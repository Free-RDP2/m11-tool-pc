@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 SELF TEST - Toolkit Verification
color 0e

set "HOME_DIR=%USERPROFILE%\Desktop"
set "REPORT=%HOME_DIR%\M11_SELF_TEST_REPORT.txt"
set "FAIL=0"
set "PASS=0"
if not exist "%HOME_DIR%" set "HOME_DIR=C:\M11Data" & if not exist "%HOME_DIR%" mkdir "%HOME_DIR%"
set "REPORT=%HOME_DIR%\M11_SELF_TEST_REPORT.txt"

echo M11 SELF TEST REPORT > "%REPORT%"
echo Generated: %DATE% %TIME% >> "%REPORT%"
echo ============================================================ >> "%REPORT%"

echo.
echo --- SYSTEM ---
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName >> "%REPORT%" 2>&1
net session >nul 2>&1
if errorlevel 1 ( call :bad "Administrator rights" ) else ( call :ok "Administrator rights" )

netstat -ano | findstr /r /c:":3389 .*LISTENING" >nul 2>&1
if errorlevel 1 ( call :bad "RDP 3389 listening" ) else ( call :ok "RDP 3389 listening" )

if exist "C:\Program Files\Tailscale\tailscale.exe" ( call :ok "Tailscale installed" ) else ( call :bad "Tailscale installed" )

sc query Audiosrv | findstr /i RUNNING >nul 2>&1
if errorlevel 1 ( call :bad "Audio service running" ) else ( call :ok "Audio service running" )

sc query TermService | findstr /i RUNNING >nul 2>&1
if errorlevel 1 ( call :bad "TermService running" ) else ( call :ok "TermService running" )

echo.
echo --- AUTOLOGON ---
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon >> "%REPORT%" 2>&1
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon 2^>nul ^| findstr AutoAdminLogon') do set "AL=%%A"
if "%AL%"=="0x1" ( call :ok "Auto-logon enabled" ) else ( call :bad "Auto-logon enabled (value=%AL%)" )

for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fSingleSessionPerUser 2^>nul ^| findstr fSingleSessionPerUser') do set "SS=%%A"
if "%SS%"=="0x1" ( call :ok "Single session per user" ) else ( call :bad "Single session per user (value=%SS%)" )

echo.
echo --- TOOLKIT FILES ---
set "HERE=%~dp0"
set "ENG="
if exist "%HERE%_Engines_And_Scripts\" set "ENG=%HERE%_Engines_And_Scripts"
for /d %%D in ("%HERE%*_Engines_And_Scripts") do set "ENG=%%~fD"
if not defined ENG for /d %%D in ("%HERE%..\*_Engines_And_Scripts") do set "ENG=%%~fD"

if exist "%HERE%M11_MASTER_RUNNER.bat" ( call :ok "runner: M11_MASTER_RUNNER.bat" ) else ( call :bad "runner: M11_MASTER_RUNNER.bat" )
if exist "%HERE%M11_MASTER_CONTROL_CENTER.bat" ( call :ok "center: M11_MASTER_CONTROL_CENTER.bat" ) else ( call :bad "center: M11_MASTER_CONTROL_CENTER.bat" )
if defined ENG ( call :ok "engines folder: %ENG%" ) else ( call :bad "engines folder missing" )

if defined ENG (
  for %%E in ("%ENG%\*.bat") do call :ok "engine: %%~nxE"
)

echo.
echo --- MOJIBAKE SCAN ---
powershell -NoProfile -ExecutionPolicy Bypass -Command "$bad=0; $dirs=@('C:\Users\M11 Dev-Tool\Desktop','C:\Users\runneradmin\Desktop','C:\Users\Public\Desktop') ^| Where-Object { Test-Path $_ }; foreach($d in $dirs){ Get-ChildItem $d -Recurse -Force -ErrorAction SilentlyContinue ^| ForEach-Object { if($_.Name -match '^\?+'){ $bad++; Write-Host ('  BAD NAME: ' + $_.FullName) } elseif(-not $_.PSIsContainer -and $_.Length -lt 300000 -and $_.Extension -match '\.(bat|cmd|ps1|txt|json)$'){ $t=[IO.File]::ReadAllText($_.FullName); if($t -match '\?\?\?\?\?'){ $bad++; Write-Host ('  BAD CONTENT: ' + $_.FullName) } } } }; if($bad -eq 0){ Write-Host '  CLEAN: no mojibake found' } else { Write-Host ('  FOUND ' + $bad + ' mojibake items') }" 2>&1 | powershell -NoProfile -Command "$input | Tee-Object -FilePath '%REPORT%' -Append"

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
echo (press any key to close)
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
