#!/bin/bash
pushcode()
{
PROJECT_NAME="pushcode"
ARCHIVE_SRC="." #what files to send, for find command
PACK_DIR="$PWD" #where to save files
PUSHCODE_SERVER="http://doodkin.com/pushcode" #server urls, no ending slash

#note: this still sends these files
#you can add here frequently changing files like configuration files
#
COMPARE_IGNORE_FILES="`cat<<EOF
./pushcode.email
./pushcode.name
./pushcode.original.files
./pushcode.original.dirs
./pushcode.original.id
./pushcode.userid
./pushcode.version.id
./pushcode.version.files
./pushcode.version.dirs
EOF`"

#these are not regular files, links and dirs, everything to not md5sum it, just checks path when compares
COMPARE_IGNORE_DIRS="`cat<<EOF
.
EOF`"

MAX_SIZE_OF_A_FILE=5000 #bytes
MAX_SIZE_OF_TAR_GZ=5000 #bytes
#
#
######################## share code #######################
COMPARE_IGNORE_FILES="`echo \"$COMPARE_IGNORE_FILES\"|sed -r 's/\#.*$//'|sed -r '/^\s*$/d'|awk '{print " -not -ipath "$0}' |tr -d '\r'|tr -d '\n' `"
COMPARE_IGNORE_DIRS="`echo \"$COMPARE_IGNORE_DIRS\"|sed -r 's/\#.*$//'|sed -r '/^\s*$/d'|awk '{print " -not -ipath "$0}' |tr -d '\r'|tr -d '\n'`"
##some funxtions:
####shell script post
# i want it to work on all systems with no additional install
# there is no post support in busybox's wget, there is no curl,perl,php,python on every system by default but there is usally net cut - nc
# on windows there is vbscript
#
#first create an empty file
#echo -n "">/tmp/post_data
addfield()
{
NAME="$1"
VALUE="$2"
echo -en "-----------------------------7d833c20a70a14\r\nContent-Disposition: form-data; name=\"$NAME\"\r\n\r\n$VALUE\r\n">>/tmp/post_data;
}
addfile()
{
NAME="$1"
ADDFILENAME="$2"
[ ! -e $ADDFILENAME ] && echo "file does not exists:" "'$ADDFILENAME'"
echo -en "-----------------------------7d833c20a70a14\r\nContent-Disposition: form-data; name=\"$NAME\"; filename=\"$ADDFILENAME\"\r\nContent-Type: application/octet-stream\r\n\r\n">>/tmp/post_data;
cat $ADDFILENAME>>/tmp/post_data;
echo -en "\r\n">>/tmp/post_data;
}

NC_GZIP="";
which gzip > /dev/null && [ $? -eq 0 ] && NC_GZIP="gzip," #just check gzip
nc_post()
{
echo -en "-----------------------------7d833c20a70a14\r\n">>/tmp/post_data;
POST_KEEPFILES=0
URL=$1
URLHOST="`echo \"$URL\"|sed -r 's|^http://([^/]+).+$|\\1|g'`"
URLPATH="`echo \"$URL\"|sed -r 's|^http://[^/]+(/.+$)|\\1|g'`"
POST_SIZE="`ls -la /tmp/post_data|awk '{print$5}'`"
echo -ne "POST $URLPATH HTTP/1.1\r\nHost: $URLHOST\r\nUser-Agent: Pushcode SH v0.1.1\r\nAccept: text/xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5\r\nAccept-Language: en-gb,en;q=0.5\r\nAccept-Encoding: ${NC_GZIP}chunked\r\nAccept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\nConnection: close\r\nContent-Length: $POST_SIZE\r\nContent-Type: multipart/form-data; boundary=---------------------------7d833c20a70a14\r\n\r\n">/tmp/post_request
cat /tmp/post_data>>/tmp/post_request;
# if user does't have nc try to use dev/tcp
which nc > /dev/null
if [ $? -eq 0 ]; then
 echo -n "post using nc " >&2
 echo -n "..." >&2
 cat /tmp/post_request | nc $URLHOST 80 |cat>/tmp/post_response #netcat had bug in piping, so i repiped it thru cat
 echo -n "." >&2
else
 echo -n "post using bash stream " >&2
 exec 5<> /dev/tcp/$URLHOST/80
 ERR=$?
 if [ "$ERR" -ne 0 ] ; then
  echo "Error $ERR: COULD NOT CONNECT"
  exit $ERR;
 fi
 echo -n "." >&2
 cat /tmp/post_request >&5
 echo -n "." >&2
 cat <&5 >/tmp/post_response
 echo -n "."  >&2
 exec 5>&-
 echo -n "."  >&2
fi
echo -n " post transfered. parsing head ." >&2
cat /tmp/post_response |awk '{ if (NF == 1 && length($0)==1 )exit(0); print }' >/tmp/post_response_head
echo -n "."  >&2
RESULT_HEAD_SIZE="`ls -la /tmp/post_response_head|awk '{print$5}'`";
RESULT_HEAD_SIZE=`expr $RESULT_HEAD_SIZE + 3`;
tail -c +$RESULT_HEAD_SIZE /tmp/post_response>/tmp/post_response_body.gz
echo -n "."  >&2

POST_ENCODING=`cat  /tmp/post_response_head |awk '{if($1=="Content-Encoding:")print $2;}' |tr -d '\r'|tr -d '\n' `
POST_LOCATION=`cat  /tmp/post_response_head |awk '{if($1=="Location:")print $2;}' |tr -d '\r'|tr -d '\n' `
echo -n "."  >&2

[ -e /tmp/post_response_body ] && rm -f /tmp/post_response_body
if [ "$POST_ENCODING" == "gzip" ]; then
 echo -n " decompress gzip body ."  >&2
gzip -d /tmp/post_response_body.gz
 echo -n "."  >&2
elif [ "$POST_ENCODING"=="chunked" ]; then
 echo -n " parsing chunked response ."  >&2
 
read_chunk() # function from http://cfajohnson.com/shell/scripts/httpClient-sh by Chris F.A. Johnson
{
read -r -t 1 num
num=${num%%[!0-9a-fA-F]*}
#printf "CHUNK SIZE: %d (%s)\n" "$size" "$num" >&2
case $num in
"") return 0 ;;
esac
size=$( printf "%d\n" "0x${num#0[xX]}" )
[ "$size" -eq 0 ] && return 1
dd bs=$size count=1 2>/dev/null
}

RESULT_BODY_SIZE="`ls -la /tmp/post_response_body.gz|awk '{print$5}'`";
[ $RESULT_BODY_SIZE -gt 0 ] && (cat /tmp/post_response_body.gz | while read_chunk; do :; done;) >/tmp/post_response_body
 echo -n "."  >&2
else
 echo -n " use response as is ."  >&2
mv /tmp/post_response_body.gz /tmp/post_response_body
#echo "unknown header Content-Encoding: $POST_ENCODING"
#echo "supporting only chunked and gzip encoding"
 echo -n "."  >&2
fi
#echo " done. "  >&2
echo " result: "  >&2

echo ""  >&2

cat  /tmp/post_response_body

echo ""  >&2

#the data is in /tmp/post_response_body  cat it?, or not delete the file?
if [ $POST_KEEPFILES -eq 0 ] ; then
 [ -e /tmp/post_data ] && rm -f /tmp/post_data
 [ -e /tmp/post_request ] && rm -f /tmp/post_request
 [ -e /tmp/post_response ] && rm -f /tmp/post_response
 [ -e /tmp/post_response_head ] && rm -f /tmp/post_response_head
 [ -e /tmp/post_response_body.gz ] && rm -f /tmp/post_response_body.gz
 [ -e /tmp/post_response_body ] && rm -f /tmp/post_response_body
fi

}
wget_post()
{
URL=$1
wget --header="Content-Type: multipart/form-data; boundary=---------------------------7d833c20a70a14" --post-file="/tmp/post_data" "$URL"
rm /tmp/post_data;
}
curl_post()
{
 echo "#curl -T file -# -o output http://pastebin.com/"
}

