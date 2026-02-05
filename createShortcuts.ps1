# Définir le chemin vers le script main.ps1 (dans le même dossier)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path $scriptDir "main.ps1"

# Vérifier que le fichier main.ps1 existe
if (-Not (Test-Path $mainScript)) {
  Write-Host "Le fichier main.ps1 n'a pas été trouvé dans le répertoire courant !" -ForegroundColor Red
  exit
}

# Créer le dossier "shortcuts" dans le même répertoire que main.ps1
$shortcutsDir = Join-Path $scriptDir "shortcuts"
if (-Not (Test-Path $shortcutsDir)) {
  New-Item -ItemType Directory -Path $shortcutsDir | Out-Null
  Write-Host "Dossier 'shortcuts' créé dans : $shortcutsDir" -ForegroundColor Green
}

# Initialiser l'objet WScript.Shell
$shell = New-Object -ComObject WScript.Shell

# Rechercher le fichier .ico le plus récent dans le dossier
$iconFile = Get-ChildItem -Path $scriptDir -Filter "*.ico" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($iconFile) {
  $iconPath = $iconFile.FullName
  Write-Host "Icône trouvée : $($iconFile.Name)" -ForegroundColor Cyan
}

# Créer un raccourci pour PowerShell 7
$pwsh7Path = "C:\Program Files\PowerShell\7\pwsh.exe"
if (Test-Path $pwsh7Path) {
  $shortcutPathPwsh7 = Join-Path $shortcutsDir "Open Folder (PowerShell 7).lnk"
  
  # Supprimer l'ancien raccourci s'il existe pour forcer le rafraîchissement
  if (Test-Path $shortcutPathPwsh7) {
    Remove-Item $shortcutPathPwsh7 -Force
  }

  $shortcut = $shell.CreateShortcut($shortcutPathPwsh7)
  $shortcut.TargetPath = $pwsh7Path
  $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$mainScript`""
  $shortcut.WorkingDirectory = $scriptDir
  if ($iconFile) {
    $shortcut.IconLocation = $iconPath
  }
  $shortcut.Save()
  Write-Host "Raccourci pour PowerShell 7 créé dans : $shortcutPathPwsh7" -ForegroundColor Green
}
else {
  Write-Host "PowerShell 7 n'est pas installé sur ce système." -ForegroundColor Yellow
}

# Créer un raccourci pour PowerShell 5.1
$pwsh51Path = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
if (Test-Path $pwsh51Path) {
  $shortcutPathPwsh51 = Join-Path $shortcutsDir "Open Folder (PowerShell 5.1).lnk"

  # Supprimer l'ancien raccourci s'il existe pour forcer le rafraîchissement
  if (Test-Path $shortcutPathPwsh51) {
    Remove-Item $shortcutPathPwsh51 -Force
  }

  $shortcut = $shell.CreateShortcut($shortcutPathPwsh51)
  $shortcut.TargetPath = $pwsh51Path
  $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$mainScript`""
  $shortcut.WorkingDirectory = $scriptDir
  if ($iconFile) {
    $shortcut.IconLocation = $iconPath
  }
  $shortcut.Save()
  Write-Host "Raccourci pour PowerShell 5.1 créé dans : $shortcutPathPwsh51" -ForegroundColor Green
}
else {
  Write-Host "PowerShell 5.1 n'est pas installé ou n'a pas été trouvé." -ForegroundColor Yellow
}
