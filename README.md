# Codex Provider Switcher / Codex 连接切换器

Codex Provider Switcher is a Windows desktop app for one-click switching between official ChatGPT account mode and third-party OpenAI-compatible gateways.

Codex Provider Switcher 是一个 Windows 桌面应用，用来一键切换 Codex 的官方 ChatGPT 账号连接和第三方 OpenAI-compatible 网关连接。

## Creator / 创作者

ENHE AI | Developed by Enhe Intelligent Technology Studio | Website: [https://www.enhe-tech.com.cn](https://www.enhe-tech.com.cn)

恩禾 ENHE AI｜恩禾智能科技工作室研发｜官网：[https://www.enhe-tech.com.cn](https://www.enhe-tech.com.cn)

## What It Solves / 解决什么痛点

Many normal AI users use both:

- Official ChatGPT account quota.
- Third-party gateways such as CCswitch/Freemodel, OpenRouter, SiliconFlow, or a private gateway.

Without this app, switching means editing `config.toml`, setting environment variables, and checking login state. That is easy to get wrong.

很多普通 AI 用户会同时使用：

- 官方 ChatGPT 账号额度。
- CCswitch/Freemodel、OpenRouter、硅基流动或私有网关等第三方连接。

如果手动切换，就要改 `config.toml`、配置环境变量、检查登录状态，很容易切错或混用凭据。

## Simple Workflow / 傻瓜式流程

Open `Codex Provider Switcher` and follow the buttons:

1. `Connection Status` / `连接状态`: check what Codex is using now.
2. `Use Official ChatGPT` / `使用官方 ChatGPT`: switch to official account quota.
3. `Third-party connection` / `第三方连接`: choose a gateway, then click `Use Selected Third-party` / `使用所选第三方`.
4. `Add Third-party Connection` / `添加第三方连接`: choose a template, enter the API key, and save. The key is saved only to your local Windows user environment variable.
5. Restart any already-open Codex window after switching.

普通用户不需要手动编辑 JSON。只有高级用户才需要点击 `高级编辑配置`。

## Main Features / 主要功能

- Default Chinese UI, with `中文 / English` switching.
- Official ChatGPT mode and third-party API-key mode stay separate.
- Built-in templates for CCswitch/Freemodel, OpenRouter, SiliconFlow, and custom gateways.
- Optional API key input in the add-provider form. Keys are not stored in this repository.
- Every switch creates a backup under `%USERPROFILE%\.codex\provider-switch\backups`.
- Built-in usage instructions in the app window.

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

## Install / 安装

Requirements / 前置要求：

- Windows 10 or Windows 11.
- Codex CLI installed and available as `codex`.
- For official mode, Codex should be logged in with `Sign in with ChatGPT`.

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

Upgrade installs do not overwrite your existing `providers.json`.

## Add a Third-party Gateway / 添加第三方连接

Recommended simple path:

1. Open the app.
2. Click `添加第三方连接`.
3. Choose a template, such as `OpenRouter` or `SiliconFlow`.
4. Paste the API key.
5. Confirm the model name.
6. Click `保存`.
7. Select the new gateway from the dropdown and click `使用所选第三方`.

高级配置文件位置：

```text
%USERPROFILE%\.codex\provider-switch\providers.json
```

Third-party gateways must be compatible with the `wireApi` and model settings Codex uses. Some gateways need `responses`, others need `chat`.

Built-in templates prefill common public parameters, but the final model name should still match the model available in your own gateway account.

## User Guide PDF / PDF 使用手册

- [中文 PDF 使用手册](docs/USER_GUIDE.zh-CN.pdf)
- [中文说明](docs/README.zh-CN.md)
- [English documentation](docs/README.en.md)

## Uninstall / 卸载

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

Normal users can also uninstall by double-clicking `一键卸载.cmd` or `Uninstall.cmd`.

Uninstalling removes the app files and shortcuts only. It does not delete your Codex config, environment variables, or login credentials.

卸载只删除应用文件和快捷方式，不删除 Codex 配置、环境变量或登录凭据。
