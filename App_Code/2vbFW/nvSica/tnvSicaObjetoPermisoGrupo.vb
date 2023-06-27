Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvSICA

        Public Class tnvSicaPermisoGrupo
            Implements InvSicaObjetoGrupo


            Public Shared cn_name As String = "default"


            Public Shared Function getRSXMLElements(nvApp As tnvApp, Optional filtro As String = "") As String
                ' filtro: si no está vacío, viene completo como "like '%valor_buscado%'" o "not like '%valor_a_excluir%'"
                If cn_name = String.Empty Then cn_name = "default"

                Dim nvcn As tDBConection = nvApp.app_cns(cn_name).clone()
                nvcn.excaslogin = False

                Dim strSQL As String = "SELECT permiso_grupo AS objeto," &
                                              "'" & cn_name & "\' + permiso_grupo AS path," &
                                              "'' AS comentario," &
                                              "0 AS cod_sub_tipo " &
                                        "FROM operador_permiso_grupo " &
                                        If(filtro <> String.Empty, " WHERE permiso_grupo " & filtro, "")

                Dim rs As ADODB.Recordset

                Try
                    rs = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, _nvcn:=nvcn)
                Catch ex As Exception
                    Throw New Exception(ex.Message & "</br>Compruebe que la tabla (operador_permiso_grupo) de Permisos Grupo existe en el sistema seleccionado.")
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
                                              Optional cod_sub_tipo As Integer = 0,
                                              Optional chargeBinary As Boolean = False,
                                              Optional bytes() As Byte = Nothing) Implements InvSicaObjetoGrupo.loadFromImplementation

                Dim cn As String = path.Split("\")(0)
                Dim permiso_grupo As String = path.Split("\")(1)

                If cn = "" Then cn = "default"

                Dim nvcn As tDBConection = nvApp.app_cns(cn)
                nvcn.excaslogin = False
                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(emunDBType.db_other, nvcn)

                Dim oPermisoGrupo As New tSicaObjeto
                objME.fecha_modificacion = Now()

                Try
                    '--- Agregar elemento de "operador_permiso_grupo" ---
                    Dim strSQL As String = "SELECT * FROM operador_permiso_grupo WHERE permiso_grupo='" & permiso_grupo & "'"
                    Dim rsGrupo As ADODB.Recordset = conn.Execute(strSQL)

                    If rsGrupo.EOF Then
                        nvDBUtiles.DBCloseRecordset(rsGrupo)
                        Exit Sub
                    End If

                    Dim nro_permiso_grupo As Integer = rsGrupo.Fields("nro_permiso_grupo").Value ' guardo el "nro_permiso_grupo" que tenga la implementacion
                    objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo)
                    Dim oPath As String = cn & "\operador_permiso_grupo"
                    Dim oObjeto As String = rsGrupo.Fields("permiso_grupo").Value
                    Dim oCod_subtipo As Integer = 0
                    Dim oBytes() As Byte
                    Dim arParam As New trsParam
                    Dim primary_keys As New List(Of String)
                    primary_keys.Add("permiso_grupo")
                    Dim oXML As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rsGrupo, arParam, primary_keys:=primary_keys)
                    Dim strXML As String = oXML.OuterXml
                    oBytes = nvConvertUtiles.StringToBytes(strXML)
                    oPermisoGrupo.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                    objME.childObjects.Add(oPermisoGrupo)


                    '--- Agregar elementos de "operador_permiso_detalle" ---
                    strSQL = "SELECT * FROM operador_permiso_detalle WHERE nro_permiso_grupo=" & nro_permiso_grupo & " ORDER BY nro_permiso"
                    Dim rsDetalle As ADODB.Recordset = conn.Execute(strSQL)
                    oPath = cn & "\operador_permiso_detalle"
                    oObjeto = "Detalle de " & oPermisoGrupo.objeto
                    oCod_subtipo = 0
                    primary_keys = New List(Of String)
                    primary_keys.Add("nro_permiso_grupo")  ' no quiero usarlo para que no interfiera; en el detalle solo me interesa el número y permitir
                    primary_keys.Add("nro_permiso")
                    arParam = New trsParam
                    arParam.Add("permiso_grupo", permiso_grupo)
                    oXML = nvXMLSQL.RecordsetToXML(rsDetalle, arParam, primary_keys:=primary_keys)
                    strXML = oXML.OuterXml
                    oBytes = nvConvertUtiles.StringToBytes(strXML)
                    Dim oPermisoDetalle As New tSicaObjeto
                    oPermisoDetalle.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                    objME.childObjects.Add(oPermisoDetalle)


                    '--- Agregar elementos de "Permiso_Nodos" ---
                    ' Se exportan todos los nodos que pertenecen al "permiso_grupo", iniciando con "nro_permiso_grupo"
                    strSQL = getQueryForPermissionNodes(nro_permiso_grupo)
                    Dim rsNodos As ADODB.Recordset = conn.Execute(strSQL)

                    If Not rsNodos.EOF Then
                        oPath = cn & "\Permiso_Nodos"
                        oObjeto = "Nodos de " & oPermisoGrupo.objeto
                        oCod_subtipo = 0
                        primary_keys = New List(Of String)
                        primary_keys.Add("per_nodo")
                        primary_keys.Add("per_nodo_tipo")
                        arParam = New trsParam
                        arParam.Add("permiso_grupo", permiso_grupo)
                        oXML = nvXMLSQL.RecordsetToXML(rsNodos, arParam, primary_keys:=primary_keys)
                        strXML = oXML.OuterXml
                        oBytes = nvConvertUtiles.StringToBytes(strXML)
                        Dim oPermisoNodos As New tSicaObjeto
                        oPermisoNodos.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                        objME.childObjects.Add(oPermisoNodos)
                    End If


                    If chargeBinary Then
                        Dim _bytes() As Byte
                        ReDim _bytes(0)
                        objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo, _bytes)
                    End If

                    nvDBUtiles.DBCloseRecordset(rsGrupo)
                    nvDBUtiles.DBCloseRecordset(rsDetalle)
                    nvDBUtiles.DBCloseRecordset(rsNodos)
                Catch ex As Exception
                    Throw New Exception("No fué posible cargar el objeto Permiso Grupo desde la implementación.", ex)
                End Try
            End Sub



            Public Function checkIntegrity(objME As tSicaObjeto, rescab As tResCab, nvApp As tnvApp) As nvenumResStatus Implements InvSicaObjetoGrupo.checkIntegrity
                Dim resStatus As nvenumResStatus
                Dim resElement As New tResElement
                resElement.cod_modulo_version = objME.cod_modulo_version
                resElement.cod_objeto = objME.cod_objeto
                resElement.cod_obj_tipo = objME.cod_obj_tipo
                resElement.cod_pasaje = objME.modulo_version_cod_pasaje
                resElement.cod_sub_tipo = objME.modulo_version_cod_sub_tipo
                resElement.comentario = ""
                resElement.path = objME.modulo_version_path
                resElement.objeto = objME.objeto

                If objME.bytes Is Nothing Then
                    resStatus = nvenumResStatus.objeto_no_econtrado
                Else
                    Dim count_no_encontrados As Integer = 0
                    Dim count_modificados As Integer = 0
                    Dim child As tSicaObjeto
                    Dim childRes As nvenumResStatus
                    Dim resChilds As New tResCab

                    For Each child In objME.childObjects
                        If child.modulo_version_path.Split("\").Length = 2 AndAlso child.modulo_version_path.Split("\")(1).ToLower = "permiso_nodos" Then
                            childRes = Me.checkIntegrityNodes(child, resChilds, nvApp)
                        Else
                            childRes = child.checkIntegrity(resChilds, nvApp)
                        End If

                        If childRes <> nvenumResStatus.OK Then
                            If childRes = nvenumResStatus.objeto_no_econtrado Then count_no_encontrados += 1
                            If childRes = nvenumResStatus.objeto_modificado Then count_modificados += 1

                            resElement.comentario &= resChilds.elements(0).comentario
                        End If
                    Next

                    If (count_modificados > 0) OrElse (count_no_encontrados > 0) Then
                        resStatus = nvenumResStatus.objeto_modificado
                    Else
                        resStatus = nvenumResStatus.OK
                    End If
                End If

                resElement.resStatus = resStatus
                rescab.elements.Add(resElement)
                Return resStatus
            End Function



            Private Function checkIntegrityNodes(oSicaDefinicion As tSicaObjeto, resCab As tResCab, nvApp As tnvApp) As nvenumResStatus
                ' Cargar la definicion XML para obtener el valor de "permiso_grupo"
                Dim oXml As New System.Xml.XmlDocument

                If oSicaDefinicion.bytes.Length > 0 Then
                    oXml.LoadXml(nvConvertUtiles.BytesToString(oSicaDefinicion.bytes))
                Else
                    Throw New Exception("No hay datos en la definición de Permisos Nodos.")
                End If

                Dim cn As String = oSicaDefinicion.modulo_version_path.Split("\")(0)
                If cn = String.Empty Then cn = "default"

                Dim nvcn As tDBConection = nvApp.app_cns(cn)
                nvcn.excaslogin = False
                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(emunDBType.db_other, nvcn)

                ' Comparar oSicaDefinicion con oSicaImplementacion
                Dim resElement As New tResElement
                resElement.cod_objeto = oSicaDefinicion.cod_objeto
                resElement.cod_obj_tipo = oSicaDefinicion.cod_obj_tipo
                resElement.path = oSicaDefinicion.modulo_version_path
                resElement.cod_sub_tipo = oSicaDefinicion.modulo_version_cod_sub_tipo
                resElement.objeto = oSicaDefinicion.objeto
                resElement.cod_modulo_version = oSicaDefinicion.cod_modulo_version
                resElement.cod_pasaje = oSicaDefinicion.modulo_version_cod_pasaje
                resElement.comentario = ""

                Dim permiso_grupo As String = nvXMLUtiles.getAttribute_path(oXml, "xml/params/@permiso_grupo", "")
                Dim query As String = "SELECT nro_permiso_grupo FROM operador_permiso_grupo WHERE permiso_grupo='" & permiso_grupo & "'"
                Dim rs As ADODB.Recordset = conn.Execute(query)

                If rs.EOF Then
                    'Throw New Exception("No existe el grupo de permisos relacionado a los nodos.")
                    resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                    resElement.comentario = "No existe el grupo de permisos (" & permiso_grupo & ") relacionado a los nodos."
                    resCab.elements.Add(resElement)
                    Return nvenumResStatus.objeto_no_econtrado
                End If

                Dim nro_permiso_grupo As Integer = rs.Fields("nro_permiso_grupo").Value
                nvDBUtiles.DBCloseRecordset(rs, False)

                query = getQueryForPermissionNodes(nro_permiso_grupo)
                rs = conn.Execute(query)
                Dim oPath As String = cn & "\Permiso_Nodos"
                Dim oObjeto As String = "Nodos de " & oSicaDefinicion.objeto
                Dim oCod_subtipo As Integer = 0
                Dim primary_keys As New List(Of String)
                primary_keys.Add("per_nodo")
                primary_keys.Add("per_nodo_tipo")
                Dim arParam As New trsParam
                arParam.Add("permiso_grupo", permiso_grupo)
                oXml = nvXMLSQL.RecordsetToXML(rs, arParam, primary_keys:=primary_keys)
                nvDBUtiles.DBCloseRecordset(rs, False)

                Dim strXML As String = oXml.OuterXml
                Dim oBytes As Byte() = nvConvertUtiles.StringToBytes(strXML)
                Dim oSicaImplementacion As New tSicaObjeto
                oSicaImplementacion.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)

                strXML = nvConvertUtiles.BytesToString(oSicaDefinicion.bytes)
                Dim oXmlDef As New System.Xml.XmlDocument
                oXmlDef.LoadXml(strXML)

                strXML = nvConvertUtiles.BytesToString(oSicaImplementacion.bytes)
                Dim oXmlImp As New System.Xml.XmlDocument
                oXmlImp.LoadXml(strXML)

                Dim nodesDef As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlDef, "xml/rs:data/z:row")
                If nodesDef.Count = 0 Then nodesDef = nvXMLUtiles.selectNodes(oXmlDef, "xml/rs:data/rs:insert/z:row")

                Dim nodesImp As System.Xml.XmlNodeList
                Dim nodesPK As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlImp, "xml/s:Schema/s:ElementType/s:AttributeType[@pk='true']")
                Dim nodesFields As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlImp, "xml/s:Schema/s:ElementType/s:AttributeType")
                Dim nodePK As System.Xml.XmlNode
                Dim iguales As Boolean
                Dim xPtah As String
                Dim encontrados As Integer = 0
                Dim count_distintos As Integer = 0

                For i = 0 To nodesDef.Count - 1
                    xPtah = ""
                    Dim attributeNamePK As String = ""

                    Try
                        For Each nodePK In nodesPK
                            attributeNamePK = nodePK.Attributes("name").Value

                            If xPtah = "" Then
                                xPtah &= "@" & attributeNamePK & "='" & nodesDef(i).Attributes(attributeNamePK).Value & "'"
                            Else
                                xPtah &= " and @" & attributeNamePK & "='" & nodesDef(i).Attributes(attributeNamePK).Value & "'"
                            End If
                        Next
                    Catch ex As Exception
                        Throw New Exception("El atributo de PK (" & attributeNamePK & ") no se encuentra en la definición")
                    End Try

                    nodesImp = nvXMLUtiles.selectNodes(oXmlImp, "xml/rs:data/z:row[" & xPtah & "]")

                    If nodesImp.Count = 0 Then nodesImp = nvXMLUtiles.selectNodes(oXmlImp, "xml/rs:data/rs:insert/z:row[" & xPtah & "]")

                    If nodesImp.Count > 0 Then
                        encontrados += 1
                        iguales = True
                        Dim attributeName As String
                        Dim table As String = resElement.path.Split("\")(1)

                        For Each nodePK In nodesFields
                            attributeName = nodePK.Attributes("name").Value

                            If nodesDef(i).Attributes(attributeName) Is Nothing OrElse nodesImp(0).Attributes(attributeName) Is Nothing Then
                                If Not nodesDef(i).Attributes(attributeName) Is Nothing OrElse Not nodesImp(0).Attributes(attributeName) Is Nothing Then
                                    Dim definicionIsNull As Boolean = IsDBNull(nodesDef(i).Attributes(attributeName)) OrElse nodesDef(i).Attributes(attributeName) Is Nothing
                                    resElement.comentario &= "Tabla.columna [<b>" & table & "</b>].[<b>" & attributeName & "</b>]: valor nulo en " & If(definicionIsNull, "definición", "implementación") & "</br>"
                                    iguales = False
                                    Exit For
                                End If
                            Else
                                If nodesDef(i).Attributes(attributeName).Value <> nodesImp(0).Attributes(attributeName).Value Then
                                    resElement.comentario &= "Tabla.columna [<b>" & table & "</b>].[<b>" & attributeName & "</b>]: difiere entre definición (" & nodesDef(i).Attributes(attributeName).Value & ") e implementación (" & nodesImp(0).Attributes(attributeName).Value & ")</br>"
                                    iguales = False
                                    Exit For
                                End If
                            End If
                        Next

                        If Not iguales Then count_distintos += 1
                    End If
                Next

                conn.Close()

                If encontrados = 0 Then
                    resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                    resCab.elements.Add(resElement)
                    Return nvenumResStatus.objeto_no_econtrado
                ElseIf count_distintos > 0 OrElse (encontrados <> nodesDef.Count) Then
                    resElement.resStatus = nvenumResStatus.objeto_modificado
                    resCab.elements.Add(resElement)
                    Return nvenumResStatus.objeto_modificado
                End If

                Return nvenumResStatus.OK
            End Function



            Public Sub saveToImplementation(objME As tSicaObjeto, nvApp As tnvApp) Implements InvSicaObjetoGrupo.saveToImplementation
                ' Verificar que esté el objeto "nvApp" de la implementación en el "objMe" (en implementation_nvApp)
                If objME.implemantation_nvApp Is Nothing AndAlso Not nvApp Is Nothing Then objME.implemantation_nvApp = nvApp

                ' No hace falta agregar el objeto base (Permiso Grupo), sólo los hijos de tipo "Dato"
                For Each child As tSicaObjeto In objME.childObjects
                    Me.objeto_agregar(child.cod_objeto, child.cod_obj_tipo, objME.implemantation_nvApp, child.modulo_version_path, child.bytes)
                Next
            End Sub



            Private Sub objeto_agregar(cod_objeto As Integer,
                                       cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo,
                                       nvApp As tnvApp,
                                       modulo_version_path As String,
                                       bytes As Byte())

                ' Parametros esta compuesto de objetos de tipo "DATOS"
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

                    Try
                        ' Este objeto complejo se compone con datos de 3 tablas:
                        '   1) operador_permiso_grupo    (1 registro)
                        '   2) operador_permiso_detalle  (30 registros normalmente)
                        '   3) permiso_nodos             (desde 2 registros en adelante)

                        Select Case tabla
                            Case "operador_permiso_grupo"
                                Dim nodeDef As System.Xml.XmlNode = nvXMLUtiles.selectSingleNode(oXml, "xml/rs:data/z:row")
                                If nodeDef Is Nothing Then nodeDef = nvXMLUtiles.selectSingleNode(oXml, "xml/rs:data/rs:insert/z:row")

                                If Not nodeDef Is Nothing Then
                                    Dim strWhere As New List(Of String)

                                    For Each pk As String In pks
                                        strWhere.Add("[" & pk & "]='" & nvXMLUtiles.getAttribute_path(nodeDef, "@" & pk, "") & "'")
                                    Next

                                    query = "SELECT COUNT(*) AS [count] FROM operador_permiso_grupo WHERE " & String.Join(" AND ", strWhere)
                                    rs = conn.Execute(query)

                                    ' No esta el grupo, insertarlo
                                    If rs.Fields("count").Value = 0 Then
                                        Dim permiso_grupo_DEF As String = nvXMLUtiles.getAttribute_path(nodeDef, "@permiso_grupo", "")
                                        Dim hardcode_DEF As Integer = If(nvXMLUtiles.getAttribute_path(nodeDef, "@hardcode", "False").ToString.ToLower = "true", 1, 0)

                                        query = "DECLARE @nro_permiso_grupo INT" & vbCrLf
                                        query &= "SELECT @nro_permiso_grupo = ISNULL(MAX(nro_permiso_grupo), 0) + 1 FROM operador_permiso_grupo" & vbCrLf
                                        query &= "INSERT INTO operador_permiso_grupo (nro_permiso_grupo, permiso_grupo, hardcode) " &
                                                "VALUES(@nro_permiso_grupo, '" & permiso_grupo_DEF & "', " & hardcode_DEF & ")"
                                        conn.Execute(query)
                                    End If

                                    nvDBUtiles.DBCloseRecordset(rs, False)
                                End If


                            Case "operador_permiso_detalle"
                                ' Aca si hay un permiso en la implementación diferente a la definición,
                                ' salir con una exepción
                                Dim permiso_grupo_DEF As String = nvXMLUtiles.getAttribute_path(oXml, "xml/params/@permiso_grupo", "")

                                If permiso_grupo_DEF <> String.Empty Then
                                    ' Obtener el nro_permiso_grupo de la implementacion
                                    Dim nro_permiso_grupo As Integer = 0
                                    rs = conn.Execute("SELECT nro_permiso_grupo FROM operador_permiso_grupo where permiso_grupo='" & permiso_grupo_DEF & "'")

                                    If Not rs.EOF Then nro_permiso_grupo = rs.Fields("nro_permiso_grupo").Value

                                    nvDBUtiles.DBCloseRecordset(rs, False)

                                    nodesDef = nvXMLUtiles.selectNodes(oXml, "xml/rs:data/z:row")
                                    If nodesDef.Count = 0 Then nodesDef = nvXMLUtiles.selectNodes(oXml, "xml/rs:data/rs:insert/z:row")

                                    Dim nro_permiso_DEF As Integer
                                    Dim Permitir_DEF As String

                                    For Each nodo As System.Xml.XmlNode In nodesDef
                                        nro_permiso_DEF = nvXMLUtiles.getAttribute_path(nodo, "@nro_permiso", "-1")
                                        Permitir_DEF = nvXMLUtiles.getAttribute_path(nodo, "@Permitir", "")
                                        query = "SELECT Permitir FROM operador_permiso_detalle WHERE nro_permiso_grupo=" & nro_permiso_grupo & " AND nro_permiso=" & nro_permiso_DEF
                                        rs = conn.Execute(query)

                                        If Not rs.EOF Then
                                            '' Hay 3 posibilidades con Permitir: 
                                            ''   A) iguales: no hacer nada
                                            ''   B) distintos:
                                            ''       B.1) implementacion tiene valor == "No Utilizado", actualizar valor
                                            ''       B.2) implementacion tiene valor != "No Utilizado", sair con throw
                                            'If Permitir_DEF <> rs.Fields("Permitir").Value Then
                                            '    If rs.Fields("Permitir").Value.ToString.ToLower = "no utilizado" Then
                                            '        query = "BEGIN UPDATE operador_permiso_detalle" & vbCrLf &
                                            '                "SET Permitir='" & Permitir_DEF & "'" & vbCrLf &
                                            '                "WHERE nro_permiso=" & nro_permiso_DEF & " AND nro_permiso_grupo=" & nro_permiso_grupo & " END"
                                            '        conn.Execute(query)
                                            '    Else
                                            '        Throw New Exception("No es posible implementar los permisos detalle porque uno o más permisos ya están ocupados en la implementación y difieren en nombre")
                                            '        Exit For
                                            '    End If
                                            'End If

                                            ' Se actualizan todos los permisos, independientemente de los que tengan a menos que sean iguales
                                            If Permitir_DEF <> rs.Fields("Permitir").Value Then
                                                query = "BEGIN UPDATE operador_permiso_detalle" & vbCrLf &
                                                            "SET Permitir='" & Permitir_DEF & "'" & vbCrLf &
                                                            "WHERE nro_permiso=" & nro_permiso_DEF & " AND nro_permiso_grupo=" & nro_permiso_grupo & " END"
                                                conn.Execute(query)
                                            End If
                                        Else
                                            query = "INSERT INTO operador_permiso_detalle (nro_permiso, nro_permiso_grupo, Permitir) VALUES(" & nro_permiso_DEF & ", " & nro_permiso_grupo & ", '" & Permitir_DEF & "')"
                                            conn.Execute(query)
                                        End If

                                        nvDBUtiles.DBCloseRecordset(rs, False)
                                    Next
                                Else
                                    Throw New Exception("No fué posible obtener el permiso grupo para los detalles.")
                                End If


                            Case "permiso_nodos"
                                '-------------------------------------------------------------------------------
                                ' Estructura de tabla [Permiso_Nodos]
                                '-------------------------------------------------------------------------------
                                ' nro_per_nodo         <int>       Éste es el ID del NODO
                                ' per_nodo             <string>    Acá siempre está vacío
                                ' per_nodo_tipo        <string>    R: raiz; M: modulo; P: permiso;
                                ' nro_per_nodo_dep     <int>       ID del modulo del cual depende. Raiz no tiene valor
                                ' nro_permiso          <int>       Valor del permiso. Valido en nodos Permiso.
                                ' nro_permiso_grupo    <int>       ID del grupo de permisos
                                ' per_orden            <int>       Valor para ordenamiento de nodos.
                                '-------------------------------------------------------------------------------
                                nodesDef = nvXMLUtiles.selectNodes(oXml, "xml/rs:data/z:row")
                                If nodesDef.Count = 0 Then nodesDef = nvXMLUtiles.selectNodes(oXml, "xml/rs:data/rs:insert/z:row")

                                Dim nro_per_nodo_dep As Integer = 0
                                Dim permiso_grupo_DEF As String = nvXMLUtiles.getAttribute_path(oXml, "xml/params/@permiso_grupo")
                                query = "SELECT nro_permiso_grupo FROM operador_permiso_grupo WHERE permiso_grupo='" & permiso_grupo_DEF & "'"
                                rs = conn.Execute(query)

                                Dim nro_permiso_grupo As Integer = 0
                                Dim dependencias_de_nodos As New Dictionary(Of Integer, Integer) ' Guardar ID original y el nuevo (pueden coincidir); con ésto armamos correctamente las dependencias de los parametros

                                If Not rs.EOF Then nro_permiso_grupo = rs.Fields("nro_permiso_grupo").Value
                                nvDBUtiles.DBCloseRecordset(rs, False)

                                Dim per_nodo_tipo_DEF As String
                                Dim per_nodo_DEF As String

                                For Each nodeDef As System.Xml.XmlNode In nodesDef
                                    per_nodo_tipo_DEF = nvXMLUtiles.getAttribute_path(nodeDef, "@per_nodo_tipo", "")
                                    per_nodo_DEF = nvXMLUtiles.getAttribute_path(nodeDef, "@per_nodo", "")

                                    Select Case per_nodo_tipo_DEF.ToUpper
                                        ' Raiz
                                        Case "R"
                                            query = "SELECT * FROM Permiso_Nodos WHERE per_nodo_tipo='R' AND per_nodo='" & per_nodo_DEF & "'"
                                            rs = conn.Execute(query)

                                            Dim nro_per_nodo_raiz_DEF As Integer = nvXMLUtiles.getAttribute_path(nodeDef, "@nro_per_nodo", "-1")

                                            If Not rs.EOF Then
                                                dependencias_de_nodos.Add(nro_per_nodo_raiz_DEF, rs.Fields("nro_per_nodo").Value)
                                            Else
                                                ' Insertar la Raiz
                                                query = "INSERT INTO Permiso_Nodos (per_nodo, per_nodo_tipo) VALUES ('" & per_nodo_DEF & "', '" & per_nodo_tipo_DEF & "')" & vbCrLf &
                                                        "SELECT @@IDENTITY AS nro_per_nodo"
                                                Dim rsRaiz As ADODB.Recordset = conn.Execute(query)
                                                dependencias_de_nodos.Add(nro_per_nodo_raiz_DEF, rsRaiz.Fields("nro_per_nodo").Value)
                                                nvDBUtiles.DBCloseRecordset(rsRaiz, False)
                                            End If

                                            nvDBUtiles.DBCloseRecordset(rs, False)


                                        ' Modulo
                                        Case "M"
                                            query = "SELECT * FROM Permiso_Nodos WHERE per_nodo_tipo='M' AND per_nodo='" & per_nodo_DEF & "'"
                                            rs = conn.Execute(query)

                                            Dim nro_per_nodo_modulo_DEF As Integer = nvXMLUtiles.getAttribute_path(nodeDef, "@nro_per_nodo", "-1")
                                            Dim nro_per_nodo_dep_modulo_DEF As Integer = nvXMLUtiles.getAttribute_path(nodeDef, "@nro_per_nodo_dep", "-1")

                                            If Not rs.EOF Then
                                                ' Existe, verificar si conincide con el dependiente, sino actualizar
                                                If nro_per_nodo_dep_modulo_DEF = rs.Fields("nro_per_nodo_dep").Value Then
                                                    dependencias_de_nodos.Add(nro_per_nodo_modulo_DEF, rs.Fields("nro_per_nodo").Value)
                                                Else
                                                    nro_per_nodo_dep = dependencias_de_nodos(nro_per_nodo_dep_modulo_DEF) ' recuperar desde el original
                                                    query = "UPDATE Permiso_Nodos SET nro_per_nodo_dep=" & nro_per_nodo_dep & " WHERE per_nodo_tipo='M' AND per_nodo='" & per_nodo_DEF & "'" & vbCrLf &
                                                            "SELECT nro_per_nodo FROM Permiso_Nodos WHERE per_nodo_tipo='M' AND per_nodo='" & per_nodo_DEF & "'"
                                                    Dim rsMod As ADODB.Recordset = conn.Execute(query)

                                                    If Not rsMod.EOF Then
                                                        dependencias_de_nodos.Add(nro_per_nodo_modulo_DEF, rsMod.Fields("nro_per_nodo").Value)
                                                    End If

                                                    nvDBUtiles.DBCloseRecordset(rsMod, False)
                                                End If
                                            Else
                                                ' Insertar el Módulo
                                                nro_per_nodo_dep = dependencias_de_nodos(nro_per_nodo_dep_modulo_DEF) ' recuperar desde el original
                                                Dim per_orden_DEF As Integer = nvXMLUtiles.getAttribute_path(nodeDef, "@per_orden", "0")
                                                query = "INSERT INTO Permiso_Nodos (per_nodo, per_nodo_tipo, nro_per_nodo_dep, nro_permiso, nro_permiso_grupo, per_orden) " & vbCrLf &
                                                            "VALUES ('" & per_nodo_DEF & "', 'M', " & nro_per_nodo_dep & ", null, null, " & per_orden_DEF & ")" & vbCrLf &
                                                        "SELECT @@IDENTITY AS nro_per_nodo"
                                                Dim rsMod As ADODB.Recordset = conn.Execute(query)

                                                If Not rsMod.EOF Then
                                                    dependencias_de_nodos.Add(nro_per_nodo_modulo_DEF, rsMod.Fields("nro_per_nodo").Value)
                                                End If

                                                nvDBUtiles.DBCloseRecordset(rsMod, False)
                                            End If

                                            nvDBUtiles.DBCloseRecordset(rs, False)


                                        ' Permiso
                                        Case "P"
                                            ' "Joinear" con tabla "operador_permiso_detalle" para obtener el nombre del permiso ("Permitir")
                                            query = "SELECT a.*, b.Permitir " & vbCrLf &
                                                    "FROM Permiso_Nodos a " & vbCrLf &
                                                    "LEFT JOIN operador_permiso_detalle b ON a.nro_permiso_grupo=b.nro_permiso_grupo AND a.nro_permiso=b.nro_permiso " & vbCrLf &
                                                    "WHERE a.nro_permiso_grupo=" & nro_permiso_grupo & " AND per_nodo_tipo='P' AND Permitir='" & per_nodo_DEF & "'"
                                            rs = conn.Execute(query) ' RS con el NODO "Permiso" de la IMPLEMENTACION

                                            Dim nro_permiso_DEF As Integer = nvXMLUtiles.getAttribute_path(nodeDef, "@nro_permiso", "0")
                                            Dim per_orden_DEF As Integer = nvXMLUtiles.getAttribute_path(nodeDef, "@per_orden", "0")
                                            ' obtener el ID del módulo al que pertenece
                                            Dim nro_per_nodo_dep_permiso_DEF As Integer = nvXMLUtiles.getAttribute_path(nodeDef, "@nro_per_nodo_dep", "-1")
                                            nro_per_nodo_dep = dependencias_de_nodos(nro_per_nodo_dep_permiso_DEF)

                                            If Not rs.EOF Then
                                                ' Existe => revisar que coincida la dependencia
                                                If nro_per_nodo_dep <> rs.Fields("nro_per_nodo_dep").Value OrElse
                                                   nro_permiso_grupo <> rs.Fields("nro_permiso_grupo").Value OrElse
                                                   nro_permiso_DEF <> rs.Fields("nro_permiso").Value OrElse
                                                   per_orden_DEF <> rs.Fields("per_orden").Value Then

                                                    ' obtener el ID del nodo para no actualizar cualquier cosa
                                                    Dim nro_per_nodo As Integer = rs.Fields("nro_per_nodo").Value
                                                    query = "UPDATE Permiso_Nodos " & vbCrLf &
                                                            "SET nro_per_nodo_dep=" & nro_per_nodo_dep & vbCrLf &
                                                               ",nro_permiso_grupo=" & nro_permiso_grupo & vbCrLf &
                                                               ",nro_permiso=" & nro_permiso_DEF & vbCrLf &
                                                               ",per_orden=" & per_orden_DEF & vbCrLf &
                                                            "WHERE nro_per_nodo=" & nro_per_nodo & vbCrLf
                                                    conn.Execute(query)
                                                End If
                                            Else
                                                ' Insertar Permiso - columna "per_nodo" va vacía en caso de Permiso, no lleva descripción
                                                query = "INSERT INTO Permiso_Nodos (per_nodo, per_nodo_tipo, nro_per_nodo_dep, nro_permiso, nro_permiso_grupo, per_orden) " & vbCrLf &
                                                            "VALUES ('', 'P', " & nro_per_nodo_dep & ", " & nro_permiso_DEF & ", " & nro_permiso_grupo & ", " & per_orden_DEF & ")"
                                                conn.Execute(query)
                                            End If

                                            nvDBUtiles.DBCloseRecordset(rs, False)

                                    End Select
                                Next
                        End Select

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
                Return True
            End Function



            Private Function getQueryForPermissionNodes(ByVal nro_permiso_grupo As Integer) As String
                Dim sb As New StringBuilder()

                sb.AppendFormat("SET NOCOUNT ON {0}", vbCrLf)
                sb.Append("CREATE TABLE #tmp (")
                sb.Append("nro_per_nodo INT,")
                sb.Append("per_nodo VARCHAR(100) NULL,")
                sb.Append("per_nodo_tipo CHAR(1),")
                sb.Append("nro_per_nodo_dep INT NULL,")
                sb.Append("nro_permiso INT NULL,")
                sb.Append("nro_permiso_grupo INT NULL,")
                sb.AppendFormat("per_orden INT NULL) {0}", vbCrLf)

                sb.AppendFormat("INSERT INTO #tmp SELECT * FROM Permiso_Nodos WHERE nro_permiso_grupo={0} {1}", nro_permiso_grupo, vbCrLf)
                sb.AppendFormat("DECLARE c CURSOR LOCAL FORWARD_ONLY READ_ONLY {0}", vbCrLf)
                sb.AppendFormat("FOR {0}", vbCrLf)
                sb.AppendFormat("SELECT nro_per_nodo_dep FROM #tmp {0}", vbCrLf)
                sb.AppendFormat("OPEN c {0}", vbCrLf)
                sb.AppendFormat("DECLARE @nro_per_nodo_dep INT {0}", vbCrLf)
                sb.AppendFormat("FETCH NEXT FROM c INTO @nro_per_nodo_dep {0}", vbCrLf)

                sb.AppendFormat("WHILE (@@FETCH_STATUS = 0) {0}", vbCrLf)
                sb.AppendFormat("BEGIN {0}", vbCrLf)
                sb.AppendFormat("IF NOT EXISTS (SELECT nro_per_nodo FROM #tmp WHERE nro_per_nodo = @nro_per_nodo_dep) {0}", vbCrLf)
                sb.AppendFormat("INSERT INTO #tmp SELECT * FROM Permiso_Nodos WHERE nro_per_nodo = @nro_per_nodo_dep {0}", vbCrLf)
                sb.AppendFormat("FETCH NEXT FROM c INTO @nro_per_nodo_dep {0}", vbCrLf)
                sb.AppendFormat("END {0}", vbCrLf)

                sb.AppendFormat("CLOSE c {0}", vbCrLf)
                sb.AppendFormat("DEALLOCATE c {0}", vbCrLf)

                sb.Append("SELECT ")
                sb.Append("a.nro_per_nodo, ")
                sb.Append("CASE WHEN a.per_nodo <> '' THEN a.per_nodo ELSE b.Permitir COLLATE MODERN_SPANISH_CI_AI END AS per_nodo, ")
                sb.Append("a.per_nodo_tipo, ")
                sb.Append("a.nro_per_nodo_dep, ")
                sb.Append("a.nro_permiso, ")
                sb.Append("a.nro_permiso_grupo, ")
                sb.AppendFormat("a.per_orden {0}", vbCrLf)
                sb.AppendFormat("FROM #tmp a {0}", vbCrLf)
                sb.AppendFormat("LEFT JOIN operador_permiso_detalle b ON a.nro_permiso_grupo = b.nro_permiso_grupo AND a.nro_permiso = b.nro_permiso {0}", vbCrLf)
                sb.AppendFormat("ORDER BY (CASE WHEN per_nodo_tipo = 'R' THEN 0 {0}", vbCrLf)
                sb.AppendFormat("WHEN per_nodo_tipo = 'M' THEN 1 {0}", vbCrLf)
                sb.AppendFormat("ELSE 99 END), nro_per_nodo_dep {0}", vbCrLf)

                sb.AppendFormat("DROP TABLE #tmp {0}", vbCrLf)

                Return sb.ToString()
            End Function

        End Class
    End Namespace
End Namespace