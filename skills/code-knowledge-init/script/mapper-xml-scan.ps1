# mapper-xml-scan.ps1
# 扫描 MyBatis Mapper XML 中的 <resultMap> 提取表名和字段映射
# 产出格式与 entity-scan-result.md 对齐，供下游 LLM 统一处理
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$OutputDir,
  [string]$EntityResultPath = ""  # 可选：entity-scan-result.md 路径，用于去重
)

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# 加载 entity-scan 已扫到的表名（用于去重）
$existingTables = @{}
if ($EntityResultPath -and (Test-Path $EntityResultPath)) {
  Get-Content $EntityResultPath -Encoding UTF8 | ForEach-Object {
    if ($_ -match '^###\\s+(\\S+)\\s+\\(') { $existingTables[$Matches[1].ToLower()] = $true }
  }
}

$TAG_TODO = "[" + [char]0x9700 + [char]0x4EBA + [char]0x5DE5 + [char]0x786E + [char]0x8BA4 + "]"  # [需人工确认]
$mdLines = [System.Collections.Generic.List[string]]::new()
$tableCount = 0
$totalFieldCount = 0

# 扫描所有 Mapper XML 文件
Get-ChildItem -Path $SourceRoot -Recurse -Filter "*Mapper.xml" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $xmlPath = $_.FullName
  $moduleName = ""
  # 从路径中提取模块名（取 src/main 前一级目录名）
  if ($xmlPath -match '[\\\\/]([^\\\\/]+)[\\\\/]src[\\\\/]') { $moduleName = $Matches[1] }

  try {
    $content = Get-Content $xmlPath -Raw -Encoding UTF8
    # 过滤 XML 注释避免干扰
    $content = $content -replace '(?s)<!--.*?-->', ''
  } catch {
    return
  }

  # 提取所有 <resultMap> 块
  $rmMatches = [regex]::Matches($content, '(?s)<resultMap\\s[^>]*>(.*?)</resultMap>')
  foreach ($rm in $rmMatches) {
    $rmTag = $rm.Value
    # 提取 type 属性（全限定类名）
    $typeMatch = [regex]::Match($rmTag, 'type\\s*=\\s*"([^"]+)"')
    if (-not $typeMatch.Success) { continue }
    $fullType = $typeMatch.Groups[1].Value
    $className = ($fullType -split '\\.')[-1]

    # 提取 id 属性（用于标识）
    $idMatch = [regex]::Match($rmTag, '\\bid\\s*=\\s*"([^"]+)"')
    $rmId = if ($idMatch.Success) { $idMatch.Groups[1].Value } else { "unknown" }
    # 跳过非 BaseResultMap 的扩展映射（通常是查询专用的，会重复）
    if ($rmId -ne "BaseResultMap" -and $rmId -ne "baseResultMap" -and $rmId -notmatch '(?i)base') {
      # 检查是否有 extends，如果有说明是扩展映射，跳过
      if ($rmTag -match 'extends\\s*=\\s*"') { continue }
    }

    # 提取表名
    $tableName = ""
    # 方法1（优先）：从类名推断（CamelCase → snake_case，去掉常见后缀）
    $cleanName = $className -replace '(PO|Entity|DO|Model|Domain)$', ''
    $tableName = ($cleanName -creplace '([A-Z])', '_$1').TrimStart('_').ToLower()

    # 方法2（辅助）：从当前 resultMap 对应的 insert/update 语句中提取表名验证
    # 查找 namespace 对应的 insert 语句（更精确）
    $nsMatch = [regex]::Match($content, 'namespace\\s*=\\s*"([^"]+)"')
    if ($nsMatch.Success) {
      # 从 insert 语句提取表名（insert into TABLE_NAME）
      $insertMatch = [regex]::Match($content, '(?i)insert\\s+into\\s+(\\w+)')
      if ($insertMatch.Success) { $tableName = $insertMatch.Groups[1].Value }
      else {
        # 从 update 语句提取（update TABLE_NAME）
        $updateMatch = [regex]::Match($content, '(?i)(?<!\\w)update\\s+(\\w+)\\s')
        if ($updateMatch.Success) { $tableName = $updateMatch.Groups[1].Value }
      }
    }

    # 去重：如果 entity-scan 已扫到该表，跳过
    if ($existingTables.ContainsKey($tableName.ToLower())) { continue }
    if ($existingTables.ContainsKey($className.ToLower())) { continue }

    # 提取字段：<id> 和 <result> 标签
    $fieldRows = [System.Collections.Generic.List[string]]::new()
    $seenColumns = @{}
    $fieldMatches = [regex]::Matches($rmTag, '<(?:id|result)\\s+([^/]*?)/?>')
    foreach ($fm in $fieldMatches) {
      $attrs = $fm.Groups[1].Value
      $colMatch = [regex]::Match($attrs, 'column\\s*=\\s*"([^"]+)"')
      $propMatch = [regex]::Match($attrs, 'property\\s*=\\s*"([^"]+)"')
      $typeMatch2 = [regex]::Match($attrs, 'jdbcType\\s*=\\s*"([^"]+)"')
      $javaTypeMatch = [regex]::Match($attrs, 'javaType\\s*=\\s*"([^"]+)"')

      $col = if ($colMatch.Success) { $colMatch.Groups[1].Value } else { "unknown" }
      if ($seenColumns.ContainsKey($col)) { continue }
      $seenColumns[$col] = $true
      $prop = if ($propMatch.Success) { $propMatch.Groups[1].Value } else { "" }
      $fType = if ($javaTypeMatch.Success) { ($javaTypeMatch.Groups[1].Value -split '\\.')[-1] }
               elseif ($typeMatch2.Success) { $typeMatch2.Groups[1].Value }
               else { "Object" }

      $isId = $fm.Value -match '^<id\\b'
      $req = if ($isId) { [char]0x662F } else { [char]0x5426 }  # 是/否
      $desc = if ($isId) { [char]0x4E3B + [char]0x952E }        # 主键
              else { $TAG_TODO }

      $fieldRows.Add("| $col | $fType | $req | - | $desc |")
      $totalFieldCount++
    }

    if ($fieldRows.Count -eq 0) { continue }

    # 中文表头
    $hdr = "| $([char]0x5B57)$([char]0x6BB5)$([char]0x540D) | $([char]0x7C7B)$([char]0x578B) | $([char]0x5FC5)$([char]0x586B) | $([char]0x9ED8)$([char]0x8BA4)$([char]0x503C) | $([char]0x8BF4)$([char]0x660E) |"
    $sep = "|--------|------|------|--------|------|"

    $sourceNote = "> " + [char]0x6765 + [char]0x6E90 + ": Mapper XML ($($_.Name))"  # 来源: Mapper XML
    $modNote = if ($moduleName) { " ($moduleName)" } else { "" }

    $mdLines.Add("### $tableName ($className$modNote)")
    $mdLines.Add("")
    $mdLines.Add($sourceNote)
    $mdLines.Add("")
    $mdLines.Add($hdr)
    $mdLines.Add($sep)
    foreach ($r in $fieldRows) { $mdLines.Add($r) }
    $mdLines.Add("")
    $tableCount++
    $existingTables[$tableName.ToLower()] = $true  # 防止同文件多个 resultMap 重复
  }
}

# Output
$header = "> MapperXML: $tableCount, Fields: $totalFieldCount"
$body = $header + [Environment]::NewLine + [Environment]::NewLine + ($mdLines -join [Environment]::NewLine)
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "mapper-xml-scan-result.md"), $body, $utf8BOM)

Write-Host "MapperXML: $tableCount, Fields: $totalFieldCount"