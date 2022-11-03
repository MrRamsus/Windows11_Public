<#
.SYNOPSIS
	Tweak your Windows 10/11 device for "High memory usage". Note that this script is at own risk.
.DESCRIPTION
	With this script, the following actions will be done:
    - Change regkey Start from 2 to 4
    - Change regkey ClearPageFileAtShutdown from 0 to 1
    - Disable service sysmain
    - run dism Cleanup-image and sfc /scannow commands
    - Run Cleanmanager
    - Optimize your SSD drive (Re-Trim)
.PARAMETER message
    ServiceName = The service name for Sysmain.
    
.EXAMPLE
	PS> ./Fix-HighMemory_W10_W11.ps1
.LINK
	https://github.com/MrRamsus/Windows11_Public/blob/main/Fix-HighMemory_W10_W11.ps1.ps1
.NOTES
	Author: MrRamsus
#>
Function RunAsAdmin{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

Function RegeditNDUStart(){
    $NDUStart = Get-Itemproperty -Path "HKLM:SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -ErrorAction SilentlyContinue
    #Write-Host Default value: 2
    if($NDUStart){
        If($NDUStart.Start -ne "4"){
                try {
                    Set-ItemProperty "HKLM:SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Value "4" -ErrorAction Stop
                }
                catch {
                    Write-Host "Start can not be changed" -BackgroundColor Red -ForegroundColor White
                }
            }
        }else{
                try {
                    New-ItemProperty -Path "HKLM:SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Value "4" -ErrorAction Stop
                }
                catch {
                    Write-Host "Start can not be created" -BackgroundColor Red -ForegroundColor White
                }
            }
}

Function RegeditClearPageFileAtShutdown(){
    $ClearPageFileAtShutdown = Get-Itemproperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -ErrorAction SilentlyContinue
    #Write-Host Default value: 0
    if($ClearPageFileAtShutdown){
        If($ClearPageFileAtShutdown.ClearPageFileAtShutdown -ne 1){
            try {
                Set-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value "1" -ErrorAction Stop
            }
            catch {
                Write-Host "ClearPageFileAtShutdown can not be changed" -BackgroundColor Red -ForegroundColor White
            }
        }
    }else{
        try {
            New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value "1" -ErrorAction Stop
        }
        catch {
            Write-Host "ClearPageFileAtShutdown can not be created" -BackgroundColor Red -ForegroundColor White
        }
    }
}

Function DisableService{
    Param(
        $ServiceName
        )
    try {
        Get-Service $ServiceName | Set-Service -Status stopped -StartupType disabled -ErrorAction Stop
    }
    catch {
        Write-Host "$ServiceName cannot be disabled!" -BackgroundColor Red -ForegroundColor White
    } 
}

function RunCMDCommands {
    $CommandList = @()
    $CommandList += "Dism /Online /Cleanup-Image /CheckHealth"
    $CommandList += "Dism /Online /Cleanup-Image /ScanHealth"
    $CommandList += "Dism /Online /Cleanup-Image /RestoreHealth"
    $CommandList += "sfc /scannow"

    Foreach($Command in $CommandList){
        Start-Process "cmd.exe" "/c $Command" -NoNewWindow -Wait
    }
}

function OptimizeSSD {
    $DriveLetter = (get-location).Drive.Name
        try {
            Optimize-Volume -DriveLetter $DriveLetter -ReTrim -ErrorAction Stop
        }
        catch {
            Write-Host "SDD Optimizer can not run" -BackgroundColor Red -ForegroundColor White
        }
}

Function StartCleanMGR {
    Try{
        Start-Process -FilePath Cleanmgr -ArgumentList '/sagerun:1' -Wait
    }
    Catch [System.Exception]{
        Write-host "cleanmgr is not installed! To use this portion of the script you must install the following windows features:" -ForegroundColor Red -NoNewline
        Write-host "Desktop-Experience, Ink-Handwriting" -ForegroundColor Red -BackgroundColor black
    }
} 

#Scriptblok
RunAsAdmin
RegeditNDUStart
RegeditClearPageFileAtShutdown
DisableService -ServiceName "Sysmain"
RunCMDCommands
OptimizeSSD
StartCleanMGR

