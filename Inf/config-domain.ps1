$base_context = "DC=AWS,DC=Deloitte,DC=COM"
$initial_password = GenerateStrongPassword(24)
$secure_password = ConvertTo-SecureString $initial_password
#create OU structure
New-ADOrganizationalUnit -Name "CyberArk" -Path $base_context
New-ADOrganizationalUnit -Name "Users" -Path "OU=CyberArk,$cyberark_org"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=CyberArk,$cyberark_org"
New-ADOrganizationalUnit -Name "Service_Accounts" -Path "OU=CyberArk,$cyberark_org"

#create users needed for POC
New-ADUser -Name "svc_lcl_creator" -AccountPassword $secure_password -Enabled $true


#user password (only use for POC purposes in closed environments)
Write-Host $initial_password


Function GenerateStrongPassword ([Parameter(Mandatory = $true)][int]$PasswordLenght) {
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
