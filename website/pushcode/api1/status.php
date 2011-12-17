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
// here should come tests
// we have no database so we need only to test files
$OK='ok';
$MESSAGE="welcome to push code server";

try
{
include("../config.php");
$FF=tempnam($temp_folder, 'testwrite');
$F=fopen($FF,"w+");
fwrite($F,'1');
fclose($F);
unlink($FF);
} catch (Exception $e) {
    $OK='error';
    echo "$OK:\r\n";
    echo 'Caught exception: ',  $e->getMessage(), "\n";
    exit();
}
//$OK="maintannence";
//$MESSAGE="the server is on maintannance";
echo "$OK\r\n";
echo "$MESSAGE";
?>