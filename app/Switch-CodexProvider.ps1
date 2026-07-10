param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('ccswitch', 'official', 'status')]
  [string]$Provider,

  [switch]$Launch
)

$ErrorActionPreference = 'Stop'

$codexHome = Join-Path $env:USERPROFILE '.codex'
$configPath = Join-Path $codexHome 'config.toml'
$backupDir = Join-Path $codexHome 'provider-switch\backups'
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

function Get-EffectiveEnvValue([string]$Name) {
  foreach ($scope in @('Process', 'User', 'Machine')) {
    $value = [Environment]::GetEnvironmentVariable($Name, $scope)
    if ($value) { return $value }
  }
  return $null
}

function Set-UserSecretEnv([string]$Name) {
  $secure = Read-Host "Enter $Name" -AsSecureString
  if ($secure.Length -eq 0) {
    throw "$Name was empty; no changes made."
  }
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try {
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    [Environment]::SetEnvironmentVariable($Name, $plain, 'User')
    Set-Item -Path "Env:$Name" -Value $plain
  } finally {
    if ($bstr -ne [IntPtr]::Zero) {
      [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
  }
}

function Set-TomlScalar([string[]]$Lines, [string]$Key, [string]$Value) {
  $pattern = "^\s*$([regex]::Escape($Key))\s*="
  $replacement = "$Key = `"$Value`""
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match $pattern) {
      $Lines[$i] = $replacement
      return $Lines
    }
  }

  return @($replacement) + $Lines
}

function Read-CurrentProvider {
  if (-not (Test-Path -LiteralPath $configPath)) {
    return '<missing config.toml>'
  }
  $lines = Get-Content -LiteralPath $configPath
  $provider = ($lines | Where-Object { $_ -match '^\s*model_provider\s*=' } | Select-Object -First 1)
  $model = ($lines | Where-Object { $_ -match '^\s*model\s*=' } | Select-Object -First 1)
  if (-not $provider) { $provider = 'model_provider = <unset>' }
  if (-not $model) { $model = 'model = <unset>' }
  return "$provider; $model"
}

if ($Provider -eq 'status') {
  Write-Host "Current Codex config: $(Read-CurrentProvider)"
  Write-Host "FREEMODEL_API_KEY: $([bool](Get-EffectiveEnvValue 'FREEMODEL_API_KEY'))"
  Write-Host "Codex login status:"
  codex login status
  exit 0
}

if (-not (Test-Path -LiteralPath $configPath)) {
  throw "Missing config file: $configPath"
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupPath = Join-Path $backupDir "config.$timestamp.toml"
Copy-Item -LiteralPath $configPath -Destination $backupPath -Force

$lines = Get-Content -LiteralPath $configPath

if ($Provider -eq 'ccswitch') {
  $freemodelKey = Get-EffectiveEnvValue 'FREEMODEL_API_KEY'
  if ($freemodelKey) { $env:FREEMODEL_API_KEY = $freemodelKey }

  $lines = Set-TomlScalar $lines 'model_provider' 'freemodel'
  $lines = Set-TomlScalar $lines 'model' 'gpt-5.5'
  $lines = Set-TomlScalar $lines 'model_reasoning_effort' 'xhigh'
  $lines = Set-TomlScalar $lines 'service_tier' 'fast'
  $lines = Set-TomlScalar $lines 'preferred_auth_method' 'apikey'
  $envName = 'FREEMODEL_API_KEY'
} else {
  $lines = Set-TomlScalar $lines 'model_provider' 'openai'
  $lines = Set-TomlScalar $lines 'model' 'gpt-5.5'
  $lines = Set-TomlScalar $lines 'model_reasoning_effort' 'medium'
  $lines = Set-TomlScalar $lines 'service_tier' 'fast'
  $lines = Set-TomlScalar $lines 'preferred_auth_method' 'chatgpt'
  $envName = 'ChatGPT account login'
}

Set-Content -LiteralPath $configPath -Value $lines -Encoding UTF8

Write-Host "Switched Codex provider to $Provider."
Write-Host "Backup: $backupPath"
Write-Host "Provider auth: $envName"
Write-Host "Restart any already-open Codex window so it reloads config.toml."

if ($Launch) {
  Start-Process -FilePath 'codex' -ArgumentList 'app'
}
