# entity-scan.ps1
# 扫描 Java 持久化实体（MyBatis-Plus @TableName / JPA @Entity/@Table），产出表结构清单。
#
# 增强点（只增强不破坏，保留原 -SourceRoot/-OutputDir 参数与 entity-scan-result.md 输出格式）：
#   1. 剥注释：先去除 /* */ 块注释与 // 行注释，再判断注解，避免 Javadoc 中 "@Table:" 等被误判为实体。
#   2. 排除非实体类：类上带 @RestController/@Controller/@Service/@Component/@Configuration/
#      @SpringBootApplication/@Mapper/@FeignClient/@Repository 等的一律跳过。
#   3. 注解位置校验：实体注解（@TableName(/@Table(/@Entity）必须出现在 public class 声明之前的注解区。
#   4. 记录来源位置（文件相对路径 + 行号），人读写入表标题下，机读写入 -ProvenanceJson 指定的 json。
#   5. 行尾注释：字段声明同一行上的 // 说明（如 private String x; // 字典类型）须提取，优先级低于字段上方 Javadoc/独立行 //。
# 仅针对 Java。
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$OutputDir,
  [string]$ProvenanceJson = "",       # 可选：机读溯源 json 输出路径（不传则不生成）
  [string]$ModuleName = ""            # 可选：模块名，写入溯源记录
)

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

function Clean-Comment {
  param([string]$raw)
  $c = $raw -replace '/\*\*|\*/|\*|//', '' -replace '<[^>]+>', ''
  $c = $c -replace '@(author|since|date|version|see|param|return|throws)\b[^\r\n]*', ''
  return ($c -replace '\s+', ' ').Trim()
}

function CamelToSnake {
  param([string]$name)
  return ($name -creplace '([A-Z])', '_$1').TrimStart('_').ToLower()
}

# 剥离 Java 源码中的块注释与行注释（保留行结构，便于后续按行判断），返回"去注释后的整体文本"。
# 注意：仅用于"是否为实体/是否含排除注解"的判定；字段说明仍从原始注释提取。
function Strip-JavaComments {
  param([string]$text)
  # 去块注释 /* ... */（含 Javadoc /** */），非贪婪，跨行
  $noBlock = [regex]::Replace($text, '/\*[\s\S]*?\*/', ' ')
  # 去行注释 //...（行尾）
  $noLine = [regex]::Replace($noBlock, '//[^\r\n]*', ' ')
  return $noLine
}

# 归一化表名：小写、去反引号/引号、去 schema 前缀（a.b -> b）
function Normalize-TableName {
  param([string]$name)
  if (-not $name) { return "" }
  $n = $name.Trim().ToLower()
  if ($n -match '\.') { $n = ($n -split '\.')[-1] }
  $n = $n -replace '[`"'']',''
  return $n.Trim()
}

# 提取字段声明行尾 // 注释（须在剥离 ; 之后内容之前调用原始行）
function Get-InlineLineComment {
  param([string]$line)
  $m = [regex]::Match($line, ';\s*//(.+)$')
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return ""
}

function Is-EmptyComment {
  param([string]$text, [string]$placeholder)
  if (-not $text) { return $true }
  $t = $text.Trim()
  if (-not $t) { return $true }
  if ($placeholder -and $t -eq $placeholder) { return $true }
  return $false
}

# 排除性注解（类级）：出现即判定为非实体类
$EXCLUDE_ANNO = @(
  '@RestController','@Controller','@RestControllerAdvice','@ControllerAdvice',
  '@Service','@Component','@Configuration','@SpringBootApplication',
  '@Mapper','@FeignClient','@Repository','@Aspect','@Interceptor'
)

