<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_herramientas", 11)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Me.contents("filtro_movimientos_alarmas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_alarmas_movimientos' cn='UNIDATO'><campos>id_cliente, razon_social_cliente,razon_social, unidato_numero_alarma,anio_calc,mes_calc,mes_calc_desc,nro_tope_tipo,tope_tipo,tipo_periodo,mov_tipo_desc, mov_fecha,tit_razon_social,tit_cuitcuil,tit_gran_cliente,tit_cbu,tit_cvu,cont_razon_social,cont_cuitcuil,cont_gran_cliente,cont_cbu,cont_cvu,importe,ID_ESTADO_SECUENCIA,ESTADO_SECUENCIA,OBSERVACIONES,ID_TIPO_ALARMA,TIPO_ALARMA</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_movimientos_todos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_movimientos' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_movimientos_alarmas_agrupadas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_alarmas_estado' cn='UNIDATO'><campos>unidato_numero_alarma,razon_social_cliente,gran_cliente,cuitcuil,razon_social,mes_calc,anio_calc,fe_desde,fe_hasta,tipo_periodo,tope_tipo,id_tope,nro_tope_def,tope_def,tp,cuitcuil,ESTADO_SECUENCIA,importe_obtenido as IMPORTE_MO,calc_tope,cantidad_obtenida, FECHA_ALTA_ALARMA, FECHA_VENCIMIENTO_ALARMA, DIAS_VENCIMIENTO, nro_registro</campos><grupo></grupo><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_movimientos_alarmas_agrupadas_excel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_alarmas_estado' cn='UNIDATO'><campos>unidato_numero_alarma,razon_social_cliente as psp_razon_social,gran_cliente,tp,cuitcuil,razon_social,mes_calc,anio_calc,fe_desde,fe_hasta,tipo_periodo,ID_TIPO_ALARMA,TIPO_ALARMA,ESTADO_SECUENCIA,importe_obtenido as monto_operado,calc_tope as umbral,cantidad_obtenida as cantidad_operaciones, FECHA_ALTA_ALARMA, FECHA_VENCIMIENTO_ALARMA, DIAS_VENCIMIENTO</campos><grupo></grupo><filtro></filtro><orden></orden></select></criterio>")

    Me.contents("filtro_mes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_periodos' cn='UNIDATO'><campos>nro_periodo as [id], periodo as [campo]</campos><filtro><tipo_periodo type='igual'>'MENSUAL'</tipo_periodo></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipo_periodo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_def' cn='UNIDATO'><campos>distinct tipo_periodo as [id], tipo_periodo as [campo]</campos><filtro><NOT><tipo_periodo type='isnull'/></NOT></filtro><orden></orden></select></criterio>")


    Me.contents("filtro_tope_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPCSC_TIPO_ALARMA' cn='UNIDATO'><campos>id_tipo_alarma as [id], tipo_alarma as [campo]</campos><filtro><tipo_alarma type='like'>%psp%</tipo_alarma></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_mov_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_mov_tipos' cn='UNIDATO'><campos>mov_tipo as [id], mov_tipo_desc as [campo]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("estado_secuencia") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPCSC_ESTADO' cn='UNIDATO'><campos>id_estado as [id], estado as [campo]</campos><filtro></filtro><orden></orden></select></criterio>")

    Me.contents("filtro_sub_comentario") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro_UnidatoPSP'><campos>nro_entidad,id_tipo,nro_com_id_tipo,nro_com_estado,nro_registro, nro_com_tipo,numero_alarma</campos><filtro></filtro><orden>nro_registro desc</orden></select></criterio>")

    Me.contents("vista_topes_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psp_topes_def' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("tabla_clientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_clientes' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Alarmas Movimientos</title>
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
            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu
            Menus["pMenu"].alineacion = 'izquierda';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0' style='width:8%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>reporte</icono><Desc>Resumen</Desc><Acciones><Ejecutar Tipo='script'><Codigo>resumen()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>PSPs</Desc><Acciones><Ejecutar Tipo='script'><Codigo>alta_psp()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>personas</icono><Desc>Clientes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>alta_cliente()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>configuracion</icono><Desc>Configuración</Desc><Acciones><Ejecutar Tipo='script'><Codigo>configurar()</Codigo></Ejecutar></Acciones></MenuItem>")

            pMenu.loadImage("excel", "/voii/image/icons/excel.png");
            pMenu.loadImage("reporte", "/voii/image/icons/adminreporte.png");
            pMenu.loadImage("buscar", "/voii/image/icons/buscar.png");
            pMenu.loadImage("personas", "/voii/image/icons/personas.png");
            pMenu.loadImage("configuracion", "/voii/image/icons/edicion.png");
            pMenu.MostrarMenu();

            let vButtonItems = {};
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Buscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return btnBuscar()";
            vButtonItems[1] = {}
            vButtonItems[1]["nombre"] = "Limpiar";
            vButtonItems[1]["etiqueta"] = "Limpiar campos";
            vButtonItems[1]["imagen"] = "refresh";
            vButtonItems[1]["onclick"] = "return btnLimpiar()";

            let vListButtons = new tListButton(vButtonItems, 'vListButtons');
            vListButtons.loadImage("buscar", '/voii/image/icons/buscar.png');
            vListButtons.loadImage("refresh", '/voii/image/icons/refresh.png');
            vListButtons.MostrarListButton();

            campos_defs.set_value('id_cliente', GetCookie("psp", ""));
            cambio_vista();
            window_onresize();
        }

        function window_onresize() {
            try {
                let dif = Prototype.Browser.IE ? 10 : 0;
                let body_heigth = $$('body')[0].getHeight();
                let cab_heigth = $('tbFiltros').getHeight();
                let menu_heigth = $('divMenuPrincipal').getHeight();

                $('ver_movimientos_alarmas').setStyle({ 'height': body_heigth - cab_heigth - menu_heigth - 10 - dif + 'px' });
            }
            catch (e) { }
        }

        function filtrar() {
            let filtro = campos_defs.filtroWhere();

            if (campos_defs.get_value('anio') != "") {
                if ((tipoVista.value == "movimientosAlarmas") || (tipoVista.value == "alarmas"))
                    filtro += "<anio_calc type='igual'>" + campos_defs.get_value('anio') + "</anio_calc>";
                else if (tipoVista.value == "movimientosTodos")
                    filtro += "<anio type='igual'>" + campos_defs.get_value('anio') + "</anio>";
            }

            if (campos_defs.get_value('mes') != "") {
                if ((tipoVista.value == "movimientosAlarmas") || (tipoVista.value == "alarmas"))
                    filtro += "<mes_calc type='in'>" + campos_defs.get_value('mes') + "</mes_calc>";
                else if (tipoVista.value == "movimientosTodos")
                    filtro += "<mes type='igual'>" + campos_defs.get_value('mes') + "</mes>";
            }
    
            return filtro;
        }

        function btnBuscar() {
            if (parseFecha(campos_defs.get_value('fecha_vencimiento_desde'), 'dd/mm/yyyy') > parseFecha(campos_defs.get_value('fecha_vencimiento_hasta'), 'dd/mm/yyyy')) {
                nvFW.alert("La fecha de vencimiento desde es mayor que la fecha de vencimiento hasta.");
                return;
            }

            if (filtrar() == '' && campos_defs.get_value('limitador') == '') {
                Dialog.confirm('No estableció ningún filtro ni un limitador. ¿Desea realmente continuar?'
                    , {
                        width: 350, className: "alphacube",
                        onCancel: function (win) { win.close(); },
                        onOk: function (win) { buscar(); win.close(); },
                        okLabel: 'Si',
                        cancelLabel: 'No'
                    });
            }
            else
                buscar();
        }

        function btnLimpiar() {
            campos_defs.clear();
            win.setTitle("PLD - Movimientos PSP");
            campos_defs.set_value('limitador', 100);
            campos_defs.set_value('id_cliente', GetCookie("psp", ""));
        }

        function buscar() {
            SetCookie('psp', campos_defs.get_value('id_cliente'), 30);
            let cantFilas = $("ver_movimientos_alarmas").clientHeight / 1.5;
            let limitador = campos_defs.get_value('limitador');

            if (campos_defs.get_value('id_cliente') == '' && campos_defs.get_value('unidato_numero_alarma') == '') {
                nvFW.alert("Debe seleccionar un PSP para continuar.");
                return;
            }

            if (tipoVista.value == "movimientosAlarmas") {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_movimientos_alarmas,
                    filtroWhere: "<criterio><select top='" + limitador + "' PageSize='" + cantFilas.toFixed(0) + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtrar() + "</filtro></select></criterio>",
                    path_xsl: 'report/unidato/verNv_psp_alarmas_movimientos.xsl',
                    formTarget: 'ver_movimientos_alarmas',
                    nvFW_mantener_origen: true,
                    cls_contenedor: 'ver_movimientos_alarmas'
                });
            }
            else if (tipoVista.value == "alarmas") {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_movimientos_alarmas_agrupadas,
                    filtroWhere: "<criterio><select top='" + limitador + "' PageSize='" + cantFilas.toFixed(0) + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtrar() + "</filtro></select></criterio>",
                    path_xsl: 'report/unidato/verNv_psp_alarmas.xsl',
                    formTarget: 'ver_movimientos_alarmas',
                    nvFW_mantener_origen: true,
                    cls_contenedor: 'ver_movimientos_alarmas'
                });
            }
            else if (tipoVista.value == "movimientosTodos") {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_movimientos_todos,
                    filtroWhere: "<criterio><select top='" + limitador + "' PageSize='" + cantFilas.toFixed(0) + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtrar() + "</filtro></select></criterio>",
                    path_xsl: 'report/unidato/verNv_psp_movimientos_todos.xsl',
                    formTarget: 'ver_movimientos_alarmas',
                    nvFW_mantener_origen: true,
                    cls_contenedor: 'ver_movimientos_alarmas'
                });
            }

            win.setTitle("PLD - Movimientos PSP - " + campos_defs.get_desc("id_cliente"));
        }

        function exportar() {
            if (campos_defs.get_value('id_cliente') == '') {
                nvFW.alert("Debe seleccionar un PSP para continuar.");
                return;
            }

            if (tipoVista.value == "movimientosAlarmas") {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_movimientos_alarmas,
                    filtroWhere: filtrar(),
                    path_xsl: "report/EXCEL_base.xsl",
                    salida_tipo: "adjunto",
                    ContentType: "application/vnd.ms-excel",
                    filename: "detalle_movimientos_alarmas.xls"
                });
            }
            else if (tipoVista.value == "alarmas") {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_movimientos_alarmas_agrupadas_excel,
                    filtroWhere: filtrar(),
                    path_xsl: "report/EXCEL_base.xsl",
                    salida_tipo: "adjunto",
                    ContentType: "application/vnd.ms-excel",
                    filename: "alarmas.xls"
                });
            }
            else if (tipoVista.value == "movimientosTodos") {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_movimientos_todos,
                    filtroWhere: filtrar(),
                    path_xsl: "report/EXCEL_base.xsl",
                    salida_tipo: "adjunto",
                    ContentType: "application/vnd.ms-excel",
                    filename: "detalle_movimientos_todos.xls"
                });
            }

        }

        function resumen() {
            let win = nvFW.createWindow({
                className: 'alphacube',
                url: 'alarmas_movimientos_resumen.aspx',
                title: '<b>Resumen Definiciones de Tope</b>',
                minimizable: false,
                maximizable: false,
                resizable: true,
                draggable: true,
                width: 1000,
                height: 600,
                destroyOnClose: true

            });
            win.showCenter(true);
        }

        function onEnter(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which;
            if (key == 13)
                btnBuscar();
        }

        function alta_psp() {
            win_evento = nvFW.createWindow({
                className: 'alphacube',
                url: 'psps_listar.aspx',
                title: 'Listado PSP',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                parentWidthElement: document.body,
                parentWidthPercent: 0.95,
                parentHeightElement: document.body,
                parentHeightPercent: 0.85,
                centerHFromElement: document.body,
                centerVFromElement: document.body,
                destroyOnClose: true
            });

            win_evento.showCenter(true);
        }

        function alta_cliente() {
            let win_evento = nvFW.createWindow({
                className: 'alphacube',
                url: 'psp_clientes_listar.aspx',
                title: 'Listado Clientes',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                parentWidthElement: document.body,
                parentWidthPercent: 0.95,
                parentHeightElement: document.body,
                parentHeightPercent: 0.85,
                centerHFromElement: document.body,
                centerVFromElement: document.body,
                destroyOnClose: true
            });

            win_evento.showCenter(true);

        }

        function configurar() {
            let win_evento = nvFW.createWindow({
                className: 'alphacube',
                url: 'listar_topes_det.aspx',
                title: '<b> ABM Topes Detalle </b>',
                minimizable: true,
                maximizable: true,
                resizable: true,
                draggable: true,
                parentWidthElement: document.body,
                parentWidthPercent: 0.95,
                parentHeightElement: document.body,
                parentHeightPercent: 0.85,
                centerHFromElement: document.body,
                centerVFromElement: document.body,
                destroyOnClose: true

            });

            win_evento.showCenter(true);

        }

        function cambio_vista() {
            win.setTitle("PLD - Movimientos PSP");
            campos_defs.set_value('limitador', 100);

            if (tipoVista.value == "movimientosAlarmas") {
                campos_defs.clear('cuitcuil');
                campos_defs.habilitar('cuitcuil', false);
                campos_defs.clear('id_estado_secuencia');
                campos_defs.habilitar('id_estado_secuencia', false);

                document.getElementById('filtrosTitConRow1').hidden = false;
                document.getElementById('filtrosTitConRow2').hidden = false;
                campos_defs.habilitar('mov_tipo', true);
                campos_defs.clear('razon_social');
                campos_defs.habilitar('razon_social', false);
                campos_defs.habilitar('fecha_mov_desde', true);
                campos_defs.habilitar('fecha_mov_hasta', true);
                campos_defs.habilitar('fecha_vencimiento_desde', false);
                campos_defs.habilitar('fecha_vencimiento_hasta', false);
                campos_defs.habilitar('unidato_numero_alarma', true);
                campos_defs.habilitar('id_tipo_alarma', true);
                campos_defs.habilitar('tipo_periodo', true);
            }
            else if (tipoVista.value == "alarmas") {
                document.getElementById('filtrosTitConRow1').hidden = true;
                document.getElementById('filtrosTitConRow2').hidden = true;
                campos_defs.clear('mov_tipo');
                campos_defs.habilitar('mov_tipo', false);
                campos_defs.habilitar('razon_social', true);
                campos_defs.habilitar('fecha_vencimiento_desde', true);
                campos_defs.habilitar('fecha_vencimiento_hasta', true);
                campos_defs.clear('fecha_mov_desde');
                campos_defs.habilitar('fecha_mov_desde', false);
                campos_defs.clear('fecha_mov_hasta');
                campos_defs.habilitar('fecha_mov_hasta', false);
                campos_defs.clear('tit_cuitcuil');
                campos_defs.clear('tit_razon_social');
                campos_defs.clear('tit_cbucvu');
                campos_defs.clear('cont_cuitcuil');
                campos_defs.clear('cont_razon_social');
                campos_defs.clear('cont_cbucvu');

                document.getElementById('filtrosAlarmasRow1').hidden = false;
                document.getElementById('filtrosAlarmasRow2').hidden = false;
                campos_defs.habilitar('cuitcuil', true);
                campos_defs.habilitar('id_estado_secuencia', true);
                campos_defs.habilitar('unidato_numero_alarma', true);
                campos_defs.habilitar('id_tipo_alarma', true);
                campos_defs.habilitar('tipo_periodo', true);
            }
            else if (tipoVista.value == "movimientosTodos") {
                campos_defs.clear('cuitcuil');
                campos_defs.habilitar('cuitcuil', false);
                campos_defs.clear('id_estado_secuencia');
                campos_defs.habilitar('id_estado_secuencia', false);
                campos_defs.clear('unidato_numero_alarma');
                campos_defs.habilitar('unidato_numero_alarma', false);
                campos_defs.clear('id_tipo_alarma');
                campos_defs.habilitar('id_tipo_alarma', false);
                campos_defs.clear('razon_social');
                campos_defs.habilitar('razon_social', false);
                campos_defs.clear('tipo_periodo');
                campos_defs.habilitar('tipo_periodo', false);
                campos_defs.clear('fecha_vencimiento_desde');
                campos_defs.habilitar('fecha_vencimiento_desde', false);
                campos_defs.clear('fecha_vencimiento_hasta');
                campos_defs.habilitar('fecha_vencimiento_hasta', false);

                document.getElementById('filtrosTitConRow1').hidden = false;
                document.getElementById('filtrosTitConRow2').hidden = false;
                campos_defs.habilitar('mov_tipo', true);
                campos_defs.habilitar('fecha_mov_desde', true);
                campos_defs.habilitar('fecha_mov_hasta', true);
            }

            window_onresize();

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

        function ver_cliente(cuitcuil) {
            let id_cliente, tipo_docu, nro_docu;
            let rs = new tRS();
            let filtroWhere = "<criterio><select><filtro><cuitcuil type='igual'>'" + cuitcuil + "'</cuitcuil></filtro></select></criterio>";
            rs.open({ filtroXML: nvFW.pageContents.tabla_clientes, filtroWhere: filtroWhere });

            if (!rs.eof()) {
                id_cliente = rs.getdata('id_cliente');
                tipo_docu = rs.getdata('tipo_docu');
                nro_docu = rs.getdata('nro_docu');
            }
            else {
                nvFW.alert("Ocurrió un error. No se encuentra dicho cliente.");
                return;
            }

            let win_evento = nvFW.createWindow({
                className: 'alphacube',
                url: 'abm_psp_clientes.aspx',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                width: 800,
                height: 450,
                destroyOnClose: true
            });

            win_evento.options.userData = { modo: 'M', id_cliente: id_cliente, tipo_docu: tipo_docu, nro_docu: nro_docu }
            win_evento.showCenter(true);
        }

        function cargarSubDetalle(e, numero_alarma, nro_registro) {
            if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                window.open('/voii/unidato/alarma_detalle.aspx?numero_alarma=' + numero_alarma + '&nro_registro=' + nro_registro)
            else {
                let w = nvFW.createWindow({
                    className: 'alphacube',
                    url: '/voii/unidato/alarma_detalle.aspx?numero_alarma=' + numero_alarma + '&nro_registro=' + nro_registro,
                    title: '<b>Detalle de Alarma</b>',
                    minimizable: true,
                    maximizable: false,
                    draggable: true,
                    resizable: true,
                    destroyOnClose: true,
                    parentWidthElement: document.body,
                    parentWidthPercent: 0.95,
                    parentHeightElement: document.body,
                    parentHeightPercent: 0.9
                })

                w.showCenter(false);
            }
        }

        var winCom;
        function abrirComentario(numero_alarma, nro_registro) {
            let rs = new tRS();
            let filtroWhere = "<numero_alarma type='igual'>'" + numero_alarma + "'</numero_alarma>";
            if (nro_registro != '')
                filtroWhere += "<nro_registro type='igual'>'" + nro_registro + "'</nro_registro>"
            rs.open(nvFW.pageContents.filtro_sub_comentario, "", filtroWhere)
            if (!rs.eof()) {

                let nro_entidad = rs.getdata("nro_entidad")
                let id_tipo = rs.getdata("id_tipo")
                let nro_com_id_tipo = rs.getdata("nro_com_id_tipo")
                if (nro_registro == '')
                    nro_registro = rs.getdata("nro_registro")
                let nro_com_tipo = rs.getdata("nro_com_tipo")
                let nro_com_estado = rs.getdata("nro_com_estado")
                let w = parent.nvFW != undefined ? parent.nvFW : nvFW

                winCom = nvFW.createWindow({
                    className: 'alphacube',
                    url: '/FW/comentario/ABMRegistro.aspx?nro_entidad=' + nro_entidad + '&id_tipo=' + id_tipo + '&nro_registro_origen=' + nro_registro + '&nro_com_estado_origen=' + nro_com_estado + '&nro_com_id_tipo=' + nro_com_id_tipo + '&nro_com_tipo_origen=' + nro_com_tipo,
                    title: '<b>Alta de Comentario</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    width: 670,
                    height: 450,
                    resizable: true,
                    onClose: Mostrarcomentarios_return
                });
                winCom.showCenter(true);
            }
        }

        function Mostrarcomentarios_return() {
            if (window.top.Windows.getFocusedWindow().returnValue != undefined)
                btnBuscar();
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" onkeypress="onEnter(event)" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>

    <table class="tb1 layout_fixed" id="tbFiltros">
        <tr id="filtrosAlarmasRow1">
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">PSP
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" colspan="2">Tipo de Alarma
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Número alarma UNIDATO
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">CUIT
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" colspan="2" white-space="nowrap">Razón Social
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Tipo de período
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Año
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Mes
            </td>
        </tr>

        <tr id="filtrosAlarmasRow2">
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_cliente', {
                        enDB: true,
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('id_tipo_alarma', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tope_def,
                        filtroWhere: "<id_tipo_alarma type='in'>%campo_value%</id_tipo_alarma>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('unidato_numero_alarma', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<unidato_numero_alarma type='igual'>%campo_value%</unidato_numero_alarma>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cuitcuil', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<cuitcuil type='igual'>'%campo_value%'</cuitcuil>"
                    });
                </script>
            </td>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('razon_social', {
                        nro_campo_tipo: 104,
                        enDB: false,
                        filtroWhere: "<razon_social type='like'>%%campo_value%%</razon_social>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tipo_periodo', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipo_periodo,
                        filtroWhere: "<tipo_periodo type='in'>%campo_value%</tipo_periodo>",
                        StringValueIncludeQuote: true,
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('anio', {
                        nro_campo_tipo: 100,
                        enDB: false
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('mes', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_mes,
                        mostrar_codigo: false
                    });
                </script>
            </td>
        </tr>

        <tr>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Estado de Alarma
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Venc Alarma Desde
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Venc Alarma Hasta
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap" colspan="2">Tipo de movimiento
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Fecha de movimiento desde
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Fecha de movimiento hasta
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Cantidad de registros
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">Tipo de vista
            </td>
            <td rowspan="2" style="width: 7%;" white-space="nowrap">
                <div id="divBuscar" style="margin: 0px; padding: 1px;"></div>
                <div id="divLimpiar" style="margin: 0px; padding: 1px;"></div>
            </td>
        </tr>

        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_estado_secuencia', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.estado_secuencia,
                        filtroWhere: "<id_estado_secuencia type='in'>%campo_value%</id_estado_secuencia>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_vencimiento_desde', {
                        nro_campo_tipo: 103,
                        enDB: false,
                        filtroWhere: "<FECHA_VENCIMIENTO_ALARMA type='mas'>convert(datetime,'%campo_value%',103)</FECHA_VENCIMIENTO_ALARMA>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_vencimiento_hasta', {
                        nro_campo_tipo: 103,
                        enDB: false,
                        filtroWhere: "<FECHA_VENCIMIENTO_ALARMA type='menor'>convert(datetime,'%campo_value%',103)</FECHA_VENCIMIENTO_ALARMA>"
                    });
                </script>
            </td>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('mov_tipo', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_mov_tipo,
                        filtroWhere: "<mov_tipo type='in'>%campo_value%</mov_tipo>",
                        StringValueIncludeQuote: true
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_mov_desde', {
                        nro_campo_tipo: 103,
                        enDB: false,
                        filtroWhere: "<mov_fecha type='mas'>convert(datetime,'%campo_value%',103)</mov_fecha>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_mov_hasta', {
                        nro_campo_tipo: 103,
                        enDB: false,
                        filtroWhere: "<mov_fecha type='menor'>dateadd(dd,1,convert(datetime,'%campo_value%',103))</mov_fecha>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('limitador', {
                        nro_campo_tipo: 100,
                        enDB: false
                    });
                </script>
            </td>
            <td>
                <select name="tipoVista" id="tipoVista" style="width: 100%" onchange="cambio_vista()">
                    <option value="alarmas" selected>Vista Alarmas</option>
                    <option value="movimientosAlarmas">Vista Detalle Movimientos (Alarmas)</option>
                    <option value="movimientosTodos">Vista Detalle Movimientos (Todos)</option>
                </select>
            </td>
        </tr>

        <tr id="filtrosTitConRow1">
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">CUIT/CUIL Titular
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap" colspan="2">Razón Social Titular
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">CBU/CVU Titular
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">CUIT/CUIL Contraparte
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap" colspan="2">Razón Social Contraparte
            </td>
            <td class="Tit1" style="padding: 3px; text-align: center" white-space="nowrap">CBU/CVU Contraparte
            </td>
        </tr>

        <tr id="filtrosTitConRow2">
            <td>
                <script type="text/javascript">
                    campos_defs.add('tit_cuitcuil', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<tit_cuitcuil type='igual'>'%campo_value%'</tit_cuitcuil>"
                    });
                </script>
            </td>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('tit_razon_social', {
                        nro_campo_tipo: 104,
                        enDB: false,
                        filtroWhere: "<tit_razon_social type='like'>%%campo_value%%</tit_razon_social>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tit_cbucvu', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<or><tit_cbu type='igual'>'%campo_value%'</tit_cbu><tit_cvu type='igual'>'%campo_value%'</tit_cvu></or>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cont_cuitcuil', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<cont_cuitcuil type='igual'>'%campo_value%'</cont_cuitcuil>"
                    });
                </script>
            </td>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('cont_razon_social', {
                        nro_campo_tipo: 104,
                        enDB: false,
                        filtroWhere: "<cont_razon_social type='like'>%%campo_value%%</cont_razon_social>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cont_cbucvu', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<or><cont_cbu type='igual'>'%campo_value%'</cont_cbu><cont_cvu type='igual'>'%campo_value%'</cont_cvu></or>"
                    });
                </script>
            </td>
        </tr>

    </table>

    <iframe name="ver_movimientos_alarmas" id="ver_movimientos_alarmas" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>

</body>
</html>
