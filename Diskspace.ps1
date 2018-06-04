#create a text file servers.txt file in same folder where this script is saved.Otherwise mention full path of servers.txt below.
$comp=get-content servers.txt 
$ErrorActionPreference = "Stop" 
$failed=@() 
$result=@() 
$attachment = "failed.txt"

###### HTML Output Design ##### 
$a = "<style>" 
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}" 
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}" 
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}" 
$a = $a + "</style>"

  
foreach($com in $comp) 
{ 
  
try 
{ 
  
  $dsk=get-wmiobject win32_volume -computername $com -Filter “DriveType = 3" 
  
                foreach($eachdsk in $dsk) 
                { 
                [int]$perc=((([double]$eachdsk.freespace) * 100 )/[double]$eachdsk.Capacity) 
  
 
                                if($perc -lt 99) 
                                { 
                                [int]$c=$eachdsk.Capacity/1GB 
                               [int]$b=$eachdsk.FreeSpace/1GB 
                                $obj = New-Object System.Object 
                                $obj | Add-Member  -MemberType NoteProperty -Name ServerName -value $eachdsk.SystemName 
                                $obj | Add-Member  -MemberType NoteProperty -Name Drive -value $eachdsk.Caption 
                                $obj | Add-Member  -MemberType NoteProperty  -Name TotalSpace -value $c 
                                $obj | Add-Member  -MemberType NoteProperty  -Name FreeSpace -value $b 
                                $obj | Add-Member  -MemberType NoteProperty  -Name PercentageFree -value $perc 
                                $result +=$obj 
                                } 
  
                } 
  } 
catch{ 
$failed +=$Com 
} 
}  
#Disk space details are available in Diskspace.html. If you wish to same this file in any other path, mention full path below along with Diskspace.html
$result | ConvertTo-HTML -head $a|Out-File Diskspace.html
#Whatever the servers are unable to connect available in failed.txt file. You can check server name is correct or network connectivity.
$failed | Out-File failed.txt
