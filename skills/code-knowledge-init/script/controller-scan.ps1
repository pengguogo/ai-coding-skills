# controller-scan.ps1
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$OutputDir
)

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$SourceRootFull = (Resolve-Path -LiteralPath $SourceRoot).Path

# --- Phase 0: Build constant mapping table ---
# Scan all .java files for String constant definitions like:
#   public static final String XXX = "/api/path";
#   String XXX = "/api/path";
# Build a lookup: "ClassName.FIELD" -> "value"
$constMap = @{}
Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\target\*" -and $_.FullName -notlike "*\src\test\*" -and $_.FullName -notlike "*\.git\*"
} | ForEach-Object {
  $cLines = Get-Content $_.FullName -Encoding UTF8
  $cClassName = ""
  foreach ($cl in $cLines) {
    if ($cl -match '^\s*public\s+(abstract\s+)?(class|interface|enum)\s+(\w+)') { $cClassName = $Matches[3] }
    if ($cl -match '^\s*(public\s+)?(static\s+)?(final\s+)?String\s+(\w+)\s*=\s*"([^"]*)"') {
      $fieldName = $Matches[4]; $fieldValue = $Matches[5]
      if ($cClassName) { $constMap["$cClassName.$fieldName"] = $fieldValue }
      $constMap[$fieldName] = $fieldValue
    }
  }
}

# Read a complete annotation, including annotations split across multiple lines.
function Read-AnnotationBlock {
  param([string[]]$Lines, [int]$StartIndex)

  $parts = [System.Collections.Generic.List[string]]::new()
  $depth = 0
  $hasParentheses = $false
  $endIndex = $StartIndex

  for ($i = $StartIndex; $i -lt $Lines.Count; $i++) {
    $line = $Lines[$i].Trim()
    $parts.Add($line)
    $openCount = ([regex]::Matches($line, '\(')).Count
    $closeCount = ([regex]::Matches($line, '\)')).Count
    if ($openCount -gt 0) { $hasParentheses = $true }
    $depth += $openCount - $closeCount
    $endIndex = $i
    if (-not $hasParentheses -or $depth -le 0) { break }
  }

  return [PSCustomObject]@{
    Text = ($parts -join ' ')
    EndIndex = $endIndex
  }
}

function Resolve-MappingPaths {
  param([string]$AnnotationText)

  $annotationMatch = [regex]::Match($AnnotationText, '(?is)@\w+Mapping\s*(?:\((.*)\))?')
  if (-not $annotationMatch.Success -or -not $annotationMatch.Groups[1].Success) { return @('') }

  $arguments = $annotationMatch.Groups[1].Value.Trim()
  if (-not $arguments) { return @('') }

  # Prefer path/value named arguments. Otherwise use only the first positional argument,
  # so strings from produces/consumes are never mistaken for URL paths.
  $namedPath = [regex]::Match($arguments, '(?is)(?:^|,)\s*(?:value|path)\s*=\s*(\{(?:[^{}"]|"(?:\\.|[^"])*"|\{[^{}]*\})*\}|"(?:\\.|[^"])*"|[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)')
  if ($namedPath.Success) {
    $candidate = $namedPath.Groups[1].Value
  }
  elseif ($arguments -match '^(?:method|params|headers|consumes|produces|name)\s*=') {
    return @('')
  }
  else {
    $positionalPath = [regex]::Match($arguments, '(?is)^\s*(\{(?:[^{}"]|"(?:\\.|[^"])*"|\{[^{}]*\})*\}|"(?:\\.|[^"])*"|[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)')
    if (-not $positionalPath.Success) { return @('') }
    $candidate = $positionalPath.Groups[1].Value
  }

  $paths = [System.Collections.Generic.List[string]]::new()
  $literalMatches = [regex]::Matches($candidate, '["'']([^"'']*)["'']')
  foreach ($literal in $literalMatches) {
    $paths.Add($literal.Groups[1].Value)
  }

  if ($paths.Count -eq 0) {
    $constantExpression = $candidate.Trim().TrimStart('{').TrimEnd('}')
    foreach ($piece in ($constantExpression -split ',')) {
      $reference = $piece.Trim()
      if ($reference -match '^[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)?$') {
        if ($constMap.ContainsKey($reference)) { $paths.Add($constMap[$reference]) }
        else { $paths.Add("[CONST:$reference]") }
      }
    }
  }

  if ($paths.Count -eq 0) { return @('') }
  return $paths.ToArray()
}

