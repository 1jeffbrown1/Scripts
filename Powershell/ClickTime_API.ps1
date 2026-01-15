function Set-FTE()
{
    $ETID = '4aikevn894XpBwCigNNelVQ2'

    if ($ETID -ne $CTUserETID)
    {
        $Body = @{
        EmploymentTypeID="$ETID"
        } | ConvertTo-Json

        $Results = Invoke-RestMethod -Uri "https://api.clicktime.com/v2/Users/$CTUserID" -Headers $Headers -Body $Body -Method Patch -ContentType "application/json"
    }
}

function Set-CTR()
{
    $ETID = '4EX3mnzk9nRWolLf7bppWIQ2'

    if ($ETID -ne $CTUserETID)
    {
        $Body = @{
        EmploymentTypeID="$ETID"
        } | ConvertTo-Json

        $Results = Invoke-RestMethod -Uri "https://api.clicktime.com/v2/Users/$CTUserID" -Headers $Headers -Body $Body -Method Patch -ContentType "application/json"
    }
}

$AuthToken = '<redacted>'  #service account

$Headers = @{
Authorization="Token $AuthToken"
}

$AllClickTimeUsers = (Invoke-RestMethod -Uri 'https://api.clicktime.com/v2/users' -Headers $headers -Method Get -ContentType "application/json").data
$CSVUsers = Import-Csv C:\temp\ClickTime_Users.csv

foreach($CSVUser in $CSVUsers)
{
    $EType = $CSVUser.'Employment Type'
    $EN = $CSVUser.'Employee Number'

    $CTUser = $AllClickTimeUsers | where {$_.EmployeeNumber -like $EN}

    if(($CTUser | measure).count -eq 1)
    {
        $CTUserID = $CTUser.ID
        $CTUserETID = $CTUser.EmployementTypeID

        switch ($EType){
        "Employee"   {Set-FTE}
        "Contractor" {Set-CTR}
        }
    }
}

