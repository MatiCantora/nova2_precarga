<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%
    Dim accion As String = obtenerValor("accion", "")
    If accion = "generar_legajo" Then
        Stop
        If Request.Files.Count > 0 Then
            Dim filename As String = Request.Files(0).FileName
            Dim temp_path As String = System.IO.Path.GetTempPath & "\" & Request.Files(0).FileName
            Request.Files(0).SaveAs(temp_path)

            Dim oDocument As New nvFW.tnvLegDocument("archivo1", filename)
            oDocument.load(temp_path)

            Dim oLeg As New nvFW.tnvLegContainer()



            oLeg.documents.Add(0, oDocument)

            oLeg.exportToFile("d:\prueba_legajo\prueba.rm0")

            oLeg.saveFilesToDir("d:\prueba_legajo\", True)



        End If
        Response.Write("OK")
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

    </script>
</head>
<body style="height: 100%; overflow: hidden">
<form name="form1" method="post" target='iframe01' action="prueba_generar_rm0.aspx" enctype="multipart/form-data"  onsubmit="return validateForm()" >
    <input type="hidden" name="accion" value="generar_legajo" />
<table class='tb1'>
    <tr>
        <td>
            <input type="file" name='file01' id="file01" style='width: 100%' />
        </td>
    </tr>
</table>
    
    <table class='tb1'>
    <tr><td><input type="submit" value="Generar legajo" style='font-size: 16px' /></td></tr></table>
    </form>
    <iframe name='iframe01' style='width:100%; height:200px; border: 1px solid blue'></iframe>
</body>
</html>
