<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    stop
    Dim file As String = nvFW.nvUtiles.obtenerValor("js")
    Dim filename As String = nvFW.nvServer.appl_physical_path & "\" & "fw\script\" & file
    Dim fs As New System.IO.FileStream(filename, System.IO.FileMode.Open)
    Dim buffer(fs.Length - 1) As Byte
    fs.Read(buffer, 0, fs.Length)
    Response.Write(buffer)
 %>