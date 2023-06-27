Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports System

Namespace nvFW
    Public Class nvApp

        ''' <summary>
        ''' Se utiliza para poder pasar una variable nvAPP cuando se ejecuta en trheads diferentes. Se debe asignar el valor dentro del thread
        ''' </summary>
        ''' <remarks></remarks>
        <ThreadStatic()> Public Shared _nvApp_ThreadStatic As tnvApp
        Public Shared Function getInstance(Optional ByVal _default As tnvApp = Nothing, Optional Session As HttpSessionState = Nothing) As tnvApp

            'Dim nvApp As New tnvApp
            'Try
            '    nvApp = nvSession.Contents("nvApp")
            '    If nvApp Is Nothing Then
            '        nvApp = New tnvApp
            '    End If
            '    Return nvApp
            'Catch ex As Exception
            '    Stop
            'End Try
            'Return nvApp

            Dim nvApp As tnvApp = Nothing

            'Si tiene un nvAPP a nivel de thread
            If _nvApp_ThreadStatic IsNot Nothing Then Return _nvApp_ThreadStatic



            Dim s As System.Web.SessionState.HttpSessionState = nvSession.GetContents(Session)
            If s IsNot Nothing Then nvApp = s("nvApp")

            If nvApp Is Nothing And _default Is Nothing Then
                Try
                    If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session IsNot Nothing Then HttpContext.Current.Session.Abandon()
                    If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Response IsNot Nothing Then HttpContext.Current.Response.End()
                Catch ex As Exception
                End Try
            End If
            If nvApp Is Nothing And Not _default Is Nothing Then
                nvApp = _default
            End If

            Return nvApp

        End Function



        '//Recupera el objeto aplicacion desde el cod_sistema o el path_rel
        Public Shared Sub set_app_from_cod(nvApp As tnvApp, Optional ByVal cod_sistema As String = Nothing, Optional ByVal path_rel As String = Nothing)
            'Dim res As tnvApp = New tnvApp
            Dim strSQL As String
            Dim rs As ADODB.Recordset
            If Not cod_sistema Is Nothing Then
                strSQL = "Select * from verSistemas_servidores where cod_servidor = '" & nvServer.cod_servidor & "' and cod_sistema = '" & cod_sistema & "'"
            Else
                strSQL = "Select * from verSistemas_servidores where cod_servidor = '" & nvServer.cod_servidor & "' and path_rel = '" & path_rel & "'"
            End If
            rs = nvDBUtiles.ADMDBExecute(strSQL)
            If Not rs.EOF Then
                nvApp.path_rel = rs.Fields("path_rel").Value
                nvApp.cod_sistema = rs.Fields("cod_sistema").Value
                'nvApp.cod_servidor = rs.Fields("cod_servidor").Value
                nvApp.sistema = rs.Fields("sistema").Value
                nvApp.cod_sistema_version = IIf(IsDBNull(rs.Fields("cod_sistema_version").Value), 0, rs.Fields("cod_sistema_version").Value)
                nvApp.id_sistema_rol = rs.Fields("id_sistema_rol").Value
                nvApp.delegate_login = rs.Fields("delegate_login").Value
                nvApp.ads_login = rs.Fields("ads_login").Value
                nvApp.ads_dominio = rs.Fields("ads_dominio").Value
                nvApp.ads_dc = rs.Fields("ads_dc").Value
                nvApp.ads_access = rs.Fields("ads_access").Value
                nvApp.ads_group = rs.Fields("ads_grupo").Value
            Else

            End If
            nvDBUtiles.DBCloseRecordset(rs)
        End Sub


        Public Shared Sub set_app_default(nvApp As tnvApp, ByVal login As String)
            'Dim rsServidor As ADODB.Recordset
            Dim rsSistema As ADODB.Recordset
            Dim strSQL As String
            'Dim res As tnvApp = New tnvApp
            Try
                '//Identificar la aplicacción que tiene por defecto y si tiene permiso
                strSQL = "select path_rel, nv_servidor_sistemas.cod_sistema, nv_servidor_sistemas.cod_servidor, sistema, cod_sistema_version, delegate_login, ads_login, ads_dominio, ads_dc, ads_access, ads_grupo " &
                                " from nv_login " &
                                " join nv_operadores on nv_login.login = nv_operadores.Login " &
                                " join nv_servidor_sistemas on nv_operadores.cod_sistema = nv_servidor_sistemas.cod_sistema " &
                                " join nv_sistemas on nv_servidor_sistemas.cod_sistema = nv_sistemas.cod_sistema " &
                                " Join nv_servidor_alias On nv_servidor_sistemas.cod_servidor = nv_servidor_alias.cod_servidor " &
                                " where nv_login.login = '" & login & "' and acceso_sistema = 1 and nv_servidor_alias.servidor_alias = '" & nvApp.server_name & "' " &
                                " order by acceso_orden"

                rsSistema = nvDBUtiles.ADMDBExecute(strSQL)
                nvApp.path_rel = rsSistema.Fields("path_rel").Value
                nvApp.cod_sistema = rsSistema.Fields("cod_sistema").Value
                nvApp.cod_servidor = rsSistema.Fields("cod_servidor").Value
                nvApp.sistema = rsSistema.Fields("sistema").Value
                nvApp.cod_sistema_version = IIf(IsDBNull(rsSistema.Fields("cod_sistema_version").Value), 0, rsSistema.Fields("cod_sistema_version").Value)
                'nvApp.id_sistema = rsSistema.Fields("id_sistema").Value
                nvApp.delegate_login = rsSistema.Fields("delegate_login").Value
                nvApp.ads_login = rsSistema.Fields("ads_login").Value
                nvApp.ads_dominio = rsSistema.Fields("ads_dominio").Value
                nvApp.ads_dc = rsSistema.Fields("ads_dc").Value
                nvApp.ads_access = rsSistema.Fields("ads_access").Value
                nvApp.ads_group = rsSistema.Fields("ads_grupo").Value
                nvDBUtiles.DBCloseRecordset(rsSistema)
            Catch ex As Exception

            End Try
        End Sub


    End Class
    <Serializable()>
    Public Class tnvApp

        Public appState As enumnvAppState = enumnvAppState.not_loaded

        'Public id_sistema As Integer = 0
        Public cod_sistema As String = ""
        Public sistema As String = ""
        Public path_rel As String = ""
        Public delegate_login As String = ""
        Public ads_login As Boolean
        Public ads_dominio As String = ""
        Public ads_dc As String = ""
        Public ads_access As String = ""
        Public ads_group As String = ""
        'Public cod_servidor As String = ""
        Public app_cns As Dictionary(Of String, tDBConection)
        Public app_dirs As Dictionary(Of String, tnvAppDir)
        Public operador As nvFW.nvSecurity.tnvOperador

        Public ports As nvServer.tParPorts = New nvServer.tParPorts

        Public host_ip As String = ""           'Ip del equipo remoto (Browser)
        Public host_name As String = ""         'host remoto (browser)


        Public cod_servidor As String = ""      'Codigo del servidor en Nova
        Public server_name As String = ""       'Nombre del servidor que viene el la URL de llamada
        Public server_path As String = ""       'Path del servidor que viene en la URL de llamada
        Public server_ip As String = ""         'Ip por la que respondio el servidor
        Public server_port As Integer           'Puerto por el que respondió el servidor
        Public server_protocol As String = ""   'Protocolo por el cual respondió el servidor
        Public server_host_http As String = ""  'URL de acceso al servidor por HTTP
        Public server_host_https As String = "" 'URL de acceso al servidor por HTTPS
        'Public server_physical_path As String = "" 'Direccion de red de acceso a la carpeta del servidor

        Public cod_sistema_version As Integer = 0  'Version definida dentro del SICA
        Public sistema_version_estado As Integer = 1 'Estado de la version definida 
        Public id_sistema_rol As Integer = 1 'Rol del sistemas (desarrollo, testing, producción)

        Public sica_control As nvSICA.tResCab
        Public sica_implementacion As nvSICA.tResCab
        'Public sica_control As List(Of nvFW.nvSICA.tResElement) 'Resultado de la ultima evaluación de integridad
        'Public sica_thread As Threading.Thread   'Thread de ejecución del control de integridad

        'Public app_cns_actives As New Dictionary(Of String, ADODB.Connection)

        Private _PKIs As Dictionary(Of String, tnvPKI)

        'Eventos
        'Public Event onSessionEnd()

        Public ReadOnly Property PKIs As Dictionary(Of String, tnvPKI)
            Get
                If _PKIs Is Nothing Then
                    _PKIs = New Dictionary(Of String, tnvPKI)
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from PKI")
                    While Not rs.EOF
                        Dim pki As tnvPKI
                        pki = nvPKIDBUtil.LoadPKIFromDB(rs.Fields("idpki").Value,, nvPKIDBUtil.nveunmloadDBOptions.loadMy & nvPKIDBUtil.nveunmloadDBOptions.loadTrusted)
                        _PKIs.Add(rs.Fields("idpki").Value, pki)
                        rs.MoveNext()
                    End While
                    nvDBUtiles.DBCloseRecordset(rs)
                End If
                Return _PKIs
            End Get
        End Property

        Public Sub New()
            app_cns = New Dictionary(Of String, tDBConection)
            app_dirs = New Dictionary(Of String, tnvAppDir)
            operador = New nvSecurity.tnvOperador
            'If autoCarga Then
            '    Me.server_name = HttpContext.Current.Request.ServerVariables("SERVER_NAME")
            '    Me.server_path = HttpContext.Current.Request.Url.Scheme & "://" & HttpContext.Current.Request.ServerVariables("SERVER_NAME")
            '    Me.server_ip = HttpContext.Current.Request.ServerVariables("LOCAL_ADDR")
            '    Me.server_port = HttpContext.Current.Request.ServerVariables("SERVER_PORT")
            '    Me.server_protocol = HttpContext.Current.Request.Url.Scheme
            '    Me.host_ip = HttpContext.Current.Request.ServerVariables("REMOTE_ADDR")
            '    Me.host_name = HttpContext.Current.Request.ServerVariables("REMOTE_host")


            '    'nvServer.port_http = ports.http
            '    'nvServer.port_https = ports.https


            '    If nvServer.port_https <> 443 Then
            '        Me.server_host_https = "https://" & Me.server_name & ":" & nvServer.port_https
            '        'nvSession.Contents("cfg_host_https") = "https://" & nvSession.Contents("cfg_server_name") & ":" & ports.https
            '    Else
            '        'nvSession.Contents("cfg_host_https") = "https://" & nvSession.Contents("cfg_server_name")
            '        Me.server_host_https = "https://" & Me.server_name
            '    End If
            '    If nvServer.port_http <> 80 Then
            '        'nvSession.Contents("cfg_host_http") = "http://" & nvSession.Contents("cfg_server_name") & ":" & ports.http
            '        Me.server_host_http = "http://" & Me.server_name & ":" & nvServer.port_http
            '    Else
            '        'nvSession.Contents("cfg_host_http") = "http://" & nvSession.Contents("cfg_server_name")
            '        Me.server_host_http = "http://" & Me.server_name
            '    End If
            '    nvSession.Contents("nvApp") = Me
            'End If
        End Sub

        Public Sub loadFromDefinition(Optional _cod_servidor As String = "", Optional _cod_sistema As String = "", Optional _port As Integer = 0)
            If _cod_servidor <> "" Then
                Me.cod_servidor = _cod_servidor
            End If
            If _cod_servidor <> "" Then
                Dim rsAlias As ADODB.Recordset
                rsAlias = nvDBUtiles.ADMDBExecute("Select TOP 1 * from verServidor_ports where cod_servidor = '" & _cod_servidor & "'")
                Me.server_name = rsAlias.Fields("servidor_alias").Value
                nvDBUtiles.DBCloseRecordset(rsAlias)
            End If
            If _cod_sistema <> "" Then
                Me.cod_sistema = _cod_sistema
            End If
            If _port = 0 Then
                _port = Me.ports.http
            End If
            If _port <> 0 Then
                Dim ports As nvServer.tParPorts = nvFW.nvServer.getPorts(_port, Me.server_name)
                Me.ports = ports
                Me.ports.physical_path = ports.physical_path
            End If

            Dim strSQL As String
            If cod_sistema <> "" Then
                strSQL = "select * from nv_servidor_sistemas where cod_servidor = '" & Me.cod_servidor & "' and cod_sistema = '" & cod_sistema & "'"
                Dim rsSrvSis As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
                'Me.cod_sistema = cod_sistema
                Me.ads_dominio = rsSrvSis.Fields("ads_dominio").Value
                Me.ads_dc = rsSrvSis.Fields("ads_dc").Value
                Me.ads_group = rsSrvSis.Fields("ads_grupo").Value
                Me.ads_access = rsSrvSis.Fields("ads_access").Value
                Me.ads_login = rsSrvSis.Fields("ads_login").Value
                Me.delegate_login = rsSrvSis.Fields("delegate_login").Value
                Me.cod_sistema_version = nvUtiles.isNUll(rsSrvSis.Fields("cod_sistema_version").Value, 0)
                nvDBUtiles.DBCloseRecordset(rsSrvSis)
                strSQL = "Select * from nv_sistemas where cod_sistema = '" & cod_sistema & "'"
                Dim rsApp As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
                Me.path_rel = rsApp.Fields("path_rel").Value
                nvDBUtiles.DBCloseRecordset(rsApp)

                Me.loadCNAndDir()
            End If

        End Sub


        Public Sub loadCNAndDir()
            'Cargar conexiones de la aplicación
            Dim strSQL As String = "select *, null as cod_modulo from verNv_servidor_sistema_cn where cod_servidor = '" & Me.cod_servidor & "' and cod_sistema = '" & cod_sistema & "'"
            Dim cns As New Dictionary(Of String, tDBConection)
            Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBExecute(strSQL)

            'Cargar conexiones de los modulos
            Dim strSQL2 As String = <![CDATA[
select cod_servidor, cod_sistema, nv_servidor_sistema_modulo_cn.cod_modulo, nv_servidor_sistema_modulo_cn.cod_cn as cod_ss_cn, excaslogin, cn_string, cn_nombre, nv_modulo_cn.id_cn_tipo, 0 as cn_default, cn_tipo, connectSSO  from nv_servidor_sistema_modulo_cn 
JOIN nv_modulo_cn on nv_servidor_sistema_modulo_cn.cod_modulo = nv_modulo_cn.cod_modulo and nv_servidor_sistema_modulo_cn.cod_cn = nv_modulo_cn.cod_cn
left outer join nv_cn_tipos on nv_modulo_cn.id_cn_tipo = nv_cn_tipos.id_cn_tipo
where cod_servidor = '{cod_servidor}' and cod_sistema = '{cod_sistema}']]>.Value().Replace("{cod_servidor}", cod_servidor).Replace("{cod_sistema}", cod_sistema)
            '                "select * from verNv_servidor_sistema_modulo_cn where cod_servidor = '" & Me.cod_servidor & "' and cod_sistema = '" & cod_sistema & "'"
            Dim rs2 As ADODB.Recordset = nvDBUtiles.ADMDBExecute(strSQL2)

            Dim rsList As New List(Of ADODB.Recordset)
            rsList.Add(rs)
            rsList.Add(rs2)

            For Each rs In rsList
                While Not rs.EOF

                    'key de cn de sistema = cod_ss_cn
                    'key de cn de modulo  = cod_modulo@cod_ss_cn  
                    Dim key As String = IIf(isnull(rs.Fields("cod_modulo").Value, "") <> "", rs.Fields("cod_modulo").Value & "@" & rs.Fields("cod_ss_cn").Value, rs.Fields("cod_ss_cn").Value)
                    cns.Add(key, New tDBConection)
                    cns(key).cod_ss_cn = rs.Fields("cod_ss_cn").Value
                    cns(key).cn_string = nvFW.nvUtiles.ADMReplaceParametroValor(rs.Fields("cn_string").Value) ' Reemplaza parametros de la cadena de conexion con el formato {%param_name%} por su valor
                    cns(key).cn_nombre = rs.Fields("cn_nombre").Value
                    cns(key).id_cn_tipo = rs.Fields("id_cn_tipo").Value
                    cns(key).cn_tipo = rs.Fields("cn_tipo").Value
                    cns(key).excaslogin = rs.Fields("excaslogin").Value
                    cns(key).cn_default = rs.Fields("cn_default").Value
                    cns(key).SSO = rs.Fields("connectSSO").Value

                    If cns(key).excaslogin Then
                        Try
                            cns(key).excasloginuser = IIf(Me.ads_dominio <> String.Empty, Me.operador.ads_usuario, Me.operador.ads_usuario.Split("\")(1))
                        Catch ex As Exception

                        End Try

                    End If

                    If cns(key).SSO Then
                        cns(key).WindowsIdentity = Me.operador.WindowsIdentity
                    End If

                    If rs.Fields("cn_default").Value Then
                        cns.Add("default", cns(key))
                    End If

                    rs.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rs)
            Next

            Me.app_cns = cns


            Dim dirs As New Dictionary(Of String, tnvAppDir)
            strSQL = "select * from nv_servidor_sistema_dir where cod_servidor = '" & Me.cod_servidor & "' and cod_sistema = '" & cod_sistema & "'"
            rs = nvDBUtiles.ADMDBExecute(strSQL)
            While Not rs.EOF
                dirs.Add(rs.Fields("cod_ss_dir").Value, New tnvAppDir)
                dirs(rs.Fields("cod_ss_dir").Value).cod_ss_dir = rs.Fields("cod_ss_dir").Value
                dirs(rs.Fields("cod_ss_dir").Value).path = rs.Fields("path").Value
                rs.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rs)

            strSQL = "select * from nv_servidor_sistema_modulo_dir where cod_servidor = '" & Me.cod_servidor & "' and cod_sistema = '" & cod_sistema & "'"
            rs = nvDBUtiles.ADMDBExecute(strSQL)
            While Not rs.EOF
                dirs.Add(rs.Fields("cod_modulo_dir").Value, New tnvAppDir)
                dirs(rs.Fields("cod_modulo_dir").Value).cod_ss_dir = rs.Fields("cod_modulo_dir").Value
                dirs(rs.Fields("cod_modulo_dir").Value).path = rs.Fields("path").Value
                rs.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rs)
            Me.app_dirs = dirs
        End Sub

        'Public Sub sessionEnd()
        '    RaiseEvent onSessionEnd()
        'End Sub



    End Class

    ''' <summary>
    ''' Define una instancia de carpeta de usuario para el sisstema
    ''' </summary>
    ''' <remarks></remarks>
    Public Class tnvAppDir
        Public cod_ss_dir As String
        Public path As String
    End Class

    Public Enum enumnvAppState
        not_loaded = 0
        loaded = 1
    End Enum

End Namespace
