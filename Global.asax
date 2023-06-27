<%@ Application Language="VB" %>
<%@ Import namespace="nvFW" %>
<script runat="server">

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        'Se desencadena al iniciar la aplicación
        '**********************************************************************************************************************************************************************
        ' .Net me esta disparando el Session_star cuando aún no se terminó de ejecutar el Session_end anterior
        ' Para solucionarlo, realizo un bloqueo de objeto en ambos procedimientos para garantizar que se termine de ejecutar el Session_end antes de continuar el Session_start
        '**********************************************************************************************************************************************************************

        SyncLock nvServer.lockOkject
            'Inicializar la variable del manejador de eventos de nova
            Application.Contents("_nvHandlers_proccess") = False
            Dim objXML As System.Xml.XmlDocument
            Dim nv_SessionType As String = ""

            'Cargar el archivo de configuración del sistema
            'En caso de haber un error se carga en Application.Contents("nv_start_error")
            Try
                nvServer.LoadConfigValue(Server.MapPath("\") + "App_LocalResources\nvConfig.cfg")
                'nvServer.cn_string = nvServer.getConfigValue("/config/conections/conection [@name = 'admin'] /@cn_string")
                'nvServer.onlyHTTPS = nvServer.getConfigValue("/config/global/@onlyHTTPS", "false").ToLower() = "true"
                'nvServer.showDebugErrors = nvServer.getConfigValue("/config/global/@showDebugErrors", "false").ToLower() = "true"
                nv_SessionType = nvServer.getConfigValue("/config/global/@SessionType")
            Catch ex As Exception
                Dim err As tError = New tError()
                err.parse_error_script(ex)
                err.numError = 10
                err.titulo = "Error al iniciar la Aplicacion"
                err.mensaje = "No se pudo acceder a la configuración del sistema"
                err.system_reg()
                'err.mostrar_error()
                nvServer.start_error = err
            End Try



            nvServer.appl_physical_path = HttpRuntime.AppDomainAppPath
            Dim MachineName As String = System.Environment.MachineName

            'Comprobar que el objeto de nvInterOP funciona
            If nv_SessionType.ToLower() <> "HTTP_session".ToLower() Then
                'Try
                '    Dim instanciador As Object
                '    instanciador = CreateObject("nvInterOP.nvInstanciador", "localhost")
                'Catch ex As Exception
                '    Dim err As tError = New tError()
                '    err.parse_error_script(ex)
                '    err.titulo = "Error al iniciar la Aplicacion"
                '    err.mensaje = "No se puede instanciar nvInterOP.nvInstanciador"
                '    'err.mostrar_error()
                '    err.system_reg()
                '    nvServer.start_error = err
                '    Exit Sub
                'End Try
                'nvSession.SessionType = emunSessionType.nvInterOP_session
                'nvServer.SessionType = emunSessionType.nvInterOP_session
            Else
                nvSession.SessionType = emunSessionType.HTTP_session
                nvServer.SessionType = emunSessionType.HTTP_session
            End If

            '*******************************************************************************************
            'Eliminar archivos temporales
            '*******************************************************************************************
            nvServer.clearTMPFiles()

            '*****************************************************
            'Comprobar que la cadena de conexion funciona
            '*****************************************************
            Try
                Dim cn As ADODB.Connection = New ADODB.Connection
                cn.ConnectionTimeout = 2
                cn.Open(nvServer.cn_string)
                cn.Close()
            Catch ex As Exception
                Dim err As tError = New tError()
                err.parse_error_script(ex)
                err.titulo = "Error al iniciar la Aplicacion"
                err.mensaje = "No se puede conectar a la base de datos primaria"
                err.system_reg()
                nvServer.start_error = err
                Exit Sub
            End Try


            '**************************************************************************
            'Identificar servidor
            '**************************************************************************
            Dim strSQL As String = "select * from nv_servidor_alias where servidor_alias = '" & MachineName & "' or cod_servidor = '" & MachineName & "'"
            'Dim cod_servidor As String = ""
            Dim rsServer As ADODB.Recordset
            Try
                rsServer = nvDBUtiles.ADMDBOpenRecordset(strSQL, logEvent:=False)
                nvServer.cod_servidor = rsServer.Fields("cod_servidor").Value
                nvServer.port = Request.ServerVariables("SERVER_PORT")
            Catch ex As Exception
            Finally
                nvDBUtiles.DBCloseRecordset(rsServer)
            End Try

            If nvServer.cod_servidor = "" Then
                Dim err As tError = New tError()
                err.numError = 11
                err.titulo = "Error al iniciar la Aplicacion"
                err.mensaje = "No se puede recuperar el codigo del servidor"
                err.debug_desc = "SQL : " & strSQL
                err.system_reg()
                nvServer.start_error = err
                Exit Sub
            End If
            '*************************************************
            'Iniciar el objeto de log
            '*************************************************
            nvFW.nvLog.init()


            nvLog.addEvent("app_start", nvServer.cod_servidor & ";" & nvServer.port)

            Dim errOK As New tError(0, "app_start. Aplicación iniciada", "")
            errOK.system_reg(Diagnostics.EventLogEntryType.Information)
            'Iniciar clase de interoperabilidad para casos especiales, por ejemplo XSL
            Application.Contents("_nvFW_interOp") = New tnvFW_InterOp()

            'Carga la coleccion de nvPages instaladas en el sistema
            nvServer.loadNvPages()

        End SyncLock

    End Sub

    '*****************************************************************
    '*****************************************************************
    'SESSION onStart
    '*****************************************************************
    '*****************************************************************
    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
        '**********************************************************************************************************************************************************************
        ' .Net me esta disparando el Session_star cuando aún no se terminó de ejecutar el Session_end anterior
        ' Para solucionarlo, realizo un bloqueo de objeto en ambos procedimientos para garantizar que se termine de ejecutar el Session_end antes de continuar el Session_start
        '**********************************************************************************************************************************************************************
        SyncLock nvServer.lockOkject
            'Evaluar su hubo algún error al momento de cargar la aplicación
            If Not nvServer.start_error Is Nothing Then
                Dim err As tError = nvServer.start_error
                err.response()
                Me.CompleteRequest()
                'HttpContext.Current.ApplicationInstance.CompleteRequest()
                HttpRuntime.UnloadAppDomain()
                Exit Sub
            End If

            '************************************************************************************
            'Agregar los manejadores de eventos. Esto debería ir en el Application_start 
            'pero en ese contexto no se puede realizar el Server.execute
            'Se procesan todos los archivos ASPX que se encuentren en la carpeta "/fw/handlers/"
            '************************************************************************************
            If Application.Contents("_nvHandlers_proccess") = False Then
                Application.Contents("_nvHandlers_proccess") = True
                dim rsPath_rel = nvDBUtiles.ADMDBOpenRecordset("select ss.cod_sistema, path_rel from nv_servidor_sistemas ss join nv_sistemas s on ss.cod_sistema = s.cod_sistema where cod_servidor = '" & nvServer.cod_servidor & "'")
                dim dirs as new List(of string)
                while (not rsPath_rel.eof())
                    dirs.add(Server.MapPath("\") & rsPath_rel.fields("path_rel").value)
                    rsPath_rel.movenext()
                end while
                'Dim dirs() As String = System.IO.Directory.GetDirectories(Server.MapPath("\"))
                For Each directorio In dirs
                    If System.IO.Directory.Exists(directorio & "\handlers") Then
                        Dim hdl_dir As String = directorio & "\handlers"
                        Dim files() As String = System.IO.Directory.GetFiles(hdl_dir, "*.aspx")
                        For Each file In files
                            Dim filename As String = System.IO.Path.GetFileName(file)
                            Server.Execute(hdl_dir.Replace(Server.MapPath("\"), "~\") & "\" & filename)
                        Next
                    End If
                Next
            End If

            'Comprobar que la cadena de conexion funciona
            Try
                Dim cn As ADODB.Connection = New ADODB.Connection
                cn.ConnectionTimeout = 2
                cn.Open(nvServer.cn_string)
                'nvDBUtiles.ADMDBExecute("Select 1")
                'Dim cn As ADODB.Connection
                'cn = nvDBUtiles.ADMDBConectar
                'cn.Execute("Select 1")
                cn.Close()
            Catch ex As Exception
                Dim err As tError = New tError()
                err.parse_error_script(ex)
                err.numError = 10
                err.titulo = "Error al iniciar la sesion"
                err.mensaje = "No se puede conectar a la base de datos primaria"
                err.system_reg()
                err.response()
                Me.CompleteRequest()
                Exit Sub
            End Try


            Dim SERVER_PORT As Integer
            Dim ports As nvServer.tParPorts

            'Evaluar la existencia del puerto por el cual se accede
            SERVER_PORT = Request.ServerVariables("SERVER_PORT")
            ports = nvFW.nvServer.getPorts(SERVER_PORT, Request.ServerVariables("SERVER_NAME"))
            If ports.http = 0 Then
                Dim err As tError = New tError()
                err.numError = 11
                err.titulo = "Error al iniciar la Session"
                err.mensaje = "El puerto de acceso(" & SERVER_PORT & ") o el Alias (" & Request.ServerVariables("SERVER_NAME") & ") no se encuentran configurados"
                err.response()
                Session.Abandon()
                Me.CompleteRequest()
                Exit Sub
            End If

            Dim nvApp As New tnvApp()
            nvApp.ports = ports
            nvApp.cod_servidor = nvServer.cod_servidor
            nvApp.server_name = Request.ServerVariables("SERVER_NAME")
            nvApp.server_path = Request.Url.Scheme & "://" & Request.ServerVariables("SERVER_NAME")
            nvApp.server_ip = Request.ServerVariables("LOCAL_ADDR")
            nvApp.server_port = Request.ServerVariables("SERVER_PORT")
            nvApp.server_protocol = Request.Url.Scheme
            nvApp.host_ip = Request.ServerVariables("REMOTE_ADDR")
            nvApp.host_name = Request.ServerVariables("REMOTE_host")

            nvSession.Contents("nvApp") = nvApp

            nvServer.port_http = ports.http
            nvServer.port_https = ports.https


            If ports.https <> 443 Then
                nvApp.server_host_https = "https://" & nvApp.server_name & ":" & ports.https
            Else
                nvApp.server_host_https = "https://" & nvApp.server_name
            End If
            If ports.http <> 80 Then
                nvApp.server_host_http = "http://" & nvApp.server_name & ":" & ports.http
            Else
                nvApp.server_host_http = "http://" & nvApp.server_name
            End If



            '****************************
            'Iniciar cache
            '****************************
            nvCache.init()
            nvLog.addEvent("gss_start", nvServer.port_http & ";" & nvServer.port_https & ";" & nvServer.port & ";" & HttpContext.Current.Request.Url.ToString())

            '**********************************************
            'Compatibilidad con ASP Classic
            '**********************************************
            'nvSession.Contents("cfg_server_port_https") = nvServer.port_https
            'nvSession.Contents("cfg_server_name") = nvApp.server_name
            'nvSession.Contents("AutLevel") = -1

            nvServer.Events.RaiseEvent("onSessionStart", sender, e)

        End SyncLock

    End Sub


    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
        'Disparar el evento para handlers
        nvServer.Events.RaiseEvent("onSessionEnd", {Session})


        'Se desencadena cuando finaliza la sesión
        'Limpiar caches de session
        'nvCache_clear()
        'nvLog_addEvent("gss_end", Session.Contents("cfg_host_ip"))
        'nvLog_close()
        '**********************************************************************************************************************************************************************
        ' .Net me esta disparando el Session_star cuando aún no se terminó de ejecutar el Session_end anterior
        ' Para solucionarlo, realizo un bloqueo de objeto en ambos procedimientos para garantizar que se termine de ejecutar el Session_end antes de continuar el Session_start
        '**********************************************************************************************************************************************************************
        SyncLock nvServer.lockOkject
            nvCache.clear(Session)
            If (nvSession.GetContents(Session)("login") <> "") Then
                nvLog.addEvent("ss_logout", "", Session)
            End If
            nvLog.addEvent("gss_end", nvServer.port_http & ";" & nvServer.port_https, Session)
            Dim nvApp As nvFW.tnvApp = nvFW.nvApp.getInstance(, Session)

            'If Not nvApp Is Nothing Then nvApp.sessionEnd()

            nvSession.Abandon(Session)
            Try
                If Application.Contents("_cn_admin_nvcn") IsNot Nothing Then
                    Dim cn As ADODB.Connection = Application.Contents("_cn_admin_nvcn").ActiveConnection
                    Application.Contents("_cn_admin_nvcn") = Nothing
                    cn.Close()
                End If
            Catch ex As Exception

            End Try

        End SyncLock
    End Sub

    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
        'nvWebSocket.closeAll()
        SyncLock nvServer.lockOkject
            Dim err As New tError(0, "app_end. Aplicación cerrada", "")
            err.system_reg(Diagnostics.EventLogEntryType.Information)
            nvLog.addEvent("app_end", "")
            nvServer.Events.RaiseEvent("onApplicationEnd", sender, e)

            Application.Contents.Clear()
            ' Se desencadena cuando finaliza la aplicación

            Try
                nvLog.close()
            Catch ex As Exception
            End Try

            'nvSession.removeInstance()
            'Application.Contents.RemoveAll()
            HttpRuntime.UnloadAppDomain()
        End SyncLock
    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
        Dim er As New tError()

        Try
            Dim ex = Server.GetLastError()
            Server.ClearError()
            er.parse_error_script(ex)
        Catch ex As Exception

        End Try

        er.titulo = "Error de procesamiento"
        er.mensaje = "Error desconocido"
        er.debug_src = "Global.asax::Application_Error"
        er.system_reg()
        er.response()
        HttpContext.Current.ApplicationInstance.CompleteRequest()

    End Sub

</script>
