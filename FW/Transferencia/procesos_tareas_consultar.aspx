<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Response.Expires = 0
    Dim estado = nvUtiles.obtenerValor("estado", "")
    Dim id_transferencia = nvUtiles.obtenerValor("id_transferencia", "")
    Dim modo = nvUtiles.obtenerValor("modo", "")

    'debe tener el permiso para editar el modulo
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If Not op.tienePermiso("permisos_procesos_tareas", 1) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.response()
    End If

    If (modo.ToUpper = "ISALIVE") Then

        Dim Err = New tError()
        Err.params("isAlive") = "False"
        Err.params("momento") = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss")

        Dim id_transf_log As Integer = nvUtiles.obtenerValor("id_transf_log", "")

        Try
            Err.params("isAlive") = nvFW.nvTransferencia.nvTransfUtiles.getTransfStatusRunThread(id_transf_log).ToString
        Catch ex As Exception

            Err.parse_error_script(ex)
            Err.numError = -99
            Err.mensaje = "Error al consultar el estado de la transfencia log " & id_transf_log.ToString

        End Try

        Err.response()

    End If

    If (modo.ToUpper = "LISTISALIVE") Then
        nvFW.nvTransferencia.nvTransfUtiles.getListTransfStatusRunThread().response()
    End If

    'If (modo.ToUpper = "GUARDAR") Then

    '    Dim Err As tError = New tError()
    '    Try
    '        Dim id_transf_log = nvUtiles.obtenerValor("id_transf_log", "")
    '        nvDBUtiles.DBExecute("update transf_log_cab set fe_fin = GETDATE() , estado = 'error', operador = dbo.rm_nro_operador() where id_transf_log =" + id_transf_log)
    '        nvDBUtiles.DBExecute("update transf_log_det set fe_fin = GETDATE() , estado_det = 'error' where estado_det='Pendiente' and id_transf_log =" + id_transf_log)
    '        Err.numError = 0
    '        Err.mensaje = ""

    '    Catch ex As Exception
    '        Err.parse_error_script(ex)
    '        'Err.error_script(ex)
    '    End Try

    '    Err.response()
    'End If

    Dim tiene_ejecuciones As Boolean
    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT  count(*) as ejecutando  FROM verTransf_log_cab WHERE estado='ejecutando' and  operador =" & nvApp.operador.operador.ToString)
    If (rs.EOF = False) Then
        tiene_ejecuciones = IIf(rs.Fields("ejecutando").Value > 0, True, False)
    End If
    nvDBUtiles.DBCloseRecordset(rs)

    '******* vistas encriptadas 
    Me.contents("filtro_seg_ejecucion") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_cab' AbsolutePage='1' PageSize='50' cacheControl='Session'><campos>*</campos><filtro><estado type='like'>ejecutando</estado><operador type='igual'>" & nvApp.operador.operador.ToString & "</operador></filtro><orden>fe_inicio desc</orden></select></criterio>")
    Me.contents("filtroTransf_procesos_tareas_consultar") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='transf_procesos_tareas_consultar'><parametros><tipo_retorno></tipo_retorno><select><filtro></filtro><orden></orden></select></parametros></procedure></criterio>")

    '*********** permisos
    Me.addPermisoGrupo("permisos_seguridad")
    Me.addPermisoGrupo("permisos_transferencia")
    Me.addPermisoGrupo("permisos_procesos_tareas")
    Me.addPermisoGrupo("permisos_transferencia_ejecutar")

    Me.contents("hoy") = Now

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <%--<link href="/fw/transferencia/css/mnuEstado.css" type="text/css" rel="stylesheet" />--%>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>

    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <%--<script type="text/javascript" language='javascript' src="/fw/script/window_utiles.js"></script>--%>
    <script type="text/javascript" language='javascript' src="/fw/transferencia/script/transf_seg_utiles.js"></script>

    <%= Me.getHeadInit()   %>
    <style type="text/css">
    
    </style>

    <script type="text/javascript" language="javascript" >
    //Botones

var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

var vButtonItems = {};
vButtonItems[0] = {};
vButtonItems[0]["nombre"] = "Buscar";
vButtonItems[0]["etiqueta"] = "Buscar";
vButtonItems[0]["imagen"] = "buscar";
vButtonItems[0]["onclick"] = "return onclick_buscar()";

