@ECHO OFF

SET INSTALL_LOG_FILE=metanorma_install.log

ECHO Installation metanorma (local) started %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

WHERE choco >> %INSTALL_LOG_FILE% 2>&1
IF %ERRORLEVEL% NEQ 0 (
	ECHO Installing chocolatey...
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass ^
		-Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
			&& SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >> %INSTALL_LOG_FILE% 2>&1
)

ECHO Installing metanorma package...
cinst metanorma -y >> %INSTALL_LOG_FILE% 2>&1
CALL refreshenv >> %INSTALL_LOG_FILE% 2>&1

CALL metanorma --help >> %INSTALL_LOG_FILE% 2>&1

ECHO Installation metanorma (local) finished %DATE% %TIME% >> %INSTALL_LOG_FILE% 2>&1

ECHO Done!
