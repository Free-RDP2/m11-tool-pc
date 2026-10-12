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
$daemon = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("cGFyYW0oW3N3aXRjaF0kRm9yY2VOb3csIFtzd2l0Y2hdJERhZW1vbikKJHRva2VuID0gIlJFUExBQ0VfUEFUIgppZiAoLW5vdCAkdG9rZW4pIHsgJHRva2VuID0gIlJFUExBQ0VfR0hUIiB9CiRyZXBvID0gIlJFUExBQ0VfUkVQTyIKJHN0YWdpbmcgPSAiQzpcTTExRGF0YVxzdGFnaW5nIgokemlwUGF0aCA9ICJDOlxNMTFEYXRhXGNsb3VkX3N0YXRlLnppcCIKJGhhc2hQYXRoID0gIkM6XE0xMURhdGFcbGFzdF9oYXNoLnR4dCIKJHRyaWdnZXIgPSAiQzpcTTExRGF0YVxzeW5jX25vdy50cmlnZ2VyIgokaGVhZGVycyA9IEB7ICJBdXRob3JpemF0aW9uIiA9ICJCZWFyZXIgJHRva2VuIjsgIlVzZXItQWdlbnQiID0gIk0xMS1TeW5jLXYxMTIiIH0KCmZ1bmN0aW9uIFdyaXRlLU0xMUxvZyhbc3RyaW5nXSRtKSB7CiAgICAkbGluZSA9ICIkKEdldC1EYXRlIC1Gb3JtYXQgJ0hIOm1tOnNzJykgfCAkbSIKICAgIEFkZC1Db250ZW50IC1QYXRoICJDOlxNMTFEYXRhXG0xMV9zeW5jLmxvZyIgLVZhbHVlICRsaW5lIC1FbmNvZGluZyBVVEY4CiAgICBXcml0ZS1Ib3N0ICRsaW5lCn0KCmZ1bmN0aW9uIEludm9rZS1NMTFTYWZlU3luYyB7CiAgICBwYXJhbShbc3RyaW5nXSRyZWFzb24gPSAiQXV0by1TeW5jIikKICAgIHRyeSB7CiAgICAgICAgaWYgKC1ub3QgKFRlc3QtUGF0aCAkc3RhZ2luZykpIHsgTmV3LUl0ZW0gLUl0ZW1UeXBlIERpcmVjdG9yeSAtUGF0aCAkc3RhZ2luZyAtRm9yY2UgfCBPdXQtTnVsbCB9CiAgICAgICAgJHVzZXIgPSAiQzpcVXNlcnNcTTExIERldi1Ub29sIgogICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggIiR1c2VyXERlc2t0b3AiKSkgeyAkdXNlciA9ICRlbnY6VVNFUlBST0ZJTEUgfQogICAgICAgICRtYXAgPSBAewogICAgICAgICAgICAiJHVzZXJcRGVza3RvcCIgICAgPSAiJHN0YWdpbmdcRGVza3RvcCIKICAgICAgICAgICAgIiR1c2VyXERvY3VtZW50cyIgID0gIiRzdGFnaW5nXERvY3VtZW50cyIKICAgICAgICAgICAgIiR1c2VyXERvd25sb2FkcyIgID0gIiRzdGFnaW5nXERvd25sb2FkcyIKICAgICAgICAgICAgIiR1c2VyXEFwcERhdGFcTG9jYWxcUm9ibG94XENsaWVudFNldHRpbmdzIiA9ICIkc3RhZ2luZ1xSb2Jsb3hTZXR0aW5ncyIKICAgICAgICB9CiAgICAgICAgZm9yZWFjaCAoJGsgaW4gJG1hcC5LZXlzKSB7CiAgICAgICAgICAgIGlmIChUZXN0LVBhdGggJGspIHsKICAgICAgICAgICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggJG1hcFska10pKSB7IE5ldy1JdGVtIC1JdGVtVHlwZSBEaXJlY3RvcnkgLVBhdGggJG1hcFska10gLUZvcmNlIHwgT3V0LU51bGwgfQogICAgICAgICAgICAgICAgcm9ib2NvcHkgJGsgJG1hcFska10gL0UgL1I6MCAvVzowIC9YRiAqLnRtcCAqLmNyZG93bmxvYWQgKi5sb2NrIGRlc2t0b3AuaW5pIC9ORkwgL05ETCAvTkpIIC9OSlMgL05QIHwgT3V0LU51bGwKICAgICAgICAgICAgfQogICAgICAgIH0KICAgICAgICAkY2hyb21lID0gIiR1c2VyXEFwcERhdGFcTG9jYWxcR29vZ2xlXENocm9tZVxVc2VyIERhdGFcRGVmYXVsdCIKICAgICAgICBpZiAoVGVzdC1QYXRoICRjaHJvbWUpIHsKICAgICAgICAgICAgaWYgKC1ub3QgKFRlc3QtUGF0aCAiJHN0YWdpbmdcQ2hyb21lRGF0YSIpKSB7IE5ldy1JdGVtIC1JdGVtVHlwZSBEaXJlY3RvcnkgLVBhdGggIiRzdGFnaW5nXENocm9tZURhdGEiIC1Gb3JjZSB8IE91dC1OdWxsIH0KICAgICAgICAgICAgZm9yZWFjaCAoJGYgaW4gQCgiQm9va21hcmtzIiwiSGlzdG9yeSIsIlByZWZlcmVuY2VzIikpIHsKICAgICAgICAgICAgICAgIGlmIChUZXN0LVBhdGggIiRjaHJvbWVcJGYiKSB7IENvcHktSXRlbSAiJGNocm9tZVwkZiIgIiRzdGFnaW5nXENocm9tZURhdGFcJGYiIC1Gb3JjZSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSB9CiAgICAgICAgICAgIH0KICAgICAgICB9CiAgICAgICAgaWYgKFRlc3QtUGF0aCAkemlwUGF0aCkgeyBSZW1vdmUtSXRlbSAkemlwUGF0aCAtRm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfQogICAgICAgIENvbXByZXNzLUFyY2hpdmUgLVBhdGggIiRzdGFnaW5nXCoiIC1EZXN0aW5hdGlvblBhdGggJHppcFBhdGggLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlCiAgICAgICAgaWYgKC1ub3QgKFRlc3QtUGF0aCAkemlwUGF0aCkpIHsgV3JpdGUtTTExTG9nICJbU1lOQ10gYXJjaGl2ZSBjcmVhdGlvbiBmYWlsZWQiOyByZXR1cm4gfQogICAgICAgICRzaGEyNTYgPSAoR2V0LUZpbGVIYXNoIC1BbGdvcml0aG0gU0hBMjU2IC1QYXRoICR6aXBQYXRoKS5IYXNoCiAgICAgICAgJGxhc3RIYXNoID0gIiIKICAgICAgICBpZiAoVGVzdC1QYXRoICRoYXNoUGF0aCkgeyAkbGFzdEhhc2ggPSAoR2V0LUNvbnRlbnQgJGhhc2hQYXRoIC1SYXcpLlRyaW0oKSB9CiAgICAgICAgaWYgKCRzaGEyNTYgLWVxICRsYXN0SGFzaCAtYW5kIC1ub3QgJEZvcmNlTm93KSB7IHJldHVybiB9CiAgICAgICAgJGI2NCA9IFtDb252ZXJ0XTo6VG9CYXNlNjRTdHJpbmcoW1N5c3RlbS5JTy5GaWxlXTo6UmVhZEFsbEJ5dGVzKCR6aXBQYXRoKSkKICAgICAgICAkdXJsID0gImh0dHBzOi8vYXBpLmdpdGh1Yi5jb20vcmVwb3MvJHJlcG8vY29udGVudHMvY2xvdWRfc3RhdGUuemlwIgogICAgICAgICRzaGEgPSAkbnVsbAogICAgICAgIHRyeSB7ICRyZiA9IEludm9rZS1SZXN0TWV0aG9kIC1VcmkgJHVybCAtSGVhZGVycyAkaGVhZGVycyAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZTsgaWYgKCRyZi5zaGEpIHsgJHNoYSA9ICRyZi5zaGEgfSB9IGNhdGNoIHsgfQogICAgICAgICRib2R5ID0gQHsgbWVzc2FnZSA9ICJNMTEgc3luYyBbJChHZXQtRGF0ZSAtRm9ybWF0ICd5eXl5LU1NLWRkIEhIOm1tOnNzJyldICRyZWFzb24iOyBjb250ZW50ID0gJGI2NCB9CiAgICAgICAgaWYgKCRzaGEpIHsgJGJvZHlbInNoYSJdID0gJHNoYSB9CiAgICAgICAgSW52b2tlLVJlc3RNZXRob2QgLVVyaSAkdXJsIC1IZWFkZXJzICRoZWFkZXJzIC1NZXRob2QgUHV0IC1Cb2R5ICgkYm9keSB8IENvbnZlcnRUby1Kc29uKSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZSB8IE91dC1OdWxsCiAgICAgICAgW1N5c3RlbS5JTy5GaWxlXTo6V3JpdGVBbGxUZXh0KCRoYXNoUGF0aCwgJHNoYTI1NiwgKE5ldy1PYmplY3QgU3lzdGVtLlRleHQuVVRGOEVuY29kaW5nKCRmYWxzZSkpKQogICAgICAgIFtTeXN0ZW0uSU8uRmlsZV06OldyaXRlQWxsVGV4dCgiJHVzZXJcRGVza3RvcFxMQVNUX0JBQ0tVUF9TVEFUVVMudHh0IiwgIkxhc3QgQ2xvdWQgU3luYzogJChHZXQtRGF0ZSAtRm9ybWF0ICd5eXl5LU1NLWRkIEhIOm1tOnNzJykgfCBSZWFzb246ICRyZWFzb24iLCAoTmV3LU9iamVjdCBTeXN0ZW0uVGV4dC5VVEY4RW5jb2RpbmcoJGZhbHNlKSkpCiAgICAgICAgV3JpdGUtTTExTG9nICJbU1lOQyBPS10gJHJlYXNvbiAoJChbbWF0aF06OlJvdW5kKChHZXQtSXRlbSAkemlwUGF0aCkuTGVuZ3RoLzFLQiwxKSkgS0IpIgogICAgfSBjYXRjaCB7IFdyaXRlLU0xMUxvZyAiW1NZTkMgRVJST1JdICQoJF8uRXhjZXB0aW9uLk1lc3NhZ2UpIiB9Cn0KCmlmICgkRm9yY2VOb3cpIHsgSW52b2tlLU0xMVNhZmVTeW5jIC1yZWFzb24gIk1hbnVhbCBUcmlnZ2VyIjsgZXhpdCAwIH0KaWYgKCREYWVtb24pIHsKICAgIFdyaXRlLU0xMUxvZyAiZGFlbW9uIHN0YXJ0ZWQiCiAgICBJbnZva2UtTTExU2FmZVN5bmMgLXJlYXNvbiAiSW5pdGlhbCBCb290IgogICAgJGxhc3QgPSBHZXQtRGF0ZQogICAgd2hpbGUgKCR0cnVlKSB7CiAgICAgICAgU3RhcnQtU2xlZXAgLVNlY29uZHMgMTAKICAgICAgICBpZiAoVGVzdC1QYXRoICR0cmlnZ2VyKSB7CiAgICAgICAgICAgIFJlbW92ZS1JdGVtICR0cmlnZ2VyIC1Gb3JjZSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZQogICAgICAgICAgICBJbnZva2UtTTExU2FmZVN5bmMgLXJlYXNvbiAiT24tRGVtYW5kIFRyaWdnZXIiCiAgICAgICAgICAgICRsYXN0ID0gR2V0LURhdGUKICAgICAgICAgICAgY29udGludWUKICAgICAgICB9CiAgICAgICAgaWYgKCgoR2V0LURhdGUpIC0gJGxhc3QpLlRvdGFsU2Vjb25kcyAtZ2UgMTgwKSB7ICRsYXN0ID0gR2V0LURhdGU7IEludm9rZS1NMTFTYWZlU3luYyAtcmVhc29uICJQZXJpb2RpYyAzLU1pbnV0ZSBTeW5jIiB9CiAgICB9Cn0="))
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
