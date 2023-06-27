<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Me.contents("filtrowrp_config") = nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_config'><campos>*</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")

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
            if ($("radioDatos0").checked == false) //campos_defs.value('vista') == '' ||
             script_editar(editorFiltroXML.getTextArea().id,'filtroXML');
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
             script_editar(editorFiltroWhere.getTextArea().id,'filtroWhere');
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
             script_editar(editorFiltroParametro.getTextArea().id,'params');
        })
    }

    $('parametros').value = value
    editorFiltroParametro.setValue(value);
}

var editorFiltroXML_data
function setContentFiltroXML_data(value) {

    if (!editorFiltroXML_data) {
        editorFiltroXML_data = CodeMirror.fromTextArea($('xml_data'), {
            mode: 'application/xml',
            readOnly: true,
            lineNumbers: true,
            selectionPointer: true,
        });

        editorFiltroXML_data.on("dblclick", function (event) {
             script_editar(editorFiltroXML_data.getTextArea().id,'xml_data');
        })
    }

    $('xml_data').value = value
    editorFiltroXML_data.setValue(value);
}

function window_onload() 
{

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
   $('filtroXML').value = '<criterio><select vista=""><campos></campos><filtro></filtro></select></criterio>'
   $('filtroWhere').value = ''
   $('xml_xsl_txt').value = ''
   $('xml_data').value = ''
   //$('target').value = ''
   $('cb_salida_tipo').value = ''
   $('cb_xsl_name').options.value = ''
   $('path_xsl_text').value = 'report/EXCEL_base.xsl'
   campos_defs.set_value('file_xsl', '')
   Cargar_Salida_Tipo($('cb_salida_tipo'),"'estado'")
   Cargar_ContentType("'application/vnd.ms-excel'")
   Cargar_Metodo($('cb_metodo'),"''")
   $('mantener_origen').value = 'false'
   $('id_exp_origen').value = '0'
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
    Cargar_Salida_Tipo($('cb_salida_tipo'),Transferencia["detalle"][indice]["salida_tipo"])
    Cargar_ContentType(Transferencia["detalle"][indice]["contenttype"])
    CargarXsl($('filtroXML').value, objScript.script_to_string(Transferencia["detalle"][indice]["xsl_name"]))
    $('path_xsl_text').value = objScript.script_to_string(Transferencia["detalle"][indice]["path_xsl"])
    $('path_xsl_text').value = $('path_xsl_text').value == '' && Transferencia["detalle"][indice]["xsl_name"] == '' ? 'report/EXCEL_base.xsl' : $('path_xsl_text').value
    $('xml_xsl_txt').value = Transferencia["detalle"][indice]["xml_xsl"]
    $('xml_data').value = objScript.script_to_string(Transferencia["detalle"][indice]["xml_data"]) 
    cargar_target(Transferencia["detalle"][indice]["target"])
    Cargar_Metodo($('cb_metodo'),Transferencia["detalle"][indice]["metodo"],Transferencia.detalle[indice].parametros_extra.source_xsl)
    $('file_xsl_desc').value = Transferencia.detalle[indice].parametros_extra.source_xsl == 'Gestor' ? $('path_xsl_text').value : ''
    $('mantener_origen').value = Transferencia["detalle"][indice]["mantener_origen"]
    $('id_exp_origen').value = Transferencia["detalle"][indice]["id_exp_origen"]
    $('parametros').value = Transferencia["detalle"][indice]["parametros"]
    $('page_name').value = !Transferencia.detalle[indice].parametros_extra.page_name ? "" : Transferencia.detalle[indice].parametros_extra.page_name
    $('filename').value = !Transferencia.detalle[indice].parametros_extra.filename ? "" : Transferencia.detalle[indice].parametros_extra.filename

    onchange_metodo()
   }

setContentFiltroXML($('filtroXML').value)
setContentFiltroWhere($('filtroWhere').value)
setContentFiltroParametro($('parametros').value)
setContentFiltroXML_data($('xml_data').value)
onchange_radio(null)



window_onresize()

}


