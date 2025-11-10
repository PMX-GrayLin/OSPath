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

    if /i "!arg2!"=="init" (
        echo Running init batch...
        cd /d "!base_dir!"
        call 01_cct_setup.bat
        call 02_NDD_preview_8395.bat
        echo to Run video streaming device...
    )

    if /i "!arg2!"=="rui" (
        echo Running ui...
        cd /d "!base_dir!\svn\install"
        call 4.0.MTKToolCustom.bat
    )

    if /i "!arg2!"=="drinit" (
        echo Dump raw init...
        cd /d "!base_dir!\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 01_init_ISP7_IoTYocto.bat
        echo to Run video streaming device...
    )

    if /i "!arg2!"=="drob" (
        echo Dump raw ob...
        cd /d "!base_dir!\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 03_Dump_raw_ob_ISP7_IoTYocto.bat
    )
    if /i "!arg2!"=="driso" (
        echo Dump raw iso...
        cd /d "!base_dir!\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 03_Dump_raw_miniso_ISP7_IoTYocto.bat
    )
    if /i "!arg2!"=="drsat" (
        echo Dump raw saturation...
        cd /d "!base_dir!\svn\install\DataSet\CamCaliTool\SensorCalibrationDumpRaw"
        call 03_Dump_raw_minsatgain_ISP7_IoTYocto.bat
    )

    if /i "!arg2!"=="2raw" (
        echo [IQ:OB2] convert packed_word to raw...
        cd /d "!base_dir!\Packedword2Raw_IoT_v250307
        python BatchRun.py
    )

    if /i "!arg2!"=="ftp" (
        echo Preparing to upload DB to FTP...
        cd /d "!base_dir!\svn\install\DataSet\SQLiteModule"

        echo Zipping db folder...
        powershell -Command "Compress-Archive -Path 'db' -DestinationPath 'db_new.zip' -Force"

        echo Uploading db_new.zip to FTP server...
        > "%temp%\ftp_commands.txt" (
            echo open 10.1.13.207
            echo gray.lin
            echo Zx03310331
            echo binary
            echo cd /Public/gray/aicamera/IQ_DB/
            echo put db_new.zip
            echo bye
        )

        ftp -s:"%temp%\ftp_commands.txt"
        del "%temp%\ftp_commands.txt"

        echo Upload complete.
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
