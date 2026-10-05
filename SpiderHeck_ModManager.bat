@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Aktualizacja SpiderHeck Mod Manager

if not exist "SpiderHeck_ModManager.ps1" (
    echo Przygotowywanie nowego systemu PowerShell...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/coffynerd/Spidh/main/SpiderHeck_ModManager.ps1' -OutFile 'SpiderHeck_ModManager.ps1'"
)

powershell -NoProfile -ExecutionPolicy Bypass -File "SpiderHeck_ModManager.ps1"