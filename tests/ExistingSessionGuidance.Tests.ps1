$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$switchScript = Join-Path $repoRoot 'app\Switch-CodexProvider.ps1'
$tempHome = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-provider-guidance-test-" + [guid]::NewGuid().ToString('N'))
$originalUserProfile = $env:USERPROFILE

try {
  $env:USERPROFILE = $tempHome
  $codexHome = Join-Path $tempHome '.codex'
  New-Item -ItemType Directory -Force -Path $codexHome | Out-Null
  'model_provider = "openai"' | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Encoding UTF8

  $output = & $switchScript -Provider thirdparty -ProviderId freemodel -Language en-US 6>&1 | Out-String

  if ($output -notmatch 'Existing Codex tasks keep their original provider') {
    throw 'Switch output does not warn that existing tasks cannot hot-switch providers.'
  }
  if ($output -notmatch 'new task') {
    throw 'Switch output does not tell the user to create a new task after switching.'
  }

  Write-Host 'PASS: switch output explains how existing and new tasks use providers.'
} finally {
  $env:USERPROFILE = $originalUserProfile
  if (Test-Path -LiteralPath $tempHome) {
    Remove-Item -LiteralPath $tempHome -Recurse -Force
  }
}
