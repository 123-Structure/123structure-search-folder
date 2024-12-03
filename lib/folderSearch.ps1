function Search-Folder {
  param (
    [string]$basePath,
    [string]$projectNumber
  )

  $basePath = Format-AccentedChars $basePath
  $matchingFolders = Get-ChildItem -Path $basePath -Directory | Where-Object { $_.Name -like "$projectNumber*" }
  return $matchingFolders
}