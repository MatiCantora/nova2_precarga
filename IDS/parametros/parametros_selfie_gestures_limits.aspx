<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim idParam As String = nvFW.nvUtiles.obtenerValor("idParam", "")

    Me.contents("idParam") = idParam
    Me.contents("filtroParametros") = nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros_nodos'><campos>*</campos><filtro></filtro><orden>orden</orden></select></criterio>")
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es-ar">
<head>
    <title>Listado parámetros de Image Size</title>
    <link href='/FW/css/base.css' type='text/css' rel='stylesheet' />

    <style type="text/css">
        input[type=number] {
            text-align: right;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var idParam    = nvFW.pageContents.idParam;
        var parametros = [];
        var win_edition;
        var vButtonItems = [];
        var vListButton;


        var Convert =
        {
            // Convertir JSON a XML
            JSONtoXML: function(objJSONArray)
            {
                if (!objJSONArray.length) return "<parametros></parametros>";

                var strXML = "<parametros>";
                var param = null;

                for (var i = 0; i < objJSONArray.length; i++)
                {
                    param = objJSONArray[i];
                    strXML += "<parametro>";
                    strXML += "<gesture_type>" + param.gesture_type + "</gesture_type>";
                    strXML += "<pitch_min>" + param.pitch_min + "</pitch_min>";
                    strXML += "<pitch_max>" + param.pitch_max + "</pitch_max>";
                    strXML += "<roll_min>" + param.roll_min + "</roll_min>";
                    strXML += "<roll_max>" + param.roll_max + "</roll_max>";
                    strXML += "<yaw_min>" + param.yaw_min + "</yaw_min>";
                    strXML += "<yaw_max>" + param.yaw_max + "</yaw_max>";
                    strXML += "</parametro>";
                }

                strXML += "</parametros>";
                return strXML;
            },

            // Convertir XML a JSON Array
            XMLtoJSONArray: function(strXML)
            {
                var JSONArray = [];

                if (!strXML) return JSONArray;

                try
                {
                    var oXml = new tXML();

                    if (oXml.loadXML(strXML))
                    {
                        JSONArray.length = 0;  // Vaciar el contenedor
                        var xml_parametros = oXml.selectNodes('/parametros/parametro');
                        var NOD = null;
                        var obj = null;

                        for (var i = 0; i < xml_parametros.length; i++)
                        {
                            NOD = xml_parametros[i];
                            obj = {
                                'gesture_type': NOD.getElementsByTagName("gesture_type") ? NOD.getElementsByTagName("gesture_type")[0].textContent : '',
                                'pitch_min':    NOD.getElementsByTagName("pitch_min") ? parseFloat(NOD.getElementsByTagName("pitch_min")[0].textContent) : 0,
                                'pitch_max':    NOD.getElementsByTagName("pitch_max") ? parseFloat(NOD.getElementsByTagName("pitch_max")[0].textContent) : 0,
                                'roll_min':     NOD.getElementsByTagName("roll_min") ? parseFloat(NOD.getElementsByTagName("roll_min")[0].textContent) : 0,
                                'roll_max':     NOD.getElementsByTagName("roll_max") ? parseFloat(NOD.getElementsByTagName("roll_max")[0].textContent) : 0,
                                'yaw_min':      NOD.getElementsByTagName("yaw_min") ? parseFloat(NOD.getElementsByTagName("yaw_min")[0].textContent) : 0,
                                'yaw_max':      NOD.getElementsByTagName("yaw_max") ? parseFloat(NOD.getElementsByTagName("yaw_max")[0].textContent) : 0
                            };

                            JSONArray.push(obj);
                        }
                    }
                }
                catch(e)
                {
                    JSONArray.length = 0;
                }

                return JSONArray;
            }
        }



        function makeButtons()
        {
            // Boton Cancelar
            vButtonItems[0] = [];
            vButtonItems[0]["nombre"]   = "Cancelar";
            vButtonItems[0]["etiqueta"] = "Cancelar";
            vButtonItems[0]["imagen"]   = "cancelar";
            vButtonItems[0]["onclick"]  = "return editDefinition_cancelar()";

            // Boton Guardar
            vButtonItems[1] = [];
            vButtonItems[1]["nombre"]   = "Aceptar";
            vButtonItems[1]["etiqueta"] = "Aceptar";
            vButtonItems[1]["imagen"]   = "aceptar";
            vButtonItems[1]["onclick"]  = "return editDefinition_aceptar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("cancelar", '/FW/image/icons/cancelar.png');
            vListButton.loadImage("aceptar", '/FW/image/icons/tilde.png');

            vListButton.MostrarListButton();
        }


        function drawParameters()
        {
            if (!parametros)
            {
                $('divTable').innerHTML = '<div>No hay parámetros</div>';
                return;
            }

            var htmlDialog = "";

            // Tabla y Cabeceras
            htmlDialog += "<table id='tbParametria' class='tb1 highlightOdd highlightTROver layout_fixed'>" +
                            "<tr class='tbLabel'>" +
                                "<td style='width:5%; text-align: center'>-</td>" +
                                "<td style='text-align: center;'>Tipo Gesto</td>" +
                                "<td style='text-align: center;'>Pitch Min</td>" +
                                "<td style='text-align: center;'>Pitch Max</td>" +
                                "<td style='text-align: center;' title=''>Roll Min</td>" +
                                "<td style='text-align: center;' title=''>Roll Max</td>" +
                                "<td style='text-align: center;' title=''>Yaw Min</td>" +
                                "<td style='text-align: center;' title=''>Yaw Min</td>" +
                            "</tr>";

            // Armado de las filas de datos
            var param;

            for (var i = 0; i < parametros.length; i++)
            {
                param = parametros[i];
                htmlDialog += "<tr id='tr" + i + "'>" +
                                "<td style='width:5%;text-align:center'>" +
                                    "<img title='Eliminar Definición' onclick='deleteValue(" + i + ")' src='/FW/image/icons/eliminar.png' style='cursor: pointer' />" +
                                    "<img title='Editar Definición' onclick='editDefinition(\"M\"," + i + ")' src='/FW/image/icons/editar.png' style='cursor: pointer' />" +
                                "</td>" +
                                "<td style=''>" + param.gesture_type + "</td>" +
                                "<td style='text-align: right;'>" + param.pitch_min + "</td>" +
                                "<td style='text-align: right;'>" + param.pitch_max + "</td>" +
                                "<td style='text-align: right;'>" + param.roll_min + "</td>" +
                                "<td style='text-align: right;'>" + param.roll_max + "</td>" +
                                "<td style='text-align: right;'>" + param.yaw_min + "</td>" +
                                "<td style='text-align: right;'>" + param.yaw_max + "</td>" +
                            "</tr>";
            }

            htmlDialog += "</table>"
            $('divTable').innerHTML = htmlDialog
        }


        function loadParameters()
        {
            var rs = new tRS();
            rs.open({
                filtroXML:   nvFW.pageContents.filtroParametros,
                filtroWhere: "<criterio><select><campos>valor</campos><filtro><id_param type='like'>%" + idParam + "%</id_param></filtro></select></criterio>"
            });

            var valor = rs.getdata("valor");
            rs = null;

            // Si NO hay valores, informarlo en la salida
            if (!valor) return;

            /*-----------------------------------------------------------------
            *   valor:
            *
            *       <parametros>
            *           <parametro>     //////// Esta sub-estructura ("parametro") SE PUEDE REPETIR como tantos parametros querramos
            *               <gesture_type>mirar_izquierda</gesture_type>
            *               <pitch_min>-15</pitch_min>
            *               <pitch_max>15</pitch_max>
            *               <roll_min>-10</roll_min>
            *               <roll_max>10</roll_max>
            *               <yaw_min>-10</yaw_min>
            *               <yaw_max>10</yaw_max>
            *           </parametro>
            *       </parametros>
            -----------------------------------------------------------------*/

            parametros = Convert.XMLtoJSONArray(valor);
        }


        function deleteValue(definition_pos) {
            nvFW.confirm('<b>¿Esta seguro que desea eliminar ésta configuración de parámetros?</b>',
            {
                title: '<b>Eliminar definición</b>',
                width: 425,
                okLabel: "SI",
                cancelLabel: "NO",
                onOk: function (win) {
                    deleteDefinition(definition_pos);
                    win.close()
                }
            })
        }


        function newValue()
        {
            // Llamamos a a ventana de edición, pero le indicamos que actúe como un ALTA ("A")
            editDefinition("A");
        }


        function onSave()
        {
            // Armar todo el string XML desde el arreglo JSON (parametros)
            var valor = Convert.JSONtoXML(parametros);

            if (!valor) return;

            // Salvar el valor con el método "guardar" del parent
            parent.guardar(idParam, valor, false);
        }


        function deleteDefinition(definition_pos)
        {
            parametros.splice(definition_pos, 1);   // Elimino la posicion actual de los parametros
            onSave();                               // Salvar la nueva configuración de parametría
            drawParameters();                       // Volver a dibujar con los nuevos datos
        }


        function editDefinition(modo, definition_pos)
        {
            if (!modo) modo = 'M';

            if (modo === 'M' && (definition_pos === null || definition_pos === undefined)) return;

            win_edition = nvFW.createWindow({
                title:          '<b>Edición de Parametros</b>',
                width:          750,
                height:         150,
                destroyOnClose: true,
                onShow: function (win)
                {
                    var userData = win.options.userData;
                    if (userData.modo === 'A') return;

                    var param = userData.param;
                    $('gesture_type').value = param.gesture_type;
                    $('pitch_min').value    = param.pitch_min;
                    $('pitch_max').value    = param.pitch_max;
                    $('roll_min').value     = param.roll_min;
                    $('roll_max').value     = param.roll_max;
                    $('yaw_min').value      = param.yaw_min;
                    $('yaw_max').value      = param.yaw_max;
                },
                onClose: function (win)
                {
                    if (win.options.userData.hay_cambios)
                    {
                        switch (win.options.userData.modo.toUpperCase())
                        {
                            case 'A':
                                parametros.push(win.options.userData.param);
                                drawParameters();
                                break;

                            case 'M':
                                parametros[definition_pos] = win.options.userData.param;
                                drawParameters();
                                break;
                        }
                    }
                }
            });

            win_edition.setHTMLContent($('divEdition').innerHTML);
            win_edition.options.userData = {
                "hay_cambios": false,
                "modo": modo,
                "param": modo === "A" ? {} : parametros[definition_pos]
            };
            win_edition.showCenter(true);
        }


        function editDefinition_cancelar()
        {
            win_edition.options.userData.hay_cambios = false;
            win_edition.close();
        }


        function editDefinition_aceptar()
        {
            // Tener en cuenta que todos los objetos de javascrip se asignan por referencia
            var data           = win_edition.options.userData;
            var param          = data.param;
            data.hay_cambios   = true;

            param.gesture_type = $('gesture_type').value;
            param.pitch_min    = parseFloat($('pitch_min').value);
            param.pitch_max    = parseFloat($('pitch_max').value);
            param.roll_min     = parseFloat($('roll_min').value);
            param.roll_max     = parseFloat($('roll_max').value);
            param.yaw_min      = parseFloat($('yaw_min').value);
            param.yaw_max      = parseFloat($('yaw_max').value);

            win_edition.close();
        }


        function window_onresize()
        {

        }


        function window_onload()
        {
            makeButtons();
            loadParameters();
            drawParameters();
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; margin: 0px; padding: 0px; overflow: hidden;">

    <%-- MENU --%>
    <div id="divMenu"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu;
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Definiciones de Angulos en Gestos Selfie (Pitch, Roll, Yaw)</Desc></MenuItem>");
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onSave()</Codigo></Ejecutar></Acciones></MenuItem>");

        vMenu.loadImage("guardar", '/FW/image/icons/guardar.png');
        vMenu.MostrarMenu();
    </script> 


    <%-- DEFINICIONES DE PARAMETROS --%>
    <div id="divTable" style="width: 100%; overflow: auto;"></div>


    <%-- FOOTER PARA AGREGAR NUEVA DEFINICION DE PARAMETROS --%>
    <div id='divAgregar' style='position: absolute; bottom: 0; left: 0; width: 100%; padding: 10px 0; overflow: hidden; text-align: center;'>
        <img alt='add_definition' title='Agregar Definición de Parámetros' style="cursor: pointer;" onclick='newValue()' src='/FW/image/icons/agregar.png' />
    </div>


    <%-- DIV EDICION --%>
    <div id="divEdition" style="display: none; font-size: 13px;">
        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align: center;">Tipo Gesto</td>
                <td style="text-align: center;">Pitch Min</td>
                <td style="text-align: center;">Pitch Max</td>
                <td style="text-align: center;">Roll Min</td>
                <td style="text-align: center;">Roll Max</td>
                <td style="text-align: center;">Yaw Min</td>
                <td style="text-align: center;">Yaw Max</td>
            </tr>
            <tr>
                <td>
                    <input type="text" name="gesture_type" id="gesture_type" value="" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="pitch_min" id="pitch_min" value="" min="-15" max="15" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="pitch_max" id="pitch_max" value="" min="-15" max="15" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="roll_min" id="roll_min" value="" min="-10" max="10" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="roll_max" id="roll_max" value="" min="-10" max="10" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="yaw_min" id="yaw_min" value="" min="-45" max="45" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="yaw_max" id="yaw_max" value="" min="-45" max="45" style="width: 100%;" />
                </td>
            </tr>
        </table>

        <div style="position: absolute; left: 0; bottom: 0; width: 100%; padding: 5px 0; text-align: center;">
            <div id="divCancelar" style="display: inline-block; width: 180px; padding: 0 15px;"></div>
            <div id="divAceptar" style="display: inline-block; width: 180px; padding: 0 15px;"></div>
        </div>
    </div>

</body>
</html>