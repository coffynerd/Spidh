import customtkinter as ctk
import tkinter as tk
from tkinter import messagebox, filedialog
import urllib.request
import zipfile
import os
import sys
import tempfile
import subprocess
import webbrowser
import shutil
import datetime

# --- KONFIGURACJA GŁÓWNA ---
LOCAL_VERSION = "1.3.0"
GITHUB_RAW_URL = "https://raw.githubusercontent.com/coffynerd/Spidh/main"
GITHUB_EXE_URL = "https://github.com/coffynerd/Spidh/raw/main/SpiderHeckManager.exe"

# Konfiguracja Wyglądu CustomTkinter
ctk.set_appearance_mode("dark")  # "light", "dark", "system"
ctk.set_default_color_theme("blue")  # "blue", "green", "dark-blue"

# --- FUNKCJA POBIERANIA (OMIJająca BŁĄD 403) ---
def download_file(url, dest):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=15) as response, open(dest, 'wb') as out_file:
        shutil.copyfileobj(response, out_file)

# --- BAZA DANYCH MODÓW ---
MODS = [
    {
        "name": "InfiniteFriends",
        "file": "InfiniteFriends.dll",
        "url": "https://github.com/Senyksia/InfiniteFriends/releases/latest/download/InfiniteFriends_BepInEx.zip",
        "is_zip": True,
        "desc": "Usuwa limit graczy, pozwalając na grę w więcej osób. Rozszerza lobby."
    },
    {
        "name": "Spiderheck Stats",
        "file": "SpiderheckStats.dll",
        "url": "https://silk.abstractmelon.net/download/mod/62909a24-7a6d-4e20-91db-765629a9d868",
        "is_zip": False,
        "desc": "Dodaje szczegółowe statystyki pod koniec rundy (zabójstwa, obrażenia itp.)."
    },
    {
        "name": "SpiderSurge",
        "file": "SpiderSurge.dll",
        "url": "https://github.com/Dylan-Grinboju/SpiderSurge/releases/latest/download/SpiderSurge.dll",
        "is_zip": False,
        "desc": "Ogromna modyfikacja dodająca nowe umiejętności, mechaniki i przeciwników."
    },
    {
        "name": "Shrinkless Swords",
        "file": "ShrinklessSwords.dll",
        "url": "https://silk.abstractmelon.net/download/mod/2420286b-6318-4031-8e01-3cfca06b1214",
        "is_zip": False,
        "desc": "Miecze świetlne nie zmniejszają się po zderzeniach z innymi broniami."
    },
    {
        "name": "Long Sword Mod",
        "file": "LongSwordMod.dll",
        "url": "https://silk.abstractmelon.net/download/mod/169f75c5-675f-4a35-b1fc-a655508f3e95",
        "is_zip": False,
        "desc": "Znacznie wydłuża zasięg wszystkich mieczy świetlnych w grze."
    },
    {
        "name": "Infinite Ammo",
        "file": "InfiniteAmmo.dll",
        "url": "https://silk.abstractmelon.net/download/mod/20919363-b596-42d1-86fb-69689ada3987",
        "is_zip": False,
        "desc": "Bronie palne nigdy nie tracą amunicji. Czysta demolka."
    },
    {
        "name": "Increased Recoil",
        "file": "IncreasedRecoil.dll",
        "url": "https://silk.abstractmelon.net/download/mod/b4b62fa3-4c60-496a-a31d-3af91230ad20",
        "is_zip": False,
        "desc": "Zwiększa odrzut broni, umożliwiając ekstremalne latanie po arenie."
    },
    {
        "name": "InfiniteWeb",
        "file": "InfiniteWeb.dll",
        "url": "https://silk.abstractmelon.net/download/mod/0a59f933-cd40-4f68-8e88-c84e0a37f3b0",
        "is_zip": False,
        "desc": "Pająk ma nieskończoną pajęczynę. Łatwiejszy powrót na arenę z przepaści."
    },
    {
        "name": "No Lava Mod",
        "file": "NoLavaMod.dll",
        "url": "https://silk.abstractmelon.net/download/mod/1ea3d67d-cc1b-4b71-8190-710bbabb562f",
        "is_zip": False,
        "desc": "Usuwa całkowicie lawę z dołu poziomu, ułatwiając przeżycie."
    },
    {
        "name": "SpiderBorders",
        "file": "SpiderBorders.dll",
        "url": "https://silk.abstractmelon.net/download/mod/20919363-b596-42d1-86fb-69689ada3987",
        "is_zip": False,
        "desc": "Tworzy niewidzialne ściany na krawędziach map - zamknięte areny walk."
    }
]

