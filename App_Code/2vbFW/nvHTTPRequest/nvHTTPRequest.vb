Imports System.IO
Imports System.Net
Imports System.Net.Http
Imports System.Net.Security
Imports System.Security.Cryptography.X509Certificates
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Public Class nvHttpUtiles

    Public Enum nvSecurityProtocolType
        Ssl3 = 48
        Tls = 192
        Tls11 = 768
        Tls12 = 3072
        Tls13 = 12288
    End Enum

    Public Shared https_defaultSecurityProtocol As System.Net.SecurityProtocolType = nvSecurityProtocolType.Ssl3 Or nvSecurityProtocolType.Tls Or nvSecurityProtocolType.Tls11 Or nvSecurityProtocolType.Tls12 'Or nvSecurityProtocolType.Tls13


    Public Shared Function GenericValidateCertificate(ByVal sender As Object, ByVal certificate As X509Certificate, ByVal chain As X509Chain, ByVal sslPolicyErrors As SslPolicyErrors) As Boolean
        Dim validationResult As Boolean
        validationResult = True
        '
        ' policy code here ...
        '
        Return validationResult
    End Function

    'Public Shared Function GetServerCertificate(ByVal url As String) As X509Certificate2
    '    Dim certificate As X509Certificate2 = Nothing
    '    Dim httpClientHandler = New HttpClientHandler With {
    '        .ServerCertificateCustomValidationCallback = Function(__, cert, ___, ____)
    '                                                         certificate = cert
    '                                                         Return True
    '                                                     End Function
    '    }
    '    Dim httpClient = New HttpClient(httpClientHandler)
    '    httpClient.SendAsync(New HttpRequestMessage(HttpMethod.Head, url))
    '    Return certificate
    'End Function

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

    Public Shared Function requestHTTP(ByVal strURL As String,
                                       ByVal params() As nvHTTPRequest.tParam,
                                       Optional ByVal USERNAME As String = "",
                                       Optional ByVal PSSWD As String = "",
                                       Optional ByVal Domain As String = "",
                                       Optional ByVal multi_part As Boolean = False,
                                       Optional ByRef Cookies As String = "",
                                       Optional timeout As Integer = 0,
                                       Optional userAgent As String = "",
                                       Optional ClientCertificate As List(Of X509Certificate2) = Nothing,
                                       Optional ContentType As String = "application/x-www-form-urlencoded",
                                       Optional Body As String = "",
                                       Optional Method As String = "POST") As HttpWebResponse

        Dim Response As HttpWebResponse = Nothing
        Dim paramHeader As String
        Dim paramHeaderBytes As Byte()
        Dim tmpStream As Stream = New MemoryStream()
        Dim buffer As Byte() = {}
        Dim bytesRead As Integer = 0

        If params Is Nothing Then
            ReDim params(-1)
        End If

        ' Identificar si tiene archivos
        ' Si los tiene se manda como multipart/form-data
        Dim i As Integer
        Dim tiene_archivos As Boolean = False

        For i = 0 To UBound(params)
            If params(i).type = typeParam.param_file Then
                tiene_archivos = True
                Exit For
            End If
        Next

        If tiene_archivos OrElse multi_part = True Then
            '****************************************************************
            ' Genarar POST multipart - Cuando tiene archivos
            '****************************************************************
            ' Generar limite 
            Dim limite As String = "----------" & DateTime.Now.Ticks.ToString("x")

            ' Recorre cada parametro generando el arreglo de bytes y esribiendolos en el buffer de salida
            For i = 0 To UBound(params)
                If params(i).type = typeParam.param_string Then
                    ' Si es una cadena
                    paramHeader = "--" & limite & vbNewLine
                    paramHeader &= "Content-Disposition: form-data; name=""" & params(i).name & """"
                    paramHeader &= vbNewLine & vbNewLine
                    paramHeader &= params(i).value 'Valor del parametro
                    paramHeader &= vbNewLine

                    ' Escribir la cabecera del parametro en el tmpStream
                    paramHeaderBytes = Encoding.GetEncoding(1252).GetBytes(paramHeader)
                    tmpStream.Write(paramHeaderBytes, 0, paramHeaderBytes.Length)

                ElseIf params(i).type = typeParam.param_file Then
                    ' Si es un archivo
                    ' Construir cabecera del parametro archivo
                    paramHeader = "--" & limite & vbNewLine
                    paramHeader &= "Content-Disposition: form-data; name=""" & params(i).name & """; filename=""" & Path.GetFileName(params(i).value) & """"
                    paramHeader &= vbNewLine & "Content-Type: application/octet-stream"
                    paramHeader &= vbNewLine & vbNewLine

                    ' Escribir la cabecera del parametro en el tmpStream
                    paramHeaderBytes = Encoding.GetEncoding(1252).GetBytes(paramHeader)
                    tmpStream.Write(paramHeaderBytes, 0, paramHeaderBytes.Length)

                    ' Cargar en tmpStream el archivo
                    If params(i).value <> "" Then
                        If IsNothing(params(i).stream) Then
                            ' Si no viene el stream recuperarlo desde el archivo
                            Try
                                Dim fileStream As FileStream = New FileStream(params(i).value, FileMode.Open, FileAccess.Read)
                                ReDim buffer(fileStream.Length - 1)
                                bytesRead = fileStream.Read(buffer, 0, buffer.Length)

                                ' Escribir el contenido del archivo
                                While bytesRead <> 0
                                    tmpStream.Write(buffer, 0, bytesRead)
                                    bytesRead = fileStream.Read(buffer, 0, buffer.Length)
                                End While

                                fileStream.Close()
                            Catch ex As Exception
                            End Try
                        Else
                            ' Si viene el stream cargarlo desde el mismo
                            ReDim buffer(4000)
                            bytesRead = params(i).stream.Read(buffer, 0, buffer.Length)

                            ' Escribir el contenido del archivo
                            While bytesRead <> 0
                                tmpStream.Write(buffer, 0, bytesRead)
                                bytesRead = params(i).stream.Read(buffer, 0, buffer.Length)
                            End While

                            ' Agregamos 2 bytes al fin
                            'paramFootBytes = Encoding.GetEncoding(1252).GetBytes(vbNewLine & vbNewLine)
                            'tmpStream.Write(paramFootBytes, 0, paramFootBytes.Length)
                            params(i).stream.Close()
                        End If
                    End If
                End If
            Next

            ' Crear el string de límite final como matriz de bytes
            Dim limiteBytes As Byte() = Encoding.UTF8.GetBytes(vbNewLine & "--" & limite & vbNewLine)

            ' Escriba el límite final
            tmpStream.Write(limiteBytes, 0, limiteBytes.Length)
            ' ContentType junto con el limite
            ContentType = "multipart/form-data; boundary=" & limite
        Else
            '****************************************************************
            ' Genarar POST simpple - Cuando no tiene archivos
            '****************************************************************
            For i = 0 To UBound(params)
                If params(i).name <> "" AndAlso params(i).type <> typeParam.param_headers Then
                    ' Si es una cadena
                    paramHeader = params(i).name & "=" & HttpUtility.UrlEncode(params(i).value) & "&"
                    paramHeaderBytes = Encoding.GetEncoding(1252).GetBytes(paramHeader)
                    tmpStream.Write(paramHeaderBytes, 0, paramHeaderBytes.Length)
                End If
            Next
        End If

        If Body <> "" Then
            Dim bytesBody As Byte() = Encoding.GetEncoding(65001).GetBytes(Body)
            tmpStream.Write(bytesBody, 0, bytesBody.Length)
        End If

        '********************************************************************
        ' Enviar el request
        '********************************************************************
        ' Cuando utiliza protocolo HTTPS necesita una función de validación de certificado
        ' Para este caso la función devuelve siempre true
        ' Si no es HTTPS no utiliza esta funcion
        If ServicePointManager.ServerCertificateValidationCallback Is Nothing Then ServicePointManager.ServerCertificateValidationCallback = New RemoteCertificateValidationCallback(AddressOf nvHttpUtiles.GenericValidateCertificate)

        ' Definir protocolos de seguridad (ssl3, tls1, tls1.1, tls1.2)
        ServicePointManager.SecurityProtocol = https_defaultSecurityProtocol

        ' Crear el objeto HttpWebRequest con la url de la pagina destino
        Dim HttpWRequest As HttpWebRequest = HttpWebRequest.Create(strURL)

        ' Cargar propiedades de la cabecera
        For i = 0 To UBound(params)
            If params(i).type = typeParam.param_headers AndAlso params(i).value <> "" Then
                HttpWRequest.Headers.Add(params(i).name, params(i).value)
            End If
        Next

        If timeout > 0 Then
            HttpWRequest.Timeout = timeout
        Else
            HttpWRequest.Timeout = System.Threading.Timeout.Infinite
        End If

        If Not ClientCertificate Is Nothing Then
            For Each cert In ClientCertificate
                HttpWRequest.ClientCertificates.Add(cert)
            Next
        End If

        ' Si se le pasaron credenciales las asigna, sino utilizar las credenciales actuales
        If USERNAME <> "" Then
            Dim creds As New Net.NetworkCredential(USERNAME, PSSWD, Domain)
            HttpWRequest.Credentials = creds
        Else
            HttpWRequest.Credentials = CredentialCache.DefaultCredentials
        End If

        ' Habilitar el buffer, no se envían los datos hasta la sentencia GetResponse()
        HttpWRequest.AllowWriteStreamBuffering = True

        ' Asignar el contentType
        HttpWRequest.ContentType = ContentType

        If Cookies <> "" Then
            HttpWRequest.Headers.Add(HttpRequestHeader.Cookie, Cookies)
        End If

        If userAgent <> "" Then
            HttpWRequest.UserAgent = userAgent
        End If

        HttpWRequest.Method = Method

        Try
            ' Solo se puede escribir en el stream del request con POST
            If (Method.ToUpper() = "POST" OrElse Method.ToUpper() = "PUT") AndAlso (params.Count >= 0 OrElse Body <> "") Then
                tmpStream.Seek(0, SeekOrigin.Begin)
                ' Asignar el largo del stream (Content-Length)
                HttpWRequest.ContentLength = tmpStream.Length
                Dim stream As Stream = HttpWRequest.GetRequestStream()
                ReDim buffer(tmpStream.Length - 1)
                bytesRead = tmpStream.Read(buffer, 0, buffer.Length)

                While bytesRead <> 0
                    stream.Write(buffer, 0, bytesRead)
                    bytesRead = tmpStream.Read(buffer, 0, buffer.Length)
                End While
            End If

            Response = HttpWRequest.GetResponse()
        Catch ex As System.Net.WebException
            If Not ex.Response Is Nothing Then
                Response = CType(ex.Response, HttpWebResponse)
            End If

            Try
                Dim logTrack As String = nvLog.getNewLogTrack()
                nvLog.addEvent("lg_nv_request_open", logTrack & ";;" & ex.Message.ToString & ";" & strURL)
            Catch ex0 As Exception
            End Try

            Try
                tmpStream.Close()
            Catch ex1 As Exception
            End Try
        Catch ex As ProtocolViolationException
            Response = Nothing
        Catch ex As ObjectDisposedException
            Response = Nothing
        Catch ex As InvalidOperationException
            Response = Nothing
        Catch ex As NotSupportedException
            Response = Nothing
        Catch ex As Exception
            Response = Nothing
        End Try

        Return Response
    End Function



    Public Enum typeParam
        param_string = 0
        param_file = 1
        param_headers = 2
    End Enum

End Class

<Microsoft.VisualBasic.ComClass()> Public Class nvHTTPRequest

    Private _url As String
    Private params As Dictionary(Of String, nvRequestParam)
    Private _UID As String = ""
    Private _PWD As String = ""
    Private _Domain As String = ""
    Private _multi_part As Boolean = False
    Private _response As HttpWebResponse
    Private _response_error As HttpWebResponse
    Private _close_response As Boolean = False
    Private _responseXML As String
    Private _time_out As Integer = -1
    Private _cookies As String = ""
    Private _PersistSession As Boolean = True
    Private _ClientCertificate As New List(Of X509Certificate2)
    Private _Body As String = ""
    Private _ContentType As String = ""
    Private _Method As String = "POST"

    Public Sub New()
        MyBase.New()
        inicializarVariables()
    End Sub

    <System.Runtime.InteropServices.DispId(1)> Public Sub inicializarVariables()
        Me.params = New Dictionary(Of String, nvRequestParam)
    End Sub

    Private _params() As tParam
    Private _thread_request As Threading.Thread

    Public Event onResponse(ByRef refer As nvHTTPRequest)


    <System.Runtime.InteropServices.DispId(2)> Public Function param_add(ByVal nombre As String, ByVal valor As String, Optional ByVal tipo As typeParam = typeParam.param_string) As Object
        ' tipoparam: 1 para file, 0 para string, por defecto 0
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

        Dim reqParam As New nvRequestParam
        reqParam.nombre = nombre
        reqParam.tipo = tipo
        reqParam.valor = valor
        params.Add(nombre, reqParam)

        Return reqParam
    End Function



    <System.Runtime.InteropServices.DispId(3)> Public Sub param_remove(ByVal nombre As String)
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

    Public Function getResponseXML(Optional ByVal charsetName As String = "iso-8859-1") As System.Xml.XmlDocument
        Try
            Dim response As System.Net.HttpWebResponse = Me.getResponse()
            Dim reader As System.IO.StreamReader = New System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding(charsetName))
            Dim strXML As String = reader.ReadToEnd()
            Dim XML As New System.Xml.XmlDocument
            XML.LoadXml(strXML)

            Return XML
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Public Function getResponseText(Optional ByVal charsetName As String = "iso-8859-1") As String
        Try
            Dim response As System.Net.HttpWebResponse = Me.getResponse()
            Dim reader As System.IO.StreamReader = New System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding(charsetName))
            Dim strXML As String = reader.ReadToEnd()

            Return strXML
        Catch ex As Exception
            Return Nothing
        End Try
    End Function


    <System.Runtime.InteropServices.DispId(4)> Public Function getResponse(Optional ByVal close_response As Boolean = False) As HttpWebResponse
        _close_response = close_response
        Dim response As HttpWebResponse = Nothing

        Try
            response = nvHttpUtiles.requestHTTP(Me._url, Me._params, Me._UID, Me._PWD, Me._Domain, Me._multi_part, _cookies, Me._time_out, Body:=Me._Body, ContentType:=Me._ContentType, Method:=Me._Method, ClientCertificate:=Me.ClientCertificate)
        Catch ex As Exception
        End Try

        Me._response = Nothing
        Me._response_error = Nothing
        Me._responseXML = Nothing

        If Not response Is Nothing Then
            If response.StatusCode = 200 Then
                Me._response = response
                _header_analizar(response)
                Me._response_error = Nothing

                Try
                    'Stop
                    'Dim reader As StreamReader = New StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding("iso-8859-1"))
                    'Me._responseXML = reader.ReadToEnd()
                Catch
                End Try
            Else
                Me._response = Nothing
                Me._response_error = response
                Me._responseXML = ""
            End If
        End If

        RaiseEvent onResponse(Me)

        If _close_response Then
            If Not Me._response Is Nothing Then
                Me._response.Close()
            End If

            If Not Me._response_error Is Nothing Then
                Me._response_error.Close()
            End If
        End If

        Return Me._response
    End Function

    <System.Runtime.InteropServices.DispId(5)> Public Sub sendRequest()
        Dim index As Integer
        Dim fileStream As FileStream
        Dim memStream As MemoryStream
        Dim bytesRead As Integer
        Dim buffer(4000) As Byte
        Dim param As tParam

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

    <System.Runtime.InteropServices.DispId(6)> Public Function ejecutando() As Boolean
        Return _thread_request.IsAlive
    End Function

    <System.Runtime.InteropServices.DispId(7)> Public Property url() As String
        Get
            Return Me._url
        End Get
        Set(ByVal value As String)
            Me._url = value
        End Set
    End Property

    <System.Runtime.InteropServices.DispId(8)> Public Property PWD() As String
        Get
            Return Me._PWD
        End Get
        Set(ByVal value As String)
            Me._PWD = value
        End Set
    End Property
    <System.Runtime.InteropServices.DispId(9)> Public Property UID() As String
        Get
            Return Me._UID
        End Get
        Set(ByVal value As String)
            Me._UID = value
        End Set
    End Property
    <System.Runtime.InteropServices.DispId(10)> Public Property Domain() As String
        Get
            Return Me._Domain
        End Get
        Set(ByVal value As String)
            Me._Domain = value
        End Set
    End Property

    <System.Runtime.InteropServices.DispId(11)> Public Property multi_part() As Boolean
        Get
            Return Me._multi_part
        End Get
        Set(ByVal value As Boolean)
            Me._multi_part = value
        End Set
    End Property
    <System.Runtime.InteropServices.DispId(12)> Public Property time_out() As Integer
        Get
            Return Me._time_out
        End Get
        Set(ByVal value As Integer)
            Me._time_out = value
        End Set
    End Property


    <System.Runtime.InteropServices.DispId(14)> Public Sub param_clear()
        params.Clear()
        ReDim Preserve _params(0)

    End Sub

    <System.Runtime.InteropServices.DispId(13)> Public ReadOnly Property response_error() As HttpWebResponse
        Get
            Return _response_error
        End Get

    End Property

    <System.Runtime.InteropServices.DispId(14)> Public ReadOnly Property response() As HttpWebResponse
        Get
            Return _response
        End Get

    End Property

    <System.Runtime.InteropServices.DispId(15)> Public Property responseXML() As String
        Get
            Return _responseXML
        End Get
        Set(ByVal value As String)
            Me._responseXML = value
        End Set
    End Property

    <System.Runtime.InteropServices.DispId(16)> Public Property cookies() As String
        Get
            Return Me._cookies
        End Get
        Set(ByVal value As String)
            Me._cookies = value
        End Set
    End Property

    <System.Runtime.InteropServices.DispId(17)> Public Property persistSession() As Boolean
        Get
            Return Me._PersistSession
        End Get
        Set(ByVal value As Boolean)
            Me._PersistSession = value
        End Set
    End Property

    <System.Runtime.InteropServices.DispId(18)> Public Property Body() As String
        Get
            Return Me._Body
        End Get
        Set(ByVal value As String)
            Me._Body = value
        End Set
    End Property
    <System.Runtime.InteropServices.DispId(18)> Public Property Method() As String
        Get
            Return Me._Method
        End Get
        Set(ByVal value As String)
            Me._Method = value
        End Set
    End Property

    <System.Runtime.InteropServices.DispId(19)> Public Property ContentType() As String
        Get
            Return Me._ContentType
        End Get
        Set(ByVal value As String)
            Me._ContentType = value
        End Set
    End Property

    Public Property ClientCertificate() As List(Of X509Certificate2)
        Get
            Return _ClientCertificate
        End Get
        Set(value As List(Of X509Certificate2))
            _ClientCertificate = value
        End Set
    End Property


    <System.Runtime.InteropServices.DispId(18)> Public Sub param_removeAll()
        Dim i As Integer
        For i = LBound(_params) To UBound(_params)
            params.Remove(_params(UBound(_params)).name)
            ReDim Preserve _params(UBound(_params) - 1)
        Next

    End Sub
    Private Sub _header_analizar(ByVal re As HttpWebResponse)
        'If re.Headers.AllKeys.Contains("Set-Cookie") And _cookies = "" Then
        'f _cookies = "" Then
        If _PersistSession Then
            _cookies += ";" & re.Headers("Set-Cookie")
        End If
        'End If
    End Sub


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
End Class

Public Enum typeParam
    param_string = 0
    param_file = 1
    param_headers = 2
End Enum

Public Class nvRequestParam
    Public nombre As String
    Public tipo As typeParam
    Public valor As String

    Public Sub New()
    End Sub
End Class




