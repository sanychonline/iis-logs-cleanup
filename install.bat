@echo off
setlocal

:: Path to the encrypted credentials file
set "CRED_FILE=credentials.b64"

:: Read and decode the credentials
for /f "delims=" %%A in ('powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content '%CRED_FILE%' -Raw).Trim()))"') do set "DECODED_CREDENTIALS=%%A"

:: Extract username and password (format: username:password)
for /f "tokens=1,2 delims=:" %%B in ("%DECODED_CREDENTIALS%") do (
    set "SERVICE_ACCOUNT=%%B"
    set "PASSWORD=%%C"
)

:: Download powershell scrypt from GitHub repo
:: curl --create-dirs -O --output-dir "C:\Users\Default\AppData\Local\Microsoft\Windows\PowerShell" https://raw.githubusercontent.com/sanychonline/iis-logs-cleanup/refs/heads/main/archive-logs.ps1

:: Task details
set "TASK_NAME=IIS-Logs-Rotate"
set "SCRIPT_PATH=C:\Users\Default\AppData\Local\Microsoft\Windows\PowerShell\archive-logs.ps1"
set "START_TIME=00:00"

:: Create the scheduled task
schtasks /create /tn %TASK_NAME% /tr "powershell.exe %SCRIPT_PATH% " /sc MONTHLY /mo 1 /d 1 /st %START_TIME% /rl highest /ru %SERVICE_ACCOUNT%  /rp %PASSWORD%

if %ERRORLEVEL% equ 0 (
    echo Scheduled task "%TASK_NAME%" created successfully.
) else (
    echo Failed to create scheduled task.
)

endlocal
