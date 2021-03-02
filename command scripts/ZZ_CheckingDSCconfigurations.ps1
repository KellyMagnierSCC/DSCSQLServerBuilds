#Quick Test to confirm whether computers are in the desired state configuration.
#This will only return true or false to confirm that the computer complies with the DSC
$computernames = "ODC1-SQL-TN-02", "ODC2-SQL-D-01", "ODC1-SQL-01"
Test-DscConfiguration -CimSession $computernames

#If you wanted more detail you could run the the following command to find out more detailed info
Test-DscConfiguration -detailed   -CimSession $computernames


#To check for infomration in the event log for DSC 
#this will opne a grid view for each server in the computernames list above.
foreach ($computer in $computernames)
{
#most recent 50 lines
Get-WinEvent –LogName “Microsoft-Windows-Dsc/Operational”  -ComputerName $computer -MaxEvents 50  | ogv -title $computer
}
foreach ($computer in $computernames)
{
#where the level was of type ERROR
Get-WinEvent –LogName “Microsoft-Windows-Dsc/Operational” -ComputerName $computer  | where LevelDisplayNAme -eq 'Error'  | ogv -title $computer
}

#If you want to see what configurations the LCM on the target machine is using you can run the following command
#This will list out each resource and configurations that LCMhas applied 
GET-DSCConfiguration -CimSession $computernames  #| ogv


#Check the status of LCM's on the target machines
Get-DSCLocalConfigurationManager -CimSession $computernames
