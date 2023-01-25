:START
@ECHO OFF&&CLS&&TITLE  Download from github.com/joshuacline&&COLOR 0C&&Reg.exe query "HKU\S-1-5-19\Environment">NUL
IF NOT %ERRORLEVEL% EQU 0 ECHO Right-Click ^& Run As Administrator&&PAUSE&&EXIT 0
FOR /F "TOKENS=*" %%a in ('WHOAMI') do (IF "%%a"=="nt authority\system" GOTO:LOCKDOWN)
ECHO (1) Install LockDown Service&&ECHO (2) Uninstall LockDown Service&&ECHO Press (Enter) to exit...&&SET "SELECT="&&SET /P "SELECT=$>>"
SET "REMOVE="&&IF "%SELECT%"=="2" SET "LOCKDOWN=0"&&SET "REMOVE=1"&&SC DELETE LockDown>NUL 2>&1
IF DEFINED REMOVE SC DELETE LockDownClear>NUL 2>&1
IF DEFINED REMOVE GOTO:JUMP
IF NOT "%SELECT%"=="1" EXIT 0
COPY /Y "%0" "%PROGRAMDATA%\LockDown.cmd">NUL 2>&1
SC CREATE LockDown BINPATH="CMD /C START %PROGRAMDATA%\LockDown.cmd" START=DEMAND>NUL 2>&1
SC CREATE LockDownClear BINPATH="%WinDir%\SYSTEM32\CMD.EXE /C REG.EXE ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /v RestrictRun /t REG_DWORD /d 0 /f" START=AUTO>NUL 2>&1
CLS&&ECHO LockDown Installed @ %PROGRAMDATA%\LockDown.cmd&&ECHO Start LockDown via Taskmgr Services-tab&&ECHO LockDown will clear on reboot&&SET /P PAUSED=Press (Enter) to continue...
GOTO:START
:LOCKDOWN
SET "LOCKDOWN="&&FOR /F "TOKENS=3 SKIP=1 DELIMS=: " %%a in ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v RestrictRun /s') do (IF "%%a"=="0x0" CALL SET "LOCKDOWN=1"
IF "%%a"=="0x1" CALL SET "LOCKDOWN=0")
:JUMP
IF NOT DEFINED LOCKDOWN SET "LOCKDOWN=0"
REG.EXE ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "RestrictRun" /t REG_DWORD /d "%LOCKDOWN%" /f>NUL 2>&1
IF "%REMOVE%"=="1" ECHO Removing LockDown...
GPUPDATE /FORCE>NUL 2>&1
IF "%REMOVE%"=="1" CLS&&ECHO LockDown Removed&&DEL /F "%PROGRAMDATA%\LockDown.cmd">NUL 2>&1
IF "%REMOVE%"=="1" SET /P PAUSED=Press (Enter) to continue...
IF "%REMOVE%"=="1" GOTO:START
EXIT 0