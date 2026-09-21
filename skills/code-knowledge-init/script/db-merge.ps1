# db-merge.ps1
# 将实体扫描（entity-scan）与 DDL 扫描（ddl-scan）的产出按"归一化表名"取并集去重，
# 生成：
#   1. 对账报告 reconcile-report.md（人读）：仅实体 / 仅DDL / 双有 / 疑似备份表 四清单 + 统计
#   2. 合并表清单 merged-tables.json（机读）：每张表的来源(entity/ddl/both)、实体类、文件行号、列数
#
# 输入：
#   -EntityProvDir : 存放各模块 entity-provenance.json 的根目录（递归查找 *entity-provenance.json）
#   -DdlProvJson   : ddl-scan 产出的 ddl-provenance.json
#   -OutputDir     : 报告与合并清单输出目录
#
# 归一化：小写、去 schema 前缀、去引号（与 entity-scan/ddl-scan 保持一致）。
# 备份/临时表识别（启发式，非绝对通用）：默认按 _bk/_bak/_tmp/_temp/_backup 命名识别，单列"疑似备份表"，
#   不计入业务表并集。该规则可能漏判（如 _old/_his/日期后缀）或误判（真业务表恰好以此结尾），
#   因此报告中明确标注"[需要人工复核]"，且提供 -BackupPattern 覆盖、-NoBackupFilter 关闭两条逃生舱。
# 只增强不破坏：新脚本，独立运行。
param(
  [Parameter(Mandatory=$true)][string]$EntityProvDir,
  [Parameter(Mandatory=$true)][string]$DdlProvJson,
  [Parameter(Mandatory=$true)][string]$OutputDir,
  # 可选：项目自定义备份表识别正则（匹配归一化表名即视为备份表）。不传则用默认启发式。
  [string]$BackupPattern = "",
  # 可选：关闭备份表过滤（项目无备份表命名约定时使用），所有表进入业务表并集。
  [switch]$NoBackupFilter
)

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# 默认备份表启发式（跨项目常见约定，非绝对；可被 -BackupPattern 覆盖或 -NoBackupFilter 关闭）
$DEFAULT_BACKUP_PATTERN = '(_bk|_bak|_tmp|_temp|_backup)$|(_bk|_bak|_temp|_backup)_'

function Load-Json {
  param([string]$path)
  if (-not (Test-Path $path)) { return @() }
  if ((Get-Item $path).Length -le 2) { return @() }
  $d = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($null -eq $d) { return @() }
  if ($d -is [array]) { return $d }
  return @($d)
}

function Is-Backup {
  param([string]$t)
  if ($script:NoBackupFilter) { return $false }
  $pat = if ($script:BackupPattern -ne "") { $script:BackupPattern } else { $DEFAULT_BACKUP_PATTERN }
  return ($t -match $pat)
}

# 收集实体表：normalized -> @{ entityClass; file; line; module }
$entMap = @{}
Get-ChildItem -Path $EntityProvDir -Recurse -Filter "*entity-provenance.json" | ForEach-Object {
  foreach ($r in (Load-Json $_.FullName)) {
    $n = "$($r.normalized)"
    if (-not $n) { continue }
    if (-not $entMap.ContainsKey($n)) {
      $entMap[$n] = @{ entityClass=$r.entityClass; file=$r.file; line=$r.line; module=$r.module }
    }
  }
}

# 收集 DDL 表：normalized -> @{ file; line; version; columns }
$ddlMap = @{}
foreach ($r in (Load-Json $DdlProvJson)) {
  $n = "$($r.table)"
  if (-not $n) { continue }
  if (-not $ddlMap.ContainsKey($n)) {
    $ddlMap[$n] = @{ file=$r.file; line=$r.line; version=$r.version; columns=$r.columns }
  }
}

$entKeys = $entMap.Keys
$ddlKeys = $ddlMap.Keys
$allKeys = ($entKeys + $ddlKeys) | Sort-Object -Unique

$both = @(); $onlyEnt = @(); $onlyDdl = @(); $backup = @()
$merged = [System.Collections.Generic.List[object]]::new()

foreach ($k in $allKeys) {
  $inE = $entMap.ContainsKey($k)
  $inD = $ddlMap.ContainsKey($k)
  if (Is-Backup $k) { $backup += $k; continue }
  $src = if ($inE -and $inD) { "both" } elseif ($inE) { "entity" } else { "ddl" }
  if ($src -eq "both") { $both += $k } elseif ($src -eq "entity") { $onlyEnt += $k } else { $onlyDdl += $k }
  $rec = [ordered]@{
    table = $k
    source = $src
    entityClass = if ($inE) { $entMap[$k].entityClass } else { "" }
    entityFile  = if ($inE) { "$($entMap[$k].file):$($entMap[$k].line)" } else { "" }
    module      = if ($inE) { $entMap[$k].module } else { "" }
    ddlFile     = if ($inD) { "$($ddlMap[$k].file):$($ddlMap[$k].line)" } else { "" }
    ddlVersion  = if ($inD) { $ddlMap[$k].version } else { "" }
    ddlColumns  = if ($inD) { $ddlMap[$k].columns } else { 0 }
  }
  $merged.Add($rec)
}

# 输出合并清单 json
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $OutputDir "merged-tables.json"), ($merged | ConvertTo-Json -Depth 5), $utf8)

