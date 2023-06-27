<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Me.contents("filtroXML_transferencia_cab") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_cab'><campos>id_transferencia,nombre,habi,transf_version,timeout,isnull(id_transf_estado,1) as id_transf_estado,isnull(convert(varchar,transf_fe_creacion,103),'') as transf_fe_creacion_f,isnull(convert(varchar,transf_fe_creacion,108),'') as transf_fe_creacion_h,convert(varchar,isnull(transf_fe_modificado,getdate()),103) as transf_fe_modificado_f,convert(varchar,isnull(transf_fe_modificado,getdate()),108) as transf_fe_modificado_h,dbo.rm_nombre_operador(operador) as nombre_operador</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_parametros'><campos>parametro,etiqueta,editable,requerido,tipo_dato</campos><orden>orden,parametro</orden><grupo></grupo><filtro></filtro></select></criterio>")

    '/**Permisos**/
    Me.addPermisoGrupo("permisos_transferencia")
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

var vButtonItems = new Array();
vButtonItems[0] = new Array();
vButtonItems[0]["nombre"] = "Boton_Buscar"
vButtonItems[0]["etiqueta"] = "Seleccionar"
vButtonItems[0]["imagen"] = "seleccion"
vButtonItems[0]["onclick"] = "return buscar()";

var vListButtons = new tListButton(vButtonItems, 'vListButtons')
vListButtons.loadImage("seleccion", '/fw/image/icons/agregar.png')

var win = nvFW.getMyWindow();

function window_onload() 
{

  // mostramos los botones creados
  vListButtons.MostrarListButton()

  indice = $('indice').value
  Transferencia = parent.return_Transferencia()

  //cargar parametros fijos
  var id_transferencia = null

  //var strXML = !Transferencia.detalle[indice].parametros_extra.xml ? "" : Transferencia.detalle[indice].parametros_extra.xml;
  //var objXML = new tXML();
  //if (objXML.loadXML('<?xml version="1.0" encoding="iso-8859-1"?>' + strXML))
  //    id_transferencia = selectSingleNode('/subproceso/@id_transferencia', objXML.xml).value
    
  var id_transferencia = !Transferencia.detalle[indice].parametros_extra.id_transferencia ? null : Transferencia.detalle[indice].parametros_extra.id_transferencia; 
  var async = Transferencia.detalle[indice].parametros_extra.async; 
  TransferenciaCargar(id_transferencia,async)
  // setear los parametros de los valoeres fijos

  window_onresize()
   
}

var winBuscar
function buscar() {
     var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
     winBuscar = w.createWindow({
            title: '<b>Buscar Subproceso</b>',
            url: '/fw/transferencia/transf_buscar.aspx',
            minimizable: false,
            maximizable: false,
            draggable: true,
            width: 900,
            height: 450,
            resizable: true,
            destroyOnClose: true,
            onClose: return_buscar
        })

    winBuscar.options.userData = ""
    winBuscar.showCenter(true)
    }

function return_buscar() {
 
    if (winBuscar.options.userData > 0) {
        
        var id_tranf = winBuscar.options.userData 

        if (id_tranf == Transferencia.id_transferencia)
        {
            alert("Imposible asociar. El subproceso es la misma transferencia")
            return
        }

        if (id_tranf != Transferencia.detalle[indice].parametros_extra.id_transferencia)
            Transferencia["detalle"][indice]["parametros_det"] = [];

        TransferenciaCargar(id_tranf)
    }

 }

function TransferenciaCargar(id_transferencia,async) {
    $('async').checked = async

    if (!id_transferencia)
        return

   var rs = new tRS();
   rs.open(nvFW.pageContents.filtroXML_transferencia_cab, "", "<id_transferencia type='igual'>" + id_transferencia + "</id_transferencia>", "")
   if (!rs.eof()) {
            $('id_transferencia_txt').value = rs.getdata('id_transferencia');
            $('nombre').value = rs.getdata('nombre');
            campos_defs.habilitar('id_transf_estado', true)
            campos_defs.set_value('id_transf_estado', rs.getdata('id_transf_estado'))
            $('transf_version').value = isNULL(rs.getdata('transf_version'), '1.0');
    }


    campos_defs.habilitar('id_transf_estado', false)

    TransferenciaParametrosCargar(id_transferencia)
}

