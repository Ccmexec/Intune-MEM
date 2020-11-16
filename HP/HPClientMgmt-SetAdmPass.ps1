Start-Transcript -Path "$env:TEMP\$($(Split-Path $PSCommandPath -Leaf).ToLower().Replace(".ps1",".log"))" | Out-Null

$NewPassword = "Password1"
$OldPassword = "Password2"
$DetectionRegPath = "HKLM:\SOFTWARE\Onevinn\Intune\HPClientMgmt"
$DetectionRegName = "PasswordSet"

if (-not (Test-Path -Path $DetectionRegPath)) {
    New-Item -Path $DetectionRegPath -Force | Out-Null
}

if (Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\HP.ClientManagement") {
    Write-Output "HP.ClientManagement folder already exists @ $env:ProgramFiles\WindowsPowerShell\Modules\HP.ClientManagement."
    Write-Output "Deleting the folder..."
    Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\HP.ClientManagement" -Recurse -Force
}

if (Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\HP.SoftPaq.Shared") {
    Write-Output "HP.SoftPaq.Shared folder already exists @ $env:ProgramFiles\WindowsPowerShell\Modules\HP.SoftPaq.Shared."
    Write-Output "Deleting the folder..."
    Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\HP.SoftPaq.Shared" -Recurse -Force
}

Write-Output "Copying HP.ClientManagement module to: $env:ProgramFiles\WindowsPowerShell\Modules\HP.ClientManagement" 
Copy-Item -Path "$PSScriptRoot\HP.ClientManagement\" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\HP.ClientManagement" -Recurse -Force

Write-Output "Copying HP.SoftPaq.Shared module to: $env:ProgramFiles\WindowsPowerShell\Modules\HP.SoftPaq.Shared" 
Copy-Item -Path "$PSScriptRoot\HP.SoftPaq.Shared\" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\HP.SoftPaq.Shared" -Recurse -Force

try {
    Import-Module "HP.ClientManagement" -Force -Verbose -ErrorAction Stop
}
catch {
    Write-Output "Error importing module: $_"
    exit 1
}

$IsAdminPassSet = Get-HPBiosSetupPasswordIsSet

if ($IsAdminPassSet -eq $false) {
    Write-Output "Admin password is not set at this moment, will try to set it."
    Set-HPBiosSetupPassword -newPassword "$NewPassword"
    if ( (Get-HPBiosSetupPasswordIsSet) -eq $true ){
        Write-Output "Admin password has now been set."
        New-ItemProperty -Path "$DetectionRegPath" -Name "$DetectionRegName" -Value 1 | Out-Null
    }
}
else {
    Write-Output "Admin password is already set"
    if ($null -eq $OldPassword) {
        Write-Output "`$OldPassword variable has not been specified, will not attempt to change admin password"
    }
    else {
        Write-Output "`$OldPassword variable has been specified, will try to change the admin password"
        try {
            Set-HPBiosSetupPassword -newPassword "$NewPassword" -Password "$OldPassword"
        }
        catch [System.Management.Automation.RuntimeException] {
            Write-Output "Access Denied error, verify that `$OldPassword is correct"
        }
        New-ItemProperty -Path "$DetectionRegPath" -Name "$DetectionRegName" -Value 1 -Force | Out-Null
    }
}

Stop-Transcript
