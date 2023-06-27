<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Me.contents("filtro_campos_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='campos_def'><campos>campo_def,descripcion</campos><orden>campo_def,descripcion</orden><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtro_verParametros_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros_def'><campos>param_tipo</campos><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtro_verParametros") = nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros'><campos>%campo% as descripcion</campos><grupo></grupo><filtro></filtro></select></criterio>")

%>
<html>
<head>
<title>Transferencia ABM Parametros</title>
    <meta http-equiv="X-UA-Compatible" content="IE=8"/>
    <!--meta charset='utf-8'-->
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
    <% = Me.getHeadInit()%>  
<%
    Dim id_transferencia = nvUtiles.obtenerValor("id_transferencia", "")
%>
       <style type="text/css">
           /**** menu ****/      

            .trOver td {
                background: #C0C0C0
            }

      

    </style>
<script type="text/javascript">
    
var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 
var arCampos_defs = ''
var arParam = ''

function isNULL(valor, sinulo)
{
  valor = valor == null ? sinulo: valor
  return valor
}

var win = nvFW.getMyWindow()
var Transferencia = win.options.Transferencia //ObtenerVentana('frame_contenedor').Transferencia

function window_onload() 
{
 //parametros_cargar()    
 parametros_dibujar()
 campos_defs.items['id_param']['onchange'] = id_param_onchange;

    window_onresize()


    parent.$(win.getId() + '_close').onclick = function (e) {

        var strError = campo_parametro_validar()

        if (strError == "") {
            for (j = 0; j < Transferencia["parametros"].length; j++) {
                if (($('parametro' + j).value in list_params_reservado))
                    strError = j + "-El parámetro '" + $('parametro' + j).value + "' se encuentra reservado."
            }

          if (strError != "") {
              index = strError.split('-')[0]
              strError = strError.split('-')[1]
              confirm(strError + "</br> ¿Desea continuar?", {
                        width: 400,
                        height: "auto",
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function (w) {
                            win.close(); return
                        },
                        onCancel: function (w) {
                            w.close(); return
                        }
                    });
             return
            }

        }

        if (strError == "")
           win.close()
    }
 
}

var id_param_index = 0
function id_param_onclick(index)
{
 id_param_index = index
 
 //if(!$('editable'+ id_param_index).checked)
  //return
 
 //campos_defs.clear("id_param")
 campos_defs.onclick("","id_param",true)
}

function id_param_onchange()
{
 $('id_param'+ id_param_index).value = campos_defs.value('id_param')
 valida_tipo_dato(id_param_index)
 $('id_param' + id_param_index).title = param_descripcion(campos_defs.value('id_param'), "param")
 $('valor_defecto' + id_param_index).value = param_descripcion(campos_defs.value('id_param'),"valor")
 transferencia_actualizar()
}

function cargar_tipoparametria()
{
Transferencia["parametros"].each(function(arreglo,j)
           {
             tipo_parametria_onchange(undefined,j)
           });
}

function id_param_clear(index)
{
 if($('id_param'+ index).disabled)
  return
  
 $('id_param'+ index).value = ""
 campos_defs.clear('id_param')
}

function dropStart_tdParam(event, origen) {
    event.dataTransfer.setData("Text", origen);
  }

function drop(event, destino) {
   event.preventDefault();
   var origen = event.dataTransfer.getData("Text");

   $("trParam" + destino).removeClassName('trOver')

   parametro_drop(origen,destino)
}

 function parametro_drop(origen, destino) {

  transferencia_actualizar()

  var dif = 0.1
  if (Transferencia["parametros"][origen].orden < Transferencia["parametros"][destino].orden)
         dif = (0.1) * -1

  
  Transferencia["parametros"][origen].orden = Transferencia["parametros"][destino].orden
  Transferencia["parametros"][destino].orden = Transferencia["parametros"][destino].orden + dif

  ///* Ordenar el arreglo */
  for(i=0;i<Transferencia["parametros"].length;i++)
	{
	    	for(j=i+1;j<Transferencia["parametros"].length;j++)
	      	{
	 		if(Number(Transferencia["parametros"][i]['orden']) > Number(Transferencia["parametros"][j]['orden']))
	    		{
		  	        tempValue = Transferencia["parametros"][j];
		    		Transferencia["parametros"][j] = Transferencia["parametros"][i];
			    	Transferencia["parametros"][i] = tempValue;
			    }
	    	}
	}

  parametros_dibujar()

 }

