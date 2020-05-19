# Adding required SnapIn

asnp VeeamPSSnapin

# Global variables

$name = $args[0]
$period = $args[1]
$dateformat = "dd/MM/yyyy"
# Veeam Backup & Replication job status check

$job = Get-VBRJob -Name $name
$name = "'" + $name + "'"


if ($job -eq $null)
{
	Write-Host "UNKNOWN! No such a job: $name."
	exit 3
}

#Check if Job is disabled, NOT WORK with Backup Copy

if ($job.IsScheduleEnabled -ne $true)
{
Write-Host "CRITICAL! The Following Job: $name is Disabled."
exit 2
}


$status = $job.GetLastResult()
$info =  Get-WinEvent -FilterHashtable @{Logname='Veeam Backup';ID=190} |Select-Object Message | Select-String -Pattern $Job.Name | select -First 1
$info = $info -replace '@{Message=', ''


if ($status -eq "Failed")
{
	Write-Host "CRITICAL! Errors were encountered during the backup process of the following job: $name."
	exit 2
}

#Check VM Restore Points  Status

if ($job.Isbackup -eq $true)
{
$Session = $Job.FindLastSession()
$Session = $Session.state

if ($Session -eq "Stopped")

{

$Restorepoints = Get-VBRBackup -Name $job.name | Get-VBRRestorePoint -Name *

 foreach($RP in $Restorepoints)
 {

 $CheckState = $RP.IsCorrupted 
 $RecheckState = $RP.IsRecheckCorrupted
 $ConsistentState = $RP.IsConsistent

 
 if ($CheckState -ne $false -or $RecheckState -ne $false -or $ConsistentState -ne $true)

{

$VM = $RP.Name
write-host "CRITICAL! VM Backup of $VM is Corrupted"
exit 2

}
}
}
}
#---------------------------------------------

#Check Backup Status

if ($status -ne "Success")
{
	Write-Host "WARNING! Job $name is in WARNING State. Session is: $Session"
	exit 1
}
	
# Veeam Backup & Replication job last run check

$now = (Get-Date).AddDays(-$period)
$now = $now.ToString("yyyy-MM-dd")
$last =  get-vbrsession -job $job -Last | select -ExpandProperty "CreationTime"
# Uncomment this for old Veeam Version
#$last = $job.GetScheduleOptions()
#$last = $last -replace '.*Latest run time: \[', ''
#$last = $last -replace '\], Next run time: .*', ''
#$last = $last.split(' ')[0]

if((Get-Date $now) -gt (Get-Date $last))
{
	Write-Host "CRITICAL! Last run of job: $name more than $period days ago. Session is: $Session"
	exit 2
} 
else
{
	$last = $last.tostring($dateformat)
	Write-Host "OK! Backup process of job $name completed successfully on $last Session is: $Session"
	exit 0
}
