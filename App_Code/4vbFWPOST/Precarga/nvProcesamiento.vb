Imports Microsoft.VisualBasic
Imports System.IO
Imports System.Net
Imports System.Text
Imports System.Web
''clase para la manipulacion de archivos en general (copiado de srv a srv, manipulacion, conversion, etc)

Namespace nvFW.servicios

    Public Class nvProcesamiento
        ''obtiene los comprobantes que hay en el server de uploadfiles.improntasolutions.com para agregarlos a los legajos 
        Public Function SwapComprobantesVoii(NCredentials As Net.NetworkCredential) As tError

            Dim op As nvFW.nvSecurity.tnvOperador = nvFW.nvApp.getInstance().operador
            Dim nro_operador As Integer = op.operador
            Dim nro_archivo As String = ""
            Dim Err = New tError()
            Try
                Dim pathtemp As String = nvReportUtiles.get_file_path("(nvarchivos)/")
                Dim source As String = "\\172.16.1.99"
                Dim pathremote As String = "\\\\uploadfiles.improntasolutions.com\\VOII\\Comprobantes"
                Err.mensaje = "busqueda en " & source
                Dim strSQL = ""
                Dim path_archivo As String = ""
                Dim file_remote As String = ""
                Dim bytes_cumulo As Byte() = Nothing
                'Dim NCredentials As Net.NetworkCredential = New Net.NetworkCredential("impronta_user", "Imp123+")
                '' Dim NCredentials As Net.NetworkCredential = New Net.NetworkCredential(usuariodominio, pwdusuario)
                Using New nvFW.servicios.nvNetworkConnection(source, NCredentials)
                    Dim sourceFiles As String() = System.IO.Directory.GetFiles(pathremote, "*.pdf", System.IO.SearchOption.TopDirectoryOnly)
                    Dim pathfolderConf As String = ""
                    Dim rs As ADODB.Recordset
                    For Each file_remote In sourceFiles
                        Try
                            Dim nombre As String = System.IO.Path.GetFileName(file_remote)
                            Dim regftpformatstring As String = "^(\d{7})_(\d{22})_(\d{6})(.pdf)" ''machea 7digitos para credito, 22 para cbu, 6 para comprobantes y la extension
                            Dim mftpformastring As Match = Regex.Match(nombre, regftpformatstring, RegexOptions.IgnoreCase)
                            If (mftpformastring.Success And mftpformastring.Groups.Count > 3) Then

                                Dim nro_credito As String = CStr(CInt(mftpformastring.Groups(1).Value))
                                Dim cbu As String = mftpformastring.Groups(2).Value
                                Dim nro_comprobante As String = CStr(CInt(mftpformastring.Groups(3).Value))
                                rs = nvFW.nvDBUtiles.DBOpenRecordset("Select * from lausana_anexa..comprobantes_seguros_voii where nro_credito=" & nro_credito)
                                '' si no existe el comprobante, lo agrego
                                If (rs.EOF) Then
                                    nvFW.nvDBUtiles.DBExecute("insert into lausana_anexa..comprobantes_seguros_voii(path_remote,procesado,fe_ingreso,nro_credito,cbu,nro_comprobante) values('" & file_remote & "',0,getdate()," & nro_credito & ",'" & cbu & "'," & nro_comprobante & ") ")
                                End If

                            End If
                        Catch ex As Exception
                            Err.numError = -2
                            Err.titulo = "Error  " & pathfolderConf
                            Err.mensaje = ex.Message & " - " & ex.StackTrace
                        End Try

                    Next
                    rs = nvFW.nvDBUtiles.DBOpenRecordset("Select t.path_remote,t.nro_credito from lausana_anexa..comprobantes_seguros_voii  t  where t.procesado<>1 and isnull(t.path_remote,'')<>''")

                    While Not rs.EOF
                        Dim nro_credito As String = rs.Fields("nro_credito").Value
                        Dim path_remote As String = rs.Fields("path_remote").Value
                        Dim nro_def_archivo As Integer
                        Dim orden As Integer
                        Dim nro_def_detalle As Integer
                        Dim repetido As Integer
                        Dim descripcion As String
                        ''constancia de pago del credito
                        Dim rs1 = nvFW.nvDBUtiles.DBOpenRecordset("Select * from verarchivos_def where nro_credito=" & nro_credito & " And nro_archivo_def_tipo=22 order by nro_archivo_def_tipo desc")
                        If Not (rs1.EOF) Then
                            nro_def_archivo = CInt(rs1.Fields("nro_def_archivo").Value)
                            orden = CInt(rs1.Fields("orden").Value)
                            nro_def_detalle = CInt(rs1.Fields("nro_def_detalle").Value)
                            repetido = CBool(rs1.Fields("repetido").Value)
                            descripcion = rs1.Fields("archivo_descripcion").Value

                            Dim carpeta As String = System.DateTime.Now.ToString("yyyyMM")
                            strSQL = "SET NOCOUNT ON" & vbCrLf
                            strSQL &= "declare @nro_archivo int " & vbCrLf
                            strSQL &= "select @nro_archivo=isnull(max(nro_archivo), 0) + 1  from archivos WITH (NOLOCK) " & vbCrLf
                            strSQL &= "Insert Into archivos (nro_archivo, path, operador,nro_img_origen,cant_hojas,nro_credito,nro_def_detalle,Descripcion,nro_archivo_estado) values(@nro_archivo, ''," & CStr(nro_operador) & ",1,1," & CStr(nro_credito) & "," & CStr(nro_def_detalle) & ",'" & descripcion & "',2)" & vbCrLf
                            strSQL &= "SET NOCOUNT OFF" & vbCrLf
                            strSQL &= "select @nro_archivo as maxArchivo"
                            Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
                            nro_archivo = CStr(rsA.Fields("maxArchivo").Value)
                            nvFW.nvDBUtiles.DBCloseRecordset(rsA)

                            Dim directoryfault As String = pathtemp & carpeta
                            Dim file As String = nro_archivo & ".pdf"
                            Dim path_file_fault = directoryfault & "\\" & file
                            If (Not System.IO.Directory.Exists(directoryfault)) Then
                                System.IO.Directory.CreateDirectory(directoryfault)
                            End If
                            bytes_cumulo = System.IO.File.ReadAllBytes(path_remote.Replace("\", "\\"))
                            Dim fs1 As New System.IO.FileStream(path_file_fault, System.IO.FileMode.Create)
                            fs1.Write(bytes_cumulo, 0, bytes_cumulo.Length)
                            fs1.Close()
                            bytes_cumulo = Nothing
                            strSQL = "SET NOCOUNT ON" & vbCrLf
                            If (repetido = False) Then
                                strSQL &= "update archivos set nro_archivo_estado = 2 where  nro_def_detalle =" & CStr(nro_def_detalle) & " and nro_credito =  " & CStr(nro_credito) & " and nro_archivo <> " & nro_archivo & vbCrLf
                            End If
                            strSQL &= "update archivos set path = '" & carpeta & "\" & file & "',nro_archivo_estado = 1 where nro_archivo = " & nro_archivo
                            nvFW.nvDBUtiles.DBExecute(strSQL)
                            nvFW.nvDBUtiles.DBExecute("update lausana_anexa..comprobantes_seguros_voii set procesado=1 where nro_credito=" & nro_credito)
                        End If
                        rs.MoveNext()
                    End While
                End Using
            Catch ex As Exception
                Err.parse_error_script(ex)
            End Try
            Return Err
        End Function


        Public Function addfilelegajo2(BinaryData() As Byte, id_tipo As String, nro_archivo_id_tipo As String _
                , Optional nro_def_archivo As String = "0" _
                , Optional nro_def_detalle As String = "0" _
                , Optional ext As String = ".pdf") As tError

            Dim errLegajo As New tError()
            Try

                If BinaryData.Length > 0 Then
                    If errLegajo.numError = 0 Then
                        Dim archivo As New nvFW.tnvArchivo(BinaryData:=BinaryData, id_tipo:=id_tipo, nro_archivo_id_tipo:=nro_archivo_id_tipo, nro_def_archivo:=nro_def_archivo, nro_def_detalle:=nro_def_detalle, file_ext:=ext)
                        errLegajo = archivo.save()

                        If errLegajo.numError = 0 AndAlso nro_archivo_id_tipo = "2" Then
                            nvDBUtiles.DBExecute("update archivos set nro_credito = " & id_tipo & " where nro_archivo = " & errLegajo.params("nro_archivo"))
                        End If
                    End If
                Else
                    errLegajo.numError = 1
                    errLegajo.mensaje = "La imagen no existe."
                End If

            Catch ex As Exception
                errLegajo.parse_error_script(ex)
                errLegajo.numError = 100
                errLegajo.titulo = "Error"
                errLegajo.mensaje = "Error al adjuntar archivo (" & nro_def_detalle & ")"
                errLegajo.debug_src = "nvProcesamiento::addfilelegajo2"
            End Try

            Return errLegajo
        End Function

        ''agrega un binario al legajo del credito pasado por parametro en funcion del archivo def tipo ingresado (se puede seleccionar otra extesion , que por defecto es pdf
        Public Function addfilelegajo(ByVal binary As Byte(), ByVal nro_credito As String, ByVal nro_archivo_def_tipo As String, Optional ByVal extension As String = "pdf", Optional cod_sistema As String = Nothing) As tError
            Dim op As nvFW.nvSecurity.tnvOperador = nvFW.nvApp.getInstance().operador
            Dim nro_operador As Integer = op.operador
            Dim ins = nvFW.nvApp.getInstance()
            Dim server As String = ins.cod_servidor
            Dim pathR As String = ""
            'Dim cod_sistema As String = ins.cod_sistema
            If (cod_sistema Is Nothing) Then
                cod_sistema = ins.cod_sistema
            End If

            Dim nro_archivo As String = ""
            Dim Err = New tError()
            Dim path_rova As String = ""
            Dim rsDef = nvFW.nvDBUtiles.DBOpenRecordset("select nro_def_detalle,archivo_descripcion,repetido from verArchivos_def where nro_credito = " & nro_credito & " and  nro_archivo_def_tipo=" & nro_archivo_def_tipo)
            If (rsDef.EOF = True) Then
                Err.numError = 1000
                Err.mensaje = "no existe el detalle para el tipo de archivo"
                Return Err
            End If
            'Guardado en Rova
            Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = '" & cod_sistema & "' and cod_servidor = '" & server & "' and cod_ss_dir = 'nvArchivosDefault'")
            If (rsRova.EOF = True) Then
                Err.numError = 1001
                Err.mensaje = "no se encontro el servidor para almacenar los archivos"
                Err.params("cod_sistema") = cod_sistema
                Err.params("server") = server
                Return Err
            End If
            Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
            path_rova = rsRova.Fields("path").Value.Replace("\", "\\") & carpeta
            Try
                Dim nro_def_detalle As String = rsDef.Fields("nro_def_detalle").Value
                Dim archivo_descripcion As String = rsDef.Fields("archivo_descripcion").Value
                Dim repetido As Boolean = rsDef.Fields("repetido").Value
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("get_nro_archivo", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                cmd.addParameter("@nro_def_detalle", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_def_detalle)
                cmd.addParameter("@descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, archivo_descripcion.Length, archivo_descripcion)
                Dim rs As ADODB.Recordset = cmd.Execute()
                nro_archivo = rs.Fields("nro_archivo").Value
                Dim filename As String = nro_archivo & "." & extension
                If System.IO.Directory.Exists(path_rova) = False Then
                    System.IO.Directory.CreateDirectory(path_rova)
                End If
                pathR = path_rova & "\\" & filename
                Dim fs3 As New System.IO.FileStream(pathR, IO.FileMode.Create)
                fs3.Write(binary, 0, binary.Length)
                fs3.Close()
                Dim strSQL As String = ""
                If (repetido = False) Then
                    strSQL &= "update archivos set nro_archivo_estado = 2 where  nro_def_detalle =" & nro_def_detalle & " and nro_credito =  " & nro_credito & " and nro_archivo <> " & nro_archivo & vbCrLf
                End If
                'nvFW.nvDBUtiles.DBExecute("update archivos set nro_archivo_estado = 2 where nro_def_detalle = " & nro_def_detalle & " and nro_credito = " & nro_credito & " and nro_archivo <> " & nro_archivo)
                'nvFW.nvDBUtiles.DBExecute("update archivos set nro_archivo_estado = 1,  path = '" & carpeta & "\" & filename & "', nro_credito = " & nro_credito & ", descripcion = '" & archivo_descripcion & "',nro_def_detalle=" & nro_def_detalle & " where nro_archivo = " & nro_archivo)
                strSQL &= "update archivos set nro_archivo_estado = 1,  path = '" & carpeta & "\" & filename & "', nro_credito = " & nro_credito & ", descripcion = '" & archivo_descripcion & "',nro_def_detalle=" & nro_def_detalle & " where nro_archivo = " & nro_archivo
                nvFW.nvDBUtiles.DBExecute(strSQL)
                binary = Nothing
                Err.params("nro_archivo") = nro_archivo
                Err.params("filename") = pathR
            Catch ex As Exception
                Err.parse_error_script(ex)
            End Try
            Return Err
        End Function

        ''' <summary>
        ''' crear un archivo en nova y dado ese nro de archivo, lo replica en otros items
        ''' </summary>
        ''' <param name="binary"><c>binary</c> archivo binario a replicar</param>
        ''' ''' <param name="nro_docu"><c>nro_docu</c> nro_docu de la persona</param>
        ''' ''' <param name="tipo_docu"><c>tipo_docu</c>tipo de documento</param>
        ''' ''' <param name="sexo"><c>sexo</c> sexo</param>
        ''' ''' <param name="nro_archivo_def_tipo"><c>nro_archivo_def_tipo</c> def tipo a copia el archivo</param>
        Public Function addlegajpersona(ByVal binary As Byte(), ByVal nro_docu As String, ByVal tipo_docu As Integer, ByVal sexo As String, ByVal nro_archivo_def_tipo As String, Optional ByVal extension As String = "pdf", Optional cod_sistema As String = Nothing, Optional ByVal creditos As String = "") As tError
            Dim op As nvFW.nvSecurity.tnvOperador = nvFW.nvApp.getInstance().operador
            Dim nro_operador As Integer = op.operador
            Dim ins = nvFW.nvApp.getInstance()
            Dim server As String = ins.cod_servidor
            'Dim cod_sistema As String = ins.cod_sistema
            If (cod_sistema Is Nothing) Then
                cod_sistema = ins.cod_sistema
            End If

            Dim nro_archivo As String = ""
            Dim Err = New tError()
            Dim path_rova As String = ""


            'Guardado en Rova
            ''Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path,d.archivo_def_tipo from helpdesk.dbo.nv_servidor_sistema_dir,archivos_def_tipo d where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = '" & cod_sistema & "' and cod_servidor = '" & server & "' and cod_ss_dir = 'nvArchivosDefault' and d.nro_archivo_def_tipo=" & nro_archivo_def_tipo)
            Dim rs1 = nvFW.nvDBUtiles.DBOpenRecordset("select d.archivo_def_tipo from archivos_def_tipo d where d.nro_archivo_def_tipo=" & nro_archivo_def_tipo)
            If (rs1.EOF = True) Then
                Err.numError = 1001
                Err.mensaje = "no se encontro el servidor para almacenar los archivos"
                Err.params("cod_sistema") = cod_sistema
                Err.params("server") = server
                Return Err
            End If
            Dim archivo_descripcion As String = rs1.Fields("archivo_def_tipo").Value
            Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
            Dim pathtemp As String = nvReportUtiles.get_file_path("(nvarchivos)/")
            path_rova = pathtemp.Replace("\", "\\") & carpeta


            Dim rsPersona = nvFW.nvDBUtiles.DBOpenRecordset("select * from verpersonas where nro_docu=" & nro_docu & " and tipo_docu=" & tipo_docu & " and sexo='" & sexo & "'")
            If (rsPersona.EOF = True) Then
                Err.numError = 1002
                Err.mensaje = "no se encontro persona "
                Err.params("nro_docu") = nro_docu

                Return Err
            End If
            Dim nro_entidad As String = rsPersona.Fields("nro_entidad").Value
            Try

                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("get_nro_archivo_entidad", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@nro_entidad", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_entidad)
                cmd.addParameter("@descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, archivo_descripcion.Length, archivo_descripcion)
                Dim rs As ADODB.Recordset = cmd.Execute()
                nro_archivo = rs.Fields("nro_archivo").Value
                Dim filename As String = nro_archivo & "." & extension
                If System.IO.Directory.Exists(path_rova) = False Then
                    System.IO.Directory.CreateDirectory(path_rova)
                End If
                Dim pathR As String = path_rova & "\\" & filename
                Dim fs3 As New System.IO.FileStream(pathR, IO.FileMode.Create)
                fs3.Write(binary, 0, binary.Length)
                fs3.Close()
                Dim strSQL As String = ""
                Dim path_file As String = carpeta & "\" & filename

                strSQL &= "update archivos set nro_archivo_estado = 1,  path = '" & path_file & "' where nro_archivo = " & nro_archivo
                nvFW.nvDBUtiles.DBExecute(strSQL)
                binary = Nothing
                ''recorro todos los creditos de la persoan
                Dim nro_credito As String = ""
                If (creditos <> "") Then
                    Dim stmt As String = "select distinct d.nro_credito,d.nro_def_detalle,d.archivo_descripcion,d.repetido  from verArchivos_def d left outer join archivos a on d.nro_def_detalle=a.nro_def_detalle and a.nro_credito=d.nro_credito and a.nro_archivo_estado=1 where d.nro_credito in(" & creditos & ")  and d.nro_archivo_def_tipo=" & nro_archivo_def_tipo
                    Dim rsDef = nvFW.nvDBUtiles.DBOpenRecordset(stmt)
                    While Not rsDef.EOF
                        nro_credito = rsDef.Fields("nro_credito").Value
                        Dim nro_def_detalle As String = rsDef.Fields("nro_def_detalle").Value
                        archivo_descripcion = rsDef.Fields("archivo_descripcion").Value
                        Dim repetido As Boolean = rsDef.Fields("repetido").Value
                        Dim cmd2 As New nvFW.nvDBUtiles.tnvDBCommand("get_nro_archivo", ADODB.CommandTypeEnum.adCmdStoredProc)
                        cmd2.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                        cmd2.addParameter("@nro_def_detalle", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_def_detalle)
                        cmd2.addParameter("@descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, archivo_descripcion.Length, archivo_descripcion)
                        Dim rs2 As ADODB.Recordset = cmd2.Execute()
                        nro_archivo = rs2.Fields("nro_archivo").Value
                        strSQL = ""
                        If (repetido = False) Then
                            strSQL &= "update archivos set nro_archivo_estado = 2 where  nro_def_detalle =" & nro_def_detalle & " and nro_credito =  " & nro_credito & " and nro_archivo <> " & nro_archivo & vbCrLf
                        End If
                        strSQL &= "update archivos set nro_archivo_estado = 1,  path = '" & path_file & "', nro_credito = " & nro_credito & ", descripcion = '" & archivo_descripcion & "',nro_def_detalle=" & nro_def_detalle & " where nro_archivo = " & nro_archivo
                        nvFW.nvDBUtiles.DBExecute(strSQL)
                        rsDef.MoveNext()
                    End While
                End If


            Catch ex As Exception
                Err.parse_error_script(ex)
            End Try
            Return Err
        End Function

        ''' <summary>
        ''' obtiene el binario de una archivo formateado (convertido) para ser manipulado por pdf
        ''' </summary>
        ''' <param name="nro_credito"><c>nro_credito</c> credito a tomar</param>
        ''' <param name="nro_archivo_def_tipo"><c>nro_archivo_def_tipo</c> def tipo que se toma el archivo</param>
        Public Function getbinarypdf(ByVal nro_credito As Integer, ByVal nro_archivo_def_tipo As Integer, Optional ByVal cod_sistema As String = "nv_mutual") As tError
            Dim doc_bytes() As Byte = Nothing
            Dim op As nvFW.nvSecurity.tnvOperador = nvFW.nvApp.getInstance().operador
            Dim nro_operador As Integer = op.operador
            Dim ins = nvFW.nvApp.getInstance()
            Dim server As String = ins.cod_servidor
            'Dim cod_sistema As String = ins.cod_sistema
            If (cod_sistema Is Nothing) Then
                cod_sistema = ins.cod_sistema
            End If

            Dim nro_archivo As String = ""
            Dim Err = New tError()
            Dim path_rova As String = ""
            Dim path_archivo As String = ""
            Try
                'Guardado en Rova
                ''Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path,d.archivo_def_tipo from helpdesk.dbo.nv_servidor_sistema_dir,archivos_def_tipo d where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = '" & cod_sistema & "' and cod_servidor = '" & server & "' and cod_ss_dir = 'nvArchivosDefault' and d.nro_archivo_def_tipo=" & nro_archivo_def_tipo)
                Dim rs1 = nvFW.nvDBUtiles.DBOpenRecordset("select nro_credito, nro_archivo, [Path], Descripcion  from verArchivos where nro_credito=" & CStr(nro_credito) & " and nro_archivo_def_tipo = " & CStr(nro_archivo_def_tipo) & " and nro_archivo_estado = 1")
                If (rs1.EOF = True) Then
                    Err.numError = 1
                    Err.mensaje = "no se existe el archivo en el legajo"
                    Err.params("cod_sistema") = cod_sistema
                    Err.params("server") = server
                    Return Err
                End If
                Dim Descripcion As String = rs1.Fields("Descripcion").Value
                nro_archivo = rs1.Fields("nro_archivo").Value
                Err.params("nro_archivo") = nro_archivo
                Dim path_file As String = rs1.Fields("Path").Value
                rs1.Close()
                path_rova = ""

                Dim rsrova As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = '" & cod_sistema & "' and cod_servidor = '" & server & "' and [path]<>'' ")
                ''busco en todas las carpetas posibles
                While Not rsrova.EOF
                    path_rova = rsrova.Fields("path").Value
                    If (System.IO.File.Exists(path_rova & path_file)) Then
                        path_archivo = path_rova & path_file
                        Exit While
                    End If
                    rsrova.MoveNext()
                End While
                rsrova.Close()
                If (path_archivo = "") Then
                    Err.numError = 2
                    Err.mensaje = "no se encontro el archivo nro. " & nro_archivo & " en los servidores"
                    Err.params("cod_sistema") = cod_sistema
                    Err.params("server") = server
                    Return Err
                End If

                If (path_archivo <> "") Then
                    Dim ext = System.IO.Path.GetExtension(path_archivo).ToLower()
                    Select Case ext
                        Case ".html", ".htm"
                            Dim cuerpoMail As String = ""
                            Dim sr As New System.IO.StreamReader(path_archivo)
                            cuerpoMail = sr.ReadToEnd()
                            sr.Close()
                            doc_bytes = nvFW.nvPDF.HtmlStringToPdf(cuerpoMail)
                        Case ".jpg", ".bmp", ".jpeg"
                            doc_bytes = nvFW.nvPDFUtil.ImageToPDF(path_archivo)
                        Case ".pdf"
                            doc_bytes = System.IO.File.ReadAllBytes(path_archivo.Replace("\", "\\"))
                        Case ".wav", ".mp3"
                            ''doc_bytes = System.IO.File.ReadAllBytes(path_archivo.Replace("\", "\\"))
                        Case Else
                    End Select
                End If
                If (doc_bytes Is Nothing) Then
                    Err.numError = 3
                    Err.mensaje = "no se pudo convertir el archivo nro. " & nro_archivo & " del legajo"
                Else
                    Err.params("binary") = doc_bytes
                End If

            Catch ex As Exception
                Err.parse_error_script(ex)
            End Try
            Return Err
        End Function

        ''' <summary>
        ''' obtiene el binario de una archivo sin formato 
        ''' </summary>
        ''' <param name="nro_credito"><c>nro_credito</c> credito a tomar</param>
        ''' <param name="nro_archivo_def_tipo"><c>nro_archivo_def_tipo</c> def tipo que se toma el archivo</param>
        Public Function getbinary(ByVal nro_credito As Integer, ByVal nro_archivo_def_tipo As Integer, Optional ByVal cod_sistema As String = "nv_mutual") As tError
            Dim doc_bytes() As Byte = Nothing
            Dim op As nvFW.nvSecurity.tnvOperador = nvFW.nvApp.getInstance().operador
            Dim nro_operador As Integer = op.operador
            Dim ins = nvFW.nvApp.getInstance()
            Dim server As String = ins.cod_servidor
            'Dim cod_sistema As String = ins.cod_sistema
            If (cod_sistema Is Nothing) Then
                cod_sistema = ins.cod_sistema
            End If

            Dim nro_archivo As String = ""
            Dim Err = New tError()
            Dim path_rova As String = ""
            Dim path_archivo As String = ""
            Try
                'Guardado en Rova
                ''Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path,d.archivo_def_tipo from helpdesk.dbo.nv_servidor_sistema_dir,archivos_def_tipo d where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = '" & cod_sistema & "' and cod_servidor = '" & server & "' and cod_ss_dir = 'nvArchivosDefault' and d.nro_archivo_def_tipo=" & nro_archivo_def_tipo)
                Dim rs1 = nvFW.nvDBUtiles.DBOpenRecordset("select nro_credito, nro_archivo, [Path], Descripcion  from verArchivos where nro_credito=" & CStr(nro_credito) & " and nro_archivo_def_tipo = " & CStr(nro_archivo_def_tipo) & " and nro_archivo_estado = 1")
                If (rs1.EOF = True) Then
                    Err.numError = 1
                    Err.mensaje = "no se existe el archivo en el legajo"
                    Err.params("cod_sistema") = cod_sistema
                    Err.params("server") = server
                    Return Err
                End If
                Dim Descripcion As String = rs1.Fields("Descripcion").Value
                nro_archivo = rs1.Fields("nro_archivo").Value
                Err.params("nro_archivo") = nro_archivo
                Dim path_file As String = rs1.Fields("Path").Value
                rs1.Close()
                path_rova = ""

                Dim rsrova As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = '" & cod_sistema & "' and cod_servidor = '" & server & "' and [path]<>'' ")
                ''busco en todas las carpetas posibles
                While Not rsrova.EOF
                    path_rova = rsrova.Fields("path").Value
                    If (System.IO.File.Exists(path_rova & path_file)) Then
                        path_archivo = path_rova & path_file
                        Exit While
                    End If
                    rsrova.MoveNext()
                End While
                rsrova.Close()
                If (path_archivo = "") Then
                    Err.numError = 2
                    Err.mensaje = "no se encontro el archivo nro. " & nro_archivo & " en los servidores"
                    Err.params("cod_sistema") = cod_sistema
                    Err.params("server") = server
                    Return Err
                End If

                If (path_archivo <> "") Then
                    doc_bytes = System.IO.File.ReadAllBytes(path_archivo.Replace("\", "\\"))
                End If
                If (doc_bytes Is Nothing) Then
                    Err.numError = 3
                    Err.mensaje = "no se pudo convertir el archivo nro. " & nro_archivo & " del legajo"
                Else
                    Err.params("path_archivo") = path_archivo.Replace("\", "\\")
                    Err.params("binary") = doc_bytes
                End If

            Catch ex As Exception
                Err.parse_error_script(ex)
            End Try
            Return Err
        End Function
    End Class
End Namespace
