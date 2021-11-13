<###   THIS FUNCTION REPLACES THE SPECIAL CHARACTERS   ###>
Function Remove-StringSpecialCharacters
{
   param ([string]$String)

   Begin {}

   Process {

      $String = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String))

      $String = $String -replace '-', '' `
                        -replace ' ', '' `
                        -replace '/', '/' `
                        -replace '\*', '\*' `
                        -replace '\?', '' `
                        -replace "'", "" 
   }

   End {
      return $String
   }
}


<###   HERE WE LOWER EVERY CHARACTER IN THE ENTRY FILE AND WE TAKE OUT THE OUT-VALUES IN ANOTHER FILE   ###>
Get-Content 'C:\Users\louisfitdevoie\Documents\Employes.csv' | ForEach-Object {$_.ToLower() } | Out-File 'C:\Users\louisfitdevoie\Documents\Employes-lower.csv'

<###   HERE WE USE THE FUNCTION PREVIOUSLY DECLARED TO REPLACE THE SPECIAL CHARACTERS AND WE TAKE OUT THE OUT-VALUES IN ANOTHER FILE   ###>
Get-Content 'C:\Users\louisfitdevoie\Documents\Employes-lower.csv'| ForEach-Object { Remove-StringSpecialCharacters($_) } | Out-File 'C:\Users\louisfitdevoie\Documents\Employes-lower-sansAccents.csv'

