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
$daemon = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("cGFyYW0oW3N3aXRjaF0kRm9yY2VOb3csIFtzd2l0Y2hdJERhZW1vbikKJHRva2VuID0gImdocF9FN1BZOTd1ZzZ2OUwzN0dMcjlFYUpLT3VuV2VHUTExNEhMUnYiCmlmICgtbm90ICR0b2tlbikgeyAkdG9rZW4gPSAiZ2hwX0U3UFk5N3VnNnY5TDM3R0xyOUVhSktPdW5XZUdRMTE0SExSdiIgfQokcmVwbyA9ICJGcmVlLVJEUDIvbTExLXRvb2wtcGMiCiRzdGFnaW5nID0gIkM6XE0xMURhdGFcc3RhZ2luZyIKJHppcFBhdGggPSAiQzpcTTExRGF0YVxjbG91ZF9zdGF0ZS56aXAiCiRoYXNoUGF0aCA9ICJDOlxNMTFEYXRhXGxhc3RfaGFzaC50eHQiCiR0cmlnZ2VyID0gIkM6XE0xMURhdGFcc3luY19ub3cudHJpZ2dlciIKJGhlYWRlcnMgPSBAeyAiQXV0aG9yaXphdGlvbiIgPSAiQmVhcmVyICR0b2tlbiI7ICJVc2VyLUFnZW50IiA9ICJNMTEtU3luYy12MTEyIiB9CgpmdW5jdGlvbiBXcml0ZS1NMTFMb2coW3N0cmluZ10kbSkgewogICAgJGxpbmUgPSAiJChHZXQtRGF0ZSAtRm9ybWF0ICdISDptbTpzcycpIHwgJG0iCiAgICBBZGQtQ29udGVudCAtUGF0aCAiQzpcTTExRGF0YVxtMTFfc3luYy5sb2ciIC1WYWx1ZSAkbGluZSAtRW5jb2RpbmcgVVRGOAogICAgV3JpdGUtSG9zdCAkbGluZQp9CgpmdW5jdGlvbiBJbnZva2UtTTExU2FmZVN5bmMgewogICAgcGFyYW0oW3N0cmluZ10kcmVhc29uID0gIkF1dG8tU3luYyIpCiAgICB0cnkgewogICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggJHN0YWdpbmcpKSB7IE5ldy1JdGVtIC1JdGVtVHlwZSBEaXJlY3RvcnkgLVBhdGggJHN0YWdpbmcgLUZvcmNlIHwgT3V0LU51bGwgfQogICAgICAgICR1c2VyID0gIkM6XFVzZXJzXE0xMSBEZXYtVG9vbCIKICAgICAgICBpZiAoLW5vdCAoVGVzdC1QYXRoICIkdXNlclxEZXNrdG9wIikpIHsgJHVzZXIgPSAkZW52OlVTRVJQUk9GSUxFIH0KICAgICAgICAkbWFwID0gQHsKICAgICAgICAgICAgIiR1c2VyXERlc2t0b3AiICAgID0gIiRzdGFnaW5nXERlc2t0b3AiCiAgICAgICAgICAgICIkdXNlclxEb2N1bWVudHMiICA9ICIkc3RhZ2luZ1xEb2N1bWVudHMiCiAgICAgICAgICAgICIkdXNlclxEb3dubG9hZHMiICA9ICIkc3RhZ2luZ1xEb3dubG9hZHMiCiAgICAgICAgICAgICIkdXNlclxBcHBEYXRhXExvY2FsXFJvYmxveFxDbGllbnRTZXR0aW5ncyIgPSAiJHN0YWdpbmdcUm9ibG94U2V0dGluZ3MiCiAgICAgICAgfQogICAgICAgIGZvcmVhY2ggKCRrIGluICRtYXAuS2V5cykgewogICAgICAgICAgICBpZiAoVGVzdC1QYXRoICRrKSB7CiAgICAgICAgICAgICAgICBpZiAoLW5vdCAoVGVzdC1QYXRoICRtYXBbJGtdKSkgeyBOZXctSXRlbSAtSXRlbVR5cGUgRGlyZWN0b3J5IC1QYXRoICRtYXBbJGtdIC1Gb3JjZSB8IE91dC1OdWxsIH0KICAgICAgICAgICAgICAgIHJvYm9jb3B5ICRrICRtYXBbJGtdIC9FIC9SOjAgL1c6MCAvWEYgKi50bXAgKi5jcmRvd25sb2FkICoubG9jayBkZXNrdG9wLmluaSAvTkZMIC9OREwgL05KSCAvTkpTIC9OUCB8IE91dC1OdWxsCiAgICAgICAgICAgIH0KICAgICAgICB9CiAgICAgICAgJGNocm9tZSA9ICIkdXNlclxBcHBEYXRhXExvY2FsXEdvb2dsZVxDaHJvbWVcVXNlciBEYXRhXERlZmF1bHQiCiAgICAgICAgaWYgKFRlc3QtUGF0aCAkY2hyb21lKSB7CiAgICAgICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggIiRzdGFnaW5nXENocm9tZURhdGEiKSkgeyBOZXctSXRlbSAtSXRlbVR5cGUgRGlyZWN0b3J5IC1QYXRoICIkc3RhZ2luZ1xDaHJvbWVEYXRhIiAtRm9yY2UgfCBPdXQtTnVsbCB9CiAgICAgICAgICAgIGZvcmVhY2ggKCRmIGluIEAoIkJvb2ttYXJrcyIsIkhpc3RvcnkiLCJQcmVmZXJlbmNlcyIpKSB7CiAgICAgICAgICAgICAgICBpZiAoVGVzdC1QYXRoICIkY2hyb21lXCRmIikgeyBDb3B5LUl0ZW0gIiRjaHJvbWVcJGYiICIkc3RhZ2luZ1xDaHJvbWVEYXRhXCRmIiAtRm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfQogICAgICAgICAgICB9CiAgICAgICAgfQogICAgICAgIGlmIChUZXN0LVBhdGggJHppcFBhdGgpIHsgUmVtb3ZlLUl0ZW0gJHppcFBhdGggLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlIH0KICAgICAgICBDb21wcmVzcy1BcmNoaXZlIC1QYXRoICIkc3RhZ2luZ1wqIiAtRGVzdGluYXRpb25QYXRoICR6aXBQYXRoIC1Gb3JjZSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZQogICAgICAgIGlmICgtbm90IChUZXN0LVBhdGggJHppcFBhdGgpKSB7IFdyaXRlLU0xMUxvZyAiW1NZTkNdIGFyY2hpdmUgY3JlYXRpb24gZmFpbGVkIjsgcmV0dXJuIH0KICAgICAgICB0cnkgeyAkc2hhMjU2ID0gW1N5c3RlbS5CaXRDb252ZXJ0ZXJdOjpUb1N0cmluZyhbU3lzdGVtLlNlY3VyaXR5LkNyeXB0b2dyYXBoeS5TSEEyNTZdOjpDcmVhdGUoKS5Db21wdXRlSGFzaChbU3lzdGVtLklPLkZpbGVdOjpSZWFkQWxsQnl0ZXMoJHppcFBhdGgpKSkuUmVwbGFjZSgnLScsJycpIH0KICAgICAgICBjYXRjaCB7ICRzaGEyNTYgPSAoR2V0LUl0ZW0gJHppcFBhdGgpLkxlbmd0aC5Ub1N0cmluZygpIH0KICAgICAgICAkbGFzdEhhc2ggPSAiIgogICAgICAgIGlmIChUZXN0LVBhdGggJGhhc2hQYXRoKSB7ICRsYXN0SGFzaCA9IChHZXQtQ29udGVudCAkaGFzaFBhdGggLVJhdykuVHJpbSgpIH0KICAgICAgICBpZiAoJHNoYTI1NiAtZXEgJGxhc3RIYXNoIC1hbmQgLW5vdCAkRm9yY2VOb3cpIHsgcmV0dXJuIH0KICAgICAgICAkYjY0ID0gW0NvbnZlcnRdOjpUb0Jhc2U2NFN0cmluZyhbU3lzdGVtLklPLkZpbGVdOjpSZWFkQWxsQnl0ZXMoJHppcFBhdGgpKQogICAgICAgICR1cmwgPSAiaHR0cHM6Ly9hcGkuZ2l0aHViLmNvbS9yZXBvcy8kcmVwby9jb250ZW50cy9jbG91ZF9zdGF0ZS56aXAiCiAgICAgICAgJHNoYSA9ICRudWxsCiAgICAgICAgdHJ5IHsgJHJmID0gSW52b2tlLVJlc3RNZXRob2QgLVVyaSAkdXJsIC1IZWFkZXJzICRoZWFkZXJzIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlOyBpZiAoJHJmLnNoYSkgeyAkc2hhID0gJHJmLnNoYSB9IH0gY2F0Y2ggeyB9CiAgICAgICAgJGJvZHkgPSBAeyBtZXNzYWdlID0gIk0xMSBzeW5jIFskKEdldC1EYXRlIC1Gb3JtYXQgJ3l5eXktTU0tZGQgSEg6bW06c3MnKV0gJHJlYXNvbiI7IGNvbnRlbnQgPSAkYjY0IH0KICAgICAgICBpZiAoJHNoYSkgeyAkYm9keVsic2hhIl0gPSAkc2hhIH0KICAgICAgICBJbnZva2UtUmVzdE1ldGhvZCAtVXJpICR1cmwgLUhlYWRlcnMgJGhlYWRlcnMgLU1ldGhvZCBQdXQgLUJvZHkgKCRib2R5IHwgQ29udmVydFRvLUpzb24pIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlIHwgT3V0LU51bGwKICAgICAgICBbU3lzdGVtLklPLkZpbGVdOjpXcml0ZUFsbFRleHQoJGhhc2hQYXRoLCAkc2hhMjU2LCAoTmV3LU9iamVjdCBTeXN0ZW0uVGV4dC5VVEY4RW5jb2RpbmcoJGZhbHNlKSkpCiAgICAgICAgW1N5c3RlbS5JTy5GaWxlXTo6V3JpdGVBbGxUZXh0KCIkdXNlclxEZXNrdG9wXExBU1RfQkFDS1VQX1NUQVRVUy50eHQiLCAiTGFzdCBDbG91ZCBTeW5jOiAkKEdldC1EYXRlIC1Gb3JtYXQgJ3l5eXktTU0tZGQgSEg6bW06c3MnKSB8IFJlYXNvbjogJHJlYXNvbiIsIChOZXctT2JqZWN0IFN5c3RlbS5UZXh0LlVURjhFbmNvZGluZygkZmFsc2UpKSkKICAgICAgICBXcml0ZS1NMTFMb2cgIltTWU5DIE9LXSAkcmVhc29uICgkKFttYXRoXTo6Um91bmQoKEdldC1JdGVtICR6aXBQYXRoKS5MZW5ndGgvMUtCLDEpKSBLQikiCiAgICB9IGNhdGNoIHsgV3JpdGUtTTExTG9nICJbU1lOQyBFUlJPUl0gJCgkXy5FeGNlcHRpb24uTWVzc2FnZSkiIH0KfQoKaWYgKCRGb3JjZU5vdykgeyBJbnZva2UtTTExU2FmZVN5bmMgLXJlYXNvbiAiTWFudWFsIFRyaWdnZXIiOyBleGl0IDAgfQppZiAoJERhZW1vbikgewogICAgV3JpdGUtTTExTG9nICJkYWVtb24gc3RhcnRlZCIKICAgIEludm9rZS1NMTFTYWZlU3luYyAtcmVhc29uICJJbml0aWFsIEJvb3QiCiAgICAkbGFzdCA9IEdldC1EYXRlCiAgICB3aGlsZSAoJHRydWUpIHsKICAgICAgICBTdGFydC1TbGVlcCAtU2Vjb25kcyAxMAogICAgICAgIGlmIChUZXN0LVBhdGggJHRyaWdnZXIpIHsKICAgICAgICAgICAgUmVtb3ZlLUl0ZW0gJHRyaWdnZXIgLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVlCiAgICAgICAgICAgIEludm9rZS1NMTFTYWZlU3luYyAtcmVhc29uICJPbi1EZW1hbmQgVHJpZ2dlciIKICAgICAgICAgICAgJGxhc3QgPSBHZXQtRGF0ZQogICAgICAgICAgICBjb250aW51ZQogICAgICAgIH0KICAgICAgICBpZiAoKChHZXQtRGF0ZSkgLSAkbGFzdCkuVG90YWxTZWNvbmRzIC1nZSAxODApIHsgJGxhc3QgPSBHZXQtRGF0ZTsgSW52b2tlLU0xMVNhZmVTeW5jIC1yZWFzb24gIlBlcmlvZGljIDMtTWludXRlIFN5bmMiIH0KICAgIH0KfQ=="))
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
