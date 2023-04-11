@echo off
set /p "passw=Enter SHF_USER password: "
cmdkey /add:172.30.16.234 /user:SHF\SHF_USER /pass:%passw%
net use * /delete /y
net use S: \\172.30.16.234\UCLA_SHF_Data %passw% /user:SHF\SHF_USER /p:yes
net use U: \\172.30.16.234\UCLA_Deployment %passw% /user:SHF\SHF_USER /p:yes