function dropEnter_tdParam(event, index) { //entrada al evento
    event.preventDefault();

    $("trParam" + index).addClassName('trOver')
}

function dropOver_tdParam(event, index) { //sobre el evento
    event.preventDefault();

    $("trParam" + index).addClassName('trOver')

}


function dropLeave_tdParam(event, index) { //salida al evento

    event.preventDefault();

    $("trParam" + index).removeClassName('trOver')  
  
}

document.ondragover = null;
document.ondrop = null;

function parametros_dibujar()
{
      $('divParametros').innerHTML = ""
 
      var strHTML = "<table class='tb1' style='width:100%' id='tbParametros'>"  
      var i = 0    
      Transferencia["parametros"].each(function(arreglo,j)
          { 
          arreglo["orden"]  = i
          strHTML += "<tr id='trParam" + j + "'>"
          strHTML += "<td style='width:5%; text-align:center; vertical-align:middle' draggable='true' id='tdParam" + j + "' ondragstart='return dropStart_tdParam(event," + j + ")' ondragover='return dropOver_tdParam(event," + j + ")'  ondragleave='return dropLeave_tdParam(event," + j + ")'  ondragenter='return dropEnter_tdParam(event," + j + ")' ondrop='drop(event," + j + ")'>"
          strHTML += "<img src='/fw/image/transferencia/arrow_up.png' onclick='parametro_subir(" + j + ")' style='cursor:hand;cursor:pointer' border='0' align='absmiddle' hspace='1'/>" 
          strHTML += "<img src='/fw/image/transferencia/arrow_down.png' onclick='parametro_bajar(" + j + ")' style='cursor:hand;cursor:pointer' border='0' align='absmiddle' hspace='1'/></td>"
          strHTML += "<td style='width:2%; text-align:center; vertical-align:middle'>" + arreglo["orden"] + "</td>"         
          strHTML += "<td style='width:2%; text-align:center; vertical-align:middle'><img src='/FW/image/tnvRect/delete.png' onclick='btnEliminar_Parametro_onclick(" + j + ")' style='cursor:hand;cursor:pointer' border='0' align='absmiddle' hspace='1'/></td>"
          strHTML += "<td style='text-align:left; vertical-align:middle'><div style='width:100%;'><input style='width:100%; overflow: hidden;' type='text' name='parametro" + j + "' id='parametro" + j + "' value='" + arreglo["parametro"] + "' /></div></td>"          //onblur='campo_parametro_validar()'
          strHTML += "<td style='width:8%; text-align:center; vertical-align:middle'>"
          strHTML += armar_tipodato(arreglo["tipo_dato"], j)
          strHTML += "</td>"
          
          strHTML += "<td id='td_tipo_dato" + j + "' style='width:12%; text-align:left; vertical-align:middle'>" + parametro_cambiar_tipo(j, arreglo["tipo_dato"], arreglo["valor_defecto"],arreglo["file_max_size"],arreglo["file_filtro"]) + " </td> "
      
          var requerido_chk = ''
          if (arreglo["requerido"])
             requerido_chk = 'checked'
             
          strHTML += "<td style='width:2%; text-align:center; vertical-align:middle'><input type='checkbox' style='border:0px' " + requerido_chk + " name='requerido" + j + "' id='requerido" + j + "' onblur='transferencia_actualizar()'/></td>" 
          
          var disabled_editable = ''
          var editable_chk = 'checked'
          
          if (!arreglo["editable"])
            {
         //   disabled_editable = ' disabled '
            editable_chk = ''     
             }
        //   else
          //   {
          //   etiqueta_d = 'disabled' 
          //   valor_defecto_edit_d = 'disabled'
           //  }                     

          var interno_chk = ''
          if (arreglo["interno"])
             interno_chk = 'checked'

          strHTML += "<td style='width:2%; text-align:center; vertical-align:middle'><input type='checkbox' style='border:0px' " + editable_chk + " name='editable" + j + "' id='editable" + j + "'  onclick='btn_editable_onclick(" + j + ")' onblur='transferencia_actualizar()'/></td>"   
          strHTML += "<td style='width:10%; text-align:left; vertical-align:middle'><input type='text' style='width:100%' " + disabled_editable + " name='etiqueta" + j + "' id='etiqueta" + j + "' value='" + arreglo["etiqueta"] + "' onblur='transferencia_actualizar()'/></td>"                    
          strHTML += "<td style='width:10%; text-align:left; vertical-align:middle'><input type='text' style='width:100%' " + disabled_editable + " name='valor_defecto_editable" + j + "' id='valor_defecto_editable" + j + "' value='" + arreglo["valor_defecto_editable"] + "' onblur='transferencia_actualizar()'/></td>"          
          strHTML += "<td style='width:10%; text-align:center; vertical-align:middle'>"
            strHTML += armar_tipoparametria(arreglo["tipo_parametria"], j)
          strHTML += "</td>" 
          strHTML += "<td style='width:15%; text-align:center; vertical-align:middle' id='tdCampo_Def"+j+"'>" + campo_def_cargar( j , arreglo["campo_def"]) + "</td>"                                                                      
          strHTML += "<td style='width:15%; text-align:left; vertical-align:middle' id='tdParametro"+j+"'><input type='text' id='id_param"+j+"' value='"+ arreglo["id_param"]+"' title='"+ param_descripcion(arreglo["id_param"],"param")+ "' " + disabled_editable + " readonly = 'readonly' style='width:70%'/><span style='vertical-align:bottom;width:5px'><img src='/fw/image/campo_def/buscar.png' style='cursor:hand;cursor:pointer;' onclick='id_param_onclick("+j+")'/><img src='/fw/image/campo_def/file.png' style='cursor:hand;cursor:pointer;' onclick='id_param_clear("+j+")'/></span></td>"    
          strHTML += "<td style='width:15%; text-align:center; vertical-align:middle' id='tdVacio"+j+"'></td>"    
          strHTML += "<td style='width:2%; text-align:center; vertical-align:middle'><input type='checkbox' style='border:0px' " + interno_chk + " name='interno" + j + "' id='interno" + j + "' onblur='transferencia_actualizar()'/></td>"   
          strHTML += "<td style='width:14px !Important' id='tdScroll" + j + "'></td>"
          strHTML += "</tr>"
          
          i++ 
          });            
      strHTML += "</table>"
    
      $('divParametros').insert({ top: strHTML })
      
    window_onresize()

    cargar_tipoparametria()
    //transferencia_xls_habilitada() 
}

