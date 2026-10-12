@echo off
rem =====================================================================
rem  M11 self-elevation guard (v1.14) - engines need admin rights
rem =====================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs" >nul 2>&1
    exit /b
)
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 UNIVERSAL STORE - Games ^& Apps Hub (v1.12)
color 0b
cd /d "%~dp0"

rem --- winget availability gate (works under SYSTEM too) ---
call "%~dp0_M11_WINGET_ENSURE.bat" <nul
set "WG_OK=%errorlevel%"
if not "%WG_OK%"=="0" (
    echo.
        echo  [!] winget is not available on this Windows build.
        echo      Fix: run this file again after Windows Update finishes,
        echo      or install "App Installer" from the Microsoft Store,
        echo      then run it again. Direct downloads are used meanwhile.
    echo.
)


:menu
cls
echo ==============================================================================
echo        M11 UNIVERSAL STORE - Games ^& Apps Hub ^(v1.12 fixed^)
echo        Developer: Mohamed El-Sayed Abdelfattah - M11 Dev
echo ==============================================================================
echo  Note: everything below is installed from the official free sources (winget).
echo  Important: paid games (GTA V / any paid game) must be bought
echo  from the official store. This hub installs launchers and stores only.
echo ==============================================================================
echo   [1]  Official game stores (Steam / Epic / Rockstar / EA)
echo   [2]  Browsers (Chrome / Brave / Firefox)
echo   [3]  Developer tools (VS Code / Git / Python / NodeJS)
echo   [4]  Communication tools (Discord / Zoom / TeamViewer)
echo   [5]  Archive and file tools (7-Zip / WinRAR / Everything)
echo   [6]  Free game tools (RetroArch / portable Steam)
echo   [7]  Upgrade every installed program
echo   [0]  Back
echo ==============================================================================
set "opt="
rem --- optional command line argument: M11 script 0|1|2... runs that entry directly ---
if not "%~1"=="" set "opt=%~1"
if defined opt goto dispatch
set /p opt="Choice [0-7]: "
if not defined opt (
    echo.
    echo [!] No input available ^(non-interactive session^) - closing.
    timeout /t 2 >nul
    exit /b 9
)
:dispatch

if "%opt%"=="1" goto stores
if "%opt%"=="2" goto browsers
if "%opt%"=="3" goto dev
if "%opt%"=="4" goto comm
if "%opt%"=="5" goto utils
if "%opt%"=="6" goto freegames
if "%opt%"=="7" goto upgrade
if "%opt%"=="0" exit /b 0
goto menu

:stores
cls
echo [1/4] Steam...
"%M11_WINGET%" install --id Valve.Steam -e --silent --accept-package-agreements --accept-source-agreements
echo [2/4] Epic Games Launcher...
"%M11_WINGET%" install --id EpicGames.EpicGamesLauncher -e --silent --accept-package-agreements --accept-source-agreements
echo [3/4] EA App...
"%M11_WINGET%" install --id ElectronicArts.EADesktop -e --silent --accept-package-agreements --accept-source-agreements
echo [4/4] Rockstar Games Launcher...
"%M11_WINGET%" install --id RockstarGames.Launcher -e --silent --accept-package-agreements --accept-source-agreements
echo [DONE] Official game stores installed. Sign in to buy/download your games.
pause
goto menu

:browsers
cls
echo [1/3] Google Chrome...
"%M11_WINGET%" install --id Google.Chrome -e --silent --accept-package-agreements --accept-source-agreements
echo [2/3] Brave...
"%M11_WINGET%" install --id Brave.Brave -e --silent --accept-package-agreements --accept-source-agreements
echo [3/3] Firefox...
"%M11_WINGET%" install --id Mozilla.Firefox -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:dev
cls
echo [1/4] Visual Studio Code...
"%M11_WINGET%" install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements --accept-source-agreements
echo [2/4] Git...
"%M11_WINGET%" install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
echo [3/4] Python 3.12...
"%M11_WINGET%" install --id Python.Python.3.12 -e --silent --accept-package-agreements --accept-source-agreements
echo [4/4] NodeJS LTS...
"%M11_WINGET%" install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:comm
cls
echo [1/3] Discord...
"%M11_WINGET%" install --id Discord.Discord -e --silent --accept-package-agreements --accept-source-agreements
echo [2/3] Zoom...
"%M11_WINGET%" install --id Zoom.Zoom -e --silent --accept-package-agreements --accept-source-agreements
echo [3/3] TeamViewer...
"%M11_WINGET%" install --id TeamViewer.TeamViewer -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:utils
cls
echo [1/3] 7-Zip...
"%M11_WINGET%" install --id 7zip.7zip -e --silent --accept-package-agreements --accept-source-agreements
echo [2/3] RAR...
"%M11_WINGET%" install --id RARLab.WinRAR -e --silent --accept-package-agreements --accept-source-agreements
echo [3/3] Everything search...
"%M11_WINGET%" install --id voidtools.Everything -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:freegames
cls
echo [1/2] RetroArch (free open-source multi-system emulator)...
"%M11_WINGET%" install --id Libretro.RetroArch -e --silent --accept-package-agreements --accept-source-agreements
echo [2/2] itch.io app (free indie games)...
"%M11_WINGET%" install --id ItchIo.Itch -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:upgrade
cls
echo Upgrading all installed packages...
"%M11_WINGET%" upgrade --all --silent --accept-package-agreements --accept-source-agreements
pause
goto menu
