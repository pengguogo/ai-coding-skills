# Init 机械扫描：列出工作区根下所有 ocspec-* 一级目录（scheduler-protocol §1.2.1）
# 用法: .\init-ocspec-scan.ps1 -WorkspaceRoot "C:\path\to\workspace"
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceRoot
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$names = Get-ChildItem -LiteralPath $root -Directory |
    Where-Object { $_.Name -like 'ocspec-*' } |
    Select-Object -ExpandProperty Name |
    Sort-Object

if ($names.Count -eq 0) {
    Write-Output '(empty)'
    exit 0
}

$names | ForEach-Object { Write-Output $_ }
exit 0
