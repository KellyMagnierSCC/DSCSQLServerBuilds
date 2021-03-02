# prep server for DSC commands
# This script sets the permissions on the mount points for the sql server service account 
# as well as installing the modules needed and referenced by DSC onto the target machine
Function LogWrite {
        Param ([string]$logstring, [string]$loglevel)
        $logDate = (get-date).ToString("d.M.yyyy hh:mm tt")
        Add-content $Logfile -value $logDate`t$loglevel`t`t$logstring
    
}
$Environment = Read-Host -Prompt "Environment to process - DEV, PROD, TRN"
$log_date = (get-date).ToString("yyyyMMdd-HHmm")
    
    
If ($Environment -ne 'DEV' -and $Environment -ne 'PROD' -and $Environment -ne 'TRN') {
        Write-Warning -Message "Input a correct ENVIRONMENT"
}
else {
        $Logfile = ".\log\PrepServerInfo_$log_date.log"
        Add-content $Logfile -value "Date`t`t`tLog Level`tDetails"
        LogWrite "Running Prep Server Script for Environemnt $Environment" "INFO"
        if ($Environment -eq 'DEV' ) {
                $HashPath = '.\01 - SqlServer_ConfigData_DEV.psd1'
        }
        elseif ($Environment -eq 'PROD') {
                $HashPath = '.\01 - SqlServer_ConfigData_PROD.psd1'
        }
        elseif ($Environment -eq 'TRN') {
                $HashPath = '.\01 - SqlServer_ConfigData_TRN.psd1'
        } 
        # input file contents
        $filecontent = Get-Content -Path $HashPath -Raw -ErrorAction Stop
        # put the file in a script block
        $scriptBlock = [scriptblock]::Create( $filecontent )
        #check that the file contains no other Powershell commands
        $scriptBlock.CheckRestrictedLanguage( $allowedCommands, $allowedVariables, $true )
        #execute it to create the hashtable 
        $log_date = (get-date).ToString("yyyyMMdd-HHmm")
        $logfileMount = "PrepServerInfo_MountPermssions_$log_date.log"
        $cred = Get-Credential -Credential SURREYCC\$env:USERNAME

        $hashtable = ( & $scriptBlock )
        $hashtable.AllNodes.NodeName | Where-object { $_ -ne '*' } | ForEach-Object {
                $RemoteComputers = $_
                If (Test-Connection -ComputerName $RemoteComputers -Quiet) {
                        Invoke-Command -ComputerName $RemoteComputers -ScriptBlock { Install-Module -Name SqlServerDsc, SecurityPolicyDSC, cNtfsAccessControl -force }
                } 
                $sb = {
                        Param(
                                $icred, $ilogfile
                        )
                        
                        $cred = $icred 
                        $depgroup = "SURREYCC\SVC-SQLDB-01"
                        $dep = 'log%'
                        $disks = Get-WmiObject Win32_Volume  -Filter "Label like '$dep'"
                        New-PSDrive -Name logfolder -PSProvider FileSystem -Root \\sec-mgt-14\log -Credential $cred
                        "******************************************"  | out-file -filepath logfolder:\$ilogfile -append
                        "**        SERVERNAME $env:COMPUTERNAME      **"  | out-file -filepath logfolder:\$ilogfile -append
                        "******************************************"  | out-file -filepath logfolder:\$ilogfile -append
                        "****** Adding permissions for LOG Mount Points ******"  | out-file -filepath logfolder:\$ilogfile -append  
                        foreach ($disk in $disks) {
                                
                                $path = $disk.deviceid 
                                $perm_string = $depgroup + ":(OI)(CI)(RX,W)"       
                                icacls $path /grant $perm_string | out-file -filepath logfolder:\$ilogfile -append  #\\sec-mgt-14\log\logical_output.log -Append
                               
                        }    
                        $dep = 'tempdb%'
                        $disks = Get-WmiObject Win32_Volume  -Filter "Label like '$dep'"
                        "****** Adding permissions for TEMPDB Mount Points ******"  | out-file -filepath logfolder:\$ilogfile -append
                        foreach ($disk in $disks) {
                                $path = $disk.deviceid 
                                $perm_string = $depgroup + ":(OI)(CI)(RX,W)"
                                icacls $path /grant $perm_string | out-file -filepath logfolder:\$ilogfile -append 
                        }   
                        $dep = 'data%'
                        $disks = Get-WmiObject Win32_Volume  -Filter "Label like '$dep'"
                        "****** Adding permissions for DATA Mount Points ******"  | out-file -filepath logfolder:\$ilogfile -append
                        foreach ($disk in $disks) {
                              
                                $path = $disk.deviceid 
                                $perm_string = $depgroup + ":(OI)(CI)(RX,W)"
                                icacls $path /grant $perm_string | out-file -filepath logfolder:\$ilogfile -append  
                        }   
                }
                
                Invoke-Command -ComputerName $RemoteComputers -ScriptBlock $sb -ArgumentList $cred, $logfileMount       
                LogWrite "Completed Prep Server Script for server $RemoteComputers" "INFO"    
        }   
        LogWrite "Completed Prep Server Script for Environemnt $Environment" "INFO"    
        LogWrite "Checking for failures in granting Mount Permissions" "INFO"
        If (Get-Content ".\log\$logfileMount" | select-string -Pattern "Failed processing [1-9] files" -Quiet )
        { LogWrite "Errors found granting Permissions for Mount Point - Checkerror log $logfileMount for further details" "ERROR" }
        ELSE {
                LogWrite "No errors found granting permissions for MOUNT points" "INFO"       
        }
}    
