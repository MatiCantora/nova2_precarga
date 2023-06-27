<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
   
    Dim accion = nvUtiles.obtenerValor("accion", "")
    Me.contents("accion") = accion
    
   
   
    If accion = "" Then
        
        Dim id_circuito_firma = nvUtiles.obtenerValor("id_circuito_firma", "")
        Me.contents("id_circuito_firma") = id_circuito_firma
    
        Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")
        Me.contents("nro_entidad") = nro_entidad
        
        Dim titulo As String = ""
        Dim comentario As String = ""
        'Dim docs_str As String = ""
        
        Dim documentsData As New trsParam
        Dim firmantesData As New trsParam
        firmantesData("entidades_firmantes") = New trsParam
       
        If id_circuito_firma <> "" Then
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuitos_firma WHERE id_circuito_firma=" & id_circuito_firma)
            titulo = rs.Fields("titulo").Value
            comentario = rs.Fields("comentario").Value
            nvDBUtiles.DBCloseRecordset(rs)
            
            

            rs = nvDBUtiles.DBOpenRecordset("SELECT * FROM ver_documentos_firma WHERE id_circuito_firma=" & id_circuito_firma & " order by id_documento_firma ")
            Dim i As Integer = 0
            While Not rs.EOF
                'docs.Add(rs.Fields("nombre_doc").Value)
                Dim documentData As New trsParam
                documentData.Add("nombre_doc", rs.Fields("nombre_doc").Value)
                documentData.Add("id_documento_firma", rs.Fields("id_documento_firma").Value)
                documentData.Add("extension", rs.Fields("extension").Value)
                documentData.Add("adjuntable", rs.Fields("adjuntable").Value)
                documentData.Add("nro_entidad_adjuntante", rs.Fields("nro_entidad_adjuntante").Value)
                documentData.Add("nro_entidad_adjuntante_delegado", rs.Fields("nro_entidad_adjuntante_delegado").Value)
                documentData.Add("adjuntable_obligatorio", rs.Fields("adjuntable_obligatorio").Value)
                documentData.Add("depthcolor", rs.Fields("depthcolor").Value)
                documentData.Add("ppi", rs.Fields("ppi").Value)
                documentsData.Add(i, documentData)
                rs.MoveNext()
                i = i + 1
            End While
            nvDBUtiles.DBCloseRecordset(rs)
            
            
            
            rs = nvDBUtiles.DBOpenRecordset("SELECT * FROM ver_circuito_firmantes WHERE id_circuito_firma=" & id_circuito_firma & " ORDER BY orden")
         
            
            i = 0
            While Not rs.EOF
                
                If IsDBNull(rs.Fields("id_esquema").Value) Then 'Entidad física
                    
                    Dim firmanteData As New trsParam
                    firmanteData.Add("nro_entidad", rs.Fields("nro_entidad").Value)
                    firmanteData.Add("razon_social", rs.Fields("razon_social").Value)
                    firmantesData("entidades_firmantes").add(i, firmanteData)
                    rs.MoveNext()
                    
                Else ' Entidad jurídica
                    
                    
                    Dim firmanteData As New trsParam
                    firmanteData.Add("nro_entidad", rs.Fields("nro_entidad_juridica").Value)
                    firmanteData.Add("razon_social", rs.Fields("razon_social_juridica").Value)
                    firmanteData.Add("id_esquema", rs.Fields("id_esquema").Value)
                    firmanteData.Add("firmantes", New trsParam)
                    firmantesData("entidades_firmantes").add(i, firmanteData)
                    
                    
                    Dim orden As Integer = rs.Fields("orden").Value
                    Dim orden2 As Integer
                    

                    Do
                        Dim entidadParam As New trsParam
                        entidadParam.Add("nro_entidad", rs.Fields("nro_entidad").Value)
                        entidadParam.Add("razon_social", rs.Fields("razon_social").Value)
                        firmanteData("firmantes").Add(rs.Fields("nro_entidad").Value, entidadParam)
                        rs.MoveNext()

                        If Not rs.EOF Then
                            orden2 = rs.Fields("orden").Value
                        End If
                        
                    Loop While Not rs.EOF And orden = orden2
                    
                End If
                
                i = i + 1
               
            End While
            
            nvDBUtiles.DBCloseRecordset(rs)
            
            
            
            
            
            
            
             
            Dim fisicasSignConfigs As New trsParam
            Dim juridicasSignConfigs As New trsParam
            
            
            Dim strSQL As String = ""
            strSQL &= "SELECT * FROM ver_entidad_firma_config WHERE id_circuito_firma=" + id_circuito_firma
            rs = nvDBUtiles.DBOpenRecordset(strSQL)
            
            While Not rs.EOF
                
                
                ' configuracion de firma personas fisicas
                If isNUll(rs.Fields("id_esquema").Value, Nothing) Is Nothing Then
                    
                    Dim nombre_doc As String = rs.Fields("nombre_doc").Value
                    Dim id_documento_firma As String = rs.Fields("id_documento_firma").Value
                    Dim nroentidad As String = rs.Fields("nro_entidad").Value
                    
                    If Not fisicasSignConfigs.ContainsKey(nombre_doc) Then
                        fisicasSignConfigs.Add(nombre_doc, New trsParam)
                    End If
                    
     
                    fisicasSignConfigs(nombre_doc).Add(nroentidad, New trsParam)
                    
                    
                    fisicasSignConfigs(nombre_doc)(nroentidad).Add("requerido", rs.Fields("requerido").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad).Add("hashAlgorithm", rs.Fields("hashAlgorithm").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad).Add("setLTV", rs.Fields("setLTV").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad).Add("orden", rs.Fields("orden").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad).Add("fieldname", rs.Fields("fieldname").Value)
                    
                    fisicasSignConfigs(nombre_doc)(nroentidad).Add("PDF_params", New trsParam)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params").Add("appendToExistingOnes", rs.Fields("appendToExistingOnes").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params").Add("certificationLevel", rs.Fields("certificationLevel").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params").Add("cryptoStandard", rs.Fields("cryptoStandard").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params").Add("visible", rs.Fields("visible").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params").Add("signatureEstimatedSize", rs.Fields("signatureEstimatedSize").Value)
                    
                    
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params").Add("PDF_appereance", New trsParam)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("x1", rs.Fields("x1").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("x2", rs.Fields("x2").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("y1", rs.Fields("y1").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("y2", rs.Fields("y2").Value)
                    
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("page", rs.Fields("page").Value)
                    'fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("fieldname", rs.Fields("fieldname").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("fontFamily", rs.Fields("fontFamily").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("fontColor", rs.Fields("fontColor").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("fontSize", rs.Fields("fontSize").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("fontStyle", rs.Fields("fontStyle").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("display", rs.Fields("display").Value)
                    fisicasSignConfigs(nombre_doc)(nroentidad)("PDF_params")("PDF_appereance").add("signatureText", rs.Fields("signatureText").Value)
                Else
                    
                    Dim nombre_doc As String = rs.Fields("nombre_doc").Value
                    Dim id_documento_firma As String = rs.Fields("id_documento_firma").Value
                    Dim nroentidad As String = rs.Fields("nro_entidad").Value
                    Dim id_esquema As String = rs.Fields("id_esquema").Value
                    
                    
                    If Not juridicasSignConfigs.ContainsKey(nombre_doc) Then
                        juridicasSignConfigs.Add(nombre_doc, New trsParam)
                    End If
                    
                    If Not juridicasSignConfigs(nombre_doc).ContainsKey(id_esquema) Then
                        juridicasSignConfigs(nombre_doc).Add(id_esquema, New trsParam)
                    End If
                    

                    juridicasSignConfigs(nombre_doc)(id_esquema).Add(nroentidad, New trsParam)
                    
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad).Add("requerido", rs.Fields("requerido").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad).Add("hashAlgorithm", rs.Fields("hashAlgorithm").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad).Add("setLTV", rs.Fields("setLTV").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad).Add("orden", rs.Fields("orden").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad).Add("fieldname", rs.Fields("fieldname").Value)
                    
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad).Add("PDF_params", New trsParam)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params").Add("appendToExistingOnes", rs.Fields("appendToExistingOnes").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params").Add("certificationLevel", rs.Fields("certificationLevel").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params").Add("cryptoStandard", rs.Fields("cryptoStandard").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params").Add("visible", rs.Fields("visible").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params").Add("signatureEstimatedSize", rs.Fields("signatureEstimatedSize").Value)
                    
                    
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params").Add("PDF_appereance", New trsParam)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("x1", rs.Fields("x1").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("x2", rs.Fields("x2").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("y1", rs.Fields("y1").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("y2", rs.Fields("y2").Value)
                    
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("page", rs.Fields("page").Value)
                    'juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("fieldname", rs.Fields("fieldname").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("fontFamily", rs.Fields("fontFamily").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("fontColor", rs.Fields("fontColor").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("fontSize", rs.Fields("fontSize").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("fontStyle", rs.Fields("fontStyle").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("display", rs.Fields("display").Value)
                    juridicasSignConfigs(nombre_doc)(id_esquema)(nroentidad)("PDF_params")("PDF_appereance").add("signatureText", rs.Fields("signatureText").Value)
                    
                    
                End If
                
                
                rs.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rs)
            
            
            
            'If docs.Count > 0 Then
            '    docs_str = String.Join(",", docs.ToArray)
            'End If
            
      
        
            Me.contents("titulo") = titulo
            Me.contents("comentario") = comentario
            'Me.contents("docs_str") = docs_str
            Me.contents("documentsData") = documentsData
            Me.contents("firmantesData") = firmantesData
            Me.contents("juridicasSignConfigs") = juridicasSignConfigs
            Me.contents("fisicasSignConfigs") = fisicasSignConfigs
        
        End If
    End If
    
    
    
    
    
    If accion = "alta_circuito" Then
        Dim err As New tError
        
        Dim nro_entidad As String = nvUtiles.obtenerValor("nro_entidad", "")
        Dim titulo As String = nvUtiles.obtenerValor("titulo", "")
        Dim comentario As String = nvUtiles.obtenerValor("comentario", "")
        
        '<![CDATA[some stuff]]>
            
        Dim strXML As String = "<?xml version='1.0' encoding='iso-8859-1'?>"
        strXML &= "<circuitos_firma_abm><circuito_firma_alta><nro_entidad>" & nro_entidad & "</nro_entidad>" &
            "<titulo><![CDATA[" & titulo & "]]></titulo><comentario><![CDATA[" & comentario & "]]></comentario></circuito_firma_alta></circuitos_firma_abm>"
        
        
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("circuitos_firma_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        Dim pStrXML As ADODB.Parameter
        pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
        cmd.Parameters.Append(pStrXML)
        Dim rs As ADODB.Recordset
        rs = cmd.Execute()
        err.numError = rs.Fields("numError").Value
        err.mensaje = rs.Fields("mensaje").Value
        err.titulo = rs.Fields("titulo").Value
        err.debug_desc = rs.Fields("debug_desc").Value
        err.debug_src = rs.Fields("debug_src").Value
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
        
        If err.numError = 0 Then
            Dim rst As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT id_circuito_firma FROM circuitos_firma WHERE titulo='" & titulo & "' AND nro_entidad=" + nro_entidad)
            err.params("id_circuito_firma") = rst.Fields("id_circuito_firma").Value
            nvDBUtiles.DBCloseRecordset(rst)
        End If
       
        err.response()
    End If
    
    
    
    If accion = "modificacion_circuito" Then
        
        Dim err As New tError
        
        Dim titulo As String = nvUtiles.obtenerValor("titulo", "")
        Dim comentario As String = nvUtiles.obtenerValor("comentario", "")
        
            
        Dim strXML As String = "<?xml version='1.0' encoding='iso-8859-1'?>"
        strXML &= "<circuitos_firma_abm><circuito_firma_modificacion>" &
            "<titulo><![CDATA[" & titulo & "]]></titulo><comentario><![CDATA[" & comentario & "]]></comentario></circuito_firma_modificacion></circuitos_firma_abm>"
        
       
       
        err.response()
        
    End If
    
    
    
    If accion = "alta_documento" Then
        
     
        Dim id_circuito_firma As String = nvUtiles.obtenerValor("id_circuito_firma", "")
        
        Dim Files As HttpFileCollection = Request.Files

        Dim err = New tError()

        'capturamos el archivo para guardarlo
        For Each key_archivo In Request.Files.AllKeys

            Dim archivo As Web.HttpPostedFile = Request.Files(key_archivo)
            If archivo.FileName <> "" Then
               
                
                    
                Dim doc_binary As Byte()
                
                Dim aux As String() = archivo.FileName.Split(".")
                Dim extension As String = aux(aux.Length - 1)
                Array.Resize(aux, aux.Length - 1)
                Dim nombre_doc As String = String.Join("", aux)
                    
                Using memoryStream As New IO.MemoryStream()
                    archivo.InputStream.CopyTo(memoryStream)
                    doc_binary = memoryStream.ToArray()
                End Using
                    

                Dim tmpFilePath = System.IO.Path.GetTempPath() & Guid.NewGuid().ToString() + ".tmp"
                
                Try
                    System.IO.File.WriteAllBytes(tmpFilePath, doc_binary)
                    err.params("tmp_file_path") = tmpFilePath
                    err.params("nombre_doc") = nombre_doc
                    err.params("extension") = extension
                    err.salida_tipo = "adjunto"
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
                
            End If
        Next
        err.mostrar_error()
       
    End If
    
    
    
    'If accion = "alta_documento" Then
        
     
    '    Dim id_circuito_firma As String = nvUtiles.obtenerValor("id_circuito_firma", "")
        
    '    Dim Files As HttpFileCollection = Request.Files

    '    Dim err = New tError()

    '    'capturamos el archivo para guardarlo
    '    For Each key_archivo In Request.Files.AllKeys

    '        Dim archivo As Web.HttpPostedFile = Request.Files(key_archivo)
    '        If archivo.FileName <> "" Then
               
                
                    
    '            Dim doc_binary As Byte()
                
    '            Dim aux As String() = archivo.FileName.Split(".")
    '            Dim extension As String = aux(aux.Length - 1)
    '            Array.Resize(aux, aux.Length - 1)
    '            Dim nombre_doc As String = String.Join("", aux)
                    
    '            Using memoryStream As New IO.MemoryStream()
    '                archivo.InputStream.CopyTo(memoryStream)
    '                doc_binary = memoryStream.ToArray()
    '            End Using
                    
                    
    '            Dim ms As New System.IO.MemoryStream
    '            Dim settings As New System.Xml.XmlWriterSettings()
    '            settings.Indent = False
    '            settings.NewLineOnAttributes = True
    '            settings.OmitXmlDeclaration = True
    '            settings.Encoding = nvConvertUtiles.currentEncoding
    '            Dim writer As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(ms, settings)
    '            writer.WriteStartDocument()
    '            writer.WriteStartElement("circuitos_firma_documentos_abm")
    '            writer.WriteStartElement("circuitos_firma_documento_alta")

                
    '            writer.WriteStartElement("id_circuito_firma")
    '            writer.WriteValue(id_circuito_firma)
    '            writer.WriteEndElement()
                
    '            writer.WriteStartElement("nombre_doc")
    '            writer.WriteValue(nombre_doc)
    '            writer.WriteEndElement()
                
    '            writer.WriteStartElement("extension")
    '            writer.WriteValue(extension)
    '            writer.WriteEndElement()
                
    '            writer.WriteStartElement("doc_binary")
    '            writer.WriteBase64(doc_binary, 0, doc_binary.Count)
    '            writer.WriteEndElement()
                
    '            writer.WriteEndElement()
    '            writer.WriteEndElement()
                    
    '            writer.WriteEndDocument()
    '            writer.Close()
    '            ms.Position = 0
    '            Dim bytes(ms.Length - 1) As Byte
    '            ms.Read(bytes, 0, ms.Length)
    '            ms.Close()

    '            Dim xmlOutput As String = System.Text.Encoding.GetEncoding("ISO-8859-1").GetString(bytes)
                    
    '            Dim strXML As String = "<?xml version='1.0'?>" & xmlOutput
                    

    '            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("circuitos_firma_documentos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
    '            Dim pStrXML As ADODB.Parameter
    '            pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
    '            cmd.Parameters.Append(pStrXML)
    '            Dim rs As ADODB.Recordset
    '            rs = cmd.Execute()
                
    '            'err.numError = rs.Fields("numError").Value
    '            'err.mensaje = rs.Fields("mensaje").Value
    '            'err.titulo = rs.Fields("titulo").Value
    '            'err.debug_desc = rs.Fields("debug_desc").Value
    '            'err.debug_src = rs.Fields("debug_src").Value
    '            'err.response()
                    
    '            err.numError = rs.Fields("numError").Value
    '            err.mensaje = rs.Fields("mensaje").Value
    '            err.titulo = rs.Fields("titulo").Value
    '            err.debug_desc = rs.Fields("debug_desc").Value
    '            err.debug_src = rs.Fields("debug_src").Value
    '            err.salida_tipo = "adjunto"
                
    '            If err.numError = 0 Then
    '                err.params("nombre_doc") = nombre_doc
    '                err.params("id_documento_firma") = rs.Fields("id_documento_firma").Value
    '            End If
                
    '            nvDBUtiles.DBCloseRecordset(rs)
                

                
    '        End If
    '    Next
    '    err.mostrar_error()
       
    'End If
    
    
    
    
    'If accion = "firmante_abm" Then
        
    '    Dim err As New tError
    '    Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
        
        
    '    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("circuitos_firmantes_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
    '    Dim pStrXML As ADODB.Parameter
    '    pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
    '    cmd.Parameters.Append(pStrXML)
    '    Dim rs As ADODB.Recordset
    '    rs = cmd.Execute()
                
    '    err.numError = rs.Fields("numError").Value
    '    err.mensaje = rs.Fields("mensaje").Value
    '    err.titulo = rs.Fields("titulo").Value
    '    err.debug_desc = rs.Fields("debug_desc").Value
    '    err.debug_src = rs.Fields("debug_src").Value
    '    err.response()
                    
        
    'End If
    
    
    
    
    If accion = "firmante_abm" Then
        
        
        
        Dim err As New tError
        Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
        
        
        Dim oXml As New System.Xml.XmlDocument
        oXml.LoadXml(strXML)
        
        Dim nodeList As System.Xml.XmlNodeList = oXml.SelectNodes("circuito_firma_config/documentos_abm/documento[@accion='A']")
        
        For Each node As System.Xml.xmlNode In nodeList
            
            If Not node.Attributes("tmp_file_path") Is Nothing Then
                Dim tmp_file_path As String = node.Attributes("tmp_file_path").Value
                Dim doc_binary As Byte() = System.IO.File.ReadAllBytes(tmp_file_path)
            
                Dim attr As System.Xml.XmlAttribute = oXml.CreateAttribute("doc_binary")
                attr.Value = Convert.ToBase64String(doc_binary)
                node.Attributes.Append(attr)
                node.Attributes.Remove(node.Attributes("tmp_file_path"))
            End If
            
            
        Next
        
        
        strXML = oXml.OuterXml
        
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("circuito_firma_config", ADODB.CommandTypeEnum.adCmdStoredProc)
        Dim pStrXML As ADODB.Parameter
        pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
        cmd.Parameters.Append(pStrXML)
        Dim rs As ADODB.Recordset
        rs = cmd.Execute()
                
        err.numError = rs.Fields("numError").Value
        err.mensaje = rs.Fields("mensaje").Value
        err.titulo = rs.Fields("titulo").Value
        err.debug_desc = rs.Fields("debug_desc").Value
        err.debug_src = rs.Fields("debug_src").Value
        err.response()
                    
        
    End If
    
    
    
    
    
    
    If accion = "GENERAR_RM0" Then
        stop
        
        Dim id_circuito_firma As String = nvUtiles.obtenerValor("id_circuito_firma", "")
        
        Dim rsCircuito As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from circuitos_firma where id_circuito_firma=" + id_circuito_firma)
        Dim titulo As String = ""
        Dim comentario As String = ""
        If Not rsCircuito.EOF Then
            titulo = rsCircuito.Fields("titulo").Value
            comentario = rsCircuito.Fields("comentario").Value
        End If
        nvDBUtiles.DBCloseRecordset(rsCircuito)
        
        
        Dim cod_rm0_seg As String = "nvMUTUAL" & Guid.NewGuid().ToString("N")
        Dim filename As String = ""


        Dim oLegajo As New tnvLegContainer
        Dim oDocumento As tnvLegDocument
        Dim oSign As tnvSignature


        '**********************************************************
        'Estructura params.
        'Permite agregar al legajo parámetros para uso interno
        '**********************************************************
        filename = "legajo_prueba.rm0"
        
        
        Dim rsParams As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_parametros WHERE id_circuito_firma=" & id_circuito_firma)
        While Not rsParams.EOF
            Dim param_id As String = rsParams.Fields("param_id").Value
            Dim value As String = rsParams.Fields("value").Value
            oLegajo.paramAdd(param_id, value)
            rsParams.MoveNext()
        End While
        nvDBUtiles.DBCloseRecordset(rsParams)
        


        '****************************************************************************
        'Estructura returns.
        'Permite agregar la definición de donde y como se enviará el legajo firmado
        'Hay dos métodos posible 
        '    1) por HTTPs a una URL donde se adjuntará el legajo firmado. 
        '    2) Por mail donde se adjuntará el legajo firmado
        '****************************************************************************
        Dim url As String = "https://www.improntasolutions.com.ar/services/legajo_recepcion.aspx"
        oLegajo.returnHTTPAdd(filename, url, "file01")
        oLegajo.returnMailAdd(filename, "recepcion@improntasolutions.com.ar", "Legajo nro 2134657")


        '**********************************************************
        'Agregar los documentos a firmar
        '**********************************************************

        
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from ver_documentos_firma where id_circuito_firma=" & id_circuito_firma & " order by id_documento_firma ")
        Dim docIndex As Integer = 0
        While Not rs.EOF
            Dim name As String = rs.Fields("nombre_doc").Value
            Dim nombreDoc As String = rs.Fields("nombre_doc").Value
            Dim buffer(-1) As Byte
            Dim fileBin As Byte() = isNUll(rs.Fields("doc_binary").Value, buffer)
            Dim id_documento_firma As String = rs.Fields("id_documento_firma").Value
            Dim adjuntable As Boolean = rs.Fields("adjuntable").Value
            
            oDocumento = New tnvLegDocument(name, nombreDoc)
            oDocumento.load(fileBin)
            
            oLegajo.documents.Add(docIndex, oDocumento)
            
            
            ' Si es un documento agregable
            If adjuntable Then
                'Archivo requerido
                Dim adjuntable_obligatorio As Boolean = rs.Fields("adjuntable_obligatorio").Value
                Dim nro_entidad_adjuntante As String = rs.Fields("nro_entidad_adjuntante").Value
                Dim nro_entidad_adjuntante_delegado As String = isNUll(rs.Fields("nro_entidad_adjuntante_delegado").Value, "")
                Dim depthcolor As String = rs.Fields("depthcolor").Value
                Dim ppi As String = rs.Fields("ppi").Value
                
                '"SERIALNUMBER=CUIT 20324792776"
                
                Dim requesterId As String = ""
                If nro_entidad_adjuntante_delegado = "" Then 'persona fisica
                    Dim nro_entidad_adjuntante_cuitcuil As String = rs.Fields("nro_entidad_adjuntante_cuitcuil").Value
                    Dim nro_entidad_adjuntante_cuit As String = rs.Fields("nro_entidad_adjuntante_cuit").Value
                    requesterId = "SERIALNUMBER=" & nro_entidad_adjuntante_cuitcuil & " " & nro_entidad_adjuntante_cuit & ""
                Else
                    Dim nro_entidad_adjuntante_delegado_cuitcuil As String = rs.Fields("nro_entidad_adjuntante_delegado_cuitcuil").Value
                    Dim nro_entidad_adjuntante_delegado_cuit As String = rs.Fields("nro_entidad_adjuntante_delegado_cuit").Value
                    requesterId = "SERIALNUMBER=" & nro_entidad_adjuntante_delegado_cuitcuil & " " & nro_entidad_adjuntante_delegado_cuit & ""
                End If
                
   
                oDocumento.metadataRequest = New Dictionary(Of String, String)
                oDocumento.metadataRequest.Add("ppi", ppi)
                oDocumento.metadataRequest.Add("depthcolor", "truecolor")
                oDocumento.metadataRequest.Add("requesterID", requesterId)
                oDocumento.metadataRequest.Add("requerido", adjuntable_obligatorio)
         
            End If
            
            
            
            
            
            
            ' Recorrer los firmantes
            Dim rsFirmantes As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM ver_circuito_firmantes WHERE id_circuito_firma=" & id_circuito_firma & " ORDER BY orden")
            
            While Not rsFirmantes.EOF
                
                Dim nro_entidad As String = rsFirmantes.Fields("nro_entidad").Value
                Dim id_esquema As String = isNUll(rsFirmantes.Fields("id_esquema").Value, "")
                
                
                Dim nro_entidad_juridica As String = isNUll(rsFirmantes.Fields("nro_entidad_juridica").Value, "")
                Dim cuitcuil As String = ""
                Dim cuit As String = ""
                If nro_entidad_juridica <> "" Then
                    cuitcuil = isNUll(rsFirmantes.Fields("cuitcuil_juridica").Value, "")
                    cuit = isNUll(rsFirmantes.Fields("cuit_juridica").Value, "")
                Else
                    cuitcuil = isNUll(rsFirmantes.Fields("cuitcuil").Value, "")
                    cuit = isNUll(rsFirmantes.Fields("cuit").Value, "")
                End If
                
                
                
                Dim strSQL As String = "SELECT * FROM ver_entidad_firma_config WHERE id_circuito_firma=" + id_circuito_firma & " AND id_documento_firma=" & id_documento_firma & " and nro_entidad=" & nro_entidad
                
                If id_esquema = "" Then
                    strSQL += " and (id_esquema is null or id_esquema=NULL)"
                Else
                    strSQL += " and id_esquema =" + id_esquema
                End If
                
                
                Dim rsSignatures = nvDBUtiles.DBOpenRecordset(strSQL)
                If Not rsSignatures.EOF Then
                    
                    Dim fieldname As String = rsSignatures.Fields("fieldname").Value
                    Dim visible As Boolean = rsSignatures.Fields("visible").Value
                    Dim appendToExistingOnes As Boolean = rsSignatures.Fields("appendToExistingOnes").Value
                    Dim certificationLevel As Integer = rsSignatures.Fields("certificationLevel").Value
                    Dim cryptoStandard As Integer = rsSignatures.Fields("cryptoStandard").Value
                    Dim hashAlgorithm As Integer = rsSignatures.Fields("hashAlgorithm").Value
                    Dim signatureEstimatedSize As Integer = rsSignatures.Fields("signatureEstimatedSize").Value
                    
                    Dim display As Integer = isNUll(rsSignatures.Fields("display").Value, 0)
                    Dim signatureText As String = isNUll(rsSignatures.Fields("signatureText").Value, "")
                    Dim x1 As Integer = isNUll(rsSignatures.Fields("x1").Value, 0)
                    Dim y1 As Integer = isNUll(rsSignatures.Fields("y1").Value, 0)
                    Dim x2 As Integer = isNUll(rsSignatures.Fields("x2").Value, 0)
                    Dim y2 As Integer = isNUll(rsSignatures.Fields("y2").Value, 0)
                    Dim page As String = isNUll(rsSignatures.Fields("page").Value, 1)
                    
                    oSign = New tnvSignature(oDocumento)
                    'oSign.PKI = New nvFW.tnvPKI
                    oSign.name = fieldname
                    oSign.use = nvSignUse.user_sign

                    'Configurar parámetros de la firma
                    oSign.PDFSignParams = New tnvPDFSignParam
                    With oSign.PDFSignParams
                        
                        .fieldname = fieldname
                        .reason = "Aceptación de condiciones del crédito"
                        .Location = "Santa Fe"
                        .hashAlgorithm = hashAlgorithm
                        
                        
                        .appendToExistingOnes = appendToExistingOnes
                        .certificationLevel = certificationLevel
                        .cryptoStandard = cryptoStandard
                        .visible_signature = visible
                        .estimatedSize = signatureEstimatedSize
                        

                        'Posicion
                        .page = page
                        .x1 = x1
                        .x2 = x2
                        .y1 = y1
                        .y2 = y2

                        .display = display
                        .signature_text = signatureText
                        
                    End With
                    oSign.signatoryID = "SERIALNUMBER=" & cuitcuil & " " & cuit

                    oDocumento.Signatures.Add(oSign)
                End If
                
                nvDBUtiles.DBCloseRecordset(rsSignatures)
                

                rsFirmantes.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rsFirmantes)
            
            docIndex += 1
            rs.MoveNext()
        End While
        nvDBUtiles.DBCloseRecordset(rs)
        
        
        

        '********************************************
        'Primer pantalla del asistente.
        'Mostrar condiciones de la operación
        '********************************************
        oLegajo.titulo = titulo
        oLegajo.comentario = comentario


        'Metadatos que se deben mostrar al usuario. Condiciones de lo que estaría firmando

        Dim rsMetadatos As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_metadatos WHERE id_circuito_firma=" + id_circuito_firma)
        If Not rsMetadatos.EOF Then
            Dim key As String = rsMetadatos.Fields("key").Value
            Dim label As String = rsMetadatos.Fields("label").Value
            Dim value As String = rsMetadatos.Fields("value").Value
            oLegajo.metadataAdd(key, label, value)
        End If
        nvDBUtiles.DBCloseRecordset(rsMetadatos)
        
        
        
        'Reason de las firmas. Principalmente se utiliza en PDF.
        'Se puede pasar valores tabulados para que el cliente seleccione o "editable" para que ingrese la rason escribíendola
        oLegajo.reason_editable = True
        Dim rsRazones As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_razones WHERE id_circuito_firma=" + id_circuito_firma)
        While Not rsRazones.EOF
            oLegajo.reasonAdd(rsRazones.Fields("label").Value, rsRazones.Fields("selected").Value)
            rsRazones.MoveNext()
        End While
        nvDBUtiles.DBCloseRecordset(rsRazones)
        


        'Location de las firmas. Principalmente se utiliza en PDF. 
        'Se puede pasar valores tabulados para que el cliente seleccione o "editable" para que ingrese la localidad escribíendola.
        oLegajo.location_editable = True
        Dim rsLocaciones As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_locaciones WHERE id_circuito_firma=" + id_circuito_firma)
        While Not rsLocaciones.EOF
            oLegajo.locationAdd(rsLocaciones.Fields("label").Value, rsLocaciones.Fields("selected").Value)
            rsLocaciones.MoveNext()
        End While
        nvDBUtiles.DBCloseRecordset(rsLocaciones)
        


        Dim exportedFilePath As String = System.IO.Path.GetTempPath() + Guid.NewGuid().ToString() + ".tmp"
        oLegajo.exportToFile(exportedFilePath)
        
        Dim outputFile As String = "exportedLegContainer.rm0"
        Response.AddHeader("content-disposition", "attachment; filename=" + outputFile)
        Response.ContentType = "application/xml"
        'Response.CacheControl = "public"

        'Response.Write(res)
        Response.BinaryWrite(System.IO.File.ReadAllBytes(exportedFilePath))
        Response.Flush()
        Response.End()
        
        
        
        'Dim oLegajo2 As New tnvLegContainer
        'oLegajo2.importFromFile("d:\prueba1.rm0")
        'oLegajo2.saveFilesToDir("d:\", True)
        
        
        
        
        
        
        
        
        
    End If
    
    
    
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Firmas ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var vMenu;
        var verFirmas;
        var vButtonItems = {}
        var idCircuitoFirma


        var documentsData = []
        var firmantes = []



        function windowOnload() {
            
            
            idCircuitoFirma = nvFW.pageContents.id_circuito_firma
            if (!idCircuitoFirma) {
                accion = "alta_circuito"

                //nvFW.bloqueo_activar('divCircuito', 'bloqCircuito')

            } else {
                accion = "modificacion_circuito"
                $('titulo').value = nvFW.pageContents.titulo
                $('comentario').value = nvFW.pageContents.comentario


                // linealizar por orden: pasar de objeto a array
                for (var index in nvFW.pageContents.firmantesData["entidades_firmantes"]) {
                    firmantes[index] = nvFW.pageContents.firmantesData["entidades_firmantes"][index]
                }
                // linealizar: pasar de objeto a array
                for (var index in nvFW.pageContents.documentsData) {
                    documentsData[index] = nvFW.pageContents.documentsData[index]
                }



                loadCircuito()
            }

            loadMenusAndButton()
            windowOnresize()
        }


        function windowOnresize() {
            var bodyHeight = $$('body')[0].getHeight()
            var divHeadHeight = $("divHead").getHeight()
            var divFootHeight = $("divFoot").getHeight()

            $("divFirmas").setStyle({ 'height': (bodyHeight - divHeadHeight - divFootHeight - 25) + "px" })

        }



        function submitArchivos() {

            if (idCircuitoFirma) {
                nvFW.bloqueo_activar($$('body')[0], 'bloqueo')
                formArchivos.action = "firmas_ABM.aspx?accion=alta_documento&id_circuito_firma=" + idCircuitoFirma
                formArchivos.submit();
            }
        }




        function abmMetadatos() {

            var win = nvFW.createWindow({
                url: 'metadatos_abm.aspx?id_circuito_firma=' + idCircuitoFirma,
                title: '<b>Metadatos/Parámetros ABM</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 600,
                height: 600,
                onClose: function () {

                    if (win.options.userData.retorno["success"]) {
                    }
                }
            });


            win.options.userData = { input: {}, retorno: {} }
            win.showCenter(true)

        }

        function abmRazonesLocaciones() {

            var win = nvFW.createWindow({
                url: 'razon_locacion_abm.aspx?id_circuito_firma=' + idCircuitoFirma,
                title: '<b>Razones/Locaciones ABM</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 600,
                height: 600,
                onClose: function () {

                    if (win.options.userData.retorno["success"]) {
                    }
                }
            });

            win.options.userData = { input: {}, retorno: {} }
            win.showCenter(true)
        }



        function loadMenusAndButton() {

            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Circuitos</Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Generar archivo RM0</Desc><Acciones><Ejecutar Tipo='script'><Codigo>generarRM0()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>ABM Razones/Locaciones</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abmRazonesLocaciones()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>ABM Metadatos/Parámetros</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abmMetadatos()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["vMenu"].loadImage("abm", "/FW/image/icons/agregar.png")
            vMenu.MostrarMenu()


            verFirmas = new tMenu('divFirmas', 'verFirmas');
            Menus["verFirmas"] = verFirmas
            Menus["verFirmas"].loadImage("agregar", "/FW/image/icons/agregar.png")
            Menus["verFirmas"].loadImage("abm", "/FW/image/icons/abm.png")
            Menus["verFirmas"].loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["verFirmas"].alineacion = 'centro';
            Menus["verFirmas"].estilo = 'A';
            Menus["verFirmas"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Firmas</Desc></MenuItem>")
            Menus["verFirmas"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar Firmante</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregarFirmante()</Codigo></Ejecutar></Acciones></MenuItem>")
            //Menus["verFirmas"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Configuracion Avanzada</Desc><Acciones><Ejecutar Tipo='script'><Codigo>configuracionAvanzadaABM()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["verFirmas"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardarConfigFirmas()</Codigo></Ejecutar></Acciones></MenuItem>")
            verFirmas.MostrarMenu()


            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Guardar";
            vButtonItems[0]["etiqueta"] = "Subir";
            vButtonItems[0]["imagen"] = "guardar";
            vButtonItems[0]["onclick"] = "return submitArchivos()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage('guardar', '/FW/image/icons/guardar.png')

            vListButton.MostrarListButton();
        }

        function hiddenIframeLoad() {
            try {
                nvFW.bloqueo_desactivar($$('body')[0], "bloqueo")
                var strHTML = $('hiddenIframe').contentWindow.document.body.innerHTML
                var strXML = $('hiddenIframe').contentWindow.error_xml.value
                var oXML = new tXML()
                oXML.loadXML(strXML)

                nroError = oXML.selectSingleNode('error_mensajes/error_mensaje/@numError').nodeValue
                mensaje = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/mensaje'))

                if (nroError != 0) {
                    alert(mensaje)
                    return
                }
                else {

                    //                    var nombreDoc = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/nombre_doc'))
                    //                    var idDocumentoFirma = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/id_documento_firma'))

                    //                    var size = Object.keys(documentsData).length
                    //                    var docu = { nombre_doc: nombreDoc, id_documento_firma: idDocumentoFirma }
                    //                    documentsData[size] = docu

                    //                    fisicasSignConfigs[idDocumentoFirma] = {}
                    //                    juridicasSignConfigs[idDocumentoFirma] = {}

                    //                    renderNuevoDocu(docu)


                    var nombre_doc = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/nombre_doc'))
                    var extension = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/extension'))
                    var tmp_file_path = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/tmp_file_path'))

                    var docu = { tmp_file_path: tmp_file_path, nombre_doc: nombre_doc, extension: extension, accion: 'A' }

                    debugger



                    for (var i = 0; i < documentsData.length; i++) {
                        if (documentsData[i].accion == 'I' || documentsData[i].accion == 'B') {
                            continue
                        }
                        if (documentsData[i].nombre_doc == nombre_doc) {
                            alert("El documento ya está en la lista")
                            return
                        }

                    }


                    /*for (var index in documentsData) {
                        if (documentsData[index].accion == 'I' || documentsData[index].accion == 'B') {
                            continue
                        }
                        if (documentsData[index].nombre_doc == nombre_doc) {
                            alert("El documento ya está en la lista")
                            return
                        }
                    }*/


                    var index = documentsData.length
                    documentsData[index] = docu


                    init(nombre_doc)


                    renderNuevoDocu(index)

                }
            }
            catch (e)
        { }
        }






        function init(nombre_doc, index_firmante) {

            
            fisicasSignConfigs[nombre_doc] = {}
            juridicasSignConfigs[nombre_doc] = {}


            if (!index_firmante) {
                index_firmante = 0
            }

            for (var i = index_firmante; i < firmantes.length; i++) {
                var entidad = firmantes[i]["nro_entidad"]
                var entidadesFisicas = firmantes[i]["firmantes"]
                var idEsquemaJuridica = firmantes[i]["id_esquema"]
                var entidadesFisicas = firmantes[i]["firmantes"]

                if (idEsquemaJuridica) {
                    juridicasSignConfigs[nombre_doc][idEsquemaJuridica] = {}

                    for (var j in entidadesFisicas) {

                        var entidadFisica = entidadesFisicas[j]
                        var nroEntidad = entidadFisica["nro_entidad"]

                        juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad] = {}
                        setDefaultParamValues(juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad])
                        juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad]["orden"] = i
                    }



                } else {


                    fisicasSignConfigs[nombre_doc][entidad] = {}
                    setDefaultParamValues(fisicasSignConfigs[nombre_doc][entidad])
                    fisicasSignConfigs[nombre_doc][entidad]["orden"] = i
                }
            }




        }




        function guardar() {

            var titulo = campos_defs.get_value("titulo")
            var comentario = campos_defs.get_value("comentario")


            nvFW.error_ajax_request('firmas_ABM.aspx', {
                parameters: {
                    accion: accion,
                    titulo: titulo,
                    comentario: comentario,
                    nro_entidad: nvFW.pageContents.nro_entidad
                },
                onSuccess: function (err) {

                    if (err.numError == 0 && accion == "alta_circuito") {

                        idCircuitoFirma = err.params["id_circuito_firma"]
                        accion = "modificacion_circuito"

                        //nvFW.bloqueo_desactivar('divCircuito', 'bloqCircuito')
                    }
                }
            });
        }



        function guardarConfigFirmas() {

            var strXML = '<?xml version="1.0" encoding="iso-8859-1"?>'
            strXML += '<circuito_firma_config id_circuito_firma="' + idCircuitoFirma + '">'
            strXML += '<documentos_abm>'
            for (var i = 0; i < documentsData.length; i++) {

                if (documentsData[i].accion == 'B') {
                    strXML += '<documento id_documento_firma="' + documentsData[i].id_documento_firma + '" accion="B"/>'
                }

                if (documentsData[i].accion == 'A') {

                    if (documentsData[i].adjuntable) {

                        var strAdjuntanteDelegado = ""
                        if (documentsData[i].nro_entidad_adjuntante_delegado != null) {
                            strAdjuntanteDelegado = ' nro_entidad_adjuntante_delegado="' + documentsData[i].nro_entidad_adjuntante_delegado + '" '
                        }

                        strXML += '<documento nombre_doc="' + documentsData[i].nombre_doc + '" extension="' + documentsData[i].extension +
                        '" adjuntable="1" nro_entidad_adjuntante="' + documentsData[i].nro_entidad_adjuntante +
                        '" adjuntable_obligatorio="' + (documentsData[i].adjuntable_obligatorio==true?1:0) + '" ' + strAdjuntanteDelegado +
                        ' ppi="' + documentsData[i].ppi + '" depthcolor="' + documentsData[i].depthcolor + '" accion="A"/>'

                    } else {
                        strXML += '<documento nombre_doc="' + documentsData[i].nombre_doc + '" extension="' + documentsData[i].extension + 
                        '" adjuntable="0" tmp_file_path="' + XMLAttributeStringToString(documentsData[i].tmp_file_path) + '" accion="A"/>'
                    }

                }


                if (documentsData[i].accion == 'M') {
                    
                    var strAdjuntanteDelegado = ""
                    if (documentsData[i].nro_entidad_adjuntante_delegado != null) {
                        strAdjuntanteDelegado = ' nro_entidad_adjuntante_delegado="' + documentsData[i].nro_entidad_adjuntante_delegado + '" '
                    }

                    //id_documento_firma="' + documentsData[i].id_documento_firma + '" 

                    strXML += '<documento nombre_doc="' + documentsData[i].nombre_doc + '" extension="' + documentsData[i].extension +
                    '" nro_entidad_adjuntante="' + documentsData[i].nro_entidad_adjuntante +
                    '" adjuntable_obligatorio="' + (documentsData[i].adjuntable_obligatorio == true ? 1 : 0) + '" ' + strAdjuntanteDelegado +
                    ' ppi="' + documentsData[i].ppi + '" depthcolor="' + documentsData[i].depthcolor + '" accion="M"/>'

                }

            }

            strXML += '</documentos_abm>'

            
            strXML += '<firmantes_abm>'
            for (nombre_doc in juridicasSignConfigs) {

                for (id_esquema in juridicasSignConfigs[nombre_doc]) {

                    if (juridicasSignConfigs[nombre_doc][id_esquema]) {

                        for (nro_entidad in juridicasSignConfigs[nombre_doc][id_esquema]) {

                            var params = juridicasSignConfigs[nombre_doc][id_esquema][nro_entidad]
                            var orden = params["orden"]

                            strXML += '<firmante nombre_doc="' + XMLAttributeStringToString(nombre_doc) + '" id_esquema="' + id_esquema + '" nro_entidad="' + nro_entidad + '" orden="' + orden + '">'
                            strXML += getFirmaParamsXML(params)
                            strXML += '</firmante>'


                        }
                    }
                }

            }

            


            for (nombre_doc in fisicasSignConfigs) {

                for (nro_entidad in fisicasSignConfigs[nombre_doc]) {

                    var params = fisicasSignConfigs[nombre_doc][nro_entidad]
                    var orden = params["orden"]

                    strXML += '<firmante nombre_doc="' + XMLAttributeStringToString(nombre_doc) + '" nro_entidad="' + nro_entidad + '" orden="' + orden + '">'
                    strXML += getFirmaParamsXML(params)
                    strXML += '</firmante>'
                }
            }


            strXML += '</firmantes_abm>'
            strXML += '</circuito_firma_config>'


            /*for (var i = 0; i < firmantes.length; i++) {

            var firmantes[]


            }*/

            nvFW.error_ajax_request(
                'firmas_ABM.aspx', {
                    parameters: { accion: 'firmante_abm', strXML: strXML },
                    onSuccess: function (err, transport) {
                        if (err.numError == 0) {
                            debugger
                            // las acciones de abm sobre los doc se efectuaron,
                            // actualizar el arreglo de documentos
                            for (var i = 0; i < documentsData.length; i++) {
                                if (documentsData[i].accion == "A" || documentsData[i].accion == "M") {
                                    documentsData[i].accion = ""
                                }

                                if (documentsData[i].accion == "B") {
                                    documentsData[i].accion = "I"
                                }


                            }
                        }
                    }
                });






        }






        function getFirmaParamsXML(params) {
            
            var strXML = ""
            strXML += "<firma_params"
            strXML += " hashAlgorithm='" + params.hashAlgorithm + "'"
            strXML += " setLTV='" + params.setLTV + "'"
            strXML += " requerido='" + params.requerido + "'"
            strXML += " fieldname='" + params.fieldname + "'"
            strXML += " >"

            strXML += "<PDF_params "
            strXML += " appendToExistingOnes='true'"
            strXML += " certificationLevel='" + params.PDF_params.certificationLevel + "'"
            strXML += " cryptoStandard='" + params.PDF_params.cryptoStandard + "'"
            strXML += " signatureEstimatedSize='" + params.PDF_params.signatureEstimatedSize + "'"
            strXML += " visible='" + params.PDF_params.visible + "'"
            strXML += " >"

            if (params.PDF_params.visible) {
                strXML += "<PDF_appereance "
                strXML += " x1='" + params.PDF_params.PDF_appereance.x1 + "'"
                strXML += " y1='" + params.PDF_params.PDF_appereance.y1 + "'"
                strXML += " x2='" + params.PDF_params.PDF_appereance.x2 + "'"
                strXML += " y2='" + params.PDF_params.PDF_appereance.y2 + "'"
                strXML += " page='" + params.PDF_params.PDF_appereance.page + "'"
                //strXML += " fieldname='" + params.PDF_params.PDF_appereance.fieldname + "'"
                strXML += " fontFamily='" + params.PDF_params.PDF_appereance.fontFamily + "'"
                strXML += " fontColor='" + params.PDF_params.PDF_appereance.fontColor + "'"
                strXML += " fontSize='" + params.PDF_params.PDF_appereance.fontSize + "'"
                strXML += " fontStyle='" + params.PDF_params.PDF_appereance.fontStyle + "'"
                strXML += " display='" + params.PDF_params.PDF_appereance.display + "'"
                strXML += " signatureText='" + params.PDF_params.PDF_appereance.signatureText + "'"
                strXML += "/>"
            }

            strXML += "</PDF_params>"
            strXML += "</firma_params>"

            return strXML
        }



        function agregarFirmante() {


            var win = nvFW.createWindow({
                //url: 'entidad_consultar.aspx',
                url: '/fw/funciones/entidad_consultar.aspx?modoSeleccionarEntidadFirmante=1',
                title: '<b>Seleccionar Entidad</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 600,
                height: 483,
                onClose: function () {

                    var entidadFisica = win.options.userData.retorno["entidad_fisica"]
                    var entidadJuridica = win.options.userData.retorno["entidad_juridica"]
                    var orden = firmantes.length
                    var data = {}

                    //var strXML = "<?xml version='1.0' encoding='iso-8859-1'?><firmantes_abm id_circuito_firma='" + idCircuitoFirma + "'><firmantes_alta>"

                    if (entidadFisica) {

                        var nroEntidad = win.options.userData.retorno["entidad_fisica"]["nro_entidad"]
                        var razonSocial = win.options.userData.retorno["entidad_fisica"]["razon_social"]

                        var data = { razon_social: razonSocial, nro_entidad: nroEntidad }


                        for (var i = 0; i < firmantes.length; i++) {
                            if (firmantes[i]["nro_entidad"] == nroEntidad) {
                                alert("El firmante ya esta en la lista")
                                return
                            }
                        }


                        firmantes[orden] = data



                        for (var j = 0; j < documentsData.length; j++) {

                            if (documentsData[j].accion == 'B' || documentsData[j].accion == 'I') {
                                continue
                            }

                            var nombre_doc = documentsData[j].nombre_doc
                            fisicasSignConfigs[nombre_doc][nroEntidad] = {}
                            setDefaultParamValues(fisicasSignConfigs[nombre_doc][nroEntidad])
                            fisicasSignConfigs[nombre_doc][nroEntidad]["orden"] = orden
                        }


                        renderFirmante(orden)

                        //strXML += "<firmante nro_entidad='" + nroEntidad + "' orden='" + orden + "'/>"


                    } else {
                        var xmlData = win.options.userData.retorno["entidad_juridica"]["xmlData"]
                        var objXml = new tXML()
                        objXml.loadXML(xmlData)

                        var entidadJuridicaNode = objXml.selectNodes("firmantes/esquema")[0]
                        var idEsquemaJuridica = getAttribute(entidadJuridicaNode, "idEsquema", "")
                        var numEntidad = getAttribute(entidadJuridicaNode, "nro_entidad", "")
                        var razonSocialJuridica = getAttribute(entidadJuridicaNode, "razon_social", "")


                        for (var i = 0; i < firmantes.length; i++) {
                            if (firmantes[i]["nro_entidad"] == numEntidad) {
                                alert("El firmante ya esta en la lista")
                                return
                            }
                        }


                        var data = {}
                        data["razon_social"] = razonSocialJuridica
                        data["nro_entidad"] = numEntidad
                        data["id_esquema"] = idEsquemaJuridica
                        data["firmantes"] = {}


                        var entidadesFisicasNodes = objXml.selectNodes("firmantes/esquema/firmante")
                        for (var i = 0; i < entidadesFisicasNodes.length; i++) {

                            var entidadFisicaNode = entidadesFisicasNodes[i]
                            var attrNroEntidad = getAttribute(entidadFisicaNode, "nro_entidad", "")
                            var attrNroFuncion = getAttribute(entidadFisicaNode, "nro_funcion", "")
                            var attrRazonSocial = getAttribute(entidadFisicaNode, "razon_social", "")

                            data["firmantes"][i] = { razon_social: attrRazonSocial, nro_entidad: attrNroEntidad, nro_funcion: attrNroFuncion }

                            //strXML += "<firmante nro_entidad='" + attrNroEntidad + "' nro_funcion='" + attrNroFuncion + "' id_esquema='" + idEsquemaJuridica + "' orden='" + orden  + "'/>"
                        }

                        firmantes[orden] = data


                        for (var j = 0; j < documentsData.length; j++) {

                            if (documentsData[j].accion == 'B' || documentsData[j].accion == 'I') {
                                continue
                            }

                            var nombre_doc = documentsData[j].nombre_doc
                            juridicasSignConfigs[nombre_doc][idEsquemaJuridica] = {}


                            for (var k in data["firmantes"]) {

                                var entidadFisica = data["firmantes"][k]
                                var nroEntidad = entidadFisica["nro_entidad"]


                                juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad] = {}
                                setDefaultParamValues(juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad])
                                juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad]["orden"] = orden

                            }

                        }


                        /*for (var k = 0; k < documentsData.length; k++) {
                        for (var j in data["firmantes"]) {

                        var entidadFisica = data["firmantes"][j]
                        var nroEntidad = entidadFisica["nro_entidad"]


                        juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad] = {}
                        setDefaultParamValues(juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad])
                        juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad]["orden"] = orden

                        }
                        }
                        debugger*/

                        renderFirmanteJuridica(orden)

                    }


                    //strXML += "</firmantes_alta></firmantes_abm>"


                    //idCircuitoFirma
                    //<entidades>
                    //<entidades_fisicas>
                    //<entidad nro_entidad>
                    //<entidades_fisicas>
                    //<entidades_juridicas>
                    //<entidad_juridica idesquema>
                    //<entidad nro_entidad funcion>


                    /*nvFW.error_ajax_request('firmas_ABM.aspx', {
                    parameters: {
                    accion: "firmante_abm",
                    strXML: strXML
                    },
                    onSuccess: function (err) {

                    if (err.numError == 0 && entidadFisica) {
                    var data = { razon_social: razonSocial, nro_entidad: nroEntidad }
                    renderFirmante(data)
                    } else {

                    var data = {}
                    var objXml = new tXML()
                    objXml.loadXML(xmlData)

                    var entidadJuridicaNode = objXml.selectNodes("firmantes/esquema")[0]
                    var razonSocialJuridica = getAttribute(entidadJuridicaNode, "razon_social", "")
                    var idEsquemaJuridica = getAttribute(entidadJuridicaNode, "idEsquema", "")
                    var entidadesFisicasNodes = objXml.selectNodes("firmantes/esquema/firmante")

                    data["razon_social"] = razonSocialJuridica
                    data["id_esquema"] = idEsquemaJuridica
                    data["firmantes"] = {}
                    for (var i = 0; i < entidadesFisicasNodes.length; i++) {

                    var entidadFisicaNode = entidadesFisicasNodes[i]
                    var attrNroEntidad = getAttribute(entidadFisicaNode, "nro_entidad", "")
                    var attrNroFuncion = getAttribute(entidadFisicaNode, "nro_funcion", "")
                    var attrRazonSocial = getAttribute(entidadFisicaNode, "razon_social", "")

                    data["firmantes"][i] = { razon_social: attrRazonSocial, nro_entidad: attrNroEntidad, nro_funcion: attrNroFuncion }
                    }

                    // mostrar el firmante
                    renderFirmanteJuridica(data)

                    }

                    // adjuntar el firmante al vector de firmantes
                    firmantes[orden] = data
                    }
                    })*/



                }

            });

            win.showCenter(true)
            win.options.userData = { retorno: {} }
        }



        function eliminarFirmante(nro_entidad) {

            var index
            for (var i = 0; i < firmantes.length; i++) {
                if (firmantes[i]["nro_entidad"] == nro_entidad) {
                    index = i
                    break
                }
            }

            //var nro_entidad = firmantes[index].nro_entidad
            var id_esquema = firmantes[index].id_esquema

            firmantes.splice(index, 1)

            for (var i = 0; i < $('tablaDocumentosFirmas').rows.length; i++) {
                $('tablaDocumentosFirmas').rows[i].deleteCell(index + 1)
            }

            if (id_esquema) {
                for (var nombre_doc in juridicasSignConfigs) {
                    //juridicasSignConfigs[nombre_doc][id_esquema] = undefined
                    delete juridicasSignConfigs[nombre_doc][id_esquema]
                }
            } else {
                for (var nombre_doc in fisicasSignConfigs) {
                    delete fisicasSignConfigs[nombre_doc][nro_entidad]
                    //fisicasSignConfigs[nombre_doc][nro_entidad] = undefined
                }

            }



            for (var nombre_doc in juridicasSignConfigs) {
                //juridicasSignConfigs[nombre_doc][id_esquema] = undefined
                for (var id_esquema in juridicasSignConfigs[nombre_doc]) {
                    for (var entidad in juridicasSignConfigs[nombre_doc][id_esquema])
                        if (parseInt(juridicasSignConfigs[nombre_doc][id_esquema][entidad]["orden"]) > parseInt(index)) {
                            juridicasSignConfigs[nombre_doc][id_esquema][entidad]["orden"] = parseInt(juridicasSignConfigs[nombre_doc][id_esquema][entidad]["orden"]) - 1
                        }
                }
            }



            for (var nombre_doc in fisicasSignConfigs) {
                for (var nro_entidad in fisicasSignConfigs[nombre_doc]) {
                    if (parseInt(fisicasSignConfigs[nombre_doc][nro_entidad]["orden"]) > parseInt(index)) {
                        fisicasSignConfigs[nombre_doc][nro_entidad]["orden"] = parseInt(fisicasSignConfigs[nombre_doc][nro_entidad]["orden"]) - 1
                    }
                }
            }



        }


        function eliminarDocumento(index) {

            index = parseInt(index)
            var nombre_doc = documentsData[index].nombre_doc


            // ocultar la fila
            $('tablaDocumentosFirmas').rows[index + 1].style.display = 'none'


            // si el doc existe en BD
            if (documentsData[index].id_documento_firma) {

                // marcar como doc a borrar
                documentsData[index].accion = 'B'

            } else {  // si el doc no existe en la BD (fue agregado pero aun no guardado)

                // marcar como doc a ignorar (no será dado de alta, dado que se lo quitó posteriormente)
                documentsData[index].accion = 'I'
            }


            // eliminar las configuraciones de firma para el documento
            delete juridicasSignConfigs[nombre_doc]
            delete fisicasSignConfigs[nombre_doc]


        }




        var juridicasSignConfigs = {}
        function setFirmaJuridicaRequerida(e, nombre_docu, id_esquema) {

            var val = e.checked
            for (nro_entidad in juridicasSignConfigs[nombre_docu][id_esquema]) {
                juridicasSignConfigs[nombre_docu][id_esquema][nro_entidad].requerido = val
            }
        }


        var fisicasSignConfigs = {}
        function setFirmaFisicaRequerida(e, nombre_doc, nro_entidad) {

            var val = e.checked
            fisicasSignConfigs[nombre_doc][nro_entidad].requerido = val

        }

        function configurarFirma(index_doc, nro_entidad, id_esquema) {

            var nombre_doc = documentsData[index_doc].nombre_doc
            var doc_adjuntable = documentsData[index_doc].adjuntable

            var firma_params
            if (!id_esquema) {
                firma_params = fisicasSignConfigs[nombre_doc][nro_entidad]
            } else {
                firma_params = juridicasSignConfigs[nombre_doc][id_esquema][nro_entidad]
            }

            if (!id_esquema) {
                id_esquema = ""
            }

            var win = nvFW.createWindow({
                url: '/fw/document_signing/pdf_signature_editor.aspx?modo=config_firma_esquema&doc_adjuntable=' + doc_adjuntable,
                title: '<b>Configuración de Firma</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 600,
                height: 600,
                onClose: function () {
                    
                    if (win.options.userData.retorno["success"]) {
                        if (!id_esquema) {
                            fisicasSignConfigs[nombre_doc][nro_entidad] = win.options.userData.retorno["firma_params"]
                        } else {
                            juridicasSignConfigs[nombre_doc][id_esquema][nro_entidad] = win.options.userData.retorno["firma_params"]
                        }
                    }
                }
            });


            win.options.userData = { input: { firma_params: firma_params, docu: documentsData[index_doc] }, retorno: { firma_params: {}} }
            win.showCenter(true)
        }



        function renderNuevoDocu(index_docu) {
            var docu = documentsData[index_docu]
            var id_documento_firma = docu.id_documento_firma
            var nombre_doc = docu.nombre_doc

            var table = $('tablaDocumentosFirmas')
            var row = table.insertRow(table.rows.length)
            var cell = row.insertCell(0)
            cell.innerHTML = "<div><img style='cursor:pointer' src='/FW/image/icons/eliminar.png' onclick='eliminarDocumento(\"" + index_docu + "\")' title='eliminar'/>&nbsp;" + nombre_doc + "</div>"


            for (var i = 0; i < firmantes.length; i++) {
                if (firmantes[i]["id_esquema"]) {

                    var nroEntidadJuridica = firmantes[i]["nro_entidad"]
                    var entidadesFisicas = firmantes[i]["firmantes"]
                    var idEsquemaJuridica = firmantes[i]["id_esquema"]

                    //juridicasSignConfigs[nombre_doc][idEsquemaJuridica] = {}

                    var strHTML =
                    "<div style='text-align:center'><input type='checkbox' checked='checked' onclick ='setFirmaJuridicaRequerida(this, \"" + nombre_doc + "\"," + idEsquemaJuridica + ")'/> Requerida</div>" +
                    "<table style='width:100%'><tr>"

                    for (var j in entidadesFisicas) {

                        var entidadFisica = entidadesFisicas[j]
                        var nroEntidad = entidadFisica["nro_entidad"]


                        /*juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad] = {}
                        setDefaultParamValues(juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad])
                        juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad]["orden"] = i*/

                        strHTML +=
                        "<td style='text-align:center'><img src='/FW/image/icons/abm.png' title='Ver Firma' onclick='configurarFirma(\"" + index_docu + "\", " + nroEntidad + ", " + idEsquemaJuridica + ")'/></td>"
                        //"<td><input type='button' value='Ver Firma' onclick='configurarFirma(" + docu.id_documento_firma + ", " + nroEntidad + "," + idEsquemaJuridica + ")'/></td>"
                    }
                    strHTML += "</tr></table>"

                    row.insertCell(-1).innerHTML += strHTML




                } else {

                    var nroEntidad = firmantes[i].nro_entidad;

                    /*fisicasSignConfigs[nombre_doc][nroEntidad] = {}
                    setDefaultParamValues(fisicasSignConfigs[nombre_doc][nroEntidad])
                    fisicasSignConfigs[nombre_doc][nroEntidad]["orden"] = i*/

                    row.insertCell(-1).innerHTML +=
                    "<div style='text-align:center'><input type='checkbox' checked='checked' onclick ='setFirmaFisicaRequerida(this, \"" + nombre_doc + "\"," + nroEntidad + ")'/> Requerida</div>" +
                    //"<div><input type='button' value='Ver Firma' onclick='configurarFirma(" + docu.id_documento_firma + ", " + nroEntidad + ")'/></div>"
                    "<div style='text-align:center'><img src='/FW/image/icons/abm.png' title='Ver Firma' onclick='configurarFirma(\"" + index_docu + "\", " + nroEntidad + ")'/></div>"

                }
            }



        }


        function renderFirmante(firmante_index) {
            
            var entidad = firmantes[firmante_index]
            var razonSocial = entidad["razon_social"]
            var nroEntidad = entidad["nro_entidad"]

            var table = $('tablaDocumentosFirmas')
            var headerRow = table.rows[0]
            var cell = headerRow.insertCell(headerRow.cells.length)
            cell.innerHTML = "<div style='text-align:center'><img src='/fw/image/icons/eliminar.png' style='cursor:pointer' title='eliminar' onclick='eliminarFirmante(" + nroEntidad + ")'/>" + razonSocial + "</div>"
                             + "<div style='text-align:center'><img src='/fw/image/icons/file.png' style='cursor:pointer' onclick='nuevoDocAdjuntable(" + nroEntidad + ")'/></div>"

            

            for (var i = 1; i < table.rows.length; i++) {

                if (table.rows[i].style.display == "none") {
                    continue
                }

                // i arranca en 1, por el header de la tabla
                // i = 1 corresponde al index 0 en documentsData
                var index = i - 1
                var id_documento_firma = documentsData[index].id_documento_firma
                var nombre_doc = documentsData[index].nombre_doc
                var adjuntable_obligatorio = documentsData[index].adjuntable_obligatorio


                var nro_entidad_adjuntante = documentsData[index].nro_entidad_adjuntante


                var row = table.rows[i]
                var cell = row.insertCell(row.cells.length)

                if (fisicasSignConfigs[nombre_doc][nroEntidad] != null) {


                    if (nro_entidad_adjuntante == nroEntidad) {
                        var strChecked = ""
                        if (adjuntable_obligatorio) {
                            strChecked = "checked='checked'"
                        }
                        var check_id = 'check_oblig_' + index
                        cell.innerHTML += "<div style='text-align:center'><input type='checkbox' id='" + check_id + "' " + strChecked + " onclick ='setDocAdjuntableObligatorio(this, " + index + ")'/> Obligatorio</div>"
                            + "<div style='text-align:center'><img src='/FW/image/icons/abm.png' title='Configurar' onclick='configurarDocAdjuntable(" + check_id + ",\"" + index + "\", " + nroEntidad + ")'/></div>"
                    }


                    var strChecked = ""
                    if (fisicasSignConfigs[nombre_doc][nroEntidad]["requerido"]) {
                        strChecked = "checked='checked'"
                    }


                    cell.innerHTML +=
                    "<div style='text-align:center'><input type='checkbox' " + strChecked + " onclick ='setFirmaFisicaRequerida(this, \"" + nombre_doc + "\"," + nroEntidad + ")'/> Requerida</div>" +
                    //"<div><input type='button' value='Ver Firma' onclick='configurarFirma(" + documentsData[index].id_documento_firma + ", " + nroEntidad + ")'/></div>"
                    "<div style='text-align:center'><img src='/FW/image/icons/abm.png' title='Ver Firma' onclick='configurarFirma(\"" + index + "\", " + nroEntidad + ")'/></div>"

                }

            }


        }


        function configurarDocAdjuntable(elem, index_docu, nro_entidad) {

            var index_firmante
            for (var i = 0; i < firmantes.length; i++) {
                if (firmantes[i]["nro_entidad"] == nro_entidad) {
                    index_firmante = i
                    break
                }
            }

            var docu = documentsData[index_docu]

            var win = nvFW.createWindow({
                url: 'documento_adjuntable_agregar.aspx',
                title: '<b>Definir documento a adjuntar</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 600,
                height: 483,
                onClose: function () {
                    if (win.options.userData.retorno["success"]) {
                        
                        var docu_adjuntable = win.options.userData.retorno["docu_adjuntable"]

                        if (docu.accion != "A") {
                            docu_adjuntable.accion = "M"
                        }

                        documentsData[index_docu] = docu_adjuntable

                        $(elem).checked = docu_adjuntable.adjuntable_obligatorio


                    }
                }
            });
            win.showCenter(true)
            win.options.userData = { input: { firmante: firmantes[index_firmante], docu: documentsData[index_docu] }, retorno: {} }

        }





        function renderFirmanteJuridica(firmante_index) {


            var entidadJuridica = firmantes[firmante_index]

            var razonSocialJuridica = entidadJuridica["razon_social"]
            var idEsquemaJuridica = entidadJuridica["id_esquema"]
            var nroEntidadJuridica = entidadJuridica["nro_entidad"]

            var table = $('tablaDocumentosFirmas')
            var headerRow = table.rows[0]
            var cell = headerRow.insertCell(headerRow.cells.length)
            var strHTML = "<table class='tb1'><tr><td style='text-align:center'>"
                + "<div style='text-align:center'><img src='/fw/image/icons/eliminar.png' style='cursor:pointer' title='eliminar' onclick='eliminarFirmante(" + nroEntidadJuridica + ", " + idEsquemaJuridica + ")'/>"
                + razonSocialJuridica
                + "<div style='text-align:center'><img src='/fw/image/icons/file.png' style='cursor:pointer' onclick='nuevoDocAdjuntable(" + nroEntidadJuridica + ")'/></div>"
                + "</td></tr></table>"

            strHTML += "<table class='tb1'><tr>"

            var entidadesFisicas = entidadJuridica["firmantes"]
            for (var i in entidadesFisicas) {

                var entidadFisica = entidadesFisicas[i]

                //var nro_funcion = entidadFisica["nro_funcion"]
                var razon_social = entidadFisica["razon_social"]
                strHTML += "<td style='text-align:center'>" + razon_social
                //strHTML += "<div style='text-align:center'><img src='/fw/image/icons/file.png' style='cursor:pointer' onclick='nuevoDocAdjuntable(" + firmante_index + ")'/></div>"
                strHTML += "</td>"
            }

            strHTML += "</tr></table>"

            cell.innerHTML = strHTML




            // dibujar los botones de configuracion para cada documento del firmante
            for (var i = 1; i < table.rows.length; i++) {

                if (table.rows[i].style.display == "none") {
                    continue
                }

                var index = i - 1

                var row = table.rows[i]
                var cell = row.insertCell(row.cells.length)
                var nombre_doc = documentsData[index].nombre_doc
                var id_documento_firma = documentsData[index].id_documento_firma
                var nombre_doc = documentsData[index].nombre_doc
                var nro_entidad_adjuntante = documentsData[index].nro_entidad_adjuntante
                var adjuntable_obligatorio = documentsData[index].adjuntable_obligatorio

                /*if (!juridicasSignConfigs[nombre_doc][idEsquemaJuridica]) {
                juridicasSignConfigs[nombre_doc][idEsquemaJuridica] = {}
                }*/

                if (juridicasSignConfigs[nombre_doc][idEsquemaJuridica] == null) {
                    continue
                }


                var strHTML = ""
                if (nro_entidad_adjuntante == nroEntidadJuridica) {

                    var strChecked = ""
                    if (adjuntable_obligatorio) {
                        strChecked = "checked='checked'"
                    }
                    var check_id = 'check_oblig_' + index
                    strHTML += "<div style='text-align:center'><input type='checkbox' id='" + check_id + "' " + strChecked + " onclick ='setDocAdjuntableObligatorio(this, " + index + ")'/> Obligatorio</div>"
                        + "<div style='text-align:center'><img src='/FW/image/icons/abm.png' title='Configurar' onclick='configurarDocAdjuntable(" + check_id + ",\"" + index + "\", " + nro_entidad_adjuntante + ")'/></div>"
                }




                var strEntidades = ""
                var requerido
                for (var j in entidadesFisicas) {

                    var entidadFisica = entidadesFisicas[j]
                    var nroEntidad = entidadFisica["nro_entidad"]

                    strEntidades +=
                    "<td style='text-align:center'><img src='/FW/image/icons/abm.png' title='Ver Firma' onclick='configurarFirma(\"" + index + "\", " + nroEntidad + "," + idEsquemaJuridica + ")'/></td>"

                    // el flag es requerido, o no requerido, para todas las entidades fisicas que componen la entidad juridica
                    requerido = juridicasSignConfigs[nombre_doc][idEsquemaJuridica][nroEntidad]["requerido"]
                }





                var strChecked = ""
                if (requerido) {
                    strChecked = "checked = 'checked'"
                }

                strHTML +=
                    "<div style='text-align:center'><input type='checkbox' " + strChecked + " onclick ='setFirmaJuridicaRequerida(this, \"" + nombre_doc + "\", " + idEsquemaJuridica + ")'/> Requerida</div>" +
                    "<table style='width:100%'><tr>"

                strHTML += strEntidades
                strHTML += "</tr></table>"

                cell.innerHTML = strHTML

            }

        }





        function setDefaultParamValues(params) {

            params["requerido"] = true
            params["hashAlgorithm"] = 1
            params["setLTV"] = true
            params["fieldname"] = ""

            params["PDF_params"] = {}
            params["PDF_params"]["appendToExisitingOnes"] = true
            params["PDF_params"]["certificationLevel"] = 0
            params["PDF_params"]["cryptoStandard"] = 1
            params["PDF_params"]["signatureEstimatedSize"] = 0
            params["PDF_params"]["visible"] = false


            /*params["PDF_params"]["PDF_appereance"] = {}
            params["PDF_params"]["PDF_appereance"]["x1"] = 0
            params["PDF_params"]["PDF_appereance"]["y1"] = 0
            params["PDF_params"]["PDF_appereance"]["x2"] = 0
            params["PDF_params"]["PDF_appereance"]["y2"] = 0
            params["PDF_params"]["PDF_appereance"]["page"] = 1
            params["PDF_params"]["PDF_appereance"]["fieldname"] = ""
            params["PDF_params"]["PDF_appereance"]["fontColor"] = 0
            params["PDF_params"]["PDF_appereance"]["fontSize"] = 9
            params["PDF_params"]["PDF_appereance"]["fontStyle"] = 0
            params["PDF_params"]["PDF_appereance"]["fontFamily"] = 2
            params["PDF_params"]["PDF_appereance"]["display"] = 0
            params["PDF_params"]["PDF_appereance"]["signatureText"] = 0*/


        }





        function loadCircuito() {


            fisicasSignConfigs = nvFW.pageContents.fisicasSignConfigs
            juridicasSignConfigs = nvFW.pageContents.juridicasSignConfigs

            if (!fisicasSignConfigs) {
                fisicasSignConfigs = {}
            }
            if (!juridicasSignConfigs) {
                juridicasSignConfigs = {}
            }



            var table = $('tablaDocumentosFirmas')


            // labels de los documentos
            if (documentsData) {
                for (var i = 0; i < documentsData.length; i++) {
                    var docu = documentsData[i]
                    var row = table.insertRow(table.rows.length)
                    var cell = row.insertCell(0)
                    cell.innerHTML = "<div><img style='cursor:pointer' src='/FW/image/icons/eliminar.png' onclick='eliminarDocumento(\"" + i + "\")' title='eliminar'/>&nbsp;" + docu.nombre_doc + "</div>"


                    if (!fisicasSignConfigs[docu.nombre_doc]) {
                        fisicasSignConfigs[docu.nombre_doc] = {}
                    }
                    if (!juridicasSignConfigs[docu.nombre_doc]) {
                        juridicasSignConfigs[docu.nombre_doc] = {}
                    }


                }
            }

            
            // agregar las columnas de los firmantes
            for (var i = 0; i < firmantes.length; i++) {
                if (firmantes[i]["id_esquema"]) {

                    renderFirmanteJuridica(i)
                } else {
                    renderFirmante(i)
                }
            }

        }


        function nuevoDocAdjuntable(nro_entidad) {

            var index_firmante
            for (var i = 0; i < firmantes.length; i++) {
                if (firmantes[i]["nro_entidad"] == nro_entidad) {
                    index_firmante = i
                    break
                }
            }


            var win = nvFW.createWindow({
                url: 'documento_adjuntable_agregar.aspx',
                title: '<b>Definir documento a adjuntar</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 600,
                height: 483,
                onClose: function () {
                    if (win.options.userData.retorno["success"]) {

                        var docu_adjuntable = win.options.userData.retorno["docu_adjuntable"]
                        docu_adjuntable.accion = "A"
                        var nombre_doc = docu_adjuntable["nombre_doc"]


                        /*for (var i = 0; i < documentsData.length; i++) {
                            if (documentsData[i].nombre_doc == nombre_doc) {
                                alert("El documento ya está en la lista")
                                return
                            }
                        }*/


                        for (var i = 0; i < documentsData.length; i++) {
                            if (documentsData[i].accion == 'I' || documentsData[i].accion == 'B') {
                                continue
                            }
                            if (documentsData[i].nombre_doc == nombre_doc) {
                                alert("El documento ya está en la lista")
                                return
                            }
                        }


                        var index = documentsData.length
                        documentsData[index] = docu_adjuntable
                        init(nombre_doc, index_firmante)
                        renderNuevoDocuAdjuntable(index, index_firmante, nro_entidad)
                    }
                }
            });
            win.showCenter(true)
            win.options.userData = { input: { firmante: firmantes[index_firmante] }, retorno: {} }
        }



        function setDocAdjuntableObligatorio(elem, index_docu) {

            documentsData[index_docu]["adjuntable_obligatorio"] = elem.checked

            if (documentsData[index_docu].accion != "A") {
                documentsData[index_docu].accion = "M"
            }
        }



        function renderNuevoDocuAdjuntable(index_docu, index_firmante, entidad_firmante) {

            
            var docu = documentsData[index_docu]
            var id_documento_firma = docu.id_documento_firma
            var nombre_doc = docu.nombre_doc

            var table = $('tablaDocumentosFirmas')
            var row = table.insertRow(table.rows.length)
            var cell = row.insertCell(0)
            cell.innerHTML = "<div><img style='cursor:pointer' src='/FW/image/icons/eliminar.png' onclick='eliminarDocumento(\"" + index_docu + "\")' title='eliminar'/>&nbsp;" + nombre_doc + "</div>"



            var i = 0
            var str = ""
            if (index_firmante != null) {

                for (; i < index_firmante; i++) {
                    row.insertCell(-1).innerHTML += ""
                }

                var check_id = 'check_oblig_' + index_docu
                str += "<div style='text-align:center'><input type='checkbox' id='" + check_id + "' checked='checked' onclick ='setDocAdjuntableObligatorio(this, " + index_docu + ")'/> Obligatorio</div>"
                + "<div style='text-align:center'><img src='/FW/image/icons/abm.png' title='Configurar' onclick='configurarDocAdjuntable(" + check_id + ", \"" + index_docu + "\", " + entidad_firmante + ")'/></div>"

            }


            for (; i < firmantes.length; i++) {


                if (firmantes[i]["id_esquema"]) {

                    var nroEntidadJuridica = firmantes[i]["nro_entidad"]
                    var entidadesFisicas = firmantes[i]["firmantes"]
                    var idEsquemaJuridica = firmantes[i]["id_esquema"]

                    //juridicasSignConfigs[nombre_doc][idEsquemaJuridica] = {}


                    // para el firmante que agrega documento, se dibuja la opcion
                    // para chequear la obligatoriedad del adjunto
                    var strHTML = str
                    str = ""


                    strHTML +=
                    "<div style='text-align:center'><input type='checkbox' checked='checked' onclick ='setFirmaJuridicaRequerida(this, \"" + nombre_doc + "\"," + idEsquemaJuridica + ")'/> Requerida</div>" +
                    "<table style='width:100%'><tr>"

                    for (var j in entidadesFisicas) {

                        var entidadFisica = entidadesFisicas[j]
                        var nroEntidad = entidadFisica["nro_entidad"]

                        strHTML +=
                        "<td style='text-align:center'><img src='/FW/image/icons/abm.png' title='Ver Firma' onclick='configurarFirma(\"" + index_docu + "\", " + nroEntidad + ", " + idEsquemaJuridica + ")'/></td>"
                        //"<td><input type='button' value='Ver Firma' onclick='configurarFirma(" + docu.id_documento_firma + ", " + nroEntidad + "," + idEsquemaJuridica + ")'/></td>"
                    }
                    strHTML += "</tr></table>"

                    row.insertCell(-1).innerHTML += strHTML


                } else {

                    var nroEntidad = firmantes[i].nro_entidad;

                    var strHTML = str
                    str = ""


                    strHTML += "<div style='text-align:center'><input type='checkbox' checked='checked' onclick ='setFirmaFisicaRequerida(this, \"" + nombre_doc + "\"," + nroEntidad + ")'/> Requerida</div>" +
                    //"<div><input type='button' value='Ver Firma' onclick='configurarFirma(" + docu.id_documento_firma + ", " + nroEntidad + ")'/></div>"
                    "<div style='text-align:center'><img src='/FW/image/icons/abm.png' title='Ver Firma' onclick='configurarFirma(\"" + index_docu + "\", " + nroEntidad + ")'/></div>"

                    row.insertCell(-1).innerHTML = strHTML

                }
            }

        }





        function generarRM0() {

            $('ifrResponse').src = "firmas_ABM.aspx?accion=GENERAR_RM0&id_circuito_firma=" + nvFW.pageContents.id_circuito_firma 

//            nvFW.error_ajax_request('firmas_ABM.aspx', {
//                parameters: {
//                    accion: "GENERAR_RM0",
//                    id_circuito_firma: nvFW.pageContents.id_circuito_firma
//                },
//                onSuccess: function (err) {
//                    if (err.numError) {

//                    }
//                }
//            });
        }

    </script>
