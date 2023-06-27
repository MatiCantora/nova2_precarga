<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim id_calc_det = obtenerValor("id_calc_det")

    Me.contents("filtro_calc_acumuladores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_acumuladores' PageSize='17' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

%>

<html>
<head>
    <title>Cálculo de Comisiones</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var vButtonItems = new Array();

        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return acumuladores_buscar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png')

        var win = nvFW.getMyWindow()
        var Acumuladores = new Array()
        //var cambio_acumulador

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()

            }
            catch (e) { }
        }


        function window_onload() {

            vListButton.MostrarListButton()
            //llamo a plantilla
            acumuladores_buscar()


            //acumuladores_cargar()
            //pizarras_cargar()

            window_onresize()
        }


        function acumuladores_buscar() {

            var filtro = ''
            if ($('calc_acum').value != '')
                filtro += "<calc_acum type='like'>%" + $('calc_acum').value + "%</calc_acum>"

            if ($('base_calc').value != '')
                filtro += "<base_calc type='like'>%" + $('base_calc').value + "%</base_calc>"

            if ($('calc_tipo').value != '')
                filtro += "<calc_tipo type='igual'>'" + $('calc_tipo').value + "'</calc_tipo>"

            if ($('calc_campo').value != '')
                filtro += "<calc_campo type='like'>%" + $('calc_campo').value + "%</calc_campo>"

            if ($('condicion').value != '')
                filtro += "<OR><cond_var type='like'>%" + $('condicion').value + "%</cond_var><cond_fija type='like'>%" + $('condicion').value + "%</cond_fija></OR>"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_calc_acumuladores,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: "report/calculos/HTML_calculos_acumuladores.xsl",
                formTarget: 'iframe1',
                nvFW_mantener_origen: true,
                bloq_contenedor: $('iframe1'),
                cls_contenedor: 'iframe1'
            })
        }

        function acumulador_abm(nro_calc_acum) {


            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win = w.createWindow({
                className: 'alphacube',
                url: 'calculos/calculos_acumulador_ABM.aspx',
                title: '<b>Acumulador ABM</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 300,
                onClose: acumulador_return
            });

            win.options.userData = { nro_calc_acum: nro_calc_acum }
            win.showCenter(true)

        }


        function acumulador_return() {

            if (win.options.userData.parametros) {
                parent.cambio_acumulador = true

                acumuladores_buscar()
            }

        }

        function nombre_variable_verificar() {
            var error = ''
            if ($('calc_variable').value.split(' ')[1])
                error = 'NO deben existir espacios vacíos en el nombre de variable'

            return error

        }


        function tipo_variable_verificar() {
            var error = ''
            if (campos_defs.get_value('id_calc_var_tipo') == 1) { //Constante
                if (campos_defs.get_value('nro_calc_acum') != '')
                    error += 'Una variable constante no puede tener acumulador asociado'

                if ($('calc_variable').value != $('calculo').value.split('@')[1])
                    error += 'El cálculo debe ser igual al nombre de variable precedido por @'
            }

            if (campos_defs.get_value('id_calc_var_tipo') == 2) { //Calculo

            }

            if (campos_defs.get_value('id_calc_var_tipo') == 3) { //Acumulador
                if (campos_defs.get_value('nro_calc_acum') == '')
                    error += 'Una variable Acumulador debe tener acumulador asociado'
            }

            if (campos_defs.get_value('id_calc_var_tipo') == 4) { //Fcion pizarra

            }

            return error
        }


        var win_editar
        function ver_editor(_this) {
            var texto = _this.value
            var name_campo = _this.name
            win_editar = new Window({
                className: 'alphacube',
                title: '<b>Editar Texo</b>',
                minimizable: true,
                maximizable: false,
                draggable: false,
                resizable: false,
                recenterAuto: false,
                width: 650,
                height: 200,
                onClose: function () { }
            });
            var html = "<html><head></head><body style='width: 100%; height: 100%;'><form><table class='tb1'><tr><td align='center'><input type='hidden' name='name_campo' id='name_campo' value='" + name_campo + "'/><textarea style='overflow: auto; resize: none; width: 630px;' rows='9' cols='1' name='editar_texto' id='editar_texto' >" + texto + "</textarea></td></tr><tr><td align='right'><input type='button' name='aceptar' id='aceptar' value='Aceptar' onclick='actualizar_texto(win_editar)'/></td></tr></table></form></body>";
            win_editar.setHTMLContent(html)
            var id = win_editar.getId()
            focus(id)
            win_editar.showCenter(true)
        }


        function actualizar_texto(win_editar) {
            var editar_texto = $('editar_texto').value
            var name_campo = $('name_campo').value
            win_editar.close()
            $(name_campo).value = editar_texto
        }


        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divMenuABMAcumulador_h = $('divMenuABMAcumulador').getHeight()
                var tbCab_h = $('tb_cab').getHeight()

                $('iframe1').setStyle({ 'height': body_h - divMenuABMAcumulador_h - tbCab_h - dif + 'px' });

            }
            catch (e) { }
        }


    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuABMAcumulador" style="width: 100%; margin: 0px; padding: 0px"></div>
    <script type="text/javascript" language="javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuABMAcumulador = new tMenu('divMenuABMAcumulador', 'vMenuABMAcumulador');
        Menus["vMenuABMAcumulador"] = vMenuABMAcumulador
        Menus["vMenuABMAcumulador"].alineacion = 'centro';
        Menus["vMenuABMAcumulador"].estilo = 'A';

        vMenuABMAcumulador.loadImage("nuevo", "/FW/image/icons/nueva.png");

        Menus["vMenuABMAcumulador"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuABMAcumulador"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo Acumulador</Desc><Acciones><Ejecutar Tipo='script'><Codigo>acumulador_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABMAcumulador"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenuABMAcumulador.MostrarMenu()
    </script>
    <table class="tb1" style="width: 100%" id="tb_cab">
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td>Nombre</td>
                        <td>Base</td>
                        <td>Tipo</td>
                        <td>Campo</td>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" id="calc_acum" name="calc_acum" value="" style="width: 100%" /></td>
                        <td>
                            <input type="text" id="base_calc" name="base_calc" value="" style="width: 100%" /></td>
                        <td style="text-align: left" id="td_calc_tipo">
                            <select name="calc_tipo" id="calc_tipo" style="width: 100%">
                                <option value=""></option>
                                <option value="sum">sum</option>
                                <option value="count">count</option>
                            </select>
                        </td>
                        <td>
                            <input type="text" id="calc_campo" name="calc_campo" value="" style="width: 100%" /></td>

                    </tr>
                </table>

            </td>
            <td style='width: 15%' rowspan='2' valign="middle">
                <table style='width: 100%; vertical-align: top'>
                    <tr>
                        <td id='td_aceptar' valign="middle" colspan="2">
                            <div id="divBuscar"></div>
                        </td>
                    </tr>

                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td>Condición</td>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" id="condicion" name="condicion" value="" style="width: 100%" /></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <iframe name="iframe1" id="iframe1" style='width: 100%; overflow: hidden; height: 100%' frameborder="0" src="enBlanco.htm"></iframe>


</body>
</html>
