[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop"
$host.ui.RawUI.WindowTitle = "SpiderHeck Mod Manager (Windows)"
$scriptPath =$MyInvocation.MyCommand.Path
$workDir = Split-Path -Parent$scriptPath
Set-Location -Path $workDir

$localVersion = "1.1.5"
$githubRawUrl = "https://raw.githubusercontent.com/coffynerd/Spidh/main"

$remoteVersion = ""
try {
    $remoteVersion = (Invoke-RestMethod -Uri "$githubRawUrl/version_win.txt" -TimeoutSec 3).Trim()
} catch { }

$updateAvailable = ($remoteVersion -ne "") -and ($remoteVersion -ne$localVersion)

function Show-Menu {
    Clear-Host
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "    SpiderHeck - InfiniteFriends Manager (Windows) " -ForegroundColor White
    Write-Host "    Wersja: $localVersion (System PowerShell)" -ForegroundColor DarkGray
    Write-Host "===================================================" -ForegroundColor Cyan
    
    if (Test-Path "winhttp.dll") {
        Write-Host "Status Moda: " -NoNewline; Write-Host "WLACZONY" -ForegroundColor Green
    } elseif (Test-Path "winhttp.dll.disabled") {
        Write-Host "Status Moda: " -NoNewline; Write-Host "WYLACZONY" -ForegroundColor Red
    } else {
        Write-Host "Status Moda: " -NoNewline; Write-Host "NIEZAINSTALOWANY" -ForegroundColor Yellow
    }
    Write-Host "===================================================" -ForegroundColor Cyan
    
    if ($updateAvailable) {
        Write-Host "0. [DOSTEPNA AKTUALIZACJA!] Zaktualizuj program do $remoteVersion" -ForegroundColor Green
    }
    
    Write-Host "1. Zainstaluj / Zaktualizuj modyfikacje"
    Write-Host "2. Wlacz / Wylacz moda"
    Write-Host "3. Uruchom gre"
    Write-Host "4. Dodaj bezpieczne skroty (Pulpit i Menu Start)"
    Write-Host "5. Narzedzia Parsec (Gra online)"
    Write-Host "6. Wyjscie"
    Write-Host "===================================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Wybierz opcje"
    
    switch ($choice) {         '0' { if ($updateAvailable) { Update-Script } else { Show-Menu } }
        '1' { Install-Mod }
        '2' { Toggle-Mod }
        '3' { Start-Process "steam://rungameid/1329500"; Show-Menu }
        '4' { Create-Shortcuts }
        '5' { Show-ParsecMenu }
        '6' { exit }
        default { Show-Menu }
    }
}

function Show-ParsecMenu {
    Clear-Host
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "                MENU PARSEC" -ForegroundColor White
    Write-Host "===================================================" -ForegroundColor Cyan
    Write-Host "1. Uruchom Parsec w przegladarce (Web Parsec)"
    Write-Host "2. Pobierz aplikacje Parsec"
    Write-Host "3. Instrukcja uzywania"
    Write-Host "4. Cofnij"
    Write-Host "===================================================" -ForegroundColor Cyan
    
    $pchoice = Read-Host "Wybierz opcje"
    switch ($pchoice) {
        '1' { Start-Process "https://web.parsec.app/"; Show-ParsecMenu }
        '2' { Start-Process "https://parsec.app/downloads"; Show-ParsecMenu }
        '3' { Show-ParsecInstructions }
        '4' { Show-Menu }
        default { Show-ParsecMenu }
    }
}

function Show-ParsecInstructions {
    Clear-Host
    Write-Host "--- JAK UZYWAC PARSEC DO GRY SPIDERHECK ---" -ForegroundColor Yellow
    Write-Host "1. HOST (Osoba u ktorej odpalona jest gra z modem):"
    Write-Host "   - Pobiera aplikacje, zaklada konto i loguje sie."
    Write-Host "   - W sekcji 'Friends' dodaje swoich znajomych."
    Write-Host "   - Uruchamia gre SpiderHeck."
    Write-Host ""
    Write-Host "2. ZNAJOMI (Goscie):"
    Write-Host "   - Moga uzyc wersji przegladarkowej (Web Parsec) lub aplikacji."
    Write-Host "   - Loguja sie na swoje konto i w sekcji 'Computers' klikaja 'Connect'"
    Write-Host "     przy komputerze Hosta."
    Write-Host ""
    Write-Host "3. UPRAWNIENIA:"
    Write-Host "   - Po dolaczeniu gosci, HOST klika ikonke Parsec i upewnia sie,"
    Write-Host "     ze goscie maja wlaczone uprawnienia TYLKO do 'Gamepad' (Kontroler)."
    Write-Host "   - Wylaczcie 'Keyboard' i 'Mouse', zeby goscie nie klikali po systemie!"
    Write-Host "-------------------------------------------" -ForegroundColor Yellow
    Read-Host "Nacisnij Enter, aby wrocic..."
    Show-ParsecMenu
}

function Update-Script {
    Write-Host "Pobieranie nowej wersji skryptu (PowerShell)..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "$githubRawUrl/SpiderHeck_ModManager.ps1" -OutFile "update.ps1"
        Copy-Item "update.ps1" -Destination $scriptPath -Force
        Remove-Item "update.ps1" -Force
        Write-Host "Aktualizacja zakonczona! Skrypt zostanie zrestartowany." -ForegroundColor Green
        Start-Sleep -Seconds 2
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
        exit
    } catch {
        Write-Host "Blad pobierania aktualizacji: $_" -ForegroundColor Red
        Read-Host "Nacisnij Enter, aby wrocic do menu..."
        Show-Menu
    }
}

