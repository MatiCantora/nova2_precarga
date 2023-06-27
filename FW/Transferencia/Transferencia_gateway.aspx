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

            var win = {}
                win.options = {}
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

            var objScriptEditar = new tScript();
            function window_onload() {

                nvFW.enterToTab = false
                
                gateway = nvFW.getMyWindow().options.Gateway
                Transferencia = nvFW.getMyWindow().options.Transferencia 

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
                    
                    $('tbPie').hide()
                    $('tr_default').hide();
                    $('default').value = '';

                    $('tr_output_false').hide();
                    $('output_false').value = '';

                    if (!gateway.parametros_extra.op_evaluacion) gateway.parametros_extra.op_evaluacion = ""

                    objScriptEditar.script_txt =  xmlUnscape(gateway.parametros_extra.op_evaluacion)
                    objScriptEditar.cargar_parametros(Transferencia.parametros)
                    objScriptEditar.protocolo = "SCRIPT"
                    objScriptEditar.parametros_extra = {} 
                    objScriptEditar.lenguaje = 'js'
                    objScriptEditar.callbackCancel = btn_Cancelar_onclick
                    objScriptEditar.callbackAccept = btn_Aceptar_onclick

                    var select = $('sel_si');
                    var encontro = false
                    for (var index = 0; index < gateway.relations.length; index++) {

                            var relation = gateway.relations[index]
                            tempRel.push(relation);
                            if (relation.src == gateway && relation.dest.transf_tipo != 'annotation') {

                                var option = $(document.createElement('option'));
                                var title_tmp = relation.dest.title + ' [' + relation.dest.transf_tipo + ']';
                                option.update(title_tmp);
                                option.setAttribute('value', index);

                                if (relation.dest.id_transf_det != 0)
                                    if ((gateway.parametros_extra.op_true_id_transf_det) && ((gateway.parametros_extra.op_true_id_transf_det == relation.dest.id_transf_det))) {

                                        if (gateway.parametros_extra.op_true_RectId != relation.dest.id)
                                            gateway.parametros_extra.op_true_RectId = relation.dest.id

                                        objScriptEditar.script_txt = !gateway.parametros_extra.op_evaluacion ? true : xmlUnscape(relation.src.parametros_extra.op_evaluacion)

                                        $('input_si').value = relation.title
                                        option.selected = true
                                    }

                                //  $("evaluacion").value = relation.evaluacion == undefined ? true : relation.evaluacion
                                if ((gateway.parametros_extra.op_true_RectId) && ((gateway.parametros_extra.op_true_RectId == relation.dest.id) || (gateway.parametros_extra.op_true_RectId == relation.dest.parametros_extra.RectId))) {
                                    objScriptEditar.script_txt = !gateway.parametros_extra.op_evaluacion ? true : xmlUnscape(relation.src.parametros_extra.op_evaluacion)
                                    $('input_si').value = relation.title
                                    option.selected = true;
                                }

                                select.insert({ bottom: option });
                                objScriptEditar.lenguaje = relation.src.lenguaje

                            }
                    }

                    win.options.objScriptEditar = objScriptEditar
                    $('ifrDetalle').src = "/fw/transferencia/editor_script.aspx"

                    select = $('sel_no');
                    encontro = false
                    for (var index = 0; index < gateway.relations.length; index++) {

                        var relation = gateway.relations[index]
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
                    }
                    

                }
                
                if (gateway.transf_tipo == 'AND' || gateway.transf_tipo == 'XOR' || gateway.transf_tipo == 'OR') {

                    $('tr_default').hide();
                    $('default').value = '';

                    $('tr_condicional').hide();
                    $('sel_si').value = '';
                    $('sel_no').value = '';

                }
                
                window_onresize()
            }

            function window_onresize() {

                try {
                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_h = $$('body')[0].getHeight()
                    var tbPie_h = getComputedStyle($('tbPie')).display == 'none' ? 0 : $('tbPie').getHeight()
                    var trTitulo_h = getComputedStyle($('trTitulo')).display == 'none' ? 0 : $('trTitulo').getHeight()
                    var trTitulo1_h = getComputedStyle($('trTitulo1')).display == 'none' ? 0 :$('trTitulo1').getHeight()
                    var tr_default_h = getComputedStyle($('tr_default')).display == 'none' ? 0 : $('tr_default').getHeight()
                    var tr_output_false_h = getComputedStyle($('tr_output_false')).display == 'none' ? 0 : $('tr_output_false').getHeight()
                    var trCondicional_h = getComputedStyle($('trCondicional')).display == 'none' ? 0 :$('trCondicional').getHeight()
                    var trCondicional1_h = getComputedStyle($('trCondicional1')).display == 'none' ? 0 :$('trCondicional1').getHeight()

                    var calc = body_h - trTitulo_h - trTitulo1_h - tr_default_h - trCondicional_h - trCondicional1_h - tbPie_h - trCondicional_h - tr_default_h - tr_output_false_h - dif  //- 10
               //     console.log(calc)
                    $('ifrDetalle').setStyle({ height: calc + 'px' })

                }
                catch (e) { console.log("dd"+e.message) }

            }

            function window_onunload() {

            }

            function btn_Aceptar_onclick() {
                
                gateway.title = $('title').value;

                if (gateway.transf_tipo == 'IF') {

                    gateway.lenguaje = objScriptEditar.lenguaje


                    if (objScriptEditar.script_txt == '')
                       objScriptEditar.script_txt= 'true'

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
                    gateway.parametros_extra.op_evaluacion = xmlScape(objScriptEditar.script_txt)

                    if ($('sel_si').value != "") {
                        if (gateway.relations[$('sel_si').value] != '') {
                            
                            var encontrar = false
                            gateway.relations.each(function (relation, index) {
                                if (relation.src == gateway && relation.dest.id == tempRel[$('sel_si').value].dest.id) {
                                    relation.evaluacion =  xmlScape(objScriptEditar.script_txt) 
                                    relation.lenguaje = objScriptEditar.lenguaje
                                    relation.title = $("input_si").value
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


                           if (gateway.relations[$('sel_si').value].dest.id != gateway.relations[$('sel_si').value].dest.parametros_extra.RectId)
                                gateway.relations[$('sel_si').value].dest.parametros_extra.RectId = gateway.relations[$('sel_si').value].dest.id

                            gateway.parametros_extra.op_true_RectId = !gateway.relations[$('sel_si').value].dest.parametros_extra.RectId ? gateway.relations[$('sel_si').value].dest.id : gateway.relations[$('sel_si').value].dest.parametros_extra.RectId
                            gateway.parametros_extra.op_true_id_transf_det = gateway.relations[$('sel_si').value].dest.id_transf_det
                            gateway.parametros_extra.op_evaluacion =  xmlScape(objScriptEditar.script_txt)

                        }
                    }



                    if ($('sel_no').value != "") {
                        if (gateway.relations[$('sel_no').value] != '') {

                            var encontrar = false
                            gateway.relations.each(function (relation, index) {

                                if (relation.src == gateway && relation.dest.id == tempRel[$('sel_no').value].dest.id) {
                                    
                                    relation.evaluacion = xmlScape((objScriptEditar.script_txt.toLowerCase() == 'true' ? 'false' : ("not(" + objScriptEditar.script_txt + ")")));
                                    relation.title = $("input_no").value
                                    relation.lenguaje =  objScriptEditar.lenguaje
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

                            if (gateway.relations[$('sel_no').value].dest.id != gateway.relations[$('sel_no').value].dest.parametros_extra.RectId)
                                gateway.relations[$('sel_no').value].dest.parametros_extra.RectId = gateway.relations[$('sel_no').value].dest.id 

                            gateway.parametros_extra.op_false_RectId = !gateway.relations[$('sel_no').value].dest.parametros_extra.RectId ? gateway.relations[$('sel_no').value].dest.id : gateway.relations[$('sel_no').value].dest.parametros_extra.RectId
                            gateway.parametros_extra.op_false_id_transf_det = gateway.relations[$('sel_no').value].dest.id_transf_det


                        }
                    }
                    
                }
                else {

                    if ($('default').value != "") {
                        if (gateway.relations[$('default').value] != undefined) {
                            gateway.defaultArrow = gateway.relations[$('default').value];

                           if (gateway.relations[$('default').value].dest.id != gateway.relations[$('default').value].dest.parametros_extra.RectId)
                                gateway.relations[$('default').value].dest.parametros_extra.RectId = gateway.relations[$('default').value].dest.id 

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


                           if (gateway.relations[$('output_false').value].dest.id != gateway.relations[$('output_false').value].dest.parametros_extra.RectId)
                                gateway.relations[$('output_false').value].dest.parametros_extra.RectId = gateway.relations[$('output_false').value].dest.id 

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
                nvFW.getMyWindow().close();
            }

            function btn_Cancelar_onclick() {
                nvFW.getMyWindow().close();
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
            <div id="divCabe" style="width:100%">
                <table class="tb1" id ="table_cont">
                    <tr id="trTitulo" class="tbLabel">
                        <td style="width:10%;text-align:center">Nº</td>
                        <td style="width:10%;text-align:center">Tipo</td>
                        <td style="text-align:center">Descripción</td>
                        <td style="width:20%;text-align:center">Estado</td>
                    </tr>
                    <tr id="trTitulo1">
                        <td><input type="text" name="id_transferencia_txt" id="id_transferencia_txt" style="width:100%; text-align:center" onkeypress='return valDigito()' disabled="disabled" /></td>
                        <td><select name="cb_transf_tipo" id="cb_transf_tipo" style="width:100%" onclick="cb_Transf_Tipo_on_change()" disabled="disabled"></select></td>
                        <td><input type="text" name="title" id="title" style="width:100%" /></td>                
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
                                   <td class="Tit1" style="width:10%">Título:</td>
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
                                   <td class="Tit1" style="width:10%">Título:</td>
                                   <td>
                                     <script type="text/javascript">
                                         campos_defs.add('input_no', { enDB: false, nro_campo_tipo: 104 })
									</script>   
                                   </td>
                               </tr>
                         </table>
                       </td>
                    </tr>
                </table>  
            </div>
           <input type="hidden" id="evaluacion" value=""/>
           <iframe id="ifrDetalle" style='width:100%;overflow:hidden' frameborder="0" ></iframe>

            <table class="tb1" id="tbPie">
                <tr>
                    <td style="width:15%">&nbsp;</td>
                    <td style="width:30%;text-align:center"><input type="button" style="width:100%;cursor:pointer" name="btn_Aceptar" value="Aceptar" onclick="btn_Aceptar_onclick()" /></td>
                    <td style="width:10%">&nbsp;</td>
                    <td style="width:30%;text-align:center"><input type="button" style="width:100%;cursor:pointer" name="btn_Cancelar" value="Cancelar" onclick="btn_Cancelar_onclick()" /></td>
                    <td>&nbsp;</td>
                </tr>
            </table>             
    </body>
</html>