# --- AKTUALIZACJA PROGRAMU ---
def check_update():
    try:
        req = urllib.request.Request(f"{GITHUB_RAW_URL}/version_win.txt", headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=3) as response:
            remote_version = response.read().decode('utf-8').strip()
            if remote_version and remote_version != LOCAL_VERSION:
                btn_update.pack(pady=(0, 10))
                btn_update.configure(text=f"⚠️ Dostępna aktualizacja ({remote_version}) - Kliknij tutaj")
    except Exception:
        pass

def download_update():
    try:
        messagebox.showinfo("Aktualizacja", "Rozpoczynam pobieranie nowej wersji. Program zrestartuje się automatycznie.\nKliknij OK i poczekaj.")
        current_exe = sys.executable
        exe_dir = os.path.dirname(current_exe)
        new_exe = os.path.join(exe_dir, "update_temp.exe")
        
        download_file(GITHUB_EXE_URL, new_exe)
        
        if os.name == 'nt':
            bat_path = os.path.join(tempfile.gettempdir(), "spidh_updater.bat")
            bat_content = f"""@echo off\ntimeout /t 2 /nobreak >nul\ndel "{current_exe}"\nren "{new_exe}" "{os.path.basename(current_exe)}"\nstart "" "{current_exe}"\ndel "%~f0"\n"""
            with open(bat_path, "w", encoding="utf-8") as f:
                f.write(bat_content)
            subprocess.Popen(["cmd.exe", "/c", bat_path], creationflags=0x08000000)
            root.destroy()
            sys.exit()
        else:
            messagebox.showwarning("Info", "Automatyczny instalator aktualizacji działa tylko na Windowsie (.exe). Pobierz najnowszą wersję Pythona ręcznie.")
    except Exception as e:
        messagebox.showerror("Błąd", f"Nie udało się zaktualizować programu:\n{e}")

# --- MECHANIKI BAZOWE ---
def get_mod_status(mod):
    file_path = os.path.join("BepInEx", "plugins", mod['file'])
    dis_file_path = file_path + ".disabled"
    if os.path.exists(file_path):
        return "WŁĄCZONY", "#2ecc71" # Jasny zielony
    elif os.path.exists(dis_file_path):
        return "WYŁĄCZONY", "#e74c3c" # Jasny czerwony
    else:
        return "NIEZAINSTALOWANY", "gray"

def install_bepinex():
    try:
        messagebox.showinfo("Instalacja", "Rozpoczynam pobieranie silnika BepInEx.\nKliknij OK i poczekaj chwilę.")
        bepinex_url = "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip"
        download_file(bepinex_url, "bepinex.zip")
        with zipfile.ZipFile("bepinex.zip", 'r') as zip_ref:
            zip_ref.extractall(".")
        os.remove("bepinex.zip")
        if os.path.exists("winhttp.dll.disabled"):
            os.rename("winhttp.dll.disabled", "winhttp.dll")
        update_status()
        messagebox.showinfo("Sukces", "Silnik BepInEx zainstalowany pomyślnie!\nPamiętaj o parametrach uruchamiania w Steam: WINEDLLOVERRIDES=\"winhttp=n,b\" %command%")
    except Exception as e:
        messagebox.showerror("Błąd", f"Wystąpił błąd podczas instalacji:\n{e}")

