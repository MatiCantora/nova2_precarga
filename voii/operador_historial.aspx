<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Me.contents("filtro_historial") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verHist_personas' PageSize='14' AbsolutePage='1' cacheControl='Session'><campos>operador, nro_entidad, Razon_social, nro_docu, tipo_docu, origen, tipocli,%grupo_fecha%</campos><filtro></filtro><orden>fecha_busqueda DESC</orden></select></criterio>")
    Me.contents("fecha_hoy") = Now().ToString("dd/MM/yyyy")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Historial de Búsqueda del Operador</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar_historial_operador()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');

        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png')

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    body_h = $$('body')[0].getHeight(),
                    tb_busqueda_h = $('tb_busqueda').getHeight()

                $('iframe_historial_operador').setStyle({ 'height': body_h - tb_busqueda_h - dif + 'px' });
            }
            catch (e) { }
        }

        function window_onload() {
            vListButton.MostrarListButton()
            campos_defs.set_value('fecha_desde', nvFW.pageContents.fecha_hoy)
            buscar_historial_operador()
            window_onresize()
        }

        function buscar_historial_operador() {
            var filtro = "<operador type='igual'>dbo.rm_nro_operador()</operador>",
                razon_social = $F('razon_social'), //$('razon_social').value,
                fecha_desde = campos_defs.get_value('fecha_desde'),
                hora_desde = $F('hora_desde'), //$('hora_desde').value,
                fecha_hasta = campos_defs.get_value('fecha_hasta'),
                hora_hasta = $F('hora_hasta'), //$('hora_hasta').value,
                vista = $F('vista'), //$('vista').value,
                desde = '',
                hasta = '',
                grupo = '',
                grupo_fecha = ''

            if (razon_social != '')
                filtro += "<Razon_social type='like'>%" + razon_social + "%</Razon_social>"

            if (fecha_desde != '') {
                desde = (hora_desde != '') ? fecha_desde + ' ' + hora_desde : fecha_desde + ' 00:00'
                filtro += "<fecha_busqueda type='mas'>CONVERT(datetime, '" + desde + "', 103)</fecha_busqueda>"
            }

            if (fecha_hasta != '') {
                if (hora_hasta != '') {
                    hasta = fecha_hasta + ' ' + hora_hasta
                    filtro += "<fecha_busqueda type='menos'>CONVERT(datetime, '" + hasta + "', 103)</fecha_busqueda>"
                } else {
                    hasta = fecha_hasta + ' 00:00'
                    filtro += "<fecha_busqueda type='menos'>CONVERT(datetime, '" + hasta + "', 103) + 1</fecha_busqueda>"
                }
            }

            grupo = (vista == 'A') ? '<grupo>operador, nro_entidad, Razon_social, nro_docu, tipo_docu, origen, tipocli</grupo>' : ''
            grupo_fecha = (vista == 'A') ? 'MAX(fecha_busqueda) AS fecha_busqueda' : 'fecha_busqueda'

            var params = "<criterio><params grupo_fecha='" + grupo_fecha + "'></params></criterio>"

            //window.top.nvFW.exportarReporte({
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_historial,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro>" + grupo + "</select></criterio>",
                params: params,
                path_xsl: 'report/Plantillas/verHist_personas/HTML_hist_personas.xsl',
                formTarget: 'iframe_historial_operador',
                nvFW_mantener_origen: true,
                bloq_contenedor: 'iframe_historial_operador',
                cls_contenedor: 'iframe_historial_operador'
            })
        }

        function cerrarVentana() {
            var win = nvFW.getMyWindow()
            win.close()
        }

        function valFormatoHora(elem) {
            var valor = elem.value
            var longitud = elem.value.length

            switch (longitud) {
                case 1:
                    if (valor >= 3)
                        elem.value = '0'
                    break
                case 2:
                    if (parseInt(valor, 10) < 24)
                        elem.value = elem.value + ':'
                    else
                        elem.value = '23:'
                    break
                case 4:
                    var hora = valor.split(':')[0]
                    var minutos = valor.split(':')[1]
                    if (minutos >= 6)
                        elem.value = hora + ':0'
                    break
                case 5:
                    var hora = valor.split(':')[0]
                    var minutos = valor.split(':')[1]
                    if (minutos >= 60)
                        elem.value = hora + ':59'
                    break
            }
        }
        function valTiempo(e) {
            val = Event.element(e).value
            var res = '99:99'
            if (val.split(':').length == 2) {
                hora = parseInt(val.split(':')[0], 10) < 24 && parseInt(val.split(':')[0], 10) >= 0 ? parseInt(val.split(':')[0], 10) : 99
                minutos = parseInt(val.split(':')[0], 10) < 99 && parseInt(val.split(':')[1], 10) < 60 && parseInt(val.split(':')[1], 10) >= 0 ? parseInt(val.split(':')[1], 10) : 99

                hora = hora < 10 ? '0' + hora : hora
                minutos = minutos < 10 ? minutos + '0' : minutos
                minutos = minutos == 99 ? '00' : minutos
                res = hora == 99 || minutos == 99 ? '99:99' : hora + ':' + minutos
            }

            if (res == '99:99') {
                //alert('El formato de hora no es válido.')
                Event.element(e).value = ''
                //Event.element(e).focus()
            }
            else
                Event.element(e).value = res
        }

        function btnBuscar_onclick(e) {
            var key = Prototype.Browser.IE ? e.keyCode : e.which
            if (key == 13)
                buscar_historial_operador()
        }
    </script>
