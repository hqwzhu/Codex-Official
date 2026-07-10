$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$switchScript = Join-Path $scriptDir 'Switch-CodexProvider.ps1'
$loginScript = Join-Path $scriptDir 'Login-ChatGPT.cmd'
$powershellExe = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$currentLanguage = 'zh-CN'

function ConvertFrom-Utf8Base64([string]$Value) {
  [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

$Text = @{
  'en-US' = @{
    AppTitle = 'Codex Provider Switcher'
    Subtitle = 'Switch between official ChatGPT account mode and CCswitch without mixing credentials.'
    LanguageLabel = 'Language'
    Official = 'Use Official ChatGPT'
    Ccswitch = 'Use CCswitch'
    Status = 'Connection Status'
    Login = 'Re-login ChatGPT'
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
    InstructionsText = "1. Click Connection Status first to check the active provider, FREEMODEL_API_KEY, and ChatGPT login state.`r`n2. Click Use Official ChatGPT for official account quota, or Use CCswitch for the third-party gateway.`r`n3. If official mode still shows API-key login, click Re-login ChatGPT and choose Sign in with ChatGPT.`r`n4. Restart any already-open Codex window after switching."
  }
  'zh-CN' = @{
    AppTitle = ConvertFrom-Utf8Base64 'Q29kZXgg6L+e5o6l5YiH5o2i5Zmo'
    Subtitle = ConvertFrom-Utf8Base64 '5LiA6ZSu5YiH5o2i5a6Y5pa5IENoYXRHUFQg6LSm5Y+35qih5byP5ZKMIENDc3dpdGNo77yM6YG/5YWN5Yet5o2u5re355So44CC'
    LanguageLabel = ConvertFrom-Utf8Base64 '6K+t6KiA'
    Official = ConvertFrom-Utf8Base64 '5L2/55So5a6Y5pa5IENoYXRHUFQ='
    Ccswitch = ConvertFrom-Utf8Base64 '5L2/55SoIENDc3dpdGNo'
    Status = ConvertFrom-Utf8Base64 '6L+e5o6l54q25oCB'
    Login = ConvertFrom-Utf8Base64 '6YeN5paw55m75b2VIENoYXRHUFQ='
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
    InstructionsText = ConvertFrom-Utf8Base64 'MS4g5YWI54K54oCc6L+e5o6l54q25oCB4oCd77yM56Gu6K6k5b2T5YmNIHByb3ZpZGVy44CBRlJFRU1PREVMX0FQSV9LRVkg5ZKMIENoYXRHUFQg55m75b2V54q25oCB44CCCjIuIOmcgOimgeWumOaWuemineW6puaXtueCueKAnOS9v+eUqOWumOaWuSBDaGF0R1BU4oCd77yb6ZyA6KaB56ys5LiJ5pa5572R5YWz5pe254K54oCc5L2/55SoIENDc3dpdGNo4oCd44CCCjMuIOWmguaenOWumOaWueaooeW8j+S7jeaYvuekuiBBUEkgS2V5IOeZu+W9le+8jOeCueKAnOmHjeaWsOeZu+W9lSBDaGF0R1BU4oCd77yM5bm26YCJ5oupIFNpZ24gaW4gd2l0aCBDaGF0R1BU44CCCjQuIOWIh+aNouWujOaIkOWQju+8jOmHjeWQr+W3suaJk+W8gOeahCBDb2RleCDnqpflj6PjgII='
  }
}

function Get-Text([string]$Key) {
  $Text[$currentLanguage][$Key]
}

function Format-Text([string]$Key, [object]$Value) {
  [string]::Format((Get-Text $Key), $Value)
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

function Set-Language([string]$Language) {
  $script:currentLanguage = $Language
  $form.Text = Get-Text 'AppTitle'
  $title.Text = Get-Text 'AppTitle'
  $subtitle.Text = Get-Text 'Subtitle'
  $languageLabel.Text = Get-Text 'LanguageLabel'
  $officialButton.Text = Get-Text 'Official'
  $ccswitchButton.Text = Get-Text 'Ccswitch'
  $statusButton.Text = Get-Text 'Status'
  $loginButton.Text = Get-Text 'Login'
  $launchCheck.Text = Get-Text 'Launch'
  $logLabel.Text = Get-Text 'Log'
  $instructionsGroup.Text = Get-Text 'InstructionsTitle'
  $instructionsText.Text = Get-Text 'InstructionsText'
}

function Invoke-ProviderAction([string]$Provider) {
  try {
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $buttonPanel.Enabled = $false
    Add-Log (Format-Text 'Running' $Provider)

    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$switchScript`" -Provider $Provider -Language `"$currentLanguage`""
    if ($launchCheck.Checked -and $Provider -ne 'status') {
      $args += ' -Launch'
    }

    $result = Invoke-Capture $args
    if ($result.Output) {
      Add-Log $result.Output
    }
    if ($result.ExitCode -ne 0) {
      Add-Log (Format-Text 'ExitCode' $result.ExitCode)
      [System.Windows.Forms.MessageBox]::Show($result.Output, (Get-Text 'AppTitle'), 'OK', 'Warning') | Out-Null
    }
  } catch {
    Add-Log $_.Exception.Message
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-Text 'AppTitle'), 'OK', 'Error') | Out-Null
  } finally {
    $buttonPanel.Enabled = $true
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
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
    $message = Format-Text 'MissingHelper' $loginScript
    [System.Windows.Forms.MessageBox]::Show($message, (Get-Text 'AppTitle'), 'OK', 'Error') | Out-Null
    return
  }

  Add-Log (Get-Text 'OpeningLogin')
  Start-Process -FilePath 'cmd.exe' -ArgumentList "/k `"$loginScript`"" -WorkingDirectory $scriptDir
}

$form = New-Object System.Windows.Forms.Form
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(920, 700)
$form.MinimumSize = New-Object System.Drawing.Size(840, 640)
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
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(26, 58)
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

$buttonPanel = New-Object System.Windows.Forms.TableLayoutPanel
$buttonPanel.Location = New-Object System.Drawing.Point(24, 104)
$buttonPanel.Size = New-Object System.Drawing.Size(846, 120)
$buttonPanel.ColumnCount = 2
$buttonPanel.RowCount = 2
$buttonPanel.Anchor = 'Top,Left,Right'
$buttonPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
$buttonPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
$buttonPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
$buttonPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
$form.Controls.Add($buttonPanel)

function New-ActionButton([string]$Text) {
  $button = New-Object System.Windows.Forms.Button
  $button.Text = $Text
  $button.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
  $button.Margin = New-Object System.Windows.Forms.Padding(6)
  $button.Dock = 'Fill'
  $button.FlatStyle = 'Flat'
  $button.BackColor = [System.Drawing.Color]::White
  $button.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
  $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
  return $button
}

$officialButton = New-ActionButton ''
$ccswitchButton = New-ActionButton ''
$statusButton = New-ActionButton ''
$loginButton = New-ActionButton ''

$buttonPanel.Controls.Add($officialButton, 0, 0)
$buttonPanel.Controls.Add($ccswitchButton, 1, 0)
$buttonPanel.Controls.Add($statusButton, 0, 1)
$buttonPanel.Controls.Add($loginButton, 1, 1)

$launchCheck = New-Object System.Windows.Forms.CheckBox
$launchCheck.AutoSize = $true
$launchCheck.Location = New-Object System.Drawing.Point(30, 238)
$launchCheck.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
$form.Controls.Add($launchCheck)

$instructionsGroup = New-Object System.Windows.Forms.GroupBox
$instructionsGroup.Location = New-Object System.Drawing.Point(24, 272)
$instructionsGroup.Size = New-Object System.Drawing.Size(846, 120)
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
$instructionsText.Size = New-Object System.Drawing.Size(820, 84)
$instructionsText.Anchor = 'Top,Bottom,Left,Right'
$instructionsGroup.Controls.Add($instructionsText)

$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$logLabel.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logLabel.AutoSize = $true
$logLabel.Location = New-Object System.Drawing.Point(26, 410)
$form.Controls.Add($logLabel)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.ReadOnly = $true
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$logBox.BorderStyle = 'FixedSingle'
$logBox.Location = New-Object System.Drawing.Point(24, 436)
$logBox.Size = New-Object System.Drawing.Size(846, 200)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($logBox)

$officialButton.Add_Click({ Invoke-ProviderAction 'official' })
$ccswitchButton.Add_Click({ Invoke-ProviderAction 'ccswitch' })
$statusButton.Add_Click({ Invoke-ProviderAction 'status' })
$loginButton.Add_Click({ Start-ChatGptLogin })
$languageBox.Add_SelectedIndexChanged({
  if ($languageBox.SelectedIndex -eq 1) {
    Set-Language 'en-US'
  } else {
    Set-Language 'zh-CN'
  }
})

$form.Add_Shown({
  Set-Language 'zh-CN'
  Add-Log (Get-Text 'Started')
  Invoke-ProviderAction 'status'
})

[void][System.Windows.Forms.Application]::Run($form)
