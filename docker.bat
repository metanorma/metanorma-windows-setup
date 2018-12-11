@ECHO OFF

SET INSTALL_LOG_FILE=metanorma_install.log

ECHO Installation metanorma (docker) started %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

IF "%APPVEYOR_REPO_COMMIT%"=="" SET APPVEYOR_REPO_COMMIT=master

bitsadmin /transfer get ^
	https://raw.githubusercontent.com/riboseinc/metanorma-windows-setup/%APPVEYOR_REPO_COMMIT%/docker.config ^
	%CD%\docker.config >> %INSTALL_LOG_FILE% 2>&1

WHERE choco >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Installing chocolatey...
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass ^
		-Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
			&& SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >> %INSTALL_LOG_FILE% 2>&1
)

ECHO Installing choco packages...
cinst docker.config -y >> %INSTALL_LOG_FILE% 2>&1
CALL refreshenv >> %INSTALL_LOG_FILE% 2>&1

WHERE docker >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Installing Docker For Windows...
	cinst docker-for-windows -y >> %INSTALL_LOG_FILE% 2>&1

	:: docker-for-windows availavle only on Enterprise & Pro version so fallback if it doesn't work
	IF %ERRORLEVEL% NEQ 0 (
		ECHO "Installing Docker For Windows failed. Fallback to docker & docker-machine..."
		cinst docker -y >> %INSTALL_LOG_FILE% 2>&1
	)

	CALL refreshenv >> %INSTALL_LOG_FILE% 2>&1
) ELSE (
	ECHO Docker already installed
)

WHERE docker-machine >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 cinst docker-machine -y >> %INSTALL_LOG_FILE% 2>&1

CALL refreshenv >> %INSTALL_LOG_FILE% 2>&1

ECHO - Please be aware about docker-machine sharing restrictions on Windows https://github.com/docker/machine/issues/4424#issuecomment-377727985

docker-machine inspect default >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO - There is no default machine for Docker, please proceed with creation https://docs.docker.com/machine/reference/create/

ECHO Installation metanorma (docker) finished %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

ECHO Done!