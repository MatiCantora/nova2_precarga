<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Me.contents("filtroXML_Transferencia_parametros_EQV_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_parametros_EQV_def'><campos>*</campos><orden>orden desc</orden><grupo></grupo><filtro></filtro></select></criterio>")

%>
<html>
<head>
<title>Transferencia Detalle INF</title>
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
<% = Me.getHeadInit()%>
<script type="text/javascript">

var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:120, okLabel: "cerrar"}); }

var indice
var Transferencia

function window_onload() 
{
  indice = $('indice').value
  Transferencia = parent.return_Transferencia()
  
  EQV_cargar()
  window_onresize()

}

var arEQV = new Array()
function EQV_cargar()
{  
    var indice
    var rs = new tRS();
    rs.open(nvFW.pageContents.filtroXML_Transferencia_parametros_EQV_def, "", "", "")
    while(!rs.eof())
        {  
          indice = arEQV.length
          arEQV[indice] = new Array()
          arEQV[indice].variable_def = rs.getdata("variable_def") 
          arEQV[indice].descripcion = rs.getdata("descripcion") 
          arEQV[indice].io = parseInt(rs.getdata("io"))
          arEQV[indice].parametro = ""
          rs.movenext()
        }
   
   EQV_dibujar()     
}

function EQV_existe_Parametro(parametro,valor_eqv)
{  
   for (var i = 0; i < Transferencia["detalle"][indice]["parametros_det"].length ; i++)
     {
       det = Transferencia["detalle"][indice]["parametros_det"][i]
       if(det["valor_eqv"] == valor_eqv && det["parametro"] == parametro )
          return true
     } 
   
   return false  
}

function EQV_dibujar()
{  
    var io_des 
    var strHTML = "<table class='tb1'>"  
    for(var i = 0; i< arEQV.length; i++)
        {  
          io_des = ''
          switch(arEQV[i].io)
          {
           case 1:
              io_des = 'Entrada'    
           break   
           case 2:
              io_des = 'Salida'    
           break   
           case 3:
              io_des = 'Entrada/Salida'          
           break   
          }
          
          strHTML += "<tr>"
          strHTML += "<td style='width:248px !Important;text-align:left; vertical-align:middle'><input type='text' style='width:100% !Important' disabled = 'disabled' name='" + arEQV[i].variable_def + "' id='" + arEQV[i].variable_def + "' value='" + arEQV[i].descripcion + " - " + io_des + "'></td>"          
          strHTML += "<td style='text-align:center; vertical-align:middle'>" + parametros_cargar(arEQV[i].variable_def,arEQV[i].io) + "</td>"                                                                      
          strHTML += "</tr>"
        }
    strHTML += "</table>"
      
    $('divEQV').insert({top:strHTML})    
}

function parametros_onchange(e,io)
{
  var obj = Event.element(e)
   
  for(var i = 0; i< arEQV.length; i++)
      {
        obj2 = $('sel_' + arEQV[i].variable_def)
        if(obj2.value == obj.value && obj2.id != obj.id && obj2.value != 'vacio')
          { 
           if((arEQV[i].io > 1 && io > 1))
            {
             alert('el parametro ya se selecciono en el valor EQV: '+ arEQV[i].variable_def)
             obj.value = ''
            }
          }  
      }
 
}


function parametros_cargar(variable,io)
{
      var Str_Param = "<select style='width:100%' id='sel_" + variable + "' name='sel_" + variable + "' onchange='return parametros_onchange(event," + io + ")'>"
          Str_Param += "<option value='vacio'></option>"
      Transferencia["parametros"].each(function(arreglo,j)
          { 
           var seleccionado = ''
           seleccionado = EQV_existe_Parametro(arreglo['parametro'],variable) ? 'selected' : ''
           Str_Param += "<option value='" +  arreglo['parametro'] + "' " + seleccionado + ">" + arreglo['parametro'] + "</option>"
        });

      Str_Param += "</select>"     
      
    return Str_Param   
}

function transferencia_actualizar()
{
 //Actualiza Parametros
  Transferencia["detalle"][indice]["parametros_det"] = null
  Transferencia["detalle"][indice]["parametros_det"] = new Array();
 
  for(var i = 0; i< arEQV.length; i++)
        {  
           variable = arEQV[i].variable_def
           parametro = $('sel_'+ variable).value
          
           if(parametro != 'vacio')
            {
             var nuevo = Transferencia["detalle"][indice]["parametros_det"].length
             Transferencia["detalle"][indice]["parametros_det"][nuevo] = new Array();
             Transferencia["detalle"][indice]["parametros_det"][nuevo]["parametro"] = parametro
             Transferencia["detalle"][indice]["parametros_det"][nuevo]["valor_eqv"] = variable
            } 
        }
 }  


function validar() {
    var strError = ''

   
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
    Transferencia["detalle"][indice]["transf_tipo"] = 'EQV'
    Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
    Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
    Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value

    return Transferencia 
}

//function Aceptar()
//{ 
// transferencia_actualizar()
     
// if (indice == -1)
//   {
//    Transferencia["detalle"].length++
//    indice = Transferencia["detalle"].length -1 
//    Transferencia["detalle"][indice] = new Array();
//   }

// Transferencia["detalle"][indice]["orden"] = indice
// Transferencia["detalle"][indice]["transf_tipo"] = 'EQV'       
// Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
// Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
// Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
   
// return Transferencia 
//}

function window_onresize()
{
 try
 {
  var dif = Prototype.Browser.IE ? 5 : 2
  var body_h = $$('body')[0].getHeight()
  var divCab_h = $('divCab').getHeight()
  $('divEQV').setStyle({'height': body_h - divCab_h - dif })
 }
 catch(e){}
}

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
<form action="" name="frmDetalle_XLS" style="width:100%;height:100%;overflow:hidden">
<input type="hidden" name="indice" id="indice" value="<%=indice%>" />
<div id="divCab" style="margin: 0px;padding: 0px;">
     <table class='tb1'>
     <tr class='tbLabel'>
       <td style='width:250px;text-align:center'>Variables</td>
       <td style='text-align:center'>Parámetro</td>
     </tr>
    </table>          
    </div>
    <div id="divEQV" style="width:100%;overflow:auto;"></div>
 </form>
</body>
</html>