function param_descripcion(id_param,campo)
{
  if(id_param == '' || id_param == null)
   return ""
   
  var parametros = "<criterio><params campo= '" + campo + "' /></criterio>";
  var rs = new tRS();
  rs.open(nvFW.pageContents.filtro_verParametros, "", "<criterio><select><filtro><id_param type='igual'>'" + id_param + "'</id_param></filtro></select></criterio>", "", parametros)
  if(!rs.eof())
   return rs.getdata("descripcion")
  else
   return ""   
}

function valida_tipo_dato(orden)
{
  if($('id_param'+ orden).value == "")
   return 
   
  var tipodato = $('tipo_dato'+ orden).value 
  var strError = ""
  var rs = new tRS();
  rs.open(nvFW.pageContents.filtro_verParametros_def,"","<criterio><select><filtro><id_param type='igual'>'"+ $('id_param'+ orden).value +"'</id_param></filtro></select></criterio>","","") 
  if(!rs.eof() && tipodato != "")    
   {
    param_tipo = rs.getdata("param_tipo")
    switch (tipodato)
    {
      case 'int':
       if(param_tipo != '100')
        strError= "El parámetro debe ser entero."
      break

      case 'money':
       if(param_tipo != '102')
       strError= "El parámetro debe ser moneda."
      break

      case 'datetime':
       if(param_tipo != '103')
        strError= "El parámetro debe ser fecha."
      break
      
      case 'file':
       if(param_tipo != '104')
        strError= "El parámetro debe ser cadena."
      break
     
     }
   }
  
  if(strError != "")
   {
    alert(strError)
    $('id_param'+ orden).value = ""
   }

}

