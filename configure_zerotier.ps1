Clear-Host
Write-Output "######################################################################################"
Write-Output "##################           Saving Hearts Foundation       ##########################"
Write-Output "##################     ZeroTier Install and Config Script   ##########################"
Write-Output "##################           Revision 1a (04/13/2023)       ##########################"
Write-Output "######################################################################################"
Write-Output ""

#Self-elevate the script if required.
#(source: https://stackoverflow.com/questions/60209449/how-to-elevate-a-powershell-script-from-within-a-script)
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

#Set TLS Version.
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

#Get installed ZeroTier version.
$ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion

#Define script-level variable for ZT ID
$ZT_ID = "temp" | Out-String

if ($ZT_ver[0].DisplayVersion -eq '1.10.6')
{
    Write-Host "ZeroTier is up to date! Version " -NoNewline -ForegroundColor Green
    Write-Host $ZT_ver[0].DisplayVersion -NoNewline -ForegroundColor Green
    Write-Host " is installed." -ForegroundColor Green
}
elseif (($ZT_ver[0].DisplayVersion -ne '1.10.6' ) -and ($ZT_ver[0].DisplayVersion -ne $null))
{
    Write-Output "ZeroTier is not up to date! Updating now..."
    Write-Output ""
    #Download and install newer ZeroTier version.
    Invoke-WebRequest -URI "https://download.zerotier.com/dist/ZeroTier%20One.msi" -OutFile "C:\ZeroTier One.msi"
    if (Test-Path "C:\ZeroTier One.msi")
    {
        $InstallStatus = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ""C:\ZeroTier One.msi"" /qn" -Wait -PassThru).ExitCode
        if ($InstallStatus -eq 0)
        {
           $ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
           Write-Host "ZeroTier was updated successfully! Version " -NoNewline -ForegroundColor Green
           Write-Host $($ZT_ver[0].DisplayVersion) -NoNewline -ForegroundColor Green
           Write-Host " was installed." -ForegroundColor Green
           Remove-Item "C:\ZeroTier One.msi"
        }
        else
        {
            Write-Output "ZeroTier could not be updated."
        }
    }
    else
    {
        Write-Output "ZeroTier download failed!"
    }
}
else
{
    Write-Output "ZeroTier is not installed! Installing and configuring now..."
    Write-Output ""
    Invoke-WebRequest -URI "https://download.zerotier.com/dist/ZeroTier%20One.msi" -OutFile "C:\ZeroTier One.msi"
    if (Test-Path "C:\ZeroTier One.msi")
    {
        $InstallStatus = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ""C:\ZeroTier One.msi"" /qn" -Wait -PassThru).ExitCode
        if ($InstallStatus -eq 0)
        {
            $ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
            Write-Host "ZeroTier was installed successfully! Version " -NoNewline -ForegroundColor Green
            Write-Host $($ZT_ver[0].DisplayVersion) -NoNewline -ForegroundColor Green
            Write-Host " was installed. Your ID is: " -NoNewline -ForegroundColor Green
            $info = C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe -q info | Out-String
            $ZT_ID = $info.Substring(9, 10)
            Write-Host $ZT_ID -NoNewline -ForegroundColor Green
            Write-Host "."
            Remove-Item "C:\ZeroTier One.msi"
        }
        else
        {
            Write-Output "ZeroTier could not be installed."
        }
        Write-Output ""
        Write-Output "#########################"
        Write-Output "Configuring ZeroTier now."
        Write-Output "#########################"
        Write-Output ""
        $ConfigStatus = (Start-Process -FilePath "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -ArgumentList "-q join 632ea2908589098f" -Wait -PassThru).ExitCode
        if ($ConfigStatus -eq 2)
        {
            Write-Output "Successfully joined SHF ZeroTier network! Please contact your network admin with the above ID to enable this device."
            Start-Process -FilePath "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -ArgumentList "-q set 632ea2908589098f allowDNS=1"
        }
    }
    else
    {
        Write-Host "ZeroTier download failed!"
    }
}

Write-Output ""
Read-Host -Prompt "Press any key to continue"
