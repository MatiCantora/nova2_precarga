<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>

<% 
    
    Dim f_id = nvUtiles.obtenerValor("f_id", "0")
    Dim ref_files_path = nvFW.nvUtiles.obtenerValor("ref_files_path", "")

    Dim salida_tipo As String = obtenerValor("salida_tipo", "HTML")   'estado|html
    Dim content_disposition As String = obtenerValor("content_disposition", "")  'attachment|inline

    Dim path = obtenerValor("path", "") 'Path realtivo a los directorios de la apliacación
    Dim temp_path = obtenerValor("temp_path", "") 'Path realtivo a la carpeta de archivos temporales

    Dim filename As String = nvUtiles.obtenerValor("filename", "")
    Dim ContentType As String = nvUtiles.obtenerValor("ContentType", "")

    Dim ext_default_content_disposition As String = ""
    Dim ext_default_ContentType As String = ""
    Dim err As New nvFW.tError()
    Dim ext As String
    Dim BinaryData() As Byte

    'Para archivos de carpetas de aplicacion
    If (path <> "") Then

        Dim fisical_path = nvFW.nvReportUtiles.get_file_path(path)

        'dir
        Dim cumple As Boolean = False
        err.titulo = "Error al intentar descargar el archivo"
        err.numError = 99
        err.mensaje = "No cumple no las validaciones de descarga"

        For Each dir As tnvAppDir In nvApp.app_dirs.Values
            If fisical_path.IndexOf(dir.cod_ss_dir) >= 0 Then
                cumple = True
                Exit For
            End If
        Next

        If cumple = False Then
            err.mostrar_error()
        End If

        'archivo exista
        If System.IO.File.Exists(fisical_path) = False Then
            err.mostrar_error()
        End If

        err.numError = 0
        err.mensaje = ""

        ext = System.IO.Path.GetExtension(fisical_path).Replace(".", "")
        filename = IIf(filename = "", System.IO.Path.GetFileName(fisical_path), filename)
        BinaryData = System.IO.File.ReadAllBytes(fisical_path)
    End If

    'Para archivos del administrador documental
    If ref_files_path <> "" And f_id <> "" Then

        err.titulo = "Error al intentar descargar el archivo"
        err.salida_tipo = salida_tipo

        Dim file As nvFW.nvFile.tnvFile = nvFW.nvFile.getFile(f_id:=f_id, ref_files_path:=ref_files_path)
        If file Is Nothing Then
            err.numError = 1366
            err.mensaje = "El archivo no existe o no tiene permisos para verlo"
            err.mostrar_error()
        End If

        If file.BinaryData Is Nothing Then
            err.mensaje = "El archivo no existe o no tiene permisos para verlo"
            err.mostrar_error()
        End If

        ext = file.f_ext
        filename = file.filename
        BinaryData = file.BinaryData

    End If

    'Para archivos temporales
    If (temp_path <> "") Then

        Dim fisical_path As String = System.IO.Path.GetTempPath & "\" & temp_path

        err.titulo = "Error al intentar descargar el archivo"
        err.numError = 99
        err.mensaje = "El archivo no existe"

        'archivo exista
        If System.IO.File.Exists(fisical_path) = False Then
            err.mostrar_error()
        End If

        BinaryData = System.IO.File.ReadAllBytes(fisical_path)

        System.IO.File.Delete(fisical_path)

        err.numError = 0
        err.mensaje = ""

        ext = System.IO.Path.GetExtension(fisical_path).Replace(".", "")
        filename = System.IO.Path.GetFileName(fisical_path)
    End If

    ext_default_content_disposition = nvFW.nvFile.fileTypes(ext).defaul_content_disposition
    ext_default_ContentType = nvFW.nvFile.fileTypes(ext).contentType

    If content_disposition = "" Then content_disposition = ext_default_content_disposition
    If ContentType = "" Then ContentType = ext_default_ContentType

    Response.AddHeader("Content-Disposition", content_disposition + ";filename=" + filename)

    Response.BinaryWrite(BinaryData)
    Response.ContentType = ContentType
    Response.End()


   %>



