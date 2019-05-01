@echo off
color 0a
title hosts appender 1.0

SETLOCAL ENABLEDELAYEDEXPANSION
set /a RTN_VAL=0
set ORIGIN_HOSTS=C:\Windows\system32\drivers\etc\hosts
set FILE_HOSTS=hosts.tmp
set FOLDER_HOSTS=hosts.tmp.1

if not exist "%ORIGIN_HOSTS%" (
	echo Not exist hosts.
	goto NORMAL_EXIT
)

set /a RTN_VAL=0
cd /d "%ORIGIN_HOSTS%" && set /a RTN_VAL=1
if !RTN_VAL! equ 1 (
	echo Not a hosts file.
	goto NORMAL_EXIT
)
cls

if "%TEMP%" neq "" (
	cd /d "%TEMP%"
	set /a RTN_VAL=0
	cd . > "%FILE_HOSTS%" || set /a RTN_VAL=1
	if !RTN_VAL! equ 1 (
		cls
		echo Can not access to "%FILE_HOSTS%".
		goto NORMAL_EXIT
	)
) else (
	echo Environment Variables - TEMP is empty.
	goto NORMAL_EXIT
)

:INPUT_COMMENTS
set /p COMMENTS=Enter comments: 
if "%COMMENTS%" equ "" (
	goto INPUT_COMMENTS
)
:INPUT_IP_ADDRESS
set /p IP_ADDRESS=Enter IP address: 
if "%IP_ADDRESS%" equ "" (
	goto INPUT_IP_ADDRESS
)
:INPUT_HOST_NAMES
set /p HOST_NAMES=Enter host names: 
if "%HOST_NAMES%" equ "" (
	goto INPUT_HOST_NAMES
)

>> "%FILE_HOSTS%" echo.
>> "%FILE_HOSTS%" echo # %COMMENTS%
>> "%FILE_HOSTS%" echo     %IP_ADDRESS%    %HOST_NAMES%

cls
echo Preview: 
type "%FILE_HOSTS%"
echo.

:INPUT_APPEND_CONFIRM
set /p APPEND_CONFIRM=Enter 'Y' append to origin hosts, or 'n' quit.": 
if "%APPEND_CONFIRM%" equ "Y" (
	set /a RTN_VAL=0
	type "%FILE_HOSTS%" >> "%ORIGIN_HOSTS%" || set /a RTN_VAL=1
	if !RTN_VAL! equ 0 (
		echo Completed successfully.
		goto NORMAL_EXIT
	) else (
		cls
		if exist "%FOLDER_HOSTS%" (
			rmdir /s /q "%FOLDER_HOSTS%"
		)
		mkdir "%FOLDER_HOSTS%"
		type "%ORIGIN_HOSTS%" > "%FOLDER_HOSTS%\hosts"
		type "%FILE_HOSTS%" >> "%FOLDER_HOSTS%\hosts"

		set ORIGIN_ATTR=
		for /f "tokens=*" %%I in ("%ORIGIN_HOSTS%") do (
			set ORIGIN_ATTR=%%~aI
		)
		if "!ORIGIN_ATTR!" neq "" (
			set /a RTN_VAL=0
			for /f "tokens=1* delims=-" %%m in ("!ORIGIN_ATTR!") do (
				set ORIGIN_ATTR=%%m
				set /a RTN_VAL=1
			)
			if !RTN_VAL! equ 0 (
				set ORIGIN_ATTR=
			)
		) else (
			echo Can not obtain file attributes.
			goto NORMAL_EXIT
		)
		attrib -r -a -s -h -i "%FOLDER_HOSTS%\hosts"
		set SURPLUS=!ORIGIN_ATTR!
		set STR_ATTR=
		:PROCESS_ATTR
		for /f "tokens=*" %%m in ("!SURPLUS!") do (
			set STR_ATTR=!STR_ATTR!+!SURPLUS:~0,1! 
			set SURPLUS=!SURPLUS:~1!
		)
		if "!SURPLUS!" neq "" (
			goto PROCESS_ATTR
		)
		if "!STR_ATTR!" neq "" (
			rem No 'I'.
			attrib !STR_ATTR!"%FOLDER_HOSTS%\hosts"
		)

		set /a RTN_VAL=0
		xcopy /y /q /h /r /k "%FOLDER_HOSTS%\hosts" "%ORIGIN_HOSTS%" || set /a RTN_VAL=1
		if !RTN_VAL! equ 0 (
			cls
			echo Completed successfully.
			goto NORMAL_EXIT
		) else (
			echo Failed.
			goto NORMAL_EXIT
		)
	)
) else if "%APPEND_CONFIRM%" equ "n" (
	goto NORMAL_EXIT
) else (
	goto INPUT_APPEND_CONFIRM
)

:NORMAL_EXIT
pause
exit
