# ============================================================
#  M11 TOOL - PC : mojibake / integrity checker
#  Called by _M11_SELF_TEST.bat  (M11 Dev - Mohamed)
# ============================================================
$bad = 0
$dirs = @('C:\Users\M11 Dev-Tool\Desktop', 'C:\Users\runneradmin\Desktop', 'C:\Users\Public\Desktop') |
        Where-Object { Test-Path $_ }

foreach ($d in $dirs) {
    Get-ChildItem $d -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -match '^\?+') {
            $bad++
            Write-Host ('  BAD NAME: ' + $_.FullName)
        }
        elseif (-not $_.PSIsContainer -and $_.Length -lt 300000 -and $_.Extension -match '\.(bat|cmd|ps1|txt|json)$') {
            $t = [IO.File]::ReadAllText($_.FullName)
            if ($t -match '\?\?\?\?\?') {
                $bad++
                Write-Host ('  BAD CONTENT: ' + $_.FullName)
            }
        }
    }
}

if ($bad -eq 0) { Write-Host '  CLEAN: no mojibake found' }
else { Write-Host ('  FOUND ' + $bad + ' mojibake items') }
