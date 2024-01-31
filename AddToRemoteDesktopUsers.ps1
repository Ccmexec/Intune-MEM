# Script to add the user who enrolled the computer in Microsoft Entra to the remote desktop users group
# Written by Jörgen Nilsson
# ccmexec.com

$LocalGroup = Get-LocalGroup -SID "S-1-5-32-555"
$Localgroupname = $LocalGroup.name

function Get-MembersOfGroup {
    Param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$GroupName,
        [string]$Computer = $env:COMPUTERNAME
    )

    $membersOfGroup = @()
    $ADSIComputer = [ADSI]("WinNT://$Computer,computer")
    $group = $ADSIComputer.psbase.children.find("$GroupName", 'Group')

    $group.psbase.invoke("members") | ForEach-Object {
        $membersOfGroup += $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }

    $membersOfGroup
}

# Get the UPN of the user that enrolled the computer to AAD
$AADInfo = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"
$RDPUsers = Get-MembersOfGroup $Localgroupname

$guids = $AADInfo.GetSubKeyNames()
foreach ($guid in $guids) {
    $guidSubKey = $AADinfo.OpenSubKey($guid);
    $UPN = $guidSubKey.GetValue("UserEmail");
}

$Username = $UPN -split ("@")
$Username = $Username[0]

if ($UPN) {
        if (!($RDPUsers -contains $Username)) {
            Add-LocalGroupMember -Group $Localgroupname -Member "Azuread\$UPN"
            "Added AzureAD\$UPN as a member of the Remote Desktop Users." | Out-File -FilePath $env:TEMP\RDPUsers.log
        }
        else {
            "AzureAD\$UPN is already a member of the Remote Desktop Users Group." | Out-File -FilePath $env:TEMP\RDPUsers.log
        }
    }
    else {
        "Failed to find an RDPUsername in registry." | Out-File -FilePath $env:TEMP\RDPUsers.log
}
