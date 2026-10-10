#!/bin/bash
cd "$(dirname "$0")"

# === KONFIGURACJA GŁÓWNA ================================
LOCAL_VERSION="1.3.0"
GITHUB_RAW_URL="https://raw.githubusercontent.com/coffynerd/Spidh/main"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# KODY KOLORÓW DLA NOWEGO WYGLĄDU
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
MAGENTA='\e[35m'
NC='\e[0m' # Reset koloru

# === BAZA DANYCH MODÓW ==================================
MOD_NAMES=("InfiniteFriends" "Spiderheck Stats" "SpiderSurge" "Shrinkless Swords" "Long Sword Mod" "Infinite Ammo" "Increased Recoil" "InfiniteWeb" "No Lava Mod" "SpiderBorders")
MOD_FILES=("InfiniteFriends.dll" "SpiderheckStats.dll" "SpiderSurge.dll" "ShrinklessSwords.dll" "LongSwordMod.dll" "InfiniteAmmo.dll" "IncreasedRecoil.dll" "InfiniteWeb.dll" "NoLavaMod.dll" "SpiderBorders.dll")
MOD_IS_ZIP=(1 0 0 0 0 0 0 0 0 0)
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

REMOTE_VERSION=$(curl -s -A "$USER_AGENT" --max-time 3 "$GITHUB_RAW_URL/version_linux.txt" | tr -d '\r' | xargs)
UPDATE_AVAILABLE=false
if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
    UPDATE_AVAILABLE=true
fi

# --- GŁÓWNE MENU (ODŚWIEŻONE) ---
function show_menu() {
    clear
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${CYAN}        SPIDERHECK MOD MANAGER - Wersja $LOCAL_VERSION ${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    
    if [ "$UPDATE_AVAILABLE" = true ]; then
        echo -e "${GREEN} 0. [AKTUALIZACJA] Zaktualizuj program do $REMOTE_VERSION ${NC}"
        echo -e "${CYAN}-------------------------------------------------------${NC}"
    fi
    
    echo -e "${MAGENTA}--- ZARZĄDZANIE MODAMI ---${NC}"
    echo " 1. Baza Modów (Pobieranie, włączanie, opisy)"
    echo " 2. Zainstaluj własnego moda z dysku (.dll / .zip)"
    echo " 3. Edytor konfiguracji modów (.cfg)"
    echo " 4. Włącz / Wyłącz silnik BepInEx (Wszystkie mody)"
    echo ""
    echo -e "${MAGENTA}--- GRA I NARZĘDZIA ---${NC}"
    echo -e " ${GREEN}5. Uruchom grę${NC}"
    echo " 6. Otwórz folder z grą w menedżerze plików"
    echo " 7. Kopia zapasowa zapisów gry (Save Backup)"
    echo " 8. Narzędzia Dodatkowe (Parsec, Skróty na pulpit)"
    echo -e " ${RED}9. TWARDY RESET (Czysta instalacja)${NC}"
    echo " 10. Wyjście"
    echo -e "${CYAN}=======================================================${NC}"
    read -p "Wybierz opcję: " choice

    case $choice in
        0) if [ "$UPDATE_AVAILABLE" = true ]; then update_script; else show_menu; fi ;;
        1) show_mods_menu ;;
        2) install_custom_mod ;;
        3) edit_config ;;
        4) toggle_all_mods ;;
        5) play_game ;;
        6) xdg-open "$PWD" 2>/dev/null ; show_menu ;;
        7) backup_saves ;;
        8) tools_menu ;;
        9) hard_reset ;;
        10) exit 0 ;;
        *) show_menu ;;
    esac
}

