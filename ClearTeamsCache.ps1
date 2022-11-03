<#
.SYNOPSIS
	Clean cache files of Teams.
.DESCRIPTION
	With this script, the following actions will be done:
    - Stop Teams
    - Cleanup several folders
    - Start teams
.PARAMETER message
    MainFolder = The root folder of Teams. Normaly no change needed!
    FolderList = All folders that should be cleared.
    StopAppName = The name of the process name you will stop
    StartProcessName = The name of the process name you will start (same as StopAppName)
    File = The file you will start (path with exe file)
    Args = The arguments you will use with the start of the process.
.EXAMPLE
	PS> ./ClearTeamsCache.ps1
.LINK
	https://github.com/MrRamsus/Windows11_Public/blob/main/ClearTeamsCache.ps1
.NOTES
	Author: MrRamsus
#>

#Vars
$MainFolder = "$env:AppData\Microsoft\Teams\"
$FolderList = @()
$FolderList += "blob_storage"
$FolderList += "Cache"
$FolderList += "Code Cache"
$FolderList += "databases"
$FolderList += "GPUCache"
$FolderList += "Local Storage"
$FolderList += "tmp"
$FolderList += "IndexedDB"


Function Stop-Application{
       Param(
        $StopProcessName
    )
    $ProcessList = Get-Process $StopProcessName -ErrorAction SilentlyContinue
    If($ProcessList){
        Foreach ($Process in $ProcessList){
            Stop-Process $Process -Force -ErrorAction Stop | Out-Null
            $ProcessList = Get-Process $StopProcessName -ErrorAction SilentlyContinue
            } 
    }
}

Function Cleanup-Folders{
    param(
        $Mainfolder,
        $FolderList)
    foreach ($Folder in $FolderList){
    $Path = $MainFolder+$Folder
        Get-Childitem -Path $Path\* -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }
}

Function Start-Application{
    Param(
        $StartProcessName
        $File,
        $Args
    )
    $ProcessList = Get-Process $StartProcessName -ErrorAction SilentlyContinue
    If(!($ProcessList)){
        try {
                Start-Process -FilePath $File -ArgumentList $args -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Host "$StartProcessName couldn't been started" -Backgroundcolor Red
            }
        }
}

##Script
Stop-Application -StopProcessName "Teams" 
Cleanup-Folders -MainFolder $MainFolder -FolderList $FolderList
Start-Application -StartProcessName "Teams" -File "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe" -Args '--processStart "Teams.exe"'
