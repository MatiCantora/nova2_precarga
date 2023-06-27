<%@ Page Language="vb" AutoEventWireup="true" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Dim objError as new tError()
    dim nro_archivo as string =  nvUtiles.obtenerValor("nro_archivo","")
    Dim nombre_archivo As String = ""
    Dim path_archivo As String = nvUtiles.obtenerValor("path_archivo", "")
    Dim path As String = ""

    If (nro_archivo <> "") Then
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("Select path from archivos where nro_archivo=" + nro_archivo)
        nombre_archivo = rs.Fields("path").Value

        For Each cod_modulo_dir As tnvAppDir In nvApp.app_dirs.Values
            If (IO.File.Exists(cod_modulo_dir.path + nombre_archivo)) Then
                path_archivo = cod_modulo_dir.path + nombre_archivo
            End If
        Next
    End If

    If (path_archivo <> "") Then


        Try

            Dim extension As String = IO.Path.GetExtension(path_archivo)
            Dim name As String = IO.Path.GetFileName(path_archivo)

            Select Case (extension.ToLower())
                Case ".xls"
                    Response.ContentType = "application/vnd.ms-excel"
                Case ".doc"
                    Response.ContentType = "application/msword"
                Case ".html"
                    Response.ContentType = "text/html"
                   'Response.Charset = "ISO-8859-1";
                Case ".pdf"
                    Response.ContentType = "application/pdf"
                Case ".xml"
                    Response.ContentType = "text/xml"
                    'Response.Charset = "ISO-8859-1";
                Case Else
                    Response.ContentType = "text/html"
                    'Response.Charset = "ISO-8859-1";
            End Select


            'Dim rs01 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("Select top 1 mime_type from Mime_type where extencion='" & extencion & "'")
            ' If (rs01.EOF = True) Then
            ' Response.Redirect("mensajes/MostrarError.asp?numError=150")
            '  Else
            'Response.ContentType = rs01.Fields("mime_type").Value
            Dim BinaryData() As Byte
            Dim mStream As New ADODB.Stream
            mStream.Mode = 3 '//adModeReadWrite
            mStream.Type = 1
            mStream.Open()
            mStream.LoadFromFile(path_archivo)

            Response.AddHeader("Content-Disposition", "inline;filename=" & name & "")
            BinaryData = mStream.Read()
            Response.BinaryWrite(BinaryData)
            mStream.Close()

            Response.Flush()

            ' End If


        Catch ex As Exception

            If (Err.Number.ToString = "-2147467259") Then
                objError.Cargar_msj_error(102)
            Else
                objError.parse_error_script(ex)
            End If

            Response.ContentType = "text/html"
            objError.mostrar_error()

        End Try


    Else
        Response.Redirect("mensajes/MostrarError.asp?numError=101")
    End If

 %>