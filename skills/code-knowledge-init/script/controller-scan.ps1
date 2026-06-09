# controller-scan.ps1
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$OutputDir
)

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

# --- Phase 0: Build constant mapping table ---
# Scan all .java files for String constant definitions like:
#   public static final String XXX = "/api/path";
#   String XXX = "/api/path";
# Build a lookup: "ClassName.FIELD" -> "value"
$constMap = @{}
Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\src\\test\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $cLines = Get-Content $_.FullName -Encoding UTF8
  $cClassName = ""
  foreach ($cl in $cLines) {
    if ($cl -match '^\\s*public\\s+(abstract\\s+)?(class|interface|enum)\\s+(\\w+)') { $cClassName = $Matches[3] }
    if ($cl -match '^\\s*(public\\s+)?(static\\s+)?(final\\s+)?String\\s+(\\w+)\\s*=\\s*"([^"]*)"') {
      $fieldName = $Matches[4]; $fieldValue = $Matches[5]
      if ($cClassName) { $constMap["$cClassName.$fieldName"] = $fieldValue }
      $constMap[$fieldName] = $fieldValue
    }
  }
}

# Helper: resolve a @RequestMapping value (string literal or constant reference)
function Resolve-MappingPath {
  param([string]$annotationLine)
  # Try string literal first
  $m = [regex]::Match($annotationLine, '(?:value\\s*=\\s*|path\\s*=\\s*)?["'']([^"'']+)["'']')
  if ($m.Success) { return $m.Groups[1].Value }
  # Try constant reference: @RequestMapping(ConstClass.FIELD) or @RequestMapping(FIELD)
  $cm = [regex]::Match($annotationLine, '@\\w+Mapping\\s*\\(\\s*(?:value\\s*=\\s*|path\\s*=\\s*)?(\\w+(?:\\.\\w+)?)\\s*[,)]')
  if (-not $cm.Success) {
    $cm = [regex]::Match($annotationLine, '@RequestMapping\\s*\\(\\s*(?:value\\s*=\\s*|path\\s*=\\s*)?(\\w+(?:\\.\\w+)?)\\s*[,)]')
  }
  if ($cm.Success) {
    $ref = $cm.Groups[1].Value
    if ($constMap.ContainsKey($ref)) { return $constMap[$ref] }
    # Return marker for LLM to resolve
    return "[CONST:$ref]"
  }
  return ""
}

$mdLines = [System.Collections.Generic.List[string]]::new()
$controllerCount = 0
$totalInterfaceCount = 0

