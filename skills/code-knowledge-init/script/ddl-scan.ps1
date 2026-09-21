# ddl-scan.ps1
# 扫描 DDL 脚本（*.sql），提取 CREATE TABLE 的表与列，回放 ALTER TABLE 到最新态，
# 并抽取 COMMENT ON TABLE / COMMENT ON COLUMN 作为表/列说明。
#
# 版本回放（通用，不写死任何项目专有前缀）：
#   同一张表可能分布在多个"版本"的 SQL 中（先 CREATE 后 ALTER）。本脚本按"版本号升序 + 路径 + 文件名"
#   排序回放，得到每张表最新态（最后一次 CREATE TABLE 为基准，其后的 ALTER ADD/DROP COLUMN 叠加）。
#   版本号识别按下列多策略自动适配不同项目（命中即停）：
#     1) -VersionRegex 显式指定（捕获组1为版本串，形如 '1.2.3'/'2_1_0'），最高优先；
#     2) Flyway 命名：文件名形如 V<版本>__desc.sql（V1__/V1_2__/V1.2.3__）；
#     3) 通用路径版本目录：路径中形如 <任意前缀><x.y[.z...]> 的多段数字（如 release-3.4.0、v2.1、PROJ-1.2.3）；
#     4) 均未命中 → 版本 key 归零，退化为"按路径 + 文件名字典序"回放（单文件全量/无版本组织同样可用）。
#   分隔符 '.' 与 '_' 等价处理；版本段数不固定，比较时短段补 0。
#
# 只针对 SQL（PostgreSQL / MySQL 语法兼容）。产出：
#   - <OutputDir>\ddl-scan-result.md   （人读：按表列出字段 + 说明 + 来源行）
#   - <ProvenanceJson>（可选，机读：表/列/来源文件行号/版本）
#
# 只增强不破坏：新脚本，独立于 entity-scan.ps1。
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$OutputDir,
  [string]$ProvenanceJson = "",
  # 可选：项目自定义版本正则（捕获组1为版本串）。示例：'AIAS-CCPS(\d+(?:\.\d+)*)' 或 'release[-_](\d+(?:\.\d+)*)'
  [string]$VersionRegex = ""
)

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$SEG_COUNT = 6  # 版本 key 统一段数（补零对齐，兼容任意段数版本）

# 从版本串（如 "1.2.3" / "2_1_0"）解析为整数数组
function Parse-VersionString {
  param([string]$s)
  if (-not $s) { return @() }
  $parts = $s -split '[._]'
  $k = @()
  foreach ($p in $parts) { if ($p -match '^\d+$') { $k += [int]$p } }
  return $k
}

# 通用版本串提取：按多策略（VersionRegex > Flyway > 通用多段数字）返回版本字符串，未命中返回 ''
function Get-VersionString {
  param([string]$path, [string]$fileName)
  if ($script:VersionRegex -ne "") {
    $m = [regex]::Match($path, $script:VersionRegex)
    if ($m.Success -and $m.Groups.Count -gt 1) { return $m.Groups[1].Value }
  }
  # Flyway: 文件名 V<版本>__desc.sql
  $fm = [regex]::Match($fileName, '(?i)^V(\d+(?:[._]\d+)*)__')
  if ($fm.Success) { return $fm.Groups[1].Value }
  # 通用：路径中最后一个"多段数字"（至少两段，避免把单个普通数字误当版本），可带任意前缀
  $gms = [regex]::Matches($path, '(\d+(?:[._]\d+)+)')
  if ($gms.Count -gt 0) { return $gms[$gms.Count - 1].Groups[1].Value }
  return ''
}

# 版本 key：定长补零的可排序字符串
function Get-VersionSortKey {
  param([string]$path, [string]$fileName)
  $arr = Parse-VersionString (Get-VersionString $path $fileName)
  $sb = @()
  for ($i=0; $i -lt $SEG_COUNT; $i++) {
    if ($i -lt $arr.Count) { $sb += ('{0:D6}' -f $arr[$i]) } else { $sb += '000000' }
  }
  return ($sb -join '.')
}

