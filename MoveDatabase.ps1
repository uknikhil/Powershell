#Move All User Database From C: drive to other drive
$ErrorActionPreference = "Stop"
#New location of data and log files
$dataTo="F:\SQLDB\data\"
$logTo="E:\SQLDB\log\"
#SQL Server instance name
$instance="MyServer\SQL1"
#If you want to move file not from C: drive,update where condition in below line
$dblist=invoke-sqlcmd -server user -database master -query "select DB_NAME(database_id) as dbname,name,type,physical_name from sys.master_files where physical_name like 'E:%' and database_id>4"

$dbs= $dblist.dbname | get-unique
try{
foreach($db in $dbs){
$offlinequery="alter database [$db] set offline"
invoke-sqlcmd -server $instance -database master -query $offlinequery
$filenames=$dblist | where {$_.dbname -eq $db}
foreach($filename in $filenames){
$logicalname=$filename.name
$physicalname=$filename.physical_name
$physicalfile=Split-Path $physicalname -leaf
if($filename.type -eq 1){
$physicalnewname=$dataTo+$physicalfile
}
elseif($filename.type -eq 2){
$physicalnewname=$logTo+$physicalfile
}
$alterquery="ALTER DATABASE $db MODIFY FILE (NAME =$logicalname, FILENAME ='$physicalnewname');" 
Move-item  -path $physicalname -destination $physicalnewname
invoke-sqlcmd -server $instance -database master -query $alterquery
}
$bringonline="ALTER DATABASE $db SET ONLINE;"
invoke-sqlcmd -server $instance -database master -query $bringonline
}
}
catch{
}
