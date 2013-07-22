<?php

include('p.php');

$v = $_REQUEST['v'];

$api=$_REQUEST['api'];

if($api == 'SDFB52f4vw9230V45gdfg'  && getValidVersion($v))
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
	
	$device = $_REQUEST['device'];
	$page = $_REQUEST['page'];
	$query = mysql_query("SELECT * FROM themes WHERE device='".$device."' ORDER BY downloads DESC ,themeName ASC LIMIT 0,20");
	
	
	    //loop through and return results
	  for ($x = 0, $numrows = mysql_num_rows($query); $x < $numrows; $x++) {
	    $row = mysql_fetch_assoc($query);
	
	    $comments[$x] = array(
	    "id" => $row["id"],
	    "udid" => $row["author"],
	    "themeName" => $row["themeName"],
	    "device" => $row["device"],
	    "category" => $row["category"],
	    "downloads" => $row["downloads"]
	    );
	  }
	
	  //echo JSON to page
	  $response = $_GET["jsoncallback"] . "(" . json_encode($comments) . ")";
	  echo json_encode($comments);  
	mysql_close($conn);
}
else
echo 'Unauthorized';

?>