$mdLines = [System.Collections.Generic.List[string]]::new()
$provRecords = [System.Collections.Generic.List[object]]::new()
$entityCount = 0
$totalFieldCount = 0
$TAG_TODO = "[" + [char]0x9700 + [char]0x4EBA + [char]0x5DE5 + [char]0x786E + [char]0x8BA4 + "]"  # [需人工确认]
$srcRootFull = (Resolve-Path $SourceRoot).Path

Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\target\*" -and $_.FullName -notlike "*\src\test\*" -and $_.FullName -notlike "*\.git\*"
} | ForEach-Object {
  $filePath = $_.FullName
  $content = Get-Content $filePath -Raw -Encoding UTF8

  # --- 增强1：剥注释后再判断，避免注释中的 @Table: / @Entity 误命中 ---
  $stripped = Strip-JavaComments $content

  # --- 增强3：实体注解必须真实存在（带括号或独立注解），且在剥注释后的文本中 ---
  $hasEntityAnno = ($stripped -match '@TableName\s*\(') -or `
                   ($stripped -match '@Table\s*\(') -or `
                   ($stripped -match '@Entity\b')
  if (-not $hasEntityAnno) { return }

  # --- 增强2：排除非实体类（Controller/Service/Config/Mapper 等） ---
  $isExcluded = $false
  foreach ($ex in $EXCLUDE_ANNO) {
    if ($stripped -match [regex]::Escape($ex) + '\b') { $isExcluded = $true; break }
  }
  if ($isExcluded) { return }

  $lines = Get-Content $filePath -Encoding UTF8

  # 定位类声明行
  $classLine = ($lines | Select-String '^\s*public\s+(abstract\s+)?class\s+(\w+)' | Select-Object -First 1)
  if (-not $classLine) { return }
  $className = $classLine.Matches[0].Groups[2].Value
  $classLineNo = $classLine.LineNumber   # 1-based

  # --- 增强3续：确认实体注解出现在类声明之前的注解区（紧邻类头，向上扫描至遇到非注解/非注释行）---
  $annoLineNo = -1
  $annoKind = ""
  for ($k = $classLineNo - 2; $k -ge 0; $k--) {
    $raw = $lines[$k]
    $t = $raw.Trim()
    if ($t -eq '') { continue }
    if ($t -match '^//' -or $t -match '^/\*' -or $t -match '^\*' -or $t -match '^\*/') { continue }
    if ($t -match '@TableName\s*\(') { $annoLineNo = $k + 1; $annoKind = '@TableName'; break }
    if ($t -match '@Table\s*\(')     { if ($annoLineNo -lt 0) { $annoLineNo = $k + 1; $annoKind = '@Table' } ; continue }
    if ($t -match '@Entity\b')       { if ($annoLineNo -lt 0) { $annoLineNo = $k + 1; $annoKind = '@Entity' } ; continue }
    if ($t -match '^@') { continue }        # 其它注解，继续向上
    break                                    # 遇到非注解非注释代码行，停止
  }
  # 若类头前注解区未发现实体注解，视为非实体（如注解误写在别处），跳过
  if ($annoLineNo -lt 0) { return }

  # 类注释（业务说明）——仍从原始行提取
  $classComment = ""
  $idx = $classLineNo - 1
  if ($idx -gt 0) {
    $cLines = @()
    for ($i = $idx - 1; $i -ge 0; $i--) {
      $ln = $lines[$i].Trim()
      if ($ln -match '^\*/' -or $ln -match '^\*' -or $ln -match '^/\*\*' -or $ln -match '^//') { $cLines = ,$ln + $cLines }
      elseif ($ln -match '^@' -or $ln -match '^\)' -or $ln -match '^\w+\s*=' -or $ln -match '^\}') { continue }
      else { break }
    }
    $classComment = Clean-Comment ($cLines -join " ")
  }

  # 表名：优先 @TableName("x") / @Table(name="x")，否则类名驼峰转下划线
  $tnMatch = [regex]::Match($content, '@TableName\s*\(\s*(?:value\s*=\s*)?"([^"]+)"')
  if (-not $tnMatch.Success) { $tnMatch = [regex]::Match($content, '@Table\s*\(\s*name\s*=\s*"([^"]+)"') }
  $tableName = if ($tnMatch.Success) { $tnMatch.Groups[1].Value } else { CamelToSnake $className }
  $normTable = Normalize-TableName $tableName

  $extMatch = [regex]::Match(($lines[$idx]), 'extends\s+(\w+)')
  $extNote = if ($extMatch.Success) { "> extends ``$($extMatch.Groups[1].Value)``" } else { "" }
  $tDesc = if ($classComment) { $classComment } else { $TAG_TODO }

  # 相对路径（相对 SourceRoot）
  $relPath = $filePath
  if ($filePath.StartsWith($srcRootFull)) { $relPath = $filePath.Substring($srcRootFull.Length).TrimStart('\','/') }
  $relPath = $relPath -replace '\\','/'

  $fieldRows = [System.Collections.Generic.List[string]]::new()
  $fieldCountThis = 0
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*(private|protected|public)\s+' -and $line -notmatch '\bclass\s' -and $line -match ';\s*' -and $line -notmatch '\bstatic\b') {
      $rawLine = $line.Trim()
      $inlineComment = Get-InlineLineComment $rawLine
      $fl = ($rawLine -replace ';.*', '' -replace '\s*=\s*.*', '').Trim()
      $st = $fl -replace '^\s*(private|protected|public)\s+', '' -replace '\b(final|volatile|transient)\s+', ''
      $ps = $st -split '\s+'
      if ($ps.Count -lt 2) { continue }
      $fName = $ps[-1]; $fType = ($ps[0..($ps.Count-2)] -join ' ').Trim()

      # 过滤伪字段：Java 关键字/控制流（if/for/while/return/switch/case/else/new 等）被误当字段
      $JAVA_KW = @('if','for','while','return','switch','case','else','new','do','try','catch','finally','throw','throws','synchronized','instanceof')
      if ($JAVA_KW -contains $fName.ToLower()) { continue }
      if ($JAVA_KW -contains $fType.ToLower()) { continue }
      # 字段名/类型必须是合法 Java 标识符（排除含括号、运算符等的行）
      if ($fName -notmatch '^[A-Za-z_$][A-Za-z0-9_$]*$') { continue }
      if ($fType -match '[(){}=<>!&|+]') { continue }

      $fComment = ""; $ignored = $false; $required = $false; $colName = CamelToSnake $fName
      for ($j = $i - 1; $j -ge 0; $j--) {
        $p = $lines[$j].Trim()
        if ($p -match '^@') {
          if ($p -match '@TableField\s*\(.*exist\s*=\s*false' -or $p -match '@Transient') { $ignored = $true }
          if ($p -match '@Column\s*\(.*nullable\s*=\s*false') { $required = $true }
          $m1 = [regex]::Match($p, '@TableField\s*\(\s*(?:value\s*=\s*)?"([^"]+)"'); if ($m1.Success) { $colName = $m1.Groups[1].Value }
          $m2 = [regex]::Match($p, '@Column\s*\(.*name\s*=\s*"([^"]+)"'); if ($m2.Success) { $colName = $m2.Groups[1].Value }
        } elseif ($p -match '^\*/' -or $p -match '^\*' -or $p -match '^/\*\*' -or $p -match '^//') { $fComment = $p + " " + $fComment }
        else { break }
      }
      if ($ignored) { continue }
      $fComment = Clean-Comment $fComment
      if (Is-EmptyComment $fComment $TAG_TODO) {
        $fComment = Clean-Comment $inlineComment
      }
      if (Is-EmptyComment $fComment $TAG_TODO) { $fComment = $TAG_TODO }
      $req = if ($required) { [char]0x662F } else { [char]0x5426 }

      $fieldRows.Add("| $colName | $fType | $req | - | $fComment |")
      $totalFieldCount++
      $fieldCountThis++
    }
  }

  $hdr = "| $([char]0x5B57)$([char]0x6BB5)$([char]0x540D) | $([char]0x7C7B)$([char]0x578B) | $([char]0x5FC5)$([char]0x586B) | $([char]0x9ED8)$([char]0x8BA4)$([char]0x503C) | $([char]0x8BF4)$([char]0x660E) |"
  $sep = "|--------|------|------|--------|------|"

  $mdLines.Add("### $tableName ($className)")
  $mdLines.Add("")
  $mdLines.Add("> $tDesc")
  # 来源溯源（人读）：来源类型 + 相对路径:行号
  $mdLines.Add("> " + [char]0x6765 + [char]0x6E90 + ": $relPath`:$annoLineNo ($annoKind)")
  if ($extNote) { $mdLines.Add($extNote) }
  $mdLines.Add("")
  $mdLines.Add($hdr)
  $mdLines.Add($sep)
  foreach ($r in $fieldRows) { $mdLines.Add($r) }
  $mdLines.Add("")
  $entityCount++

  # 机读溯源记录
  $provRecords.Add([ordered]@{
    table       = $tableName
    normalized  = $normTable
    source      = "entity"
    annotation  = $annoKind
    entityClass = $className
    file        = $relPath
    line        = $annoLineNo
    fieldCount  = $fieldCountThis
    module      = $ModuleName
  })
}

# 输出 markdown（UTF-8 BOM，PS 5.1 兼容）
$header = "> Entity: $entityCount, Fields: $totalFieldCount"
$mdBody = $header + [Environment]::NewLine + [Environment]::NewLine + ($mdLines -join [Environment]::NewLine)
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "entity-scan-result.md"), $mdBody, $utf8BOM)

# 输出机读溯源 json（可选）
if ($ProvenanceJson -ne "") {
  $provDir = Split-Path $ProvenanceJson -Parent
  if ($provDir -and -not (Test-Path $provDir)) { New-Item -ItemType Directory -Path $provDir -Force | Out-Null }
  $json = $provRecords | ConvertTo-Json -Depth 5
  $utf8 = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($ProvenanceJson, $json, $utf8)
  Write-Host "Provenance: $($provRecords.Count) records -> $ProvenanceJson"
}

Write-Host "Entity: $entityCount, Fields: $totalFieldCount"
