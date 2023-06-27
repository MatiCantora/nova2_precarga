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
    
    Public Sub logApiCall(input_data As String, response As String)
        Try
            ADMDBExecute("INSERT INTO nv_security_login_log(service_id, input_data, response, fecha_log) VALUES (3, '" & input_data.Replace("'", "''") & "', '" & response.Replace("'", "''") & "', GETDATE())")
        Catch e As Exception
        End Try
    End Sub
    
</script>


<%
    
    Dim err As New tError
    Dim usuario As String = nvUtiles.obtenerValor("usuario", "")
    Dim password_actual As String = nvUtiles.obtenerValor("password_actual", "")
    Dim password_nueva As String = nvUtiles.obtenerValor("password_nueva", "")
    
    Dim inputDataLog As String = "{ usuario=""" & usuario & """}"
    
    ' Debe pasar el login como primer paso
    Server.Execute("/fw/security/login/login_validar.aspx?err_response_onsuccess=0&usuario=" + usuario + "&password=" + password_actual)
    
    
    'TODO: si el password actual es igual a password nueva
    Dim exc As New Exception()

    
    Try
    
        ' Control politica de contraseña
        Dim pass_min_length As Integer ' longitud de contraseña
        Dim pass_strenght As Integer  '1=baja,2=media,3=alta
        pass_min_length = nvUtiles.getParametroValor("pass_min_length", 6)
        pass_strenght = nvUtiles.getParametroValor("pass_strenght", 2)
    
        If pass_strenght = 2 Or pass_strenght = 3 Then
            
            ' Controlar longitud de la password
            If password_nueva.Length < pass_min_length Then
                exc.Data.Add(43, "La contraseña debe tener al menos " & pass_min_length & " caracteres")
                Throw exc
            End If
            
            ' Contar caracteres numéricos, alfabéticos, y alfabéticos en mayúsculas
            Dim lettercount As Integer = 0
            Dim upperLetterCount As Integer = 0
            Dim numberCount As Integer = 0
            
            For Each character In password_nueva
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
    
    
    

    
        ' Calcular el hash de la nueva contraseña con apendice aleatorio
        Dim password_salt As Byte() = CreateSalt(32)
        Dim password_hash As Byte() = GenerateSaltedHash(Encoding.UTF8.GetBytes(password_nueva), password_salt)
    
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
        Else
            err.numError = -1
            err.mensaje = "Error inesperado"
            'err.parse_error_script(e)
        End If
    End Try

    
    logApiCall(inputDataLog, err.get_error_xml())
    err.response()
%>