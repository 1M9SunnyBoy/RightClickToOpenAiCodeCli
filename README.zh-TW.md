# 右鍵開啟 AI 程式設計 CLI

一個 Windows 工具，用於在右鍵選單中新增項目，可在目前資料夾的 PowerShell 視窗中啟動
**Claude Code**、**Codex** 或 **OpenCode**。

> README 語言：[English](README.md) · [简体中文](README.zh-CN.md) · **繁體中文** · [日本語](README.ja-JP.md) · [한국어](README.ko-KR.md)

## 功能

- 右鍵點擊資料夾或其空白處 → 出現「在此處開啟 Claude Code / Codex / OpenCode」項目
- 每個項目都會在對應資料夾中啟動對應 CLI（自動偵測是否已安裝）
- 安裝時可選擇要為哪些 CLI 加入右鍵選單項目（選擇會被記住）
- 安裝時提供互動式語言選擇器——自動偵測的系統語言會被推薦並預選
- 語言選擇會被記住，用於選單標籤和所有提示文字
- 固定安裝位置——移動或刪除來源資料夾不會影響已安裝的選單
- 介面已本地化：English、简体中文、繁體中文、日本語、한국어

## 必要條件

- Windows 10/11
- 已安裝至少一個 CLI：
  - Claude Code：`npm install -g @anthropic-ai/claude-code`
  - Codex：`npm install -g @openai/codex`
  - OpenCode：`npm install -g opencode-ai`
- 系統管理員權限（用於修改登錄檔）

## 安裝

1. 右鍵點擊 `install.bat` → 選擇 **「以系統管理員身分執行」**
2. 在語言選擇器中選一種介面語言（建議使用你的系統語言），按 Enter 確認
3. 在工具選擇器中勾選要加入右鍵選單的 AI CLI——只有已安裝的才能勾選（未安裝的會置灰顯示）——按 Enter 確認
4. 完成！所選的選單項目現已可用

## 解除安裝

1. 右鍵點擊 `uninstall.bat` → 選擇 **「以系統管理員身分執行」**
2. 右鍵選單項目和已安裝的檔案將一併移除

## 檔案說明

| 檔案 | 說明 |
|------|------|
| `install.bat` | 安裝入口——執行 `install.ps1` |
| `install.ps1` | 安裝器：語言/工具選擇器、複製檔案、寫入登錄檔（留在來源資料夾） |
| `uninstall.bat` | 解除安裝入口——執行 `uninstall.ps1` |
| `uninstall.ps1` | 解除安裝器：刪除登錄檔項目與安裝檔案（留在來源資料夾） |
| `i18n.ps1` | 完整 5 語言文字，供安裝/解除安裝共用（留在來源資料夾） |
| `RightClickToOpenAiCode.ps1` | 精簡的執行時啟動器——唯一被安裝到 `%ProgramData%\RightClickToOpenAiCode` 的指令碼 |
| `claude.ico` / `codex.ico` / `opencode.ico` | 三個工具的右鍵選單圖示 |

> `install.bat` / `uninstall.bat` 是純 ASCII 的薄包裝。只有精簡的執行時指令碼和圖示會複製到硬碟；
> 安裝器與語言文字留在來源資料夾。

## 運作原理

- `install.bat` → `install.ps1` 執行互動式選擇器（語言、CLI 工具），把精簡的執行時指令碼 + 圖示複製到固定位置
  `%ProgramData%\RightClickToOpenAiCode`，並在那裡註冊右鍵選單項目。每個選單項目執行
  `RightClickToOpenAiCode.ps1 -Tool <cli> -Path "%V"`。
- `RightClickToOpenAiCode.ps1`（執行時）切換到目標目錄並啟動所選 CLI；若未安裝則給出本地化提示。
- `uninstall.bat` → `uninstall.ps1` 刪除登錄檔項目與已安裝的檔案。

### 為什麼可以安全移動/刪除來源資料夾

安裝時會把 `RightClickToOpenAiCode.ps1` 和三個圖示 **複製**到固定位置
`%ProgramData%\RightClickToOpenAiCode`，登錄檔只指向這個固定位置。

- 之後移動、改名或刪除本專案資料夾，**不會**影響已安裝的選單。
- 修改了 `RightClickToOpenAiCode.ps1` 後，重新執行一次 `install.bat` 即可重新整理副本。
- 解除安裝時只會刪除 `%ProgramData%\RightClickToOpenAiCode`，不會碰來源資料夾裡的任何檔案。

## 語言選擇

安裝時會顯示一個語言選擇器：

```
  選擇介面語言：
    ► English  （推薦）
      简体中文
      繁體中文
      日本語
      한국어

  方向鍵 / 1-5 選擇，Enter 確認，Esc 取消
```

**推薦**（預選）項根據 `CurrentUICulture` 自動偵測你的系統語言。選擇結果儲存到
`%ProgramData%\RightClickToOpenAiCode\language.txt`，用於選單標籤和所有提示文字。
若該檔案不存在，則使用系統語言。

在工具選擇器中勾選的 CLI 會儲存到同一目錄下的 `tools.txt`，下次安裝時自動預選。只有偵測到已安裝在 PATH 中的工具才能勾選，未安裝的會置灰。

### 如何新增語言

安裝/解除安裝提示文字在 `i18n.ps1` 中；執行時提示文字在 `RightClickToOpenAiCode.ps1` 頂端的小區塊中。

1. 在 `i18n.ps1` 的 `$All` 中加入 `"fr-FR" = @{ ... }` 項目（鍵名與英文項目完全一致），並把 `"fr-FR"` 附加到 `$langKeys`。
2. 在 `RightClickToOpenAiCode.ps1` 的 `$All` 區塊中加入對應的執行時字串（`launching`、`not_found`、`install_hint`、`visit`、`current_dir`）以及一個偵測分支。

> 注意：`i18n.ps1` 和 `RightClickToOpenAiCode.ps1` 需保持 **UTF-8 with BOM** 編碼，
> 否則中文/日文/韓文會被 Windows PowerShell 5.1 誤讀為 ANSI 而亂碼。
