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

    <%= Me.getHeadInit()  %>
    <script type="text/javascript">

            var objRel = nvFW.getMyWindow().options.rel
            function window_onload()
                {
                    vMenuParametros.MostrarMenu()
                    nvFW.enterToTab = false
                  // campos_defs.items["transf_rel_tipo"].despliega = "arriba"
                    rel_cargar()
                    window_onresize()                    
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

              var win = {}
              win.options = {}
              var objScriptEditar = new tScript();
              function rel_cargar()
                {
                    
                   var det_origen = objRel.src.id_transf_det == 0 ? 'N' + objRel.src.orden : objRel.src.id_transf_det
                   var origen = objRel.src.transferencia
                   var det_destino = objRel.dest.id_transf_det == 0 ? 'N' + objRel.dest.orden : objRel.dest.id_transf_det
                   var destino = objRel.dest.transferencia
                    
                   objScriptEditar.script_txt = 'true'
                   objScriptEditar.lenguaje = 'js'
                   objScriptEditar.protocolo = "SCRIPT"
                   objScriptEditar.cargar_parametros(nvFW.getMyWindow().options.parametros)
                   objScriptEditar.parametros_extra = {} 
                   objScriptEditar.callbackCancel = window_onunload
                   objScriptEditar.callbackAccept = guardar
 
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
                      objScriptEditar.script_txt = xmlUnscape(objRel.evaluacion)
                      objScriptEditar.lenguaje = objRel.lenguaje
                      $("id_transf_rel").value = objRel.id_transf_rel
                      $("title").value = objRel.title
                    }
                    else
                    {
                      objRel.evaluacion = objScriptEditar.script_txt
                      objRel.lenguaje = objScriptEditar.lenguaje
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
                      
                    $('eva_checkbox').checked = true
                    if (objScriptEditar.script_txt == 'true')
                       $('eva_checkbox').checked = false;
                    
                    if(objRel.dest.type == 'annotation'){
                        $('posicion').hide();
                        $('evaluacion_check').hide();
                    }
       
                    if (objRel.src.transf_tipo == 'IF' || objRel.src.transf_tipo == 'SSS') {
                        objScriptEditar.readOnly = false
                        $('eva_checkbox').checked = false
                        $('eva_checkbox').disabled = false
                        checkChecbox(true)
                    }

            
                   win.options.objScriptEditar = objScriptEditar
                   $('ifrDetalle').src = "/fw/transferencia/editor_script.aspx"


                    /*$('linecolor_sel').setStyle({ backgroundColor: objRel.lineColor })*/
                }


                function checkChecbox(no_evaluar) 
                 {

                    if (!no_evaluar) {

                        if ($('eva_checkbox').checked) 
                           $('ifrDetalle').show()
                        else 
                            $('ifrDetalle').hide()
                        
                    }

                    window_onresize()
                    //nvFW.getMyWindow().setSize(($$('body')[0].getWidth()) + "px", "170px")
                }
                
                function eliminar() {

                  Dialog.confirm("Desea eliminar la relaci�n seleccionada", {width: 300,
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function(winLocal) {
                            nvFW.getMyWindow().options.accion = 'B'
                            winLocal.close()
                            nvFW.getMyWindow().close()
                        },
                        onCancel: function(winLocal) {
                            winLocal.close();
                            return
                        }
                    });
                }

                function window_onresize()
                {
                    try {
                        var dif = Prototype.Browser.IE ? 5 : 2
                        var body_h = $$('body')[0].getHeight()
                        var divMenuParametros_h = $('divMenuParametros').getHeight()
                        var tbGlobal_h = $('tbGlobal').getHeight()

                        var calc = body_h - divMenuParametros_h - tbGlobal_h - dif

                        $('ifrDetalle').setStyle({height: (calc) + 'px'})

                    }
                    catch (e) {
                    }
                }

                function window_onunload()
                {
                    nvFW.getMyWindow().close()
                }

                function guardar()
                {
                    actualizar()
                    nvFW.getMyWindow().close()
                }

                function actualizar()
                {

                    if($('eva_checkbox').checked){
                        objRel.evaluacion = xmlScape(objScriptEditar.script_txt)
                    } else {
                        objRel.evaluacion =xmlScape(objScriptEditar.script_txt) // 'true';
                    }
                    objRel.id_transf_rel = $("id_transf_rel").value
                    objRel.title = $("title").value 
                    objRel.lenguaje =  objScriptEditar.lenguaje

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
        <input type="hidden" id="id_transf_rel" style="width:100%;text-align:center" disabled="disabled"/>
        <div id="divMenuParametros" class="contenedor" style="margin: 0px;padding: 0px;"></div>
        <script type="text/javascript">
                
            var DocumentMNG = new tDMOffLine;
            var vMenuParametros = new tMenu('divMenuParametros', 'vMenuParametros');
            Menus["vMenuParametros"] = vMenuParametros
            Menus["vMenuParametros"].alineacion = 'centro';
            Menus["vMenuParametros"].estilo = 'A';
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenuParametros.loadImage("guardar", '/fw/image/transferencia/guardar.png')
            vMenuParametros.loadImage("eliminar", '/fw/image/transferencia/eliminar.png')
         
            </script> 
      <table class='tb1' id="tbGlobal" style="width:100%">  
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
                    <td style='width:8%' class='Tit4'>Descripci�n:</td>
                    <td><input type="text" id="title" style="width:100%"/></td>
                </tr>
             </table>
             <table class='tb1 contenedor' style="display:none">    
                <tr id="posicion">
                    <td style='width:5%' class='Tit4'>Posici�n:</td>
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
                    <td style='width:5%' class='Tit4'>Evaluaci�n:</td>
                    <td style='width:3%'><input type="checkbox" id="eva_checkbox" onclick="checkChecbox(false)" style="border:0px;" checked="checked" /></td>
                    <td style='width:8%;white-space:nowrap' class='Tit4'>Formato:</td>
                    <td style='white-space:nowrap'><%= nvCampo_def.get_html_input("transf_rel_tipo")%></td>
                </tr>
             </table>
         </td>
        </tr>
       </table>
     <iframe id="ifrDetalle" style='width:100%;overflow:hidden' src='' frameborder="0" ></iframe>
    </body>
</html>