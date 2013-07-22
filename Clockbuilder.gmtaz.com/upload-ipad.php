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
	
	
function removeRN($string){


$string = str_replace("\n", "", $string);
$string = str_replace("\r", "", $string);
return $string;


}
	
$api=removeRN($_POST['api']);
$v = removeRN($_POST['v']);

function nslog($string){
	if($api=='test'){
		print_r("\n$string\n");
		return true;
	}
	return false;
}
$testing = ($api=='test');
function rrmdir($dir) {
   if (is_dir($dir)) {
     $objects = scandir($dir);
     foreach ($objects as $object) {
       if ($object != "." && $object != "..") {
         if (filetype($dir."/".$object) == "dir") rrmdir($dir."/".$object); else unlink($dir."/".$object);
       }
     }
     reset($objects);
     rmdir($dir);
   }
   return true;
 } 
function clean($badID, $badDir, $connection, $msg){

	rrmdir($badDir);
	if($badID>0){
		$sqlClean = "DELETE FROM `themesNumbered` WHERE `themesNumbered`.`id` = $badID LIMIT 1";
		if(!$connection){
		
			die('$conn is null');
		
		}
		
		if(!mysql_query($sqlClean, $connection)){
			nslog("unable to execute db clean command");
		}	
	}
	else {
		
		$json = array(
		"success" => "".nslog(''),
		"error" => "$badID was <= 0"
		);
		print(json_encode($json));
	}
	$json = array(
	"success" => "".nslog(''),
	"error" => "Cleaned directory $badDir and deleted row: $badID",
	"message" => $msg
	);
	print_r(json_encode($json));
}


if(!getValidVersion($v)){

	mysql_close($conn);

	$json = array(
	"success" => "false",
	"error" => "Invalid Version"
	);
	print_r(json_encode($json));
	die ();

}

if($api == 'SDFB52f4vw9230V45gdfg' || $api=='test')
{	
	$category = removeRN($_POST['category']);
	$udid = removeRN($_POST['udid']);
	
	
	$sqlGetNextFolder = "SELECT MAX(CAST(`themeName` as SIGNED)+1) as `nextFolder` FROM themesNumbered";
	$getLastRow = "SELECT * FROM themesNumbered ORDER BY `id` DESC LIMIT 1";
	
	$folderQuery = mysql_query($getLastRow, $conn);
	$folderName = -1;
	
	if($folderQuery!=0){
		if(mysql_num_rows($folderQuery)==1)
		{	
		  $row = mysql_fetch_row($folderQuery);
		  $id = $row[0];
		  $folderName = $row[1] +1;	
		  $dbCat = $row[2];
		  $dbudid = $row[3];
		  
		  $data = array(
		  "id" => $row[0],
		  "themeName" => $row[1],
		  "category" => $row[2],
		  "udid" => $row[3]
		  );
		  
		  $json = array(
		  "newestTheme" => $data
		  );
		  
		  nslog(json_encode($json));
		  
		}
		
		if($folderName!=-1)
		{
		//continue saving
		
			$createDir_path = "resources/themes/$folderName";
			
			if($testing){
				
				$shouldRun = false;
				while (file_exists($createDir_path) && is_dir($createDir_path))
				{
					//try again
					$folderName += 1;
					$createDir_path = "resources/themes/$folderName";
				}
				
				if(mkdir($createDir_path)){
					$shouldRun = true;
					nslog('directory created. shouldRun:'.$shouldRun);
				}
				else{			
					nslog('directory NOT created at path:'.$createDir_path.'. shouldRun:'.$shouldRun);
					mysql_close($conn);
					die ("unable to create directory at path ".$createDir_path);
				}
				if($shouldRun){
				
					//insert new row into SQL to prevent another user from 
					$insert = "INSERT INTO `themesNumbered` (`themeName`,`category`,`udid`, `iPad`) VALUES ('$folderName','$category','$udid', 1)";
					$id;
					$insertResult = mysql_query($insert, $conn);
					if(!$insertResult){
						// delete directoy - we were unable to add to the DB
						nslog("Unable to insert row");
						clean($id,$createDir_path,$conn,"Unable to insert row");
						
					}
					else {
						//continue
						$id = mysql_insert_id();
						
						$target_path = $createDir_path.'/';
						
						$screenshot = $_FILES['screenshot'];
						$bg = $_FILES['background'];
						$plist = $_FILES['plist'];
						print_r("screenshot=>");
						print_r($screenshot);
						print_r("<=Screenshot");
						if ((( $screenshot["type"] == "image/jpeg") &&	
							($bg["type"] == "image/png") &&
							($plist["type"] == "application/x-plist")))
						   {		  
						   
						   
						      if(!move_uploaded_file($screenshot["tmp_name"],
						      $target_path . $screenshot["name"]))
						      {
						      
						      	clean($id,$createDir_path,$conn, "move_uploaded_file($screenshot) failed");
						      	if($testing){
						      	 nslog("bg screenshot:".$screenshot["tmp_name"]);
						      	 nslog("bg screenshot:".$target_path . $screenshot["name"]);
						      	}
						        
						      }
						      	
						      if(!move_uploaded_file($bg["tmp_name"],
						      $target_path . $bg["name"]))
						      {
						      
						        clean($id,$createDir_path,$conn, "move_uploaded_file($bg) failed");
						        if($testing){
						         nslog("bg tmp_name:".$bg["tmp_name"]);
						         nslog("bg target:".$target_path . $bg["name"]);
						        }
						        
						      }
						      	
						      if(!move_uploaded_file($plist["tmp_name"], $target_path . $plist["name"]))
						      {
						      
						      	clean($id,$createDir_path, $conn, "move_uploaded_file($plist) failed");
						      	if($testing){
						      	 nslog("plist tmp_name:".$plist["tmp_name"]);
						      	 nslog("plist target:".$target_path . $plist["name"]);
						      	}
						      	
						      }
						      
						      //so far so good - return something so device knows it was a success
						      $json = array(
						      "id" => $id,
						      "themeName" => $folderName,
						      "success" => "true"
						      );
						      
						      echo json_encode($json);
						      if($testing){
						      
						      	nslog('Upload test success - delete folder and row manually');
						      	#clean($id,$createDir_path,$conn);
						      	
						      }
						      
						   }   
						else{
							nslog('filetypes not correct');
							nslog('screenshot type:'. $screenshot["type"] );
							nslog('bg type:'. $bg["type"] );
							nslog('plist type:'. $plist["type"] );						
						    clean($id,$createDir_path,$conn,$_FILES);
						}
					}
				
				}
			}
			else {
				$json = array(
				"success" => "false",
				"error" => "Testing API Used",
				"api" => $api,
				"version" => $v
				);
				nslog(json_encode($json));
				
				mysql_close($conn);
				die();
			}
		}
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