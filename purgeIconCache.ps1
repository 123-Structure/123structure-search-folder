# Script pour purger le cache des icônes de Windows
# Attention : L'explorateur Windows va redémarrer, votre barre des tâches va disparaître quelques secondes.

Write-Host "⚠️  Attention : Ce script va redémarrer l'Explorateur Windows." -ForegroundColor Yellow
Write-Host "La barre des tâches va disparaître momentanément."
Start-Sleep -Seconds 2

# 1. Arrêter l'Explorateur Windows
Write-Host "🛑 Arrêt de l'Explorateur Windows..." -ForegroundColor Red
Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue

# Attendre un peu que les verrous sur les fichiers soient libérés
Start-Sleep -Seconds 2

# 2. Supprimer le fichier IconCache.db principal
$iconCachePath = "$env:LOCALAPPDATA\IconCache.db"
if (Test-Path $iconCachePath) {
    Write-Host "🗑️  Suppression de $iconCachePath" -ForegroundColor Cyan
    Remove-Item -Path $iconCachePath -Force -ErrorAction SilentlyContinue
}

# 3. Supprimer les fichiers de cache explorer
$explorerCachePath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*.db"
Write-Host "🗑️  Nettoyage du dossier de cache étendu..." -ForegroundColor Cyan
Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\" -Filter "iconcache*.db" | ForEach-Object {
    Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
}
Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\" -Filter "thumbcache*.db" | ForEach-Object {
    Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
}

# 4. Redémarrer l'Explorateur
Write-Host "✅ Redémarrage de l'Explorateur Windows..." -ForegroundColor Green
Start-Process explorer

Write-Host "Terminé ! Le cache a été purgé." -ForegroundColor Green
