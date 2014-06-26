rem this script will be called from provision-virtualbox-slave.bat
rem in an asynchronous way, because installation of VirtualBox drops
rem all network connections. An so a vagrant provision would hang.
rem As we also want to reboot the machine to have updated PATH in all
rem services this is a working workaround.

if "%ChocolateyInstall%x"=="x" set ChocolateyInstall=%SystemDrive%\Chocolatey
where cinst
if ERRORLEVEL 1 goto set_chocolatey
goto inst
:set_chocolatey
set PATH=%PATH%;%ChocolateyInstall%\bin
:inst

call cinst VirtualBox
where vboxmanage
if ERRORLEVEL 1 call :addVBoxToUserPath
goto VBOX_DONE
:addVBoxToUserPath
for /F "tokens=2* delims= " %%f IN ('reg query "HKCU\Environment" /v Path ^| findstr /i path') do set OLD_USER_PATH=%%g
reg add HKCU\Environment /v Path /d "%OLD_USER_PATH%;C:\Program Files\Oracle\VirtualBox" /f
set PATH=%PATH%;C:\Program Files\Oracle\VirtualBox
exit /b
:VBOX_DONE

rem Reboot to have all tools in PATH needed in jenkins slave
shutdown /r /t 5 /c "Reboot to update PATH slave"