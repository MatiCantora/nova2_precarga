<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%@ Import namespace="nvFW.nvUtiles" %>
<%
    '/***************************************************/
    '// Recuperar parametros
    '/***************************************************/
    '//debugger
    '//Parametros de datos

    Dim paramExport As tnvExportarParam = nvFW.reportViewer.getParamExportFromRequest()

    Dim er As nvFW.tError = reportViewer.exportarReporte(paramExport)

    If er.numError <> 0 Then
        er.salida_tipo = "adjunto"
        er.mostrar_error()
    End If
    'If paramExport.salida_tipo = nvenumSalidaTipo.estado Then
    '    er.response()
    'Else
    '    If er.numError <> 0 And paramExport.salida_tipo = nvenumSalidaTipo.adjunto Then
    '        er.salida_tipo = "adjunto"
    '        er.mostrar_error()
    '    End If
    'End If
%>