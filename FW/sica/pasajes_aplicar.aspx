<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor")
    Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema")
    Dim port As String = nvUtiles.obtenerValor("port", "")

    Dim cod_pasajes As String = nvUtiles.obtenerValor("cod_pasajes")
    Dim err As New tError

    ' chequear permisos 
    ' debe tener el permiso para implementar sistema
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador

    If Not op.tienePermiso("permisos_sica", 8) AndAlso Not op.tienePermiso("permisos_servidor_" & cod_servidor & "_sistema_" & cod_sistema, 4) Then
        err.numError = -1
        err.mensaje = "No tiene permisos para aplicar pasajes al sistema <b>" & cod_sistema & "</b> en este servidor."
        err.response()
        Return
    End If

    Dim app As New nvFW.tnvApp
    app.loadFromDefinition(cod_servidor, cod_sistema, port)
    app.operador = nvFW.nvApp.getInstance().operador

    If (Application.Contents("nvRunningImplementations") Is Nothing) Then
        Application.Contents("nvRunningImplementations") = New Dictionary(Of String, nvFW.tnvApp)
    End If

    Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
    Dim nvRunningImplementations As Dictionary(Of String, nvFW.tnvApp) = Application.Contents("nvRunningImplementations")

    If nvRunningImplementations.ContainsKey(key) Then
        Dim tApp As nvFW.tnvApp = nvRunningImplementations(key)

        If Not tApp Is Nothing AndAlso tApp.sica_implementacion.thread.IsAlive Then
            err.numError = -1
            err.mensaje = "Existe una instalación o pasaje en curso."
            err.response()
        Else
            nvRunningImplementations(key) = app
        End If
    Else
        nvRunningImplementations.Add(key, app)
    End If

    err = nvSICA.Implementation.sistema_pasajes_iniciar(app, cod_pasajes)
    err.response()
%>