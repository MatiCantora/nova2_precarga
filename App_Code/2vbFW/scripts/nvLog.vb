Imports Microsoft.VisualBasic
Imports nvFW
Imports System.Diagnostics
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    Public Class nvLog

        'Public Shared 

        Public Shared parentLogTrack As String = ""
        Public Shared parentLogParams As String = ""
        Public Shared parentStopwatch As System.Diagnostics.Stopwatch = Nothing


        Private Shared _nvLog As tnvLog


        ''' <summary>
        ''' Inicializa el proceso de log del sistema
        ''' </summary>
        ''' <remarks></remarks>
        Public Shared Sub init()
            _nvLog = New tnvLog(nvServer.getConfigValue("/config/global/nvLog/@runAsync", True))
        End Sub

        ''' <summary>
        ''' Devuelve el objeto tnvLog que administra
        ''' </summary>
        ''' <remarks></remarks>
        Public Shared ReadOnly Property log As tnvLog
            Get
                Return _nvLog
            End Get
        End Property


        ''' <summary>
        ''' Agrega un nuevo elemento al log de sistema
        ''' </summary>
        ''' <param name="ev"></param>
        ''' <param name="params"></param>
        ''' <remarks></remarks>
        Public Shared Sub addEvent(ByVal ev As String, Optional params As String = "", Optional Session As HttpSessionState = Nothing)
            If Not _nvLog Is Nothing Then
                _nvLog.addEvent(ev, params, Session)
            End If
        End Sub


        ''' <summary>
        ''' Cierra el proceso de log
        ''' </summary>
        ''' <remarks></remarks>
        Public Shared Sub close()
            Try
                If Not _nvLog Is Nothing Then
                    _nvLog.close()
                End If
            Catch ex As Exception
            End Try
        End Sub


        ''' <summary>
        ''' Devuelve una cadena Random de 10 caracteres para utiizar como LogTrack
        ''' </summary>
        ''' <remarks></remarks>
        Public Shared Function getNewLogTrack() As String

            Return nvConvertUtiles.RamdomString(10)
            'Dim res As String = ""
            'Randomize()
            'For i = 0 To 10
            '    res += Chr(CInt(Rnd() * 25) + 65)
            'Next
            'Return res
        End Function

        Public Shared Sub EventWindows_addEvent(Machine As String, Source As String, log As String, strparams As String, severidad As EventLogEntryType)
            'me.elw_tipo:  {ERROR|WARNING|INFORMATION|SUCCESSAUDIT|FAILUREAUDIT}
            'me.elw_idevento: EventID
            'me.elw_registro: {APPLICATION | SYSTEM}
            'strParam: Description
            'me.elw_source: SrcName
            Dim sMachine As String = Machine
            If sMachine = "" Then sMachine = "."
            Dim sLog As String = log
            Dim sSource As String = Source
            'Try
            'Si no existe el log o el source crearlo.
            'Primero si no existe el log y si el souce eliminarlo
            If Not EventLog.Exists(sLog, sMachine) Then
                    If EventLog.SourceExists(sSource, sMachine) Then
                        EventLog.DeleteEventSource(sSource, sMachine)
                    End If
                End If
                'Ahora si no existe, crearlo
                If Not EventLog.SourceExists(sSource, sMachine) Then
                    Try
                        Dim creationData As New EventSourceCreationData(sSource, sLog)
                        creationData.MachineName = sMachine
                        EventLog.CreateEventSource(creationData)
                    Catch ex As Exception
                    End Try
                End If

                '//registrar evento
                Dim ELog = New EventLog(sLog, sMachine, sSource)
                'strLog = fe_e.ToString("MM/dd/yyyy hh:mm:ss.ffff") & ";" & nvServer.cod_servidor & ";" & nvApp.cod_sistema & ";" & nvApp.operador.login & ";" & id_nv_log_sistema & ";" & nvSession.IDSession & ";" & ev & ";" & params
                ELog.WriteEntry(strparams, severidad)

            'Catch ex As Exception
            'Debug.Print("tnvLogEvent::sendEvent::Log db eventos de windows." & vbCrLf & ex.Message)
            'End Try
        End Sub

    End Class



    ''' <summary>
    ''' Objeto que controla los logs del sistema
    ''' </summary>
    ''' <remarks>
    ''' NO SE PUEDE UTILIZAR DBOpenRecordset o DBExecute dentro del este objeto, reemplazarlo por DBOpenRecordsetNoLogEvent y DBExecuteNoLogEvent.
    ''' De otra manera puede entrar en un bucle infinito
    ''' </remarks>
    Public Class tnvLog
        Public logs As Dictionary(Of Integer, tnvLogItem)
        Public last_update As DateTime
        Public stats As New trsParam
        Private _eventos As Dictionary(Of String, List(Of tnvLogItem))
        Private _allEvents As List(Of String)
        Private _allEventsMissing As New List(Of String)

        Private _colaEvents As New Queue()

        Private _threadCola As System.Threading.Thread
        Private _threadCola_exit As Boolean = False
        Private _runAsync As Boolean
        'Private _strDate As String

        Public Sub New(Optional ByVal async As Boolean = True)

            stats("total_ms") = 0 'Total de ms sumados procesos sync y asnyc
            stats("total_ms_sync") = 0 'Total de ms solo proceso sync
            stats("total_events") = 0 'Cantidad de eventos que tiró el sistema independientemente de si están configurados
            stats("total_events_process") = 0 'Cantidad de eventos que proceso el sistema independientemente de si están configurados
            stats("total_events_send") = 0 'Cantidad de eventos que fueron enviados. Solo los que están configurados
            stats("total_event_errors") = 0 'Cantidad de errores en los que se enviaron. Un evento puede tirar mas de un error
            stats("total_event_not_exists") = 0 'Cantidad de eventos que no existen en la base de datos
            stats("event_not_exists") = New trsParam 'Eventos que no existen en la base de datos


            _runAsync = async
            Dim nvApp As tnvApp = nvFW.nvApp.getInstance(New tnvApp)
            Dim strSQL As String = ""
            _allEvents = New List(Of String)
            strSQL = "Select * from nv_log_evento"
            Dim rsAllEvents As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordsetNoLogEvent(strSQL)
            While Not rsAllEvents.EOF
                _allEvents.Add(rsAllEvents.Fields("id_nv_log_evento").Value.ToString().ToLower)
                rsAllEvents.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rsAllEvents)

            _eventos = New Dictionary(Of String, List(Of tnvLogItem))
            logs = New Dictionary(Of Integer, tnvLogItem)


            strSQL = "select id_nv_log_sistema,nv_log_sistema, cod_servidor, " &
                     "cod_sistema,file_path,syslog_url,syslog_port,syslog_user,syslog_pwd, global, activo,allUsers,dbcn_string,dbtable,elw_registro,elw_source,elw_machine,dbinterna, IISLog " &
                     "from  nv_log_sistema ls  where (global = 1  or (global = 0 and cod_servidor = '" & nvServer.cod_servidor & "')) and activo = 1"

            Dim rsServer As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordsetNoLogEvent(strSQL)
            Dim logItem As tnvLogItem
            'var fso = Server.CreateObject("Scripting.FileSystemObject")
            While Not rsServer.EOF
                If logs.Keys.Contains(rsServer.Fields("id_nv_log_sistema").Value) Then
                    logItem = logs(rsServer.Fields("id_nv_log_sistema").Value)
                Else
                    logItem = New tnvLogItem(Me)
                    logs.Add(rsServer.Fields("id_nv_log_sistema").Value, logItem)
                End If

                logItem.id_nv_log_sistema = rsServer.Fields("id_nv_log_sistema").Value
                logItem.cod_servidor = nvUtiles.isNUll(rsServer.Fields("cod_servidor").Value)
                logItem.cod_sistema = nvUtiles.isNUll(rsServer.Fields("cod_sistema").Value)
                logItem.file_path = nvUtiles.isNUll(rsServer.Fields("file_path").Value)
                logItem.syslog_url = nvUtiles.isNUll(rsServer.Fields("syslog_url").Value)
                logItem.syslog_port = nvUtiles.isNUll(rsServer.Fields("syslog_port").Value, 0)
                logItem.dbcn_string = nvUtiles.isNUll(rsServer.Fields("dbcn_string").Value)
                logItem.dbtable = nvUtiles.isNUll(rsServer.Fields("dbtable").Value)
                'logItem.elw_idevento = nvUtiles.isNUll(rsServer.Fields("elw_idevento").Value, 0)
                logItem.elw_registro = nvUtiles.isNUll(rsServer.Fields("elw_registro").Value)
                'logItem.elw_tipo = nvUtiles.isNUll(rsServer.Fields("elw_tipo").Value)
                logItem.elw_source = nvUtiles.isNUll(rsServer.Fields("elw_source").Value)
                logItem.elw_machine = nvUtiles.isNUll(rsServer.Fields("elw_machine").Value)
                logItem.dbinterna = nvUtiles.isNUll(rsServer.Fields("dbinterna").Value, False)
                logItem.IISLog = nvUtiles.isNUll(rsServer.Fields("IISLog").Value, False)

                '  //Ini - Logins
                logItem.allUsers = True
                logItem.syslog_logins = New List(Of String)

                strSQL = "select login  from  nv_log_sistema ls join nv_log_login nll on nll.id_nv_log_sistema = ls.id_nv_log_sistema " &
                         "where ls.id_nv_log_sistema = " & logItem.id_nv_log_sistema

                Dim rsLogin As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordsetNoLogEvent(strSQL)
                logItem.allUsers = rsLogin.EOF
                While Not rsLogin.EOF
                    logItem.syslog_logins.Add(rsLogin.Fields("login").Value)
                    rsLogin.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsLogin)


                'If logItem.log_file Is Nothing And logItem.file_path <> "" Then
                '    Try
                '        logItem.openFile()
                '    Catch ex As Exception
                '        System.Diagnostics.Debug.Print(ex.ToString)
                '    End Try
                'End If

                ' //Si hay un syslog
                If logItem.syslog_url <> "" Then
                    Try
                        Dim sysLogClient As Object = CreateObject("nvSysLog.nvSysLogClient5")
                        nvSession.Contents("nvSysLogClient") = sysLogClient
                    Catch ex As Exception

                    End Try

                End If

                logItem.eventos = New Dictionary(Of String, tnvLogEvent)
                '  var rsEventos = Server.CreateObject("ADODB.Recordset") 
                strSQL = "select * from nv_log_sistema_evento se join nv_log_evento le on se.id_nv_log_evento = le.id_nv_log_evento where id_nv_log_sistema = " & logItem.id_nv_log_sistema
                Dim rsEventos As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordsetNoLogEvent(strSQL)
                Dim logEvent As tnvLogEvent
                While Not rsEventos.EOF
                    logEvent = New tnvLogEvent
                    logEvent.id_nv_log_evento = rsEventos.Fields("id_nv_log_evento").Value
                    logEvent.aServidor = rsEventos.Fields("aServidor").Value
                    logEvent.aSistema = rsEventos.Fields("aSistema").Value
                    logEvent.sysLog_recurso = rsEventos.Fields("sysLog_recurso").Value
                    logEvent.sysLog_severidad = rsEventos.Fields("sysLog_severidad").Value
                    logItem.eventos.Add(rsEventos.Fields("id_nv_log_evento").Value, logEvent)
                    'Cargar _eventos con los elementos configurados para poder encontrarlo mas fácil
                    If Not _eventos.ContainsKey(logEvent.id_nv_log_evento) Then
                        _eventos.Add(logEvent.id_nv_log_evento, New List(Of tnvLogItem))
                    End If
                    _eventos(logEvent.id_nv_log_evento).Add(logItem)
                    rsEventos.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsEventos)
                rsServer.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rsServer)
            last_update = New Date()

            If _runAsync Then
                _threadCola = New Threading.Thread(AddressOf threadColaProcess)
                _threadCola.Start()
            End If

            'nvLog_addEvent("lg_start")
            'return this
        End Sub

        Private Sub threadColaProcess()
            Dim colaEvent As tnvColaEvent
            Do
                While _colaEvents.Count > 0
                    SyncLock _colaEvents.SyncRoot
                        colaEvent = _colaEvents.Dequeue()
                    End SyncLock
                    stats("total_events_process") += 1
                    Dim ts As New System.Diagnostics.Stopwatch
                    ts.Start()
                    colaEvent.logItem.addEvent(colaEvent.evento, colaEvent.params, colaEvent.login, colaEvent.app_cod_sistema, colaEvent.context)
                    ts.Stop()
                    Dim ms As Integer = ts.ElapsedMilliseconds
                    stats("total_ms") += ms
                End While
                If _colaEvents.Count = 0 Then
                    System.Threading.Thread.Sleep(100)
                End If
            Loop Until _threadCola_exit = True
        End Sub

        'Private Property strDate(ByVal fe_e As Date) As String
        '    Get
        '        Return _strDate
        '    End Get
        '    Set(ByVal value As String)
        '        _strDate = value
        '    End Set
        'End Property

        Public Sub start()

        End Sub

        Public Sub close()
            Me.Finalize()
        End Sub

        Public Sub addEvent(ByVal ev As String, Optional ByRef params As String = "", Optional Session As HttpSessionState = Nothing)
            'Disparar el Server Event
            nvServer.Events.RaiseEvent("onLog", ev, params, Session)
            Dim ts As New System.Diagnostics.Stopwatch
            ts.Start()
            stats("total_events") += 1
            If Not _allEvents.Contains(ev.ToLower) AndAlso Not _allEventsMissing.Contains(ev.ToLower) Then

                Dim errEV As New tError()
                errEV.numError = 112
                errEV.titulo = "Advertencia de nvLog"
                errEV.mensaje = "No se encuentra el evento '" & ev & "'"
                errEV.system_reg(Diagnostics.EventLogEntryType.Warning, True)

                If Not DirectCast(stats("event_not_exists"), trsParam).ContainsKey(ev.ToLower) Then stats("event_not_exists")(ev.ToLower) = 0
                stats("event_not_exists")(ev.ToLower) += 1

                _allEventsMissing.add(ev.ToLower)
            End If

            'Existe el evento dentro de la configuración de este server?
            If _eventos.ContainsKey(ev) Then
                'Recorrer todos los Logs que tengan este evento
                For Each logItem As tnvLogItem In _eventos(ev)
                    'logItem.addEvent(ev, params, Session)
                    Dim nvApp As tnvApp = nvFW.nvApp.getInstance(New tnvApp, Session)
                    Dim context As New trsParam
                    context("login") = nvApp.operador.login
                    context("app_cod_sistema") = nvApp.cod_sistema
                    context("host_ip") = nvApp.host_ip
                    context("sessionID") = ""
                    Try
                        context("sessionID") = nvSession.IDSession(Session)
                    Catch ex As Exception

                    End Try

                    context("httpsession") = Session
                    If _runAsync Then
                        SyncLock _colaEvents.SyncRoot
                            _colaEvents.Enqueue(New tnvColaEvent(logItem, ev, params, nvApp.operador.login, nvApp.cod_sistema, context))
                        End SyncLock
                    Else
                        stats("total_events_process") += 1
                        logItem.addEvent(ev, params, nvApp.operador.login, nvApp.cod_sistema, context)
                    End If

                Next
            End If
            ts.Stop()
            Dim ms As Integer = ts.ElapsedMilliseconds
            stats("total_ms") += ms
            stats("total_ms_sync") += ms
        End Sub

        Protected Overrides Sub Finalize()
            _threadCola_exit = True
            While _threadCola.IsAlive
                System.Threading.Thread.Sleep(100)
            End While

            'If Not Me._threadCola Is Nothing Then
            '    If Me._threadCola.IsAlive Then Me._threadCola.Abort()
            'End If
            Dim i As Integer
            Try
                For Each i In logs.Keys
                    If logs(i).cn_db_interna IsNot Nothing Then DBDesconectar(logs(i).cn_db_interna)
                    If logs(i).cn_db_externa IsNot Nothing Then DBDesconectar(logs(i).cn_db_externa)
                    Try
                        If Not logs(i).log_file Is Nothing Then
                            logs(i).log_file.Close()
                            logs(i).log_file = Nothing
                        End If
                    Catch ex As Exception
                    End Try
                Next
            Catch ex As Exception
            End Try
            MyBase.Finalize()
        End Sub

        Public Class tnvColaEvent
            Public logItem As tnvLogItem
            Public evento As String
            Public params As String
            Public login As String
            Public app_cod_sistema As String
            Public context As trsParam


            Public Sub New(logItem As tnvLogItem, evento As String, params As String, login As String, app_cod_sistema As String, context As trsParam)
                Me.logItem = logItem
                Me.evento = evento
                Me.params = params
                Me.login = login
                Me.app_cod_sistema = app_cod_sistema
                Me.context = context
            End Sub
        End Class

    End Class

    Public Class tnvLogItem


        Public id_nv_log_sistema As Integer
        Public cod_servidor As String
        Public cod_sistema As String
        Public file_path As String
        Public syslog_url As String
        Public syslog_port As Integer
        Public dbcn_string As String
        Public dbtable As String
        Public elw_idevento As String
        Public elw_registro As String
        Public elw_tipo As String
        Public elw_source As String
        Public elw_machine As String
        Public dbinterna As Boolean
        Public IISLog As Boolean

        'Ini - Logins
        Public allUsers As Boolean
        Public syslog_logins As List(Of String)

        Public log_file As IO.StreamWriter = Nothing
        Public cn_db_interna As ADODB.Connection
        Public cn_db_externa As ADODB.Connection

        Public eventos As Dictionary(Of String, tnvLogEvent)
        Public stats As New trsParam

        Private _parent As tnvLog

        Public Sub New(parent As tnvLog)
            _parent = parent
            stats("total_ms") = 0 'Total de ms que consumió el proceso
            'stats("total_events") = 0 'Cantidad de eventos que tiró el sistema independientemente de si están configurados
            stats("total_events_process") = 0 'Cantidad de eventos que proceso el sistema independientemente de si están configurados
            stats("total_events_send") = 0 'Cantidad de eventos que fueron enviados. Solo los que están configurados
            stats("total_event_errors") = 0 'Cantidad de errores en los que se enviaron. Un evento puede tirar mas de un error

        End Sub

        Public Sub addEvent(ByVal ev As String, ByRef params As String, login As String, app_cod_sistema As String, context As trsParam)
            stats("total_events_process") += 1
            Dim ts As New System.Diagnostics.Stopwatch
            ts.Start()
            Dim evento As tnvLogEvent
            'Dim nvApp As tnvApp = nvFW.nvApp.getInstance(New tnvApp, Session)
            'If nvApp Is Nothing Then nvApp = New tnvApp
            'Controlar que exista el evento
            If Not eventos.Keys.Contains(ev) Then Exit Sub
            'Si es un evento para usuarios determinados, controlar que exista el usuario
            If Not allUsers Then
                If login <> "" And Not syslog_logins.Contains(login) Then Exit Sub
            End If

            'Evaluar que que corresponda enviar el evento en fucnión de la configuración del mismo
            evento = Me.eventos(ev)
            If (evento.aServidor And (Me.cod_servidor = nvServer.cod_servidor Or Me.cod_servidor = "")) Or (evento.aSistema And (Me.cod_sistema = cod_sistema Or Me.cod_sistema = "")) Then
                _parent.stats("total_events_send") += 1
                stats("total_events_send") += 1
                sendEvent(ev, params, context)
            End If
            ts.Stop()
            Dim ms As Integer = ts.ElapsedMilliseconds
            stats("total_ms") += ms
        End Sub

        Public Sub sendEvent(ByVal ev As String, ByRef params As String, context As trsParam)
            Dim fe_e As DateTime = Now()
            Dim strLog As String = ""
            Dim ELog As EventLog
            'Dim nvApp As tnvApp = nvFW.nvApp.getInstance(New tnvApp, Session) ' nvUtiles.get_nvApp()
            Dim sessionID As String = If(context("sessionID") Is Nothing, "", context("sessionID"))


            'If nvApp Is Nothing Then nvApp = New tnvApp
            Dim evento As tnvLogEvent = eventos(ev)
            Dim host_ip As String = If(context("host_ip") Is Nothing, "", context("host_ip"))

            strLog = fe_e.ToString("MM/dd/yyyy hh:mm:ss.ffff") & ";" & ev & ";" & nvServer.cod_servidor & ";" & context("app_cod_sistema") & ";" & context("login") & ";" & id_nv_log_sistema & ";" & host_ip & ";" & sessionID & ";" & params
            '//Log de archivo
            If Me.file_path <> "" Then
                Try
                    'Si el log llega a 5MB continuar en otro archivo
                    If Me.log_file Is Nothing Then Me.openFile()
                    If Me.log_file.BaseStream.Length >= 5242880 Then
                        Me.log_file.Close()
                        Me.openFile()
                    End If
                    Me.log_file.WriteLine(strLog)
                Catch ex As Exception
                    stats("total_event_errors") += 1
                    _parent.stats("total_event_errors") += 1
                    Debug.Print("tnvLogEvent::sendEvent::Log de archivo" & vbCrLf & ex.Message)
                End Try

            End If

            '//Log de IIS
            If (Me.IISLog) Then
                Try
                    HttpContext.Current.Response.AppendToLog(strLog)
                Catch ex As Exception
                    stats("total_event_errors") += 1
                    _parent.stats("total_event_errors") += 1
                    Debug.Print("tnvLogEvent::sendEvent::Log de IIS" & vbCrLf & ex.Message)
                End Try
            End If

            '//event log window
            If Me.elw_registro <> "" And Me.elw_source <> "" Then
                Try
                    nvLog.EventWindows_addEvent(Me.elw_machine, Me.elw_source, Me.elw_registro, strLog, getLogEntryTypeFromsysLog_severidad(evento.sysLog_severidad))
                Catch ex As Exception
                    stats("total_event_errors") += 1
                    _parent.stats("total_event_errors") += 1
                End Try

                ''me.elw_tipo:  {ERROR|WARNING|INFORMATION|SUCCESSAUDIT|FAILUREAUDIT}
                ''me.elw_idevento: EventID
                ''me.elw_registro: {APPLICATION | SYSTEM}
                ''strParam: Description
                ''me.elw_source: SrcName
                'Dim sMachine As String = Me.elw_machine
                'If sMachine = "" Then sMachine = "."
                'Dim sLog As String = Me.elw_registro
                'Dim sSource As String = Me.elw_source
                'Try
                '    'Si no existe el log o el source crearlo.
                '    'Primero si no existe el log y si el souce eliminarlo
                '    If Not EventLog.Exists(sLog, sMachine) Then
                '        If EventLog.SourceExists(sSource, sMachine) Then
                '            EventLog.DeleteEventSource(sSource, sMachine)
                '        End If
                '    End If
                '    'Ahora si no existe, crearlo
                '    If Not EventLog.SourceExists(sSource, sMachine) Then
                '        Try
                '            Dim creationData As New EventSourceCreationData(sSource, sLog)
                '            creationData.MachineName = sMachine
                '            EventLog.CreateEventSource(creationData)
                '        Catch ex As Exception
                '        End Try
                '    End If

                '    '//registrar evento
                '    ELog = New EventLog(sLog, sMachine, sSource)
                '    'strLog = fe_e.ToString("MM/dd/yyyy hh:mm:ss.ffff") & ";" & nvServer.cod_servidor & ";" & nvApp.cod_sistema & ";" & nvApp.operador.login & ";" & id_nv_log_sistema & ";" & nvSession.IDSession & ";" & ev & ";" & params
                '    ELog.WriteEntry(strLog, getLogEntryTypeFromsysLog_severidad(evento.sysLog_severidad))

                'Catch ex As Exception
                '    Debug.Print("tnvLogEvent::sendEvent::Log db eventos de windows." & vbCrLf & ex.Message)
                'End Try
            End If

            '// Log db interna
            Dim strSQL As String
            Dim intentos As Integer = 0
            If Me.dbinterna Then
reintentar_db_interna:
                intentos += 1
                Try
                    If Me.cn_db_interna Is Nothing Then Me.cn_db_interna = New ADODB.Connection
                    If Me.cn_db_interna.State <> ADODB.ObjectStateEnum.adStateOpen Then
                        Me.cn_db_interna = New ADODB.Connection
                        Me.cn_db_interna.Open(nvServer.cn_string)
                    End If
                Catch ex As Exception
                    stats("total_event_errors") += 1
                    _parent.stats("total_event_errors") += 1
                    Me.cn_db_interna = Nothing
                    Debug.Print("tnvLogEvent::sendEvent::Log db interna. No se puede coonectar a la DB. " & vbCrLf & ex.Message)
                End Try

                If Me.cn_db_interna IsNot Nothing Then
                    Try
                        strSQL = " INSERT INTO nv_log ([cod_servidor],[cod_sistema],[momento] ,[login],[host_ip], [id_nv_log_sistema], [sessionID], [id_log_evento],[params])"
                        strSQL += " VALUES ('" & nvServer.cod_servidor & "' ,'" & context("app_cod_sistema") & "' ,getdate() ,'" & context("login") & "','" & context("host_ip") & "' ," & id_nv_log_sistema & " ,'" + sessionID.Replace("'", "''")
                        strSQL += "' ,'" + ev + "', '" & params.Replace("'", "''") & "')"
                        Me.cn_db_interna.Execute(strSQL)
                    Catch ex As Exception
                        If intentos = 1 Then
                            Me.cn_db_interna = Nothing
                            GoTo reintentar_db_interna
                        Else
                            stats("total_event_errors") += 1
                            _parent.stats("total_event_errors") += 1
                            Debug.Print("tnvLogEvent::sendEvent::Log db interna. Error SQL '" & strSQL & "'. " & vbCrLf & ex.Message)
                        End If
                    End Try
                End If
            End If

            '// Log db 
            If Me.dbcn_string <> "" And Me.dbtable <> "" Then
reintentar_db_externa:
                intentos += 1
                Try
                    If Me.cn_db_externa Is Nothing Then Me.cn_db_externa = New ADODB.Connection
                    If Me.cn_db_externa.State <> ADODB.ObjectStateEnum.adStateOpen Then
                        Me.cn_db_externa = New ADODB.Connection
                        Me.cn_db_externa.Open(nvServer.cn_string)
                    End If
                Catch ex As Exception
                    stats("total_event_errors") += 1
                    _parent.stats("total_event_errors") += 1
                    Me.cn_db_externa = Nothing
                    Debug.Print("tnvLogEvent::sendEvent::Log db externa. No se puede coonectar a la DB. " & vbCrLf & ex.Message)
                End Try
                If Me.cn_db_externa IsNot Nothing Then
                    Try
                        strSQL = " INSERT INTO " & Me.dbtable & " ([cod_servidor],[cod_sistema],[momento] ,[login], [id_nv_log_sistema], [sessionID], [id_log_evento],[params])"
                        strSQL += " VALUES ('" & nvServer.cod_servidor & "' ,'" & context("app_cod_sistema") & "' ,getdate() ,'" & context("login") & "' ," & id_nv_log_sistema & " , '" + sessionID.Replace("'", "''")
                        strSQL += "' ,'" + ev + "', '" & params.Replace("'", "''") & "')"
                        Me.cn_db_externa.Execute(strSQL)
                    Catch ex As Exception
                        If intentos = 1 Then
                            Me.cn_db_interna = Nothing
                            GoTo reintentar_db_interna
                        Else
                            stats("total_event_errors") += 1
                            _parent.stats("total_event_errors") += 1
                            Debug.Print("tnvLogEvent::sendEvent::Log db externa. Error SQL '" & strSQL & "'. " & vbCrLf & ex.Message)
                        End If
                    End Try
                End If
            End If

            '//Log de SysLog
            If Me.syslog_url <> "" Then
                'strLog = nvServer.cod_servidor & ";" & nvApp.cod_sistema & ";" & nvApp.operador.login & ";" & id_nv_log_sistema & ";" & nvSession.IDSession & ";" & ev & ";" & params & vbCrLf
                Try
                    'Dim sysLogClient As nvSysLog.tnvSysLogClient = New nvSysLog.tnvSysLogClient '= nvSession.Contents("nvSysLogClient") '//Server.CreateObject("nvSysLog.nvSysLogClient5")
                    nvSysLog.nvSysLogClient.Send(Me.syslog_url, Me.syslog_port, evento.sysLog_recurso, evento.sysLog_severidad, strLog & vbCrLf)
                Catch ex As Exception
                    stats("total_event_errors") += 1
                    _parent.stats("total_event_errors") += 1
                    Debug.Print("tnvLogEvent::sendEvent::Log de SysLog." & vbCrLf & ex.Message)
                End Try
            End If
        End Sub



        Private Function getLogEntryTypeFromsysLog_severidad(ByVal severidad As Integer) As EventLogEntryType
            Dim res As EventLogEntryType
            Select Case severidad
                Case 0 '          Emergencia()
                    res = EventLogEntryType.Warning
                Case 1 '          Alerta()
                    res = EventLogEntryType.Warning
                Case 2 '          Crítico()
                    res = EventLogEntryType.Warning
                Case 3 '	Error
                    res = EventLogEntryType.Error
                Case 4 '          Peligro()
                    res = EventLogEntryType.Warning
                Case 5 '          Aviso()
                    res = EventLogEntryType.Information
                Case 6 '          Información()
                    res = EventLogEntryType.Information
                Case 7 '          Depuración()
                    res = EventLogEntryType.Information
                Case Else
                    res = EventLogEntryType.Information
            End Select
            Return res
        End Function

        Public Sub openFile()
            Dim filename As String = nvServer.appl_physical_path & "App_Data\log\" & Me.file_path
            Dim directorio As String = System.IO.Path.GetDirectoryName(filename)
            Dim ext As String = System.IO.Path.GetExtension(filename)
            If ext = "" Then ext = ".log"
            filename = System.IO.Path.GetFileNameWithoutExtension(filename)
            Dim cont As Integer = 1
            Dim path_file As String = directorio & "\" & filename & "_" & Now().ToString("MMddyyyy_") & cont & ext
            While System.IO.File.Exists(path_file)
                cont = cont + 1
                path_file = directorio & "\" & filename & "_" & Now().ToString("MMddyyyy_") & cont & ext
            End While
            nvReportUtiles.create_folder(path_file)
            Me.log_file = New IO.StreamWriter(path_file, True, nvConvertUtiles.currentEncoding)
            Me.log_file.AutoFlush = True
            Me.log_file.WriteLine("fecha;evento;cod_servidor;cod_sistema;login;id_nv_log_sistema;host_ip;session_id;param01;param02;param03;param04;param05;param06;param07;param08;param09;param10")
        End Sub
    End Class


    Public Class tnvLogEvent
        Public id_nv_log_evento As String
        Public aServidor As Boolean
        Public aSistema As Boolean
        Public sysLog_recurso As Integer
        Public sysLog_severidad As Integer
    End Class


End Namespace