function validar() {
    
    //Validar 
    var strError = ''
    if (($('filtroXML').value == '' || $('filtroXML').value == '<criterio><select vista=""><campos></campos><filtro></filtro></select></criterio>') && $("radioDatos2").checked == false)
        strError += 'Defina el "filtro XML" </br>'

    //if ($('filtroWhere').value != '' && $("radioDatos2").checked == false)
    //    strError += 'El "filtro Where" está mal formado </br>' + valXML($('filtroWhere').value)

    //if ($('parametros').value != '' && $("radioDatos2").checked == false)
    //    strError += 'El "parámetro" está mal formado </br>'+ valXML($('parametros').value)

    //if ($('filtroXML').value != '' && $("radioDatos2").checked == false)
    //    strError += 'El "filtro XML" está mal formado </br>'+ valXML($('filtroXML').value)

    //if ($('xml_xsl_txt').value != '')
    //    strError += valXML($('xml_xsl_txt').value)

    //if ($('xml_data').value != '' && $("radioDatos2").checked == true)
    //    strError += 'El "XML DATA" está mal formado </br>'+ valXML($('xml_data').value)

    if ($('cb_xsl_name').value == 0 && $('cb_metodo').value == "TransformFromXSL (Name)")
        strError += 'Debe ingresar el nombre de la plantilla.</br>'

    if ($('path_xsl_text').value == '' && $('cb_metodo').value == "TransformFromXSL (Path)")
        strError += 'Debe ingresar el path donde se encuentra la plantilla.</br>'
    
    if (campos_defs.get_desc('file_xsl') == '' && $('cb_metodo').value == "TransformFromXSL (Gestor)")
        strError += 'Debe ingresar el path donde se encuentra la plantilla.</br>'

    if ($('xml_xsl_txt').value == '' && $('cb_metodo').value == "TransformFromXSL (XML)")
        strError += 'Debe ingresar la codificacion.</br>'

    //if ($('xml_xsl').value == '' && $('path_xsl_text').value == '' && $('cb_xsl_name').value == 0)
    //  strError += 'Debe ingresar la propiadad correspondiente al metodo.</br>'

    if ($('cb_metodo').value == '')
        strError += 'Debe seleccionar un metodo.</br>'

    return strError
}

