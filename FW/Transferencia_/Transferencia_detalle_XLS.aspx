<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
<head>
<title>Transferencia Detalle XLS</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
            
    <script type="text/javascript" src="/FW/transferencia/script/transf_utiles.js"></script>
<%
    Dim indice = nvUtiles.obtenerValor("indice","")
%>

<script type="text/javascript">

var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:120, okLabel: "cerrar"}); }

var indice
var Transferencia
var objScript = new tScript();

function window_onload() 
{
if(!Prototype.Browser.IE)
 {
  $('xls_path_file').hide()
  $('xls_path_text').setStyle({width:'100%'})
 }

  Event.observe($('target_cd'),'dblclick',function(e) {
                                                         script_editar(e)
                                                      });
                                                    

indice = $('indice').value
Transferencia = parent.return_Transferencia()

if (indice == -1)
   {
    $('xls_path_text').value = ''
   }
else
   {
    $('xls_path_text').value = Transferencia["detalle"][indice]["xls_path"]
    $('xls_path_text_save_as').value = Transferencia["detalle"][indice]["xls_path_save_as"]
    $('xls_visible').checked = Transferencia["detalle"][indice]["xls_visible"] 
    $('xls_cerrar').checked = Transferencia["detalle"][indice]["xls_cerrar"]
    $('xls_guardar_resultado').checked = Transferencia["detalle"][indice]["xls_guardar_resultado"]
    cargar_target(Transferencia["detalle"][indice]["target"])
   }
    parametros_dibujar()
    window_onresize()
}

function cargar_target(target)
{
target = objScript.script_to_string(target)
var arTarget = target_parse(target)
$('target_cd').options.length = 0
arTarget.each(function(arreglo,i)
  {
  $('target_cd').options.length++
  $('target_cd').options[$('target_cd').options.length-1].text = arreglo['target']
  });
}

function parametro_xls_nuevo()
{
  transferencia_actualizar() 
  
  var i = Transferencia["detalle"][indice]["parametros_det"].length
  Transferencia["detalle"][indice]["parametros_det"][i] = new Array();
  Transferencia["detalle"][indice]["parametros_det"][i]["parametro"] = ''  
  Transferencia["detalle"][indice]["parametros_det"][i]["valor_hoja"] = ''
  Transferencia["detalle"][indice]["parametros_det"][i]["valor_celda"] = ''
  Transferencia["detalle"][indice]["parametros_det"][i]["valor_io"] = 1
  Transferencia["detalle"][indice]["parametros_det"][i]["estado"] = 'N' 
    
  parametros_dibujar()
}

function parametro_cargar(campo,disabed,valor)
{

      var Str_Param = "<select style='width:100%' name='" + campo + "' "+ disabed +" id='" + campo + "'>"
          Str_Param += "<option value=''></option>"
      Transferencia["parametros"].each(function(arreglo,j)
          { 
           var seleccionado = ''
           seleccionado = arreglo['parametro'] == valor ? 'selected' : ''
           Str_Param += "<option value='" +  arreglo['parametro'] + "' " + seleccionado + ">" + arreglo['parametro'] + "</option>"
        });

      Str_Param += "</select>"     
      
    return Str_Param   
}


function parametros_dibujar()
{
      $('divParametros').innerHTML = ""
 
      var strHTML = "<table class='tb1'>"  
      var i = 0   
     
      Transferencia["detalle"][indice]["parametros_det"].each(function(arreglo,j)
          { 
           strHTML += "<tr>"
      
           var requerido_habi = ''
           var disabled_editable = ' disabled '
           if (arreglo["habilitado"])
            {
             requerido_habi = 'checked'
             disabled_editable = ' '
            }
             
           strHTML += "<td style='width:18px; text-align:center; vertical-align:middle'><input type='checkbox' style='border:0px' " + requerido_habi + " name='habilitado" + j + "' id='habilitado" + j + "' onclick='btn_habilitado_onclick(" + j + ")'/></td>" 
           strHTML += "<td style='text-align:left; vertical-align:middle'>" + parametro_cargar("parametro"+j,disabled_editable,arreglo["parametro"]) + "</td>"          
           strHTML += "<td style='width:98px !Important; text-align:left; vertical-align:middle'><input type='text' style='width:98px !Important' " + disabled_editable + " name='valor_hoja" + j + "' id='valor_hoja" + j + "' value='" + arreglo["valor_hoja"] + "'/></td>"                    
           strHTML += "<td style='width:258px !Important; text-align:left; vertical-align:middle'><input type='text' style='width:258px !Important' " + disabled_editable + " name='valor_celda" + j + "' id='valor_celda" + j + "' value='" + arreglo["valor_celda"] + "'/></td>"          
           strHTML += "<td style='width:118px !Important;text-align:center; vertical-align:middle'>" + IO_cargar( j , arreglo["valor_io"]) + "</td>"                                                                      
           strHTML += "</tr>"
          
           i++ 
          });            
      strHTML += "</table>"
      
    $('divParametros').insert({top:strHTML})     
}

