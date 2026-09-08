# 우클릭으로 AI 코딩 CLI 열기

Windows 우클릭 메뉴에 항목을 추가하여 현재 폴더에서 **Claude Code**·**Codex**·**OpenCode**를
PowerShell 창으로 실행하는 도구입니다.

> README 언어: [English](README.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja-JP.md) · **한국어**

## 기능

- 폴더 또는 빈 영역을 우클릭 → 「여기에서 Claude Code / Codex / OpenCode 열기」 항목
- 각 항목은 해당 폴더에서 해당 CLI를 실행합니다(설치 여부 자동 확인)
- 설치 시 우클릭 메뉴에 추가할 CLI를 선택할 수 있습니다(선택은 기억됩니다)
- 설치 시 대화형 언어 선택 표시——감지된 시스템 언어를 권장·사전 선택
- 선택한 언어는 저장되며 메뉴 라벨과 모든 메시지에 사용됩니다
- 안정적인 설치 위치——소스 폴더를 이동·삭제해도 메뉴는 깨지지 않습니다
- 지원 언어: English, 简体中文, 繁體中文, 日本語, 한국어

## 사전 요구사항

- Windows 10/11
- 다음 CLI 중 하나 이상 설치:
  - Claude Code: `npm install -g @anthropic-ai/claude-code`
  - Codex: `npm install -g @openai/codex`
  - OpenCode: `npm install -g opencode-ai`
- 관리자 권한(레지스트리 수정용)

## 설치

1. `install.bat`을 우클릭 → **「관리자 권한으로 실행」**
2. 언어 선택에서 표시 언어를 고르고 Enter(시스템 언어 권장)
3. 도구 선택에서 우클릭 메뉴에 추가할 AI CLI를 체크하고 Enter(설치된 것만 선택 가능, 미설치는 회색 표시)
4. 완료——선택한 메뉴 항목이 준비됩니다

## 제거

1. `uninstall.bat`을 우클릭 → **「관리자 권한으로 실행」**
2. 우클릭 메뉴 항목과 설치된 파일이 함께 제거됩니다

## 파일

| 파일 | 설명 |
|------|------|
| `install.bat` | 설치 진입점(`install.ps1` 실행) |
| `install.ps1` | 설치 프로그램: 언어/도구 선택, 파일 복사, 레지스트리 등록(소스 폴더에 남음) |
| `uninstall.bat` | 제거 진입점(`uninstall.ps1` 실행) |
| `uninstall.ps1` | 제거 프로그램: 레지스트리 항목과 설치 파일 삭제(소스 폴더에 남음) |
| `i18n.ps1` | 완전한 5개 언어 카탈로그. 설치/제거 프로그램이 공유(소스 폴더에 남음) |
| `RightClickToOpenAiCode.ps1` | 경량 실행 런처——`%ProgramData%\RightClickToOpenAiCode`에 설치되는 유일한 스크립트 |
| `claude.ico` / `codex.ico` / `opencode.ico` | 세 CLI의 우클릭 메뉴 아이콘 |

> `.bat` 파일은 순수 ASCII의 얇은 래퍼입니다. 하드디스크에 복사되는 것은 경량 실행 스크립트와
> 아이콘뿐입니다. 설치 프로그램과 언어 카탈로그는 소스 폴더에 남아 있습니다.

## 동작 방식

- `install.bat` → `install.ps1`이 대화형 선택(언어, CLI 도구)을 실행하고, 경량 실행 스크립트 + 아이콘을
  `%ProgramData%\RightClickToOpenAiCode`로 복사한 뒤 우클릭 메뉴를 등록합니다. 각 항목은
  `RightClickToOpenAiCode.ps1 -Tool <cli> -Path "%V"`를 실행합니다.
- `RightClickToOpenAiCode.ps1`(실행)은 디렉터리로 이동해 선택한 CLI를 실행합니다. 미설치 시 현지화된 힌트를 표시합니다.
- `uninstall.bat` → `uninstall.ps1`이 레지스트리 항목과 설치된 파일을 삭제합니다.

### 소스 폴더를 이동·삭제해도 안전한 이유

설치 시 `RightClickToOpenAiCode.ps1`과 각 아이콘을
`%ProgramData%\RightClickToOpenAiCode`로 복사하고, 레지스트리는 그 위치를 참조합니다.

- 프로젝트 폴더를 이동·이름 변경·삭제해도 설치된 메뉴에는 **영향이 없습니다**.
- `RightClickToOpenAiCode.ps1`을 수정한 뒤에는 `install.bat`을 다시 실행해 복사본을 갱신하세요.
- 제거 시에는 `%ProgramData%\RightClickToOpenAiCode`만 삭제하며, 소스 폴더의 파일에는 손대지 않습니다.

## 언어 선택

설치 시 언어 선택이 표시됩니다:

```
  인터페이스 언어 선택:
    ► English  (권장)
      简体中文
      繁體中文
      日本語
      한국어

  방향키 / 1-5 선택, Enter 확인, Esc 취소
```

**권장**(사전 선택) 항목은 `CurrentUICulture`로 감지한 시스템 언어입니다. 선택 결과는
`%ProgramData%\RightClickToOpenAiCode\language.txt`에 저장되며 메뉴 라벨과
모든 메시지에 사용됩니다. 파일이 없으면 시스템 언어를 사용합니다.

도구 선택에서 고른 CLI는 같은 폴더의 `tools.txt`에 저장되어 다음 설치 시 사전 선택됩니다. PATH에서 감지된 도구만 선택할 수 있으며, 미설치 항목은 회색으로 표시됩니다.

### 언어 추가 방법

설치/제거 프로그램 메시지는 `i18n.ps1`, 실행 시 힌트는 `RightClickToOpenAiCode.ps1` 상단의 작은 블록에 있습니다.

1. `i18n.ps1`의 `$All`에 `"fr-FR" = @{ ... }` 항목을 추가하고(키는 영어 항목과 완전히 일치) `$langKeys`에 `"fr-FR"`을 추가합니다.
2. `RightClickToOpenAiCode.ps1`의 `$All` 블록에 실행 시 문자열(`launching`·`not_found`·`install_hint`·`visit`·`current_dir`)과 감지 분기를 추가합니다.

> `i18n.ps1`과 `RightClickToOpenAiCode.ps1`은 **UTF-8 with BOM**을 유지해야 합니다.
> 그렇지 않으면 한·중·일 문자열이 Windows PowerShell 5.1에서 ANSI로 잘못 읽혀 깨집니다.

## 링크

- [GitHub 저장소](https://github.com/1M9SunnyBoy/RightClickToOpenAiCodeCli)
