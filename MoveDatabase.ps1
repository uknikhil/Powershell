#Move All User Database From C: drive to other drive
$ErrorActionPreference = "Stop" 
$dataTo="F:\SQLDB\data\"
$logTo="F:\SQLDB\log\"
$instance="user"
$dblist=invoke-sqlcmd -server user -database master -query "select DB_NAME(database_id) as dbname,name,file_id,physical_name from sys.master_files where physical_name like 'C:%' and database_id>4"
$dbs= $dblist.dbname | get-unique
foreach($db in $dbs){
$offlinequery="alter database [$db] set offline"
invoke-sqlcmd -server $instance -database master -query $offlinequery
$filenames=$dblist | where {$_.dbname -eq $db}
foreach($filename in $filenames){
$logicalname=$filename.name
$physicalname=$filename.physical_name
$physicalfile=Split-Path $physicalname -leaf
if($filename.file_id -eq 1){
$physicalnewname=$dataTo+$physicalfile
}
elseif($filename.file_id -eq 2){
$physicalnewname="$logTo"+"$physicalfile"
}
$alterquery="ALTER DATABASE $db MODIFY FILE ('NAME =$logicalname, FILENAME =$physicalnewname');" 
Move-item  -path $physicalname -destination $physicalnewname
invoke-sqlcmd -server $instance -database master -query $alterquery
}
}
