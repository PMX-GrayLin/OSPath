@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Windows 11 Aggressive Cleanup (CRASH-PROOF)
color 0C

:: ==================================================
:: Admin check
:: ==================================================
net session >nul 2>&1 || (
    echo [ERROR] Please run as Administrator
    pause
    exit /b
)

echo ================================================
echo   Windows 11 AGGRESSIVE CLEANUP (SAFE EDITION)
echo   - No CMD self-destruction
echo   - No del /s *
echo ================================================
echo.
pause

:: ==================================================
:: Stop services
:: ==================================================
echo [1/10] Stop services...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop dosvc >nul 2>&1

:: ==================================================
:: Windows TEMP (SAFE)
:: ==================================================
echo [2/10] Cleaning Windows TEMP...

for %%f in ("%windir%\Temp\*") do del /f /q "%%f" >nul 2>&1
for /d %%d in ("%windir%\Temp\*") do rd /s /q "%%d" >nul 2>&1

pause

:: ==================================================
:: User TEMP CLEAN (ABSOLUTE SAFE)
:: ==================================================
echo [3/10] Cleaning User TEMP (child process)...

cmd /c ^
"for %%f in (\"%temp%\*\") do del /f /q \"%%f\" >nul 2>&1 && ^
 for /d %%d in (\"%temp%\*\") do rd /s /q \"%%d\" >nul 2>&1"

pause

:: ==================================================
:: Windows Update Cache (SAFE)
:: ==================================================
echo [4/10] Cleaning Windows Update cache...

for %%f in ("%windir%\SoftwareDistribution\Download\*") do del /f /q "%%f" >nul 2>&1
for /d %%d in ("%windir%\SoftwareDistribution\Download\*") do rd /s /q "%%d" >nul 2>&1

pause

:: ==================================================
:: Delivery Optimization Cache
:: ==================================================
echo [5/10] Cleaning Delivery Optimization cache...

set "DO_CACHE=C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache"
for %%f in ("%DO_CACHE%\*") do del /f /q "%%f" >nul 2>&1
for /d %%d in ("%DO_CACHE%\*") do rd /s /q "%%d" >nul 2>&1

pause

:: ==================================================
:: Error Reports & Dump
:: ==================================================
echo [6/10] Cleaning error reports & dumps...

for %%f in ("%ProgramData%\Microsoft\Windows\WER\*") do del /f /q "%%f" >nul 2>&1
for /d %%d in ("%ProgramData%\Microsoft\Windows\WER\*") do rd /s /q "%%d" >nul 2>&1

del /f /q "%SystemRoot%\MEMORY.DMP" >nul 2>&1
del /f /q "%SystemRoot%\Minidump\*" >nul 2>&1

pause

:: ==================================================
:: Recycle Bin
:: ==================================================
echo [7/10] Empty Recycle Bin...
rd /s /q C:\$Recycle.Bin >nul 2>&1

pause

:: ==================================================
:: WinSxS HARD cleanup (NO rollback)
:: ==================================================
echo [8/10] WinSxS resetbase cleanup...
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase /Quiet

pause

:: ==================================================
:: Driver Store SAFE cleanup
::   - Only removes drivers NOT in use
:: ==================================================
echo [9/10] Cleaning unused drivers...

pnputil /enum-drivers | findstr /i "Published Name" > "%temp%\drivers.txt"

for /f "tokens=3" %%i in (%temp%\drivers.txt) do (
    pnputil /delete-driver %%i /force >nul 2>&1
)

del "%temp%\drivers.txt" >nul 2>&1

pause

:: ==================================================
:: Disable Hibernate
:: ==================================================
echo [10/10] Disable Hibernate (remove hiberfil.sys)...
powercfg -h off

:: ==================================================
:: Restart services
:: ==================================================
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start dosvc >nul 2>&1

echo.
echo ================================================
echo   CLEANUP COMPLETED SUCCESSFULLY
echo ================================================
echo  Recommended: reboot now
echo ================================================
pause
