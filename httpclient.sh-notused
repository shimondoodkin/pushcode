#!/bin/bash
# credit: bashcurescancer.com and Chris F.A. Johnson http://cfajohnson.com/shell/scripts/httpClient-sh
# Author: see http://bashcurescancer.com/improve-this-script-win-100-dollars.html
# Modified and extended by "Chris F.A. Johnson" <cfajohnson@gmail.com>, 2007-02-25 
# Web site: http://cfaj.freeshell.org

## Features:
##  Will use non-standard port if specified in URL
##     (e.g., http://example.com:8080/index.html)
##  Checks for successful connection
##  Moderately meaningful exit codes
##  Parses headers for
##     Successful request
##     Content-Type
##     Content-Length
##     Transfer-Encoding: chunked (the reason for f19 before and 0 after HTML)
##  Stores headers in shell array
##  Command-line options:
##     Save output to a file
##     Save headers to a file
##     Verbose output in various degrees
##  Automatic redirect on 301, 302 and 303 return codes
##  Works in KornShell93 as well as bash

## To do:
##     Better usage function, including command-line options
##     Strip CRs from chunked encoded text
##     Add From: line to request
##     More comments

## References:
##   HTTP Made Really Easy:
##      A Practical Guide to Writing Clients and Servers
##      <http://www.jmarshall.com/easy/http/>

httpClient()
{
  local URL=$1
  local type=
  local HEADERS HOST RESOURCE PORT=$PORT

  case $URL in
      http://*) ;;
      "") die "$ERR_USAGE" "$USAGE" ;;
      *) die "$ERR_URL" "$URL not a valid URL. Must start with http://" ;;
  esac

  # Get the host
  HOST=${URL#http://} ## Discard http://
  case $HOST in
      */*) RESOURCE=/${HOST#*/}       # Extract resource from URL
           HOST=${HOST%"$RESOURCE"}
           ;;
      *) 
          ;;
  esac
  case $HOST in
      *:*) PORT=${HOST##*:}
           HOST=${HOST%:*}
           ;;
  esac

  [ $pr_info -eq 1 ] && {
      echo "HOST=$HOST"
      echo "PORT=$PORT"
      echo "RESOURCE=$RESOURCE"
  } >&2

  exec 3<> /dev/tcp/$HOST/$PORT       # Open connection
  ERR=$?
  [ "$ERR" -ne 0 ] && die "$ERR_CONNECT" "Error $ERR: COULD NOT CONNECT"

  request >&3
  [ $pr_request -eq 1 ] && request >&2

  location=
  type=
  length=

  ## Get headers
  while :
  do
    IFS= read -r -u 3 -t ${TIMEOUT:=1} || die "$ERR_HEADER"
    LINE=${REPLY%"$CR"}
    [ "${pr_header:-0}" -eq 1 ] && printf "%s\n" "$LINE" >&2
    case $LINE in
        "") break ;; ## end of headers
        HTTP/1.[01]*)
               set -- $LINE
               status_code=$2
               shift 2
               message=$*
               ;;
        Transfer-Encoding:*chunked*)
               type=chunked$type
               ;;
        Content-Length:*)
               length=${LINE#Content-Length: }
               ;;
        Content-Type:*)
               type=$type${LINE#Content-Type: }
               ;;
        Location:*)
               location=${LINE#Location: }
               ;;
    esac
    HEADERS[${#HEADERS[@]}]=$LINE  # Save headers, for no reason
  done

  case $status_code in
      301|302|303) PORT=80 httpClient "$location"; return ;;
      [45]*) printf "Error %d: %s\n" "$status_code" "$message" >&2; return ;;
  esac

  ## Redirect stdout to $outfile if specified
  [ -n "$outfile" ] && {
      exec > "$outfile" || die "$ERR_WRITE" "Could not write to $outfile"
  }

  [ $pr_body -eq 1 ] && {  ## Print body to stdout (assumes text)
      while IFS= read -u3 -r -t1 line
      do
        printf "%s\n" "${line%"$CR"}"
      done
      exit
  }

  ## Get the body
  case $type in
      chunked*) while read_chunk; do :; done ;;
      Text/*)
          while :
          do
            IFS= read -r -u 3 -t "$TIMEOUT" ||   # read from server
            die "$ERR_TIMEOUT" "Server timed out"
            printf "%s\n" "${REPLY%$CR}"   # Eliminate \r, we are using UNIX
          done
          ;;
      *) dd bs=$length count=1 <&3 2>/dev/null ;;
  esac

  exec 3<&-
}

request()
{
    printf "GET %s HTTP/1.1\r\n" "${RESOURCE:-/}"  # Request resource, only care about gets.
    printf "host: %s:%d\r\n" "$HOST" "$PORT"       # Send host header, what about encoding?
    printf "User-agent: %s %s\r\n" "$user_agent" "$version" # Send user agent
    printf "\r\n"                                  # End request
}

read_chunk()
{
    IFS= read -r -t1 num
    num=${num%%[!0-9a-fA-F]*}
    case $num in
        "") return 0 ;;
    esac
    size=$( printf "%d\n" "0x${num#0[xX]}" )
    [ $verbose -gt 2 ] && printf "CHUNK SIZE: %d (%s)\n" "$size" "$num" >&2
    [ "$size" -eq 0 ] && return 1
    dd bs=$size count=1 2>/dev/null
} <&3

die() {
    result=$1
    shift
    [ -n "$*" ] && printf "%s\n" "$*" >&2
    exec 3<&-

    [ -n "$headerfile" ] && printf "%s\n" "${HEADERS[@]}" > "$headerfile"
    exit $result
}

usage()
{
   cat <<EOF

NAME: httpClient-sh - shell script to retrieve page via HTTP

USAGE: httpClient-sh [OPTIONS] URL ## URL must begin with http://

OPTIONS:
  -h FILE      -- store headers in FILE
  -o FILE      -- store the page in FILE
  -u USERAGENT -- send USERAGENT instead of the default, $user_agent
  -v OPTIONS   -- verbose output, determined by one or more argumentL
       -b  -- send body to stdout (assumes text page)
       -h  -- print headers to stderr
       -i  -- print URL info to stderr
       -r  -- print the HTTP request to stderr

EOF
}

CR=$'\r'
NL=$'\n'
progname=${0##*/}
user_agent=$progname
version=0.1
ERR_USAGE=1
ERR_URL=2
ERR_CONNECT=3
ERR_REQUEST=4
ERR_HEADER=5
ERR_TIMEOUT=6
ERR_WRITE=7

PORT=80
headerfile=
outfile=
verbose=0
pr_header=0
pr_info=0
pr_body=0
pr_request=0

while getopts h:o:u:v: opt
do
  case $opt in
      h) headerfile=$OPTARG ;;
      o) outfile=$OPTARG ;;
      u) user_agent=$OPTARG ;;
      v) while :
         do
           case $OPTARG in
               b*) pr_body=1 ;;
               h*) pr_header=1 ;;
               i*) pr_info=1 ;;
               r*) pr_request=1 ;;
               "") break ;;
           esac
           OPTARG=${OPTARG#?}
         done
         ;;
      *) usage; exit 1 ;;
  esac
done
shift "$(( $OPTIND - 1 ))"
#echo pr_header=$pr_header >&2
httpClient "$@"

[ -n "$headerfile" ] && printf "%s\n" "${HEADERS[@]}" > "$headerfile"
