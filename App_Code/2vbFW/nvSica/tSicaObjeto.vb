Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvSICA

        Public Class tSicaObjeto

            Public cod_objeto As Integer
            Public objeto As String
            Public cod_obj_tipo As nvEnumObjeto_tipo
            Public fecha_creacion As DateTime
            Public fecha_modificacion As DateTime
            Public implemantation_nvApp As tnvApp
            Public cod_modulo_version As Integer = 0
            Public modulo_version_path As String = ""
            Public modulo_version_cod_sub_tipo As Integer = 0
            Public modulo_version_depende_de As Integer = 0
            Public modulo_version_cod_pasaje As Integer = 0
            Public modulo_version_fe_modificacion As DateTime
            Public es_baja As Boolean = False
            Public childObjects As List(Of tSicaObjeto)
            Public physical_path As String = ""
            Private _isImplementation As Boolean = False
            Private _bytes() As Byte
            Private _hash() As Byte
            Private _extension As String = ""
            Private _isBinaryLoad As Boolean = False
            Private _esGrupo As Boolean
            Private _paramXML As String = ""


            Public Sub New(Optional ByVal cod_objeto As Integer = 0)
                childObjects = New List(Of tSicaObjeto)

                If cod_objeto <> 0 Then Me.loadFromDefinition(cod_objeto)
            End Sub


            Public Sub New(ByVal nvApp As tnvApp, ByVal cod_objeto_tipo As nvEnumObjeto_tipo, ByVal path As String, ByVal objeto As String, Optional ByVal cod_sub_tipo As Integer = 0)
                Me.loadFromImplementation(nvApp, cod_objeto_tipo, path, objeto, cod_sub_tipo)
            End Sub


            Public ReadOnly Property isImplementacion As Boolean
                Get
                    Return _isImplementation
                End Get
            End Property


            Public ReadOnly Property bytes As Byte()
                Get
                    If _isBinaryLoad = False Then _loadBinary()

                    Return _bytes
                End Get
            End Property


            Public ReadOnly Property hash As Byte()
                Get
                    If _isBinaryLoad = False Then _loadBinary()

                    Return _hash
                End Get
            End Property


            Public ReadOnly Property extension As String
                Get
                    If _isBinaryLoad = False Then _loadBinary()

                    Return _extension
                End Get
            End Property


            Public ReadOnly Property size As Integer
                Get
                    If _isBinaryLoad = False Then _loadBinary()
                    If _bytes Is Nothing Then Return 0

                    Return _bytes.Length
                End Get
            End Property


            Public ReadOnly Property esGrupo As Boolean
                Get
                    Return _esGrupo
                End Get
            End Property



            Public Sub loadFromDefinition(Optional ByVal cod_objeto As Integer = 0)
                If cod_objeto <> 0 Then Me.cod_objeto = cod_objeto
                If Me.cod_objeto = 0 Then Exit Sub

                Dim strsql As String = "SELECT nv_objetos.*, nv_objeto_tipos.esGrupo FROM nv_objetos JOIN nv_objeto_tipos ON nv_objetos.cod_obj_tipo = nv_objeto_tipos.cod_obj_tipo WHERE cod_objeto=" & Me.cod_objeto
                Dim rsObj As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strsql)

                If Not rsObj.EOF Then
                    Me.objeto = rsObj.Fields("objeto").Value
                    Me.cod_obj_tipo = rsObj.Fields("cod_obj_tipo").Value
                    Me.fecha_creacion = rsObj.Fields("fecha_creacion").Value
                    Me.fecha_modificacion = rsObj.Fields("fecha_modificacion").Value
                    _esGrupo = rsObj.Fields("esGrupo").Value
                Else
                    Me.objeto = Nothing
                    Me.cod_obj_tipo = Nothing
                    Me.fecha_creacion = Nothing
                    Me.fecha_modificacion = Nothing
                    _esGrupo = Nothing
                End If

                nvDBUtiles.DBCloseRecordset(rsObj)

                _isBinaryLoad = False
                _isImplementation = False
                _bytes = Nothing
            End Sub



            Public Sub loadFromDefinition(ByVal cod_mdulo_version As Integer, ByVal cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo, ByVal path As String, ByVal objeto As String, Optional cod_pasaje As Integer = 0)
                Me.cod_modulo_version = cod_mdulo_version
                Me.cod_obj_tipo = cod_obj_tipo
                Me.modulo_version_path = path
                Me.objeto = objeto
                Me.cod_obj_tipo = cod_obj_tipo

                Dim sb As New StringBuilder()
                sb.Append("SELECT a.cod_objeto ")
                sb.Append("FROM nv_modulo_version_objetos a ")
                sb.Append("JOIN nv_objetos b ON a.cod_objeto = b.cod_objeto ")
                sb.AppendFormat("WHERE cod_modulo_version={0} AND path='{1}' AND objeto='{2}' AND cod_pasaje={3}", Me.cod_modulo_version, Me.modulo_version_path, Me.objeto, cod_pasaje)

                Dim rsObjeto As ADODB.Recordset = nvDBUtiles.ADMDBExecute(sb.ToString())

                If Not rsObjeto.EOF Then
                    Me.loadFromDefinition(rsObjeto.Fields("cod_objeto").Value)
                End If

                nvDBUtiles.DBCloseRecordset(rsObjeto)
            End Sub



            Public Sub _loadBinary()
                If Not _isBinaryLoad Then

                    '**************************************
                    ' Cargar desde la IMPLEMENTACION
                    '**************************************
                    If _isImplementation Then
                        If _esGrupo Then
                            Dim objetoGrupo As InvSicaObjetoGrupo = nvSICA.nvSicaObjetoGrupo.getObject(Me.cod_obj_tipo)
                            objetoGrupo.loadFromImplementation(Me, Me.implemantation_nvApp, Me.cod_obj_tipo, Me.modulo_version_path, Me.objeto, Me.modulo_version_cod_sub_tipo, True)
                            Exit Sub
                        End If

                        Select Case Me.cod_obj_tipo
                            Case nvEnumObjeto_tipo.directorio
                                fecha_modificacion = IO.Directory.GetCreationTime(physical_path)
                                ReDim _bytes(0)

                            Case nvEnumObjeto_tipo.grupo
                                ReDim _bytes(0)
                                _isBinaryLoad = True

                            Case nvEnumObjeto_tipo.archivo
                                If IO.File.Exists(physical_path) Then
                                    fecha_modificacion = IO.File.GetLastWriteTime(physical_path)

                                    ' Asi no funciona: hay que emplear Using
                                    'Dim fs As System.IO.FileStream = New System.IO.FileStream(physical_path, IO.FileMode.Open)
                                    'Dim bytes(fs.Length - 1) As Byte
                                    'fs.Read(bytes, 0, fs.Length)
                                    'fs.Close()
                                    '_bytes = bytes

                                    _bytes = IO.File.ReadAllBytes(physical_path)
                                    _isBinaryLoad = True
                                End If

                            Case nvEnumObjeto_tipo.vista, nvEnumObjeto_tipo.sp, nvEnumObjeto_tipo.funcion, nvEnumObjeto_tipo.tabla
                                Dim nvcn As tDBConection

                                If modulo_version_path = "" Then
                                    nvcn = implemantation_nvApp.app_cns("default").clone()
                                Else
                                    If Not implemantation_nvApp.app_cns.ContainsKey(modulo_version_path) Then
                                        Throw New Exception("No se pudo encontrar una definición para la conexion " & modulo_version_path & " en el objeto " & Me.objeto)
                                    End If

                                    nvcn = implemantation_nvApp.app_cns(modulo_version_path).clone()
                                End If

                                nvcn.excaslogin = False
                                Dim strDef As String
                                Dim strSQL As String = "select OBJECT_DEFINITION(object_id) as obj_def, modify_date from sys.objects where name = '" & objeto & "'"
                                Dim rsObj As ADODB.Recordset = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, _nvcn:=nvcn)

                                If Not rsObj.EOF Then
                                    fecha_modificacion = rsObj.Fields("modify_date").Value

                                    If Me.cod_obj_tipo <> nvEnumObjeto_tipo.tabla Then
                                        strDef = rsObj.Fields("obj_def").Value
                                    Else
                                        'strDef = _GetTablasScript(nvcn, Me.objeto)
                                        ' llamar a nueva funcion "GetTablasXml" que incluye el resultado de "_GetTablasScript"
                                        strDef = GetTablasXml(nvcn, Me.objeto)
                                    End If

                                    _bytes = nvConvertUtiles.StringToBytes(strDef)
                                    _isBinaryLoad = True
                                End If

                                nvDBUtiles.DBCloseRecordset(rsObj)

                            Case nvEnumObjeto_tipo.datos
                                Try
                                    ' Tomar la conexion del path, esta compuesto por conexion\tabla
                                    Dim nvcn As tDBConection
                                    Dim cn As String = Me.modulo_version_path.Split("\")(0)     ' Recuperar la conexion
                                    Dim tabla As String = Me.modulo_version_path.Split("\")(1)  ' Recuperar la tabla del path

                                    If cn = "" Then cn = "default"
                                    nvcn = Me.implemantation_nvApp.app_cns(cn).clone()
                                    nvcn.excaslogin = False

                                    Dim oXMl As New System.Xml.XmlDocument

                                    If _paramXML = "" Then
                                        oXMl = _loadTableData(tabla, nvcn)
                                    Else
                                        oXMl.LoadXml(_paramXML)
                                    End If

                                    Dim nodes As System.Xml.XmlNodeList
                                    nodes = nvXMLUtiles.selectNodes(oXMl, "xml/s:Schema/s:ElementType/s:AttributeType")
                                    Dim node As System.Xml.XmlNode
                                    Dim campos As New List(Of String)
                                    Dim pk As New List(Of String)
                                    Dim campo As String
                                    Dim strCampos As String = ""
                                    Dim strWhere As String = ""
                                    Dim strWhere2 As String = ""
                                    Dim strOrden As String = ""
                                    Dim types As New Dictionary(Of String, String)
                                    Dim i As Integer = 0
                                    Dim strSQL As String = ""
                                    Dim strSQL2 As String = ""
                                    Dim parami As Integer = 0

                                    For Each node In nodes
                                        campo = nvXMLUtiles.getAttribute_path(node, "@name", "Error")
                                        types.Add(campo, nvXMLUtiles.getAttribute_path(node, "s:datatype/@dt:type"))
                                        campos.Add(campo)
                                        strCampos &= ", [" & campo & "]"

                                        If nvXMLUtiles.getAttribute_path(node, "@pk", "false") = "true" Then
                                            pk.Add(campo)
                                            strWhere &= "and [" & campo & "] = ? "
                                            strOrden &= ", [" & campo & "]"
                                            i += 1
                                        End If
                                    Next


                                    ' Si no hay PK en la tabla --> no continuar
                                    If pk.Count = 0 Then Throw New Exception("No se puede cargar el objeto (" & Me.objeto & ") de la tabla " & tabla & " porque no tiene definida una o mas PK")

                                    If strCampos <> "" Then strCampos = strCampos.Substring(2)
                                    If strOrden <> "" Then strOrden = strOrden.Substring(2)
                                    If strWhere <> "" Then strWhere = strWhere.Substring(4)

                                    nodes = nvXMLUtiles.selectNodes(oXMl, "xml/rs:data/z:row")

                                    If nodes.Count = 0 Then
                                        Try
                                            nodes = nvXMLUtiles.selectNodes(oXMl, "xml/rs:data/rs:insert/z:row")
                                        Catch exNodes As Exception
                                        End Try
                                    End If


                                    ' Si no hay datos, no continuar
                                    If nodes.Count = 0 Then
                                        _bytes = Nothing
                                        _isBinaryLoad = False
                                    Else
                                        Dim cmd As nvDBUtiles.tnvDBCommand
                                        Dim valor As String
                                        Dim type As String
                                        Dim rsFila As ADODB.Recordset = Nothing
                                        Dim docXML As System.Xml.XmlDocument = Nothing
                                        Dim adoType As ADODB.DataTypeEnum
                                        Dim size As Integer
                                        Dim oValor As Object

                                        '-------------------------------------------------------------------
                                        '  ADODB Command -- Restrictions
                                        '-------------------------------------------------------------------
                                        '  2100 es la cant. maxima admitida de parametros en el ado command
                                        '
                                        '  Por lo tanto, limita la cantidad de registros que se pueden traer
                                        ' en una sola consulta.
                                        '  Si la cantidad de parametros supera 2100, hay que repetir la 
                                        ' consulta y traer los registros de datos en bloques.
                                        '
                                        '  En la practica, admite 2098 parametros como maximo
                                        '-------------------------------------------------------------------
                                        Dim MaxRegistrosPorCiclo As Integer = Math.Floor(2098 / pk.Count)
                                        Dim registrosPorCiclo = Math.Min(MaxRegistrosPorCiclo, nodes.Count)

                                        If registrosPorCiclo = 0 Then Throw New Exception("Objeto dato sin registros: " & Me.objeto)

                                        Dim ciclos As Integer = Math.Ceiling(nodes.Count / registrosPorCiclo)
                                        Dim j As Integer

                                        For j = 0 To registrosPorCiclo - 1
                                            strWhere2 &= " or (" & strWhere & ")"
                                        Next

                                        If strWhere2 <> "" Then strWhere2 = strWhere2.Substring(4)

                                        Dim numreg As Integer
                                        Dim k As Integer

                                        For k = 0 To ciclos - 1
                                            ' Si se ejecuta mas de un ciclo, el ultimo puede traer menos registros
                                            If ciclos > 1 AndAlso k = ciclos - 1 Then
                                                numreg = nodes.Count Mod registrosPorCiclo
                                                strWhere2 = ""

                                                For j = 0 To numreg - 1
                                                    strWhere2 &= " or (" & strWhere & ")"
                                                Next

                                                If strWhere2 <> "" Then strWhere2 = strWhere2.Substring(4)
                                            End If

                                            ' No quitar las sentencias begin y end. Estan puestas para que ado command no agregue automaticamente
                                            ' un parametro cuando encuentra el simbolo "?"
                                            strSQL2 = "begin Select " & strCampos & " from " & tabla & " where " & strWhere2 & " end "
                                            cmd = New nvDBUtiles.tnvDBCommand(strSQL2, ADODB.CommandTypeEnum.adCmdText, nvDBUtiles.emunDBType.db_other, nvcn:=nvcn)
                                            parami = 1
                                            Dim nod As System.Xml.XmlNode

                                            For j = k * registrosPorCiclo To (k + 1) * registrosPorCiclo - 1
                                                If j < nodes.Count Then
                                                    nod = nodes(j)

                                                    For Each campo In pk
                                                        parami += 1
                                                        valor = nvXMLUtiles.getAttribute_path(nod, "@" & campo, Nothing)
                                                        type = types(campo)
                                                        oValor = nvConvertUtiles.StringToAdoParamObject(valor, type)
                                                        adoType = nvConvertUtiles.XMLTypeToAdoParamType(type)

                                                        Select Case adoType
                                                            Case ADODB.DataTypeEnum.adChar, ADODB.DataTypeEnum.adLongVarChar, ADODB.DataTypeEnum.adLongVarWChar, ADODB.DataTypeEnum.adVarChar, ADODB.DataTypeEnum.adVarWChar, ADODB.DataTypeEnum.adWChar, ADODB.DataTypeEnum.adBinary, ADODB.DataTypeEnum.adLongVarBinary, ADODB.DataTypeEnum.adVarBinary
                                                                size = oValor.length
                                                                cmd.Parameters.Append(cmd.CreateParameter("@param" & parami, adoType, ADODB.ParameterDirectionEnum.adParamInput, size, oValor))

                                                            Case Else
                                                                cmd.Parameters.Append(cmd.CreateParameter("@param" & parami, adoType, ADODB.ParameterDirectionEnum.adParamInput, , oValor))
                                                        End Select
                                                    Next
                                                Else
                                                    Exit For
                                                End If
                                            Next

                                            Dim rs1 As ADODB.Recordset = cmd.Execute()

                                            If rsFila Is Nothing Then
                                                rsFila = New ADODB.Recordset

                                                For n As Integer = 0 To rs1.Fields.Count - 1
                                                    rsFila.Fields.Append(rs1.Fields(n).Name, rs1.Fields(n).Type, rs1.Fields(n).DefinedSize, rs1.Fields(n).Attributes)
                                                Next

                                                rsFila.Open()
                                            End If

                                            While Not rs1.EOF
                                                rsFila.AddNew()

                                                For f As Integer = 0 To rs1.Fields.Count - 1
                                                    rsFila.Fields(f).Value = rs1.Fields(f).Value
                                                Next

                                                rs1.MoveNext()
                                            End While

                                            nvDBUtiles.DBCloseRecordset(rs1)
                                        Next

                                        Dim arParam As New trsParam
                                        docXML = nvXMLSQL.RecordsetToXML(rsFila, arParam, , pk)
                                        nvDBUtiles.DBCloseRecordset(rsFila)
                                        fecha_modificacion = Now()
                                        _bytes = nvConvertUtiles.StringToBytes(docXML.OuterXml)
                                        _isBinaryLoad = True
                                    End If
                                Catch ex As Exception
                                    _bytes = Nothing
                                    _isBinaryLoad = False
                                    Throw ex
                                End Try


                            Case Else
                                'Stop

                        End Select
                    Else
                        '**********************************
                        ' Cargar desde la DEFINICIÓN
                        '**********************************
                        If Me.cod_objeto <> 0 Then
                            Dim strSQL As String = "SELECT valor, hash, extension FROM nv_obj_binary WHERE cod_objeto=" & Me.cod_objeto
                            Dim rsObjBin As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)

                            If Not rsObjBin.EOF Then
                                Dim def As Byte() = Nothing

                                _bytes = If(IsDBNull(rsObjBin.Fields("valor").Value), def, rsObjBin.Fields("valor").Value)
                                _hash = If(IsDBNull(rsObjBin.Fields("hash").Value), def, rsObjBin.Fields("hash").Value)
                                _extension = If(IsDBNull(rsObjBin.Fields("extension").Value), "", rsObjBin.Fields("extension").Value)
                                _isBinaryLoad = True
                            End If

                            nvDBUtiles.DBCloseRecordset(rsObjBin)
                        End If
                    End If
                End If
            End Sub



            Private Shared Function _loadTableData(tableName As String, nvcn As tDBConection) As System.Xml.XmlDocument
                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(emunDBType.db_other, nvcn)
                ' Obtener todos los datos de la tabla
                Dim query As String = String.Format("SELECT * FROM {0}", tableName)
                Dim rsData As ADODB.Recordset = conn.Execute(query)
                Dim rParam As New trsParam()
                Dim oXMl As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rsData, rParam)

                nvDBUtiles.DBCloseRecordset(rsData, False)

                ' Buscar las PK de la tabla
                query = "select  C.name as pk, D.name as tipo" &
                        " from sys.indexes A" &
                        " inner join sys.index_columns B on A.object_id = B.object_id and B.index_id = A.index_id" &
                        " inner join sys.columns C on C.object_id=B.object_id and B.column_id = C.column_id" &
                        " inner join sys.types D on D.user_type_id = C.user_type_id  and D.is_user_defined=0" &
                        " where object_name(A.object_id)='" & tableName & "' and A.is_primary_key=1"

                Dim rsPK As ADODB.Recordset = conn.Execute(query)
                Dim element As System.Xml.XmlElement
                Dim attribute As System.Xml.XmlAttribute
                Dim primaryKey As String

                While Not rsPK.EOF
                    primaryKey = rsPK.Fields("pk").Value.ToString()
                    element = nvXMLUtiles.selectSingleNode(oXMl, "xml/s:Schema/s:ElementType/s:AttributeType[@name='" & primaryKey & "']")
                    attribute = oXMl.CreateAttribute("pk")
                    attribute.Value = "true"
                    element.Attributes.Append(attribute)

                    rsPK.MoveNext()
                End While

                nvDBUtiles.DBCloseRecordset(rsPK, False)
                conn.Close()

                Return oXMl
            End Function



            Public Sub SetValues(ByVal cod_obj_tipo As nvEnumObjeto_tipo, ByVal path As String, ByVal objeto As String, Optional ByVal cod_sub_tipo As Integer = 0, Optional binary As Byte() = Nothing)
                Me.objeto = objeto
                Me.cod_obj_tipo = cod_obj_tipo
                Me.modulo_version_path = path
                Me.modulo_version_cod_sub_tipo = cod_sub_tipo
                Me._bytes = binary
                Me._isBinaryLoad = True
                Me._isImplementation = False
                Me._hash = Nothing
                Me.cod_modulo_version = 0
            End Sub



            Public Sub loadFromImplementation(nvApp As tnvApp,
                                              cod_objeto_tipo As nvEnumObjeto_tipo,
                                              path As String,
                                              objeto As String,
                                              Optional cod_sub_tipo As Integer = 0,
                                              Optional chargeBinary As Boolean = False,
                                              Optional oBytes() As Byte = Nothing)

                _isImplementation = True
                Me.objeto = objeto
                Me.cod_obj_tipo = cod_objeto_tipo
                Me.implemantation_nvApp = nvApp
                Me.modulo_version_path = path
                Me.modulo_version_cod_sub_tipo = cod_sub_tipo
                Me._paramXML = ""

                If Not chargeBinary AndAlso (cod_objeto_tipo = nvEnumObjeto_tipo.datos OrElse cod_objeto_tipo = nvEnumObjeto_tipo.script_db) AndAlso Not oBytes Is Nothing Then
                    Me._paramXML = nvConvertUtiles.BytesToString(oBytes)
                    Me._bytes = oBytes
                    Me._isBinaryLoad = True
                End If

                _esGrupo = nvSicaObjetoGrupo.esGrupo(cod_objeto_tipo)

                If _esGrupo Then
                    Dim objetoGrupo As InvSicaObjetoGrupo = nvSICA.nvSicaObjetoGrupo.getObject(cod_objeto_tipo)
                    objetoGrupo.loadFromImplementation(Me, nvApp, cod_objeto_tipo, path, objeto, cod_sub_tipo, chargeBinary, oBytes)
                Else
                    Select Case cod_objeto_tipo
                        Case nvEnumObjeto_tipo.directorio
                            physical_path = nvSICA.path.LogicalToPhysical(nvApp, path & objeto)
                            _extension = ""

                        Case nvEnumObjeto_tipo.archivo
                            physical_path = nvSICA.path.LogicalToPhysical(nvApp, path & objeto)
                            _extension = IO.Path.GetExtension(physical_path)

                        Case nvEnumObjeto_tipo.vista, nvEnumObjeto_tipo.sp, nvEnumObjeto_tipo.funcion, nvEnumObjeto_tipo.tabla, nvEnumObjeto_tipo.datos
                            physical_path = ""
                            _extension = ""

                        Case nvEnumObjeto_tipo.script_db
                            physical_path = ""
                            _extension = ""
                            chargeBinary = False
                            fecha_modificacion = Now()
                            _bytes = bytes
                            _isBinaryLoad = True

                        Case nvEnumObjeto_tipo.grupo

                    End Select
                End If

                If chargeBinary Then _loadBinary()
            End Sub



            Public Sub loadModuloVersion(ByVal cod_modulo_version As Integer, ByVal path As String, Optional ByVal cod_pasaje As Integer = 0)
                Dim strSQL As String = "select * from nv_modulo_version_objetos where path='" & path & "' and cod_modulo_version = " & cod_modulo_version & " and cod_objeto = " & Me.cod_objeto & If(cod_pasaje > 0, " and cod_pasaje = " & cod_pasaje, " and cod_pasaje = 0 ")
                Dim rsObj As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
                Me.cod_modulo_version = cod_modulo_version
                Me.modulo_version_path = rsObj.Fields("path").Value
                Me.modulo_version_cod_sub_tipo = rsObj.Fields("cod_sub_tipo").Value
                Me.modulo_version_depende_de = If(IsDBNull(rsObj.Fields("depende_de").Value), 0, rsObj.Fields("depende_de").Value)
                Me.modulo_version_cod_pasaje = If(IsDBNull(rsObj.Fields("cod_pasaje").Value), 0, rsObj.Fields("cod_pasaje").Value)
                Me.modulo_version_fe_modificacion = rsObj.Fields("fe_mod").Value

                nvDBUtiles.DBCloseRecordset(rsObj)
                loadChilds()
            End Sub



            Public Sub loadModuloVersion(ByVal cod_modulo_version As Integer, ByVal path As String, ByVal cod_sub_tipo As Integer, ByVal depende_de As Object, ByVal cod_pasaje As Object, ByVal fe_modificacion As DateTime)
                Me.cod_modulo_version = cod_modulo_version
                Me.modulo_version_path = path
                Me.modulo_version_cod_sub_tipo = cod_sub_tipo
                Me.modulo_version_depende_de = If(IsDBNull(depende_de), 0, depende_de)
                Me.modulo_version_cod_pasaje = If(IsDBNull(cod_pasaje), 0, cod_pasaje)
                Me.modulo_version_fe_modificacion = fe_modificacion
                loadChilds()
            End Sub



            Public Sub loadChilds()
                ' Cargar elementos dependientes
                If Not _isImplementation Then
                    Dim strsql As String = String.Format("SELECT * FROM nv_modulo_version_objetos WHERE cod_modulo_version={0} AND depende_de={1} AND cod_pasaje={2}", cod_modulo_version, Me.cod_objeto, Me.modulo_version_cod_pasaje)
                    Dim rsObj As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strsql)
                    Dim objChild As tSicaObjeto

                    While Not rsObj.EOF
                        objChild = New tSicaObjeto
                        objChild.loadFromDefinition(rsObj.Fields("cod_objeto").Value)
                        objChild.modulo_version_depende_de = Me.cod_objeto
                        objChild.cod_modulo_version = cod_modulo_version
                        objChild.modulo_version_path = rsObj.Fields("path").Value
                        objChild.modulo_version_cod_sub_tipo = rsObj.Fields("cod_sub_tipo").Value
                        objChild.modulo_version_depende_de = If(IsDBNull(rsObj.Fields("depende_de").Value), 0, rsObj.Fields("depende_de").Value)
                        objChild.modulo_version_cod_pasaje = If(IsDBNull(rsObj.Fields("cod_pasaje").Value), 0, rsObj.Fields("cod_pasaje").Value)
                        objChild.modulo_version_fe_modificacion = rsObj.Fields("fe_mod").Value
                        objChild.loadChilds()
                        Me.childObjects.Add(objChild)

                        rsObj.MoveNext()
                    End While

                    nvDBUtiles.DBCloseRecordset(rsObj)
                End If
            End Sub



            Public Function existImplementation(Optional nvApp As tnvApp = Nothing, Optional ByVal cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo = 0, Optional ByVal modulo_version_path As String = "", Optional ByVal objeto As String = "") As Boolean
                If implemantation_nvApp Is Nothing AndAlso nvApp IsNot Nothing Then implemantation_nvApp = nvApp
                If Me.cod_obj_tipo = 0 AndAlso cod_obj_tipo <> 0 Then Me.cod_obj_tipo = cod_obj_tipo
                If Me.modulo_version_path = "" AndAlso modulo_version_path <> "" Then Me.modulo_version_path = modulo_version_path
                If Me.objeto = "" AndAlso objeto <> "" Then Me.objeto = objeto

                Return Implementation.exist(Me.implemantation_nvApp, Me.cod_obj_tipo, Me.modulo_version_path, Me.objeto, Me.bytes)
            End Function



            Public Function checkIntegrity(rescab As tResCab, nvApp As tnvApp) As nvenumResStatus
                Dim parent_path As String
                Dim ParamRelPath As String
                Dim ParamRel As String
                Dim filename As String
                Dim path As String
                Dim cod_sub_tipo As Integer
                Dim strSQL As String
                Dim rsDir As ADODB.Recordset
                Dim rsFile As ADODB.Recordset
                Dim files() As IO.FileInfo
                Dim directories() As IO.DirectoryInfo
                Dim res As nvenumResStatus = nvenumResStatus.OK
                Dim resElement As New tResElement
                resElement.cod_objeto = Me.cod_objeto
                resElement.cod_obj_tipo = Me.cod_obj_tipo
                resElement.path = Me.modulo_version_path
                resElement.cod_sub_tipo = Me.modulo_version_cod_sub_tipo
                resElement.objeto = Me.objeto
                resElement.cod_modulo_version = cod_modulo_version
                resElement.cod_pasaje = Me.modulo_version_cod_pasaje
                resElement.comentario = ""
                resElement.depende_de = Me.modulo_version_depende_de

                Me.implemantation_nvApp = nvApp

                ' Recuperar implementacion
                Dim oSicaImplementacion As New tSicaObjeto

                If Me.cod_obj_tipo = nvEnumObjeto_tipo.datos Then
                    oSicaImplementacion.loadFromImplementation(Me.implemantation_nvApp, Me.cod_obj_tipo, Me.modulo_version_path, Me.objeto, Me.modulo_version_cod_sub_tipo, True, Me.bytes)
                Else
                    oSicaImplementacion.loadFromImplementation(Me.implemantation_nvApp, Me.cod_obj_tipo, Me.modulo_version_path, Me.objeto, Me.modulo_version_cod_sub_tipo, True)
                End If

                If oSicaImplementacion.bytes Is Nothing Then
                    resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                    rescab.elements.Add(resElement)
                    res = nvenumResStatus.objeto_no_econtrado
                Else
                    If _esGrupo Then
                        Dim objetoGrupo As InvSicaObjetoGrupo = nvSicaObjetoGrupo.getObject(cod_obj_tipo)
                        res = objetoGrupo.checkIntegrity(Me, rescab, nvApp)

                        If res <> nvenumResStatus.OK Then
                            If rescab.elements.Count >= 1 Then
                                Dim resElement2 As tResElement = rescab.elements.Last()
                                resElement.comentario = resElement2.comentario
                                rescab.elements.Remove(resElement2)
                            End If

                            resElement.resStatus = res
                            rescab.elements.Add(resElement)
                        Else
                            ' Limpiar lista para que no muestre los que estan OK (no hace falta)
                            Dim lastPosition As Integer = If(rescab.elements.Count > 0, rescab.elements.Count - 1, 0)
                            If lastPosition > 0 Then rescab.elements.RemoveAt(lastPosition)
                        End If
                    Else
                        Select Case Me.cod_obj_tipo
                            Case nvEnumObjeto_tipo.tabla, nvEnumObjeto_tipo.vista, nvEnumObjeto_tipo.sp, nvEnumObjeto_tipo.archivo, nvEnumObjeto_tipo.funcion, nvEnumObjeto_tipo.grupo, nvEnumObjeto_tipo.script_db
                                If Me.cod_obj_tipo = nvEnumObjeto_tipo.tabla Then
                                    Dim resElement2 As tResElement = checkXmlTable(Me.cod_objeto, oSicaImplementacion.bytes)  'oSicaImplementacion.checkIntegrity(rescab, nvApp, cod_pasaje)
                                    resElement.resStatus = resElement2.resStatus
                                    resElement.comentario = resElement2.comentario

                                    If resElement.resStatus <> nvenumResStatus.OK Then rescab.elements.Add(resElement)
                                    res = resElement.resStatus
                                Else
                                    If Me.cod_objeto = 0 Then   ' No está en definicion
                                        resElement.resStatus = nvenumResStatus.archivo_sobrante
                                        rescab.elements.Add(resElement)
                                        res = nvenumResStatus.archivo_sobrante
                                    ElseIf Not Implementation.checkBinary(Me.cod_objeto, oSicaImplementacion.bytes) Then
                                        resElement.resStatus = nvenumResStatus.objeto_modificado
                                        rescab.elements.Add(resElement)
                                        res = nvenumResStatus.objeto_modificado
                                    End If
                                End If


                            Case nvEnumObjeto_tipo.datos
                                ' Comparar ambos binarios y devolver el resultado
                                ' Si ningun dato existe:                        nvenumResStatus.objeto_no_econtrado
                                ' si existen todos y son iguales:               nvenumResStatus.OK
                                ' Si existen algunos de las PK y son distintas: nvenumResStatus.objeto_modificado
                                Dim strXML As String = nvConvertUtiles.BytesToString(Me.bytes)
                                Dim oXmlDef As New System.Xml.XmlDocument
                                oXmlDef.LoadXml(strXML)

                                strXML = nvConvertUtiles.BytesToString(oSicaImplementacion.bytes)
                                Dim oXmlImp As New System.Xml.XmlDocument
                                oXmlImp.LoadXml(strXML)

                                Dim nodesDef As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlDef, "xml/rs:data/z:row")
                                If nodesDef.Count = 0 Then nodesDef = nvXMLUtiles.selectNodes(oXmlDef, "xml/rs:data/rs:insert/z:row")

                                Dim nodesImp As System.Xml.XmlNodeList
                                'Dim nodesPK As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlImp, "xml/s:Schema/s:ElementType/s:AttributeType[@pk='true']")
                                'Dim nodesFields As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlImp, "xml/s:Schema/s:ElementType/s:AttributeType")

                                ' PK y columnas --> obtener desde DEFINICION
                                ' Ésto es así porque podríamos haber definido otra/s PKs diferente a la que está por defecto o no tener una y definirla nosotros;
                                ' además podríamos haber definido el dato habiendo seleccionado solo algunas columnas en lugar de la totalidad
                                Dim nodesPK As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlDef, "xml/s:Schema/s:ElementType/s:AttributeType[@pk='true']")
                                Dim nodesFields As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlDef, "xml/s:Schema/s:ElementType/s:AttributeType")

                                Dim nodePK As System.Xml.XmlNode
                                Dim iguales As Boolean = True
                                Dim xPtah As String
                                Dim encontrados As Integer = 0
                                Dim count_distintos As Integer = 0
                                Dim table As String = resElement.path.Split("\")(1)


                                For i = 0 To nodesDef.Count - 1
                                    xPtah = ""
                                    Dim attributeNamePK As String = ""

                                    Try
                                        If nodesPK.Count = 0 Then Throw New Exception("La tabla " & table & " no tiene definida ninguan PK.")

                                        For Each nodePK In nodesPK
                                            attributeNamePK = nodePK.Attributes("name").Value

                                            If xPtah = "" Then
                                                xPtah &= "@" & attributeNamePK & "='" & nodesDef(i).Attributes(attributeNamePK).Value & "'"
                                            Else
                                                xPtah &= " and @" & attributeNamePK & "='" & nodesDef(i).Attributes(attributeNamePK).Value & "'"
                                            End If
                                        Next
                                    Catch ex As Exception
                                        Throw New Exception("No se encontró el atributo de clave primaria (PK: " & attributeNamePK & ") en los nodos de Definición (tabla: " & table & ").", ex)
                                    End Try

                                    nodesImp = nvXMLUtiles.selectNodes(oXmlImp, "xml/rs:data/z:row[" & xPtah & "]")
                                    If nodesImp.Count = 0 Then nodesImp = nvXMLUtiles.selectNodes(oXmlImp, "xml/rs:data/rs:insert/z:row[" & xPtah & "]")

                                    If nodesImp.Count > 0 Then
                                        encontrados += 1
                                        iguales = True
                                        Dim attributeName As String

                                        For Each nodePK In nodesFields
                                            attributeName = nodePK.Attributes("name").Value

                                            If nodesDef(i).Attributes(attributeName) Is Nothing OrElse nodesImp(0).Attributes(attributeName) Is Nothing Then
                                                If Not nodesDef(i).Attributes(attributeName) Is Nothing OrElse Not nodesImp(0).Attributes(attributeName) Is Nothing Then
                                                    Dim definicionIsNull As Boolean = IsDBNull(nodesDef(i).Attributes(attributeName)) OrElse nodesDef(i).Attributes(attributeName) Is Nothing
                                                    resElement.comentario &= table & "@" & attributeName & ": valor nulo en " & If(definicionIsNull, "definición", "implementación") & "</br>"
                                                    iguales = False
                                                    Exit For
                                                End If
                                            Else
                                                If nodesDef(i).Attributes(attributeName).Value <> nodesImp(0).Attributes(attributeName).Value Then
                                                    resElement.comentario &= table & "@" & attributeName & ": difiere entre definición (" & nodesDef(i).Attributes(attributeName).Value & ") e implementación (" & nodesImp(0).Attributes(attributeName).Value & ")</br>"
                                                    iguales = False
                                                    Exit For
                                                End If
                                            End If
                                        Next

                                        If Not iguales Then count_distintos += 1
                                    Else
                                        resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                                        res = nvenumResStatus.objeto_no_econtrado
                                    End If
                                Next


                                If encontrados = 0 Then
                                    resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                                    rescab.elements.Add(resElement)
                                    res = nvenumResStatus.objeto_no_econtrado
                                ElseIf count_distintos > 0 OrElse (encontrados <> nodesDef.Count) Then
                                    resElement.resStatus = nvenumResStatus.objeto_modificado
                                    rescab.elements.Add(resElement)
                                    res = nvenumResStatus.objeto_modificado
                                End If


                            Case nvEnumObjeto_tipo.directorio
                                ParamRel = nvSICA.path.getParamRel(rescab.nvApp, Me.modulo_version_path & Me.objeto)
                                ParamRelPath = nvSICA.path.getParamRelPath(rescab.nvApp, Me.modulo_version_path & Me.objeto)
                                Me.physical_path = nvSICA.path.LogicalToPhysical(Me.implemantation_nvApp, Me.modulo_version_path & Me.objeto)

                                If IO.Directory.Exists(ParamRelPath) Then
                                    If Me.modulo_version_cod_sub_tipo = 1 Then
                                        Dim dir As New IO.DirectoryInfo(Me.physical_path)
                                        Dim pila As New Stack(Of IO.DirectoryInfo)
                                        pila.Push(dir)

                                        While pila.Count > 0
                                            dir = pila.Pop
                                            '**************************************************************
                                            ' Controlar que la carpeta no tenga definido otro cod_sub_tipo
                                            '**************************************************************
                                            parent_path = dir.Parent.FullName & "\"
                                            parent_path = parent_path.Replace(ParamRelPath, ParamRel)
                                            cod_sub_tipo = 1
                                            strSQL = "SELECT * FROM nv_modulo_version_objetos mo JOIN nv_objetos o ON mo.cod_objeto = o.cod_objeto WHERE mo.cod_modulo_version=" & cod_modulo_version & " AND path='" & parent_path & "' AND objeto='" & dir.Name & "'"
                                            rsDir = nvDBUtiles.ADMDBOpenRecordset(strSQL)

                                            Try
                                                cod_sub_tipo = rsDir.Fields("cod_sub_tipo").Value
                                            Catch ex2 As Exception
                                            Finally
                                                nvDBUtiles.DBCloseRecordset(rsDir)
                                            End Try

                                            ' Si tiene cod_sub_tipo = 2 (datos) no se debe chequear el contenido de la carpeta
                                            If cod_sub_tipo = 2 Then Continue While

                                            directories = dir.GetDirectories("*.*")

                                            For i = LBound(directories) To UBound(directories)
                                                pila.Push(directories(i))
                                            Next

                                            files = dir.GetFiles("*.*")

                                            For i = LBound(files) To UBound(files)
                                                path = files(i).DirectoryName & "\"
                                                path = path.Replace(ParamRelPath, ParamRel)
                                                filename = files(i).Name
                                                strSQL = "SELECT * FROM nv_modulo_version_objetos mo JOIN nv_objetos o ON mo.cod_objeto = o.cod_objeto WHERE mo.cod_modulo_version=" & cod_modulo_version & " AND path='" & path & "' AND objeto='" & filename & "'"
                                                rsFile = nvDBUtiles.ADMDBOpenRecordset(strSQL)

                                                If rsFile.EOF Then
                                                    resElement = New tResElement
                                                    resElement.cod_modulo_version = cod_modulo_version
                                                    resElement.cod_obj_tipo = tSicaObjeto.nvEnumObjeto_tipo.archivo
                                                    resElement.objeto = filename
                                                    resElement.path = path
                                                    resElement.resStatus = nvenumResStatus.archivo_sobrante ' = "Sobra archivo en carpeta de codigo"
                                                    rescab.elements.Add(resElement)
                                                End If
                                            Next
                                        End While
                                    End If
                                End If
                        End Select
                    End If
                End If

                Return res
            End Function



            Public Shared Function checkXmlTable(ByVal cod_objeto As Integer, ByVal binario_implementacion As Byte()) As tResElement
                Dim resultado As New tResElement

                ' Si no esta el cod_objeto salir (objeto no está presente en la definición)
                If cod_objeto = 0 Then
                    resultado.cod_objeto = cod_objeto
                    resultado.resStatus = nvenumResStatus.archivo_sobrante
                    Return resultado
                End If

                Dim msg_diferencias As String = ""
                Dim estado As nvenumResStatus = nvenumResStatus.OK
                resultado.cod_objeto = cod_objeto
                resultado.cod_obj_tipo = nvEnumObjeto_tipo.tabla

                ' Recuperar todos los binarios
                '   Binario Definicion:     binario_definicion
                '   Binario Implementacion: binario_implementacion
                Dim strSQL As String = "SELECT valor FROM nv_obj_binary WHERE cod_objeto=" & cod_objeto
                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBExecute(strSQL)
                Dim binario_definicion As Byte() = Nothing

                If Not rs.EOF Then binario_definicion = rs.Fields("valor").Value

                nvDBUtiles.DBCloseRecordset(rs)

                ' Si uno de los 2 binarios está vacío => salir por false
                If binario_definicion Is Nothing OrElse binario_implementacion Is Nothing Then
                    If binario_definicion Is Nothing Then msg_diferencias &= "La <b>definición</b> no cuenta con el binario asociado.<br/>"
                    If binario_implementacion Is Nothing Then msg_diferencias &= "La <b>implementación</b> no cuenta con su binario.<br/>"

                    resultado.comentario = msg_diferencias
                    resultado.resStatus = nvenumResStatus.objeto_no_econtrado
                    Return resultado
                End If

                ' Cargar objetos XML desde los String XML (convertidos desde sus binarios)
                Dim oXmlDefinicion As New System.Xml.XmlDocument
                Dim oXmlImplementacion As New System.Xml.XmlDocument

                Try
                    oXmlDefinicion.LoadXml(nvConvertUtiles.BytesToString(binario_definicion))
                    oXmlImplementacion.LoadXml(nvConvertUtiles.BytesToString(binario_implementacion))
                Catch ex As Exception
                    estado = nvenumResStatus.objeto_modificado
                    msg_diferencias &= "No se pueden cargar los XML de tabla (para definición y/o implementación) para la comparación.<br/>"

                    resultado.resStatus = estado
                    resultado.comentario = msg_diferencias
                    Return resultado
                End Try

                ' Recorrer todas las columnas del XML partiendo de la definicion
                Dim columnasDefinicion As System.Xml.XmlNodeList
                Dim columnasImplementacion As System.Xml.XmlNodeList

                ' Cargar columnas de la Definicion
                Try
                    columnasDefinicion = nvXMLUtiles.selectNodes(oXmlDefinicion, "table/columns/column")
                Catch ex As Exception
                    columnasDefinicion = Nothing
                End Try

                ' Cargar columnas de la Implementacion
                Try
                    columnasImplementacion = nvXMLUtiles.selectNodes(oXmlImplementacion, "table/columns/column")
                Catch ex As Exception
                    columnasImplementacion = Nothing
                End Try

                ' Comparar si todas las columnas de Definición están en Implementación y viceversa
                ' Cols Definicion <---> Cols Implementacion 
                Dim columnasComun As New List(Of String)
                Dim columnasSolo_definicion As New List(Of String)
                Dim columnasSolo_implementacion As New List(Of String)
                Dim colName_tmp As String

                ' Busqueda 1: desde definicion contra implementacion
                For Each columnaDef As System.Xml.XmlNode In columnasDefinicion
                    colName_tmp = columnaDef.Attributes("name").Value

                    For Each columnaImp As System.Xml.XmlNode In columnasImplementacion
                        If columnaImp.Attributes("name").Value.Equals(colName_tmp) Then
                            columnasComun.Add(colName_tmp)
                            Exit For
                        End If
                    Next

                    If Not columnasComun.Contains(colName_tmp) Then columnasSolo_definicion.Add(colName_tmp)
                Next

                ' Busqueda 2: desde implementacion contra definicion
                For Each columnaImp As System.Xml.XmlNode In columnasImplementacion
                    colName_tmp = columnaImp.Attributes("name").Value

                    For Each columnaDef As System.Xml.XmlNode In columnasDefinicion
                        If columnaDef.Attributes("name").Value.Equals(colName_tmp) Then
                            If Not columnasComun.Contains(colName_tmp) Then columnasComun.Add(colName_tmp)
                            Exit For
                        End If
                    Next

                    If Not columnasComun.Contains(colName_tmp) Then columnasSolo_implementacion.Add(colName_tmp)
                Next


                ' Verificar si hay columnas sólo en Definición
                If columnasSolo_definicion.Count > 0 Then
                    msg_diferencias &= "Las siguientes columnas están presentes sólo en <b>Definición</b><br/>"
                    msg_diferencias &= "<ul>"

                    For Each columna As String In columnasSolo_definicion
                        msg_diferencias &= "<li>" & columna & "</li>"
                    Next

                    msg_diferencias &= "</ul><br/>"
                    estado = nvenumResStatus.objeto_modificado
                End If

                ' Verificar si hay columnas sólo en Implementación
                If columnasSolo_implementacion.Count > 0 Then
                    msg_diferencias &= "Las siguientes columnas están presentes sólo en <b>Implementación</b><br/>"
                    msg_diferencias &= "<ul>"

                    For Each columna As String In columnasSolo_implementacion
                        msg_diferencias &= "<li>" & columna & "</li>"
                    Next

                    msg_diferencias &= "</ul><br/>"
                    estado = nvenumResStatus.objeto_modificado
                End If


                ' Comparar todas las columnas en comun (entre definición e implementación)
                Dim columnaDefinicion As System.Xml.XmlNode
                Dim columnaImplementacion As System.Xml.XmlNode
                Dim cantAttrDefinicion As Integer
                Dim cantAttrImplementacion As Integer
                Dim attrDefinicion As System.Xml.XmlAttribute
                Dim attrImplementacion As System.Xml.XmlAttribute
                Dim attrValueDef As String
                Dim attrValueImp As String
                Dim cantidadAtributos As Integer


                For Each colName As String In columnasComun
                    columnaDefinicion = nvXMLUtiles.selectSingleNode(oXmlDefinicion, "table/columns/column[@name='" & colName & "']")
                    columnaImplementacion = nvXMLUtiles.selectSingleNode(oXmlImplementacion, "table/columns/column[@name='" & colName & "']")

                    ' Comparar atributo por atributo para la columna
                    cantAttrDefinicion = columnaDefinicion.Attributes.Count
                    cantAttrImplementacion = columnaImplementacion.Attributes.Count

                    ' Verificar si tienen la misma cantidad de atributos (muy raro que suceda, podría darse por un cambio de versión en motor SQL, pero muy raro)
                    If cantAttrDefinicion <> cantAttrImplementacion Then
                        estado = nvenumResStatus.objeto_modificado
                        msg_diferencias &= "<b>" & colName & "</b>: cantidad de atributos difiere entre definición (" & cantAttrDefinicion & ") e implementación (" & cantAttrImplementacion & ").<br/>"
                        cantidadAtributos = If(cantAttrDefinicion > cantAttrImplementacion, cantAttrDefinicion, cantAttrImplementacion)
                    Else
                        cantidadAtributos = cantAttrDefinicion ' aca puede ir cualquiera porque son iguales
                    End If

                    For pos As Integer = 0 To cantidadAtributos - 1
                        Try
                            attrDefinicion = columnaDefinicion.Attributes.ItemOf(pos)
                            attrImplementacion = columnaImplementacion.Attributes.ItemOf(attrDefinicion.Name)

                            attrValueDef = attrDefinicion.Value
                            attrValueImp = attrImplementacion.Value

                            If Not attrValueDef.Equals(attrValueImp) Then
                                msg_diferencias &= "<b>" & colName & "</b>: el atributo <b>@" & attrDefinicion.Name & "</b> difiere entre definición (" & attrValueDef & ") e implementación (" & attrValueImp & ")<br/>"
                                estado = nvenumResStatus.objeto_modificado
                            End If
                        Catch ex As Exception
                            msg_diferencias &= "<b>" & colName & "</b>: Error al comparar atributos, debido a que el mismo no está en una de las columnas.<br/>"
                            estado = nvenumResStatus.objeto_modificado
                        End Try
                    Next
                Next


                resultado.resStatus = estado
                resultado.comentario = msg_diferencias
                Return resultado
            End Function



            Public Sub saveToDefinition(ByVal cod_modulo_version As Integer, Optional ByVal cod_pasaje As Integer = 0, Optional ByVal depende_de As Integer = 0, Optional ByVal cn As ADODB.Connection = Nothing, Optional ByVal es_baja As Boolean = False)
                If cod_pasaje > 0 Then Me.modulo_version_cod_pasaje = cod_pasaje
                If depende_de > 0 Then modulo_version_depende_de = depende_de

                Me.es_baja = es_baja

                If Me.cod_objeto = 0 Then
                    Dim cmd As New nvDBUtiles.tnvDBCommand("sica_objeto_insertar", commandType:=ADODB.CommandTypeEnum.adCmdStoredProc, db_type:=nvDBUtiles.emunDBType.db_admin, cn:=cn)
                    cmd.addParameter("@objeto", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, objeto.Length, Me.objeto)
                    cmd.addParameter("@cod_obj_tipo", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 0, Me.cod_obj_tipo)

                    If Me.size <> 0 Then
                        cmd.addParameter("@valor", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, _bytes.Length, _bytes)
                    End If

                    cmd.addParameter("@ext", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, Me.extension)
                    cmd.addParameter("@fecha_modificacion", ADODB.DataTypeEnum.adDBTimeStamp, ADODB.ParameterDirectionEnum.adParamInput, -1, Me.fecha_modificacion)

                    Dim rsObjeto As ADODB.Recordset = cmd.Execute(noDBClose:=Not cn Is Nothing)

                    If Not rsObjeto.EOF Then
                        Me.cod_objeto = rsObjeto.Fields(0).Value
                        'Dim objeto_existia As Boolean = rsObjeto.Fields(1).Value
                    End If

                    If cn Is Nothing Then
                        nvDBUtiles.DBCloseRecordset(rsObjeto)
                    Else
                        rsObjeto.Close()
                    End If
                End If

                If cod_modulo_version > 0 Then
                    Dim cmd2 As New nvDBUtiles.tnvDBCommand("sica_modulo_version_objeto_insertar", commandType:=ADODB.CommandTypeEnum.adCmdStoredProc, db_type:=nvDBUtiles.emunDBType.db_admin, cn:=cn)
                    cmd2.Parameters("@operador").Value = nvFW.nvApp.getInstance().operador.operador
                    cmd2.Parameters("@cod_objeto").Value = Me.cod_objeto
                    cmd2.Parameters("@cod_modulo_version").Value = cod_modulo_version
                    cmd2.Parameters("@path").Value = Me.modulo_version_path
                    cmd2.Parameters("@cod_sub_tipo").Value = Me.modulo_version_cod_sub_tipo

                    If modulo_version_cod_pasaje > 0 Then cmd2.Parameters("@cod_pasaje").Value = modulo_version_cod_pasaje
                    If modulo_version_depende_de > 0 Then cmd2.Parameters("@depende_de").Value = modulo_version_depende_de
                    If Me.es_baja Then cmd2.Parameters("@es_baja").Value = es_baja

                    Dim rsOut As ADODB.Recordset = cmd2.Execute(noDBClose:=Not cn Is Nothing)

                    If rsOut.State <> 0 Then rsOut.Close()
                End If

                Dim sicaObjectChild As tSicaObjeto

                For Each sicaObjectChild In Me.childObjects
                    sicaObjectChild.saveToDefinition(cod_modulo_version:=cod_modulo_version, cod_pasaje:=cod_pasaje, depende_de:=Me.cod_objeto, cn:=cn, es_baja:=Me.es_baja)
                Next
            End Sub



            Public Sub saveToImplementation(Optional ByVal nvApp As tnvApp = Nothing, Optional ByVal _modulo_version_path As String = "", Optional ByVal _objeto As String = "")
                If implemantation_nvApp Is Nothing AndAlso nvApp IsNot Nothing Then implemantation_nvApp = nvApp
                If Me.modulo_version_path = "" AndAlso _modulo_version_path <> "" Then Me.modulo_version_path = _modulo_version_path
                If Me.objeto = "" AndAlso _objeto <> "" Then Me.objeto = _objeto

                Dim classObject As InvSicaObjetoGrupo = nvSicaObjetoGrupo.getObject(Me.cod_obj_tipo)

                If Not classObject Is Nothing AndAlso classObject.hasImplementation Then
                    classObject.saveToImplementation(Me, nvApp)
                Else
                    Implementation.objeto_agregar(Me.cod_objeto, Me.cod_obj_tipo, Me.implemantation_nvApp, Me.modulo_version_path, Me.objeto, Me.bytes)

                    For Each child As tSicaObjeto In Me.childObjects
                        Implementation.objeto_agregar(child.cod_objeto, child.cod_obj_tipo, Me.implemantation_nvApp, child.modulo_version_path, child.objeto, child.bytes)
                    Next
                End If
            End Sub



            Public Sub removeFromDefinition(Optional ByVal cod_modulo_version As Integer = 0, Optional ByVal cod_objeto As String = "", Optional ByVal modulo_version_path As String = "")
                If cod_modulo_version <> 0 Then Me.cod_modulo_version = cod_modulo_version
                If cod_objeto <> "" Then Me.cod_objeto = cod_objeto
                If modulo_version_path <> "" Then Me.modulo_version_path = modulo_version_path

                Definition.objeto_eliminar(Me.cod_modulo_version, Me.cod_objeto, Me.modulo_version_path)
            End Sub



            Public Sub removeFromImplementation()
                Dim child As tSicaObjeto

                While childObjects.Count > 0
                    child = childObjects(childObjects.Count - 1)
                    Implementation.objeto_eliminar(implemantation_nvApp, child.cod_obj_tipo, child.modulo_version_path, child.objeto, child.modulo_version_cod_sub_tipo)
                End While

                Implementation.objeto_eliminar(implemantation_nvApp, cod_obj_tipo, modulo_version_path, objeto, modulo_version_cod_sub_tipo)
            End Sub



            Private Function _GetTablasScript(ByVal nvcn As tDBConection, ByVal tabla As String) As String
                Dim sql_cn_builder As Data.SqlClient.SqlConnectionStringBuilder = utiles.cnstringToSqlConnectionStringBuilder(nvcn.cn_string)
                Dim sqlConnection As New Data.SqlClient.SqlConnection(sql_cn_builder.ConnectionString)
                Dim ServerConnection As New Microsoft.SqlServer.Management.Common.ServerConnection(sqlConnection)
                Dim serv As New Microsoft.SqlServer.Management.Smo.Server(ServerConnection)
                Dim db As Microsoft.SqlServer.Management.Smo.Database = serv.Databases(sql_cn_builder("Initial Catalog"))

                Dim opt As New Microsoft.SqlServer.Management.Smo.ScriptingOptions
                opt.DriAll = True
                opt.IncludeHeaders = False
                opt.Default = True
                opt.WithDependencies = False
                opt.Indexes = False
                opt.Triggers = False
                opt.ClusteredIndexes = False
                opt.ExtendedProperties = False
                opt.IncludeDatabaseContext = False
                opt.FullTextCatalogs = False
                opt.FullTextIndexes = False
                opt.FullTextStopLists = False
                opt.Permissions = False
                opt.Statistics = False
                opt.AppendToFile = True
                opt.ToFileOnly = False

                Dim scr As New Microsoft.SqlServer.Management.Smo.Scripter
                scr.Server = serv
                scr.Options = opt
                Dim script As String

                Try
                    Dim table As Microsoft.SqlServer.Management.Smo.Table = db.Tables(tabla)
                    Dim smoObjects() As Microsoft.SqlServer.Management.Sdk.Sfc.Urn = New Microsoft.SqlServer.Management.Sdk.Sfc.Urn(0) {}
                    smoObjects(0) = table.Urn
                    Dim stringsCollection As StringCollection = scr.Script(smoObjects)
                    Dim str_final As String = ""
                    Dim strRegCreate As String = "create table"
                    Dim strRegAlter As String = "alter table"
                    Dim strRegSet As String = "^set\s"
                    Dim regCreate As New Regex(strRegCreate, RegexOptions.IgnoreCase)
                    Dim regAlter As New Regex(strRegAlter, RegexOptions.IgnoreCase)
                    Dim regSet As New Regex(strRegSet, RegexOptions.IgnoreCase)

                    For Each str As String In stringsCollection
                        If regCreate.IsMatch(str) OrElse regAlter.IsMatch(str) OrElse regSet.IsMatch(str) Then
                            str_final &= str & vbNewLine & "GO" & vbNewLine
                        End If
                    Next

                    script = str_final
                Catch ex As Exception
                    Throw ex
                End Try

                Return script
            End Function



            Private Function GetTablasXml(ByVal nvcn As tDBConection, ByVal tabla As String) As String
                Dim strXml As String

                If nvcn Is Nothing OrElse tabla = String.Empty Then
                    strXml = ""
                Else
                    Dim strSQL As String = "SELECT " &
                                                "c.name, c.column_id, c.system_type_id, t.name as system_type_name, c.max_length, c.precision, c.scale, " &
                                                "case when c.collation_name is null then '' else c.collation_name end AS collation_name, " &
                                                "c.is_nullable, c.is_ansi_padded, c.is_rowguidcol, c.is_identity, c.is_computed, c.is_filestream, " &
                                                "c.is_replicated, c.is_non_sql_subscribed, c.is_merge_published, c.is_dts_replicated, c.is_xml_document, " &
                                                "c.xml_collection_id, c.default_object_id, c.rule_object_id, c.is_sparse, c.is_column_set " &
                                           "FROM sys.columns c " &
                                               "INNER JOIN sys.types t ON t.system_type_id = c.system_type_id AND t.user_type_id = c.user_type_id " &
                                           "WHERE object_id = OBJECT_ID('" & tabla & "')"

                    Dim rs As ADODB.Recordset = nvDBUtiles.pvDBOpenRecordset(emunDBType.db_other, strSQL, _nvcn:=nvcn)
                    Dim xmlDoc As New System.Xml.XmlDocument
                    Dim tableElement As System.Xml.XmlElement = xmlDoc.CreateElement("table")
                    tableElement.SetAttribute("name", tabla)
                    ' Nodo columns
                    Dim columnsNode As System.Xml.XmlNode = xmlDoc.CreateElement("columns")
                    ' Obtenemos el XML desde ADO. nos quedamos solamente con los "z:row"
                    Dim oXml As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rs, New trsParam)
                    Dim rows As System.Xml.XmlNode = nvXMLUtiles.selectSingleNode(oXml, "xml/rs:data")
                    columnsNode.InnerXml = rows.InnerXml.Replace("z:row", "column") ' Reemplazar los tags z:row porque luego se rompe al no tener el namespace "z"
                    ' Nodo creation_script
                    Dim creationScriptNode As System.Xml.XmlNode = xmlDoc.CreateElement("creation_script")
                    Dim cdata As System.Xml.XmlCDataSection = xmlDoc.CreateCDataSection(_GetTablasScript(nvcn, tabla))
                    creationScriptNode.AppendChild(cdata)
                    ' Agregar los nodos (columns, creation_script) a tableElement
                    tableElement.AppendChild(columnsNode)
                    tableElement.AppendChild(creationScriptNode)

                    strXml = tableElement.OuterXml
                End If

                Return strXml
            End Function



            Public Enum nvEnumObjeto_tipo
                tabla = 1
                vista = 2
                sp = 3
                directorio = 4
                archivo = 5
                funcion = 6
                transferencia = 7
                datos = 8
                permiso_grupo = 9
                grupo = 10
                script_db = 11
                pizarra = 12
                parametro = 13
            End Enum
        End Class
    End Namespace
End Namespace
