param([switch]$ForceNow, [switch]$Daemon)
$token = "REPLACE_PAT"
if (-not $token) { $token = "REPLACE_GHT" }
$repo = "REPLACE_REPO"
$staging = "C:\M11Data\staging"
$zipPath = "C:\M11Data\cloud_state.zip"
$hashPath = "C:\M11Data\last_hash.txt"
$trigger = "C:\M11Data\sync_now.trigger"
$headers = @{ "Authorization" = "Bearer $token"; "User-Agent" = "M11-Sync-v112" }

function Write-M11Log([string]$m) {
    $line = "$(Get-Date -Format 'HH:mm:ss') | $m"
    Add-Content -Path "C:\M11Data\m11_sync.log" -Value $line -Encoding UTF8
    Write-Host $line
}

function Invoke-M11SafeSync {
    param([string]$reason = "Auto-Sync")
    try {
        if (-not (Test-Path $staging)) { New-Item -ItemType Directory -Path $staging -Force | Out-Null }
        $user = "C:\Users\M11 Dev-Tool"
        if (-not (Test-Path "$user\Desktop")) { $user = $env:USERPROFILE }
        $map = @{
            "$user\Desktop"    = "$staging\Desktop"
            "$user\Documents"  = "$staging\Documents"
            "$user\Downloads"  = "$staging\Downloads"
            "$user\AppData\Local\Roblox\ClientSettings" = "$staging\RobloxSettings"
        }
        foreach ($k in $map.Keys) {
            if (Test-Path $k) {
                if (-not (Test-Path $map[$k])) { New-Item -ItemType Directory -Path $map[$k] -Force | Out-Null }
                robocopy $k $map[$k] /E /R:0 /W:0 /XF *.tmp *.crdownload *.lock desktop.ini /NFL /NDL /NJH /NJS /NP | Out-Null
            }
        }
        $chrome = "$user\AppData\Local\Google\Chrome\User Data\Default"
        if (Test-Path $chrome) {
            if (-not (Test-Path "$staging\ChromeData")) { New-Item -ItemType Directory -Path "$staging\ChromeData" -Force | Out-Null }
            foreach ($f in @("Bookmarks","History","Preferences")) {
                if (Test-Path "$chrome\$f") { Copy-Item "$chrome\$f" "$staging\ChromeData\$f" -Force -ErrorAction SilentlyContinue }
            }
        }
        if (Test-Path $zipPath) { Remove-Item $zipPath -Force -ErrorAction SilentlyContinue }
        Compress-Archive -Path "$staging\*" -DestinationPath $zipPath -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $zipPath)) { Write-M11Log "[SYNC] archive creation failed"; return }
        try { $sha256 = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.IO.File]::ReadAllBytes($zipPath))).Replace('-','') }
        catch { $sha256 = (Get-Item $zipPath).Length.ToString() }
        $lastHash = ""
        if (Test-Path $hashPath) { $lastHash = (Get-Content $hashPath -Raw).Trim() }
        if ($sha256 -eq $lastHash -and -not $ForceNow) { return }
        $b64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($zipPath))
        $url = "https://api.github.com/repos/$repo/contents/cloud_state.zip"
        $sha = $null
        try { $rf = Invoke-RestMethod -Uri $url -Headers $headers -ErrorAction SilentlyContinue; if ($rf.sha) { $sha = $rf.sha } } catch { }
        $body = @{ message = "M11 sync [$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $reason"; content = $b64 }
        if ($sha) { $body["sha"] = $sha }
        Invoke-RestMethod -Uri $url -Headers $headers -Method Put -Body ($body | ConvertTo-Json) -ErrorAction SilentlyContinue | Out-Null
        [System.IO.File]::WriteAllText($hashPath, $sha256, (New-Object System.Text.UTF8Encoding($false)))
        [System.IO.File]::WriteAllText("$user\Desktop\LAST_BACKUP_STATUS.txt", "Last Cloud Sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Reason: $reason", (New-Object System.Text.UTF8Encoding($false)))
        Write-M11Log "[SYNC OK] $reason ($([math]::Round((Get-Item $zipPath).Length/1KB,1)) KB)"
    } catch { Write-M11Log "[SYNC ERROR] $($_.Exception.Message)" }
}

if ($ForceNow) { Invoke-M11SafeSync -reason "Manual Trigger"; exit 0 }
if ($Daemon) {
    Write-M11Log "daemon started"
    Invoke-M11SafeSync -reason "Initial Boot"
    $last = Get-Date
    while ($true) {
        Start-Sleep -Seconds 10
        if (Test-Path $trigger) {
            Remove-Item $trigger -Force -ErrorAction SilentlyContinue
            Invoke-M11SafeSync -reason "On-Demand Trigger"
            $last = Get-Date
            continue
        }
        if (((Get-Date) - $last).TotalSeconds -ge 180) { $last = Get-Date; Invoke-M11SafeSync -reason "Periodic 3-Minute Sync" }
    }
}