function Normalize-TableName {
  param([string]$name)
  if (-not $name) { return "" }
  $n = $name.Trim().ToLower()
  # 去 schema 前缀（可能带引号：public."x" / "public"."x"）
  if ($n -match '\.') { $n = ($n -split '\.')[-1] }
  # 去残留的反引号/双引号/单引号（可能出现在两端）
  $n = $n -replace '[`"'']',''
  return $n.Trim()
}

$srcRootFull = (Resolve-Path $SourceRoot).Path

# 收集所有 .sql 文件，按版本升序（老版本先回放，新版本覆盖）；无版本信息时退化为路径+文件名字典序
$sqlFiles = Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.sql" | Where-Object {
  $_.FullName -notlike "*\target\*" -and $_.FullName -notlike "*\.git\*"
} | Sort-Object `
    @{Expression={ Get-VersionSortKey $_.FullName $_.Name }}, `
    @{Expression={ $_.DirectoryName }}, `
    @{Expression={ $_.Name }}

# tables: normName -> ordered hash { name, columns(ordered: colName->@{type,comment,file,line}), tableComment, file, line, version }
$tables = [ordered]@{}

foreach ($f in $sqlFiles) {
  $raw = $null
  try { $raw = Get-Content $f.FullName -Raw -Encoding UTF8 } catch { $raw = $null }
  if ([string]::IsNullOrWhiteSpace($raw)) { continue }
  $relPath = $f.FullName
  if ($relPath.StartsWith($srcRootFull)) { $relPath = $relPath.Substring($srcRootFull.Length).TrimStart('\','/') }
  $relPath = $relPath -replace '\\','/'
  $verStr = Get-VersionString $f.FullName $f.Name

  # 计算行号：用原始行数组定位每个 CREATE TABLE
  $lines = $raw -split "`n"

  # --- CREATE TABLE ... ( ... ) ---
  foreach ($cm in [regex]::Matches($raw, '(?is)CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([`"\w\.]+)\s*\((.*?)\)\s*;')) {
    $tname = $cm.Groups[1].Value
    $norm = Normalize-TableName $tname
    if (-not $norm) { continue }
    # 行号：CREATE TABLE 出现处
    $before = $raw.Substring(0, $cm.Index)
    $lineNo = ([regex]::Matches($before, "`n")).Count + 1

    $body = $cm.Groups[2].Value
    $cols = [ordered]@{}
    foreach ($bl in ($body -split "`n")) {
      $t = $bl.Trim().TrimEnd(',')
      if ($t -eq '') { continue }
      # 跳过约束/索引行
      if ($t -match '(?i)^\s*(CONSTRAINT|PRIMARY\s+KEY|UNIQUE|KEY|INDEX|FOREIGN\s+KEY|CHECK)\b') { continue }
      # 列定义：col_name type ...
      $lm = [regex]::Match($t, '^\s*[`"]?(\w+)[`"]?\s+([A-Za-z0-9_]+(?:\s*\([^)]*\))?)')
      if ($lm.Success) {
        $cn = $lm.Groups[1].Value.ToLower()
        $ct = $lm.Groups[2].Value.Trim()
        if ($cols.Contains($cn)) { continue }
        $cols[$cn] = @{ type=$ct; comment=""; }
      }
    }
    # 最新态：后出现（更高版本）覆盖
    $tables[$norm] = [ordered]@{
      name=$tname; norm=$norm; columns=$cols; tableComment="";
      file=$relPath; line=$lineNo; version=$verStr
    }
  }

  # --- ALTER TABLE ... ADD [COLUMN] col type ---
  foreach ($am in [regex]::Matches($raw, '(?is)ALTER\s+TABLE\s+([`"\w\.]+)\s+ADD\s+(?:COLUMN\s+)?[`"]?(\w+)[`"]?\s+([A-Za-z0-9_]+(?:\s*\([^)]*\))?)')) {
    $norm = Normalize-TableName $am.Groups[1].Value
    if (-not $tables.Contains($norm)) { continue }
    $cn = $am.Groups[2].Value.ToLower(); $ct = $am.Groups[3].Value.Trim()
    if (-not $tables[$norm].columns.Contains($cn)) { $tables[$norm].columns[$cn] = @{ type=$ct; comment="" } }
    else { $tables[$norm].columns[$cn].type = $ct }
  }
  # --- ALTER TABLE ... DROP [COLUMN] col ---
  foreach ($dm in [regex]::Matches($raw, '(?is)ALTER\s+TABLE\s+([`"\w\.]+)\s+DROP\s+(?:COLUMN\s+)?[`"]?(\w+)[`"]?')) {
    $norm = Normalize-TableName $dm.Groups[1].Value
    if (-not $tables.Contains($norm)) { continue }
    $cn = $dm.Groups[2].Value.ToLower()
    if ($tables[$norm].columns.Contains($cn)) { $tables[$norm].columns.Remove($cn) }
  }

  # --- COMMENT ON TABLE x IS '...' ---
  foreach ($tcm in [regex]::Matches($raw, "(?is)COMMENT\s+ON\s+TABLE\s+([``""\w\.]+)\s+IS\s+'((?:[^']|'')*)'")) {
    $norm = Normalize-TableName $tcm.Groups[1].Value
    if ($tables.Contains($norm)) { $tables[$norm].tableComment = ($tcm.Groups[2].Value -replace "''","'").Trim() }
  }
  # --- COMMENT ON COLUMN x.col IS '...' ---
  foreach ($ccm in [regex]::Matches($raw, "(?is)COMMENT\s+ON\s+COLUMN\s+([``""\w\.]+)\.[``""]?(\w+)[``""]?\s+IS\s+'((?:[^']|'')*)'")) {
    $norm = Normalize-TableName $ccm.Groups[1].Value
    $cn = $ccm.Groups[2].Value.ToLower()
    $cmt = ($ccm.Groups[3].Value -replace "''","'").Trim()
    if ($tables.Contains($norm) -and $tables[$norm].columns.Contains($cn)) { $tables[$norm].columns[$cn].comment = $cmt }
  }
}

