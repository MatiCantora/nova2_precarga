<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%
    Dim fileCount As Integer = Request.Files.Count
    If Request.Files.Count > 0 Then
        Response.Write(fileCount & " archivos")
        Response.End()
    End If


 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <% = Me.getHeadInit()%>
    <style type="text/css">
        .hover { border: 1px dashed #0c0 !important}
     </style>
    <script type="text/javascript">
    function validateForm() 
      {
      if ($("file01").value == "")
        {
        alert('No ha seleccionado el archivo a firmar')
        return false
        }
      return true 
      }

   function windows_onload()
     {
     var body = $$("BODY")[0]
     
     //body.observe("dragover", function(e)
     //                     {
     //                     //$("divDebug").innerHTML += "body.ondragover(" + e.dataTransfer.dropEffect + ") <br>"
     //                     var body = $$("BODY")[0]
     //                     if (e.dataTransfer.dropEffect != "copy")
     //                       e.dataTransfer.dropEffect = "none"
     //                     //e.preventDefault()
     //                     return false 
     //                     } )

     //body.ondragover =  function(e)
     //                     {
     //                     if (e.dataTransfer.dropEffect != "copy")
     //                       e.dataTransfer.dropEffect = "none"
     //                     return false 
     //                     } 
     
     //body.observe("drop", function (e) { e.preventDefault(); return false; })
     //body.ondrop = function (e) { e.preventDefault(); return false; };


     var dropContainer = $("holder01")
     debugger
     nvFW.enableDropFile(dropContainer, "hover", function(evt) 
                               {
                               // pretty simple -- but not for IE :(
                               debugger
                               $("file01").files = evt.dataTransfer.files;
                               })

     ////dropContainer.observe("dragover", function (e) 
     ////                              { 
     ////                              //$("divDebug").innerHTML += "dropContainer.ondragover(" + e.dataTransfer.dropEffect + ") <br>"
     ////                              $(this).addClassName('hover)'); 
     ////                              e.dataTransfer.dropEffect = "copy";  
     ////                              e.preventDefault()
     ////                              return false; 
     ////                              })

     //dropContainer.ondragover = function (e) 
     //                              { 
     //                              //$("divDebug").innerHTML += "dropContainer.ondragover(" + e.dataTransfer.dropEffect + ") <br>"
     //                              $(this).addClassName('hover'); 
     //                              e.dataTransfer.dropEffect = "copy";  
     //                              e.preventDefault()
     //                              return false; 
     //                              };

     ////dropContainer.ondragover = function (e) 
     ////                              { 
     ////                              $(this).addClassName('hover)'); 
     ////                              e.dataTransfer.dropEffect = "copy";  
     ////                              return false; 
     ////                              };
     ////dropContainer.observe("dragend", function () { $(this).removeClassName('hover)'); return false; })
     //dropContainer.ondragleave = function () { $(this).removeClassName('hover'); return false; };
     //dropContainer.ondragend = function () { $(this).removeClassName('hover'); return false; };
     
     //dropContainer.observe("drop", function(evt) 
     //                          {
     //                          // pretty simple -- but not for IE :(
     //                          debugger
     //                          $("file01").files = evt.dataTransfer.files;
     //                          evt.preventDefault();
     //                          })
     //dropContainer.ondrop = function(evt) 
     //                          {
     //                          // pretty simple -- but not for IE :(
     //                          debugger
     //                          $(this).removeClassName('hover')
     //                          $("file01").files = evt.dataTransfer.files;
     //                          evt.preventDefault();
     //                          };  
   }

   
   
 

    </script>
</head>
<body style="height: 100%; overflow: hidden" onload="return windows_onload()" >
    <form name="form1" method="post" target='iframe01' action="prueba_dad.aspx" enctype="multipart/form-data" onsubmit="return validateForm()">
        <table class="tb1">
            <tr><td><input id="holder01" style="border:solid gray 1px;" value=" Archivo 01" readonly /> </td><td><input name="file01" id="file01" type="file" /></td></tr>
        </table>

        <table class='tb1'>
            <tr>
                <td>
                    </td>
            </tr>
        </table>
    </form>
    <div id="divDebug" style="border: solid blue 1px; width:100%; height:300px; overflow-y:auto"></div>
    
</body>
</html>
