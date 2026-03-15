param(
  [switch]$Adminer,
  [switch]$Mailpit,
  [switch]$Direct
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

function Open-Url([string]$Url) {
  if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
    Start-Process $Url | Out-Null
    return
  }

  if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)) {
    & open $Url
    return
  }

  & xdg-open $Url
}

function Test-IsWindows {
  return [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
}

function Get-HostsPath {
  if (Test-IsWindows) {
    return Join-Path $env:SystemRoot "System32\drivers\etc\hosts"
  }

  return "/etc/hosts"
}

function Test-HostMapped([string]$HostName) {
  $hostsPath = Get-HostsPath
  if (-not (Test-Path $hostsPath)) {
    return $false
  }

  $hostsContent = Get-Content $hostsPath -Raw
  return $hostsContent -match ("(^|\s){0}(\s|$)" -f [Regex]::Escape($HostName))
}

function Format-ProxyUrl([string]$HostName, [string]$Port) {
  if ($Port -eq "80") {
    return "http://$HostName"
  }

  return "http://{0}:{1}" -f $HostName, $Port
}

function Test-ProxyTargetAvailable([hashtable]$Settings, [string]$HostName) {
  if ([string]::IsNullOrWhiteSpace($HostName)) {
    return $false
  }

  $projectName = $Settings["COMPOSE_PROJECT_NAME"]
  $proxyProjectName = $Settings["PROXY_PROJECT_NAME"]
  $configDir = $Settings["PROXY_CONFIG_DIR"]
  if ([string]::IsNullOrWhiteSpace($projectName) -or [string]::IsNullOrWhiteSpace($proxyProjectName) -or [string]::IsNullOrWhiteSpace($configDir)) {
    return $false
  }

  $proxyRunning = docker ps --filter "label=com.docker.compose.project=$proxyProjectName" --format "{{.Names}}" 2>$null | Select-Object -First 1
  if ([string]::IsNullOrWhiteSpace($proxyRunning)) {
    return $false
  }

  $configPath = Join-Path $configDir ("{0}.yml" -f $projectName)
  if (-not (Test-Path $configPath)) {
    return $false
  }

  $routePattern = 'Host\(`' + [Regex]::Escape($HostName) + '`\)'
  if (-not (Select-String -Path $configPath -Pattern $routePattern -Quiet)) {
    return $false
  }

  return Test-HostMapped $HostName
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
& (Join-Path $PSScriptRoot "bootstrap-env.ps1") -Quiet
$settings = Get-EnvSettings (Join-Path $root ".env")

if ($Adminer -and $Mailpit) {
  throw "Choose only one target: site, Adminer, or Mailpit."
}

if ($Adminer) {
  $directUrl = "http://127.0.0.1:{0}" -f $settings["ADMINER_PUBLISHED_PORT"]
  $proxyHost = "db-{0}" -f $settings["WP_HOSTNAME"]
  $proxyUrl = Format-ProxyUrl -HostName $proxyHost -Port $settings["PROXY_HTTP_PORT"]
  $url = if ($Direct -or -not (Test-ProxyTargetAvailable -Settings $settings -HostName $proxyHost)) { $directUrl } else { $proxyUrl }
}
elseif ($Mailpit) {
  $directUrl = "http://127.0.0.1:{0}" -f $settings["MAILPIT_PUBLISHED_PORT"]
  $proxyHost = "mail-{0}" -f $settings["WP_HOSTNAME"]
  $proxyUrl = Format-ProxyUrl -HostName $proxyHost -Port $settings["PROXY_HTTP_PORT"]
  $url = if ($Direct -or -not (Test-ProxyTargetAvailable -Settings $settings -HostName $proxyHost)) { $directUrl } else { $proxyUrl }
}
else {
  $directUrl = if ($settings.ContainsKey("WP_DIRECT_URL") -and -not [string]::IsNullOrWhiteSpace($settings["WP_DIRECT_URL"])) {
    $settings["WP_DIRECT_URL"]
  } else {
    "http://localhost:{0}" -f $settings["WORDPRESS_PUBLISHED_PORT"]
  }
  $proxyUrl = $settings["WP_URL"]
  $url = if ($Direct -or -not (Test-ProxyTargetAvailable -Settings $settings -HostName $settings["WP_HOSTNAME"])) { $directUrl } else { $proxyUrl }
}

Open-Url $url
Write-Host $url
