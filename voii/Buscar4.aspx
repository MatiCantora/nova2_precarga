<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")

    If accion.ToLower() = "capturar" Then

        Dim Err As New nvFW.tError()

        If (Not op.tienePermiso("permisos_comentarios", 6)) Then
            Err.numError = -2
            Err.titulo = ""
            Err.mensaje = "No posee permisos para realizar esta acción."
            Err.debug_src = "ABMRegistro.aspx"
            Err.response()
        End If

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("com_capture_first", ADODB.CommandTypeEnum.adCmdStoredProc)

        cmd.addParameter("@operador", ADODB.DataTypeEnum.adInteger, , , op.operador)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()

            If rs.Fields("numError").Value = 0 Then
                Dim nro_registro As Integer = rs.Fields("nro_registro").Value
                Err.params.Add("nro_registro", nro_registro)
                If nro_registro <> 0 Then
                    Err.params.Add("nro_entidad", nvFW.nvUtiles.isNUllorEmpty(rs.Fields("nro_entidad").Value, 0))
                    Err.params.Add("id_tipo", rs.Fields("id_tipo").Value)
                    Err.params.Add("nro_com_id_tipo", rs.Fields("nro_com_id_tipo").Value)
                    Err.params.Add("nro_com_tipo", rs.Fields("nro_com_tipo").Value)
                    Err.params.Add("nro_com_estado", rs.Fields("nro_com_estado").Value)
                End If
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
            Err.numError = -1
            Err.mensaje = "Error al cargar comentario."
            Err.titulo = "Error"
            Err.debug_src = "Buscar.aspx"
            Err.debug_desc = "Error en carga de datos"
        End Try

        Err.response()

    End If


    Me.contents("filtro_buscar_entidad_nrodoc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><nrodoc type='igual'>%nrodoc%</nrodoc></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_nrodoc_todos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><or><nrodoc type='igual'>%nrodoc%</nrodoc><DNI type='igual'>'%nrodoc%'</DNI><CUIT_CUIL type='igual'>'%nrodoc%'</CUIT_CUIL></or></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_cuitcuil") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><or><and><tipdoc type='igual'>%tipdoc%</tipdoc><nrodoc type='igual'>%nrodoc%</nrodoc></and><CUIT_CUIL type='igual'>'%nrodoc%'</CUIT_CUIL></or></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_dni") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><or><and><tipdoc type='igual'>%tipdoc%</tipdoc><nrodoc type='igual'>%nrodoc%</nrodoc></and><DNI type='igual'>'%nrodoc%'</DNI></or></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_otros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><tipdoc type='igual'>%tipdoc%</tipdoc><nrodoc type='igual'>%nrodoc%</nrodoc></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_rz") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><razon_social type='like'>%razon_social%</razon_social></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_openro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_prestamos' cn='BD_IBS_ANEXA'><campos>DISTINCT paiscod, bcocod, succod, sistcod, codsubsist, moncod, cuecod, nrodoc, cliape, clinom, clisexo, clifecnac, openro, nroreferencia, nrodoc</campos><filtro></filtro><orden>openro</orden></select></criterio>")
    Me.contents("filtro_tipo_doc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_documento' cn='BD_IBS_ANEXA'><campos>tipdoc as id, sintetico as [campo]</campos><filtro><estado type='igual'>0</estado></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_nomenclador_sistema") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'sistema'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'documento'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_reclamos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.LD_circuito_reclamos' CommantTimeOut='1500'  AbsolutePage='1' expire_minutes='1' PageSize='%cantFilas%' cacheControl='Session'><parametros><nro_proceso DataType='int'>" & 354 & "</nro_proceso></parametros></procedure></criterio>")
    Me.contents("filtroTipRel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..trcl_tiprelac' cn='BD_IBS_ANEXA'><campos>distinct tiporel as id, tipreldesc as [campo], paiscod, bcocod, tiporel</campos><orden></orden></select></criterio>")

    Me.contents("filtro_comentarios") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro'><campos>nro_com_grupo, nro_com_estado, id_tipo, nro_com_id_tipo, fecha, comentario, operador, nro_com_tipo, com_tipo, com_estado, nombre_operador, nro_registro, bloqueado, bloq_operador</campos><filtro>[<nro_com_id_tipo type='in'>%nro_com_id_tipo?%</nro_com_id_tipo>][<id_tipo type='in'>%id_tipo?%</id_tipo>]</filtro><orden>fecha desc</orden></select></criterio>")

    Me.contents("filtro_pendientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_registro'><campos>COUNT(*) AS cant_pendientes</campos><orden></orden><filtro><sql type='sql'>'" & op.operador.ToString() & "' IN (SELECT valor1 FROM dbo.piz2D_values('config_comentario_operador',nro_com_tipo, nro_com_estado))</sql></filtro></select></criterio>")
    Me.contents("filtro_comentarios_pendientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro'><campos>nro_com_grupo, nro_com_estado, id_tipo, nro_com_id_tipo, fecha, comentario, operador, nro_com_tipo, com_tipo, com_estado, nombre_operador, nro_registro, bloqueado, bloq_operador</campos><filtro><sql type='sql'>'" & op.operador.ToString() & "' IN (SELECT valor1 FROM dbo.piz2D_values('config_comentario_operador',nro_com_tipo, nro_com_estado))</sql></filtro><orden>fecha desc</orden></select></criterio>")

    Me.contents("filtro_bloqueados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='bloqueo_operador'><campos>COUNT(*) AS cant_bloqueados</campos><orden></orden><filtro><operador type='igual'>" & op.operador.ToString() & "</operador><fe_hasta type='mayor'>GETDATE()</fe_hasta></filtro></select></criterio>")

    Me.contents("filtroCircuito") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cire_com_detalle' top='1'><campos>nro_circuito</campos><filtro><nro_com_tipo type='igual'>%nro_com_tipo%</nro_com_tipo><nro_com_estado type='igual'>%nro_com_estado%</nro_com_estado></filtro></select></criterio>")

    Me.contents("fecha_hoy") = Now().ToString("dd/MM/yyyy")
    Me.contents("operador") = op.operador