//vButtonItems[1] = {};
//vButtonItems[1]["nombre"] = "BuscarP";
//vButtonItems[1]["etiqueta"] = "Buscar";
//vButtonItems[1]["imagen"] = "buscar";
//vButtonItems[1]["onclick"] = "return onclick_buscar()";

var vListButton = new tListButton(vButtonItems, 'vListButton');
vListButton.loadImage("buscar", '/fw/image/transferencia/buscar.png')

var win = nvFW.getMyWindow()

function window_onload() 
{
    vListButton.MostrarListButton()
   // visualizar_busqueda_avanzada()
    window_onresize()

   // 
   /* if ('< = tiene_ejecuciones>' == 'True')
       {
        Dialog.confirm("Usted tiene tareas ejecutandose.<br> ¿Desea verlas?", {
            width: 300,
            className: "alphacube",
            okLabel: "Si",
            cancelLabel: "No",
            onOk: function (win) {
                                  onclick_ejecutando()
                                  win.close();
                                  return
                                 },
            onCancel: function (win) { onclick_buscar(); win.close(); return }
        })

    }
    else
        onclick_buscar()*/
    onclick_iniciar("NO_BUSCAR")
    //visualizar_busqueda_avanzada()
}


  //function vertareas_en_ejecucion()
  //{

  //            nvFW.exportarReporte({
  //                filtroXML: nvFW.pageContents.filtro_seg_ejecucion,
  //                path_xsl: "\\report\\transferencia\\verTransf_log\\HTML_verTransf_seg.xsl",
  //                formTarget: 'winPrototype',
  //                nvFW_mantener_origen: true,
  //                id_exp_origen: 0,
  //                winPrototype: {
  //                    modal: true,
  //                    center: true,
  //                    bloquear: false,
  //                    url: 'enBlanco.htm',
  //                    title: '<b>Proceso y Tareas en Ejecución.</b>',
  //                    minimizable: false,
  //                    maximizable: false,
  //                    draggable: true,
  //                    width: 800,
  //                    height: 200,
  //                    resizable: false,
  //                    destroyOnClose: true
  //                }
  //            })

  //}


function buscar(estado)
{
    filtroWhere = ""

    if (campos_defs.value('descripcion') != "")
     filtroWhere += "<descripcion type='like'>%" + campos_defs.value('descripcion') + "%</descripcion>"

    if (estado.toLowerCase() == 'pendiente' || estado.toLowerCase() == 'terminado' || estado.toLowerCase() == 'ejecutando')
      {
        var tipo_fecha = estado.toLowerCase() == 'pendiente' ? '' : '_transf'
        if ($('fe_ini').value != "")
            filtroWhere += "<fe_ini" + tipo_fecha + " type='mas'>convert(datetime,'" + $('fe_ini').value + "',103)</fe_ini" + tipo_fecha + ">"

         if ($('fe_fin').value != "") 
             filtroWhere += "<fe_fin" + tipo_fecha + " type='menor'>dateadd(day,1,convert(datetime,'" + $('fe_fin').value + "',103))</fe_fin" + tipo_fecha + ">"

         if ($('login').value != "")
             filtroWhere += obtenerFiltroLogin('login_det',$('login').value)

         if ($('resumen').value != "")
             filtroWhere += "<resumen type='like'>%" + $('resumen').value + "%</resumen>"


         filtroWhere += "<estado_det type=\"like\">" + estado + "</estado_det>"
      }

     if (estado.toLowerCase() == 'iniciar')
         filtroWhere += "<estado_det type=\"like\">iniciar</estado_det>"

     filtroWhere  += campos_defs.filtroWhere()

     return filtroWhere
}

function obtenerFiltroLogin(campo,valor)
{
  str = ""
  if ($('login').value.match(/\,/)) 
     str = "<" + campo + " type='in'>'" + replace(valor, ",", "','") + "'</" + campo + ">"
  else
     str = "<" + campo + " type='like'>%" + valor + "%</" + campo + ">"
  return str   
}

capitalize = function () {
    return this.replace(/^./, function (match) {
        return match.toUpperCase();
    });
};

function onclick_buscar()
{
   // try { setTimeout('win.setTitle("<b>Procesos y Tareas: ' + $('control_estado').value.capitalize() + '</b>")', 500) } catch (e) { }

    generar_info($('control_estado').value)
}

