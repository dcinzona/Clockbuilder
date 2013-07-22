<?php

include('p.php');

header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');

$dbhost = 'internal-db.s94282.gridserver.com';
$dbuser = 'db94282_cbAdmin';
$dbpass = 'illiad.3583';

$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die ('Error connecting to mysql');

$dbname = 'db94282_clockbuilder';
mysql_select_db($dbname, $conn);

function nslog($string){
	print('\n');
	print_r($string);
	print('\n');
	return true;
}
/*
if(!getValidVersion($v)){

	mysql_close($conn);

	$json = array(
	"success" => "false",
	"error" => "Invalid Version"
	);
	print_r(json_encode($json));
	die ();

}
*/
$api = $_GET['api'];

if($api == 'thisisasecretapikeygmt2745694' || $api=='test')
{	
	$themeName = ($_GET['themeName']);
	
					//insert new row into SQL to prevent another user from 
	$insert = "INSERT INTO `themesFlagged` (`themeName`) VALUES ('$themeName')";
	$id;
	$insertResult = mysql_query($insert, $conn);
	if(!$insertResult){
		// delete directoy - we were unable to add to the DB
		nslog("Unable to insert row");
		mysql_close($conn);
		die();
	}
	
	$id = mysql_insert_id();
	
	$json = array(
			      "id" => $id,
			      "themeName" => $folderName,
			      "success" => "true"
			      );
			      
	$to = "clockbuilder_flagged@gmtaz.com";
	$subject = "New Theme Flagged";
 	$body = "A user flagged theme named: $themeName <br/><p><img src=\"http://clockbuilder.gmtaz.com/resources/themes/$themeName/themeScreenshot.jpg\" /></p><br/><a href=\"http://clockbuilder.gmtaz.com/deleteTheme2.php?api=thisisasecretapikeygmt2745694&themeName=$themeName\">Delete Theme</a>";
 	
 	
$headers = "MIME-Version: 1.0\r\n";
$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";
 	
 	$emailDelievered = false;
	 if (mail($to, $subject, $body, $headers)) {
	  	$emailDelievered = true;
	  } else {
	   	
	  }
	if($emailDelievered){
		echo "flagged!";	
	}
	else
	{
		echo "email delivery failed";
	}
	mysql_close($conn);
}
else{
	mysql_close($conn);
	$json = array(
	"success" => "false",
	"error" => "Unauthorized"
	);
	print_r(json_encode($json));
	die ();
}


?>