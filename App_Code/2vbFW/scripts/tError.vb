﻿Imports System.Web
Imports System.Xml
Imports ADODB
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW
    Public Class tError
        Dim _Response As HttpResponse

        Public numError As Integer = 0
        Public titulo As String = ""
        Public mensaje As String = ""
        Public debug_src As String = ""
        Public debug_desc As String = ""
        Public pvSalida_tipo As nvenumSalidaTipo = nvenumSalidaTipo.adjunto

        Public params As New trsParam

        Public Sub New()
            'HttpContext.Current.Items("operador") = nvApp.getInstance().operador.login
            'params = New trsParam()
        End Sub

        Public Sub New(rs As ADODB.Recordset)
            'params = New trsParam()
            Me.parse_rs(rs)
        End Sub

        Public Sub New(ex As Exception, Optional titulo As String = "", Optional mensaje As String = "", Optional debug_src As String = "", Optional debug_desc As String = "")
            'params = New trsParam()
            Me.parse_error_script(ex)
            Me.titulo = titulo
            Me.mensaje = mensaje
            Me.debug_src = debug_src
            Me.debug_desc = debug_desc & Me.debug_desc
        End Sub

        Public Sub New(numError As Integer, titulo As String, mensaje As String, Optional ByRef params As trsParam = Nothing)
            Me.numError = numError
            Me.titulo = titulo
            Me.mensaje = mensaje
            If params IsNot Nothing Then Me.params = params

        End Sub
        Public Sub clear()
            numError = 0
            titulo = ""
            mensaje = ""
            debug_src = ""
            debug_desc = ""

            params = New trsParam()
        End Sub

        Public Property salida_tipo As String
            Set(value As String)
                Try
                    pvSalida_tipo = [Enum].Parse(GetType(nvenumSalidaTipo), value, True)
                Catch ex As Exception

                End Try

            End Set
            Get
                Return [Enum].GetName(GetType(nvenumSalidaTipo), pvSalida_tipo)
            End Get
        End Property

        Public Property comentario As String
            Set(value As String)
                mensaje = value
            End Set
            Get
                Return mensaje
            End Get
        End Property

        Public Overloads Sub loadXML(ByVal strXML As String)
            params = New trsParam()
            Dim oXML As New System.Xml.XmlDocument
            Try
                oXML.LoadXml(strXML)
                numError = oXML.SelectSingleNode("/error_mensajes/error_mensaje").Attributes("numError").Value
                Me.titulo = oXML.SelectSingleNode("/error_mensajes/error_mensaje/titulo").InnerText
                Me.mensaje = oXML.SelectSingleNode("/error_mensajes/error_mensaje/mensaje").InnerText
                Dim nparams As System.Xml.XmlNodeList = oXML.SelectNodes("/error_mensajes/error_mensaje/params")
                '' Dim node As Xml.XmlNode
                For i = 0 To nparams.Count - 1
                    For j = 0 To nparams.Item(i).ChildNodes.Count - 1
                        If nparams.Item(i).ChildNodes(j).InnerXml <> "" Then
                            Me.params.Add(nparams.Item(i).ChildNodes(j).Name, nparams.Item(i).ChildNodes(j).InnerXml)
                        Else
                            Me.params.Add(nparams.Item(i).ChildNodes(j).Name, nparams.Item(i).ChildNodes(j).InnerText)
                        End If

                    Next
                Next
            Catch ex As Exception
                numError = -1
                Me.titulo = "Error al cargar el tError"
                Me.mensaje = ex.Message
            End Try
        End Sub
        Public Overloads Sub loadXML(ByVal response As System.Net.WebResponse)

            Dim reader As System.IO.StreamReader = New System.IO.StreamReader(response.GetResponseStream(), nvConvertUtiles.currentEncoding)
            Dim responseXML As String = reader.ReadToEnd()
            Me.loadXML(responseXML)

        End Sub
        Public Sub response(Optional ByVal error_format As tError.nvenum_error_format = nvenum_error_format.no_definido)
            Dim _Response = HttpContext.Current.Response
            If _Response.Buffer Then _Response.Clear()

            Dim pvError_format As nvenum_error_format = nvenum_error_format.xml
            Try
                Dim str_error_format As String = obtenerValor({"error_format", "ef"}, [Enum].GetName(GetType(tError.nvenum_error_format), 1))
                pvError_format = [Enum].Parse(GetType(tError.nvenum_error_format), str_error_format, True)
            Catch ex As Exception
            End Try

            Dim charset As String = nvConvertUtiles.currentEncoding.BodyName
            Try
                charset = obtenerValor({"error_charset", "ec"}, nvConvertUtiles.currentEncoding.BodyName)
            Catch ex As Exception
            End Try

            If error_format <> nvenum_error_format.no_definido Then
                pvError_format = error_format
            End If

            Select Case pvError_format
                Case nvenum_error_format.xml
                    Dim strXML = Me.get_error_xml
                    nvXMLUtiles.responseXML(_Response, strXML)

                    Dim buffer() As Byte = nvConvertUtiles.currentEncoding.GetBytes(strXML)
                    saveAPIResponse(buffer)
                Case nvenum_error_format.json
                    Dim strJson As String = get_error_json()
                    _Response.Expires = -1
                    _Response.ContentType = "application/json"
                    _Response.Charset = charset
                    Dim buffer() As Byte = System.Text.Encoding.GetEncoding(charset).GetBytes(strJson)
                    saveAPIResponse(buffer)
                    _Response.BinaryWrite(buffer)
                    '_Response.End()
                Case nvenum_error_format.html
                    Dim strHTML As String = get_error_html()
                    _Response.Expires = -1
                    _Response.ContentType = "text/html"
                    _Response.Charset = charset
                    Dim buffer() As Byte = System.Text.Encoding.GetEncoding(charset).GetBytes(strHTML)
                    saveAPIResponse(buffer)
                    _Response.BinaryWrite(buffer)
                    '_Response.End()

            End Select
            'HttpContext.Current.ApplicationInstance.CompleteRequest()

            '"_Response.End()" dispara un error de "Subproceso anulado" eso no se puede corregir.
            'Las correcciones que sugiere microsoft es reemplazarlo por HttpContext.Current.ApplicationInstance.CompleteRequest(), pero eso no funciona porque el códio continúa,
            'no aborta la ejecución.
            'Igualmente por mas que dispara ese error no afecta a otros procesos y funciona bien.
            'Lo único que no hay que haces es disparar el tError.response() dentro de un try.
            HttpContext.Current.ApplicationInstance.CompleteRequest()
            _Response.End()


            '_Response.Expires = 0
            ''_Response.Charset = "UTF-8" '"ISO-8859-1"
            '_Response.Charset = "ISO-8859-1"
            'Dim buffer() As Byte = Encoding.GetEncoding("iso-8859-1").GetBytes(strXML)
            ''_Response.Write(strXML)
            '_Response.BinaryWrite(buffer)
            '_Response.End()
            ''HttpContext.Current.ApplicationInstance.CompleteRequest()

        End Sub

        Public Sub saveAPIResponse(response_binary As Byte())

            If HttpContext.Current.Items("hasApi") = True AndAlso HttpContext.Current.Items("save_request") = True Then

                Dim id_api_log = HttpContext.Current.Items("id_API_log")

                Dim strSQL_api_log As String = "UPDATE API_log SET response_binary = ?, response_momento = GETDATE(), api_url = '" & HttpContext.Current.Request.Url.AbsoluteUri & "' WHERE id_api_log = " & id_api_log
                ' cuando se hace un abandon el nvapp se rompe
                'Dim strSQL_api_log As String = "UPDATE API_log SET response_binary = ?, response_momento = GETDATE(), api_url = '" & HttpContext.Current.Request.Url.AbsoluteUri & "', [login]= '" & nvApp.getInstance().operador.login & "' WHERE id_api_log = " & id_api_log

                Dim cmdAPILog As New nvDBUtiles.tnvDBCommand(strSQL_api_log, db_type:=emunDBType.db_admin)

                ' Parametro 0: "response_binary"
                cmdAPILog.Parameters(0).Type = ADODB.DataTypeEnum.adLongVarBinary
                cmdAPILog.Parameters(0).Size = response_binary.Count
                cmdAPILog.Parameters(0).Value = response_binary

                cmdAPILog.Execute()

            End If

        End Sub

        Public Function get_error_html() As String

            Dim strHTML As String = "<html xmlns='http://www.w3.org/1999/xhtml'><head><link href='../../fw/css/base.css' type='text/css' rel='stylesheet' />" & vbCrLf & "<title>Mostrar Error</title>" & vbCrLf
            ''strHTML = strHTML & "<script type='text/javascript'>" & vbCrLf & "var error_mensajes = '" & Replace(Replace(Me.get_error_xml(), "'", "\'"), "\", "\\") & "'" & vbCrLf
            'strHTML = strHTML & "document.error_mensajes = error_mensajes</script>" & vbCrLf
            strHTML = strHTML & "</head>"
            strHTML = strHTML & "<body><table class='tb1'><tr class='tbLabel0'><td>"
            strHTML = strHTML & Me.numError & " : " & Me.titulo
            strHTML = strHTML & "</td></tr><tr><td>" & Me.mensaje & "</td></tr></table><table class='tb1'><tr class='tbLabel0'><td>Error</td></tr>"
            If nvServer.showDebugErrors Then
                strHTML = strHTML & "<tr><td>" & Me.debug_src & "</td></tr><tr><td><textarea id='debug_desc' name='debug_desc' style='width: 100%' rows='10' size='5'>" + Me.debug_desc + "</textarea></td></tr>"
            Else
                Dim xmlDebugError As String = "<debug_src><![CDATA[" & Me.debug_src & "]]></debug_src><debug_desc><![CDATA[" & Me.debug_desc & "]]></debug_desc>"
                strHTML = strHTML & "<tr><td><textarea id='debug' name='debug' style='width: 100%' rows='10' size='5'>" + Convert.ToBase64String(Text.Encoding.UTF8.GetBytes(xmlDebugError)) + "</textarea></td></tr>"
            End If
            strHTML = strHTML & "</table>"
            strHTML = strHTML & "<textarea style='display: none' id='error_xml' name='error_xml' style='width: 100%' rows='10' size='5'>" & Me.get_error_xml() & "</textarea>"
            strHTML = strHTML & "</body></html>"
            Return strHTML

        End Function
        Public Function get_error_json() As String
            Dim sep As String = vbCrLf
            Dim strJson As String = "{" & sep
            strJson += """numError"":" & Me.numError & sep
            strJson += ",""titulo"":" & nvConvertUtiles.objectToScript(Me.titulo, nvConvertUtiles.nvJS_format.js_json) & sep
            strJson += ",""mensaje"":" & nvConvertUtiles.objectToScript(Me.mensaje, nvConvertUtiles.nvJS_format.js_json) & sep
            If nvServer.showDebugErrors Then
                strJson += ",""debug_src"":" & nvConvertUtiles.objectToScript(Me.debug_src, nvConvertUtiles.nvJS_format.js_json) & sep
                strJson += ",""debug_desc"":" & nvConvertUtiles.objectToScript(Me.debug_desc, nvConvertUtiles.nvJS_format.js_json) & sep
            End If

            strJson += ",""params"": " & sep & params.toJSON(nvConvertUtiles.nvJS_format.js_json) & sep
            strJson += "}"


            Return strJson

        End Function
        Public Function get_error_xml() As String
            'Dim i As Integer

            'Dim error_xml As String = "<?xml version='1.0' encoding='ISO-8859-1'?><error_mensajes><error_mensaje numError='" & Me.numError & "'><titulo>" & Me.titulo & "</titulo><mensaje><![CDATA[" & Me.mensaje & "]]></mensaje><comentario><![CDATA[" & Me.comentario & "]]></comentario>"
            ''La información de debug no se envía al usuario, se debería enviar un código de error para poder rastrear el mismo
            ''O tirarlo codificado en base64 para poder copiarlo y verlo
            'Dim xmlDebugError As String = "<debug_src><![CDATA[" & Me.debug_src & "]]></debug_src><debug_desc><![CDATA[" & Me.debug_desc & "]]></debug_desc>"
            'If nvServer.showDebugErrors Then
            '    error_xml += xmlDebugError
            'Else
            '    error_xml += "<debug><![CDATA[" & Convert.ToBase64String(Text.Encoding.UTF8.GetBytes(xmlDebugError)) & "]]></debug>"
            'End If
            'error_xml += "<params>"
            'For i = 0 To Me.params.Keys.Count - 1
            '    error_xml = error_xml & "<" & Me.params.Keys(i) & "><![CDATA[" & Me.params(Me.params.Keys(i)) & "]]></" & Me.params.Keys(i) & ">"
            'Next
            'error_xml = error_xml & "</params></error_mensaje></error_mensajes>"
            'Return error_xml
            Dim i As Integer
            Dim ms As New System.IO.MemoryStream
            Dim settings As New XmlWriterSettings()
            settings.Indent = False
            settings.NewLineOnAttributes = True
            settings.OmitXmlDeclaration = False
            settings.Encoding = nvConvertUtiles.currentEncoding

            Dim writer As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(ms, settings)
            writer.WriteStartDocument()
            writer.WriteStartElement("error_mensajes")
            writer.WriteStartElement("error_mensaje")
            writer.WriteAttributeString("numError", Me.numError)
            writer.WriteElementString("titulo", Me.titulo)
            writer.WriteElementString("mensaje", Me.mensaje)
            If nvServer.showDebugErrors Then
                writer.WriteElementString("debug_src", Me.debug_src)
                writer.WriteElementString("debug_desc", Me.debug_desc)
            Else
                writer.WriteElementString("debug_src", Convert.ToBase64String(Text.Encoding.UTF8.GetBytes(Me.debug_src)))
                writer.WriteElementString("debug_desc", Convert.ToBase64String(Text.Encoding.UTF8.GetBytes(Me.debug_desc)))
            End If

            Dim strXMLParams As String = Me.params.toXML()
            writer.WriteRaw(strXMLParams)

            writer.WriteEndElement() 'error_mensaje
            writer.WriteEndElement() 'error_mensajes
            writer.WriteEndDocument()
            writer.Close()
            ms.Position = 0
            Dim bytes(ms.Length - 1) As Byte
            ms.Read(bytes, 0, ms.Length)
            ms.Close()

            Dim strXMLs As String = nvConvertUtiles.currentEncoding.GetString(bytes)
            Return strXMLs

            Dim error_xml As String = "<?xml version='1.0' encoding='ISO-8859-1'?><error_mensajes><error_mensaje numError='" & Me.numError & "'><titulo>" & Me.titulo & "</titulo><mensaje><![CDATA[" & Me.mensaje & "]]></mensaje>"
            'La información de debug no se envía al usuario, se debería enviar un código de error para poder rastrear el mismo
            'O tirarlo codificado en base64 para poder copiarlo y verlo
            Dim xmlDebugError As String = "<debug_src><![CDATA[" & Me.debug_src & "]]></debug_src><debug_desc><![CDATA[" & Me.debug_desc & "]]></debug_desc>"
            If nvServer.showDebugErrors Then
                error_xml += xmlDebugError
            Else
                error_xml += "<debug><![CDATA[" & Convert.ToBase64String(Text.Encoding.UTF8.GetBytes(xmlDebugError)) & "]]></debug>"
            End If
            error_xml += "<params>"
            For i = 0 To Me.params.Keys.Count - 1
                error_xml = error_xml & "<" & Me.params.Keys(i) & "><![CDATA[" & Me.params(Me.params.Keys(i)).Replace("]]>", "]]&gt;") & "]]></" & Me.params.Keys(i) & ">"
            Next
            error_xml = error_xml & "</params></error_mensaje></error_mensajes>"
            Return error_xml
        End Function


        Public Function parse_rs(rs As ADODB.Recordset)
            Me.numError = rs.Fields("numerror").Value
            Me.titulo = rs.Fields("titulo").Value
            Me.mensaje = rs.Fields("mensaje").Value
            Me.debug_desc = rs.Fields("debug_desc").Value
            Me.debug_src = rs.Fields("debug_src").Value
            Return Me.debug_desc
        End Function

        Public Function parse_error_xml(pe As XmlException) As String
            Me.numError = 100
            Me.titulo = "Error XML"
            Me.mensaje = pe.Message
            Me.mensaje = ""
            Try
                Me.debug_desc = " - url: '" & pe.SourceUri & "' - reason: '" & pe.Message & "' - line: " & pe.LineNumber & " linepos: " & pe.LinePosition
            Catch ex As Exception

            End Try


            Return (Me.debug_desc)
        End Function

        Public Function parse_error_script(err As Exception) As String
            Me.numError = 100
            Me.titulo = "Error Script"
            Me.mensaje = ""

            If Not err.InnerException Is Nothing Then
                Me.debug_desc = err.Message & ";" & err.InnerException.ToString()
            Else
                Me.debug_desc = err.Message & vbCrLf & err.StackTrace
            End If

            If err.Data.Contains("numError") Then Me.numError = err.Data("numError")
            If err.Data.Contains("titulo") Then Me.titulo = err.Data("titulo")
            If err.Data.Contains("mensaje") Then Me.mensaje = err.Data("mensaje")
            If err.Data.Contains("debug_src") Then Me.debug_src &= If(Me.debug_src <> "", vbCrLf, "") & err.Data("debug_src")
            If err.Data.Contains("debug_desc") Then Me.debug_desc &= If(Me.debug_desc <> "", vbCrLf, "") & err.Data("debug_desc")

            Return Me.debug_desc
        End Function


        Public Function Cargar_msj_error(ByVal numError As Integer) As String
            Dim error_xml As String
            Me.numError = numError
            Try
                Dim rs As Recordset = nvDBUtiles.DBExecute("Select * from error_mensajes where numError = " & numError)
                Me.titulo = rs.Fields("titulo").Value
                Me.mensaje = rs.Fields("mensaje").Value
                'Me.mensaje = rs.Fields("comentario").Value
                error_xml = "<?xml version='1.0' encoding='iso-8859-1'?><error_mensajes><error_mensaje numError='" & numError & "'><titulo>" & Me.titulo & "</titulo><mensaje>" & Me.mensaje & "</mensaje></error_mensaje></error_mensajes>"

            Catch e As Exception
                Me.titulo = "Error desconocido."
                Me.mensaje = "Error desconocido."
                Me.mensaje = ""
            End Try

            Return get_error_xml()
        End Function


        Public Function mostrar_error() As Object
            Dim _Response = HttpContext.Current.Response
            Select Case pvSalida_tipo
                Case nvenumSalidaTipo.estado
                    Me.response()
                Case Else
                    Me.response(nvenum_error_format.html)
            End Select
            Return Me
        End Function

        Public Sub system_reg(Optional severidad As Diagnostics.EventLogEntryType = Diagnostics.EventLogEntryType.Error, Optional noLog As Boolean = False)
            Dim strparams As String = nvConvertUtiles.StringTonvLogParam(Me.titulo) & "," & nvConvertUtiles.StringTonvLogParam(Me.mensaje) & "," & nvConvertUtiles.StringTonvLogParam(Me.debug_src) & "," & nvConvertUtiles.StringTonvLogParam(Me.debug_desc) & "," & nvConvertUtiles.StringTonvLogParam(Me.params.toXML())
            Dim machine As String = "."
            Dim source As String = "NOVA"
            Dim log As String = "Application"
            System.Diagnostics.Debug.Print("tError::system_reg::Log eventos de error de systema." & strparams)
            Try
                nvLog.EventWindows_addEvent(machine, source, log, strparams, severidad)
            Catch ex As Exception
            End Try
            If Not noLog Then nvLog.addEvent("tError_system", strparams)
        End Sub

        Public Enum nvenum_error_format
            no_definido = -1
            xml = 1
            html = 2
            json = 3
        End Enum
    End Class

    Public Enum nvenumSalidaTipo As Integer
        adjunto = 0
        estado = 1
        [return] = 2
        returnWithBinary = 3
        no_definido = 1
    End Enum

End Namespace
