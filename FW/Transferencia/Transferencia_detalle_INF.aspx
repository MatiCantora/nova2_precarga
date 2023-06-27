<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Me.contents("filtrowrp_config") = nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_config'><campos>*</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
 %>
<html>
<head>
<title>Transferencia Detalle INF</title>
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
    Dim indice = nvUtiles.obtenerValor("indice","")
%>
<% = Me.getHeadInit()%>
<script type="text/javascript">

var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 

var indice
var Transferencia
var objScript

var editorFiltroXML
function setContentFiltroXML(value) {

    if (!editorFiltroXML) {
        editorFiltroXML = CodeMirror.fromTextArea($('filtroXML'), {
            mode: 'application/xml',
            readOnly: true,
            lineNumbers: true,
            selectionPointer: true
        });

        editorFiltroXML.on("dblclick", function (event) {
            if (campos_defs.value('vista') == '')
              script_editar(editorFiltroXML.getTextArea().id);
        })
    }

    $('filtroXML').value = value
    editorFiltroXML.setValue(value);
}

var editorFiltroWhere
function setContentFiltroWhere(value) {

    if (!editorFiltroWhere) {
        editorFiltroWhere = CodeMirror.fromTextArea($('filtroWhere'), {
            mode: 'application/xml',
            readOnly: true,
            lineNumbers: true,
            selectionPointer: true,
        });

        editorFiltroWhere.on("dblclick", function (event) {
             script_editar(editorFiltroWhere.getTextArea().id);
        })
    }

    $('filtroWhere').value = value
    editorFiltroWhere.setValue(value);
}

var editorFiltroParametro
function setContentFiltroParametro(value) {

    if (!editorFiltroParametro) {
        editorFiltroParametro = CodeMirror.fromTextArea($('parametros'), {
            mode: 'application/xml',
            readOnly: true,
            lineNumbers: true,
            selectionPointer: true,
        });

        editorFiltroParametro.on("dblclick", function (event) {
              script_editar(editorFiltroParametro.getTextArea().id);
        })
    }

    $('parametros').value = value
    editorFiltroParametro.setValue(value);
}

function window_onload() 
{

if(!Prototype.Browser.IE)
  $('path_reporte_file').setStyle({ width: '155px' })
else
  $('path_reporte_file').setStyle({ width: '120px' })

indice = $('indice').value
Transferencia = parent.return_Transferencia()

objScript = new tScript();
objScript.cargar_parametros(Transferencia['parametros'])

campos_defs.items['vista']['onchange'] = vista_onchange
btn_filtroXML_onclick()
//$('filtroXML').readOnly = true
//$('filtroWhere').readOnly = true

if (indice == -1)
    {    
     $('filtroXML').value = '<criterio><select vista=""><campos>*</campos><filtro></filtro></select></criterio>'
     $('filtroWhere').value = ''
     $('cb_report_name').value = ''
     $('path_reporte_text').value = ''
     campos_defs.set_value('file_rpt', '')
     //frmDetalle_INF.target.value = ''
     Cargar_Salida_Tipo($('cb_salida_tipo'), "'estado'")
     Cargar_ContentType("'application/vnd.ms-excel'")
     Cargar_Metodo($('cb_metodo'), "''")
     $('parametros').value = ''
     $('page_name').value = ''
     $('filename').value = ''
    }
else
    {
    $('filtroXML').value = objScript.script_to_string(Transferencia["detalle"][indice]["filtroXML"])
    if (Transferencia["detalle"][indice]["vistaguardada"] != '')
      {
      campos_defs.items['vista']["input_hidden"].value = objScript.script_to_string(Transferencia["detalle"][indice]["vistaguardada"])
      campos_defs.items['vista']["input_text"].value = objScript.script_to_string(Transferencia["detalle"][indice]["vistaguardada"])
      campos_defs.items['vista']['onchange']()
      }
    $('filtroWhere').value = objScript.script_to_string(Transferencia["detalle"][indice]["filtroWhere"])
    $('path_reporte_text').value= objScript.script_to_string(Transferencia["detalle"][indice]["path_reporte"])
    Cargar_Salida_Tipo($('cb_salida_tipo'), Transferencia["detalle"][indice]["salida_tipo"])
    CargarReportes($('filtroXML').value, objScript.script_to_string(Transferencia["detalle"][indice]["report_name"]))
    cargar_target(Transferencia["detalle"][indice]["target"])
    Cargar_ContentType(Transferencia["detalle"][indice]["contenttype"])
    Cargar_Metodo($('cb_metodo'), Transferencia["detalle"][indice]["metodo"], Transferencia.detalle[indice].parametros_extra.source_rpt)
    $('file_rpt_desc').value = Transferencia.detalle[indice].parametros_extra.source_rpt == 'Gestor' ? $('path_reporte_text').value : ''
    $('parametros').value = Transferencia["detalle"][indice]["parametros"]
    $('page_name').value = !Transferencia.detalle[indice].parametros_extra.page_name ? "" : Transferencia.detalle[indice].parametros_extra.page_name
    $('filename').value = !Transferencia.detalle[indice].parametros_extra.filename ? "" : Transferencia.detalle[indice].parametros_extra.filename

    onchange_metodo()
}

setContentFiltroXML($('filtroXML').value)
setContentFiltroWhere($('filtroWhere').value)
setContentFiltroParametro($('parametros').value)

window_onresize()
}

