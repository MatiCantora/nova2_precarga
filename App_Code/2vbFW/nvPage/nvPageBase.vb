Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports System.Collections.Generic
Imports System.Linq

Namespace nvFW
    Namespace nvPages

        'Public Class nvPageGlobal
        '    Public Static pageID_max As Integer = 0
        'End Class


        ''' <summary>
        ''' Clase base de todas las paginas de la aplicación
        ''' </summary>
        ''' <remarks></remarks>
        Public Class nvPageBase
            Inherits System.Web.UI.Page

            'Public operador As nvSecurity.nvOperador

            Private _classname As String = "nvPageDefault"
            Private _app_cod_sistema As String = ""
            Private _app_sistema As String = ""
            Private _app_path_rel As String = ""
            Private _hasSendHeadInit As Boolean = False 'Determina si se ha enviado la información del HeadInit

            Private _operador As nvSecurity.tnvOperador = Nothing

            'Private Shared _pageID_max As Long = 0 'Cuenta la cantidad de paginas generadas

            'Public Shared _pages As Dictionary(Of Integer, String) = New Dictionary(Of Integer, String)

            Public nvApp As tnvApp
            'Public pageID As String = "" 'ID Unico para cada pagina de de esta clase o sus derivadas
            Public contents As trsParam ' Colección de datos de usuario de la pagina, se envirán al cliente si se utiliza el metodo getHeadInit
            Public permiso_grupos As New Dictionary(Of String, Integer)

            Public acceso_solo_interfaces As Boolean = True



            '*************************************************
            'Propiedades
            '*************************************************
            ''' <summary>
            ''' Devuelve el nombre de la clase
            ''' </summary>
            ''' <value></value>
            ''' <returns></returns>
            ''' <remarks></remarks>
            Public ReadOnly Property classname As String
                Get
                    Return _classname
                End Get
            End Property

            Public ReadOnly Property app_cod_sistema As String
                Get
                    Return _app_cod_sistema
                End Get
            End Property

            Public ReadOnly Property app_sistema As String
                Get
                    Return _app_sistema
                End Get
            End Property

            Public ReadOnly Property app_path_rel As String
                Get
                    Return _app_path_rel
                End Get
            End Property

            Public Overridable ReadOnly Property operador As nvSecurity.tnvOperador
                Get
                    Return _operador
                End Get
            End Property

            '*************************************************
            'Metodos
            '*************************************************
            Public Sub setAPP(ByVal app_cod_sistema As String, ByVal app_sistema As String, ByVal app_path_rel As String)
                _app_cod_sistema = app_cod_sistema
                _app_sistema = app_sistema
                _app_path_rel = app_path_rel
            End Sub


            Protected Overridable Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) 'Handles Me.Load
                nvApp = nvFW.nvApp.getInstance
                If nvApp IsNot Nothing Then _operador = nvApp.operador
                '_pageID_max += 1
                'pageID = Session.SessionID & "::" & _pageID_max
                '_pages.Add(pageID, "load - " & Request.Url.ToString)
                'Dim cook As New HttpCookie("nvPageID", Session.SessionID & "::" & pageID)
                'cook.Expires = DateAdd(DateInterval.Minute, 1, Date.Now)
                'Response.Cookies.Add(cook)
                Me.app_acces_control()
                'HttpContext.Current.Response.Expires = 0
            End Sub


            Public Overridable Sub app_acces_control()
                '/***************************************************************************************/
                '//Controlar que no haya habido ningún problema al inicio de la aplicación
                '/***************************************************************************************/
                If Not nvServer.start_error Is Nothing Then
                    Dim err As tError = nvServer.start_error
                    err.response()
                    Exit Sub
                End If

                ''// ***************************************************************************************
                ''// Si no coincice el app_cod_sistema de la pagona conel de la aplicación activa. Salir
                ''// ****************************************************************************************
                'If Me.app_cod_sistema <> nvApp.cod_sistema Then
                '    Dim err2 As New tError
                '    err2.numError = 15
                '    err2.mensaje = "No se puede acceder. Esta página no pertenece a la aplicación activa."
                '    err2.response()
                'End If

                ' // ***************************************************************************************
                '// Si ya está autorizado no hace falta volver a controlar
                '// autorizado = 1
                '// autorizado_solo_interfaces = 2
                '// ***************************************************************************************
                Dim nvAPP_operador As nvFW.nvSecurity.tnvOperador = nvApp.operador
                If nvAPP_operador.AutLevel = nvSecurity.enumnvAutLevel.autorizado AndAlso Me.app_cod_sistema = nvApp.cod_sistema Then
                    Return
                End If


                '/***************************************************************************************/
                '//Controlar que ingrese por el protocolo seguro https si esta configurado de esa manera
                '//En caso contrario mandarlo a la misma URL pero en HTTPS
                '/***************************************************************************************/
                Dim Request As System.Web.HttpRequest = HttpContext.Current.Request
                Dim HTTPS = Request.ServerVariables("HTTPS")
                Dim URL As String
                Dim QueryString As String = ""
                URL = Request.ServerVariables("URL")
                If Request.QueryString.ToString.Length > 0 Then
                    QueryString = Request.QueryString.ToString
                End If

                If nvServer.onlyHTTPS = True And HTTPS.ToLower <> "on" Then
                    Response.Redirect(nvApp.server_host_https & URL & "?" & QueryString)
                End If

                Dim SERVER_NAME As String
                If HTTPS.ToLower = "on" Then
                    SERVER_NAME = nvApp.server_host_https
                Else
                    SERVER_NAME = nvApp.server_host_http
                End If

                '/*********************************************************************/
                '//Si la aplicación ya esta configurada y no coincide con la del objeto
                '//debe llamar de nuevo al nv_login para crear una nueva sesión
                '/*********************************************************************/
                If nvApp.appState = enumnvAppState.loaded And nvApp.cod_sistema <> Me.app_cod_sistema Then
                    URL = SERVER_NAME & "/FW/nvlogin.aspx?URL=" & HttpUtility.UrlEncode(URL & "?" & QueryString) & "&app_cod_sistema=" & Me.app_cod_sistema
                    HttpContext.Current.Response.Redirect(URL)

                End If


                '/****************************************************/
                '//Controlar esté logueado al sistema
                '//Puede no estar logueado y venir un HASH de login
                '//O puede no estar logueado y venir usuario y contraseña
                '//Si no viene ninguno de los anteriores enviarlo a la pantalla de login
                '/****************************************************/
                If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado Then
                    '/****************************************************/
                    '//Controlar esté logueado al sistema
                    '//Si viene un hash procesarlo
                    '/****************************************************/
                    Dim nv_hash As String = ""
                    nv_hash = nvFW.nvUtiles.obtenerValor("nv_hash", "")
                    If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado And nv_hash <> "" Then
                        '*************************************************************
                        'Procesar el hash
                        '*************************************************************
                        If nvApp.cod_sistema = "" Then
                            nvFW.nvApp.set_app_from_cod(nvApp, _app_cod_sistema)
                        End If
                        Dim HashError As tError = nvLogin.execute(nvApp, "login", "", "", "", "", nv_hash, "")
                        If HashError.numError <> 0 Then
                            HashError.response()
                            'HashError.salida_tipo = "adjunto"
                            'HashError.mostrar_error()
                            Exit Sub
                        End If
                    End If


                    '*************************************************************
                    'Procesar JWT
                    '**************************************************************
                    'If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado And Request.Headers("Authorization") <> Nothing Then
                    'If Request.Headers("Authorization") <> Nothing Then

                    '    'If Request.FilePath.ToLower().IndexOf("/ids/ids_client_token.aspx") <> 0 Then

                    '    Dim strAuthorization As String = Request.Headers("Authorization")
                    '    Dim strJWT As String = strAuthorization.Substring(7)

                    '    If nvSession.Contents("_JWT") <> strJWT Then

                    '        Dim LoginError As tError = nvLogin.execute(nvApp, "login", "", "", "", "", strJWT, "")
                    '        If LoginError.numError <> 0 Then
                    '            LoginError.response()
                    '            'LoginError.salida_tipo = "adjunto"
                    '            'LoginError.mostrar_error()
                    '            Exit Sub
                    '        End If
                    '        nvSession.Contents("_JWT") = strJWT
                    '    End If
                    'End If
                    Dim strJWT As String = ""

                    If Request.Headers("Authorization") <> Nothing Then
                        Dim strAuthorization As String = Request.Headers("Authorization")
                        strJWT = strAuthorization.Substring(7)
                    End If

                    If Not Request.Cookies("jwt") Is Nothing And strJWT = "" Then
                        strJWT = Request.Cookies("jwt").Value
                    End If

                    If strJWT <> "" Then
                        nvLog.addEvent("nvsl_login_jwt", "JWT=" & strJWT & ";user_agent=" & Request.UserAgent)
                        If nvSession.Contents("_JWT") <> strJWT Then

                            Dim LoginError As tError = nvLogin.execute(nvApp, "login", "", "", "", "", strJWT, "")
                            If LoginError.numError <> 0 Then
                                LoginError.response()
                                'LoginError.salida_tipo = "adjunto"
                                'LoginError.mostrar_error()
                                Exit Sub
                            End If
                            nvSession.Contents("_JWT") = strJWT
                        End If

                    End If



                    '/****************************************************/
                    '//Controlar esté logueado al sistema
                    '//Si viene un usuario y contraseña procesarlo
                    '/****************************************************/
                    Dim UID As String = nvFW.nvUtiles.obtenerValor("UID", "")
                    Dim PWD As String = nvFW.nvUtiles.obtenerValor("PWD", "")

                    If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado AndAlso app_cod_sistema <> "" AndAlso ((UID <> "" AndAlso PWD <> "") OrElse HttpContext.Current.Request.ClientCertificate.Count > 0 OrElse HttpContext.Current.Items("hasApi") = True) Then
                        'If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado And UID <> "" And PWD <> "" Then
                        If nvApp.cod_sistema = "" Then
                            nvFW.nvApp.set_app_from_cod(nvApp, _app_cod_sistema)
                        End If
                        Dim LoginError As tError = nvLogin.execute(nvApp, "login", UID, PWD, "", "", "", "")
                        If LoginError.numError <> 0 Then
                            LoginError.response()
                            'LoginError.salida_tipo = "adjunto"
                            'LoginError.mostrar_error()
                            Exit Sub
                        End If
                    End If

                    '/****************************************************/
                    '//Controlar esté logueado al sistema
                    '//Si aun no está logueado enviarlo al login
                    '/****************************************************/
                    If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado Then
                        Dim param_app_cod_sistema As String = ""
                        If nvApp.cod_sistema <> _app_cod_sistema Then
                            param_app_cod_sistema = "&app_cod_sistema=" & _app_cod_sistema
                        End If
                        Dim dirURL As String
                        dirURL = SERVER_NAME & "/FW/nvlogin.aspx?URL=" & HttpUtility.UrlEncode(URL & "?" & QueryString) & param_app_cod_sistema

                        HttpContext.Current.Response.Redirect(dirURL)

                        ''Si no está logueado mandarlo al login
                        'If nvApp.operador.login = "" Then
                        '    Dim dirURL As String
                        '    dirURL = SERVER_NAME & "/FW/nvlogin.aspx?URL=" & HttpUtility.UrlEncode(URL) & "&" & QueryString
                        '    HttpContext.Current.Response.Redirect(dirURL)
                        '    Exit Sub
                        'End If
                        ''//Si no coincide la Aplicación activa con de la aplicación 
                        'If nvApp.cod_sistema <> _app_cod_sistema Then
                        '    Dim dirURL As String
                        '    dirURL = SERVER_NAME & "/FW/nvlogin.aspx?URL=" & HttpUtility.UrlEncode(URL) & "&app_cod_sistema=" & _app_cod_sistema & "&" & QueryString
                        '    'URL = SERVER_NAME & "/FW/nvlogin.aspx?URL=" & HttpUtility.UrlEncode(URL) & "&app_cod_sistema=" & _app_cod_sistema & nv_hash
                        '    HttpContext.Current.Response.Redirect(dirURL)
                        '    Exit Sub
                        'End If
                    End If
                Else
                    'Si no está logeado igual verificar el token y si es correcto guardarlo en la session
                    If Request.Headers("Authorization") <> Nothing Then
                        Dim strAuthorization As String = Request.Headers("Authorization")
                        Dim strJWT As String = strAuthorization.Substring(7)
                        If strJWT.Split(".").Length = 3 AndAlso nvSession.Contents("_JWT") <> strJWT Then
                            Dim JWT As New nvSecurity.tnvJWT()
                            JWT.parse(strJWT)
                            Dim app_cod_sistema As String = JWT.payload("aud")
                            nvFW.nvApp.set_app_from_cod(nvApp, app_cod_sistema)
                            Dim verifyRes As tError = JWT.verifyError(, nvApp.cod_sistema)
                            If verifyRes.numError = 0 Then
                                nvSession.Contents("_JWT") = strJWT
                            Else
                                verifyRes.response()
                            End If

                        End If
                    End If
                End If



                '/****************************************************/
                '//Controlar que este configurada la Aplicación actual
                '//Si nvApp.appState = enumnvAppState.not_loaded la palicacion no está configurada 
                '// y nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.logeado el usuario esta logeado
                '//Entonces configurar la aplicación
                '/****************************************************/
                If nvApp.appState = enumnvAppState.not_loaded And nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.logeado Then
                    Dim err As tError = Me.app_config()
                    If err.numError <> 0 Then
                        'err.salida_tipo = IIf(nvFW.nvUtiles.obtenerValor("app_config_return_error", "").ToLower = "true", "estado", "adjunto")
                        'err.mostrar_error()
                        HttpContext.Current.Session.Abandon()
                        err.response()
                        Exit Sub
                    End If
                    'Si la variable app_config_return_error viene en true, significa que no se quiere cargar la pagina.
                    'Sino simplemente cargar la aplicación, es decir que debe devolver el estado de la carga.
                    If nvFW.nvUtiles.obtenerValor("app_config_return_error", "").ToLower = "true" And nvApp.appState = enumnvAppState.loaded Then
                        Dim err2 As New tError
                        err2.response()
                    End If
                End If



                '/*****************************************************************************************************/
                '//Controlar que sea un operador de sistema
                '//Si el usuario es AutLevel es nvSecurity.enumnvAutLevel.autorizado_solo_interfaces no puede acceder
                '//Si el usuario es AutLevel es nvSecurity.enumnvAutLevel.autorizado puede acceder
                '/****************************************************************************************************/

                If nvApp.operador.AutLevel <> nvSecurity.enumnvAutLevel.autorizado And Not (acceso_solo_interfaces = True And nvApp.operador.AutLevel = nvSecurity.enumnvAutLevel.autorizado_solo_interfaces) Then
                    HttpContext.Current.Session.Abandon()
                    Dim err2 As New tError
                    err2.numError = 10
                    err2.mensaje = "El usuario solo puede acceder a interfaces"
                    err2.response()
                End If

                If acceso_solo_interfaces = False AndAlso nvApp.operador.AutLevel <> nvSecurity.enumnvAutLevel.autorizado Then
                    HttpContext.Current.Session.Abandon()
                    Dim err2 As New tError
                    err2.numError = 10
                    err2.mensaje = "No tiene acceso al sistema"
                    err2.response()
                    'HttpContext.Current.Response.Redirect("../../errores_personalizados/error_401_1.html")
                End If


            End Sub

            Public Overridable Function app_config() As tError
                Dim err As New tError
                If nvApp Is Nothing Then nvApp = nvFW.nvApp.getInstance
                Try
                    If nvApp.id_sistema_rol = 3 And Not nvServer.customErrorsEnable Then
                        err.numError = 10
                        err.titulo = "Error al iniciar la Aplicación"
                        err.mensaje = "No puede iniciar una aplicación en rol 'Producción' sino habilita los errores personalizados en web.config"
                        Return err
                    End If

                    Dim login As String = nvApp.operador.login
                    'Cargar conexiones y directorios del sistema
                    nvApp.loadCNAndDir()

                    Dim strSQL = "select * from verLogin_servidores where login like '" & login & "' and acceso_sistema = 1 and cod_sistema = '" & _app_cod_sistema & "' order by acceso_orden"
                    Dim rsAcceso As ADODB.Recordset = nvDBUtiles.ADMDBExecute(strSQL)
                    Dim tiene_acceso As Boolean = Not rsAcceso.EOF
                    nvDBUtiles.DBCloseRecordset(rsAcceso)

                    If Not tiene_acceso Then
                        'nvSession.Contents("AutLevel") = -1
                        err.numError = 1002
                        err.titulo = "Error al iniciar la Aplicación"
                        err.mensaje = "El usuario no tiene permisos para acceder a la aplicación"
                        Return err
                    Else
                        '/***********************************/
                        '// Comprobar fucnionamiento de la base default
                        'Comprobar que la cadena de conexion funciona
                        '/***********************************/
                        Try
                            Dim cn As New ADODB.Connection
                            cn.ConnectionTimeout = 5 'Cuantos segundos espera la conexión
                            cn.Open(nvApp.app_cns("default").cn_string)
                            Dim rsS As ADODB.Recordset = cn.Execute("Select 1")
                            rsS.Close()
                            nvFW.nvDBUtiles.DBDesconectar(cn)
                        Catch ex As Exception
                            err.parse_error_script(ex)
                            err.numError = 10
                            err.titulo = "Error al iniciar la Aplicación"
                            err.mensaje = "No se puede conectar a la base de datos por defecto"
                            err.debug_desc = "App:" & nvApp.cod_sistema & ". " & err.debug_desc
                            err.debug_src = "bvPageBase::app_config"
                            err.system_reg()
                            Return err
                        End Try

                        '/***********************************************************************/
                        '// Cargar información de operador
                        '/***********************************************************************/

                        nvApp.operador.load(login)

                        'Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute("select o.operador,o.Login " &
                        '                                                    " ,nombre_operador" &
                        '                                                    " ,o.nro_entidad" &
                        '                                                    " ,upper(isNULL(o.login,'') + ' - ' + isNull(e.razon_social,'')) AS descripcion " &
                        '                                                    " , isnull(e.apellido,'') + ', ' + isNULL(e.nombres,'')   AS strNombreCompleto" &
                        '                                                    " ,e.apellido,e.nombres,d.documento,e.nro_docu,e.tipo_docu,e.sexo, o.solo_interfaces" &
                        '                                                    " ,use_credential, use_clientCertificate, use_tokenJWT, restriction_ip" &
                        '                                                    " From operadores o " &
                        '                                                    "  Left outer join entidades e on e.nro_entidad = o.nro_entidad" &
                        '                                                    "  Left outer join documento d on d.tipo_docu = e.tipo_docu" &
                        '                                                    " where  login like '" & login & "'")

                        If nvApp.operador.operador = 0 Then
                            'nvDBUtiles.DBCloseRecordset(rs)
                            HttpContext.Current.Session.Abandon()
                            err.numError = 12
                            err.titulo = "Error al iniciar la Aplicación"
                            err.mensaje = "El usuario no existe en la aplicación"
                            Return err
                        End If

                        'Evaluar restrucciones de acceso por método de login
                        'nvApp.operador.use_credential = nvUtiles.isNUllorEmpty(rs.Fields("use_credential").Value, True)
                        'nvApp.operador.use_clientCertificate = nvUtiles.isNUllorEmpty(rs.Fields("use_clientCertificate").Value, False)
                        'nvApp.operador.use_tokenJWT = nvUtiles.isNUllorEmpty(rs.Fields("use_tokenJWT").Value, False)
                        'nvApp.operador.restriction_ip = nvUtiles.isNUllorEmpty(rs.Fields("restriction_ip").Value, False)

                        If nvApp.operador.login_method = nvSecurity.enumnvLogin_method.credentials And Not nvApp.operador.use_credential _
                            Or nvApp.operador.login_method = nvSecurity.enumnvLogin_method.clientCertificate And Not nvApp.operador.use_clientCertificate _
                            Or nvApp.operador.login_method = nvSecurity.enumnvLogin_method.tokenJWT And Not nvApp.operador.use_tokenJWT Then
                            'nvDBUtiles.DBCloseRecordset(rs)
                            HttpContext.Current.Session.Abandon()
                            err.numError = 13
                            err.titulo = "Error al iniciar la Aplicación"
                            err.mensaje = "El usuario no puede utilizar este tipo de validación ('" & [Enum].GetName(GetType(nvSecurity.enumnvLogin_method), nvApp.operador.login_method) & "')"
                            Return err
                        End If

                        'Evaluar restricciones de acceso por IP
                        If nvApp.operador.restriction_ip Then
                            Dim ip As System.Net.IPAddress = System.Net.IPAddress.Parse(nvApp.host_ip)
                            Dim strSQLBlackList As String = "SELECT operador, IP, mask, ip_typeID FROM operador_ip where operador = " & nvApp.operador.operador '.Fields("operador").Value
                            Dim rsIP As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQLBlackList)
                            Dim hasWl As Boolean = False
                            While Not rsIP.EOF
                                Dim ip_typeID As Integer = rsIP.Fields("ip_typeID").Value
                                Dim ip_mask As System.Net.IPAddress = System.Net.IPAddress.Parse(rsIP.Fields("IP").Value)
                                Dim mask As System.Net.IPAddress = System.Net.IPAddress.Parse(rsIP.Fields("mask").Value)
                                'lista negra
                                If ip_typeID = 2 And ((ip_mask.Address And mask.Address) = (ip.Address And mask.Address)) Then
                                    'nvDBUtiles.DBCloseRecordset(rs)
                                    HttpContext.Current.Session.Abandon()
                                    err.numError = 13
                                    err.titulo = "Error al iniciar la Aplicación"
                                    err.mensaje = "La IP se encuentra en una lista negra para este usuario"
                                    Return err
                                End If
                                'Lista blanca
                                If ip_typeID = 1 And ((ip_mask.Address And mask.Address) = (ip.Address And mask.Address)) Then
                                    hasWl = True
                                End If
                                rsIP.MoveNext()
                            End While
                            nvDBUtiles.DBCloseRecordset(rsIP)

                            'Si no se encuentra en ninguna lista blanca
                            If Not hasWl Then
                                '  nvDBUtiles.DBCloseRecordset(rs)
                                HttpContext.Current.Session.Abandon()
                                err.numError = 13
                                err.titulo = "Error al iniciar la Aplicación"
                                err.mensaje = "La IP no se encuentra habilitada para este usuario"
                                Return err
                            End If

                        End If

                        ' nvApp.operador.operador = rs.Fields("operador").Value
                        '  nvApp.operador.nombre_operador = rs.Fields("strNombreCompleto").Value
                        If nvApp.operador.nro_entidad = 0 Then
                            err.numError = 12
                            err.titulo = "Error al iniciar la Aplicación"
                            err.mensaje = "El usuario no tiene entidad asignada"
                            Return err
                        End If

                        'nvSession.Contents("app_cod_sistema") = _app_cod_sistema
                        nvApp.cod_sistema = _app_cod_sistema
                        nvApp.path_rel = _app_path_rel
                        nvApp.sistema = _app_sistema
                        If nvApp.operador.solo_interfaces Then
                            nvApp.operador.AutLevel = nvSecurity.enumnvAutLevel.autorizado_solo_interfaces
                        Else
                            nvApp.operador.AutLevel = nvSecurity.enumnvAutLevel.autorizado
                        End If
                        'nvDBUtiles.DBCloseRecordset(rs)
                        nvApp.appState = enumnvAppState.loaded
                        '************************************************
                        'Compatibilidad con ASP Classic
                        '************************************************
                        nvSession.Contents("AutLevel") = 1 ' //Controla el acceso al sistema
                        nvSession.Contents("NET_path_rel") = _app_path_rel ' //Controla el acceso al sistema
                        nvSession.Contents("NET_app_cod_sistema") = app_cod_sistema ' //Controla el acceso al sistema

                        Return err

                    End If
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error al configurar la aplicación"
                    err.mensaje = "Error desconocido"
                    err.debug_desc = "Class:" & _classname & ". " & err.debug_desc
                    err.debug_src = "nvPageBase::app_config"
                    err.system_reg()
                    Return err
                End Try

            End Function

            'Public Sub app_db_dir_config_old(ByVal cod_sistema As String)

            '    '//Cargar conexiones a DB del sistema
            '    Dim strSQL As String
            '    'Dim nvApp As tnvApp = nvSession.Contents("nvApp")
            '    Dim rs As ADODB.Recordset
            '    Try
            '        strSQL = "select * from verNv_servidor_sistema_cn where cod_servidor = '" & nvApp.server_name & "' and cod_sistema = '" & cod_sistema & "'"
            '        Dim cns As New Dictionary(Of String, tDBConection)
            '        rs = nvDBUtiles.ADMDBExecute(strSQL)

            '        While Not rs.EOF
            '            cns.Add(rs.Fields("cod_ss_cn").Value, New tDBConection)
            '            'cns(rs.Fields("cod_ss_cn").Value).ID = rs.Fields("cod_ss_cn").Value
            '            cns(rs.Fields("cod_ss_cn").Value).cn_string = rs.Fields("cn_string").Value
            '            cns(rs.Fields("cod_ss_cn").Value).cn_nombre = rs.Fields("cn_nombre").Value
            '            cns(rs.Fields("cod_ss_cn").Value).id_cn_tipo = rs.Fields("id_cn_tipo").Value
            '            cns(rs.Fields("cod_ss_cn").Value).cn_tipo = rs.Fields("cn_tipo").Value
            '            cns(rs.Fields("cod_ss_cn").Value).excaslogin = rs.Fields("excaslogin").Value
            '            cns(rs.Fields("cod_ss_cn").Value).cn_default = rs.Fields("cn_default").Value
            '            If cns(rs.Fields("cod_ss_cn").Value).excaslogin Then
            '                cns(rs.Fields("cod_ss_cn").Value).excasloginuser = nvApp.operador.ads_usuario
            '            End If
            '            If rs.Fields("cn_default").Value Then
            '                cns.Add("default", cns(rs.Fields("cod_ss_cn").Value))
            '            End If
            '            rs.MoveNext()
            '        End While
            '        nvDBUtiles.DBCloseRecordset(rs)
            '        'If Not cns.Keys.Contains("default") Then
            '        '    cns.Add("default", New tDBConection)
            '        '    cns("default").cn_string = nvSession.Contents("connection_string")
            '        '    cns("default").cn_nombre = "default"
            '        '    cns("default").id_cn_tipo = "1"
            '        '    cns("default").cn_tipo = "SQL Server"
            '        '    cns("default").excaslogin = True
            '        '    cns("default").excaslogin = True
            '        '    cns("default").cn_default = 1
            '        'End If
            '        nvApp.app_cns = cns
            '    Catch ex As Exception

            '    End Try

            '    '//Cargar las distintas carpetas de datos del sistema
            '    Try
            '        Dim dirs As New Dictionary(Of String, tnvAppDir)
            '        strSQL = "select * from nv_servidor_sistema_dir where cod_servidor = '" & nvApp.server_name & "' and cod_sistema = '" & cod_sistema & "'"
            '        rs = nvDBUtiles.ADMDBExecute(strSQL)
            '        While Not rs.EOF
            '            dirs.Add(rs.Fields("cod_ss_dir").Value, New tnvAppDir)
            '            dirs(rs.Fields("cod_ss_dir").Value).cod_ss_dir = rs.Fields("cod_ss_dir").Value
            '            dirs(rs.Fields("cod_ss_dir").Value).path = rs.Fields("path").Value
            '            rs.MoveNext()
            '        End While
            '        nvDBUtiles.DBCloseRecordset(rs)

            '        strSQL = "select * from nv_servidor_sistema_modulo_dir where cod_servidor = '" & nvApp.server_name & "' and cod_sistema = '" & cod_sistema & "'"
            '        rs = nvDBUtiles.ADMDBExecute(strSQL)
            '        While Not rs.EOF
            '            dirs.Add(rs.Fields("cod_modulo_dir").Value, New tnvAppDir)
            '            dirs(rs.Fields("cod_modulo_dir").Value).cod_ss_dir = rs.Fields("cod_modulo_dir").Value
            '            dirs(rs.Fields("cod_modulo_dir").Value).path = rs.Fields("path").Value
            '            rs.MoveNext()
            '        End While
            '        nvDBUtiles.DBCloseRecordset(rs)

            '        nvApp.app_dirs = dirs
            '    Catch ex As Exception

            '    End Try

            'End Sub

            Public Overridable Function getHeadInit() As String
                Dim includes As New Dictionary(Of String, Boolean)
                Return getHeadInit(includes)
            End Function
            Public Overridable Function getHeadInit(ByRef includes As Dictionary(Of String, Boolean)) As String

                If includes Is Nothing Then
                    includes = New Dictionary(Of String, Boolean)
                End If
                If Not includes.Keys.Contains("permisos") Then includes.Add("permisos", False)
                'If Not includes.Keys.Contains("utiles.js") Then includes.Add("utiles.js", True)
                'If Not includes.Keys.Contains("imagenes_icons.js") Then includes.Add("imagenes_icons.js", True)

                Dim retScript As String = "" '= "<script type='text/javascript' language='javascript' id='nvPageBase_HeadInit' name='nvPageBase_HeadInit'>" & vbCrLf

                retScript += "var obj = window;" & vbCrLf
                retScript += "if (!!nvFW)" & vbCrLf
                retScript += "  obj = nvFW;" & vbCrLf
                'retScript += "obj.nvPageID = '" & pageID & "';" & vbCrLf & vbCrLf

                If contents.Count > 0 Then
                    retScript += "  obj.pageContents = " & contents.toJSON() & ";" & vbCrLf & vbCrLf
                End If


                retScript += "obj.permiso_grupos = {};" & vbCrLf
                    For Each permiso_grupo As String In Me.permiso_grupos.Keys
                        retScript += "obj.permiso_grupos['" & permiso_grupo & "'] = " & Me.permiso_grupos(permiso_grupo) & ";" & vbCrLf
                    Next
                    'For Each permiso_grupo In operador.permiso_grupos
                    '    retScript += "var " & permiso_grupo & " = " & operador.permisos(permiso_grupo) & vbCrLf
                    'Next
                    retScript += vbCrLf



                'var fila = document.getElementById(id);
                'fila.parentNode.removeChild(fila)
                'retScript = nvSecurity.nvCrypto.JSToJSOfuscated(retScript, "head_init")
                retScript = "<script type='text/javascript' language='javascript' id='nvPageBase_HeadInit' name='nvPageBase_HeadInit'>" & vbCrLf & retScript & "</script>" & vbCrLf

                _hasSendHeadInit = True
                Return retScript
            End Function



            Private Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
                contents.clear()
                'If _pages.Keys.Contains(pageID) Then
                '    _pages.Remove(pageID)
                'End If
                'Stop
                '_pages.Add(pageID, "unload - " & Me.ToString)

            End Sub

            Public Sub addPermisoGrupo(permiso_grupo As String)
                Dim op As nvSecurity.tnvOperador = nvApp.operador
                Dim valor As Integer = op.permisos(permiso_grupo)
                Me.permiso_grupos.Remove(permiso_grupo)
                Me.permiso_grupos.Add(permiso_grupo, valor)
            End Sub
            Public Sub New()
                contents = New trsParam
            End Sub
        End Class
    End Namespace
End Namespace
