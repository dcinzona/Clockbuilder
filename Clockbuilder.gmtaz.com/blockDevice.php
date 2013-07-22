<?php
$dbhost = 'internal-db.s94282.gridserver.com';
$dbuser = 'db94282_cbAdmin';
$dbpass = 'illiad.3583';

$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die                      ('Error connecting to mysql');

$dbname = 'db94282_clockbuilder';
mysql_select_db($dbname, $conn);

$UDID = $_REQUEST['udid'];
$KEY = $_REQUEST['key'];

if($KEY == "086eec220c3db3edafa624a3c869315e907ef253"){
	mysql_query("INSERT INTO blockList (UDID)
	VALUES ('".$UDID."')");
	print "Device Blacklisted";
}
else
	print "invalid key";
	
mysql_close($conn);

?>