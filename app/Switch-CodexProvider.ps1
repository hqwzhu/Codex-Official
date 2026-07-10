param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('thirdparty', 'ccswitch', 'official', 'status')]
  [string]$Provider,

  [string]$ProviderId = 'freemodel',

  [ValidateSet('zh-CN', 'en-US')]
  [string]$Language = 'zh-CN',

  [switch]$Launch
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$providersPath = Join-Path $scriptDir 'providers.json'
$providersExamplePath = Join-Path $scriptDir 'providers.example.json'
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
    ProviderNotFound = 'Third-party provider not found: {0}'
    MissingProviderConfig = 'Missing third-party provider config file: {0}'
    ThirdPartyEnv = 'Third-party key ({0}): {1}'
    ThirdPartyProviders = 'Third-party providers:'
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
    ProviderNotFound = ConvertFrom-Utf8Base64 '5om+5LiN5Yiw56ys5LiJ5pa56L+e5o6l77yaezB9'
    MissingProviderConfig = ConvertFrom-Utf8Base64 '57y65bCR56ys5LiJ5pa56L+e5o6l6YWN572u5paH5Lu277yaezB9'
    ThirdPartyEnv = ConvertFrom-Utf8Base64 '56ys5LiJ5pa5IEtleSAoezB9Ke+8mnsxfQ=='
    ThirdPartyProviders = ConvertFrom-Utf8Base64 '56ys5LiJ5pa56L+e5o6l77ya'
  }
}

function Get-Text([string]$Key) {
  $Text[$Language][$Key]
}

function Format-Text([string]$Key, [object[]]$Values) {
  [string]::Format((Get-Text $Key), $Values)
}

function Get-EffectiveEnvValue([string]$Name) {
  foreach ($scope in @('Process', 'User', 'Machine')) {
    $value = [Environment]::GetEnvironmentVariable($Name, $scope)
    if ($value) { return $value }
  }
  return $null
}

function Get-ProviderConfigPath {
  if (Test-Path -LiteralPath $providersPath) {
    return $providersPath
  }
  if (Test-Path -LiteralPath $providersExamplePath) {
    return $providersExamplePath
  }
  throw (Format-Text 'MissingProviderConfig' @($providersPath))
}

function Get-JsonProperty([object]$Object, [string]$Name, [string]$Default = '') {
  if ($null -eq $Object) { return $Default }
  if ($Object.PSObject.Properties.Name -notcontains $Name) { return $Default }
  $value = $Object.$Name
  if ($null -eq $value -or [string]::IsNullOrWhiteSpace([string]$value)) { return $Default }
  return [string]$value
}

function Get-ThirdPartyProviders {
  $path = Get-ProviderConfigPath
  $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $config = $raw | ConvertFrom-Json
  if ($null -eq $config.providers) { return @() }
  return @($config.providers)
}

function Find-ThirdPartyProvider([string]$Id) {
  $providers = Get-ThirdPartyProviders
  foreach ($item in $providers) {
    if ((Get-JsonProperty $item 'id') -eq $Id) {
      return $item
    }
  }
  throw (Format-Text 'ProviderNotFound' @($Id))
}

