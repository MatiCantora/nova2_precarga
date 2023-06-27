<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%


    ''Dim accion As String = nvUtiles.obtenerValor({"accion","a"}, "")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")
    Dim usuario As String = nvUtiles.getParametroValor("user_sms", "") ''"SMSDEMO65328"
    Dim clave As String = nvUtiles.getParametroValor("pass_sms", "")
    Dim minsms As Integer = nvUtiles.getParametroValor("min_sms", 0)
    Dim mails_saldo As String = nvUtiles.getParametroValor("mail_saldo", "")
    Dim modoTest As Boolean = True
    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim Err As New tError
    Err.params.add("xmlresponse", XML)

    Dim logTrack As String = nvLog.getNewLogTrack()
    Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
    Dim id_codigo As Integer = 0

    Try

        XML = New System.Xml.XmlDocument
        XML.LoadXml(criterio)

        Dim xmlresponse As String=""
        Dim oNsValidate = XML.SelectNodes("criterio/validate/item")

        Dim mode = XML.SelectSingleNode("criterio/validate/@mode").Value
        If (mode = "test") Then
            modoTest = True
        Else
            modoTest = False
        End If
        Dim cn As ADODB.Connection = DBConectar()

        ' Err.params.Add("xmlresponse", "")
        strXML = "<validate>"
        For each item in oNsValidate
            Dim tipo As String = item.SelectSingleNode("@type").Value
            Dim identificador=item.SelectSingleNode("@identificador").Value
            Dim texto = item.SelectSingleNode("texto").innerText
            Dim cuit=item.SelectSingleNode("@cuit").Value
            Dim codigoStr = ""
            ''validacion envio sms
            If (tipo.ToLower = "sms") Then

                Dim lowerbound As Integer = 10000
                Dim upperbound As Integer = 99999
                Dim randomValue = CInt(Math.Floor((upperbound - lowerbound + 1) * Rnd())) + lowerbound
                Dim apenom As String = "XXXXXX"

                ''Dim PreTexto = "Estimado/a %apenom%.La aplicacion de Validacion de identidad te envia el siguiente Codigo: %codigo% para continuar con la solicitud iniciada."
                Dim PreTexto = "Codigo validacion OK Consumer: %codigo% debes cargarlo en la pagina para continuar con la solicitud."
                If (texto = "") Then
                    texto = PreTexto
                End If

                texto = texto.Replace("%codigo%", CStr(randomValue))
                ''texto = texto.Replace("%apenom%", apenom)

                If (modoTest) Then
                    codigoStr = "codigo='" & CStr(randomValue) & "'"
                End If

                Dim longitud = Len(texto)
                If (longitud <= 160) Then
                    Dim hash As String = ""
                    For c = 0 To 30
                        hash = hash & Chr(Rnd() * 25 + 65)
                    Next

                    cn.Execute("insert into validaciones (type,identificador,validador,estado,momento,token,intentos) values ('" & tipo & "','" & identificador & "','" & CStr(randomValue) & "','E',getdate(),'" & hash & "',0)")
                    Dim rs = cn.Execute("select @@IDENTITY as id_validacion")

                    If rs.EOF = False Then
                        id_codigo = CInt(rs.Fields("id_validacion").Value)
                    End If


                    Dim smsRq As nvFW.servicios.SMS.nvSmsRequest
                    smsRq = New nvFW.servicios.SMS.nvSmsRequest(usuario, clave, modotest:=modoTest)
                    smsRq.savebd = True
                    smsRq.cn = cn
                    Dim sms = smsRq.enviar(identificador, texto, "")
                    If (sms.enviado) Then
                        Dim idinterno = sms.idinterno
                        nvDBUtiles.DBExecute("update validaciones set id_registro=" & CStr(idinterno) & " where id=" & CStr(id_codigo))
                        strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  cuit='" & cuit & "' token='" & hash & "' estado='enviado'   " & codigoStr & " ><detalle>mensaje enviado correctamente</detalle></item>"
                        Dim saldo = smsRq.getSaldo()
                        If (saldo <> -1 And saldo < minsms) Then
                            Dim body = "Estimado/a " & "<br>" & "<br>"
                            body += "Se informa mediante este mail que restan " & CStr(saldo) & " mensajes en la cuenta de sms masivos.<br><br>"

                            Dim from_title As String = "SMS MASIVOS service - (Informacion de saldo en cuenta " & usuario & ")"
                            Dim subject = "Informacion de saldo"

                            texto += "Estimado/a " & "<br>" & "<br>"
                            texto += "Se informa mediante este mail que restan " & CStr(saldo) & " mensajes en la cuenta de sms masivos.<br><br>"
                            Dim _from As String = "sqlmail@redmutual.com.ar"
                            Dim errr = nvFW.nvNotify.sendMail(_from:=_from, _to:=mails_saldo _
                                                      , _from_title:=from_title _
                                                      , _subject:=subject _
                                                      , _body:=body)
                        End If
                    Else
                        Dim detalleError As String = "Desconocido"
                        If (smsRq.numError <> 0) Then
                            detalleError = smsRq.descError.Replace(vbCrLf, "")
                            Err.numError = smsRq.numError
                            Err.titulo = "Error al enviar sms"
                            Err.mensaje = "El servicio no pudo enviar sms: " & detalleError
                            Err.debug_desc = "send.aspx:smsRq.enviar : " & detalleError
                        End If

                        ''anulo validacion
                        nvDBUtiles.DBExecute("update validaciones set estado='N',momento=getdate() where id=" & CStr(id_codigo))
                        strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  cuit='" & cuit & "' token='" & hash & "' estado='error'  " & codigoStr & " ><detalle>" & detalleError & "</detalle></item>"
                    End If
                Else
                    strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  cuit='" & cuit & "' token='' estado='error'   " & codigoStr & " ><detalle>el mensaje supera 160 caracteres</detalle></item>"
                End If

            End If

            ''validacion envio mail
            If (tipo.ToLower = "mail") Then
                Dim lowerbound As Integer = 10000
                Dim upperbound As Integer = 99999
                Dim randomValue = CInt(Math.Floor((upperbound - lowerbound + 1) * Rnd())) + lowerbound
                Dim apenom As String = "XXXXXX"
                Dim body As String = ""


                If (modoTest) Then
                    codigoStr = "codigo='" & CStr(randomValue) & "'"
                End If

                Dim hash As String = ""
                For c = 0 To 30
                    hash = hash & Chr(Rnd() * 25 + 65)
                Next
                If (texto = "") Then
                    Dim para = "<criterio><validate><item validador='%codigo%' token ='%hash%'></item></validate></criterio>"
                    para = para.Replace("%codigo%", "<b>" & CStr(randomValue) & "</b>")
                    para = para.Replace("%hash%", hash)
                    Dim strParams = HttpUtility.UrlEncode(para)
                    texto += "Estimado/a " & "<br>" & "<br>"
                    texto += "La aplicación de Validación de Identidad te envía el siguiente codigo: %codigo% para continuar con la solicitud iniciada.<br><br>"
                    ''texto += "O haga click en el siguiente enlace <a href='https://novatest.redmutual.com.ar:10443/fw/servicios/VALIDATE/VALIDATE.aspx?criterio=" & strParams & "'>Click Aqui</a><br><br>"
                    texto += "Gracias por elegir OK Créditos.<br>"

                End If
                texto = texto.Replace("%codigo%", "<b>" & CStr(randomValue) & "</b>")
                texto = texto.Replace("%hash%", hash)
                Dim subject As String = ""
                subject = "Validación de identidad"

                ''enlace = "<a href='#'>Click Aqui</a>"

                cn.Execute("insert into validaciones (type,identificador,validador,estado,momento,token,intentos) values ('" & tipo & "','" & identificador & "','" & CStr(randomValue) & "','E',getdate(),'" & hash & "',0)")
                Dim rs = cn.Execute("select @@IDENTITY as id_validacion")

                If rs.EOF = False Then
                    id_codigo = CInt(rs.Fields("id_validacion").Value)
                End If

                ''texto = texto.Replace("%codigo%", "<b>" & CStr(randomValue) & "</b>")
                ''texto = texto.Replace("%enlace%", "<b>" & enlace & "</b>")
                ''texto = texto.Replace("%apenom%", "<b>" & apenom & "</b>")

                body = texto

                Dim from As String = nvUtiles.getParametroValor("send_mail_from", "")
                Dim from_title As String = nvUtiles.getParametroValor("send_mail_from_title", "")

                Dim user As String = nvUtiles.getParametroValor("send_mail_uid_voii", "")
                Dim pass As String = nvUtiles.getParametroValor("send_mail_pwd_voii", "")
                Dim server As String = nvUtiles.getParametroValor("send_mail_server", "")
                Dim server_port As String = nvUtiles.getParametroValor("send_mail_server_port", "")
                Dim server_ssl As String = nvUtiles.getParametroValor("send_mail_ssl", "")

                Dim errr = nvFW.nvNotify.sendMail(_from:=from, _to:=identificador _
               , _from_title:=from_title, _subject:=subject, _body:=body _
               , _server:=server, _port:=server_port, _ssl:=server_ssl, _pass:=pass, _user:=user)


                If (errr.numError <> 0) Then
                    ''anulo validacion
                    nvDBUtiles.DBExecute("update validaciones set estado='N',momento=getdate() where id=" & CStr(id_codigo))
                    'strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  cuit='" & cuit & "' token='" & hash & "' estado='error'  " & codigoStr & " ><detalle><![CDATA[" & errr.get_error_xml() & "]]></detalle></item>"
                    Err.numError = errr.numError
                    Err.titulo = "Error al enviar mail"
                    Err.mensaje = "El servicio no pudo enviar mail" '& errr.mensaje
                    Err.debug_desc = "send.aspx:smsRq.enviar  " '& errr.mensaje
                    errr.response()
                Else
                    strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  cuit='" & cuit & "' token='" & hash & "' estado='enviado'  " & codigoStr & " ><detalle><![CDATA[mail enviado correctamente]]></detalle></item>"
                End If



            End If

        Next
        strXML = strXML & "</validate>"

        XML = New System.Xml.XmlDocument
        XML.LoadXml(strXML)
        Err.params("xmlresponse") = XML
    Catch ex As Exception
        Err.parse_error_script(ex)
        Err.titulo = "Error en la importación de la consulta"
        Err.mensaje = "Salida por excepcion" & criterio
        Err.debug_src = "getxml::getvalidate"
        Err.params.clear()
    End Try


    nvDBUtiles.DBExecute("update validaciones set xmlSend='" & strXML.Replace("'", "") & "' where id=" & CStr(id_codigo))

    'nvXMLUtiles.responseXML(Response, strXML)
    'Stopwatch.Stop()
    'Dim ts As TimeSpan = Stopwatch.Elapsed
    'nvLog.addEvent("veraz_getXML", logTrack & ";;" & ts.TotalMilliseconds & ";" & accion & ";" & criterio)

    Err.response()


%>