<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Generar Validacion
    '--------------------------------------------------------------------------
    Dim codigo As String = nvUtiles.obtenerValor("codigo", "0")
    Dim token As String = nvUtiles.obtenerValor("token", "")

    'Armado del criterio
    Dim criterio As String = "<criterio><validate><item validador='" & codigo & "' token='" & token & "'></item></validate></criterio>"

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("criterio", criterio)

    ' Seguir la ejecución en getXML
    Server.Execute("~/fw/servicios/VALIDATE/VALIDATE.aspx")
%>