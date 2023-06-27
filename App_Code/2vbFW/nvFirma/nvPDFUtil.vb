Imports System.IO
Imports System.Security.Cryptography
Imports System.Security.Cryptography.X509Certificates
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Public Class nvPDFUtil

        Public Shared Function getPDFRevision(ByRef bytes() As Byte, revision As String) As Byte()


            Dim reader As New iTextSharp.text.pdf.PdfReader(bytes)
            Dim af As iTextSharp.text.pdf.AcroFields = reader.AcroFields
            Dim os As New MemoryStream
            Dim ip As iTextSharp.text.io.RASInputStream = af.ExtractRevision(revision)


            Dim buff(ip.Length - 1) As Byte

            ip.Read(buff, 0, ip.Length)

            'os.Write(buff, 0, ip.Length)
            'System.IO.File.WriteAllBytes("D:\revision.pdf", buff)
            Return buff

        End Function

        

        Public Shared Function signDeferred(ByRef bytes() As Byte, signatureName As String, externalSignature As tnvExternalSignatureContainer) As Byte()

            Dim reader As New iTextSharp.text.pdf.PdfReader(bytes)
            Dim ms As MemoryStream = New MemoryStream
            iTextSharp.text.pdf.security.MakeSignature.SignDeferred(reader, signatureName, ms, externalSignature)
            Dim retBytes() As Byte = ms.ToArray()
            ms.Dispose()
            Return retBytes

        End Function



        Public Shared Function signDocument(ByRef bytes() As Byte, ByRef oSign As tnvSignature, ByVal sign_certificate As X509Certificate2, Optional blankSignature As Boolean = False) As Byte()

            Dim bc_sign_certificate As Org.BouncyCastle.X509.X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(sign_certificate)
            Dim PDFSignParam As tnvPDFSignParam = oSign.PDFSignParams

            'Crear el memorystream de salida
            Dim ms As MemoryStream = New MemoryStream

            'Si tiene clave privada 
            If sign_certificate.HasPrivateKey Or blankSignature = True Then
                'Dim pk As System.Security.Cryptography.AsymmetricAlgorithm = sign_certificate.PrivateKey


                '***************************************************************************************************************************************
                '*********************************************** CONFIGURAR APARIENCIA *****************************************************************
                '***************************************************************************************************************************************

                'Abrir el PDF
                Dim myPdfReader As New iTextSharp.text.pdf.PdfReader(bytes)

                ' Si se lee desde un memorystream me obligó a poner esta sentencia. Sino da un error de password incorrecto aunque no tenga password
                myPdfReader.unethicalreading = True

                'al momento de generar el stamper hay que ver si esta firmado o no y que se quiere hacer con las firmas anteriores
                Dim myPdfStamper As iTextSharp.text.pdf.PdfStamper

                'Indicar si se deben agregar la firma a las ya existentes
                If PDFSignParam.appendToExistingOnes Then
                    myPdfStamper = iTextSharp.text.pdf.PdfStamper.CreateSignature(myPdfReader, ms, "0", Nothing, True)
                Else
                    myPdfStamper = iTextSharp.text.pdf.PdfStamper.CreateSignature(myPdfReader, ms, "0")
                End If

                'Dim myPdfDocument As New iTextSharp.text.Document(myPdfReader.GetPageSizeWithRotation(1))

                '*******************************************
                'Define la apariencia de la firma'
                '*******************************************

                Dim myPdfSignatureAppearance As iTextSharp.text.pdf.PdfSignatureAppearance = myPdfStamper.SignatureAppearance


                myPdfSignatureAppearance.Acro6Layers = PDFSignParam.AcrobatLayer6Mode

                If PDFSignParam.signature_text <> "" Then
                    myPdfSignatureAppearance.Layer2Text = PDFSignParam.signature_text
                End If

                Dim font As iTextSharp.text.Font
                'Si no viene con la FontFamily definida, tomar la que esta actualmente
                font = New iTextSharp.text.Font(PDFSignParam.signature_text_fontFamily, -1, -1, PDFSignParam.signature_text_fontColor.getColor)

                ' Asignar tamaño si se ha especificado.
                ' Ademas, si se setea el modo signaturename_and_description, no se debe especificar el tamaño del texto
                ' sino que este se debe autoajustar para visualizarse correctamente de acuerdo al tamaño del recuadro de firma
                If PDFSignParam.signature_text_fontSize <> "0" And PDFSignParam.display <> nvPDFSingDisplay.signaturename_and_description Then
                    font.Size = PDFSignParam.signature_text_fontSize
                End If
                If PDFSignParam.signature_text_fontstyle <> 0 Then
                    font.SetStyle(PDFSignParam.signature_text_fontstyle)
                End If


                myPdfSignatureAppearance.Layer2Font = font

                If PDFSignParam.status_text <> "" Then
                    myPdfSignatureAppearance.Layer4Text = PDFSignParam.status_text
                End If
                If PDFSignParam.LocationCaption <> "" Then
                    myPdfSignatureAppearance.LocationCaption = PDFSignParam.LocationCaption
                End If
                If PDFSignParam.ReasonCaption <> "" Then
                    myPdfSignatureAppearance.ReasonCaption = PDFSignParam.ReasonCaption
                End If
                If PDFSignParam.contact <> "" Then
                    myPdfSignatureAppearance.Contact = PDFSignParam.contact
                End If
                ''myPdfSignatureAppearance.CryptoDictionary = iTextSharp.text.pdf.PdfName.ADOBE_PPKLITE | iTextSharp.text.pdf.PdfName.ADOBE_PPKMS | iTextSharp.text.pdf.PdfName.VERISIGN_PPKVS
                ''myPdfSignatureAppearance.FieldName   = "FieldName"
                '
                If PDFSignParam.SignatureCreator <> "" Then
                    myPdfSignatureAppearance.SignatureCreator = PDFSignParam.SignatureCreator
                End If

                myPdfSignatureAppearance.CertificationLevel = PDFSignParam.certificationLevel 'iTextSharp.text.pdf.PdfSignatureAppearance.CERTIFIED_NO_CHANGES_ALLOWED
                If PDFSignParam.image_path <> "" Then
                    myPdfSignatureAppearance.SignatureGraphic = iTextSharp.text.Image.GetInstance(PDFSignParam.image_path)
                End If

                If PDFSignParam.backgroundimage_path <> "" Then
                    myPdfSignatureAppearance.Image = iTextSharp.text.Image.GetInstance(PDFSignParam.image_path)
                    myPdfSignatureAppearance.ImageScale = PDFSignParam.backgroundimage_scale
                End If
                If PDFSignParam.reason <> "" Then
                    myPdfSignatureAppearance.Reason = PDFSignParam.reason
                End If
                If PDFSignParam.Location <> "" Then
                    myPdfSignatureAppearance.Location = PDFSignParam.Location
                End If
                myPdfSignatureAppearance.SignatureRenderingMode = PDFSignParam.display 'iTextSharp.text.pdf.PdfSignatureAppearance.RenderingMode.GRAPHIC_AND_DESCRIPTION

                If PDFSignParam.fieldname = "" Then
                    PDFSignParam.fieldname = Nothing
                End If

                If PDFSignParam.visible_signature Then
                    myPdfSignatureAppearance.SetVisibleSignature(New iTextSharp.text.Rectangle(PDFSignParam.x1, PDFSignParam.y1, PDFSignParam.x2, PDFSignParam.y2), PDFSignParam.page, PDFSignParam.fieldname)
                Else
                    myPdfSignatureAppearance.SetVisibleSignature(New iTextSharp.text.Rectangle(0, 0, 0, 0), 1, PDFSignParam.fieldname)
                End If

                ' Si no se especifico nombre de firma, asignar el generado automaticamente
                If String.IsNullOrEmpty(PDFSignParam.fieldname) Then
                    oSign.name = myPdfSignatureAppearance.FieldName
                    PDFSignParam.fieldname = myPdfSignatureAppearance.FieldName
                End If


                

                '***************************************************************************************************************************************
                '*********************************************** FIRMAR DOCUMENTO **********************************************************************
                '***************************************************************************************************************************************

                If blankSignature Then
                    Dim external As New com.itextpdf.text.pdf.security.ExternalBlankSignatureContainer(iTextSharp.text.pdf.PdfName.ADOBE_PPKLITE, iTextSharp.text.pdf.PdfName.ADBE_PKCS7_DETACHED)

                    ' Especificar el certificado en la apariencia: es necesario para que el modo de visualizacion signature name and description funcione
                    ' dado que desde el certificado se obtiene el nombre del firmante para mostrar en el recuadro
                    myPdfSignatureAppearance.Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(sign_certificate)

                    iTextSharp.text.pdf.security.MakeSignature.SignExternalContainer(myPdfSignatureAppearance, external, oSign.PDFSignParams.estimatedSize)

                Else


                    '**********************************************************
                    'Configurar las opciones OCSP
                    '**********************************************************
                    Dim ocspClient As iTextSharp.text.pdf.security.OcspClientBouncyCastle = Nothing
                    If oSign.includeRevocationInfo = enumRevocationInfo.OCSP Or oSign.includeRevocationInfo = enumRevocationInfo.OCSP_AND_CRL Then
                        Dim OCSP_URL = iTextSharp.text.pdf.security.CertificateUtil.GetOCSPURL(bc_sign_certificate)
                        If Not OCSP_URL Is Nothing Then
                            ocspClient = New iTextSharp.text.pdf.security.OcspClientBouncyCastle()
                        End If
                    End If


                    '**********************************************************
                    'Cargar cadena de certificados
                    '**********************************************************
                    Dim myX509Chain As New X509Chain()
                    Dim ks As New List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)
                    ks = oSign.PKI.getTrustedCertsList("X509Certificate2")
                    myX509Chain.ChainPolicy.ExtraStore.AddRange(ks.ToArray)

                    ' la raiz de nuestra pki  debe estar instalada en el store (user o machine) del equipo
                    ' para que la cadena resulte valida. Seteamos elsiguiente flag para para que el build chain devuelva true, aunque la raiz sea desconocida. 
                    myX509Chain.ChainPolicy.VerificationFlags = System.Security.Cryptography.X509Certificates.X509VerificationFlags.AllowUnknownCertificateAuthority

                    ' modo de revocacion: no check
                    myX509Chain.ChainPolicy.RevocationMode = System.Security.Cryptography.X509Certificates.X509RevocationMode.NoCheck
                    myX509Chain.Build(sign_certificate)

                    Dim myCertificateChain As IList(Of Org.BouncyCastle.X509.X509Certificate) = New List(Of Org.BouncyCastle.X509.X509Certificate)()
                    For Each myChainElement As X509ChainElement In myX509Chain.ChainElements
                        myCertificateChain.Add(Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(myChainElement.Certificate))
                    Next

                    '**********************************************************
                    'Configurar las opciones tsaClient
                    '**********************************************************
                    Dim tsaClient As iTextSharp.text.pdf.security.ITSAClient = Nothing
                    If oSign.use_timestamp_server Then
                        If oSign.TSA_URL <> "" Then
                            tsaClient = New iTextSharp.text.pdf.security.TSAClientBouncyCastle(oSign.TSA_URL, oSign.TSA_uid, oSign.TSA_pwd, 4096, oSign.TSA_hash_algorithm)
                        Else
                            For intI As Integer = 0 To myCertificateChain.Count - 1
                                Dim cert As Org.BouncyCastle.X509.X509Certificate = myCertificateChain(intI)
                                Dim tsaUrl As String = iTextSharp.text.pdf.security.CertificateUtil.GetTSAURL(cert)
                                If tsaUrl IsNot Nothing Then
                                    tsaClient = New iTextSharp.text.pdf.security.TSAClientBouncyCastle(tsaUrl, oSign.TSA_uid, oSign.TSA_pwd, 4096, oSign.TSA_hash_algorithm)
                                    Exit For
                                End If
                            Next
                        End If
                    End If

                    '**********************************************************
                    'Configurar las opciones CRL
                    '**********************************************************
                    Dim crlList As IList(Of iTextSharp.text.pdf.security.ICrlClient) = New List(Of iTextSharp.text.pdf.security.ICrlClient)()
                    If oSign.includeRevocationInfo = enumRevocationInfo.CRL Or oSign.includeRevocationInfo = enumRevocationInfo.OCSP_AND_CRL Then
                        crlList.Add(New iTextSharp.text.pdf.security.CrlClientOnline(myCertificateChain))
                    End If

                    '******************************************
                    'Adjuntar la firma al PDF
                    '******************************************
                    Dim strHashAlgorithm As String = "SHA-1"
                    'Select Case PDFSignParam.hashAlgorithm
                    Select Case oSign.hashAlgorithm
                        Case nvHashAlgorithm.SHA1
                            strHashAlgorithm = "SHA-1"
                        Case nvHashAlgorithm.SHA256
                            strHashAlgorithm = "SHA-256"
                        Case nvHashAlgorithm.SHA384
                            strHashAlgorithm = "SHA-384"
                        Case nvHashAlgorithm.SHA512
                            strHashAlgorithm = "SHA-512"
                        Case nvHashAlgorithm.RIPEMD160
                            strHashAlgorithm = "RIPEMD-160"
                    End Select


                    ' no funciona con token hsm ...
                    Dim myExternalSignature As iTextSharp.text.pdf.security.IExternalSignature = New tnvExternalSignature(sign_certificate.PrivateKey, strHashAlgorithm)

                    ' otras variantes para firma
                    'Dim myExternalSignature As iTextSharp.text.pdf.security.IExternalSignature = New iTextSharp.text.pdf.security.X509Certificate2Signature(sign_certificate, strHashAlgorithm) ' soporta firma con token (clave no exportable)
                    'Dim myExternalSignature As iTextSharp.text.pdf.security.IExternalSignature = New iTextSharp.text.pdf.security.PrivateKeySignature(sign_certificate.PrivateKey, strHashAlgorithm)

                    iTextSharp.text.pdf.security.MakeSignature.SignDetached(myPdfSignatureAppearance, myExternalSignature, myCertificateChain, crlList, ocspClient, tsaClient, oSign.PDFSignParams.estimatedSize, PDFSignParam.cryptoStandard)
                End If


                myPdfReader.Close()
                myPdfStamper.Close()

                'Generar un nuevo memory stream desde el asignado al Stamper. El stamper cierra el stream asignado
                Dim retBytes() As Byte = ms.ToArray()
                ms.Dispose()
                Return retBytes
            Else
                Throw New Exception("El certificado seleccionado no tiene clave privada")
            End If
        End Function



        Public Shared Function PdfConcat(fileA As String, FileB As String) As Byte()

            Dim byteA() As Byte = System.IO.File.ReadAllBytes(fileA)
            Dim byteB() As Byte = System.IO.File.ReadAllBytes(FileB)

            Return PdfConcat(byteA, byteB)

        End Function

        Public Shared Function PdfConcat(fileAasBytes As Byte(), fileBasBytes As Byte()) As Byte()

            Dim i As Integer = 0
            Dim j As Integer = 0
            Dim ms As New MemoryStream
            Dim document = New iTextSharp.text.Document
            Dim pdfCopyProvider As iTextSharp.text.pdf.PdfCopy = New iTextSharp.text.pdf.PdfCopy(document, ms)

            document.Open()

            Dim doc(1)() As Byte
            doc(0) = fileAasBytes
            doc(1) = fileBasBytes
            For i = 0 To 1
                Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(doc(i))
                For j = 1 To reader.NumberOfPages
                    Dim importedPage As iTextSharp.text.pdf.PdfImportedPage = pdfCopyProvider.GetImportedPage(reader, j)
                    pdfCopyProvider.AddPage(importedPage)
                    ' pdfCopyProvider.FreeReader(reader)
                Next
                reader.Close()
            Next

            document.Close()

            Dim byteres() As Byte = ms.ToArray()
            ms.Close()

            'Dim byteres(ms.Length - 1) As Byte
            'ms.Position = 0
            'ms.Read(byteres, 0, ms.Length)

            pdfCopyProvider.CloseStream = True
            pdfCopyProvider.Close()

            Return byteres

        End Function

        Public Shared Function PdfNumberPages(ByVal fileA As String, ByRef Err As nvFW.tError) As Integer
            Err = New nvFW.tError()
            Dim pagenumber As Integer = 0
            Dim reader As iTextSharp.text.pdf.PdfReader
            Try
                reader = New iTextSharp.text.pdf.PdfReader(fileA)
                pagenumber = reader.NumberOfPages
                reader.Close()
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error al procesar el archivo"
                Err.mensaje = "No se pudo realizar la acción solicitada"
            End Try
            Return pagenumber
        End Function

        Public Shared Function PageIsBlank(ByVal fileA As String, ByVal pageNumber As Integer, ByRef Err As nvFW.tError) As Boolean
            Err = New nvFW.tError()
            Dim isBlank As Boolean = False
            Dim reader As iTextSharp.text.pdf.PdfReader
            If Not (pageNumber > 0) Then
                Err.numError = 1
                Err.titulo = "Error al procesar el archivo"
                Err.mensaje = "El numero de la pagina debe ser un valor mayor a cero"
            End If
            Try
                reader = New iTextSharp.text.pdf.PdfReader(fileA)
                Dim pageDict = reader.GetPageN(pageNumber)
                Dim resDict As iTextSharp.text.pdf.PdfDictionary = CType(pageDict.Get(iTextSharp.text.pdf.PdfName.RESOURCES), iTextSharp.text.pdf.PdfDictionary)
                If resDict IsNot Nothing Then
                    isBlank = resDict.Get(iTextSharp.text.pdf.PdfName.FONT) Is Nothing AndAlso resDict.Get(iTextSharp.text.pdf.PdfName.XOBJECT) Is Nothing
                End If
                reader.Close()
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error al procesar el archivo"
                Err.mensaje = "No se pudo realizar la acción solicitada"
            End Try
            Return isBlank
        End Function

        Public Shared Function GetText(ByVal fileA As String, ByVal pageNumber As Integer, ByRef Err As nvFW.tError) As String
            Err = New nvFW.tError()
            Dim currentText As String = ""
            Dim reader As iTextSharp.text.pdf.PdfReader
            Dim strategy As iTextSharp.text.pdf.parser.ITextExtractionStrategy = New iTextSharp.text.pdf.parser.SimpleTextExtractionStrategy()
            If Not (pageNumber > 0) Then
                Err.numError = 1
                Err.titulo = "Error al procesar el archivo"
                Err.mensaje = "El numero de la pagina debe ser un valor mayor a cero"
            End If
            Try
                reader = New iTextSharp.text.pdf.PdfReader(fileA)
                currentText = iTextSharp.text.pdf.parser.PdfTextExtractor.GetTextFromPage(reader, pageNumber, strategy)
                currentText = System.Text.Encoding.UTF8.GetString(System.Text.ASCIIEncoding.Convert(System.Text.Encoding.[Default], System.Text.Encoding.UTF8, System.Text.Encoding.[Default].GetBytes(currentText)))
                reader.Close()
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error al procesar el archivo"
                Err.mensaje = "No se pudo realizar la acción solicitada"
            End Try
            Return currentText
        End Function


        Public Shared Function SavePage(ByVal fileA As String, ByVal pageNumber As Integer, ByVal fileOutput As String, ByRef Err As nvFW.tError) As Boolean
            Err = New nvFW.tError()
            Dim saved As Boolean = False
            Dim reader As iTextSharp.text.pdf.PdfReader
            Dim sourceDocument As iTextSharp.text.Document = Nothing
            Dim pdfCpy As iTextSharp.text.pdf.PdfCopy = Nothing
            Dim page As iTextSharp.text.pdf.PdfImportedPage = Nothing
            If Not (pageNumber > 0) Then
                Err.numError = 1
                Err.titulo = "Error al procesar el archivo"
                Err.mensaje = "El numero de la pagina debe ser un valor mayor a cero"
            End If
            Try
                reader = New iTextSharp.text.pdf.PdfReader(fileA)
                sourceDocument = New iTextSharp.text.Document(reader.GetPageSizeWithRotation(pageNumber))
                pdfCpy = New iTextSharp.text.pdf.PdfCopy(sourceDocument, New System.IO.FileStream(fileOutput, System.IO.FileMode.Create))
                sourceDocument.Open()
                page = pdfCpy.GetImportedPage(reader, pageNumber)
                pdfCpy.AddPage(page)
                sourceDocument.Close()
                pdfCpy.Dispose()
                reader.Close()
                saved = True
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error al procesar el archivo"
                Err.mensaje = "No se pudo realizar la acción solicitada"
            End Try
            Return saved
        End Function

        ''dado un pdf, agrega una etiqueta a una pagina (0 a todas las paginas)
        Public Shared Function AddLabelPage(ByVal filenameIn As String, ByVal Etiqueta As Label, Optional ByVal pageNumber As Integer = 0) As Byte()

            Dim descError As String = ""
            Dim numError As Integer = 0
            Dim dirpath As String = System.IO.Path.GetTempPath()
            Dim outputfile As String = ""
            Dim docbytes As Byte() = Nothing

            ''tomo el archivo del credito, le pongo titulo, y lo guardo en una ubicacion temporal
            Dim reader As New iTextSharp.text.pdf.PdfReader(New iTextSharp.text.pdf.RandomAccessFileOrArray(filenameIn), Nothing)
            Dim parser As New iTextSharp.text.pdf.parser.PdfReaderContentParser(reader)
            Dim finder As New iTextSharp.text.pdf.parser.TextMarginFinder()
            iTextSharp.text.pdf.PdfReader.unethicalreading = True
            Dim fileoutname As String = System.IO.Path.GetFileName(System.IO.Path.GetTempFileName).Replace(".tmp", ".pdf")
            outputfile = dirpath & fileoutname
            Dim fs = New System.IO.FileStream(outputfile, System.IO.FileMode.Create, System.IO.FileAccess.Write)
            Using stamper As New iTextSharp.text.pdf.PdfStamper(reader, fs)
                '  int pageNumber = reader.NumberOfPages;
                '  finder = parser.ProcessContent(pageNumber, new TextMarginFinder());
                Dim cb As iTextSharp.text.pdf.PdfContentByte
                ''Dim size = reader.GetPageSize(1)
                Dim titleFont As iTextSharp.text.Font ''= New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 15, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.BLUE)
                ''Dim textFont As iTextSharp.text.Font = New iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.HELVETICA, 13, iTextSharp.text.Font.BOLD, iTextSharp.text.BaseColor.BLUE)
                Dim titleChunk As iTextSharp.text.Chunk
                ''Dim phrase As New iTextSharp.text.Phrase(" Nro Pieza: 45564564", textFont)
                ' Image logo = Image.GetInstance("signature.png");
                Dim rect As New iTextSharp.text.Rectangle(0, 0, 0, 0)
                ''aplico la etiqueta a todos las paginas
                If (pageNumber = 0) Then
                    For i As Integer = 1 To reader.NumberOfPages
                        cb = stamper.GetOverContent(i)
                        ''finder = parser.ProcessContent(i, New iTextSharp.text.pdf.parser.TextMarginFinder())
                        titleFont = New iTextSharp.text.Font(Etiqueta.Font.family, Etiqueta.Font.Size, Etiqueta.Font.Bold, Etiqueta.Font.itextColor())
                        titleChunk = New iTextSharp.text.Chunk(Etiqueta.Text, titleFont)
                        cb = stamper.GetOverContent(i)
                        rect = New iTextSharp.text.Rectangle(Etiqueta.posx, Etiqueta.posy, Etiqueta.dx, Etiqueta.dy)
                        cb.Rectangle(rect)
                        Dim ct As New iTextSharp.text.pdf.ColumnText(cb)
                        ct.SetSimpleColumn(rect)
                        ct.AddElement(titleChunk)
                        ''ct.AddElement(phrase)
                        ''ct.AddElement(New iTextSharp.text.Chunk(Environment.NewLine))
                        ct.Go()
                        cb.Stroke()
                    Next
                Else
                    ''agrega solo a una pagina en particular
                    If (pageNumber <= reader.NumberOfPages And pageNumber > 0) Then
                        cb = stamper.GetOverContent(pageNumber)
                        titleFont = New iTextSharp.text.Font(Etiqueta.Font.family, Etiqueta.Font.Size, Etiqueta.Font.Bold, Etiqueta.Font.itextColor())
                        titleChunk = New iTextSharp.text.Chunk(Etiqueta.Text, titleFont)
                        cb = stamper.GetOverContent(pageNumber)
                        rect = New iTextSharp.text.Rectangle(Etiqueta.posx, Etiqueta.posy, Etiqueta.dx, Etiqueta.dy)
                        cb.Rectangle(rect)
                        Dim ct As New iTextSharp.text.pdf.ColumnText(cb)
                        ct.SetSimpleColumn(rect)
                        ct.AddElement(titleChunk)
                        ''ct.AddElement(phrase)
                        ''ct.AddElement(New iTextSharp.text.Chunk(Environment.NewLine))
                        ct.Go()
                        cb.Stroke()
                    End If

                End If
                stamper.Close()
                reader.Close()
            End Using
            fs.Close()
            docbytes = System.IO.File.ReadAllBytes(outputfile)
            System.IO.File.Delete(outputfile)

            Return docbytes
        End Function


        Public Shared Function ImageToPDF(ByVal path_archivo As String, Optional ByVal image_compresion As Integer = 85, Optional ByVal image_dpi As Integer = 150) As Byte()
            Dim img = New System.Drawing.Bitmap(path_archivo)
            Return ImageToPDF(img, image_compresion, image_dpi)
        End Function

        Public Shared Function ImageToPDF(ByVal img_stream As IO.MemoryStream, Optional ByVal image_compresion As Integer = 85, Optional ByVal image_dpi As Integer = 150) As Byte()
            Dim img = New System.Drawing.Bitmap(img_stream)
            Return ImageToPDF(img, image_compresion, image_dpi)
        End Function

        Public Shared Function ImageToPDF(ByVal img As System.Drawing.Bitmap, Optional ByVal image_compresion As Integer = 85, Optional ByVal image_dpi As Integer = 150) As Byte()
            Dim docBytes As Byte() = Nothing
            Dim document As iTextSharp.text.Document
            Dim pdfCopyProvider As iTextSharp.text.pdf.PdfCopy
            Dim filename As String = System.IO.Path.GetTempFileName().Replace(".tmp", ".pdf")
            Dim importedPage As iTextSharp.text.pdf.PdfImportedPage

            document = New iTextSharp.text.Document()
            pdfCopyProvider = New iTextSharp.text.pdf.PdfCopy(document, New System.IO.FileStream(filename, System.IO.FileMode.Create))
            pdfCopyProvider.SetFullCompression()
            document.Open()

            Dim imageDocument As New iTextSharp.text.Document
            Dim msOutputStream As New System.IO.MemoryStream
            Dim imageDocumentWriter As iTextSharp.text.pdf.PdfWriter = iTextSharp.text.pdf.PdfWriter.GetInstance(imageDocument, msOutputStream)
            imageDocument.Open()

            'Calcular que tamaño de pagina cuadra mejor con el elemento
            Dim img_ratio As Single = img.Width / img.Height
            Dim pageSizes As New Dictionary(Of String, Object)
            pageSizes.Add("A4", iTextSharp.text.PageSize.A4)
            pageSizes.Add("A4_LANDSCAPE", New iTextSharp.text.Rectangle(iTextSharp.text.PageSize.A4.Height, iTextSharp.text.PageSize.A4.Width, 0))
            pageSizes.Add("LEGAL", iTextSharp.text.PageSize.LEGAL)
            pageSizes.Add("LEGAL_LANDSCAPE", New iTextSharp.text.Rectangle(iTextSharp.text.PageSize.LEGAL.Height, iTextSharp.text.PageSize.LEGAL.Width, 0))

            Dim selected_pageSize As Object
            Dim min_dif As Single = 20

            For Each p In pageSizes.Values
                If Math.Abs((p.Width / p.height) - img_ratio) < min_dif Then
                    selected_pageSize = p
                    min_dif = Math.Abs((p.Width / p.height) - img_ratio)
                End If
            Next

            imageDocument.SetPageSize(selected_pageSize)
            Dim bmp As System.Drawing.Bitmap = New System.Drawing.Bitmap(img)
            If image_dpi = 0 Then image_dpi = 150


            If imageDocument.NewPage() Then
                Dim new_width As Integer
                Dim new_height As Integer
                Dim page_aratio As Single = imageDocument.PageSize.Width / imageDocument.PageSize.Height
                Dim image_aratio As Single = bmp.Width / bmp.Height

                'Controla el aspect ratio para ver como se debe escalar
                'Si la imagen es mas grande que la hoja la achica, sino la deja del tamaño actual
                If page_aratio < image_aratio Then
                    If imageDocument.PageSize.Width < bmp.Width Then
                        new_width = (imageDocument.PageSize.Width / 72) * image_dpi
                    Else
                        new_width = bmp.Width
                    End If
                    new_height = new_width / image_aratio
                Else
                    If imageDocument.PageSize.Height < bmp.Height Then
                        new_height = (imageDocument.PageSize.Height / 72) * image_dpi
                    Else
                        new_height = bmp.Height
                    End If
                    new_width = new_height * image_aratio
                End If
                ''Dim bmp1 = nvImage.resize(bmp, new_width, new_height, True, True)
                Dim bmp1 = nvImage.resize(bmp, new_width, new_height)
                Dim bytes As Byte() = nvImage.ConvertToJpgBytes(bmp1, image_compresion)
                bmp.Dispose()
                bmp1.Dispose()
                Dim image As iTextSharp.text.Image = iTextSharp.text.Image.GetInstance(bytes)
                image.ScaleAbsolute((image.Width / image_dpi) * 72, (image.Height / image_dpi) * 72)
                image.SetAbsolutePosition(0, 0) 'imageDocument.PageSize.Height - new_height
                If Not imageDocument.Add(image) Then
                    Throw New Exception("Unable to add image to page!")
                End If
                image = Nothing

            End If
            imageDocument.Close()
            imageDocumentWriter.Close()
            Dim imageDocumentReader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(msOutputStream.ToArray())
            msOutputStream.Close()
            Stop
            importedPage = pdfCopyProvider.GetImportedPage(imageDocumentReader, 1)
            pdfCopyProvider.AddPage(importedPage)

            pdfCopyProvider.CloseStream = True
            document.Close()
            document = Nothing
            pdfCopyProvider.Close()
            docBytes = System.IO.File.ReadAllBytes(filename)
            System.IO.File.Delete(filename)
            Return docBytes
        End Function


        Public Shared Function HtmlToPDF(ByVal strHTML As String) As Byte()
            Dim Converter As SelectPdf.HtmlToPdf = New SelectPdf.HtmlToPdf
            Dim doc As SelectPdf.PdfDocument = Converter.ConvertHtmlString(strHTML, "")
            Dim binaryData() As Byte = doc.Save()
            doc.Close()

            Return binaryData
        End Function


    End Class

    Public Class Font
        Public family As Single = 2
        Public color As Single = 1
        Public bold As Single = 1
        Public size As Single = 10

        Public Function itextFont() As iTextSharp.text.Font.FontFamily
            Dim ret As iTextSharp.text.Font.FontFamily = iTextSharp.text.Font.FontFamily.UNDEFINED
            Select Case family
                Case 1
                    ret = iTextSharp.text.Font.FontFamily.HELVETICA
                Case 0
                    ret = iTextSharp.text.Font.FontFamily.COURIER
                Case 2
                    ret = iTextSharp.text.Font.FontFamily.TIMES_ROMAN
                Case 4
                    ret = iTextSharp.text.Font.FontFamily.ZAPFDINGBATS
                Case Else
                    ret = iTextSharp.text.Font.FontFamily.UNDEFINED
            End Select
            Return ret
        End Function

        Public Function itextColor() As iTextSharp.text.BaseColor
            Dim ret As iTextSharp.text.BaseColor = iTextSharp.text.BaseColor.BLACK
            Select Case color
                Case 1
                    ret = iTextSharp.text.BaseColor.BLUE
                Case 2
                    ret = iTextSharp.text.BaseColor.DARK_GRAY
                Case 3
                    ret = iTextSharp.text.BaseColor.GREEN
                Case 4
                    ret = iTextSharp.text.BaseColor.LIGHT_GRAY
                Case 5
                    ret = iTextSharp.text.BaseColor.RED
                Case 6
                    ret = iTextSharp.text.BaseColor.WHITE
                Case 7
                    ret = iTextSharp.text.BaseColor.ORANGE
                Case Else
                    ret = iTextSharp.text.BaseColor.BLACK
            End Select
            Return ret
        End Function

    End Class

    Public Class Label
        Public font As Font = New Font()
        Public text As String = ""
        Public posx As Double = 0
        Public posy As Double = 0
        Public dx As Double = 0
        Public dy As Double = 0
    End Class

    '******************************
    'Genera la firma externa
    'Solo genera con algoritmo RSA
    'Si se quisiera firmar con otro algoritmo hay que cambiar los parametros de las llamadas
    'ya que actualmente recibe certificados con claves RSA
    'En realidad si se pasara un certificado con clave DSA pudiera fucnionar.
    '******************************
    Public Class tnvExternalSignature
        Implements iTextSharp.text.pdf.security.IExternalSignature

        Private hashAlgorithm As String
        Private encryptionAlgorithm As String
        Private _private_key As AsymmetricAlgorithm

        Public Sub New(ByRef private_key As AsymmetricAlgorithm, ByVal hashAlgorithm As String)
            _private_key = private_key
            Select Case _private_key.GetType.ToString
                Case "System.Security.Cryptography.RSACryptoServiceProvider"
                    Me.encryptionAlgorithm = "RSA"
                Case "System.Security.Cryptography.DSACryptoServiceProvider"
                    Me.encryptionAlgorithm = "DSA"
            End Select
            'Me.encryptionAlgorithm = "RSA" 'private_key.SignatureAlgorithm
            Me.hashAlgorithm = iTextSharp.text.pdf.security.DigestAlgorithms.GetDigest(iTextSharp.text.pdf.security.DigestAlgorithms.GetAllowedDigests(hashAlgorithm))
        End Sub

        Public Function GetEncryptionAlgorithm() As String Implements iTextSharp.text.pdf.security.IExternalSignature.GetEncryptionAlgorithm
            Return encryptionAlgorithm
        End Function

        Public Function GetHashAlgorithm() As String Implements iTextSharp.text.pdf.security.IExternalSignature.GetHashAlgorithm
            Return hashAlgorithm
        End Function

        Public Function Sign(ByVal message() As Byte) As Byte() Implements iTextSharp.text.pdf.security.IExternalSignature.Sign
            Dim hash() As Byte = Nothing

            Dim sig() As Byte
            Select Case _private_key.GetType.ToString
                Case "System.Security.Cryptography.RSACryptoServiceProvider"
                    Dim RSA As RSACryptoServiceProvider = DirectCast(_private_key, RSACryptoServiceProvider)
                    sig = RSA.SignData(message, hashAlgorithm)


                Case "System.Security.Cryptography.DSACryptoServiceProvider"
                    Dim DSA As DSACryptoServiceProvider = DirectCast(_private_key, DSACryptoServiceProvider)
                    sig = DSA.SignData(message)
            End Select

            Return sig
        End Function
    End Class





    ' Interfaz para firmar con un contenedor pkcs7 generado remotamente
    Public Class tnvExternalSignatureContainer
        Implements iTextSharp.text.pdf.security.IExternalSignatureContainer

        Private signContainer As Byte()

        Public Sub New(signContainer As Byte())
            Me.signContainer = signContainer
        End Sub

        Public Function Sign(inputstr As Stream) As Byte() Implements iTextSharp.text.pdf.security.IExternalSignatureContainer.Sign
            Return signContainer
        End Function

        Public Sub ModifySigningDictionary(signDic As iTextSharp.text.pdf.PdfDictionary) Implements iTextSharp.text.pdf.security.IExternalSignatureContainer.ModifySigningDictionary
            Return
        End Sub

    End Class




    Public Class nvPDFDeferredSign

        Public doc As Byte()
        Public oCert As X509Certificate2
        Public oSign As tnvSignature

        Public myCertificateChain As List(Of Org.BouncyCastle.X509.X509Certificate) = Nothing
        Public ocspBytes As Byte() = Nothing
        Public crlBytes As List(Of Byte()) = Nothing
        Public tsaClient As iTextSharp.text.pdf.security.ITSAClient = Nothing

        Private sgn As iTextSharp.text.pdf.security.PdfPKCS7 = Nothing
        Private hash As Byte()

        Private blankSigned As Byte()

        ' Por defecto, la firma deferida genera el hash pkcs7 del documento
        ' y una vez consumada la firma, incrusta en el documento el pkcs7 firmado.
        ' Si se pone en false esta variable, el hash que se genera es el del documento (hash puro)
        ' y se incrusta el pkcs7 firmado generado por el sevicio de firma
        Public asPKCS7HashSignature As Boolean = True


        ' Este parametro es importante, ya que indica si el digesto de salida
        ' esta codificado en DER segun PKCS#1: al hash de los datos le adjunta el identificado del algoritmo de hash
        ' El metodo SignHash de la RSACryptoServiceProvider de .NET se encarga de hacer este trabajo antes de encriptar, por lo
        ' que el digesto de salida debe ser el hash crudo. En cambio, la clase Org.BouncyCastle.Crypto.Signer  de BouncyCastle
        ' necesita el hash codificado en DER PKCS#1
        Public outputDigestIsDEREncoded As Boolean = False


        Sub New(ByVal doc As Byte(), ByRef oCert As X509Certificate2, ByRef oSign As tnvSignature)

            Me.doc = doc
            Me.oCert = oCert
            Me.oSign = oSign

        End Sub


        Public Function genHash() As Byte()


            Dim strHashAlgorithm As String = "SHA256"
            Select Case oSign.hashAlgorithm
                Case nvHashAlgorithm.SHA1
                    strHashAlgorithm = "SHA1"
                Case nvHashAlgorithm.SHA256
                    strHashAlgorithm = "SHA256"
                Case nvHashAlgorithm.SHA384
                    strHashAlgorithm = "SHA384"
                Case nvHashAlgorithm.SHA512
                    strHashAlgorithm = "SHA512"
                Case nvHashAlgorithm.RIPEMD160
                    strHashAlgorithm = "RIPEMD-160"
            End Select


            ' Si no se requiere hash pkcs7, se devuelve el hash puro del documento
            If Not asPKCS7HashSignature Then
                If oSign.PDFSignParams.estimatedSize = 0 Then
                    oSign.PDFSignParams.estimatedSize = 8192
                End If
                genDocumentHash(strHashAlgorithm)
                Return hash
            End If



            '***************************************************************************************************************************************
            '*********************************************** DESCARGAR INFO VALIDACIÓN LTV  ********************************************************
            '***************************************************************************************************************************************

            Dim bc_sign_certificate As Org.BouncyCastle.X509.X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(oCert)

            ' cargar cadena de cert
            Dim myX509Chain As New X509Chain()
            Dim ks As New List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)
            ks = oSign.PKI.getTrustedCertsList("X509Certificate2")
            myX509Chain.ChainPolicy.ExtraStore.AddRange(ks.ToArray)

            ' la raiz de nuestra pki  debe estar instalada en el store (user o machine) del equipo
            ' para que la cadena resulte valida. Seteamos elsiguiente flag para para que el build chain devuelva true, aunque la raiz sea desconocida. 
            myX509Chain.ChainPolicy.VerificationFlags = System.Security.Cryptography.X509Certificates.X509VerificationFlags.AllowUnknownCertificateAuthority

            ' modo de revocacion: no check
            myX509Chain.ChainPolicy.RevocationMode = System.Security.Cryptography.X509Certificates.X509RevocationMode.NoCheck
            myX509Chain.Build(oCert)


            myCertificateChain = New List(Of Org.BouncyCastle.X509.X509Certificate)()
            For Each myChainElement As X509ChainElement In myX509Chain.ChainElements
                myCertificateChain.Add(Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(myChainElement.Certificate))
            Next



            Dim crlList As IList(Of iTextSharp.text.pdf.security.ICrlClient) = Nothing
            If oSign.includeRevocationInfo = enumRevocationInfo.CRL Or oSign.includeRevocationInfo = enumRevocationInfo.OCSP_AND_CRL Then
                crlList = New List(Of iTextSharp.text.pdf.security.ICrlClient)()
                crlList.Add(New iTextSharp.text.pdf.security.CrlClientOnline(myCertificateChain))
            End If


            Dim ocspClient As iTextSharp.text.pdf.security.OcspClientBouncyCastle = Nothing
            If oSign.includeRevocationInfo = enumRevocationInfo.OCSP Or oSign.includeRevocationInfo = enumRevocationInfo.OCSP_AND_CRL Then
                Dim OCSP_URL = iTextSharp.text.pdf.security.CertificateUtil.GetOCSPURL(bc_sign_certificate)
                If Not OCSP_URL Is Nothing Then
                    ocspClient = New iTextSharp.text.pdf.security.OcspClientBouncyCastle()
                End If
            End If


            If oSign.use_timestamp_server Then
                If oSign.TSA_URL <> "" Then
                    tsaClient = New iTextSharp.text.pdf.security.TSAClientBouncyCastle(oSign.TSA_URL, oSign.TSA_uid, oSign.TSA_pwd, 4096, oSign.TSA_hash_algorithm)
                Else
                    For intI As Integer = 0 To myCertificateChain.Count - 1
                        Dim cert As Org.BouncyCastle.X509.X509Certificate = myCertificateChain(intI)
                        Dim tsaUrl As String = iTextSharp.text.pdf.security.CertificateUtil.GetTSAURL(cert)
                        If tsaUrl IsNot Nothing Then
                            tsaClient = New iTextSharp.text.pdf.security.TSAClientBouncyCastle(tsaUrl, oSign.TSA_uid, oSign.TSA_pwd, 4096, oSign.TSA_hash_algorithm)
                            Exit For
                        End If
                    Next
                End If
            End If



            If Not crlList Is Nothing Then
                Dim i As Integer = 0
                While (crlBytes Is Nothing And i < myCertificateChain.Count)
                    crlBytes = iTextSharp.text.pdf.security.MakeSignature.ProcessCrl(myCertificateChain(i), crlList)
                    i = i + 1
                End While
            End If


            If Not ocspClient Is Nothing Then
                If myCertificateChain.Count >= 2 And Not ocspClient Is Nothing Then
                    ocspBytes = ocspClient.GetEncoded(myCertificateChain(0), myCertificateChain(1), Nothing)
                End If
            End If




            '***************************************************************************************************************************************
            '***********************************************  ESTIMAR TAMAÑO DE FIRMA  ******************************************************
            '***************************************************************************************************************************************

            If oSign.PDFSignParams.estimatedSize = 0 Then
                oSign.PDFSignParams.estimatedSize = 8192
                If Not crlBytes Is Nothing Then
                    For Each element In crlBytes
                        oSign.PDFSignParams.estimatedSize += element.Length + 10
                    Next
                End If

                If Not ocspClient Is Nothing Then
                    oSign.PDFSignParams.estimatedSize += 4192
                End If

                If Not tsaClient Is Nothing Then
                    oSign.PDFSignParams.estimatedSize += 4192
                End If

            End If



            '***************************************************************************************************************************************
            '*********************************************** OBTENER DIGESTO DEL DOCUMENTO  ********************************************************
            '***************************************************************************************************************************************
            genDocumentHash(strHashAlgorithm)



            '***************************************************************************************************************************************
            '*********************************************** OBTENER PCKS7 LISTO PARA FIRMAR *******************************************************
            '***************************************************************************************************************************************
            sgn = New iTextSharp.text.pdf.security.PdfPKCS7(Nothing, myCertificateChain, strHashAlgorithm, False)
            Dim autAttributes As Byte() = sgn.getAuthenticatedAttributeBytes(hash, ocspBytes, crlBytes, oSign.PDFSignParams.cryptoStandard)

            ' En el cliente se va a firmar = hashear datos + encriptar el  digesto
            If outputDigestIsDEREncoded Then
                ' se genera el hash: el cliente debe aplicar rsa
                Return getDEREncodedHash(autAttributes, strHashAlgorithm)
            Else
                Dim digest As Byte()
                Using mem As New MemoryStream(autAttributes)
                    digest = iTextSharp.text.pdf.security.DigestAlgorithms.Digest(mem, strHashAlgorithm)
                End Using
                Return digest
            End If

        End Function

        Private Sub genDocumentHash(strHashAlgorithm As String)

            blankSigned = nvPDFUtil.signDocument(doc, oSign, oCert, True)

            ' Extraer el data a hashear leyendo los params de ByteRange, como se realiza en signDeferred
            Dim reader As New iTextSharp.text.pdf.PdfReader(blankSigned)

            Dim af As iTextSharp.text.pdf.AcroFields = reader.AcroFields

            Dim v As iTextSharp.text.pdf.PdfDictionary = af.GetSignatureDictionary(oSign.name)
            If v Is Nothing Then
                Throw New iTextSharp.text.DocumentException("No field")
            End If

            If Not af.SignatureCoversWholeDocument(oSign.name) Then
                Throw New iTextSharp.text.DocumentException("Not the last signature")
            End If

            Dim b As iTextSharp.text.pdf.PdfArray = v.GetAsArray(iTextSharp.text.pdf.PdfName.BYTERANGE)
            Dim gaps As Long() = b.AsLongArray()
            If b.Size <> 4 Or gaps(0) <> 0 Then
                Throw New iTextSharp.text.DocumentException("Single exclusion space supported")
            End If

            Dim readerSource As iTextSharp.text.io.IRandomAccessSource = reader.SafeFile.CreateSourceView()
            Dim rg As New iTextSharp.text.io.RASInputStream(New iTextSharp.text.io.RandomAccessSourceFactory().CreateRanged(readerSource, gaps))

            hash = iTextSharp.text.pdf.security.DigestAlgorithms.Digest(rg, strHashAlgorithm)

            rg.Close()
            reader.Close()

        End Sub


        Public Shared Function getDEREncodedHash(autAttributes As Byte(), strHashAlgorithm As String) As Byte()

            ' se genera el hash: el cliente debe aplicar rsa
            Dim outputHash As Byte()
            Using msAutAttributes As New MemoryStream(autAttributes)
                Dim digest As Byte() = iTextSharp.text.pdf.security.DigestAlgorithms.Digest(msAutAttributes, strHashAlgorithm)

                ' crear hash valido para firma ( hash del digesto + hashAlgorithmID)
                Dim sha1oid_ As New Org.BouncyCastle.Asn1.DerObjectIdentifier(iTextSharp.text.pdf.security.DigestAlgorithms.GetAllowedDigests(strHashAlgorithm))
                Dim sha1aid_ As New Org.BouncyCastle.Asn1.X509.AlgorithmIdentifier(sha1oid_, Nothing)
                Dim di As New Org.BouncyCastle.Asn1.X509.DigestInfo(sha1aid_, digest)
                outputHash = di.GetDerEncoded()
            End Using
            Return outputHash

        End Function



        Public Shared Function signData(data As Byte(), ByVal sign_certificate As X509Certificate2, Optional hashAlgorithm As nvFW.nvHashAlgorithm = nvFW.nvHashAlgorithm.SHA1) As Byte()

            'firma datos
            Dim strHashAlgorithm As String = "SHA-1"
            Select Case hashAlgorithm
                Case nvHashAlgorithm.SHA1
                    strHashAlgorithm = "SHA-1"
                Case nvHashAlgorithm.SHA256
                    strHashAlgorithm = "SHA-256"
                Case nvHashAlgorithm.SHA384
                    strHashAlgorithm = "SHA-384"
                Case nvHashAlgorithm.SHA512
                    strHashAlgorithm = "SHA-512"
                Case nvHashAlgorithm.RIPEMD160
                    strHashAlgorithm = "RIPEMD-160"
            End Select

            Dim signature As iTextSharp.text.pdf.security.PrivateKeySignature = New iTextSharp.text.pdf.security.PrivateKeySignature(Org.BouncyCastle.Security.DotNetUtilities.GetRsaKeyPair(sign_certificate.PrivateKey).Private, strHashAlgorithm)
            Dim extSignature As Byte() = signature.Sign(data)
            Return extSignature
        End Function



        ' Firmar digesto al que se le ha aplicado previamente el algoritmo de hash
        Public Shared Function signHash(hash As Byte(), ByVal sign_certificate As X509Certificate2, Optional hashIsDEREncoded As Boolean = True, Optional hashAlgorithm As nvFW.nvHashAlgorithm = nvFW.nvHashAlgorithm.SHA1) As Byte()

            If hashIsDEREncoded Then
                Dim encryptionAlgorithm As String = "NONEWITHRSA"
                Select Case sign_certificate.PrivateKey.GetType.ToString
                    Case "System.Security.Cryptography.RSACryptoServiceProvider"
                        encryptionAlgorithm = "NONEWITHRSA"
                    Case "System.Security.Cryptography.DSACryptoServiceProvider"
                        encryptionAlgorithm = "NONEWITHDSA"
                End Select
                Dim pk As Org.BouncyCastle.Crypto.AsymmetricKeyParameter = Org.BouncyCastle.Security.DotNetUtilities.GetRsaKeyPair(sign_certificate.PrivateKey).Private
                Dim SIg As Org.BouncyCastle.Crypto.ISigner = Org.BouncyCastle.Security.SignerUtilities.GetSigner(encryptionAlgorithm)
                SIg.Init(True, pk)
                SIg.BlockUpdate(hash, 0, hash.Length)
                Return SIg.GenerateSignature()

            Else

                Dim strHashAlgorithm As String = "SHA1"
                Select Case hashAlgorithm
                    Case nvHashAlgorithm.SHA1
                        strHashAlgorithm = "SHA1"
                    Case nvHashAlgorithm.SHA256
                        strHashAlgorithm = "SHA256"
                    Case nvHashAlgorithm.SHA384
                        strHashAlgorithm = "SHA384"
                    Case nvHashAlgorithm.SHA512
                        strHashAlgorithm = "SHA512"
                    Case nvHashAlgorithm.RIPEMD160
                        strHashAlgorithm = "RIPEMD160"
                End Select


                Dim sig() As Byte = Nothing
                Select Case sign_certificate.PrivateKey.GetType.ToString
                    Case "System.Security.Cryptography.RSACryptoServiceProvider"
                        Dim RSA As RSACryptoServiceProvider = DirectCast(sign_certificate.PrivateKey, RSACryptoServiceProvider)
                        sig = RSA.SignHash(hash, CryptoConfig.MapNameToOID(strHashAlgorithm))

                    Case "System.Security.Cryptography.DSACryptoServiceProvider"
                        Dim DSA As DSACryptoServiceProvider = DirectCast(sign_certificate.PrivateKey, DSACryptoServiceProvider)
                        sig = DSA.SignHash(hash, CryptoConfig.MapNameToOID(strHashAlgorithm))
                End Select
                Return sig
            End If

        End Function



        Private Function getPkcs7(signedHash As Byte()) As Byte()


            Dim strEncriptionAlogorithm As String = ""
            If oSign.asymmetricAlgorithm = nvFW.nvAsymmetricAlgorithm.RSA Then
                strEncriptionAlogorithm = "RSA"
            ElseIf oSign.asymmetricAlgorithm = nvFW.nvAsymmetricAlgorithm.DSA Then
                strEncriptionAlogorithm = "DSA"
            End If


            sgn.SetExternalDigest(signedHash, Nothing, strEncriptionAlogorithm)
            Dim encodedSig As Byte() = sgn.GetEncodedPKCS7(hash, tsaClient, ocspBytes, crlBytes, oSign.PDFSignParams.cryptoStandard)
            Return encodedSig



        End Function


        'Public Function composeSignedPDF(base64SignedHash As String) As Byte()
        '    Dim bin() As Byte = Convert.FromBase64String(base64SignedHash)
        '    Return composeSignedPDF(bin)
        'End Function

        'Public Function composeSignedPDF(signedHash As Byte()) As Byte()
        '    Dim signedPkcs7 As Byte() = getPkcs7(signedHash)
        '    Dim sCont As New tnvExternalSignatureContainer(signedPkcs7)

        '    If oSign.PDFSignParams.estimatedSize >= signedPkcs7.Length Then
        '        Dim result As Byte() = nvPDFUtil.signDeferred(blankSigned, oSign.name, sCont)
        '        Return result
        '    End If
        '    Return Nothing

        'End Function


        Public Function composeSignedPDF(base64SignedHash As String) As Byte()
            Dim bin() As Byte = Convert.FromBase64String(base64SignedHash)
            Return composeSignedPDF(bin)
        End Function

        Public Function composeSignedPDF(signedHash As Byte()) As Byte()


            ' El conteido firmado extraido de un pcks7 no se corresponde con la firma del hash que se ha enviado
            ' sino con la firma del resultdado de (hash + crlbytes + ocpbytes + tsa etc)
            ' La firma HASH de PFDR Argentina esta devolviendo un PKCS7 en
            ' Dim hashBytes As Byte()
            'If isPkcs7 = True Then
            '    obtener
            '    Dim pdfPkcs7 As New iTextSharp.text.pdf.security.PdfPKCS7(signedHash, iTextSharp.text.pdf.PdfName.ADBE_PKCS7_DETACHED)
            '    Dim p As System.Reflection.FieldInfo = GetType(iTextSharp.text.pdf.security.PdfPKCS7).GetField("digestAttr", Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic)
            '    Dim authenticatedAttributes = DirectCast(p.GetValue(pdfPkcs7), Byte())

            '    Dim data As Byte()
            '    Dim signature As New CmsSignedData(signedHash)
            '    For Each it In signature.GetSignerInfos().GetSigners()
            '        Dim signer As SignerInformation = it
            '        data = signer.GetSignature()
            '        Dim sc As CmsProcessable = signature.SignedContent
            '        Dim data = sc.GetContent
            '    Next

            '    hashBytes = data
            'Else
            '    hashBytes = signedHash
            'End If

            Dim sCont As tnvExternalSignatureContainer
            If asPKCS7HashSignature Then
                sCont = New tnvExternalSignatureContainer(getPkcs7(signedHash))
            Else
                sCont = New tnvExternalSignatureContainer(signedHash)
            End If


            'If oSign.PDFSignParams.estimatedSize >= signedPkcs7.Length Then
            Dim result As Byte() = nvPDFUtil.signDeferred(blankSigned, oSign.name, sCont)
            Return result
            'End If
            'Return Nothing

        End Function


    End Class



End Namespace