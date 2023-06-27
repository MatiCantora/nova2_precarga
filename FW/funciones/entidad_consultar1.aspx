<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Dim nro_rol = nvUtiles.obtenerValor("nro_rol", "2")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consulta Entidades</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript">

var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

var vButtonItems = {};
vButtonItems[0] = new Array();
vButtonItems[0]["nombre"] = "Buscar";
vButtonItems[0]["etiqueta"] = "Buscar";
vButtonItems[0]["imagen"] = "buscar";
vButtonItems[0]["onclick"] = "return Aceptar()";

var vListButtons = new tListButton(vButtonItems, 'vListButtons')
vListButtons.loadImage("buscar", '/fw/image/icons/buscar.png')                                                // "Imagenes" está definida en "pvUtiles.asp"

var Parametros = new Array();
var razon_social

var win = nvFW.getMyWindow()

function window_onload() 
{
  window_onresize()
   
// mostramos los botones creados
vListButtons.MostrarListButton()  
var Parametros = window.dialogArguments
}

function AgregarEntidad(nro_entidad,apellido,nombres,documento,nro_docu,sexo,tipo_docu)
{ 
 var Entidad = new Array()
 Entidad["nro_entidad"] = nro_entidad
 Entidad["apellido"] = apellido
 Entidad["nombres"] = nombres
 Entidad["documento"] = documento
 Entidad["nro_docu"] = nro_docu 
 Entidad["sexo"] = sexo
 Entidad["tipo_docu"] = tipo_docu
 window.parent.win.returnValue=Entidad
 window.parent.win.close();
}

function Aceptar()      // Realiza la busqueda de Entidades
{
// if($('apellido').value.length > 1 ||   $('nro_docu').value != '')
//  { 
    nro_docu = $('nro_docu').value != '' ? "<nro_docu type='igual'>'" + $('nro_docu').value + "'</nro_docu>"  : ''
    nro_docu = nro_docu != '' ? nro_docu : ''
    apellido = $('apellido').value  != '' ? "<apellido type='like'>%" + $('apellido').value + "%</apellido>" : ''
    nombres = $('nombres').value != '' ? "<nombres type='like'>%" + $('nombres').value + "%</nombres>" : ''
    
    nvFW.exportarReporte({   filtroXML: "<criterio><select vista='verEntidades'><campos>nro_entidad,apellido,nombres,'DNI' as documento,nro_docu,sexo,tipo_docu,cuit</campos><orden>nro_entidad</orden><filtro>" + apellido + nombres + nro_docu + "</filtro><grupo></grupo></select></criterio>",
                              path_xsl: 'report\\funciones\\entidades\\HTML_entidades.xsl',
                            formTarget: 'iframeRes',
                       bloq_contenedor: $('iframeRes'),
                        cls_contenedor: 'iframeRes'
                       })
  //}
 //else
 //  alert('Ingrese mas de tres digitos.')      
}

function strNombreCompleto_onkeypress(e) 
{
  var key = Prototype.Browser.IE ? e.keyCode : e.which;
  if (key == 13)
    Aceptar()
}

function dni_onkeypress(e) 
{
 var key = Prototype.Browser.IE ? e.keyCode : e.which;
 if (key == 13)
   Aceptar()
 else
   valDigito(e)
}

function window_onresize()
    {
     var dif = Prototype.Browser.IE ? 5 : 2
     body_heigth = $$('body')[0].getHeight()
     cab_heigth = $('tbFiltro').getHeight()
     try
     {
      $('iframeRes').setStyle({'height': body_heigth - cab_heigth - dif})
     }
     catch(e){}
    } 
    
function entidad_seleccionar(nro_entidad, apellido, nombres, documento, nro_docu, sexo, tipo_docu,cuit)
{
    win.options.userData.entidad = {nro_entidad: nro_entidad, apellido: apellido, nombres: nombres, documento: documento, nro_docu: nro_docu, sexo: sexo, tipo_docu: tipo_docu,cuit:cuit}
    win.close()
}

var win_abm_entidad
function nueva_entidad()  // Llama la modal para editar las Entidades
{
    /*if ((permisos_entidades & 2) == 0)          // Controlo si tiene permisos de Modificación Entidad             
    {
        alert ('No Tiene Permisos para realizar esta Acción, <br>Consulte con el Administrador del Sistema');
    }
    else    
    {*/
    win_abm_entidad = window.top.nvFW.createWindow({
        className: 'alphacube',
        url: '/FW/entidades/rol_abm.aspx?nro_rol=<%= nro_rol%>&nro_entidad=',
        title: '<b>ABM Entidad</b>',
        minimizable: false,
        maximizable: false,
        draggable: false,
        width: 900,
        height: 420,
        resizable: false
    })
    win_abm_entidad.showCenter(true)
    //}
}

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height:100%; overflow: hidden">
    <form action="" name="frmFiltro_entidad" id="frmFiltro_entidad" style="width: 100%; height:100% ; overflow: hidden">
        <div id="divMenuEntidad"></div>
        <script type="text/javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenuEntidad = new tMenu('divMenuEntidad', 'vMenuEntidad');
            Menus["vMenuEntidad"] = vMenuEntidad
            Menus["vMenuEntidad"].alineacion = 'centro';
            Menus["vMenuEntidad"].estilo = 'A';
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_entidad()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/security/nueva.png')
            vMenuEntidad.MostrarMenu()
        </script>

        <table id="tbFiltro" class="tb1" style='width:100%'>
            <tr class="tblabel">
                <td style="width: 25%">Documento</td>
                <td style="width: 25%">Apellido</td>
                <td style="width: 25%">Nombre</td>
                <td rowspan="3" style="text-align:center"><div id="divBuscar" style="width:100%"></div></td>
            </tr>
            <tr>
                <td><input name="nro_docu" id="nro_docu" style="width: 100%" onkeypress="return dni_onkeypress(event)" /></td>
                <td><input name="apellido" id="apellido" style="width: 100%" onkeypress="return strNombreCompleto_onkeypress(event)" /></td>
                <td><input name="nombres" id="nombres" style="width: 100%" onkeypress="return strNombreCompleto_onkeypress(event)" /></td>
            </tr>
        </table>
    <iframe name="iframeRes" id="iframeRes" style="width: 100%; height: 100%; overflow: hidden" frameborder="0" src="/fw/enBlanco.htm"></iframe>
  </form>

</body>
</html>
