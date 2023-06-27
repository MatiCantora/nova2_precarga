<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim nrodoc As String = nvFW.nvUtiles.obtenerValor("nrodoc", "")
    Dim tipdoc As String = nvFW.nvUtiles.obtenerValor("tipdoc", "")

    Me.contents("ver_cuentas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_cuentas' cn='BD_IBS_ANEXA'><campos>sistema, cuecod, cueestdesc, fecalta, fecestado, fecultmov, moneda, nombrecta </campos><filtro> <nrodoc type='igual'> " + nrodoc + " </nrodoc> <tipdoc type='igual'> " + tipdoc + " </tipdoc></filtro></select ></criterio > ")

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <meta name="viewport" content="width=device-width, user-scalable=no">

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var body_h
        function window_onload() {
            
            window_onresize()
            campos_defs.set_value("sistcodes", "3,5")
            buscar()
        }

        function window_onresize() {
            body_h = $$('body')[0].getHeight();
            //if ($$('body')[0].getHeight() != body_h && !verFiltros)
            //    body_h = $$('body')[0].getHeight();

            if (verFiltros) {
                $("iframe5").setStyle({ height: body_h - ($("vMenuPrincipal").getHeight() - $("tbFiltros").getHeight()) + "px" })
                //$$('body')[0].setStyle({ height: $("iframe5").getHeight() + $("vMenuPrincipal").getHeight() + $("tbFiltros").getHeight() })
            }
            else {
                $("iframe5").setStyle({ height: body_h - $("vMenuPrincipal").getHeight() + "px" })
                //$$('body')[0].setStyle({ height: body_h + "px" })
            }
        }

        function buscar() {
            window_onresize()
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.ver_cuentas
                , filtroWhere: "<criterio><select vista='VOII_cuentas' cn='BD_IBS_ANEXA'><filtro>" + campos_defs.filtroWhere() + "</filtro></select></criterio>"
                , path_xsl: "/report/operaciones/cuentas_listar.xsl"
                , salida_tipo: "adjunto"
                , formTarget: "iframe5"
                , nvFW_mantener_origen: true
            })
        }

        var verFiltros = false
        function mostrar_filtros() {
            if (verFiltros) {
                $('img_filtros_mostrar').src = '/FW/image/icons/mas.gif';
                $('tbFiltros').hide();
                verFiltros = false;
            } else {
                $('img_filtros_mostrar').src = '/FW/image/icons/menos.gif';
                $('tbFiltros').show();
                verFiltros = true;
            }
            window_onresize()
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
    <div id="divMenuPrincipal"></div>
    <script>
        vMenuPrincipal = new tMenu('divMenuPrincipal', 'vMenuPrincipal');
        Menus["vMenuPrincipal"] = vMenuPrincipal;
        Menus["vMenuPrincipal"].alineacion = 'centro';
        Menus["vMenuPrincipal"].estilo = 'A';

        Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");

        vMenuPrincipal.MostrarMenu();
        $('menuItem_divMenuPrincipal_0').innerHTML = "<img onclick='return mostrar_filtros()' name='img_filtros_mostrar' id='img_filtros_mostrar' style='cursor: pointer; vertical-align: middle' src='/FW/image/icons/mas.gif' />&nbsp;Filtros"
    </script>
    <table id="tbFiltros" class="tb1" style="display: none">
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="text-align: center">Tipo</td>
                        <td style="text-align: center">Moneda</td>
                        <td style="text-align: center">Nro.</td>
                        <td style="text-align: center">Estado</td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add("sistcodes")
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('moncodes')
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('cuecod', {
                                    enDB: false,
                                    nro_campo_tipo: 100,
                                    filtroXML: nvFW.pageContents.filtro_descripcion,
                                    filtroWhere: "<cuecod type='in'>%campo_value%</cuecod>"
                                }) 
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('estctacodes') 
                            </script>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td style="text-align: center" colspan="2">Fecha Alta</td>
                        <td style="text-align: center" colspan="2">Fecha Estado</td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('fecalta_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecalta type='mas'>convert(datetime, '%campo_value%', 103)</fecalta>"
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecalta_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecalta type='menos'>convert(datetime, '%campo_value%', 103)</fecalta>"
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecestado_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecestado type='mas'>convert(datetime, '%campo_value%', 103)</fecestado>"
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecestado_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecestado type='menos'>convert(datetime, '%campo_value%', 103)</fecestado>"
                                });
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table class="tb1">
                    <tr>
                        <td style="vertical-align: middle">
                            <div id="divBuscar">
                            <script type="text/javascript">
                                var vButtonItems = {};
                                vButtonItems[0] = {};
                                vButtonItems[0]["nombre"] = "Buscar";
                                vButtonItems[0]["etiqueta"] = "Buscar";
                                vButtonItems[0]["imagen"] = "buscar";
                                vButtonItems[0]["onclick"] = "return buscar()";

                                var vListButton = new tListButton(vButtonItems, 'vListButton')

                                vListButton.loadImage("buscar", '/FW/image/icons/buscar.png')

                                vListButton.MostrarListButton()
                            </script>
                        </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <iframe name="iframe5" id="iframe5" style="width: 100%; height: 100%; overflow: auto;"></iframe>    
</body>
</html>
