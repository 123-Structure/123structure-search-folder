# Script de création de raccourci - Version Robuste
try {
  # Définir le chemin vers le script main.ps1 (dans le même dossier)
  $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
  $mainScript = Join-Path $scriptDir "main.ps1"

  Write-Host "Dossier du script : $scriptDir"
  Write-Host "Script cible : $mainScript"

  # Vérifier que le fichier main.ps1 existe
  if (-Not (Test-Path $mainScript)) {
    throw "Le fichier main.ps1 n'a pas été trouvé dans le répertoire courant !"
  }

  # Initialiser l'objet WScript.Shell
  $shell = New-Object -ComObject WScript.Shell

  # Rechercher le fichier .ico le plus récent dans le dossier
  $iconFile = Get-ChildItem -Path $scriptDir -Filter "*.ico" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $iconPath = ""

  if ($iconFile) {
    Write-Host "Icône trouvée : $($iconFile.Name)"
    # Copier l'icône en local (AppData) pour garantir qu'elle s'affiche même depuis un NAS
    $localIconDir = "$env:LOCALAPPDATA\123Structure"
    if (-not (Test-Path $localIconDir)) {
      New-Item -ItemType Directory -Path $localIconDir -Force | Out-Null
    }
        
    $localIconPath = Join-Path $localIconDir $iconFile.Name
    Copy-Item -Path $iconFile.FullName -Destination $localIconPath -Force
        
    $iconPath = $localIconPath
    Write-Host "Icône copiée localement : $localIconPath" -ForegroundColor Cyan
  }
  else {
    Write-Host "Aucune icône (.ico) trouvée dans le dossier." -ForegroundColor Gray
  }

  # Déterminer quel exécutable PowerShell utiliser (Priorité à PS7)
  $pwsh7Path = "C:\Program Files\PowerShell\7\pwsh.exe"
  $pwsh51Path = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
  $targetPwsh = ""
  $pwshVersion = ""

  Write-Host "Recherche de PowerShell..."

  if (Test-Path $pwsh7Path) {
    $targetPwsh = $pwsh7Path
    $pwshVersion = "7"
    Write-Host "✅ PowerShell 7 détecté à : $pwsh7Path" -ForegroundColor Green
  }
  elseif (Test-Path $pwsh51Path) {
    $targetPwsh = $pwsh51Path
    $pwshVersion = "5.1"
    Write-Host "⚠️ PowerShell 7 non trouvé." -ForegroundColor Yellow
    Write-Host "✅ PowerShell 5.1 détecté à : $pwsh51Path" -ForegroundColor Green
  }
  else {
    # Tentative de secours via Get-Command
    try {
      $cmd = Get-Command powershell
      $targetPwsh = $cmd.Source
      $pwshVersion = "5.1 (Auto-détecté)"
      Write-Host "✅ PowerShell trouvé via PATH : $targetPwsh" -ForegroundColor Green
    }
    catch {
      throw "Aucune version de PowerShell compatible n'a été trouvée !"
    }
  }

  # Définir le chemin du raccourci sur le Bureau
  $desktopPath = [Environment]::GetFolderPath("Desktop")
  $shortcutName = "Recherche 123 STRUCTURE.lnk"
  $desktopShortcutPath = Join-Path $desktopPath $shortcutName

  Write-Host "Création du raccourci sur le Bureau : $desktopShortcutPath"

  # Supprimer l'ancien raccourci s'il existe pour forcer le rafraîchissement
  if (Test-Path $desktopShortcutPath) {
    Remove-Item $desktopShortcutPath -Force
    Write-Host "Ancien raccourci supprimé." -ForegroundColor Gray
  }

  # Créer le raccourci directement sur le Bureau
  $shortcut = $shell.CreateShortcut($desktopShortcutPath)
  $shortcut.TargetPath = $targetPwsh
  $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$mainScript`""
  $shortcut.WorkingDirectory = $scriptDir
  if ($iconPath) {
    $shortcut.IconLocation = $iconPath
  }
  $shortcut.Save()

  Write-Host ""
  Write-Host "✅ Raccourci créé sur le Bureau avec succès !" -ForegroundColor Green
  Write-Host "Version utilisée : PowerShell $pwshVersion"
  Write-Host "Emplacement : $desktopShortcutPath"
  Write-Host "========================================================================"

  # Nettoyage : Supprimer le dossier 'shortcuts' du projet s'il existe (nettoyage de l'ancienne version)
  $shortcutsDir = Join-Path $scriptDir "shortcuts"
  if (Test-Path $shortcutsDir) {
    Remove-Item $shortcutsDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "🧹 Ancien dossier 'shortcuts' supprimé du projet." -ForegroundColor Gray
  }

}
catch {
  Write-Host ""
  Write-Host "❌ UNE ERREUR EST SURVENUE :" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Red
  Write-Host ""
  Write-Host "Détails de l'erreur :"
  Write-Host $_.ScriptStackTrace -ForegroundColor Gray
}

# Pause pour laisser le temps de lire le message uniquement en cas d'erreur
if ($Error.Count -gt 0) {
  Write-Host ""
  Read-Host "Appuyez sur Entrée pour quitter..."
}
