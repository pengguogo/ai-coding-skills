# dubbo-scan.ps1 — 通用 Dubbo RPC 接口扫描
# 识别规则（优先级从高到低）：
#   a) XML <dubbo:service>/<dubbo:reference>
#   b) @DubboService/@DubboReference + dubbo.scan.base-packages
#   c) 反向 implements 跨模块 + Dubbo 依赖传播
#   d) Maven 依赖图（被 Dubbo 模块依赖的非 common 模块）
#   e) 模块名白名单兜底（*-api/*-interface/*-facade/*-client）
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$OutputDir
)
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$mdLines = [System.Collections.Generic.List[string]]::new()
$serviceCount = 0; $referenceCount = 0
$knownIfaces = @{}
$xmlServices = [System.Collections.Generic.List[object]]::new()
$xmlReferences = [System.Collections.Generic.List[object]]::new()
$annoServices = [System.Collections.Generic.List[object]]::new()
$dubboScanPkgs = [System.Collections.Generic.List[string]]::new()

# === Phase 1: XML ===
Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.xml" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $xc = Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
  if (-not $xc) { return }
  $rp = $_.FullName.Replace("$((Get-Location).Path)\\$SourceRoot\\", "").Replace('\\', '/')
  foreach ($sm in [regex]::Matches($xc, '<dubbo:service\\s+([^>]+)>')) {
    $a = $sm.Groups[1].Value; $id=""; $if=""; $rf=""; $to=""
    if ($a -match 'id\\s*=\\s*"([^"]+)"') { $id=$Matches[1] }
    if ($a -match 'interface\\s*=\\s*"([^"]+)"') { $if=$Matches[1] }
    if ($a -match 'ref\\s*=\\s*"([^"]+)"') { $rf=$Matches[1] }
    if ($a -match 'timeout\\s*=\\s*"([^"]+)"') { $to=$Matches[1] }
    if ($if) { $xmlServices.Add(@{id=$id;interface=$if;ref=$rf;timeout=$to;source=$rp}); $knownIfaces[$if]="xml-service"; $serviceCount++ }
  }
  foreach ($rm in [regex]::Matches($xc, '<dubbo:reference\\s+([^>]+)/?\\s*>')) {
    $a = $rm.Groups[1].Value; $id=""; $if=""
    if ($a -match 'id\\s*=\\s*"([^"]+)"') { $id=$Matches[1] }
    if ($a -match 'interface\\s*=\\s*"([^"]+)"') { $if=$Matches[1] }
    if ($if) { $xmlReferences.Add(@{id=$id;interface=$if;source=$rp}); $knownIfaces[$if]="xml-reference"; $referenceCount++ }
  }
}

# === Phase 2: @DubboService/@DubboReference + scan-packages ===
Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\src\\test\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $c = Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue; if (-not $c) { return }
  $rp = $_.FullName.Replace("$((Get-Location).Path)\\$SourceRoot\\", "").Replace('\\', '/')
  if ($c -match '@DubboService') {
    $ls = Get-Content $_.FullName -Encoding UTF8
    $cl = ($ls | Select-String '^\\s*public\\s+(abstract\\s+)?class\\s+(\\w+)' | Select-Object -First 1)
    if ($cl) {
      $cn = $cl.Matches[0].Groups[2].Value
      $im = [regex]::Match($cl.Line, 'implements\\s+([\\w.]+)')
      $if = if ($im.Success) { $im.Groups[1].Value } else { $cn }
      $annoServices.Add(@{class=$cn;interface=$if;source=$rp})
      $imp = ($ls | Select-String "import\\s+[\\w.]+\\.$if\\s*;")
      if ($imp) { $fi = ($imp | Select-Object -First 1).Line -replace 'import\\s+','' -replace '\\s*;',''; $knownIfaces[$fi]="annotation-service" }
      $knownIfaces[$if]="annotation-service"; $serviceCount++
    }
  }
  if ($c -match '@(EnableDubbo|DubboComponentScan)\\s*\\(') {
    foreach ($pm in [regex]::Matches($c, '(?:scanBasePackages|basePackages)\\s*=\\s*\\{?\\s*"([^"]+)"')) { $dubboScanPkgs.Add($pm.Groups[1].Value) }
  }
}
# scan-packages from config files
Get-ChildItem -Path $SourceRoot -Recurse -Include "application*.yml","application*.yaml","application*.properties" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $cc = Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
  if ($cc -match 'dubbo[\\s.]*scan[\\s.]*base-packages\\s*[:=]\\s*(.+)') {
    foreach ($p in ($Matches[1].Trim() -split '[,;]')) { $pt=$p.Trim(); if ($pt) { $dubboScanPkgs.Add($pt) } }
  }
}

