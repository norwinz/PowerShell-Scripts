## ------------------ Start session with VM ---------------------
Enter-PSSession -VMName ad02sto
Enter-PSSession -VMName AD01gbg
Enter-PSSession -VMName Clientgbg
Enter-PSSession -VMName ClientSto
Exit-PSSession

## ---------------- Set IP/dns ad02Sto --------------------------
New-NetIPAddress -IPAddress 192.168.10.6 -PrefixLength 24 -DefaultGateway 192.168.10.1 -InterfaceAlias "Ethernet"
Get-NetIPConfiguration
Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses 192.168.10.5, 192.168.10.6

## ----------------- Join mstile domain ---------------------
Import-Module ADDSDeployment
Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-CreateDnsDelegation:$false `
-CriticalReplicationOnly:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainName "mstile.se" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SiteName "Default-First-Site-Name" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true

## ------------------- Add STO OU and secSTO ----------------------------
New-ADOrganizationalUnit -Name "STO" -Path "DC=Mstile,DC=SE"
New-ADGroup -Name secSTO -SamAccountName secSTO -GroupCategory Security -GroupScope Global -DisplayName "secSTO" -Path "OU=STO,DC=mstile,DC=se"
New-ADGroup -Name secSTOCOMP -SamAccountName secSTOCOMP -GroupCategory Security -GroupScope Global -DisplayName "secSTOCOMP" -Path "OU=STO,DC=mstile,DC=se"

## ---------------------------- Add users from CSV and add them to secSTO and OU----------------------
$CSV = Import-CSV -path "C:\Users\administrator.MSTILE\Desktop\StockholmAnvändarev2 - StockholmAnvändarev2.csv"
$newPass = "Sommar2020"
foreach($user in $CSV)
{
New-ADUser -givenName $user.givenname -Surname $user.surname -Name "$($user.givenname) $($user.surname)" -SamAccountName $user.samaccountname -UserPrincipalName "$($user.givenname).$($user.surname)@mstile.com" -path "OU=STO, DC=mstile, DC=se"
Set-ADAccountPassword -Identity $user.samaccountname -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$newPass" -Force)
Add-ADGroupMember -Identity "secSTO" -Members $user.samaccountname
}

##----------------- Join ClientSto to domain -------------------
Rename-Computer -NewName "Clientsto"
add-computer -domainname "mstile.se"  -restart


##------------------------GBG STUFF BELLOW -------------------------------------------------------------------------------------------------------

## ---------------- Set IP/dns  --------------------------
New-NetIPAddress -IPAddress 192.168.10.5 -PrefixLength 24 -DefaultGateway 192.168.10.1 -InterfaceAlias "Ethernet"
Get-NetIPConfiguration
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses 192.168.10.6, 127.0.0.1


## ---------------- Create GBG OU -------------------
New-ADOrganizationalUnit -Name "GBG" -Path "DC=Mstile,DC=SE"
New-ADGroup -Name secGBG -SamAccountName secGBG -GroupCategory Security -GroupScope Global -DisplayName "secGBG" -Path "OU=GBG,DC=mstile,DC=se"
New-ADGroup -Name secGBGCOMP -SamAccountName secGBGCOMP -GroupCategory Security -GroupScope Global -DisplayName "secGBGCOMP" -Path "OU=GBG,DC=mstile,DC=se"

## ------------------ Create users for the GBG-OU --------------
$newPass = "Sommar2020"

$usergivennameArray = "Anders", "Bertil", "Erika", "Morgan", "Kalle"
$usersurnameArray = "Andersson", "Andersson", "Stark", "Stark", "Karlsson"


for($i = 0; $i -le 4; $i++)
{
    $usergivenname = $usergivennameArray[$i]
    $usersurname = $usersurnameArray[$i]
    $usersamaccountname = "$($usergivenname).$($usersurname)"
    New-ADUser -givenName $usergivenname -Surname $usersurname -Name "$($usergivenname) $($usersurname)" -SamAccountName "$($usergivenname).$($usersurname)" -UserPrincipalName "$($usergivenname).$($usersurname)@mstile.se" -path "OU=GBG, DC=mstile, DC=se"
    Set-ADAccountPassword -Identity $usersamaccountname -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$newPass" -Force)
    Add-ADGroupMember -Identity "secGBG" -Members $usersamaccountname
}



##------------------- Create suffix ----------------
Set-ADForest -Identity mstile -UPNSuffixes @{add="mstile.com"}
Get-ADForest | Format-List UPNSuffixes
##---------------- Join client to domain -------------
Rename-Computer -NewName "Clientgbg"
add-computer -domainname "mstile.se"  -restart




##-----------------Remove AD ----------------------

##---------------- Transfer FSMO-Roles ------------------

##Check who owns the roles
import-module activedirectory
netdom query fsmo ##check who own roles

#Move roles
Move-ADDirectoryServerOperationMasterRole -Identity "ad02Sto" InfrastructureMaster, PDCEmulator, RIDMaster, DomainNamingMaster, SchemaMaster

dcdiag /q

##Move DHCP http://www.ngcci.com/move-dhcp-one-server-another-dhcp-server/

Test-ADDSDomainControllerUninstallation #Test to see if removal is ready

Uninstall-ADDSDomainController #Removes AD

Uninstall-WindowsFeature AD-Domain-Services -IncludeManagementTools

##Check if connected to correct AD on client cmd
Echo %logonserver%