# 产出 markdown
$nl = [Environment]::NewLine
$TAG_TODO = "[" + [char]0x9700 + [char]0x4EBA + [char]0x5DE5 + [char]0x786E + [char]0x8BA4 + "]"
$md = [System.Collections.Generic.List[string]]::new()
$tableCount = $tables.Count
$colTotal = 0
foreach ($k in $tables.Keys) { $colTotal += $tables[$k].columns.Count }
$md.Add("> DDL Tables: $tableCount, Columns: $colTotal")
$md.Add("")
$hdr = "| $([char]0x5B57)$([char]0x6BB5)$([char]0x540D) | $([char]0x7C7B)$([char]0x578B) | $([char]0x8BF4)$([char]0x660E) |"
$sep = "|--------|------|------|"
$prov = [System.Collections.Generic.List[object]]::new()
foreach ($k in $tables.Keys) {
  $tb = $tables[$k]
  $tc = if ($tb.tableComment) { $tb.tableComment } else { $TAG_TODO }
  $md.Add("### $($tb.norm)")
  $md.Add("")
  $md.Add("> $tc")
  $md.Add("> " + [char]0x6765 + [char]0x6E90 + ": $($tb.file):$($tb.line) (DDL" + $(if($tb.version){" v$($tb.version)"}else{""}) + ")")
  $md.Add("")
  $md.Add($hdr)
  $md.Add($sep)
  foreach ($cn in $tb.columns.Keys) {
    $col = $tb.columns[$cn]
    $cc = if ($col.comment) { $col.comment } else { $TAG_TODO }
    $md.Add("| $cn | $($col.type) | $cc |")
  }
  $md.Add("")
  $prov.Add([ordered]@{ table=$tb.norm; source="ddl"; file=$tb.file; line=$tb.line; version=$tb.version; columns=$tb.columns.Count })
}

$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "ddl-scan-result.md"), ($md -join $nl), $utf8BOM)

if ($ProvenanceJson -ne "") {
  $pd = Split-Path $ProvenanceJson -Parent
  if ($pd -and -not (Test-Path $pd)) { New-Item -ItemType Directory -Path $pd -Force | Out-Null }
  $utf8 = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($ProvenanceJson, ($prov | ConvertTo-Json -Depth 5), $utf8)
}

Write-Host "DDL Tables: $tableCount, Columns: $colTotal"
