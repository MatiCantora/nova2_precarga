<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Me.contents("filtro_buscar_cuit") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_openro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_prestamos' cn='BD_IBS_ANEXA'><campos>DISTINCT paiscod, bcocod, succod, sistcod, codsubsist, moncod, cuecod, nrodoc, cliape, clinom, clisexo, clifecnac, openro, nroreferencia, nrodoc</campos><filtro></filtro><orden>openro</orden></select></criterio>")
    Me.contents("filtro_tipo_doc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_documento' cn='BD_IBS_ANEXA'><campos>tipdoc as id, sintetico as [campo]</campos><filtro><estado type='igual'>0</estado></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_nomenclador_sistema") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'sistema'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'documento'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_reclamos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.LD_circuito_reclamos' CommantTimeOut='1500'  AbsolutePage='1' expire_minutes='1' PageSize='%cantFilas%' cacheControl='Session'><parametros><nro_proceso DataType='int'>" & 354 & "</nro_proceso></parametros></procedure></criterio>")
    Me.contents("filtroTipRel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..trcl_tiprelac' cn='BD_IBS_ANEXA'><campos>distinct tiporel as id, tipreldesc as [campo], paiscod, bcocod, tiporel</campos><orden></orden></select></criterio>")

    Me.contents("filtro_acciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ids_actions'><campos>ids_actionID AS [id], ids_action AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_eventos_accion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verIDSAction_events'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_operadores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos>operador AS [id], nombre_operador AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Buscar</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        tr.tbLabel td {
            text-align: center;
            font-weight: bold !important;
        }
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
        function isEmpty(obj)
        {
            if (!obj) return true;

            if (window.Object.entries)
                return Object.entries(obj).length === 0;
            else
            {
                for (var o in obj)
                    if (obj.hasOwnProperty(o))
                        return false

                return true
            }
        }
    </script>

    <script type="text/javascript">
        //Cargar botones
        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "BuscarCliente";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscarEntidad();";

        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "IDSBuscar";
        vButtonItems[1]["etiqueta"] = "Buscar";
        vButtonItems[1]["imagen"] = "buscar";
        vButtonItems[1]["onclick"] = "return buscarEventosAccion();";

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



        function window_onload()
        {
            nvFW.enterToTab = false
            vListButton.MostrarListButton();

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

          //  winFramePrincipal = ObtenerVentana('frame_consulta')
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


        function buscarEntidad()
        {
            if ($nro_docu.value == '' && $apenom.value == '' && campos_defs.get_value('tiporels') == '' && campos_defs.get_value('tipocli') == '')
            {
                window.top.alert('Ingrese un criterio de busqueda')
                return
            }

            var filtro = '';

            if ($nro_docu.value != '')
            {
                if ($('checkTipdoc').checked)
                {
                    filtro = "<or><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc><DNI type='igual'>'" + $nro_docu.value + "'</DNI><CUIT_CUIL type='igual'>'" + $nro_docu.value + "'</CUIT_CUIL></or>"
                }
                else
                {
                    filtro += "<nrodoc type='igual'>" + $nro_docu.value + "</nrodoc>";

                    if ($tipo_docu.value != '')
                    {
                        //filtro += "<tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc>";
                        switch ($tipo_docu.value)
                        {
                            case "8":
                                if ($nro_docu.value.toString().length == 11) {
                                    filtro = "<or><and><tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc></and><CUIT_CUIL type='igual'>'" + $nro_docu.value + "'</CUIT_CUIL></or>";
                                }
                                else {
                                    window.top.alert('El CUIT ingresado debe tener 11 d�gitos.');
                                    return
                                }
                                break;


                            case "5":
                                if ($nro_docu.value.toString().length == 11) {
                                    filtro = "<or><and><tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc></and><CUIT_CUIL type='igual'>'" + $nro_docu.value + "'</CUIT_CUIL></or>";
                                }
                                else {
                                    window.top.alert('El CUIT ingresado debe tener 11 d�gitos.');
                                    return
                                }
                                break;


                            //case "70":
                            //    filtro = "<tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc>";
                            //    break;
                            
                            
                            case "1":
                                filtro = "<or><and><tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc></and><DNI type='igual'>'" + $nro_docu.value + "'</DNI></or>";
                                break;


                            default:
                                filtro = "<tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc>";
                                break;
                        }
                    }
                }
            }

            if ($apenom.value != '')
                filtro += "<sql type='sql'>upper(razon_social) like upper('%" + $apenom.value + "%')</sql>";
            //filtro += "<razon_social type='like'>%" + $apenom.value.toUpperCase() + "%</razon_social>";

            filtro += campos_defs.filtroWhere('tiporels');
            filtro += campos_defs.filtroWhere('tipocli');

            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 24);

            parent.nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_buscar_cuit,
                filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                bloq_contenedor: window.top.document.getElementById('frame_ref'),
                path_xsl: 'report/Plantillas/HTML_buscar_entidad.xsl',
                bloq_msg: 'Buscando cliente...',
                formTarget: 'frame_consulta',
                nvFW_mantener_origen: true
            });
        }


        function verReclamos()
        {
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


        function cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc) {
            var url = '/voii/cargar_cliente.aspx?tipocli=' + tipocli + '&tipdoc=' + tipdoc + '&nrodoc=' + nrodoc
            if (nro_entidad)
                url += '&nro_entidad=' + nro_entidad
            winFramePrincipal.location.href = url;
        }


        function operador_historial(e) {

            var win = window.top.nvFW.createWindow({
                async: false,
                url: '/voii/operador_historial.aspx',
                title: '<b>Historial de B�squeda</b>',
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


            //win.showCenter(true)
            win.show(false)
        }


        function habilitar_tipdoc() {
            campos_defs.clear('tipodoc');
            campos_defs.habilitar('tipodoc', $('checkTipdoc').checked == false);            
        }


        /*---------------------------------------------------------------------
        |
        |   BUSQUEDA DE EVENTOS DE ACCION
        |
        |--------------------------------------------------------------------*/
        function buscarEventosAccion()
        {
            // Pasar todos los valores a "ids_action_events.aspx"
            let operador =     campos_defs.get_value('operador');
            let ids_deviceid = campos_defs.get_value('ids_deviceid');
            let uid =          campos_defs.get_value('uid');
            let dni_cuit =     campos_defs.get_value('dni_cuit');
            let ids_actionID = campos_defs.get_value('ids_actionID').replace(/\s+/, '');
            
            // Setear el SRC del iframe derecho
            const src = '/IDS/consultas/ids_action_events.aspx?' +
                                                            'ids_actionID=' + ids_actionID +
                                                            '&operador=' + operador +
                                                            '&ids_deviceid=' + ids_deviceid +
                                                            '&uid=' + uid +
                                                            '&dni_cuit=' + dni_cuit;
            parent.$('frame_right').src = src;
        }
    </script>
</head>
<body onload="window_onload()" style='overflow: hidden;'>

    <table class="tb1" cellpadding="0" cellspacing="0">
        <tr class="tbLabel0">
            <td style="text-align: center; font-weight: bold !important;">B�squeda Cliente</td>
            <td style='width: 20px; text-align: center'>
                <a id="link_historial_operador">
                    <img alt="historial" title='Mostrar Historial Operador' src='image/icons/historial.png' onclick='return operador_historial(event)' style='cursor: pointer; border: none' />
                </a>
            </td>
        </tr>
        <%-- B�squeda por CUIT --%>
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
                            <script>
                                campos_defs.add('nro_docu', { enDB: false, nro_campo_tipo: 100 });
                            </script>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td style="text-align: center;" colspan="3" nowrap><b>Apellido y Nombres / Raz�n Social</b></td>
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
                        <td colspan="3" style="text-align: center;"><b>Tipo</b></td>
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
                                rs.addRecord({ id: "2", campo: "Persona Jur�dica" });
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

    <%-- Filas en blanco --%>
    <br/>
    <br/>
    
    <%--Reclamo--%>
    <%-- <table style="width: 100%">
        <tr>
            <td>
                <div id="divBtnReclamo"></div>
            </td>
        </tr>
    </table>--%>
    <%--</form>--%>
    <%--<table class="tb1" cellpadding="0" cellspacing="0">
        <tr class="tbLabel0">
            <td style="text-align: center; font-weight: bold !important;">B�squeda Operaci�n</td>
        </tr>
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="text-align: center;"><b>M�dulo</b></td>
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
                        <td style="text-align: center;"><b>Nro. Operaci�n</b></td>
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


    <!-- NUEVO BUSCADOR DE IDS -->
    <table class="tb1" cellspacing="0" cellpadding="0">
        <tr class="tbLabel0">
            <td style="text-align: center; font-weight: bold !important;">B�squeda Eventos</td>
        </tr>

        <tr>
            <td>
                <table class="tb1">

                    <!-- Filtro Operador -->
                    <tr class="tbLabel">
                        <td colspan="2">Operador</td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <script type="text/javascript">
                                campos_defs.add('operador', {
                                    enDB:           false,
                                    nro_campo_tipo: 3,
                                    placeholder:    'Seleccionar Operador',
                                    filtroXML:      nvFW.pageContents.filtro_operadores,
                                    filtroWhere:    "<operador>%campo_value%</operador>",
                                    campo_codigo:   'operador',
                                    campo_desc:     'nombre_operador',
                                    mostrar_codigo: false
                                });
                            </script>
                        </td>
                    </tr>

                    <!-- Filtro Dispositivo -->
                    <tr class="tbLabel">
                        <td colspan="2">Dispositivo</td>
                    </tr>
                    <tr>
                        <td class="Tit1" title="Puede utilizar * como comod�n para la b�squeda">ID</td>
                        <td title="Puede utilizar * como comod�n para la b�squeda">
                            <script type="text/javascript">
                                campos_defs.add('ids_deviceid', { enDB: false, nro_campo_tipo: 104, placeholder: 'ID del Dispositivo' });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="Tit1">Usuario</td>
                        <td>
                            <script type="text/javascript">
                                campos_defs.add('uid', {
                                    enDB:           false,
                                    nro_campo_tipo: 104,
                                    placeholder:    'Usuario del Dispositivo',
                                    filtroWhere:    "<uid type='like'>%%campo_value%%</uid>"
                                });
                            </script>
                        </td>
                    </tr>

                    <!-- Filtro Identidad -->
                    <tr class="tbLabel">
                        <td colspan="2">Identidad</td>
                    </tr>
                    <tr>
                        <td class="Tit1">DNI-CUIT</td>
                        <td>
                            <script type="text/javascript">
                                campos_defs.add('dni_cuit', {
                                    enDB:           false,
                                    nro_campo_tipo: 100,
                                    placeholder:    'Nro. de Documento',
                                    filtroWhere:    "<or><nro_docu>%campo_value%</nro_docu><cuit>'%campo_value%'</cuit></or>"
                                });
                            </script>
                        </td>
                    </tr>

                    <!-- Filtro Acciones -->
                    <tr class="tbLabel">
                        <td colspan="2">Acciones</td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <script type="text/javascript">
                                campos_defs.add('ids_actionID', {
                                    enDB:           false,
                                    nro_campo_tipo: 2,
                                    filtroXML:      nvFW.pageContents.filtro_acciones,
                                    filtroWhere:    "<ids_actionID type='igual'>%campo_value%</ids_actionID>",
                                    mostrar_codigo: false,
                                    placeholder:    'Seleccionar Acci�n'
                                });
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <tr>
            <td>
                <div id="divIDSBuscar"></div>
            </td>
        </tr>
    </table>

</body>
</html>
