# Fonction pour remplacer les caractères accentués
function Format-AccentedChars {
  param([string]$inputString)
  $replacements = @{
    'é' = [char]233; 'è' = [char]232; 'ê' = [char]234; 'ë' = [char]235;
    'à' = [char]224; 'â' = [char]226; 'ä' = [char]228;
    'ù' = [char]249; 'û' = [char]251; 'ü' = [char]252;
    'ô' = [char]244; 'ö' = [char]246;
    'î' = [char]238; 'ï' = [char]239;
    'ç' = [char]231;
  }
  foreach ($key in $replacements.Keys) {
    $inputString = $inputString -replace $key, $replacements[$key]
  }
  return $inputString
}

# # Redéfinir Write-Host pour utiliser automatiquement Format-AccentedChars
# function global:Write-Host {
#   param(
#     [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
#     [object] $Object,
#     [switch] $NoNewline,
#     [System.ConsoleColor] $ForegroundColor,
#     [System.ConsoleColor] $BackgroundColor
#   )

#   $formattedObject = if ($Object -is [string]) {
#     Format-AccentedChars $Object
#   }
#   else {
#     $Object
#   }

#   $params = @{
#     Object    = $formattedObject
#     NoNewline = $NoNewline
#   }

#   if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
#     $params['ForegroundColor'] = $ForegroundColor
#   }
#   if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
#     $params['BackgroundColor'] = $BackgroundColor
#   }

#   Microsoft.PowerShell.Utility\Write-Host @params
# }

# # Redéfinir Read-Host pour utiliser automatiquement Format-AccentedChars
# function global:Read-Host {
#   param(
#     [Parameter(Position = 0, ValueFromPipeline = $true)]
#     [string] $Prompt
#   )

#   $formattedPrompt = Format-AccentedChars $Prompt
#   Microsoft.PowerShell.Utility\Read-Host -Prompt $formattedPrompt
# }