<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>

<% 
    Dim f_id = nvUtiles.obtenerValor("f_id", "0")
    Dim ref_files_path = nvFW.nvUtiles.obtenerValor("ref_files_path", "")
    Dim salida_tipo As String = obtenerValor("salida_tipo", "HTML")   'estado|html
    Dim content_disposition As String = obtenerValor("content_disposition", "")  'attachment|inline

    Dim err As New nvFW.tError()
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

    Dim ext_default_content_disposition As String = nvFW.nvFile.fileTypes(file.f_ext).defaul_content_disposition
    Dim ContentType As String = nvFW.nvFile.fileTypes(file.f_ext).contentType

    If content_disposition = "" Then content_disposition = ext_default_content_disposition

    Response.ContentType = ContentType
    Response.AddHeader("Content-Disposition", content_disposition + ";filename=" + file.filename)
    Response.BinaryWrite(file.BinaryData)
    Response.End()



   %>
  