</head>

<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <input type="hidden" name="fecha_desde_hidden" id="fecha_desde_hidden" />
    <input type="hidden" name="fecha_hasta_hidden" id="fecha_hasta_hidden" />
    <table class="tb1" id='tb_busqueda'>
        <tr>
            <td style="width: 80%;">
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 35%;"><b>Razón Social</b></td>
                        <td style="width: 25%;"><b>Fecha/Hora desde</b></td>
                        <td style="width: 25%;"><b>Fecha/Hora hasta</b></td>
                        <td style="width: 15%;"><b>Vista</b></td>
                    </tr>
                    <tr>
                        <td style="width: 35%;">
                            <input style="width: 100%" type="text" name="razon_social" id="razon_social" onkeypress='return btnBuscar_onclick(event)' /></td>
                        <td style="width: 25%; vertical-align: middle; text-align: left">
                            <table class="tb1">
                                <tr>
                                    <td style="width: 60%;">
                                        <%= nvFW.nvCampo_def.get_html_input("fecha_desde", enDB:=False, nro_campo_tipo:=103) %>
                                        <%--<script type="text/javascript">
                                            campos_defs.add('fecha_desde', { enDB: false, nro_campo_tipo: 103 })
                                        </script>--%>
                                    </td>
                                    <td style="width: 40%;">
                                        <input type="text" name="hora_desde" id="hora_desde" style="width: 100%; text-align: right" onkeypress="return valDigito(event, '/')" onkeyup="valFormatoHora(this)" onblur="return valTiempo(event)" maxlength="5" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width: 25%; vertical-align: middle; text-align: left">
                            <table class="tb1">
                                <tr>
                                    <td>
                                        <%= nvFW.nvCampo_def.get_html_input("fecha_hasta", enDB:=False, nro_campo_tipo:=103) %>
                                        <%--<script type="text/javascript">
                                            campos_defs.add('fecha_hasta', { enDB: false, nro_campo_tipo: 103 })
                                        </script>--%>
                                    </td>
                                    <td style="width: 40%;">
                                        <input type="text" name="hora_hasta" id="hora_hasta" style="width: 100%; text-align: right" onkeypress="return valDigito(event, '/')" onkeyup="valFormatoHora(this)" onblur="return valTiempo(event)" maxlength="5" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width: 15%; vertical-align: middle; text-align: center">
                            <select id="vista" name="vista">
                                <option value='A'>Agrupada</option>
                                <option value='D'>Detalle</option>
                            </select>
                        </td>
                    </tr>
                </table>
            </td>
            <td style="width: 20%;">
                <div id="divBuscar"></div>
            </td>
        </tr>
    </table>
    <iframe style='width: 100%; height: 100%; border-style: none' name='iframe_historial_operador' id='iframe_historial_operador' src='enBlanco.htm'></iframe>
</body>
</html>
