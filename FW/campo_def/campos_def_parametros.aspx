<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Campos def Parametros</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript">

        var win = nvFW.getMyWindow();
        var json = win.options.userData.strParametros;

        function window_onload() {

            if (parent.campos_defs.get_value('nro_campo_tipo') != 1 && parent.campos_defs.get_value('nro_campo_tipo') != 4)
                $('checkAutocomplete').disabled = true
            else {
                var es_tipo_cuatro = parent.campos_defs.get_value('nro_campo_tipo') == 4;
                $('checkAutocomplete').checked = es_tipo_cuatro;
                habilitar_autocompletes(es_tipo_cuatro);
            }
            
            if (json != '' && validarJSON(json)) {
                cargarParametros();
            }

            window_onresize();

        }


        function window_onresize() {
            $('divDetalle').setStyle({ height: $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('vMenu').getHeight() + 'px' });
            resize_columns('tbCabecera', 'tbDetalle');
        }


        function cargarParametros() {
            $('checkMostrar_codigo').checked = typeof json.mostrar_codigo != 'undefined' ? json.mostrar_codigo : true;

            $('checkSin_seleccion').checked = typeof json.sin_seleccion != 'undefined' ? json.sin_seleccion : true;

            $('checkAutocomplete').checked = typeof json.autocomplete != 'undefined' ? json.autocomplete : parent.campos_defs.get_value('nro_campo_tipo') == 4;
            habilitar_autocompletes();

            $('checkAutocompleteMatch').checked = typeof json.autocomplete_match != 'undefined' ? true : false;
            $('checkAutocompleteMatch').onchange();
            if ($('checkAutocompleteMatch').checked)
                campos_defs.set_value('autocomplete_match', json.autocomplete_match);

            $('checkAutocompleteMinLength').checked = typeof json.autocomplete_minlength != 'undefined' ? true : false;
            $('checkAutocompleteMinLength').onchange();
            if ($('checkAutocompleteMinLength').checked)
                campos_defs.set_value('autocomplete_minlength', json.autocomplete_minlength);

            $('checkPlaceholder').checked = typeof json.placeholder != 'undefined' ? true : false;
            $('checkPlaceholder').onchange();
            if ($('checkPlaceholder').checked)
                campos_defs.set_value('placeholder', json.placeholder);

            $('checkDespliega').checked = typeof json.despliega != 'undefined' ? true : false;
            $('checkDespliega').onchange();
            if ($('checkDespliega').checked)
                campos_defs.set_value('despliega', json.despliega);


            $('checkMaxSize').checked = typeof json.max_size != 'undefined' ? true : false;
            $('checkMaxSize').onchange();
            if ($('checkMaxSize').checked)
                campos_defs.set_value('max_size', json.max_size);

            $('checkNativeAutocomplete').checked = typeof json.native_autocomplete != 'undefined' ? json.native_autocomplete : false;

            $('checkStringValueIncludeQuote').checked = typeof json.StringValueIncludeQuote != 'undefined' ? json.StringValueIncludeQuote : false;
        }


        function validarJSON(strParametros) {
            try {
                json = JSON.parse(strParametros)
            } catch (e) {
                return false;
            }
            return true;
        }


        function habilitar_autocompletes(es_tipo_cuatro) {
            var habilitar = !$('checkAutocomplete').checked;
            $('checkAutocompleteMatch').disabled = habilitar;
            $('checkAutocompleteMinLength').disabled = habilitar;
            $('checkAutocomplete').disabled = typeof es_tipo_cuatro === 'undefined' ? false : es_tipo_cuatro;
        }


        function btnGuardar() {
            var strParametros = '';

            if (!$('checkMostrar_codigo').checked)
                strParametros += '"mostrar_codigo": false,';

            if (!$('checkSin_seleccion').checked)
                strParametros += '"sin_seleccion": false,';

            if ($('checkAutocomplete').checked)
                strParametros += '"autocomplete": true,';

            if ($('checkAutocompleteMatch').checked)
                strParametros += '"autocomplete_match": "' + campos_defs.get_value('autocomplete_match') + '",';

            if ($('checkAutocompleteMinLength').checked)
                strParametros += '"autocomplete_minlength": ' + campos_defs.get_value('autocomplete_minlength') + ',';

            if ($('checkPlaceholder').checked)
                strParametros += '"placeholder": "' + campos_defs.get_value('placeholder') + '",';

            if ($('checkDespliega').checked)
                strParametros += '"despliega": "' + campos_defs.get_value('despliega') + '",';

            if ($('checkDespliega').checked)
                strParametros += '"despliega": "' + campos_defs.get_value('despliega') + '",';

            if ($('checkMaxSize').checked)
                strParametros += '"max_size": ' + campos_defs.get_value('max_size') + ',';

            if ($('checkNativeAutocomplete').checked)
                strParametros += '"native_autocomplete": true,';

            if ($('checkStringValueIncludeQuote').checked)
                strParametros += '"StringValueIncludeQuote": true,';

            if (strParametros != "")
                strParametros = '{' + strParametros.substring(0, strParametros.length - 1) + '}';

            win.options.userData = { strParametros: strParametros }
            win.close()
        }


        function resize_columns(idHead, idBody) {
            
            var oHead = $(idHead)
            var oBody = $(idBody)

            if (oHead == undefined || oBody == undefined)
                return

            var colHead = oHead
            while (colHead.nodeName.toUpperCase() != "TR" && $(colHead).childElements().length > 0)
                colHead = $(colHead).childElements()[0]

            var colBody = oBody
            while (colBody.nodeName.toUpperCase() != "TR" && $(colBody).childElements().length > 0) // || $(colBody).style.display == 'none')
                colBody = $(colBody).childElements()[0]

            if ((colBody.nodeName.toUpperCase() != "TR") || (colHead.nodeName.toUpperCase() != "TR"))
                return

            var divBody = $(oBody.parentNode)


            var colWidth
            var tbBodyWidth = oBody.getWidth()
            var scrollWidth = divBody.getWidth() - tbBodyWidth

            for (var i = 0; i < colHead.childElements().length - 1; i++) {
                $(colBody.childElements()[i]).setStyle({ width: $(colHead.childElements()[i]).getWidth() + "px" })
            }

            //Ajustar ultimo elemento
            var hasVerticalScrollbar = divBody.scrollHeight > divBody.clientHeight
            var i = colHead.childElements().length - 1
            var widthScroll = 0
            if (hasVerticalScrollbar)
                widthScroll = 16
            $(colBody.childElements()[i]).setStyle({ width: ($(colHead.childElements()[i]).getWidth() - widthScroll) + "px" })

            return ""

        }

    </script>
