# Codex Provider Switcher / Codex 连接切换器

Codex Provider Switcher is a small Windows desktop utility for one-click switching between CCswitch/Freemodel and official OpenAI ChatGPT account mode.

Codex Provider Switcher 是一个 Windows 本地小工具，用来一键切换 Codex 的第三方 CCswitch/Freemodel 连接和 OpenAI 官方 ChatGPT 账号连接。

## What It Does / 项目作用

It gives you one app window with four buttons:

- `Use Official ChatGPT`: switch Codex to the official `openai` provider and ChatGPT account login.
- `Use CCswitch`: switch Codex to the third-party CCswitch/Freemodel provider.
- `Connection Status`: check the active provider and login state.
- `Re-login ChatGPT`: log out of API-key auth and start the ChatGPT account login flow.

它把四个常用动作整合到一个应用窗口里：

- `Use Official ChatGPT`：切换到官方 ChatGPT 账号通道。
- `Use CCswitch`：切换到第三方 CCswitch/Freemodel 通道。
- `Connection Status`：查看当前连接状态。
- `Re-login ChatGPT`：退出 API Key 登录并重新选择 ChatGPT 账号登录。

## Pain Point / 痛点

Many Codex users need both connection modes:

- Official ChatGPT account mode for Codex quota included in a ChatGPT plan.
- Third-party API gateway mode for CCswitch/Freemodel workflows.

Manual switching means editing `~/.codex/config.toml`, checking environment variables, and sometimes changing login state. It is easy to mix credentials, use the wrong provider, or break Codex with a small config mistake.

很多 Codex 用户会同时需要两种连接：

- 官方 ChatGPT 账号模式：使用 ChatGPT 套餐里的 Codex 使用额度。
- 第三方 API 网关模式：使用 CCswitch/Freemodel 这类工作流。

如果手动切换，就要改 `~/.codex/config.toml`、检查环境变量，有时还要处理登录状态。这个过程容易混用凭据、切错 provider，或者因为配置小错误导致 Codex 无法启动。

## Solution / 解决方案

The app keeps the two modes separate:

- CCswitch mode uses `FREEMODEL_API_KEY`.
- Official mode uses Codex's built-in `openai` provider and ChatGPT account login.
- Every switch creates a config backup under `%USERPROFILE%\.codex\provider-switch\backups`.
- The repository does not store API keys, login tokens, or local backups.

这个工具把两种模式隔离：

- CCswitch 模式读取 `FREEMODEL_API_KEY`。
- 官方模式使用 Codex 内置 `openai` provider 和 ChatGPT 账号登录。
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
- For CCswitch mode, `FREEMODEL_API_KEY` should already be configured.
- For official mode, use `Sign in with ChatGPT` in Codex.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

The installer creates:

- Desktop shortcut: `Codex Provider Switcher`.
- Start menu shortcut: `Codex Provider Switcher`.
- Installed app files under `%USERPROFILE%\.codex\provider-switch`.

安装后会创建桌面和开始菜单快捷方式，名称都是 `Codex Provider Switcher`。

## Usage / 使用

Open `Codex Provider Switcher`.

- Click `Use Official ChatGPT` to use official OpenAI / ChatGPT account mode.
- Click `Use CCswitch` to use CCswitch/Freemodel mode.
- Click `Connection Status` to inspect the current state.
- Click `Re-login ChatGPT` if Codex still shows API-key login and you want to restore ChatGPT account login.

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
