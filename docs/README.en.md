# Codex Provider Switcher

Codex Provider Switcher is a Windows desktop app that lets normal AI users switch Codex between:

- Official ChatGPT account mode.
- Third-party OpenAI-compatible gateway mode.

The default third-party provider is `CCswitch / Freemodel`. The app can also add OpenRouter, private gateways, or other services that support the Responses API.

## Creator

ENHE AI | Developed by Enhe Intelligent Technology Studio | Website: [https://www.enhe-tech.com.cn](https://www.enhe-tech.com.cn)

## Simple Workflow

1. Open the Desktop shortcut `Codex Provider Switcher`.
2. Click `Connection Status` to see what Codex is using now.
3. To use official quota, click `Use Official ChatGPT`.
4. To use a third-party gateway, choose it from `Third-party connection`, then click `Use Selected Third-party`.
5. If your gateway is missing, click `Add Third-party Connection`, choose a template, enter the API key and model name, then save.
6. Existing tasks keep their original provider. Fully exit Codex, reopen it, and create a new task.

Normal users do not need to edit `providers.json`. `Advanced Config` is for users who want to edit JSON manually.

## Pain Point

Manual switching usually requires:

- Editing `%USERPROFILE%\.codex\config.toml`.
- Setting API key environment variables.
- Checking whether Codex is using ChatGPT login or API-key login.
- Restoring backups when a config edit breaks.

This app turns those steps into buttons and a guided form so official credentials and third-party keys do not get mixed.

## Install

Requirements:

- Windows 10 or Windows 11.
- Codex CLI installed and available in `PATH`.
- For official mode: Codex logged in with `Sign in with ChatGPT`.

Normal users can install by double-clicking either file in the project folder:

- `一键安装.cmd`
- `Install.cmd`

If Windows blocks double-click scripts, open PowerShell in the project folder and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

The installer creates:

- Desktop shortcut: `Codex Provider Switcher`.
- Start menu shortcut: `Codex Provider Switcher`.
- Installed files under `%USERPROFILE%\.codex\provider-switch`.
- Provider config file: `%USERPROFILE%\.codex\provider-switch\providers.json`.

Upgrade installs do not overwrite an existing `providers.json`.

## Add a Third-party Gateway

Recommended path:

1. Open the app.
2. Click `Add Third-party Connection`.
3. Choose `CCswitch / Freemodel`, `OpenRouter`, or `Custom`.
4. Enter the API key. The key is saved only to the current Windows user's environment variables, not to GitHub.
5. Confirm `API URL`, `Environment variable`, `Model`, and `API type`.
6. Click `Save`.
7. Select the new connection and click `Use Selected Third-party`.

Common fields:

- `API URL`: API endpoint from the gateway.
- `Environment variable`: variable name that stores the API key, such as `OPENROUTER_API_KEY`.
- `Model`: model name required by the gateway.
- `API type`: current Codex custom providers require `responses`.

Built-in templates prefill common public parameters, but the final model name should still match the model available in your own gateway account.

## Advanced Config

Advanced users can edit:

```text
%USERPROFILE%\.codex\provider-switch\providers.json
```

Example:

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

After editing, click `Reload List` in the app.

## Official Account Mode

Click `Use Official ChatGPT` to switch Codex back to the official `openai` provider and ChatGPT account login mode.

If the status still shows API-key login, click `Re-login ChatGPT`, then choose `Sign in with ChatGPT` in the terminal.

## Uninstall

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

Normal users can also uninstall by double-clicking `一键卸载.cmd` or `Uninstall.cmd`.

The uninstaller removes the app shortcut and installed app files. It does not remove Codex `config.toml`, environment variables, or login credentials.

## PDF Guide

Chinese PDF guide:

```text
docs\USER_GUIDE.zh-CN.pdf
```
