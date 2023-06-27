<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim nro_ref As Integer = nvFW.nvUtiles.obtenerValor("nro_ref", "")
    Dim tipo_salida As String = nvFW.nvUtiles.obtenerValor("tipo_salida", "detalle")
    
    Dim err As New nvFW.tError()
    err.salida_tipo = "HTML"

       
    Dim filtroXML As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.ref_dependientes' CommantTimeOut='1500'><parametros></parametros></procedure></criterio>")
    Dim filtroWhere = "<criterio><procedure><parametros><nro_ref DataType='int'>" & nro_ref & "</nro_ref></parametros></procedure></criterio>"
    
    Dim exportParam As New tnvExportarParam
    
    exportParam.filtroXML = filtroXML
    exportParam.filtroWhere = filtroWhere
    If tipo_salida.ToLower = "detalle" Then
        exportParam.path_xsl = "report\verRef_docs\HTML_ref_doc_impresion_detalle.xsl"
    Else
        exportParam.path_xsl = "report\verRef_docs\HTML_ref_doc_impresion_resumen.xsl"
    End If
    
    err = nvFW.reportViewer.exportarReporte(exportParam)
    
    If err.numError <> 0 Then
        err.response()
    End If
                      
%>