function Cargar_Salida_Tipo(cb,salida_tipo)
{
Salida_Tipo = new Array();
Salida_Tipo[0] = 'estado'
Salida_Tipo[1] = 'adjunto'

Salida_Tipo.each(function(arreglo,i)
    {
    cb.options.length++
    cb.options[cb.options.length-1].value = arreglo 
    cb.options[cb.options.length-1].text = arreglo
    if (objScript.script_to_string(salida_tipo) == arreglo)
        cb.options[cb.options.length-1].selected = true
    });
}

function CargarReportes(criterio,nombre_reporte) {
  
 var cb =  $('cb_report_name')
 cb.options.length = 0
 objScript.set_string(criterio)
 var rpt = objScript.get_rpt()
 cb.options.length++
 cb.options[cb.options.length-1].value = 0
 cb.options[cb.options.length-1].text = ''
 for(var i=1; i< rpt.length; i++)
   {
   cb.options.length++
   cb.options[cb.options.length-1].value = rpt[i]['path']
   cb.options[cb.options.length-1].text = rpt[i]['name']
   if (nombre_reporte.toLowerCase().indexOf(rpt[i]['name'].toLowerCase()) >= 0)
     cb.selectedIndex = i
    }

    if (rpt.length == 0 && nombre_reporte != "") {
        cb.options.length++
        cb.options[cb.options.length - 1].value = nombre_reporte
        cb.options[cb.options.length - 1].text = nombre_reporte
        cb.selectedIndex = i
    }

} 

function filtroXML_on_change()
{
 if($('cb_report_name').selectedIndex != -1)
  CargarReportes($('filtroXML').value, $('cb_report_name')[$('cb_report_name').selectedIndex].text)
}

function isVACIO(valor, sinulo) {
    valor = valor == '' ? sinulo : valor
    return valor
}

function validar() {

    //Validar 
    var strError = ''

    if ($('filtroXML').value == '' || $('filtroXML').value == '<criterio><select vista=""><campos></campos><filtro></filtro></select></criterio>')
        strError += '\nDefina Defina el "filtro XML" '

    if ($('filtroWhere').value != '')
        strError += valXML($('filtroWhere').value)

    if ($('filtroXML').value != '')
        strError += valXML($('filtroXML').value)

    if ($('path_reporte_text').value == '' && $('cb_report_name').value == "" && campos_defs.get_desc('file_rpt') == '')
        strError += '\nNo ha ingresado ningún valor para los campos "Path reporte" ni "Nombre reporte"'

    return strError 

}


