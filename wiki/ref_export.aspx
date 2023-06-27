<%@Page Language="VB" AutoEventWireup="false" aspcompat="true" Inherits="nvFW.nvPages.nvPageWiki"  %>

<%
    Dim nro_ref As String = nvFW.nvUtiles.obtenerValor("nro_ref", "")
    'Dim file_type As String = nvFW.nvUtiles.obtenerValor("file_type", "pdf")
    Dim tipo_salida As String = nvFW.nvUtiles.obtenerValor("tipo_salida", "detalle")
    Dim ext As String = "pdf"

    Dim err As New nvFW.tError()
    err.salida_tipo = "HTML"

    Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("SELECT referencia FROM verReferencia WHERE nro_ref = " + nro_ref)
    Dim referencia As String
    If rs.EOF Then
        err.mensaje = "No existe la referencia: " & nro_ref
        err.numError = 1014
        err.titulo = " Error en la referencia."
        err.debug_desc = "Error al buscar el nro_ref: " & nro_ref & "en la vista verReferencia"
        err.debug_src = "ref_export.aspx"
        err.mostrar_error()
    Else
        referencia = rs.Fields("referencia").Value
    End If
    nvFW.nvDBUtiles.DBCloseRecordset(rs)

    Dim errHash As tError = nvFW.nvLogin.execute(nvApp, "get_hash", "", "", "", "", "", "")
    Dim hash As String = errHash.params("hash")

    Dim server_host As String = nvApp.server_protocol & "://" & nvApp.server_name & ":" & nvApp.server_port


    Dim file_url = server_host + "/wiki/ref_detalle.aspx?nro_ref=" + nro_ref + "&tipo_salida=" + tipo_salida + "&nv_hash=" + hash

    Dim temp_downloadable_filename = System.IO.Path.GetTempFileName() & "." & ext
    
    Dim response_type = ""
    Try

        Dim WshShell = Server.CreateObject("WScript.Shell")
        Dim zoom = nvFW.nvUtiles.obtenerValor("zoom", "1.4")
        Dim marginTop = nvFW.nvUtiles.obtenerValor("marginTop", "10") + "mm"
        Dim marginRight = nvFW.nvUtiles.obtenerValor("marginRight", "10") + "mm"
        Dim marginBottom = nvFW.nvUtiles.obtenerValor("marginBottom", "6") + "mm"
        Dim marginLeft = nvFW.nvUtiles.obtenerValor("marginLeft", "10") + "mm"
        Dim pageSize = nvFW.nvUtiles.obtenerValor("pageSize", "A4")
        Dim footerFontSize = nvFW.nvUtiles.obtenerValor("footerFontSize", "9")
        Dim footerText = nvFW.nvUtiles.obtenerValor("footerText", "Página [page] de [topage]")

            
        Dim command As String = ""
        'Dim osVersion = Environment.OSVersion.Version
        'If osVersion.Major > 6 Or (osVersion.Major = 6 And osVersion.Minor >= 2) Then
        '    command = nvServer.appl_physical_path & "bin\herramientas_externas\wkhtmltopdf\wkhtmltopdf.exe" 'Anda en server 2012 con https inseguro (pero no en 2008)
        'Else
        command = nvServer.appl_physical_path & "Bin\herramientas_externas\wkhtmltox\bin\wkhtmltopdf.exe" 'La version mas reciente:  Anda para server 2008 y 2012 unicamente en modo https seguro (no funciona con cert autofirmado)
        'End If
        
        
        command += " --print-media-type"
        command += " --footer-line"
        command += " --footer-right """ & footerText & """"
        command += " --footer-left """ & referencia & """"

        command += " --zoom " + zoom
        command += " --margin-top " + marginTop
        command += " --margin-right " + marginRight
        command += " --margin-bottom " + marginBottom
        command += " --margin-left " + marginLeft
        command += " --footer-font-size " + footerFontSize
        command += " --page-size " + pageSize
        command += " --load-error-handling ignore "
        command += " """ + file_url + """"
        command += " """ + temp_downloadable_filename + """"

        
        command = "cmd.exe /C " + command
        'nvFW.nvDBUtiles.DBExecute("INSERT INTO zzzz (dato) VALUES('" & command & "')")
        

        Dim exec = WshShell.Run(command, 0, True)

        response_type = "application/pdf"
       
    Catch ex As Exception
        err.mensaje = "Error de la aplicación para el formato: " & ext
        err.numError = 1020
        err.titulo = " Error al exportar."
        err.debug_desc = ex.Message()
        err.debug_src = "ref_export.aspx"
        err.mostrar_error()
    End Try

    Dim regEx2 As New Regex("[\t\r\n*:<>?/\|]+")
    Dim download_filename = regEx2.Replace(referencia.ToLower, "_") & "." & ext

    Response.ContentType = response_type
    Response.AddHeader("Content-Disposition", "inline; filename=" + download_filename)


    Dim bytes() As Byte
    Try
        bytes = System.IO.File.ReadAllBytes(temp_downloadable_filename)
        Try
            System.IO.File.Delete(temp_downloadable_filename)
            Response.BinaryWrite(bytes)
        Catch e As Exception
            err.mensaje = "Error para leer el archivo " & temp_downloadable_filename
            err.numError = 1030
            err.titulo = " Error al exportar."
            err.debug_desc = e.Message()
            err.debug_src = "ref_export.aspx "
            err.mostrar_error()
        End Try


    Catch ex As Exception
        err.mensaje = "Error para leer el archivo " & temp_downloadable_filename
        err.numError = 1032
        err.titulo = " Error al exportar."
        err.debug_desc = ex.Message()
        err.debug_src = "ref_export.aspx "
        err.mostrar_error()
    End Try

  




%>

