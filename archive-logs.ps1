 param (
    [string]$SourceFolder = "$Env:SystemDrive\inetpub\logs\LogFiles",
    [string]$DestinationFolder = "D:\IIS_Archived_Logs",
    [string]$RuntimeLog = "$env:SystemRoot\Logs\IISLogRotate.log",
    [switch]$CreateLink = $true,
    [int]$Age = -30
)

Start-Transcript -Append $RuntimeLog

# Check if D: is removable and fallback to E: if needed
try {
    $dVolume = Get-Volume -DriveLetter D -ErrorAction Stop
    if ($dVolume.DriveType -eq 'Removable') {
        $eVolume = Get-Volume -DriveLetter E -ErrorAction SilentlyContinue
        if ($eVolume -and $eVolume.DriveType -ne 'Removable') {
            Write-Host "Drive D: is removable. Using E: for archive instead."
            $DestinationFolder = "E:\IIS_Archived_Logs"
        } else {
            Write-Host "Both D: and E: are removable or E: not available. Keeping D: as destination."
        }
    }
} catch {
    Write-Host "Error checking volume info: $_"
}

if (Test-Path $SourceFolder) {
    $Files = Get-ChildItem -Path $SourceFolder -Recurse -File | Where-Object {
        $_.LastWriteTime -lt (Get-Date).AddDays($Age)
    }

    foreach ($File in $Files) {
        $NewPath = $File.DirectoryName.Replace($SourceFolder, "")
        $DestPath = Join-Path $DestinationFolder $NewPath

        if (!(Test-Path -LiteralPath $DestPath)) {
            New-Item -Path $DestPath -ItemType Directory -Force
        }

        $ZipFile = Join-Path $DestPath ("Logs-" + $File.Name + "-" + (Get-Date -Format "yyyy-MM-dd") + ".zip")
        Compress-Archive -Update -Path $File.FullName -DestinationPath $ZipFile
        Remove-Item $File.FullName -Force

        Write-Host "$(Get-Date -Format 'MM/dd/yy hh:mm:ss') $($File.FullName) compressed to $ZipFile"
    }

    if ($CreateLink) {
        $folderName = Split-Path -Path $DestinationFolder -Leaf
        $LinkPath = Join-Path $SourceFolder $folderName

        if (!(Test-Path $LinkPath)) {
            cmd /c "mklink /D `"$LinkPath`" `"$DestinationFolder`""
            Write-Host "$(Get-Date -Format 'MM/dd/yy hh:mm:ss') Created symlink $LinkPath -> $DestinationFolder"
        }
    }

} else {
    Write-Host "$SourceFolder does not exist. Nothing to clean up."
}

Stop-Transcript 