function guardar() {

    if (indice == -1) {
        Transferencia["detalle"].length++
        indice = Transferencia["detalle"].length - 1
        Transferencia["detalle"][indice] = new Array();
    }

    //Cargar arreglo
    Transferencia["detalle"][indice]["orden"] = indice
    Transferencia["detalle"][indice]["transf_tipo"] = 'INF'
    Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
    Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
    Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
    Transferencia["detalle"][indice]["filtroWhere"] = objScript.string_to_script($('filtroWhere').value)
    Transferencia["detalle"][indice]["salida_tipo"] = objScript.string_to_script($('cb_salida_tipo').value)

    if ($('cb_report_name').selectedIndex != -1)
        Transferencia["detalle"][indice]["report_name"] = objScript.string_to_script($('cb_report_name').options[$('cb_report_name').selectedIndex].text)
    else
        Transferencia["detalle"][indice]["report_name"] = ''

    if ($('cb_metodo').value == 'Gestor') {
        Transferencia.detalle[indice].parametros_extra.source_rpt = 'Gestor'
        $('path_reporte_text').value = campos_defs.get_desc('file_rpt')
    } else Transferencia.detalle[indice].parametros_extra.source_rpt = 'none'

    Transferencia["detalle"][indice]["path_reporte"] = objScript.string_to_script($('path_reporte_text').value)

    if (campos_defs.value('vista') == '') {
        Transferencia["detalle"][indice]["filtroXML"] = objScript.string_to_script($('filtroXML').value)
        Transferencia["detalle"][indice]["vistaguardada"] = ''
    }
    else {
        Transferencia["detalle"][indice]["vistaguardada"] = objScript.string_to_script(campos_defs.value('vista'))
        Transferencia["detalle"][indice]["filtroXML"] = ''
    }
    //Cargar en un string el Target  
    var cadena = ""
    tabla_target.actualizarData();
    for (var index_fila = 1; index_fila < tabla_target.cantFilas; index_fila++) {
        if (!tabla_target.getFila(index_fila).eliminado)
            cadena += tabla_target.data[index_fila].uri + ';'
    }

    Transferencia["detalle"][indice]["target"] = objScript.string_to_script(cadena)
    Transferencia["detalle"][indice]["contenttype"] = objScript.string_to_script($('cb_contenttype').value)
    Transferencia["detalle"][indice]["parametros"] = isVACIO($('parametros').value, '')
    Transferencia.detalle[indice].parametros_extra.page_name = $('page_name').value
    Transferencia.detalle[indice].parametros_extra.filename = $('filename').value


    return Transferencia 

}

//function Aceptar()
//{
//  //Validar 
//  var strError = ''
  
//  if ($('filtroXML').value == '' ||  $('filtroXML').value == '<criterio><select vista=""><campos></campos><filtro></filtro></select></criterio>')
//    strError += '\nDefina Defina el "filtro XML" '
  
//  if($('filtroWhere').value != '') 
//    strError += valXML($('filtroWhere').value)
  
//  if ($('filtroXML').value != '' )
//    strError += valXML($('filtroXML').value)
    
//  if ($('path_reporte_text').value == '' && $('cb_report_name').value == "")
//    strError += '\nNo ha ingresado ningún valor para los campos "Path reporte" ni "Nombre reporte"'
   
//  if (strError != '')
//    {
//    alert(strError)
//    return null
//    }

//    //Cuando es Nuevo
//  if (indice == -1)
//    {
//     Transferencia["detalle"].length++
//     indice = Transferencia["detalle"].length -1 
//     Transferencia["detalle"][indice] = new Array();
//    }
    
//  //Cargar arreglo
//  Transferencia["detalle"][indice]["orden"] = indice
//  Transferencia["detalle"][indice]["transf_tipo"] = 'INF'   
//  Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
//  Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
//  Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value 
//  Transferencia["detalle"][indice]["filtroWhere"] = objScript.string_to_script($('filtroWhere').value)
//  Transferencia["detalle"][indice]["salida_tipo"] = objScript.string_to_script($('cb_salida_tipo').value)
   
//  if ($('cb_report_name').selectedIndex != -1)
//    Transferencia["detalle"][indice]["report_name"] = objScript.string_to_script($('cb_report_name').options[$('cb_report_name').selectedIndex].text)
//  else  
//    Transferencia["detalle"][indice]["report_name"] = '' 
    
