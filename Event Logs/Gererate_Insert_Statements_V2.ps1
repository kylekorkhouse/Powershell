Function GenerateEvtxInserts($LogFolder, $TargetDB){
        #This will generate a bat file to insert your logs
        #info about the functions available for the SQL statement below can be found here: http://logparserplus.com/Functions

        $DateAfter = '2015-01-01 00:00:00'
        $OutPath = $LogFolder + '\SQLInsert.bat'
        $CompletedStrings = New-Object -TypeName 'System.Collections.Generic.List[String]'

        $baseString = 'logparser "SELECT RecordNumber, ComputerName, TimeGenerated, EventTypeName, SourceName, EventLog,SUBSTR(Strings,0,250) as Str1,SUBSTR(Strings,251,502) as Str2,SUBSTR(Strings,503,753) as Str3 INTO ' + $TargetDB + ' FROM '''
        $tailString = ''' WHERE TimeGenerated > ''' + $DateAfter + '''" -i:EVT -o:SQL -createTable:ON -server:""ITPRODDB102\SPRTSQL2008R2"" -database:CS_LogOutput_KK186019 -username:Aprimo -password:aprimosprt -driver:"SQL Server Native Client 11.0"'


        #Remove Batch File if it already exists
        If (Test-Path $OutPath){
        	Remove-Item $OutPath
        }

        #Generate an Insert Statement for Each log file in the directory
        ChildItem $LogFolder -recurse  -filter "*.evt" | `
        ForEach-object{
                        $CompletedString = ($baseString + $_.FullName + $tailString)
                        $CompletedStrings.Add($CompletedString)
                      }
        #$CompletedStrings.Add("Pause");


        #Write the Completed batch file out to disk
        [System.IO.File]::WriteAllLines($OutPath, $CompletedStrings)

        Write-Host "Trying to execute file at " + $OutPath -ForegroundColor Yellow
        $A = Start-Process -FilePath "$OutPath" -Wait -passthru;$a.ExitCode
}

Function AddEvtxIndexes($TargetTable)
{
    #Creates indexes on tables created from log parsing inserts

    $DDL_List = New-Object 'system.collections.generic.dictionary[string,string]'

    $DDL_List.Add("SQL_Add_RowNum","ALTER TABLE $TargetTable ADD RowNum INT IDENTITY")

    $ixRowNum = "ix_" + $TargetTable + "RowNum"
    $DDL_List.Add("Add_ix_RowNum","CREATE CLUSTERED INDEX $ixRowNum  ON $TargetTable (RowNum)")

    $DDL_List.Add("$Add_HashID","ALTER TABLE $TargetTable ADD HashID AS CHECKSUM(Str1) PERSISTED")

    $ixHash = "ix_" + $TargetTable + "_Hash"
    $DDL_List.Add("Add_ix_HashID","CREATE INDEX $ixHash ON $TargetTable (HashID)")

    $DDL_List.Add("Add_Active","ALTER TABLE $TargetTable ADD Active binary(1)")

    $DDL_List.Add("Set_Active","UPDATE $TargetTable SET ACTIVE = 1")

    $ixActive = "ix_" + $TargetTable + "_Active"
    $DDL_List.Add("Add_ix_Active","CREATE INDEX $ixActive  ON $TargetTable  (Active)")

    $Server = "ITPRODDB102\SPRTSQL2008R2"
    $Database = "CS_LogOutput_KK186019"

    $Connection = New-Object 'System.Data.SQLClient.SQLConnection'
    $Connection.ConnectionString = "server='$Server';database='$Database';trusted_connection=true;"
    $Connection.Open()



    foreach($DDL_Statement in $DDL_List.Values )
    {
        $Command = New-Object 'System.Data.SQLClient.SQLCommand'
        $Command.Connection = $Connection
        
        Write-Host "Executing statement: " + $DDL_Statement + "..." 
        $Command.CommandText = $DDL_Statement
        $Command.ExecuteNonQuery()
    }

    $Connection.Close()


}

#GenerateEvtxInserts 'C:\Users\KK186019.TD\Desktop\FT_Logs_03182014' 'FT_Logs'
AddEvtxIndexes 'FT_Logs'