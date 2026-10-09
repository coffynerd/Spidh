#!/bin/bash
cd "$(dirname "$0")"

# === KONFIGURACJA GŁÓWNA ================================
LOCAL_VERSION="1.2.0"
GITHUB_RAW_URL="https://raw.githubusercontent.com/coffynerd/Spidh/main"

# === BAZA DANYCH MODÓW ==================================
MOD_NAMES=(
    "InfiniteFriends"
    "Spiderheck Stats"
    "SpiderSurge"
    "Shrinkless Swords"
    "Long Sword Mod"
    "Infinite Ammo"
    "Increased Recoil"
    "InfiniteWeb"
    "No Lava Mod"
    "SpiderBorders"
)

# Wymuszone nazwy plików na dysku (ułatwia to ich włączanie/wyłączanie)
MOD_FILES=(
    "InfiniteFriends.dll"
    "SpiderheckStats.dll"
    "SpiderSurge.dll"
    "ShrinklessSwords.dll"
    "LongSwordMod.dll"
    "InfiniteAmmo.dll"
    "IncreasedRecoil.dll"
    "InfiniteWeb.dll"
    "NoLavaMod.dll"
    "SpiderBorders.dll"
)

# Bezpośrednie linki do pobierania
MOD_URLS=(
    "https://github.com/Senyksia/InfiniteFriends/releases/latest/download/InfiniteFriends_BepInEx.zip"
    "https://silk.abstractmelon.net/download/mod/62909a24-7a6d-4e20-91db-765629a9d868"
    "https://github.com/Dylan-Grinboju/SpiderSurge/releases/latest/download/SpiderSurge.dll"
    "https://silk.abstractmelon.net/download/mod/2420286b-6318-4031-8e01-3cfca06b1214"
    "https://silk.abstractmelon.net/download/mod/169f75c5-675f-4a35-b1fc-a655508f3e95"
    "https://silk.abstractmelon.net/download/mod/20919363-b596-42d1-86fb-69689ada3987"
    "https://silk.abstractmelon.net/download/mod/b4b62fa3-4c60-496a-a31d-3af91230ad20"
    "https://silk.abstractmelon.net/download/mod/0a59f933-cd40-4f68-8e88-c84e0a37f3b0"
    "https://silk.abstractmelon.net/download/mod/1ea3d67d-cc1b-4b71-8190-710bbabb562f"
    "https://silk.abstractmelon.net/download/mod/20919363-b596-42d1-86fb-69689ada3987"
)

# Oznacza, czy link pobiera archiwum ZIP (1), czy zwykły plik DLL (0)
MOD_IS_ZIP=(1 0 0 0 0 0 0 0 0 0)

MOD_DESCS=(
    "Usuwa limit graczy, pozwalając na grę w więcej osób. Rozszerza lobby."
    "Dodaje szczegółowe statystyki pod koniec rundy (zabójstwa, obrażenia itp.)."
    "Ogromna modyfikacja dodająca nowe umiejętności, mechaniki i przeciwników."
    "Miecze świetlne nie zmniejszają się po zderzeniach z innymi broniami."
    "Znacznie wydłuża zasięg wszystkich mieczy świetlnych w grze."
    "Bronie palne nigdy nie tracą amunicji. Czysta demolka."
    "Zwiększa odrzut broni, umożliwiając ekstremalne latanie po arenie."
    "Pająk ma nieskończoną pajęczynę. Łatwiejszy powrót na arenę z przepaści."
    "Usuwa całkowicie lawę z dołu poziomu, ułatwiając przeżycie."
    "Tworzy niewidzialne ściany na krawędziach map - zamknięte areny walk."
)
# ========================================================

REMOTE_VERSION=$(curl -s --max-time 3 "$GITHUB_RAW_URL/version_linux.txt" | tr -d '\r' | xargs)
UPDATE_AVAILABLE=false
if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
    UPDATE_AVAILABLE=true
fi

