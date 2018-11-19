@ECHO OFF

:: download chocolately packages config
bitsadmin /transfer get ^
	https://raw.githubusercontent.com/CAMOBAP795/metanorma-windows-setup/master/packages.config ^
	%CD%\packages.config

:: Check if cocolately installed & install if it missing
:: Official installation guide https://chocolatey.org/docs/installation
WHERE choco
IF %ERRORLEVEL% NEQ 0 @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: Install packages
choco install packages.config -y
CALL refreshenv

:: Create "default" machine if it doesn't exists
%ChocolateyInstall%\bin\docker-machine inspect default > NUL
IF %ERRORLEVEL% NEQ 0 echo There is no default machine for docker please proceed with creation https://docs.docker.com/machine/reference/create/