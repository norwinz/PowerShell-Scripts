$nameManage = "ad01"
$usernameTemp = "tempAdmin"
$password = ConvertTo-SecureString "Sommar2020" -AsPlainText -Force
$credTemp = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameTemp, $password
Invoke-Command  -VmName $nameManage -Credential $credTemp -ScriptBlock {
Get-windowsfeature AD-Domain-Services}