@echo off
cls
echo ######################################################################################
echo ########################    Saving Hearts Foundation     #############################
echo ########################   Script to Set Mapped Drives   #############################
echo ########################     Revision 1b (04/13/2023)    #############################
echo ######################################################################################
echo:
set /p "usr=Enter username (SHF\): "
set /p "passw=Enter %usr% password: "
cmdkey /add:172.30.16.234 /user:SHF\%usr% /pass:%passw%
net use * /delete /y
net use S: \\172.30.16.234\UCLA_SHF_Data %passw% /user:SHF\%usr% /p:yes
net use U: \\172.30.16.234\UCLA_Deployment %passw% /user:SHF\%usr% /p:yes
pause
echo ######################################################################################
echo Here are the currently mapped drives:
echo:
net use

echo ######################################################################################
echo Copying Cardea Preferences File
echo D | xcopy "U:\Preference Files\20230411_user.config" "%USERPROFILE%\AppData\Local\Cardiac_Insight,_Inc\Cardea_20.20_ECG.exe_Url_bnysl1bxpkuhajiypxmozcfbiagw0412\5.0.1.6\user.config" /y /z
echo:
echo If the above failed, you need to import the preference file manually! 
echo Otherwise, just check that the Data Acquisition location is set properly. 
pause
exit /b 0