function Install-Mod {
    Write-Host "Pobieranie narzedzia BepInEx 5.4.22..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip" -OutFile "bepinex.zip"
    Write-Host "Pobieranie moda InfiniteFriends..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/Senyksia/InfiniteFriends/releases/latest/download/InfiniteFriends_BepInEx.zip" -OutFile "mod.zip"

    Write-Host "Rozpakowywanie plikow..." -ForegroundColor Yellow
    Expand-Archive -Path "bepinex.zip" -DestinationPath "." -Force
    Expand-Archive -Path "mod.zip" -DestinationPath "." -Force

    Remove-Item "bepinex.zip" -ErrorAction SilentlyContinue
    Remove-Item "mod.zip" -ErrorAction SilentlyContinue

    if (Test-Path "winhttp.dll.disabled") {
        Rename-Item -Path "winhttp.dll.disabled" -NewName "winhttp.dll"
    }
    
    Write-Host "Instalacja zakonczona pomyslnie!" -ForegroundColor Green
    Read-Host "Nacisnij Enter, aby wrocic do menu..."
    Show-Menu
}

function Toggle-Mod {
    if (Test-Path "winhttp.dll") {
        Rename-Item -Path "winhttp.dll" -NewName "winhttp.dll.disabled"
        Write-Host "Mod zostal WYLACZONY." -ForegroundColor Yellow
    } elseif (Test-Path "winhttp.dll.disabled") {
        Rename-Item -Path "winhttp.dll.disabled" -NewName "winhttp.dll"
        Write-Host "Mod zostal WLACZONY." -ForegroundColor Green
    } else {
        Write-Host "Mod nie jest zainstalowany." -ForegroundColor Red
    }
    Read-Host "Nacisnij Enter, aby wrocic do menu..."
    Show-Menu
}

function Create-Shortcuts {
    Write-Host "Tworzenie bezposrednich skrotow do PowerShell..." -ForegroundColor Yellow
    $WshShell = New-Object -ComObject WScript.Shell
    
    $desktop = [Environment]::GetFolderPath('Desktop')$programs = [Environment]::GetFolderPath('Programs')

    # Skrot Pulpit
    $shortcut = $WshShell.CreateShortcut("$desktop\SpiderHeck Mod Manager.lnk")
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Normal -File `"$scriptPath`""
    $shortcut.WorkingDirectory = $workDir$shortcut.IconLocation = "powershell.exe,0"
    $shortcut.Save()

    # Skrot Menu Start
    $shortcut2 = $WshShell.CreateShortcut("$programs\SpiderHeck Mod Manager.lnk")
    $shortcut2.TargetPath = "powershell.exe"
    $shortcut2.Arguments = "-ExecutionPolicy Bypass -WindowStyle Normal -File `"$scriptPath`""
    $shortcut2.WorkingDirectory = $workDir$shortcut2.IconLocation = "powershell.exe,0"
    $shortcut2.Save()

    Write-Host "Skroty zostaly pomyslnie dodane!" -ForegroundColor Green
    Read-Host "Nacisnij Enter, aby wrocic do menu..."
    Show-Menu
}

Show-Menu
