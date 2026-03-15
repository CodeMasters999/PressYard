param(
  [switch]$WithTools,
  [switch]$WithProxy,
  [switch]$WithMounts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "scripts\\reset.ps1") @PSBoundParameters
