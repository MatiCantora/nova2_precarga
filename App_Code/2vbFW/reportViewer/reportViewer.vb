Imports Microsoft.VisualBasic
Imports System.Xml
Imports System.IO
Imports nvFW
Imports Microsoft.Office.Interop
Imports nvFW.nvUtiles

Namespace nvFW

    Public Class reportViewer

        Private Shared _cacheXslCompiledTransform As New Dictionary(Of String, System.Xml.Xsl.XslCompiledTransform)

        Public Shared Function getParamExportFromRequest() As tnvExportarParam
            Dim paramExport As New tnvExportarParam
            paramExport.VistaGuardada = obtenerValor({"vg", "vistaGuardada"}, "")           ' nombre de la vista guardada en WRP_config
            paramExport.filtroXML = obtenerValor({"criterio", "filtroXML"}, "")             ' Comando SQL en codificación XML
            paramExport.filtroWhere = obtenerValor({"criterio_where", "filtroWhere"}, "")   ' Where anexo a los comandos anteriores
            paramExport.filtroParams = obtenerValor("params", "")                           ' Parametros que aplican al filtroXML, filtroWhere y VistaGuardada
            paramExport.xml_data = obtenerValor("xml_data", "")                             ' Datos que se van a plantillar. Se utiliza en lugar de las consultasXML
            paramExport.parametros = obtenerValor("parametros", "")                         ' Estructura XML que se anexa al XML de salida como parametros adicionales para poder incluir en plantillas

            ' Parametros de transformación 
            ' Si xsl_name tiene valor se busca el archivo dentro de la carpeta de la vista.
            ' Si no se busca la el archivo en la dirección indicada en path_xsl anexandole la carpeta de servidor
            paramExport.xsl_name = obtenerValor("xsl_name", "")
            paramExport.path_xsl = obtenerValor("path_xsl", "")
            paramExport.xml_xsl = obtenerValor("xml_xsl", "")

            ' Si xsl_name tiene valor se busca el archivo dentro de la carpeta de la vista.
            ' Si no se busca la el archivo en la dirección indicada en path_xsl anexandole la carpeta de servidor
            paramExport.report_name = obtenerValor("report_name", "")
            paramExport.path_reporte = obtenerValor("path_reporte", "")

            ' Parametros de destino
            paramExport.ContentType = obtenerValor("ContentType", obtenerValor("ContectType", ""))  ' Identifica ese valor en el flujo de salida
            paramExport.target = obtenerValor("destinos", "")
            If paramExport.target = "" Then paramExport.target = obtenerValor("target", "")         ' Itenfifica donde será envíado el flujo de salida
            paramExport.export_exeption = obtenerValor("export_exeption", "")                       ' Defina una exportacion por exepcion, sin plantilla xsl, sino por otro proceso
            paramExport.filename = obtenerValor("filename", "")                                     ' Nombre del archivo generado para el flujo de salida 
            paramExport.content_disposition = obtenerValor("content_disposition", "attachment")     ' disposición la salida "attachment" | "inline"

            Dim salida_tipo As String = obtenerValor("salida_tipo", "no_definido")

            Select Case salida_tipo.ToLower
                Case "estado"
                    paramExport.salida_tipo = nvenumSalidaTipo.estado
                Case "adjunto"
                    paramExport.salida_tipo = nvenumSalidaTipo.adjunto
                Case Else
                    paramExport.salida_tipo = nvenumSalidaTipo.no_definido
            End Select

            paramExport.mantener_origen = obtenerValor("mantener_origen", "false").ToLower = "true"     ' Indica que se llevará registro de la llamada para reutilizarlo

            If paramExport.mantener_origen = False AndAlso obtenerValor("mantener_origen") = "1" Then
                paramExport.mantener_origen = True
            End If

            paramExport.id_exp_origen = obtenerValortype("id_exp_origen", 0, nvConvertUtiles.DataTypes.int) ' Identificar el nro con el que se guardó el origen en la tabla exp_origen

            Return paramExport
        End Function


        Public Shared Function mostrarReporte(ByVal paramExport As tnvExportarParam, Optional ByRef ActiveConnections As Dictionary(Of String, ADODB.Connection) = Nothing) As nvFW.tError
            Dim BinaryData() As Byte = Nothing
            Dim TextData As String = Nothing
            Dim path_temp As String = ""
            Dim XSL As New System.Xml.XmlDocument
            Dim XML As New System.Xml.XmlDocument

            '******************************************************************
            ' Controla y ajusta el valor de ContentType para que sea válido
            ' Solamente los que tienen (*) son entradas válidas, sino lo manda como PDF
            '   Valores de FormatType de  CR11
            '       00 = crEFTNoFormat
            '       01 = crEFTCrystalReport
            '       02 = crEFTDataInterChange
            '       03 = crEFTRecordStyle
            '       05 = crEFTCommaSeparatedValues
            '       06 = crEFTTabSeparatedValues
            '       07 = crEFTCharSeparatedValues
            '       08 = crEFTText
            '       09 = crEFTTabSeparatedText
            '       14 = crEFTWordForWindows (*) DOC
            '       23 = crEFTODBC
            '       24 = crEFTHTML32Standard
            '       25 = crEFTExplorer32Extend
            '       31 = crEFTPortableDocFormat (*) PDF
            '       32 = crEFTHTML40 (*) HTML
            '       34 = crEFTReportDefinition
            '       35 = crEFTExactRitchText
            '       36 = crEFTExcel97 (*) XLS
            '       37 = crEFTXML
            '       38 = crEFTExcelDataOnly
            '       39 = crEFTEditableRitchText
            '******************************************************************

            Dim ext As String = ""  ' Define la extención a devolver
            Dim FormatType As CrystalDecisions.Shared.ExportFormatType ' Se utiliza como parametro para la exportación de CR
            Dim logTrack As String = nvLog.getNewLogTrack()
            Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

            '*******************************************************
            ' Variable de error
            '*******************************************************
            Dim rptError As New tError()
            rptError.titulo = "Error al exportar"
            rptError.salida_tipo = paramExport.salida_tipo.ToString
            rptError.debug_src = "reportViewer::ExportarReporte"

            ''/******************************************************************************************/
            '// Ajusta las variables filtroXML y filtroWhere en función de vistaguardada y los parámetros
            ''/******************************************************************************************/
            rptError = nvXMLSQL.setFiltroXML(paramExport.filtroXML, paramExport.filtroWhere, paramExport.VistaGuardada, paramExport.filtroParams)
            If rptError.numError <> 0 Then
                Return rptError
            End If

            '********************************************************************************************
            ' Ajusta los parámetros en caso que filtroXML venga encriptado
            '********************************************************************************************
            setExportParam(paramExport)

            If paramExport.salida_tipo = nvenumSalidaTipo.no_definido Then paramExport.salida_tipo = nvenumSalidaTipo.adjunto

            If paramExport.content_disposition = "" Then paramExport.content_disposition = "attachment"

            Select Case paramExport.ContentType.ToLower()
                Case "application/vnd.ms-excel"
                    FormatType = CrystalDecisions.Shared.ExportFormatType.Excel ' 36 '//29
                    ext = ".xls"

                Case "application/msword"
                    FormatType = CrystalDecisions.Shared.ExportFormatType.WordForWindows '14
                    ext = ".doc"

                Case "text/html"
                    FormatType = CrystalDecisions.Shared.ExportFormatType.HTML40 '32
                    ext = ".html"
                    paramExport.content_disposition = "inline"

                Case "application/pdf"
                    FormatType = CrystalDecisions.Shared.ExportFormatType.PortableDocFormat '31
                    ext = ".pdf"
                    paramExport.content_disposition = "inline"

                Case Else
                    paramExport.ContentType = "application/pdf"
                    FormatType = CrystalDecisions.Shared.ExportFormatType.PortableDocFormat '31
                    ext = ".pdf"
                    'paramExport.content_disposition = "inline"

            End Select

            '********************************************************************************
            ' Mantener origen
            ' Guarda en la base de datos los parametros de entrada dandole un identificador
            '********************************************************************************
            If paramExport.mantener_origen Then
                If paramExport.id_exp_origen <= 0 Then
                    Dim strSQL As String = "exec exp_origen_add"
                    strSQL &= "'" & Replace(paramExport.VistaGuardada, "'", "''") & "', '" & Replace(paramExport.filtroXML, "'", "''") & "',"
                    strSQL &= "'" & Replace(paramExport.filtroWhere, "'", "''") & "', '" & Replace(paramExport.xsl_name, "'", "''") & "', '" & Replace(paramExport.path_xsl, "'", "''") & "', '" & Replace(paramExport.ContentType, "'", "''") & "', '" & Replace(paramExport.target, "'", "''") & "', '" & Replace(paramExport.salida_tipo, "'", "''") & "', '" & Replace(paramExport.parametros, "'", "''") & "'"

                    Dim rsOrigen As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                    paramExport.id_exp_origen = rsOrigen.Fields("id_exp_origen").Value
                Else
                    Dim strSQL As String = "update exp_origen_log set VistaGuardada="
                    strSQL &= "'" & Replace(paramExport.VistaGuardada, "'", "''") & "', filtroXML='" & Replace(paramExport.filtroXML, "'", "''") & "',"
                    strSQL &= " filtroWhere='" & Replace(paramExport.filtroWhere, "'", "''") & "', xsl_name='" & Replace(paramExport.xsl_name, "'", "''") & "', path_xsl='" & Replace(paramExport.path_xsl, "'", "''") & "', ContentType='" & Replace(paramExport.ContentType, "'", "''") & "', target='" & Replace(paramExport.target, "'", "''") & "', salida_tipo='" & Replace(paramExport.salida_tipo, "'", "''") & "', parametros='" & Replace(paramExport.parametros, "'", "''") & "'"
                    strSQL &= " where id_exp_origen=" & paramExport.id_exp_origen
                    nvDBUtiles.DBExecute(strSQL)
                End If
            End If

            '***********************************************************************
            ' Si VistaGuardada tiene valor utilizarlo, sino parsear el filtroXML
            '***********************************************************************
            'If Trim(paramExport.VistaGuardada) <> "" Then
            '    Dim rs2 As ADODB.Recordset = nvDBUtiles.DBExecute("select * from WRP_Config where vista = '" & paramExport.VistaGuardada & "'")
            '    paramExport.filtroXML = rs2.Fields("strXML").Value
            'End If                '//error filtroXML

            'If Trim(paramExport.filtroXML) = "" Then
            '    rptError.numError = 11002
            '    rptError.titulo = "Error al exportar"
            '    rptError.mensaje = "Falta el parametro filtroXML"
            '    Return rptError
            'End If

            '**********************************************************************
            ' Abre el filtro para controlarlo y para recuperar el valor de vista
            '**********************************************************************
            'Dim objfiltroXML As New System.Xml.XmlDocument
            'Try
            '    objfiltroXML.LoadXml(paramExport.filtroXML)
            'Catch ex As Exception
            '    rptError.parse_error_xml(ex)
            '    rptError.titulo = "Error al exportar"
            '    rptError.mensaje = "Error XML en el parametro filtroXML"
            '    rptError.debug_desc += vbCrLf & paramExport.filtroXML
            '    Return rptError
            'End Try

            Dim objfiltroXML As New System.Xml.XmlDocument
            objfiltroXML.LoadXml(paramExport.filtroXML)

            Dim vista As String = nvXMLUtiles.getAttribute_path(objfiltroXML, "criterio/select/@vista", "")

            If vista = "" Then
                vista = nvXMLUtiles.getAttribute_path(objfiltroXML, "criterio/procedure/@vista", "")
            End If

            '*********************************************************************
            ' Recuperar path de la plantilla
            ' Si xsl_name tiene valor utilizarlo, sino path_xsl
            ' Controlar que el archivo existe sino devuelve error
            ' Abrir el XSL si no se puede devuelve error
            ' Probar en la carpeta de la aplicacion y despues en meridiano
            '*********************************************************************
            Dim path_rel As New List(Of String)
            Dim nvApp As tnvApp = nvFW.nvApp.getInstance()
            path_rel.Add(nvApp.path_rel)
            path_rel.Add("FW")

            Dim path_reporte As String = ""
            Dim path_buscado As String = ""
            paramExport.report_name = paramExport.report_name.Replace("/", "\")
            paramExport.path_reporte = paramExport.path_reporte.Replace("/", "\")

            For Each rel In path_rel
                If paramExport.report_name.Length > 0 Then
                    path_buscado = nvServer.appl_physical_path & "App_Data\" & rel & "\report\" & vista & "\" & paramExport.report_name
                Else
                    If Not IO.File.Exists(paramExport.path_reporte) Then
                        path_buscado = nvServer.appl_physical_path & "App_Data\" & rel & "\" & paramExport.path_reporte
                    Else
                        path_buscado = paramExport.path_reporte
                    End If
                End If

                If IO.File.Exists(path_buscado) Then
                    path_reporte = path_buscado
                    Exit For
                End If
            Next

            'Identificar si se necesita el reporte existe

            If path_reporte = "" Then
                rptError.numError = "11003"
                rptError.titulo = "Error al exportar"
                rptError.mensaje = "El reporte no existe"
                'rptError.comentario = "El reporte no existe"
                rptError.debug_desc = "No se ha encontrado el reporte path_reporte='" & paramExport.path_reporte & "', report_name='" & paramExport.report_name & "', vista='" & vista & "'"
                Return rptError
            End If

            '***********************************************************************
            ' Recuperar datos
            ' var strSQL = XMLtoSQL(filtroXML, filtroWhere)
            ' Procesa el filtroXML y vevuelve un recordset con los datos resultado.
            ' Si no devuelve el recordset da error
            ' Luego controla el resultado, si existe el campo forxml_data, carga el 
            ' XML con esos datos, sino carga el resultado del recordset
            '***********************************************************************
            Dim arParam As New trsParam
            arParam("logTrack") = logTrack
            Dim rs As ADODB.Recordset = nvXMLSQL.XMLtoRecordset(paramExport.filtroXML, paramExport.filtroWhere, arParam, ActiveConnections)

            If rs Is Nothing Then
                If Not arParam("objError") Is Nothing Then
                    rptError = arParam("objError")
                Else
                    rptError.titulo = "Error al exportar"
                    rptError.mensaje = "La consulta no genera datos"
                    rptError.debug_desc = "El recordset viene viene nulo" & vbCrLf & arParam("SQL")
                End If

                Return rptError
            End If

            '**********************************************************************
            ' Abrir y cargar el reporte
            ' Crear lo objetos necesarios para mostrar el reporte
            '**********************************************************************
            ' Application
            ' Revisar creación condicional
            Dim rptDoc As New CrystalDecisions.CrystalReports.Engine.ReportDocument()
            Dim stopwatchCR As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

            Try
                rptDoc.Load(path_reporte) '//var oRpt = oApp.OpenReport(path_reporte, 1) //genera ~*.tmp
            Catch ex As Exception
                rptError.parse_error_script(ex)
                rptError.titulo = "Error al exportar"
                rptError.mensaje = "No se puede abrir el reporte"
                rptError.debug_desc &= vbCrLf & path_reporte
                stopwatchCR.Stop()

                Return rptError
            End Try

            '***********************************************************************************************
            ' Cambiar la conexión de los reportes y subreportes por la cadena de conexión de la aplicación
            ' Como los boludos de Crystal no permiten cambiar la cadena de conexión y administran una distinta para cada tabla
            ' Y ademas no tienen en el objeto una colección de subreportes hay que hacer todo a pata
            '***********************************************************************************************
            ' 1) Separar la cadena de conexión en sus propiedades

            'Dim properties() As String = nvSession.Contents("connection_string").split(";")
            'Dim cn_properties() As String '= New Array())
            'For a = 0 To properties.Length - 1
            '    If properties(a).Split("=").Length > 0 Then
            '        cn_properties(properties(a).Split("=")(0)) = properties(a).Split("=")(1)
            '    End If
            'Next
            '//rpt_change_connection(oRpt, cn_properties)  

            'Dim oADORecordset As ADODB.Recordset ' = Server.CreateObject("ADODB.Recordset"))
            'oADORecordset = rs

            'Dim oRptTable As Object = oRpt.Database.Tables.Item(1)
            'oRptTable.SetDataSource(oADORecordset, 3)

            Try

                If (rs.EOF = False) Then
                    rptDoc.SetDataSource(rs)
                Else
                    Dim miDS As System.Data.DataSet = New System.Data.DataSet()
                    Dim miDA As System.Data.OleDb.OleDbDataAdapter = New System.Data.OleDb.OleDbDataAdapter()
                    miDA.Fill(miDS, rs, "UnaTabla")
                    rptDoc.SetDataSource(miDS.Tables(0))
                End If

            Catch ex As Exception
                rptError.parse_error_script(ex)
                rptError.titulo = "Error al exportar"
                rptError.mensaje = "No se pueden recuperar los registros de la consulta"
                stopwatchCR.Stop()
                Return rptError
            End Try

            Try
                '**********************************************
                ' Parametros de exportación CR
                '**********************************************
                'CrystalExportOptions = oRpt.ExportOptions
                'oRpt.DisplayProgressDialog = False
                'CrystalExportOptions.FormatType = FormatType '//CREFTPORTABLEDOCFORMAT
                '//CrystalExportOptions.PDFExportAllPages = true
                '//CrystalExportOptions.DiskFileName = path_temp
                'CrystalExportOptions.DestinationType = 1 '//CREDTDISKFILE

                '******************************
                ' Exportar
                '******************************
                'Dim gvGroupPath() As VariantType
                'goPageGenerator = oRpt.PageEngine.CreatePageGenerator(gvGroupPath)
                'BinaryData = goPageGenerator.Export(8209)
                Dim ms As System.IO.MemoryStream = rptDoc.ExportToStream(FormatType)
                ReDim BinaryData(ms.Length - 1)
                ms.Read(BinaryData, 0, ms.Length)
            Catch ex As Exception
                rptError.parse_error_script(ex)
                rptError.titulo = "Error al exportar"
                rptError.mensaje = "No se pudo exportar el reporte"
                stopwatchCR.Stop()

                Return rptError
            End Try

            nvDBUtiles.DBCloseRecordset(rs, ActiveConnections Is Nothing)
            rptDoc.Close()
            stopwatchCR.Stop()

            Dim ts As TimeSpan = stopwatchCR.Elapsed
            nvLog.addEvent("rd_RStoRPT", ";" & logTrack & ";" & ts.TotalMilliseconds & ";" & path_reporte & ";" & BinaryData.Length)

            '*************************************************************
            ' Analizar salida en función de salida_tipo y target
            '*************************************************************
            arParam("Stopwatch") = Stopwatch
            Return exportarDestino(paramExport, BinaryData, TextData, path_temp, arParam)
        End Function


        Public Shared Sub setExportParam(ByRef paramExport As tnvExportarParam)
            Dim exportParams As String = ""
            Dim oFiltroXML As New System.Xml.XmlDocument
            Dim oExportParams As New System.Xml.XmlDocument

            Try
                ' Si viene encriptado desencriptarlo.
                oFiltroXML.LoadXml(paramExport.filtroXML)

                If Not oFiltroXML.SelectSingleNode("/enc") Is Nothing Then
                    exportParams = nvSecurity.nvCrypto.EncBase64ToStr(oFiltroXML.SelectSingleNode("/enc").InnerText)
                    oExportParams.LoadXml(exportParams)

                    If Not oExportParams.SelectSingleNode("criterio/export_params") Is Nothing Then
                        With paramExport
                            .filtroXML = ""
                            If Not oExportParams.SelectSingleNode("criterio/export_params/filtroXML") Is Nothing Then .filtroXML = oExportParams.SelectSingleNode("criterio/export_params/filtroXML").InnerText
                            If .filtroWhere = "" And Not oExportParams.SelectSingleNode("criterio/export_params/filtroWhere") Is Nothing Then .filtroWhere = oExportParams.SelectSingleNode("criterio/export_params/filtroWhere").InnerText
                            If .xml_xsl = "" And Not oExportParams.SelectSingleNode("criterio/export_params/xml_xsl") Is Nothing Then .xml_xsl = oExportParams.SelectSingleNode("criterio/export_params/xml_xsl").InnerText
                            If .xml_data = "" And Not oExportParams.SelectSingleNode("criterio/export_params/xml_data") Is Nothing Then .xml_data = oExportParams.SelectSingleNode("criterio/export_params/xml_data").InnerText
                            If .VistaGuardada = "" And Not oExportParams.SelectSingleNode("criterio/export_params/VistaGuardada") Is Nothing Then .VistaGuardada = oExportParams.SelectSingleNode("criterio/export_params/VistaGuardada").InnerText
                            If .content_disposition = "" And Not oExportParams.SelectSingleNode("criterio/export_params/content_disposition") Is Nothing Then .content_disposition = oExportParams.SelectSingleNode("criterio/export_params/content_disposition").InnerText
                            If .ContentType = "" And Not oExportParams.SelectSingleNode("criterio/export_params/ContentType") Is Nothing Then .ContentType = oExportParams.SelectSingleNode("criterio/export_params/ContentType").InnerText
                            If .export_exeption = "" And Not oExportParams.SelectSingleNode("criterio/export_params/export_exeption") Is Nothing Then .export_exeption = oExportParams.SelectSingleNode("criterio/export_params/export_exeption").InnerText
                            If .filename = "" And Not oExportParams.SelectSingleNode("criterio/export_params/filename") Is Nothing Then .filename = oExportParams.SelectSingleNode("criterio/export_params/filename").InnerText
                            If .filtroParams = "" And Not oExportParams.SelectSingleNode("criterio/export_params/filtroParams") Is Nothing Then .filtroParams = oExportParams.SelectSingleNode("criterio/export_params/filtroParams").InnerText
                            If .id_exp_origen = 0 And Not oExportParams.SelectSingleNode("criterio/export_params/id_exp_origen") Is Nothing Then .id_exp_origen = oExportParams.SelectSingleNode("criterio/export_params/id_exp_origen").InnerText
                            If .mantener_origen = False And Not oExportParams.SelectSingleNode("criterio/export_params/mantener_origen") Is Nothing Then
                                .mantener_origen = oExportParams.SelectSingleNode("criterio/export_params/mantener_origen").InnerText.ToLower = "true"
                            End If
                            If .parametros = "" And Not oExportParams.SelectSingleNode("criterio/export_params/parametros") Is Nothing Then .parametros = oExportParams.SelectSingleNode("criterio/export_params/parametros").InnerText
                            If .path_reporte = "" And Not oExportParams.SelectSingleNode("criterio/export_params/path_reporte") Is Nothing Then .path_reporte = oExportParams.SelectSingleNode("criterio/export_params/path_reporte").InnerText
                            If .path_xsl = "" And Not oExportParams.SelectSingleNode("criterio/export_params/path_xsl") Is Nothing Then .path_xsl = oExportParams.SelectSingleNode("criterio/export_params/path_xsl").InnerText
                            If .report_name = "" And Not oExportParams.SelectSingleNode("criterio/export_params/report_name") Is Nothing Then .report_name = oExportParams.SelectSingleNode("criterio/export_params/report_name").InnerText
                            If .salida_tipo = nvenumSalidaTipo.no_definido And Not oExportParams.SelectSingleNode("criterio/export_params/salida_tipo") Is Nothing Then
                                Dim salida_tipo As String = oExportParams.SelectSingleNode("criterio/export_params/salida_tipo").InnerText

                                Select Case salida_tipo.ToLower
                                    Case "estado"
                                        .salida_tipo = nvenumSalidaTipo.estado
                                    Case "adjunto"
                                        .salida_tipo = nvenumSalidaTipo.adjunto
                                    Case Else
                                        .salida_tipo = nvenumSalidaTipo.no_definido
                                End Select
                            End If
                            If .target = "" And Not oExportParams.SelectSingleNode("criterio/export_params/target") Is Nothing Then .target = oExportParams.SelectSingleNode("criterio/export_params/target").InnerText
                            If .xsl_name = "" And Not oExportParams.SelectSingleNode("criterio/export_params/xsl_name") Is Nothing Then .xsl_name = oExportParams.SelectSingleNode("criterio/export_params/xsl_name").InnerText
                        End With
                    End If
                End If
            Catch ex As Exception
            End Try
        End Sub


        Public Shared Function exportarReporte(ByVal paramExport As tnvExportarParam, Optional ByRef ActiveConnections As Dictionary(Of String, ADODB.Connection) = Nothing) As nvFW.tError
            Dim BinaryData() As Byte = Nothing
            Dim TextData As String = Nothing
            Dim path_temp As String = ""
            Dim XSL As New System.Xml.XmlDocument
            Dim XML As New System.Xml.XmlDocument
            Dim ext As String ' Define la extención a devolver
            Dim logTrack As String = nvLog.getNewLogTrack()
            Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

            '*******************************************************
            ' Variable de error
            '*******************************************************
            Dim rptError As New tError()
            rptError.titulo = "Error al exportar"
            rptError.salida_tipo = paramExport.salida_tipo.ToString
            rptError.debug_src = "reportViewer::ExportarReporte"

            Dim vista As String = ""

            If paramExport.xml_data = "" Then
                '*********************************************************************************************
                ' Ajusta las variables filtroXML y filtroWhere en función de vistaguardada y los parámetros
                '*********************************************************************************************
                rptError = nvXMLSQL.setFiltroXML(paramExport.filtroXML, paramExport.filtroWhere, paramExport.VistaGuardada, paramExport.filtroParams)

                If rptError.numError <> 0 Then
                    Return rptError
                End If

                If rptError.params("NoEncExecute") = True Then
                    logTrack = "NoEnc_" & logTrack
                End If


                Dim objfiltroXML As New System.Xml.XmlDocument
                objfiltroXML.LoadXml(paramExport.filtroXML)
                vista = nvXMLUtiles.getAttribute_path(objfiltroXML, "criterio/select/@vista", "")

                If vista = "" Then
                    vista = nvXMLUtiles.getAttribute_path(objfiltroXML, "criterio/procedure/@vista", "")
                End If
            End If

            '*********************************************************************************************
            ' Ajusta los parámetros en caso que filtroXML venga encriptado
            '*********************************************************************************************
            setExportParam(paramExport)

            If paramExport.salida_tipo = nvenumSalidaTipo.no_definido Then paramExport.salida_tipo = nvenumSalidaTipo.adjunto
            If paramExport.content_disposition = "" Then paramExport.content_disposition = "attachment"
            If paramExport.export_exeption = "" Then paramExport.export_exeption = "TransformFromXSL"

            Select Case paramExport.ContentType.ToLower()
                Case "application/vnd.ms-excel"
                    ext = ".xls"

                Case "application/msword"
                    ext = ".doc"

                Case "text/html"
                    ext = ".html"
                    paramExport.content_disposition = "inline"

                Case "application/pdf"
                    ext = ".pdf"
                    paramExport.content_disposition = "inline"

                Case "text/xml"
                    ext = ".xml"

                Case Else
                    paramExport.ContentType = "text/html"
                    ext = ".html"
                    paramExport.content_disposition = "inline"

            End Select

            ' Recuperar parametros adicionales
            Dim objParametros As New System.Xml.XmlDocument

            If paramExport.parametros <> "" Then
                Try
                    objParametros.LoadXml(paramExport.parametros)
                Catch ex As Exception
                    rptError.parse_error_xml(ex)
                    rptError.titulo = "Error al exportar"
                    rptError.mensaje = "Error de estructura XML en los parametros"
                    rptError.debug_desc &= vbCrLf & paramExport.parametros
                    Return rptError
                End Try
            End If

            '********************************************************************************
            ' Mantener origen
            ' Guarda en la base de datos los parametros de entrada dandole un identificador
            '********************************************************************************
            If paramExport.mantener_origen Then
                If paramExport.id_exp_origen <= 0 Then
                    Dim strSQL As String = "exec exp_origen_add"
                    strSQL &= "'" & Replace(paramExport.VistaGuardada, "'", "''") & "', '" & Replace(paramExport.filtroXML, "'", "''") & "',"
                    strSQL &= "'" & Replace(paramExport.filtroWhere, "'", "''") & "', '" & Replace(paramExport.xsl_name, "'", "''") & "', '" & Replace(paramExport.path_xsl, "'", "''") & "', '" & Replace(paramExport.ContentType, "'", "''") & "', '" & Replace(paramExport.target, "'", "''") & "', '" & Replace(paramExport.salida_tipo.ToString, "'", "''") & "', '" & Replace(paramExport.parametros, "'", "''") & "'"

                    Dim rsOrigen As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                    paramExport.id_exp_origen = rsOrigen.Fields("id_exp_origen").Value
                    nvDBUtiles.DBCloseRecordset(rsOrigen)
                Else
                    Dim strSQL As String = "update exp_origen_log set VistaGuardada="
                    strSQL &= "'" & Replace(paramExport.VistaGuardada, "'", "''") & "', filtroXML='" & Replace(paramExport.filtroXML, "'", "''") & "',"
                    strSQL &= " filtroWhere='" & Replace(paramExport.filtroWhere, "'", "''") & "', xsl_name='" & Replace(paramExport.xsl_name, "'", "''") & "', path_xsl='" & Replace(paramExport.path_xsl, "'", "''") & "', ContentType='" & Replace(paramExport.ContentType, "'", "''") & "', target='" & Replace(paramExport.target, "'", "''") & "', salida_tipo='" & Replace(paramExport.salida_tipo.ToString, "'", "''") & "', parametros='" & Replace(paramExport.parametros, "'", "''") & "'"
                    strSQL &= " where id_exp_origen=" & paramExport.id_exp_origen
                    nvDBUtiles.DBExecute(strSQL)
                End If
            End If

            '*********************************************************************
            ' Recuperar path de la plantilla
            ' Si xsl_name tiene valor utilizarlo, sino path_xsl
            ' Controlar que el archivo existe sino devuelve error
            ' Abrir el XSL si no se puede devuelve error
            ' Probar en la carpeta de la aplicacion y despues en meridiano
            '*********************************************************************
            Dim path_rel As New List(Of String)
            Dim nvApp As tnvApp = nvFW.nvApp.getInstance()
            path_rel.Add(nvApp.path_rel)
            path_rel.Add("FW")
            Dim path_xsl As String = ""
            Dim path_buscado As String = ""
            paramExport.xsl_name = paramExport.xsl_name.Replace("/", "\")
            paramExport.path_xsl = paramExport.path_xsl.Replace("/", "\")

            For Each rel In path_rel
                If paramExport.xsl_name.Length > 0 Then
                    path_buscado = nvServer.appl_physical_path & "App_Data\" & rel & "\report\" & vista & "\" & paramExport.xsl_name
                Else
                    If Not IO.File.Exists(paramExport.path_xsl) Then
                        path_buscado = nvServer.appl_physical_path & "App_Data\" & rel & "\" & paramExport.path_xsl
                    Else
                        path_buscado = paramExport.path_xsl
                    End If
                End If

                ' Limpiar el path para que no quede un doble slash "\\" por accidente
                path_buscado = IO.Path.GetFullPath(path_buscado)

                If IO.File.Exists(path_buscado) Then
                    path_xsl = path_buscado
                    Exit For
                End If
            Next

            ' Identificar si se necesita la plantilla, si la misma existe y si está confromada correctamente
            If paramExport.export_exeption.ToLower = "transformfromxsl" Then
                If path_xsl = "" AndAlso paramExport.xml_xsl = "" Then
                    rptError.numError = "11003"
                    rptError.titulo = "Error al exportar"
                    rptError.mensaje = "La plantilla XSL no existe"
                    rptError.debug_desc = "No se ha encontrado la plantilla path_xsl='" & paramExport.path_xsl & "', xsl_name='" & paramExport.xsl_name & "', vista='" & vista & "'"
                    Return rptError
                End If

                If path_xsl <> "" Then
                    Try
                        XSL.PreserveWhitespace = True
                        XSL.Load(path_xsl)
                    Catch ex As Exception
                        rptError.parse_error_xml(ex)
                        rptError.titulo = "Error al exportar"
                        rptError.mensaje = "La plantilla XSL contiene errores y no puede cargarse"
                        rptError.debug_desc += vbCrLf & path_xsl
                        Return rptError
                    End Try

                End If

                If paramExport.xml_xsl <> "" Then
                    Try
                        XSL.PreserveWhitespace = True
                        XSL.LoadXml(paramExport.xml_xsl)
                    Catch ex As Exception
                        rptError.parse_error_xml(ex)
                        rptError.titulo = "Error al exportar"
                        rptError.mensaje = "La plantilla XSL contiene errores y no puede cargarse"
                        rptError.debug_desc += vbCrLf & path_xsl
                        Return rptError
                    End Try
                End If

            End If

            '***********************************************************************
            ' Recuperar datos
            ' var strSQL = XMLtoSQL(filtroXML, filtroWhere)
            ' Procesa el filtroXML y vevuelve un recordset con los datos resultado.
            ' Si no devuelve el recordset da error
            ' Luego controla el resultado, si existe el campo forxml_data, carga el 
            ' XML con esos datos, sino carga el resultado del recordset
            '***********************************************************************
            Dim arParam As New trsParam
            arParam("logTrack") = logTrack
            arParam("vista") = vista
            Dim rs As ADODB.Recordset

            If paramExport.xml_data = "" Then
                rs = nvXMLSQL.XMLtoRecordset(paramExport.filtroXML, paramExport.filtroWhere, arParam, ActiveConnections)

                If rs Is Nothing Then
                    If Not arParam("objError") Is Nothing Then
                        rptError = arParam("objError")
                    Else
                        rptError.titulo = "Error al exportar"
                        rptError.mensaje = "La consulta no genera datos"
                        rptError.debug_desc = "El recordset viene viene nulo" & vbCrLf & arParam("SQL")
                    End If
                    Return rptError
                End If
            Else
                Try
                    XML.LoadXml(paramExport.xml_data)
                Catch ex As Exception
                    rptError.parse_error_xml(ex)
                    rptError.titulo = "Error al exportar"
                    rptError.comentario = "El XML DATA contiene errores y no puede cargarse"
                    Return rptError
                End Try
            End If

            '***********************************************************************
            ' Transformar a Excel
            ' Transforma el XML a Excel 
            '***********************************************************************
            Dim stopeatchTransform As System.Diagnostics.Stopwatch
            Dim ts As TimeSpan


            If paramExport.export_exeption.ToLower.IndexOf("rsxmltoexcel") > -1 AndAlso paramExport.xml_data = "" Then
                Try
                    stopeatchTransform = System.Diagnostics.Stopwatch.StartNew()
                    Dim xlsError As tError = nvReportUtiles.RSXMLtoExcelRs(rs, paramExport)
                    stopeatchTransform.Stop()
                    ts = stopeatchTransform.Elapsed

                    If xlsError.numError = 0 Then
                        path_temp = xlsError.params("path_temp")
                        nvLog.addEvent("rd_RStoRPT", ";" & logTrack & ";" & ts.TotalMilliseconds & ";RSXMLtoExcel;" & New System.IO.FileInfo(path_temp).Length)
                    Else
                        Return xlsError
                    End If

                    nvDBUtiles.DBCloseRecordset(rs, ActiveConnections Is Nothing)
                Catch ex As Exception
                    nvDBUtiles.DBCloseRecordset(rs, ActiveConnections Is Nothing)
                    rptError.parse_error_script(ex)
                    rptError.titulo = "Error al exportar"
                    rptError.mensaje &= vbCrLf & "No se pudo generar el archivo excel"
                    rptError.debug_src = "reportViewer::ExportarReporte::RSXMLtoExcelRs"
                    Return rptError
                End Try
            End If

            '***********************************************************************
            ' Transformar a XMLJson
            '***********************************************************************
            If paramExport.export_exeption.ToLower.IndexOf("rsxmltoxmljson") > -1 AndAlso paramExport.xml_data = "" Then
                Try
                    'Convertir el RS a XMLJSON
                    XML = nvXMLSQL.RecordsetToXMLJson(rs, arParam, objParametros)
                    nvDBUtiles.DBCloseRecordset(rs, ActiveConnections Is Nothing)
                    TextData = XML.OuterXml
                Catch ex4 As Exception
                End Try
            End If

            '***********************************************************************
            ' Transformar XML
            ' Transforma el XML con la plantilla XSL
            ' Si no puede devuelve error
            '***********************************************************************
            If paramExport.export_exeption.ToLower = "transformfromxsl" Then
                Try
                    arParam("id_exp_origen") = paramExport.id_exp_origen
                    arParam("mantener_origen") = IIf(paramExport.mantener_origen, "1", "0")

                    ' Convertir el RS a XML
                    If paramExport.xml_data = "" Then
                        XML = nvXMLSQL.RecordsetToXML(rs, arParam, objParametros)
                        nvDBUtiles.DBCloseRecordset(rs, ActiveConnections Is Nothing)
                    Else
                        XML = New System.Xml.XmlDocument
                        XML.LoadXml(paramExport.xml_data)
                    End If

                    stopeatchTransform = System.Diagnostics.Stopwatch.StartNew()

                    Dim enebleDebug As Boolean = nvServer.getConfigValue("/config/global/transformXSL/@enableDebug", "False").ToLower = "true"
                    Dim method As String = nvServer.getConfigValue("/config/global/transformXSL/@method", "XMLDocument").ToLower
                    Dim indent As Boolean = nvServer.getConfigValue("/config/global/transformXSL/@indent", "False").ToLower = "true"
                    Dim cacheXslCompiledTransform As Boolean = nvServer.getConfigValue("/config/global/transformXSL/@cacheXslCompiledTransform", "False").ToLower = "true"

                    If method = "xmldocument" Then
                        Dim XSLTrans As System.Xml.Xsl.XslCompiledTransform

                        If cacheXslCompiledTransform AndAlso _cacheXslCompiledTransform.ContainsKey(path_xsl) Then
                            SyncLock New Object
                                XSLTrans = _cacheXslCompiledTransform(path_xsl)
                            End SyncLock
                        Else
                            XSLTrans = New System.Xml.Xsl.XslCompiledTransform(enebleDebug)
                            ' Habilitar ejecución de scripts
                            Dim settings As New System.Xml.Xsl.XsltSettings(False, True)

                            ' Se le debe dar un XmlUrlResolver para que pueda resolver los includes e imports de la plantilla
                            Dim xmlUrlResolver As New XmlUrlResolver()
                            XSLTrans.Load(XSL, settings, xmlUrlResolver)

                            If cacheXslCompiledTransform Then _cacheXslCompiledTransform.Add(path_xsl, XSLTrans)
                        End If

                        Dim output As New IO.MemoryStream
                        Dim writer As New nvFW.nvXmlHtmlWriter(output, nvConvertUtiles.currentEncoding)

                        ' Indemtar el resultado
                        If indent Then writer.Formatting = Formatting.Indented

                        XSLTrans.Transform(XML, writer)
                        output.Seek(0, IO.SeekOrigin.Begin)
                        Dim reader As IO.StreamReader = New IO.StreamReader(output, nvConvertUtiles.currentEncoding)
                        TextData = reader.ReadToEnd()
                        reader.Close()
                        writer.Close()
                        output.Close()
                    Else
                        '*** DOMDocument
                        Dim oXML As New MSXML2.DOMDocument
                        Dim oXMLXSL As New MSXML2.DOMDocument
                        oXML.loadXML(XML.OuterXml)
                        oXMLXSL.loadXML(XSL.OuterXml)
                        TextData = oXML.transformNode(oXMLXSL)
                    End If

                    stopeatchTransform.Stop()
                    ts = stopeatchTransform.Elapsed
                    nvLog.addEvent("rd_RStoRPT", ";" & logTrack & ";" & ts.TotalMilliseconds & ";" & path_xsl & ";" & TextData.Length)
                Catch ex As Exception
                    rptError.parse_error_script(ex)
                    rptError.titulo = "Error al exportar"
                    rptError.mensaje = "No se pudo realizar el plantillado XSL"
                    rptError.debug_desc += vbCrLf & path_xsl
                    Return rptError
                End Try
            End If

            '*********************************************************************
            ' Transformar a XMLNone
            '*********************************************************************
            If paramExport.export_exeption = "XMLNone" Then
                If paramExport.xml_data = "" Then
                    XML = nvXMLSQL.RecordsetToXML(rs, arParam, objParametros)
                    nvDBUtiles.DBCloseRecordset(rs, ActiveConnections Is Nothing)
                    TextData = XML.OuterXml
                Else
                    TextData = paramExport.xml_data
                End If
            End If

            '********************************************************************
            ' Genera el path del archivo temporal
            '********************************************************************

            '//archivo_tmp = "exp_" + Session.SessionID + ext
            '//path_temp = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "\FW\\reportViewer\\tmp\\" + archivo_tmp

            'Dim archivo_tmp As String = "exp_" & nvSession.IDSession & ext
            'If path_archivo = "" Then
            '    path_temp = System.IO.Path.GetTempPath & archivo_tmp
            'End If

            '*************************************************************
            ' Analizar salida en función de salida_tipo y target
            '*************************************************************            

            arParam("Stopwatch") = Stopwatch
            Return (exportarDestino(paramExport, Nothing, TextData, path_temp, arParam))
        End Function


        Public Shared Function exportarDestino(ByVal paramExport As tnvExportarParam, ByRef BinaryData As Byte(), ByRef TextData As String, ByRef path_temp As String, ByRef arParam As trsParam) As nvFW.tError
            '***********************************************************************
            '   DEVOLVER EL RESULTADO
            '   Parametros
            '       salida_tipo = ['estado'|'adjunto'] = identifica que info se escribe en el flujo de salida.
            '       target = definición de destinos separados por ";"
            '   Los datos pueden estar en tres contenedores.
            '       1) variable BinaryData
            '       2) Archivo que se encuentra en el "path_temp"
            '       3) variable string "TextData"
            '***********************************************************************
            Dim rptError As New nvFW.tError
            rptError.salida_tipo = paramExport.salida_tipo.ToString
            Dim stopwatch As System.Diagnostics.Stopwatch

            If arParam("Stopwatch").GetType().ToString = "System.Diagnostics.Stopwatch" Then
                stopwatch = arParam("Stopwatch")
            Else
                stopwatch = System.Diagnostics.Stopwatch.StartNew
            End If

            Try
                Dim path_destino As String = ""
                Dim file_exists As Boolean = False
                Try
                    '***********************************************************
                    '   Analizar salida
                    '***********************************************************
                    Dim destinos As List(Of Dictionary(Of String, String)) = nvReportUtiles.target_parse(paramExport.target)
                    Dim destino As Dictionary(Of String, String)

                    For Each destino In destinos
                        Select Case destino("protocolo").ToUpper
                            Case "FILE" ' Copia el archivo resultado al destino
                                path_destino = destino("path")
                                nvReportUtiles.create_folder(path_destino)
                                stopwatch = System.Diagnostics.Stopwatch.StartNew

                                ' Chequear dentro del archivo comprimido 
                                If destino("comp_metodo") <> "" And destino("target_agregar") = "true" Then
                                    rptError = nvReportUtiles.zipDescomprimirArchivo(destino("path"), path_destino, destino("comp_filename"), destino("comp_pwd"))

                                    If (rptError.numError <> 0) Then
                                        Continue For
                                    End If
                                End If

                                ' Si existe el destino renombrarlo
                                ' aca va la conversion
                                If path_temp <> "" OrElse destino("xls_save_as") <> "" OrElse destino("target_agregar") = "true" Then
                                    If destino("xls_save_as") <> "" Or (System.IO.File.Exists(path_destino) And destino("target_agregar") = "true" And (destino("extencion") = ".xls" Or destino("extencion") = ".xlsx")) Then
                                        If Not BinaryData Is Nothing Then
                                            path_temp = System.IO.Path.GetTempPath
                                            Dim fs As New System.IO.FileStream(path_temp, FileMode.Create)
                                            fs.Write(BinaryData, 0, BinaryData.Length)
                                            fs.Close()
                                            BinaryData = Nothing
                                        End If

                                        If Not TextData Is Nothing Then
                                            path_temp = System.IO.Path.GetTempFileName
                                            Dim fs As New System.IO.FileStream(path_temp, FileMode.Create)
                                            BinaryData = nvConvertUtiles.StringToBytes(TextData)
                                            fs.Write(BinaryData, 0, BinaryData.Length)
                                            fs.Close()
                                            BinaryData = Nothing
                                            TextData = Nothing
                                        End If
                                    End If

                                    ' en el caso que tengamos que convertir el formato
                                    If destino("xls_save_as") <> "" Then
                                        rptError = nvReportUtiles.excelConvertirA(destino("xls_save_as"), path_temp)

                                        If (rptError.numError <> 0) Then
                                            Continue For
                                        End If

                                        If System.IO.File.Exists((path_temp & ".pdf")) And destino("xls_save_as") = 57 Then
                                            path_temp = path_temp & ".pdf"
                                        End If

                                    End If
                                End If

                                If System.IO.File.Exists(path_destino) And destino("target_agregar") = "true" And (destino("extencion") = ".xls" Or destino("extencion") = ".xlsx") Then
                                    rptError = nvReportUtiles.excelABMLibro(path_temp, path_destino, nombre_hoja:=paramExport.page_name)

                                    If (rptError.numError <> 0) Then
                                        Continue For
                                    End If

                                    System.IO.File.Copy(path_destino, path_temp, True)
                                End If

                                ' Datos binarios 
                                If Not BinaryData Is Nothing Then
                                    Dim mStream As New ADODB.Stream
                                    mStream.Mode = 3 ' adModeReadWrite
                                    mStream.Type = 1

                                    Try
                                        mStream.Charset = If(destino("codificacion") = String.Empty, nvConvertUtiles.currentEncoding.HeaderName, destino("codificacion"))
                                    Catch ex As Exception
                                    End Try

                                    mStream.Open()
                                    mStream.Write(BinaryData)
                                    mStream.SaveToFile(path_destino, 2)
                                    mStream.Close()
                                    '  Continue For
                                End If

                                ' Si viene en el archivo temporal
                                If System.IO.File.Exists(path_temp) Then
                                    System.IO.File.Copy(path_temp, path_destino, True)
                                    '   Continue For
                                End If

                                ' Si viene en el text data
                                If Not TextData Is Nothing Then

                                    Dim a As New System.IO.StreamWriter(path_destino, False, If(destino("codificacion") = String.Empty, nvConvertUtiles.currentEncoding, System.Text.Encoding.GetEncoding(destino("codificacion"))))
                                    a.Write(TextData)
                                    a.Close()

                                End If

                                If destino("comp_metodo") <> "" AndAlso System.IO.File.Exists(path_destino) Then
                                    rptError = nvReportUtiles.zipComprimirArchivo(destino, True, destino("comp_filename"))

                                    If (rptError.numError <> 0) Then
                                        Continue For
                                    End If
                                End If

                                stopwatch.Stop()
                                Dim ts2 As TimeSpan = stopwatch.Elapsed
                                nvLog.addEvent("rd_RStoDest", ";" & arParam("logTrack") & ";" & ts2.TotalMilliseconds & ";FILE;" & path_destino)

                            Case "MAILTO"
                                Dim mailto = destino
                                Dim attch_path_destino = destino("attch")
                                stopwatch = System.Diagnostics.Stopwatch.StartNew()

                                If Not System.IO.File.Exists(attch_path_destino) And path_destino = "" Then
                                    path_destino = nvReportUtiles.get_file_path(destino("path"))
                                    nvReportUtiles.create_folder(path_destino)

                                    ' Datos binarios 
                                    If Not BinaryData Is Nothing Then
                                        Dim mStream As New ADODB.Stream
                                        mStream.Mode = 3 ' adModeReadWrite

                                        Try
                                            mStream.Charset = If(destino("codificacion") = String.Empty, nvConvertUtiles.currentEncoding.HeaderName, destino("codificacion"))
                                        Catch ex As Exception
                                        End Try

                                        mStream.Type = 1
                                        mStream.Open()
                                        mStream.Write(BinaryData)
                                        mStream.SaveToFile(path_destino, 2)
                                        mStream.Close()
                                        'Continue For
                                    End If

                                    If System.IO.File.Exists(path_temp) Then
                                        System.IO.File.Copy(path_temp, path_destino, True)
                                        Continue For
                                    End If

                                    If Not TextData Is Nothing Then
                                        Dim a As New System.IO.StreamWriter(path_destino, False, If(destino("codificacion") = String.Empty, nvConvertUtiles.currentEncoding, System.Text.Encoding.GetEncoding(destino("codificacion"))))
                                        a.Write(TextData)
                                        a.Close()
                                    End If

                                End If

                                mailto.Remove("attch")
                                mailto.Add("attch", path_destino)

                                Try
                                    nvReportUtiles.sql_mail_send(mailto("to"), mailto("cc"), mailto("bcc"), mailto("subject"), mailto("body"), mailto("attch"))
                                Catch ex As Exception
                                End Try

                                stopwatch.Stop()
                                Dim ts3 As TimeSpan = stopwatch.Elapsed
                                nvLog.addEvent("rd_RStoDest", ";" & arParam("logTrack") & ";" & ts3.TotalMilliseconds & ";MAILTO;""" & mailto("to") & """")
                        End Select
                    Next
                Catch ex As Exception
                    rptError.parse_error_script(ex)
                    rptError.titulo = "Error al procesar el destino"
                    rptError.mensaje = "Ocurrió un error al exportar el destino"
                    rptError.debug_src = "reportVierwer::exportarDestino"
                    Return rptError
                End Try



                Select Case paramExport.salida_tipo.ToString.ToLower()
                    Case "adjunto"
                        HttpContext.Current.Response.ContentType = paramExport.ContentType
                        HttpContext.Current.Response.Charset = nvConvertUtiles.currentEncoding.HeaderName 'ISO-8859-1

                        If paramExport.filename = "" And path_destino <> "" Then
                            paramExport.filename = path_destino
                        End If

                        If paramExport.content_disposition <> "" Then
                            HttpContext.Current.Response.AddHeader("Content-Disposition", paramExport.content_disposition & IIf(paramExport.filename <> "", ";filename=" & paramExport.filename, ""))
                        End If

                        ' Si viene un achivo cargar el binaryData
                        If BinaryData Is Nothing And System.IO.File.Exists(path_temp) Then
                            Dim mStream As New ADODB.Stream
                            mStream.Mode = 3 ' adModeReadWrite: indica permisos de lectura/escritura
                            mStream.Type = 1 ' adTypeBinary: indica datos binarios
                            mStream.Open()
                            mStream.LoadFromFile(path_temp)
                            BinaryData = mStream.Read()
                            mStream.Close()
                        End If

                        If Not BinaryData Is Nothing Then
                            HttpContext.Current.Response.BinaryWrite(BinaryData)
                        Else
                            HttpContext.Current.Response.Write(TextData)
                        End If

                        rptError = New nvFW.tError

                    Case "estado"
                        rptError = New nvFW.tError
                        rptError.salida_tipo = paramExport.salida_tipo.ToString
                        HttpContext.Current.Response.Charset = nvConvertUtiles.currentEncoding.HeaderName 'ISO-8859-1
                        HttpContext.Current.Response.ContentType = "application/xml" '"text/xml"
                        HttpContext.Current.Response.AddHeader("Content-Disposition", "inline;filename=error.xml")
                        HttpContext.Current.Response.Write(rptError.get_error_xml())

                        Return rptError

                    Case "return"

                    Case "returnwithbinary"
                        ' Si viene un achivo cargar el binaryData
                        If BinaryData Is Nothing And System.IO.File.Exists(path_temp) Then
                            Dim mStream As New ADODB.Stream
                            mStream.Mode = 3 ' adModeReadWrite
                            mStream.Type = 1
                            mStream.Open()
                            mStream.LoadFromFile(path_temp)
                            BinaryData = mStream.Read()
                            mStream.Close()
                        End If

                        If Not BinaryData Is Nothing Then
                            rptError.params("reportBinary") = Convert.ToBase64String(BinaryData)
                        Else
                            rptError.params("reportBinary") = Convert.ToBase64String(nvConvertUtiles.StringToBytes(TextData))
                        End If

                End Select

                'Eliminar el archivo
                Try
                    If IO.File.Exists(path_temp) Then System.IO.File.Delete(path_temp)
                Catch ex As Exception

                End Try

                TextData = Nothing
                BinaryData = Nothing
                stopwatch.Stop()

                Dim ts As TimeSpan = stopwatch.Elapsed
                nvLog.addEvent("rd_EndRPT", arParam("logTrack") & ";;" & ts.TotalMilliseconds & nvLog.parentLogParams)

                'Esto es lo final
                If arParam("logTrack").Length > 0 AndAlso arParam("logTrack").Substring(0, 6) = "NoEnc_" Then
                    'Vista, cantidad de registros,consulta , tiempo total
                    Dim strLg_NoEncExecute = arParam("logTrack") & ";" & arParam("vista") & ";" & arParam("recordcount") & ";" & arParam("SQL") & ";" & ts.TotalMilliseconds
                    nvLog.addEvent("lg_NoEncExecute", strLg_NoEncExecute)
                End If

                Return rptError
            Catch ex As Exception
                rptError.parse_error_script(ex)
                rptError.titulo = "Error al exportar al destino"
                rptError.debug_src = "reportViewer::exportarDestino"
                nvLog.parentStopwatch = Nothing
                Return rptError
            End Try

        End Function
    End Class


    Public Class nvReportUtiles

        Public Shared Function RSXMLtoExcelRs(ByVal rs As ADODB.Recordset, paramExport As tnvExportarParam) As tError
            'Name    Value	Description	Extension
            'xlAddIn 18	Microsoft Excel 97-2003 Add-In	*.xla
            'xlAddIn8    18	Microsoft Excel 97-2003 Add-In	*.xla
            'xlCSV   6	CSV	*.csv
            'xlCSVMac    22	Macintosh CSV	*.csv
            'xlCSVMSDOS  24	MSDOS CSV	*.csv
            'xlCSVWindows    23	Windows CSV	*.csv
            'xlCurrentPlatformText   -4158	Current Platform Text	*.txt
            'xlDBF2  7	Dbase 2 format	*.dbf
            'xlDBF3  8	Dbase 3 format	*.dbf
            'xlDBF4  11	Dbase 4 format	*.dbf
            'xlDIF   9	Data Interchange format	*.dif
            'xlExcel12   50	Excel Binary Workbook	*.xlsb
            'xlExcel2    16	Excel version 2.0 (1987)	*.xls
            'xlExcel2FarEast 27	Excel version 2.0 far east (1987)	*.xls
            'xlExcel3    29	Excel version 3.0 (1990)	*.xls
            'xlExcel4    33	Excel version 4.0 (1992)	*.xls
            'xlExcel4Workbook    35	Excel version 4.0. Workbook format (1992)	*.xlw
            'xlExcel5    39	Excel version 5.0 (1994)	*.xls
            'xlExcel7    39	Excel 95 (version 7.0)	*.xls
            'xlExcel8    56	Excel 97-2003 Workbook	*.xls
            'xlExcel9795 43	Excel version 95 And 97	*.xls
            'xlHtml  44	HTML format	*.htm; *.html
            'xlIntlAddIn 26	International Add-In	No file extension
            'xlIntlMacro 25	International Macro	No file extension
            'xlOpenDocumentSpreadsheet   60	OpenDocument Spreadsheet	*.ods
            'xlOpenXMLAddIn  55	Open XML Add-In	*.xlam
            'xlOpenXMLStrictWorkbook 61(&;H3D)  Strict Open XML file	*.xlsx
            'xlOpenXMLTemplate   54	Open XML Template	*.xltx
            'xlOpenXMLTemplateMacroEnabled   53	Open XML Template Macro Enabled	*.xltm
            'xlOpenXMLWorkbook   51	Open XML Workbook	*.xlsx
            'xlOpenXMLWorkbookMacroEnabled   52	Open XML Workbook Macro Enabled	*.xlsm
            'xlSYLK  2	Symbolic Link format	*.slk
            'xlTemplate  17	Excel Template format	*.xlt
            'xlTemplate8 17	Template 8	*.xlt
            'xlTextMac   19	Macintosh Text	*.txt
            'xlTextMSDOS 21	MSDOS Text	*.txt
            'xlTextPrinter   36	Printer Text	*.prn
            'xlTextWindows   20	Windows Text	*.txt
            'xlUnicodeText   42	Unicode Text	No file extension; *.txt
            'xlWebArchive    45	Web Archive	*.mht; *.mhtml
            'xlWJ2WD1    14	Japanese 1-2-3	*.wj2
            'xlWJ3   40	Japanese 1-2-3	*.wj3
            'xlWJ3FJ3    41	Japanese 1-2-3 format	*.wj3
            'xlWK1   5	Lotus 1-2-3 format	*.wk1
            'xlWK1ALL    31	Lotus 1-2-3 format	*.wk1
            'xlWK1FMT    30	Lotus 1-2-3 format	*.wk1
            'xlWK3   15	Lotus 1-2-3 format	*.wk3
            'xlWK3FM3    32	Lotus 1-2-3 format	*.wk3
            'xlWK4   38	Lotus 1-2-3 format	*.wk4
            'xlWKS   4	Lotus 1-2-3 format	*.wks
            'xlWorkbookDefault   51	Workbook default	*.xlsx
            'xlWorkbookNormal    -4143	Workbook normal	*.xls
            'xlWorks2FarEast 28	Microsoft Works 2.0 far east format	*.wks
            'xlWQ1   34	Quattro Pro format	*.wq1
            'xlXMLSpreadsheet    46	XML Spreadsheet	*.xml

            '**************************************
            ' Revisar permisos de DCOM
            '**************************************
            'Ejecutar mmc comexp.msc /32
            'Buscar el componente Microsoft Excel Application y darle una cuenta con privilegios.
            'Componentes DCOM

            Dim export_exeption As String = paramExport.export_exeption
            Dim lfilas As Integer = If(export_exeption = "RSXMLtoExcel", 1048575, 65535) ' Cantidad de filas por hoja / mirar version de excel
            Dim ext_modelo As String = If(export_exeption = "RSXMLtoExcel", ".xlsx", ".xls")
            Dim formatExcel As Integer = If(export_exeption = "RSXMLtoExcel", 51, 56)
            Dim n_hoja As Integer ' !!! investigar si su uso hace falta
            Dim AbsoluteFila As Integer ' !!! investigar si su uso hace falta
            Dim path_temp As String
            Dim hoja_nueva As Boolean = True
            Dim exAPP As Excel.Application '  = new ActiveXObject("Excel.Application")
            Dim exLibro As Excel.Workbook
            Dim exHoja As Excel.Worksheet

            Dim rptError As New tError
            rptError.debug_src = "reportViewer::RSXMLtoExcelRs"

            Try
                rptError.numError = 8
                rptError.mensaje = "Error al instanciar la aplicación Excel" 'new ActiveXObject("Excel.Application")'

                exAPP = New Excel.Application '  = new ActiveXObject("Excel.Application")
                exAPP.Visible = False
                exAPP.DisplayAlerts = False

                rptError.numError = 9
                rptError.mensaje = "No se pudo crear el libro"
                exLibro = exAPP.Workbooks.Add

                ' Dejar solo una hoja
                While exLibro.Worksheets.Count > 1
                    exLibro.Worksheets(2).delete
                End While

                rptError.numError = 10
                rptError.mensaje = "El modelo debe tener al menos una hoja" 'exLibro.Worksheets(1)
                exHoja = exLibro.Worksheets(1)
                exHoja.Name = If(paramExport.page_name = "", "Hoja1", paramExport.page_name)
                n_hoja = 1
                AbsoluteFila = 0

                Dim pages_count As Integer = Math.Ceiling(rs.RecordCount / (lfilas - 1))

                If pages_count = 1 Then
                End If

                Dim stw As New System.Diagnostics.Stopwatch
                stw.Start()
                Dim times As New Dictionary(Of Integer, trsParam)
                Dim page_i As Integer
                Dim rs_clon As ADODB.Recordset

                For page_i = 1 To pages_count
                    Dim rd As New trsParam

                    For c = 0 To rs.Fields.Count - 1
                        exHoja.Cells(1, c + 1) = rs.Fields.Item(c).Name

                        ' si es varchar lo formateamos directamente como texto porque en algunos casos el formato general lo expresa de mala manera
                        If rs.Fields.Item(c).Type = 202 Then
                            exAPP.Columns(c + 1).Select()
                            exAPP.Selection.NumberFormat = "@"
                        End If

                        ' si es numerico pero la precision supera los 11 digitos, le decimos al excel que es numerico sino el formate general no lo resuelve "1,0001E+12"
                        If rs.Fields.Item(c).Type = 131 And rs.Fields.Item(c).Precision > 11 Then
                            exAPP.Columns(c + 1).Select()
                            exAPP.Selection.NumberFormat = "0"
                        End If
                    Next

                    Dim arParam As New trsParam
                    arParam("AbsolutePage") = page_i
                    arParam("PageSize") = lfilas

                    ' Copiar recordset
                    Dim st_copiar As New System.Diagnostics.Stopwatch
                    st_copiar.Start()

                    Dim exclude_types As New List(Of ADODB.DataTypeEnum)
                    exclude_types.Add(141)
                    rs_clon = nvXMLSQL.DBRecordsetCopiar(rs, arParam, exclude_types)
                    st_copiar.Stop()
                    rd("RSCopiar_ms") = st_copiar.ElapsedMilliseconds

                    Dim st_copiarexcel As New System.Diagnostics.Stopwatch
                    st_copiarexcel.Start()
                    exHoja.Cells(2, 1).CopyFromRecordset(rs_clon)
                    st_copiarexcel.Stop()
                    rd("RSCopiarExcel_ms") = st_copiarexcel.ElapsedMilliseconds

                    nvDBUtiles.DBCloseRecordset(rs_clon)

                    If page_i < pages_count Then
                        n_hoja += 1

                        Try
                            Dim ojaAnterior = exHoja
                            exHoja = exLibro.Worksheets.Add()
                            exHoja.Move(After:=ojaAnterior)
                        Catch ex As Exception
                        End Try

                        exHoja.Name = paramExport.page_name & (page_i - 1)
                    End If

                    times.Add(page_i, rd)
                Next

                stw.Stop()
                Dim ms As Long = stw.ElapsedMilliseconds

                ' Formatea la primer fila
                For c = 1 To exLibro.Worksheets.Count
                    exHoja = exLibro.Worksheets(c)
                    exHoja.Select()
                    exAPP.Rows("1:1").Select()
                    exAPP.Selection.Font.Bold = True
                    exAPP.Selection.HorizontalAlignment = -4108 ' xlCenter
                    exAPP.Selection.VerticalAlignment = -4107 ' xlBottom
                    exAPP.Selection.WrapText = False
                    exAPP.Selection.Orientation = 0
                    exAPP.Selection.AddIndent = False
                    exAPP.Selection.IndentLevel = 0
                    exAPP.Selection.ShrinkToFit = False
                    exAPP.Selection.ReadingOrder = -5002 ' xlContext
                    exAPP.Selection.MergeCells = False
                    exAPP.Rows.Select()
                    exAPP.Selection.RowHeight = 12.75
                    exHoja.Cells.Select()
                    exAPP.Cells.EntireColumn.AutoFit()
                Next

                rptError.numError = "11"
                rptError.mensaje = "Errror al crear el archivo temporal"
                path_temp = System.IO.Path.GetTempFileName

                '**********************************************
                ' Guardar archivo
                '**********************************************
                rptError.numError = 12
                rptError.mensaje = "Error al intentar guardar el archivo temporal."

                Try
                    exLibro.SaveAs(path_temp, FileFormat:=formatExcel, Password:="", WriteResPassword:="", ReadOnlyRecommended:=False, CreateBackup:=False)
                Catch ex1 As System.Runtime.InteropServices.COMException
                    Throw ex1
                End Try

                For c = 1 To exAPP.Workbooks.Count
                    exAPP.Workbooks(c).Close(True)
                Next

                exAPP.Quit()

                Try
                    System.Runtime.InteropServices.Marshal.FinalReleaseComObject(exAPP)
                Catch ex As Exception
                End Try

                rptError = New tError
                rptError.params.Add("path_temp", path_temp)
                Return rptError  ' Devuelve el path del archivo
            Catch ex As Exception
                If Not exAPP Is Nothing Then
                    For c = 1 To exAPP.Workbooks.Count
                        exAPP.Workbooks(c).Close(False)
                    Next

                    exAPP.Quit()

                    Try
                        System.Runtime.InteropServices.Marshal.FinalReleaseComObject(exAPP)
                    Catch ex0 As Exception
                    End Try

                    ' Eliminar el archivo si fue creado
                    Try
                        If System.IO.File.Exists(path_temp) Then System.IO.File.Delete(path_temp)
                    Catch ex1 As Exception
                    End Try

                    Return rptError
                End If
            End Try
        End Function


        Public Shared Function target_parse(ByVal target As String) As List(Of Dictionary(Of String, String))
            Dim i As Integer
            ' Los targets vienen separados por ;
            ' Utiliza el split si sencuentra el ; o simplemente asigna el valor al primer elemento
            Dim destinos() As String

            If target.IndexOf(";") = -1 Then
                ReDim destinos(0)
                destinos(0) = target
            Else
                destinos = target.Split(";")
            End If

            ' Elimina los espacio al principio
            Dim oXMl As New System.Xml.XmlDocument
            Dim arrTarget As New List(Of Dictionary(Of String, String))
            Dim protocolo As String
            Dim eTarget As Dictionary(Of String, String)

            For Each target In destinos
                If target = "" Then Continue For

                protocolo = target.Substring(0, target.IndexOf("://")).ToUpper
                Dim target_basic As String
                Dim target_params As String

                If target.IndexOf("||") > -1 Then
                    Dim stringSeparators() As String = {"||"}
                    target_basic = target.Split(stringSeparators, System.StringSplitOptions.RemoveEmptyEntries)(0)
                    target_params = target.Split(stringSeparators, System.StringSplitOptions.RemoveEmptyEntries)(1)

                    Try
                        oXMl.LoadXml(target_params)
                    Catch ex As Exception
                    End Try
                Else
                    target_basic = target
                    target_params = ""
                End If

                Select Case protocolo
                    Case "FILE" ' Copia el archivo resultado al destino
                        eTarget = nvReportUtiles.target_get_file(target_basic)
                        arrTarget.Add(eTarget)

                    Case "MAILTO"
                        eTarget = nvReportUtiles.target_get_mailto(target_basic)
                        arrTarget.Add(eTarget)

                    Case "NAME" ' Copia el archivo resultado al destino
                        eTarget = New Dictionary(Of String, String)
                        eTarget.Add("protocolo", protocolo)
                        eTarget.Add("filename", target_basic.Substring(target.IndexOf("://") + 3, target_basic.Length))
                        arrTarget.Add(eTarget)

                    Case Else
                        eTarget = New Dictionary(Of String, String)
                        eTarget.Add("protocolo", protocolo)
                        arrTarget.Add(eTarget)
                End Select

                eTarget.Add("xls_save_as", nvXMLUtiles.getAttribute_path(oXMl, "opcional/@xls_save_as", ""))
                eTarget.Add("comp_metodo", nvXMLUtiles.getAttribute_path(oXMl, "opcional/@comp_metodo", ""))
                eTarget.Add("comp_algoritmo", nvXMLUtiles.getAttribute_path(oXMl, "opcional/@comp_algoritmo", ""))
                eTarget.Add("comp_pwd", nvXMLUtiles.getAttribute_path(oXMl, "opcional/@comp_pwd", ""))
                eTarget.Add("comp_filename", nvXMLUtiles.getAttribute_path(oXMl, "opcional/@comp_filename", ""))
                eTarget.Add("target_agregar", nvXMLUtiles.getAttribute_path(oXMl, "opcional/@target_agregar", ""))
                eTarget.Add("codificacion", nvXMLUtiles.getAttribute_path(oXMl, "opcional/@codificacion", ""))
                eTarget.Add("target_basic", target_basic)
                eTarget.Add("target_params", target_params)
                eTarget.Add("target", target)
            Next

            Return arrTarget
        End Function


        Public Shared Sub create_folder(ByVal path As String, Optional ByVal cont As Integer = 1)
            Dim max_cont As Integer = 10
            cont += 1

            If (cont >= max_cont) Then Exit Sub

            If System.IO.Path.HasExtension(path) Then
                path = System.IO.Path.GetDirectoryName(path)
            End If

            If Not System.IO.Directory.Exists(path) Then
                Try
                    create_folder(System.IO.Path.GetDirectoryName(path), cont)
                    System.IO.Directory.CreateDirectory(path)
                Catch ex As Exception
                End Try
            End If
        End Sub


        ''' <summary>
        ''' Devuelve el path de una dirección relativa
        ''' </summary>
        ''' <param name="path">Path relativo Ej: "file://(default)/directorio_archivos". (default) define cual es el directorio raiz. Si no viene se define el default;
        ''' Exiete tambien el valor (temp) para identificar la carpeta de temporales del sistema </param>
        ''' <returns>Devuelve la dirección física del path</returns>
        ''' <remarks></remarks>
        Public Shared Function get_file_path(ByVal path As String) As String

            If path.IndexOf("FILE://[%local%]") > -1 Then
                Return path.Substring(("FILE://[%local%]").Length, path.Length - ("FILE://[%local%]").Length).Replace("/", "\")
            End If

            Dim nvApp As tnvApp = nvFW.nvApp.getInstance()
            Dim raiz As String = nvServer.appl_physical_path & "App_Data\localfile\"
            Dim cod_ss_dir As String = ""
            Dim strReg As String = "\(.*\)[\\||/]"
            Dim r As New System.Text.RegularExpressions.Regex(strReg)

            ' Identificar si existe el
            If r.IsMatch(path) And nvApp.app_dirs.Count > 0 Then
                Try
                    cod_ss_dir = r.Match(path).Value
                    path = path.Replace(cod_ss_dir, "")
                    cod_ss_dir = cod_ss_dir.Substring(1, cod_ss_dir.Length - 3)

                    If cod_ss_dir.ToLower() = "temp" Then
                        raiz = System.IO.Path.GetTempPath

                        If cod_ss_dir.ToLower() <> "default" AndAlso nvApp.app_dirs.Keys.Contains(cod_ss_dir) Then
                            raiz = nvApp.app_dirs(cod_ss_dir).path
                        End If
                    End If

                    For Each dir As String In nvApp.app_dirs.Keys

                        If dir.ToLower() = cod_ss_dir.ToLower() Then

                            Dim dirs_internos = nvApp.app_dirs(dir).path.Split(";")
                            For Each dir_interno As String In dirs_internos

                                Try
                                    If System.IO.File.Exists(dirs_internos(dir_interno)) Then
                                        raiz = dirs_internos(dir_interno)
                                        Return raiz & "\" & path.Replace("/", "\")
                                    End If
                                Catch ex As Exception

                                End Try

                                Return dir_interno & (path.Replace("FILE://", "").Replace("/", "\"))

                            Next

                            If dirs_internos.Length = 0 Then
                                If System.IO.File.Exists(nvApp.app_dirs(dir).path) Then
                                    Return raiz & "\" & nvApp.app_dirs(dir).path & "\" & path.Replace("/", "\")
                                End If
                            End If

                        End If
                    Next

                Catch ex As Exception
                End Try
            End If

            Dim path_destino As String = ""

            Try
                ' Quitar protocolo
                Dim pos As Integer = path.IndexOf("://")

                For Each dir As String In nvApp.app_dirs.Keys
                    If dir = "nvFiles" Then
                        raiz = nvApp.app_dirs(dir).path.Split(";")(0)
                    End If
                Next

                If pos <> -1 Then
                    pos += 3
                    path_destino = path.Substring(pos, path.Length - pos)
                Else
                    path_destino = path
                End If

                If nvApp.app_dirs.Keys.Contains(cod_ss_dir) Then
                    Dim dirs As String() = nvApp.app_dirs(cod_ss_dir).path.Split(New Char() {";"})
                    For Each dir As String In dirs
                        If System.IO.File.Exists(dir & Replace(path_destino, "/", "\")) = True Then
                            raiz = dir
                            Exit For
                        End If
                    Next
                End If

                path_destino = raiz & Replace(path_destino, "/", "\")
            Catch ex As Exception
            End Try

            Return path_destino
        End Function


        Public Shared Function target_get_file(ByVal strfile As String) As Dictionary(Of String, String)
            Dim path As String = get_file_path(strfile)
            Dim file As New Dictionary(Of String, String)
            file.Add("protocolo", "file")
            file.Add("path", path)
            file.Add("folder", System.IO.Path.GetDirectoryName(path))
            file.Add("filename", System.IO.Path.GetFileName(strfile))
            file.Add("extencion", System.IO.Path.GetExtension(strfile))

            Return file
        End Function


        Public Shared Function target_get_mailto(ByVal strmailto As String) As Dictionary(Of String, String)
            Dim ma(), mb(), mc(), md() As String
            ' Array resultado
            Dim mailto As New Dictionary(Of String, String)
            ' Descompone la cadena entre la direccion y los parametros
            ma = strmailto.Split("?")
            ' Descompone la cadena entre protocolo y dirección
            mb = ma(0).Split("://")
            mailto(mb(0)) = mb(1)
            mc = ma(1).Split("&")

            For i = LBound(mc) To UBound(mc)
                md = mc(i).Split("=")
                mailto.Add(md(0), md(1))
            Next

            If Not mailto.Keys.Contains("to") Then
                mailto.Add("to", mailto("mailto"))
            Else
                Dim t = mailto("to")
                mailto.Remove("to")
                mailto.Add("to", t & ";" & mailto("mailto"))
            End If

            mailto.Add("protocolo", "mailto")

            Return mailto

            '   mailto["mailto"]
            '   mailto["to"]
            '   mailto["cc"]
            '   mailto["bcc"]
            '   mailto["subject"]
            '   mailto["body"]
            '   mailto["attach"]
        End Function


        Public Shared Sub sql_mail_send(ByVal mto As String, ByVal cc As String, ByVal bcc As String, ByVal subject As String, ByVal body As String, ByVal attach As String)

            '      If (!cc) Then
            '  cc = ''
            '          If (!bcc) Then
            '  bcc = ''
            '              If (!subject) Then
            '  subject = ''  
            '                  If (!body) Then
            '  body = ''      
            '                      If (!attach) Then
            '  attach = ''        

            Dim strSQL As String = "EXECUTE dbo.rm_send_mail '" & mto & "', '" & cc & "', '" & bcc & "', '" & Replace(subject, "'", "''") & "', '" & Replace(body, "'", "''") & "', '" & attach & "'"
            nvDBUtiles.DBExecute(strSQL)
        End Sub

        Public Shared Function excelConvertirA(saveas As Integer, path As String) As tError

            Dim err As New tError
            Try

                Dim exAPP As New Excel.Application

                exAPP.Visible = False
                exAPP.DisplayAlerts = False

                Dim exLibro As Excel.Workbook = exAPP.Workbooks.Open(path)

                If (saveas = 57) Then ' si es PDF
                    exLibro.ExportAsFixedFormat(Excel.XlFixedFormatType.xlTypePDF, Filename:=path, Quality:=Excel.XlFixedFormatQuality.xlQualityStandard, IncludeDocProperties:=True, IgnorePrintAreas:=True, OpenAfterPublish:=False)
                Else
                    exLibro.SaveAs(path, saveas)
                End If


                exAPP.Quit()
                exAPP = Nothing

            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = 99
                err.mensaje = "Problemas al convertir a Excel"
            End Try

            Return err

        End Function

        Public Shared Function excelGetNombreHojaNueva(libro As Excel.Workbook, Optional nombre_hoja As String = "Hoja") As String

            Dim existe As Boolean = True
            Dim index As Integer = 1

            Dim temp_nombre_hoja As String = nombre_hoja

            Do

                For Each hoja_destino In libro.Sheets

                    If hoja_destino.Name = temp_nombre_hoja Then
                        existe = True
                        Exit For
                    Else
                        existe = False
                    End If

                Next

                index = index + 1

                temp_nombre_hoja = nombre_hoja & index.ToString

            Loop While existe = True

            Return temp_nombre_hoja

        End Function

        Public Shared Function excelABMLibro(path_temp As String, path_destino As String, Optional modo As String = "REEMPLAZAR", Optional nombre_hoja As String = "Hoja1") As tError

            Dim err As New tError
            Dim exAPP As New Excel.Application

            Try

                exAPP.Visible = False
                exAPP.DisplayAlerts = False

                Dim exLibro_dest = exAPP.Workbooks.Open(path_destino)
                Dim exLibro_tmp = exAPP.Workbooks.Open(path_temp)

                Dim hoja_destino As Excel.Worksheet = Nothing
                Dim hoja_found As String = ""

                For Each hoja_tmp As Excel.Worksheet In exLibro_tmp.Sheets

                    If (modo = "AGREGAR") Then
                        hoja_tmp.Name = excelGetNombreHojaNueva(exLibro_dest, nombre_hoja)
                    End If

                    If (modo = "REEMPLAZAR") Then

                        For Each hoja_destino In exLibro_dest.Sheets
                            If hoja_destino.Name = hoja_tmp.Name Then
                                hoja_found = True
                                Exit For
                            Else
                                hoja_found = False
                            End If
                        Next

                        If (hoja_found = True) Then

                            If exLibro_tmp.Sheets.Count = 1 Then
                                hoja_destino.Name = "$NEW_" & hoja_tmp.Name
                            Else
                                hoja_destino.Delete()
                            End If

                        Else
                            hoja_tmp.Name = nombre_hoja
                        End If

                    End If

                    hoja_tmp.Copy(Before:=exLibro_dest.Worksheets(exLibro_dest.Worksheets.Count))

                    If (Not hoja_destino Is Nothing) Then
                        If (hoja_destino.Name = "$NEW_" & hoja_tmp.Name) Then
                            hoja_destino.Delete()
                        End If
                    End If

                Next

                exLibro_dest.Save()

                exLibro_dest.Close()
                exLibro_tmp.Close()

                'For Each Workbook In exAPP.Workbooks
                '    Workbook.Close(True)
                'Next

                exAPP.Quit()
                Try
                    System.Runtime.InteropServices.Marshal.FinalReleaseComObject(exAPP)
                Catch ex As Exception
                End Try

                exAPP = Nothing

            Catch ex As Exception

                If Not exAPP Is Nothing Then

                    For c = 1 To exAPP.Workbooks.Count
                        exAPP.Workbooks(c).Close(False)
                    Next

                    exAPP.Quit()
                    System.Runtime.InteropServices.Marshal.FinalReleaseComObject(exAPP)

                End If

                err.parse_error_script(ex)
                err.numError = 99
                err.mensaje = "Problemas al convertir a Excel"
            End Try

            Return err

        End Function

        Public Shared Function zipDescomprimirArchivo(ByVal path_relativo As String, ByVal path_absoluto As String, ByVal file_name_zip As String, Optional ByVal pwd As String = "") As tError

            Dim err As New tError()
            err.titulo = "Descomprimir archivo"
            Try

                Dim archivoZip As String = Replace(path_relativo, Path.GetFileName(path_absoluto), file_name_zip)

                If System.IO.File.Exists(archivoZip) Then

                    Using zip As New Ionic.Zip.ZipFile(archivoZip)
                        Dim e As Ionic.Zip.ZipEntry
                        For Each e In zip
                            If e.FileName = System.IO.Path.GetFileName(path_absoluto) Then
                                If e.UsesEncryption Then
                                    e.ExtractWithPassword(System.IO.Path.GetDirectoryName(path_absoluto), Ionic.Zip.ExtractExistingFileAction.OverwriteSilently, pwd)
                                Else
                                    e.Extract(System.IO.Path.GetDirectoryName(path_absoluto), Ionic.Zip.ExtractExistingFileAction.OverwriteSilently)
                                End If
                            End If
                        Next
                    End Using

                    '  Dim archivoZip = System.IO.Path.GetDirectoryName(path_destino) & "\" & System.IO.Path.GetFileNameWithoutExtension(path_destino) & "." & destino("comp_metodo")
                    'Using zip As Ionic.Zip.ZipFile = Ionic.Zip.ZipFile.Read(archivoZip)
                    '  zip.ExtractSelectedEntries("name = " & System.IO.Path.GetFileName(path_absoluto), System.IO.Path.GetDirectoryName(path_absoluto), "unpack", Ionic.Zip.ExtractExistingFileAction.OverwriteSilently)
                    'End Using

                End If

            Catch ex As Exception
                err.parse_error_script(ex)
                err.mensaje = "Error al intentar descomprimir el archivo"
            End Try

            Return err

        End Function



        Public Shared Function zipComprimirArchivo(ByVal destino As Dictionary(Of String, String), Optional eliminar As Boolean = False, Optional filename As String = "") As tError

            Dim err As New tError()
            err.titulo = "Comprimir archivo"

            Try
                Dim path_destino As String = destino("path")

                Dim path_destino_comp As String = ""
                If filename <> "" Then
                    path_destino_comp = Replace(path_destino, Path.GetFileName(path_destino), filename)
                Else
                    path_destino_comp = Replace(path_destino, Path.GetExtension(path_destino), ".zip")
                End If

                If System.IO.File.Exists(path_destino_comp) And destino("target_agregar") <> "true" Then
                    System.IO.File.Delete(path_destino_comp)
                End If


                Dim enc As Ionic.Zip.EncryptionAlgorithm = Ionic.Zip.EncryptionAlgorithm.PkzipWeak
                If (destino("comp_algoritmo") <> "") Then
                    enc = destino("comp_algoritmo") 'EncryptionAlgorithm.WinZipAes256
                End If

                Using zip As New Ionic.Zip.ZipFile(path_destino_comp)

                    If Not String.IsNullOrEmpty(destino("comp_pwd")) Then
                        zip.Password = destino("comp_pwd")
                        ' zip.Encryption = Ionic.Zip.EncryptionAlgorithm.WinZipAes256
                    End If

                    zip.UpdateFile(path_destino, "") ' zip.AddFile(path_destino, "")

                    zip.Save(path_destino_comp)

                    If System.IO.File.Exists(path_destino) And eliminar = True Then
                        System.IO.File.Delete(path_destino)
                    End If

                    err.params.Add("path_destino", path_destino_comp)

                End Using

            Catch ex As Exception
                err.parse_error_script(ex)
                err.mensaje = "Error al intentar comprimir el archivo"
            End Try

            Return err
        End Function

        Public Shared Function RSXMLtoExcelRs(ByVal rs As ADODB.Recordset, ByVal export_exeption As String, Optional page_name As String = "Hoja1") As tError
            Dim lfilas As Integer = IIf(export_exeption = "RSXMLtoExcel", 1048575, 65535) '//Cantidad de filas por hoja / mirar version de excel
            Dim ext_modelo As String = IIf(export_exeption = "RSXMLtoExcel", ".xlsx", ".xls")
            Dim c
            Dim registros
            Dim oColumna
            Dim columna
            Dim n_hoja
            Dim fila As Integer = 0
            Dim NOD
            Dim registro
            Dim AbsoluteFila
            Dim path_temp As String
            Dim hoja_nueva As Boolean = True

            Dim exAPP As Excel.Application '  = new ActiveXObject("Excel.Application")
            Dim exLibro As Excel.Workbook
            Dim exHoja As Excel.Worksheet


            Dim rptError As New tError
            rptError.debug_src = "reportViewer::RSXMLtoExcelRs"

            Try
                rptError.numError = 8
                rptError.mensaje = "Error al instanciar la aplicación Excel" 'new ActiveXObject("Excel.Application")'
                exAPP = New Excel.Application '  = new ActiveXObject("Excel.Application")

                Dim path_modelo As String = nvServer.appl_physical_path + "\fw\reportViewer\modelo_excel" + ext_modelo

                rptError.numError = 9
                rptError.mensaje = "No se pudo abrir el archivo de modelo."
                rptError.debug_desc = path_modelo
                exLibro = exAPP.Workbooks.Open(path_modelo)

                exAPP.Visible = False
                exAPP.DisplayAlerts = False

                rptError.numError = 10
                rptError.mensaje = "El modelo debe tener al menos una hoja" 'exLibro.Worksheets(1)

                exHoja = exLibro.Worksheets(1)
                exHoja.Name = page_name


                n_hoja = 1
                AbsoluteFila = 0

                While Not rs.EOF
                    fila = IIf(AbsoluteFila Mod lfilas = 0, 1, fila + 1)
                    If fila = 1 Then
                        For c = 0 To rs.Fields.Count - 1
                            exHoja.Cells(1, c + 1) = rs.Fields.Item(c).Name
                            If rs.Fields.Item(c).Type = 7 Or rs.Fields.Item(c).Type = 133 Or rs.Fields.Item(c).Type = 134 Or rs.Fields.Item(c).Type = 135 Then
                                exAPP.Columns(c + 1).Select()
                                exAPP.Selection.NumberFormat = "dd/mm/yyyy;@"
                            End If
                        Next
                        fila += 1
                    End If

                    For c = 0 To rs.Fields.Count - 1
                        If Not IsDBNull(rs.Fields.Item(c).Value) Then   '//revisar
                            Try
                                Select Case rs.Fields.Item(c).Type

                                    Case 7 Or 133 Or 134 Or 135 '://"dateTime":
                                        Try
                                            exHoja.Cells(fila, c + 1) = rs.Fields.Item(c).Value
                                        Catch ex As Exception
                                            'Stop
                                            'exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((New Date("" + rs.fields.item(c).value)))
                                        End Try

                                        '                  case 133://"dateTime":
                                        '                try {exHoja.Cells(fila, c + 1) = rs.fields.item(c).value} catch (e){exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((new Date("" + rs.fields.item(c).value)))}
                                        '                                            break()
                                        '              case 134://"dateTime":
                                        '                try {exHoja.Cells(fila, c + 1) = rs.fields.item(c).value} catch (e){exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((new Date("" + rs.fields.item(c).value)))}
                                        '                                                break()
                                        '              case 135://"dateTime":
                                        '                try {exHoja.Cells(fila, c + 1) = rs.fields.item(c).value} catch (e){exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((new Date("" + rs.fields.item(c).value)))}
                                        '                                                    break()
                                    Case 200 Or 201 Or 202 ': // "string":
                                        exHoja.Cells(fila, c + 1) = "'" + rs.Fields.Item(c).Value
                                        '              Case 201 ': // "string":
                                        '                                                    exHoja.Cells(fila, c + 1) = "'" + rs.fields.item(c).value
                                        '                                                    break()
                                        '              case 202: // "string":
                                        '                                                    exHoja.Cells(fila, c + 1) = "'" + rs.fields.item(c).value
                                        '                                                    break()
                                    Case Else
                                        exHoja.Cells(fila, c + 1) = rs.Fields.Item(c).Value
                                End Select
                            Catch ex As Exception
                                exHoja.Cells(fila, c + 1) = "ERROR"
                            End Try
                        Else
                            exHoja.Cells(fila, c + 1) = "NULL"
                        End If
                    Next

                    '      //aumento en uno para el proximo registro
                    AbsoluteFila += 1
                    If (AbsoluteFila Mod lfilas) = 0 And AbsoluteFila < rs.RecordCount Then
                        n_hoja += 1
                        fila = 1
                        exHoja = exLibro.Worksheets.Add(Nothing, exHoja)
                    End If
                    rs.MoveNext()
                End While


                For c = 1 To exLibro.Worksheets.Count
                    exHoja = exLibro.Worksheets(c)
                    exHoja.Select()
                    exAPP.Rows("1:1").Select()
                    exAPP.Selection.Font.Bold = True
                    exAPP.Selection.HorizontalAlignment = -4108 '//xlCenter
                    exAPP.Selection.VerticalAlignment = -4107 '//xlBottom
                    exAPP.Selection.WrapText = False
                    exAPP.Selection.Orientation = 0
                    exAPP.Selection.AddIndent = False
                    exAPP.Selection.IndentLevel = 0
                    exAPP.Selection.ShrinkToFit = False
                    exAPP.Selection.ReadingOrder = -5002 '//xlContext
                    exAPP.Selection.MergeCells = False
                    exAPP.Rows.Select()
                    exAPP.Selection.RowHeight = 12.75
                    exHoja.Cells.Select()
                    exAPP.Cells.EntireColumn.AutoFit()
                Next

                'exAPP.Worksheets(1).Select()


                rptError.numError = "11"
                rptError.mensaje = "Errror al crear el archivo temporal" 'Server.CreateObject("Scripting.FileSystemObject")
                path_temp = System.IO.Path.GetTempFileName

                rptError.numError = 12
                rptError.mensaje = "Error al intentar guardar el archivo temporal." 'exLibro.SaveAs(path_tmp)
                exLibro.SaveAs(path_temp)

                For c = 1 To exAPP.Workbooks.Count
                    exAPP.Workbooks(c).Close(True)
                Next

                exAPP.Quit()
                System.Runtime.InteropServices.Marshal.FinalReleaseComObject(exAPP)

                rptError = New tError
                rptError.params.Add("path_temp", path_temp)
                Return rptError  '//Devuelve el path del archivo

            Catch ex As Exception

                If Not exAPP Is Nothing Then
                    For c = 1 To exAPP.Workbooks.Count
                        exAPP.Workbooks(c).Close(False)
                    Next
                    exAPP.Quit()
                    System.Runtime.InteropServices.Marshal.FinalReleaseComObject(exAPP)

                    '//Eliminar el archivo si fue creado
                    Try
                        If System.IO.File.Exists(path_temp) Then System.IO.File.Delete(path_temp)
                    Catch ex1 As Exception
                    End Try

                    Return rptError

                End If

            End Try




        End Function


    End Class


    Public Class tnvExportarParam
        Public VistaGuardada As String = ""   ' nombre de la vista guardada en WRP_config
        Public filtroXML As String = ""       ' Comando SQL en codificación XML
        Public filtroWhere As String = ""     ' Where anexo a los comandos anteriores
        Public filtroParams As String = ""    ' Tiene los valores de los parametros de la consulta XML
        Public xml_data As String = ""        ' XML que se va a tomar como origen de datos para el plantillado

        ' Parametros de transformación
        ' Si xsl_name tiene valor se busca el archivo dentro de la carpeta de la vista.
        ' Si no se busca la el archivo en la dirección indicada en path_xsl anexandole la carpeta de servidor
        Public xsl_name As String = ""
        Public path_xsl As String = ""
        Public xml_xsl As String = ""
        Public report_name As String = ""
        Public path_reporte As String = ""

        ' Parametros de destino
        ''' <summary>
        ''' ContentType que se enviará en la cabecera de la respuesta
        ''' </summary>
        ''' <remarks></remarks>
        Public ContentType As String = ""                                       ' Identifica ese valor en el flujo de salida
        Public target As String = ""
        Public salida_tipo As nvenumSalidaTipo = nvenumSalidaTipo.no_definido   ' Identifica si en la llamada será devuelto el resultado o un informe de resultado
        Public mantener_origen As Boolean = False                               ' Indica que se llevará registro de la llamada para reutilizarlo
        Public id_exp_origen As Integer = 0                                     ' Identificar el nro con el que se guardó el origen en la tabla exp_origen
        Public parametros As String = ""
        Public export_exeption As String = ""                                   ' Defina una exportacion por exepcion, sin plantilla xsl, sino por otro proceso
        Public filename As String = ""
        Public page_name As String = ""
        Public content_disposition As String = ""

        Public Sub New(Optional ByVal VistaGuardada As String = "" _
            , Optional ByVal filtroXML As String = "" _
            , Optional ByVal filtroWhere As String = "" _
            , Optional ByVal filtroParams As String = "" _
            , Optional ByVal xsl_name As String = "" _
            , Optional ByVal path_xsl As String = "" _
            , Optional ByVal xml_xsl As String = "" _
            , Optional ByVal xml_data As String = "" _
            , Optional ByVal report_name As String = "" _
            , Optional ByVal path_reporte As String = "" _
            , Optional ByVal ContentType As String = "" _
            , Optional ByVal target As String = "" _
            , Optional ByVal salida_tipo As nvenumSalidaTipo = nvenumSalidaTipo.no_definido _
            , Optional ByVal mantener_origen As Boolean = False _
            , Optional ByVal id_exp_origen As Integer = 0 _
            , Optional ByVal parametros As String = "" _
            , Optional ByVal export_exeption As String = "" _
            , Optional ByVal filename As String = "" _
            , Optional ByVal content_disposition As String = "")

            Me.VistaGuardada = VistaGuardada
            Me.filtroXML = filtroXML
            Me.filtroWhere = filtroWhere
            Me.filtroParams = filtroParams
            Me.xsl_name = xsl_name
            Me.xml_xsl = xml_xsl
            Me.xml_data = xml_data
            Me.path_xsl = path_xsl
            Me.report_name = report_name
            Me.path_reporte = path_reporte
            Me.ContentType = ContentType
            Me.target = target
            Me.salida_tipo = salida_tipo
            Me.mantener_origen = mantener_origen
            Me.id_exp_origen = id_exp_origen
            Me.parametros = parametros
            Me.export_exeption = export_exeption
            Me.filename = filename
            Me.content_disposition = content_disposition
        End Sub


        Public Function toXML() As String
            Dim strXML As String = "<criterio><export_params> "

            If filtroXML <> "" Then strXML += "<filtroXML><![CDATA[" & filtroXML & "]]></filtroXML>"
            If filtroWhere <> "" Then strXML += "<filtroWhere><![CDATA[" & filtroWhere & "]]></filtroWhere>"
            If VistaGuardada <> "" Then strXML += "<VistaGuardada><![CDATA[" & VistaGuardada & "]]></VistaGuardada>"
            If filtroParams <> "" Then strXML += "<filtroParams><![CDATA[" & filtroParams & "]]></filtroParams>"
            If xsl_name <> "" Then strXML += "<xsl_name><![CDATA[" & xsl_name & "]]></xsl_name>"
            If path_xsl <> "" Then strXML += "<path_xsl><![CDATA[" & path_xsl & "]]></path_xsl>"
            If xml_xsl <> "" Then strXML += "<xml_xsl><![CDATA[" & xml_xsl & "]]></xml_xsl>"
            If xml_data <> "" Then strXML += "<xml_data><![CDATA[" & xml_data & "]]></xml_data>"
            If report_name <> "" Then strXML += "<report_name><![CDATA[" & report_name & "]]></report_name>"
            If path_reporte <> "" Then strXML += "<path_reporte><![CDATA[" & path_reporte & "]]></path_reporte>"
            If ContentType <> "" Then strXML += "<ContentType><![CDATA[" & ContentType & "]]></ContentType>"
            If target <> "" Then strXML += "<target><![CDATA[" & target & "]]></target>"
            If salida_tipo <> nvenumSalidaTipo.no_definido Then strXML += "<salida_tipo><![CDATA[" & salida_tipo.ToString & "]]></salida_tipo>"
            If mantener_origen Then strXML += "<mantener_origen><![CDATA[true]]></mantener_origen>"
            If id_exp_origen <> 0 Then strXML += "<id_exp_origen><![CDATA[" & id_exp_origen & "]]></id_exp_origen>"
            If parametros <> "" Then strXML += "<parametros><![CDATA[" & parametros & "]]></parametros>"
            If export_exeption <> "" Then strXML += "<export_exeption><![CDATA[" & export_exeption & "]]></export_exeption>"
            If filename <> "" Then strXML += "<filename><![CDATA[" & filename & "]]></filename>"
            If content_disposition <> "" Then strXML += "<content_disposition><![CDATA[" & content_disposition & "]]></content_disposition>"

            strXML += "</export_params></criterio>"

            Return strXML
        End Function


        Public Function encXML() As String
            Dim strXML As String = toXML()
            Dim res As String = nvXMLSQL.encXMLSQL(strXML)
            Return res
        End Function


        Public Shared Function getEncXML(Optional ByVal VistaGuardada As String = "" _
            , Optional ByVal filtroXML As String = "" _
            , Optional ByVal filtroWhere As String = "" _
            , Optional ByVal filtroParams As String = "" _
            , Optional ByVal xsl_name As String = "" _
            , Optional ByVal path_xsl As String = "" _
            , Optional ByVal xml_xsl As String = "" _
            , Optional ByVal xml_data As String = "" _
            , Optional ByVal report_name As String = "" _
            , Optional ByVal path_reporte As String = "" _
            , Optional ByVal ContentType As String = "" _
            , Optional ByVal target As String = "" _
            , Optional ByVal salida_tipo As nvenumSalidaTipo = nvenumSalidaTipo.no_definido _
            , Optional ByVal mantener_origen As Boolean = False _
            , Optional ByVal id_exp_origen As Integer = 0 _
            , Optional ByVal parametros As String = "" _
            , Optional ByVal export_exeption As String = "" _
            , Optional ByVal filename As String = "" _
            , Optional ByVal content_disposition As String = "") As String

            Dim expParam As New tnvExportarParam(VistaGuardada, filtroXML, filtroWhere, filtroParams, xsl_name, path_xsl, xml_xsl, xml_data, report_name, path_reporte, ContentType, target, salida_tipo, mantener_origen, id_exp_origen, parametros, export_exeption, filename, content_disposition)

            Return expParam.encXML()
        End Function
    End Class



End Namespace