#
#post example:
#echo -n "">/tmp/post_data
#addfield "name" "value"
#addfile "name" "/file" 
#wget --header="Content-Type: multipart/form-data; boundary=---------------------------7d833c20a70a14" --post-file="/tmp/post_data" "http://example.com/file.php"
# --post-file is not working in busybox version of wget#
#login example:
#wget --post-data="usrname=xxxx&pass=xxxx&submit=Login" --keep-session-cookies --save-cookies cookies.txt http://www.mapc.co.nz/administrator/index.php
#wget --load-cookies cookies.txt
#
#end wget
##end functions

# if machine id changed ask to regenerate ids
#USERID, the userid is just md5sum on random data prefferably stable data
USERID="`blkid |grep UUID |md5sum -b|head -c32`"

#EMAIL , maybe save it in temp folder
EMAIL_FILE="$PACK_DIR/pushcode.email"
if [ ! -e $EMAIL_FILE ]; then
 echo  "if there will be any questions:"
 read -p "Enter Email or press enter to contiune:" RESP
 echo "$RESP" >  $EMAIL_FILE
fi
EMAIL="`cat $EMAIL_FILE`"

#original
ORIGINAL_SUM_FILES="$PACK_DIR/pushcode.original.files"
if [ ! -e $ORIGINAL_SUM_FILES ]; then
 echo "Creating original md5sum of file"
