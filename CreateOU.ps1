Import-Module activedirectory

$FileLocation = 'C:\Users\louisfitdevoie\Documents\Employes-lower-sansAccents.csv'
$FileData = Import-CSV -Path $FileLocation -Delimiter ";" -Encoding UTF8

foreach ($User in $FileData) {

    $OUName = $User.departement
    $Path = 'DC=test,DC=lan'

    #Verifie si le nom de departement contient un /
    if($OUName.contains("/")) {
        #split
        $OUNameSplited = $OUName.Split("/") 
        
        #verifie si le nom de departement apres le / existe
        $FilterOUName1 = -join("name -eq '",$OUNameSplited[1],"'")
        $FilterOUName0 = -join("name -eq '",$OUNameSplited[0],"'")
        if(Get-ADOrganizationalUnit -Filter "$FilterOUName1") {

            #Si oui on verifie si le nom de departement avant le / existe dans l'uo
            if(Get-ADOrganizationalUnit -Filter "$FilterOUName0") {

            } else {
                $NewPath = -join('OU=',$OUNameSplited[1],',',$Path)
                New-ADOrganizationalUnit -Name $OUNameSplited[0] -path $NewPath
                Write-Host "L'UO",$OUNameSplited[0],"a ete creee au path $NewPath"
            }

        } else {
            #Sinon on crée les 2 UO
            New-ADOrganizationalUnit -Name $OUNameSplited[1] -path $Path
            Write-Host "L'UO",$OUNameSplited[1],"a ete creee"
            $NewPath = -join('OU=',$OUNameSplited[1],',',$Path)
            New-ADOrganizationalUnit -Name $OUNameSplited[0] -path $NewPath
            Write-Host "L'UO",$OUNameSplited[0],"a ete creee au path $NewPath"
        }

    } else {
        if(Get-ADOrganizationalUnit -Filter "name -eq '$OUName'") {
            
        } else {
            New-ADOrganizationalUnit -Name $OUName -path $Path
            Write-Host "L'UO $OUName a ete creee"
        }
    }
}