<?php

include('p.php');
$api=$_REQUEST['api'];
$v = $_REQUEST['v'];
if($api == 'SDFB52f4vw9230V45gdfg' ) //&& getValidVersion($v))
{	
	$dbhost = 'internal-db.s94282.gridserver.com';
	$dbuser = 'db94282_cbAdmin';
	$dbpass = 'illiad.3583';
	
	$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die                      ('Error connecting to mysql');
	
	$dbname = 'db94282_clockbuilder';
	mysql_select_db($dbname, $conn);
	
	$name = $_REQUEST['themeName'];
	
	$query = mysql_query("SELECT * FROM themes WHERE LOWER(themeName)='".strtolower($name)."'");
	$numrows = mysql_num_rows($query);
	if($numrows>0){
	    $row = mysql_fetch_assoc($query);
	
	    $downloads = intval( $row["downloads"] ) +1;
	    
	    $query = "UPDATE themes SET downloads=".$downloads." WHERE LOWER(themeName)='".strtolower($name)."'";
	    
	    if (!mysql_query($query))
	      die('Error: ' . mysql_error());
	    echo $downloads;
	}
	
	
	mysql_close($conn);
}
else
echo 'Unauthorized';

?>