function onclick_iniciar(accion)
{
  if (!accion)
       accion = "BUSCAR"

  if(id_interval)
   clearTimeout(id_interval)

  $('iframeSolicitud').src = "enBlanco.htm"

  $('control_estado').value = "iniciar"
  win.setTitle("<b>Procesos y Tareas: " + $('control_estado').value.capitalize() + "</b>")
  
  if ($('tdMenuPie').style.display != 'none') {
      $('tdMenuPie').hide()
      onresize()
    }

  visualizar_busqueda_avanzada(false)
  //if (accion.toUpperCase() == "BUSCAR")
    // onclick_buscar()
}

function onclick_pendiente()
{
   $('iframeSolicitud').src = "enBlanco.htm"

   if ($('control_estado').value == "terminado") {
       $('fe_ini').value = ""
       $('fe_fin').value = ""
   }

  if(id_interval)
   clearTimeout(id_interval)

  $('control_estado').value = "pendiente"
  win.setTitle("<b>Procesos y Tareas: " + $('control_estado').value.capitalize() + "</b>")
  
  if ($('tdMenu').style.display != 'none') {
      $('tdMenuPie').show()
      onresize()
  }

  visualizar_busqueda_avanzada(false)
  //onclick_buscar()
}

function onclick_ejecutando() {

    $('iframeSolicitud').src = "enBlanco.htm"

    var fe_inicio = new Date(nvFW.pageContents.hoy)
    $('fe_ini').value = FechaToSTR(fe_inicio)
    $('fe_fin').value = ""

    if ($('tdMenu').style.display != 'none') {
        $('tdMenuPie').show()
    }

    if(id_interval)
       clearTimeout(id_interval)

    $('control_estado').value = "ejecutando"
    win.setTitle("<b>Procesos y Tareas: " + $('control_estado').value.capitalize() + "</b>")

    visualizar_busqueda_avanzada(false)
    // onclick_buscar()

}

function onclick_terminado() {

    $('iframeSolicitud').src = "enBlanco.htm"


    if(id_interval)
        clearTimeout(id_interval)

    $('control_estado').value = "terminado"
    win.setTitle("<b>Procesos y Tareas: " + $('control_estado').value.capitalize() + "</b>")

    var fe_inicio = new Date(nvFW.pageContents.hoy)
;
    var fe_anterior = fe_inicio.getDate();
    fe_inicio.setDate(fe_anterior - 1);

    $('fe_ini').value = FechaToSTR(fe_inicio)
    $('fe_fin').value = FechaToSTR(new Date(nvFW.pageContents.hoy))


    if ($('tdMenu').style.display != 'none') {
        $('tdMenuPie').show()
    }

    visualizar_busqueda_avanzada(false)

    //onclick_buscar()    
}

function generar_info(estado) 
{
    var PageSize = setPageSize()
    if ($('control_estado').value == "ejecutando" || $('control_estado').value == "pendiente") {
        PageSize = 1000000
    }

    filtroWhere = buscar(estado)
    filtroWhere = "<criterio><procedure AbsolutePage='1' PageSize='" + PageSize + "'><parametros><tipo_retorno></tipo_retorno><select><filtro>" + filtroWhere + "</filtro><orden>fe_fin desc</orden></select></parametros></procedure></criterio>"
 
    path_xsl = "\\report\\transferencia\\Procesos_tareas\\HTML_procesos_tareas.xsl"
    exportar_plantilla() 
}


function setPageSize() {
    var pagesize = 100
    try {
        var altoFila = 20
        if ($('login').getHeight() > 0)
            altoFila = $('login').getHeight()

        pagesize = Math.round($('iframeSolicitud').getHeight() / (altoFila) - 1, 0)
        //restamos la cabecera y pie considero 4 el como las row de los mismos
        pagesize = pagesize - 2
    }
    catch (e) { }

    return pagesize
}

