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
    AddProvider = 'Add Third-party Connection'
    EditProviders = 'Advanced Config'
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
    InstructionsText = "1. Click Connection Status first to confirm the current connection and login state.`r`n2. For official quota, click Use Official ChatGPT.`r`n3. For a third-party gateway, choose it from the list and click Use Selected Third-party.`r`n4. If your gateway is missing, click Add Third-party Connection, choose a template, enter the API key, and save.`r`n5. Restart any already-open Codex window after switching."
    ProvidersReloaded = 'Third-party connection list reloaded.'
    OpeningProviderConfig = 'Opening third-party provider config.'
    ProviderConfigTitle = 'Third-party provider config'
    NoThirdPartySelected = 'Select a third-party connection first.'
    ProviderConfigMissing = 'Third-party provider config file was not found: {0}'
    NoThirdPartyProviders = 'No third-party connections are configured.'
    AddProviderTitle = 'Add Third-party Connection'
    PresetLabel = 'Template'
    DisplayNameLabel = 'Display name'
    BaseUrlLabel = 'API URL'
    EnvKeyLabel = 'Environment variable'
    ApiKeyLabel = 'API Key (optional)'
    ModelLabel = 'Model'
    WireApiLabel = 'API type'
    Save = 'Save'
    Cancel = 'Cancel'
    ProviderAdded = 'Added third-party connection: {0}. If you entered an API key, it was saved to your Windows user environment variables.'
    ProviderExists = 'Connection already exists: {0}. If you entered an API key, the environment variable was updated.'
    RequiredFields = 'Fill in display name, API URL, environment variable, and model.'
    AddProviderHelp = 'Most users only need to choose a template and enter the API key. Advanced users can adjust the model and API type.'
    CustomPreset = 'Custom'
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
    AddProvider = ConvertFrom-Utf8Base64 '5re75Yqg56ys5LiJ5pa56L+e5o6l'
    EditProviders = ConvertFrom-Utf8Base64 '6auY57qn57yW6L6R6YWN572u'
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
    InstructionsText = ConvertFrom-Utf8Base64 'MS4g5YWI54K56L+e5o6l54q25oCB77yM56Gu6K6k5b2T5YmN6L+e5o6l5ZKM55m75b2V54q25oCB44CCDQoyLiDnlKjlrpjmlrnpop3luqbvvJrngrnkvb/nlKjlrpjmlrkgQ2hhdEdQVOOAgg0KMy4g55So56ys5LiJ5pa577ya5YWI5Zyo5LiL5ouJ5qGG6YCJ5oup77yM5YaN54K55L2/55So5omA6YCJ56ys5LiJ5pa544CCDQo0LiDmsqHmnInkvaDnmoTnrKzkuInmlrnvvJ/ngrnmt7vliqDnrKzkuInmlrnov57mjqXvvIzmjInmqKHmnb/loasgQVBJIEtleSDlkI7kv53lrZjjgIINCjUuIOWIh+aNouWQjumHjeWQr+W3suaJk+W8gOeahCBDb2RleCDnqpflj6PjgII='
    ProvidersReloaded = ConvertFrom-Utf8Base64 '56ys5LiJ5pa56L+e5o6l5YiX6KGo5bey5Yi35paw44CC'
    OpeningProviderConfig = ConvertFrom-Utf8Base64 '5q2j5Zyo5omT5byA56ys5LiJ5pa56L+e5o6l6YWN572u44CC'
    ProviderConfigTitle = ConvertFrom-Utf8Base64 '56ys5LiJ5pa56L+e5o6l6YWN572u'
    NoThirdPartySelected = ConvertFrom-Utf8Base64 '6K+35YWI6YCJ5oup5LiA5Liq56ys5LiJ5pa56L+e5o6l44CC'
    ProviderConfigMissing = ConvertFrom-Utf8Base64 '5om+5LiN5Yiw56ys5LiJ5pa56L+e5o6l6YWN572u5paH5Lu277yaezB9'
    NoThirdPartyProviders = ConvertFrom-Utf8Base64 '5pyq6YWN572u56ys5LiJ5pa56L+e5o6l44CC'
    AddProviderTitle = ConvertFrom-Utf8Base64 '5re75Yqg56ys5LiJ5pa56L+e5o6l'
    PresetLabel = ConvertFrom-Utf8Base64 '6L+e5o6l5qih5p2/'
    DisplayNameLabel = ConvertFrom-Utf8Base64 '5pi+56S65ZCN56ew'
    BaseUrlLabel = ConvertFrom-Utf8Base64 'QVBJIOWcsOWdgA=='
    EnvKeyLabel = ConvertFrom-Utf8Base64 '546v5aKD5Y+Y6YeP5ZCN'
    ApiKeyLabel = ConvertFrom-Utf8Base64 'QVBJIEtlee+8iOWPr+mAie+8iQ=='
    ModelLabel = ConvertFrom-Utf8Base64 '5qih5Z6L5ZCN56ew'
    WireApiLabel = ConvertFrom-Utf8Base64 '5o6l5Y+j57G75Z6L'
    Save = ConvertFrom-Utf8Base64 '5L+d5a2Y'
    Cancel = ConvertFrom-Utf8Base64 '5Y+W5raI'
    ProviderAdded = ConvertFrom-Utf8Base64 '5bey5re75Yqg56ys5LiJ5pa56L+e5o6l77yaezB944CC5aaC5p6c5aGr5YaZ5LqGIEFQSSBLZXnvvIzkuZ/lt7Lkv53lrZjliLDlvZPliY0gV2luZG93cyDnlKjmiLfnjq/looPlj5jph4/jgII='
    ProviderExists = ConvertFrom-Utf8Base64 '6L+e5o6l5bey5a2Y5Zyo77yaezB944CC5aaC5p6c5aGr5YaZ5LqGIEFQSSBLZXnvvIzlt7Lmm7TmlrDnjq/looPlj5jph4/jgII='
    RequiredFields = ConvertFrom-Utf8Base64 '6K+35aGr5YaZ5pi+56S65ZCN56ew44CBQVBJIOWcsOWdgOOAgeeOr+Wig+WPmOmHj+WQjeWSjOaooeWei+WQjeensOOAgg=='
    AddProviderHelp = ConvertFrom-Utf8Base64 '5pmu6YCa55So5oi35Y+q6ZyA6YCJ5oup5qih5p2/5bm25aGr5YWlIEFQSSBLZXnvvJvpq5jnuqfnlKjmiLflho3kv67mlLnmqKHlnovlkozmjqXlj6PnsbvlnovjgII='
    CustomPreset = ConvertFrom-Utf8Base64 '6Ieq5a6a5LmJ'
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

