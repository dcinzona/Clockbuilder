<?php
//http://clockbuilder.gmtaz.com/deleteTheme.php?api=SDFB52f4vw9230V45gdfg&themeName=test1&device=iphone&rowID=1&block=1&udid=sljnvlsbv

function rrmdir($dir) {
   if (is_dir($dir)) {
     $objects = scandir($dir);
     foreach ($objects as $object) {
       if ($object != "." && $object != "..") {
         if (filetype($dir."/".$object) == "dir") rrmdir($dir."/".$object); else unlink($dir."/".$object);
       }
     }
     reset($objects);
     rmdir($dir);
   }
   echo "$dir";
 } 
 
 function block($UDID)
 {
 	$dbhost = 'internal-db.s94282.gridserver.com';
 	$dbuser = 'db94282_cbAdmin';
 	$dbpass = 'illiad.3583';
 	
 	$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die                      ('Error connecting to mysql');
 	
 	$dbname = 'db94282_clockbuilder';
 	mysql_select_db($dbname, $conn);
 	mysql_query("INSERT INTO blockList (UDID)
 	VALUES ('".$UDID."')");
 	print "Device Blacklisted";		
 	mysql_close($conn);
 }
 
 function deleteFromDB($id)
 {
 $dbhost = 'internal-db.s94282.gridserver.com';
 $dbuser = 'db94282_cbAdmin';
 $dbpass = 'illiad.3583';
 
 $conn = mysql_connect($dbhost, $dbuser, $dbpass) or die                      ('Error connecting to mysql');
 
 $dbname = 'db94282_clockbuilder';
 mysql_select_db($dbname, $conn);
 
 $query = mysql_query("DELETE FROM themes WHERE LOWER(themeName)='" .$_REQUEST['themeName']. "'");
 
 mysql_close($conn);
 if($_REQUEST['block']!='1')
  	echo 'Deleted';
 else
 	block($_REQUEST['udid']);
 	
}

$api=$_REQUEST['api'];
if($api == 'SDFB52f4vw9230V45gdfg')
{
	$device = $_REQUEST['device'];
	$dirToRemove = 'resources/'.$device.'/'.$_REQUEST['themeName'];
	deleteFromDB($_REQUEST['rowID']);
	if($dirToRemove != '')
		rrmdir($dirToRemove);		
	
}
else
	echo 'unauthorized';

?>