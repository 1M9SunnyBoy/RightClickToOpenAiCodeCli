@echo off
:: Right-Click AI Code - Uninstaller (run as Administrator)
:: Runs the (localized) PowerShell uninstaller. All logic, including the
:: admin check, lives in uninstall.ps1.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
