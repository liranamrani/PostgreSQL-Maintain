$userName = 'newLocalAdmin'
$password = ConvertTo-SecureString -String '123456789' -AsPlainText -Force
$group = 'Administrators'
$comp = "localhost"
Invoke-Command -ComputerName $comp -ArgumentList $userName, $password, $group -ScriptBlock {
    New-LocalUser -Name $args[0] -FullName 'Local Admin' -Description 'Local Admin Account' -Password $args[1] -PasswordNeverExpires -AccountNeverExpires
    Add-LocalGroupMember -Group $args[2] -Member $args[0]
}