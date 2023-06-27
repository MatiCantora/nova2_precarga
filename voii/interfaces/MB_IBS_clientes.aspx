<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar maestro de tarjeta
    '--------------------------------------------------------------------------
    Dim cuil As String = nvUtiles.obtenerValor("cuil", "0")

    Dim strFiltro As String = "<criterio><select vista='Entidades e" &
     " inner join verContacto_telefono t On t.id_tipo = e.nro_entidad And t.nro_contacto_tipo = 99 And t.nro_id_tipo = 1 And t.predeterminado = 1" &
     " inner join verContacto_Email m on m.id_tipo  = e.nro_entidad and m.nro_contacto_tipo = 99  and m.nro_id_tipo = 1 and m.predeterminado = 1'>" &
     "<campos>top 1 tipo_docu as tipdoc,e.nro_docu as nrodoc,e.Razon_social as apellido_nombres,isnull(m.email,'') as email, isnull(t.car_tel,'') as cartel,isnull(t.telefono,'') as numtel</campos>" &
     "<filtro><e.tipo_docu type='igual'>6</e.tipo_docu><e.nro_docu type='igual'>" & cuil & "</e.nro_docu></filtro>" &
     "<orden></orden>" &
     "</select></criterio>"

    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>