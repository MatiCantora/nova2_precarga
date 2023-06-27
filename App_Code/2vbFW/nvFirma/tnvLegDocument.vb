Imports System.IO
Imports System.Security.Cryptography
Imports System.Security.Cryptography.X509Certificates
Imports iTextSharp.text.pdf
Imports iTextSharp.text.pdf.security
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW
    Public Class tnvLegDocument

        Private _name As String
        Private _filename As String
        Private _length As String
        Private _content_type As String
        Private _file As MemoryStream
        Private _metadatarequest As Dictionary(Of String, String)


        Public Signatures As List(Of tnvSignature) ' Dictionary(Of String, nvSignature)
        Public PDFEncryption As nvPDFEncryption


        ''' <summary>
        ''' Acceso a las propiedades del documento
        ''' </summary>
        ''' <param name="key">Nombre de la propiedad</param>
        ''' <value></value>
        ''' <returns>Valor de la propiedad</returns>
        ''' <remarks></remarks>
        Public Property metadata(ByVal key As String) As String
            Set(ByVal value As String)
                '********************************'
                'Agregar los metadatos al PDF
                '********************************'
                If Path.GetExtension(_filename).ToLower() = ".pdf" Or _content_type.ToLower() = "application/pdf" Then


                    'Abrir el PDF desde la colleccion bytes
                    Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(bytes)
                    'Abrir el PDF directamente desde el memorystream
                    'Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(_file)
                    'Crear el memorystream de salida
                    Dim ms As MemoryStream = New MemoryStream

                    ' Si se lee desde un memory stream me obligó a poner esta sentencia. Sino da un error de password incorrecto aunque no tenga password
                    reader.unethicalreading = True

                    Dim stamper As iTextSharp.text.pdf.PdfStamper = New iTextSharp.text.pdf.PdfStamper(reader, ms)
                    Dim info As Dictionary(Of String, String) = reader.Info


                    'Cargar el metadato


                    If info.Keys.Contains(key) Then
                        info.Remove(key)
                    End If
                    info.Add(key, value)

                    stamper.MoreInfo = info
                    stamper.Close()

                    'Generar un nuevo memory stream desde el asignado al Stamper. El stamper cierra el stream asignado
                    Dim ms2 As New MemoryStream(ms.ToArray())

                    'copiar a un archivo
                    'Dim fs As New FileStream("d:\salidapdf.pdf", System.IO.FileMode.Create)
                    'ms2.CopyTo(fs)
                    'fs.Close()

                    'Destruir el stream
                    ms.Dispose()
                    'reasignar el nuevo stream
                    _file.Dispose()
                    _file = ms2

                    'ms.Close()
                    reader.Close()

                End If
            End Set
            Get
                Dim res As String = Nothing
                'Codigo según la estancion y el content-type
                If Path.GetExtension(_filename).ToLower() = ".pdf" Or _content_type.ToLower() = "application/pdf" Then

                    'realizar la apertura del PDF desde la colelccion bytes
                    Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(bytes)


                    Dim info As Dictionary(Of String, String) = reader.Info


                    Dim tmpkey As String

                    For Each tmpkey In info.Keys
                        If key.ToLower = tmpkey.ToLower Then
                            res = info.Keys(key)
                            Exit For
                        End If
                    Next
                    'stamper.MoreInfo = info
                    'stamper.Close()
                    'ms.Close()
                    reader.Close()
                End If

                Return res '_metadata(key)
            End Get
        End Property

        ''' <summary>
        ''' Recupera la colleccion de propiedades del documento
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property metadataKeys() As Dictionary(Of String, String).KeyCollection
            Get
                Dim res As Dictionary(Of String, String).KeyCollection = Nothing
                'Codigo según la estancion y el content-type
                If Path.GetExtension(_filename).ToLower() = ".pdf" Or _content_type.ToLower() = "application/pdf" Then

                    'realizar la apertura del PDF desde la colelccion bytes
                    Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(bytes)


                    Dim info As Dictionary(Of String, String) = reader.Info

                    res = info.Keys

                    reader.Close()
                    Return res
                End If

                Return res '_metadata(key)
            End Get
        End Property



        ''' <summary>
        ''' Rescupera el dicionario de propiedades del documento
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Function getInfo() As Dictionary(Of String, String)

            Dim res As Dictionary(Of String, String) = Nothing
            'Codigo según la estancion y el content-type
            If Path.GetExtension(_filename).ToLower() = ".pdf" Or _content_type.ToLower() = "application/pdf" Then

                'realizar la apertura del PDF desde la colelccion bytes
                Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(bytes)


                Dim info As Dictionary(Of String, String) = reader.Info

                res = info

                reader.Close()
                Return res
            End If

            Return res '_metadata(key)

        End Function

        ''' <summary>
        ''' Acceso a la cadena de bytes del documento
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property bytes() As Byte()
            Get
                Dim buffer(_file.Length - 1) As Byte
                Dim count As Integer
                _file.Position = 0
                count = _file.Read(buffer, 0, _file.Length)

                Return buffer
            End Get
        End Property

        Public ReadOnly Property filename As String
            Get
                Return _filename
            End Get
        End Property

        Public ReadOnly Property content_type As String
            Get
                Return _content_type
            End Get
        End Property

        Public Property metadataRequest() As Object
            Get
                Return Me._metadatarequest
            End Get
            Set(ByVal value)
                Me._metadatarequest = value
            End Set

        End Property

        Public Property getfile() As Object
            Get
                Return Me._file
            End Get
            Set(ByVal value)
            End Set

        End Property

        Public Sub setPropiedadesDocument(Optional ByVal name As String = "", Optional ByVal filename As String = "", Optional ByVal length As Integer = 0, Optional ByVal content_type As String = "")
            _filename = IIf(filename = "", _filename, filename)
            _name = IIf(name = "", _name, name)
            _content_type = IIf(content_type = "", _content_type, content_type)
            _length = IIf(length = 0, _length, length)
        End Sub

        ''' <summary>
        ''' Recibe un dicccionario de metadatos y los incorpora al documento.
        ''' </summary>
        ''' <param name="metadataDictionary">Diccionario de propiedades</param>
        ''' <remarks></remarks>
        Public Sub addMetadataCollection(ByVal metadataDictionary As Dictionary(Of String, String))
            '********************************'
            'Agregar los metadatos al PDF
            '********************************'
            If Path.GetExtension(_filename).ToLower() = ".pdf" Or _content_type.ToLower() = "application/pdf" Then


                'Abrir el PDF desde la colleccion bytes
                Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(bytes)
                'Abrir el PDF directamente desde el memorystream
                'Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(_file)
                'Crear el memorystream de salida
                Dim ms As MemoryStream = New MemoryStream

                ' Si se lee desde un memory stream me obligó a poner esta sentencia. Sino da un error de password incorrecto aunque no tenga password
                reader.unethicalreading = True

                Dim stamper As iTextSharp.text.pdf.PdfStamper = New iTextSharp.text.pdf.PdfStamper(reader, ms)
                Dim info As Dictionary(Of String, String) = reader.Info


                'Cargar los metadatos
                Dim key As String
                For Each key In metadataDictionary.Keys
                    If info.Keys.Contains(key) Then
                        info.Remove(key)
                    End If
                    info.Add(key, metadataDictionary(key))
                Next
                stamper.MoreInfo = info
                stamper.Close()

                'Generar un nuevo memory stream desde el asignado al Stamper. El stamper cierra el stream asignado
                Dim ms2 As New MemoryStream(ms.ToArray())

                'copiar a un archivo
                'Dim fs As New FileStream("d:\salidapdf.pdf", System.IO.FileMode.Create)
                'ms2.CopyTo(fs)
                'fs.Close()

                'Destruir el stream
                ms.Dispose()
                'reasignar el nuevo stream
                _file.Dispose()
                _file = ms2

                'ms.Close()
                reader.Close()

            End If
        End Sub

        Public Sub New(ByVal name As String, ByVal filename As String, Optional ByVal content_type As String = "", Optional ByVal length As Integer = 0)
            _name = name
            _filename = filename
            _length = length

            If content_type = "" Then
                Dim ext As String = System.IO.Path.GetExtension(filename)
                Select Case ext.ToLower()
                    Case ".pdf"
                        content_type = "application/pdf"
                    Case ".xml"
                        content_type = "application/xml"
                    Case Else
                        content_type = ""
                End Select
            End If
            _content_type = content_type
            Signatures = New List(Of tnvSignature)
            PDFEncryption = nvPDFEncryption.not_encrypted
        End Sub

        Public Sub close()
            _file.Dispose()
            ' PDFSingnatures.Clear()
        End Sub
        Public ReadOnly Property name
            Get
                Return _name
            End Get
        End Property

        Public ReadOnly Property length As Long
            Get
                Try
                    Return _file.Length
                Catch ex As Exception

                End Try
                Return 0
            End Get
        End Property

        Public Sub load(ByVal path As String)
            Dim fs As FileStream = New FileStream(path, System.IO.FileMode.Open)
            Dim buffer(fs.Length - 1) As Byte
            Dim count As Integer

            count = fs.Read(buffer, 0, fs.Length)

            _file = New MemoryStream(buffer, True)
            fs.Close()
        End Sub
        Public Sub load(ByRef bytes() As Byte)
            _file = New MemoryStream(bytes)
        End Sub
        Public Sub load(ByRef mstream As MemoryStream)
            _file = mstream
        End Sub
        Public Sub load(ByRef fstream As FileStream)
            _file = New MemoryStream(fstream.ReadByte())
        End Sub
        Public Sub saveToFile(filename As String)
            Dim fs As New System.IO.FileStream(filename, FileMode.Create)
            fs.Write(bytes, 0, bytes.Length)
            fs.Close()
        End Sub

        Public Sub sign(ByRef oSign As tnvSignature, ByVal myCertificate As X509Certificate2)

            If bytes.Length = 0 Then
                Return
            End If

            Dim PDFSignParam As tnvPDFSignParam = oSign.PDFSignParams
            'Dim oSign As nvSignature = New nvSignature(name, use, PDFSignParam)
            '*************************************************'
            'Aca se firma el documento
            '*************************************************'
            'Identificar el formato del documento
            If Path.GetExtension(_filename).ToLower() = ".pdf" Or _content_type.ToLower() = "application/pdf" Then
                Dim ms2 As New MemoryStream(nvPDFUtil.signDocument(bytes, oSign, myCertificate))
                'reasignar el nuevo stream
                _file.Dispose()
                _file = ms2
                'Agregan la firma a la coleccion
                Signatures.Add(oSign)
            ElseIf Path.GetExtension(_filename).ToLower() = ".xml" Or _content_type.ToLower() = "application/xml" Then


                Dim doc As System.Xml.XmlDocument = New System.Xml.XmlDocument()
                Dim xmlReader = New System.Xml.XmlTextReader(_file)
                xmlReader.MoveToContent()
                doc.LoadXml(xmlReader.ReadOuterXml())

                Dim signer As nvXMLSigned = New nvXMLSigned(doc, "a", "signatureProperties")
                signer.SigningKey = myCertificate.PrivateKey

                ' create a timestamp property
                Dim timestamp As System.Xml.XmlElement = doc.CreateElement("TimeStamp", "http://www.example.org/#signatureProperties")
                timestamp.InnerText = DateTime.Now.ToUniversalTime().ToString()
                signer.AddProperty(timestamp)

                ' create a signed by property
                'Dim signedBy As System.Xml.XmlElement = doc.CreateElement("SignedBy", "http://www.example.org/#signatureProperties")
                '    signedBy.InnerText = new WindowsPrincipal(WindowsIdentity.GetCurrent()).Identity.Name;
                '    signer.AddProperty(signedBy);

                Dim orderRef As Xml.Reference = New Xml.Reference("") 'todo el xml
                orderRef.AddTransform(New Xml.XmlDsigEnvelopedSignatureTransform())
                signer.AddReference(orderRef)

                signer.ComputeSignature()
                Dim xmlDigitalSignature As System.Xml.XmlElement = signer.GetXml()

                ' borrar esto
                doc.DocumentElement.AppendChild(signer.GetXml())
                doc.Save("D:\order-signed.xml")

                oSign.setSign(New System.Text.UTF8Encoding().GetBytes(xmlDigitalSignature.OuterXml), Now(), myCertificate)
                Signatures.Add(oSign)

            Else

                Select Case myCertificate.PrivateKey.GetType.ToString
                    Case "System.Security.Cryptography.RSACryptoServiceProvider"
                        Dim RSA As RSACryptoServiceProvider = DirectCast(myCertificate.PrivateKey, RSACryptoServiceProvider)
                        Dim signBytes() As Byte
                        signBytes = RSA.SignData(bytes, oSign.hashAlgorithm.ToString)
                        oSign.setSign(signBytes, Now(), myCertificate)

                    Case "System.Security.Cryptography.DSACryptoServiceProvider"
                        Dim DSA As DSACryptoServiceProvider = DirectCast(myCertificate.PrivateKey, DSACryptoServiceProvider)
                        Dim signBytes() As Byte
                        signBytes = DSA.SignData(bytes)
                        oSign.setSign(signBytes, Now(), myCertificate)

                End Select

                'Agregan la firma a la coleccion
                Signatures.Add(oSign)

            End If

        End Sub
        'Public Sub sign(ByVal name As String, ByVal use As nvSignUse, ByVal PDFSignParam As nvPDFSignParam, ByVal myCertificate As X509Certificate2)
        '    Dim oSign As nvSignature = New nvSignature(Me, name, use, PDFSignParam)
        '    sign(oSign, myCertificate)
        'End Sub

        'Public Sub sign(ByVal name As String, ByVal use As nvSignUse, ByVal myCertificate As X509Certificate2)
        '    Dim oSign As nvSignature = New nvSignature(Me, name, use)
        '    sign(oSign, myCertificate)
        'End Sub


        Public Function verifyPDFSign() As List(Of String)
            Dim res As New List(Of String)

            'Abrir el PDF
            Dim myPdfReader As New iTextSharp.text.pdf.PdfReader(bytes)
            Dim af As iTextSharp.text.pdf.AcroFields = myPdfReader.AcroFields
            Dim names As List(Of String) = af.GetSignatureNames()
            Dim name As String

            For Each name In names
                'Valida si la firma cubre todo el documento
                If (Not af.SignatureCoversWholeDocument(name)) Then
                    res.Add(String.Format("La firma: {0} no cubre todo el documento.", name))
                End If

                Dim pk As iTextSharp.text.pdf.security.PdfPKCS7 = af.VerifySignature(name)
                Dim cal As Date = pk.SignDate
                Dim pkc() As Org.BouncyCastle.X509.X509Certificate = pk.Certificates

                If (Not pk.Verify()) Then
                    res.Add(String.Format("La firma: {0} no pudo ser verificada.", name))
                End If
                If (Not pk.VerifyTimestampImprint()) Then
                    res.Add(String.Format("La firma de tiempo : {0} no pudo ser verificada.", name))
                    'Throw New InvalidOperationException("The signature timestamp could not be verified.")
                End If

                Dim fails As List(Of iTextSharp.text.pdf.security.VerificationException) = iTextSharp.text.pdf.security.CertificateVerification.VerifyCertificates(pkc, New Org.BouncyCastle.X509.X509Certificate() {pk.SigningCertificate}, Nothing, cal)
                If (Not fails Is Nothing) Then
                    'res.Add(String.Format("La firma: {0} no pudo ser verificada.", name))
                    'Throw New InvalidOperationException("The file is not signed using the specified key-pair.")
                End If

                Dim fail As iTextSharp.text.pdf.security.VerificationException
                For Each fail In fails
                    res.Add(String.Format("La firma: {0}. " & fail.Message, name))
                Next
            Next

            Return res
        End Function

        Public Function getSingsFromSignatoriID(ByVal subjectname As String) As List(Of nvFW.tnvSignature)
            Dim res As New List(Of nvFW.tnvSignature)
            For i = 0 To Signatures.Count - 1
                If (Signatures(i).signatoryID = "") Then
                    Continue For
                End If

                If Signatures(i).isSignatory(subjectname, Signatures(i).signatoryID) Then
                    res.Add(Signatures(i))
                End If
            Next
            Return res
        End Function

        Public Function isRequesterID(ByVal subjectname As String) As Boolean
            Try

                Dim requesterID As String = metadataRequest("requesterID")

                Dim s() As String = subjectname.ToString.Split(",")
                Dim cn As New Dictionary(Of String, String)
                For i = 0 To s.Count - 1
                    cn.Add(Trim(s(i).Split("=")(0)), s(i).Split("=")(1))
                Next

                s = requesterID.ToString.Split(",")
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

        Public Function isRequerido() As Boolean
            Dim res As Boolean = False

            If (_metadatarequest.ContainsKey("requerido")) Then
                res = IIf(_metadatarequest("requerido").ToLower() = "true", True, False)
            End If

            Return res

        End Function


        Public Function getFileSignaturesNames() As List(Of String)

            ' Obtener la lista de firmas del documento
            Dim names As List(Of String) = Nothing
            If _content_type = "application/pdf" Then
                Dim reader As PdfReader = New PdfReader(_file.ToArray())
                Dim fields As AcroFields = reader.AcroFields
                names = fields.GetSignatureNames()
                Return names
            End If
            Return names
        End Function



        Public Function verifyFileSignatures(Optional pkiObj As tnvPKI = Nothing, Optional revocationMethod As nvFW.enumnvRevocationOptions = enumnvRevocationOptions.OCSP_OPTIONAL_CRL) As Dictionary(Of String, tnvSignVerifyStatus)

            'valida firma y certificados 
            ' TODO: falta comprobar en la my
            If _content_type = "application/pdf" Then
                Dim res As Dictionary(Of String, tnvSignVerifyStatus) = nvSignatureVerify.verifyPDFSignatures(bytes, pkiObj, revocationMethod)
                Return res
            ElseIf _content_type = "application/xml" Or _content_type = "text/xml" Then
                Dim res As Dictionary(Of String, tnvSignVerifyStatus) = nvSignatureVerify.verifyXMLSignatures(bytes, pkiObj, Nothing, revocationMethod)
                Return res
            Else
                Throw New Exception("No se pueden analizar las firmas del documento porque no se conoce su formato")
            End If

        End Function
    End Class

   
End Namespace