$tblHdr = "| $([char]0x65B9)$([char]0x6CD5) | URL | $([char]0x8BF4)$([char]0x660E) |"
$tblSep = "|------|-----|------|"

Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\src\\test\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $lines = Get-Content $_.FullName -Encoding UTF8
  if (-not ($lines | Select-String "@(RestController|Controller)\\b")) { return }
  if ($lines | Select-String "@ControllerAdvice") { return }
  if ($lines | Select-String "@SpringBootApplication") { return }

  $fileName = $_.Name
  $pkg = ($lines | Select-String "^package " | Select-Object -First 1).Line -replace 'package\\s+', '' -replace ';', ''

  # Resolve class-level path (supports constants)
  # Class-level @RequestMapping is the one within 5 lines above the class declaration
  $classDecl = ($lines | Select-String '^\\s*public\\s+(abstract\\s+)?class\\s+' | Select-Object -First 1)
  $classLineNum = if ($classDecl) { $classDecl.LineNumber } else { 0 }
  $classLevelRMLine = -1
  $clsMap = $null
  # Search for @RequestMapping within 5 lines above class declaration
  if ($classLineNum -gt 0) {
    for ($ci = $classLineNum - 1; $ci -ge [Math]::Max(1, $classLineNum - 5); $ci--) {
      $cLine = $lines[$ci - 1].Trim()  # LineNumber is 1-based, array is 0-based
      if ($cLine -match '@RequestMapping') {
        $clsMap = $cLine
        $classLevelRMLine = $ci  # 1-based line number
        break
      }
    }
  }
  $classPath = if ($clsMap) { Resolve-MappingPath $clsMap } else { "" }

  $moduleName = "root"
  if ($pkg -match 'controller\\.(\\w+)') { $moduleName = $Matches[1] }

  $rows = [System.Collections.Generic.List[string]]::new()

  # Scan line by line, track annotation block per method
  $pendingApiDesc = ""
  for ($li = 0; $li -lt $lines.Count; $li++) {
    $cl = $lines[$li].Trim()

    # Collect @ApiOperation (Swagger 2.x) or @Operation (Swagger 3.x / springdoc) from annotation block
    if ($cl -match '@(ApiOperation|Operation)') {
      $dm = [regex]::Match($cl, '(?:value\\s*=\\s*|summary\\s*=\\s*)?["'']([^"'']+)["'']')
      if ($dm.Success) { $pendingApiDesc = $dm.Groups[1].Value }
      continue
    }

    # Check for mapping annotation
    if ($cl -match '@(GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping|RequestMapping)') {
      # Skip class-level @RequestMapping (identified by proximity to class declaration)
      if ($cl -match '@RequestMapping' -and $classLevelRMLine -gt 0 -and ($li + 1) -eq $classLevelRMLine) {
        $pendingApiDesc = ""
        continue
      }

      $method = "GET"
      if ($cl -match '@GetMapping') { $method = "GET" }
      elseif ($cl -match '@PostMapping') { $method = "POST" }
      elseif ($cl -match '@PutMapping') { $method = "PUT" }
      elseif ($cl -match '@DeleteMapping') { $method = "DELETE" }
      elseif ($cl -match '@PatchMapping') { $method = "PATCH" }
      elseif ($cl -match '@RequestMapping') {
        # Support method={RequestMethod.POST, RequestMethod.GET} and method=RequestMethod.GET
        $methodMatches = [regex]::Matches($cl, 'RequestMethod\\.(\\w+)')
        if ($methodMatches.Count -gt 0) {
          $methods = @()
          foreach ($mm in $methodMatches) { $methods += $mm.Groups[1].Value }
          $method = ($methods | Sort-Object) -join "/"
        }
        else {
          # No method declared: infer from context
          # Look ahead for @RequestBody in method signature -> POST
          $hasRequestBody = $false
          for ($bodyCheck = $li + 1; $bodyCheck -le [Math]::Min($li + 5, $lines.Count - 1); $bodyCheck++) {
            $bodyLine = $lines[$bodyCheck].Trim()
            if ($bodyLine -match '@RequestBody') { $hasRequestBody = $true; break }
            if ($bodyLine -match '^\\s*(public|private|protected)\\s+' -and $bodyLine -notmatch '^\\s*@') { break }
          }
          if ($hasRequestBody) {
            $method = "POST"
          }
          else {
            # Infer from method name prefix
            $methodNameLine = ""
            for ($mnCheck = $li + 1; $mnCheck -le [Math]::Min($li + 5, $lines.Count - 1); $mnCheck++) {
              $mnLine = $lines[$mnCheck].Trim()
              if ($mnLine -match '^\\s*(public|private|protected)\\s+\\S+\\s+(\\w+)\\s*\\(') {
                $methodNameLine = $Matches[2]
                break
              }
            }
            if ($methodNameLine -match '^(delete|remove)') { $method = "DELETE" }
            elseif ($methodNameLine -match '^(update|modify|edit)') { $method = "PUT" }
            elseif ($methodNameLine -match '^(patch)') { $method = "PATCH" }
            else { $method = "GET" }
          }
        }
      }

      $mPath = Resolve-MappingPath $cl

      $url = ($classPath.TrimEnd('/') + '/' + $mPath.TrimStart('/')).TrimEnd('/')
      if (-not $url) { $url = $classPath }

      # If no pending desc, look ahead 1-2 lines for @ApiOperation/@Operation below mapping
      if (-not $pendingApiDesc) {
        for ($ahead = $li + 1; $ahead -le [Math]::Min($li + 2, $lines.Count - 1); $ahead++) {
          $nextLine = $lines[$ahead].Trim()
          if ($nextLine -match '@(ApiOperation|Operation)') {
            $dm2 = [regex]::Match($nextLine, '(?:value\\s*=\\s*|summary\\s*=\\s*)?["'']([^"'']+)["'']')
            if ($dm2.Success) { $pendingApiDesc = $dm2.Groups[1].Value }
            break
          }
          if ($nextLine -notmatch '^\\s*@' -and $nextLine -ne '') { break }
        }
      }

      $rows.Add("| $method | $url | $pendingApiDesc |")
      $totalInterfaceCount++
      $pendingApiDesc = ""
      continue
    }

    # Non-annotation line (method signature, blank line, etc.) -> reset pending desc
    if ($cl -notmatch '^\\s*@' -and $cl -ne '') {
      $pendingApiDesc = ""
    }
  }

  if ($rows.Count -eq 0) { return }

  $ctrlName = $fileName -replace '\\.java$', ''
  $mdLines.Add("### $ctrlName ($moduleName)")
  $mdLines.Add("")
  $mdLines.Add($tblHdr)
  $mdLines.Add($tblSep)
  foreach ($r in $rows) { $mdLines.Add($r) }
  $mdLines.Add("")
  $controllerCount++
}

$header = "> Controller: $controllerCount, Interface: $totalInterfaceCount"
$body = $header + [Environment]::NewLine + [Environment]::NewLine + ($mdLines -join [Environment]::NewLine)
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "controller-scan-result.md"), $body, $utf8BOM)

Write-Host "Controller: $controllerCount, Interface: $totalInterfaceCount"