Imports Microsoft.VisualBasic
Imports Org.BouncyCastle.X509
Imports System.IO
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW


    Public Class pkiFolder

        Public folder_path As String
        Public folder_name As String
        Public certificates As New Dictionary(Of String, X509Certificate)
        Public is_trusted As Boolean
        Public is_my As Boolean

        Public Sub New(folderPath As String, Optional isTrusted As Boolean = False, Optional isMy As Boolean = False)

            Dim folderName As String = folderPath.Split("\").Last

            Me.folder_path = folderPath
            Me.folder_name = folderName
            Me.is_trusted = isTrusted
            Me.is_my = isMy

        End Sub

    End Class






    ''' <summary>
    ''' Contenedor de estructura PKI
    ''' </summary>
    ''' <remarks></remarks>
    Public Class tnvPKI

        Public name As String = ""
        Public description As String


        Private _rootCert As X509Certificate = Nothing
        Private _trustedRoot As Boolean

        Private _certs As New Dictionary(Of String, X509Certificate)
        Private _certs_X509Certificate2 As New Dictionary(Of String, System.Security.Cryptography.X509Certificates.X509Certificate2)
        Private _trustedCerts As New Dictionary(Of String, X509Certificate)
        Private _myCerts As Dictionary(Of String, X509Certificate) = New Dictionary(Of String, X509Certificate)

        Private _folders As New Dictionary(Of String, pkiFolder)(System.StringComparer.OrdinalIgnoreCase)


        Public tsaUrl As String = ""
        Public tsaCert As X509Certificate


        Public ReadOnly Property rootCert As X509Certificate
            Get
                Return _rootCert
            End Get
        End Property

        Public ReadOnly Property trustedRoot As Boolean
            Get
                Return _trustedRoot
            End Get
        End Property

        Public ReadOnly Property certs As Dictionary(Of String, X509Certificate)
            Get
                Return _certs
            End Get
        End Property
        Public ReadOnly Property certs_X509Certificate2 As Dictionary(Of String, System.Security.Cryptography.X509Certificates.X509Certificate2)
            Get
                Return _certs_X509Certificate2
            End Get
        End Property

        Public ReadOnly Property trustedCerts As Dictionary(Of String, X509Certificate)
            Get
                Return _trustedCerts
            End Get
        End Property

        Public ReadOnly Property myCerts As Dictionary(Of String, X509Certificate)
            Get
                Return _myCerts
            End Get
        End Property

        Public ReadOnly Property folders As Dictionary(Of String, pkiFolder)
            Get
                Return _folders
            End Get
        End Property

        Public Sub New()
        End Sub

        'Public Function clone(Optional loadDBOptions As PKINovaDBUtil.nveunmloadDBOptions = PKINovaDBUtil.nveunmloadDBOptions.loadAll) As tnvPKI


        '    Dim newPKI As New tnvPKI(Me.name, Me.trustedRoot, Me.rootCert)

        '    For Each folder In _folders

        '        ' si corresponde, agregar carpeta y sus certificados
        '        If loadDBOptions And PKINovaDBUtil.nveunmloadDBOptions.loadTrusted And folder.Value.is_trusted Or
        '            loadDBOptions And PKINovaDBUtil.nveunmloadDBOptions.loadMy And folder.Value.is_my Or
        '            loadDBOptions And PKINovaDBUtil.nveunmloadDBOptions.LoadOther And (Not folder.Value.is_my And Not folder.Value.is_trusted) Then

        '            newPKI.createFolder(folder.Value.folder_path, folder.Value.is_trusted, folder.Value.is_my)

        '            Dim parser As New X509CertificateParser()
        '            For Each cert In folder.Value.certificates.Values
        '                Dim nuevoCert As X509Certificate = parser.ReadCertificate(cert.GetEncoded())
        '                newPKI.addCert(folder.Value.folder_path, nuevoCert)
        '            Next

        '        End If
        '    Next

        '    Return newPKI

        'End Function


        Public Sub New(pkiName As String, isTrusted As Boolean, rootCAFilePath As String)

            'Dim parser As New X509CertificateParser()
            'Dim cert As X509Certificate = parser.ReadCertificate(System.IO.File.ReadAllBytes(rootCAFilePath))
            Dim rootCert As New System.Security.Cryptography.X509Certificates.X509Certificate2(rootCAFilePath)
            setPKI(pkiName, isTrusted, rootCert)

        End Sub

        'Public Sub New(pkiName As String, isTrusted As Boolean, cert As X509Certificate)
        '    setPKI(pkiName, isTrusted, cert)
        'End Sub

        Public Sub New(pkiName As String, isTrusted As Boolean, cert As System.Security.Cryptography.X509Certificates.X509Certificate2)

            'Dim oCert As Org.BouncyCastle.X509.X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cert)
            setPKI(pkiName, isTrusted, cert)
        End Sub


        'Public Sub setPKI(pkiName As String, isTrusted As Boolean, cert As X509Certificate)

        '    name = pkiName
        '    _trustedRoot = isTrusted

        '    Dim id As String = cert.SerialNumber.ToString
        '    _rootCert = cert
        '    _certs.Add(id, _rootCert)
        '    If _trustedRoot Then
        '        _trustedCerts.Add(id, _rootCert)
        '    End If
        'End Sub

        Public Sub setPKI(pkiName As String, isTrusted As Boolean, cert As System.Security.Cryptography.X509Certificates.X509Certificate2)

            Dim cert2 As X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cert)

            name = pkiName
            _trustedRoot = isTrusted

            Dim id As String = cert.SerialNumber.ToString
            _rootCert = cert2
            _certs.Add(id, _rootCert)
            _certs_X509Certificate2.Add(id, cert)
            If _trustedRoot Then
                _trustedCerts.Add(id, _rootCert)
            End If
        End Sub


        Public Function getCertByName(SubjectDN As String) As X509Certificate
            For Each cert In _certs.Values
                If cert.SubjectDN.ToString = SubjectDN Then Return cert
            Next
            Return Nothing
        End Function



        Public Sub createFolder(folderPath As String, Optional trusted As Boolean = False, Optional isMy As Boolean = False)

            Dim folder As pkiFolder = New pkiFolder(folderPath, trusted, isMy)
            If Not _folders.ContainsKey(folderPath) Then
                _folders.Add(folderPath, folder)
            Else
                ' ya existe la carpeta
                Throw New Exception("Ya existe la carpeta")
            End If
        End Sub

        Public Sub addCert(path As String, cert As System.Security.Cryptography.X509Certificates.X509Certificate2)

            Dim id As String = cert.SerialNumber
            If _folders.ContainsKey(path) Then

                Dim BC_cert As X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(New System.Security.Cryptography.X509Certificates.X509Certificate(cert.RawData))

                _certs(id) = BC_cert
                _certs_X509Certificate2(id) = cert
                _folders(path).certificates(id) = _certs(id)

                If _folders(path).is_trusted Then
                    _trustedCerts(id) = _certs(id)
                End If

                If _folders(path).is_my Then
                    _myCerts(id) = _certs(id)
                End If

            Else
                Throw New Exception("No existe la carpeta destino")
            End If
        End Sub


        'Public Sub addCert(path As String, cert As System.Security.Cryptography.X509Certificates.X509Certificate2)
        '    Dim oCert As X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cert)
        '    addCert(path, oCert)
        'End Sub


        Public Sub addCert(folderPath As String, filePath As String, Optional passwd As String = "")

            Dim cert As System.Security.Cryptography.X509Certificates.X509Certificate2
            If passwd <> "" Then
                cert = New System.Security.Cryptography.X509Certificates.X509Certificate2(filePath, passwd, System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.MachineKeySet)
            Else
                cert = New System.Security.Cryptography.X509Certificates.X509Certificate2(filePath)
            End If
            addCert(folderPath, cert)
        End Sub

        Public Function getChain(cert As Org.BouncyCastle.X509.X509Certificate) As System.Security.Cryptography.X509Certificates.X509Chain
            Dim chain As System.Security.Cryptography.X509Certificates.X509Chain = New System.Security.Cryptography.X509Certificates.X509Chain()
            Dim ks As New List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)

            ks = Me.getTrustedCertsList("X509Certificate2")
            chain.ChainPolicy.ExtraStore.AddRange(ks.ToArray)

            ' la raiz de nuestra pki  debe estar instalada en el store (user o machine) del equipo
            ' para que la cadena resulte valida. Seteamos elsiguiente flag para para que el build chain devuelva true, aunque la raiz sea desconocida. 
            chain.ChainPolicy.VerificationFlags = System.Security.Cryptography.X509Certificates.X509VerificationFlags.AllowUnknownCertificateAuthority

            ' modo de revocacion: no check
            chain.ChainPolicy.RevocationMode = System.Security.Cryptography.X509Certificates.X509RevocationMode.NoCheck

            ' devuelve true si pudo verificar cadena, false caso contrario.
            ' Los mensajes de errorse cargan siempre, mas alla de lo que se haya especificado en los flags de verificacion
            ' Los errores UntrustedRoot y PartialChain(no armó cadena completa), no ocasionan que el build arroje falso
            Dim certificate2 As System.Security.Cryptography.X509Certificates.X509Certificate2 = New System.Security.Cryptography.X509Certificates.X509Certificate2(Org.BouncyCastle.Security.DotNetUtilities.ToX509Certificate(cert))

            'Construye la cadena de certificdso
            If Not chain.Build(certificate2) Then
                Return Nothing
            End If
            Return chain
        End Function

        'Public Function getChainElement(cert As Org.BouncyCastle.X509.X509Certificate) As List(Of Org.BouncyCastle.X509.X509Certificate)
        '    Dim chain As System.Security.Cryptography.X509Certificates.X509Chain
        '    chain = getChain(cert)
        '    Dim chainElement As New List(Of Org.BouncyCastle.X509.X509Certificate)
        '    For Each element In chain.ChainElements
        '        chainElement.Add(Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(element.Certificate))
        '    Next
        '    Return chainElement
        'End Function

        Public Function getChainElement(initialcert As Org.BouncyCastle.X509.X509Certificate, Optional ByRef includeRoot As Boolean = True) As List(Of Org.BouncyCastle.X509.X509Certificate)
            Dim res As New List(Of Org.BouncyCastle.X509.X509Certificate)
            'Dim certs() As Org.BouncyCastle.X509.X509Certificate =
            res.Add(initialcert)
            includeRoot = False
            Dim cert As Org.BouncyCastle.X509.X509Certificate = initialcert
            Dim issueCert As Org.BouncyCastle.X509.X509Certificate = Me.getCertByName(cert.IssuerDN.ToString)

            While Not issueCert Is Nothing
                Try
                    cert.Verify(issueCert.GetPublicKey)
                    res.Add(issueCert)
                    cert = issueCert
                    issueCert = Me.getCertByName(cert.IssuerDN.ToString)
                    If cert.SubjectDN.ToString = issueCert.SubjectDN.ToString Then
                        includeRoot = True
                        Try
                            cert.Verify(issueCert.GetPublicKey)
                        Catch ex As Exception
                            Stop
                        End Try
                        issueCert = Nothing
                    End If
                Catch ex As Exception
                    issueCert = Nothing
                End Try
            End While
            Return res
        End Function

        'Public Shared Function getCertFromList(subjectDN As String, lista() As Org.BouncyCastle.X509.X509Certificate) As Org.BouncyCastle.X509.X509Certificate
        '    For Each cert In lista
        '        If cert.SubjectDN.ToString = subjectDN Then
        '            Return cert
        '        End If
        '    Next
        '    Return Nothing
        'End Function



        Public Function getTrustedCertsList(Optional certType As String = "BC_X509Certificate") As IList

            Dim certs As IList = Nothing
            If certType = "BC_X509Certificate" Then
                certs = New List(Of X509Certificate)
                For Each kvp As KeyValuePair(Of String, X509Certificate) In trustedCerts
                    certs.Add(trustedCerts(kvp.Key))
                Next
            ElseIf certType = "X509Certificate" Then
                certs = New List(Of System.Security.Cryptography.X509Certificates.X509Certificate)
                For Each kvp As KeyValuePair(Of String, X509Certificate) In trustedCerts
                    certs.Add(Org.BouncyCastle.Security.DotNetUtilities.ToX509Certificate(trustedCerts(kvp.Key)))
                Next
            ElseIf certType = "X509Certificate2" Then
                certs = New List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)
                For Each kvp As KeyValuePair(Of String, X509Certificate) In trustedCerts
                    certs.Add(New System.Security.Cryptography.X509Certificates.X509Certificate2(Org.BouncyCastle.Security.DotNetUtilities.ToX509Certificate(trustedCerts(kvp.Key))))
                Next
            End If

            Return certs
        End Function



        Public Function certIsKnown(cert As X509Certificate) As Boolean
            Dim id As String = cert.SerialNumber.ToString
            Return _certs.ContainsKey(id)
        End Function


        Public Function certIsMy(cert As X509Certificate) As Boolean
            Dim id As String = cert.SerialNumber.ToString
            Return _myCerts.ContainsKey(id)
        End Function


        Public Function certIsTrusted(cert As X509Certificate) As Boolean
            Dim id As String = cert.SerialNumber.ToString
            Return _trustedCerts.ContainsKey(id)
        End Function

        Public Function certIsTrusted(cert As System.Security.Cryptography.X509Certificates.X509Certificate2) As Boolean
            Dim id As String = Integer.Parse(cert.GetSerialNumberString) 'el parse es para eliminar el 0 a la izquierda que aparecen para ids < 10
            Return _trustedCerts.ContainsKey(id)
        End Function

        Public Function getTrustedCertificate(serialNumber As String) As X509Certificate
            If trustedCerts.ContainsKey(serialNumber) Then
                Return trustedCerts(serialNumber)
            Else
                Return Nothing
            End If
        End Function

        Public Function getTrustedCertificateByName(name As String) As X509Certificate
            For Each cert In _trustedCerts.Values
                If cert.SubjectDN.ToString = name Then Return cert
            Next
            Return Nothing
        End Function









    End Class

End Namespace