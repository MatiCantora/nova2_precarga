<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar maestro de tarjeta
    '--------------------------------------------------------------------------

    ' Armado del filtro de consulta
    Dim strFiltro As String = "<criterio><select vista='[verLINK_soat_tj_maestro]'>" &
"<campos>*</campos>" &
"<filtro></filtro>" &
"<orden>producto desc</orden>" &
"</select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>