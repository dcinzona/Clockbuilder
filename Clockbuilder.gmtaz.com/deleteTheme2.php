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
   //echo "$dir";
 } 
 
 function deleteFromDB($id)
 {
 $dbhost = 'internal-db.s94282.gridserver.com';
 $dbuser = 'db94282_cbAdmin';
 $dbpass = 'illiad.3583';
 
 $conn = mysql_connect($dbhost, $dbuser, $dbpass) or die ('Error connecting to mysql');
 
 $dbname = 'db94282_clockbuilder';
 mysql_select_db($dbname, $conn);
 
 $query = mysql_query("DELETE FROM `themesNumbered` WHERE LOWER(themeName)='" .$_REQUEST['themeName']. "'");
 $query = mysql_query("DELETE FROM `themesFlagged` WHERE LOWER(themeName)='" .$_REQUEST['themeName']. "'");
 
 mysql_close($conn);
 
 	
}

$api=$_REQUEST['api'];
if($api == 'thisisasecretapikeygmt2745694')
{
	$device = $_REQUEST['device'];
	$dirToRemove = 'resources/themes/'.$_REQUEST['themeName'];
	if($dirToRemove != "resources/themes/"){
		deleteFromDB($_REQUEST['themeName']);
		rrmdir($dirToRemove);
		echo("deleted!");
	}
}
else
	echo 'unauthorized';

?>