function guardar() {

    var indice = $('indice').value

    var metodo = "TransformFromXSL"
    switch ($('cb_metodo').value) {
        case "TransformFromXSL (Name)":
            $('xml_xsl_txt').value = ""
            $('path_xsl_text').value = ""
            Transferencia.detalle[indice].parametros_extra.source_xsl = "Name"
            break
        case "TransformFromXSL (Path)":
            $('cb_xsl_name').value = 0
            $('xml_xsl_txt').value = ""
            Transferencia.detalle[indice].parametros_extra.source_xsl = "Path"
            break
        case "TransformFromXSL (XML)":
            $('path_xsl_text').value = ""
            $('cb_xsl_name').value = 0
            Transferencia.detalle[indice].parametros_extra.source_xsl = "XML"
            break
        case "TransformFromXSL (Gestor)":
            $('cb_xsl_name').value = 0
            $('xml_xsl_txt').value = ""
            $('path_xsl_text').value = campos_defs.get_desc('file_xsl')
            Transferencia.detalle[indice].parametros_extra.source_xsl = "Gestor"
            break
        default:
            $('path_xsl_text').value = ""
            $('cb_xsl_name').value = 0
            $('xml_xsl_txt').value = ""
            metodo = $('cb_metodo').value
            Transferencia.detalle[indice].parametros_extra.source_xsl = 'none'
    }

    //Cuando es Nuevo
    if (indice == -1) {
        Transferencia["detalle"].length++
        indice = Transferencia["detalle"].length - 1
        Transferencia["detalle"][indice] = new Array();
    }


    if ($("radioDatos2").checked == true) { // xml_data
        $('filtroXML').value = ""
        $('filtroWhere').value = ""
        $('parametros').value = ""
    }
    else
       $('xml_data').value = ""

    //cargar arreglo
    Transferencia["detalle"][indice]["orden"] = indice
    Transferencia["detalle"][indice]["transf_tipo"] = 'EXP'
    Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
    Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
    Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
    Transferencia["detalle"][indice]["filtroWhere"] = objScript.string_to_script($('filtroWhere').value)
    Transferencia["detalle"][indice]["xml_data"] = objScript.string_to_script($('xml_data').value)
    Transferencia["detalle"][indice]["salida_tipo"] = objScript.string_to_script($('cb_salida_tipo').value)
    Transferencia["detalle"][indice]["contenttype"] = objScript.string_to_script($('cb_contenttype').value)

    if ($('cb_xsl_name').selectedIndex != -1)
        Transferencia["detalle"][indice]["xsl_name"] = objScript.string_to_script($('cb_xsl_name').options[$('cb_xsl_name').selectedIndex].text)
    else
        Transferencia["detalle"][indice]["xsl_name"] = ''
    Transferencia["detalle"][indice]["path_xsl"] = objScript.string_to_script($('path_xsl_text').value)
    Transferencia["detalle"][indice]["xml_xsl"] = $('xml_xsl_txt').value

    if (campos_defs.value('vista') == '') {
        Transferencia["detalle"][indice]["filtroXML"] = objScript.string_to_script($('filtroXML').value)
        Transferencia["detalle"][indice]["vistaguardada"] = ''
    }
    else {
        Transferencia["detalle"][indice]["vistaguardada"] = objScript.string_to_script(campos_defs.value('vista'))
        Transferencia["detalle"][indice]["filtroXML"] = ''
    }

    var cadena = ""
    tabla_target.actualizarData();
    for (var index_fila = 1; index_fila < tabla_target.cantFilas; index_fila++) {
        if (!tabla_target.getFila(index_fila).eliminado)
            cadena += tabla_target.data[index_fila].uri + ';'
    }

    Transferencia["detalle"][indice]["target"] = objScript.string_to_script(cadena)
    Transferencia["detalle"][indice]["metodo"] = objScript.string_to_script(metodo)
    Transferencia["detalle"][indice]["mantener_origen"] = isVACIO($('mantener_origen').value, 'false')
    Transferencia["detalle"][indice]["id_exp_origen"] = isVACIO($('id_exp_origen').value, '0')
    Transferencia["detalle"][indice]["parametros"] = isVACIO($('parametros').value, '')
    Transferencia["detalle"][indice]["xls_save_as"] = 0//isVACIO($('xls_save_as').value, '') 

    Transferencia.detalle[indice].parametros_extra.page_name = $('page_name').value
    Transferencia.detalle[indice].parametros_extra.filename = $('filename').value

    return Transferencia 
}

function return_trasferencia_parametro()
{
    return Transferencia
}

function isVACIO(valor, sinulo)
{
  valor = valor == '' ? sinulo: valor
  return valor
}

function vista_onchange()
{ 
 var rs = new tRS();
 var filtroWhere = campos_defs.filtroWhere()
 rs.open(nvFW.pageContents.filtrowrp_config,"","<criterio><select><campos></campos><orden></orden><grupo></grupo><filtro>" + filtroWhere + "</filtro></select></criterio>","","")
 if (!rs.eof()&& filtroWhere!= "")
    { 
      $('filtroXML').value = rs.getdata('strXML')      
    } 
 //else
 //   { 
 //     $('filtroXML').value = '<criterio><select vista=""><campos></campos><filtro></filtro></select></criterio>'
 //   }

  btn_filtroXML_onclick()
}

function CargarXsl(criterio,nombre_xsl) { 
    
 var cb =  $('cb_xsl_name')
 cb.options.length = 0
 objScript.set_string(criterio)
 var xsl = objScript.get_xsl()
 cb.options.length++
 cb.options[cb.options.length-1].value = 0
 cb.options[cb.options.length-1].text = ''
 
 for(var i=1; i< xsl.length; i++)
  {
   cb.options.length++
   cb.options[cb.options.length-1].value = xsl[i]['path']
   cb.options[cb.options.length-1].text = xsl[i]['name']
   if (nombre_xsl.toLowerCase().indexOf(xsl[i]['name'].toLowerCase()) >= 0)
     cb.selectedIndex = i
    }

    if (xsl.length == 0 && nombre_xsl != "") {
        cb.options.length++
        cb.options[cb.options.length - 1].value = nombre_xsl
        cb.options[cb.options.length - 1].text = nombre_xsl
        cb.selectedIndex = i
        Transferencia["detalle"][indice]["metodo"] = "'TransformFromXSL'"
    }
} 