def toggle_bepinex():
    if os.path.exists("winhttp.dll"):
        os.rename("winhttp.dll", "winhttp.dll.disabled")
        messagebox.showinfo("Status", "Silnik modów zablokowany. Gra włączy się CZYSTA (Vanilla).")
    elif os.path.exists("winhttp.dll.disabled"):
        os.rename("winhttp.dll.disabled", "winhttp.dll")
        messagebox.showinfo("Status", "Silnik modów ODBLOKOWANY.")
    else:
        messagebox.showwarning("Status", "Brak silnika BepInEx. Zainstaluj go najpierw w Menedżerze Modów.")
    update_status()

def play_game():
    webbrowser.open("steam://rungameid/1329500")

def open_game_folder():
    try:
        if sys.platform == 'win32':
            os.startfile(os.getcwd())
        elif sys.platform == 'darwin': # macOS
            subprocess.Popen(['open', os.getcwd()])
        else: # Linux
            subprocess.Popen(['xdg-open', os.getcwd()])
    except Exception as e:
        messagebox.showerror("Błąd", f"Nie udało się otworzyć folderu:\n{e}")

def backup_saves():
    if sys.platform == 'win32':
        save_dir = os.path.join(os.environ['USERPROFILE'], 'AppData', 'LocalLow', 'Neverjam', 'SpiderHeck')
    else:
        # Przykładowa ścieżka dla testów na Linuxie
        save_dir = os.path.join(os.environ['HOME'], '.steam/steam/steamapps/compatdata/1329500/pfx/drive_c/users/steamuser/AppData/LocalLow/Neverjam/SpiderHeck')

    if os.path.exists(save_dir):
        try:
            os.makedirs("Zapisy_KopieZapasowe", exist_ok=True)
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
            backup_base = os.path.join("Zapisy_KopieZapasowe", f"SaveBackup_{timestamp}")
            shutil.make_archive(backup_base, 'zip', save_dir)
            messagebox.showinfo("Sukces", f"Utworzono kopię zapasową zapisów w folderze:\nZapisy_KopieZapasowe")
        except Exception as e:
            messagebox.showerror("Błąd", f"Nie udało się utworzyć kopii zapasowej:\n{e}")
    else:
        messagebox.showerror("Błąd", "Nie znaleziono folderu z zapisami gry.")

def hard_reset():
    if messagebox.askyesno("TWARDY RESET", "Czy na pewno chcesz wykonać reset?\n\nZostaną usunięte WSZYSTKIE mody, configi oraz silnik BepInEx.\nTwoje zapisy stanu gry pozostaną bezpieczne.\n\nGra wróci do 100% oryginalnego stanu."):
        items_to_remove = ["BepInEx", "winhttp.dll", "winhttp.dll.disabled", "doorstop_config.ini"]
        try:
            for item in items_to_remove:
                if os.path.exists(item):
                    if os.path.isdir(item):
                        shutil.rmtree(item, ignore_errors=True)
                    else:
                        os.remove(item)
            update_status()
            messagebox.showinfo("Sukces", "Modyfikacje zostały całkowicie usunięte z gry.")
        except Exception as e:
            messagebox.showerror("Błąd", f"Wystąpił błąd podczas usuwania plików:\n{e}")

def update_status():
    if os.path.exists("winhttp.dll"):
        lbl_status.configure(text="Status Silnika (BepInEx): WŁĄCZONY", text_color="#2ecc71")
    elif os.path.exists("winhttp.dll.disabled"):
        lbl_status.configure(text="Status Silnika (BepInEx): WYŁĄCZONY", text_color="#e74c3c")
    else:
        lbl_status.configure(text="Status Silnika (BepInEx): NIEZAINSTALOWANY", text_color="#f39c12")