# --- FUNKCJA: WŁASNY MOD ---
function install_custom_mod() {
    clear
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${CYAN}               INSTALACJA WŁASNEGO MODA${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    echo "Możesz tutaj łatwo dodać moda, który nie istnieje w bazie."
    echo "Przeciągnij plik .dll lub archiwum .zip do tego okna,"
    echo "lub wpisz pełną ścieżkę do pliku."
    echo "-------------------------------------------------------"
    
    # read -e pozwala na użycie klawisza TAB do autouzupełniania ścieżek!
    read -e -p "Ścieżka do pliku: " custom_path
    
    # Usuwamy cudzysłowy (jeśli plik był przeciągnięty z menedżera)
    custom_path=$(echo "$custom_path" | tr -d "'\"")
    # Zamieniamy znak tyldy na domową ścieżkę (jeśli wpisano z palca)
    custom_path="${custom_path/#\~/$HOME}"
    
    if [ -f "$custom_path" ]; then
        mkdir -p BepInEx/plugins
        if [[ "$custom_path" == *.zip || "$custom_path" == *.ZIP ]]; then
            unzip -o -q "$custom_path" -d .
            echo -e "${GREEN}Sukces! Rozpakowano archiwum do folderu z grą.${NC}"
        elif [[ "$custom_path" == *.dll || "$custom_path" == *.DLL ]]; then
            cp "$custom_path" "BepInEx/plugins/"
            echo -e "${GREEN}Sukces! Skopiowano plik modyfikacji do BepInEx/plugins.${NC}"
        else
            echo -e "${RED}Błąd: Nieobsługiwany format pliku. Wybierz .dll lub .zip.${NC}"
        fi
    else
        echo -e "${RED}Błąd: Plik nie istnieje pod wskazaną ścieżką: $custom_path${NC}"
    fi
    echo "-------------------------------------------------------"
    read -p "Naciśnij Enter, aby wrócić..."
    show_menu
}

# --- FUNKCJA: EDYTOR KONFIGURACJI ---
function edit_config() {
    clear
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${CYAN}               EDYTOR KONFIGURACJI (.CFG)${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    CONFIG_DIR="BepInEx/config"
    
    if [ ! -d "$CONFIG_DIR" ]; then
        echo -e "${RED}Folder 'config' jeszcze nie istnieje.${NC}"
        echo "Aby mod stworzył swój plik konfiguracyjny, musisz go najpierw"
        echo "zainstalować i URUCHOMIĆ GRĘ chociaż raz!"
        read -p "Naciśnij Enter, aby wrócić..."
        show_menu
        return
    fi
    
    # Zbieranie plików cfg
    configs=("$CONFIG_DIR"/*.cfg)
    
    if [ ! -e "${configs[0]}" ]; then
        echo -e "${YELLOW}Folder 'config' jest pusty.${NC}"
        echo "Żaden z zainstalowanych modów nie wygenerował jeszcze plików opcji."
        read -p "Naciśnij Enter, aby wrócić..."
        show_menu
        return
    fi
    
    echo "Wybierz plik do edycji (otworzy się w domyślnym edytorze tekstu):"
    echo "-------------------------------------------------------"
    for i in "${!configs[@]}"; do
        filename=$(basename "${configs[$i]}")
        echo " $((i+1)). $filename"
    done
    echo "-------------------------------------------------------"
    echo " 0. Powrót"
    read -p "Twój wybór: " cchoice
    
    if [[ "$cchoice" == "0" ]]; then
        show_menu
    elif [[ "$cchoice" =~ ^[0-9]+$ ]] && [ "$cchoice" -ge 1 ] && [ "$cchoice" -le ${#configs[@]} ]; then
        idx=$((cchoice-1))
        selected_file="${configs[$idx]}"
        echo -e "${GREEN}Otwieranie $selected_file ...${NC}"
        # xdg-open otworzy systemowy notatnik/gedit/kate
        xdg-open "$selected_file" 2>/dev/null || nano "$selected_file"
        show_menu
    else
        show_menu
    fi
}

# --- FUNKCJA: KOPIA ZAPASOWA ZAPISÓW ---
function backup_saves() {
    clear
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${CYAN}               KOPIA ZAPASOWA ZAPISÓW GRY${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    
    # Proton przechowuje zapisy na wygenerowanym "Dysku C" dla danej gry
    SAVE_PATH_1="$HOME/.steam/steam/steamapps/compatdata/1329500/pfx/drive_c/users/steamuser/AppData/LocalLow/Neverjam/SpiderHeck"
    SAVE_PATH_2="$HOME/.local/share/Steam/steamapps/compatdata/1329500/pfx/drive_c/users/steamuser/AppData/LocalLow/Neverjam/SpiderHeck"
    
    SAVE_PATH=""
    if [ -d "$SAVE_PATH_1" ]; then SAVE_PATH="$SAVE_PATH_1";
    elif [ -d "$SAVE_PATH_2" ]; then SAVE_PATH="$SAVE_PATH_2"; fi
    
    if [ -n "$SAVE_PATH" ]; then
        echo "Znaleziono folder zapisów:"
        echo -e "${YELLOW}$SAVE_PATH${NC}"
        echo "Trwa tworzenie kopii zapasowej..."
        
        mkdir -p "Zapisy_KopieZapasowe"
        TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
        BACKUP_NAME="Zapisy_KopieZapasowe/SaveBackup_${TIMESTAMP}.tar.gz"
        
        tar -czf "$BACKUP_NAME" -C "$SAVE_PATH" . 2>/dev/null
        
        echo -e "${GREEN}SUKCES! Utworzono bezpieczny plik:${NC}"
        echo "$PWD/$BACKUP_NAME"
    else
        echo -e "${RED}BŁĄD: Nie odnaleziono folderu z zapisami gry!${NC}"
        echo "Upewnij się, że SpiderHeck był uruchamiany na tym systemie"
        echo "poprzez Steam (Warstwa zgodności Proton)."
    fi
    
    echo "-------------------------------------------------------"
    read -p "Naciśnij Enter, aby wrócić..."
    show_menu
}

# --- FUNKCJA: TWARDY RESET ---
function hard_reset() {
    clear
    echo -e "${RED}=======================================================${NC}"
    echo -e "${RED}            TWARDY RESET (CZYSTA INSTALACJA)${NC}"
    echo -e "${RED}=======================================================${NC}"
    echo "Ta funkcja używana jest, gdy mody popsują grę."
    echo "Zostaną bezpowrotnie usunięte następujące pliki/foldery:"
    echo " - Cały rdzeń BepInEx (w tym wszystkie pobrane mody)"
    echo " - Wszystkie Twoje pliki konfiguracyjne (.cfg)"
    echo " - Pliki winhttp.dll"
    echo ""
    echo -e "${GREEN}Twoje zapisy stanu gry (Saves) pozostaną bezpieczne!${NC}"
    echo "Gra wróci do 100% oryginalnego, czystego stanu."
    echo "-------------------------------------------------------"
    read -p "Czy na pewno chcesz wykonać reset? (Wpisz T, aby usunąć): " confirm
    
    if [[ "$confirm" == "T" || "$confirm" == "t" ]]; then
        echo "Usuwanie plików..."
        rm -rf BepInEx winhttp.dll winhttp.dll.disabled doorstop_config.ini mod_temp.zip bepinex.zip >/dev/null 2>&1
        echo -e "${GREEN}Modyfikacje zostały całkowicie wyczyszczone.${NC}"
    else
        echo "Anulowano. Nic nie zostało usunięte."
    fi
    read -p "Naciśnij Enter, aby wrócić..."
    show_menu
}

# --- NARZĘDZIA DODATKOWE ---
function tools_menu() {
    clear
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${CYAN}                 NARZĘDZIA DODATKOWE${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    echo " 1. Narzędzia sieciowe Parsec (Instrukcje i pobieranie)"
    echo " 2. Utwórz skróty do Menedżera (Pulpit i Menu Aplikacji)"
    echo " 0. Powrót do głównego menu"
    echo "-------------------------------------------------------"
    read -p "Wybierz opcję: " tchoice
    case $tchoice in
        1) show_parsec_menu ;;
        2) create_shortcuts ;;
        0) show_menu ;;
        *) tools_menu ;;
    esac
}

# --- BAZA MENEDŻERA MODÓW ---
function show_mods_menu() {
    clear
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${CYAN}                  BAZA MODYFIKACJI${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    
    if [ ! -f "winhttp.dll" ] && [ ! -f "winhttp.dll.disabled" ]; then
        echo -e "${RED}UWAGA: Nie zainstalowano silnika BepInEx!${NC}"
        echo "Mody nie będą działać. Zainstaluj go opcją 'B' na dole."
        echo "-------------------------------------------------------"
    fi

    for i in "${!MOD_NAMES[@]}"; do
        NAME="${MOD_NAMES[$i]}"
        FILE="BepInEx/plugins/${MOD_FILES[$i]}"
        DIS_FILE="${FILE}.disabled"
        
        if [ -f "$FILE" ]; then
            STATUS="${GREEN}[WŁĄCZONY]${NC}"
        elif [ -f "$DIS_FILE" ]; then
            STATUS="${YELLOW}[WYŁĄCZONY]${NC}"
        else
            STATUS="\e[90m[BRAK PLIKU]${NC}"
        fi
        
        IDX=$((i+1))
        printf " %2d. %-22s %b\n" "$IDX" "$NAME" "$STATUS"
    done
    
    echo "-------------------------------------------------------"
    echo -e " ${BLUE}B. Zainstaluj/Zaktualizuj rdzeń modów (BepInEx)${NC}"
    echo " 0. Powrót do Głównego Menu"
    echo -e "${CYAN}=======================================================${NC}"
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
    echo -e "${CYAN}=======================================================${NC}"
    echo -e " ${BLUE}MODYFIKACJA:${NC} ${NAME}"
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "Opis: \n$DESC"
    echo "-------------------------------------------------------"
    
    if [ -f "$FILE" ]; then
        STATUS="${GREEN}WŁĄCZONY${NC}"
        HAS_MOD=true
        IS_ON=true
    elif [ -f "$DIS_FILE" ]; then
        STATUS="${YELLOW}WYŁĄCZONY${NC}"
        HAS_MOD=true
        IS_ON=false
    else
        STATUS="\e[90mNIEZAINSTALOWANY (BRAK PLIKU)${NC}"
        HAS_MOD=false
        IS_ON=false
    fi
    echo -e "Obecny status: $STATUS"
    echo -e "${CYAN}=======================================================${NC}"
    echo " 1. Zainstaluj / Aktualizuj (Pobierz z sieci)"
    
    if [ "$HAS_MOD" = true ]; then
        if [ "$IS_ON" = true ]; then
            echo " 2. Wyłącz moda"
        else
            echo " 2. Włącz moda"
        fi
    fi
    echo " 3. Cofnij do listy modów"
    echo "-------------------------------------------------------"
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
        echo -e "${RED}[BŁĄD] Link do tego moda nie został jeszcze dodany!${NC}"
        sleep 3
        mod_details $i
        return
    fi
    
    echo "Pobieranie ${MOD_NAMES[$i]}..."
    mkdir -p BepInEx/plugins
    
    if [ "$IS_ZIP" -eq 1 ]; then
        curl -A "$USER_AGENT" -L -o temp_mod.zip "$URL"
        unzip -o -q temp_mod.zip -d . 
        rm temp_mod.zip
    else
        curl -A "$USER_AGENT" -L -o "BepInEx/plugins/$FILE" "$URL"
    fi
    
    if [ -f "BepInEx/plugins/$FILE.disabled" ]; then
        rm "BepInEx/plugins/$FILE.disabled"
    fi
    
    echo -e "${GREEN}Zainstalowano!${NC}"
    sleep 2
    mod_details $i
}

function toggle_single_mod() {
    local i=$1
    local FILE="BepInEx/plugins/${MOD_FILES[$i]}"
    local DIS_FILE="${FILE}.disabled"
    if [ -f "$FILE" ]; then mv "$FILE" "$DIS_FILE"
    elif [ -f "$DIS_FILE" ]; then mv "$DIS_FILE" "$FILE"; fi
    mod_details $i
}

function install_bepinex() {
    clear
    echo "Pobieranie silnika BepInEx 5.4.22..."
    curl -A "$USER_AGENT" -L -o bepinex.zip "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip"
    unzip -o -q bepinex.zip
    rm bepinex.zip
    
    if [ -f "winhttp.dll.disabled" ]; then
        mv winhttp.dll.disabled winhttp.dll
    fi
    echo -e "${GREEN}Silnik BepInEx zainstalowany!${NC}"
    echo -e "${YELLOW}[WAŻNE] Dodaj w opcjach gry na Steam:${NC}"
    echo 'WINEDLLOVERRIDES="winhttp=n,b" %command%'
    read -p "Naciśnij Enter..."
    show_mods_menu
}

function toggle_all_mods() {
    if [ -f "winhttp.dll" ]; then
        mv winhttp.dll winhttp.dll.disabled
        echo -e "${YELLOW}Silnik modów zablokowany. Gra włączy się CZYSTA.${NC}"
    elif [ -f "winhttp.dll.disabled" ]; then
        mv winhttp.dll.disabled winhttp.dll
        echo -e "${GREEN}Silnik modów ODBLOKOWANY.${NC}"
    else
        echo -e "${RED}Brak silnika BepInEx.${NC}"
    fi
    read -p "Naciśnij Enter..."
    show_menu
}

# --- PARSEC MENU ---
function show_parsec_menu() {
    clear
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${CYAN}                     MENU PARSEC${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    echo " 1. Uruchom Parsec w przeglądarce (Web Parsec)"
    echo " 2. Pobierz i zainstaluj aplikację Parsec"
    echo " 3. Instrukcja używania"
    echo " 0. Cofnij"
    echo "-------------------------------------------------------"
    read -p "Wybierz opcję: " pchoice
    case $pchoice in
        1) xdg-open "https://web.parsec.app/" 2>/dev/null ; show_parsec_menu ;;
        2) install_parsec ;;
        3) show_parsec_instructions ;;
        0) tools_menu ;;
        *) show_parsec_menu ;;
    esac
}

function install_parsec() {
    clear
    if command -v flatpak &> /dev/null; then
        echo "Wykryto system Flatpak. Rozpoczynam pobieranie..."
        flatpak install -y --user flathub com.parsecgaming.parsec || flatpak install -y flathub com.parsecgaming.parsec
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Zakończono sukcesem!${NC}"
        else
            echo -e "${RED}Błąd Flatpak. Otwieram stronę pobierania.${NC}"
            xdg-open "https://parsec.app/downloads" 2>/dev/null
        fi
    else
        echo -e "${YELLOW}Brak Flatpak. Otwieram stronę pobierania.${NC}"
        xdg-open "https://parsec.app/downloads" 2>/dev/null
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
    curl -s -A "$USER_AGENT" -L -o "$0.tmp" "$GITHUB_RAW_URL/SpiderHeck_ModManager.sh"
    if [ -f "$0.tmp" ]; then
        mv "$0.tmp" "$0"
        chmod +x "$0"
        echo -e "${GREEN}Aktualizacja zakończona!${NC}"
        sleep 2
        exec "$0"
    else
        echo -e "${RED}Błąd aktualizacji.${NC}"
        sleep 2
        show_menu
    fi
}

function play_game() {
    xdg-open steam://rungameid/1329500 2>/dev/null
    show_menu
}

function create_shortcuts() {
    clear
    echo -e "${CYAN}Tworzenie bezpiecznych skrótów dla Linuxa...${NC}"
    SCRIPT_PATH=$(readlink -f "$0")
    WORK_DIR=$(dirname "$SCRIPT_PATH")
    ICON_PATH="$WORK_DIR/spidh_logo.png"
    
    DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null)
    if [ -z "$DESKTOP_DIR" ]; then DESKTOP_DIR="$HOME/Desktop"; fi
    
    APP_DIR="$HOME/.local/share/applications"
    mkdir -p "$APP_DIR"
    
    if [ ! -f "$ICON_PATH" ]; then
        curl -s -A "$USER_AGENT" -L -o "$ICON_PATH" "https://raw.githubusercontent.com/coffynerd/Spidh/main/Site-logo.png"
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

    echo -e "${GREEN}Skróty dodane pomyślnie!${NC}"
    read -p "Naciśnij Enter..."
    tools_menu
}

# Uruchomienie programu
show_menu
