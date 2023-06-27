<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", "0")
    Dim rpt_defs As string = nvFW.nvUtiles.obtenerValor("rpt_defs", "0")
    Dim salida_tipo As String = nvFW.nvUtiles.obtenerValor({"salida", "salida_tipo"}, "HTML")
    Dim mail As String = nvFW.nvUtiles.obtenerValor("mail", "")
    Dim content_disposition As String = nvFW.nvUtiles.obtenerValor("content_disposition", "")
    Dim _temp_path As String=""

    'Dim login As String = nvApp.operador.login
    'Dim ip_usr As String = Request.ServerVariables("REMOTE_ADDR")
    'Dim ip_srv As String = Request.ServerVariables("LOCAL_ADDR")

    'Dim operador As Object
    'Try
    '    operador = nvFW.nvApp.getInstance().operador
    'Catch ex As Exception
    'End Try

    'Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    'Me.contents("permisos_precarga") = op.permisos("permisos_precarga")

    Dim bytes_cumulo() As Byte = Nothing

    Dim err As New nvFW.tError
    Select Case salida_tipo.ToLower()
        Case "mail"
            err.salida_tipo = "estado"
        Case "htmlreturn"
            err.salida_tipo = "estado"
        Case Else
            err.salida_tipo = salida_tipo
    End Select

    Try
        'exec dbo.rm_rpt_buscar 5177756,1,2
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_rpt_buscar", ADODB.CommandTypeEnum.adCmdStoredProc)
        Dim param1 As ADODB.Parameter = cmd.CreateParameter("@nro_credito", 3, 1, 0, nro_credito)
        cmd.Parameters.Append(param1)
        Dim param2 As ADODB.Parameter = cmd.CreateParameter("@rpt_todos", 3, 1, 0, 1)
        cmd.Parameters.Append(param2)
        Dim param3 As ADODB.Parameter = cmd.CreateParameter("@nro_print_tipo", 3, 1, 0, 2)
        cmd.Parameters.Append(param3)
        Dim res As ADODB.Recordset = cmd.Execute()

        Dim nro_rpt_def As Integer
        Dim docbytes() As Byte

        Dim expParam As New nvFW.tnvExportarParam
        While res.EOF = False

            nro_rpt_def = res.Fields.Item("nro_rpt_def").Value

            If (rpt_defs.IndexOf(nro_rpt_def.ToString) >= 0) Then

                With expParam
                    .filtroXML = nvXMLSQL.encXMLSQL(nvFW.nvConvertUtiles.JSScriptToObject(Replace(nvUtiles.isNUllorEmpty(res.Fields("filtroXML").Value, "''"), "' + nro_credito + '", nro_credito.ToString)))
                    .filtroWhere = nvFW.nvConvertUtiles.JSScriptToObject(Replace(nvUtiles.isNUllorEmpty(res.Fields("filtroWhere").Value, "''"), "' + nro_credito + '", nro_credito.ToString))
                    .path_reporte = nvFW.nvConvertUtiles.JSScriptToObject(Replace(nvUtiles.isNUllorEmpty(res.Fields("rpt_path").Value, "''"), "' + nro_credito + '", nro_credito.ToString))
                    .report_name = nvFW.nvConvertUtiles.JSScriptToObject(Replace(nvUtiles.isNUllorEmpty(res.Fields("rpt_name").Value, "''"), "' + nro_credito + '", nro_credito.ToString))
                    .salida_tipo = nvFW.nvenumSalidaTipo.returnWithBinary
                End With
                
                err = nvFW.reportViewer.mostrarReporte(expParam)
                If (err.numError <> 0) Then
                    err.response()
                End If

                docbytes = Convert.FromBase64String(err.params("reportBinary"))

                If bytes_cumulo Is Nothing Then
                    bytes_cumulo = docbytes
                Else
                    bytes_cumulo = nvFW.nvPDFUtil.PdfConcat(bytes_cumulo, docbytes)
                End If

                'Dim fs1 As New System.IO.FileStream("c:\cumulo de pdf" & nro_rpt_def.ToString & ".pdf", System.IO.FileMode.Create)
                'fs1.Write(bytes_cumulo, 0, bytes_cumulo.Length)
                'fs1.Close()

            End If

            res.MoveNext()
        End While

        docbytes = Nothing
        err.clear()

        Dim _filename As String = ""
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from vercreditos where nro_credito = " & nro_credito.ToString)
        _filename = "Prestamo " & nro_credito.ToString & " de " & rs.Fields("nombres").Value.ToString & " " & rs.Fields("apellido").Value.ToString & ".pdf"
        'DBCloseRecordset(rs)


        If (salida_tipo.ToLower() = "mail") Then

            Dim path_destino As String = ""
            Dim body As String = ""
            Dim subject As String = ""
            'Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from vercreditos where nro_credito = " & nro_credito.ToString)
            If rs.EOF = False Then

                body += "Estimado:" & "<br>" & "<br>"
                body += "Se adjunta documentación para completar en referencia a la operación " & nro_credito.ToString & ".<br><br>"
                body += "<b>Información del Solicitante:</b>" & "<br>"
                body += "Nombre: " & rs.Fields("nombres").Value.ToString & ".<br>"
                body += "Apellido: " & rs.Fields("apellido").Value.ToString & ".<br>"
                body += rs.Fields("documento").Value & ": " & rs.Fields("nro_docu").Value.ToString & ".<br>"
                body += "CUIL: " & rs.Fields("cuit").Value.ToString & ".<br>"
                body += "Fecha Nacimiento: " & Format(rs.Fields("fe_naci").Value, "dd/MM/yyyy") & ".<br>" & "<br>"

                body += "<b>Información del Préstamo:</b>" & "<br>"
                body += "Préstamo Nº: <b>" & nro_credito.ToString & "</b>.<br>"
                body += "Fecha del Préstamo: " & Format(rs.Fields("fe_credito").Value, "dd/MM/yyyy") & ".<br>"
                body += "Plan: " & rs.Fields("plan_banco").Value.ToString & ".<br>"
                body += "Importe Solicitado: $" & rs.Fields("importe_bruto").Value.ToString & ".<br>"
                body += "Importe Neto: $" & rs.Fields("importe_neto").Value.ToString & ".<br>"
                body += "Importe cuota: $" & rs.Fields("importe_cuota").Value.ToString & ".<br>"
                body += "Cuotas: " & rs.Fields("cuotas").Value.ToString & ".<br>"

                subject = "Solicitud de Préstamo Nº " & nro_credito.ToString & " a nombre de " & rs.Fields("nombres").Value.ToString & " " & rs.Fields("apellido").Value.ToString

                path_destino = System.IO.Path.GetTempPath & _filename
            End If
            'DBCloseRecordset(rs)

            If (System.IO.File.Exists(path_destino)) Then
                System.IO.File.Delete(path_destino)
            End If

            Dim fs As New System.IO.FileStream(path_destino, System.IO.FileMode.Create)
            fs.Write(bytes_cumulo, 0, bytes_cumulo.Length)
            fs.Close()

            Dim from_title As String = Replace(nvFW.nvApp.getInstance().operador.nombre_operador, ",", "")

            'rs = nvDBUtiles.DBOpenRecordset("select nombres + ' ' + apellido as razon_social from verPersonas where nro_entidad = " & nvFW.nvApp.getInstance().operador.nombre_operador.ToString)
            'If rs.EOF = False Then
            '    from_title = rs.Fields("razon_social").Value.ToString
            'End If
            'DBCloseRecordset(rs)

            Dim _from As String = "sqlmail@redmutual.com.ar"
            err = nvFW.nvNotify.sendMail(_from:=_from, _to:=mail _
                                      , _from_title:=from_title _
                                      , _subject:=subject _
                                      , _body:=body _
                                      , _attachByPath:=path_destino)

            If (err.numError <> 0) Then
                err.response()
            End If

            If (System.IO.File.Exists(path_destino)) Then
                System.IO.File.Delete(path_destino)
            End If

            'Dim fs As New System.IO.FileStream("c:\pruebaNet.pdf", System.IO.FileMode.Create)
            'fs.Write(docbytes, 0, docbytes.Length)
            'fs.Close()

            'err.mostrar_error()
        End If

        DBCloseRecordset(rs)

        If (salida_tipo.ToLower() = "adjunto") Then

            Response.AddHeader("Content-Disposition", "inline;filename=" & _filename)
            Response.BinaryWrite(bytes_cumulo)
            Response.ContentType = "application/pdf"

            ' Response.End()
        End If

        If salida_tipo.ToLower() = "html" Then
            ''Dim _temp_path As String = System.IO.Path.GetTempPath & "\" & _filename
            _temp_path= System.IO.Path.GetTempPath & "\" & _filename
            System.IO.File.WriteAllBytes(_temp_path, bytes_cumulo)
            bytes_cumulo = Nothing
            err.params("filename") = _filename
            err.params("temp_path") = _temp_path
            
            err.params("url") = "/FW/files/file_get.aspx?temp_path=" & _filename & "&content_disposition=" & content_disposition

            ' err.mostrar_error()
        End If

        If salida_tipo.ToLower() = "htmlreturn" Then
            err.params("filename") = _filename
            err.params.Add("reportBinaryBase64", Convert.ToBase64String(bytes_cumulo))
            'err.mostrar_error()
        End If

        bytes_cumulo = Nothing

    Catch ex As Exception
        err.parse_error_script(ex)
        err.titulo = "Error al procesar el destino"
        err.debug_src = "tCerProxy::tCerProxy"
        err.params("temp_path") = _temp_path
    End Try
    err.salida_tipo = "estado"
    err.mostrar_error()

 %>