# echo "#it is better to not modify this file, this file used to find out modified files from the last upload" >  $ORIGINAL_SUM_FILES
 find $ARCHIVE_SRC -type f $COMPARE_IGNORE_FILES -exec md5sum {} \;>>$ORIGINAL_SUM_FILES
fi

ORIGINAL_DIRS="$PACK_DIR/pushcode.original.dirs"
if [ ! -e $ORIGINAL_DIRS ]; then
 echo "Creating original list of dirs"
# echo "#it is better to not modify this file, this file used to find out modified dirs from the last upload" >   $ORIGINAL_DIRS
 find $ARCHIVE_SRC -not -type f $COMPARE_IGNORE_DIRS >>$ORIGINAL_DIRS
fi

ORIGINAL_ID_FILE="$PACK_DIR/pushcode.original.id"
if [ ! -e $ORIGINAL_ID_FILE ]; then
cat $ORIGINAL_SUM_FILES $ORIGINAL_DIRS|md5sum|head -c32>$ORIGINAL_ID_FILE
fi
ORIGINAL_ID="`cat $ORIGINAL_ID_FILE`"
echo "original id: $ORIGINAL_ID"
## end original

echo "check if server is available"
echo -n "">/tmp/post_data
[ -e /tmp/post_result ] && rm -f /tmp/post_result
nc_post "$PUSHCODE_SERVER/api1/status.php" | tee -a /tmp/post_result
CHECK_RESULT="`cat /tmp/post_result`"
[ -e /tmp/post_result ] && rm -f /tmp/post_result
SERVER_STATUS="`echo \"$CHECK_RESULT\"|head -n 1|sed 's/^\\s*//g'|sed 's/\\s*$//g'`"
SERVER_MESSAGE="`echo \"$CHECK_RESULT\"|sed 1d`"
if [ "$SERVER_STATUS" != "ok" ]; then
 //echo "server status error:$SERVER_STATUS"
 //echo "server message:$SERVER_MESSAGE"
 exit;
 //else
 //echo "server status:$SERVER_STATUS"
 //echo "server message:$SERVER_MESSAGE"
fi
## end check server

#changed version
VERSION_SUM_FILES="$PACK_DIR/pushcode.version.files"
[ -e $VERSION_SUM_FILES ] && rm -f $VERSION_SUM_FILES
echo "Creating version md5sum of file"
# echo "#it is better to not modify this file, this file used to find out modified files from the last upload" >  $VERSION_SUM_FILES
find $ARCHIVE_SRC -type f $COMPARE_IGNORE_FILES -exec md5sum {} \;>>$VERSION_SUM_FILES

VERSION_DIRS="$PACK_DIR/pushcode.version.dirs"
[ -e $VERSION_DIRS ] && rm -f $VERSION_DIRS
echo "Creating version list of dirs"
find $ARCHIVE_SRC -not -type f $COMPARE_IGNORE_DIRS >>$VERSION_DIRS

