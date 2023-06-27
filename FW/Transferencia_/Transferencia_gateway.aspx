<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<%

    Me.contents("filtroTransf_diccionario") = nvXMLSQL.encXMLSQL("<criterio><select vista='transf_diccionario'><campos>distinct transf_dic_var,transf_dic_var_desc</campos><filtro></filtro><orden>transf_dic_var_desc</orden></select></criterio>")
    Me.contents("filtrotransf_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='transf_tipos'><campos>distinct (rtrim(transf_tipo)) as transf_tipo</campos><orden>transf_tipo</orden><grupo></grupo><filtro></filtro></select></criterio>")

%>
<html>
<head>
<title>Transferencia Detalle GATEWAY</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     


    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/doc/docs.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/lib/codemirror.css" />

    <script src="/FW/Transferencia/script/CodeMirror/lib/codemirror.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/lib/util/loadmode.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/meta.js" type="text/javascript"></script>
    
    <script src="/FW/Transferencia/script/CodeMirror/mode/javascript/javascript.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/vb/vb.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/clike/clike.js" type="text/javascript"></script>
    
    <%= Me.getHeadInit()  %>
        <style type="text/css">
            ul.rels {
                padding: 1px;
                margin: 0px;
            }
            ul.rels li {
                width: 250px;
                list-style: none;
                padding: 1px 1px 1px 5px;
                background: #FFFFFF;
                border: 1px solid #d0d0d0;
                height: 16px;
            }
            .move {
                width: 16px;
                height: 16px;
                float: right;
            }
            .move.up {
                /*background: url('/meridiano/image/icons/subir.png');*/
                background: url('/FW/image/transferencia/arrow_up.png');
            }
            .move.down {
                /*background: url('/meridiano/image/icons/bajar.png');*/
                background: url('/FW/image/transferencia/arrow_down.png');
            }
        </style>
        <script type="text/javascript">

            var win;
            var gateway;
            var tempRel = [];
            var Transferencia;

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

            function window_onload() {
                
                nvFW.enterToTab = false
                
                win = nvFW.getMyWindow();
                gateway = win.options.Gateway;
                Transferencia = win.options.Transferencia 

                if (!gateway.parametros_extra.RectId)
                    gateway.parametros_extra.RectId = gateway.id

                $('title').value = gateway.title;
                CargarTransf_Tipo($("cb_transf_tipo"), gateway.transf_tipo)

                var select = $('default');
                gateway.relations.each(function(relation, index) {
                    if (relation.src == gateway && relation.dest.transf_tipo != 'annotation') {
                        var option = $(document.createElement('option'));
                        var title_tmp = relation.title == '' ? relation.dest.title + ' [' + relation.dest.transf_tipo + ']' : relation.title;
                        option.update(title_tmp);
                        option.selected = gateway.amIDefault(relation);
                        option.setAttribute('value', index);
                        select.insert({bottom: option});
                    }
                });
                
                var select = $('output_false');
                gateway.relations.each(function (relation, index) {
                    if (relation.src == gateway && relation.dest.transf_tipo != 'annotation') {
                        var option = $(document.createElement('option'));
                        var title_tmp = relation.title == '' ? relation.dest.title + ' [' + relation.dest.transf_tipo + ']' : relation.title;
                        option.update(title_tmp);
                        option.selected = gateway.amIDOutPutFalse(relation);
                        option.setAttribute('value', index);
                        select.insert({ bottom: option });
                    }
                });
                
                if (gateway.transf_tipo == 'IF') {

                    setContent('js', 'evaluacion', '')

                    $('tr_default').hide();
                    $('default').value = '';

                    $('tr_output_false').hide();
                    $('output_false').value = '';

                    gateway.parametros_extra.op_evaluacion = xmlUnscape(gateway.parametros_extra.op_evaluacion)
                    gateway.parametros_extra.op_evaluacion = gateway.parametros_extra.op_evaluacion.replace("<![CDATA[", "").replace("]]>", "")
                    $("evaluacion").value = gateway.parametros_extra.op_evaluacion
                    editor.setValue($("evaluacion").value);

                    var select = $('sel_si');
                    var encontro = false
                    gateway.relations.each(function (relation, index) {
                        tempRel.push(relation);
                        if (relation.src == gateway && relation.dest.transf_tipo != 'annotation') {
                                                    
                            var option = $(document.createElement('option'));
                            var title_tmp = relation.dest.title + ' [' + relation.dest.transf_tipo + ']';
                            option.update(title_tmp);
                            option.setAttribute('value', index);
                            
                            if(relation.dest.id_transf_det != 0)
                                if ((gateway.parametros_extra.op_true_id_transf_det) && ((gateway.parametros_extra.op_true_id_transf_det == relation.dest.id_transf_det))) {

                                   if (gateway.parametros_extra.op_true_RectId != relation.dest.id)
                                      gateway.parametros_extra.op_true_RectId = relation.dest.id

                                    $("evaluacion").value = !gateway.parametros_extra.op_evaluacion ? true : relation.src.parametros_extra.op_evaluacion
                                    editor.setValue($("evaluacion").value);
                                    $('input_si').value = relation.title
                                    option.selected = true
                                }

                            //  $("evaluacion").value = relation.evaluacion == undefined ? true : relation.evaluacion
                            if ((gateway.parametros_extra.op_true_RectId) && ((gateway.parametros_extra.op_true_RectId == relation.dest.id) || (gateway.parametros_extra.op_true_RectId == relation.dest.parametros_extra.RectId))) {
                                $("evaluacion").value = !gateway.parametros_extra.op_evaluacion ? true : relation.src.parametros_extra.op_evaluacion
                                editor.setValue($("evaluacion").value);
                                $('input_si').value = relation.title
                                option.selected = true;
                            }

                            select.insert({ bottom: option });
                            setCmbLenguaje(relation.lenguaje, 'js')
                            setContent($('cmb_lenguaje'), 'evaluacion', relation.evaluacion)
                           
                        }
                    });

                    select = $('sel_no');
                    encontro = false
                    gateway.relations.each(function (relation, index) {
                        tempRel.push(relation);
                        if (relation.src == gateway && relation.dest.transf_tipo != 'annotation') {
                            
                            var option = $(document.createElement('option'));
                            var title_tmp = relation.dest.title + ' [' + relation.dest.transf_tipo + ']';
                            option.update(title_tmp);
                            option.setAttribute('value', index);

                            if(relation.dest.id_transf_det != 0)
                                if ((gateway.parametros_extra.op_false_id_transf_det) && ((gateway.parametros_extra.op_false_id_transf_det == relation.dest.id_transf_det))) {

                                    if (gateway.parametros_extra.op_false_RectId != relation.dest.id)
                                      gateway.parametros_extra.op_false_RectId = relation.dest.id

                                    $('input_no').value = relation.title
                                    option.selected = true
                                }

                            if ((gateway.parametros_extra.op_false_RectId) && ((gateway.parametros_extra.op_false_RectId == relation.dest.id) || (gateway.parametros_extra.op_false_RectId == relation.dest.parametros_extra.RectId))) {
                                $('input_no').value = relation.title
                                option.selected = true
                            }

                            select.insert({ bottom: option });
                        
                         
                        }
                    });
                    
                    //setContent('js', 'evaluacion', $('evaluacion').value)

                }

    
                
                if (gateway.transf_tipo == 'AND' || gateway.transf_tipo == 'XOR' || gateway.transf_tipo == 'OR') {

                    $('tr_default').hide();
                    $('default').value = '';

                    $('tr_condicional').hide();
                    $('sel_si').value = '';
                    $('sel_no').value = '';

                    $('TBevaluacion').hide();
                    $('bt_editar').hide();

                  

                }

                  window_onresize()
            }

            function window_onresize() {

                try {
                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_h = $$('body')[0].getHeight()
                    var tbPie_h = $('tbPie').getHeight()
                    var trTitulo_h = $('trTitulo').getHeight()
                    var trTitulo1_h = $('trTitulo1').getHeight()
                    var tr_default_h = $('tr_default').getHeight()
                    var trCondicional_h = $('trCondicional').getHeight()
                    var trCondicional1_h = $('trCondicional1').getHeight()
                    var trLenguaje_h = $('trLenguaje').getHeight()

                    var alto_left = 0
                    //contenedores = $('tdLeft').querySelectorAll(".contenedor")
                    //for (var i = 0; i < contenedores.length; i++) {
                    //    if (contenedores[i].style.display != 'none')
                    //        alto_left = alto_left + contenedores[i].getHeight()
                    //}

                    var calc = body_h - trTitulo_h - trTitulo1_h - tr_default_h - trCondicional_h - trCondicional1_h - tbPie_h - alto_left - trLenguaje_h - dif  //- 10
                    editor.setSize('100%', (calc) + "px")

                   // var alto_parametros = 0
                   // contenedores = $('tdRight').querySelectorAll(".contenedor")
                    //for (var i = 0; i < contenedores.length; i++) {
                    //    if (contenedores[i].style.display != 'none')
                    //        alto_parametros = alto_parametros + contenedores[i].getHeight()
                    //}

                 //   calc = body_h - trTitulo_h - trTitulo1_h - tr_default_h - alto_parametros - trCondicional_h - trCondicional1_h - tbPie_h - dif - 12
                 //   $('div_dic_var').setStyle({ 'height': (calc) + "px" })

                }
                catch (e) { console.log(e.message) }

            }

            function window_onunload() {

            }

            function btn_Aceptar_onclick() {
                
                gateway.title = $('title').value;

                if (gateway.transf_tipo == 'IF') {

                    try { editor.save() } catch (e) { }
                    gateway.lenguaje = $('cmb_lenguaje').value;


                    if ($("evaluacion").value == '')
                       $("evaluacion").value = 'true'

                    gateway.relations.each(function (relation, index) {

                        if (relation.src == gateway)
                        {
                            relation.evaluacion = 'true'
                            relation.title = ""
                            relation.lenguaje = ""

                            relation.segments.each(function (seg, i) {
                                seg.removeClassName("output_false")
                            });

                            relation.segments.each(function (seg, i) {
                                seg.addClassName("default")
                            });

                            relation.segmentClassName = relation.className = "default"

                            gateway.parametros_extra.op_true_RectId = ""
                            gateway.parametros_extra.op_true_id_transf_det = ""
                            gateway.parametros_extra.op_evaluacion = "true"
                        }

                    });

                    gateway.parametros_extra.op_true_RectId = null
                    gateway.parametros_extra.op_true_id_transf_det = null
                    gateway.parametros_extra.op_false_RectId = null
                    gateway.parametros_extra.op_false_id_transf_det = null
                    gateway.parametros_extra.op_evaluacion = $("evaluacion").value
                    if ($('sel_si').value != "") {
                        if (gateway.relations[$('sel_si').value] != '') {
                            
                            var encontrar = false
                            gateway.relations.each(function (relation, index) {
                                if (relation.src == gateway && relation.dest.id == tempRel[$('sel_si').value].dest.id) {
                                    relation.evaluacion = $("evaluacion").value
                                    relation.title = $("input_si").value
                                    relation.lenguaje = $("cmb_lenguaje").value
                                    encontrar = true;

                                    relation.segments.each(function (seg, i) {
                                        seg.removeClassName("output_false")
                                    });

                                    gateway.relations[$('sel_si').value].segments.each(function (seg, i) {
                                        seg.addClassName("default")
                                    });

                                    relation.segmentClassName = relation.className = "default"
                                }
                            });

                            if (!encontrar)
                                gateway.relations.push(tempRel[$('sel_si').value]);

                            gateway.parametros_extra.op_true_RectId = !gateway.relations[$('sel_si').value].dest.parametros_extra.RectId ? gateway.relations[$('sel_si').value].dest.id : gateway.relations[$('sel_si').value].dest.parametros_extra.RectId
                            gateway.parametros_extra.op_true_id_transf_det = gateway.relations[$('sel_si').value].dest.id_transf_det
                            gateway.parametros_extra.op_evaluacion =  "<![CDATA[" + $("evaluacion").value + ']]>'

                        }
                    }



                    if ($('sel_no').value != "") {
                        if (gateway.relations[$('sel_no').value] != '') {

                            var encontrar = false
                            gateway.relations.each(function (relation, index) {

                                if (relation.src == gateway && relation.dest.id == tempRel[$('sel_no').value].dest.id) {
                                    
                                    relation.evaluacion = ($("evaluacion").value.toLowerCase() == 'true' ? 'false' : ("not(" + $("evaluacion").value + ")"));
                                    relation.title = $("input_no").value
                                    relation.lenguaje = $("cmb_lenguaje").value
                                    encontrar = true;
                                    
                                    relation.segments.each(function (seg, i) {
                                        seg.removeClassName("default")
                                    });

                                    gateway.relations[$('sel_no').value].segments.each(function (seg, i) {
                                        seg.addClassName("output_false")
                                    });

                                    relation.segmentClassName = relation.className = "output_false"
                                }
                            });

                            if (!encontrar)
                                gateway.relations.push(tempRel[$('sel_no').value]);
                            
                            gateway.parametros_extra.op_false_RectId = !gateway.relations[$('sel_no').value].dest.parametros_extra.RectId ? gateway.relations[$('sel_no').value].dest.id : gateway.relations[$('sel_no').value].dest.parametros_extra.RectId
                            gateway.parametros_extra.op_false_id_transf_det = gateway.relations[$('sel_no').value].dest.id_transf_det


                        }
                    }
                    
                }
                else {

                    if ($('default').value != "") {
                        if (gateway.relations[$('default').value] != undefined) {
                            gateway.defaultArrow = gateway.relations[$('default').value];
                            gateway.parametros_extra.op_false_rectID = !gateway.relations[$('default').value].dest.parametros_extra.RectId ? gateway.relations[$('default').value].dest.id : gateway.relations[$('default').value].dest.parametros_extra.RectId
                            gateway.parametros_extra.op_false_id_transf_det = gateway.relations[$('default').value].dest.id_transf_det
                        }
                    }
                    else
                        gateway.defaultArrow = false;


                    if (gateway.OutPutFalseArrow)
                        gateway.OutPutFalseArrow.segments.each(function (seg, i) {
                            seg.removeClassName(gateway.OutPutFalseArrow.segmentClassName)
                        });
                    
                    if ($('output_false').value != "") {
                        if (gateway.relations[$('output_false').value] != undefined) {

                            gateway.OutPutFalseArrow = gateway.relations[$('output_false').value];
                            gateway.parametros_extra.op_false_rectID = !gateway.relations[$('output_false').value].dest.parametros_extra.RectId ? gateway.relations[$('output_false').value].dest.id : gateway.relations[$('output_false').value].dest.parametros_extra.RectId
                            gateway.parametros_extra.op_false_id_transf_det = gateway.relations[$('output_false').value].dest.id_transf_det

                            gateway.OutPutFalseArrow.segments.each(function (seg, i) {
                                seg.removeClassName("default")
                            });

                            gateway.OutPutFalseArrow.segments.each(function (seg, i) {
                                seg.addClassName("output_false")
                            });

                            gateway.OutPutFalseArrow.segmentClassName = gateway.OutPutFalseArrow.className = "output_false"

                        }
                    }
                    else
                        gateway.OutPutFalseArrow = false;


                    //if (gateway.transf_tipo == 'XOR') {
                    //    gateway.relations = tempRel;
                    //}
                }
            
                gateway.relations.each(function(relation) {
                    relation.afterDraw();
                });

                gateway.HTMLTitle();
                
                //win.Undo.add();
                win.close();
            }

            function btn_Cancelar_onclick() {
                win.close();
            }

            var editor
            function setContent(extension, obj, value) {


                // los objetos de texto que soporta
                if (extension == 'asp' ||
                    extension == 'aspx' ||
                    extension == 'vb' ||
                    extension == 'js' ||
                    extension == 'cs'
                ) {

                    var modeInput
                    switch (extension) {
                        case "vb":
                            modeInput = "text/x-vb"
                            break;
                        case "cs":
                            modeInput = "text/x-csharp"
                            break;
                        case "js":
                            modeInput = "text/javascript"
                            break;
                        case "asp":
                            modeInput = "application/x-ejs"
                            break;
                        case "aspx":
                            modeInput = "application/x-ejs"
                            break;
                    }


                    if (editor) {

                        var val = modeInput, m, mode, spec;
                        if (m = /.+\.([^.]+)$/.exec(val)) {
                            var info = CodeMirror.findModeByExtension(m[1]);
                            if (info) {
                                mode = info.mode;
                                spec = info.mime;
                            }
                        } else if (/\//.test(val)) {
                            var info = CodeMirror.findModeByMIME(val);
                            if (info) {
                                mode = info.mode;
                                spec = val;
                            }
                        } else {
                            mode = spec = val;
                        }
                        if (mode) {
                            editor.setOption("mode", spec);
                            CodeMirror.autoLoadMode(editor, mode);
                        } else {
                            alert("No encuentra el modo correspondiente a " + val);
                        }

                        //editor.setOption("mode", mode);
                        //CodeMirror.autoLoadMode(editor, mode);
                    }
                    else {
                        editor = CodeMirror.fromTextArea($(obj), {
                            //scrollbarStyle: "native",
                            //scrollbarStyle: "simple",
                            mode: modeInput,
                            readOnly: false,
                            lineNumbers: true,
                            autofocus: true,
                            selectionPointer: false
                        });


                        editor.on("dblclick", function (event) {
                            script_editar();
                        })

                        $(obj).value = value
                        editor.setValue(value);

                    }

                }


                //window_onresize()
            }

            function setCmbLenguaje(valor, defecto) {
                var res = false
                for (var i = 0; i < $('cmb_lenguaje').length; i++) {
                    if ($('cmb_lenguaje')[i].value == valor) {
                        $('cmb_lenguaje')[i].selected = true
                        res = true
                        // break;
                    }
                }

                if (res == false)
                    $('cmb_lenguaje').value = defecto
            }

            var objScriptEditar = new tScript();
            function script_editar() {
                
                objScriptEditar.cargar_parametros(parent.Transferencia.parametros)
                objScriptEditar.script_txt = $("evaluacion").value
                objScriptEditar.lenguaje = $("cmb_lenguaje").value
                objScriptEditar.protocolo = "SCRIPT"
                objScriptEditar.parametros_extra =  gateway.parametros_extra

                var path = "/fw/transferencia/editor_script.aspx"
             
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                winE = w.createWindow({
                    url: path,
                    title: '<b>Editar: Si ' + $('sel_si').value + ' No ' + $("sel_no").value + '</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 950,
                    height: 550,
                    destroyOnClose: true,
                    onClose: script_editar_return
                });

                winE.options.objScriptEditar = objScriptEditar
                winE.showCenter(true)

            }

            function script_editar_return() {
                if (winE.returnValue == 'OK') {
                    $("evaluacion").value = winE.options.objScriptEditar.string
                    $("cmb_lenguaje").value = winE.options.objScriptEditar.lenguaje
                    editor.setValue($("evaluacion").value);
                }
            }

            //function cargar_diccionario() {

            //    var strHTML = ''
            //    $("div_dic_var").innerHTML = ''
            //    strHTML = "<table class='tb1 layout_fixed'>"
            //    var rs = new tRS();
            //    var criterio = nvFW.pageContents.filtroTransf_diccionario
            //    rs.open(criterio)
            //    var i = 0
            //    while (!rs.eof()) {
            //        strHTML += "<tr>"
            //        strHTML += "<td onclick='dic_copiar(" + i + ",\"" + replace(rs.getdata("transf_dic_var"), "\'", "&&") + "\",event)' style='text-align:left;' title='" + replace(rs.getdata("transf_dic_var"), "\'", "\"") + "'><span id='span_transf_dic_var" + i + "' style='display:block'>" + rs.getdata('transf_dic_var_desc') + "</span><input type='text' style='width:100%;display:none' id='transf_dic_var" + i + "' value=''/></td>"
            //        strHTML += "<td style='width: 20px; text-align:right'><img src='/FW/image/transferencia/copiar.png' title='Copiar' style='cursor:pointer' onclick='dic_copiar(" + i + ",\"" + replace(rs.getdata("transf_dic_var"), "\'", "&&") + "\",event)'/></td>"
            //        strHTML += "</tr>"
            //        i++
            //        rs.movenext()
            //    }

            //    parent.Transferencia.parametros.each(function (arreglo, j) {
            //        strHTML += "<tr>"
            //        strHTML += "<td onclick='dic_copiar(" + i + ",\"" + arreglo["parametro"] + "\",event)' style='text-align:left;' title='" + arreglo["parametro"] + "'><span id='span_transf_dic_var" + i + "' style='display:block'>" + arreglo["parametro"] + "</span><input type='text' style='width:100%;display:none' id='transf_dic_var" + i + "' value='" + arreglo["parametro"] + "'/></td>"
            //        strHTML += "<td style='width: 20px; text-align:right'><img src='/FW/image/transferencia/copiar.png' title='Copiar' style='cursor:pointer' onclick='dic_copiar(" + i + ",\"" + arreglo["parametro"] + "\",event)'/></td>"
            //        strHTML += "</tr>"
            //        i++
            //    });

            //    strHTML += "</table>"
            //    $("div_dic_var").insert({ top: strHTML })
            //}

            //function dic_copiar(i, valor) {
            //    //$('txt_dic_var').value = replace(valor, "&&", "\'") 
            //    $('transf_dic_var' + i).value = replace(valor, "&&", "\'")

            //    //if (Prototype.Browser.IE)
            //    //  window.clipboardData.setData("Text", $('txt_dic_var').value)

            //    //   if ($('span_transf_dic_var' + i).style.display == 'none') {
            //    //       $('span_transf_dic_var' + i).show();
            //    //       $('transf_dic_var' + i).hide();
            //    //   }
            //    //    else {
            //    $('span_transf_dic_var' + i).hide();
            //    $('transf_dic_var' + i).show();
            //    setTimeout("$('transf_dic_var" + i + "').select();", 100);
            //    //   }

            //    //   $('txt_dic_var').select();

            //}

            function onchange_lenguje() {
                if ($('cmb_lenguaje').value == "vb")
                    setContent('vb', 'evaluacion', $('evaluacion').value)

                if ($('cmb_lenguaje').value == "js")
                    setContent('js', 'evaluacion', $('evaluacion').value)

                if ($('cmb_lenguaje').value == "cs")
                    setContent('cs', 'evaluacion', $('evaluacion').value)

            }

            function CargarTransf_Tipo(cb, transf_tipo) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtrotransf_tipos, "", "", "", "")
                while (!rs.eof()) {
                    cb.options.length++
                    cb.options[cb.options.length - 1].value = rs.getdata('transf_tipo')
                    cb.options[cb.options.length - 1].text = rs.getdata('transf_tipo')
                    if (transf_tipo == rs.getdata('transf_tipo'))
                        cb.options[cb.options.length - 1].selected = true
                    rs.movenext()
                }
            }

        </script>
    </head>
    <body onload="return window_onload()" onresize="return window_onresize()" onunload="return window_onunload()" style="width:100%;height:100%;overflow:hidden">
        <div style="display: none;"><%= nvCampo_def.get_html_input("tipo_operadores") %></div>
        <div style="display: none;"><%= nvCampo_def.get_html_input("nro_operador")%></div>
            <div id="divCabe" style="width:100%">
                <table class="tb1" id ="table_cont">
                    <tr id="trTitulo" class="tbLabel">
                        <td style="width:10%;text-align:center">N�</td>
                        <td style="width:10%;text-align:center">Tipo</td>
                        <td style="text-align:center">Descripci�n</td>
                        <td style="width:10%;text-align:center">Opcional</td>
                        <td style="width:20%;text-align:center">Estado</td>
                    </tr>
                    <tr id="trTitulo1">
                        <td><input type="text" name="id_transferencia_txt" id="id_transferencia_txt" style="width:100%; text-align:center" onkeypress='return valDigito()' disabled="disabled" /></td>
                        <td><select name="cb_transf_tipo" id="cb_transf_tipo" style="width:100%" onclick="cb_Transf_Tipo_on_change()" disabled="disabled"></select></td>
                        <td><input type="text" name="title" id="title" style="width:100%" /></td>                
                        <td><input type="checkbox" name="opcional" id="opcional" style="width:100%;border:0px" /></td>
                        <td>
                            <select name="estado" id="estado" style="width:100%">
                                <option value='A'>Activo</option>
                                <option value='N'>Nulo</option>
                            </select>
                        </td>
                    </tr>
                    <tr id="tr_default" class="contenedor">
                        <td colspan="2" class="Tit1" >
                            Salida por Defecto
                        </td>
                        <td colspan="4">
                            <select name="default" id="default" style="width: 100px;">
                                <option value=""></option>
                            </select>
                        </td>
                    </tr>
                    <tr id="tr_output_false" class="contenedor">
                        <td colspan="2" class="Tit1" >
                            Salida por falso
                        </td>
                        <td colspan="4">
                            <select name="output_false" id="output_false" style="width: 100px;">
                                <option value=""></option>
                            </select>
                        </td>
                    </tr>
                    <tr id="tr_condicional">
                      <td colspan="5">
                         <table class="tb1">
                                <tr id="trCondicional">
                                   <td class="Tit1" style="width:10%">Verdadero:</td>
                                   <td>
                                        <select name="sel_si" id="sel_si" style="width: 100%;">
                                            <option value=""></option>
                                        </select>
                                   </td>
                                   <td class="Tit1" style="width:10%">T�tulo:</td>
                                   <td>
                                     <script type="text/javascript">
                                         campos_defs.add('input_si', { enDB: false, nro_campo_tipo: 104 })
									</script>   
                                   </td>
                                   </tr>
                                   <tr id="trCondicional1">
                                   <td class="Tit1" style="width:10%">Falso:</td>
                                   <td>
                                        <select name="sel_no" id="sel_no" style="width: 100%;">
                                            <option value=""></option>
                                        </select>
                                   </td>
                                   <td class="Tit1" style="width:10%">T�tulo:</td>
                                   <td>
                                     <script type="text/javascript">
                                         campos_defs.add('input_no', { enDB: false, nro_campo_tipo: 104 })
									</script>   
                                   </td>
                               </tr>
                               <tr id="trLenguaje">
                                 <td style='width:5%' class='Tit1'>Lenguaje:</td>
                                 <td style='width:15%;white-space:nowrap' id="td_cmb_lenguje"><select id="cmb_lenguaje" onchange="onchange_lenguje()" style="width:100%"><option value="js" selected ="selected">JSCRIT</option><option value="vb">VB .NET</option><option value="cs">CS .NET</option></select></td>
                               </tr>
                             <%--  <tr id="evaluacion_text">
                                   <td colspan="4">
                                     <table class='tb1' style="width:100%">
                                         <tr>
                                             <td id="tdLeft" style="border:1px solid"><textarea rows="10" cols="25" id="evaluacion" name="evaluacion"  style="border:0px;height:100%;width:100%;resize:none;font:12px arial"></textarea></td>
                                             <td id="tdRight"  style="width:30%;vertical-align:top">
                                                <table class='tb1' id="tbDic" style="width:100%">  
                                                    <tr class="tbLabel contenedor">
                                                      <td id="tit_lenguaje"><b>Lenguaje</b></td>
                                                    </tr>
                                                    <tr class="contenedor">
                                                      <td id="td_cmb_lenguje"><select id="cmb_lenguaje" onchange="onchange_lenguje()" style="width:100%"><option value="js" selected ="selected">JSCRIPT</option><option value="vb">VB .NET</option><option value="cs">CS .NET</option></select></td>
                                                    </tr>
                                                   <tr class="tbLabel contenedor">
                                                      <td id="tit_dic_var"><b>Par�metros</b></td>
                                                    </tr>
                                                    <tr>
                                                      <td style="height:70%;"><div style="width:100%;overflow:auto" id="div_dic_var">&nbsp;</div></td>
                                                    </tr>
                                                    <%--<tr class="contenedor">
                                                      <td style="vertical-align:bottom"><input type="text" readonly="readonly" id="txt_dic_var" name="txt_dic_var" style="width:100%;vertical-align:bottom"/></td>
                                                    </tr>
                                                </table>     
                                             </td>
                                           </tr>
                                      </table>
                                   </td>
                               </tr>--%>
                         </table>
                       </td>
                    </tr>
                </table>  
                <table class='tb1' id="TBevaluacion">  
                  <tr id="evaluacion_text">
                    <td style="border:1px solid"><textarea id="evaluacion" name="evaluacion" style="border:0px;height:100%;width:100%;resize:none;font:12px arial;cursor:pointer"></textarea></td>
                  </tr>
                </table>  
            </div>
            <table class="tb1" id="tbPie">
                <tr>
                    <td style="width:2%">&nbsp;</td>
                    <td style="width:20%;text-align:center"><input type="button" id="bt_editar" value="Abrir editor" style="width:100%;cursor:pointer" onclick="script_editar()"></td>
                    <td style="width:5%">&nbsp;</td>
                    <td style="width:20%;text-align:center"><input type="button" style="width:100%;cursor:pointer" name="btn_Aceptar" value="Aceptar" onclick="btn_Aceptar_onclick()" /></td>
                    <td style="width:10%">&nbsp;</td>
                    <td style="width:20%;text-align:center"><input type="button" style="width:100%;cursor:pointer" name="btn_Cancelar" value="Cancelar" onclick="btn_Cancelar_onclick()" /></td>
                    <td>&nbsp;</td>
                </tr>
            </table>             
    </body>
</html>