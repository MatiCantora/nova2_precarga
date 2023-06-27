<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Me.contents("filtroverTransferencias") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransferencias'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title></title>
 <meta http-equiv="X-UA-Compatible" content="IE=edge">
 <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
 <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
 <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
 <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>

 <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
 <script type="text/javascript" language='javascript' src="/fw/script/window_utiles.js"></script>
<%= Me.getHeadInit()   %>
<script type="text/javascript" language="javascript" >
    //Botones

var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

var vButtonItems = new Array();
vButtonItems[0] = new Array();
vButtonItems[0]["nombre"] = "Boton_Buscar"
vButtonItems[0]["etiqueta"] = "Buscar"
vButtonItems[0]["imagen"] = "buscar"
vButtonItems[0]["onclick"] = "return btnMostrar_transferencia()";

var vListButtons = new tListButton(vButtonItems, 'vListButtons')
vListButtons.loadImage("buscar", '/fw/image/icons/buscar.png')

var win = nvFW.getMyWindow()

function window_onload() 
{
    // mostramos los botones creados
    vListButtons.MostrarListButton()
   
    $('nombre').observe("keydown", function (e) { enter_onkeypress(e) })
   $('id_transf').observe("keypress", function(e) { enter_onkeypress(e) })
   
   $('nombre').focus()
   
    window_onresize()
}


function enter_onkeypress(e) 
{ 
  key = Prototype.Browser.IE ? e.keyCode : e.which
  if (key == 13)
    btnMostrar_transferencia()
}

function btnMostrar_transferencia() 
{
    var cadena_filtro = campos_defs.filtroWhere()

    if ($('nombre').value != '')
        cadena_filtro = cadena_filtro + "<nombre type='like'>%" + $('nombre').value + "%</nombre>"

    if ($('habi').checked == true)
        cadena_filtro = cadena_filtro + "<habi type='igual'>'S'</habi>"
    else
        cadena_filtro = cadena_filtro + "<habi type='igual'>'N'</habi>"

    if ($('id_transf').value != '')
        cadena_filtro = cadena_filtro + "<id_transferencia type='in'>" + $('id_transf').value + "</id_transferencia>"

    if ($('fe_desde_c').value != "")
        cadena_filtro = cadena_filtro + "<transf_fe_creacion type='mas'>convert(datetime,'" + $('fe_desde_c').value + "',103)</transf_fe_creacion>"

    if ($('fe_hasta_c').value != "")
        cadena_filtro = cadena_filtro + "<transf_fe_creacion type='menor'>dateadd(day,1,convert(datetime,'" + $('fe_hasta_c').value + "',103))</transf_fe_creacion>"
 
	if ($('fe_desde_m').value != "")
	    cadena_filtro = cadena_filtro + "<transf_fe_modificado type='mas'>convert(datetime,'" + $('fe_desde_m').value + "',103)</transf_fe_modificado>"

    if ($('fe_hasta_m').value != "")
        cadena_filtro = cadena_filtro + "<transf_fe_modificado type='menor'>dateadd(day,1,convert(datetime,'" + $('fe_hasta_m').value + "',103))</transf_fe_modificado>"

    filtroWhere = "<criterio><select AbsolutePage='1' PageSize='" + setPageSize() + "' cacheControl='Session'><campos></campos><filtro>" + cadena_filtro + "</filtro><orden></orden></select></criterio>"
    nvFW.exportarReporte({
                           filtroXML: nvFW.pageContents.filtroverTransferencias
                        ,filtroWhere: filtroWhere
                          , path_xsl: "\\report\\transferencia\\verTransferencias\\HTML_verTransferencias.xsl"
                       , salida_tipo: "adjunto"                    
                        , formTarget: "iframeSolicitud"
              , nvFW_mantener_origen: true
                  // , bloq_contenedor: $('iframeSolicitud')
                    , cls_contenedor: "iframeSolicitud"
                        }) 

 }

function setPageSize() {
    var pagesize = 100
    try {
        pagesize = Math.round($('iframeSolicitud').getHeight() / ($('nombre').getHeight()) - 1, 0)
        //restamos la cabecera y pie considero 4 el como las row de los mismos
        pagesize = pagesize - 2
    }
    catch (e) { }

    return pagesize
}

