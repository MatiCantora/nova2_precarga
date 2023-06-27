<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Me.contents("vista_topes_det") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psp_topes_det' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("vista_topes_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psp_topes_def' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("nro_tope_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_def' cn='UNIDATO'><campos>nro_tope_def as id, tope_def as campo</campos><orden>tope_def</orden><filtro><vigente type='igual'>1</vigente></filtro></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Listar Topes Detalle</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();

        function window_onload() {
            cargar_datos();

            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu;
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>definiciones</icono><Desc>Ver Definiciones</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ver_definiciones()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_como</icono><Desc>Guardar cómo..</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_como()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_topes_det()</Codigo></Ejecutar></Acciones></MenuItem>")
            pMenu.loadImage("excel", "../image/icons/excel.png");
            pMenu.loadImage("nuevo", "../image/icons/nueva.png");
            pMenu.loadImage("guardar_como", "../image/icons/guardar_como.png");
            pMenu.loadImage("definiciones", "../image/icons/file_txt.png");
            pMenu.MostrarMenu();

            var vButtonItems = [];
            vButtonItems[0] = [];
            vButtonItems[0]["nombre"] = "Menu";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            var vListButtons = new tListButton(vButtonItems, 'vListButtons');
            vListButtons.loadImage("buscar", '../image/icons/buscar.png');
            vListButtons.MostrarListButton();

            campos_defs.set_value('id_cliente', GetCookie("psp", ""));
            document.getElementById('vigente').value = 0;
            window_onresize();
        }

        function window_onresize() {
            try {
                let dif = Prototype.Browser.IE ? 10 : 0;
                let body_heigth = $$('body')[0].getHeight();
                let cab_heigth = $('tbFiltros').getHeight();
                let menu_heigth = $('divMenuPrincipal').getHeight();

                $('ver_lote').setStyle({ 'height': body_heigth - cab_heigth - menu_heigth - dif + 'px' });
            }
            catch (e) { }
        }

        function cargar_datos() {
            if (win.options.userData != undefined) {
                campos_defs.set_value('cuitcuil', win.options.userData.cuitcuil);
                campos_defs.set_value('id_cliente', win.options.userData.id_cliente);
                buscar();
            }
        }

        function filtrar() {             
            let filtro = campos_defs.filtroWhere();

            if (document.getElementById('gran_cliente').value == 0)
                filtro += "<gran_cliente type='igual'>0</gran_cliente>";

            if (document.getElementById('gran_cliente').value == 1)
                filtro += "<gran_cliente type='igual'>1</gran_cliente>";

            if (document.getElementById('tipo_persona').value == "PH")
                filtro += "<tipo_persona type='igual'>'PH'</tipo_persona>";

            if (document.getElementById('tipo_persona').value == "PJ")
                filtro += "<tipo_persona type='igual'>'PJ'</tipo_persona>";

            if (document.getElementById('vigente').value == 0)
                filtro += "<no_vigente type='igual'>0</no_vigente>"

            if (document.getElementById('vigente').value == 1)
                filtro += "<no_vigente type='igual'>1</no_vigente>"
            
            return filtro;
        }

        function buscar() {
            if (campos_defs.get_value('id_cliente') == '') {
                nvFW.alert("Debe seleccionar un PSP");
                return;
            }

            win.setTitle("ABM Topes Detalle - " + campos_defs.get_desc("id_cliente"));

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.vista_topes_det,
                filtroWhere: "<criterio><select><filtro>" + filtrar() + "</filtro></select></criterio>",
                path_xsl: 'report/unidato/verNv_psp_topes_det.xsl',
                formTarget: 'ver_lote',
                nvFW_mantener_origen: true,
                cls_contenedor: 'ver_lote'
            });

        }

        function exportar() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.vista_topes_det,
                filtroWhere: "<criterio><select><filtro>" + filtrar() + "</filtro></select></criterio>",
                path_xsl: "report/EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "nv_topes_det.xls"
            });
        }

        function guardar_como() {
            let id_psp_from = campos_defs.get_value('id_cliente');
            if (id_psp_from == '') {
                nvFW.alert("No hay seleccionado ningún PSP del cual tomar los detalles de tope.");
                return;
            }

            let win_gc = new window.Window({
                className: 'alphacube',
                url: 'topes_det_lote.aspx',
                title: '<b>Copiar Topes Detalle para nuevo PSP</b>',
                minimizable: false,
                maximizable: false,
                resizable: true,
                draggable: true,
                parentWidthElement: document.body,
                parentWidthPercent: 0.30,
                parentHeightElement: document.body,
                parentHeightPercent: 0.40,
                centerHFromElement: document.body,
                centerVFromElement: document.body,
                destroyOnClose: true
            });

            win_gc.options.userData = { id_psp_from: id_psp_from, desc_psp_from: campos_defs.get_desc('id_cliente'), modo: 2 };
            win_gc.showCenter(true);
        }

        function abm_topes_det() {
            let win = nvFW.createWindow({
                className: 'alphacube',
                url: 'abm_topes_det.aspx',
                title: '<b>ABM Tope Det</b>',
                minimizable: false,
                maximizable: false,
                resizable: false,
                draggable: true,
                width: 700,
                height: 400,
                destroyOnClose: true,
                onClose: function () {
                    if (win.options.userData.hay_modificacion)
                        buscar();
                }
            });

            win.options.userData = { modo: 'A', hay_modificacion: false };
            win.showCenter();
        }

        function editar(modo, nro_tope_def, id_cliente, tipo_persona, gran_cliente, proporcion_tope, fecha_alta, nv_login, nro_topes_det = '', fecha_baja = '', cuitcuil = '') {
            if ((modo == 'M' || modo == 'B') && (nro_topes_det == '')) {
                nvFW.alert("Se solicitó modificar o dar de baja un registro sin indicar cuál correctamente");
            }
            let win = nvFW.createWindow({
                className: 'alphacube',
                url: '/voii/unidato/abm_topes_det.aspx',
                title: '<b>Editar Tope Det</b>',
                minimizable: false,
                maximizable: false,
                resizable: false,
                draggable: true,
                width: 700,
                height: 400,
                destroyOnClose: true,
                onClose: function () {
                    if (win.options.userData.hay_modificacion)
                        buscar();
                }

            });

            win.options.userData = { modo: modo, hay_modificacion: false, nro_tope_def: nro_tope_def, id_cliente: id_cliente, cuitcuil: cuitcuil, tipo_persona: tipo_persona, gran_cliente: gran_cliente, proporcion_tope: proporcion_tope, fecha_alta: fecha_alta, nv_login: nv_login, nro_topes_det: nro_topes_det, fecha_baja: fecha_baja }
            win.showCenter();
        }

        function ver_definiciones() {
            let win = nvFW.createWindow({
                className: 'alphacube',
                url: '/voii/unidato/listar_def_topes.aspx',
                title: '<b>Listado Definiciones de Tope</b>',
                minimizable: false,
                maximizable: false,
                resizable: false,
                draggable: true,
                parentWidthElement: document.body,
                parentWidthPercent: 0.95,
                parentHeightElement: document.body,
                parentHeightPercent: 0.90,
                centerHFromElement: document.body,
                centerVFromElement: document.body,
                destroyOnClose: true
            });

            win.showCenter(true);
        }

        function ver_tope_def(nro_tope_def) {
            let tope_def, nro_tope_tipo, nro_tope, vigente, tipo_periodo, id_tipo_alarma, origen, tipos_movs, movs_propios;
            let rs = new tRS();
            let filtroWhere = "<criterio><select><filtro><nro_tope_def type='igual'>'" + nro_tope_def + "'</nro_tope_def></filtro></select></criterio>";
            rs.open({ filtroXML: nvFW.pageContents.vista_topes_def, filtroWhere: filtroWhere });

            if (!rs.eof()) {
                tope_def = rs.getdata('tope_def');
                nro_tope_tipo = rs.getdata('nro_tope_tipo');
                nro_tope = rs.getdata('nro_tope');
                vigente = rs.getdata('vigente');
                tipo_periodo = rs.getdata('tipo_periodo');
                id_tipo_alarma = rs.getdata('id_tipo_alarma');
                origen = rs.getdata('origen');
                tipos_movs = rs.getdata('tipos_movs');
                movs_propios = rs.getdata('movs_propios ');
            }
            else {
                nvFW.alert("Ocurrió un error. No se encuentra dicha definición.");
                return;
            }

            let win_plantilla = nvFW.createWindow({
                className: 'alphacube',
                url: '/voii/unidato/abm_def_topes.aspx',
                title: 'Editar Definición de Tope',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                width: 700,
                height: 350,
                destroyOnClose: true
            });

            win_plantilla.options.userData = { nro_tope_def: nro_tope_def, tope_def: tope_def, nro_tope_tipo: nro_tope_tipo, nro_tope: nro_tope, vigente: vigente, tipo_periodo: tipo_periodo, id_tipo_alarma: id_tipo_alarma, modo: 'M', origen: origen, tipos_movs: tipos_movs, movs_propios: movs_propios }
            win_plantilla.showCenter(true);
        }

        function onEnter(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which;
            if (key == 13)
                buscar();
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" onkeypress="onEnter(event)" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>

    <table id="tbFiltros" class="tb1">
        <tr>
            <td class="Tit1" style="text-align:center; white-space:nowrap">
                PSP
            </td>
            <td class="Tit1" style="text-align:center; white-space:nowrap">
                Tope Def
            </td>
             <td class="Tit1" style="text-align:center; white-space:nowrap">
                CUIT/CUIL
            </td>
            <td class="Tit1" style="text-align:center; white-space:nowrap">
                Tipo persona
            </td>
            <td class="Tit1" style="text-align:center; width:5%; white-space:nowrap" title="Gran Cliente">
                Gran Cliente
            </td>
            <td class="Tit1" style="text-align:center; width:5%; white-space:nowrap" title="Vigencia">
                Vigencia
            </td>
            <td rowspan="4" style="width:10%; white-space:nowrap">
                <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
            </td>
        </tr>
        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_cliente', {
                        enDB: true,
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    //campos_defs.add('nro_tope_def', { enDB: true });
                    campos_defs.add('nro_tope_def', {
                        enDB: false,
                        nro_campo_tipo: 2,
                        filtroXML: nvFW.pageContents.nro_tope_def,
                        filtroWhere: "<nro_tope_def type='in'>%campo_value%</nro_tope_def>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cuitcuil', { nro_campo_tipo: 100, enDB: false, filtroWhere: "<cuitcuil type='igual'>%campo_value%</cuitcuil>" });
                </script>
            </td>
            <td>
                <select name="tipo_persona" id="tipo_persona" style="width:100%">
                    <option value=""></option>
                    <option value="PH">Persona Humana </option>
                    <option value="PJ">Persona Jurídica </option>
                </select>
            </td>
            <td style="text-align: center; width: 10%;">
                <select name="gran_cliente" id="gran_cliente" style="width:100%">
                    <option value="-1"></option>
                    <option value="0">No </option>
                    <option value="1">Si </option>
                </select>
            </td>
            <td style="text-align: center; width: 10%;">
                <select name="vigente" id="vigente" style="width:100%">
                    <option value="-1">Todos</option>
                    <option value="0">Solo vigentes </option>
                    <option value="1">No vigentes</option>
                </select>
            </td>
        </tr>    
    </table>

    <iframe name="ver_lote" id="ver_lote" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>

</body>
</html>