# --- MENEDŻER MODÓW (NOWY WYGLĄD) ---
def open_mod_manager():
    mod_win = ctk.CTkToplevel(root)
    mod_win.title("Menedżer Modów")
    mod_win.geometry("750x520")
    mod_win.resizable(False, False)
    mod_win.grab_set() # Blokuje klikanie w główne okno

    # Lewy panel z listą modów (Przewijany)
    frame_left = ctk.CTkScrollableFrame(mod_win, width=220)
    frame_left.pack(side="left", fill="y", padx=10, pady=10)
    
    # Prawy panel ze szczegółami
    frame_right = ctk.CTkFrame(mod_win)
    frame_right.pack(side="right", fill="both", expand=True, padx=10, pady=10)
    
    # Elementy prawego panelu
    lbl_name = ctk.CTkLabel(frame_right, text="Wybierz moda z listy", font=("Arial", 20, "bold"))
    lbl_name.pack(anchor="nw", padx=15, pady=(15, 5))
    
    lbl_desc = ctk.CTkLabel(frame_right, text="Tutaj pojawi się opis modyfikacji.", font=("Arial", 12), justify="left", wraplength=400)
    lbl_desc.pack(anchor="nw", padx=15, pady=(0, 15))
    
    lbl_mod_status = ctk.CTkLabel(frame_right, text="Status: Brak", font=("Arial", 14, "bold"))
    lbl_mod_status.pack(anchor="nw", padx=15, pady=(0, 15))
    
    btn_install = ctk.CTkButton(frame_right, text="Zainstaluj / Aktualizuj (Pobierz z bazy)", state="disabled", height=35)
    btn_install.pack(anchor="nw", padx=15, pady=5)
    
    btn_toggle = ctk.CTkButton(frame_right, text="Włącz / Wyłącz moda", state="disabled", fg_color="#34495e", hover_color="#2c3e50", height=35)
    btn_toggle.pack(anchor="nw", padx=15, pady=5)
    
    ctk.CTkLabel(frame_right, text="--- NARZĘDZIA ZAAWANSOWANE ---", text_color="gray").pack(anchor="nw", padx=15, pady=(25, 5))
    
    def install_custom_mod():
        filepath = filedialog.askopenfilename(title="Wybierz plik moda", filetypes=[("Modyfikacje", "*.dll *.zip")])
        if filepath:
            try:
                os.makedirs(os.path.join("BepInEx", "plugins"), exist_ok=True)
                if filepath.lower().endswith('.zip'):
                    with zipfile.ZipFile(filepath, 'r') as zip_ref:
                        zip_ref.extractall(".")
                    messagebox.showinfo("Sukces", "Rozpakowano archiwum do folderu z grą.")
                elif filepath.lower().endswith('.dll'):
                    shutil.copy(filepath, os.path.join("BepInEx", "plugins"))
                    messagebox.showinfo("Sukces", "Skopiowano plik .dll do folderu BepInEx/plugins.")
            except Exception as e:
                messagebox.showerror("Błąd", f"Wystąpił błąd podczas kopiowania:\n{e}")

    def edit_configs():
        config_dir = os.path.join("BepInEx", "config")
        if not os.path.exists(config_dir):
            messagebox.showinfo("Informacja", "Folder 'config' jeszcze nie istnieje. Zainstaluj mody i uruchom grę chociaż raz.")
            return
        cfgs = [f for f in os.listdir(config_dir) if f.endswith('.cfg')]
        if not cfgs:
            messagebox.showinfo("Informacja", "Brak plików konfiguracyjnych w folderze.")
            return
            
        cfg_win = ctk.CTkToplevel(mod_win)
        cfg_win.title("Edytor Configów")
        cfg_win.geometry("350x400")
        cfg_win.resizable(False, False)
        
        ctk.CTkLabel(cfg_win, text="Wybierz plik do edycji:", font=("Arial", 14, "bold")).pack(pady=10)
        
        cfg_frame = ctk.CTkScrollableFrame(cfg_win)
        cfg_frame.pack(fill="both", expand=True, padx=10, pady=5)
        
        selected_cfg = tk.StringVar(value="")
        for c in cfgs:
            rb = ctk.CTkRadioButton(cfg_frame, text=c, variable=selected_cfg, value=c)
            rb.pack(anchor="w", pady=5)
            
        def open_selected_cfg():
            val = selected_cfg.get()
            if val:
                cfg_path = os.path.join(config_dir, val)
                if sys.platform == 'win32':
                    os.startfile(cfg_path)
                else:
                    subprocess.Popen(['xdg-open', cfg_path])
                
        ctk.CTkButton(cfg_win, text="Otwórz (Systemowy Edytor)", command=open_selected_cfg, height=40).pack(fill="x", padx=10, pady=10)
    
    ctk.CTkButton(frame_right, text="Zainstaluj własnego moda (.dll / .zip)", command=install_custom_mod, fg_color="#8e44ad", hover_color="#732d91").pack(anchor="nw", padx=15, pady=4)
    ctk.CTkButton(frame_right, text="Edytor konfiguracji modów (.cfg)", command=edit_configs, fg_color="#16a085", hover_color="#1abc9c").pack(anchor="nw", padx=15, pady=4)
    ctk.CTkButton(frame_right, text="Zainstaluj / Zaktualizuj rdzeń BepInEx", command=install_bepinex, fg_color="#c0392b", hover_color="#e74c3c").pack(anchor="nw", padx=15, pady=(20,0))

    # Logika wyboru modów
    def select_mod(idx):
        mod = MODS[idx]
        lbl_name.configure(text=mod['name'])
        lbl_desc.configure(text=f"Opis:\n{mod['desc']}")
        status, color = get_mod_status(mod)
        lbl_mod_status.configure(text=f"Status w grze: {status}", text_color=color)
        
        btn_install.configure(state="normal", command=lambda: handle_install(mod, idx))
        if status == "NIEZAINSTALOWANY":
            btn_toggle.configure(state="disabled")
        else:
            btn_toggle.configure(state="normal", command=lambda: handle_toggle(mod, idx))

    # Generowanie przycisków modów po lewej stronie
    for i, mod in enumerate(MODS):
        btn = ctk.CTkButton(frame_left, text=mod['name'], fg_color="transparent", text_color=("gray10", "gray90"), hover_color=("gray70", "gray30"), anchor="w", command=lambda idx=i: select_mod(idx))
        btn.pack(fill="x", pady=2)

    def handle_install(mod, idx):
        try:
            messagebox.showinfo("Pobieranie", f"Rozpoczęto pobieranie: {mod['name']}...\nKliknij OK i poczekaj.")
            os.makedirs(os.path.join("BepInEx", "plugins"), exist_ok=True)
            if mod['is_zip']:
                temp_zip = "temp_mod.zip"
                download_file(mod['url'], temp_zip)
                with zipfile.ZipFile(temp_zip, 'r') as zip_ref:
                    zip_ref.extractall(".")
                os.remove(temp_zip)
            else:
                target_path = os.path.join("BepInEx", "plugins", mod['file'])
                download_file(mod['url'], target_path)
                
            dis_path = os.path.join("BepInEx", "plugins", mod['file'] + ".disabled")
            if os.path.exists(dis_path): os.remove(dis_path)
            select_mod(idx) # Odświeżenie interfejsu
            messagebox.showinfo("Sukces", "Mod zainstalowany!")
        except Exception as e:
            messagebox.showerror("Błąd", f"Wystąpił błąd podczas pobierania:\n{str(e)}")

    def handle_toggle(mod, idx):
        file_path = os.path.join("BepInEx", "plugins", mod['file'])
        dis_path = file_path + ".disabled"
        if os.path.exists(file_path): os.rename(file_path, dis_path)
        elif os.path.exists(dis_path): os.rename(dis_path, file_path)
        select_mod(idx)

