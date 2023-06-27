<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

%>
<html>
<head>
<title>Transferencia Detalle Exp</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/Transferencia/script/CodeMirror/lib/codemirror.css" rel="stylesheet" >            
    
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
    <script type="text/javascript" src="/FW/script/tTable.js"></script>    
    <script type="text/javascript" src="/FW/script/tcampo_head.js"></script>     
    <script type="text/javascript" src="/FW/transferencia/script/transf_destino_utiles.js"></script>

    <script type="text/javascript" src="/FW/Transferencia/script/CodeMirror/lib/codemirror.js"></script>     
    <script type="text/javascript" src="/FW/Transferencia/script/CodeMirror/mode/xml/xml.js" ></script>
    
<%
    Dim indice = nvUtiles.obtenerValor("indice", "")
%>

<% = Me.getHeadInit()%>
<script type="text/javascript">

var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 
var indice 
var Transferencia
var objScript


function window_onload() 
{

    indice = $('indice').value
    Transferencia = parent.return_Transferencia()

    cargar_target(Transferencia["detalle"][indice]["target"])

    window_onresize()

}

function Aceptar()
{

 var cadena = ""
 tabla_target.actualizarData();
 for (var index_fila = 1; index_fila < tabla_target.cantFilas ; index_fila++) {
     if (!tabla_target.getFila(index_fila).eliminado)
         cadena += tabla_target.data[index_fila].uri + ';'
 }
 
 return Transferencia 
}


function isVACIO(valor, sinulo)
{
  valor = valor == '' ? sinulo: valor
  return valor
}

var tabla_target
function cargar_target(target) {
    
 target = objScript.script_to_string(target)
 //target = "FILE://directorio_archivos/prueba.xls||<opcional xls_save_as='' comp_metodo='rar' comp_algoritmo='wwws' comp_pwd='sss' ></opcional>||;FILE://directorio_archivos/mario.xls||<opcional xls_save_as='' comp_metodo='rar' comp_algoritmo='wwws' comp_pwd='sss' ></opcional>||"
 var arTarget = target_parse(target)

 tabla_target = new tTable();
 tabla_target.cn = '';
 tabla_target.filtroXML = ''

 tabla_target.nombreTabla = "tabla_target";
 tabla_target.editable = true;
 tabla_target.eliminable = true;
 tabla_target.mostrarAgregar = true;
 tabla_target.funcionCheckBox = true;
 tabla_target.cabeceras = ["Target", "Guardar como", "Comprime"];
 tabla_target.campos = [
     {
         nombreCampo: "target", width: "65%", editable: false, ordenable: false
     },
     {
         nombreCampo: "xls_save_as", width: "15%", editable: false, ordenable: false
     },
     {
         nombreCampo: "comp_metodo", width: "5%", editable: false, ordenable: false
     },
 ]

 tabla_target.camposHide = [
     {
         nombreCampo: "uri",
         nombreCampo: "protocolo"
     }]

 tabla_target.data = [];

 for (var i = 0; i < arTarget.length; i++)
 {
        var fila = {};
        fila["protocolo"] = arTarget[i].protocolo
        fila["target"] = arTarget[i].target
        fila["xls_save_as"] = getExtSave_as(arTarget[i].xls_save_as)
        fila["comp_metodo"] = !arTarget[i].comp_metodo ? "" : arTarget[i].comp_metodo
        fila["target_agregar"] = !arTarget[i].target_agregar ? "No" : (arTarget[0].target_agregar == 'true' ? 'Si' : 'No')
        fila["uri"] = arTarget[i].protocolo.toLowerCase() == 'mailto' ? arTarget[i].target : arTarget[i].uri

        fila.tabla_control = {};
        tabla_target.data.push(fila);
     }
 
 tabla_target_recargar();

}

function alta_target(e) {
    script_editar({ id: "target_cd" })
}

function editar_target(e)
{
    var cadena = e.srcElement.outerHTML
    strExp = "(?:')(.*?)(?:')"
    var reg = new RegExp(strExp, "ig")
    var indice = eval(cadena.match(reg)[0])
    script_editar({ id: "target_cd", indice: indice })
}

function valXML(strXML)
{
var strError = ''
var objXML = new tXML();
if (!objXML.loadXML(strXML))
  {
  strError = 'ErrorCode: ' + objXML.parseError.errorCode + '\nReason: ' + objXML.parseError.reason
  strError += 'strText: ' + objXML.parseError.strText 
  }  
return strError
}

