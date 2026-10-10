import tkinter as tk
from tkinter import messagebox
import urllib.request
import zipfile
import os
import sys
import tempfile
import subprocess
import webbrowser

# --- KONFIGURACJA GŁÓWNA ---
LOCAL_VERSION = "1.2.0"
GITHUB_RAW_URL = "https://raw.githubusercontent.com/coffynerd/Spidh/main"
GITHUB_EXE_URL = "https://github.com/coffynerd/Spidh/raw/main/SpiderHeckManager.exe"

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
                btn_update.config(text=f"⚠️ Dostępna aktualizacja ({remote_version}) - Kliknij tutaj")
    except Exception:
        pass

def download_update():
    try:
        messagebox.showinfo("Aktualizacja", "Rozpoczynam pobieranie nowej wersji. Program zrestartuje się automatycznie.\nKliknij OK i poczekaj.")
        
        current_exe = sys.executable
        exe_dir = os.path.dirname(current_exe)
        new_exe = os.path.join(exe_dir, "update_temp.exe")
        
        urllib.request.urlretrieve(GITHUB_EXE_URL, new_exe)
        
        bat_path = os.path.join(tempfile.gettempdir(), "spidh_updater.bat")
        bat_content = f"""@echo off
timeout /t 2 /nobreak >nul
del "{current_exe}"
ren "{new_exe}" "{os.path.basename(current_exe)}"
start "" "{current_exe}"
del "%~f0"
"""
        with open(bat_path, "w", encoding="utf-8") as f:
            f.write(bat_content)
            
        creationflags = 0x08000000 if os.name == 'nt' else 0
        subprocess.Popen(["cmd.exe", "/c", bat_path], creationflags=creationflags)
        root.destroy()
        sys.exit()
        
    except Exception as e:
        messagebox.showerror("Błąd", f"Nie udało się zaktualizować programu:\n{e}")

# --- MECHANIKI BAZOWE ---
def get_mod_status(mod):
    file_path = os.path.join("BepInEx", "plugins", mod['file'])
    dis_file_path = file_path + ".disabled"
    if os.path.exists(file_path):
        return "WŁĄCZONY", "green"
    elif os.path.exists(dis_file_path):
        return "WYŁĄCZONY", "red"
    else:
        return "NIEZAINSTALOWANY", "gray"

def install_bepinex():
    try:
        messagebox.showinfo("Instalacja", "Rozpoczynam pobieranie silnika BepInEx.\nKliknij OK i poczekaj chwilę - program może na moment przestać odpowiadać.")
        
        bepinex_url = "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip"
        urllib.request.urlretrieve(bepinex_url, "bepinex.zip")
        
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

def update_status():
    if os.path.exists("winhttp.dll"):
        lbl_status.config(text="Status Silnika Modów (BepInEx): WŁĄCZONY", fg="green")
    elif os.path.exists("winhttp.dll.disabled"):
        lbl_status.config(text="Status Silnika Modów (BepInEx): WYŁĄCZONY", fg="red")
    else:
        lbl_status.config(text="Status Silnika Modów (BepInEx): NIEZAINSTALOWANY", fg="orange")

