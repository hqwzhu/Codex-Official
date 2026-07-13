$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$appScript = Join-Path $repoRoot 'app\CodexProviderSwitchApp.ps1'
$source = Get-Content -LiteralPath $appScript -Raw -Encoding UTF8

if ($source.Contains("`$wireApiBox.Items.Add('chat')")) {
  throw 'The provider dialog still offers the unsupported chat wire API.'
}

if ($source -notmatch "id\s*=\s*'openrouter'.*wireApi\s*=\s*'responses'") {
  throw 'The OpenRouter preset must use the Responses API supported by current Codex.'
}

if ($source -match "id\s*=\s*'siliconflow'") {
  throw 'SiliconFlow must not be offered as a one-click preset without a documented Responses API.'
}

Write-Host 'PASS: built-in provider presets use Codex-compatible Responses API settings.'
