<?php
 //Includes the CloudFiles PHP API.. Ensure the API files are located in your Global includes folder or in the same directory 
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
$query = mysql_query("SELECT * FROM themes WHERE device='iphone' ORDER BY downloads DESC ,themeName ASC LIMIT 0,20");


$ret = '{ "items":[';
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
    $value = $row["themeName"];
    $ret = $ret.'"<div class=\"item\"><img src=\"http://clockbuilder.gmtaz.com/resources/iphone/'.strtolower($value).'/themeScreenshot.jpg\" /></div>",';
    
  }

 $ret = substr($ret,0,strlen($ret)-1);
 $ret .= ']}';
 echo $ret;
 mysql_close($conn);
?>