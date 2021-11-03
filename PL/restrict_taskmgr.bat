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

GOTO SET_USER

:SET_USER

wmic UserAccount get Name
	set "user_id="
	set /p "user_id=PODAJ NAZWE UZYTKOWNIKA DLA KTOREGO CHCESZ USTAWIC CZAS Z LISTY U GORY: "
GOTO MAIN

:MAIN

SETLOCAL ENABLEDELAYEDEXPANSION
SET /A FOUND_VAR=0
FOR /F "tokens=* USEBACKQ" %%F IN (`query session`) DO (

		echo %%F|findstr /i /c:"%user_id%" >nul
		if errorlevel 1 ( echo: ) else ( SET /A FOUND_VAR=1 )
		)
IF %FOUND_VAR% == 1 (
	GOTO WRITE_REG_WITH_SID
	)	else	(
	GOTO WRITE_REG_WITH_HIVE
	)

ENDLOCAL

:WRITE_REG_WITH_SID
for /f "delims= " %%a in ('"wmic path win32_useraccount where name='%user_id%' get sid"') do (
   if not "%%a"=="SID" (          
      set sid_var=%%a
      goto write_reg
   )   
)

:write_reg
echo %sid_var%

REG.EXE ADD HKEY_USERS\%sid_var%\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System

GOTO end

:WRITE_REG_WITH_HIVE

reg load HKLM\TempHive C:\Users\%user_id%\ntuser.dat

REG.EXE ADD HKLM\TempHive\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\	/v DisableTaskmgr /t REG_DWORD /d 1 /f

GOTO end

:end
pause
