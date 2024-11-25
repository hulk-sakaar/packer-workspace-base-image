Write-Host "starting sleep"
Start-Sleep -Seconds 45
Write-Host "stopping WSUS"
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
write-host "disableing WSUS"
Set-Service -Name wuauserv -StartupType Disabled
Write-Host "setting firewall"
Set-NetFirewallProfile -Enabled False
Write-Host "setting items for byol"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Value 1
Write-Host "removing auto logon"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" -Name "AutoAdminLogon"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" -Name "DefaultUsername"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" -Name "Defaultpassword"
Write-Host "moving byol unattend.xml to panther dir"
Copy-Item -Path "C:\Users\workspaces_byol\Documents\BYOLChecker\OOBE_unattend.xml" -Destination "C:\Windows\panther\unattend.xml" -recurse -force