function isNULL(valor, defecto) {
    return (valor == null ? defecto : valor)
}

function transf_parametro_existe(parametro) {

    for (var i = 0; i < parametros_det.length; i++) {
        det = parametros_det[i]
        if (det.param_sub == parametro)
            return i
    }

    return -1
}

var parametros_det = []
function TransferenciaParametrosCargar(id_transferencia) {
    
    parametros_det.length = 0

    var rs = new tRS();
    rs.open(nvFW.pageContents.filtroXML_transferencia_parametros, "", "<id_transferencia type='igual'>" + id_transferencia + "</id_transferencia>", "")
    while (!rs.eof()) {

        pos = parametros_det.length
        parametros_det[pos] = [];
        parametros_det[pos].param_sub = rs.getdata("parametro")
        parametros_det[pos].parametro = ""
        parametros_det[pos].valor = ""
        parametros_det[pos].tipo_asignar = "parametro"
        parametros_det[pos].transf_etiqueta = rs.getdata("etiqueta")
        parametros_det[pos].transf_requerido = rs.getdata("requerido") == 'True'
        parametros_det[pos].transf_editable = rs.getdata("editable") == 'True'
        parametros_det[pos].tipo_dato = rs.getdata("tipo_dato")
        parametros_det[pos].estado = 'N'
        parametros_det[pos].disabled = true

        rs.movenext()
    }
    var msj = ""
    var strXML = !Transferencia.detalle[indice].parametros_extra.asignacion ? "" : Transferencia.detalle[indice].parametros_extra.asignacion;
    var objXML = new tXML();
    if (objXML.loadXML('<?xml version="1.0" encoding="iso-8859-1"?><parametros>' + strXML + "</parametros>" ))
    {
        var parametros = selectNodes('/parametros/parametro', objXML.xml)
        for (var i = 0; i < parametros.length; i++) {

            var param = !selectSingleNode('@param', parametros[i]) ? "" : selectSingleNode('@param', parametros[i]).value
            var valor = !selectSingleNode('@valor', parametros[i]) ? "" : selectSingleNode('@valor', parametros[i]).value
            var tipo_asignar = !selectSingleNode('@tipo_asignar', parametros[i]) ? "parametro" : selectSingleNode('@tipo_asignar', parametros[i]).value
            var param_sub = selectSingleNode('@param_sub', parametros[i]).value

            var pos = transf_parametro_existe(param_sub)
            if (pos >= 0) {

                parametros_det[pos].parametro = param
                parametros_det[pos].valor = valor
                parametros_det[pos].tipo_asignar = tipo_asignar
                parametros_det[pos].estado = 'E'
            }
            else {
                if (msj == "")
                    msj = param_sub
                else
                   msj += ", " + param_sub 
            }


        }
    }

    if (msj == "")
        TransferenciaParametrosDibujar()
    else {

         var elementos = msj.split(",")
        
         if (elementos.length > 0)
            msj = "Los parámetros relacionados: <b>" + msj + "</b>, ya no existen"
         else
            msj = "El parámetro relacionado: <b>" + msj + "</b>, ya no existe"
    
         Dialog.confirm(msj + "<br>¿Desea continuar?" , {
                                      width: 300,
                                      className: "alphacube",
                                      okLabel: "Si",
                                      cancelLabel: "No",
                                      zIndex: 10,
                                      onOk: function(win_local) {
                                                                 TransferenciaParametrosDibujar()
                                                                 win_local.close(); return
                                      },
                                      onCancel: function (win_local) { win_local.close(); parent.win.close();return }
                       });
        }
}

