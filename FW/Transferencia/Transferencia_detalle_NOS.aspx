<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Me.contents("filtroTransferencia_parametros_NOSIS_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_parametros_NOS_def_new'><campos>*</campos><filtro></filtro><orden>nosis_orden</orden></select></criterio>")
    Me.contents("filtroTransferencia_parametros_NOSIS") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_parametros_NOS'><campos>*</campos><filtro></filtro><orden>parametro</orden></select></criterio>")


%>
<html>
<head>
<title>Transferencia Detalle Nosis</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
    <script type="text/javascript" src="/FW/script/tTable.js"></script>    
    <script type="text/javascript" src="/FW/script/tcampo_head.js"></script>     
    <script type="text/javascript" src="/FW/transferencia/script/transf_destino_utiles.js"></script>
    
<%
    Dim indice = nvUtiles.obtenerValor("indice", "")
%>

<% = Me.getHeadInit()%>
<script  type="text/javascript">

var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:120, okLabel: "cerrar"}); }

var indice
var Transferencia
var objScript = new tScript();

function window_onload() 
{
  indice = $('indice').value
  Transferencia = parent.return_Transferencia()

  //ubicar los valores de entrada sobre el xmlparametros
  
  $('divCUIL').insert({ "top": parametro_cargar("CUIL", false, Transferencia.detalle[indice].parametros_extra.cuil) })
  $('divCDA').insert({ "top": parametro_cargar("CDA", false, Transferencia.detalle[indice].parametros_extra.cda) })
  $('divVendedor').insert({ "top": parametro_cargar("vendedor", false, Transferencia.detalle[indice].parametros_extra.vendedor) })
  $('actualizar_fuentes').checked = Transferencia.detalle[indice].parametros_extra.actualizar_fuentes == 'true'
  $('tipo_informe').value = !Transferencia.detalle[indice].parametros_extra.tipo_informe ? 'sac_informe' : Transferencia.detalle[indice].parametros_extra.tipo_informe
  $('forzar_consulta').checked = Transferencia.detalle[indice].parametros_extra.forzar_consulta == 'true'
  $('divrazonsocial').insert({ "top": parametro_cargar("razonsocial", false, Transferencia.detalle[indice].parametros_extra.razonsocial) })
  $('divsexo').insert({ "top": parametro_cargar("sexo", false, Transferencia.detalle[indice].parametros_extra.sexo) })
    
  // setear valoeres de entrada
  
  //cargar parametros fijos
  NosisCargar()
  //dibujar  
  NosisDibujar()
  // setear los parametros de los valoeres fijos

  window_onresize()
   
}

function NOSIS_existe_en_parametro_det(nosis_def) {

    for (var i = 0; i <  Transferencia["detalle"][indice]["parametros_det"].length; i++) {
        det = Transferencia["detalle"][indice]["parametros_det"][i]
        if (det.nosis_def == nosis_def)
            return det.parametro
    }

    return ""
}

function NOSIS_existe_def(nosis_def) {

    for (var i = 0; i <  parametros_det.length; i++) {
        det = parametros_det[i]
        if (det.nosis_def == nosis_def)
            return i
    }

    return -1
    }

function NOSIS_existe_parametro(parametro) {

    for (var i = 0; i < Transferencia["parametros"].length; i++) {
        det = Transferencia["parametros"][i]
        if (det.parametro == parametro)
            return i
    }

    return -1
    }