var filtroWhere = ''
var path_xsl = ''
function exportar_plantilla() 
{
    nvFW.exportarReporte({
                           filtroXML: nvFW.pageContents.filtroTransf_procesos_tareas_consultar
                       , filtroWhere: filtroWhere
                          , path_xsl: path_xsl 
                       , salida_tipo: "adjunto"                    
                        , formTarget: "iframeSolicitud"
              , nvFW_mantener_origen: true
                   , bloq_contenedor: "iframeSolicitud"
                    , cls_contenedor: "iframeSolicitud"
                     , id_exp_origen: "0"
                 ,cls_contenedor_msg: $('control_estado').value.capitalize()
                        , parametros: "<parametros><control_estado>" + $('control_estado').value + "</control_estado></parametros>",
                         funComplete: function () {
                             
                                                     if ($('control_estado').value.toLowerCase() == 'ejecutando') {
                                                         ejecutando_busqueda=false
                                                         transf_run_list_isalive()
                                                        // setTimeout("transf_run_list_isalive()", 1000)
                                                         
                                                     }
                                                     else
                                                         id_interval = null
                          }
                        }) 

 }

function enter_onkeypress(e) 
{ 
  key = Prototype.Browser.IE ? e.keyCode : e.which
  if (key == 13)
      onclick_buscar()
}

function hoy() {
    return FechaToSTR(nvFW.pageContents.hoy) 
}

function detalle_dibujar(id_transf_log, id_transferencia,transferencia,e,id_param1,id_param2,id_param3,async) 
{
    var strXML_parm = '<parametros>'
    if (arrtparam) {
        if (id_param1 != "")
            strXML_parm += "<" + arrtparam[1] + ">" + id_param1 + "</" + arrtparam[1] + ">"
        if (id_param2 != "")
            strXML_parm += "<" + arrtparam[2] + ">" + id_param2 + "</" + arrtparam[2] + ">"
        if (id_param3 != "")
            strXML_parm += "<" + arrtparam[3] + ">" + id_param3 + "</" + arrtparam[3] + ">"
    }
    strXML_parm += '</parametros>'

    if (e.ctrlKey == true) 
       {
          if (e.ctrlKey == true) //con la tecla "Ctrl", abre una nueva pestaña
              window.open('/fw/transferencia/transf_ejecutar.aspx?async=' + async +'&id_transferencia=' + id_transferencia + '&xml_param='+ strXML_parm +'&id_transf_log=' + id_transf_log + '&ej_mostrar=true&app_path_rel=<%=  nvApp.path_rel  %>')
       }
      else
       {
           win_transf = window.top.nvFW.createWindow({
                                                        title: '<b>' + transferencia + '</b>',
                                                        minimizable: false,
                                                        maximizable: true,
                                                        maximize:true,
                                                        draggable: true,
                                                        width: 1100,
                                                        height: 600,
                                                        resizable: true,
                                                        onClose: function (w) {

                                                            if ($('control_estado').value.toLowerCase() != "iniciar") 
                                                               onclick_buscar();

                                                            win_transf.destroy()
                                                        }
                                                    });
           win_transf.setURL('/fw/transferencia/transf_ejecutar.aspx?async='+ async +'&id_transferencia=' + id_transferencia + '&xml_param='+ strXML_parm +'&id_transf_log=' + id_transf_log + '&ej_mostrar=true&app_path_rel=<%= nvApp.path_rel  %>') // nvUtiles.obtenerValor("app_path_rel", "") %>')
           win_transf.showCenter()
       }
      //ObtenerVentana('frame_detalle').location.href = '/fw/transferencia/transf_ejecutar.asp?id_transferencia=' + id_transferencia + '&id_transf_log=' + id_transf_log + '&ej_mostrar=true'
}

 var win_transf
 function transferencia_ABM(e,id_transferencia,nombre) 
 {
    
     if (nvFW.tienePermiso("permisos_transferencia", 1))
      {
        if (id_transferencia > 0) 
         {
            var strXML_parm = '<parametros></parametros>'
            
            if (e.ctrlKey == true) //con la tecla "Ctrl", abre una nueva pestaña
                window.open("/fw/transferencia/transferencia_abm.aspx?id_transferencia=" +  id_transferencia)
            else 
              {//sino, abre una ventana emergente
                win_transf = window.top.nvFW.createWindow({
                                                            title: '<b>' + nombre + '</b>',
                                                            minimizable: false,
                                                            maximizable: true,
                                                            maximize:true,
                                                            draggable: true,
                                                            width: 1100,
                                                            height: 600,
                                                            resizable: true,
                                                            onClose: function(w){win_transf.destroy()}
                                                         });
                win_transf.setURL("/fw/transferencia/transferencia_abm.aspx?id_transferencia=" +  id_transferencia)
                win_transf.showCenter()
              //  win_transf.maximize()

              }  
              
         }
       }  
    else
      alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')

}


 var win_comentario
 function comentario(id_transf_log, descripcion) {

        win_transf = window.top.nvFW.createWindow({
            title: '<b>' + descripcion + '</b>',
            minimizable: false,
            maximizable: true,
            maximize: true,
            draggable: true,
            width: 800,
            height: 350,
            resizable: true,
            destroyOnClose: true
        });
        win_transf.setURL("/fw/comentario/verCom_registro.aspx?do_zoom=0&nro_com_id_tipo=3&nro_com_grupo=4&collapsed_fck=1&id_tipo=" + id_transf_log)
        win_transf.showCenter()

 }

