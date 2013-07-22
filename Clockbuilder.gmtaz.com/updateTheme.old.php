<?php

include('p.php');
$api=$_POST['api'];
if($api == 'SDFB52f4vw9230V45gdfg')
{	
	$dbhost = 'internal-db.s94282.gridserver.com';
	$dbuser = 'db94282_cbAdmin';
	$dbpass = 'illiad.3583';
	
	$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die ('Error connecting to mysql');
	
	$dbname = 'db94282_clockbuilder';
	mysql_select_db($dbname, $conn);
	$name = $_POST['themeName'];
	$device = $_POST['device'];
	$category = $_POST['cat'];
  	$query = "UPDATE themes SET category='".$category."' WHERE LOWER(themeName)='".strtolower($name)."' AND LOWER(device)='".strtolower($device)."'";
	 if (!mysql_query($query))
	    die('Error: ' . mysql_error());
	mysql_close($conn);
}
else
echo 'Unauthorized';

?>