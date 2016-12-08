<html>
 <body>
<!--  PortalSite Environment <?php $option = $_GET['environment']; ?><br> -->

<?php
date_default_timezone_set("America/New_York");
// echo "The time is " . date("h:i:sa");

?>


Environment is: 					<?php echo $env = $_POST["environment"]; ?><br> 
Existing Market Vertical is: 				<?php echo $market = $_POST['market']; ?><br> 
New Market Vertical is:                                 <?php echo $newmarketvertical =  $_POST['newmarketvertical']; ?><br><br>
Site Folder is:           			        <?php echo $sitefoldername = $_POST['sitefoldername']; ?><br> 


<?php
$myfile = fopen("/var/www/html/replication/in/myValues", "w") or die("Unable to open file!");
$txt = "$env,$market,$newmarketvertical,$sitefoldername   \n";
fwrite($myfile, $txt);
fclose($myfile);
?> 

// <?php
// exec ('php email_site_replication_notice.php', $output); 
// file_put_contents('file.txt', $output); 
// ?>


<!-- Execute site-replication.sh post output to screen and send communication to stakeholders  -->

<?php  $output =      shell_exec("replication/site-replication.sh"); 
echo "<pre>$output</pre>";
$retVal = `replication/site-replication.sh &2>1`;
if ($retVal) echo 'SWEET';
else echo 'POOP: ' . $retVal;
header("Location: $url/replication/site-replication.html");
  echo $htmlHeader;
  while($stuff){
    echo $stuff;
  }
  echo "<script>window.location = 'https://dplutladm1.ddtc.cmgdigital.com/replication/site-replication.html'";
?>


<?php  $output =      shell_exec("replication/in/logs_to_html.sh");
echo "<pre>$output</pre>";
$retVal = `replication/logs_to_html.sh &2>1`;
if ($retVal) echo 'SWEET';
else echo 'POOP: ' . $retVal;
?>



<!-- Read entire content in file -->
<?php

// current time
echo date('h:i:s') . "\n";

// sleep for 10 seconds
sleep(10);

// wake up !
echo date('h:i:s') . "\n";

//logs 
//$path="/var/www/html/replication/logs";
//chdir($path);
//$log =  exec('ls -1t | head -1');
//echo "Site Replication Logs URL https://dplutladm1.ddtc.cmgdigital.com/replication/logs/$log to view logs<br>";
//echo "$log";

//$homepage = file_get_contents("/var/www/html/replication/done/$done");
//echo "<pre>$homepage</pre>";

// ab?>  
 


<!-- read each line in file -->
<!-- <?php
$file1 = "/var/www/html/replication/done/test";
$lines = file($file1);
foreach($lines as $line_num => $line)
{
echo $line;
echo "<br>";
}
?> --> 

//<?php
//specify your server
//$server = "10.243.230.4";

//specify your username
 //   $username = "meth01";

    //select port to use for SSH
  //  $port = "22";

 //command that will be run on server B
   // $command = "eomutil";

 //form full command with ssh and command, you will need to use links above for auto authentication help
//$cmd_string = "ssh meth01@$env source /methode/meth01/.bash_profile; eomutil";

    //this will run the above command on server A (localhost of the php file)
 //   exec($cmd_string, $output1);

//echo '<pre>';
 //   print_r($output1);
  //  echo '</pre>';

//?>


</body>
</html> 
