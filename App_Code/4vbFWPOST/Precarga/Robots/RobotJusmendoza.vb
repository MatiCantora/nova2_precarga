Imports System.IO

Namespace nvFW.servicios.Robots
    Public Class RobotJusmendoza

        Public responseString As String

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
        Public url1 As String = "http://www2.jus.mendoza.gov.ar/registros/rju/index.php?"
        Public url2 As String = "http://www2.jus.mendoza.gov.ar/registros/rju/resultados2.php"
        Public cookies As String = ""
        Public timeout As Integer = 10000


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

        Public Function consultarjuicios(ByVal nro_docu As Integer) As tError

            Dim err As New tError
            Dim contenedorCookie As Net.CookieContainer
            Dim response As System.Net.HttpWebResponse = Nothing
            Dim nvRequestSteps = New nvHTTPRequestRobot
            nvRequestSteps.timeout = Me.timeout
            Dim h As nvHttpUtilesRobot.tHeader
            Dim headers As List(Of nvHttpUtilesRobot.tHeader) = Me.initheaders()
            Dim cookiesResponse As List(Of nvHttpUtilesRobot.tCookies) = New List(Of nvHttpUtilesRobot.tCookies)
            Dim cookies As String = ""
            Dim AbsoluteUri As String = ""

            h = New nvHttpUtilesRobot.tHeader
            h.name = "Host"
            h.value = "www2.jus.mendoza.gov.ar"
            headers.Add(h)

            h = New nvHttpUtilesRobot.tHeader
            h.name = "Sec-Fetch-Site"
            h.value = "none"
            headers.Add(h)

            nvRequestSteps = New nvHTTPRequestRobot
            nvRequestSteps.url = url1
            response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie)
            err = nvRequestSteps.lastError

            If (err.numError = 0) Then
                cookies = contenedorCookie.GetCookieHeader(New Uri(url1))
                ''[PETICION 1]
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                AbsoluteUri = response.ResponseUri.AbsoluteUri
                headers = Me.initheaders()

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Host"
                h.value = "www2.jus.mendoza.gov.ar"
                headers.Add(h)

                h = New nvHttpUtilesRobot.tHeader
                h.name = "Origin"
                h.value = Me.url1
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

                nvRequestSteps.param_add("nombre", "")
                nvRequestSteps.param_add("fec", 0)
                nvRequestSteps.param_add("expediente", "")
                nvRequestSteps.param_add("documento", nro_docu)
                cookiesResponse = Nothing
                nvRequestSteps.AllowWriteStreamBuffering = True
                nvRequestSteps.url = url2
                response = nvRequestSteps.getResponse("POST", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie)
                err = nvRequestSteps.lastError
            End If


            If (err.numError = 0) Then

                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                err.params.Add("response", Me.responseString)
            End If

            Return err
        End Function

        Function getjuicios(ByVal nro_docu As Integer, ByVal nro_operador As Integer) As tError

            Dim cantidad_registros As Integer = 0
            Dim err = Me.consultarjuicios(nro_docu:=nro_docu)
            Try
                Dim cadenapatron As String = "Total de Registros Encontrados:"

                If (err.numError = 0) Then
                    Dim responseString As String = err.params("response")
                    Dim pos1 As Integer = responseString.IndexOf(cadenapatron)
                    If (pos1 > 0) Then
                        Dim parteencontrada = responseString.Substring(pos1, responseString.Length - pos1)
                        Dim partes2 = parteencontrada.Split(";")
                        cantidad_registros = CInt(partes2(0).Replace(cadenapatron, ""))
                    End If

                    If (err.numError = 0) Then
                        Dim strSQL = "insert into robot_jusmendoza (nro_operador,fecha,response) values(" & CStr(nro_operador) & ",getdate(),?)"
                        Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
                        Dim insertparam = cmd.CreateParameter("@html", ADODB.DataTypeEnum.adVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.params("response"))
                        cmd.Parameters.Append(insertparam)
                        cmd.Execute()
                        cmd = Nothing
                    End If
                End If
            Catch ex As Exception
                err.numError = 5
                err.parse_error_script(ex)
            End Try
            err.params.Add("registros", cantidad_registros)
            Return err
        End Function
    End Class
End Namespace