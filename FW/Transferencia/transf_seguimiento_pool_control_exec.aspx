<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Response.Expires = 0

    'debe tener el permiso para editar el modulo
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If Not op.tienePermiso("permisos_transferencia_seguimiento", 1) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.response()
    End If

    Me.addPermisoGrupo("permisos_transferencia_ejecutar")

    Dim modo As String = nvUtiles.obtenerValor("modo", "")

    Dim id_transf_log = nvUtiles.obtenerValor("id_transf_log", "")
    Dim estado = "FIN"
    If (nvUtiles.obtenerValor("estado", "") <> "finalizado") Then
        estado = "INI"
    End If

    If (modo.ToUpper = "REEJECUTAR") Then

        If Not op.tienePermiso("permisos_transferencia_ejecutar", 3) Then
            Dim errPerm = New tError()
            errPerm.numError = -1
            errPerm.titulo = "No se pudo completar la operación. "
            errPerm.mensaje = "No tiene permisos para ver la página."
            errPerm.response()
        End If

        Dim er = New tError()
        Dim id_transferencia As Integer = nvUtiles.obtenerValor("id_transferencia", "")
        Dim id_transf_log_det As String = nvUtiles.obtenerValor("id_transf_log_det", "")

        Try

            Dim nT As New System.Threading.Thread(Sub(objeto As Object())

                                                      Dim err As New tError()
                                                      Try
                                                          'Cargar los parametros 
                                                          Dim nvApp1 As tnvApp = objeto.GetValue(0)
                                                          nvFW.nvApp._nvApp_ThreadStatic = nvApp1

                                                          Dim transferencia As New nvTransferencia.tTransfererncia
                                                          transferencia.cargar(id_transferencia)

                                                          Dim rsTrans As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select parametro,valor from vertransf_log_param where id_transf_log_det = " & id_transf_log_det.ToString)
                                                          While Not rsTrans.EOF

                                                              Dim param_name As String = rsTrans.Fields("parametro").Value
                                                              Dim param_valor = rsTrans.Fields("valor").Value

                                                              If param_name <> "" and transferencia.param.ContainsKey(param_name) = true Then
                                                                  transferencia.param(param_name)("valor") = param_valor
                                                              End If

                                                              rsTrans.MoveNext()

                                                          End While

                                                          nvDBUtiles.DBCloseRecordset(rsTrans)

                                                          Try
                                                              Dim rsTransf_log As ADODB.Recordset = nvDBUtiles.DBExecute("exec transf_log_add " & id_transferencia)
                                                              transferencia.id_transf_log = rsTransf_log.Fields("id_transf_log").Value
                                                              nvDBUtiles.DBCloseRecordset(rsTransf_log)

                                                              nvFW.nvTransferencia.nvTransfUtiles.transfRunThread.Add(transferencia.id_transf_log, nT)

                                                              er = transferencia.ejecutar()

                                                              nvFW.nvTransferencia.nvTransfUtiles.transfRunThread.Remove(transferencia.id_transf_log)

                                                              If transferencia.id_transf_log And transferencia.id_transf_log <> 0 Then
                                                                  id_transf_log = transferencia.id_transf_log
                                                              Else
                                                                  id_transf_log = 0
                                                              End If

                                                          Catch ex As Exception

                                                              er.parse_error_script(ex)
                                                              er.numError = 101
                                                              er.mensaje = "Hubo errores al ejecutar algunas transferencias del proceso."

                                                          End Try


                                                      Catch e As Exception
                                                          err.parse_error_script(e)
                                                          err.numError = 101
                                                          err.mensaje = "Hubo errores al ejecutar algunas transferencias del proceso."

                                                      End Try
                                                  End Sub)

            nT.Start(New Object() {nvApp, id_transferencia, id_transf_log_det})

        Catch ex As Exception

            er.parse_error_script(ex)
            er.numError = -99
            er.mensaje = "Error al consultar el estado de la transfencia log " & id_transf_log.ToString

        End Try

        er.response()

    End If

    Me.contents("filtroVerTransf_log_det") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_det'><campos>id_transf_log_subproc,fe_fin_det,id_transf_log,id_transferencia, nombre, estado, estado_det, fe_inicio, fe_fin, id_transf_log_det, id_transf_det,id_transferencia_transf_det,nombre_transf_det, transferencia,transf_tipo,numError, mensaje, comentario, debug_desc, debug_src,link, script, nombre_operador,operador_det,login_det,nombre_operador_det,time_sec</campos><filtro></filtro><orden>fe_fin_det</orden></select></criterio>")
    Me.contents("filtroVerTransf_log_cab") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_cab'><campos>*</campos><filtro><id_transf_log type='igual'>" + id_transf_log + "</id_transf_log></filtro><orden></orden></select></criterio>")
    Me.contents("filtroVertransf_log_param") = nvXMLSQL.encXMLSQL("<criterio><select vista='vertransf_log_param'><campos>[id_transf_log],[id_transferencia],[nombre],[timeout],[estado],[fe_inicio],[fe_fin],[obs],[resumen],[id_transf_log_det],[id_transf_det],[transferencia],[numError],[mensaje],[comentario],[debug_desc],[debug_src],[parametro],replace([valor],'-','- ') as valor,[editable],[requerido],[tipo_dato],[etiqueta],[operador],[login],[nombre_operador],[operador_det],[login_det],[nombre_operador_det]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroRm_DTSRun_res") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_DTSRun_res' CommantTimeOut='1500' vista='verDTSRun_res'><parametros></parametros></procedure></criterio>")
    Me.contents("filtroVertransf_log_param") = nvXMLSQL.encXMLSQL("<criterio><select vista='vertransf_log_param'><campos>[id_transf_log],[id_transferencia],[nombre],[timeout],[estado],[fe_inicio],[fe_fin],[obs],[resumen],[id_transf_log_det],[id_transf_det],[transferencia],[numError],[mensaje],[comentario],[debug_desc],[debug_src],[parametro],replace([valor],'-','- ') as valor,[editable],[requerido],[tipo_dato],[etiqueta],[operador],[login],[nombre_operador],[operador_det],[login_det],[nombre_operador_det]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroVertransf_log_paramALL") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.transf_log_param_select' CommantTimeOut='1500'><parametros></parametros></procedure></criterio>")
    Me.contents("filtroverTransf_log_param_colum") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='transf_log_param_campos'><parametros></parametros><orden></orden></procedure></criterio>")

    Me.contents("permiso_ver_parametros") = IIf(op.tienePermiso("permisos_transferencia_seguimiento", 3) = True, "1", "0")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title> 
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0"/>
    
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <style type="text/css">
    
    .divCabe {
        font-family: arial; 
        font-size: 8pt !Important; 
        background-color: White;
        text-align:left !Important;
        overflow:hidden;
        width:100% !Important;
      }     

    .divINI {
        border-top:6px solid Red;
      }     
    
    .divERR {
        border-top:6px solid Red;
      }     
    
    .divPEN {
        border-top:6px solid blue;
      }     
     
    .divFIN {
        border-top:6px solid green;
      }     
      
    </style>
    
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <script type="text/javascript" src="/fw/transferencia/script/transf_seg_utiles.js"></script>
    <script type="text/javascript" src="/fw/transferencia/script/transf_utiles.js"></script>
    <script type="text/javascript" src="/fw/transferencia/script/transf_destino_utiles.js"></script>
    <%= Me.getHeadInit()   %>
    <script type="text/javascript">

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    var mostrar_adjunto = false

    var win = nvFW.getMyWindow()
    var id_transf_log = <% = id_transf_log %>;

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
 
    function MMDDYYYY(strFecha) 
     {
      return strFecha.split('/')[1] + '/' + strFecha.split('/')[0] + '/' + strFecha.split('/')[2]
     }

    function HTMLTitle() {
         var type = estado
         var img = estado  //type == 'INI' ? 'cerrar' : 'abierto'
         
         HTML = "<div id='divTitulo" + id_transf_log + "' style='width:100%' class='divCabe div" + type + "'>"
         HTML += "<table style='width:100%;border:0px'><tr><td style='width:5%;vertical-align:top'><img alt='' src='/FW/image/transferencia/seg_" + img + ".png' title=''></img></td>"
         HTML += "<td>" + title + "</td><td style='width:2%;text-align:right;vertical-align:top' nowrap='nowrap'>"
         if (type == 'INI' && (nvFW.tienePermiso("permisos_transferencia", 1)))
             HTML += "<img alt='' title='Finalizar' src='/FW/image/transferencia/eliminar.png' style='cursor:hand;cursor:pointer' onclick='return finalizar_transf(" + id_transf_log + ")'/>"

         // solo relanzar si esta finalizado, pendiente??? o finalizado con error
         HTML += "<img alt='' title='Re ejecutar' src='/FW/image/transferencia/procesar.png'  style='float:left;cursor:hand;cursor:pointer' onclick='return reload_transf(" + id_transf_log + ",event)'/>"
         HTML += "</td><tr></table></br>"
         HTML += "</div>" 
         
         return HTML
     }

     var transf_log_dets = {}
     var interval = null
     var hoyS = new Date('<%= DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss") %>')
     var difS = (hoyS.getTime() - (new Date().getTime()))
     function pool_control_ejecucion() 
     {
         hoy = new Date((new Date().getTime()) + (difS))
         fecha = new Date(MMDDYYYY(fe_inicio).split(' ')[0] + " " + fe_inicio.split(' ')[1])

         if (estado == 'INI')
             $("spanCTRL").innerHTML = ' - Tiempo transcurrido: <b>' + getDuracion(fecha, hoy) + '</b>'
         else
             $("spanCTRL").innerHTML = ' - Tiempo transcurrido: <b>' + getDuracion(fecha, new Date(MMDDYYYY(fe_fin).split(' ')[0] + " " + fe_fin.split(' ')[1])) + '</b>'          
   
         
         try {
             var rs = new tRS()
             rs.async = true
             rs.xml_format = 'rs_xml_json'
             rs.onComplete = function(rs) {
                 try {
                     var id_transf_log_det
                     var tranf_log_det

                     var strHTML = "<table class='tb1 highlightOdd highlightTROver layout_fixed'>"
                     strHTML += '<tr class="tbLabel"><td style="width:15%" title=" Nro. Log Transf: ' + id_transf_log + '">&nbsp;Nro.</td><td style="width:30%" >Tarea</td><td style="width:15%">Estado</td><td>LINK</td><td style="width:20%">LOG</td><td style="width:6%" Title="Duración en segundos">Duración Seg</td><td style="width:6%">Param</td></tr>'

                     while (!rs.eof()) {
                         
                         id_transf_log_det = rs.getdata('id_transf_log_det')
                         tranf_log_det = transf_log_dets[id_transf_log_det] = {}
                         tranf_log_det['id_transf_log'] = rs.getdata('id_transf_log')
                         tranf_log_det['id_transf_log_subproc'] = rs.getdata('id_transf_log_subproc')
                         tranf_log_det['nombre'] = rs.getdata('nombre')
                         tranf_log_det['estado'] = rs.getdata('estado').toLowerCase()
                         tranf_log_det['estado_det'] = rs.getdata('estado_det') == null ? '' : rs.getdata('estado_det').toLowerCase()
                         tranf_log_det['login_det'] = rs.getdata('login_det') == null ? '' : "(" + rs.getdata('login_det') + ")"
                         tranf_log_det['fe_inicio'] = rs.getdata("fe_inicio") == null ? '' : FechaToSTR((rs.getdata("fe_inicio"))) + " " + HoraToSTR((rs.getdata("fe_inicio")))
                         tranf_log_det['fe_fin'] = rs.getdata("fe_fin") == null ? '' : FechaToSTR((rs.getdata("fe_fin"))) + " " + HoraToSTR((rs.getdata("fe_fin")))
                         tranf_log_det['nombre_operador'] = rs.getdata('nombre_operador')
                         tranf_log_det['nombre_operador_det'] = rs.getdata('nombre_operador_det') == null ? '' : rs.getdata('nombre_operador_det')
                         tranf_log_det['id_transferencia'] = rs.getdata('id_transferencia')
                         tranf_log_det['id_transf_log_det'] = rs.getdata('id_transf_log_det')
                         tranf_log_det['id_transf_det'] = rs.getdata('id_transf_det') == null ? '' : rs.getdata('id_transf_det')
                         tranf_log_det['transferencia'] = rs.getdata('transferencia') == null ? '' : rs.getdata('transferencia')
                         tranf_log_det['transf_tipo'] = rs.getdata('transf_tipo')
                         tranf_log_det['salida_tipo'] = rs.getdata('salida_tipo')
                         tranf_log_det['time_sec'] = rs.getdata('time_sec')
                         tranf_log_det['id_transferencia_transf_det'] = rs.getdata('id_transferencia_transf_det')
                         tranf_log_det['nombre_transf_det'] = rs.getdata('id_transferencia_transf_det') != 0 ? (" (<b>" + rs.getdata('nombre_transf_det') + " - " + rs.getdata('id_transferencia_transf_det')+ "</b>)") : ""

                         tranf_log_det['link'] = rs.getdata('link') == null ? '' : rs.getdata('link')
                         tranf_log_det['script'] = rs.getdata('script')
                         tranf_log_det['error'] = new tError()
                         tranf_log_det['error'].numError = rs.getdata('numError')
                         tranf_log_det['error'].mensaje = rs.getdata('mensaje')
                         tranf_log_det['error'].comentario = rs.getdata('comentario')
                         tranf_log_det['error'].debug_desc = rs.getdata('debug_desc')
                         tranf_log_det['error'].debug_src = rs.getdata('debug_src')

                         tranf_log_det['fe_fin_det'] = rs.getdata('fe_fin_det')
                         tranf_log_det['fe_fin_det_ant'] = transf_log_dets[id_transf_log_det - 1] != undefined ? transf_log_dets[id_transf_log_det - 1].fe_fin_det : null
                         tranf_log_det['fe_comienzo'] = tranf_log_det['fe_fin_det']
                         if (transf_log_dets[id_transf_log_det - 1] != undefined)
                             tranf_log_det['fe_comienzo'] = transf_log_dets[id_transf_log_det - 1]['fe_comienzo']

                         var img_estado = ''
                         var class_name = 'color:green;'
                         var txtEstado = ''
                         var link = ''
                         var log = ''
                         if (tranf_log_det['estado_det'] == 'pendiente') {
                             txtEstado = "Pendiente"
                             class_name = 'color:blue;'
                         }

                         if (tranf_log_det['estado_det'] == 'ejecutando') {
                             txtEstado = "Ejecutando - " + '<img style="text-align:center" src="/FW/image/icons/spinner24x24_azul.gif"></img>'
                             class_name = 'color:blue;'
                         }

                         if (tranf_log_det['estado_det'] == 'pendiente_ejecutado') {
                             txtEstado = "Pendiente - Ejecutado "
                             class_name = 'color:green;'
                         }

                         if (tranf_log_det['estado_det'] == 'terminado' && tranf_log_det['error'].numError == 0) {
                             txtEstado = "Terminado"
                             class_name = 'color:green;'
                         }

                         
                         if (tranf_log_det.estado_det.toLowerCase() == 'ejecucion_async') {
                    
                            href = "javascript:mostrar_transf(" + tranf_log_det.id_transf_log_subproc + ")"
                            txtEstado = "<a style='color:#D28757 !Important' href='" + href + "'>Ejecución Asincrona</a>"
                            class_name = 'color:#D28757;'

                         }

                         if (tranf_log_det["error"].numError != 0) {

                             //href = "javascript:transf_log_dets[" + id_transf_log_det + "][\"error\"].alert()"
                             //href = "javascript:fn_mostrar_error({ numError: '" + tranf_log_det['error']['numError'] + "' ,titulo : '" + tranf_log_det['error']['titulo'] + "' ,mensaje : '" + tranf_log_det['error']['mensaje'] + "',comentario : '" + tranf_log_det['error']['comentario'] + "' ,debug_src : '" + tranf_log_det['error']['debug_src'] + "'})"
                             href = "javascript:fn_mostrar_error(" + id_transf_log_det + ",\"" + nvFW.pageContents.filtroVerTransf_log_det + "\")"

                             if (tranf_log_det['transf_tipo'] == 'DTS' && tranf_log_det["error"].numError != 0)
                                 href = "javascript:fn_DTS_log(\"" + tranf_log_det["error"]['debug_src'] + "\",\"" + nvFW.pageContents.filtroRm_DTSRun_res + "\")"

                             txtEstado = "<a style='color:red !Important' href='" + href + "'>Error<a>"
                             class_name = 'color:red !Important; '
                         }

                         if (tranf_log_det['script'] != '' && tranf_log_det['script'] != null && tranf_log_det['script_run'] != true) {
                             if (transf_log_dets['window'] == undefined)
                                 transf_log_dets['window'] = new Array()

                             if (transf_log_dets['window'].length >= 0) {
                                 var encontro = false
                                 for (var i = 0; i < transf_log_dets['window'].length; i++) {
                                     if (transf_log_dets['window'][i].id == 'win_' + tranf_log_det['id_transf_log_det'])
                                         encontro = true
                                 }

                                 if (!encontro && mostrar_adjunto)
                                     try { eval(tranf_log_det['script']) } catch (errSCR) { alert(errSCR.message) }
                             }
                             else
                                 if (mostrar_adjunto)
                                 try { eval(tranf_log_det['script']) } catch (errSCR) { alert(errSCR.message) }

                             tranf_log_det['script_run'] = true
                         }
                         
                         if (tranf_log_det['link'] != '' && tranf_log_det['estado_det'].toLowerCase() == "terminado") {

                             var arDestinos = target_parse(tranf_log_det['link'])
                             var ext = ""
                             var target = ""
                             var content_disposition = 'inline'
                             var path = ""
                             for (d = 0; d < arDestinos.length; d++)
                                 if (arDestinos[d].protocolo.toLowerCase() == 'file' && tranf_log_det["error"].numError == 0) {

                                     ext = arDestinos[d].comp_extension != "" ? arDestinos[d].comp_extension : arDestinos[d].extension
                                     path = arDestinos[d].target_comp != "" ? arDestinos[d].target_comp : arDestinos[d].path
                                     filename = arDestinos[d].comp_filename != "" ? arDestinos[d].comp_filename : arDestinos[d].filename

                                     link += "<a title='" + filename + "' target='_bank' href='/fw/files/file_get.aspx?content_disposition=" + content_disposition + "&path=" + path + "'><img src='/FW/image/docs/" + ext + ".png' border='0' align='bottom'></img>&nbsp;" + filename + "</a>&nbsp;"
                                 }

                         }    

                         if (tranf_log_det.transf_tipo == 'DTS' && tranf_log_det.estado_det.toLowerCase() == "terminado" && tranf_log_det.error.numError == 0)
                               log = "&nbsp;<a href='javascript:fn_DTS_log(\"" + tranf_log_det["error"]['debug_src'] + "\",\"" + nvFW.pageContents.filtroRm_DTSRun_res + "\")'>log DTS</a>"


                         img_parametro = '&nbsp;'
                         if ((rs.position == 0 || tranf_log_det['transf_tipo'] != 'DTS' && tranf_log_det['transf_tipo'] != 'INF' && tranf_log_det['transf_tipo'] != 'EXP') && tranf_log_det['estado_det'] == 'terminado' && tranf_log_det['id_transf_log_det'] > 0) {
                             img_parametro = "<img title='Parámetros' onclick='mostrar_transf_parametros(" + tranf_log_det['id_transf_log_det'] + ", \"" + "Parámetros Entrada: " + tranf_log_det['transferencia'] + tranf_log_det['nombre_transf_det'] + "\", " + ((nvFW.pageContents.permiso_ver_parametros) > 0) + ",\"" + nvFW.pageContents.filtroVertransf_log_param + "\")' style='cursor:pointer;cursor:hand' src='/FW/image/transferencia/variable.png'/>"
                           //  img_parametro += "&nbsp;<img title='Exportar' onclick='exportar(" + tranf_log_det['id_transf_log_det'] + ", \"" + "Parámetros Entrada: " + tranf_log_det['transferencia'] + "\")' style='cursor:pointer;cursor:hand' src='/FW/image/transferencia/descargar.png'/>"

                         }

                         strHTML += "<tr><td style='width:15%;text-align:center' title='Nro. Log Transf. Det: " + tranf_log_det['id_transf_log_det'] + "'>" + tranf_log_det['id_transf_det'] + "</td><td style='width:30%' title='" + tranf_log_det['transferencia'] + " " + tranf_log_det['nombre_transf_det'] + "'>" + tranf_log_det['transferencia'] + tranf_log_det['nombre_transf_det'] + "</td><td style='width:15%;" + class_name + "'>" + txtEstado + " - " + tranf_log_det['login_det'] + "</td><td>" + link + "</td><td style='width:20%'>" + log + "</td><td style='width:6%;text-align:center'>" + tranf_log_det['time_sec'] + "</td><td style='width:6%;text-align:center'>" + img_parametro + "</td></tr>"
                         rs.movenext()
                     }
                     
                     strHTML += "</table>"

                     $('divCuerpo').innerHTML = ''
                     $('divCuerpo').insert({ top: strHTML })
                     window_onresize()
                     
                     if (typeof (tranf_log_det) == 'object')
                     {
                         if (tranf_log_det['estado'].toLowerCase() == 'finalizado' || tranf_log_det['estado'].toLowerCase() == 'pendiente' || tranf_log_det['estado'].toLowerCase() == 'error') 
                         {
                          if (interval > 0) 
                           {
                             window.clearInterval(interval)
                             interval = undefined
                             if (estado == 'INI')
                              {
                               estado = tranf_log_det['estado'] == 'finalizado' ? 'FIN' : tranf_log_det['estado'] == 'pendiente' ? 'PEN' : tranf_log_det['estado'] == 'error' ? 'ERR' : 'INI'
                               title = "<table><tr style='font-size:10pt;font-weight:bold'><td colspan='2'>" + id_transf_log + " - (" + tranf_log_det['id_transferencia'] + ") " + tranf_log_det['nombre'] + "</td></tr><tr style='font-size:8pt'><td>Fecha Inicio:</td><td>[" + tranf_log_det['fe_inicio'] + "]</td></tr><tr style='font-size:8pt'><td>Fecha Finalización:</td><td>" + "[" + tranf_log_det['fe_fin'] + "]</td></tr><tr style='font-size:8pt'><td>Operador:</td><td>" + tranf_log_det['nombre_operador'] + "</td></tr><tr style='font-size:8pt'><td>Estado:</td><td><b>" + tranf_log_det['estado'].toUpperCase() + "</b>&nbsp;<span id='spanCTRL'>" + getDuracion(new Date(tranf_log_det['fe_inicio']), new Date(tranf_log_det['fe_fin_det'])) + "</span></td></tr></table>"
                               $("divTitulo").innerHTML = ''
                               $('divTitulo').insert({ top: HTMLTitle()})
                               }
                           }
                        }    
                     
                       if (interval === null) 
                       {
                         interval = setInterval("pool_control_ejecucion()", 1000)
                         win.options.userData['interval'] = interval
                        }
                     }  
                 }
                 catch (e) {
                     
                     if (interval > 0)
                         window.clearInterval(interval)
                 }
             }

             rs.open(nvFW.pageContents.filtroVerTransf_log_det, "", "<criterio><select><campos></campos><filtro><id_transf_log type='igual'>" + id_transf_log + "</id_transf_log></filtro><orden>fe_fin_det</orden></select></criterio>", "", "")
         }
         catch (e) {
             
             if (interval > 0)
               window.clearInterval(interval)
         }
     }
     
