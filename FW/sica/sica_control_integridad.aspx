<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim err As nvFW.tError
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Me.contents("modo") = modo
    Dim header_xml As String = "<?xml version='1.0' encoding='iso-8859-1'?>"
    Dim cod_sistema_version As Integer = nvApp.cod_sistema_version
    Me.contents("cod_sistema_version") = cod_sistema_version


    Select Case modo
        Case "currentApp"
            Dim accion As String = nvUtiles.obtenerValor("accion", "")

            Select Case accion
                Case "currentAppRun"
                    Dim cod_modulo_versiones As String = nvUtiles.obtenerValor("cod_modulo_versiones", "")
                    Dim cod_obj_tipos As String = nvUtiles.obtenerValor("cod_obj_tipos", "")
                    Dim filtroObjeto As String = nvUtiles.obtenerValor("filtroObjeto", "")
                    Dim filtroFechaMod As DateTime = DateTime.Parse(nvUtiles.obtenerValor("filtroFechaMod", "1/1/1980 00:00:00"))

                    err = nvSICA.currentApp.control_integridad_iniciar(cod_modulo_versiones, cod_obj_tipos, filtroObjeto, filtroFechaMod)
                    err.response()


                Case "currentAppAbort"
                    err = nvSICA.currentApp.control_integridad_abortar()
                    err.response()


                Case "currentAppRes"
                    Dim strXML As String = ""

                    If nvApp.sica_control IsNot Nothing Then
                        strXML = "<resultado>" &
                                    "<nvApp cod_sistema='" & nvApp.cod_sistema & "'" &
                                          " cod_sistema_version='" & cod_sistema_version & "'" &
                                          " sistema='" & nvApp.sistema & "'" &
                                          " fe_inicio='" & nvApp.sica_control.fe_inicio.ToString & "'" &
                                          " fe_fin='" & If(nvApp.sica_control.thread.IsAlive, "", nvApp.sica_control.fe_fin.ToString()) & "'" &
                                          " elapseSeconds='" & If(nvApp.sica_control.thread.IsAlive, "", DateDiff(DateInterval.Second, nvApp.sica_control.fe_inicio, nvApp.sica_control.fe_fin)) & "'" &
                                          " pg_count='" & nvApp.sica_control.pg_count & "'" &
                                          " pg_pos='" & nvApp.sica_control.pg_pos & "'" &
                                          " pi_count='" & nvApp.sica_control.pi_count & "'" &
                                          " pi_pos='" & nvApp.sica_control.pi_pos & "'" &
                                          " total_count='" & nvApp.sica_control.total_count & "'" &
                                          " status='" & nvApp.sica_control.status & "'" &
                                          " status_err_msg='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.status_err_msg) & "'" &
                                          " progress_info='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.progress_info) & "'>"

                        If Not nvApp.sica_control.thread.IsAlive Then
                            Dim extension As String

                            For Each elemento As nvSICA.tResElement In nvApp.sica_control.elements
                                extension = IO.Path.GetExtension(elemento.objeto)
                                strXML &= "<resElement" &
                                            " path='" & elemento.path & "'" &
                                            " objeto='" & elemento.objeto & "'" &
                                            " extension='" & extension & "'" &
                                            " resStatus='" & elemento.resStatus & "'" &
                                            " resStatusDesc='" & elemento.resStatus.ToString() & "'" &
                                            " cod_pasaje='" & elemento.cod_pasaje & "'" &
                                            " cod_objeto='" & elemento.cod_objeto & "'" &
                                            " cod_obj_tipo='" & elemento.cod_obj_tipo & "'" &
                                            " cod_sub_tipo='" & elemento.cod_sub_tipo & "'" &
                                            " cod_modulo_version='" & elemento.cod_modulo_version & "'" &
                                            " depende_de='" & elemento.depende_de & "'" &
                                            " comentario='" & nvXMLUtiles.escapeXMLAttribute(elemento.comentario) & "' />"
                            Next

                        End If

                        strXML &= "</nvApp></resultado>"
                    Else
                        strXML = "<resultado>" &
                                    "<nvApp cod_sistema='" & nvApp.cod_sistema & "'" &
                                          " cod_sistema_version='" & cod_sistema_version & "'" &
                                          " sistema='" & nvApp.sistema & "'" &
                                          " fe_inicio=''" &
                                          " fe_fin=''" &
                                          " pg_count=''" &
                                          " pg_pos=''" &
                                          " pi_count=''" &
                                          " pi_pos=''" &
                                          " elapseSeconds=''" &
                                          " total_count='0'" &
                                          " status=''" &
                                          " status_err_msg=''" &
                                          " progress_info=''>" &
                                    "</nvApp>" &
                                 "</resultado>"
                    End If

                    Response.ContentType = "text/xml"
                    Response.Write(header_xml & strXML)
                    Response.End()

            End Select


        Case "selectedApp"
            Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor", "")
            Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema", "")
            Dim port As String = nvUtiles.obtenerValor("port", "")

            Me.contents("consulta_ports") = nvXMLSQL.encXMLSQL("<criterio><select vista='nv_servidor_ports'><campos>distinct port_https as id, port_https as campo</campos><filtro><cod_servidor type='igual'>'" & cod_servidor & "'</cod_servidor></filtro></select></criterio>")
            Me.contents("cod_servidor") = cod_servidor
            Me.contents("cod_sistema") = cod_sistema
            Me.contents("port") = port

            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT cod_sistema_version FROM nv_servidor_sistemas WHERE cod_servidor='" & cod_servidor & "' AND cod_sistema='" & cod_sistema & "'")
            cod_sistema_version = nvUtiles.isNUll(rs.Fields("cod_sistema_version").Value, 0)
            Me.contents("cod_sistema_version") = cod_sistema_version
            nvDBUtiles.DBCloseRecordset(rs)

            Dim accion As String = nvUtiles.obtenerValor("accion", "")

            Select Case accion
                Case "selectedAppRun"
                    Dim cod_modulo_versiones As String = nvUtiles.obtenerValor("cod_modulo_versiones", "")
                    Dim cod_obj_tipos As String = nvUtiles.obtenerValor("cod_obj_tipos", "")
                    Dim filtroObjeto As String = nvUtiles.obtenerValor("filtroObjeto", "")
                    Dim filtroFechaMod As DateTime = DateTime.Parse(nvUtiles.obtenerValor("filtroFechaMod", "1/1/1980 00:00:00"))

                    Dim app As New nvFW.tnvApp
                    app.loadFromDefinition(cod_servidor, cod_sistema, port)

                    If nvFW.nvSession.Contents("nvIntegrityControls") Is Nothing Then
                        nvFW.nvSession.Contents("nvIntegrityControls") = New Dictionary(Of String, nvFW.tnvApp)
                    End If

                    Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                    Dim nvIntegrityControls As Dictionary(Of String, nvFW.tnvApp) = nvFW.nvSession.Contents("nvIntegrityControls")

                    If nvIntegrityControls.ContainsKey(key) Then
                        nvIntegrityControls(key) = app
                    Else
                        nvIntegrityControls.Add(key, app)
                    End If

                    err = nvSICA.Implementation.control_integridad_iniciar(app, cod_modulo_versiones, cod_obj_tipos, filtroObjeto, filtroFechaMod)
                    err.response()


                Case "selectedAppAbort"
                    Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                    Dim app As nvFW.tnvApp = nvFW.nvSession.Contents("nvIntegrityControls")(key)

                    err = nvSICA.Implementation.control_integridad_abortar(app)
                    err.response()


                Case "selectedAppRes"
                    Dim strXML As String = ""
                    Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                    Dim nvApp As nvFW.tnvApp = Nothing
                    Dim nvIntegrityControls As Dictionary(Of String, nvFW.tnvApp) = nvFW.nvSession.Contents("nvIntegrityControls")

                    If Not nvIntegrityControls Is Nothing AndAlso nvIntegrityControls.ContainsKey(key) Then
                        nvApp = nvFW.nvSession.Contents("nvIntegrityControls")(key)
                    End If


                    If Not nvApp Is Nothing AndAlso Not nvApp.sica_control Is Nothing Then
                        strXML = "<resultado>" &
                                    "<nvApp cod_sistema='" & nvApp.cod_sistema & "'" &
                                          " cod_sistema_version='" & cod_sistema_version & "'" &
                                          " sistema='" & nvApp.sistema & "'" &
                                          " fe_inicio='" & nvApp.sica_control.fe_inicio.ToString & "'" &
                                          " fe_fin='" & If(nvApp.sica_control.thread.IsAlive, "", nvApp.sica_control.fe_fin.ToString()) & "'" &
                                          " elapseSeconds='" & If(nvApp.sica_control.thread.IsAlive, "", DateDiff(DateInterval.Second, nvApp.sica_control.fe_inicio, nvApp.sica_control.fe_fin)) & "'" &
                                          " pg_count='" & nvApp.sica_control.pg_count & "'" &
                                          " pg_pos='" & nvApp.sica_control.pg_pos & "'" &
                                          " pi_count='" & nvApp.sica_control.pi_count & "'" &
                                          " pi_pos='" & nvApp.sica_control.pi_pos & "'" &
                                          " total_count='" & nvApp.sica_control.total_count & "'" &
                                          " status='" & nvApp.sica_control.status & "'" &
                                          " status_err_msg='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.status_err_msg) & "'" &
                                          " progress_info='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.progress_info) & "'>"

                        If Not nvApp.sica_control.thread.IsAlive Then
                            Dim extension As String

                            For Each element As nvSICA.tResElement In nvApp.sica_control.elements
                                extension = IO.Path.GetExtension(element.objeto)
                                strXML &= "<resElement" &
                                            " path='" & element.path & "'" &
                                            " objeto='" & element.objeto & "'" &
                                            " extension='" & extension & "'" &
                                            " resStatus='" & element.resStatus & "'" &
                                            " resStatusDesc='" & element.resStatus.ToString() & "'" &
                                            " cod_pasaje='" & element.cod_pasaje & "'" &
                                            " cod_objeto='" & element.cod_objeto & "'" &
                                            " cod_obj_tipo='" & element.cod_obj_tipo & "'" &
                                            " cod_sub_tipo='" & element.cod_sub_tipo & "'" &
                                            " cod_modulo_version='" & element.cod_modulo_version & "'" &
                                            " depende_de='" & element.depende_de & "'" &
                                            " comentario='" & nvXMLUtiles.escapeXMLAttribute(element.comentario) & "' />"
                            Next
                        End If

                        strXML &= "</nvApp></resultado>"
                    Else
                        strXML = "<resultado>" &
                        "<nvApp cod_sistema='" & cod_sistema & "'" &
                              " cod_sistema_version=''" &
                              " sistema=''" &
                              " fe_inicio=''" &
                              " fe_fin=''" &
                              " pg_count=''" &
                              " pg_pos=''" &
                              " pi_count=''" &
                              " pi_pos=''" &
                              " elapseSeconds=''" &
                              " total_count='0'" &
                              " status=''" &
                              " status_err_msg=''" &
                              " progress_info=''>" &
                        "</nvApp>" &
                     "</resultado>"
                    End If

                    Response.ContentType = "text/xml"
                    Response.Write(header_xml & strXML)
                    Response.End()

            End Select
    End Select


    Me.contents("server_name") = nvApp.cod_servidor
    Me.contents("filtro_ordenar_xml") = nvXMLSQL.encXMLSQL("<criterio><procedure expire_minutes='1' cacheControl='Session' AbsolutePage='1' CommandText='dbo.sica_control_integridad_ordenar_xml'></procedure></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>SICA Control de Integridad</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        td { white-space: nowrap; }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/sicaObjetoUtils.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var interval
        var interval_seg
        var interval_ms = 2000;
        var interva_seg_count = 0
        var proceso_activo;
        var contador_bloqueos = 0;
        var flag_reporte_exportado = false;

        var cod_servidor
        var cod_sistema
        var port

        var $tdStatus
        var $btnAbortar
        var $btnIniciar
        var $iFrameRes



        function sica_control_integridad_iniciar()
        {
            // Ocultar botones "Actualizar Definicion" y "Actualizar Implementacion"
            toogleUpdateButtons(false);
            flag_reporte_exportado = false;

            var fe_mod_date = $('fe_mod_date').value;

            if (!fe_mod_date)
            {
                fe_mod_date = '01/01/1900';
            }

            var filtroFechaMod  = fe_mod_date + ' ' + $('fe_mod_time').value;
            var str_modo_accion = '';

            if (nvFW.pageContents.modo == "currentApp")
            {
                str_modo_accion = "modo=currentApp&accion=currentAppRun";
            }
            else if (nvFW.pageContents.modo == "selectedApp")
            {
                port = campos_defs.get_value('port');

                if (!port)
                {
                    alert("Seleccione el puerto de la aplicación.");
                    return false;
                }

                str_modo_accion = "modo=selectedApp&accion=selectedAppRun&cod_servidor=" + encodeURIComponent(cod_servidor) + "&cod_sistema=" + encodeURIComponent(cod_sistema) + "&port=" + encodeURIComponent(port)
            }

            var err = new tError();
            var filtroObjeto = ""

            if ($("filtroObjeto").value)
            {
                filtroObjeto = $('filtroLike').value == "like" ? "like '%" : "not like '%";
                filtroObjeto += $("filtroObjeto").value.trim();
                filtroObjeto += "%'"
            }

            var urlErrorRequest = "/FW/sica/sica_control_integridad.aspx?" + 
                                                                        str_modo_accion + "&cod_modulo_versiones=" + 
                                                                        campos_defs.value("cod_modulo_versiones") + 
                                                                        "&cod_obj_tipos=" + campos_defs.value("cod_obj_tipos") + 
                                                                        "&filtroObjeto=" + encodeURIComponent(filtroObjeto) +
                                                                        "&filtroFechaMod=" + encodeURIComponent(filtroFechaMod);

            err.request(urlErrorRequest, 
                {
                    asynchronous: false,
                    error_alert: false
                });

            if (err.numError == 0)
            {
                $iFrameRes.src = "about:blank";
                $btnIniciar.hide();
                $btnAbortar.show();

                if (nvFW.pageContents.modo == "selectedApp")
                {
                    campos_defs.habilitar("port", false);
                }

                interval = window.setInterval("sica_control_res()", interval_ms);
                $tdStatus.innerHTML = "Ejecutando...";
                proceso_activo = true;
            }
            else
            {
                alert(err.numError + ":" + err.mensaje);
            }
        }



        function sica_control_integridad_abortar()
        {
            $tdStatus.innerHTML = '<i>Control abortado...</i>';
            $tdStatus.setStyle({ background: "inherit" });
            $btnAbortar.hide();
            $btnIniciar.show();
            var str_modo_accion     = '';
            var err                 = new tError();

            if (nvFW.pageContents.modo == "currentApp")
            {
                str_modo_accion = "modo=currentApp&accion=currentAppAbort";
                err.request("/FW/sica/sica_control_integridad.aspx?" + str_modo_accion, { asynchronous: false, error_alert: false });
            }
            else if (nvFW.pageContents.modo == "selectedApp")
            {
                str_modo_accion = "modo=selectedApp&accion=selectedAppAbort&cod_servidor=" + encodeURIComponent(cod_servidor) + "&cod_sistema=" + encodeURIComponent(cod_sistema) + "&port=" + encodeURIComponent(port);
                err.request("/FW/sica/sica_control_integridad.aspx?" + str_modo_accion, { asynchronous: false, error_alert: false });
            }

            if (err.numError != 0)
            {
                alert(err.numError + ":" + err.mensaje);
            }

            window.clearInterval(interval)
        }



        function sica_control_res()
        {
            window.top.nvSesion.usuario_accion();   // Emitir una accion de usuario para evitar el bloqueo de pantalla

            var oXML = new tXML();
            oXML.async = true;
            oXML.onComplete = function (oXML)
            {
                var fe_inicio = this.selectSingleNode("resultado/nvApp/@fe_inicio").nodeValue;
                var fe_fin    = this.selectSingleNode("resultado/nvApp/@fe_fin").nodeValue;

                if (fe_inicio && fe_fin)
                {
                    var status_err_msg = this.selectSingleNode("resultado/nvApp/@status_err_msg").nodeValue;

                    if (status_err_msg)
                    {
                        alert("El proceso finalizó debido a un error: " + status_err_msg);
                    }

                    $btnAbortar.hide();
                    $btnIniciar.show();

                    if (nvFW.pageContents.modo == "selectedApp")
                    {
                        campos_defs.habilitar("port", true);
                    }

                    
                    window.clearInterval(interval);
                    proceso_activo      = false;
                    var elapseSeconds   = this.selectSingleNode("resultado/nvApp/@elapseSeconds").nodeValue;
                    var total_count     = this.selectSingleNode("resultado/nvApp/@total_count").nodeValue;
                    $tdStatus.innerHTML = "Tiempo de ejecucion " + elapseSeconds + " segundos (" + total_count + " objetos)";
                    

                    if (!flag_reporte_exportado)
                    {
                        // Llamar a la exportación
                        var filtroWhere = "<criterio><procedure PageSize='3000'>";
                        filtroWhere += "<parametros>";
                        filtroWhere += "<select><campos>*</campos><filtro></filtro><orden></orden><grupo></grupo></select>";
                        filtroWhere += "<strXML><![CDATA[" + this.toString() + "]]></strXML>";
                        filtroWhere += "</parametros>";
                        filtroWhere += "</procedure></criterio>";

                        contador_bloqueos++;

                        nvFW.exportarReporte(
                        {
                            filtroXML:            nvFW.pageContents.filtro_ordenar_xml,
                            filtroWhere:          filtroWhere,
                            path_xsl:             "report\\verResIntegridad\\verResIntegridad.xsl",
                            nvFW_mantener_origen: true,
                            salida_tipo:          "adjunto",
                            formTarget:           "iFrameRes",
                            cls_contenedor:       "iFrameRes",
                            cls_contenedor_msg:   " ",
                            bloq_contenedor:      "iFrameRes",
                            bloq_msg:             "Cargando resultado...",
                            bloq_id:              'vidrio_sica_integridad_' + contador_bloqueos
                        });

                        flag_reporte_exportado = true;
                    }
                    

                    $tdStatus.setStyle({ background: "inherit" });

                    return;
                }
                else if (fe_inicio && !fe_fin)
                {
                    var pg_count = this.selectSingleNode("resultado/nvApp/@pg_count").nodeValue;
                    var pg_pos   = this.selectSingleNode("resultado/nvApp/@pg_pos").nodeValue;
                    var pi_count = this.selectSingleNode("resultado/nvApp/@pi_count").nodeValue;
                    var pi_pos   = this.selectSingleNode("resultado/nvApp/@pi_pos").nodeValue;
                    var percent  = ((pi_pos / pi_count) * 100).toFixed(2);
                    
                    $btnIniciar.hide();
                    $btnAbortar.show();
                    $tdStatus.innerHTML = "Ejecutando (" + pg_pos + " de " + pg_count + ")(" + pi_pos + " de " + pi_count + ")";
                    $tdStatus.setStyle({ background: "linear-gradient(to right, #4BB543 0px, #4BB543 " + percent + "%, #a2a2a2 " + percent + "%, #a2a2a2 100%)" });

                    // Cuando se cierra la ventana y se vuelve a abrir, y hay un proceso activo, reactivar el timer
                    if (!interval)
                    {
                        interval = window.setInterval("sica_control_res()", interval_ms);
                        proceso_activo = true;
                    }

                    return;
                }
                else if (!fe_inicio)
                {
                    $btnIniciar.show();
                    $btnAbortar.hide();
                    $tdStatus.innerHTML = "";
                    $iFrameRes.src      = "";
                }
            }

            if (nvFW.pageContents.modo == "currentApp")
            {
                oXML.load("/FW/sica/sica_control_integridad.aspx?modo=currentApp&accion=currentAppRes");
            }
            else if (nvFW.pageContents.modo == "selectedApp")
            {
                oXML.load("/FW/sica/sica_control_integridad.aspx?modo=selectedApp&accion=selectedAppRes&cod_servidor=" + encodeURIComponent(cod_servidor) + "&cod_sistema=" + encodeURIComponent(cod_sistema) + "&port=" + encodeURIComponent(port));
            }
        }



        function window_onload()
        {
            $tdStatus   = $('tdStatus')
            $btnAbortar = $('btnAbortar')
            $btnIniciar = $('btnIniciar')
            $iFrameRes  = $('iFrameRes')

            if (nvFW.pageContents.modo == "selectedApp")
            {
                cod_servidor                = nvFW.pageContents.cod_servidor;
                cod_sistema                 = nvFW.pageContents.cod_sistema;
                $('cod_servidor').innerHTML = cod_servidor;
                $('cod_sistema').innerHTML  = cod_sistema;
                $('tbServidorSistemaPort').style.display = "inline";

                campos_defs.add('port',
                {
                    enDB:           false,
                    nro_campo_tipo: 1,
                    filtroXML:      nvFW.pageContents.consulta_ports,
                    target:         'tdPort'
                });

                campos_defs.items["port"].onchange = function ()
                {
                    port = campos_defs.get_value("port");

                    if (port) {
                        sica_control_res();
                    }
                }
            }
            else
            {
                sica_control_res();
            }

            window_onresize();
        }



        function check_all()
        {
            // Ver si esta activado el checkbox maestro dentro del iframe de objetos
            var iframe      = iframeRef(document.getElementById('iFrameRes'));
            var source      = iframe.getElementById('chbx_master');
            var estadoCheck = source.checked;
            var checkboxes  = iframe.getElementsByName('chbx_group');

            for (var checkbox of checkboxes)
            {
                if (!checkbox.disabled)
                    checkbox.checked = estadoCheck;
            }
        }



        function iframeRef(frameRef)
        {
            return frameRef.contentWindow ? frameRef.contentWindow.document : frameRef.contentDocument;
        }



        function confirmEjecutarAccion(modo)
        {
            var server_name = cod_servidor ? cod_servidor : nvFW.pageContents.server_name.toLowerCase();
            var title       = '';
            var msg         = '';

            if (modo == 1)
            {
                title = '<b>Actualizar definición</b>';
                msg   = '<br/>¿Está seguro que desea actualizar la <b>definición</b> del módulo desde <b>"' + server_name + '"</b>?';
            }
            else
            {
                title = '<b>Actualizar implementación</b>';
                msg   = '<br/>¿Está seguro que desea aplicar los cambios en la <b>implementación</b> de <b>"' + server_name + '"</b>?';
            }

            nvFW.confirm(msg,
            {
                title: title,
                width: 570,
                height: 100,
                onOk: function (win)
                {
                    ejecutarAccionIntegridad(modo);
                    win.close()
                },
                onCancel: function (win)
                {
                    win.close();
                },
                okLabel: 'Aplicar',
                cancelLabel: 'Cancelar'
            });
        }



        // [modo]
        //  1: actualizar definicion
        //  2: actualizar implementacion
        function ejecutarAccionIntegridad(modo)
        {
            var items      = [];
            var items_pos  = [];
            var iframe     = iframeRef(document.getElementById('iFrameRes'));
            var checkboxes = iframe.getElementsByName('chbx_group');
            var row

            for (var i = 0, n = checkboxes.length; i < n; i++)
            {
                if (checkboxes[i].checked)
                {
                    row = checkboxes[i].parentNode.parentNode;  // ->td->tr
                    items.push({
                        cod_modulo_version: row.attributes.cod_modulo_version.value,
                        cod_objeto:         row.attributes.cod_objeto.value,
                        objeto:             row.attributes.objeto.value,
                        path:               row.attributes.path.value,
                        cod_obj_tipo:       row.attributes.cod_obj_tipo.value,
                        resStatus:          row.attributes.resStatus.value,
                        cod_pasaje:         row.attributes.cod_pasaje.value
                    });

                    items_pos.push(checkboxes[i].parentNode.parentNode.rowIndex); // row_pos: checkbox -> td -> tr
                }
            }

            if (!items.length)
            {
                alert("No se han seleccionado objetos");
                return;
            }

            var strItems = "<?xml version='1.0'?>";
            strItems += "<objetos>";
            var item
            var strCod_objeto

            for (var i = 0; i < items.length; i++)
            {
                item = items[i];
                // 1 - si se van a guardar cambios a la definicion:
                // si el objeto es objeto_no_encontrado se envia el cod_objeto para poder eliminarlo desde la definicion

                // 2 - si se va actualizar implementacion:
                // siempre se envia el cod_objeto
                strCod_objeto = "";

                if ((modo == '1' && item.resStatus == '1') || modo == '2')
                {
                    strCod_objeto = "cod_objeto='" + item.cod_objeto + "'";
                }

                strItems += "<objeto cod_modulo_version='" + item.cod_modulo_version + "' " + strCod_objeto + " objeto='" + stringToXMLAttributeString(item.objeto) + "' path='" + stringToXMLAttributeString(item.path) + "' cod_obj_tipo='" + item.cod_obj_tipo + "' resStatus='" + item.resStatus + "' cod_pasaje='" + item.cod_pasaje + "' />"
            }

            strItems += "</objetos>"

            var url      = modo == '1' ? "sica_definicion_abm.aspx" : "sica_implementacion_abm.aspx";
            var curr_app = "true";
            var cod_serv = "";
            var cod_sis  = "";
            var app_port = "";

            if (nvFW.pageContents.modo == "selectedApp")
            {
                curr_app = "false";
                app_port = campos_defs.get_value('port');

                if (!app_port)
                {
                    alert("Seleccione puerto de la aplicación.");
                    return;
                }

                cod_serv = cod_servidor;
                cod_sis  = cod_sistema;
            }

            nvFW.error_ajax_request(url,
            {
                parameters:
                {
                    currentApp:   curr_app,
                    cod_servidor: cod_serv,
                    cod_sistema:  cod_sis,
                    port:         app_port,
                    strItems:     strItems
                },
                onSuccess: function (err)
                {
                    winmod.close();
                },
                onFailure: function (err)
                {
                    alert(err.mensaje, { title: '<b>' + err.titulo + '</b>' });
                },
                bloq_msg: 'Actualizando ' + (modo == 1 ? '<b>definición</b>...' : '<b>implementación</b>...'),
                error_alert: false
            });
        }



        function verObjetoIntegridad(cod_objeto, objeto, path_ori, cod_obj_tipo, extension, status, comentario)
        {
            switch (status)
            {
                // archivo modificado: mostrar el comparador
                case 2:
                    var objetos_complejos = {
                        '7': 'Transferencia', 
                        '9': 'Permiso Grupo', 
                        '10': 'Grupo', 
                        '12': 'Pizarra', 
                        '13': 'Parametro'
                    };
                    var cod_serv = "";
                    var cod_sis  = "";
                    var app_port = "0";

                    if (cod_servidor)
                    {
                        cod_serv = cod_servidor;
                        cod_sis  = cod_sistema;
                        app_port = port;
                    }

                    var diff = {
                        source1: {
                            modo:       'GET_DEF',
                            cod_objeto: cod_objeto
                        },
                        source2: {
                            modo:         'GET_IMP',
                            cod_servidor: cod_serv,
                            cod_sistema:  cod_sis,
                            port:         app_port,
                            objeto:       objeto,
                            path:         path_ori,
                            cod_obj_tipo: cod_obj_tipo,
                            comentario:   comentario
                        }
                    };

                    var win = window.top.nvFW.createWindow(
                    {
                        url:            "/FW/sica/sica_diff_viewer.aspx",
                        title:          '<b>Diff</b>',
                        minimizable:    true,
                        maximizable:    true,
                        draggable:      true,
                        width:          700,
                        height:         350,
                        destroyOnClose: true,
                        recenterAuto:   true
                    });

                    win.options.userData = {
                        es_objeto_complejo: objetos_complejos[cod_obj_tipo] ? true : false,
                        objeto_tipo:        objetos_complejos[cod_obj_tipo],
                        objeto:             objeto,
                        diff:               diff
                    };

                    win.showCenter();
                    break;


                // archivo sobrante, ver de la implementacion
                case 3:
                    mostrarObjetoImplementacion(cod_serv, cod_sis, app_port, objeto, path_ori, cod_obj_tipo, extension);
                    break;


                // objeto no encontrado, ver su definicion
                case 1:
                    mostrarObjetoDefinicion(cod_objeto, cod_obj_tipo, extension);
                    break;
            }
        }



        function window_onresize()
        {
            try
            {
                var body_h    = $$('body')[0].getHeight();
                var divHead_h = $('divHead').getHeight();
                var divFoot_h = $('divFoot').getHeight();
                var h         = body_h - divHead_h - divFoot_h;

                $('divBody').setStyle({ height: h + 'px', overflow: "hidden" });
            }
            catch (e) {}
        }



        function iframeRef(frameRef)
        {
            return frameRef.contentWindow ? frameRef.contentWindow.document : frameRef.contentDocument;
        }



        function toogleUpdateButtons(show)
        {
            show ? $('tablaActualizar').show() : $('tablaActualizar').hide();
            window_onresize();
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="height: 100%; width: 100%; overflow: hidden; background-color: white;">
    <div id="divHead">
        <table id="tbServidorSistemaPort" class="tb1" style="display: none">
            <tr class="tbLabel">
                <td style="text-align: center;">Cod Servidor</td>
                <td style="text-align: center;">Cod Sistema</td>
                <td style="text-align: center;">Puerto</td>
            </tr>
            <tr>
                <td>
                    <span id="cod_servidor"></span>
                </td>
                <td>
                    <span id="cod_sistema"></span>
                </td>
                <td id="tdPort"></td>
            </tr>
        </table>

        <table class="tb1" id='tablaParametros'>
            <tr class="tbLabel">
                <td style="width: 20%; text-align: center;">Módulos</td>
                <td style="width: 20%; text-align: center;">Tipo de objetos</td>
                <td style="width: 20%; text-align: center;">Filtro objetos</td>
                <td colspan="2" style="text-align: center;">Fe. Mod. Desde</td>
                <td id="tdStatus" style="width: 20%; min-width: 270px;">&nbsp;</td>
            </tr>
            <tr>
                <td>
                    <% = nvCampo_def.get_html_input("cod_modulo_versiones", nro_campo_tipo:=2, filtroXML:="<criterio><select vista='vernv_sistema_modulo_version'><campos>cod_modulo_version as id, modulo + ' ' + modulo_numero_version as campo</campos><filtro><cod_sistema_version type='igual'>" & cod_sistema_version & "</cod_sistema_version></filtro></select></criterio>", enDB:=False) %>
                </td>
                <td>
                    <% = nvCampo_def.get_html_input("cod_obj_tipos", nro_campo_tipo:=2, filtroXML:="<criterio><select vista='nv_objeto_tipos'><campos>cod_obj_tipo as id, objeto_tipo as [campo]</campos><orden>[campo]</orden></select></criterio>", enDB:=False) %>
                </td>
                <td>
                    <select id="filtroLike" style="width: 40%; min-width: 105px;">
                        <option value="like" selected="selected">Contiene</option>
                        <option value="notlike">No contiene</option>
                    </select>
                    <input type='text' name='filtroObjeto' id='filtroObjeto' style="width: 60%;" />
                </td>
                <td>
                    <% = nvCampo_def.get_html_input("fe_mod_date", enDB:=False, nro_campo_tipo:=103) %>
                </td>
                <td>
                    <input style="width: 100%" type="text" value="00:00:00" id="fe_mod_time" name="fe_mod_time" />
                </td>
                <td>
                    <input type="button" name="btnIniciar" id="btnIniciar" value="Iniciar" onclick="sica_control_integridad_iniciar()" style="width: 100%; cursor: pointer;" />
                    <input type="button" name="btnAbortar" id="btnAbortar" value="Abortar" onclick="sica_control_integridad_abortar()" style="width: 100%; display: none; cursor: pointer;" />
                </td>
            </tr>
        </table>
    </div>

    <div id="divBody">
        <iframe id="iFrameRes" name="iFrameRes" style="display: block; width: 100%; height: 100%; background-color: White; border: 1px solid #dfdfdf;"></iframe>
    </div>

    <div id="divFoot" style="text-align: center;">
        <table id='tablaActualizar' style="display: none; width: 100%;">
            <tr>
                <td style="width: 50%; text-align: center">
                    <div id="divActualizarDef" style="margin: auto; width: 80%; max-width: 350px;"></div>
                </td>
                <td style="width: 50%; text-align: center">
                    <div id="divActualizarImp" style="margin: auto; width: 80%; max-width: 350px;"></div>
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
        // Botones
        var vButtonItems = {};
        vButtonItems[0]  = {};
        vButtonItems[0].nombre   = "ActualizarDef";
        vButtonItems[0].etiqueta = "Actualizar Definición";
        vButtonItems[0].imagen   = "subir";
        vButtonItems[0].onclick  = "confirmEjecutarAccion(1) ";
        vButtonItems[1] = {};
        vButtonItems[1].nombre   = "ActualizarImp";
        vButtonItems[1].etiqueta = "Actualizar Implementación";
        vButtonItems[1].imagen   = "bajar";
        vButtonItems[1].onclick  = "confirmEjecutarAccion(2)";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
        vListButtons.loadImage("subir", '/FW/image/icons/subir.png');
        vListButtons.loadImage("bajar", '/FW/image/icons/bajar.png');

        vListButtons.MostrarListButton();
    </script>

</body>
</html>