function Get-ProviderConfig {
  $path = Get-ProviderConfigPath -Create
  $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $config = $raw | ConvertFrom-Json
  if ($null -eq $config.providers) {
    return [pscustomobject]@{ providers = @() }
  }
  return $config
}

function Save-ProviderConfig([object[]]$Providers) {
  $path = Get-ProviderConfigPath -Create
  $config = [ordered]@{ providers = @($Providers) }
  $json = $config | ConvertTo-Json -Depth 8
  Set-Content -LiteralPath $path -Value $json -Encoding UTF8
}

function New-UniqueProviderId([string]$PreferredId, [object[]]$Providers) {
  $base = $PreferredId.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
  $base = $base.Trim('-')
  if ([string]::IsNullOrWhiteSpace($base)) {
    $base = 'provider'
  }

  $existing = @{}
  foreach ($item in $Providers) {
    $id = Get-JsonProperty $item 'id'
    if ($id) { $existing[$id] = $true }
  }

  if (-not $existing.ContainsKey($base)) {
    return $base
  }

  $index = 2
  do {
    $candidate = "$base-$index"
    $index++
  } while ($existing.ContainsKey($candidate))

  return $candidate
}

function Set-UserApiKey([string]$EnvKey, [string]$ApiKey) {
  if ([string]::IsNullOrWhiteSpace($ApiKey)) { return }
  [Environment]::SetEnvironmentVariable($EnvKey, $ApiKey, 'User')
  Set-Item -Path "Env:$EnvKey" -Value $ApiKey
}

function Select-ProviderById([string]$ProviderId) {
  for ($i = 0; $i -lt $script:providerItems.Count; $i++) {
    if ((Get-JsonProperty $script:providerItems[$i] 'id') -eq $ProviderId) {
      $providerBox.SelectedIndex = $i
      return
    }
  }
}

