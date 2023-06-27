﻿
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports System
Imports System.Text
Imports System.Runtime.CompilerServices
Imports System.Collections.Generic

Namespace nvFW
    Namespace nvSecurity



        Public Class nvCrytoHMACSHA256


            Public Shared Function create(KeyByte As Byte(), valorBytes As Byte()) As String

                Dim respuesta As String = Nothing
                Try

                    Using Hmacsha256 = New System.Security.Cryptography.HMACSHA256(KeyByte)
                        Dim HashBytes As Byte() = Hmacsha256.ComputeHash(valorBytes)
                        Return BitConverter.ToString(HashBytes).Replace("-", "").ToLower()
                    End Using

                Catch ex As Exception

                End Try

                Return respuesta

            End Function
            Public Shared Function create(secretKey As String, valor As String) As String

                Dim respuesta As String = Nothing
                Try

                    Dim KeyByte As Byte() = nvFW.nvConvertUtiles.StringToBytes(secretKey)
                    Dim valorBytes As Byte() = nvFW.nvConvertUtiles.StringToBytes(valor)

                    Return create(KeyByte, valorBytes)

                Catch ex As Exception

                End Try

                Return respuesta

            End Function


            Public Shared Function verify(signature As String, secretKey As String, valor As Byte()) As Boolean

                Dim res As Boolean = False

                Try
                    Dim secretKeyByte As Byte() = nvFW.nvConvertUtiles.StringToBytes(secretKey)
                    Dim hash As String = create(secretKeyByte, valor)
                    If hash.ToLower = signature.ToLower Then
                        Return True
                    End If

                Catch ex As Exception

                End Try

                Return res

            End Function

        End Class

        Public Class nvCrypto

            Private Shared _enc_key() As Byte = {10, 45, 254, 33, 76, 134, 85, 236, 168, 64}
            Private Shared _enc_IV() As Byte = {25, 54, 165, 225, 198, 56, 37, 99, 84, 233, 38, 79, 68, 45, 198, 244}

            Private Shared _enc_algorithm As System.Security.Cryptography.RijndaelManaged


            Private Shared Function _getEnc_algorithm() As System.Security.Cryptography.RijndaelManaged
                Dim rj As New System.Security.Cryptography.RijndaelManaged 'Rijndael
                rj.Mode = System.Security.Cryptography.CipherMode.CBC
                Return rj
            End Function


            Public Shared Function StrToEncBase64(ByVal cadena As String) As String
                Dim res As String
                If _enc_algorithm Is Nothing Then
                    _enc_algorithm = _getEnc_algorithm()
                End If
                Dim transforma As System.Security.Cryptography.ICryptoTransform
                transforma = _enc_algorithm.CreateEncryptor(_enc_key, _enc_IV)

                Dim memdata As New System.IO.MemoryStream
                Dim encstream As New System.Security.Cryptography.CryptoStream(memdata, transforma, System.Security.Cryptography.CryptoStreamMode.Write)

                Dim plaintext() As Byte
                plaintext = Encoding.ASCII.GetBytes(cadena)
                encstream.Write(plaintext, 0, plaintext.Length)
                encstream.FlushFinalBlock()
                encstream.Close()
                res = Convert.ToBase64String(memdata.ToArray)
                Return res
            End Function


            Public Shared Function EncBase64ToStr(ByVal cadena As String) As String
                Dim res As String
                If _enc_algorithm Is Nothing Then
                    _enc_algorithm = _getEnc_algorithm()
                End If
                Dim transforma As System.Security.Cryptography.ICryptoTransform
                transforma = _enc_algorithm.CreateDecryptor(_enc_key, _enc_IV)

                Dim memdata As New System.IO.MemoryStream
                Dim encstream As New System.Security.Cryptography.CryptoStream(memdata, transforma, System.Security.Cryptography.CryptoStreamMode.Write)
                Dim plaintext() As Byte
                plaintext = Convert.FromBase64String(cadena)
                encstream.Write(plaintext, 0, plaintext.Length)
                encstream.FlushFinalBlock()
                encstream.Close()

                res = Encoding.ASCII.GetString(memdata.ToArray)
                Return res
            End Function



            Private Shared _jsofuscator_HasReadConfig As Boolean = False
            Private Shared _jsofuscator_elements As String
            Private Shared _jsofuscator_library As String
            Private Shared _jsofuscator_Encoding As Integer
            Private Shared _jsofuscator_fastEncode As Boolean
            Private Shared _jsofuscator_specialCars As Boolean

            Private Shared _ECMAScriptPacker As Dean.Edwards.ECMAScriptPacker



            Private Shared Sub _jsofuscator_readConfig()
                If Not _jsofuscator_HasReadConfig Then
                    _jsofuscator_elements = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@elements", "")
                    _jsofuscator_library = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@library", "none")
                    _jsofuscator_Encoding = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@encoding", "0")
                    _jsofuscator_fastEncode = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@fastEncode", "false") = "true"
                    _jsofuscator_specialCars = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@specialCars", "false") = "true"
                    'If HttpContext.Current.IsDebuggingEnabled Then
                    '    _jsofuscator_library = "none"
                    'End If
                End If
                _jsofuscator_HasReadConfig = True
            End Sub


            Public Shared ReadOnly Property jsofuscator_elements As String
                Get
                    _jsofuscator_readConfig()
                    Return _jsofuscator_elements
                End Get
            End Property


            Public Shared ReadOnly Property jsofuscator_library As String
                Get
                    _jsofuscator_readConfig()
                    Return _jsofuscator_library
                End Get
            End Property


            Public Shared ReadOnly Property jsofuscator_Encoding As String
                Get
                    _jsofuscator_readConfig()
                    Return _jsofuscator_Encoding
                End Get
            End Property


            Private Shared Function _splitSTR(strSRC As String) As String
                Dim res As String
                If strSRC.Length > 50 Then
                    Dim mid As Integer = strSRC.Length / 2
                    res = "[" & _splitSTR(strSRC.Substring(mid, strSRC.Length - mid)) & ", " & _splitSTR(strSRC.Substring(0, mid)) & "]"
                Else
                    res = nvConvertUtiles.objectToScriptString(strSRC)
                End If
                Return res
            End Function


            Public Shared Function JSToJSOfuscated(strJS As String, Optional element As String = "all") As String
                If _jsofuscator_library = "" Then
                    _jsofuscator_elements = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@elements", "")
                    _jsofuscator_library = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@library", "none")
                    _jsofuscator_Encoding = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@encoding", "0")
                    _jsofuscator_fastEncode = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@fastEncode", "false") = "true"
                    _jsofuscator_specialCars = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@specialCars", "false") = "true"
                    'If HttpContext.Current.IsDebuggingEnabled Then
                    '    _jsofuscator_library = "none"
                    'End If
                End If

                If _jsofuscator_elements.IndexOf("all") = -1 And _jsofuscator_elements.IndexOf(element) = -1 Then
                    Return strJS
                End If

                Select Case _jsofuscator_library.ToLower

                    Case "ecmascriptpacker"
                        Try
                            If _ECMAScriptPacker Is Nothing Then _ECMAScriptPacker = New Dean.Edwards.ECMAScriptPacker(_jsofuscator_Encoding, _jsofuscator_fastEncode, _jsofuscator_specialCars)
                            strJS = _ECMAScriptPacker.Pack(strJS)
                        Catch ex As Exception
                        End Try


                    Case "yui.compressor"
                        Try
                            Dim _Yui_JavaScriptCompressor As New Yahoo.Yui.Compressor.JavaScriptCompressor
                            _Yui_JavaScriptCompressor.Encoding = System.Text.Encoding.GetEncoding("UTF-8")
                            strJS = _Yui_JavaScriptCompressor.Compress(strJS)
                        Catch ex As Exception
                        End Try


                    Case "nvjsofuscator"
                        Try
                            Dim _Yui_JavaScriptCompressor As New Yahoo.Yui.Compressor.JavaScriptCompressor
                            _Yui_JavaScriptCompressor.Encoding = System.Text.Encoding.GetEncoding("UTF-8")

                            Try
                                strJS = _Yui_JavaScriptCompressor.Compress(strJS)
                            Catch ex As Exception
                            End Try

                            If _jsofuscator_Encoding = 20 Then 'split
                                Dim arCode As String = _splitSTR(strJS)
                                strJS = "(window.execScript||function(data){window['eval'].call( window,data);})((function(ar,init){if (init==undefined) init=true;if(typeof ar==='string'){return ar}else{return arguments.callee(ar[1],false) + arguments.callee(ar[0],false)}})(" & arCode & "))"
                            End If

                            If _jsofuscator_Encoding = 10 Then 'Numeric
                                Try
                                    Dim words_count As New Dictionary(Of String, Integer)
                                    Dim wordOf As New List(Of String)
                                    Dim strReg As String = "\w+"
                                    Dim regExp As New System.Text.RegularExpressions.Regex(strReg)
                                    Dim m As System.Text.RegularExpressions.Match = regExp.Match(strJS)

                                    While m.Success
                                        If m.Groups(0).Value.Length > 3 And Not IsNumeric(m.Groups(0).Value) Then
                                            If Not words_count.Keys.Contains(m.Groups(0).Value) Then
                                                words_count.Add(m.Groups(0).Value, 0)
                                            Else
                                                words_count(m.Groups(0).Value) = words_count(m.Groups(0).Value) + 1
                                            End If
                                        End If
                                        m = m.NextMatch
                                    End While

                                    ' ordenar por largo
                                    Dim words_count2 = words_count.OrderByDescending(Function(item) item.Value)

                                    Dim hasMil As Integer = False
                                    Dim strWords As String = ""
                                    Dim strJSOf As String = strJS
                                    Dim index As Integer = 0

                                    For Each wordItem In words_count2
                                        If index >= 300 Then
                                            hasMil = True
                                            Exit For
                                        End If

                                        strJSOf = strJSOf.Replace(wordItem.Key, "{" & index & "}")
                                        strWords &= wordItem.Key & "|"
                                        index += 1
                                    Next

                                    If strWords <> "" Then strWords = "'" & strWords.Substring(0, strWords.Length - 1) & "'"

                                    Dim strJS2 As String = strJSOf

                                    If hasMil Then
                                        Dim arCode As String = ""
                                        arCode = _splitSTR(strJS2)
                                        strJS = "(window.execScript||function(data){window['eval'].call( window,data);})(function (n,as){for(s=0;s<as.length;s++){var r=new RegExp('\\{'+s+'\\}','gm');n=n.replace(r,as[s])};return n}((function(ar,init){if (init==undefined) init=true;if(typeof ar==='string'){return ar}else{return arguments.callee(ar[1],false) + arguments.callee(ar[0],false)}})(" & arCode & ")," & strWords & ".split('|')))"
                                    Else
                                        strJS2 = nvConvertUtiles.objectToScriptString(strJSOf)
                                        strJS = "(window.execScript||function(data){window['eval'].call( window,data);})(function (n,as){for(s=0;s<as.length;s++){var r=new RegExp('\\{'+s+'\\}','gm');n=n.replace(r,as[s])};return n}(" & strJS2 & "," & strWords & ".split('|')))"
                                    End If
                                Catch ex As Exception
                                    'Stop
                                End Try
                            End If
                        Catch ex As Exception
                            'Stop
                        End Try
                End Select

                Return strJS
            End Function
        End Class



        <Serializable()>
        Public Class tnvOperador
            Private _permissionCache As enumnvPermissionCache
            Private _permisos As New Dictionary(Of String, Integer)
            Private _loginXML As String = "Not Loaded"

            Public operador As Integer
            Public login As String = ""
            Public nombre_operador As String = ""
            Public ads_usuario As String = ""
            Public nro_entidad As Integer
            Public perfiles As New List(Of tnvTipoOperador)
            Public datos As New Dictionary(Of String, tnvOperadorDato)
            Public AutLevel As enumnvAutLevel = enumnvAutLevel.no_logeado
            Public WindowsIdentity As System.Security.Principal.WindowsIdentity = Nothing
            Public WindowsIdentityToken As String
            Public solo_interfaces As Boolean = False
            Public login_method As enumnvLogin_method = enumnvLogin_method.no_logeado

            Public use_credential As Boolean = True
            Public use_clientCertificate As Boolean = False
            Public use_tokenJWT As Boolean = False
            Public restriction_ip As Boolean = False


            Public ReadOnly Property loginXML As String
                Get
                    If _loginXML = "Not Loaded" Then
                        Dim erLogin As nvFW.tError = loadLogin()
                        If erLogin.numError <> 0 Then
                            Me._loginXML = ""
                        Else
                            Me._loginXML = erLogin.params("loginXML")
                        End If
                    End If
                    Return _loginXML
                End Get
            End Property

            Public Sub New()
                Me.New(Nothing)
            End Sub


            Public Sub New(Optional orOpe As nvSecurity.tnvOperador = Nothing)
                Dim str_permissionCache As String = nvServer.getConfigValue("/config/global/nvSecurity/@permissionCache", "False").ToLower
                Dim permissionCache As nvSecurity.enumnvPermissionCache
                If str_permissionCache = "none" Then
                    permissionCache = nvSecurity.enumnvPermissionCache.none
                Else
                    permissionCache = nvSecurity.enumnvPermissionCache.session
                End If
                _permissionCache = permissionCache

                If Not orOpe Is Nothing Then
                    Me.login = orOpe.login
                    Me.nombre_operador = orOpe.nombre_operador
                    Me.nro_entidad = orOpe.nro_entidad
                    Me.operador = orOpe.operador
                    Me.ads_usuario = orOpe.ads_usuario
                    Me.AutLevel = orOpe.AutLevel
                    Me.WindowsIdentity = orOpe.WindowsIdentity
                    Me.WindowsIdentityToken = orOpe.WindowsIdentityToken
                    Me.use_clientCertificate = orOpe.use_clientCertificate
                    Me.use_credential = orOpe.use_credential
                    Me.use_tokenJWT = orOpe.use_tokenJWT
                    Me.login_method = orOpe.login_method
                    Me.restriction_ip = orOpe.restriction_ip
                    Me.solo_interfaces = orOpe.solo_interfaces
                    Me.datos = orOpe.datos
                End If
            End Sub


            'Public ReadOnly Property permiso_grupos As List(Of String)
            '    Get
            '        If _permissionCache = enumnvPermissionCache.none Then
            '            Dim l As New List(Of String)
            '            Dim strSQL As String = "select permiso_grupo from operador_permiso_grupo"
            '            Dim rsP As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
            '            While Not rsP.EOF
            '                l.Add(rsP.Fields("permiso_grupo").Value)
            '                rsP.MoveNext()
            '            End While
            '            nvDBUtiles.DBCloseRecordset(rsP)
            '            Return l
            '        End If
            '        If _permissionCache = enumnvPermissionCache.session Then
            '            If _permisos Is Nothing Then cargarPermisos()
            '            Dim l As New List(Of String)
            '            For Each pg In _permisos.Keys
            '                l.Add(pg)
            '            Next
            '            Return l
            '        End If

            '    End Get
            'End Property

            Public ReadOnly Property permiso_grupo As Dictionary(Of String, Integer)
                Get
                    Return _permisos
                End Get
            End Property
            Public Function permisos(ByVal permiso_grupo As String, Optional fecha As DateTime? = Nothing) As Integer
                If fecha Is Nothing Then fecha = Date.Now()
                Dim permiso As Integer = 0
                'Si está en el diccionario es porque tiene cache activado y ya fué consultado
                If _permisos.Keys.Contains(permiso_grupo) Then
                    permiso = _permisos(permiso_grupo)
                Else
                    'Sino hay que consultarlo
                    Dim strSQL As String = "select op.permiso FROM operadores_operador_tipo oot " &
                                               "INNER JOIN dbo.operador_permiso op On op.tipo_operador = oot.tipo_operador " &
                                               "INNER JOIN dbo.operador_permiso_grupo opg On opg.nro_permiso_grupo = op.nro_permiso_grupo And op.tipo_operador = oot.tipo_operador " &
                                            "where opg.permiso_grupo = ? And oot.operador = ? " &
                                              "And (oot.fe_alta Is null Or ? >= oot.fe_alta) " &
                                              "And (oot.fe_baja Is null Or ? < dateadd(d,1,oot.fe_baja))"

                    Dim cmd As New tnvDBCommand(strSQL)
                    cmd.addParameter("Param1", ADODB.DataTypeEnum.adVarChar, value:=permiso_grupo)
                    cmd.addParameter("Param2", ADODB.DataTypeEnum.adInteger, value:=Me.operador)
                    cmd.addParameter("Param3", ADODB.DataTypeEnum.adDate, value:=fecha)
                    cmd.addParameter("Param4", ADODB.DataTypeEnum.adDate, value:=fecha)

                    Dim rsP As ADODB.Recordset = cmd.Execute()

                    If rsP.eof() Then
                        'Notificar que no existe el permiso
                        Dim errPG As New tError()
                        errPG.numError = 113
                        errPG.titulo = "Advertencia de seguridad"
                        errPG.mensaje = "No existe el grupo de permisos '" & permiso_grupo & "'"
                        errPG.system_reg(Diagnostics.EventLogEntryType.Warning)
                    End If

                    While Not rsP.eof()
                        permiso = permiso Or rsP.Fields("permiso").Value
                        rsP.movenext()
                    End While
                    DBCloseRecordset(rsP)
                    If _permissionCache = enumnvPermissionCache.session Then _permisos(permiso_grupo) = permiso
                End If
                Return permiso

                'permiso_grupo = permiso_grupo.ToLower

                'If _permissionCache = enumnvPermissionCache.none Then
                '    ' Dim strSQL As String = "select dbo.FW_permisos_perfiles('" & permiso_grupo & "') as permiso"
                '    Dim strSQL As String = "select * from verOperador_permiso_grupo where permiso_grupo = '" & permiso_grupo & "'"
                '    Dim rsP As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                '    Try
                '        Return rsP.Fields("permiso").Value
                '    Catch ex As Exception
                '        Return 0
                '    Finally
                '        nvDBUtiles.DBCloseRecordset(rsP)
                '    End Try
                'End If
                'If _permissionCache = enumnvPermissionCache.session Then
                '    If _permisos Is Nothing Then cargarPermisos()
                '    If Not _permisos.Keys.Contains(permiso_grupo) Then Return 0
                '    Return _permisos(permiso_grupo)
                'End If
                'Return 0
            End Function


            Public Sub cargarPermisos(Optional fecha As Date? = Nothing)
                If fecha Is Nothing Then fecha = Date.Now()
                Dim permiso As Integer = 0

                If _permisos Is Nothing Then
                    _permisos = New Dictionary(Of String, Integer)

                    Dim strSQL As String = "select op.permiso, permiso_grupo FROM operadores_operador_tipo oot " &
                                                   "INNER JOIN dbo.operador_permiso op On op.tipo_operador = oot.tipo_operador " &
                                                   "INNER JOIN dbo.operador_permiso_grupo opg On opg.nro_permiso_grupo = op.nro_permiso_grupo And op.tipo_operador = oot.tipo_operador " &
                                                "where oot.operador = ? " &
                                                  "And (oot.fe_alta Is null Or ? >= oot.fe_alta) " &
                                                  "And (oot.fe_baja Is null Or ? < dateadd(d,1,oot.fe_baja)) " &
                                                  "Order by opg.permiso_grupo"

                    Dim cmd As New tnvDBCommand(strSQL)
                    cmd.addParameter("Param1", ADODB.DataTypeEnum.adInteger, value:=Me.operador)
                    cmd.addParameter("Param2", ADODB.DataTypeEnum.adDate, value:=fecha)
                    cmd.addParameter("Param3", ADODB.DataTypeEnum.adDate, value:=fecha)

                    Dim rsP As ADODB.Recordset = cmd.Execute()
                    Dim permiso_grupo As String = ""
                    While Not rsP.eof()
                        If permiso_grupo <> rsP.Fields("permiso_grupo").Value Then
                            If permiso_grupo <> "" Then _permisos(permiso_grupo) = permiso

                            permiso_grupo = rsP.Fields("permiso_grupo").Value
                            permiso = 0
                        End If

                        permiso = permiso Or rsP.Fields("permiso").Value
                        rsP.movenext()
                    End While
                    DBCloseRecordset(rsP)
                End If
            End Sub

            Public Function tienePermiso(ByVal permiso_grupo As String, ByVal nro_permiso As Integer, ByVal fecha As DateTime) As Boolean
                'permiso_grupo = permiso_grupo.ToLower
                Dim permiso As Integer = Me.permisos(permiso_grupo, fecha)

                Dim tieneElPermiso As Boolean = (permiso And (2 ^ (nro_permiso - 1))) <> 0

                If tieneElPermiso Then Return True

                If nvServer.su.contains(Me.login) Then

                    Dim err As New tError()
                    err.numError = 112
                    err.titulo = "Advertencia de seguridad"
                    err.mensaje = "Permiso concedido a  '" & Me.login & "' como super usuario. Permiso '" & permiso_grupo & "', nro_permiso: " & nro_permiso
                    err.system_reg(Diagnostics.EventLogEntryType.Warning)
                    Return True
                End If

                Return False

            End Function
            Public Overridable Function tienePermiso(ByVal permiso_grupo As String, ByVal nro_permiso As Integer) As Boolean

                Return tienePermiso(permiso_grupo, nro_permiso, now())
                'permiso_grupo = permiso_grupo.ToLower
                'If _permissionCache = enumnvPermissionCache.none Then
                '    'Dim strSQL As String = "select dbo.FW_permisos_perfiles('" & permiso_grupo & "') as permiso"
                '    Dim strSQL As String = "select * from verOperador_permiso_grupo where permiso_grupo = '" & permiso_grupo & "'"
                '    Dim rsP As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                '    Try
                '        Return (rsP.Fields("permiso").Value And (2 ^ (nro_permiso - 1))) <> 0
                '        'Return (rsP.Fields("permiso").Value And nro_permiso) <> 0
                '    Catch ex As Exception
                '        Return False
                '    Finally
                '        nvDBUtiles.DBCloseRecordset(rsP)
                '    End Try
                'End If
                'If _permissionCache = enumnvPermissionCache.session Then
                '    If _permisos Is Nothing Then cargarPermisos()
                '    If Not _permisos.Keys.Contains(permiso_grupo) Then Return False
                '    'Return (_permisos(permiso_grupo) And (2 ^ (nro_permiso - 1))) <> 0
                '    Return (_permisos(permiso_grupo) And ((nro_permiso - 1))) <> 0
                'End If
                'Return False
            End Function


            Public Overridable Function save() As tError
                Dim errLogin As tError

                If Me.loginXML <> "" Then
                    errLogin = nvLogin.execute(nvApp.getInstance(), "abm", "", "", "", "", "", Me.loginXML)

                    If errLogin.numError <> 0 Then
                        Return errLogin
                    End If
                End If

                Dim err As New tError
                Dim strXML As String
                Dim ms As New System.IO.MemoryStream
                Dim setting As New System.Xml.XmlWriterSettings
                setting.Encoding = nvConvertUtiles.currentEncoding
                setting.OmitXmlDeclaration = False
                setting.Indent = False

                Dim writer As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(ms, setting)
                With writer
                    .WriteStartDocument()
                    .WriteStartElement("abm_operador")
                    .WriteStartElement("operador")
                    .WriteAttributeString("operador", Me.operador)
                    .WriteAttributeString("nombre_operador", Me.nombre_operador)
                    .WriteAttributeString("login", Me.login)
                    .WriteAttributeString("nro_entidad", Me.nro_entidad)
                    .WriteAttributeString("solo_interfaces", Me.solo_interfaces)

                    .WriteAttributeString("use_credential", Me.use_credential)
                    .WriteAttributeString("use_clientCertificate", Me.use_clientCertificate)
                    .WriteAttributeString("use_tokenJWT", Me.use_tokenJWT)
                    .WriteAttributeString("restriction_ip", Me.restriction_ip)

                    .WriteStartElement("operador_tipos")

                    For Each perfil In perfiles
                        .WriteStartElement("operador_tipo")
                        .WriteAttributeString("tipo_operador", perfil.tipo_operador)
                        .WriteAttributeString("fe_alta", perfil.fe_alta)
                        .WriteAttributeString("fe_baja", nvUtiles.isNUllorEmpty(perfil.fe_baja, ""))
                        .WriteAttributeString("comentario", perfil.comentario)
                        .WriteEndElement()
                    Next

                    .WriteEndElement()
                    .WriteEndElement()
                    .WriteEndDocument()
                End With

                writer.Close()
                ms.Position = 0

                Dim bytes(ms.Length - 1) As Byte
                ms.Read(bytes, 0, ms.Length)
                strXML = nvConvertUtiles.BytesToString(bytes)

                Dim cmd As New nvDBUtiles.tnvDBCommand("fw_operadores_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar,,, strXML)

                Try
                    Dim rs As ADODB.Recordset = cmd.Execute()
                    Me.operador = rs.Fields("operador").Value
                    err.parse_rs(rs)
                    nvDBUtiles.DBCloseRecordset(rs)

                    If err.numError <> 0 Then
                        Return err
                    End If
                Catch ex As Exception
                    err.numError = 12
                    err.parse_error_script(ex)
                    err.titulo = "Error al actualizar el operador"
                    err.mensaje = "No se pudo ejecutar la acción"
                    Return err
                End Try

                'ejecuta el abm login
                'Update de la tabla operador (sin la sucursal)
                'Insert en la operador_tipo_operador
                Return err
            End Function


            Public Function enebleApplication(cod_sistema As String) As Boolean
                If loginXML <> "" Then
                    Dim oXML As New System.Xml.XmlDocument
                    oXML.LoadXml(loginXML)
                    Dim enable As Boolean = nvXMLUtiles.getNodeText(oXML, "criterio/cuenta_habilitada", "false") = "true"
                    Dim acceso_sistema As Boolean = nvXMLUtiles.getAttribute_path(oXML, "criterio/nv_operadores/nv_operador[@cod_sistema='" & cod_sistema & "']/@acceso_sistema", "false") = "true"
                    Return enable And acceso_sistema
                Else
                    Return False
                End If

            End Function

            Public Overridable Function toXML(Optional ByVal omitXmlDeclaration As Boolean = False) As String
                Dim strXML As String
                Dim ms As New System.IO.MemoryStream
                Dim setting As New System.Xml.XmlWriterSettings
                setting.Encoding = nvConvertUtiles.currentEncoding
                'setting.OmitXmlDeclaration = False
                setting.OmitXmlDeclaration = omitXmlDeclaration
                setting.Indent = False

                Dim writer As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(ms, setting)
                With writer
                    .WriteStartDocument()
                    .WriteStartElement("operador")
                    .WriteElementString("operador", Me.operador)
                    .WriteElementString("nombre_operador", Me.nombre_operador)
                    .WriteElementString("nro_entidad", Me.nro_entidad)
                    .WriteElementString("login", Me.login)
                    .WriteElementString("solo_interfaces", Me.solo_interfaces)

                    .WriteElementString("use_credential", Me.use_credential)
                    .WriteElementString("use_clientCertificate", Me.use_clientCertificate)
                    .WriteElementString("use_tokenJWT", Me.use_tokenJWT)
                    .WriteElementString("restriction_ip", Me.restriction_ip)

                    .WriteElementString("loginXML", Me.loginXML)
                    .WriteStartElement("perfiles")
                    For Each perfil In perfiles
                        .WriteStartElement("perfil")
                        .WriteAttributeString("tipo_operador", perfil.tipo_operador)
                        .WriteAttributeString("tipo_operador_desc", perfil.tipo_operador_desc)
                        .WriteAttributeString("fe_alta", perfil.fe_alta)
                        .WriteAttributeString("fe_baja", nvUtiles.isNUllorEmpty(perfil.fe_baja, ""))
                        .WriteAttributeString("comentario", perfil.comentario)
                        .WriteEndElement()
                    Next
                    .WriteEndElement()

                    .WriteStartElement("datos")
                    For Each name In Me.datos.Keys
                        .WriteStartElement("dato")
                        .WriteAttributeString("name", name)
                        .WriteAttributeString("label", Me.datos(name).label)
                        .WriteAttributeString("value", Me.datos(name).value)
                        .WriteAttributeString("campo_def", Me.datos(name).campo_def)
                        .WriteEndElement()
                    Next
                    .WriteEndElement()
                    .WriteEndElement()
                    .WriteEndDocument()
                End With
                writer.Close()

                ms.Position = 0
                Dim bytes(ms.Length - 1) As Byte
                ms.Read(bytes, 0, ms.Length)
                strXML = nvConvertUtiles.BytesToString(bytes)
                ms.Close()

                Return strXML

            End Function

            Public Overridable Function load(login As String) As Boolean
                Me.login = login
                Dim strSQL As String = "Select * from operadores where [login] = '" & login & "'"
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)

                If rs.EOF Then
                    nvDBUtiles.DBCloseRecordset(rs)
                    Return False
                End If

                Dim operador As Integer = rs.Fields("operador").Value
                nvDBUtiles.DBCloseRecordset(rs)
                Return load(operador)
            End Function

            Public Overridable Function load(operador As Integer) As Boolean
                ' Dim strSQL As String = "Select top 1 * from operadores where operador = '" & operador & "'"
                Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute("select o.operador,o.Login " &
                                                                    " ,nombre_operador" &
                                                                    " ,o.nro_entidad" &
                                                                    " ,upper(isNULL(o.login,'') + ' - ' + isNull(e.razon_social,'')) AS descripcion " &
                                                                    " , isnull(e.apellido,'') + ', ' + isNULL(e.nombres,'')   AS strNombreCompleto" &
                                                                    " ,e.apellido,e.nombres,d.documento,e.nro_docu,e.tipo_docu,e.sexo, o.solo_interfaces" &
                                                                    " ,use_credential, use_clientCertificate, use_tokenJWT, restriction_ip" &
                                                                    " From operadores o " &
                                                                    "  Left outer join entidades e on e.nro_entidad = o.nro_entidad" &
                                                                    "  Left outer join documento d on d.tipo_docu = e.tipo_docu" &
                                                                    " where  o.operador = " & operador & "")

                'Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)

                If rs.EOF Then
                    nvDBUtiles.DBCloseRecordset(rs)
                    Return False
                End If


                Me.operador = rs.Fields("operador").Value
                Me.login = rs.Fields("login").Value
                Me.nombre_operador = rs.Fields("nombre_operador").Value
                Me.nro_entidad = nvUtiles.isNUll(rs.Fields("nro_entidad").Value, 0)
                Me.solo_interfaces = nvUtiles.isNUll(rs.Fields("solo_interfaces").Value, False)

                Me.use_credential = nvUtiles.isNUll(rs.Fields("use_credential").Value, False)
                Me.use_clientCertificate = nvUtiles.isNUll(rs.Fields("use_clientCertificate").Value, False)
                Me.use_tokenJWT = nvUtiles.isNUll(rs.Fields("use_tokenJWT").Value, False)
                Me.restriction_ip = nvUtiles.isNUll(rs.Fields("restriction_ip").Value, False)

                nvDBUtiles.DBCloseRecordset(rs)

                'Dim erLogin As nvFW.tError = loadLogin()
                'If erLogin.numError <> 0 Then
                '    Me.loginXML = ""
                'Else
                '    Me.loginXML = erLogin.params("loginXML")
                'End If

                Dim strSQL As String = "SELECT operador, a.tipo_operador, tipo_operador_desc, fe_alta, fe_baja, comentario FROM operadores_operador_tipo a INNER JOIN operador_tipo b ON a.tipo_operador = b.tipo_operador WHERE operador = " & Me.operador
                Dim rsPerfiles As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                While Not rsPerfiles.EOF
                    'Me.addPerfil(rsPerfiles.Fields("tipo_operador").Value, rsPerfiles.Fields("fe_alta").Value, nvUtiles.isNUll(rsPerfiles.Fields("fe_baja").Value, Nothing), rsPerfiles.Fields("comentario").Value)
                    Me.addPerfil(tipo_operador:=rsPerfiles.Fields("tipo_operador").Value, tipo_operador_desc:=rsPerfiles.Fields("tipo_operador_desc").Value, fe_alta:=rsPerfiles.Fields("fe_alta").Value, fe_baja:=nvUtiles.isNUll(rsPerfiles.Fields("fe_baja").Value, Nothing), comentario:=nvUtiles.isNUllorEmpty(rsPerfiles.Fields("comentario").Value, ""))

                    rsPerfiles.MoveNext()
                End While
                Return True
            End Function

            Public Function loadLogin() As tError
                Return nvLogin.execute(nvApp.getInstance(), "getlogin", "", "", "", "", "", "<criterio><login>" & login & "</login></criterio>")
            End Function

            Public Overridable Function loadFromXML(strXML As String) As Boolean
                Dim oXML As New System.Xml.XmlDocument
                Try
                    oXML.LoadXml(strXML)
                Catch ex As Exception
                    Return False
                End Try

                Me.operador = nvXMLUtiles.getNodeText(oXML, "operador/operador", 0)
                Me.nombre_operador = nvXMLUtiles.getNodeText(oXML, "operador/nombre_operador", "")
                Me.nro_entidad = nvXMLUtiles.getNodeText(oXML, "operador/nro_entidad", 0)
                Me.login = nvXMLUtiles.getNodeText(oXML, "operador/login", "")
                Me._loginXML = nvXMLUtiles.getNodeText(oXML, "operador/loginXML", "")
                Me.solo_interfaces = nvXMLUtiles.getNodeText(oXML, "operador/solo_interfaces", "false").ToLower() = "true"

                Me.use_credential = nvXMLUtiles.getNodeText(oXML, "operador/use_credential", "false").ToLower() = "true"
                Me.use_clientCertificate = nvXMLUtiles.getNodeText(oXML, "operador/use_clientCertificate", "false").ToLower() = "true"
                Me.use_tokenJWT = nvXMLUtiles.getNodeText(oXML, "operador/use_tokenJWT", "false").ToLower() = "true"
                Me.restriction_ip = nvXMLUtiles.getNodeText(oXML, "operador/restriction_ip", "false").ToLower() = "true"

                Dim perfiles As System.Xml.XmlNodeList = oXML.SelectNodes("operador/perfiles/perfil")

                For Each perfil As System.Xml.XmlNode In perfiles
                    Me.addPerfil(tipo_operador:=perfil.Attributes("tipo_operador").Value, tipo_operador_desc:=perfil.Attributes("tipo_operador_desc").Value, fe_alta:=perfil.Attributes("fe_alta").Value, fe_baja:=IIf(perfil.Attributes("fe_baja").Value = "", New Date(0), perfil.Attributes("fe_baja").Value), comentario:=nvUtiles.isNUllorEmpty(perfil.Attributes("comentario").Value, ""))
                Next

                Dim datos As System.Xml.XmlNodeList = oXML.SelectNodes("operador/datos/dato")

                For Each node As System.Xml.XmlNode In datos
                    Dim dato As New nvSecurity.tnvOperadorDato
                    dato.name = node.Attributes("name").Value
                    dato.label = node.Attributes("label").Value
                    dato.value = node.Attributes("value").Value
                    dato.campo_def = node.Attributes("campo_def").Value
                    Me.datos.Add(dato.name, dato)
                Next

                Return True

            End Function

            Public Sub addPerfil(tipo_operador As Integer, Optional tipo_operador_desc As String = "", Optional fe_alta As DateTime = Nothing, Optional fe_baja As DateTime = Nothing, Optional comentario As String = "")
                If IsNothing(fe_alta) Then fe_alta = Now()
                Dim p As New tnvTipoOperador
                p.tipo_operador = tipo_operador
                p.tipo_operador_desc = tipo_operador_desc
                p.fe_alta = fe_alta
                p.fe_baja = fe_baja
                p.comentario = comentario
                Me.perfiles.Add(p)
            End Sub

        End Class

        Public Class tnvOperadorDato
            Public name As String
            Public label As String = ""
            Public value As String = ""
            Public campo_def As String = ""
            Public editable As Boolean = True
        End Class
        Public Class tnvTipoOperador
            Public tipo_operador As Integer
            Public tipo_operador_desc As String
            Public fe_alta As Date
            Public fe_baja As Date
            Public comentario As String
        End Class

        Public Enum enumnvPermissionCache
            none = 0
            session = 1
        End Enum

        Public Enum enumnvAutLevel
            no_logeado = -1
            logeado = 0
            autorizado = 1
            autorizado_solo_interfaces = 2
        End Enum

        Public Enum enumnvLogin_method
            no_logeado = -1
            credentials = 0
            tokenJWT = 1
            clientCertificate = 2
            nvhash = 3
        End Enum

        Public Class nvImpersonate

            Shared LOGON32_LOGON_INTERACTIVE As Integer = 2
            Shared LOGON32_LOGON_NETWORK As Integer = 3
            Shared LOGON32_LOGON_BATCH As Integer = 4
            Shared LOGON32_LOGON_SERVICE As Integer = 5
            Shared LOGON32_LOGON_UNLOCK As Integer = 7
            Shared LOGON32_LOGON_NETWORK_CLEARTEXT As Integer = 8
            Shared LOGON32_LOGON_NEW_CREDENTIALS As Integer = 9
            Shared LOGON32_PROVIDER_DEFAULT As Integer = 0

            'Shared impersonationContext As System.Security.Principal.WindowsImpersonationContext

            Declare Function LogonUserA Lib "advapi32.dll" (ByVal lpszUsername As String,
                                    ByVal lpszDomain As String,
                                    ByVal lpszPassword As String,
                                    ByVal dwLogonType As Integer,
                                    ByVal dwLogonProvider As Integer,
                                    ByRef phToken As IntPtr) As Integer

            Declare Auto Function DuplicateToken Lib "advapi32.dll" (
                                    ByVal ExistingTokenHandle As IntPtr,
                                    ByVal ImpersonationLevel As Integer,
                                    ByRef DuplicateTokenHandle As IntPtr) As Integer

            Declare Auto Function RevertToSelf Lib "advapi32.dll" () As Long
            Declare Auto Function CloseHandle Lib "kernel32.dll" (ByVal handle As IntPtr) As Long

            Public Shared Function getWindowsIdentity(ByVal userName As String, ByVal domain As String, ByVal password As String) As System.Security.Principal.WindowsIdentity
                Dim token As IntPtr = IntPtr.Zero
                Dim tokenDuplicate As IntPtr = IntPtr.Zero
                Dim tempWindowsIdentity As System.Security.Principal.WindowsIdentity = Nothing
                Try

                    If password = "" Or userName = "" Then
                        Return tempWindowsIdentity
                    End If

                    If RevertToSelf() Then
                        If LogonUserA(userName, domain, password, LOGON32_LOGON_INTERACTIVE,
                                     LOGON32_PROVIDER_DEFAULT, token) <> 0 Then
                            If DuplicateToken(token, 2, tokenDuplicate) <> 0 Then
                                tempWindowsIdentity = New System.Security.Principal.WindowsIdentity(tokenDuplicate)
                            End If

                        End If
                    End If
                    'If Not tokenDuplicate.Equals(IntPtr.Zero) Then
                    '    CloseHandle(tokenDuplicate)
                    'End If
                    'If Not token.Equals(IntPtr.Zero) Then
                    '    CloseHandle(token)
                    'End If
                Catch ex As Exception
                    'Stop
                End Try
                Return tempWindowsIdentity
            End Function


            Public Shared Function getImpersonationContext(WindowsIdentity As System.Security.Principal.WindowsIdentity) As System.Security.Principal.WindowsImpersonationContext
                Try
                    Dim token As System.IntPtr = CType(WindowsIdentity, System.Security.Principal.WindowsIdentity).Token
                    Dim a As New System.Security.Principal.WindowsIdentity(token)
                    Return a.Impersonate()
                Catch ex As Exception
                    'Stop
                End Try
                Return Nothing
            End Function

        End Class
    End Namespace
End Namespace