function tipo_parametria_onchange(evento,orden)
{

 if($('tipo_param'+ orden ).options[$('tipo_param'+ orden).selectedIndex].text == 'Campo Def')
  {
   $('tdVacio'+ orden).hide()

   $('tdCampo_Def'+ orden).show()
   $('tdParametro'+ orden).hide()

   if (evento != undefined)
   $('valor_defecto' + orden).value = ""
   
   //$('valor_defecto' + orden).disabled = false
   $('id_param'+ orden).value = ""
  } 

 if($('tipo_param'+ orden ).options[$('tipo_param'+ orden).selectedIndex].text == 'Param Global')
  {
   $('tdVacio'+ orden).hide()

   $('tdCampo_Def'+ orden).hide()
   $('tdParametro'+ orden).show()

   $('valor_defecto' + orden).value =  ""// param_descripcion($('id_param' + orden).value, "valor")
   //$('valor_defecto' + orden).disabled = true
   $('campo_def'+orden).value = ""
  } 
 
 if($('tipo_param'+ orden ).options[$('tipo_param'+ orden).selectedIndex].text == '')
  {
   $('tdVacio'+ orden).show()
   
   $('tdCampo_Def'+ orden).hide()
   $('tdParametro' + orden).hide()

   if (evento != undefined)
   $('valor_defecto' + orden).value = ""

   //$('valor_defecto' + orden).disabled = false
  }  
}

function transferencia_xls_habilitada()
{
 //Actualiza Parametros
 Transferencia["parametros"].each(function(arreglo,j)
  {  
    if(Transferencia["parametros"][j]['habilitado'])
        {
         $('tipo_dato' + j).disabled = true
         $('tipo_dato'+ j)[5].selected = true
         $('valor_defecto' + j).disabled = true
         $('requerido' + j).disabled = true
         $('editable' + j).disabled = true
         $('etiqueta' + j).disabled = true
         $('valor_defecto_editable' + j).disabled = true
         $('campo_def'+j).disabled = true
         $('id_param'+ j).disabled = true
         $('tipo_param' + j).disabled = true
         $('interno'+j).disabled = true
        }
   });
 }

function btn_editable_onclick(j) 
{

// if ($('parametro' + j).value == "") 
//  {
//   alert("El parámetro está vacio. Debe definirlo.")
//   $('editable' + j).checked = false
//   return
//  }
        
//campo_chk = $('editable' + j)
//campo_etiqueta = $('etiqueta' + j)
//campo_valor_defecto = $('valor_defecto_editable' + j)
//campo_campo_def = $('campo_def' + j)
//campo_tipo_param = $('tipo_param' + j)
//campo_id_param = $('id_param'+ j)

//campo_etiqueta.disabled = !campo_chk.checked
//campo_valor_defecto.disabled = !campo_chk.checked
//campo_campo_def.disabled = !campo_chk.checked
//campo_id_param.disabled = !campo_chk.checked
//campo_tipo_param.disabled = !campo_chk.checked

}

function campo_def_cargar(orden, campo_def)
{  
    if (arCampos_defs == '') 
      {
      arCampos_defs = new Array();
      var rs = new tRS();
      rs.open(nvFW.pageContents.filtro_campos_def,"","","","")
      while (!rs.eof())
       {
       arCampos_defs[rs.position] = new Array();
       arCampos_defs[rs.position]['campo_def'] =  rs.getdata('campo_def').toLowerCase()
       arCampos_defs[rs.position]['descripcion'] =  rs.getdata('descripcion').toLowerCase()
       rs.movenext()      
       }
      }
    var disabled = ''
   // if (!Transferencia["parametros"][orden]["editable"])
     //        disabled = ' disabled'
    var Str_CampoDef = "<select style='width:100%' " + disabled + " name='campo_def"  + orden + "' id='campo_def"  + orden + "' onblur='transferencia_actualizar()'>"
    
    Str_CampoDef += "<option value=''></option>"
    var seleccionado = ''
    arCampos_defs.each(function(arreglo,i)
        {
         seleccionado = arreglo['campo_def'] == campo_def.toLowerCase() ? 'selected' : ''
         Str_CampoDef += "<option value='" +  arreglo['campo_def'] + "' " + seleccionado + ">" + arreglo['campo_def']  + "</option>"
        });

Str_CampoDef += "</select>"     
return Str_CampoDef
}

