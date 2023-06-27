<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="frmFirma.aspx.vb"   %>
<% 


    Stop
    Dim fUID As String = ""
    Dim UID As String = ""
    Dim PWD As String = ""
    If Not Request.Form("fUID") Is Nothing Then
        fUID = Request.Form("fUID")
    End If
    If Not Request.Form("UID") Is Nothing Then
        UID = Request.Form("UID")
    End If
    If Not Request.Form("PWD") Is Nothing Then
        PWD = Request.Form("PWD")
    End If

    If fUID = "" Then fUID = UID

    Dim oADF As New ADFirma(fUID, UID, PWD)
    Dim firmaHTML = oADF.getFirmaHTML()

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <!--<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />-->
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Firma Institucional</title>
    
</head>
<body>
 <!--<p style="text-align:center">
    <font color='#606060' face='Trebuchet MS, Arial' size='4'> <b>Firma institucional Banco VOII SA</b></font>
    </p>
    <div style= "border: solid blue 1px; text-align:center; width:600px; margin:auto">
    <font face='Trebuchet MS, Arial' size='2'>Agregue la firma que se encuentra a continuación dentro de su cliente de correo electrónico</font>
    </div>
    
   
    <br />
   -->
    
        <%
            Response.Write(firmaHTML)
            %>
</body>
</html>
