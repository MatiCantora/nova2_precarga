<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
<head>
<title>Transferencia Detalle USR</title>
    <meta http-equiv="X-UA-Compatible" content="IE=8"/>
    <!--meta charset='utf-8'-->
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
    <script type="text/javascript" src="/FW/transferencia/script/tags.js"></script>            

        <style type="text/css">
            table.table {
                width: 100%;
            }
            table.table td {
                text-align: center;
            }
            table.table textarea,
            table.table input[type="text"] {
                width: 100%;
            }
            tr.tbLabel td {
                padding: 1px 2px !important;
            }
            td.left {
                text-align: left;
            }
            td.center {
                text-align: center;
            }
            .tb2 td.tipo,
            .tb2 td.descargable {
                width: 32px;
            }
            .tb2 td.tipo select{
                width: 100px;
            }
            td {
                border-bottom: 1px solid #FFFFFF;
            }
            label {
                position: relative;
                bottom: 2px;
            }
            div#frees {
               /* background: #E9F0F4;*/
            }
            span.free {
                display: inline-block;
                background: #DDDDDD;
                border: 1px solid #666666;
                padding: 5px;
                cursor: pointer;
                margin: 1px 2px;
                color: #000000;
            }
             .variablesHelp {
                color: #749BC4;
                cursor: pointer;
                display: block;
                font-size: 18px;
                font-weight: bold;
                height: 16px;
                line-height: 14px;
                position: relative;
                width: 16px;
                   
            }
            .variablesHelp ul {
                display: none;
                position: absolute;
                right: 9px;
                top: -4px;
                background: #FFFFCC;
                border: 1px solid #000000;
                text-align: left;
                font-size: 12px;
                list-style-type: none;
                padding: 2px 20px 2px 2px;
                font-weight: normal;
                color: #444444;
                max-height: 150px;
                overflow-y: auto;
                overflow-x: hidden;
                border-radius: 5px;
                z-index:1;

            }
            .variablesHelp:hover ul {
                display: inline-block;   
            }
        </style>
        <script type="text/javascript">
            var transferencia;
            var usr;
            var indice = parseInt('<%= nvUtiles.obtenerValor("indice") %>');
            
            function addFree(parametro) {
                $('libres').show();
                var free = $(document.createElement('span'));
                free.addClassName('free');
                free.update('<b>' + parametro.parametro + '</b> [' + parametro.tipo_dato + ']');
                free.observe('click', function() {
                    free.remove();
                    addUsed(parametro);
                    if ($$('#frees span.free').length == 0) {
                        $('libres').hide();
                    }
                });

                $('frees').insert({bottom: free});
            }

            function addUsed(parametro) {
                var tbody = $$('#table_cont tbody')[0];
                var tr = $(document.createElement('tr'));

                var td = $(document.createElement('td'));
                td.update('<b>' + parametro.parametro + '</b> [' + parametro.tipo_dato + ']');

                var input = $(document.createElement('input'));
                input.setAttribute('type', 'hidden');
                input.addClassName('name');
                input.value = parametro.parametro;
                td.insert({bottom: input});

                tr.insert({bottom: td});
                //----------------------------------
                td = $(document.createElement('td'));
                td.addClassName('tipo');
                var select = $(document.createElement('select'));
                select.addClassName('tipo');
                var options = {
                    visible: 'Visible',
                    editable: 'Editable',
                    requerido: 'Requerido'
                }
                var option;
                for (var i in options) {
                    option = $(document.createElement('option'));
                    option.setAttribute('value', i);
                    option.innerHTML = options[i];
                    select.insert({bottom: option});
                }
                if (usr.parametros_det[parametro.parametro] != undefined) {
                    select.select('option[value="' + usr.parametros_det[parametro.parametro].tipo + '"]')[0].selected = true;
                }
                td.insert({bottom: select});
                tr.insert({bottom: td});
                //----------------------------------
                td = $(document.createElement('td'));
                td.addClassName('center descargable');

                var checkbox = $(document.createElement('input'));
                checkbox.addClassName('descargable');
                checkbox.setAttribute('type', 'checkbox');
                checkbox.checked = usr.parametros_det[parametro.parametro] == undefined ? false : usr.parametros_det[parametro.parametro].descargable;
                td.insert({bottom: checkbox});

                if (parametro.tipo_dato != 'file') {
                    checkbox.checked = false;
                    checkbox.disable();
                }

                tr.insert({bottom: td});
                //----------------------------------
                td = $(document.createElement('td'));
                td.addClassName('left');
                input = $(document.createElement('input'));
                input.addClassName('valor_defecto_editable');
                input.setStyle({
                    width: '100%'
                });

                if (parametro.tipo_dato == 'file') {
                    input.value = '';
                    input.disable();
                } else {
                    if (usr.parametros_det[parametro.parametro] == undefined) {
                        input.value = parametro.valor_defecto_editable;
                    } else {
                        input.value = usr.parametros_det[parametro.parametro].valor_defecto_editable;
                    }
                }
                td.insert({bottom: input});
                tr.insert({bottom: td});
                //----------------------------------
                td = $(document.createElement('td'));
                td.addClassName('left');
                input = $(document.createElement('input'));
                input.addClassName('label');
                input.setStyle({
                    width: '100%'
                });
                if (usr.parametros_det[parametro.parametro] == undefined) {
                    if (parametro.etiqueta != '') {
                        input.value = parametro.etiqueta;
                    } else {
                        input.value = parametro.parametro;
                    }
                } else {
                    input.value = usr.parametros_det[parametro.parametro].label;
                }
                td.insert({bottom: input});
                tr.insert({bottom: td});
                //------------------------------------
                td = $(document.createElement('td'));
                var img = $(document.createElement('img'));
                img.setAttribute('src', '/FW/image/tnvRect/delete.png');
                img.observe('click', function() {
                    tr.remove();
                    addFree(parametro);
                    window_onresize()
                });
                td.insert({bottom: img});

                img = $(document.createElement('img'));
                img.setAttribute('src', '/FW/image/transferencia/arrow_up.png');
                img.observe('click', function() {
                    var prev = tr.previous();
                    if (prev) {
                        prev.insert({before: tr});
                    }
                });
                td.insert({bottom: img});

                img = $(document.createElement('img'));
                img.setAttribute('src', '/FW/image/transferencia/arrow_down.png');
                img.observe('click', function() {
                    var next = tr.next()
                    if (next) {
                        next.insert({after: tr});
                    }
                });
                td.insert({bottom: img});

                tr.insert({bottom: td});
                //------------------------------------
                tbody.insert({bottom: tr});
            }

            function window_onload() {
                $('libres').hide();
                transferencia = parent.return_Transferencia();
                usr = transferencia['detalle'][indice];
                
                var ordered_params = [];
                var postProcess = [];

                transferencia.parametros.each(function(parametro) {
                    if (usr.parametros_det[parametro.parametro] == undefined) {
                        addFree(parametro);
                    } else {
                        parametro.tmp_order = usr.parametros_det[parametro.parametro].orden;
                        ordered_params.push(parametro);
                    }
                });
                ordered_params.sort(function(a, b) {
                    return a.tmp_order - b.tmp_order;
                });
                ordered_params.each(function(par) {
                    addUsed(par);
                });
                
                $('resumen').value = !usr.parametros_extra['resumen'] ? "" : usr.parametros_extra['resumen'];
                $('verComentarios').checked = usr.parametros_extra['verComentarios'] == 1;
                $('avanzado').observe('click', function(){
                    var w = window.parent.nvFW != undefined ? window.parent.nvFW : nvFW;
                    win = w.createWindow({
                        className: 'alphacube',
                        url: '/FW/transferencia/Transferencia_detalle_USR_avanzado.aspx',
                        title: 'Avanzado',
                        minimizable: true,
                        maximizable: true,
                        draggable: true,
                        width: $$('body')[0].getWidth() - 20,
                        height: $$('body')[0].getHeight(),
                        resizable: false,
                        onClose: function(){
                            
                        }
                    });
                    win.options.usr = usr;
                    win.options.parametros_det = getParametrosDet();
                    win.showCenter(true);
                    return false;
                });

                setTimeout(loadParameters, 1500);

                window_onresize()
            }
            function getParameter(name) {
                var parameter = null;
                transferencia.parametros.each(function(parametro) {
                    if (parametro.parametro == name) {
                        parameter = parametro;
//                        throw $break;
                    }
                });
                return parameter;
            }
            function getParametrosDet() {
                var parametros_det = {};
                var orden = 0;
                $$('#table_cont tbody tr').each(function(tr) {
                    var tipo = getValue(tr.select('select.tipo')[0]);
                    var name = tr.select('input.name')[0].value;
                    parametros_det[name] = {};
                    parametros_det[name].parameter = getParameter(name);
                    parametros_det[name].tipo = tipo;
                    parametros_det[name].descargable = tr.select('input.descargable:checked').length > 0;
                    parametros_det[name].label = tr.select('input.label')[0].value;
                    parametros_det[name].valor_defecto_editable = tr.select('input.valor_defecto_editable')[0].value;
                    parametros_det[name].orden = orden++;
                });
                return parametros_det;
            }

            function validar() {

                var strError = ''

                var parametros_det = getParametrosDet();
                var validate = true;

                if (usr.parametros_extra.usarInputsPersonalizados) {
                    var tmp_parametros_det_need = [];
                    var tmp_parametros_det_used = [];
                    for (var i in parametros_det) {
                        tmp_parametros_det_need.push(parametros_det[i].parameter.parametro);
                    }
                    var tmp = $(document.createElement('div'));
                    tmp.update(usr.parametros_extra.inputs);
                    var tups = tmp.select('transfusrparametro');
                    tups.each(function (tup) {
                        tmp_parametros_det_used.push(tup.getAttribute('parametro'));
                    });

                    var diff = tmp_parametros_det_need.filter(function (item) {
                        return tmp_parametros_det_used.indexOf(item) == -1;
                    });
                    validate &= diff.length == 0;
                    if (diff.length != 0) {
                        strError = "Faltan los parametros " + diff.join(', ') + " en el formulario"
                    }

                    diff = tmp_parametros_det_used.filter(function (item) {
                        return tmp_parametros_det_need.indexOf(item) == -1;
                    });
                    validate &= diff.length == 0;
                    if (diff.length != 0) {
                        strError += "Se utilizan los parametros " + diff.join(', ') + " en el formulario y estos no son utilizados en el USR detalle"
                    }
                }

                return strError 
            }

            function guardar() {

                var parametros_det = getParametrosDet();
                
                usr.parametros_det = parametros_det;
                usr.parametros_extra['verComentarios'] = $('verComentarios').checked ? 1 : 0;
                usr.parametros_extra['resumen'] = $('resumen').value;

                //Carga El Objeto  
                usr["orden"] = indice;
                usr["transferencia"] = parent.transferencia.value;
                usr["opcional"] = parent.opcional.checked;
                usr["transf_estado"] = parent.estado.value;
                return transferencia;

            }

            //function Aceptar() {
            //    var parametros_det = getParametrosDet();
            //    var validate = true;
            //    if(usr.parametros_extra.usarInputsPersonalizados) {
            //        var tmp_parametros_det_need = [];
            //        var tmp_parametros_det_used = [];
            //        for(var i in parametros_det) {
            //            tmp_parametros_det_need.push(parametros_det[i].parameter.parametro);
            //        }
            //        var tmp = $(document.createElement('div'));
            //        tmp.update(usr.parametros_extra.inputs);
            //        var tups = tmp.select('transfusrparametro');
            //        tups.each(function(tup){
            //            tmp_parametros_det_used.push(tup.getAttribute('parametro'));
            //        });
                    
            //        var diff = tmp_parametros_det_need.filter(function(item){
            //            return tmp_parametros_det_used.indexOf(item) == -1;
            //        });
            //        validate &= diff.length == 0;
            //        if(diff.length != 0) {
            //            alert ("Faltan los parametros " + diff.join(', ') + " en el formulario");
            //        }
                    
            //        diff = tmp_parametros_det_used.filter(function(item){
            //            return tmp_parametros_det_need.indexOf(item) == -1;
            //        });
            //        validate &= diff.length == 0;
            //        if(diff.length != 0) {
            //            alert ("Se utilizan los parametros " + diff.join(', ') + " en el formulario y estos no son utilizados en el USR detalle");
            //        }
            //    }
                
            //    if(validate) {
            //        usr.parametros_det = parametros_det;
            //        usr.parametros_extra['verComentarios'] = $('verComentarios').checked ? 1 : 0;
            //        usr.parametros_extra['resumen'] = $('resumen').value;

            //        //Carga El Objeto  
            //        usr["orden"] = indice;
            //        usr["transferencia"] = parent.transferencia.value;
            //        usr["opcional"] = parent.opcional.checked;
            //        usr["transf_estado"] = parent.estado.value;
            //        return transferencia;
            //    }
            //}

            function getValue(select) {
                var selected = null;
                if (select) {
                    select.select('option').each(function(option) {
                        if (option.selected) {
                            selected = option.value;
                            throw $break;
                        }
                    });
                }
                return selected;
            }
            function window_onunload() {
                
            }
            function window_onresize() {
                try {

                    var dif = Prototype.Browser.IE ? 10 : 4
                    var body_heigth = $$('body')[0].getHeight()

                    var alto_parametros = 0
                    contenedores = $('divCabe').querySelectorAll(".contenedor")
                    for (var i = 0; i < contenedores.length; i++) {
                        if (contenedores[i].style.display != 'none')
                            alto_parametros = alto_parametros + contenedores[i].getHeight()
                    }

                    $('div_table_cont').setStyle({ 'height': body_heigth - alto_parametros })

                }
                catch (e) {}
            }

            function setValue(element, value) {
                if (element.tagName == undefined) {
                    var elementName = element;
                    element = $(element);
                }
                if (!element) {
                    //console.log(elementName)
                }
                if (element && element.tagName != undefined) {
                    switch (element.tagName.toUpperCase()) {
                        case 'SELECT':
                            var option = element.select('option[value="' + value + '"]');
                            if (option.length > 0) {
                                option[0].selected = true;
                            }
                            break;
                        case 'INPUT':
                            if (element.getAttribute('type') == 'checkbox') {
                                if (value == '1') {
                                    element.checked = true;
                                } else {
                                    element.checked = false;
                                }
                            } else {
                                element.value = value;
                            }
                            break;
                        case 'DIV': //es un campodef
                            if (element.hasClassName('tagger')) {
                                element.setValue(value);
                            } else {
                                campos_defs.set_value(element.getAttribute('id') + '_cd', value);
                            }
                            break;
                        case 'TEXTAREA':
                            try {
                                element.update(value);
                            } catch (e) {
                                //IExplorer
                            }
                            break;
                    }
                }
            }

            function variablesHelp() {
                var varsSel = [
                    "Fecha",
                    "Transf.id_transferencia",
                    "Transf.nombre",
                    "Transf.habi",
                    "Transf.timeout",
                    "Transf.estado",
                    "Transf.id_transf_log",
                    "Transf.transf_det_pendiente",
                    "Transf.cola_ejecucion",
                    "Transf.tareas[x]",
                    "Transf.param[x]",
                    "Transf.cola_ejecucion[x]"
                ];
                parent.Transferencia.parametros.each(function (parametro) {
                    varsSel.push(parametro.parametro);
                });
                $$(".variablesHelp").each(function (vh) {
                    
                    var ul = $(document.createElement('ul'));
                    vh.insert({ bottom: ul });
                    varsSel.each(function (varSel) {

                        var li = $(document.createElement('li'));
                        li.observe('click', function () {
                        
                            var input = ul.up('.cont').select('.variable');
                            if (input.length) {
                                var val = getValue(input[0]);
                                if (typeof (val) == 'object') {
                                    val[val.length] = {
                                        name: li.innerHTML,
                                        extras: {}
                                    };
                                } else {
                                    val += li.innerHTML;
                                }
                                setValue(input[0], val);
                            }
                        });
                        li.update('{{' + varSel + '}}');
                        ul.insert({ bottom: li });
                    });
                });
            }

            function getValue(element) {
                if (element.tagName == undefined) {
                    element = $(element);
                }
                var value = null;
                switch (element.tagName.toUpperCase()) {
                    case 'SELECT':
                        element.select('option').each(function (option) {
                            if (option.selected) {
                                value = option.value;
                                throw $break;
                            }
                        });
                        break;
                    case 'TEXTAREA':
                    case 'INPUT':
                        if (element.getAttribute('type') == 'checkbox') {
                            if (element.up().select('input:checked').length > 0) {
                                value = 1;
                            } else {
                                value = 0;
                            }
                        } else {
                            value = element.value;
                        }
                        break;
                    case 'DIV':
                        if (element.hasClassName('tagger')) {
                            value = element.getValue();
                        } else {
                            value = campos_defs.get_value(element.getAttribute('id') + '_cd');
                        }
                        break;
                    //                    case 'TEXTAREA': 
                    //                        value = element.value 
                    //                        break; 
                }
                return value;
            }

            function loadParameters() {
               
                variablesHelp();
            }
        </script>
    </head>
    <body onload="return window_onload()" onresize="return window_onresize()" onunload="return window_onunload()" style="width:100%;height:100%;overflow:hidden">
        <div id="divCabe" style="width:100%">
            <table class="tb1 contenedor" style="width:100%">
                 <tr>
                   <td class="Tit4" colspan="6" style="text-align:left">Visualizar Comentario:</td>
                </tr>
                <tr>
                    <td style="width: 100%;text-align:left">
                        <input type="checkbox" id="verComentarios" />
                        <label for="verComentarios">Al ejecutarse la tarea de usuario desea ver el modulo de comentario.</label>
                    </td>
                </tr>
               <tr style="display:none">
                    <td>
                        <a href="#" id="avanzado">Avanzado</a>
                    </td>
                </tr>
                </table>
                <table class="tb1 table contenedor" style="width:100%">
                <tr>
                   <td class="Tit4" colspan="2" style="text-align:left">Descripción Dinamica:</td>
                </tr>
                <tr>
                   <td colspan="2" style="width: 100%;text-align:left">En caso que se quiera generar una descripción dinamica de la tarea. Se utiliza para su posterior identificación.</td>
                </tr>
                <tr class="input cont">
                    <td style="width: 98%;">
                        <input type="text" class="variable" id="resumen" style="width:100%" value=""/>
                    </td>
                    <td>
                     <span class="variablesHelp" style="width:100%">+</span>
                    </td>
                </tr>
            </table>
            <table id="libres" class="tb1 contenedor" style="width: 100%">
                <tbody>
                  <tr>
                   <td class="Tit4" colspan="2" style="text-align:left">Parámetros a Seleccionar:</td>
                    </tr>
                    <tr class="tbLabel">
                        <%--<td class="left" style="width: 40px">Parámetros:</td>--%>
                        <td style="text-align: left;"><div id="frees"></div>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div id="div_table_cont" style="width:100%;overflow:auto">
            <table class="tb1" style="width:100%" id="table_cont">
                <thead>
                    <tr>
                        <td class="Tit4" colspan="6" style="text-align:left">Parámentros Seleccionados:</td>
                    </tr>
                    <tr class="tbLabel">
                        <td class="left">Parámetro</td>
                        <td>Tipo</td>
                        <td>Descargable</td>
                        <td class="center" style="width: 150px;">Valor por defecto</td>
                        <td class="center" style="width: 150px;">Etiqueta</td>
                        <td class="center" style="width: 10px;">&nbsp;</td>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
            </div>
            
        </div>
    </body>
</html>