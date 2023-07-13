<#
.SYNOPSIS
	Copy template settings Brave (Chromium) profiles to all other profiles.
.DESCRIPTION
	With this script, the following actions will be done:
    - Stop the browser process
    - Profile folders will be cleaned
    - Profile folders will be filled with the template profile files
.PARAMETER message
    $UserData = The location of the browser user data
    $TemplateFolderName = The folder name of your default profile (Template profile)
    $ProfilePrefix = The prefixname of all profiles
    $ExcludeFolderFile = A filename which is be used to exclude that folder profile for this actions
    $ProcessName = The process name of the Brave (chromium) application
.EXAMPLE
	PS> ./CopyBraveChromiumProfiles.ps1
.LINK
	https://github.com/MrRamsus/Windows11_Public/blob/main/CopyBraveChromiumProfiles.ps1
.NOTES
	Author: MrRamsus
#>

#Vars
$UserData = "C:\Users\USERNAME\AppData\Local\BraveSoftware\Brave-Browser\User Data" #Change the username
$TemplateFolderName = "Default" #This is the template profile folder name
$ProfilePrefix = "Profile"
$ExcludeFolderFile = "NoCopySync.txt" #When this file is located in the root of the profile folder, this profile will not replaced with the default profile. This one will skipped
$ProcessName = "Brave"

#Don't change below this line
$ProfileList = (Get-ChildItem -Path $UserData -Directory | Where-Object {$_.Name -like "$ProfilePrefix *" -and $_.Name -ne $TemplateFolderName}).Name
$ProcessCheck = get-process $ProcessName -ErrorAction SilentlyContinue

#Start script
#Stop the browser process. This is needed to remove/copy the profile data
IF($ProcessCheck){
    Try{
        Stop-Process -Name $ProcessName -Force -ErrorAction Stop
    }
    Catch{
        Write-Host "Process $ProcessName couldn't be stopped" -ForegroundColor White -BackgroundColor Red
    }
}

#Remove and copy each profile data
Foreach($Profile in $ProfileList){
    $CheckFile = "$UserData\$Profile\$ExcludeFolderFile"
    #Will only applied when the $ExcludeFolderFile doesn't exist in the profile folder
    If((Test-Path $Checkfile) -eq $False){
        Try{
            Remove-Item "$UserData\$Profile\*" -Recurse -ErrorAction Stop
            Copy-Item -Path "$Userdata\$TemplateFolderName\*" -Destination "$UserData\$Profile" -recurse -ErrorAction Stop
        }
        Catch{
            Write-Host "There are some errors with the removal and/or copy of the content for $Profile. Please check manually" -ForegroundColor White -BackgroundColor Red
        }
    }
}
