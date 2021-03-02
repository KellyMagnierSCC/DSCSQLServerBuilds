#push config changes out to the lcoacl Config Manager
[DscLocalConfigurationManager()]
 
configuration LCM {
 
param (
 
[parameter(Mandatory=$true)]
[string[]]$computername
 
)
 
node $computername {
 
settings {
 
ConfigurationMode = 'ApplyOnly'
RebootNodeIfNeeded = $true
 
}
}
}
 

#$computername = 'ODC2-SQL-D-01.surreycc.local'
#$computername = 'ODC1-SQL-01.surreycc.local'
$computername = 'ODC1-SQL-TN-02.surreycc.local'
 
LCM -Output .\output  -computername $computername -verbose

Set-DscLocalConfigurationManager -Path .\output\ -Force -Verbose -ComputerName $computername

get-dsclocalconfigurationmanager -CimSession $computername