@echo off

cd %~dp0

set arg1=%1
set arg2=%2
set arg3=%3
set arg4=%4
set arg5=%5
echo %arg1%
echo %arg2%
echo %arg3%
echo %arg4%
echo %arg5%

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

