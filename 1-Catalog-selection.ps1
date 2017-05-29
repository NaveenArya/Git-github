##Select Machine Catalog
#Function Catalog-Selection{
asnp citrix.*
NaveenaryaShinugserrordetails 
$CatalogName=""
Add-type -AssemblyName PresentationFramework

while ($CatalogName -eq "")
{
                $pools = @()
                
                Write-Host -ForegroundColor Yellow "Please select a catalog (by number) from the following list:"
                $ct=0
                
                try {
                                foreach($Catalog in Get-BrokerCatalog | Select -unique Name)
                                {
                                                $ct++;
                                                $CatNam = $Catalog.Name
                                                $pools += $CatNam
                                                Write-Host -ForegroundColor Gray "$ct : $CatNam"
                                                                                }
                }
                catch {
                                Write-Host "Failed to get Broker catalog"
                                Write-Log -me "failed to get Broker Catalog" -Level Error
                                Write-Host $_.Exception.ToString()
                                ExitScript
                }

                if ($ct -le 0)
       {
           Write-Host -ForegroundColor Red "No catalogs found"
           Write-Host "No catalogs found"
           Write-Log "No catalogs found exiting from script" -Level Error
           ExitScript
       }

                Write-Host
                Write-Host -ForegroundColor White -NoNewLine "Catalog Selection> "
          $Selection = Read-Host
          if($Selection -match "^\d+$")
                {
                $SelIdx = $Selection - 1

                if($SelIdx -lt 0 -or $SelIdx -ge $pools.count)
                    {
                    Write-Host
                    Write-Host -ForegroundColor Red "No such catalog"
                    Write-Log "No such catalog Please check the input" -Level Error

                    Write-Host
                    }
                    else
                    {
                    $CatalogName = $pools[$SelIdx]
                    Write-Host "Catalog Selected: $CatalogName"
                    }
      }
    else        
    {              
                    Write-Host
                    Write-Host -ForegroundColor Red "Invalid input"
                    Write-Log -Message "Please check the input value" -Level Error
                    Write-Host
    }
[System.windows.Messagebox]::Show("Catalog Selected: $CatalogName",'Input','YesNoCancel','Info')
}
#}
