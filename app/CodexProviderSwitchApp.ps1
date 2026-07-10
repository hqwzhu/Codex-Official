$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$switchScript = Join-Path $scriptDir 'Switch-CodexProvider.ps1'
$loginScript = Join-Path $scriptDir 'Login-ChatGPT.cmd'
$providersPath = Join-Path $scriptDir 'providers.json'
$providersExamplePath = Join-Path $scriptDir 'providers.example.json'
$powershellExe = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$currentLanguage = 'zh-CN'
$script:providerItems = @()

function ConvertFrom-Utf8Base64([string]$Value) {
  [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

$Text = @{
  'en-US' = @{
    AppTitle = 'Codex Provider Switcher'
    Subtitle = 'Switch between official ChatGPT account mode and configurable third-party providers without mixing credentials.'
    LanguageLabel = 'Language'
    Official = 'Use Official ChatGPT'
    Status = 'Connection Status'
    Login = 'Re-login ChatGPT'
    ThirdPartyLabel = 'Third-party connection'
    UseThirdParty = 'Use Selected Third-party'
    EditProviders = 'Edit Third-party Connections'
    ReloadProviders = 'Reload List'
    Launch = 'Launch Codex after switching'
    Log = 'Log'
    Started = 'Application started.'
    Running = 'Running provider action: {0}'
    ExitCode = 'Exit code: {0}'
    LoginConfirm = 'This will log Codex out of the stored API-key login and start ChatGPT account login. Continue?'
    LoginTitle = 'ChatGPT account login'
    LoginCanceled = 'ChatGPT login canceled.'
    MissingHelper = 'Missing login helper: {0}'
    OpeningLogin = 'Opening ChatGPT login helper window.'
    LanguageZh = 'Chinese'
    LanguageEn = 'English'
    InstructionsTitle = 'Instructions'
    InstructionsText = "1. Click Connection Status first to confirm the active provider, third-party key, and ChatGPT login state.`r`n2. Use Official ChatGPT for official quota; choose a third-party connection and click Use Selected Third-party for a gateway.`r`n3. To add OpenRouter, SiliconFlow, or another gateway, click Edit Third-party Connections, save providers.json, then click Reload List.`r`n4. Restart any already-open Codex window after switching."
    ProvidersReloaded = 'Third-party connection list reloaded.'
    OpeningProviderConfig = 'Opening third-party provider config.'
    ProviderConfigTitle = 'Third-party provider config'
    NoThirdPartySelected = 'Select a third-party connection first.'
    ProviderConfigMissing = 'Third-party provider config file was not found: {0}'
    NoThirdPartyProviders = 'No third-party connections are configured.'
  }
  'zh-CN' = @{
    AppTitle = ConvertFrom-Utf8Base64 'Q29kZXgg6L+e5o6l5YiH5o2i5Zmo'
    Subtitle = ConvertFrom-Utf8Base64 '5LiA6ZSu5YiH5o2i5a6Y5pa5IENoYXRHUFQg6LSm5Y+35ZKM5Y+v6YWN572u56ys5LiJ5pa56L+e5o6l77yM6YG/5YWN5Yet5o2u5re355So44CC'
    LanguageLabel = ConvertFrom-Utf8Base64 '6K+t6KiA'
    Official = ConvertFrom-Utf8Base64 '5L2/55So5a6Y5pa5IENoYXRHUFQ='
    Status = ConvertFrom-Utf8Base64 '6L+e5o6l54q25oCB'
    Login = ConvertFrom-Utf8Base64 '6YeN5paw55m75b2VIENoYXRHUFQ='
    ThirdPartyLabel = ConvertFrom-Utf8Base64 '56ys5LiJ5pa56L+e5o6l'
    UseThirdParty = ConvertFrom-Utf8Base64 '5L2/55So5omA6YCJ56ys5LiJ5pa5'
    EditProviders = ConvertFrom-Utf8Base64 '57yW6L6R56ys5LiJ5pa56L+e5o6l'
    ReloadProviders = ConvertFrom-Utf8Base64 '5Yi35paw5YiX6KGo'
    Launch = ConvertFrom-Utf8Base64 '5YiH5o2i5ZCO5ZCv5YqoIENvZGV4'
    Log = ConvertFrom-Utf8Base64 '5pel5b+X'
    Started = ConvertFrom-Utf8Base64 '5bqU55So5bey5ZCv5Yqo44CC'
    Running = ConvertFrom-Utf8Base64 '5q2j5Zyo5omn6KGM5pON5L2c77yaezB9'
    ExitCode = ConvertFrom-Utf8Base64 '6YCA5Ye65Luj56CB77yaezB9'
    LoginConfirm = ConvertFrom-Utf8Base64 '6L+Z5Lya6YCA5Ye65b2T5YmN5L+d5a2Y55qEIEFQSSBLZXkg55m75b2V77yM5bm25byA5aeLIENoYXRHUFQg6LSm5Y+355m75b2V44CC5piv5ZCm57un57ut77yf'
    LoginTitle = ConvertFrom-Utf8Base64 'Q2hhdEdQVCDotKblj7fnmbvlvZU='
    LoginCanceled = ConvertFrom-Utf8Base64 '5bey5Y+W5raIIENoYXRHUFQg55m75b2V44CC'
    MissingHelper = ConvertFrom-Utf8Base64 '5om+5LiN5Yiw55m75b2V6L6F5Yqp6ISa5pys77yaezB9'
    OpeningLogin = ConvertFrom-Utf8Base64 '5q2j5Zyo5omT5byAIENoYXRHUFQg55m75b2V6L6F5Yqp56qX5Y+j44CC'
    LanguageZh = ConvertFrom-Utf8Base64 '5Lit5paH'
    LanguageEn = 'English'
    InstructionsTitle = ConvertFrom-Utf8Base64 '5L2/55So6K+05piO'
    InstructionsText = ConvertFrom-Utf8Base64 'MS4g5YWI54K56L+e5o6l54q25oCB77yM56Gu6K6k5b2T5YmNIHByb3ZpZGVy44CB56ys5LiJ5pa5IEtleSDlkowgQ2hhdEdQVCDnmbvlvZXnirbmgIHjgIINCjIuIOmcgOimgeWumOaWuemineW6puaXtueCueS9v+eUqOWumOaWuSBDaGF0R1BU77yb6ZyA6KaB56ys5LiJ5pa5572R5YWz5pe26YCJ5oup6L+e5o6l5ZCO54K55L2/55So5omA6YCJ56ys5LiJ5pa544CCDQozLiDopoHmt7vliqAgT3BlblJvdXRlcuOAgeehheWfuua1geWKqOetieesrOS4ieaWue+8jOeCuee8lui+keesrOS4ieaWuei/nuaOpe+8m+S/neWtmCBwcm92aWRlcnMuanNvbiDlkI7ngrnliLfmlrDliJfooajjgIINCjQuIOWIh+aNouWujOaIkOWQju+8jOmHjeWQr+W3suaJk+W8gOeahCBDb2RleCDnqpflj6PjgII='
    ProvidersReloaded = ConvertFrom-Utf8Base64 '56ys5LiJ5pa56L+e5o6l5YiX6KGo5bey5Yi35paw44CC'
    OpeningProviderConfig = ConvertFrom-Utf8Base64 '5q2j5Zyo5omT5byA56ys5LiJ5pa56L+e5o6l6YWN572u44CC'
    ProviderConfigTitle = ConvertFrom-Utf8Base64 '56ys5LiJ5pa56L+e5o6l6YWN572u'
    NoThirdPartySelected = ConvertFrom-Utf8Base64 '6K+35YWI6YCJ5oup5LiA5Liq56ys5LiJ5pa56L+e5o6l44CC'
    ProviderConfigMissing = ConvertFrom-Utf8Base64 '5om+5LiN5Yiw56ys5LiJ5pa56L+e5o6l6YWN572u5paH5Lu277yaezB9'
    NoThirdPartyProviders = ConvertFrom-Utf8Base64 '5pyq6YWN572u56ys5LiJ5pa56L+e5o6l44CC'
  }
}

function Get-Text([string]$Key) {
  $Text[$currentLanguage][$Key]
}

function Format-Text([string]$Key, [object[]]$Values) {
  [string]::Format((Get-Text $Key), $Values)
}

function New-Font([float]$Size, [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular) {
  return New-Object System.Drawing.Font('Segoe UI', $Size, $Style)
}

function Add-Log([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return }
  $timestamp = Get-Date -Format 'HH:mm:ss'
  foreach ($line in ($Text -split "(`r`n|`n|`r)")) {
    if ($line.Trim().Length -gt 0) {
      $logBox.AppendText("[$timestamp] $line`r`n")
    }
  }
}

function Invoke-Capture([string]$Arguments) {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $powershellExe
  $psi.Arguments = $Arguments
  $psi.WorkingDirectory = $scriptDir
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.CreateNoWindow = $true

  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $psi
  [void]$process.Start()
  $stdout = $process.StandardOutput.ReadToEnd()
  $stderr = $process.StandardError.ReadToEnd()
  $process.WaitForExit()

  return [pscustomobject]@{
    ExitCode = $process.ExitCode
    Output = ($stdout + $stderr).Trim()
  }
}

function Get-ProviderConfigPath([switch]$Create) {
  if (Test-Path -LiteralPath $providersPath) {
    return $providersPath
  }

  if ($Create -and (Test-Path -LiteralPath $providersExamplePath)) {
    Copy-Item -LiteralPath $providersExamplePath -Destination $providersPath -Force
    return $providersPath
  }

  if (Test-Path -LiteralPath $providersExamplePath) {
    return $providersExamplePath
  }

  throw (Format-Text 'ProviderConfigMissing' @($providersPath))
}

function Get-JsonProperty([object]$Object, [string]$Name, [string]$Default = '') {
  if ($null -eq $Object) { return $Default }
  if ($Object.PSObject.Properties.Name -notcontains $Name) { return $Default }
  $value = $Object.$Name
  if ($null -eq $value -or [string]::IsNullOrWhiteSpace([string]$value)) { return $Default }
  return [string]$value
}

function Get-ProviderDisplayName([object]$ProviderItem) {
  $id = Get-JsonProperty $ProviderItem 'id'
  return (Get-JsonProperty $ProviderItem 'displayName' $id)
}

function Load-Providers([bool]$WriteLog) {
  try {
    $path = Get-ProviderConfigPath
    $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $config = $raw | ConvertFrom-Json
    if ($null -eq $config.providers) {
      $script:providerItems = @()
    } else {
      $script:providerItems = @($config.providers)
    }

    $providerBox.Items.Clear()
    foreach ($item in $script:providerItems) {
      [void]$providerBox.Items.Add((Get-ProviderDisplayName $item))
    }

    $hasProviders = $providerBox.Items.Count -gt 0
    $providerBox.Enabled = $hasProviders
    $useThirdPartyButton.Enabled = $hasProviders
    if ($hasProviders) {
      $providerBox.SelectedIndex = 0
    } else {
      Add-Log (Get-Text 'NoThirdPartyProviders')
    }

    if ($WriteLog) {
      Add-Log (Get-Text 'ProvidersReloaded')
    }
  } catch {
    Add-Log $_.Exception.Message
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-Text 'AppTitle'), 'OK', 'Error') | Out-Null
  }
}

function Set-Language([string]$Language) {
  $script:currentLanguage = $Language
  $form.Text = Get-Text 'AppTitle'
  $title.Text = Get-Text 'AppTitle'
  $subtitle.Text = Get-Text 'Subtitle'
  $languageLabel.Text = Get-Text 'LanguageLabel'
  $officialButton.Text = Get-Text 'Official'
  $statusButton.Text = Get-Text 'Status'
  $loginButton.Text = Get-Text 'Login'
  $thirdPartyGroup.Text = Get-Text 'ThirdPartyLabel'
  $providerLabel.Text = Get-Text 'ThirdPartyLabel'
  $useThirdPartyButton.Text = Get-Text 'UseThirdParty'
  $editProvidersButton.Text = Get-Text 'EditProviders'
  $reloadProvidersButton.Text = Get-Text 'ReloadProviders'
  $launchCheck.Text = Get-Text 'Launch'
  $logLabel.Text = Get-Text 'Log'
  $instructionsGroup.Text = Get-Text 'InstructionsTitle'
  $instructionsText.Text = Get-Text 'InstructionsText'
}

function Invoke-ProviderAction([string]$Provider, [string]$ProviderId = '') {
  try {
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $actionPanel.Enabled = $false
    $thirdPartyGroup.Enabled = $false
    Add-Log (Format-Text 'Running' @($Provider))

    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$switchScript`" -Provider `"$Provider`" -Language `"$currentLanguage`""
    if (-not [string]::IsNullOrWhiteSpace($ProviderId)) {
      $safeProviderId = $ProviderId.Replace('"', '\"')
      $args += " -ProviderId `"$safeProviderId`""
    }
    if ($launchCheck.Checked -and $Provider -ne 'status') {
      $args += ' -Launch'
    }

    $result = Invoke-Capture $args
    if ($result.Output) {
      Add-Log $result.Output
    }
    if ($result.ExitCode -ne 0) {
      Add-Log (Format-Text 'ExitCode' @($result.ExitCode))
      [System.Windows.Forms.MessageBox]::Show($result.Output, (Get-Text 'AppTitle'), 'OK', 'Warning') | Out-Null
    }
  } catch {
    Add-Log $_.Exception.Message
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-Text 'AppTitle'), 'OK', 'Error') | Out-Null
  } finally {
    $actionPanel.Enabled = $true
    $thirdPartyGroup.Enabled = $true
    if ($providerBox.Items.Count -eq 0) {
      $providerBox.Enabled = $false
      $useThirdPartyButton.Enabled = $false
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
  }
}

function Invoke-SelectedThirdParty {
  if ($providerBox.SelectedIndex -lt 0 -or $script:providerItems.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show((Get-Text 'NoThirdPartySelected'), (Get-Text 'AppTitle'), 'OK', 'Warning') | Out-Null
    return
  }

  $selected = $script:providerItems[$providerBox.SelectedIndex]
  $providerId = Get-JsonProperty $selected 'id'
  Invoke-ProviderAction 'thirdparty' $providerId
}

function Edit-ProviderConfig {
  try {
    $path = Get-ProviderConfigPath -Create
    Add-Log (Get-Text 'OpeningProviderConfig')
    Start-Process -FilePath 'notepad.exe' -ArgumentList "`"$path`""
  } catch {
    Add-Log $_.Exception.Message
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-Text 'ProviderConfigTitle'), 'OK', 'Error') | Out-Null
  }
}

