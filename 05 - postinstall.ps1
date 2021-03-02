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
    $Logfile = ".\log\Postinstall_$log_date.log"
    Add-content $Logfile -value "Date`t`t`tLog Level`tDetails"
    LogWrite "Starting to Apply scripts for Environemnt $Environment" "INFO"
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
    $hashtable = ( & $scriptBlock )
    $SQLFiles = Get-ChildItem -Path "\\sec-mgt-14\SQL_Server_2019\postinstall\maintenance" 
    $InstanceName = $hashtable.NonNodeData.InstanceName
    $hashtable.AllNodes.NodeName | Where-object { $_ -ne '*' } | ForEach-Object {
        $servername = $_
        $SQLFiles | select-object | ForEach-Object {
            $SQLFile = $_.Name
            try {
                Invoke-Sqlcmd -InputFile "\\sec-mgt-14\SQL_Server_2019\postinstall\maintenance\$SQLFile" -ServerInstance "$servername\$InstanceName" -ErrorAction 'Stop'  -ErrorVariable ProcessError
                LogWrite "Scripts applied :  $SQLFile to Server and Instance $servername\$InstanceName" "INFO"
            } 
            catch {
                LogWrite "Error running script  $SQLFile check error file .\log\Postinstall_$SQLFile$log_date.err for details" "ERROR"
                Add-Content -Path ".\log\Postinstall_$SQLFile$log_date.err" -value $ProcessError  
            }
        }

    }
}




