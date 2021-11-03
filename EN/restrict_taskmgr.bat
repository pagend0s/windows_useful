@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

GOTO MAIN

:MAIN

wmic UserAccount get Name
	set "user_id="
	set /p "user_id=ENTER THE NAME OF THE USER FOR WHOM YOU WANT TO BLOCK ACCESS TO TASKMGR: "

reg load HKLM\TempHive C:\Users\%user_id%\ntuser.dat

REG.EXE ADD HKLM\TempHive\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\	/v DisableTaskmgr /t REG_DWORD /d 1 /f

pause