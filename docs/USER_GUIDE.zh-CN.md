# Codex Provider Switcher 使用手册

## 这个工具是做什么的

Codex Provider Switcher 是一个 Windows 桌面应用，用来让普通 AI 用户在 Codex 的两种连接方式之间一键切换。

- 官方 ChatGPT 账号连接：使用 ChatGPT 账号里的 Codex 额度。
- 第三方连接：使用 CCswitch/Freemodel、OpenRouter 或支持 Responses API 的私有网关。

普通用户不需要手动编辑 Codex 配置文件。日常操作只需要打开应用、看状态、点按钮。

## 创作者

恩禾 ENHE AI｜恩禾智能科技工作室研发｜官网：[https://www.enhe-tech.com.cn](https://www.enhe-tech.com.cn)

## 推荐使用流程

1. 打开桌面快捷方式 `Codex Provider Switcher`。
2. 点击 `连接状态`，确认当前 Codex 使用的是官方账号还是第三方连接。
3. 要使用官方账号额度，点击 `使用官方 ChatGPT`。
4. 要使用第三方连接，在 `第三方连接` 下拉框里选择连接，再点击 `使用所选第三方`。
5. 列表里没有你的第三方时，点击 `添加第三方连接`，按模板填入 API Key 和模型名。
6. 已打开的任务会继续使用原连接。请完全退出 Codex，重新打开并新建任务。

## 安装

### 前置要求

- Windows 10 或 Windows 11。
- 已安装 Codex CLI，并且 `codex` 命令可用。
- 如果要使用官方账号，Codex 需要通过 `Sign in with ChatGPT` 登录。

### 安装步骤

1. 下载并解压项目。
2. 先打开根目录的 `使用前必看.pdf`。
3. 双击 `一键安装.cmd` 或 `Install.cmd`。
4. 如果 Windows 阻止双击脚本，再在项目目录打开 PowerShell 运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

安装后会创建：

- 桌面快捷方式：`Codex Provider Switcher`。
- 开始菜单快捷方式：`Codex Provider Switcher`。
- 本地安装目录：`%USERPROFILE%\.codex\provider-switch`。
- 第三方连接配置文件：`%USERPROFILE%\.codex\provider-switch\providers.json`。

升级安装不会覆盖你已经编辑过的 `providers.json`。

## 主界面按钮说明

| 按钮 | 作用 |
| --- | --- |
| 连接状态 | 查看当前 Codex 连接、第三方 Key 是否存在、ChatGPT 登录状态。 |
| 使用官方 ChatGPT | 切换到官方 OpenAI provider 和 ChatGPT 账号模式。 |
| 使用所选第三方 | 切换到下拉框当前选中的第三方连接。 |
| 添加第三方连接 | 用模板添加新的第三方网关，并可顺便保存 API Key 到本机环境变量。 |
| 高级编辑配置 | 打开 `providers.json`，给高级用户手动修改。 |
| 刷新列表 | 保存配置后刷新第三方下拉框。 |
| 重新登录 ChatGPT | 当官方模式仍显示 API Key 登录时，重新走 ChatGPT 登录流程。 |

## 添加第三方连接

推荐普通用户使用 `添加第三方连接` 表单。

1. 点击 `添加第三方连接`。
2. 在 `连接模板` 中选择：
   - `CCswitch / Freemodel`
   - `OpenRouter`
   - `自定义`
3. 填入或确认：
   - `显示名称`：界面里显示的名字。
   - `API 地址`：第三方网关给你的接口地址。
   - `环境变量名`：保存 API Key 的变量名，例如 `OPENROUTER_API_KEY`。
   - `API Key（可选）`：填写后只保存到当前 Windows 用户环境变量。
   - `模型名称`：第三方网关要求的模型名。
   - `接口类型`：当前 Codex 自定义连接仅支持 `responses`。
4. 点击 `保存`。
5. 回到主界面选择新连接，并点击 `使用所选第三方`。

API Key 不会写入 GitHub 项目，也不会写入 `providers.json`。它只保存到你的 Windows 用户环境变量。

内置模板会预填常见公开参数，但最终模型名仍要以你自己的第三方账号可用模型为准。

## 官方 ChatGPT 模式

点击 `使用官方 ChatGPT` 后，工具会把 Codex 切换回官方 `openai` provider 和 ChatGPT 账号登录模式，并恢复上次使用的官方模型设置。

如果 `连接状态` 仍显示 API Key 登录，点击 `重新登录 ChatGPT`，在弹出的终端里选择 `Sign in with ChatGPT`。

## 第三方模式

点击 `使用所选第三方` 后，工具会根据当前下拉框选择写入 Codex 配置：

- provider 名称
- API 地址
- 环境变量名
- 模型名称
- 接口类型

每次切换前都会自动备份原始配置。备份目录：

```text
%USERPROFILE%\.codex\provider-switch\backups
```

## 高级配置

高级用户可以手动编辑：

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

保存后回到应用，点击 `刷新列表`。

## 卸载

普通用户可以双击 `一键卸载.cmd` 或 `Uninstall.cmd`。如果 Windows 阻止双击脚本，再在项目目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

卸载只删除应用文件和快捷方式，不会删除：

- Codex 主配置文件。
- Windows 环境变量。
- ChatGPT 登录凭据。
- 配置备份。

## 常见问题

### 切换后为什么还没生效

已经打开的 Codex 任务不会热切换连接。请完全退出 Codex，重新打开并新建任务。

### API Key 要不要写进 providers.json

不要。`providers.json` 只保存环境变量名。API Key 可以通过 `添加第三方连接` 表单保存到当前 Windows 用户环境变量。

### 第三方连接不工作怎么办

检查三项：

1. API Key 是否正确。
2. 模型名称是否是第三方网关支持的名称。
3. 第三方网关是否支持 Responses API；当前 Codex 不支持 Chat-Completions-only 网关。

### 官方模式是否需要 OpenAI API Key

不需要。官方 ChatGPT 账号模式使用 `Sign in with ChatGPT` 登录，不走 API Key。
