curl --create-dirs -O --output-dir "C:\Users\Default\AppData\Local\Microsoft\Windows\PowerShell" https://raw.githubusercontent.com/sanychonline/iis-logs-cleanup/refs/heads/main/archive-logs.ps1
schtasks.exe /create /tn "IIS-Logs-Rotate" /sc Weekly /d MON /st 00:00 /rl highest /ru system /tr "powershell.exe C:\Users\Default\AppData\Local\Microsoft\Windows\PowerShell\archive-logs.ps1"
