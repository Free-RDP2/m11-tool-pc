# ============================================================
#  M11 TOOL - PC : mojibake / integrity checker  (v1.14)
#  Called by _M11_SELF_TEST.bat  -  M11 Dev - Mohamed
#  v1.14: never throws on inaccessible folders (runneradmin etc.)
# ============================================================
$bad = 0
$dirs = New-Object System.Collections.Generic.List[string]
foreach ($p in @('C:\Users\M11 Dev-Tool\Desktop', 'C:\Users\runneradmin\Desktop', 'C:\Users\Public\Desktop')) {
    try { if (Test-Path -LiteralPath $p) { $dirs.Add($p) } } catch { }
}
# add every real user profile desktop (handles C:\Users\Name.runnervmfi6oq style profiles)
try {
    Get-ChildItem 'C:\Users' -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $d = Join-Path $_.FullName 'Desktop'
        try { if ((Test-Path -LiteralPath $d) -and ($dirs -notcontains $d)) { $dirs.Add($d) } } catch { }
    }
} catch { }

foreach ($d in $dirs) {
    $items = $null
    try { $items = Get-ChildItem -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue } catch { continue }
    if (-not $items) { continue }
    foreach ($f in $items) {
        try {
            if ($f.Name -match '^\?+') { $bad++; Write-Host ('  BAD NAME: ' + $f.FullName) }
            elseif (-not $f.PSIsContainer -and $f.Length -lt 300000 -and $f.Extension -match '\.(bat|cmd|ps1|txt|json)$') {
                $t = [IO.File]::ReadAllText($f.FullName)
                if ($t -match '\?\?\?\?\?') { $bad++; Write-Host ('  BAD CONTENT: ' + $f.FullName) }
            }
        } catch { }
    }
}
if ($bad -eq 0) { Write-Host '  CLEAN: no mojibake found' }
else { Write-Host ('  FOUND ' + $bad + ' mojibake items') }
