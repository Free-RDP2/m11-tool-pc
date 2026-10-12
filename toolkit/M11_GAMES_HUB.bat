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
title M11 GAMES HUB - Official Launchers ^& Free Games (v1.12)
color 0c
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
echo        M11 GAMES HUB - Official Game Launchers ^& Free Games ^(v1.12 fixed^)
echo        Developer: Mohamed El-Sayed Abdelfattah - M11 Dev
echo ==============================================================================
echo  Specs: 16GB RAM ^| 4 vCPU ^| Windows Server ^| Direct3D 11 WARP
echo  Note: this hub installs official stores and free games only.
echo  Paid games (like GTA V) are bought and downloaded from the official store with your account.
echo ==============================================================================
echo   [1]  Install all official stores (Steam + Epic + EA + Rockstar)
echo   [2]  Steam only
echo   [3]  Epic Games only
echo   [4]  Rockstar Games Launcher only (for the official GTA V)
echo   [5]  Free games: RetroArch + itch.io
echo   [6]  Official Minecraft (Bedrock, from the Microsoft Store)
echo   [7]  Legacy game graphics setup (WARP + DirectX 9)
echo   [8]  Performance check (FPS / clock sync)
echo   [0]  Back
echo ==============================================================================
set "opt="
rem --- optional command line argument: M11 script 0|1|2... runs that entry directly ---
if not "%~1"=="" set "opt=%~1"
if defined opt goto dispatch
set /p opt="Choice [0-8]: "
if not defined opt (
    echo.
    echo [!] No input available ^(non-interactive session^) - closing.
    timeout /t 2 >nul
    exit /b 9
)
:dispatch

if "%opt%"=="1" goto allstores
if "%opt%"=="2" goto steam
if "%opt%"=="3" goto epic
if "%opt%"=="4" goto rockstar
if "%opt%"=="5" goto freegames
if "%opt%"=="6" goto minecraft
if "%opt%"=="7" goto dx9fix
if "%opt%"=="8" goto perf
if "%opt%"=="0" exit /b 0
goto menu

:allstores
call :install "Valve.Steam" "Steam"
call :install "EpicGames.EpicGamesLauncher" "Epic Games"
call :install "ElectronicArts.EADesktop" "EA App"
call :install "RockstarGames.Launcher" "Rockstar Games Launcher"
echo.
echo [DONE] Official stores installed. Sign in with your account, then download your games.
pause
goto menu

:steam
call :install "Valve.Steam" "Steam"
pause
goto menu

:epic
call :install "EpicGames.EpicGamesLauncher" "Epic Games"
pause
goto menu

:rockstar
call :install "RockstarGames.Launcher" "Rockstar Games Launcher"
pause
goto menu

:freegames
call :install "Libretro.RetroArch" "RetroArch"
call :install "ItchIo.Itch" "itch.io"
pause
goto menu

:minecraft
call :install "Microsoft.MinecraftUWP" "Minecraft Bedrock"
pause
goto menu

:dx9fix
cls
echo [1/4] DirectX 9.0c runtime...
if exist "C:\M11Data\dx9\DXSETUP.exe" ( start /wait "" "C:\M11Data\dx9\DXSETUP.exe" /silent ) else ( echo  (skip: installer not staged) )
echo [2/4] DirectPlay legacy feature...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-WindowsOptionalFeature -Online -FeatureName DirectPlay -NoRestart -WarningAction SilentlyContinue | Out-Null" 2>nul
echo [3/4] Direct3D WARP software renderer flag...
reg add "HKLM\SOFTWARE\Microsoft\Direct3D\Drivers" /v "SoftwareOnly" /t REG_DWORD /d 0 /f >nul 2>&1
echo [4/4] dgVoodoo2 wrapper (if staged)...
if exist "C:\M11Data\dgVoodoo2\dgVoodoo.conf" (
    copy /y "C:\M11Data\dgVoodoo2\*.*" "C:\Windows\System32\" >nul 2>&1
    echo  dgVoodoo2 copied to System32.
) else (
    echo  ^(skip: dgVoodoo2 not staged in C:\M11Data\dgVoodoo2^)
)
echo [DONE] Legacy game compatibility enabled ^(DirectX 9 / WARP^).
pause
goto menu

:perf
cls
echo Opening Task Manager ^(Performance tab^)...
start "" taskmgr
echo.
echo Tip: over RDP, games rely on the CPU ^(software rendering^).
echo Lower the resolution to 1280x720 for the highest FPS.
pause
goto menu

:direct
rem ============================================================
rem  direct-download fallback (used only when winget is missing)
rem ============================================================
set "DL=%TEMP%\m11_dl_setup"
set "EXT=exe"
set "URL="
if /i "%~1"=="Valve.Steam"                 set "URL=https://cdn.fastly.steamstatic.com/client/installer/SteamSetup.exe"
if /i "%~1"=="EpicGames.EpicGamesLauncher" set "URL=https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi" & set "EXT=msi"
if /i "%~1"=="RockstarGames.Launcher"      set "URL=https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe"
if /i "%~1"=="Ubisoft.Connect"             set "URL=https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe"
if not defined URL (
        echo [!] No direct download available for this item without winget: %~1
        echo     Install App Installer from the Microsoft Store, then retry.
    exit /b 1
)
set "DL=%DL%.%EXT%"
echo      [direct] downloading: %~1
curl -sL --retry 3 --max-time 1200 -o "%DL%" "%URL%"
if not exist "%DL%" (
        echo [!] direct download failed for %~1
    exit /b 1
)
if /i "%EXT%"=="msi" (
    msiexec /i "%DL%" /qn /norestart
) else (
    start "" /wait "%DL%"
)
echo [OK] direct install started: %~1
exit /b 0

:install
echo.
echo [INSTALL] %~2 ...
if "%WG_OK%"=="0" ( "%M11_WINGET%" install --id %~1 -e --silent --accept-package-agreements --accept-source-agreements ) else ( call :direct %~1 )
if errorlevel 1 (
        echo [!] winget install failed: %~1
        echo     try later: winget install --id %~1 -e
) else (
    echo [OK] %~2
)
exit /b 0
