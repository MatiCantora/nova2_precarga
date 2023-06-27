
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Public Class nvLogin

        Public Shared Function execute(ByVal nvApp As tnvApp, ByVal accion As String, ByVal UID As String, ByVal PWD As String, ByVal PWD_OLD As String, ByVal PwdCC As String, ByVal nv_hash As String, ByVal criterio As String) As tError
            Dim retErr As tError
            Dim rs As ADODB.Recordset

            '******************************************************
            ' Delegar la ejecución en caso de ser un login delegado.
            ' El delegado devuelde la variable errq
            '*****************************************************
            If nvApp.ads_login = False AndAlso nvApp.delegate_login <> "" Then
                Try
                    HttpContext.Current.Server.Execute(nvApp.delegate_login)
                Catch ex As Exception
                    Dim err As tError = New tError
                    err.parse_error_script(ex)
                    err.titulo = "Error en login"
                    err.mensaje = "Error en el login delegado"
                    Return err
                End Try
            End If

            ' La enumeración ADS_AUTHENTICATION_ENUM especifica las opciones de autenticación utilizados 
            ' en ADSI para unirse a los objetos del ADS
            '
            ' Const ADS_SECURE_AUTHENTICATION As Long = 1          ' 0x1 Las solicitudes de autenticación con seguridad
            ' Const ADS_USE_ENCRYPTION As Long = 2                 ' 0x2 Requiere ADSI para utilizar el cifrado para el intercambio de datos a través de la red.
            ' Const ADS_USE_SSL As Long = 2                        ' 0x2 El canal se cifra mediante Secure Sockets Layer (SSL). Active Directory requiere que el certificado del servidor se instalará para soportar SSL.
            ' Const ADS_READONLY_SERVER As Long = 4                ' 0x4
            ' Const ADS_PROMPT_CREDENTIALS As Long = 8             ' 0x8
            ' Const ADS_NO_AUTHENTICATION As Long = 16             ' 0x10
            ' Const ADS_FAST_BIND As Long = 32                     ' 0x20
            ' Const ADS_USE_SIGNING As Long = 64                   ' 0x40
            ' Const ADS_USE_SEALING As Long = 128                  ' 0x80
            ' Const ADS_USE_DELEGATION As Long = 256               ' 0x100
            ' Const ADS_SERVER_BIND As Long = 512                  ' 0x200
            ' Const ADS_NO_REFERRAL_CHASING As Long = 1024         ' 0x400
            ' Const ADS_AUTH_RESERVED As Long = 2147483648         ' 0x80000000
            '*******************************************************************

            Select Case accion.ToLower()
                Case "login"
                    '**************************************************************
                    '                NV_HASH
                    '**************************************************************
                    ' Permite transferir el login de una aplicación a otra
                    ' Si nv_hash viene se controla contra la BD si da OK se
                    ' asume que el usuario esta logueado y se direcciona a la 
                    ' pagina que quería entrar
                    '**************************************************************
                    If nv_hash <> "" Then
                        Try
                            retErr = New tError()
                            '*************************************************************
                            'JWT
                            '*************************************************************

                            If nv_hash.Split(".").Length = 3 Then 'JSON WEB TOKEN

                                Dim strJWT As String = nv_hash

                                If nvSession.Contents("_JWT") <> strJWT Then
                                    Dim JWT As New nvSecurity.tnvJWT()
                                    JWT.parse(strJWT)

                                    Dim verifySing As Boolean = JWT.verify()
                                    'Dim verifyUID As Boolean = JWT.payload("sub") = operador.login
                                    Dim app_cod_sistema As String = JWT.payload("aud")
                                    If nvApp.cod_sistema = "" Then
                                        nvFW.nvApp.set_app_from_cod(nvApp, app_cod_sistema)
                                    Else
                                        app_cod_sistema = nvApp.cod_sistema
                                    End If
                                    Dim expired As Boolean = JWT.isExpired()


                                    If verifySing And nvApp.cod_sistema = app_cod_sistema And Not expired Then

                                        nvSession.Contents("_JWT") = strJWT
                                        nvApp.operador.login_method = nvSecurity.enumnvLogin_method.tokenJWT
                                        nvApp.operador.login = JWT.payload("sub")

                                        If nvApp.ads_dominio <> String.Empty Then
                                            nvApp.operador.ads_usuario = nvApp.ads_dominio.Split(".")(0) & "\" & nvApp.operador.login
                                        End If
                                        If nvApp.ads_dc <> String.Empty And nvApp.operador.ads_usuario = String.Empty Then
                                            nvApp.operador.ads_usuario = nvApp.ads_dc & "\" & nvApp.operador.login
                                        End If

                                        nvApp.operador.AutLevel = nvSecurity.enumnvAutLevel.logeado
                                        nvSession.Contents("login") = JWT.payload("sub")               ' Compatibilidad con ASP Classic
                                        nvSession.Contents("ads_usuario") = "" ' Compatibilidad con ASP Classic
                                        retErr.params.Add("app_default", "/" & nvApp.path_rel)
                                        nvLog.addEvent("ss_login_hash", "")
                                        Return retErr
                                    Else
                                        Dim e As tError = New tError
                                        e.numError = 99
                                        e.titulo = "Error en login"
                                        e.mensaje = "Token Inválido"
                                        e.debug_src = "nvLogin::Execute::accion=login"
                                        'e.debug_desc = "hash=" & nv_hash
                                        'nvDBUtiles.DBCloseRecordset(rsHash)
                                        nvLog.addEvent("ss_login_hash_error", UID & ";" & retErr.numError & ";" & "Token Inválido")
                                        Return e
                                    End If

                                End If

                                'Varificar cliente y recurso asignado
                            End If


                            retErr = New tError()
                            ' Conectar a la base de configuraciones
                            UID = ""
                            Dim ads_usuario As String = ""
                            Dim rsHash As ADODB.Recordset

                            Try
                                Dim SQLHash As String = "SELECT * FROM tempdb..nv_login_hash WHERE fe_vencimiento >= getdate() and hash='" & nv_hash & "'"
                                rsHash = nvDBUtiles.ADMDBExecute(SQLHash)
                                UID = rsHash.Fields("UID").Value
                                ads_usuario = rsHash.Fields("ads_usuario").Value
                            Catch ex As Exception
                            Finally
                                nvDBUtiles.DBCloseRecordset(rsHash)
                            End Try

                            If UID = "" Then
                                Dim e As tError = New tError
                                e.numError = 99
                                e.titulo = "Error en login"
                                e.mensaje = "No se encuentra el hash proporcionado"
                                e.debug_src = "nvLogin::Execute::accion=login"
                                e.debug_desc = "hash=" & nv_hash
                                nvLog.addEvent("ss_login_hash_error", UID & ";" & retErr.numError & ";" & "No se encuentra el hash proporcionado")
                                Return e
                            End If

                            Dim strSQL As String = "select * from nv_login where login='" & UID & "' and vigente=1"
                            rs = nvDBUtiles.ADMDBExecute(strSQL)

                            If Not rs.EOF Then
                                nvApp.operador.login_method = nvSecurity.enumnvLogin_method.nvhash
                                nvApp.operador.login = UID
                                nvApp.operador.ads_usuario = ads_usuario
                                nvApp.operador.AutLevel = nvSecurity.enumnvAutLevel.logeado
                                nvSession.Contents("login") = UID               ' Compatibilidad con ASP Classic
                                nvSession.Contents("ads_usuario") = ads_usuario ' Compatibilidad con ASP Classic
                                retErr.params.Add("app_default", "/" & nvApp.path_rel)
                                nvLog.addEvent("ss_login_hash", "")
                            Else
                                Dim e As tError = New tError
                                e.numError = 99
                                e.titulo = "Error en login"
                                e.mensaje = "El usuario no existe o no está activo"
                                e.debug_src = "nvLogin::Execute::accion=login"
                                e.debug_desc = "hash=" & nv_hash
                                nvDBUtiles.DBCloseRecordset(rsHash)
                                nvLog.addEvent("ss_login_hash_error", UID & ";" & retErr.numError & ";" & "El usuario no existe o no está activo")
                                Return e
                            End If

                            nvDBUtiles.DBCloseRecordset(rs)
                        Catch ex As Exception
                            Dim e As tError = New tError
                            e.parse_error_script(ex)
                            e.titulo = "Error en login"
                            e.mensaje = "Error Hash"
                            e.debug_src = "nvLogin::Execute::accion=login"
                            nvDBUtiles.DBCloseRecordset(rs)
                            nvLog.addEvent("ss_login_hash_error", UID & ";" & retErr.numError & ";" & ex.Message.Replace(";", ","))
                            Return e
                        End Try
                    Else
                        '******************************************************
                        ' Controlar esté logueado al sistema
                        ' Si viene un certificado procesarlo
                        '******************************************************
                        If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado AndAlso HttpContext.Current.Request.ClientCertificate.Count > 0 AndAlso Not (UID <> "" AndAlso PWD <> "") Then
                            Dim ClientCertificate As HttpClientCertificate = HttpContext.Current.Request.ClientCertificate
                            Dim strSQLcert As String = "Select * from nv_login_certificates where serialnumber=replace('" & ClientCertificate.SerialNumber & "', '-', '')"
                            Dim rsLogin As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQLcert)

                            While Not rsLogin.EOF
                                Dim bin() As Byte = rsLogin.Fields("cert").Value
                                If bin.SequenceEqual(ClientCertificate.Certificate) Then
                                    UID = rsLogin.Fields("login").Value
                                    nvApp.operador.login_method = nvSecurity.enumnvLogin_method.clientCertificate
                                    retErr = New tError
                                    Exit While
                                End If
                                rsLogin.MoveNext()
                            End While
                            nvDBUtiles.DBCloseRecordset(rsLogin)
                        End If

                        If retErr Is Nothing Then
                            retErr = nvADSUtiles.UserLogon(nvApp.ads_access, nvApp.ads_dominio, nvApp.ads_dc, nvApp.ads_group, UID, PWD)
                            If retErr.numError = 0 Then nvApp.operador.login_method = nvSecurity.enumnvLogin_method.credentials
                        End If

                        If retErr.numError = 0 Then
                            Dim strSQL = "select * from verLogin_servidores where login like '" & UID & "' and acceso_sistema=1 and cod_sistema='" & nvApp.cod_sistema & "' order by acceso_orden"
                            Dim rsAcceso As ADODB.Recordset = nvDBUtiles.ADMDBExecute(strSQL)
                            Dim tiene_acceso As Boolean = Not rsAcceso.EOF
                            nvDBUtiles.DBCloseRecordset(rsAcceso)

                            ' Validar si el usuario debe cambiar la contraseña
                            Dim strSQL2 As String = "select PwdCC from nv_login where login='" & UID & "'"
                            Dim rsPwdCC As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL2)

                            If Not rsPwdCC.EOF Then
                                If rsPwdCC.Fields("PwdCC").Value Then
                                    Dim er As New nvFW.tError()
                                    er.numError = 11
                                    er.mensaje = "Su contraseña ha caducado. Debe cambiarla para poder continuar."
                                    nvDBUtiles.DBCloseRecordset(rsPwdCC)
                                    Return er
                                End If
                            End If

                            nvDBUtiles.DBCloseRecordset(rsPwdCC)

                            If Not tiene_acceso Then
                                retErr = New tError
                                retErr.numError = 1002
                                retErr.titulo = "Error al iniciar la Aplicacion"
                                retErr.mensaje = "El usuario no tiene permisos para acceder a la aplicación"
                            End If

                            If retErr.numError = 0 Then
                                '********************************
                                ' LOGIN OK
                                '********************************
                                nvApp.operador.login = UID
                                nvSession.Contents("login") = UID ' Compatibilidad con ASP Classic
                                nvApp.operador.AutLevel = nvSecurity.enumnvAutLevel.logeado

                                ' Si viene dominio, puede venir "midominio.com.ar" o "midominio" se debe cargar ads_usuario como "midominio\usuario"
                                ' Sino va el nombre del equipo
                                If nvApp.ads_dominio <> "" Then
                                    nvSession.Contents("ads_usuario") = nvApp.ads_dominio.Split(".")(0) & "\" & UID ' Compatibilidad con ASP Classic
                                    nvApp.operador.ads_usuario = nvApp.ads_dominio.Split(".")(0) & "\" & UID
                                Else
                                    nvSession.Contents("ads_usuario") = nvApp.ads_dc & "\" & UID ' Compatibilidad con ASP Classic
                                    nvApp.operador.ads_usuario = nvApp.ads_dc & "\" & UID
                                End If
                            Else
                                nvSession.Contents("ads_usuario") = nvApp.ads_dc & "\" & UID ' Compatibilidad con ASP Classic
                                nvApp.operador.ads_usuario = nvApp.ads_dc & "\" & UID
                            End If

                            retErr.params.Add("app_default", "/" & nvApp.path_rel)
                            nvLog.addEvent("ss_login", "")
                            nvApp.operador.WindowsIdentity = nvSecurity.nvImpersonate.getWindowsIdentity(UID, nvApp.ads_dominio, PWD)
                        Else
                            nvLog.addEvent("ss_login_error", UID & ";" & retErr.numError & ";" & retErr.mensaje.Replace(";", ","))
                        End If
                    End If

                    If HttpContext.Current.Items("hasApi") = True AndAlso HttpContext.Current.Items("save_request") = True Then
                        Try
                            Dim id_api_log = HttpContext.Current.Items("id_API_log")

                            Dim strSQL_api_log As String = "UPDATE API_log SET [login]= '" & UID & "' WHERE id_api_log = " & id_api_log

                            Dim cmdAPILog As New nvDBUtiles.tnvDBCommand(strSQL_api_log, db_type:=emunDBType.db_admin)

                            cmdAPILog.Execute()
                        Catch ex As Exception

                        End Try

                    End If


                    Return retErr

                Case "cerrar"
                    Dim err As tError = New tError

                    Try
                        HttpContext.Current.Session.Abandon()
                    Catch ex As Exception
                        err.numError = 98
                        err.titulo = "Error en cerrar sessión"
                        err.debug_desc = ex.ToString()
                    End Try

                    Return err

                Case "pwd_cambiar"
                    Dim err As tError = nvADSUtiles.UserChangePassword(nvApp.ads_access, nvApp.ads_dominio, nvApp.ads_dc, nvApp.ads_group, UID, PWD_OLD, PWD)

                    If err.numError = 0 Then
                        nvApp.operador.login = UID
                        nvDBUtiles.ADMDBExecute("Update nv_login set PwdCC = 0 where [login] = '" & UID & "'")
                        nvLog.addEvent("ss_pwdchg", UID)
                        nvApp.operador.login = ""
                    End If

                    Return err

                Case "pwd_setear"
                    Dim err As tError = nvADSUtiles.UserSetPassword(nvApp.ads_access, nvApp.ads_dominio, nvApp.ads_dc, nvApp.ads_group, UID, PWD)

                    If err.numError = 0 Then
                        nvLog.addEvent("ss_pwd_set", UID)
                    End If

                    Return err

                Case "pwd_cambiar_cancelar"
                    Dim err As New tError

                    Try
                        UID = nvApp.operador.login
                        Dim strSQL As String = "UPDATE nv_login set PwdCC=0 where login='" & UID & "'"
                        nvDBUtiles.ADMDBExecute(strSQL)
                    Catch ex As Exception
                        err.numError = 97
                        err.titulo = "Error en calcelar cambiar contraseña"
                        err.debug_desc = ex.ToString()
                    End Try

                    Return err

                Case "get_hash"
                    '***********************************************************************************
                    ' Genera un hash de login para poder moverse entre aplicaciones sin pedir el login
                    '***********************************************************************************
                    Dim hash As String = ""

                    For c = 0 To 30
                        hash &= Chr(Rnd() * 25 + 65)
                    Next

                    Dim ads_usuario As String = nvFW.nvApp.getInstance.operador.ads_usuario
                    Dim login As String = nvApp.operador.login
                    Dim SQLhash As String = "if OBJECT_ID(N'tempdb..nv_login_hash', N'U') IS NULL " & vbCrLf
                    SQLhash &= "CREATE TABLE tempdb..nv_login_hash([id_hash] [int] identity(1,1) NOT NULL, [hash] [varchar](255) NOT NULL,[ip_source] [varchar](255) NOT NULL,[uid] [varchar](255) NOT NULL,[fe_hash] [datetime] NOT NULL,[fe_vencimiento] [datetime] NOT NULL,[ads_usuario] [varchar](4000) NOT NULL)" & vbCrLf
                    SQLhash &= "INSERT INTO tempdb..nv_login_hash(hash, ip_source, uid, fe_hash, fe_vencimiento, ads_usuario)"
                    SQLhash &= " VALUES('" & hash & "', '" & nvApp.host_ip & "', '" & login & "'"
                    SQLhash &= ", getdate(), dateadd(minute, 10, getdate()), '" & ads_usuario & "')" & vbCrLf

                    nvDBUtiles.ADMDBExecute(SQLhash)
                    nvDBUtiles.ADMDBExecute("DELETE FROM tempdb..nv_login_hash WHERE fe_vencimiento < getdate()")

                    Dim err As New tError
                    err.numError = 0
                    err.mensaje = ""
                    err.params.Add("hash", hash)
                    nvLog.addEvent("ss_login_getthash", "")

                    Return err

                Case "get_jwt"
                    Dim err As New tError
                    Dim nvTWT As New nvFW.nvSecurity.tnvJWT
                    'nvTWT.payload("iss") = "IDS"
                    nvTWT.payload("sub") = nvApp.operador.login
                    nvTWT.payload("aud") = nvApp.cod_sistema
                    Dim strJWT As String = nvTWT.encode()
                    err.params("JWT") = strJWT
                    nvLog.addEvent("ss_login_getthash", "")
                    Return err

                Case "getlogin"
                    Dim err As New tError
                    err.numError = 0
                    err.mensaje = ""

                    Try
                        Dim objXML = New System.Xml.XmlDocument
                        objXML.LoadXml(criterio)

                        Dim _login As String = objXML.SelectSingleNode("criterio/login").InnerText
                        Dim ads_login As Boolean = nvApp.ads_login
                        Dim ads_access As String = nvApp.ads_access
                        Dim ads_dc As String = nvApp.ads_dc
                        Dim ads_dominio As String = nvApp.ads_dominio

                        Dim _cuit As String = ""
                        Dim _nombres As String = ""
                        Dim _apellido As String = ""
                        Dim _fullname As String = ""
                        Dim _cuenta_habilitada As Boolean = False
                        Dim _cuenta_bloqueada As Boolean = False
                        Dim _cuenta_cambiar_pwd As Boolean = False
                        Dim _cuenta_acceso_app As Boolean = False
                        Dim _cuenta_existe As Boolean = False
                        Dim _fe_alta As String = ""
                        Dim _fe_baja As String = ""
                        Dim oADUser = Nothing
                        Dim strXMLComplementarios As String = "<datos_complementarios/>"
                        Dim comentario_grupo As String = ""

                        If ads_login Then
                            oADUser = nvADSUtiles.getUserByLogin(ads_access, ads_dc, ads_dominio, _login)

                            If Not oADUser Is Nothing Then
                                _cuenta_existe = True

                                Try
                                    _cuenta_habilitada = Not oADUser.AccountDisabled And Not oADUser.IsAccountLocked
                                Catch ex As Exception
                                End Try

                                Try
                                    _cuenta_cambiar_pwd = nvADSUtiles.UserMustChangePasswordAtNextLogon(oADUser)
                                Catch ex As Exception
                                End Try

                                Try
                                    _apellido = oADUser.sn
                                Catch ex As Exception
                                End Try
                                Try
                                    _nombres = oADUser.givenname
                                Catch ex As Exception
                                End Try

                                Try
                                    Try
                                        _fullname = oADUser.FullName
                                    Catch ex As Exception
                                        _fullname = oADUser.cn
                                    End Try
                                Catch ex As Exception
                                    _fullname = ""
                                End Try

                                strXMLComplementarios = "<datos_complementarios>"
                                strXMLComplementarios &= "<dato name='fullname' label='Nombre completo' editable='true' valor='" & _fullname & "'></dato>"

                                Try
                                    strXMLComplementarios &= "<dato name='Title' label='Titulo' editable='true'  valor='" & oADUser.Title & "'></dato>"
                                    strXMLComplementarios &= "<dato name='ADsDepartamento' label='Departamento' editable='true'  valor='" & oADUser.Department & "'></dato>"
                                    strXMLComplementarios &= "<dato name='ADsOrganizacion' label='Organización' editable='true'  valor='" & oADUser.company & "'></dato>"
                                    strXMLComplementarios &= "<dato name='Description' label='Descripción' editable='true'  valor='" & oADUser.Description & "'></dato>"
                                Catch ex As Exception
                                End Try

                                strXMLComplementarios &= "<dato name='cuenta_habilitada' label='Cuenta habilitada' editable='false'  valor='" & IIf(Not oADUser.AccountDisabled, "Si", "No") & "'></dato>"
                                strXMLComplementarios &= "<dato name='cuenta_bloqueada' label='Cuenta bloqueada' editable='false'  valor='" & IIf(oADUser.IsAccountLocked, "Si", "No") & "'></dato>"
                                strXMLComplementarios &= "<dato name='cuenta_cambiar_pwd' label='Cambiar contraseña en el siguiente inicio de sesión' editable='false'  valor='" & IIf(_cuenta_cambiar_pwd, "Si", "No") & "'></dato>"
                                strXMLComplementarios &= "</datos_complementarios>"

                                If nvApp.ads_group <> "" Then
                                    If nvADSUtiles.userInGgroup(oADUser, nvApp.ads_access, nvApp.ads_dominio, nvApp.ads_dc, nvApp.ads_group) = False Then
                                        comentario_grupo = " <b style='color:red'>No pertenece al grupo '" & nvApp.ads_group & "'</b>."
                                    End If
                                End If
                            End If
                        End If

                        Dim descripcion As String = "La cuenta "

                        If _cuenta_existe Then
                            descripcion &= "<b>existe</b>. Pertenece a: <b>" & _fullname.ToUpper & "</b>"
                        Else
                            descripcion &= "<b style='color: red;'>no existe</b>"
                        End If

                        descripcion &= comentario_grupo

                        Dim strXMLSistemas As String = "<nv_operadores>"
                        Dim rsSistemas As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset("select distinct " &
                                                                                          " case when nol.[login] = '" & _login & "' then nol.cod_sistema else n.cod_sistema end as cod_sistema " &
                                                                                          ",case when nol.[login] = '" & _login & "' then nol.[login] else '" & _login & "' end as login " &
                                                                                          ",case when nol.[login] = '" & _login & "' then nol.acceso_sistema  else cast(0 as bit) end as acceso_sistema " &
                                                                                          ",case when nol.[login] = '" & _login & "' then nol.acceso_orden  else 1 end as acceso_orden " &
                                                                                          "from nv_sistemas n " &
                                                                                          "left outer join nv_operadores nol on nol.cod_sistema = n.cod_sistema and nol.[login] = '" & _login & "'" &
                                                                                          "order by acceso_orden")

                        While Not rsSistemas.EOF
                            strXMLSistemas &= "<nv_operador cod_sistema='" & rsSistemas.Fields("cod_sistema").Value & "' acceso_sistema='" & rsSistemas.Fields("acceso_sistema").Value.ToString.ToLower & "' acceso_orden='" & rsSistemas.Fields("acceso_orden").Value & "' />"
                            rsSistemas.MoveNext()
                        End While

                        strXMLSistemas &= "</nv_operadores>"
                        rs = nvDBUtiles.ADMDBOpenRecordset("select pwdcc, login, nombres, apellido, vigente, fe_alta, fe_baja from VerNv_login where login='" & _login & "'")

                        If Not rs.EOF Then
                            _nombres = rs.Fields("nombres").Value
                            _apellido = rs.Fields("apellido").Value.ToString
                            _cuenta_cambiar_pwd = IIf(nvUtiles.isNUll(rs.Fields("pwdcc").Value, "false") = "true" OrElse _cuenta_cambiar_pwd = True, True, False)
                            _cuenta_habilitada = IIf(nvUtiles.isNUll(rs.Fields("vigente").Value, "false") = "true" AndAlso _cuenta_habilitada = True, True, False)
                            _cuenta_existe = _cuenta_existe
                            _fe_alta = rs.Fields("fe_alta").Value.ToString
                            _fe_baja = rs.Fields("fe_baja").Value.ToString
                        End If

                        nvDBUtiles.DBCloseRecordset(rs)

                        Dim strXML As String = "<criterio>" &
                                                    "<login>" & _login & "</login>" &
                                                    "<cuenta_existe>" & _cuenta_existe.ToString().ToLower & "</cuenta_existe>" &
                                                    "<pass></pass>" &
                                                    "<nombres>" & _nombres & "</nombres>" &
                                                    "<apellido>" & _apellido & "</apellido>" &
                                                    "<fullname>" & IIf(_fullname <> "", _fullname, _nombres & " " & _apellido) & "</fullname>" &
                                                    "<cuenta_cambiar_pwd>" & _cuenta_cambiar_pwd.ToString().ToLower & "</cuenta_cambiar_pwd>" &
                                                    "<cuenta_habilitada>" & _cuenta_habilitada.ToString.ToLower & "</cuenta_habilitada>" &
                                                    "<fe_baja>" & nvFW.nvConvertUtiles.objectToScript(_fe_baja).Replace("'", "") & "</fe_baja>" &
                                                    "<fe_alta>" & nvFW.nvConvertUtiles.objectToScript(_fe_alta).Replace("'", "") & "</fe_alta>" &
                                                    "<observacion><![CDATA[<p style='margin: 0px;'>" & descripcion & "</p>]]></observacion>" &
                                                    strXMLComplementarios & strXMLSistemas &
                                                    "<forzar>false</forzar>" &
                                                "</criterio>"

                        err.params.Add("loginXML", strXML)
                    Catch ex As Exception
                        err.parse_error_script(ex)
                        err.numError = -99
                        err.titulo = "Consulta login."
                        err.mensaje = "Error al validar login.</br>" & err.debug_desc
                        err.debug_src = "nvLogin.vb::getlogin"
                        err.params.Add("observacion", "Error al validar login. Intente nuevamente.")
                    End Try

                    Return err

                Case "abm"
                    Dim err As New tError()
                    err.numError = 0
                    err.mensaje = ""
                    Dim strLogABM As String = ""
                    Dim objXML = New System.Xml.XmlDocument

                    Try
                        objXML.LoadXml(criterio)

                        Dim abmlogin As String = objXML.SelectSingleNode("criterio/login").InnerText
                        Dim pass As String = nvFW.nvXMLUtiles.getNodeText(objXML, "criterio/pass")
                        Dim nombres As String = nvFW.nvXMLUtiles.getNodeText(objXML, "criterio/nombres")
                        Dim apellido As String = nvFW.nvXMLUtiles.getNodeText(objXML, "criterio/apellido")
                        Dim fullname As String = nvFW.nvXMLUtiles.getNodeText(objXML, "criterio/fullname")
                        Dim cuenta_habilitada As Boolean = nvFW.nvXMLUtiles.getNodeText(objXML, "criterio/cuenta_habilitada") = "true"
                        Dim cuenta_cambiar_pwd As Boolean = nvFW.nvXMLUtiles.getNodeText(objXML, "criterio/cuenta_cambiar_pwd") = "true"
                        Dim forzar As Boolean = nvFW.nvXMLUtiles.getNodeText(objXML, "criterio/forzar").ToLower = "true"

                        If abmlogin = "" Then
                            err.numError = -99
                            err.titulo = "Consultar complemetos."
                            err.mensaje = "El parámetro abmlogin esta vacio."
                            err.debug_src = "nv_login.vb"
                            err.debug_desc = "El parámetro abmlogin esta vacio."
                            Return err
                        End If

                        Dim ads_login As Boolean = nvApp.ads_login
                        Dim ads_access As String = nvApp.ads_access
                        Dim ads_dc As String = nvApp.ads_dc
                        Dim ads_dominio As String = nvApp.ads_dominio

                        ' ABM de login DELEGADO
                        If Not ads_login Then
                            err.numError = -99
                            err.titulo = "Abm de login delegado"
                            err.mensaje = "Error en login Delegado (En desarrollo)"
                            err.debug_src = "nv_login.vb::abm"
                            err.debug_desc = ""
                            Return err
                        End If

                        ' ABM de login ADS
                        If ads_login Then
                            Dim objUserNew As ActiveDs.IADsContainer
                            Dim oADUser As ActiveDs.IADsUser
                            Dim oADUserFN As ActiveDs.IADsUser

                            Try
                                oADUser = nvADSUtiles.getUserByLogin(ads_access, ads_dc, ads_dominio, abmlogin)
                                oADUserFN = nvADSUtiles.getUserByFN(ads_access, ads_dc, ads_dominio, fullname)
                            Catch ex As Exception
                                err.numError = 99
                                err.titulo = "Active Directory"
                                err.mensaje = "Problemas de acceso al active directory"
                                err.debug_src = "nv_login.vb::abm"
                                err.debug_desc = ""
                                Return err
                            End Try

                            If Not IsNothing(oADUserFN) AndAlso Not IsNothing(oADUser) Then
                                If oADUser.Name.ToString.ToLower <> oADUserFN.Name.ToString.ToLower Then
                                    err.numError = -99
                                    err.titulo = "Error en AD"
                                    err.mensaje = "El individuo '" & fullname & "' ya existe."
                                    err.debug_src = "nvLogin.vb::abm"
                                    Return err
                                End If
                            End If

                            If IsNothing(oADUser) Then
                                If Not IsNothing(oADUserFN) Then
                                    oADUserFN = Nothing
                                    err.numError = -99
                                    err.titulo = "Error en AD"
                                    err.mensaje = "El individuo '" & fullname & "' ya existe."
                                    err.debug_src = "nvLogin.vb::abm"
                                    Return err
                                End If

                                objUserNew = nvADSUtiles.getContainerByClass(ads_access, ads_dc, ads_dominio, "")

                                If nvApp.ads_access = "LDAP" Then
                                    oADUser = objUserNew.Create("user", "CN=" & fullname)
                                    oADUser.sAMAccountName = abmlogin
                                    oADUser.userPrincipalName = abmlogin & "@" & nvApp.ads_dominio
                                Else
                                    oADUser = objUserNew.Create("user", abmlogin)
                                End If

                                Try
                                    oADUser.SetInfo()
                                Catch ex As Exception
                                    'ex.HResult = -2147024891 'acceso denegado
                                    err.parse_error_script(ex)
                                    err.numError = 99
                                    err.titulo = "Login ABM"
                                    err.mensaje = "Error al crear el usuario sobre el Active Directory. Acceso denegado."
                                    err.debug_src = "nvLogin.vb::abm"
                                    GoTo guardar_db
                                End Try

                                nvLog.addEvent("ss_login_new", abmlogin)
                            End If

                            If Trim(pass) <> "" Then
                                err = nvLogin.execute(nvApp, "pwd_setear", abmlogin, pass, "", "", "", "")

                                If err.numError <> 0 Then
                                    GoTo guardar_db
                                End If
                            End If

                            ' Deshabilitar cuenta
                            Dim AccountDisabled As Boolean = IIf(cuenta_habilitada OrElse (Not cuenta_habilitada AndAlso oADUser.IsAccountLocked AndAlso Not oADUser.AccountDisabled), False, True)

                            If oADUser.AccountDisabled <> AccountDisabled Then
                                If oADUser.AccountDisabled Then
                                    nvLog.addEvent("ss_login_enabled", abmlogin)
                                Else
                                    nvLog.addEvent("ss_login_disabled", abmlogin)
                                End If
                            End If

                            oADUser.AccountDisabled = AccountDisabled

                            If oADUser.IsAccountLocked AndAlso Not oADUser.AccountDisabled Then
                                oADUser.IsAccountLocked = False
                                nvLog.addEvent("ss_login_enabled", abmlogin)
                            End If

                            Try
                                If cuenta_cambiar_pwd Then
                                    oADUser.Put("pwdLastSet", 0)
                                Else
                                    oADUser.Put("pwdLastSet", -1)
                                End If
                            Catch ex As Exception
                            End Try

                            Dim description As String = nvFW.nvXMLUtiles.getAttribute_path(objXML, "criterio/datos_complementarios/dato[@name='Description']/@valor", "")

                            If (description <> "") Then
                                Try
                                    oADUser.Description = description
                                Catch ex As Exception
                                    Try
                                        oADUser.PutEx(1, "description", 0)
                                    Catch ex1 As Exception
                                    End Try
                                End Try
                            Else
                                Try
                                    oADUser.PutEx(1, "description", 0)
                                Catch ex As Exception
                                End Try
                            End If

                            Dim title As String = nvFW.nvXMLUtiles.getAttribute_path(objXML, "criterio/datos_complementarios/dato[@name='Title']/@valor", "")
                            Dim department As String = nvFW.nvXMLUtiles.getAttribute_path(objXML, "criterio/datos_complementarios/dato[@name='ADsDepartamento']/@valor", "")
                            Dim company As String = nvFW.nvXMLUtiles.getAttribute_path(objXML, "criterio/datos_complementarios/dato[@name='ADsOrganizacion']/@valor", "")
                            fullname = nvFW.nvXMLUtiles.getAttribute_path(objXML, "criterio/datos_complementarios/dato[@name='fullname']/@valor", fullname)

                            If ads_access = "LDAP" Then
                                oADUser.sn = apellido
                                oADUser.givenname = nombres
                                oADUser.FullName = fullname

                                If title <> "" Then
                                    oADUser.Title = title
                                Else
                                    oADUser.PutEx(1, "Title", 0)
                                End If

                                If department <> "" Then
                                    oADUser.Department = department
                                Else
                                    oADUser.PutEx(1, "department", 0)
                                End If

                                If company <> "" Then
                                    oADUser.company = company
                                Else
                                    oADUser.PutEx(1, "company", 0)
                                End If
                            Else
                                oADUser.FullName = fullname
                            End If

                            Try
                                oADUser.SetInfo()
                                strLogABM = "<loginABM><login login='" & abmlogin & "' habilitada='" & (Not AccountDisabled).ToString.ToLower & "' fullname='" & fullname & "' apellido='" & apellido & "' nombres='" & nombres & "' descripcion='" & description & "' titulo='" & title & "' departamento='" & department & "' compania='" & company & "'/></loginABM>"

                                Dim ADSPath As String = ""
                                Dim borrar As Integer = 0
                                Dim oADGroup As ActiveDs.IADsGroup
                                Dim nods As System.Xml.XmlNodeList = objXML.SelectNodes("criterio/datos_complementarios/miembro_de/grupo")

                                For Each nod As System.Xml.XmlNode In nods
                                    ADSPath = nvFW.nvXMLUtiles.getNodeText(nod, "ADSPath", "")
                                    borrar = nvFW.nvXMLUtiles.getAttribute_path(nod, "@borrar", 0)
                                    oADGroup = GetObject(ADSPath)

                                    If oADGroup.IsMember(oADUser.ADsPath) = False Then
                                        oADGroup.Add(oADUser.ADsPath)
                                        oADGroup.SetInfo()
                                    Else
                                        If borrar = 1 Then
                                            oADGroup.Remove(oADUser.ADsPath)
                                            oADGroup.SetInfo()
                                        End If
                                    End If
                                Next

                                nvLog.addEvent("ss_login_abm", strLogABM)
                                forzar = True
                            Catch ex As Exception
                                'ex.HResult = -2147024891 'acceso denegado
                                err.parse_error_script(ex)
                                err.numError = 99
                                err.titulo = "Login ABM"
                                err.mensaje = "Error al editar el usuario sobre el Active Directory. Acceso denegado."
                                err.debug_src = "nvLogin.vb::abm"
                                GoTo guardar_db
                            End Try
                        End If
guardar_db:
                        ' Modulo de Login
                        If forzar = True Then
                            Try
                                Dim cmd As New nvDBUtiles.tnvDBCommand("fw_login_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_admin)
                                cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , criterio)
                                Dim rsCMD As ADODB.Recordset = cmd.Execute
                                err.parse_rs(rsCMD)
                                nvFW.nvDBUtiles.DBCloseRecordset(rsCMD)
                            Catch ex As Exception
                                Throw ex
                            End Try
                        End If
                    Catch ex As Exception
                        err.parse_error_script(ex)
                        err.numError = -99
                        err.titulo = "Login ABM"
                        err.mensaje = "Error al realizar alta o modificación del login."
                        err.debug_src = "nvLogin.vb::abm"
                    End Try

                    Return err
            End Select
        End Function

    End Class
End Namespace
