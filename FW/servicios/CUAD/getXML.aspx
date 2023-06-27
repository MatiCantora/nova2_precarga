<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%
    Dim accion As String = nvUtiles.obtenerValor({"accion","a"}, "")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")
    Stop
    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim st As New ADODB.Stream
    Dim Err As New tError

    Dim logTrack As String = nvLog.getNewLogTrack()
    Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

    Select Case accion.ToLower
        Case "uif_html"
            Try
                Dim apenom As String = ""

                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)

                apenom = XML.SelectSingleNode("criterio/apenom").InnerText

                Dim uif As New nvFW.nvUIF
                Err = uif.consultarUIF(apenom)

                If (Err.numError = 0 And Err.mensaje.IndexOf("No se encontraron registros con el criterio") > 0 And Err.mensaje.IndexOf(apenom) = -1 Or (Err.mensaje = "Total : 0")) Then
                    Err.numError = 2
                    Err.titulo = "Consulta UIF"
                    Err.mensaje = "Error en la importación de la consulta. Intente nuevamente."
                End If

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error en la importación de la consulta"
                Err.mensaje = "Salida por excepcion"
                Err.debug_src = "getxml::uif_html"
            End Try

            strXML = Err.get_error_xml()

        Case "uif_html_guardar"
            Try
                Dim apenom As String = ""
                Dim nro_credito As String = ""
                Err.params("respuesta") = ""

                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)

                nro_credito = XML.SelectSingleNode("criterio/nro_credito").InnerText

                Dim strSQL As String = "Select ltrim(rtrim(apellido)) + ' ' + replace(ltrim(rtrim(nombres)),'  ',' ') as apenom from vercreditos where nro_credito ='" & nro_credito & "'"
                Dim rsRes As ADODB.Recordset = DBOpenRecordset(strSQL)
                If Not rsRes.EOF Then
                    apenom = rsRes.Fields("apenom").Value
                    apenom = apenom.Replace("/([\ \t]+(?=[\ \t])|^\s+|\s+$)/ g", "") ' mas de dos espacios lo reemplaza con un espacio
                End If
                DBCloseRecordset(rsRes)

                Dim uif As New nvFW.nvUIF
                Err = uif.consultarUIF(apenom)

                If (Err.numError = 0 And Err.mensaje.IndexOf("No se encontraron registros con el criterio") > 0 And Err.mensaje.IndexOf(apenom) = -1 Or (Err.mensaje = "Total : 0")) Then
                    Err.numError = 2
                    Err.titulo = "Consulta UIF"
                    Err.mensaje = "Error en la importación de la consulta. Intente Nuevamente"
                Else

                    Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset("select ISNULL(MAX(nro_archivo),0) + 1 as maxArchivo from archivos")
                    Dim nro_archivo = rsA.Fields("maxArchivo").Value
                    nvFW.nvDBUtiles.DBCloseRecordset(rsA)

                    ' Dim operador = nvApp.getInstance().operador
                    Dim nro_operador = 0 '= operador.operador

                    Dim strSQLarchivos = "Insert Into archivos (nro_archivo, path, operador,nro_img_origen,nro_archivo_estado) values(" + nro_archivo + ", '" + nro_archivo + "','" + nro_operador + "',1,1))"
                    nvFW.nvDBUtiles.DBExecute(strSQLarchivos)

                    Dim Archivo As New Dictionary(Of String, String)()
                    Archivo.Add("nro_archivo", nro_archivo)
                    Archivo.Add("ext", "html")
                    Dim filename = nro_archivo.ToString() & "." & Archivo.Item("ext")
                    Archivo.Add("filename", filename)
                    'Dim path = Request.ServerVariables(4).Item + "documentos\\" + Archivo.Values("filename")
                    Dim path = nvServer.appl_physical_path & "/lavado/documentos/" & Archivo.Item("filename")
                    Archivo.Add("path", path)

                    'StringToFile(resHTML, Archivo.Item("path"), "ISO-8859-1")

                    If (Err.numError = 0 And Err.titulo = "OK") Then
                        Dim strSQLarchivos_param = "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'RES_UIF' , '" & Err.mensaje & "', getdate(),dbo.rm_nro_operador())"
                        nvFW.nvDBUtiles.DBExecute(strSQLarchivos_param)
                    End If

                    'Recuperar info archivo_def
                    strSQL = "select dbo.conv_fecha_to_str(GETDATE(),'dd/mm/yyyy') as fe_documento,* from archivos_param_def where archivo_descripcion like 'Consulta Lista Terrorista'"
                    Dim rsDef = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
                    Archivo.Add("defar", rsDef.Fields("nro_def_archivo").Value)
                    Archivo.Add("desc", rsDef.Fields("archivo_descripcion").Value)
                    Archivo.Add("nro_def_archivo", rsDef.Fields("nro_def_archivo").Value)
                    Archivo.Add("fe_documento", rsDef.Fields("fe_documento").Value)
                    '    Archivo.Add("nro_cliente", nro_cliente.ToString())
                    nvFW.nvDBUtiles.DBCloseRecordset(rsDef)

                    'Actualizar la tabla archivos con los datos del archivo
                    strSQL = "UPDATE archivos SET nro_cliente=" & Archivo.Item("nro_cliente") & ", fe_documento=convert(datetime,'" & Archivo.Item("fe_documento") & "',103), nro_def_archivo=" & Archivo.Item("nro_def_archivo") & ", path = '" & Archivo.Item("filename") & "' where nro_archivo = " & Archivo.Item("nro_archivo")

                    nvFW.nvDBUtiles.DBExecute(strSQL)

                    'ABM registro
                    strSQL = "INSERT INTO [com_registro]([nro_entidad],[id_tipo],[nro_com_id_tipo],[nro_com_tipo],[comentario],[nro_com_estado]) "
                    strSQL &= " VALUES(" & Archivo.Item("nro_cliente") & "," & Archivo.Item("nro_archivo") & ",1,4,'Se adjunto al documento <b>" & Archivo.Item("desc") & "</b>. Archivo referencia: " & Archivo.Item("filename") + "',5)\n"

                    nvFW.nvDBUtiles.DBExecute(strSQL)

                End If


            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error al actualizar las fuentes externas"
                Err.mensaje = "Salida por excepcion"
            End Try

            strXML = Err.get_error_xml()

    End Select

    nvXMLUtiles.responseXML(Response, strXML)
    Stopwatch.Stop()
    Dim ts As TimeSpan = Stopwatch.Elapsed
    nvLog.addEvent("nosis_getXML", logTrack & ";;" & ts.TotalMilliseconds & ";" & accion & ";" & criterio)
    'nvLog.addEvent("rd_getXML", logTrack & ";;" & ts.TotalMilliseconds & ";" & accion & ";" & criterio)
    Response.End()

    'Response.Expires = -1
    'Response.ContentType = "text/xml"
    'Response.Charset = "ISO-8859-1" '"UTF-8"
    'strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>" + strXML
    'Dim buffer() As Byte = Encoding.GetEncoding("iso-8859-1").GetBytes(strXML)
    ''Response.Write(strXML)
    'Response.BinaryWrite(buffer)
    'Response.Flush()

%>