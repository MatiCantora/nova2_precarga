<%@ CodePage=65001 Language="VBScript"%>

<%
Option Explicit
Response.Buffer = True
%>
<%
 ' FCKeditor - The text editor for Internet - http://www.fckeditor.net
 ' Copyright (C) 2003-2009 Frederico Caldeira Knabben
 '
 ' == BEGIN LICENSE ==
 '
 ' Licensed under the terms of any of the following licenses at your
 ' choice:
 '
 '  - GNU General Public License Version 2 or later (the "GPL")
 '    http://www.gnu.org/licenses/gpl.html
 '
 '  - GNU Lesser General Public License Version 2.1 or later (the "LGPL")
 '    http://www.gnu.org/licenses/lgpl.html
 '
 '  - Mozilla Public License Version 1.1 or later (the "MPL")
 '    http://www.mozilla.org/MPL/MPL-1.1.html
 '
 ' == END LICENSE ==
 '
 ' This is the File Manager Connector for ASP.
%>
<!--#include file="config.asp"-->
<!--#include file="util.asp"-->
<!--#include file="io.asp"-->
<!--#include file="basexml.asp"-->
<!--#include file="commands.asp"-->
<!--#include file="class_upload.asp"-->
<!--#include virtual="meridiano/scripts/pvDB_utiles.asp"-->

<script language="JScript" runat="Server"> 
 
 function getFolder_id(currentFolder)
   {
   var str_reg = "/$"
   var reg = new RegExp(str_reg)
   currentFolder = currentFolder.replace(reg, '')
   
   var str_reg = "^/"
   var reg = new RegExp(str_reg)
   currentFolder = currentFolder.replace(reg, '')
   
   var folders = currentFolder.split('/')
   var strSQL
   var rs
   
   strSQL = "Select * from ref_files where f_nro_tipo = -1 and f_depende_de is null" 
   rs = DBOpenRecordset(strSQL)
   var folder_id = rs.fields("f_id").value
   DBCloseRecordset(rs)
   for (var f_nombre in folders)
     if (folders[f_nombre] != '')
       {
       strSQL = "Select * from ref_files where f_nombre = '" + folders[f_nombre] + "' and f_nro_tipo = 0 and f_depende_de " 
       strSQL += folder_id == 0 ? ' is null' : ' = ' + folder_id
       rs = DBOpenRecordset(strSQL)
       folder_id = rs.fields("f_id").value
       }
   DBCloseRecordset(rs)    
   return folder_id
   }
   
  function js_GetFolders(resourceType, currentFolder)
   {
    
	var folder_id = getFolder_id(currentFolder)
	//folder_id = 0
	Response.write("<Folders>")
	
	var strSQL = "Select * from ref_files where f_nro_tipo = 0 and f_depende_de "
	strSQL += folder_id == 0 ? ' is null' : ' = ' + folder_id
	var rs = DBOpenRecordset(strSQL)
	while (!rs.eof)
	  {
	  Response.write("<Folder name='" + rs.fields('f_nombre').value + "' />")
	  rs.movenext()
	  }
	DBCloseRecordset(rs)
	
	Response.write("</Folders>")
	
	
   }  
   
 function js_GetFoldersAndFiles(resourceType, currentFolder)
   {
	var folder_id = getFolder_id(currentFolder)

	var ext = ConfigAllowedExtensions.item(resourceType)
	var strWhere
	if (ext != '')
	  strWhere = " and charindex(f_ext, '" + ext + "') <> 0"
	
	
	Response.write("<Folders>")
	var strSQL = "Select * from ref_files where f_nro_tipo = 0 and f_depende_de "
	strSQL += folder_id == 0 ? ' is null' : ' = ' + folder_id
	rs = DBOpenRecordset(strSQL)
	while (!rs.eof)
	  {
	  Response.write("<Folder name='" + rs.fields('f_nombre').value + "' />")
	  rs.movenext()
	  }
	DBCloseRecordset(rs)
	
	Response.write("</Folders>")
	Response.write("<Files>")
	strSQL = "Select * from ref_files where f_nro_tipo = 1 " + strWhere + " and f_depende_de "
	strSQL += folder_id == 0 ? ' is null' : ' = ' + folder_id
	rs = DBOpenRecordset(strSQL)
	while (!rs.eof)
	  {
	  Response.write("<File name='" + rs.fields('f_nombre').value + '.' + rs.fields('f_ext').value + "' size='" + rs.fields('f_size').value + "' url='../../../wiki/archivos/file" + rs.fields('f_id').value  + "." + rs.fields('f_ext').value + "' />")
	  rs.movenext()
	  }
	DBCloseRecordset(rs)
	Response.write("</Files>")
   }	

 function js_CreateFolder(resourceType, currentFolder)
   {
   var folder_id = getFolder_id(currentFolder)
   //Validar nombre de directorio
   var sNewFolderName = Request.QueryString("NewFolderName")
   var iErrNumber = 0
   var sErrDescription = ''
   var sErrorNumber = 0
   try
     {
     //rs = DBOpenRecordset('Select max(f_id) as max_id from ref_files')
    // var f_id = rs.fields('max_id').value+1
     var strSQL = 'INSERT INTO ref_files([f_nombre], [f_ext], [f_descripcion], [f_path], [f_falta], [f_nro_tipo], [f_depende_de])'
     strSQL += "VALUES('" + sNewFolderName + "', '', '', '', getdate(), 0, case when " + folder_id + " = 0 then null else " + folder_id + " end)"
     DBExecute(strSQL)
     }
   catch(e)  
     {
     sErrorNumber = "102"
     iErrNumber = "102"
     sErrDescription = ''
     }
   Response.Write("<Error number='" + sErrorNumber + "' originalNumber='" + iErrNumber + "' originalDescription='" + sErrDescription + "' />")
   }
   
 function js_FileUpload(resourceType, currentFolder, sCommand)
   {
   
    //var oUploader = new NetRube_Upload()
    oUploader.MaxSize = 0
    oUploader.Allowed = ConfigAllowedExtensions.Item(resourceType)
    oUploader.Denied = ConfigDeniedExtensions.Item(resourceType)
    oUploader.HtmlExtensions = ConfigHtmlExtensions
    oUploader.GetData()

    var sErrorNumber
    sErrorNumber = "0"

    var sFileName
    var sOriginalFileName
    var sExtension
    var sSize
    sFileName = ""

    if (oUploader.ErrNum > 0)
      sErrorNumber = "202"
    else
      {
      var folder_id = getFolder_id(currentFolder)
      //Get the uploaded file name.
	  sFileName	= oUploader.File("NewFile").Name
	  sExtension = oUploader.File("NewFile").Ext
	  sSize = oUploader.File("NewFile").size
	  sOriginalFileName = sFileName.replace('.'+sExtension, '')
	  //obtener id
	  rs = DBOpenRecordset('Select max(f_id) as max_id from ref_files')
	  var f_id = rs.fields('max_id').value+1
	  //var path = ConfigUserFilesPath + '\\' + 
	  var sServerDir =  Request.ServerVariables(4).Item + "\\wiki\\archivos"
	  oUploader.SaveAs("NewFile", sServerDir + "\\file" + f_id + '.' +  sExtension)
	  
	  if (oUploader.ErrNum > 0)
	    sErrorNumber = "202"
      
       var strSQL = 'INSERT INTO ref_files([f_id], [f_nombre], [f_ext], [f_descripcion], [f_path], [f_falta], [f_nro_tipo], [f_depende_de], [f_size])'
       strSQL += "VALUES(" + f_id + " ,'" + sOriginalFileName + "', '" + sExtension + "', '', '', getdate(), 1, case when " + folder_id + " = 0 then null else " + folder_id + " end, " + Math.round(sSize / 1024) + ")"
       DBExecute(strSQL)
       sErrorNumber = '0'
      }
    oUploader = null
	var sFileUrl = currentFolder
	//sFileUrl = CombinePaths( GetResourceTypePath( resourceType, sCommand ) , currentFolder )
	//sFileUrl = CombinePaths( sFileUrl, sFileName )
	SendUploadResults(sErrorNumber, sFileUrl, sFileName, "")  
    
}  