function TransferenciaParametrosDibujar() {
    
    $('divTRAN').innerHTML =""
    
    var strHTML = "<table class='tb1 layout_fixed' id='tbTran'>"
    for (var i = 0; i < parametros_det.length; i++) {

        var arTransfParam = parametros_det[i]
        
        var disabled = ""
        if (arTransfParam.disabled == true)
            disabled = " disabled = 'disabled' "

        var titulo = " " + (arTransfParam.transf_etiqueta == "" ? "" : " <u>Etiqueta:</u> " + arTransfParam.transf_etiqueta + ". ") 
        titulo += " " + (arTransfParam.tipo_dato == "" ? "" : " <u>Tipo Dato:</u> " + arTransfParam.tipo_dato + ". ")

        var titulo_plano = " " + (arTransfParam.transf_etiqueta == "" ? "" : " " + arTransfParam.transf_etiqueta + ": " + arTransfParam.param_sub)
        titulo_plano += " " + (arTransfParam.tipo_dato == "" ? "" : " " + arTransfParam.tipo_dato + ". ")

        if (arTransfParam.transf_requerido)
            titulo = titulo + " <b>Requerido</b>"  

        strHTML += "<tr>"
        strHTML += "<td style='width:10% !Important;text-align:center; vertical-align:middle'>" + parametro_tipo_cargar( i,"tipo_asignar_" + i, arTransfParam.tipo_asignar) + "</td>"

        strHTML += "<td style='width:30% ;text-align:center; vertical-align:middle'>"

        strHTML += "<div id='parametro_param_" + i + "' "
        if (arTransfParam.tipo_asignar != 'parametro')
          strHTML += " style='display:none' "
        strHTML += ">" + parametro_cargar("parametro_" + i, false, arTransfParam.parametro) + "</div>"

        strHTML += "<div id='parametro_valor_" + i + "' "
        if (arTransfParam.tipo_asignar != 'valor')
          strHTML += " style='display:none' "

        strHTML += "><input type='text' name='valor_" + i + "' id='valor_" + i + "'  value ='"+ arTransfParam.valor + "' style='width:100%'/></div></td>"
        strHTML += "<td title='" + titulo_plano  + "' style='width:60% !Important;text-align:left; vertical-align:middle'><div style='width:40%;display:inline-block'><input type='text' style='border:0px;width:100% !Important' " + disabled + " name='tansf_param_" + i + "' id='tansf_param_" + i + "' value='" + arTransfParam.param_sub + "'></div><div style='width:60%;display:inline-block'>" + titulo + "</div></td>"
        strHTML += "<td style='width:14px !Important' id='tdScroll" + i + "'></td>"
        strHTML += "</tr>"
    }

    strHTML += "</table>"

    $('divTRAN').insert({ top: strHTML })
}

function onchange_parametro_tipo_cargar(index) {

    if ($("tipo_asignar_" + index).value == 'valor') {

        $("parametro_param_" + index).hide();
        $("parametro_valor_" + index).show();
        $("parametro_" + i).value = ""

    }

    if ($("tipo_asignar_" + index).value == 'parametro') {

        $("parametro_param_" + index).show();
        $("parametro_valor_" + index).hide();
        $("valor_" + i).value = ""

    }

}


function parametro_tipo_cargar(index, campo, tipo)
{
     var Str_Param = "<select style='width:100%' name='" + campo + "' id='" + campo + "' onchange='onchange_parametro_tipo_cargar("+ index +")'>"
        Str_Param += "<option value='valor' "+ (tipo == "valor" ? 'selected' : '') +">Valor</option>"
        Str_Param += "<option value='parametro' "+ (tipo == "parametro" ? 'selected' : '') +">Parámetro</option>"
      Str_Param += "</select>"     
      
    return Str_Param   
}

