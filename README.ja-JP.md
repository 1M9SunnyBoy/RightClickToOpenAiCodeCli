# 右クリックで AI コーディング CLI を開く

Windows の右クリックメニューに項目を追加し、現在のフォルダーで **Claude Code**・**Codex**・
**OpenCode** を PowerShell ウィンドウから起動するツールです。

> README の言語：[English](README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · **日本語** · [한국어](README.ko-KR.md)

## 機能

- フォルダーまたはその空き領域を右クリック → 「ここで Claude Code / Codex / OpenCode を開く」項目
- 各項目はそのフォルダーで対応する CLI を起動します（インストール済みか自動判定）
- インストール時に右クリックメニューへ追加する CLI を選択可能（選択は記憶されます）
- インストール時に対話式の言語選択を表示——検出したシステム言語を推奨・事前選択
- 選択した言語は記憶され、メニューのラベルとすべてのメッセージに使用されます
- 安定したインストール先——ソースフォルダーを移動・削除してもメニューは壊れません
- 表示言語：English、简体中文、繁體中文、日本語、한국어

## 前提条件

- Windows 10/11
- 次の CLI のうち少なくとも 1 つをインストール：
  - Claude Code：`npm install -g @anthropic-ai/claude-code`
  - Codex：`npm install -g @openai/codex`
  - OpenCode：`npm install -g opencode-ai`
- 管理者権限（レジストリを変更するため）

## インストール

1. `install.bat` を右クリック → **「管理者として実行」**
2. 言語選択で表示言語を選び、Enter で確定（システム言語が推奨）
3. ツール選択で右クリックメニューに追加する AI CLI にチェックを入れ、Enter で確定（インストール済みのみ選択可、未インストールはグレー表示）
4. 完了——選択したメニューが利用可能になります

## アンインストール

1. `uninstall.bat` を右クリック → **「管理者として実行」**
2. 右クリックメニューとインストール済みファイルが削除されます

## ファイル

| ファイル | 説明 |
|----------|------|
| `install.bat` | インストール入口（`install.ps1` を実行） |
| `install.ps1` | インストーラー：言語/ツール選択、ファイルコピー、レジストリ登録（ソースフォルダーに残る） |
| `uninstall.bat` | アンインストール入口（`uninstall.ps1` を実行） |
| `uninstall.ps1` | アンインストーラー：レジストリ項目とインストール済みファイルを削除（ソースフォルダーに残る） |
| `i18n.ps1` | 完全な 5 言語カタログ。インストーラー/アンインストーラーが共有（ソースフォルダーに残る） |
| `RightClickToOpenAiCode.ps1` | 軽量な実行時ランチャー——`%ProgramData%\RightClickToOpenAiCode` にインストールされる唯一のスクリプト |
| `claude.ico` / `codex.ico` / `opencode.ico` | 各 CLI の右クリックメニューアイコン |

> `.bat` は純 ASCII の薄いラッパーです。ハードディスクにコピーされるのは軽量な実行時スクリプトと
> アイコンのみ。インストーラーと言語カタログはソースフォルダーに残ります。

## 仕組み

- `install.bat` → `install.ps1` が対話式選択（言語、CLI ツール）を実行し、軽量な実行時スクリプト + アイコンを
  `%ProgramData%\RightClickToOpenAiCode` へコピーして、右クリックメニューを登録します。各項目は
  `RightClickToOpenAiCode.ps1 -Tool <cli> -Path "%V"` を実行します。
- `RightClickToOpenAiCode.ps1`（実行時）はディレクトリに移動して選択した CLI を起動。未インストールならローカライズ済みのヒントを表示します。
- `uninstall.bat` → `uninstall.ps1` がレジストリ項目とインストール済みファイルを削除します。

### ソースフォルダーを移動・削除しても安全な理由

インストール時に `RightClickToOpenAiCode.ps1` と各アイコンを
`%ProgramData%\RightClickToOpenAiCode` へコピーし、レジストリはそこを参照します。

- プロジェクトフォルダーを移動・改名・削除しても、インストール済みメニューには**影響しません**。
- `RightClickToOpenAiCode.ps1` を編集したら、`install.bat` を再実行してコピーを更新してください。
- アンインストールは `%ProgramData%\RightClickToOpenAiCode` のみを削除し、ソースフォルダーには触れません。

## 言語選択

インストール時に言語選択が表示されます：

```
  表示言語を選択：
    ► English  （推奨）
      简体中文
      繁體中文
      日本語
      한국어

  方向キー / 1-5 で選択、Enter で確定、Esc でキャンセル
```

**推奨**（事前選択）は `CurrentUICulture` で検出したシステム言語です。選択結果は
`%ProgramData%\RightClickToOpenAiCode\language.txt` に保存され、メニューのラベルと
すべてのメッセージに使われます。ファイルがなければシステム言語が使われます。

ツール選択で選んだ CLI は同じフォルダーの `tools.txt` に保存され、次回インストール時に事前選択されます。PATH 上で検出されたツールのみ選択可能で、未インストールはグレー表示です。

### 言語の追加方法

インストーラー/アンインストーラーのメッセージは `i18n.ps1`、実行時のヒントは `RightClickToOpenAiCode.ps1` 冒頭の小さなブロックにあります。

1. `i18n.ps1` の `$All` に `"fr-FR" = @{ ... }` を追加し（キーは英語エントリと完全に一致）、`$langKeys` に `"fr-FR"` を追記します。
2. `RightClickToOpenAiCode.ps1` の `$All` ブロックに対応する実行時文字列（`launching`・`not_found`・`install_hint`・`visit`・`current_dir`）と検出分岐を追加します。

> `i18n.ps1` と `RightClickToOpenAiCode.ps1` は **UTF-8 with BOM** を維持してください。
> そうしないと日本語・中国語・韓国語が Windows PowerShell 5.1 で ANSI として誤読され、文字化けします。

## リンク

- [GitHub リポジトリ](https://github.com/1M9SunnyBoy/RightClickToOpenAiCodeCli)
