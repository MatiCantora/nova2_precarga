<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Enviar sms
    '--------------------------------------------------------------------------
    Dim phone As String = nvUtiles.obtenerValor("phone", "0")
    Dim body As String = nvUtiles.obtenerValor("body", "")
    Dim mode As String = nvUtiles.obtenerValor("mode", "")

    'Armado del criterio
    Dim criterio As String = "<criterio><send mode='" & mode & "'><item type='sms' identificador='" & phone & "'><body><![CDATA[" & body & "]]></body></item></send></criterio>"

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("criterio", criterio)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/servicios/send/send.aspx")
%>