<%@ Page Language="vb" AutoEventWireup="true" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%



    '/***************************************************/
    '// Recuperar parametros
    '/***************************************************/
    '//JMO: NO Está contemplando que se utilice otra conexion.
    '//JMO: NO pasar nombres de tablas como parámetros
    '/*
    ' * Debería recibir un solo parámetro: ejemplos id_ref_doc = "" 
    ' * id_ref_doc = "256" :: archivo ID 256 de la tabla por defecto de la conexion por defecto
    ' * id_ref_doc = "otra::256" :: archivo ID 256 de la tabla "otra" de la conexion por defecto
    ' * id_ref_doc = "nc::otra::256" :: archivo ID 256 de la tabla "otra" de la conexion "cn"
    ' ** */


    Dim paramExport As tnvExportarParam = New tnvExportarParam()
    '//Parametros de destino
    paramExport.ContentType = nvUtiles.obtenerValor("ContentType", nvUtiles.obtenerValor("ContectType", ""))        '//Identifica ese valor en el flujo de salida
    paramExport.target = nvUtiles.obtenerValor("destinos", "")
    If (paramExport.target = "") Then paramExport.target = nvUtiles.obtenerValor("target", "")  '//Itenfifica donde será envíado el flujo de salida

    Dim salida_tipo As String = nvUtiles.obtenerValor("salida_tipo", "adjunto")
    If (salida_tipo.ToLower() = "adjunto") Then
        paramExport.salida_tipo = nvenumSalidaTipo.adjunto          '//Identifica si en la llamada será devuelto el resultado o un informe de resultado
    Else
        paramExport.salida_tipo = nvenumSalidaTipo.estado
    End If


    '//Parametros de datos
    Dim id_ref_doc As String = nvUtiles.obtenerValor("id_ref_doc")  '//id del documento
    Dim vista As String = nvUtiles.obtenerValor("vista")  '//id del documento     



    '/*****************************************************/
    '// Variable de error
    '/*****************************************************/
    Dim objError As tError = New tError()
    objError.salida_tipo = salida_tipo
    objError.debug_src = "getFile.aspx"


    '/*********************************************************************/
    '//Recuperar datos
    '//var strSQL = XMLtoSQL(filtroXML, filtroWhere)
    '//Procesa el filtroXML y vevuelve un recordset con los datos resultado.
    '//Si no devuelve el recordset da error
    '//Luego controla el resultado, si existe el campo forxml_data, carga el 
    '//XML con esos datos, sino carga el resultado del recordset
    '/*********************************************************************/
    Dim BinaryData() As Byte
    Try


        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from " & vista & " where id_ref_doc = " & id_ref_doc)

        Dim ext As String = rs.Fields("doc_type").Value
        BinaryData = rs.Fields("ref_doc_datos").Value

        nvDBUtiles.DBCloseRecordset(rs)

        Select Case ext.ToLower()
            Case ".xls"
                paramExport.ContentType = "application/vnd.ms-excel"
            Case ".doc"
                ContentType = "application/msword"
            Case ".html"
                paramExport.ContentType = "text/html"
                '//Response.Charset = "ISO-8859-1";
            Case ".pdf"
                paramExport.ContentType = "application/pdf"
            Case ".xml"
                paramExport.ContentType = "text/xml"
                '//Response.Charset = "ISO-8859-1"
            Case Else
                paramExport.ContentType = "text/html"
                '//Response.Charset = "ISO-8859-1";
                '//ext = ".html";
        End Select

    Catch ex As Exception

        objError.parse_error_script(ex)
        objError.titulo = "Error al recuperar el archivo"
        objError.comentario = "No se pudo recuperar la información"
        '//objError.mostrar_error();

    End Try


    '/***********************************************************/
    '// Analizar salida en función de salida_tipo y target
    '/***********************************************************/
    Dim path_temp As String = ""  '//= Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "reportViewer\\tmp\\" + archivo_tmp
    Dim TextData As String = ""
    Dim rsParam As New trsParam()
    If (objError.numError = 0) Then
        objError = reportViewer.exportarDestino(paramExport, BinaryData, TextData, path_temp, rsParam)
    End If

    If (paramExport.salida_tipo = nvenumSalidaTipo.estado) Then
        objError.response()
    Else
        If (objError.numError <> 0 And paramExport.salida_tipo = nvenumSalidaTipo.adjunto) Then
            objError.salida_tipo = "adjunto"
            objError.mostrar_error()
        End If
    End If

%>