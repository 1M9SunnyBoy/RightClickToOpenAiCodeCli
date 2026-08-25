# ============================================================
#  Right-Click AI Code - Uninstaller (PowerShell)
#  Run as Administrator (via uninstall.bat). Removes the context-menu
#  entries and the installed files at %ProgramData%\RightClickToOpenAiCode.
#  Localized strings come from i18n.ps1 (dot-sourced below).
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$sourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load localized strings (defines $All, $langKeys, $Text)
. (Join-Path $sourceDir "i18n.ps1")

$installDir = Join-Path $env:ProgramData "RightClickToOpenAiCode"
$toolKeys   = @('Claude', 'Codex', 'OpenCode')

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Deny-NoAdmin {
    Write-Host $Text.run_admin -ForegroundColor Red
    Write-Host $Text.run_admin_hint -ForegroundColor Gray
    Write-Host ""
    Read-Host $Text.press_enter
    exit 1
}

if (-not (Test-IsAdmin)) { Deny-NoAdmin }

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  $($Text.un_title)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host $Text.un_reg -ForegroundColor Yellow
foreach ($k in $toolKeys) {
    Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\$k" -Recurse -Force
    Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\$k" -Recurse -Force
    Write-Host "  $($Text.un_removed) $k" -ForegroundColor Gray
}

Write-Host ""
Write-Host $Text.un_files -ForegroundColor Yellow
if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
    Write-Host "  $($Text.un_removed) $installDir" -ForegroundColor Gray
} else {
    Write-Host "  $($Text.un_no_files)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  $($Text.un_complete)" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Read-Host $Text.press_enter