function Normalize-MappingPath {
  param([string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
  $normalized = $Path.Trim() -replace '\\', '/'
  if ($normalized -eq '/') { return '/' }
  return '/' + (($normalized.Trim('/') -replace '/+', '/'))
}

# Join class-level and method-level mappings while removing duplicated prefixes or
# overlapping path segments (for example /v1/policy + /policy/{id}).
function Join-MappingPath {
  param([string]$BasePath, [string]$MethodPath)

  $base = Normalize-MappingPath $BasePath
  $child = Normalize-MappingPath $MethodPath
  if ($base -eq '/') { $base = '' }
  if ($child -eq '/') { $child = '' }
  if (-not $base -and -not $child) { return '/' }
  if (-not $base) { return $child }
  if (-not $child) { return $base }
  if ($child -eq $base -or $child.StartsWith("$base/")) { return $child }

  $baseParts = @($base.Trim('/') -split '/')
  $childParts = @($child.Trim('/') -split '/')
  $maxOverlap = [Math]::Min($baseParts.Count, $childParts.Count)
  $overlap = 0
  for ($size = $maxOverlap; $size -ge 1; $size--) {
    $matched = $true
    for ($part = 0; $part -lt $size; $part++) {
      if ($baseParts[$baseParts.Count - $size + $part] -cne $childParts[$part]) {
        $matched = $false
        break
      }
    }
    if ($matched) {
      $overlap = $size
      break
    }
  }

  $combined = [System.Collections.Generic.List[string]]::new()
  foreach ($part in $baseParts) { $combined.Add($part) }
  for ($part = $overlap; $part -lt $childParts.Count; $part++) { $combined.Add($childParts[$part]) }
  return '/' + ($combined -join '/')
}

function Get-TypeDeclaration {
  param([string[]]$Lines)

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -notmatch '^\s*(?:(?:public|protected|private|abstract|final|static|sealed|non-sealed)\s+)*(class|interface)\s+(\w+)') { continue }
    $kind = $Matches[1]
    $name = $Matches[2]
    $parts = [System.Collections.Generic.List[string]]::new()
    $endIndex = $i
    for ($j = $i; $j -lt [Math]::Min($i + 20, $Lines.Count); $j++) {
      $parts.Add($Lines[$j].Trim())
      $endIndex = $j
      if ($Lines[$j] -match '\{') { break }
    }
    return [PSCustomObject]@{
      Kind = $kind
      Name = $name
      StartIndex = $i
      EndIndex = $endIndex
      Text = ($parts -join ' ')
    }
  }
  return $null
}

function Get-ClassMappingPaths {
  param([string[]]$Lines, [int]$DeclarationIndex)

  $lastMapping = $null
  for ($i = 0; $i -lt $DeclarationIndex; $i++) {
    if ($Lines[$i].Trim() -notmatch '@RequestMapping\b') { continue }
    $lastMapping = Read-AnnotationBlock -Lines $Lines -StartIndex $i
    $i = $lastMapping.EndIndex
  }
  if ($null -eq $lastMapping) { return @('') }
  return @(Resolve-MappingPaths $lastMapping.Text)
}

