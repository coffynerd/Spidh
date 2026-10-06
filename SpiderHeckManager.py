import tkinter as tk
from tkinter import messagebox
import urllib.request
import zipfile
import os
import sys
import tempfile
import subprocess
import webbrowser

# --- KONFIGURACJA ---
LOCAL_VERSION = "1.1.11"
GITHUB_RAW_URL = "https://raw.githubusercontent.com/coffynerd/Spidh/main"
GITHUB_EXE_URL = "https://github.com/coffynerd/Spidh/raw/main/SpiderHeckManager.exe"

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

def install_mod():
    try:
        messagebox.showinfo("Pobieranie", "Rozpoczynam pobieranie plików. Kliknij OK i poczekaj chwilę - program może na moment przestać odpowiadać.")
        
        bepinex_url = "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip"
        mod_url = "https://github.com/Senyksia/InfiniteFriends/releases/latest/download/InfiniteFriends_BepInEx.zip"
        
        urllib.request.urlretrieve(bepinex_url, "bepinex.zip")
        urllib.request.urlretrieve(mod_url, "mod.zip")
        
        with zipfile.ZipFile("bepinex.zip", 'r') as zip_ref:
            zip_ref.extractall(".")
        with zipfile.ZipFile("mod.zip", 'r') as zip_ref:
            zip_ref.extractall(".")
            
        os.remove("bepinex.zip")
        os.remove("mod.zip")
        
        if os.path.exists("winhttp.dll.disabled"):
            os.rename("winhttp.dll.disabled", "winhttp.dll")
            
        update_status()
        messagebox.showinfo("Sukces", "Instalacja zakończona pomyślnie!\nPamiętaj o parametrach uruchamiania w Steam.")
    except Exception as e:
        messagebox.showerror("Błąd", f"Wystąpił błąd podczas instalacji:\n{e}")

def toggle_mod():
    if os.path.exists("winhttp.dll"):
        os.rename("winhttp.dll", "winhttp.dll.disabled")
        messagebox.showinfo("Status", "Mod został WYŁĄCZONY (Gra uruchomi się bez limitów).")
    elif os.path.exists("winhttp.dll.disabled"):
        os.rename("winhttp.dll.disabled", "winhttp.dll")
        messagebox.showinfo("Status", "Mod został WŁĄCZONY.")
    else:
        messagebox.showwarning("Status", "Mod nie jest jeszcze zainstalowany!")
    update_status()

def play_game():
    webbrowser.open("steam://rungameid/1329500")

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
    
    # Próba załadowania ikony również dla podokna
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

def update_status():
    if os.path.exists("winhttp.dll"):
        lbl_status.config(text="Status Moda: WŁĄCZONY", fg="green")
    elif os.path.exists("winhttp.dll.disabled"):
        lbl_status.config(text="Status Moda: WYŁĄCZONY", fg="red")
    else:
        lbl_status.config(text="Status Moda: NIEZAINSTALOWANY", fg="orange")

# --- INTERFEJS GRAFICZNY (GŁÓWNE OKNO) ---
root = tk.Tk()
root.title(f"SpiderHeck Mod Manager (Windows)")
root.geometry("380x520")
root.resizable(False, False)

# --- ŁADOWANIE IKONY PROGRAMU ---
try:
    icon_path = os.path.join(tempfile.gettempdir(), "spidh_logo.png")
    if not os.path.exists(icon_path):
        urllib.request.urlretrieve(f"{GITHUB_RAW_URL}/Site-logo.png", icon_path)
    icon_image = tk.PhotoImage(file=icon_path)
    root.iconphoto(True, icon_image)
except Exception:
    pass  # Jeśli nie uda się pobrać, aplikacja uruchomi się z domyślną ikonką

tk.Label(root, text="SpiderHeck", font=("Arial", 16, "bold")).pack(pady=(15, 0))
tk.Label(root, text=f"InfiniteFriends Manager v{LOCAL_VERSION}", font=("Arial", 10)).pack(pady=(0, 15))

lbl_status = tk.Label(root, text="Sprawdzanie statusu...", font=("Arial", 11, "bold"))
lbl_status.pack(pady=5)

# Przycisk aktualizacji
btn_update = tk.Button(root, text="", command=download_update, width=35, height=2, bg="#a5d6a7", font=("Arial", 9, "bold"))

btn_install = tk.Button(root, text="1. Zainstaluj / Zaktualizuj modyfikację", command=install_mod, width=35, height=2, bg="#e0e0e0")
btn_install.pack(pady=4)

btn_toggle = tk.Button(root, text="2. Włącz / Wyłącz moda", command=toggle_mod, width=35, height=2, bg="#e0e0e0")
btn_toggle.pack(pady=4)

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
