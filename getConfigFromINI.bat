@echo off 
REM Read an .ini configuration file given as parameter (%1)
REM
REM example of .ini content:
REM [section]
REM option=value
REM

for /f "tokens=1,2 delims==" %%a in (%1) do (
	if %%a==psConsoleFile set psConsoleFile=%%b
	if %%a==installPath set installPath=%%b
	if %%a==credsDir set credsDir=%%b
	if %%a==logsDir set logsDir=%%b
	if %%a==getStatusListFile set getStatusListFile=%%b
	if %%a==sendReportsFile set sendReportsFile=%%b
)

echo %psConsoleFile%
echo %installPath%
echo %credsDir%
echo %logsDir%
echo %getStatusListFile%
echo %sendReportsFile%