function Resolve-ApiDescription {
  param([string]$AnnotationText)

  $description = [regex]::Match($AnnotationText, '(?is)(?:value|summary)\s*=\s*["'']([^"'']+)["'']')
  if (-not $description.Success) {
    $description = [regex]::Match($AnnotationText, '(?is)@(ApiOperation|Operation)\s*\(\s*["'']([^"'']+)["'']')
    if ($description.Success) { return $description.Groups[2].Value }
  }
  if ($description.Success) { return $description.Groups[1].Value }
  return ''
}

function Get-FollowingMethodInfo {
  param([string[]]$Lines, [int]$StartIndex)

  $signature = [System.Collections.Generic.List[string]]::new()
  $description = ''
  $endIndex = $StartIndex
  for ($i = $StartIndex; $i -lt [Math]::Min($StartIndex + 30, $Lines.Count); $i++) {
    $line = $Lines[$i].Trim()
    $endIndex = $i
    if (-not $line -or $line -match '^\s*(//|/\*|\*|\*/)') { continue }
    if ($line -match '^@') {
      $annotation = Read-AnnotationBlock -Lines $Lines -StartIndex $i
      if ($annotation.Text -match '@(ApiOperation|Operation)\b') {
        $candidateDescription = Resolve-ApiDescription $annotation.Text
        if ($candidateDescription) { $description = $candidateDescription }
      }
      $i = $annotation.EndIndex
      $endIndex = $i
      continue
    }

    $signature.Add($line)
    if ($line -match '[;{]') { break }
  }

  $signatureText = $signature -join ' '
  $methodNameMatch = [regex]::Match($signatureText, '\b([A-Za-z_]\w*)\s*\(')
  return [PSCustomObject]@{
    Name = $(if ($methodNameMatch.Success) { $methodNameMatch.Groups[1].Value } else { '' })
    SignatureText = $signatureText
    Description = $description
    EndIndex = $endIndex
  }
}

function Resolve-MappingHttpMethod {
  param([string]$AnnotationText, [PSCustomObject]$MethodInfo)

  if ($AnnotationText -match '@GetMapping\b') { return 'GET' }
  if ($AnnotationText -match '@PostMapping\b') { return 'POST' }
  if ($AnnotationText -match '@PutMapping\b') { return 'PUT' }
  if ($AnnotationText -match '@DeleteMapping\b') { return 'DELETE' }
  if ($AnnotationText -match '@PatchMapping\b') { return 'PATCH' }

  $methodMatches = [regex]::Matches($AnnotationText, 'RequestMethod\.(\w+)')
  if ($methodMatches.Count -gt 0) {
    $methods = @($methodMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    return $methods -join '/'
  }
  if ($MethodInfo.SignatureText -match '@RequestBody') { return 'POST' }
  if ($MethodInfo.Name -match '^(delete|remove)') { return 'DELETE' }
  if ($MethodInfo.Name -match '^(update|modify|edit)') { return 'PUT' }
  if ($MethodInfo.Name -match '^patch') { return 'PATCH' }
  return 'GET'
}

function Get-TypeEndpoints {
  param([string[]]$Lines, [string[]]$ClassPaths)

  $declaration = Get-TypeDeclaration $Lines
  if ($null -eq $declaration) { return @() }
  if (-not $ClassPaths -or $ClassPaths.Count -eq 0) { $ClassPaths = @('') }

  $endpoints = [System.Collections.Generic.List[object]]::new()
  $pendingDescription = ''
  for ($i = $declaration.EndIndex + 1; $i -lt $Lines.Count; $i++) {
    $line = $Lines[$i].Trim()
    if ($line -match '@(ApiOperation|Operation)\b') {
      $annotation = Read-AnnotationBlock -Lines $Lines -StartIndex $i
      $pendingDescription = Resolve-ApiDescription $annotation.Text
      $i = $annotation.EndIndex
      continue
    }
    if ($line -notmatch '@(GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping|RequestMapping)\b') {
      if ($line -and $line -notmatch '^@') { $pendingDescription = '' }
      continue
    }

    $mapping = Read-AnnotationBlock -Lines $Lines -StartIndex $i
    $methodInfo = Get-FollowingMethodInfo -Lines $Lines -StartIndex ($mapping.EndIndex + 1)
    $description = if ($pendingDescription) { $pendingDescription } else { $methodInfo.Description }
    $httpMethod = Resolve-MappingHttpMethod -AnnotationText $mapping.Text -MethodInfo $methodInfo
    $methodPaths = @(Resolve-MappingPaths $mapping.Text)
    if ($methodPaths.Count -eq 0) { $methodPaths = @('') }

    foreach ($classPath in $ClassPaths) {
      foreach ($methodPath in $methodPaths) {
        $endpoints.Add([PSCustomObject]@{
          HttpMethod = $httpMethod
          Path = (Join-MappingPath -BasePath $classPath -MethodPath $methodPath)
          MappingPath = $methodPath
          Description = $description
          MethodName = $methodInfo.Name
        })
      }
    }
    $pendingDescription = ''
    $i = [Math]::Max($mapping.EndIndex, $methodInfo.EndIndex)
  }
  return $endpoints.ToArray()
}

function Get-ImplementedInterfaceNames {
  param([string]$DeclarationText)

  $implemented = [regex]::Match($DeclarationText, '(?is)\bimplements\s+([^\{]+)')
  if (-not $implemented.Success) { return @() }
  $names = [System.Collections.Generic.List[string]]::new()
  foreach ($item in ($implemented.Groups[1].Value -split ',')) {
    $name = ($item -replace '<.*?>', '').Trim()
    if ($name) { $names.Add($name) }
  }
  return $names.ToArray()
}

$mdLines = [System.Collections.Generic.List[string]]::new()
$provenance = [System.Collections.Generic.List[string]]::new()
$controllerCount = 0
$totalInterfaceCount = 0

$tblHdr = "| $([char]0x65B9)$([char]0x6CD5) | URL | $([char]0x8BF4)$([char]0x660E) |"
$tblSep = "|------|-----|------|"

$javaFiles = @(Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\target\*" -and $_.FullName -notlike "*\src\test\*" -and $_.FullName -notlike "*\.git\*"
})

