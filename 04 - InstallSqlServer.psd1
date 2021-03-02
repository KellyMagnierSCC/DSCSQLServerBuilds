Configuration InstallSqlServer {

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SqlServerDsc
    Import-DscResource -ModuleName SecurityPolicyDsc #used to add SQL Service account into Volume Maintenance Task Policy
    Import-DscResource -ModuleName cNtfsAccessControl #added so that file permissions can be set for sql server folders

    $saCred = (Get-Credential -Credential sa)
    $sqlserviceCred = (Get-Credential -message 'Enter the password for user account associated with the SQL Server Service Account' -username 'SURREYCC\SVC-SQLDB-01')
    $sqlAgentServiceCred = (Get-Credential -message 'Enter the password for user account associated with the SQL Server Agent Account' -username 'SURREYCC\SVC-SQLAgent-01')
    $sqlISServiceCred = (Get-Credential -message 'Enter the password for user account associated with the SQL Server Integration Service Account' -username 'SURREYCC\SVC-SQLIS-01')
    
    Node $AllNodes.NodeName {
        WindowsFeature InstallDotNet {
            #Name   = 'NET-Framework-Features'
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }
        
        File CreateInstallDir {
            DestinationPath = $ConfigurationData.NonNodeData.InstallDir
            Ensure          = 'Present'
            Type            = 'Directory'
        }

        File CreateInstanceDir {
            DestinationPath = $ConfigurationData.NonNodeData.InstanceDir
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateDataDir {
            DestinationPath = $ConfigurationData.NonNodeData.DataDir
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateDataDir1 {
            DestinationPath = $ConfigurationData.NonNodeData.DataDir1
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateDataDir2 {
            DestinationPath = $ConfigurationData.NonNodeData.DataDir2
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateDataDir3 {
            DestinationPath = $ConfigurationData.NonNodeData.DataDir3
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateDataDir4 {
            DestinationPath = $ConfigurationData.NonNodeData.DataDir4
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateLogsDir1 {
            DestinationPath = $ConfigurationData.NonNodeData.LogDir1
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateLogsDir2 {
            DestinationPath = $ConfigurationData.NonNodeData.LogDir2
            Ensure          = 'Present'
            Type            = 'Directory'
        }

        File CreateSharedWOWDir {
            DestinationPath = $ConfigurationData.NonNodeData.InstallSharedWOWDir
            Ensure          = 'Present'
            Type            = 'Directory'
        }

        File CreateTempDBDir1 {
            DestinationPath = $ConfigurationData.NonNodeData.TempDBDir1
            Ensure          = 'Present'
            Type            = 'Directory'
            #Credential       = MSSQL$PROD'
        }
        File CreateTempDBDir2 {
            DestinationPath = $ConfigurationData.NonNodeData.TempDBDir2
            Ensure          = 'Present'
            Type            = 'Directory'
            Credential      = $sqlserviceCred
        }
        <# No longer required but kept for future reference       
          cNtfsPermissionEntry PermissionSetTempDBDir1
    {
        Ensure = 'Present'
        Path = $ConfigurationData.NonNodeData.TempDBDir1
        Principal = $ConfigurationData.NonNodeData.SQLServerServiceAccount
        AccessControlInformation = @(
            cNtfsAccessControlInformation
            {
                AccessControlType = 'Allow'
                FileSystemRights = 'ReadAndExecute'
                Inheritance = 'ThisFolderSubfoldersAndFiles'
                NoPropagateInherit = $false
            }
            cNtfsAccessControlInformation
            {
                AccessControlType = 'Allow'
                FileSystemRights = 'FullControl'
                Inheritance = 'ThisFolderSubfoldersAndFiles'
                NoPropagateInherit = $false
            }
        )
        DependsOn = '[File]CreateTempDBDir1'
    }
      #>
        File CreateTempDBDir3 {
            DestinationPath = $ConfigurationData.NonNodeData.TempDBDir3
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateTempDBDir4 {
            DestinationPath = $ConfigurationData.NonNodeData.TempDBDir4
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateDBBackupDir {
            DestinationPath = $ConfigurationData.NonNodeData.BackupDir
            Ensure          = 'Present'
            Type            = 'Directory'
        }
        File CreateInstanceDBDataDir {
            DestinationPath = $ConfigurationData.NonNodeData.InstanceDBDataDir
            Ensure          = 'Present'
            Type            = 'Directory'
        }

        UserRightsAssignment PerformVolumeMaintenanceTasks {
            Policy   = "Perform_volume_maintenance_tasks"
            Identity = $ConfigurationData.NonNodeData.SQLServerServiceAccount
        }
            
        SqlSetup  'InstallNamedInstance' {
            InstanceName           = $ConfigurationData.NonNodeData.InstanceName
            SourcePath             = '\\SEC-MGT-14\SQL_Server_2019\base'
            UpdateEnabled          = 'true'
            UpdateSource           = '\\SEC-MGT-14\SQL_Server_2019\updates'
            Features               = 'SQLENGINE,CONN,IS,BC,SDK,FULLTEXT'
            SQLSysAdminAccounts    = 'SURREYCC\AG-SQL-Admin'
            SQLUserDBDir           = $ConfigurationData.NonNodeData.DataDir1
            SQLUserDBLogDir        = $ConfigurationData.NonNodeData.LogDir1
            InstallSharedDir       = $ConfigurationData.NonNodeData.InstallDir
            InstanceDir            = $ConfigurationData.NonNodeData.InstanceDir
            InstallSharedWOWDir    = $ConfigurationData.NonNodeData.InstallSharedWOWDir
            SQLTempDBDir           = $ConfigurationData.NonNodeData.TempDBDir
            SQLTempDBLogDir        = $ConfigurationData.NonNodeData.TempDBLogDir
            SQLBackupDir           = $ConfigurationData.NonNodeData.BackupDir
            INSTALLSQLDATADIR      = $ConfigurationData.NonNodeData.InstanceDBDataDir
            SecurityMode           = 'SQL'
            SAPwd                  = $saCred
            SQLSVCACCOUNT          = $sqlServiceCred
            AgtSvcAccount          = $sqlAgentServiceCred
            ISSVCACCOUNT           = $sqlISServiceCred 
            AGTSVCSTARTUPTYPE      = 'Automatic'
            ISSVCSTARTUPTYPE       = 'Automatic'
            #SQLSVCINSTANTFILEINIT = 'True' #option not available in DSC as of yet
            TcpEnabled             = $true
            SQLCollation           = 'Latin1_General_CI_AS'
            SqlTempdbFileSize      = 1024
            SqlTempdbFileGrowth    = 64
            SqlTempdbLogFileSize   = 512
            SqlTempdbLogFileGrowth = 64
            SqlTempdbFileCount     = 4
            #PsDscRunAsCredential   = $SqlAdministratorCredential
            DependsOn              = '[WindowsFeature]InstallDotNet'
        }

        #nutanix calculation for Max SQL memory uses similar formula to dynamic memory allocation in DSC
        
        SqlMemory 'Set_SQLServerMaxMemory_ToAuto' {
            Ensure                  = 'Present'
            DynamicAlloc            = $true
            ServerName              = $Node.NodeName
            InstanceName            = $ConfigurationData.NonNodeData.InstanceName
            ProcessOnlyOnActiveNode = $true
            # PsDscRunAsCredential    = $SqlAdministratorCredential
        }
        SqlTraceFlag 'Set_SqlTraceFlags' {
            ServerName          = $Node.NodeName
            InstanceName        = $ConfigurationData.NonNodeData.InstanceName
            TraceFlagsToInclude = 834, 3226
            RestartService      = $true

            #PsDscRunAsCredential = $SqlAdministratorCredential
        }
        #  SqlTraceFlag 'Set_SqlTraceFlags' {
        #      ServerName     = $Node.NodeName
        #      InstanceName   = $ConfigurationData.NonNodeData.InstanceName
        #      TraceFlags     = 3226 #, 834 #large memory pages as specified by Nutanix
        #      RestartService = $true

        #PsDscRunAsCredential = $SqlAdministratorCredential
        #  }
        SqlMaxDop 'Set_SqlMaxDop_ToAuto' {
            Ensure                  = 'Present'
            DynamicAlloc            = $true
            ServerName              = $Node.NodeName
            InstanceName            = $ConfigurationData.NonNodeData.InstanceName
            ProcessOnlyOnActiveNode = $true
            #PsDscRunAsCredential    = $SqlAdministratorCredential
        }
        $ConfigurationData.NonNodeData.ConfigOptions.foreach{
            SqlConfiguration ("SetConfigOption {0}" -f $_.name) {
                DependsOn    = '[SqlSetup]InstallNamedInstance'
                ServerName   = $Node.NodeName
                InstanceName = $ConfigurationData.NonNodeData.InstanceName
                OptionName   = $_.Name
                OptionValue  = $_.Setting
            }
        }

        #  deprecated replced with SqlProtocolTcpIP
        #SqlServerNetwork 'EnableTcpIp' {
        #     DependsOn      = '[SqlSetup]InstallSql'
        #     InstanceName   = $ConfigurationData.NonNodeData.InstanceName
        #     ProtocolName   = 'Tcp'
        #     IsEnabled      = $true
        #     TCPPort        = 55101
        #     RestartService = $true
        # }

        SqlProtocolTcpIP 'ChangeIPAll' {
            InstanceName   = $ConfigurationData.NonNodeData.InstanceName
            IpAddressGroup = 'IPAll'
            TcpPort        = $ConfigurationData.NonNodeData.InstancePortNumber
        }
        
    
        SqlAgentAlert 'Add_Sev19' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 19 Error: Error 19 Alert Fatal Error in Resource'
            Severity     = '19'
        }
        
        SqlAgentAlert 'Add_Sev20' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 20 Error: Error 20 Alert Fatal Error in Current Process'
            Severity     = '20'
        }
        SqlAgentAlert 'Add_Sev21' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 21 Error: Error 21 Alert Fatal Error in Database Process'
            Severity     = '21'
        }
        SqlAgentAlert 'Add_Sev22' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 22 Error: Error 22 Alert Fatal Error: Table Integrity Suspect'
            Severity     = '22'
        }
       
        SqlAgentAlert 'Add_Sev23' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 23 Error: Error 23 Alert Fatal Error Database Integrity Suspect'
            Severity     = '23'
        }   
        SqlAgentAlert 'Add_Sev24' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 24 Error: Error 24 Alert Fatal Hardware Error'
            Severity     = '24'
        }   
        SqlAgentAlert 'Add_Sev25' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 25 Error: Error 25 Alert Fatal Error'
            Severity     = '25'
        } 
        SqlAgentAlert 'Add_Msg823' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 823 Error: Error 823 Alert The operating System returned an Error'
            MessageId    = '823'
        }   
        SqlAgentAlert 'Add_Msg824' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 824 Error: Error 824 Alert Logical Consistency-based I/O Error'
            MessageId    = '824'
        }

        SqlAgentAlert 'Add_Msg825' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 825 Error: Error 825 Alert Read-Retry Required'
            MessageId    = '825'
        }
        SqlAgentAlert 'Add_Msg832' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 832 Error: Error 832 Alert Constant page has changed'
            MessageId    = '832'
        }
        SqlAgentAlert 'Add_Msg855' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 855 Error: Error 855 Alert Uncorrectable hardware memory corruption detected'
            MessageId    = '855'
        }
        SqlAgentAlert 'Add_Msg856' {
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            ServerName   = $Node.NodeName
            Ensure       = 'Present'
            Name         = 'Alert - Sev 856 Error: Error 856 Alert SQL Server has detected hardware memory corruption, but has recovered the page'
            MessageId    = '856'
        }
        # SqlConfiguration 'EnableDatabaseMailXPs' #added to configdata section
        #  {
        #      ServerName     = $Node.NodeName
        #      InstanceName   = $ConfigurationData.NonNodeData.InstanceName
        #      OptionName     = 'Database Mail XPs'
        #      OptionValue    = 1
        #      RestartService = $false
        # }
        SqlDatabaseMail 'EnableDatabaseMail' {
            Ensure         = 'Present'
            ServerName     = $Node.NodeName
            InstanceName   = $ConfigurationData.NonNodeData.InstanceName
            AccountName    = 'SQKMonitoring'
            ProfileName    = 'Database Monitoring'
            EmailAddress   = 'dba.alerts@surreycc.gov.uk'
            ReplyToAddress = 'dba.alerts@surreycc.gov.uk'
            DisplayName    = 'SQLServerMonitoring'
            MailServerName = 'outmail.surreycc.gov.uk'
            Description    = 'SQL Monitoring mail account and profile.'
            LoggingLevel   = 'Normal'
            TcpPort        = 25

            #PsDscRunAsCredential = $SqlInstallCredential
        }
        SqlScript 'RestoreDBADatabase' {
            ServerName   = $Node.NodeName
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            # Credential   = $SqlCredential

            SetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Set-RunSQLScript.sql'
            TestFilePath = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Test-RunSQLScript.sql'
            GetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Get-RunSQLScript.sql'
           
        }
        SqlAgentOperator 'Add_DbaTeam' {
            Ensure       = 'Present'
            Name         = 'DBA'
            ServerName   = $Node.NodeName
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            EmailAddress = 'dba.alerts@surreycc.gov.uk'
        }
        SqlScript 'CreateAlertNotifications' {
            ServerName   = $Node.NodeName
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            # Credential   = $SqlCredential

            SetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Set-RunSQLScript-Notifications.sql'
            TestFilePath = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Test-RunSQLScript-Notifications.sql'
            GetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Get-RunSQLScript-Notifications.sql'
           
        }
        SqlScript 'ConfigureTempDB' {
            ServerName   = $Node.NodeName
            InstanceName = $ConfigurationData.NonNodeData.InstanceName
            # Credential   = $SqlCredential

            SetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Set-RunSQLScript-TempDB.sql'
            TestFilePath = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Test-RunSQLScript-TempDB.sql'
            GetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Get-RunSQLScript-TempDB.sql'
           
        }
        SqlDatabaseDefaultLocation 'Set_SqlDatabaseDefaultDirectory_Data' {
            ServerName     = $Node.NodeName
            InstanceName   = $ConfigurationData.NonNodeData.InstanceName
            #ProcessOnlyOnActiveNode = $true
            Type           = 'Data'
            Path           = $ConfigurationData.NonNodeData.DataDir1 + '\'
            RestartService = $true
        }
        SqlDatabaseDefaultLocation 'Set_SqlDatabaseDefaultDirectory_Log' {
            ServerName     = $Node.NodeName
            InstanceName   = $ConfigurationData.NonNodeData.InstanceName
            #ProcessOnlyOnActiveNode = $true
            Type           = 'Log'
            Path           = $ConfigurationData.NonNodeData.LogDir1 + '\'
            RestartService = $true
        }
        cNtfsPermissionEntry PermissionSetDataDir1 {
            Ensure                   = 'Present'
            Path                     = $ConfigurationData.NonNodeData.DataDir1
            Principal                = 'NT Service\MSSQL$' + $ConfigurationData.NonNodeData.InstanceName
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType  = 'Allow'
                    FileSystemRights   = 'FullControl'
                    Inheritance        = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
            DependsOn                = '[File]CreateDataDir1'
        }

        cNtfsPermissionEntry PermissionSetDataDir2 {
            Ensure                   = 'Present'
            Path                     = $ConfigurationData.NonNodeData.DataDir2
            Principal                = 'NT Service\MSSQL$' + $ConfigurationData.NonNodeData.InstanceName
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType  = 'Allow'
                    FileSystemRights   = 'FullControl'
                    Inheritance        = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
            DependsOn                = '[File]CreateDataDir2'
        }
        cNtfsPermissionEntry PermissionSetDataDir3 {
            Ensure                   = 'Present'
            Path                     = $ConfigurationData.NonNodeData.DataDir3
            Principal                = 'NT Service\MSSQL$' + $ConfigurationData.NonNodeData.InstanceName
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType  = 'Allow'
                    FileSystemRights   = 'FullControl'
                    Inheritance        = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
            DependsOn                = '[File]CreateDataDir2'
        }
        cNtfsPermissionEntry PermissionSetDataDir4 {
            Ensure                   = 'Present'
            Path                     = $ConfigurationData.NonNodeData.DataDir4
            Principal                = 'NT Service\MSSQL$' + $ConfigurationData.NonNodeData.InstanceName
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType  = 'Allow'
                    FileSystemRights   = 'FullControl'
                    Inheritance        = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
            DependsOn                = '[File]CreateDataDir4'
        }
        cNtfsPermissionEntry PermissionSet3 {
            Ensure    = 'Absent'
            Path      = $ConfigurationData.NonNodeData.DataDir4
            Principal = 'BUILTIN\Users'
            DependsOn = '[File]CreateDataDir4'
        }
    }
}
#Move out old configuration files
Move-Item -Path .\output\*.mof -Destination .\output\PreviousConfigurations -Force
$Environment = Read-Host -Prompt "Environment to process - DEV, PROD, TRN"
If ($Environment -ne 'DEV' -and $Environment -ne 'PROD' -and $Environment -ne 'TRN') {
    Write-Warning -Message "Input a correct ENVIRONMENT"
}
else {
    if ($Environment -eq 'DEV' ) {
        InstallSqlServer -Output .\Output -ConfigurationData '01 - SqlServer_ConfigData_DEV.psd1'
    }
    elseif ($Environment -eq 'PROD') {
        InstallSqlServer -Output .\Output -ConfigurationData '01 - SqlServer_ConfigData_Prod.psd1'
    }
    elseif ($Environment -eq 'TRN') {
        InstallSqlServer -Output .\Output -ConfigurationData '01 - SqlServer_ConfigData_TRN.psd1'
    }
}
#Start-DscConfiguration -Path .\Output\ -ComputerName DscSvr2 -Wait -Verbose -Force

$ApplyConfig = Read-Host -Prompt "Do you want to apply the configuration now? (Y/N)"

If ($ApplyConfig -eq 'Y')
{Start-DscConfiguration -Path .\Output\ -Wait -Verbose -Force}
Elseif ($ApplyConfig -ne 'Y')
{write-host "To apply the config at a later date run the following command :- "
write-host "      Start-DscConfiguration -Path .\Output\ -Wait -Verbose -Force " -ForegroundColor RED
}

#command below will apply the exusting config on the server to the server
#Start-DscConfiguration -Wait -UseExisting -CimSession $computername
#confirm configuration has been applied
#$computername = "ODC2-SQL-D-20.surreycc.local"
#Get-DscLocalConfigurationManager -CimSession $computername
#Test-DscConfiguration -detailed   -CimSession $computername | Format-Table -Wrap -AutoSize -Property ResourcesInDesiredState -Property ResourcesInDesiredState -wrap Ft -AutoSize  #| Out-GridView
#Get-DSCConfiguration -CimSession $computername

#Get-DSCConfigurationStatus -CimSession $computername

