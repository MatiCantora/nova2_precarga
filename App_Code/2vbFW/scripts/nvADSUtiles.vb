Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Public Class nvADSUtiles
        ''//La enumeración ADS_AUTHENTICATION_ENUM especifica las opciones de autenticación utilizados 
        ''//en ADSI para unirse a los objetos del ADS
        Const ADS_SECURE_AUTHENTICATION As Long = 1          '//0x1 Las solicitudes de autenticación con seguridad
        Const ADS_USE_ENCRYPTION As Long = 2                 '//0x2 Requiere ADSI para utilizar el cifrado para el intercambio de datos a través de la red.
        Const ADS_USE_SSL As Long = 2                        '//0x2 El canal se cifra mediante Secure Sockets Layer (SSL). Active Directory requiere que el certificado del servidor se instalará para soportar SSL.
        Const ADS_READONLY_SERVER As Long = 4                '//0x4
        Const ADS_PROMPT_CREDENTIALS As Long = 8             '//0x8
        Const ADS_NO_AUTHENTICATION As Long = 16             '//0x10
        Const ADS_FAST_BIND As Long = 32                     '//0x20
        Const ADS_USE_SIGNING As Long = 64                   '//0x40
        Const ADS_USE_SEALING As Long = 128                  '//0x80
        Const ADS_USE_DELEGATION As Long = 256               '//0x100
        Const ADS_SERVER_BIND As Long = 512                  '//0x200
        Const ADS_NO_REFERRAL_CHASING As Long = 1024         '//0x400
        Const ADS_AUTH_RESERVED As Long = 2147483648         '//0x80000000
        ''//***************************************************************/
        Public Shared ADS_option As Long = ADS_SECURE_AUTHENTICATION + ADS_USE_ENCRYPTION + ADS_USE_SSL

        Public Shared Function UserLogon(ByVal protocolo As String, ByVal dominio As String, ByVal servidor As String, ByVal grupo As String, ByVal UID As String, ByVal PWD As String) As tError
            Dim strADsPath As String
            Dim oADGroup As ActiveDs.IADsGroup
            Dim oADContainer As ActiveDs.IADsContainer
            Dim oADUser As ActiveDs.IADsUser

            Dim err As New tError
            err.numError = 13
            err.titulo = "Error de login"
            err.mensaje = "Usuario o contraseña inválidos"

            If protocolo = "LDAP" Then
                '***********
                '  LDAP
                '***********
                Dim DC As String = nvADSUtiles.LDAP_getDC(dominio)
                'En caso de estar habilitado UserMustChangePasswordAtNextLogon se debe desabilitar para poder validar el usuario
                'Luego se vuelve a habilidat.
                oADUser = getUserByLogin(protocolo, servidor, dominio, UID)

                If oADUser Is Nothing Then
                    Return err
                End If
                If oADUser.IsAccountLocked Then
                    err.mensaje = "La cuenta se encuentra bloqueada."
                    Return err
                End If
                If oADUser.AccountDisabled Then
                    err.mensaje = "La cuenta se encuentra deshabilitada"
                    Return err
                End If

                Dim UserAcountControlToString As String = UserAcountControlFlagsToString(oADUser.userAccountControl)
                Dim MustChangePasswordAtNextLogon As Boolean = UserMustChangePasswordAtNextLogon(oADUser)
                If MustChangePasswordAtNextLogon Then
                    oADUser.Put("pwdLastSet", -1)
                    oADUser.SetInfo()
                End If
                Dim acountDisabled As Boolean = (oADUser.userAccountControl And enumUserAcountControlFlags.ACCOUNTDISABLE) > 0
                Dim userAccountControl As Integer = oADUser.userAccountControl
                If acountDisabled Then
                    oADUser.userAccountControl = oADUser.userAccountControl And (&HFFFFFFFF Xor enumUserAcountControlFlags.ACCOUNTDISABLE)
                    oADUser.SetInfo()
                End If

                Try
                    Dim oADS As Object = GetObject("LDAP:")
                    If UID = "" Or PWD = "" Then 'Cuidado, si no se le da contraseña y el usuario es el mismo que el del contexto pasa igual.
                        err.mensaje = "El usuario o la contraseña están vacios."
                        Return err
                    End If
                    If grupo <> "" Then
                        'Llamar al grupo donde debe estar el usuario
                        'Utilizar las credenciales del usuario que se intenta loguear
                        'En caso de no ser correctas las credenciales da error
                        strADsPath = "LDAP://" + LDAP_getServer(servidor, dominio) + "/CN=" & grupo & ",CN=Users," + DC
                        'valida credenciales
                        oADGroup = oADS.OpenDSObject(strADsPath, UID, PWD, ADS_option)
                    Else
                        'Si no hay grupo solo probamos las credenciales solicitando el grupo users
                        strADsPath = "LDAP://" + LDAP_getServer(servidor, dominio) + "/CN=Users," + DC
                        oADContainer = oADS.OpenDSObject(strADsPath, UID, PWD, ADS_option)
                    End If
                Catch eCom As Runtime.InteropServices.COMException
                    err.mensaje = eCom.Message
                    Return err
                Catch ex As Exception
                    err.mensaje = ex.Message
                    Return err
                End Try
                'Si estaba habilitado MustChangePasswordAtNextLogon, volver a habilitarlo
                If MustChangePasswordAtNextLogon Then
                    oADUser.Put("pwdLastSet", 0)
                    oADUser.SetInfo()
                End If
                If acountDisabled Then
                    oADUser.userAccountControl = userAccountControl
                    oADUser.SetInfo()
                    err.mensaje = "La cuenta se encuentra deshabilitada."
                    Return err
                End If

            Else
                '***********
                '  WinNT
                '***********
                'Dim nvLLogon As WindowsLogon
                'Try
                '    nvLLogon = New WindowsLogon
                'Catch ex As Exception
                '    err = New tError
                '    err.numError = 14
                '    err.titulo = "Error de login"
                '    err.mensaje = "Error interno. Consulte al administrador del sistema"
                '    err.debug_desc = "No se puede instanciar el objeto 'WindowsLogon'" & vbCrLf & ex.Message
                '    Return err
                'End Try

                If nvWindowsLogon.Logon(UID, PWD, servidor) Then
                    If grupo <> "" Then
                        strADsPath = "WinNT://" & servidor & "/" & grupo & ",Group"
                        oADGroup = GetObject(strADsPath)
                    End If
                Else
                    Return err
                End If
            End If

            Dim retVal As Boolean
            oADUser = getUserByLogin(protocolo, servidor, dominio, UID)
            If UserMustChangePasswordAtNextLogon(oADUser) Then
                err = New tError
                err.numError = 11
                err.mensaje = "Su contraseña ha caducado. Debe cambiarla para poder continuar."
                Return err
            End If

            If grupo <> "" Then
                retVal = oADGroup.IsMember(oADUser.ADsPath)
                If Not retVal Then
                    err = New tError
                    err.numError = 15
                    err.titulo = "Error de login"
                    err.mensaje = "El usuario no se encuentra dentro del grupo de usuarios habilitados"
                    Return err
                End If
            End If
            err = New tError
            err.numError = 0
            err.titulo = "Login OK"
            Return err
        End Function
        Public Shared Function LDAP_getServer(ByVal servidor As String, ByVal dominio As String) As String
            If dominio <> "" And servidor <> "" Then
                Return servidor & "." & dominio
            End If

            If dominio = "" And servidor <> "" Then
                Return servidor
            End If

            If dominio <> "" And servidor = "" Then
                Return dominio
            End If

            Return ""
        End Function

        Public Shared Function UserChangePassword(ByVal protocolo As String, ByVal dominio As String, ByVal servidor As String, ByVal grupo As String, ByVal UID As String, ByVal PWD As String, ByVal newPWD As String) As tError
            Dim oADUser As ActiveDs.IADsUser
            Dim msg As String = ""
            Try
                oADUser = getUserByLogin(protocolo, servidor, dominio, UID)
                oADUser.ChangePassword(PWD, newPWD)

            Catch ex2 As Runtime.InteropServices.COMException
                msg = ex2.Message
            Catch ex As Exception
                '    When Err.Number = -2147022651
                '    msg = "Error al intentear cambiar la contraseña. La nueva contrasena no cumple alguna de las politicas de complejidad definidas"
                'Catch
                '    msg = "Error al intentear cambiar la contraseña"
                msg = "Error al intentear cambiar la contraseña"
            End Try

            Dim errRet As New tError
            If msg <> "" Then
                errRet.numError = 16
                errRet.mensaje = msg
            End If

            Return errRet
        End Function
        Public Shared Function UserSetPassword(ByVal protocolo As String, ByVal dominio As String, ByVal servidor As String, ByVal grupo As String, ByVal UID As String, ByVal newPWD As String) As tError
            Dim Err As New tError
            Dim oADUser As ActiveDs.IADsUser
            Dim msg As String = ""
            Try
                oADUser = getUserByLogin(protocolo, servidor, dominio, UID)
                oADUser.SetPassword(newPWD)

            Catch ex2 As Runtime.InteropServices.COMException
                Err.parse_error_script(ex2)
                Err.numError = -99
                Err.titulo = "Error al setear la contraseña"
                Err.mensaje = ex2.Message
                Err.debug_src = "nvADSUtiles.vb::UserSetPassword"
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.numError = -99
                Err.titulo = "Error al setear la contraseña"
                Err.mensaje = "No se pudo realizar la acción solicitada"
                Err.debug_src = "nvADSUtiles.vb::UserSetPassword"
            End Try
            Return Err
        End Function
        Public Shared Function LDAP_getDC(ByVal dominio As String) As String
            Dim ArrDominio() As String
            Dim DC As String
            Dim i As Integer

            ArrDominio = Split(dominio, ".")

            DC = ""
            For i = LBound(ArrDominio) To UBound(ArrDominio)
                If DC = "" Then
                    DC = "DC=" & ArrDominio(i)
                Else
                    DC = DC & ",DC=" & ArrDominio(i)
                End If
            Next


            If DC = "" Then DC = dominio

            Return DC
        End Function

        Public Shared Function getUserByLogin(ByVal protocolo As String, ByVal servidor As String, ByVal dominio As String, ByVal UID As String) As ActiveDs.IADsUser
            If protocolo = "LDAP" Then
                'Return LDAP_getUserByLoginADSI(servidor, dominio, UID)
                Return LDAP_getUserByLoginADO(servidor, dominio, UID)
            Else
                Return WinNT_getUserByLogin(servidor, dominio, UID)
            End If
        End Function

        Public Shared Function WinNT_getUserByLogin(ByVal servidor As String, ByVal dominio As String, ByVal UID As String) As ActiveDs.IADsUser
            Dim oADUser As ActiveDs.IADsUser = Nothing
            Dim strADsPath As String
            Try
                strADsPath = "WinNT://" + servidor + "/" & UID & ",User"
                'recuperar el usuario
                oADUser = GetObject(strADsPath)
            Catch ex As Exception
            End Try

            Return oADUser

        End Function


        Public Shared Function LDAP_getUserByLoginADSI(ByVal servidor As String, ByVal dominio As String, ByVal UID As String) As ActiveDs.IADsUser
            '*******************************************************************************
            'Esta funcion no se utiliza. Es muy lenta. La reemplaza "LDAP_getUserByLoginADO"
            '*******************************************************************************
            Dim DC As String
            Dim oADContainer As ActiveDs.IADsContainer
            Dim oADS As ActiveDs.IADs
            Dim strADsPath As String
            Dim oADUser As ActiveDs.IADsUser

            DC = LDAP_getDC(dominio)
            strADsPath = "LDAP://" + LDAP_getServer(servidor, dominio) + "/CN=Users," + DC
            'recuperar contenedor con todas las entidades
            oADContainer = GetObject(strADsPath)
            'Filtrar para que solo queden los usuarios
            Dim arr(0) As String
            arr(0) = "(objectClass=user)"
            oADContainer.Filter = New String() {"User"}
            'Buscar el usuario que coincida con el login
            For Each oADS In oADContainer
                If oADS.Class = "user" Then
                    oADUser = oADS
                    If LCase(oADUser.sAMAccountName) = LCase(UID) Then

                        'Set oADS2 = GetObject("LDAP:")
                        'Set oADUser2 = oADS2.OpenDSObject(oADUser.ADsPath, "jmolivera", "phantom99", ADS_option)
                        'oADUser2.SetPassword newPWD
                        Return oADUser
                    End If
                End If
            Next
            Return Nothing
        End Function


        Public Shared Function LDAP_getUserByLoginADO(ByVal servidor As String, ByVal dominio As String, ByVal UID As String) As ActiveDs.IADsUser

            Dim ldapFilter, DC As String
            Dim oADUser As ActiveDs.IADsUser
            Dim ado As ADODB.Connection
            Dim objectList As ADODB.Recordset

            DC = LDAP_getDC(dominio)

            Try
                ldapFilter = "(&(samAccountType=805306368)(sAMAccountName=" & UID & "))"
                ado = CreateObject("ADODB.Connection")
                ado.Provider = "ADSDSOObject"
                ado.Open("ADSearch")
                objectList = ado.Execute("<LDAP://" & LDAP_getServer(servidor, dominio) & ">;" & ldapFilter &
                                             ";distinguishedName,samAccountName,displayname,userPrincipalName;subtree,ADSPath")

                While Not objectList.EOF
                    If LCase(objectList.Fields("samAccountName").Value) = LCase(UID) Then
                        'oADUser = GetObject(objectList.Fields("ADSPath").Value)
                        'extrar el acepto = System.Text.Encoding.GetEncoding("ISO-8859-8")
                        oADUser = GetObject(System.Text.Encoding.UTF8.GetString(System.Text.Encoding.GetEncoding("ISO-8859-8").GetBytes(objectList.Fields("ADSPath").Value)))
                        Return oADUser
                    End If
                    objectList.MoveNext()
                End While
            Catch ex As Exception

            End Try

            Return Nothing
        End Function

        Public Shared Function LDAP_getoADGroupByGroupADO(ByVal servidor As String, ByVal dominio As String, ByVal Optional grupo As String = "*") As ActiveDs.IADsGroup

            Dim ldapFilter, DC As String
            Dim oADGroup As ActiveDs.IADsGroup
            Dim ado As ADODB.Connection
            Dim objectList As ADODB.Recordset

            DC = LDAP_getDC(dominio)

            Try
                ldapFilter = "(&(objectClass=group)(samAccountName=" & grupo & "))"
                ado = CreateObject("ADODB.Connection")
                ado.Provider = "ADSDSOObject"
                ado.Open("ADSearch")
                objectList = ado.Execute("<LDAP://" & LDAP_getServer(servidor, dominio) & ">;" & ldapFilter & ";samAccountName,ADSPath")

                While Not objectList.EOF
                    If LCase(objectList.Fields("samAccountName").Value) = LCase(grupo) Then
                        oADGroup = GetObject(objectList.Fields("ADSPath").Value)
                        Return oADGroup
                    End If
                    objectList.MoveNext()
                End While
            Catch ex As Exception

            End Try

            Return Nothing
        End Function

        Public Shared Function getContainerByClass(ByVal protocolo As String, ByVal servidor As String, ByVal dominio As String, Optional ByVal clase As String = "*") As ActiveDs.IADsContainer
            If protocolo = "LDAP" Then
                Return LDAP_getContainerByClass(servidor, dominio, clase)
            Else
                Return WinNT_getContainerByClass(servidor, dominio, clase)
            End If
        End Function

        Public Shared Function LDAP_getUserByFN(ByVal servidor As String, ByVal dominio As String, ByVal FN As String) As ActiveDs.IADsContainer
            Dim DC As String
            Dim oADContainer As ActiveDs.IADsContainer
            Dim strADsPath As String

            'extrar el acepto = System.Text.Encoding.GetEncoding("ISO-8859-8")
            FN = System.Text.Encoding.UTF8.GetString(System.Text.Encoding.GetEncoding("ISO-8859-8").GetBytes(FN))

            Try
                DC = LDAP_getDC(dominio)
                strADsPath = "LDAP://" + LDAP_getServer(servidor, dominio) + "/CN=" + FN + ",CN=users," + DC
                oADContainer = GetObject(strADsPath)
            Catch ex As Exception
                Return Nothing
            End Try

            Return oADContainer

        End Function

        Public Shared Function WinNT_getUserByFN(ByVal servidor As String, ByVal dominio As String, ByVal FN As String) As ActiveDs.IADsUser

            Dim oADContainer As ActiveDs.IADsContainer
            Dim oADUser As ActiveDs.IADsUser = Nothing
            Dim oADS As ActiveDs.IADs

            Try
                oADContainer = WinNT_getContainerByClass(servidor, "", "user")
                For Each oADS In oADContainer
                    oADUser = oADS
                    If (LCase(oADUser.FullName) = LCase(FN)) Then
                        Return oADUser
                    End If
                Next
            Catch ex As Exception

            End Try

            Return Nothing

        End Function
        Public Shared Function WinNT_getContainerByClass(ByVal servidor As String, ByVal dominio As String, Optional ByVal clase As String = "*") As ActiveDs.IADsContainer
            Dim oADContainer As ActiveDs.IADsContainer
            Dim oADS As ActiveDs.IADs
            Dim strADsPath As String

            Try
                strADsPath = "WinNT://" + servidor
                oADS = GetObject(strADsPath)
                oADContainer = oADS
                Dim arr(0) As String
                If clase <> "*" Then
                    oADContainer.Filter = New String() {clase}
                End If
            Catch ex As Exception

            End Try

            Return oADContainer

        End Function
        Public Shared Function LDAP_getContainerByClass(ByVal servidor As String, ByVal dominio As String, Optional ByVal clase As String = "*") As ActiveDs.IADsContainer
            Dim DC As String
            Dim oADContainer As ActiveDs.IADsContainer
            Dim strADsPath As String

            Try
                DC = LDAP_getDC(dominio)
                strADsPath = "LDAP://" + LDAP_getServer(servidor, dominio) + "/CN=Users," + DC
                oADContainer = GetObject(strADsPath)
                Dim arr(0) As String
                If clase <> "*" Then
                    oADContainer.Filter = New String() {clase}
                End If
            Catch ex As Exception

            End Try

            Return oADContainer

        End Function

        Public Shared Function getUserByFN(ByVal protocolo As String, ByVal servidor As String, ByVal dominio As String, ByVal FN As String) As ActiveDs.IADsUser
            If protocolo = "LDAP" Then
                Return LDAP_getUserByFN(servidor, dominio, FN)
            Else
                Return WinNT_getUserByFN(servidor, dominio, FN)
            End If
        End Function
        Public Shared Function UserMustChangePasswordAtNextLogon(oADUser As ActiveDs.IADsUser) As Boolean
            Dim PasswordLastChanged As Date = New Date(0)
            Try
                PasswordLastChanged = oADUser.PasswordLastChanged
                If (PasswordLastChanged = (New Date(0)) And (oADUser.userAccountControl And 64) = 0) Then
                    Return True
                Else
                    Return False
                End If
            Catch ex As Exception
                Return False
            End Try

        End Function

        Public Shared Function userInGgroup(ByVal UID As String, ByVal protocolo As String, ByVal dominio As String, ByVal servidor As String, ByVal grupo As String) As Boolean
            Dim oUser As ActiveDs.IADsUser = getUserByLogin(protocolo, servidor, dominio, UID)
            Return userInGgroup(oUser, protocolo, dominio, servidor, grupo)
        End Function

        Public Shared Function userInGgroup(ByVal oUser As ActiveDs.IADsUser, ByVal protocolo As String, ByVal dominio As String, ByVal servidor As String, ByVal grupo As String) As Boolean
            Dim oADGroup As ActiveDs.IADsGroup
            Dim retVal As Boolean = False
            Try
                If protocolo = "LDAP" Then
                    Dim DC As String = nvADSUtiles.LDAP_getDC(dominio)
                    Dim oADS As Object = GetObject("LDAP:")
                    Dim strADsPath = "LDAP://" + LDAP_getServer(servidor, dominio) + "/CN=" & grupo & ",CN=Users," + DC
                    'valida credenciales
                    oADGroup = oADS.OpenDSObject(strADsPath, "", "", ADS_option)
                Else
                    Dim strADsPath As String = "WinNT://" & servidor & "/" & grupo & ",Group"
                    oADGroup = GetObject(strADsPath)
                End If
                retVal = oADGroup.IsMember(oUser.ADsPath)
            Catch ex As Exception

            End Try
            Return retVal
        End Function

        Public Shared Function UserAcountControlFlagsToString(UserAcountControl As Integer) As String
            Dim a As enumUserAcountControlFlags
            Dim values As Array = System.Enum.GetValues(a.GetType())
            Dim names As Array = System.Enum.GetNames(a.GetType())
            Dim strRes As String = ""
            For Each value As enumUserAcountControlFlags In values
                If (UserAcountControl And value) > 0 Then
                    strRes += value.ToString() & vbCrLf
                End If
            Next
            Return strRes
        End Function

        Public Enum enumUserAcountControlFlags
            SCRIPT = 1
            ACCOUNTDISABLE = 2
            HOMEDIR_REQUIRED = 8
            LOCKOUT = 16
            PASSWD_NOTREQD = 32
            PASSWD_CANT_CHANGE = 64
            ENCRYPTED_TEXT_PWD_ALLOWED = 128
            TEMP_DUPLICATE_ACCOUNT = 256
            NORMAL_ACCOUNT = 512
            INTERDOMAIN_TRUST_ACCOUNT = 2048
            WORKSTATION_TRUST_ACCOUNT = 4096
            SERVER_TRUST_ACCOUNT = 8192
            DONT_EXPIRE_PASSWORD = 65536
            MNS_LOGON_ACCOUNT = 131072
            SMARTCARD_REQUIRED = 262144
            TRUSTED_FOR_DELEGATION = 524288
            NOT_DELEGATED = 1048576
            USE_DES_KEY_ONLY = 2097152
            DONT_REQ_PREAUTH = 4194304
            PASSWORD_EXPIRED = 8388608
            TRUSTED_TO_AUTH_FOR_DELEGATION = 16777216
            PARTIAL_SECRETS_ACCOUNT = 67108864
        End Enum

    End Class


End Namespace
