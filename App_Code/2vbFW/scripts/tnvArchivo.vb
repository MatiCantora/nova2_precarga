Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Public Class tnvArchivo

        Public nro_archivo As Integer
        Public id_tipo As Integer
        Public nro_archivo_id_tipo As Integer
        Public nro_def_archivo As Integer
        Public nro_def_detalle As Integer
        Public nro_com_id_tipo As Integer
        Public isFisical As Boolean
        Public operador As Integer
        Public descripcion As String
        Public filename As String
        Public file_ext As String
        Public orden As Integer
        Public version As String = ""
        Public fe_inicio As Date
        Public nro_img_origen As enumOrigen = enumOrigen.browser
        Public cant_hojas As Integer = 0
        Public ComputerName As String = ""
        Public pages_params As Dictionary(Of Integer, tnvPageParams)
        Public auto As Integer = 0
        Public porc As Integer = 0
        Public disp As String = "Manual"
        Public com_nro_registro_depende As Integer
        Public com_parametros As String
        Public exts_permitidas As String()
        Public file_max_size As Integer
        Public repetido As Boolean = False
        Public BinaryData As Byte()
        Public archivo_error As tError
        Public nro_registro As Integer = 0
        Public f_nro_ubi As Integer = 1
        Public f_path As String = ""
        Public f_id As Integer
        Public nro_venc_tipo As Integer
        Public venc_dias As Integer
        Public venc_function As String
        Public fe_venc As DateTime
        Public fe_venc_param As DateTime

        Public Sub New(Optional BinaryData As Byte() = Nothing, Optional id_tipo As Integer = 0, Optional nro_archivo_id_tipo As Integer = 0, Optional nro_def_archivo As Integer = 0, Optional nro_def_detalle As Integer = 0, Optional nro_com_id_tipo As Integer = 0 _
                              , Optional operador As Integer = 0, Optional descripcion As String = "", Optional filename As String = "", Optional file_ext As String = "", Optional version As String = "" _
                              , Optional fe_inicio As Date = Nothing, Optional nro_img_origen As enumOrigen = enumOrigen.browser _
                              , Optional ComputerName As String = "", Optional xmlError As String = "", Optional xmlInfo As String = "", Optional auto As Integer = 0 _
                              , Optional porc As Integer = 0, Optional disp As String = "", Optional com_nro_registro_depende As Integer = Nothing, Optional com_parametros As String = "", Optional fe_venc_param As DateTime = Nothing _
                              , Optional nro_archivo As Integer = 0, Optional isFisical As Boolean = False)

            Try

                Me.id_tipo = id_tipo
                Me.nro_archivo_id_tipo = nro_archivo_id_tipo
                Me.nro_def_archivo = nro_def_archivo
                Me.nro_def_detalle = nro_def_detalle
                Me.nro_com_id_tipo = nro_com_id_tipo
                Me.descripcion = descripcion
                Me.nro_img_origen = IIf(xmlError = "1" And nro_img_origen = 1, enumOrigen.nvclient, nro_img_origen)
                Me.operador = IIf(operador = 0, nvFW.nvApp.getInstance().operador.operador, operador)
                Me.filename = filename
                Me.file_ext = file_ext
                Me.version = version
                Me.nro_img_origen = nro_img_origen
                Me.ComputerName = ComputerName
                Me.auto = auto
                Me.porc = porc
                Me.disp = disp
                Me.com_nro_registro_depende = com_nro_registro_depende
                Me.com_parametros = com_parametros
                Me.BinaryData = BinaryData
                Me.nro_archivo = nro_archivo
                Me.archivo_error = New tError
                Me.pages_params = New Dictionary(Of Integer, tnvPageParams)
                Me.orden = 0
                Me.nro_registro = 0
                Me.fe_venc_param = fe_venc_param
                Me.fe_venc = Nothing
                Me.isFisical = isFisical

                Dim strSQL As String = ""
                If Me.descripcion <> "" And Me.nro_def_detalle = 0 Then strSQL = "Select nro_def_detalle,file_max_size,f_nro_ubi,f_path,archivo_descripcion,readonly,orden,file_filtro,repetido,nro_venc_tipo,venc_dias,venc_function,null as fe_venc from archivos_def_detalle where archivo_descripcion Like '%" & Me.descripcion & "%' and nro_def_archivo =" & Me.nro_def_archivo.ToString & ""
                If Me.nro_def_detalle > 0 Then strSQL = "Select nro_def_detalle,file_max_size,f_nro_ubi,f_path,archivo_descripcion,readonly,orden,file_filtro,repetido,nro_venc_tipo,venc_dias,venc_function,null as fe_venc from archivos_def_detalle where nro_def_detalle = " & Me.nro_def_detalle & ""
                If Me.nro_archivo > 0 Then strSQL = "Select nro_def_detalle,file_max_size,f_nro_ubi,f_path,archivo_descripcion,readonly,orden,file_filtro,repetido,nro_venc_tipo,venc_dias,venc_function,fe_venc from verArchivos_idtipo where nro_archivo = " & Me.nro_archivo & ""

                If strSQL = "" Then
                    Exit Sub
                End If

                Dim rsDet As ADODB.Recordset = DBOpenRecordset(strSQL)
                If Not rsDet.EOF Then
                    Me.nro_def_detalle = rsDet.Fields("nro_def_detalle").Value
                    Me.descripcion = IIf(Me.descripcion = "" Or rsDet.Fields("readonly").Value = True, rsDet.Fields("archivo_descripcion").Value, Me.descripcion)
                    Me.exts_permitidas = rsDet.Fields("file_filtro").Value.Split("|")
                    Me.file_max_size = rsDet.Fields("file_max_size").Value
                    Me.f_nro_ubi = rsDet.Fields("f_nro_ubi").Value
                    Me.f_path = rsDet.Fields("f_path").Value
                    Me.repetido = rsDet.Fields("repetido").Value
                    Me.orden = rsDet.Fields("orden").Value
                    Me.nro_venc_tipo = IIf(IsDBNull(rsDet.Fields("nro_venc_tipo").Value), Nothing, rsDet.Fields("nro_venc_tipo").Value)
                    Me.venc_dias = IIf(IsDBNull(rsDet.Fields("venc_dias").Value), Nothing, rsDet.Fields("venc_dias").Value)
                    Me.venc_function = IIf(IsDBNull(rsDet.Fields("venc_function").Value), "", rsDet.Fields("venc_function").Value)
                    Me.fe_venc = IIf(IsDBNull(rsDet.Fields("fe_venc").Value), Nothing, rsDet.Fields("fe_venc").Value)
                End If
                DBCloseRecordset(rsDet)

                Try
                    Dim oXML As New System.Xml.XmlDataDocument
                    oXML.LoadXml(xmlInfo)
                    Dim contar As Integer = 0
                    Dim nodes As System.Xml.XmlNodeList = oXML.SelectNodes("/pages/page")
                    For Each n As System.Xml.XmlElement In nodes
                        Dim pageparams As New tnvPageParams
                        pageparams.device = nvUtiles.isNUll(n.GetAttribute("device"), "")
                        pageparams.document_feeder = nvUtiles.isNUll(n.GetAttribute("document_feeder"), "True") = "True"
                        pageparams.id_definicion = nvUtiles.isNUll(n.GetAttribute("id_definicion"), 0)
                        pageparams.barcodes = nvUtiles.isNUll(n.GetAttribute("barcodes"), "")
                        pageparams.id_tipo = nvXMLUtiles.getNodeText(n, "id_tipo", 0)
                        pageparams.nro_pagina = nvXMLUtiles.getNodeText(n, "nro_pagina", 0)
                        pageparams.orden = nvXMLUtiles.getNodeText(n, "orden", "")
                        pageparams.nro_archivo_def_tipo = nvXMLUtiles.getNodeText(n, "nro_archivo_def_tipo", 0)
                        pages_params.Add(contar, pageparams)
                        contar = contar + 1
                    Next
                    Me.cant_hojas = contar
                Catch ex As Exception

                End Try

            Catch ex As Exception

            End Try

        End Sub

        Public Function save() As tError

            Dim err As New tError
            err.params("nro_archivo") = ""
            err.params("filename") = ""
            err.params("link") = ""
            err.params("nro_registro") = ""
            Dim strSQL As String = ""
            Dim path_rel As String = ""

            Try
                'Dim momento As DateTime = Now ' rs.Fields("momento").Value

                If Me.isFisical = False Then

                    'validaciones
                    If Me.descripcion = "" Then
                        err.numError = -97
                        err.titulo = "Falta descripción"
                        err.mensaje = "El archivo no tiene una descripcion asociada."
                        GoTo _gt_error
                    End If

                    If Me.BinaryData.Length > Me.file_max_size Then
                        err.numError = -97
                        err.titulo = "Tamaño máximo"
                        err.mensaje = "El archivo excede el tamaño permitido."
                        GoTo _gt_error
                    End If

                    If Me.exts_permitidas.Contains(Me.file_ext.ToLower) = False Then
                        err.numError = -98
                        err.titulo = "Formato incorrecto"
                        err.mensaje = "El tipo del archivo no es valido."
                        GoTo _gt_error
                    End If

                    strSQL = "If (select columnproperty(object_id('archivos'),'nro_archivo','IsIdentity')) = 1 "
                    strSQL += "begin "

                    strSQL += "Insert Into archivos (Descripcion,id_tipo,nro_archivo_id_tipo,momento,nro_def_detalle,operador,nro_archivo_estado,nro_img_origen,cant_hojas,f_nro_ubi) values('" & Me.descripcion & "','" & Me.id_tipo & "'," & Me.nro_archivo_id_tipo & ",getdate()," & Me.nro_def_detalle & "," & Me.operador & ",1," & Me.nro_img_origen & "," & Me.cant_hojas & "," & Me.f_nro_ubi & ")" & vbCrLf
                    strSQL += "select SCOPE_IDENTITY() as nro_archivo "

                    strSQL += "End "
                    strSQL += "Else begin "
                    strSQL += "declare @nro_archivo_identity bigint "
                    strSQL += "select @nro_archivo_identity = isnull(max(nro_archivo), 0) + 1 from archivos WITH (NOLOCK)  "

                    strSQL += "Insert Into archivos (nro_archivo, Descripcion,id_tipo,nro_archivo_id_tipo,momento,nro_def_detalle,operador,nro_archivo_estado,nro_img_origen,cant_hojas,f_nro_ubi) values(@nro_archivo_identity, '" & Me.descripcion & "','" & Me.id_tipo & "'," & Me.nro_archivo_id_tipo & ",getdate()," & Me.nro_def_detalle & "," & Me.operador & ",1," & Me.nro_img_origen & "," & Me.cant_hojas & "," & Me.f_nro_ubi & ")" & vbCrLf

                    strSQL += "select @nro_archivo_identity as nro_archivo "
                    strSQL += "End "


                    Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)
                    Me.nro_archivo = rs.Fields("nro_archivo").Value
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)
                    strSQL = ""

                    If Me.filename = "" Then
                        Me.filename = nro_archivo & Me.file_ext
                    End If

                    If Me.file_ext = "" Then
                        Me.file_ext = System.IO.Path.GetExtension(filename)
                    End If

                    If Me.f_nro_ubi = 1 Then
                        err = SaveFileSystem()
                        path_rel = err.params("path_rel")
                    Else
                        err = SaveDocumenManager()
                        Me.f_id = err.params("f_id")
                    End If

                    If err.numError <> 0 Then
                        GoTo _gt_error
                    End If

                    strSQL = ""

                    Dim index As Integer
                    For Each index In Me.pages_params.Keys
                        pages_params(index).save(nro_archivo)
                    Next

                    If Me.nro_img_origen = enumOrigen.nvclient Then

                        Dim disp As String = "nvClient " & version + " - " & ComputerName
                        Dim reg As Integer = 0
                        If auto = 1 Then reg = 1

                        strSQL = "insert into archivos_img_clas values (" + Me.nro_archivo + ", " + auto + "," + reg + ",0," + Me.nro_def_detalle + "," + Me.porc + ",'" + disp + "')" & vbCrLf

                    End If

                Else

                    strSQL = "Insert Into archivos (Descripcion,id_tipo,nro_archivo_id_tipo,momento,nro_def_detalle,operador,nro_archivo_estado) values('" & Me.descripcion & "','" & Me.id_tipo & "'," & Me.nro_archivo_id_tipo & ",getdate()," & Me.nro_def_detalle & "," & Me.operador & ",3)" & vbCrLf
                    strSQL += "select SCOPE_IDENTITY() as nro_archivo "
                    Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)
                    Me.nro_archivo = rs.Fields("nro_archivo").Value
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)
                    strSQL = ""

                End If

                ' inserta comentario atado al archivo
                Dim filtro_nro_registro As String = ""
                Dim errCom As tError = guardar_comentario()
                If errCom.numError = 0 Then

                    If errCom.params("nro_registro") <> "" Then
                        Me.nro_registro = errCom.params("nro_registro")
                        filtro_nro_registro = ", nro_registro = " & errCom.params("nro_registro")
                    End If

                End If

                'si no es repetido anula el anterior
                If Me.repetido = False Then
                    strSQL += "update archivos Set nro_archivo_estado = 2 where nro_def_detalle = " & Me.nro_def_detalle & " And id_tipo = " & Me.id_tipo & " And nro_archivo_id_tipo=" & Me.nro_archivo_id_tipo & " And nro_archivo <> " & Me.nro_archivo & vbCrLf
                End If

                'insertar parametros de la definición
                strSQL += "insert into archivos_parametros (nro_archivo,parametro,parametro_valor,fe_actualizacion,nro_operador) " & vbCrLf
                strSQL += "select " & Me.nro_archivo & " as nro_archivo,parametro,'' as parametro_valor,getdate() as fe_actualizacion,dbo.rm_nro_operador() as nro_operador " & vbCrLf
                strSQL += "from archivos_parametro_def where archivo_descripcion = '" & Me.descripcion & "'" & vbCrLf

                strSQL += "update archivos set momento=getdate(), path = '" & path_rel & "' " & filtro_nro_registro & ""
                If (Me.f_id > 0) Then
                    strSQL += " , f_id=" & Me.f_id & " "
                End If
                strSQL += " where nro_archivo = " & Me.nro_archivo & vbCrLf

                nvFW.nvDBUtiles.DBExecute(strSQL)

                'insertar vencimiento
                '1 fecha de alta + dias de venciminetos 
                '2 fecha de documento + dias de venciminetos
                '3 valor de funcion
                Me.fe_venc = getFechaVencimiento()
                If Me.fe_venc <> Nothing Then
                    strSQL = "insert into archivos_venc (nro_archivo,fe_venc,vigente) values (" & Me.nro_archivo & " ,cast('" & Me.fe_venc.ToString("yyyyMMdd") & "' as datetime),1)" & vbCrLf
                    nvFW.nvDBUtiles.DBExecute(strSQL)
                End If

                err.params("nro_archivo") = Me.nro_archivo
                err.params("filename") = Me.filename
                err.params("link") = "\fw\files\file_get.aspx?path=" & path_rel & "&f_id=" & Me.f_id
                err.params("nro_registro") = Me.nro_registro

            Catch ex As Exception

                If Me.nro_archivo > 0 Then
                    nvFW.nvDBUtiles.DBExecute("DELETE FROM archivos_img_clas WHERE nro_archivo = " & Me.nro_archivo)
                    nvFW.nvDBUtiles.DBExecute("DELETE FROM archivos_venc WHERE nro_archivo = " & Me.nro_archivo)
                    nvFW.nvDBUtiles.DBExecute("DELETE FROM archivos WHERE nro_archivo = " & Me.nro_archivo)
                    nvFW.nvDBUtiles.DBExecute("DELETE FROM archivos_parametros WHERE nro_archivo = " & Me.nro_archivo)
                End If

                err.numError = -99
                err.titulo = "Subida de archivos"
                err.mensaje = "El archivo no existe detalle:" & ex.Message & " sql:" & strSQL
            End Try

