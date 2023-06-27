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
 <script type="text/javascript">
    
var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 


function isNULL(valor, sinulo)
{
  valor = valor == null ? sinulo: valor
  return valor
}

var win = nvFW.getMyWindow()
var Transferencia 
var detalle 
var indice
var oSwitch = {};

function window_onload() 
{
     Transferencia = parent.return_Transferencia() 
     detalle = parent.return_detalle()
     indice = parent.return_indice()
    
     var agregar = $(document.createElement('img'));
     agregar.setAttribute('alt', 'Agregar');
     agregar.setAttribute('title', 'Agregar ' + detalle.transf_tipo);
     agregar.setAttribute('src', '/FW/image/tnvRect/agregar.png');
     agregar.setAttribute('style', 'z-index:1000;cursor:hand;cursor:pointer');
     agregar.observe('click', function (e) {

         condicion_nueva()

     });
     $('tdAgregar').insert({ bottom: agregar });

     var select = $('selDefault');
     detalle.relations.each(function (relation, index) {
         if (relation.src == detalle && relation.dest.transf_tipo != 'annotation' && relation.dest.transf_tipo != 'SSC') {
             var option = $(document.createElement('option'));
             var title_tmp = relation.title == '' ? relation.dest.title + ' [' + relation.dest.transf_tipo + ']' : relation.title;
             option.update(title_tmp);
             option.selected = detalle.amIDefault(relation);// ver!!!!  parametros_xml
             option.setAttribute('value', index);
             select.insert({ bottom: option });
         }
     });

     oSwitch = {};
     oSwitch.expresion = detalle.parametros_extra.switch.expresion;
     oSwitch.campo_def = detalle.parametros_extra.switch.campo_def;
     oSwitch.id_param = detalle.parametros_extra.switch.id_param;
     oSwitch.tipo_dato = detalle.parametros_extra.switch.tipo_dato;
     oSwitch.case = detalle.parametros_extra.switch.case;

      var id = "sel_parametro0_0"
      $('divSwitch').insert({ top: parametro_cargar(true, oSwitch.expresion, id) })    
      if (oSwitch.campo_def  != "")
          cargar_campo_def(id)
    
      var objScript = new tScript();
      oSwitch.case.each(function (arreglo, j) {
          if (arreglo.evaluacion != '' && arreglo.evaluacion != undefined)
          arreglo.evaluacion = objScript.script_to_string(arreglo.evaluacion)
      });
  
      
     condicion_agregar_dibujar()

     window_onresize()
 
}
     

function cargar_campo_def(id) {
    
     var valor = $(id).value

     oSwitch.expresion = valor
     oSwitch.campo_def = ""
     oSwitch.id_param = ""
     oSwitch.tipo_dato = ""

     Transferencia["parametros"].each(function (arreglo, i) {
         if (valor == arreglo.parametro) {

             oSwitch.tipo_dato = arreglo.tipo_dato

             if (arreglo.campo_def != "") {
                 oSwitch.campo_def = arreglo.campo_def
                 oSwitch.id_param = ""
             }

             if (arreglo.id_param != "" && valor == arreglo.parametro) {
                 oSwitch.campo_def = ""
                 oSwitch.id_param = arreglo.id_param
             }
         }
     });

     if (oSwitch.campo_def != "")
         campos_defs.add(oSwitch.campo_def, { despliega: 'arriba', enDB: true, target: "tdOculto" })


     condicion_agregar_dibujar()

     }

function parametro_cargar(expresion,parametro, i) {

    var Str_CampoDef = "<select style='width:100%' name='" + i + "' id='" + i + "'"
    var strClass = ""

     if (expresion) 
         Str_CampoDef += " onchange=\"return cargar_campo_def('" + i + "')\""

     Str_CampoDef += "><option value=''></option>"
     var seleccionado = ''
     Transferencia["parametros"].each(function (arreglo, i) {

        seleccionado  = arreglo.parametro == parametro.toLowerCase() ? 'selected' : ''

        valor = arreglo.parametro 

        Str_CampoDef += "<option value='" + valor + "' " + seleccionado + ">" + valor + "</option>"
     });

     Str_CampoDef += "</select>"

  return Str_CampoDef

}

     
function condicion_nueva()
{

    actualizar()

     indice = oSwitch.case.length;
     oSwitch.case[indice] = new Array();
     oSwitch.case[indice]["RectId"] = '0'
     oSwitch.case[indice]["valor"] = ''
     oSwitch.case[indice]["condicion"] = ''
     oSwitch.case[indice]["evaluacion"] = ''
     oSwitch.case[indice]["descripcion"] = ''

    condicion_agregar_dibujar()
}

