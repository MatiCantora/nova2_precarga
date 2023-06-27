Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvSICA
        Public Class tnvSicaTipoTransferencia
            Implements InvSicaObjetoGrupo



            Public Shared Function getRSXMLElements(nvApp As tnvApp, Optional filtro As String = "") As String
                Dim nvcn As tDBConection = nvApp.app_cns("default")
                nvcn.excaslogin = False
                Dim strSQL As String = "SELECT nombre AS objeto, " &
                                                "'default\' + CAST(id_transferencia AS VARCHAR(10)) AS path, " &
                                                "'' AS comentario , " &
                                                "0 AS cod_sub_tipo " &
                                            "FROM Transferencia_Cab " &
                                            If(filtro <> String.Empty, " WHERE nombre " & filtro, "")

                Dim rs As ADODB.Recordset

                Try
                    rs = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, _nvcn:=nvcn)
                Catch ex As Exception
                    Throw New Exception(ex.Message & "</br>Compruebe que la tabla (Transferencia_Cab) de Transferencias existe en el sistema seleccionado.")
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
                    Dim path_split As String() = path.Split("\")
                    Dim cn As String
                    Dim id_transferencia As String

                    If path_split.Length < 2 Then
                        Throw New Exception("No fué posible obtener la conexión y/o el ID de transferencia.")
                    Else
                        cn = path_split(0)
                        id_transferencia = path_split(1)
                    End If

                    Dim nvcn As tDBConection = nvApp.app_cns(cn).clone()
                    nvcn.excaslogin = False
                    Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(emunDBType.db_other, nvcn)
                    conn.CursorLocation = ADODB.CursorLocationEnum.adUseClient
                    Dim query As String

                    '--- Cargar todo el dato de la transferencia desde "transf_binary"
                    Dim table_name As String = "transf_binary"
                    query = String.Format("SELECT * FROM {0} WHERE id_transferencia={1} AND vigente={2}", table_name, id_transferencia, 1)
                    Dim rs As ADODB.Recordset
                    rs = conn.Execute(query)

                    If rs.EOF Then
                        nvDBUtiles.DBCloseRecordset(rs)
                        Exit Sub
                    End If

                    Dim oSicaTransferencia As New tSicaObjeto
                    objME.fecha_modificacion = Now()
                    objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo)

                    Dim oPath As String = String.Format("{0}\{1}", cn, table_name)  ' conexion\tabla
                    Dim oObjeto As String = objeto
                    Dim oCod_subtipo As Integer = 0
                    Dim oBytes() As Byte
                    Dim arParam As New trsParam
                    Dim primary_keys As New List(Of String)
                    primary_keys.Add("id_transferencia")
                    primary_keys.Add("vigente")

                    Dim oXML As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rs, arParam, primary_keys:=primary_keys)
                    nvDBUtiles.DBCloseRecordset(rs, False)

                    Dim strXML As String = oXML.OuterXml
                    oBytes = nvConvertUtiles.StringToBytes(strXML)
                    oSicaTransferencia.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                    objME.childObjects.Add(oSicaTransferencia)

                    ' Procesos Y tareas
                    table_name = "transf_pt_ref"
                    query = String.Format("SELECT * FROM {0} WHERE id_transferencia={1}", table_name, id_transferencia)
                    rs = conn.Execute(query)

                    If rs.EOF = False Then

                        Dim oSicatransf_pt_ref As New tSicaObjeto
                        objME.fecha_modificacion = Now()
                        objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo)

                        oPath = String.Format("{0}\{1}", cn, table_name)  ' conexion\tabla
                        oObjeto = objeto
                        oCod_subtipo = 0
                        Dim oBytesRef() As Byte
                        Dim arParamRef As New trsParam
                        Dim primary_keys_Ref As New List(Of String)
                        primary_keys_Ref.Add("id_transferencia")

                        oXML = nvXMLSQL.RecordsetToXML(rs, arParamRef, primary_keys:=primary_keys_Ref)
                        nvDBUtiles.DBCloseRecordset(rs, False)

                        strXML = oXML.OuterXml
                        oBytesRef = nvConvertUtiles.StringToBytes(strXML)
                        oSicatransf_pt_ref.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytesRef)
                        objME.childObjects.Add(oSicatransf_pt_ref)

                    End If

                    ' Procesos Y tareas
                    table_name = "campos_def"
                    query = String.Format("select c.* from transferencia_parametros tp inner join campos_def c on c.campo_def = tp.campo_def where tp.campo_def <> '' and id_transferencia = {0}", id_transferencia)
                    rs = conn.Execute(query)

                    If rs.EOF = False Then

                        Dim oSicacampos_def As New tSicaObjeto
                        objME.fecha_modificacion = Now()
                        objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo)

                        oPath = String.Format("{0}\{1}", cn, table_name)  ' conexion\tabla
                        oObjeto = objeto
                        oCod_subtipo = 0
                        Dim oBytesRef() As Byte
                        Dim arParamRef As New trsParam
                        Dim primary_keys_Ref As New List(Of String)
                        primary_keys_Ref.Add("campo_def")

                        oXML = nvXMLSQL.RecordsetToXML(rs, arParamRef, primary_keys:=primary_keys_Ref)
                        nvDBUtiles.DBCloseRecordset(rs, False)

                        strXML = oXML.OuterXml
                        oBytesRef = nvConvertUtiles.StringToBytes(strXML)
                        oSicacampos_def.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytesRef)
                        objME.childObjects.Add(oSicacampos_def)

                    End If

                    'gestor documental
                    'insertar archivo
                    Dim f_id As String = ""
                    Dim parents As String = ""
                    Dim strSQL As String = " select distinct dbo.[ref_files_depende_de](f_id) as parents, f_id from verRef_files f " &
                                           " join Transferencia_Det td On ((replace(replace(td.dtsx_path,'\\','\'),'''','') = f.ref_files_path) OR (replace(replace(td.path_reporte,'\\','\'),'''','') = f.ref_files_path) OR (replace(replace(td.path_xsl,'\\','\'),'''','') = f.ref_files_path))  and borrado = 0" &
                                           " where id_transferencia = " & id_transferencia
                    Dim rsFile_id As ADODB.Recordset = conn.Execute(strSQL)
                    While rsFile_id.EOF = False

                        If f_id = "" Then
                            f_id = rsFile_id.Fields("f_id").Value
                        Else
                            f_id += "," & rsFile_id.Fields("f_id").Value
                        End If

                        If parents = "" Then
                            parents = rsFile_id.Fields("parents").Value
                        Else
                            parents += "," & rsFile_id.Fields("parents").Value
                        End If

                        rsFile_id.MoveNext()
                    End While

                    nvDBUtiles.DBCloseRecordset(rsFile_id, False)

                    If parents <> "" Then
                        parents = parents & ","
                    End If

                    If f_id <> "" Then

                        strSQL = " select parent_f_nombre, f.f_id, f_nombre, f_ext, f_descripcion, f_path, f_falta, f_nro_tipo,nro_operador, f_depende_de, f_size, f_nro_ubi, f_nro_ubi_default,borrado,BinaryData from verref_files f" &
                             " where f.f_id in (" & parents & f_id & ") order by f_nro_tipo,f_depende_de,f.f_id"

                        Dim rsFile As New ADODB.Recordset
                        rsFile.Open(strSQL, conn, CursorType:=ADODB.CursorTypeEnum.adOpenDynamic, LockType:=ADODB.LockTypeEnum.adLockOptimistic) 'conn.Execute(strSQL)
                        While rsFile.EOF = False

                            'archivos fisicos
                            If rsFile.Fields("f_nro_tipo").Value > 0 AndAlso rsFile.Fields("f_nro_ubi").Value = "1" Then
                                If System.IO.File.Exists(rsFile.Fields("f_path").Value) Then

                                    Dim fs As System.IO.FileStream = New System.IO.FileStream(rsFile.Fields("f_path").Value, System.IO.FileMode.Open)
                                    Dim by(fs.Length - 1) As Byte
                                    fs.Read(by, 0, fs.Length)
                                    fs.Close()

                                    rsFile.Fields("BinaryData").Value = by

                                Else
                                    Throw New Exception("No existe el archivo  '" & rsFile.Fields("f_nombre").Value & "." & rsFile.Fields("f_ext").Value & "' en la unidad especificada.")
                                End If
                            End If

                            rsFile.MoveNext()
                        End While

                        ' rsFile.MoveFirst()

                        oPath = cn & "\ref_files"
                        objeto = "Registro de archivo " & oSicaTransferencia.objeto
                        oCod_subtipo = 0
                        primary_keys = New List(Of String)
                        primary_keys.Add("f_nombre")
                        primary_keys.Add("f_nro_tipo")
                        primary_keys.Add("parent_f_nombre")
                        primary_keys.Add("borrado")

                        oXML = nvXMLSQL.RecordsetToXML(rsFile, arParam, primary_keys:=primary_keys)

                        nvDBUtiles.DBCloseRecordset(rsFile, False)

                        strXML = oXML.OuterXml
                        oBytes = nvConvertUtiles.StringToBytes(strXML)
                        Dim oSicaFile As New tSicaObjeto
                        oSicaFile.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                        objME.childObjects.Add(oSicaFile)

                    End If

                    If chargeBinary Then
                        Dim _bytes() As Byte
                        ReDim _bytes(0)
                        objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo, _bytes)
                    End If
                Catch ex As Exception
                    Throw New Exception("No fué posible cargar el objeto Transferencia desde la implementación.", ex)
                End Try
            End Sub



            Public Function checkIntegrity(objME As tSicaObjeto, rescab As tResCab, nvApp As tnvApp) As nvenumResStatus Implements InvSicaObjetoGrupo.checkIntegrity
                Dim res As nvenumResStatus

                If objME.bytes Is Nothing Then
                    res = nvenumResStatus.objeto_no_econtrado
                Else
                    Dim child As tSicaObjeto
                    Dim no_encontrados_count As Integer = 0
                    Dim modificados_count As Integer = 0
                    Dim childRes As nvenumResStatus
                    Dim resChilds As New tResCab

                    For Each child In objME.childObjects
                        childRes = checkIntegrity_transferencia(child, resChilds, nvApp)

                        If childRes <> nvenumResStatus.OK Then
                            If childRes = nvenumResStatus.objeto_no_econtrado Then no_encontrados_count += 1
                            If childRes = nvenumResStatus.objeto_modificado Then modificados_count += 1
                        End If
                    Next

                    If (modificados_count > 0) OrElse (no_encontrados_count > 0) Then
                        res = nvenumResStatus.objeto_modificado
                    Else
                        res = nvenumResStatus.OK
                    End If
                End If

                Return res
            End Function



            Private Function checkIntegrity_transferencia(oMe As tSicaObjeto, resCab As tResCab, nvApp As tnvApp) As nvenumResStatus
                ' Comparar los binarios a partir de las columnas "id_transferencia" y "vigente"
                ' Si no existe en la implementacion:  --------- NO_ENCONTRADO
                ' Si existen y difiere el binario:  ----------- MODIFICADO
                ' si existen y son los binarios iguales: ------ OK
                Dim tabla As String = If(oMe.modulo_version_path.Split("\").Length = 2, oMe.modulo_version_path.Split("\")(1), "")
                Dim strXML As String = nvConvertUtiles.BytesToString(oMe.bytes)
                Dim oXmlDefinicion As New System.Xml.XmlDocument
                oXmlDefinicion.LoadXml(strXML)

                '--- DEFINICION ----------------------
                ' Sólo debe haber un nodo
                Dim nodoDefinicion As System.Xml.XmlNode = nvXMLUtiles.selectSingleNode(oXmlDefinicion, "xml/rs:data/z:row")
                If nodoDefinicion Is Nothing Then nodoDefinicion = nvXMLUtiles.selectSingleNode(oXmlDefinicion, "xml/rs:data/rs:insert/z:row")
                ' Si no hay datos en DEFINICION salir
                If nodoDefinicion Is Nothing Then Throw New Exception("La Definición no tiene datos asociados.")

                Dim id_transferencia As Integer = nvXMLUtiles.getAttribute_path(nodoDefinicion, "@id_transferencia", "-1")
                If id_transferencia = -1 Then Throw New Exception("Id de transferencia (-1) inválido.")

                ' Controlar que el objMe tenga asociada la APP
                If oMe.implemantation_nvApp Is Nothing Then oMe.implemantation_nvApp = nvApp

                Dim resElement As New tResElement
                resElement.cod_objeto = oMe.cod_objeto
                resElement.cod_obj_tipo = oMe.cod_obj_tipo
                resElement.path = oMe.modulo_version_path
                resElement.cod_sub_tipo = oMe.modulo_version_cod_sub_tipo
                resElement.objeto = oMe.objeto
                resElement.cod_modulo_version = oMe.cod_modulo_version
                resElement.cod_pasaje = oMe.modulo_version_cod_pasaje
                resElement.comentario = ""


                '--- IMPLEMENTACION ------------------
                ' Buscar directamente desde su BBDD con la conexión definida en el path desde la nvApp
                Dim cn As String = If(resElement.path.Split("\").Count = 2, resElement.path.Split("\")(0), "default")
                Dim nvcn As tDBConection = nvApp.app_cns(cn).clone()
                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(emunDBType.db_other, nvcn)
                Dim query As String
                Dim rs As ADODB.Recordset

                query = String.Format("SELECT * FROM {0} WHERE id_transferencia={1} AND vigente=1", tabla, id_transferencia)
                rs = conn.Execute(query)

                If rs.EOF Then
                    nvDBUtiles.DBCloseRecordset(rs)
                    resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                    resElement.comentario = String.Format("No existe el objeto ({0}) en la Implementación", oMe.objeto)
                    resCab.elements.Add(resElement)
                    Return nvenumResStatus.objeto_no_econtrado
                End If

                Dim oXmlImplementacion As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rs, New trsParam)

                '--------------------------------------------------------------
                ' Primary Keys
                ' 
                ' En transferencia se utilizan 2 columnas como claves primarias:
                '       * id_transferencia
                '       * vigente
                '
                '
                ' NOTA: Si se llegara a utilizar otros campos como PK, se
                '       deberán agregar aquí debajo.
                '--------------------------------------------------------------
                Dim PKs As New List(Of String)({"id_transferencia", "vigente"})

                Dim xPath As String = ""
                Dim pk_ As String = ""

                Try
                    For Each pk As String In PKs
                        pk_ = pk
                        If xPath = "" Then
                            xPath &= String.Format("@{0}='{1}'", pk, nodoDefinicion.Attributes(pk).Value)
                        Else
                            xPath &= String.Format(" and @{0}='{1}'", pk, nodoDefinicion.Attributes(pk).Value)
                        End If
                    Next
                Catch ex As Exception
                    Throw New Exception("No se encontró el atributo de clave primaria (PK: " & pk_ & ") en los nodos de Definición (tabla: " & tabla & ").", ex)
                End Try


                Dim nodosImplementacion As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlImplementacion, "xml/rs:data/z:row[" & xPath & "]")
                If nodosImplementacion.Count = 0 Then nodosImplementacion = nvXMLUtiles.selectNodes(oXmlImplementacion, "xml/rs:data/rs:insert/z:row[" & xPath & "]")

                If nodosImplementacion.Count = 1 Then
                    ' Realizar comparación binaria con los campos "valor" unicamente
                    Dim valor_definicion As String = nvXMLUtiles.getAttribute_path(nodoDefinicion, "@valor", "")
                    Dim binario_definicion As Byte() = nvConvertUtiles.StringToBytes(valor_definicion)

                    If binario_definicion.Length = 0 Then
                        resElement.resStatus = nvenumResStatus.archivo_sobrante
                        resElement.comentario = "El campo 'valor' de la transferencia del objeto (" & oMe.objeto & ") en la definición es nulo o inválido."
                        resCab.elements.Add(resElement)
                        Return nvenumResStatus.archivo_sobrante
                    End If


                    Dim valor_implementacion As String = nvXMLUtiles.getAttribute_path(nodosImplementacion(0), "@valor", "")
                    Dim binario_implementacion As Byte() = nvConvertUtiles.StringToBytes(valor_implementacion)

                    If binario_implementacion.Length = 0 Then
                        resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                        resElement.comentario = "El campo 'valor' de la transferencia del objeto (" & oMe.objeto & ") en la implementación es nulo o inválido."
                        resCab.elements.Add(resElement)
                        Return nvenumResStatus.objeto_no_econtrado
                    End If


                    If binario_definicion.Length <> binario_implementacion.Length Then
                        resElement.resStatus = nvenumResStatus.objeto_modificado
                        resElement.comentario = "El campo 'valor' de la transferencia del objeto (" & oMe.objeto & ") difiere en longitud (bytes) entre definición e implementación."
                        resCab.elements.Add(resElement)
                        Return nvenumResStatus.objeto_modificado
                    End If


                    ' Comparar byte a byte
                    For i As Integer = 0 To binario_definicion.Length - 1
                        If binario_definicion(i) <> binario_implementacion(i) Then
                            resElement.resStatus = nvenumResStatus.objeto_modificado
                            resElement.comentario = "El campo 'valor' de la transferencia del objeto (" & oMe.objeto & ") difiere entre definición e implementación."
                            resCab.elements.Add(resElement)
                            Return nvenumResStatus.objeto_modificado
                            Exit For
                        End If
                    Next
                Else
                    ' No hay resultados o bien hay mas de 1
                    If nodosImplementacion.Count = 0 Then
                        resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                        resElement.comentario = "No se encontró el objeto (" & oMe.objeto & ") en la implementación."
                        resCab.elements.Add(resElement)
                        Return nvenumResStatus.objeto_no_econtrado
                    ElseIf nodosImplementacion.Count > 1 Then
                        resElement.resStatus = nvenumResStatus.archivo_sobrante
                        resElement.comentario = "Hay más de una coincidencia al comparar contra la implementación. Revisar que las PKs utilizadas obtengan resultados únicos."
                        resCab.elements.Add(resElement)
                        Return nvenumResStatus.archivo_sobrante
                    End If
                End If


                Return nvenumResStatus.OK
            End Function



            Public Sub saveToImplementation(oMe As tSicaObjeto, nvApp As tnvApp) Implements InvSicaObjetoGrupo.saveToImplementation
                ' Verificar que esté presente el objeto "nvApp" de la implementación en el "oMe" (en implementation_nvApp)
                If oMe.implemantation_nvApp Is Nothing AndAlso Not nvApp Is Nothing Then oMe.implemantation_nvApp = nvApp

                'For Each child As tSicaObjeto In oMe.childObjects
                '    Me.objeto_agregar(child.cod_objeto, child.cod_obj_tipo, oMe.implemantation_nvApp, child.modulo_version_path, child.bytes)
                'Next


                Dim oDefinicion As New tSicaObjeto
                For Each child As tSicaObjeto In oMe.childObjects
                    If child.modulo_version_path.Split("\")(1).ToLower() = "transf_binary" Then
                        oDefinicion = child
                    End If
                Next

                Dim cn As String = ""
                Dim tabla As String = ""

                If oDefinicion.modulo_version_path.Split("\").Length = 2 Then
                    cn = oDefinicion.modulo_version_path.Split("\")(0)              ' Recuperar la conexion
                    tabla = oDefinicion.modulo_version_path.Split("\")(1).ToLower() ' Recuperar la tabla del path
                End If

                If cn = "" Then cn = "default"

                Dim nvcn As tDBConection
                nvcn = nvApp.app_cns(cn).clone()
                nvcn.excaslogin = False

                Dim strXML As String = nvConvertUtiles.BytesToString(oDefinicion.bytes)
                Dim oXml As New System.Xml.XmlDocument
                oXml.LoadXml(strXML)

                ' Cargar el nodo transferencia
                Dim nodo_transferencia As System.Xml.XmlNode = nvXMLUtiles.selectSingleNode(oXml, "xml/rs:data/z:row")
                If nodo_transferencia Is Nothing Then nodo_transferencia = nvXMLUtiles.selectSingleNode(oXml, "xml/rs:data/rs:insert/z:row")

                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)
                Dim ultimo_paso_ejecutado As String = ""

                Try
                    ' Obtener el "id_transferencia", "id_transf_version" y "valor"
                    Dim id_transferencia As Integer = nvXMLUtiles.getAttribute_path(nodo_transferencia, "@id_transferencia")
                    Dim id_transf_version As Integer = nvXMLUtiles.getAttribute_path(nodo_transferencia, "@id_transf_version")
                    Dim valor As String = nvXMLUtiles.getAttribute_path(nodo_transferencia, "@valor")
                    Dim valor_len As Integer = valor.Length

                    If (valor_len And 1) = 1 Then
                        Throw New Exception("La longitud del String es impar cuando se requiere que sea par para procesarlo como Binario hexadecimal.")
                    End If

                    ' "@valor" es un Base 64 String --> convertirlo a byte array para pasarlo al SP
                    Dim nBytes As Integer = valor_len \ 2
                    Dim valor_array(nBytes - 1) As Byte

                    For i = 0 To nBytes - 1
                        valor_array(i) = Convert.ToByte(valor.Substring(i * 2, 2), 16)
                    Next

                    Dim query As String

                    conn.BeginTrans()   ' INICIO transacción

                    ' 1) Actualizar el ultimo registro en "transf_binary" y sacarlo de vigencia
                    'query = String.Format("UPDATE {0} SET vigente=0 WHERE id_transferencia={1} AND vigente=1", tabla, id_transferencia)
                    query = String.Format("DELETE FROM {0} WHERE id_transferencia={1} AND vigente=1", tabla, id_transferencia)
                    conn.Execute(query)
                    ultimo_paso_ejecutado = "Ultimo paso ejecutado (1/4): se quitó la última transferencia vigente."


                    ' 2) Insertar el nuevo binario
                    Dim strCampos As String = "[id_transferencia],[valor],[id_transf_version],[vigente],[fe_transf_version]"
                    query = "INSERT INTO " & tabla & " (" & strCampos & ") VALUES (?,?,?,?,GETDATE())"

                    Dim Cmd As ADODB.Command = New ADODB.Command
                    Cmd.ActiveConnection = conn
                    Cmd.CommandType = ADODB.CommandTypeEnum.adCmdText
                    Cmd.CommandTimeout = 1500
                    Cmd.CommandText = query

                    ' Agregar los parametros de cada campo (en orden tal como se definen en el insert)
                    Dim param As ADODB.Parameter

                    '--- id_transferencia -------------
                    param = Cmd.CreateParameter("@id_transferencia")
                    param.Type = ADODB.DataTypeEnum.adInteger
                    param.Direction = ADODB.ParameterDirectionEnum.adParamInput
                    param.Value = id_transferencia
                    Cmd.Parameters.Append(param)

                    '--- valor ------------------------
                    param = Cmd.CreateParameter("@valor")
                    param.Type = ADODB.DataTypeEnum.adLongVarBinary
                    param.Direction = ADODB.ParameterDirectionEnum.adParamInput
                    param.Size = valor_array.Length
                    param.Value = valor_array
                    Cmd.Parameters.Append(param)

                    '--- id_transf_version -------------
                    param = Cmd.CreateParameter("@id_transf_version")
                    param.Type = ADODB.DataTypeEnum.adInteger
                    param.Direction = ADODB.ParameterDirectionEnum.adParamInput
                    param.Value = id_transf_version
                    Cmd.Parameters.Append(param)

                    '--- vigente ----------------------
                    param = Cmd.CreateParameter("@vigente")
                    param.Type = ADODB.DataTypeEnum.adBoolean
                    param.Direction = ADODB.ParameterDirectionEnum.adParamInput
                    param.Value = 1
                    Cmd.Parameters.Append(param)

                    Cmd.Execute()
                    '--- NOTA -----------------------------------------------------------------
                    ' Necesitamos commitear los cambios antes de ejecutar el PASO 3, ya que
                    ' internamente el procedimiento "transf_abm" está transaccionado y se rompe
                    ' la conexión actual
                    '--------------------------------------------------------------------------
                    conn.CommitTrans()  ' FINALIZO transacción
                    ultimo_paso_ejecutado = "Ultimo paso ejecutado (2/4): se agregó la nueva transferencia."


                    ' 3) Cargar la transferencia
                    query = String.Format("DECLARE @id_transferencia INT = {0}", id_transferencia) & vbCrLf &
                                 "DECLARE @valor VARBINARY(MAX)" & vbCrLf &
                                 "SELECT @valor = valor FROM transf_binary WHERE id_transferencia = @id_transferencia AND vigente = 1" & vbCrLf

                    query &= "IF (NOT EXISTS(SELECT 1 FROM transferencia_cab WHERE id_transferencia = @id_transferencia))" & vbCrLf &
                                 "BEGIN" & vbCrLf &
                                   "SET IDENTITY_INSERT transferencia_cab ON" & vbCrLf &
                                   "INSERT INTO transferencia_cab(id_transferencia, nombre, habi, timeout, id_transf_estado, transf_fe_creacion, transf_fe_modificado, operador, transf_version)" & vbCrLf &
                                   "VALUES(@id_transferencia, '', 1, 300, 1, getdate(), getdate(), dbo.rm_nro_operador(), '2.0')" & vbCrLf &
                                   "SET IDENTITY_INSERT transferencia_cab OFF" & vbCrLf &
                                 "END" & vbCrLf

                    query &= "IF (NOT(@valor IS NULL))" & vbCrLf &
                                   "EXEC [transf_abm] @valor, 1, @id_transferencia"

                    Dim rs As ADODB.Recordset = conn.Execute(query)
                    nvDBUtiles.DBCloseRecordset(rs, False)
                    ultimo_paso_ejecutado = "Ultimo paso ejecutado (3/4): se actualizó la tabla 'transferencia_cab'."

                    For Each child As tSicaObjeto In oMe.childObjects
                        If child.modulo_version_path.Split("\")(1).ToLower() <> "transf_binary" Then
                            Me.objetos_anexos_agregar(child.cod_objeto, child.cod_obj_tipo, oMe.implemantation_nvApp, child.modulo_version_path, child.bytes)
                        End If
                    Next

                    ultimo_paso_ejecutado = "Ultimo paso ejecutado (4/4): se actualizó gestor de archivos."

                Catch ex As Exception
                    conn.RollbackTrans()
                    Throw New Exception("Ocurrió un error al implementar la transferencia.</br>" & ultimo_paso_ejecutado & "</br>Se realizó un rollback transaccional.")
                Finally
                    If conn.State = 1 Then conn.Close()
                End Try

            End Sub

            Private f_id_dependientes As String = ""

            Private Sub objetos_anexos_agregar(cod_objeto As Integer,
                                       cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo,
                                       nvApp As tnvApp,
                                       modulo_version_path As String,
                                       bytes As Byte())

                ' el gestor documental esta compuesto de objetos de tipo "DATOS"
                If cod_obj_tipo = tSicaObjeto.nvEnumObjeto_tipo.datos Then
                    ' Tomar la conexion del path, esta compuesto por conexion\tabla
                    Dim nvcn As tDBConection
                    Dim cn As String = modulo_version_path.Split("\")(0)                ' Recuperar la conexion
                    Dim tabla As String = modulo_version_path.Split("\")(1).ToLower()   ' Recuperar la tabla del path

                    cn = If(cn = "", "default", cn)
                    nvcn = nvApp.app_cns(cn).clone()
                    nvcn.excaslogin = False

                    Dim _paramXML As String = nvConvertUtiles.BytesToString(bytes)
                    Dim oXml As New System.Xml.XmlDocument
                    oXml.LoadXml(_paramXML)

                    Dim nodesDef As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXml, "xml/s:Schema/s:ElementType/s:AttributeType")
                    Dim pks As New List(Of String)

                    For Each node As System.Xml.XmlNode In nodesDef
                        If nvXMLUtiles.getAttribute_path(node, "@pk", "false") = "true" Then
                            pks.Add(nvXMLUtiles.getAttribute_path(node, "@name", "Error"))
                        End If
                    Next

                    Dim rs As ADODB.Recordset
                    Dim query As String
                    Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)
                    conn.BeginTrans()

                    nodesDef = nvXMLUtiles.selectNodes(oXml, "xml/rs:data/z:row")

                    Try

                        For Each node As System.Xml.XmlNode In nodesDef

                            Select Case tabla

                                Case "campos_def"

                                    Dim campo_def As String = nvXMLUtiles.getAttribute_path(node, "@campo_def", "")
                                    Dim descripcion As String = nvXMLUtiles.getAttribute_path(node, "@descripcion", "")
                                    Dim filtroXML As String = nvXMLUtiles.getAttribute_path(node, "@filtroXML", "")
                                    Dim nro_campo_tipo As String = nvXMLUtiles.getAttribute_path(node, "@nro_campo_tipo", "")
                                    Dim filtroWhere As String = nvXMLUtiles.getAttribute_path(node, "@filtroWhere", "")
                                    Dim campo_filtro As String = nvXMLUtiles.getAttribute_path(node, "@campo_filtro", "")
                                    Dim depende_de As String = nvXMLUtiles.getAttribute_path(node, "@depende_de", "")
                                    Dim depende_de_campo As String = nvXMLUtiles.getAttribute_path(node, "@depende_de_campo", "")
                                    Dim permite_codigo As String = If(nvXMLUtiles.getAttribute_path(node, "@permite_codigo", "").ToLower = "true", "1", "0")
                                    Dim json As String = If(nvXMLUtiles.getAttribute_path(node, "@json", "").ToLower = "true", "1", "0")
                                    Dim cacheControl As String = nvXMLUtiles.getAttribute_path(node, "@cacheControl", "")
                                    Dim options As String = nvXMLUtiles.getAttribute_path(node, "@options", "")

                                    Dim strWhere As New List(Of String)

                                    For Each pk As String In pks
                                        strWhere.Add("[" & pk & "]='" & nvXMLUtiles.getAttribute_path(node, "@" & pk, "") & "'")
                                    Next

                                    query = "SELECT campo_def FROM campos_def WHERE " & String.Join(" AND ", strWhere)
                                    rs = conn.Execute(query)

                                    If rs.EOF = True Then
                                        query = String.Format("INSERT INTO [campos_def] " &
                                                               "          ([campo_def],[descripcion],[filtroXML],[nro_campo_tipo],[filtroWhere] " &
                                                               "         ,[campo_filtro],[depende_de],[depende_de_campo],[permite_codigo],[json],[cacheControl],[options]) " &
                                                               "   VALUES ('{0}','{1}','{2}',{3},'{4}','{5}','{6}','{7}',{8},{9},'{10}','{11}') ", campo_def, descripcion, filtroXML.Replace("'", "''"), nro_campo_tipo, filtroWhere.Replace("'", "''"), campo_filtro, depende_de, depende_de_campo, permite_codigo, json, cacheControl, options)

                                        conn.Execute(query)
                                    End If

                                    nvDBUtiles.DBCloseRecordset(rs, False)

                                Case "ref_files"

                                    Dim f_id As Integer = 0
                                    Dim f_nombre As String = nvXMLUtiles.getAttribute_path(node, "@f_nombre", "")
                                    Dim f_ext As String = nvXMLUtiles.getAttribute_path(node, "@f_ext", "")
                                    Dim f_descripcion As String = nvXMLUtiles.getAttribute_path(node, "@f_descripcion", "")
                                    Dim f_path As String = "" 'nvXMLUtiles.getAttribute_path(node, "@f_path", "")
                                    Dim f_falta As String = "getdate()" 'String.Format(DateTime.Parse(nvXMLUtiles.getAttribute_path(node, "@f_falta", ""), cultureinfo), "dd/MM/yyyy")
                                    Dim f_nro_tipo As String = nvXMLUtiles.getAttribute_path(node, "@f_nro_tipo", "NULL")
                                    Dim nro_operador As String = "dbo.rm_nro_operador()" 'nvXMLUtiles.getAttribute_path(node, "@nro_operador", "NULL")

                                    Dim f_size As String = nvXMLUtiles.getAttribute_path(node, "@f_size", "NULL")
                                    Dim borrado As String = If(nvXMLUtiles.getAttribute_path(node, "@borrado", "").ToLower = "true", "1", "0")
                                    Dim nro_operador_borrado As String = If(nvXMLUtiles.getAttribute_path(node, "@borrado", "").ToLower = "true", "dbo.rm_nro_operador()", "NULL")
                                    'Dim hereda_permisos As String = nvXMLUtiles.getAttribute_path(node, "@hereda_permisos", "1")
                                    Dim f_nro_ubi As String = nvXMLUtiles.getAttribute_path(node, "@f_nro_ubi", "NULL")
                                    Dim f_nro_ubi_default As String = nvXMLUtiles.getAttribute_path(node, "@f_nro_ubi_default", "2")


                                    Dim parent_f_nombre As String = nvXMLUtiles.getAttribute_path(node, "@parent_f_nombre", "")
                                    Dim f_depende_de As String = "NULL"
                                    Dim hereda_permisos As String = "NULL"

                                    Dim filtros_dependientes As String = ""

                                    If parent_f_nombre <> "" Then

                                        If f_id_dependientes <> "" Then
                                            filtros_dependientes = " and f_depende_de in (" & f_id_dependientes & ")"
                                        End If

                                        query = "SELECT f_id,f_nro_ubi FROM ref_files WHERE f_nombre = '" & parent_f_nombre & "' and borrado = 0" & filtros_dependientes
                                        Dim rsDep = conn.Execute(query)
                                        If rsDep.EOF = False Then

                                            f_depende_de = rsDep.Fields("f_id").Value
                                            f_nro_ubi = rsDep.Fields("f_nro_ubi").Value
                                            hereda_permisos = "1"

                                            If f_id_dependientes = "" Then
                                                f_id_dependientes = "'" & f_depende_de & "'"
                                            Else
                                                f_id_dependientes += ",'" & f_depende_de & "'"
                                            End If

                                        Else
                                            Throw New Exception("No se pudo obtener la dependencia de:" & f_nombre)
                                        End If
                                        nvDBUtiles.DBCloseRecordset(rsDep, False)

                                    End If

                                    Dim strWhere As New List(Of String)

                                    For Each pk As String In pks
                                        If pk = "parent_f_nombre" Then
                                            If f_depende_de = "NULL" Then
                                                strWhere.Add("[f_depende_de] IS NULL")
                                            Else
                                                strWhere.Add("[f_depende_de]=" & f_depende_de & "")
                                            End If
                                        Else
                                            strWhere.Add("[" & pk & "]='" & nvXMLUtiles.getAttribute_path(node, "@" & pk, "") & "'")
                                        End If
                                    Next

                                    query = "SELECT f_id FROM dbo.ref_files WHERE " & String.Join(" AND ", strWhere)

                                    rs = conn.Execute(query)
                                    query = ""

                                    If rs.EOF = False Then
                                        f_id = rs.Fields("f_id").Value
                                    End If
                                    nvDBUtiles.DBCloseRecordset(rs, False)

                                    ' si es archivo
                                    If f_id > 0 AndAlso f_nro_tipo > 0 Then

                                        query = String.Format("UPDATE [ref_files]" &
                                                              "  SET [borrado] = 1" &
                                                              "     ,[nro_operador_borrado] =  dbo.rm_nro_operador()" &
                                                              "     WHERE f_id = {0}", f_id) & vbCrLf

                                        'crea una nueva version del archivo
                                        f_id = 0

                                    End If

                                    If f_id = 0 Then

                                        query += String.Format("INSERT INTO [ref_files]" &
                                                                      " ([f_nombre],[f_ext],[f_descripcion],[f_path],[f_falta],[f_nro_tipo]" &
                                                                      " ,[nro_operador],[f_depende_de],[f_size],[borrado],[nro_operador_borrado]" &
                                                                      " ,[hereda_permisos],[f_nro_ubi],[f_nro_ubi_default])" &
                                                                      " VALUES" &
                                                                      "('{0}','{1}','{2}','{3}',{4},{5},{6},{7},'{8}',{9},{10},{11},{12},{13})", f_nombre, f_ext, f_descripcion, f_path, f_falta, f_nro_tipo, nro_operador, f_depende_de, f_size, borrado, nro_operador_borrado, hereda_permisos, f_nro_ubi, f_nro_ubi_default) & vbCrLf
                                        query += "select SCOPE_IDENTITY() as f_id" & vbCrLf

                                        Dim rs_f_id As ADODB.Recordset = conn.Execute(query)
                                        If rs_f_id.EOF = False Then
                                            f_id = rs_f_id.Fields("f_id").Value
                                        End If
                                        nvDBUtiles.DBCloseRecordset(rs_f_id, False)

                                        If hereda_permisos = "NULL" Then

                                            query = String.Format("INSERT INTO [dbo].[ref_file_permisos] ([f_id],[tipo_operador],[permiso],[nro_operador])" &
                                                                   " VALUES " &
                                                                   " ({0},1,31,{1})", f_id, nro_operador)

                                            conn.Execute(query)

                                        End If

                                    End If

                                    Dim BinaryData As String = nvXMLUtiles.getAttribute_path(node, "@BinaryData", "")

                                    If BinaryData <> "" AndAlso f_id > 0 AndAlso f_nro_ubi = 2 Then

                                        query = String.Format("DELETE FROM [ref_file_bin] WHERE [f_id] = {0}", f_id)
                                        'query += String.Format("INSERT INTO [ref_file_bin]" &
                                        '                                  " ([f_id],[BinaryData])" &
                                        '                                  " VALUES" &
                                        '                                  " ({0},{1})", f_id, BinaryData)
                                        conn.Execute(query)

                                        Dim cmd As New nvDBUtiles.tnvDBCommand("insert into ref_file_bin(f_id,BinaryData) values  (?, ?)", ADODB.CommandTypeEnum.adCmdText, cn:=conn)

                                        cmd.Parameters(0).Type = ADODB.DataTypeEnum.adInteger
                                        cmd.Parameters(0).Size = -1
                                        cmd.Parameters(0).Value = f_id

                                        cmd.Parameters(1).Type = ADODB.DataTypeEnum.adVarBinary
                                        cmd.Parameters(1).Size = -1
                                        cmd.Parameters(1).Value = nvConvertUtiles.BinhexToBytes2(BinaryData)

                                        cmd.Execute()

                                    End If

                                    If BinaryData <> "" AndAlso f_id > 0 AndAlso f_nro_ubi = 1 Then

                                        Dim path As String = nvApp.app_dirs("nvFiles").path

                                        If System.IO.Directory.Exists(path) = False Then
                                            Throw New Exception("El repositorio del archivo '" & f_nombre & "." & f_ext & "' no existe")
                                        End If

                                        Dim filename As String = path & "\file" & f_id & "." & f_ext

                                        nvFW.nvReportUtiles.create_folder(filename)

                                        Dim bin As Byte() = nvConvertUtiles.BinhexToBytes2(BinaryData)

                                        Dim fs = New System.IO.FileStream(filename, System.IO.FileMode.Create, System.IO.FileAccess.ReadWrite)
                                        fs.Write(bin, 0, bin.Length)
                                        fs.Close()

                                        query = String.Format("UPDATE [ref_files]" &
                                                         "  SET [f_path] = '{0}'" &
                                                         "     ,[nro_operador] =  {1}" &
                                                         "      WHERE f_id = {2}", filename, nro_operador, f_id)
                                        conn.Execute(query)

                                    End If

                                Case "transf_pt_ref"

                                    Dim id_transf_pt_param1 As String = nvXMLUtiles.getAttribute_path(node, "@id_transf_pt_param1", "")
                                    Dim id_transf_pt_param2 As String = nvXMLUtiles.getAttribute_path(node, "@id_transf_pt_param2", "")
                                    Dim id_transf_pt_param3 As String = nvXMLUtiles.getAttribute_path(node, "@id_transf_pt_param3", "")
                                    Dim descripcion As String = nvXMLUtiles.getAttribute_path(node, "@descripcion", "")
                                    Dim id_transferencia As String = nvXMLUtiles.getAttribute_path(node, "@id_transferencia", "")
                                    Dim vigente As String = If(nvXMLUtiles.getAttribute_path(node, "@vigente", "").ToLower = "true", "1", "0")

                                    id_transf_pt_param1 = If(id_transf_pt_param1 = "", "NULL", id_transf_pt_param1)
                                    id_transf_pt_param2 = If(id_transf_pt_param2 = "", "NULL", id_transf_pt_param2)
                                    id_transf_pt_param3 = If(id_transf_pt_param3 = "", "NULL", id_transf_pt_param3)

                                    query = String.Format("DELETE FROM [transf_pt_ref] WHERE [id_transferencia] = {0}", id_transferencia) & vbCrLf
                                    query += String.Format("INSERT INTO [dbo].[transf_pt_ref]" &
                                                           "          ([id_transf_pt_param1]" &
                                                           "          ,[id_transf_pt_param2]" &
                                                           "          ,[id_transf_pt_param3]" &
                                                           "          ,[descripcion]" &
                                                           "          ,[id_transferencia]" &
                                                           "          ,[vigente]" &
                                                           "          ,[nro_permiso_grupo]" &
                                                           "          ,[nro_permiso])" &
                                                           "    VALUES" &
                                                           "          ({0}" &
                                                           "          ,{1}" &
                                                           "          ,{2}" &
                                                           "          ,'{3}'" &
                                                           "          ,{4}" &
                                                           "          ,{5}" &
                                                           "          ,NULL" &
                                                           "          ,NULL)", id_transf_pt_param1, id_transf_pt_param2, id_transf_pt_param3, descripcion, id_transferencia, vigente)

                                    conn.Execute(query)

                                Case Else


                            End Select

                        Next

                        conn.CommitTrans()

                    Catch ex As Exception
                        conn.RollbackTrans()
                        Throw ex
                    Finally
                        conn.Close()
                    End Try

                End If

            End Sub

            Public Function hasImplementation() As Boolean Implements InvSicaObjetoGrupo.hasImplementation
                ' NOTA:
                '   Si retornamos TRUE, debemos tener el método "saveToImplementation" con la implementación
                '   propia de ésta clase (tnvSicaObjetoTransferencia.vb).
                '
                '   Caso contrario, retornar FALSE y dejar el método "saveToImplementation" vacío.
                Return True
            End Function

        End Class
    End Namespace
End Namespace
