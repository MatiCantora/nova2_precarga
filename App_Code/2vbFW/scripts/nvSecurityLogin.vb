Imports System.Security.Cryptography
Imports System.Net
Imports System.Runtime.Serialization
Imports System.Runtime.Serialization.Json
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW


    Public Class nvSecurityLogin

        Public Shared Function AltaUsuario(strXML As String, nro_operador As String) As terror

            Dim inputDataLog As String = ""
            Dim err As New tError
            Dim exc As New Exception()

            Try
                Dim nro_docu As String = ""
                Dim tipo_docu As String = ""
                Dim sexo As String = ""
                Dim cuil As String = ""
                Dim nombres As String = ""
                Dim apellido As String = ""
                Dim email As String = ""
                Dim usuario As String = ""
                Dim password As String = ""
                Dim PwdCC As String = ""
                Dim facebook_id As String = ""
                Dim access_token As String = ""
                Dim solo_cliente As String = ""

                Dim oXml As New System.Xml.XmlDocument
                Try
                    oXml.LoadXml(strXML)
                Catch e As Exception
                    exc.Data.Add(-1, "Documento xml de entrada inválido")
                    Throw exc
                End Try

                Dim nodeLogin = oXml.SelectSingleNode("/criterio/login")
                If Not nodeLogin Is Nothing Then
                    nro_docu = nvXMLUtiles.getAttribute_path(nodeLogin, "@nro_docu", "")
                    tipo_docu = nvXMLUtiles.getAttribute_path(nodeLogin, "@tipo_docu", "3")
                    sexo = nvXMLUtiles.getAttribute_path(nodeLogin, "@sexo", "")
                    cuil = nvXMLUtiles.getAttribute_path(nodeLogin, "@cuil", "")
                    nombres = nvXMLUtiles.getAttribute_path(nodeLogin, "@nombres", "")
                    apellido = nvXMLUtiles.getAttribute_path(nodeLogin, "@apellido", "")
                    email = nvXMLUtiles.getAttribute_path(nodeLogin, "@email", "")
                    usuario = nvXMLUtiles.getAttribute_path(nodeLogin, "@usuario", "")
                    password = nvXMLUtiles.getAttribute_path(nodeLogin, "@password", "")
                    PwdCC = nvXMLUtiles.getAttribute_path(nodeLogin, "@PwdCC", "0")
                    facebook_id = nvXMLUtiles.getAttribute_path(nodeLogin, "@facebook_id", "")
                    access_token = nvXMLUtiles.getAttribute_path(nodeLogin, "@access_token", "")
                    solo_cliente = nvXMLUtiles.getAttribute_path(nodeLogin, "@solo_cliente", "0")
                Else
                    exc.Data.Add(-1, "No se ha encontrado el nodo con etiqueta login")
                    Throw exc
                End If

                inputDataLog = "" & nro_docu & ";" & tipo_docu & ";" & sexo & ";" & cuil &
                    ";" & nombres & ";" & apellido & ";" & email & ";" & usuario &
                    ";" & PwdCC & ";" & facebook_id & ";" & solo_cliente

                ' Controlar campos requeridos
                Dim campo As String = ""
                If nro_docu = "" Then
                    campo = "nro_docu"
                End If
                If sexo = "" Then
                    campo = "sexo"
                End If
                If nombres = "" Then
                    campo = "nombres"
                End If
                If apellido = "" Then
                    campo = "apellido"
                End If
                If email = "" Then
                    campo = "email"
                End If

                ' si es login interno, controlar que haya ingresado password
                If facebook_id = "" Then
                    If password = "" Then
                        campo = "password"
                    End If

                    If usuario = "" Then
                        campo = "usuario"
                    End If
                Else ' si es login de facebook, debe proporcionar el access_token
                    If access_token = "" Then
                        campo = "access_token"
                    End If
                End If

                If campo <> "" Then
                    exc.Data.Add(40, "EL campo '" & campo & "' es obligatorio y no se ha proporcionado")
                    Throw exc
                End If

                'La única validación que hace el servicio es validar formato y sanitizacion del mail.
                'Chequear email válido y sanitizar caso de gmail: eliminar puntos y quitar lo que está después del simbolo +
                Dim emailRaw As String = email
                email = SanitizeGMail(email)

                ' Buscar cuil: si se especificó número de documento y sexo
                If cuil = "" Then
                    Dim rsCuil As ADODB.Recordset = DBOpenRecordset("SELECT cuit FROM verDBCuit WHERE nro_docu=" & nro_docu & " AND sexo='" & sexo & "'")
                    If Not rsCuil.EOF Then
                        cuil = rsCuil.Fields("cuit").Value
                    End If
                    DBCloseRecordset(rsCuil)
                    If cuil = "" Then
                        exc.Data.Add(-1, " No se ha encontrado cuil para el número de documento y sexo especificados")
                        Throw exc
                    End If
                End If

                ' Averiguar si el usuario es un cliente conocido
                If solo_cliente <> "0" Then
                    Dim rsCliente As ADODB.Recordset = DBOpenRecordset("SELECT * FROM credito WHERE nro_docu=" & nro_docu & " AND sexo='" & sexo & "' and estado in('A','B','C','E','L','P','S','T','U')")
                    Dim esClienteConocido As Boolean = False
                    If Not rsCliente.EOF Then
                        esClienteConocido = True
                    End If
                    DBCloseRecordset(rsCliente)
                    If Not esClienteConocido Then
                        exc.Data.Add(39, "El usuario especificado no es un cliente conocido")
                        Throw exc
                    End If
                End If


                If facebook_id = "" Then

                    'Controlar si existe el usuario
                    Dim passed As Boolean = True
                    Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset("SELECT usuario FROM nv_security_login WHERE usuario='" & usuario & "'")
                    If Not rs.EOF Then
                        passed = False
                    End If
                    nvDBUtiles.DBCloseRecordset(rs)

                    If Not passed Then
                        exc.Data.Add(40, "El nombre de usuario ya existe")
                        Throw exc
                    End If

                    'Controlar si existe el mail
                    passed = True
                    rs = nvDBUtiles.ADMDBOpenRecordset("SELECT usuario FROM nv_security_login WHERE email='" & email & "'")
                    If Not rs.EOF Then
                        passed = False
                    End If
                    nvDBUtiles.DBCloseRecordset(rs)

                    If Not passed Then
                        exc.Data.Add(38, "La dirección de mail ya se encuentra registrada")
                        Throw exc
                    End If

                    ' se supone que devuelve un registro
                    Dim existeUsuario As Boolean = False
                    Dim esLoginInterno As Boolean = False
                    rs = nvDBUtiles.ADMDBOpenRecordset("SELECT usuario, esLoginInterno FROM vernv_security_login WHERE cuil='" & cuil & "'")
                    If Not rs.EOF Then
                        existeUsuario = True
                        esLoginInterno = rs.Fields("esLoginInterno").Value
                    End If
                    nvDBUtiles.DBCloseRecordset(rs)

                    ' ya existe un login interno con esos datos filiatorios
                    If existeUsuario And esLoginInterno Then
                        exc.Data.Add(41, "Ya existe un usuario con esos datos filiatorios")
                        Throw exc
                    End If

                    ' Control de la política de contraseña
                    checkPwdPolicy(password)

                    ' Calcular el hash de la contraseña con apendice aleatorio
                    Dim password_salt As Byte() = CreateSalt()
                    Dim password_hash As Byte() = GeneratePasswordHash(password, password_salt)

                    Dim strSQL As String = ""
                    If existeUsuario Then

                        ' updatear password_hash, password_salt, password_last_update
                        strSQL += "UPDATE nv_security_login SET email='" + email + "', usuario='" + usuario + "', password_hash=?, password_salt=?, password_last_update =GETDATE() WHERE cuil='" & cuil & "'"

                    Else

                        ' Hacer el alta del usuario
                        strSQL += "INSERT INTO nv_security_login "
                        strSQL += "(nro_docu, tipo_docu, sexo, cuil, nombres, apellido, email, "
                        strSQL += "usuario, password_hash, password_salt, fe_alta, last_modified, "
                        strSQL += "cod_estado, fe_estado, failed_count, nro_operador, pwdcc, password_last_update)"
                        strSQL += " VALUES(" + nro_docu + "," + tipo_docu + ",'" + sexo + "', '" + cuil + "','"
                        strSQL += nombres + "','" + apellido + "','" + email + "','" + usuario + "',?,?,GETDATE(),GETDATE(),1,GETDATE(),0," + nro_operador.ToString + "," + PwdCC + ", GETDATE())"
                    End If


                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText, emunDBType.db_admin)
                    Dim objParm1 = cmd.CreateParameter("@password_hash", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, password_hash.Length, password_hash)
                    Dim objParm2 = cmd.CreateParameter("@password_salt", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, password_salt.Length, password_salt)
                    cmd.Parameters.Append(objParm1)
                    cmd.Parameters.Append(objParm2)

                    cmd.Execute()

                    err.params("CUIL") = cuil

                Else

                    ' Controlar que esté logueado en facebook, y que su login corresponda
                    Dim isLogged As Boolean = VerifyFBLogin(facebook_id, access_token)
                    If Not isLogged Then
                        exc.Data.Add(-1, "El usuario no está logeado mediante facebook")
                        Throw exc
                    End If

                    'Controlar si existe el facebook_id
                    Dim passed As Boolean = True
                    Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset("SELECT facebook_id FROM nv_security_login WHERE facebook_id='" & facebook_id & "'")
                    If Not rs.EOF Then
                        passed = False
                    End If
                    nvDBUtiles.DBCloseRecordset(rs)
                    If Not passed Then
                        exc.Data.Add(42, "El facebook id ya existe")
                        Throw exc
                    End If

                    ' controlar si existe persona con el cuil especificado
                    Dim existeUsuario As Boolean = False
                    Dim esFBLogin As Boolean = False
                    rs = nvDBUtiles.ADMDBOpenRecordset("SELECT usuario, esFBLogin  FROM vernv_security_login WHERE  cuil='" & cuil & "'")
                    If Not rs.EOF Then
                        existeUsuario = True
                        esFBLogin = rs.Fields("esFBLogin").Value
                    End If
                    nvDBUtiles.DBCloseRecordset(rs)

                    ' ya existe un login de facebook con esos datos filiatorios
                    If existeUsuario And esFBLogin Then
                        exc.Data.Add(41, "Ya existe un usuario con esos datos filiatorios")
                        Throw exc
                    End If

                    ' Existe usuario, registrado via mail
                    If existeUsuario Then
                        Dim strSQL As String = ""
                        strSQL += " UPDATE nv_security_login SET facebook_id='" + facebook_id + "', last_modified=getdate() WHERE cuil='" & cuil & "'"
                        ADMDBExecute(strSQL)

                    Else
                        ' Hacer el alta del usuario
                        Dim strSQL As String = ""
                        strSQL += "INSERT INTO nv_security_login "
                        strSQL += "(nro_docu, tipo_docu, sexo, cuil, nombres, apellido"
                        strSQL += ", fe_alta, last_modified, "
                        strSQL += "cod_estado, fe_estado, failed_count, nro_operador, pwdcc, facebook_id)"
                        strSQL += " VALUES(" + nro_docu + "," + tipo_docu + ",'" + sexo + "', '" + cuil + "','"
                        strSQL += nombres + "','" + apellido + "',GETDATE(),GETDATE(),1,GETDATE(),0," + nro_operador.ToString + "," + PwdCC + ",'" + facebook_id + "')"
                        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText, emunDBType.db_admin)
                        cmd.Execute()

                    End If

                    err.params("CUIL") = cuil

                End If

            Catch e As Exception
                If e.Data.Keys.Count > 0 Then
                    Dim numError = e.Data.Keys(0)
                    Dim mensaje As String = e.Data(numError).ToString()
                    err.numError = numError
                    err.mensaje = mensaje
                    err.debug_desc = ""
                Else
                    err.numError = -1
                    err.mensaje = "Error inesperado"
                    err.debug_desc = e.Message
                    'err.parse_error_script(e)
                End If
            End Try

            nvLog.addEvent("nvsl_login_new", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)
            Return err
        End Function


        Public Shared Function BajaUsuarioByDocu(tipo_docu As String, nro_docu As String, sexo As String) As terror
            Return BajaUsuario(tipo_docu:=tipo_docu, nro_docu:=nro_docu, sexo:=sexo)
        End Function


        Public Shared Function BajaUsuarioByCuil(cuil As String) As terror
            Return BajaUsuario(cuil:=cuil)
        End Function


        Public Shared Function BajaUsuarioByEmail(email As String) As terror
            Return BajaUsuario(email:=email)
        End Function


        Public Shared Function BajaUsuarioByUserName(usuario As String) As terror
            Return BajaUsuario(usuario:=usuario)
        End Function


        Public Shared Function BajaUsuarioByFBId(facebook_id As String) As terror
            Return BajaUsuario(facebook_id:=facebook_id)
        End Function


        Public Shared Function BajaUsuario(Optional tipo_docu As String = "-1", Optional nro_docu As String = "-1",
                                           Optional sexo As String = "", Optional cuil As String = "",
                                           Optional email As String = "", Optional usuario As String = "",
                                           Optional facebook_id As String = "") As terror

            Dim err As New tError
            Dim exc As New Exception()
            Dim inputDataLog As String = "" & cuil & ";" & tipo_docu & ";" & nro_docu & ";" & sexo & ";" & email & ";" & usuario & ";" & facebook_id & ""
            Try
                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset("SELECT * FROM nv_security_login WHERE (tipo_docu=" & tipo_docu & " AND nro_docu=" & nro_docu & " AND sexo='" & sexo & "') OR cuil='" & cuil & "' OR email='" + email + "' OR usuario='" + usuario + "' OR facebook_id='" + facebook_id + "'")
                Dim existeRegistro As Boolean = True
                If rs.EOF Then
                    existeRegistro = False
                End If
                nvDBUtiles.DBCloseRecordset(rs)

                If Not existeRegistro Then
                    exc.Data.Add(-1, "El usuario no existe")
                    Throw exc
                End If
                nvDBUtiles.ADMDBExecute("DELETE FROM nv_security_login WHERE (tipo_docu=" & tipo_docu & " AND nro_docu=" & nro_docu & " AND sexo='" & sexo & "') OR cuil='" & cuil & "' OR email='" + email + "' OR usuario='" + usuario + "' OR facebook_id='" + facebook_id + "'")
            Catch e As Exception
                If e.Data.Keys.Count > 0 Then
                    Dim numError = e.Data.Keys(0)
                    Dim mensaje As String = e.Data(numError).ToString()
                    err.numError = numError
                    err.mensaje = mensaje
                    err.debug_desc = ""
                Else
                    err.numError = -1
                    err.mensaje = "Error inesperado"
                    err.debug_desc = e.Message
                    'err.parse_error_script(e)
                End If
            End Try

            'nvLog.addEvent("nvsl_login_delete",  nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)
            Return err
        End Function



        Public Shared Function validarLogin(usuario As String, password As String) As terror

            Dim err As New terror
            Dim exc As New Exception()
            Dim inputDataLog As String = "" & usuario & ""

            Try

                ' politica de contraseña
                Dim pass_failed_count_limit As Integer 'intentos permitidos antes de bloquearse
                Dim failed_login_time As Integer  ' tiempo entre login fallidos en segundos
                Dim pass_max_age_day As Integer ' vigencia de la contraseña en dias (-1 = sin vencimiento)
                pass_failed_count_limit = nvUtiles.getParametroValor("pass_failed_count_limit", 3)
                failed_login_time = nvUtiles.getParametroValor("failed_login_time", 5)
                pass_max_age_day = nvUtiles.getParametroValor("pass_max_age_day", -1)


                Dim password_salt As Byte() = Nothing
                Dim password_hash As Byte() = Nothing
                Dim last_login_failed As Date = Nothing
                Dim password_last_update As Date = Nothing
                Dim date_now As Date = Nothing
                Dim cuil As String = ""

                Dim rs As ADODB.Recordset = ADMDBOpenRecordset("SELECT cuil, cod_estado, password_hash, password_salt, last_login_failed, password_last_update, getdate() as date_now FROM nv_security_login WHERE usuario='" & usuario & "'")
                Dim cod_estado As String = ""
                If Not rs.EOF Then
                    cod_estado = rs.Fields("cod_estado").Value
                    password_salt = rs.Fields("password_salt").Value
                    password_hash = rs.Fields("password_hash").Value
                    date_now = rs.Fields("date_now").Value ' Usar el date del server sql y no el del iis (uso uno u otro, pero no los dos porque pueden estar desincronizados entre si)
                    last_login_failed = isNUll(rs.Fields("last_login_failed").Value, Nothing)
                    password_last_update = rs.Fields("password_last_update").Value
                    cuil = rs.Fields("cuil").Value
                End If
                DBCloseRecordset(rs)

                ' si encontro registro, debe tener estado
                If cod_estado <> "" Then
                    If cod_estado = "3" Then
                        exc.Data.Add(51, "El usuario se encuentra bloqueado")
                        Throw exc
                    End If
                Else 'si no encontro registro ...
                    'No genera retardo para proximo intento de logueo ya que no existe el registro. PROBLEMA: se puede deducir que el user no existe

                    exc.Data.Add(50, "Usuario o contraseñas incorrectos")
                    Throw exc
                End If

                ' Controlar tiempo transcurrido desde ultimo logueo fallido
                Dim diffInSeconds As Double = (date_now - last_login_failed).TotalSeconds
                If diffInSeconds < failed_login_time Then
                    exc.Data.Add(-1, "Debe esperar " & (failed_login_time - diffInSeconds) & " segundos para poder volver a loguearse")
                    Throw exc
                End If

                If password_hash Is Nothing Or password_salt Is Nothing Then
                    exc.Data.Add(-1, "Error inesperado")
                    Throw exc
                End If

                ' Controlar que la contraseña no esté vencida
                If pass_max_age_day <> -1 Then
                    Dim diffInDays As Double = (date_now - password_last_update).TotalDays
                    If Math.Floor(diffInDays) > Math.Floor(pass_max_age_day) Then
                        exc.Data.Add(46, "Su contraseña ha caducado, debe cambiarla para poder ingresar")
                        Throw exc
                    End If
                End If

                ' Verificar la contraseña
                ' IMPORTANTE- Fix: los logins con la fecha de ultima actualizacion de password
                ' menor al 1/1/2019 8:23PM han sido generados con un bug. 
                ' Hasta tanto no se actualicen, deben continuar siendo verificados
                ' con el método GeneratePasswordHash_buggy.
                ' TODO: Cuando se corrobore que todas las passwords tienen fecha de actualizacion mayor a 
                ' la fecha del fix, dejar unicamente el método correcto "GeneratePasswordHash" y eliminar
                ' "GeneratePasswordHash_buggy"
                Dim fixDate As Date = #1/1/2019 8:23:00 PM#
                Dim res As Byte()
                If (password_last_update <= fixDate) Then
                    res = GeneratePasswordHash_buggy(password, password_salt)
                Else
                    res = GeneratePasswordHash(password, password_salt)
                End If

                If Not password_hash.SequenceEqual(res) Then 'Si falló la verificación...

                    ' obtenter failed_count actual
                    rs = ADMDBOpenRecordset("SELECT failed_count FROM nv_security_login WHERE usuario='" & usuario & "'")
                    Dim failed_count As Integer = 0
                    If Not rs.EOF Then
                        failed_count = rs.Fields("failed_count").Value
                    End If
                    DBCloseRecordset(rs)

                    ' si se supero el limite de logins incorrectos bloquear la cuenta y resetear contador de intentos fallidos,
                    ' sino aumentar el contador de intentos fallidos
                    If failed_count + 1 > pass_failed_count_limit Then
                        ADMDBExecute("UPDATE nv_security_login SET failed_count=0, last_login_failed=NULL, cod_estado=3, fe_estado=GETDATE() WHERE usuario='" & usuario & "'")
                    Else
                        ADMDBExecute("UPDATE nv_security_login SET failed_count=failed_count+1, last_login_failed=GETDATE() WHERE usuario='" & usuario & "'")
                    End If


                    exc.Data.Add(50, "Usuario o contraseñas incorrectos")
                    Throw exc

                Else
                    ' Terminó con exito.
                    ' Resetear contador de intentos fallidos a cero
                    ADMDBExecute("UPDATE nv_security_login SET failed_count=0, last_login_failed=NULL WHERE usuario='" & usuario & "'")

                    err.params("CUIL") = cuil
                    nvLog.addEvent("nvsl_login", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)
                End If
            Catch e As Exception

                If e.Data.Keys.Count > 0 Then
                    Dim numError = e.Data.Keys(0)
                    Dim mensaje As String = e.Data(numError).ToString()
                    err.numError = numError
                    err.mensaje = mensaje
                    err.debug_desc = ""
                Else
                    err.numError = -1
                    err.mensaje = "Error inesperado"
                    err.debug_desc = e.Message
                    'err.parse_error_script(e)
                End If

                nvLog.addEvent("nvsl_login_error", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)

            End Try

            Return err

        End Function


        Public Shared Function validarFBLogin(facebook_id As String, access_token As String) As terror

            Dim inputDataLog As String = "" & facebook_id & ""
            Dim exc As New Exception()
            Dim err As New terror
            Try

                If access_token = "" Then
                    exc.Data.Add(-1, "El campo access_token es obligatorio para el login mediante facebook")
                    Throw exc
                End If

                Dim rset As ADODB.Recordset = ADMDBOpenRecordset("SELECT cuil FROM nv_security_login WHERE facebook_id='" & facebook_id & "'")
                Dim cuil_res As String = ""
                If Not rset.EOF Then
                    cuil_res = rset.Fields("cuil").Value
                Else
                    exc.Data.Add(-1, "No se encontro el usuario con el facebook_id especificado")
                    Throw exc
                End If
                DBCloseRecordset(rset)

                ' Controlar que este logeado en facebook, y que su login corresponda
                Dim isLogged As Boolean = VerifyFBLogin(facebook_id, access_token)
                If Not isLogged Then
                    exc.Data.Add(-1, "El usuario no está logeado mediante facebook")
                    Throw exc
                End If

                err.params("CUIL") = cuil_res
                nvLog.addEvent("nvsl_login", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)

            Catch e As Exception

                If e.Data.Keys.Count > 0 Then
                    Dim numError = e.Data.Keys(0)
                    Dim mensaje As String = e.Data(numError).ToString()
                    err.numError = numError
                    err.mensaje = mensaje
                    err.debug_desc = ""
                Else
                    err.numError = -1
                    err.mensaje = "Error inesperado"
                    err.debug_desc = e.Message
                    'err.parse_error_script(e)
                End If

                nvLog.addEvent("nvsl_login_error", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)
            End Try

            Return err

        End Function


        Public Shared Function changePwd(usuario As String, password_nueva As String) As terror

            Dim inputDataLog As String = "" & usuario & ""
            Dim err As New terror
            'TODO: si el password actual es igual a password nueva
            Try

                ' Control de política de contraseña
                checkPwdPolicy(password_nueva)

                ' Calcular el hash de la nueva contraseña con apendice aleatorio
                Dim password_salt As Byte() = CreateSalt()
                Dim password_hash As Byte() = GeneratePasswordHash(password_nueva, password_salt)

                ' Actualizar password
                Dim strSQL As String = ""
                strSQL += "UPDATE nv_security_login SET password_hash=?, password_salt=?, password_last_update=GETDATE() WHERE usuario='" & usuario & "' "
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText, emunDBType.db_admin)
                Dim objParm1 = cmd.CreateParameter("@password_hash", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, password_hash.Length, password_hash)
                Dim objParm2 = cmd.CreateParameter("@password_salt", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, password_salt.Length, password_salt)
                cmd.Parameters.Append(objParm1)
                cmd.Parameters.Append(objParm2)
                cmd.Execute()

            Catch e As Exception

                If e.Data.Keys.Count > 0 Then
                    Dim numError = e.Data.Keys(0)
                    Dim mensaje As String = e.Data(numError).ToString()
                    err.numError = numError
                    err.mensaje = mensaje
                    err.debug_desc = ""
                Else
                    err.numError = -1
                    err.mensaje = "Error inesperado"
                    err.debug_desc = e.Message
                    'err.parse_error_script(e)
                End If
            End Try

            nvLog.addEvent("nvsl_pwdchg", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)
            Return err
        End Function


        Public Shared Sub checkPwdPolicy(password As String, Optional pass_min_length As Integer = Nothing, Optional pass_strenght As Integer = Nothing)

            ' politica de contraseña
            If pass_min_length = Nothing Then
                pass_min_length = nvUtiles.getParametroValor("pass_min_length", 6) ' longitud de contraseña
            End If
            If pass_strenght = Nothing Then
                pass_strenght = nvUtiles.getParametroValor("pass_strenght", 2) '1=baja,2=media,3=alta
            End If

            Dim exc As New Exception()
            If pass_strenght = 2 Or pass_strenght = 3 Then

                ' Controlar longitud de la password
                If password.Length < pass_min_length Then
                    exc.Data.Add(43, "La contraseña debe tener al menos " & pass_min_length & " caracteres")
                    Throw exc
                End If

                ' Contar caracteres numéricos, alfabéticos, y alfabéticos en mayúsculas
                Dim lettercount As Integer = 0
                Dim upperLetterCount As Integer = 0
                Dim numberCount As Integer = 0

                For Each character In password
                    If Char.IsLetter(character) Then
                        lettercount += 1
                        If Char.IsUpper(character) Then
                            upperLetterCount += 1
                        End If
                    End If
                    If Char.IsNumber(character) Then
                        numberCount += 1
                    End If
                Next

                If pass_strenght = 2 Then
                    If lettercount = 0 Or numberCount < 2 Then
                        exc.Data.Add(44, "La contraseña no respeta la complejidad esperada. Longitud mayor o igual a " & pass_min_length & " caracteres con al menos 2 números")
                        Throw exc
                    End If
                End If

                If pass_strenght = 3 Then
                    If lettercount = 0 Or upperLetterCount = 0 Or numberCount < 2 Then
                        exc.Data.Add(45, "La contraseña no respeta la complejidad esperada. Longitud mayor o igual a " & pass_min_length & " caracteres con al menos 2 números y letras en mayúsculas y minúsculas")
                        Throw exc
                    End If
                End If
            ElseIf pass_strenght = 1 Then
                ' No se controla dureza
            Else
                exc.Data.Add(-1, "Política de contraseña desconocida")
                Throw exc
            End If

        End Sub


        Public Shared Function resetPwd(usuario As String, password As String, password_confirm As String, password_reset_code As String) As terror

            Dim err As New terror
            Dim exc As New exception
            Dim inputDataLog As String = "" & usuario & ""
            Dim reset_code_valid_time As Double = nvUtiles.getParametroValor("reset_code_valid_time", 1440) ' en minutos (1440 min = 1 dia)

            Try

                ' controlar que la contraseña coincida
                If password <> password_confirm Then
                    exc.Data.Add(-1, "La contraseña y su confirmación no coinciden")
                    Throw exc
                End If

                ' Control politica de contraseña
                checkPwdPolicy(password)

                Dim rs As ADODB.Recordset = ADMDBOpenRecordset("SELECT password_reset_code, password_reset_code_creation_date, getdate() as date_now  FROM nv_security_login WHERE usuario='" & usuario & "'")
                Dim valid_reset_code As Boolean = False
                If Not rs.EOF Then

                    Dim password_reset_code_creation_date As Date = isNUll(rs.Fields("password_reset_code_creation_date").Value, Nothing)
                    If password_reset_code_creation_date <> Nothing Then
                        Dim date_now As Date = rs.Fields("date_now").Value
                        Dim diffInMin As Double = (date_now - password_reset_code_creation_date).TotalMinutes

                        ' si el codigo coincide y no ha caducado
                        If password_reset_code = rs.Fields("password_reset_code").Value And diffInMin <= reset_code_valid_time Then
                            valid_reset_code = True
                        End If
                    End If
                End If
                DBCloseRecordset(rs)

                If valid_reset_code Then

                    ' Calcular el hash de la nueva contraseña con apendice aleatorio
                    Dim password_salt As Byte() = CreateSalt()
                    Dim password_hash As Byte() = GeneratePasswordHash(password, password_salt)

                    ' Establece la nueva password y desbloquea la cuenta (ademas se cambia el valor de password_reset_code para evitar multiples usos del mismo hash)
                    Dim strSQL As String = ""
                    strSQL += "UPDATE nv_security_login SET password_hash=?, password_salt=?, password_last_update=GETDATE(), password_reset_code='" & Guid.NewGuid().ToString & "', cod_estado=1, fe_estado=GETDATE() WHERE usuario='" & usuario & "' "
                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText, emunDBType.db_admin)
                    Dim objParm1 = cmd.CreateParameter("@password_hash", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, password_hash.Length, password_hash)
                    Dim objParm2 = cmd.CreateParameter("@password_salt", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, password_salt.Length, password_salt)
                    cmd.Parameters.Append(objParm1)
                    cmd.Parameters.Append(objParm2)

                    cmd.Execute()
                Else
                    exc.Data.Add(52, "No se ha podido restablecer la contraseña")
                    Throw exc
                End If

            Catch e As Exception

                If e.Data.Keys.Count > 0 Then
                    Dim numError = e.Data.Keys(0)
                    Dim mensaje As String = e.Data(numError).ToString()
                    err.numError = numError
                    err.mensaje = mensaje
                    err.debug_desc = ""
                Else
                    err.numError = -1
                    err.mensaje = "Error inesperado"
                    err.debug_desc = e.Message
                    'err.parse_error_script(e)
                End If
            End Try

            nvLog.addEvent("nvsl_pwd_set", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)

            Return err

        End Function


        Public Shared Function sendMail(usuario As String, email As String, resetPasswordUrl As String) As terror

            Dim password_reset_code As String = ""
            Dim inputDataLog As String = "" & usuario & ";" & email & ";"
            Dim exc As New exception
            Dim err As New terror

            Try
                If resetPasswordUrl = "" Then
                    exc.Data.Add(-1, "Debe establecer el campo reset_password_url")
                    Throw exc
                End If

                Dim rs As ADODB.Recordset = ADMDBOpenRecordset("SELECT esLoginInterno FROM vernv_security_login  WHERE usuario='" & usuario & "' or email='" & email & "'")
                Dim esLoginInterno As Boolean = False
                If Not rs.EOF Then
                    esLoginInterno = rs.Fields("esLoginInterno").Value
                End If
                DBCloseRecordset(rs)

                If Not esLoginInterno Then
                    exc.Data.Add(-1, "Este servicio sólo permite resetear la contraseña de logins internos. Las contraseñas de logins mediante facebook se deben resetear a través de sus servicios")
                    Throw exc
                End If

                ' generar hash de reseteo
                ADMDBExecute("UPDATE nv_security_login SET password_reset_code='" & Guid.NewGuid.ToString & "', password_reset_code_creation_date=GETDATE() WHERE usuario='" & usuario & "' or email='" & email & "'")

                ' Leer hash de reseto
                rs = nvDBUtiles.ADMDBOpenRecordset("SELECT password_reset_code, email FROM nv_security_login WHERE usuario='" & usuario & "' or email='" & email & "'")
                If Not rs.EOF Then
                    password_reset_code = rs.Fields("password_reset_code").Value
                    email = rs.Fields("email").Value
                End If
                DBCloseRecordset(rs)

                If password_reset_code = "" Then 'si no encontro registro...
                    If usuario <> "" Then
                        exc.Data.Add(50, "Usuario desconocido")
                        Throw exc
                    Else
                        exc.Data.Add(51, "Dirección de email desconocida")
                        Throw exc
                    End If
                End If

                Dim uriBuilder As New UriBuilder(resetPasswordUrl)
                Dim parameters = HttpUtility.ParseQueryString(uriBuilder.Query)
                parameters("usuario") = usuario
                parameters("password_reset_code") = password_reset_code
                uriBuilder.Query = parameters.ToString()
                'uriBuilder.Fragment = "some_fragment"
                Dim finalUrl As Uri = uriBuilder.Uri
                resetPasswordUrl = finalUrl.ToString

                Dim subject As String = "Solicitud de reseteo de contraseña"
                Dim body As String = "Por favor, para proceder con el reseteo de su contraseña haga click en el siguiente enlace: " &
                    "<br/><a href='" & resetPasswordUrl & "'><code>" + resetPasswordUrl + "</code></a><br/>" &
                    "Si el link no funciona, copie y peguelo en el navegador."
                err = nvNotify.sendMail(_from_title:="Servicio notificación", _from:="notificaciones@okcreditos.com.ar", _to:=email, _cc:="", _bcc:="", _subject:=subject, _body:=body)

                If err.numError = 0 Then
                    err.params("usuario") = usuario
                    err.params("email") = email
                    err.params("password_reset_code") = password_reset_code
                End If

            Catch e As Exception

                If e.Data.Keys.Count > 0 Then
                    Dim numError = e.Data.Keys(0)
                    Dim mensaje As String = e.Data(numError).ToString()
                    err.numError = numError
                    err.mensaje = mensaje
                    err.debug_desc = ""
                Else
                    err.numError = -1
                    err.mensaje = "Error inesperado"
                    err.debug_desc = e.Message
                    'err.parse_error_script(e)
                End If
            End Try

            nvLog.addEvent("nvsl_pwd_mail", nvLog.getNewLogTrack() & ";" & err.numError & ";" & err.mensaje & ";" & err.debug_desc & ";" & inputDataLog)
            Return err
        End Function


        Public Shared Function CreateSalt() As Byte()

            Dim size As Integer = 32 ' 32 bytes = tamaño sha256

            ' Generate a cryptographic random number.
            Dim rng As RNGCryptoServiceProvider = New RNGCryptoServiceProvider()
            Dim buff(size - 1) As Byte
            rng.GetBytes(buff)
            Return buff
        End Function


        Public Shared Function GeneratePasswordHash(pwd As String, salt As Byte()) As Byte()

            Dim pwdBytes() As Byte = Encoding.UTF8.GetBytes(pwd)
            Dim algorithm As HashAlgorithm = New SHA256Managed()

            Dim saltedBytes(pwdBytes.Length + salt.Length - 1) As Byte
            For i As Integer = 0 To pwdBytes.Length - 1
                saltedBytes(i) = pwdBytes(i)
            Next

            For i As Integer = 0 To salt.Length - 1
                saltedBytes(pwdBytes.Length + i) = salt(i)
            Next

            Return algorithm.ComputeHash(saltedBytes)
        End Function


        Public Shared Function GeneratePasswordHash_buggy(pwd As String, salt As Byte()) As Byte()

            Dim pwdBytes() As Byte = Encoding.UTF8.GetBytes(pwd)
            Dim algorithm As HashAlgorithm = New SHA256Managed()

            Dim saltedBytes(pwdBytes.Length + salt.Length - 1) As Byte
            For i As Integer = 0 To pwdBytes.Length - 1
                saltedBytes(i) = pwdBytes(i)
            Next

            For i As Integer = 0 To pwdBytes.Length - 1
                saltedBytes(pwdBytes.Length + i) = salt(i)
            Next

            Return algorithm.ComputeHash(saltedBytes)
        End Function


        Public Shared Function SanitizeGMail(email As String) As String

            Dim index As Integer = email.LastIndexOf("@")
            Dim emailDomain As String = email.Substring(index, email.Length - index)
            Dim emailUserRaw As String = email.Substring(0, index)

            If emailDomain.ToLower = "@gmail.com" Then
                Dim plusindex As Integer = emailUserRaw.LastIndexOf("+")
                If plusindex <> -1 Then
                    emailUserRaw = emailUserRaw.Substring(0, plusindex)
                End If
                email = emailUserRaw.Replace(".", "")
                Return email + "@gmail.com"
            Else
                Return email
            End If

        End Function


        ' Verificar Login de facebook
        Public Shared Function VerifyFBLogin(facebookId As String, userToken As String) As Boolean

            Dim tokenIsValid As Boolean = False
            Dim userId As String = ""
            Try

                Dim clientId As String = nvUtiles.getParametroValor("fb_login_app_id", "")
                Dim clientSecret As String = nvUtiles.getParametroValor("fb_login_app_secret", "")
                'clientId = "513963535696201"
                'clientSecret = "312ac7b97c1d95e688d8f235af9ffcdb"


                Dim appToken As String = ""
                Dim appLink As String = "https://graph.facebook.com/oauth/access_token?client_id=" & clientId & "&client_secret=" & clientSecret & "&grant_type=client_credentials"
                Using response As HttpWebResponse = nvHttpUtiles.requestHTTP(appLink, Nothing)


                    'Dim str As New System.IO.StreamReader(response.GetResponseStream())
                    'appToken = str.ReadToEnd().ToString().Replace("access_token=", "")

                    Dim servResponse As New AccessTokenServiceResponse
                    Dim ser As New DataContractJsonSerializer(servResponse.GetType)
                    servResponse = TryCast(ser.ReadObject(response.GetResponseStream()), AccessTokenServiceResponse)
                    appToken = servResponse.access_token
                End Using

                Dim link As String = "https://graph.facebook.com/debug_token?input_token=" & userToken & "&access_token=" & Uri.EscapeDataString(appToken)
                Using response As HttpWebResponse = nvHttpUtiles.requestHTTP(link, Nothing)

                    'Dim str As New System.IO.StreamReaderresponse.GetResponseStream())
                    'appToken = str.ReadToEnd().ToString()


                    Dim settings As DataContractJsonSerializerSettings = New DataContractJsonSerializerSettings()
                    settings.UseSimpleDictionaryFormat = True

                    Dim servResponse As New UserIdServiceResponse
                    Dim ser As New DataContractJsonSerializer(servResponse.GetType, settings)

                    servResponse = TryCast(ser.ReadObject(response.GetResponseStream()), UserIdServiceResponse)
                    userId = TryCast(servResponse.data("user_id"), String)
                    tokenIsValid = servResponse.data("is_valid")
                End Using
            Catch ex As Exception
                Return False
            End Try

            Return tokenIsValid And (facebookId = userId)
        End Function


        <DataContract()>
        Public Class AccessTokenServiceResponse
            <DataMember()>
            Public access_token As String
            <DataMember()>
            Public token_type As String 'bearer
        End Class


        <DataContract()>
        Public Class UserIdServiceResponse
            <DataMember()>
            Public data As Dictionary(Of String, Object)
        End Class


    End Class
End Namespace
