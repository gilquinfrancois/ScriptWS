<# Import the raw data from a csv file #>
$ADUsers = Import-csv 'C:\Users\louisfitdevoie\Documents\Employés-lower-sansAccents.csv' -Encoding UTF8

<##>
<#$Empty = "" | Out-File 'C:\Users\louisfitdevoie\Documents\test.csv'#>

$continue = 1

<###  CREATION D'UO  ###>

$tableOUToCreate.Clear()
Clear-Content 'C:\Users\louisfitdevoie\Documents\test.csv'


while($continue -eq 1) {
    
    $continue = Read-Host -Prompt 'Do you want to add a OU ? [1=YES/0=NO]'
    if($continue -eq 1) {
        $tableOUToCreate += Read-Host -Prompt 'What is the name of the OU ?'
        
    }
}

<# Test pour voir si les données rentrées par l'utilisateur sortent bien dans le fichier #>
$tableOUToCreate | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'

<###   ENREGISTREMENT DES DONNES DES USERS DANS UN FICHIER   ###>

foreach ($User in $ADUsers) {
    $FirstName = $User.Prenom <# | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'#>
    $LastName = $User.Nom
    $Description = $User.Description
    $Departement = $User.Departement
    $InternNumber = $User.N\°Interne
    $Bureau = $User.Bureau

    ($FirstName + ' ' + $LastName + ' ' + $Description + ' ' + $Departement + ' ' + $InternNumber + ' ' + $Bureau).ToLower() -replace 'é','e' -replace 'è','e' -replace 'ê','e' | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'

}