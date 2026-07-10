# Codex Provider Switcher

Codex Provider Switcher 是一个 Windows 本地小工具，用来在两种 Codex 连接方式之间一键切换：

- OpenAI 官方 / ChatGPT 账号模式。
- 第三方 CCswitch / Freemodel API 模式。

它适合同时使用官方 ChatGPT 账号额度和第三方 API 网关的人。你不需要每次手动改 `config.toml`，也不需要担心官方账号和第三方 Key 混在一起。

## 解决什么痛点

Codex 可以通过不同方式连接模型：

- 官方 ChatGPT 账号登录：使用 ChatGPT 套餐里包含的 Codex 使用额度。
- API Key 自定义 provider：例如 CCswitch、Freemodel 等第三方网关。

没有切换工具时，用户通常需要手动修改 `~/.codex/config.toml`、环境变量和登录状态。这样很容易出现几个问题：

- 改错 provider，导致 Codex 连接失败。
- 官方账号和第三方 API Key 混用，不知道当前到底走哪一路。
- 切换前没有备份，配置出错后不好恢复。
- 每次切换都要打开终端，操作繁琐。

## 如何解决

这个项目提供一个本地 GUI 应用，把常用操作做成按钮：

- `Use Official ChatGPT`：切换到官方 ChatGPT 账号通道。
- `Use CCswitch`：切换到第三方 CCswitch/Freemodel 通道。
- `Connection Status`：查看当前连接状态。
- `Re-login ChatGPT`：重新登录官方 ChatGPT 账号。

工具会在切换前自动备份配置，并让两种认证方式互不影响：

- CCswitch 模式读取 `FREEMODEL_API_KEY`。
- 官方模式使用 Codex 内置 `openai` provider 和 ChatGPT 账号登录。

本仓库不会保存你的 API Key、登录凭据或本机备份文件。

## 下载

方式一：使用 Git 克隆。

```powershell
git clone https://github.com/hqwzhu/Codex-Official.git
cd Codex-Official
```

方式二：在 GitHub 下载 ZIP。

1. 打开 `https://github.com/hqwzhu/Codex-Official`。
2. 点击 `Code`。
3. 点击 `Download ZIP`。
4. 解压 ZIP。

## 安装

前置要求：

- Windows 10 或 Windows 11。
- 已安装 Codex CLI，并且 `codex` 命令可用。
- 如果要使用 CCswitch：需要已经配置 `FREEMODEL_API_KEY`。
- 如果要使用官方账号：Codex 需要通过 `Sign in with ChatGPT` 登录。

在项目目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

安装后会创建：

- 桌面快捷方式：`Codex Provider Switcher`。
- 开始菜单快捷方式：`Codex Provider Switcher`。
- 本地安装目录：`%USERPROFILE%\.codex\provider-switch`。

## 使用方法

从桌面或开始菜单打开 `Codex Provider Switcher`。

- 点击 `Use Official ChatGPT`：切换到官方 OpenAI provider 和 ChatGPT 账号登录模式。
- 点击 `Use CCswitch`：切换到第三方 CCswitch/Freemodel provider。
- 点击 `Connection Status`：查看当前 provider、Key 是否存在、Codex 当前登录状态。
- 点击 `Re-login ChatGPT`：当状态仍显示 API Key 登录时，用它重新选择 `Sign in with ChatGPT`。

切换完成后，需要重启已经打开的 Codex 窗口，让 Codex 重新读取 `config.toml`。

## 卸载

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

卸载脚本只删除应用快捷方式和应用文件，不会删除你的 Codex `config.toml`、环境变量或登录凭据。
