Imports Microsoft.VisualBasic
Imports System
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    Public Class nvNotify

        Public Shared server As String = ""
        Public Shared port As String = 465
        Public Shared user As String = ""
        Public Shared pass As String = ""
        Public Shared from As String = ""
        Public Shared ssl As Boolean = True
        Public Shared IsBodyHtml As String = True
        Public Shared from_title As String = ""

        Public Enum enumcdoTypeAuthentication
            cdoAnonymous = 0 'Do not authenticate
            cdoBasic = 1 'basic (clear-text) authentication
            cdoNTLM = 2 'NTLM
        End Enum

        Public Enum enumcdoSendUsing
            cdoSendUsingPickup = 1 'Send message using the local SMTP service pickup directory. 
            cdoSendUsingPort = 2 'Send the message using the network (SMTP over the network). 
        End Enum

        Public Shared Function sendMail(ByVal _from As String, ByVal _to As String, Optional ByVal _subject As String = "", Optional ByVal _body As String = "" _
                            , Optional ByVal _cc As String = "", Optional ByVal _bcc As String = "", Optional ByVal _bodyencoding As String = "UTF-8" _
                            , Optional ByVal _server As String = "", Optional ByVal _user As String = "", Optional ByVal _pass As String = "" _
                            , Optional ByVal _port As Integer = 465, Optional ByVal _ssl As Boolean = False _
                            , Optional ByVal _attachByPath As String = "", Optional ByVal _attachByBinary As Byte() = Nothing _
                            , Optional ByVal _attachFilename As String = "" _
                            , Optional ByVal _from_title As String = "", Optional ByVal _IsBodyHtml As Boolean = True) As tError

            Dim err As New tError()
            Try

                Dim strSQLConf As String = "Select * from transf_conf where (([from] = '" & _from & "'))" ' or (transf_conf_default =1 ))"
                Dim rsConf As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQLConf)
                If (rsConf.EOF = False) Then
                    server = nvUtiles.getParametroValor(rsConf.Fields("server").Value, "")
                    port = nvUtiles.getParametroValor(rsConf.Fields("port").Value, "")
                    user = nvUtiles.getParametroValor(rsConf.Fields("user").Value, "")
                    ssl = iif(nvUtiles.getParametroValor(rsConf.Fields("esSSl").Value, False).tolower = "true", True, False)
                    pass = nvUtiles.getParametroValor(rsConf.Fields("password").Value, "")
                    from = nvUtiles.getParametroValor(rsConf.Fields("from").Value, "")
                    from_title = nvUtiles.getParametroValor(rsConf.Fields("from_title").Value, "")
                Else
                    server = _server
                    port = _port
                    user = _user
                    ssl = _ssl
                    pass = _pass
                    from = _from
                    from_title = _from_title
                End If
                nvDBUtiles.DBCloseRecordset(rsConf)

                'Const cdoSendUsingPickup = 1 'Send message using the local SMTP service pickup directory. 
                'Const cdoSendUsingPort = 2 'Send the message using the network (SMTP over the network). 

                'Const cdoAnonymous = 0 'Do not authenticate
                'Const cdoBasic = 1 'basic (clear-text) authentication
                'Const cdoNTLM = 2 'NTLM

                Dim objMessage As Object = CreateObject("CDO.Message")
                objMessage.Subject = _subject

                If (from_title = "") Then
                    from_title = from
                End If

                objMessage.From = from_title & " <" & from & ">" '"""Me"" <sqlmail@redmutual.com.ar>"
                objMessage.To = _to
                objMessage.Cc = _cc
                objMessage.Bcc = _bcc
                objMessage.MimeFormatted = True

                'Dim Mail As Net.Mail.MailMessage = New Net.Mail.MailMessage()
                'Dim avHtml As Net.Mail.AlternateView = Net.Mail.AlternateView.CreateAlternateViewFromString(_body, nvConvertUtiles.currentEncoding, Net.Mime.MediaTypeNames.Text.Html)
                'Mail.From = New Net.Mail.MailAddress(from, from_title)
                'For i = 0 To _to.Split(";").Length - 1
                ' Mail.To.Add(_to.Split(";")(i))
                ' Next
                'Mail.Subject = _subject
                'Mail.IsBodyHtml = _IsBodyHtml

                If _IsBodyHtml = True Then

                    Try

                        Dim strReg As String = "(cid\:((.+?).(gif|jpeg|png|pif)))"
                        Dim Expression As New System.Text.RegularExpressions.Regex(strReg)
                        Dim filename As String = ""

                        If Expression.IsMatch(_body) Then
                            Dim matches As MatchCollection = Expression.Matches(_body)
                            For Each match As Match In matches
                                Dim groups As GroupCollection = match.Groups

                                filename = ""

                                If System.IO.File.Exists(Replace(groups(2).Value.ToString, "/", "\")) Then
                                    filename = Replace(groups(2).Value.ToString, "/", "\")
                                Else
                                    filename = nvServer.appl_physical_path & "\" & Replace(groups(2).Value.ToString, "/", "\")
                                End If

                                If System.IO.File.Exists(filename) Then

                                    Dim ext As String = System.IO.Path.GetExtension(filename).Replace(".", "")
                                    Dim inline As New Net.Mail.LinkedResource(filename, "image/" & ext)
                                    inline.ContentId = Guid.NewGuid().ToString()

                                    'avHtml.LinkedResources.Add(inline)
                                    'Mail.AlternateViews.Add(avHtml)
                                    'Mail.Body = Replace(_body, groups(0).Value.ToString, "cid:" & inline.ContentId)

                                    Dim Attachment = objMessage.AddAttachment(filename)
                                    Attachment.Fields.Item("urn:schemas:mailheader:Content-ID") = "<" & inline.ContentId & ">" ' set an ID we can refer to in HTML 
                                    Attachment.Fields.Item("urn:schemas:mailheader:Content-Disposition") = "inline" ' "hide" the attachment 
                                    Attachment.Fields.Item("urn:schemas:mailheader:Content-Type") = "image/" & ext & ";name=" & inline.ContentId 'System.IO.Path.GetFileName(filename) ' "hide" the attachment 
                                    Attachment.Fields.Update()

                                    _body = Replace(_body, groups(0).Value.ToString, "cid:" & inline.ContentId)

                                    'Dim att As New Net.Mail.Attachment(path)
                                    'att.ContentDisposition.Inline = True
                                    'Mail.Attachments.Add(att)

                                    'Mail.Body = String.Format("Here is the previous HTML Body@<img src='cid:{0}' />", inline.ContentId)
                                    ' _body = replace(_body, groups(0).Value.ToString, System.IO.Path.GetFileName(filename))

                                End If
                            Next

                        End If

                        objMessage.HtmlBody = _body

                    Catch ex As Exception

                    End Try

                Else
                    objMessage.TextBody = _body
                End If

                If (_attachByPath <> "") Then

                    'With objMessage.Attachments(1).Fields
                    '    .Item("urn:schemas:mailheader:Content-Disposition") = "attachment;filename=algo"
                    '    .Update()
                    'End With

                    Dim i As Integer
                    For i = 0 To _attachByPath.Split(";").Length - 1
                        objMessage.AddAttachment(_attachByPath.Split(";")(i))
                    Next

                    If (_attachByPath.Split(";").Length = 0) Then
                        objMessage.AddAttachment(_attachByPath)
                    End If

                End If

                If Not (_attachByBinary Is Nothing) Then

                    Dim attachment As System.Net.Mail.Attachment = New System.Net.Mail.Attachment(New System.IO.MemoryStream(_attachByBinary), _attachFilename)
                    objMessage.AddAttachment(attachment)

                End If

                'Dim cred As New System.Net.NetworkCredential(from, pass)
                'Dim smtp As New Net.Mail.SmtpClient(server, port)
                'smtp.EnableSsl = ssl
                'smtp.DeliveryFormat = Net.Mail.SmtpDeliveryFormat.International
                'smtp.DeliveryMethod = Net.Mail.SmtpDeliveryMethod.Network
                'smtp.UseDefaultCredentials = True
                'smtp.Credentials = cred
                'smtp.Timeout = 60
                'smtp.Send(Mail)

                '==This section provides the configuration information for the remote SMTP server.

                objMessage.Configuration.Fields.Item _
                ("http://schemas.microsoft.com/cdo/configuration/sendusing") = enumcdoSendUsing.cdoSendUsingPort

                'Name or IP of Remote SMTP Server
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = server

                'Type of authentication, NONE, Basic (Base64 encoded), NTLM
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = enumcdoTypeAuthentication.cdoBasic

                'Your UserID on the SMTP server
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/sendusername") = from

                'Your password on the SMTP server
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = pass

                'Server port (typically 25)
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = port

                'Use SSL for the connection (False or True)
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = ssl

                'Connection Timeout in seconds (the maximum time CDO will try to establish a connection to the SMTP server)
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60

                'Acuse de recibo
                objMessage.Configuration.Fields.Item _
                            ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2

                objMessage.Configuration.Fields.Update()

                '==End remote SMTP server configuration section==

                objMessage.Send()




            Catch ex As Exception
                err.numError = -99
                err.mensaje = ex.Message.ToString
            End Try

            Return err

        End Function


    End Class


End Namespace

