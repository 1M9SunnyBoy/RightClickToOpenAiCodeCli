@echo off
:: Right-Click AI Code - Installer (run as Administrator)
:: Runs the (localized) PowerShell installer. All logic, including the
:: admin check and the language/tool pickers, lives in install.ps1.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
