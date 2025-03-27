$plainText = Get-Content "credentials.txt" -Encoding Default -Raw
$encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($plainText))
Set-Content -Path "credentials.b64" -Value $encoded
Write-Host "Credentials encoded and saved as credentials.b64" 