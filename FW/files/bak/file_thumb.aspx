<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
   
<%
    'Dim f_params As String = nvFW.nvUtiles.obtenerValor("f_params", "")
    Dim thumb_strech As Boolean = nvFW.nvUtiles.obtenerValor("thumb_strech", "0") = 1
    Dim thumb_width As String = nvFW.nvUtiles.obtenerValor("thumb_width", "0")
    Dim thumb_height As String = nvFW.nvUtiles.obtenerValor("thumb_height", "0")
    Dim thumb_quality As String = nvFW.nvUtiles.obtenerValor("thumb_quality", "60")
    Dim content_disposition As String = obtenerValor("content_disposition", "")  'attachment|inline
    Dim f_id As String = nvFW.nvUtiles.obtenerValor("f_id", "0")
    Dim ref_files_path = nvFW.nvUtiles.obtenerValor("ref_files_path", "")

    Dim BinaryData() As Byte = Nothing

    Dim file As nvFW.nvFile.tnvFile = nvFW.nvFile.getFile(f_id:=f_id, ref_files_path:=ref_files_path)
    If Not file Is Nothing Then
        BinaryData = file.getThumbBinary(thumb_strech, thumb_width, thumb_height, thumb_quality)
    End If

    Response.ContentType = "image/jpeg"
    If content_disposition = "" Then content_disposition = "inline"

    Dim filename As String = file.f_nombre & "_thumb_" & thumb_width & "_" & thumb_height & ".jpg"
    Response.AddHeader("Content-Disposition", content_disposition + ";filename=" + filename)

    'Response.ContentType = "image/png"
    Response.BinaryWrite(BinaryData)
    Response.End()






%>
