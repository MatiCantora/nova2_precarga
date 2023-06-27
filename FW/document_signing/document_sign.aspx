 <%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="System.Runtime.Serialization.Json" %>

<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Net" %>


 <script language="VB" runat="server">
    
     
     Private Sub GetPOSTResponse(uri As Uri, data As String, apiKey As String, callback As Action(Of WebResponse))
         Dim request As HttpWebRequest = DirectCast(HttpWebRequest.Create(uri), HttpWebRequest)
        
         request.Method = "POST"
         'request.ContentType = "text/plain;charset=utf-8"
         request.ContentType = "application/json;charset=utf-8"
         request.Headers.Add("Authorization", "key=" & apiKey)
        
         Dim encoding As New System.Text.UTF8Encoding()
         Dim bytes As Byte() = encoding.GetBytes(data)

         request.ContentLength = bytes.Length

         Using requestStream As Stream = request.GetRequestStream()
             ' Send the data.
             requestStream.Write(bytes, 0, bytes.Length)
         End Using

         request.BeginGetResponse(
             Function(x)
                 Using response As HttpWebResponse = DirectCast(request.EndGetResponse(x), HttpWebResponse)
                     If callback IsNot Nothing Then
                         Dim ser As New DataContractJsonSerializer(GetType(WebResponse))
                         callback(TryCast(ser.ReadObject(response.GetResponseStream()), WebResponse))
                     End If
                 End Using
                 Return 0
             End Function, Nothing)
     End Sub
     
     
     Function SendPushNotification(title As String, body As String, icon As String, cod_binding As String, dataParams As Dictionary(Of String, String)) As tError
         Dim err As New tError
         
         Dim apikey As String = ""
         Dim notificationToken As String = ""
         Dim cod_os As String = ""
         Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM verNotification_binding WHERE cod_binding=" & cod_binding)
         If Not rs.EOF Then
             apikey = rs.Fields("api_key").Value
             notificationToken = rs.Fields("notification_token").Value
             cod_os = rs.Fields("cod_os").Value
         End If
         nvDBUtiles.DBCloseRecordset(rs)
         
         
         Dim jsonReq As String = "{"
         jsonReq &= """to"": """ & notificationToken & """"
         
         If cod_os = "2" Then 'iOS
             jsonReq &= ", ""notification"": {"
             jsonReq &= " ""title"": """ & title & """"
             jsonReq &= ", ""body"": """ & body & """"
             jsonReq &= ", ""icon"": """ & icon & """}"
             jsonReq &= ", ""data"": {"
             
         Else
             jsonReq &= ", ""data"": {" 'Android
             jsonReq &= " ""title"": """ & title & """"
             jsonReq &= ", ""body"": """ & body & """"
             jsonReq &= ", ""icon"": """ & icon & """"
         End If
         
        
         For Each key As String In dataParams.Keys
             jsonReq &= ", """ & key & """: """ & dataParams(key) & """"
         Next
       
         jsonReq &= "}}"
        
         
         
         Try
             GetPOSTResponse(New Uri("https://fcm.googleapis.com/fcm/send"), jsonReq, apikey, Nothing)
         Catch ex As Exception
             err.parse_error_script(ex)
         End Try
         
         Return err
         
     End Function
     
         
</script>


<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>

<%@ Import Namespace="nvFW" %>
<%

    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    
    If accion = "" Then
        Dim err As New tError
    
        Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
        Dim cod_binding As String = nvUtiles.obtenerValor("cod_binding", "")
        Dim idCert As String = nvUtiles.obtenerValor("idCert", "")
        Dim f_id As String = nvUtiles.obtenerValor("f_id", "")
        Dim saveAs As String = nvUtiles.obtenerValor("saveAs", "")
    
    

        Dim f_path As String
        Dim f_nro_ubi As String
        Dim binarydata As Byte()
        
        Dim idpki As String
        Dim certBin() As Byte
        Dim cert_name As String = ""
    
        Dim oXML As New System.Xml.XmlDocument
        oXML.LoadXml(strXML)
    
    
        Dim node As System.Xml.XmlNode = oXML.SelectSingleNode("firma_params")
    
    
        Dim location As String = ""
        Dim reason As String = ""
        Dim hashAlgorithm As nvFW.nvHashAlgorithm
        Dim setLTV As Boolean = True
    
        If Not node.Attributes("location") Is Nothing Then
            location = node.Attributes("location").Value
        End If
    
        If Not node.Attributes("reason") Is Nothing Then
            reason = node.Attributes("reason").Value
        End If

        'Dim strAlgoritmoHash As String = ""
        'If Not node.Attributes("hashAlgorithm") Is Nothing Then
        '    strAlgoritmoHash = node.Attributes("hashAlgorithm").Value
        '    Select Case strAlgoritmoHash
        '        Case "0"
        '            hashAlgorithm = nvFW.nvHashAlgorithm.SHA1
        '        Case "1"
        '            hashAlgorithm = nvFW.nvHashAlgorithm.SHA256
        '        Case "2"
        '            hashAlgorithm = nvFW.nvHashAlgorithm.SHA384
        '        Case "3"
        '            hashAlgorithm = nvFW.nvHashAlgorithm.SHA512
        '        Case "4"
        '            hashAlgorithm = nvFW.nvHashAlgorithm.RIPEMD160
        '        Case Else
        '            hashAlgorithm = nvFW.nvHashAlgorithm.SHA256
        '    End Select
        'End If
   
    
        If Not node.Attributes("setLTV") Is Nothing Then
            setLTV = IIf(node.Attributes("setLTV").Value.ToLower = "true", True, False)
        End If
    
    
        Dim fieldname As String = ""
        If Not node.Attributes("setLTV") Is Nothing Then
            fieldname = node.Attributes("fieldname").Value.ToLower
        End If
    
    
        Dim certificationLevel As nvFW.nvPDFCertificationLevel = nvPDFCertificationLevel.not_certified
        Dim cryptoStandard As nvFW.nvPDFCryptoStandard = nvPDFCryptoStandard.CADES
        Dim appendToExistingOnes As Boolean = True
    
        ' Si es invisible no se le puede asignar nombre: da error
        Dim visible As Boolean = False
    
    
        Dim x1 As String = "0", y1 As String = "0", x2 As String = "0", y2 As String = "0", page As String = "1"
        Dim display As nvFW.nvPDFSingDisplay
        Dim fontFamily As iTextSharp.text.Font.FontFamily
        Dim fontColor As String 'iTextSharp.text.BaseColor = Nothing
        Dim fontSize As Double
        Dim fontStyle As Integer
        Dim signatureText As String = ""
        Dim signatureEstimatedSize As String = "0"
    
    
        Dim pdfParamsNode As System.Xml.XmlNode = oXML.SelectSingleNode("firma_params/PDF_params")
        If Not pdfParamsNode Is Nothing Then
        
            If Not pdfParamsNode.Attributes("appendToExistingOnes") Is Nothing Then
                appendToExistingOnes = pdfParamsNode.Attributes("appendToExistingOnes").Value
            End If
        
            If Not pdfParamsNode.Attributes("certificationLevel") Is Nothing Then
                Dim strCertificationLevel As String = pdfParamsNode.Attributes("certificationLevel").Value
                Select Case strCertificationLevel.ToLower
                    Case "0"
                        certificationLevel = nvFW.nvPDFCertificationLevel.not_certified
                    Case "1"
                        certificationLevel = nvFW.nvPDFCertificationLevel.not_change_allowed
                    Case "2"
                        certificationLevel = nvFW.nvPDFCertificationLevel.form_filling_allowed
                    Case "3"
                        certificationLevel = nvFW.nvPDFCertificationLevel.form_filling_and_anotation_allowed
                End Select
            End If
        
        
            If Not pdfParamsNode.Attributes("cryptoStandard") Is Nothing Then
                Dim strCryptoStandard As String = pdfParamsNode.Attributes("cryptoStandard").Value
                Select Case strCryptoStandard.ToLower
                    Case "0"
                        cryptoStandard = nvFW.nvPDFCryptoStandard.CMS
                    Case "1"
                        cryptoStandard = nvFW.nvPDFCryptoStandard.CADES
                End Select

            End If
        
            If Not pdfParamsNode.Attributes("visible") Is Nothing And pdfParamsNode.Attributes("visible").Value.ToLower = "true" Then
                visible = True
            End If
        
            
            If Not pdfParamsNode.Attributes("signatureEstimatedSize") Is Nothing Then
                signatureEstimatedSize = pdfParamsNode.Attributes("signatureEstimatedSize").Value
            End If
            
            
            
            If visible Then
                Dim pdfAppereanceParamsNode As System.Xml.XmlNode = oXML.SelectSingleNode("firma_params/PDF_params/PDF_appereance")
            
                x1 = pdfAppereanceParamsNode.Attributes("x1").Value
                x2 = pdfAppereanceParamsNode.Attributes("x2").Value
                y1 = pdfAppereanceParamsNode.Attributes("y1").Value
                y2 = pdfAppereanceParamsNode.Attributes("y2").Value
                page = pdfAppereanceParamsNode.Attributes("page").Value
            
                'fieldname = pdfAppereanceParamsNode.Attributes("fieldname").Value
            
                Dim strFontFamily = pdfAppereanceParamsNode.Attributes("fontFamily").Value
                Select Case strFontFamily
                    Case "0"
                        fontFamily = iTextSharp.text.Font.FontFamily.COURIER
                    Case "1"
                        fontFamily = iTextSharp.text.Font.FontFamily.HELVETICA
                    Case "2"
                        fontFamily = iTextSharp.text.Font.FontFamily.TIMES_ROMAN
                    Case "3"
                        fontFamily = iTextSharp.text.Font.FontFamily.SYMBOL
                    Case "4"
                        fontFamily = iTextSharp.text.Font.FontFamily.ZAPFDINGBATS
                    Case "-1"
                        fontFamily = iTextSharp.text.Font.FontFamily.UNDEFINED
                End Select
            
                Dim strFontColor As String = pdfAppereanceParamsNode.Attributes("fontColor").Value
            
                fontColor = strFontColor
                'Select Case strFontColor
                '    Case "0"
                '        fontColor = iTextSharp.text.BaseColor.BLACK
                '    Case "1"
                '        fontColor = iTextSharp.text.BaseColor.WHITE
                '    Case "2"
                '        fontColor = iTextSharp.text.BaseColor.GRAY
                '    Case "3"
                '        fontColor = iTextSharp.text.BaseColor.RED
                '    Case "4"
                '        fontColor = iTextSharp.text.BaseColor.PINK
                '    Case "5"
                '        fontColor = iTextSharp.text.BaseColor.ORANGE
                '    Case "6"
                '        fontColor = iTextSharp.text.BaseColor.YELLOW
                '    Case "7"
                '        fontColor = iTextSharp.text.BaseColor.GREEN
                '    Case "8"
                '        fontColor = iTextSharp.text.BaseColor.MAGENTA
                '    Case "9"
                '        fontColor = iTextSharp.text.BaseColor.CYAN
                '    Case "10"
                '        fontColor = iTextSharp.text.BaseColor.BLUE
                '    Case "11"
                '        fontColor = iTextSharp.text.BaseColor.LIGHT_GRAY
                '    Case "12"
                '        fontColor = iTextSharp.text.BaseColor.DARK_GRAY
                'End Select
            
            
                fontSize = pdfAppereanceParamsNode.Attributes("fontSize").Value
            
            
                Dim strFontStyle = pdfAppereanceParamsNode.Attributes("fontStyle").Value
                Select Case strFontStyle
                    Case "0"
                        fontStyle = iTextSharp.text.Font.NORMAL
                    Case "1"
                        fontStyle = iTextSharp.text.Font.BOLD
                    Case "2"
                        fontStyle = iTextSharp.text.Font.ITALIC
                    Case "3"
                        fontStyle = iTextSharp.text.Font.BOLDITALIC
                    Case "4"
                        fontStyle = iTextSharp.text.Font.UNDERLINE
                    Case "8"
                        fontStyle = iTextSharp.text.Font.STRIKETHRU
                    Case "12"
                        fontStyle = iTextSharp.text.Font.DEFAULTSIZE
                    
                    Case "-1"
                        fontStyle = iTextSharp.text.Font.UNDEFINED


                End Select
            
                Dim strDisplay = pdfAppereanceParamsNode.Attributes("display").Value
                Select Case strDisplay
                    Case "0"
                        display = nvFW.nvPDFSingDisplay.description_only
                    Case "1"
                        display = nvFW.nvPDFSingDisplay.signaturename_and_description
                    Case "2"
                        display = nvFW.nvPDFSingDisplay.image_and_description
                    Case "3"
                        display = nvFW.nvPDFSingDisplay.image_only
                    
                End Select
            
            
                signatureText = pdfAppereanceParamsNode.Attributes("signatureText").Value
            
            End If
        
        
        End If
    

        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from verPKI_certificados_carpetas where idcert=" + idCert)
        If Not rs.EOF Then
            idpki = rs.Fields("idpki").Value
            certBin = rs.Fields("cert_bin").Value
            cert_name = rs.Fields("cert_name").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)
    
        rs = nvDBUtiles.DBOpenRecordset("select * from verref_files where f_id=" + f_id)
        If Not rs.EOF Then
            f_path = rs.Fields("f_path").Value
            f_nro_ubi = rs.Fields("f_nro_ubi").Value
            binarydata = isNUll(rs.Fields("binarydata").Value, Nothing)
        End If
        nvDBUtiles.DBCloseRecordset(rs)
    
    
        Dim PKI As tnvPKI = nvPKIDBUtil.LoadPKIFromDB(idpki:=idpki, loadDBOptions:=nvFW.nvPKIDBUtil.nveunmloadDBOptions.loadTrusted)
    
   
        Dim doc As New tnvLegDocument("doc1", "doc1.pdf")
        
        If f_nro_ubi = "1" Then
            doc.load(System.IO.File.ReadAllBytes(f_path))
        Else
            doc.load(binarydata)
        End If
            
        

    
    
    
    
        Dim oSign As New tnvSignature(doc)
        oSign.PKI = PKI
        oSign.name = fieldname
        oSign.use = nvSignUse.user_sign
        oSign.includeRevocationInfo = enumRevocationInfo.None
        oSign.signDate = Now
    
        oSign.use_timestamp_server = False
        oSign.TSA_URL = ""
        oSign.TSA_hash_algorithm = "SHA-256"
        If setLTV Then
            oSign.includeRevocationInfo = enumRevocationInfo.OCSP_AND_CRL
        End If
    
    
        oSign.hashAlgorithm = hashAlgorithm
        oSign.PDFSignParams = New tnvPDFSignParam
        With oSign.PDFSignParams
            .fieldname = fieldname
            .reason = reason
            .Location = location
            .hashAlgorithm = hashAlgorithm
        
            .appendToExistingOnes = appendToExistingOnes    ' El PDFstamper reordena los objetos dict del pdf, por lo que rompe una firma previa si existe. Hay que usar appendmode=true para que las firmas previas no se rompan.
            .certificationLevel = certificationLevel
            .cryptoStandard = cryptoStandard
            .visible_signature = visible
            .estimatedSize = signatureEstimatedSize
        End With
    
       
    
  
    
        ' Apariencia PDF
        If visible Then
        
            ' Para el rectangulo de itext se debe cumplir
            'x1, y1 = lowerx, lowery
            'x2, y2 = upperx, uppery
            Dim llx As Single = Single.Parse(x1, System.Globalization.CultureInfo.InvariantCulture.NumberFormat)
            Dim lly As Single = Single.Parse(y1, System.Globalization.CultureInfo.InvariantCulture.NumberFormat)
            Dim urx As Single = Single.Parse(x2, System.Globalization.CultureInfo.InvariantCulture.NumberFormat)
            Dim ury As Single = Single.Parse(y2, System.Globalization.CultureInfo.InvariantCulture.NumberFormat)
        
        
            oSign.PDFSignParams.display = display
            oSign.PDFSignParams.page = page
            oSign.PDFSignParams.x1 = llx
            oSign.PDFSignParams.y1 = lly
            oSign.PDFSignParams.x2 = urx
            oSign.PDFSignParams.y2 = ury
        
            oSign.PDFSignParams.signature_text_fontFamily = fontFamily
            oSign.PDFSignParams.signature_text_fontstyle = fontStyle
            'oSign.PDFSignParams.signature_text_fontColor = fontColor
            
            oSign.PDFSignParams.signature_text_fontColor.setColor(fontColor)
            oSign.PDFSignParams.signature_text_fontSize = fontSize
            oSign.PDFSignParams.signature_text = signatureText
        End If
    
    

        ' Recuperar certificado y generar firma diferida
        Dim oCert As X509Certificate2 = New X509Certificate2(certBin)
    
    
   
        ' Obtener el algoritmo de hash desde el certificado, ignorando la seleccion de usuario
        Dim mapField = GetType(Org.BouncyCastle.Cms.CmsSignedData).Assembly.GetType("Org.BouncyCastle.Cms.CmsSignedHelper").GetField("digestAlgs", Reflection.BindingFlags.Static Or Reflection.BindingFlags.NonPublic)
        Dim map = mapField.GetValue(Nothing)
        Dim strAlgoritmoHash As String = DirectCast(map(oCert.SignatureAlgorithm.Value), String) ' returns "SHA256" for OID of sha256 with RSA.
        'Dim tAlgoritmoHash As System.Security.Cryptography.HashAlgorithm = System.Security.Cryptography.HashAlgorithm.Create(hashAlgName) ' your SHA256
    
        Select Case strAlgoritmoHash
            Case "SHA1"
                hashAlgorithm = nvFW.nvHashAlgorithm.SHA1
            Case "SHA256"
                hashAlgorithm = nvFW.nvHashAlgorithm.SHA256
            Case "SHA384"
                hashAlgorithm = nvFW.nvHashAlgorithm.SHA384
            Case "SHA512"
                hashAlgorithm = nvFW.nvHashAlgorithm.SHA512
            Case "RIPEMD160"
                hashAlgorithm = nvFW.nvHashAlgorithm.RIPEMD160
            Case Else
                hashAlgorithm = nvFW.nvHashAlgorithm.SHA256
        End Select

        oSign.hashAlgorithm = hashAlgorithm
        oSign.PDFSignParams.hashAlgorithm = hashAlgorithm
    
  
        Dim modo_firma As String = nvUtiles.obtenerValor("modo_firma", "")
    
    
    
        If modo_firma = "" Then
        
        
        End If
    
    
    
    
    
    
        '/**  Modo de Firma para archivos grandes: se envía unicamente el hash del documento
        ' *   el cual se firma remotamente. Luego se recibe el hash firmado y se integra en el pdf de salida
        '**/
     
        If modo_firma = "deferred_sign" Then
            
            Dim defSign As New nvPDFDeferredSign(doc.bytes, oCert, oSign)
            defSign.outputDigestIsDEREncoded = True 'codificar en DER PKCS#1 el digesto de salida
            
            
            ' se genera el hash del contenido del pdf a firmar
            ' IMPORTANTE: notar que, en general, el hash difiere cada vez que se lo genera
            ' ya que el doc blanksigned que se regenera no es exactamente el mismo 
            ' (cada vez que se genera un blanksigned con SignExternalContainer, appareance.SignDate es distinto, asi como tambien los datos de crl, ocsp, y tsa pueden cambiar)
            ' 
            ' Por lo tanto, hay que guardar el pdf con el espacio de firma reservado para luego acoplar la firma. 
            ' En general, no es posible regenerar el pdf
            ' con espacio de firma reservado, con el pdf original más los parametros de firma, ya que el blanksigned resulta distinto y cuando acoplamos
            ' la firma del blanksigned original, resulta en firma invalida. 
            ' 
            ' Prueba realizada : guardar el apperance.SignDate, los Osign parametros (incluido Osign.Signdate), la crl, ocsp y timestamp usados para el blanksigned original. Estos parametros setearlos para obtener la replica del blankSigned. Lo probé
            ' y los blanksigned  siguen siendo distintos...
            ' La respuesta es que no se pueden crear dos pdfs iguales. Los pdf creados en diferentes momentos tienen diferentes CreationDate  y por ende diferentes identificadores. Tambien el orden de los elementos en el diccionario de objets puede variar
            ' Ver mas en  http://developers.itextpdf.com/question/why-are-pdf-files-different-even-if-content-same
            '
            
            Dim hash As Byte() = defSign.genHash()
            
        
            ' generar un request pending
            Dim operador As String = nvApp.operador.operador
            Dim cod_sistema As String = nvApp.cod_sistema
            Dim rpending As nvFW.nvResponsePending.nvResponsePendingElement = nvFW.nvResponsePending.add("")
            
            rpending.operador = operador
            rpending.cod_sistema = cod_sistema
            
            rpending.element("sign_pending") = defSign
            rpending.element("f_id") = f_id
            rpending.element("saveAs") = saveAs
            If saveAs <> "" Then
                rpending.element("f_nombre") = saveAs
                rpending.element("f_depende_de") = nvUtiles.obtenerValor("f_depende_de", "")
                rpending.element("f_ext") = nvUtiles.obtenerValor("f_ext", "")
                rpending.element("f_nro_ubi") = nvUtiles.obtenerValor("f_nro_ubi", "0")
            End If
            

            'Dim nv_hash As String = ""
            'Dim res As tError = nvLogin.execute(nvApp, "get_hash", "", "", "", "", "", "")
            'If res.numError = 0 Then
            '    nv_hash = res.params("hash")
            'End If
            
            Dim serverUri As Uri = New Uri(nvApp.server_host_https)
            Dim responseUrl = New Uri(serverUri, "/FW/document_signing/document_signature_compose.aspx?accion=compose_signature&app_cod_sistema=" & cod_sistema & "")

            Dim recset = nvDBUtiles.DBOpenRecordset("SELECT f_nombre + '.' + f_ext FROM ref_files WHERE f_id=" + f_id)
            Dim file_name As String = "Unknown"
            If Not recset.EOF Then
                file_name = recset.Fields(0).Value
            End If
            
            
            Dim params As New Dictionary(Of String, String)
            params.Add("sign_document_message", "true")
            params.Add("f_id_name", file_name)
            params.Add("digest", Convert.ToBase64String(hash))
            'params.Add("digest_hash_algorithm", oSign.hashAlgorithm) 'defSign.strHashAlgorithm
            params.Add("proc_id", rpending.id)
            params.Add("response_url", responseUrl.ToString)
            params.Add("cert_name", cert_name)
            
            Dim title As String = "Solicitud de firma de documento"
            Dim body As String = "Ha recibido una solicitud de firma para el documento " + file_name
            Dim icon As String = ""
            
            
            Dim PushErr As tError = SendPushNotification(title, body, icon, cod_binding, params)
        
            If err.numError = 0 Then
                err.params("requestPendingId") = rpending.id
            End If
            
            err.response()
        End If
        
        
       
    End If
    
    
    
    
    
    'If accion = "compose_signature" Then
    '    stop
    '    Dim proc_id As String = nvUtiles.obtenerValor("proc_id", "")
    '    Dim err As New tError
        
        
    '    'If nvFW.nvResponsePending.get(proc_id) Is Nothing Then
    '    '    err.numError = -1
    '    '    err.mensaje = "No existe el proceso pendiente asociado a la firma"
    '    '    err.response()
    '    'End If
        
    '    'If nvFW.nvResponsePending.get(proc_id).state = nvResponsePending.enumPendingSatate.terminado Or nvFW.nvResponsePending.get(proc_id).state = nvResponsePending.enumPendingSatate.timeout Then
    '    '    err.numError = -1
    '    '    err.mensaje = "El proceso pendiente de firma a expirado"
    '    'End If
        
    '    If nvFW.nvResponsePending.get(proc_id).element.ContainsKey("sign_pending") Then
            
    '        Dim defSign As nvPDFDeferredSign = nvFW.nvResponsePending.get(proc_id).element("sign_pending")
    '        Dim f_id As String = nvFW.nvResponsePending.get(proc_id).element("f_id")
    '        Dim signedDigest As String = nvUtiles.obtenerValor("signed_digest", "")
            
    '        ' ensamblar pdf con firma
    '        Dim signedPDF As Byte() = defSign.composeSignedPDF(signedDigest)
    '        If Not signedPDF Is Nothing Then
                
    '            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM ref_files WHERE f_id=" + f_id)
    '            Dim f_path As String
    '            Dim f_nro_ubi As String = "1"
    '            If Not rs.EOF Then
    '                f_path = rs.Fields("f_path").Value
    '                f_nro_ubi = rs.Fields("f_nro_ubi").Value
    '            End If
    '            If f_nro_ubi = "1" Then
    '                Try
    '                    DBExecute("UPDATE ref_files SET f_falta=GETDATE() WHERE f_id=" + f_id + ";")
    '                    Using fs As New FileStream(f_path, System.IO.FileMode.Create)
    '                        fs.Write(signedPDF, 0, signedPDF.Length)
    '                    End Using
    '                Catch e As Exception
    '                    err.parse_error_script(e)
    '                End Try
    '            Else
    '                ' updatear binario del file en la wiki
    '                Dim sqltran As String = ""
    '                sqltran &=
    '                    "BEGIN TRAN;" &
    '                    "UPDATE ref_files SET f_falta=GETDATE() WHERE f_id=" + f_id + ";" &
    '                    "UPDATE ref_file_bin SET binaryData=?  WHERE f_id=" + f_id + ";" &
    '                    "COMMIT TRAN;"
                    
    '                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(sqltran, ADODB.CommandTypeEnum.adCmdText)
    '                Dim objParm1 = cmd.CreateParameter("@binaryData", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, signedPDF.Length, signedPDF)
    '                cmd.Parameters.Append(objParm1)
    '                Try
    '                    cmd.Execute()
    '                Catch e As Exception
    '                    err.parse_error_script(e)
    '                End Try
    '            End If
    '        Else
    '            err.numError = "-1"
    '            err.mensaje = "No se pudo generar el archivo firmado. Compruebe que el espacio reservado para la firme sea el suficiente"
    '        End If
    '    End If
        
    '    ' marcar proceso pendiente como terminado
    '    nvFW.nvResponsePending.get(proc_id).state = nvResponsePending.enumPendingSatate.terminado

    '    err.response()
    'End If
    
    


    %>