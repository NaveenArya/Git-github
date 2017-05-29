##Hosting(Storage) connection selection
Write-Verbose "Gathering storage and hypervisor connections from the XenDesktop infrastructure."
$hosting= Get-ChildItem -AdminAddress $adminAddress "XDHyp:\HostingUnits" | Select -Unique PSChildName
$hostingUnit=""


while ($hostingUnit -eq "")
{
                $pools = @()
                
                Write-Host -ForegroundColor Yellow "Please select a hosting Unit (by number) from the following list:"
                $ct=0
                
                try {
                                foreach($hostingName in $hosting)
                                {
                                                $ct++;
                                                $hostName = $hostingName.PSChildName
                                                $pools += $hostName
                                                Write-Host -ForegroundColor Gray "$ct : $hostName"
                                }
                }
                catch {
                                Write-Host "Failed to get HostingUnit"
                                Write-Host $_.Exception.ToString()
                                Write-Log "Failed to get HostingUnit" -Level Crtical -ErrorAction Stop
                                ExitScript
                }

                if ($ct -le 0)
       {
           Write-Host -ForegroundColor Red "Wrong Hosting Unit name"
           Write-Log "Please check the Hosting Unit Name" -Level Warning
           ExitScript
       }

                Write-Host
                Write-Host -ForegroundColor Cyan -NoNewLine "HostingUnit: "
          $Selection = Read-Host
          if($Selection -match "^\d+$")
                {
                $SelIdx = $Selection - 1

                if($SelIdx -lt 0 -or $SelIdx -ge $pools.count)
                    {
                    Write-Host
                    Write-Host -ForegroundColor Yellow  "Wrong HostResource name Selection"
                    Write-Log "Wrong HostResource name Selection" -Level Info

              
                    }
                    else
                    {
                    $HostingUnit = $pools[$SelIdx]
                    Write-Host "HostingUnit Selected: $hostingUnit"
                    write-log "Selected hosing Unit is $hostingUnit" -Level Info
                    }
      }
    else        
    {              
                    Write-Host
                    Write-Host -ForegroundColor Red "Invalid input"
                    Write-log "Invalid Input" -Level Crtical
                    Write-Host
    }
}