function Format-TomlString([string]$Value) {
  $escaped = $Value.Replace('\', '\\').Replace('"', '\"')
  return "`"$escaped`""
}

function New-StringList([string[]]$Lines) {
  $list = New-Object System.Collections.Generic.List[string]
  foreach ($line in $Lines) {
    [void]$list.Add($line)
  }
  return $list
}

function Set-TomlScalar([string[]]$Lines, [string]$Key, [string]$Value) {
  $pattern = "^\s*$([regex]::Escape($Key))\s*="
  $replacement = "$Key = $(Format-TomlString $Value)"
  $sectionIndex = $Lines.Count

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match '^\s*\[.+\]\s*$') {
      $sectionIndex = $i
      break
    }
    if ($Lines[$i] -match $pattern) {
      $Lines[$i] = $replacement
      return $Lines
    }
  }

  $list = New-StringList $Lines
  $list.Insert($sectionIndex, $replacement)
  return $list.ToArray()
}

function Set-TomlSectionScalar([string[]]$Lines, [string]$SectionName, [string]$Key, [string]$Value) {
  $sectionPattern = "^\s*\[$([regex]::Escape($SectionName))\]\s*$"
  $keyPattern = "^\s*$([regex]::Escape($Key))\s*="
  $replacement = "$Key = $(Format-TomlString $Value)"
  $start = -1
  $end = $Lines.Count

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match $sectionPattern) {
      $start = $i
      break
    }
  }

  if ($start -lt 0) {
    $list = New-StringList $Lines
    if ($list.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($list[$list.Count - 1])) {
      [void]$list.Add('')
    }
    [void]$list.Add("[$SectionName]")
    [void]$list.Add($replacement)
    return $list.ToArray()
  }

  for ($i = $start + 1; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match '^\s*\[.+\]\s*$') {
      $end = $i
      break
    }
  }

  for ($i = $start + 1; $i -lt $end; $i++) {
    if ($Lines[$i] -match $keyPattern) {
      $Lines[$i] = $replacement
      return $Lines
    }
  }

  $list = New-StringList $Lines
  $list.Insert($end, $replacement)
  return $list.ToArray()
}

function Read-CurrentProvider {
  if (-not (Test-Path -LiteralPath $configPath)) {
    return '<missing config.toml>'
  }

  $lines = Get-Content -LiteralPath $configPath
  $provider = 'model_provider = <unset>'
  $model = 'model = <unset>'

  foreach ($line in $lines) {
    if ($line -match '^\s*\[.+\]\s*$') { break }
    if ($line -match '^\s*model_provider\s*=') { $provider = $line.Trim() }
    if ($line -match '^\s*model\s*=') { $model = $line.Trim() }
  }

  return "$provider; $model"
}

if ($Provider -eq 'ccswitch') {
  $Provider = 'thirdparty'
  $ProviderId = 'freemodel'
}

if ($Provider -eq 'status') {
  Write-Host (Format-Text 'CurrentConfig' @((Read-CurrentProvider)))
  Write-Host (Get-Text 'ThirdPartyProviders')
  foreach ($item in (Get-ThirdPartyProviders)) {
    $id = Get-JsonProperty $item 'id'
    $displayName = Get-JsonProperty $item 'displayName' $id
    $envKey = Get-JsonProperty $item 'envKey'
    if ($envKey) {
      Write-Host ("  - {0} ({1})" -f $displayName, $id)
      Write-Host ("    " + (Format-Text 'ThirdPartyEnv' @($envKey, [bool](Get-EffectiveEnvValue $envKey))))
    }
  }
  Write-Host (Get-Text 'CodexLoginStatus')
  codex login status
  exit 0
}

if (-not (Test-Path -LiteralPath $configPath)) {
  throw (Format-Text 'MissingConfig' @($configPath))
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$backupPath = Join-Path $backupDir "config.$timestamp.toml"
Copy-Item -LiteralPath $configPath -Destination $backupPath -Force

$lines = Get-Content -LiteralPath $configPath

if ($Provider -eq 'thirdparty') {
  $selected = Find-ThirdPartyProvider $ProviderId
  $id = Get-JsonProperty $selected 'id'
  $displayName = Get-JsonProperty $selected 'displayName' $id
  $modelProvider = Get-JsonProperty $selected 'modelProvider' $id
  $baseUrl = Get-JsonProperty $selected 'baseUrl'
  $envKey = Get-JsonProperty $selected 'envKey'
  $wireApi = Get-JsonProperty $selected 'wireApi' 'responses'
  $model = Get-JsonProperty $selected 'model' 'gpt-5.5'
  $reasoningEffort = Get-JsonProperty $selected 'modelReasoningEffort' 'xhigh'
  $serviceTier = Get-JsonProperty $selected 'serviceTier' 'fast'
  $authMethod = Get-JsonProperty $selected 'preferredAuthMethod' 'apikey'

  if ([string]::IsNullOrWhiteSpace($modelProvider) -or [string]::IsNullOrWhiteSpace($baseUrl) -or [string]::IsNullOrWhiteSpace($envKey)) {
    throw (Format-Text 'ProviderNotFound' @($ProviderId))
  }

  $apiKey = Get-EffectiveEnvValue $envKey
  if ($apiKey) { Set-Item -Path "Env:$envKey" -Value $apiKey }

  $lines = Set-TomlScalar $lines 'model_provider' $modelProvider
  $lines = Set-TomlScalar $lines 'model' $model
  $lines = Set-TomlScalar $lines 'model_reasoning_effort' $reasoningEffort
  $lines = Set-TomlScalar $lines 'service_tier' $serviceTier
  $lines = Set-TomlScalar $lines 'preferred_auth_method' $authMethod

  $sectionName = "model_providers.$modelProvider"
  $lines = Set-TomlSectionScalar $lines $sectionName 'name' $displayName
  $lines = Set-TomlSectionScalar $lines $sectionName 'base_url' $baseUrl
  $lines = Set-TomlSectionScalar $lines $sectionName 'env_key' $envKey
  $lines = Set-TomlSectionScalar $lines $sectionName 'wire_api' $wireApi

  $switchName = $displayName
  $envName = "$envKey ($displayName)"
} else {
  $lines = Set-TomlScalar $lines 'model_provider' 'openai'
  $lines = Set-TomlScalar $lines 'model' 'gpt-5.5'
  $lines = Set-TomlScalar $lines 'model_reasoning_effort' 'medium'
  $lines = Set-TomlScalar $lines 'service_tier' 'fast'
  $lines = Set-TomlScalar $lines 'preferred_auth_method' 'chatgpt'
  $switchName = 'Official ChatGPT'
  $envName = 'ChatGPT account login'
}

Set-Content -LiteralPath $configPath -Value $lines -Encoding UTF8

Write-Host (Format-Text 'Switched' @($switchName))
Write-Host (Format-Text 'Backup' @($backupPath))
Write-Host (Format-Text 'ProviderAuth' @($envName))
Write-Host (Get-Text 'Restart')

if ($Launch) {
  Start-Process -FilePath 'codex' -ArgumentList 'app'
}
