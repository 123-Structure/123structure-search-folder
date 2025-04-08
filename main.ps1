# Inclure les scripts utilitaires
. .\lib\utils.ps1
. .\lib\monthMap.ps1
. .\lib\folderSearch.ps1
. .\lib\accentHandler.ps1

# Définir l'encodage de sortie
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$driveY = "O:"
$driveL = "Y:\123 STRUCTURE"

Write-Host @"
 _ ____  _____   ____  _                   _                  
/ |___ \|___ /  / ___|| |_ _ __ _   _  ___| |_ _   _ _ __ ___ 
| | __) | |_ \  \___ \| __| '__| | | |/ __| __| | | | '__/ _ \
| |/ __/ ___) |  ___) | |_| |  | |_| | (__| |_| |_| | | |  __/
|_|_____|____/  |____/ \__|_|   \__,_|\___|\__|\__,_|_|  \___|
"@ -ForegroundColor Yellow

if ($PSVersionTable.PSVersion.Major -lt 7) {
  $warningMessage = Format-AccentedChars "Ce script peut afficher incorrectement les caractères accentués dans PowerShell 5.1 ou inférieur. Pour une meilleure expérience, utilisez PowerShell 7 ou une version ultérieure."
  Write-Host ""
  Write-Warning $warningMessage
  Write-Host ""
  
  $downloadMessage = Format-AccentedChars "Vous pouvez télécharger PowerShell 7 ici : https://github.com/PowerShell/PowerShell/releases/latest ou exécuter la commande suivante :"
  Write-Host ""
  Write-Host $downloadMessage -ForegroundColor Cyan
  Write-Host "winget install --id Microsoft.PowerShell --source winget" -ForegroundColor Green
  Write-Host ""
}

# Boucle jusqu'à ce qu'un numéro de projet valide soit saisi ou que l'utilisateur tape "exit"
while ($true) {
  # Demander à l'utilisateur de saisir le numéro de projet
  Write-Host ""
  $projectNumber = Read-Host -Prompt "Veuillez saisir le numéro de projet (ou tapez 'exit' pour quitter) "

  if ($projectNumber -eq "exit") {
    Write-Host ""
    Write-Host "Fermeture du script." -ForegroundColor Yellow
    exit
  }

  if ($projectNumber -eq "") {
    Write-Host ""
    Write-Host "Le numéro de projet est obligatoire" -ForegroundColor Red
    Write-Host ""
    continue
  }

  # Vérifier si le numéro de projet est valide pour l'ancienne ou la nouvelle numérotation
  if (-not (Test-ProjectNumber -projectNumber $projectNumber)) {
    Write-Host ""
    Write-Host "Le format du numéro de projet est invalide. Utilisez le format 00.00.000A (ancienne numérotation) ou 00000000 (nouvelle numérotation)." -ForegroundColor Red
    Write-Host ""
    continue
  }

  # Déterminer si c'est une ancienne ou nouvelle numérotation
  $oldFormatRegex = '^\d{2}\.\d{2}\.\d{3}[A-Z]$'
  $newFormatRegex = '^\d{4}\d{4}$'

  $isOldFormat = $projectNumber -match $oldFormatRegex
  $isNewFormat = $projectNumber -match $newFormatRegex

  # Log le numéro de projet
  Write-Host ""
  Write-Host "========================================================================"
  Write-Host "Numéro de projet: $projectNumber"
  Write-Host "========================================================================"

  if ($isOldFormat) {
    # Définir les partages réseaux en fonction de la dernière lettre
    $lastChar = $projectNumber[-1]
    $drive = ""
  
    switch ($lastChar) {
      'L' {
        $drive = $driveL
      }
      'U' {
        $drive = $driveL
      }
      'Y' {
        $drive = $driveY
      }
      default {
        Write-Host "Suffixe du projet invalide." -ForegroundColor Red
        Write-Host ""
        continue
      }
    }
  
    # Extraire l'année et le mois du numéro de projet
    $yearAndMonth = Get-YearAndMonth -projectNumber $projectNumber
    $year = $yearAndMonth[0]
    $monthNumber = $yearAndMonth[1]
  
    # Récupérer le dernier chiffre avant la lettre
    $projectTypeNumber = Get-ProjectTypeNumber -projectNumber $projectNumber
  
    if (-not $projectTypeNumber) {
      Write-Host "Erreur: le numéro de projet doit comporter 10 ou 11 caractères." -ForegroundColor Red
      continue
    }
  
    # Log de l'année et du numéro de mois
    Write-Host "Année: $year"
  
    # Récupérer le mois formaté avec le bon index
    $month = $monthMap[$monthNumber - 1]
  
    # Vérifier si le mois est valide
    if (-not $month) {
      Write-Host "Mois invalide pour le numéro donné." -ForegroundColor Red
      continue
    }
  
    Write-Host "Mois: $month"
  
    # Correspondance entre le dernier chiffre et les sous-dossiers
    $folderMap = @{
      '3' = "Béton (3)"
      '4' = "Charpente (4)"
      '7' = "Diagnostic (7)"
      '9' = "Maison (9)"
    }
  
    # Vérifier si le chiffre correspond à un dossier
    if ($folderMap.ContainsKey($projectTypeNumber)) {
      $subFolder = $folderMap[$projectTypeNumber]
      Write-Host "Sous-dossier: $subFolder"
    }
    else {
      Write-Host "Chiffre du projet invalide." -ForegroundColor Red
      continue
    }
  
    # Construire le chemin de base avec le sous-dossier correct
    $basePath = Join-Path $drive "$year\$month\$subFolder"
    $basePath = Format-AccentedChars $basePath
  
    # Rechercher le dossier qui commence par le numéro de projet
    $matchingFolders = Search-Folder -basePath $basePath -projectNumber $projectNumber
  
    # Log du chemin complet
    if ($matchingFolders) {
      # Si un dossier correspondant est trouvé, ouvre-le
      $folderPath = $matchingFolders[0].FullName
      Write-Host ""
      Write-Host "Dossier correspondant trouvé: $folderPath" -ForegroundColor Green
      Write-Host "========================================================================"
      # Write-Host ""
      # Read-Host -Prompt "Ouvrir le dossier ?"
      explorer $folderPath
      # break # Sortir de la boucle si le dossier a été ouvert
    }
    else {
      Write-Host ""
      Write-Host "Aucun dossier ne correspond au numéro de projet." -ForegroundColor Red
      Write-Host "========================================================================"
      ""
      continue
    }
  }
  elseif ($isNewFormat) {
    # Extraire l'année et le mois du numéro de projet
    $yearAndMonth = Get-YearAndMonth -projectNumber $projectNumber
    $year = $yearAndMonth[0]
    $monthNumber = $yearAndMonth[1]
    $projectTypeNumber = Get-ProjectTypeNumber -projectNumber $projectNumber

    # Log de l'année et du numéro de mois
    Write-Host "Année: $year"

    # Récupérer le mois formaté avec le bon index
    $month = $monthMap[$monthNumber - 1]
  
    # Vérifier si le mois est valide
    if (-not $month) {
      Write-Host "Mois invalide pour le numéro donné." -ForegroundColor Red
      continue
    }
  
    Write-Host "Mois: $month"

    # Construire le chemin de base avec le sous-dossier correct
    $baseOldPathY = Join-Path $driveY "$year\$month\Maison (9)"
    $basePathY = Join-Path $driveL "$year\$month Y"
    $basePathL = Join-Path $driveL "$year\$month"

    # Vérifier si les dossiers existent avant de rechercher
    $matchingFolders = @()

    if ((Test-Path $baseOldPathY) -and (Search-Folder -basePath $baseOldPathY -projectNumber $projectNumber)) {
      # Rechercher dans $baseOldPathY si le chemin existe
      $matchingFolders = Search-Folder -basePath $baseOldPathY -projectNumber $projectNumber
    }
    elseif ((Test-Path $basePathY) -and (Search-Folder -basePath $basePathY -projectNumber $projectNumber)) {
      # Rechercher dans $basePathY si le chemin existe
      $matchingFolders = Search-Folder -basePath $basePathY -projectNumber $projectNumber
    }
    elseif ((Test-Path $basePathL) -and (Search-Folder -basePath $basePathL -projectNumber $projectNumber)) {
      # Rechercher dans $basePathL si le chemin existe
      $matchingFolders = Search-Folder -basePath $basePathL -projectNumber $projectNumber
    }

    # Log du chemin complet
    if ($matchingFolders) {
      # Si un dossier correspondant est trouvé
      $folderPath = $matchingFolders[0].FullName
      Write-Host ""
      Write-Host "Dossier correspondant trouvé dans Y: $folderPath" -ForegroundColor Green
      Write-Host "========================================================================"
      explorer $folderPath
      # break # Sortir de la boucle si le dossier a été ouvert
    }
    else {
      Write-Host ""
      Write-Host "Aucun dossier ne correspond au numéro de projet dans les répertoires spécifiés." -ForegroundColor Red
      Write-Host "========================================================================"
      continue
    }
  }
  else {
    Write-Host "Erreur inattendue : le format de numérotation est invalide." -ForegroundColor Red
    continue
  }

}