_gt_error:
            Me.archivo_error = err
            Return err

        End Function

        Public Function SaveFileSystem() As tError
            Dim err As New tError
            err.params("path_rel") = ""

            Try

                Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
                Dim path As String = nvReportUtiles.get_file_path("FILE://(nvFiles)/")
                If System.IO.Directory.Exists(path) = False Then
                    err.numError = -99
                    err.titulo = "Grabado de archivo"
                    err.mensaje = "No existe la ruta destino"
                    Return err
                End If

                Me.filename = path & "\" & carpeta & "\" & nro_archivo & Me.file_ext

                nvFW.nvReportUtiles.create_folder(filename)

                Dim fs = New System.IO.FileStream(filename, System.IO.FileMode.Create, System.IO.FileAccess.ReadWrite)
                fs.Write(Me.BinaryData, 0, Me.BinaryData.Length)
                fs.Close()

                err.params("path_rel") = carpeta & "\" & Me.nro_archivo & Me.file_ext

            Catch ex As Exception
                err.numError = -99
                err.titulo = "Grabado de archivo"
                err.mensaje = "Imposible guardar el archivo"
            End Try

            Return err

        End Function

        Public Function SaveDocumenManager() As tError

            Dim err As New tError
            err.params("f_id") = 0
            err.params("f_path") = ""

            Dim f_depende_de As Integer
            Dim f_nro_ubi_default As Integer
            Dim f_nro_ubi As Integer

            Dim file As New tUpload(0)
            file.filename = Me.filename
            file.size = Me.BinaryData.Length

            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select f_id,f_nro_ubi,f_nro_ubi_default from [verRef_files] where f_tipo in ('disco','carpeta') and ref_files_path like '" & Me.f_path & "'")
            If rs.EOF = True Then
                err.numError = -99
                err.mensaje = "No existe el path " & Me.f_path
                Return err
            End If

            f_depende_de = rs.Fields("f_id").Value
            f_nro_ubi_default = rs.Fields("f_nro_ubi_default").Value
            f_nro_ubi = rs.Fields("f_nro_ubi").Value
            nvDBUtiles.DBCloseRecordset(rs)

            rs = nvDBUtiles.DBOpenRecordset("select dbo.ref_file_permiso_operador('" & f_depende_de & "') as permiso")
            Dim permiso = rs.Fields("permiso").Value
            nvDBUtiles.DBCloseRecordset(rs)

            If (permiso And 8) = 0 Then
                err.numError = -99
                err.mensaje = "No tiene permiso para subir archivos en esta carpeta."
                Return err
            End If

            Dim f_ext As String = System.IO.Path.GetExtension(filename).Substring(1)
            Dim f_nombre As String = System.IO.Path.GetFileName(filename)
            f_nombre = Split(f_nombre, ".")(0)
            file.path_tmp = System.IO.Path.GetTempFileName

            Dim fs = New System.IO.FileStream(file.path_tmp, System.IO.FileMode.Create, System.IO.FileAccess.ReadWrite)
            fs.Write(Me.BinaryData, 0, Me.BinaryData.Length)
            fs.Close()

            ' Controlar archivo duplicado
            Dim archivoExiste As Boolean = False
            Dim f_id_existente As String = ""
            If file.path_tmp <> "" Then
                Dim rs1 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("Select f_id from ref_files where borrado = 0 and f_depende_de = '" & f_depende_de & "' and f_nombre = '" & Replace(f_nombre, "'", "''") & "' and f_ext = '" & Replace(f_ext, "'", "''") & "'")
                If Not rs1.EOF Then
                    archivoExiste = True
                    f_id_existente = rs1.Fields("f_id").Value
                End If
                nvDBUtiles.DBCloseRecordset(rs1)
            End If

            Dim dirs() As String
            Dim base_path As String = ""

            If f_nro_ubi = 1 Then
                Try
                    dirs = nvApp.getInstance().app_dirs("nvFiles").path.Split(";")
                    base_path = dirs(0)
                Catch ex As Exception

                End Try
                If Not System.IO.Directory.Exists(base_path) Or base_path = "" Then
                    err.numError = 12
                    err.titulo = "Error al intentar subir el archivo"
                    err.mensaje = "La carpeta de detino no existe"
                    Return err
                End If
            End If

            Dim strSQL As String = ""
            If archivoExiste Then
                strSQL = "UPDATE ref_files SET borrado=1  where f_id=" & f_id_existente & vbLf
            End If
            strSQL += "INSERT INTO ref_files(f_nombre, f_ext, f_descripcion, f_path, f_falta, f_nro_tipo, f_depende_de, f_size, f_nro_ubi, f_nro_ubi_default) VALUES ('" & f_nombre & "', '" & f_ext & "', '', '', getdate(), 1, " & f_depende_de & ", '" & CType(file.size / 1024, Integer) & "', " & CType(f_nro_ubi, String) & "," & CType(f_nro_ubi_default, String) & ")"


            Dim cn = nvDBUtiles.DBConectar()
            cn.BeginTrans()
            Try
                cn.Execute(strSQL)
                strSQL = "Select @@identity as f_id"
                Dim rsID = cn.Execute(strSQL)
                file.file_id = rsID.Fields("f_id").Value
                rsID.Close()
                err.params("f_id") = CType(file.file_id, String)

                'cuando se guarda en el sistema de archivos
                If f_nro_ubi = 1 Then
                    filename = base_path & "file" & file.file_id & "." & f_ext
                    strSQL = "UPDATE ref_files set f_path = '" & Replace(file.filename, "'", "''") & "' where f_id = " & file.file_id
                    cn.Execute(strSQL)
                    file.mover(filename, True)
                Else
                    'cuando se guarda en BD
                    Dim cmd As New ADODB.Command()
                    cmd.CommandType = ADODB.CommandTypeEnum.adCmdStoredProc
                    cmd.CommandText = "ref_file_bin_actualizar"
                    cmd.ActiveConnection = cn
                    cmd.Parameters("@f_id").Value = file.file_id
                    cmd.Parameters("@BinaryData").Type = 205
                    cmd.Parameters("@BinaryData").Size = Me.BinaryData.Length
                    cmd.Parameters("@BinaryData").AppendChunk(Me.BinaryData)
                    cmd.Execute()

                End If
                cn.CommitTrans()
            Catch ex As Exception
                cn.RollbackTrans()
            End Try
            cn.Close()


            Return err
        End Function


        Private Function getFechaVencimiento() As DateTime

            '1 fecha de alta + dias de venciminetos 
            '2 fecha de documento + dias de venciminetos
            '3 valor de funcion
            Try

                Select Case Me.nro_venc_tipo
                    Case 1
                        Return DateAdd(DateInterval.Day, Me.venc_dias, Now())
                    Case 2
                        If Not Me.fe_venc_param = Nothing Then Return DateAdd(DateInterval.Day, Me.venc_dias, Me.fe_venc_param) 'fecha del documento, un parametro 
                    Case 3
                        If Me.venc_function.IndexOf("dbo.") = -1 Then
                            Me.venc_function = "dbo." & Me.venc_function
                        End If
                        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute("select " & Me.venc_function.Replace("(FN)", "(" & Me.nro_archivo & ")") & " as fe_venc")
                        Return rs.Fields("fe_venc").value
                    Case Else
                End Select

            Catch ex As Exception

            End Try

            Return Nothing

        End Function

        Public Function setFechaVencimiento() As tError

            Dim err As New tError
            'err.params("fe_venc") = ""
            Try
                '  Dim fe_venc_nueva As datetime = getFechaVencimiento()
                '  If fe_venc_nueva = Me.fe_venc Then
                '      err.params("fe_venc") = Me.fe_venc.ToString("yyyyMMdd")
                '  Return err
                '   End If

                '  If Me.fe_venc <> Nothing Then
                'Dim strSQL As String = ""
                ' strSQL = "update archivos_venc set vigente = 0, fe_baja = getdate() where vigente = 1 and nro_archivo = " & Me.nro_archivo & " " & vbCrLf
                ' strSQL += "insert into archivos_venc (nro_archivo,fe_venc,vigente) values (" & Me.nro_archivo & ",cast('" & Me.fe_venc.ToString("yyyyMMdd") & "' as datetime),1)" & vbCrLf

                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("dbo.archivos_set_vencimiento", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@nro_archivo_id_tipo", ADODB.DataTypeEnum.adInteger, 1, 255, iif(Me.nro_archivo_id_tipo = Nothing, 0, Me.nro_archivo_id_tipo))
                cmd.addParameter("@id_tipo", ADODB.DataTypeEnum.adInteger, 1, 0, iif(Me.id_tipo = Nothing, 0, Me.id_tipo))
                cmd.addParameter("@nro_def_archivo", ADODB.DataTypeEnum.adInteger, 1, 0, iif(Me.nro_def_archivo = Nothing, 0, Me.nro_def_archivo))
                cmd.addParameter("@nro_def_detalle", ADODB.DataTypeEnum.adInteger, 1, 0, iif(Me.nro_def_detalle = Nothing, 0, Me.nro_def_detalle))
                cmd.addParameter("@nro_archivo", ADODB.DataTypeEnum.adInteger, 1, 0, iif(Me.nro_archivo = Nothing, 0, Me.nro_archivo))

                Dim res As ADODB.Recordset = cmd.Execute()
                If Not res.EOF Then
                    err.numError = res.Fields("numError").Value
                    err.titulo = res.Fields("titulo").Value
                    err.mensaje = res.Fields("mensaje").Value
                End If
                nvDBUtiles.DBCloseRecordset(res)
                '     End If
                ' err.params("fe_venc") = Me.fe_venc.ToString("yyyyMMdd")

            Catch ex As Exception
                err.numError = -99
                err.titulo = "Error al intentar actulizar"
                err.mensaje = "La fecha de vencimiento no pudo ser actualizada" & Me.fe_venc.ToString("yyyyMMdd")
            End Try

            Return err

        End Function


        Private Function guardar_comentario() As tError

            Dim err As New tError
            err.params("nro_registro") = ""

            If com_parametros = "" Then
                Return err
            End If

            Try

                Dim strSQL As String = "exec dbo.rm_com_add_archivo " & Me.id_tipo & "," & Me.nro_com_id_tipo & ", " & Me.nro_def_archivo & ", " & Me.orden & ",'' ," & Me.operador & ", " & Me.com_nro_registro_depende & ", " & Me.com_parametros & " "
                Dim rsRegistro As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)
                Dim nro_registro As String = rsRegistro.Fields("nro_registro").Value
                err.params("nro_registro") = nro_registro
                nvDBUtiles.DBCloseRecordset(rsRegistro)
            Catch ex As Exception
                err.numError = -99
                err.mensaje = "No se pudo cargar el comentario asociado"
            End Try

            Return err

        End Function
    End Class

    Public Class tnvPageParams

        Public device As String
        Public document_feeder As Boolean
        Public barcodes As String
        Public id_definicion As Integer
        Public nro_tipo_clasificacion As Integer
        Public id_tipo As Integer
        Public nro_archivo_id_tipo As Integer = 0
        Public nro_pagina As String = ""
        Public orden As Integer = 0
        Public nro_archivo_def_tipo As Integer = 0

        Public Sub New()
            Me.device = ""
            Me.document_feeder = False
            Me.barcodes = ""
            Me.id_definicion = 0
            Me.nro_tipo_clasificacion = 0
            Me.id_tipo = 0
            Me.nro_archivo_id_tipo = 0
            Me.nro_pagina = ""
            Me.orden = 0
            Me.nro_archivo_def_tipo = 0
        End Sub

        Function save(nro_archivo As Integer) As tError

            Dim err As New tError()
            Try
                Dim StrSQL As String = "insert into archivos_hojas_param (nro_archivo,nro_tipo_clasificacion,id_tipo,nro_pagina,barcode,barcode_pag,id_definicion,device,document_feeder,nro_archivo_def_tipo)"
                StrSQL += " values(" + nro_archivo + ", " + Me.nro_tipo_clasificacion + ", " + Me.id_tipo + ", " + Me.orden + ",'" + Me.barcodes + "','" + Me.nro_pagina + "','" + Me.id_definicion + "','" + Me.device + "'," + Me.document_feeder + "," + Me.nro_archivo_def_tipo + ")"
                nvDBUtiles.DBExecute(StrSQL)

            Catch ex As Exception
                err.numError = -99
                err.titulo = "Guardar parametros documento"
                err.mensaje = "Error al guardar los parametros de hojas de un documento."
            End Try
            Return err

        End Function

    End Class

    Public Class nvArchivo

        Public Shared Function recalcacular_vencimientos_archivo(nro_archivo As Integer) As terror

            Dim err As New tError
            Dim ar As tnvArchivo = New tnvArchivo(nro_archivo:=nro_archivo)
            ar.nro_def_detalle = 0
            err = ar.setFechaVencimiento()

            Return err
        End Function

        Public Shared Function recalcacular_vencimientos_archivo_def(nro_def_archivo As Integer) As terror

            Dim err As New tError
            Dim ar As tnvArchivo = New tnvArchivo(nro_def_archivo:=nro_def_archivo)
            err = ar.setFechaVencimiento()

            Return err
        End Function

        Public Shared Function recalcacular_vencimientos_archivo_detalle(nro_def_detalle As Integer) As terror

            Dim err As New tError
            Dim ar As tnvArchivo = New tnvArchivo(nro_def_detalle:=nro_def_detalle)
            err = ar.setFechaVencimiento()

            Return err
        End Function

        Public Shared Function recalcacular_vencimientos_id_tipo(nro_archivo_id_tipo As Integer, id_tipo As Integer) As terror

            Dim err As New tError
            Dim ar As tnvArchivo = New tnvArchivo(nro_archivo_id_tipo:=nro_archivo_id_tipo, id_tipo:=id_tipo)
            err = ar.setFechaVencimiento()

            Return err
        End Function

    End Class

    Public Enum enumOrigen
        browser = 1
        nvclient = 2
    End Enum
End Namespace
