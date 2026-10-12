@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 MASTER RUNNER - Control Center (v1.12 FIXED)
color 0b
cd /d "%~dp0"

rem ===========================================================================
rem  M11 MASTER RUNNER (fixed build v1.12)
rem  - Auto-detects the toolkit folder (works from Desktop or inside the folder)
rem  - Every menu entry is verified with EXISTAN before it is offered
rem  - Pure ASCII launcher body + UTF-8 file output = zero mojibake
rem  Architect: M11 Dev - Mohamed
rem ===========================================================================

set "SELF=%~dp0"
set "ENG="

rem --- Locate the engines folder no matter where we run from ------------------
if exist "%SELF%Engines_And_Scripts\" set "ENG=%SELF%Engines_And_Scripts"
if exist "%SELF%_Engines_And_Scripts\" set "ENG=%SELF%_Engines_And_Scripts"
for /d %%D in ("%SELF%*_Engines_And_Scripts") do set "ENG=%%~fD"
if not defined ENG if exist "%SELF%..\_Engines_And_Scripts\" set "ENG=%SELF%..\_Engines_And_Scripts"
for /d %%D in ("%SELF%..\*_Engines_And_Scripts") do set "ENG=%%~fD"

if not defined ENG (
    echo [!] Engines folder not found next to this runner.
    echo     Expected: M11_TOOL_PC\[name]_Engines_And_Scripts
    echo.
    pause
    exit /b 1
)

:menu
cls
echo ==============================================================================
echo      M11 TOOL - PC ^| MASTER RUNNER ^(v1.12 fixed build^)
echo      Engines folder: %ENG%
echo ==============================================================================
echo   [1] System ^& 3D Gaming Turbo Optimizer        ^(run first^)
echo   [2] Unblock Internet / Outlook / Browsers     ^(run first^)
echo   [3] Roblox deep fix ^+ installer
echo   [4] All-in-one gaming runtimes ^(DirectX, VC++, PhysX^)
echo   [5] DirectX11 WARP / software GPU booster
echo   [6] Install developer ^& productivity apps
echo   [7] Free disk space
echo   [8] Cloud backup ^(save your files^)
echo   [9] Cloud session auto-restore
echo   [A] Audio ^& microphone virtual cable
echo   [B] Internet speed ^& ping booster
echo   [C] Virtual RAM ^(32GB pagefile^)
echo   [D] Creative media ^& recording suite
echo   [E] GTA V ^& heavy games downloader
echo   [F] Universal package manager ^(winget/choco^)
echo   [T] Self test ^(verify every file^)
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

if /i "%opt%"=="1" set "F=00_System_And_3D_Gaming_Turbo_Optimizer.bat" & goto runfirst
if /i "%opt%"=="2" set "F=09_Internet_Speed_And_Ping_Booster.bat" & goto run
if /i "%opt%"=="3" set "F=01_Roblox_Deep_Fix_And_Installer.bat" & goto run
if /i "%opt%"=="4" set "F=11_All_In_One_Gaming_Runtimes_AIO.bat" & goto run
if /i "%opt%"=="5" set "F=03_DirectX11_WARP_Mesa3D_GPU_Booster.bat" & goto run
if /i "%opt%"=="6" set "F=06_Install_Developer_And_Productivity_Apps.bat" & goto run
if /i "%opt%"=="7" set "F=04_Free_Up_100GB_Disk_Space.bat" & goto run
if /i "%opt%"=="8" set "F=07_Instant_Cloud_Backup.bat" & goto run
if /i "%opt%"=="9" set "F=08_Cloud_Session_Auto_Restorer.bat" & goto run
if /i "%opt%"=="A" set "F=10_Audio_Microphone_Virtual_Cable.bat" & goto run
if /i "%opt%"=="B" set "F=09_Internet_Speed_And_Ping_Booster.bat" & goto run
if /i "%opt%"=="C" set "F=13_Virtual_RAM_32GB_Pagefile_Booster.bat" & goto run
if /i "%opt%"=="D" set "F=14_Creative_Media_And_Recording_Suite.bat" & goto run
if /i "%opt%"=="E" set "F=15_GTA_V_And_Heavy_Games_Downloader.bat" & goto run
if /i "%opt%"=="F" set "F=12_Universal_Package_Manager_Winget_Choco.bat" & goto run
if /i "%opt%"=="T" goto selftest
if "%opt%"=="0" exit /b 0
echo [!] Invalid choice.
timeout /t 2 >nul
goto menu

:runfirst
rem Option 1 = turbo optimizer lives outside the engines folder in some builds
if exist "%ENG%\%F%" goto run
if exist "%SELF%01_Roblox_Deep_Fix_And_Installer.bat" set "ENG=%SELF%" & goto run
echo [!] File not found: %F%
pause
goto menu

:run
set "TARGET=%ENG%\%F%"
if not exist "%TARGET%" (
    echo [!] Missing engine file: %TARGET%
    echo     Run the Self Test [T] to verify the toolkit.
    pause
    goto menu
)
echo [RUN] %TARGET%
call "%TARGET%"
echo.
echo [DONE] Engine finished. Press any key to return to the menu.
pause >nul
goto menu

:selftest
set "TARGET=%SELF%_M11_SELF_TEST.bat"
if not exist "%TARGET%" set "TARGET=%ENG%\_M11_SELF_TEST.bat"
if not exist "%TARGET%" (
    echo [!] Self test not found.
    pause
    goto menu
)
call "%TARGET%"
pause
goto menu
