Imports System.IO
Imports System.Net
Imports System.IO.Compression

Imports mshtml
'' OBSERVACION: Si no anda el proceso  (IHTMLDOCUMENT)html write (de la libreria mshtml), Desactivar "Internet explorar Enhanced security configuration" (IE ESC) y probar con eso
''https://www.ibm.com/support/pages/content-within-application-coming-website-listed-below-being-blocked-internet-explorer-enhanced-security-configuration-when-running-standard-reports

Namespace nvFW.servicios.Robots
    Public Class RobotEducacion
        Public responseString As String
        Public nro_vendedor As Integer = 0
        Private nro_operador As Integer = 0
        ''parametros comunes
        Private accept As String = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
        Private acceptencoding As String = "gzip, deflate, br"
        Private acceptlanguage As String = "es-419,es;q=0.9"
        Private useragent As String = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36"
        Private secfetchdest As String = "document"
        Private secfetchmode As String = "navigate"
        Private upgradeinsecurerequests As String = "1"
        Private connection As String = "keep-alive"
        Private _cookieContenedor As Net.CookieContainer
        Private Path_base As String = "D:\nova2\App_Data\localfile\directorio_archivos\roboteducacion\"
        Public cookies As String = ""
        Private last_nro_docu As Integer = 0
        Private last_nro_entidad As Integer = 0
        Public Sub New()
            Me.nro_operador = nvFW.nvApp.getInstance().operador.operador
            'Dim rsop = nvFW.nvDBUtiles.DBOpenRecordset("select nro_vendedor from vervendedores where nro_entidad in(select nro_entidad from verOperadores where operador=" & CStr(Me.nro_operador) & ")")
            'If Not (rsop.EOF) Then
            '    Me.nro_vendedor = rsop.Fields("nro_vendedor").Value
            'End If
        End Sub


        Public Property cookieContenedor() As Net.CookieContainer
            Get
                Return Me._cookieContenedor
            End Get
            Set(ByVal value As Net.CookieContainer)
                Me._cookieContenedor = value
            End Set
        End Property



        Function initheaders() As List(Of nvHttpUtilesRobot.tHeader)
            Dim headers As List(Of nvHttpUtilesRobot.tHeader) = New List(Of nvHttpUtilesRobot.tHeader)
            Dim h As New nvHttpUtilesRobot.tHeader
            h.name = "Accept"
            h.value = Me.accept
            headers.Add(h)
            h = New nvHttpUtilesRobot.tHeader
            h.name = "Accept-Encoding"
            h.value = Me.acceptencoding
            headers.Add(h)
            h = New nvHttpUtilesRobot.tHeader
            h.name = "Accept-Language"
            h.value = Me.acceptlanguage
            headers.Add(h)
            h = New nvHttpUtilesRobot.tHeader
            h.name = "User-Agent"
            h.value = Me.useragent
            headers.Add(h)
            h = New nvHttpUtilesRobot.tHeader
            h.name = "Sec-Fetch-Dest"
            h.value = Me.secfetchdest
            headers.Add(h)
            h = New nvHttpUtilesRobot.tHeader
            h.name = "Sec-Fetch-Mode"
            h.value = Me.secfetchmode
            headers.Add(h)

            h = New nvHttpUtilesRobot.tHeader
            h.name = "Upgrade-Insecure-Requests"
            h.value = Me.upgradeinsecurerequests
            headers.Add(h)
            h = New nvHttpUtilesRobot.tHeader
            h.name = "Connection"
            h.value = Me.connection
            headers.Add(h)

            Return headers
        End Function
        Private Function decoderesponse(ByVal response As HttpWebResponse) As String
            Dim responseString As String = ""
            Try
                Using WebResponse As HttpWebResponse = response
                    Dim responseStream As Stream = WebResponse.GetResponseStream()
                    If (WebResponse.ContentEncoding.ToLower().Contains("gzip")) Then
                        responseStream = New GZipStream(responseStream, CompressionMode.Decompress)
                    ElseIf (WebResponse.ContentEncoding.ToLower().Contains("deflate")) Then
                        responseStream = New DeflateStream(responseStream, CompressionMode.Decompress)
                    End If
                    Dim reader As StreamReader = New StreamReader(responseStream, System.Text.Encoding.Default)
                    responseString = reader.ReadToEnd()
                    responseStream.Close()
                End Using
            Catch ex As Exception

            End Try
            Return responseString

        End Function

        Public Function login(ByVal uuid As String, ByVal pwd As String) As tError
            Dim err As New tError
            Dim contenedorCookie As Net.CookieContainer
            Dim response As System.Net.HttpWebResponse = Nothing
            Dim nvRequestSteps = New nvHTTPRequestRobot
            Dim h As nvHttpUtilesRobot.tHeader
            Dim headers As List(Of nvHttpUtilesRobot.tHeader) = Me.initheaders()
            Dim cookiesResponse As List(Of nvHttpUtilesRobot.tCookies) = New List(Of nvHttpUtilesRobot.tCookies)
            Dim cookies As String = ""
            Dim AbsoluteUri As String = ""

            h = New nvHttpUtilesRobot.tHeader
            h.name = "Host"
            h.value = "login.abc.gob.ar"
            headers.Add(h)

            h = New nvHttpUtilesRobot.tHeader
            h.name = "Sec-Fetch-Site"
            h.value = "none"
            headers.Add(h)

            nvRequestSteps = New nvHTTPRequestRobot
            nvRequestSteps.url = "https://login.abc.gob.ar/nidp/idff/sso?id=ABC-Form&sid=0&option=credential&sid=0&target=https://misaplicaciones1.abc.gob.ar/Certificaciones/login.do"        '
            response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie)
            err = nvRequestSteps.lastError

            If (err.numError = 0) Then
                cookies = contenedorCookie.GetCookieHeader(New Uri("https://login.abc.gob.ar/nidp/idff/sso?sid=0&sid=0"))
                ''[PETICION 1]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "login.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = "https://login.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/nidp/idff/sso?id=ABC-Form&sid=0&option=credential&sid=0&target=https://misaplicaciones1.abc.gob.ar/Certificaciones/login.do"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-origin"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-User"
                h.value = "?1"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Content-Type"
                h.value = "application/x-www-form-urlencoded"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.param_add("Ecom_User_ID", uuid)
                nvRequestSteps.param_add("Ecom_Password", pwd)
                nvRequestSteps.param_add("option", "credential")
                cookiesResponse = Nothing
                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = "https://login.abc.gob.ar/nidp/app/login?sid=0&sid=0"
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie)
                err = nvRequestSteps.lastError
            End If

            If (err.numError = 0) Then
                ''[PETICION 2]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)


                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = "https://misaplicaciones1.abc.gob.ar/Certificaciones/login.do"

                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If


            If (err.numError = 0) Then
                ''[PETICION 3]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "menu.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)


                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = response.Headers.Get("Location")

                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If


            If (err.numError = 0) Then
                ''[PETICION 4]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "login.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = response.Headers.Get("Location")
                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If

            If (err.numError = 0) Then
                ''[PETICION 5]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "menu.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = response.Headers.Get("Location")
                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If


            If (err.numError = 0) Then
                ''[PETICION 6]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = response.Headers.Get("Location")
                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If


            If (err.numError = 0) Then
                ''[PETICION 7]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = response.Headers.Get("Location")
                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False) ''probar con AllowAutoRedirect:=False
                err = nvRequestSteps.lastError
            End If

            If (err.numError = 0) Then
                ''[PETICION 8]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "login.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = response.Headers.Get("Location")
                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)  ''probar con AllowAutoRedirect:=False
                err = nvRequestSteps.lastError
            End If


            If (err.numError = 0) Then

                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = "https://login.abc.gob.ar"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Content-Type"
                h.value = "application/x-www-form-urlencoded"
                headers.Add(h)
                Dim ini = Me.responseString.IndexOf("value=""")
                Dim token = Me.responseString.Substring(ini + 7, Me.responseString.IndexOf("""/>") - 1 - ini - 6)
                token = token.Replace("""", "")
                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.param_add("SAMLResponse", token)
                cookiesResponse = Nothing
                ''contenedorCookie = New Net.CookieContainer

                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = "https://misaplicaciones1.abc.gob.ar/Certificaciones/samlResponse.do"
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If

            If (err.numError = 0) Then
                ''[PETICION 10]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://login.abc.gob.ar/"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-site"
                headers.Add(h)


                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.url = response.Headers.Get("Location")
                response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie)
                err = nvRequestSteps.lastError
            End If


            If (err.numError = 0) Then
                cookies = ""
                Me.responseString = decoderesponse(response)
                Me._cookieContenedor = contenedorCookie
            End If
            err.params.Add("response", Me.responseString)
            Return err
        End Function

        Private Function consultar_certificados(ByVal nro_docu As Integer) As tError
            Dim response As System.Net.HttpWebResponse = Nothing
            Dim err As New tError
            Dim nvRequestSteps = New nvHTTPRequestRobot
            Dim h As nvHttpUtilesRobot.tHeader
            Dim headers As List(Of nvHttpUtilesRobot.tHeader) = Me.initheaders()
            Dim cookiesResponse As List(Of nvHttpUtilesRobot.tCookies) = New List(Of nvHttpUtilesRobot.tCookies)
            Dim contenedorCookie = Me._cookieContenedor
            If (contenedorCookie Is Nothing) Then
                err.numError = 1
                err.mensaje = "no ha iniciado sesion"
            End If


            If (err.numError = 0) Then
                ''[PETICION 1]
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://misaplicaciones1.abc.gob.ar/Certificaciones/selectCertOp.do"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = "https://misaplicaciones1.abc.gob.ar"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-origin"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)


                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-User"
                h.value = "?1"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Content-Type"
                h.value = "application/x-www-form-urlencoded"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.param_add("criterio", "documento")
                nvRequestSteps.param_add("number", CStr(nro_docu))
                nvRequestSteps.param_add("button", "Seguir")
                cookiesResponse = Nothing


                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = "https://misaplicaciones1.abc.gob.ar/Certificaciones/consultaCert.do"
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If
            If (err.numError = 0) Then
                Me.responseString = decoderesponse(response)
                If (Me.responseString.IndexOf("302 Found") >= 0) Then
                    err.numError = 3
                    err.mensaje = "error al consultar . Puede que no haya iniciado sesion"
                End If
            End If
            err.params.Add("response", Me.responseString)
            Return err
        End Function

        ''cuando se realiza el alta de certificados , se puede consultar previamente, el disponible en la tabla que arroje por nro_docu
        ''nro_entidad es la entidad que proviene de la tabla "educacion_ba_entidades"
        Public Function consultar_disponibles(ByVal nro_docu As Integer, ByVal nro_entidad As Integer, Optional ByRef lastcontenedorCookie As Net.CookieContainer = Nothing) As tError
            Dim response As System.Net.HttpWebResponse = Nothing
            Dim err As New tError
            Dim responseString As String = ""
            Me.responseString = ""
            Dim nvRequestSteps = New nvHTTPRequestRobot
            Dim h As nvHttpUtilesRobot.tHeader
            Dim headers As List(Of nvHttpUtilesRobot.tHeader) = Me.initheaders()
            Dim cookiesResponse As List(Of nvHttpUtilesRobot.tCookies) = New List(Of nvHttpUtilesRobot.tCookies)
            Dim contenedorCookie = Me._cookieContenedor
            If (contenedorCookie Is Nothing) Then
                err.numError = 1
                err.mensaje = "No ha iniciado sesion"
            End If


            If (err.numError = 0) Then
                ''[PETICION 1]
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://misaplicaciones1.abc.gob.ar/Certificaciones/selectOpGroup.do"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = "https://misaplicaciones1.abc.gob.ar"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-origin"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)


                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-User"
                h.value = "?1"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Content-Type"
                h.value = "application/x-www-form-urlencoded"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.param_add("operation", "Alta")
                nvRequestSteps.param_add("button", "Seguir")
                cookiesResponse = Nothing


                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = "https://misaplicaciones1.abc.gob.ar/Certificaciones/selectCertOp.do"
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If
            If (err.numError = 0) Then
                ''[PETICION 2]
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://misaplicaciones1.abc.gob.ar/Certificaciones/selectCertOp.do"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = "https://misaplicaciones1.abc.gob.ar"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-origin"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-User"
                h.value = "?1"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Content-Type"
                h.value = "application/x-www-form-urlencoded"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.param_add("docNumber", CStr(nro_docu))
                nvRequestSteps.param_add("selectedEntity", CStr(nro_entidad))
                nvRequestSteps.param_add("otraEntidad", "")
                nvRequestSteps.param_add("button", "Seguir")

                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = "https://misaplicaciones1.abc.gob.ar/Certificaciones/altaCert.do"
                nvRequestSteps.timeout = 50000
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError

            End If
            lastcontenedorCookie = contenedorCookie
            If (err.numError = 0) Then
                responseString = decoderesponse(response)
                Me.responseString = responseString
                If (responseString.IndexOf("302 Found") >= 0) Then
                    err.numError = 3
                    err.mensaje = "error al consultar . Puede que no haya iniciado sesion"
                ElseIf (responseString.IndexOf("registra un Certificado") >= 0) Then
                    err.numError = 5
                    err.mensaje = "Informacion no disponible. Registra un certificado presentado en el mes en curso para esta entidad"
                ElseIf (responseString.IndexOf("SERVICIOS DEL AGENTE") < 0) Then
                    err.numError = 4
                    err.mensaje = "no se encuentra informacion del agente"
                End If
            End If
            If (err.numError = 0) Then
                Me._cookieContenedor = contenedorCookie
            End If
            err.params.Add("response", responseString)
            Return err
        End Function

        ''previo el login nro_docu int, nro_entidad int,nro_item int
        Public Function obtener_certificado(ByVal nro_docu As Integer, ByVal nro_entidad As Integer, ByVal nro_item As Integer, Optional ByRef lastcontenedorCookie As Net.CookieContainer = Nothing) As tError
            Me.last_nro_docu = nro_docu
            Me.last_nro_entidad = nro_entidad
            Dim err As tError = consultar_disponibles(nro_docu, nro_entidad, lastcontenedorCookie)
            If (err.numError = 0) Then
                err = obtener_certificado(nro_item)
            End If
            Return err
        End Function

        ''previo el login nro_docu int, nro_entidad int,nro_item 0 primera fila del html recuperador por consultas disponibles
        Public Function obtener_certificado(ByVal nro_docu As Integer, ByVal nro_entidad As Integer, ByVal nro_item As Integer, Optional ByRef err As tError = Nothing) As Stream
            Me.last_nro_docu = nro_docu
            Me.last_nro_entidad = nro_entidad
            err = consultar_disponibles(nro_docu, nro_docu, Nothing)
            Dim binario As Stream = Nothing
            If (err.numError = 0) Then
                binario = obtener_certificado_binario(nro_item, err)
            End If
            Return binario
        End Function

        ''nro_item, es la fila del html donde esta el certificado
        ''aca el numero de certificado va a depender del html devuelto en la funcion consultar_certificados()
        Private Function obtener_certificado(ByVal nro_item As Integer) As tError
            Dim err As New tError
            Dim pathtmpfilename As String = ""
            Dim ext As String = ".pdf"
            Dim streamfile As Stream = obtener_certificado_binario(nro_item:=nro_item, err:=err)
            If (err.numError = 0) Then
                Try
                    If (err.params("filename") <> "") Then
                        ext = System.IO.Path.GetExtension(err.params("filename"))
                    End If
                    pathtmpfilename = Me.Path_base & System.IO.Path.GetTempFileName.Replace(".tmp", ext)
                    Dim fs As New System.IO.FileStream(pathtmpfilename, IO.FileMode.Create)
                    streamfile.CopyTo(fs)
                    fs.Close()
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try

            End If
            err.params.Add("tmpfile", pathtmpfilename)
            Return err
        End Function
        ''devuelve el binario del certificado, se usa previa llamada a la funcion consultar_certificados()
        ''nro_item, es la fila del html donde esta el certificado
        Private Function obtener_certificado_binario(ByVal nro_item As Integer, Optional ByRef err As tError = Nothing) As Stream
            err = New tError
            Dim filename As String = ""
            Dim archivobinario As Stream = Nothing
            Dim response As System.Net.HttpWebResponse = Nothing

            Dim nvRequestSteps = New nvHTTPRequestRobot
            Dim h As nvHttpUtilesRobot.tHeader
            Dim headers As List(Of nvHttpUtilesRobot.tHeader) = Me.initheaders()
            Dim cookiesResponse As List(Of nvHttpUtilesRobot.tCookies) = New List(Of nvHttpUtilesRobot.tCookies)
            Dim contenedorCookie = Me._cookieContenedor
            If (contenedorCookie Is Nothing) Then
                err.numError = 1
                err.mensaje = "no ha iniciado sesion"
            End If
            If (err.numError = 0) Then
                ''[PETICION 1]
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://misaplicaciones1.abc.gob.ar/Certificaciones/consultaCert.do"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = "https://misaplicaciones1.abc.gob.ar"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-origin"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)


                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-User"
                h.value = "?1"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Content-Type"
                h.value = "application/x-www-form-urlencoded"
                headers.Add(h)

                nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.param_add("certificado", CStr(nro_item))
                nvRequestSteps.param_add("button", "Imprimir")
                cookiesResponse = Nothing

                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = "https://misaplicaciones1.abc.gob.ar/Certificaciones/showCert.do"
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If
            If (err.numError = 0) Then

                Try
                    If Not response.Headers("filename") Is Nothing Then
                        filename = response.Headers("filename")
                    End If
                    If (response.Headers("Content-Disposition") IsNot Nothing) Then
                        If (response.Headers("Content-Disposition").IndexOf("filename") >= 0) Then
                            Dim partes = response.Headers("Content-Disposition").Split(";")
                            For p = 0 To partes.Count - 1
                                If (partes(p).IndexOf("filename") >= 0) Then
                                    filename = System.IO.Path.GetTempPath & partes(p).Replace("filename=", "")
                                    filename = filename.Replace("""", "")
                                    Exit For
                                End If
                            Next
                        End If
                    End If
                    If (filename <> "") Then
                        archivobinario = response.GetResponseStream()
                    End If

                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
            End If
            err.params.Add("filename", filename)
            Return archivobinario
        End Function


        Public Function obtener_disponible(ByVal htmlstring As String) As tError
            Dim err = New tError
            Dim disponible As Double = 0
            If (htmlstring = "") Then
                err.numError = 1
                err.mensaje = "no ingreso html"
            End If
            ''Dim htmlDocument As IHTMLDocument2 = New HTMLDocument()
            Dim htmlDocument As IHTMLDocument = New HTMLDocument()
            ''Dim htmlDocument = CreateObject("htmlfile")
            htmlDocument.Open()
            htmlDocument.Write(htmlstring)
            htmlDocument.Close()

            If (err.numError = 0) Then
                Try
                    Dim allTables As IHTMLElementCollection = htmlDocument.body.all.tags("table")
                    Dim element As IHTMLElement = Nothing
                    For Each element In allTables
                        ''element.title = element.innerText
                        If (element.className = "tabla1") Then
                            Exit For
                        End If
                    Next
                    ''
                    Dim colDisponible As Integer = 0 ''nro de columna que indica la celda del disponible (se busca primero en el encabezado)
                    If (element IsNot Nothing And element.className = "tabla1") Then
                        Dim elementosTR As IHTMLElementCollection = element.all.tags("tr")
                        Dim tr As IHTMLElement = Nothing
                        For Each tr In elementosTR
                            Dim elementosTD As IHTMLElementCollection = tr.all.tags("td")
                            Dim td As IHTMLElement = Nothing
                            Dim col As Integer = 0
                            If (colDisponible = 0) Then
                                For Each td In elementosTD
                                    ''si la columna del disponible ya fue hallada, se busca solamente el monto
                                    If (td.innerText.IndexOf("Total Disponible") >= 0) Then
                                        colDisponible = col
                                        Exit For '' y salgo del for del tr que tiene encabezado, continuo con los demas tr
                                    End If
                                    col += 1
                                    If (colDisponible > 0) Then
                                        Exit For
                                    End If
                                Next
                            Else
                                Try
                                    disponible += CDbl(elementosTD(colDisponible).innerText.Replace(".", ","))
                                Catch ex As Exception
                                End Try
                            End If
                        Next
                    End If
                Catch ex As Exception
                    err.parse_error_script(ex)
                    disponible = 0
                End Try
            End If
            err.params.Add("disponible", Replace(CStr(disponible), ",", "."))
            Return err
        End Function


        'Private Sub Serializar()
        '    Dim formatter As IFormatter = New BinaryFormatter 'formateador binario para realizar la serialización.
        '    ' Todo lo que necesita es crear una instancia de la secuencia y el formateador que desee utilizar, 
        '    Dim stream As Stream = New FileStream("mycookie.bin", FileMode.Create, FileAccess.Write, FileShare.Read)
        '    'y a continuación, llamar al método Serialize en el formateador
        '    formatter.Serialize(stream, Me._cookieContenedor)
        '    stream.Close()
        'End Sub
        '''Importantísimo para poder crear el archivo es tener permisos el usuario ASPNET en la carpeta. Para desSerializar 

        'Private Sub DesSerializar()
        '    Dim formatter As IFormatter = New BinaryFormatter
        '    Dim stream As Stream = New FileStream("mycookie.bin", FileMode.Open, FileAccess.Read, FileShare.Read)
        '    Me._cookieContenedor = TryCast(formatter.Deserialize(stream), Net.CookieContainer)
        '    stream.Close()
        'End Sub

        '' consulta primero la tabla de listado de certificados y luego en funcion del nro del certificado,descarga el binario
        Public Function descargar_certificado(ByVal nro_certificado As String, ByVal nro_docu As Integer) As tError

            Dim err As New tError
            Dim nro_item As Integer = -1 ''nro de item que indica la fila donde esta el nro_certificado
            err = consultar_certificados(CInt(nro_docu))
            If (err.numError = 0) Then
                Dim htmlresponse = err.params("response")

                Try
                    ''Dim htmlDocument As IHTMLDocument2 = New HTMLDocument()
                    Dim htmlDocument As IHTMLDocument = New HTMLDocument()
                    ''Dim htmlDocument = CreateObject("htmlfile")
                    htmlDocument.Open()
                    htmlDocument.Write(htmlresponse)
                    htmlDocument.Close()
                    ''htmlDocument.body.innerHTML = htmlresponse

                    Dim allTables As IHTMLElementCollection = htmlDocument.body.all.tags("table")
                    Dim element As IHTMLElement = Nothing
                    For Each element In allTables
                        ''element.title = element.innerText
                        If (element.className = "tabla1") Then
                            Exit For
                        End If
                    Next
                    ''

                    If (element IsNot Nothing And element.className = "tabla1") Then
                        Dim elementosTR As IHTMLElementCollection = element.all.tags("tr")
                        Dim tr As IHTMLElement = Nothing
                        Dim filascount As Integer = 0
                        For Each tr In elementosTR
                            filascount += 1
                            Dim elementosTD As IHTMLElementCollection = tr.all.tags("td")
                            If (RTrim(LTrim(elementosTD(1).innerText)) = nro_certificado) Then
                                nro_item = filascount - 2
                                Exit For
                            End If
                        Next
                    End If
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
                If (nro_item >= 0) Then
                    err = obtener_certificado(nro_item:=nro_item)
                Else
                    err.numError = 99
                    err.mensaje = "El certificado no se encuentra en la consulta"
                End If

            End If
            Return err
        End Function

        Public Function presentar_certificado(ByVal nro_docu As Integer, ByVal nro_entidad As Integer) As tError
            Dim err As New tError
            Dim filename As String = ""
            Dim pathtmpfilename As String = ""
            Dim archivobinario As Stream = Nothing
            Dim response As System.Net.HttpWebResponse = Nothing
            Dim contenedorCookie As New Net.CookieContainer
            Me.last_nro_docu = nro_docu
            Me.last_nro_entidad = nro_entidad
            err = consultar_disponibles(nro_docu, nro_entidad, contenedorCookie)
            If (err.numError = 0) Then
                ''[PETICION 1]
                Dim headers = Me.initheaders()

                Dim h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "misaplicaciones1.abc.gob.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Referer"
                h.value = "https://misaplicaciones1.abc.gob.ar/Certificaciones/altaCert.do"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = "https://misaplicaciones1.abc.gob.ar"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-Site"
                h.value = "same-origin"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Cache-Control"
                h.value = "max-age=0"
                headers.Add(h)


                h = New nvHttpUtilesRobot.tHeader
                h.name = "Sec-Fetch-User"
                h.value = "?1"
                headers.Add(h)
                h = New nvHttpUtilesRobot.tHeader
                h.name = "Content-Type"
                h.value = "application/x-www-form-urlencoded"
                headers.Add(h)

                Dim nvRequestSteps = New nvHTTPRequestRobot
                nvRequestSteps.param_add("button", "Seguir")
                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = "https://misaplicaciones1.abc.gob.ar/Certificaciones/showCertData.do"
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=Nothing, cookiecontainer:=contenedorCookie, AllowAutoRedirect:=False)
                err = nvRequestSteps.lastError
            End If

            If (err.numError = 0) Then

                Dim ext As String = ".pdf"
                Try
                    If Not response.Headers("filename") Is Nothing Then
                        filename = response.Headers("filename")
                    End If
                    If (response.Headers("Content-Disposition") IsNot Nothing) Then
                        If (response.Headers("Content-Disposition").IndexOf("filename") >= 0) Then
                            Dim partes = response.Headers("Content-Disposition").Split(";")
                            For p = 0 To partes.Count - 1
                                If (partes(p).IndexOf("filename") >= 0) Then
                                    filename = System.IO.Path.GetTempPath & partes(p).Replace("filename=", "")
                                    filename = filename.Replace("""", "")

                                    Exit For
                                End If
                            Next
                        End If
                    End If
                    If (filename <> "") Then
                        ext = System.IO.Path.GetExtension(filename)
                        archivobinario = response.GetResponseStream()
                        Try

                            pathtmpfilename = Me.Path_base & CStr(nro_docu) & "_" & System.IO.Path.GetFileName(filename) ''System.IO.Path.GetFileName(System.IO.Path.GetTempFileName.Replace(".tmp", ext))
                            Dim fs As New System.IO.FileStream(pathtmpfilename, IO.FileMode.Create)
                            archivobinario.CopyTo(fs)
                            fs.Close()
                            archivobinario = Nothing
                        Catch ex As Exception
                            err.parse_error_script(ex)
                        End Try
                    Else
                        err.numError = 6
                        err.mensaje = "No se pudo obtener el certificado"
                    End If

                    Dim htmlstring As String = decoderesponse(response)
                    If (err.params.ContainsKey("response")) Then
                        err.params("response") = htmlstring
                    Else
                        err.params.Add("response", htmlstring)
                    End If

                    If (htmlstring.IndexOf("Ha agotado") >= 0) Then
                        err.numError = 7
                        err.mensaje = "Ha agotado la cantidad de certificados disponibles para esta entidad"
                    End If

                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
            End If


            err.params.Add("tmpfile", pathtmpfilename)
            err.params.Add("filename", filename)

            Dim strSQL = "insert into educacion_ba_logs(fecha,descripcion,logs,nro_operador,nro_vendedor,nro_docu,nro_entidad) values(getdate(),?,?," & CStr(Me.nro_operador) & "," & CStr(Me.nro_vendedor) & "," & CStr(Me.last_nro_docu) & "," & CStr(Me.last_nro_entidad) & ")"
            Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
            Dim descripcion As String = CStr(err.numError) & " - msg: " & err.mensaje & " - filename: " & err.params("filename") & " - tmpfile: " & pathtmpfilename
            Dim descripcionparam = cmd.CreateParameter("@descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, descripcion)
            cmd.Parameters.Append(descripcionparam)
            Dim logsparam = cmd.CreateParameter("@logs", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.params("response"))
            cmd.Parameters.Append(logsparam)
            cmd.Execute()
            cmd = Nothing

            Return err
        End Function

        Public Function obtener_monto_disponible(ByVal nro_docu As Integer, ByVal nro_entidad As Integer) As tError
            Dim err As New tError
            Dim htmlresponse As String = ""
            err = Me.consultar_disponibles(nro_docu:=nro_docu, nro_entidad:=nro_entidad)
            If (err.numError = 0) Then
                htmlresponse = err.params("response")
                err = obtener_disponible_cargos_titulares(htmlresponse)
            End If
            If (err.numError = 0) Then
                Dim strSQL = "insert into educacion_ba_disponibles (nro_docu,fecha,nro_entidad,html,disponible,nro_operador,nro_vendedor) values(" & CStr(nro_docu) & ",getdate()," & CStr(nro_entidad) & ",?," & Replace(err.params("disponible"), ",", ".") & "," & CStr(Me.nro_operador) & "," & CStr(Me.nro_vendedor) & ")"
                Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
                Dim insertparam = cmd.CreateParameter("@html", ADODB.DataTypeEnum.adVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, htmlresponse)
                cmd.Parameters.Append(insertparam)
                cmd.Execute()
                cmd = Nothing
            End If
            Return err
        End Function


        '' consulta primero la tabla de listado de certificados y luego en funcion de la entidad, mes y anio, obtenego el certificado
        Public Function obtener_info_certificado_periodo(ByVal nro_docu As Integer, ByVal entidad As String, ByVal mes As Integer, anio As Integer) As tError

            Dim messtr As String = IIf(mes < 10, "0" & CStr(mes), CStr(mes))
            Dim periodo As String = CStr(anio) & messtr
            Dim err As New tError
            Dim nro_item As Integer = -1 ''nro de item que indica la fila donde esta el nro_certificado
            Dim param_fe_emision As String = ""
            Dim param_estado As String = ""
            Dim param_cod_descuento As String = ""
            Dim param_nro_autorizacion_descuento As String = ""

            Dim param_nro_certificado As String = ""
            err = consultar_certificados(CInt(nro_docu))
            If (err.numError = 0) Then
                Dim htmlresponse = err.params("response")

                Try
                    ''Dim htmlDocument As IHTMLDocument2 = New HTMLDocument()
                    Dim htmlDocument As IHTMLDocument = New HTMLDocument()
                    ''Dim htmlDocument = CreateObject("htmlfile")
                    htmlDocument.Open()
                    htmlDocument.Write(htmlresponse)
                    htmlDocument.Close()

                    Dim allTables As IHTMLElementCollection = htmlDocument.body.all.tags("table")
                    Dim element As IHTMLElement = Nothing
                    For Each element In allTables
                        ''element.title = element.innerText
                        If (element.className = "tabla1") Then
                            Exit For
                        End If
                    Next
                    ''

                    If (element IsNot Nothing And element.className = "tabla1") Then
                        Dim elementosTR As IHTMLElementCollection = element.all.tags("tr")
                        Dim tr As IHTMLElement = Nothing
                        Dim filascount As Integer = 0
                        For Each tr In elementosTR
                            filascount += 1
                            Dim elementosTD As IHTMLElementCollection = tr.all.tags("td")
                            param_fe_emision = RTrim(LTrim(elementosTD(3).innerText)).ToUpper()
                            If (param_fe_emision.Substring(0, 6) = periodo And RTrim(LTrim(elementosTD(5).innerText)).ToUpper() = entidad.ToUpper()) Then
                                param_nro_certificado = RTrim(LTrim(elementosTD(1).innerText))
                                param_estado = RTrim(LTrim(elementosTD(4).innerText))
                                param_cod_descuento = RTrim(LTrim(elementosTD(6).innerText))
                                param_nro_autorizacion_descuento = RTrim(LTrim(elementosTD(7).innerText))
                                nro_item = filascount - 2
                                Exit For
                            End If
                        Next
                    End If
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
                If (nro_item >= 0) Then
                    err = obtener_certificado(nro_item:=nro_item)
                    err.params.Add("nro_certificado", param_nro_certificado)
                    err.params.Add("estado", param_estado)
                    err.params.Add("cod_descuento", param_cod_descuento)
                    err.params.Add("nro_autorizacion", param_nro_autorizacion_descuento)
                    err.params.Add("fe_emision", param_fe_emision)
                Else
                    err.numError = 100
                    err.mensaje = "No hay certificado en el periodo consultado"
                End If

            End If
            Return err
        End Function

        Public Function obtener_disponible_cargos_titulares(ByVal htmlstring As String) As tError
            Dim err As New tError
            Dim disponible As Double = 0
            If (htmlstring = "") Then
                err.numError = 1
                err.mensaje = "no ingreso html"
            End If

            Dim htmlDocument As IHTMLDocument = New HTMLDocument()
            htmlDocument.open()
            htmlDocument.write(htmlstring)
            htmlDocument.close()

            If (err.numError = 0) Then
                Try
                    Dim allTables As IHTMLElementCollection = htmlDocument.body.all.tags("table")
                    Dim element As IHTMLElement = Nothing
                    For Each element In allTables
                        ''element.title = element.innerText
                        If (element.className = "tabla1") Then
                            Exit For
                        End If
                    Next
                    ''
                    Dim colDisponible As Integer = 0 ''nro de columna que indica la celda del disponible (se busca primero en el encabezado)
                    Dim colCargo As Integer = 4 ''nro de columna que indica la celda del cargo q ocupa
                    If (element IsNot Nothing And element.className = "tabla1") Then
                        Dim elementosTR As IHTMLElementCollection = element.all.tags("tr")
                        Dim tr As IHTMLElement = Nothing
                        For Each tr In elementosTR
                            Dim elementosTD As IHTMLElementCollection = tr.all.tags("td")
                            Dim td As IHTMLElement = Nothing
                            Dim col As Integer = 0
                            If (colDisponible = 0) Then
                                For Each td In elementosTD
                                    ''si la columna del disponible ya fue hallada, se busca solamente el monto
                                    If (td.innerText.IndexOf("Total Disponible") >= 0) Then
                                        colDisponible = col
                                        Exit For '' y salgo del for del tr que tiene encabezado, continuo con los demas tr
                                    End If
                                    col += 1
                                    If (colDisponible > 0) Then
                                        Exit For
                                    End If
                                Next
                            Else
                                Try
                                    ''si el cargo no es suplente, sumo disponible
                                    Dim cargo As String = elementosTD(colCargo).innerText.ToUpper()
                                    If (cargo.IndexOf("SUPLENTE") = -1) Then
                                        disponible += CDbl(elementosTD(colDisponible).innerText.Replace(".", ","))
                                    End If

                                Catch ex As Exception
                                End Try
                            End If
                        Next
                    End If
                Catch ex As Exception
                    err.parse_error_script(ex)
                    disponible = 0
                End Try
            End If
            err.params.Add("disponible", CStr(disponible))
            Return err
        End Function
    End Class
End Namespace