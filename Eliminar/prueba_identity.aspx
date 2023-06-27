<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.Security" %>
<%@ Import Namespace = "System.Security.Principal" %>
<%@ Import Namespace = "System.Runtime.InteropServices" %>
<%
    
                         
    
  
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

   
    </script>

    <script runat=server>
        
      
</script>

<%
    Stop
     
    Dim token As TokenImpersonationLevel
    token = CType(User.Identity, System.Security.Principal.WindowsIdentity).ImpersonationLevel
    Response.Write("Impersonationlevel del usuario actual es : " & token.ToString() & "<br/>")
   
    nvApp.app_cns("primaria").excaslogin = False
    nvApp.app_cns("primaria").SSO = True
    nvApp.app_cns("primaria").WindowsIdentity = nvApp.operador.WindowsIdentity
    
    
    Dim cn As ADODB.Connection = nvFW.nvDBUtiles.DBConectar
    Dim rs As ADODB.Recordset = cn.Execute("select SYSTEM_USER as [SYSTEM_USER] ")
    Dim SYSTEM_USER As String = rs.Fields("SYSTEM_USER").Value
    nvFW.nvDBUtiles.DBCloseRecordset(rs)
    Response.Write("Usuario de DB es : " & SYSTEM_USER & "<br/>")
    
    token = CType(User.Identity, System.Security.Principal.WindowsIdentity).ImpersonationLevel
    Response.Write("Impersonationlevel del usuario actual es : " + token.ToString())
    
    token = CType(User.Identity, System.Security.Principal.WindowsIdentity).GetCurrent().ImpersonationLevel
    Response.Write("Impersonationlevel del usuario actual es : " + token.ToString())
    
    'Stop
    'Dim bytes() As Byte = nvFW.nvSecurity.nvImpersonate.WindowsIdentityToBytes(CType(User.Identity, System.Security.Principal.WindowsIdentity))
    
    'Dim WindowsIdentity2 As System.Security.Principal.WindowsIdentity = nvFW.nvSecurity.nvImpersonate.BytesToWindowsIdentity(bytes)
    'Dim WindowsIdentity3 As System.Security.Principal.WindowsIdentity = New System.Security.Principal.WindowsIdentity(WindowsIdentity2.Token)
    'Dim impersonationContext As System.Security.Principal.WindowsImpersonationContext = WindowsIdentity3.Impersonate()
     
    
    'impersonationContext.Undo()
    
    

    'If nvFW.nvSecurity.nvImpersonate.impersonateValidUser("jmolivera", "redmutual", "phantom99") Then
    '    'Inserte aquí el código que se ejecuta en el contexto de seguridad de un usuario específico.
        
    '    Dim cn As ADODB.Connection = nvFW.nvDBUtiles.DBConectar
    '    Dim rs As ADODB.Recordset = cn.Execute("select SYSTEM_USER as [SYSTEM_USER] ")
    '    Dim SYSTEM_USER As String = rs.Fields("SYSTEM_USER").Value
    '    nvFW.nvDBUtiles.DBCloseRecordset(rs)
        
    '    nvFW.nvSecurity.nvImpersonate.undoImpersonation()
        
    '    cn = nvFW.nvDBUtiles.DBConectar
    '    rs = cn.Execute("select SYSTEM_USER as [SYSTEM_USER] ")
    '    SYSTEM_USER = rs.Fields("SYSTEM_USER").Value
    '    nvFW.nvDBUtiles.DBCloseRecordset(rs)
        
        
    'Else
    '    'Error en la suplantación. Por lo tanto, incluya aquí un mecanismo a prueba de errores.
    'End If

    %>
</head>
<body onload="window_onload()" style=" height:100%; overflow: hidden">
<% 
    'Stop
    'Dim impersonationContext As System.Security.Principal.WindowsImpersonationContext
    'Dim currentWindowsIdentity As System.Security.Principal.WindowsIdentity
    'Response.Write("01 - " & User.Identity.Name)
    'currentWindowsIdentity = CType(User.Identity, System.Security.Principal.WindowsIdentity)
    ' impersonationContext = currentWindowsIdentity.Impersonate()

    'Inserte aquí el código que se ejecuta en el contexto de seguridad del usuario que se autentica.

    'impersonationContext.Undo()
    
    %>

</body>
</html>
