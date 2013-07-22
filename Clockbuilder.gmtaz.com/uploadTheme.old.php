<?php

include('p.php');
$api=$_POST['api'];
$invalidChars = ereg("[^A-Za-z0-9 -_]", $_POST['themeName']);
$v = $_POST['v'];
if($api == 'SDFB52f4vw9230V45gdfg' && !$invalidChars && getValidVersion($v))
{	
	$dbhost = 'internal-db.s94282.gridserver.com';
	$dbuser = 'db94282_cbAdmin';
	$dbpass = 'illiad.3583';
	
	$conn = mysql_connect($dbhost, $dbuser, $dbpass) or die                      ('Error connecting to mysql');
	
	$dbname = 'db94282_clockbuilder';
	mysql_select_db($dbname, $conn);
	
	/*
	
	    [request addPostValue:name forKey:@"themeName"];
	    [request addPostValue:category forKey:@"category"];
	    [request addPostValue:UDID forKey:@"udid"];
	    [request addPostValue:@"iphone" forKey:@"device"];
	    [request addPostValue:@"SDFB52f4vw9230V45gdfg" forKey:@"api"];
	    [request addData:imageData withFileName:@"themeScreenshot.jpg" andContentType:@"image/jpeg" forKey:@"screenshot"];
	    [request addData:bgData withFileName:@"LockBackground.png" andContentType:@"image/png" forKey:@"background"];
	    [request addData:plist withFileName:@"widgetsList.plist" andContentType:@"application/x-plist" forKey:@"plist"];
	   */
	
	$name = $_POST['themeName'];
	$device = $_POST['device'];
	$category = $_POST['category'];
	$udid = $_POST['udid'];
	//$_POST[firstname]
	$createDir_path = "resources/".$device.'/'.strtolower($name);
	
	$shouldRun = false;
	if (file_exists($createDir_path) && is_dir($createDir_path))
	{
		$shouldRun = true;
	}
	else
	{
		if(mkdir($createDir_path))
			$shouldRun = true;
		else
			echo "unable to create directory at path ".$createDir_path;
			
	}
	if($shouldRun)
	{
		 $checkQuery = mysql_query("SELECT * FROM themes WHERE LOWER(themeName)='" .strtolower($name). "'");
          
      	  $query = "INSERT INTO themes (themeName, category, device, author) VALUES ('".$name."', '".$category."', '".$device."','".$udid."')";
          if(mysql_num_rows($checkQuery)>0){
          	$query = "UPDATE themes SET category='".$category."', themeName='".$name."' WHERE LOWER(themeName)='".strtolower($name)."'";
          	echo $name.' theme is being updated || ';
          	} 
          if (!mysql_query($query))
            echo 'Error: ' . mysql_error();
		  else
          	echo $name." record added/updated for ".$udid;
		
		
		$target_path = $createDir_path.'/';
		
		$screenshot = $_FILES['screenshot'];
		$bg = $_FILES['background'];
		$plist = $_FILES['plist'];
		
		if ((( $screenshot["type"] == "image/jpeg") &&	
			($bg["type"] == "image/png") &&
			($plist["type"] == "application/x-plist")))
		   {		  
		      if(!move_uploaded_file($screenshot["tmp_name"],
		      $target_path . $screenshot["name"])){
		        echo "unable to move file ".$screenshot["tmp_name"]." to ".$target_path . $screenshot["name"];	      
		      	return;
		      	}
	          if(!move_uploaded_file($bg["tmp_name"],
	          $target_path . $bg["name"])){
	            echo "unable to move file ".$bg["tmp_name"]." to ".$target_path . $bg["name"];
	          	return;
	          	}
              if(!move_uploaded_file($plist["tmp_name"], $target_path . $plist["name"])){
                echo "unable to move file ".$plist["tmp_name"]." to ".$target_path . $plist["name"];
              	return;
              }
              
             
		   }
		else
		  echo "Invalid file";
	}
	else
	{
		echo 'should run was false';
	}
	mysql_close($conn);
}
else
echo 'Unauthorized';

?>