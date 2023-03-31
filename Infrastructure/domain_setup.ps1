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


$strong_user_initial_password = Get-StrongPassword(24)
$strong_user_secure_password = ConvertTo-SecureString $strong_user_initial_password -AsPlainText -Force

$bind_user_intial_password = Get-StrongPassword(24)
$bind_user_secure_password = ConvertTo-SecureString $bind_user_intial_password -AsPlainText -Force
#create OU structure
New-ADOrganizationalUnit -Name "CyberArk" -Path $base_context
New-ADOrganizationalUnit -Name "Users" -Path "OU=CyberArk,$base_context"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=CyberArk,$base_context"
New-ADOrganizationalUnit -Name "Service_Accounts" -Path "OU=CyberArk,$base_context"

#create users needed for POC
New-ADUser -Name "svc_lcl_creator" -AccountPassword $strong_user_secure_password -Enabled $true -Path "OU=Service_Accounts,OU=CyberArk,$base_context"
New-ADUser -Name "svc_bind_user" -AccountPassword $bind_user_secure_password -Enabled $true -Path "OU=Service_Accounts,OU=CyberArk,$base_context"


#user password (only use for POC purposes in closed environments)
Write-Host "svc_lcl_creator password: " + $strong_user_initial_password 
Write-HOst "svc_bind_user password: " + $bind_user_intial_password
