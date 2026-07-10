$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$switchScript = Join-Path $scriptDir 'Switch-CodexProvider.ps1'
$loginScript = Join-Path $scriptDir 'Login-ChatGPT.cmd'
$powershellExe = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'

function New-Font([float]$Size, [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular) {
  return New-Object System.Drawing.Font('Segoe UI', $Size, $Style)
}

function Add-Log([string]$Text) {
  $timestamp = Get-Date -Format 'HH:mm:ss'
  $logBox.AppendText("[$timestamp] $Text`r`n")
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

function Invoke-ProviderAction([string]$Provider) {
  try {
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $buttonPanel.Enabled = $false
    Add-Log "Running provider action: $Provider"

    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$switchScript`" -Provider $Provider"
    if ($launchCheck.Checked -and $Provider -ne 'status') {
      $args += ' -Launch'
    }

    $result = Invoke-Capture $args
    if ($result.Output) {
      Add-Log $result.Output
    }
    if ($result.ExitCode -ne 0) {
      Add-Log "Exit code: $($result.ExitCode)"
      [System.Windows.Forms.MessageBox]::Show($result.Output, 'Codex Provider Switcher', 'OK', 'Warning') | Out-Null
    }
  } catch {
    Add-Log $_.Exception.Message
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Codex Provider Switcher', 'OK', 'Error') | Out-Null
  } finally {
    $buttonPanel.Enabled = $true
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
  }
}

function Start-ChatGptLogin {
  $answer = [System.Windows.Forms.MessageBox]::Show(
    'This will log Codex out of the stored API-key login and start ChatGPT account login. Continue?',
    'ChatGPT account login',
    'YesNo',
    'Question'
  )

  if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) {
    Add-Log 'ChatGPT login canceled.'
    return
  }

  if (-not (Test-Path -LiteralPath $loginScript)) {
    [System.Windows.Forms.MessageBox]::Show("Missing login helper: $loginScript", 'Codex Provider Switcher', 'OK', 'Error') | Out-Null
    return
  }

  Add-Log 'Opening ChatGPT login helper window.'
  Start-Process -FilePath 'cmd.exe' -ArgumentList "/k `"$loginScript`"" -WorkingDirectory $scriptDir
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Codex Provider Switcher'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(720, 520)
$form.MinimumSize = New-Object System.Drawing.Size(640, 460)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
$form.Font = New-Font 9

$title = New-Object System.Windows.Forms.Label
$title.Text = 'Codex Provider Switcher'
$title.Font = New-Font 18 ([System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 22)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Switch between official ChatGPT account mode and CCswitch without mixing credentials.'
$subtitle.Font = New-Font 9
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(26, 58)
$form.Controls.Add($subtitle)

$buttonPanel = New-Object System.Windows.Forms.TableLayoutPanel
$buttonPanel.Location = New-Object System.Drawing.Point(24, 94)
$buttonPanel.Size = New-Object System.Drawing.Size(656, 120)
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

$officialButton = New-ActionButton 'Use Official ChatGPT'
$ccswitchButton = New-ActionButton 'Use CCswitch'
$statusButton = New-ActionButton 'Connection Status'
$loginButton = New-ActionButton 'Re-login ChatGPT'

$buttonPanel.Controls.Add($officialButton, 0, 0)
$buttonPanel.Controls.Add($ccswitchButton, 1, 0)
$buttonPanel.Controls.Add($statusButton, 0, 1)
$buttonPanel.Controls.Add($loginButton, 1, 1)

$launchCheck = New-Object System.Windows.Forms.CheckBox
$launchCheck.Text = 'Launch Codex after switching'
$launchCheck.AutoSize = $true
$launchCheck.Location = New-Object System.Drawing.Point(30, 228)
$launchCheck.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
$form.Controls.Add($launchCheck)

$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Text = 'Log'
$logLabel.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$logLabel.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logLabel.AutoSize = $true
$logLabel.Location = New-Object System.Drawing.Point(26, 264)
$form.Controls.Add($logLabel)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.ReadOnly = $true
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$logBox.BorderStyle = 'FixedSingle'
$logBox.Location = New-Object System.Drawing.Point(24, 290)
$logBox.Size = New-Object System.Drawing.Size(656, 170)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($logBox)

$officialButton.Add_Click({ Invoke-ProviderAction 'official' })
$ccswitchButton.Add_Click({ Invoke-ProviderAction 'ccswitch' })
$statusButton.Add_Click({ Invoke-ProviderAction 'status' })
$loginButton.Add_Click({ Start-ChatGptLogin })

$form.Add_Shown({
  Add-Log 'Application started.'
  Invoke-ProviderAction 'status'
})

[void][System.Windows.Forms.Application]::Run($form)
