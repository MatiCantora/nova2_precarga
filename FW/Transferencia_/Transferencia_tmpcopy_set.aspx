<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    
    Dim html_code = nvUtiles.obtenerValor("html_code", "error")

    Dim code = System.IO.Path.GetRandomFileName.Split(".")(0).ToString
    Dim temp_filename As String = ""
    temp_filename = System.IO.Path.GetTempPath & "\" & code & ".transf.html"
    
    Dim fs As System.IO.FileStream = New System.IO.FileStream(temp_filename, IO.FileMode.Create)
    Dim buffer() As Byte
    buffer = System.Text.Encoding.UTF8.GetBytes(html_code)
    
    fs.Write(buffer, 0, buffer.Length)
    
    fs.Close()

    Response.Write(code)
%>