%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Buscar</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        .icon-16 {
            width: 16px;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        //Cargar botones
        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "BuscarCliente";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscarEntidad()";

        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "BuscarComentario";
        vButtonItems[1]["etiqueta"] = "Buscar";
        vButtonItems[1]["imagen"] = "buscar";
        vButtonItems[1]["onclick"] = "return buscarComentario()";

        vButtonItems[2] = {}
        vButtonItems[2]["nombre"] = "BtnPendientes";
        vButtonItems[2]["etiqueta"] = "Pendientes (?)";
        vButtonItems[2]["imagen"] = "";
        vButtonItems[2]["onclick"] = "return cargarPendientes()";

        vButtonItems[3] = {}
        vButtonItems[3]["nombre"] = "BtnBloqueados";
        vButtonItems[3]["etiqueta"] = "Bloqueados (?)";
        vButtonItems[3]["imagen"] = "";
        vButtonItems[3]["onclick"] = "return cargarBloqueados()";

        vButtonItems[4] = {}
        vButtonItems[4]["nombre"] = "BtnCapturar";
        vButtonItems[4]["etiqueta"] = "Capturar";
        vButtonItems[4]["imagen"] = "";
        vButtonItems[4]["onclick"] = "return capturar_comentario()";

        vButtonItems[5] = {}
        vButtonItems[5]["nombre"] = "BtnAlta";
        vButtonItems[5]["etiqueta"] = "Alta";
        vButtonItems[5]["imagen"] = "";
        vButtonItems[5]["onclick"] = "return nuevoComentario()";

        //vButtonItems[1] = {}
        //vButtonItems[1]["nombre"] = "BtnReclamo";
        //vButtonItems[1]["etiqueta"] = "Reclamo";
        //vButtonItems[1]["imagen"] = "buscar";
        //vButtonItems[1]["onclick"] = "return verReclamos()";

        //vButtonItems[1] = {}
        //vButtonItems[1]["nombre"] = "BuscarOperacion";
        //vButtonItems[1]["etiqueta"] = "Buscar";
        //vButtonItems[1]["imagen"] = "buscar";
        //vButtonItems[1]["onclick"] = "return buscarOperacion()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        //var vListButton = new tListButton(vButtonItems, 'vListButton');

        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');


        // Variables para 'cachear' elementos
        var $tipo_docu
        var $nro_docu
        var $apenom
        var $openro
        var $nroReferencia
        var winBusquedaCUIT
        var winFramePrincipal
        var operador = nvFW.pageContents.operador


        function window_onload() {

            ////Menu Comentarios
            //if (!nvFW.tienePermiso('permisos_backoffice', 1)) {
            //    $('tbComentario').hide();
            //}
            ////Boton Alta Comentario
            //if (!nvFW.tienePermiso('permisos_backoffice', 2)) {
            //    $('tbAlta').hide();
            //}
            ////Boton Pendientes
            //if (!nvFW.tienePermiso('permisos_backoffice', 4)) {
            //    $('tbPendientes').hide();
            //} else {
                actualizar_pendientes();
                interval_pendientesID = setInterval('actualizar_pendientes()', 15000);
            //}
            ////Boton Captura y Comentarios Bloqueados
            //if (!nvFW.tienePermiso('permisos_backoffice', 3)) {
            //    $('tbCapturar').hide();
            //    $('tbBloqueados').hide();
            //} else {
                actualizar_bloqueados();
                interval_bloqueadosID = setInterval('actualizar_bloqueados()', 15000);
            //}

            vListButton.MostrarListButton();

            nvFW.enterToTab = false

            // Asignar las referencias a elementos
            $tipo_docu = $('tipodoc')
            $nro_docu = $('nro_docu')
            $apenom = $('apenom')
            //$openro = $('openro')
            //$nroReferencia = $('nroreferencia')

            // Setear funciones onchange() de los campos_def
            $tipo_docu.onkeypress = tipodocuOnKeyPress
            $nro_docu.onkeypress = nrodocuOnKeyPress
            $nro_docu.onfocus = function () {
                campos_defs.clear('apenom')
            }
            $apenom.onkeypress = apenomOnKeyPress
            $apenom.onfocus = function () {
                campos_defs.clear('nro_docu')
            }
            //$openro.onkeypress = openroOnKeyPress
            //$openro.onfocus = function () {
            //    campos_defs.clear('nroreferencia')
            //}
            //$nroReferencia.onkeypress = nroreferenciaOnKeyPress
            //$nroReferencia.onfocus = function () {
            //    campos_defs.clear('openro')
            //}

            winFramePrincipal = ObtenerVentana('frame_consulta')
        }


        //Setear onKeyPress para buscar
        function isEnterKey(event) {
            return (event.keyCode || event.which) == 13
        }


        function apenomOnKeyPress(event) {
            if (!isEnterKey(event)) {
                return
            }
            else {
                if (this.value.length == 0)
                    return false
                else
                    buscarEntidad()
            }
        }


        function tipodocuOnKeyPress(event) {
            if (!isEnterKey(event))
                return
            else {
                if (this.value.length == 0)
                    return false
                else
                    buscarEntidad()
            }
        }


        function nrodocuOnKeyPress(event) {
            if (!isEnterKey(event)) {
                return
            }
            else {
                if (this.value.length == 0)
                    return false
                else
                    buscarEntidad()
            }
        }


        //function openroOnKeyPress(event) {
        //    if (!isEnterKey(event)) {
        //        return
        //    }
        //    else {
        //        if (this.value.length == 0)
        //            return false
        //        else
        //            buscarOperacion()
        //    }
        //}


        //function nroreferenciaOnKeyPress(event) {
        //    if (!isEnterKey(event)) {
        //        return
        //    }
        //    else {
        //        if (this.value.length == 0)
        //            return false
        //        else
        //            buscarOperacion()
        //    }
        //}


        function buscarEntidad() {

            if ($nro_docu.value == '' && $apenom.value == '') {
                window.top.alert('Ingrese <b>Nro. documento</b> o <b>Razón social</b>')
                return
            }

            var filtroXML = '';
            var filtro = '';
            var params = ''
            if ($nro_docu.value != '') {       
                
                if ($('checkTipdoc').checked) {          
                    params = "<criterio><params nrodoc='" + $nro_docu.value + "' /></criterio>"
                    filtroXML = nvFW.pageContents.filtro_buscar_entidad_nrodoc_todos
                } else {
                    params = "<criterio><params nrodoc='" + $nro_docu.value + "' /></criterio>"
                    filtroXML = nvFW.pageContents.filtro_buscar_entidad_nrodoc
                    if ($tipo_docu.value != '') {
                        params = "<criterio><params nrodoc='" + $nro_docu.value + "' tipdoc='" + $tipo_docu.value + "' /></criterio>"
                        switch ($tipo_docu.value) {
                            case "8":
                                if ($nro_docu.value.toString().length == 11) {
                                    filtroXML = nvFW.pageContents.filtro_buscar_entidad_cuitcuil
                                } else { window.top.alert('El CUIT ingresado debe tener 11 dígitos.'); return }
                                break;
                            case "5":
                                if ($nro_docu.value.toString().length == 11) {
                                    filtroXML = nvFW.pageContents.filtro_buscar_entidad_cuitcuil
                                } else { window.top.alert('El CUIT ingresado debe tener 11 dígitos.'); return }
                                break;
                            case "1":
                                filtroXML = nvFW.pageContents.filtro_buscar_entidad_dni
                                break;
                            default:
                                filtroXML = nvFW.pageContents.filtro_buscar_entidad_otros
                                break;
                        }
                    }
                }
            }

            if ($apenom.value != '') {
                filtroXML = nvFW.pageContents.filtro_buscar_entidad_rz
                params = "<criterio><params razon_social='%" + $apenom.value.toUpperCase() + "%' /></criterio>"
            }
                //filtro += "<sql type='sql'>upper(razon_social) like upper('%" + $apenom.value + "%')</sql>";

            filtro += campos_defs.filtroWhere('tiporels');

            filtro += campos_defs.filtroWhere('tipocli');

            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 24);


            parent.nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                bloq_contenedor: window.top.document.getElementById('frame_ref'),
                path_xsl: 'report/Plantillas/HTML_buscar_entidad.xsl',
                bloq_msg: 'Buscando cliente...',
                formTarget: 'frame_consulta',
                params: params,
                nvFW_mantener_origen: true
            });

        }

        function verReclamos() {

            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 24);
            //<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro></filtro></select></criterio>
            parent.nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_reclamos,
                filtroWhere: '',
                bloq_contenedor: window.top.document.getElementById('frame_ref'),
                path_xsl: 'report/Plantillas/HTML_buscar_reclamos.xsl',
                bloq_msg: 'Buscando Reclamos...',
                formTarget: 'frame_consulta',
                params: '<criterio><params cantFilas="' + cantFilas + '" /></criterio>',
                nvFW_mantener_origen: true
            });

        }

        //function buscarOperacion() {

        //    if ($openro.value == '' && $nroReferencia.value == '') {
        //        window.top.alert('Ingrese un filtro de busqueda')
        //        return
        //    }

        //    var filtro = '';

        //    if ($openro.value != '')
        //        filtro += '<openro type="igual">' + $openro.value + '</openro>';
        //    if ($nroReferencia.value != '')
        //        filtro += '<nroreferencia type="igual">\'' + $nroReferencia.value + '\'</nroreferencia>';

        //    top.nvFW.exportarReporte({
        //        filtroXML: nvFW.pageContents.filtro_buscar_openro,
        //        filtroWhere: '<criterio><select><filtro>' + filtro + '</filtro></select></criterio>',
        //        path_xsl: 'report/verPrestamos/HTML_buscar_openro.xsl',
        //        bloq_contenedor: window.top.document.getElementById('frame_ref'),
        //        bloq_msg: 'Buscando operacion...',
        //        formTarget: 'frame_consulta'
        //    })

        //}


        function cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, tiporel) {
            var url = '/voii/cargar_cliente.aspx?tipocli=' + tipocli + '&tipdoc=' + tipdoc + '&nrodoc=' + nrodoc
            if (typeof tiporel != "undefined" && tiporel != '')
                url += '&tiporel=' + tiporel
            if (nro_entidad)
                url += '&nro_entidad=' + nro_entidad
            winFramePrincipal.location.href = url;
        }


        function operador_historial(e) {

            var win = window.top.nvFW.createWindow({
                async: false,
                url: '/voii/operador_historial.aspx',
                title: '<b>Historial de Búsqueda</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                resizable: false,
                modulo: false,
                width: 800,
                height: 400,
                onClose: function (err) {
                }
            });


            win.showCenter(false)
            //win.show(false)
        }

        function habilitar_tipdoc() {

            campos_defs.clear('tipodoc');
            campos_defs.habilitar('tipodoc', $('checkTipdoc').checked == false);            

        }

        function mostrar_filtros_comentario() {

            if ($('trFiltrosComentario').style.display == 'none') {
                $('trFiltrosComentario').show();
                $('trBuscarComentarios').show();
                $('imgFiltrosComentario').src = '/fw/image/mnusvr/menos.gif'
            } else {
                $('trBuscarComentarios').hide();
                $('trFiltrosComentario').hide();
                $('imgFiltrosComentario').src = '/fw/image/mnusvr/mas.gif'
            }
        }

        function buscarComentario() {
            var filtro = ''
            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 22);

            if (campos_defs.get_value("fecha_desde") == "") {
                window.top.alert('Ingrese <b>Fecha Desde</b>')
                return
            }
            else {
                filtro += '<nro_com_grupo type="igual">' + $('nro_com_grupo').value + '</nro_com_grupo>'
                filtro += campos_defs.filtroWhere('nro_com_tipo')
                filtro += campos_defs.filtroWhere('nro_com_estados')
                filtro += campos_defs.filtroWhere('fecha_desde')

                winFramePrincipal.frameElement.onload = function () {
                    ObtenerVentana("frame_consulta").nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.filtro_comentarios,
                        filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                        bloq_contenedor: 'frame_comentarios',
                        path_xsl: 'report/comentario/HTML_verComentarios.xsl',
                        bloq_msg: 'Buscando comentarios...',
                        formTarget: 'frame_comentarios',
                        params: "",
                        nvFW_mantener_origen: true
                    });
                }
                winFramePrincipal.frameElement.src = "/voii/comentario/comentario_listar.aspx?tipo_filtro=comentarios"

            }

        }

        function cargarPendientes() {

            var filtro = ''
            filtro += '<nro_com_grupo type="igual">' + $('nro_com_grupo').value + '</nro_com_grupo>'

            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 22);

            winFramePrincipal.frameElement.onload = function () {
                ObtenerVentana("frame_consulta").nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_comentarios_pendientes,
                filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                bloq_contenedor: 'frame_comentarios',
                path_xsl: 'report/comentario/HTML_verComentarios.xsl',
                bloq_msg: 'Buscando comentarios...',
                formTarget: 'frame_comentarios',
                params: "",
                nvFW_mantener_origen: true
                });
            }
            winFramePrincipal.frameElement.src = "/voii/comentario/comentario_listar.aspx?tipo_filtro=pendientes"
        }

        function actualizar_pendientes() {
            
            var rs = new tRS();

            rs.async = true;

            rs.onComplete = function () {
                if (rs.recordcount > 0) {
                    var cant_pendientes = rs.getdata("cant_pendientes")
                    $('divBtnPendientes').getElementsByTagName('td')[1].innerHTML = '&nbsp;Pendientes (<b>' + cant_pendientes + '</b>)'
                }
            }

            rs.open(nvFW.pageContents.filtro_pendientes);
        }


        function cargarBloqueados() {

            var filtro = "<bloq_operador type='igual'>" + operador + "</bloq_operador><bloqueado type='igual'>1</bloqueado>"
            filtro += '<nro_com_grupo type="igual">1</nro_com_grupo>'

            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 22);

            winFramePrincipal.frameElement.onload = function () {
                ObtenerVentana("frame_consulta").nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_comentarios,
                filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                bloq_contenedor: 'frame_comentarios',
                path_xsl: 'report/comentario/HTML_verComentarios.xsl',
                bloq_msg: 'Buscando comentarios...',
                formTarget: 'frame_comentarios',
                params: "",
                nvFW_mantener_origen: true
                });
            }
            winFramePrincipal.frameElement.src = "/voii/comentario/comentario_listar.aspx?tipo_filtro=bloqueados"
        }

        function actualizar_bloqueados() {

            var rs = new tRS();

            rs.async = true;

            rs.onComplete = function () {
                if (rs.recordcount > 0) {
                    var cant_bloqueados = rs.getdata("cant_bloqueados")
                    $('divBtnBloqueados').getElementsByTagName('td')[1].innerHTML = '&nbsp;Bloqueados (<b>' + cant_bloqueados + '</b>)'
                }
            }

            rs.open(nvFW.pageContents.filtro_bloqueados);
        }


        var Parametros = []
        function capturar_comentario() {

            top.nvFW.error_ajax_request('buscar.aspx', {
                parameters: {
                    accion: 'capturar'
                },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {

                        if (err.params['nro_registro'] == 0) {
                            top.nvFW.alert('No hay comentarios pendientes.');
                            return
                        }

                        nvFW.bloqueo_activar($$('body')[0], 'bloq_comentario', 'Cargando comentario...');
                        var rsCircuito = new tRS();

                        rsCircuito.async = true;
                        rsCircuito.onComplete = function (res) {

                            nvFW.bloqueo_desactivar(null, 'bloq_comentario');

                            var url_destino = '/FW/comentario/ABMRegistro.aspx' +
                                '?nro_entidad=' + err.params['nro_entidad'] +
                                '&id_tipo=' + err.params['id_tipo'] +
                                '&nro_com_id_tipo=' + err.params['nro_com_id_tipo'] +
                                '&nro_registro_origen=' + err.params['nro_registro'] +
                                '&nro_com_tipo_origen=' + err.params['nro_com_tipo'] +
                                '&nro_com_estado_origen=' + err.params['nro_com_estado'] +
                                '&nro_circuito=' + res.getdata('nro_circuito') +
                                '&nro_com_grupo=' + 1 +
                                '&collapsed_fck=' + 1 +
                                '&bloq_menu=' + 1 +
                                '&bloqueado=' + 1 +
                                '&bloq_operador=' + operador

                            Parametros["nro_entidad"] = err.params['nro_entidad']
                            Parametros["id_tipo"] = err.params['id_tipo']
                            Parametros["nro_com_id_tipo"] = err.params['nro_com_id_tipo']
                            Parametros["nro_registro_origen"] = err.params['nro_registro']
                            Parametros["nro_com_tipo_origen"] = err.params['nro_com_tipo']
                            Parametros["nro_com_estado_origen"] = err.params['nro_com_estado']
                            Parametros["collapsed_fck"] = 1
                            Parametros["nro_circuito"] = res.getdata('nro_circuito')
                            Parametros["nro_com_grupo"] = 1
                            Parametros["bloq_menu"] = 1
                            Parametros["bloqueado"] = 1
                            Parametros["bloq_operador"] = operador

                            window.top.win = window.top.nvFW.createWindow({
                                url: url_destino,
                                title: '<b>Alta de Comentario</b>',
                                minimizable: false,
                                maximizable: false,
                                draggable: true,
                                width: 800,
                                height: 600,
                                //height: 624,
                                resizable: true,
                                destroyOnClose: true,
                                onClose: Mostrarcomentarios_return
                            });

                            window.top.win.options.userData = Parametros

                            window.top.win.showCenter()
                        }

                    }

                    rsCircuito.onError = function (res) {
                        nvFW.bloqueo_desactivar(null, 'bloq_comentario');
                        alert('Error al cargar comentario.')
                    }

                    rsCircuito.open(nvFW.pageContents.filtroCircuito, '', '', '', '<criterio><params nro_com_tipo="' + err.params['nro_com_tipo'] + '" nro_com_estado="' + err.params['nro_com_estado'] + '"/></criterio>')
                },
                bloq_msg: 'Cargando..'
            })
        }

    </script>
