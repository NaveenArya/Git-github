##Select target snapshot
$Snap = ""
$MI = $MasterImages | Where-Object { $_.ObjectType -eq "VM" -and $_.PSChildName -eq "$VM" }
$VMSnapshots = Get-ChildItem -AdminAddress $adminAddress $MI.FullPath -Recurse -Include *.snapshot
$Snapshot =  $VMSnapshots | select FullName
while ($Snap -eq "")
{
                $lists = @()
                
                Write-Host -ForegroundColor Yellow "Please select a Latest snapshot (by number) from the following list:"
                $st=0
                
                try {
                                foreach($Sp in $Snapshot)
                                {
                                                $st++;
                                                $snapNam = $Sp.FullName
                                                $lists += $snapNam
                                                Write-Host -ForegroundColor Gray "$st : $snapNam"
                                }
                }
                catch {
                                Write-Host "Failed to getsnapshot names"
                                Write-Host $_.Exception.ToString()
                                Write-Log "Failed to get the snapshots details" -level Crtical -ErrorAction Stop
                                ExitScript
                }

                if ($st -le 0)
       {
           Write-Host "No snapshots found"
           ExitScript
       }

                Write-Host
                Write-Host -ForegroundColor White -NoNewLine "Snapshotname: "
          $Select = Read-Host
          if($Select -match "^\d+$")
                {
                $SIdx = $Select - 1

                if($SIdx -lt 0 -or $SIdx -ge $lists.count)
                    {
                    Write-Host
                    Write-Host -ForegroundColor Red "Wrong snapshot Selection"
                    Write-Log "Enter the valid input" -Level Info
                    Write-Host
                    }
                    else
                    {
                    $Snap = $lists[$SIdx]
                    Write-Host "Snapshot Selected: $Snap"
                    Write-Log "Snapshot Selected is $Snap" -Level Info
                    }
      }
    else        
    {              
                    Write-Host
                    Write-Host -ForegroundColor Red "Invalid input"
                    Write-Log "Enter the valid input"
                    Write-Host
    }
}

$TargetSnapshot = $VMSnapshots | Where-Object { $_.FullName -eq "$Snap" }