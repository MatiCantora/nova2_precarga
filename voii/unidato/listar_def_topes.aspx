<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 3)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Me.contents("vista_topes_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psp_topes_def' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipo_tope") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_tipos' cn='UNIDATO'><campos>nro_tope_tipo as [id], tope_tipo as [campo]</campos><filtro><NOT><nro_tope_tipo type='isnull'/></NOT></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipo_periodo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_def' cn='UNIDATO'><campos>distinct tipo_periodo as [id], tipo_periodo as [campo]</campos><filtro><NOT><tipo_periodo type='isnull'/></NOT></filtro><orden></orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Definición de Topes</title>
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
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>tipos_tope</icono><Desc>Ver Tipos Topes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ver_tipos_topes()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
            pMenu.loadImage("excel", "../image/icons/excel.png");
            pMenu.loadImage("nuevo", "../image/icons/nueva.png");
            pMenu.loadImage("tipos_tope", "../image/icons/modulo1.png");

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
            window_onresize();
        }

        function window_onresize() {
            try {
                let dif = Prototype.Browser.IE ? 10 : 0;
                let body_heigth = $$('body')[0].getHeight();
                let cab_heigth = $('tbFiltros').getHeight();
                let menu_heigth = $('divMenuPrincipal').getHeight();

                $('ver_defs').setStyle({ 'height': body_heigth - cab_heigth - menu_heigth - dif + 'px' });
            }
            catch (e) { }
        }

        function filtrar() {
            let filtro = campos_defs.filtroWhere();

            if (document.getElementById('vigente').value == 0)
                filtro += "<vigente>0</vigente>";

            if (document.getElementById('vigente').value == 1)
                filtro += "<vigente>1</vigente>";

            return filtro;
        }

        function buscar() {
            let cantFilas = $("ver_defs").clientHeight / 22.6;

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.vista_topes_def,
                filtroWhere: "<criterio><select PageSize='" + cantFilas.toFixed(0) + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtrar() + "</filtro></select></criterio>",
                path_xsl: 'report/unidato/verNv_psp_def_topes.xsl',
                formTarget: 'ver_defs',
                nvFW_mantener_origen: true,
                cls_contenedor: 'ver_defs'
            });

        }

        function exportar() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.vista_topes_def,
                filtroWhere: "<criterio><select><filtro>" + filtrar() + "</filtro></select></criterio>",
                path_xsl: "report/EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "nv_def_topes.xls"
            });
        }

        function nuevo() {
            let win = nvFW.createWindow({
                className: 'alphacube',
                url: 'abm_def_topes.aspx',
                title: '<b>Nueva definición</b>',
                minimizable: false,
                maximizable: false,
                resizable: false,
                draggable: true,
                width: 700,
                height: 350,
                destroyOnClose: true,
                onClose: function (win) {
                    //buscar();
                    if (win.options.userData.hay_modificacion) {
                        buscar();
                    }
                }
            });

            win.options.userData = { nro_tope_def: "", hay_modificacion: false };
            win.showCenter();
        }

        function eliminar(nro_tope_def) {       
            let rs = new tRS();
            let filtroWhere = "<criterio><select><filtro><nro_tope_def type='igual'>" + nro_tope_def + "</nro_tope_def><vigente type='igual'>1</vigente></filtro></select></criterio>";
            rs.open({ filtroXML: nvFW.pageContents.vista_topes_def, filtroWhere: filtroWhere });

            if (rs.eof()) {
                nvFW.alert("Dicha definición ya se encuentra dada de baja. ");
                return;
            }

            Dialog.confirm('¿Realmente desea dar de baja?', {
                width: 300, className: "alphacube",
                onOk: function (win) {
                    nvFW.error_ajax_request('abm_def_topes.aspx', {
                        parameters:
                        {
                            modo: 'B',
                            nro_tope_def: nro_tope_def
                        },
                        onSuccess: function (err, transport) {
                            nvFW.alert("Se ha quitado la vigencia de la definición con éxito.");
                            buscar();
                        }
                    });
                     
                    win.close();
                },
                onCancel: function (win) {
                    win.close();
                },

                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar'
            });
        }

        function ver_tipos_topes() {
            let win = nvFW.createWindow({
                className: 'alphacube',
                url: '/voii/unidato/listar_tipos_topes.aspx',
                title: '<b>Tipos de Topes</b>',
                minimizable: false,
                maximizable: false,
                resizable: true,
                draggable: true,
                width: 700,
                height: 450,
                destroyOnClose: true

            });

            win.showCenter(true);
        }

        //function abm_topes_det() {
        //    let win = new window.Window({
        //        className: 'alphacube',
        //        url: 'abm_topes_det.aspx',
        //        title: '<b>Editar Tope Det</b>',
        //        minimizable: false,
        //        maximizable: false,
        //        resizable: false,
        //        draggable: true,
        //        width: 400,
        //        height: 200,
        //        destroyOnClose: true
                
        //    });
        //    win.showCenter(true);
        //}

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
            <td class="Tit1" style="text-align:center; white-space:nowrap" title="Tipo de tope">
                Tipo tope
            </td>
             <td class="Tit1" style="text-align:center; white-space:nowrap" title="Número de tope">
                Nro tope
            </td>
            <td class="Tit1" style="text-align:center; white-space:nowrap" title="Definición de tope">
                Definición de tope
            </td>
            <td class="Tit1" style="text-align:center; white-space:nowrap" title="Fecha de alta">
                Fecha de alta
            </td>
            <td class="Tit1" style="text-align:center; white-space:nowrap" title="Tipo de período">
                Tipo de período
            </td>
            <%--<td class="Tit1" style="text-align:center; white-space:nowrap" title="Tipo de movimientos">
                Movs tipo
            </td>--%>
            <td class="Tit1" style="text-align:center; width:5%; white-space:nowrap" title="¿Está vigente?">
                Vigente
            </td>
            <td rowspan="2" style="width:10%; white-space:nowrap">
                <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
            </td>
        </tr>
        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tope_tipo', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipo_tope,
                        filtroWhere: "<nro_tope_tipo type='in'>%campo_value%</nro_tope_tipo>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_tope', {
                        nro_campo_tipo: 104,
                        enDB: false,
                        filtroWhere: "<nro_tope type='like'>%%campo_value%%</nro_tope>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tope_def', {
                        nro_campo_tipo: 104,
                        enDB: false,
                        filtroWhere: "<tope_def type='like'>%%campo_value%%</tope_def>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha', {
                        nro_campo_tipo: 103,
                        enDB: false,
                        filtroWhere: "<fe_alta type='mas'>convert(datetime,'%campo_value%',103)</fe_alta>"
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
           <%-- <td>
                <script type="text/javascript">
                    campos_defs.add('tipos_movs', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipos_movs,
                        mostrar_codigo: false,
                        //filtroWhere: "<tipos_movs type='in'>'%campo_value%'</tipos_movs>"
                    });
                </script>
            </td>--%>
            <td style="text-align: center; width: 5%;">
                <select name="vigente" id="vigente" style="width:100%">
                    <option value="-1"></option>
                    <option value="1">Si </option>
                    <option value="0">No </option>
                </select>
            </td>
        </tr>    
    </table>

    <iframe name="ver_defs" id="ver_defs" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>

</body>
</html>
