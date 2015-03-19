$Script:InputList = New-Object -TypeName System.Collections.Generic.List[string] 
$Script:ProposedNames = New-Object -TypeName System.Collections.Generic.List[string] 
[System.String]$Script:RootDir

function IsolateServerNameFromPath ($file) 
{ 
    return $file.Substring($file.IndexOf('SVR'),8);   
}

function GatherEventLogLocations ($LogFolder)
{
    $Script:RootDir = $LogFolder
    Get-ChildItem $LogFolder -recurse | `
    Where-Object {($_.Extension -eq '.evtx') -or ($_.Extension -eq '.evt')} | `
    ForEach-Object { $Script:InputList.Add($_.FullName)}
}

function CreateNewLogNames()
{
    forEach($fp in $Script:InputList)
    {
        $newName = IsolateServerNameFromPath($fp);
        $oldFileName = [System.IO.Path]::GetFileName($fp)
        $newName = $newName + "_" + $oldFileName
        $Script:ProposedNames.Add($newName);
    }

}

function moveLogsToRoot()
{
    forEach($fp in $Script:InputList)
    {
        $id = $Script:InputList.IndexOf($fp);
        $fileName = $Script:ProposedNames.Item($id);

        Move-Item -Path $fp -Destination "$Script:RootDir\$fileName"
     }
}

GatherEventLogLocations 'C:\Users\KK186019.TD\Desktop\RECGCS5ZE'
CreateNewLogNames
moveLogsToRoot



