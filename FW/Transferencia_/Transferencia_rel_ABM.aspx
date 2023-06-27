<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Me.contents("filtroTransf_diccionario") = nvXMLSQL.encXMLSQL("<criterio><select vista='transf_diccionario'><campos>distinct transf_dic_var,transf_dic_var_desc</campos><filtro></filtro><orden>transf_dic_var_desc</orden></select></criterio>")
%>

<html>
<head>
<title>Transferencia REL ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
     <link href="/FW/css/tMenu.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     

    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/doc/docs.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/lib/codemirror.css" />
    <%--<link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/addon/fold/foldgutter.css" />--%>
    <%--<link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/addon/scroll/simplescrollbars.css" />--%>

    <script src="/FW/Transferencia/script/CodeMirror/lib/codemirror.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/lib/util/loadmode.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/meta.js" type="text/javascript"></script>
    
    
    <%--<script src="/FW/Transferencia/script/CodeMirror/addon/fold/markdown-fold.js" type="text/javascript"></script>--%>
    <%--<script src="/FW/Transferencia/script/CodeMirror/addon/scroll/simplescrollbars.js" type="text/javascript"></script>--%>
    
    <script src="/FW/Transferencia/script/CodeMirror/mode/javascript/javascript.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/vb/vb.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/clike/clike.js" type="text/javascript"></script>

    <%= Me.getHeadInit()  %>
    <%
        Dim indice = nvUtiles.obtenerValor("indice","")
    %>
    <style type="text/css">
    .CodeMirror {
                  border: 1px solid #eee;
                  height: 200px;
                  min-height: 200px;
                  cursor:pointer;
                }

     </style>       
    <script type="text/javascript">

                var editor
                function setContent(extension, obj, value, options) {

                    if (!options) 
                        options = {};

                    if (!options.readOnly)
                      options.readOnly = false

                    if (!options.lineNumbers)
                      options.lineNumbers = true

                    if (!options.autofocus)
                      options.autofocus = true

                    if (!options.selectionPointer)
                      options.selectionPointer = false
                    

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

                        }
                        else {
                            editor = CodeMirror.fromTextArea($(obj), {
                                //scrollbarStyle: "native",
                                //scrollbarStyle: "simple",
                                mode: modeInput,
                                readOnly: options.readOnly,
                                lineNumbers: options.lineNumbers,
                                autofocus: options.autofocus,
                                selectionPointer: options.selectionPointer,
                            });

                            editor.on("dblclick", function (event) {
                                if(!options.readOnly)
                                  script_editar();
                            })

                            $(obj).value = value
                            editor.setValue(value);

                        }

                    }
                    //window_onresize()
                }

        
                var objScriptEditar = new tScript();
                function script_editar()
                { 
                    objScriptEditar.cargar_parametros(parent.Transferencia.parametros)
                    objScriptEditar.script_txt = $("evaluacion").value
                    objScriptEditar.lenguaje = $("cmb_lenguaje").value
                    objScriptEditar.protocolo = "SCRIPT"
                    objScriptEditar.parametros_extra = {}
                    objScriptEditar.parametros_extra.tipo_aisla = 'noaislar'


                    var path = "/fw/transferencia/editor_script.aspx"
                   
                    var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                    winE = w.createWindow({
                        url: path, 
                        title: '<b>Editar Relación "' + $("origen").value + ' -> ' + $("destino").value + '"</b>',
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
 
                function script_editar_return()
                {
                    if (winE.returnValue == 'OK')
                     {
                        $("evaluacion").value = winE.options.objScriptEditar.string
                        editor.setValue($("evaluacion").value);
                     }
                }

                function onchange_lenguje() {

                    if ($('cmb_lenguaje').value == "vb")
                        setContent('vb', 'evaluacion', $('evaluacion').value)

                    if ($('cmb_lenguaje').value == "js")
                        setContent('js', 'evaluacion', $('evaluacion').value)

                    if ($('cmb_lenguaje').value == "cs")
                        setContent('cs', 'evaluacion', $('evaluacion').value)

                }

                function isNULL(valor, sinulo)
                {
                    valor = valor == null ? sinulo : valor
                    return valor
                }

                var win = nvFW.getMyWindow()
                var objRel = win.options.rel
                function window_onload()
                {
                    nvFW.enterToTab = false
                    campos_defs.items["transf_rel_tipo"].despliega = "arriba"
                    rel_cargar()
                    vMenuParametros.MostrarMenu()
                   
                    //$('eva_checkbox').observe('change', function () {
                    //    checkChecbox();
                    //});

                }

                function obtenerIndice_OrigenDestino(obj, det_origen, det_destino)
                {
                    var indice = -1
                    obj.each(function(arreglo, i)
                    {
                        if (det_origen == arreglo['det_origen'] && det_destino == arreglo['det_destino'])
                            indice = i
                    });

                    return indice
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

                var inidice_rel
                function rel_cargar()
                {

                    var det_origen = objRel.src.id_transf_det == 0 ? 'N' + objRel.src.orden : objRel.src.id_transf_det
                    var origen = objRel.src.transferencia
                    var det_destino = objRel.dest.id_transf_det == 0 ? 'N' + objRel.dest.orden : objRel.dest.id_transf_det
                    var destino = objRel.dest.transferencia
                    
                    $("evaluacion").value = 'true'
                    setCmbLenguaje(objRel.lenguaje, 'js')

                    if(!objRel.segmentClassName)
                      objRel.segmentClassName =  objRel.className
                    campos_defs.set_value("transf_rel_tipo", objRel.segmentClassName)

                    $("id_transf_rel").value = 0
                    $$('#titlePosition option').each(function(option){
                        if(option.value == objRel.titlePosition){
                            option.selected = true;
                            throw $break;
                        }
                    });

                    if (objRel.evaluacion != undefined)
                    {
                      $("evaluacion").value = objRel.evaluacion
                      $("id_transf_rel").value = objRel.id_transf_rel
                      $("title").value = objRel.title
                    }
                    else
                    {
                      objRel.evaluacion = $("evaluacion").value
                      objRel.id_transf_rel = $("id_transf_rel").value
                    }

                    $("origen_type").value = objRel.src.transf_tipo
                    $("det_origen").value = det_origen
                    $("origen").value = origen

                    $("destino_type").value = objRel.dest.transf_tipo
                    $("det_destino").value = det_destino
                    $("destino").value = destino

                    if(objRel.style)
                     if(objRel.style.color)
                        $('condicion').value = objRel.style.color
                      
                   // $('evaluacion').focus()
                    $('eva_checkbox').checked = true
                    if ($("evaluacion").value == 'true')
                       $('eva_checkbox').checked = false;
                    
                    if(objRel.dest.type == 'annotation'){
                        $('posicion').hide();
                        $('evaluacion_check').hide();
                        $('evaluacion_text').hide();
                    }
       

                    var readOnly = false
                    if (objRel.src.transf_tipo == 'IF' || objRel.src.transf_tipo == 'SSS') {
                        readOnly = true
                        $('eva_checkbox').checked = false
                        $('eva_checkbox').disabled = true
                        $('cmb_lenguaje').disabled = true
                        $('bt_editar').disabled = true
                    }

                    //setContent('evaluacion')
                    setContent($('cmb_lenguaje').value, 'evaluacion', $('evaluacion').value, { readOnly: readOnly})

                    checkChecbox(readOnly);
                    
                    /*$('linecolor_sel').setStyle({ backgroundColor: objRel.lineColor })*/
                }


                function checkChecbox(no_evaluar) 
                 {

                    if (!no_evaluar) {
                        if ($('eva_checkbox').checked) {
                            $('evaluacion_text').show();
                            $('evaluacion').focus()
                            $('bt_editar').disabled = false
                            $('evaluacion').setStyle({ height: '200px' })
                        }
                        else {
                            $('evaluacion_text').hide();
                            $('bt_editar').disabled = true
                        }
                    }

                    window_onresize()
                    win.setSize(($$('body')[0].getWidth()) + "px", (altoBody) + "px")
                }
                
                function eliminar() {

                  Dialog.confirm("Desea eliminar la relación seleccionada", {width: 300,
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function(winLocal) {
                            win.options.accion = 'B'
                            winLocal.close()
                            win.close()
                        },
                        onCancel: function(winLocal) {
                            winLocal.close();
                            return
                        }
                    });
                }


                var altoBody = 0
                function window_onresize()
                {
                    
                    try
                    {
                        var dif = Prototype.Browser.IE ? 5 : 2
                        var body_h = $$('body')[0].getHeight()
                        var divMenuParametros_h = $('divMenuParametros').getHeight()
                        altoBody = 0
                        console.log(divMenuParametros_h)
                        var alto_left = 0
                        contenedores = $('tdLeft').querySelectorAll(".contenedor")
                        for (var i = 0; i < contenedores.length; i++) {
                            if (contenedores[i].style.display != 'none')
                                alto_left = alto_left + contenedores[i].getHeight()
                        }

                        var calc = body_h - divMenuParametros_h - alto_left - dif - 10 

                        altoBody = $('evaluacion').getHeight() + divMenuParametros_h + alto_left + dif + 30

                        editor.setSize("100%", (calc) + 'px')
                        editor.refresh()


                        //var alto_parametros = 0
                        //contenedores = $('tdRight').querySelectorAll(".contenedor")
                        //for (var i = 0; i < contenedores.length; i++) {
                        //    if (contenedores[i].style.display != 'none')
                        //        alto_parametros = alto_parametros + contenedores[i].getHeight()
                        //}

                    }
                    catch (e) {
                        console.log(e.message)
                    }
                }

                function window_onunload()
                {
                    win.close()
                }

                function guardar()
                {

                    actualizar()
                //  win.options.Transferencia_Rel = Transferencia_Rel
                    win.close()
                }

                function actualizar()
                {
                    try { editor.save() } catch (e) { }

                    if($('eva_checkbox').checked){
                        objRel.evaluacion = $("evaluacion").value
                    } else {
                        objRel.evaluacion = 'true';
                    }
                    objRel.id_transf_rel = $("id_transf_rel").value
                    objRel.title = $("title").value 
                    objRel.lenguaje = $("cmb_lenguaje").value

                    objRel.titlePosition = $('titlePosition').value

                    if (campos_defs.value("transf_rel_tipo")  == '')
                        campos_defs.set_value("transf_rel_tipo","default")

                    objRel.segments.each(function (seg, i) {
                        seg.removeClassName(objRel.segmentClassName)
                    });

                    objRel.segments.each(function (seg, i) {
                        seg.addClassName(campos_defs.value("transf_rel_tipo"))
                    });

                    objRel.segmentClassName = objRel.className = campos_defs.value("transf_rel_tipo")
                    objRel.afterDraw();

                }

                //function changeColor(e)
                //{
                //    var obj = Event.element(e)
                //    $('linecolor_sel').setStyle({backgroundColor: $(obj).style.backgroundColor})
                //}

            </script>
    </head>
    <body onload="return window_onload()" onunload="return window_onunload()" onresize="return window_onresize()" style="width:100%; height: 100%; overflow: hidden; margin: 0px; padding: 0px; ">
        <input type="hidden" name="det_destino" id="det_destino" value=""/>    
        <input type="hidden" name="det_origen" id="det_origen" value=""/>    
        <input type="hidden" name="indice" id="indice" value="<%= indice %>"/>  
        <input type="hidden" id="id_transf_rel" style="width:100%;text-align:center" disabled="disabled"/>
        <div id="divMenuParametros" style="margin: 0px;padding: 0px;"></div>
            <script type="text/javascript">
                
                var DocumentMNG = new tDMOffLine;
                var vMenuParametros = new tMenu('divMenuParametros', 'vMenuParametros');
            Menus["vMenuParametros"] = vMenuParametros
            Menus["vMenuParametros"].alineacion = 'centro';
            Menus["vMenuParametros"].estilo = 'A';
            //Menus["vMenuParametros"].imagenes = Imagenes //Imagenes se declara en pvUtiles
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenuParametros.loadImage("guardar", '/fw/image/transferencia/guardar.png')
            vMenuParametros.loadImage("eliminar", '/fw/image/transferencia/eliminar.png')
         
            </script> 
        <table class='tb1' id="tbGlobal" style="height: 100%;width:100%">  
        <tr>
         <td id="tdLeft" style="width:70%; vertical-align:top">
            <table class='tb1 contenedor'>
                <tr>
                    <td style='text-align:left;width:10%;white-space:nowrap' class="tit4">Tarea Origen:</td>
                    <td style='text-align:left;width:10%;'><input type="text" id="origen_type" style="width:100%;text-align:center" disabled="disabled"/></td>
                    <td><input type="text" id="origen" style="width:100%" disabled="disabled"/></td>
               </tr>
               <tr>
                    <td style='text-align:left;width:10%;white-space:nowrap' class="tit4">Tarea Destino:</td>
                    <td style='text-align:left;width:10%;'><input type="text" id="destino_type" style="width:100%;text-align:center" disabled="disabled"/></td>
                    <td><input type="text" id="destino" style="width:100%" disabled="disabled"/></td>
               </tr>
             </table>
             <table class='tb1 contenedor'> 
                <tr>
                    <td style='width:8%' class='Tit4'>Descripción:</td>
                    <td><input type="text" id="title" style="width:100%"/></td>
                </tr>
             </table>
             <table class='tb1 contenedor' style="display:none">    
                <tr id="posicion">
                    <td style='width:5%' class='Tit4'>Posición:</td>
                    <td style='width:20%'>
                        <select name="titlePosition" id="titlePosition" style="width:100%">
                            <option value="ini">Inicio</option>
                            <option value="middle">Medio</option>
                            <option value="fin">Final</option>
                        </select>
                    </td>
                    <td style='width:5%' class='Tit4' >Salida:</td>
                    <td style='width:20%'>
                        <select name="condicion" id="condicion" style="width:100%">
                            <option value="black" selected="selected">Correcta</option>
                            <option value="red">Error</option>
                        </select>
                    </td>
                    <td>&nbsp;</td>
                </tr>
              </table>
             <table class='tb1 contenedor'>  
                <tr id="evaluacion_check">
                    <td style='width:5%' class='Tit4'>Evaluación:</td>
                    <td style='width:3%'><input type="checkbox" id="eva_checkbox" onclick="checkChecbox(false)" style="border:0px;"/></td>
                    <td style='width:5%'><input type="button" id="bt_editar" value="Abrir editor" style="width:100%;cursor:pointer" onclick="script_editar()"></td>
                    <td style='width:8%;white-space:nowrap' class='Tit4'>Formato:</td>
                    <td style='white-space:nowrap'><%= nvCampo_def.get_html_input("transf_rel_tipo")%></td>
                    <td style='width:5%' class='Tit4'>Lenguaje:</td>
                    <td style='width:15%;white-space:nowrap' id="td_cmb_lenguje"><select id="cmb_lenguaje" onchange="onchange_lenguje()" style="width:100%"><option value="js" selected ="selected">JSCRIT</option><option value="vb">VB .NET</option><option value="cs">CS .NET</option></select></td>
                </tr>
             </table>
            <table class='tb1' id="TBevaluacion">  
                <tr id="evaluacion_text">
                    <td colspan="3" style="border:1px solid"><textarea id="evaluacion" name="evaluacion"  style="border:0px;height:100%;width:100%;resize:none;font:12px arial;cursor:pointer"></textarea></td>
                </tr>
          </table>     
         </td>
       <%--  <td id="tdRight"  style="vertical-align:top">
            <table class='tb1' id="tbDic" style="width:100%">  
                <tr class="tbLabel contenedor">
                  <td id="tit_lenguaje">Lenguaje</td>
                </tr>
                <tr class="contenedor">
                  <td id="td_cmb_lenguje"><select id="cmb_lenguaje" onchange="onchange_lenguje()" style="width:100%"><option value="js" selected ="selected">JSCRIT</option><option value="vb">VB .NET</option><option value="cs">CS .NET</option></select></td>
                </tr>
               <tr class="tbLabel contenedor">
                  <td id="tit_dic_var">Parámetros</td>
                </tr>
                <tr>
                  <td style="height:70%;"><div style="width:100%;overflow:auto" id="div_dic_var">&nbsp;</div></td>
                </tr>
               <tr class="contenedor">
                  <td style="vertical-align:bottom"><input type="text" readonly="readonly" id="txt_dic_var" name="txt_dic_var" style="width:100%;vertical-align:bottom"/></td>
                </tr>
            </table>     
         </td>--%>
         </tr>
         </table>
    </body>
</html>