Imports System.IO
Imports System.Security.Cryptography.X509Certificates
Imports System.Runtime.InteropServices
Imports System.Text
Imports System.Xml
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    'Clase contenedor para transportar un legajo completo con todas las definiciones necesarias para su firma.
    'Propiedades:
    '   metadata: un diccionario de metadatos asociados al legajo
    '   documents: diccionario de documentos que contiene el legajo
    'Importante revisar siempre la version, porque pueden irse generando distintas versiones y como son archivo binarios no son compatibles.

    Public Class tnvLegContainer

        Public Const major_version As Byte = 1
        Public Const minor_version As Byte = 0
        Public titulo As String
        Public comentario As String

        Public reason_editable As Boolean
        Public reason As Dictionary(Of String, tnvReason)

        Public location_editable As Boolean
        Public location As Dictionary(Of String, tnvLocation)
        Public metadata As Dictionary(Of String, tnvMetadaData)
        Public params As Dictionary(Of String, tnvParam)
        Public documents As Dictionary(Of Integer, tnvLegDocument)
        Public documents_len As Dictionary(Of Integer, tnvLegDocument)
        Public returns As List(Of tnvLegReturn)


        Public Sub New()
            documents = New Dictionary(Of Integer, tnvLegDocument)
            documents_len = New Dictionary(Of Integer, tnvLegDocument)
            metadata = New Dictionary(Of String, tnvMetadaData)
            reason = New Dictionary(Of String, tnvReason)
            location = New Dictionary(Of String, tnvLocation)
            params = New Dictionary(Of String, tnvParam)
            returns = New List(Of tnvLegReturn)
        End Sub


        ''' <summary>
        ''' Agrega un nuevo metadato al legeajo
        ''' </summary>
        ''' <param name="key">Clave del metadato</param>
        ''' <param name="label">Etiqueta del metadato</param>
        ''' <param name="value">Valor del metadato</param>
        ''' <remarks></remarks>
        Public Sub metadataAdd(key As String, label As String, value As String)
            Dim m As New tnvMetadaData(key, label, value)
            metadata.Add(key, m)
        End Sub

        Public Sub reasonAdd(ByVal label As String, ByVal selected As Boolean)
            Dim m As New tnvReason(label, selected)
            reason.Add(label, m)
        End Sub

        Public Sub locationAdd(ByVal label As String, ByVal selected As Boolean)
            Dim m As New tnvLocation(label, selected)
            location.Add(label, m)
        End Sub

        Public Sub paramAdd(ByVal param As String, ByVal value As String)
            Dim m As New tnvParam(param, value)
            params.Add(param, m)
        End Sub

        ''' <summary>
        ''' Devuelve la etiqueta del metadato
        ''' </summary>
        ''' <param name="key">Clave del metadato</param>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property metadataLabel(key As String) As String
            Get
                Try
                    Return metadata(key).label
                Catch ex As Exception

                End Try
            End Get
        End Property

        ''' <summary>
        ''' Devuelve el valor del metadato
        ''' </summary>
        ''' <param name="key">Clave del metadato</param>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property metadataValue(key As String) As String
            Get
                Try
                    Return metadata(key).value
                Catch ex As Exception

                End Try
            End Get
        End Property


        ''' <summary>
        ''' Agrega un retorno de tipo mail
        ''' </summary>
        ''' <param name="filename">Nombre que tendrá el archivo</param>
        ''' <param name="to">Destinatario del mail</param>
        ''' <param name="subject">Asunto del mail</param>
        ''' <param name="body">Texto del cuerpo del mail</param>
        ''' <param name="cc">Copiar a destinatarios</param>
        ''' <param name="co">Copiar con sopia oculta</param>
        ''' <param name="body_url">Url de descarga del texto del cuerpo del mail</param>
        ''' <remarks></remarks>
        Public Sub returnMailAdd(filename As String, [to] As String, subject As String, Optional body As String = "", Optional cc As String = "", Optional co As String = "", Optional body_url As String = "")
            Dim m As New tnvLegReturn
            m.metodo = tnvLegReturn.tnvLegReturnMethod.mail
            m.filename = filename
            m.mail_to = [to]
            m.mail_cc = cc
            m.mail_co = co
            m.mail_subject = subject
            m.mail_body = body
            m.mail_body_url = body
            returns.Add(m)
        End Sub

        Public Sub returnHTTPAdd(filename As String, url As String, paramname As String, Optional urlfailover As String = "")
            Dim m As New tnvLegReturn
            m.metodo = tnvLegReturn.tnvLegReturnMethod.http
            m.filename = filename
            m.http_url = url
            m.http_paramname = paramname
            m.http_urlfailover = urlfailover
            returns.Add(m)
        End Sub


        ''' <summary>
        ''' Exporta el legajo completo al formato propietario
        ''' </summary>
        ''' <param name="path">Path del archivo destino</param>
        ''' <remarks></remarks>
        Public Sub exportToFile(ByVal path As String)


            '*********************************
            'Armar la cabecera XML
            '*********************************
            Dim oXML As XmlDocument = _getXML()

            '*********************************
            'Copiar los datos al archivo
            '*********************************

            'Pasar la cabecera a bytes()
            Dim strXML As String
            strXML = oXML.OuterXml

            Dim XMLBytes() As Byte
            XMLBytes = System.Text.Encoding.Unicode.GetBytes(strXML)

            'Armar la cabecera del archivo
            Dim fcad As New nvLegContainerFileCab
            fcad.major_version = major_version
            fcad.minor_version = minor_version
            fcad.XMLCAB_length = XMLBytes.Length

            'Crear y abrir el archivo
            Dim fs As New FileStream(path, System.IO.FileMode.Create)

            'copiar la cabecera del archivo
            fs.WriteByte(fcad.major_version)
            fs.WriteByte(fcad.minor_version)


            Dim LongBArray() As Byte = BitConverter.GetBytes(fcad.XMLCAB_length)
            fs.Write(LongBArray, 0, LongBArray.Length)

            'Copiar la cabecera XML
            fs.Write(XMLBytes, 0, XMLBytes.Length)

            'copiar los archivos
            Dim FileBytes() As Byte
            For Each index In documents.Keys
                If Not (documents(index).getfile Is Nothing) Then
                    FileBytes = documents(index).bytes
                    fs.Write(FileBytes, 0, FileBytes.Length)
                End If
            Next

            fs.Close()

        End Sub

        ''' <summary>
        ''' Importa el legajo desde una archivo en formato propietario
        ''' </summary>
        ''' <param name="path">Path del archivo</param>
        ''' <remarks></remarks>
        ''' 
        Public Sub importFromFile(ByVal path As String)

            Dim fs As FileStream = New FileStream(path, System.IO.FileMode.Open)
            Dim bytes(fs.Length - 1) As Byte
            fs.Read(bytes, 0, fs.Length)
            fs.Close()

            importFromBytesArray(bytes)

        End Sub

        Public Sub importFromBytesArray(ByVal bytes() As Byte)
            'Dim fs As FileStream = New FileStream(path, System.IO.FileMode.Open)
            Dim fs As Stream = New MemoryStream(bytes)

            titulo = ""
            comentario = ""
            documents = New Dictionary(Of Integer, tnvLegDocument)
            metadata = New Dictionary(Of String, tnvMetadaData)
            returns = New List(Of tnvLegReturn)

            Dim fcab As New nvLegContainerFileCab

            fcab.major_version = fs.ReadByte()
            fcab.minor_version = fs.ReadByte()

            If fcab.major_version <> major_version Or fcab.minor_version <> minor_version Then
                fs.Close()
                Throw New Exception("El archivo no se corresponde con la version esperada")
                Exit Sub
            End If
            Dim LongBArray(7) As Byte
            fs.Read(LongBArray, 0, LongBArray.Length)

            fcab.XMLCAB_length = BitConverter.ToInt64(LongBArray, 0)


            Dim XMLBytes(fcab.XMLCAB_length - 1) As Byte
            fs.Read(XMLBytes, 0, XMLBytes.Length)


            Dim strXML As String
            strXML = System.Text.Encoding.Unicode.GetString(XMLBytes)

            Dim oXML As New XmlDocument
            oXML.LoadXml(strXML)

            Dim oNodes As XmlNodeList
            Dim oNode As XmlNode

            titulo = oXML.SelectSingleNode("nvLegContainer/metadatas/@titulo").Value
            comentario = oXML.SelectSingleNode("nvLegContainer/metadatas/@comentario").Value

            'Dim oXML1 As New XmlDocument
            ' oXML1.LoadXml("<nvLegContainer><locations><location value='' key='' selected='true'></location><location value='Entre Rios' key='entre rios' selected='false'></location><location value='Santa Fe' key='santa fe' selected='false'></location></locations><reasons><reason value='Aceptación' key='aceptacion' selected='true'></reason><reason value='Rechazo' key='rechazo' selected='false'></reason></reasons></nvLegContainer>")
            'oXML1.LoadXml("<nvLegContainer><locations><location value='Santa Fe' key='santa fe' selected='true'></location></locations><reasons><reason value='Aceptación' key='aceptacion' selected='true'></reason><reason value='Rechazo' key='rechazo' selected='false'></reason></reasons></nvLegContainer>")

            reason_editable = oXML.SelectSingleNode("nvLegContainer/reasons/@editable").Value
            oNodes = oXML.SelectNodes("nvLegContainer/reasons/reason")
            For i = 0 To oNodes.Count - 1
                oNode = oNodes(i)
                reasonAdd(oNode.Attributes("label").Value, Convert.ToBoolean(oNode.Attributes("selected").Value))
            Next

            location_editable = oXML.SelectSingleNode("nvLegContainer/locations/@editable").Value
            oNodes = oXML.SelectNodes("nvLegContainer/locations/location")
            For i = 0 To oNodes.Count - 1
                oNode = oNodes(i)
                locationAdd(oNode.Attributes("label").Value, Convert.ToBoolean(oNode.Attributes("selected").Value))
            Next

            oNodes = oXML.SelectNodes("nvLegContainer/params/param")
            For i = 0 To oNodes.Count - 1
                oNode = oNodes(i)
                paramAdd(oNode.Attributes("param").Value, oNode.Attributes("value").Value)
            Next

            oNodes = oXML.SelectNodes("nvLegContainer/metadatas/metadata")
            For i = 0 To oNodes.Count - 1
                oNode = oNodes(i)
                metadataAdd(oNode.Attributes("key").Value, oNode.Attributes("label").Value, oNode.Attributes("value").Value)
            Next

            oNodes = oXML.SelectNodes("nvLegContainer/returns/return")
            For i = 0 To oNodes.Count - 1
                If oNodes(i).Attributes("metodo").Value = "mail" Then
                    returnMailAdd(oNodes(i).Attributes("filename").Value, oNodes(i).Attributes("mail_to").Value, oNodes(i).Attributes("mail_subject").Value, oNodes(i).Attributes("mail_body").Value, oNodes(i).Attributes("mail_cc").Value, oNodes(i).Attributes("mail_co").Value, oNodes(i).Attributes("mail_body_url").Value)
                Else
                    returnHTTPAdd(oNodes(i).Attributes("filename").Value, oNodes(i).Attributes("http_url").Value, oNodes(i).Attributes("http_paramname").Value, oNodes(i).Attributes("http_urlfailover").Value)
                End If
            Next


            oNodes = oXML.SelectNodes("nvLegContainer/documents/document")

            Dim oDocument As tnvLegDocument
            Dim DocBytes() As Byte
            Dim oSignNodes As XmlNodeList
            Dim oSignNode As XmlNode
            Dim oSignature As tnvSignature
            Dim oReqNode As XmlNode
            Dim oPDFSignParam As tnvPDFSignParam = New tnvPDFSignParam
            Dim ms As MemoryStream
            Dim x As System.Xml.Serialization.XmlSerializer = New System.Xml.Serialization.XmlSerializer(oPDFSignParam.GetType)
            Dim signCert As X509Certificate2
            Dim sign() As Byte
            For i = 0 To oNodes.Count - 1
                oNode = oNodes(i)
                oDocument = New tnvLegDocument(oNode.Attributes("name").Value, oNode.Attributes("filename").Value, oNode.Attributes("content_type").Value)

                'Cargo los datos de metadatarequest si es que los hay
                Dim dicAtr As Dictionary(Of String, String) = New Dictionary(Of String, String)
                oReqNode = oNode.SelectSingleNode("request")
                If Not (oReqNode Is Nothing) Then
                    Dim atributos = oReqNode.Attributes
                    Dim cant As Integer = oReqNode.Attributes.Count

                    For index As Integer = 0 To cant - 1
                        Dim name = atributos.Item(index).Name
                        Dim value = atributos.Item(index).Value
                        dicAtr(name) = value
                    Next

                    oDocument.metadataRequest = dicAtr

                End If

                oSignNodes = oNode.SelectNodes("signatures/signature")
                For j = 0 To oSignNodes.Count - 1
                    oSignNode = oSignNodes(j)
                    'Desserializar el nvPDFSignParam
                    ms = New MemoryStream(Encoding.Unicode.GetBytes(oSignNode.SelectSingleNode("tnvPDFSignParam").OuterXml))
                    oPDFSignParam = x.Deserialize(ms)
                    oSignature = New tnvSignature(oDocument, oSignNode.Attributes("name").Value, oSignNode.Attributes("use").Value, oSignNode.Attributes("signatoryID").Value, oPDFSignParam)
                    If oSignNode.Attributes("certificate").Value <> "" Then
                        signCert = New X509Certificate2(Convert.FromBase64String(oSignNode.Attributes("certificate").Value))
                    Else
                        signCert = Nothing
                    End If
                    If oSignNode.Attributes("sign").Value <> "" Then
                        sign = Convert.FromBase64String(oSignNode.Attributes("certificate").Value)
                    Else
                        sign = Nothing
                    End If
                    oSignature.setSignProperties(signCert, oSignNode.Attributes("signatoryID").Value, sign)

                    oDocument.Signatures.Add(oSignature)
                Next


                Dim nodelength As System.Xml.XmlNode = oXML.SelectSingleNode("nvLegContainer/documents_len/document_len[@index=" + oNode.Attributes("index").Value + "]")
                If Not nodelength Is Nothing Then
                    ReDim DocBytes(nodelength.Attributes("length").Value - 1)
                    fs.Read(DocBytes, 0, DocBytes.Length)
                    oDocument.load(DocBytes)
                End If


                documents.Add(oNode.Attributes("index").Value, oDocument)
            Next

            fs.Close()

        End Sub



        ''' <summary>
        ''' Guarda todos los archivo contenido en la estructura a una carpeta del file system
        ''' </summary>
        ''' <param name="path_dir">Carpeta de destino</param>
        ''' <remarks></remarks>
        Public Sub saveFilesToDir(ByVal path_dir As String, Optional ByVal saveLegInfo As Boolean = False)
            Dim fs As FileStream
            If saveLegInfo Then
                fs = New FileStream(path_dir & "\legInfo.xml", System.IO.FileMode.Create)
                Dim oXMl As System.Xml.XmlDocument = _getXML()
                Dim XMLBytes() As Byte
                XMLBytes = System.Text.Encoding.Unicode.GetBytes(oXMl.OuterXml)
                fs.Write(XMLBytes, 0, XMLBytes.Length)
                fs.Close()
            End If
            Dim Buffer() As Byte
            Dim index As Integer
            For Each index In documents.Keys
                If documents(index).length > 0 Then
                    fs = New FileStream(path_dir & "\" & documents(index).filename, System.IO.FileMode.Create)
                    Buffer = documents(index).bytes
                    fs.Write(Buffer, 0, Buffer.Length)
                    fs.Close()
                End If
            Next

        End Sub

        Public Sub close()
            metadata.Clear()
            Dim index As Integer
            For Each index In documents.Keys
                documents(index).close()
            Next
            documents.Clear()
        End Sub


        Private Function _getXML() As System.Xml.XmlDocument

            Dim oXML As New System.Xml.XmlDocument
            Dim oAtt As System.Xml.XmlAttribute
            'Agregar la raiz
            Dim oNode As System.Xml.XmlNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "nvLegContainer", "")
            oXML.AppendChild(oNode)

            'Agregar Reason
            oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "reasons", "")

            oAtt = oXML.CreateAttribute("editable")
            oAtt.Value = reason_editable
            oNode.Attributes.Append(oAtt)

            oXML.SelectSingleNode("nvLegContainer").AppendChild(oNode)

            'Agregar location
            oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "locations", "")

            oAtt = oXML.CreateAttribute("editable")
            oAtt.Value = location_editable
            oNode.Attributes.Append(oAtt)
            oXML.SelectSingleNode("nvLegContainer").AppendChild(oNode)

            'Agregar Params
            oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "params", "")
            oXML.SelectSingleNode("nvLegContainer").AppendChild(oNode)

            'Agregar metadatas
            oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "metadatas", "")

            oAtt = oXML.CreateAttribute("titulo")
            oAtt.Value = titulo
            oNode.Attributes.Append(oAtt)
            oAtt = oXML.CreateAttribute("comentario")
            oAtt.Value = comentario
            oNode.Attributes.Append(oAtt)

            oXML.SelectSingleNode("nvLegContainer").AppendChild(oNode)

            'Agregar documents
            oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "documents", "")
            oXML.SelectSingleNode("nvLegContainer").AppendChild(oNode)

            'Agregar documents len
            oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "documents_len", "")
            oXML.SelectSingleNode("nvLegContainer").AppendChild(oNode)

            'Agregar retornos
            oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "returns", "")
            oXML.SelectSingleNode("nvLegContainer").AppendChild(oNode)

            Dim reasonKey As String
            For Each reasonKey In reason.Keys
                'Agregar reason
                oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "reason", "")
                oAtt = oXML.CreateAttribute("label")
                oAtt.Value = reason(reasonKey).label
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("selected")
                oAtt.Value = reason(reasonKey).selected.ToString
                oNode.Attributes.Append(oAtt)

                oXML.SelectSingleNode("nvLegContainer/reasons").AppendChild(oNode)
            Next

            Dim locationKey As String
            For Each locationKey In location.Keys
                'Agregar location
                oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "location", "")
                oAtt = oXML.CreateAttribute("label")
                oAtt.Value = location(locationKey).label
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("selected")
                oAtt.Value = location(locationKey).selected.ToString
                oNode.Attributes.Append(oAtt)

                oXML.SelectSingleNode("nvLegContainer/locations").AppendChild(oNode)
            Next

            Dim paramKey As String
            For Each paramKey In params.Keys
                'Agregar location
                oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "param", "")
                oAtt = oXML.CreateAttribute("param")
                oAtt.Value = params(paramKey).param
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("value")
                oAtt.Value = params(paramKey).value
                oNode.Attributes.Append(oAtt)

                oXML.SelectSingleNode("nvLegContainer/params").AppendChild(oNode)
            Next

            Dim key As String
            For Each key In metadata.Keys
                'Agregar metadata
                oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "metadata", "")
                oAtt = oXML.CreateAttribute("key")
                oAtt.Value = key
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("label")
                oAtt.Value = metadata(key).label
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("value")
                oAtt.Value = metadata(key).value
                oNode.Attributes.Append(oAtt)

                oXML.SelectSingleNode("nvLegContainer/metadatas").AppendChild(oNode)
            Next

            Dim retorno As tnvLegReturn
            For Each retorno In returns
                'Agregar return
                oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "return", "")

                oAtt = oXML.CreateAttribute("metodo")
                oAtt.Value = retorno.metodo.ToString
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("filename")
                oAtt.Value = retorno.filename
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("http_paramname")
                oAtt.Value = retorno.http_paramname
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("http_url")
                oAtt.Value = retorno.http_url
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("http_urlfailover")
                oAtt.Value = retorno.http_urlfailover
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("mail_to")
                oAtt.Value = retorno.mail_to
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("mail_subject")
                oAtt.Value = retorno.mail_subject
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("mail_body")
                oAtt.Value = retorno.mail_body
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("mail_body_url")
                oAtt.Value = retorno.mail_body_url
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("mail_cc")
                oAtt.Value = retorno.mail_cc
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("mail_co")
                oAtt.Value = retorno.mail_co
                oNode.Attributes.Append(oAtt)

                oXML.SelectSingleNode("nvLegContainer/returns").AppendChild(oNode)
            Next

            Dim index As Integer
            Dim oSignaturesNode As XmlNode
            Dim oSignNode As XmlNode
            Dim oRequestNode As XmlNode
            Dim oRequest As Dictionary(Of String, String) = New Dictionary(Of String, String)
            For Each index In documents.Keys

                'Agregar documento
                oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "document", "")
                oAtt = oXML.CreateAttribute("index")
                oAtt.Value = index
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("name")
                oAtt.Value = documents(index).name
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("filename")
                oAtt.Value = documents(index).filename
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("content_type")
                oAtt.Value = documents(index).content_type
                oNode.Attributes.Append(oAtt)

                'oAtt = oXML.CreateAttribute("length")
                'oAtt.Value = documents(index).length
                'oNode.Attributes.Append(oAtt)


                Dim oAttreq As XmlAttribute
                oRequestNode = oXML.CreateNode(XmlNodeType.Element, "request", "")

                ''si el archivo es vacio , se cargan los metadatas request
                'If (documents(index).length = 0) Then
                oRequest = documents(index).metadataRequest()
                If Not (oRequest Is Nothing) Then

                    For Each clave As String In oRequest.Keys
                        Dim valor As String = oRequest(clave)
                        oAttreq = oXML.CreateAttribute(clave)
                        oAttreq.Value = oRequest(clave)
                        oRequestNode.Attributes.Append(oAttreq)
                    Next
                End If
                oNode.AppendChild(oRequestNode)
                'End If


                'Agregar firmas
                oSignaturesNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "signatures", "")
                oNode.AppendChild(oSignaturesNode)
                Dim signature As tnvSignature

                Dim msXML As MemoryStream
                'Dim oXMLReader As Xml.XmlReader
                Dim strXMLFragment As String
                Dim StreamReader As StreamReader
                For Each signature In documents(index).Signatures
                    oSignNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "signature", "")
                    oAtt = oXML.CreateAttribute("name")
                    oAtt.Value = signature.name
                    oSignNode.Attributes.Append(oAtt)

                    oAtt = oXML.CreateAttribute("signatoryID")
                    oAtt.Value = signature.signatoryID
                    oSignNode.Attributes.Append(oAtt)

                    oAtt = oXML.CreateAttribute("use")
                    oAtt.Value = signature.use
                    oSignNode.Attributes.Append(oAtt)

                    oAtt = oXML.CreateAttribute("certificate")
                    If Not signature.certificate Is Nothing Then
                        oAtt.Value = Convert.ToBase64String(signature.certificate.GetRawCertData)
                    End If
                    oSignNode.Attributes.Append(oAtt)


                    oAtt = oXML.CreateAttribute("sign")
                    If Not signature.sign_bytes Is Nothing Then
                        oAtt.Value = Convert.ToBase64String(signature.sign_bytes)
                    End If
                    oSignNode.Attributes.Append(oAtt)

                    oAtt = oXML.CreateAttribute("hashAlgorithm")
                    If Not signature.sign_bytes Is Nothing Then
                        oAtt.Value = signature.hashAlgorithm
                    End If
                    oSignNode.Attributes.Append(oAtt)

                    oAtt = oXML.CreateAttribute("asymmetricAlgorithm")
                    If Not signature.sign_bytes Is Nothing Then
                        oAtt.Value = signature.asymmetricAlgorithm
                    End If
                    oSignNode.Attributes.Append(oAtt)

                    '*********************************************
                    'Serializar el PDFSignParam y agregar al nodo
                    '*********************************************
                    If Not signature.PDFSignParams Is Nothing Then
                        Dim x As System.Xml.Serialization.XmlSerializer = New System.Xml.Serialization.XmlSerializer(signature.PDFSignParams.GetType)
                        msXML = New MemoryStream
                        x.Serialize(msXML, signature.PDFSignParams)
                        msXML.Position = 0
                        StreamReader = New StreamReader(msXML)

                        strXMLFragment = StreamReader.ReadToEnd
                        msXML.Close()
                        StreamReader.Close()
                        Dim fragment As System.Xml.XmlDocumentFragment = oXML.CreateDocumentFragment()

                        fragment.InnerXml = strXMLFragment '.Replace("<?xml version=""1.0""?>", "").Replace(vbCrLf, "")
                        fragment.RemoveChild(fragment.FirstChild)
                        oSignNode.AppendChild(fragment)
                    End If


                    oSignaturesNode.AppendChild(oSignNode)

                Next
                oXML.SelectSingleNode("nvLegContainer/documents").AppendChild(oNode)
            Next

            For Each index In documents.Keys
                'Agregar largo de documento 
                oNode = oXML.CreateNode(System.Xml.XmlNodeType.Element, "document_len", "")
                oAtt = oXML.CreateAttribute("index")
                oAtt.Value = index
                oNode.Attributes.Append(oAtt)

                oAtt = oXML.CreateAttribute("length")
                If (documents(index).getfile() Is Nothing) Then
                    oAtt.Value = 0
                Else
                    oAtt.Value = documents(index).bytes.Length
                End If
                oNode.Attributes.Append(oAtt)

                oXML.SelectSingleNode("nvLegContainer/documents_len").AppendChild(oNode)
            Next


            Return oXML
        End Function

        Public Class tnvReason

            Public label As String
            Public selected As Boolean

            Public Sub New(Optional ByVal value As String = "", Optional ByVal selected As Boolean = False)
                Me.label = value
                Me.selected = selected
            End Sub

        End Class

        Public Class tnvLocation

            Public label As String
            Public selected As Boolean

            Public Sub New(Optional ByVal label As String = "", Optional ByVal selected As Boolean = False)
                Me.label = label
                Me.selected = selected
            End Sub

        End Class

        Public Class tnvMetadaData
            Public key As String
            Public label As String
            Public value As String

            Public Sub New(Optional key As String = "", Optional label As String = "", Optional value As String = "")
                Me.key = key
                Me.label = label
                Me.value = value
            End Sub

        End Class

        Public Class tnvParam
            Public param As String
            Public value As String

            Public Sub New(Optional param As String = "", Optional value As String = "")
                Me.param = param
                Me.value = value
            End Sub

        End Class

        Public Class tnvLegReturn
            Public filename As String
            Public metodo As tnvLegReturnMethod = tnvLegReturnMethod.http
            Public mail_body_url As String
            Public mail_body As String
            Public mail_to As String
            Public mail_cc As String
            Public mail_co As String
            Public mail_subject As String
            Public http_paramname As String
            Public http_url As String
            Public http_urlfailover As String

            Public Enum tnvLegReturnMethod
                mail = 0
                http = 1
            End Enum

        End Class

        'Public Function ObjectToByteArray(ByVal _Object As Object) As Byte()

        '    Try
        '        ' create new memory stream
        '        Dim _MemoryStream As New System.IO.MemoryStream()

        '        ' create new BinaryFormatter
        '        Dim _BinaryFormatter As New System.Runtime.Serialization.Formatters.Binary.BinaryFormatter()

        '        ' Serializes an object, or graph of connected objects, to the given stream.
        '        _BinaryFormatter.Serialize(_MemoryStream, _Object)


        '        ' convert stream to byte array and return
        '        Return _MemoryStream.ToArray()
        '    Catch _Exception As Exception
        '        ' Error
        '        Console.WriteLine("Exception caught in process: {0}", _Exception.ToString())
        '    End Try
        '    ' Error occured, return null
        '    Return Nothing
        'End Function

        <Serializable()>
        Private Structure nvLegContainerFileCab
            Public major_version As Byte
            Public minor_version As Byte
            Public XMLCAB_length As Long
        End Structure
    End Class



End Namespace

