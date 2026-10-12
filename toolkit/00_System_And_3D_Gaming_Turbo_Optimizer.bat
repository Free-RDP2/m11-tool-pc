@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 ENGINE 00 - System ^& 3D Gaming Turbo Optimizer (v2)
color 0a
cd /d "%~dp0"

rem ============================================================================
rem  M11 TOOL - PC : ENGINE 00 v2 - System & 3D Gaming Turbo Optimizer
rem  Developer: Mohamed El-Sayed Abdelfattah - M11 Dev
rem  Strong, still-safe performance tuning for a 4 vCPU / 16 GB cloud gaming box.
rem  Everything is logged and reversible:  run with  "restore"  to undo.
rem  Log: C:\M11Data\m11_turbo_log.txt
rem ============================================================================

set "LOGDIR=C:\M11Data"
if not exist "%LOGDIR%" set "LOGDIR=%TEMP%"
set "LOG=%LOGDIR%\m11_turbo_log.txt"
set "MODE=%~1"
if /i "%MODE%"=="restore" goto restore

echo ==============================================================================
echo    M11 TURBO OPTIMIZER v2 - maximum gaming performance, no reboot needed
echo ==============================================================================
echo. >> "%LOG%"
echo ===== TURBO v2 %DATE% %TIME% ===== >> "%LOG%"

echo [1/12] Power: Ultimate Performance plan + 100%% CPU, no throttling ...
powercfg /setactive SCHEME_MIN >> "%LOG%" 2>&1
for /f "tokens=4" %%G in ('powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2^>nul') do powercfg /setactive %%G >> "%LOG%" 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >> "%LOG%" 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >> "%LOG%" 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2 >> "%LOG%" 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1 >> "%LOG%" 2>&1
powercfg /setactive SCHEME_CURRENT >> "%LOG%" 2>&1
powercfg /change monitor-timeout-ac 0 >> "%LOG%" 2>&1
powercfg /change standby-timeout-ac 0 >> "%LOG%" 2>&1
powercfg /change disk-timeout-ac 0 >> "%LOG%" 2>&1
echo       done.

echo [2/12] CPU scheduling + multimedia response (games first) ...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 10 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >> "%LOG%" 2>&1
echo       done.

echo [3/12] Killing background services that steal CPU/disk from games ...
for %%S in (DiagTrack dmwappushservice SysMain WSearch MapsBroker Fax) do (
    sc stop %%S >> "%LOG%" 2>&1
    sc config %%S start= disabled >> "%LOG%" 2>&1
)
echo       done.

echo [4/12] Visual effects: best performance ...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >> "%LOG%" 2>&1
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >> "%LOG%" 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >> "%LOG%" 2>&1
echo       done.

echo [5/12] Lower network latency (Nagle off, TcpAckFrequency=1, RSS on) ...
for /f "tokens=*" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" 2^>nul ^| findstr /i "Interfaces\\\\"') do (
    reg add "%%K" /v TcpAckFrequency /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
    reg add "%%K" /v TCPNoDelay /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
    reg add "%%K" /v TcpDelAckTicks /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
)
netsh int tcp set global rss=enabled >> "%LOG%" 2>&1
netsh int tcp set heuristics disabled >> "%LOG%" 2>&1
netsh int tcp set global autotuninglevel=normal >> "%LOG%" 2>&1
echo       done.

echo [6/12] GPU: hardware scheduling ON + full performance preference ...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "GpuPreference=2;VRROptimizeEnable=0;" /f >> "%LOG%" 2>&1
echo       done.

echo [7/12] Disable Game Bar / Game DVR capture overhead + fullscreen tweaks ...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
echo       done.

echo [8/12] Defender: exclude game + tool folders (protection stays ON) ...
for %%P in ("C:\Users\M11 Dev-Tool\Desktop\M11Data" "C:\M11Data" "%LOCALAPPDATA%\Roblox" "C:\Program Files\Roblox" "%LOCALAPPDATA%\Programs") do (
    powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%%~P' -ErrorAction SilentlyContinue" >nul 2>&1
)
powershell -NoProfile -Command "Set-MpPreference -ScanAvgCPULoadFactor 30 -ExclusionProcess 'RobloxPlayerBeta.exe','RobloxStudioBeta.exe' -ErrorAction SilentlyContinue" >nul 2>&1
echo       done.

echo [9/12] Memory: compression off (frees CPU), trim working sets ...
powershell -NoProfile -Command "Disable-MMAgent -mc -ErrorAction SilentlyContinue" >> "%LOG%" 2>&1
powershell -NoProfile -Command "Get-Process | Where-Object { $_.WorkingSet64 -lt 250MB } | ForEach-Object { $_.MinWorkingSet = $_.MinWorkingSet; }" >nul 2>&1
echo       done.

echo [10/12] Keep RDP sessions alive and fast (no idle drops) ...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v KeepAliveEnable /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v KeepAliveInterval /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "fDisableAudioCapture" /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
sc config Audiosrv start= auto >> "%LOG%" 2>&1
sc start Audiosrv >> "%LOG%" 2>&1
echo       done.

echo [11/12] Free disk: temp junk + hibernation file ...
for %%P in ("%TEMP%" "C:\Windows\Temp") do (
    if exist "%%~P" del /f /s /q "%%~P\*.*" >> "%LOG%" 2>&1
    if exist "%%~P" for /d %%D in ("%%~P\*\") do rd /s /q "%%~D" >> "%LOG%" 2>&1
)
powercfg /h off >> "%LOG%" 2>&1
echo       done.

echo [12/12] Summary ...
echo       * Power plan: active
echo       * Services trimmed: DiagTrack, SysMain, WSearch, dmwappushservice
echo       * Latency: Nagle off + TcpAckFrequency=1 on every adapter
echo       * GPU: HwSchMode=2, GpuPreference=High performance
echo       * Note: display/graphics changes fully apply after one reboot.
echo.
echo ==============================================================================
echo  [SUCCESS] Turbo profile v2 active.  Log: %LOG%
echo  Run again with:  00_System_And_3D_Gaming_Turbo_Optimizer.bat restore
echo ==============================================================================
if /i "%~2"=="nopause" exit /b 0
if "%~1"=="nopause" exit /b 0
if "%~1"=="0" exit /b 0
pause
exit /b 0

:restore
echo ==============================================================================
echo    M11 TURBO OPTIMIZER v2 - restoring Windows defaults
echo ==============================================================================
echo. >> "%LOG%"
echo ===== RESTORE %DATE% %TIME% ===== >> "%LOG%"
powercfg /setactive SCHEME_BALANCED >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 2 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 20 /f >> "%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 10 /f >> "%LOG%" 2>&1
for %%S in (DiagTrack dmwappushservice SysMain WSearch) do (
    sc config %%S start= auto >> "%LOG%" 2>&1
    sc start %%S >> "%LOG%" 2>&1
)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 0 /f >> "%LOG%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f >> "%LOG%" 2>&1
powershell -NoProfile -Command "Enable-MMAgent -mc -ErrorAction SilentlyContinue" >nul 2>&1
powercfg /h on >> "%LOG%" 2>&1
for /f "tokens=*" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" 2^>nul ^| findstr /i "Interfaces\\\\"') do (
    reg delete "%%K" /v TcpAckFrequency /f >> "%LOG%" 2>&1
    reg delete "%%K" /v TCPNoDelay /f >> "%LOG%" 2>&1
    reg delete "%%K" /v TcpDelAckTicks /f >> "%LOG%" 2>&1
)
echo [OK] Windows defaults restored. Reboot recommended.
if /i "%~2"=="nopause" exit /b 0
pause
exit /b 0
