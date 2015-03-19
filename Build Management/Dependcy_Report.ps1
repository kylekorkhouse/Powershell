<#
Function Get-ProjectReferences ($rootFolder)
{
    
    $projectFiles = Get-ChildItem $rootFolder -Filter *.csproj -Recurse
    $ns = @{ defaultNamespace = "http://schemas.microsoft.com/developer/msbuild/2003" }

    $projectFiles | ForEach-Object {
        $projectFile = $_ | Select-Object -ExpandProperty FullName
        Write-Host $projectFile -ForegroundColor Yellow
        $projectName = $_ | Select-Object -ExpandProperty BaseName
        Write-Host $projectName -ForegroundColor Yellow
        $projectXml = [xml](Get-Content $projectFile)

        $projectReferences = $projectXml | Select-Xml '//defaultNamespace:ProjectReference/defaultNamespace:Name' -Namespace $ns | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty "#text"
        $DLLReferences = $projectXml | Select-Xml '//defaultNamespace:Reference/defaultNamespace:HintPath' -Namespace $ns | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty "#text"
        
        $projectReferences | ForEach-Object {
            "Project Reference [" + $projectName + "] -> [" + $_ + "]"
        }
        $DLLReferences | ForEach-Object {
            "DLL Reference [" + $projectName + "] -> [" + $_ + "]"
        }
    }
}
#>

Function Get-ProjectReferencesReport ($rootFolder)
{
    
    $projectFiles = Get-ChildItem $rootFolder -Filter *.csproj -Recurse
    $ns = @{ defaultNamespace = "http://schemas.microsoft.com/developer/msbuild/2003" }

    $projectFiles | ForEach-Object {
        $projectFile = $_ | Select-Object -ExpandProperty FullName
        #Write-Host $projectFile -ForegroundColor Yellow
        $projectName = $_ | Select-Object -ExpandProperty BaseName
        #Write-Host $projectName -ForegroundColor Yellow
        $projectXml = [xml](Get-Content $projectFile)

        $projectReferences = $projectXml | Select-Xml '//defaultNamespace:ProjectReference/defaultNamespace:Name' -Namespace $ns | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty "#text"
        $DLLReferences = $projectXml | Select-Xml '//defaultNamespace:Reference/defaultNamespace:HintPath' -Namespace $ns | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty "#text"
        
        "###" + $projectFile + "###"

        "Project References:"
        $projectReferences | ForEach-Object {
            "`t`t-> [" + $_ + "]"
        }
        "DLL References:"
        $DLLReferences | ForEach-Object {
            "`t`t-> [" + $_ + "]"
        }
        "########################################################"
        "                                    "
    }
}

Function BackupOriginalFile($FilePath)
{
    $a = Get-Date
    $a = $a.ToShortDateString().Replace('/','_')
    $tag = $a.ToString() + '.bak'
    $NewFileName = $FilePath.Replace('.csproj','.') + $tag
    Write-Host $NewFileName
    Copy-Item $FilePath $NewFileName


}

##=====================================================================
##NO CHANGES ABOVE##
##=====================================================================

$ProjFiles = @(Get-ChildItem -recurse 'C:\Users\KK186019.TD\Desktop\Reckett Config Mover' | Where-Object {$_.extension -eq '.csproj'} | Select-Object -property Fullname)

#ForEach($file in $ProjFiles){
   # $_p = (Split-Path -Path $file -Parent)
    #$_p = $_p.Remove(0,11)
   # $_p = $_p + '\References_Report.txt'
    #$file = $file | Select-Object -ExpandProperty FullName

   # Write-Host "Searching for references in " + $file -ForegroundColor Yellow
   # Write-Host "Results written to " + $_p -ForegroundColor Cyan

   # Get-ProjectReferencesReport $file | Out-File $_p
#}

#Get-ProjectReferencesReport "I:\873 Source\_XML_Listener\Business" | Out-File "I:\873 Source\_XML_Listener\Business.txt"
#Get-ProjectReferencesReport "I:\873 Source\_XML_Listener\Diagnostics" | Out-File "I:\873 Source\_XML_Listener\Diagnostics.txt"
#Get-ProjectReferencesReport "I:\873 Source\_XML_Listener\XMLListener" | Out-File "I:\873 Source\_XML_Listener\xmlListener.txt"
#Get-TestStub "I:\9015_Source_Full\Aprimo\Admin"

#Get-ProjectReferencesReport "I:\9.0.20 BOA Customizations" | Out-File "I:\9.0.20 BOA Customizations\References.txt"
$OriginalFile = 'I:\9.0.20 BOA Customizations\Aprimo.AGS.BofA.ADIMUserExport.Service\Aprimo.AGS.BofA.ADIMUserExport.Service.csproj'

BackupOriginalFile $OriginalFile