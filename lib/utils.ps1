function Test-ProjectNumber {
  param([string]$projectNumber)

  # Ancien format : AA.MM.000Y
  $oldFormatRegex = '^\d{2}\.\d{2}\.\d{3}[A-Z]$'
  # Nouveau format : AAMM0000
  $newFormatRegex = '^\d{4}\d{4}$'

  return ($projectNumber -match $oldFormatRegex -or $projectNumber -match $newFormatRegex)
}

function Get-YearAndMonth {
  param([string]$projectNumber)

  if ($projectNumber -match '^\d{2}\.\d{2}\.\d{3}[A-Z]$') {
    # Ancien format
    $parts = $projectNumber -split '\.'
    $year = "20" + $parts[0]
    $month = $parts[1]
    return @($year, $month)
  }
  elseif ($projectNumber -match '^\d{4}\d{4}$') {
    # Nouveau format
    $year = "20" + $projectNumber.Substring(0, 2)
    $month = $projectNumber.Substring(2, 2)
    return @($year, $month)
  }
  else {
    throw "Format de numéro de projet invalide."
  }
}


function Get-ProjectTypeNumber {
  param (
    [string]$projectNumber
  )
  if ($projectNumber.Length -eq 10) {
    return $projectNumber.Substring(8, 1)
  }
  elseif ($projectNumber.Length -eq 11) {
    return $projectNumber.Substring(9, 1)
  }
  return $null
}

function ConvertTo-NormalizedMonth {
  param (
    [string]$month
  )
  return $month.ToLower() -replace "é|è|ê", "e" -replace "â|à", "a" -replace "ô", "o" -replace "î|ï", "i" -replace "ù|û", "u" -replace "ç", "c"
}

function Resolve-NetworkPath {
  param (
    [string]$PrimaryPath,
    [string]$FallbackIP = "192.168.148.231"
  )

  # Si le chemin principal est accessible, on le garde
  if (Test-Path $PrimaryPath) {
    return $PrimaryPath
  }

  # Sinon, on tente de remplacer le nom du serveur par l'IP
  # On suppose que le format est \\SERVEUR\PARTAGE...
  # On extrait le nom du serveur pour le remplacer
  if ($PrimaryPath -match '^\\\\([^\\]+)\\(.+)$') {
    $serverName = $matches[1]
    $sharePath = $matches[2]
        
    $fallbackPath = "\\$FallbackIP\$sharePath"
        
    if (Test-Path $fallbackPath) {
      Write-Host "⚠️ Chemin principal inaccessible ($PrimaryPath). Bascule sur l'IP ($fallbackPath)." -ForegroundColor Yellow
      return $fallbackPath
    }
  }

  # Si rien ne marche, on retourne le chemin initial (pour laisser l'erreur se produire plus loin ou gérer l'échec)
  return $PrimaryPath
}
