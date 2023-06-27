Imports System.IO
Imports System.Net
Imports System.Net.Security
Imports System
Imports System.Web
Imports System.Security.Cryptography.X509Certificates
Imports System.Text
Imports System.Collections


Namespace nvFW.servicios.Robots
    Public Class nvHttpUtilesRobot
        Public Enum nvSecurityProtocolType
            Ssl3 = 48
            Tls = 192
            Tls11 = 768
            Tls12 = 3072
        End Enum
        Public Shared https_defaultSecurityProtocol As System.Net.SecurityProtocolType = 192 Or 768 Or 3072
        Public Shared Function getMaxSecurityProtocol(url As String) As System.Net.SecurityProtocolType
            Dim spt As nvSecurityProtocolType
            Dim max_spt As nvSecurityProtocolType = 0
            For Each value As System.Net.SecurityProtocolType In spt.GetType().GetEnumValues()
                Try
                    ServicePointManager.SecurityProtocol = value
                    Dim httprequest As HttpWebRequest
                    httprequest = HttpWebRequest.Create(url)
                    httprequest.AllowAutoRedirect = False
                    httprequest.Timeout = 1000
                    httprequest.GetResponse()
                    If value > max_spt Then max_spt = value
                Catch ex As Exception
                End Try
            Next
            Return max_spt
        End Function

        Public Shared Function getMaxSecurityProtocol(url() As String) As System.Net.SecurityProtocolType
            Dim spt As nvSecurityProtocolType
            Dim max_spt(url.Length - 1) As nvSecurityProtocolType
            For i = 0 To url.Length - 1
                max_spt(i) = 0
                max_spt(i) = getMaxSecurityProtocol(url(i))
            Next

            Dim min_spt As nvSecurityProtocolType = max_spt(0)
            For i = 1 To url.Length - 1
                If max_spt(i) < min_spt Then min_spt = max_spt(i)
            Next
            Return min_spt
        End Function

        Public Shared Function requestHTTP(ByVal strURL As String, ByVal params() As tParam, Optional ByVal USERNAME As String = "",
                               Optional ByVal PSSWD As String = "",
                               Optional ByVal Domain As String = "", Optional ByVal multi_part As Boolean = False,
                               Optional ByRef Cookies As String = "",
                               Optional timeout As Integer = System.Threading.Timeout.Infinite, Optional timeoutRequestSend As Integer = System.Threading.Timeout.Infinite,
                               Optional ByRef error_message As String = "",
                               Optional ByRef error_code As Integer = 0, Optional Method As String = "POST", Optional headers As List(Of nvHttpUtilesRobot.tHeader) = Nothing, Optional ByRef CookieContainer As Net.CookieContainer = Nothing, Optional ByVal AllowAutoRedirect As Boolean = True) As HttpWebResponse

            Dim Response As HttpWebResponse = Nothing
            Dim paramHeader As String
            Dim paramHeaderBytes As Byte()
            Dim paramFootBytes As Byte()
            Dim tmpStream As Stream = New MemoryStream()
            Dim buffer As Byte() = {}
            Dim bytesRead As Integer = 0
            Dim ContentType As String

            If params Is Nothing Then
                ReDim params(-1)
            End If
            Dim i As Integer

            'Si los tiene se manda como multipart-postdata

            Dim tiene_archivos As Boolean = False
            For i = 0 To UBound(params)
                If params(i).type = typeParam.param_file Then
                    tiene_archivos = True
                    Exit For
                End If
            Next

            If tiene_archivos Or multi_part = True Then
                '****************************************************************
                'Genarar POST miltipart - Cuando tiene archivos
                '****************************************************************
                'Generar limite 
                Dim limite As String = "----------" & DateTime.Now.Ticks.ToString("x")
                'Recorre cada parametro generando el arreglo de bytes y esribiendolos en el buffer de salida
                For i = 0 To UBound(params)
                    If params(i).type = typeParam.param_string Then
                        Try
                            'Si es una cadena
                            paramHeader = "--" & limite & vbNewLine
                            paramHeader += "Content-Disposition: form-data; name=""" & params(i).name & """"
                            paramHeader += vbNewLine & vbNewLine
                            paramHeader += params(i).value 'Valor del parametro
                            paramHeader += vbNewLine
                            'Escribir la cabecera del parametro en el tmpStream
                            paramHeaderBytes = Encoding.GetEncoding(1252).GetBytes(paramHeader)
                            tmpStream.Write(paramHeaderBytes, 0, paramHeaderBytes.Length)
                        Catch ex As Exception
                            error_code = -12
                            error_message = ex.Message
                            tmpStream.Close()
                            Return Nothing
                        End Try
                    Else
                        Try
                            'Si es un archivo
                            'Construir cabecera del parametro archivo
                            paramHeader = "--" & limite & vbNewLine
                            paramHeader += "Content-Disposition: form-data; name=""" & params(i).name & """; filename=""" & Path.GetFileName(params(i).value) & """"
                            paramHeader += vbNewLine & "Content-Type: application/octet-stream"
                            paramHeader += vbNewLine & vbNewLine

                            ''Escribir la cabecera del parametro en el tmpStream
                            paramHeaderBytes = Encoding.GetEncoding(1252).GetBytes(paramHeader)
                            tmpStream.Write(paramHeaderBytes, 0, paramHeaderBytes.Length)

                        Catch ex As Exception
                            error_code = -13 'Error no critico, es solo para capturar y ver que hacer a futuro
                            error_message = ex.Message
                            tmpStream.Close()
                            Return Nothing
                        End Try

                        'cargar en tmpStream el archivo
                        If params(i).value <> "" Then
                            If IsNothing(params(i).stream) Then 'Si no viene el stream recuperarlo desde el archivo
                                Try
                                    Dim fileStream As FileStream = New FileStream(params(i).value, FileMode.Open, FileAccess.Read)
                                    ReDim buffer(fileStream.Length - 1)
                                    bytesRead = fileStream.Read(buffer, 0, buffer.Length)
                                    'Escribir el contenido del archivo
                                    While bytesRead <> 0
                                        tmpStream.Write(buffer, 0, bytesRead)
                                        bytesRead = fileStream.Read(buffer, 0, buffer.Length)
                                    End While
                                    fileStream.Close()
                                Catch ex As Exception
                                    error_code = -10  'Error no critico , es solo para capturar y ver que hacer a futuro
                                    error_message = ex.Message
                                    tmpStream.Close()
                                    Return Nothing
                                End Try
                            Else 'Si viene el stream cargarlo desde el mismo
                                Try
                                    ReDim buffer(4000)
                                    'Dim memStream As FileStream = params(i).stream
                                    bytesRead = params(i).stream.Read(buffer, 0, buffer.Length)
                                    'Escribir el contenido del archivo
                                    While bytesRead <> 0
                                        tmpStream.Write(buffer, 0, bytesRead)
                                        bytesRead = params(i).stream.Read(buffer, 0, buffer.Length)
                                    End While

                                    'Agregamos 2 bytes al fin
                                    paramFootBytes = Encoding.GetEncoding(1252).GetBytes(vbNewLine & vbNewLine)
                                    tmpStream.Write(paramFootBytes, 0, paramFootBytes.Length)

                                    params(i).stream.Close()
                                Catch ex As Exception
                                    error_code = -11  'Error no critico , es solo para capturar y ver que hacer a futuro
                                    error_message = ex.Message
                                    tmpStream.Close()
                                    Return Nothing
                                End Try
                            End If
                        End If
                    End If
                Next

                Try
                    'Crear el string de límite final como matriz de bytes
                    'Dim limiteBytes As Byte() = Encoding.UTF8.GetBytes(vbNewLine & "--" + limite + vbNewLine)
                    Dim limiteBytes As Byte() = Encoding.UTF8.GetBytes(vbNewLine + "--" + limite + vbNewLine)
                    'Escriba el límite final
                    tmpStream.Write(limiteBytes, 0, limiteBytes.Length)
                    'contentType junto con el limite

                    ContentType = "multipart/form-data; boundary=" & limite
                Catch ex As Exception
                    error_code = -15
                    error_message = ex.Message ' para ver a futuro
                    tmpStream.Close()
                    Return Nothing
                End Try
            Else
                '****************************************************************
                'Genarar POST simpple - Cuando no tiene archivos
                '****************************************************************
                Try
                    For i = 0 To UBound(params)
                        If params(i).name <> "" Then
                            'Si es una cadena
                            'paramHeader = params(i).name & "=" & System.Web.HttpUtility.UrlEncode(params(i).value) & "&"
                            'paramHeaderBytes = Encoding.GetEncoding(1252).GetBytes(paramHeader)
                            paramHeader = params(i).name & "=" & HttpUtility.UrlEncode(params(i).value) & "&"
                            paramHeaderBytes = Encoding.GetEncoding(1252).GetBytes(paramHeader)
                            tmpStream.Write(paramHeaderBytes, 0, paramHeaderBytes.Length)
                        End If
                    Next
                    ''ContentType = "application/x-www-form-urlencoded"



                Catch ex As Exception
                    error_code = -14
                    error_message = ex.Message 'error para ver a futuro
                    tmpStream.Close()
                    Return Nothing
                End Try
            End If

            Dim HttpWRequest As HttpWebRequest

            ServicePointManager.SecurityProtocol = https_defaultSecurityProtocol

            Try
                '********************************************************************
                'Enviar el request
                '********************************************************************
                'Cuando utiliza protocolo HTTPS necesita una función de validación de certificado
                'Para este caso la función devuelve siempre true
                'Si no es HTTPS no utiliza esta funcion
                ServicePointManager.ServerCertificateValidationCallback = New RemoteCertificateValidationCallback(AddressOf ValidateCertificate)
                'Crear el objeto HttpWebRequest con la url de la pagina destino
                HttpWRequest = HttpWebRequest.Create(strURL)
                HttpWRequest.Timeout = timeout

                HttpWRequest.AllowAutoRedirect = AllowAutoRedirect
                'Si se le pasaron credenciales las asigna, sino utilizar las credenciales actuales
                If (USERNAME <> "") Then
                    Dim creds As New Net.NetworkCredential(USERNAME, PSSWD, Domain)
                    HttpWRequest.Credentials = creds
                Else
                    HttpWRequest.Credentials = CredentialCache.DefaultCredentials
                End If

                'Habilitar el buffer, no se envían los datos hasta la sentencia GetResponse()
                'HttpWRequest.AllowWriteStreamBuffering = True
                ''If (Method = "GET") Then
                Dim cookieJar As CookieContainer
                If (CookieContainer Is Nothing) Then
                    cookieJar = New Net.CookieContainer()
                    CookieContainer = cookieJar
                End If
                HttpWRequest.CookieContainer = CookieContainer

                ''End If
                HttpWRequest.Method = Method




                If Not Cookies Is Nothing And Cookies <> "" Then
                    HttpWRequest.Headers.Add(HttpRequestHeader.Cookie, Cookies)
                End If

                HttpWRequest.UserAgent = ""
                If (headers IsNot Nothing) Then
                    For h = 0 To headers.Count - 1
                        If (headers(h).name.ToUpper = "REFERER") Then
                            HttpWRequest.Referer = headers(h).value
                        End If
                        If (headers(h).name.ToUpper = "USER-AGENT") Then
                            HttpWRequest.UserAgent = headers(h).value
                        End If
                        If (headers(h).name.ToUpper = "ACCEPT") Then
                            HttpWRequest.Accept = headers(h).value
                        End If

                        If (headers(h).name.ToUpper = "HOST") Then
                            HttpWRequest.Host = headers(h).value
                        End If
                        If (headers(h).name.ToUpper = "CONNECTION") Then
                            HttpWRequest.KeepAlive = IIf(headers(h).value.ToUpper = "KEEP-ALIVE", True, False)
                        End If
                        If (headers(h).name.ToUpper = "CONTENT-TYPE") Then
                            HttpWRequest.ContentType = headers(h).value
                        End If
                        If (headers(h).name.ToUpper = "TRANSFER-ENCODING") Then
                            HttpWRequest.SendChunked = True
                        End If
                        If (headers(h).name.ToUpper <> "CONTENT-TYPE" And headers(h).name.ToUpper <> "HOST" And headers(h).name.ToUpper <> "ACCEPT" And headers(h).name.ToUpper <> "USER-AGENT" And headers(h).name.ToUpper <> "REFERER" And headers(h).name.ToUpper <> "KEEP-ALIVE" And headers(h).name.ToUpper <> "CONNECTION" And headers(h).name.ToUpper <> "TRANSFER-ENCODING") Then
                            HttpWRequest.Headers.Add(headers(h).name, headers(h).value)
                        End If
                    Next
                End If




            Catch ex As Exception
                error_code = -16 ' error no critico para rastrar a futuro
                error_message = ex.Message
                tmpStream.Close()
                Return Nothing
            End Try
            Dim stream As Stream
            Try
                If (Method = "POST") Then
                    HttpWRequest.AllowWriteStreamBuffering = True
                    tmpStream.Seek(0, SeekOrigin.Begin)
                    'asignar el largo del stream
                    HttpWRequest.ContentLength = tmpStream.Length
                    stream = HttpWRequest.GetRequestStream()
                    'Ajustar timeout de envio
                    stream.WriteTimeout = timeoutRequestSend
                    tmpStream.CopyTo(stream)
                    tmpStream.Close()
                End If

                Response = HttpWRequest.GetResponse()


            Catch ex As System.Net.WebException
                'MsgBox(ex.Message)
                'Debug.Print(ex.Message)
                error_code = -1 'error grave
                error_message = ex.Message
                Try
                    tmpStream.Close()
                Catch ex1 As Exception
                End Try
                Try
                    stream.Close()
                Catch ex2 As Exception
                End Try

                Return Nothing
                'Logger.e("Error en utiles.requestHTTP3. ", ex, Nothing)
            End Try
            Return Response
        End Function





        Private Shared Function ValidateCertificate(ByVal sender As Object, ByVal certificate As X509Certificate, ByVal chain As X509Chain, ByVal sslPolicyErrors As SslPolicyErrors) As Boolean
            Dim validationResult As Boolean
            validationResult = True
            '
            ' policy code here ...
            '
            Return validationResult
        End Function

        Public Enum typeParam
            param_string = 0
            param_file = 1
        End Enum
        Public Enum post_encode
            multipart_form_data = 0
            application_x_www_form_urlencoded = 1
            text_plain = 2
        End Enum

        Public Structure tParam
            Dim name As String
            Dim value As String
            Dim type As typeParam
            Dim stream As MemoryStream
        End Structure

        Public Structure tHeader
            Dim name As String
            Dim value As String
        End Structure
        Public Structure tCookies
            Dim name As String
            Dim value As String
        End Structure
    End Class


    Public Class nvHTTPRequestRobot

        Private _url As String ''para consultas

        Public UID As String = ""
        Public PWD As String = ""
        Public Domain As String = ""
        Public multi_part As Boolean = False
        Public timeout As Integer = 10000   ''System.Threading.Timeout.Infinite
        Public timeoutRequestSend As Integer = System.Threading.Timeout.Infinite
        Public cookies As String
        Public headersResponse As Dictionary(Of String, String) = New Dictionary(Of String, String)
        Public AllowWriteStreamBuffering As Boolean = False
        Public UserAgent As String = ""
        Public Referer As String = ""

        Private params As Dictionary(Of String, nvRequestParam)
        Private _response As HttpWebResponse
        Private _lastError As tError
        Private _params() As nvHttpUtilesRobot.tParam
        Private _headers As List(Of nvHttpUtilesRobot.tHeader)
        Private _cookies As List(Of nvHttpUtilesRobot.tCookies)
        Private _thread_request As Threading.Thread
        Public Event onResponse(ByRef refer As HttpWebResponse)
        Public Event onError(ByRef refer As nvHTTPRequestRobot, ByRef err As tError)

        'Public Event Notify As EventHandler



        Public Sub New()
            MyBase.New()
            inicializarVariables()
        End Sub

        Public Sub inicializarVariables()
            Me.params = New Dictionary(Of String, nvRequestParam)
        End Sub


        Public ReadOnly Property lastError As tError
            Get
                Return _lastError
            End Get
        End Property

        Public Function param_add(ByVal nombre As String, ByVal valor As String, Optional ByVal tipo As Integer = False) As Object
            'tipoparam: 1 para file, 0 para string, por defecto 0
            'Dim tipo As typeParam
            'If (tipoParametro = True) Then
            '    tipo = typeParam.param_file
            'Else
            '    tipo = typeParam.param_string
            'End If

            Dim i As Integer
            If IsNothing(_params) Then
                ReDim Preserve _params(0)
                i = 0
            Else
                ReDim Preserve _params(UBound(_params) + 1)
                i = UBound(_params)
            End If
            _params(i).name = nombre
            _params(i).type = tipo
            _params(i).value = valor
            Dim a As New nvRequestParam
            a.nombre = nombre
            a.tipo = tipo
            a.valor = valor
            params.Add(nombre, a)
            Return a
        End Function




        Public Sub param_remove(ByVal nombre As String)
            Dim i As Integer
            Dim j As Integer
            For i = LBound(_params) To UBound(_params)
                If _params(i).name = nombre Then
                    For j = i To UBound(_params) - 1
                        _params(i) = _params(i + 1)
                    Next
                    ReDim Preserve _params(UBound(_params) - 1)
                End If
            Next
            params.Remove(nombre)
        End Sub

        Private Function tParamToString(p() As nvHttpUtilesRobot.tParam) As String
            Dim res As String = ""
            If p Is Nothing Then Return ""
            For i = LBound(p) To UBound(p)
                res += p(i).name & "=" & p(i).value & vbCrLf
            Next
            Return res
        End Function



        Public Function getResponse(Optional Method As String = "POST", Optional ByRef headers As List(Of nvHttpUtilesRobot.tHeader) = Nothing, Optional ByRef cookiesResponse As List(Of nvHttpUtilesRobot.tCookies) = Nothing, Optional ByRef cookiecontainer As CookieContainer = Nothing, Optional ByVal AllowAutoRedirect As Boolean = True) As HttpWebResponse
            Dim response As HttpWebResponse = Nothing
            Dim error_code As Integer
            Dim error_message As String = ""
            Dim stopWatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
            response = nvHttpUtilesRobot.requestHTTP(strURL:=Me.url, params:=Me._params, USERNAME:=Me.UID, PSSWD:=Me.PWD, Domain:=Me.Domain, multi_part:=Me.multi_part, Cookies:=cookies, timeout:=Me.timeout, timeoutRequestSend:=Me.timeoutRequestSend, error_message:=error_message, error_code:=error_code, Method:=Method, headers:=headers, CookieContainer:=cookiecontainer, AllowAutoRedirect:=AllowAutoRedirect)
            stopWatch.Stop()

            Dim ts As TimeSpan = stopWatch.Elapsed
            _lastError = New tError
            _lastError.numError = error_code
            _lastError.mensaje = error_message
            If (response Is Nothing And error_code <> 0) Then
                Dim mensaje As String = "Error getResponse. numError: " & error_code & " . DescError:" & error_message
                RaiseEvent onError(Me, _lastError)
                Return Nothing
            Else

                Dim HeaderCollection As WebHeaderCollection = response.Headers
                Me._headers = New List(Of nvHttpUtilesRobot.tHeader)
                For c = 0 To HeaderCollection.Count - 1
                    Dim nameheader As String = HeaderCollection.GetKey(c)
                    Dim valores() As String = HeaderCollection.GetValues(nameheader)
                    If (valores.Count > 0) Then
                        For v = 0 To valores.Count - 1
                            Dim head As New nvHttpUtilesRobot.tHeader
                            head.name = nameheader
                            head.value = valores(v)
                            Me._headers.Add(head)

                        Next
                    End If
                Next
                headers = Me._headers
                set_cookie(response)
                cookiesResponse = _cookies
                RaiseEvent onResponse(response)
            End If

            Return response
        End Function


        Public Sub sendRequest()
            Dim index As Integer
            Dim fileStream As FileStream
            Dim memStream As MemoryStream
            Dim bytesRead As Integer
            Dim buffer(4000) As Byte
            Dim param As nvHttpUtilesRobot.tParam
            'Carga los stream de archivos a la estructura de parámetros para poder elimiar la dependencia de los
            'archivos en el file system
            For index = 0 To Me._params.Length - 1
                param = Me._params(index)
                If (param.type = typeParam.param_file) Then
                    memStream = New MemoryStream
                    fileStream = New FileStream(param.value, FileMode.Open, FileAccess.Read)
                    bytesRead = fileStream.Read(buffer, 0, buffer.Length)
                    'Escribir el contenido del archivo
                    While bytesRead <> 0
                        memStream.Write(buffer, 0, bytesRead)
                        bytesRead = fileStream.Read(buffer, 0, buffer.Length)
                    End While
                    fileStream.Close()
                    memStream.Position = 0
                    Me._params(index).stream = memStream
                End If
            Next
            _thread_request = New Threading.Thread(AddressOf getResponse)
            _thread_request.Start()

        End Sub

        Public Function ejecutando() As Boolean
            Return _thread_request.IsAlive
        End Function

        Public Property url() As String
            Get
                Return Me._url
            End Get
            Set(ByVal value As String)
                Me._url = value
            End Set
        End Property

        Public Sub param_clear()
            params.Clear()
            ReDim Preserve _params(0)

        End Sub

        Public Function get_cookies()
            Return _cookies
        End Function

        Private Sub set_cookie(ByVal re As HttpWebResponse)
            _cookies = New List(Of nvHttpUtilesRobot.tCookies)
            Dim HeaderCollection As WebHeaderCollection = re.Headers
            Dim valores() As String = HeaderCollection.GetValues("Set-Cookie")
            If (valores IsNot Nothing) Then
                If (valores.Count > 0) Then
                    For v = 0 To valores.Count - 1
                        Dim head As New nvHttpUtilesRobot.tCookies
                        head.name = "Set-Cookie"
                        head.value = valores(v)
                        _cookies.Add(head)
                    Next
                End If

            End If

        End Sub





    End Class

    Public Enum typeParam
        param_string = 0
        param_file = 1
    End Enum

    Public Class nvRequestParam
        Public nombre As String
        Public tipo As typeParam
        Public valor As String

        Public Sub New()
        End Sub
    End Class
End Namespace

