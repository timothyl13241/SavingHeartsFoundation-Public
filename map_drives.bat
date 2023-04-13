@echo off
cls
echo ######################################################################################
echo ########################   Script to Set Mapped Drives   #############################
echo ########################     Revision 1b (04/13/2023)    #############################
echo ######################################################################################
echo:
set /p "passw=Enter SHF_USER password: "
cmdkey /add:172.30.16.234 /user:SHF\SHF_USER /pass:%passw%
net use * /delete /y
net use S: \\172.30.16.234\UCLA_SHF_Data %passw% /user:SHF\SHF_USER /p:yes
net use U: \\172.30.16.234\UCLA_Deployment %passw% /user:SHF\SHF_USER /p:yes
pause
echo ######################################################################################
echo Here are the currently mapped drives:
echo:
net use

echo ######################################################################################
echo Copying Cardea Preferences File
echo D | xcopy "U:\Preference Files\20230411_user.config" %USERPROFILE%\AppData\Local\Cardiac_Insight,_Inc\Cardea_20.20_ECG.exe_Url_bnysl1bxpkuhajiypxmozcfbiagw0412\5.0.1.6\user.config /y /z
echo:
echo If the above failed (i.e. 0 files copied), you need to import the preference file manually! 
echo Otherwise, if you see 1 file, just check that the Data Acquisition location is set properly. 
pause
exit /b 0
