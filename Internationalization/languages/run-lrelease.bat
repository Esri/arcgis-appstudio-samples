@echo off

rem The lrelease tool produces qm files from ts files

FOR /F %%A in ('DIR /B *.TS') DO %USERPROFILE%\Applications\ArcGIS\AppStudio\bin\lrelease.exe %%A

pause