function condicion_agregar_dibujar()
{
      $('divCase').innerHTML = ""
 
      var strHTML = "<table class='tb1' style='width:100%' id='tbParametros'>"  
      var i = 0    
      oSwitch.case.each(function(arreglo,j)
      { 
          if (arreglo.RectId.indexOf("$ELI$") == -1) {
          arreglo["orden"]  = i
          strHTML += "<tr>"
          strHTML += "<td style='width:8%'>&nbsp;</td>"      
          strHTML += "<td style='width:5%; text-align:center; vertical-align:middle'>" + arreglo["orden"] + "</td>"         
          strHTML += "<td style='width:25%; text-align:center; vertical-align:middle'>"
          strHTML += armar_condiciones(arreglo["condicion"], j)
          strHTML += "</td>"
          strHTML += "<td id='td_condicion" + j + "' style='text-align:left; vertical-align:middle'></td> "
          strHTML += "<td style='width:8%; text-align:center; vertical-align:middle'><img src='/FW/image/tnvRect/delete.png' onclick='btnEliminar_Parametro_onclick(" + j + ")' style='cursor:hand;cursor:pointer' border='0' align='absmiddle' hspace='1'/></td>"
          strHTML += "<td style='width:14px !Important' id='tdScroll" + j + "'></td>"
          strHTML += "</tr>"
          
          i++ 
          }
          });            
      strHTML += "</table>"
    
      $('divCase').insert({ top: strHTML })
    

      var filtroXML = ""
      var filtroWhere = ""
      var nro_campo_tipo = 1
      oSwitch.case.each(function (arreglo, j) {
          if (arreglo.RectId.indexOf("$ELI$") == -1) {
              filtroXML = ""
              filtroWhere = ""
              nro_campo_tipo = 1

              if (oSwitch.campo_def != "") {
                  filtroXML = campos_defs.items[oSwitch.campo_def].filtroXML
                  filtroWhere = campos_defs.items[oSwitch.campo_def].filtroWhere
                  nro_campo_tipo = campos_defs.items[oSwitch.campo_def].nro_campo_tipo
                  campos_defs.add(oSwitch.expresion + j, { target: 'td_condicion' + j, nro_campo_tipo: nro_campo_tipo, filtroXML: filtroXML, filtroWhere: filtroWhere, despliega: 'abajo', enDB: false }) + " </td> "
              }
              else
                  campos_defs.add(oSwitch.expresion + j, { target: 'td_condicion' + j, nro_campo_tipo: getTipo_dato(oSwitch.tipo_dato), enDB: false })

              campos_defs.set_value(oSwitch.expresion + j, arreglo.valor)
          }
      });
      
    window_onresize()

}


     function getTipo_dato(tipo_dato) {
         var res
         switch (tipo_dato)
         {
             case 'int':
                 res = 100
                 break;
             case 'datetime':
                 res = 103
                 break;
             case 'money':
                 res = 102
                 break;
             default:
                 res = 104
                 break;
         }

         return res

     }

function armar_condiciones(condicion_valor, orden)
{
     var Str_Condicion = "<select style='width:100%' name='sel_condicion" + orden + "' id='sel_condicion" + orden + "'>"

     condicion = [];
     condicion[0] = [];
     condicion[0].texto = 'Igual ='
     condicion[0].valor = '=='
     condicion[1] = [];
     condicion[1].texto = 'Mayor >'
     condicion[1].valor = '>'
     condicion[2] = [];
     condicion[2].texto = 'Menor <'
     condicion[2].valor = '<'
     condicion[3] = [];
     condicion[3].texto = 'Mayor igual >='
     condicion[3].valor = '>='
     condicion[4] = [];
     condicion[4].texto = 'Menor Igual <='
     condicion[4].valor = '<='
     condicion[5] = [];
     condicion[5].texto = 'Distinto <>'
     condicion[5].valor = '!='
     condicion[6] = [];
     condicion[6].texto = 'Evaluación'
     condicion[6].valor = ''

    condicion.each(function(arreglo,i)
    {
    var seleccionado = ''
        if (condicion_valor == arreglo.valor)
        seleccionado = 'selected="selected"'
        Str_Condicion += "<option value='" + arreglo.valor + "' " + seleccionado + ">" + arreglo.texto + "</option>"
    });
    Str_Condicion += "</select>"     

    return Str_Condicion
}

function btnEliminar_Parametro_onclick(j) {

    actualizar()
    
    Dialog.confirm( "¿Desea borrar la condición seleccionado?", {   width: 300,
                                                                 className: "alphacube",
                                                                 okLabel: "Si",
                                                                 cancelLabel: "No",
                                                                 onOk: function (win) {
                                                                                      oSwitch.case[j].RectId = "$ELI$" + oSwitch.case[j].RectId
                                                                                      condicion_agregar_dibujar()
                                                                                      win.close(); return
                                                                                    },
                                                                 onCancel: function(win) { win.close(); return }
                                                              });
}