function btn_habilitado_onclick(j)
{
campo_habilitado = $('habilitado' + j)
campo_parametro = $('parametro' + j)
campo_valor_hoja = $('valor_hoja' + j)
campo_valor_celda = $('valor_celda' + j)
campo_valor_io = $('valor_io' + j)

campo_parametro.disabled = !campo_habilitado.checked
campo_valor_hoja.disabled = !campo_habilitado.checked
campo_valor_celda.disabled = !campo_habilitado.checked
campo_valor_io.disabled = !campo_habilitado.checked

}

var arIO =  new Array();
function IO_cargar(orden, io)
{  
    if (arIO.length ==  0) 
      {
       arIO[0] = new Array();
       arIO[0]['valor'] =  1
       arIO[0]['desc'] =  'Entrada'
       arIO[1] = new Array();
       arIO[1]['valor'] =  2
       arIO[1]['desc'] =  'Salida'
       arIO[2] = new Array();
       arIO[2]['valor'] =  3
       arIO[2]['desc'] =  'Entrada/Salida'
      }
      
    var disabled = ''
    if (!Transferencia["detalle"][indice]["parametros_det"][orden]["habilitado"])
             disabled = 'disabled'
    var Str_IO = "<select style='width:100%' " + disabled + " name='valor_io"  + orden + "' id='valor_io"  + orden + "'>"
    
    var seleccionado = ''
    arIO.each(function(arreglo,i)
        {
         seleccionado = arreglo['valor'] == io ? 'selected' : ''
         Str_IO += "<option value='" +  arreglo['valor'] + "' " + seleccionado + ">" + arreglo['desc']  + "</option>"
        });

    Str_IO += "</select>"     
return Str_IO
}


function transferencia_actualizar()
{
 //Actualiza Parametros
 Transferencia["detalle"][indice]["parametros_det"].each(function(arreglo,j)
  {  
    arreglo["habilitado"] = $('habilitado' + j).checked
    arreglo["parametro"] = $('parametro' + j).value
    arreglo["valor_hoja"] = $('valor_hoja'+j).value
    arreglo["valor_celda"] = $('valor_celda'+j).value
    arreglo["valor_io"] = $('valor_io' + j).value
   } );
 }  


function validar() {

    var strError = ''

    if ($('xls_path_text').value == '')
        strError = 'No se ha ingresado el "Path XLS"</br>'

    Transferencia["detalle"][indice]["parametros_det"].each(function (arreglo, j) {
        if ($('habilitado' + j).checked) {
            if ($('parametro' + j).value == '')
                strError += 'Falta definir parametros </br>'
            if ($('valor_hoja' + j).value == '')
                strError += 'Falta definir el valor de la hoja </br>'
            if ($('valor_celda' + j).value == '')
                strError += 'Falta definir el valor de la celda </br>'
        }
    });


    return strError
}

function guardar() {

    transferencia_actualizar()

    if (indice == -1) {
        Transferencia["detalle"].length++
        indice = Transferencia["detalle"].length - 1
        Transferencia["detalle"][indice] = new Array();
    }

    Transferencia["detalle"][indice]["orden"] = indice
    Transferencia["detalle"][indice]["transf_tipo"] = 'XLS'
    Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
    Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
    Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
    Transferencia["detalle"][indice]["xls_path"] = $('xls_path_text').value
    Transferencia["detalle"][indice]["xls_path_save_as"] = $('xls_path_text_save_as').value
    Transferencia["detalle"][indice]["xls_visible"] = $('xls_visible').checked
    Transferencia["detalle"][indice]["xls_cerrar"] = $('xls_cerrar').checked
    Transferencia["detalle"][indice]["xls_guardar_resultado"] = $('xls_guardar_resultado').checked

    var cadena = ""
    for (var u = 0; u < $('target_cd').length; u++) {
        if ($('target_cd').options[u].text != "")
            cadena += $('target_cd').options[u].text + ';'
    }
    Transferencia["detalle"][indice]["target"] = objScript.string_to_script(cadena)

    for (var i = 0; i < Transferencia["detalle"][indice]["parametros_det"].length; i++)
        if (Transferencia["detalle"][indice]["parametros_det"][i]["estado"] == 'N')
            Transferencia["detalle"][indice]["parametros_det"][i]["estado"] = ''

    return Transferencia 

}

