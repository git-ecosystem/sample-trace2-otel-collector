@ECHO OFF

FOR /F "usebackq" %%i IN (`go env GOOS`) DO (SET GOOS=%%i)
FOR /F "usebackq" %%i IN (`go env GOARCH`) DO (SET GOARCH=%%i)

FOR /F "usebackq tokens=2" %%i IN (`go list -m github.com/git-ecosystem/trace2receiver`) DO (SET VER=%%i)
SET "NVER=%VER:v=%

SET DISTNAME=sample-trace2-otel-collector_%NVER%_%GOOS%_%GOARCH%
SET DISTPATH=.\_out_\%DISTNAME%

ECHO ======== Creating Layout ========
ECHO GOOS     is %GOOS%
ECHO GOARCH   is %GOARCH%
ECHO VER      is %VER%
ECHO NVER     is %NVER%
ECHO DISTNAME is %DISTNAME%

IF EXIST _out_ (RMDIR /Q /S _out_ || (ECHO Could not delete previous _out_ directory & EXIT /B 1))

@ECHO ON
MKDIR _out_
MKDIR %DISTPATH%

XCOPY /Q ..\..\sample-trace2-otel-collector.exe %DISTPATH%\

powershell.exe -Command "(Get-Content install.bat_template).replace('X_VER_X','%VER%')    | Set-Content %DISTPATH%\install.bat"
powershell.exe -Command "(Get-Content register.bat_template).replace('X_VER_X','%VER%')   | Set-Content %DISTPATH%\register.bat"
powershell.exe -Command "(Get-Content unregister.bat_template).replace('X_VER_X','%VER%') | Set-Content %DISTPATH%\unregister.bat"

XCOPY /Q ..\..\sample-configs\windows\*.yml %DISTPATH%\

@ECHO ======== Creating ZIP Package ========

powershell.exe -Command "Set-Location _out_; Compress-Archive -DestinationPath .\%DISTNAME%.zip -Path %DISTNAME%" || (ECHO Could not create ZIPFILE & EXIT /B 1)

@ECHO ======== ZIP Package Created ========
@ECHO ZIPFILE created .\_out_\%DISTNAME%.zip