function Start-ChatGptLogin {
  $answer = [System.Windows.Forms.MessageBox]::Show(
    (Get-Text 'LoginConfirm'),
    (Get-Text 'LoginTitle'),
    'YesNo',
    'Question'
  )

  if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) {
    Add-Log (Get-Text 'LoginCanceled')
    return
  }

  if (-not (Test-Path -LiteralPath $loginScript)) {
    $message = Format-Text 'MissingHelper' @($loginScript)
    [System.Windows.Forms.MessageBox]::Show($message, (Get-Text 'AppTitle'), 'OK', 'Error') | Out-Null
    return
  }

  Add-Log (Get-Text 'OpeningLogin')
  Start-Process -FilePath 'cmd.exe' -ArgumentList "/k `"$loginScript`"" -WorkingDirectory $scriptDir
}

$form = New-Object System.Windows.Forms.Form
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(920, 750)
$form.MinimumSize = New-Object System.Drawing.Size(860, 700)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
$form.Font = New-Font 9

$title = New-Object System.Windows.Forms.Label
$title.Font = New-Font 18 ([System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 22)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Font = New-Font 9
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$subtitle.AutoSize = $false
$subtitle.Location = New-Object System.Drawing.Point(26, 58)
$subtitle.Size = New-Object System.Drawing.Size(594, 34)
$subtitle.Anchor = 'Top,Left,Right'
$form.Controls.Add($subtitle)

$languageLabel = New-Object System.Windows.Forms.Label
$languageLabel.Font = New-Font 9
$languageLabel.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
$languageLabel.AutoSize = $false
$languageLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$languageLabel.Location = New-Object System.Drawing.Point(620, 26)
$languageLabel.Size = New-Object System.Drawing.Size(90, 24)
$languageLabel.Anchor = 'Top,Right'
$form.Controls.Add($languageLabel)

$languageBox = New-Object System.Windows.Forms.ComboBox
$languageBox.DropDownStyle = 'DropDownList'
$languageBox.Location = New-Object System.Drawing.Point(720, 24)
$languageBox.Size = New-Object System.Drawing.Size(150, 24)
$languageBox.Anchor = 'Top,Right'
[void]$languageBox.Items.Add($Text['zh-CN'].LanguageZh)
[void]$languageBox.Items.Add($Text['en-US'].LanguageEn)
$languageBox.SelectedIndex = 0
$form.Controls.Add($languageBox)

function New-ActionButton([string]$Text) {
  $button = New-Object System.Windows.Forms.Button
  $button.Text = $Text
  $button.Font = New-Font 9.5 ([System.Drawing.FontStyle]::Bold)
  $button.Margin = New-Object System.Windows.Forms.Padding(6)
  $button.Dock = 'Fill'
  $button.FlatStyle = 'Flat'
  $button.BackColor = [System.Drawing.Color]::White
  $button.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
  $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
  return $button
}

$actionPanel = New-Object System.Windows.Forms.TableLayoutPanel
$actionPanel.Location = New-Object System.Drawing.Point(24, 108)
$actionPanel.Size = New-Object System.Drawing.Size(846, 58)
$actionPanel.ColumnCount = 3
$actionPanel.RowCount = 1
$actionPanel.Anchor = 'Top,Left,Right'
$actionPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 34))) | Out-Null
$actionPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 33))) | Out-Null
$actionPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 33))) | Out-Null
$actionPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
$form.Controls.Add($actionPanel)

$officialButton = New-ActionButton ''
$statusButton = New-ActionButton ''
$loginButton = New-ActionButton ''

$actionPanel.Controls.Add($officialButton, 0, 0)
$actionPanel.Controls.Add($statusButton, 1, 0)
$actionPanel.Controls.Add($loginButton, 2, 0)

$thirdPartyGroup = New-Object System.Windows.Forms.GroupBox
$thirdPartyGroup.Location = New-Object System.Drawing.Point(24, 184)
$thirdPartyGroup.Size = New-Object System.Drawing.Size(846, 88)
$thirdPartyGroup.Anchor = 'Top,Left,Right'
$thirdPartyGroup.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$thirdPartyGroup.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$form.Controls.Add($thirdPartyGroup)

$thirdPartyLayout = New-Object System.Windows.Forms.TableLayoutPanel
$thirdPartyLayout.Location = New-Object System.Drawing.Point(10, 26)
$thirdPartyLayout.Size = New-Object System.Drawing.Size(824, 40)
$thirdPartyLayout.ColumnCount = 5
$thirdPartyLayout.RowCount = 1
$thirdPartyLayout.Anchor = 'Top,Left,Right'
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 116))) | Out-Null
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 178))) | Out-Null
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 188))) | Out-Null
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 116))) | Out-Null
$thirdPartyGroup.Controls.Add($thirdPartyLayout)

$providerLabel = New-Object System.Windows.Forms.Label
$providerLabel.Font = New-Font 9
$providerLabel.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
$providerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$providerLabel.Dock = 'Fill'
$thirdPartyLayout.Controls.Add($providerLabel, 0, 0)

$providerBox = New-Object System.Windows.Forms.ComboBox
$providerBox.DropDownStyle = 'DropDownList'
$providerBox.Font = New-Font 9
$providerBox.Margin = New-Object System.Windows.Forms.Padding(4, 8, 8, 4)
$providerBox.Dock = 'Fill'
$thirdPartyLayout.Controls.Add($providerBox, 1, 0)

$useThirdPartyButton = New-ActionButton ''
$editProvidersButton = New-ActionButton ''
$reloadProvidersButton = New-ActionButton ''
$thirdPartyLayout.Controls.Add($useThirdPartyButton, 2, 0)
$thirdPartyLayout.Controls.Add($editProvidersButton, 3, 0)
$thirdPartyLayout.Controls.Add($reloadProvidersButton, 4, 0)

$launchCheck = New-Object System.Windows.Forms.CheckBox
$launchCheck.AutoSize = $true
$launchCheck.Location = New-Object System.Drawing.Point(30, 290)
$launchCheck.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
$form.Controls.Add($launchCheck)

$instructionsGroup = New-Object System.Windows.Forms.GroupBox
$instructionsGroup.Location = New-Object System.Drawing.Point(24, 324)
$instructionsGroup.Size = New-Object System.Drawing.Size(846, 142)
$instructionsGroup.Anchor = 'Top,Left,Right'
$instructionsGroup.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$instructionsGroup.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$form.Controls.Add($instructionsGroup)

$instructionsText = New-Object System.Windows.Forms.TextBox
$instructionsText.Multiline = $true
$instructionsText.ReadOnly = $true
$instructionsText.BorderStyle = 'None'
$instructionsText.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
$instructionsText.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
$instructionsText.Font = New-Font 9
$instructionsText.Location = New-Object System.Drawing.Point(12, 24)
$instructionsText.Size = New-Object System.Drawing.Size(820, 104)
$instructionsText.Anchor = 'Top,Bottom,Left,Right'
$instructionsGroup.Controls.Add($instructionsText)

$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$logLabel.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logLabel.AutoSize = $true
$logLabel.Location = New-Object System.Drawing.Point(26, 484)
$form.Controls.Add($logLabel)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.ReadOnly = $true
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$logBox.BorderStyle = 'FixedSingle'
$logBox.Location = New-Object System.Drawing.Point(24, 510)
$logBox.Size = New-Object System.Drawing.Size(846, 190)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($logBox)

$officialButton.Add_Click({ Invoke-ProviderAction 'official' })
$statusButton.Add_Click({ Invoke-ProviderAction 'status' })
$loginButton.Add_Click({ Start-ChatGptLogin })
$useThirdPartyButton.Add_Click({ Invoke-SelectedThirdParty })
$editProvidersButton.Add_Click({ Edit-ProviderConfig })
$reloadProvidersButton.Add_Click({ Load-Providers $true })
$languageBox.Add_SelectedIndexChanged({
  if ($languageBox.SelectedIndex -eq 1) {
    Set-Language 'en-US'
  } else {
    Set-Language 'zh-CN'
  }
})

$form.Add_Shown({
  Set-Language 'zh-CN'
  Load-Providers $false
  Add-Log (Get-Text 'Started')
  Invoke-ProviderAction 'status'
})

[void][System.Windows.Forms.Application]::Run($form)
