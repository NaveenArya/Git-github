###Enter the Detials of CRQ
#####Importing of Modules
#Catalog Selection
#Import-Module -DisableNameChecking 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\ImageUpdate\Catalog-selection.psm1'
#Catalog-Selection


##Fetching the details of Unrefistered and agent error VM.
$VM= Get-BrokerDesktop -MaxRecordCount 500 | ? {($_.CatalogName -eq $CatalogName -and $_.RegistrationState -eq 'Unregistered' -and $_.PowerState -eq 'On') -or ($_.CatalogName -eq $CatalogName -and $_.RegistrationState -eq 'AgentError' -and $_.PowerState -eq 'On') }| Select-Object MachineName, @{l="associatedusernames";e={$_.associatedusernames -join ""}}
Write-Host -ForegroundColor Yellow $VM

$CRQ = Read-host "Enter the CRQ Details" 

#Fetching the Active and disconnect session and sending log off message
for($Rep=0;$Rep -lt 3;$Rep++)
{
$details=Get-BrokerSession -MaxRecordCount 200 |?{($_.CatalogName -eq $CatalogName) -and {($_.SessionState -eq 'Disconnected' ) -or ($_.SessionState -eq 'Active')} }| Select-Object Uid  

foreach($uid in $details)
{
Send-BrokerSessionMessage $uid  -MessageStyle Information -Title $CRQ -Text 'Please save your work and logoff your session as we are starting' 
 }
 sleep 30
}


#####Logofff of VM

Get-BrokerSession -MaxRecordCount 500|? {$_.CatalogName -eq $CatalogName} |Stop-BrokerSession 
Sleep (6*10)
$MachineName =(Get-BrokerDesktop -MaxRecordCount 500|? {$_.CatalogName -eq $CatalogName}).MachineName
Write-Output  'Script will poweroff the'$MachineName

Foreach($hostVM in $MachineName){

Set-BrokerMachineMaintenanceMode -InputObject $hostVM $true
New-BrokerHostingPowerAction -Action Shutdown -MachineName $hostVM
Sleep (10)
}

# Get the broker connection to the hypervisor management
$brokerHypConnection = Get-BrokerHypervisorConnection -AdminAddress $adminAddress -HypHypervisorConnectionUid $hostConnection.HypervisorConnectionUid

# Set a provisioning scheme for the update process
$ProvScheme = Set-ProvSchemeMetadata -AdminAddress $adminAddress -Name 'ImageManagementPrep_DoImagePreparation' -ProvisioningSchemeName $CatalogName -Value 'True'

# Publish the image update to the machine catalog
$PubTask = Publish-ProvMasterVmImage -AdminAddress $adminAddress -MasterImageVM $TargetSnapshot.FullPath -ProvisioningSchemeName $CatalogName -RunAsynchronously
$provTask = Get-ProvTask -AdminAddress $adminAddress -TaskId $PubTask

# Track progress of the image update
Write-Verbose "Tracking progress of the machine creation task."
$totalPercent = 0
While ( $provTask.Active -eq $True ) {
        Try { 
    
   $totalPercent = If ( $provTask.TaskProgress ) { $provTask.TaskProgress } Else {0} 
    
  
 while($totalPercent -le 100)
  
  {

  
Function Global:Send-Email { 
[cmdletbinding()]
 Param (
[Parameter(Mandatory=$False,Position=0)]
[String]$Sendto= 'naveen.arya@bp.com',
[Parameter(Mandatory=$False,Position=1)]
[String]$username = "<doNotReply@bp.com>",
[Parameter(Mandatory=$False,Position=2)]
[String]$Subject = "$CRQ-VDi Image Update Progress Status",
[Parameter(Mandatory=$False,Position=3)]
[String]$Body ="[This is an auto-generated email.  Please DO NOT reply.]

VDI image update Progress Status is  $totalPercent% Complete
Regards,
Rubicon L3 Support Team
"

      )

Begin {
Clear-Host
    }
Process {

$SMTPServer = "smtp-apps03.dsc.bp.com"
$message = New-Object System.Net.Mail.MailMessage
$message.subject = $Subject
$message.body =$Body
$message.to.add($Sendto)
#$message.cc.add($cc)
$message.from = $username
 $smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer);
$smtp.EnableSSL = $true
$smtp.send($message)
write-host "Mail Sent" 
sleep 900 
} 
} 

Send-Email 

}
  }


Catch {

            Write-Host "Failed to get Update Progress "
            Write-Host $_.Exception.ToString()
            ExitScript
                }

    Write-Progress -Activity "Provisioning image update" -Status "$totalPercent% Complete:" -percentcomplete $totalPercent
    Sleep 15
   $provTask = Get-ProvTask -AdminAddress $adminAddress -TaskId $PubTask
}

# Start the desktop reboot cycle to get the update to the actual desktops
Start-BrokerRebootCycle -AdminAddress $adminAddress -InputObject @($CatalogName) -RebootDuration 0 

Foreach($hostVM in $MachineName){

Set-BrokerMachineMaintenanceMode -InputObject $hostVM $False
New-BrokerHostingPowerAction -Action Restart -MachineName $hostVM
Sleep (10)
}