# Index interface declarations once so Controller implementations can inherit
# class-level and method-level mapping annotations from their contracts.
$interfaceIndex = @{}
foreach ($javaFile in $javaFiles) {
  $interfaceLines = @(Get-Content $javaFile.FullName -Encoding UTF8)
  $interfaceDeclaration = Get-TypeDeclaration $interfaceLines
  if ($null -eq $interfaceDeclaration -or $interfaceDeclaration.Kind -ne 'interface') { continue }
  $interfacePaths = @(Get-ClassMappingPaths -Lines $interfaceLines -DeclarationIndex $interfaceDeclaration.StartIndex)
  $interfaceIndex[$interfaceDeclaration.Name] = [PSCustomObject]@{
    ClassPaths = $interfacePaths
    Endpoints = @(Get-TypeEndpoints -Lines $interfaceLines -ClassPaths @(''))
  }
}

foreach ($javaFile in $javaFiles) {
  $lines = @(Get-Content $javaFile.FullName -Encoding UTF8)
  if (-not ($lines | Select-String "@(RestController|Controller)\b")) { continue }
  if ($lines | Select-String "@ControllerAdvice") { continue }
  if ($lines | Select-String "@SpringBootApplication") { continue }

  $declaration = Get-TypeDeclaration $lines
  if ($null -eq $declaration -or $declaration.Kind -ne 'class') { continue }

  $fileName = $javaFile.Name
  $pkgMatch = $lines | Select-String "^package " | Select-Object -First 1
  $pkg = if ($pkgMatch) { $pkgMatch.Line -replace 'package\s+', '' -replace ';', '' } else { '' }
  $classPaths = @(Get-ClassMappingPaths -Lines $lines -DeclarationIndex $declaration.StartIndex)
  $controllerEndpoints = @(Get-TypeEndpoints -Lines $lines -ClassPaths $classPaths)

  $moduleName = "root"
  if ($pkg -match 'controller\.(\w+)') { $moduleName = $Matches[1] }

  $endpointMap = @{}
  foreach ($endpoint in $controllerEndpoints) {
    $key = "$($endpoint.HttpMethod)|$($endpoint.Path)|$($endpoint.MethodName)"
    $endpointMap[$key] = $endpoint
  }

  foreach ($interfaceName in @(Get-ImplementedInterfaceNames $declaration.Text)) {
    if (-not $interfaceIndex.ContainsKey($interfaceName)) { continue }
    $interfaceContract = $interfaceIndex[$interfaceName]
    foreach ($interfaceEndpoint in $interfaceContract.Endpoints) {
      # If the implementation repeats a mapping for the same Java method, its
      # concrete annotation wins and the inherited contract is not duplicated.
      $implementationForMethod = @($controllerEndpoints | Where-Object { $_.MethodName -eq $interfaceEndpoint.MethodName })
      if ($implementationForMethod.Count -gt 0) { continue }

      foreach ($controllerPath in $classPaths) {
        foreach ($interfacePath in $interfaceContract.ClassPaths) {
          $basePath = Join-MappingPath -BasePath $controllerPath -MethodPath $interfacePath
          $inheritedPath = Join-MappingPath -BasePath $basePath -MethodPath $interfaceEndpoint.MappingPath
          $inheritedEndpoint = [PSCustomObject]@{
            HttpMethod = $interfaceEndpoint.HttpMethod
            Path = $inheritedPath
            MappingPath = $interfaceEndpoint.MappingPath
            Description = $interfaceEndpoint.Description
            MethodName = $interfaceEndpoint.MethodName
          }
          $key = "$($inheritedEndpoint.HttpMethod)|$($inheritedEndpoint.Path)|$($inheritedEndpoint.MethodName)"
          $endpointMap[$key] = $inheritedEndpoint
        }
      }
    }
  }

  $endpoints = @($endpointMap.Values | Sort-Object Path, HttpMethod, MethodName)
  if ($endpoints.Count -eq 0) { continue }

  $ctrlName = $fileName -replace '\.java$', ''
  $srcRel = $javaFile.FullName
  if ($srcRel.StartsWith($SourceRootFull)) { $srcRel = $srcRel.Substring($SourceRootFull.Length).TrimStart('\','/') }
  $srcRel = $srcRel -replace '\\','/'
  $provenance.Add(("{0}`t{1}`t{2}`t{3}" -f $ctrlName, $moduleName, $srcRel, $endpoints.Count))
  $mdLines.Add("### $ctrlName ($moduleName)")
  $mdLines.Add("")
  $mdLines.Add($tblHdr)
  $mdLines.Add($tblSep)
  foreach ($endpoint in $endpoints) {
    $mdLines.Add("| $($endpoint.HttpMethod) | $($endpoint.Path) | $($endpoint.Description) |")
    $totalInterfaceCount++
  }
  $mdLines.Add("")
  $controllerCount++
}

$header = "> Controller: $controllerCount, Interface: $totalInterfaceCount"
$body = $header + [Environment]::NewLine + [Environment]::NewLine + ($mdLines -join [Environment]::NewLine)
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutputDir "controller-scan-result.md"), $body, $utf8BOM)

# Sidecar provenance (ClassName<TAB>Module<TAB>SourceRelPath<TAB>InterfaceCount), one line per Controller block.
# Used by downstream splitting to route same-named cross-module controllers by real source path.
$provHeader = "class`tmodule`tsource`tinterfaces"
$provBody = $provHeader + [Environment]::NewLine + ($provenance -join [Environment]::NewLine)
[System.IO.File]::WriteAllText((Join-Path $OutputDir "controller-scan-provenance.tsv"), $provBody, $utf8BOM)

Write-Host "Controller: $controllerCount, Interface: $totalInterfaceCount"
