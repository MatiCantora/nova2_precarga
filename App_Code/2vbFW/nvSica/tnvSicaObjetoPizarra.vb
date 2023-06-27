Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvSICA

        Public Class tnvSicaPizarra
            Implements InvSicaObjetoGrupo

            ' Conexion por defecto
            Public Shared cn_name As String = "default"


            Public Shared Function getRSXMLElements(nvApp As tnvApp, Optional filtro As String = "") As String
                ' filtro: si no está vacío, viene completo como "like '%valor_buscado%'" o "not like '%valor_a_excluir%'"
                If cn_name = String.Empty Then cn_name = "default"

                Dim nvcn As tDBConection = nvApp.app_cns(cn_name).clone()
                nvcn.excaslogin = False

                Dim strSQL As String = "SELECT calc_pizarra AS objeto, " &
                                            "'" & cn_name & "\' + calc_pizarra AS path, " &
                                            "'' AS comentario, " &
                                            "0 AS cod_sub_tipo " &
                                        "FROM calc_pizarra_cab " &
                                        "WHERE habilitada=1 " &
                                        If(filtro <> String.Empty, "AND calc_pizarra " & filtro, "")

                Dim rs As ADODB.Recordset

                Try
                    rs = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, _nvcn:=nvcn)
                Catch ex As Exception
                    Throw New Exception(ex.Message & "</br>Compruebe que la tabla (calc_pizarra_cab) de Pizarras existe en el sistema seleccionado.")
                End Try

                Dim arParam As New trsParam
                Dim oXMl As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rs, arParam)
                nvDBUtiles.DBCloseRecordset(rs)

                Return oXMl.OuterXml
            End Function



            Public Sub loadFromImplementation(objME As tSicaObjeto,
                                              nvApp As tnvApp,
                                              cod_objeto_tipo As tSicaObjeto.nvEnumObjeto_tipo,
                                              path As String,
                                              objeto As String,
                                              Optional ByVal cod_sub_tipo As Integer = 0,
                                              Optional chargeBinary As Boolean = False,
                                              Optional bytes() As Byte = Nothing) Implements InvSicaObjetoGrupo.loadFromImplementation
                Try
                    Dim cn As String = path.Split("\")(0)
                    Dim calc_pizarra As String = path.Split("\")(1) ' path=> nombre_conexion\nombre_objeto_pizarra

                    cn = If(cn = "", "default", cn)

                    Dim nvcn As tDBConection = nvApp.app_cns(cn).clone()
                    nvcn.excaslogin = False
                    Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)

                    Dim oSicaPizarraCab As New tSicaObjeto
                    objME.fecha_modificacion = Now()


                    '--- Agregar elemento de "calc_pizarra_cab" ---
                    Dim strSQL As String = "SELECT * FROM calc_pizarra_cab WHERE calc_pizarra='" & calc_pizarra & "' AND habilitada=1"
                    Dim rsCab As ADODB.Recordset = conn.Execute(strSQL)

                    If rsCab.EOF Then
                        nvDBUtiles.DBCloseRecordset(rsCab)
                        Exit Sub
                    End If

                    objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo)
                    Dim oPath As String = cn_name & "\calc_pizarra_cab" ' "default\operador_permiso_grupo"  => ' conexion\tabla
                    Dim oObjeto As String = rsCab.Fields("calc_pizarra").Value
                    Dim oCod_subtipo As Integer = 0
                    Dim oBytes() As Byte
                    Dim arParam As New trsParam
                    Dim primary_keys As New List(Of String)
                    primary_keys.Add("nro_calc_pizarra")
                    Dim nro_calc_pizarra As Integer = rsCab.Fields("nro_calc_pizarra").Value
                    Dim oXML As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rsCab, arParam, primary_keys:=primary_keys)
                    nvDBUtiles.DBCloseRecordset(rsCab, False)

                    Dim strXML As String = oXML.OuterXml
                    oBytes = nvConvertUtiles.StringToBytes(strXML)
                    oSicaPizarraCab.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                    objME.childObjects.Add(oSicaPizarraCab)


                    '--- Agregar elementos de "calc_pizarra_cab_def_valores" ---
                    strSQL = "SELECT * FROM calc_pizarra_cab_def_valores WHERE nro_calc_pizarra=" & nro_calc_pizarra & " ORDER BY orden"
                    Dim rsCabDef As ADODB.Recordset = conn.Execute(strSQL)

                    ' Este elemento es OPCIONAL, con lo que podría no haber datos => controlar
                    If Not rsCabDef.EOF Then
                        oPath = cn_name & "\calc_pizarra_cab_def_valores" ' "default\operador_permiso_detalle"
                        oObjeto = "Valores extra de Cabecera para " & oSicaPizarraCab.objeto
                        oCod_subtipo = 0
                        primary_keys = New List(Of String)
                        primary_keys.Add("id_nro_calc_pizarra")
                        primary_keys.Add("nro_calc_pizarra")
                        oXML = nvXMLSQL.RecordsetToXML(rsCabDef, arParam, primary_keys:=primary_keys)

                        strXML = oXML.OuterXml
                        oBytes = nvConvertUtiles.StringToBytes(strXML)
                        Dim oSicaPizarraCabDef As New tSicaObjeto
                        oSicaPizarraCabDef.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                        objME.childObjects.Add(oSicaPizarraCabDef)
                    End If

                    nvDBUtiles.DBCloseRecordset(rsCabDef, False)


                    '--- Agregar elementos de "calc_pizarra_def" ---
                    strSQL = "SELECT * FROM calc_pizarra_def WHERE nro_calc_pizarra=" & nro_calc_pizarra & " ORDER BY dato_orden"
                    Dim rsDef As ADODB.Recordset = conn.Execute(strSQL)
                    oPath = cn_name & "\calc_pizarra_def"
                    oObjeto = "Valores definicion de " & oSicaPizarraCab.objeto
                    oCod_subtipo = 0
                    primary_keys = New List(Of String)
                    primary_keys.Add("nro_calc_pizarra")
                    primary_keys.Add("calc_pizarra_dato")
                    oXML = nvXMLSQL.RecordsetToXML(rsDef, arParam, primary_keys:=primary_keys)
                    nvDBUtiles.DBCloseRecordset(rsDef, False)

                    strXML = oXML.OuterXml
                    oBytes = nvConvertUtiles.StringToBytes(strXML)
                    Dim oSicaPizarraDef As New tSicaObjeto
                    oSicaPizarraDef.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                    objME.childObjects.Add(oSicaPizarraDef)


                    '--- Agregar elementos de "calc_pizarra_det" ---
                    strSQL = "SELECT nro_calc_pizarra, " &
                                    "dato1_desde, dato1_hasta, " &
                                    "dato2_desde, dato2_hasta, " &
                                    "dato3_desde, dato3_hasta, " &
                                    "dato4_desde, dato4_hasta, " &
                                    "dato5_desde, dato5_hasta, " &
                                    "dato6_desde, dato6_hasta, " &
                                    "dato7_desde, dato7_hasta, " &
                                    "dato8_desde, dato8_hasta, " &
                                    "dato9_desde, dato9_hasta, " &
                                    "dato10_desde, dato10_hasta, " &
                                    "dato11_desde, dato11_hasta, " &
                                    "pizarra_valor, " &
                                    "pizarra_valor_2, " &
                                    "pizarra_valor_3, " &
                                    "orden " &
                                "FROM calc_pizarra_det " &
                                "WHERE nro_calc_pizarra=" & nro_calc_pizarra &
                            " ORDER BY orden"
                    Dim rsDet As ADODB.Recordset = conn.Execute(strSQL)
                    oPath = cn_name & "\calc_pizarra_det"
                    oObjeto = "Valores detalle de " & oSicaPizarraCab.objeto
                    oCod_subtipo = 0
                    primary_keys = New List(Of String)
                    primary_keys.Add("nro_calc_pizarra")
                    primary_keys.Add("orden")               ' "nro_calc_pizarra" y "orden" formen parte (ambas) de las PKs
                    oXML = nvXMLSQL.RecordsetToXML(rsDet, arParam, primary_keys:=primary_keys)
                    nvDBUtiles.DBCloseRecordset(rsDet, False)

                    strXML = oXML.OuterXml
                    oBytes = nvConvertUtiles.StringToBytes(strXML)
                    Dim oSicaPizarraDet As New tSicaObjeto
                    oSicaPizarraDet.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                    objME.childObjects.Add(oSicaPizarraDet)


                    If chargeBinary Then
                        Dim _bytes() As Byte
                        ReDim _bytes(0)
                        objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo, _bytes)
                    End If

                    Try
                        conn.Close()
                    Catch ex As Exception
                    End Try
                Catch ex As Exception
                    Throw New Exception("No fué posible cargar el objeto Pizarra desde la implementación", ex)
                End Try
            End Sub



            Public Function checkIntegrity(objME As tSicaObjeto, rescab As tResCab, nvApp As tnvApp) As nvenumResStatus Implements InvSicaObjetoGrupo.checkIntegrity
                Dim resStatus As nvenumResStatus


                If objME.bytes Is Nothing Then
                    resStatus = nvenumResStatus.objeto_no_econtrado
                Else
                    Dim count_no_encontrados As Integer = 0
                    Dim count_modificados As Integer = 0
                    Dim child As tSicaObjeto
                    Dim childRes As nvenumResStatus
                    Dim resChilds As New tResCab

                    For Each child In objME.childObjects
                        childRes = child.checkIntegrity(resChilds, nvApp)
                        If childRes = nvenumResStatus.objeto_no_econtrado Then count_no_encontrados += 1
                        If childRes = nvenumResStatus.objeto_modificado Then count_modificados += 1
                    Next

                    If (count_modificados > 0) OrElse (count_no_encontrados > 0) Then
                        resStatus = nvenumResStatus.objeto_modificado
                    Else
                        resStatus = nvenumResStatus.OK
                    End If
                End If

                Return resStatus
            End Function



            Public Sub saveToImplementation(objME As tSicaObjeto, nvApp As tnvApp) Implements InvSicaObjetoGrupo.saveToImplementation
                ' Verificar que esté el objeto "nvApp" de la implementación en el "objMe" (en implementation_nvApp)
                If objME.implemantation_nvApp Is Nothing AndAlso Not nvApp Is Nothing Then objME.implemantation_nvApp = nvApp

                ' No hace falta agregar el objeto base (Parametro), sólo los hijos de tipo "Dato"
                For Each child As tSicaObjeto In objME.childObjects
                    Me.objeto_agregar(child.cod_objeto, child.cod_obj_tipo, objME.implemantation_nvApp, child.modulo_version_path, child.bytes)
                Next
            End Sub



            Private Sub objeto_agregar(cod_objeto As Integer,
                                       cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo,
                                       nvApp As tnvApp,
                                       modulo_version_path As String,
                                       bytes As Byte())

                ' Tomar la conexion del path, esta compuesto por conexion\tabla
                Dim nvcn As tDBConection
                Dim cn As String = modulo_version_path.Split("\")(0)    ' Recuperar la conexion
                Dim tabla As String = modulo_version_path.Split("\")(1) ' Recuperar la tabla del path

                If cn = "" Then cn = "default"

                nvcn = nvApp.app_cns(cn).clone()
                nvcn.excaslogin = False

                Dim _paramXML As String = nvConvertUtiles.BytesToString(bytes)
                Dim oXml As New System.Xml.XmlDocument
                oXml.LoadXml(_paramXML)
                Dim nodes As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXml, "xml/s:Schema/s:ElementType/s:AttributeType")
                Dim pk As New List(Of String)
                Dim campo As String

                For Each node In nodes
                    campo = nvXMLUtiles.getAttribute_path(node, "@name", "Error")

                    If nvXMLUtiles.getAttribute_path(node, "@pk", "false") = "true" Then pk.Add(campo)
                Next

                Dim objStream As New ADODB.Stream
                With objStream
                    .Charset = "unicode"
                    .Mode = ADODB.ConnectModeEnum.adModeReadWrite
                    .Type = ADODB.StreamTypeEnum.adTypeText
                    .Open()
                    .WriteText(_paramXML)
                    .Position = 0
                End With

                Dim rs As New ADODB.Recordset
                rs.Open(objStream)
                objStream.Close()

                Dim campos As New List(Of String)
                Dim wildCards As New List(Of String)
                Dim NoPk As New List(Of String)

                For i As Integer = 0 To rs.Fields.Count - 1
                    If (rs.Fields(i).Type <> 128) OrElse ((rs.Fields(i).Attributes And &H200) = 0) Then  ' se debe excluir timestamp ( como binary tambien es tipo 128 hay q preguntar en attributes)
                        campos.Add(rs.Fields(i).Name)
                        wildCards.Add("?")

                        If Not pk.Contains(rs.Fields(i).Name) Then NoPk.Add(rs.Fields(i).Name)
                    End If
                Next

                Dim strWhere As String = "[" & String.Join("]=? and [", pk) & "]=? "
                Dim strSetCampos As String = "[" & String.Join("]=? , [", NoPk) & "]=? "
                Dim strCampos As String = "[" & String.Join("],[", campos) & "]"
                Dim strWildCards As String = String.Join(",", wildCards)
                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)
                conn.BeginTrans()

                Try
                    Dim strQuery As String = ""
                    ' Si la tabla tiene columnas "Identity" desactivar la inserción de valores de identidad
                    ' NOTA: no aplicar para la tabla "calc_pizarra_det"
                    If tabla.ToLower() <> "calc_pizarra_det" Then
                        strQuery = "IF (EXISTS(SELECT TOP 1 * FROM sys.identity_columns WHERE object_name(object_id)='" & tabla & "'))" & vbCrLf &
                                    "SET identity_insert " & tabla & " ON" & vbCrLf
                        conn.Execute(strQuery)
                    End If

                    ' Guardar las "Foreign Keys" de la tabla (si tiene alguna) para luego no chequear tales "constraints"
                    strQuery = "SELECT name FROM sys.foreign_keys WHERE object_name(parent_object_id)='" & tabla & "'"
                    Dim rsFks As ADODB.Recordset = conn.Execute(strQuery)
                    Dim fks As New List(Of String)

                    While Not rsFks.EOF
                        fks.Add(rsFks.Fields("name").Value)
                        rsFks.MoveNext()
                    End While

                    nvDBUtiles.DBCloseRecordset(rsFks, False)

                    For i As Integer = 0 To fks.Count - 1
                        strQuery = "ALTER TABLE " & tabla & vbCrLf & "NOCHECK CONSTRAINT " & fks(i)
                        conn.Execute(strQuery)
                    Next

                    Dim procedure As String
                    Dim Cmd As ADODB.Command
                    Dim rst As ADODB.Recordset
                    Dim rowcount As Integer
                    Dim _rs As ADODB.Recordset
                    Dim count As Integer

                    While Not rs.EOF
                        Try
                            ' Controlar que el registro no existe o bien si existe que sea unico; caso contrario hacer rollback
                            strQuery = "BEGIN SELECT COUNT(*) AS [count] FROM " & tabla & " WHERE "
                            Dim _where As String = ""

                            For Each _pk In pk
                                _where &= " AND [" & _pk & "]="

                                If rs.Fields(_pk).Type = ADODB.DataTypeEnum.adChar OrElse rs.Fields(_pk).Type = ADODB.DataTypeEnum.adLongVarChar OrElse
                                    rs.Fields(_pk).Type = ADODB.DataTypeEnum.adLongVarWChar OrElse rs.Fields(_pk).Type = ADODB.DataTypeEnum.adVarChar OrElse
                                    rs.Fields(_pk).Type = ADODB.DataTypeEnum.adVarWChar OrElse rs.Fields(_pk).Type = ADODB.DataTypeEnum.adWChar Then
                                    _where &= "'" & rs.Fields(_pk).Value & "'"
                                ElseIf rs.Fields(_pk).Type = ADODB.DataTypeEnum.adBoolean Then
                                    _where &= If(rs.Fields(_pk).Value.ToString.ToLower = "true" OrElse rs.Fields(_pk).Value.ToString = "1", 1, 0)
                                Else
                                    _where &= rs.Fields(_pk).Value
                                End If
                            Next

                            _where = _where.Substring(5)
                            strQuery &= _where & " END"

                            _rs = conn.Execute(strQuery)

                            If Not _rs.EOF Then
                                count = _rs.Fields("count").Value

                                Select Case count
                                    Case 0
                                        ' No hay registros => INSERTAR
                                        procedure = "BEGIN INSERT INTO " & tabla & " (" & strCampos & ") VALUES(" & strWildCards & ") END"
                                        Cmd = New ADODB.Command
                                        Cmd.ActiveConnection = conn
                                        Cmd.CommandType = ADODB.CommandTypeEnum.adCmdText
                                        Cmd.CommandTimeout = 1500
                                        Cmd.CommandText = procedure

                                        For Each campo In campos
                                            _AddADOParameter(rs.Fields(campo), Cmd)
                                        Next

                                        Cmd.Execute()


                                    Case 1
                                        ' Si no hay campos para updatear (caso excepcional de una tabla con un solo campo) => Salir con Excepción
                                        'If strSetCampos = "[]=? " Then
                                        '   Throw New Exception("No hay campos para actualizar")
                                        If strSetCampos <> "[]=? " Then
                                            ' Hay sólo un registro => ACTUALIZAR
                                            procedure = "BEGIN UPDATE " & tabla & " SET " & strSetCampos & " WHERE " & strWhere & vbCrLf & " SELECT @@rowcount AS [rowcount] END" & vbCrLf
                                            Cmd = New ADODB.Command
                                            Cmd.ActiveConnection = conn
                                            Cmd.CommandType = ADODB.CommandTypeEnum.adCmdText
                                            Cmd.CommandTimeout = 1500
                                            Cmd.CommandText = procedure

                                            For Each campo In NoPk
                                                _AddADOParameter(rs.Fields(campo), Cmd)
                                            Next

                                            For Each campo In pk
                                                _AddADOParameter(rs.Fields(campo), Cmd)
                                            Next

                                            Try
                                                rst = Cmd.Execute()
                                                rowcount = rst.Fields(0).Value
                                                nvDBUtiles.DBCloseRecordset(rst, False)

                                                If rowcount = 0 Then
                                                    Throw New Exception("Error de inserción. No se pudo updatear el registro.")
                                                End If
                                            Catch UpdateException As Exception
                                                Throw UpdateException
                                            End Try
                                        End If


                                    Case Else
                                        ' Hay más de un registro => ERROR
                                        Throw New Exception("La/s claves primarias retornan más de un registro, invalidando la actualización de los datos.")

                                End Select
                            End If

                            nvDBUtiles.DBCloseRecordset(_rs, False)
                        Catch updateDataException As Exception
                            Throw updateDataException
                        End Try

                        rs.MoveNext()
                    End While

                    ' Volver a checkear las "Foreign Keys" que tiene la tabla (si las tiene)
                    For i As Integer = 0 To fks.Count - 1
                        strQuery = "ALTER TABLE " & tabla & vbCrLf & "CHECK CONSTRAINT " & fks(i)
                        conn.Execute(strQuery)
                    Next

                    ' Volver a habilitar el control de insersión de identidades de tabla
                    If tabla.ToLower() <> "calc_pizarra_det" Then
                        conn.Execute("IF (EXISTS(SELECT TOP 1 * FROM sys.identity_columns WHERE object_name(object_id)='" & tabla & "'))" & vbCrLf &
                                        "SET identity_insert " & tabla & " OFF" & vbCrLf)
                    End If

                    conn.CommitTrans()
                Catch ex As Exception
                    conn.RollbackTrans()
                    Throw ex
                Finally
                    Try
                        conn.Close()
                        rs.Close()
                    Catch ex As Exception
                    End Try
                End Try
            End Sub



            Private Shared Sub _AddADOParameter(ByVal field As ADODB.Field, ByVal Cmd As ADODB.Command)
                If Not IsDBNull(field.Value) Then
                    ' Los campos tipo fecha se castean a string para resolver
                    ' el problema del truncado de los milisegundos
                    If field.Type = 135 Then 'datetime, smalldatetime (adDBTimeStamp)
                        Dim anio As String = String.Format("{0:D4}", field.Value.year)
                        Dim mes As String = String.Format("{0:D2}", field.Value.month)
                        Dim dia As String = String.Format("{0:D2}", field.Value.day)
                        Dim horas As String = String.Format("{0:D2}", field.Value.hour)
                        Dim minutos As String = String.Format("{0:D2}", field.Value.Minute)
                        Dim segundos As String = String.Format("{0:D2}", field.Value.Second)
                        Dim ms As String = String.Format("{0:D3}", field.Value.millisecond)
                        Dim strValue As String = anio & "" & mes & "" & dia & " " & horas & ":" & minutos & ":" & segundos & "." & ms
                        Cmd.Parameters.Append(Cmd.CreateParameter("@" & field.Name, 200, 1, strValue.Length, strValue))
                    Else
                        Dim fieldSize As Integer = field.ActualSize
                        Dim fieldValue As Object = field.Value

                        ' image nulo (adLongVarBinary = 205)
                        If field.Type = ADODB.DataTypeEnum.adLongVarBinary AndAlso field.ActualSize = 0 Then
                            fieldValue = ""
                            fieldSize = 4
                        End If

                        ' varchar y nvarchar nulos (adVarChar = 200, adVarWChar = 202)
                        If (field.Type = ADODB.DataTypeEnum.adVarChar OrElse field.Type = ADODB.DataTypeEnum.adVarWChar) AndAlso field.ActualSize = 0 Then
                            fieldSize = 4
                        End If

                        Cmd.Parameters.Append(Cmd.CreateParameter("@" & field.Name, field.Type, 1, fieldSize, fieldValue))
                    End If
                Else
                    Cmd.Parameters.Append(Cmd.CreateParameter("@" & field.Name, field.Type, 1, -1, Nothing))
                End If
            End Sub



            Public Function hasImplementation() As Boolean Implements InvSicaObjetoGrupo.hasImplementation
                ' NOTA:
                '   Si retornamos TRUE, debemos tener el método "saveToImplementation" con la implementación
                '   propia de ésta clase (tnvSicaObjetoPermisoGrupo.vb).
                '
                '   Caso contrario, retornar FALSE y dejar el método "saveToImplementation" vacío.
                Return True
            End Function
        End Class
    End Namespace
End Namespace