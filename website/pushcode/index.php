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
<title>Give Source - Projects</title>
</head>
<body>
<xmp><?
include("config.php");
$projects=projects();
?></xmp>
<style>
</style>
<a href="register.php">Register</a><br /> 
<h2>Give Source projects:</h2>
<ul>
<?
sort($projects);
foreach($projects as $name)
{
 ?><li><a href="project.php?project=<?=urlencode($name)?>"><?=htmlspecialchars($name)?></a></li><?
}
?>
</ul>
<p>
the idea is to let people submit modifications efforlessly, 
stright from the code,
the more convinient the submit is the more changres will be submited.
other idea is to let people choose to submit the code for non public view as is,
with their personal information, like database logins and website titles etc'.
later project's maintainer will be able to exract the changes and add them to the open source code.
</p>
<p>
the service is free, experimental, contact: helpmepro1@gmail.com
</p>

</body>
</html>