function parametro_cargar(campo, disabled, valor)
{
     if (disabled == true)
         disabled = " disabled = 'disabled' "

     var Str_Param = "<select style='width:100%' name='" + campo + "' "+ disabled +" id='" + campo + "'>"
         Str_Param += "<option value=''></option>"
      Transferencia["parametros"].each(function(arreglo,j)
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
    
        arreglo["transf_parametro"] = $("tansf_param_" + j).value
        arreglo["parametro"] = $('parametro_' + j).value
        arreglo["valor"] = $('valor_' + j).value
        arreglo["tipo_asignar"] = $('tipo_asignar_' + j).value 
});

}  


function validar() {

    var strError = ''

    if ($('id_transferencia_txt').value == '')
        strError += 'Seleccione la transferencia a ejecutar</br>'

    parametros_det.each(function (arreglo, j) {

        if (arreglo.estado != 'B' && arreglo.disabled == false) {
            if ($('transf_parametro_' + j).value == '')
                strError += 'Falta definir el parámetro a la definición</br>'
            if ($('parametro_' + j).value == '')
                strError += 'Falta definir un parámetro</br>'
        }

    });

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
    Transferencia["detalle"][indice]["transf_tipo"] = 'TRA'
    Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
    Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
    Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
    
    Transferencia.detalle[indice].parametros_extra.id_transferencia = $('id_transferencia_txt').value
    Transferencia.detalle[indice].parametros_extra.async = $('async').checked

    var strXML = ""
    parametros_det.each(function (arreglo, j) {
        if (($('parametro_' + j).value != "" || $('valor_' + j).value != "") && $("tansf_param_" + j).value != "")
          strXML += "<parametro param='" + $('parametro_' + j).value + "' valor='" + $('valor_' + j).value + "' tipo_asignar='" + $('tipo_asignar_' + j).value + "' param_sub='" + $("tansf_param_" + j).value + "'/>"
    });
    Transferencia.detalle[indice].parametros_extra.asignacion = strXML

    //console.log(strXML)

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

  $('divTRAN').setStyle({ 'height': body_h - divCab_h - tbTarget_h - dif })

  $('tbTran').getHeight() - $('divTRAN').getHeight() > 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)

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
       if(_windows[i].options.title == '<b>Parámetros</b>')
           _windows[i].close()
 
   transferencia_actualizar()
 
   var path = "/FW/transferencia/transferencia_parametros_abm.aspx?id_transferencia="+ Transferencia['id_transferencia'] 
   var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
   win = w.createWindow({ 
                            url: path,
                            title: '<b>Parámetros</b>', 
                            minimizable: true,
                            maximizable: true,
                            draggable: true,
                            width: 1000,
                            height: 400,
                            resizable: true,
                            destroyOnClose: true,
                            onClose: TransferenciaParametrosDibujar
                       });
    
    win.options.Transferencia = Transferencia
    win.showCenter(true)
  }