# --- NARZĘDZIA DODATKOWE ---
def open_tools_menu():
    tools_win = ctk.CTkToplevel(root)
    tools_win.title("Narzędzia Dodatkowe")
    tools_win.geometry("350x400")
    tools_win.resizable(False, False)
    tools_win.grab_set()
    
    ctk.CTkLabel(tools_win, text="Parsec (Gra Online)", font=("Arial", 14, "bold")).pack(pady=(20, 10))
    ctk.CTkButton(tools_win, text="Uruchom Web Parsec", command=lambda: webbrowser.open("https://web.parsec.app/")).pack(fill="x", padx=30, pady=5)
    ctk.CTkButton(tools_win, text="Pobierz aplikację Parsec", command=lambda: webbrowser.open("https://parsec.app/downloads")).pack(fill="x", padx=30, pady=5)
    ctk.CTkButton(tools_win, text="Instrukcja używania", fg_color="#34495e", hover_color="#2c3e50", command=show_parsec_instructions).pack(fill="x", padx=30, pady=5)
    
    ctk.CTkLabel(tools_win, text="Systemowe", font=("Arial", 14, "bold")).pack(pady=(20, 10))
    ctk.CTkButton(tools_win, text="Utwórz skróty (Pulpit/Start)", command=create_shortcuts, fg_color="#27ae60", hover_color="#2ecc71").pack(fill="x", padx=30, pady=5)
    ctk.CTkButton(tools_win, text="Zamknij okno", command=tools_win.destroy, fg_color="transparent", border_width=1).pack(fill="x", padx=30, pady=(15, 5))

