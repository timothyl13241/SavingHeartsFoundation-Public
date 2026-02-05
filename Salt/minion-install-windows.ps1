# Example Windows minion install via MSI
$msiUrl = "https://packages.broadcom.com/artifactory/saltproject-generic/windows/3007.11/Salt-Minion-3007.11-Py3-AMD64.msi"
$msiPath = "$env:TEMP\Salt-Minion.msi"
Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath
Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" MASTER=salt.internal.savingheartsfoundation.com /qn" -Wait
Start-Service -Name "salt-minion"
Set-Service -Name "salt-minion" -StartupType Automatic
cd "C:\Program Files\Salt Project\Salt\"
.\salt-call.exe test.ping
Read-Host -Prompt "Please reach out to your admin to authorize the minion key. Then press Enter to continue"
.\salt-call.exe state.highstate
