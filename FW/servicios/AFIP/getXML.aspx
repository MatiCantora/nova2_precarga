<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%
    Stop
    Dim accion As String = nvUtiles.obtenerValor({"accion", "a"}, "afip_constancia_inscripcion")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "<criterio><nro_docu>20002195624</nro_docu><id_tipo>280</id_tipo></criterio>")

    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim Err As New tError

    Dim logTrack As String = nvLog.getNewLogTrack()
    Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

    Select Case accion.ToLower

        Case "afip_constancia_inscripcion"
            Try
                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)

                Dim nro_docu As String = nvFW.nvXMLUtiles.getNodeText(XML, "criterio/nro_docu", "")
                Dim id_tipo As String = nvFW.nvXMLUtiles.getNodeText(XML, "criterio/id_tipo", "")

                Err = nvFW.servicios.AFIP.Query.getServicio(nro_docu)

                Dim binaryData() As Byte
                If Err.params.ContainsKey("xml") = True Then

                    XML = Err.params("xml")
                    binaryData = nvFW.servicios.AFIP.Utiles.ConstanciaPDF(XML.SelectSingleNode("//personaReturn").OuterXml)

                    Dim nro_archivo_id_tipo As Integer = 1 'el que le corresponde a la solicitud 
                    Dim archivo_descripcion As String = "" ' descripcion de la deficion de documento 
                    Dim nro_def_archivo As Integer = 0
                    Dim nro_def_detalle As Integer = 0

                    Dim strSQL As String = " select lc.nro_def_archivo,dd.nro_def_detalle from archivo_leg_cab lc " &
                    "join archivos_def_detalle dd on lc.nro_def_archivo = dd.nro_def_archivo " &
                     "where nro_archivo_id_tipo = " & nro_archivo_id_tipo & " and id_tipo = " & id_tipo & " and dd.archivo_descripcion like '" & archivo_descripcion & "' "
                    Dim rsRes As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                    If Not rsRes.EOF Then
                        nro_def_archivo = rsRes.Fields("nro_def_archivo").Value
                        nro_def_detalle = rsRes.Fields("nro_def_detalle").Value
                        archivo_descripcion = "Constancia de Inscripción"
                    Else
                        Err.numError = 99
                        Err.titulo = "Constancia de Inscripción"
                        Err.mensaje = "Error"
                    End If
                    nvDBUtiles.DBCloseRecordset(rsRes)

                    If Err.numError = 0 Then
                        Dim archivo As New nvFW.tnvArchivo(BinaryData:=binaryData, descripcion:=archivo_descripcion, id_tipo:=id_tipo, nro_archivo_id_tipo:=nro_archivo_id_tipo, nro_def_archivo:=nro_def_archivo, nro_def_detalle:=nro_def_detalle, file_ext:=".pdf")
                        Err = archivo.save()
                    End If

                    If Err.params.ContainsKey("xml") = False Then
                        Err.params.Add("xml", XML)
                    End If

                End If

                'ABM registro
                ' strSQL = "INSERT INTO [com_registro]([nro_entidad],[id_tipo],[nro_com_id_tipo],[nro_com_tipo],[comentario],[nro_com_estado]) "
                '  strSQL &= " VALUES(" & Archivo.Item("nro_cliente") & "," & Archivo.Item("nro_archivo") & ",1,4,'Se adjunto al documento <b>" & Archivo.Item("desc") & "</b>. Archivo referencia: " & Archivo.Item("filename") + "',5)\n"
                '  nvFW.nvDBUtiles.DBExecute(strSQL)

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error en la importación de la consulta"
                Err.mensaje = "Salida por excepcion"
                Err.debug_src = "getxml::AFIP"
            End Try

            strXML = Err.get_error_xml()

    End Select

    nvXMLUtiles.responseXML(Response, strXML)
    Stopwatch.Stop()
    Dim ts As TimeSpan = Stopwatch.Elapsed
    nvLog.addEvent("nosis_getXML", logTrack & ";;" & ts.TotalMilliseconds & ";" & accion & ";" & criterio)
    Response.End()


%>