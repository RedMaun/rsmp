@echo off
setlocal EnableDelayedExpansion

REM === Urls ===
set "update_url=https://api.github.com/repos/Redmaun/rsmp/releases/latest"
set "zip_url=https://github.com/RedMaun/rsmp/releases/latest/download/game.zip"
REM === Files ===
set "zip_name=game.zip"
set "tmp_file=remote_update.txt"
set "ver_file=ver.txt"
REM === Local paths ===
set "mods_dir=%APPDATA%\.tlauncher\legacy\Minecraft\game\mods"
set "game_dir=%APPDATA%\.tlauncher\legacy\Minecraft\game"
set "launcher_exe=%APPDATA%\.tlauncher\legacy\Minecraft\TL.exe"

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
    start "" "%launcher_exe%"
    exit /b
)

echo update detected, downloading archive...
powershell -Command "Invoke-WebRequest -Uri '%zip_url%' -OutFile '%zip_name%'"

if exist "%mods_dir%" (
    rmdir /S /Q "%mods_dir%"
)
mkdir "%mods_dir%"

powershell -Command "Expand-Archive -Path '%zip_name%' -DestinationPath '%game_dir%' -Force"

echo %RELEASE_NAME% > %ver_file%

start "" "%launcher_exe%"