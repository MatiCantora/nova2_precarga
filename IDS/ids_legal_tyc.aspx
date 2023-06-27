<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Obtener Términos y Condiciones con ID de recurso e ID de evento
    '--------------------------------------------------------------------------
    Dim ids_cli_id As String = Me.operador.ids_cli_id
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")
    Dim ids_event_id As String = nvUtiles.obtenerValor("ids_event_id", "")

    ' Armado del filtro de consulta
    Dim strFiltro As String = "<criterio><select vista='ids_res_config'>" &
                              "<campos>ids_legal_binary, ids_legal_content_type</campos>" &
                              "<filtro>" &
                                "<ids_cli_id>'" & ids_cli_id & "'</ids_cli_id>" &
                                "<ids_res_id>'" & ids_res_id & "'</ids_res_id>" &
                                "<ids_event_id>'" & ids_event_id & "'</ids_event_id>" &
                              "</filtro><orden></orden></select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales (necesarios para el getXML) al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)
    nvUtiles.definirValor("destPublicKey", Me.nvDevice.DevicePublicKey)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>