function visualizar_busqueda_avanzada(ocultar) 
{

  if (ocultar == undefined)
        ocultar = true

  if ($('tdMenu').style.display == 'none') 
    {
      $('tdMenu').show()
      if ($('control_estado').value.toLowerCase() == "pendiente" || $('control_estado').value.toLowerCase() == "terminado" || $('control_estado').value.toLowerCase() == "ejecutando" )
         $('tdMenuPie').show()
    }
  else 
   {
      if (ocultar == true) {
          $('tdMenu').hide()
          $('tdMenuPie').hide()
      }
   }

    window_onresize()

}

function window_onresize()
{
	try{
    
		var dif = Prototype.Browser.IE ? 5 : 2
		var body_height = $$('BODY')[0].getHeight()
        var divMenu_height = $('divMenu').getHeight()


        var tdMenu_heigtht = 0
        if ($('tdMenu').style.display != "none")
            tdMenu_heigtht = $('tdMenu').getHeight()

        var tdMenuPie_heigtht = 0
       // if ($('tdMenuPie').style.display != "none")
         //   tdMenuPie_heigtht = $('tdMenuPie').getHeight()

        var sumar = body_height - divMenu_height - tdMenu_heigtht - tdMenuPie_heigtht  - dif
       
        $('iframeSolicitud').setStyle({ height: sumar })

     }
   catch(e){}

}

function grupo_proceso_tareas_ref_consulta() 
{
    if (nvFW.tienePermiso("permisos_procesos_tareas", 2)) {
        var wing = window.top.nvFW.createWindow({
            url: '/fw/transferencia/procesos_tareas_ref_consultar.aspx',
            title: '<b>Grupos Procesos Tareas: Consultar Asociaciones</b>',
            minimizable: false,
            maximizable: false,
            draggable: true,
            width: 900,
            height: 400,
            resizable: true,
            destroyOnClose: true
        });

        wing.showCenter();
    }
    else {
        alert('No posee los permisos necesarios para realizar esta acción')
        return
    }

 }

function grupos_procesos_tareas_abm(nro_transf_pt_ref)
{

   if (nvFW.tienePermiso("permisos_procesos_tareas", 2))
   {
       var getparam = ""
       if (nro_transf_pt_ref > 0)
           getparam = "?nro_transf_pt_ref=" + nro_transf_pt_ref

       win = window.top.nvFW.createWindow({
                    url: '/fw/transferencia/procesos_tareas_ref_ABM.aspx' + getparam , 
                    title: '<b>Grupos Procesos y Tareas Referencia - ABM</b>', 
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    width: 800, 
                    height: 230,
//                    destroyOnClose: true,
                    onClose: onclick_buscar
                });
    
     win.showCenter()   
   
  }  
else
  {
   alert('No posee los permisos necesarios para realizar esta acción')
   return
  }   
}



function transferencia_abm(id_transferencia) {

    if (nvFW.tienePermiso("permisos_transferencia", 1)) {
        win = window.top.nvFW.createWindow({
            url: '/fw/transferencia/transferencia_abm.aspx?id_transferencia=' + id_transferencia,
            title: '<b>Transferencia - ABM</b>',
            minimizable: true,
            maximizable: true,
            draggable: true,
            width: 1000,
            height: 500,
            //destroyOnClose: true,
            onClose: onclick_buscar
        });

        win.showCenter()

    }
    else {
        alert('No posee los permisos necesarios para realizar esta acción')
        return
    }
}

