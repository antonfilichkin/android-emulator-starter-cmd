@echo OFF
cls

REM ===== Batch Parameters =====
setlocal EnableDelayedExpansion
set colNormal=02
set colError=04

REM ===== Check If Emulator Is Present on PATH =====
for /F %%i in ('emulator.exe') do set EMULATORS_PATH=%%i
if NOT defined EMULATORS_PATH goto NO_EMULATOR_FOUND

REM ===== Reading Aviable Emulators Images =====
set TOTAL_COUNT=0
for /F %%i in ('emulator -avd -list-avds') do (
    set /A TOTAL_COUNT+=1
    set EMULATORS[!TOTAL_COUNT!]=%%i
)

:ADB_START
REM ===== Starting ADB Server
call adb start-server >nul 2>&1

:MENU
REM ===== Populating Menu =====
cls
color %colNormal%
echo ..................................................
echo Choose emulator to run:
echo.
for /L %%i in (1, 1, %TOTAL_COUNT%) do (
    echo %%i !EMULATORS[%%i]!
)
echo.
echo A - Start All
echo.
echo S - Refresh Attached Devices
echo R - Restart ADB server 
echo Q - Quit
echo ..................................................
echo.
REM ===== Listing connected devices =====
call adb devices

set /P Choice=Select option and press ENTER:
echo.

REM ===== Validating User Input =====
REM ----- check if input is number & valid -----
set /A isNum=%Choice% 2>nul
if %isNum%==%Choice% (
    if %isNum% LEQ %TOTAL_COUNT%(
	if %isNum% GTR 0 ( 
            goto START_EMULATOR
        )
    )
    color %colError%
    echo Wrong Emulator Number!
    goto SMTH_GONE_WRONG
)
REM ----- check if input is valid character -----
if /I %Choice%==A goto START_ALL
if /I %Choice%==S goto REFRESH_ADB
if /I %Choice%==R goto RESTART_ADB
if /I %Choice%==Q goto :EOF
echo No Such Option!

:SMTH_GONE_WRONG
timeout /t 3
goto MENU

:START_EMULATOR
start emulator -avd !EMULATORS[%Choice%]!
goto MENU

:START_ALL
for /L %%i in (1, 1, %TOTAL_COUNT%) do (
    start cmd /c emulator -avd !EMULATORS[%%i]!
)
goto MENU

:REFRESH_ADB
goto MENU

:RESTART_ADB
call adb kill-server
goto ADB_START

:NO_EMULATOR_FOUND
    color %colError%
    echo No emulator (emulator.exe) found on PATH!
    echo Try running from emulator folder, or add:
    echo "%USERPROFILE%\AppData\Local\Android\Sdk\tools"
    echo "%USERPROFILE%\AppData\Local\Android\Sdk\emulator"
    echo "to Enviromental Variables."
    timeout /t 10
)