function Add-OrUpdateProvider([object]$Preset, [string]$DisplayName, [string]$BaseUrl, [string]$EnvKey, [string]$ApiKey, [string]$Model, [string]$WireApi) {
  if ([string]::IsNullOrWhiteSpace($DisplayName) -or [string]::IsNullOrWhiteSpace($BaseUrl) -or [string]::IsNullOrWhiteSpace($EnvKey) -or [string]::IsNullOrWhiteSpace($Model)) {
    throw (Get-Text 'RequiredFields')
  }

  $config = Get-ProviderConfig
  $providers = @($config.providers)
  $preferredId = Get-JsonProperty $Preset 'id' $DisplayName
  if ($preferredId -eq 'custom') {
    $preferredId = $DisplayName
  }
  $displayNameClean = $DisplayName.Trim()
  $envKeyClean = $EnvKey.Trim()
  $existingId = ''

  foreach ($item in $providers) {
    if ((Get-JsonProperty $item 'id') -eq $preferredId -or (Get-JsonProperty $item 'displayName') -eq $displayNameClean) {
      $existingId = Get-JsonProperty $item 'id'
      Set-UserApiKey $envKeyClean $ApiKey
      Add-Log (Format-Text 'ProviderExists' @($displayNameClean))
      [System.Windows.Forms.MessageBox]::Show((Format-Text 'ProviderExists' @($displayNameClean)), (Get-Text 'AppTitle'), 'OK', 'Information') | Out-Null
      Load-Providers $true
      Select-ProviderById $existingId
      return
    }
  }

  $id = New-UniqueProviderId $preferredId $providers
  $provider = [pscustomobject]([ordered]@{
    id = $id
    displayName = $displayNameClean
    modelProvider = $id
    baseUrl = $BaseUrl.Trim()
    envKey = $envKeyClean
    wireApi = $WireApi.Trim()
    model = $Model.Trim()
    modelReasoningEffort = (Get-JsonProperty $Preset 'reasoning' 'medium')
    serviceTier = (Get-JsonProperty $Preset 'serviceTier' 'auto')
    preferredAuthMethod = 'apikey'
  })

  Save-ProviderConfig (@($providers) + $provider)
  Set-UserApiKey $envKeyClean $ApiKey
  Add-Log (Format-Text 'ProviderAdded' @($displayNameClean))
  [System.Windows.Forms.MessageBox]::Show((Format-Text 'ProviderAdded' @($displayNameClean)), (Get-Text 'AppTitle'), 'OK', 'Information') | Out-Null
  Load-Providers $true
  Select-ProviderById $id
}

