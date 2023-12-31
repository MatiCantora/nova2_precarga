<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
<head>
<title>Transferencia Detalle DTS</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
    <script type="text/javascript" src="/FW/script/tTable.js"></script>    
    <script type="text/javascript" src="/FW/script/tcampo_head.js"></script>     
    <script type="text/javascript" src="/FW/transferencia/script/transf_destino_utiles.js"></script>

    <%--<script type="text/javascript" src="/FW/transferencia/script/transf_utiles.js"></script>--%>
<%
    Dim indice = nvUtiles.obtenerValor("indice","")
%>


<script type="text/javascript">

var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:120, okLabel: "cerrar"}); }
var indice
var Transferencia
var objScript

function window_onload() 
{
//if(!Prototype.Browser.IE)
// {
  $('dtsx_path_file').hide()
  $('td_file_dtsx').hide()
  $('dtsx_path_text').setStyle({width:'100%'})
 //}

indice =$('indice').value
Transferencia = parent.return_Transferencia()

objScript = new tScript();
objScript.cargar_parametros(Transferencia['parametros'])

if (indice == -1)
  {
    $('dtsx_path_text').value = ''
    campos_defs.set_value('file_dtsx','')
    var objSelect
    Transferencia["parametros"].each(function(arreglo,j)
    {
      objSelect = $('cb_parametro_total')
      objSelect.options.length++
      objSelect.options[objSelect.options.length-1].value = arreglo["parametro"]
      objSelect.options[objSelect.options.length-1].text = arreglo["parametro"]  
     });
   }
else
   {
   
    $('cb_dtsx_exec').value = Transferencia["detalle"][indice]["dtsx_exec"] == '' ? 'NET' : Transferencia["detalle"][indice]["dtsx_exec"]


    if ($('cb_dtsx_exec').value == '') $('cb_dtsx_exec').value= 'NET'

    $('dtsx_path_text').value = Transferencia["detalle"][indice]["dtsx_path"]
    var sourceDTS = Transferencia["detalle"][indice].parametros_extra.source_dts

    switch (sourceDTS) 
      {
      case 'gestor':
        $('seluri').value = 'gestor'
        $('file_dtsx_desc').value = $('dtsx_path_text').value
        $('dtsx_path_text').value = ''
        onchange_metodo()
        break
      case 'local':
        $('seluri').value = 'local'
        $('dtsx_path_text').value = $('dtsx_path_text').value
        break
      default:
        $('seluri').value = 'local'
        $('dtsx_path_text').value = $('dtsx_path_text').value
      }

    //$('dtsx_path_text').value = Transferencia["detalle"][indice]["dtsx_path"]
    //if ($('dtsx_path_text').value.indexOf('[%local%]') > -1) {
    //    $('seluri').value = 'local'
    //    $('dtsx_path_text').value = $('dtsx_path_text').value.replace('[%local%]', '')
    //} else 
    //    if ($('dtsx_path_text').value != '') {
    //        $('seluri').value = 'default'
    //        $('file_dtsx_desc').value = $('dtsx_path_text').value
    //        $('dtsx_path_text').value = ''
    //        onchange_metodo()
    //    }
    var str=Transferencia["detalle"][indice]["dtsx_parametros"]
    var par = str.split(';')
    var bandera = false   
    var objSelect
    
   par.each(function(arreglo,i)
   {par[i] = replace(arreglo,' ','')});
   
   Transferencia["parametros"].each(function(arreglo_j,j)
      {
      bandera = true
      par.each(function(arreglo_i,i)
        {
         if (arreglo_j["parametro"]== arreglo_i)
           {
           objSelect = $('cb_parametro_sele')
           bandera = false
           return;
           }
        });
      if (bandera)  
        objSelect = $('cb_parametro_total')
        
      objSelect.options.length++
      objSelect.options[objSelect.options.length-1].value = arreglo_j["parametro"]
      objSelect.options[objSelect.options.length-1].text = arreglo_j["parametro"]  
      });
      cargar_target(Transferencia["detalle"][indice]["target"])
     
}
    window_onresize()
}


function validar() {

    var strError = ''
    if ($('dtsx_path_text').value == '' && $('seluri').value == 'local' && $('cb_parametro_sele').length < 0)
        strError = 'No ha ingresado ning�n valor para los campos "Path DTSX" ni "Parametros"'

    if ($('file_dtsx_desc').value == '' && $('seluri').value == 'gestor' && $('cb_parametro_sele').length < 0)
        strError = 'No ha ingresado ning�n valor para los campos "Path DTSX" ni "Parametros"'

    return strError

}

