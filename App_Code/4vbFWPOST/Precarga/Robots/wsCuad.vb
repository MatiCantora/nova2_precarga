Imports System.IO
Imports System.IO.Compression
Imports System.Net
Imports nvFW.servicios.Robots
Namespace nvFW.servicios.Robots
    Public Class wsCuad

        Private _url As String = "http://172.16.25.10:8080/WsACUAD.asmx"
        Private _callback As String = ""
        Private _procesos As New Dictionary(Of Integer, RequestID)
        Private _timeoutcupo As Integer = 120000
        Private _timeoutconsumo As Integer = 1000 * 60 * 15 '15 minutos


        Public Function GetCupoScreen(ByVal credencial As wsCredencial, ByVal Scu_Id As Integer, ByVal Sce_Id As Integer, ByVal Scm_Id As Integer, ByVal clave_sueldo As String, ByVal prioridad As Integer) As nvFW.tError
            Dim err As New tError
            Dim strSQL As String = "insert into lausana_anexa..cuad_robot (fe_creacion,nro_operador,servicio) values(getdate(),dbo.rm_nro_operador(),'WsGetCupoScreen')" & vbCrLf
            strSQL &= "select @@identity as id"
            Dim rs = nvDBUtiles.DBOpenRecordset(strSQL)
            Dim id As Integer = CInt(rs.Fields("id").Value)
            nvDBUtiles.DBCloseRecordset(rs)
            Dim cod_acceso As String = get_hash(CInt(id))
            Dim UrlCallBack As String = Me._callback & "?cod_acceso=" & cod_acceso
            strSQL = ""
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'Scu_Id','" & CStr(Scu_Id) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'Sce_Id','" & CStr(Sce_Id) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'Scm_Id','" & CStr(Scm_Id) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'clave_sueldo','" & clave_sueldo & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'prioridad','" & CStr(prioridad) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'callback','" & UrlCallBack & "','request')" & vbCrLf
            nvDBUtiles.DBExecute(strSQL)

            Dim async_thread As System.Threading.Thread = New System.Threading.Thread(Sub(psp As Object)

                                                                                          nvFW.nvApp._nvApp_ThreadStatic = psp("instancia")
                                                                                          Dim log_id As Integer = psp("id")
                                                                                          Dim huborespuesta As Boolean = False
                                                                                          While Not huborespuesta
                                                                                              ''averigo cada 400ms si hay respuesta por parte de cuad
                                                                                              Dim rs1 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from lausana_anexa..cuad_robot where id=" & CStr(log_id) & " and fe_respuesta is not null")
                                                                                              If Not (rs1.EOF) Then
                                                                                                  Dim xmlresponse As String = rs1.Fields("xmlresponse").Value
                                                                                                  huborespuesta = True
                                                                                                  Dim errresponse As New tError
                                                                                                  Try
                                                                                                      errresponse.loadXML(xmlresponse)
                                                                                                      onFinishResponse(log_id, errresponse)
                                                                                                  Catch ex As Exception
                                                                                                      errresponse.parse_error_script(ex)
                                                                                                      onErrorResponse(log_id, errresponse)
                                                                                                  End Try
                                                                                                  ' errresponse.clear()
                                                                                                  xmlresponse = Nothing
                                                                                              End If
                                                                                              If (Not huborespuesta) Then
                                                                                                  System.Threading.Thread.Sleep(400)
                                                                                              End If
                                                                                          End While
                                                                                      End Sub)


            Try
                Dim errRequest As New tError
                Dim instancia = nvApp.getInstance()
                onInitRequest(id)
                Dim soapCli As New WsACUAD.WsACUADSoapClient
                Dim xmlrespuesta As String = soapCli.WsGetCupoScreen(Usuario:=credencial.usuario, Password:=credencial.pwd, UrlCallBack:=UrlCallBack, Scu_Id:=Scu_Id, Sce_Id:=Sce_Id, Scm_Id:=Scm_Id, clave_sueldo:=clave_sueldo, prioridad:=prioridad)
                soapCli.Close()
                errRequest.loadXML(xmlrespuesta)
                If (errRequest.numError = 0) Then
                    Dim timeout As Integer = Me._timeoutcupo / 1000 'segundos
                    Dim ini As Date = Microsoft.VisualBasic.DateAndTime.Now
                    Dim parametro As New Dictionary(Of String, Object)
                    parametro.Add("id", id)
                    parametro.Add("instancia", instancia)
                    async_thread.Start(parametro)
                    While Not process_finished(id) And Microsoft.VisualBasic.DateAndTime.Now < Microsoft.VisualBasic.DateAndTime.DateAdd(DateInterval.Second, timeout, ini)
                        System.Threading.Thread.CurrentThread.Sleep(500)
                    End While
                    If (async_thread.IsAlive) Then
                        async_thread.Abort()
                        If Not (process_finished(id)) Then
                            err.numError = 1000
                            err.mensaje = "timeout"
                        Else
                            err = Me._procesos(id).terror
                        End If
                    Else
                        err = Me._procesos(id).terror
                    End If
                    async_thread = Nothing
                Else
                    err = errRequest
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                onErrorResponse(id, err)
            End Try
            Return err
        End Function



        Public Function GetCupo(ByVal credencial As wsCredencial, ByVal Scu_Id As Integer, ByVal Sce_Id As Integer, ByVal Scm_Id As Integer, ByVal clave_sueldo As String, ByVal prioridad As Integer, ByVal periodo_desc As String) As nvFW.tError

            Dim err As New tError
            Dim strSQL As String = "insert into lausana_anexa..cuad_robot (fe_creacion,nro_operador,servicio) values(getdate(),dbo.rm_nro_operador(),'WsGetCupo')" & vbCrLf
            strSQL &= "select @@identity as id"
            Dim rs = nvDBUtiles.DBOpenRecordset(strSQL)
            Dim id As Integer = CInt(rs.Fields("id").Value)
            nvDBUtiles.DBCloseRecordset(rs)
            Dim cod_acceso As String = get_hash(CInt(id))
            Dim UrlCallBack As String = Me._callback & "?cod_acceso=" & cod_acceso
            strSQL = ""
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'Scu_Id','" & CStr(Scu_Id) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'Sce_Id','" & CStr(Sce_Id) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'Scm_Id','" & CStr(Scm_Id) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'clave_sueldo','" & clave_sueldo & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'prioridad','" & CStr(prioridad) & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros(id,parametro,valor,tipo) values(" & CStr(id) & ",'periodo_desc','" & periodo_desc & "','request')" & vbCrLf
            strSQL &= "insert into lausana_anexa..cuad_robot_parametros (id,parametro,valor,tipo) values(" & CStr(id) & ",'callback','" & UrlCallBack & "','request')" & vbCrLf
            nvDBUtiles.DBExecute(strSQL)

            Try
                Dim errRequest As New tError
                'Dim instancia = nvApp.getInstance()
                onInitRequest(id)
                Dim soapCli As New WsACUAD.WsACUADSoapClient
                Dim xmlrespuesta As String = soapCli.WsGetCupo(Usuario:=credencial.usuario, Password:=credencial.pwd, UrlCallBack:=UrlCallBack, Scu_Id:=Scu_Id, Sce_Id:=Sce_Id, Scm_Id:=Scm_Id, clave_sueldo:=clave_sueldo, prioridad:=prioridad, periodo_desc:=periodo_desc)
                soapCli.Close()
                errRequest.loadXML(xmlrespuesta)
                If (errRequest.numError = 0) Then
                    Dim timeout As Integer = 30000 / 1000 'segundos
                    Dim ini As Date = Microsoft.VisualBasic.DateAndTime.Now

                    Dim log_id As Integer = id
                    Dim huborespuesta As Boolean = False

                    While Not huborespuesta AndAlso Microsoft.VisualBasic.DateAndTime.Now < Microsoft.VisualBasic.DateAndTime.DateAdd(DateInterval.Second, timeout, ini)
                        Try
                            ''averigo cada 400ms si hay respuesta por parte de cuad
                            Dim rs1 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select xmlresponse from lausana_anexa..cuad_robot where id=" & CStr(log_id) & " and fe_respuesta is not null")
                            If Not (rs1.EOF) Then
                                Dim xmlresponse As String = rs1.Fields("xmlresponse").Value
                                huborespuesta = True
                                Try
                                    err.loadXML(xmlresponse)
                                    onFinishResponse(log_id, err)
                                Catch ex As Exception
                                    err.parse_error_script(ex)
                                    onErrorResponse(log_id, err)
                                End Try

                                xmlresponse = Nothing
                            End If
                            nvDBUtiles.DBCloseRecordset(rs1)
                            If (Not huborespuesta) Then
                                System.Threading.Thread.Sleep(400)
                            End If
                        Catch ex As Exception
                            onErrorResponse(log_id, err)
                            Exit While
                        End Try
                    End While

                    If Not huborespuesta Then
                        err.numError = 1000
                        err.mensaje = "timeout"
                    End If

                Else
                    err = errRequest
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                onErrorResponse(id, err)
            End Try
            Return err
        End Function



        ''' <summary>
        ''' dada la clave de sueldo, consulta el estado de un consumo 
        '''Retorna un XML con el resultado (0->éxito y en el contenido va la respuesta de la solicitud con su contenido completo; -1->solicitud no encontrada; -2 -> solicitud en proceso; -3 -> solicitud finalizada con error; -4 -> parámetros incorrectos; -5 -> error no definido)
        ''' </summary>
        ''' <param name="cod_acceso"><c>codigo de acceso</c>codigo de la consulta con la que se hizo el consumo</param>
        Public Function StatusConsumo(ByVal credencial As wsCredencial, ByVal cod_acceso As String, Optional errParams As tError = Nothing) As nvFW.tError
            Dim err As New tError
            Dim id As Integer = 0
            Dim UrlCallBack As String = ""
            Dim clave_sueldo As String = ""
            Dim rs = nvDBUtiles.DBOpenRecordset("select p.valor as urlcallback,pclave.valor as clave_sueldo  from lausana_anexa..cuad_robot c join  lausana_anexa..cuad_robot_parametros p on c.id=p.id join  lausana_anexa..cuad_robot_parametros pclave on c.id=pclave.id where c.cod_acceso='" & cod_acceso & "' and p.parametro='callback' and p.tipo='request' and pclave.parametro='clave_sueldo' and pclave.tipo='request'")
            If Not (rs.EOF) Then
                UrlCallBack = rs.Fields("urlcallback").Value
                clave_sueldo = rs.Fields("clave_sueldo").Value
            Else
                err.numError = -99
                err.mensaje = "no se puede determinar si el consumo se hizo o no"
            End If
            If (UrlCallBack <> "" And clave_sueldo <> "") Then
                Try
                    Dim errRequest As New tError
                    Dim soapCli As New WsACUAD.WsACUADSoapClient
                    Dim xmlrespuesta As String = soapCli.WsGetRespuestaXMLSolicitud(Usuario:=credencial.usuario, Password:=credencial.pwd, UrlCallBack:=UrlCallBack, clave_sueldo:=clave_sueldo)
                    soapCli.Close()
                    errRequest.loadXML(xmlrespuesta)
                    err = errRequest
                    err.params.Add("xmlrespuesta", xmlrespuesta)
                    xmlrespuesta = Nothing
                    'errRequest.clear()
                    ''err.params("xmlrespuesta") = xmlrespuesta
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
            Else
                err.numError = -100
                err.mensaje = "No se pudo realizar la carga en cuad. Intente nuevamente"
                err.debug_desc = "Problemas en nova antes de realizar el consumo en cuad .  Falta parametros necesarios en nova para realizar el consumo"
                err.titulo = "El consumo no se pudo realizar"
            End If

            Return err
        End Function


        ''destructor
        Protected Overrides Sub Finalize()
            ''Console.WriteLine("Out..")
        End Sub

        Public Function AltaConsumoCredito(ByVal credencial As wsCredencial, ByVal parametrosrobot As Dictionary(Of String, String), ByVal parametroscredito As Dictionary(Of String, String)) As tError
            Dim err As New tError
            Dim id As Integer = 0
            Dim consumo_log_id As String = "0"
            Dim UrlCallBack As String = ""
            ''paso 1: genero la relacion credito, id motor calificacion
            Dim strSQL As String = "INSERT INTO CUAD_motor_calificacion ([id_transf_log],[nro_credito],[estado],[fecha],[nro_operador],[xml]) VALUES (" & parametroscredito("id_transf_log") & "," & parametroscredito("nro_credito") & ",'" & parametroscredito("estado") & "',getdate(),dbo.rm_nro_operador(),?)" & vbCrLf
            strSQL = strSQL & "select @@identity as id "
            Try
                Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
                Dim parametersSql = cmd.CreateParameter("@xml", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, parametroscredito("xmlmotorparametros"))
                cmd.Parameters.Append(parametersSql)
                Dim rs = cmd.Execute()
                Dim id_motor_califacion As String = "0"
                id_motor_califacion = rs.Fields("id").Value
                strSQL = ""
                strSQL = " declare @id As Integer " & vbCrLf
                strSQL &= "insert into lausana_anexa..cuad_robot (fe_creacion,nro_operador,servicio) values(getdate(),dbo.rm_nro_operador(),'WsAltaConsumoDirecto') " & vbCrLf
                strSQL &= "set @id=@@identity " & vbCrLf
                strSQL &= "update  CUAD_motor_calificacion set consumo_log_id=@id where id=" & id_motor_califacion & vbCrLf
                strSQL &= "select  @id as id"
                rs = nvDBUtiles.DBOpenRecordset(strSQL)
                id = CInt(rs.Fields("id").Value)
                consumo_log_id = CStr(id)
                nvDBUtiles.DBCloseRecordset(rs)
                Dim cod_acceso As String = get_hash(CInt(id))
                UrlCallBack = Me._callback & "?cod_acceso=" & cod_acceso
                strSQL = ""
                For Each kvp As KeyValuePair(Of String, String) In parametrosrobot
                    strSQL &= "insert into lausana_anexa..cuad_robot_parametros (id,parametro,valor,tipo) values(" & CStr(id) & ",'" & kvp.Key & "','" & kvp.Value & "','request')" & vbCrLf
                Next
                strSQL &= "insert into lausana_anexa..cuad_robot_parametros (id,parametro,valor,tipo) values(" & CStr(id) & ",'callback','" & UrlCallBack & "','request')" & vbCrLf
                nvDBUtiles.DBExecute(strSQL)
                strSQL = ""
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            If (id <= 0) Then
                err.numError = -99
                err.mensaje = "No se pudo generar el consumo. No se realizo carga en cuad. Intente nuevamente"
                Return err
            End If

            Try
                Dim errRequest As New tError
                onInitRequest(id)
                Dim soapCli As New WsACUAD.WsACUADSoapClient
                Dim response As String = soapCli.WsAltaConsumoDirecto(Usuario:=credencial.usuario, Password:=credencial.pwd, UrlCallBack:=UrlCallBack, Scu_Id:=parametrosrobot("Scu_Id"), Sce_Id:=parametrosrobot("Sce_Id"), Scm_Id:=parametrosrobot("Scm_Id"), Clave_Sueldo:=parametrosrobot("Clave_Sueldo"), Nro_Documento:=parametrosrobot("Nro_Documento"), Prioridad:=parametrosrobot("Prioridad"), Ses_Id:=parametrosrobot("Ses_Id"), Cuotas:=parametrosrobot("Cuotas"), Importe:=parametrosrobot("Importe"), Primer_Venc:=parametrosrobot("Primer_Venc"), Categoria_Socio:=parametrosrobot("Categoria_Socio"), Clave_Servicio:=parametrosrobot("Clave_Servicio"), Comentario:=parametrosrobot("Comentario"))
                soapCli.Close()
                errRequest.loadXML(response)
                response = Nothing
                If (errRequest.numError = 0) Then
                    Dim timeoutms As Integer = _timeoutconsumo
                    Dim ini As Date = Microsoft.VisualBasic.DateAndTime.Now
                    Dim sleepms As Integer = 500
                    Dim log_id As Integer = id
                    Dim huborespuesta As Boolean = False
                    While Not huborespuesta AndAlso timeoutms > 0
                        Try
                            ''averigo cada 500ms si hay respuesta por parte de cuad
                            Dim rs1 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select xmlresponse from lausana_anexa..cuad_robot where id=" & CStr(log_id) & " and fe_respuesta is not null")
                            If Not (rs1.EOF) Then
                                Dim errresponse As New tError
                                Try
                                    Dim xmlresponse As String = rs1.Fields("xmlresponse").Value
                                    huborespuesta = True
                                    err.loadXML(xmlresponse)
                                    onFinishResponse(log_id, err)
                                    xmlresponse = Nothing
                                Catch ex As Exception
                                    err.parse_error_script(ex)
                                    onErrorResponse(log_id, err)
                                End Try

                            End If
                            nvDBUtiles.DBCloseRecordset(rs1)
                            If (Not huborespuesta) Then
                                System.Threading.Thread.Sleep(500)
                                timeoutms = timeoutms - sleepms
                            End If
                        Catch ex As Exception
                            onErrorResponse(log_id, err)
                            Exit While
                        End Try
                    End While

                    If Not huborespuesta Then
                        err.numError = 1000
                        err.mensaje = "timeout"
                    End If
                Else
                    err = errRequest
                End If
                'errRequest.clear()
            Catch ex As Exception
                err.parse_error_script(ex)
                onErrorResponse(id, err)
            End Try
            If (err.params.ContainsKey("log_id")) Then
                err.params("log_id") = consumo_log_id
            Else
                err.params.Add("log_id", consumo_log_id)
            End If
            ''siempre que el error no sea por timeout, setear el consumo con su respectiva respuesta del web service
            If (err.numError <> 1000) Then
                Me.SetConsumoSuccess(CInt(consumo_log_id))
            End If
            Return err
        End Function
        ''dado el id, genera el hash y si es necesario, le pongo una vigencia
        Private Function get_hash(ByVal id As Integer, Optional segundosvigentes As Integer = 0) As String
            Dim cod_acceso As String = ""
            Dim strvigencia As String = ""
            If (segundosvigentes > 0) Then
                strvigencia = " ,fe_venc=DATEADD(second," & CStr(segundosvigentes) & ",fe_creacion) "
            End If
            Dim strsql As String = "update lausana_anexa..cuad_robot set vigente=1, cod_acceso=SUBSTRING(master.dbo.fn_varbintohexstr(HASHBYTES('SHA1', cast(id as varchar(10))+'_'+CONVERT(varchar,fe_creacion,126))),3,30) " & strvigencia & " where id=" & CStr(id) & vbCrLf
            strsql &= "select cod_acceso from lausana_anexa..cuad_robot where id=" & CStr(id)
            Dim rs = nvDBUtiles.DBOpenRecordset(strsql)
            If Not (rs.EOF) Then
                cod_acceso = rs.Fields("cod_acceso").Value
            End If
            nvDBUtiles.DBCloseRecordset(rs)
            Return cod_acceso
        End Function

        Private Function process_finished(ByVal id As Integer) As Boolean
            Dim finished As Boolean = True
            Dim proceso As RequestID = Me._procesos.Item(id)
            If (proceso IsNot Nothing) Then
                finished = (proceso.estado = "F")
            End If
            Return finished
        End Function


        ''procesa la respuesta del ws de cuad
        Public Sub ProcessResponse(ByVal id As Integer, ByVal xmlerror As String)
            Dim err As New tError
            Try
                err.loadXML(xmlerror)
                Me.ProcessResponse(id, err)
            Catch ex As Exception
                err.parse_error_script(ex)
                Dim strSQL = "update lausana_anexa..cuad_robot set xmlresponse=?,numError=?,fe_respuesta=getdate() where id=" & CStr(id)
                Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
                Dim insertparam = cmd.CreateParameter("@xmlresponse", ADODB.DataTypeEnum.adLongVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.get_error_xml())
                cmd.Parameters.Append(insertparam)
                insertparam = cmd.CreateParameter("@numError", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, -1, CInt(err.numError))
                cmd.Parameters.Append(insertparam)
                cmd.Execute()
                cmd = Nothing
            End Try
            ''err.clear()
        End Sub
        ''procesa la respuesta del ws de cuad
        Public Sub ProcessResponse(ByVal id As Integer, ByVal err As nvFW.tError)
            Dim strSQL = "update lausana_anexa..cuad_robot set xmlresponse=?,numError=?,fe_respuesta=getdate() where id=" & CStr(id)
            Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
            Dim insertparam = cmd.CreateParameter("@xmlresponse", ADODB.DataTypeEnum.adLongVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, err.get_error_xml())
            cmd.Parameters.Append(insertparam)
            insertparam = cmd.CreateParameter("@numError", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, -1, CInt(err.numError))
            cmd.Parameters.Append(insertparam)
            cmd.Execute()
            nvDBUtiles.DBExecute("delete from lausana_anexa..cuad_robot_parametros where id=" & CStr(id) & " and tipo='response'")
            Dim parametros = err.params
            For Each p As KeyValuePair(Of String, Object) In parametros
                ''Dim q As String = "insert into lausana_anexa..cuad_robot_parametros (id,parametro,valor,tipo) values(" & CStr(id) & ",'" & CStr(p.Key) & "','" & CStr(p.Value) & "','response')"
                strSQL = "insert into lausana_anexa..cuad_robot_parametros (id,parametro,valor,tipo) values(" & CStr(id) & ",?,?,'response')"
                cmd = New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText)
                insertparam = cmd.CreateParameter("@parametro", ADODB.DataTypeEnum.adLongVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(p.Key))
                cmd.Parameters.Append(insertparam)
                insertparam = cmd.CreateParameter("@valor", ADODB.DataTypeEnum.adLongVarWChar, ADODB.ParameterDirectionEnum.adParamInput, -1, CStr(p.Value))
                cmd.Parameters.Append(insertparam)
                cmd.Execute()
                ''nvDBUtiles.DBExecute(q)
            Next
            Me.SetConsumoSuccess(id)
            cmd = Nothing
        End Sub
        ''' <summary>
        ''' procedimiento que actualiza en la base de datos los consumos que fueron respondidos siempre y cuando no hayan tenido respuestas.
        ''' </summary>
        ''' <param name="id"><c>ID</c> identificador que realizo la consulta de consumo en la tabla lausana_anexa..cuad_robot y respondio desde el robot.</param>
        Public Sub SetConsumoSuccess(ByVal id As Integer)
            Dim xmlresponse As String = ""
            Dim strSQL = "select cl.consumo_log_id  from CUAD_motor_calificacion cl join lausana_anexa..cuad_robot r on cl.consumo_log_id=r.id where cl.consumo_log_id=" & CStr(id) & " and cl.fe_msg is null and r.xmlresponse<>'' "
            Dim rs = nvDBUtiles.DBOpenRecordset(strSQL)
            '' si tiene registro, se trata de un consumo de un credito, actualizo las respuestas
            If Not (rs.EOF) Then
                strSQL = "UPDATE cl set cl.fe_msg=r.fe_respuesta,cl.msg=r.xmlresponse from CUAD_motor_calificacion cl join lausana_anexa..cuad_robot r on cl.consumo_log_id=r.id where  cl.fe_msg is null and r.xmlresponse<>'' and cl.consumo_log_id=" & CStr(id) & " and cl.fe_msg is null and r.xmlresponse<>''"
                nvDBUtiles.DBExecute(strSQL)
            End If
            nvDBUtiles.DBCloseRecordset(rs)
        End Sub


        Public Function getPdf(ByVal sBase64 As String) As Byte()
            sBase64 = System.Uri.UnescapeDataString(sBase64)
            Dim Base64Byte() As Byte = Convert.FromBase64String(sBase64)
            sBase64 = Nothing
            Return Base64Byte
        End Function

        Public Function parseBytes(ByVal sbase64 As String) As Byte()
            sbase64 = System.Uri.UnescapeDataString(sbase64)
            Dim Base64Byte() As Byte = Convert.FromBase64String(sbase64)
            sbase64 = Nothing
            Return Base64Byte
        End Function
        ''agrega un binario al legajo de un credito
        Public Function addFile(ByVal binary As Byte(), ByVal nro_credito As Integer, ByVal nro_archivo_def_tipo As Integer) As tError
            Dim err As New tError
            Dim path_rova As String = ""
            Dim rsDef = nvFW.nvDBUtiles.DBOpenRecordset("select nro_def_detalle,archivo_descripcion from verArchivos_def where nro_credito = " & CStr(nro_credito) & " and  nro_archivo_def_tipo=" & CStr(nro_archivo_def_tipo))
            If (rsDef.EOF = True) Then
                err.numError = 1000
                err.mensaje = "no existe el detalle para el tipo de archivo"
                Return err
            End If
            Try
                Dim nro_def_detalle As Integer = rsDef.Fields("nro_def_detalle").Value
                Dim archivo_descripcion As String = rsDef.Fields("archivo_descripcion").Value
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("get_nro_archivo", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                cmd.addParameter("@nro_def_detalle", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_def_detalle)
                cmd.addParameter("@descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, archivo_descripcion.Length, archivo_descripcion)
                Dim rs As ADODB.Recordset = cmd.Execute()
                Dim nro_archivo As Integer = rs.Fields("nro_archivo").Value
                Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
                Dim filename As String = CStr(nro_archivo) & ".pdf"
                nvDBUtiles.DBCloseRecordset(rs)
                'Guardado en Rova

                Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = 'nv_mutual' and cod_servidor = '" & nvApp.getInstance().cod_servidor & "' and cod_ss_dir = 'nvArchivosDefault'")
                path_rova = rsRova.Fields("path").Value.Replace("\", "\\") & carpeta
                nvDBUtiles.DBCloseRecordset(rsRova)

                If System.IO.Directory.Exists(path_rova) = False Then
                    System.IO.Directory.CreateDirectory(path_rova)
                End If
                Dim pathR As String = path_rova & "\\" & filename
                'System.IO.File.Copy(path, pathR, True)
                Dim fs3 As New System.IO.FileStream(pathR, IO.FileMode.Create)
                fs3.Write(binary, 0, binary.Length)
                fs3.Close()
                binary = Nothing
                nvFW.nvDBUtiles.DBExecute("update archivos set nro_archivo_estado = 2 where nro_def_detalle = " & nro_def_detalle & " and nro_credito = " & nro_credito & " and nro_archivo <> " & nro_archivo)
                nvFW.nvDBUtiles.DBExecute("update archivos set nro_archivo_estado = 1,  path = '" & carpeta & "\" & filename & "', nro_credito = " & nro_credito & ", descripcion = '" & archivo_descripcion & "',nro_def_detalle=" & nro_def_detalle & " where nro_archivo = " & nro_archivo)
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try

            'err.mensaje = path_rova
            Return err
        End Function



        Public Property timeoutcupo As Integer
            Get
                Return Me._timeoutcupo
            End Get
            Set(ByVal value As Integer)
                Me._timeoutcupo = value
            End Set
        End Property
        Public Property timeoutconsumo As Integer
            Get
                Return Me._timeoutconsumo
            End Get
            Set(ByVal value As Integer)
                Me._timeoutconsumo = value
            End Set
        End Property
        Public Property url As String
            Get
                Return Me._url
            End Get
            Set(ByVal value As String)
                Me._url = value
            End Set
        End Property

        Public Property callback As String
            Get
                Return Me._callback
            End Get
            Set(ByVal value As String)
                Me._callback = value
            End Set
        End Property


        ''eventos para el servicio
        Public Sub onInitRequest(ByVal id As Integer)
            Dim proceso As New RequestID(id)
            If (Me._procesos.ContainsKey(id)) Then
                Me._procesos.Item(id) = proceso
            Else
                Me._procesos.Add(id, proceso)
            End If
        End Sub
        Public Sub onErrorResponse(ByVal id As Integer, ByVal err As tError)
            If Not (err.params.ContainsKey("log_id")) Then
                err.params.Add("log_id", CStr(id))
            Else
                err.params.Item("log_id") = CStr(id)
            End If
            Dim proceso As RequestID = Me._procesos.Item(id)
            If (proceso IsNot Nothing) Then
                proceso.estado = "F"
                proceso.terror = err
                Me._procesos.Item(id) = proceso

            End If
        End Sub
        Public Sub onFinishResponse(ByVal id As Integer, ByVal err As tError)
            If Not (err.params.ContainsKey("log_id")) Then
                err.params.Add("log_id", CStr(id))
            Else
                err.params.Item("log_id") = CStr(id)
            End If
            Dim proceso As RequestID = Me._procesos.Item(id)
            If (proceso IsNot Nothing) Then
                proceso.estado = "F"
                proceso.terror = err
                Me._procesos.Item(id) = proceso
            End If
        End Sub



        Public Class wsCredencial
            Public usuario As String = ""
            Public pwd As String = ""
        End Class

        Public Class RequestID
            Private _estado As String = "P" ''P:pendiente, "E":enviando , "F":finalizado
            Private _id As Integer = 0
            Private _terror As tError
            Public Sub New(ByVal id As Integer)
                Me._id = id
            End Sub

            Public Property estado As String
                Get
                    Return Me._estado
                End Get
                Set(ByVal value As String)
                    Me._estado = value
                End Set
            End Property

            Public Property terror As tError
                Get
                    Return Me._terror
                End Get
                Set(ByVal value As tError)
                    Me._terror = value
                End Set
            End Property

        End Class
    End Class


End Namespace