<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Me.contents("filtro_buscar_entidad_nrodoc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><nrodoc type='igual'>%nrodoc%</nrodoc><tipocli type='igual'>1</tipocli></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_nrodoc_todos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><or><nrodoc type='igual'>%nrodoc%</nrodoc><DNI type='igual'>'%nrodoc%'</DNI><CUIT_CUIL type='igual'>'%nrodoc%'</CUIT_CUIL></or><tipocli type='igual'>1</tipocli></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_cuitcuil") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><or><and><tipdoc type='igual'>%tipdoc%</tipdoc><nrodoc type='igual'>%nrodoc%</nrodoc></and><CUIT_CUIL type='igual'>'%nrodoc%'</CUIT_CUIL></or><tipocli type='igual'>1</tipocli></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_dni") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><or><and><tipdoc type='igual'>%tipdoc%</tipdoc><nrodoc type='igual'>%nrodoc%</nrodoc></and><DNI type='igual'>'%nrodoc%'</DNI></or><tipocli type='igual'>1</tipocli></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_otros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><tipdoc type='igual'>%tipdoc%</tipdoc><nrodoc type='igual'>%nrodoc%</nrodoc><tipocli type='igual'>1</tipocli></filtro><orden>razon_social</orden></select></criterio>")
    Me.contents("filtro_buscar_entidad_rz") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos><filtro><razon_social type='like'>%razon_social%</razon_social><tipocli type='igual'>1</tipocli></filtro><orden>razon_social</orden></select></criterio>")


    Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'documento'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_reclamos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.LD_circuito_reclamos' CommantTimeOut='1500'  AbsolutePage='1' expire_minutes='1' PageSize='%cantFilas%' cacheControl='Session'><parametros><nro_proceso DataType='int'>" & 354 & "</nro_proceso></parametros></procedure></criterio>")
    Me.contents("filtroTipRel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..trcl_tiprelac' cn='BD_IBS_ANEXA'><campos>distinct tiporel as id, tipreldesc as [campo], paiscod, bcocod, tiporel</campos><orden></orden></select></criterio>")


