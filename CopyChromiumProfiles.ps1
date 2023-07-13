<#
.SYNOPSIS
	Copy template settings Chromium (Brave / Edge) profiles to all other profiles.
.DESCRIPTION
	With this script, the following actions will be done:
    - Stop the browser process
    - Profile folders will be cleaned
    - Profile folders will be filled with the template profile files
.PARAMETER message
    $UserData = The location of the browser user data [Line 30]
      - For brave use: "C:\Users\USERNAME\AppData\Local\BraveSoftware\Brave-Browser\User Data"
      - For edge use: "C:\Users\UserName\AppData\Local\Microsoft\Edge\User Data"
      - For chrome use: "C:\Users\UserName\AppData\Local\Google\Chrome\User Data"
    $TemplateFolderName = The folder name of your default profile (Template profile) [Line31].
    $ProfilePrefix = The prefixname of all profiles [Line 32]
    $ExcludeFolderFile = A filename which is be used to exclude that folder profile for this actions [Line 33]
    $ProcessName = The process name of the Brave (chromium) application [Line 34]
      - For Brave use: "brave"
      - For Edge use: "msedge"
      - For chrome use: "chrome"
.EXAMPLE
	PS> ./CopyChromiumProfiles.ps1
.LINK
	https://github.com/MrRamsus/Windows11_Public/blob/main/CopyChromiumProfiles.ps1
.NOTES
	Author: MrRamsus
#>

#Vars
$UserData = "C:\Users\USERNAME\AppData\Local\BraveSoftware\Brave-Browser\User Data" #Change the username #See .PARAMETER message for known alternative value
$TemplateFolderName = "Default" #This is the template profile folder name
$ProfilePrefix = "Profile"
$ExcludeFolderFile = "NoCopySync.txt" #When this file is located in the root of the profile folder, this profile will not replaced with the default profile. This one will skipped
$ProcessName = "Brave" #See .PARAMETER message for known alternative value

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
