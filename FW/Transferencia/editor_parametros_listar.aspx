<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
%>
<html>
<head>
<title>Transferencia Detalle SSR</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
            
    <script type="text/javascript" src="/FW/transferencia/script/transf_utiles.js"></script>

    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/doc/docs.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/lib/codemirror.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/addon/fold/foldgutter.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/addon/scroll/simplescrollbars.css" />

    <script src="/FW/Transferencia/script/CodeMirror/lib/codemirror.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/fold/markdown-fold.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/javascript/javascript.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/scroll/simplescrollbars.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/vb/vb.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/clike/clike.js" type="text/javascript"></script>

<%= Me.getHeadInit()   %>
<script type="text/javascript">

var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 

var objScript = new tScript();
function window_onload()
{
   nvFW.enterToTab = false
    
    objScript.cargar_parametros(parent.objScriptEditar.parametros)
    objScript.lenguaje = parent.objScriptEditar.lenguaje
    objScript.protocolo = parent.objScriptEditar.protocolo

    var param_adicionales = {};
    if (objScript.protocolo.toUpperCase() == 'SCRIPT')
    {

     if (objScript.lenguaje.toUpperCase() != 'SQL') {
       param_adicionales.parametro = "Transf.lastdet.det_error.numError"
       param_adicionales.etiqueta = "Excepción no controlada"
       parent.objScriptEditar.param_add.push(param_adicionales)   
     }

     param_adicionales = {};
     param_adicionales.parametro = objScript.lenguaje.toUpperCase() == 'SQL' ? '_transf_id_transf_log' : "Transf.id_transf_log"
     param_adicionales.etiqueta = "Nro. Seguimiento"
     parent.objScriptEditar.param_add.push(param_adicionales)        
     param_adicionales = {};
     param_adicionales.parametro = objScript.lenguaje.toUpperCase() == 'SQL' ? '_transf_id_transferencia' : "Transf.id_transferencia"
     param_adicionales.etiqueta = "Nro. Tranferencia"
     parent.objScriptEditar.param_add.push(param_adicionales) 

    }

   objScript.cargar_param_add(parent.objScriptEditar.param_add)


   //if (!objScript.parametros.length)
   //    objScript.parametros = []

   //if (!objScript.param_add.length)
   //    objScript.param_add = []

    
   cargarDiccionario()

   window_onresize()
}

function recargar_lenguaje() {
   objScript.lenguaje = parent.objScriptEditar.lenguaje
}

function window_onresize() {
    try {

        var dif = Prototype.Browser.IE ? 5 : 2
        var body_heigth = $$('body')[0].getHeight()
     
        
        var calc = body_heigth - dif

        var alto_parametros = 0
        contenedores = $('tbDic').querySelectorAll(".contenedor")
        for (var i = 0; i < contenedores.length; i++) {
            if (contenedores[i].style.display != 'none')
                alto_parametros = alto_parametros + contenedores[i].getHeight()
        }

        $('div_dic_var').setStyle({ 'height': calc - alto_parametros })

    }
    catch (e) { window.status = e.description; alert('calc: ' + calc) }
}

 function parametros_todos(accion) {

     var prefijo = ""
     var posfijo = ""
     recargar_lenguaje()
     switch (objScript.lenguaje.toUpperCase()) {

            case "SQL":
                 prefijo = accion.toLowerCase() == "declare" ? " DECLARE @" : " SET @"
                 posfijo = accion.toLowerCase() == "declare" ? " {tipo_dato} -- " : " = null -- "
                break
            case "JS":
                 prefijo = accion.toLowerCase() == "declare" ? " var " : " "
                 posfijo =  " = null // "
                break
            case "VB":
                 prefijo = accion.toLowerCase() == "declare" ? " dim " : " "
                 posfijo = " = Nothing ' "
                break
            case "CS":
                 prefijo = accion.toLowerCase() == "declare" ? " var " : " "
                 posfijo = " = null // "
                break

     }

    var str = ""
    for (var j = 0; j < objScript.parametros.size(); j++) {
           var parametros = objScript.parametros
            str += prefijo + parametros[j]["parametro"] + posfijo.replace('{tipo_dato}',parametros[j]["tipo_dato"]) + (parametros[j]["etiqueta"] == "" ? "Parámetro:" + parametros[j]["parametro"] : (parametros[j]["etiqueta"] + ": " + parametros[j]["parametro"])) + "\n"
        }

     return str
}

