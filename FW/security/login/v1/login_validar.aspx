<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="System.Runtime.Serialization" %>
<%@ Import Namespace="System.Runtime.Serialization.Json" %>
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

    
    Function CompareByteArrays(array1 As Byte(), array2 As Byte()) As Boolean
        If array1.Length <> array2.Length Then
            Return False
        End If

        For i As Integer = 0 To array1.Length - 1
            If array1(i) <> array2(i) Then
                Return False
            End If
        Next
        Return True
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

    
    
    Public Sub logApiCall(input_data As String, response As String, Optional usuario As String = Nothing, Optional facebook_id As String = Nothing)
        
        'Dim id_usuario As String = "NULL"
        'If Not String.IsNullOrEmpty(usuario) Then
        '    Dim rs As ADODB.Recordset = ADMDBExecute("SELECT id_usuario FROM nv_security_login WHERE usuario='" & usuario & "'")
        '    If Not rs.EOF Then
        '        id_usuario = rs.Fields("id_usuario").Value
        '    End If
        '    DBCloseRecordset(rs)
        'ElseIf Not String.IsNullOrEmpty(facebook_id) Then
        '    Dim rs As ADODB.Recordset = ADMDBExecute("SELECT id_usuario FROM nv_security_login WHERE facebook_id='" & facebook_id & "'")
        '    If Not rs.EOF Then
        '        id_usuario = rs.Fields("id_usuario").Value
        '    End If
        '    DBCloseRecordset(rs)
        'End If
        
        Try
            ADMDBExecute("INSERT INTO nv_security_login_log(service_id, input_data, response, fecha_log) VALUES (2, '" & input_data.Replace("'", "''") & "', '" & response.Replace("'", "''") & "', GETDATE())")
            'System.IO.File.WriteAllText("D:\prueba_passs", "Ok")
        Catch e As Exception
            'System.IO.File.WriteAllText("D:\prueba_passs", "failed:" & e.ToString)
        End Try
        
    End Sub


</script>

<%
   

    Dim facebook_id As String = nvUtiles.obtenerValor("facebook_id", "")
    Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
        
    Dim err As New tError
    Dim exc As New Exception()
    Dim inputDataLog As String = ""
    
    Try
        ' chequear Facebook login
        If facebook_id <> "" Then
            
            Dim access_token As String = nvUtiles.obtenerValor("access_token", "")
            
            inputDataLog = "{""facebook_id""=""" & facebook_id & """}"

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
            logApiCall(inputDataLog, err.get_error_xml())
            err.response()
            
            
        Else
            

            ' politica de contraseña
            Dim pass_failed_count_limit As Integer 'intentos permitidos antes de bloquearse
            Dim failed_login_time As Integer  ' tiempo entre login fallidos en segundos
            Dim pass_max_age_day As Integer ' vigencia de la contraseña en dias (-1 = sin vencimiento)
            pass_failed_count_limit = nvUtiles.getParametroValor("pass_failed_count_limit", 3)
            failed_login_time = nvUtiles.getParametroValor("failed_login_time", 5)
            pass_max_age_day = nvUtiles.getParametroValor("pass_max_age_day", -1)

            Dim password As String = nvUtiles.obtenerValor("password", "")
            Dim err_response_onsuccess As Boolean = nvUtiles.obtenerValor("err_response_onsuccess", 1) ' Por defecto, dispara response cuando termina con exito
    
   
            inputDataLog = "{""usuario""=""" & usuario & """}"
    
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
    
    
            ' Controlar que la contraseña no este vencida
            If pass_max_age_day <> -1 Then
                Dim diffInDays As Double = (date_now - password_last_update).TotalDays
                If Math.Floor(diffInDays) > Math.Floor(pass_max_age_day) Then
                    exc.Data.Add(46, "Su contraseña ha caducado, debe cambiarla para poder ingresar")
                    Throw exc
                End If
            End If
    
    
            ' Verificar la contraseña
            Dim res As Byte() = GenerateSaltedHash(Encoding.UTF8.GetBytes(password), password_salt)
    
            If Not CompareByteArrays(password_hash, res) Then 'Si falló la verificación...
        
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
        
                ' Si el login_validar se llama desde otro aspx mediante server.execute
                ' se evita dispara el response
                If err_response_onsuccess Then
                    err.params("CUIL") = cuil
                    logApiCall(inputDataLog, err.get_error_xml())
                    err.response()
                End If
            End If
            

            
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
        logApiCall(inputDataLog, err.get_error_xml())
        err.response()
    End Try


    
    
    
    
    

    
    %>
    


