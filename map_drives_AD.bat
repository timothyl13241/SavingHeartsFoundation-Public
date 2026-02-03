@echo off
cls
echo ######################################################################################
echo ########################    Saving Hearts Foundation     #############################
echo ########################   Script to Set Mapped Drives   #############################
echo ########################     Revision 2f (05/16/2025)    #############################
echo ######################################################################################
echo:
echo %ComputerName%
setlocal
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "10.0" echo Windows 10
if "%version%" == "6.3" echo Windows 8.1
if "%version%" == "6.2" echo Windows 8.
if "%version%" == "6.1" echo Windows 7.
if "%version%" == "6.0" echo Windows Vista.
rem etc etc
endlocal
echo:
echo ######################################################################################
echo:
net use * /delete /y
net use S: \\172.17.16.234\UCLA_SHF_Data /p:yes
net use U: \\172.17.16.234\UCLA_Deployment /p:yes
pause
echo ######################################################################################
echo Here are the currently mapped drives:
echo:
net use

echo ######################################################################################
echo Copying Cardea Preferences File
for /D %%D in ("%USERPROFILE%\AppData\Local\Cardiac_Insight,_Inc\*") do (echo F | xcopy "U:\Preference Files\20260207_user.config" "%%~D\5.0.1.6\user.config" /y /z)
echo:
echo If the above failed (i.e. 0 files copied), you need to import the preference file manually! 
echo Otherwise, if you see 1 file, just check that the Data Acquisition location is set properly.
pause
exit /b 0
