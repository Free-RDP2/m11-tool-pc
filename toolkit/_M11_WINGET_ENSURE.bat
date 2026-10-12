@echo off
rem ============================================================
rem  M11 TOOL - PC : winget availability gate (M11 Dev - Mohamed)
rem  Usage:  call "%~dp0_M11_WINGET_ENSURE.bat"
rem  Result: %M11_WINGET% = command to use (winget OR full path)
rem          errorlevel 0 = ready, 1 = not available
rem  NOTE: under SYSTEM, `where winget` fails even when App Installer
rem        exists, so we also look in the AppX locations first.
rem ============================================================
setlocal EnableDelayedExpansion
set "M11_WINGET=winget"

rem --- 1) already on PATH? -------------------------------------
where winget >nul 2>&1
if not errorlevel 1 (
    endlocal & set "M11_WINGET=winget" & exit /b 0
)

rem --- 2) per-user alias of any known profile -------------------
for %%U in ("M11 Dev-Tool" "runneradmin" "Admin" "Administrator") do (
    if exist "C:\Users\%%~U\AppData\Local\Microsoft\WindowsApps\winget.exe" (
        set "WEXE=C:\Users\%%~U\AppData\Local\Microsoft\WindowsApps\winget.exe"
        set "M11_WINGET=!WEXE!"
        set "PATH=!PATH!;C:\Users\%%~U\AppData\Local\Microsoft\WindowsApps"
        endlocal & set "M11_WINGET=!WEXE!" & set "PATH=%PATH%;C:\Users\%%~U\AppData\Local\Microsoft\WindowsApps" & exit /b 0
    )
)

rem --- 3) PowerShell search (AppX package locations) -----------
set "WEXE="
for /f "usebackq delims=" %%P in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_M11_WINGET_FIND.ps1" 2^>nul`) do set "WEXE=%%P"
if defined WEXE if exist "!WEXE!" (
    set "PATH=!PATH!;%~dp0"
    endlocal & set "M11_WINGET=!WEXE!" & exit /b 0
)

rem --- 4) last resort: bootstrap App Installer -----------------
set "BEXE="
for /f "usebackq delims=" %%P in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_M11_WINGET_BOOTSTRAP.ps1" 2^>nul`) do set "BEXE=%%P"
if defined BEXE if exist "!BEXE!" (
    endlocal & set "M11_WINGET=!BEXE!" & exit /b 0
)

endlocal & set "M11_WINGET=winget" & exit /b 1
