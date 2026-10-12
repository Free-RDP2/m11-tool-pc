@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title M11 UNIVERSAL STORE - Games & Apps Hub (v1.12)
color 0b
cd /d "%~dp0"

:menu
cls
echo ==============================================================================
echo        M11 UNIVERSAL STORE - Games ^& Apps Hub ^(v1.12 fixed^)
echo        Developer: Mohamed El-Sayed Abdelfattah - M11 Dev
echo ==============================================================================
echo  ملاحظة: كل ما يلي يُثبَّت من المصادر الرسمية المجانية (winget).
echo  ملاحظة مهمة: الألعاب المدفوعة (GTA V / أي لعبة مدفوعة) يجب شراؤها
echo  من المتجر الرسمي. هذا المركز يثبّت الـ Launchers والمتاجر فقط.
echo ==============================================================================
echo   [1]  المتاجر الرسمية للألعاب (Steam / Epic / Rockstar / EA)
echo   [2]  المتصفحات (Chrome / Brave / Firefox)
echo   [3]  أدوات المطورين (VS Code / Git / Python / NodeJS)
echo   [4]  أدوات الاتصال (Discord / Zoom / TeamViewer)
echo   [5]  أدوات ضغط وملفات (7-Zip / WinRAR / Everything)
echo   [6]  أدوات الألعاب المجانية (RetroArch / Steam بلا متجر)
echo   [7]  تحديث كل البرامج المثبتة
echo   [0]  رجوع
echo ==============================================================================
set "opt="
set /p opt="اختر رقم [0-7]: "
if not defined opt goto menu

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
winget install --id Valve.Steam -e --silent --accept-package-agreements --accept-source-agreements
echo [2/4] Epic Games Launcher...
winget install --id EpicGames.EpicGamesLauncher -e --silent --accept-package-agreements --accept-source-agreements
echo [3/4] EA App...
winget install --id ElectronicArts.EADesktop -e --silent --accept-package-agreements --accept-source-agreements
echo [4/4] Rockstar Games Launcher...
winget install --id RockstarGames.Launcher -e --silent --accept-package-agreements --accept-source-agreements
echo [DONE] Official game stores installed. Sign in to buy/download your games.
pause
goto menu

:browsers
cls
echo [1/3] Google Chrome...
winget install --id Google.Chrome -e --silent --accept-package-agreements --accept-source-agreements
echo [2/3] Brave...
winget install --id Brave.Brave -e --silent --accept-package-agreements --accept-source-agreements
echo [3/3] Firefox...
winget install --id Mozilla.Firefox -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:dev
cls
echo [1/4] Visual Studio Code...
winget install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements --accept-source-agreements
echo [2/4] Git...
winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
echo [3/4] Python 3.12...
winget install --id Python.Python.3.12 -e --silent --accept-package-agreements --accept-source-agreements
echo [4/4] NodeJS LTS...
winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:comm
cls
echo [1/3] Discord...
winget install --id Discord.Discord -e --silent --accept-package-agreements --accept-source-agreements
echo [2/3] Zoom...
winget install --id Zoom.Zoom -e --silent --accept-package-agreements --accept-source-agreements
echo [3/3] TeamViewer...
winget install --id TeamViewer.TeamViewer -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:utils
cls
echo [1/3] 7-Zip...
winget install --id 7zip.7zip -e --silent --accept-package-agreements --accept-source-agreements
echo [2/3] RAR...
winget install --id RARLab.WinRAR -e --silent --accept-package-agreements --accept-source-agreements
echo [3/3] Everything search...
winget install --id voidtools.Everything -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:freegames
cls
echo [1/2] RetroArch (free open-source multi-system emulator)...
winget install --id Libretro.RetroArch -e --silent --accept-package-agreements --accept-source-agreements
echo [2/2] itch.io app (free indie games)...
winget install --id ItchIo.Itch -e --silent --accept-package-agreements --accept-source-agreements
pause
goto menu

:upgrade
cls
echo Upgrading all installed packages...
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
pause
goto menu
