<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Obtiene todos los Clientes del CORE de CUENTAS (CC) a partir de los 
    ' siguientes valores:
    '   ID de cliente (ids_cli_id)
    '   Tipo Documento (tipo_docu)
    '   Nro Documento (nro_docu)
    '   ID de recurso (ids_res_id)
    '--------------------------------------------------------------------------
    Dim ids_cli_id As Integer = Me.operador.ids_cli_id
    Dim tipo_docu As String = nvUtiles.obtenerValor("tipo_docu", "")
    Dim nro_docu As String = nvUtiles.obtenerValor("nro_docu", "")
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")

    ' Armado del filtro de consulta
    Dim strFiltro As String = "<criterio><select vista='ids_identity i  join ids_identity_resources ir on i.uid = ir.uid'>" &
                "<campos>i.uid, i.nro_docu, i.tipo_docu, i.razon_social</campos>" &
                "<filtro>" &
                    "<ids_cli_id>'" & ids_cli_id & "'</ids_cli_id>" &
                    "<ids_res_id>'" & ids_res_id & "'</ids_res_id>" &
                    "<tipo_docu>'" & tipo_docu & "'</tipo_docu>" &
                    "<nro_docu>'" & nro_docu & "'</nro_docu>" &
                "</filtro><orden></orden></select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales (necesarios para el getXML) al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>