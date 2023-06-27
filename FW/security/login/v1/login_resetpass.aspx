<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

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
    
    Public Sub logApiCall(input_data As String, response As String)
        Try
            ADMDBExecute("INSERT INTO nv_security_login_log(service_id, input_data, response, fecha_log) VALUES (4, '" & input_data.Replace("'", "''") & "', '" & response.Replace("'", "''") & "', GETDATE())")
        Catch e As Exception
        End Try
    End Sub
   
</script>

<%
    Dim err As New tError
    Dim exc As New Exception()
    Dim accion As String = nvUtiles.obtenerValor("accion", "send_mail")
    Dim inputDataLog As String = ""
    
    Try
        If accion = "send_mail" Then
        
        
            Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
            Dim email As String = nvUtiles.obtenerValor("email", "")
            Dim resetPasswordUrl As String = nvUtiles.obtenerValor("reset_password_url", "")
            Dim password_reset_code As String = ""
        
        
            inputDataLog = "{ usuario=""" & usuario & """ email=""" & email & """ reset_password_url=""" & resetPasswordUrl & """ accion=""send_mail"" }"
        
        
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
        
            ' Enviar mail con link para el reseteo
            'Dim serverUri As Uri = New Uri(nvApp.server_host_https)
            'resetPasswordUrl = New Uri(serverUri, "/fw/security/login/login_resetpass_form.aspx")
            'Dim resetPasswordUrlString As String = resetPasswordUrl.ToString & "?usuario=" & usuario & "&password_reset_code=" & password_reset_code
        
            'resetPasswordUrl = resetPasswordUrl.ToString & "?usuario=" & usuario & "&password_reset_code=" & password_reset_code
        
        
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

            err.params("usuario") = usuario
            err.params("email") = email
            err.params("password_reset_code") = password_reset_code
            
        End If
    
    
    
    
    
        If accion = "reset_password" Then
        
        
            Dim reset_code_valid_time As Double = nvUtiles.getParametroValor("reset_code_valid_time", 1440) ' en minutos (1440 min = 1 dia)
            Dim password_reset_code As String = nvUtiles.obtenerValor("password_reset_code", "")
            Dim password As String = nvUtiles.obtenerValor("password", "")
            Dim password_confirm As String = nvUtiles.obtenerValor("password_confirm", "")
            Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
        
        
            inputDataLog = "{ usuario=""" & usuario & """ password_reset_code=""" & password_reset_code & """ accion=""reset_password""}"
            
            ' controlar que la contraseña coincida
            If password <> password_confirm Then
                exc.Data.Add(-1, "La contraseña y su confirmación no coinciden")
                Throw exc
            End If
        
        
            ' Control politica de contraseña
            Dim pass_min_length As Integer ' longitud de contraseña
            Dim pass_strenght As Integer  '1=baja,2=media,3=alta
            pass_min_length = nvUtiles.getParametroValor("pass_min_length", 6)
            pass_strenght = nvUtiles.getParametroValor("pass_strenght", 2)
    
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
        
        
        
            Dim rs As ADODB.Recordset = ADMDBOpenRecordset("SELECT password_reset_code, password_reset_code_creation_date, getdate() as date_now  FROM nv_security_login WHERE usuario='" & usuario & "'")
            Dim valid_reset_code As Boolean = False
            If Not rs.EOF Then
            
                Dim password_reset_code_creation_date As Date = rs.Fields("password_reset_code_creation_date").Value
                Dim date_now As Date = rs.Fields("date_now").Value
                Dim diffInMin As Double = (date_now - password_reset_code_creation_date).TotalMinutes
            
                ' si el codigo coincide y no ha caducado
                If password_reset_code = rs.Fields("password_reset_code").Value And diffInMin <= reset_code_valid_time Then
                    valid_reset_code = True
                End If
            End If
            DBCloseRecordset(rs)
        
            If valid_reset_code Then
            
                ' Calcular el hash de la nueva contraseña con apendice aleatorio
                Dim password_salt As Byte() = CreateSalt(32)
                Dim password_hash As Byte() = GenerateSaltedHash(Encoding.UTF8.GetBytes(password), password_salt)
    
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
        
        
        End If
    
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