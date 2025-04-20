@echo off
setlocal

:: Define version and architecture (adjust as needed)
set NODE_VERSION=20.11.1
set ARCH=x64
set NODE_URL=https://nodejs.org/dist/v%NODE_VERSION%/node-v%NODE_VERSION%-%ARCH%.msi
set INSTALLER=node.msi
set NODE_PATH="C:\Program Files\nodejs\node.exe"

set "FOLDER=%USERPROFILE%\rsmp"
set "SCRIPT=%USERPROFILE%\rsmp\start.bat"

if not exist "%FOLDER%" (
    mkdir "%FOLDER%"
)

set "script_url=https://github.com/RedMaun/rsmp/releases/latest/download/start.bat"

if exist %NODE_PATH% (
    powershell -Command "Invoke-WebRequest -Uri '%script_url%' -OutFile '%SCRIPT%'"

@echo off
cd %USERPROFILE%\rsmp
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%userprofile%\Desktop\RSMP.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%USERPROFILE%\rsmp\start.bat" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%USERPROFILE%\rsmp" >> CreateShortcut.vbs
echo oLink.Description = "Minecraft server" >> CreateShortcut.vbs
echo oLink.IconLocation = "%APPDATA%\.tlauncher\legacy\Minecraft\TL.exe" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs

    %SCRIPT%
    exit /b
	
) else (

echo Downloading Node.js %NODE_VERSION% installer...
powershell -Command "Invoke-WebRequest -Uri '%NODE_URL%' -OutFile '%INSTALLER%'"

if exist %INSTALLER% (
    echo Running Node.js installer...
    msiexec /i %INSTALLER% /norestart

    del %INSTALLER%

    echo Node.js installation complete.
    powershell -Command "Invoke-WebRequest -Uri '%script_url%' -OutFile '%SCRIPT%'"

@echo off
cd %USERPROFILE%\rsmp
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%userprofile%\Desktop\RSMP.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%USERPROFILE%\rsmp\start.bat" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%USERPROFILE%\rsmp" >> CreateShortcut.vbs
echo oLink.Description = "Minecraft server" >> CreateShortcut.vbs
echo oLink.IconLocation = "%APPDATA%\.tlauncher\legacy\Minecraft\TL.exe" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs
     
))
pause
