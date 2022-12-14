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
    - Popup message with the info that you need to reboot your device.
.PARAMETER message
    Path = The pathn of the regkey
    Name = Regkey name
    Value = The value of the regkey name
    ServiceName = The service name for Sysmain.
    Header = The header of the popup message.
    Message = The message what will show in the popup.
.EXAMPLE
	PS> ./Fix-HighMemory_W10_W11.ps1
.LINK
	https://github.com/MrRamsus/Windows11_Public/blob/main/Fix-HighMemory_W10_W11.ps1
.NOTES
	Author: MrRamsus
#>

Function RunAsAdmin{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

Function ChangeRegKey{
    Param(
        $Path,
        $Name,
        $Value
    )
    $Regkey = Get-Itemproperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if($Regkey){
        If($Regkey.$Name -ne $Value){
                try {
                    Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
                }
                catch {
                    Write-Host "Regkey $Name can not be changed" -BackgroundColor Red -ForegroundColor White
                }
            }
        }else{
                try {
                    New-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
                }
                catch {
                    Write-Host "Regkey $Name can not be created" -BackgroundColor Red -ForegroundColor White
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

Function TriggerPopUp{
    Param(
        $Header,
        $Message
    )
    $notify = new-object system.windows.forms.notifyicon
    $notify.icon = [System.Drawing.SystemIcons]::Information
    $notify.visible = $true
    $notify.showballoontip(10,$Header,$Message,[system.windows.forms.tooltipicon]::None)
}

#Scriptblok
RunAsAdmin
ChangeRegKey -Path "HKLM:SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Value "4"
ChangeRegKey -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value "1"
DisableService -ServiceName "Sysmain"
RunCMDCommands
OptimizeSSD
StartCleanMGR
TriggerPopUp -Header "Reboot Required" -Message "You will need to restart this device for the completion of this fix!"