def create_shortcuts():
    if sys.platform != 'win32':
        messagebox.showerror("Błąd", "Ta funkcja działa tylko w systemie Windows.")
        return
    try:
        exe_path = os.path.abspath(sys.argv[0])
        game_dir = os.path.dirname(exe_path)
        game_exe = os.path.join(game_dir, "SpiderHeck.exe")
        desktop = os.path.join(os.environ['USERPROFILE'], 'Desktop')
        start_menu = os.path.join(os.environ['APPDATA'], 'Microsoft', 'Windows', 'Start Menu', 'Programs')
        
        vbs_script = f"""
        Set oWS = WScript.CreateObject("WScript.Shell")
        sLinkFile = "{desktop}\\SpiderHeck Mod Manager.lnk"
        Set oLink = oWS.CreateShortcut(sLinkFile)
        oLink.TargetPath = "{exe_path}"
        oLink.WorkingDirectory = "{game_dir}"
        oLink.IconLocation = "{game_exe}, 0"
        oLink.Save
        sLinkFile2 = "{start_menu}\\SpiderHeck Mod Manager.lnk"
        Set oLink2 = oWS.CreateShortcut(sLinkFile2)
        oLink2.TargetPath = "{exe_path}"
        oLink2.WorkingDirectory = "{game_dir}"
        oLink2.IconLocation = "{game_exe}, 0"
        oLink2.Save
        """
        vbs_path = os.path.join(tempfile.gettempdir(), "makeshortcut.vbs")
        with open(vbs_path, "w", encoding="utf-8") as f: f.write(vbs_script)
        subprocess.run(["cscript", "//nologo", vbs_path], creationflags=0x08000000)
        messagebox.showinfo("Sukces", "Skróty z ikoną gry zostały pomyślnie dodane na Pulpit oraz do Menu Start!")
    except Exception as e:
        messagebox.showerror("Błąd", f"Nie udało się utworzyć skrótów:\n{e}")

def show_parsec_instructions():
    inst_text = (
        "--- JAK UŻYWAĆ PARSEC DO GRY SPIDERHECK ---\n\n"
        "1. HOST (Osoba u której odpalona jest gra z modem):\n"
        "   - Pobiera aplikację, zakłada konto i loguje się.\n"
        "   - W sekcji 'Friends' dodaje swoich znajomych.\n"
        "   - Uruchamia grę SpiderHeck.\n\n"
        "2. ZNAJOMI (Goście):\n"
        "   - Mogą użyć przeglądarki (Web Parsec) lub aplikacji.\n"
        "   - Logują się na konto i w sekcji 'Computers' klikają 'Connect'\n"
        "     przy komputerze Hosta.\n\n"
        "3. UPRAWNIENIA:\n"
        "   - Po dołączeniu gości, HOST klika ikonkę Parsec i upewnia się,\n"
        "     że goście mają włączone uprawnienia TYLKO do 'Gamepad'.\n"
        "   - Wyłączcie 'Keyboard' i 'Mouse'!"
    )
    messagebox.showinfo("Instrukcja Parsec", inst_text)

