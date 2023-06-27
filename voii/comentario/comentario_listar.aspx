<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    'Stop
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador

    Dim tipo_filtro As String = nvFW.nvUtiles.obtenerValor("tipo_filtro", "")

    Me.contents("operador") = op.operador
    Me.contents("tipo_filtro") = tipo_filtro.ToLower()
    Me.contents("fecha_hoy") = Now().ToString("dd/MM/yyyy")

    Me.contents("filtro_comentarios") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro'><campos>nro_com_grupo, nro_com_estado, id_tipo, nro_com_id_tipo, fecha, comentario, operador, nro_com_tipo, com_tipo, com_estado, nombre_operador, nro_registro, bloqueado, bloq_operador</campos><filtro>[<nro_com_id_tipo type='in'>%nro_com_id_tipo?%</nro_com_id_tipo>][<id_tipo type='in'>%id_tipo?%</id_tipo>][<sql type='sql'>'%operador?%' IN (SELECT valor1 FROM dbo.piz2D_values('config_comentario_operador',nro_com_tipo, nro_com_estado))</sql>]</filtro><orden>fecha desc</orden></select></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Comentarios Backoffice</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/tcampo_def.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscarComentario()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

        var tipo_filtro = nvFW.pageContents.tipo_filtro;
        var operador = nvFW.pageContents.operador

        function window_onload() { 
            vListButton.MostrarListButton();

            $('checkPendientes').checked = tipo_filtro == 'pendientes';
            $('checkBloqueados').checked = tipo_filtro == 'bloqueados';

            window_onresize();
        }


        function window_onresize() {
            var tbFiltro_h = $('tbFiltros').style.display == '' ? $('tbFiltros').getHeight() : 0;

            $('frame_comentarios').setStyle({ height: $$('body')[0].getHeight() - $('divMenuPrincipal').getHeight() - tbFiltro_h });
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
            window_onresize();
        }


        function buscarComentario() {
            var filtro = ''

            if ($('checkBloqueados').checked)
                filtro += "<bloq_operador type='igual'>" + operador + "</bloq_operador><bloqueado type='igual'>1</bloqueado>";

            var cantFilas = Math.floor((window.parent.document.getElementById('frame_consulta').getHeight() - 18) / 22);

            filtro += '<nro_com_grupo type="igual">' + $('nro_com_grupo').value + '</nro_com_grupo>'
            filtro += campos_defs.filtroWhere('nro_com_tipo')
            filtro += campos_defs.filtroWhere('nro_com_estados')
            filtro += campos_defs.filtroWhere('fecha_desde')

            var params = "<criterio><params "
            if ($('checkPendientes').checked)
                params += "operador='" + operador + "' "

            params += " /></criterio>"

            nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_comentarios,
                filtroWhere: '<criterio><select PageSize="' + cantFilas + '" AbsolutePage="1" expire_minutes="1" cacheControl="Session"><filtro>' + filtro + '</filtro></select></criterio>',
                    bloq_contenedor: 'frame_comentarios',
                    path_xsl: 'report/comentario/HTML_verComentarios.xsl',
                    bloq_msg: 'Buscando comentarios...',
                    formTarget: 'frame_comentarios',
                    params: params,
                    nvFW_mantener_origen: true
                });
        }


    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <input type="hidden" id="nro_com_grupo" value="1" />
    <input type="hidden" id="nro_entidad" value="" />
    <div id="divMenuPrincipal"></div>
    <script type="text/javascript" >
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
            <td style="width:85%">
                <table class="tb1">
                    <tr class="tbLabel">
                        <%--<td style="text-align: center">Usuario</td>--%>
                        <td style="text-align: center">Motivo</td>
                        <td style="text-align: center">Estado</td>
                        <td style="text-align: center">Fecha Desde</td>
                    </tr>
                    <tr>
                        <%--<td>
                            <script>
                                campos_defs.add("usuario", {
                                    enDB: false,
                                    nro_campo_tipo: 104
                                })
                            </script>
                        </td>--%>
                        <td>
                            <script>
                                campos_defs.add('nro_com_tipo')
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('nro_com_estados')
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecha_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecha type='mas'>convert(datetime, '%campo_value%', 103)</fecha>"
                                });
                                //campos_defs.set_value("fecha_desde", nvFW.pageContents.fecha_hoy);
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
            <td style="width:15%">
                <table class="tb1">
                    <tr>
                        <td style="vertical-align: middle" colspan="2">
                            <div id="divBuscar" style="width: 100%"></div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <input type="checkbox" id="checkBloqueados" />Bloqueados
                        </td>
                        <td>
                            <input type="checkbox" id="checkPendientes" />Mis pendientes
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <iframe src="/FW/enBlanco.htm" name="frame_comentarios" id="frame_comentarios" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
</body>
</html>
