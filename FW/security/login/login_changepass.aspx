<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>

<%
    Dim err As tError
    Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
    Dim password_actual As String = nvUtiles.obtenerValor("password_actual", "")
    Dim password_nueva As String = nvUtiles.obtenerValor("password_nueva", "")
    
    ' se debe validar el login previamente con la password actual
    err = nvSecurityLogin.validarLogin(usuario, password_actual)
    If err.numError <> 0 Then
        err.response()
    End If
    
    ' cambiar la password
    err = nvSecurityLogin.changePwd(usuario, password_nueva)
    err.response()
%>