//  Transferencia["detalle"][indice]["path_reporte"] = objScript.string_to_script($('path_reporte_text').value)
  
//  if (campos_defs.value('vista') == '')
//   {
//    Transferencia["detalle"][indice]["filtroXML"] = objScript.string_to_script($('filtroXML').value)
//    Transferencia["detalle"][indice]["vistaguardada"] = ''
//   } 
//  else  
//   {
//    Transferencia["detalle"][indice]["vistaguardada"] = objScript.string_to_script(campos_defs.value('vista'))
//    Transferencia["detalle"][indice]["filtroXML"] = ''
//   }
//  //Cargar en un string el Target  
//  var cadena = ""
//  tabla_target.actualizarData();
//  for (var index_fila = 1; index_fila < tabla_target.cantFilas ; index_fila++) {
//      if (!tabla_target.getFila(index_fila).eliminado)
//          cadena += tabla_target.data[index_fila].uri + ';'
//  }

//  Transferencia["detalle"][indice]["target"] = objScript.string_to_script(cadena)
//  Transferencia["detalle"][indice]["contenttype"] = objScript.string_to_script($('cb_contenttype').value) 
//  Transferencia["detalle"][indice]["parametros"] = isVACIO($('parametros').value, '')
//  Transferencia.detalle[indice].parametros_extra.page_name = $('page_name').value
//  Transferencia.detalle[indice].parametros_extra.filename = $('filename').value

      
// return Transferencia 
//}
 
function vista_onchange()
{ 
 var rs = new tRS();
 var filtroWhere = campos_defs.filtroWhere()
 rs.open(nvFW.pageContents.filtrowrp_config, "", "<criterio><select><campos></campos><orden></orden><grupo></grupo><filtro>" + filtroWhere + "</filtro></select></criterio>", "", "")
 if (!rs.eof() && filtroWhere != "")
       $('filtroXML').value = rs.getdata('strXML')
 else
       $('filtroXML').value = '<criterio><select vista=><campos></campos><filtro></filtro></select></criterio>'
 
 //$('filtroXML').onchange()
}


function path_reporte_file_onchange()
{
    var ruta =   $('path_reporte_file').value  //Prototype.Browser.IE ? $('path_reporte_file').value : $('path_reporte_file').files[0].mozFullPath
  var arrRuta = ruta.split("\\")
  var encontro_report = false
  var path = ''
  for(var i = 0 ; i < arrRuta.length; i++)
   {
    if(arrRuta[i] == 'report' && !encontro_report)
      encontro_report = true
    
    if(encontro_report)
     {
      if(path == '' )  
       {
        path = arrRuta[i]  
        continue
       }
      
      if(path != '' )  
       path += '\\' + arrRuta[i]  
     }  
   }
   
  if(!encontro_report) 
    path = 'report\\' + ruta.split("\\")[ruta.split("\\").length-1]
  
  if (path != '')
   {
   $('path_reporte_text').value = path
   path_reporte_text_onchange()
  } 
}