</script>
<%

If ( ConfigIsEnabled = False ) Then
	SendError 1, "This connector is disabled. Please check the ""editor/filemanager/connectors/asp/config.asp"" file"
End If

Dim oUploader

DoResponse

Sub DoResponse()
	Dim sCommand, sResourceType, sCurrentFolder
    
	' Get the main request information.
	sCommand = Request.QueryString("Command")

	sResourceType = Request.QueryString("Type")
	If ( sResourceType = "" ) Then sResourceType = "File"

	sCurrentFolder = GetCurrentFolder()

	' Check if it is an allowed command
	if ( Not IsAllowedCommand( sCommand ) ) then
		SendError 1, "The """ & sCommand & """ command isn't allowed"
	end if

	' Check if it is an allowed resource type.
	if ( Not IsAllowedType( sResourceType ) ) Then
		SendError 1, "The """ & sResourceType & """ resource type isn't allowed"
	end if

	' File Upload doesn't have to Return XML, so it must be intercepted before anything.
	If ( sCommand = "FileUpload" ) Then
	    Set oUploader = New NetRube_Upload
		js_FileUpload sResourceType, sCurrentFolder, sCommand
		Exit Sub
	End If

	SetXmlHeaders

	CreateXmlHeader sCommand, sResourceType, sCurrentFolder, GetUrlFromPath( sResourceType, sCurrentFolder, sCommand)

	' Execute the required command.
	
	Select Case sCommand
		Case "GetFolders"
			js_GetFolders sResourceType, sCurrentFolder
		Case "GetFoldersAndFiles"
			js_GetFoldersAndFiles sResourceType, sCurrentFolder
		Case "CreateFolder"
			js_CreateFolder sResourceType, sCurrentFolder
	End Select

	CreateXmlFooter

	Response.End
End Sub

%>