function seleccion(valor,desc) 
{
    win.options.userData = valor
    win.options.id_transferencia = valor
    win.options.nombre = desc
    win.close()
}


function window_onresize()
{
	try{

		var dif = Prototype.Browser.IE ? 5 : 2
		var body_height = $$('BODY')[0].getHeight()
		var cabe_height = $('cabecera').getHeight()		
		if($('cabecera').style.display == 'none')
		    cabe_height = 0
        $('iframeSolicitud').setStyle({height: body_height - cabe_height-dif})
   }catch(e){}
} 

function enter_onkeypress(e) 
{ 
  key = Prototype.Browser.IE ? e.keyCode : e.which
  if (key == 13)
    btnMostrar_transferencia()
}

function hoy() {
    return FechaToSTR(new Date()) 
}

</script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width:100%; height:100%; overflow:hidden">
 <table class="tb1" id="cabecera" cellspacing="0" cellpadding="0">
	    <tr>
		    <td>
                <table class="tb1">
                    <tr class="tbLabel">	
					    <td style="width: 100px; text-align: center;" rowspan="2">Nro.</td>
					    <td style="text-align: center;" rowspan="2">Nombre</td>
					    <td style="width: 220px;text-align: center;" colspan="2">Fecha Creación</td>
                        <td style="width: 220px;text-align: center;" colspan="2">Fecha Modificación</td>
                        <td style="width: 120px; text-align: center;" rowspan="2">Operador</td>
                        <td style="width: 50px; text-align: center;" rowspan="2">Hab.</td>
				    </tr>

                    <tr class="tbLabel">
                        <td style="width: 110px; text-align: center;">Desde</td>
                        <td style="width: 110px; text-align: center;">Hasta</td>
                        <td style="width: 110px; text-align: center;">Desde</td>
                        <td style="width: 110px; text-align: center;">Hasta</td>
                    </tr>

                    <tr>
					    <td style="width: 100px;">
                            <input type="text" style="width: 100%" id="id_transf" name="id_transf" onkeypress="return valDigito(event)" autocomplete="off"/>
					    </td>
					    <td>
                            <input type="text" size="20" style="width: 100%" id="nombre" name="nombre" autocomplete="off"/>
					    </td>
					    <td id="td_fe_desde_c" style="width: 110px;">
						    <script type="text/javascript">
                                campos_defs.add('fe_desde_c', { target: 'td_fe_desde_c', enDB: false, nro_campo_tipo: 103 })
						    </script>                        
					    </td>
					    <td id="td_fe_hasta_c" style="width: 110px;"> 
						    <script type="text/javascript">
                                campos_defs.add('fe_hasta_c', { target: 'td_fe_hasta_c', enDB: false, nro_campo_tipo: 103 })
						    </script>
					    </td>
					    <td id="td_fe_desde_m" style="width: 110px;">
						    <script type="text/javascript">
                                campos_defs.add('fe_desde_m', { target: 'td_fe_desde_m', enDB: false, nro_campo_tipo: 103 })
						    </script>                        
					    </td>
					    <td id="td_fe_hasta_m" style="width: 110px;">
						    <script type="text/javascript">
                                campos_defs.add('fe_hasta_m', { target: 'td_fe_hasta_m', enDB: false, nro_campo_tipo: 103 })
						    </script>
					    </td>
		                <td style="width: 120px;">
                            <% = nvCampo_def.get_html_input("nro_operador") %>
		                </td>  
					    <td style="width: 50px; text-align: center;">
                            <input type="checkbox" style="cursor: pointer;" id="habi" name="habi" checked="checked" />
					    </td>
		            </tr>
                </table>
	        </td>
	        <td style="width:100px">
                <div id="divBoton_Buscar" style="width: 100%;"></div>
	        </td>
        </tr>
    </table>
<iframe id="iframeSolicitud" name="iframeSolicitud" src="/fw/enBlanco.htm" frameborder="0" style="width:100%; height:100%; border:0;overflow:hidden" ></iframe> 
</body>
</html>