# --- MENEDŻER MODÓW (NOWE OKNO) ---
def open_mod_manager():
    mod_win = tk.Toplevel(root)
    mod_win.title("Menedżer Modów")
    mod_win.geometry("640x480")
    mod_win.resizable(False, False)
    
    try:
        icon_path = os.path.join(tempfile.gettempdir(), "spidh_logo.png")
        icon_image = tk.PhotoImage(file=icon_path)
        mod_win.iconphoto(False, icon_image)
    except:
        pass

    # Lewy panel z listą
    frame_left = tk.Frame(mod_win, width=220)
    frame_left.pack(side=tk.LEFT, fill=tk.Y, padx=10, pady=10)
    
    # Prawy panel ze szczegółami
    frame_right = tk.Frame(mod_win)
    frame_right.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=10, pady=10)

    tk.Label(frame_left, text="Dostępne modyfikacje:", font=("Arial", 11, "bold")).pack(anchor=tk.W)
    
    listbox = tk.Listbox(frame_left, width=30, height=22, font=("Arial", 10), selectbackground="#bbdefb", selectforeground="black")
    listbox.pack(side=tk.LEFT, fill=tk.Y)
    
    scrollbar = tk.Scrollbar(frame_left, command=listbox.yview)
    scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    listbox.config(yscrollcommand=scrollbar.set)
    
    for mod in MODS:
        listbox.insert(tk.END, mod['name'])
        
    # Elementy prawego panelu
    lbl_name = tk.Label(frame_right, text="Wybierz moda z listy po lewej", font=("Arial", 14, "bold"))
    lbl_name.pack(anchor=tk.NW, pady=(0, 10))
    
    lbl_desc = tk.Label(frame_right, text="", font=("Arial", 10), justify=tk.LEFT, wraplength=350)
    lbl_desc.pack(anchor=tk.NW, fill=tk.X, pady=(0, 15))
    
    lbl_mod_status = tk.Label(frame_right, text="", font=("Arial", 11, "bold"))
    lbl_mod_status.pack(anchor=tk.NW, pady=(0, 15))
    
    btn_install = tk.Button(frame_right, text="Zainstaluj / Aktualizuj (Pobierz)", width=32, height=2, bg="#a5d6a7", state=tk.DISABLED)
    btn_install.pack(anchor=tk.NW, pady=5)
    
    btn_toggle = tk.Button(frame_right, text="Włącz / Wyłącz moda", width=32, height=2, bg="#e0e0e0", state=tk.DISABLED)
    btn_toggle.pack(anchor=tk.NW, pady=5)
    
    tk.Label(frame_right, text="----------------------------------------------------------").pack(anchor=tk.NW, pady=(15, 10))
    
    btn_bepinex = tk.Button(frame_right, text="B. Zainstaluj/Zaktualizuj silnik BepInEx", command=install_bepinex, width=32, height=2, bg="#fff9c4")
    btn_bepinex.pack(anchor=tk.NW)

    # Akcje po kliknięciu na liście
    def on_select(event):
        selection = listbox.curselection()
        if not selection:
            return
        idx = selection[0]
        mod = MODS[idx]
        
        lbl_name.config(text=mod['name'])
        lbl_desc.config(text=f"Opis:\n{mod['desc']}")
        
        status, color = get_mod_status(mod)
        lbl_mod_status.config(text=f"Status w grze: {status}", fg=color)
        
        btn_install.config(state=tk.NORMAL, command=lambda: handle_install(mod, idx))
        
        if status == "NIEZAINSTALOWANY":
            btn_toggle.config(state=tk.DISABLED)
        else:
            btn_toggle.config(state=tk.NORMAL, command=lambda: handle_toggle(mod, idx))

    listbox.bind('<<ListboxSelect>>', on_select)
    
    def handle_install(mod, idx):
        if "LINK_DO_" in mod['url']:
            messagebox.showerror("Błąd", "Link do pobrania tego moda nie został jeszcze skonfigurowany w kodzie programu!")
            return
            
        try:
            messagebox.showinfo("Pobieranie", f"Rozpoczęto pobieranie: {mod['name']}...\nKliknij OK i poczekaj.")
            os.makedirs(os.path.join("BepInEx", "plugins"), exist_ok=True)
            
            if mod['is_zip']:
                temp_zip = "temp_mod.zip"
                urllib.request.urlretrieve(mod['url'], temp_zip)
                with zipfile.ZipFile(temp_zip, 'r') as zip_ref:
                    zip_ref.extractall(".")
                os.remove(temp_zip)
            else:
                target_path = os.path.join("BepInEx", "plugins", mod['file'])
                urllib.request.urlretrieve(mod['url'], target_path)
                
            # Jeśli mod miał wyłączoną starą wersję, kasujemy ją
            dis_path = os.path.join("BepInEx", "plugins", mod['file'] + ".disabled")
            if os.path.exists(dis_path):
                os.remove(dis_path)
                
            # Odświeżenie interfejsu
            listbox.selection_set(idx)
            on_select(None)
            messagebox.showinfo("Sukces", "Mod zainstalowany!")
        except Exception as e:
            messagebox.showerror("Błąd", f"Wystąpił błąd podczas pobierania:\n{str(e)}")

    def handle_toggle(mod, idx):
        file_path = os.path.join("BepInEx", "plugins", mod['file'])
        dis_path = file_path + ".disabled"
        
        if os.path.exists(file_path):
            os.rename(file_path, dis_path)
        elif os.path.exists(dis_path):
            os.rename(dis_path, file_path)
            
        listbox.selection_set(idx)
        on_select(None)

