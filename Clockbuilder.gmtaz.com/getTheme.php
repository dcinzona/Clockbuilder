<?php

include('p.php');
$api=$_REQUEST['api'];
$invalidChars = ereg("[^A-Za-z0-9 -_]", $_POST['themeName']);
$v = $_REQUEST['v'];
if($api == 'SDFB52f4vw9230V45gdfg' && !$invalidChars  && getValidVersion($v))
{
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	header('Content-type: application/json');
	
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
	
	    $comments = array(
	    "id" => $row["id"],
	    "udid" => $row["author"],
	    "themeName" => $row["themeName"],
	    "device" => $row["device"],
	    "category" => $row["category"]
	    );
	    echo json_encode($comments);  
	  }
	else
	{
		echo 'no theme found';
	}
	mysql_close($conn);
}
else
echo 'Unauthorized';

?>