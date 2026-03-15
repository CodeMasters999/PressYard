param(
  [switch]$WithTools,
  [switch]$WithProxy,
  [switch]$WithMounts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "down.ps1") -Volumes

if ($WithTools) {
  if ($PSBoundParameters.ContainsKey("WithProxy")) {
    & (Join-Path $PSScriptRoot "up.ps1") -WithTools -WithProxy:$WithProxy -WithMounts:$WithMounts
  }
  else {
    & (Join-Path $PSScriptRoot "up.ps1") -WithTools -WithMounts:$WithMounts
  }
}
else {
  if ($PSBoundParameters.ContainsKey("WithProxy")) {
    & (Join-Path $PSScriptRoot "up.ps1") -WithProxy:$WithProxy -WithMounts:$WithMounts
  }
  else {
    & (Join-Path $PSScriptRoot "up.ps1") -WithMounts:$WithMounts
  }
}
