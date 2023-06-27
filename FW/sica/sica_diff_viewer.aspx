<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>SICA Visor de Diferencias</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/tMenu.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <link type="text/css" rel="stylesheet" href="/FW/script/jsdifflib/diffview.css" />
    <script type="text/javascript" src="/FW/script/jsdifflib/difflib.js"></script>
    <script type="text/javascript" src="/FW/script/jsdifflib/diffview.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        
        var win = nvFW.getMyWindow();
        var cod_objeto;
        var cod_obj_tipo;
        var objeto;
        var path_ori;
        var path_dest;
        var cod_modulo_version;
        var cod_servidor;
        var cod_sistema;
        var port;
        var src_base;
        var src_modificado;
        var source1 = {}
        var source2 = {}


        function window_onload()
        {
            objeto                   = win.options.userData.objeto;
            nvFW.enterToTab          = false;
            $('tableName').innerHTML = objeto;
            printMenu();

            if (win.options.userData.es_objeto_complejo)
            {
                // Ocultar todo lo que haga referencia al diferenciador
                $('tbOptions').hide();
                $('tbEncodings').hide();
                $('diffoutput').hide();
                
                // Mostrar la tabla de diferencias
                $('tipoObjeto').innerText = 'objeto tipo ' + win.options.userData.objeto_tipo;
                $('diffTableDiv').show();

                // Insertar los comentarios pertinentes
                if (win.options.userData.diff.source2.comentario) {
                    $('diffTableResult').innerHTML = win.options.userData.diff.source2.comentario;
                }
                else {
                    $('diffTableResult').innerHTML = 'Sin comentarios</br>';
                }
            }
            else
            {
                // comparacion con 10 lineas de contexto por default
                $('showAllLines').click();
                $('contextSize').value = 10;

                var diff       = win.options.userData.diff;
                var objSource1 = diff.source1;
                var objSource2 = diff.source2;

                if (objSource1.modo == "GET_DEF")
                {
                    source1.modo               = "GET_DEF";
                    source1.cod_objeto         = objSource1.cod_objeto;
                    source1.cod_obj_tipo       = objSource1.cod_obj_tipo;
                    source1.objeto             = objSource1.objeto;
                    source1.path               = objSource1.path;
                    source1.cod_modulo_version = objSource1.cod_modulo_version;
                }
                else
                {
                    source1.modo = "GET_IMP";
                    source1.cod_servidor = objSource1.cod_servidor;
                    source1.cod_sistema  = objSource1.cod_sistema;
                    source1.port         = objSource1.port;
                    source1.objeto       = objSource1.objeto;
                    source1.path         = objSource1.path;
                    source1.cod_obj_tipo = objSource1.cod_obj_tipo;
                }

                if (objSource2.modo == "GET_DEF")
                {
                    source2.modo               = "GET_DEF";
                    source2.cod_objeto         = objSource2.cod_objeto;
                    source2.cod_obj_tipo       = objSource2.cod_obj_tipo;
                    source2.objeto             = objSource2.objeto;
                    source2.path               = objSource2.path;
                    source2.cod_modulo_version = objSource2.cod_modulo_version;
                    source2.comentario         = objSource2.comentario;
                }
                else
                {
                    source2.modo = "GET_IMP";
                    source2.cod_servidor = objSource2.cod_servidor;
                    source2.cod_sistema  = objSource2.cod_sistema;
                    source2.port         = objSource2.port;
                    source2.objeto       = objSource2.objeto;
                    source2.path         = objSource2.path;
                    source2.cod_obj_tipo = objSource2.cod_obj_tipo;
                    source2.comentario   = objSource2.comentario;
                }

                var select1      = $('select_encoding1')
                var select2      = $('select_encoding2')
                var encoding1    = select1.options[select1.selectedIndex].value;
                var encoding2    = select2.options[select2.selectedIndex].value;
                source1.encoding = encoding1
                source2.encoding = encoding2

                var onEnd = function ()
                {
                    getSource(source2, "modificado", printOutput)
                }

                getSource(source1, "base", onEnd)

                nvFW.window_key_action["13"] = function (e) {
                    if (src_base && src_modificado) {
                        printOutput();
                    }
                }

                // Si el comentario no está vacío mostar las diferencias de Tabla
                source2.comentario ? $('diffTableDiv').show() : $('diffTableDiv').hide();
                win.maximize();
            }
            
            window_onresize()
        }



        function getSource(source, target, onEnd)
        {
            var url    = '';
            var params = {};

            switch (source.modo)
            {
                case 'GET_DEF':
                    url    = '/FW/sica/get_objeto_def_source.aspx';
                    params = {
                        cod_objeto:         source.cod_objeto,
                        cod_obj_tipo:       source.cod_obj_tipo,
                        objeto:             source.objeto,
                        path:               source.path,
                        cod_modulo_version: source.cod_modulo_version,
                        encoding:           source.encoding
                    }

                    break;


                case 'GET_IMP':
                    url    = '/FW/sica/get_objeto_imp_source.aspx';
                    params = {
                        cod_servidor: source.cod_servidor,
                        cod_sistema:  source.cod_sistema,
                        port:         source.port,
                        objeto:       source.objeto,
                        path:         source.path,
                        cod_obj_tipo: source.cod_obj_tipo,
                        encoding:     source2.encoding
                    }

                    break;
            }


            nvFW.error_ajax_request(url,
            {
                parameters: params,
                onSuccess: function (err)
                {
                    if (err.numError == 0)
                    {
                        if (target == 'base')
                        {
                            src_base = err.params.objetoContent;
                            $('select_encoding1').value = err.params.encoding.toUpperCase();
                        }
                        else
                        {
                            src_modificado = err.params.objetoContent;
                            $('select_encoding2').value = err.params.encoding.toUpperCase();
                        }

                        if (onEnd) onEnd();
                    }
                },
                onFailure: function (err)
                {
                    var errorMsg = "Ocurrío un error obteniedo el objeto desde la ";
                    errorMsg    += (target === 'base' ? 'Definición<br/><br/>': 'Implementación<br/>');
                    errorMsg    += "(" + err.numError + ") " + err.mensaje;
                    
                    alert(errorMsg, {
                        title: "<b>Error</b>",
                        width: 450,
                        height: 110
                    });
                },
                bloq_msg: 'Cargando diferencias...',
                error_alert: false
            });
        }


        function printMenu()
        {
            var vMenuObj = new tMenu('divObjeto', 'vMenuObj');
            Menus.vMenuObj = vMenuObj;
            Menus.vMenuObj.alineacion = 'centro';
            Menus.vMenuObj.estilo = 'A';
            Menus.vMenuObj.CargarMenuItemXML("<MenuItem id='0' style='width: 100%; font-size: medium; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + objeto + "</Desc><Acciones><Ejecutar Tipo='script'><codigo>return false;</codigo></Ejecutar></Acciones></MenuItem>");
            vMenuObj.MostrarMenu();
        }


        function printOutput()
        {
            printTableDiff();

            srcBase       = difflib.stringAsLines(src_base);
            srcModificado = difflib.stringAsLines(src_modificado);

            // create a SequenceMatcher instance that diffs the two sets of lines
            var sm        = new difflib.SequenceMatcher(srcBase, srcModificado);
            // get the opcodes from the SequenceMatcher instance
            // opcodes is a list of 3-tuples describing what changes should be made to the base text
            // in order to yield the new text
            var opcodes             = sm.get_opcodes();
            var diffoutputdiv       = $("diffoutput");
            diffoutputdiv.innerHTML = "";
            var contextSize         = null

            if (!$('showAllLines').checked)
            {
                if ($('contextSize').value != "" && $('contextSize').value >= 0)
                {
                    contextSize = $('contextSize').value;
                }
            } 

            // build the diff view and add it to the current DOM
            diffoutputdiv.appendChild(diffview.buildView({
                baseTextLines: srcBase,
                newTextLines:  srcModificado,
                opcodes:       opcodes,
                // set the display titles for each resource
                baseTextName:  "Definición",
                newTextName:   "Implementación",
                contextSize:   contextSize,
                viewType:      0
            }));
        }



        function printTableDiff()
        {
            if (source2.comentario)
                $('diffTableResult').innerHTML = source2.comentario;
        }



        function window_onresize()
        {
            var body_h         = $$('BODY')[0].getHeight();
            var divHeader_h    = $('divHeader').getHeight();
            // Calcular la altura de las diferencias de tabla, solo si esta visible
            var diffTableDiv_h = $('diffTableDiv').visible() ? $('diffTableDiv').getHeight() : 0;
            var height         = body_h - divHeader_h - diffTableDiv_h;

            if (height > 0) {
                $('diffoutput').setStyle({ height: height + 'px' });
            }
        }



        function getDefSource(select)
        {
            var encoding = select.options[select.selectedIndex].value;
            source1.encoding = encoding
            getSource(source1, "base", printOutput)
        }



        function getImpSource(select) {
            var encoding = select.options[select.selectedIndex].value;
            source2.encoding = encoding
            getSource(source2, "modificado", printOutput)
        }



        function showAllLinesCheck(element)
        {
            if (element.checked) {
                campos_defs.habilitar("contextSize", false);

                if (src_base && src_modificado) {
                    printOutput();
                }
            }
            else {
                campos_defs.habilitar("contextSize", true)
            }
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="height: 100%; width: 100%; overflow: hidden;">
    <div id='divHeader' style="width: 100%">
        <div style="width: 100%" id="divObjeto"></div>

        <table class="tb1" id="tbOptions">
            <tr>
                <td style="white-space: nowrap;" class="Tit2">Mostrar Todo</td>
                <td style="width: 15px;">
                    <input type="checkbox" id="showAllLines" checked="checked" onclick="showAllLinesCheck(this)" title="Mostrar todo" />
                </td>
                <td style="width: 20px;">&nbsp;</td>
                <td id='tdNLineas' style="white-space: nowrap;" class="Tit2">Nº Lineas en Contexto: </td>
                <td style="min-width: 80px;">
                    <% = nvCampo_def.get_html_input("contextSize", enDB:=False, nro_campo_tipo:=100) %>
                    <script type="text/javascript">
                        campos_defs.set_value("contextSize", 100);
                        campos_defs.habilitar("contextSize", false);
                    </script>
                </td>
                <td style="width: 100%;">&nbsp;</td>
            </tr>
        </table>

        <table class="tb1" id="tbEncodings">
            <tr>
                <td>
                    <div style="float: left">
                        <select id="select_encoding1" onchange="getDefSource(this)">
                            <option value="ISO-8859-1">ISO-8859-1</option>
                            <option value="UTF-8">UTF-8</option>
                        </select>
                    </div>

                    <div style="float: right">
                        <select id="select_encoding2" onchange="getImpSource(this)">
                            <option value="ISO-8859-1">ISO-8859-1</option>
                            <option value="UTF-8">UTF-8</option>
                        </select>
                    </div>
                </td>
            </tr>
        </table>
    </div>

    <div id="diffoutput" style="width: 100%; overflow: auto; background-color: white;"></div>

    <%-- Muestra las diferencias SOLO de TABLA --%>
    <div id="diffTableDiv" style="display: none; width: 100%; height: 200px; overflow: hidden; border: 1px solid #ceced0;">
        <table class="tb1" style="height: 22px; border-collapse: collapse;">
            <tr>
                <td class="Tit1" style="border-radius: 0;">Diferencias en estructura de <span id="tipoObjeto">tabla</span> <span id="tableName" style="font-weight: bold;">NAME</span></td>
            </tr>
        </table>

        <div style="height: calc(100% - 22px); overflow: auto;">
            <table class="tb1" style="height: 100%; border-collapse: collapse;">
                <tr>
                    <td id="diffTableResult" style="padding: 5px; vertical-align: top;"></td>
                </tr>
            </table>
        </div>
    </div>

</body>
</html>