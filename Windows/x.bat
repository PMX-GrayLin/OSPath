@echo off
REM ===============================
REM Batch Script Argument Printer
REM ===============================

REM Change to script directory (uncomment if needed)
REM cd /d "%~dp0"

setlocal enabledelayedexpansion

set count=0
for %%A in (%*) do (
    set /a count+=1
    echo Argument !count!: %%A
)

echo.
echo Total arguments: %count%

endlocal

set live_current="C:\Users\gray.lin\STM32CubeIDE\workspace_1.13.2\.metadata\.plugins\com.st.stm32cube.ide.mcu.livewatch\saved_expr.dat"
set live_backup="D:\prj\STM\liveview\saved_expr_%arg4%.dat"

if "%arg1%"=="stm" (
    if "%arg2%"=="live" (
        if "%arg3%"=="load" (
            copy "%live_backup%" "%live_current%"
        )

        if "%arg3%"=="save" (
            copy "%live_current%" "%live_backup%"
        )
    )
) 

if "%arg1%"=="code" (

    if "%arg2%"=="stmlive" (
        code C:\Users\gray.lin\STM32CubeIDE\workspace_1.13.2\.metadata\.plugins\com.st.stm32cube.ide.mcu.livewatch\saved_expr.dat
    )
)

