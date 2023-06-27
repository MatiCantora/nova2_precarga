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
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var idParam    = nvFW.pageContents.idParam;
        var parametros = [];
        var win_edition;
        var vButtonItems = [];
        var vListButton;


        var Convert =
        {
            JSONtoXML: function(objJSONArray)
            {
                if (!objJSONArray.length) return "<parametros></parametros>";

                var strXML = "<parametros>";
                var param = null;

                for (var i = 0; i < objJSONArray.length; i++)
                {
                    param = objJSONArray[i];
                    strXML += "<parametro>";
                    strXML += "<image_type>" + param.image_type + "</image_type>";
                    strXML += "<width>" + param.width + "</width>";
                    strXML += "<height>" + param.height + "</height>";
                    strXML += "<compression>" + param.compression + "</compression>";
                    strXML += "<percent_min_target_width>" + param.percent_min_target_width + "</percent_min_target_width>";
                    strXML += "<percent_min_target_height>" + param.percent_min_target_height + "</percent_min_target_height>";
                    strXML += "</parametro>";
                }

                strXML += "</parametros>";
                return strXML;
            },

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
                                'image_type':                NOD.getElementsByTagName("image_type") ? NOD.getElementsByTagName("image_type")[0].textContent : '',
                                'width':                     NOD.getElementsByTagName("width") ? parseInt(NOD.getElementsByTagName("width")[0].textContent) : 0,
                                'height':                    NOD.getElementsByTagName("height") ? parseInt(NOD.getElementsByTagName("height")[0].textContent) : 0,
                                'compression':               NOD.getElementsByTagName("compression") ? parseInt(NOD.getElementsByTagName("compression")[0].textContent) : 0,
                                'percent_min_target_width':  NOD.getElementsByTagName("percent_min_target_width") ? parseInt(NOD.getElementsByTagName("percent_min_target_width")[0].textContent) : 0,
                                'percent_min_target_height': NOD.getElementsByTagName("percent_min_target_height") ? parseInt(NOD.getElementsByTagName("percent_min_target_height")[0].textContent) : 0
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
            htmlDialog += "<table id='tbParametria' class='tb1 highlightOdd highlightTROver layout_fixed'>" +
                            "<tr class='tbLabel'>" +
                                "<td style='width:5%; text-align: center'>-</td>" +
                                "<td style='text-align: center;'>Tipo Imagen</td>" +
                                "<td style='text-align: center;'>Ancho</td>" +
                                "<td style='text-align: center;'>Alto</td>" +
                                "<td style='text-align: center;' title='Factor de compresión de imagen'>Compresión</td>" +
                                "<td style='text-align: center;' title='Porcentaje de Ancho mínimo que debe ocupar el objetivo en la captura'>% Ancho min</td>" +
                                "<td style='text-align: center;' title='Porcentaje de Alto mínimo que debe ocupar el objetivo en la captura'>% Alto min</td>" +
                            "</tr>";

            // Armado de las filas
            var param;

            for (var i = 0; i < parametros.length; i++)
            {
                param = parametros[i];
                htmlDialog += "<tr id='tr" + i + "'>" +
                                "<td style='width:5%;text-align:center'>" +
                                    "<img title='Eliminar Definición' onclick='deleteValue(" + i + ")' src='/FW/image/icons/eliminar.png' style='cursor: pointer' />" +
                                    "<img title='Editar Definición' onclick='editDefinition(\"M\"," + i + ")' src='/FW/image/icons/editar.png' style='cursor: pointer' />" +
                                "</td>" +
                                "<td style=''>" + param.image_type + "</td>" +
                                "<td style='text-align: right;'>" + param.width + "</td>" +
                                "<td style='text-align: right;'>" + param.height + "</td>" +
                                "<td style='text-align: right;'>" + param.compression + "</td>" +
                                "<td style='text-align: right;'>" + param.percent_min_target_width + "</td>" +
                                "<td style='text-align: right;'>" + param.percent_min_target_height + "</td>" +
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

            /**
            *   valor:
            *
            *       <parametros>
            *           <parametro>     //////// Esta sub-estructura ("parametro") se puede repetir como tantos parametros querramos
            *               <image_type>dni_frente</image_type>
            *               <width>1200</width>
            *               <height>900</height>
            *               <compression>80</compression>
            *               <percent_min_target_width>95</percent_min_target_width>
            *               <percent_min_target_height>95</percent_min_target_height>
            *           </parametro>
            *       </parametros>
            */

            parametros = Convert.XMLtoJSONArray(valor);

            //try
            //{
            //    var oXml = new tXML();

            //    if (oXml.loadXML(valor))
            //    {
            //        parametros.length = 0;  // Vaciar el contenedor
            //        var xml_parametros = oXml.selectNodes('/parametros/parametro');
            //        var NOD = null;
            //        var obj = null;

            //        for (var i = 0; i < xml_parametros.length; i++)
            //        {
            //            NOD = xml_parametros[i];
            //            obj = {
            //                'image_type':                NOD.getElementsByTagName("image_type") ? NOD.getElementsByTagName("image_type")[0].textContent : '',
            //                'width':                     NOD.getElementsByTagName("width") ? parseInt(NOD.getElementsByTagName("width")[0].textContent) : 0,
            //                'height':                    NOD.getElementsByTagName("height") ? parseInt(NOD.getElementsByTagName("height")[0].textContent) : 0,
            //                'compression':               NOD.getElementsByTagName("compression") ? parseInt(NOD.getElementsByTagName("compression")[0].textContent) : 0,
            //                'percent_min_target_width':  NOD.getElementsByTagName("percent_min_target_width") ? parseInt(NOD.getElementsByTagName("percent_min_target_width")[0].textContent) : 0,
            //                'percent_min_target_height': NOD.getElementsByTagName("percent_min_target_height") ? parseInt(NOD.getElementsByTagName("percent_min_target_height")[0].textContent) : 0
            //            };

            //            parametros.push(obj);
            //        }
            //    }
            //}
            //catch(e)
            //{
            //    console.error("No se cargaron los datos.");
            //}
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
            if (!modo) modo = "M";

            if (modo === 'M' && (definition_pos === null || definition_pos === undefined)) return;

            win_edition = nvFW.createWindow({
                title:          '<b>Edición de Parametros</b>',
                width:          750,
                height:         150,
                destroyOnClose: true,
                onShow: function (win)
                {
                    var userData = win.options.userData;
                    if (userData.modo === "A") return;

                    var param = userData.param;
                    $('image_type').value                = param.image_type;
                    $('width').value                     = param.width;
                    $('height').value                    = param.height;
                    $('compression').value               = param.compression;
                    $('percent_min_target_width').value  = param.percent_min_target_width;
                    $('percent_min_target_height').value = param.percent_min_target_height;
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
            var data         = win_edition.options.userData;
            var param        = data.param;
            data.hay_cambios = true;

            param.image_type                = $('image_type').value;
            param.width                     = parseInt($('width').value);
            param.height                    = parseInt($('height').value);
            param.compression               = parseInt($('compression').value);
            param.percent_min_target_width  = parseInt($('percent_min_target_width').value);
            param.percent_min_target_height = parseInt($('percent_min_target_height').value);

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
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Definiciones de Tamaño de Imagen</Desc></MenuItem>");
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
                <td style="text-align: center;">Tipo Imagen</td>
                <td style="text-align: center;">Ancho</td>
                <td style="text-align: center;">Alto</td>
                <td style="text-align: center;">Compresión</td>
                <td style="text-align: center;">% Ancho min</td>
                <td style="text-align: center;">% Alto min</td>
            </tr>
            <tr>
                <td>
                    <input type="text" name="image_type" id="image_type" value="" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="width" id="width" value="" min="50" max="3000" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="height" id="height" value="" min="50" max="2000" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="compression" id="compression" value="" min="60" max="100" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="percent_min_target_width" id="percent_min_target_width" value="" min="70" max="100" style="width: 100%;" />
                </td>
                <td>
                    <input type="number" name="percent_min_target_height" id="percent_min_target_height" value="" min="70" max="100" style="width: 100%;" />
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