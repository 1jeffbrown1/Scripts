# I setup a forwarded events on my domain controllers
# A single domain controller collects all events we want, in this case 4624,
# by making use of the Subscription feature in windows event logs
# These events are aggregated into a single event log called, Forwarded Events
# This script will parse the Archived logs and only pull out the information I want.

$SourceFilePath = '\\<redacted>\Forwarded$'
$ToProcessFilePath = $SourceFilePath + "\ToProcess"
$ProcessedFilePath = $SourceFilePath + "\Processed"

$EventLogs = Get-ChildItem $SourceFilePath | where {$_.name -like "Archive*"}
$EventLogs | Move-Item -Destination $ToProcessFilePath
$EventLogs = Get-ChildItem $ToProcessFilePath | where {$_.name -like "Archive*"}

foreach($Log in $EventLogs)
{
    $PathToLog = $Log.fullname
    $Events = Get-WinEvent -Path $PathToLog | where {$_.Id -eq '4624'}

    foreach($Event in $Events)
    {
        [xml]$xmlEvent = $Event.ToXml()

        $TargetUserSid = ($xmlevent.event.eventdata.data | where {$_.name -eq 'TargetUserSid'}).'#text'
        if($TargetUserSid -ne 'S-1-5-7' -and $TargetUserSid -notlike "<redacted>*")
        {
            $TD = $Event.TimeCreated.ToString("yyyy-MM-dd")

            $EventID = $Event.ID
            if($EventID -eq '4624'){$CSVLogFile = $ProcessedFilePath + "\$TD" + "_4624.csv"}
        
            $TimeCreated = $Event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            $TargetUserName = ($xmlevent.event.eventdata.data | where {$_.name -eq 'TargetUserName'}).'#text'
            $TargetDomainName = ($xmlevent.event.eventdata.data | where {$_.name -eq 'TargetDomainName'}).'#text'
            $LogonT = ($xmlevent.event.eventdata.data | where {$_.name -eq 'LogonType'}).'#text'
            $SourceIP = ($xmlevent.event.eventdata.data | where {$_.name -eq 'IpAddress'}).'#text'
            $DomainController = $xmlevent.event.system.computer

            $LogonType = switch ($LogonT){
            0 {'0 - System'}
            2 {'2 - Interactive'}
            3 {'3 - Network'}
            4 {'4 - Batch'}
            5 {'5 - Service'}
            7 {'7 - Unlock'}
            8 {'8 - NetworkClearText'}
            10 {'10 - RemoteInteractive'}
            11 {'11 - CachedInteractive'}
            default {"$LogonT - Unknown"}
            }

            $obj = [pscustomobject]@{
            TimeCreated = $TimeCreated
            DomainController = $DomainController
            Domain = $TargetDomainName
            UserName = $TargetUserName
            LogonType = $LogonType
            SourceIP = $SourceIP
            UserSID = $TargetUserSid
            }

            $obj | export-csv $CSVLogFile -Append -Force -NoTypeInformation
        }
    }
    Remove-Item -Path $PathToLog -Force -Confirm:$false
}

