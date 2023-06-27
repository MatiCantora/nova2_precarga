Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvPages
Imports nvFW.nvSecurity
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvSecurity
        Public Class tnvJWT
            Public header As New trsParam
            Public payload As New trsParam
            Public sign As Byte()

            Public Sub New(Optional ByVal alg As String = "RS256", Optional ByVal typ As String = "JWT")
                header("alg") = alg
                header("typ") = typ

                Dim utc0 = New DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc)
                Dim issueTime = DateTime.Now



                Dim iat = CInt(issueTime.Subtract(utc0).TotalSeconds)
                Dim exp = CInt(issueTime.AddMinutes(nvJWTConfig.JWT_exprie_minutes).Subtract(utc0).TotalSeconds) ' // Expiration time Is up to 1 hour, but lets play on safe side

                payload("iat") = iat
                payload("exp") = exp
                payload("iss") = nvJWTConfig.JWT_iss

            End Sub

            Public Sub parse(strJWT As String)
                Dim segments As String() = strJWT.Split(".")
                segments(0) = System.Text.Encoding.UTF8.GetString(Base64UrlDecode(segments(0)))
                segments(1) = System.Text.Encoding.UTF8.GetString(Base64UrlDecode(segments(1)))

                sign = Base64UrlDecode(segments(2))

                Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
                'Dim objForm As Object = serializer.Deserialize(Of Object)(strJSON)
                Dim objForm As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(segments(0))
                Dim formBody As Dictionary(Of String, Object) = New Dictionary(Of String, Object)(objForm, StringComparer.CurrentCultureIgnoreCase)

                header = New trsParam(formBody)

                'Dim objForm As Object = serializer.Deserialize(Of Object)(strJSON)
                objForm = serializer.Deserialize(Of Dictionary(Of String, Object))(segments(1))
                formBody = New Dictionary(Of String, Object)(objForm, StringComparer.CurrentCultureIgnoreCase)

                payload = New trsParam(formBody)

            End Sub

            Public Function verify(Optional ByRef certificate As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing) As Boolean

                If certificate Is Nothing Then certificate = nvFW.nvSecurity.nvJWTConfig.MyCert

                Dim segments = New List(Of String)
                Dim headerJSON As String = header.toJSON(nvConvertUtiles.nvJS_format.js_json)
                Dim payloadJSON As String = payload.toJSON(nvConvertUtiles.nvJS_format.js_json)
                Dim headerUTF8 As Byte() = System.Text.Encoding.UTF8.GetBytes(headerJSON)
                Dim payloadUTF8 As Byte() = System.Text.Encoding.UTF8.GetBytes(payloadJSON)

                segments.Add(Base64UrlEncode(headerUTF8))
                segments.Add(Base64UrlEncode(payloadUTF8))

                Dim stringToVerify As String = String.Join(".", segments.ToArray())

                Dim bytesToVerify As Byte() = System.Text.Encoding.UTF8.GetBytes(stringToVerify)
                Dim res As Boolean = False

                ' "alg" Param  | Digital Signature Or MAC      | Implementation     |
                '| Value        | Algorithm                     | Requirements       |
                '+--------------+-------------------------------+--------------------+
                '| HS256        | HMAC using SHA-256            | Required           |
                '| HS384        | HMAC using SHA-384            | Optional           |
                '| HS512        | HMAC using SHA-512            | Optional           |
                '| RS256        | RSASSA-PKCS1-v1_5 using       | Recommended        |
                '|              | SHA-256                       |                    |
                '| RS384        | RSASSA-PKCS1-v1_5 using       | Optional           |
                '|              | SHA-384                       |                    |
                '| RS512        | RSASSA-PKCS1-v1_5 using       | Optional           |
                '|              | SHA-512                       |                    |
                '| ES256        | ECDSA using P-256 And SHA-256 | Recommended+       |
                '| ES384        | ECDSA using P-384 And SHA-384 | Optional           |
                '| ES512        | ECDSA using P-521 And SHA-512 | Optional           |
                '| PS256        | RSASSA-PSS using SHA-256 And  | Optional           |
                '|              | MGF1 with SHA-256             |                    |
                '| PS384        | RSASSA-PSS using SHA-384 And  | Optional           |
                '|              | MGF1 with SHA-384             |                    |
                '| PS512        | RSASSA-PSS using SHA-512 And  | Optional           |
                '|              | MGF1 with SHA-512             |                    |
                '| none         | No digital signature Or MAC   | Optional           |
                '|              | performed                     |                    |
                '+--------------+-------------------------------+--------------------+
                Select Case header("alg").toupper
                    Case "RS256"


                        'Por defecto el RSA Provider que viene directamente desde la PrivateKey no puede hacer firma con sha256, sí puede con sha1 que es lo que tiene definido en el certificado.
                        Dim Key = DirectCast(certificate.PrivateKey, System.Security.Cryptography.RSACryptoServiceProvider)
                        Dim key_bytes As Byte() = Key.ExportCspBlob(True)

                        Dim RSA As New System.Security.Cryptography.RSACryptoServiceProvider()
                        RSA.ImportCspBlob(key_bytes)
                        res = RSA.VerifyData(bytesToVerify, "SHA256", sign)

                        RSA.Clear()


                        ''Por defecto el RSA Provider que viene directamente desde la PrivateKey no puede hacer firma con sha256, sí puede con sha1 que es lo que tiene definido en el certificado.
                        ''Para poder hacer esto se crea un nuevo RSA Provider desde el guardado con el containerName
                        'Dim Key = DirectCast(certificate.PrivateKey, System.Security.Cryptography.RSACryptoServiceProvider)
                        ''// Force use Of the Enhanced RSA And AES Cryptographic Provider With openssl-generated SHA256 keys
                        'Dim enhCsp = New System.Security.Cryptography.RSACryptoServiceProvider().CspKeyContainerInfo
                        'Dim cspparams = New System.Security.Cryptography.CspParameters(enhCsp.ProviderType, enhCsp.ProviderName, Key.CspKeyContainerInfo.KeyContainerName)
                        'cspparams.Flags = System.Security.Cryptography.CspProviderFlags.UseMachineKeyStore
                        'Dim RSA = New System.Security.Cryptography.RSACryptoServiceProvider(cspparams)

                        'res = RSA.VerifyData(bytesToVerify, "SHA256", sign)
                        'RSA.Clear()

                        ''Borrar el conteddor por las dudas
                        'Dim cp As New System.Security.Cryptography.CspParameters()
                        'cp.Flags = System.Security.Cryptography.CspProviderFlags.UseMachineKeyStore Or System.Security.Cryptography.CspProviderFlags.UseDefaultKeyContainer
                        'cp.KeyContainerName = Key.CspKeyContainerInfo.KeyContainerName
                        'Dim rsaBorrar As New System.Security.Cryptography.RSACryptoServiceProvider(cp)
                        '' Indicar que no debe ser guardada
                        'rsaBorrar.PersistKeyInCsp = False
                        '' Liberar los recursos del proveedor
                        'rsaBorrar.Clear()

                End Select

                Return res

            End Function

            Public Function verifyError(Optional ByRef certificate As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing, Optional ByVal aud As String = "") As tError
                Dim err As New tError()

                Dim verifySing As Boolean = Me.verify()
                Dim isExpired As Boolean = Me.isExpired

                If Not verifySing Then err.mensaje = "Token firma incorrecta."

                If isExpired Then err.mensaje = "Token exprirado."

                If aud <> "" AndAlso aud <> Me.payload("aud") Then err.mensaje = "El token no se corresponde con la aplicación."

                If err.mensaje <> "" Then
                    err.numError = 124
                    err.titulo = "Error de validación de token"
                End If

                Return err

            End Function

            Public Function encode(Optional ByRef certificate As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing) As String

                If certificate Is Nothing Then certificate = nvFW.nvSecurity.nvJWTConfig.MyCert
                Dim strJWT As String = ""
                Dim hashAlgoritm As System.Security.Cryptography.HashAlgorithm


                Dim segments = New List(Of String)
                Dim headerJSON As String = header.toJSON(nvConvertUtiles.nvJS_format.js_json)
                Dim payloadJSON As String = payload.toJSON(nvConvertUtiles.nvJS_format.js_json)
                Dim headerUTF8 As Byte() = System.Text.Encoding.UTF8.GetBytes(headerJSON)
                Dim payloadUTF8 As Byte() = System.Text.Encoding.UTF8.GetBytes(payloadJSON)

                segments.Add(Base64UrlEncode(headerUTF8))
                segments.Add(Base64UrlEncode(payloadUTF8))

                Dim stringToSign As String = String.Join(".", segments.ToArray())

                Dim bytesToSign As Byte() = System.Text.Encoding.UTF8.GetBytes(stringToSign)
                Dim signature As Byte()

                Select Case header("alg").toupper
                    Case "RS256"

                        'Por defecto el RSA Provider que viene directamente desde la PrivateKey no puede hacer firma con sha256, sí puede con sha1 que es lo que tiene definido en el certificado.
                        Dim privKey = DirectCast(certificate.PrivateKey, System.Security.Cryptography.RSACryptoServiceProvider)
                        Dim key_bytes As Byte() = privKey.ExportCspBlob(True)

                        Dim RSA As New System.Security.Cryptography.RSACryptoServiceProvider()
                        RSA.ImportCspBlob(key_bytes)

                        signature = RSA.SignData(bytesToSign, "SHA256")

                        RSA.Clear()


                        'Dim privKey As System.Security.Cryptography.RSACryptoServiceProvider = DirectCast(certificate.PrivateKey, System.Security.Cryptography.RSACryptoServiceProvider)

                        ''Por defecto el RSA Provider que viene directamente desde la PrivateKey no puede hacer firma con sha256, sí puede con sha1 que es lo que tiene definido en el certificado.
                        ''Para poder hacer esto se crea un nuevo RSA Provider desde el guardado con el containerName
                        ''// Force use Of the Enhanced RSA And AES Cryptographic Provider With openssl-generated SHA256 keys
                        'Dim enhCsp = New System.Security.Cryptography.RSACryptoServiceProvider().CspKeyContainerInfo
                        'Dim cspparams = New System.Security.Cryptography.CspParameters(enhCsp.ProviderType, enhCsp.ProviderName, privKey.CspKeyContainerInfo.KeyContainerName)
                        'cspparams.Flags = System.Security.Cryptography.CspProviderFlags.UseMachineKeyStore
                        'Dim RSA = New System.Security.Cryptography.RSACryptoServiceProvider(cspparams)

                        'signature = RSA.SignData(bytesToSign, "SHA256")
                        'RSA.Clear()

                        ''Borrar el conteddor por las dudas
                        'Dim cp As New System.Security.Cryptography.CspParameters()
                        'cp.Flags = System.Security.Cryptography.CspProviderFlags.UseMachineKeyStore Or System.Security.Cryptography.CspProviderFlags.UseDefaultKeyContainer
                        'cp.KeyContainerName = privKey.CspKeyContainerInfo.KeyContainerName
                        'Dim rsaBorrar As New System.Security.Cryptography.RSACryptoServiceProvider(cp)
                        '' Indicar que no debe ser guardada
                        'rsaBorrar.PersistKeyInCsp = False
                        '' Liberar los recursos del proveedor
                        'rsaBorrar.Clear()




                End Select


                segments.Add(Base64UrlEncode(signature))

                strJWT = String.Join(".", segments.ToArray())


                Return strJWT
            End Function


            Public Function isExpired() As Boolean
                Dim utc0 = New DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc)
                Dim issueTime = DateTime.Now
                Dim ahora = CInt(issueTime.Subtract(utc0).TotalSeconds)

                Dim res As Boolean = ahora > payload("exp")

                Return res
                'Dim exp = CInt(issueTime.AddMinutes(55).Subtract(utc0).TotalSeconds)
            End Function
            Private Shared Function Base64UrlEncode(input As Byte()) As String
                Dim output = Convert.ToBase64String(input)
                output = output.Split("=")(0)      '// Remove any trailing '='s
                output = output.Replace("+", "-")  '// 62nd char of encoding
                output = output.Replace("/", "_")  '// 63rd char of encoding

                Return output
            End Function

            Private Shared Function Base64UrlDecode(input As String) As Byte()
                Dim output = input
                output = output.Replace("-", "+")   '// 62nd char of encoding
                output = output.Replace("_", "/")   '// 63rd char of encoding

                output = IIf(output.Length Mod 4 = 0, output, output + "====".Substring(output.Length Mod 4))

                'Select Case output.Length Mod 4
                '    Case 0
                '        'No requiere padding

                '    Case 2
                '        output &= "==" '// Two pad chars
                '    Case 3
                '        output &= "="  '// One pad char
                'End Select

                Dim converted = Convert.FromBase64String(output)

                Return converted

            End Function

        End Class

    End Namespace
End Namespace