var parametros_det = []
function NosisCargar(cambio_tipo_informe) {
    
    parametros_det.length = 0

    var rs = new tRS();
    rs.open(nvFW.pageContents.filtroTransferencia_parametros_NOSIS_def, "", "<nosis_tipo_informe type='igual'>'"+ $("tipo_informe").value +"'</nosis_tipo_informe>", "")
    while (!rs.eof()) {

        var i = parametros_det.length

        parametros_det[i] = []
        parametros_det[i].disabled = true 
        parametros_det[i].parametro = NOSIS_existe_en_parametro_det(rs.getdata("nosis_def"))
        parametros_det[i].estado = 'N' 
        parametros_det[i].nosis_def = rs.getdata("nosis_def")
        parametros_det[i].nosis_descripcion = rs.getdata("nosis_descripcion")
        parametros_det[i].nosis_xpath = rs.getdata("nosis_xpath")          
  
        rs.movenext()

    }

    if (cambio_tipo_informe)
        return

    for (var i = 0; i < Transferencia["detalle"][indice]["parametros_det"].length; i++) {

        var pos_def = NOSIS_existe_def(Transferencia["detalle"][indice]["parametros_det"][i].nosis_def)
        if (pos_def == -1) {
            pos_def = parametros_det.length
            parametros_det[pos_def] = []
            parametros_det[pos_def].disabled = false
            parametros_det[pos_def].parametro = Transferencia["detalle"][indice]["parametros_det"][i].parametro
            parametros_det[pos_def].nosis_def = Transferencia["detalle"][indice]["parametros_det"][i].nosis_def
            parametros_det[pos_def].nosis_descripcion = Transferencia["detalle"][indice]["parametros_det"][i].nosis_descripcion
            parametros_det[pos_def].nosis_xpath = Transferencia["detalle"][indice]["parametros_det"][i].nosis_xpath
        }

    }
   
    var msj_def = ""
    var msj_param = ""
    var strXML = !Transferencia.detalle[indice].parametros_extra.asignacion ? "" : Transferencia.detalle[indice].parametros_extra.asignacion;
    var objXML = new tXML();
    if (objXML.loadXML('<?xml version="1.0" encoding="iso-8859-1"?><parametros>' + strXML + "</parametros>" ))
    {
        var parametros = selectNodes('/parametros/parametro', objXML.xml)
        for (var i = 0; i < parametros.length; i++) {

                var param = !selectSingleNode('@param', parametros[i]) ? "" : selectSingleNode('@param', parametros[i]).value
                var nosis_def = !selectSingleNode('@nosis_def', parametros[i]) ? "" : selectSingleNode('@nosis_def', parametros[i]).value
                var nosis_descripcion = !selectSingleNode('@nosis_descripcion', parametros[i]) ? "" : selectSingleNode('@nosis_descripcion', parametros[i]).value
                var nosis_xpath = !selectSingleNode('@nosis_xpath', parametros[i]) ? "" : selectSingleNode('@nosis_xpath', parametros[i]).value
                var editable = !selectSingleNode('@editable', parametros[i]) ? false : (selectSingleNode('@editable', parametros[i]).value == 'true' ? true : false)

                var pos_def = NOSIS_existe_def(nosis_def)

                if (editable && pos_def == -1) {
                    pos_def = parametros_det.length
                    parametros_det[pos_def] = []
                    parametros_det[pos_def].disabled = false
                    parametros_det[pos_def].parametro = param
                    parametros_det[pos_def].nosis_def = nosis_def
                    parametros_det[pos_def].nosis_descripcion = nosis_descripcion
                    parametros_det[pos_def].nosis_xpath = nosis_xpath
                }
              
                var pos_param = NOSIS_existe_parametro(param)              

                if (pos_def > -1) {

                    if (pos_param == -1) {

                        if (msj_param == "")
                          msj_param = param
                       else
                          msj_param += ", " + param

                       param = ""
                    }

                    parametros_det[pos_def].parametro = param
                    parametros_det[pos_def].nosis_def = nosis_def
                    parametros_det[pos_def].nosis_descripcion = nosis_descripcion
                    parametros_det[pos_def].nosis_xpath = nosis_xpath
                    parametros_det[pos_def].estado = 'E'

                }
                else {
                    if (msj_def == "")
                        msj_def = nosis_def
                    else
                        msj_def += ", " + nosis_def
                }
         }
    }

    if (msj_def == "" && msj_param == "")
        NosisDibujar()
    else {

        var elementos
        if (msj_def != "") {

            elementos = msj_def.split(",")

            if (elementos.length > 0)
                msj_def = "Las definciones: <b>" + msj_def + "</b>, ya no existen.<br>"
            else
                msj_def = "La definición: <b>" + msj_def + "</b>, ya no existe.<br>"
        }

        if (msj_param != "") {

            elementos = msj_param.split(",")

            if (elementos.length > 0)
                msj_param = "Los parámetros relacionados: <b>" + msj_param + "</b>, ya no existen.<br>"
            else
                msj_param = "El parámetro relacionado: <b>" + msj_param + "</b>, ya no existe.<br>"
        }
        
         Dialog.confirm(msj_def + "<br>¿Desea continuar?" , {
                                      width: 400,
                                      className: "alphacube",
                                      okLabel: "Si",
                                      cancelLabel: "No",
                                      zIndex: 10,
                                      onOk: function(win_local) {
                                                                 NosisDibujar()
                                                                 win_local.close(); return
                                      },
                                      onCancel: function (win_local) { win_local.close(); parent.win.close();return }
                       });
        }

}

