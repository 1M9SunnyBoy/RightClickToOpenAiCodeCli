# ============================================================
#  Right-Click AI Code - Installer (PowerShell)
#  Run as Administrator (via install.bat). Adds context-menu entries
#  that launch AI coding CLIs (Claude Code / Codex / OpenCode) in the
#  current folder.
#
#  Copies the slim runtime script RightClickToOpenAiCode.ps1 and the
#  icons to a stable location (%ProgramData%\RightClickToOpenAiCode)
#  and points the context menu there, so moving or deleting this source
#  folder does NOT break the menu. Localized strings come from i18n.ps1
#  (dot-sourced below); neither install.ps1 nor i18n.ps1 is installed.
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$sourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load localized strings (defines $All, $langKeys, $Text)
. (Join-Path $sourceDir "i18n.ps1")

$installDir   = Join-Path $env:ProgramData "RightClickToOpenAiCode"
$psScript     = Join-Path $installDir "RightClickToOpenAiCode.ps1"
$configFile   = Join-Path $installDir "language.txt"
$toolsFile    = Join-Path $installDir "tools.txt"
$sourceScript = Join-Path $sourceDir "RightClickToOpenAiCode.ps1"

# Context-menu entries (registry key, CLI command, catalog key for the label, icon file)
$ToolEntries = @(
    @{ key = 'Claude';   cmd = 'claude';   menuKey = 'menu_claude';   icon = 'claude.ico';   display = 'Claude Code' },
    @{ key = 'Codex';    cmd = 'codex';    menuKey = 'menu_codex';    icon = 'codex.ico';    display = 'Codex' },
    @{ key = 'OpenCode'; cmd = 'opencode'; menuKey = 'menu_opencode'; icon = 'opencode.ico'; display = 'OpenCode' }
)

# ============================================================
#  Helpers
# ============================================================
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

# ============================================================
#  TUI - interactive language picker
# ============================================================
function Show-LanguagePicker {
    param(
        [string]$Title,
        [string]$RecommendedTag,
        [string]$Footer,
        [string]$Prompt,
        [int]$DefaultIndex
    )

    $names = @('English', '简体中文', '繁體中文', '日本語', '한국어')
    $count = $names.Count
    $sel = $DefaultIndex

    if ([Console]::IsInputRedirected) {
        # Non-interactive fallback: numbered prompt
        Write-Host ""
        Write-Host "  $Title" -ForegroundColor Cyan
        Write-Host ""
        for ($i = 0; $i -lt $count; $i++) {
            $tag = if ($i -eq $DefaultIndex) { "  $RecommendedTag" } else { "" }
            Write-Host "  $($i + 1). $($names[$i])$tag"
        }
        Write-Host ""
        $ans = $null
        try { $ans = Read-Host $Prompt } catch { $ans = '' }
        if ($ans -match '^[1-9]$') {
            $n = [int]$ans
            if ($n -ge 1 -and $n -le $count) { return $n - 1 }
        }
        return $DefaultIndex
    }

    # Interactive TUI: arrow keys / number keys, Enter to confirm.
    # If the console is not fully interactive, fall back to the default.
    try {
        $top = [Console]::CursorTop
        [Console]::CursorVisible = $false
        try {
            while ($true) {
                [Console]::SetCursorPosition(0, $top)
                Write-Host ""
                Write-Host "  $Title" -ForegroundColor Cyan
                Write-Host ""
                for ($i = 0; $i -lt $count; $i++) {
                    $marker = if ($i -eq $sel) { '►' } else { ' ' }
                    $tag    = if ($i -eq $DefaultIndex) { "  $RecommendedTag" } else { "" }
                    if ($i -eq $sel) {
                        Write-Host "  $marker $($names[$i])$tag" -ForegroundColor White -BackgroundColor DarkBlue
                    } else {
                        Write-Host "  $marker $($names[$i])$tag" -ForegroundColor Gray
                    }
                }
                Write-Host ""
                Write-Host "  $Footer" -ForegroundColor DarkGray

                $key = [Console]::ReadKey($true)
                if ($key.Key -eq [ConsoleKey]::UpArrow)   { $sel = ($sel + $count - 1) % $count; continue }
                if ($key.Key -eq [ConsoleKey]::DownArrow) { $sel = ($sel + 1) % $count; continue }
                if ($key.Key -eq [ConsoleKey]::Enter)     { break }
                if ($key.Key -eq [ConsoleKey]::Escape)    { $sel = $DefaultIndex; break }
                if ($key.KeyChar -ge '1' -and $key.KeyChar -le [char]([int]'0' + $count)) {
                    $sel = [int]::Parse($key.KeyChar.ToString()) - 1
                    break
                }
            }
        } finally {
            [Console]::CursorVisible = $true
        }
        Write-Host ""
        return $sel
    } catch {
        Write-Host ""
        return $DefaultIndex
    }
}