function abm_transferencia(e) {
    
    if (nvFW.tienePermiso("permisos_transferencia", 1))
      {
        if ( $('id_transferencia_txt').value > 0) 
         {
            if (e.ctrlKey == true) //con la tecla "Ctrl", abre una nueva pestaña
                window.open("/fw/transferencia/transferencia_abm.aspx?id_transferencia=" +  $('id_transferencia_txt').value)
            else 
              {//sino, abre una ventana emergente
                win_transf = window.top.nvFW.createWindow({
                                                            title: '<b>' + $('nombre').value + '</b>',
                                                            minimizable: false,
                                                            maximizable: true,
                                                            maximize:true,
                                                            draggable: true,
                                                            width: 1100,
                                                            height: 600,
                                                            resizable: true,
                                                            onClose: function(w){win_transf.destroy()}
                                                         });
                win_transf.setURL("/fw/transferencia/transferencia_abm.aspx?id_transferencia=" +  $('id_transferencia_txt').value)
                win_transf.showCenter(true)
              //  win_transf.maximize()

              }  
              
         }
       }  
    else
      alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')

}

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
<input type="hidden" name="indice" id="indice" value="<%=indice%>" />
<div id="divCab" style="margin: 0px;padding: 0px;">
     <div id="divMenuAbrir" style="margin: 0px;padding: 0px;"></div>
        <script type="text/javascript">
         //   var DocumentMNG = new tDMOffLine;
         //   var vMenuAbrir = new tMenu('divMenuAbrir', 'vMenuAbrir');
         //   Menus["vMenuAbrir"] = vMenuAbrir
         //   Menus["vMenuAbrir"].alineacion = 'centro';
         //   Menus["vMenuAbrir"].estilo = 'A';
         //   Menus["vMenuAbrir"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
         //   Menus["vMenuAbrir"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Buscar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>buscar()</Codigo></Ejecutar></Acciones></MenuItem>")
         //   vMenuAbrir.loadImage("buscar", '/fw/image/transferencia/buscar.png')
         //   vMenuAbrir.MostrarMenu()
        </script> 
       <table class="tb1">
            <tr>
                 <td style='width:100%'>
                    <table class="tb1">
                            <tr>
                                <td class="Tit2" style="width:5%;text-align:center">Id</td>
                                <td class="Tit2" style="text-align:center" colspan="2">Subproceso</td>
                                <td class="Tit2" style="width:10%;text-align:center">Runtime</td>
                                <td class="Tit2" style="width:10%;text-align:center">Ejecución Asincrona</td>
                                <td class="Tit2" style="width:30%;text-align:center">Estado</td>
                                <td style="width:15%;" rowspan="2">
                                   <div id="divBoton_Buscar" style="width: 100%;"></div>
	                            </td>

                            </tr>
                            <tr>    
                                <td style="width:5%;">
                                    <input type="text" name="id_transferencia_txt" id="id_transferencia_txt" style="width:100%; text-align:center" disabled="disabled"/>
                                </td>
                                <td>
                                    <input type="text" name="nombre" id="nombre" style="width:100%" disabled="disabled" />
                                </td>
                                <td style="text-align:center;">
                                    <img src="/fw/image/icons/editar.png" style="cursor:pointer" onclick="return abm_transferencia(event)"/>
                                </td>
                                <td style="width:10%;">
                                   <select name="transf_version" id="transf_version" style="width:100%" disabled="disabled"><option value="1.0" selected="selected">1.0</option><option value="2.0">2.0</option></select>
                                </td>
                                <td style="width:10%;">
                                    <input type="checkbox" name="async" id="async" style="width:100%" />
                                </td>
                               <td style="width:30%;">
                                  <%= nvCampo_def.get_html_input("id_transf_estado")%>
                                </td>
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
         Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>var</icono><Desc>Parámetros</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_transferencia_parametros()</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenuParametros.loadImage("var", '/fw/image/transferencia/variable.png')
         vMenuParametros.loadImage("nueva", '/fw/image/transferencia/nueva.png')
         vMenuParametros.MostrarMenu()
        </script> 
     <table class='tb1'>
     <tr class='tbLabel0'>
       <td style='text-align:center;white-space:nowrap' colspan="2">Parámetros</td>
       <td style='width:60%; text-align:center;white-space:nowrap' colspan="2">Parámetros de Entrada del Subproceso</td>
       <td style='width:14px; text-align:center' rowspan="2">-</td> 
     </tr>
     <tr class='tbLabel0'>
       <td style='width:10%;text-align:center;white-space:nowrap'>Tipo</td>
       <td style='width:30%;text-align:center;white-space:nowrap'>Parámetros</td>
       <td style='width:24%; text-align:center;white-space:nowrap'>Parámetros de Entrada</td>
       <td style='width:40%; text-align:center;white-space:nowrap'>Detalles</td>
     </tr>
    </table>          
    </div>
    <div id="divTRAN" style="width:100%;overflow:auto;"></div>
</body>
</html>