function NosisDibujar() {
    
    $('divNOSIS').innerHTML =""
    
    var strHTML = "<table class='tb1' id='tbNosis'>"
    for (var i = 0; i < parametros_det.length; i++) {

        if (parametros_det[i].estado == 'B')
            continue;

        var arNosis = parametros_det[i]
        
        var disabled = ""
        if (arNosis.disabled == true)
            disabled = " disabled = 'disabled' "

        strHTML += "<tr title='"+ arNosis.nosis_descripcion +"'>"
        strHTML += "<td style='text-align:left; vertical-align:middle'><input type='text' style='width:100% !Important' " + disabled + " name='xpath_" + i + "' id='xpath_" + i + "' value='" + arNosis.nosis_xpath + "' title='" + arNosis.nosis_xpath + "'/></td>"
        strHTML += "<td style='width:22% !Important;text-align:left; vertical-align:middle'><input type='text' style='width:100% !Important' " + disabled + " name='nosis_descripcion_" + i + "' id='nosis_descripcion_" + i + "' value='"+ arNosis.nosis_descripcion  + "'/></td>"
        strHTML += "<td style='width:22% !Important;text-align:left; vertical-align:middle'><input type='text' style='width:100% !Important' " + disabled + " name='nosis_def_" + i + "' id='nosis_def_" + i + "' value='" + arNosis.nosis_def + "'/></td>"
        strHTML += "<td style='width:20% !Important;text-align:center; vertical-align:middle'>" + parametro_cargar("parametro_" + i, false, arNosis.parametro) + "</td>"
        strHTML += "<td style='width:2% !Important;text-align:left; vertical-align:middle'>"
        if(arNosis.disabled == false)
            strHTML += "<img type='text' style='cursor:hand' src='\\fw\\image\\icons\\eliminar.png' onclick='return EliminarRegistro(" + i + ")' title='Eliminar'/>"
        strHTML += "</td>"
        strHTML += "<td style='width:14px !Important' id='tdScroll" + i + "'></td>"
        strHTML += "</tr>"
    }

    strHTML += "</table>"

    $('divNOSIS').insert({ top: strHTML })
}


function EliminarRegistro(j) {
    
    parametros_det[j].estado = 'B'
    parametros_det.splice(j, 1)
    NosisDibujar()

}

function parametro_xls_nuevo()
{
  transferencia_actualizar() 
  
  var i = parametros_det.length
  parametros_det[i] = [];
  parametros_det[i].nosis_def = ""
  parametros_det[i].nosis_descripcion = ""
  parametros_det[i].nosis_xpath = ""
  parametros_det[i].parametro = ""
  parametros_det[i].disabled = false 
  parametros_det[i].estado = 'N'

    NosisDibujar()

    try {
        $('divNOSIS').scrollTop = $('divNOSIS').querySelectorAll('table')[0].getHeight()
    }
    catch (e) {

    }
}

function parametro_cargar(campo, disabled, valor)
{
     if (disabled == true)
         disabled = " disabled = 'disabled' "

     var Str_Param = "<select style='width:100%' name='" + campo + "' " + disabled + " id='" + campo + "' onchange='transferencia_actualizar()'>"
         Str_Param += "<option value=''></option>"

    Transferencia["parametros"].each(function (arreglo, j)
          { 
           var seleccionado = ''
           seleccionado = arreglo['parametro'] == valor ? 'selected' : ''
           Str_Param += "<option value='" +  arreglo['parametro'] + "' " + seleccionado + ">" + arreglo['parametro'] + "</option>"
        });

      Str_Param += "</select>"     
      
    return Str_Param   
}