function filtroXML_on_change() {
 
   CargarXsl($('filtroXML').value,$('cb_xsl_name').value)
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
 
 function Cargar_ContentType(contenttype)
{
     
     var cb = $('cb_contenttype')

     if (cb.length == 0)
     {
         var ContentType = new Array();
         ContentType[0] = 'text/xml'
         ContentType[1] = 'application/vnd.ms-excel'
         ContentType[2] = 'application/msword'
         ContentType[3] = 'text/html'
     //    ContentType[4] = 'application/pdf'
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


  if ($('cb_salida_tipo').value == 'adjunto')
    {     
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
  else
   {
    //$('cb_contenttype').disabled = true
    //$('cb_contenttype').value = ''
    $('filename').disabled = true
    $('filename').value = ''
   }
    
 }


function onchange_metodo() 
 {
    switch ($('cb_metodo').value) 
     {
       case "TransformFromXSL (Name)":
             $('td_xsl_name').show()
             $('td_path_xsl').hide()
             $('td_xml_xsl').hide()
             $('td_vacio').hide()
             $('td_file_xsl').hide()
       break
       case "TransformFromXSL (Path)":
           $('td_xsl_name').hide()
           $('td_path_xsl').show()
           $('td_xml_xsl').hide()
           $('td_vacio').hide()
           $('td_file_xsl').hide()
           if ($('file_xsl_desc').value != '' && $('path_xsl_text').value == $('file_xsl_desc').value)
             $('path_xsl_text').value = ''
       break
       case "TransformFromXSL (XML)":
           $('td_xml_xsl').show()
           $('td_xsl_name').hide()
           $('td_path_xsl').hide()
           $('td_vacio').hide()
           $('td_file_xsl').hide()
       break
       case "TransformFromXSL (Gestor)":
           $('td_xml_xsl').hide()
           $('td_xsl_name').hide()
           $('td_path_xsl').hide()
           $('td_vacio').hide()
           $('td_file_xsl').show()
       break
       default:
           $('td_xsl_name').hide()
           $('td_path_xsl').hide()
           $('td_xml_xsl').hide()
           $('td_file_xsl').hide()
           $('td_vacio').show()
    }

 }

function Cargar_Metodo(cb,metodo,source)
 { 
       Metodo = new Array();
       Metodo[0] = ''
       Metodo[1] = 'RSXMLtoExcel'
       Metodo[2] = 'XMLNone'
       Metodo[3] = 'RSXMLtoXmlJson'
       Metodo[4] = 'TransformFromXSL (Name)'
       Metodo[5] = 'TransformFromXSL (Path)'
       Metodo[6] = 'TransformFromXSL (XML)'
       Metodo[7] = 'TransformFromXSL (Gestor)'
       
     Metodo.each(function(arreglo,i)
      {
        cb.options.length++
        cb.options[cb.options.length-1].value = arreglo 
        cb.options[cb.options.length-1].text = arreglo
      
        if (objScript.script_to_string(metodo) == arreglo)
            cb.options[cb.options.length - 1].selected = true
      });
      
    if (objScript.script_to_string(metodo) == 'TransformFromXSL')
     {
        if (source == 'none')
         {
          if ($('cb_xsl_name').options[$('cb_xsl_name').selectedIndex].text != '')
            cb.options[4].selected = true
          else
            if ($('path_xsl_text').value != "")
              cb.options[5].selected = true
         }
        else cb.value = "TransformFromXSL (" + source + ")"
          
       
     }
    
 }

function path_xsl_file_onchange()
 {
  var ruta = $('path_xsl_file').value // Prototype.Browser.IE ? $('path_xsl_file').value : $('path_xsl_file').files[0].mozFullPath
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
    $('path_xsl_text').value = path
    path_xsl_text_onchange()
   } 
 } 

function path_xsl_text_onchange()
  { 
  if ($('path_xsl_text').value != '')
    {
    $('cb_xsl_name').selectedIndex = 0
    campos_defs.clear('file_xsl')
    }
  }   

function file_xsl_onchange()
  { 
  if (campos_defs.get_desc('file_xsl') != '')
    {
    $('path_xsl_text').value = ''
    $('cb_xsl_name').selectedIndex = 0
    }
  }   

var tabla_target
function cargar_target(target) {
    
 target = objScript.script_to_string(target)
 //target = "FILE://directorio_archivos/prueba.xls||<opcional xls_save_as='' comp_metodo='rar' comp_algoritmo='wwws' comp_pwd='sss' ></opcional>||;FILE://directorio_archivos/mario.xls||<opcional xls_save_as='' comp_metodo='rar' comp_algoritmo='wwws' comp_pwd='sss' ></opcional>||"
 var arTarget = target_parse(target)

//$('target_cd').options.length = 0
//arTarget.each(function(arreglo,i)
// {
//  $('target_cd').options.length++
//  $('target_cd').options[$('target_cd').options.length-1].text = arreglo['target']
// });

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
  strError = 'ErrorCode: ' + objXML.parseError.errorCode + '<br>Reason: ' + objXML.parseError.reason
  strError += 'strText: ' + objXML.parseError.strText 
  }  
return strError
    }

function getStringFromBase64(valor) 
 {
    var res = ''
    if (valor == '' || valor == '0x')
     return res

    var oXML = new tXML()
    oXML.method = "POST"
    var URL = 'transferencia_abm.aspx?modo=SET_BASE64_STRING&valor=' + escape(valor)
    oXML.load(URL)

    try {
          
          var err = new tError()
          err.error_from_xml(oXML)

          if (err.numError == 0)
            res = err.params["XMLXSL"]
        }
    catch (e) { }

    return res
 }                        

function cb_xsl_name_onchange()
  { 
  if ($('cb_xsl_name').selectedIndex > 0)
    {
    $('path_xsl_text').value = ''
    campos_defs.clear('file_xsl')
    }
    
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
   case 'xml_data':
     txt = $(id)
     protocolo = 'XSL'
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

  var objScriptEditar = new tScript()
  objScriptEditar['script_txt'] = script_txt
  //objScriptEditar['parametros'] = Transferencia['parametros']
  objScriptEditar.cargar_parametros(Transferencia.parametros)
  objScriptEditar['protocolo'] = protocolo
  objScriptEditar['vista'] = id

  var path = "/fw/transferencia/editor_script.aspx"
  
  var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
  win = w.createWindow({className: 'alphacube', 
                        url: path, 
                        title: '<b>Editar</b>', 
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

          if (win.options.id == "xml_data")
             setContentFiltroXML_data($('xml_data').value)
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
       if (img_editar[i].title.toLowerCase().indexOf('editar') > -1)
            img_editar[i].onclick = editar_target
    }

    }

function removeStyle(id) {
     $(id).setStyle({backgroundColor : "", fontWeight: "",fontColor: "", cursor:"" })
}


function btn_filtroParametros_onclick() {

    $('trFiltroParametros').show()
    $('trFiltroXML').hide()
    $('trFiltroWhere').hide()
    $('trFiltroXML_data').hide()


    removeStyle('btn_filtroXML')
    removeStyle('btn_filtroWhere')
    removeStyle('btn_filtroXML_data')
    removeStyle('btn_filtroParametros')

    $('btn_filtroXML').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroWhere').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroXML_data').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroParametros').setStyle({backgroundColor : "red", fontWeight: "bold",fontColor: "white", cursor:"pointer" })

    setContentFiltroParametro($('parametros').value)

    }

function btn_filtroXML_data_onclick() {

    $('trFiltroXML_data').show()
    $('trFiltroParametros').hide()
    $('trFiltroXML').hide()
    $('trFiltroWhere').hide()

    removeStyle('btn_filtroXML')
    removeStyle('btn_filtroWhere')
    removeStyle('btn_filtroXML_data')
    removeStyle('btn_filtroParametros')

    $('btn_filtroXML').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroWhere').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroParametros').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroXML_data').setStyle({backgroundColor : "red", fontWeight: "bold",fontColor: "white", cursor:"pointer" })
    
    setContentFiltroXML_data($('xml_data').value)
}

