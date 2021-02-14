$resourcegroup = Read-Host "Please enter your resource-group"
$VMname = Read-Host "Please enter your VMname"
$image = Read-Host "Please enter your image"
$adminusername = Read-Host "Please enter your admin-username"
$adminpassword = Read-Host "Please enter your admin-password"
$location = Read-Host "Please enter your location"
az vm create --resource-group $resourcegroup --name $VMname --image $image --admin-username $adminusername --admin-password $adminpassword --location $location
Write-Host "Congratulations! Your VM $VMname Created"