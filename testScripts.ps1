$nameManage = "AD01"
                $usernameTemp = "tempAdmin"
                $password = ConvertTo-SecureString "Sommar2020" -AsPlainText -Force
                $credTemp = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameTemp, $password
                Invoke-Command  -VMname $nameManage -Credential $credTemp -ScriptBlock {
                    get-windowsfeature AD-Domain-Services
                }