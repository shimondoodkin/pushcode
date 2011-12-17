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

$projects_folder=dirname(__FILE__).'/projectsdata/';
$temp_folder=dirname(__FILE__).'/temp/';
$website_url='http://doodkin.com/pushcode';

function projects()
{
 $a=array();
 global $projects_folder;
 $dh=opendir($projects_folder);
 while (false !== ($filename = readdir($dh))) {
  if($filename[0]=='.') continue;
  $a[]=$filename;
 }
 closedir($dh);
 return $a;
}
?>