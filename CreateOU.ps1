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
                $NewPath = -join('OU=',$OUNameSplited[0],',',$NewPath)
                New-ADGroup -Name $OUNameSplited[0] -GroupScope DomainLocal -GroupCategory Security -Path $NewPath
                Write-Host "L'UO",$OUNameSplited[0],"a ete creee au path $NewPath"
            }

        } else {
            #Sinon on crée les 2 UO
            ##Creation de l'UO parent
            New-ADOrganizationalUnit -Name $OUNameSplited[1] -path $Path
            $NewPath = -join('OU=',$OUNameSplited[1],',',$Path)
            New-ADGroup -Name $OUNameSplited[1] -GroupScope DomainLocal -GroupCategory Security -Path $NewPath
            Write-Host "L'UO",$OUNameSplited[1],"a ete creee"

            ##Creation de l'UO enfant
            $NewPath = -join('OU=',$OUNameSplited[0],',',$NewPath)
            New-ADOrganizationalUnit -Name $OUNameSplited[0] -path $NewPath
            New-ADGroup -Name $OUNameSplited[1] -GroupScope DomainLocal -GroupCategory Security -Path $NewPath
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