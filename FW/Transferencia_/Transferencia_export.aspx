<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Dim err = New nvFW.tError()
    err.salida_tipo = "HTML"
    Dim id_transferencia = nvUtiles.obtenerValor("id_transferencia", "")
    Dim code = nvUtiles.obtenerValor("code", "")
    Dim file_type = nvUtiles.obtenerValor("file_type", "")
    Dim tipo_salida = nvUtiles.obtenerValor("tipo_salida", "detalle")

    If (Not (New Text.RegularExpressions.Regex("^[0-9a-zA-Z]+$", RegexOptions.IgnoreCase).IsMatch(code))) Then
        err.numError = 1010
        err.mensaje = "code inválido"
        err.titulo = "code inválido"
        err.mostrar_error()
    End If


    If (Not (New Text.RegularExpressions.Regex("^[0-9]+$", RegexOptions.IgnoreCase).IsMatch(id_transferencia))) Then
        err.numError = 1010
        err.mensaje = "id_transferencia inválido"
        err.titulo = "id_transferencia inválido"
        err.mostrar_error()
    End If

    Dim filetypes As New Dictionary(Of String, String)
    Dim key As String

    filetypes.Add("doc", "doc")
    filetypes.Add("pdf", "pdf")
    filetypes.Add("html", "html")
    If (filetypes.Item(file_type) Is Nothing) Then
        err.mensaje = "Formatos soportados: "

        For Each key In filetypes.Keys
            err.mensaje += filetypes(key) + ", "
        Next

        err.mensaje = err.mensaje.Substring(0, err.mensaje.Length - 2)
        err.numError = 1013
        err.titulo = "file_type inválido"
        err.mostrar_error()
    End If

    Dim rs = nvDBUtiles.DBOpenRecordset("SELECT nombre FROM Transferencia_Cab WHERE id_transferencia = " + id_transferencia)

    Dim fs = Server.CreateObject("Scripting.FileSystemObject")

    Dim protocolo As String = "http://"
    Dim port As String = ":" & Request.ServerVariables("SERVER_PORT")

    If (Request.ServerVariables("HTTPS").ToUpper = "ON") Then
        protocolo = "https://"
        ' port = ":" & Request.ServerVariables("SERVER_PORT")
    End If

    'Dim server_host = protocolo & Request.ServerVariables("SERVER_NAME") & port
    Dim server_host = "http://" & Request.ServerVariables("SERVER_NAME") & ":8100"
    Dim file_url = server_host & "/FW/transferencia/transferencia_tmpcopy_get.aspx?code=" & code
    'Dim file_url = server_host & "/FW/scripts/pvGetFilePath.asp?code=" & code


    Dim temp_filename As String = ""
    Dim tem_dir = System.IO.Path.GetTempPath
    Dim temp_downloadable_filename = tem_dir & code & ".transf"
    Dim ext = ""
    Dim response_type = ""
    Dim strcmd As String = ""
    Dim cmd = ""
    Select Case (file_type)
        Case "doc"
            ext = "doc"
            temp_downloadable_filename += "." + ext
            Dim macro_path = Request.ServerVariables("APPL_PHYSICAL_PATH") + "wiki\\embedImages.dot"

            Dim word = Server.CreateObject("Word.Application")
            word.DisplayAlerts = False
            word.Visible = False

            Dim document = word.Documents.Open(file_url)
            word.AddIns.Add(macro_path)
            document.Activate()
            word.Run("embedImages")

            document.SaveAs(temp_downloadable_filename, False)
            document.Close()

            word.Quit()
            response_type = "application/msword"

        Case "pdf"

            ext = "pdf"
            Dim filename_input = temp_downloadable_filename + "html"
            temp_downloadable_filename += "." + ext
            'Dim WshShell = Server.CreateObject("WScript.Shell")
            Dim zoom = nvUtiles.obtenerValor("zoom", "1.0")
            Dim marginTop = nvUtiles.obtenerValor("marginTop", "10") + "mm"
            Dim marginRight = nvUtiles.obtenerValor("marginRight", "10") + "mm"
            Dim marginBottom = nvUtiles.obtenerValor("marginBottom", "6") + "mm"
            Dim marginLeft = nvUtiles.obtenerValor("marginLeft", "10") + "mm"
            Dim pageSize = nvUtiles.obtenerValor("pageSize", "A4")
            Dim footerFontSize = nvUtiles.obtenerValor("footerFontSize", "9")
            Dim footerText = nvUtiles.obtenerValor("footerText", "Página [page] de [topage]")
            Dim orientation = nvUtiles.obtenerValor("orientation", "Portrait")

             cmd = "" ' """ C:\\Program Files (x86)\\wkhtmltopdf\\"" "
            '       command += " --print-media-type"
            cmd += " wkhtmltopdf.exe --footer-line"
            cmd += " --footer-right """ + footerText + """"
            cmd += " --footer-left """ + rs.Fields("nombre").Value + """"
            cmd += " --zoom " + zoom
            cmd += " --margin-top " + marginTop
            cmd += " --margin-right " + marginRight
            cmd += " --margin-bottom " + marginBottom
            cmd += " --margin-left " + marginLeft
            cmd += " --footer-font-size " + footerFontSize
            cmd += " --page-size " + pageSize
            cmd += " --disable-smart-shrinking"
            cmd += " --orientation " + orientation
            cmd += " """ + file_url + """ "
            'cmd += " """ + filename_input + """ "
            cmd += " """ + temp_downloadable_filename + """ "
            '

            'strcmd = "cmd /k " & "c: && cd C:\Program Files (x86)\wkhtmltopdf\ && " & cmd
            Dim res = Shell("cmd /k " & "c: && cd C:\Program Files (x86)\wkhtmltopdf\ && " & cmd, AppWinStyle.Hide, True, 5000) ' 5 segundo

            response_type = "application/pdf"

        Case "html"
            ext = "html"
            Response.Write("<script type='text/javascript'>window.location = '" & file_url & "'</script>")
            Response.End()

            response_type = "text/html"
    End Select

    Dim BinData() As Byte = Nothing

    If (file_type <> "html") Then

        Try
            Dim mStream As New ADODB.Stream
            mStream.Mode = 3
            mStream.Type = 1
            mStream.Open()

            mStream.LoadFromFile(temp_downloadable_filename)
            Dim sizeTh = mStream.size
            BinData = mStream.Read(-1)
            mStream.Close()
            ' fs.DeleteFile(temp_downloadable_filename, True)
            Dim download_filename = New Text.RegularExpressions.Regex("[ \t\r\n]+").Replace(rs.Fields("nombre").Value, "_").ToLower + "." + ext

            Response.ContentType = response_type
            Response.AddHeader("Content-Disposition", "inline; filename=" + download_filename)
            'Response.AddHeader("Content-Disposition", "inline filename=" + download_filename)
            Response.AddHeader("Content-Length", sizeTh)
            Response.Clear()
            Response.BinaryWrite(BinData)
            Response.Flush()
        Catch ex As Exception
            Response.Write(strcmd)
            Response.Write(ex.Message)
            Response.Write(cmd)
            Response.Flush()
        End Try

    Else
        Response.Clear()
        Response.Write(BinData)
    End If
%>