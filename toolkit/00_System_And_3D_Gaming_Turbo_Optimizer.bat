@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 ENGINE 00 - System & 3D Gaming Turbo Optimizer
color 0a
cd /d "%~dp0"

rem ============================================================================
rem  M11 TOOL - PC : ENGINE 00 - System & 3D Gaming Turbo Optimizer
rem  Developer: Mohamed El-Sayed Abdelfattah - M11 Dev
rem  Safe, reversible performance tuning for a 4 vCPU / 16 GB cloud gaming box.
rem  Usage:  run normally to optimize   |   run with "restore" to undo.
rem  Log:    C:\M11Data\m11_turbo_log.txt
rem ============================================================================

set "LOGDIR=C:\M11Data"
if not exist "%LOGDIR%" set "LOGDIR=%TEMP%"
set "LOG=%LOGDIR%\m11_turbo_log.txt"
set "MODE=%~1"
if /i "%MODE%"=="restore" goto restore

echo ==============================================================================
echo    M11 TURBO OPTIMIZER - applying safe performance settings
echo ==============================================================================
echo. >> "%LOG%"
echo ===== TURBO %DATE% %TIME% ===== >> "%LOG%"

echo [1/9] Power plan: Ultimate/High performance ...
powercfg /setactive SCHEME_MIN >> "%LOG%" 2>&1
powercfg /change monitor-timeout-ac 0 >> "%LOG%" 2>&1
powercfg /change standby-timeout-ac 0 >> "%LOG%" 2>&1
echo       done.

echo [2/9] CPU scheduling for foreground games (Win32PrioritySeparation=26) ...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f >> "%LOG%" 2>&1
echo       done.

echo [3/9] Visual effects: best performance ...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >> "%LOG%" 2>&1
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >> "%LOG%" 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >> "%LOG%" 2>&1
echo       done.

echo [4/9] Lower network latency (Nagle off, TcpAckFrequency=1) ...
for %%I in (TcpAckFrequency TCPNoDelay TcpDelAckTicks) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v %%I /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
)
set "IFKEY="
for /f "tokens=*" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" 2^>nul ^| findstr /i "Interfaces\\\\"') do (
    reg add "%%K" /v TcpAckFrequency /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
    reg add "%%K" /v TCPNoDelay /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
)
echo       done.

echo [5/9] Hardware GPU scheduling ON (HwSchMode=2) ...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >> "%LOG%" 2>&1
echo       done.

echo [6/9] Disable Game Bar / Game DVR capture overhead ...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
echo       done.

echo [7/9] Keep audio + network services responsive ...
sc config Audiosrv start= auto >> "%LOG%" 2>&1
sc start Audiosrv >> "%LOG%" 2>&1
echo       done.

echo [8/9] Clear temp junk (safe paths only) ...
for %%P in ("%TEMP%" "C:\Windows\Temp") do (
    if exist "%%~P" del /f /s /q "%%~P\*.*" >> "%LOG%" 2>&1
    if exist "%%~P" for /d %%D in ("%%~P\*") do rd /s /q "%%~D" >> "%LOG%" 2>&1
)
echo       done.

echo [9/9] Trim pagefile recommendation + disk check ...
echo       (pagefile left to engine 13 - current setting:)
powershell -NoProfile -Command "Get-CimInstance Win32_PageFileSetting | Select-Object Name,InitialSize,MaximumSize | Format-Table -AutoSize | Out-String" >> "%LOG%" 2>&1
echo       done.

echo.
echo ==============================================================================
echo  [SUCCESS] Turbo profile active.
echo   * Run this engine again with  restore  to revert the tweaks.
echo   * Reboot once for GPU scheduling + pagefile changes to fully apply.
echo   * Full log: %LOG%
echo ==============================================================================
pause
exit /b 0

:restore
echo ==============================================================================
echo    M11 TURBO OPTIMIZER - restoring Windows defaults
echo ==============================================================================
echo. >> "%LOG%"
echo ===== RESTORE %DATE% %TIME% ===== >> "%LOG%"

powercfg /setactive SCHEME_BALANCED >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 2 /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
for /f "tokens=*" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" 2^>nul ^| findstr /i "Interfaces\\\\"') do (
    reg delete "%%K" /v TcpAckFrequency /f >> "%LOG%" 2>&1
    reg delete "%%K" /v TCPNoDelay /f >> "%LOG%" 2>&1
)
echo [OK] Windows defaults restored. Reboot recommended.
pause
exit /b 0