//function Aceptar()
//{ 
//  var strError = ''
//  if ($('xls_path_text').value == '')
//    strError = 'No se ha ingresado el "Path XLS"</br>'
  
// Transferencia["detalle"][indice]["parametros_det"].each(function(arreglo,j)
//  {  
//    if($('habilitado' + j).checked)
//     {
//      if ($('parametro' + j).value == '')
//          strError += 'Falta definir parametros </br>'
//      if ($('valor_hoja'+ j).value == '')
//          strError += 'Falta definir el valor de la hoja </br>'
//      if ($('valor_celda'+ j).value == '')
//          strError += 'Falta definir el valor de la celda </br>'   
//     }
//  });
   
//  if (strError != '')
//    {
//    alert('\n' + strError)
//    return null
//    }
 
// transferencia_actualizar()
     
// if (indice == -1)
//   {
//    Transferencia["detalle"].length++
//    indice = Transferencia["detalle"].length -1 
//    Transferencia["detalle"][indice] = new Array();
//   }

// Transferencia["detalle"][indice]["orden"] = indice
// Transferencia["detalle"][indice]["transf_tipo"] = 'XLS'       
// Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
// Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
// Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
// Transferencia["detalle"][indice]["xls_path"] = $('xls_path_text').value
// Transferencia["detalle"][indice]["xls_path_save_as"] = $('xls_path_text_save_as').value
// Transferencia["detalle"][indice]["xls_visible"] = $('xls_visible').checked
// Transferencia["detalle"][indice]["xls_cerrar"] = $('xls_cerrar').checked
// Transferencia["detalle"][indice]["xls_guardar_resultado"] = $('xls_guardar_resultado').checked

// var cadena = ""
// for (var u=0; u < $('target_cd').length; u++)
//   {
//    if ($('target_cd').options[u].text!="")
//      cadena += $('target_cd').options[u].text + ';'
//   }  
// Transferencia["detalle"][indice]["target"] = objScript.string_to_script(cadena)  
 
// for (var i = 0 ; i < Transferencia["detalle"][indice]["parametros_det"].length ; i++)
//     if(Transferencia["detalle"][indice]["parametros_det"][i]["estado"] == 'N')
//       Transferencia["detalle"][indice]["parametros_det"][i]["estado"] = ''
   
//return Transferencia 
//}

function xls_path_file_onchange()
  {
  $('xls_path_text').value = $('xls_path_file').value 
  }

function xls_path_file_save_as_onchange()
  {
  $('xls_path_text_save_as').value = $('xls_path_file_save_as').value 
  }
  
function cadena_pasar()  
{
 var cadena=""
 for(var i=0; i < $('cb_parametro_sele').options.length; i++)
  {
   cadena += $('cb_parametro_sele').options[i].text + ";"
  }
 return (cadena)
}

function cargar_target(target)
{
target = objScript.script_to_string(target)
var arTarget = target_parse(target)
$('target_cd').options.length = 0
arTarget.each(function(arreglo,i)
  {
  $('target_cd').options.length++
  $('target_cd').options[$('target_cd').options.length-1].text = arreglo['target']
  });
}


 function btn_target_nuevo_onclick()
{
  $('target_cd').options.length++
  if($('target_cd').options.seletedIndex != undefined)
    $('target_cd').options[$('target_cd').options.length-1].text = $('target_cd').options[$('target_cd').options.seletedIndex].text
  $('target_cd').options[$('target_cd').options.length-1].selected = true
}  

function btn_target_borrar_onclick()
 {
 if ($('target_cd').selectedIndex > -1)
    $('target_cd').remove($('target_cd').selectedIndex)
 } 


