<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII"%>
<script runat="server">
'Public Shared nro_entidad_shared As String = ""
</script>
<%

    ' Parametros desde solicitud GET
    Dim tituloPagina As String = nvFW.nvUtiles.obtenerValor("titulo", "Datos de entidad")

    'Dim tiporel As Integer = nvFW.nvUtiles.obtenerValor("tiporel", 0)
    Dim nro_entidad As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad", 0)
    Dim tipocli As Integer = nvFW.nvUtiles.obtenerValor("tipocli", 0)
    Dim tipdoc As Integer = nvFW.nvUtiles.obtenerValor("tipdoc", 0)
    Dim nrodoc As Long = nvFW.nvUtiles.obtenerValor("nrodoc", 0)
    Dim tiporel As Integer = nvFW.nvUtiles.obtenerValor("tiporel", -1)

    Dim parametro As String = nvFW.nvUtiles.obtenerValor("parametro", "")

    If parametro <> "" Then
        'Edici�n de par�metro 
        Dim err As New tError()
        Dim op = nvFW.nvApp.getInstance.operador

        If Not op.tienePermiso("permisos_entidades", 1) Then
            err.numError = 1
            err.mensaje = "No posee permisos para modificar el par�metro"
            err.debug_src = "voii::cargar_cliente.aspx"
            err.response()
        End If

        Dim param_valor As String = nvFW.nvUtiles.obtenerValor("param_valor", "")
        Dim nro_com_id_tipo As String = nvFW.nvUtiles.obtenerValor("nro_com_id_tipo", "")

        Try

            Dim param As New nvFW.trsParam
            param("tipo_parametro") = ""

            If nro_com_id_tipo = "1" Then param("tipo_parametro") = "ENTIDAD"
            If nro_com_id_tipo = "9" Then param("tipo_parametro") = "PLD"

            param("nro_com_id_tipo") = nro_com_id_tipo
            param("parametro") = parametro
            param("param_valor") = param_valor
            param("nrodoc") = nrodoc
            param("tipdoc") = tipdoc
            param("nro_entidad") = nro_entidad

            err = nvVOIIUtiles.param_def_set(param)

        Catch e As Exception
            err.parse_error_script(e)
            err.numError = -99
            err.mensaje = "No se pudo modificar el par�metro"
            err.debug_src = "voii::cargar_cliente.aspx"
        End Try

        err.response()

    End If

    Me.addPermisoGrupo("permisos_entidades")

    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    If (strXML <> "") Then
        nvFW.nvVOIIUtiles.Entidad_Consolidar(nro_entidad, strXML)
        'nvServer.Events.RaiseEvent("entidad_onSave", "", strXML)
        Dim err As New tError

        'alta historial de busqueda
        Dim op = nvFW.nvApp.getInstance.operador
        Dim strSQL = "INSERT INTO hist_personas (fecha_busqueda,operador,nro_entidad,origen) VALUES (GETDATE()," & op.operador & "," & nro_entidad & ",'ibs')"
        Try
            nvFW.nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
        End Try

        err.params("nro_entidad") = nro_entidad
        err.response()
    End If

    'alta historial de busqueda    
    If nro_entidad > 0 Or strXML = "" Then
        Dim op = nvFW.nvApp.getInstance.operador
        Dim strSQL = ""
        If tiporel < 0 Then
            strSQL = "INSERT INTO hist_personas (fecha_busqueda,operador,nro_entidad,origen) VALUES (GETDATE()," & op.operador & "," & nro_entidad & ",'')"
            Try
                nvFW.nvDBUtiles.DBExecute(strSQL)
            Catch ex As Exception
            End Try
        Else
            Try
                If nro_entidad = 0 Then
                    strSQL = "SELECT nro_entidad FROM entidades WHERE nro_docu =" & nrodoc.ToString & " AND tipo_docu = (SELECT cod_interno FROM nv_codigos_externos WHERE elemento = 'documento' AND sistema_externo = 'ibs' AND cod_externo = " & tipdoc.ToString & ")"
                    Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)
                    If Not rs.EOF Then
                        nro_entidad = rs.Fields("nro_entidad").Value 'guardo el nro_entidad
                    End If
                End If

                If nro_entidad > 0 Then 'si nro_entidad = 0, la entidad no esta cargada en nova
                    strSQL = "INSERT INTO hist_personas (fecha_busqueda,operador,nro_entidad,origen) VALUES (GETDATE()," & op.operador & "," & nro_entidad & ",'ibs')"
                    nvFW.nvDBUtiles.DBExecute(strSQL)
                End If
            Catch ex As Exception
            End Try
        End If
    End If

    If tipdoc > 0 And nrodoc > 0 Or nro_entidad > 0 Then
        Dim op = nvFW.nvApp.getInstance.operador
        If (Not op.tienePermiso("permisos_entidades", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx?No posee permisos para ver las entidades.")


        'Si viene nro_entidad lo buscamos en nova
        If tiporel < 0 Then
            Dim camposNV As String = "nro_entidad, tipocli, tiporel, tipdoc, tipdoc_desc, nrodoc, CUIT_CUIL, DNI, cliape, clinom, clideno, " +
            "fecnac_insc, clisexo, cartel, numtel, razon_social, tipreldesc, domnom, domnro, dompiso, domdepto, codpos, loccoddesc, codprovdesc, " +
            "email, clconddgi, descestciv, tipsocdesc, tipoempdesc, policaexpuesto, apenomConyuge, nacionalidad, '' AS sectorfindesc, '' AS profdesc, impgandesc, '' AS perconnom, '' AS clasidesc, '' AS desctipcar, " +
            "'' as ofitipdoc, ofinrodoc, '' as ofirazon_social"
            Me.contents("entXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades_compatibilidad_ibs'><campos>" + camposNV + "</campos><filtro><nro_entidad type='igual'>'" + nro_entidad.ToString + "'</nro_entidad></filtro></select></criterio>")
        Else
            Dim camposIBS As String = "tipocli, tiporel, tipdoc, tipdoc_desc, nrodoc, CUIT_CUIL, DNI, cliape, clinom, clideno, " +
"fecnac_insc, clisexo, cartel, numtel, razon_social, tipreldesc, domnom, domnro, dompiso, domdepto, codpos, loccoddesc, codprovdesc, " +
"email, clconddgi, descestciv, tipsocdesc, tipoempdesc, policaexpuesto, sectorfindesc, profdesc, impgandesc, perconnom, clasidesc, desctipcar, " +
"ofitipdoc_desc, ofitipdoc, ofinrodoc, ofirazon_social"
            Me.contents("entXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>" + camposIBS + "</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro></select></criterio>")

        End If

        Me.contents("filtro_vinculos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidad_vinculos' cn='BD_IBS_ANEXA'><campos>vinc_razon_social, vinc_tipocli, " +
                                                                 "vinc_tipdoc, vinc_tipdoc_desc, vinc_nrodoc, tipvinclicod, " +
                                                                 "cliclivincod, vincliclinom, tipvinclidesc, clivinfecalta, clivinfecven, vinc_tiporel</campos>" +
                                                                 "<filtro><tipdoc type='igual'>" & tipdoc.ToString & "</tipdoc><nrodoc type='igual'>" & nrodoc.ToString & "</nrodoc></filtro>" +
                                                                 "<orden>vinc_razon_social ASC</orden></select></criterio>")

        Me.contents("filtroEntidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
        Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_interno, cod_externo, desc_externo</campos><filtro><elemento type='igual'>'documento'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden></orden></select></criterio>")
        Me.contents("filtro_nomenclador_grupo_vinculo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_interno, cod_externo, desc_externo</campos><filtro><elemento type='igual'>'grupo_vinculo'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden></orden></select></criterio>")
        Me.contents("filtro_nomenclador_tipo_vinculo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_interno, cod_externo, desc_externo</campos><filtro><elemento type='igual'>'tipo_vinculo'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden></orden></select></criterio>")

        Me.contents("filtro_archivo_leg_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivo_leg_cab'><campos>nro_def_archivo, id_tipo</campos><filtro><nro_archivo_id_tipo type='igual'>2</nro_archivo_id_tipo></filtro><orden></orden></select></criterio>")
        Me.contents("filtro_archivos_def_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_cab'><campos>nro_def_archivo, def_archivo</campos><filtro></filtro><orden></orden></select></criterio>")

        Me.contents("entParamsXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='verEnt_params'><campos>orden, etiqueta, nro_entidad, param, valor, campo_def, tipo_dato, visible, editable, valor_defecto, permiso_ver, permiso_edicion</campos><orden>orden</orden><filtro></filtro></select></criterio>")
        Me.contents("entParamsXMLPLD") = nvXMLSQL.encXMLSQL("<criterio><select vista='verEnt_paramsPLD'><campos>orden, etiqueta, nro_entidad, param, valor, campo_def, tipo_dato, visible, editable, valor_defecto, permiso_ver, permiso_edicion</campos><orden>orden</orden><filtro></filtro></select></criterio>")

        Me.contents("filtro_limite_operativo") = nvXMLSQL.encXMLSQL("<criterio><select vista='TPLAV_CLIENTE' cn='UNIDATO'><campos>LIMITE_OPERATIVO, NUMERO_DOC</campos><orden></orden><filtro><SQL type='sql'>cast(NUMERO_DOC as bigint) = " & nrodoc & "</SQL></filtro></select></criterio>")

        Me.contents("filtro_fecha_alta") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTPLAV_CLIENTE_PEP_fecha' cn='UNIDATO'><campos>FECHA_ALTA, NUMERO_DOC</campos><orden></orden><filtro><SQL type='sql'>cast(NUMERO_DOC as bigint) = " & nrodoc & "</SQL></filtro></select></criterio>")

        Me.contents("filtro_fecha_baja") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTPLAV_CLIENTE_PEP_fecha' cn='UNIDATO'><campos>FECHA_BAJA, NUMERO_DOC</campos><orden></orden><filtro><SQL type='sql'>cast(NUMERO_DOC as bigint) = " & nrodoc & "</SQL></filtro></select></criterio>")

        Me.contents("filtro_pep_tipo") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTPLAV_CLIENTE_PEP' cn='UNIDATO'><campos>ID_TIPO_PEP, TIPO_PEP, NUMERO_DOC</campos><orden></orden><filtro><SQL type='sql'>cast(NUMERO_DOC as bigint) = " & nrodoc & "</SQL></filtro></select></criterio>")

        Me.contents("filtro_histotico_com") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ent_param_valor_log'><campos>*</campos><filtro><nro_entidad type='igual'>" & nro_entidad & "</nro_entidad></filtro><orden>momento</orden></select></criterio>")

        Me.contents("filtro_histotico_pld") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ent_pld_param_valor_log'><campos>*</campos><filtro><nro_entidad type='igual'>" & nro_entidad & "</nro_entidad></filtro><orden>momento</orden></select></criterio>")

        Me.contents("filtro_fatca") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidad_clientes' cn='BD_IBS_ANEXA'><campos>nrodoc, estfatca</campos><orden></orden><filtro><SQL type='sql'>cast(nrodoc as bigint) = " & nrodoc & "</SQL></filtro></select></criterio>")

        Me.contents("filtro_cod_actividad") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tcl_Cliente_Actividad c inner join Banksys..tcl_act_economica e on e.actcod = c.actcod and e.tipcod = c.tipcod and e.tipcod= 8' cn='BD_IBS_ANEXA'><campos>e.codactbcra, actprim</campos><orden></orden><filtro><SQL type='sql'>cast(c.nrodoc as bigint) = " & nrodoc & " </SQL></filtro></select></criterio>")

        Me.contents("filtro_cod_producto") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_cuentas' cn='BD_IBS_ANEXA'><campos>distinct prodcod</campos><orden></orden><filtro><SQL type='sql'>cast(nrodoc as bigint) = " & nrodoc & " and cast(tipdoc as int)= " & tipdoc & "</SQL></filtro></select></criterio>")

        Me.contents("filtro_cod_actividad_pizarra") = nvXMLSQL.encXMLSQL("<criterio><select top='1' vista='calc_pizarra_det d left outer join calc_pizarra_det d1 on d1.nro_calc_pizarra = 4 and d.dato1_desde = d1.dato1_desde'><campos>d.dato1_desde as [codactbcra], max(isnull(d1.pizarra_valor_2,0)) as puntaje</campos><orden></orden><filtro><SQL type='sql'>d.nro_calc_pizarra = 3</SQL></filtro><grupo>d.dato1_desde</grupo><orden>puntaje</orden></select></criterio>")

        Me.contents("filtro_cod_producto_pizarra") = nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_det d'><campos>case when sum(case when not d.dato1_desde is null then 1 else 0 end) > sum(case when d.dato1_desde is null then 1 else 0 end) then 0 else 1 end as presenciales</campos><orden></orden><filtro><SQL type='sql'>d.nro_calc_pizarra = 243</SQL></filtro><grupo></grupo><orden></orden></select></criterio>")

        Me.contents("filtro_presencial_sol") = nvXMLSQL.encXMLSQL("<criterio><select top='1' vista='verSol_params p inner join sol_solicitudes s on p.nro_sol = s.nro_sol'><campos>top 1 0 as presenciales</campos><orden></orden><filtro><SQL type='sql'>param = 'IBS_cliente_nuevo' and p.valor = 'SI' and s.cuil = " & nrodoc & "</SQL></filtro><grupo></grupo><orden></orden></select></criterio>")



        'Me.contents("filtroContactoDomicilio") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos' cn='BD_IBS_ANEXA'>" +
        '                        "<campos>'VER' as modo, 'Personal' as desc_contacto_tipo, '' as fecha_estado" +
        '                        ", domnom as calle, domnro as numero, dompiso as piso, domdepto as depto, '' as resto, codpos as postal_real, loccoddesc as localidad, codprovdesc as provincia, '' as cpa" +
        '                        "</campos><filtro><sql type='sql'>domnom IS NOT NULL AND domnro IS NOT NULL</sql><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")
        'Me.contents("filtroContactoTelefono") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos' cn='BD_IBS_ANEXA'>" +
        '                        "<campos>'VER' as modo, 'Personal' as desc_contacto_tipo, '' as fecha_estado" +
        '                        ", cartel as car_tel, numtel as telefono" +
        '                        "</campos><filtro><sql type='sql'>cartel IS NOT NULL AND numtel IS NOT NULL</sql><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")
        'Me.contents("filtroContactoEmail") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos' cn='BD_IBS_ANEXA'>" +
        '                        "<campos>'VER' as modo, 'Personal' as desc_contacto_tipo, '' as fecha_estado" +
        '                        ", email, '' as observacion" +
        '                        "</campos><filtro><sql type='sql'>email IS NOT NULL</sql><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")

        Me.contents("filtroContactoGenerico") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos_Generica' cn='BD_IBS_ANEXA'><campos>*</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")

        Me.contents("nro_entidad") = nro_entidad
        Me.contents("tipdoc") = tipdoc
        Me.contents("nrodoc") = nrodoc

        Me.contents("today") = DateTime.Now

        Me.contents("cda") = nvUtiles.getParametroValor("nosis_cda_default")
    End If

    Me.addPermisoGrupo("permisos_pld")


#End ExternalSource
    Dim __o As Object

#ExternalSource("C:\nova2\voii\cargar_cliente.aspx",3)
    __o =  tituloPagina

#End ExternalSource

#ExternalSource("C:\nova2\voii\cargar_cliente.aspx",4)
    __o =  Me.getHeadInit()%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title><% = tituloPagina %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    <style type="text/css">
        
        .param_editable{
            position:relative;
            cursor:pointer;
            padding-right: 16px;
        }
        .param_editable{
            background-image: url(../../fw/image/icons/editar.png);
            background-size: 16px;
            background-repeat: no-repeat;
            background-position: right center;
        }

        .tiporel-1, /*Prospecto*/
        .tiporel1,  /*Cliente Potencial (CCL)*/
        .tiporel2,  /*Cliente en Tramite*/
        .tiporel6,  /*Cliente de Alta Reducida*/
        .tiporel7,  /*Cliente Normal*/
        .tiporel8,  /*Cliente Pend. de Autorizaci�n*/
        .tiporel10, /*Vuelco Sin Cuentas*/
        .tiporel11, /*Alta Masiva*/
        .tiporel12, /*Vuelco Con Cuenta*/
        .tiporel13  /*Firmantes Cust Val*/
        {
        /*Amarillo*/
        color: #a3a21b;background-color: #ffff9e !important;
        }

        .tiporel3 /*Cliente Activo (CCL)*/
        {
        /*Verde*/
        color: #270;background-color: #DFF2BF !important;
        }

        .tiporel4,  /*Cliente Inactivo*/
        .tiporel5,  /*Cliente Suspendido*/
        .tiporel9 /*Cliente Rechazado*/
        {
        /*Rojo*/
        color: #D8000C;background-color: #FFBABA !important;
        }

    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/nosis.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        // Objeto frame creado para una mejor organizacion y uso de los datos
        var frame = {
            'comentario': { 'cargado': false, 'elemento': null, 'content': null },
            'operacion': { 'cargado': false, 'elemento': null, 'content': null },
            'vinculo': { 'cargado': false, 'elemento': null, 'content': null },
            'archivo': { 'cargado': false, 'elemento': null, 'content': null },
            'prestamo': { 'cargado': false, 'elemento': null, 'content': null },
            'solicitud': { 'cargado': false, 'elemento': null, 'content': null },
            'contacto': { 'cargado': false, 'elemento': null, 'content': null },
            'pld': { 'cargado': false, 'elemento': null, 'content': null }
        }
        var _cuit_cuil, _tiporel, _nro_entidad, _nro_com_id_tipo, _razon_social, _sexo;
        var _params;
        var _nro_def_archivo, _def_archivo

        var params_def = new tParam_def()
        var params_defPLD = new tParam_def()
        var _params = {}

        var _nrodoc = nvFW.pageContents.nrodoc
        var _tipdoc = nvFW.pageContents.tipdoc

        function window_onload()
        {
            // Cargar los frames en el objeto 'frame'
            frame.comentario.elemento = $('frame_comentario')
            frame.comentario.content = $('content_comentario')
            frame.operacion.elemento = $('frame_operacion')
            frame.operacion.content = $('content_operacion')
            frame.vinculo.elemento = $('frame_vinculo')
            frame.vinculo.content = $('content_vinculo')
            frame.archivo.elemento = $('frame_archivo')
            frame.archivo.content = $('content_archivo')
            frame.prestamo.elemento = $('frame_prestamo')
            frame.prestamo.content = $('content_prestamo')
            frame.solicitud.elemento = $('frame_solicitud')
            frame.solicitud.content = $('content_solicitud')
            frame.contacto.elemento = $('frame_contacto')
            frame.contacto.content = $('content_contacto')
            frame.pld.elemento = $('frame_pld')
            frame.pld.content = $('content_pld')

            if (nvFW.pageContents.entXML) {
                var rs = new tRS()
                rs.async = true
                rs.onComplete = function (rs) {
                    if (!rs.eof()) {
                        _cuit_cuil = rs.getdata("CUIT_CUIL");
                        _tiporel = rs.getdata("tiporel");
                        _nro_entidad = undefined;
                        _razon_social = rs.getdata("razon_social");
                        _sexo = rs.getdata("clisexo");

                        $("cuit_cuil").update(_cuit_cuil)
                        if ($("dni"))
                            $("dni").update(rs.getdata("DNI"))
                        if ($("cliape"))
                            $("cliape").update(rs.getdata("cliape"))
                        if ($("clinom"))
                            $("clinom").update(rs.getdata("clinom"))
                        if ($("clisexo")) {
                            var clisexo = rs.getdata("clisexo")
                            if (clisexo == 'M')
                                $("clisexo").update('Masculino')
                            else if (clisexo == 'F')
                                $("clisexo").update('Femenino')
                        }
                        
                        if ($("tipreldesc")) {
                            $("tipreldesc").update(rs.getdata("tipreldesc")).addClassName("tiporel" + rs.getdata("tiporel"))
                        }
                            
                        if ($("descestciv"))
                            $("descestciv").update(rs.getdata("descestciv"))
                        if ($("clconddgi"))
                            $("clconddgi").update(rs.getdata("clconddgi"))

                        if ($("pep"))
                            $("pep").update(rs.getdata("policaexpuesto") == 1 ? 'Si' : 'No')

                        var fecnac_insc = rs.getdata("fecnac_insc")
                        if ($("fecnac_insc") && fecnac_insc) {
                            var date = parseFecha(fecnac_insc)
                            $("fecnac_insc").update(FechaToSTR(date))
                            if ($("age"))
                                $("age").update(_calculateAge(date))
                        }

                        if ($("razon_social"))
                            $("razon_social").update(rs.getdata("razon_social"))
                        if ($("tipoempdesc"))
                            $("tipoempdesc").update(rs.getdata("tipoempdesc"))
                        if ($("tipsocdesc"))
                            $("tipsocdesc").update(rs.getdata("tipsocdesc"))
                        if ($("tipreldesc"))
                            $("tipreldesc").update(rs.getdata("tipreldesc"))
                        if ($("clideno"))
                            $("clideno").update(rs.getdata("clideno"))

                        setTelefono(rs.getdata("cartel"), rs.getdata("numtel"));
                        setEmail(rs.getdata("email"));
                        var descLocalidad = rs.getdata("loccoddesc")
                        if (descLocalidad && rs.getdata("codprovdesc"))
                            descLocalidad += " - " + rs.getdata("codprovdesc")
                        setDomicilio(rs.getdata("domnom"), rs.getdata("domnro"), rs.getdata("dompiso"), rs.getdata("domdepto"), undefined, rs.getdata("codpos"), descLocalidad ? descLocalidad : "");
                        
                        if ($("sectorfindesc"))
                            $("sectorfindesc").update(rs.getdata("sectorfindesc"))
                        
                        if ($("apenomConyuge"))
                            $("apenomConyuge").update(rs.getdata("apenomConyuge"))
                        if ($("nacionalidad"))
                            $("nacionalidad").update(rs.getdata("nacionalidad"))

                        //Informaci�n complementaria del cliente en la vista de comentarios
                        $("infoDiv").hide();
                        $('infoCliente').innerHTML = "";
                        var infoComplementaria = "";

                        var clasidesc = rs.getdata("clasidesc")
                        if (clasidesc)
                            infoComplementaria += '<tr><td class="Tit2" width="15%" nowrap >Clasificaci�n:</td ><td class="Tit4" >' + clasidesc + '</td></tr>';

                        var profdesc = rs.getdata("profdesc")
                        if (profdesc)
                            infoComplementaria += '<tr><td class="Tit2" width="15%" nowrap >Profesi�n:</td ><td class="Tit4" >' + profdesc + '</td></tr >';

                        var impgandesc = rs.getdata("impgandesc")
                        if (impgandesc)
                            infoComplementaria += '<tr><td class="Tit2" width="15%" nowrap >Imp. Ganancias:</td ><td class="Tit4" >' + impgandesc + '</td></tr>';

                        var perconnom = rs.getdata("perconnom")
                        if (perconnom)
                            infoComplementaria +='<tr><td class="Tit2" width="15%" nowrap >Perfil de Consumo:</td ><td class="Tit4" >' + perconnom + '</td></tr>';

                        var desctipcar = rs.getdata("desctipcar")
                        if (desctipcar)
                            infoComplementaria += '<tr><td class="Tit2" width="15%" nowrap >Tipo de Cartera:</td ><td class="Tit4" >' + desctipcar + '</td></tr>';
                        
                        if (infoComplementaria != "") {
                            $("infoDiv").show();
                            $('infoCliente').insert(infoComplementaria);
                        }
                        
                        if (nvFW.pageContents.nro_entidad == 0) {
                            //Viene de IBS
                            //Si no est� en Nova, lo creamos
                            //Si ya est� en Nova y no esta sincronizado a IBS obtenemos el nro de entidad
                            //En ambos casos seteo el _nro_entidad

                            //Obtenemos el tipdoc correspondiente a Nova
                            var tipo_docu_nv
                            var rsTDoc = new tRS();
                            rsTDoc.open(nvFW.pageContents.filtro_nomenclador_documento, "", "<criterio><select><filtro><cod_externo type='igual'>" + rs.getdata("tipdoc") + "</cod_externo></filtro></select></criterio>", "", "")
                            if (rsTDoc.recordcount >= 1) {
                                tipo_docu_nv = rsTDoc.getdata('cod_interno')
                            }

                            var rsEnv = new tRS();
                            //Verifica existencia en Nova
                            rsEnv.open(nvFW.pageContents.filtroEntidades, "", "<criterio><select><filtro><tipo_docu type='igual'>" + tipo_docu_nv + "</tipo_docu><nro_docu type='igual'>" + rs.getdata("nrodoc") + "</nro_docu></filtro></select></criterio>", "", "")

                            if (rsEnv.recordcount == 0) {
                                guardarEntidad(rs, tipo_docu_nv);
                            }
                            //else { // recupero el nro_entidad cuando guardo el historial
                            //    _nro_entidad = rsEnv.getdata("nro_entidad")
                            //}
                        
                        }
                        //FIN - guardar entidad en nova

                        mostrarComentarios();

                        // DEFINICION DE ARCHIVO //
                        if (_nro_def_archivo == undefined) {
                            cargarDefArchivo()
                        }
                        if (_def_archivo == undefined)
                            $("menuItem_divMenu_0").childElements()[1].innerText = " Sin definici�n de legajos "
                        nvNosis.callback = cargar_NOSIS

                        $$('#verClienteSelf')[0].onclick = function (event) { verEntidad(event, nvFW.pageContents.nro_entidad, rs.getdata("tipdoc"), rs.getdata("nrodoc"), rs.getdata("tipocli"), rs.getdata("razon_social"), rs.getdata("tiporel")); };
                    }
                    nvFW.bloqueo_desactivar(null, 'bloq_datos')
                }
                rs.onError = function (rs) {
                    
                }
                rs.open({ filtroXML: nvFW.pageContents.entXML });

                //Men� principal
                if (typeof(pMenu) == "undefined") {
                    pMenu = new tMenu('divMenuPrincipal', 'pMenu');
                    Menus["pMenu"] = pMenu
                    Menus["pMenu"].alineacion = 'centro';
                    Menus["pMenu"].estilo = 'A';
                    Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Entidad [<% = nrodoc %>]</Desc></MenuItem>")
                    if (nvFW.pageContents.nro_entidad > 0) {
                        var tienePermiso = false
                        tienePermiso = nvFW.tienePermiso('permisos_entidades', 1)
                        if (tienePermiso == true) {
                            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editarEntidad()</Codigo></Ejecutar></Acciones></MenuItem>")

                            pMenu.loadImage("editar", "/FW/image/icons/editar.png");
                        }
                    }
                    pMenu.MostrarMenu();
                }
                

                window_onresize()
                
            }
            
        }


        function window_onresize()
        {
            try {
                var dif                = Prototype.isIE ? 5 : 0
                var body_h             = $$('body')[0].getHeight()
                var datos_cliente_h = $('datos_cliente').getHeight()
                var menu_h             = $('divMenu').getHeight()
                var altura             = body_h - datos_cliente_h - menu_h - dif + 'px'

                for (var item in frame) {
                    frame[item].content.style.height = altura
                }
            }
            catch(e) {}
        }

        function _calculateAge(birthday) {
            var ageDifMs = nvFW.pageContents.today - birthday.getTime();
            var ageDate = new Date(ageDifMs);
            return Math.abs(ageDate.getUTCFullYear() - 1970);
        }


        function hideFrames()
        {
            for (var item in frame) {
                frame[item].content.hide()
            }
        }

        var vinculosExternos
        function mostrarVinculos() {
            if (!frame.vinculo.cargado) {

                var rsVincExt = new tRS();
                rsVincExt.open({ filtroXML: nvFW.pageContents.filtro_vinculos });
                
                vinculosExternos = [];
                while (!rsVincExt.eof()) {
                    var rsTDoc = new tRS();
                    rsTDoc.open(nvFW.pageContents.filtro_nomenclador_documento, "", "<criterio><select><filtro><cod_externo type='igual'>" + rsVincExt.getdata("vinc_tipdoc") + "</cod_externo></filtro></select></criterio>", "", "")
                    var vinc_tipdoc = rsTDoc.getdata("cod_interno", "")
                    
                    var rsGV = new tRS();
                    rsGV.open(nvFW.pageContents.filtro_nomenclador_grupo_vinculo, "", "<criterio><select><filtro><cod_externo type='igual'>" + rsVincExt.getdata("tipvinclicod") + "</cod_externo></filtro></select></criterio>", "", "")
                    var grupo_vinculo = rsGV.getdata("cod_interno", "")
                    
                    var rsTV = new tRS();
                    rsTV.open(nvFW.pageContents.filtro_nomenclador_tipo_vinculo, "", "<criterio><select><filtro><cod_externo type='igual'>" + rsVincExt.getdata("cliclivincod") + "</cod_externo></filtro></select></criterio>", "", "")
                    var tipo_vinculo = rsTV.getdata("cod_interno", "")
                    
                    vinculosExternos.push({
                        razon_social_vinc: rsVincExt.getdata("vinc_razon_social", ""),
                        vinc_tipocli: rsVincExt.getdata("vinc_tipocli", ""),
                        //nro_entidad_vinc: ,
                        vinc_grupo: rsVincExt.getdata("tipvinclidesc", ""),
                        nro_vinc_grupo: grupo_vinculo,
                        vinc_tipo: rsVincExt.getdata("vincliclinom", ""),
                        nro_vinc_tipo: tipo_vinculo,
                        tipo_docu_vinc: vinc_tipdoc,
                        documento_vinc: rsVincExt.getdata("vinc_tipdoc_desc", ""),
                        nro_docu_vinc: rsVincExt.getdata("vinc_nrodoc", ""),
                        vinc_desde: rsVincExt.getdata("clivinfecalta", ""),
                        vinc_hasta: rsVincExt.getdata("clivinfecven", ""),
                        sistema: "IBS",
                        vinc_tiporel: rsVincExt.getdata("vinc_tiporel", "")
                    });

                    rsVincExt.movenext()
                }

                
                var url = '/FW/entidades/vinculos/ent_vinculos_listar.aspx?nro_entidad=' + (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad)
                url += "&entidad_consultar=/voii/entidad_cons_consultar.aspx"
                frame.vinculo.elemento.src = url
                frame.vinculo.cargado = true
            }

            hideFrames()
            frame.vinculo.content.show()
        }

        var options_params = {
            width: 600,
            height: 400,
            maximizable: false,
            minimizable: false,
            title: "<b>Editar Par�metros</b>"
        }

        function mostrarComentarios() {
            _nro_com_id_tipo = 1
            //if (!frame.comentario.cargado) {
                var entidad = (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad)
            frame.comentario.elemento.src = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=' + _nro_com_id_tipo + '&nro_com_grupo=1&collapsed_fck=1&do_zoom=0&id_tipo=' + entidad + '&nro_entidad=' + entidad
                frame.comentario.cargado = true
            //}

            hideFrames()
            frame.comentario.content.show()

            $('paramsDivPLD').show()
            _params = params_def.add(nvFW.pageContents.entParamsXML, "<criterio><select><filtro><nro_entidad type='igual'>" + (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad) + "</nro_entidad></filtro></select></criterio>", 'paramsDivCom', callback_param_onSave, nvFW.pageContents.filtro_histotico_com, options_params)
        }


        function obtener_fatca(param_nombre, campo_def, td_campo_def, param_valor, async) {
            var fatca
            var rs_fatca = new tRS();

            if (async) {
                rs_fatca.async = true;

                nvFW.bloqueo_activar(td_campo_def, 'bloq_oc_' + param_nombre, null);
                $('divBloq_msg_bloq_oc_' + param_nombre).className = ""

                rs_fatca.onError = function () {
                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                    alert('Error al cargar los par�metros.')
                }

                rs_fatca.onComplete = function () {
                    if (!rs_fatca.eof())
                        fatca = rs_fatca.getdata("estfatca")

                    if (fatca) {
                        campos_defs.set_value(campo_def, fatca)
                        $(param_nombre).value = $(campo_def + "_desc").value
                    }
                    else 
                        $(param_nombre).value = ""

                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                }

                rs_fatca.open({ filtroXML: nvFW.pageContents.filtro_fatca });
            }
            else {
                rs_fatca.async = false;

                rs_fatca.open({ filtroXML: nvFW.pageContents.filtro_fatca });

                if (!rs_fatca.eof()) {
                    fatca = rs_fatca.getdata("estfatca")
                }
                else
                    fatca = ""

                return fatca
            }
        }
        function obtener_cod_actividad_riesgo(param_nombre, campo_def, td_campo_def, param_valor, async) {
            var lista_cod_actividad = ""

            var rs_cod_actividad_riesgo = new tRS();

            if (async) {
                rs_cod_actividad_riesgo.async = true;

                nvFW.bloqueo_activar(td_campo_def, 'bloq_oc_' + param_nombre, null);
                $('divBloq_msg_bloq_oc_' + param_nombre).className = ""

                rs_cod_actividad_riesgo.onError = function () {
                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                    alert('Error al cargar los par�metros.')
                }

                rs_cod_actividad_riesgo.onComplete = function () {

                    while (!rs_cod_actividad_riesgo.eof()) {
                        lista_cod_actividad += rs_cod_actividad_riesgo.getdata("codactbcra") + ","
                        rs_cod_actividad_riesgo.movenext()
                    }

                    lista_cod_actividad = lista_cod_actividad.substring(0, lista_cod_actividad.length - 1)

                    var descripcion = "", cod_act = obtener_codigo_mayor_puntaje(lista_cod_actividad)

                    campos_defs.set_value(campo_def, cod_act)
                    $(param_nombre).value = $(campo_def + "_desc").value

                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                }

                rs_cod_actividad_riesgo.open({ filtroXML: nvFW.pageContents.filtro_cod_actividad });
            }
            else {
                rs_cod_actividad_riesgo.async = false;

                rs_cod_actividad_riesgo.open({ filtroXML: nvFW.pageContents.filtro_cod_actividad });

                while (!rs_cod_actividad_riesgo.eof()) {
                    lista_cod_actividad += rs_cod_actividad_riesgo.getdata("codactbcra") + ","
                    rs_cod_actividad_riesgo.movenext()
                }

                lista_cod_actividad = lista_cod_actividad.substring(0, lista_cod_actividad.length - 1)

                var descripcion = "", cod_act = obtener_codigo_mayor_puntaje(lista_cod_actividad)

                return cod_act
            }
        }


        function obtener_codigo_mayor_puntaje(lista_cod_actividad) {
            var cod_actividad = ""

            var rs_pizarra = new tRS();
            rs_pizarra.open(nvFW.pageContents.filtro_cod_actividad_pizarra, "", "<criterio><select><filtro><d.dato1_desde type='in'>" + lista_cod_actividad + "</d.dato1_desde></filtro></select></criterio>", "", "")
            if (rs_pizarra.recordcount >= 1) {
                cod_actividad = rs_pizarra.getdata("codactbcra")
            }
            
            return cod_actividad
		}
      
        function obtener_tipo_vinculacion(param_nombre, campo_def, td_campo_def, param_valor, async) {
            var lista = ""

            var rs_cod_producto = new tRS();

            if (async) {
                rs_cod_producto.async = true;

                nvFW.bloqueo_activar(td_campo_def, 'bloq_oc_' + param_nombre, null);
                $('divBloq_msg_bloq_oc_' + param_nombre).className = ""

                rs_cod_producto.onError = function () {
                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                    alert('Error al cargar los par�metros.')
                }

                rs_cod_producto.onComplete = function () {
                    while (!rs_cod_producto.eof()) {
                        lista += rs_cod_producto.getdata("prodcod") + ","

                        rs_cod_producto.movenext()
                    }

                    lista = lista.substring(0, lista.length - 1)

                    var descripcion = "", cod_prod = obtener_es_presencial(lista)

                    //campos_defs.set_value(campo_def, cod_prod)
                    $(param_nombre).value = cod_prod

                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                }

                rs_cod_producto.open({ filtroXML: nvFW.pageContents.filtro_cod_producto });
            }
            else {
                rs_cod_producto.async = false;

                rs_cod_producto.open({ filtroXML: nvFW.pageContents.filtro_cod_producto });

                while (!rs_cod_producto.eof()) {
                    lista += rs_cod_producto.getdata("prodcod") + ","

                    rs_cod_producto.movenext()
                }

                lista = lista.substring(0, lista.length - 1)

                var cod_prod = obtener_codigo_mayor_puntaje(lista)

                return cod_prod
            }
        }


        function obtener_es_presencial(lista) {
            var presencial = "1"

            var rs_pizarra = new tRS();
            rs_pizarra.open(nvFW.pageContents.filtro_cod_producto_pizarra, "", "<criterio><select><filtro><d.dato1_desde type='in'>" + lista + "</d.dato1_desde></filtro></select></criterio>", "", "")
            if (rs_pizarra.recordcount >= 1) {
                presencial = rs_pizarra.getdata("presenciales")
            }

            var rs_presencial_sol = new tRS();
            rs_presencial_sol.open(nvFW.pageContents.filtro_presencial_sol, "", "", "", "")
            if (rs_presencial_sol.recordcount >= 1) {
                presencial = rs_presencial_sol.getdata("presenciales")
            }
            
            return presencial == "1" ? "Presencial" : "A Distancia"
        }
        function obtener_param_pld(param_nombre, campo_def, td_campo_def, param_valor, async) {
            var filtro_pld_param = "", pld_param = ""

            if (param_nombre == "perfil_operativo") {
                filtro_pld_param = nvFW.pageContents.filtro_limite_operativo
            }
            else if (param_nombre == "pep_fecha_alta") {
                filtro_pld_param = nvFW.pageContents.filtro_fecha_alta
            }
            else if (param_nombre == "pep_fecha_baja") {
                filtro_pld_param = nvFW.pageContents.filtro_fecha_baja
            }
            else if (param_nombre == "pep_tipo") {
                filtro_pld_param = nvFW.pageContents.filtro_pep_tipo
            }

            var rsUnidato = new tRS();

            if (async) {
                rsUnidato.async = true;

                nvFW.bloqueo_activar(td_campo_def, 'bloq_oc_' + param_nombre, null);
                $('divBloq_msg_bloq_oc_' + param_nombre).className = ""
            
                rsUnidato.onError = function () {
                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                    alert('Error al cargar los par�metros.')
                }

                rsUnidato.onComplete = function () {
                    pld_param = obtener_valor_unidato(param_nombre, rsUnidato)

                    var descripcion = pld_param

                    if (descripcion == "" && param_valor != "")
                        descripcion = param_valor

                    if (campo_def) {
                        campos_defs.set_value(campo_def, descripcion)
                        $(param_nombre).value = $(campo_def + "_desc").value
                    }
                    else
                        $(param_nombre).value = descripcion


                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                }

                rsUnidato.open({ filtroXML: filtro_pld_param });

            }
            else {
                rsUnidato.async = false;
                rsUnidato.open({ filtroXML: filtro_pld_param });

                pld_param = obtener_valor_unidato(param_nombre, rsUnidato)

                return pld_param
            }
        }


        function obtener_valor_unidato(param_nombre, rs) {
            var pld_param = ""

            if (!rs.eof()) {
                if (param_nombre == "perfil_operativo") {
                    pld_param = rs.getdata('LIMITE_OPERATIVO')
                }
                else if (param_nombre == "pep_fecha_alta") {
                    pld_param = FechaToSTR(parseFecha(rs.getdata('FECHA_ALTA')), 1)
                }
                else if (param_nombre == "pep_fecha_baja") {
                    pld_param = FechaToSTR(parseFecha(rs.getdata('FECHA_BAJA')), 1)
                }
                else if (param_nombre == "pep_tipo") {
                    pld_param = rs.getdata('ID_TIPO_PEP')
                }
            }

            return pld_param
        }


        function obtener_oficial_cuentas(param_nombre, campo_def, td_campo_def, param_valor, async) {
            var rs_oficial_cuentas = new tRS();
            var ofinrodoc = ""

            if (async) {
                rs_oficial_cuentas.async = true;

                nvFW.bloqueo_activar(td_campo_def, 'bloq_oc_' + param_nombre, null);
                $('divBloq_msg_bloq_oc_' + param_nombre).className = ""

                rs_oficial_cuentas.onError = function () {
                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                    alert('Error al cargar los par�metros.')
                }

                rs_oficial_cuentas.onComplete = function () {

                    if (!rs_oficial_cuentas.eof()) {
                        rs_oficial_cuentas.getdata("ofinrodoc") ? ofinrodoc = rs_oficial_cuentas.getdata("ofinrodoc") : ofinrodoc = ""
                    }

                    nvFW.bloqueo_desactivar(td_campo_def, 'bloq_oc_' + param_nombre);
                    campos_defs.set_value(campo_def, ofinrodoc)
                    $(param_nombre).value = $(campo_def + "_desc").value
                }

                rs_oficial_cuentas.open({ filtroXML: nvFW.pageContents.entXML });
            }
            else {
                rs_oficial_cuentas.async = true;
                rs_oficial_cuentas.open({ filtroXML: nvFW.pageContents.entXML });

                if (!rs_oficial_cuentas.eof()) {
                    rs_oficial_cuentas.getdata("ofinrodoc") ? ofinrodoc = rs_oficial_cuentas.getdata("ofinrodoc") : ofinrodoc = ""
                }

                return ofinrodoc
            }
        }


        function mostrarPLD() {
            _nro_com_id_tipo = 9

            var tienePermiso = false
            tienePermiso = nvFW.tienePermiso('permisos_pld', 1)

            if (tienePermiso == false) {
                alert('No posee permisos para realizar esta acci�n.')
                return
            }
            else {
                // if (!frame.pld.cargado) {
                var entidad = (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad)
                frame.pld.elemento.src = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=' + _nro_com_id_tipo + '&nro_com_grupo=11&collapsed_fck=1&do_zoom=0&id_tipo=' + entidad //+ '&nro_entidad=' + entidad
                frame.pld.cargado = true
                // }

                hideFrames()
                frame.pld.content.show()

                $('paramsDivPLD').show()
                _params = params_defPLD.add(nvFW.pageContents.entParamsXMLPLD, "<criterio><select><filtro><nro_entidad type='igual'>" + (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad) + "</nro_entidad></filtro></select></criterio>", 'paramsDivPLD', callback_param_onSave, nvFW.pageContents.filtro_histotico_pld, options_params)
            }
        }

        
        function mostrarOperaciones() {            
            if (!frame.operacion.cargado) {
                frame.operacion.elemento.src = '/voii/operaciones/mostrar_operaciones.aspx?nrodoc=<% = nrodoc %>&tipdoc=<% = tipdoc %>'
                frame.operacion.cargado = true
            }

            hideFrames()
            frame.operacion.content.show()
        }

        function mostrarArchivos(reload) {
            //if (!frame.archivo.cargado || reload) {

                if (reload)
                    cargarDefArchivo()
                //Definici�n de archivo
                if (_nro_def_archivo) {
                    frame.archivo.elemento.src = '/FW/archivo/mostrar_def_archivos.aspx?habilitar_nosis=true&nro_archivo_id_tipo=2&nro_def_archivo=' + _nro_def_archivo + '&id_tipo=' + (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad)
                    frame.archivo.cargado = true
                }
                else {
                    nvFW.confirm("Esta entidad no posee una definici�n de legajos<br>�Desea crearla?",
                        {
                            okLabel: 'Si',
                            cancelLabel: 'No',
                            onOk: function (win) {
                                ABMDefArchivo();
                                win.close();
                            }
                        })
                }

            //}

            hideFrames()
            frame.archivo.content.show()
        }


        function mostrarPrestamos()
        {
            if (!frame.prestamo.cargado) {
                frame.prestamo.elemento.src = '/voii/listado_prestamos.aspx?cuit=' + _cuit_cuil
                frame.prestamo.cargado = true
            }

            hideFrames()
            frame.prestamo.content.show()            
        }

        function listar_solicitudes() {
            if (!frame.solicitud.cargado) {
                
                frame.solicitud.elemento.src = '/voii/Solicitudes/solicitud_seleccion.aspx?cuit=' + _cuit_cuil
                frame.solicitud.cargado = true
            }

            hideFrames()
            frame.solicitud.content.show() 
        }

        var contactosExternos = [];
        function mostrarContactos() {
            if (!frame.contacto.cargado) {
                if (nvFW.pageContents.nro_entidad > 0) {
                    var rsContacto = new tRS();
                    
                    rsContacto.async = true;

                    nvFW.bloqueo_activar($$('body')[0], 'bloq_contacto', null);

                    rsContacto.onError = function () {
                        nvFW.bloqueo_desactivar(null, 'bloq_contacto');
                        alert('Error al cargar contactos.')
                    }

                    rsContacto.onComplete = function () {
                        contactosExternos = [];
                        while (!rsContacto.eof()) {
                    
                   
                            contactosExternos.push({
                                nro_contacto_grupo: rsContacto.getdata("nro_contacto_grupo", ""),
                                modo: rsContacto.getdata("modo", ""),
                                desc_contacto_tipo: rsContacto.getdata("desc_contacto_tipo", ""),
                                contacto_grupo: rsContacto.getdata("contacto_grupo", ""),
                                contacto: rsContacto.getdata("contacto", ""),
                                postal_real: rsContacto.getdata("postal_real", ""),
                                localidad: rsContacto.getdata("localidad", ""),
                                provincia: rsContacto.getdata("provincia", ""),
                                sistema: "IBS",
                                cpa: rsContacto.getdata("cpa", ""),
                                fecha_estado: rsContacto.getdata("fecha_estado", ""),
                                predeterminado: rsContacto.getdata("predeterminado", "")
                            });

                            rsContacto.movenext()
                        }
                        nvFW.bloqueo_desactivar(null, 'bloq_contacto');
                        frame.contacto.elemento.src = '/FW/entidades/contactos/Contacto_ABM.aspx?id_tipo=' + nvFW.pageContents.nro_entidad + '&nro_id_tipo=1';
                    }

                    rsContacto.open(nvFW.pageContents.filtroContactoGenerico);

                } else
                    frame.contacto.elemento.src = '/FW/entidades/contactos/Contacto_ABM.aspx' +
                        '?nombreFiltroContactoDomicilio=filtroContactoDomicilio' +
                        '&nombreFiltroContactoTelefono=filtroContactoTelefono' +
                        '&nombreFiltroContactoEmail=filtroContactoEmail' + 
                        '&nombreFiltroContactoGenerico=filtroContactoGenerico'
                frame.contacto.cargado = true
            }

            $('paramsDivPLD').hide()
            hideFrames()
            frame.contacto.content.show()
        }


        function verEntidad(evento, nro_entidad, tipdoc, nrodoc, tipocli, nombre, tiporel) {
            var url_destino = "/voii/cargar_cliente.aspx"
            if (tiporel < 0) {
                //Entidad de Nv
                url_destino += "?nro_entidad=" + nro_entidad + "&tipdoc=" + tipdoc + "&nrodoc=" + nrodoc + "&tipocli=" + tipocli + "&titulo=" + nombre + "tiporel=" + tiporel
            }
            else {
                //IBS
                var tipo_docu_ibs = tipdoc;
                //Debemos usar el tipo de documento externo
                if (evento.element().id !== "verClienteSelf") {
                    //Si se llama desde otra pantalla (Ej.: plantilla del FW), viene el tipdoc interno
                    var rsTDoc = new tRS();
                    rsTDoc.open(nvFW.pageContents.filtro_nomenclador_documento, "", "<criterio><select><filtro><cod_interno type='igual'>" + tipdoc + "</cod_interno></filtro></select></criterio>", "", "")
                    if (rsTDoc.recordcount >= 1) {
                        tipo_docu_ibs = rsTDoc.getdata('cod_externo')
                    }
                }
                
                url_destino += "?nro_entidad=" + nro_entidad + "&tipdoc=" + tipo_docu_ibs + "&nrodoc=" + nrodoc + "&tipocli=" + tipocli + "&titulo=" + nombre + "&tiporel=" + tiporel
            }

            //abrir_ventana_emergente(url_destino, nombre, 'permisos_entidades', 2, 500, 1000, true, true, true, true, false, 'frame_ref', evento)

            // Abrir datos seg�n modificadores (Ctrl | Shift)
            if (evento.ctrlKey) {
                // Nueva pesta�a
                var newWin = window.open(url_destino)
            }
            else if (evento.shiftKey) {
                // Nueva ventana de browser
                var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                newWin.moveTo(0, 0)
                newWin.resizeTo(screen.availWidth, screen.availHeight)
            }
            else {
                // Ventana flotante NO-modal. Comportamiento por defecto
                var porcentajeHeight;
                if (screen.height < 800)
                    porcentajeHeight = 0.747;
                else porcentajeHeight = 0.763;

                var frame_ref = top.ObtenerVentana('frame_ref')
                var win_vinculo = frame_ref.nvFW.createWindow({
                    url: url_destino,
                    title: '<b>' + nombre + '</b>',
                    width: frame_ref.innerWidth * 0.788, //1024,
                    height: frame_ref.innerHeight * porcentajeHeight,//500,
                    destroyOnClose: true
                })

                win_vinculo.showCenter(false)
            }

        }
    

        function callback_param_onSave(params) {
            //Guarda los datos
            var er = new tError()
            //Si bien recorremos una lista, suponemos que se editar� 1 par�metro a la vez
            for (var i = 0; i < params.length; i += 1) {
                if (params[i].visible && params[i].editable) {
                    nvFW.error_ajax_request('cargar_cliente.aspx', {
                        parameters: { parametro: params[i].parametro, param_valor: params[i].valor, nro_entidad: (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad), nro_com_id_tipo: _nro_com_id_tipo, nrodoc: _nrodoc, tipdoc : _tipdoc},
                        onSuccess: function (err, transport) {

                            if (err.numError == 0) {

                                //Actualizo los datos
                                if (_nro_com_id_tipo == 1)
                                    mostrarComentarios()

                                else if (_nro_com_id_tipo == 9)
                                    mostrarPLD()

                                if ($('frame_comentario').contentWindow.nro_com_grupo == 3)
                                    $('frame_comentario').contentWindow.Mostrar_Registro_grupo(3, 'ABM');

                            }
                        },
                        onFailure: function (err, transport) {
                            //debugger
                        },
                        error_alert: true
                    });
                }
                    
            }


            return er
        }

        function cargarDefArchivo() {
            _nro_def_archivo = 0; _def_archivo = undefined;
            //Definici�n de archivo
            var rsAl = new tRS();
            rsAl.open(nvFW.pageContents.filtro_archivo_leg_cab, "", "<criterio><select><filtro><id_tipo type='igual'>" + (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad) + "</id_tipo></filtro></select></criterio>", "", "")
            if (rsAl.recordcount >= 1) {
                _nro_def_archivo = rsAl.getdata('nro_def_archivo')
                var rsAd = new tRS();
                rsAd.open(nvFW.pageContents.filtro_archivos_def_cab, "", "<criterio><select><filtro><nro_def_archivo type='igual'>" + _nro_def_archivo + "</nro_def_archivo></filtro></select></criterio>", "", "")
                if (rsAd.recordcount >= 1) {
                    _def_archivo = rsAd.getdata('def_archivo')
                    $("menuItem_divMenu_0").childElements()[1].innerText = " " + _def_archivo + " "
                }
            }
        }

        var defarchivo
        function ABMDefArchivo() {

            var url = '\\fw\\archivo\\ABMDef_archivo.aspx?nro_archivo_id_tipo=2&nro_def_archivo=' + _nro_def_archivo + '&id_tipo=' + (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad)

            defarchivo = window.top.nvFW.createWindow({
                url: url,
                title: 'Definici�n Legajos',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 650,
                height: 200,
                onShow: function () {
                },
                onClose: ABMDefArchivo_return
            });

            defarchivo.options.userData = {}
            defarchivo.showCenter(true)

        }

        function ABMDefArchivo_return(win) {

            var retorno = ""
            try { retorno = win.options.userData.retorno ? "refresh" : "" } catch (e) { }
            
            if (retorno == "refresh")
                mostrarArchivos(true)
       				
        }

        function cargar_NOSIS() {

            nvFW.bloqueo_activar($$('BODY')[0], 1234, "Adjuntando informe Nosis")
            sac_html_guardar(function (url, propiedades) {
                try {

                    nvFW.bloqueo_desactivar($$('BODY')[0], 1234, "El informe Nosis se adjunto exitosamente")
                    if (url == "return")
                        return

                    if (url == "") {
                        reintentos = propiedades.reintentos
                        consultando = false;
                        cargar_NOSIS();
                        return
                    }

                    $('frame_archivo').contentWindow.cargarHistorial()

                    if (propiedades.novedad != "")
                        window.top.alert(propiedades.novedad)

                } catch (e) {
                    window.top.alert('No se pudo generar el archivo. Consulte al administrador del sistema.')
                }
            }, {
                CDA: nvFW.pageContents.cda,
                nro_vendedor: 0,
                nro_banco: 0,
                id_tipo: (nvFW.pageContents.nro_entidad != 0 ? nvFW.pageContents.nro_entidad : _nro_entidad),
                nro_archivo_id_tipo: 2,
                cuit: _cuit_cuil,
                nro_docu: _cuit_cuil.substr(2, 8),
                razonsocial: _razon_social,
                sexo: _sexo,
                reintentos: 0,
                nro_def_archivo: _nro_def_archivo
            }, function (err) {
                nvFW.bloqueo_desactivar($$('BODY')[0], 1234, "El informe Nosis se adjunto exitosamente")
                alert(err.mensaje)
            })

        }



        function guardarEntidad(rs, tipo_docu_nv) {
            var razon_social = '<![CDATA[' + rs.getdata("razon_social") + ']]>'
            var abreviacion = '<![CDATA[' + rs.getdata("razon_social") + ']]>'
            var apellido = '<![CDATA[' + rs.getdata("cliape") + ']]>'
            var nombres = '<![CDATA[' + rs.getdata("clinom") + ']]>'
            var alias = rs.getdata("clideno") ? '<![CDATA[' + rs.getdata("clideno") + ']]>' : ''
            var calle = '<![CDATA[' + rs.getdata("domnom") + ']]>'
            var email = email ? '<![CDATA[' + rs.getdata("email") + ']]>' : ''
            var esPersona_fisica = rs.getdata("tipocli") == "1"

            
            var xmldato = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            xmldato += "<pago_entidad modo='AC' nro_entidad='' "
//            xmldato += "postal='" + rs.getdata("codpos") + "' "
            if (rs.getdata("cartel"))
                xmldato += "postal_telefono='" + rs.getdata("cartel") + "' "
            if (rs.getdata("numtel"))
                xmldato += "telefono='" + rs.getdata("numtel") + "' "
            xmldato += "cuit='" + rs.getdata("CUIT_CUIL") + "' "
            //if (rs.getdata("CUIT_CUIL") != '')
            //    xmldato += "cuitcuil='" + rs.getdata("CUIT_CUIL") + "' ";
            xmldato += "cuitcuil='" + (esPersona_fisica ? 'CUIL' : 'CUIT') + "' "
            //                        else xmldato += "cuitcuil='' "

            xmldato += "numero='" + rs.getdata("domnro") + "' nro_contacto_tipo='1' resto='' "
            if (rs.getdata("dompiso"))
                xmldato += "piso='" + rs.getdata("dompiso") + "' "
            if (rs.getdata("domdepto"))
                xmldato += "depto='" + rs.getdata("domdepto") + "' "
            //xmldato += "cod_sit_iva='" + clconddgi + "' cod_ing_brutos='" + $cod_ing_brutos.value + "' "

            if (rs.getdata("policaexpuesto") == 1)
                xmldato += "pep='1' "
            else
                xmldato += "pep='0' "

            var fecnac_insc = rs.getdata("fecnac_insc") == undefined ? '' : FechaToSTR(parseFecha(rs.getdata("fecnac_insc")));

            if (esPersona_fisica) {

                xmldato += "nro_docu='" + rs.getdata("nrodoc") + "' tipo_docu='" + tipo_docu_nv + "' sexo='" + rs.getdata("clisexo") + "' persona_fisica='1' "
                xmldato += "dni='" + rs.getdata("DNI") + "' nro_emp_tipo='' nro_soc_tipo='' "
                xmldato += "fecha_nacimiento='" + fecnac_insc + "' fecha_inscripcion='' " //estado_civil='" + rs.getdata("descestciv") + "' nro_nacion='" + $nro_nacion.value + "' "
                //xmldato += "nro_docu_c='" + $('nro_docu_c').value + "' tipo_docu_c='" + $('tipo_docu_c').value + "' "
            }
            else {

                xmldato += "nro_docu='" + rs.getdata("nrodoc") + "' tipo_docu='" + tipo_docu_nv + "' sexo='' persona_fisica='0' "
                xmldato += "dni='' nro_emp_tipo='' nro_soc_tipo='' "
                xmldato += "fecha_nacimiento='' fecha_inscripcion='" + fecnac_insc + "' estado_civil='' nro_nacion='' "
                //xmldato += "nro_docu_c='' tipo_docu_c='' "

            }

            //Oficial de cuenta
            if (rs.getdata("ofinrodoc"))
                xmldato += " ofinrodoc='" + rs.getdata("ofinrodoc") + "' "
            else
                xmldato += " ofinrodoc='' "

            xmldato += ">"


            if (esPersona_fisica) {
                xmldato += "<apellido>" + apellido + "</apellido>"
                xmldato += "<nombres>" + nombres + "</nombres>"
            }
            else {
                xmldato += "<apellido></apellido>"
                xmldato += "<nombres></nombres>"
            }

            xmldato += "<razon_social>" + razon_social + "</razon_social>"
            xmldato += "<abreviacion>" + abreviacion + "</abreviacion>"
            xmldato += "<alias>" + alias + "</alias>"
            xmldato += "<calle>" + calle + "</calle>"
            xmldato += "<email>" + email + "</email>"
            xmldato += "</pago_entidad>"

            nvFW.error_ajax_request('cargar_cliente.aspx', {
                asynchronous: false, //Necesitamos el mro_entidad para poder corgar la p�gina
                parameters: {
                    strXML: xmldato
                },
                onSuccess: function (err, transport) {
                    _nro_entidad = err.params['nro_entidad']
                },
                onFailure: function (err) {
                    if (typeof err == 'object') {
                        alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                    }
                },
                error_alert: false,
                bloq_msg: "Cargando..."
            });
        }

        function editarEntidad() {
            var tienePermiso = false
            tienePermiso = nvFW.tienePermiso('permisos_entidades', 1)
            if (tienePermiso == false) {
                alert('No posee permisos para editar la entidad.')
                return
            }
            
            if (nvFW.pageContents.nro_entidad) {
                var win_entidad_abm = window.top.nvFW.createWindow({
                    url: '/FW/entidades/entidad_abm.aspx?nro_entidad=' + nvFW.pageContents.nro_entidad + "&entidad_consultar=/voii/entidad_cons_consultar.aspx",
                    title: '<b>Entidad ABM</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    width: 1024,
                    height: 480,
                    resizable: true,
                    destroyOnClose: true,
                    onClose: function(win)
                    {
                        if(win.options.userData.recargar) {
                            window_onload()
                            //if ($('frame_comentario').contentWindow.nro_com_grupo == 3)
                            //    $('frame_comentario').contentWindow.Mostrar_Registro_grupo(3, 'ABM');
                        }
                    }
                })

                win_entidad_abm.options.userData = { recargar: false }
                win_entidad_abm.showCenter(true)
            }
        }

        function setTelefono(car_tel, num_tel) {
            if (!$("telefono"))
                return;
            if (num_tel)
                $("telefono").update((car_tel ? "(" + car_tel + ") " : "") + num_tel)
            else
                $("telefono").update("&nbsp;")
        }
        function setDomicilio(dom_nom, dom_nro, dom_piso, dom_depto, dom_resto, postal, descLocalidad) {
            if ($("domicilio")) {
                if (dom_nom)
                    $("domicilio").update(dom_nom + " " + dom_nro + (dom_piso ? " - Piso: " + dom_piso : "") + (dom_depto ? " - Depto: " + dom_depto : ""))
                else
                    $("domicilio").update("&nbsp;")
            }
            if ($("codpos")) {
                if (postal)
                    $("codpos").update(postal)
                else
                    $("codpos").update("&nbsp;")
            }
            if ($("localidad")) {
                if (descLocalidad)
                    $("localidad").update(descLocalidad)
                else
                    $("localidad").update("&nbsp;")
            }
        }
        function setEmail(email) {
            if (!$("email"))
                return;
            if (email)
                $("email").update(email)
            else
                $("email").update("&nbsp;")
        }

    </script>
    <style>
        tr.centrado td { text-align: center; }
    </style>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <script type="text/javascript">nvFW.bloqueo_activar($$('body')[0], 'bloq_datos', 'Cargando informaci�n de la entidad...')</script>
    <div  id="datos_cliente">
        <%-- MENU principal de la operacion --%>
        <div id="divMenuPrincipal"></div>
        
    
        <table class="tb1" cellspacing="0" cellpadding="0">
            <tr>
                <td>
                    <table class="tb1">
                    <%--Persona F�sica--%>
                    <% if tipocli = 1 Then %>
                
                        <tr class="tbLabel centrado">
                            <td  colspan="2" style="width: 120px;">CUIT / CUIL</td>
                            <td >DNI</td>
                            <td >Apellido</td>
                            <td >Nombres</td>
                            <td >Sexo</td>
                        
                            <td colspan="2">Estado</td>
                        </tr>
                        <tr>
                            <td width="20px"><img id="verClienteSelf" title="Ver Cliente" alt="Ver" src="../FW/image/icons/ver.png" style="cursor:pointer" /> </td>
                            <td style="width: 120px;"class="Tit4" id="cuit_cuil">&nbsp</td>
                            <td class="Tit4" id="dni">&nbsp</td>
                            <td class="Tit4" id="cliape">&nbsp</td>
                            <td class="Tit4" id="clinom">&nbsp</td>
                            <td class="Tit4" id="clisexo">&nbsp</td>
                        
                            <td class="Tit4" colspan="2" id="tipreldesc"></td>
                        </tr>
                        <tr class="tbLabel centrado">
                            <td  colspan="2" style="width: 120px;">Nacionalidad</td>
                        
                            <td >Estado Civil</td>
                            <td >Conyuge</td>
                            <td >Situaci�n IVA</td>
                            <td >PEP</td>
                        
                            <td >Fecha Nac.</td>
                            <td >Edad</td>
                        </tr>
                        <tr>
                            <td  colspan="2" class="Tit4" style="width: 120px;" id="nacionalidad">&nbsp</td>
                        
                            <td class="Tit4" id="descestciv">&nbsp</td>
                            <td class="Tit4" id="apenomConyuge">&nbsp</td>
                            <td class="Tit4" id="clconddgi">&nbsp</td>
                            <td class="Tit4" id="pep">&nbsp</td>
                            <td Class="Tit4" id="fecnac_insc">&nbsp</td>
                            <td Class="Tit4" id="age">&nbsp</td>
                        </tr>
                    <%End If%>
                    <%--Persona Jur�dica--%>
                    <% if tipocli = 2 Then %>
                        <tr class="tbLabel centrado">
                            <td colspan="2" style="width: 120px;">CUIT / CUIL</td>
                        
                            <td>Raz�n Social</td>
                        
                            <td >Tipo Empresa</td>
                        
                            <td >Tipo Sociedad</td>
                            <td >Estado</td>
                        </tr>
                        <tr>
                            <td width="20px"><img id="verClienteSelf" title="Ver Cliente" alt="Ver" src="../FW/image/icons/ver.png" style="cursor:pointer" /> </td>
                            <td class="Tit4" style="width: 120px;" id="cuit_cuil"></td>
                        
                            <td class="Tit4" id="razon_social">&nbsp</td>
                        
                            <td class="Tit4" id="tipoempdesc">&nbsp</td>
                        
                            <td class="Tit4" id="tipsocdesc">&nbsp</td>
                        
                            <td class="Tit4" id="tipreldesc">&nbsp</td>
                        </tr>

                        <tr class="tbLabel centrado">
                            <td colspan="2"style="width: 120px;">Fecha Inscripci�n</td>
                            <td >Denominaci�n</td>
                        
                            <td>Sector Financiero</td>
                            <td colspan="2">Situaci�n IVA</td>
                        
                        </tr>
                        <tr>
                            <td colspan="2" Class="Tit4" style="width: 120px;" id="fecnac_insc">&nbsp</td>
                            <td class="Tit4" id="clideno">&nbsp</td>
                        
                            <td class="Tit4" id="sectorfindesc">&nbsp</td>
                            <td class="Tit4" colspan="2" id="clconddgi">&nbsp</td>
                        
                        </tr>
                    <%End If%>
                    </table>
                    <table class="tb1">
                        <tr class="tbLabel centrado">
                            <td style="width: 120px;">Tel�fono</td>
                            <td >Email</td>
                            <td  >Domicilio</td>
                            <td >CP</td>
                            <td >Localidad</td>
                        </tr>
                        <tr>
                            <td class="Tit4"  style="width: 120px;" id="telefono">&nbsp</td>
                            <td class="Tit4" id="email">&nbsp</td>
                            <td class="Tit4" id="domicilio">&nbsp</td>
                            <td class="Tit4" id="codpos">&nbsp</td>
                            <td class="Tit4" id="localidad">&nbsp</td>
                        </tr>
                    </table>

                </td>
            </tr>
        </table>
    </div>
    

    <div id="divMenu"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');

        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc> </Desc><Acciones><Ejecutar Tipo='script'><Codigo>ABMDefArchivo()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>comentario</icono><Desc>Comentarios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarComentarios()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>operacion</icono><Desc>Cuentas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarOperaciones()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>contactos</icono><Desc>Contactos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarContactos()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>reporte</icono><Desc>Solicitudes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>listar_solicitudes()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='6'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vinculos</icono><Desc>V�nculos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarVinculos()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='7'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarArchivos()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='8'><Lib TipoLib='offLine'>DocMNG</Lib><icono>playft</icono><Desc>PLAyFT</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarPLD()</Codigo></Ejecutar></Acciones></MenuItem>")


        vMenu.loadImage("editar", "/FW/image/icons/editar.png");
        vMenu.loadImage("operacion", "/FW/image/icons/dollar.png");
        vMenu.loadImage("comentario", "/FW/image/icons/comentario3.png");
        vMenu.loadImage("archivo", "/FW/image/icons/nueva.png");
        vMenu.loadImage("vinculos", "/FW/image/icons/personas.png");
        vMenu.loadImage("contactos", "/FW/image/icons/user.png");
        vMenu.loadImage("reporte", "/FW/image/icons/reporte.png");
        vMenu.loadImage("playft", "/FW/image/icons/buscar.png");
        vMenu.MostrarMenu()
    </script>

    <div id="content_comentario" style="display:none;">
        
    <div style="width:70%; float:left;">
        <iframe id="frame_comentario" name="frame_comentario" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%;"></iframe>
    </div>
    <div style="width:30%; float:left;">
        <div id="paramsDivCom" style="max-height:300px; overflow-y:auto;"></div>
        <div id="infoDiv" class="mnuCELL_Normal_P">&nbsp;Informaci�n complementaria&nbsp;</div>
        <table class="tb1">
            <tbody id="infoCliente"></tbody>
        </table>
    </div>
        
    </div>
    <div id="content_operacion" style="display: none;">
        <iframe id="frame_operacion" name="frame_archivo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%;"></iframe>
    </div>
    <div id="content_archivo" style="display: none;">
        <iframe id="frame_archivo" name="frame_archivo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%;"></iframe>
    </div>
    <div id="content_vinculo" style="display: none;">
        <iframe id="frame_vinculo" name="frame_vinculo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%;"></iframe>
    </div>
    
    <div id="content_prestamo" style="display: none;">
        <iframe id="frame_prestamo" name="frame_prestamo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%"></iframe>
    </div>
    <div id="content_solicitud" style="display: none;">
        <iframe id="frame_solicitud" name="frame_solicitud" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%"></iframe>
    </div>

     <div id="content_pld" style=" width:70%; float: left; display: none;">
        <iframe id="frame_pld" name="frame_pld" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%"></iframe>
    </div>
     <div style="width:30%; float:left;">
        <div id="paramsDivPLD" style="overflow-y:auto;"></div>
    </div>

    <div id="content_contacto" style="display: none;">
        <iframe id="frame_contacto" name="frame_contacto" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%"></iframe>
    </div>

</body>
</html>
