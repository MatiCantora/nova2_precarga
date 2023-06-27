<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    '*****************************************************
    '   Recuperar parametros
    '*****************************************************
    '   Parametros de datos
    Dim paramExport As tnvExportarParam = reportViewer.getParamExportFromRequest()
    Dim er As tError = reportViewer.exportarReporte(paramExport)

    If er.numError <> 0 Then
        er.salida_tipo = "adjunto"
        er.mostrar_error()
    End If
%>