Imports Microsoft.VisualBasic

Namespace nvFW
    Public Class nvSignatureVerify
        Public Shared Function verifyBINSignatures(bytes As Byte(), pki As nvFW.tnvPKI, signatureBin() As Byte, Optional signatureCert As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing) As Dictionary(Of String, tnvSignVerifyStatus)
            Return Nothing
        End Function

        Public Shared Function verifyXMLSignatures(bytes As Byte(), pki As nvFW.tnvPKI, Optional signatureCert As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing, Optional revocationMethod As nvFW.enumnvRevocationOptions = enumnvRevocationOptions.OCSP_OPTIONAL_CRL) As Dictionary(Of String, tnvSignVerifyStatus)

            Dim res As New Dictionary(Of String, tnvSignVerifyStatus)

            ' Leer XML
            Dim doc As System.Xml.XmlDocument = New System.Xml.XmlDocument()
            doc.PreserveWhitespace = True
            Dim xmlReader = New System.Xml.XmlTextReader(New IO.MemoryStream(bytes))
            xmlReader.MoveToContent()
            doc.LoadXml(xmlReader.ReadOuterXml())
            If doc Is Nothing Then
                Throw New ArgumentException("No se pudo parsear el documento xml.")
            End If

            ' Crear el SignedXml object y pasarle el documento
            Dim nodeList As System.Xml.XmlNodeList = doc.GetElementsByTagName("Signature")
            If nodeList.Count <= 0 Then
                Throw New System.Security.Cryptography.CryptographicException("Verificacion fallida. El documento no tiene firma/s.")
            End If


            Dim signedXml As New System.Security.Cryptography.Xml.SignedXml(doc)
            For i As Integer = 0 To nodeList.Count - 1

                Dim SignVerifyStatus As New tnvSignVerifyStatus

                ' Check the signature and return the result.
                signedXml.LoadXml(CType(nodeList(i), System.Xml.XmlElement))


                '************* signatureIntegrity*********************************************************
                If signatureCert Is Nothing Then
                    ' Obtener el certificado de la firma si no se lo envió como parametro
                    Dim x509data = signedXml.Signature.KeyInfo.OfType(Of System.Security.Cryptography.Xml.KeyInfoX509Data).First()
                    If x509data Is Nothing Then
                        Throw New Exception("No se pudo leer el certificado asociado a la firma " & signedXml.Signature.Id)
                    End If
                    signatureCert = x509data.Certificates(0)
                    If signatureCert Is Nothing Then
                        Throw New Exception("Error parseando el certificado asociado a la firma " & signedXml.Signature.Id)
                    End If

                    ' Verifica sólo la firma y no el certificado.
                    ' Poniendo el segundo argumento en false verifica el certificado contra el store my del sistema
                    SignVerifyStatus.signatureIntegrity = signedXml.CheckSignature(signatureCert, True)
                Else
                    ' verifica la firma a partir del certificado que viene embebido en el xml
                    SignVerifyStatus.signatureIntegrity = signedXml.CheckSignature
                End If

                If SignVerifyStatus.signatureIntegrity Then
                    SignVerifyStatus.signatureIntegrity = True
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = String.Format("El documento no ha sido modificado luego de la firma.", signedXml.Signature.Id)
                    SignVerifyStatus.statusmsg.Add(msg)
                Else
                    SignVerifyStatus.signatureIntegrity = False
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = String.Format("El documento ha sido modificado luego de la firma.", signedXml.Signature.Id)
                    SignVerifyStatus.statusmsg.Add(msg)
                End If

                res.Add(signedXml.Signature.Id, SignVerifyStatus)

            Next
            Return res

        End Function




        Public Shared Function verifyPDFSignatures(bytesOfPDFFile As Byte(), pki As nvFW.tnvPKI,
                                                   Optional revocationMethod As nvFW.enumnvRevocationOptions = enumnvRevocationOptions.OCSP_OPTIONAL_CRL
                                                   ) As Dictionary(Of String, tnvSignVerifyStatus)

            ' Lista de firmas
            Dim res As New Dictionary(Of String, tnvSignVerifyStatus)

            Dim myPdfReader As iTextSharp.text.pdf.PdfReader
            Try
                myPdfReader = New iTextSharp.text.pdf.PdfReader(bytesOfPDFFile)
            Catch ex As Exception
                Return res
            End Try

            Dim af As iTextSharp.text.pdf.AcroFields = myPdfReader.AcroFields
            Dim names As List(Of String) = af.GetSignatureNames()
            Dim name As String

            Dim certifiedSignatures As New List(Of String)
            ' Recorrer firmas
            For Each name In names
                Dim SignVerifyStatus As New tnvSignVerifyStatus
                SignVerifyStatus.pkiName = pki.description
                Dim pk As iTextSharp.text.pdf.security.PdfPKCS7 = af.VerifySignature(name)
                'Dim pkc() As Org.BouncyCastle.X509.X509Certificate = pk.SignCertificateChain
                Dim cal As Date = pk.SignDate

                'si es una firma timestamp a nivel de documentos: por ahora se las omite
                If pk.IsTsp Then
                    ' Chequear:
                    ' - Integridad
                    '  - cubre todo el doc
                    Continue For
                End If


                'Valida si la firma cubre todo el documento
                If (Not af.SignatureCoversWholeDocument(name)) Then
                    SignVerifyStatus.signatureAllDocument = False
                Else
                    SignVerifyStatus.signatureAllDocument = True
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                End If

                'Valida el nivel de certificación del documento
                SignVerifyStatus.PDF_certificationLevel = nvPDFCertificationLevel.not_certified
                Dim a As iTextSharp.text.pdf.security.SignaturePermissions = New iTextSharp.text.pdf.security.SignaturePermissions(af.GetSignatureDictionary(name), Nothing)
                If a.Certification Then

                    'If Not a.FillInAllowed And Not a.AnnotationsAllowed Then
                    If Not a.FillInAllowed Then
                        SignVerifyStatus.PDF_certificationLevel = nvPDFCertificationLevel.not_change_allowed
                    ElseIf Not a.AnnotationsAllowed Then
                        SignVerifyStatus.PDF_certificationLevel = nvPDFCertificationLevel.form_filling_allowed
                    Else
                        SignVerifyStatus.PDF_certificationLevel = nvPDFCertificationLevel.form_filling_and_anotation_allowed
                    End If

                    ' agregar a lista de firmas certificadas ...
                    certifiedSignatures.Add(name)

                End If

                'Evaluar que tenga campos de formularios
                'FIELD_TYPE_NONE = 0
                'FIELD_TYPE_PUSHBUTTON = 1;
                'FIELD_TYPE_CHECKBOX = 2;
                'FIELD_TYPE_RADIOBUTTON = 3;
                'FIELD_TYPE_TEXT = 4;
                'FIELD_TYPE_LIST = 5;
                'FIELD_TYPE_COMBO = 6;
                'FIELD_TYPE_SIGNATURE = 7; 
                Dim listFieldFormTypes As New List(Of Integer)
                listFieldFormTypes.Add(1)
                listFieldFormTypes.Add(2)
                listFieldFormTypes.Add(3)
                listFieldFormTypes.Add(4)
                listFieldFormTypes.Add(5)
                listFieldFormTypes.Add(6)
                Dim containsFormField As Boolean = False
                For Each field In af.Fields.Keys
                    If listFieldFormTypes.Contains(af.GetFieldType(field)) Then
                        containsFormField = True
                        Exit For
                    End If
                Next


                ' Si la firma es not_certified: AnnotationsAllowed y FillInAllowed son siempre true
                If Not a.Certification Or (a.Certification And a.AnnotationsAllowed) Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = String.Format("La firma permite el agregado de anotaciones.", name)
                    SignVerifyStatus.statusmsg.Add(msg)
                End If

                If a.FillInAllowed And containsFormField Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = String.Format("La firma permite el relleno de campos de formulario.", name)
                    SignVerifyStatus.statusmsg.Add(msg)
                End If




                ' firma valida
                If SignVerifyStatus.PDF_certificationLevel = nvPDFCertificationLevel.not_change_allowed Then
                    Dim docChanged As Boolean = False
                    If Not af.SignatureCoversWholeDocument(name) Then
                        docChanged = True
                    End If
                    SignVerifyStatus.signatureIntegrity = Not docChanged And pk.Verify()
                Else
                    SignVerifyStatus.signatureIntegrity = pk.Verify()
                End If



                If (SignVerifyStatus.signatureIntegrity) Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = String.Format("El documento no ha sido modificado luego de la firma.", name)
                    SignVerifyStatus.statusmsg.Add(msg)
                Else
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = String.Format("Se han realizado cambios que anulan la firma", name)
                    SignVerifyStatus.statusmsg.Add(msg)
                End If





                'Timestamp
                SignVerifyStatus.useTimestam = False
                If Not pk.TimeStampToken Is Nothing Then
                    SignVerifyStatus.useTimestam = True
                    Dim tsa = pk.TimeStampToken.TimeStampInfo.Tsa.Name.ToString
                    'pk.TimeStampToken.GetCertificates()
                    'pk.TimeStampToken.GetCrls()
                    'pk.TimeStampToken.ToCmsSignedData.

                    'pk.TimeStampToken.Validate(CERTSA)

                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = String.Format("La fecha de la firma fue suministrada por '{0}'", tsa)
                    SignVerifyStatus.statusmsg.Add(msg)
                Else
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = String.Format("La fecha de la firma fue tomada del equipo local.")
                    SignVerifyStatus.statusmsg.Add(msg)

                End If



                ' CRLs y OCSP responses agregadas en el DSS del pdf
                Dim dssCRLs As New List(Of Org.BouncyCastle.X509.X509Crl)
                dssCRLs = getCRLsFromDSS(myPdfReader)
                Dim dssOCSP As New List(Of Org.BouncyCastle.Ocsp.BasicOcspResp)
                dssOCSP = GetOCSPResponsesFromDSS(myPdfReader)


                Dim CRLs As New List(Of Org.BouncyCastle.X509.X509Crl)
                For Each crl In pk.CRLs
                    If Not crl Is Nothing Then
                        CRLs.Add(crl)
                    End If
                Next

                For Each crl In dssCRLs
                    If Not crl Is Nothing Then
                        CRLs.Add(crl)
                    End If
                Next




                SignVerifyStatus.IncludeCRLs = CRLs.Count > 0 Or dssCRLs.Count > 0
                'If pk.CRLs.Count > 0 Then
                '    SignVerifyStatus.IncludeCRLs = True
                '    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                '    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                '    msg.mesage = String.Format("La lista de revocación se encuentra dentro de la firma")
                '    SignVerifyStatus.statusmsg.Add(msg)
                'End If

                SignVerifyStatus.IncludeOCSPResponse = Not pk.Ocsp Is Nothing Or dssOCSP.Count > 0
                'If Not pk.Ocsp Is Nothing Then
                '    SignVerifyStatus.IncludeOCSPResponse = True
                '    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                '    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                '    msg.mesage = String.Format("La conulta de revovación online se encuentra dentro de la firma")
                '    SignVerifyStatus.statusmsg.Add(msg)
                'End If

                ' validar que la fecha de la firma este dentro del intervalo de validez del certificado
                Dim isValidInDate As Boolean = False
                Try
                    pk.SigningCertificate.CheckValidity(cal)
                    isValidInDate = True
                Catch ex As Org.BouncyCastle.Security.Certificates.CertificateExpiredException
                    isValidInDate = False
                    'El certificado se encontraba expirado cuando se efectuó la firma
                Catch ex As Org.BouncyCastle.Security.Certificates.CertificateNotYetValidException
                    'El certificado aún no era válido cuando se efectuo la firma
                    isValidInDate = False
                End Try
                If Not isValidInDate Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = String.Format("El certificado no es válido para la fecha de la firma", name)
                    SignVerifyStatus.statusmsg.Add(msg)
                End If

                ' chequeo de revocacion: usando los puntos de distribucion del certificado o en su defecto las ocsp respones y crl lists embebidas en el PDF 
                Dim OCSPResponse As Org.BouncyCastle.Ocsp.BasicOcspResp = pk.Ocsp
                If OCSPResponse Is Nothing Then
                    If dssOCSP.Count > 0 Then
                        OCSPResponse = dssOCSP(0)
                    End If
                End If

                Dim isRevoked As nveunmRevokeStatus = certIsRevoked(SignVerifyStatus, pk.SigningCertificate, pki, cal, revocationMethod, CRLs, OCSPResponse)
                SignVerifyStatus.isRevoked = isRevoked
                SignVerifyStatus.validSignatureDate = isValidInDate And isRevoked = nveunmRevokeStatus.norevoke


                Dim includeRoot As Boolean
                Dim chainElement As List(Of Org.BouncyCastle.X509.X509Certificate) = pki.getChainElement(pk.SigningCertificate, includeRoot)
                SignVerifyStatus.setSignElement(pk.SigningCertificate, chainElement, CRLs, OCSPResponse, pk.SignDate)


                'Identificamos si el firmante es el usaurio actual de la PKI
                SignVerifyStatus.isMyCertificate = pki.certIsMy(pk.SigningCertificate)
                If SignVerifyStatus.isMyCertificate Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = String.Format("Firmado por el usuario actual", name)
                    SignVerifyStatus.statusmsg.Add(msg)
                End If

                SignVerifyStatus.trusedCertificate = pki.certIsTrusted(pk.SigningCertificate)

                'SignVerifyStatus.trustedChain = isTrustedChain(pk.SigningCertificate, pki)
                'If Not SignVerifyStatus.trustedChain Then
                SignVerifyStatus.trustedChain = includeRoot
                If Not includeRoot Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "El certificado del firmante no fué emitido por una entidad de confianza"
                    SignVerifyStatus.statusmsg.Add(msg)
                End If

                SignVerifyStatus.isKnownCertificate = pki.certIsKnown(pk.SigningCertificate)


                '/****************************************************/
                '                   Verificar LTV
                'Debe tener las listas CRL o una respuesta OCSP
                'Tambien debe contener los certificados que se utilizan, es decir la cadena completa del firmante 
                'mas los certificados del OCSP y sellos de tiempo
                '/****************************************************/

                SignVerifyStatus.isLTV = False
                Dim chainIncludeRoot As Boolean
                Dim chain As List(Of Org.BouncyCastle.X509.X509Certificate) = getChain(pk.SigningCertificate, pk.SignCertificateChain, chainIncludeRoot)

                Dim includeOCSPCert As Boolean = False
                If Not OCSPResponse Is Nothing Then
                    Dim certOCSP As Org.BouncyCastle.X509.X509Certificate
                    certOCSP = getCertFromList(OCSPResponse.GetCerts(0).SubjectDN.ToString, pk.Certificates)
                    includeOCSPCert = Not certOCSP Is Nothing
                End If

                SignVerifyStatus.isLTV = (SignVerifyStatus.IncludeCRLs Or (SignVerifyStatus.IncludeOCSPResponse And includeOCSPCert)) And chainIncludeRoot
                If Not SignVerifyStatus.isLTV Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = "La firma no está activada para LTV"
                    SignVerifyStatus.statusmsg.Add(msg)
                Else
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.info
                    msg.mesage = "La firma está activada para LTV"
                    SignVerifyStatus.statusmsg.Add(msg)
                End If


                '/****************************************************/
                ' Info de appereance
                '/****************************************************/
                SignVerifyStatus.location = pk.Location
                SignVerifyStatus.reason = pk.Reason


                res.Add(name, SignVerifyStatus)

            Next


            ' Solo se admite una sola firma certificada, 
            If certifiedSignatures.Count > 1 Then
                certifiedSignatures.Remove(certifiedSignatures.Last)
                For Each name In certifiedSignatures
                    res(name).signatureIntegrity = False
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = String.Format("Se ha anulado la firma certificada: una nueva firma certificada ha sido agregada posteriormente", name)
                    res(name).statusmsg.Add(msg)
                Next
            End If


            Return res
        End Function
        Public Shared Function getChain(initialcert As Org.BouncyCastle.X509.X509Certificate, certs() As Org.BouncyCastle.X509.X509Certificate, ByRef includeRoot As Boolean) As List(Of Org.BouncyCastle.X509.X509Certificate)
            Dim res As New List(Of Org.BouncyCastle.X509.X509Certificate)
            res.Add(initialcert)
            includeRoot = False
            Dim cert As Org.BouncyCastle.X509.X509Certificate = initialcert
            Dim issueCert As Org.BouncyCastle.X509.X509Certificate = getCertFromList(cert.IssuerDN.ToString, certs)

            While Not issueCert Is Nothing
                Try
                    cert.Verify(issueCert.GetPublicKey)
                    res.Add(issueCert)
                    cert = issueCert
                    issueCert = getCertFromList(cert.IssuerDN.ToString, certs)
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

        Public Shared Function getCertFromList(subjectDN As String, lista() As Org.BouncyCastle.X509.X509Certificate) As Org.BouncyCastle.X509.X509Certificate
            For Each cert In lista
                If cert.SubjectDN.ToString = subjectDN Then
                    Return cert
                End If
            Next
            Return Nothing
        End Function




        Public Shared Function verifyPDFSignatures(stream As System.IO.MemoryStream, pki As nvFW.tnvPKI, Optional revocationMethod As nvFW.enumnvRevocationOptions = enumnvRevocationOptions.OCSP_OPTIONAL_CRL) As Dictionary(Of String, tnvSignVerifyStatus)
            Return verifyPDFSignatures(stream.ToArray, pki, revocationMethod)
        End Function

        Public Shared Function verifyPDFSignatures(filename As String, pki As nvFW.tnvPKI, Optional revocationMethod As nvFW.enumnvRevocationOptions = enumnvRevocationOptions.OCSP_OPTIONAL_CRL) As Dictionary(Of String, tnvSignVerifyStatus)
            Dim fs As New System.IO.FileStream(filename, IO.FileMode.Open)
            Dim buffer(fs.Length - 1) As Byte
            fs.Read(buffer, 0, fs.Length)
            Return verifyPDFSignatures(buffer, pki, revocationMethod)
        End Function



        Public Shared Function certIsRevoked(SignVerifyStatus As tnvSignVerifyStatus, cert As Org.BouncyCastle.X509.X509Certificate, pki As nvFW.tnvPKI, [date] As Date, Optional revocationMethod As enumnvRevocationOptions = enumnvRevocationOptions.OCSP_OPTIONAL_CRL, Optional ByRef CRLs As System.Collections.Generic.ICollection(Of Org.BouncyCastle.X509.X509Crl) = Nothing, Optional ByRef OCSPResponse As Org.BouncyCastle.Ocsp.BasicOcspResp = Nothing) As nveunmRevokeStatus
            'Obtener certificado de la autorida emisora
            'Dim PP As Org.BouncyCastle.X509.Store.X509CollectionStoreParameters = New Org.BouncyCastle.X509.Store.X509CollectionStoreParameters(pki.getTrustedCertsList)
            'Dim st1 As Org.BouncyCastle.X509.Store.IX509Store = Org.BouncyCastle.X509.Store.X509StoreFactory.Create("CERTIFICATE/COLLECTION", PP)
            'Dim certSelect As Org.BouncyCastle.X509.Store.X509CertStoreSelector = New Org.BouncyCastle.X509.Store.X509CertStoreSelector()
            'certSelect.Subject = cert.IssuerDN
            'Dim resCol As ICollection = st1.GetMatches(certSelect)
            'Dim issuerCert As Org.BouncyCastle.X509.X509Certificate = pki.getCertByName(cert.IssuerDN.ToString)


            Dim CRL_URL As String
            Dim OCSP_URL As String
            Dim hasOCSP As Boolean = False
            OCSP_URL = iTextSharp.text.pdf.security.CertificateUtil.GetOCSPURL(cert)
            If Not OCSPResponse Is Nothing Or Not OCSP_URL Is Nothing Then
                hasOCSP = True
            End If

            Dim hasCRL As Boolean = Not CRLs Is Nothing
            CRL_URL = iTextSharp.text.pdf.security.CertificateUtil.GetCRLURL(cert)
            If Not CRLs Is Nothing Or Not CRL_URL Is Nothing Then
                hasCRL = True
            End If

            Select Case revocationMethod
                Case enumnvRevocationOptions.CRL
                    If Not hasCRL Then
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se pudo comprobar revocación porque el certificado no dispone de puntos de distribución de CRLs y la firma no contiene una CRL"
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck
                    End If
                    Return certIsRevokedByCrl(SignVerifyStatus, cert, CRLs, pki, [date])

                Case enumnvRevocationOptions.OCSP
                    If Not hasOCSP Then
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se pudo comprobar revocación porque el certificado no especifica OCSP."
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck
                    End If
                    Return certIsRevokedByOcsp(SignVerifyStatus, cert, OCSPResponse, pki, [date])
                Case enumnvRevocationOptions.OCSP_OPTIONAL_CRL
                    If hasOCSP Then
                        Return certIsRevokedByOcsp(SignVerifyStatus, cert, OCSPResponse, pki, [date])
                    ElseIf hasCRL Then
                        Return certIsRevokedByCrl(SignVerifyStatus, cert, CRLs, pki, [date])
                    Else
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se pudo comprobar revocación porque el certificado no especifica información de CRL ni OCSP."
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck
                    End If

                Case enumnvRevocationOptions.OCSP_FAIL_CRL
                    Dim res As nveunmRevokeStatus
                    If hasOCSP Then
                        res = certIsRevokedByOcsp(SignVerifyStatus, cert, OCSPResponse, pki, [date])
                    End If
                    If res <> nveunmRevokeStatus.errorCheck Then
                        Return res
                    End If
                    SignVerifyStatus.statusmsg.RemoveAt(SignVerifyStatus.statusmsg.Count - 1)
                    If hasCRL Then
                        Return certIsRevokedByCrl(SignVerifyStatus, cert, CRLs, pki, [date])
                    Else
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se pudo comprobar revocación porque el certificado no especifica información de CRL ni OCSP."
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck
                    End If

            End Select

        End Function

        Public Shared Function getCRL(ByVal Url As String) As Org.BouncyCastle.X509.X509Crl
            Dim crl As Org.BouncyCastle.X509.X509Crl
            Dim httprequest As New nvHTTPRequest
            httprequest.url = Url
            Dim response As System.Net.HttpWebResponse
            Try
                response = httprequest.getResponse()
                Dim st As System.IO.Stream = response.GetResponseStream()
                Dim buffer(response.ContentLength) As Byte
                st.Read(buffer, 0, response.ContentLength)
                Dim crlParser As Org.BouncyCastle.X509.X509CrlParser = New Org.BouncyCastle.X509.X509CrlParser
                crl = crlParser.ReadCrl(buffer)
            Catch ex As Exception
                'Throw New Exception("No se puede comprobar la revocación del certificado porque no se pudo acceder al servidor de revocación.")
            End Try
            Return crl
        End Function

        Private Shared Function certIsRevokedByCrl(SignVerifyStatus As tnvSignVerifyStatus, cert As Org.BouncyCastle.X509.X509Certificate, ByRef CRLs As System.Collections.Generic.ICollection(Of Org.BouncyCastle.X509.X509Crl), PKI As tnvPKI, [date] As Date) As nveunmRevokeStatus
            If CRLs Is Nothing Then
                CRLs = New List(Of Org.BouncyCastle.X509.X509Crl)
            End If
            If CRLs.Count = 0 Then
                CRLs = New List(Of Org.BouncyCastle.X509.X509Crl)
                'Dim chain As System.Security.Cryptography.X509Certificates.X509Chain = PKI.getChain(cert)

                Dim includeRoot As Boolean = False
                Dim chain As List(Of Org.BouncyCastle.X509.X509Certificate) = PKI.getChainElement(cert, includeRoot)

                'If chain Is Nothing Then
                If Not includeRoot Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "No se pudo construir la cadena de certifficados para validar su confianza."
                    SignVerifyStatus.statusmsg.Add(msg)
                    Return nveunmRevokeStatus.errorCheck
                End If
                Dim errorDescarga As Boolean = False

                For i = 0 To chain.Count - 2
                    Dim elCert As Org.BouncyCastle.X509.X509Certificate = chain(i)
                    'For i = 0 To chain.ChainElements.Count - 2
                    'Dim elCert As Org.BouncyCastle.X509.X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(chain.ChainElements(i).Certificate)
                    Dim CRL_URL As String = iTextSharp.text.pdf.security.CertificateUtil.GetCRLURL(elCert)
                    Dim crl As Org.BouncyCastle.X509.X509Crl = getCRL(CRL_URL)
                    If crl Is Nothing Then
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se puede comprobar el estado de revocación del certificado. No se pudo descargar la lista de revocación"
                        SignVerifyStatus.statusmsg.Add(msg)
                        errorDescarga = True
                    Else
                        CRLs.Add(crl)
                    End If
                Next
                If errorDescarga Then
                    Return nveunmRevokeStatus.errorCheck
                End If
            End If

            For Each crl In CRLs
                Dim issuerCert As Org.BouncyCastle.X509.X509Certificate = PKI.getCertByName(crl.IssuerDN.ToString)
                If issuerCert Is Nothing Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "No se pudo encontrar el certificado de la autoridad intermedia necesario para comporbar la revocación del certificado."
                    SignVerifyStatus.statusmsg.Add(msg)
                    Return nveunmRevokeStatus.errorCheck 'no se pudo encontrar el Issuer del certificado (que debe ser el issuer de la crl) por lo que no se podrá comprobar la firma de la crl
                End If
                ' la crl debe estar firmada por la autorida emisora
                Dim isSignedbyCA = verifyCRLSign(crl, issuerCert)
                If Not isSignedbyCA Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "No se puede comprobar el estado de revocación del certificado. La lista de revocación no esta firmada por el emisor del certificado."
                    SignVerifyStatus.statusmsg.Add(msg)
                    Return nveunmRevokeStatus.errorCheck
                End If

                'La fecha de la lista de revocación debe ser posterior a la firma y menor que la fecha de expiración del certificado
                'La fecha de la CRL es válida hasta la pro
                'crl.NextUpdate
                'Dim crlDate As Date = DateAdd(DateInterval.Day, 1, crl.ThisUpdate)

                If crl.NextUpdate.Value < [date] Or crl.ThisUpdate > cert.NotAfter Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "No se puede comprobar el estado de revocación del certificado. La lista de revocación esta fuera del período de consulta válido. Fecha de consulta '" & [date].ToString("dd/MM/yyyy hh:mm:ss") & "' válido desde '" & crl.ThisUpdate.ToString("dd/MM/yyyy hh:mm:ss") & "' hasta '" & crl.NextUpdate.Value.ToString("dd/MM/yyyy hh:mm:ss") & "'."
                    SignVerifyStatus.statusmsg.Add(msg)
                    Return nveunmRevokeStatus.errorCheck
                End If


                Dim crl2 As Org.BouncyCastle.X509.X509CrlEntry = crl.GetRevokedCertificate(cert.SerialNumber)
                If Not crl2 Is Nothing Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "El certificado fué revocado el día " & crl2.RevocationDate.ToString("dd/MM/yyyy") & "."
                    SignVerifyStatus.statusmsg.Add(msg)
                    Return nveunmRevokeStatus.revoke
                End If
            Next

            Return nveunmRevokeStatus.norevoke

        End Function



        Private Shared Function certIsRevokedByOcsp(SignVerifyStatus As tnvSignVerifyStatus, cert As Org.BouncyCastle.X509.X509Certificate, ByRef OCSPResponse As Org.BouncyCastle.Ocsp.BasicOcspResp, PKI As tnvPKI, [date] As Date) As nveunmRevokeStatus
            Dim OCSPResponses As New List(Of Org.BouncyCastle.Ocsp.BasicOcspResp)
            'Si no viene la respuesta OCSP hacemos la consulta
            If OCSPResponse Is Nothing Then
                Dim ocspClient As iTextSharp.text.pdf.security.OcspClientBouncyCastle = New iTextSharp.text.pdf.security.OcspClientBouncyCastle()
                'Dim ocspResp As Org.BouncyCastle.Ocsp.BasicOcspResp
                'Dim elCert As Org.BouncyCastle.X509.X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(chain.ChainElements(i).Certificate)
                Dim OCSP_URL As String = iTextSharp.text.pdf.security.CertificateUtil.GetOCSPURL(cert)
                Dim issuerCert As Org.BouncyCastle.X509.X509Certificate = PKI.getCertByName(cert.IssuerDN.ToString)
                OCSPResponse = ocspClient.GetBasicOCSPResp(cert, issuerCert, OCSP_URL)
                If OCSPResponse Is Nothing Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "No se puede comprobar el estado de revocación del certificado. No se pudo obtener una respuesta del servidor OSCP."
                    SignVerifyStatus.statusmsg.Add(msg)
                    Return nveunmRevokeStatus.errorCheck
                Else
                    OCSPResponses.Add(OCSPResponse)
                End If


                'Dim chain As System.Security.Cryptography.X509Certificates.X509Chain = PKI.getChain(cert)
                'Dim errorDecarga As Boolean = False
                'For i = 0 To chain.ChainElements.Count - 2
                '    Dim ocspClient As iTextSharp.text.pdf.security.OcspClientBouncyCastle = New iTextSharp.text.pdf.security.OcspClientBouncyCastle()
                '    'Dim ocspResp As Org.BouncyCastle.Ocsp.BasicOcspResp
                '    Dim elCert As Org.BouncyCastle.X509.X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(chain.ChainElements(i).Certificate)
                '    Dim OCSP_URL As String = iTextSharp.text.pdf.security.CertificateUtil.GetOCSPURL(elCert)
                '    Dim issuerCert As Org.BouncyCastle.X509.X509Certificate = PKI.getCertByName(elCert.IssuerDN.ToString)
                '    OCSPResponse = ocspClient.GetBasicOCSPResp(cert, issuerCert, OCSP_URL)
                '    If OCSPResponse Is Nothing Then
                '        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                '        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                '        msg.mesage = "No se puede comprobar el estado de revocación del certificado. No se pudo obtener una respuesta del servidor OSCP ('" & elCert.IssuerDN.ToString & "')."
                '        SignVerifyStatus.statusmsg.Add(msg)
                '        errorDecarga = True
                '    Else
                '        OCSPResponses.Add(OCSPResponse)
                '    End If
                'Next
                'If errorDecarga Then
                '    Return nveunmRevokeStatus.errorCheck
                'End If
            Else
                For i = 0 To OCSPResponse.Responses.Count - 1
                    OCSPResponses.Add(OCSPResponse)
                Next
            End If
            For Each OCSPResponse In OCSPResponses
                'Varificar que la respuesta OCSP esté firmada por el emisor
                'Primero verificar que el certificado del firmante del OSCP sea emitido por una entidad de confianza
                'Luego comprobar que la respuesta OSCP esté firmada por el certificado que se comprobó
                Dim signOCSPCert As Org.BouncyCastle.X509.X509Certificate = OCSPResponse.GetCerts(0)
                Dim issuerCert As Org.BouncyCastle.X509.X509Certificate = PKI.getTrustedCertificateByName(signOCSPCert.IssuerDN.ToString())
                Dim isSignedbyCA As Boolean = False
                Dim isTrusted As Boolean = False
                If Not issuerCert Is Nothing Then
                    Try
                        signOCSPCert.Verify(issuerCert.GetPublicKey)
                        isTrusted = True
                    Catch ex As Exception
                    End Try

                    Dim key As Org.BouncyCastle.Crypto.AsymmetricKeyParameter = signOCSPCert.GetPublicKey
                    isSignedbyCA = OCSPResponse.Verify(key) And isTrusted
                End If

                If Not isSignedbyCA Then
                    Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                    msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                    msg.mesage = "No se puede comprobar el estado de revocación del certificado. La consulta OCSP no esta firmada por el emisor o no se confía en el mismo."
                    SignVerifyStatus.statusmsg.Add(msg)

                    Return nveunmRevokeStatus.errorCheck
                End If
                For Each resp As Org.BouncyCastle.Ocsp.SingleResp In OCSPResponse.Responses
                    'Validar que la respuesta OCSP pertenesca al certificado evaluado.
                    If resp.GetCertID().SerialNumber.ToString() <> cert.SerialNumber.ToString() Then
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se puede comprobar el estado de revocación del certificado. La consulta OCSP no pertenece al certificado evaluado. OCSP(SN='" & resp.GetCertID().SerialNumber.ToString() & "'), Certificado (SN='" & cert.SerialNumber.ToString() & "')"
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck
                    End If

                    'La fecha de la consulta OCSP debe ser posterior a la firma y menor que la fecha de expiración del certificado
                    If resp.NextUpdate.Value < [date] Or resp.ThisUpdate > cert.NotAfter Then
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se puede comprobar el estado de revocación del certificado. La consulta OCSP esta fuera del período de consulta válido. Fecha de consulta '" & [date].ToString("dd/MM/yyyy hh:mm:ss") & "' válido desde '" & resp.ThisUpdate.ToString("dd/MM/yyyy hh:mm:ss") & "' hasta '" & resp.NextUpdate.Value.ToString("dd/MM/yyyy hh:mm:ss") & "'."
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck
                    End If

                    'Controlar estado de revocación
                    Dim status As Object = resp.GetCertStatus
                    If status Is Org.BouncyCastle.Ocsp.CertificateStatus.Good Then
                        Return nveunmRevokeStatus.norevoke ' No Revocado
                    ElseIf TypeOf status Is Org.BouncyCastle.Ocsp.RevokedStatus Then
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "El certificado fué revocado el día '" & DirectCast(status, Org.BouncyCastle.Ocsp.RevokedStatus).RevocationTime.ToString("dd/MM/yyyy hh:mm:ss") & "'."
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.revoke ' Revocado
                    ElseIf TypeOf status Is Org.BouncyCastle.Ocsp.UnknownStatus Then
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se puede comprobar el estado de revocación del certificado. Respuesta OCSP desconocida"
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck 'desconocido
                    Else
                        Dim msg As New tnvSignVerifyStatus.tnvStatusMsg
                        msg.tipo = tnvSignVerifyStatus.enunvStatusMsgTipo.warning
                        msg.mesage = "No se puede comprobar el estado de revocación del certificado. Respuesta OCSP desconocida"
                        SignVerifyStatus.statusmsg.Add(msg)
                        Return nveunmRevokeStatus.errorCheck 'No deberia pasar
                    End If
                Next
            Next
            Return nveunmRevokeStatus.norevoke
        End Function



        Private Shared Function isTrustedChain(cert As Org.BouncyCastle.X509.X509Certificate, pki As nvFW.tnvPKI) As Boolean

            If Not pki.trustedRoot Then
                Return False
            End If

            Dim chain As System.Security.Cryptography.X509Certificates.X509Chain = pki.getChain(cert)
            If chain Is Nothing Then
                Return False
            End If
            Dim trustedChain As Boolean = True
            If chain.ChainElements.Count <= 1 Then
                trustedChain = False
            Else
                'El ultimo certificado de la cadena debe ser nuestro root
                Dim rootThumbprint As String = New System.Security.Cryptography.X509Certificates.X509Certificate2(Org.BouncyCastle.Security.DotNetUtilities.ToX509Certificate(pki.rootCert)).Thumbprint
                If chain.ChainElements(chain.ChainElements.Count - 1).Certificate.Thumbprint <> rootThumbprint Then
                    trustedChain = False
                    'Return New CertStatus(1, "No ha podido crearse una cadena de para el certificado específicado.") 'partialChain, no llegó al root
                Else
                    'Los certificados de la cadena deben pertener a nuestra pki 
                    'se omiten el primer y ultimo certificado (certificado a comprobar y raiz)
                    'Dim pki_thumbs As List(Of String) = getThumbs(ks)

                    For i As Integer = 1 To chain.ChainElements.Count - 2
                        If Not pki.certIsTrusted(chain.ChainElements(i).Certificate) Then 'Not pki_thumbs.Contains(chain.ChainElements(i).Certificate.Thumbprint) Then
                            trustedChain = False
                        End If
                    Next
                End If
            End If

            Return trustedChain
        End Function

        'Private Shared Function getThumbs(ks As List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)) As List(Of String)
        '    Dim res As List(Of String) = New List(Of String)
        '    For i As Integer = 0 To ks.Count - 1
        '        Dim thumb As String = ks(i).Thumbprint
        '        res.Add(thumb)
        '    Next
        '    Return res
        'End Function


        Private Shared Function downloadCRL(crlURL As String) As Org.BouncyCastle.X509.X509Crl
            If crlURL.StartsWith("http://") Or crlURL.StartsWith("https://") Then
                Dim crl As Org.BouncyCastle.X509.X509Crl = downloadCRLFromWeb(crlURL)
                Return crl
            ElseIf crlURL.StartsWith("ldap://") Then
                'Dim crl As X509Crl = downloadCRLFromLDAP(crlURL)
                Return Nothing
            Else
                Throw New Exception("No se puede descargar la lista de revocación indicada por el punto de distribución: " & crlURL)
            End If
        End Function


        Private Shared Function downloadCRLFromWeb(crlURL As String) As Org.BouncyCastle.X509.X509Crl
            Dim X509Crl = Nothing
            Using wc As New Net.WebClient()
                Using stream As IO.Stream = wc.OpenRead(crlURL)
                    Dim memstream As IO.MemoryStream = New IO.MemoryStream
                    stream.CopyTo(memstream)
                    Dim crlParser As Org.BouncyCastle.X509.X509CrlParser = New Org.BouncyCastle.X509.X509CrlParser
                    X509Crl = crlParser.ReadCrl(memstream.ToArray())
                End Using
            End Using
            Return X509Crl
        End Function


        Private Shared Function verifyCRLSign(crl As Org.BouncyCastle.X509.X509Crl, authCert As Org.BouncyCastle.X509.X509Certificate) As Boolean
            Try
                Dim key As Org.BouncyCastle.Crypto.AsymmetricKeyParameter = authCert.GetPublicKey
                crl.Verify(key)
                Return True
            Catch ex As Exception
                Return False
            End Try
        End Function


        Private Shared Function getCRLsFromDSS(pdfreader As iTextSharp.text.pdf.PdfReader) As List(Of Org.BouncyCastle.X509.X509Crl)

            Dim dss As iTextSharp.text.pdf.PdfDictionary = pdfreader.Catalog.GetAsDict(iTextSharp.text.pdf.PdfName.DSS)

            Dim crls As New List(Of Org.BouncyCastle.X509.X509Crl)
            If dss Is Nothing Then
                Return crls
            End If

            Dim crlarray As iTextSharp.text.pdf.PdfArray = dss.GetAsArray(iTextSharp.text.pdf.PdfName.CRLS)
            If crlarray Is Nothing Then
                Return crls
            End If

            Dim crlParser As New Org.BouncyCastle.X509.X509CrlParser
            For i As Integer = 0 To crlarray.Size - 1
                Dim stream As iTextSharp.text.pdf.PRStream = DirectCast(crlarray.GetAsStream(i), iTextSharp.text.pdf.PRStream)
                Dim crl As Org.BouncyCastle.X509.X509Crl = crlParser.ReadCrl(New IO.MemoryStream(iTextSharp.text.pdf.PdfReader.GetStreamBytes(stream)))
                crls.Add(crl)
            Next
            Return crls


        End Function



        Private Shared Function GetOCSPResponsesFromDSS(pdfreader As iTextSharp.text.pdf.PdfReader) As List(Of Org.BouncyCastle.Ocsp.BasicOcspResp)

            Dim dss As iTextSharp.text.pdf.PdfDictionary = pdfreader.Catalog.GetAsDict(iTextSharp.text.pdf.PdfName.DSS)
            Dim ocsps As New List(Of Org.BouncyCastle.Ocsp.BasicOcspResp)
            If dss Is Nothing Then
                Return ocsps
            End If
            Dim ocsparray As iTextSharp.text.pdf.PdfArray = dss.GetAsArray(iTextSharp.text.pdf.PdfName.OCSPS)
            If ocsparray Is Nothing Then
                Return ocsps
            End If
            For i As Integer = 0 To ocsparray.Size - 1
                Dim stream As iTextSharp.text.pdf.PRStream = DirectCast(ocsparray.GetAsStream(i), iTextSharp.text.pdf.PRStream)
                Dim ocspResponse As New Org.BouncyCastle.Ocsp.OcspResp(iTextSharp.text.pdf.PdfReader.GetStreamBytes(stream))
                If ocspResponse.Status = 0 Then
                    Try
                        ocsps.Add(DirectCast(ocspResponse.GetResponseObject(), Org.BouncyCastle.Ocsp.BasicOcspResp))
                    Catch e As Org.BouncyCastle.Ocsp.OcspException
                        Throw New Org.BouncyCastle.Security.GeneralSecurityException(e.ToString())
                    End Try
                End If
            Next
            Return ocsps
        End Function





        Public Enum nveunmRevokeStatus As Integer
            norevoke = 0
            revoke = 1
            errorCheck = 2
        End Enum

    End Class


    Public Class tnvSignVerifyStatus
        Public pkiName As String
        Public signatureIntegrity As Boolean
        Public useTimestam As Boolean
        Public validSignatureDate As Boolean
        Public trustedChain As Boolean
        Public trusedCertificate As Boolean
        Public isMyCertificate As Boolean
        Public isKnownCertificate As Boolean
        Public signatureAllDocument As Boolean
        Public IncludeCRLs As Boolean
        Public IncludeOCSPResponse As Boolean
        Public isLTV As Boolean
        Public isRevoked As Boolean
        Public PDF_certificationLevel As nvPDFCertificationLevel = nvPDFCertificationLevel.not_certified

        Public location As String
        Public reason As String
        Public signatureCreator As String
        Public contact As String


        Private _SigningCertificate As Org.BouncyCastle.X509.X509Certificate
        Private _chain As List(Of Org.BouncyCastle.X509.X509Certificate)
        Private _CRLs As List(Of Org.BouncyCastle.X509.X509Crl)
        Private _OSCPResponse As Org.BouncyCastle.Ocsp.BasicOcspResp
        Private _SignDate As Date


        Public statusmsg As New List(Of tnvStatusMsg)

        Public ReadOnly Property SigningCertificate As Org.BouncyCastle.X509.X509Certificate
            Get
                Return _SigningCertificate
            End Get
        End Property

        Public ReadOnly Property chain As List(Of Org.BouncyCastle.X509.X509Certificate)
            Get
                Return _chain
            End Get
        End Property

        Public ReadOnly Property CRLs As List(Of Org.BouncyCastle.X509.X509Crl)
            Get
                Return _CRLs
            End Get
        End Property

        Public ReadOnly Property OSCPResponse As Org.BouncyCastle.Ocsp.BasicOcspResp
            Get
                Return _OSCPResponse
            End Get
        End Property

        Public ReadOnly Property SignDate As Date
            Get
                Return _SignDate
            End Get
        End Property

        Public Sub setSignElement(SigningCertificate As Org.BouncyCastle.X509.X509Certificate, chain As List(Of Org.BouncyCastle.X509.X509Certificate), CRLs As List(Of Org.BouncyCastle.X509.X509Crl), OSCPResponse As Org.BouncyCastle.Ocsp.BasicOcspResp, SignDate As Date)
            _SigningCertificate = SigningCertificate
            _chain = chain
            _CRLs = CRLs
            _OSCPResponse = OSCPResponse
            _SignDate = SignDate
        End Sub

        Public Function getStatusmsgXML(Optional OmitXmlDeclaration As Boolean = True,
                                        Optional includeSigningCertificate As Boolean = True,
                                        Optional includeCRLInfo As Boolean = True,
                                        Optional includeOCSPResponse As Boolean = True,
                                        Optional inlcudeSignCertificate As Boolean = True,
                                        Optional includeChain As Boolean = True,
                                        Optional includeBin As Boolean = True
                                        ) As String
            Dim sb As New System.Text.StringBuilder
            Dim setting As New System.Xml.XmlWriterSettings
            setting.OmitXmlDeclaration = True
            Dim xmlw As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(sb, setting)
            xmlw.WriteStartDocument()
            xmlw.WriteStartElement("SignVerifyStatus")
            xmlw.WriteAttributeString("signatureIntegrity", Me.signatureIntegrity.ToString().ToLower)
            xmlw.WriteAttributeString("signatureAllDocument", Me.signatureAllDocument.ToString().ToLower)
            xmlw.WriteAttributeString("validSignatureDate", Me.validSignatureDate.ToString().ToLower)
            xmlw.WriteAttributeString("useTimestam", Me.useTimestam.ToString().ToLower)
            xmlw.WriteAttributeString("isMyCertificate", Me.isMyCertificate.ToString().ToLower)
            xmlw.WriteAttributeString("isKnownCertificate", Me.isKnownCertificate.ToString().ToLower)
            xmlw.WriteAttributeString("trusedCertificate", Me.trusedCertificate.ToString().ToLower)
            xmlw.WriteAttributeString("trustedChain", Me.trustedChain.ToString().ToLower)
            xmlw.WriteAttributeString("IncludeCRLs", Me.IncludeCRLs.ToString().ToLower)
            xmlw.WriteAttributeString("IncludeOCSPResponse", Me.IncludeOCSPResponse.ToString().ToLower)
            xmlw.WriteAttributeString("isLTV", Me.isLTV.ToString().ToLower)
            xmlw.WriteAttributeString("isRevoked", Me.isRevoked.ToString().ToLower)
            xmlw.WriteStartElement("messages")
            Dim countWarning As Integer = 0
            Dim countInfo As Integer = 0

            For Each msg In statusmsg
                If msg.tipo = enunvStatusMsgTipo.warning Then countWarning += 1
                If msg.tipo = enunvStatusMsgTipo.info Then countInfo += 1
            Next
            xmlw.WriteAttributeString("countWarning", countWarning)
            xmlw.WriteAttributeString("countInfo", countInfo)
            For Each msg In statusmsg
                xmlw.WriteStartElement("statusmsg")
                xmlw.WriteAttributeString("tipo", msg.tipo.ToString)
                xmlw.WriteAttributeString("msg", msg.mesage)
                xmlw.WriteEndElement()
            Next
            xmlw.WriteEndElement()

            xmlw.WriteStartElement("signElemets")
            xmlw.WriteAttributeString("signDate", _SignDate.ToString("MM/dd/yyy hh:mm:ss"))
            If Not _SigningCertificate Is Nothing And includeSigningCertificate Then
                xmlw.WriteStartElement("SigningCertificate")
                xmlw.WriteAttributeString("SubjectDN", _SigningCertificate.SubjectDN.ToString)
                xmlw.WriteAttributeString("SerialNumber", _SigningCertificate.SerialNumber.ToString)
                xmlw.WriteAttributeString("NotAfter", _SigningCertificate.NotAfter.ToString("MM/dd/yyy hh:mm:ss"))
                xmlw.WriteAttributeString("NotBefore", _SigningCertificate.NotBefore.ToString("MM/dd/yyy hh:mm:ss"))
                xmlw.WriteAttributeString("IssuerDN", _SigningCertificate.IssuerDN.ToString())
                If includeBin Then
                    Dim buffer() As Byte = _SigningCertificate.GetEncoded()
                    xmlw.WriteBase64(buffer, 0, buffer.Length)
                End If
                xmlw.WriteEndElement() 'SigningCertificate

            End If
            If Not CRLs Is Nothing And includeCRLInfo Then
                xmlw.WriteStartElement("CRLs")
                For Each crl In CRLs
                    xmlw.WriteStartElement("CRL")
                    xmlw.WriteAttributeString("ThisUpdate", crl.ThisUpdate.ToString("MM/dd/yyy hh:mm:ss"))
                    xmlw.WriteAttributeString("NextUpdate", crl.NextUpdate.Value.ToString("MM/dd/yyy hh:mm:ss"))
                    xmlw.WriteAttributeString("IssuerDN", crl.IssuerDN.ToString)
                    If includeBin Then
                        Dim buffer() As Byte = crl.GetEncoded()
                        xmlw.WriteBase64(buffer, 0, buffer.Length)
                    End If
                    xmlw.WriteEndElement() 'CRL
                Next
                xmlw.WriteEndElement() 'CRLs
            End If
            If Not _OSCPResponse Is Nothing And includeOCSPResponse Then
                xmlw.WriteStartElement("OCSPResponse")
                For Each response As Org.BouncyCastle.Ocsp.SingleResp In _OSCPResponse.Responses
                    xmlw.WriteAttributeString("ThisUpdate", response.ThisUpdate.ToString("MM/dd/yyy hh:mm:ss"))
                    xmlw.WriteAttributeString("NextUpdate", response.NextUpdate.Value.ToString("MM/dd/yyy hh:mm:ss"))
                    xmlw.WriteAttributeString("SerialNumber", response.GetCertID().SerialNumber.ToString)
                Next
                If includeBin Then
                    xmlw.WriteStartElement("base64")
                    Dim buffer() As Byte = _OSCPResponse.GetEncoded()
                    xmlw.WriteBase64(buffer, 0, buffer.Length)
                    xmlw.WriteEndElement() 'base64
                End If
                xmlw.WriteEndElement() 'OCSPResponse
            End If

            If Not _chain Is Nothing And includeChain Then
                xmlw.WriteStartElement("chain")
                For Each cert In chain
                    xmlw.WriteStartElement("certificate")
                    xmlw.WriteAttributeString("SubjectDN", cert.SubjectDN.ToString)
                    xmlw.WriteAttributeString("SerialNumber", cert.SerialNumber.ToString)
                    xmlw.WriteAttributeString("NotAfter", cert.NotAfter.ToString("MM/dd/yyy hh:mm:ss"))
                    xmlw.WriteAttributeString("NotBefore", cert.NotBefore.ToString("MM/dd/yyy hh:mm:ss"))
                    xmlw.WriteAttributeString("IssuerDN", cert.IssuerDN.ToString())
                    If includeBin Then
                        Dim buffer() As Byte = cert.GetEncoded()
                        xmlw.WriteBase64(buffer, 0, buffer.Length)
                    End If
                    xmlw.WriteEndElement() 'certificate
                Next
                xmlw.WriteEndElement() 'chain
            End If
            xmlw.WriteEndElement() 'signElemets

            xmlw.WriteEndElement()
            xmlw.WriteEndDocument()
            xmlw.Close()
            Dim res As String = sb.ToString()
            Return res
        End Function

        Public Class tnvStatusMsg
            Public tipo As enunvStatusMsgTipo
            Public mesage As String
        End Class

        Public Enum enunvStatusMsgTipo
            info = 0
            warning = 1
        End Enum

    End Class

    Public Enum enumnvRevocationOptions
        None = 0
        OCSP = 1
        CRL = 2
        OCSP_OPTIONAL_CRL = 3
        OCSP_FAIL_CRL = 4
    End Enum


End Namespace