function dragInicio(e, parametro) {

    if (parametro.indexOf('#parametrostodos') >= 0) {

        var accion  = parametro.split("?")[1]
        var str = parametros_todos(accion)
        if(str != "")
          event.dataTransfer.setData("Text", str );

        return
    }


    var el = Event.element(e)
    parametro = replace(parametro, "&&", "\"")
    
    if (parametro.indexOf("(") == -1) {  // si no es funcion

        switch (objScript.lenguaje.toUpperCase()) {
            case "SQL":
                parametro = "@" + parametro
                break
            default:
                if (objScript.protocolo.toUpperCase() == 'XML' || objScript.protocolo.toUpperCase() == 'FILE')
                    parametro = "\{" + parametro + "\}"
                else
                   if (objScript.protocolo.toUpperCase() == 'XSL')
                        parametro = '<xsl:value-of select="@' + parametro + '"/>'
                break
        }
    }
    else { // si es funcion

          switch (objScript.protocolo.toUpperCase()) {
            case "XML":
                parametro = "\{%" + parametro + "%\}"
                break
            default:
                break
        }
    }

    console.log(objScript.protocolo)

    event.dataTransfer.setData("Data", " datos = {parametro: '" + parametro + "'}");

}
    var i = 0
    function cargarDiccionario() {

       var strHTML = ''
       $("div_dic_var").innerHTML = ''
       strHTML = "<table class='tb1 layout_fixed'>"

       i = 0
       strHTML += "<tr id='tr_transf_dic_var" + i + "'>"
       strHTML += "<td class='tit2'>Parámetros</td>"
       strHTML += "</tr>"
       i++ 

       for (var j = 0; j < objScript.parametros.size(); j++) {
            var parametros = objScript.parametros
            strHTML += "<tr id='tr_transf_dic_var" + i + "'>"
            strHTML += "<td class='tit4' style='text-align:left;cursor:pointer' title='" + (parametros[j]["etiqueta"] == "" ? "Parámetro:" + parametros[j]["parametro"] : (parametros[j]["etiqueta"] + ": " + parametros[j]["parametro"])) + "'><span id='span_transf_dic_var" + i + "' draggable= 'true' ondragstart='dragInicio(event,\"" + parametros[j].parametro + "\")' style='display:block'>" + (parametros[j]["etiqueta"] == "" ? parametros[j]["parametro"] : parametros[j]["etiqueta"]) + " ("+ parametros[j]["tipo_dato"] +")</span></td>"
            strHTML += "</tr>"
            i++
        }

       strHTML += "<tr id='tr_transf_dic_var" + i + "'>"
       strHTML += "<td class='tit2'>Complementos</td>"
       strHTML += "</tr>"
       i++
       strHTML += "<tr id='tr_transf_dic_var" + i + "'>"
       strHTML += "<td class='tit4' style='color:green;text-align:left;cursor:pointer' title='Declarar todos los parametros'><span id='span_transf_dic_var" + i + "' draggable= 'true' ondragstart='dragInicio(event,\"#parametrostodos?declare\")' style='display:block'>Declarar todos</span></td>"
       strHTML += "</tr>"
       i++

       strHTML += "<tr id='tr_transf_dic_var" + i + "'>"
       strHTML += "<td class='tit4' style='color:green;text-align:left;cursor:pointer' title='Setear todos los parametros'><span id='span_transf_dic_var" + i + "' draggable= 'true' ondragstart='dragInicio(event,\"#parametrostodos?set\")' style='display:block'>Setear todos</span></td>"
       strHTML += "</tr>"
       i++

       for (var j = 0; j < objScript.param_add.size(); j++) {
           var param_add = objScript.param_add
           strHTML += "<tr id='tr_transf_dic_var" + i + "'>"
           strHTML += "<td class='tit4' style='color:blue;text-align:left;cursor:pointer' title='" + (param_add[j]["etiqueta"] == "" ? "Parámetro:" + param_add[j]["parametro"] : (param_add[j]["etiqueta"] + ": " + param_add[j]["parametro"])) + "'><span id='span_transf_dic_var" + i + "' draggable= 'true' ondragstart='dragInicio(event,\"" + param_add[j].parametro + "\")' style='display:block'>" + (param_add[j]["etiqueta"] == "" ? param_add[j]["parametro"] : param_add[j]["etiqueta"]) + "</span></td>"
           strHTML += "</tr>"
           i++
       }

       strHTML += "</table>"
        $("div_dic_var").insert({ top: strHTML })
    }

    function Buscar() {

        if ($('buscar').value != '') {
            
            var j = 0
            while (j < i)
            {
                valor = $("span_transf_dic_var" + j).innerText
                if (valor.toUpperCase().indexOf($('buscar').value.toUpperCase()) != -1) {
                    $("span_transf_dic_var" + j).addClassName('resaltar')
                }
                else
                    $("tr_transf_dic_var" + j).hide()
                j++
            }
        }
    }

    function limpiar() {

        var j = 0
        while (j < i) {
            $("span_transf_dic_var" + j).removeClassName('resaltar')
            $("tr_transf_dic_var" + j).show()
            j++
        }

    }

    function onkeypress_function(e) {
        
        key = Prototype.Browser.IE ? e.keyCode : e.which
        //if (key == 13) {
            limpiar()
            Buscar()
        //}
        
     }

    function onkeyup_function(e) {

        if (Event.element(e).value == "")
            limpiar()

    }

</script>

<style type="text/css">

  .resaltar{background-color:#FF0;}

</style> 

</HEAD>
<body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
         <table class='tb1' id="tbDic" style="width:100%">  
                <tr class="tbLabel contenedor">
                  <td id="tit_dic_var" style="text-align:center" ><b>Parámetros</b></td>
                </tr>
                 <tr class="contenedor">
                  <td style="height:70%;"><input type="text" id="buscar" style="width:55%;display:inline-block;margin-right:5px" onkeyup="onkeyup_function(event)" onkeypress="onkeypress_function(event)" /><input type="button" style="width:40%;display:inline-block;cursor:pointer" value="Buscar" onclick="Buscar()"/></td>
                </tr>
                <tr>
                  <td style="height:70%;" colspan="2"><div style="width:100%;overflow:auto" id="div_dic_var">&nbsp;</div></td>
                </tr>
         </table>     
</body>
</HTML>