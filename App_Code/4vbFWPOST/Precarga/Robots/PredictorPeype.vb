Imports System.IO

Namespace nvFW.servicios.Robots
    Public Class PredictorPeype

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
        Public dias_cache As Integer = 30 ''cantidad de dias a buscar consultas en la base de datos
        Public url1 As String = "https://www.pypdatos.com.ar:8543/apipyp/rest/serviciospyp/persona"
        ''ejemplo https://www.pypdatos.com.ar:8543/apipyp/rest/serviciospyp/persona/apitestjh/jcnfh4g3/30452908/M

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

        Public Function consultar(ByVal nro_docu As Integer, ByVal sexo As String, ByVal credenciales As PredictorCredenciales, Optional cache As Boolean = True) As tError

            Dim err As New tError
            If (cache) Then
                Dim responseText = Me.consultarcache(nro_docu, sexo)
                If (responseText <> "") Then
                    Me.responseString = responseText
                    err.params.Add("response", responseText)
                    Return err
                End If
            End If

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
            h.name = "Sec-Fetch-Site"
            h.value = "none"
            headers.Add(h)

            nvRequestSteps = New nvHTTPRequestRobot
            nvRequestSteps.url = url1 & "/" & credenciales.user & "/" & credenciales.pwd & "/" & CStr(nro_docu) & "/" & sexo
            response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie)
            err = nvRequestSteps.lastError

            If (err.numError = 0) Then
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                err.params.Add("response", Me.responseString)
            End If
            Dim strSQL = "insert into lausana_anexa..predictor_log (xmlresponse,error,fecha,nro_operador,nro_docu,sexo) values(?,?,getdate(),dbo.rm_nro_operador()," & CStr(nro_docu) & ",'" & sexo & "')"
            Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
            Dim insertparam = cmd.CreateParameter("@xmlresponse", ADODB.DataTypeEnum.adVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.params("response"))
            cmd.Parameters.Append(insertparam)
            insertparam = cmd.CreateParameter("@error", ADODB.DataTypeEnum.adVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.mensaje)
            cmd.Parameters.Append(insertparam)
            cmd.Execute()
            cmd = Nothing
            Return err
        End Function


        Public Function consultar(ByVal nro_docu As Integer, ByVal sexo As String, ByVal credenciales As PredictorCredenciales, ByRef err As tError, Optional cache As Boolean = True) As Dictionary(Of String, String)

            Dim ret As New Dictionary(Of String, String)
            err = Me.consultar(nro_docu, sexo, credenciales, cache)
            If (err.numError = 0) Then
                Dim xmlresponse As String = err.params.Item("response")
                Dim ParteXML = New System.Xml.XmlDocument
                ParteXML.LoadXml(xmlresponse)
                Dim XmlNodeList As System.Xml.XmlNodeList
                Dim node As System.Xml.XmlNode
                Dim row As System.Xml.XmlNode = ParteXML.DocumentElement.SelectSingleNode("/RESULTADO/row")
                XmlNodeList = row.ChildNodes()
                For Each node In XmlNodeList
                    ret.Add(node.Name, node.InnerText)
                Next
            End If
            Return ret
        End Function


        Public Function consultarcache(ByVal nro_docu As Integer, ByVal sexo As String) As String
            Dim responseText As String = ""
            Dim stmt As String = "select *  from lausana_anexa..predictor_log where nro_docu=" & CStr(nro_docu) & " and sexo='" & sexo & "' and [error]='' and xmlresponse<>'' and  DATEDIFF(day, fecha,getdate())<" & CStr(Me.dias_cache)
            Dim rs = nvDBUtiles.DBOpenRecordset(stmt)
            If (Not rs.EOF) Then
                responseText = rs.Fields("xmlresponse").Value
            End If

            Return responseText
        End Function

        Public Function consultarcache(ByVal cuit As String) As String
            Dim responseText As String = ""
            Dim stmt As String = "select *  from lausana_anexa..predictor_log where cuit='" & cuit & "' and [error]='' and xmlresponse<>'' and  DATEDIFF(day, fecha,getdate())<" & CStr(Me.dias_cache)
            Dim rs = nvDBUtiles.DBOpenRecordset(stmt)
            If (Not rs.EOF) Then
                responseText = rs.Fields("xmlresponse").Value
            End If

            Return responseText
        End Function

        Public Function consultar(ByVal cuit As String, ByVal credenciales As PredictorCredenciales, Optional cache As Boolean = True) As tError

            Dim err As New tError

            If (cache) Then
                Dim responseText = Me.consultarcache(cuit)
                If (responseText <> "") Then
                    Me.responseString = responseText
                    err.params.Add("response", responseText)
                    Return err
                End If
            End If
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
            h.name = "Sec-Fetch-Site"
            h.value = "none"
            headers.Add(h)

            nvRequestSteps = New nvHTTPRequestRobot
            nvRequestSteps.url = url1 & "/" & credenciales.user & "/" & credenciales.pwd & "/" & cuit & "/S"
            response = nvRequestSteps.getResponse("GET", headers:=headers, cookiesResponse:=cookiesResponse, cookiecontainer:=contenedorCookie)
            err = nvRequestSteps.lastError

            If (err.numError = 0) Then
                Dim stream = response.GetResponseStream()
                Dim responseReader = New StreamReader(stream)
                Me.responseString = responseReader.ReadToEnd()
                err.params.Add("response", Me.responseString)
            End If
            Dim strSQL = "insert into lausana_anexa..predictor_log (xmlresponse,error,fecha,nro_operador,cuit) values(?,?,getdate(),dbo.rm_nro_operador()," & cuit & ")"
            Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
            Dim insertparam = cmd.CreateParameter("@xmlresponse", ADODB.DataTypeEnum.adVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.params("response"))
            cmd.Parameters.Append(insertparam)
            insertparam = cmd.CreateParameter("@error", ADODB.DataTypeEnum.adVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.mensaje)
            cmd.Parameters.Append(insertparam)
            cmd.Execute()
            cmd = Nothing
            Return err
        End Function


    End Class

    Public Class PredictorCredenciales
        Public user As String = ""
        Public pwd As String = ""
    End Class
End Namespace