function transf_run_isalive(id_transf_log) 
 {
                
   var oXML = new tXML()
   oXML.method = "POST"
   var URL = 'procesos_tareas_consultar.aspx'
   oXML.load(URL, 'modo=isalive&id_transf_log=' + id_transf_log)
    
   try {

      var err = new tError()
      err.error_from_xml(oXML)

      if (err.numError == 0)
           res = err.params["isAlive"]

    }
   catch (e) { }

   alert(res)

 }            

var id_interval = null 
var ejecutando_busqueda = false
function transf_run_list_isalive() 
 {
    if (iframeSolicitud.document.querySelectorAll("body")[0].innerText.toLowerCase() == 'ejecutando')
       return

    //nvFW.bloqueo_activar($(document.body), 'Ajax_bloqueo')

    var oXML = new tXML()
    oXML.async = true
    oXML.method = "POST"
    var URL = 'procesos_tareas_consultar.aspx'
    oXML.load(URL, 'modo=listisalive', function (){
    
               try {

                   //nvFW.bloqueo_desactivar($(document.body), 'Ajax_bloqueo')

                  var err = new tError()
                  err.error_from_xml(oXML)
       
                   if (err.numError == 0)
                    {
                       var contenedores = iframeSolicitud.document.querySelectorAll("#tbRow tr")
                       for (var i = 0; i < contenedores.length; i++) {
                            if (!err.params[contenedores[i].id]) 
                                iframeSolicitud.$(contenedores[i].id).hide()
                            else {
                                    if (iframeSolicitud.$(contenedores[i].id + "_fecha")) {
                                        iframeSolicitud.$("span_" + contenedores[i].id + "_fecha").innerText = ""
                                        iframeSolicitud.$("span_" + contenedores[i].id + "_fecha").innerText = getDuracion(iframeSolicitud.$(contenedores[i].id + "_fecha").value, err.params["momento"])
                                    }
                            }
                       }

                       var existen_mas = false
                       for (var i in err.params) {
                            if(!iframeSolicitud.$(i) && i.indexOf("id_transf_log") > -1)
                                existen_mas = true
                       }

                       if (existen_mas) {
                           ejecutando_busqueda = true
                           onclick_buscar()
                       }

                   }

                  id_interval = setTimeout("transf_run_list_isalive()", 1000)
                }
               catch (e) { }
      
        });

 }            

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" onkeypress="enter_onkeypress(event)" style="border:0px; width:100%; height:100%; overflow:hidden">
      <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
       <script language="javascript" type="text/javascript">
         var DocumentMNG = new tDMOffLine;
         var vMenu = new tMenu('divMenu', 'vMenu');
         Menus["vMenu"] = vMenu
         Menus["vMenu"].alineacion = 'centro';
         Menus["vMenu"].estilo = 'A';
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>p</icono><Desc>Pendientes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_pendiente()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>i</icono><Desc>Iniciar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_iniciar()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>t</icono><Desc>Terminados</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_terminado()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>e</icono><Desc>Ejecución</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_ejecutando()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='5' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='6'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vincular</icono><Desc>Asociar Definición de Procesos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>grupo_proceso_tareas_ref_consulta()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='7'><Lib TipoLib='offLine'>DocMNG</Lib><icono>filtro</icono><Desc>Busqueda Avanzada</Desc><Acciones><Ejecutar Tipo='script'><Codigo>visualizar_busqueda_avanzada()</Codigo></Ejecutar></Acciones></MenuItem>")

         vMenu.loadImage("i", '/fw/image/transferencia/seg_ini.png')
         vMenu.loadImage("p", '/fw/image/transferencia/seg_pen.png')
         vMenu.loadImage("t", '/fw/image/transferencia/seg_fin.png')
         vMenu.loadImage("e", '/fw/image/transferencia/seg_err.png')
         vMenu.loadImage("editar", '/fw/image/transferencia/editar.png')
         vMenu.loadImage("buscar", '/fw/image/transferencia/buscar.png')
         vMenu.loadImage("vincular", '/fw/image/transferencia/vincular.png')
         vMenu.loadImage("filtro", '/fw/image/transferencia/filtro.png')
         vMenu.MostrarMenu()
        </script> 
 <table class="tb1" id="tbCabe" style="width:100%;padding:0px;">
           <tr>
           <td style="text-align:left;width:100%;vertical-align:top;display:none;border:0px" id="tdMenu">
                <table class="tb1" style="width:100%">
                <%

                    Dim strarrtparam As String = ""
                    Dim strHead As String = ""
                    Dim strBody As String = ""
                    Dim cant_param As Integer = 1
                    Dim strSQL = "Select distinct id_transf_pt_param, campo_def,campo_etiqueta from transf_pt_params order by id_transf_pt_param"
                    Dim rsTpram = nvDBUtiles.DBExecute(strSQL)
                    While (Not (rsTpram.EOF))

                        strHead += "<td class='Tit1' style='width:22%;text-align:center'>" & rsTpram.Fields("campo_etiqueta").Value & "</td> "
                        strBody += "<td>" + nvFW.nvCampo_def.get_html_input(rsTpram.Fields("campo_def").Value) + "</td>"

                        strarrtparam += " arrtparam['" & rsTpram.Fields("id_transf_pt_param").Value & "'] = '" & rsTpram.Fields("campo_def").Value & "' " & vbCr
                        cant_param = cant_param + 1
                        rsTpram.MoveNext()

                    End While

                    nvDBUtiles.DBCloseRecordset(rsTpram)

                    Response.Write("<tr><td class='Tit1' style='text-align:center'>Proceso</td>" + strHead + "<td style='width: 15%' rowspan='4'><div id='divBuscar'></div></td></tr>")
                    Response.Write("<tr><td id='td_descr'></td>" + strBody + "</tr>")
                    Response.Write("<script type='text/javascript'>")
                    Response.Write("var arrtparam = {};" & vbCr)
                    Response.Write(strarrtparam)
                    Response.Write("</script>")

                %>
                <script type="text/javascript">campos_defs.add('descripcion', { nro_campo_tipo: 104, enDB: false, target: 'td_descr' })</script>
                <tr>
                   <td id="tdMenuPie" colspan="<%= cant_param %>"" style='text-align:left;width:100%;display:none'>
                     <table  class="tb1" style="width:100%">
                        <tr>
                        <td style="width:100%;">
                             <table class="tb1" id="tbBuscarPendiente" style="width:100%">
                                <tr>
                                      <td style="width:100%;vertical-align:top">
                                        <table class="tb1" style="width:100%">
                                        <tr>
                                            <td class='Tit1' style="text-align:center">Resumen</td> 
                                            <td class='Tit1' style="width: 20%;text-align:center">Ejecutado por</td> 
                                            <td class='Tit1' style="width:15%;text-align:center">Fecha Desde</td> 
                                            <td class='Tit1' style="width:15%;text-align:center">Fecha Hasta</td> 
                                            <%--<td style="width: 15%" rowspan="2"><div id="divBuscarP" style="width:100%"></div></td>--%>
                                        </tr>
                                        <tr> 
                                            <td id="td_resumen">
                                                <input type="hidden" id="control_estado" value="pendiente" />
                                                <script type="text/javascript">campos_defs.add('resumen', { nro_campo_tipo: 104, enDB: false, target: 'td_resumen' })</script>
                                            </td>
                                            <td id="td_login">
                                                <script type="text/javascript">campos_defs.add('login', { nro_campo_tipo: 104, enDB: false, target: 'td_login' })</script>
                                            </td>
                                            <td id="td_fe_ini">
                                                <script type="text/javascript">campos_defs.add('fe_ini', { nro_campo_tipo: 103, enDB: false, target: 'td_fe_ini' })</script>
                                            </td>
                                            <td id="td_fe_fin">
                                                <script type="text/javascript">campos_defs.add('fe_fin', { nro_campo_tipo: 103, enDB: false, target: 'td_fe_fin' })</script>
                                            </td>
                                        </tr> 
                                        </table>      
                                </td>
                                </tr>
                            </table>
                        </td>
                 </tr>
                </table>   
                </td>
               </tr>

                </table>
           </td>      
           </tr>
         </table>
        <iframe id="iframeSolicitud" name="iframeSolicitud" src="enBlanco.htm" frameborder="0" style="padding:0px;width:100%; border:0;overflow:hidden" ></iframe> 
</body>
</html>