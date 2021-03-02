Configuration Example
{
    #param
    #(
    #    [Parameter(Mandatory = $true)]
    #    [System.Management.Automation.PSCredential]
    #    $SqlAdministratorCredential
    #)

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SqlServerDsc
    node $AllNodes.NodeName
    {
        SqlScript 'RunAsSqlCredential'
        {
            ServerName   = 'localhost'
            InstanceName = 'PROD'
            Credential   = $SqlCredential

            SetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Set-RunSQLScript.sql'
            TestFilePath = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Test-RunSQLScript.sql'
            GetFilePath  = '\\SEC-MGT-14\SQL_Server_2019\postinstall\Get-RunSQLScript.sql'
            #Variable     = @('FilePath=C:\temp\log\AuditFiles')
        }
    }
}

Example -Output D:\dsc-SqlServerBuild\output -ConfigurationData D:\dsc-SqlServerBuild\SqlServer_ConfigData.psd1

Start-DscConfiguration -Path d:\dsc-SqlServerBuild\output\ -Wait -Verbose -Force