function enter_onkeypress(e) {
    key = Prototype.Browser.IE ? e.keyCode : e.which
    if (key == 13)
        cargar_control()
}

var estado
var id_transferencia 
var nombre 
var fe_inicio
var fe_fin 
var nombre_operador 
var operador 
var title
    

function windows_onload() 
   {
    //vListButtons.MostrarListButton()
    var rs = new tRS()
    rs.async = true
    rs.xml_format = 'rs_xml_json'
    rs.onComplete = function (rs) {
        if (!rs.eof()) {

            id_transferencia = rs.getdata('id_transferencia')
            nombre = rs.getdata('nombre')
            fe_inicio = rs.getdata("fe_inicio") == null ? '' : FechaToSTR((rs.getdata("fe_inicio"))) + " " + HoraToSTR((rs.getdata("fe_inicio")))
            fe_fin = rs.getdata("fe_fin") == null ? '' : FechaToSTR((rs.getdata("fe_fin"))) + " " + HoraToSTR((rs.getdata("fe_fin")))
            nombre_operador = rs.getdata('nombre_operador')
            operador = rs.getdata('operador')
            estado = rs.getdata('estado')
            title = "<table><tr style='font-size:10pt;font-weight:bold'><td colspan='2'>" + id_transf_log + " - (" + id_transferencia + ") " + nombre + "</td></tr><tr style='font-size:8pt'><td>Fecha Inicio:</td><td>[" + fe_inicio + "]</td></tr><tr style='font-size:8pt'><td>Fecha Finalización:</td><td>" + "[" + fe_fin + "]</td></tr><tr style='font-size:8pt'><td>Operador:</td><td>" + nombre_operador + "</td></tr><tr style='font-size:8pt'><td>Estado:</td><td>" + estado + "&nbsp;<span id='spanCTRL'></span></td></tr></table>"
            resumen = !rs.getdata('resumen') ? '' : rs.getdata('resumen')

            try {
                win.setTitle("<b>" + nombre +". " + resumen + "</b>")
               }
            catch (e) { }

            switch (estado.toLowerCase()) {
                case 'finalizado':
                    estado = 'FIN'
                    break;
                case 'pendiente':
                    estado = 'PEN'
                    break;
                case 'error':
                    estado = 'ERR'
                    break;
                case 'terminado':
                    estado = 'FIN'
                    break;
                default:
                    estado = 'INI'
                    break;
            }

            $("divTitulo").insert({ top: HTMLTitle() })
            pool_control_ejecucion()
        }
    }
    rs.open(nvFW.pageContents.filtroVerTransf_log_cab, "", "", "", "")

   
   }

