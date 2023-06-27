<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%@ Import namespace="nvFW.nvUtiles" %>
<%
    '/***************************************************/
    '// Recuperar parametros
    '/***************************************************/
    '//debugger
    '//Parametros de datos

    'Dim paramExport As New tnvExportarParam
    'paramExport.VistaGuardada = obtenerValor("VistaGuardada", "")   '//nombre de la vista guardada en WRP_config
    'paramExport.filtroXML = obtenerValor("filtroXML", "")           '//Comando SQL en codificación XML
    'paramExport.filtroWhere = obtenerValor("filtroWhere", "")       '//Where anexo a los comandos anteriores
    'paramExport.xml_data = obtenerValor("xml_data", "")             '//parámetros modificadores de la consulta

    ''//Parametros de transformación 
    ''//Si xsl_name tiene valor se busca el archivo dentro de la carpeta de la vista.
    ''//Si no se busca la el archivo en la dirección indicada en path_xsl anexandole la carpeta de servidor
    'paramExport.report_name = obtenerValor("report_name", "")
    'paramExport.path_reporte = obtenerValor("path_reporte", "")

    ''//Parametros de destino
    'paramExport.ContentType = obtenerValor("ContentType", obtenerValor("ContectType", ""))         '//Identifica ese valor en el flujo de salida
    'paramExport.target = obtenerValor("destinos", "")
    'If paramExport.target = "" Then paramExport.target = obtenerValor("target", "")                '//Itenfifica donde será envíado el flujo de salida
    'paramExport.export_exeption = obtenerValor("export_exeption", "")                              '//Defina una exportacion por exepcion, sin plantilla xsl, sino por otro proceso
    'paramExport.filename = obtenerValor("filename", "")                                            '//Nombre del archivo generado para el flujo de salida 
    'paramExport.content_disposition = obtenerValor("content_disposition", "attachment")            '//disposición la salida "attachment" | "inline"

    'Dim salida_tipo As String = obtenerValor("salida_tipo", "no_definido")
    'Select Case salida_tipo.ToLower
    '    Case "estado"
    '        paramExport.salida_tipo = nvenumSalidaTipo.estado
    '    Case "adjunto"
    '        paramExport.salida_tipo = nvenumSalidaTipo.adjunto
    '    Case Else
    '        paramExport.salida_tipo = nvenumSalidaTipo.no_definido
    'End Select
    'paramExport.mantener_origen = obtenerValor("mantener_origen", "false").ToLower = "true" '//Indica que se llevará registro de la llamada para reutilizarlo
    'If paramExport.mantener_origen = False And obtenerValor("mantener_origen") = "1" Then
    '    paramExport.mantener_origen = True
    'End If
    'paramExport.id_exp_origen = IIf(obtenerValor("id_exp_origen", 0) = "", 0, obtenerValor("id_exp_origen", 0)) '//Identificar el nro con el que se guardó el origen en la tabla exp_origen
    'paramExport.parametros = obtenerValor("parametros", "")


    Dim paramExport As tnvExportarParam = nvFW.reportViewer.getParamExportFromRequest()

    Dim er As nvFW.tError = reportViewer.mostrarReporte(paramExport)

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