%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Buscar Cliente</title>
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

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');


        // Variables para 'cachear' elementos
        var $tipo_docu
        var $nro_docu
        var $apenom
        var $openro
        var $nroReferencia
        var winBusquedaCUIT


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

            window_onresize() 
        }

        function window_onresize() {

            var dif = Prototype.Browser.IE ? 5 : 2;

            $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('frmBuscar').getHeight() - dif + 'px' });


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

            var cantFilas = Math.floor((window.document.getElementById('frameDatos').getHeight() - 18) / 24);


            nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                bloq_contenedor: $("frameDatos"),
                path_xsl: 'report/Plantillas/HTML_buscar_entidad.xsl',
                bloq_msg: 'Buscando cliente...',
                formTarget: 'frameDatos',
                params: params,
                nvFW_mantener_origen: true
            });

        }

        function verReclamos() {

            var cantFilas = Math.floor((window.document.getElementById('frameDatos').getHeight() - 18) / 24);
            //<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro></filtro></select></criterio>
            parent.nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_reclamos,
                filtroWhere: '',
                bloq_contenedor: window.top.document.getElementById('frameDatos'),
                path_xsl: 'report/Plantillas/HTML_buscar_reclamos.xsl',
                bloq_msg: 'Buscando Reclamos...',
                formTarget: 'frameDatos',
                params: '<criterio><params cantFilas="' + cantFilas + '" /></criterio>',
                nvFW_mantener_origen: true
            });

        }

        //function cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, tiporel) {
        //    var url = '/voii/cargar_cliente.aspx?tipocli=' + tipocli + '&tipdoc=' + tipdoc + '&nrodoc=' + nrodoc
        //    if (typeof tiporel != "undefined" && tiporel != '')
        //        url += '&tiporel=' + tiporel
        //    if (nro_entidad)
        //        url += '&nro_entidad=' + nro_entidad
        //    winFramePrincipal.location.href = url;
        //}


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

        /****************** ABM CLIENTE **********************/

        function cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, tiporel) {
            //var url = '/voii/cargar_cliente.aspx?tipocli=' + tipocli + '&tipdoc=' + tipdoc + '&nrodoc=' + nrodoc
            //if (typeof tiporel != "undefined" && tiporel != '')
            //    url += '&tiporel=' + tiporel
            //if (nro_entidad)
            //    url += '&nro_entidad=' + nro_entidad
            //winFramePrincipal.location.href = url;
        
            
            var url_destino = '/voii/clientes/cliente_abm.aspx?tipdoc=' + tipdoc + '&nrodoc=' + nrodoc

            if (typeof(e) != "undefined" && e.ctrlKey == true) {
                var win = window.open(url_destino)
            } else if (typeof(e) != "undefined" && e.shiftKey) {
                // Nueva ventana de browser
                var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                newWin.moveTo(0, 0)
                newWin.resizeTo(screen.availWidth, screen.availHeight)
            } else {
                var width;
                var height;

                //if (screen.height < 800) {
                //    porcentajeHeight = 0.94;
                //    porcentajeWidth = 0.988;
                //    height = $$("body")[0].getHeight() * porcentajeHeight;
                //    width = $$("body")[0].getWidth() * porcentajeWidth;
                //    //porcentajeHeight = 0.947;
                //}
                //else {
                //    //porcentajeHeight = 0.963;
                //    //porcentajeWidth = 0.988;
                //    porcentajeHeight = 0.92;
                //    porcentajeWidth = 0.94;
                //    height = $$("body")[0].getHeight() * porcentajeHeight;
                //    width = $$("body")[0].getWidth() * porcentajeWidth;
                //}

                //var win = nvFW.createWindow({                   
                var win = top.nvFW.createWindow({
                    url: url_destino,
                    title: "<b>Cliente ABM</b>",
                    resizable: true,
                    width: 900,//width,
                    height: 600,//height,
                    onShow: function (win) {
                        
                        //var topLocation = parent.document.getElementById('tb_cab').getHeight() + (win.element.childNodes[4].getHeight() + 2);
                        //var leftLocation = ((parent.document.getElementById('tb_cab').getWidth() - win.element.childNodes[4].getWidth()) / 2);

                        //win.setLocation(topLocation, leftLocation);

                    },
                    onClose: function (win) {

                        if (win.options.userData.hay_modificacion) {
                            buscar_solicitud(0);
                            //campos_head.pagina_cambiar(campos_head.AbsolutePage)
                        }
                    }

                })

                var id = win.getId();
                focus(id);

                win.showCenter()

            }

        }

        function nueva_entidad() {
            win_abm_entidad = window.top.nvFW.createWindow({
                url: '/voii/clientes/cliente_abm.aspx',
                title: '<b>Nuevo Cliente</b>',
                minimizable: false,
                maximizable: true,
                draggable: true,
                width: 900,
                height: 600,
                resizable: true
            })

            win_abm_entidad.showCenter(true)
        }


    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style='width: 100%; height: 100%; overflow: hidden;'>
    <form name="frmBuscar" id="frmBuscar" style="margin: 0;" autocomplete="off">
        <table class="tb1" cellpadding="0" cellspacing="0">
            <tr class="tbLabel0">
                <td colspan="2" style="text-align: center; font-weight: bold !important;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Búsqueda Cliente</td>
            </tr>
            <%-- Búsqueda por CUIT --%>
            <tr>
                <td>
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td style="text-align: center; width:50%"><b>Documento</b></td>
                            <td style="text-align: center; width:50%;" nowrap><b>Apellido y Nombres</b></td>
                        </tr>
                        <tr>
                            <td>
                                <table class="tb1">
                                    <tr>
                                        <td style="width: 5%">
                                            <input type="checkbox" title="Todos los documentos" name="checkTipdoc" id="checkTipdoc" style="cursor: pointer; vertical-align: middle" onclick="habilitar_tipdoc()" />
                                        </td>
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
                                </table>
                                
                            </td>
                            <td>
                                <script>
                                    campos_defs.add('apenom', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                        </tr>
                        <tr class="tbLabel">
                            <td style="text-align: center"><b>Estado</b></td>
                        </tr>
                        <tr>
                            <td>
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
                    </table>
                </td>
                <td>
                    <div id="divBuscarCliente"></div>
                </td>
            </tr>
        </table>
        
      
    </form>
    <iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>
</body>
</html>
