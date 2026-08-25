# 右键打开 AI 编程 CLI

一个 Windows 工具，用于在右键菜单中添加入口，可在当前文件夹的 PowerShell 窗口中启动
**Claude Code**、**Codex** 或 **OpenCode**。

> README 语言：[English](README.md) · **简体中文** · [繁體中文](README.zh-TW.md) · [日本語](README.ja-JP.md) · [한국어](README.ko-KR.md)

## 功能

- 右键点击文件夹或其空白处 → 出现「在此处打开 Claude Code / Codex / OpenCode」入口
- 每个入口都会在对应文件夹中启动对应 CLI（自动检测是否已安装）
- 安装时可选择要为哪些 CLI 添加右键菜单入口（选择会被记住）
- 安装时提供交互式语言选择器——自动检测的系统语言会被推荐并预选
- 语言选择会被记住，用于菜单标签和所有提示语
- 固定安装位置——移动或删除源码文件夹不会影响已安装的菜单
- 界面已本地化：English、简体中文、繁體中文、日本語、한국어

## 前提条件

- Windows 10/11
- 已安装至少一个 CLI：
  - Claude Code：`npm install -g @anthropic-ai/claude-code`
  - Codex：`npm install -g @openai/codex`
  - OpenCode：`npm install -g opencode-ai`
- 管理员权限（用于修改注册表）

## 安装

1. 右键点击 `install.bat` → 选择 **「以管理员身份运行」**
2. 在语言选择器中选一种界面语言（推荐使用你的系统语言），按回车确认
3. 在工具选择器中勾选要加入右键菜单的 AI CLI——只有已安装的才能勾选（未安装的会置灰显示）——按回车确认
4. 完成！所选的菜单入口现已可用

## 卸载

1. 右键点击 `uninstall.bat` → 选择 **「以管理员身份运行」**
2. 右键菜单入口和已安装的文件将被一并移除

## 文件说明

| 文件 | 说明 |
|------|------|
| `install.bat` | 安装入口——运行 `install.ps1` |
| `install.ps1` | 安装器：语言/工具选择器、复制文件、写注册表（留在源码文件夹） |
| `uninstall.bat` | 卸载入口——运行 `uninstall.ps1` |
| `uninstall.ps1` | 卸载器：删除注册表项与安装文件（留在源码文件夹） |
| `i18n.ps1` | 完整 5 语言文案，供安装/卸载共用（留在源码文件夹） |
| `RightClickToOpenAiCode.ps1` | 精简的运行时启动器——唯一被安装到 `%ProgramData%\RightClickToOpenAiCode` 的脚本 |
| `claude.ico` / `codex.ico` / `opencode.ico` | 三个工具的右键菜单图标 |

> `install.bat` / `uninstall.bat` 是纯 ASCII 的薄包装。只有精简的运行时脚本和图标会复制到硬盘；
> 安装器与语言文案留在源码文件夹。

## 工作原理

- `install.bat` → `install.ps1` 运行交互式选择器（语言、CLI 工具），把精简的运行时脚本 + 图标复制到固定位置
  `%ProgramData%\RightClickToOpenAiCode`，并在那里注册右键菜单项。每个菜单项运行
  `RightClickToOpenAiCode.ps1 -Tool <cli> -Path "%V"`。
- `RightClickToOpenAiCode.ps1`（运行时）切换到目标目录并启动所选 CLI；若未安装则给出本地化提示。
- `uninstall.bat` → `uninstall.ps1` 删除注册表项与已安装的文件。

### 为什么可以安全移动/删除源文件夹

安装时会把 `RightClickToOpenAiCode.ps1` 和三个图标 **复制**到固定位置
`%ProgramData%\RightClickToOpenAiCode`，注册表只指向这个固定位置。

- 之后移动、改名或删除本项目文件夹，**不会**影响已安装的菜单。
- 修改了 `RightClickToOpenAiCode.ps1` 后，重新运行一次 `install.bat` 即可刷新副本。
- 卸载时只会删除 `%ProgramData%\RightClickToOpenAiCode`，不会碰源文件夹里的任何文件。

## 语言选择

安装时会显示一个语言选择器：

```
  选择界面语言：
    ► English  （推荐）
      简体中文
      繁體中文
      日本語
      한국어

  方向键 / 1-5 选择，回车确认，Esc 取消
```

**推荐**（预选）项根据 `CurrentUICulture` 自动检测你的系统语言。选择结果保存到
`%ProgramData%\RightClickToOpenAiCode\language.txt`，用于菜单标签和所有提示语。
若该文件不存在，则使用系统语言。

在工具选择器中勾选的 CLI 会保存到同一目录下的 `tools.txt`，下次安装时自动预选。只有检测到已安装在 PATH 中的工具才能勾选，未安装的会置灰。

### 如何新增语言

安装/卸载提示语在 `i18n.ps1` 中；运行时提示语在 `RightClickToOpenAiCode.ps1` 顶部的小块中。

1. 在 `i18n.ps1` 的 `$All` 中加入 `"fr-FR" = @{ ... }` 条目（键名与英文条目完全一致），并把 `"fr-FR"` 追加到 `$langKeys`。
2. 在 `RightClickToOpenAiCode.ps1` 的 `$All` 块中加入对应的运行时字符串（`launching`、`not_found`、`install_hint`、`visit`、`current_dir`）以及一个检测分支。

> 注意：`i18n.ps1` 和 `RightClickToOpenAiCode.ps1` 需保持 **UTF-8 with BOM** 编码，
> 否则中文/日文/韩文会被 Windows PowerShell 5.1 误读为 ANSI 而乱码。
