' upload:
'
'
srcFolder = “\\server\share\“
 strUserID = “MyID”
 strPassword = “APasswordGoesHere”
 strURL = “https://www.theuploadwebsite.com/puthere/“

Set HTTP = WScript.CreateObject(“Microsoft.XMLHTTP”)
 Set fso = CreateObject(“Scripting.FileSystemObject”)
 Set folder = fso.getfolder(srcFolder)

For Each File in Folder.Files
 If fso.GetExtensionName(File)=”TXT” Then
 Set objStream = CreateObject(“ADODB.Stream”)
 objStream.Type = 1
 objStream.Open
 objStream.LoadFromFile(srcFolder & fso.GetFileName(File))

    HTTP.open “PUT”, strURL & fso.GetFileName(File), False, strUserID, strPassword
 WScript.Echo “Now uploading file ” & fso.GetFileName(File)


 HTTP.send objStream.Read

    WScript.Echo “Uploading complete for file ” & fso.GetFileName(File)
 fso.DeleteFile(File)
 End If
 Next
 WScript.Echo “All files uploaded.”

Set HTTP = Nothing
'
'
'
'

Function Download ( ByVal strUrl, ByVal strDestPath, ByVal overwrite )
    Dim intStatusCode, objXMLHTTP, objADOStream, objFSO
    Set objFSO = CreateObject("Scripting.FileSystemObject")

    ' if the file exists already, and we're not overwriting, quit now
    If Not overwrite And objFSO.FileExists(strDestPath) Then
        WScript.Echo "Already exists - " & strDestPath
        Download = True
        Exit Function
    End If

    WScript.Echo "Downloading " & strUrl & " to " & strDestPath

    ' Fetch the file
    ' need to use ServerXMLHTTP so can set timeouts for downloading large files
    Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP")
    objXMLHTTP.open "GET", strUrl, false
    objXMLHTTP.setTimeouts 1000 * 60 * 1, 1000 * 60 * 1, 1000 * 60 * 1, 1000 * 60 * 7
    objXMLHTTP.send()

    intStatusCode = objXMLHTTP.Status

    If intStatusCode = 200 Then
        Set objADOStream = CreateObject("ADODB.Stream")
        objADOStream.Open
        objADOStream.Type = 1 'adTypeBinary
        objADOStream.Write objXMLHTTP.ResponseBody
        objADOStream.Position = 0    'Set the stream position to the start

        'If the file already exists, delete it.
        'Otherwise, place the file in the specified location
        If objFSO.FileExists(strDestPath) Then objFSO.DeleteFile strDestPath

        objADOStream.SaveToFile strDestPath
        objADOStream.Close

        Set objADOStream = Nothing
    End If

    Set objXMLHTTP = Nothing
    Set objFSO = Nothing

    WScript.Echo "Status code: " & intStatusCode & VBNewLine 

    If intStatusCode = 200 Then
        Download = True
    Else
        Download = False
    End If
End Function


'
'
' another vbs upload
'
'======================================================================
' https-upload.vbs 1.0  @2009 by Frank4dd http://www.frank4dd.com/howto
' This script demonstrates a file upload to a WebDAV enabled webserver,
' using https (and proxy settings from IE) with basic web authentication
'
' Original authors and code references:
' - "ASP - File upload with HTTP Put" by Martin Clark  
'
' This program comes with ABSOLUTELY NO WARRANTY. You may redistribute
' copies of it under the terms of the GNU General Public License.
'======================================================================

'======================================================================
' Global Constants and Variables
'======================================================================
Const scriptVer  = "1.0"
Const UploadDest = "https://mywebdavserver.com/uploadurl"
Const UploadFile = "localpath-and-file"
Const UploadUser = "username"
Const UploadPass = "password"
Const UploadType = "binary"
dim strURL

function sendit()
  sData = getFileBytes(UploadFile, UploadType)
  sfileName= mid(UploadFile, InstrRev(UploadFile,"\")+1,len(UploadFile))
  
  dim xmlhttp
  set xmlhttp=createobject("MSXML2.XMLHTTP.3.0")
  strURL = UploadDest & "/" & UploadFile
  msgbox "Upload-URL: " & strURL
  xmlhttp.Open "PUT", strURL, false, UploadUser, UploadPass
  xmlhttp.Send sData
  Wscript.Echo "Upload-Status: " & xmlhttp.statusText
  set xmlhttp=Nothing
End function 

function showresult()
  Wscript.Echo "Complete. Check upload success at: " & strURL
end function

function getFileBytes(flnm, sType)
  Dim objStream
  Set objStream = CreateObject("ADODB.Stream")
  if sType="binary" then
    objStream.Type = 1 ' adTypeBinary
  else
    objStream.Type = 2 ' adTypeText
    objStream.Charset ="ascii"
  end if
  objStream.Open
  objStream.LoadFromFile flnm
  if sType="binary" then
    getFileBytes=objStream.Read 'read binary'
  else
    getFileBytes= objStream.ReadText 'read ascii'
  end if
  objStream.Close
  Set objStream = Nothing
end function

'=======================================================================
' End Function Defs, Start Main
'=======================================================================
' Get cmdline params and initialize variables
If Wscript.Arguments.Named.Exists("h") Then
  Wscript.Echo "Usage: https-upload.vbs"
  Wscript.Echo "version " & scriptVer
  WScript.Quit(intOK)
End If

sendit()
showresult()
Wscript.Quit(intOK)
'=======================================================================
' End Main
'=======================================================================