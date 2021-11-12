
$ADUsersToCreate = Import-csv 'C:\Users\louisfitdevoie\Documents\Employés-lower-sansAccents.csv' -Encoding UTF8

foreach ($User in $ADUsersToCreate)
{

    $Username    = $User.ninterne
    $Password    = 'Test123*'
    $Firstname   = $User.prenom
    $Lastname    = $User.nom
    $Departement = $User.departement
    $Name = -join($Firstname,' ',$Lastname)

    $DepartementSplit = $Departement.Split("/")
    If($DepartementSplit[1] -eq $null) {
        $OU = -join ('OU=',$DepartementSplit[0],',DC=test','DC=lan')
    } else {
        $OU = -join ('OU=',$DepartementSplit[0] + ',OU=' + $DepartementSplit[1],',DC=test','DC=lan')
    }

       #Vérifiez si le compte utilisateur existe déjà dans AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
            #Si l’utilisateur existe, éditez un message d’avertissement
            Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
            #Si un utilisateur n’existe pas, créez un nouveau compte utilisateur
          
            #Le compte sera créé dans l’unité d’organisation indiquée dans la variable $OU du fichier CSV ; n’oubliez pas de changer le nom de domaine dans la variable « -UserPrincipalName ».
            New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@test.lan" `
            -Name $Name `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)

       }
}