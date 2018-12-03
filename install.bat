@ECHO OFF

SET INSTALL_LOG_FILE=metanorma_install.log

ECHO Installation start %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

bitsadmin /transfer get ^
	https://raw.githubusercontent.com/riboseinc/metanorma-windows-setup/master/packages.config ^
	%CD%\packages.config >> %INSTALL_LOG_FILE% 2>&1

WHERE choco >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Installing chocolatey...
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass ^
		-Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
			&& SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >> %INSTALL_LOG_FILE% 2>&1
)

ECHO Installing choco packages...
cinst packages.config -y >> %INSTALL_LOG_FILE% 2>&1
CALL refreshenv >> %INSTALL_LOG_FILE% 2>&1

WHERE java >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Installing JRE...
	cinst javaruntime -y >> %INSTALL_LOG_FILE% 2>&1
)

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

ECHO - Please be aknowledged about docker-machine sharing restrictions on windows https://github.com/docker/machine/issues/4424#issuecomment-377727985

docker-machine inspect default >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO - There is no default machine for docker please proceed with creation https://docs.docker.com/machine/reference/create/

ECHO Installing gems...

ECHO @ECHO OFF > %ChocolateyInstall%\bin\xml2-config.bat
ECHO @ECHO OFF > %ChocolateyInstall%\bin\xslt-config.bat
SET XSLT_INCLUDE=%ChocolateyInstall%\lib\xsltproc\dist\include
SET XSLT_LIB_DIR=%ChocolateyInstall%\lib\xsltproc\dist\lib
SET RUBY_BIN=c:\tools\ruby25\bin

CALL %RUBY_BIN%\gem install bundler metanorma-cli -- ^
	--with-xml2-include=%XSLT_INCLUDE%\libxml2 ^
	--with-xslt-include=%XSLT_INCLUDE% ^
	--with-xml2-lib=%XSLT_LIB_DIR% ^
	--with-xslt-lib=%XSLT_LIB_DIR% >> %INSTALL_LOG_FILE% 2>&1
SETX /M RUBY_DLL_PATH "%ChocolateyInstall%\lib\xsltproc\dist\bin;%RUBY_DLL_PATH%" >> %INSTALL_LOG_FILE% 2>&1
CALL refreshenv >> %INSTALL_LOG_FILE% 2>&1

:: Copy with removing version from filename (need because xslt_lib.so expect such names)
XCOPY /Y %ChocolateyInstall%\lib\xsltproc\dist\bin\libxml2*.dll %ChocolateyInstall%\lib\xsltproc\dist\bin\libxml2.dll* >> %INSTALL_LOG_FILE% 2>&1
XCOPY /Y %ChocolateyInstall%\lib\xsltproc\dist\bin\libxslt*.dll %ChocolateyInstall%\lib\xsltproc\dist\bin\libxslt.dll* >> %INSTALL_LOG_FILE% 2>&1
XCOPY /Y %ChocolateyInstall%\lib\xsltproc\dist\bin\libexslt*.dll %ChocolateyInstall%\lib\xsltproc\dist\bin\libexslt.dll* >> %INSTALL_LOG_FILE% 2>&1

ECHO List applications... >> %INSTALL_LOG_FILE% 2>&1
WHERE ruby gem bundle java docker >> %INSTALL_LOG_FILE% 2>&1

CALL metanorma --help >> %INSTALL_LOG_FILE% 2>&1

ECHO Installation finished %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

ECHO Done!