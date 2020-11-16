$NewPassword = "Password1"
$OldPassword = "Password2"
$DetectionRegPath = "HKLM:\SOFTWARE\Onevinn\Intune\DellBIOSProvider"
$DetectionRegName = "PasswordSet"

Start-Transcript -Path "$env:TEMP\$($(Split-Path $PSCommandPath -Leaf).ToLower().Replace(".ps1",".log"))" | Out-Null

if (-not (Test-Path -Path $DetectionRegPath)) {
    New-Item -Path $DetectionRegPath -Force | Out-Null
}

if (Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider") {
    Write-Output "DellBIOSProvider folder already exists @ $env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider."
    Write-Output "Deleting the folder..."
    Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider" -Recurse -Force
}

Write-Output "Copying DellBIOSProvider module to: $env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider" 
Copy-Item -Path "$PSScriptRoot\DellBIOSProvider\" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider" -Recurse -Force

try {
    Import-Module "DellBIOSProvider" -Force -Verbose -ErrorAction Stop
}
catch {
    Write-Output "Error importing module: $_"
    exit 1
}

$IsAdminPassSet = (Get-Item -Path DellSmbios:\Security\IsAdminPasswordSet).CurrentValue

if ($IsAdminPassSet -eq $false) {
    Write-Output "Admin password is not set at this moment, will try to set it."
    Set-Item -Path DellSmbios:\Security\AdminPassword "$NewPassword"
    if ( (Get-Item -Path DellSmbios:\Security\IsAdminPasswordSet).CurrentValue -eq $true ){
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
        Set-Item -Path DellSmbios:\Security\AdminPassword "$NewPassword" -Password "$OldPassword"
        New-ItemProperty -Path "$DetectionRegPath" -Name "$DetectionRegName" -Value 1 | Out-Null
    }
}

Stop-Transcript