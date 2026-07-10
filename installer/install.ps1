$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$sourceAppDir = Join-Path $repoRoot 'app'
$installDir = Join-Path $env:USERPROFILE '.codex\provider-switch'
$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Codex Provider Switcher.lnk'
$startMenuShortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Codex Provider Switcher.lnk'
$wscriptExe = Join-Path $env:WINDIR 'System32\wscript.exe'
$silentLauncher = Join-Path $installDir 'CodexProviderSwitcher.vbs'

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
  Write-Warning 'Codex CLI was not found in PATH. Install Codex first, then run this installer again.'
}

if (-not (Test-Path -LiteralPath $sourceAppDir)) {
  throw "Missing app directory: $sourceAppDir"
}

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $installDir 'backups') | Out-Null

Get-ChildItem -LiteralPath $sourceAppDir -File | ForEach-Object {
  $destination = Join-Path $installDir $_.Name
  if ($_.Name -eq 'providers.json' -and (Test-Path -LiteralPath $destination)) {
    return
  }
  Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
}

$installedProvidersPath = Join-Path $installDir 'providers.json'
$installedProvidersExamplePath = Join-Path $installDir 'providers.example.json'
if (-not (Test-Path -LiteralPath $installedProvidersPath) -and (Test-Path -LiteralPath $installedProvidersExamplePath)) {
  Copy-Item -LiteralPath $installedProvidersExamplePath -Destination $installedProvidersPath -Force
}

if (-not (Test-Path -LiteralPath $silentLauncher)) {
  throw "Missing installed launcher: $silentLauncher"
}

$shell = New-Object -ComObject WScript.Shell

function New-AppShortcut([string]$Path) {
  $shortcut = $shell.CreateShortcut($Path)
  $shortcut.TargetPath = $wscriptExe
  $shortcut.Arguments = "`"$silentLauncher`""
  $shortcut.WorkingDirectory = $installDir
  $shortcut.IconLocation = "$env:WINDIR\System32\shell32.dll,25"
  $shortcut.Description = 'Codex provider switcher'
  $shortcut.Save()
}

New-AppShortcut $desktopShortcut
New-AppShortcut $startMenuShortcut

Get-ChildItem -LiteralPath ([Environment]::GetFolderPath('Desktop')) -Filter 'Codex-*.cmd' -File -ErrorAction SilentlyContinue |
  Remove-Item -Force

Write-Host 'Codex Provider Switcher installed.'
Write-Host "Install directory: $installDir"
Write-Host "Desktop shortcut: $desktopShortcut"
Write-Host "Start menu shortcut: $startMenuShortcut"
Write-Host 'Open "Codex Provider Switcher" from Desktop or Start menu.'
