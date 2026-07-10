# Codex Provider Switcher

Codex Provider Switcher 是一个 Windows 本地小工具，用来在 Codex 的两类连接方式之间一键切换：

- OpenAI 官方 / ChatGPT 账号模式。
- 可配置的第三方 OpenAI-compatible API 网关模式。

默认第三方连接仍然是 `CCswitch / Freemodel`，但你可以在 `providers.json` 里继续添加 OpenRouter、硅基流动、私有网关或其他兼容服务。

## 解决什么痛点

Codex 可以通过不同方式连接模型：

- 官方 ChatGPT 账号登录：使用 ChatGPT 套餐里包含的 Codex 使用额度。
- API Key 自定义 provider：例如 CCswitch、OpenRouter、硅基流动、Freemodel 或私有网关。

没有切换工具时，用户通常需要手动修改 `~/.codex/config.toml`、环境变量和登录状态。这样很容易出现几个问题：

- 改错 provider，导致 Codex 连接失败。
- 官方账号和第三方 API Key 混用，不知道当前到底走哪一路。
- 切换前没有备份，配置出错后不好恢复。
- 每次切换都要打开终端，操作繁琐。

## 如何解决

这个项目提供一个本地 GUI 应用，把常用操作做成按钮和下拉框：

- `使用官方 ChatGPT`：切换到官方 ChatGPT 账号通道。
- `第三方连接`：从列表里选择一个第三方网关。
- `使用所选第三方`：切换到当前选中的第三方 provider。
- `连接状态`：查看当前 provider、Key 是否存在、Codex 当前登录状态。
- `重新登录 ChatGPT`：重新登录官方 ChatGPT 账号。
- `编辑第三方连接`：打开 `providers.json`，添加或修改第三方 provider。
- `刷新列表`：保存 `providers.json` 后刷新下拉框。

工具会在切换前自动备份配置，并让两种认证方式互不影响：

- 官方模式使用 Codex 内置 `openai` provider 和 ChatGPT 账号登录。
- 第三方模式读取 `providers.json` 中的 `envKey`，例如 `FREEMODEL_API_KEY`、`OPENROUTER_API_KEY`、`SILICONFLOW_API_KEY`。
- 界面支持中文和英文切换，默认打开为中文。
- 界面内置“使用说明”，直接显示推荐操作步骤。

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
- 如果要使用第三方连接：需要先把对应 API Key 配置成 Windows 环境变量。
- 如果要使用官方账号：Codex 需要通过 `Sign in with ChatGPT` 登录。

在项目目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

安装后会创建：

- 桌面快捷方式：`Codex Provider Switcher`。
- 开始菜单快捷方式：`Codex Provider Switcher`。
- 本地安装目录：`%USERPROFILE%\.codex\provider-switch`。
- 第三方配置文件：`%USERPROFILE%\.codex\provider-switch\providers.json`。

升级安装不会覆盖你已经编辑过的 `providers.json`。

## 配置第三方连接

打开应用后点击 `编辑第三方连接`，或手动打开：

```text
%USERPROFILE%\.codex\provider-switch\providers.json
```

配置结构如下：

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

字段说明：

- `id`：工具内部识别名，建议只用英文、数字、短横线。
- `displayName`：界面上显示的名字。
- `modelProvider`：写入 Codex `config.toml` 的 provider 名称。
- `baseUrl`：第三方网关的 API 地址。
- `envKey`：保存 API Key 的 Windows 环境变量名称。工具只保存变量名，不保存 Key。
- `wireApi`：Codex 使用的协议类型，常见为 `responses` 或 `chat`。
- `model`：要使用的模型名。
- `modelReasoningEffort`、`serviceTier`、`preferredAuthMethod`：写入 Codex 主配置的相关参数。

添加 provider 后，保存文件并点击应用里的 `刷新列表`。

### OpenRouter 示例

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

### 硅基流动示例

```json
{
  "id": "siliconflow",
  "displayName": "SiliconFlow / 硅基流动",
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

注意：第三方网关需要兼容 Codex 当前使用的 `wireApi` 和模型配置。不同网关可能要求不同模型名或协议类型，请以网关文档为准。

## 使用方法

从桌面或开始菜单打开 `Codex Provider Switcher`。

- 右上角语言选择器可在中文和 English 之间切换。
- 点击 `连接状态`：查看当前 provider、Key 是否存在、Codex 当前登录状态。
- 点击 `使用官方 ChatGPT`：切换到官方 OpenAI provider 和 ChatGPT 账号登录模式。
- 在 `第三方连接` 下拉框选择一个 provider，再点击 `使用所选第三方`。
- 点击 `重新登录 ChatGPT`：当状态仍显示 API Key 登录时，用它重新选择 `Sign in with ChatGPT`。

切换完成后，需要重启已经打开的 Codex 窗口，让 Codex 重新读取 `config.toml`。

## 卸载

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

卸载脚本只删除应用快捷方式和应用文件，不会删除你的 Codex `config.toml`、环境变量或登录凭据。
