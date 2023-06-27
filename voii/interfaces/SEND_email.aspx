<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Enviar Mail
    '--------------------------------------------------------------------------
    Dim [to] As String = nvUtiles.obtenerValor("to", "")
    Dim cc As String = nvUtiles.obtenerValor("cc", "")
    Dim cco As String = nvUtiles.obtenerValor("cco", "")

    Dim body As String = nvUtiles.obtenerValor("body", "")
    Dim subject As String = nvUtiles.obtenerValor("subject", "")
    Dim mode As String = nvUtiles.obtenerValor("mode", "")

    'Armado del criterio
    Dim criterio As String = "<criterio><send mode='" & mode & "'><item type='mail' identificador='" & [to] & "' cc='" & [cc] & "' cco='" & [cco] & "'><subject><![CDATA[" & subject & "]]></subject><body><![CDATA[" & body & "]]></body></item></send></criterio>"

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("criterio", criterio)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/servicios/send/send.aspx")
%>