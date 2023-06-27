Imports Microsoft.VisualBasic
Imports nvFW
Imports System.Web.Script.Serialization
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports EcmaScript.NET
Imports System.Security.Cryptography


Namespace nvFW.nvTransferencia
    'Public  Class pvTransferenciaCache
    '    Public Shared cache As New Dictionary(Of String, tTransfererncia)
    'End Class
    Public Class tTransfererncia
        Inherits System.MarshalByRefObject
        Public id_transferencia As Integer
        Public serial As String
        Public nombre As String
        Public habilitada As Boolean
        Public id_transf_log As Integer
        Public id_transf_det As Integer
        Public estado As nvenumTransfEstado = nvenumTransfEstado.no_iniciada
        Public timeout As Integer
        Public transf_version As String
        <ScriptIgnore()>
        Public param As New Dictionary(Of String, trsParam)
        Public Archivos As New Dictionary(Of String, Dictionary(Of String, Object))
        Public dets As New Dictionary(Of String, tTransfDet)
        Public dets_run As New List(Of tCola_det)
        Public transf_det_pendiente As tTransfDet
        Public tiene_opcionales As Boolean = False
        Public tiene_opcionales_msg As String = "Tareas opcionales no vienen el valor del opcional y están habilitadas: " & vbCrLf

        Public salida_tipo As nvenumSalidaTipo
        Public transf_error As New tError
        Public log_param_save As enum_log_param_save = enum_log_param_save.todo
        Public tiene_requeridos_pendientes As Boolean = False
        Public tiene_requeridos_pendientes_msg As String = "Existen parámetros que no tienen valor y son requeridos: " & vbCrLf
        Public tiene_editables As Boolean = False

        'Conexion global de toda la transaccion
        Public ActiveConnections As New Dictionary(Of String, ADODB.Connection)

        'Public Property tareas(id As Integer) As tTransfDet
        '    Get
        '        Return dets(id)
        '    End Get
        '    Set(value As tTransfDet)
        '        dets(id) = value
        '    End Set
        'End Property

        Public Sub limpiar()
            id_transf_log = 0
            Me.dets_run.Clear()
            For Each det In Me.dets.Values
                det.id_transf_log_det = 0
                det.estado = nvenumTransfEstado.no_iniciada
            Next

            For Each p In Me.param.Values
                p("value") = p("original_value")
            Next


        End Sub

        Public Function cargar(id_transferencia As Integer, Optional xml_param As String = "", Optional xml_det_opcional As String = "") As tError

            Dim det As tTransfDet
            Dim objError As New tError
            Dim rsTransf As ADODB.Recordset
            Dim rsRel As ADODB.Recordset
            Dim rsTareas As ADODB.Recordset
            Dim rsParam As ADODB.Recordset
            Dim nvApp = nvFW.nvApp.getInstance()

            '  Dim id_cache As String = nvServer.cod_servidor & "_" & nvApp.cod_sistema & "_" & id_transferencia


            Try
                rsTransf = nvDBUtiles.DBExecute("Select * from transferencia_cab where id_transferencia = " & id_transferencia)
                ' // si el id no existe
                If (rsTransf.EOF) Then
                    objError.numError = 12001 '     objError.cargar_msj_error(12010)
                    objError.titulo = "Error al cargar la transferencia"
                    objError.mensaje = "La transferencia no existe"
                    'Transf.error_limpiar_archivos()
                    nvDBUtiles.DBCloseRecordset(rsTransf)
                    Return objError
                End If


                '//Validar si el XML es correcto
                Dim objXML As New System.Xml.XmlDocument
                If Trim(xml_param) <> "" Then
                    Try
                        objXML.LoadXml(xml_param)
                    Catch ex As Exception
                        objError.parse_error_xml(ex)
                        objError.numError = 12002
                        objError.titulo = "Error al intentar ejecutar la transferencia"
                        objError.mensaje = "Error al cargar los parámetros(xml_param)"
                        Me.error_limpiar_archivos()
                        Return objError
                    End Try
                End If

                '//Si el correcto el XML
                Dim objXML_det_opcional As New System.Xml.XmlDocument
                If Trim(xml_det_opcional) <> "" Then
                    Try
                        objXML_det_opcional.LoadXml(xml_det_opcional)
                    Catch ex As Exception
                        objError.parse_error_xml(ex)
                        objError.numError = 12002
                        objError.titulo = "Error al intentar ejecutar la transferencia"
                        objError.mensaje = "Error al cargar los parámetros(xml_det_opcional)"
                        Me.error_limpiar_archivos()
                        Return objError
                    End Try
                End If

                Me.serial = Guid.NewGuid.ToString()

                '/******************************************************************************************/
                '//                 SI TRAE ARCHIVOS COPIARLOS A LA CARPETA directorio_archivos
                '/******************************************************************************************/
                Me.Archivos = New Dictionary(Of String, Dictionary(Of String, Object))
                Dim Request As HttpRequest = Nothing
                Try
                    Request = HttpContext.Current.Request
                Catch ex As Exception

                End Try
                If Not Request Is Nothing Then
                    Dim archivo As Dictionary(Of String, Object)
                    Try
                        For Each campo In Request.Files.AllKeys
                            archivo = New Dictionary(Of String, Object)
                            If Request.Files(campo).FileName <> "" Then

                                ' //Guarda los archivos en el directorio_archivos
                                archivo.Add("existe", True)
                                archivo.Add("filename", System.IO.Path.GetFileName(Request.Files(campo).FileName))
                                archivo.Add("extension", System.IO.Path.GetExtension(archivo("filename")))
                                archivo.Add("size", Request.Files(campo).ContentLength)
                                archivo.Add("path", nvTransferencia.nvTransfUtiles.getFileTmpPath(archivo("filename"), serial:=Me.serial))

                                nvFW.nvReportUtiles.create_folder(archivo("path"))

                                Request.Files(campo).SaveAs(archivo("path"))

                            Else
                                archivo.Add("existe", False)
                                archivo.Add("filename", Nothing)
                                archivo.Add("extension", "")
                                archivo.Add("size", "")
                                archivo.Add("path", "")
                            End If
                            Me.Archivos.Add(campo, archivo)
                        Next
                    Catch ex As Exception
                        objError.parse_error_script(ex)
                        objError.titulo = "Error al intentar ejecutar la transferencia"
                        objError.mensaje = "Error al intentar cargar los parametro/s de archivo/s"
                        Me.error_limpiar_archivos()
                        Return objError
                    End Try
                End If


                ' /***********************************************/
                ' //Crear objeto transferencia
                ' /***********************************************/

                Me.estado = tTransfererncia.nvenumTransfEstado.no_iniciada
                Me.id_transferencia = id_transferencia
                Me.nombre = rsTransf.Fields("nombre").Value
                Me.habilitada = rsTransf.Fields("habi").Value.toUpper() = "S"
                'Me.id_transf_log = id_transf_log
                'Select Case salida_tipo.ToLower
                '    Case "estado"
                '        Transf.salida_tipo = nvenumSalidaTipo.estado
                '    Case Else
                '        Transf.salida_tipo = nvenumSalidaTipo.adjunto
                'End Select
                Me.transf_version = rsTransf.Fields("transf_version").Value.ToString

                ' /****************************************************************************/
                ' //Controla el tiempo maximo de ejecución de la transferencia
                ' /****************************************************************************/
                Me.timeout = rsTransf.Fields("timeout").Value
                'Server.ScriptTimeout = Transf.timeout

                '*************************************************************************
                'Cargar Dets
                '*************************************************************************
                Me.dets.Clear()
                rsTareas = nvDBUtiles.DBExecute("select *,dbo.[transf_det_tiene_permiso](id_transf_det) as tiene_permiso from Transferencia_det where id_transferencia = " & Me.id_transferencia)
                While Not rsTareas.EOF
                    det = New tTransfDet ' Me.dets(rsTareas.Fields("id_transf_det").Value)
                    det.Transf = Me
                    'det.det_error = New tError()
                    det.id_transf_det = rsTareas.Fields("id_transf_det").Value
                    det.transf_tipo = Trim(rsTareas.Fields("transf_tipo").Value)
                    det.habilitado = nvUtiles.isNUllorEmpty(rsTareas.Fields("transf_estado").Value, "A").ToUpper() = "A"
                    det.transf_det = rsTareas.Fields("transferencia").Value
                    det.TSQL = nvConvertUtiles.BytesToString(nvUtiles.isNUll(rsTareas.Fields("TSQL").Value, Nothing)) ' == null ? null : ByteArrayToString(rsTareas.fields('TSQL').value)
                    det.dtsx_path = nvUtiles.isNUllorEmpty(rsTareas.Fields("dtsx_path").Value, "")
                    det.dtsx_parametros = nvUtiles.isNUllorEmpty(rsTareas.Fields("dtsx_parametros").Value, "")
                    det.dtsx_exec = nvUtiles.isNUllorEmpty(rsTareas.Fields("dtsx_exec").Value, "TSQL") ' == null ? 'TSQL' : rsTareas.Fields('dtsx_exec').value
                    det.salida_tipo = IIf(nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("salida_tipo").Value, "'ESTADO'")).toUpper() = "ADJUNTO", nvenumSalidaTipo.adjunto, nvenumSalidaTipo.estado) '  : rsTareas.Fields('salida_tipo').value
                    det.filtroXML = nvUtiles.isNUllorEmpty(rsTareas.Fields("filtroXML").Value, "''")
                    det.filtroWhere = nvUtiles.isNUllorEmpty(rsTareas.Fields("filtroWhere").Value, "''")
                    det.xml_data = nvUtiles.isNUllorEmpty(rsTareas.Fields("xml_data").Value, "''")
                    det.report_name = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("report_name").Value, "''"))
                    det.path_reporte = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("path_reporte").Value, "''"))
                    det.contentType = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("contentType").Value, "''"))
                    det.target = nvUtiles.isNUllorEmpty(rsTareas.Fields("target").Value, "''")
                    det.xsl_name = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("xsl_name").Value, "''"))
                    det.path_xsl = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("path_xsl").Value, "''"))
                    det.xml_xsl = nvConvertUtiles.BytesToString(nvUtiles.isNUll(rsTareas.Fields("xml_xsl").Value, Nothing)) ' == null ? null : ByteArrayToString(rsTareas.fields('xml_xsl').value)
                    det.vistaguardada = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("vistaguardada").Value, "''"))
                    det.metodo = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("metodo").Value, "''"))
                    det.mantener_origen = nvConvertUtiles.JSScriptToObject(nvUtiles.isNUllorEmpty(rsTareas.Fields("mantener_origen").Value, "false")) = True
                    det.id_exp_origen = nvUtiles.isNUllorEmpty(rsTareas.Fields("id_exp_origen").Value, "0")
                    det.parametros = nvUtiles.isNUllorEmpty(rsTareas.Fields("parametros").Value, "")
                    det.parametros_extra_xml = New System.Xml.XmlDocument
                    Try
                        det.parametros_extra_xml.LoadXml(nvUtiles.isNUllorEmpty(rsTareas.Fields("parametros_extra_xml").Value, "<parametros_extra></parametros_extra>"))
                    Catch ex As Exception
                    End Try
                    det.xls_path = nvUtiles.isNUll(rsTareas.Fields("xls_path").Value, "")
                    det.lenguaje = nvUtiles.isNUll(rsTareas.Fields("lenguaje").Value, "")
                    det.cod_cn = nvUtiles.isNUll(rsTareas.Fields("cod_cn").Value, "")
                    det.estado = nvenumTransfEstado.no_iniciada
                    det.transf_estado = IIf(nvUtiles.isNUll(rsTareas.Fields("transf_estado").Value, "").toUpper = "A", "A", "N")
                    det.opcional = IIf(rsTareas.Fields("opcional").Value = True And rsTareas.Fields("tiene_permiso").Value = 1, True, False)
                    det.opcional_value = False
                    det.orden = rsTareas.Fields("orden").Value

                    Me.dets.Add(rsTareas.Fields("id_transf_det").Value, det)
                    rsTareas.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsTareas)

                '*************************************************************************
                'cargar relaciones
                '*************************************************************************
                rsRel = nvDBUtiles.DBExecute("select * from Transferencia_rel join Transferencia_Det origen on Transferencia_rel.det_origen = origen.id_transf_det where id_transferencia = " & Me.id_transferencia & " order by Transferencia_rel.orden, [default]")
                Dim id_transf_rel As Integer
                Dim ori As tTransfDet
                Dim dest As tTransfDet

                While Not rsRel.EOF
                    ori = Me.dets(rsRel.Fields("det_origen").Value)
                    dest = Me.dets(rsRel.Fields("det_destino").Value)
                    id_transf_rel = rsRel.Fields("id_transf_rel").Value

                    If ori.sigs Is Nothing Then ori.sigs = New Dictionary(Of String, trsParam)
                    If dest.ants Is Nothing Then dest.ants = New Dictionary(Of String, trsParam)

                    ori.sigs.Add(id_transf_rel, New trsParam)
                    ori.sigs(id_transf_rel)("det") = dest
                    ori.sigs(id_transf_rel)("evaluacion") = HttpUtility.HtmlDecode(rsRel.Fields("evaluacion").Value)
                    ori.sigs(id_transf_rel)("default") = rsRel.Fields("default").Value ' = true ? true : false
                    ori.sigs(id_transf_rel)("disabled") = False
                    dest.ants.Add(id_transf_rel, New trsParam)
                    dest.ants(id_transf_rel)("det") = ori
                    dest.ants(id_transf_rel)("evaluacion") = HttpUtility.HtmlDecode(rsRel.Fields("evaluacion").Value)
                    dest.ants(id_transf_rel)("default") = rsRel.Fields("default").Value ' == true ? true : false
                    dest.ants(id_transf_rel)("disabled") = False
                    rsRel.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsRel)


                'Cargar definición de parámetros
                Dim parametro As String
                rsParam = nvDBUtiles.DBExecute("Select * from transferencia_parametros where id_transferencia = " & Me.id_transferencia & " order by orden")
                Dim tParam As trsParam
                While Not rsParam.EOF
                    parametro = rsParam.Fields("parametro").Value
                    tParam = New trsParam
                    tParam("parametro") = rsParam.Fields("parametro").Value
                    tParam("tipo_dato") = rsParam.Fields("tipo_dato").Value.toLower()

                    If IsDBNull(rsParam.Fields("valor_defecto").Value) Or rsParam.Fields("valor_defecto").Value = "" Then
                        tParam("valor_defecto") = Nothing
                    Else
                        tParam("valor_defecto") = nvConvertUtiles.StringToObject(rsParam.Fields("valor_defecto").Value, tParam("tipo_dato"), True, "es-AR")
                    End If

                    tParam("valor_defecto_editable") = rsParam.Fields("valor_defecto_editable").Value
                    tParam("visible") = False
                    tParam("requerido") = rsParam.Fields("requerido").Value
                    tParam("editable") = rsParam.Fields("editable").Value
                    tParam("etiqueta") = rsParam.Fields("etiqueta").Value
                    tParam("orden") = rsParam.Fields("orden").Value
                    tParam("campo_def") = rsParam.Fields("campo_def").Value
                    tParam("id_param") = nvUtiles.isNUll(rsParam.Fields("id_param").Value, "")
                    tParam("file_max_size") = rsParam.Fields("file_max_size").Value
                    tParam("file_filtro") = rsParam.Fields("file_filtro").Value
                    tParam("interno") = nvUtiles.isNUll(rsParam.Fields("interno").Value, False)
                    tParam("file_error") = ""
                    tParam("valor") = Nothing

                    '//colocar el valor por defecto
                    If Not tParam("valor_defecto") Is Nothing Then tParam("valor") = tParam("valor_defecto")
                    'Tomar el valor de parametro gobal
                    If tParam("id_param") <> "" Then
                        tParam("valor") = nvConvertUtiles.StringToObject(nvUtiles.getParametroValor(tParam("id_param")), tParam("tipo_dato"), True, "es-AR")
                    End If

                    tParam("original_value") = tParam("valor")

                    Me.param.Add(parametro, tParam)
                    rsParam.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsParam)



                '' /********************************************/
                '' //Controlar que si es una ejecución pendiente
                '' /********************************************/

                If Me.id_transf_log > 0 Then

                    Dim rsTLog As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select estado from transf_log_cab where id_transf_log = " & Me.id_transf_log)
                    If (rsTLog.Fields("estado").Value.toLower() = "pendiente") Then
                        Me.estado = tTransfererncia.nvenumTransfEstado.Pendiente
                        '//Controlar que el usuario tenga permisos de ejecución
                        Dim strSQL As String = "select distinct id_transf_det,id_transf_log_det,fe_fin from verTransf_USR_pendientes where id_transf_log = " & Me.id_transf_log
                        strSQL += " and dbo.transf_det_tiene_permiso(id_transf_det) = 1 "
                        strSQL += " order by fe_fin"
                        Dim rsDetPend As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                        If rsDetPend.EOF Then
                            nvDBUtiles.DBCloseRecordset(rsDetPend)
                            objError.numError = 12001 '     objError.cargar_msj_error(12010)
                            objError.titulo = "Error al intentar ejecutar la transferencia"
                            objError.mensaje = "No tiene permisos para ejecutar esta transferencia en estado 'Pendiente'"
                            Me.error_limpiar_archivos()
                            objError.mostrar_error()
                        End If

                        Me.transf_det_pendiente = New tTransfDet
                        Me.transf_det_pendiente.id_transf_det = rsDetPend.Fields("id_transf_det").Value
                        Me.transf_det_pendiente.id_transf_log_det = rsDetPend.Fields("id_transf_log_det").Value
                        Me.transf_det_pendiente.fe_fin = nvUtiles.isNUll(rsDetPend.Fields("fe_fin").Value, Nothing)
                        nvDBUtiles.DBCloseRecordset(rsDetPend)
                        '//Identificar que tiene ejecuciones pendientes
                        Me.tiene_requeridos_pendientes = Me.id_transf_det <> Me.transf_det_pendiente.id_transf_det
                        '//Tomar el valor de las variables despues de la última ejecución

                        Dim rsValores As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select tlparam.parametro, valor, label, tipo, isnull(bfile,0) as bfile ,tipo_dato, descargable from transf_log_det tldet  " &
                                              "left outer join transf_log_param tlparam on tldet.id_transf_log_det = tlparam.id_transf_log_det " &
                                              "left outer join Transferencia_parametros tparam on tparam.parametro = tlparam.parametro and tlparam.id_transferencia = tparam.id_transferencia " &
                                              "left outer join Transferencia_parametros_USR as TUSR on TUSR.id_transf_det = tldet.id_transf_det and TUSR.parametro = tlparam.parametro " &
                                              "left outer join transf_log_param_file tfile on tfile.id_transf_log_det = tlparam.id_transf_log_det  and tfile.parametro = tlparam.parametro " &
                                              "where not(tlparam.parametro is null) and tldet.id_transf_log = " & Me.id_transf_log & " and tldet.id_transf_log_det = (select MAX(id_transf_log_det) from transf_log_det where  id_transf_log = tldet.id_transf_log)")

                        Me.transf_det_pendiente.param = New Dictionary(Of String, trsParam)
                        Dim tParams As trsParam
                        Dim param As String
                        While Not rsValores.EOF
                            tParams = New trsParam
                            param = nvUtiles.isNUll(rsValores.Fields("parametro").Value, Nothing)
                            tParams("tipo_dato") = nvUtiles.isNUll(rsValores.Fields("tipo_dato").Value, Nothing)
                            tParams("tipo") = nvUtiles.isNUll(rsValores.Fields("tipo").Value, Nothing)
                            tParams("valor") = nvConvertUtiles.StringToObject(nvUtiles.isNUll(rsValores.Fields("valor").Value), tParams("tipo_dato"), True, "es-AR") ' nvUtiles.isNUll(rsValores.Fields("valor").Value, Nothing)
                            tParams("label") = nvUtiles.isNUll(rsValores.Fields("label").Value, Nothing)
                            tParams("link") = ""
                            If nvUtiles.isNUll(rsValores.Fields("tipo_dato").Value, "").ToString.ToLower = "file" And Not IsDBNull(rsValores.Fields("bfile").Value) Then

                                Dim filename As String = nvUtiles.isNUll(rsValores.Fields("valor").Value, "")
                                'Dim path As String = nvTransferencia.nvTransfUtiles.getFileTmpPath(filename)

                                If filename <> "" Then

                                    Dim target_path As String = ""
                                    Dim target_basic As String = ""

                                    target_path = "FILE://(temp)/" & filename
                                    Dim arDestinosTMP As List(Of Dictionary(Of String, String)) = nvReportUtiles.target_parse(target_path)
                                    target_path = arDestinosTMP(0)("path")
                                    target_basic = arDestinosTMP(0)("target_basic")

                                    If System.IO.File.Exists(target_path) Then
                                        System.IO.File.Delete(target_path)
                                    End If

                                    Dim fs As New System.IO.FileStream(target_path, IO.FileMode.Create)
                                    Dim bytes() As Byte = rsValores.Fields("bfile").Value
                                    fs.Write(bytes, 0, bytes.Length)
                                    fs.Close()

                                    Dim href As String = ""
                                    Dim link As String = ""
                                    If (nvUtiles.isNUll(rsValores.Fields("descargable").Value, False)) = True Then
                                        href = "href= '/fw/files/file_get.aspx?path=" & Replace(target_basic, "\", "\\") & "'"
                                        link = "&nbsp;&nbsp;&nbsp;<a style='width:2%;cursor:hand;cursor:pointer' title='" & filename & "'  target='_blank' " & href & " ><img align='bottom' src='/FW/image/icons/buscar.png' title='" & filename & "' border='0'></img></a>&nbsp;"
                                        tParams("link") = link
                                    End If

                                End If

                            End If

                            'If (rsValores.Fields("tipo_dato").Value.TOLOWER() = "file" And rsValores.Fields("descargable").Value And IsDBNull(rsValores.Fields("bfile").Value)) Then
                            '    '         var arDestinos = target_parse("FILE://" + rsValores.fields("valor").value)
                            '    '           href = "href= '/fw/scripts/pvGetFilePath.asp?path=" + arDestinos[0].path + "'"
                            '    '		 link = "&nbsp;&nbsp;&nbsp;<a style='width:2%;cursor:hand;cursor:pointer' title='" + arDestinos[0].filename + "'  target='_blank' "+ href +" ><img align='bottom' src='/FW/image/icons/buscar.png' title='" + arDestinos[0].filename  + "' border='0'></img></a>&nbsp;"
                            '    '         Transf.transf_det_pendiente.param[rsValores.fields("parametro").value].link = link
                            'End If
                            Me.transf_det_pendiente.param(param) = tParams
                            rsValores.MoveNext()
                        End While
                        nvDBUtiles.DBCloseRecordset(rsValores)
                        '     //Escribir los archivo nuevamente en el filesystem
                        '     //Coloca el nombre del archivo en el parametro
                    End If
                    nvDBUtiles.DBCloseRecordset(rsTLog)
                End If

                '  //en el caso que la primer tarea sea de usuario tomo los valor de la tarea
                If Me.id_transf_log = 0 Then
                    '//Tomar el valor de las variables de la tarea de usuario
                    Dim rsValores As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(" select det.id_transf_det,parametro,usr.valor_defecto_editable as valor, label, tipo from Transferencia_Det det " &
                                             " inner join Transferencia_parametros_USR usr on usr.id_transf_det = det.id_transf_det " &
                                             " where id_transferencia = " & Me.id_transferencia & " and det.transf_tipo = 'IUS'")
                    Dim tParams As trsParam
                    Dim param As String
                    While Not rsValores.EOF
                        If Me.transf_det_pendiente Is Nothing Then
                            Me.transf_det_pendiente = New tTransfDet
                            Me.transf_det_pendiente.param = New Dictionary(Of String, trsParam)
                            Me.transf_det_pendiente.id_transf_det = rsValores.Fields("id_transf_det").Value
                            Me.id_transf_det = rsValores.Fields("id_transf_det").Value
                        End If

                        tParams = New trsParam
                        param = rsValores.Fields("parametro").Value
                        tParams("valor") = nvUtiles.isNUll(rsValores.Fields("valor").Value, Nothing)
                        tParams("label") = rsValores.Fields("label").Value
                        tParams("tipo") = rsValores.Fields("tipo").Value
                        tParams("link") = ""

                        If (Not objXML.SelectSingleNode("parametros/" & rsValores.Fields("parametro").Value) Is Nothing) Then
                            tParams("valor") = objXML.SelectSingleNode("parametros/" & rsValores.Fields("parametro").Value).InnerText
                        End If
                        Me.transf_det_pendiente.param(param) = tParams
                        rsValores.MoveNext()
                    End While

                    nvDBUtiles.DBCloseRecordset(rsValores)
                End If


                '***********************************************************
                ' /*********************************************************/
                ' /*********************************************************/
                ' //              Cargar parametros              
                ' /*********************************************************/
                ' /*********************************************************/
                'objError.mensaje = "Existen parámetros que no tienen valor y son requeridos: " & vbCrLf
                'Dim parametros_editables_seteados As Boolean = False
                'Dim rsParam = nvDBUtiles.DBExecute("Select * from transferencia_parametros where id_transferencia = " & Transf.id_transferencia & " order by orden")
                Dim valor_defecto As String
                For Each Item In Me.param
                    parametro = Item.Key
                    tParam = Item.Value

                    If Not Me.transf_det_pendiente Is Nothing Then
                        If Me.transf_det_pendiente.param.ContainsKey(parametro) = True Then

                            If nvUtiles.isNUll(Me.transf_det_pendiente.param(parametro)("tipo"), "") = "visible" Then
                                tParam("visible") = True
                                tParam("requerido") = False
                                tParam("editable") = False
                            End If

                            If nvUtiles.isNUll(Me.transf_det_pendiente.param(parametro)("tipo"), "") = "requerido" Then
                                tParam("requerido") = True
                                tParam("editable") = True
                                tParam("visible") = True
                            End If

                            If nvUtiles.isNUll(Me.transf_det_pendiente.param(parametro)("tipo"), "") = "editable" Then
                                tParam("editable") = True
                                tParam("requerido") = False
                                tParam("visible") = True
                            End If

                            If nvUtiles.isNUll(Me.transf_det_pendiente.param(parametro)("label"), "") <> "" Then tParam("etiqueta") = Me.transf_det_pendiente.param(parametro)("label")
                        End If
                    End If

                    '   //SETEAR EL VALOR POR DEL PARAMETRO
                    '   //Si es de tipo file colocar el nombre del archivo subido
                    '   //Sino controlar que venga el valor del parametro en el XML
                    '   //Sino cargar el valor por defecto
                    If tParam("tipo_dato") = "file" Then

                        'tParam("valor") = ""
                        tParam("valor") = Nothing
                        If Me.Archivos.Keys.Contains(parametro) Then
                            tParam("valor") = Me.Archivos(parametro)("filename")
                        End If


                        '/*************************************************************/
                        '//Controlar que el tamaño del archivo y el filtro de nombre
                        If Not tParam("valor") Is Nothing Then
                            '/***********************************************************************/
                            '// Reemplazar "*" por ".*" , luego "?" por ".?" y el "." por "\."     

                            If tParam("file_filtro") <> "" Then
                                Dim streg As String = tParam("file_filtro")
                                Dim reg = New System.Text.RegularExpressions.Regex("\.")
                                streg = reg.Replace(streg, "\.")
                                reg = New System.Text.RegularExpressions.Regex("\*")
                                streg = reg.Replace(streg, ".*")
                                reg = New System.Text.RegularExpressions.Regex("\?")
                                streg = reg.Replace(streg, ".?")
                                reg = New System.Text.RegularExpressions.Regex(streg, RegexOptions.IgnoreCase)
                                Dim match As Boolean = reg.IsMatch(tParam("valor"))
                                If Not match Then
                                    tParam("file_error") = 12008 '//'El nombre del archivo seleccionado es incorrecto.\n'
                                    objError.numError = 12008 '     objError.cargar_msj_error(12010)
                                    objError.titulo = "Error en los parámetros"
                                    objError.mensaje = "El nombre del archivo seleccionado es incorrecto"
                                    Me.error_limpiar_archivos()
                                    Return objError
                                End If
                            End If
                            'Controlar tamaño
                            If Me.Archivos(parametro)("size") > tParam("file_max_size") * 1024 * 1024 And tParam("file_max_size") > 0 Then
                                tParam("file_error") = 12009 '// 'El tamaño del archivo supera al máximo permitido.\n'
                                objError.numError = 12008
                                objError.titulo = "Error en los parámetros"
                                objError.mensaje = "El tamaño del archivo supera al máximo permitido."
                                Me.error_limpiar_archivos()
                                Return objError
                            End If


                        End If
                    Else
                        '1) Viene valor en los parámetros de la llamada
                        '2) Sino toma el valor por defecto o el valor de la ejecución pendiente
                        If Not objXML.SelectSingleNode("parametros/" & parametro) Is Nothing Then

                            tParam("valor") = nvConvertUtiles.StringToObject(objXML.SelectSingleNode("parametros/" & parametro).InnerText, tParam("tipo_dato"), True, "es-AR")

                            If objXML.SelectSingleNode("parametros/" & parametro).InnerText <> "" And tParam("valor") Is Nothing Then
                                objError.numError = 12010
                                objError.titulo = "Error al setar parámetro"
                                objError.mensaje = "El parámetro " & parametro & ". Verifique su tipo de dato."
                                Me.error_limpiar_archivos()
                                Return objError

                            End If

                        Else
                            '//Si es una ejecucion pendiente entonces colocar el valor a la ultima ejecución
                            Try
                                If Not Me.transf_det_pendiente Is Nothing AndAlso Not Me.transf_det_pendiente.param(parametro)("valor") Is Nothing Then
                                    tParam("valor") = Me.transf_det_pendiente.param(parametro)("valor")
                                End If
                                If tParam("requerido") Then
                                    Me.tiene_requeridos_pendientes = True
                                End If
                            Catch ex As Exception

                            End Try
                        End If
                    End If

                    '/********************************************************************/
                    '//  Controlar las variables de requerido que no son editables
                    '//  devolver el error
                    '/********************************************************************/

                    '/*Si tiene un parametro que no tiene valor y es requerido solicitarlo*/
                    If tParam("valor") Is Nothing And tParam("requerido") Then
                        Me.tiene_requeridos_pendientes = True
                        Me.tiene_requeridos_pendientes_msg += tParam("parametro") & "," & vbCrLf
                    End If

                    ' /*Si es la primera pasada siempre pide los editables salvo que le pasen un valor*/      
                    If tParam("valor") Is Nothing And tParam("editable") Then 'And pasada = 0 And Not async And Transf.salida_tipo <> nvenumSalidaTipo.estado
                        tiene_editables = True
                    End If

                Next

                If tiene_requeridos_pendientes_msg.Substring(tiene_requeridos_pendientes_msg.Length - 3) = ("," & vbCrLf) Then
                    Me.tiene_requeridos_pendientes_msg = " " & tiene_requeridos_pendientes_msg.Substring(0, tiene_requeridos_pendientes_msg.Length - 3) & " " & vbCrLf
                    '  objError.numError = 12009
                    '  objError.titulo = "Error en los parámetros"
                    '  objError.mensaje = Me.tiene_requeridos_pendientes_msg
                    ' Me.error_limpiar_archivos()
                    'Return objError
                End If

                'Tareas opcionales
                'objError.mensaje += "Tareas opcionales no vienen el valor del opcional y están habilitadas: " & vbCrLf

                'Dim rsTareas As ADODB.Recordset = nvDBUtiles.DBExecute("Select * ,dbo.[transf_det_tiene_permiso](id_transf_det) as tiene_permiso from transferencia_det where id_transferencia = " & id_transferencia)
                Me.tiene_opcionales = False
                For Each det In Me.dets.Values

                    If Not nvXMLUtiles.getAttribute_path(objXML_det_opcional, "det_opcional/det[@id_transf_det = '" & det.id_transf_det & "']/@check", Nothing) Is Nothing Then
                        det.opcional_value = nvXMLUtiles.getAttribute_path(objXML_det_opcional, "det_opcional/det[@id_transf_det = '" & det.id_transf_det & "']/@check", "false").ToLower = "true"
                    End If
                    ' If det.opcional Then Me.tiene_opcionales = True

                    'Si es opcional, no viene el valor del opcional y está habilitada
                    If det.opcional = True And nvXMLUtiles.getAttribute_path(objXML_det_opcional, "det_opcional/det[@id_transf_det = '" & det.id_transf_det & "']/@check", Nothing) Is Nothing And det.habilitado Then
                        Me.tiene_opcionales = True
                        Me.tiene_opcionales_msg += det.transf_det & " - " & det.transf_tipo & vbCrLf
                        det.opcional_value = True
                    End If
                Next

                If Me.tiene_opcionales_msg.Substring(Me.tiene_opcionales_msg.Length - 3) = ("," & vbCrLf) Then
                    Me.tiene_opcionales_msg = Me.tiene_opcionales_msg.Substring(0, Me.tiene_opcionales_msg.Length - 3) & " " & vbCrLf
                End If



            Catch ex1 As Exception
                objError.parse_error_script(ex1)
                objError.titulo = "Error al cargar la transferencia"
                nvDBUtiles.DBCloseRecordset(rsTareas)
                nvDBUtiles.DBCloseRecordset(rsRel)
                nvDBUtiles.DBCloseRecordset(rsTransf)
                nvDBUtiles.DBCloseRecordset(rsParam)
                Return objError
            End Try

            Return objError
        End Function

        Public Function new_id_transf_log() As Integer

            Dim id_transf_log As Integer
            Dim rsTransf_log As ADODB.Recordset = nvDBUtiles.DBExecute("exec transf_log_add " & Me.id_transferencia)
            id_transf_log = rsTransf_log.Fields("id_transf_log").Value
            nvDBUtiles.DBCloseRecordset(rsTransf_log)
            Return id_transf_log

        End Function

        Public Function ejecutar() As tError
            'Me.log_param_save = enum_log_param_save.inicio_y_fin
            Dim cola_ejecucion As New Queue(Of tCola_det)
            Dim det As tTransfDet

            Dim ts_all As New System.Diagnostics.Stopwatch
            ts_all.Start()

            'Transf.id_transf_log = obtenerValor("id_transf_log", "")
            If Me.id_transf_log = 0 Then
                Dim rsTransf_log As ADODB.Recordset = nvDBUtiles.DBExecute("exec transf_log_add " & Me.id_transferencia)
                Me.id_transf_log = rsTransf_log.Fields("id_transf_log").Value
                nvDBUtiles.DBCloseRecordset(rsTransf_log)
            Else
                nvDBUtiles.DBExecute("UPDATE transf_log_cab set estado = 'ejecutando' where id_transf_log = " & Me.id_transf_log)
            End If
            Me.transf_error.params("id_transf_log") = Me.id_transf_log
            Me.estado = nvenumTransfEstado.iniciado ' "iniciado"
            Try
                '*********************************
                ' Cargar tareas a ejecutar
                '*********************************
                If Not Me.transf_det_pendiente Is Nothing Then
                    ' //Cargamos la tarea que esta pendiente
                    Me.dets(Me.transf_det_pendiente.id_transf_det).estado = nvenumTransfEstado.Pendiente
                    cola_ejecucion.Enqueue(New tCola_det With {.det = Me.dets(Me.transf_det_pendiente.id_transf_det).clone(), .ant = Nothing})
                    nvDBUtiles.DBExecute("UPDATE transf_log_det set estado_det = 'pendiente_ejecutado' where id_transf_log_det = " & Me.transf_det_pendiente.id_transf_log_det)
                Else
                    '//cargamos la pila de ejecucion
                    For Each id_transf_det In Me.dets.Keys
                        If Me.dets(id_transf_det).ants.Count = 0 Then
                            cola_ejecucion.Enqueue(New tCola_det With {.det = Me.dets(id_transf_det).clone, .ant = Nothing})
                        End If
                    Next
                End If


            Catch ex As Exception

                Me.transf_error.parse_error_script(ex)
                Me.transf_error.titulo = "Error al ejecutar la transferencia"
                Me.transf_error.mensaje = ""
                'nvDBUtiles.DBDesconectar(cnTran)
                Me.estado = nvenumTransfEstado.error ' "error"
                nvDBUtiles.DBExecute("Update transf_log_cab set fe_fin = getdate(), estado = '" & Me.estado.ToString() + "' where id_transf_log = " & Me.id_transf_log)
                Return Me.transf_error
            End Try


            '***************************************************************************************************/
            '/   While recorre cada uno de los registro de ejecución de la transferencia
            '***************************************************************************************************/
            'Dim resumen As String = ""
            'Me.estado = nvenumTransfEstado.finalizado '= "finalizado"

            Me.transf_error.titulo = "Ejecución transferencia Nro " & Me.id_transferencia

            'Guardar los parametros de entrada
            Dim strSQLDet As String
            Dim primer_det As Boolean = True

            Dim detError As tError
            While cola_ejecucion.Count > 0
                '//tomar el primer elemento de la cola
                Dim el As tCola_det = cola_ejecucion.Dequeue
                det = el.det

                '*******************************************************
                'Ejecutar la tarea
                '*******************************************************
                If det.transf_estado = "A" Then 'Si está activo
                    detError = det.ejecutar(el)
                    Me.dets_run.Add(el)

                    If primer_det = True And Me.log_param_save = enum_log_param_save.inicio_y_fin Then
                        primer_det = False
                        strSQLDet = nvTransfUtiles.GetStrSQLLogInsertParams(el.det)
                        nvDBUtiles.DBExecute(strSQLDet)
                    End If

                End If

                ' /************************************************************/      
                ' //Poner en cola las tareas pendientes
                ' /************************************************************/
                Try
                    Dim s As Integer
                    Dim eval_res As Boolean
                    Dim strEval As String
                    If el.continuar = True Then
                        For Each s In det.sigs.Keys
                            ' //Evaluar cada tarea
                            If det.sigs(s)("disabled") Then Continue For
                            eval_res = False
                            strEval = "function res(){" & Me.paramSCRIPT() & "; return " & det.sigs(s)("evaluacion") & " } res()"
                            Try
                                eval_res = nvConvertUtiles.JSScriptToObject(strEval) 'eval(strEval) ? 1 : 0
                            Catch ex As Exception

                            End Try
                            'el.eval_res = eval_res
                            '//Si verdadero encolarla y agregarl el token
                            If eval_res Or {"AND", "OR", "XOR"}.Contains(det.sigs(s)("det").transf_tipo) Then
                                cola_ejecucion.Enqueue(New tCola_det With {.det = det.sigs(s)("det").clone(), .ant = det, .eval_res = eval_res})
                            End If
                        Next
                    End If
                    For Each cola_det In el.sigs
                        cola_ejecucion.Enqueue(cola_det)
                    Next
                Catch ex As Exception
                End Try

            End While ' //cierra el while

            If Me.dets_run.Count > 0 And (Me.log_param_save = enum_log_param_save.inicio_y_fin Or Me.log_param_save = enum_log_param_save.solo_fin) Then
                strSQLDet = nvTransfUtiles.GetStrSQLLogInsertParams(dets_run.Last.det)
                nvDBUtiles.DBExecute(strSQLDet)
            End If


            Dim fs As System.IO.FileStream
            Dim bytes() As Byte
            Dim Cmd As ADODB.Command
            Dim count_pendientes As Integer = Me.dets_run.FindAll(Function(c As tCola_det)
                                                                      Return c.det.estado = nvenumTransfEstado.Pendiente
                                                                  End Function).Count
            'Dim rsEstado As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("Select count(*) as cp from transf_log_det where id_transf_log = " & Me.id_transf_log & " and estado_det = 'Pendiente'")
            If count_pendientes > 0 Then
                'If rsEstado.Fields("cp").Value > 0 Then
                Me.estado = nvenumTransfEstado.Pendiente '= "Pendiente"
                Dim rsEstado_det As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("Select id_transf_log_det from transf_log_det where id_transf_log = " & Me.id_transf_log & " and estado_det = 'Pendiente'")
                While Not rsEstado_det.EOF
                    For Each campo In Me.Archivos.Keys
                        Try
                            If Me.Archivos(campo)("filename") <> "" Then
                                fs = New System.IO.FileStream(Me.Archivos(campo)("path"), IO.FileMode.Open)
                                ReDim bytes(fs.Length - 1)
                                fs.Read(bytes, 0, fs.Length)
                                fs.Close()

                                Cmd = New ADODB.Command
                                Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar
                                Cmd.CommandType = 4
                                Cmd.CommandTimeout = 1500
                                Cmd.CommandText = "dbo.transf_log_param_file_add"

                                Dim param As ADODB.Parameter = Cmd.CreateParameter("Return", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamReturnValue)
                                Dim param1 As ADODB.Parameter = Cmd.CreateParameter("id_transf_log_det", ADODB.DataTypeEnum.adInteger, 1, 0, rsEstado_det.Fields("id_transf_log_det").Value.ToString)
                                Dim param2 As ADODB.Parameter = Cmd.CreateParameter("parametro", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, campo.ToString.Length, campo.ToString)
                                Dim param3 As ADODB.Parameter = Cmd.CreateParameter("filename", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, Me.Archivos(campo)("filename").ToString.Length, Me.Archivos(campo)("filename").ToString)
                                Dim param4 As ADODB.Parameter = Cmd.CreateParameter("bfile", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, bytes.Length, bytes)

                                Cmd.Parameters.Append(param)
                                Cmd.Parameters.Append(param1)
                                Cmd.Parameters.Append(param2)
                                Cmd.Parameters.Append(param3)
                                Cmd.Parameters.Append(param4)

                                Cmd.Execute()

                                'Dim rsValores As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select filename,isnull(bfile,0) as bfile from transf_log_param_file where id_transf_log_det  = " & rsEstado_det.Fields("id_transf_log_det").Value.ToString)

                                'Dim target_path = "FILE://(temp)/" & rsValores.Fields("filename").Value
                                'Dim arDestinosTMP As List(Of Dictionary(Of String, String)) = nvReportUtiles.target_parse(target_path)
                                'target_path = arDestinosTMP(0)("path")
                                'Dim target_basic = arDestinosTMP(0)("target_basic")

                                'If System.IO.File.Exists(target_path) Then
                                '    System.IO.File.Delete(target_path)
                                'End If

                                'Dim fs1 As New System.IO.FileStream(target_path, IO.FileMode.Create)
                                'Dim bytes1() As Byte = rsValores.Fields("bfile").Value
                                'fs1.Write(bytes1, 0, bytes1.Length)
                                'fs1.Close()


                                If param.Value = 0 Then ' 0 = no se pudo guardar el archivo, 1 = ok
                                    Throw New Exception("Error al ejecutar la transferencia")
                                End If

                            End If
                        Catch ex As Exception
                            Me.transf_error.parse_error_script(ex)
                            Me.transf_error.titulo = "Error al ejecutar la transferencia"
                            Me.transf_error.mensaje = ""
                            Me.estado = nvenumTransfEstado.error ' "error"
                            nvDBUtiles.DBExecute("Update transf_log_cab set fe_fin = getdate(), estado = '" & Me.estado.ToString() + "' where id_transf_log = " & Me.id_transf_log)
                            Return Me.transf_error
                        End Try
                    Next
                    rsEstado_det.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsEstado_det)
            End If
            'nvDBUtiles.DBCloseRecordset(rsEstado)

            ts_all.Stop()
            Dim ms As Long = ts_all.ElapsedMilliseconds()
            Me.transf_error.params("time_all_ms") = ms

            If Me.estado <> nvenumTransfEstado.error And Me.estado <> nvenumTransfEstado.Pendiente Then
                Me.estado = nvenumTransfEstado.finalizado
            End If

            Dim Error_xml As String = Me.getError_xml
            ' Dim strSQL As String = "Update transf_log_cab set fe_fin = getdate(), estado = '" & Me.estado.ToString() & "', resumen = " & nvConvertUtiles.objectToSQLScript(resumen) & ", obs = " & nvConvertUtiles.objectToSQLScript(Error_xml) & ", obsbin = cast(" & nvConvertUtiles.objectToSQLScript(Error_xml) & " as varbinary(max)) where id_transf_log = " & Me.id_transf_log
            Dim strSQL As String = "Update transf_log_cab set fe_fin = getdate(), estado = '" & Me.estado.ToString() & "', obsbin = cast(" & nvConvertUtiles.objectToSQLScript(Error_xml) & " as varbinary(max)) where id_transf_log = " & Me.id_transf_log
            nvDBUtiles.DBExecute(strSQL)


            'Cerrar todas las conexiones utilizadas
            For Each key In ActiveConnections.Keys
                Try
                    ActiveConnections(key).Close()
                Catch ex As Exception

                End Try
            Next
            ActiveConnections.Clear()



            'Me.error_limpiar_archivos()

            Return Me.transf_error
        End Function

        Public Function getErrorResumen_xml(Optional ByVal include_file As Boolean = False, Optional ByVal include_file_format As String = "xml") As tError

            Dim errRes As New tError()
            Dim mXML As New System.Xml.XmlDocument
            Try
                errRes.params("id_tranf_log") = Me.id_transf_log
                errRes.params("time_all_ms") = Me.transf_error.params("time_all_ms")
                Dim error_count As Integer = 0

                Dim settings As New System.Xml.XmlWriterSettings()
                settings.Indent = False
                settings.NewLineOnAttributes = True
                settings.OmitXmlDeclaration = False
                settings.Encoding = nvConvertUtiles.currentEncoding

                Dim ms As New System.IO.MemoryStream
                Dim xmlw As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(ms, settings)
                xmlw.WriteStartDocument()
                xmlw.WriteStartElement("targets")
                For Each cola_det In Me.dets_run

                    Dim det As tTransfDet = cola_det.det
                    If det.det_error.numError <> 0 Then error_count += 1
                    If det.link_browser <> "" Then
                        xmlw.WriteStartElement("target")
                        xmlw.WriteAttributeString("transf_det", det.transf_det)
                        xmlw.WriteAttributeString("url", det.link_browser)
                        If include_file Then

                            Dim destinos As List(Of Dictionary(Of String, String)) = nvReportUtiles.target_parse(det.link_browser)
                            Dim path_destino As String = destinos(0)("path")
                            Dim extension As String = System.IO.Path.GetExtension(det.link_browser)

                            Dim BinaryData() As Byte
                            If System.IO.File.Exists(path_destino) Then

                                BinaryData = System.IO.File.ReadAllBytes(path_destino)

                                If extension.ToLower.IndexOf(".xml") > -1 And include_file_format.ToLower = "xml" Then
                                    Dim value As String = nvUtiles.isNUllorEmpty(nvConvertUtiles.currentEncoding.GetString(BinaryData), "")
                                    Try
                                        If (value.ToString().IndexOf("<?xml") = -1) Then
                                            mXML.LoadXml("<?xml version='1.0' encoding='iso-8859-1'?>" & value)
                                        Else
                                            mXML.LoadXml(value)
                                        End If
                                        xmlw.WriteRaw(value)
                                    Catch exe1 As System.Xml.XmlException
                                        xmlw.WriteRaw("")
                                    End Try
                                Else
                                    xmlw.WriteBase64(BinaryData, 0, BinaryData.Length)
                                End If
                            End If

                        End If
                        xmlw.WriteEndElement()

                    End If
                Next
                xmlw.WriteEndElement()

                If xmlw.WriteState > 1 Then
                    xmlw.WriteEndDocument()
                End If

                xmlw.Close()

                ms.Position = 0
                Dim bytes(ms.Length - 1) As Byte
                ms.Read(bytes, 0, ms.Length)
                ms.Close()

                errRes.params("error_count") = error_count

                Dim strXMLTarget As String = nvConvertUtiles.currentEncoding.GetString(bytes)
                strXMLTarget = strXMLTarget.Replace("<?xml version=""1.0"" encoding=""iso-8859-1""?>", "")
                mXML.LoadXml(strXMLTarget)
                errRes.params("targets") = mXML

                'Agregar parámetros de salida (no internos)
                For Each item In Me.param
                    If Not item.Value("interno") Then errRes.params(item.Key) = item.Value("valor")
                Next

            Catch ex As Exception
                errRes.parse_error_script(ex)
            End Try

            Return errRes

        End Function

        Public Function getError_xml() As String
            Dim strXML As String = Me.transf_error.get_error_xml()
            Dim oXML As New System.Xml.XmlDocument
            oXML.LoadXml(strXML)
            Dim node_params As System.Xml.XmlNode = oXML.SelectSingleNode("error_mensajes/error_mensaje/params")

            'Agregar error_mesajes de los dets
            'Dim node_det_error_mensajes = oXML.CreateElement("error_mensajes")
            'node_params.AppendChild(node_det_error_mensajes)
            Dim node_det_tareas_logs = oXML.CreateElement("tareas_logs")
            node_params.AppendChild(node_det_tareas_logs)
            'node_det_error_mensajes.AppendChild(node_det_tareas_logs)
            Dim nod_targets As System.Xml.XmlNode = oXML.CreateElement("targets")
            Dim error_count As Integer = 0
            For Each cola_det In Me.dets_run
                Dim det As tTransfDet = cola_det.det
                'det.det_error.params("")
                Dim strError_det As String = det.det_error.get_error_xml()
                Dim objError_det As New System.Xml.XmlDocument
                objError_det.LoadXml(strError_det)
                Dim node_origen As System.Xml.XmlNode = objError_det.SelectSingleNode("error_mensajes/error_mensaje")
                Dim node_clon As System.Xml.XmlNode = oXML.ImportNode(node_origen, True)
                node_det_tareas_logs.AppendChild(node_clon)
                If det.det_error.numError <> 0 Then error_count += 1
                If det.link_browser <> "" Then
                    Dim nod_t As System.Xml.XmlNode = oXML.CreateElement("target")
                    'id_transf_det="7617" id_transf_log_det="3841008"
                    Dim att1 As System.Xml.XmlAttribute = oXML.CreateAttribute("id_transf_det")
                    att1.Value = det.id_transf_det
                    nod_t.Attributes.Append(att1)
                    Dim att2 As System.Xml.XmlAttribute = oXML.CreateAttribute("id_transf_log_det")
                    att2.Value = det.id_transf_log_det
                    nod_t.Attributes.Append(att2)
                    nod_t.InnerText = det.link_browser
                    nod_targets.AppendChild(nod_t)
                End If
            Next
            Dim att As System.Xml.XmlAttribute = oXML.CreateAttribute("error_count")
            att.Value = error_count
            node_det_tareas_logs.Attributes.Append(att)

            'Agregar el return
            Dim node_return As System.Xml.XmlNode = oXML.CreateElement("return")
            node_params.AppendChild(node_return)

            'Agregar elements
            Dim node_elements As System.Xml.XmlNode = oXML.CreateElement("elements")
            node_return.AppendChild(node_elements)

            'Si hay targets sumarlos a la salida
            If nod_targets.ChildNodes.Count > 0 Then node_elements.AppendChild(nod_targets)

            'Agregar parámetros
            Dim node_p As System.Xml.XmlNode = oXML.CreateElement("params")
            node_elements.AppendChild(node_p)

            For Each item In Me.param
                Dim node_p1 As System.Xml.XmlNode = oXML.CreateElement(item.Key)
                'Dim node_cda As System.Xml.XmlNode = oXML.CreateCDataSection(item.Value("valor"))
                'Dim node_cda As System.Xml.XmlNode = oXML.CreateCDataSection(String.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"), "{0}", item.Value("valor")))
                Dim node_cda As System.Xml.XmlNode
                Try
                    node_cda = oXML.CreateCDataSection(String.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"), "{0}", item.Value("valor")))
                Catch ex As Exception
                    node_cda.InnerText = item.Value("valor")
                End Try

                node_p1.AppendChild(node_cda)
                node_p.AppendChild(node_p1)
            Next


            Return oXML.OuterXml()
        End Function

        Public Sub error_limpiar_archivos()
            'Dim archivo As Dictionary(Of String, Object)
            'Dim folderPath, folderError, pathError As String
            'For Each campo In archivos.Keys
            '    archivo = archivos(campo)
            '    If archivo("filename") <> "" Then
            '        pathError = nvTransfUtiles.getFileErrorPath(archivo("filename"))
            '        nvFW.nvReportUtiles.create_folder(pathError)
            '        folderPath = System.IO.Path.GetDirectoryName(archivo("path"))
            '        folderError = System.IO.Path.GetDirectoryName(pathError)
            '        System.IO.File.Move(archivo("path"), pathError)
            '    End If
            'Next
            'If folderPath = "" Then folderPath = nvTransfUtiles.getFileTmpPath("")
            'If System.IO.Directory.Exists(folderPath) Then System.IO.Directory.Delete(folderPath)
            Dim folderPath, pathError, filename As String
            folderPath = nvTransfUtiles.getFileTmpPath("", serial:=Me.serial)
            Dim _archivos() As String
            If System.IO.Directory.Exists(folderPath) Then
                'Dim dir As System.IO.Directory = System.IO.Directory.GetFiles()
                _archivos = System.IO.Directory.GetFiles(folderPath, "*.*")
                For i = LBound(_archivos) To UBound(_archivos)
                    filename = System.IO.Path.GetFileName(_archivos(i))
                    pathError = nvTransfUtiles.getFileErrorPath(filename)
                    nvFW.nvReportUtiles.create_folder(pathError)
                    System.IO.File.Copy(_archivos(i), pathError, True)
                    Try
                        System.IO.File.Delete(_archivos(i))
                    Catch ex As Exception
                    End Try
                Next
                Try
                    System.IO.Directory.Delete(folderPath)
                Catch ex As Exception
                End Try

            End If
        End Sub
        Public Function paramSCRIPT() As String


            Dim res As String = ""
            Dim parametro As trsParam
            'Dim valor As Object
            Dim param As String
            For Each param In Me.param.Keys
                parametro = Me.param(param)
                res += "var " & param & " = " & nvConvertUtiles.objectToScript(parametro("valor")) & vbCrLf
                'If parametro("valor") Is Nothing Then
                '    res += "var " & param & " = null" & vbCrLf
                'Else

                '                             If (parametro['tipo_dato'].toUpperCase() == 'DATETIME')
                '                               {
                '                               //valor = New Date(Date.parse((parametro['valor'] + '')))
                '                               //parametro['valor'] = FechaToSTR(valor)
                '                               res += 'var ' + parametro['parametro'] + ' = ' + SCRIPT_set_valor(parametro['tipo_dato'], parametro['valor']) + '\n'
                '                               }
                '                             Else
                '                               {
                '                               res += 'var ' + parametro['parametro'] + ' = ' + SCRIPT_set_valor(parametro['tipo_dato'], parametro['valor']) + '\n'
                '                               // Si tiene un campo def setear el valor
                '                               }  
                '                             //if (parametro['campo_def']!= '')
                '                             //    res += '$("' + parametro['parametro'] + '").value = ' + SCRIPT_set_valor(parametro['tipo_dato'], parametro['valor']) + '\n'  
                '                             }  
                'End If

            Next

            Dim strtransf As String = ""
            strtransf += "if(!Transf)" & vbCrLf
            strtransf += " var Transf = {}" & vbCrLf
            strtransf += "if(!Transf.lastdet)" & vbCrLf
            strtransf += " Transf.lastdet = {}" & vbCrLf
            strtransf += "if(!Transf.lastdet.det_error)" & vbCrLf
            strtransf += " Transf.lastdet.det_error = {}" & vbCrLf
            strtransf += "Transf.lastdet.det_error.numError = " & If(dets_run.count > 0, dets_run.Last.det.det_error.numError.ToString, "0") & "" & vbCrLf

            Return strtransf & res

        End Function

        Public Sub getScript_SP_ejecutar(ByRef scriptSQL As String, ByRef paramTSQL As String, ByVal paramTSQL_ret As String, ByVal scriptBlock As String, ByVal cn_tipo As String, ByVal id_transf_log_det As Integer)
            Select Case cn_tipo.ToLower()
                Case "oracle"
                    paramTSQL = Me.paramTPLSQL()
                    scriptBlock = Replace(scriptBlock, vbLf, vbCrLf)
                Case Else
                    paramTSQL = Me.paramTSQL()
            End Select

            scriptSQL = nvTransfUtiles.getScriptBase_SP_ejecutar(paramTSQL, cn_tipo)

            scriptSQL = scriptSQL.Replace("--{tran_name}", "transf_det_" & id_transf_log_det)
            scriptSQL = scriptSQL.Replace("--{code}", scriptBlock)
            If paramTSQL_ret <> "" Then scriptSQL = scriptSQL.Replace("--{paramTSQL_ret}", paramTSQL_ret)
        End Sub


        Public Function paramTSQL() As String
            Dim res As String = "--Parametros de transferencia" & vbCrLf
            Dim parametro As trsParam
            Dim param As String
            For Each param In Me.param.Keys
                parametro = Me.param(param)
                res += "DECLARE @" & param & " " & nvConvertUtiles.ParamTypeToSQLType(parametro("tipo_dato")) & vbCrLf
            Next
            res += "--Parametros internos" & vbCrLf
            res += "DECLARE @_transf_id_transf_log int" & vbCrLf
            res += "DECLARE @_transf_id_transferencia int" & vbCrLf


            res += "--Valores para parametros de transferencia" & vbCrLf
            For Each param In Me.param.Keys
                parametro = Me.param(param)
                res += "SET @" & param & " = " & nvConvertUtiles.objectToSQLScript(parametro("valor")) & vbCrLf
            Next
            res += "--Valores para parametros internos" & vbCrLf
            res += "SET @_transf_id_transf_log = " & Me.id_transf_log & vbCrLf
            res += "SET @_transf_id_transferencia = " & Me.id_transferencia & vbCrLf

            res += vbCrLf
            '//seteo variable global
            'If Me.id_transf_log <> 0 Then
            '    res += "SET @" & Me.id_transf_log ']['parametro'] + ' = ' + TSQL_set_valor(this.param['_transf_id_transf_log']['tipo_dato'], this.id_transf_log ) + '\n'
            'End If

            Return res
        End Function

        Public Function paramTPLSQL() As String
            Dim res As String = "--Parametros de transferencia" & vbCrLf
            res += "create or replace procedure tmp_transf_sp_" & Me.id_transf_log & "(c1 out SYS_REFCURSOR) is" & vbCrLf
            Dim parametro As trsParam
            Dim param As String
            For Each param In Me.param.Keys
                parametro = Me.param(param)
                res += "v_" & param & " " & nvConvertUtiles.ParamTypeToPLSQLType(parametro("tipo_dato")) & ";" & vbCrLf
            Next
            res += "--Parametros internos" & vbCrLf
            res += "v_transf_id_transf_log NUMBER;" & vbCrLf
            res += "v_transf_id_transferencia NUMBER;" & vbCrLf
            'res += "c1 SYS_REFCURSOR;" & vbCrLf


            res += "--Valores para parametros de transferencia" & vbCrLf
            res &= "BEGIN" & vbCrLf
            For Each param In Me.param.Keys
                parametro = Me.param(param)
                res += "v_" & param & " := " & nvConvertUtiles.objectToSQLScript(parametro("valor")) & ";" & vbCrLf
            Next
            res += "--Valores para parametros internos" & vbCrLf
            res += "v_transf_id_transf_log := " & Me.id_transf_log & ";" & vbCrLf
            res += "v_transf_id_transferencia := " & Me.id_transferencia & ";" & vbCrLf

            res += vbCrLf

            Return res
        End Function

        Public Function paramTSQL_ret(Optional cn_tipo As String = "") As String
            Dim res As String = ""
            Dim pre_var As String = ""
            Dim pos_select As String = ""
            Dim pre_column_scape As String = ""
            Dim pos_column_scape As String = ""
            Select Case cn_tipo.ToLower()
                Case "oracle"
                    pre_var = "v_"
                    pos_select = " from dual;"
                    pre_column_scape = """"
                    pos_column_scape = """"
                Case Else
                    pre_var = "@"
                    pre_column_scape = "["
                    pos_column_scape = "]"
            End Select


            Dim parametro As trsParam
            Dim param As String
            For Each param In Me.param.Keys
                parametro = Me.param(param)
                If res <> "" Then res += ", "
                res &= pre_var & param & " as " & pre_column_scape & param & pos_column_scape
            Next

            res &= pos_select

            Return res
            'Transf.paramTSQL_ret = Function()
            '                         {
            '                         var res = ""
            '                         var parametro
            '                         var valor
            '                         For (var param in this.param)
            '                           {
            '                           parametro = this.param[param]
            '                           If (res!= '')
            '                             res += ', '
            '                           res += '@' + param + ' as [' + param + ']'
            '                           }
            '                         Return res
            '                         }        

        End Function
        Public Enum nvenumTransfEstado
            [error] = -1
            no_iniciada = 0
            Pendiente = 1
            iniciado = 2
            finalizado = 10
            terminado = 20
            no_habilitado = 100
            habilitado = 101
            ejecucion_async = 30
        End Enum

        Public Function toJSON() As String
            'For Each t In Me.dets.Values
            '    t.Transf = Nothing
            '    t.sigs.Clear()
            '    t.ants.Clear()
            'Next

            Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer()
            serializer.MaxJsonLength = int32.maxvalue 'default 2097152

            Dim strScript As String = "var Transf = " & serializer.Serialize(Me)

            strScript += vbCrLf & "Transf.param = {"
            Dim param As String
            Dim primero As Boolean = True
            For Each param In Me.param.Keys
                If Not primero Then
                    strScript += ", "
                End If
                strScript += param & ":" & Me.param(param).toJSON()
                primero = False
            Next
            strScript += "}"

            Return strScript
        End Function



    End Class


    Public Enum enum_log_param_save
        todo = 1
        inicio_y_fin = 2
        solo_fin = 3
    End Enum


End Namespace
