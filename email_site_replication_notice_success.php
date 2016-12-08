<?php
 $to = "Walter.Hicks@coxinc.com, Walter.Hicks@coxinc.com";
 $subject = "Success CMGt Site Replication Completed no Errors and/or Failures";

 $message = "
 <html>
 <head>
 <title>Success CMGt Site Replication Completed no Errors and/or Failures</title>
 </head>
 <body>
 <p>Success CMGt Site Replication Completed no Errors and/or Failures</p></font>
 <table>
 <p>
 User selected Environment is: trn_editorall_10.243.230.7 </br>
 User selected Market Vertical is: Athens-Radio-CONTENT </br>
 User selected Site Folder Name is: </br>
 Site Replication Results https://dplutladm1.ddtc.cmgdigital.com/replication/logs/Athens-Radio-CONTENT.log_12-07-2016-14-13-58
 </p>
 <tr>
<!-- <td>John</td> -->
<!--  <td>Doe</td> -->
 </tr>
 </table>
 </body>
 </html>
 ";

// Always set content-type when sending HTML email
 $headers = "MIME-Version: 1.0" . "\r\n";
 $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";

 // More headers
 $headers .= 'From: Walter.Hicks@coxinc.com>' . "\r\n";
 $headers .= 'Cc: Walter.Hicks@coxinc.com' . "\r\n";

 mail($to,$subject,$message,$headers);
 ?>