function cb_xsl_name_onchange()
  { 
  if ($('cb_xsl_name').selectedIndex > 0)
    $('path_xsl_text').value = ''
  }

var txt 
function script_editar(param)
  { 
  
  if (typeof (param) == "string")
    {
      id = param
      param = {}
      param.id = id
      param.indice = null
    }

  id = param.id 

  var protocolo = ''
  var script_txt
  switch (id)
  {
   case 'xml_xsl':
     txt = $(id)
     protocolo = 'XSL'
     txt = $(id + '_txt')
     script_txt = txt.value
   break;
   case 'filtroXML':
     txt = $(id)
    protocolo = 'XML'
    script_txt = txt.value
   break;
   case 'filtroWhere':
    txt = $(id)
    protocolo = 'XML'
    script_txt = txt.value
   break;
   case 'parametros':
    txt = $(id)
    protocolo = 'XML'
    script_txt = txt.value
   break;
   case 'target_cd':
       script_txt = ''

       if (param.indice)
       {
           script_txt = tabla_target.data[parseInt(param.indice)].uri
           protocolo = tabla_target.data[parseInt(param.indice)].protocolo
       }

       if (protocolo == '')
        protocolo = 'FILE'

   break;
   default:
    protocolo = 'XML'
    script_txt = txt.value
  }
  
  var objScriptEditar = new Array()
  objScriptEditar['script_txt'] = script_txt
  objScriptEditar['parametro'] = Transferencia['parametros']
  objScriptEditar['protocolo'] = protocolo
  objScriptEditar['vista'] = id

  var path = "/fw/transferencia/editor_script.aspx"
  
  var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
  win = w.createWindow({className: 'alphacube', 
                        url: path, 
                        title: '<b>Transferencia Editar</b>', 
                        minimizable: false,
                        maximizable: true,
                        draggable: true,
                        width: 950, 
                        height: 550,
                        destroyOnClose: true,
                        onClose: script_editar_return
                      });
  
  win.options.objScriptEditar = objScriptEditar
  win.options.id = id
  win.options.indice = param.indice
  win.showCenter(true)
 
 }
 
function script_editar_return()
{
    
  if(win.returnValue == 'OK') {
   try
     {
      if(win.options.id != 'target_cd')
      {
          txt.value = win.options.objScriptEditar['script_txt']

          if (win.options.id == "filtroXML")
              setContentFiltroXML($('filtroXML').value)

          if (win.options.id == "filtroWhere")
              setContentFiltroWhere($('filtroWhere').value)

          if (win.options.id == "parametros")
             setContentFiltroParametro($('parametros').value)
      }          

     else
      {
          var arTarget = target_parse(win.options.objScriptEditar['script_txt'])
          if (win.options.indice) {
              var indice = parseInt(win.options.indice)
              tabla_target.data[indice].protocolo = arTarget[0].protocolo
              tabla_target.data[indice].target = arTarget[0].target
              tabla_target.data[indice].xls_save_as = getExtSave_as(arTarget[0].xls_save_as)
              tabla_target.data[indice].comp_metodo = !arTarget[0].comp_metodo ? "" : arTarget[0].comp_metodo
              tabla_target.data[indice].target_agregar = !arTarget[0].target_agregar ? "No" : (arTarget[0].target_agregar == 'true' ? 'Si' : 'No')
              tabla_target.data[indice].uri = arTarget[0].protocolo.toLowerCase() == 'mailto' ? arTarget[0].target : arTarget[0].uri
          }
          else {
              var fila = {};
              fila["protocolo"] = arTarget[0].protocolo
              fila["target"] = arTarget[0].target
              fila["xls_save_as"] = getExtSave_as(arTarget[0].xls_save_as)
              fila["comp_metodo"] = !arTarget[0].comp_metodo ? "" : arTarget[0].comp_metodo
              fila["target_agregar"] = !arTarget[0].target_agregar ? "No" : (arTarget[0].target_agregar == 'true' ? 'Si' : 'No') 
              fila["uri"] = arTarget[0].protocolo.toLowerCase() == 'mailto' ? arTarget[0].target : arTarget[0].uri

              fila.tabla_control = {};
              tabla_target.data.push(fila);
          }

        tabla_target.data.splice(0,1);

        tabla_target_recargar()
      } 
     }
   catch(e){}  
  } 
 // $('filtroXML').onchange()
}  