var objScript = new tScript();
function actualizar()
{
    oSwitch.case.each(function (arreglo, j) {
        if (arreglo.RectId.indexOf("$ELI$") == -1) {
            if (campos_defs.items[oSwitch.expresion + j]) {
                if (oSwitch.expresion != "") {
                    arreglo.valor = campos_defs.value(oSwitch.expresion + j)
                }
                arreglo.condicion = $('sel_condicion' + j).value
                //arreglo.evaluacion = oSwitch.expresion + " " + $('sel_condicion' + j).value + " " + campos_defs.value(oSwitch.expresion + j)
                arreglo.descripcion = oSwitch.expresion + " " + $('sel_condicion' + j).options[$('sel_condicion' + j).selectedIndex].text + " " + campos_defs.value(oSwitch.expresion + j)

                if ($('sel_condicion' + j).value != '' && (oSwitch.tipo_dato == 'varchar' || oSwitch.tipo_dato == 'datetime'))
                    arreglo.evaluacion = oSwitch.expresion + " " + $('sel_condicion' + j).value + " " + objScript.string_to_script(campos_defs.value(oSwitch.expresion + j))
                else
                    arreglo.evaluacion = oSwitch.expresion + " " + campos_defs.value(oSwitch.expresion + j)
            }
        }
    });
    
}  

function window_onresize()
{
 try
 {
  var dif = Prototype.Browser.IE ? 5 : 2
     var body_h = $$('body')[0].getHeight()
     var divCabe_h = $('divCabe').getHeight()

     var alto = 0

     //contenedores = $('bodySSS').querySelectorAll(".conteiner")
     //for (var i = 0; i < contenedores.length; i++) {
     //    if (contenedores[i].style.display != 'none')
     //        alto += contenedores[i].getHeight()
     //}

     var calculo = body_h - divCabe_h - dif

     $('divCase').setStyle({ 'height': (calculo) + 'px' })

 }
 catch(e){}
}


function validar(){
    var strError = ''
    return strError
}

function guardar() {

    actualizar();

    detalle.parametros_extra.switch = {};
    detalle.parametros_extra.switch = oSwitch;

    if ($('selDefault').value != "")
        if (detalle.relations[$('selDefault').value] != undefined) {
            detalle.defaultArrow = detalle.relations[$('selDefault').value];
        }
        else
            gateway.defaultArrow = false;

    return Transferencia
}

//function Aceptar()
// {
//    actualizar();
  

     
//     //oSwitch.case.each(function (arreglo, j) {
//     //    if (arreglo.RectId.indexOf("$ELI$") == -1) {
//     //        if ($('sel_condicion' + j).value != '' && (oSwitch.tipo_dato == 'varchar' || oSwitch.tipo_dato == 'datetime'))
//     //            arreglo.evaluacion = oSwitch.expresion + " " + $('sel_condicion' + j).value + " " + objScript.string_to_script(campos_defs.value(oSwitch.expresion + j))
//     //        else
//     //            arreglo.evaluacion = oSwitch.expresion + " " + campos_defs.value(oSwitch.expresion + j)
//     //    }
//     //});

//     detalle.parametros_extra.switch = {};
//     detalle.parametros_extra.switch = oSwitch;

//    return Transferencia
//  }

</script>
</head>
<body id="bodySSS" onload="return window_onload()" onresize="return window_onresize()" style="width:100% !Important; height: 100% !Important; overflow: hidden; margin: 0px; padding: 0px; ">
      <input type="hidden" name="id_transferencia" id="id_transferencia" value="<%= id_transferencia %>"/> 
    <div id="divCabe" style="width:100%">
    <table class='tb1'>
         <tr class="conteiner">
           <td class="Tit1" colspan="3" style='text-align:left'>Seleccione un parámetro a evaluar:</td>
           <td class="Tit1" colspan="3" style='text-align:left'>Seleccione una tarea en caso que <b>no</b> se cumple la evaluacion:</td>
         </tr>
         <tr class="conteiner">
           <td class="Tit4" style='width:8%; text-align:center'><b>Parámetro:</b></td>
           <td style='text-align:center'><div id="divSwitch" style="width:100%;margin: 0px;padding: 0px;"></div></td>
           <td style='width:5%' id="tdAgregar"></td>
           <td style='display:none' id="tdOculto"></td>
           <td class="Tit4" style='width:8%; text-align:center'><b>Tarea:</b></td>
           <td style='width:40%; text-align:center'><select id="selDefault" style="width:100%"><option value=""></option></select></td>
         </tr>
     </table>
     <table class='tb1'>
         <tr class="conte">
            <td style="width:8%">&nbsp;</td>
            <td>
            <table class='tb1'>
             <tr class='tbLabel'>
               <td style='width:5%; text-align:center'>-</td>
               <td style='width:25%; text-align:center'>Condición</td>
               <td style='text-align:center'>Parámetro</td>
               <td style='width:8%; text-align:center'>-</td>
               <td style='width:14px; text-align:center'>-</td> 
             </tr>
            </table>          
            </td>
        </tr>
     </table>
     </div>
     <div id="divCase" style="width:100%;overflow:auto;"></div>

    <%-- <table class='tb1'>
         <tr class="conteiner">
           <td class="Tit1" colspan="4" style='text-align:left'>Sino cumple:</td>
         </tr>
         <tr class="conteiner">
           <td class="Tit4" style='width:10%; text-align:center'><b>Tarea:</b></td>
           <td style='width:30%; text-align:center'><select id="selDefault" style="width:100%"><option value=""></option></select></td>
           <td>&nbsp;</td>
         </tr>
     </table>--%>
</body>
</html>