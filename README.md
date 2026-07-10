# Codex Provider Switcher / Codex 连接切换器

Codex Provider Switcher is a small Windows desktop utility for one-click switching between official OpenAI / ChatGPT account mode and configurable third-party OpenAI-compatible providers.

Codex Provider Switcher 是一个 Windows 本地小工具，用来一键切换 Codex 的 OpenAI 官方 / ChatGPT 账号连接，以及可配置的第三方 OpenAI-compatible 网关连接。

## What It Does / 项目作用

It gives you one app window for the common Codex connection actions:

- Default Chinese UI with a `中文 / English` language switcher.
- `Use Official ChatGPT`: switch Codex to the official `openai` provider and ChatGPT account login.
- Third-party provider selector: choose CCswitch/Freemodel, OpenRouter, SiliconFlow, or another configured gateway.
- `Connection Status`: check the active provider, third-party key availability, and login state.
- `Re-login ChatGPT`: log out of API-key auth and start the ChatGPT account login flow.
- Built-in instructions panel with the recommended operation steps.

它把常用 Codex 连接动作整合到一个应用窗口里：

- 默认中文界面，并支持 `中文 / English` 一键切换。
- `使用官方 ChatGPT`：切换到官方 ChatGPT 账号通道。
- 第三方连接下拉框：可选择 CCswitch/Freemodel、OpenRouter、硅基流动或其他已配置网关。
- `连接状态`：查看当前连接、第三方 Key 是否存在、Codex 登录状态。
- `重新登录 ChatGPT`：退出 API Key 登录并重新选择 ChatGPT 账号登录。
- 界面内置“使用说明”，直接显示推荐操作步骤。

## Pain Point / 痛点

Many Codex users need more than one connection mode:

- Official ChatGPT account mode for Codex quota included in a ChatGPT plan.
- Third-party API gateway mode for CCswitch, OpenRouter, SiliconFlow, private gateways, or other OpenAI-compatible services.

Manual switching means editing `~/.codex/config.toml`, checking environment variables, and sometimes changing login state. It is easy to mix credentials, use the wrong provider, or break Codex with a small config mistake.

很多 Codex 用户会同时需要多种连接：

- 官方 ChatGPT 账号模式：使用 ChatGPT 套餐里的 Codex 使用额度。
- 第三方 API 网关模式：使用 CCswitch、OpenRouter、硅基流动、私有网关或其他 OpenAI-compatible 服务。

如果手动切换，就要改 `~/.codex/config.toml`、检查环境变量，有时还要处理登录状态。这个过程容易混用凭据、切错 provider，或者因为配置小错误导致 Codex 无法启动。

## Solution / 解决方案

The app keeps official account mode and third-party provider mode separate:

- Official mode uses Codex's built-in `openai` provider and ChatGPT account login.
- Third-party mode is read from `providers.json`; the default entry remains `CCswitch / Freemodel`.
- Each provider can define `baseUrl`, `envKey`, `wireApi`, `model`, reasoning effort, service tier, and auth method.
- Every switch creates a config backup under `%USERPROFILE%\.codex\provider-switch\backups`.
- The repository does not store API keys, login tokens, or local backups.

这个工具把官方账号模式和第三方连接模式隔离：

- 官方模式使用 Codex 内置 `openai` provider 和 ChatGPT 账号登录。
- 第三方模式从 `providers.json` 读取；默认仍保留 `CCswitch / Freemodel`。
- 每个第三方可以配置 `baseUrl`、`envKey`、`wireApi`、`model`、reasoning effort、service tier 和认证方式。
- 每次切换都会备份配置到 `%USERPROFILE%\.codex\provider-switch\backups`。
- 仓库不保存 API Key、登录 token 或本机备份。

## Download / 下载

Clone with Git:

```powershell
git clone https://github.com/hqwzhu/Codex-Official.git
cd Codex-Official
```

Or download ZIP from GitHub:

1. Open `https://github.com/hqwzhu/Codex-Official`.
2. Click `Code`.
3. Click `Download ZIP`.
4. Extract the ZIP.

也可以在 GitHub 页面点击 `Code`，选择 `Download ZIP` 下载并解压。

## Install / 安装

Requirements / 前置要求：

- Windows 10 or Windows 11.
- Codex CLI installed and available as `codex`.
- For third-party mode, set the provider's API key as a Windows environment variable, such as `FREEMODEL_API_KEY`, `OPENROUTER_API_KEY`, or `SILICONFLOW_API_KEY`.
- For official mode, use `Sign in with ChatGPT` in Codex.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

The installer creates:

- Desktop shortcut: `Codex Provider Switcher`.
- Start menu shortcut: `Codex Provider Switcher`.
- Installed app files under `%USERPROFILE%\.codex\provider-switch`.
- Editable provider config: `%USERPROFILE%\.codex\provider-switch\providers.json`.

安装后会创建桌面和开始菜单快捷方式，名称都是 `Codex Provider Switcher`，并生成可编辑的第三方配置文件 `providers.json`。

## Configure Providers / 配置第三方连接

Open the app and click `编辑第三方连接` / `Edit Third-party Connections`, or edit:

```text
%USERPROFILE%\.codex\provider-switch\providers.json
```

Default provider:

```json
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
```

After editing `providers.json`, click `刷新列表` / `Reload List`.

第三方网关需要兼容 Codex 当前使用的 `wireApi` 和模型配置。不同网关可能需要 `responses` 或 `chat`，请按网关文档调整。

## Usage / 使用

Open `Codex Provider Switcher`.

- Click `使用官方 ChatGPT` / `Use Official ChatGPT` to use official OpenAI / ChatGPT account mode.
- Select a third-party connection, then click `使用所选第三方` / `Use Selected Third-party`.
- Click `连接状态` / `Connection Status` to inspect the current state.
- Click `重新登录 ChatGPT` / `Re-login ChatGPT` if Codex still shows API-key login and you want to restore ChatGPT account login.

打开 `Codex Provider Switcher` 后，根据需要点击对应按钮。切换完成后，重启已经打开的 Codex 窗口，让 Codex 重新读取配置。

## More Docs / 更多说明

- [English documentation](docs/README.en.md)
- [中文说明](docs/README.zh-CN.md)

## Uninstall / 卸载

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

Uninstalling removes the app files and shortcuts only. It does not delete your Codex config, environment variables, or login credentials.

卸载只删除应用文件和快捷方式，不删除你的 Codex 配置、环境变量或登录凭据。