function tabla_target_recargar()
{
   tabla_target.mostrar_tabla(tabla_target);

    var img_agregar = $('div_boton_tabla_target').querySelectorAll("img")
    for (var i = 0; i < img_agregar.length; i++) {
        img_agregar[i].onclick = alta_target
    }

    var img_editar = $('campos_tb_tabla_target').querySelectorAll("img")
    for (var i = 0; i < img_editar.length; i++) {
        if (img_editar[i].title == 'editar')
            img_editar[i].onclick = editar_target
    }

}

function btn_filtroParametros_onclick() {

    $('trFiltroParametros').show()
    $('trFiltroXML').hide()
    $('trFiltroWhere').hide()

    $('btn_filtroXML').setStyle({ fontWeight: "normal" })
    $('btn_filtroXML').setStyle({ color: "black" })
    $('btn_filtroXML').style.backgroundColor = ""

    $('btn_filtroWhere').setStyle({ fontWeight: "normal" })
    $('btn_filtroWhere').setStyle({ color: "black" })
    $('btn_filtroWhere').style.backgroundColor = ""

    $('btn_filtroParametros').setStyle({ fontWeight: "bold" })
    $('btn_filtroParametros').setStyle({ color: "white" })
    $('btn_filtroParametros').style.backgroundColor = "red"

    setContentFiltroParametro($('parametros').value)

}


function btn_filtroXML_onclick() {

  $('trFiltroXML').show()
  $('trFiltroWhere').hide()
  $('trFiltroParametros').hide()

  $('btn_filtroXML').setStyle({fontWeight: "bold"})
  $('btn_filtroXML').setStyle({color: "white"})
  $('btn_filtroWhere').setStyle({fontWeight: "normal"})
  $('btn_filtroWhere').setStyle({color: "black"})
  $('btn_filtroXML').style.backgroundColor="red"
  $('btn_filtroWhere').style.backgroundColor = ""

  $('btn_filtroParametros').setStyle({ fontWeight: "normal" })
  $('btn_filtroParametros').setStyle({ color: "black" })
  $('btn_filtroParametros').style.backgroundColor = ""

  setContentFiltroXML($('filtroXML').value)

}

function btn_filtroWhere_onclick()  {    
    $('trFiltroWhere').show()
    $('trFiltroXML').hide()
    $('trFiltroParametros').hide()

    $('btn_filtroWhere').style.fontWeight="bold"
    $('btn_filtroWhere').style.color="white"
    $('btn_filtroXML').style.fontWeight="normal"
    $('btn_filtroXML').style.color="black"
    $('btn_filtroXML').style.backgroundColor=""
    $('btn_filtroWhere').style.backgroundColor = "red"

    $('btn_filtroParametros').setStyle({ fontWeight: "normal" })
    $('btn_filtroParametros').setStyle({ color: "black" })
    $('btn_filtroParametros').style.backgroundColor = ""

    setContentFiltroWhere($('filtroWhere').value)

  }
 
