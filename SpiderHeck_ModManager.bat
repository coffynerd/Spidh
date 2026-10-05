@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Aktualizacja SpiderHeck Mod Manager

echo ===================================================
echo    TRWA MIGRACJA DO NOWEJ WERSJI (PowerShell)
echo ===================================================
echo.
echo Pobieranie nowego, stabilniejszego systemu w tle...

set "GITHUB_RAW_URL=https://raw.githubusercontent.com/coffynerd/Spidh/main"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GITHUB_RAW_URL%/SpiderHeck_ModManager.ps1' -OutFile 'SpiderHeck_ModManager.ps1'"

echo Tworzenie nowych skrotow systemowych...
set "PS1_PATH=%~dp0SpiderHeck_ModManager.ps1"
set "VBS_FILE=%temp%\MakeShortcutPS.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%VBS_FILE%"
echo sLinkFile = oWS.SpecialFolders("Desktop") ^& "\SpiderHeck Mod Manager.lnk" >> "%VBS_FILE%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%VBS_FILE%"
echo oLink.TargetPath = "powershell.exe" >> "%VBS_FILE%"
echo oLink.Arguments = "-ExecutionPolicy Bypass -File """ ^& "%PS1_PATH%" ^& """" >> "%VBS_FILE%"
echo oLink.WorkingDirectory = "%~dp0" >> "%VBS_FILE%"
echo oLink.IconLocation = "powershell.exe,0" >> "%VBS_FILE%"
echo oLink.Save >> "%VBS_FILE%"

echo sLinkFile2 = oWS.SpecialFolders("Programs") ^& "\SpiderHeck Mod Manager.lnk" >> "%VBS_FILE%"
echo Set oLink2 = oWS.CreateShortcut(sLinkFile2) >> "%VBS_FILE%"
echo oLink2.TargetPath = "powershell.exe" >> "%VBS_FILE%"
echo oLink2.Arguments = "-ExecutionPolicy Bypass -File """ ^& "%PS1_PATH%" ^& """" >> "%VBS_FILE%"
echo oLink2.WorkingDirectory = "%~dp0" >> "%VBS_FILE%"
echo oLink2.IconLocation = "powershell.exe,0" >> "%VBS_FILE%"
echo oLink2.Save >> "%VBS_FILE%"

cscript //nologo "%VBS_FILE%" >nul 2>&1
del "%VBS_FILE%" >nul 2>&1

echo.
echo ===================================================
echo [32mMIGRACJA ZAKONCZONA POMYSLNIE![0m
echo ===================================================
echo Od teraz stary plik .bat przestaje byc uzywany.
echo Program zostal trwale przeniesiony do PowerShell.
echo.
echo Za chwile otworzy sie nowa wersja menedzera...
timeout /t 5 >nul

start "" "%USERPROFILE%\Desktop\SpiderHeck Mod Manager.lnk"
del "%~nx0" & exit
