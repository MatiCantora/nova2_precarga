<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_herramientas", 11)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Me.contents("filtro_resumen") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_alarmas_resumen' cn='UNIDATO'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("filtro_tope_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_def' cn='UNIDATO'><campos>nro_tope_def as [id], tope_def as [campo]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_mes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_periodos' cn='UNIDATO'><campos>nro_periodo as [id], periodo as [campo]</campos><filtro><tipo_periodo type='igual'>'MENSUAL'</tipo_periodo></filtro><orden></orden></select></criterio>")
    Me.contents("vista_topes_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psp_topes_def' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipo_periodo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_def' cn='UNIDATO'><campos>distinct tipo_periodo as [id], tipo_periodo as [campo]</campos><filtro><NOT><tipo_periodo type='isnull'/></NOT></filtro><orden></orden></select></criterio>")

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

            pMenu.loadImage("excel", "../image/icons/excel.png");
            pMenu.MostrarMenu();

            let vButtonItems = [];
            vButtonItems[0] = [];
            vButtonItems[0]["nombre"] = "Buscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            let vListButtons = new tListButton(vButtonItems, 'vListButtons');
            vListButtons.loadImage("buscar", '../image/icons/buscar.png');
            vListButtons.MostrarListButton();

            window_onresize();
            campos_defs.set_value('id_cliente', GetCookie("psp", ""));
            buscar();
        }

        function window_onresize() {
            try {
                let dif = Prototype.Browser.IE ? 10 : 0;
                let body_heigth = $$('body')[0].getHeight();
                let cab_heigth = $('tbFiltros').getHeight();

                $('ver_resumen').setStyle({ 'height': body_heigth - cab_heigth - 35 - dif + 'px' });
            }
            catch (e) { }
        }

        function buscar() {
            let filtro = campos_defs.filtroWhere();

            if (document.getElementById('vigencia').value != "")
                filtro += "<vigente>" + document.getElementById('vigencia').value + "</vigente>";

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_resumen,
                filtroWhere: filtro,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: 'report/unidato/verNv_psp_alarmas_movimientos_resumen.xsl',
                formTarget: 'ver_resumen',
                nvFW_mantener_origen: true,
                cls_contenedor: 'ver_resumen',
                async: true,
            });

        }

        function exportar() {
            let filtro = campos_defs.filtroWhere();

            if (document.getElementById('vigencia').value != "")
                filtro += "<vigente>" + document.getElementById('vigencia').value + "</vigente>";

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_resumen,
                filtroWhere: filtro,
                path_xsl: "report/EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "detalle_resumen_alarmas.xls"
            });
        }

        function ver_alarmas(id_tipo_alarma, anio, mes, psp) {
            parent.campos_defs.clear();
            parent.document.getElementById('tipoVista').value = "alarmas";
            parent.cambio_vista();
            parent.campos_defs.set_value('id_tipo_alarma', id_tipo_alarma);
            parent.campos_defs.set_value('anio', anio);
            parent.campos_defs.set_value('mes', mes);
            parent.campos_defs.set_value('id_cliente', psp);

            parent.buscar();
            win.close();
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
    <table id="tbFiltros" class="tb1 layout_fixed">
        <tr>
            <td class="Tit1" style="padding: 3px; text-align:center"; white-space="nowrap">
                Def Tope
            </td>
            <td class="Tit1" style="padding: 3px; text-align:center"; white-space="nowrap">
                PSP
            </td>
            <td class="Tit1" style="padding: 3px; text-align:center"; white-space="nowrap">
                Tipo de período
            </td>
            <td class="Tit1" style="padding: 3px; text-align:center; width:15%" white-space="nowrap">
                Vigencia
            </td>
            <td rowspan="4" style="width:8%;" white-space="nowrap">
                <div id="divBuscar" style="margin: 0px; padding: 0px;"></div>
            </td>
        </tr>
        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tope_def', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tope_def,
                        filtroWhere: "<nro_tope_def type='in'>%campo_value%</nro_tope_def>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_cliente', { 
                        enDB: true,
                        filtroWhere: "<psp_id type='igual'>'%campo_value%'</psp_id>",
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
                <select name="vigencia" id="vigencia" style="width: 100%">
                    <option value="" selected></option>
                    <option value="1">Vigente</option>
                    <option value="0">No vigente</option>
                </select>
            </td>
        </tr>

        <tr>
            <td class="Tit1" style="padding: 3px; text-align:center"; white-space="nowrap">
                Año
            </td>
            <td class="Tit1" style="padding: 3px; text-align:center"; white-space="nowrap">
                Mes
            </td>
            <td class="Tit1" style="padding: 3px; text-align:center"; white-space="nowrap">
                Fecha desde
            </td>
            <td class="Tit1" style="padding: 3px; text-align:center"; white-space="nowrap">
                Fecha hasta
            </td>
        </tr>
        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('anio', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        filtroWhere: "<anio_calc type='igual'>%campo_value%</anio_calc>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('mes', {
                        nro_campo_tipo: 2,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_mes,
                        filtroWhere: "<mes_calc type='in'>%campo_value%</mes_calc>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_mov_desde', {
                        nro_campo_tipo: 103,
                        enDB: false,
                        filtroWhere: "<fe_alta type='mas'>convert(datetime,'%campo_value%',103)</fe_alta>"
                    });
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_mov_hasta', {
                        nro_campo_tipo: 103,
                        enDB: false,
                        filtroWhere: "<fe_alta type='menor'>dateadd(dd,1,convert(datetime,'%campo_value%',103))</fe_alta>"
                    });
                </script>
            </td>
        </tr>
    </table>

    <iframe name="ver_resumen" id="ver_resumen" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>

</body>
</html>
