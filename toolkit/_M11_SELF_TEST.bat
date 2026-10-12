@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 SELF TEST - Toolkit Verification (v1.12)
color 0e

set "HERE=%~dp0"
set "REPORT=%USERPROFILE%\Desktop\M11_SELF_TEST_REPORT.txt"
if not exist "%USERPROFILE%\Desktop" set "REPORT=C:\M11Data\M11_SELF_TEST_REPORT.txt"
set "PASS=0"
set "FAIL=0"

echo M11 SELF TEST REPORT (v1.12) > "%REPORT%"
echo Generated: %DATE% %TIME% >> "%REPORT%"
echo ============================================================ >> "%REPORT%"

echo.
echo --- SYSTEM ---
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName >> "%REPORT%" 2>&1

net session >nul 2>&1
if errorlevel 1 ( call :bad "Administrator rights" ) else ( call :ok "Administrator rights" )

netstat -ano | findstr /r /c:":3389 .*LISTENING" >nul 2>&1
if errorlevel 1 ( call :bad "RDP port 3389 listening" ) else ( call :ok "RDP port 3389 listening" )

if exist "C:\Program Files\Tailscale\tailscale.exe" ( call :ok "Tailscale installed" ) else ( call :bad "Tailscale installed" )

sc query Audiosrv | findstr /i RUNNING >nul 2>&1
if errorlevel 1 ( call :bad "Audio service running" ) else ( call :ok "Audio service running" )

sc query TermService | findstr /i RUNNING >nul 2>&1
if errorlevel 1 ( call :bad "TermService running" ) else ( call :ok "TermService running" )

echo.
echo --- LOGIN / SESSION POLICY ---
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon 2^>nul ^| findstr AutoAdminLogon') do set "AL=%%A"
if /i "%AL%"=="0x1" ( call :ok "Auto-logon enabled" ) else if "%AL%"=="1" ( call :ok "Auto-logon enabled" ) else ( call :bad "Auto-logon enabled (value=%AL%)" )

for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fSingleSessionPerUser 2^>nul ^| findstr fSingleSessionPerUser') do set "SS=%%A"
if /i "%SS%"=="0x1" ( call :ok "Single session per user" ) else if "%SS%"=="1" ( call :ok "Single session per user" ) else ( call :bad "Single session per user (value=%SS%)" )

echo.
echo --- TOOLKIT FILES ---
rem name-independent: the launchers may carry an emoji/ASCII prefix
set "F_RUN="
for %%R in ("%HERE%*MASTER_RUNNER*.bat") do set "F_RUN=%%~nxR"
if defined F_RUN ( call :ok "runner found: %F_RUN%" ) else ( call :bad "runner launcher missing" )

set "F_CC="
for %%R in ("%HERE%*MASTER_CONTROL_CENTER*.bat") do set "F_CC=%%~nxR"
if defined F_CC ( call :ok "control center found: %F_CC%" ) else ( call :bad "control center missing" )

set "F_ST="
for %%R in ("%HERE%*M11_UNIVERSAL_STORE*.bat") do set "F_ST=%%~nxR"
if defined F_ST ( call :ok "universal store found: %F_ST%" ) else ( call :bad "universal store missing" )

set "F_GH="
for %%R in ("%HERE%*M11_GAMES_HUB*.bat") do set "F_GH=%%~nxR"
if not defined F_GH for %%R in ("%HERE%*DOWNLOAD_GTA_V_AND_HEAVY_GAMES*.bat") do set "F_GH=%%~nxR"
if defined F_GH ( call :ok "games hub found: %F_GH%" ) else ( call :bad "games hub missing" )

set "ENG="
if exist "%HERE%_Engines_And_Scripts\" set "ENG=%HERE%_Engines_And_Scripts"
if not defined ENG for /d %%D in ("%HERE%*Engines_And_Scripts*") do set "ENG=%%~fD"

if defined ENG (
  call :ok "engines folder found"
  for %%E in ("%ENG%\[0-9]*.bat") do call :ok "engine: %%~nxE"
) else (
  call :bad "engines folder found"
)

echo.
echo --- TOOLS ---
where curl >nul 2>&1
if errorlevel 1 ( echo    note: curl not found in PATH >> "%REPORT%" ) else ( echo    curl OK >> "%REPORT%" )

call "%HERE%_M11_WINGET_ENSURE.bat" <nul >nul 2>&1
if errorlevel 1 (
  echo  [INFO] winget not available - launchers will use direct downloads
  echo  [INFO] winget not available - direct-download fallback active >> "%REPORT%"
) else (
  echo        resolved: %M11_WINGET% >> "%REPORT%"
  if "%M11_WINGET%"=="winget" ( call :ok "winget available on PATH" ) else ( call :ok "winget found: %M11_WINGET%" )
)

echo.
echo --- MOJIBAKE / INTEGRITY SCAN ---
if exist "%HERE%_M11_MOJI_CHECK.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%_M11_MOJI_CHECK.ps1" 2>&1 | findstr /v "^$"
) else (
  echo   ^(checker not found - skipping^)
)

echo.
echo --- SESSION STATE ---
query user >> "%REPORT%" 2>&1
query user

echo.
echo ============================================================
echo  RESULT: %PASS% passed, %FAIL% failed
echo  Full report: %REPORT%
echo ============================================================
echo RESULT: %PASS% passed, %FAIL% failed >> "%REPORT%"
if /i "%~1"=="nopause" exit /b 0
echo ^(press any key to close^)
pause >nul
exit /b 0

:ok
set /a PASS+=1
echo  [PASS] %~1
echo  [PASS] %~1 >> "%REPORT%"
exit /b 0

:bad
set /a FAIL+=1
echo  [FAIL] %~1
echo  [FAIL] %~1 >> "%REPORT%"
exit /b 0
