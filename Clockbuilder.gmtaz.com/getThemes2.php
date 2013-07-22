<?php

include('p.php');
function rrmdir($dir) {
   if (is_dir($dir)) {
     $objects = scandir($dir);
     foreach ($objects as $object) {
       if ($object != "." && $object != "..") {
         if (filetype($dir."/".$object) == "dir") rrmdir($dir."/".$object); else unlink($dir."/".$object);
       }
     }
     reset($objects);
     return rmdir($dir);
   }
 }
$v = $_REQUEST['v'];
$api=$_REQUEST['api'];
if($api == 'SDFB52f4vw9230V45gdfg')
{
	header('Cache-Control: no-cache, must-revalidate');
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	header('Content-type: application/json');
	
	$dbhost = 'internal-db.s94282.gridserver.com';
	$dbuser = 'db94282_cbAdmin';
	$dbpass = 'illiad.3583';
	
	$conn = mysql_connect($dbhost, $dbuser, $dbpass) or 
	die ('Error connecting to mysql');
	
	$dbname = 'db94282_clockbuilder';
	mysql_select_db($dbname, $conn);
	
	$cat = $_REQUEST["category"];
	$sql = 'SELECT * FROM themesNumbered WHERE iPad=0';// WHERE `themeName` REGEXP \'.+[a-zA-Z0-9_-].+\'';
	//$result = mysql_query($sql,$conn);
	
	if(strlen($cat)>1)
	{
		$sql.=" AND category='$cat'";
	}
	if($cat == "Flagged"){
		$sql = 'SELECT DISTINCT themeName FROM themesFlagged';
	}
	
	$sql.=" ORDER BY id DESC";
	$result = mysql_query($sql,$conn);
	
	if($result!=0){
		$numrows = mysql_num_rows($result);
		$data;
	    for ($x = 0; $x < $numrows; $x++) {
	      $row = mysql_fetch_assoc($result);
	      $category = $row["category"];
	      if(!$category)
	      	$category = "";
	      $ID = $row["id"];
	      if(!$ID)
	      	$ID = "";
	      $data[$x] = array(
	      "id" => $ID,
	      "themeName" => $row["themeName"],
	      "category" => $category
	      );
	    }
	    $response = $_GET["jsoncallback"] . "(" . json_encode($data) . ")";
	    echo json_encode($data);  
		mysql_close($conn);
	}
}
else
echo 'Unauthorized';

?>