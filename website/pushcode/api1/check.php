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
 
 if(!file_exists($projects_folder.$project.'/original_id/'.$original_id.'.txt'))
 {
  $status="notfound";
  $message.="the original_id $original_id for project '$project' does not exists yet\r\n";
  break;
 }
 
 $original_files=file_get_contents($_FILES['original_md5sum_files']['tmp_name']);
 $original_dirs=file_get_contents($_FILES['original_dirs']['tmp_name']);
  
 $pushcode_change_files=file_get_contents($projects_folder.$project.'/original_id/'.$original_id.'.txt');
 $lines=split('[\r\n]+',trim($pushcode_change_files));
 $isfound=false;
 foreach($lines as $line)
 {
  if( file_exists($projects_folder.$project.'/version/'.$line))
  {

   $compare_files="";
   if( file_exists($projects_folder.$project.'/version/'.$line.'/pushcode.version.files'))
    $compare_files=file_get_contents($projects_folder.$project.'/version/'.$line.'/pushcode.version.files');

   $compare_dirs="";
   if( file_exists($projects_folder.$project.'/version/'.$line.'/pushcode.version.dirs'))
    $compare_dirs=file_get_contents($projects_folder.$project.'/version/'.$line.'/pushcode.version.dirs');
   
   if($compare_files==$original_files && $compare_dirs==$original_dirs )
   {
    $isfound=true;
    $status="found";
    break;
   }
  }
 }
 if(!$isfound)
 {
  $status="notfound";
  $message.="the original_id is found but a matching version is not found\r\n";
  break;
 }
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
<title>Give Source - Check If we have an original copy for your project, in order to upload only diff</title>
</head>
<body>
<div align="center"><span style="float:left"><a href="?help" style="float:left">help</a>, <a href="?source">source</a></span>
<a href="index.php">Home</a></div>
<h2>Check If we have an original, in order to upload only diff</h2>
<form action="check.php" method="post" style="margin:0px">
Project Name:  <input type="text" name="project" value=""> [a-zAZ0-9_] (required)<br>
Original Id:  <input type="text" name="original_id" value=""> [a-zAZ0-9_] (required)<br>
Original Files: <input type="file" name="original_md5sum_files" > (required) <br>
Original Dirs: <input type="file" name="original_dirs" > (required) <br>
<input type="submit" value="Create Project">
</form>
</body>
</html>
<?
}
?>