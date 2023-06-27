Imports System.IO
Imports System.Security.Cryptography
Imports System.Security.Cryptography.X509Certificates
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Namespace nvFW
    <Serializable()>
    Public Class tnvSignature
        ''' <summary>
        ''' Determina la PKI con la cual se firmará. Se utiliza para armar la cadena de certificados, identificar TSA, etc.
        ''' </summary>
        ''' <remarks></remarks>
        Public PKI As tnvPKI
        Public name As String
        ''' <summary>
        ''' Permite identificar a quien debe firmar el documento. El valor debe tener coincidencia con el certificado del firmante
        ''' </summary>
        ''' <remarks></remarks>
        Public signatoryID As String
        ''' <summary>
        ''' Motivo de uso de la firma
        ''' </summary>
        ''' <remarks></remarks>
        Public use As nvSignUse = nvSignUse.user_sign
        ''' <summary>
        ''' Certificado del firmante. Debe contener la clave privada
        ''' </summary>
        ''' <remarks></remarks>
        Public certificate As X509Certificate2
        ''' <summary>
        ''' Parámetros de configuración de firmas en PDF
        ''' </summary>
        ''' <remarks></remarks>
        Public PDFSignParams As tnvPDFSignParam
        ''' <summary>
        ''' Fecha de la firma
        ''' </summary>
        ''' <remarks></remarks>
        Public signDate As Date
        ''' <summary>
        ''' Algoritmo de hash que se utilizará en la firma.
        ''' </summary>
        ''' <remarks></remarks>
        Public hashAlgorithm As nvHashAlgorithm = nvHashAlgorithm.SHA1
        ''' <summary>
        ''' Algoritmo de encriptado asimetrico que se utilizará en la firma. Si es una firma con certificados no aplica.
        ''' </summary>
        ''' <remarks></remarks>
        Public asymmetricAlgorithm As nvAsymmetricAlgorithm = nvAsymmetricAlgorithm.RSA
        ''' <summary>
        ''' Especifica que información de revocación debe incluirse en la firma
        ''' </summary>
        ''' <remarks></remarks>
        Public includeRevocationInfo As enumRevocationInfo = enumRevocationInfo.OCSP_AND_CRL 'Determina que información de revocación debe incluirse en la firma

        'Si utiliza sellos de tiempo
        ''' <summary>
        ''' Especifica si se debe incluir sello de tiempo en la firma
        ''' </summary>
        ''' <remarks></remarks>
        Public use_timestamp_server As Boolean = False
        ''' <summary>
        ''' URL del servidor TSA
        ''' </summary>
        ''' <remarks></remarks>
        Public TSA_URL As String
        Public TSA_uid As String
        Public TSA_pwd As String
        Public TSA_police As String
        ''' <summary>
        ''' Especifica el algoritmo de hash que se utilizará en el sello de tiempo. Por defecto "SHA-256"
        ''' </summary>
        ''' <remarks></remarks>
        Public TSA_hash_algorithm As String = "SHA-256"


        Private _signVerifiExeptions As List(Of String)
        Private _signVerifyStatus As tnvSignVerifyStatus
        Private _status As nvSignStatus = nvSignStatus.unverified
        Private _document As tnvLegDocument
        'Elementos de la firma de una firma de documento binario
        Private _sign_bytes() As Byte
        Private _sign_date As Date
        Private _sign_certificate As X509Certificate2
        Private _sign_chain() As X509Certificate2
        Private _sign_CRL() As Byte
        Private _sign_OCSP() As Byte
        Private _sign_timestamtoken() As Byte







        Public Sub New(ByRef document As tnvLegDocument)
            _document = document
            '_PDFSignParams = New nvPDFSignParam
            use = nvSignUse.server_sign
            _status = nvSignStatus.unverified
        End Sub
        Public Sub New(ByRef document As tnvLegDocument, ByVal name As String, ByVal use As nvSignUse)
            _document = document
            Me.name = name
            Me.use = use
            _status = nvSignStatus.unverified
        End Sub

        Public Sub New(ByRef document As tnvLegDocument, ByVal name As String, ByVal use As nvSignUse, ByVal signatoryID As String)
            _document = document
            Me.name = name
            Me.use = use
            _signVerifiExeptions = Nothing
            _status = nvSignStatus.unverified
        End Sub
        Public Sub New(ByRef document As tnvLegDocument, ByVal name As String, ByVal use As nvSignUse, ByRef PDFSignParams As tnvPDFSignParam)
            _document = document
            Me.name = name
            Me.PDFSignParams = PDFSignParams
            Me.use = use
            _status = nvSignStatus.unverified
        End Sub

        Public Sub New(ByRef document As tnvLegDocument, ByVal name As String, ByVal use As nvSignUse, ByVal signatoryID As String, ByRef PDFSignParams As tnvPDFSignParam)
            _document = document
            Me.name = name
            Me.PDFSignParams = PDFSignParams
            Me.use = use
            _signVerifiExeptions = Nothing
            _status = nvSignStatus.unverified
        End Sub


        Public Sub setSignProperties(ByVal cer As X509Certificate2, Optional ByVal _signatoryID As String = "", Optional ByVal sign As Byte() = Nothing)
            _sign_certificate = cer
            signatoryID = _signatoryID
            If signatoryID = "" And signatoryID = "" And Not cer Is Nothing Then
                signatoryID = cer.FriendlyName

            End If
            If Not sign Is Nothing Then
                _sign_bytes = sign
            End If
        End Sub

        'Public Sub setSign(ByVal sign As Byte())
        '    _sign = sign
        'End Sub
        'Public Function isApplied(name As String) As Boolean

        '    If _status = nvSignStatus.unverified Then

        '        If Path.GetExtension(_document.filename).ToLower() = ".pdf" Or _document.content_type.ToLower() = "application/pdf" Then
        '            Dim myPdfReader As New iTextSharp.text.pdf.PdfReader(_document.bytes)
        '            Dim af As iTextSharp.text.pdf.AcroFields = myPdfReader.AcroFields
        '            Dim names As List(Of String) = af.GetSignatureNames()

        '            'Verificar si la firma existe
        '            If names.Contains(name) Then
        '                _status = nvSignStatus.applied
        '            Else
        '                _status = nvSignStatus.not_applied
        '            End If

        '            myPdfReader.Close()
        '        Else
        '            ' TODO: chequear si existe la firma en otro tipo de documentos
        '            _status = nvSignStatus.not_applied
        '        End If
        '    End If

        '    Return _status = nvSignStatus.applied

        'End Function

        Public Sub statusUpdate(pki As nvFW.tnvPKI)
            _signVerifiExeptions = New List(Of String)
            'Identificar el formato del documento
            If Path.GetExtension(_document.filename).ToLower() = ".pdf" Or _document.content_type.ToLower() = "application/pdf" Then

                '**********************************
                Dim singnaturesStatus As Dictionary(Of String, tnvSignVerifyStatus) = nvSignatureVerify.verifyPDFSignatures(_document.bytes, pki)
                Dim singStatus As tnvSignVerifyStatus

                'Verificar si la firma existe
                If Not singnaturesStatus.ContainsKey(name) Then
                    _status = nvSignStatus.not_applied
                    _signVerifyStatus = Nothing

                    Exit Sub
                Else
                    _signVerifyStatus = singnaturesStatus(name)
                    _status = nvSignStatus.applied
                End If


                ''**********************************
                ''Abrir el PDF
                'Dim myPdfReader As New iTextSharp.text.pdf.PdfReader(_document.bytes)

                'Dim af As iTextSharp.text.pdf.AcroFields = myPdfReader.AcroFields

                'Dim names As List(Of String) = af.GetSignatureNames()


                ''Verificar si la firma existe
                'If Not names.Contains(name) Then
                '    _status = nvSignStatus.not_applied
                '    Exit Sub
                'Else
                '    _status = nvSignStatus.applied
                'End If

                ''Valida si la firma cubre todo el documento
                'If (Not af.SignatureCoversWholeDocument(name)) Then
                '    _signVerifiExeptions.Add(String.Format("La firma: {0} no cubre todo el documento.", name))
                'End If

                'Dim pk As iTextSharp.text.pdf.security.PdfPKCS7 = af.VerifySignature(name)
                'Dim cal As Date = pk.SignDate
                '_sign_date = cal
                'Dim pkc() As Org.BouncyCastle.X509.X509Certificate = pk.Certificates

                'If (Not pk.Verify()) Then
                '    _signVerifiExeptions.Add(String.Format("La firma: {0} no pudo ser verificada.", name))
                'End If
                'If TSA_URL <> "" Then
                '    If (Not pk.VerifyTimestampImprint()) Then
                '        _signVerifiExeptions.Add(String.Format("La firma de tiempo : {0} no pudo ser verificada.", name))
                '        'Throw New InvalidOperationException("The signature timestamp could not be verified.")
                '    End If
                'Else
                '    _signVerifiExeptions.Add(String.Format("La firma de tiempo : {0} fue realizada con la hora del equipo firmante.", name))
                'End If

                'Dim fails As List(Of iTextSharp.text.pdf.security.VerificationException) = iTextSharp.text.pdf.security.CertificateVerification.VerifyCertificates(pkc, New Org.BouncyCastle.X509.X509Certificate() {pk.SigningCertificate}, Nothing, cal)
                'If (Not fails Is Nothing) Then
                '    'res.Add(String.Format("La firma: {0} no pudo ser verificada.", name))
                '    'Throw New InvalidOperationException("The file is not signed using the specified key-pair.")
                'End If

                'Dim fail As iTextSharp.text.pdf.security.VerificationException
                'For Each fail In fails
                '    _signVerifiExeptions.Add(String.Format("La firma: {0}. " & fail.Message, name))
                'Next
                ''************************************************
                ''Verificar que la firma sea del signatoryID
                ''************************************************
                ''Aca se debe verificar que la firma pernetezca al signatoryID.
                ''Seguramente será por el CUIT/CUIL que viene en el certificado, como no vienen aún no puedo verificar
                ''por eso compara por nombre
                'Dim AlternativeNames As List(Of String) = Nothing
                'Try
                '    AlternativeNames = pk.SigningCertificate.GetSubjectAlternativeNames()
                'Catch ex As Exception

                'End Try


                'If AlternativeNames Is Nothing Then
                '    AlternativeNames = New List(Of String)
                'End If
                'AlternativeNames.Add(pk.SigningCertificate.IssuerDN.ToString)
                'If Not AlternativeNames.Contains(signatoryID) Then
                '    _signVerifiExeptions.Add(String.Format("La firma: {0}. La firma no pertenece a la entidad definida", name))
                'End If
            Else

                '**********************************
                If _sign_bytes Is Nothing Then
                    _status = nvSignStatus.not_applied
                    _signVerifyStatus = Nothing
                    Exit Sub
                End If
                _status = nvSignStatus.applied
                _signVerifyStatus = nvSignatureVerify.verifyBINSignatures(_document.bytes, pki, _sign_bytes, _sign_certificate)(0)


                '**********************************



                'Verifivar que la firma existe
                If Not _sign_bytes Is Nothing And Not _sign_certificate Is Nothing Then
                    _status = nvSignStatus.applied
                Else
                    _status = nvSignStatus.not_applied
                    _signVerifiExeptions.Clear()
                    Exit Sub
                End If
                'Verificar firmas externas
                Select Case _sign_certificate.PrivateKey.GetType.ToString
                    Case "System.Security.Cryptography.RSACryptoServiceProvider"
                        Dim RSA As RSACryptoServiceProvider = DirectCast(_sign_certificate.PrivateKey, RSACryptoServiceProvider)
                        If Not RSA.VerifyData(_document.bytes, hashAlgorithm.ToString, _sign_bytes) Then
                            _signVerifiExeptions.Add(String.Format("La firma: {0} es incorrecta. Los datos no se corresponden con la firma.", name))
                        End If
                        _sign_certificate.Verify()

                    Case "System.Security.Cryptography.DSACryptoServiceProvider"
                        Dim DSA As DSACryptoServiceProvider = DirectCast(_sign_certificate.PrivateKey, DSACryptoServiceProvider)
                        If Not DSA.VerifyData(_document.bytes, _sign_bytes) Then
                            _signVerifiExeptions.Add(String.Format("La firma: {0} es incorrecta. Los datos no se corresponden con la firma.", name))
                        End If

                End Select

                Dim objChain As X509Chain = New X509Chain()
                Dim objChainStatus As X509ChainStatus

                '//Verifico toda la cadena de revocación
                objChain.ChainPolicy.RevocationFlag = X509RevocationFlag.EntireChain 'X509RevocationFlag.EndCertificateOnly X509RevocationFlag.ExcludeRoot
                objChain.ChainPolicy.RevocationMode = X509RevocationMode.Online 'X509RevocationMode.NoCheck X509RevocationMode.Offline

                '//Timeout para las listas de revocación
                objChain.ChainPolicy.UrlRetrievalTimeout = New TimeSpan(0, 0, 30)

                '//Verificar todo
                objChain.ChainPolicy.VerificationFlags = X509VerificationFlags.NoFlag

                '//Se puede cambiar la fecha de verificación
                If _sign_date > New Date(2001, 1, 1) Then
                    objChain.ChainPolicy.VerificationTime = _sign_date
                End If

                objChain.Build(_sign_certificate)

                Dim strVal As String = ""
                If (objChain.ChainStatus.Length <> 0) Then
                    For Each objChainStatus In objChain.ChainStatus
                        _signVerifiExeptions.Add(String.Format("La firma: {0}." & objChainStatus.Status.ToString() & " - " & objChainStatus.StatusInformation, name))
                        'strVal += objChainStatus.Status.ToString() & " - " & objChainStatus.StatusInformation & vbCrLf
                    Next

                End If
            End If
        End Sub


        Public Function isSignatory(ByVal subjectname As String, ByVal _signatoryID As String) As Boolean
            Try
                Dim s() As String = subjectname.ToString.Split(",")
                Dim cn As New Dictionary(Of String, String)
                For i = 0 To s.Count - 1
                    cn.Add(Trim(s(i).Split("=")(0)), s(i).Split("=")(1))
                Next

                s = _signatoryID.ToString.Split(",")
                Dim sID As New Dictionary(Of String, String)
                For i = 0 To s.Count - 1
                    sID.Add(s(i).Split("=")(0), s(i).Split("=")(1))
                Next

                Dim key As String
                For Each key In sID.Keys
                    If Not cn.Keys.Contains(key) Then
                        Return False
                    End If
                    If cn(key) <> sID(key) Then
                        Return False
                    End If
                Next
                Return True
            Catch ex As Exception
                Return False
            End Try

        End Function


        Public ReadOnly Property sign_bytes As Byte()
            Get
                Return _sign_bytes
            End Get
        End Property

        Public ReadOnly Property sign_certificate As X509Certificate2
            Get
                Return _sign_certificate
            End Get
        End Property


        Public ReadOnly Property status As nvSignStatus
            Get
                Return _status
            End Get
        End Property

        Public ReadOnly Property signVerifiExeptions As List(Of String)
            Get
                Return _signVerifiExeptions
            End Get
        End Property



        Public Sub setSign(ByVal sign() As Byte, ByVal singDate As Date, ByRef cer As X509Certificate2)
            _sign_bytes = sign
            _sign_date = signDate
            _sign_certificate = cer
        End Sub


    End Class

    Public Enum nvSignStatus
        unverified = 0
        not_applied = 1
        applied = 2
    End Enum

    Public Enum nvSignUse
        server_sign = 0
        user_sign = 1
    End Enum

    Public Enum nvHashAlgorithm
        SHA1 = 0
        SHA256 = 1
        SHA384 = 2
        SHA512 = 3
        RIPEMD160 = 4
    End Enum

    Public Enum nvAsymmetricAlgorithm
        RSA = 0
        DSA = 1
    End Enum

    Public Enum enumRevocationInfo
        None = 0
        OCSP = 1
        CRL = 2
        OCSP_AND_CRL = 3
    End Enum

End Namespace
