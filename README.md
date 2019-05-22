# Veeam-Backup-Monitor-Plugin
A Powershell Script based on robinsmit's project, compatible with Nagios and Icinga. I've added some commands to check if Job's are disabled and if restore points are corruped.  This is my first project so be gentle with me, 'i'm a poor little IT boy who wants to be a man.

INSTALLATION:

1- Copy the .ps1 file to icinga sbin directory

2- Configure Icinga to run PS Command following these steps

https://community.icinga.com/t/windows-powershell-checks-with-icinga2/712

Command Template:

./check_veeambackup.ps1 "BACKUPNAME" NumberOfDays
  
Command Example: 

./check_veeambackup.ps1 "BACKUPNAME" 2


