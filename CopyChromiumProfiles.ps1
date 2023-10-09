<#
.SYNOPSIS
	Copy template settings Chromium (Brave / Edge) profiles to all other profiles.
.DESCRIPTION
	With this script, the following actions will be done:
		- Stop the browser process
		- Profile folders will be cleaned
		- Profile folders will be filled with the template profile files
.PARAMETER message
	$Browser = Choose the browser you use. [brave | chrome | msedge]
	$UserName = This is your windows username as shown in "c:\users"
	$TemplateFolderName = The folder name of your default profile (Template profile) [Line under #Vars]
	$ProfilePrefix = The prefixname of all profiles [Line under #Vars]
	$ExcludeFolderFile = A filename which is be used to exclude that folder profile for this actions [Line under #Vars]
	$UserData = The location of the browser user data. This value will automatically be filled after you choose your $Browser
		- For brave use: "C:\Users\$UserName\AppData\Local\BraveSoftware\Brave-Browser\User Data"
		- For chrome use: "C:\Users\$UserName\AppData\Local\Google\Chrome\User Data"
		- For edge use: "C:\Users\$UserName\AppData\Local\Microsoft\Edge\User Data"
	$ProcessName = The process name of the Brave (chromium) application. This value will automatically be filled after you choose your $Browser
		- For Brave use: "brave"
		- For chrome use: "chrome"
		- For Edge use: "msedge"
	$CopyFileList = The list with the files which will be copied. You can let this by default
.EXAMPLE
	How to use this script:
		1. When you start the browser for the first time, you need to create one profile as template. Change every setting you need to use for other profiles.
	 	2. You have to know which browser you use. Change the var "$Browser" to the correct browser.
	    	3. Change the value "$UserName" with your windows username shown in "c:\users"
	 	4. Notice your template profile folder name (For Brave and Chrome, the first profile will be named "Default". In Edge, the first profile will be named "Profile 1". Check it in the app data and check which profile has been changed.
	   	5. If needed, create a file to exclude that profile for this script. In that case, the template settings will not be copied to that profile.
	    	6. Run the script.
.EXAMPLE
	PS> ./CopyChromiumProfiles.ps1
.LINK
	https://github.com/MrRamsus/Windows11_Public/blob/main/CopyChromiumProfiles.ps1
.NOTES
	Author: MrRamsus
#>

#Vars needs to be filled
$Browser = "brave" #[ "brave" | "chrome" | "msedge" ]
$UserName = "CustomUserName" # Fill only this value if you run this script with another user
$TemplateFolderName = "Default" #This is the template profile folder name
$ProfilePrefix = "Profile"
$ExcludeFolderFile = "NoCopySync.txt" #When this file is located in the root of the profile folder, this profile will not replaced with the default profile. This one will skipped
$CopyFileList = @("Bookmarks","Favicons","Preferences","PreferredApps","Secure Preferences","Shortcuts") #Choose which files needs to be copied.

#Automation Vars.
# Don't change below this line!
if ($UserName -eq "CustomUserName"){
	$UserName = [System.Environment]::UserName
}
If($Browser -eq "brave"){
    $UserData = "C:\Users\$UserName\AppData\Local\BraveSoftware\Brave-Browser\User Data" #Change the username #See .PARAMETER message for known alternative value
    $ProcessName = "brave" #See .PARAMETER message for known alternative value [ "brave" | "chrome" | "msedge" ]
}
ElseIf($Browser -eq "chrome"){
    $UserData = "C:\Users\$UserName\AppData\Local\Google\Chrome\User Data" #Change the username #See .PARAMETER message for known alternative value
    $ProcessName = "chrome" #See .PARAMETER message for known alternative value [ "brave" | "chrome" | "msedge" ]
}
ElseIf($Browser -eq "msedge"){
    $UserData = "C:\Users\$UserName\AppData\Local\Microsoft\Edge\User Data" #Change the username #See .PARAMETER message for known alternative value
    $ProcessName = "msedge" #See .PARAMETER message for known alternative value [ "brave" | "chrome" | "msedge" ]
}
$ProfileList = (Get-ChildItem -Path $UserData -Directory | Where-Object {$_.Name -like "$ProfilePrefix *" -and $_.Name -ne $TemplateFolderName}).Name
$ProcessCheck = get-process $ProcessName -ErrorAction SilentlyContinue

#Start script
# Don't change below this line!
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
            foreach($File in $CopyFileList){
				Copy-Item -Path "$Userdata\$TemplateFolderName\$File" -Destination "$UserData\$Profile" -recurse -ErrorAction Stop
			}
        }
        Catch{
            Write-Host "There are some errors with the removal and/or copy of the content for $Profile. Please check manually" -ForegroundColor White -BackgroundColor Red
        }
    }
}