function show_menu() {
    clear
    echo "==================================================="
    echo "    SpiderHeck - Mod Manager (Linux)"
    echo "    Wersja: $LOCAL_VERSION"
    echo "==================================================="
    
    if [ "$UPDATE_AVAILABLE" = true ]; then
        echo -e "\e[32m0. [DOSTĘPNA AKTUALIZACJA!] Zaktualizuj program do $REMOTE_VERSION\e[0m"
    fi
    
    echo "1. Zarządzaj Modami (Instalacja, opisy, włączanie)"
    echo "2. Włącz / Wyłącz WSZYSTKIE mody naraz (Zarządzaj BepInEx)"
    echo "3. Uruchom grę"
    echo "4. Dodaj skróty (Pulpit i Menu Aplikacji)"
    echo "5. Narzędzia Parsec (Gra online)"
    echo "6. Wyjście"
    echo "==================================================="
    read -p "Wybierz opcję: " choice

    case $choice in
        0) if [ "$UPDATE_AVAILABLE" = true ]; then update_script; else show_menu; fi ;;
        1) show_mods_menu ;;
        2) toggle_all_mods ;;
        3) play_game ;;
        4) create_shortcuts ;;
        5) show_parsec_menu ;;
        6) exit 0 ;;
        *) show_menu ;;
    esac
}

# --- EKRAN: ZARZĄDZANIE MODAMI ---
function show_mods_menu() {
    clear
    echo "==================================================="
    echo "                MENEDŻER MODÓW"
    echo "==================================================="
    
    if [ ! -f "winhttp.dll" ] && [ ! -f "winhttp.dll.disabled" ]; then
        echo -e "\e[31mUWAGA: Nie zainstalowano silnika BepInEx!\e[0m"
        echo "Mody nie będą działać w grze. Zainstaluj go opcją 'B'."
        echo "---------------------------------------------------"
    fi

    for i in "${!MOD_NAMES[@]}"; do
        NAME="${MOD_NAMES[$i]}"
        FILE="BepInEx/plugins/${MOD_FILES[$i]}"
        DIS_FILE="${FILE}.disabled"
        
        if [ -f "$FILE" ]; then
            STATUS="\e[32m[WŁĄCZONY]\e[0m"
        elif [ -f "$DIS_FILE" ]; then
            STATUS="\e[33m[WYŁĄCZONY]\e[0m"
        else
            STATUS="\e[90m[BRAK PLIKU]\e[0m"
        fi
        
        IDX=$((i+1))
        printf " %2d. %-22s %b\n" "$IDX" "$NAME" "$STATUS"
    done
    
    echo "---------------------------------------------------"
    echo " B. Zainstaluj/Zaktualizuj rdzeń modów (BepInEx)"
    echo " 0. Powrót do Głównego Menu"
    echo "==================================================="
    read -p "Wybierz cyfrę moda, aby otworzyć jego opcje: " mchoice
    
    if [[ "$mchoice" == "0" ]]; then
        show_menu
    elif [[ "$mchoice" == "B" || "$mchoice" == "b" ]]; then
        install_bepinex
    elif [[ "$mchoice" =~ ^[0-9]+$ ]] && [ "$mchoice" -ge 1 ] && [ "$mchoice" -le ${#MOD_NAMES[@]} ]; then
        mod_details $((mchoice-1))
    else
        show_mods_menu
    fi
}

function mod_details() {
    local i=$1
    local NAME="${MOD_NAMES[$i]}"
    local FILE="BepInEx/plugins/${MOD_FILES[$i]}"
    local DIS_FILE="${FILE}.disabled"
    local DESC="${MOD_DESCS[$i]}"
    
    clear
    echo "==================================================="
    echo " Modyfikacja: $NAME"
    echo "==================================================="
    echo -e "Opis: \n$DESC"
    echo "---------------------------------------------------"
    
    if [ -f "$FILE" ]; then
        STATUS="\e[32mWŁĄCZONY\e[0m"
        HAS_MOD=true
        IS_ON=true
    elif [ -f "$DIS_FILE" ]; then
        STATUS="\e[33mWYŁĄCZONY\e[0m"
        HAS_MOD=true
        IS_ON=false
    else
        STATUS="\e[90mNIEZAINSTALOWANY (BRAK PLIKU)\e[0m"
        HAS_MOD=false
        IS_ON=false
    fi
    echo -e "Obecny status: $STATUS"
    echo "==================================================="
    echo "1. Zainstaluj / Aktualizuj (Pobierz z sieci)"
    
    if [ "$HAS_MOD" = true ]; then
        if [ "$IS_ON" = true ]; then
            echo "2. Wyłącz moda"
        else
            echo "2. Włącz moda"
        fi
    fi
    echo "3. Cofnij do listy modów"
    echo "==================================================="
    read -p "Wybierz opcję: " dchoice
    
    case $dchoice in
        1) install_single_mod $i ;;
        2) 
           if [ "$HAS_MOD" = true ]; then
               toggle_single_mod $i
           else
               mod_details $i
           fi
           ;;
        3) show_mods_menu ;;
        *) mod_details $i ;;
    esac
}

