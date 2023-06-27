<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>

<%
    Dim facebook_id As String = nvUtiles.obtenerValor("facebook_id", "")
    Dim usuario As String = nvUtiles.obtenerValor("usuario", "")  
    Dim err As tError

    If facebook_id <> "" Then
        
        ' validadr facebook login
        Dim access_token As String = nvUtiles.obtenerValor("access_token", "")
        err = nvSecurityLogin.validarFBLogin(facebook_id, access_token)
        err.response()
   
    ElseIf usuario <> "" Then
        
        ' validar login de mail
        Dim password As String = nvUtiles.obtenerValor("password", "")
        err = nvSecurityLogin.validarLogin(usuario, password)
        err.response()
    Else
        
        err = New tError
        err.numError = -1
        err.mensaje = "No se ha especificado usuario o facebook_id"
        err.response()
    End If



    
    
    
    
    

    
    %>
    