function btn_filtroXML_onclick() {

  $('trFiltroXML').show()
  $('trFiltroWhere').hide()
  $('trFiltroParametros').hide()
  $('trFiltroXML_data').hide()

  removeStyle('btn_filtroXML')
  removeStyle('btn_filtroWhere')
  removeStyle('btn_filtroXML_data')
  removeStyle('btn_filtroParametros')

  $('btn_filtroParametros').setStyle({ backgroundColor : "",fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
  $('btn_filtroXML_data').setStyle({ backgroundColor: "", fontWeight: "normal", fontColor: "gred", cursor: "pointer" })
  $('btn_filtroWhere').setStyle({ backgroundColor: "", fontWeight: "normal", fontColor: "gred", cursor: "pointer" })
  $('btn_filtroXML').setStyle({backgroundColor : "red", fontWeight: "bold", fontColor: "white", cursor:"pointer" })

  setContentFiltroXML($('filtroXML').value)

}

function btn_filtroWhere_onclick() {    

    $('trFiltroWhere').show()
    $('trFiltroXML').hide()
    $('trFiltroParametros').hide()
    $('trFiltroXML_data').hide()

    removeStyle('btn_filtroXML')
    removeStyle('btn_filtroWhere')
    removeStyle('btn_filtroXML_data')
    removeStyle('btn_filtroParametros')

    $('btn_filtroParametros').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroXML_data').setStyle({backgroundColor : "", fontWeight: "normal",fontColor: "gred", cursor:"pointer" })
    $('btn_filtroXML').setStyle({ backgroundColor: "", fontWeight: "normal", fontColor: "gred", cursor: "pointer" })
    $('btn_filtroWhere').setStyle({backgroundColor : "red", fontWeight: "bold", fontColor: "white", cursor:"pointer" })

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
        $('xml_data').setStyle({ height: calc })

        editorFiltroXML.setSize('100%', (calc) )
        editorFiltroWhere.setSize('100%', (calc))
        editorFiltroParametro.setSize('100%', (calc))
        editorFiltroXML_data.setSize('100%', (calc))

        if (tabla_target) {
            tabla_target.resize();
        }

    }
    catch (e) { //window.status = e.description; alert('calc: ' + calc) 
    }

    
}

    function onchange_radio(e) {

        var valor = "1"
        if (!e) {

            if (campos_defs.value("vista") != "")
                valor="0"
            if (campos_defs.value("vista") == "" && $('filtroXML').value != "")
                valor="1"
            if ($('xml_data').value != "")
                valor = "2"

            $("radioDatos" + valor).value = valor
            $("radioDatos" + valor).checked = true
        }
        else
          valor = $(Event.element(e).id).value

        switch (valor)
         {
            case "0":
                campos_defs.habilitar("vista",true)
                $('btn_filtroXML').disabled = false
                $('btn_filtroWhere').disabled = false
                $('btn_filtroParametros').disabled = false
               // $('xml_data').value = ""
                $('btn_filtroXML_data').disabled = true
                btn_filtroXML_onclick()
                break;
            case "1":
                campos_defs.clear("vista")
                campos_defs.habilitar("vista", false)
                $('btn_filtroXML').disabled = false
                $('btn_filtroWhere').disabled = false
                $('btn_filtroParametros').disabled = false
                $('btn_filtroXML_data').disabled = true
              //  $('xml_data').value = ""
                btn_filtroXML_onclick()
                break;
            case "2":
                campos_defs.clear("vista")
                campos_defs.habilitar("vista", false)
                $('btn_filtroXML').disabled = true
                $('btn_filtroWhere').disabled = true
                $('btn_filtroParametros').disabled = true
                //$('filtroXML').value = ""
                //$('filtroWhere').value = ""
                //$('parametros').value = ""
                $('btn_filtroXML_data').disabled = false
                btn_filtroXML_data_onclick()
                break;
        }

    }

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style="width:100%;height:100%;overflow:hidden">
<input type="hidden" name="indice" id="indice" value="<%=indice%>" />
<input type="hidden" name="mantener_origen" id="mantener_origen" value=""/>
<input type="hidden" name="id_exp_origen" id="id_exp_origen" value="" />

    <div id="divhead" style="width:100%">
    <table class='tb1'>   
        <tr>
          <td class='Tit2' style='width:10%'><b>Origen de datos:</b></td>
          <td class='Tit4' colspan="6"><input type="radio" style="cursor:pointer;" name="radioDatos" id="radioDatos0" value="0" onclick="return onchange_radio(event)"/><b>Vista Guardada</b>
                          <input type="radio"  style="cursor:pointer;" name="radioDatos" id="radioDatos1" value="1" onclick="return onchange_radio(event)"/><b>FiltroXML</b>
                          <input type="radio"  style="cursor:pointer;" name="radioDatos" id="radioDatos2" value="2" onclick="return onchange_radio(event)"/><b>Datos XML</b>
          </td>
        </tr>
        <tr>
          <td class="Tit1" style='width:10%' nowrap="true">Vista guardada:</td>
          <td><%= nvCampo_def.get_html_input("vista") %></td>
          <td class="Tit1"  style='width:5%'>Opciones:</td>
          <td style="width: 10%; vertical-align: 100%"><input type="button" name="btn_filtroXML" id="btn_filtroXML" style="WIDTH: 100%" value="XML" onclick ="btn_filtroXML_onclick()"/></td>
          <td style="width: 10%; vertical-align: 100%"><input type="button" name="btn_filtroWhere" id="btn_filtroWhere" style="WIDTH: 100%" value="Where" onclick ="btn_filtroWhere_onclick()"/></td>
          <td style="width: 10%; vertical-align: 100%"><input type="button" name="btn_filtroParametros" id="btn_filtroParametros" style="WIDTH: 100%" value="Parámetro" onclick ="btn_filtroParametros_onclick()"/></td>
          <td style="width: 10%; vertical-align: 100%"><input type="button" name="btn_filtroXML_data" id="btn_filtroXML_data" style="WIDTH: 100%" value="Datos" onclick ="btn_filtroXML_data_onclick()"/></td>
        </tr>
    </table>  
     </div>
    <table class='tb1' id='tbfiltro'>   
         <tr>
            <td  class='Tit1' style="text-align:center" colspan='5'><b>Datos (Formato:XML)</b></td>
        </tr>
        <tr id='trFiltroXML'>
           <td colspan='5'>
           <textarea rows='8' cols='1' name='filtroXML' id='filtroXML'></textarea>
           </td>
        </tr>
        <tr id='trFiltroWhere'>
           <td colspan='5'>
           <textarea rows='8' cols='1' name='filtroWhere' id='filtroWhere'></textarea></td>
        </tr>
         <tr id='trFiltroParametros'>
           <td colspan='5'>
           <textarea rows='8' cols='1' name='parametros' id='parametros'"></textarea></td>
        </tr>
         <tr id='trFiltroXML_data'>
           <td colspan='5'>
           <textarea rows='8' cols='1' name='xml_data' id='xml_data'"></textarea></td>
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
           <td style="display:none" id="td_path_xsl"><input type="text" style="width: 60%" name="path_xsl_text" id="path_xsl_text" onchange="path_xsl_text_onchange()" /><input type="file" onchange="return path_xsl_file_onchange()" style="WIDTH: 140px;border:0px;vertical-align:top" id="path_xsl_file" name="path_xsl_file"/></td>
           <td style="display:none" id="td_file_xsl">
               <script>
                   campos_defs.add('file_xsl',{
                       enDB: false,
                       nro_campo_tipo: 90,
                       file_dialog: {
                           seleccionar: true,
                           view: 'detalle',
                           filters: {
                               0: {
                                   titulo: 'Plantillas',
                                   filter: '*.xsl',
                                   inicio: false
                                   }
                               }
                           },
                       onchange: file_xsl_onchange
                       })
               </script>
           </td>
           <td id="td_page_name" class="Tit2" style="width:25%;text-align:center">Nombre de Hoja:<input type="text" style="width:45%" name="page_name" id="page_name"/></td>
       </tr>
    </table>       
    <table class='tb1'>   
       <tr>
            <td class='Tit2' style="text-align:left">Destinos</td>
            <td class='Tit2' style="width: 10%;">Salida Tipo:</td>
            <td style="width: 10%;"><select name="cb_salida_tipo" id="cb_salida_tipo" style="width:100%" onchange='return Cargar_ContentType()'></select></td>
            <td style="width: 20%;"><select name="cb_contenttype" id="cb_contenttype" style="width:100%" ></select></td>    
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