# --- TWORZENIE SKRÓTÓW I PARSEC ---
def create_shortcuts():
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
        with open(vbs_path, "w", encoding="utf-8") as f:
            f.write(vbs_script)
            
        creationflags = 0x08000000 if os.name == 'nt' else 0
        subprocess.run(["cscript", "//nologo", vbs_path], creationflags=creationflags)
        
        messagebox.showinfo("Sukces", "Skróty z ikoną gry zostały pomyślnie dodane na Pulpit oraz do Menu Start!")
    except Exception as e:
        messagebox.showerror("Błąd", f"Nie udało się utworzyć skrótów:\n{e}")

def show_parsec_menu():
    parsec_win = tk.Toplevel(root)
    parsec_win.title("Menu Parsec")
    parsec_win.geometry("350x300")
    parsec_win.resizable(False, False)
    
    try:
        icon_path = os.path.join(tempfile.gettempdir(), "spidh_logo.png")
        icon_image = tk.PhotoImage(file=icon_path)
        parsec_win.iconphoto(False, icon_image)
    except:
        pass

    tk.Label(parsec_win, text="Narzędzia Parsec", font=("Arial", 14, "bold")).pack(pady=(15, 10))
    
    tk.Button(parsec_win, text="1. Uruchom Web Parsec (Przeglądarka)", command=lambda: webbrowser.open("https://web.parsec.app/"), width=35, height=2, bg="#bbdefb").pack(pady=4)
    tk.Button(parsec_win, text="2. Pobierz aplikację Parsec", command=lambda: webbrowser.open("https://parsec.app/downloads"), width=35, height=2, bg="#bbdefb").pack(pady=4)
    tk.Button(parsec_win, text="3. Instrukcja używania", command=show_parsec_instructions, width=35, height=2, bg="#e0e0e0").pack(pady=4)
    tk.Button(parsec_win, text="4. Cofnij (Zamknij)", command=parsec_win.destroy, width=35, height=2, bg="#ffcdd2").pack(pady=4)

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
        "   - Wyłączcie 'Keyboard' i 'Mouse', żeby goście nie klikali po systemie!"
    )
    messagebox.showinfo("Instrukcja Parsec", inst_text)

# --- INTERFEJS GRAFICZNY (GŁÓWNE OKNO) ---
root = tk.Tk()
root.title(f"SpiderHeck Mod Manager (Windows)")
root.geometry("380x520")
root.resizable(False, False)

try:
    icon_path = os.path.join(tempfile.gettempdir(), "spidh_logo.png")
    if not os.path.exists(icon_path):
        urllib.request.urlretrieve(f"{GITHUB_RAW_URL}/Site-logo.png", icon_path)
    icon_image = tk.PhotoImage(file=icon_path)
    root.iconphoto(True, icon_image)
except Exception:
    pass

tk.Label(root, text="SpiderHeck", font=("Arial", 16, "bold")).pack(pady=(15, 0))
tk.Label(root, text=f"Mod Manager v{LOCAL_VERSION}", font=("Arial", 10)).pack(pady=(0, 15))

lbl_status = tk.Label(root, text="Sprawdzanie statusu...", font=("Arial", 11, "bold"))
lbl_status.pack(pady=5)

btn_update = tk.Button(root, text="", command=download_update, width=35, height=2, bg="#a5d6a7", font=("Arial", 9, "bold"))

btn_mods = tk.Button(root, text="1. Zarządzaj Modami (Instalacja, opisy)", command=open_mod_manager, width=35, height=2, bg="#e0e0e0")
btn_mods.pack(pady=4)

btn_toggle_engine = tk.Button(root, text="2. Włącz / Wyłącz WSZYSTKIE mody naraz", command=toggle_bepinex, width=35, height=2, bg="#e0e0e0")
btn_toggle_engine.pack(pady=4)

btn_play = tk.Button(root, text="3. Uruchom grę", command=play_game, width=35, height=2, bg="#c8e6c9")
btn_play.pack(pady=4)

btn_shortcut = tk.Button(root, text="4. Dodaj skrót (Pulpit i Menu Start)", command=create_shortcuts, width=35, height=2, bg="#fff9c4")
btn_shortcut.pack(pady=4)

btn_parsec = tk.Button(root, text="5. Narzędzia Parsec (Gra online)", command=show_parsec_menu, width=35, height=2, bg="#bbdefb")
btn_parsec.pack(pady=4)

btn_exit = tk.Button(root, text="6. Wyjście", command=root.destroy, width=35, height=2, bg="#ffcdd2")
btn_exit.pack(pady=4)

update_status()
root.after(1000, check_update)
root.mainloop()
