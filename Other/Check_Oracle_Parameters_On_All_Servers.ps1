$ServerList = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]'

$ServerList.Add('9.0.1','pgsprt45');
$ServerList.Add('9.0.2','pgsprt56');
$ServerList.Add('9.0.3','pgsprt59');
$ServerList.Add('9.0.4','pgsprt68');
$ServerList.Add('9.0.5','pgsprt70');
$ServerList.Add('9.0.6','pgsprt77');
$ServerList.Add('9.0.7','pgsprt73');
$ServerList.Add('9.0.8','pgsprt78');
$ServerList.Add('9.0.9','pgsprt79');
$ServerList.Add('9.0.10','pgsprt80');
$ServerList.Add('9.0.11','pgsprt81');
$ServerList.Add('9.0.12','pgsprt82');
$ServerList.Add('9.0.13','pgsprt83');
$ServerList.Add('9.0.14','pgsprt84');
$ServerList.Add('9.0.15','pgsprt85');
$ServerList.Add('9.0.16','pgsprt88');
$ServerList.Add('9.0.17','pgsprt91');
$ServerList.Add('9.0.18','pgsprt93');
$ServerList.Add('9.0.19','pgsprt94');
$ServerList.Add('9.0.20','sprtsvr100');
$ServerList.Add('9.0.21','sprtsvr103');
$ServerList.Add('9.1.0','pgsprt96');
$ServerList.Add('9.1.2','sprtsvr104');




$ComputerName =@('PGSPRT73','PGSPRT77')
$Name = 'Path'
$PathFilterString = '%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;'

# Instantiate the variable
$Report = @() 
# Then for each disk you want to add:
<#
$Report += New-Object PSOBject -Property @{
                                        "ComputerName" = (Get-DiskName) # Put the function here
                                        "ENV:Path" = (Get-DiskSize) # Disk size - remember to format!
                                        "ENV:Oracle_Home" = (Get-FreeSpace) # same again
                                        "ENV:TNS_ADMIN" = (Get-DiskSize) # Disk size - remember to format!
                                        "REG:TNS_ADMIN" = (Get-FreeSpace) # same again
                                        "REG:Oracle_Home" = (Get-FreeSpace) # same again
                                        "FS:NetWorkAdminExists" = (Get-FreeSpace) # same again
                                             }
#>
foreach($Key in $ServerList.Keys) {
    $Computer = $ServerList.Item($Key); 
    #Confirm Computer is online
    if(!(Test-Connection -ComputerName $Computer -Count 1 -quiet)) {  Continue } 
    
    #Output Computer Name
    Write-Host " "
    Write-Host "`t`t`t`t`t"  $Key " / " $Computer -ForegroundColor Yellow
    Write-Host "=============================================================" -ForegroundColor Yellow
    
    try { 
        #Get WMI Environment Objects
        $EnvObj = @(Get-WMIObject -Class Win32_Environment -ComputerName $Computer -EA Stop) 
        
        #Write-Verbose "Successfully queried $Computer" 
         

        #$Path= $EnvObj | Where-Object {$_.Name -eq 'PATH'}  
        $OraHome = $EnvObj | Where-Object {$_.Name -eq 'ORACLE_HOME'}  
        $T_ADMIN = $EnvObj | Where-Object {$_.Name -eq 'TNS_ADMIN'}  
        $PathSearch = $EnvObj | Where-Object {$_.Name -eq 'Path'}
        $PathLocationA = $PathSearch.VariableValue.Contains('c:\oracle\odac64\')
        $PathLocationB = $PathSearch.VariableValue.Contains('c:\oracle\odac64\bin\')
        if(!$Env) { 
                    Write-Verbose "$Computer has no environment variable with name $Name" 
                Continue 
            } 
            
             Write-Host "[Environment Variable]: ORACLE_HOME = "  $OraHome.VariableValue -ForegroundColor Magenta
             Write-Host "[Environment Variable]: TNS_ADMIN = " $T_ADMIN.VariableValue -ForegroundColor Magenta
             Write-Host "[Environment Variable.Path]: Includes c:\oracle\odac64\bin\ = "  $PathLocationA.ToString() -ForegroundColor Magenta
             Write-Host "[Environment Variable.Path]: Includes c:\oracle\odac64\ = "  $PathLocationB.ToString() -ForegroundColor Magenta
            if([System.IO.FILE]::Exists('\\PGSPRT77\C$\oracle\odac64\network\admin\tnsnames.ora')) 
            {
             Write-Host "TNS File Correctly Placed = True" -ForegroundColor Green

            }else
            {

             Write-Host "TNS File Correctly Placed = False" -ForegroundColor Red
            }
               
                $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
                $RegKey= $Reg.OpenSubKey("SOFTWARE\\Oracle\\KEY_odac64")
                $Reg_OracleHome = $RegKey.GetValue("ORACLE_HOME")
                $Reg_TNSAdmin = $RegKey.GetValue("TNS_ADMIN")    

             Write-Host "[Registry Key] ORACLE_HOME = "  $Reg_OracleHome -ForegroundColor Cyan
             Write-Host "[Registry Key] TNS_ADMIN = "  $Reg_TNSAdmin -ForegroundColor Cyan
             Write-Host "=============================================================" -ForegroundColor Yellow
             Write-Host ""
             
    } catch {  
        Continue 
    } 
 
}

