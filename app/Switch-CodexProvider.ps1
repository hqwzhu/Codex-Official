param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('ccswitch', 'official', 'status')]
  [string]$Provider,

  [ValidateSet('zh-CN', 'en-US')]
  [string]$Language = 'zh-CN',

  [switch]$Launch
)

$ErrorActionPreference = 'Stop'

$codexHome = Join-Path $env:USERPROFILE '.codex'
$configPath = Join-Path $codexHome 'config.toml'
$backupDir = Join-Path $codexHome 'provider-switch\backups'
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

function ConvertFrom-Utf8Base64([string]$Value) {
  [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

$Text = @{
  'en-US' = @{
    CurrentConfig = 'Current Codex config: {0}'
    CodexLoginStatus = 'Codex login status:'
    Switched = 'Switched Codex provider to {0}.'
    Backup = 'Backup: {0}'
    ProviderAuth = 'Provider auth: {0}'
    Restart = 'Restart any already-open Codex window so it reloads config.toml.'
    MissingConfig = 'Missing config file: {0}'
    EmptySecret = '{0} was empty; no changes made.'
  }
  'zh-CN' = @{
    CurrentConfig = ConvertFrom-Utf8Base64 '5b2T5YmNIENvZGV4IOmFjee9ru+8mnswfQ=='
    CodexLoginStatus = ConvertFrom-Utf8Base64 'Q29kZXgg55m75b2V54q25oCB77ya'
    Switched = ConvertFrom-Utf8Base64 '5bey5YiH5o2iIENvZGV4IOi/nuaOpeWIsCB7MH3jgII='
    Backup = ConvertFrom-Utf8Base64 '5aSH5Lu977yaezB9'
    ProviderAuth = ConvertFrom-Utf8Base64 '6K6k6K+B5pa55byP77yaezB9'
    Restart = ConvertFrom-Utf8Base64 '6K+36YeN5ZCv5bey57uP5omT5byA55qEIENvZGV4IOeql+WPo++8jOiuqeWug+mHjeaWsOivu+WPliBjb25maWcudG9tbOOAgg=='
    MissingConfig = ConvertFrom-Utf8Base64 '57y65bCR6YWN572u5paH5Lu277yaezB9'
    EmptySecret = ConvertFrom-Utf8Base64 'ezB9IOS4uuepuu+8jOacqui/m+ihjOS/ruaUueOAgg=='
  }
}

function Get-Text([string]$Key) {
  $Text[$Language][$Key]
}

function Format-Text([string]$Key, [object]$Value) {
  [string]::Format((Get-Text $Key), $Value)
}

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
    throw (Format-Text 'EmptySecret' $Name)
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
  Write-Host (Format-Text 'CurrentConfig' (Read-CurrentProvider))
  Write-Host "FREEMODEL_API_KEY: $([bool](Get-EffectiveEnvValue 'FREEMODEL_API_KEY'))"
  Write-Host (Get-Text 'CodexLoginStatus')
  codex login status
  exit 0
}

if (-not (Test-Path -LiteralPath $configPath)) {
  throw (Format-Text 'MissingConfig' $configPath)
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

Write-Host (Format-Text 'Switched' $Provider)
Write-Host (Format-Text 'Backup' $backupPath)
Write-Host (Format-Text 'ProviderAuth' $envName)
Write-Host (Get-Text 'Restart')

if ($Launch) {
  Start-Process -FilePath 'codex' -ArgumentList 'app'
}
