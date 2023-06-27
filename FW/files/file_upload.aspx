<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<%
    'Define el tamaño máximo de archivo permitido
    'Dim upload_max_size = 1024 * 10
    'Define la regla de archivos permitidos
    'Dim upload_filter = "*.*"



    Dim err = New tError()
    Dim files As Object = Request.Files()


    Dim accion = nvFW.nvUtiles.obtenerValor("accion", "")


    If nvSession.Contents("upload_files") Is Nothing Then
        '    'upload_files = {}
        nvSession.Contents("upload_files") = New Dictionary(Of Integer, tUpload)
    End If



    Select Case accion
        Case "getid"
        
            Dim file_id As Integer = nvSession.Contents("upload_files").Count + 1
            Dim file As New tUpload(file_id)
            file.filename = nvFW.nvUtiles.obtenerValor("filename")
            nvSession.Contents("upload_files")(file.file_id) = file

            err.params("file_id") = file.file_id
            err.response()

        Case "upload"

            Try
                
                Dim file_id As Integer = nvFW.nvUtiles.obtenerValor("file_id", 0)
                Dim max_size As Integer = nvFW.nvUtiles.obtenerValor("max_size", 0)
                If max_size = 0 Then max_size = nvFW.nvUtiles.obtenerValor("max_size_kb", "0") * 1024
                If max_size = 0 Then max_size = nvFW.nvUtiles.obtenerValor("max_size_mb", "0") * 1024 * 1024


                If max_size > nvFile.upload_max_size Then
                    max_size = nvFile.upload_max_size
                End If
                If max_size = 0 Then max_size = nvFile.upload_max_size

                Dim filter = nvFW.nvUtiles.obtenerValor("filter")

                If Request.Files.Item(0).ContentLength > max_size Then
                    err.numError = 1022
                    err.titulo = "Error tUpload"
                    err.mensaje = "El archivo supera el tamaño permitido (" & max_size & "kb)"
                Else
                    Dim file As tUpload = nvSession.Contents("upload_files")(file_id)
                    file.filename = Request.Files.Item(0).FileName
                    file.size = Request.Files.Item(0).ContentLength
                    file.max_size = max_size
                    file.filter = filter

                    'Generar tmp y guardarlo
                    file.set_filename_tmp()
                    Request.Files.Item(0).SaveAs(file.path_tmp)

                    nvSession.Contents("upload_files")(file_id) = file

                    'Pasar params
                    err.params("file_id") = file_id
                    err.params("filename") = file.filename
                    err.params("size") = file.size
                    err.params("filter") = file.filter
                    err.params("estado") = file.estado
                    err.params("path_tmp") = file.path_tmp
                    'err.response()

                    ''''''''
                    'Dim p As Integer
                    'For Each p In file
                    '   If TypeOf(file(p)) <> "function"
                    'err.params([p] = file(p))
                    'End If
                    'Next

                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                err.mensaje = "Error upload"

            End Try

            err.salida_tipo = "HTML"
            err.mostrar_error()

        Case "delete"
            
            Dim file_id = nvFW.nvUtiles.obtenerValor("file_id")
            nvSession.Contents("upload_files")(file_id).borrar()
            nvSession.Contents("upload_files").Remove(file_id)

            err.mostrar_error()

    End Select




%>