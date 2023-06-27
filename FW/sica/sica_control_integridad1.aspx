<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%


    Dim err As nvFW.tError
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Me.contents("modo") = modo
    Dim header_xml As String = "<?xml version='1.0' encoding='iso-8859-1'?>"

    Dim cod_sistema_version As Integer = nvApp.cod_sistema_version

    If (modo = "currentApp") Then

        cod_sistema_version = nvApp.cod_sistema_version
        Me.contents("cod_sistema_version") = cod_sistema_version

        Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")

        Select Case accion

            Case "currentAppRun"

                Dim cod_modulo_versiones = nvFW.nvUtiles.obtenerValor("cod_modulo_versiones", "")
                Dim cod_obj_tipos = nvFW.nvUtiles.obtenerValor("cod_obj_tipos", "")
                Dim filtroObjeto = nvFW.nvUtiles.obtenerValor("filtroObjeto", "")

                'Dim filtroFechaMod As DateTime = New Date(2016, 6, 20)
                Dim filtroFechaMod As DateTime = DateTime.Parse(nvFW.nvUtiles.obtenerValor("filtroFechaMod", "1/1/1980 00:00:00"))
                err = nvFW.nvSICA.currentApp.control_integridad_iniciar(cod_modulo_versiones, cod_obj_tipos, filtroObjeto, filtroFechaMod)
                err.response()

            Case "currentAppAbort"
                'Dim cod_modulo_versiones = nvFW.nvUtiles.obtenerValor("cod_modulo_versiones", "")
                'Dim cod_obj_tipos = nvFW.nvUtiles.obtenerValor("cod_obj_tipos", "")
                'Dim filtroObjeto = nvFW.nvUtiles.obtenerValor("filtroObjeto", "")
                err = nvFW.nvSICA.currentApp.control_integridad_abortar()
                err.response()

            Case "currentAppRes"
            
                Dim strXML As String = ""
                'nvApp.sica_control
                'nvApp.sica_control.thread.isAlive
                'nvApp.sica_control.elements
                If Not nvApp.sica_control Is Nothing Then

                    strXML = "<resultado><nvApp cod_sistema='" & nvApp.cod_sistema & "' cod_sistema_version='" & nvApp.cod_sistema_version & "' sistema='" & nvApp.sistema & _
                        "' fe_inicio='" & nvApp.sica_control.fe_inicio.ToString & "' fe_fin='" & IIf(nvApp.sica_control.thread.IsAlive, "", nvApp.sica_control.fe_fin.ToString()) & _
                        "' elapseSeconds='" & IIf(nvApp.sica_control.thread.IsAlive, "", DateDiff(DateInterval.Second, nvApp.sica_control.fe_inicio, nvApp.sica_control.fe_fin)) & _
                        "' pg_count='" & nvApp.sica_control.pg_count & "' pg_pos='" & nvApp.sica_control.pg_pos & "' pi_count='" & nvApp.sica_control.pi_count & "' pi_pos='" & nvApp.sica_control.pi_pos & "' total_count='" &
                        nvApp.sica_control.total_count & "' status='" & nvApp.sica_control.status & "' status_err_msg='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.status_err_msg) & "' progress_info='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.progress_info) & "' >"
                    
                    If Not nvApp.sica_control.thread.IsAlive Then
                        For i = 0 To nvApp.sica_control.elements.Count - 1

                            Dim extension As String = System.IO.Path.GetExtension(nvApp.sica_control.elements(i).objeto)
                            strXML += "<resElement path='" & nvApp.sica_control.elements(i).path & "' objeto='" & nvApp.sica_control.elements(i).objeto &
                                "' extension='" & extension & "' resStatus='" & nvApp.sica_control.elements(i).resStatus & "' resStatusDesc='" & nvApp.sica_control.elements(i).resStatus.ToString() &
                                "'  cod_objeto='" & nvApp.sica_control.elements(i).cod_objeto & "' cod_obj_tipo='" & nvApp.sica_control.elements(i).cod_obj_tipo & "' cod_sub_tipo='" & nvApp.sica_control.elements(i).cod_sub_tipo & "'  cod_modulo_version='" & nvApp.sica_control.elements(i).cod_modulo_version & "' cod_pasaje='" &  nvApp.sica_control.elements(i).cod_pasaje & "'/>"
                        Next
                    End If
                    strXML += "</nvApp></resultado>"
                Else
                    strXML = "<resultado><nvApp cod_sistema='" & nvApp.cod_sistema & "' cod_sistema_version='" & nvApp.cod_sistema_version & "' sistema='" & nvApp.sistema & _
                        "' fe_inicio='' fe_fin='' pg_count='' pg_pos='' pi_count='' pi_pos='' elapseSeconds=''" & _
                         "  total_count='0' status='' status_err_msg='' progress_info=''></nvApp></resultado>"
                End If
                
                Response.ContentType = "text/xml"
                Response.Write(header_xml & strXML)
                Response.End()

        End Select



    End If


    If (modo = "selectedApp") Then

        Dim cod_servidor As String = nvFW.nvUtiles.obtenerValor("cod_servidor", "")
        Dim cod_sistema As String = nvFW.nvUtiles.obtenerValor("cod_sistema", "")
        Dim port As String = nvFW.nvUtiles.obtenerValor("port", "")

        Me.contents("consulta_ports") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_servidor_ports'><campos>distinct port_https as id, port_https as campo</campos><filtro><cod_servidor type='igual'>'" & cod_servidor & "'</cod_servidor></filtro></select></criterio>")
        Me.contents("cod_servidor") = cod_servidor
        Me.contents("cod_sistema") = cod_sistema
        Me.contents("port") = port

        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("SELECT cod_sistema_version FROM nv_servidor_sistemas WHERE cod_servidor='" & cod_servidor & "' AND cod_sistema='" & cod_sistema & "'")
        cod_sistema_version = nvFW.nvUtiles.isNUll(rs.Fields("cod_sistema_version").Value, 0)
        Me.contents("cod_sistema_version") = cod_sistema_version
        nvFW.nvDBUtiles.DBCloseRecordset(rs)


        Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")

        Select Case accion

            Case "selectedAppRun"

                Dim cod_modulo_versiones = nvFW.nvUtiles.obtenerValor("cod_modulo_versiones", "")
                Dim cod_obj_tipos = nvFW.nvUtiles.obtenerValor("cod_obj_tipos", "")
                Dim filtroObjeto = nvFW.nvUtiles.obtenerValor("filtroObjeto", "")
                Dim filtroFechaMod As DateTime = DateTime.Parse(nvFW.nvUtiles.obtenerValor("filtroFechaMod", "1/1/1980 00:00:00"))
                Dim app As New nvFW.tnvApp

                app.loadFromDefinition(cod_servidor, cod_sistema, port)

                If (nvFW.nvSession.Contents("nvIntegrityControls") Is Nothing) Then
                    nvFW.nvSession.Contents("nvIntegrityControls") = New Dictionary(Of String, nvFW.tnvApp)
                End If

                Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                Dim nvIntegrityControls As Dictionary(Of String, nvFW.tnvApp) = nvFW.nvSession.Contents("nvIntegrityControls")

                If nvIntegrityControls.ContainsKey(key) Then
                    nvIntegrityControls(key) = app
                Else
                    nvIntegrityControls.Add(key, app)
                End If

                err = nvFW.nvSICA.Implementation.control_integridad_iniciar(app, cod_modulo_versiones, cod_obj_tipos, filtroObjeto, filtroFechaMod)
                err.response()

            Case "selectedAppAbort"

                Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                Dim app As nvFW.tnvApp = nvFW.nvSession.Contents("nvIntegrityControls")(key)
                err = nvFW.nvSICA.Implementation.control_integridad_abortar(app)
                err.response()

            Case "selectedAppRes"

                Dim strXML As String = ""

                Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                Dim nvApp As nvFW.tnvApp

                Dim nvIntegrityControls As Dictionary(Of String, nvFW.tnvApp) = nvFW.nvSession.Contents("nvIntegrityControls")

                If Not nvIntegrityControls Is Nothing Then
                    If nvIntegrityControls.ContainsKey(key) Then
                        nvApp = nvFW.nvSession.Contents("nvIntegrityControls")(key)
                    End If
                End If



                strXML = "<resultado><nvApp cod_sistema='" & cod_sistema & "' cod_sistema_version='' sistema=''" &
                    " fe_inicio='' fe_fin='' pg_count='' pg_pos='' pi_count='' pi_pos='' elapseSeconds=''" &
                    "  total_count='0' status='' status_err_msg='' progress_info=''></nvApp></resultado>"


                If Not nvApp Is Nothing Then
                    If Not nvApp.sica_control Is Nothing Then

                        strXML = "<resultado><nvApp cod_sistema='" & nvApp.cod_sistema & "' cod_sistema_version='" & nvApp.cod_sistema_version & "' sistema='" & nvApp.sistema & _
                            "' fe_inicio='" & nvApp.sica_control.fe_inicio.ToString & "' fe_fin='" & IIf(nvApp.sica_control.thread.IsAlive, "", nvApp.sica_control.fe_fin.ToString()) & _
                            "' elapseSeconds='" & IIf(nvApp.sica_control.thread.IsAlive, "", DateDiff(DateInterval.Second, nvApp.sica_control.fe_inicio, nvApp.sica_control.fe_fin)) & _
                            "' pg_count='" & nvApp.sica_control.pg_count & "' pg_pos='" & nvApp.sica_control.pg_pos & "' pi_count='" & nvApp.sica_control.pi_count & "' pi_pos='" & nvApp.sica_control.pi_pos & "' total_count='" &
                            nvApp.sica_control.total_count & "' status='" & nvApp.sica_control.status & "' status_err_msg='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.status_err_msg) & "' progress_info='" & nvXMLUtiles.escapeXMLAttribute(nvApp.sica_control.progress_info) & "' >"
                        If Not nvApp.sica_control.thread.IsAlive Then
                            For i = 0 To nvApp.sica_control.elements.Count - 1
                                Dim extension As String = System.IO.Path.GetExtension(nvApp.sica_control.elements(i).objeto)
                                strXML += "<resElement path='" & nvApp.sica_control.elements(i).path & "' objeto='" & nvApp.sica_control.elements(i).objeto &
                                      "' extension='" & extension & "' resStatus='" & nvApp.sica_control.elements(i).resStatus & "' resStatusDesc='" & nvApp.sica_control.elements(i).resStatus.ToString() &
                                      "'  cod_objeto='" & nvApp.sica_control.elements(i).cod_objeto & "' cod_obj_tipo='" & nvApp.sica_control.elements(i).cod_obj_tipo & "' cod_sub_tipo='" & nvApp.sica_control.elements(i).cod_sub_tipo & "'  cod_modulo_version='" & nvApp.sica_control.elements(i).cod_modulo_version & "' cod_pasaje='" & nvApp.sica_control.elements(i).cod_pasaje & "' />"
                            Next
                        End If
                        strXML += "</nvApp></resultado>"

                    End If
                End If

                Response.ContentType = "text/xml"
                Response.Write(header_xml & strXML)
                Response.End()

        End Select

    End If

    Me.contents("server_name") = nvApp.cod_servidor
    Me.contents("filtro_ordenar_xml") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure expire_minutes='1' cacheControl='Session' AbsolutePage='1' CommandText='dbo.sica_control_integridad_ordenar_xml'></procedure></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <style type="text/css">
        td
        {
            white-space: nowrap;
        }
    </style>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/sicaObjetoUtils.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">
        var interval
        var interval_seg
        var interva_seg_count = 0
        var proceso_activo;

        var cod_servidor
        var cod_sistema
        var port

        function sica_control_integridad_iniciar() {


            var fe_mod_date = $('fe_mod_date').value
            if (fe_mod_date == "") {
                fe_mod_date = '01/01/1900'
            }

            var filtroFechaMod = fe_mod_date + ' ' + $('fe_mod_time').value
            var str_modo_accion = ""

            if (nvFW.pageContents["modo"] == "currentApp") {
                str_modo_accion = "modo=currentApp&accion=currentAppRun"

            } else if (nvFW.pageContents["modo"] == "selectedApp") {
                port = campos_defs.get_value('port')
                if (!port) {
                    alert("Seleccione puerto de la aplicación.")
                    return
                }
                str_modo_accion = "modo=selectedApp&accion=selectedAppRun&cod_servidor=" + encodeURIComponent(cod_servidor) + "&cod_sistema=" + encodeURIComponent(cod_sistema) + "&port=" + encodeURIComponent(port)
            }


            var err = new tError()
            err.request("/FW/sica/sica_control_integridad.aspx?" + str_modo_accion + "&cod_modulo_versiones=" +
                campos_defs.value("cod_modulo_versiones") + "&cod_obj_tipos=" + campos_defs.value("cod_obj_tipos") + "&filtroObjeto=" +
                $("filtroObjeto").value + "&filtroFechaMod=" + encodeURIComponent(filtroFechaMod), { asynchronous: false, error_alert: false })

            if (err.numError == 0) {

                $('iFrameRes').src = "about:blank"
                $("btnIniciar").hide()
                $("btnAbortar").show()

                if (nvFW.pageContents["modo"] == "selectedApp") {
                    campos_defs.habilitar("port", false)
                }

                interval = window.setInterval("sica_control_res()", 4000)
                $("tdStatus").innerHTML = "Ejecutando..."
                proceso_activo = true
                //proc_iniciado = true

            }
            else {
                alert(err.numError + ":" + err.mensaje)
            }
        }




        function sica_control_integridad_abortar() {
            var err = new tError()
            $("btnIniciar").show()
            $("btnAbortar").hide()

            var str_modo_accion = ""
            if (nvFW.pageContents["modo"] == "currentApp") {
                str_modo_accion = "modo=currentApp&accion=currentAppAbort"
                err.request("/FW/sica/sica_control_integridad.aspx?" + str_modo_accion, { asynchronous: false, error_alert: false })

            } else if (nvFW.pageContents["modo"] == "selectedApp") {

                str_modo_accion = "modo=selectedApp&accion=selectedAppAbort&cod_servidor=" + encodeURIComponent(cod_servidor) + "&cod_sistema=" + encodeURIComponent(cod_sistema) + "&port=" + encodeURIComponent(port)
                err.request("/FW/sica/sica_control_integridad.aspx?" + str_modo_accion, { asynchronous: false, error_alert: false })
            }

            if (err.numError != 0) {
                alert(err.numError + ":" + err.mensaje)
            }
            window.clearInterval(interval)


        }

        function sica_control_res() {

            window.top.nvSesion.usuario_accion();

            var oXML = new tXML()
            oXML.async = true
            oXML.onComplete = function (oXML) {

                var fe_fin = this.selectSingleNode("resultado/nvApp/@fe_fin").nodeValue
                var elapseSeconds = this.selectSingleNode("resultado/nvApp/@elapseSeconds").nodeValue
                var fe_inicio = this.selectSingleNode("resultado/nvApp/@fe_inicio").nodeValue
                var pg_count = this.selectSingleNode("resultado/nvApp/@pg_count").nodeValue
                var pg_pos = this.selectSingleNode("resultado/nvApp/@pg_pos").nodeValue
                var pi_count = this.selectSingleNode("resultado/nvApp/@pi_count").nodeValue
                var pi_pos = this.selectSingleNode("resultado/nvApp/@pi_pos").nodeValue
                var total_count = this.selectSingleNode("resultado/nvApp/@total_count").nodeValue
                var status = this.selectSingleNode("resultado/nvApp/@status").nodeValue
                var status_err_msg = this.selectSingleNode("resultado/nvApp/@status_err_msg").nodeValue
                var progress_info = this.selectSingleNode("resultado/nvApp/@progress_info").nodeValue

               
                if (fe_inicio != "" && fe_fin != "") {

                    if (status_err_msg != "") {
                        alert("El proceso finalizó debido a un error: " + status_err_msg)
                    }

                    $("btnIniciar").show()
                    $("btnAbortar").hide()
                    if (nvFW.pageContents["modo"] == "selectedApp") {
                        campos_defs.habilitar("port", true)

                    }
                    proceso_activo = false;
                    window.clearInterval(interval)
                    
                    //habilitar botones implementar, actualizar
                    // ...

                    $("tdStatus").innerHTML = "Tiempo de ejecucion " + elapseSeconds + " segundos (" + total_count + " objetos)"
                    
//                    nvFW.exportarReporte({
//                        //Parámetros de consulta
//                        filtroXML: ''
//                        , xml_data: this.toString()
//                        , path_xsl: "report\\verResIntegridad\\verResIntegridad.xsl"
//                        , salida_tipo: "adjunto"
//                        , formTarget: "iFrameRes"
//                    })



                    // Llamar a la exportación
                    var filtroWhere = "<criterio><procedure PageSize='3000'>";
                    filtroWhere += "<parametros>";
                    filtroWhere += "<select><filtro></filtro><campos>*</campos><orden></orden><grupo></grupo></select>";
                    filtroWhere += "<strXML><![CDATA[" + this.toString() + "]]></strXML>";
                    filtroWhere += "</parametros>";
                    filtroWhere += "</procedure></criterio>";

                    nvFW.exportarReporte(
                    {
                        filtroXML: nvFW.pageContents.filtro_ordenar_xml,
                        filtroWhere: filtroWhere,
                        path_xsl: "report\\verResIntegridad\\verResIntegridad.xsl",
                        nvFW_mantener_origen: true,
                        salida_tipo: "adjunto",
                        formTarget: "iFrameRes",
                        cls_contenedor: "iFrameRes",
                        cls_contenedor_msg: " ",
                        bloq_contenedor: "iFrameRes",
                        bloq_msg: "Cargando resultado..."
                    });

                    $("tdStatus").setStyle({ background: "inherit" });

                    return
                }

                if (fe_inicio != "" && fe_fin == "") {
                    $("btnIniciar").hide()
                    $("btnAbortar").show()
                    //$("tdStatus").innerHTML = "Ejecutando (" + pg_pos + " de " + pg_count + ")(" + pi_pos + " de " + pi_count + ")"

                    $("tdStatus").innerHTML = "Ejecutando (" + pg_pos + " de " + pg_count + ")(" + pi_pos + " de " + pi_count + ")";
                    var percent = ((pi_pos / pi_count) * 100).toFixed(2);
                    $("tdStatus").setStyle({ background: "linear-gradient(to right, #4BB543 0px, #4BB543 " + percent + "%, #a2a2a2 " + percent + "%, #a2a2a2 100%)" });

                    if (!interval) { // cuando se cierra la ventana y se vuelve a abrir, y hay un proceso activo, reactivar el timer
                        interval = window.setInterval("sica_control_res()", 4000)
                        proceso_activo = true
                    }

                    return
                }

                if (fe_inicio == "") {
                    $("btnIniciar").show()
                    $("btnAbortar").hide()
                    $("tdStatus").innerHTML = ""
                    $("iFrameRes").src = ""
                }

            }

            if (nvFW.pageContents["modo"] == "currentApp") {
                oXML.load("/FW/sica/sica_control_integridad.aspx?modo=currentApp&accion=currentAppRes")
            } else if (nvFW.pageContents["modo"] == "selectedApp") {
                oXML.load("/FW/sica/sica_control_integridad.aspx?modo=selectedApp&accion=selectedAppRes&cod_servidor=" + encodeURIComponent(cod_servidor) + "&cod_sistema=" + encodeURIComponent(cod_sistema) + "&port=" + encodeURIComponent(port))
            }

        }




        function window_onload() {

            if (nvFW.pageContents["modo"] == "selectedApp") {
                cod_servidor = nvFW.pageContents["cod_servidor"];
                cod_sistema = nvFW.pageContents["cod_sistema"];
                $('cod_servidor').innerHTML = cod_servidor
                $('cod_sistema').innerHTML = cod_sistema
                $('tbServidorSistemaPort').style.display = "inline"
                campos_defs.add('port', {
                    enDB: false,
                    nro_campo_tipo: 1,
                    depende_de: null,
                    filtroXML: nvFW.pageContents["consulta_ports"],
                    filtroWhere: null,
                    depende_de_campo: null,
                    target: 'divPort'
                });

                campos_defs.items["port"]["onchange"] = function () {
                    port = campos_defs.get_value("port")

                    if (port != "") {
                        //proc_iniciado = true;
                        sica_control_res()
                    }
                }


            } else {

                sica_control_res()
            }

            vListButtons.MostrarListButton()
            window_onresize()
        }


        function check_all() {
            // ver si esta chequeado el checkbox maestro dentro del iframe de objetos
            var iframe = iframeRef(document.getElementById('iFrameRes'))
            var source = iframe.getElementById('chbx_master');
            checkboxes = iframe.getElementsByName('chbx_group');
            for (var i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = source.checked;
            }
        }

        function iframeRef(frameRef) {
            return frameRef.contentWindow ? frameRef.contentWindow.document : frameRef.contentDocument
        }

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"]   = "ActualizarDef";
        vButtonItems[0]["etiqueta"] = "Actualizar Definición";
        vButtonItems[0]["imagen"]   = "subir";
        vButtonItems[0]["onclick"]  = "confirmEjecutarAccion(1) ";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"]   = "ActualizarImp";
        vButtonItems[1]["etiqueta"] = "Actualizar Implementación";
        vButtonItems[1]["imagen"]   = "bajar";
        vButtonItems[1]["onclick"]  = "confirmEjecutarAccion(2)";


        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("subir", '/FW/image/icons/subir.png')
        vListButtons.loadImage("bajar", '/FW/image/icons/bajar.png')



        function confirmEjecutarAccion(modo) {

            var server_name = cod_servidor != undefined ? cod_servidor : nvFW.pageContents.server_name.toLowerCase()

            if (modo == 1) {
                var msg = '¿Está seguro que desea actualizar la <b>definición</b> del módulo desde <b>"' + server_name + '"</b>?'
            } else {
                var msg = '¿Está seguro que desea aplicar los cambios en la <b>implementación</b> de <b>"' + server_name + '"</b>?'
            }

            nvFW.confirm(msg, {
                width: 570,
                height: 80,
                //onShow: function () {

                //},
                onOk: function (win) {
                    ejecutarAccionIntegridad(modo);
                    win.close()
                },
                onCancel: function (win) { win.close() },
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar'
            });
        }




        // modo: 1 - actualizar definicion; 2 - actualizar implementacion
        function ejecutarAccionIntegridad(modo) {

            var items = []
            var items_pos = []
            var indice = 0
            var iframe = iframeRef(document.getElementById('iFrameRes'))
            var checkboxes = iframe.getElementsByName('chbx_group');

            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].checked == true) {
                    var row = checkboxes[i].parentNode.parentNode;  // ->td->tr
                    var cod_modulo_version = row.attributes["cod_modulo_version"].value   //row.cod_modulo_version
                    var cod_objeto = row.attributes["cod_objeto"].value //row.cod_objeto
                    var objeto = row.attributes["objeto"].value //row.objeto
                    var path = row.attributes["path"].value //row.path
                    var cod_obj_tipo = row.attributes["cod_obj_tipo"].value //row.cod_obj_tipo
                    var resStatus = row.attributes["resStatus"].value //row.resStatus
                    items.push({ cod_modulo_version: cod_modulo_version, cod_objeto: cod_objeto, objeto: objeto, path: path, cod_obj_tipo: cod_obj_tipo, resStatus: resStatus });
                    items_pos.push(checkboxes[i].parentNode.parentNode.rowIndex); // row_pos: checkbox -> td -> tr
                }
            }

            if (items.length == 0) {
                alert("No se han seleccionado objetos")
                return
            }

            var strItems = "<?xml version='1.0'?>"
            strItems += "<objetos>"
            for (var i = 0; i < items.length; i++) {
                var item = items[i];

                // 1 - si se van a guardar cambios a la definicion:
                // si el objeto es objeto_no_encontrado se envia el cod_objeto para poder eliminarlo desde la definicion

                // 2 - si se va actualizar implementacion:
                // siempre se envia el cod_objeto

                var strCod_objeto = ""
                if ((modo == '1' && item.resStatus == '1') || (modo == '2')) {
                    strCod_objeto = "cod_objeto='" + item.cod_objeto + "'"
                }

                strItems += "<objeto cod_modulo_version='" + item.cod_modulo_version + "' " + strCod_objeto + " objeto='" + stringToXMLAttributeString(item.objeto) + "' path='" + stringToXMLAttributeString(item.path) + "' cod_obj_tipo='" + item.cod_obj_tipo + "' resStatus='" + item.resStatus + "'/>"
            }
            strItems += "</objetos>"


            var url = modo == '1' ? "sica_definicion_abm.aspx" : "sica_implementacion_abm.aspx"


            var curr_app = "true"
            var cod_serv = ""
            var cod_sis = ""
            var app_port = ""

            if (nvFW.pageContents["modo"] == "selectedApp") {
                curr_app = "false"
                app_port = campos_defs.get_value('port')
                if (!app_port) {
                    alert("Seleccione puerto de la aplicación.")
                    return
                }
                cod_serv = cod_servidor
                cod_sis = cod_sistema
            }

            nvFW.error_ajax_request(url, {
                parameters: {
                    currentApp: curr_app,
                    cod_servidor: cod_serv,
                    cod_sistema: cod_sis,
                    port: app_port,
                    strItems: strItems
                },
                onSuccess: function (err, transport) {
                    winmod.close();
                }
            });
        }



        function verObjetoIntegridad(cod_objeto, objeto, path_ori, cod_obj_tipo, extension, status) {
        
            if (status == '2') {
                // archivo modificado: mostrar el comparador

                /*var servidor_params = ""
                if (nvFW.pageContents["modo"] == "selectedApp") {
                    servidor_params += "&cod_servidor=" + encodeURIComponent(cod_servidor) +
                                       "&cod_sistema=" + encodeURIComponent(cod_sistema) +
                                       "&port=" + port
                }
                var win =
                window.top.nvFW.createWindow({
                    url: "/fw/sica/sica_diff_viewer.aspx?cod_objeto=" + cod_objeto +
                        "&path_ori=" + encodeURIComponent(path_ori) +
                        servidor_params,
                    className: 'alphacube',
                    title: '<b>Diff</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 700,
                    height: 350,
                    destroyOnClose: true,
                    recenterAuto: true
                });
                win.options.data = {}
                win.showCenter();*/

                var cod_serv = ""
                var cod_sis = ""
                var app_port = "0"

                if (cod_servidor != undefined) {
                    cod_serv = cod_servidor
                    cod_sis = cod_sistema
                    app_port = port
                }

                var strXML = "<diff><source1 modo='GET_DEF' cod_objeto='"  + cod_objeto + "'/>" +
                "<source2 modo='GET_IMP' cod_servidor='" + stringToXMLAttributeString(cod_serv) + "' cod_sistema='" +
                stringToXMLAttributeString(cod_sis) + "' port='" + app_port + "' objeto='" + stringToXMLAttributeString(objeto) +
                "' path='" + stringToXMLAttributeString(path_ori) + "' cod_obj_tipo='" + cod_obj_tipo + "' /></diff>"


                var win =
                window.top.nvFW.createWindow({
                    url: "/fw/sica/sica_diff_viewer.aspx?strXML=" + encodeURIComponent(strXML),
                    //className: 'alphacube',
                    title: '<b>Diff</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 700,
                    height: 350,
                    destroyOnClose: true,
                    recenterAuto: true
                });
                win.options.data = {}
                win.showCenter()
                win.maximize()


            } else if (status == '3') {



                // archivo sobrante, ver de la implementacion
                mostrarObjetoImplementacion(cod_serv, cod_sis, app_port, objeto, path_ori, cod_obj_tipo, extension)

            } else if (status == '1') {

                // objeto no encontrado, ver su definicion
                mostrarObjetoDefinicion(cod_objeto, cod_obj_tipo, extension)
            }
        }




        function window_onresize() {

            var body_h = $$('BODY')[0].getHeight();
            var divHead_h = $('divHead').getHeight();
            var divFoot_h = $('divFoot').getHeight();

            var h = body_h - divHead_h - divFoot_h
            if (h > 0) {
                $('divBody').setStyle({ height: h + 'px', overflow: "hidden" });
            }
        }

        function iframeRef(frameRef) {
            return frameRef.contentWindow ? frameRef.contentWindow.document : frameRef.contentDocument
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="height: 100%; width: 100%; overflow: hidden; background-color: white;">
    <div id="divHead">
        <table id="tbServidorSistemaPort" class="tb1" style="display: none">
            <tr class="tbLabel">
                <td>
                    Cod Servidor
                </td>
                <td>
                    Cod Sistema
                </td>
                <td>
                    Port
                </td>
            </tr>
            <tr>
                <td>
                    <span id="cod_servidor"></span>
                </td>
                <td>
                    <span id="cod_sistema"></span>
                </td>
                <td>
                    <div id='divPort'>
                    </div>
                </td>
            </tr>
        </table>
        <table class="tb1" id='tablaParametros'>
            <tr class="tbLabel">
                <td style="width: 20%">
                    Módulos
                </td>
                <td style="width: 20%">
                    Tipo de objetos
                </td>
                <td style="width: 20%">
                    Filtro objetos
                </td>
                <td colspan="2">
                    Fe. Mod. Desde
                </td>
                <td id="tdStatus" style="width: 20%">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td>
                    <%= nvFW.nvCampo_def.get_html_input("cod_modulo_versiones", nro_campo_tipo:=2, filtroXML:="<criterio><select vista='vernv_sistema_modulo_version'><campos>cod_modulo_version as id, modulo + ' ' + modulo_numero_version as campo</campos><filtro><cod_sistema_version type='igual'>" & cod_sistema_version & "</cod_sistema_version></filtro></select></criterio>", enDB:=False)%>
                </td>
                <td>
                    <%= nvFW.nvCampo_def.get_html_input("cod_obj_tipos", nro_campo_tipo:=2, filtroXML:="<criterio><select vista='nv_objeto_tipos'><campos>cod_obj_tipo as id, objeto_tipo as campo</campos></select></criterio>", enDB:=False)%>
                </td>
                <td>
                    <input type='text' name='filtroObjeto' id='filtroObjeto' style="width: 100%" />
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('fe_mod_date', { enDB: false,
                            nro_campo_tipo: 103
                        });

                        //$('fe_mod_date').value = '1/1/1980';
                    </script>
                </td>
                <td>
                    <input style="width: 100%" type="text" value="00:00:00" id="fe_mod_time" />
                </td>
                <td>
                    <input type="button" id="btnIniciar" value="Iniciar" onclick="sica_control_integridad_iniciar()"
                        style="width: 100%; cursor: pointer" />
                    <input type="button" id="btnAbortar" value="Abortar" onclick="sica_control_integridad_abortar()"
                        style="width: 100%; display: none; cursor: pointer" />
                </td>
            </tr>
        </table>
    </div>
    <div id="divBody">
        <iframe id="iFrameRes" name="iFrameRes" style="display: block; width: 100%; height: 100%; background-color: White; border: 1px solid #CCC;"></iframe>
    </div>
    <div id="divFoot" style="text-align: center; width: 100%;">
        <table id='tablaActualizar' style="width: 100%">
            <tr>
                <td style="width: 50%; text-align: center">
                    <div id="divActualizarDef" style="margin: auto; width: 80%">
                    </div>
                </td>
                <td style="width: 50%; text-align: center">
                    <div id="divActualizarImp" style="margin: auto; width: 80%">
                    </div>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
