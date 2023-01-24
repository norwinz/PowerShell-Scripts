# Disable Hyper-v
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor

bcdedit /set hypervisorlaunchtype off

Restart-Computer


### Enable Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor

bcdedit /set hypervisorlaunchtype auto

Restart-Computer