var tabla_target
function cargar_target(target)
{
target = objScript.script_to_string(target)
var arTarget = target_parse(target)
//$('target_cd').options.length = 0
//arTarget.each(function(arreglo,i)
//  {
//   $('target_cd').options.length++
//   $('target_cd').options[$('target_cd').options.length-1].text = arTarget[i]['target']
    //  });


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

function cb_report_name_onchange()
  {
  if ($('cb_report_name').selectedIndex > 0)
    {
    $('path_reporte_text').value = ''
    campos_defs.clear('flie_rpt')
    }
  }

function file_rpt_onchange()
  {
  if (campos_defs.get_desc('file_rpt') != '')
    {
    $('path_reporte_text').value = ''
    $('cb_report_name').selectedIndex = 0
    }
  }
  
function path_reporte_text_onchange()
  {
  if ($('path_reporte_text').value != '')
    {
    $('cb_report_name').selectedIndex = 0
    campos_defs.clear('flie_rpt')
    }
  }  


function cb_xsl_name_onchange()
  { 
  if ($('cb_xsl_name').selectedIndex > 0)
    $('path_xsl_text').value = ''
  }

function Cargar_ContentType(contenttype) {

    var cb = $('cb_contenttype')

    if (cb.length == 0) {

        var ContentType = new Array();
        ContentType[0] = 'text/xml'
        ContentType[1] = 'application/vnd.ms-excel'
        ContentType[2] = 'application/msword'
        ContentType[3] = 'text/html'
        ContentType[4] = 'application/pdf'

        cb.options.length++
        cb.options[cb.options.length - 1].value = ''
        cb.options[cb.options.length - 1].text = ''
        ContentType.each(function (arreglo, i) {
            cb.options.length++
            cb.options[cb.options.length - 1].value = arreglo
            cb.options[cb.options.length - 1].text = arreglo
            if (contenttype != undefined) {
                if (objScript.script_to_string(contenttype) == arreglo)
                    cb.options[cb.options.length - 1].selected = true
                if (objScript.script_to_string(contenttype) == '')
                    cb.options[0].selected = true
            }
        });

    }
    else {
        if (contenttype)
            cb.value = objScript.script_to_string(contenttype)
        if (contenttype == '' || contenttype == undefined)
            cb.options[0].selected = true
    }


    if ($('cb_salida_tipo').value == 'adjunto') {
        $('filename').disabled = false
        $('cb_contenttype').disabled = false

        //  ContentType = new Array();
        //  ContentType[0] = 'text/xml'
        //  ContentType[1] = 'application/vnd.ms-excel'
        //  ContentType[2] = 'application/msword'
        //  ContentType[3] = 'text/html'
        //  ContentType[4] = 'application/pdf'

        //ContentType.each(function(arreglo,i)
        //   {
        //   cb.options.length++
        //   cb.options[cb.options.length-1].value = arreglo 
        //   cb.options[cb.options.length-1].text = arreglo
        //   if(contenttype != undefined)
        //     {
        //       if (objScript.script_to_string(contenttype) == arreglo)
        //           cb.options[cb.options.length-1].selected = true
        //       if (objScript.script_to_string(contenttype) == '')
        //           cb.options[0].selected = true    
        //     }      
        //   });

    }
    else {
        //$('cb_contenttype').disabled = true
        //$('cb_contenttype').value = ''
        $('filename').disabled = true
        $('filename').value = ''
    }

}

 
function onchange_metodo() {
    switch ($('cb_metodo').value) {
        case "Vista":
            CargarReportes($('filtroXML').value, $('cb_report_name')[$('cb_report_name').selectedIndex].text)
            $('td_report_name').show()
            $('td_path_reporte').hide()
            $('td_file_rpt').hide()
          //  $('td_vacio').hide()
            break
        case "Path":
            $('td_report_name').hide()
            $('td_file_rpt').hide()
            $('td_path_reporte').show()
            if ($('file_rpt_desc').value != '' && $('path_reporte_text').value == $('file_rpt_desc').value)
             $('path_reporte_text').value = ''
        //    $('td_vacio').hide()
            break     
        case "Gestor":
            $('td_report_name').hide()
            $('td_path_reporte').hide()
            $('td_file_rpt').show()
        //    $('td_vacio').hide()
            break
        default:
            $('td_report_name').hide()
            $('td_path_reporte').show()
         //   $('td_vacio').show()
    }

}

function Cargar_Metodo(cb, metodo, source) {
    
    Metodo = new Array();
    Metodo[0] = ''
    Metodo[1] = 'Vista'
    Metodo[2] = 'Path'
    Metodo[3] = 'Gestor'

    Metodo.each(function (arreglo, i) {
        cb.options.length++
        cb.options[cb.options.length - 1].value = arreglo
        cb.options[cb.options.length - 1].text = arreglo

     //   if (objScript.script_to_string(metodo) == arreglo)
     //       cb.options[cb.options.length - 1].selected = true
    });

    //if (objScript.script_to_string(metodo).toLowerCase() == 'vista') {
    if (source == 'none') {
        if ($('cb_report_name').options[$('cb_report_name').selectedIndex].text != '')
            cb.options[1].selected = true
        else
            if ($('path_reporte_text').value != "")
                cb.options[2].selected = true
    } else cb.value = source

    //}

}

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
//    objScriptEditar['parametros'] = Transferencia['parametros']
    objScriptEditar.cargar_parametros(Transferencia.parametros)
    objScriptEditar['protocolo'] = protocolo
    objScriptEditar['vista'] = id

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

    $('btn_filtroXML').setStyle({ fontWeight: "bold" })
    $('btn_filtroXML').setStyle({ color: "white" })
    $('btn_filtroWhere').setStyle({ fontWeight: "normal" })
    $('btn_filtroWhere').setStyle({ color: "black" })
    $('btn_filtroXML').style.backgroundColor = "red"
    $('btn_filtroWhere').style.backgroundColor = ""

    $('btn_filtroParametros').setStyle({ fontWeight: "normal" })
    $('btn_filtroParametros').setStyle({ color: "black" })
    $('btn_filtroParametros').style.backgroundColor = ""

    setContentFiltroXML($('filtroXML').value)
}

