param(
  [switch]$WithMounts,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$WpArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-EnvSettings([string]$Path) {
  $settings = @{}
  foreach ($line in Get-Content $Path) {
    if ($line -match "^\s*#" -or $line -notmatch "=") {
      continue
    }
    $parts = $line.Split("=", 2)
    $settings[$parts[0].Trim()] = $parts[1].Trim()
  }
  return $settings
}

function Is-True([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $false
  }

  return @("1", "true", "yes", "on") -contains $Value.Trim().ToLowerInvariant()
}

function Invoke-ContentPermissionNormalization([hashtable]$Settings, [string[]]$ComposeFileArgs) {
  $runtimeUid = if ($Settings.ContainsKey("PRESSYARD_RUNTIME_UID")) { $Settings["PRESSYARD_RUNTIME_UID"] } else { "" }
  $runtimeGid = if ($Settings.ContainsKey("PRESSYARD_RUNTIME_GID")) { $Settings["PRESSYARD_RUNTIME_GID"] } else { "" }

  if ($runtimeUid -notmatch '^\d+$' -or $runtimeGid -notmatch '^\d+$') {
    return
  }

  docker compose @ComposeFileArgs --profile ops run --rm --no-deps --entrypoint bash `
    -e "PRESSYARD_RUNTIME_UID=$runtimeUid" `
    -e "PRESSYARD_RUNTIME_GID=$runtimeGid" `
    wp-cli /workspace/scripts/fix-content-permissions.sh | Out-Null
}

function Test-ProjectUsesBindMounts([string]$ProjectName) {
  if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    return $false
  }

  $containerName = docker ps `
    --filter "label=com.docker.compose.project=$ProjectName" `
    --filter "label=com.docker.compose.service=wordpress" `
    --format "{{.Names}}" | Select-Object -First 1

  if ([string]::IsNullOrWhiteSpace($containerName)) {
    return $false
  }

  $mountLines = docker inspect --format "{{range .Mounts}}{{println .Type .Destination}}{{end}}" $containerName 2>$null
  foreach ($line in $mountLines) {
    if ($line -match '^bind /var/www/html/wp-content/(plugins|mu-plugins|themes)$') {
      return $true
    }
  }

  return $false
}

if ($WpArgs.Count -eq 0) {
  throw "Pass WP-CLI arguments, for example: .\scripts\wp.ps1 plugin list"
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
& (Join-Path $PSScriptRoot "bootstrap-env.ps1") -Quiet
$settings = Get-EnvSettings (Join-Path $root ".env")
$projectName = $settings["COMPOSE_PROJECT_NAME"]
$mailpitRunning = docker ps --filter "label=com.docker.compose.project=$projectName" --filter "label=com.docker.compose.service=mailpit" --format "{{.Names}}" | Select-Object -First 1
$useMounts = $WithMounts -or (Test-ProjectUsesBindMounts -ProjectName $projectName)
$composeFileArgs = @("-f", "docker-compose.yml")
if ($useMounts) {
  $composeFileArgs += @("-f", "docker-compose.mounts.yml")
}

$previousEnableMailpit = $env:ENABLE_MAILPIT
if ((Is-True $settings["ENABLE_MAILPIT"]) -or -not [string]::IsNullOrWhiteSpace($mailpitRunning)) {
  $env:ENABLE_MAILPIT = "true"
}

Push-Location $root
try {
  docker compose @composeFileArgs --profile ops run --rm --no-deps wp-cli @WpArgs
}
finally {
  try {
    Invoke-ContentPermissionNormalization -Settings $settings -ComposeFileArgs $composeFileArgs
  }
  catch {
    Write-Warning "Could not normalize wp-content ownership after WP-CLI execution."
  }
  if ($null -eq $previousEnableMailpit) {
    Remove-Item Env:ENABLE_MAILPIT -ErrorAction SilentlyContinue
  }
  else {
    $env:ENABLE_MAILPIT = $previousEnableMailpit
  }
  Pop-Location
}