function window_onresize() {
     try {
         var dif = Prototype.Browser.IE ? 5 : 2
         var body_height = $$('BODY')[0].getHeight()
         var divTitulo_h = $("divTitulo").getHeight()
         var tbPie_h = $('tbPie').getHeight()

         $("divCuerpo").setStyle({ height: body_height - divTitulo_h - tbPie_h - dif })
     } catch (e) { }
 }


function exportarTareasParams(id_transf_log)
  {
   var filtroWhere = "<criterio><procedure><parametros><id_transf_log DataType='int'>"+ id_transf_log +"</id_transf_log></parametros></procedure></criterio>"
        nvFW.exportarReporte({
            filtroXML: nvFW.pageContents.filtroVertransf_log_paramALL,
            path_xsl: "/report/Excel_base.xsl",
            filtroWhere: filtroWhere,
            filename: "excelControlValoresParamtros_" + id_transf_log + ".xls",
            ContentType: "application/vnd.ms-excel"
        });                   
}

function reload_transf(id_transf_log, e)
{

    
    if (!nvFW.tienePermiso("permisos_transferencia_ejecutar", 3)) {
       alert('No posee los permisos necesarios para realizar esta acción.')
       return
    }

    Dialog.confirm("¿Desea volver a ejecutar el proceso?", {  width: 300,
                                                                 className: "alphacube",
                                                                 okLabel: "Si",
                                                                 cancelLabel: "No",
                                                                 onOk: function(w){
																 
                                                                                   for (var id_transf_log_det in transf_log_dets)
                                                                                       break;

                                                                                   if (!id_transf_log_det)
                                                                                       return

                                                                                   var oXML = new tXML()
                                                                                   oXML.method = "POST"
                                                                                   var URL = 'transf_seguimiento_pool_control_exec.aspx'
                                                                                   oXML.load(URL, 'modo=reejecutar&id_transf_log_det='+ id_transf_log_det +'&id_transferencia=' + id_transferencia)

                                                                                   try {

                                                                                      var err = new tError()
                                                                                      err.error_from_xml(oXML)
       
                                                                                       if (err.numError != 0) 
                                                                                          alert(err.mensaje)

                                                                                    }
                                                                                   catch (e) { }
																				   
																				   if(!win.options.userData)
																					 win.options.userData={}

																				   win.options.userData.actualizar = true
																				   //win.options.userData.onclose();
																				   win.close()
																				   w.close()


                                                                          },
                                                                 onCancel: function(w) { w.close(); return }
                                                              });

 }            

