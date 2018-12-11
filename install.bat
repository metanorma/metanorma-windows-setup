@ECHO OFF

SET INSTALL_LOG_FILE=metanorma_install.log

ECHO Installation metanorma (local) started %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

IF "%APPVEYOR_REPO_COMMIT%"=="" SET APPVEYOR_REPO_COMMIT=master

bitsadmin /transfer get ^
	https://raw.githubusercontent.com/riboseinc/metanorma-windows-setup/%APPVEYOR_REPO_COMMIT%/install.config ^
	%CD%\install.config >> %INSTALL_LOG_FILE% 2>&1

WHERE choco >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Installing chocolatey...
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass ^
		-Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
			&& SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >> %INSTALL_LOG_FILE% 2>&1
)

ECHO Installing choco packages...
cinst install.config -y >> %INSTALL_LOG_FILE% 2>&1
CALL refreshenv >> %INSTALL_LOG_FILE% 2>&1

ECHO Installing puppeteer...
CALL npm i -g puppeteer >> %INSTALL_LOG_FILE% 2>&1

WHERE java >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Installing JRE...
	cinst javaruntime -y >> %INSTALL_LOG_FILE% 2>&1
)

ECHO Installing gems...

ECHO @ECHO OFF > %ChocolateyInstall%\bin\xml2-config.bat
ECHO @ECHO OFF > %ChocolateyInstall%\bin\xslt-config.bat

SET XSLT_INCLUDE=%ChocolateyInstall%\lib\xsltproc\dist\include
SET XSLT_LIB_DIR=%ChocolateyInstall%\lib\xsltproc\dist\lib
SET RUBY_BIN=c:\tools\ruby25\bin

CALL %RUBY_BIN%\gem install bundler >> %INSTALL_LOG_FILE% 2>&1
CALL %RUBY_BIN%\gem install metanorma-cli -- ^
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

ECHO Installation metanorma (local) finished %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

ECHO Done!
