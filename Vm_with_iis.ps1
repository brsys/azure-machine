#Welcome to Easy VM creator 
# BRSYS
# Please note this can bring azure costs, be aware and delete non wanted resources 

Write-Output "Welcome to easy test vm creator"
$numofvm = Read-Host -Prompt 'Please tell me desired Vm quantity'
$time = $_.BaseName + [datetime]::now.ToString('_yyyyMMdd_hhmmss') + $_.Extension
$resource = "eastgroup"
$resourcename = $resource + $time
Write-Output "Creating new Resource group called $resourcename"
New-AzResourceGroup -name $resourcename -Location eastus
$cred = Get-Credential 
$demosubnetConfig = New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix 10.3.0.0/24
$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName $resourcename -Location EastUS -Name $resourcename -AddressPrefix 10.3.0.0/16 -Subnet $demosubnetConfig
$VMname = Read-Host -Prompt 'Input your server name'
For ($i=1; $i -le $numofvm; $i++) {

  $VMnamesrv = $VMname + $i

  Write-Output "Creating server/VM $VMnamesrv - Hang tight this could take a while "

  $mypublicip = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

  $demoip = New-AzPublicIpAddress -ResourceGroupName $resourcename -Location EastUS -Name $VMnamesrv -AllocationMethod Dynamic

  $RuleConfig = New-AzNetworkSecurityRuleConfig -Name RuleRDPhttp -Protocol Tcp -Direction Inbound -Priority 300 -SourceAddressPrefix $mypublicip -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80,3389 -Access Allow

  $securitygroup = New-AzNetworkSecurityGroup -ResourceGroupName $resourcename -Location EastUS -Name $VMnamesrv -SecurityRules $RuleConfig

  $nic = New-AzNetworkInterface -Name $VMnamesrv -ResourceGroupName $resourcename -Location EastUS -SubnetId $VirtualNetwork.Subnets[0].Id -PublicIpAddressId $demoip.Id -NetworkSecurityGroupId $securitygroup.Id

  $vmConfig = New-AzVMConfig -VMName $VMnamesrv -VMSize Standard_B1s | Set-AzVMOperatingSystem -Windows -ComputerName $VMnamesrv -Credential $cred | Set-AzVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version latest | Add-AzVMNetworkInterface -Id $nic.Id

  New-AzVM -ResourceGroupName $resourcename -Location EastUS -VM $vmConfig

  Write-Output "Created server/VM $VMnamesrv , now installing IIS"

  Set-AzVMExtension -ResourceGroupName $resourcename  -ExtensionName "IIS" -VMName $VMnamesrv -Location "EastUS" -Publisher Microsoft.Compute  -ExtensionType CustomScriptExtension  -TypeHandlerVersion 1.8 -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

  Write-Output "IIS installed server/VM $VMnamesrv "

  Write-Output "Finished $VMnamesrv of $numofvm "

  }
Get-AzPublicIPAddress  -ResourceGroupName $resourcename | select Name,IpAddress
Write-Output "Dont forget to delete using Remove-AzResourceGroup"