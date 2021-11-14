#Fonctions de generation de password
    function Get-RandomCharacters($length, $characters) {
        $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
        $private:ofs=""
        return [String]$characters[$random]
    }

    function Scramble-String([string]$inputString){     
        $characterArray = $inputString.ToCharArray()   
        $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
        $outputString = -join $scrambledStringArray
        return $outputString 
    }

    function GeneratePassword([int]$length) {
        if($length -lt 8) {
            $length = 8
        }
        $GeneratedPassword = Get-RandomCharacters -length ($length - 3) -characters 'abcdefghiklmnoprstuvwxyz'
        $GeneratedPassword += Get-RandomCharacters -length 1 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
        $GeneratedPassword += Get-RandomCharacters -length 1 -characters '1234567890'
        $GeneratedPassword += Get-RandomCharacters -length 1 -characters '!$%&=?@#*+'

        $GeneratedPassword = Scramble-String $GeneratedPassword
        return $GeneratedPassword
    }

#Importation des donnees
    $FileLocation = 'C:\Users\louisfitdevoie\Documents\Employes-lower-sansAccents.csv'
    $FileData = Import-CSV -Path $FileLocation -Delimiter ";" -Encoding UTF8

#Boucle
    $Test = "Name;DisplayName;GivenName;Surname;SamAccountName;UserPrincipalName;Path;AccountPassword;ChangePasswordAtLogon;Enabled" | Out-File 'C:\Users\louisfitdevoie\Documents\test.txt'
    foreach($User in $FileData) {
        $FirstName = $User.prenom
        $LastName  = $User.nom
        
        #Creation du login -> 3 premiers caracteres du prenom + . + 16 premiers caracteres du nom
        if($LastName.length -gt 16) { #Si le nom fait plus de 16 caraceres, on recupere les 16 premiers
            $UsernameLastName = ($LastName).Substring(0,16)
        } else {
            $UsernameLastName = $LastName
        }
        $Login = ($FirstName).Substring(0,3) + "." + $UsernameLastName

        #On verifie si un utilisateur avec le même login existe
        if(Get-ADUser -Filter {SamAccountName -eq $Login}) {
            Write-Warning "L'identifiant $Login existe deja dans l'AD"
        } else {
            #Generation du mot de passe avec 8 caracteres
            $Password = GeneratePassword -length 8

            #Recuperation du Path ou on cree l'utilisateur + creation du samaccountname
            $OUName = $User.departement
            $InitialPath = "DC=test,DC=lan"
            $UPNSuffix = "test.lan"

            if($OUName.contains("/")) {
                $OUNameSplited = $OUName.Split("/")
                $NewPath = -join("OU=",$OUNameSplited[0],",OU=",$OUNameSplited[1],",",$InitialPath)
            } else {
                $NewPath = -join("OU=",$OUName,",",$InitialPath)
            }

            #Creation de l'User dans l'AD

            $Name = -join($FirstName,' ',$LastName)
            $DisplayName = -join($LastName.ToUpper(),' ',$FirstName)
            $GivenName = $FirstName
            $Surname = $LastName
            $SamAccountName = $Login
            $UserPrincipalName = -join($Login,"@",$UPNSuffix)
            $Path = $NewPath
            $AccountPassword = (convertto-securestring $Password -AsPlainText -Force)
            $ChangePasswordAtLogon = $True
            $Enabled = $True
            
            try {
                New-ADUser -Name $Name -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName -Path $Path -AccountPassword $AccountPassword -ChangePasswordAtLogon $ChangePasswordAtLogon -Enabled $Enabled
                Write-Host "L'utilisateur $SamAccountName a ete cree dans l'AD"
            } catch {
                Write-Warning "L'utilisateur $SamAccountName n'a pas pu etre cree dans l'AD"
            }
            

            $Test = -join($Name,";",$DisplayName,";",$GivenName,";",$Surname,";",$SamAccountName,";",$UserPrincipalName,";",$Path,";",$Password) | Out-File 'C:\Users\louisfitdevoie\Documents\test.txt' -Append
        }
    }
