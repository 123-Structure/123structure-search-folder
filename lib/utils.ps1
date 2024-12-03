function Test-ProjectNumber {
  param (
    [string]$projectNumber
  )
  $projectNumberRegex = "^\d{2}\.\d{2}\.\d{3,4}[A-Za-z]$"
  return $projectNumber -match $projectNumberRegex
}

function Get-YearAndMonth {
  param (
    [string]$projectNumber
  )
  $year = "20" + $projectNumber.Substring(0, 2)
  $monthNumber = $projectNumber.Substring(3, 2)
  return @($year, $monthNumber)
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
