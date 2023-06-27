<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIIClienteInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar moviminetos psp
    '--------------------------------------------------------------------------

    'Dim cuecod As String = nvUtiles.obtenerValor("cuecod", "0")
    'Dim sistcod As String = nvUtiles.obtenerValor("sistcod", "3")
    'Dim fe_desde As String = nvUtiles.obtenerValor("fe_desde", "")
    'Dim fe_hasta As String = nvUtiles.obtenerValor("fe_hasta", "")
    'Dim pagesize As Integer = nvUtiles.obtenerValor("pagesize", 0)
    'Dim absolutepage As Integer = nvUtiles.obtenerValor("absolutepage", 1)
    Dim accion As String = nvutiles.obtenerValor("accion", "getterror")
    Dim filtroEntrante As String = nvUtiles.obtenerValor("filtroWhere", "")
    filtroEntrante = filtroEntrante.Replace("<criterio><select><filtro>", "")
    filtroEntrante = filtroEntrante.Replace("</filtro></select></criterio>", "")

    Dim filtroWhere As String = ""
    filtroWhere = "<criterio><select><filtro>$filtroEntrante$<clitipdoc type='igual'>" & nvAPP.operador.datos("cli_tipdoc").value & "</clitipdoc><clinrodoc type='igual'>" & nvAPP.operador.datos("cli_nrodoc").value & "</clinrodoc></filtro></select></criterio>"
    filtroWhere = filtroWhere.Replace("$filtroEntrante$", filtroEntrante)

    'If cuecod <> "" Then
    ' filtroWhere += "<cuecod type='igual'>" & cuecod & "</cuecod>"
    '' End If

    'If fe_desde <> "" Then
    'filtroWhere += "<fecreal type='mas'>convert(datetime,'" & fe_desde & "',103)</fecreal>"
    'End If

    'If fe_hasta <> "" Then
    'filtroWhere += "<fecreal type='menor'>dateadd(dd,1,convert(datetime,'" & fe_hasta & "',103))</fecreal>"
    'End If

    'If sistcod <> "" Then
    'filtroWhere += "<sistcod type='igual'>" & sistcod & "</sistcod>"
    'End If


    Dim strFiltro As String = "<criterio><select vista='VOII_movimientos' cn='BD_IBS_ANEXA'><campos>fecreal as fecha, clideno [razon_social], clinrodoc as CUIT,cuecod as [nro_cuenta], accdesc as [desc],descbreve as [cod_trn],descdet as [trn], info_adic as [informacion_adicional], mondesc as [moneda], accimp as importe</campos><filtro></filtro></select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", accion)
    nvUtiles.definirValor("filtroWhere", filtroWhere)
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")

%>