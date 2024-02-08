# Script to check if the device is deployad as a self-deploying device
# Written by Jörgen Nilsson
# ccmexec.com
function Get-EnrolledUser {
    # Get the UPN of the user that enrolled the computer to AAD
    $AADInfo = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"

    $guids = $AADInfo.GetSubKeyNames()
    foreach ($guid in $guids) {
        $guidSubKey = $AADinfo.OpenSubKey($guid);
        $UPN = $guidSubKey.GetValue("UserEmail");
    }
    $UserName = ($UPN -split ("@"))[0]
    Write-Output $UserName
}

if (Get-EnrolledUser -eq "autopilot") {
    return $true
}
else {
    return $false
}