function window_onresize() {
    try {

        var dif = Prototype.Browser.IE ? 5 : 5
        var body_heigth = $$('body')[0].getHeight()
        var divhead_height = $('divhead').getHeight()
        var divfooter_height = $('divfooter').getHeight()
        var titulofiltro = 22
        var calc = body_heigth - divhead_height - divfooter_height - titulofiltro - dif + "px"

        $('filtroXML').setStyle({height:calc})
        $('filtroWhere').setStyle({ height: calc })
        $('parametros').setStyle({ height: calc })

        editorFiltroXML.setSize('100%', (calc) )
        editorFiltroWhere.setSize('100%', (calc))
        editorFiltroParametro.setSize('100%', (calc))

        if (tabla_target) {
            tabla_target.resize();
        }

    }
    catch (e) { window.status = e.description; alert('calc: ' + calc) }

    
}

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style="width:100%;height:100%;overflow:hidden">
<input type="hidden" name="indice" id="indice" value="<%=indice%>" />
<input type="hidden" name="mantener_origen" id="mantener_origen" value=""/>
<input type="hidden" name="id_exp_origen" id="id_exp_origen" value="" />

    <div id="divhead" style="width:100%">
    <table class='tb1'>   
        <tr class='tbLabel'>
          <td style='width:10%' colspan="5"><b>Datos</b></td>
        </tr>
        <tr>
          <td class="Tit1" style='width:10%' nowrap="true">Vista Guardada:</td>
          <td><%= nvCampo_def.get_html_input("vista") %></td>
          <td class="Tit1"  style='width:5%'>Filtro:</td>
          <td style="width: 10%; vertical-align: 100%"><input type="button" name="btn_filtroXML" id="btn_filtroXML" style="WIDTH: 100%" value="XML" onclick ="btn_filtroXML_onclick()"/></td>
          <td style="width: 10%; vertical-align: 100%"><input type="button" name="btn_filtroWhere" id="btn_filtroWhere" style="WIDTH: 100%" value="Where" onclick ="btn_filtroWhere_onclick()"/></td>
          <td style="width: 10%; vertical-align: 100%"><input type="button" name="btn_filtroParametros" id="btn_filtroParametros" style="WIDTH: 100%" value="Parámetro" onclick ="btn_filtroParametros_onclick()"/></td>
        </tr>
    </table>  
     </div>
    <table class='tb1' id='tbfiltro'>   
         <tr class='tbLabel'>
            <td colspan='4'>Filtro</td>
        </tr>
        <tr id='trFiltroXML'>
           <td colspan='4'>
           <textarea rows='8' cols='1' name='filtroXML' id='filtroXML'></textarea>
           </td>
        </tr>
        <tr id='trFiltroWhere'>
           <td colspan='4'>
           <textarea rows='8' cols='1' name='filtroWhere' id='filtroWhere'></textarea></td>
        </tr>
         <tr id='trFiltroParametros'>
           <td colspan='4'>
           <textarea rows='8' cols='1' name='parametros' id='parametros'"></textarea></td>
        </tr>
    </table>   
    <div id="divfooter">
    <table class='tb1'>   
       <tr>
           <td style="width:5%" class="Tit2">Metodo:&nbsp;</td>
           <td style="width:25%"><select onchange="return onchange_metodo()" id="cb_metodo" name="cb_metodo" style="width:100%"></select></td>
           <td style="display:none" id="td_vacio">&nbsp;</td>
           <td style="display:none" id="td_xml_xsl"><input type="button" style="width:10%" value="..." id="xml_xsl" name="xml_xsl" onclick="return script_editar('xml_xsl')"/><input type="hidden" name='xml_xsl_txt' id='xml_xsl_txt' /></td>
           <td style="display:none" id="td_xsl_name"><select name="cb_xsl_name" id="cb_xsl_name" style="width:70%" onchange="cb_xsl_name_onchange()"></select></td>
           <td style="display:none" id="td_path_xsl"><input type="text" style="width: 76%" name="path_xsl_text" id="path_xsl_text" onchange="path_xsl_text_onchange()" /><input type="file" onchange="return path_xsl_file_onchange()" style="WIDTH: 95px;border:0px;vertical-align:top" id="path_xsl_file" name="path_xsl_file"/></td>
           <td  id="td_page_name" class="Tit2" style="width:25%;text-align:center">Nombre de Hoja:<input type="text" style="width:45%" name="page_name" id="page_name"/></td>
       </tr>
    </table>       
    <table class='tb1'>   
       <tr>
            <td class='Tit2' style="text-align:left">Destinos</td>
            <td class='Tit2' style="width: 10%;">Salida Tipo:</td>
            <td style="width: 10%;"><select name="cb_salida_tipo" id="cb_salida_tipo" style="width:100%" onchange='return Cargar_ContentType()'></select></td>
            <td style="width: 20%;"><select name="cb_contenttype" id="cb_contenttype" style="width:100%" disabled="disabled"></select></td>    
            <td class='Tit2' style="width: 8%;">Filename:</td>
            <td style="width: 30%;"><input type="text" style="width:100%" name="filename" id="filename"/></td>
       </tr>
    </table>
    <table class='tb1'>   
        <tr>
            <td style="width: 90%">
              <div id="tbDatosTarget" style="width: 100%;max-height:150px;min-height:150px">
                <div id="tabla_target" style="width: 100%;"></div>
              </div>
            </td>
         </tr>
    </table>  
   </div> 
</body>
</html>