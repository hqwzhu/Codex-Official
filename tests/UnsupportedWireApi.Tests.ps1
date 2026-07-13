$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-provider-wire-api-test-" + [guid]::NewGuid().ToString('N'))
$tempHome = Join-Path $tempRoot 'home'
$tempApp = Join-Path $tempRoot 'app'
$originalUserProfile = $env:USERPROFILE

try {
  New-Item -ItemType Directory -Force -Path $tempApp | Out-Null
  Copy-Item -LiteralPath (Join-Path $repoRoot 'app\Switch-CodexProvider.ps1') -Destination $tempApp

  @'
{
  "providers": [
    {
      "id": "legacy-chat",
      "displayName": "Legacy Chat Gateway",
      "modelProvider": "legacy-chat",
      "baseUrl": "https://example.invalid/v1",
      "envKey": "LEGACY_CHAT_API_KEY",
      "wireApi": "chat",
      "model": "test-model"
    }
  ]
}
'@ | Set-Content -LiteralPath (Join-Path $tempApp 'providers.json') -Encoding UTF8

  $env:USERPROFILE = $tempHome
  $codexHome = Join-Path $tempHome '.codex'
  New-Item -ItemType Directory -Force -Path $codexHome | Out-Null
  'model_provider = "openai"' | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Encoding UTF8

  $errorMessage = ''
  try {
    & (Join-Path $tempApp 'Switch-CodexProvider.ps1') -Provider thirdparty -ProviderId legacy-chat -Language en-US
  } catch {
    $errorMessage = $_.Exception.Message
  }

  if ($errorMessage -notmatch 'responses') {
    throw "Expected a clear unsupported API error mentioning responses; got: $errorMessage"
  }

  Write-Host 'PASS: unsupported chat providers are rejected before writing Codex config.'
} finally {
  $env:USERPROFILE = $originalUserProfile
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