/*
function param_cargar()
{  
   
   Transferencia["parametros"].each(function(arreglo,i)
        {
         campos_defs.add( 'id_param' + i , {
                                            despliega: 'arriba',
                                            enDB: false,
                                            target: 'tdParametro' + i ,
                                            nro_campo_tipo: 1,
                                            filtroXML: "<criterio><select vista='verParametros'><campos>distinct id_param as id, [param] as [campo] </campos><orden>[campo]</orden></select></criterio>",
                                            filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>"
                                           })
   
         campos_defs.set_value('id_param' + i,arreglo.id_param)
         campos_defs.items['id_param' + i]["onchange"] = function(){transferencia_actualizar();
                                                                    try
                                                                     {
                                                                      $(this.campo_def + '_desc').title = param_descripcion(this.input_hidden.value)
                                                                      $(this.campo_def + '_desc').value = this.input_hidden.value  
                                                                     } 
                                                                    catch(e1){}}

         $('id_param' + i + '_desc').title = param_descripcion(this.input_hidden.value)
         $('id_param' + i + '_desc').value =  campos_defs.items['id_param' + i]["input_hidden"].value 
       });                                                   
}
*/

function armar_tipoparametria(tipo, orden)
{
 var disabled = ''
 //if (!Transferencia["parametros"][orden]["editable"])
 //     disabled = ' disabled'
             
var Str_TipoParam = "<select style='width:100%' " + disabled + " name='tipo_param" + orden + "' id='tipo_param" + orden + "' onchange='return tipo_parametria_onchange(event," + orden + ")' onblur='transferencia_actualizar()'>"
Tipo_Param = new Array();
Tipo_Param[0] = ''
Tipo_Param[1] = 'Campo Def'
Tipo_Param[2] = 'Param Global'
Tipo_Param.each(function(arreglo,i)
    {
    var seleccionado = ''
    if (tipo == arreglo)
        seleccionado = 'selected'
    Str_TipoParam += "<option value='" + arreglo + "' " + seleccionado + ">" + arreglo + "</option>"
    });
Str_TipoParam += "</select>"     
return Str_TipoParam
}


function armar_tipodato(tipo_dato, orden)
{

var Str_TipoDato = "<select style='width:100%' name='tipo_dato" + orden + "' id='tipo_dato" + orden + "' onchange='return parametro_cambiar_tipo(" + orden + ") && valida_tipo_dato("+orden+")' onblur='transferencia_actualizar()'>"
Tipo_Dato = new Array();
Tipo_Dato[0] = 'bit'
Tipo_Dato[1] = 'datetime'
Tipo_Dato[2] = 'file'
Tipo_Dato[3] = 'int'
Tipo_Dato[4] = 'money'
Tipo_Dato[5] = 'varchar'
Tipo_Dato.each(function(arreglo,i)
    {
    var seleccionado = ''
    if (tipo_dato == arreglo)
        seleccionado = 'selected'
    Str_TipoDato += "<option value='" + arreglo + "' " + seleccionado + ">" + arreglo + "</option>"
    });
Str_TipoDato += "</select>"     
return Str_TipoDato
}

function btnNuevo_Parametro_onclick()
{
  strError = campo_parametro_validar() 
  if(strError != '')
   return
   
  transferencia_actualizar("validar") 
  
  indice = Transferencia["parametros"].length
  Transferencia["parametros"][indice] = new Array();
  Transferencia["parametros"][indice]["parametro"] = ''
  Transferencia["parametros"][indice]["tipo_dato"] = 'varchar'
  Transferencia["parametros"][indice]["valor_defecto"] = ''
  Transferencia["parametros"][indice]["requerido"] = false
  Transferencia["parametros"][indice]["editable"] = false
  Transferencia["parametros"][indice]["etiqueta"] = ''
  
  if (indice == 0)
      Transferencia["parametros"][indice]["orden"] = 0
  else
      Transferencia["parametros"][indice]["orden"] = parseFloat(Transferencia["parametros"][indice-1]["orden"]) + 1
      
  Transferencia["parametros"][indice]["valor_defecto_editable"] = ''
  Transferencia["parametros"][indice]["campo_def"] = ''
  Transferencia["parametros"][indice]["id_param"] = ''
  Transferencia["parametros"][indice]["tipo_parametria"] = ''
  Transferencia["parametros"][indice]["file_max_size"] ='0'
  Transferencia["parametros"][indice]["file_filtro"] = ''  
  Transferencia["parametros"][indice]["valor_hoja"] = ''
  Transferencia["parametros"][indice]["valor_celda"] = ''
  Transferencia["parametros"][indice]["valor_io"] = 1
  Transferencia["parametros"][indice]["habilitado"] = false
  Transferencia["parametros"][indice]["valor_eqv"] = ''
  Transferencia["parametros"][indice]["interno"] = true

  parametros_dibujar()

}

