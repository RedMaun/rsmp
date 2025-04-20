@echo off
setlocal EnableDelayedExpansion

set "script_url=https://github.com/RedMaun/rsmp/releases/latest/download/index.js"
set "package_url=https://github.com/RedMaun/rsmp/releases/latest/download/package.json"
set "update_url=https://api.github.com/repos/Redmaun/rsmp/releases/latest"
set "ver_file=ver.txt"
set "tmp_file=remote_update.txt"
cd /d "%~dp0"

powershell -Command "Invoke-WebRequest -Uri '%update_url%' -OutFile '%tmp_file%'"

@echo off
for /f "delims=" %%A in ('powershell -NoLogo -Command ^
    "(Get-Content %tmp_file% -Raw | ConvertFrom-Json).name"') do (
    set "RELEASE_NAME=%%A"
)

del %tmp_file%

set /p local_date=<%ver_file%

if "%local_date%"=="%RELEASE_NAME%" (
    node index.js
    exit /b
)

echo update detected, downloading...
powershell -Command "Invoke-WebRequest -Uri '%script_url%' -OutFile 'index.js'"
powershell -Command "Invoke-WebRequest -Uri '%package_url%' -OutFile 'package.json'"
REM echo %RELEASE_NAME%>%ver_file%
start cmd /c "npm i"
node .
pause