# --- INTERFEJS GRAFICZNY (GŁÓWNE OKNO) ---
root = ctk.CTk()
root.title(f"SpiderHeck Mod Manager")
root.geometry("450x620")
root.resizable(False, False)

# Próba wczytania własnej ikonki w starym standardzie tkinter
try:
    icon_path = os.path.join(tempfile.gettempdir(), "spidh_logo.png")
    if not os.path.exists(icon_path):
        download_file(f"{GITHUB_RAW_URL}/Site-logo.png", icon_path)
    icon_image = tk.PhotoImage(file=icon_path)
    root.wm_iconphoto(True, icon_image)
except Exception:
    pass

# Nagłówek
ctk.CTkLabel(root, text="SpiderHeck", font=("Arial", 26, "bold")).pack(pady=(20, 0))
ctk.CTkLabel(root, text=f"Mod Manager v{LOCAL_VERSION}", font=("Arial", 12), text_color="gray").pack(pady=(0, 15))

lbl_status = ctk.CTkLabel(root, text="Sprawdzanie statusu...", font=("Arial", 14, "bold"))
lbl_status.pack(pady=5)

btn_update = ctk.CTkButton(root, text="", fg_color="#f39c12", hover_color="#d68910", text_color="black", command=download_update)

# Ramka 1: ZARZĄDZANIE MODAMI
frame_mods = ctk.CTkFrame(root)
frame_mods.pack(fill="x", padx=25, pady=10)
ctk.CTkLabel(frame_mods, text="ZARZĄDZANIE MODAMI", font=("Arial", 11, "bold"), text_color="gray").pack(pady=5)
ctk.CTkButton(frame_mods, text="Otwórz Menedżer Modów", command=open_mod_manager, height=35).pack(fill="x", padx=15, pady=5)
ctk.CTkButton(frame_mods, text="Włącz / Wyłącz silnik (BepInEx)", command=toggle_bepinex, fg_color="#34495e", hover_color="#2c3e50", height=35).pack(fill="x", padx=15, pady=(5, 10))

# Ramka 2: GRA I NARZĘDZIA
frame_tools = ctk.CTkFrame(root)
frame_tools.pack(fill="x", padx=25, pady=10)
ctk.CTkLabel(frame_tools, text="GRA I NARZĘDZIA", font=("Arial", 11, "bold"), text_color="gray").pack(pady=5)
ctk.CTkButton(frame_tools, text="Uruchom grę", command=play_game, fg_color="#27ae60", hover_color="#2ecc71", height=35).pack(fill="x", padx=15, pady=5)
ctk.CTkButton(frame_tools, text="Otwórz folder z grą", command=open_game_folder, fg_color="#7f8c8d", hover_color="#95a5a6", height=35).pack(fill="x", padx=15, pady=5)
ctk.CTkButton(frame_tools, text="Kopia zapasowa zapisów", command=backup_saves, fg_color="#8e44ad", hover_color="#9b59b6", height=35).pack(fill="x", padx=15, pady=5)
ctk.CTkButton(frame_tools, text="Narzędzia Dodatkowe (Parsec, Skróty)", command=open_tools_menu, fg_color="#2980b9", hover_color="#3498db", height=35).pack(fill="x", padx=15, pady=(5, 10))

# Dolny pasek akcji
frame_bottom = ctk.CTkFrame(root, fg_color="transparent")
frame_bottom.pack(fill="x", padx=25, pady=10, side="bottom")
ctk.CTkButton(frame_bottom, text="TWARDY RESET", command=hard_reset, fg_color="#c0392b", hover_color="#e74c3c", width=150, height=35).pack(side="left")
ctk.CTkButton(frame_bottom, text="Wyjście", command=root.destroy, fg_color="transparent", border_width=1, width=120, height=35).pack(side="right")

update_status()
root.after(1000, check_update)
root.mainloop()