function prototype_window(obj)
    {
    var win = new Window(obj);
    return win
    }      

function btnEliminar_Parametro_onclick(j) {
    transferencia_actualizar()
    
    var used = '';
    if(isInUSR(Transferencia["parametros"][j].parametro)) {
        used = '<b style="color: #EE2222;">El parámetro esta siendo utilizado en un USR.</b> ';
    }
    Dialog.confirm(used + "Desea Borrar El Parametro Seleccionado", {   width: 300,
                                                                 className: "alphacube",
                                                                 okLabel: "Si",
                                                                 cancelLabel: "No",
                                                                 onOk: function(win){
                                                                                      IUSRRemove(Transferencia["parametros"][j].parametro)
                                                                                      Transferencia["parametros"].splice(j,1) 
                                                                                      parametros_dibujar()
                                                                                      win.close(); return
                                                                                    },
                                                                 onCancel: function(win) { win.close(); return }
                                                              });
}

function IUSRRemove(parametro_name) {
    Transferencia["detalle"].each(function (detalle, j) {
        if (detalle.transf_tipo == 'USR' || detalle.transf_tipo == 'IUS')
            if (detalle.parametros_det[parametro_name] != undefined)
                delete (detalle.parametros_det[parametro_name])
        });
    }

function parametro_bajar(orden)
  { transferencia_actualizar()
  if (orden < Transferencia["parametros"].length-1)
    {
    var a = Transferencia["parametros"][orden]
    Transferencia["parametros"][orden] = Transferencia["parametros"][orden+1]
    Transferencia["parametros"][orden+1] = a
    parametros_dibujar()
    }
    
  }
  
function parametro_subir(orden)
  {
  transferencia_actualizar()
  if (orden > 0)
    {
    var a = Transferencia["parametros"][orden]
    Transferencia["parametros"][orden] = Transferencia["parametros"][orden-1]
    Transferencia["parametros"][orden-1] = a
    parametros_dibujar()
    }
  }
  
