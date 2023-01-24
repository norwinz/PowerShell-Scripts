## DVMMoHH Dans Virtuell Machine Manager of High Hopes.


##------------Functions-----------

function Remove-DanVM{
    $allVmList = Get-VM | Select-Object Name
    ##$allVmList | Out-Host
    $nameRemove = Read-Host "Write name of VM to remove "
    $correctName = $false
    foreach($value in $allVmList)
    {
        if($value.Name -eq $nameRemove)
        {
            $correctName = $true
        }
    }
    if($correctName)
    {
Remove-VM -Name $nameRemove
Remove-Item -Path "C:\VM\VM\$($nameRemove)" -Force
Write-Output "$($nameRemove) have been deleted. Returning to Main Menu in 2 seconds"
Start-Sleep 2
$nameRemove = "PlaceHolderToStopMistakes"
}
else {
    Write-Host "A VM with that name does not exist, deletion not possible."
}
}
function Get-MenuText{
   ## $allVms = $null
    ## $allVms = Get-VM | Select-Object Name, State, CPUUsage, MemoryAssigned | Format-Table
    
Write-Output "Welcome to DVMMoHH!"

Write-Output "1. List all VMs"
Write-Output "2. Create new VM"
Write-Output "3. Manage a VM"
Write-Output "4. Remove a VM"
}
function New-DanVM{
    $name = Read-Host "Write name"
    $menuOption = Read-Host "1 = Server. 2 = Client"

        switch($menuOption)
            {
    1{Clear-Host
        New-VM -Name $name -Path "C:\VM\VM" -MemoryStartupBytes 2048mb -Generation 2
        Set-VMProcessor -VMName $name -Count 2
        Set-VM -Name $name -AutomaticCheckpointsEnabled $false
        New-VHD -Path "C:\VM\VM\$($name)\$($name).vhdx" -Differencing -ParentPath "C:\VM\Templates\Server19-template.vhdx"
        Add-VMHardDiskDrive -VMName $($name) -Path "C:\VM\VM\$($name)\$($name).vhdx"
        Write-Output " "
        Read-Host "VM has been created. Press any key to continue or CTRL+C to quit" 
        Continue }
    2{Clear-Host 
        New-VM -Name $name -Path "C:\VM\VM" -MemoryStartupBytes 2048mb -Generation 2
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
        
         Continue}
    2{Clear-Host ## Create new VM
        New-DanVM   
        
        Continue}
    3{Clear-Host ## Manage a VM
       
        Write-Output "NYI"       
        Write-Output " "
        Continue}
    4{Clear-Host ## Remove a VM
        
        $allVms   
        Remove-DanVM
    
        Write-Output " "
        Continue}    
    default {
        Clear-Host
        Write-Output "Incorrect. Write a number from the menu.!"
    Break }
}
}