function guardar() {

    if (indice == -1) {
        Transferencia["detalle"].length++
        indice = Transferencia["detalle"].length - 1
        Transferencia["detalle"][indice] = new Array();
    }

    Transferencia["detalle"][indice]["orden"] = indice
    Transferencia["detalle"][indice]["transf_tipo"] = 'DTS'
    Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
    Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
    Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
    Transferencia["detalle"][indice]["dtsx_exec"] = $('cb_dtsx_exec').value
    Transferencia["detalle"][indice]["dtsx_path"] = ($('seluri').value != 'gestor' ? $('dtsx_path_text').value : campos_defs.get_desc('file_dtsx'))
    Transferencia["detalle"][indice].parametros_extra.source_dts = $('seluri').value
    Transferencia["detalle"][indice]["dtsx_parametros"] = cadena_pasar()

    //Cargar en un string el Target  
    var cadena = ""
    tabla_target.actualizarData();
    for (var index_fila = 1; index_fila < tabla_target.cantFilas; index_fila++) {
        if (!tabla_target.getFila(index_fila).eliminado)
            cadena += tabla_target.data[index_fila].uri + ';'
    }

    Transferencia["detalle"][indice]["target"] = objScript.string_to_script(cadena)

    return Transferencia 

}

//function Aceptar()
//{ 
//  var strError = ''
//  if ($('dtsx_path_text').value == '' && $('cb_parametro_sele').length < 0 )
//    strError = 'No ha ingresado ning�n valor para los campos "Path DTSX" ni "Parametros"'
   
//  if (strError != '')
//    {
//    alert('\n' + strError)
//    return null
//    }
    
// if (indice == -1)
//   {
//    Transferencia["detalle"].length++
//    indice = Transferencia["detalle"].length -1 
//    Transferencia["detalle"][indice] = new Array();
//   }

// Transferencia["detalle"][indice]["orden"] = indice
// Transferencia["detalle"][indice]["transf_tipo"] = 'DTS'       
// Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
// Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
// Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
// Transferencia["detalle"][indice]["dtsx_exec"] = $('cb_dtsx_exec').value
// Transferencia["detalle"][indice]["dtsx_path"] = $('dtsx_path_text').value
// Transferencia["detalle"][indice]["dtsx_parametros"] = cadena_pasar()

// //Cargar en un string el Target  
// var cadena = ""
// tabla_target.actualizarData();
// for (var index_fila = 1; index_fila < tabla_target.cantFilas ; index_fila++) {
//     if (!tabla_target.getFila(index_fila).eliminado)
//         cadena += tabla_target.data[index_fila].uri + ';'
// }

// Transferencia["detalle"][indice]["target"] = objScript.string_to_script(cadena)
   
//return Transferencia 
//}

function btn_agregar_onclick ()
{
if ($('cb_parametro_total').selectedIndex > -1 && $('cb_parametro_total').options[$('cb_parametro_total').selectedIndex].text != '')
  {
  $('cb_parametro_sele').options.length++
  $('cb_parametro_sele').options[$('cb_parametro_sele').options.length-1].text = $('cb_parametro_total').options[$('cb_parametro_total').selectedIndex].text
  $('cb_parametro_total').remove($('cb_parametro_total').selectedIndex)
  }
}

function btn_quitar_onclick ()
{
 if ($('cb_parametro_sele').selectedIndex > -1 && $('cb_parametro_sele').options[$('cb_parametro_sele').selectedIndex].text != '')
  {
  $('cb_parametro_total').options.length++
  $('cb_parametro_total').options[$('cb_parametro_total').options.length-1].text = $('cb_parametro_sele').options[$('cb_parametro_sele').selectedIndex].text
  $('cb_parametro_sele').remove($('cb_parametro_sele').selectedIndex)
  }
}

