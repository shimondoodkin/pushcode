<?
header('Content-type: text/html; charset=utf-8');
if (get_magic_quotes_gpc()) {
    function stripslashes_gpc(&$value)
    {
        $value = stripslashes($value);
    }
    array_walk_recursive($_GET, 'stripslashes_gpc');
    array_walk_recursive($_POST, 'stripslashes_gpc');
    array_walk_recursive($_COOKIE, 'stripslashes_gpc');
    array_walk_recursive($_REQUEST, 'stripslashes_gpc');
}

?><?
include("../config.php");


function file_upload_error_message($error_code) {
     switch ($error_code) { 
         case UPLOAD_ERR_INI_SIZE: 
             return 'The uploaded file exceeds the upload_max_filesize directive in php.ini'; 
         case UPLOAD_ERR_FORM_SIZE: 
             return 'The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form'; 
         case UPLOAD_ERR_PARTIAL: 
             return 'The uploaded file was only partially uploaded'; 
         case UPLOAD_ERR_NO_FILE: 
             return 'No file was uploaded'; 
         case UPLOAD_ERR_NO_TMP_DIR: 
             return 'Missing a temporary folder'; 
         case UPLOAD_ERR_CANT_WRITE: 
             return 'Failed to write file to disk'; 
         case UPLOAD_ERR_EXTENSION: 
             return 'File upload stopped by extension'; 
         default: 
             return 'Unknown upload error'; 
     } 
}
 
