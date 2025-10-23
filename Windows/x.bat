@echo off
setlocal enabledelayedexpansion

:: -----------------------------
:: Parse all command-line args
:: -----------------------------
set count=0
for %%A in (%*) do (
    set /a count+=1
    set "arg!count!=%%~A"
    echo Argument !count!: %%A
)

echo.
echo Total arguments: !count!

:: -----------------------------
:: IQ Command Section
:: Usage: script.bat iq s1|s2|ob1|ob2
:: -----------------------------
if /i "!arg1!"=="iq" (
    set "base_dir=D:\project\MediaToolKit_IoTYocto_240522"

    if /i "!arg2!"=="s1" (
        echo [IQ:S1] Running setup...
        cd /d "!base_dir!"
        call 01_cct_setup.bat
        call 02_NDD_preview_8395.bat
    )

    if /i "!arg2!"=="s2" (
        echo [IQ:S2] Running install...
        cd /d "!base_dir!\svn\install"
        call 4.0.MTKToolCustom.bat
    )

    if /i "!arg2!"=="ob1" (
        echo [IQ:OB1] Init ISP7...
        cd /d "!base_dir!\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 01_init_ISP7_IoTYocto.bat
    )

    if /i "!arg2!"=="ob2" (
        echo [IQ:OB2] Dump raw...
        cd /d "!base_dir!\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 03_Dump_raw_minsatgain_ISP7_IoTYocto.bat
    )
)

endlocal

:: -----------------------------
:: STM Section (after endlocal)
:: -----------------------------
set "live_current=C:\Users\gray.lin\STM32CubeIDE\workspace_1.13.2\.metadata\.plugins\com.st.stm32cube.ide.mcu.livewatch\saved_expr.dat"
set "live_backup=D:\prj\STM\liveview\saved_expr_%4%.dat"

if /i "%1"=="stm" (
    if /i "%2"=="live" (
        if /i "%3"=="load" (
            echo [STM] Loading backup...
            copy "%live_backup%" "%live_current%"
        )

        if /i "%3"=="save" (
            echo [STM] Saving backup...
            copy "%live_current%" "%live_backup%"
        )
    )
)

:: -----------------------------
:: VSCode Section
:: -----------------------------
if /i "%1"=="code" (
    if /i "%2"=="stmlive" (
        echo [CODE] Opening saved_expr.dat in VSCode...
        code "C:\Users\gray.lin\STM32CubeIDE\workspace_1.13.2\.metadata\.plugins\com.st.stm32cube.ide.mcu.livewatch\saved_expr.dat"
    )
)
