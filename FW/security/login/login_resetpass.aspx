<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<%
    Dim err As New tError
    Dim exc As New Exception()
    Dim accion As String = nvUtiles.obtenerValor("accion", "send_mail")
    Dim inputDataLog As String = ""
    
    If accion = "send_mail" Then
        
        Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
        Dim email As String = nvUtiles.obtenerValor("email", "")
        Dim resetPasswordUrl As String = nvUtiles.obtenerValor("reset_password_url", "")
        err = nvSecurityLogin.sendMail(usuario, email, resetPasswordUrl)
        err.response()
    End If
    
    If accion = "reset_password" Then

        Dim password_reset_code As String = nvUtiles.obtenerValor("password_reset_code", "")
        Dim password As String = nvUtiles.obtenerValor("password", "")
        Dim password_confirm As String = nvUtiles.obtenerValor("password_confirm", "")
        Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
        err = nvSecurityLogin.resetPwd(usuario, password, password_confirm, password_reset_code)
        err.response() 
    End If
    





    

%>