function btn_filtroWhere_onclick() {
    $('trFiltroWhere').show()
    $('trFiltroXML').hide()
    $('trFiltroParametros').hide()

    $('btn_filtroWhere').style.fontWeight = "bold"
    $('btn_filtroWhere').style.color = "white"
    $('btn_filtroXML').style.fontWeight = "normal"
    $('btn_filtroXML').style.color = "black"
    $('btn_filtroXML').style.backgroundColor = ""
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

        $('filtroXML').setStyle({ height: calc })
        $('filtroWhere').setStyle({ height: calc })
        $('parametros').setStyle({ height: calc })

        editorFiltroXML.setSize('100%', (calc))
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
<body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
   <input type="hidden" name="indice" id="indice" value="<%=indice %>" />
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
         <div id="divfooter" style="width:100%">
          <table class='tb1' style="width:100%">
              <tr>
               <td style="width:15%;white-space:nowrap" class="Tit2">Origen de la Plantilla:&nbsp;</td>
               <td style="width:10%"><select onchange="return onchange_metodo()" id="cb_metodo" name="cb_metodo" style="width:100%"></select></td>
               <td style="display:none" id="td_report_name"><select name="cb_report_name" id="cb_report_name" style="width:100%" onchange="path_reporte_text_onchange()"></select></td>
               <td style="display:none" id="td_path_reporte"><input type="text" style="width: 65%" name="path_reporte_text" id="path_reporte_text" onchange="path_reporte_text_onchange()" /><input type="file" onchange="return path_reporte_file_onchange()" style="WIDTH: 140px;border:0px !important;text-align:center;color:white" id="path_reporte_file" name="path_reporte_file" /></td>
               <td style="display:none" id="td_file_rpt">
                 <script>
                     campos_defs.add('file_rpt',{
                         enDB: false,
                         nro_campo_tipo: 90,
                         file_dialog: {
                             seleccionar: true,
                             view: 'detalle',
                             filters: {
                                 0: {
                                     titulo: 'Plantillas',
                                     filter: '*.rpt',
                                     inicio: false
                                 }
                             }
                         },
                         onchange: file_rpt_onchange
                     })
                 </script>
               </td>
               <td  id="td_page_name" class="Tit2" style="width:25%;text-align:right">Nombre de Página:<input type="text" style="width:35%" name="page_name" id="page_name"/></td>
              </tr>            
        </table>
        <table class='tb1' style="width:100%">   
        <tr>
            <td class='Tit2' style="text-align:left">Destinos</td>
            <td class='Tit2' style="width: 10%;">Salida Tipo:</td>
            <td style="width: 10%;"><select name="cb_salida_tipo" id="cb_salida_tipo" style="width:100%" onchange='return Cargar_ContentType()'></select></td>
            <td style="width: 20%;"><select name="cb_contenttype" id="cb_contenttype" style="width:100%"></select></td>    
            <td class='Tit2' style="width: 8%;">Filename:</td>
            <td style="width: 25%;"><input type="text" style="width:100%" name="filename" id="filename"/></td>
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
