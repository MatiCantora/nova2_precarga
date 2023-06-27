<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar todos los eventos disponibles
    '--------------------------------------------------------------------------
    Dim strFiltro As String = "<criterio><select vista='ids_events'><campos>ids_event_id, ids_event</campos><filtro></filtro><orden></orden></select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>