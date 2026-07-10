$ErrorActionPreference = 'Stop'

$installDir = Join-Path $env:USERPROFILE '.codex\provider-switch'
$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Codex Provider Switcher.lnk'
$startMenuShortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Codex Provider Switcher.lnk'

foreach ($path in @($desktopShortcut, $startMenuShortcut)) {
  if (Test-Path -LiteralPath $path) {
    Remove-Item -LiteralPath $path -Force
  }
}

if (Test-Path -LiteralPath $installDir) {
  Remove-Item -LiteralPath $installDir -Recurse -Force
}

Write-Host 'Codex Provider Switcher uninstalled.'
Write-Host 'Codex config.toml and environment variables were not removed.'
