Update-TypeData -TypeName System.Io.FileInfo -MemberType ScriptProperty -MemberName FileVersionUpdated -Value {

    New-Object System.Version -ArgumentList @(
        $this.VersionInfo.FileMajorPart
        $this.VersionInfo.FileMinorPart
        $this.VersionInfo.FileBuildPart
        $this.VersionInfo.FilePrivatePart
    )

}

function buildString($inputName, $inputLastTime, $inputLength, $inputFileVersion, $inputFullName, $inputFileName)
{
    $sb = New-Object -TypeName 'System.Text.StringBuilder'

    $sb.Append($inputName);$sb.Append(', ');

    ##Using Time was making too many differences
    #$sb.Append($inputLastTime);$sb.Append(', ');
    $sb.Append($inputLength);$sb.Append(', ');
    $sb.Append($inputFileVersion);
    $sb.Append('               ')

    #Control output File Name Here
    [System.String]$inputFileName = [System.String]$inputFileName.Replace('.txt','_noTimes.txt')
    
    Add-Content -Value $sb.ToString() -Path $inputFileName

 


}


$Global:basePath = 'C:\Users\KK186019.TD\Desktop\Friday Desktop\Caesars Files\'

$DirectotyList = @(Get-ChildItem 'C:\Users\KK186019.TD\Desktop\Friday Desktop\Caesars Files'  | Where-Object { $_.PSIsContainer -eq $true } | Select-Object -ExpandProperty FullName)

foreach($Dir in $DirectotyList)
{

    $subDirs = @(Get-ChildItem $Dir | Where-Object {$_.PSIsContainer -eq $true} | Select-Object -ExpandProperty FullName)
    foreach($subDir in $subDirs)
    {
        


        if([System.IO.Directory]::Exists([System.String]::Concat($subDir,'\bin')) -eq $true)
		{
        #Make File Name      
        [System.String]$fileName = $subDir.Remove(0,58)
        $filename = $fileName.Replace('\','_')
        $fileName = [System.String]::Concat($fileName,'.txt')
        #Write-Host $fileName -ForegroundColor Red
        $fileName = [System.String]::Concat($Global:basePath,$fileName)
        #//Make File Name

        Get-ChildItem $subDir\bin | Where-Object {$_.Extension -eq '.dll'} | Sort-Object -Property Name | ForEach-Object { buildString $_.Name $_.LastWriteTime $_.Length $_.FileVersionUpdated $_.FullName $fileName }

		}
	}
  
}


