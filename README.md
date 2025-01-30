# iis-logs-cleanup
IIS-CleanUp tool to make a cleanup in IIS logs directory and move old zipped logs to archive folder.
In fact this tool may be used to any outdated files based on your retention policy.

All variables are set to default IIS location, but you may override them:

SourceFolder = $Env:SystemDrive+"\inetpub\logs\LogFiles",
DestinationFolder = "D:\IIS_Archived_Logs",
RuntimeLog = $env:SystemRoot+"\Logs\IISLogRotate.log",
Age = -7

Example
.\logs.ps1 -SourceFolder C:\TEMP\SourceLogsLocation -DestinationFolder C:\ArchivedLogs -Age -7 -RuntimeLog C:\TEMP\Output.log 