</head>
<body onload="return windowOnload()" onresize="windowOnresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id='divHead'>
        <div id="divMenu">
        </div>
        <table id="table_titulo_comentario" class="tb1">
            <tr>
                <td>
                    Titulo
                </td>
                <td style="width: 40%">
                    <script type="text/javascript">
                        campos_defs.add('titulo', { nro_campo_tipo: 104, enDB: false });
                    </script>
                </td>
                <td>
                    Comentario
                </td>
                <td style="width: 40%">
                    <script type="text/javascript">
                        campos_defs.add('comentario', { nro_campo_tipo: 104, enDB: false });
                    </script>
                </td>
            </tr>
        </table>
    </div>

    <div id='divCircuito'>
    <div id="divFirmas" style='overflow: auto'>
        <table id='tablaDocumentosFirmas' style="vertical-align:top;height: auto;width:auto" class='tb1'>
            <tr>
                <td>
                </td>
            </tr>
        </table>
    </div>

    <div id='divFoot'>
        <iframe onload="hiddenIframeLoad()" id="hiddenIframe" name="hiddenIframe" style="display: none">
        </iframe>


        <form target="hiddenIframe" name="formArchivos" id="formArchivos" method="post" enctype="multipart/form-data"
        action="">

        <input type="file" id="file" name="file" style="width: 100%" />
        </form>
    

        <div id="divGuardar">
        </div>


    </div>
    </div>

    <iframe id="ifrResponse" name="ifrResponse" style="visibility: hidden;" width="100%"></iframe>
</body>
</html>
