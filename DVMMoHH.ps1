## DVMMoHH Dans Virtuell Machine Manager of High Hopes.
$VMPath = "C:\VM"
$ServerTemplatePath = "C:\VM\Templates\Server19-template.vhdx"
$ClientTemplatePath = "C:\VM\Templates\Windows10-template.vhdx"

##------------Functions-----------

function Remove-DGVM {

    [CmdletBinding()]
    param (
    [Parameter(Mandatory)]
    [string]$VMName
    )

    $VMPath = (get-vm -name $VMName).Path
    $VHDPath = (get-vm -name $VMName).HardDrives.Path

    if (!(get-vm $VMName -ErrorAction SilentlyContinue)) {
        Write-Error "Virtual Machine [$($VMName)] does not exist!"
    } elseif (((Get-VM $VMName).State) -eq "Running") {
        Write-Host "Shutting down [$($VMName)] before deleting" -ForegroundColor Cyan
        Get-VM -Name $VMName | Stop-VM
        Remove-VM $VMName
        Remove-Item $VHDPath,$VMPath -Force
    } else {
        Remove-VM $VMName -Confirm:$false -Force -Verbose
        Remove-Item $VHDPath,$VMPath -Confirm:$false -Force -Verbose
    }
Write-Output "[$($VMName)] have been deleted. Returning to Main Menu in 2 seconds"
Start-Sleep -Seconds 2
}

function New-DGVM {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$VMName,
        [Parameter(Mandatory)][ValidateSet("Server","Client")]$MachineType
    )
    
    if((-not(Get-VM $VMName -ErrorAction SilentlyContinue).Name) -eq $VMName) {
        if ($MachineType -like "Server") { $TemplatePath = $ServerTemplatePath } else { $TemplatePath = $ClientTemplatePath }

    $VHDPath = "$VMPath\$VMName\$VMName.vhdx"
    New-VHD -ParentPath "$TemplatePath" -Path $VHDPath -Differencing -Verbose

    New-VM -Name $VMName -Path $VMPath -MemoryStartupBytes 2GB -VHDPath $VHDPath -BootDevice VHD -Generation 2
    Set-VMProcessor -VMName $VMName -Count 4 -Verbose
    Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface" -Verbose
    Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $false -Verbose
  
    Write-Host "[$($VMName)] created" -ForegroundColor Green
    Start-VM $VMName
    } else { Write-Error "[$($VMName)] already exists!" }
}

Clear-Host

##-----------Start of Menu-Loop-------
while($true)
{
    $allVms = $null
    $allVms = Get-VM | Select-Object Name, State, CPUUsage, MemoryAssigned | Format-Table
    start-sleep -Seconds 1
    Write-Output "Welcome to DVMMoHH!"

    Write-Output "1. List all VMs`n2. Create new VM`n3. Manage a VM`n4. Remove a VM"
    $menuOption = Read-Host "Select an option"

    switch($menuOption)
    {
        ## List all VMs
        1{  Clear-Host
            $allVms        
            Write-Output " "
            Continue 
        }
        ## Create new VM
        2{  Clear-Host
            Write-Host "Existing VM" -ForegroundColor Red
            $allVms
            $name = Read-Host "Write the name for the new VM"
            Write-Host "1 = Server`n2 = Client" -ForegroundColor green
            $menuOption = Read-Host "Select an option from above"
            Clear-Host
            if ($menuOption -like "1") { New-DGVM -VMName $name -MachineType Server} elseif ($menuOption -like "2") { New-DGVM -VMName $name -MachineType Client } 
            else { Write-Error "You did not select the correct VM type!" }
            Continue
        }
        ## Manage a VM
        3{  Clear-Host
            Write-Output "NYI"       
            Write-Output " "
            Continue
        }
        ## Remove a VM
        4{  Clear-Host
            $allVms
            $nameRemove = Read-Host "Write name of VM to remove (b for back to menu)"
            if ($nameRemove -like "b") {
                & "$PSScriptRoot\DVMMoHH.ps1"
                exit
            } else {
                Remove-DGVM -VMName $nameRemove   
            }
            Continue}

        default 
        {   Clear-Host
            Write-Error "Incorrect. Write a number from the menu!"
            Break 
        }
    }
}


