<?php
$dbhost = 'internal-db.s94282.gridserver.com';
$dbuser = 'db94282_cbAdmin';
$dbpass = 'illiad.3583';

$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die                      ('Error connecting to mysql');

$dbname = 'db94282_clockbuilder';
mysql_select_db($dbname, $conn);

$UDID = $_REQUEST['udid'];

$result = mysql_query("SELECT id, UDID FROM blockList WHERE UDID='".$UDID."'");
while ($row = mysql_fetch_array($result,MYSQL_ASSOC)) {
print "blocked";
}
mysql_close($conn);

?>