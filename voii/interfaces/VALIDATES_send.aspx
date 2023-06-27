<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Enviar Validacion
    '--------------------------------------------------------------------------
    Dim type As String = nvUtiles.obtenerValor("type", "")
    Dim id As String = nvUtiles.obtenerValor("id", "0")
    Dim cuil As String = nvUtiles.obtenerValor("cuil", "0")
    Dim mode As String = "test"
    'Armado del criterio
    Dim criterio As String = "<criterio><validate mode='" & mode & "'><item type='" & type & "' identificador='" & id & "' cuit='" & cuil & "'><texto><![CDATA[]]></texto></item></validate></criterio>"

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("criterio", criterio)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/servicios/validate/send.aspx")
%>