function install_single_mod() {
    local i=$1
    local URL="${MOD_URLS[$i]}"
    local IS_ZIP="${MOD_IS_ZIP[$i]}"
    local FILE="${MOD_FILES[$i]}"
    
    if [[ "$URL" == *"LINK_DO_"* ]]; then
        echo -e "\e[31m[BŁĄD] Link do tego moda nie został jeszcze dodany w skrypcie!\e[0m"
        sleep 4
        mod_details $i
        return
    fi
    
    echo "Pobieranie ${MOD_NAMES[$i]}..."
    mkdir -p BepInEx/plugins
    
    if [ "$IS_ZIP" -eq 1 ]; then
        curl -L -o temp_mod.zip "$URL"
        # Rozpakowanie z nadpisywaniem tylko pliku moda do plugins
        unzip -o -q temp_mod.zip -d . 
        rm temp_mod.zip
    else
        # Zapisuje pobrany plik prosto pod wymuszoną nazwą (np. SpiderheckStats.dll)
        curl -L -o "BepInEx/plugins/$FILE" "$URL"
    fi
    
    if [ -f "BepInEx/plugins/$FILE.disabled" ]; then
        rm "BepInEx/plugins/$FILE.disabled"
    fi
    
    echo -e "\e[32mZainstalowano!\e[0m"
    sleep 2
    mod_details $i
}

function toggle_single_mod() {
    local i=$1
    local FILE="BepInEx/plugins/${MOD_FILES[$i]}"
    local DIS_FILE="${FILE}.disabled"
    
    if [ -f "$FILE" ]; then
        mv "$FILE" "$DIS_FILE"
    elif [ -f "$DIS_FILE" ]; then
        mv "$DIS_FILE" "$FILE"
    fi
    mod_details $i
}

function install_bepinex() {
    clear
    echo "==================================================="
    echo " Instalacja środowiska BepInEx 5.4.22"
    echo "==================================================="
    echo "Pobieranie narzędzia z GitHuba..."
    curl -L -o bepinex.zip "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip"
    echo "Wypakowywanie..."
    unzip -o -q bepinex.zip
    rm bepinex.zip
    
    if [ -f "winhttp.dll.disabled" ]; then
        mv winhttp.dll.disabled winhttp.dll
    fi
    
    echo -e "\e[32mSilnik BepInEx zainstalowany pomyślnie!\e[0m"
    echo -e "\e[33m[WAŻNE] Dodaj w opcjach gry na Steam:\e[0m"
    echo 'WINEDLLOVERRIDES="winhttp=n,b" %command%'
    read -p "Naciśnij Enter..."
    show_mods_menu
}

function toggle_all_mods() {
    if [ -f "winhttp.dll" ]; then
        mv winhttp.dll winhttp.dll.disabled
        echo "Silnik modów zablokowany. Gra włączy się CZYSTA (Vanilla)."
    elif [ -f "winhttp.dll.disabled" ]; then
        mv winhttp.dll.disabled winhttp.dll
        echo "Silnik modów ODBLOKOWANY."
    else
        echo "Brak silnika BepInEx."
    fi
    read -p "Naciśnij Enter..."
    show_menu
}

# --- PARSEC MENU ---
function show_parsec_menu() {
    clear
    echo "==================================================="
    echo "                MENU PARSEC"
    echo "==================================================="
    echo "1. Uruchom Parsec w przeglądarce (Web Parsec)"
    echo "2. Pobierz i zainstaluj aplikację Parsec"
    echo "3. Instrukcja używania"
    echo "4. Cofnij"
    echo "==================================================="
    read -p "Wybierz opcję: " pchoice
    case $pchoice in
        1) xdg-open "https://web.parsec.app/" ; show_parsec_menu ;;
        2) install_parsec ;;
        3) show_parsec_instructions ;;
        4) show_menu ;;
        *) show_parsec_menu ;;
    esac
}