function Show-AddProviderDialog {
  $dialog = New-Object System.Windows.Forms.Form
  $dialog.Text = Get-Text 'AddProviderTitle'
  $dialog.StartPosition = 'CenterParent'
  $dialog.Size = New-Object System.Drawing.Size(620, 430)
  $dialog.MinimumSize = New-Object System.Drawing.Size(580, 400)
  $dialog.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252)
  $dialog.Font = New-Font 9

  $help = New-Object System.Windows.Forms.Label
  $help.Text = Get-Text 'AddProviderHelp'
  $help.ForeColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
  $help.Location = New-Object System.Drawing.Point(22, 18)
  $help.Size = New-Object System.Drawing.Size(560, 34)
  $dialog.Controls.Add($help)

  $layout = New-Object System.Windows.Forms.TableLayoutPanel
  $layout.Location = New-Object System.Drawing.Point(22, 62)
  $layout.Size = New-Object System.Drawing.Size(560, 250)
  $layout.ColumnCount = 2
  $layout.RowCount = 7
  $layout.Anchor = 'Top,Left,Right'
  $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 150))) | Out-Null
  $layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
  for ($i = 0; $i -lt 7; $i++) {
    $layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 34))) | Out-Null
  }
  $dialog.Controls.Add($layout)

  function New-DialogLabel([string]$Text) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $label.Dock = 'Fill'
    $label.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
    return $label
  }

  function New-DialogTextBox {
    $box = New-Object System.Windows.Forms.TextBox
    $box.Dock = 'Fill'
    $box.Margin = New-Object System.Windows.Forms.Padding(0, 5, 0, 4)
    return $box
  }

  $presetBox = New-Object System.Windows.Forms.ComboBox
  $presetBox.DropDownStyle = 'DropDownList'
  $presetBox.Dock = 'Fill'
  $presetBox.Margin = New-Object System.Windows.Forms.Padding(0, 5, 0, 4)

  $nameBox = New-DialogTextBox
  $baseUrlBox = New-DialogTextBox
  $envKeyBox = New-DialogTextBox
  $apiKeyBox = New-DialogTextBox
  $apiKeyBox.UseSystemPasswordChar = $true
  $modelBox = New-DialogTextBox

  $wireApiBox = New-Object System.Windows.Forms.ComboBox
  $wireApiBox.DropDownStyle = 'DropDownList'
  $wireApiBox.Dock = 'Fill'
  $wireApiBox.Margin = New-Object System.Windows.Forms.Padding(0, 5, 0, 4)
  [void]$wireApiBox.Items.Add('responses')
  [void]$wireApiBox.Items.Add('chat')
  $wireApiBox.SelectedIndex = 0

  $layout.Controls.Add((New-DialogLabel (Get-Text 'PresetLabel')), 0, 0)
  $layout.Controls.Add($presetBox, 1, 0)
  $layout.Controls.Add((New-DialogLabel (Get-Text 'DisplayNameLabel')), 0, 1)
  $layout.Controls.Add($nameBox, 1, 1)
  $layout.Controls.Add((New-DialogLabel (Get-Text 'BaseUrlLabel')), 0, 2)
  $layout.Controls.Add($baseUrlBox, 1, 2)
  $layout.Controls.Add((New-DialogLabel (Get-Text 'EnvKeyLabel')), 0, 3)
  $layout.Controls.Add($envKeyBox, 1, 3)
  $layout.Controls.Add((New-DialogLabel (Get-Text 'ApiKeyLabel')), 0, 4)
  $layout.Controls.Add($apiKeyBox, 1, 4)
  $layout.Controls.Add((New-DialogLabel (Get-Text 'ModelLabel')), 0, 5)
  $layout.Controls.Add($modelBox, 1, 5)
  $layout.Controls.Add((New-DialogLabel (Get-Text 'WireApiLabel')), 0, 6)
  $layout.Controls.Add($wireApiBox, 1, 6)

  $presets = @(
    [pscustomobject]@{ label = 'CCswitch / Freemodel'; id = 'freemodel'; displayName = 'CCswitch / Freemodel'; baseUrl = 'https://vip-sg.freemodel.dev'; envKey = 'FREEMODEL_API_KEY'; model = 'gpt-5.5'; wireApi = 'responses'; reasoning = 'xhigh'; serviceTier = 'fast' },
    [pscustomobject]@{ label = 'OpenRouter'; id = 'openrouter'; displayName = 'OpenRouter'; baseUrl = 'https://openrouter.ai/api/v1'; envKey = 'OPENROUTER_API_KEY'; model = '~openai/gpt-latest'; wireApi = 'chat'; reasoning = 'high'; serviceTier = 'auto' },
    [pscustomobject]@{ label = 'SiliconFlow / ' + (ConvertFrom-Utf8Base64 '56Gu5Z+65rWB5Yqo'); id = 'siliconflow'; displayName = 'SiliconFlow'; baseUrl = 'https://api.siliconflow.cn/v1'; envKey = 'SILICONFLOW_API_KEY'; model = 'Pro/zai-org/GLM-4.7'; wireApi = 'chat'; reasoning = 'medium'; serviceTier = 'auto' },
    [pscustomobject]@{ label = Get-Text 'CustomPreset'; id = 'custom'; displayName = ''; baseUrl = ''; envKey = ''; model = ''; wireApi = 'responses'; reasoning = 'medium'; serviceTier = 'auto' }
  )

  foreach ($preset in $presets) {
    [void]$presetBox.Items.Add((Get-JsonProperty $preset 'label'))
  }

  $applyPreset = {
    if ($presetBox.SelectedIndex -lt 0) { return }
    $selectedPreset = $presets[$presetBox.SelectedIndex]
    $nameBox.Text = Get-JsonProperty $selectedPreset 'displayName'
    $baseUrlBox.Text = Get-JsonProperty $selectedPreset 'baseUrl'
    $envKeyBox.Text = Get-JsonProperty $selectedPreset 'envKey'
    $modelBox.Text = Get-JsonProperty $selectedPreset 'model'
    $wireApi = Get-JsonProperty $selectedPreset 'wireApi' 'responses'
    $wireApiBox.SelectedIndex = [Math]::Max(0, $wireApiBox.Items.IndexOf($wireApi))
  }

  $presetBox.Add_SelectedIndexChanged($applyPreset)
  $presetBox.SelectedIndex = 0

  $saveButton = New-ActionButton ''
  $saveButton.Text = Get-Text 'Save'
  $cancelButton = New-ActionButton ''
  $cancelButton.Text = Get-Text 'Cancel'

  $buttonLayout = New-Object System.Windows.Forms.TableLayoutPanel
  $buttonLayout.Location = New-Object System.Drawing.Point(322, 328)
  $buttonLayout.Size = New-Object System.Drawing.Size(260, 46)
  $buttonLayout.Anchor = 'Right,Bottom'
  $buttonLayout.ColumnCount = 2
  $buttonLayout.RowCount = 1
  $buttonLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
  $buttonLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
  $buttonLayout.Controls.Add($cancelButton, 0, 0)
  $buttonLayout.Controls.Add($saveButton, 1, 0)
  $dialog.Controls.Add($buttonLayout)

  $cancelButton.Add_Click({ $dialog.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $dialog.Close() })
  $saveButton.Add_Click({
    try {
      $selectedPreset = $presets[$presetBox.SelectedIndex]
      Add-OrUpdateProvider $selectedPreset $nameBox.Text $baseUrlBox.Text $envKeyBox.Text $apiKeyBox.Text $modelBox.Text $wireApiBox.Text
      $dialog.DialogResult = [System.Windows.Forms.DialogResult]::OK
      $dialog.Close()
    } catch {
      [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-Text 'AddProviderTitle'), 'OK', 'Warning') | Out-Null
    }
  })

  [void]$dialog.ShowDialog($form)
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
  $addProviderButton.Text = Get-Text 'AddProvider'
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
$form.Size = New-Object System.Drawing.Size(920, 800)
$form.MinimumSize = New-Object System.Drawing.Size(860, 760)
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
$thirdPartyGroup.Size = New-Object System.Drawing.Size(846, 126)
$thirdPartyGroup.Anchor = 'Top,Left,Right'
$thirdPartyGroup.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$thirdPartyGroup.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$form.Controls.Add($thirdPartyGroup)

