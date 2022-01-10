function tider {
    Get-EventLog -LogName Application -After "2017-08-01" | Group-Object { $_.TimeGenerated.Date } |  % { $_.Group | Sort TimeGenerated | Select -First 1 -Last 1 | Group-Object { $_.TimeGenerated.Date.ToString("yyyy-MM-dd") } } | Sort-Object Name | % { 
        Write-Host "$($_.Name): $($_.Group[0].TimeGenerated.ToString("HH:mm")) - $($_.Group[1].TimeGenerated.ToString("HH:mm"))" 
    }  
} 
  
function diskinfo { 
    Get-WmiObject Win32_LogicalDisk | Where-Object {$_.Size -gt 0} | % { Write-Host $_.DeviceID $([math]::Round(100*(1- $_.FreeSpace/$_.Size))) % använt } 
} 
  
function anv ($givenName, $surname) { 
    import-module activedirectory 
    Get-ADUser -f { GivenName -eq $givenName -and Surname -eq $surname } | % { Write-Host $_.SamAccountName } 
} 
  
function anv2 ($samAccountName) { 
    import-module activedirectory 
    Get-ADUser -f { SamAccountName -eq $samAccountName } | % { Write-Host $_.GivenName $_.Surname } 
} 