function parametro_cambiar_tipo(orden, tipo_dato, valor_defecto, file_max_size, file_filtro)
   {
   if (!valor_defecto)
      valor_defecto = ''
   var objSelect = $("tipo_dato" + orden)
   var objTD = $("td_tipo_dato" + orden)

   if (objSelect != undefined )
      var a = objSelect.options[objSelect.selectedIndex].value.toLowerCase()
   else
      var a = tipo_dato.toLowerCase()

   var strHTML = ""
    if (a == 'file') {
        input = "type = 'text' style='width: 100%' disabled "
        strHTML = "<input type='text' onchange='return validarNumero(event,\"0.00\")' onkeypress='return valDigito(event,\".\")' onblur='transferencia_actualizar()' style='width: 25%; text-align: right' name='file_max_size" + orden + "' id='file_max_size" + orden + "' value='" + parseFloat(Transferencia["parametros"][orden]["file_max_size"]).toFixed(2) + "' />"
        strHTML += "&nbsp;Mb<input type='text' style='width: 55%' name='file_filtro" + orden + "' id='file_filtro" + orden + "' onblur='transferencia_actualizar()'  value='" + Transferencia["parametros"][orden]["file_filtro"] + "' />"
        strHTML += "<input type='hidden' name='valor_defecto" + orden + "' id='valor_defecto" + orden + "' value=''/>"
    }
    else {
        if (a == 'bit') {
            strHTML = "<select onblur='transferencia_actualizar()' style='width: 100%; text-align: right' name='valor_defecto" + orden + "' id='valor_defecto" + orden + "'>"
            strHTML += "<option value='' " + (valor_defecto == "" ? "selected='selected'" : "") + ">Nulo</option>"
            strHTML += "<option value='1' " + (valor_defecto == "1" ? "selected='selected'" : "") + ">Verdadero</option>"
            strHTML += "<option value='0' " + (valor_defecto == "0" ? "selected='selected'" : "") + ">Falso</option></select>"
        }
        else {

             var input = ''
             switch (a) {
                case 'int':
                    input = "type = 'text'  onkeypress='return valDigito(event)' style='width: 100%; text-align: right'"
                    break
                case 'money':
                    input = "  onkeypress='return valDigito(event,\".\")' onchange='return validarNumero(event,\"0.00\")' style='width: 100%; text-align: right'"
                    break
                case 'datetime':
                    input = "type = 'text' onchange='return valFecha(event)' onkeypress='return valDigitoFecha(event)' style='width: 100%; text-align: right'"
                    break
                //case 'bit':
                //     input = "type = 'checkbox' style='border:0px' "
                //     valor_defecto = valor_defecto == '0' || valor_defecto == '' ? "0' ": "1'  checked='checked'"
                //     valor_defecto += "onclick='checkear_bit("+ orden +")"
                //     break    
                case 'varchar':
                    input = "type = 'text' style='width: 100%; text-align: right'"
                    break

             }

             strHTML = "<input " + input + " name='valor_defecto" + orden + "' id='valor_defecto" + orden + "' value='" + valor_defecto + "' onblur='transferencia_actualizar()'/>"
        }

        strHTML += "<input type='hidden' name='file_max_size" + orden + "' id='file_max_size" + orden + "'  value=''/>"
        strHTML += "<input type='hidden' name='file_filtro" + orden + "' id='file_filtro" + orden + "' value=''/>"
    }

    if (objTD != undefined)
     {
      objTD.innerHTML = ''  
      objTD.insert({top:strHTML})
     }
   return strHTML
  }
    
  function valDigitoFecha(event) {
      var oE = Event.element(event)
      var strFecha = oE.value
      strFecha.replace(/[^0-9\/]+/, '');
      oE.value = strFecha
  }
  function checkear_bit(orden)
  { 
   campo = $('valor_defecto' + orden)
   if (campo.checked == true)
      campo.value=1
   else
      campo.value=0
  }
   
function isInUSR(parametro_name) {
    var result = false;
    Transferencia["detalle"].each(function(detalle) {
        if(detalle.transf_tipo == 'USR' || detalle.transf_tipo == 'IUS') {
            if(detalle.parametros_det[parametro_name] != undefined){
                result = true;
            }
        }
    });
    return result;
}

var list_params_reservado = {}
    list_params_reservado.id_transf_log = null           

function campo_parametro_validar()
{
    var strError = ""
    for (j = 0; j < Transferencia["parametros"].length; j++)
   {
     if ($('parametro' + j).value == "")
         strError = j + "-El parámetro está vacio."
     else {
         
         //if (($('parametro' + j).value in list_params_reservado))
          //   strError = j + "-El parámetro '" + $('parametro' + j).value + "'</br>se encuentra reservada."

         if (campo_parametro_existe($('parametro' + j).value, j))
             strError = j + "-El parámetro '" + $('parametro' + j).value + "'</br>ya existe."
     }
   }

 if(strError != "")
   {
    index = strError.split('-')[0]
    strError = strError.split('-')[1]
    alert(strError)
    $('parametro' + index).value = ""
   }
 
 if (strError == '')
  transferencia_actualizar()

 return strError   
}

function campo_parametro_existe(valor,pos)
{
 var existe = false
 Transferencia["parametros"].each(function(arreglo,j)
   {
    if(valor == $('parametro' + j).value && j != pos)
       existe = true
   });
 return existe 
}

