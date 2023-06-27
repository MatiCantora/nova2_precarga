<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%@ Import namespace="System.Text.Json.Serialization" %>
<%

    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")

    ' parametros de configuracion para los sms
    Dim usuario As String = nvUtiles.getParametroValor("user_sms", "")
    Dim clave As String = nvUtiles.getParametroValor("pass_sms", "")
    Dim minsms As Integer = nvUtiles.getParametroValor("min_sms", 0)
    Dim mails_saldo As String = nvUtiles.getParametroValor("mail_saldo", "")

    Dim modoTest As Boolean = True
    Dim XML As System.Xml.XmlDocument
    'Dim strXML As String = ""
    Dim err As New tError

    'Dim logTrack As String = nvLog.getNewLogTrack()
    'Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

    Try

        XML = New System.Xml.XmlDocument
        XML.LoadXml(criterio)

        Dim xmlresponse As String = ""
        Dim oNsValidate = XML.SelectNodes("criterio/send/item")

        Dim mode = XML.SelectSingleNode("criterio/send/@mode").Value
        If (mode = "test") Then
            modoTest = True
        Else
            modoTest = False
        End If


        Dim cn As ADODB.Connection = DBConectar()

        'strXML = "<send>"

        Dim pos As Integer = 0
        Dim items As trsParam = New trsParam
        Dim res_item As trsParam = New trsParam
        Dim res_estado As trsParam = New trsParam

        For Each item In oNsValidate

            Dim tipo As String = nvXMLUtiles.getNodeText(item, "@type", "")
            Dim identificador As String = nvXMLUtiles.getNodeText(item, "@identificador", "") 'item.SelectSingleNode("@identificador").Value
            Dim body = nvXMLUtiles.getNodeText(item, "body", "")
            Dim subject = nvXMLUtiles.getNodeText(item, "subject", "")
            Dim cc = nvXMLUtiles.getNodeText(item, "@cc", "")
            Dim cco = nvXMLUtiles.getNodeText(item, "@cco", "")

            res_estado = New trsParam
            res_estado("identidicador") = identificador
            res_estado("tipo") = tipo.ToLower
            res_estado("estado") = ""
            res_estado("mensaje") = ""

            If (tipo.ToLower = "sms") Then

                Dim lowerbound As Integer = 10000
                Dim upperbound As Integer = 99999
                Dim randomValue = CInt(Math.Floor((upperbound - lowerbound + 1) * Rnd())) + lowerbound
                Dim apenom As String = "XXXXXX"

                Dim longitud = Len(body)
                If (longitud <= 160) Then

                    Dim smsRq As nvFW.servicios.SMS.nvSmsRequest
                    smsRq = New nvFW.servicios.SMS.nvSmsRequest(usuario, clave, modotest:=modoTest)
                    smsRq.savebd = True
                    smsRq.cn = cn
                    Dim sms = smsRq.enviar(identificador, body, "")
                    If (sms.enviado) Then
                        Dim idinterno = sms.idinterno
                        'strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "' estado='enviado'><detalle>mensaje enviado correctamente</detalle></item>"
                        res_estado("estado") = "enviado"
                        res_estado("mensaje") = "Mensaje enviado correctamente"

                        Dim saldo = smsRq.getSaldo()
                        If (saldo <> -1 And saldo < minsms) Then


                            Dim from As String = nvUtiles.getParametroValor("mail_from", "")
                            Dim from_title As String = nvUtiles.getParametroValor("mail_from_title", "")
                            Dim pass As String = nvUtiles.getParametroValor("mail_pwd", "")

                            Dim server As String = nvUtiles.getParametroValor("mail_server", "")
                            Dim server_port As String = nvUtiles.getParametroValor("mail_server_port", "")
                            Dim server_ssl As String = nvUtiles.getParametroValor("mail_ssl", "")

                            subject = "Informacion de saldo -  Servicio SMS"

                            body += "Estimado/a " & "<br>" & "<br>"
                            body += "Se informa mediante este mail que restan " & CStr(saldo) & " mensajes en la cuenta de sms masivos.<br><br>"

                            Dim errr As tError = nvFW.nvNotify.sendMail(_from:=from, _to:=mails_saldo _
                                                              , _port:=server_port, _ssl:=server_ssl _
                                                              , _from_title:=from_title _
                                                              , _subject:=subject _
                                                              , _body:=body)
                        End If
                    Else

                        Dim detalleError As String = "Desconocido"
                        If (smsRq.numError <> 0) Then
                            detalleError = smsRq.descError.Replace(vbCrLf, "")
                        End If

                        'strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  estado='error'><detalle>" & detalleError & "</detalle></item>"
                        res_estado("estado") = "error"
                        res_estado("mensaje") = detalleError
                    End If
                Else
                    'strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  estado='error'><detalle>el mensaje supera 160 caracteres</detalle></item>"
                    res_estado("estado") = "error"
                    res_estado("mensaje") = "El mensaje supera 160 caracteres"
                End If

            End If

            If (tipo.ToLower = "mail") Then

                If modoTest = True Then
                    res_estado("estado") = "enviado"
                    res_estado("mensaje") = "El mail se enviado correctamente"
                Else

                    Dim from As String = nvUtiles.getParametroValor("send_mail_from", "")
                    Dim from_title As String = nvUtiles.getParametroValor("send_mail_from_title", "")

                    Dim pass As String = nvUtiles.getParametroValor("send_mail_pwd", "")
                    Dim server As String = nvUtiles.getParametroValor("send_mail_server", "")
                    Dim server_port As String = nvUtiles.getParametroValor("send_mail_server_port", "")
                    Dim server_ssl As String = nvUtiles.getParametroValor("send_mail_ssl", "")

                    Dim errr As tError = nvFW.nvNotify.sendMail(_from:=from, _to:=identificador, _cc:=cc, _bcc:=cco _
                  , _from_title:=from_title, _subject:=subject, _body:=body _
                  , _server:=server, _port:=server_port, _ssl:=server_ssl, _pass:=pass)


                    If (err.numError <> 0) Then
                        '  strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "'  estado='error' ><detalle><![CDATA[" & err.get_error_xml() & "]]></detalle></item>"
                        res_estado("estado") = "error"
                        res_estado("mensaje") = err.get_error_xml()
                    Else
                        ' strXML = strXML & "<item type='" & tipo & "'  identificador='" & identificador & "' estado='enviado' ><detalle><![CDATA[mail enviado correctamente]]></detalle></item>"
                        res_estado("estado") = "enviado"
                        res_estado("mensaje") = "El mail se enviado correctamente"
                    End If

                End If

            End If

            If modoTest = True Then
                res_estado("mensaje") += " (Modo testing)"
            End If

            res_item(pos) = res_estado

            items("items") = res_item
            pos = pos + 1
        Next

        'strXML = strXML & "</send>"

        err.params("respuesta") = items


    Catch ex As Exception
        Err.parse_error_script(ex)
        Err.titulo = "Error en la importación de la consulta"
        Err.mensaje = "Salida por excepcion"
        Err.debug_src = "getxml::getvalidate"

    End Try


    Err.response()


%>