<?php

 //Includes the CloudFiles PHP API.. Ensure the API files are located in your Global includes folder or in the same directory 
 header('Cache-Control: no-cache, must-revalidate');
 header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
 header('Content-type: application/json');
 
 require('./cloudFiles/cloudfiles.php');
 
 //Now lets create a new instance of the authentication Class.
	 $auth = new CF_Authentication('dcinzona','781b31ba4b7997fdccf5eb0ef357f656');
	 //Calling the Authenticate method returns a valid storage token and allows you to connect to the CloudFiles Platform.
	 $auth->authenticate();
	 
	 $pref = 'http://c480887.r87.cf2.rackcdn.com/';
	 $dbhost = 'internal-db.s94282.gridserver.com';
	 $dbuser = 'db94282_cbAdmin';
	 $dbpass = 'illiad.3583';
	 
	 function isThemeAlreadyInDB($name)
	 {
		  
		 $query = mysql_query("SELECT * FROM themes WHERE LOWER(themeName)='".strtolower($name)."'");
		 $numrows = mysql_num_rows($query);
		 
		 if($numrows>0){
		     return true;
		   }
		 else
		 {
		 	return false;
		 }
	 
	 }
	 
	 function downloadFile($filePath, $localPath)
	 {
	   $url  = $filePath;
	   $outputfile = $localPath;
	   $cmd = "wget -b -q \"$url\" -O $outputfile";
	   exec($cmd);
	   return $cmd;
		/*
	   $ch = curl_init($url);
	   curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	
	   $data = curl_exec($ch);
	
	   curl_close($ch);
	
	   file_put_contents($path, $data);
	   return $localPath;
	   */
	}
	 
	 function saveTheme($name,$originalName)
	 {
	 	$themeDir = 'resources/iphone/'.$name;
	 	//if(mkdir($themeDir))
	 	//{
	 		$plist = 'http://c480887.r87.cf2.rackcdn.com/'.$originalName.'/widgetsList.plist';
			$thumb = 'http://c480887.r87.cf2.rackcdn.com/'.$originalName.'/themeScreenshot.jpg';
			$bg = 'http://c480887.r87.cf2.rackcdn.com/'.$originalName.'/LockBackground.png';
		
		   $plistpath = $themeDir.'/widgetsList.plist';
		   $thumbpath = $themeDir.'/themeScreenshot.jpg';
			$bgpath = $themeDir.'/LockBackground.png';
			$ret = '';
		    $ret .= downloadFile($plist, $plistpath).'\n';
		   $ret .= downloadFile($thumb, $thumbpath).'\n';
		   $ret .= downloadFile($bg, $bgpath).'\n';
		   return $ret;
	 	//} 
	 }
	 
	 //The Connection Class Allows us to connect to CloudFiles and make changes to containers; Create, Delete, Return existing containers. 
	 $conn = new CF_Connection($auth);
	 //Lets go ahead and create container. 
	 $cont = $conn->get_container('clockBuilderThemes');
	 //Now lets make a new Object
	 $obj  = $cont->get_objects(0);
	 $x = 0;
	 
	 if($_REQUEST['op']=='updateDB')
	 {
	 $conndb = mysql_connect($dbhost, $dbuser, $dbpass) or die ('Error connecting to mysql');
	 
	 $dbname = 'db94282_clockbuilder';
	 mysql_select_db($dbname, $conndb);
	 }
	 
	 foreach ($obj as &$value) {
	    $pos = strpos($value,'/themeScreenshot.jpg');
	    
	    if($pos === false) {
	     // string needle NOT found in haystack
	    }
	    else {
	    	$value2 = str_replace('/themeScreenshot.jpg', '', $value);
	    	$value2 = str_replace('clockBuilderThemes/', '', $value2);
	    	$output = preg_replace("/[^A-Za-z0-9_-]/","",$value2); 
	    	
	    	if($_REQUEST['op']=='updateDB')
	    	{
	    		  
		    	if(!isThemeAlreadyInDB($output))
		    	{
		    		$udid = $value->metadata['Udid'];
		    		$category = 'Uncategorized';
		    		$device = 'iphone';
		    		$query = "INSERT INTO themes (themeName, category, device, author) VALUES ('".$output."', '".$category."', '".$device."','".$udid."')";
		    		$result = mysql_query($query);
		    		if(!$result)
		    		{
		    			$message  = 'Invalid query: ' . mysql_error() . "\n";
		    			$message .= 'Whole query: ' . $query;
		    			die($message);
		    		}
		    		else
		    		{
		    			$arr[$x] = array(
		    			"name" => $output,
		    			"udid" => $udid
		    			);
		    			$x++;
		    		}
		    	}
	    	}
	    	else if($_REQUEST['op']=='copyTheme')
	    	{
	    		$arr[$x] = saveTheme($output, $value2);
	    		$x++;
	    	}
	    	else
	    	echo 'no operation';
	    } 
	 }
	 
	 
 	echo json_encode($arr);
 	if($_REQUEST['op']=='updateDB')
 	{
 	 mysql_close($conndb);
 	 }
?>