# === Phase 3: Maven dependency graph + reverse implements ===
$moduleDeps = @{}; $moduleHasDubbo = @{}; $rootGroupId = ""
$rootPom = Join-Path $SourceRoot "pom.xml"
if (Test-Path $rootPom) { $rpc = (Get-Content $rootPom -Raw -Encoding UTF8) -replace '(?s)<!--.*?-->',''; if ($rpc -match '<groupId>([^<]+)</groupId>') { $rootGroupId=$Matches[1].Trim() } }

Get-ChildItem -Path $SourceRoot -Recurse -Filter "pom.xml" -Depth 2 | Where-Object { $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\.git\\*" } | ForEach-Object {
  $pc = (Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue) -replace '(?s)<!--.*?-->',''
  if (-not $pc) { return }
  $md = $_.DirectoryName.Replace("$((Get-Location).Path)\\$SourceRoot\\", "").Replace('\\', '/')
  $mn = if ($md -eq $_.DirectoryName) { "root" } else { ($md -split '[\\\\/]')[0] }
  if ($pc -match 'dubbo') { $moduleHasDubbo[$mn]=$true }
  $deps = [System.Collections.Generic.List[string]]::new()
  foreach ($dm in [regex]::Matches($pc, '<dependency>\\s*<groupId>([^<]+)</groupId>\\s*<artifactId>([^<]+)</artifactId>')) {
    if ($dm.Groups[1].Value.Trim() -eq $rootGroupId -or $dm.Groups[1].Value.Trim() -eq '\${project.groupId}') { $deps.Add($dm.Groups[2].Value.Trim()) }
  }
  $moduleDeps[$mn] = $deps
}
# Propagate dubbo dependency
$ch=$true; while ($ch) { $ch=$false; foreach ($m in @($moduleDeps.Keys)) { if ($moduleHasDubbo.ContainsKey($m)) { continue }; foreach ($d in $moduleDeps[$m]) { if ($moduleHasDubbo.ContainsKey($d)) { $moduleHasDubbo[$m]=$true; $ch=$true; break } } } }

# API modules by dep graph (exclude common modules: depended by >30% or name contains 'common')
$apiModByDep = @{}; $depCnt = @{}
foreach ($m in @($moduleDeps.Keys)) { foreach ($d in $moduleDeps[$m]) { if (-not $depCnt.ContainsKey($d)){$depCnt[$d]=0}; $depCnt[$d]++ } }
$total = $moduleDeps.Count
foreach ($m in @($moduleDeps.Keys)) {
  if (-not $moduleHasDubbo.ContainsKey($m)) { continue }
  foreach ($d in $moduleDeps[$m]) {
    $dc = if ($depCnt.ContainsKey($d)){$depCnt[$d]}else{0}
    if ($total -gt 2 -and $dc -gt ($total*0.3)) { continue }
    if ($d -match 'common') { continue }
    $apiModByDep[$d]=$true
  }
}

# Reverse implements index via git grep (Rule c depends on git; non-git repos will skip this rule silently)
$implIdx = @{}
$fwIfaces = @('Serializable','Comparable','Cloneable','AutoCloseable','Closeable','Iterable','Runnable','Callable',
  'ApplicationContextAware','InitializingBean','DisposableBean','CommandLineRunner','ApplicationRunner',
  'FactoryBean','Ordered','PriorityOrdered','Lifecycle','Processor','Supplier','Consumer','Function',
  'Predicate','Serde','Deserializer','Serializer','ControlMessage')
$ggr = git -C $SourceRoot grep -n "public.*class.*implements" -- "*.java" 2>$null
if ($ggr) { foreach ($ln in $ggr) {
  if ($ln -match '[\\\\/](target|src[\\\\/]test)[\\\\/]' -or $ln -match '[\\\\/]\\.git[\\\\/]') { continue }
  $ps = $ln -split ':'; if ($ps.Count -lt 3) { continue }
  $mod = ($ps[0] -split '/')[0]
  $m = [regex]::Match(($ps[2..($ps.Count-1)] -join ':'), 'class\\s+(\\w+).*implements\\s+([\\w,\\s<>]+)')
  if ($m.Success) {
    foreach ($i in ($m.Groups[2].Value -split ',' | ForEach-Object { ($_.Trim() -split '<')[0].Trim() } | Where-Object { $_ -and $_ -notin $fwIfaces })) {
      if (-not $implIdx.ContainsKey($i)) { $implIdx[$i]=[System.Collections.Generic.List[object]]::new() }
      $implIdx[$i].Add(@{implClass=$m.Groups[1].Value;implModule=$mod})
    }
  }
}}