var arExportar = {}
var winExportar
function exportar(id_transf_log_det,titulo)
 {
    
    arExportar = {}
    arExportar.id_transf_log_det = id_transf_log_det
    arExportar.titulo = titulo

    winExportar = nvFW.createWindow({
                    width: 400, height: 150, zIndex: 100,
                    draggable: false,
                    resizable: false,
                    closable: true,
                    minimizable: false,
                    maximizable: false,
                    title: "<b>Exportar Log nº: " + id_transf_log + "</b>",
                    onShow: function (win) {  }
                })
    winExportar.getContent().innerHTML = $('divSeleccion').innerHTML
    winExportar.showCenter(true);

 }


function btnAceptar_onclick(tipo_salida)
  {
    
    if (!arExportar.id_transf_log_det)
        arExportar.id_transf_log_det = 0

    if (!arExportar.titulo)
        arExportar.titulo = "Exportar Log Nº: " + id_transf_log

    var filtroXML = nvFW.pageContents.filtroverTransf_log_param_colum
    var filtroWhere = "<criterio><procedure><parametros><id_transf_log DataType='int'>" + id_transf_log + "</id_transf_log><id_transf_log_det DataType='int'>"+ arExportar.id_transf_log_det +"</id_transf_log_det><filtro_params>" + $("parametro").value + "</filtro_params></parametros></procedure></criterio>"

    var path_xsl= "\\report\\HTML_base.xsl"
    var ContentType = ""  
    var filename =  ""

    if (tipo_salida != 'HTML') {
        path_xsl = "\\report\\Excel_base.xsl"
        ContentType = "application/vnd.ms-excel"
        filename = "ExcelControlParamtros_" + id_transf_log + ".xls"

        nvFW.exportarReporte({
            filtroXML: filtroXML
            , filtroWhere: filtroWhere
            , salida_tipo: "adjunto"
            , formTarget: "_blank"
            , path_xsl: path_xsl
            , ContentType: ContentType
            , filename: filename
        });
    }
    else {

        window.top.nvFW.exportarReporte({
            filtroXML: filtroXML
            , filtroWhere: filtroWhere
            , path_xsl: path_xsl
            , formTarget: 'winPrototype'
            , nvFW_mantener_origen: true
            , id_exp_origen: 0
            , winPrototype: {
                modal: false,
                center: true,
                bloquear: false,
                url: 'enBlanco.htm',
                title: '<b>' + arExportar.titulo + '</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 700,
                height: 180,
                resizable: true,
                destroyOnClose: true
            }
        });
    }

  }

 function btnCancelar_onclick(){
   winExportar.close()
 }