function transferencia_actualizar()
{
    //Actualiza Parametros
    parametros_det.each(function (arreglo, j) {
    
        if (arreglo.estado != 'B') {
            arreglo["nosis_def"] = $("nosis_def_" + j).value
            arreglo["parametro"] = $('parametro_' + j).value
            arreglo["nosis_xpath"] = $('xpath_' + j).value
            arreglo["nosis_descripcion"] = $('nosis_descripcion_' + j).value
        }

    });
 }  



function validar() {

    var strError = ''

    if ($('CUIL').value == '')
        strError += 'Falta asignar el parámetro correspondiente el CUIL</br>'
    if ($('CDA').value == '')
        strError += 'Falta asignar el parámetro correspondiente el CDA</br>'
    if ($('vendedor').value == '')
        strError += 'Falta asignar el parámetro correspondiente el vendedor</br>'
    
    parametros_det.each(function (arreglo, j) {

        if (arreglo.estado != 'B' && arreglo.disabled == false) {
            if ($('nosis_def_' + j).value == '')
                strError += 'Falta definir el parámetro a la definición</br>'
            if ($('parametro_' + j).value == '')
                strError += 'Falta definir un parámetro</br>'
            if ($('xpath_' + j).value == '')
                strError += 'Falta definir un path</br>'
        }

    });

    return strError

}   

function guardar()
{

    transferencia_actualizar()

    if (indice == -1) {
        Transferencia["detalle"].length++
        indice = Transferencia["detalle"].length - 1
        Transferencia["detalle"][indice] = new Array();
    }

    Transferencia["detalle"][indice]["orden"] = indice
    Transferencia["detalle"][indice]["transf_tipo"] = 'NOS'
    Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
    Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
    Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value

    Transferencia.detalle[indice].parametros_extra.cuil = $('CUIL').value
    Transferencia.detalle[indice].parametros_extra.cda = $('CDA').value
    Transferencia.detalle[indice].parametros_extra.vendedor = $('vendedor').value
    Transferencia.detalle[indice].parametros_extra.actualizar_fuentes = $('actualizar_fuentes').checked == true ? 'true' : 'false'
    Transferencia.detalle[indice].parametros_extra.tipo_informe = $('tipo_informe').value
    Transferencia.detalle[indice].parametros_extra.forzar_consulta = $('forzar_consulta').checked == true ? 'true' : 'false'
    Transferencia.detalle[indice].parametros_extra.razonsocial = $('razonsocial').value
    Transferencia.detalle[indice].parametros_extra.sexo = $('sexo').value

    for (var i = 0; i < parametros_det.length; i++)
        if (parametros_det[i]["estado"] == 'N')
            parametros_det[i]["estado"] = ''

    Transferencia["detalle"][indice]["parametros_det"].length = 0
    Transferencia["detalle"][indice]["parametros_det"] = parametros_det

    var strXML = ""
    parametros_det.each(function (arreglo, j) {
       // if (($('parametro_' + j).value != "" || $('valor_' + j).value != "") && $("tansf_param_" + j).value != "")
          strXML += "<parametro editable= '"+ (arreglo.disabled == true ? 'false' : 'true') +"' param='" + $('parametro_' + j).value + "' nosis_def='" + $('nosis_def_' + j).value + "' nosis_descripcion='" + $('nosis_descripcion_' + j).value + "' nosis_xpath='" + $("xpath_" + j).value + "'/>"
    });
    
    Transferencia.detalle[indice].parametros_extra.asignacion = strXML

    return Transferencia

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


function window_onresize()
{
 try
 {
  var dif = Prototype.Browser.IE ? 5 : 2
  var body_h = $$('body')[0].getHeight()
  var divCab_h = $('divCab').getHeight()
  var tbTarget_h = 0 //$('tbTarget').getHeight()
  $('divNOSIS').setStyle({ 'height': body_h - divCab_h - tbTarget_h - dif })

  $('tbNosis').getHeight() - $('divNOSIS').getHeight() > 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
 }
 catch(e){}
}

function tdScroll_hide_show(show)
    {
    var i = 0
    while (i <= parametros_det.size())
        {
          if(show &&  $('tdScroll'+ i) != undefined)
           $('tdScroll'+ i).show() 
          
          if(!show &&  $('tdScroll'+ i) != undefined)
           $('tdScroll'+ i).hide() 
          
          i++
        }
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
                            onClose: NosisDibujar
                       });
    
    win.options.Transferencia = Transferencia
    win.show()
  }

