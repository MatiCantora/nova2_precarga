<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="System.Runtime.Serialization" %>

<%@ Import Namespace="System.Runtime.Serialization.Json" %>

<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Net" %>

<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="nvFW" %>

<script runat="server">


    
    
    Function CreateSalt(size As Integer) As Byte()
        ' Generate a cryptographic random number.
        Dim rng As RNGCryptoServiceProvider = New RNGCryptoServiceProvider()
        Dim buff(size - 1) As Byte
        rng.GetBytes(buff)
        Return buff
    End Function
        
    Function GenerateSaltedHash(plainText As Byte(), salt As Byte()) As Byte()

        Dim algorithm As HashAlgorithm = New SHA256Managed()
        Dim plainTextWithSaltBytes(plainText.Length + salt.Length - 1) As Byte
        For i As Integer = 0 To plainText.Length - 1
            plainTextWithSaltBytes(i) = plainText(i)
        Next
        For i As Integer = 0 To plainText.Length - 1
            plainTextWithSaltBytes(plainText.Length + i) = salt(i)
        Next
        Return algorithm.ComputeHash(plainTextWithSaltBytes)
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


    ' Verificar Login de facebook
    Function VerifyFBLogin(facebookId As String, userToken As String)

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
    
    
    Public Function SanitizeGMail(email As String) As String
        
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
    
    
    Public Sub logApiCall(input_data As String, response As String)
        Try
            ADMDBExecute("INSERT INTO nv_security_login_log(service_id, input_data, response, fecha_log) VALUES (1, '" & input_data.Replace("'", "''") & "', '" & response.Replace("'", "''") & "', GETDATE())")
        Catch e As Exception
        End Try
    End Sub
    
</script>

<%
  
    Dim err As New tError
    Dim exc As New Exception()
    Dim inputDataLog As String = ""
    
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    

    ' politica contraseña
    Dim pass_min_length As Integer ' longitud de contraseña
    Dim pass_strenght As Integer  '1=baja,2=media,3=alta
    pass_min_length = nvUtiles.getParametroValor("pass_min_length", 6)
    pass_strenght = nvUtiles.getParametroValor("pass_strenght", 2)
    
    
    Try
        If accion.ToLower = "alta" Then
            
            Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
            Dim nro_operador As String = op.operador
            'Dim nro_docu As String = nvUtiles.obtenerValor("nro_docu", "")
            'Dim tipo_docu As String = nvUtiles.obtenerValor("tipo_docu", "")
            'Dim sexo As String = nvUtiles.obtenerValor("sexo", "")
            'Dim cuil As String = nvUtiles.obtenerValor("cuil", "")
            'Dim nombres As String = nvUtiles.obtenerValor("nombres", "")
            'Dim apellido As String = nvUtiles.obtenerValor("apellido", "")
            'Dim email As String = nvUtiles.obtenerValor("email", "")
            'Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
            'Dim password As String = nvUtiles.obtenerValor("password", "")
            'Dim PwdCC As String = nvUtiles.obtenerValor("pwdCC", "0")
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
        
            Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
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
        
            
            ' Remover la password o access token en la info de log
            If access_token <> "" Then
                oXml.SelectSingleNode("/criterio/login").Attributes("access_token").Value = "0"
            End If
            If password <> "" Then
                oXml.SelectSingleNode("/criterio/login").Attributes("password").Value = "0"
            End If
            
            inputDataLog = "{ strXML=""" & oXml.OuterXml.ToString & """ accion=""alta""}"
            

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
            Else
                If access_token = "" Then
                    campo = "access_token"
                End If
            End If
        
        
            If campo <> "" Then
                exc.Data.Add(40, "EL campo '" & campo & "' es obligatorio y no se ha proporcionado")
                Throw exc
            End If
        
        
            'La unica validacin que hace el servicio es validar formato y sanitizacion del mail.
            'chequear email valido y sanitizar caso de gmail: eliminar puntos y quitar lo que esta despues del simbolo +
            Dim emailRaw As String = email
            email = SanitizeGMail(email)
        
        
            ' Buscar cuil si se especificó número de documento y sexo
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
        
		        
            ' Buscar si el usuario es un cliente conocido
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
            
            
                ' Control politica de contraseña
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
                            exc.Data.Add(44, "La contraseña no respeta la complejidad esperada. " & pass_min_length & " caracteres con al menos 2 números")
                            Throw exc
                        End If
                    End If
        
                    If pass_strenght = 3 Then
                        If lettercount = 0 Or upperLetterCount = 0 Or numberCount < 2 Then
                            exc.Data.Add(45, "La contraseña no respeta la complejidad esperada. " & pass_min_length & " caracteres con al menos 2 números y letras en mayúsculas y minúsculas")
                            Throw exc
                        End If
                    End If
                End If

            
            
            
                ' Calcular el hash de la contraseña con apendice aleatorio
                Dim password_salt As Byte() = CreateSalt(32)
                Dim password_hash As Byte() = GenerateSaltedHash(Encoding.UTF8.GetBytes(password), password_salt)
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
                
            
                ' Controlar que este logeado en facebook, y que su login corresponda
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
            
            
                ' se supone que devuelve un registro
                Dim existeUsuario As Boolean = False
                Dim esFBLogin As Boolean = False
                rs = nvDBUtiles.ADMDBOpenRecordset("SELECT usuario, esFBLogin  FROM vernv_security_login WHERE  cuil='" & cuil & "'")
                If Not rs.EOF Then
                    existeUsuario = True
                    esFBLogin = rs.Fields("esFBLogin").Value
                End If
                nvDBUtiles.DBCloseRecordset(rs)
            
                ' ya existe un login interno con esos datos filiatorios
                If existeUsuario And esFBLogin Then
                    exc.Data.Add(41, "Ya existe un usuario con esos datos filiatorios")
                    Throw exc
                End If
            
            
           
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
        

        ElseIf accion.ToLower = "baja" Then
            
            
            
            Dim cuil As String = nvUtiles.obtenerValor("cuil", "")
            Dim tipo_docu As String = nvUtiles.obtenerValor("tipo_docu", "-1")
            Dim nro_docu As String = nvUtiles.obtenerValor("nro_docu", "-1")
            Dim sexo As String = nvUtiles.obtenerValor("sexo", "")
            Dim email As String = nvUtiles.obtenerValor("email", "")
            Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
            Dim facebook_id As String = nvUtiles.obtenerValor("facebook_id", "")
        
            inputDataLog = "{ cuil=""" & cuil & """ tipo_docu=""" & tipo_docu & """ nro_docu=""" & nro_docu & """ sexo=""" & sexo & """ email=""" & email & """ usuario=""" & usuario & """ facebook_id=""" & facebook_id & """ accion=""baja""}"
            
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
            
        
        ElseIf accion.ToLower = "modificacion" Then
        
        

        End If
        
    Catch e As Threading.ThreadAbortException 'por el error que da el err.response dentro de try
    Catch e As Exception
        
        If e.Data.Keys.Count > 0 Then
            Dim numError = e.Data.Keys(0)
            Dim mensaje As String = e.Data(numError).ToString()
            err.numError = numError
            err.mensaje = mensaje
        Else
            err.numError = -1
            err.mensaje = "Error inesperado"
            'err.parse_error_script(e)
        End If

    End Try
    

    logApiCall(inputDataLog, err.get_error_xml())
    err.response()

    
    %>