function install_parsec() {
    clear
    if command -v flatpak &> /dev/null; then
        echo "Wykryto system Flatpak. Rozpoczynam pobieranie..."
        flatpak install -y --user flathub com.parsecgaming.parsec || flatpak install -y flathub com.parsecgaming.parsec
        if [ $? -eq 0 ]; then
            echo -e "\e[32mZakończono sukcesem!\e[0m"
        else
            echo -e "\e[31mBłąd Flatpak. Otwieram stronę pobierania.\e[0m"
            xdg-open "https://parsec.app/downloads"
        fi
    else
        echo "Brak Flatpak. Otwieram stronę pobierania."
        xdg-open "https://parsec.app/downloads"
    fi
    read -p "Naciśnij Enter..."
    show_parsec_menu
}

function show_parsec_instructions() {
    clear
    echo "--- JAK UŻYWAĆ PARSEC DO GRY SPIDERHECK ---"
    echo "1. HOST (Osoba u której odpalona jest gra):"
    echo "   - Pobiera aplikację i loguje się."
    echo "   - W 'Friends' dodaje swoich znajomych."
    echo "   - Uruchamia grę."
    echo "2. ZNAJOMI (Goście):"
    echo "   - Logują się na konto i klikają 'Connect' przy Hoście."
    echo "3. UPRAWNIENIA:"
    echo "   - HOST upewnia się, że goście mają uprawnienia TYLKO do 'Gamepad'."
    echo "   - Wyłączcie 'Keyboard' i 'Mouse'!"
    read -p "Naciśnij Enter..."
    show_parsec_menu
}

# --- RESZTA MECHANIKI ---
function update_script() {
    echo "Pobieranie nowej wersji..."
    curl -s -L -o "$0.tmp" "$GITHUB_RAW_URL/SpiderHeck_ModManager.sh"
    if [ -f "$0.tmp" ]; then
        mv "$0.tmp" "$0"
        chmod +x "$0"
        echo -e "\e[32mAktualizacja zakończona!\e[0m"
        sleep 2
        exec "$0"
    else
        echo "Błąd aktualizacji."
        sleep 2
        show_menu
    fi
}

function play_game() {
    xdg-open steam://rungameid/1329500
    show_menu
}

function create_shortcuts() {
    clear
    echo -e "\e[33mTworzenie bezpiecznych skrótów dla Linuxa...\e[0m"
    SCRIPT_PATH=$(readlink -f "$0")
    WORK_DIR=$(dirname "$SCRIPT_PATH")
    ICON_PATH="$WORK_DIR/spidh_logo.png"
    
    DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null)
    if [ -z "$DESKTOP_DIR" ]; then
        DESKTOP_DIR="$HOME/Desktop"
    fi
    
    APP_DIR="$HOME/.local/share/applications"
    mkdir -p "$APP_DIR"
    
    if [ ! -f "$ICON_PATH" ]; then
        curl -s -L -o "$ICON_PATH" "https://raw.githubusercontent.com/coffynerd/Spidh/main/Site-logo.png"
    fi

    DESKTOP_FILE="[Desktop Entry]
Version=1.0
Type=Application
Name=SpiderHeck Mod Manager
Comment=Zarządzaj modami do SpiderHeck
Exec=bash \"$SCRIPT_PATH\"
Icon=$ICON_PATH
Terminal=true
Categories=Utility;Games;
"
    echo "$DESKTOP_FILE" > "$APP_DIR/spiderheck-manager.desktop"
    chmod +x "$APP_DIR/spiderheck-manager.desktop"

    if [ -d "$DESKTOP_DIR" ]; then
        DESKTOP_FILE_PATH="$DESKTOP_DIR/spiderheck-manager.desktop"
        echo "$DESKTOP_FILE" > "$DESKTOP_FILE_PATH"
        chmod +x "$DESKTOP_FILE_PATH"
        gio set "$DESKTOP_FILE_PATH" metadata::trusted true 2>/dev/null
    fi

    echo -e "\e[32mSkróty dodane pomyślnie!\e[0m"
    read -p "Naciśnij Enter..."
    show_menu
}

show_menu
