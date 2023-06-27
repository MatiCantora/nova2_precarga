<%@ Page Language="vb" AutoEventWireup="false"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%
    Dim UID As String = ""
    Dim PWD As String = ""
    Dim pwd_new01 As String = ""
    Dim msg As String
    Dim bcolor As String

    If Not Request.Form("pwd_new01") Is Nothing Then
        pwd_new01 = Request.Form("pwd_new01")
    End If
    If Not Request.Form("UID") Is Nothing Then
        UID = Request.Form("UID")
    End If
    If Not Request.Form("PWD") Is Nothing Then
        PWD = Request.Form("PWD")
    End If

    msg = "La contraseña se ha cambiado exitosamente"
    bcolor = "blue"
    Try
        Dim oADCh As ADChangePWD = New ADChangePWD(UID, PWD)
        oADCh.changePassword(pwd_new01)
    Catch ex As Exception
        msg = ex.Message
        bcolor = "red"
    End Try


 %>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
</head>
<body>
   <div style="width:600px; margin: auto; text-align:center; border:solid <%= bcolor %> 1px" > <%=msg%></div>
</body>
</html>
