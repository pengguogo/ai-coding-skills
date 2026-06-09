# model-scan.ps1
# 互补扫描：扫描数据模型目录下无 ORM 注解的 POJO 类（自动排除已被 entity-scan 覆盖的 ORM 实体）
# 与 entity-scan.ps1 配合使用，始终执行，两者结果合并构成完整数据模型全景
# - entity-scan.ps1 负责：@TableName / @Entity / @Table 标注的 ORM 实体
# - model-scan.ps1 负责：数据模型目录下的纯 POJO 数据模型（内存缓存、消息传输、DTO、事件、请求/响应等）
# 目录白名单（25 个）：
#   第一梯队（通用数据模型，7 个）：model entity dto vo domain bean pojo
#   第二梯队（传输/事件/命令，9 个）：event request response param command data message payload record
#   第三梯队（业务对象/表单/契约，9 个）：bo form result transfer contract schema types value aggregate
# 注意：query 目录已排除——在查询引擎框架（如 CQEngine）中 query/ 下是查询条件实现类而非数据模型，噪音过大
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$OutputDir
)

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

function Clean-Comment {
  param([string]$raw)
  $c = $raw -replace '/\\*\\*|\\*/|\\*|//', '' -replace '<[^>]+>', ''
  $c = $c -replace '@(author|since|date|version|see|param|return|throws)\\b[^\\r\\n]*', ''
  return ($c -replace '\\s+', ' ').Trim()
}

function CamelToSnake {
  param([string]$name)
  return ($name -creplace '([A-Z])', '_$1').TrimStart('_').ToLower()
}

$TAG_TODO = "[" + [char]0x9700 + [char]0x4EBA + [char]0x5DE5 + [char]0x786E + [char]0x8BA4 + "]"
$mdLines = [System.Collections.Generic.List[string]]::new()
$modelCount = 0
$totalFieldCount = 0

# Scan .java files under data model directories (25 directory names, case-insensitive)
# Tier 1 (7): model entity dto vo domain bean pojo
# Tier 2 (9): event request response param command data message payload record
# Tier 3 (9): bo form result transfer contract schema types value aggregate
$MODEL_DIRS = 'model|entity|dto|vo|domain|bean|pojo|event|request|response|param|command|data|message|payload|record|bo|form|result|transfer|contract|schema|types|value|aggregate'
Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $dir = $_.DirectoryName.Replace('\\', '/')
  # Exclude test and target directories
  if ($dir -match '[\\\\/](test|target)[\\\\/]') { return $false }
  if ($dir -match '[\\\\/]\\.git[\\\\/]') { return $false }
  # Match files in data model directories (any depth)
  $dir -match "/($MODEL_DIRS)(/|$)"
} | ForEach-Object {
  $content = Get-Content $_.FullName -Raw -Encoding UTF8
  $lines = Get-Content $_.FullName -Encoding UTF8

  # Skip interfaces, enums, abstract classes, annotations
  $classLine = ($lines | Select-String '^\\s*public\\s+class\\s+(\\w+)' | Select-Object -First 1)
  if (-not $classLine) { return }
  $className = $classLine.Matches[0].Groups[1].Value

  # Skip if class has ORM annotations (should have been caught by entity-scan)
  if ($content -match '@(TableName|Entity|Table)\\b') { return }
  # Skip if class has no fields (likely a marker interface or utility)
  if (-not ($content -match '(private|protected)\\s+\\w+')) { return }

  # Extract class comment
  $classComment = ""
  $idx = $classLine.LineNumber - 1
  if ($idx -gt 0) {
    $cLines = @()
    for ($i = $idx - 1; $i -ge 0; $i--) {
      $ln = $lines[$i].Trim()
      if ($ln -match '^\\*/' -or $ln -match '^\\*' -or $ln -match '^/\\*\\*' -or $ln -match '^//') { $cLines = ,$ln + $cLines }
      elseif ($ln -match '^@' -or $ln -match '^\\)' -or $ln -match '^\\w+\\s*=' -or $ln -match '^\\}') { continue }
      else { break }
    }
    $classComment = Clean-Comment ($cLines -join " ")
  }

  # Determine module from package path
  $pkg = ($lines | Select-String "^package " | Select-Object -First 1).Line -replace 'package\\s+', '' -replace ';', ''
  $moduleName = "root"
  if ($pkg -match "($MODEL_DIRS)\\.(\\w+)") { $moduleName = $Matches[2] }
  elseif ($pkg -match "($MODEL_DIRS)$") { $moduleName = "root" }

  # Check extends
  $extMatch = [regex]::Match(($lines[$idx]), 'extends\\s+(\\w+)')
  $extNote = if ($extMatch.Success) { "> extends \`\`$($extMatch.Groups[1].Value)\`\`" } else { "" }
  # Check implements
  $implMatch = [regex]::Match(($lines[$idx]), 'implements\\s+([\\w,\\s<>]+)\\s*\\{')
  $implNote = if ($implMatch.Success) { "> implements \`\`$($implMatch.Groups[1].Value.Trim())\`\`" } else { "" }

  $tDesc = if ($classComment) { $classComment } else { $TAG_TODO }

  # Extract fields
  $fieldRows = [System.Collections.Generic.List[string]]::new()
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\\s*(private|protected|public)\\s+' -and $line -notmatch '\\bclass\\s' -and $line -match ';\\s*$' -and $line -notmatch '\\bstatic\\b') {
      $fl = ($line.Trim() -replace ';.*', '' -replace '\\s*=\\s*.*', '').Trim()
      $st = $fl -replace '^\\s*(private|protected|public)\\s+', '' -replace '\\b(final|volatile|transient)\\s+', ''
      $ps = $st -split '\\s+'
      if ($ps.Count -lt 2) { continue }
      $fName = $ps[-1]; $fType = ($ps[0..($ps.Count-2)] -join ' ').Trim()

      # Extract field comment from preceding lines
      $fComment = ""
      for ($j = $i - 1; $j -ge 0; $j--) {
        $p = $lines[$j].Trim()
        if ($p -match '^\\*/' -or $p -match '^\\*' -or $p -match '^/\\*\\*' -or $p -match '^//') { $fComment = $p + " " + $fComment }
        elseif ($p -match '^@') { continue }
        else { break }
      }
      $fComment = Clean-Comment $fComment
      if (-not $fComment) { $fComment = $TAG_TODO }

      $fieldRows.Add("| $fName | $fType | $fComment |")
      $totalFieldCount++
    }
  }

  if ($fieldRows.Count -eq 0) { return }

  # Chinese table header
  $hdr = "| $([char]0x5B57)$([char]0x6BB5)$([char]0x540D) | $([char]0x7C7B)$([char]0x578B) | $([char]0x8BF4)$([char]0x660E) |"
  $sep = "|--------|------|------|"

  $mdLines.Add("### $className ($moduleName)")
  $mdLines.Add("")
  $mdLines.Add("> $tDesc")
  if ($extNote) { $mdLines.Add($extNote) }
  if ($implNote) { $mdLines.Add($implNote) }
  $mdLines.Add("")
  $mdLines.Add($hdr)
  $mdLines.Add($sep)
  foreach ($r in $fieldRows) { $mdLines.Add($r) }
  $mdLines.Add("")
  $modelCount++
}

$header = "> Model: $modelCount, Fields: $totalFieldCount"
$body = $header + [Environment]::NewLine + [Environment]::NewLine + ($mdLines -join [Environment]::NewLine)
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "model-scan-result.md"), $body, $utf8BOM)

Write-Host "Model: $modelCount, Fields: $totalFieldCount"