import tkinter as tk
from tkinter import messagebox
import urllib.request
import zipfile
import os
import webbrowser

# --- KONFIGURACJA ---
LOCAL_VERSION = "1.1.7"
GITHUB_RAW_URL = "https://raw.githubusercontent.com/coffynerd/Spidh/main"

def check_update():
    try:
        req = urllib.request.Request(f"{GITHUB_RAW_URL}/version_win.txt", headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=3) as response:
            remote_version = response.read().decode('utf-8').strip()
            if remote_version and remote_version != LOCAL_VERSION:
                messagebox.showinfo("Aktualizacja", f"Dostępna jest nowa wersja: {remote_version}!\nPobierz ją z GitHuba.")
    except Exception:
        pass

def install_mod():
    try:
        messagebox.showinfo("Pobieranie", "Rozpoczynam pobieranie plików. Kliknij OK i poczekaj chwilę...")
        
        # Pobieranie
        bepinex_url = "https://github.com/BepInEx/BepInEx/releases/download/v5.4.22/BepInEx_x64_5.4.22.0.zip"
        mod_url = "https://github.com/Senyksia/InfiniteFriends/releases/latest/download/InfiniteFriends_BepInEx.zip"
        
        urllib.request.urlretrieve(bepinex_url, "bepinex.zip")
        urllib.request.urlretrieve(mod_url, "mod.zip")
        
        # Rozpakowywanie
        with zipfile.ZipFile("bepinex.zip", 'r') as zip_ref:
            zip_ref.extractall(".")
        with zipfile.ZipFile("mod.zip", 'r') as zip_ref:
            zip_ref.extractall(".")
            
        # Sprzątanie
        os.remove("bepinex.zip")
        os.remove("mod.zip")
        
        # Naprawa statusu
        if os.path.exists("winhttp.dll.disabled"):
            os.rename("winhttp.dll.disabled", "winhttp.dll")
            
        update_status()
        messagebox.showinfo("Sukces", "Mod InfiniteFriends został zainstalowany pomyślnie!")
    except Exception as e:
        messagebox.showerror("Błąd", f"Wystąpił błąd podczas instalacji:\n{e}")

def toggle_mod():
    if os.path.exists("winhttp.dll"):
        os.rename("winhttp.dll", "winhttp.dll.disabled")
        messagebox.showinfo("Status", "Mod został WYŁĄCZONY (Gra uruchomi się bez limitów usuniętych).")
    elif os.path.exists("winhttp.dll.disabled"):
        os.rename("winhttp.dll.disabled", "winhttp.dll")
        messagebox.showinfo("Status", "Mod został WŁĄCZONY.")
    else:
        messagebox.showwarning("Status", "Mod nie jest jeszcze zainstalowany!")
    update_status()

def play_game():
    webbrowser.open("steam://rungameid/1329500")

def open_parsec():
    webbrowser.open("https://web.parsec.app/")

def update_status():
    if os.path.exists("winhttp.dll"):
        lbl_status.config(text="Status Moda: WŁĄCZONY", fg="green")
    elif os.path.exists("winhttp.dll.disabled"):
        lbl_status.config(text="Status Moda: WYŁĄCZONY", fg="red")
    else:
        lbl_status.config(text="Status Moda: NIEZAINSTALOWANY", fg="orange")

# --- INTERFEJS GRAFICZNY ---
root = tk.Tk()
root.title(f"SpiderHeck Mod Manager v{LOCAL_VERSION}")
root.geometry("350x400")
root.resizable(False, False)

tk.Label(root, text="SpiderHeck", font=("Arial", 16, "bold")).pack(pady=(15, 0))
tk.Label(root, text="InfiniteFriends Manager", font=("Arial", 10)).pack(pady=(0, 15))

lbl_status = tk.Label(root, text="Sprawdzanie statusu...", font=("Arial", 11, "bold"))
lbl_status.pack(pady=10)

btn_install = tk.Button(root, text="Zainstaluj / Zaktualizuj Moda", command=install_mod, width=30, height=2, bg="#e0e0e0")
btn_install.pack(pady=5)

btn_toggle = tk.Button(root, text="Włącz / Wyłącz Moda", command=toggle_mod, width=30, height=2, bg="#e0e0e0")
btn_toggle.pack(pady=5)

btn_play = tk.Button(root, text="Uruchom Grę", command=play_game, width=30, height=2, bg="#c8e6c9")
btn_play.pack(pady=5)

btn_parsec = tk.Button(root, text="Uruchom Parsec (Gra Online)", command=open_parsec, width=30, height=2, bg="#bbdefb")
btn_parsec.pack(pady=5)

update_status()
root.after(1000, check_update) # Sprawdza aktualizacje sekunde po włączeniu
root.mainloop()
