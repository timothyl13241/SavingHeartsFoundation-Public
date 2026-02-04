# Example Windows minion install via MSI
$msiUrl = "https://repo.saltproject.io/salt/py3/win/3006/Salt-Minion-3006-Py3-AMD64.msi"
$msiPath = "$env:TEMP\Salt-Minion.msi"
Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath
Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" MASTER=salt.internal.savingheartsfoundation.com /qn" -Wait
Start-Service -Name "salt-minion"
Set-Service -Name "salt-minion" -StartupType Automatic
