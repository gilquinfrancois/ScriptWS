<#
    Récup le nom des UO à créer
        --> Lire le fichier formatté avec les employés OK
        --> Récup les départements de chaque user  OK
        --> A chaque fois :
            --> Vérifier si il y a un "/"
                --> Si oui
                    --> Split au "/"
                    --> Vérifier si la partie d'après le "/" existe
                        --> Si oui --> break
                        --> Si non --> créer
                    --> Vérifier si la partie d'avant le "/" existe dans l'UO nommée comme après le "/"
                        --> Si oui --> break
                        --> Si non --> créer
                --> Si non
                    --> Vérifier si le nom de département existe
                        --> Si oui --> break
                        --> Si non --> créer
#>
$ADUsersToCreate = Import-csv 'C:\Users\louisfitdevoie\Documents\Employés-lower-sansAccents.csv' -Encoding UTF8

$continue = 1

<# Récupération des départements #>

foreach ($User in $ADUsersToCreate) {
    <#$Departement = $User.Departement | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'#>
    $Departement = $User.Departement

    $DepartementSplit = $Departement.Split("/")
    If($DepartementSplit[1] -eq $null) {
        if(Get-ADOrganizationalUnit -Filter {Name -eq $DepartementSplit[1]}) {

        } else {
            $DepartementSplit[1] | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'
        }
    } else {
        <#
        if(Get-ADOrganizationalUnit -Filter {Name -eq $DepartementSplit[1]}) {

        } else {
            $DepartementSplit[1] | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'
        }
        if(Get-ADOrganizationalUnit -Filter {Name -eq $DepartementSplit[0]}) {

        } else {
            $DepartementSplit[0] | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'
        }#>
        $test = $DepartementSplit[1] + '/' + $DepartementSplit[0] | Out-File -Append 'C:\Users\louisfitdevoie\Documents\test.csv'
    }

}