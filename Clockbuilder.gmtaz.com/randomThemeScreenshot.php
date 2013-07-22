<?php



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

	$offset_result = mysql_query( " SELECT FLOOR(RAND() * COUNT(*)) AS `offset` FROM `themesNumbered` ",$conn);
	$offset_row = mysql_fetch_object( $offset_result ); 
	$offset = $offset_row->offset;
	$result = mysql_query( " SELECT * FROM `themesNumbered` LIMIT $offset, 1 " , $conn);
	
	if($result){
	
	  $row = mysql_fetch_row($result);
	  $id = $row[0];
	  $folderName = $row[1] +1;	
	  $dbCat = $row[2];
	  $dbudid = $row[3];
	  
	  $data = array(
	  "screenshotURL" => "/resources/themes/".$row[1]."/themeScreenshot.jpg"
	  );
	  
	  $json = array(
	  "randomTheme" => $data
	  );
	  
	  echo(json_encode($json));
	}
	

?>