$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$switchScript = Join-Path $repoRoot 'app\Switch-CodexProvider.ps1'
$tempHome = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-provider-switch-test-" + [guid]::NewGuid().ToString('N'))
$originalUserProfile = $env:USERPROFILE

try {
  $env:USERPROFILE = $tempHome
  $codexHome = Join-Path $tempHome '.codex'
  New-Item -ItemType Directory -Force -Path $codexHome | Out-Null

  @'
model_provider = "openai"
model = "gpt-test"

[projects.'C:\test']
trust_level = "trusted"
'@ | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Encoding UTF8

  & $switchScript -Provider thirdparty -ProviderId freemodel -Language en-US

  $config = Get-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Raw
  foreach ($expected in @(
    'model_reasoning_effort = "xhigh"',
    'service_tier = "fast"',
    '[model_providers.freemodel]'
  )) {
    if (-not $config.Contains($expected)) {
      throw "Expected generated config to contain: $expected"
    }
  }

  if ($config.Contains('preferred_auth_method')) {
    throw 'Generated config contains unsupported field: preferred_auth_method'
  }

  Write-Host 'PASS: third-party switch inserts missing TOML settings.'
} finally {
  $env:USERPROFILE = $originalUserProfile
  if (Test-Path -LiteralPath $tempHome) {
    Remove-Item -LiteralPath $tempHome -Recurse -Force
  }
}
