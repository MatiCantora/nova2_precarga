<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
<head>
<title>Transferencia Seleccionar Parametros</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
            
<script type="text/javascript">

var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:120, okLabel: "cerrar"}); }
var Transferencia
var win = nvFW.getMyWindow()
var indice 

function window_onload() 
{

  Transferencia = win.options.userData.Transferencia
  indice = win.options.userData.indice
  var str=Transferencia["detalle"][indice]["parametros"]
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
     
}

function Aceptar()
{ 
  var strError = ''
  Transferencia["detalle"][indice]["parametros"] = cadena_pasar()
  win.options.Transferencia = Transferencia
  win.options.returnValue = 'OK'
  win.close() 
}

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
    try {

        var dif = Prototype.Browser.IE ? 5 : 5
        var body_height = $$('body')[0].getHeight()
        var divfooter_height = $('divfooter').getHeight()

        var calc = body_height - divfooter_height - dif + "px"

        $('divbody').setStyle({ height: calc })
        

    }
    catch (e) { window.status = e.description }
}

function Cancelar()
{
 win.close()
}
</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style="width:100%;height:100%;overflow:hidden">
     <div id="divbody" style="width:100%">
     <table class='tb1'>
        <tr>
           <td class="tit2" style="width:40%; text-align:center">Todos Los Parámetros<select style="width:100%" size="14" name='cb_parametro_total' id='cb_parametro_total' ondblclick ="btn_agregar_onclick()"></select></td>
           <td  style="vertical-align:middle">
               <input type="button" style="width: 100%" name="btn_agregar" value="Agregar" onclick="btn_agregar_onclick()"/>
               <input type="button" style="width: 100%" name="btn_sacar" value="Quitar" onclick="btn_quitar_onclick()" />
           </td>
           <td class="tit2" style="width:40%; text-align:center">Parámetros Seleccionados<select style="width:100%" size="14" name='cb_parametro_sele' id='cb_parametro_sele' ondblclick ="btn_quitar_onclick()" ></select></td>
        </tr>   
     </table>  
    </div>
     <div id="divfooter" style="width:100%">
       <table class='tb1'>
                <tr>
                    <td style="text-align:center;width:10%;padding-top:10px">&nbsp;</td>
                    <td style="text-align:center;width:35%"><input type="button" style="width:100%" name="btn_Aceptar" value="Aceptar" onclick="Aceptar()" /></td>
                    <td style="text-align:center;width:10%">&nbsp;</td>
                    <td style="text-align:center;width:35%"><input type="button" style="width:100%" name="btn_Cancelar" value="Cancelar" onclick="Cancelar()" /></td>
                    <td style="text-align:center;width:10%">&nbsp;</td>
                </tr>
       </table>          
    </div>
</body>
</html>