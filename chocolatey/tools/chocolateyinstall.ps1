New-Item -ItemType file $Env:ChocolateyInstall\\bin\\xml2-config.bat
New-Item -ItemType file $Env:ChocolateyInstall\\bin\\xslt-config.bat

New-Variable -Name XsltDist -Value $Env:ChocolateyInstall\\lib\\xsltproc\\dist
New-Variable -Name XsltInclude -Value $XsltDist\\include
New-Variable -Name XsltLib -Value $XsltDist\\lib

New-Variable -Name RubyBin -Value c:\\tools\\ruby25\\bin

$Env:RubyBin\\gem install bundler metanorma-cli -- `
  --with-xml2-include=$Env:XsltInclude\\libxml2 `
  --with-xslt-include=$Env:XsltInclude `
  --with-xml2-lib=$Env:XsltLib `
  --with-xslt-lib=$Env:XsltLib
SETX /M RUBY_DLL_PATH "$Env:ChocolateyInstall\\lib\\xsltproc\\dist\\bin;%RUBY_DLL_PATH%"
refreshenv

# Copy with removing version from filename (need because xslt_lib.so expect such names)
Copy-Item $Env:ChocolateyInstall\\lib\\xsltproc\\dist\\bin\libxml2*.dll $Env:ChocolateyInstall\\lib\\xsltproc\\dist\\bin\\libxml2.dll -force
Copy-Item $Env:ChocolateyInstall\\lib\\xsltproc\\dist\bin\libxslt*.dll $Env:ChocolateyInstall\lib\xsltproc\dist\bin\libxslt.dll* >> %INSTALL_LOG_FILE% 2>&1
XCOPY /Y $Env:ChocolateyInstall\lib\xsltproc\dist\bin\libexslt*.dll $Env:ChocolateyInstall\lib\xsltproc\dist\bin\libexslt.dll* >> %INSTALL_LOG_FILE% 2>&1

ECHO List applications... >> %INSTALL_LOG_FILE% 2>&1
WHERE ruby gem bundle java docker >> %INSTALL_LOG_FILE% 2>&1