VERSION_ID_FILE="$PACK_DIR/pushcode.version.id"
cat $VERSION_SUM_FILES $VERSION_DIRS|md5sum|head -c32>$VERSION_ID_FILE
VERSION_ID="`cat $VERSION_ID_FILE`"
echo "version id: $VERSION_ID"
## end changed version


#check if server has original md5sum
#wget post:
echo -n "">/tmp/post_data
addfield "project" "$PROJECT_NAME"
addfield "original_id" "$ORIGINAL_ID"
addfile "original_md5sum_files" "$ORIGINAL_SUM_FILES"
addfile "original_dirs" "$ORIGINAL_DIRS"
[ -e /tmp/post_result ] && rm -f /tmp/post_result
nc_post "$PUSHCODE_SERVER/api1/check.php" | tee -a /tmp/post_result
CHECK_RESULT="`cat /tmp/post_result`"
[ -e /tmp/post_result ] && rm -f /tmp/post_result
CHECK_STATUS="`echo \"$CHECK_RESULT\"|head -n 1|tr -d '\r'|tr -d '\n'`"

#if [ "$CHECK_STATUS" == "found" ]; then
#if server has then submit changeset
#echo "result found sending partial";
#tar cf /tmp/changed.tar --files-from=/tmp/file

#echo "will use user id: $USERID"
#echo "will send $EMAIL (used to contact you if we will have some questions)"

#el
if [ "$CHECK_STATUS" == "notfound" ]; then
#if server doesn't have a relative copy then submit full
#echo "result is not exists";

echo -e "this script will send all files from folder ARCHIVE_SRC=$PWD/$ARCHIVE_SRC\r\nto pushcode server $PUSHCODE_SERVER"
while true; do
    read -p "Do you wish to continue?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# create tar file of files
[ -e /tmp/pushcode.tar.gz ] && rm -f /tmp/pushcode.tar.gz
tar czf /tmp/pushcode.tar.gz .

echo -n "">/tmp/post_data

addfield "project" "$PROJECT_NAME"

addfield "userid" "$USERID"
addfield "email" "$EMAIL"

addfield "original_id" "$ORIGINAL_ID"
addfile "original_md5sum_files" "$ORIGINAL_SUM_FILES"
addfile "original_dirs" "$ORIGINAL_DIRS"

addfield "version_id" "$VERSION_ID"
addfile "version_md5sum_files" "$VERSION_SUM_FILES"
addfile "version_dirs" "$VERSION_DIRS"

addfile "targz" "/tmp/pushcode.tar.gz"

[ -e /tmp/post_result ] && rm -f /tmp/post_result
nc_post "$PUSHCODE_SERVER/api1/submitfull.php" | tee -a /tmp/post_result
SUBMIT_RESULT="`cat /tmp/post_result`"
[ -e /tmp/post_result ] && rm -f /tmp/post_result

SUBMIT_STATUS="`echo \"$SUBMIT_RESULT\"|head -n 1|sed 's/^\\s*//g'|sed 's/\\s*$//g'`"

if [ "$SUBMIT_STATUS" == "submited_successfully" ]; then
[ -e $ORIGINAL_ID_FILE ] && rm -f $ORIGINAL_ID_FILE
[ -e $ORIGINAL_SUM_FILES ] && rm -f $ORIGINAL_SUM_FILES
[ -e $ORIGINAL_DIRS ] && rm -f $ORIGINAL_DIRS
  cp $VERSION_ID_FILE $ORIGINAL_ID_FILE
  cp $VERSION_SUM_FILES $ORIGINAL_SUM_FILES
  cp $VERSION_DIRS $ORIGINAL_DIRS
fi

#else

#echo "result is error"
#exit 1;
fi

#CHANGE_DIR="/tmp/pushcode"
#if [ -e $CHANGE_DIR ]; then
#rm -rf $CHANGE_DIR
#fi

#make diff|make list|clean list
#tar cf /tmp/changed.tar --files-from=/tmp/file
#gzip -dc archive.tar.gz | tar -r data/data/com.myapp.backup/./files/settings.txt | gzip >archive_new.tar.gz

}
pushcode