<?php

$pirated = "1.5.3";
$inReview = "1.5.5";
$inDev = "1.5.6";
function getValidVersion($version)
{
$released = "1.5.5";
$inReview = "1.5.5";
$inDev = "1.6";
$inDevSub = "1.5.6";
$inDevSub2 = "1.5.6";

	return ($version == $inDev || $version == $inReview || $version == $released || $version == $inDevSub || $version == $inDevSub2 );
} 

$test = $_GET["test"];
if($test != "" && $test != null){
	var_dump(getValidVersion($test));
}

?>