@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 TOOL - PC ^| MASTER CONTROL CENTER (v1.12)
color 0b
cd /d "%~dp0"

set "DESKTOP_DIR=%~dp0"
set "TOOL_DIR="
if exist "%DESKTOP_DIR%M11_TOOL_PC\" set "TOOL_DIR=%DESKTOP_DIR%M11_TOOL_PC"
for /d %%D in ("%DESKTOP_DIR%*M11_TOOL_PC") do set "TOOL_DIR=%%~fD"
if exist "%DESKTOP_DIR%..\M11_TOOL_PC\" set "TOOL_DIR=%DESKTOP_DIR%..\M11_TOOL_PC"

:main_menu
cls
echo ==============================================================================
echo       M11 TOOL - PC ^| MASTER GAMING ^& CLOUD CONTROL CENTER ^(v1.12^)
echo   Developer : Mohamed El-Sayed Abdelfattah - M11 Dev ^(M11 Developer^)
echo   Hardware  : 16GB RAM ^| 4 vCPUs ^| Cloud Windows Server ^| Bilingual EN+AR
echo ==============================================================================
echo   [1] Open the full toolkit menu ^(all engines^)
echo   [2] Unblock internet / Outlook / downloads        [MANDATORY]
echo   [3] Roblox player ^& studio hub                   [RECOMMENDED]
echo   [4] All-in-one runtimes ^(DirectX9/11, VC++, PhysX^)
echo   [5] DirectX9 game compatibility injector ^(WARP/dgVoodoo^)
echo   [6] Essential apps ^(Chrome, Discord, VS Code, 7-Zip^)
echo   [7] Free disk space ^+ secondary drive
echo   [8] GTA V ^& heavy games downloader
echo   [9] Save my files to the cloud ^(backup^)
echo   [K] Enable Arabic ^+ English keyboard ^(Alt+Shift^)
echo   [S] Verify the toolkit ^(self test^)
echo   [0] Exit
echo ==============================================================================
set "opt="
rem --- optional command line argument: M11 script 0|1|2... runs that entry directly ---
if not "%~1"=="" set "opt=%~1"
if defined opt goto dispatch
set /p opt="Choice: "
if not defined opt (
    echo.
    echo [!] No input available ^(non-interactive session^) - closing.
    timeout /t 2 >nul
    exit /b 9
)
:dispatch

if /i "%opt%"=="1" goto open_toolkit
if /i "%opt%"=="2" goto net
if /i "%opt%"=="3" goto roblox
if /i "%opt%"=="4" goto runtimes
if /i "%opt%"=="5" goto injector
if /i "%opt%"=="6" goto apps
if /i "%opt%"=="7" goto storage
if /i "%opt%"=="8" goto games
if /i "%opt%"=="9" goto backup
if /i "%opt%"=="k" goto keyboard
if /i "%opt%"=="s" goto selftest
if "%opt%"=="0" exit /b 0
echo [!] Invalid choice "%opt%".
timeout /t 2 >nul
goto main_menu

:open_toolkit
if not defined TOOL_DIR (
    echo [!] Toolkit folder not found next to this launcher.
    pause
    goto main_menu
)
rem --- find the runner whatever its prefix is (emoji/ASCII/underscore) ---
set "RUNNER="
for %%R in ("%TOOL_DIR%\*MASTER_RUNNER*.bat") do set "RUNNER=%%~fR"
if not defined RUNNER for %%R in ("%~dp0*MASTER_RUNNER*.bat") do set "RUNNER=%%~fR"
if not defined RUNNER for /d %%D in ("%TOOL_DIR%\*Engines_And_Scripts*") do for %%R in ("%%~fD\*MASTER_RUNNER*.bat") do set "RUNNER=%%~fR"
if not defined RUNNER (
    echo [!] Runner not found inside "%TOOL_DIR%".
    dir /b "%TOOL_DIR%"
    pause
    goto main_menu
)
call "%RUNNER%"
goto main_menu

:net
call :engine "09_Internet_Speed_And_Ping_Booster.bat"
goto main_menu

:roblox
call :engine "01_Roblox_Deep_Fix_And_Installer.bat"
goto main_menu

:runtimes
call :engine "11_All_In_One_Gaming_Runtimes_AIO.bat"
goto main_menu

:injector
call :engine "03_DirectX11_WARP_Mesa3D_GPU_Booster.bat"
goto main_menu

:apps
call :engine "06_Install_Developer_And_Productivity_Apps.bat"
goto main_menu

:storage
call :engine "04_Free_Up_100GB_Disk_Space.bat"
goto main_menu

:games
call :engine "15_GTA_V_And_Heavy_Games_Downloader.bat"
goto main_menu

:backup
call :engine "07_Instant_Cloud_Backup.bat"
goto main_menu

:selftest
call :engine "_M11_SELF_TEST.bat"
goto main_menu

:keyboard
cls
echo [K] Enabling Arabic ^+ English keyboard layout...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Set-WinUserLanguageList -LanguageList en-US,ar-EG -Force -ErrorAction Stop; 'OK' } catch { 'SKIP' }" >nul 2>&1
reg add "HKCU\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
reg add "HKCU\Keyboard Layout\Preload" /v "2" /t REG_SZ /d "00000401" /f >nul 2>&1
echo [SUCCESS] Arabic ^(101^) + English ^(US^) added. Toggle with Alt+Shift.
timeout /t 3 >nul
goto main_menu

:engine
rem %~1 = engine file name ; searches toolkit then engines folder
set "TARGET="
set "ENG_DIR="
if defined TOOL_DIR for /d %%D in ("%TOOL_DIR%\*Engines_And_Scripts*") do set "ENG_DIR=%%~fD"
if defined TOOL_DIR if exist "%TOOL_DIR%\%~1" set "TARGET=%TOOL_DIR%\%~1"
if not defined TARGET if defined ENG_DIR if exist "%ENG_DIR%\%~1" set "TARGET=%ENG_DIR%\%~1"
if not defined TARGET if defined TOOL_DIR if exist "%TOOL_DIR%\_Engines_And_Scripts\%~1" set "TARGET=%TOOL_DIR%\_Engines_And_Scripts\%~1"
if not defined TARGET if exist "%~dp0%~1" set "TARGET=%~dp0%~1"
if not defined TARGET for /d %%D in ("%~dp0*Engines_And_Scripts*") do if exist "%%~fD\%~1" set "TARGET=%%~fD\%~1"
if not defined TARGET if exist "%~dp0..\%~1" set "TARGET=%~dp0..\%~1"
if not defined TARGET (
    echo [!] Engine not found: %~1
    echo     Run the Self Test [S] to verify the installation.
    pause
    exit /b 1
)
echo [RUN] %TARGET%
call "%TARGET%"
echo.
echo [DONE] Press any key to return.
pause >nul
exit /b 0