function salir() {
 win.close()
}

    </script>
</head>
<body onload="windows_onload()" onresize="return window_onresize()" style="width: 100%; height: 100%; overflow: hidden; margin: 0px; padding: 0px; background-color: white ">
<div id="divTitulo" style='width:100%'></div>
<div id='divCuerpo' style='width:100%;overflow:auto'></div>
     <table class="tb1" id="tbPie">
        <tr>
          <td style="width:35%">&#160;</td>
          <td><input type="button" style="width:100%;cursor:pointer" value ="Exportar" onclick="exportar(0,'Exportar log')" /></td>
          <td style="width:10%">&#160;</td>
          <td><input type="button" style="width:100%;cursor:pointer" value ="Cancelar" onclick="salir()" /></td>
          <td style="width:35%">&#160;</td>
        </tr>
      </table>
<div id="divSeleccion" style="display:none;width:100%">
 <table class="tb1" id="tbSeleccion" style="width:100%">
      <tr>
         <td class="Tit2" colspan="2" style="width: 100%; text-align: center">&nbsp;Selector de parámetros</td>
     </tr>
     <tr>
         <td colspan="2"><%= nvCampo_def.get_html_input("parametro", enDB:=False, filtroXML:="<criterio><select vista='verTransf_log_param'><campos>distinct parametro as [id],parametro as [campo]</campos><filtro><id_transf_log type='igual'>" & id_transf_log & "</id_transf_log></filtro><orden></orden></select></criterio>", nro_campo_tipo:=2)  %></td>
     </tr>
     <tr>
         <td>
             <br><br>
         </td>
     </tr>
     <tr>
         <td style="width: 100%; text-align: center; vertical-align: middle;margin-top:20px" colspan="2">
             <table style="width: 100%">
                 <tr>
                     <td style="width: 10%; text-align: center">&nbsp;</td>
                     <td style="width: 20%; text-align: center">
                             <input type="button" id="btnAceptar_xls" onclick="btnAceptar_onclick('XLS')" value="Excel" style="width: 100%;cursor:pointer" />
                     </td>
                     <td style="width: 5%; text-align: center">&nbsp;</td>
                     <td style="width: 20%; text-align: center">
                             <input type="button" id="btnAceptar_html" onclick="btnAceptar_onclick('HTML')" value="HTML" style="width: 100%;cursor:pointer" />
                     </td>
                     <td style="width: 5%; text-align: center">&nbsp;</td>
                     <td style="width: 20%;text-align: center">
                             <input type="button" id="btnCancelar_pwd" onclick="btnCancelar_onclick()" value="Salir" style="width: 100%;cursor:pointer" />
                     </td>
                      <td style="width: 10%; text-align: center">&nbsp;</td>
                 </tr>
             </table>
         </td>
     </tr>
 </table>
 </div>
</body>
</html>