# === Phase 4: Scan public interfaces, apply rules ===
$ifaceDefs = [System.Collections.Generic.List[object]]::new(); $ifaceMethodCount = 0
$SVC_PATTERN = '(Service|Facade|Remote|Rest|Api|Client)$'

Get-ChildItem -Path $SourceRoot -Recurse -Filter "*.java" | Where-Object {
  $_.FullName -notlike "*\\target\\*" -and $_.FullName -notlike "*\\src\\test\\*" -and $_.FullName -notlike "*\\.git\\*"
} | ForEach-Object {
  $ls = Get-Content $_.FullName -Encoding UTF8; $c = $ls -join "\`n"
  if ($c -notmatch 'public\\s+interface\\s+') { return }
  $rp = $_.FullName.Replace("$((Get-Location).Path)\\$SourceRoot\\", "").Replace('\\', '/')
  $pkg = ($ls | Select-String "^package " | Select-Object -First 1).Line -replace 'package\\s+','' -replace ';',''
  $il = ($ls | Select-String '^\\s*public\\s+interface\\s+(\\w+)' | Select-Object -First 1)
  if (-not $il) { return }
  $in = $il.Matches[0].Groups[1].Value; $fn = "$pkg.$in"
  $isDubbo=$false; $tag=""

  # Rule a: XML/annotation known
  if ($knownIfaces.ContainsKey($fn)) { $isDubbo=$true; $tag=$knownIfaces[$fn] }
  elseif ($knownIfaces.ContainsKey($in)) { $isDubbo=$true; $tag=$knownIfaces[$in] }
  # Rule b: scan-packages
  if (-not $isDubbo -and $dubboScanPkgs.Count -gt 0) { foreach ($sp in $dubboScanPkgs) { if ($pkg.StartsWith($sp)) { $isDubbo=$true; $tag="scan-pkg"; break } } }
  # Rule c: reverse implements cross-module
  if (-not $isDubbo -and $implIdx.ContainsKey($in) -and $in -match $SVC_PATTERN) {
    $im = ($rp -split '[\\\\/]')[0]
    foreach ($ii in $implIdx[$in]) { if ($ii.implModule -ne $im -and $moduleHasDubbo.ContainsKey($ii.implModule)) { $isDubbo=$true; $tag="cross-impl"; break } }
  }
  # Rule d: Maven dep graph
  if (-not $isDubbo) { $im=($rp -split '[\\\\/]')[0]; if ($apiModByDep.ContainsKey($im) -and $in -match $SVC_PATTERN) { $isDubbo=$true; $tag="maven-dep" } }
  # Rule e: module name whitelist
  if (-not $isDubbo) { $dn=($rp -split '[\\\\/]')[0]; if ($dn -match '-(api|interface|facade|client)(-|$)' -and $in -match $SVC_PATTERN) { $isDubbo=$true; $tag="module-name" } }
  if (-not $isDubbo) { return }

  # Extract methods
  $methods = [System.Collections.Generic.List[object]]::new()
  foreach ($l in $ls) {
    $tl = $l.Trim()
    if ($tl -match '^[@/\\*]' -or $tl -eq '' -or $tl -eq '}' -or $tl -match '^\\s*(default|static|package|import)\\s+' -or $tl -match '^\\s*public\\s+interface\\s+') { continue }
    if ($tl -match '\\w+\\s+\\w+\\s*\\(') {
      $sig = ($tl -replace '\\s*;\\s*$','' -replace '\\s*\\{.*','').Trim() -replace '^\\s*public\\s+',''
      $pm = [regex]::Match($sig, '^(.+?)\\s+(\\w+)\\s*\\(([^)]*)\\)')
      if ($pm.Success) {
        $pList = @(); $pStr = $pm.Groups[3].Value.Trim()
        if ($pStr) { foreach ($p in ($pStr -split ',')) { $pt=($p.Trim() -replace '@\\w+(\\([^)]*\\))?\\s*','').Trim(); $pp=$pt -split '\\s+'; if ($pp.Count -ge 2) { $pList += "$($pp[-1]): $($pp[0..($pp.Count-2)] -join ' ')" } } }
        $methods.Add(@{name=$pm.Groups[2].Value;params=$(if($pList.Count -gt 0){$pList -join ', '}else{"-"});ret=$pm.Groups[1].Value.Trim()})
        $ifaceMethodCount++
      }
    }
  }
  if ($methods.Count -gt 0) { $ifaceDefs.Add(@{name=$in;fullName=$fn;methods=$methods;source=$rp;tag=$tag;knownTag=$(if($knownIfaces.ContainsKey($fn)){$knownIfaces[$fn]}elseif($knownIfaces.ContainsKey($in)){$knownIfaces[$in]}else{""})}) }
}

