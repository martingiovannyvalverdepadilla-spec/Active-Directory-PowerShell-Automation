$Users = Import-CSV -path "C:\NewUsers.CSV"
$DefaultPassword = ConvertTo-SecureString "Password2026" -AsPlainText -Force
ForEach ($User in $Users) {

$Initial = $User.GivenName.SubString(0,1)
$LogonName= ( $Initial + $User.SurName).Tolower()
$FullName= "$($User.GivenName) $($User.SurName)"

$ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$LogonName'"
If( $ExistingUser) {
Write-Warning "User $LogonName already existing in Active Directory. Skipping"
Continue}

If ($User.Department -eq "IT") {
$TargetOU = "OU=IT,OU=COMPANY,DC=lab,DC=local"
}
ElseIf ($User.Department -eq "Sales") {
$TargetOU = "OU=Sales,OU=COMPANY,DC=lab,DC=local"
}
Else {
$TargetOU = "OU=General,OU=COMPANY,DC=lab,DC=local"
}
$Params = @{
SamAccountName  = $LogonName
UserPrincipalName  = "$LogonName@lab.local"
Name = $FullName
GivenName = $User.GivenName
Surname = $User.SurName
Department   = $User.Department 
Path = $TargetOU
AccountPassword = $DefaultPassword
Enabled = $True
ChangePasswordAtLogon = $True 
}
Try {
New-ADUser @Params -ErrorAction Stop 
Write-Host "Created $LogonName in $TargetOU" -ForeGroundColor Green
}
Catch{
Write-Host "Failed to create $LogonName. Reason:  $($_.Exception.Message)" -ForegroundColor Red
}
}