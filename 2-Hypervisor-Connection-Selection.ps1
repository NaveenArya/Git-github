##Connection to Hypervisor
$hostResource=""
$pschileName=Get-ChildItem -AdminAddress $adminAddress "XDHyp:\Connections" |Select -unique PSChildName

while ($hostResource -eq "")
{
                $pools = @()
                
                Write-Host -ForegroundColor Yellow "Please select a hostResource (by number) from the following list:"
                $ct=0
                
                try {
                                foreach($hsresource in $pschileName)
                                {
                                                $ct++;
                                                $hostNam = $hsresource.PSChildName
                                                $pools += $hostNam
                                                Write-Host -ForegroundColor Gray "$ct : $hostNam"
                                }
                }
                catch {
                                Write-Host "Failed to get Host Resource name"
                                Write-Log "unable to fetch hostanme resource name " -LeveL Crtical
                                Write-Host $_.Exception.ToString()
                                ExitScript
                }

                if ($ct -le 0)
       {
           Write-Host -ForegroundColor Red "Wrong host resource name"
           Write-Log "host Resource name is incorrect" -Level Error
           ExitScript
       }

                Write-Host
                Write-Host -ForegroundColor Yellow -NoNewLine "HostResourcename: "
          $Selection = Read-Host
          #Write-Log "Reading of host is completed"
                if($Selection -match "^\d+$")
                {
                $SelIdx = $Selection - 1

                if($SelIdx -lt 0 -or $SelIdx -ge $pools.count)
                    {
                    Write-Host
                    Write-Host -ForegroundColor Red "Wrong HostResource name Selection"
                    Write-Log 'Selection of Host Resource is incorrect' -Level Info -WarningAction SilentlyContinue
                    Write-Host
                    }
                    else
                    {
                    $hostResource = $pools[$SelIdx]
                    Write-Host "HostResource Selected: $hostResource"
                    Write-Log 'HostName is slelected from the given options' -Level Info
                    }
      }
    else        
    {              
                    Write-Host
                    Write-Host -ForegroundColor Red "Invalid input"
                    Write-Log 'Invalid  input' -Level Error 
                    Write-Host
    }
}

$hostConnection = Get-ChildItem -AdminAddress $adminAddress "XDHyp:\Connections" | Where-Object { $_.PSChildName -like $hostResource }



