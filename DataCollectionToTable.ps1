Add-PSSnapin SqlServerCmdletSnapin100
Add-PSSnapin SqlServerProviderSnapin100

$ErrorActionPreference = "Stop" 
$Servers=invoke-sqlcmd -ServerInstance User -Query "select ServerName from NixSql_Servers" -Database MSDB
Foreach($Server in $Servers){
[string]$srv=$Server.ServerName
try{
$getdata=Invoke-sqlcmd -server $srv -database msdb -query "select getdate(),@@servername,serverproperty('productlevel')" 
$connectionString = "Data Source=user; Integrated Security=True;Initial Catalog=msdb;"
$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
$bulkCopy.DestinationTableName = "servicepack"
$bulkCopy.WriteToServer($getdata)
$bulkCopy.close()
}
catch{
}
}
