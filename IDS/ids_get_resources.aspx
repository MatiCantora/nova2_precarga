<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar todos los recursos del Cliente
    '--------------------------------------------------------------------------
    Dim ids_cli_id As Integer = Me.operador.ids_cli_id

    ' Armado del filtro de consulta
    Dim strFiltro As String = "<criterio><select vista='verIDS_resources'>" &
                              "<campos>ids_res_id, ids_resource, ids_restype</campos>" &
                              "<filtro><ids_cli_id>" & ids_cli_id & "</ids_cli_id></filtro>" &
                              "<orden></orden>" &
                              "</select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>