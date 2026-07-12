$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$switchScript = Join-Path $repoRoot 'app\Switch-CodexProvider.ps1'
$tempHome = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-provider-state-test-" + [guid]::NewGuid().ToString('N'))
$originalUserProfile = $env:USERPROFILE

try {
  $env:USERPROFILE = $tempHome
  $codexHome = Join-Path $tempHome '.codex'
  New-Item -ItemType Directory -Force -Path $codexHome | Out-Null

  @'
model_provider = "openai"
model = "gpt-current-official"
model_reasoning_effort = "xhigh"
service_tier = "fast"
'@ | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Encoding UTF8

  & $switchScript -Provider thirdparty -ProviderId freemodel -Language en-US
  & $switchScript -Provider official -Language en-US

  $config = Get-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Raw
  foreach ($expected in @(
    'model_provider = "openai"',
    'model = "gpt-current-official"',
    'model_reasoning_effort = "xhigh"',
    'service_tier = "fast"'
  )) {
    if (-not $config.Contains($expected)) {
      throw "Expected restored official config to contain: $expected"
    }
  }

  Write-Host 'PASS: switching back restores the previous official model settings.'
} finally {
  $env:USERPROFILE = $originalUserProfile
  if (Test-Path -LiteralPath $tempHome) {
    Remove-Item -LiteralPath $tempHome -Recurse -Force
  }
}
