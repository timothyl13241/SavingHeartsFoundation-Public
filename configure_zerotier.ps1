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
Write-Host "##################           Revision 1c (10/25/2023)       ##########################"
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
    $RegPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $ZT_path = "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe"
    $UEMSRegPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
}
else
{
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $ZT_path = "C:\ProgramData\ZeroTier\One\zerotier-one_x86.exe"
    $UEMSRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
}

$ZT_ver = Get-ItemProperty $RegPath | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion

#Define script-level variable for ZT ID
$ZT_ID = "temp" | Out-String
$ZT_CurrVer = '1.12.2'

if ($ZT_ver -ne $null)
{
    if ($ZT_ver[0].DisplayVersion -eq $ZT_CurrVer)
    {
        Write-Host "ZeroTier is up to date! Version " -NoNewline -ForegroundColor Green
        Write-Host $ZT_ver[0].DisplayVersion -NoNewline -ForegroundColor Green
        Write-Host " is installed." -ForegroundColor Green
    }
    elseif (($ZT_ver[0].DisplayVersion -ne $ZT_CurrVer ) -and ($ZT_ver[0].DisplayVersion -ne $null))
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
                $ZT_ver = Get-ItemProperty $RegPath | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
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
    #Check if moons are orbited.
    $NetStatus = & $ZT_path -q listmoons | Out-String
    if ($NetStatus.Trim() -eq '')
    {
        Write-Host "Custom moons have not yet been orbited!"
        Start-Process -FilePath $ZT_path -ArgumentList "-q orbit 7549d395fe 7549d395fe" -Wait
        Write-Host "Added moons to orbit."
    }
    else
    {
        Write-Host "Custom moons already orbited!"
        Start-Process -FilePath $ZT_path -ArgumentList "-q deorbit 85fb50d876" -Wait
    }
}
else
{
    Write-Host "ZeroTier is not installed! Installing and configuring now..."
    Write-Host ""
    Invoke-WebRequest -URI "https://download.zerotier.com/dist/ZeroTier%20One.msi" -OutFile "C:\ZeroTier One.msi"
    if (Test-Path "C:\ZeroTier One.msi")
    {
        $ZTInstallStatus = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i ""C:\ZeroTier One.msi"" /qn" -Wait -PassThru).ExitCode
        if ($ZTInstallStatus -eq 0)
        {
            $ZT_ver = Get-ItemProperty $RegPath | Where-Object {$_.DisplayName -like "*zerotier*"} | Select-Object DisplayVersion
            Write-Host "ZeroTier was installed successfully! Version " -NoNewline -ForegroundColor Green
            Write-Host $($ZT_ver[0].DisplayVersion) -NoNewline -ForegroundColor Green
            Write-Host " was installed. Your ID is: " -NoNewline -ForegroundColor Green
            $info = & $ZT_path -q info | Out-String
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
                Start-Process -FilePath $ZT_path -ArgumentList "-q set 632ea2908589098f allowDNS=1"
                Set-NetConnectionProfile -InterfaceAlias ZeroTier* -NetworkCategory Private
            }
            else
            {
                Write-Host "Unable to join ZT network and configure settings. Please contact your network admin." -ForegroundColor Red
            }

            $NetStatus = & $ZT_path -q listmoons | Out-String
            if ($NetStatus.Trim() -eq '')
            {
                Write-Host "Custom moons have not yet been orbited!"
                Start-Process -FilePath $ZT_path -ArgumentList "-q orbit 7549d395fe 7549d395fe"
            }
            else
            {
                Write-Host "Custom moons already orbited!"
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
Write-Host "Downloading ZeroTier local configuration file"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/timothyle97/SavingHeartsFoundation-Public/main/local.conf" -OutFile "C:\local.conf"
Move-Item -Path C:\local.conf -Destination C:\ProgramData\ZeroTier\One\local.conf -Force 

Write-Host ""
Write-Host "Restarting ZeroTier. Waiting 30 seconds..."
Restart-Service -DisplayName "ZeroTier*" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 10

while ((Get-Service -DisplayName "ZeroTier*").Status -ne "Running")
{
    Write-Host "Attempting to restart ZeroTier..."
    Start-Service -DisplayName "ZeroTier*" -ErrorAction SilentlyContinue
}

Write-Host "ZeroTier successfully restarted." -ForegroundColor Green

Write-Host ""

#Get installed ManageEngine version.
$UEMS_ver = Get-ItemProperty $UEMSRegPath | Where-Object {$_.DisplayName -like "*UEMS*"} | Select-Object DisplayVersion

if ($UEMS_ver -ne $null)
{
    Write-Host "ManageEngine Agent Version " -NoNewline -ForegroundColor Green
    Write-Host $UEMS_ver[0].DisplayVersion -NoNewline -ForegroundColor Green
    Write-Host " is installed." -ForegroundColor Green
}
else
{
    #Download and install UEMS Agent. 
    Write-Host "Installing ManageEngine Agent!"
    Invoke-WebRequest -Uri "https://desktopcentral.manageengine.com/download?encapiKey=wSsVR6118hf4Da99yjKkL%2Bc7nlxXVV2jQU15jlPzunapHf7LpcdonxedVAKiGfAXFDQ%2FRTIXrbt8nEtSgDQH3t0uyVoEXSiF9mqRe1U4J3x1rb26lDTKX2Q%3D&os=Windows" -OutFile "C:\MOBILENET_Agent.exe"
    if (Test-Path "C:\MOBILENET_Agent.exe")
    {
        $UEMSInstallStatus = (Start-Process -FilePath "C:\MOBILENET_Agent.exe" -ArgumentList "/silent" -Wait -PassThru).ExitCode
        if ($UEMSInstallStatus -eq 0)
        {
            $UEMS_ver = Get-ItemProperty $UEMSRegPath | Where-Object {$_.DisplayName -like "*UEMS*"} | Select-Object DisplayVersion
            Write-Host "ManageEngine agent was installed successfully! Version " -NoNewline -ForegroundColor Green
            Write-Host $($UEMS_ver[0].DisplayVersion) -NoNewline -ForegroundColor Green
            Write-Host " was installed." -ForegroundColor Green
            Remove-Item "C:\MOBILENET_Agent.exe"
        }
        else
        {
            Write-Host "ManageEngine agent could not be updated." -ForegroundColor Red
        }
    }
    else
    {
        Write-Output "ManageEngine download failed!"
    }
}

#Download and install Atera Agent. 
Write-Host "Installing ATERA Agent!"
Invoke-WebRequest -Uri "https://nitpro.servicedesk.atera.com/GetAgent/Msi/?customerId=7&integratorLogin=timothyle97%40gmail.com&customerName=Saving%20Hearts%20Foundation&accountId=0013z00002fL1rhAAC" -OutFile "C:\AteraAgent.exe"
if (Test-Path "C:\AteraAgent.exe")
{
    $ATERAInstallStatus = (Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i C:\AteraAgent.msi /qn IntegratorLogin=timothyle97@gmail.com CompanyId=7 AccountId=0013z00002fL1rhAAC" -Wait -PassThru).ExitCode
    if ($ATERAInstallStatus -eq 0)
    {
        Write-Host "ATERA Agent installed successfully!" -ForegroundColor Green
        Remove-Item "C:\AteraAgent.exe"
    }
    else
    {
       Write-Host "ATERA Agent could not be installed." -ForegroundColor Red
    }
}
Write-Host ""
Read-Host -Prompt "Press any key to continue"
Remove-Item $PSCommandPath -Force
