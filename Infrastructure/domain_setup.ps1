#update context
$base_context = ""

function Get-StrongPassword ([Parameter(Mandatory = $true)][int]$PasswordLenght) {
    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
    do {
        $newPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLenght, 1)
        If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
                -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
                -and ($newPassword -match "[\d]") `
                -and ($newPassword -match "[^\w]")
        ) {
            $PassComplexCheck = $True
        }
    } While ($PassComplexCheck -eq $false)
    return $newPassword
}


$initial_password = Get-StrongPassword(24)
$secure_password = ConvertTo-SecureString $initial_password -AsPlainText -Force
#create OU structure
New-ADOrganizationalUnit -Name "CyberArk" -Path $base_context
New-ADOrganizationalUnit -Name "Users" -Path "OU=CyberArk,$base_context"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=CyberArk,$base_context"
New-ADOrganizationalUnit -Name "Service_Accounts" -Path "OU=CyberArk,$base_context"

#create users needed for POC
New-ADUser -Name "svc_lcl_creator" -AccountPassword $secure_password -Enabled $true -Path "OU=Service_Accounts,OU=CyberArk,$base_context"


#user password (only use for POC purposes in closed environments)
Write-Host $initial_password 
