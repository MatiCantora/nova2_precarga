Option Explicit On

Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW

    Public Class nvUtiles
        Public Sub New()

        End Sub

        ''' <summary>
        '''Recupera el valor de request, ya sea que viene
        '''de POST, GET o SmartUpload 
        '''</summary>
        ''' <param name="nombres">Array de nombres posibles</param>
        ''' <param name="def">Valor por defecto</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function obtenerValor(ByVal nombres As String(), Optional ByVal def As Object = Nothing) As String
            Dim res As Object = def
            For i = 0 To nombres.Count - 1
                res = obtenerValor(nombres(i), Nothing)
                If Not res Is Nothing Then
                    Return res
                End If
            Next
            Return def
        End Function


        ''' <summary>
        '''Recupera el valor de request, ya sea que viene
        '''de POST, GET o SmartUpload 
        '''</summary>
        ''' <param name="nombre"></param>
        ''' <param name="def">Valor por defecto</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function obtenerValor(ByVal nombre As String, Optional ByVal def As Object = Nothing) As String
            Dim res As Object = def
            'Revisar form
            Try
                If Not HttpContext.Current.Request.Form(nombre) Is Nothing Then
                    res = HttpContext.Current.Request.Form(nombre)
                    Return res
                End If
            Catch ex As Exception
            End Try
            'Revisar querystring
            Try
                If Not HttpContext.Current.Request.QueryString(nombre) Is Nothing Then
                    res = HttpContext.Current.Request.QueryString(nombre)
                    Return res
                End If
            Catch ex As Exception
            End Try

            ' Recuperar el formulario desde un JSON en el Body
            ProcessBodyJSON()

            Try
                Dim formBody As Dictionary(Of String, Object) = HttpContext.Current.Items("_request_body_stream")
                If Not formBody Is Nothing AndAlso formBody.ContainsKey(nombre.ToLower) Then
                    res = formBody(nombre.ToLower)
                    Return res
                End If
            Catch ex As Exception
            End Try


            Return res
        End Function

        Public Shared Function obtenerValorType(ByVal nombres As String(), Optional ByVal def As Object = Nothing, Optional DataType As nvConvertUtiles.DataTypes = nvConvertUtiles.DataTypes.unknown) As String
            Dim res = obtenerValor(nombres, def)
            Return nvConvertUtiles.ObjectToDataType(res, DataType)
        End Function

        Public Shared Function obtenerValorType(ByVal nombre As String, Optional ByVal def As Object = Nothing, Optional DataType As nvConvertUtiles.DataTypes = nvConvertUtiles.DataTypes.unknown) As String
            Dim res = obtenerValor(nombre, def)
            Return nvConvertUtiles.ObjectToDataType(res, DataType)
        End Function

        Public Shared Function obtenerBodyJSON() As Object

            ProcessBodyJSON()

            Return HttpContext.Current.Items("_request_body_stream")

        End Function

        Private Shared Sub ProcessBodyJSON()
            Dim _request_JSON_body_Process As Boolean = IIf(HttpContext.Current.Items("_request_JSON_body_Process") Is Nothing, False, HttpContext.Current.Items("_request_JSON_body_Process"))
            If Not _request_JSON_body_Process Then
                Try
                    HttpContext.Current.Items("_request_JSON_body_Process") = True
                    'Verificar contentType
                    Dim ContentTypeisJSON As Boolean = HttpContext.Current.Request.ContentType.ToLower.indexOf("application/json") >= 0

                    'utilizo el charset que viene definido en la cabecera ejemplo de la definición: Content-Type=application/json; charset=utf-8
                    Dim currentEncoding As Encoding = HttpContext.Current.Request.ContentEncoding

                    'Leer los primeros 10 caracteres y revisar si empieza con "{"
                    Dim io As System.IO.Stream = HttpContext.Current.Request.InputStream
                    Dim EmpiezaJSON As Boolean = False
                    If io.Length >= 3 Then

                        io.Position = 0
                        Dim buffer10(10) As Byte
                        io.Read(buffer10, 0, buffer10.Length)
                        Dim fragmentoJSON As String = Trim(currentEncoding.GetString(buffer10))
                        EmpiezaJSON = If(fragmentoJSON(0) = "{" Or fragmentoJSON(0) = "[", True, False)

                    End If

                    io.Position = 0
                    'Si el contentType  lo define o empeza con "{" se debe procesar el JSON
                    If ContentTypeisJSON Or EmpiezaJSON Then
                        io.Position = 0
                        Dim buffer(io.Length - 1) As Byte
                        io.Read(buffer, 0, buffer.Length)
                        Dim strJSON As String = currentEncoding.GetString(buffer)
                        If strJSON <> String.Empty Then
                            Try

                                ' strJSON = strJSON.Replace("}]", "}")
                                ' strJSON = strJSON.Replace("[{", "{")

                                Dim formBody As Dictionary(Of String, Object) = nvConvertUtiles.JSONToDictionary(strJSON)
                                HttpContext.Current.Items("_request_body_stream") = formBody

                            Catch ex As Exception
                                Dim err As New tError()
                                err.parse_error_script(ex)
                                err.titulo = "Error en lectura de parámetros."
                                err.mensaje = "JSON mal formado."
                                err.debug_src = "nvUtiles::ObtenerValor"
                                err.debug_desc = "Encoding BodyName=" & currentEncoding.BodyName & vbCrLf &
                                "Encoding Windows CodePage=" & currentEncoding.WindowsCodePage & vbCrLf &
                                "strJSON=" & strJSON &
                                "Stream Length=" & io.Length & " bytes" & vbCrLf &
                                "ContentTypeisJSON=" & ContentTypeisJSON & vbCrLf &
                                "EmpiezaJSON=" & EmpiezaJSON
                                err.response()
                            End Try
                        End If
                    End If
                Catch ex As Exception

                End Try
            End If

        End Sub


        ''' <summary>
        ''' Define un nuevo par clave valor dentro de los items en el flujo del cuerpo de la Request, definidos por nombre y valor respectivamente.
        ''' </summary>
        ''' <param name="nombre">Nombre de la nueva clave</param>
        ''' <param name="valor">Valor a asignar para la nueva clave</param>
        Public Shared Sub definirValor(ByVal nombre As String, ByVal valor As Object)
            'Procesar el body
            ProcessBodyJSON()

            Dim json_params As Dictionary(Of String, Object) = HttpContext.Current.Items("_request_body_stream") ' Tomamos una referencia al contenido del contexto actual
            ' Si no está seteado, arrancamos uno nuevo
            If json_params Is Nothing Then
                json_params = New Dictionary(Of String, Object)(StringComparer.CurrentCultureIgnoreCase) ' IMPORTANTE: aclarar la opción de StringComparer
                ' Variables obligatorias
                HttpContext.Current.Items("_request_body_stream") = json_params
            End If

            ' Asignar el valor propiamente pasado
            json_params(nombre) = valor
        End Sub


        ''' <summary>
        ''' Remueve un valor dentro de los items en el flujo del cuerpo de la Request.
        ''' </summary>
        ''' <param name="nombre">Nombre de la nueva clave</param>
        Public Shared Sub removerValor(ByVal nombre As String)
            Dim json_params As Dictionary(Of String, Object) = HttpContext.Current.Items("_request_body_stream") ' Tomamos una referencia al contenido del contexto actual

            ' Si no está seteado, arrancamos uno nuevo
            If json_params Is Nothing Then
                json_params = New Dictionary(Of String, Object)(StringComparer.CurrentCultureIgnoreCase) ' IMPORTANTE: aclarar la opción de StringComparer
                ' Variables obligatorias
                HttpContext.Current.Items("_request_body_stream_OK") = True
                HttpContext.Current.Items("_request_body_stream") = json_params
            Else
                HttpContext.Current.Items.Remove(nombre)
            End If

            'Try
            '    HttpContext.Current.Request.QueryString.Remove(nombre)
            'Catch ex As Exception

            'End Try
            If HttpContext.Current.Items("_request_body_stream").ContainsKey(nombre) Then
                HttpContext.Current.Items("_request_body_stream").remove(nombre)
            End If

            'Try
            '    HttpContext.Current.Request.Form.Remove(nombre)
            'Catch ex As Exception

            'End Try

        End Sub


        ''' <summary>
        ''' Determina si el valor suminstrado en "value" es distinto de DBNull y devueve su valor. Caso
        ''' contrario retorna el valor definido en "def".
        ''' </summary>
        ''' <param name="value">Valor a analizar</param>
        ''' <param name="def">Valor por defecto si "value" falla</param>
        ''' <returns></returns>
        Public Shared Function isNUll(ByVal value As Object, Optional ByVal def As Object = "") As Object
            If IsDBNull(value) Then
                Return def
            Else
                Return value
            End If
        End Function


        ''' <summary>
        ''' Determina si el valor pasado en "value" es DBNull, Nothing o está vacío. Si es así retorna el valor 
        ''' por defecto suministrado en "def".
        ''' </summary>
        ''' <param name="value">Valor a analizar</param>
        ''' <param name="def">Valor por defecto si "value" falla</param>
        ''' <returns></returns>
        Public Shared Function isNUllorEmpty(ByVal value As Object, Optional ByVal def As Object = "") As Object
            If IsDBNull(value) Then Return def

            If value Is Nothing Then Return def

            If value.GetType().ToString = "System.DateTime" Then
                If value = New Date(0) Then
                    Return def
                End If
            End If
            Try
                If Trim(value) = "" Then
                    Return def
                End If
            Catch ex As Exception
            End Try
            Return value

        End Function


        ''' <summary>
        ''' Obtiene el valor de un parámetro a partir de su identificador "id_param". Si falla o no está seteado se
        ''' retorna el valor por defecto "def".
        ''' </summary>
        ''' <param name="id_param">Identificador del parámetro</param>
        ''' <param name="def">Valor por defecto si el parámetros falla</param>
        ''' <returns></returns>
        Public Shared Function getParametroValor(ByVal id_param As String, Optional ByVal def As String = "") As String
            Dim valor As String = def
            Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute("SELECT DISTINCT isnull(valor,'') as valor, encriptar FROM verparametros WHERE id_param = '" & id_param & "'")

            If Not rs.EOF Then
                If rs.Fields("encriptar").Value Then
                    valor = If(rs.Fields("valor").Value = "", def, nvFW.nvSecurity.nvCrypto.EncBase64ToStr(rs.Fields("valor").Value))
                Else
                    valor = If(rs.Fields("valor").Value = "", def, rs.Fields("valor").Value)
                End If
            End If

            Return valor
        End Function


        Public Shared Function replaceParametroValor(Optional cn As String = "") As String
            If cn = "" Then
                Return ""
            End If

            Dim reg As Regex = New Regex("({%(\w*)%})")
            Dim mc As MatchCollection = reg.Matches(cn, RegexOptions.IgnoreCase)
            Dim m As Match

            If mc.Count > 0 Then
                For i = 0 To mc.Count - 1
                    m = mc(i)

                    Dim cadena As String = m.Groups(1).Value ' Ejemplo: {%sybase_user%}
                    Dim id_param As String = m.Groups(2).Value ' Ejemplo: sybase_user

                    If id_param <> "" Then
                        cn = cn.Replace(cadena, getParametroValor(id_param, cadena))
                    End If
                Next
            End If

            Return cn
        End Function


        Public Shared Function ADMGetParametroValor(id_param As String, Optional def As String = "") As String
            Dim valor As String = def
            Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBExecute("SELECT DISTINCT valor, encriptar FROM verparametros WHERE id_param = '" & id_param & "'")

            If Not rs.EOF Then
                If rs.Fields("encriptar").Value Then
                    valor = isNUll(nvFW.nvSecurity.nvCrypto.EncBase64ToStr(rs.Fields("valor").Value), def)
                Else
                    valor = isNUll(rs.Fields("valor").Value, def)
                End If
            End If

            Return valor
        End Function


        Public Shared Function ADMReplaceParametroValor(Optional cn As String = "") As String
            If cn = "" Then
                Return ""
            End If

            Dim reg As Regex = New Regex("({%(\w*)%})")
            Dim mc As MatchCollection = reg.Matches(cn, RegexOptions.IgnoreCase)
            Dim m As Match

            If mc.Count > 0 Then
                For i = 0 To mc.Count - 1
                    m = mc(i)

                    Dim cadena As String = m.Groups(1).Value ' Ejemplo: {%sybase_user%}
                    Dim id_param As String = m.Groups(2).Value ' Ejemplo: sybase_user

                    If id_param <> "" Then
                        cn = cn.Replace(cadena, ADMGetParametroValor(id_param, cadena))
                    End If
                Next
            End If

            Return cn
        End Function


        Public Shared Function GetWebEntryAssembly() As Reflection.Assembly
            If System.Web.HttpContext.Current Is Nothing OrElse System.Web.HttpContext.Current.ApplicationInstance Is Nothing Then Return Nothing

            Dim assm As Reflection.Assembly = Nothing
            Dim tipo As Type = System.Web.HttpContext.Current.ApplicationInstance.GetType()

            While Not tipo Is Nothing AndAlso tipo.Namespace = "ASP"
                tipo = tipo.BaseType
            End While

            If Not tipo Is Nothing Then assm = tipo.Assembly

            Return assm

        End Function


        ''' <summary>
        ''' Transforma los valores de la Request actual en un trsParam de la forma Clave-Valor, excepto para los Files, que se
        ''' organizan bajo la estructura Files > file_{position} > [FileName, ContentType, ContentLength, InputBytes], donde position
        ''' es la posición del archivo dentro de la Request procesada.
        ''' 
        ''' Se analiza la Request en el siguiente orden: Files, Query String, Form y JSON Body.
        ''' </summary>
        ''' <returns>Retorna un trsParam con todo el contenido de la Request.</returns>
        Public Shared Function RequestTotrsParam() As trsParam

            'Procesar el body
            ProcessBodyJSON()

            Dim _request As HttpRequest = HttpContext.Current.Request   ' Entrada: Request actual
            Dim param_request As New trsParam                           ' Salida: trsParam con todos los valores de la Request

            ' 1) Files
            If _request.Files.Count > 0 Then
                'Dim files As New List(Of trsParam)
                Dim files As New trsParam
                Dim file As trsParam

                For index As Integer = 0 To _request.Files.Count - 1
                    Dim buffer(0 To _request.Files(index).ContentLength - 1) As Byte
                    _request.Files(index).InputStream.Read(buffer, 0, _request.Files(index).ContentLength)

                    file = New trsParam
                    file("FileName") = _request.Files(index).FileName
                    file("ContentType") = _request.Files(index).ContentType
                    file("ContentLength") = _request.Files(index).ContentLength
                    file("InputBytes") = buffer

                    'files.Add(file)
                    files("file_" & index) = file
                Next

                If files.Count > 0 Then param_request("Files") = files
            End If

            ' 2) Query String
            For Each key In _request.QueryString.Keys
                param_request(key) = _request.QueryString.GetValues(key)(0)
            Next

            ' 3) Form
            For Each key In _request.Form.Keys
                param_request(key) = _request.Form.GetValues(key)(0)
            Next

            ' 4) JSON Body
            Dim _request_body_stream As Dictionary(Of String, Object) = HttpContext.Current.Items("_request_body_stream")

            If Not _request_body_stream Is Nothing Then
                For Each key In _request_body_stream.Keys
                    param_request(key) = _request_body_stream(key)
                Next
            End If

            Return param_request
        End Function

        Public Shared Function joinRSWithRequestToTrsParam(rs As ADODB.Recordset, trs As trsParam) As tError
            Dim err As New tError
            For i = 0 To rs.Fields.Count - 1
                Dim fieldName As String = rs.Fields(i).Name
                If Not rs.EOF Then
                    trs(fieldName) = obtenerValor(fieldName, nvUtiles.isNUll(rs.Fields(i).Value, Nothing))
                Else
                    trs(fieldName) = obtenerValor(fieldName, Nothing)
                End If

                If Not nvConvertUtiles.ValidateObjectAdoType(trs(fieldName), rs.Fields(i).Type) Then

                    err.numError = 1003
                    err.titulo = "Error en la ejecución de edición"
                    err.mensaje = "Error en la signación de parámetros. El campo '" & fieldName & "' no se corresponde con el tipo d datos '" & rs.Fields(i).Type.ToString() & "'"
                    err.debug_src = "nvUtiles::joinRSWithRequestToTrsParam"

                End If
            Next
            Return err
        End Function

        Public Shared Function joinRSWithTrsParam(rsJoin As ADODB.Recordset, trsJoin As trsParam, trsResultado As trsParam) As tError

            Dim err As New tError
            For i = 0 To rsJoin.Fields.Count - 1
                Dim fieldName As String = rsJoin.Fields(i).Name
                If Not rsJoin.EOF Then
                    trsResultado(fieldName) = trsJoin(fieldName, nvUtiles.isNUll(rsJoin.Fields(i).Value, Nothing))
                Else
                    trsResultado(fieldName) = trsJoin(fieldName, Nothing)
                End If

                If Not nvConvertUtiles.ValidateObjectAdoType(trsResultado(fieldName), rsJoin.Fields(i).Type) Then
                    err.numError = 1003
                    err.titulo = "Error en la ejecución de edición"
                    err.mensaje = "Error en la signación de parámetros. El campo '" & fieldName & "' no se corresponde con el tipo d datos '" & rsJoin.Fields(i).Type.ToString() & "'"
                    err.debug_src = "nvUtiles::joinRSWithRequestToTrsParam"
                End If
            Next
            Return err
        End Function
        
        Public Shared Function GetXmlDocumentFromJsonString(ByVal json As String, Optional ByVal _encoding As String = "utf-8") As System.Xml.XmlDocument
            If json Is Nothing OrElse json = "" Then Return Nothing

            Dim jsonBytes As Byte() = Encoding.GetEncoding(_encoding).GetBytes(json)
            Dim xmlReader As System.Xml.XmlReader = System.Runtime.Serialization.Json.JsonReaderWriterFactory.CreateJsonReader(jsonBytes, New System.Xml.XmlDictionaryReaderQuotas)
            Dim xmlDocument As New System.Xml.XmlDocument
            xmlDocument.Load(xmlReader)

            Return xmlDocument
        End Function

    End Class

End Namespace
