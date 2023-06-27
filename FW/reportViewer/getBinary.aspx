<%@ Page Language="VB" AutoEventWireup="true" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Dim paramExport As New tnvExportarParam()

    ' Parametros de destino
    paramExport.ContentType = nvUtiles.obtenerValor("ContentType", nvUtiles.obtenerValor("ContectType", ""))
    paramExport.target = nvUtiles.obtenerValor("destinos", "")

    If paramExport.target = "" Then
        paramExport.target = nvUtiles.obtenerValor("target", "")
    End If

    Dim salida_tipo As String = nvUtiles.obtenerValor("salida_tipo", "adjunto")

    If salida_tipo.ToLower() = "adjunto" Then
        paramExport.salida_tipo = nvenumSalidaTipo.adjunto
    Else
        paramExport.salida_tipo = nvenumSalidaTipo.estado
    End If

    ' Parametros de datos
    Dim strSelect As String = nvUtiles.obtenerValor("select", "")

    ' Variable de error
    Dim objError As New tError()
    objError.salida_tipo = salida_tipo
    objError.debug_src = "getBinary.aspx"

    ' Recuperar datos
    Dim BinaryData() As Byte = Nothing

    Try
        Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSelect)

        If Not rs.EOF Then
            BinaryData = rs.Fields(0).Value
        End If

        nvDBUtiles.DBCloseRecordset(rs)
    Catch ex As Exception
        objError.parse_error_script(ex)
        objError.titulo = "Error al recuperar la información"
    End Try

    ' Analizar salida en función de salida_tipo y target
    Dim path_temp As String = ""
    Dim TextData As String = ""
    Dim rsParam As New trsParam()

    If objError.numError = 0 Then
        objError = reportViewer.exportarDestino(paramExport, BinaryData, TextData, path_temp, rsParam)

        If paramExport.salida_tipo = nvenumSalidaTipo.estado Then
            objError.response()
        Else
            If objError.numError <> 0 AndAlso paramExport.salida_tipo = nvenumSalidaTipo.adjunto Then
                objError.salida_tipo = "adjunto"
                objError.mostrar_error()
            End If
        End If
    End If
%>