# 输出对账报告 markdown
$nl = [Environment]::NewLine
$md = [System.Collections.Generic.List[string]]::new()
$md.Add("# " + [char]0x6570 + [char]0x636E + [char]0x8868 + [char]0x5BF9 + [char]0x8D26 + [char]0x62A5 + [char]0x544A + " (entity + DDL)")  # 数据表对账报告
$md.Add("")
$md.Add("## " + [char]0x7EDF + [char]0x8BA1)  # 统计
$md.Add("")
$md.Add("| " + [char]0x6765 + [char]0x6E90 + " | " + [char]0x8868 + [char]0x6570 + " |")  # 来源 | 表数
$md.Add("|------|------|")
$md.Add("| entity+DDL (both) | $($both.Count) |")
$md.Add("| only entity | $($onlyEnt.Count) |")
$md.Add("| only DDL | $($onlyDdl.Count) |")
$unionCount = $both.Count + $onlyEnt.Count + $onlyDdl.Count
$md.Add("| " + [char]0x4E1A + [char]0x52A1 + [char]0x8868 + [char]0x5E76 + [char]0x96C6 + " (union) | $unionCount |")  # 业务表并集
$md.Add("| " + [char]0x7591 + [char]0x4F3C + [char]0x5907 + [char]0x4EFD + [char]0x8868 + " (backup) | $($backup.Count) |")  # 疑似备份表
$md.Add("")

$md.Add("## only entity (" + [char]0x4EC5 + [char]0x5B9E + [char]0x4F53 + [char]0x6709 + [char]0xFF0C + [char]0x65E0 + " DDL)")
$md.Add("")
foreach ($k in ($onlyEnt | Sort-Object)) { $md.Add("- $k  <- $($entMap[$k].entityClass) ($($entMap[$k].file):$($entMap[$k].line))") }
$md.Add("")

$md.Add("## only DDL (" + [char]0x4EC5 + " DDL " + [char]0x6709 + [char]0xFF0C + [char]0x65E0 + [char]0x5B9E + [char]0x4F53 + ")")
$md.Add("")
foreach ($k in ($onlyDdl | Sort-Object)) { $md.Add("- $k  ($($ddlMap[$k].file):$($ddlMap[$k].line), v$($ddlMap[$k].version), $($ddlMap[$k].columns) cols)") }
$md.Add("")

# 疑似备份表 [需要人工复核]
$TAG_REVIEW = "[" + [char]0x9700 + [char]0x8981 + [char]0x4EBA + [char]0x5DE5 + [char]0x590D + [char]0x6838 + "]"  # [需要人工复核]
$md.Add("## " + [char]0x7591 + [char]0x4F3C + [char]0x5907 + [char]0x4EFD + [char]0x8868 + " " + $TAG_REVIEW)  # 疑似备份表 [需要人工复核]
$md.Add("")
# 复核提示（中文，[char] 拼装以兼容 PS5.1 编码）
$note = "> " + $TAG_REVIEW + [char]0xFF1A + [char]0x4E0B + [char]0x5217 + [char]0x8868 + [char]0x7531 + [char]0x547D + [char]0x540D + [char]0x542F + [char]0x53D1 + [char]0x5F0F + [char]0x8BC6 + [char]0x522B + [char]0xFF08 + [char]0x9ED8 + [char]0x8BA4 + " _bk/_bak/_tmp/_temp/_backup" + [char]0xFF09 + [char]0xFF0C + [char]0x9ED8 + [char]0x8BA4 + [char]0x4E0D + [char]0x8BA1 + [char]0x5165 + [char]0x4E1A + [char]0x52A1 + [char]0x8868 + [char]0x5E76 + [char]0x96C6 + [char]0xFF1B + [char]0x53EF + [char]0x80FD + [char]0x8BEF + [char]0x5224 + [char]0xFF08 + [char]0x771F + [char]0x4E1A + [char]0x52A1 + [char]0x8868 + [char]0x6070 + [char]0x4EE5 + [char]0x6B64 + [char]0x7ED3 + [char]0x5C3E + [char]0xFF09 + [char]0x6216 + [char]0x6F0F + [char]0x5224 + [char]0xFF08 + [char]0x5982 + " _old/_his/" + [char]0x65E5 + [char]0x671F + [char]0x540E + [char]0x7F00 + [char]0xFF09 + [char]0xFF0C + [char]0x8BF7 + [char]0x4EBA + [char]0x5DE5 + [char]0x590D + [char]0x6838 + [char]0xFF1B + [char]0x9700 + [char]0x8C03 + [char]0x6574 + [char]0x89C4 + [char]0x5219 + [char]0x53EF + [char]0x4F20 + " -BackupPattern / -NoBackupFilter" + [char]0x3002
$md.Add($note)
$md.Add("")
foreach ($k in ($backup | Sort-Object)) { $md.Add("- $k  $TAG_REVIEW") }
$md.Add("")

$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "reconcile-report.md"), ($md -join $nl), $utf8BOM)

Write-Host "both=$($both.Count) onlyEntity=$($onlyEnt.Count) onlyDDL=$($onlyDdl.Count) backup=$($backup.Count) union=$($both.Count + $onlyEnt.Count + $onlyDdl.Count)"
