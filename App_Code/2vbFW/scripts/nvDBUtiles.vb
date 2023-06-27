Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports Microsoft.VisualBasic.Logging
Imports System

Namespace nvFW
    Public Class nvDBUtiles

        'Estructura de datos que registra cada conexión disponible dentro de la aplicación


        Public Enum emunDBType
            db_admin = 0
            db_app = 1
            db_other = 2
        End Enum

        Public Shared db_admin As emunDBType = emunDBType.db_admin

        'DBConectar: Función base de conexión a las bases de datos de las aplicaciones
        'Todas las conexiones de aplicación de abren con esta función
        'Devuelve un objeto connection, conectado a la base de datos del parámetro
        'Parametros:
        'cod_cn = define la conexión a utilizar, si se deja vacío utiliza la conexión principal ('default')

        Public Shared Function ADMDBConectar() As ADODB.Connection
            Return pvDBConectar(emunDBType.db_admin)
        End Function

        Public Shared Function DBConectar(ByVal db_type As emunDBType, Optional ByVal _nvcn As tDBConection = Nothing) As ADODB.Connection
            Return pvDBConectar(db_type:=db_type, _nvcn:=_nvcn)
        End Function
        Public Shared Function DBConectar(Optional ByVal cod_cn As String = Nothing) As ADODB.Connection
            If cod_cn = "admin" Then
                Throw New Exception("No se puede consultar la base admin por este método")
            End If
            Return pvDBConectar(emunDBType.db_app, cod_cn)
        End Function

        Private Shared Function pvDBConectar(ByVal db_type As emunDBType, Optional ByVal cod_cn As String = Nothing, Optional ByVal _nvcn As tDBConection = Nothing) As ADODB.Connection
            Return pvDBConectar(db_type, cod_cn, 1, _nvcn)
        End Function


        Public Shared Function cn_check_nocount(cn As ADODB.Connection) As String
            Try
                Dim rs As ADODB.Recordset = cn.Execute("select dbo.fw_check_nocount() as nocount")
                Return rs.Fields("nocount").Value
            Catch ex As Exception

            End Try
            Return "Error"
        End Function
        Public Shared Function _cn_check_ansi_warning(cn As ADODB.Connection) As String
            Try
                Dim rs As ADODB.Recordset = cn.Execute("select dbo.fw_check_ANSI_WARNINGS() as ANSI_WARNINGS")
                Return rs.Fields("ANSI_WARNINGS").Value
            Catch ex As Exception

            End Try
            Return "Error"
        End Function

        'Private Shared Function pvDBConectar(ByVal db_type As emunDBType, ByVal cod_cn As String, ByVal intentos As Integer, Optional ByVal _nvcn As tDBConection = Nothing) As ADODB.Connection
        '    Dim nvcn As tDBConection
        '    Dim connection_string As String = ""
        '    Dim ads_usuario As String

        '    If cod_cn Is Nothing Or cod_cn = "" Then cod_cn = "default"

        '    Select Case db_type
        '        Case emunDBType.db_admin
        '            nvcn = New tDBConection
        '            nvcn.cn_string = nvServer.cn_string
        '            nvcn.cn_tipo = "SQL Server"
        '            nvcn.excaslogin = False
        '            connection_string = nvServer.cn_string ' HttpContext.Current.Application.Contents("nv_cn_string")
        '        Case emunDBType.db_app
        '            'Dim app_cn_strings As Dictionary(Of String, tDBConection)
        '            'app_cn_strings = nvSession.Contents("app_cn_strings")
        '            nvcn = getDBConection(cod_cn)
        '            connection_string = nvcn.cn_string
        '        Case emunDBType.db_other
        '            If _nvcn Is Nothing Then
        '                nvcn = New tDBConection
        '                nvcn.cn_string = cod_cn
        '                nvcn.cn_tipo = "SQL Server"
        '                nvcn.excaslogin = False
        '                connection_string = cod_cn
        '            Else
        '                nvcn = _nvcn
        '                connection_string = nvcn.cn_string
        '            End If
        '    End Select
        '    'If db_type = emunDBType.db_admin Then
        '    '    connection_string = nvServer.cn_string ' HttpContext.Current.Application.Contents("nv_cn_string")
        '    'Else
        '    '    'Dim app_cn_strings As Dictionary(Of String, tDBConection)
        '    '    'app_cn_strings = nvSession.Contents("app_cn_strings")
        '    '    nvcn = getDBConection(cod_cn)
        '    '    connection_string = nvcn.cn_string
        '    'End If

        '    Dim cn As ADODB.Connection = New ADODB.Connection
        '    Dim salir As Boolean
        '    Dim intentos2 As Integer
        '    'cn.cursorLocation = 3
        '    Try
        '        cn.Open(connection_string)
        '        If Not nvcn Is Nothing Then
        '            If nvcn.cn_tipo = "SQL Server" Then
        '                intentos2 = 0
        '                Do
        '                    salir = True
        '                    Try
        '                        intentos2 += 1
        '                        cn.Execute("set nocount on")
        '                    Catch ex3 As System.Runtime.InteropServices.COMException
        '                        If intentos2 < 100 And ex3.ErrorCode = -2147467259 Then
        '                            salir = False
        '                        End If
        '                    End Try
        '                Loop Until salir
        '            End If
        '            If nvcn.excaslogin And db_type <> emunDBType.db_admin Then
        '                'ads_usuario = nvFW.nvApp.getInstance.operador.ads_usuario
        '                Dim strSQL As String = "if (charindex('" & nvcn.excasloginuser & "', system_user) = 0)" & vbCrLf & "execute as login = '" & nvcn.excasloginuser & "'"
        '                cn.Execute(strSQL)
        '            End If
        '        End If
        '    Catch ex2 As System.Runtime.InteropServices.COMException
        '        If intentos < 100 And ex2.ErrorCode = -2147467259 Then
        '            If cn.State = ADODB.ObjectStateEnum.adStateOpen Then
        '                Try
        '                    Stop
        '                    cn.Close()
        '                Catch ex4 As Exception
        '                End Try
        '            End If
        '            Return pvDBConectar(db_type, cod_cn, intentos + 1)
        '        Else
        '            Throw ex2
        '        End If

        '    Catch ex As Exception
        '        Stop
        '        Throw ex
        '    End Try

        '    Return cn
        'End Function


        Private Shared Function pvDBConectar(ByVal db_type As emunDBType, ByVal cod_cn As String, ByVal intentos As Integer, Optional ByVal _nvcn As tDBConection = Nothing) As ADODB.Connection
            Dim nvcn As tDBConection
            Dim connection_string As String = ""

            Dim nvApp As nvFW.tnvApp = nvFW.nvApp.getInstance(New tnvApp)

            If cod_cn Is Nothing Or cod_cn = "" Then cod_cn = "default"

            Select Case db_type
                Case emunDBType.db_admin
                    nvcn = New tDBConection
                    nvcn.cn_string = nvServer.cn_string
                    nvcn.cn_tipo = "SQL Server"
                    nvcn.excaslogin = False
                    connection_string = nvServer.cn_string ' HttpContext.Current.Application.Contents("nv_cn_string")
                Case emunDBType.db_app
                    'Dim app_cn_strings As Dictionary(Of String, tDBConection)
                    'app_cn_strings = nvSession.Contents("app_cn_strings")
                    nvcn = getDBConection(cod_cn)
                    connection_string = nvcn.cn_string
                Case emunDBType.db_other
                    If _nvcn Is Nothing Then
                        nvcn = New tDBConection
                        nvcn.cn_string = cod_cn
                        nvcn.cn_tipo = "SQL Server"
                        nvcn.excaslogin = False
                        connection_string = cod_cn ' ???? : Aca no establece la cadena de conexion, se necesita de la nvapp.cns
                    Else
                        nvcn = _nvcn
                        connection_string = nvcn.cn_string
                    End If
            End Select
            'If db_type = emunDBType.db_admin Then
            '    connection_string = nvServer.cn_string ' HttpContext.Current.Application.Contents("nv_cn_string")
            'Else
            '    'Dim app_cn_strings As Dictionary(Of String, tDBConection)
            '    'app_cn_strings = nvSession.Contents("app_cn_strings")
            '    nvcn = getDBConection(cod_cn)
            '    connection_string = nvcn.cn_string
            'End If
            Dim impersonationContext As System.Security.Principal.WindowsImpersonationContext
            Dim cn As ADODB.Connection = New ADODB.Connection
            Dim salir As Boolean
            Dim intentos2 As Integer
            'cn.cursorLocation = 3
            Try

                intentos2 = 0
                Do
                    salir = True
                    intentos2 += 1

                    If nvcn.SSO Then
                        'Dim token As System.IntPtr = CType(nvcn.WindowsIdentity, System.Security.Principal.WindowsIdentity).Token
                        'Dim a As New System.Security.Principal.WindowsIdentity(token)
                        'impersonationContext = a.Impersonate()
                        impersonationContext = nvSecurity.nvImpersonate.getImpersonationContext(nvcn.WindowsIdentity)
                    End If

                    Dim stopWatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                    Dim ts As TimeSpan

                    cn.Open(connection_string)

                    stopWatch.Stop()
                    'If logEvent Then
                    ts = stopWatch.Elapsed
                    nvLog.addEvent("rd_dbutiles_cn", ";" & nvLog.parentLogTrack & ";" & ts.TotalMilliseconds & ";" & IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";""")
                    'End If

                    If nvcn.SSO Then
                        impersonationContext.Undo()
                    End If

                    Try
                        If Not nvcn Is Nothing Then
                            If nvcn.cn_tipo = "SQL Server" Then

                                Dim strSQLInit As String = ""
                                strSQLInit += "SET NOCOUNT ON" & vbCrLf
                                'strSQLInit += "SET ANSI_WARNINGS OFF" & vbCrLf

                                'Crea la tabla temporal '#tmp_cn_values' donde guarda los datos de la conexión
                                'If db_type <> emunDBType.db_admin And nvApp.operador.login <> "" Then
                                '    Dim SessionId As String = nvUtiles.isNUllorEmpty(nvSession.IDSession(), "")
                                '    strSQLInit += "BEGIN TRY" & vbCrLf & "execute nv_set_login '" & nvServer.cod_servidor & "', " & nvApp.server_port & ", '" & nvApp.cod_sistema & "', '" & nvApp.operador.login & "', '" & nvSession.IDSession & "'" & vbCrLf & "END TRY" & vbCrLf & "BEGIN CATCH" & vbCrLf & "END CATCH" & vbCrLf
                                'End If

                                If nvcn.excaslogin And db_type <> emunDBType.db_admin Then
                                    'ads_usuario = nvFW.nvApp.getInstance.operador.ads_usuario
                                    strSQLInit += "if (charindex('" & nvcn.excasloginuser & "', system_user) = 0)" & vbCrLf & "execute as login = '" & nvcn.excasloginuser & "'  WITH NO REVERT"
                                End If

                                cn.Execute(strSQLInit)
                            End If

                            'If nvcn.insertTempOperador Then
                            '    cn.Execute("create table #_nova_user_login(login)" & vbCrLf &
                            '               "insert into #_nova_user_login(login )" & vbCrLf &
                            '               "Values('" & nvcn.excasloginuser & "')")
                            'End If

                        End If
                    Catch ex3 As System.Runtime.InteropServices.COMException
                        Try
                            cn.Close()
                        Catch ex4 As Exception

                        End Try
                        If intentos2 < 100 And ex3.ErrorCode = -2147467259 Then
                            salir = False
                        End If
                    End Try

                    ' If intentos2 >= 100 Then
                    '   Stop
                    '  End If

                Loop Until salir
            Catch ex2 As System.Runtime.InteropServices.COMException
                If nvcn.SSO Then
                    impersonationContext.Undo()
                End If
                If intentos < 100 And ex2.ErrorCode = -2147467259 Then
                    If cn.State = ADODB.ObjectStateEnum.adStateOpen Then
                        Try
                            '  Stop
                            cn.Close()
                        Catch ex4 As Exception
                        End Try
                    End If

                    Return pvDBConectar(db_type, cod_cn, intentos + 1, _nvcn:=_nvcn)
                    'Else
                    '  Throw ex2
                End If

            Catch ex As Exception
                ' Stop
                ' Throw ex
            End Try
            ' If cn Is Nothing Then
            ' Stop
            ' End If
            Return cn
        End Function
        Private Shared Function getDBConectionFromJS(ByVal a As Object) As tDBConection
            Dim res As New tDBConection
            res.cn_default = a.cn_default
            res.cn_nombre = a.cn_nombre
            res.cn_string = a.cn_string
            res.cn_tipo = a.cn_tipo
            res.excaslogin = a.excaslogin
            res.id_cn_tipo = a.id_cn_tipo
            Return res
        End Function

        'Procedimeinto para solucionar un ¡tema de interoperabilidad entre jscript y .net
        'No permite listar los campos ni traer listas
        Public Shared Function getDBConection(ByVal cod_cn As String) As tDBConection
            Try
                Dim nvApp As tnvApp = nvFW.nvApp.getInstance() ' nvSession.Contents("nvApp")
                Dim app_cn_strings As Dictionary(Of String, tDBConection) = nvApp.app_cns
                Dim nvcn As tDBConection = app_cn_strings(cod_cn)
                Return nvcn
            Catch ex As Exception
                'Try
                '    If nvSession.Contents("app_cn_strings").cn0.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn0)
                '    End If
                'Catch ex1 As Exception

                'End Try
                'Try
                '    If nvSession.Contents("app_cn_strings").cn1.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn1)
                '    End If
                'Catch ex1 As Exception

                'End Try
                'Try
                '    If nvSession.Contents("app_cn_strings").cn2.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn2)
                '    End If
                'Catch ex1 As Exception

                'End Try
                'Try
                '    If nvSession.Contents("app_cn_strings").cn3.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn3)
                '    End If
                'Catch ex1 As Exception

                'End Try
                'Try
                '    If nvSession.Contents("app_cn_strings").cn4.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn4)
                '    End If
                'Catch ex1 As Exception

                'End Try
                'Try
                '    If nvSession.Contents("app_cn_strings").cn5.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn5)
                '    End If
                'Catch ex1 As Exception

                'End Try
                'Try
                '    If nvSession.Contents("app_cn_strings").cn6.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn6)
                '    End If
                'Catch ex1 As Exception

                'End Try
                'Try
                '    If nvSession.Contents("app_cn_strings").cn7.ID = cod_cn Then
                '        Return getDBConectionFromJS(nvSession.Contents("app_cn_strings").cn7)
                '    End If
                'Catch ex1 As Exception

                'End Try

            End Try
            Return Nothing
        End Function
        Public Shared Sub DBDesconectar(Optional ByRef cn As ADODB.Connection = Nothing)

            Try
                If cn.State = ADODB.ObjectStateEnum.adStateOpen Then cn.Close()
            Catch ex As Exception

            End Try
            'cn = Nothing
            'If Not cn Is Nothing Then
            '    If cn.State = 1 Then '//adStateOpen
            '        cn.Close()
            '    End If
            '    cn = Nothing
            'End If
        End Sub



        Public Shared Function ADMDBExecute(ByVal strSQL As String, ByVal CommandTimeout As Integer) As ADODB.Recordset
            Return pvDBExecute(emunDBType.db_admin, strSQL, CommandTimeout)
        End Function
        Public Shared Function ADMDBExecute(ByVal strSQL As String) As ADODB.Recordset
            Return pvDBExecute(emunDBType.db_admin, strSQL)
        End Function
        Public Shared Function ADMDBExecuteNoLogEvent(ByVal strSQL As String) As ADODB.Recordset
            Return pvDBExecute(emunDBType.db_admin, strSQL, , , False)
        End Function


        Public Shared Function DBExecute(ByVal strSQL As String, Optional ByVal CommandTimeout As Integer = 1500, Optional ByVal cod_cn As String = "default", Optional ByVal logEvent As Boolean = True, Optional ByVal _nvcn As tDBConection = Nothing, Optional _cn As ADODB.Connection = Nothing, Optional ByVal autoclose_connection As Boolean = True) As ADODB.Recordset
            If _nvcn Is Nothing Then
                Return pvDBExecute(emunDBType.db_app, strSQL, CommandTimeout, cod_cn, logEvent, _nvcn, _cn, autoclose_connection)
            Else
                Return pvDBExecute(emunDBType.db_other, strSQL, CommandTimeout, cod_cn, logEvent, _nvcn, Nothing, autoclose_connection)
            End If
        End Function
        'Public Shared Function DBExecute(ByVal strSQL As String, ByVal CommandTimeout As Integer, ByVal cod_cn As String) As ADODB.Recordset
        '    Return pvDBExecute(emunDBType.db_app, strSQL, CommandTimeout, cod_cn)
        'End Function
        'Public Shared Function DBExecute(ByVal strSQL As String, ByVal CommandTimeout As Integer) As ADODB.Recordset
        '    Return pvDBExecute(emunDBType.db_app, strSQL, CommandTimeout)
        'End Function
        'Public Shared Function DBExecute(ByVal strSQL As String, ByVal cod_cn As String) As ADODB.Recordset
        '    Return pvDBExecute(emunDBType.db_app, strSQL, , cod_cn)
        'End Function
        'Public Shared Function DBExecute(ByVal strSQL As String) As ADODB.Recordset
        '    Return pvDBExecute(emunDBType.db_app, strSQL)
        'End Function


        Private Shared Function pvDBExecute(ByVal db_type As emunDBType, ByVal strSQL As String, Optional ByVal CommandTimeout As Integer = 1500, Optional ByVal cod_cn As String = "default", Optional ByVal logEvent As Boolean = True, Optional ByVal _nvcn As tDBConection = Nothing, Optional ByRef _cn As ADODB.Connection = Nothing, Optional ByVal autoclose_connection As Boolean = True) As ADODB.Recordset
            Dim cn As ADODB.Connection
            Dim rs As ADODB.Recordset
            Try
                If _cn Is Nothing Then
                    cn = pvDBConectar(db_type, cod_cn, _nvcn)
                Else
                    cn = _cn
                End If
                cn.CommandTimeout = CommandTimeout

            Catch ex As Exception

            End Try


            'Dim ini As Date
            'Dim fin As Date
            'ini = Date.Now
            'Dim t1 As Integer = My.Computer.Clock.TickCount
            Dim stopWatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
            Dim ts As TimeSpan
            Dim recordCount As Integer = 0
            Try
                rs = cn.Execute(strSQL)
                stopWatch.Stop()
                If logEvent Then
                    ts = stopWatch.Elapsed
                    Try
                        recordCount = rs.RecordCount
                    Catch ex As Exception
                    End Try
                    nvLog.addEvent("rd_dbutiles", ";" & nvLog.parentLogTrack & ";" & ts.TotalMilliseconds & ";" & IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";""" & strSQL.Replace(vbCrLf, " ") & """;" & recordCount)
                End If
            Catch ex As Exception
                nvLog.addEvent("rd_dbutiles_error", ";" & nvLog.parentLogTrack & ";" & IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";""" & strSQL.Replace(vbCrLf, " ") & """;""" & ex.Message.Replace(vbCrLf, " ") & """")
                If autoclose_connection Then
                    DBDesconectar(cn)
                End If
                Throw ex
            End Try

            If rs Is Nothing And autoclose_connection Then
                DBDesconectar(cn)
            End If

            Return rs
        End Function

        'Public Function DBExecute2(ByVal strSQL As String, ByRef cn As ADODB.Connection, Optional ByVal CommandTimeout As Integer = 1500)
        '    Dim rs As ADODB.Recordset
        '    cn.CommandTimeout = CommandTimeout
        '    rs = cn.Execute(strSQL)
        '    Return rs
        'End Function
        Public Shared Function ADMDBOpenRecordsetNoLogEvent(ByVal strSQL As String, Optional ByVal CursorType As ADODB.CursorTypeEnum = ADODB.CursorTypeEnum.adOpenStatic,
                                        Optional ByVal LockType As ADODB.LockTypeEnum = ADODB.LockTypeEnum.adLockReadOnly, Optional ByVal CommandTimeout As Integer = 1500,
                                        Optional ByVal CursorLocation As ADODB.CursorLocationEnum = ADODB.CursorLocationEnum.adUseClient) As ADODB.Recordset
            Return pvDBOpenRecordset(emunDBType.db_admin, strSQL, CursorType, LockType, CommandTimeout, CursorLocation, , False)
        End Function
        Public Shared Function ADMDBOpenRecordset(ByVal strSQL As String, Optional ByVal CursorType As ADODB.CursorTypeEnum = ADODB.CursorTypeEnum.adOpenStatic,
                                        Optional ByVal LockType As ADODB.LockTypeEnum = ADODB.LockTypeEnum.adLockReadOnly, Optional ByVal CommandTimeout As Integer = 1500,
                                        Optional ByVal CursorLocation As ADODB.CursorLocationEnum = ADODB.CursorLocationEnum.adUseClient, Optional ByVal logEvent As Boolean = True) As ADODB.Recordset
            Return pvDBOpenRecordset(emunDBType.db_admin, strSQL, CursorType, LockType, CommandTimeout, CursorLocation, , logEvent)
        End Function



        Public Shared Function DBOpenRecordset(ByVal strSQL As String, Optional ByVal CursorType As ADODB.CursorTypeEnum = ADODB.CursorTypeEnum.adOpenStatic,
                                        Optional ByVal LockType As ADODB.LockTypeEnum = ADODB.LockTypeEnum.adLockReadOnly, Optional ByVal CommandTimeout As Integer = 1500,
                                        Optional ByVal CursorLocation As ADODB.CursorLocationEnum = ADODB.CursorLocationEnum.adUseClient, Optional ByVal cod_cn As String = "default", Optional ByVal logEvent As Boolean = True, Optional ByVal _nvcn As tDBConection = Nothing, Optional _cn As ADODB.Connection = Nothing) As ADODB.Recordset
            Return pvDBOpenRecordset(emunDBType.db_app, strSQL, CursorType, LockType, CommandTimeout, CursorLocation, cod_cn, logEvent, _nvcn, _cn)
        End Function

        Public Shared Function pvDBOpenRecordset(ByVal db_type As emunDBType, ByVal strSQL As String, Optional ByVal CursorType As ADODB.CursorTypeEnum = ADODB.CursorTypeEnum.adOpenStatic,
                                        Optional ByVal LockType As ADODB.LockTypeEnum = ADODB.LockTypeEnum.adLockReadOnly, Optional ByVal CommandTimeout As Integer = 1500,
                                        Optional ByVal CursorLocation As ADODB.CursorLocationEnum = ADODB.CursorLocationEnum.adUseClient, Optional ByVal cod_cn As String = "default", Optional ByVal logEvent As Boolean = True, Optional ByVal _nvcn As tDBConection = Nothing, Optional _cn As ADODB.Connection = Nothing) As ADODB.Recordset


            'CursorType()
            'adOpenDynamic = 2
            'adOpenFordwardOnly = 0
            'adOpenKeyset = 1
            'adOpenStatic = 3

            'CursorLocation()
            'adUseClient = 3
            'adUseServer = 2

            'LockType()
            'adLockReadOnly = 1
            'adLockPessimistic = 2
            'adLockOptimistic = 3
            'adLockBatchOptimistic = 4


            Dim cn As ADODB.Connection
            Dim rs As ADODB.Recordset

            If _cn Is Nothing Then
                cn = pvDBConectar(db_type, cod_cn, _nvcn)
            Else
                cn = _cn
            End If
            cn.CommandTimeout = CommandTimeout

            rs = New ADODB.Recordset
            rs.CursorLocation = CursorLocation
            'Dim ini As Date
            'Dim fin As Date
            Dim stopWatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
            Dim ts As TimeSpan
            'Dim t1 As Integer = My.Computer.Clock.TickCount
            Try
                rs.Open(strSQL, cn, CursorType, LockType)
                stopWatch.Stop()
                If logEvent Then
                    ts = stopWatch.Elapsed
                    'fin = Date.Now
                    'Dim elapsedtime As Integer = My.Computer.Clock.TickCount - t1
                    'Dim DifferenceInMilliseconds As Double = nvConvertUtiles.DateDiffMilliseconds(ini, fin)
                    'nvLog.addEvent("rd_dbutiles", IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";" & ini.ToString("MM/dd/yyyy hh:mm:ss.ffff") & ";" & fin.ToString("MM/dd/yyyy hh:mm:ss.ffff") & ";" & DifferenceInMilliseconds & "--" & elapsedtime & ";""" & strSQL.Replace(vbCrLf, " ") & """")
                    nvLog.addEvent("rd_dbutiles", ";" & nvLog.parentLogTrack & ";" & ts.TotalMilliseconds & ";" & IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";""" & strSQL.Replace(vbCrLf, " ") & """;" & rs.RecordCount)
                End If
            Catch ex As Exception
                nvLog.addEvent("rd_dbutiles_error", ";" & nvLog.parentLogTrack & ";" & IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";""" & strSQL.Replace(vbCrLf, " ") & """;""" & ex.Message.Replace(vbCrLf, " ") & """")
                If _cn Is Nothing Then DBDesconectar(cn)
                Throw ex
            End Try
            Return rs
        End Function

        Public Shared Function pvDBCommandRecordset(ByVal db_type As emunDBType, ByRef rs As ADODB.Recordset, Optional ByVal cod_cn As String = "default",
                                                    Optional ByVal logEvent As Boolean = True, Optional ByVal _nvcn As nvFW.tDBConection = Nothing, Optional _cn As ADODB.Connection = Nothing, Optional noDBClose As Boolean = False) As ADODB.Recordset


            If rs.ActiveCommand.ActiveConnection Is Nothing Then
                If _cn Is Nothing Then
                    rs.ActiveCommand.ActiveConnection = pvDBConectar(db_type, cod_cn, _nvcn)
                Else
                    rs.ActiveCommand.ActiveConnection = _cn
                End If
            End If
            Dim cn As ADODB.Connection = rs.ActiveCommand.ActiveConnection

            'Dim ini As Date
            'Dim fin As Date
            'ini = Date.Now
            Dim recordcount As Long = 0
            Dim commandtext As String = rs.ActiveCommand.commandText
            Dim stopWatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
            Dim ts As TimeSpan
            Try
                rs.Open()
                Try
                    recordcount = rs.RecordCount
                Catch ex As Exception
                End Try
                If rs.State = 0 And noDBClose = False Then
                    rs = Nothing
                    DBDesconectar(cn)
                End If

                stopWatch.Stop()
                If logEvent Then
                    'Threading.Thread.Sleep(1)
                    'fin = Date.Now
                    'Dim DifferenceInMilliseconds As Double = nvConvertUtiles.DateDiffMilliseconds(ini, fin)
                    ts = stopWatch.Elapsed
                    nvLog.addEvent("rd_dbutiles", ";" & nvLog.parentLogTrack & ";" & ts.TotalMilliseconds & ";" & IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";""" & commandtext.Replace(vbCrLf, " ") & """;" & recordcount)
                End If
            Catch ex As Exception
                nvLog.addEvent("rd_dbutiles_error", ";" & nvLog.parentLogTrack & ";" & IIf(db_type = emunDBType.db_admin, "admin", cod_cn) & ";""" & commandtext.Replace(vbCrLf, " ") & """;""" & ex.Message.Replace(vbCrLf, " ") & """")
                Try
                    DBDesconectar(cn)
                Catch ex3 As Exception
                End Try
                Throw ex
            End Try
            Return rs
        End Function

        Public Shared Sub DBCloseRecordset(rs As ADODB.Recordset, Optional ByVal close_connection As Boolean = True)
            'State()
            'adStateClosed = 0 = Object is closed 
            'adStateConnecting = 2 = Object is connecting 
            'adStateExecuting = 4 = Object is executing 
            'adStateFetching = 8 = Object is fetching 
            'adStateOpen = 1 = Object is open 

            If rs Is Nothing Then
                Exit Sub
            End If

            'cerrar recordset
            Dim ActiveConnection As ADODB.Connection = rs.ActiveConnection
            Try
                rs.Close()
                rs = Nothing
            Catch ex As Exception
            End Try
            'cerrar conexion activa en caso de existir
            If close_connection Then
                If Not ActiveConnection Is Nothing Then DBDesconectar(ActiveConnection)
            End If
        End Sub


        Public Class tnvDBCommand
            Private _cmd As ADODB.Command
            Private _rs As ADODB.Recordset
            Private _db_type As nvDBUtiles.emunDBType
            Private _cod_cn As String
            Private _nvcn As nvFW.tDBConection

            Public Sub New(ByVal commandText As String, Optional ByVal commandType As ADODB.CommandTypeEnum = ADODB.CommandTypeEnum.adCmdText,
                           Optional ByVal db_type As nvDBUtiles.emunDBType = nvDBUtiles.emunDBType.db_app, Optional ByVal cod_cn As String = "default",
                           Optional ByVal CursorType As ADODB.CursorTypeEnum = ADODB.CursorTypeEnum.adOpenStatic,
                           Optional ByVal LockType As ADODB.LockTypeEnum = ADODB.LockTypeEnum.adLockReadOnly, Optional ByVal CommandTimeout As Integer = 1500,
                           Optional ByVal CursorLocation As ADODB.CursorLocationEnum = ADODB.CursorLocationEnum.adUseClient, Optional ByVal nvcn As nvFW.tDBConection = Nothing, Optional cn As ADODB.Connection = Nothing, Optional ByVal NamedParameters As Object = Nothing)

                Try
                    _db_type = db_type
                    _cod_cn = cod_cn
                    _cmd = New ADODB.Command
                    _nvcn = nvcn
                    If cn Is Nothing Then
                        _cmd.ActiveConnection = pvDBConectar(db_type, cod_cn, nvcn)
                    Else
                        _cmd.ActiveConnection = cn
                    End If
                    _cmd.CommandText = commandText
                    _cmd.CommandType = commandType
                    _cmd.CommandTimeout = CommandTimeout

                    '_cmd.NamedParameters = True
                    If NamedParameters Is Nothing Then
                        NamedParameters = (commandType = ADODB.CommandTypeEnum.adCmdStoredProc)
                    Else
                        NamedParameters = (commandType = True)
                    End If

                    _cmd.NamedParameters = NamedParameters

                    '_cmd.Parameters.Refresh()
                    'nvDBUtiles.DBDesconectar(_cmd.ActiveConnection)
                    _rs = New ADODB.Recordset
                    _rs.CursorType = CursorType
                    _rs.LockType = LockType
                    _rs.CursorLocation = CursorLocation
                    _rs.Source = _cmd
                Catch ex As Exception

                End Try

            End Sub

            Public Function Execute(Optional ByVal logEvent As Boolean = True, Optional noDBClose As Boolean = False) As ADODB.Recordset
                Return nvDBUtiles.pvDBCommandRecordset(_db_type, _rs, _cod_cn, logEvent, _nvcn, noDBClose:=noDBClose)
            End Function


            Public ReadOnly Property Parameters As ADODB.Parameters
                Get
                    Return _cmd.Parameters
                End Get
            End Property

            Public Function CreateParameter(ByVal name As String, Optional ByVal DataType As ADODB.DataTypeEnum = ADODB.DataTypeEnum.adEmpty,
                                            Optional ByVal direction As ADODB.ParameterDirectionEnum = ADODB.ParameterDirectionEnum.adParamInput, Optional ByVal size As Integer = 0,
                                            Optional ByVal value As Object = Nothing) As ADODB.Parameter
                Dim res As ADODB.Parameter
                res = _cmd.CreateParameter(name, DataType, direction, size, value)
                Return res
            End Function

            Public Sub addParameter(ByVal name As String, Optional ByVal DataType As ADODB.DataTypeEnum = ADODB.DataTypeEnum.adEmpty,
                                            Optional ByVal direction As ADODB.ParameterDirectionEnum = ADODB.ParameterDirectionEnum.adParamInput, Optional ByVal size As Object = Nothing,
                                            Optional ByVal value As Object = Nothing)
                Try
                    Select Case DataType
                        Case ADODB.DataTypeEnum.adChar, ADODB.DataTypeEnum.adLongVarChar, ADODB.DataTypeEnum.adLongVarWChar, ADODB.DataTypeEnum.adVarChar, ADODB.DataTypeEnum.adVarWChar, ADODB.DataTypeEnum.adWChar, ADODB.DataTypeEnum.adBinary, ADODB.DataTypeEnum.adLongVarBinary, ADODB.DataTypeEnum.adVarBinary
                            Try
                                If (size Is Nothing) Then
                                    size = value.length
                                End If
                            Catch ex As Exception
                                size = 255
                            End Try
                            If size = 0 Then size = 255
                        Case Else
                    End Select
                    Dim param As ADODB.Parameter
                    Try
                        param = _cmd.Parameters(name)
                        param.Size = size
                        param.Direction = direction
                        If DataType <> ADODB.DataTypeEnum.adEmpty Then param.Type = DataType


                    Catch ex As Exception
                        If size Is Nothing Then
                            param = _cmd.CreateParameter(name, DataType, direction)
                        Else
                            param = _cmd.CreateParameter(name, DataType, direction, size)
                        End If

                    End Try

                    If Not value Is Nothing Then
                        If DataType = ADODB.DataTypeEnum.adNumeric Then
                            param.NumericScale = value.ToString().Length
                            param.Precision = 2
                            Try
                                param.Precision = value.ToString().Split(".")(1).Length
                            Catch ex As Exception

                            End Try
                        End If
                        param.Value = value
                    End If
                    Try
                        Dim param2 As ADODB.Parameter = _cmd.Parameters(name)
                    Catch ex As Exception
                        _cmd.Parameters.Append(param)
                    End Try
                Catch ex As Exception
                    'Stop
                End Try
            End Sub

        End Class


    End Class



    Public Class tDBConection
        Public cod_ss_cn As String
        Public cn_string As String
        Public cn_nombre As String
        Public id_cn_tipo As Integer
        Public cn_tipo As String
        Public excaslogin As Boolean
        Public cn_default As Boolean
        Public excasloginuser As String
        Public SSO As Boolean = False
        Public WindowsIdentity As System.Security.Principal.WindowsIdentity
        ''Public scriptOnConnect As String = ""
        Public insertTempOperador As Boolean = False
        Public Sub New()
            cn_string = ""
            cn_nombre = ""
            id_cn_tipo = 0
            cn_tipo = ""
            excaslogin = False
            cn_default = False
            excasloginuser = ""
            cod_ss_cn = ""
        End Sub

        Public Function clone() As tDBConection
            Dim res As New tDBConection
            res.cn_string = cn_string
            res.cod_ss_cn = cod_ss_cn
            res.cn_nombre = cn_nombre
            res.id_cn_tipo = id_cn_tipo
            res.cn_tipo = cn_tipo
            res.excaslogin = excaslogin
            res.cn_default = cn_default
            res.excasloginuser = excasloginuser
            Return res
        End Function
    End Class
End Namespace