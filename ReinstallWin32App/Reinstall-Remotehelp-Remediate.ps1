<#
Version: 1.0
Author: 
- Jorgen Nilsson (ccmexec.com)
Script: Reinstall-Remotehelp-Remediate.ps1
Description:
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run as: Admin
Context: 64 Bit
#> 

#Define AppID/MSIProductcode
$AppID = "f3f8ea42-2a57-42e5-999e-399d01337e9b"
$MSIProductCode = "{1E06C136-5B6F-4A98-8296-CEFE858DEEE6}"

try {
      #Uninstall application
      Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $MSIProductCode /quiet /noreboot" -Wait
}
catch {
      $errorMessage = $_.Exception.Message
      Write-Host $errorMessage
      exit 1
}

#Clear IME registry values
$Regpath = "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps"
Get-ChildItem -Path $Regpath -Recurse -Exclude "*AppAuthority*" | Where-Object { $_.PSChildName -like "*$AppId*" -or $_.Property -like "*$AppId*" } | Remove-Item -Recurse -Force

#Restart IME service
Start-Process -FilePath powershell -ArgumentList '-Executionpolicy bypass -command "& {Start-Sleep 160 ; Restart-Service -Name IntuneManagementExtension -Force}"'

#Exit script
Exit 0 
 
