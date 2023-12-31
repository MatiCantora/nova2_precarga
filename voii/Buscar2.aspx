<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Me.contents("filtro_buscar_cuit") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_openro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_prestamos' cn='BD_IBS_ANEXA'><campos>DISTINCT paiscod, bcocod, succod, sistcod, codsubsist, moncod, cuecod, nrodoc, cliape, clinom, clisexo, clifecnac, openro, nroreferencia, nrodoc</campos><filtro></filtro><orden>openro</orden></select></criterio>")
    Me.contents("filtro_tipo_doc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_documento' cn='BD_IBS_ANEXA'><campos>tipdoc as id, sintetico as [campo]</campos><filtro><estado type='igual'>0</estado></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_nomenclador_sistema") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'sistema'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'documento'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")



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


        function window_onload() {

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
                window.top.alert('Ingrese un criterio de busqueda')
                return
            }

            var filtro = '';

            if ($nro_docu.value != '') {
                filtro += "<nrodoc type='igual'>" + $nro_docu.value + "</nrodoc>";
                if ($tipo_docu.value != '') {
                    //filtro += "<tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc>";
                    switch ($tipo_docu.value) {                        
                        case "8":
                            if ($nro_docu.value.toString().length == 11) {
                                filtro = "<or><and><tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc></and><CUIT_CUIL type='igual'>'" + $nro_docu.value + "'</CUIT_CUIL></or>";
                            } else { window.top.alert('El CUIT ingresado debe tener 11 d�gitos.'); return }
                            break;
                        case "5":
                            if ($nro_docu.value.toString().length == 11) {
                                filtro = "<or><and><tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc></and><CUIT_CUIL type='igual'>'" + $nro_docu.value + "'</CUIT_CUIL></or>";
                            } else { window.top.alert('El CUIT ingresado debe tener 11 d�gitos.'); return }
                            break;
                        case "70":
                            filtro = "<tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc>";
                            break;
                        case "1":
                                filtro = "<or><and><tipdoc type='igual'>" + $tipo_docu.value + "</tipdoc><nrodoc type='igual'>" + $nro_docu.value + "</nrodoc></and><DNI type='igual'>'" + $nro_docu.value + "'</DNI></or>";
                            break;
                    }
                }

            }

            if ($apenom.value != '')
                filtro += "<sql type='sql'>upper(razon_social) like upper('%" + $apenom.value + "%')</sql>";
            //filtro += "<razon_social type='like'>%" + $apenom.value.toUpperCase() + "%</razon_social>";

            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 24);


            parent.nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_buscar_cuit,
                filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                bloq_contenedor: window.top.document.getElementById('frame_ref'),
                path_xsl: 'report/Plantillas/HTML_buscar_entidad.xsl',
                bloq_msg: 'Buscando cliente...',
                formTarget: 'frame_consulta',
                nvFW_mantener_origen: true
            })

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


    </script>
</head>
<body onload="window_onload()" style='width: 100%; height: 100%; overflow: hidden;'>
    <form name="frmBuscar" id="frmBuscar" style="margin: 0;" autocomplete="off">
        <table class="tb1" cellpadding="0" cellspacing="0">
            <tr class="tbLabel0">
                <td style="text-align: center; font-weight: bold !important;">B�squeda Cliente</td>
            </tr>
            <%-- B�squeda por CUIT --%>
            <tr>
                <td>
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td style="text-align: center;" colspan="2"><b>Documento</b></td>
                        </tr>
                        <tr>
                            <td style="width: 40%">
                                <script>
                                    campos_defs.add('tipodoc', {
                                        enDB: false,
                                        filtroXML: nvFW.pageContents.filtro_nomenclador_documento,
                                        nro_campo_tipo: 1
                                    });
                                </script>
                            </td>
                            <td style="width: 60%">
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
                            <td style="text-align: center;" colspan="2" nowrap><b>Apellido y Nombres / Raz�n Social</b></td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <script>
                                    campos_defs.add('apenom', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>

                    <div id="divBuscarCliente"></div>
                </td>
            </tr>
        </table>
        <%-- Fila en blanco --%>
        <table>
            <tr>
                <td>&nbsp;</td>
            </tr>
        </table>
    </form>
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
</body>
</html>
