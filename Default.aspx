<%@ Page Language="vb"  %>
<%@ Import namespace="nvFW" %>
<%
    'Identifica si la conexión debe ser SSL o no, y redirecciona en función de si ya hay una aplicación activa o no.
    'Si nvSession.Contents("app_path_rel") es distinto de "" entonces ya hay una aplicación activa y lo direcciona a ella
    'si no, es por  que es el primer acceso y hay que mandarlo al login.
    Dim server_url As String
    Dim nvApp As nvFW.tnvApp = nvFW.nvApp.getInstance()
    
    Dim HTTPS = Request.ServerVariables("HTTPS")
    Dim URL As String
    URL = Request.ServerVariables("URL")
    If nvServer.onlyHTTPS = True And HTTPS.ToLower <> "on" Then
        Response.Redirect(nvApp.server_host_https)
    End If
    
    If HTTPS.ToLower = "on" Then
        server_url = nvApp.server_host_https
    Else
        server_url = nvApp.server_host_http
    End If
    
    'Si ya hay una aplicacion activa ir a esa, sino ir al selector app_frame
    If nvApp.cod_sistema = "" Then
        'Dim loginParam As New nvFW.tnvLoginParam
        'nvSession.Contents("nvLoginParam") = loginParam
        Response.Redirect(server_url & "/FW/nvLogin.aspx")
    Else
        Response.Redirect(server_url & "/" & nvApp.path_rel)
    End If

    
    

%>
