<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    
        
    Dim paramExport As tnvExportarParam = New tnvExportarParam()
    Dim nro_ref = nvFW.nvUtiles.obtenerValor("nro_ref", 0)
    Dim target = nvFW.nvUtiles.obtenerValor("target", "")
    
    
    paramExport.filtroXML = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>*</campos><orden>doc_orden</orden></select></criterio>")
    paramExport.filtroWhere = "<nro_ref type='igual'>" + nro_ref + "</nro_ref><ref_doc_activo type='igual'>1</ref_doc_activo>"
    paramExport.salida_tipo = nvenumSalidaTipo.adjunto
   ' paramExport.path_xsl = "HTML_Ref_doc_datos.xsl"wiki\report\verRef_docs\
    paramExport.xsl_name = "HTML_Ref_doc_datos.xsl"
    paramExport.content_disposition = "inline"
    paramExport.ContentType = "text/html"
    paramExport.target = target
    
    
    'Dim parametros As String = nvFW.nvUtiles.obtenerValor("parametros", "")
    'If parametros <> "" Then
    'paramExport.parametros = parametros
    'End If
    
    Dim op As nvSecurity.tnvOperador = nvApp.operador
    Dim permisos_referencias As Integer = op.permisos("permisos_referencias")
    Dim parametros As String = "<parametros><permisos_referencias>" & permisos_referencias & "</permisos_referencias></parametros>"
    paramExport.parametros = parametros
    
    Dim er As nvFW.tError = reportViewer.exportarReporte(paramExport)

    If er.numError <> 0 Then
        er.salida_tipo = "adjunto"
        er.mostrar_error()
    Else
        Response.End()
    End If
    
    'er.response()
    
%>