function onchange_tipo_informe() {

  parametros_det.length = 0

  NosisCargar(true)
  NosisDibujar()

}

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
<input type="hidden" name="indice" id="indice" value="<%=indice%>" />
<div id="divCab" style="margin: 0px;padding: 0px;">
    <table class='tb1'>
        <tr class='tbLabel'>
         <td colspan="3"><b>Parámetros de Entrada:</b></td>
        </tr>
        <tr>
         <td colspan="3">
         <table class='tb1'>
         <tr>
            <td>&nbsp;</td>
            <td class="Tit1" style="width: 5%;text-align:right">CUIL:</td>
            <td style="width: 15%"><div id="divCUIL"></div></td>
            <td class="Tit1" style="width: 5%;text-align:right">CDA:</td>
            <td style="width: 15%"><div id="divCDA"></div></td>
            <td class="Tit1" style="width: 5%;text-align:right">Vendedor:</td>
            <td style="width: 15%"><div id="divVendedor"></div></td>
            <td class="Tit1" style="width: 5%;text-align:right;white-space:nowrap">Actualizar Fuentes:</td>
            <td style="width: 2%;text-align:left"><input type="checkbox" id="actualizar_fuentes" style="border:0px" ></td>
            <td class="Tit1" style="width: 5%;text-align:left;white-space:nowrap">Tipo Informe:</td>
            <td style="width: 12%;text-align:left"><select id="tipo_informe" style="width:100%" onchange="return onchange_tipo_informe()"><option value="sac_informe">Clásico</option><option value="sac_informe_variable">Variable</option></select></td>
            <td class="Tit1" style="width: 5%;text-align:left;white-space:nowrap">Forza la consulta:</td>
            <td style="width: 2%;text-align:left"><input type="checkbox" id="forzar_consulta" style="border:0px" ></td>
            <td>&nbsp;</td>
         </tr>
            <tr>
             <td>&nbsp;</td>
             <td class="Tit1" style="width: 5%;text-align:right">RazonSocial:</td>
             <td style="width: 15%"><div id="divrazonsocial"></div></td>
             <td class="Tit1" style="width: 5%;text-align:right">Sexo:</td>
             <td style="width: 15%"><div id="divsexo"></div></td>
             <td>&nbsp;</td>
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
         Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
         Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parametro_xls_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>var</icono><Desc>Parámetros</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_transferencia_parametros()</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenuParametros.loadImage("var", '/fw/image/transferencia/variable.png')
         vMenuParametros.loadImage("nueva", '/fw/image/transferencia/nueva.png')
         vMenuParametros.MostrarMenu()
        </script> 
     <table class='tb1'>
     <tr class='tbLabel'>
       <td style='text-align:center;white-space:nowrap' colspan="2"><b>Entrada</b></td>
       <td style='width:20%; text-align:center;white-space:nowrap'><b>Salida</b></td>
       <td style='width:2%; text-align:center;white-space:nowrap' rowspan="2" >-</td>
       <td style='width:14px; text-align:center' rowspan="2">-</td> 
     </tr>
     <tr class='tbLabel'>
       <td style='text-align:center;white-space:nowrap'>xPath</td>
       <td style='width:44%; text-align:center;white-space:nowrap'>Variable (Descripción/Valor)</td>
       <td style='width:20%; text-align:center;white-space:nowrap'>Parámetros</td>
     </tr>
    </table>          
    </div>
    
    <div id="divNOSIS" style="width:100%;overflow:auto;"></div>
    
    <table id="tbTarget" class='tb1' style="width:100%;height:100px;vertical-align:bottom;display:none">   
       <tr class='tbLabel'>
            <td colspan="3">TARGET</td>
       </tr>
        <tr>
            <td style="width: 90%"><select style="width: 100%" size="8" id='target_cd'></select></td>
            <td style="width: 10%; vertical-align: middle"><input type="button" name="btn_target_nuevo" style="width: 100%" value="Nuevo" onclick ="btn_target_nuevo_onclick()"/>
            <input type="button" name="btn_target_borrar" style="width: 100%" value="Borrar" onclick ="btn_target_borrar_onclick()"/></td>

         </tr>
    </table>       
</body>
</html>