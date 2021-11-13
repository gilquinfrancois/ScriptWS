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
    foreach($User in $FileData) {
        $FirstName = $User.prenom
        $LastName  = $User.nom
        
        #Creation du login -> 3 premiers caracteres du prenom + . + 16 premiers caracteres du nom
        if($LastName.length > 16) { #Si le nom fait plus de 16 caraceres, on recupere les 16 premiers
            $UsernameLastName = ($LastName).Substring(0,16)
        } else {
            $UsernameLastName = $LastName
        }
        $Login = ($FirstName).Substring(0,3) + "." + $UsernameLastName

        #On verifie si un utilisateur avec le même login existe
        if(Get-ADUser -Filter {SamAccountName -eq $Login}) {
            Write-Warning "L'identifiant $Login existe deja dans l'AD"
        } else {
            #Creation de l'User dans l'AD
            #Generation du mot de passe avec 8 caracteres
            $Password = GeneratePassword -length 8
        }
    }