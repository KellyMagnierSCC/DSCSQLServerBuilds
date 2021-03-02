Get-DSCLocalConfigurationManager -CimSession pri-mgt-14


Get-DscResource | select Name,Module,Properties | Ft -AutoSize 

PackageManagement\Install-Package : No match was found for the specified search criteria and module name 
'SecurityPolicyDSC'. Try Get-PSRepository to see all available registered module repositories.

 Get-PSRepository

Install-Module -Name SqlServerDsc -AllowPrerelease

Install-Module -Name cNtfsAccessControl -RequiredVersion 1.4.0

get-installedmodule

Find-DscResource -name SqlSetup

Install-Module -Name SecurityPolicyDSC

Get-DscResource | where ModuleName -eq 'cNtfsAccessControl'
Get-DscResource | where ModuleName -eq 'SecurityPolicyDSC' | select Name,Module,Properties | Ft -AutoSize 

Get-DscResource -Name AccountPolicy -Syntax
Get-DscResource -Name SecurityOption -Syntax
Get-DscResource -Name SecurityTemplate -Syntax
Get-DscResource -Name UserRightsAssignment -Syntax
Get-DscResource | where ModuleName -eq 'SqlServerDsc' | select Name,Module,Properties | Ft -AutoSize 

Get-DscResource -Name SqlSetup -Syntax

Get-DscResource -Name SqlDatabase -Syntax


Get-DscResource -Name SqlAgentAlert -Syntax

Get-DscResource -Name SqlTraceFlag -Syntax

Get-DscResource -Name SqlServerNetwork -Syntax

Get-DscResource -Name SqlMaxDop -Syntax

Get-DscResource -Name SqlMemory -Syntax

Get-DscResource -Name SqlDatabaseMail -Syntax

Get-DscResource -Name SqlConfiguration -Syntax


Set-DscLocalConfigurationManager "D:\Dev Code\dsc-SqlServerBuild\output"

Start-DscConfiguration -Path "D:\Dev Code\dsc-SqlServerBuild\output\"  -ComputerName pri-mgt-02 -Wait -Verbose -Force


Start-DscConfiguration -Path "D:\Dev Code\dsc-SqlServerBuild\output\"   -Wait -Verbose -Force

Set-DscLocalConfigurationManager -Path "D:\Dev Code\dsc-SqlServerBuild\output\" -Force -Verbose -ComputerName pri-mgt-14
Get-DSCLocalConfigurationManager -CimSession pri-mgt-14


Get-DscConfiguration -cimsession pri-mgt-02

Import-DscResource -ModuleName PSDesiredStateConfiguration,
@{ModuleName='xRemoteDesktopSessionHost';ModuleVersion="1.8.0.0"}
 



#find commands find resources in external repo's whre as GET- is local to your server
find-module

find-dscresource -ov r | measure

$r | ogv

Find-DscResource -name xSQLServerMoveDatabaseFiles #this will tell you which module the resource is in

Install-Module -Name  mlSqlServerDSC  #will install the module discovered in the command above

Get-DscResource -ov dscr

$dscr | ogv

Get-DscResource -name xSQLServerDatabaseRecoveryModel -syntax #get help on how to use the resource

get-dscconfiguration -CimSession ODC2-SQL-D-20.surreycc.local

get-localconfignmanager -CimSession ODC2-SQL-D-20.surreycc.local

-CimSession ODC2-SQL-D-20.surreycc.local
 
Get-DscResource -name 
get-psrepository

Install-Module -Name xSqlServerDatabaseDefaultLocation -AllowPrerelease


install-module -name PSDscResources


Get-DSCLocalConfigurationManager -CimSession ODC2-SQL-D-20.surreycc.local

install-module sqlserverdsc -force

get-dscresource ODC2-SQL-D-20.surreycc.local



$ModuleName = 'sqlserverdsc';
$Latest = Get-InstalledModule $ModuleName; 
Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module -WhatIf