function transferencia_actualizar(validar)
{
// if(validar)
//  {
//     var strError = campo_parametro_validar()
//     if(strError != "")
//      {
//       index = strError.split('-')[0]
//       strError = strError.split('-')[1]
//       alert(strError)
//    
//       $('parametro' + index).value = ""
//      // $('parametro' + index).focus()
//       return
//      }
//  }
     
 //Actualiza Parametros
 var p=0
Transferencia["parametros"].each(function(arreglo,j)
{  
    if(isInUSR(arreglo["parametro"]) && arreglo["parametro"] != $('parametro' + j).value) {
        alert('El parámetro "' + arreglo["parametro"] + '" esta siendo utilizado en un USR. Si modifica el nombre se perderá la asociación.')
    }
    arreglo["orden"] = p      
    arreglo["parametro"] = $('parametro' + j).value
    arreglo["tipo_dato"] = $('tipo_dato' + j).value
    arreglo["requerido"] = $('requerido' + j).checked
    arreglo["editable"] = $('editable' + j).checked
    arreglo["etiqueta"] = $('etiqueta' + j).value
    arreglo["valor_defecto"] = $('valor_defecto' + j).value
    arreglo["valor_defecto_editable"] = $('valor_defecto_editable' + j).value
    arreglo["campo_def"] = $('campo_def'+j).value
    arreglo["id_param"] = $('id_param'+j).value
    arreglo["file_max_size"] = $('file_max_size' + j).value == '' ? '0' : $('file_max_size' + j).value
    arreglo["file_filtro"] = $('file_filtro' + j).value
    arreglo["tipo_parametria"] = $('tipo_param'+j).value
    arreglo["interno"] = $('interno' + j).checked

   // if(arreglo["id_param"] != "")
    //  arreglo["valor_defecto"] = ""


    p++
    });
    
}  

function window_onresize()
{
 try
 {
     
  var dif = Prototype.Browser.IE ? 5 : 2
  var body_h = $$('body')[0].getHeight()
  var divCab_h = $('divCab').getHeight()
  var tbParametros_h = $('tbParametros').getHeight()
  
  var calculo = body_h - divCab_h - 30 - dif

  if (tbParametros_h > calculo)
    $('divParametros').setStyle({ 'height': (body_h - divCab_h - 30 - dif) + 'px' })
  else
  {
    $('divParametros').setStyle({ 'height': (tbParametros_h) + 'px' })
    $('divPie').setStyle({ 'height': (body_h - divCab_h - tbParametros_h - dif) + 'px' })
  }

  $('tbParametros').getHeight() - $('divParametros').getHeight() > 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
 }
 catch(e){}
}

function tdScroll_hide_show(show)
    {
      var i = 0
      while(i <= Transferencia["parametros"].size())
        {
          if(show &&  $('tdScroll'+ i) != undefined)
           $('tdScroll'+ i).show() 
          
          if(!show &&  $('tdScroll'+ i) != undefined)
           $('tdScroll'+ i).hide() 
          
          i++
        }
}


function window_onunload()
{

  
}

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" onunload="window_onunload()" style="width:100% !Important; height: 100% !Important; overflow: hidden; margin: 0px; padding: 0px; ">
        <input type="hidden" name="id_transferencia" id="id_transferencia" value="<%= id_transferencia %>"/>    
        <div style="display: none;"><%= nvCampo_def.get_html_input("id_param") %></div>
        <div id="divCab" style="margin: 0px;padding: 0px;">
        <table class='tb1'>
         <tr class='tbLabel'>
           <td style='width:5%; text-align:center'>-</td>
           <td style='width:2%; text-align:center'>-</td>
           <td style='width:2%; text-align:center'>-</td>
           <td style='text-align:center'>Parámetro</td>
           <td style='width:8%; text-align:center'>Tipo Dato</td>
           <td style='width:13%; text-align:center'>Def.|Mx. size/Filtro</td>
           <td style='width:2%; text-align:center' title="Requerido">R</td>
           <td style='width:2%; text-align:center' title="Editable">E</td>
           <td style='width:10%; text-align:center'>Etiqueta</td>
           <td style='width:10%; text-align:center'>Valor Editable</td>
           <td style='width:10%; text-align:center'>Tipo Parametría</td>
           <td style='width:15%; text-align:center'>Parametría</td>
           <td style='width:2%; text-align:center' title="Parámetro Interno">I</td>
           <td style='width:14px; text-align:center'>-</td> 
         </tr>
        </table>          
        </div>
        <div id="divParametros" style="width:100%;overflow:auto;"></div>
        <div id='divPie' style='padding-top:10px;width:100%;overflow:hidden;text-align:center;'><img alt='' title='agregar' style="cursor:pointer;cursor:hand" onclick='btnNuevo_Parametro_onclick()' src='/fw/image/transferencia/agregar.png' /></div>
</body>
</html>