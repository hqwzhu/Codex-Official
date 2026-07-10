# Codex Provider Switcher

Codex Provider Switcher is a small Windows desktop utility for switching Codex between:

- Official OpenAI / ChatGPT account mode.
- Configurable third-party OpenAI-compatible API gateways.

The default third-party entry is still `CCswitch / Freemodel`, but you can add OpenRouter, SiliconFlow, private gateways, or other compatible services in `providers.json`.

## Pain Point

Codex can be used with different authentication paths:

- Official ChatGPT account login, which uses the Codex access included in a ChatGPT plan.
- API-key based custom providers, such as CCswitch, Freemodel, OpenRouter, SiliconFlow, or a private gateway.

Without a switcher, users often edit `~/.codex/config.toml` manually, change environment variables by hand, or overwrite the wrong credential. This is slow and risky: one typo can break Codex startup, and mixing official and third-party credentials can make it unclear which account is being used.

## Solution

This project adds a local GUI app with buttons and a provider selector:

- `Use Official ChatGPT`: switch to official ChatGPT account mode.
- `Third-party connection`: choose a configured gateway.
- `Use Selected Third-party`: switch to the selected third-party provider.
- `Connection Status`: check the current provider, key availability, and Codex login state.
- `Re-login ChatGPT`: restart the official ChatGPT account login flow.
- `Edit Third-party Connections`: open `providers.json`.
- `Reload List`: reload the provider selector after saving `providers.json`.

The app updates only the active Codex provider settings, creates backups before switching, and keeps credentials separate:

- Official mode uses Codex's built-in `openai` provider and ChatGPT account login.
- Third-party mode reads the selected provider from `providers.json`.
- API keys stay in Windows environment variables such as `FREEMODEL_API_KEY`, `OPENROUTER_API_KEY`, or `SILICONFLOW_API_KEY`.
- The GUI is bilingual. It opens in Chinese by default and can switch to English from the language selector.
- The GUI includes an instructions panel with the recommended operation steps.

No API key is stored in this repository.

## Download

Option 1: clone with Git.

```powershell
git clone https://github.com/hqwzhu/Codex-Official.git
cd Codex-Official
```

Option 2: download ZIP from GitHub.

1. Open `https://github.com/hqwzhu/Codex-Official`.
2. Click `Code`.
3. Click `Download ZIP`.
4. Extract the ZIP.

## Install

Requirements:

- Windows 10 or Windows 11.
- Codex CLI installed and available in `PATH`.
- For third-party mode: the provider API key configured in the user or machine environment.
- For official mode: Codex logged in with `Sign in with ChatGPT`.

Run the installer from the project folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

The installer creates:

- Desktop shortcut: `Codex Provider Switcher`.
- Start menu shortcut: `Codex Provider Switcher`.
- Installed files under `%USERPROFILE%\.codex\provider-switch`.
- Editable provider config: `%USERPROFILE%\.codex\provider-switch\providers.json`.

Upgrade installs do not overwrite an existing `providers.json`.

## Configure Providers

Open the app and click `Edit Third-party Connections`, or edit:

```text
%USERPROFILE%\.codex\provider-switch\providers.json
```

Config structure:

```json
{
  "providers": [
    {
      "id": "freemodel",
      "displayName": "CCswitch / Freemodel",
      "modelProvider": "freemodel",
      "baseUrl": "https://vip-sg.freemodel.dev",
      "envKey": "FREEMODEL_API_KEY",
      "wireApi": "responses",
      "model": "gpt-5.5",
      "modelReasoningEffort": "xhigh",
      "serviceTier": "fast",
      "preferredAuthMethod": "apikey"
    }
  ]
}
```

Fields:

- `id`: internal identifier. Use letters, numbers, and hyphens.
- `displayName`: name shown in the app.
- `modelProvider`: provider name written to Codex `config.toml`.
- `baseUrl`: third-party gateway API URL.
- `envKey`: Windows environment variable that stores the API key. The app stores only the variable name, not the key.
- `wireApi`: Codex wire protocol, commonly `responses` or `chat`.
- `model`: model name used by the provider.
- `modelReasoningEffort`, `serviceTier`, `preferredAuthMethod`: related Codex top-level settings.

After editing, save the file and click `Reload List` in the app.

### OpenRouter Example

```json
{
  "id": "openrouter",
  "displayName": "OpenRouter",
  "modelProvider": "openrouter",
  "baseUrl": "https://openrouter.ai/api/v1",
  "envKey": "OPENROUTER_API_KEY",
  "wireApi": "chat",
  "model": "openai/gpt-4.1",
  "modelReasoningEffort": "medium",
  "serviceTier": "auto",
  "preferredAuthMethod": "apikey"
}
```

### SiliconFlow Example

```json
{
  "id": "siliconflow",
  "displayName": "SiliconFlow",
  "modelProvider": "siliconflow",
  "baseUrl": "https://api.siliconflow.cn/v1",
  "envKey": "SILICONFLOW_API_KEY",
  "wireApi": "chat",
  "model": "Qwen/Qwen2.5-Coder-32B-Instruct",
  "modelReasoningEffort": "medium",
  "serviceTier": "auto",
  "preferredAuthMethod": "apikey"
}
```

Third-party gateways must be compatible with the `wireApi` and model settings Codex uses. Some gateways need `responses`, others need `chat`; follow the provider's documentation.

## Usage

Open `Codex Provider Switcher` from the Desktop or Start menu.

- Use the language selector in the top-right corner to switch between Chinese and English.
- Click `Connection Status` to check the current provider, key availability, and Codex login state.
- Click `使用官方 ChatGPT` / `Use Official ChatGPT` to switch Codex to the official OpenAI provider and ChatGPT account login mode.
- Select a provider in `Third-party connection`, then click `使用所选第三方` / `Use Selected Third-party`.
- Click `重新登录 ChatGPT` / `Re-login ChatGPT` if Codex still shows an API-key login and you want to restore official ChatGPT account login.

After switching, restart any already-open Codex window so it reloads `config.toml`.

## Uninstall

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

The uninstaller removes the app shortcut and installed app files. It does not remove your Codex `config.toml`, environment variables, or Codex login credentials.
