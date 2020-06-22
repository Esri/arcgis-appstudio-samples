@echo off

setlocal

set APP_NAME=MapViewer
set LANGUAGES_FOLDER=%APP_NAME%\languages
call :main
goto :eof

:set_lreleasedir_appstudio
set APPSTUDIODIR=%USERPROFILE%\Applications\ArcGIS\AppStudio
if not exist %APPSTUDIODIR% goto :eof
if not exist %APPSTUDIODIR%\bin\lrelease.exe goto :eof
set LRELEASEDIR=%APPSTUDIODIR%\bin
set PATH=%LRELEASEDIR%;%PATH%
goto :eof

:set_lreleasedir_qt
for /f %%a in ('dir /s /b C:\Qt\msvc2017_64') do set LRELEASEDIR=%%a\bin
if "%LRELEASEDIR%" == "" goto :eof
set PATH=%LRELEASEDIR%;%PATH%
goto :eof

:set_lreleasedir
set LRELEASEDIR=
call :set_lreleasedir_appstudio
if "%LRELEASEDIR%" == "" call :set_lreleasedir_qt
if not "%LRELEASEDIR%" == "" goto :eof
rem echo Cannot locate lrelease.exe
exit /b 1
goto :eof

:set_workdir
for /f %%a in ("%~dp0\..\..") do set WORKDIR=%%~dfa
echo %WORKDIR%
goto :eof

:run_lrelease
if "%1" == "%APP_NAME%.ts" goto :eof
lrelease "%WORKDIR%\%LANGUAGES_FOLDER%\%1"
set status=%errorlevel%
if "%status%" == "0" goto :eof
set /a errors+=1
set exit_status=%status%
goto :eof

:main
set errors=0
set exit_status=0
call :set_workdir
call :set_lreleasedir
lupdate "%WORKDIR%" -extensions qml -ts %WORKDIR%\%LANGUAGES_FOLDER%\%APP_NAME%.ts
lupdate "%WORKDIR%" -extensions qml -ts pluralonly -ts %WORKDIR%\%LANGUAGES_FOLDER%\%APP_NAME%_en.ts
for /f %%f in ('dir /b %WORKDIR%\%LANGUAGES_FOLDER%\*.ts') do call :run_lrelease %%f
if "%exit_status%" == "0" goto :eof
echo Exiting with %errors% errors
exit /b %exit_status%
goto :eof

