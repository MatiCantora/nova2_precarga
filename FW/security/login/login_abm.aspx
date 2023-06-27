<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<%
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador As String = op.operador

    If accion.ToLower = "alta" Then
        
        Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
        Dim err As tError = nvSecurityLogin.AltaUsuario(strXML, nro_operador)
        err.response()
        
    ElseIf accion.ToLower = "baja" Then
        
        Dim cuil As String = nvUtiles.obtenerValor("cuil", "")
        Dim tipo_docu As String = nvUtiles.obtenerValor("tipo_docu", "-1")
        Dim nro_docu As String = nvUtiles.obtenerValor("nro_docu", "-1")
        Dim sexo As String = nvUtiles.obtenerValor("sexo", "")
        Dim email As String = nvUtiles.obtenerValor("email", "")
        Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
        Dim facebook_id As String = nvUtiles.obtenerValor("facebook_id", "")
        Dim err As tError = nvSecurityLogin.BajaUsuario(tipo_docu, nro_docu, sexo, cuil, email, usuario, facebook_id)
        err.response()
      
    ElseIf accion.ToLower = "modificacion" Then
        
    End If
        
    

    
    %>

