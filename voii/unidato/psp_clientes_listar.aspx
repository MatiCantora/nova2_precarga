<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 5)) Then
        Response.Redirect("/FW/error/httpError_403.aspx")
    End If

    Me.contents("filtro_psp_clientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_clientes' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden>razon_social</orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>PSP Clientes</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        function window_onload() {
            campos_defs.set_value('id_cliente', GetCookie("psp", ""));
            window_onresize();
            cargar_menu();
        }

        function window_onresize() {
            try {
                let dif = Prototype.Browser.IE ? 3 : 6,
                    body_h = $$('body')[0].getHeight(),
                    divCabecera_height = $('divCabecera').getHeight();
                divMenu_height = $('divMenu').getHeight();

                $('ver_listado_clientes_psp').setStyle({ 'height': body_h - divCabecera_height - divMenu_height - dif + 'px' });
            }
            catch (e) { }

        }

        function cargar_menu() {
            Menu = new tMenu('divMenuCab', 'Menu');

            Menus["Menu"] = Menu;
            Menus["Menu"].alineacion = "centro";
            Menus["Menu"].estilo = "A";

            Menu.loadImage("excel", "/voii/image/icons/excel.png");
            Menu.loadImage("nuevo", "/voii/image/icons/nueva.png");
            Menu.loadImage("personas", "/voii/image/icons/entidad_grupo.png");

            Menus["Menu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>personas</icono><Desc>Importar en Lista Aceptación</Desc><Acciones><Ejecutar Tipo='script'><Codigo>transf_imp_masiva()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["Menu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["Menu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportar()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["Menu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editar_cliente()</Codigo></Ejecutar></Acciones></MenuItem>");

            Menu.MostrarMenu();

            var vButtonItems = [];
            vButtonItems[0] = [];
            vButtonItems[0]["nombre"] = "Menu";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            var vListButtons = new tListButton(vButtonItems, 'vListButtons');
            vListButtons.loadImage("buscar", '../image/icons/buscar.png');
            vListButtons.MostrarListButton();
        }

        function editar_cliente(modo = 'A', id_cliente = '', tipo_docu = '', nro_docu = '') {
            win_evento = nvFW.createWindow({
                className: 'alphacube',
                url: 'abm_psp_clientes.aspx',
                title: 'Editar Cliente',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                width: 800,
                height: 450,
                destroyOnClose: true,
                onClose: function (win_evento) {
                    if (win_evento.options.userData.hay_modificacion)
                        buscar();
                }
            });

            win_evento.options.userData = { modo: modo, id_cliente: id_cliente, tipo_docu: tipo_docu, nro_docu: nro_docu, hay_modificacion: false };
            win_evento.showCenter(true);
        }

        function exportar() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_psp_clientes,
                filtroWhere: "<criterio><select><filtro>" + filtrar() + "</filtro></select></criterio>",
                path_xsl: 'report/EXCEL_base.xsl',
                formTarget: 'ver_listado_clientes_psp',
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "nv_psp_clientes.xls"
            });

        }

        function buscar() {
            if (filtrar() == '') {
                nvFW.alert("Seleccione al menos un filtro para hacer la búsqueda.");
                return;
            }

            var cantFilas = $("ver_listado_clientes_psp").clientHeight / 1.5;

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_psp_clientes,
                filtroWhere: "<criterio><select PageSize='" + cantFilas.toFixed(0) + "' AbsolutePage='1'><filtro>" + filtrar() + "</filtro></select></criterio>",
                path_xsl: 'report/unidato/nv_psp_clientes.xsl',
                formTarget: 'ver_listado_clientes_psp',
                nvFW_mantener_origen: true,
                async: true,
                cls_contenedor: 'ver_listado_clientes_psp',
                cls_contenedor_msg: 'Cargando',
                funComplete: function (response, parseError) {
                    nvFW.bloqueo_desactivar($(document.body), 'buscar');
                    window_onresize();
                }
            });
        }

        function filtrar() {
            let filtro = campos_defs.filtroWhere();

            if (document.getElementById("tipo_persona").value != '')
                filtro += "<tipo_persona type='igual'>'" + document.getElementById("tipo_persona").value + "'</tipo_persona>";

            if (document.getElementById("gran_cliente").value == '1')
                filtro += "<gran_cliente type='igual'>" + document.getElementById("gran_cliente").value + "</gran_cliente>";
            else if (document.getElementById("gran_cliente").value == '0')
                filtro += "<or><gran_cliente type='isnull'></gran_cliente><gran_cliente type='igual'>" + document.getElementById("gran_cliente").value + "</gran_cliente></or>";

            return filtro;
        }

        function eliminar(id_cliente = '', tipo_docu = '', nro_docu = '') {
            Dialog.confirm('¿Realmente desea eliminar?', {
                width: 300, className: "alphacube",
                onOk: function (win) {
                    nvFW.error_ajax_request('abm_psp_clientes.aspx', {
                        parameters:
                        {
                            modo: 'B',
                            id_cliente: id_cliente,
                            tipo_docu: tipo_docu,
                            nro_docu: nro_docu,
                        },
                        onSuccess: function (err, transport) {
                            buscar();
                        }
                    });

                    win.close()

                },
                onCancel: function (win) {
                    win.close();
                },

                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar'
            });
        }

        function ventana_historico(id_cliente, cuitcuil) {
            win_evento = nvFW.createWindow({
                className: 'alphacube',
                url: 'historial_psp_clientes.aspx',
                title: 'Historial Cliente',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                width: 800,
                height: 450,
                destroyOnClose: true
            });

            win_evento.options.userData = { id_cliente: id_cliente, cuitcuil: cuitcuil };
            win_evento.showCenter();
        }

        function ventana_aceptacion(id_cliente, cuitcuil) {
            win_evento = nvFW.createWindow({
                className: 'alphacube',
                url: 'topes_det_lote.aspx',
                title: 'Agregar a Lista Aceptacion',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                parentWidthElement: document.body,
                parentWidthPercent: 0.30,
                parentHeightElement: document.body,
                parentHeightPercent: 0.40,
                centerHFromElement: document.body,
                centerVFromElement: document.body,
                destroyOnClose: true,
                onClose: function (win_evento) {
                    //if (win_evento.options.userData.hay_modificacion)
                    buscar();
                }
            });

            win_evento.options.userData = { id_psp_from: id_cliente, cuitcuil: cuitcuil, modo: 1 };
            win_evento.showCenter();
        }

        function transf_imp_masiva() {

            nvFW.transferenciaEjecutar({
                id_transferencia: 10001437,
                //pasada: 0,
                formTarget: 'winPrototype',
                async: false,
                //ej_mostrar: true,
                winPrototype: {
                    modal: true,
                    center: true,
                    bloquear: false,
                    url: '/fw/enBlanco.htm',
                    title: '<b>Transferencia Importación Masiva a Lista de Aceptación</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 900,
                    height: 400,
                    resizable: true,
                    destroyOnClose: true
                }
            })
        }


        function onEnter(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which;
            if (key == 13)
                buscar();
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" onkeypress="onEnter(event)" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuCab"></div>

    <table id="divCabecera" class="tb1" width="100%">
        <tr>
            <td class="Tit1" style="text-align: center; white-space: nowrap">PSP </td>
            <td class="Tit1" style="text-align: center; white-space: nowrap">Tipo documento </td>
            <td class="Tit1" style="text-align: center; white-space: nowrap">Nro Documento </td>
            <td class="Tit1" style="text-align: center; white-space: nowrap">CUIT/CUIL </td>
            <td class="Tit1" style="text-align: center; white-space: nowrap">Razón social </td>
            <td class="Tit1" style="text-align: center; white-space: nowrap">Tipo persona </td>
            <td class="Tit1" style="text-align: center; white-space: nowrap">Gran cliente </td>
            <td rowspan="2" style="width: 5%; white-space: nowrap">
                <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
            </td>
        </tr>

        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_cliente', { enDB: true, mostrar_codigo: false })
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('unidato_tipo_doc', {
                        enDB: true,
                        filtroWhere: "<tipo_docu type='in'>%campo_value%</tipo_docu>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_docu', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<nro_docu type='igual'>'%campo_value%'</nro_docu>"
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
            <td>
                <script type="text/javascript">
                    campos_defs.add('razon_social', {
                        nro_campo_tipo: 104,
                        enDB: false,
                        filtroWhere: "<razon_social type='like'>%%campo_value%%</razon_social>"
                    });
                </script>
            </td>
            <td>
                <select name="tipo_persona" id="tipo_persona" style="width: 100%">
                    <option value=""></option>
                    <option value="PH">Persona Humana </option>
                    <option value="PJ">Persona Jurídica </option>
                </select>
            </td>
            <td>
                <select name="gran_cliente" id="gran_cliente" style="width: 100%">
                    <option value=""></option>
                    <option value="1">Si</option>
                    <option value="0">No</option>
                </select>
            </td>
        </tr>
    </table>

    <iframe name="ver_listado_clientes_psp" id="ver_listado_clientes_psp" style="width: 100%; height: 80%; overflow: hidden;" frameborder="0"></iframe>

</body>
</html>
