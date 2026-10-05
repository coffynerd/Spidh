#!/bin/bash
cd "$(dirname "$0")"

# === KONFIGURACJA =======================================
LOCAL_VERSION="1.0"
# TUTAJ WKLEJ LINK DO FOLDERU RAW NA GITHUBIE (bez ukośnika na końcu):
GITHUB_RAW_URL="https://raw.githubusercontent.com/coffynerd/Spidh/main"
# ========================================================

# Sprawdzanie aktualizacji w tle (timeout 3 sekundy, żeby nie blokować jak nie ma neta)
REMOTE_VERSION=$(curl -s --max-time 3 "$GITHUB_RAW_URL/version_linux.txt" | tr -d '\r' | xargs)
UPDATE_AVAILABLE=false

if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
    UPDATE_AVAILABLE=true
fi

function show_menu() {
    clear
    echo "==================================================="
    echo "    SpiderHeck - InfiniteFriends Manager (Linux)"
    echo "    Wersja: $LOCAL_VERSION"
    echo "==================================================="
    if [ -f "winhttp.dll" ]; then
        echo -e "Status Moda: \e[32mWŁĄCZONY\e[0m"
    elif [ -f "winhttp.dll.disabled" ]; then
        echo -e "Status Moda: \e[31mWYŁĄCZONY\e[0m"
    else
        echo -e "Status Moda: \e[33mNIEZAINSTALOWANY\e[0m"
    fi
    echo "==================================================="
    
    if [ "$UPDATE_AVAILABLE" = true ]; then
        echo -e "\e[32m0. [DOSTĘPNA AKTUALIZACJA!] Zaktualizuj program do $REMOTE_VERSION\e[0m"
    fi
    
    echo "1. Zainstaluj / Zaktualizuj modyfikacje"
    echo "2. Włącz / Wyłącz moda"
    echo "3. Uruchom grę"
    echo "4. Dodaj skrót do Menu Aplikacji"
    echo "5. Wyjście"
    echo "==================================================="
    read -p "Wybierz opcję: " choice

    case $choice in
        0) 
            if [ "$UPDATE_AVAILABLE" = true ]; then
                update_script
            else
                show_menu
            fi
            ;;
        1) install_mod ;;
        2) toggle_mod ;;
        3) play_game ;;
        4) create_shortcut ;;
        5) exit 0 ;;
        *) show_menu ;;
    esac
}

function update_script() {
    echo "Pobieranie nowej wersji skryptu..."
    curl -s -L -o "$0.tmp" "$GITHUB_RAW_URL/SpiderHeck_ModManager.sh"
    if [ -f "$0.tmp" ]; then
        mv "$0.tmp" "$0"
        chmod +x "$0"
        echo -e "\e[32mAktualizacja zakończona pomyślnie!\e[0m"
        sleep 2
        exec "$0" # Zrestartuj skrypt
    else
        echo "Błąd podczas pobierania aktualizacji."
        sleep 2
        show_menu
    fi
}

function install_mod() {
    echo "Pobieranie narzędzia BepInEx..."
    curl -L -o bepinex.zip "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip"
    echo "Pobieranie moda InfiniteFriends..."
    curl -L -o mod.zip "https://github.com/Senyksia/InfiniteFriends/releases/latest/download/InfiniteFriends_BepInEx.zip"

    echo "Rozpakowywanie plików..."
    unzip -o -q bepinex.zip
    unzip -o -q mod.zip
    rm bepinex.zip mod.zip

    if [ -f "winhttp.dll.disabled" ]; then
        mv winhttp.dll.disabled winhttp.dll
    fi

    echo "Instalacja zakończona pomyślnie!"
    echo "Pamiętaj o parametrach uruchamiania w Steam: WINEDLLOVERRIDES=\"winhttp=n,b\" %command%"
    read -p "Naciśnij Enter..."
    show_menu
}

function toggle_mod() {
    if [ -f "winhttp.dll" ]; then
        mv winhttp.dll winhttp.dll.disabled
        echo "Mod został WYŁĄCZONY."
    elif [ -f "winhttp.dll.disabled" ]; then
        mv winhttp.dll.disabled winhttp.dll
        echo "Mod został WŁĄCZONY."
    fi
    read -p "Naciśnij Enter..."
    show_menu
}

function play_game() {
    xdg-open steam://rungameid/1329500
    show_menu
}

function create_shortcut() {
    DESKTOP_FILE="$HOME/.local/share/applications/spiderheck_mod_manager.desktop"
    echo "[Desktop Entry]" > "$DESKTOP_FILE"
    echo "Name=SpiderHeck Mod Manager" >> "$DESKTOP_FILE"
    echo "Exec=\"$PWD/SpiderHeck_ModManager.sh\"" >> "$DESKTOP_FILE"
    echo "Terminal=true" >> "$DESKTOP_FILE"
    echo "Type=Application" >> "$DESKTOP_FILE"
    chmod +x "$DESKTOP_FILE"
    echo "Skrót dodany!"
    read -p "Naciśnij Enter..."
    show_menu
}

show_menu