# ============================================================
#  TUI - multi-select tool picker
# ============================================================
# Read which tools were previously selected (default: all)
function Get-StoredTools {
    $result = @($true) * $ToolEntries.Count
    if (Test-Path $toolsFile) {
        $chosen = @(Get-Content $toolsFile | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        for ($i = 0; $i -lt $ToolEntries.Count; $i++) {
            $result[$i] = $chosen -contains $ToolEntries[$i].cmd
        }
    }
    return $result
}

function Show-ToolPicker {
    param(
        [string]$Title,
        [string]$Footer,
        [string]$Prompt,
        [string[]]$Items,
        [bool[]]$Initial,
        [bool[]]$Installed,
        [string]$NotInstalledTag
    )

    $count = $Items.Count
    if ($count -eq 0) { return @($false) }
    if ($Initial.Count -ne $count) { $Initial = @($true) * $count }
    if ($Installed.Count -ne $count) { $Installed = @($true) * $count }
    $checked = [bool[]]$Initial.Clone()
    # Tools that are not installed can never be selected
    for ($i = 0; $i -lt $count; $i++) {
        if (-not $Installed[$i]) { $checked[$i] = $false }
    }
    $sel = 0

    if ([Console]::IsInputRedirected) {
        # Non-interactive fallback: numbered prompt
        Write-Host ""
        Write-Host "  $Title" -ForegroundColor Cyan
        Write-Host ""
        for ($i = 0; $i -lt $count; $i++) {
            $mark = if ($checked[$i]) { '[x]' } else { '[ ]' }
            $tag  = if (-not $Installed[$i]) { "  $NotInstalledTag" } else { "" }
            if ($Installed[$i]) {
                Write-Host "  $($i + 1). $mark $($Items[$i])$tag"
            } else {
                Write-Host "  $($i + 1). $mark $($Items[$i])$tag" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
        $ans = $null
        try { $ans = Read-Host $Prompt } catch { $ans = '' }
        if (-not [string]::IsNullOrWhiteSpace($ans) -and $ans -notmatch '(?i)^all$') {
            $checked = @($false) * $count
            foreach ($m in [regex]::Matches($ans, '[1-9]')) {
                $n = [int]$m.Value
                if ($n -ge 1 -and $n -le $count -and $Installed[$n - 1]) { $checked[$n - 1] = $true }
            }
        }
        return $checked
    }

    # Interactive TUI: arrow keys to move, Space / number keys to toggle.
    # Uninstalled tools are shown grayed out and cannot be toggled.
    try {
        $top = [Console]::CursorTop
        [Console]::CursorVisible = $false
        try {
            while ($true) {
                [Console]::SetCursorPosition(0, $top)
                Write-Host ""
                Write-Host "  $Title" -ForegroundColor Cyan
                Write-Host ""
                for ($i = 0; $i -lt $count; $i++) {
                    $mark    = if ($checked[$i]) { '[x]' } else { '[ ]' }
                    $selMark = if ($i -eq $sel) { '►' } else { ' ' }
                    $tag     = if (-not $Installed[$i]) { "  $NotInstalledTag" } else { "" }
                    if ($Installed[$i] -and $i -eq $sel) {
                        Write-Host "  $selMark $mark $($Items[$i])$tag" -ForegroundColor White -BackgroundColor DarkBlue
                    } elseif ($Installed[$i]) {
                        Write-Host "  $selMark $mark $($Items[$i])$tag" -ForegroundColor Gray
                    } else {
                        Write-Host "  $selMark $mark $($Items[$i])$tag" -ForegroundColor DarkGray
                    }
                }
                Write-Host ""
                Write-Host "  $Footer" -ForegroundColor DarkGray

                $key = [Console]::ReadKey($true)
                if ($key.Key -eq [ConsoleKey]::UpArrow)   { $sel = ($sel + $count - 1) % $count; continue }
                if ($key.Key -eq [ConsoleKey]::DownArrow) { $sel = ($sel + 1) % $count; continue }
                if ($key.Key -eq [ConsoleKey]::Spacebar) {
                    if ($Installed[$sel]) { $checked[$sel] = -not $checked[$sel] }
                    continue
                }
                if ($key.Key -eq [ConsoleKey]::Enter)     { break }
                if ($key.Key -eq [ConsoleKey]::Escape)    { return $checked }
                if ($key.KeyChar -ge '1' -and $key.KeyChar -le [char]([int]'0' + $count)) {
                    $n = [int]::Parse($key.KeyChar.ToString()) - 1
                    if ($Installed[$n]) { $checked[$n] = -not $checked[$n] }
                    continue
                }
            }
        } finally {
            [Console]::CursorVisible = $true
        }
        Write-Host ""
        return $checked
    } catch {
        Write-Host ""
        return $checked
    }
}

# ============================================================
#  Install
# ============================================================
if (-not (Test-IsAdmin)) { Deny-NoAdmin }

# 1. Let the user pick a language (detected language recommended/pre-selected)
$detectedKey = "en"
$cultureName = [System.Globalization.CultureInfo]::CurrentUICulture.Name
if ($cultureName -match "^zh-(TW|HK|MO|Hant)") { $detectedKey = "zh-TW" }
elseif ($cultureName -like "zh*")              { $detectedKey = "zh-CN" }
elseif ($cultureName -like "ja*")              { $detectedKey = "ja-JP" }
elseif ($cultureName -like "ko*")              { $detectedKey = "ko-KR" }
$detectedIndex = [Array]::IndexOf($langKeys, $detectedKey)
if ($detectedIndex -lt 0) { $detectedIndex = 0 }

$sel = Show-LanguagePicker -Title $Text.tui_title `
                           -RecommendedTag $Text.tui_recommended `
                           -Footer $Text.tui_footer `
                           -Prompt $Text.tui_prompt `
                           -DefaultIndex $detectedIndex
$chosen = $langKeys[$sel]
$script:Text = $All[$chosen]

# 2. Let the user choose which CLIs get a right-click menu entry.
#    Only tools found on PATH are selectable; the rest are grayed out.
$initTools = Get-StoredTools
$installedTools = @()
foreach ($entry in $ToolEntries) {
    $installedTools += [bool](Get-Command $entry.cmd -ErrorAction SilentlyContinue)
}
if (-not ($installedTools -contains $true)) {
    Write-Host ""
    Write-Host $Text.inst_no_cli_found -ForegroundColor Yellow
    Write-Host ""
    Read-Host $Text.press_enter
    exit 1
}
$toolSel = Show-ToolPicker -Title $Text.tui_tools_title `
                           -Footer $Text.tui_tools_footer `
                           -Prompt $Text.tui_tools_prompt `
                           -Items ($ToolEntries | ForEach-Object { $_.display }) `
                           -Initial $initTools `
                           -Installed $installedTools `
                           -NotInstalledTag $Text.tui_tools_notinst
$activeEntries = @()
for ($i = 0; $i -lt $ToolEntries.Count; $i++) {
    if ($toolSel[$i]) { $activeEntries += $ToolEntries[$i] }
}
if ($activeEntries.Count -eq 0) {
    Write-Host ""
    Write-Host $Text.inst_no_tools -ForegroundColor Yellow
    Write-Host ""
    Read-Host $Text.press_enter
    exit 1
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  $($Text.inst_title)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 3. Check icons in the source folder
Write-Host $Text.inst_step_icon -ForegroundColor Yellow
$missingIcons = @()
foreach ($entry in $ToolEntries) {
    if (-not (Test-Path (Join-Path $sourceDir $entry.icon))) { $missingIcons += $entry.icon }
}
if ($missingIcons.Count -gt 0) {
    Write-Host "$($missingIcons -join ', ') $($Text.inst_icon_missing) $sourceDir" -ForegroundColor Red
    Write-Host "$($Text.inst_icon_place) $sourceScript" -ForegroundColor Red
    Read-Host $Text.press_enter
    exit 1
}
Write-Host "  $($Text.inst_icon_found)" -ForegroundColor Green

# 4. Copy files to the stable install directory and save the choices
Write-Host ""
Write-Host "$($Text.inst_step_files) $installDir ..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
foreach ($entry in $ToolEntries) {
    Copy-Item -Path (Join-Path $sourceDir $entry.icon) -Destination (Join-Path $installDir $entry.icon) -Force
}
Copy-Item -Path $sourceScript -Destination $psScript -Force
Set-Content -Path $configFile -Value $chosen -Encoding ASCII
$activeCmds = $activeEntries | ForEach-Object { $_.cmd }
Set-Content -Path $toolsFile -Value $activeCmds -Encoding ASCII
Write-Host "  $($Text.inst_files_done)" -ForegroundColor Green

Write-Host ""
Write-Host $Text.inst_step_reg -ForegroundColor Yellow

# 5. Register context-menu entries for the selected tools
foreach ($root in @("HKEY_CLASSES_ROOT\Directory\Background", "HKEY_CLASSES_ROOT\Directory")) {
    foreach ($entry in $activeEntries) {
        $key = "Registry::$root\shell\$($entry.key)"
        New-Item -Path $key -Force | Out-Null
        Set-ItemProperty -Path $key -Name "(Default)" -Value $Text[$entry.menuKey]
        Set-ItemProperty -Path $key -Name "Icon" -Value "`"$(Join-Path $installDir $entry.icon)`""
        $cmdKey = "$key\command"
        New-Item -Path $cmdKey -Force | Out-Null
        $cmd = "powershell.exe -NoExit -ExecutionPolicy Bypass -File `"$psScript`" -Tool $($entry.cmd) -Path `"%V`""
        Set-ItemProperty -Path $cmdKey -Name "(Default)" -Value $cmd
    }
}
foreach ($entry in $activeEntries) {
    Write-Host "  $($Text.inst_added) $($Text[$entry.menuKey])" -ForegroundColor Gray
}

# 6. Verify
Write-Host ""
Write-Host $Text.inst_verify -ForegroundColor Yellow
$allOk = $true
foreach ($root in @("HKEY_CLASSES_ROOT\Directory\Background", "HKEY_CLASSES_ROOT\Directory")) {
    foreach ($entry in $activeEntries) {
        if (-not (Test-Path "Registry::$root\shell\$($entry.key)")) { $allOk = $false }
    }
}
if ($allOk -and (Test-Path $psScript)) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  $($Text.inst_success)" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host $Text.inst_body1 -ForegroundColor White
    Write-Host $Text.inst_body2 -ForegroundColor White
    foreach ($entry in $activeEntries) {
        Write-Host "  - $($Text[$entry.menuKey])" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "$($Text.inst_installed_to) $installDir" -ForegroundColor Gray
    Write-Host ""
    Write-Host $Text.inst_tip1 -ForegroundColor Gray
    Write-Host $Text.inst_tip2 -ForegroundColor Gray
    Write-Host $Text.inst_tip3 -ForegroundColor Gray
    Write-Host ""
    Write-Host "$($Text.inst_to_uninstall) uninstall.bat" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host $Text.inst_failed -ForegroundColor Red
}

Write-Host ""
Read-Host $Text.press_enter