</head>
<body style="overflow: hidden;" onload="window_onload()" onresize="window_onresize()">
    <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';


        vMenu.loadImage("guardar", '/FW/image/icons/guardar.png')

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnGuardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='width: 98%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu.MostrarMenu()
    </script>
    <table id="tbCabecera" class="tb1">
        <tr class="tbLabel">
            <td style="text-align: center; width: 50%">Parametro</td>
            <td style="text-align: center">Valor</td>
        </tr>
    </table>
    <div id="divDetalle" style="overflow: auto; width: 100%;">
        <table id="tbDetalle" class="tb1 highlightEven">
            <tr>
                <td><span>Mostrar codigo</span><span style="float: right"><input id="checkMostrar_codigo" type="checkbox" checked /></span></td>
                <td></td>
            </tr>
            <tr>
                <td><span>Sin seleccion</span><span style="float: right"><input id="checkSin_seleccion" type="checkbox" checked /></span></td>
                <td></td>
            </tr>
            <tr>
                <td><span>Autocomplete</span><span style="float: right"><input id="checkAutocomplete" onchange="habilitar_autocompletes()" type="checkbox" /></span></td>
                <%--verificar que sea tipo 1, tipo 4 check por defecto, si check aparecen otros campos--%>
                <td style="color: gray">Tipo 1 y Tipo 4</td>
            </tr>
            <tr>
                <td><span>Autocomplete Match</span><span style="float: right"><input id="checkAutocompleteMatch" disabled type="checkbox" onchange="campos_defs.habilitar('autocomplete_match', this.checked)" /></span></td>
                <td>
                    <script>
                        var rs = new tRS();
                        rs.xml_format = "rs_xml_json"
                        rs.addField("id", "string")
                        rs.addField("campo", "string")
                        rs.addRecord({ id: "todo", campo: "Todo" })
                        rs.addRecord({ id: "solo_inicio", campo: "Solo Inicio" })
                        campos_defs.add('autocomplete_match', {
                            filtroXML: "",
                            filtroWhere: "",
                            nro_campo_tipo: 1, enDB: false, json: true, mostrar_codigo: false, sin_seleccion: false
                        });

                        campos_defs.items['autocomplete_match'].rs = rs
                        campos_defs.set_value('autocomplete_match', 'todo')
                        campos_defs.habilitar('autocomplete_match', false)
                    </script>
                </td>
            </tr>
            <tr>
                <td><span>Autocomplete Min Length</span><span style="float: right"><input id="checkAutocompleteMinLength" disabled type="checkbox" onchange="campos_defs.habilitar('autocomplete_minlength', this.checked)" /></span></td>
                <td>
                    <script>
                        campos_defs.add('autocomplete_minlength', {
                            nro_campo_tipo: 100, enDB: false
                        });
                        campos_defs.set_value('autocomplete_minlength', 0)
                        campos_defs.habilitar('autocomplete_minlength', false)
                    </script>
                </td>
            </tr>
            <tr>
                <td><span>Placeholder</span><span style="float: right"><input type="checkbox" id="checkPlaceholder" onchange="campos_defs.habilitar('placeholder', this.checked)" /></span></td>
                <td>
                    <script>
                        campos_defs.add('placeholder', {
                            nro_campo_tipo: 104, enDB: false
                        });
                        campos_defs.habilitar('placeholder', false)
                    </script>
                </td>
            </tr>
            <tr>
                <td><span>Despliega</span><span style="float: right"><input type="checkbox" id="checkDespliega" onchange="campos_defs.habilitar('despliega', this.checked)" /></span></td>
                <td>
                    <script>
                        var rs = new tRS();
                        rs.xml_format = "rs_xml_json"
                        rs.addField("id", "string")
                        rs.addField("campo", "string")
                        rs.addRecord({ id: "abajo", campo: "Abajo" })
                        rs.addRecord({ id: "arriba", campo: "Arriba" })
                        campos_defs.add('despliega', {
                            filtroXML: "",
                            filtroWhere: "",
                            nro_campo_tipo: 1, enDB: false, json: true, mostrar_codigo: false, sin_seleccion: false
                        });

                        campos_defs.items['despliega'].rs = rs
                        campos_defs.set_value('despliega', "abajo")
                        campos_defs.habilitar('despliega', false)
                    </script>
                </td>
            </tr>
            <tr>
                <td><span>Cantidad de datos</span><span style="float: right"><input type="checkbox" id="checkMaxSize" onchange="campos_defs.habilitar('max_size', this.checked)" /></span></td>
                <td>
                    <script>
                        campos_defs.add('max_size', {
                            nro_campo_tipo: 100, enDB: false
                        });
                        campos_defs.habilitar('max_size', false)
                    </script>
                </td>
            </tr>
            <tr>
                <td><span>Autocomplete Nativo</span><span style="float: right"><input id="checkNativeAutocomplete" type="checkbox" /></span></td>
                <td></td>
            </tr>
            <tr>
                <td><span>Incluye comillas</span><span style="float: right"><input id="checkStringValueIncludeQuote" type="checkbox" /></span></td>
                <td></td>
            </tr>
        </table>
    </div>
</body>
</html>
