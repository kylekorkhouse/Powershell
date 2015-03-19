$NamePattern = '^[A-Z]{8,15}_[0-9]{8}_[A-Z|a-z]{2}[0-9]{6}'
$SprtNamePattern = '^(SPRT_).'
$NameFamilies = @{}

#import SQL Server module
Import-Module SQLPS -DisableNameChecking

#replace this with your instance name
$instanceName = "APRPRODDB117\SPRTSQL2012"
#$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.
#Server -ArgumentList $instanceName

#Add the following script and run it:
$dbName = "CS_Manager"
#$db = $server.Databases[$dbName]

#execute a passthrough query, and export to a CSV file
$ReturnedROWS = (Invoke-Sqlcmd `
-Query "SELECT * FROM ps_getDBInfo()" `
-ServerInstance "$instanceName" `
-Database $dbName)

ForEach($Row in $ReturnedROWS)
{

    if(($Row.name -match $NamePattern) -or ($Row.name -match $SprtNamePattern)) 
    {
        Add-Member -NotePropertyName 'LegalName'  -NotePropertyValue "Y" `
          -inputObject $Row -TypeName String

        $divider = $Row.name.IndexOf('_');
        $nameFamily = $Row.name.SubString(0,$divider)
        Add-Member -NotePropertyName 'NameFamily' -NotePropertyValue $nameFamily `
            -inputObject $Row -TypeName String

        if($NameFamilies.ContainsKey($nameFamily))
        {
           # Write-Host "Dictionary already contains: " $nameFamily -ForegroundColor Cyan
            $oldCount = $NameFamilies.Values[$nameFamily]
           # Write-Host "==>Old Count is: "  $newCount
           # Write-Host "===>" $nameFamily
            $newCount = $NameFamilies.$nameFamily +1
            #Write-Host "==>New Count is: "  $newCount
            $NameFamilies.Set_Item($nameFamily,$newCount);

        }
        else
        {
           # Write-Host "Dictionary does not contain: " $nameFamily -ForegroundColor Yellow
            $NameFamilies.Add($nameFamily,1);


        }

    }else
    {
        Add-Member -NotePropertyName 'LegalName'  -NotePropertyValue "N" `
          -inputObject $Row -TypeName String

         
        if($Row.name.Length -gt 10)
        { 
            $divider = 10
        }
        else
        {
            $divider = $Row.name.Length
        } 
        
        Add-Member -NotePropertyName 'NameFamily' -NotePropertyValue ($Row.name.SubString(0,$divider)) `
            -inputObject $Row -TypeName String


        if($NameFamilies.ContainsKey($nameFamily))
        {
            #Write-Host "Dictionary already contains: " $nameFamily -ForegroundColor Cyan
            $oldCount = $NameFamilies.Values[$nameFamily]
           # Write-Host "==>Old Count is: "  $newCount
           # Write-Host "===>" $nameFamily
            $newCount = $NameFamilies.$nameFamily +1
           # Write-Host "==>New Count is: "  $newCount
            $NameFamilies.Set_Item($nameFamily,$newCount);


        }
        else
        {
            #Write-Host "Dictionary does not contain: " $nameFamily -ForegroundColor Yellow
            $NameFamilies.Add($nameFamily,1);



        }
    }

           #Select-Object -InputObject $Row -Property name,NameFamily,LegalName,create_date,RowsData,LogsData,IsBase,IsBig,IsOld | Sort-Object RowsData -Descending | Format-Table -AutoSize
            }
#$NameFamilies.GetEnumerator() | Sort-Object Value -Descending

$ListPath = 'C:\users\kk186019.td\desktop\DB_List1.csv'
$DupePath = 'C:\users\kk186019.td\desktop\Name_Ct1.csv'

Remove-Item $ListPath
Remove-Item $DupePath

ForEach($row in $ReturnedROWS)
{

    Add-Content -Path $ListPath -Value ($row.name+ ", " + $row.NameFamily + ", " + $row.LegalName + ", " + $row.create_date + ", " + $row.RowsData + ", " + $row.LogsData + ", " + $row.IsBase + ", " + $row.IsBig + ", " + $row.IsOld)
    

}


ForEach($item in $NameFamilies.GetEnumerator() | Sort-Object Value -Descending) {

    $out = $item.Key +"," + $item.Value
    Add-Content -Value $out -Path $DupePath 

 }
