Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW.nvTransferencia
    Public Class nvTransfUtiles

        Public Shared transfRunThread As New Dictionary(Of Integer, Threading.Thread)

        Public Shared Function getTransfStatusRunThread(id_transf_log As Integer) As Boolean

            Dim isAlive As Boolean = False
            Try

                If transfRunThread.Keys.Contains(id_transf_log) Then
                    isAlive = transfRunThread(id_transf_log).IsAlive
                End If

            Catch ex As Exception

            End Try

            Return isAlive

        End Function

        Public Shared Function getListTransfStatusRunThread() As tError

            Dim err As New tError
            Dim nvApp As tnvApp = nvFW.nvApp.getInstance
            Try
                For Each t In transfRunThread.Keys
                    If transfRunThread(t).IsAlive Then
                        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM verTransf_procesos_tareas WHERE id_transf_log = " & t.ToString & " and estado_det ='ejecutando' and  login_det = '" & nvApp.operador.login.ToString & "'")
                        If (rs.EOF = False) Then
                            err.params("id_transf_log_" & t.ToString) = t.ToString
                        End If
                        nvDBUtiles.DBCloseRecordset(rs)
                    End If
                Next
                err.params("momento") = DateTime.Now.ToString("dd'/'MM'/'yyyy HH':'mm':'ss")
            Catch ex As Exception
            End Try

            Return err

        End Function


        Public Shared Function getFileTmpPath(filename As String, Optional serial As String = "") As String

            Dim nvApp As tnvApp = nvFW.nvApp.getInstance
            Dim dirBase As String = nvServer.appl_physical_path & "App_Data\upload\tranf_tmp\"
            Dim dirSession As String = dirBase & "session_" & nvApp.operador.login & "_" & serial.ToString 'nvSession.IDSession
            Dim path As String = dirSession & "\" & filename

            If Not System.IO.Directory.Exists(dirSession) Then nvReportUtiles.create_folder(dirSession)

            Return path

        End Function

        Public Shared Function getFileErrorPath(filename As String, Optional serial As String = "") As String

            Dim nvApp As tnvApp = nvFW.nvApp.getInstance
            Dim dirBase As String = nvServer.appl_physical_path & "App_Data\upload\tranf_error\"
            Dim dirSession As String = dirBase & "session_" & nvApp.operador.login & "_" & serial.ToString 'Session.SessionID
            Dim path As String = dirSession & "\" & filename

            If Not System.IO.Directory.Exists(dirSession) Then nvReportUtiles.create_folder(dirSession)

            Return path
        End Function

        Public Shared Function getNvTransfDetsClasses() As Dictionary(Of String, String)
            Dim nspace As String = "nvFW.nvTransferencia.nvTranfDets"
            Dim asm As System.Reflection.Assembly = System.Reflection.Assembly.GetExecutingAssembly()
            Dim classlist As New List(Of String)
            Dim tipo As Type
            Dim obj As Object
            Dim res As New Dictionary(Of String, String)
            For Each tipo In asm.GetTypes()
                If tipo.Namespace = nspace Then
                    Try
                        obj = Activator.CreateInstance(tipo)
                        For Each dettipo In obj.det_tipos
                            res.Add(dettipo, tipo.FullName)
                        Next
                    Catch ex As Exception

                    End Try
                End If
            Next
            Return res
        End Function


        Public Shared Function getNvTransfDetInstance(det_tipo As String, clases As Dictionary(Of String, String)) As Object
            If clases.Keys.Contains(det_tipo) Then
                Try
                    Dim tipo As Type = Type.GetType(clases(det_tipo))
                    Dim obj As Object = Activator.CreateInstance(tipo)
                    Return obj
                Catch ex As Exception
                    Return Nothing
                End Try
            Else
                Return Nothing
            End If
        End Function

        Public Shared Function evalString(detalle As tTransfDet, cadena As String) As String

            Dim eval_res As String = ""
            Dim strEval As String = ""

            'strEval = System.IO.File.ReadAllText(nvServer.appl_physical_path & "\fw\script\nvUtiles.js")

            Dim strReg As String = "{([A-Z||a-z||1-9||_]*)}"
            Dim reg As New System.Text.RegularExpressions.Regex(strReg)

            Dim proc As New List(Of String)
            Dim ms As System.Text.RegularExpressions.MatchCollection = reg.Matches(cadena)
            For Each m As System.Text.RegularExpressions.Match In ms
                Dim param As String = m.Groups(1).Value
                If Not proc.Contains(param) Then
                    'cadena = cadena.Replace(m.Value, detalle.Transf.param(param)("valor").ToString(New System.Globalization.CultureInfo("en-US")))
                    cadena = cadena.Replace(m.Value, String.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"), "{0}", detalle.Transf.param(param)("valor")))
                    proc.Add(param)
                End If

            Next

            strEval = "function return_valor(){" & detalle.Transf.paramSCRIPT() & "; return " & cadena & " } " & vbCrLf & " return_valor()"
            Try
                eval_res = nvConvertUtiles.JSScriptToObject(strEval)
            Catch ex As Exception

            End Try

            Return eval_res
        End Function

        Public Shared Function GetStrSQLLogInsertParams(det As tTransfDet) As String
            Dim strSQLDet As String = "" & vbCrLf
            Dim param As String
            For Each param In det.Transf.param.Keys
                'If Me.Transf.param(param)("valor") Is Nothing Then Continue For
                strSQLDet += "INSERT INTO transf_log_param(id_transf_log_det, id_transferencia, parametro, valor)"
                strSQLDet += "VALUES(" & det.id_transf_log_det & ", " & det.Transf.id_transferencia & ", '" & param & "', " & IIf(det.Transf.param(param)("valor") Is Nothing, "NULL", nvConvertUtiles.objectToSQLScript(det.Transf.param(param)("valor"))) & ")" & vbCrLf
            Next
            Return strSQLDet
        End Function

        'Public Shared Function GetStrSQLLogInsertParams(det As tTransfDet) As String
        '    Dim strSQLDet As String = "" & vbCrLf
        '    Dim param As String
        '    For Each param In det.Transf.param.Keys
        '        'If Me.Transf.param(param)("valor") Is Nothing Then Continue For
        '        strSQLDet += "INSERT INTO transf_log_param(id_transf_log_det, id_transferencia, parametro, valor)"
        '        strSQLDet += " VALUES(" & det.id_transf_log_det & ", " & det.Transf.id_transferencia & ", '" & param & "', "

        '        If det.Transf.param(param)("tipo_dato") = "datetime" Then
        '            strSQLDet += IIf(det.Transf.param(param)("valor") Is Nothing, "NULL", "'" & det.Transf.param(param)("valor") & "'") & ")" & vbCrLf
        '        Else
        '            strSQLDet += IIf(det.Transf.param(param)("valor") Is Nothing, "NULL", nvConvertUtiles.objectToSQLScript(det.Transf.param(param)("valor"))) & ")" & vbCrLf
        '        End If

        '    Next
        '    Return strSQLDet
        'End Function


        Public Shared Function getCodeSEG(XML As System.Xml.XmlDocument, parametro As String, valor As String, params As Dictionary(Of String, trsParam)) As String

            Dim code As String = ""

            Dim xmlValor As String = nvXMLUtiles.getNodeText(XML, "nodo [@parametro='" & parametro & "' and @tipo='carpeta']/valor", "")
            Dim nhijos As String = nvXMLUtiles.getNodeText(XML, "nodo [@parametro='" & parametro & "' and @tipo='carpeta']/nodos", "")
            Dim esValor As Boolean = IIf(nvXMLUtiles.getNodeText(XML, "nodo [@parametro='" & parametro & "' and @tipo='hoja' and valor='" & valor & "']", "") = valor, True, False)

            Dim filtroXML As String = ""
            If esValor = True And nhijos > 0 Then
                filtroXML = " and valor = '" + valor + "'"
            End If

            If nhijos > 0 Then
                Dim hijos As System.Xml.XmlNodeList = XML.SelectNodes("nodo [@parametro='" & parametro & "' and @tipo='carpeta' " & filtroXML & "]/nodos")
                For Each h As System.Xml.XmlElement In hijos
                    Dim h_parametro As String = nvUtiles.isNUll(h.GetAttribute("parametro"), "")
                    Dim h_valor As String = nvXMLUtiles.getNodeText(h, "valor", "")
                    If h_parametro <> "" And h_valor <> "" Then
                        If params.ContainsKey(h_parametro) = True Then
                            If h.SelectNodes("nodos/nodo").Count > 0 Then
                                getCodeSEG(XML, nvXMLUtiles.getNodeText(h.SelectSingleNode("nodos/nodo"), "nodos/nodo/@parametro", ""), nvXMLUtiles.getNodeText(h.SelectSingleNode("nodos/nodo"), "nodos/nodo/valor", ""), params)
                            Else
                                If h.GetAttribute("tipo").ToLower = "hoja" Then
                                    Return nvXMLUtiles.getNodeText(h, "code", "")
                                End If
                            End If
                        End If
                    End If
                Next
            End If

            If esValor = True And nhijos = 0 Then
                code = nvXMLUtiles.getNodeText(XML, "nodo [@parametro='" & parametro & "' and @tipo='hoja' and valor='" & valor & "']/code", "")
            End If

            Return code

        End Function

        Public Shared Function BCP_shell(server As String, uid As String, pwd As String, tabla As String, path_plantilla As String, path_log As String, path_destino As String) As tError

            Dim err As New tError
            err.params("id_run") = 0
            Try

                Dim strCmd As String
                Dim strParam As String = ""
                Dim variable As String
                Dim valor As String

                'bcp tempdb..tmp_laincli out C:laincli.txt -c -Ubcp -Pbcpbcp -SACONQUIJA3 -o C:tmp_laincli.out -f C:LAINCLI.fmt 

                strCmd = "bcp " & tabla & " out """ & path_destino & """ -U " & uid & " -P " & pwd & " -S " & server & " -o """ & path_log & """ -f """ & path_plantilla & """ -Q"

                'Objeto shell  
                Dim objShell = CreateObject("wscript.shell")
                objShell.CurrentDirectory = "C:\"
                'Exec comand
                Dim sexec = objShell.Exec(strCmd)
                Dim strRes As String = ""

                '  //Recuperar info de aoutput
                While Not sexec.stdout.AtEndOfStream
                    strRes += sexec.stdout.Read(2000)
                End While

                objShell = Nothing
                sexec = Nothing

                Dim line = ""
                Dim pos

                Dim reg As System.Text.RegularExpressions.Regex = New System.Text.RegularExpressions.Regex("'", RegexOptions.IgnoreCase)
                Dim lineas = strRes.Split(vbCrLf)

                Dim strSQL As String = ""
                strSQL += "declare @id_run int = 0" & vbCrLf
                strSQL += "Insert into ERROR_BCP_CAB(momento) values (getdate())" & vbCrLf
                strSQL += "set @id_run = @@IDENTITY" & vbCrLf
                strSQL += "Insert into ERROR_BCP(id_run,cmd,momento,[output]) values (@id_run,'" & strCmd & "',getdate(),'Utilidad BCP wscript.shell')" & vbCrLf
                strSQL += "Insert into ERROR_BCP(id_run,cmd,momento,[output]) values (@id_run,'" & strCmd & "',getdate(),'Iniciado: " & Now().ToString("HH:mm:ss.fff") & "')" & vbCrLf

                For Each linea In lineas
                    If Trim(linea) <> "" Then
                        strSQL += "Insert into ERROR_BCP(id_run,cmd,momento,[output]) values (@id_run,'" & strCmd & "',getdate(),'" & "Error: " & Now().ToString("HH:mm:ss.fff") & "')" & vbCrLf
                        strSQL += "Insert into ERROR_BCP(id_run,cmd,momento,[output]) values (@id_run,'" & strCmd & "',getdate(),'" & reg.Replace(linea, "''") & "')" & vbCrLf
                        strSQL += "Insert into ERROR_BCP(id_run,cmd,momento,[output]) values (@id_run,'" & strCmd & "',getdate(),'Fin de error')" & vbCrLf
                    End If
                Next

                strSQL += "Insert into ERROR_BCP(id_run,cmd,momento,[output]) values (@id_run,'" & strCmd & "',getdate(),'Finalizado: " & Now().ToString("HH:mm:ss.fff") & "')" & vbCrLf
                strSQL += "Select * from ERROR_BCP_CAB where id_run = @id_run"

                Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)
                If rs.EOF = False Then
                    err.params("id_run") = rs.Fields("id_run").Value
                End If
                nvDBUtiles.DBCloseRecordset(rs)

            Catch ex As Exception
                err.numError = -99
                err.titulo = "Error al intentar ejecutar el BCP"
                err.mensaje = ex.Message.ToString
            End Try

            Return err
        End Function


        Public Shared Function getScriptBase_SP_ejecutar(paramTSQL As String, cn_tipo As String) As String

            Dim strSQL As String = ""

            Select Case cn_tipo.ToLower
                Case "oracle"
                    strSQL = getScriptPLSQL_SP_ejecutar()
                Case "sybase"
                    paramTSQL = paramTSQL.Replace("varchar(max)", "varchar(8000)")
                    strSQL = <![CDATA[
--{paramTSQL}
  --{code}
--{paramTSQL_ret}
    ]]>.Value()

                Case Else

                    strSQL = <![CDATA[
--{paramTSQL}
BEGIN TRAN --{tran_name}
BEGIN TRY
  --{code}
  COMMIT TRAN --{tran_name}
END TRY
BEGIN CATCH
  ROLLBACK TRAN --{tran_name}
  Declare @ErrorMessage NVARCHAR(4000)
  Declare @ErrorSeverity INT
  Declare @ErrorState INT
  Select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
  RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
--{paramTSQL_ret}
    ]]>.Value()

            End Select

            strSQL = strSQL.Replace("--{paramTSQL}", paramTSQL)

            Return strSQL
        End Function

        Public Shared Function getScriptPLSQL_SP_ejecutar() As String
            Dim strSQL As String = <![CDATA[
--{paramTSQL}
  --{code}
open c1 for --{paramTSQL_ret}

]]>.Value() & vbCrLf & "END;"
            '--DBMS_SQL.RETURN_RESULT(c1);
            Return strSQL
        End Function

    End Class

    Public Class tCola_det
        Public det As tTransfDet
        Public ant As tTransfDet
        Public continuar As Boolean = True 'Define si la ejecución de salida continua o no
        Public eval_res As Boolean = True 'Guarda el resultado de la evaluacion
        Public sigs As New List(Of tCola_det)
    End Class


End Namespace