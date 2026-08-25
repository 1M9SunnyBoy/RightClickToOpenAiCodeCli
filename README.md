# Open AI Coding CLIs on Right-Click

A Windows tool that adds context-menu entries to launch AI coding CLIs —
**Claude Code**, **Codex**, and **OpenCode** — in a PowerShell window from the
current folder.

> README languages: **English** · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja-JP.md) · [한국어](README.ko-KR.md)

## Features

- Right-click a folder or a folder's empty space → entries to open Claude Code / Codex / OpenCode there
- Each entry launches its CLI in that folder (auto-checks whether it is installed)
- At install time you choose which CLIs get a menu entry (the choice is remembered)
- Interactive language picker during install — your system language is recommended and pre-selected
- Language choice is remembered and used for the menu labels and all messages
- Stable install location — moving or deleting the source folder never breaks the menu
- Localized UI: English, 简体中文, 繁體中文, 日本語, 한국어

## Prerequisites

- Windows 10/11
- At least one of the CLIs installed:
  - Claude Code: `npm install -g @anthropic-ai/claude-code`
  - Codex: `npm install -g @openai/codex`
  - OpenCode: `npm install -g opencode-ai`
- Administrator rights (to edit the registry)

## Install

1. Right-click `install.bat` → **Run as administrator**
2. In the language picker, choose an interface language (your system language is recommended) and press Enter
3. In the tool picker, tick the AI CLIs you want — only installed ones are selectable (uninstalled are grayed out) — and press Enter
4. Done — the chosen menu entries are now available

## Uninstall

1. Right-click `uninstall.bat` → **Run as administrator**
2. The menu entries are removed, together with the installed files

## Files

| File | Description |
|------|-------------|
| `install.bat` | Install entry point — runs `install.ps1` |
| `install.ps1` | Installer: language & tool pickers, copies files, writes the registry (stays in the source folder) |
| `uninstall.bat` | Uninstall entry point — runs `uninstall.ps1` |
| `uninstall.ps1` | Uninstaller: removes the registry entries and installed files (stays in the source folder) |
| `i18n.ps1` | Full 5-language catalog, shared by the installer/uninstaller (stays in the source folder) |
| `RightClickToOpenAiCode.ps1` | Slim runtime launcher — the only script installed to `%ProgramData%\RightClickToOpenAiCode` |
| `claude.ico` / `codex.ico` / `opencode.ico` | Context-menu icons for the three CLIs |

> The `.bat` files are pure-ASCII thin wrappers. Only the slim runtime script
> and the icons are copied to disk; the installer and language catalog stay in
> the source folder.

## How it works

- `install.bat` → `install.ps1` runs the interactive pickers (language, CLIs),
  copies the slim runtime script + icons to the stable location
  `%ProgramData%\RightClickToOpenAiCode`, and registers the context-menu entries
  there. Each entry runs `RightClickToOpenAiCode.ps1 -Tool <cli> -Path "%V"`.
- `RightClickToOpenAiCode.ps1` (runtime) changes to the folder and launches the
  chosen CLI; if it is not installed it prints a localized hint.
- `uninstall.bat` → `uninstall.ps1` removes the registry entries and the
  installed files.

### Why moving or deleting the source folder is safe

Install copies `RightClickToOpenAiCode.ps1` and its icons (`claude.ico` / `codex.ico` / `opencode.ico`) to a stable
location `%ProgramData%\RightClickToOpenAiCode`; the registry points there.

- Moving / renaming / deleting this project folder afterwards does **not** affect the installed menu.
- After editing `RightClickToOpenAiCode.ps1`, re-run `install.bat` to refresh the copy.
- Uninstall removes only `%ProgramData%\RightClickToOpenAiCode`, never the source folder.

## Language selection

At install time a picker lets you choose the interface language:

```
  Select interface language:
    ► English  (recommended)
      简体中文
      繁體中文
      日本語
      한국어

  Arrow keys / 1-5 to choose, Enter to confirm, Esc to cancel
```

The **recommended** (pre-selected) entry is your system language, detected via
`CurrentUICulture`. The choice is saved to
`%ProgramData%\RightClickToOpenAiCode\language.txt` and used for the menu
labels and all messages. If the file is missing, the system language is used.

The CLIs you pick in the tool picker are saved to `tools.txt` in the same
folder and pre-selected on the next install. Only tools detected on your PATH
are selectable; uninstalled ones are grayed out.

### Adding a language

Installer/uninstaller messages live in `i18n.ps1`; runtime hints live in a
small block at the top of `RightClickToOpenAiCode.ps1`.

1. In `i18n.ps1`, add a `"fr-FR" = @{ ... }` entry to `$All` (keys must match the English entry) and append `"fr-FR"` to `$langKeys`.
2. In `RightClickToOpenAiCode.ps1`, add the matching runtime strings (`launching`, `not_found`, `install_hint`, `visit`, `current_dir`) to its `$All` block, plus a detection branch.

> `i18n.ps1` and `RightClickToOpenAiCode.ps1` must stay **UTF-8 with BOM**;
> otherwise the CJK strings are misread as ANSI by Windows PowerShell 5.1 and garbled.
