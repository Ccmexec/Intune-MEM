# Registry key to create additional registry value for Microsoft Edge not in Settings catalog
 
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
 
# Check if the Microsoft Edge registry key already exists
 
if (!(Test-Path $RegistryPath)) {
 
        New-Item -Path $RegistryPath -Force
 
}
 
# Create the Microsoft Edge additional registry values
 
New-ItemProperty -Path $RegistryPath -Name "WebSQLAccess" -Value "0" -PropertyType dword -Force
 
New-ItemProperty -Path $RegistryPath -Name "SharedArrayBufferUnrestrictedAccessAllowed" -Value "0" -PropertyType dword -Force
 
