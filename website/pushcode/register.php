<?
if(isset($_GET['source'])){header('Content-type: text/plain; charset=utf-8');readfile(__FILE__);exit();}
if(isset($_GET['help']))
{
 header('Content-type: text/plain; charset=utf-8');
 ?>

 goog luck
 
 // License: MIT
 // Created by: Shimon Doodkin, late 2011, helpmepro1@gmail.com
 
 <?exit();
}

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
?><html>
<head>
<title>Give Source - Register a new Project</title>
</head>
<body>
<div><?
include("config.php");
$created=false;
if(isset($_REQUEST['name']))
{
$name=$_REQUEST['name'];

switch(1){default:

 if(!ereg("[a-zAZ0-9_]+",$name))
 {
  echo "bad name<br>";
  break;
 }

 if(file_exists($projects_folder.$name))
 {
  echo "a projct with the same name already exists<br>";
  echo "view the project <a href=\"".$website_url."register\">".htmlspecialchars($name)."</a><br>";
  break;
 }


 if(ereg("^\S+@\S+.\S+$",$_REQUEST['email']))
 {
  echo "email is required<br>";
  break;
 }
 
 if(!trim($_REQUEST['title']))
 {
  echo "title is required<br>";
  break;
 }
 
 //create folder
 if(!mkdir($projects_folder.$name,0755))
 {
  echo "error creating project folder<br>";
  break;
 }
 
 
 if(!mkdir($projects_folder.$name.'/version',0755))
 {
  echo "error creating version folder inside project folder<br>";
  break;
 }
 if(!mkdir($projects_folder.$name.'/original_id',0755))
 {
  echo "error creating original_id folder inside project folder<br>";
  break;
 }
 //save title, email, url 
 file_put_contents($projects_folder.$name.'/title.txt', $_REQUEST['title']);
 file_put_contents($projects_folder.$name.'/email.txt', $_REQUEST['email']);
 if($_REQUEST['url']) 
  file_put_contents($projects_folder.$name.'/url.txt', $_REQUEST['url']);

 $created=true;   
}//switch
}
?></div>
<style>
</style>

<div align="center"><span style="float:left"><a href="?help" style="float:left">help</a>, <a href="?source">source</a></span>
<a href="index.php">Home</a></div>
<?
if($created)
{
 ?>
 <h1>your project has been created</h1>
 <h2>view the project <a href="project/<?=urlencode($name)?>"><?=htmlspecialchars($name)?></a></h2>
 <?
}
else
{
?>
<h2>Register a Project</h2>
<form action="register.php" method="post" style="margin:0px">

Project Name:  <input type="text" name="name" value=""> [a-zAZ0-9_] (required)<br>
Project Title: <input type="text" name="title" value=""> (required) <br>
Related Url:   <input type="text" name="url" value=""> <br> 
Email:         <input type="text" name="email" value=""> (required) <br />
email may be used in case we have some problems, and we will need a contact with you,<br />
also to notify you of new contributions to your project.<br>
<input type="submit" value="Create Project">
</form>
<?}?>
</body>
</html>