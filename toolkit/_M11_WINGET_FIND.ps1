# ============================================================
#  M11 TOOL - PC : locate winget.exe (M11 Dev - Mohamed)
#  Prints the full path of a usable winget.exe, or nothing.
#  Works under SYSTEM where `where winget` fails.
# ============================================================
$ErrorActionPreference = 'SilentlyContinue'
$found = $null

# 1) normal PATH lookup
$c = Get-Command winget.exe -ErrorAction SilentlyContinue
if ($c) { $found = $c.Source }

# 2) App Installer alias for any real user profile
if (-not $found) {
    foreach ($u in @('M11 Dev-Tool', 'runneradmin', 'Admin', 'Administrator')) {
        $p = "C:\Users\$u\AppData\Local\Microsoft\WindowsApps\winget.exe"
        if (Test-Path $p) { $found = $p; break }
    }
}

# 3) DesktopAppInstaller package folder (all users)
if (-not $found) {
    $pkg = Get-AppxPackage -AllUsers -Name Microsoft.DesktopAppInstaller |
           Sort-Object -Property Version -Descending | Select-Object -First 1
    if ($pkg -and $pkg.InstallLocation) {
        $p = Join-Path $pkg.InstallLocation 'winget.exe'
        if (Test-Path $p) { $found = $p }
    }
}

# 4) brute-force scan of Program Files\WindowsApps
if (-not $found) {
    $g = Get-ChildItem 'C:\Program Files\WindowsApps' -Filter 'Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe' -Directory -ErrorAction SilentlyContinue |
         Sort-Object Name -Descending | Select-Object -First 1
    if ($g) {
        $p = Join-Path $g.FullName 'winget.exe'
        if (Test-Path $p) { $found = $p }
    }
}

if ($found) { Write-Output $found }
