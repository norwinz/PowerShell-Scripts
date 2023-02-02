## SoD Script of Dreams


##------------Functions-----------


function Get-DanManage{
    
    $allVmList = $null
    $allVmList = Get-VM | Select-Object Name, State, VMname
    Clear-Host
    $allVms
    
    $nameManage = Read-Host "Write name of VM you want to install AD on "
    $correctName = $false
    foreach($value in $allVmList)
    {
        if($value.Name -eq $nameManage)
        {
            $correctName = $true
            $vmState = $value.State
            
        }
    }
    if($correctName)
    {
        ##Start server
            ##Check if VM is running

            if($vmState -eq "Off")
                {
                Write-Host "Starting VM..."
                Start-Vm -Name $nameManage
                do
                    {
                    $VMonline = get-vm $nameManage
                    } while ($VMonline.Heartbeat -ne "OkApplicationsUnknown")
                    start-sleep 15
                Write-Host "VM started"
                Write-Host "Logging in..."
                }
                $usernameTemp = "tempAdmin"
                $password = ConvertTo-SecureString "Sommar2020" -AsPlainText -Force
                $credTemp = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameTemp, $password
                Invoke-Command  -VmName $nameManage -Credential $credTemp -ScriptBlock {
                    $loggedinuser = whoami
                    write-host "Logged in as: $($loggedinuser)"
                    write-host "Installing AD DS..."
                    install-windowsfeature AD-Domain-Services
                    Import-Module ADDSDeployment
                    Write-Host "AD DS installed."
                } 

        $nameManage = "PlaceHolderNameToStopMistakes"
}
else {
    Write-Host "A VM with that name does not exist"
}
}
function Remove-DanVM{
    
    $allVmList = $null
    $allVmList = Get-VM | Select-Object Name, State
    Clear-Host
    $allVms
    
    $nameRemove = Read-Host "Write name of VM to remove "
    $correctName = $false
    foreach($value in $allVmList)
    {
        if($value.Name -eq $nameRemove)
        {
            $correctName = $true
            $vmState = $value.State
        }
    }
    if($correctName)
    {
##add code to stop VM if it is running here
if($vmState -eq "Running")
                {
                Write-Host "Turning off VM..."
                
                Stop-Vm -Name $nameRemove -TurnOff
                Start-Sleep 5
                Write-Host "VM turned off."
                Write-Host "Starting to delete $($nameRemove)..."
                }

Remove-VM -Name $nameRemove
Remove-Item -Path "C:\VM\VM\$($nameRemove)" -Force
Write-Output " "
Read-Host "$($nameRemove) have been deleted. Press any key to continue or CTRL+C to quit" 
Clear-Host
$nameRemove = "PlaceHolderToStopMistakes"
}
else {
    Write-Host "A VM with that name does not exist, deletion not possible."
}
}
function Get-MenuText{
   
    
Write-Output "Welcome to Script of Dreams (SoD)"

Write-Output "1. List all VMs"
Write-Output "2. Create new VM"
Write-Output "3. Install AD DS"
Write-Output "4. Remove a VM"
Write-Output "5. Export a VM"
}
function New-DanVM{
    $name = Read-Host "Write name"
    $menuOption = Read-Host "1 = Server. 2 = Client"

        switch($menuOption)
            {
    1{Clear-Host
        New-VM -Name $name -Path "C:\VM\VM" -MemoryStartupBytes 2048mb -Generation 2 -SwitchName 'LAN'
        Set-VMProcessor -VMName $name -Count 2
        Set-VM -Name $name -AutomaticCheckpointsEnabled $false
        New-VHD -Path "C:\VM\VM\$($name)\$($name).vhdx" -Differencing -ParentPath "C:\VM\Templates\Server19-template.vhdx"
        Add-VMHardDiskDrive -VMName $($name) -Path "C:\VM\VM\$($name)\$($name).vhdx"       
        Write-Output " "
        Read-Host "VM has been created. Press any key to continue or CTRL+C to quit" 
        Continue }
    2{Clear-Host 
        New-VM -Name $name -Path "C:\VM\VM" -MemoryStartupBytes 2048mb -Generation 2 -SwitchName 'LAN'
        Set-VMProcessor -VMName $name -Count 2
        Set-VM -Name $name -AutomaticCheckpointsEnabled $false
        New-VHD -Path "C:\VM\VM\$($name)\$($name).vhdx" -Differencing -ParentPath "C:\VM\Templates\Windows10-template.vhdx"
        Add-VMHardDiskDrive -VMName $($name) -Path "C:\VM\VM\$($name)\$($name).vhdx"     
        Write-Output " "
        Read-Host "VM has been created. Press any key to continue or CTRL+C to quit" 
        Continue}
    default{
        Clear-Host
        Write-Output "Incorrect. Write a number from the menu.!"
    Break }
            }
}
function Export-DanVM{
    $allVmList = $null
    $allVmList = Get-VM | Select-Object Name
    Clear-Host
    $allVms
    
    $nameExport = Read-Host "Write name of VM to export "
    $correctName = $false
    foreach($value in $allVmList)
    {
        if($value.Name -eq $nameExport)
        {
            $correctName = $true
        }
    }
    if($correctName)
    {
        Export-VM -Name $nameExport -Path C:\VM\ExportedVM
Write-Output " "
Read-Host "$($nameExport) have been exported to C:\VM\ExportedVM\$($nameExport). `n `n
Press any key to continue or CTRL+C to quit" 
Clear-Host
$nameExport = "PlaceHolderToStopMistakes"
}
else {
    Write-Host "A VM with that name does not exist, export not possible."
}

}

Clear-Host
##-----------Start of Menu-Loop-------
while($true)
{

Get-MenuText | Out-host
$menuOption = Read-Host "Write a number"

$allVms = $null
    $allVms = Get-VM | Select-Object Name, State, CPUUsage, MemoryAssigned | Format-Table
switch($menuOption)
{
    
    1{Clear-Host ## List all VMs
        $allVms        
         Break}
    2{Clear-Host ## Create new VM
        New-DanVM           
        Break}
    3{Clear-Host ## Manage a VM
        Get-DanManage
        Break}
    4{Clear-Host ## Remove a VM
        Remove-DanVM
        Write-Output " "
        Break}
    5{Clear-Host ## Remove a VM
        Export-DanVM
        Break} 
    default {
        Clear-Host
        Write-Output "Incorrect. Write a number from the menu.!"
    Break }
}
}