function window_onresize()
{
 try
 {
  var dif = Prototype.Browser.IE ? 5 : 2
  var body_h = $$('body')[0].getHeight()
  var divCab_h = $('divCab').getHeight()
  var tbTarget_h = $('tbTarget').getHeight()
  var divPar_h = $('divMenuParametros').getHeight()
  $('divParametros').setStyle({'height': body_h - divCab_h - divPar_h - tbTarget_h  - dif })
 }
 catch(e){}
}

 function abm_transferencia_parametros() 
  {
   //si existe una ventana de parametros abierta no crea otra
   var _windows = window.top.Windows.windows
   for (var i=0; i < _windows.length ; i++)
       if(_windows[i].options.title == '<b>Transferencia Parámetros</b>')
           _windows[i].close()
 
   transferencia_actualizar()
 
   var path = "/FW/transferencia/transferencia_parametros_abm.aspx?id_transferencia="+ Transferencia['id_transferencia'] 
   var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
   win = w.createWindow({ 
                            className: 'alphacube',
                            url: path,
                            title: '<b>Transferencia Parámetros</b>', 
                            minimizable: true,
                            maximizable: true,
                            draggable: true,
                            width: 1000,
                            height: 400,
                            top:60,
                            left:550,
                            resizable: true,
                            destroyOnClose: true,
                            onClose: parametros_dibujar
                       });
    
    win.options.Transferencia = Transferencia
    win.showCenter()
  }
 

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
<input type="hidden" name="indice" id="indice" value="<%=indice%>" />
<div id="divCab" style="margin: 0px;padding: 0px;">
    <table class='tb1' width='100%'>
        <tr class='tbLabel'>
           <td colspan="3">Path del XLS</td>
        </tr>
        <tr>
            <td style="width: 100%"><input type="text" style="WIDTH: 75%" name="xls_path_text" id="xls_path_text"/>
            <input type="file" onchange="return xls_path_file_onchange()" style="WIDTH: 155px;border:0px;vertical-align:top" id="xls_path_file" /></td>
        </tr>
        <tr class='tbLabel'>
         <td colspan="3">Opciones</td>
        </tr>
        <tr>
         <td colspan="3">
         <table class='tb1'>
         <tr>
            <td class="Tit1" style="width: 10%;text-align:right">Visible:</td>
            <td style="width: 5%"><input type="checkbox" style="WIDTH: 85%;border:0px" name="xls_visible" id="xls_visible"/></td>
            <td class="Tit1" style="width: 10%;text-align:right">Cerrar:</td>
            <td style="width: 5%"><input type="checkbox" style="WIDTH: 85%;border:0px" name="xls_cerrar" id="xls_cerrar" /></td>
            <td class="Tit1" style="width: 10%;text-align:right;white-space:nowrap">Guardar Como:</td>
            <td style="width: 5%"><input type="checkbox" style="WIDTH: 85%;border:0px" name="xls_guardar_resultado" id="xls_guardar_resultado"/></td>
            <td><input type="text" style="WIDTH: 65%" name="xls_path_text_save_as" id="xls_path_text_save_as"/>
            <input type="file" onchange="return xls_path_file_save_as_onchange()" style="WIDTH: 155px;border:0px;vertical-align:top;color:white" id="xls_path_file_save_as" /></td>
         </tr>
         </table>
          </td>
        </tr>

    </table> 
    <div id="divMenuParametros" style="margin: 0px;padding: 0px;"></div>
        <script type="text/javascript">
         var DocumentMNG = new tDMOffLine;
         var vMenuParametros = new tMenu('divMenuParametros','vMenuParametros');
         Menus["vMenuParametros"] = vMenuParametros
         Menus["vMenuParametros"].alineacion = 'centro';
         Menus["vMenuParametros"].estilo = 'A';
         //Menus["vMenuParametros"].imagenes = Imagenes //Imagenes se declara en pvUtiles
         Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")  
         Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>var</icono><Desc>Variables</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_transferencia_parametros()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parametro_xls_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenuParametros.loadImage("var", '/fw/image/transferencia/variable.png')
         vMenuParametros.loadImage("nueva", '/fw/image/transferencia/nueva.png')
         vMenuParametros.MostrarMenu()
        </script> 
     <table class='tb1'>
     <tr class='tbLabel'>
       <td style='width:20px; text-align:center'>-</td>
       <td style='text-align:center'>Parámetro</td>
       <td style='width:100px; text-align:center'>Hoja</td>
       <td style='width:260px; text-align:center'>Celda</td>
       <td style='width:130px; text-align:center'>IO</td>
     </tr>
    </table>          
    </div>
    
    <div id="divParametros" style="width:100%;overflow:auto;"></div>
    
    <div style="display:none">
    <table id="tbTarget" class='tb2' style="width:100%;height:150px">   
       <tr class='tbLabel'>
            <td colspan="3">TARGET</td>
       </tr>
        <tr>
            <td style="width: 90%"><select style="width: 100%" size="8" id='target_cd'></select></td>
            <td style="width: 10%; vertical-align: middle"><input type="button" name="btn_target_nuevo" style="width: 100%" value="Nuevo" onclick ="btn_target_nuevo_onclick()"/>
            <input type="button" name="btn_target_borrar" style="width: 100%" value="Borrar" onclick ="btn_target_borrar_onclick()"/></td>

         </tr>
    </table>       
    </div>       
</body>
</html>