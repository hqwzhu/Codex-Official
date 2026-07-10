# Codex Provider Switcher 中文说明

Codex Provider Switcher 是一个 Windows 桌面应用，用来让普通 AI 用户一键切换：

- 官方 ChatGPT 账号连接。
- 第三方 OpenAI-compatible 网关连接。

默认带有 `CCswitch / Freemodel`，也支持通过界面添加 OpenRouter、硅基流动、私有网关或其他兼容服务。

## 普通用户推荐流程

1. 打开桌面快捷方式 `Codex Provider Switcher`。
2. 点击 `连接状态`，先看当前 Codex 走的是哪一路。
3. 如果要用官方账号额度，点击 `使用官方 ChatGPT`。
4. 如果要用第三方网关，在 `第三方连接` 下拉框选择一个连接，再点击 `使用所选第三方`。
5. 如果列表里没有你的第三方，点击 `添加第三方连接`，选择模板，填入 API Key 和模型名，然后保存。
6. 切换完成后，重启已经打开的 Codex 窗口。

普通用户不需要手动编辑 `providers.json`。`高级编辑配置` 只给需要手动改 JSON 的用户使用。

## 解决什么痛点

手动切换 Codex 连接通常需要：

- 修改 `%USERPROFILE%\.codex\config.toml`。
- 设置 API Key 环境变量。
- 判断当前是 ChatGPT 登录还是 API Key 登录。
- 出错时自己找备份恢复。

这个应用把这些动作做成按钮和表单，避免官方账号和第三方 Key 混用。

## 安装

前置要求：

- Windows 10 或 Windows 11。
- 已安装 Codex CLI，并且 `codex` 命令可用。
- 如果要用官方账号，Codex 需要通过 `Sign in with ChatGPT` 登录。

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

## 添加第三方连接

推荐用界面添加：

1. 打开应用。
2. 点击 `添加第三方连接`。
3. 在 `连接模板` 里选择 `CCswitch / Freemodel`、`OpenRouter`、`SiliconFlow / 硅基流动` 或 `自定义`。
4. 填入 API Key。这个 Key 只会保存到当前 Windows 用户环境变量，不会写进 GitHub 项目。
5. 确认 `API 地址`、`环境变量名`、`模型名称`、`接口类型`。
6. 点击 `保存`。
7. 回到主界面，选择新连接并点击 `使用所选第三方`。

常见字段：

- `API 地址`：第三方网关给你的接口地址。
- `环境变量名`：保存 API Key 的变量名，例如 `OPENROUTER_API_KEY`。
- `模型名称`：第三方网关要求的模型名。
- `接口类型`：通常是 `responses` 或 `chat`，以第三方网关说明为准。

内置模板会预填常见公开参数，但最终模型名仍要以你自己的第三方账号可用模型为准。

## 高级配置

高级用户可以直接编辑：

```text
%USERPROFILE%\.codex\provider-switch\providers.json
```

示例：

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

保存后点击应用里的 `刷新列表`。

## 使用官方账号

点击 `使用官方 ChatGPT` 后，应用会把 Codex 切回官方 `openai` provider 和 ChatGPT 账号登录模式。

如果状态仍显示 API Key 登录，点击 `重新登录 ChatGPT`，在弹出的终端里选择 `Sign in with ChatGPT`。

## 卸载

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

卸载脚本只删除应用快捷方式和应用文件，不会删除 Codex `config.toml`、环境变量或登录凭据。

## PDF 手册

完整中文 PDF 手册：

```text
docs\USER_GUIDE.zh-CN.pdf
```
