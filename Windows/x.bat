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
    set "arg!count!=%%~A"
    echo Argument !count!: %%A
)

echo.
echo Total arguments: !count!

REM Example usage of arg1 / arg2 after loop
if /i "!arg1!"=="iq" (
    set "base_dir=D:\project\MediaToolKit_IoTYocto_240522"

    if /i "!arg2!"=="s1" (
        cd /d "%base_dir%"
        call 01_cct_setup.bat
        call 02_NDD_preview_8395.bat
    )

    if /i "!arg2!"=="s2" (
        cd /d "%base_dir%\svn\install"
        call 4.0.MTKToolCustom.bat
    )

    if /i "!arg2!"=="ob1" (
        cd /d "%base_dir%\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 01_init_ISP7_IoTYocto.bat
    )
    if /i "!arg2!"=="ob2" (
        cd /d "%base_dir%\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 03_Dump_raw_minsatgain_ISP7_IoTYocto.bat
    )


)

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

