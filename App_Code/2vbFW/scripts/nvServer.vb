Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Diagnostics

Namespace nvFW
    ''' <summary>
    ''' Clase global que mantiene la información del servidor
    ''' </summary>
    ''' <remarks></remarks>
    Public Class nvServer

        Public Shared lockOkject As Object = New Object


        Public Shared cod_servidor As String = ""
        Public Shared port As Integer
        Public Shared port_http As Integer
        Public Shared port_https As Integer
        Public Shared appl_physical_path As String
        Public Shared nvConfigXML As System.Xml.XmlDocument
        Public Shared SessionType As nvFW.emunSessionType
        Public Shared start_error As tError = Nothing
        Public Shared sw_cache_max_lastmodified As DateTime = Nothing
        Public Shared sw_cache_min_lastmodified As DateTime = Nothing
        Public Shared sw_cache_whatcher As System.IO.FileSystemWatcher


        Private Shared _cn_string As String
        Private Shared _onlyHTTPS As Boolean
        Private Shared _showDebugErrors As Boolean
        Private Shared _su As New list(Of String) 'Super Users

        Private Shared _configValues As New Dictionary(Of String, String)
        Private Shared _customErrosEnable As Boolean
        Private Shared _customErrosEnableRead As Boolean = False

        Public Shared _pageObjects As New Dictionary(Of String, tRSParam) 'Diccionario de todos los tipos nvPage que hay en el servidor

        'Public Shared Event onApllicationEnd()


        Public Shared Events As New tnvServerEventClass


        ''' <summary>
        ''' Clase que se utiliza como manejador de eventos
        ''' Todos los eventos del nvServer deben estar creados aquí
        ''' </summary>
        Public Class tnvServerEventClass

            Private _handlres As New Dictionary(Of String, List(Of System.Delegate))


            ''' <summary>
            ''' Dispara un evento de servidor.
            ''' Los manejadores de eventos de agregab con AddHandler.
            ''' </summary>
            ''' <param name="[event]">Nombre del evento</param>
            ''' <param name="args">Argumentos del evento, pueden ser varios es un param Array. Debe haber relación entre la cantidad de parametros del evento y el manejador del mismo</param>
            Public Sub [RaiseEvent](ByVal [event] As String, ByVal ParamArray args() As Object)
                If _handlres.ContainsKey([event]) Then
                    Dim handlerEvents As List(Of System.Delegate) = _handlres([event])
                    For Each subHandler As System.Delegate In handlerEvents
                        Try
                            Select Case args.Count
                                Case 0
                                    subHandler.DynamicInvoke([event])
                                Case 1
                                    subHandler.DynamicInvoke([event], args(0))
                                Case 2
                                    subHandler.DynamicInvoke([event], args(0), args(1))
                                Case 3
                                    subHandler.DynamicInvoke([event], args(0), args(1), args(2))
                                Case 4
                                    subHandler.DynamicInvoke([event], args(0), args(1), args(2), args(3))
                            End Select
                        Catch ex As Exception
                            Dim err As New tError(ex, "Error en el manejador de evento", "El evento '" & [event] & "' produjo un error interno", debug_src:="nvServer::tnvServerEventClass::RaiseEvent")
                            'err.parse_error_script(ex)
                            err.system_reg()
                        End Try
                    Next
                End If
            End Sub

            ''' <summary>
            ''' Agrega un manejador de evetos al servidor
            ''' </summary>
            ''' <param name="[event]">Nombre del evento</param>
            ''' <param name="[delegate]">Procedimiento que se dispara. Puede ser Lambda</param>
            Public Sub [AddHandler]([event] As String, [delegate] As System.Delegate)
                'Me._event.AddHandler(source, [delegate])
                Dim handlerEvents As New List(Of System.Delegate)
                If _handlres.ContainsKey([event]) Then
                    handlerEvents = _handlres([event])
                Else
                    _handlres.Add([event], handlerEvents)
                End If
                handlerEvents.Add([delegate])
            End Sub
        End Class




        'estructura que guarda los puestos asociados entre si en una misma aplicacion (http y https)
        Public Structure tParPorts
            Dim http As Integer
            Dim https As Integer
            Dim physical_path As String
        End Structure
        Public Shared ReadOnly Property cn_string As String
            Get
                Return _cn_string
            End Get
        End Property
        Public Shared ReadOnly Property onlyHTTPS As Boolean
            Get
                Return _onlyHTTPS
            End Get
        End Property

        Public Shared ReadOnly Property showDebugErrors As Boolean
            Get
                Return _showDebugErrors
            End Get
        End Property

        Public Shared ReadOnly Property su As list(Of String)
            Get
                Return _su
            End Get
        End Property


        Public Shared ReadOnly Property customErrorsEnable As Boolean
            Get
                If Not _customErrosEnableRead Then
                    _customErrosEnableRead = True
                    Dim oXML As New System.Xml.XmlDocument
                    oXML.Load(appl_physical_path & "/web.config")
                    Dim node_httpErrors As System.Xml.XmlNode = oXML.SelectSingleNode("configuration/system.webServer/httpErrors")
                    If Not node_httpErrors Is Nothing Then
                        Dim strHttpErrosCompare As String = "<httpErrors existingResponse=""Replace"" defaultResponseMode=""ExecuteURL"" errorMode=""Custom""><clear/><error statusCode=""403"" subStatusCode=""-1"" path=""/fw/Error/httpError_403.aspx"" responseMode=""ExecuteURL""/><error statusCode=""404"" subStatusCode=""-1"" path=""/fw/Error/httpError_404.aspx"" responseMode=""ExecuteURL""/><error statusCode=""500"" subStatusCode=""-1"" path=""/fw/Error/httpError_500.aspx"" responseMode=""ExecuteURL""/></httpErrors>"
                        Dim strHttpErros As String = node_httpErrors.OuterXml
                        Dim strReg As String = "\s"
                        Dim reg As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.IgnoreCase)
                        strHttpErrosCompare = reg.Replace(strHttpErrosCompare, "")
                        strHttpErros = reg.Replace(strHttpErros, "")
                        If strHttpErros.ToLower <> strHttpErrosCompare.ToLower Then
                            _customErrosEnableRead = False
                        End If
                    Else
                        _customErrosEnableRead = False
                    End If
                End If
                Return _customErrosEnableRead
            End Get
        End Property

        Public Shared Function getPorts(ByVal port As Integer, ByVal server_name As String) As tParPorts
            Dim rsPorts As ADODB.Recordset
            Dim res As tParPorts
            rsPorts = nvDBUtiles.ADMDBExecute("Select * from verServidor_ports where servidor_alias = '" & server_name & "' and (port_http = " & port & " or port_https = " & port & ")")
            If Not rsPorts.EOF Then
                res.http = rsPorts.Fields("port_http").Value
                res.https = rsPorts.Fields("port_https").Value
                res.physical_path = rsPorts.Fields("physical_path").Value
            End If
            nvDBUtiles.DBCloseRecordset(rsPorts)
            Return res
        End Function

        Public Shared Function getPortsTransf(server_name As String) As tParPorts
            Dim strSQL As String = "select * from verservidor_ports  where servidor_alias = '" & server_name & "' and port_transf = 1 "
            Dim rsPorts As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
            Dim res As tParPorts
            If Not rsPorts.EOF Then
                res.http = rsPorts.Fields("port_http").Value
                res.https = rsPorts.Fields("port_https").Value
                res.physical_path = rsPorts.Fields("physical_path").Value
            End If
            Return res

        End Function
        '//{
        '//    return 499

        '//    var nv_cn_string = Application.Contents('nv_cn_string')
        '//    nv_config = Server.CreateObject("ADODB.Connection");

        '//    try 
        '//     {
        '//      nv_config.Open(nv_cn_string)
        '//     }
        '//    catch (e) {}

        '//    var port = '8080'

        '//    var rsPorts = Server.CreateObject("ADODB.Recordset")
        '//    var strSQL = " select top 1 case when sip.port_http is null and isnull(sip.port_http,0) <> '" +  nvSession.getContents("cfg_server_port_http") + "' then sep.port_http else sip.port_http end as port "
        '//       strSQL += " from nv_sistemas_ports sip, verServidor_ports sep" 
        '//       strSQL += " where servidor_alias = '" +  nvSession.getContents("cfg_server_name") + "'"
        '//       strSQL += " and cod_sistema = '" + app_cod_sistema + "' and sep.port_http <> '" + nvSession.getContents("cfg_server_port_http") + "'"
        '//       strSQL += " order by port"

        '//    rsPorts.open(strSQL, nv_config)
        '//    if (!rsPorts.eof) 
        '//        port = rsPorts.fields('port').value

        '//    return port
        '//}


        Public Shared Sub clearTMPFiles()

            '*******************************************************************************************
            'Eliminar archivos de DLLs temporales
            '*******************************************************************************************
            Dim files() As String
            Dim tmp_dir As String = Environment.GetEnvironmentVariable("TEMP") & ""
            If System.IO.Directory.Exists(tmp_dir) Then
                files = System.IO.Directory.GetFiles(tmp_dir, "*.dll")
                For Each filename In files
                    Try
                        System.IO.File.Delete(filename)
                    Catch ex As Exception
                    End Try
                Next
            End If

            '*******************************************************************************************
            'Eliminar archivos auxiliares de DLLs temporales
            '*******************************************************************************************
            If System.IO.Directory.Exists(tmp_dir) Then
                files = System.IO.Directory.GetFiles(tmp_dir, "*.pdb")
                For Each filename In files
                    Try
                        System.IO.File.Delete(filename)
                    Catch ex As Exception
                    End Try
                Next
            End If

            '*******************************************************************************************
            'Eliminar archivos temporales
            '*******************************************************************************************
            If System.IO.Directory.Exists(tmp_dir) Then
                files = System.IO.Directory.GetFiles(tmp_dir, "*.tmp")
                For Each filename In files
                    Try
                        System.IO.File.Delete(filename)
                    Catch ex As Exception
                    End Try
                Next
            End If
        End Sub

        Public Shared Sub LoadConfigValue(ByVal path_file As String)
            Try
                'Cargar el archivo de configuración del sistema
                Dim objXML As New System.Xml.XmlDocument
                objXML.Load(path_file)
                nvServer.nvConfigXML = objXML
                _cn_string = getConfigValue("/config/conections/conection [@name = 'admin'] /@cn_string")
                _onlyHTTPS = getConfigValue("/config/global/@onlyHTTPS", "false").ToLower() = "true"
                _showDebugErrors = getConfigValue("/config/global/@showDebugErrors", "false").ToLower() = "true"
                Dim su As String = getConfigValue("/config/global/nvSecurity/@su", "").trim()

                If su <> "" Then
                    Dim aSU As String() = su.split(";")
                    For Each user As String In aSU
                        _su.add(user)
                        Dim err As New tError()
                        err.numError = 112
                        err.titulo = "Advertencia de seguridad"
                        err.mensaje = "El usuario '" & user & "' se ha configurado como super usuario"
                        err.system_reg(Diagnostics.EventLogEntryType.Warning)
                    Next
                End If

            Catch ex As Exception
                Throw (ex)
            End Try
        End Sub
        Public Shared Function getConfigValue(ByVal path As String, Optional ByVal def As String = "") As String
            Dim res As String = Nothing

            'If _configValues Is Nothing Then
            ' _configValues = New Dictionary(Of String, String)
            ' End If

            SyncLock _configValues

                If _configValues.Keys.Contains(path) Then
                    res = _configValues(path)
                Else
                    res = nvXMLUtiles.getAttribute_path(nvServer.nvConfigXML, path, def)
                    If _configValues.ContainsKey(path) Then
                        _configValues(path) = res
                    Else
                        _configValues.Add(path, res)
                    End If
                End If

            End SyncLock

            If res Is Nothing Then
                Return def
            Else
                Return res
            End If
        End Function

        '    Public Shared Function getPageObject(app_cod_sistema As String, app_path_rel As String) As Object

        '        If _pageObjects.Keys.Contains(app_cod_sistema) Then
        '            Try
        '                Dim tipo As Type = Type.GetType(_pageObjects(app_cod_sistema))
        '                Dim obj As Object = Activator.CreateInstance(tipo)
        '                Return obj
        '            Catch ex As Exception
        '                Return Nothing
        '            End Try

        '        Else
        '            Return Nothing
        '        End If

        '    End Function

        'End Class

        ''' <summary>
        ''' Carga la variable estática _pageObjects con todas las clases de nvPages asociados a su correspondiente app_cod_sistema
        ''' </summary>
        Public Shared Sub loadNvPages()
            _pageObjects = getNvPagesClasses()
        End Sub

        ''' <summary>
        ''' Devuelve un dicionario con todas las clases de nvPages que están instaladas, indicado a que app_cod_sistema pertenece
        ''' </summary>
        ''' <returns></returns>
        Public Shared Function getNvPagesClasses() As Dictionary(Of String, tRSParam)
            Dim asms = AppDomain.CurrentDomain.GetAssemblies()
            Dim res As New Dictionary(Of String, tRSParam)

            'Dim asms1 = From asm1 As System.Reflection.Assembly In AppDomain.CurrentDomain.GetAssemblies()
            '            Where asm1.FullName Like "*App_SubCode*"
            '            Select asm1

            For Each asm As System.Reflection.Assembly In asms
                Dim nspace As String = "nvFW.nvPages"

                'Dim asm As System.Reflection.Assembly = System.Reflection.Assembly.GetExecutingAssembly()
                Dim classlist As New List(Of String)
                Dim tipo As Type
                Dim obj As Object
                Dim app_cod_sistema As String
                System.Diagnostics.Debug.WriteLine(asm.FullName)
                If asm.FullName.IndexOf("App_SubCode") > 0 Then Continue For
                Dim tipos = Nothing
                Try
                    tipos = asm.GetTypes()
                Catch ex As Exception
                    Continue For
                End Try

                For Each tipo In tipos
                    If tipo.Namespace = nspace Then
                        'classlist.Add(tipo.Namespace & "." & tipo.Name)
                        Try
                            obj = Activator.CreateInstance(tipo)
                            app_cod_sistema = obj.app_cod_sistema
                            If app_cod_sistema <> "" Then
                                Dim o As New tRSParam()
                                o("fullName") = tipo.FullName
                                o("assembly") = asm
                                res.Add(app_cod_sistema, o)
                            End If
                        Catch ex As Exception

                        End Try

                    End If
                Next
            Next

            Return res
        End Function

        Public Shared Function getNvPageInstance(app_cod_sistema As String) As Object
            If _pageObjects.Keys.Contains(app_cod_sistema) Then
                Try
                    Dim o As tRSParam = _pageObjects(app_cod_sistema)
                    Dim asm As System.Reflection.Assembly = o("assembly")
                    Dim obj As Object = asm.CreateInstance(o("fullName"))
                    Return obj
                Catch ex As Exception
                    Return Nothing
                End Try

            Else
                Return Nothing
            End If
        End Function


        'Public Shared Sub ApplicationEnd()
        '    RaiseEvent onApllicationEnd()
        'End Sub
    End Class





    'Public Shared Function get_nvServer() As tnvServer
    '    Stop
    '    Dim nvServer As tnvServer = Nothing
    '    Try
    '        nvServer = HttpContext.Current.Application.Contents("nvServer")
    '        Return nvServer
    '    Catch ex As Exception
    '        Stop
    '    End Try
    '    Return nvServer
    'End Function



End Namespace
