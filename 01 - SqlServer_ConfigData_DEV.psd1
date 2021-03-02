@{
    AllNodes = @(
       
        @{
            NodeName = "ODC2-SQL-D-20.surreycc.local"
        }, 
        @{
            #NodeName = "ODC2-SQL-D-01.surreycc.local"
            NodeName = "ODC2-SQL-D-21.surreycc.local"
        },
        @{
            NodeName = '*'
            PSDscAllowPlainTextPassword = $true
        }
    )
    NonNodeData = @{
        InstanceName = "DEV"
        InstancePortNumber = 55201
        SQLServerServiceAccount = 'SURREYCC\SVC-SQLDB-01'
        InstanceDBDataDir="E:\MOUNT\Databases\Data\Data00"
        DataDir = "E:\MOUNT\Databases\Data\Data00"
        DataDir1 = "E:\MOUNT\Databases\Data\Data01"
        DataDir2 = "E:\MOUNT\Databases\Data\Data02"
        DataDir3 = "E:\MOUNT\Databases\Data\Data03"
        DataDir4 = "E:\MOUNT\Databases\Data\Data04"
        LogDir1 = "E:\MOUNT\Databases\Logs\Log01"
        LogDir2 = "E:\MOUNT\Databases\Logs\Log02"
        BackupDir = "E:\MOUNT\Databases\Data\Data00\backups" #"D:\Databases\PROD\Backups"
        TempDBLogDir = "E:\MOUNT\Databases\TempDB\TempDB01"
        TempDBDir1 = "E:\MOUNT\Databases\TempDB\TempDB01"
        TempDBDir2 = "E:\MOUNT\Databases\TempDB\TempDB02"
        TempDBDir3 = "E:\MOUNT\Databases\TempDB\TempDB03"
        TempDBDir4 = "E:\MOUNT\Databases\TempDB\TempDB04"
        InstallDir = "D:\Program Files\Microsoft SQL Server"
        InstanceDir =  "D:\Program Files\Microsoft SQL Server"
        InstallSharedWOWDir = "D:\Program Files (x86)\Microsoft SQL Server"
        ConfigOptions = @(
            @{
                Name    = "backup compression default"
                Setting = 1
            },
            @{
                Name    = "cost threshold for parallelism"
                Setting = 25
            }
            @{
                Name    = "Database Mail XPs"
                Setting = 1
            }
            @{
                Name    = "remote admin connections"
                Setting = 1
            }
        )
    }
}