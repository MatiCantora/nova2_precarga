<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Response.Expires = 0

    Dim modo = nvUtiles.obtenerValor("modo", "")
    Dim id_transferencia_get = nvUtiles.obtenerValor("id_transferencia_get", "")
    Dim nro_operador_get = nvUtiles.obtenerValor("nro_operador_get", "")
    Dim id_transf_log_get = nvUtiles.obtenerValor("id_transf_log_get", "")
    Dim estado_get = nvUtiles.obtenerValor("estado_get", "")
    Dim verfiltros = nvUtiles.obtenerValor("verfiltros", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador

    If (modo.ToUpper = "GUARDAR") Then

        If Not op.tienePermiso("permisos_transferencia_ejecutar", 2) Then
            Dim errPerm = New tError()
            errPerm.numError = -1
            errPerm.titulo = "No se pudo completar la operación."
            errPerm.mensaje = "No tiene permisos para ver la página."
            errPerm.response()
        End If

        Dim Err As tError = New tError()
        Try
            Dim id_transf_log = nvUtiles.obtenerValor("id_transf_log", "")
            nvDBUtiles.DBExecute("update transf_log_cab set fe_fin = GETDATE() , estado = 'error', operador = dbo.rm_nro_operador() where id_transf_log =" + id_transf_log)
            nvDBUtiles.DBExecute("update transf_log_det set fe_fin = GETDATE() , estado_det = 'error' where estado_det <> 'Terminado' and id_transf_log =" + id_transf_log)
            Err.numError = 0
            Err.mensaje = ""

        Catch ex As Exception
            Err.parse_error_script(ex)
            'Err.error_script(ex)
        End Try

        Err.response()
    End If

    'debe tener el permiso para editar el modulo
    If Not op.tienePermiso("permisos_transferencia_seguimiento", 4) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.response()
    End If


    Me.contents("filtroverTransf_log_cab") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_cab'><campos>distinct tieneSubprocesos,esSubproceso,id_transf_log,fe_inicio,fe_fin,estado,id_transferencia,nombre,operador,Login, nombre_operador,resumen </campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroverTransf_log_subproc") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_subproc'><campos>distinct 1 as esSubproceso,id_transf_log,fe_inicio,fe_fin,estado,id_transferencia,nombre,operador,Login, nombre_operador,resumen</campos><filtro></filtro><orden></orden></select></criterio>")

    Me.contents("filtroverTransf_log_param") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_param'><campos>distinct id_transf_log,id_transferencia,nombre,estado,fe_inicio,fe_fin,parametro,valor,nombre_operador,operador</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtrotransf_log_cab_xml") = nvXMLSQL.encXMLSQL("<criterio><select vista='transf_log_cab'><campos>cast(isNULL(obsbin,0) as varchar(8000)) as obsbin</campos><filtro></filtro><orden></orden></select></criterio>")

    Me.addPermisoGrupo("permisos_transferencia_ejecutar")

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>

    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/window_utiles.js"></script>
    <%= Me.getHeadInit()   %>
    <script type="text/javascript" src="/FW/transferencia/script/transf_seg_utiles.js"></script>
    <script type="text/javascript" src="/FW/transferencia/script/transf_destino_utiles.js"></script>
    
    <script type="text/javascript" >
    //Botones

var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

var id_transferencia_get = '<%= id_transferencia_get %>'
var nro_operador_get = '<%= nro_operador_get %>'
var estado_get = '<%= estado_get%>'

function window_onload() 
{
    nvFW.enterToTab = true

    if (parseInt($('id_transf_log').value) > 0) 
     {
        $('cabecera').hide()
        campos_defs.set_value('id_transferencia', id_transferencia_get)
        campos_defs.set_value('nro_operador', nro_operador_get)
        //$('cmb_estado').value = estado_get
        btnMostrar_transferencia()
     }
     else
    {
       vMenu.MostrarMenu()
       $('cabecera').show()
       $('fe_desde_ini').value = hoy()
     }  
 
   window_onresize()
}

function btnMostrar_transferencia() 
{
    var cadena_filtro = campos_defs.filtroWhere()

    if ($('sel_fe').value.toLowerCase() == "fe")
        cadena_filtro = cadena_filtro + "<SQL type='sql'>dbo.[transf_log_tiene_errores](id_transf_log) = 1 or estado = 'error' </SQL>"

    if ($('sel_fe').value.toLowerCase() == "fo")
        cadena_filtro = cadena_filtro + "<SQL type='sql'>dbo.[transf_log_tiene_errores](id_transf_log) = 0 and estado <> 'error'</SQL>"

    if ($('sel_subproc').value.toLowerCase() == "subproceso")
        cadena_filtro = cadena_filtro + "<esSubproceso type='igual'>1</esSubproceso>"

    if ($('sel_subproc').value.toLowerCase() == "contiene_subproceso")
        cadena_filtro = cadena_filtro + "<tieneSubprocesos type='igual'>1</tieneSubprocesos>"

    if ($('sel_subproc').value.toLowerCase() == "no_contiene_subproceso")
        cadena_filtro = cadena_filtro + "<tieneSubprocesos type='igual'>0</tieneSubprocesos>"

    //if ($('cmb_estado').value != '' && $('cmb_estado').value != 'finalizado_errores')
      //  cadena_filtro = cadena_filtro + "<estado type='like'>" + $('cmb_estado').value + "</estado>"
    
    if ($('id_transf_log').value  != '')
        cadena_filtro = cadena_filtro + "<id_transf_log type='in'>" + $('id_transf_log').value + "</id_transf_log>"
 
	if ($('fe_desde_ini').value != "")
	    cadena_filtro = cadena_filtro + "<fe_inicio type='mas'>convert(datetime,'" + $('fe_desde_ini').value + "',103)</fe_inicio>"

	if ($('fe_hasta_ini').value != "")
	    cadena_filtro = cadena_filtro + "<fe_inicio type='menor'>dateadd(day,1,convert(datetime,'" + $('fe_hasta_ini').value + "',103))</fe_inicio>"

    if ($('fe_desde_fin').value != "")
        cadena_filtro = cadena_filtro + "<fe_inicio type='mas'>convert(datetime,'" + $('fe_desde_fin').value + "',103)</fe_inicio>"

    if ($('fe_hasta_fin').value != "")
        cadena_filtro = cadena_filtro + "<fe_inicio type='menor'>dateadd(day,1,convert(datetime,'" + $('fe_hasta_fin').value + "',103))</fe_inicio>"

    if ($('valor').value != "")
        cadena_filtro = cadena_filtro + "<valor type='like'>%" + $('valor').value + "%</valor>"

    if ($('parametro').value != "")
        cadena_filtro = cadena_filtro + "<parametro type='like'>%" + $('parametro').value + "%</parametro>"

    filtroXML = nvFW.pageContents.filtroverTransf_log_cab
    path_xsl= "\\report\\transferencia\\verTransf_log\\HTML_verTransf_seg.xsl"
    if ($('parametro').value != "" || $('valor').value != "")
    {
       filtroXML = nvFW.pageContents.filtroverTransf_log_param
       path_xsl = "\\report\\transferencia\\verTransf_log\\HTML_verTransf_seg_param.xsl"
    }

    filtroWhere = "<criterio><select AbsolutePage='1' PageSize='" + setPageSize() + "' cacheControl='Session'><campos></campos><filtro>" + cadena_filtro + "</filtro><orden></orden></select></criterio>"
    nvFW.exportarReporte({
                           filtroXML: filtroXML
                       , filtroWhere: filtroWhere 
                          , path_xsl: path_xsl
                       , salida_tipo: "adjunto"                    
                        , formTarget: "iframeSolicitud"
              , nvFW_mantener_origen: true
                   , bloq_contenedor: $(document.body)
                    , cls_contenedor: "iframeSolicitud"
                        }) 

 }

function setPageSize() {
    
    var pagesize = 100
    try {
        if ($('id_transf_log').getHeight() == 0)
            return 100

        pagesize = Math.round($('iframeSolicitud').getHeight() / ($('id_transf_log').getHeight()) - 1, 0)
        //restamos la cabecera y pie considero 4 el como las row de los mismos
        pagesize = pagesize - 2
    }
    catch (e) { console.log(e.message)}

    return pagesize
}

var win_seg
function mostrar_transf(id_transf_log) {

    win_seg = window.top.nvFW.createWindow({
                                          url: '/fw/transferencia/transf_seguimiento_pool_control_exec.aspx?id_transf_log=' + id_transf_log,
                                          minimizable: false,
                                          maximizable: true,
                                          draggable: true,
                                          width: 800,
                                          height: 350,
                                          resizable: true,
                                          destroyOnClose: true
                                       })

    win_seg.showCenter()
}

function mostrar_transf_return() {

}

function window_onresize()
{
	try{

		var dif = Prototype.Browser.IE ? 5 : 2
		var body_height = $$('BODY')[0].getHeight()

        var cabe_height = 0
        var menu_height = 0
        if ($('cabecera').style.display != 'none') {
           cabe_height = $('cabecera').getHeight()
		   menu_height = $('divMenu').getHeight()
        }

        var calc = body_height - cabe_height - dif - menu_height
        $('iframeSolicitud').setStyle({ height: calc + 'px' })

   }catch(e){console.log(e.message)}
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

function finalizar_transf(id_transf_log, ReturnEval) {
    
    if (id_transf_log == '')
    { alert('Faltan definir el seguimiento'); return }

    Dialog.confirm("¿Desea <b>finalizar</b> el proceso seleccionado Nº " + id_transf_log + "?",
                                                    {
                                                        width: 300,
                                                        className: "alphacube",
                                                        okLabel: "Si",
                                                        cancelLabel: "No",
                                                        onOk: function (w) {
                                                            nvFW.error_ajax_request('transf_seguimiento.aspx',
                                                              {
                                                                  parameters: { modo: 'GUARDAR', id_transf_log: id_transf_log },
                                                                  onSuccess: function (err, transport) {

                                                                      if (err.numError != 0) {
                                                                          alert(err.mensaje)
                                                                          return
                                                                      }
                                                                      else
                                                                          eval(ReturnEval);
                                                                  }
                                                              });

                                                            w.close();
                                                            return
                                                        },

                                                        onCancel: function (w) {
                                                            w.close();
                                                        }
                                                    });
}


        function exportarXML(id_transf_log) {

            var filtroXML = nvFW.pageContents.filtrotransf_log_cab_xml

            var filtroWhere = "<criterio><select><campos></campos><filtro><id_transf_log type='igual'>" + id_transf_log + "</id_transf_log></filtro><orden></orden></select></criterio>"
            nvFW.exportarReporte({
                filtroXML: filtroXML
                , filtroWhere: filtroWhere
                , salida_tipo: "adjunto"
                , formTarget: "_blank"
                , path_xsl: "\\report\\HTML_Copy.xsl"
            });

        }

//function transf_run_isalive(id_transf_log) 
// {
                
//   var oXML = new tXML()
//   oXML.method = "POST"
//   var URL = 'procesos_tareas_consultar.aspx'
//   oXML.load(URL, 'modo=isalive&id_transf_log=' + id_transf_log)
    
//   try {

//      var err = new tError()
//      err.error_from_xml(oXML)

//      if (err.numError == 0)
//           res = err.params["isAlive"]

//    }
//   catch (e) { }

//   alert(res)

// } 
</script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width:100%; height:100%; overflow:hidden">
     <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
       <script  type="text/javascript">
         var DocumentMNG = new tDMOffLine;
         var vMenu = new tMenu('divMenu', 'vMenu');
         Menus["vMenu"] = vMenu
         Menus["vMenu"].alineacion = 'centro';
         Menus["vMenu"].estilo = 'A';
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Buscar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnMostrar_transferencia()</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenu.loadImage("buscar", '/fw/image/transferencia/buscar.png')
        </script> 
<table class="tbFondo" id="cabecera" style="display:none;width:100%">
	<tr>
					<td style="width:100%">
						   <table class="tb1 layout_fixed">
							<tr class="tbLabel">	
							    <td style="width: 10%;text-align:center" >Id Log</td>
								<td style="text-align:center" >Transferencia</td>
								<td style="width: 20%;text-align:center">Operador</td>
								<td style="width: 20%;text-align:center" >Estado</td>			
                                <td style="width: 15%;text-align:center">Finalización del Proceso</td>
                                <td style="width: 15%;text-align:center">Característica del Proceso</td>
							</tr>
                          	<tr>
								<%--<td><select id="cmb_estado" style="width:100%"><option value=""></option><option value="error">Error</option><option value="ejecutando">Ejecutando</option><option value="iniciando">Iniciando</option><option value="finalizado">Finalizado</option><option value="Pendiente">Pendiente</option><option value="finalizado_errores">Finalizado con Errores</option></select></td>--%>             
							    <td><input type="text" size="20" style="width: 100%" id="id_transf_log" name="id_transf_log" value="<% = id_transf_log_get %>" onkeypress='return valDigito(event,",") && enter_onkeypress(event)'/></td>             
								<td><%= nvCampo_def.get_html_input("id_transferencia")%></td>      
                                <td><%= nvCampo_def.get_html_input("nro_operador")%></td>  
                                <td><%= nvFW.nvCampo_def.get_html_input("estado", enDB:=False, nro_campo_tipo:=2,StringValueIncludeQuote:=true , filtroWhere:="<estado type='in'>%campo_value%</estado>", filtroXML:="<criterio><select vista='transf_log_estado'><campos> distinct estado as id, estado as [campo] </campos><orden>[id]</orden><filtro></filtro></select></criterio>") %></td>
                                <td><select id="sel_fe" style="width:100%;text-align:right"><option value="" selected="selected"></option><option value="fe">Con Error</option><option value="fo">Correctamente</option></select></td>
                                <td><select id="sel_subproc" style="width:100%;text-align:right"><option value="" selected="selected"></option><option value="contiene_subproceso">Contiene subprocesos</option><option value="no_contiene_subproceso">No contiene subprocesos</option><option value="subproceso">Es subproceso</option></select></td>

							</tr>
                            </table>
                            <table class="tb1 layout_fixed">
                            <tr class="tbLabel">	
								<td style="width: 10%;text-align:center">Fe ini. desde</td>       
								<td style="width: 10%;text-align:center">Fe ini. hasta</td>         
                                <td style="width: 10%;text-align:center">Fe fin desde</td>       
								<td style="width: 10%;text-align:center">Fe fin hasta</td>      
                                <td style="width: 10%;text-align:center">Parámetro</td>
                                <td style="width: 10%;text-align:center">Valor</td>
							</tr>
							<tr>
								<%--<td><select id="cmb_estado" style="width:100%"><option value=""></option><option value="error">Error</option><option value="ejecutando">Ejecutando</option><option value="iniciando">Iniciando</option><option value="finalizado">Finalizado</option><option value="Pendiente">Pendiente</option><option value="finalizado_errores">Finalizado con Errores</option></select></td>--%>             
								<td id="td_fe_desde_ini">
									<script type="text/javascript">
										campos_defs.add('fe_desde_ini', { target: 'td_fe_desde_ini', enDB: false, nro_campo_tipo: 103 })
									</script>                        
								</td>
								<td id="td_fe_hasta_ini"> 
									<script type="text/javascript">
										campos_defs.add('fe_hasta_ini', { target: 'td_fe_hasta_ini', enDB: false, nro_campo_tipo: 103 })
									</script>
								</td>
                                <td id="td_fe_desde_fin">
									<script type="text/javascript">
										campos_defs.add('fe_desde_fin', { target: 'td_fe_desde_fin', enDB: false, nro_campo_tipo: 103 })
									</script>                        
								</td>
								<td id="td_fe_hasta_fin"> 
									<script type="text/javascript">
									    campos_defs.add('fe_hasta_fin', { target: 'td_fe_hasta_fin', enDB: false, nro_campo_tipo: 103 })
									</script>
								</td>
		                       <td id="td_parametro">
									<script type="text/javascript">
                                        campos_defs.add('parametro', { target: 'td_parametro', enDB: false, nro_campo_tipo: 104 })
									</script>                        
								</td>
                                <td id="td_valor">
									<script type="text/javascript">
                                        campos_defs.add('valor', { target: 'td_valor', enDB: false, nro_campo_tipo: 104 })
									</script>                        
								</td>
		                    </tr>									  
						</table> 
					</td>				
	   		   </tr>
</table>
<iframe id="iframeSolicitud" name="iframeSolicitud" src="enBlanco.htm" frameborder="0" style="width:100%; height:100%; border:0;overflow:hidden" ></iframe> 
</body>
</html>