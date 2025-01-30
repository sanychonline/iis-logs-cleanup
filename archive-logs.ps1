param (
    [string]$SourceFolder = $Env:SystemDrive+"\inetpub\logs\LogFiles",
    [string]$DestinationFolder = "D:\IIS_Archived_Logs",
    [string]$RuntimeLog = $env:SystemRoot+"\Logs\IISLogRotate.log",
    [switch]$CreateLink = $true,
    [int]$Age = -30
)
Start-Transcript -Append $RuntimeLog

if (Test-Path $SourceFolder){
    $Files = Get-ChildItem -Path $SourceFolder -Recurse -File | where {$_.LastWriteTime -lt (Get-Date).AddDays($Age)}
    foreach ($File in $Files)
    {
        $NewPath = $File.DirectoryName.Replace($SourceFolder,"")
        if (!(Test-Path -LiteralPath "$DestinationFolder\$NewPath"))
        {
            New-Item -Path "$DestinationFolder\$NewPath" -ItemType Directory
        }
        $File | Compress-Archive -Update -DestinationPath $DestinationFolder\$NewPath\Logs-$_$(get-date -f yyyy-MM-dd).zip | Remove-Item $File -Force
        Write-Host $(Get-Date -format MM/dd/yy` hh:mm:ss) $File "Compressed to" $DestinationFolder\$NewPath\Logs-$_$(get-date -f yyyy-MM-dd).zip
    }
    foreach ($File in $Files)
    {
        $NewPath = $File.DirectoryName.Replace($SourceFolder,"")
        Remove-Item $SourceFolder\$NewPath\$File -Force
        Write-Host $(get-date -f yyyy-MM-dd) "File" $SourceFolder\$NewPath\$File "was successfully removed"
    }
    if ($CreateLink) {
        $folderName = Split-Path -Path $DestinationFolder -Leaf
        $Args = "mklink /D "+$SourceFolder+"\"+$folderName+".lnk "+$DestinationFolder
        if (!(Test-Path $SourceFolder\$folderName.lnk)) 
        {
            Start-Process cmd -ArgumentList "/c $Args"
            Write-Host $(Get-Date -format MM/dd/yy` hh:mm:ss) "Creating symlink for" $DestinationFolder in $SourceFolder
        }
        
    }
    
} else
{
    Write-Host $SourceFolder does not exists. Nothing to cleanup.
}
Stop-Transcript 