$thirdPartyLayout = New-Object System.Windows.Forms.TableLayoutPanel
$thirdPartyLayout.Location = New-Object System.Drawing.Point(10, 26)
$thirdPartyLayout.Size = New-Object System.Drawing.Size(824, 84)
$thirdPartyLayout.ColumnCount = 4
$thirdPartyLayout.RowCount = 2
$thirdPartyLayout.Anchor = 'Top,Left,Right'
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 116))) | Out-Null
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 184))) | Out-Null
$thirdPartyLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 166))) | Out-Null
$thirdPartyLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
$thirdPartyLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50))) | Out-Null
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
$thirdPartyLayout.SetColumnSpan($providerBox, 2)

$useThirdPartyButton = New-ActionButton ''
$addProviderButton = New-ActionButton ''
$editProvidersButton = New-ActionButton ''
$reloadProvidersButton = New-ActionButton ''
$thirdPartyLayout.Controls.Add($useThirdPartyButton, 3, 0)
$thirdPartyLayout.Controls.Add($addProviderButton, 0, 1)
$thirdPartyLayout.SetColumnSpan($addProviderButton, 2)
$thirdPartyLayout.Controls.Add($editProvidersButton, 2, 1)
$thirdPartyLayout.Controls.Add($reloadProvidersButton, 3, 1)

$launchCheck = New-Object System.Windows.Forms.CheckBox
$launchCheck.AutoSize = $true
$launchCheck.Location = New-Object System.Drawing.Point(30, 328)
$launchCheck.ForeColor = [System.Drawing.Color]::FromArgb(51, 65, 85)
$form.Controls.Add($launchCheck)

$instructionsGroup = New-Object System.Windows.Forms.GroupBox
$instructionsGroup.Location = New-Object System.Drawing.Point(24, 362)
$instructionsGroup.Size = New-Object System.Drawing.Size(846, 160)
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
$instructionsText.Size = New-Object System.Drawing.Size(820, 124)
$instructionsText.Anchor = 'Top,Bottom,Left,Right'
$instructionsGroup.Controls.Add($instructionsText)

$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$logLabel.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logLabel.AutoSize = $true
$logLabel.Location = New-Object System.Drawing.Point(26, 540)
$form.Controls.Add($logLabel)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.ReadOnly = $true
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$logBox.BorderStyle = 'FixedSingle'
$logBox.Location = New-Object System.Drawing.Point(24, 566)
$logBox.Size = New-Object System.Drawing.Size(846, 184)
$logBox.Anchor = 'Top,Bottom,Left,Right'
$form.Controls.Add($logBox)

$officialButton.Add_Click({ Invoke-ProviderAction 'official' })
$statusButton.Add_Click({ Invoke-ProviderAction 'status' })
$loginButton.Add_Click({ Start-ChatGptLogin })
$useThirdPartyButton.Add_Click({ Invoke-SelectedThirdParty })
$addProviderButton.Add_Click({ Show-AddProviderDialog })
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
