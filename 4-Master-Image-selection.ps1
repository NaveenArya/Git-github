##Select master image
$MasterImages = Get-ChildItem -AdminAddress $adminAddress "XDHyp:\HostingUnits\$hostingunit" | Where-Object { $_.ObjectType -eq "VM"}
$Master = $MasterImages | select PSChildName
$VM = ""
while ($VM -eq "")
{
                $vms = @()
                
                Write-Host -ForegroundColor Yellow "Please select a snapshot (by number) from the following list:"
                $mt=0
                
                try {
                                foreach($mas in $Master)
                                {
                                                $mt++;
                                                $MasNam = $mas.PSChildName
                                                $vms += $MasNam
                                                Write-Host -ForegroundColor Gray "$mt : $MasNam"
                                }
                }
                catch {
                                Write-Host "Failed to Master image names"
                                Write-Host $_.Exception.ToString()
                                Write-Log "Failed to get Master Image name " -Level Crtical -ErrorAction Stop
                                ExitScript
                }

                if ($mt -le 0)
       {
           Write-Host "No master images found"
           Write-Log "Script failed to found the Master VM details" -Level Crtical -ErrorAction Stop
           ExitScript
       }

                Write-Host
                Write-Host -ForegroundColor White -NoNewLine "MasterImageName: "
          $Sel = Read-Host

          if($Sel -match "^\d+$")
                {
                $MIdx = $Sel - 1

                if($MIdx -lt 0 -or $MIdx -ge $vms.count)
                    {
                    Write-Host
                    Write-Host -ForegroundColor Red "Wrong master image Selection"
                    Write-log "Wrong Master Image selction" -Level Info
                    Write-Host
                    }
                    else
                    {
                    $VM = $vms[$MIdx]
                    #Write-Host "Master Image Selected: $VM"
                    Write-Log "Master image selcted : $VM" -Level Info
                    }
      }
    else        
    {              
                    Write-Host
                    Write-Host -ForegroundColor Red "Invalid input"
                    Write-Log "Wrong input" -Level Error
                    Write-Host
    }
}