</head>
<body onload="window_onload()" style='width: 100%; height: 100%; overflow: hidden;'>
    <form name="frmBuscar" id="frmBuscar" style="margin: 0;" autocomplete="off">
        <table class="tb1" cellpadding="0" cellspacing="0">
            <tr class="tbLabel0">
                <td style="text-align: center; font-weight: bold !important; background-color: silver !important;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Búsqueda Cliente</td>
                <td style='width: 10%; text-align: center; background-color: silver !important;'>
                    <a id="link_historial_operador">
                        <img alt="historial" title='Mostrar Historial Operador' src='image/icons/historial.png' onclick='return operador_historial(event)' style='cursor: hand; border: none' />
                    </a>
                </td>
            </tr>
            <%-- Búsqueda por CUIT --%>
            <tr>
                <td colspan="2">
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td style="text-align: center;" colspan="3"><b>Documento</b></td>
                        </tr>
                        <tr>
                            <td style="width: 5%">
                                <input type="checkbox" title="Todos los documentos" name="checkTipdoc" id="checkTipdoc" style="cursor: pointer; vertical-align: middle" onclick="habilitar_tipdoc()" /></td>
                            <td style="width: 42.5%">
                                <script>
                                    campos_defs.add('tipodoc', {
                                        enDB: false,
                                        filtroXML: nvFW.pageContents.filtro_nomenclador_documento,
                                        nro_campo_tipo: 1
                                    });
                                </script>
                            </td>
                            <td style="width: 52.5%">
                                <%--   <% = nvFW.nvCampo_def.get_html_input("nro_docu", enDB:=False, nro_campo_tipo:=100) %>--%>
                                <script>
                                    campos_defs.add('nro_docu', {
                                        enDB: false,
                                        nro_campo_tipo: 100
                                    })
                                </script>
                            </td>
                        </tr>
                        <tr class="tbLabel">
                            <td style="text-align: center;" colspan="3" nowrap><b>Apellido y Nombres / Razón Social</b></td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <script>
                                    campos_defs.add('apenom', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                        </tr>
                        <tr class="tbLabel">
                            <td colspan="3" style="text-align: center"><b>Estado</b></td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <script>
                                    var rs = new tRS()
                                    rs.xml_format = "rs_xml_json"
                                    rs.open(nvFW.pageContents.filtroTipRel)
                                    rs.addRecord({ id: -1, campo: "Prospecto", paiscod: 54, bcocod: 312, tiporel: -1 })
                                    campos_defs.add('tiporels', {
                                        filtroXML: "", //"<criterio><select vista='Banksys..trcl_tiprelac' cn='BD_IBS_ANEXA'><campos>distinct tiporel as id, tipreldesc as [campo], paiscod, bcocod</campos><orden></orden></select></criterio>",
                                        filtroWhere: "<paiscod>%rs!paiscod%</paiscod><bcocod>%rs!bcocod%</bcocod><tiporel>%rs!tiporel%</tiporel>",
                                        nro_campo_tipo: 2, enDB: false, json: true
                                    });

                                    campos_defs.items['tiporels'].rs = rs
                                </script>
                            </td>
                        </tr>
                        <tr class="tbLabel">
                            <td colspan="3" style="text-align: center;"><b>Tipo Persona</b></td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <script>
                                    campos_defs.add('tipocli', {
                                        enDB: false,
                                        nro_campo_tipo: 1,
                                        filtroWhere: "<tipocli type='igual'>%campo_value%</tipocli>",
                                        mostrar_codigo: true
                                    })
                                    var rs = new tRS();
                                    rs.xml_format = "rsxml_json";
                                    rs.addField("id", "string")
                                    rs.addField("campo", "string")
                                    rs.addRecord({ id: "1", campo: "Persona Humana" });
                                    rs.addRecord({ id: "2", campo: "Persona Jurídica" });
                                    campos_defs.items['tipocli'].rs = rs;
                                </script>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div id="divBuscarCliente"></div>
                </td>
            </tr>
        </table>
        <%-- Fila en blanco --%>
        <br>
        <%--Reclamo--%>
        <%-- <table style="width: 100%">
            <tr>
                <td>
                    <div id="divBtnReclamo"></div>
                </td>
            </tr>
        </table>--%>
    </form>
    <%--<table class="tb1" cellpadding="0" cellspacing="0">
        <tr class="tbLabel0">
            <td style="text-align: center; font-weight: bold !important;">Búsqueda Operación</td>
        </tr>
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="text-align: center;"><b>Módulo</b></td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('cod_modulo', {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtro_nomenclador_sistema
                                });
                            </script>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td style="text-align: center;"><b>Nro. Operación</b></td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('openro', {
                                    enDB: false,
                                    nro_campo_tipo: 100
                                });
                            </script>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td style="text-align: center;"><b>Nro. Referencia</b></td>
                    </tr>
                    <tr>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("nroreferencia", enDB:=False, nro_campo_tipo:=100) %>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div id="divBuscarOperacion"></div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>--%>

    <input type="hidden" id="nro_com_grupo" value="1" />    <%--1 : cliente--%>

    <table id="tbComentario" class="tb1" cellpadding="0" cellspacing="0">
        <tr class="tbLabel0">
            <td style="text-align: center; font-weight: bold !important; background-color: silver !important;"><span style="float: left">
                <img src="/fw/image/mnusvr/mas.gif" border="0" align="absmiddle" hspace="1" id="imgFiltrosComentario" onclick="mostrar_filtros_comentario()"></span>Comentario</td>
        </tr>
        <tr style="display: none" id="trFiltrosComentario">
            <td>
                 <table class="tb1">
                    <tr class="tbLabel">
                        <td style="text-align: center"><b>Motivo</b></td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('nro_com_tipo')
                            </script>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td style="text-align: center"><b>Estado</b></td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('nro_com_estados')
                                //campos_defs.set_value('nro_com_estados', 2)
                            </script>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td style="text-align: center"><b>Fecha Desde</b></td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('fecha_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecha type='mas'>convert(datetime, '%campo_value%', 103)</fecha>"
                                });
                                campos_defs.set_value("fecha_desde", nvFW.pageContents.fecha_hoy);
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr style="display: none" id="trBuscarComentarios">
            <td>
                <div id="divBuscarComentario"></div>
            </td>
        </tr>
    </table>

    <br />
    <table id="tbPendientes" class="tb1" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <div id="divBtnPendientes"></div>
            </td>
        </tr>
    </table>
    <br />
    <table id="tbBloqueados" class="tb1" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <div id="divBtnBloqueados"></div>
            </td>
        </tr>
    </table>
    <br />
    <table id="tbCapturar" class="tb1" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <div id="divBtnCapturar"></div>
            </td>
        </tr>
    </table>
    <br />
    <table id="tbAlta" class="tb1" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <div id="divBtnAlta"></div>
            </td>
        </tr>
    </table>
</body>
</html>
