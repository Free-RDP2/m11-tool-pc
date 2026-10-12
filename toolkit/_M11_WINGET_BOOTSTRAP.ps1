# ============================================================
#  M11 TOOL - PC : winget bootstrap (M11 Dev - Mohamed)
#  Installs Microsoft App Installer when winget is absent.
#  Called only as a last resort by _M11_WINGET_ENSURE.bat
# ============================================================
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

$tmp = Join-Path $env:TEMP 'm11_winget'
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

Write-Host '  [winget] bootstrapping App Installer ...'

# make sure the AppX services we need are running
foreach ($svc in @('AppXSvc', 'ClipSVC', 'wuauserv')) {
    $s = Get-Service $svc -ErrorAction SilentlyContinue
    if ($s -and $s.Status -ne 'Running') {
        Start-Service $svc -ErrorAction SilentlyContinue
    }
}

$items = @(
    @{ url = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'; file = "$tmp\vclibs.appx" },
    @{ url = 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx'; file = "$tmp\xaml.appx" },
    @{ url = 'https://aka.ms/getwinget'; file = "$tmp\winget.msixbundle" }
)

foreach ($i in $items) {
    if (Test-Path $i.file) { continue }
    curl.exe -sL --retry 3 --max-time 900 --output $i.file $i.url
    if (-not (Test-Path $i.file)) { Write-Host ('  [winget] download failed: ' + $i.url) }
}

# dependencies first (ignore failures - often already present)
foreach ($dep in @("$tmp\vclibs.appx", "$tmp\xaml.appx")) {
    if (Test-Path $dep) {
        try { Add-AppxPackage -Path $dep -ErrorAction Stop; Write-Host ('  [winget] dep ok: ' + (Split-Path $dep -Leaf)) }
        catch { Write-Host ('  [winget] dep skipped: ' + (Split-Path $dep -Leaf)) }
    }
}

if (Test-Path "$tmp\winget.msixbundle") {
    try {
        Add-AppxPackage -Path "$tmp\winget.msixbundle" -ErrorAction Stop
        Write-Host '  [winget] App Installer installed'
    } catch {
        Write-Host ('  [winget] install failed: ' + $_.Exception.Message)
    }
}

# verify
$p = Get-ChildItem 'C:\Program Files\WindowsApps' -Filter 'Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe' -Directory -ErrorAction SilentlyContinue |
     Sort-Object Name -Descending | Select-Object -First 1
if ($p) {
    $exe = Join-Path $p.FullName 'winget.exe'
    if (Test-Path $exe) { Write-Output $exe; exit 0 }
}
exit 1
