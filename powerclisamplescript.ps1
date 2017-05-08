Add-PSSnapin VMware.VimAutomation.Core

# Connect to VSphere Server
Connet-ViServer <Vsphere Server> # DO it before Running the script, though it can be added to the SCRIPT As well

#Server Name and ESXi BUILD Details

echo "Build Details " | Out-File -Append details.txt
$details=get-view -ViewType HostSystem -Property Name,Config.Product | Select Name, @{Name="Build";Expression={$_.Config.Product.FullName}}
$details | Out-File -Append details.tx
echo "==============================================================" |  Out-File -Append details.txt

foreach($line in $details)
{
  Write-Output ($line.Name + "-- NETWORK DETAILS") | Out-File -Append details.txt
  Get-VMHost $line.Name | Get-VMHostNetworkAdapter  | Select Name,IP,Mac,PortGroupName,vMotionEnabled,mtu | Format-Table |  Out-File -Append details.txt
  echo "============================================================================================" | Out-File -Append details.txt
}

# Get the LICENSE DETAILS                                                                                                    
$ServiceInstance=Get-View ServiceInstance
$LicenseMan=Get-View $ServiceInstance.Content.LicenseManager
$vSphereLicInfo= @()
Foreach ($Licensein$LicenseMan.Licenses){
   $LicDetails="" |Select Name, Key, Total, Used,Information
   $LicDetails.Name=$License.Name
   $LicDetails.Key=$License.LicenseKey
   $LicDetails.Total=$License.Total
   $LicDetails.Used=$License.Used
   $LicDetails.Information=$License.Labels
   $vSphereLicInfo+=$LicDetails
}
$vSphereLicInfo |Select Name, Key, Total, Used | Out-File -Append details.txt

# SSH Service Details
foreach($line in $details)
{
  $VMName = $line.Name
  $SSHServiceStatus = (Get-VmHostService $VMName |   Where-Object {$_.Label -Like "SSH" }).Running
  if ($SSHServiceStatus -eq $FALSE)
    {
      $SSHStatus = "NotRunning"
    }
  else {
      $SSHStatus = "Running"
    }
  Write-Output ("SSH Service on " + $VMName + " " + $SSHStatus ) | Out-File -Append details.txt
}

