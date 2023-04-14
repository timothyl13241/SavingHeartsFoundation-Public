#Self-elevate the script if required.
#(source: https://stackoverflow.com/questions/60209449/how-to-elevate-a-powershell-script-from-within-a-script)
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

Clear-Host
Write-Host "######################################################################################"
Write-Host "##################           Saving Hearts Foundation       ##########################"
Write-Host "##################     ZeroTier Install and Config Script   ##########################"
Write-Host "##################           Revision 1a (04/13/2023)       ##########################"
Write-Host "######################################################################################"
Write-Host ""

Write-Host "Computer Name: " -NoNewline; Write-Host $env:computername
Write-Host "Operating System: " -NoNewline; [System.Environment]::OSVersion.Version | Write-Host
Write-Host "OS Architecture: " -NoNewline; (Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture | Write-Host
Write-Host ""
Write-Host "######################################################################################"
Write-Host ""

#Set TLS Version.
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

#Get installed ZeroTier version.
if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -like "64*")
{
    $ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
}
else
{
        $ZT_ver = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
}

#Define script-level variable for ZT ID
$ZT_ID = "temp" | Out-String

if ($ZT_ver -ne $null)
{
    if ($ZT_ver[0].DisplayVersion -eq '1.10.6')
    {
        Write-Host "ZeroTier is up to date! Version " -NoNewline -ForegroundColor Green
        Write-Host $ZT_ver[0].DisplayVersion -NoNewline -ForegroundColor Green
        Write-Host " is installed." -ForegroundColor Green
    }
    elseif (($ZT_ver[0].DisplayVersion -ne '1.10.6' ) -and ($ZT_ver[0].DisplayVersion -ne $null))
    {
        Write-Host "ZeroTier is not up to date! Updating now..." -ForegroundColor Yellow
        Write-Host ""
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
                Write-Host "ZeroTier could not be updated." -ForegroundColor Red
            }
        }
        else
        {
            Write-Output "ZeroTier download failed!"
        }
    }
}
else
{
    Write-Host "ZeroTier is not installed! Installing and configuring now..."
    Write-Host ""
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

            Write-Host ""
            Write-Host "#########################"
            Write-Host "Configuring ZeroTier now."
            Write-Host "#########################"
            Write-Host ""
            $ConfigStatus = C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe -q join 632ea2908589098f | Out-String
            if ($ConfigStatus.Trim() -eq "200 join OK")
            {
                Write-Host "Successfully joined SHF ZeroTier network!" -ForegroundColor Green
                Write-Host "Please contact your network admin with the above ID to enable this device." -ForegroundColor Green
                Start-Process -FilePath "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -ArgumentList "-q set 632ea2908589098f allowDNS=1"
                Set-NetConnectionProfile -InterfaceAlias ZeroTier* -NetworkCategory Private
            }
            else
            {
                Write-Host "Unable to join ZT network and configure settings. Please contact your network admin." -ForegroundColor Red
            }
        }
        else
        {
            Write-Host "ZeroTier could not be installed." -ForegroundColor Red
        }
        
    }
    else
    {
        Write-Host "ZeroTier download failed!"
    }
}

Write-Host ""
Read-Host -Prompt "Press any key to continue"
Remove-Item $PSCommandPath -Force