function dts_path_file_onchange()
  {
  $('dtsx_path_text').value = $('dtsx_path_file').value 
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

//var txt 
//function script_editar(e)
//  { 
  
//  txt = Event.element(e) 
//  if(txt.id == '')
//    txt = Event.element(e).parentElement
  
//  var script_txt
//  switch(txt.id)
//  {
//   case 'target_cd':
//    protocolo = 'FILE'
//    if (txt.selectedIndex == -1)
//      {
//       alert("Inserte un nuevo target")
//       return
//      }
//    script_txt = txt.options[txt.selectedIndex].text
//   break;
//   default:
//    protocolo = 'XML'
//    script_txt = txt.value
//  }
  
//  var objScriptEditar = new Array()
//  objScriptEditar['script_txt'] = script_txt
//  objScriptEditar['parametro'] = Transferencia['parametros']
//  objScriptEditar['protocolo'] = protocolo
   
//  var path = "editor_script.aspx"
  
//  var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
//  win = w.createWindow({className: 'alphacube', 
//                        url: path, 
//                        title: '<b>Transferencia Editar</b>', 
//                        minimizable: false,
//                        maximizable: false,
//                        draggable: true,
//                        width: 950, 
//                        height: 550,
//                        destroyOnClose: true,
//                        onClose: script_editar_return
//                      });
  
//  win.options.objScriptEditar = objScriptEditar
//  win.options.id = txt.id
//  win.showCenter(true)
 
// }
 
//function script_editar_return()
// {
//  if(win.returnValue == 'OK')
//  {
//   try
//     {
//      if(win.options.id == 'target_cd')
//       {
//        protocolo = win.options.objScriptEditar['script_txt'].split('://')[0] 
//        if(protocolo == 'NAME')
//          alert("No se puede adjuntar a un archivo temporal")
//        else
//         {  
//          txt.options[txt.selectedIndex].text =  win.options.objScriptEditar['script_txt']
//          txt.options[txt.selectedIndex].value =   win.options.objScriptEditar['script']
//         }
//       } 
//     }
//   catch(e){}  
//  } 
//}  

var txt
function script_editar(param) {

    if (typeof (param) == "string") {
        id = param
        param = {}
        param.id = id
        param.indice = null
    }

    id = param.id

    var protocolo = ''
    var script_txt
    switch (id) {
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

            if (param.indice) {
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

    var objScriptEditar = new tScript()
    objScriptEditar['script_txt'] = script_txt
    objScriptEditar['parametro'] = Transferencia['parametros']
    objScriptEditar['protocolo'] = protocolo

    var path = "/fw/transferencia/editor_script.aspx"

    var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
    win = w.createWindow({
        className: 'alphacube',
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

function script_editar_return() {

    if (win.returnValue == 'OK') {
        try {
            if (win.options.id != 'target_cd') {
                txt.value = win.options.objScriptEditar['script_txt']

                if (win.options.id == "filtroXML")
                    setContentFiltroXML($('filtroXML').value)

                if (win.options.id == "filtroWhere")
                    setContentFiltroWhere($('filtroWhere').value)

                if (win.options.id == "parametros")
                    setContentFiltroParametro($('parametros').value)
            }

            else {
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

                tabla_target.data.splice(0, 1);

                tabla_target_recargar()
            }
        }
        catch (e) { }
    }
    // $('filtroXML').onchange()
}

function tabla_target_recargar() {
    tabla_target.mostrar_tabla(tabla_target);

    var img_agregar = $('div_boton_tabla_target').querySelectorAll("img")
    for (var i = 0; i < img_agregar.length; i++) {
        img_agregar[i].onclick = alta_target
    }

    var img_editar = $('campos_tb_tabla_target').querySelectorAll("img")
    for (var i = 0; i < img_editar.length; i++) {
        if (img_editar[i].title.toLowerCase().indexOf('editar') > -1)
            img_editar[i].onclick = editar_target
    }

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

function window_onresize() {
    try {

    var dif = Prototype.Browser.IE ? 5 : 2
    var body_heigth = $$('body')[0].getHeight()
    var divhead_height = $('divhead').getHeight()
    var divbody_height = $('divbody').getHeight()
    var calc = body_heigth - divhead_height - divbody_height  - dif + "px"

    $('tbDatosTarget').setStyle({ height: calc })

    if (tabla_target) {
        tabla_target.resize();
    }

    }
    catch (e) {  }

}

var tabla_target
function cargar_target(target) {

    target = objScript.script_to_string(target)
    var arTarget = target_parse(target)

    tabla_target = new tTable();
    tabla_target.cn = '';
    tabla_target.filtroXML = ''

    tabla_target.nombreTabla = "tabla_target";
    tabla_target.editable = true;
    tabla_target.eliminable = true;
    tabla_target.mostrarAgregar = true;
    tabla_target.cabeceras = ["Target", "Guardar como", "Agregar", "Comprime"];
    tabla_target.campos = [
        {
            nombreCampo: "target", width: "65%", editable: false, ordenable: false
        },
        {
            nombreCampo: "xls_save_as", width: "15%", editable: false, ordenable: false
        },
        {
            nombreCampo: "target_agregar", width: "5%", editable: false, ordenable: false, align: "center"
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

    for (var i = 0; i < arTarget.length; i++) {
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

function editar_target(e) {
    var cadena = e.srcElement.outerHTML
    strExp = "(?:')(.*?)(?:')"
    var reg = new RegExp(strExp, "ig")
    var indice = eval(cadena.match(reg)[0])
    script_editar({ id: "target_cd", indice: indice })
}

function onchange_metodo() {
    switch ($('seluri').value) {
        case "local":
            $('td_file_dtsx').hide()
            $('td_dtsx_path').show()
            break
        case "gestor":
            $('td_file_dtsx').show()
            $('td_dtsx_path').hide()
            break     
        default:
            $('td_file_dtsx').hide()
            $('td_dtsx_path').show()
    }
}

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style="background-color:white; width:100%;height:100%;overflow:hidden">
<input type="hidden" name="indice" id="indice" value="<%=indice%>" />
    <div id="divhead" style="width:100%;display:inline-block">
    <table class='tb1'>
        <tr class='tbLabel'>
           <td style="width:10%" nowrap>Execute</td>
           <td colspan="3">Ruta del paquete DTSX</td>
        </tr>
        <tr>
            <td><select name="cb_dtsx_exec" id="cb_dtsx_exec" style="width:100%">
               <%--   <option value='SSIS2005'>SSIS 2005</option>
                  <option value='SSIS2008' selected ="selected">SSIS 2008</option>--%>
                  <option value='NET' selected ="selected">NET</option>  
                </select>
            </td>
            <td style="width: 15%">
                <%--<span style="display:inline-block;width:15%">--%>
                    <select id="seluri" style="width:100%" onchange="return onchange_metodo()"><option value="gestor" >Gestor</option><option selected="selected" value="local">Local</option></select>
                <%--</span>--%>
            </td>
            <td id="td_dtsx_path" style="width:84%">
                <%--<span id="span_dtsx_path" style="display:inline-block;width:84%">--%>
                    <input type="text" style="WIDTH: 87%" name="dtsx_path_text" id="dtsx_path_text"/>
                    <input type="file" onchange="return dts_path_file_onchange()" style="WIDTH: 95px;border:0px;vertical-align:top" id="dtsx_path_file"/>
                <%--</span>--%>
            </td>
            <td id="td_file_dtsx" style="width:84%">
                <script>
                       campos_defs.add('file_dtsx',{
                           enDB: false,
                           nro_campo_tipo: 90,
                           file_dialog: {
                               seleccionar: true,
                               view: 'detalle',
                               filters: {
                                   0: {
                                       titulo: 'Plantillas',
                                       filter: '*.dtsx',
                                       inicio: false
                                   }
                               }
                           }//,
                         //onchange: file_dtsx_onchange
                       })
                   </script>
            </td>
        </tr>
    </table> 
         </div>
     <div id="divbody" style="width:100%;display:inline-block">
     <table class='tb1'>
        <tr class='tbLabel'><td colspan="3">Par�metros</td></tr>
        <tr>
           <td style="width:40%; text-align:center">Todos Los Par�metros<select style="width:100%" size="14" name='cb_parametro_total' id='cb_parametro_total' ondblclick ="btn_agregar_onclick()"></select></td>
           <td  style="vertical-align:middle">
               <input type="button" style="width: 100%" name="btn_agregar" value="Agregar" onclick="btn_agregar_onclick()"/>
               <input type="button" style="width: 100%" name="btn_sacar" value="Quitar" onclick="btn_quitar_onclick()" />
           </td>
           <td style="width:40%; text-align:center">Par�metros Seleccionados<select style="width:100%" size="14" name='cb_parametro_sele' id='cb_parametro_sele' ondblclick ="btn_quitar_onclick()" ></select></td>
        </tr>   
     </table>  
    </div>
    <div id="tbDatosTarget" style="width: 100%;min-height:150px;display:inline-block">
       <div id="tabla_target" style="width: 100%;"></div>
     </div>
   
</body>
</html>