# === Phase 5: Output ===
$LBL = @{ svc=[char]0x670D+[char]0x52A1+[char]0x66B4+[char]0x9732; ref=[char]0x670D+[char]0x52A1+[char]0x5F15+[char]0x7528; src=[char]0x6765+[char]0x6E90; def=[char]0x670D+[char]0x52A1+[char]0x63A5+[char]0x53E3+[char]0x5B9A+[char]0x4E49; mth=[char]0x63A5+[char]0x53E3+[char]0x65B9+[char]0x6CD5; prm=[char]0x5165+[char]0x53C2; ret=[char]0x8FD4+[char]0x56DE+[char]0x503C; desc=[char]0x8BF4+[char]0x660E; iface=[char]0x63A5+[char]0x53E3 }

$mdLines.Add("## Dubbo $($LBL.svc) (dubbo:service / @DubboService)")
$mdLines.Add(""); $mdLines.Add("| ID | $($LBL.iface) | Ref/Class | Timeout | $($LBL.src) |"); $mdLines.Add("|-----|-----------|-----------|---------|------|")
foreach ($s in $xmlServices) { $to=if($s.timeout){"$($s.timeout)ms"}else{"-"}; $mdLines.Add("| $($s.id) | \`\`$($s.interface)\`\` | $($s.ref) | $to | XML: $($s.source) |") }
foreach ($s in $annoServices) { $mdLines.Add("| - | \`\`$($s.interface)\`\` | $($s.class) | - | @DubboService: $($s.source) |") }

$mdLines.Add(""); $mdLines.Add("## Dubbo $($LBL.ref) (dubbo:reference / @DubboReference)")
$mdLines.Add(""); $mdLines.Add("| ID/Field | $($LBL.iface) | $($LBL.src) |"); $mdLines.Add("|----------|-----------|------|")
foreach ($r in $xmlReferences) { $mdLines.Add("| $($r.id) | \`\`$($r.interface)\`\` | XML: $($r.source) |") }

$mdLines.Add(""); $mdLines.Add("## Dubbo $($LBL.def)"); $mdLines.Add("")
$tagMap = @{"xml-service"=" [XML $($LBL.svc)]";"xml-reference"=" [XML $($LBL.ref)]";"annotation-service"=" [@DubboService]";"annotation-reference"=" [@DubboReference]"}
foreach ($d in $ifaceDefs) {
  $ts = if ($tagMap.ContainsKey($d.knownTag)) { $tagMap[$d.knownTag] } else { "" }
  $mdLines.Add("### $($d.name)$ts"); $mdLines.Add(""); $mdLines.Add("> \`\`$($d.fullName)\`\`"); $mdLines.Add("> $($LBL.src): $($d.source)"); $mdLines.Add("")
  $mdLines.Add("| $($LBL.mth) | $($LBL.prm) | $($LBL.ret) | $($LBL.desc) |"); $mdLines.Add("|------|------|------|------|")
  foreach ($m in $d.methods) { $mdLines.Add("| $($m.name) | $($m.params) | $($m.ret) |  |") }
  $mdLines.Add("")
}

$hdr = "> Dubbo Service: $serviceCount, Reference: $referenceCount, Interface Definitions: $($ifaceDefs.Count), Methods: $ifaceMethodCount"
$body = $hdr + [Environment]::NewLine + [Environment]::NewLine + ($mdLines -join [Environment]::NewLine)
[System.IO.File]::WriteAllText((Join-Path $OutputDir "dubbo-scan-result.md"), $body, (New-Object System.Text.UTF8Encoding $true))
Write-Host "Dubbo Service: $serviceCount, Reference: $referenceCount, Interface Definitions: $($ifaceDefs.Count), Methods: $ifaceMethodCount"