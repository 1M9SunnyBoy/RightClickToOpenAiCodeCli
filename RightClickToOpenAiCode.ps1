# ============================================================
#  Right-Click AI Code - Runtime launcher
#  Permanently installed at %ProgramData%\RightClickToOpenAiCode
#  and called by the Explorer context menu. Slim on purpose:
#  it only launches the chosen AI coding CLI in a folder.
#
#  Usage (called by the context menu):
#    RightClickToOpenAiCode.ps1 -Path "DIR" -Tool claude|codex|opencode
#
#  The interface language is read from language.txt (written during
#  install); if missing, the system language is used.
# ============================================================

param(
    [string]$Path,
    [string]$Tool = "claude"
)

# Minimal localized messages (kept self-contained)
$All = @{
    "en" = @{ launching = "Launching {0} in:"; not_found = "{0} not found in PATH."; current_dir = "Current directory:" }
    "zh-CN" = @{ launching = "正在启动 {0}，位置："; not_found = "未在 PATH 中找到 {0}。"; current_dir = "当前目录：" }
    "zh-TW" = @{ launching = "正在啟動 {0}，位置："; not_found = "在 PATH 中找不到 {0}。"; current_dir = "目前目錄：" }
    "ja-JP" = @{ launching = "{0} を起動中:"; not_found = "PATH に {0} が見つかりません。"; current_dir = "現在のディレクトリ:" }
    "ko-KR" = @{ launching = "{0} 시작 위치:"; not_found = "PATH에서 {0}을(를) 찾을 수 없습니다."; current_dir = "현재 디렉터리:" }
}

$cultureName = [System.Globalization.CultureInfo]::CurrentUICulture.Name
$langKey = "en"
if ($cultureName -match "^zh-(TW|HK|MO|Hant)") { $langKey = "zh-TW" }
elseif ($cultureName -like "zh*")              { $langKey = "zh-CN" }
elseif ($cultureName -like "ja*")              { $langKey = "ja-JP" }
elseif ($cultureName -like "ko*")              { $langKey = "ko-KR" }
# A saved language choice (from install) overrides the system language
$configFile = Join-Path $PSScriptRoot "language.txt"
if (Test-Path $configFile) {
    $raw = (Get-Content $configFile -Raw).Trim()
    if ($All.ContainsKey($raw)) { $langKey = $raw }
}
$Text = $All[$langKey]

$validTools = @('claude', 'codex', 'opencode')
if ($validTools -notcontains $Tool) { $Tool = 'claude' }

if (Test-Path $Path) {
    Set-Location $Path
}

$cmd = Get-Command $Tool -ErrorAction SilentlyContinue
if ($cmd) {
    Write-Host "$($Text.launching -f $Tool) $Path" -ForegroundColor Cyan
    Write-Host ""
    & $Tool
} else {
    Write-Host "$($Text.not_found -f $Tool)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "$($Text.current_dir) $Path" -ForegroundColor Gray
}
