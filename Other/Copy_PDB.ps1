$list = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]'

$masterList = Get-ChildItem 'I:\Source\9.0.12' -Recurse | Where-Object {$_.Extension -eq '.pdb' } 

foreach($o in $masterList){


    if(!($list.Keys.Contains($o.BaseName)))
    {
        $list.Add($o.BaseName, $o.FullName)

    }
}


foreach($o in $masterList)
{

    Write-Host "Copying file: " $o.BaseName -ForegroundColor Yellow
    Copy-Item -path $o.FullName -Destination \\PGSPRT94\C$\Users\kk186019\Desktop\Symbols\


}