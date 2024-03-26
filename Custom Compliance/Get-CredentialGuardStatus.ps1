$DevGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
$CredGuardStatus = @{"CredentialGuardRunning" = ($DevGuard.SecurityServicesRunning -contains 1)}
Return $CredGuardStatus | ConvertTo-Json -Compress
