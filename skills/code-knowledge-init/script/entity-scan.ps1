# entity-scan.ps1
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

$mdLines = [System.Collections.Generic.List[string]]::new()
$entityCount = 0
$totalFieldCount = 0
# PS 5.1 safe: build Chinese strings via [char] to avoid encoding issues
$TAG_TODO = "[" + [char]0x9700 + [char]0x4EBA + [char]0x5DE5 + [char]0x786E + [char]0x8BA4 + "]"  # [需人工确认]

Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\src\\test\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $content = Get-Content $_.FullName -Raw -Encoding UTF8
  if ($content -notmatch '@(TableName|Entity|Table)\\b') { return }
  $lines = Get-Content $_.FullName -Encoding UTF8

  $classLine = ($lines | Select-String '^\\s*public\\s+(abstract\\s+)?class\\s+(\\w+)' | Select-Object -First 1)
  if (-not $classLine) { return }
  $className = $classLine.Matches[0].Groups[2].Value

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

  $tnMatch = [regex]::Match($content, '@TableName\\s*\\(\\s*"([^"]+)"')
  if (-not $tnMatch.Success) { $tnMatch = [regex]::Match($content, '@Table\\s*\\(\\s*name\\s*=\\s*"([^"]+)"') }
  $tableName = if ($tnMatch.Success) { $tnMatch.Groups[1].Value } else { CamelToSnake $className }

  $extMatch = [regex]::Match(($lines[$idx]), 'extends\\s+(\\w+)')
  $extNote = if ($extMatch.Success) { "> extends \`\`$($extMatch.Groups[1].Value)\`\`" } else { "" }
  $tDesc = if ($classComment) { $classComment } else { $TAG_TODO }

  $fieldRows = [System.Collections.Generic.List[string]]::new()
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\\s*(private|protected|public)\\s+' -and $line -notmatch '\\bclass\\s' -and $line -match ';\\s*$' -and $line -notmatch '\\bstatic\\b') {
      $fl = ($line.Trim() -replace ';.*', '' -replace '\\s*=\\s*.*', '').Trim()
      $st = $fl -replace '^\\s*(private|protected|public)\\s+', '' -replace '\\b(final|volatile|transient)\\s+', ''
      $ps = $st -split '\\s+'
      if ($ps.Count -lt 2) { continue }
      $fName = $ps[-1]; $fType = ($ps[0..($ps.Count-2)] -join ' ').Trim()

      $fComment = ""; $ignored = $false; $required = $false; $colName = CamelToSnake $fName
      for ($j = $i - 1; $j -ge 0; $j--) {
        $p = $lines[$j].Trim()
        if ($p -match '^@') {
          if ($p -match '@TableField\\s*\\(.*exist\\s*=\\s*false' -or $p -match '@Transient') { $ignored = $true }
          if ($p -match '@Column\\s*\\(.*nullable\\s*=\\s*false') { $required = $true }
          $m1 = [regex]::Match($p, '@TableField\\s*\\(\\s*"([^"]+)"'); if ($m1.Success) { $colName = $m1.Groups[1].Value }
          $m2 = [regex]::Match($p, '@Column\\s*\\(.*name\\s*=\\s*"([^"]+)"'); if ($m2.Success) { $colName = $m2.Groups[1].Value }
        } elseif ($p -match '^\\*/' -or $p -match '^\\*' -or $p -match '^/\\*\\*' -or $p -match '^//') { $fComment = $p + " " + $fComment }
        else { break }
      }
      if ($ignored) { continue }
      $fComment = Clean-Comment $fComment
      if (-not $fComment) { $fComment = $TAG_TODO }
      $req = if ($required) { [char]0x662F } else { [char]0x5426 }  # char literal for PS 5.1

      $fieldRows.Add("| $colName | $fType | $req | - | $fComment |")
      $totalFieldCount++
    }
  }

  # Chinese table header via [char] for PS 5.1 compat
  $hdr = "| $([char]0x5B57)$([char]0x6BB5)$([char]0x540D) | $([char]0x7C7B)$([char]0x578B) | $([char]0x5FC5)$([char]0x586B) | $([char]0x9ED8)$([char]0x8BA4)$([char]0x503C) | $([char]0x8BF4)$([char]0x660E) |"
  $sep = "|--------|------|------|--------|------|"

  $mdLines.Add("### $tableName ($className)")
  $mdLines.Add("")
  $mdLines.Add("> $tDesc")
  if ($extNote) { $mdLines.Add($extNote) }
  $mdLines.Add("")
  $mdLines.Add($hdr)
  $mdLines.Add($sep)
  foreach ($r in $fieldRows) { $mdLines.Add($r) }
  $mdLines.Add("")
  $entityCount++
}

# Output with UTF-8 BOM via .NET API (PS 5.1 safe)
$header = "> Entity: $entityCount, Fields: $totalFieldCount"
$body = $header + [Environment]::NewLine + [Environment]::NewLine + ($mdLines -join [Environment]::NewLine)
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "entity-scan-result.md"), $body, $utf8BOM)

Write-Host "Entity: $entityCount, Fields: $totalFieldCount"