$status="error";
$checked=false;
$message="";
if(isset($_REQUEST['project']))
{
 $checked=true;   

$project=$_REQUEST['project'];

switch(1){default:

 if(!ereg("[a-zAZ0-9_]+",$project))
 {
  $message.="bad project name\r\n";
  break;
 }

 if(!file_exists($projects_folder.$project))
 {
  $message.="a projct with the name '$project' does not exists\r\n";
  $message.="would you like to register it? \r\n";
  $message.="visit <a href=\"$website_url/register.php\">this page</a> to register a project\r\n";
  break;
 }

 if(!isset($_REQUEST['original_id']))
 {
  $message.="original_id is required\r\n";
  break;
 }
 $original_id=$_REQUEST['original_id'];
 
 if(!ereg("[a-zAZ0-9_]+",$original_id))
 {
  $message.="bad original_id\r\n";
  break;
 }

 if(!isset($_FILES['original_md5sum_files']))
 {
  $message.="uploading file original_md5sum_files is required\r\n";
  break;
 }
 
 if((isset($_FILES['original_md5sum_files'])&&$_FILES['original_md5sum_files']['error']>0))
 {
  $message.="error uploading original_md5sum_files, Error message: " . file_upload_error_message($_FILES['original_dirs']['error'])."\r\n";
  break;
 }
 
 if(!isset($_FILES['original_dirs']))
 {
  $message.="uploading file original_dirs is required\r\n";
  break;
 }
 
 if((isset($_FILES['original_dirs'])&&$_FILES['original_dirs']['error']>0))
 {
  $message.="error uploading original_dirs, Error message: " . file_upload_error_message($_FILES['original_dirs']['error'])."\r\n";
  break;
 }
 
 
 
 if(!isset($_REQUEST['version_id']))
 {
  $message.="version_id is required\r\n";
  break;
 }
 $version_id=$_REQUEST['version_id'];
 
 if(!ereg("[a-zAZ0-9_]+",$version_id))
 {
  $message.="bad version_id\r\n";
  break;
 }

 if(!isset($_FILES['version_md5sum_files']))
 {
  $message.="uploading file version_md5sum_files is required\r\n";
  break;
 }
 
 if((isset($_FILES['version_md5sum_files'])&&$_FILES['version_md5sum_files']['error']>0))
 {
  $message.="error uploading version_md5sum_files, Error message: " . file_upload_error_message($_FILES['version_dirs']['error'])."\r\n";
  break;
 }
 
 if(!isset($_FILES['version_dirs']))
 {
  $message.="uploading file version_dirs is required\r\n";
  break;
 }
 
 if((isset($_FILES['version_dirs'])&&$_FILES['version_dirs']['error']>0))
 {
  $message.="error uploading version_dirs, Error message: " . file_upload_error_message($_FILES['version_dirs']['error'])."\r\n";
  break;
 }
 
 if((isset($_FILES['targz'])&&$_FILES['targz']['error']>0)||(isset($_FILES['asis'])&&$_FILES['asis']['error']>0))
 {
  $message.="no data files uploaded\r\n";
  $message.="uploading targz file, Error message: " . file_upload_error_message($_FILES['targz']['error'])."\r\n";
  $message.="or uploading asis file, Error message: " . file_upload_error_message($_FILES['asis']['error'])."\r\n";
  break;
 }
 list($usec, $sec) = explode(" ", microtime());
 $version=date('Y_m_d_His_').substr($usec,2,3).rand(0,9);

 if(!mkdir($projects_folder.$project.'/version/'.$version,0755))
 {
  echo "error creating folder version/$version inside project folder <br>";
  break;
 }
 
 if(!mkdir($projects_folder.$project.'/version/'.$version.'/data',0755))
 {
  echo "error creating folder  version/$version inside project folder <br>";
  break;
 }

 $email =@$_REQUEST['email'];
 $userid=@$_REQUEST['userid'];
  
 file_put_contents($projects_folder.$project.'/version/'.$version.'/pushcode.userid', $userid);
 file_put_contents($projects_folder.$project.'/version/'.$version.'/pushcode.email', $email);
 
 move_uploaded_file($_FILES['original_md5sum_files']['tmp_name'], $projects_folder.$project.'/version/'.$version.'/pushcode.original.files');
 move_uploaded_file($_FILES['original_dirs']['tmp_name'], $projects_folder.$project.'/version/'.$version.'/pushcode.original.dirs');
 file_put_contents($projects_folder.$project.'/version/'.$version.'/pushcode.original.id', $original_id);
 
 move_uploaded_file($_FILES['version_md5sum_files']['tmp_name'], $projects_folder.$project.'/version/'.$version.'/pushcode.version.files');
 move_uploaded_file($_FILES['version_dirs']['tmp_name'], $projects_folder.$project.'/version/'.$version.'/pushcode.version.dirs');
 file_put_contents($projects_folder.$project.'/version/'.$version.'/pushcode.version.id', $version_id);
 
 move_uploaded_file($_FILES['targz']['tmp_name'], $projects_folder.$project.'/version/'.$version.'/data.tar.gz');
 move_uploaded_file($_FILES['asis']['tmp_name'], $projects_folder.$project.'/version/'.$version.'/data/'.$_FILES['asis']['name']);

 $F=fopen($projects_folder.$project.'/original_id/'.$original_id.'.txt','a+');
 fwrite($F,"$version\r\n");
 fclose($F);
 
 exec('tar -tzf '.$projects_folder.$project.'/version/'.$version.'/data.tar.gz', $exec_o, $exec_c);
 if($exec_s!=0)
 {
  $status="submited_maybe_error";
  $message.="maybe an error in tar $exec_s \r\n $exec_o\r\n";
 }
 else
 {
  $status="submited_successfully";
 }
 $UNTAR_CMD='tar -C '.$projects_folder.$project.'/version/'.$version.'/data -vxf '.$projects_folder.$project.'/version/'.$version.'/data.tar.gz';
 $UNTAR=`$UNTAR_CMD`;
 $message.="your version id is $version\r\n";

}//switch
}
if($checked)
{
 echo "$status\r\n";
 echo $message;
}
else
{
?><html>
<head>
<title>Give Source - Upload your version of the project (upload all files, not a diff)</title>
</head>
<body>
<div align="center"><span style="float:left"><a href="?help" style="float:left">help</a>, <a href="?source">source</a></span>
<a href="index.php">Home</a></div>
<h2>Check If we have an original, in order to upload only diff</h2>
<form action="check.php" method="post" style="margin:0px">
Project Name:  <input type="text" name="project" value=""> [a-zAZ0-9_] (required)<br>
Original Id:  <input type="text" name="original_id" value=""> [a-zAZ0-9_] (required)<br>
Original md5 sums of Files: <input type="file" name="original_md5sum_files" > (required) <br>
Original list of Dirs: <input type="file" name="original_dirs" > (required) <br>
Version Id:  <input type="text" name="version_id" value=""> [a-zAZ0-9_] (required)<br>
Version md5 sums of Files: <input type="file" name="version_md5sum_files" > (required) <br>
Version list of Dirs: <input type="file" name="version_dirs" > (required) <br>
<br>
Version tar.gz of files: <input type="file" name="targz" > (required) <br>
Version As Is file: <input type="file" name="asis" > (required) <br>

<br>
User ID:  <input type="text" name="userid" value=""> [a-zAZ0-9_]<br>
Email:    <input type="text" name="email" value="">  <br />
<input type="submit" value="Create Project">
</form>
</body>
</html>
<?
}
?>