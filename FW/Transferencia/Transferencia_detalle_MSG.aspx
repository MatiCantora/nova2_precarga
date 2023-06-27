<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<%
    Me.contents("FiltroXML_desde") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='transf_conf'><campos>id_transf_conf as id, transf_conf as [campo]</campos><orden>[campo]</orden></select></criterio>")
    Me.contents("FiltroXML_verOperadores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>*</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")

 %>
<html>
<head>
<title>Transferencia MSG</title>
        <meta http-equiv="x-ua-compatible" content="IE=10">
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/transferencia/css/tags.css" rel="stylesheet" type="text/css" />

        <script type="text/javascript" src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tScript.js"></script>     
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>   
        <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>

        <script type="text/javascript" src="/FW/transferencia/script/tags.js"></script>
      <% = Me.getHeadInit()%>
        <style type="text/css">
            html {
                overflow: auto;
                width: 100%;
                height: 100%;
            }
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
            #editor {
                height: 170px;
            }
            table.table td.title {
                width: 50px;
            }
            table.table td.narrow {
                width: 30px;
            }
            table.table td.actions {
                width: 40px;
            }
            table.table td.Tit1{
                text-align: right;
                vertical-align: central;
                /*font-weight: bold;*/
            }
            #asunto {
                width: 100%;
            }
            .tagger {
                width: 87%;
                float: right;
            }
            #archivosAdjuntos {
                width: auto;
                float: none;
                min-height: 60px;
            }
            #archivosDisponibles {
                text-align: left;
                min-height: 20px;
                background: #FFFFFF;
            }
            .hidden {
                display: none;
            }
            label {
                float: left;
                line-height: 17px;
            }
            .cont {
                clear: both;
                padding: 1px;
            }
            .campDef {
                display: none;
            }
            span.free {
                display: inline-block;
                background: #DDDDDD;
                border: 1px solid #666666;
                padding: 1px 3px;
                cursor: pointer;
                margin: 1px 2px;
                color: #000000;
            }
            img.search,
            img.avanzado {
                cursor: pointer;
                cursor: hand;
            }
            .variablesHelp {
                color: #749BC4;
                cursor: pointer;
                display: inline-block;
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
            }
            .variablesHelp:hover ul {
                display: block;
            }

            /*.transfvariable {
                    padding: 0;
                    margin-left: 1px;
                    background: #FFFF99;
                    border: 1px solid #AAAA77;
                    border-radius: 3px;
                    position: relative;
                    cursor: pointer;
                    color:red !important;
                }*/

            .transfvariable {
                                padding: 0;
                                margin-left: 1px;
                                background: #FFFF99;
                                border: 1px solid #AAAA77;
                                border-radius: 3px;
                                position: relative;
                                cursor: pointer;
                                cursor: hand;
                                color:red !important;
                            }
        </style>
        <script type="text/javascript">
            var transferencia;
            var message;
            var indice = parseInt('<%= nvUtiles.obtenerValor("indice") %>');
            function __beforeAddUser(tag) {
                
                var rs = new tRS();
                rs.open(nvFW.pageContents.FiltroXML_verOperadores,"", "<Login type='like'>" + tag.name + "</Login>","") //"<criterio><select vista='verOperadores'><campos>*</campos><orden></orden><grupo></grupo><filtro><Login type='like'>" + tag.name + "</Login></filtro></select></criterio>");
                var esUnaVariable = __validateVariable(tag.name);
                if (!rs.eof() || esUnaVariable) {
                    if(esUnaVariable) {
                        tag.extras = {
                            operador: tag.name,
                            login: tag.name,
                            strNombreCompleto: tag.name
                        };
                    } else {
                        tag.extras = {
                            operador: rs.getdata('operador'),
                            login: rs.getdata('Login'),
                            strNombreCompleto: rs.getdata('strNombreCompleto')
                        };
                    }
                } else {
                    alert('El usuario ' + tag.name + ' no existe');
                    return false;
                }
                return true;
            }
            function __beforeAddMail(tag) {
                var expression = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (!tag.name.match(expression) && !__validateVariable(tag.name)) {
                    alert('La dirección de mail no es válida');
                    return false;
                }
                return true;
            }
            function __beforeAddXmpp(tag) {
                return __beforeAddMail(tag);
            }
            function __beforeAddArchivo(archivo) {
                var expression_1 = /^([a-zA-Z]:)?(FILE:)?\\{0,2}([_a-z0-9.\$]+\\)*[_a-z0-9.\$]+$/i;
                var expression_2 = /^(FILE:)?\/{0,2}([_a-z0-9.\$]+\/)*[_a-z0-9.\$]+$/i;
                //if (!archivo.name.match(expression_1) && !archivo.name.match(expression_2)) {
                //    alert('El path no es válido');
                //    return false;
               // }
                return true;
            }
            function __validateVariable(variable) {
                return variable.match(/^{{[a-z0-9._]+(\[[a-z0-9._]\]+)?}}$/i);
            }
            function __afterRemoveArchivo(archivo) {
                if (archivo.extras.esArchivo !== undefined) {
                    addFree(archivo);
                }
            }

            function getClearText( strSrc ) {
                    return  strSrc.replace( /<[^<|>]+?>/gi,'' );
            }

            function loadParameters() {
                
                for (var names in message.parametros_extra) {
                    if (typeof (message.parametros_extra[names]) == 'object' && names != 'archivosAdjuntos') {
                        for (var name in message.parametros_extra[names]) {
                            if (typeof(message.parametros_extra[names][name]) != 'function') {
                                setValue(names + '_' + name, message.parametros_extra[names][name]);
                            }
                        }
                    } else {
                        if (typeof(message.parametros_extra[names]) != 'function') {
                            setValue(names, message.parametros_extra[names]);
                        }
                    }
                }
                if (!message.parametros_extra['cuerpo']) {
                    message.parametros_extra['cuerpo'] = '<p></p>';
                }

                CKEDITOR.instances.cuerpo.insertHtml(xmlUnscape(message.parametros_extra['cuerpo']));

                var archivos = parent.parent.getFiles();
                var used = $('archivosAdjuntos').getValue();

                for (var i = 0; i < archivos.length; i++) {
                   archivos[i] =  archivos[i].replace(/' \+ /ig, "{").replace(/ \+ '/ig,'}')
                }

                for (var i = 0; i < used.length; i++) {
                   used[i].name =  used[i].name.replace(/' \+ /ig, "{").replace(/ \+ '/ig,'}')
                 }

                archivos.each(function(archivo) {
                    var doAdd = true;
                    used.each(function(usedF) {
                        if (usedF.name == archivo) {
                            doAdd = false;
                            throw $break;
                        }
                    });
                    if (doAdd) {
                        var tag = {
                            name: archivo,
                            extras: {
                                esArchivo: true
                            }
                        };
                        addFree(tag);
                    }
                });
                variablesHelp();
            }


            function validar()
            {
                var strError = ""

                if (campos_defs.value("desde") == "") {
                    strError = "Seleccione desde donde se enviará la notificación."
                }

                return strError
            }

            function guardar()
            {
                $$('table.table tr.input input[id]').each(function (input) {
                    var id = input.getAttribute('id');
                    if (id) {
                        if (id.indexOf('_') != -1) {
                            var names = id.split('_');
                            message.parametros_extra[names[0]][names[1]] = getValue(input);
                        } else {
                            message.parametros_extra[id] = getValue(input);
                        }
                    }
                });
                $$('table tr.input .tagger').each(function (input) {
                    var id = input.getAttribute('id');
                    if (id) {
                        if (id.indexOf('_') != -1) {
                            var names = id.split('_');
                            message.parametros_extra[names[0]][names[1]] = getValue(input);
                        } else {
                            message.parametros_extra[id] = getValue(input);
                        }
                    }
                });
                
                message.parametros_extra['desde'] = campos_defs.value("desde")
                message.parametros_extra['cuerpo'] = xmlScape(CKEDITOR.instances.cuerpo.getData()) // FCKeditorAPI.GetInstance('cuerpo').GetData();
                return transferencia;
            }

             function xmlScape(valor) {
                var scp = valor;
                if(typeof(scp) == 'string') {
                    scp = scp.replace(/&/g, '&amp;');
                    scp = scp.replace(/</g, '&lt;');
                    scp = scp.replace(/>/g, '&gt;');
                    scp = scp.replace(/"/g, '&quot;');
                    scp = scp.replace(/'/g, '&apos;');
                }
                return scp;
            }
            function xmlUnscape(valor) {
                var scp = valor;
                if(typeof(scp) == 'string') {
                    scp = scp.replace(/&lt;/g, '<');
                    scp = scp.replace(/&gt;/g, '>');
                    scp = scp.replace(/&quot;/g, '"');
                    scp = scp.replace(/&apos;/g, "'");
                    scp = scp.replace(/&amp;/g, '&');
                }
                return scp;
            }

            //function Aceptar() {
                
            //    $$('table.table tr.input input[id]').each(function(input) {
            //        var id = input.getAttribute('id');
            //        if (id) {
            //            if (id.indexOf('_') != -1) {
            //                var names = id.split('_');
            //                message.parametros_extra[names[0]][names[1]] = getValue(input);
            //            } else {
            //                message.parametros_extra[id] = getValue(input);
            //            }
            //        }
            //    });
            //    $$('table tr.input .tagger').each(function(input) {
            //        var id = input.getAttribute('id');
            //        if (id) {
            //            if (id.indexOf('_') != -1) {
            //                var names = id.split('_');
            //                message.parametros_extra[names[0]][names[1]] = getValue(input);
            //            } else {
            //                message.parametros_extra[id] = getValue(input);
            //            }
            //        }
            //    });

            //    //if (campos_defs.value("desde") == "")
            //    // {
            //    //    alert("Seleccione desde donde se enviará la notificación.")
            //    //    return
            //    // }

            //    //var html = CKEDITOR.instances.cuerpo.getSnapshot();
            //    //var dom=document.createElement("DIV");
            //    //dom.innerHTML=html;
            //    //var plain_text=(dom.textContent || dom.innerText);

            //    message.parametros_extra['desde'] = campos_defs.value("desde")
            //    message.parametros_extra['cuerpo'] = CKEDITOR.instances.cuerpo.getData(); // FCKeditorAPI.GetInstance('cuerpo').GetData();
            //    return transferencia;
            //}

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
                            if (campos_defs.items[element.getAttribute('id')] != undefined) {
                                campos_defs.set_value(element.getAttribute('id'), value);
                            }
                            else
                            {
                            if (element.getAttribute('type') == 'checkbox') {
                                if (value == '1') {
                                    element.checked = true;
                                } else {
                                    element.checked = false;
                                }
                            } else {
                                element.value = value;
                            }
                            }
                            break;
                        case 'DIV'://es un campodef
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

            function getValue(element) {
                if (element.tagName == undefined) {
                    element = $(element);
                }
                var value = null;
                switch (element.tagName.toUpperCase()) {
                    case 'SELECT':
                        element.select('option').each(function(option) {
                            if (option.selected) {
                                value = option.value;
                                throw $break;
                            }
                        });
                        break;
                    case 'TEXTAREA':
                    case 'INPUT':
                        if ($(element.getAttribute('id') + '_cd')) {
                            value = campos_defs.get_value(element.getAttribute('id'));
                        }
                        else {
                            if (element.getAttribute('type') == 'checkbox') {
                                if (element.up().select('input:checked').length > 0) {
                                    value = 1;
                                } else {
                                    value = 0;
                                }
                            } else {
                                value = element.value;
                            }
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
            function addUsed(archivo) {
                return $('archivosAdjuntos').setValue(archivo);
            }
            function addFree(archivo) {
                $('archivosDisponibles').show();
                var free = $(document.createElement('span'));
                free.addClassName('free');
                free.update(archivo.name);
                free.observe('click', function() {
                    if (addUsed(archivo)) {
                        free.remove();
//                        if ($$('#archivosDisponibles span.free').length == 0) {
//                            $('archivosDisponibles').hide();
//                        }
                    }
                });
                $('archivosDisponibles').insert({bottom: free});
            }

            function window_onload() {
                
                $$('#para_userText, #cc_userText, #cco_userText').each(function(element) {
                    $(element).taggify({beforeAdd: __beforeAddUser});
                });
                $$('#para_mailText, #cc_mailText, #cco_mailText').each(function(element) {
                    $(element).taggify({beforeAdd: __beforeAddMail});
                });
//                $$('#para_text_xmpp, #cc_text_xmpp, #cco_text_xmpp').each(function(element) {
                $$('#para_xmppText').each(function(element) {
                    $(element).taggify({beforeAdd: __beforeAddXmpp});
                });
                $('archivosAdjuntos').taggify({
                    beforeAdd: __beforeAddArchivo,
                    afterRemove: __afterRemoveArchivo
                });
                
                transferencia = parent.return_Transferencia();
                message = transferencia['detalle'][indice];

                // Nueva implementacion con CKEditor
                CKEDITOR.config.toolbar = 'Transferencia'
                CKEDITOR.config.extraPlugins = 'transferencia';
                CKEDITOR.config.resize_enabled = false;
                CKEDITOR.config.removePlugins = 'elementspath';     // elimina barra inferior         
                CKEDITOR.config.language = "es";
              //  CKEDITOR.config.format_transfvariable = { element: 'transfvariable', attributes: { 'class': 'TransfVariable' } };

                CKEDITOR.replace('cuerpo', {
                    on: {
                        instanceReady: function (event) {
                            window_onresize()
                        }
                    }
                });

                //||
                //CKEDITOR.instances.cuerpo.on("instanceReady", function(event)
                //{
                //    window_onresize()
                //});

                var taggerUnderEdit = false;
                var ejecutar_onchange = false
                campos_defs.items['nro_operador']['onchange'] = function() {
                    if (ejecutar_onchange) {
                        var user = campos_defs.get_desc('nro_operador');
                        user = user.split(' - ')[0].toLowerCase();
                        taggerUnderEdit.setValue(user);
                    }
                    ejecutar_onchange = true;
                };
                $$('.search').each(function(link) {
                    link.observe('click', function(event) {
                        taggerUnderEdit = link.up('tr').select('.tagger.user')[0];
                        ejecutar_onchange = false;
                        campos_defs.clear('nro_operador');
                        campos_defs.onclick('', 'nro_operador', true);
                    });
                });
                $$('.avanzado').each(function(link) {
                    link.observe('click', function () {
                        if (link.hasClassName('showed')) {
                            link.removeClassName('showed');
                            link.up('tr').select('.hCont.showed').each(function(tagger) {
                                tagger.removeClassName('showed');
                                tagger.addClassName('hidden');
                                link.setAttribute('src', link.getAttribute('src').replace('subir', 'bajar'));
                            });
                        } else {
                            link.addClassName('showed');
                            link.up('tr').select('.hCont.hidden').each(function(tagger) {
                                tagger.removeClassName('hidden');
                                tagger.addClassName('showed');
                                link.setAttribute('src', link.getAttribute('src').replace('bajar', 'subir'));
                            });
                        }
                    });
                });

               if(message.parametros_extra.para.mailText.length > 0)
                    $$('.avanzado')[0].click()
               if(message.parametros_extra.cc.mailText.length > 0)
                    $$('.avanzado')[1].click()
               if(message.parametros_extra.cco.mailText.length > 0)
                    $$('.avanzado')[2].click()
                
                loadParameters()
                //window_onresize()
                return true;
            }

            //function FCKeditor_OnComplete(editorInstance) {
                
            //    cuerpoInstance.LinkedField.form.onsubmit = doSave;

            //    window_onresize()
            //}

            function window_onresize()
            {
                try {
                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_height = $$('BODY')[0].getHeight()
                    var cabe_height = $('tbCabe').getHeight()
                    var pie_height = $('tbPie').getHeight()
                    var divCampDef_height = $('divCampDef').getHeight()

                    var alto = (body_height - cabe_height - pie_height - divCampDef_height - dif) //+ 'px'

                    $('divCuerpo').setStyle({ height: alto })
                    CKEDITOR.instances.cuerpo.resize('100%', alto)
                }
                catch (e) {console.log(e.message)}
            }

            function window_onunload() {
                
            }

            function variablesHelp() {
                var varsSel = [
                 /*   "Fecha",
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
                    "Transf.cola_ejecucion[x]"*/
                ];
                parent.Transferencia.parametros.each(function(parametro){
                    varsSel.push(parametro.parametro);
                });
                $$(".variablesHelp").each(function(vh){
                    var ul = $(document.createElement('ul'));
                    vh.insert({bottom : ul});
                    varsSel.each(function(varSel){
                        var li = $(document.createElement('li'));
                        li.observe('click', function(){
                            var input = ul.up('.cont').select('.variable');
                            if(input.length) {
                                var val = getValue(input[0]);
                                if(typeof(val) == 'object') {
                                    val[val.length] = {
                                        name : li.innerHTML,
                                        extras : {}
                                    };
                                } else {
                                    val += li.innerHTML;
                                }
                                setValue(input[0], val);
                            }
                        });
                        li.update('{{' + varSel + '}}');
                        ul.insert({bottom : li});
                    });
                });
            }
        </script>
    </head>
    <body onload="return window_onload();" onresize="return window_onresize()" onunload="return window_onunload();" style="background-color:white; width: 100%;height: 100%;overflow: hidden;">
        <div id="divCampDef" class="campDef">
            <%= nvCampo_def.get_html_input("nro_operador")%>
        </div>
        <table class="tb1 table" id="tbCabe" style="width: 100%">
            <tr class="div">
                <td class="Tit1">Desde</td>
                <td style="width: 100%;" colspan="6">
                   <script type ="text/javascript">                          
                       campos_defs.add('desde', {
                           nro_campo_tipo: 1,
                           enDB: false,
                           filtroXML: nvFW.pageContents.FiltroXML_desde,
                           filtroWhere: "<id_transf_conf type='igual'>%campo_value%</id_transf_conf>"
                       })
                    
                       </script>

                </td>
            </tr>
            <tr class="tbLabel">
                <td class="title"></td>
                <td class="narrow">Pool</td>
                <td class="narrow">Lane</td>
                <td class="narrow">Mail</td>
                <td class="narrow">J.id</td>
                <td style="width: 100%;">Destinatarios</td>
                <td class="actions"></td>
            </tr>
            <tr class="input">
                <td class="Tit1">Para</td>
                <td><input type="checkbox" id="para_pool"/></td>
                <td><input type="checkbox" id="para_lane"/></td>
                <td><input type="checkbox" id="para_mail"/></td>
                <td><input type="checkbox" id="para_xmpp"/></td>
                <td>
                    <div class="cont">
                        <label for="para_userText">Usuario:</label>
                        <div id="para_userText" class="user variable"></div>
                        <span class="variablesHelp">+</span>
                    </div>
                    <div class="cont hCont hidden">
                        <label for="para_mailText">Mail:</label>
                        <div id="para_mailText" class="variable"></div>
                        <span class="variablesHelp">+</span>
                    </div>
                    <div class="cont hCont hidden">
                        <label for="para_xmppText">Jabber id:</label>
                        <div id="para_xmppText" class="variable"></div>
                        <span class="variablesHelp">+</span>
                    </div>
                </td>
                <td style="vertical-align: top; white-space: nowrap;">
                    <img src="/FW/image/transferencia/contactos.png" class="search" />
                    <img src="/FW/image/transferencia/bajar.png" class="avanzado" />
                </td>
            </tr>
            <tr class="input">
                <td class="Tit1">CC</td>
                <td><input type="checkbox" id="cc_pool"/></td>
                <td><input type="checkbox" id="cc_lane"/></td>
                <td><input type="checkbox" id="cc_mail"/></td>
                <td><input type="checkbox" id="cc_xmpp"/></td>
                <td>
                    <div class="cont">
                        <label for="cc_userText">Usuario:</label>
                        <div id="cc_userText" class="user variable"></div>
                        <span class="variablesHelp">+</span>
                    </div>
                    <div class="cont hCont hidden">
                        <label for="cc_mailText">Mail:</label>
                        <div id="cc_mailText" class="variable"></div>
                        <span class="variablesHelp">+</span>
                    </div>
                    <!--div class="cont hCont hidden">
                        <label for="cc_text_xmpp">Xmpp:</label>
                        <div id="cc_text_xmpp"></div>
                    </div-->
                </td>
                <td style="vertical-align: top; white-space: nowrap;">
                    <img src="/FW/image/transferencia/contactos.png" class="search"/>
                    <img src="/FW/image/transferencia/bajar.png" class="avanzado"/>
                </td>
            </tr>
            <tr class="input">
                <td class="Tit1">CCO</td>
                <td><input type="checkbox" id="cco_pool"/></td>
                <td><input type="checkbox" id="cco_lane"/></td>
                <td><input type="checkbox" id="cco_mail"/></td>
                <td><input type="checkbox" id="cco_xmpp"/></td>
                <td>
                    <div class="cont">
                        <label for="cco_userText">Usuario:</label>
                        <div id="cco_userText" class="user variable"></div>
                        <span class="variablesHelp">+</span>
                    </div>
                    <div class="cont hCont hidden">
                        <label for="cco_mailText">Mail:</label>
                        <div id="cco_mailText" class="variable"></div>
                        <span class="variablesHelp">+</span>
                    </div>
                    <!--div class="cont hCont hidden">
                        <label for="cco_text_xmpp">Xmpp:</label>
                        <div id="cco_text_xmpp"></div>
                    </div-->
                </td>
                <td style="vertical-align: top; white-space: nowrap;">
                    <img src="/FW/image/transferencia/contactos.png" class="search" />
                    <img src="/FW/image/transferencia/bajar.png" class="avanzado" />
                </td>
            </tr>
            <tr class="input cont">
                <td class="Tit1">Asunto</td>
                <td colspan="5">
                    <input type="text" id="asunto" class="variable">
                </td>
                <td>
                    <span class="variablesHelp">+</span>
                </td>
            </tr>
       </table>
       <div id="divCuerpo" style="width:100%">
       <table class="tb1 table" id="tbCuerpo" style="width: 100%">
            <tr>
                <td>
                    <textarea id="cuerpo" name="cuerpo"></textarea>
                </td>
            </tr>
      </table>
       </div>
      <table class="tb1 table" id="tbPie" style="width: 100%">
            <tr class="tbLabel" >
                <td colspan="2">Archivos Adjuntos</td>
            </tr>
            <tr class="input">
                <td class="Tit1" style="width: 30px;">Disponibles</td>
                <td>
                    <div id="archivosDisponibles" style="border: 1px solid #CCCCCC; margin-bottom: 1px;"></div>
                </td>
            </tr>
            <tr class="input">
                <td class="Tit1" >
                    Utilizados
                </td>
                <td >
                    <div id="archivosAdjuntos"></div>
                </td>
            </tr>
        </table>
    </body>
</html>