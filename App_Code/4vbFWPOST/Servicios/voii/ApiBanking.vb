Imports System.IO
Imports System.Xml
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW.servicios.voii
    Public Class ApiBanking
        Private _urlservices As Dictionary(Of String, String) = New Dictionary(Of String, String)
        Private _serverName As String = ""
        Private _urlbase As String = "https://<server_name>/"
        Private _urlpdfx As String = ""
        Private _pwdpdfx As String = ""
        Private _conectado As Boolean = False
        Private _timeout As Integer = 1000 * 60 * 3 ''3 minutos
        Private _certs As List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)
        Private _nro_entidad_consulta As Integer = 0 ''nro de la entidad con la que se realiza la consulta
        Private _contingencia As Boolean = False ''si el servicio QNET no anda, se habilita esto

        Public Sub New(ByVal urlpdfx As String, Optional ByVal pwdpdfx As String = "", Optional host As String = "", Optional nro_entidad_consulta As Integer = 0)
            Me._urlpdfx = urlpdfx
            Me._pwdpdfx = pwdpdfx
            Me._serverName = host
            If (nro_entidad_consulta <> 0) Then
                Me._nro_entidad_consulta = nro_entidad_consulta
            End If
            Me.init()
        End Sub

        ''' <summary>
        ''' este metodo se debe invocar luego del constructor para
        ''' establecer correcta conexion con certificados y claves necesarias
        ''' </summary>
        Public Function inicializar() As Boolean
            If (Me._urlpdfx = "") Then
                Return False
            End If
            Dim certificado As System.Security.Cryptography.X509Certificates.X509Certificate2 = New System.Security.Cryptography.X509Certificates.X509Certificate2(fileName:=Me._urlpdfx, password:=Me._pwdpdfx, keyStorageFlags:=System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.MachineKeySet)
            _certs = New List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)
            _certs.Add(certificado)
            _conectado = True
            Return _conectado
        End Function

        Public Sub New()
            Me.init()
        End Sub
        Private Sub init()
            _urlservices = New Dictionary(Of String, String)
            Me.add_point_service("ALTACREDIN", "API/cliente/cuenta/credin")
            Me.add_point_service("CONSULTADEBIN", "API/cliente/debin/consultar")
            Me.add_point_service("CONSULTACBU", "API/debin/consultarCBU")
            Me.add_point_service("CONSULTASALDO", "API/cliente/cuenta/saldo")
            Me.add_point_service("CONSULTAMOVIMIENTOS", "API/cliente/cuenta/movs")
        End Sub

        Public Sub add_point_service(ByVal serviceName As String, ByVal value As String)

            If (Me._urlservices.ContainsKey(serviceName.ToUpper)) Then
                Me._urlservices.Item(serviceName.ToUpper) = value
            Else
                Me._urlservices.Add(serviceName.ToUpper, value)
            End If
        End Sub

        Public Property serverName() As String
            Get
                Return Me._serverName
            End Get
            Set(ByVal value As String)
                Me._serverName = value
            End Set
        End Property

        Public Property urlpdfx() As String
            Get
                Return Me._urlpdfx
            End Get
            Set(ByVal value As String)
                Me._urlpdfx = value
            End Set
        End Property

        Public Property contingencia() As Boolean
            Get
                Return Me._contingencia
            End Get
            Set(ByVal value As Boolean)
                Me._contingencia = value
            End Set
        End Property



        Public Property timeout() As Integer
            Get
                Return Me._timeout
            End Get
            Set(ByVal value As Integer)
                Me._timeout = value
            End Set
        End Property

        ''' <summary>
        ''' este metodo, devuelve la existencia del debin
        ''' en un objeto terror
        ''' </summary>
        ''' <param name="id_debin"><c>parametro</c> identificador alfanumerico del debin.</param>
        Public Function consultarDEBIN(ByVal id_debin As String) As tError
            Dim strSql As String = ""
            Dim cmd As tnvDBCommand = Nothing
            Dim param As ADODB.Parameter = Nothing
            Dim rs As ADODB.Recordset = Nothing
            Dim responseText As String = ""
            Dim id As Integer = 0

            Dim err As New nvFW.tError
            If (id_debin = "") Then
                err.numError = -102
                err.mensaje = "faltan parametros"
                err.debug_desc = ""
                Return err
            End If
            If Not (_conectado) Then
                err.numError = -100
                err.mensaje = "no conectado"
                err.debug_desc = "faltan datos de conexion"
                Return err
            End If
            Dim url As String = parseUrl("CONSULTADEBIN")
            If (url = "") Then
                err.numError = -101
                err.mensaje = "variables de conexion no definidas correctamente"
                err.debug_desc = "verificar url CONSULTADEBIN"
                Return err
            End If
            url &= "/" & id_debin

            Dim req As New nvHTTPRequest()
            req.url = url
            req.Method = "GET"
            req.time_out = Me._timeout
            req.ClientCertificate = _certs
            Try
                'strSql = "insert into  lausana_anexa..apibanking (fe_request,nro_operador,url,servicio,nro_entidad_consulta) values (getdate(),dbo.rm_nro_operador(),?,'CONSULTADEBIN',case when " & CStr(Me._nro_entidad_consulta) & "=0 then null else " & Me._nro_entidad_consulta & " end))" & vbCrLf
                'strSql &= "select @@identity as id"
                'cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                'param = cmd.CreateParameter("@url", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, url)
                'cmd.Parameters.Append(param)
                'rs = cmd.Execute()
                'If Not (rs.EOF) Then
                '    id = rs.Fields("id").Value
                '    Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                '    paramLogsreq.add("id_debin", id_debin)
                '    paramLogsreq.save()
                'End If

                id = Me.gen_id_request(url, "CONSULTADEBIN")
                Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                paramLogsreq.add("id_debin", id_debin)
                paramLogsreq.save()
                responseText = req.getResponseText()
                If (responseText Is Nothing OrElse responseText = String.Empty) AndAlso Not req.response_error Is Nothing Then
                    responseText = New IO.StreamReader(req.response_error.GetResponseStream()).ReadToEnd()
                    err.numError = -103
                    err.mensaje = "error al consultar"
                    err.debug_desc = responseText
                Else
                    If (responseText Is Nothing) Then
                        err.numError = -1
                        err.mensaje = "no se puede consultar al host " & url
                    Else
                        err = jsonto_terror(responseText)
                        If (err.params.ContainsKey("responseXML")) Then
                            Dim paramLogsresponse As New ParamLog(id, typeParam.param_response)
                            paramLogsresponse.saveXML(err.params("responseXML"))
                        End If
                    End If
                End If
                req = Nothing
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            err.params("responseText") = responseText
            strSql = "update lausana_anexa..apibanking set fe_response=getdate(),numError=" & CStr(err.numError) & "  where id=" & CStr(id) & vbCrLf
            strSql &= "insert into lausana_anexa..apibanking_log (id,tipo,parametro,valor) values(" & CStr(id) & ",'debin_response','terror',?)"
            cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
            param = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.get_error_xml())
            cmd.Parameters.Append(param)
            cmd.Execute()
            cmd = Nothing
            param = Nothing
            rs = Nothing
            err.params("id_request") = id
            Return err
        End Function


        ''' <summary>
        ''' este metodo, devuelve la cbu si existe y de quien es
        ''' en un objeto terror
        ''' </summary>
        ''' <param name="parametro"><c>parametro</c> puede ser cbu, cvu o alias.</param>
        Public Function consultarCBU(ByVal parametro As String) As tError
            Dim strSql As String = ""
            Dim cmd As tnvDBCommand = Nothing
            Dim param As ADODB.Parameter = Nothing
            Dim rs As ADODB.Recordset = Nothing
            Dim responseText As String = ""
            Dim id As Integer = 0


            Dim err As New tError
            If (parametro = "") Then
                err.numError = -102
                err.mensaje = "faltan parametros"
                err.debug_desc = ""
                Return err
            End If
            If Not (_conectado) Then
                err.numError = -100
                err.mensaje = "no conectado"
                err.debug_desc = "faltan datos de conexion"
                Return err
            End If
            Dim url As String = parseUrl("CONSULTACBU")
            If (url = "") Then
                err.numError = -101
                err.mensaje = "variables de conexion no definidas correctamente"
                err.debug_desc = "verificar url CONSULTACBU"
                Return err
            End If
            url &= "/" & parametro


            Dim req As New nvHTTPRequest()
            req.url = url
            req.Method = "GET"
            req.time_out = Me._timeout
            req.ClientCertificate = _certs
            Try
                'strSql = "insert into  lausana_anexa..apibanking (fe_request,nro_operador,url,servicio,nro_entidad_consulta) values (getdate(),dbo.rm_nro_operador(),?,'CONSULTACBU',case when " & CStr(Me._nro_entidad_consulta) & "=0 then null else " & Me._nro_entidad_consulta & " end))" & vbCrLf
                'strSql &= "select @@identity as id"
                'cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                'param = cmd.CreateParameter("@url", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, url)
                'cmd.Parameters.Append(param)
                'rs = cmd.Execute()
                'If Not (rs.EOF) Then
                '    id = rs.Fields("id").Value
                '    Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                '    paramLogsreq.add("cbu", parametro)
                '    paramLogsreq.save()
                'End If
                id = Me.gen_id_request(url, "CONSULTACBU")
                Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                paramLogsreq.add("cbu", parametro)
                paramLogsreq.save()

                responseText = req.getResponseText()
                If (responseText Is Nothing OrElse responseText = String.Empty) AndAlso Not req.response_error Is Nothing Then
                    responseText = New IO.StreamReader(req.response_error.GetResponseStream()).ReadToEnd()
                    err.numError = -103
                    err.mensaje = "error al consultar"
                    err.debug_desc = responseText
                Else
                    If (responseText Is Nothing) Then
                        err.numError = -1
                        err.mensaje = "no se puede consultar al host " & url
                    Else
                        err = jsonto_terror(responseText)
                        If (err.params.ContainsKey("responseXML")) Then
                            Dim paramLogsresponse As New ParamLog(id, typeParam.param_response)
                            paramLogsresponse.saveXML(err.params("responseXML"))
                        End If

                    End If
                End If
                req = Nothing
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            err.params("responseText") = responseText

            strSql = "update lausana_anexa..apibanking set fe_response=getdate(),numError=" & CStr(err.numError) & "  where id=" & CStr(id) & vbCrLf
            strSql &= "insert into lausana_anexa..apibanking_log (id,tipo,parametro,valor) values(" & CStr(id) & ",'cbu_response','terror',?)"
            cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
            param = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.get_error_xml())
            cmd.Parameters.Append(param)
            cmd.Execute()

            cmd = Nothing
            param = Nothing
            rs = Nothing
            If (err.params.ContainsKey("id_request")) Then
                err.params("id_request") = CStr(id)
            Else
                err.params.Add("id_request", CStr(id))
            End If
            Return err
        End Function

        ''' <summary>
        ''' este metodo, devuelve el saldo de una cuenta 
        ''' en un objeto terror
        ''' </summary>
        ''' <param name="cbu"><c>parametro</c> 22 caracteres que identifican la cuenta bancaria</param>
        Public Function consultarSALDO(ByVal cbu As String) As tError
            Dim strSql As String = ""
            Dim cmd As tnvDBCommand = Nothing
            Dim param As ADODB.Parameter = Nothing
            Dim rs As ADODB.Recordset = Nothing
            Dim responseText As String = ""
            Dim id As Integer = 0


            Dim err As New tError
            If (cbu = "") Then
                err.numError = -102
                err.mensaje = "faltan parametros"
                err.debug_desc = ""
                Return err
            End If
            If Not (_conectado) Then
                err.numError = -100
                err.mensaje = "no conectado"
                err.debug_desc = "faltan datos de conexion"
                Return err
            End If
            Dim url As String = parseUrl("CONSULTASALDO")
            If (url = "") Then
                err.numError = -101
                err.mensaje = "variables de conexion no definidas correctamente"
                err.debug_desc = "verificar url CONSULTASALDO"
                Return err
            End If
            url &= "/" & cbu

            Dim req As New nvHTTPRequest()
            req.url = url
            req.Method = "GET"
            req.time_out = Me._timeout
            req.ClientCertificate = _certs
            Try
                'strSql = "insert into  lausana_anexa..apibanking (fe_request,nro_operador,url,servicio,nro_entidad_consulta) values (getdate(),dbo.rm_nro_operador(),?,'CONSULTASALDO',case when " & CStr(Me._nro_entidad_consulta) & "=0 then null else " & Me._nro_entidad_consulta & " end)" & vbCrLf
                'strSql &= "select @@identity as id"
                'cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                'param = cmd.CreateParameter("@url", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, url)
                'cmd.Parameters.Append(param)
                'rs = cmd.Execute()
                'If Not (rs.EOF) Then
                '    id = rs.Fields("id").Value
                '    Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                '    paramLogsreq.add("cbu", cbu)
                '    paramLogsreq.save()
                'End If
                id = Me.gen_id_request(url, "CONSULTASALDO")
                Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                paramLogsreq.add("cbu", cbu)
                paramLogsreq.save()
                responseText = req.getResponseText()
                If (responseText Is Nothing OrElse responseText = String.Empty) AndAlso Not req.response_error Is Nothing Then
                    responseText = New IO.StreamReader(req.response_error.GetResponseStream()).ReadToEnd()
                    err.numError = -103
                    err.mensaje = "error al consultar"
                    err.debug_desc = responseText
                Else
                    If (responseText Is Nothing) Then
                        err.numError = -1
                        err.mensaje = "no se puede consultar al host " & url
                    Else
                        err = jsonto_terror(responseText)
                        If (err.params.ContainsKey("responseXML")) Then
                            Dim paramLogsresponse As New ParamLog(id, typeParam.param_response)
                            paramLogsresponse.saveXML(err.params("responseXML"))
                        End If
                    End If
                End If
                req = Nothing
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            err.params("responseText") = responseText

            strSql = "update lausana_anexa..apibanking set fe_response=getdate(),numError=" & CStr(err.numError) & "  where id=" & CStr(id) & vbCrLf
            strSql &= "insert into lausana_anexa..apibanking_log (id,tipo,parametro,valor) values(" & CStr(id) & ",'saldo_response','terror',?)"
            cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
            param = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.get_error_xml())
            cmd.Parameters.Append(param)
            cmd.Execute()
            cmd = Nothing
            param = Nothing
            rs = Nothing
            err.params("id_request") = id
            Return err
        End Function

        Public Function jsonto_terror(ByVal jsontext As String, Optional ByRef odic As Dictionary(Of String, Object) = Nothing) As tError
            Dim err As New tError
            Try
                'Dim odic As Dictionary(Of String, Object) = nvFW.nvConvertUtiles.JSONToDictionary(jsontext)
                odic = nvFW.nvConvertUtiles.JSONToDictionary(jsontext)
                If (odic.ContainsKey("numError")) Then
                    err.numError = CInt(odic.Item("numError"))
                End If
                If (odic.ContainsKey("titulo")) Then
                    err.titulo = odic.Item("titulo")
                End If
                If (odic.ContainsKey("mensaje")) Then
                    err.mensaje = odic.Item("mensaje")
                End If
                If (odic.ContainsKey("debug_src")) Then
                    err.debug_src = odic.Item("debug_src")
                End If
                If (odic.ContainsKey("debug_desc")) Then
                    err.debug_desc = odic.Item("debug_desc")
                End If
                If (odic.ContainsKey("params")) Then

                    Dim paramsxml As String = parseStringToXml(odic("params"))
                    ''err.params = odic.Item("params")
                    err.params.Add("responseXML", paramsxml)
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try

            Return err
        End Function



        ''' <summary>
        ''' este metodo, devuelve los movimientos en funcion de una cbu que se pasa como parametro
        ''' en un objeto terror
        ''' </summary>
        ''' <param name="cbu"><c>parametro</c> cuenta unica bancaria de 22 digitos.</param>
        ''' <param name="fe_desde"><c> fecha desde</c>fecha desde a consultar saldo, formato string mm/dd/yyyy o  mm/dd/yyyy HH:MM:SS.</param>
        ''' <param name="fe_hasta"><c> fecha hasta</c>fecha hasta a consultar saldo, formato string mm/dd/yyyy o  mm/dd/yyyy HH:MM:SS.</param>
        ''' <param name="filtroWhere"><c> filtro extra opcional</c>se pode utilizar para detallar más la consulta de movimientos.Ejemplo 1: En este caso localiza cualquier movimiento que contenga el id debin “WGRXJE27QK7GXOL97MYQL3”, se ingresa “<criterio><select><filtro><info_adic type="like"> ”%WGRXJE27QK7GXOL97MYQL3%” </info_adic></filtro></select></criterio>”</param>
        Public Function consultarMOVIMIENTOS(ByVal cbu As String, ByVal fe_desde As String, ByVal fe_hasta As String, Optional filtroWhere As String = "") As tError
            Dim strSql As String = ""
            Dim cmd As tnvDBCommand = Nothing
            Dim param As ADODB.Parameter = Nothing
            Dim rs As ADODB.Recordset = Nothing
            Dim id As Integer = 0
            Dim nro_fila As Integer = 0

            Dim responseText As String = ""
            Dim err As New tError
            If (cbu = "") Then
                err.numError = -102
                err.mensaje = "faltan parametros"
                err.debug_desc = ""
                Return err
            End If
            If Not (_conectado) Then
                err.numError = -100
                err.mensaje = "no conectado"
                err.debug_desc = "faltan datos de conexion"
                Return err
            End If
            Dim url As String = parseUrl("CONSULTAMOVIMIENTOS")
            If (url = "") Then
                err.numError = -101
                err.mensaje = "variables de conexion no definidas correctamente"
                err.debug_desc = "verificar url CONSULTAMOVIMIENTOS"
                Return err
            End If
            ''url &= "/" & cbu

            Dim req As New nvHTTPRequest()

            Dim json As String = "{"
            json &= """cbu"":""" & cbu & ""","
            json &= """fe_desde"":""" & fe_desde & ""","
            json &= """fe_hasta"":""" & fe_hasta & ""","
            json &= """filtroWhere"":""" & filtroWhere & """"
            json &= "}"


            'req.param_add("fe_desde", fe_desde)
            'req.param_add("fe_hasta", fe_hasta)
            'If (filtroWhere <> "") Then
            '    req.param_add("filtroWhere", filtroWhere)
            'End If
            req.url = url
            req.Method = "POST"
            req.Body = json
            req.time_out = Me._timeout
            req.ContentType = "application/json"
            req.ClientCertificate = _certs
            Try
                'strSql = "insert into  lausana_anexa..apibanking (fe_request,nro_operador,url,servicio) values (getdate(),dbo.rm_nro_operador(),?,'CONSULTAMOVIMIENTOS')" & vbCrLf
                'strSql &= "select @@identity as id"
                'cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                'param = cmd.CreateParameter("@url", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, url)
                'cmd.Parameters.Append(param)
                'rs = cmd.Execute()
                'If Not (rs.EOF) Then
                '    id = rs.Fields("id").Value
                '    Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                '    paramLogsreq.add("json", json)
                '    paramLogsreq.save()
                'End If

                id = Me.gen_id_request(url, "CONSULTAMOVIMIENTOS")
                Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                paramLogsreq.add("json", json)
                paramLogsreq.save()

                strSql = "insert into  lausana_anexa..apibanking_log (id,tipo,parametro,valor) values (" & CStr(id) & ",'mov_request','parametrojson',?)" & vbCrLf
                cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                param = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, json)
                cmd.Parameters.Append(param)
                cmd.Execute()

                responseText = req.getResponseText()
                If (responseText Is Nothing OrElse responseText = String.Empty) AndAlso Not req.response_error Is Nothing Then
                    responseText = New IO.StreamReader(req.response_error.GetResponseStream()).ReadToEnd()
                    err.numError = -103
                    err.mensaje = "error al consultar"
                    err.debug_desc = responseText
                Else
                    If (responseText Is Nothing) Then
                        err.numError = -1
                        err.mensaje = "no se puede consultar al host " & url
                    Else
                        Dim paramLogsresponse As New ParamLog(id, typeParam.param_response)
                        paramLogsresponse.add("responsetext", responseText)
                        paramLogsresponse.save()
                        Dim odic As Dictionary(Of String, Object) = New Dictionary(Of String, Object)
                        err = jsonto_terror(responseText, odic)
                        If (err.numError = 0) Then
                            If (odic.ContainsKey("params")) Then
                                Dim params As Dictionary(Of String, Object) = odic("params")
                                If (params.ContainsKey("rows")) Then
                                    Dim rows As Dictionary(Of String, Object)
                                    rows = params.Item("rows")
                                    nvDBUtiles.DBExecute("delete from  [lausana_anexa].[dbo].[apibanking_movs] where id_request=" & CStr(id))
                                    For Each kvp In rows
                                        If (IsNumeric(kvp.Key)) Then
                                            Dim fila As Dictionary(Of String, Object) = TryCast(kvp.Value, Dictionary(Of String, Object))
                                            nro_fila = kvp.Key
                                            strSql = "INSERT INTO [lausana_anexa].[dbo].[apibanking_movs]([id_request],[numero],[fecha],[nro_cuenta],[desc],[cod_trn],[trn],[informacion_adicional],[moneda],[importe]) VALUES(" & CStr(id) & "," & CStr(nro_fila) & ",?,?,?,?,?,?,?,?)"
                                            cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                                            param = cmd.CreateParameter("@fecha", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("fecha"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            param = cmd.CreateParameter("@nro_cuenta", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("nro_cuenta"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            param = cmd.CreateParameter("@desc", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("desc"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            param = cmd.CreateParameter("@cod_trn", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("cod_trn"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            param = cmd.CreateParameter("@trn", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("trn"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            param = cmd.CreateParameter("@informacion_adicional", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("informacion_adicional"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            param = cmd.CreateParameter("@moneda", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("moneda"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            param = cmd.CreateParameter("@importe", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(isNUllorEmpty(fila.Item("importe"), "")).Trim())
                                            cmd.Parameters.Append(param)
                                            cmd.Execute()
                                        End If
                                    Next
                                End If
                            End If
                        End If


                    End If
                End If
                req = Nothing
            Catch ex As Exception
                err.parse_error_script(ex)
                err.debug_desc = err.debug_desc & " " & ex.StackTrace()
            End Try

            err.params("responseText") = responseText

            strSql = "update lausana_anexa..apibanking set fe_response=getdate(),numError=" & CStr(err.numError) & "  where id=" & CStr(id) & vbCrLf
            strSql &= "insert into lausana_anexa..apibanking_log (id,tipo,parametro,valor) values(" & CStr(id) & ",'mov_response','terror',?)"
            cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
            param = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.get_error_xml())
            cmd.Parameters.Append(param)
            cmd.Execute()

            cmd = Nothing
            param = Nothing
            rs = Nothing
            err.params("id_request") = CStr(id)
            err.params("movimientos") = nro_fila
            Return err
        End Function



        ''' <summary>
        ''' realizar el credin desde la api de voii
        ''' </summary>
        ''' <param name="parametro"><cparametro</c> objeto paramcredin con los atributos seleccionados</param>
        Public Function altaCREDIN(ByVal parametro As ParamCredin) As tError

            Dim strSql As String = ""
            Dim cmd As tnvDBCommand = Nothing
            Dim param As ADODB.Parameter = Nothing
            Dim rs As ADODB.Recordset = Nothing
            Dim responseText As String = ""
            Dim id As Integer = 0


            Dim err As New tError
            Dim jsonParam As String = parametro.toJson()
            Dim url As String = parseUrl("ALTACREDIN")
            If (url = "") Then
                err.numError = -101
                err.mensaje = "variables de conexion no definidas correctamente"
                err.debug_desc = "verificar url ALTACREDIN"
                Return err
            End If


            Dim req As New nvHTTPRequest()
            req.url = url
            req.Method = "POST"
            req.time_out = -1
            req.Body = jsonParam
            req.ContentType = "application/json"
            req.ClientCertificate = _certs
            Try
                'strSql = "insert into  lausana_anexa..apibanking (fe_request,nro_operador,url,servicio,nro_entidad_consulta) values (getdate(),dbo.rm_nro_operador(),?,'ALTACREDIN',case when " & CStr(Me._nro_entidad_consulta) & "=0 then null else " & Me._nro_entidad_consulta & " end))" & vbCrLf
                'strSql &= "select @@identity as id"
                'cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                'param = cmd.CreateParameter("@url", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, url)
                'cmd.Parameters.Append(param)
                'rs = cmd.Execute()
                id = Me.gen_id_request(url, "ALTACREDIN")
                Dim paramLogsreq As New ParamLog(id, typeParam.param_request)
                    paramLogsreq.add("json", jsonParam)
                    paramLogsreq.save()



                strSql = "insert into  lausana_anexa..apibanking_log (id,tipo,parametro,valor) values (" & CStr(id) & ",'credin_request','parametrojson',?)" & vbCrLf
                cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                param = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, jsonParam)
                cmd.Parameters.Append(param)
                cmd.Execute()

                responseText = req.getResponseText()
                If (responseText Is Nothing OrElse responseText = String.Empty) AndAlso Not req.response_error Is Nothing Then
                    responseText = New IO.StreamReader(req.response_error.GetResponseStream()).ReadToEnd()
                    err.numError = -103
                    err.mensaje = "error al consultar"
                    err.debug_desc = responseText
                Else
                    If (responseText Is Nothing) Then
                        err.numError = -1
                        err.mensaje = "no se puede consultar al host " & url
                    Else
                        err = jsonto_terror(responseText)
                        If (err.params.ContainsKey("responseXML")) Then
                            Dim paramLogsresponse As New ParamLog(id, typeParam.param_response)
                            paramLogsresponse.saveXML(err.params("responseXML"))
                        End If
                    End If
                End If
                req = Nothing
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            err.params("responseText") = responseText
            strSql = "update lausana_anexa..apibanking set fe_response=getdate(),numError=" & CStr(err.numError) & "  where id=" & CStr(id) & vbCrLf
            strSql &= "insert into lausana_anexa..apibanking_log (id,tipo,parametro,valor) values(" & CStr(id) & ",'credin_response','terror',?)"
            cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
            param = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.get_error_xml())
            cmd.Parameters.Append(param)
            cmd.Execute()
            cmd = Nothing
            param = Nothing
            rs = Nothing
            err.params("id_request") = id
            Return err
        End Function

        Public Function gen_id_request(ByVal url As String, ByVal servicio As String) As Integer
            Dim id_request As Integer = 0
            Dim server_request As String = nvApp.getInstance().cod_servidor
            Dim strSql = "insert into  lausana_anexa..apibanking (fe_request,nro_operador,url,servicio,nro_entidad_consulta,server_request) values (getdate(),dbo.rm_nro_operador(),?,'" & servicio & "',case when " & CStr(Me._nro_entidad_consulta) & "=0 then null else " & Me._nro_entidad_consulta & " end,'" & server_request & "')" & vbCrLf
            strSql &= "select @@identity as id"
            Dim cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
            Dim param = cmd.CreateParameter("@url", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, url)
            cmd.Parameters.Append(param)
            Dim rs As ADODB.Recordset = cmd.Execute()
            If Not (rs.EOF) Then
                id_request = rs.Fields("id").Value
            End If
            Return id_request
        End Function


        Public Function parseUrl(ByVal serviceName As String) As String
            Dim url As String = ""
            If (Me._serverName <> "" And Me._urlbase <> "") Then
                If (Me._urlservices.ContainsKey(serviceName.ToUpper)) Then
                    url = Me._urlbase.Replace("<server_name>", Me._serverName) & Me._urlservices.Item(serviceName.ToUpper)
                End If
            End If
            Return url
        End Function
        ''' <summary>
        ''' valida si una cuenta especificada , es activa, en pesos ars y si es del titular especificando el cuit
        ''' </summary>
        ''' <param name="odic"><c>diccionario de datos</c> objeto que contiene la estructura a convertir a xml</param>
        Public Function parseStringToXml(ByVal odic As Dictionary(Of String, Object)) As String
            Dim xmlstr As String = ""
            For Each kvp As KeyValuePair(Of String, Object) In odic
                Dim clave As String = kvp.Key
                Dim valor As Object = kvp.Value
                xmlstr &= "<" & clave & ">"
                If TypeOf valor Is System.Collections.Generic.Dictionary(Of String, Object) Then
                    xmlstr &= Me.parseStringToXml(DirectCast(valor, Dictionary(Of String, Object)))
                End If
                If TypeOf valor Is System.Collections.ArrayList Then
                    Dim arr As ArrayList = TryCast(valor, ArrayList)
                    For i As Integer = 0 To arr.Count - 1
                        xmlstr &= "<" & clave & " id='" & CStr(i) & "'>"
                        xmlstr &= Me.parseStringToXml(DirectCast(arr(i), Dictionary(Of String, Object)))
                        xmlstr &= "</" & clave & ">"
                    Next
                End If
                If TypeOf valor Is String Then
                    xmlstr &= IIf(valor = "null", "", DirectCast(valor, String))
                End If
                xmlstr &= "</" & clave & ">"
            Next
            Return xmlstr
        End Function
        ''' <summary>
        ''' valida si una cuenta especificada , es activa, en pesos ars y si es del titular especificando el cuit
        ''' </summary>
        ''' <param name="nro_cuenta"><c>cuenta</c> cuenta cvu o cbu de 22 caraceres.</param>
        ''' <param name="cuit"><c>cuit</c> cuit del titular</param>
        ''' <param name="err"><c>terrorc> objeto donde se devuelven detalles de la busqueda</param>
        Public Function validacuentaARS(ByVal nro_cuenta As String, ByVal cuit As String, ByRef err As tError) As Boolean


            'err = New tError
            Dim strsql As String = ""
            Dim esvalido As Boolean = False

            If (nro_cuenta = "") Then
                err.numError = 11
                err.mensaje = "no se ingreso cuenta a consultar"
                reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="OTROS", motivo:=err.mensaje)
                Return esvalido
            End If

            If (cuit = "") Then
                err.numError = 12
                err.mensaje = "no se ingreso cuit a consultar"
                reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="OTROS", motivo:=err.mensaje)
                Return esvalido
            End If

            ''busco la cuenta en bases de lausana , con acreditaciones en los dos ultimos años
            strsql = "select top 1 * from verEntidad_bco_ctas c inner join pago_registro_detalle p on p.nro_pago_estado=2 and p.dep_id_cuenta=c.id_cuenta and c.habilitada=1 and p.fe_estado>  DATEADD(year,-2, getdate())" & vbCrLf
            strsql &= " where c.nro_cuenta= '" & nro_cuenta.Trim() & "' and c.cuit='" & cuit.Trim() & "'"
            Dim rs = nvDBUtiles.DBOpenRecordset(strsql)
            If Not (rs.EOF) Then
                esvalido = True
                err.mensaje = "encontrado por cuentas validas"
                err.titulo = "consulta ok"
                err.params("tipo_consulta") = 1
                reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=1, origen:="BASE_NOVA", motivo:="cuenta con acreditación anterior")
            End If
            ''busco la relacion cuenta, en las consultas logs de al api,que pertenezca al titular, y la misma , esté activa y no sean cuentas en dolares
            If Not (esvalido) Then
                strsql = "select top 1 l.id,rtrim(ltrim(cast(p2.valor as varchar(20)))) as cuit_titular,rtrim(ltrim(cast(p3.valor as varchar(10)))) as estado_cuenta, case when cast(p4.valor as varchar(10)) in ('10','20','30') then 1 else 0 end as cta_ars,cast(p4.valor as varchar(10)) as tipo_cuenta,rtrim(ltrim(cast(p5.valor as varchar(1000)))) as descripcion  from lausana_anexa..apibanking_log l join lausana_anexa..apibanking_parametros p1 On p1.id= l.id And p1.nombre ='cbu'" & vbCrLf
                ''strsql &= " join lausana_anexa..apibanking_parametros p2 on p2.id=l.id and p2.nombre='titular/cuit'" & vbCrLf
                strsql &= " join lausana_anexa..apibanking_parametros p2 on p2.id=l.id and p2.nombre like 'titular%cuit'" & vbCrLf
                strsql &= " join lausana_anexa..apibanking_parametros p3 on p3.id=l.id and p3.nombre='cuenta/cta_activa'" & vbCrLf
                strsql &= " join lausana_anexa..apibanking_parametros p4 on p4.id=l.id and p4.nombre='cuenta/tipo_cta'" & vbCrLf
                strsql &= " join lausana_anexa..apibanking_parametros p5 on p5.id=l.id And p5.nombre='respuesta/descripcion'" & vbCrLf
                strsql &= " join lausana_anexa..apibanking b on b.id=l.id And b.servicio='CONSULTACBU' " & vbCrLf
                strsql &= " where l.tipo='cbu_response' and  cast(p1.valor as varchar(50))='" & nro_cuenta.Trim() & "'  and b.numError=0 order by b.fe_response desc" & vbCrLf
                ''strsql &= " where l.tipo='cbu_response' and  cast(p1.valor as varchar(50))='" & nro_cuenta.Trim() & "'  and cast(p2.valor as varchar(50))='" & cuit.Trim() & "' and cast(p3.valor as varchar(10))='true' and cast(p4.valor as varchar(10)) not in (11,21,31) " & vbCrLf
                rs = nvDBUtiles.DBOpenRecordset(strsql)
                If Not (rs.EOF) Then
                    Dim mensaje As String = ""
                    err.params("id_last_response") = rs.Fields("id").Value
                    Dim cuit_titular As Boolean = rs.Fields("cuit_titular").Value = cuit.Trim()

                    If Not (cuit_titular) And rs.Fields("cuit_titular").Value <> "" Then
                        mensaje &= " El CBU ingresado corresponde a otra persona."
                        reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="BASE_API", motivo:=" El CBU ingresado corresponde a otra persona.")
                    End If
                    Dim estado_cuenta As Boolean = rs.Fields("estado_cuenta").Value = "true"
                    If Not (estado_cuenta) Then
                        mensaje &= " La cuenta no está habilitada :" & rs.Fields("descripcion").Value & "."
                        reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="BASE_API", motivo:=" La cuenta consultada no está habilitada")
                    End If

                    Dim cta_ars As Boolean = rs.Fields("cta_ars").Value = "1"
                    If Not (cta_ars) And rs.Fields("tipo_cuenta").Value <> "" Then
                        mensaje &= " Ingresó una CA en Dolares - NO valida para esta Gestión"
                        reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="BASE_API", motivo:=" Ingresó una CA en Dolares - NO valida para esta Gestión")
                    End If

                    If (cuit_titular And estado_cuenta And mensaje = "") Then
                        esvalido = True
                        err.mensaje = "encontrado por consulta api anteriores"
                        err.titulo = "consulta ok"
                        reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=1, origen:="BASE_API", motivo:="cuenta consultada con anterioridad")
                    End If
                    If (mensaje <> "") Then
                        err.numError = 5
                        err.mensaje = mensaje
                        err.titulo = "Error"
                        ''reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="OTROS", motivo:=mensaje)
                    End If


                    err.params("tipo_consulta") = 2
                        'Return esvalido
                    End If
                End If
            ''si no es valida, consulto recien en la api
            If Not (esvalido) And err.numError = 0 Then
                If (_contingencia) Then
                    esvalido = False
                    err.mensaje = "Servicio de contingencia activo"
                    err.titulo = "Cbu no validada"
                    err.numError = -100
                    err.params("tipo_consulta") = -100
                    Return esvalido
                End If
                err = consultarCBU(nro_cuenta.Trim())
                If (err.numError = 0 And err.params.ContainsKey("id_request")) Then
                    ''si el servicio respondió, verifico que la cuenta esté activa y sea del titular, si eso sucede, es valida
                    Dim id_request As String = err.params("id_request")
                    ''strsql = "select p1.*  from  lausana_anexa..apibanking_parametros p1 inner join lausana_anexa..apibanking_parametros p2 on p1.id=p2.id and p1.nombre='cuenta/nro_cbu' and p2.nombre='titular/cuit' and p1.tipo=p2.tipo and p1.tipo='response'" & vbCrLf
                    strsql = "select p1.*  from  lausana_anexa..apibanking_parametros p1 inner join lausana_anexa..apibanking_parametros p2 on p1.id=p2.id and p1.nombre='cuenta/nro_cbu' and p2.nombre like 'titular%cuit' and p1.tipo=p2.tipo and p1.tipo='response'" & vbCrLf
                    strsql &= " inner join lausana_anexa..apibanking_parametros p3 on p1.id=p3.id  and p3.tipo='response' and p3.nombre='cuenta/cta_activa' " & vbCrLf
                    strsql &= " inner join lausana_anexa..apibanking_parametros p4 On p1.id= p4.id And  p4.nombre='cuenta/tipo_cta' and p1.tipo=p4.tipo " & vbCrLf
                    strsql &= " where cast(p1.valor as varchar(50))='" & nro_cuenta.Trim() & "' and cast(p2.valor as varchar(50))='" & cuit.Trim() & "' and  cast(p3.valor as varchar(10))='true' and cast(p4.valor as varchar(10)) not in('11','21','31')   and p1.id=" & id_request & vbCrLf
                    rs = nvDBUtiles.DBOpenRecordset(strsql)
                    If Not (rs.EOF) Then
                        esvalido = True
                        err.mensaje = "cuenta ARS activa del titular"
                        err.titulo = "consulta ok"
                        err.params("tipo_consulta") = 3
                        reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=1, origen:="API_ONLINE", motivo:="cuenta ARS activa del titular")
                    Else
                        ''verifico si la cuenta consultada recientemente a la api, no pertenece al titular
                        strsql = "select p1.*  from  lausana_anexa..apibanking_parametros p1 inner join lausana_anexa..apibanking_parametros p2 on p1.id=p2.id and p1.nombre='cuenta/nro_cbu' and p2.nombre like 'titular%cuit' and p1.tipo=p2.tipo and p1.tipo='response'"
                        strsql &= " where cast(p1.valor as varchar(50))='" & nro_cuenta.Trim() & "' and cast(p2.valor as varchar(20))<>'" & cuit.Trim() & "' and p1.id=" & id_request & vbCrLf
                        rs = nvDBUtiles.DBOpenRecordset(strsql)
                        If Not (rs.EOF) Then
                            err.numError = 1
                            err.mensaje = "El CBU ingresado corresponde a otra persona"
                            err.titulo = "Error"
                            reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="API_ONLINE", motivo:="El CBU ingresado corresponde a otra persona")
                        End If
                        ''verifico si la cuenta consultada recientemente a la api, es activa o no existe
                        If (err.numError = 0) Then
                            strsql = "select p3.*  from  lausana_anexa..apibanking_parametros p1 inner join lausana_anexa..apibanking_parametros p2 on p1.id=p2.id and p1.nombre='cbu' and p2.nombre='cuenta/cta_activa' and p1.tipo=p2.tipo and p1.tipo='response'" & vbCrLf
                            strsql &= " inner join lausana_anexa..apibanking_parametros p3 on p1.id=p3.id and p3.nombre='respuesta/descripcion'"
                            strsql &= " where cast(p1.valor as varchar(50))='" & nro_cuenta.Trim() & "' and cast(p2.valor as varchar(10))<>'true' and p1.id=" & id_request & vbCrLf
                            rs = nvDBUtiles.DBOpenRecordset(strsql)
                            If Not (rs.EOF) Then
                                err.numError = 2
                                err.mensaje = rs.Fields("valor").Value
                                err.titulo = "cuenta no activa o no existe"
                                reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="API_ONLINE", motivo:="cuenta no activa o no existe")
                            End If
                        End If
                        ''verifico si la cuenta consultada recientemente a la api, es en dolares
                        If (err.numError = 0) Then
                            strsql = "select p2.*  from  lausana_anexa..apibanking_parametros p1 inner join lausana_anexa..apibanking_parametros p2 on p1.id=p2.id and p1.nombre='cbu' and p2.nombre='cuenta/tipo_cta' and p1.tipo=p2.tipo and p1.tipo='response'" & vbCrLf
                            strsql &= " where cast(p1.valor as varchar(50))='" & nro_cuenta.Trim() & "' and cast(p2.valor as varchar(10)) in('11','21','31') and p1.id=" & id_request & vbCrLf
                            rs = nvDBUtiles.DBOpenRecordset(strsql)
                            If Not (rs.EOF) Then
                                err.numError = 3
                                err.mensaje = "Ingresó una CA en Dolares - NO válida para esta Gestión"
                                err.titulo = "Error"
                                reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="API_ONLINE", motivo:="Ingresó una CA en Dolares - NO válida para esta Gestión")
                            End If
                        End If
                        ''si no se puedo encontrar la causa de la titularidad o no de la cuetan
                        If (err.numError = 0) Then
                            err.numError = 99
                            err.mensaje = "No se pudo determinar la titularidad de la cuenta"
                            err.titulo = "Error"
                            reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="API_ONLINE", motivo:="No se pudo determinar la titularidad de la cuenta")
                        End If
                    End If
                    ''cuenta activa o inactiva
                    ''cuenta no pertenece al titular
                    ''cuenta no es valida para cuenta en pesos ars
                Else
                    Dim mensaje As String = IIf(err.mensaje.Trim() = "", "Problemas en el servicio. Si el problema persiste, consulte con sistemas.", err.mensaje.Trim())
                    If (err.params.ContainsKey("id_request")) Then
                        mensaje &= " (" & err.params("id_request") & ")"
                    End If
                    err.mensaje = mensaje
                    reg_validacion_cuenta(cuit:=cuit, nro_cuenta:=nro_cuenta, validado:=0, origen:="API_ONLINE", motivo:=mensaje)
                End If
            End If
            Return esvalido
        End Function

        Private Sub reg_validacion_cuenta(ByVal cuit As String, ByVal nro_cuenta As String, ByVal validado As Boolean, ByVal origen As String, ByVal motivo As String)

            Dim strSql As String = "INSERT INTO lausana_anexa.dbo.apibanking_cuenta_validacion_log (cuit,nro_cuenta,momento,nro_operador,validado,origen,motivo) "
            strSql &= " VALUES ('" & cuit & "','" & nro_cuenta & "',getdate(),dbo.rm_nro_operador()," & IIf(validado, "1", "0") & ",'" & origen & "',?)"
            Dim cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
            Dim param = cmd.CreateParameter("@motivo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, motivo)
            cmd.Parameters.Append(param)
            cmd.Execute()
            cmd = Nothing
        End Sub

        Public Enum typeParam
            param_request = 1
            param_response = 2
        End Enum
        Public Class ParamLog
            Private _tipo As Integer
            Private _params As New Dictionary(Of String, String)
            Private _id As Integer = 0
            Public Sub add(ByVal nombre As String, ByVal valor As String)
                _params.Add(nombre, valor)
            End Sub
            Public Function toStr() As String
                Dim ret As String = ""
                Select Case Me._tipo
                    Case typeParam.param_request
                        ret = "request"
                    Case typeParam.param_response
                        ret = "response"
                    Case Else
                        ret = "other"
                End Select
                Return ret
            End Function
            Public Sub New(ByVal id As Integer, ByVal tipo As Integer)
                Me._tipo = tipo
                Me._id = id
            End Sub
            Public Sub save()
                Dim strSql As String = ""
                Dim tipostring As String = Me.toStr()
                For Each kvp As KeyValuePair(Of String, String) In Me._params
                    strSql = "insert into lausana_anexa..apibanking_parametros (id, nombre, tipo, valor) values(" & CStr(Me._id) & ",?,'" & tipostring & "',?)"
                    Dim cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                    Dim param1 = cmd.CreateParameter("@key", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, kvp.Key.Trim())
                    cmd.Parameters.Append(param1)
                    Dim param2 = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, kvp.Value.Trim())
                    cmd.Parameters.Append(param2)
                    cmd.Execute()
                    cmd = Nothing
                Next

            End Sub
            Public Sub saveXML(ByVal xmlText As String)
                Dim dicParams As New Dictionary(Of String, String)
                Try
                    ''Dim xmltext As String = "<response><cbu>3120001901000110002599</cbu><respuesta><codigo>0170</codigo><descripcion>CBU ENCONTRADO Y CUENTA ACTIVA, PERO NO TIENE ALIAS ASIGNADO</descripcion></respuesta><titular><tipo_persona>J</tipo_persona><cuit>30546741636</cuit><nombre>BANCO VOII S.A.</nombre></titular><cuenta><tipo_cta>20</tipo_cta><nro_cbu_anterior></nro_cbu_anterior><nro_bco>312</nro_bco><cta_activa>true</cta_activa><nro_cbu>3120001901000110002599</nro_cbu></cuenta><transac>9761765</transac><reasigna></reasigna></response>"
                    Dim xml As New System.Xml.XmlDocument()
                    xml.LoadXml(xmlText)
                    ''Me.ValueNodesToDictionary(xml, dicParams)
                    Me.ParseNodesToDictionary(xml, dicParams)

                Catch ex As Exception
                End Try
                If (dicParams.Count > 0) Then
                    Me._params = dicParams
                    Me.save()
                End If
                dicParams = Nothing
            End Sub

            Private Sub ValueNodesToDictionary(ByVal xmldoc As System.Xml.XmlDocument, ByRef odic As Dictionary(Of String, String), Optional ByVal nodepath As String = "*")
                Try
                    For Each node As XmlNode In xmldoc.DocumentElement.SelectNodes(nodepath)
                        If (node.ChildNodes().Count > 1) Then

                            For Each nodes As XmlNode In node.ChildNodes()
                                ''Dim pathroot As String = IIf(nodepath = "*", "./" & node.Name & "/" & nodes.Name, nodepath & "/" & node.Name & "/" & nodes.Name)
                                Dim pathroot As String = IIf(nodepath = "*", "./" & node.Name & "/" & nodes.Name, nodepath & "/" & nodes.Name)
                                Me.ValueNodesToDictionary(xmldoc, odic, pathroot)
                            Next
                        Else
                            Dim paramName As String = IIf(nodepath = "*", "" & node.Name, nodepath)
                            paramName = paramName.Replace("./", "")
                            If (node.ChildNodes().Count = 1) Then
                                Dim pathroot As String = IIf(nodepath = "*", "./" & node.Name & "/" & node.ChildNodes()(0).Name, nodepath & "/" & node.ChildNodes()(0).Name)
                                Me.ValueNodesToDictionary(xmldoc, odic, pathroot)
                            Else
                                ''por si la clave ya existe, le voy agregando subindices
                                Dim indexKey As Integer = 0
                                Dim paramkey = paramName
                                While (odic.ContainsKey(paramkey))
                                    indexKey += 1
                                    paramkey = paramName & "(" & CStr(indexKey) & ")"
                                End While
                                odic.Add(paramkey, node.InnerText)
                            End If

                        End If
                    Next
                Catch ex As Exception
                End Try
            End Sub

            Private Sub ParseNodesToDictionary(ByVal xmldoc As System.Xml.XmlDocument, ByRef odic As Dictionary(Of String, String), Optional ByVal nodepath As String = "*", Optional ByRef attributes As String = "")
                If (attributes <> "") Then
                    nodepath = nodepath.Replace("/*", attributes & "/*")
                End If
                For Each node As XmlNode In xmldoc.DocumentElement.SelectNodes(nodepath)
                    Dim addnodo As Boolean = False
                    Dim valornodo As String = ""
                    If (node.ChildNodes.Count = 0) Then
                        addnodo = True
                    End If

                    If (node.Attributes.Count > 0) Then
                        For Each atr As XmlAttribute In node.Attributes
                            attributes &= "[@" & atr.Name & "='" & atr.Value & "']"
                        Next
                    End If
                    If (Not addnodo) Then
                        If Not (node.ChildNodes.Count = 1 And node.FirstChild.Name = "#text") Then
                            Dim pathroot As String = IIf(nodepath = "*", "./" & node.Name & "/*", nodepath.Replace("/*", "") & "/" & node.Name & "/*")
                            Me.ParseNodesToDictionary(xmldoc, odic, pathroot, attributes)
                        Else
                            addnodo = True
                            valornodo = node.InnerText
                        End If
                    End If

                    If (addnodo) Then
                        Dim paramName As String = IIf(nodepath = "*", node.Name, nodepath.Replace("/*", "") & "/" & node.Name)
                        paramName = paramName.Replace("./", "")
                        paramName = paramName.Replace("/*", "")
                        ''por si la clave ya existe, le voy agregando subindices
                        Dim indexKey As Integer = 0
                        Dim paramkey = paramName
                        While (odic.ContainsKey(paramkey))
                            indexKey += 1
                            paramkey = paramName & "(" & CStr(indexKey) & ")"
                        End While
                        odic.Add(paramkey, node.InnerText)
                    End If
                Next
                attributes = ""
            End Sub


        End Class


    End Class

    Public Class ParamCredin
        Public credito As New tCredito
        Public ClienteId As String = ""
        Public debito As New tDebito
        Public concepto As String = ""
        Public idUsuario As Integer = 0
        Public idComprobante As Integer = 0
        Public importe As Decimal
        Public moneda As String = ""
        Public mismo_titutar As String = ""
        Public datosGenerador As New tDatosGenerador
        Public valor As String

        Public Structure tCredito
            Dim cbu As String
            Dim banco As String
            Dim sucursal As String
            Dim cuit As String
            Dim titular As String
        End Structure

        Public Structure tDebito
            Dim cuit As String
            Dim cbu As String
            Dim banco As String
            Dim sucursal As String
            Dim titular As String
        End Structure

        Public Structure tDatosGenerador
            Dim ipCliente As String
            Dim tipoDispositivo As String
            Dim plataforma As String
            Dim imsi As String
            Dim imei As String
            Dim titular As String
            Dim lat As Decimal
            Dim lng As Decimal
            Dim precision As String
        End Structure
        Public Sub New()
            credito.sucursal = "0000"
            moneda = "032"
            mismo_titutar = "0"
            datosGenerador.lat = 0
            datosGenerador.lng = 0
        End Sub
        Public Function toJson() As String
            Dim strJson As String = ""
            strJson &= "{"
            strJson &= """credito"":{""cbu"":""" & Me.credito.cbu & """,""banco"":""" & Me.credito.banco & """,""sucursal"":""" & Me.credito.sucursal & """,""cuit"":""" & Me.credito.cuit & """,""titular"":""" & Me.credito.titular & """},"
            strJson &= """ClienteId"":""" & Me.ClienteId & ""","
            strJson &= """debito"":{""cuit"":""" & Me.debito.cuit & """,""cbu"":""" & Me.debito.cbu & """,""banco"":""" & Me.debito.banco & """,""sucursal"":""" & Me.debito.sucursal & """,""titular"":""" & Me.debito.titular & """},"
            strJson &= """concepto"":""" & Me.concepto & ""","
            strJson &= """idUsuario"":" & CStr(Me.idUsuario) & ","
            strJson &= """idComprobante"":" & CStr(Me.idComprobante) & ","
            strJson &= """importe"":" & CStr(Me.importe) & ","
            strJson &= """moneda"":""" & CStr(Me.moneda) & ""","
            strJson &= """mismoTitular"":""" & Me.mismo_titutar & ""","
            strJson &= """datosGenerador"":{""ipCliente"":""" & Me.datosGenerador.ipCliente & """,""tipoDispositivo"":""" & Me.datosGenerador.tipoDispositivo & """,""plataforma"":""" & Me.datosGenerador.plataforma & """,""imsi"":""" & Me.datosGenerador.imsi & """,""imei"":""" & Me.datosGenerador.imei & """,""lat"":""" & CStr(Me.datosGenerador.lat) & """,""lng"":""" & CStr(Me.datosGenerador.lng) & """,""precision"":""" & CStr(Me.datosGenerador.precision) & """}"
            strJson &= "}"
            Return strJson
        End Function
    End Class
End Namespace