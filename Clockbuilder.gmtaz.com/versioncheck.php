<?php

include('p.php');

$v = $_REQUEST['v'];

if(!getValidVersion($v))
	echo 'There is a newer version of ClockBuilder. Please update.';
else
	echo 'OK';

?>