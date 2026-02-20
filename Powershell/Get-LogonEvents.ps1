# Have to be a domain admin
# have to be logged into a domain controller
# logon events are collected and parsed from the domain controller you are logged into.

$SeedDateTime = (get-date -hour 0 -minute 0 -Second 0).AddDays(-1)
$HN = Hostname

Function Get-LogonEvents
{
    $StartDateTime = $SeedDateTime.AddHours($x)
    $EndDateTime =  $StartDateTime.AddHours($y)
    $FileName = "$HN" + "_" + $StartDateTime.ToString("yyyy-MM-dd_HH.mm.ss") + ".csv"

    $Filter = @{
    LogName      = 'Security'
    ProviderName = 'Microsoft-Windows-Security-Auditing'
    StartTime    = $StartDateTime
    EndTime      = $EndDateTime
    ID           = 4624
    }
    $Events = Get-WinEvent -FilterHashtable $Filter
    
    $AllData = New-Object System.Collections.ArrayList
    foreach($Event in $Events)
    {
        $xmlEvent = [xml]$Event.toxml()

        $Username = $xmlEvent.event.eventdata.data | where Name -eq 'TargetUserName' | select -ExpandProperty '#text'
        if ($Username -like "*`$"){$AccountType = 'Computer'}else{$AccountType = 'User'}
        
        $obj = [pscustomobject]@{
        Domain      = $xmlEvent.event.eventdata.data | where Name -eq 'TargetDomainName' | select -ExpandProperty '#text'
        UserName    = $Username
        AccountType = $AccountType
        SourceWks   = $xmlEvent.event.eventdata.data | where Name -eq 'WorkstationName' | select -ExpandProperty '#text'
        SourceIP    = $xmlEvent.event.eventdata.data | where Name -eq 'IpAddress' | select -ExpandProperty '#text'
        LogonType   = $xmlEvent.event.eventdata.data | where Name -eq 'LogonProcessName' | select -ExpandProperty '#text'
        AuthPkg     = $xmlEvent.event.eventdata.data | where Name -eq 'AuthenticationPackageName' | select -ExpandProperty '#text'
        }
        $AllData.Add($obj) | out-null
    }
    # Creating a csv file per 1 hour block of logon activity
    $AllData | export-csv "F:\LogonEvts\$Filename" -NoTypeInformation
}

# Get logon events for entire day, yesterday
for($x = 0; $x -le 23; $x++)
{
    $y = $x + 1

    Get-LogonEvents
    Write-host "$x is done"
}

# Process each csv, and get unique entries, per csv
$LogFiles = Get-ChildItem -Path F:\LogonEvts
$ADUnique = New-Object System.Collections.ArrayList
foreach($File in $LogFiles)
{
    $Events = import-csv $file.fullname | where {$_.domain -like "FNBM*" -and $_.username -notlike "*`$"} | select Domain,UserName,SourceIP -Unique
    foreach($E in $Events){$ADUnique.Add($E) | out-null}
}

$UniqueUN = $ADUnique | select Domain,UserName,SourceIP -Unique | sort UserName
$FileName = "$HN" + "_" + $StartDateTime.ToString("yyyy-MM-dd") + "_Unique.csv"
$UniqueUN | export-csv "F:\LogonEvts\$Filename" -NoTypeInformation

