@echo off
:: Se placer dans le répertoire du script
cd /d "%~dp0"

echo Lancement du script d'installation des raccourcis...
echo.

:: Lancer le script PowerShell en contournant la politique d'exécution
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "createShortcuts.ps1"

:: Si une erreur fatale empêche même le lancement de PowerShell
if %errorlevel% neq 0 (
    echo.
    echo Une erreur est survenue lors du lancement de PowerShell.
    pause
)
