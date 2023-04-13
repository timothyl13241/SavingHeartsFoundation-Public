Clear-Host
Write-Output "######################################################################################"
Write-Output "##################           Saving Hearts Foundation       ##########################"
Write-Output "##################     ZeroTier Install and Config Script   ##########################"
Write-Output "##################           Revision 1a (04/13/2023)       ##########################"
Write-Output "######################################################################################"
Write-Output ""

#Set TLS Version.
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

#Get installed ZeroTier version.
$ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
if ($ZT_ver[0].DisplayVersion -eq '1.10.6')
{
    echo "ZeroTier is up to date! Version $($ZT_ver[0].DisplayVersion) is installed."
}
elseif (($ZT_ver[0].DisplayVersion -ne '1.10.6' ) -and ($ZT_ver[0].DisplayVersion -ne $null))
{
    Write-Output "ZeroTier is not up to date! Updating now..."
    #Download and install newer ZeroTier version.
    Invoke-WebRequest -URI "https://download.zerotier.com/dist/ZeroTier%20One.msi" -OutFile "ZeroTier One.msi"
    $InstallStatus = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ZeroTier One.msi /qn" -Wait -PassThru).ExitCode
    if ($InstallStatus -eq 0)
    {
        $ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
        echo "ZeroTier was updated successfully! Version $($ZT_ver[0].DisplayVersion) was installed."
    }
}
else
{
    Write-Output "ZeroTier is not installed! Installing and configuring now..."
    Invoke-WebRequest -URI "https://download.zerotier.com/dist/ZeroTier%20One.msi" -OutFile "ZeroTier One.msi"
    $InstallStatus = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ZeroTier One.msi /qn" -Wait -PassThru).ExitCode
    if ($InstallStatus -eq 0)
    {
        $ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
        echo "ZeroTier was installed successfully! Version $($ZT_ver[0].DisplayVersion) was installed."
    }
    Write-Output ""
    Write-Output "#########################"
    Write-Output "Configuring ZeroTier now."
    Write-Output "#########################"
    Write-Output ""
    $ConfigStatus = (Start-Process -FilePath "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -ArgumentList "-q join 632ea2908589098f" -Wait -PassThru).ExitCode
    if ($ConfigStatus -eq 2)
    {
        Write-Output "Successfully joined SHF ZeroTier network! Please contact your network admin to enable this device."
        Start-Process -FilePath "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -ArgumentList "-q set 632ea2908589098f allowDNS=1"
    }
    
}

Read-Host -Prompt "Press any key to continue"
