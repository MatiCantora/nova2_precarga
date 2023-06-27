<%@ Page Language="VB" AutoEventWireup="false"  %>
<%@ Import Namespace="nvFW" %>
<%

    Dim err = New tError()
    Dim code = nvUtiles.obtenerValor("code", "")

    If (Not (New Text.RegularExpressions.Regex("^[0-9a-zA-Z]+$", RegexOptions.IgnoreCase).IsMatch(code))) Then
        err.numError = 1010
        err.mensaje = "archivo inválido"
        err.titulo = "archivo inválido"
        err.mostrar_error()
    End If


    Dim tem_dir = System.IO.Path.GetTempPath
    Dim temp_filename = tem_dir & "\" & code & ".transf.html"


    If (Not (System.IO.File.Exists(temp_filename))) Then
        err.numError = 1011
        err.mensaje = "archivo inexistente"
        err.titulo = "archivo inexistente"
        err.mostrar_error()
    End If

    Dim file = System.IO.File.OpenText(temp_filename)

    Dim Data = ""
    While (Not (file.EndOfStream))
        Data += file.ReadLine()
    End While
    file.Close()

    ' System.IO.File.Delete(temp_filename)

    Response.Write(Data)
%>