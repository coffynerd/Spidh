@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
title SpiderHeck Mod Manager

:: === KONFIGURACJA =======================================
set LOCAL_VERSION=1.1
set GITHUB_RAW_URL=https://raw.githubusercontent.com/coffynerd/Spidh/main
:: ========================================================

:: Sprawdzanie aktualizacji
set REMOTE_VERSION=
for /f "delims=" %%I in ('powershell -Command "$ProgressPreference = 'SilentlyContinue'; try { (Invoke-RestMethod -Uri '%GITHUB_RAW_URL%/version_win.txt' -TimeoutSec 3).Trim() } catch { '' }" 2^>nul') do set "REMOTE_VERSION=%%I"

set UPDATE_AVAILABLE=false
if not "%REMOTE_VERSION%"=="" if not "%REMOTE_VERSION%"=="%LOCAL_VERSION%" (
    set UPDATE_AVAILABLE=true
)

:menu
cls
echo ===================================================
echo    SpiderHeck - InfiniteFriends Manager (Windows)
echo    Wersja: %LOCAL_VERSION%
echo ===================================================
if exist "winhttp.dll" (
    echo Status Moda: [32mWLACZONY[0m
) else if exist "winhttp.dll.disabled" (
    echo Status Moda: [31mWYLACZONY[0m
) else (
    echo Status Moda: [33mNIEZAINSTALOWANY[0m
)
echo ===================================================
if "%UPDATE_AVAILABLE%"=="true" (
    echo [32m0. [DOSTEPNA AKTUALIZACJA!] Zaktualizuj program do %REMOTE_VERSION%[0m
)
echo 1. Zainstaluj / Zaktualizuj modyfikacje
echo 2. Wlacz / Wylacz moda
echo 3. Uruchom gre
echo 4. Dodaj skrot na Pulpit i do Menu Start
echo 5. Narzedzia Parsec (Gra online)
echo 6. Wyjscie
echo ===================================================
set "choice="
set /p choice="Wybierz opcje: "

if "%choice%"=="0" if "%UPDATE_AVAILABLE%"=="true" goto update_script
if "%choice%"=="1" goto install
if "%choice%"=="2" goto toggle
if "%choice%"=="3" goto play
if "%choice%"=="4" goto shortcut
if "%choice%"=="5" goto parsec_menu
if "%choice%"=="6" exit
goto menu

:parsec_menu
cls
echo ===================================================
echo                MENU PARSEC
echo ===================================================
echo 1. Uruchom Parsec w przegladarce (Web Parsec)
echo 2. Pobierz aplikacje Parsec
echo 3. Instrukcja uzywania
echo 4. Cofnij
echo ===================================================
set "pchoice="
set /p pchoice="Wybierz opcje: "

if "%pchoice%"=="1" (
    start https://web.parsec.app/
    goto parsec_menu
)
if "%pchoice%"=="2" (
    start https://parsec.app/downloads
    goto parsec_menu
)
if "%pchoice%"=="3" goto parsec_instructions
if "%pchoice%"=="4" goto menu
goto parsec_menu

:parsec_instructions
cls
echo --- JAK UZYWAC PARSEC DO GRY SPIDERHECK ---
echo 1. HOST (Osoba u ktorej odpalona jest gra z modem):
echo    - Pobiera aplikacje, zaklada konto i loguje sie.
echo    - W sekcji 'Friends' dodaje swoich znajomych.
echo    - Uruchamia gre SpiderHeck.
echo.
echo 2. ZNAJOMI (Goscie):
echo    - Moga uzyc wersji przegladarkowej (Web Parsec) lub aplikacji.
echo    - Loguja sie na swoje konto i w sekcji 'Computers' klikaja 'Connect'
echo      przy komputerze Hosta.
echo.
echo 3. UPRAWNIENIA:
echo    - Po dolaczeniu gosci, HOST klika ikonke Parsec i upewnia sie,
echo      ze goscie maja wlaczone uprawnienia TYLKO do 'Gamepad' (Kontroler).
echo    - Wylaczcie 'Keyboard' i 'Mouse', zeby goscie nie klikali po systemie!
echo -------------------------------------------
pause
goto parsec_menu

:update_script
echo Pobieranie nowej wersji skryptu...
powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%GITHUB_RAW_URL%/SpiderHeck_ModManager.bat' -OutFile 'update.bat'"
if exist "update.bat" (
    copy /y update.bat "%~nx0" >nul
    del update.bat
    echo [32mAktualizacja zakonczona![0m Skrypt zostanie zrestartowany.
    timeout /t 2 >nul
    start "" "%~nx0"
    exit
) else (
    echo Blad pobierania aktualizacji.
    pause
    goto menu
)

:install
echo Pobieranie BepInEx 5.4.22...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip' -OutFile 'bepinex.zip'"
echo Pobieranie InfiniteFriends...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/Senyksia/InfiniteFriends/releases/latest/download/InfiniteFriends_BepInEx.zip' -OutFile 'mod.zip'"

echo Rozpakowywanie...
powershell -Command "Expand-Archive -Path 'bepinex.zip' -DestinationPath '.' -Force"
powershell -Command "Expand-Archive -Path 'mod.zip' -DestinationPath '.' -Force"

del bepinex.zip >nul 2>&1
del mod.zip >nul 2>&1

if exist "winhttp.dll.disabled" ren winhttp.dll.disabled winhttp.dll
echo Instalacja zakonczona!
pause
goto menu

:toggle
if exist "winhttp.dll" (
    ren winhttp.dll winhttp.dll.disabled
    echo Mod zostal WYLACZONY.
) else if exist "winhttp.dll.disabled" (
    ren winhttp.dll.disabled winhttp.dll
    echo Mod zostal WLACZONY.
)
pause
goto menu

:play
start steam://rungameid/1329500
goto menu

:shortcut
echo Tworzenie skrotow...
set "SCRIPT_PATH=%~dpnx0"
set "WORK_DIR=%~dp0"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $s1 = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\SpiderHeck Mod Manager.lnk'); $s1.TargetPath = '%SCRIPT_PATH%'; $s1.WorkingDirectory = '%WORK_DIR%'; $s1.Save(); $s2 = $WshShell.CreateShortcut([Environment]::GetFolderPath('Programs') + '\SpiderHeck Mod Manager.lnk'); $s2.TargetPath = '%SCRIPT_PATH%'; $s2.WorkingDirectory = '%WORK_DIR%'; $s2.Save()"
echo Skroty dodane na Pulpit oraz do Menu Start!
pause
goto menu
