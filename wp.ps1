param(
  [switch]$WithMounts,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$WpArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "scripts\\wp.ps1") -WithMounts:$WithMounts @WpArgs
