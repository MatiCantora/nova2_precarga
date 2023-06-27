Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvSICA

        Public Class tnvSicaParametro
            Implements InvSicaObjetoGrupo

            '------------------------------------------------------------------
            ' Objeto:   PARAMETRO
            '
            ' Composición: datos de tablas
            '       Parametros_Def
            '       Parametros_Nodos
            '------------------------------------------------------------------


            ' Conexion por defecto
            Public Shared cn_name As String = "default"



            Public Shared Function getRSXMLElements(nvApp As tnvApp, Optional filtro As String = "") As String
                ' filtro: si no está vacío, viene completo como "like '%valor_buscado%'" o "not like '%valor_a_excluir%'"
                If cn_name = String.Empty Then cn_name = "default"

                Dim nvcn As tDBConection = nvApp.app_cns(cn_name).clone()
                nvcn.excaslogin = False
                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(emunDBType.db_other, nvcn)

                ' Solo buscar los nodos de tipo "Parametros" (P)
                Dim strSQL As String = "SELECT '" & cn_name & "\' + pdef.id_param AS path," &
                                       "       [param] AS objeto," &
                                       "       0 AS cod_sub_tipo," &
                                       "       '' AS comentario" &
                                       " FROM Parametros_Def pdef" &
                                       " INNER JOIN Parametros_Nodos pnod ON pdef.id_param = pnod.id_param AND pnod.par_nodo_tipo='P'" &
                                        If(filtro <> String.Empty, " WHERE [param] " & filtro, "")

                Dim rs As ADODB.Recordset

                Try
                    rs = conn.Execute(strSQL)
                Catch ex As Exception
                    If conn.State = 1 Then conn.Close()
                    Throw New Exception(ex.Message & "</br>Compruebe que la tabla (Parametros_Def) de Parámetros existe en el sistema seleccionado.")
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
                    Dim oSicaParametroDef As New tSicaObjeto
                    objME.fecha_modificacion = Now()

                    ' "path" está compuesto por:   nombre_conexion\nombre_objeto_parametro
                    Dim cn As String = path.Split("\")(0)       ' nombre_conexion
                    Dim id_param As String = path.Split("\")(1) ' nombre_objeto_parametro (id_param)

                    If cn = "" Then cn = "default"

                    Dim nvcn As tDBConection = nvApp.app_cns(cn).clone()
                    nvcn.excaslogin = False
                    Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)

                    '--- Agregar elemento de "Parametros_Def" ---
                    Dim strSQL As String = String.Format("SELECT * FROM Parametros_Def WHERE id_param='{0}'", id_param)
                    Dim rs As ADODB.Recordset = conn.Execute(strSQL)

                    If rs.EOF Then
                        nvDBUtiles.DBCloseRecordset(rs)
                        Exit Sub
                    End If

                    objME.SetValues(cod_objeto_tipo, path, objeto, cod_sub_tipo)
                    Dim oPath As String = cn & "\Parametros_Def"   ' conexion\tabla
                    Dim oObjeto As String = rs.Fields("id_param").Value
                    Dim oCod_subtipo As Integer = 0
                    Dim oBytes() As Byte

                    Dim arParam As New trsParam

                    ' Obtener los datos de permisos asociados
                    Dim nro_permiso_grupo As Integer = rs.Fields("nro_permiso_grupo").Value
                    Dim nro_permiso As Integer = rs.Fields("nro_permiso").Value

                    Dim sbSQL As New StringBuilder()
                    sbSQL.AppendFormat("SELECT a.nro_permiso_grupo, a.permiso_grupo, b.nro_permiso, b.Permitir {0}", vbCrLf)
                    sbSQL.AppendFormat(" FROM operador_permiso_grupo a {0}", vbCrLf)
                    sbSQL.AppendFormat("  INNER JOIN operador_permiso_detalle b ON b.nro_permiso_grupo=a.nro_permiso_grupo {0}", vbCrLf)
                    sbSQL.AppendFormat(" WHERE a.nro_permiso_grupo={0} AND b.nro_permiso={1} {2}", nro_permiso_grupo, nro_permiso, vbCrLf)

                    strSQL = sbSQL.ToString()
                    sbSQL = Nothing
                    Dim _rs As ADODB.Recordset = conn.Execute(strSQL)

                    If Not _rs.EOF Then
                        arParam.Add("nro_permiso_grupo", _rs.Fields("nro_permiso_grupo").Value)
                        arParam.Add("permiso_grupo", _rs.Fields("permiso_grupo").Value)
                        arParam.Add("nro_permiso", _rs.Fields("nro_permiso").Value)
                        arParam.Add("Permitir", _rs.Fields("Permitir").Value)
                    Else
                        arParam.Add("nro_permiso_grupo", nro_permiso_grupo)
                        arParam.Add("permiso_grupo", "")
                        arParam.Add("nro_permiso", nro_permiso)
                        arParam.Add("Permitir", "")
                    End If

                    nvDBUtiles.DBCloseRecordset(_rs, False)

                    Dim primary_keys As New List(Of String)
                    primary_keys.Add("id_param")

                    ' Transformar el resultado del Record Set a XML para guardarlo en el objeto SICA
                    Dim oXML As System.Xml.XmlDocument = nvXMLSQL.RecordsetToXML(rs, arParam, primary_keys:=primary_keys)
                    nvDBUtiles.DBCloseRecordset(rs, False)

                    Dim strXML As String = oXML.OuterXml
                    oBytes = nvConvertUtiles.StringToBytes(strXML)
                    oSicaParametroDef.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                    objME.childObjects.Add(oSicaParametroDef)


                    '--- Agregar todos los elementos que conformen el arbol, desde el nodo padre del actual hasta la raiz (tabla "Parametros_Nodos") ---
                    ' Armar el SQL completo que recupera los resultados ordenados de una variable de tabla SQL
                    Dim sb As New StringBuilder()
                    sb.AppendFormat("SET NOCOUNT ON {0}", vbCrLf)
                    sb.AppendFormat("DECLARE @nro_par_nodo_dep INT {0}", vbCrLf)
                    sb.AppendFormat("DECLARE @par_nodo_tipo CHAR(1) = '' {0}", vbCrLf)
                    sb.AppendFormat("DECLARE @id_param VARCHAR(50) = '{0}' {1}", id_param, vbCrLf)
                    sb.AppendFormat("DECLARE @tree_level INT = 1000 {0}", vbCrLf)
                    sb.AppendFormat("DECLARE @table TABLE(nro_par_nodo INT NOT NULL, par_nodo VARCHAR(100), nro_par_nodo_dep INT NULL, par_nodo_tipo CHAR(1), id_param VARCHAR(100), hardcode BIT, orden INT, informacion VARCHAR(250) NULL, tree_level INT) {0}", vbCrLf)

                    sb.AppendFormat("SELECT @nro_par_nodo_dep = nro_par_nodo_dep, @par_nodo_tipo = par_nodo_tipo FROM Parametros_Nodos WHERE id_param=@id_param {0}", vbCrLf)

                    sb.AppendFormat("INSERT INTO @table {0}", vbCrLf)
                    sb.AppendFormat(" SELECT nro_par_nodo, par_nodo, nro_par_nodo_dep, par_nodo_tipo, id_param, hardcode, orden, informacion, @tree_level AS tree_level {0}", vbCrLf)
                    sb.AppendFormat("  FROM Parametros_Nodos {0}", vbCrLf)
                    sb.AppendFormat("  WHERE id_param = @id_param {0}", vbCrLf)

                    sb.AppendFormat("IF (SELECT COUNT(*) FROM @table) > 0 {0}", vbCrLf) ' Está al menos el nodo buscado (id_param) --> sino, queda bucleando infinitamente
                    sb.AppendFormat(" BEGIN {0}", vbCrLf) ' Begin del IF
                    sb.AppendFormat(" SET @tree_level = @tree_level - 1 {0}", vbCrLf)

                    sb.AppendFormat(" WHILE (NOT @nro_par_nodo_dep IS NULL OR @par_nodo_tipo <> 'R') {0}", vbCrLf)
                    sb.AppendFormat("  BEGIN {0}", vbCrLf)    ' Begin del While
                    sb.AppendFormat("   INSERT INTO @table {0}", vbCrLf)
                    sb.AppendFormat("    SELECT nro_par_nodo, par_nodo, nro_par_nodo_dep, par_nodo_tipo, id_param, hardcode, orden, informacion, @tree_level AS tree_level {0}", vbCrLf)
                    sb.AppendFormat("     FROM Parametros_Nodos {0}", vbCrLf)
                    sb.AppendFormat("     WHERE nro_par_nodo = @nro_par_nodo_dep {0}", vbCrLf)

                    sb.AppendFormat("    SELECT @nro_par_nodo_dep = nro_par_nodo_dep, @par_nodo_tipo = par_nodo_tipo FROM Parametros_Nodos WHERE nro_par_nodo=@nro_par_nodo_dep {0}", vbCrLf)
                    sb.AppendFormat("    SET @tree_level = @tree_level - 1 {0}", vbCrLf)
                    sb.AppendFormat("  END {0}", vbCrLf) ' End del While
                    sb.AppendFormat(" END {0}", vbCrLf) ' End del IF

                    sb.AppendFormat("SELECT nro_par_nodo, par_nodo, nro_par_nodo_dep, par_nodo_tipo, id_param, hardcode, orden, informacion FROM @table ORDER BY tree_level {0}", vbCrLf)

                    strSQL = sb.ToString()
                    sb = Nothing
                    Dim rsArbol As ADODB.Recordset = conn.Execute(strSQL)

                    If Not rsArbol.EOF Then
                        oPath = cn & "\Parametros_Nodos"
                        oObjeto = "Nodos arbol de " & id_param
                        oCod_subtipo = 0
                        primary_keys = New List(Of String)
                        primary_keys.Add("par_nodo")
                        primary_keys.Add("par_nodo_tipo")
                        arParam = New trsParam
                        oXML = nvXMLSQL.RecordsetToXML(rsArbol, arParam, primary_keys:=primary_keys)
                        nvDBUtiles.DBCloseRecordset(rsArbol, False)
                        strXML = oXML.OuterXml
                        oBytes = nvConvertUtiles.StringToBytes(strXML)

                        Dim oSicaParametrosNodos As New tSicaObjeto
                        oSicaParametrosNodos.loadFromImplementation(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, oPath, oObjeto, oCod_subtipo, False, oBytes)
                        objME.childObjects.Add(oSicaParametrosNodos)
                    End If


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
                    Throw New Exception("No fué posible cargar el objeto Parámetro desde la implementación", ex)
                End Try
            End Sub



            Public Function hasImplementation() As Boolean Implements InvSicaObjetoGrupo.hasImplementation
                Return True
            End Function



            Public Sub saveToImplementation(objMe As tSicaObjeto, nvApp As tnvApp) Implements InvSicaObjetoGrupo.saveToImplementation
                ' Verificar que esté el objeto "nvApp" de la implementación en el "objMe" (en implementation_nvApp)
                If objMe.implemantation_nvApp Is Nothing AndAlso Not nvApp Is Nothing Then objMe.implemantation_nvApp = nvApp

                ' No hace falta agregar el objeto base (Parametro), sólo los hijos de tipo "Dato"
                For Each child As tSicaObjeto In objMe.childObjects
                    Me.objeto_agregar(child.cod_objeto, child.cod_obj_tipo, objMe.implemantation_nvApp, child.modulo_version_path, child.bytes)
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

                    If cn = "" Then cn = "default"

                    nvcn = nvApp.app_cns(cn).clone()
                    nvcn.excaslogin = False

                    Dim _paramXML As String = nvConvertUtiles.BytesToString(bytes)
                    Dim oXml As New System.Xml.XmlDocument
                    oXml.LoadXml(_paramXML)


                    ' El caso de los NODOS de parámetros los trabajamos aparte
                    If tabla.ToLower = "parametros_nodos" Then
                        MakeParameterTree(cod_objeto, oXml, nvcn)
                    Else
                        '****************************************************************************************************
                        ' Para ésta implementación los permisos, tanto grupo como detalle, deben coincidir
                        ' Para ello buscamos con los "params" del XML de definición, el número que corresponda en la
                        ' implementación.
                        '
                        ' En cuanto al permiso detalle debe coincidir "nro_permiso" y "Permitir", sino salir con "Exception"
                        '****************************************************************************************************
                        Dim nodo_parametro As System.Xml.XmlNode = nvXMLUtiles.selectSingleNode(oXml, "xml/rs:data/z:row")
                        If nodo_parametro Is Nothing Then nodo_parametro = nvXMLUtiles.selectSingleNode(oXml, "xml/rs:data/rs:insert/z:row")

                        Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)

                        If nodo_parametro IsNot Nothing Then
                            conn.BeginTrans()
                            Dim rs As ADODB.Recordset = Nothing

                            Try
                                Dim query As String = String.Empty
                                Dim param As String = nvXMLUtiles.getAttribute_path(nodo_parametro, "@param", "")

                                ' 1) Obtener los datos adicionales de permisos
                                Dim nro_permiso_grupo As Integer = nvXMLUtiles.getAttribute_path(oXml, "xml/params/@nro_permiso_grupo", "0")
                                Dim permiso_grupo As String = nvXMLUtiles.getAttribute_path(oXml, "xml/params/@permiso_grupo", "")
                                Dim nro_permiso As Integer = nvXMLUtiles.getAttribute_path(oXml, "xml/params/@nro_permiso", "0")
                                Dim Permitir As String = nvXMLUtiles.getAttribute_path(oXml, "xml/params/@Permitir", "")

                                ' 2) Controlar los permisos en la implementación
                                '   2.1) Si falla algo lanzar Excepción
                                query = String.Format("SELECT nro_permiso_grupo FROM operador_permiso_grupo WHERE permiso_grupo='{0}'", permiso_grupo)
                                rs = conn.Execute(query)

                                If rs.EOF Then Throw New Exception("No existe el grupo de permisos asociado al parámetro <b>" & param & "</b>")

                                ' Guardo el numero de grupo correcto
                                If nro_permiso_grupo <> rs.Fields("nro_permiso_grupo").Value Then nro_permiso_grupo = rs.Fields("nro_permiso_grupo").Value

                                nvDBUtiles.DBCloseRecordset(rs, False)

                                ' Controlar el permiso detalle; si es '0' lo dejo pasar
                                If nro_permiso <> 0 Then
                                    query = String.Format("SELECT COUNT(*) AS [count] FROM operador_permiso_detalle WHERE nro_permiso_grupo={0} AND nro_permiso={1} AND Permitir='{2}'", nro_permiso_grupo, nro_permiso, Permitir)
                                    rs = conn.Execute(query)

                                    If Not rs.EOF AndAlso rs.Fields("count").Value = 0 Then Throw New Exception("El permiso asociado al parámetro NO coincide. (Grupo= " & permiso_grupo & ", Nro. Permiso= " & nro_permiso & ", Detalle= " & Permitir & ")")

                                    nvDBUtiles.DBCloseRecordset(rs, False)
                                End If

                                ' 3) Controlar si ya existe el parametro_def en la implementación y realizar la acción correcta (Update || Insert)
                                Dim id_param As String = nvXMLUtiles.getAttribute_path(nodo_parametro, "@id_param", "")
                                If id_param = String.Empty Then Throw New Exception("La clave del parámetro (id_param) es nulo o inválido.")

                                query = String.Format("SELECT COUNT(*) AS [count] FROM Parametros_Def WHERE id_param='{0}'", id_param)
                                rs = conn.Execute(query)
                                Dim count As Integer = rs.Fields("count").Value
                                nvDBUtiles.DBCloseRecordset(rs, True)

                                If count > 1 Then
                                    ' ERROR
                                    Throw New Exception("Hay más de un parámetro que coincide con '" & id_param & "' (id_param)")
                                Else
                                    ' Obtener el resto de los parametros (sólo falta "param_tipo" y "encriptar")
                                    Dim param_tipo As Integer = Integer.Parse(nvXMLUtiles.getAttribute_path(nodo_parametro, "@param_tipo", "104"))
                                    Dim encriptar As String = If(nvXMLUtiles.getAttribute_path(nodo_parametro, "@encriptar", "False").ToString.ToLower = "true", "1", "0")

                                    If count = 0 Then
                                        ' INSERT
                                        query = "INSERT INTO Parametros_Def (id_param, param, param_tipo, nro_permiso_grupo, nro_permiso, encriptar) "
                                        query &= String.Format("VALUES ('{0}', '{1}', {2}, {3}, {4}, {5})", id_param, param, param_tipo, nro_permiso_grupo, nro_permiso, encriptar)
                                        conn.Execute(query)
                                    Else
                                        ' UPDATE
                                        query = String.Format("UPDATE Parametros_Def SET param='{0}', param_tipo={1}, nro_permiso_grupo={2}, nro_permiso={3}, encriptar={4} ", param, param_tipo, nro_permiso_grupo, nro_permiso, encriptar)
                                        query &= String.Format("WHERE id_param='{0}'", id_param)
                                        conn.Execute(query)
                                    End If
                                End If

                                conn.CommitTrans()
                            Catch ex As Exception
                                conn.RollbackTrans()
                                Throw ex
                            Finally
                                Try
                                    conn.Close()
                                    ' rs.Close()
                                Catch ex As Exception
                                End Try
                            End Try
                        End If
                    End If
                End If
            End Sub



            Private Sub MakeParameterTree(ByVal cod_objeto As Integer, ByVal oXml As System.Xml.XmlDocument, ByVal nvcn As tDBConection)
                ' Armar la conexion con nvcn
                Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)
                conn.BeginTrans()
                Dim rs As ADODB.Recordset

                Try
                    Dim query As String
                    Dim nodeNames As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXml, "xml/s:Schema/s:ElementType/s:AttributeType")
                    Dim pks As New List(Of String)
                    Dim campo As String

                    ' Obtener todas las PKs
                    For Each nodeName In nodeNames
                        campo = nvXMLUtiles.getAttribute_path(nodeName, "@name", "Error")
                        If nvXMLUtiles.getAttribute_path(nodeName, "@pk", "false") = "true" Then pks.Add(campo)
                    Next

                    Dim nodos As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXml, "xml/rs:data/z:row")
                    If nodos.Count = 0 Then nodos = nvXMLUtiles.selectNodes(oXml, "xml/rs:data/rs:insert/z:row")

                    ' Variable que se actualiza en cada ciclo
                    Dim nro_par_nodo As Integer = 0
                    Dim dependencias_nodos_old_new As New Dictionary(Of Integer, Integer)

                    ' Nodos tiene al menos al nodo RAIZ
                    For Each nodo As System.Xml.XmlNode In nodos
                        ' Armar strWhere con los campos primary key
                        Dim strWhere As New List(Of String)

                        For Each pk As String In pks
                            strWhere.Add(String.Format("{0}='{1}'", pk, nvXMLUtiles.getAttribute_path(nodo, "@" & pk, "")))
                        Next

                        query = "SELECT COUNT(*) AS [count] FROM Parametros_Nodos WHERE "
                        query &= String.Join(" AND ", strWhere)

                        Dim par_nodo_tipo As String = nvXMLUtiles.getAttribute_path(nodo, "@par_nodo_tipo", "")
                        Dim nro_par_nodo_dep As String = nvXMLUtiles.getAttribute_path(nodo, "@nro_par_nodo_dep", "0")
                        '*
                        '|-------------------------------------------------------------------------
                        '| Control de NODO tipo PARAMETRO
                        '|-------------------------------------------------------------------------
                        '| Si el nodo es tipo PARAMETRO, controlar que coincida con el nodo 
                        '| dependiente, ya que sino, se controla que el nodo no tenga la misma
                        '| descripción globalmente y ésto ocasiona un error, porque no podríamos
                        '| realizar un implementación con el mismo nombre de nodo en dos módulos
                        '| diferentes.
                        '|
                        '| Ejemplo:
                        '|  (M) Módulo A
                        '|  |__(P) Parámetro test
                        '|  |__(P) Parámetro test 2
                        '|  (M) Módulo B
                        '|  |__(P) Parámetro test           <-- Daría error porque éste nombre ya 
                        '|  |                                   está en otro módulo
                        '|  |__(P) Parámetro test 28
                        '|
                        '| Por lo tanto se debe controlar de quién depende el párametro actual y 
                        '| hacer el conteo sobre ello.
                        '*
                        If par_nodo_tipo.ToUpper() = "P" Then
                            query &= " AND nro_par_nodo_dep=" & dependencias_nodos_old_new(nro_par_nodo_dep)
                        End If

                        rs = conn.Execute(query)

                        ' Recuperacion del "nro_par_nodo"
                        If Not rs.EOF Then
                            Dim count As Integer = rs.Fields("count").Value
                            nvDBUtiles.DBCloseRecordset(rs, False)

                            ' Si hay mas de 1 coincidencia --> salir con excepcion
                            If count > 1 Then Throw New Exception("Hay más de una coincidencia de nodos de parámetro con los datos suministrados. Controle que las columnas de PK (" & String.Join(", ", pks) & ") retornen resultados únicos.")

                            ' Insertar el nodo y recuperar su ID (nro_par_nodo) para usarlo luego con las dependencias
                            Dim nro_par_nodo_DEF As String = nvXMLUtiles.getAttribute_path(nodo, "@nro_par_nodo", "0")
                            Dim par_nodo As String = nvXMLUtiles.getAttribute_path(nodo, "@par_nodo", "")
                            Dim id_param As String = nvXMLUtiles.getAttribute_path(nodo, "@id_param", "")
                            Dim hardcode As String = If(nvXMLUtiles.getAttribute_path(nodo, "@hardcode", "False").ToString.ToLower = "true", "1", "0")
                            Dim orden As String = nvXMLUtiles.getAttribute_path(nodo, "@orden", "0")
                            Dim informacion As String = nvXMLUtiles.getAttribute_path(nodo, "@informacion", "")

                            '-- INSERT: no existe el NODO bajo análisis --
                            If count = 0 Then
                                ' Actuar dependiendo del tipo de nodo (R: raiz, M: modulo, P: parametro)
                                Select Case par_nodo_tipo.ToUpper
                                    Case "R"
                                        ' Usar el "nro_par_nodo" para el valor de "nro_par_nodo_dep", salvo que sea "0", entonces pasar "null"
                                        query = "INSERT INTO Parametros_Nodos (par_nodo, nro_par_nodo_dep, par_nodo_tipo, id_param, hardcode, orden, informacion) " &
                                                "VALUES ('" & par_nodo & "'," &
                                                        "null," &
                                                        "'R'," &
                                                        "'" & id_param & "'," &
                                                        hardcode & "," &
                                                        orden & "," &
                                                        If(informacion <> String.Empty, "'" & informacion & "'", "null") &
                                                    ")" & vbCrLf &
                                                "SELECT @@IDENTITY AS nro_par_nodo" & vbCrLf

                                        rs = conn.Execute(query)
                                        If Not rs.EOF Then nro_par_nodo = rs.Fields("nro_par_nodo").Value
                                        nvDBUtiles.DBCloseRecordset(rs, False)
                                        dependencias_nodos_old_new.Add(nro_par_nodo_DEF, nro_par_nodo)  ' Salvar el ID viejo contra el nuevo, asi podemos armar las dependencias correctamente


                                    Case "M"
                                        query = "INSERT INTO Parametros_Nodos (par_nodo, nro_par_nodo_dep, par_nodo_tipo, id_param, hardcode, orden, informacion) " &
                                                "VALUES ('" & par_nodo & "'," &
                                                        dependencias_nodos_old_new(nro_par_nodo_dep) & "," &
                                                        "'M'," &
                                                        "'" & id_param & "'," &
                                                        hardcode & "," &
                                                        orden & "," &
                                                        If(informacion <> String.Empty, "'" & informacion & "'", "null") &
                                                    ")" & vbCrLf &
                                                "SELECT @@IDENTITY AS nro_par_nodo" & vbCrLf

                                        rs = conn.Execute(query)
                                        If Not rs.EOF Then nro_par_nodo = rs.Fields("nro_par_nodo").Value
                                        nvDBUtiles.DBCloseRecordset(rs, False)
                                        dependencias_nodos_old_new.Add(nro_par_nodo_DEF, nro_par_nodo)


                                    Case "P"
                                        ' En PARAMETRO no hace falta obtener el "nro_par_nodo" ya que es una hoja en el arbol
                                        query = "INSERT INTO Parametros_Nodos (par_nodo, nro_par_nodo_dep, par_nodo_tipo, id_param, hardcode, orden, informacion) " &
                                                "VALUES ('" & par_nodo & "'," &
                                                        dependencias_nodos_old_new(nro_par_nodo_dep) & "," &
                                                        "'P'," &
                                                        "'" & id_param & "'," &
                                                        hardcode & "," &
                                                        orden & "," &
                                                        If(informacion <> String.Empty, "'" & informacion & "'", "null") &
                                                    ")"

                                        conn.Execute(query)

                                End Select

                            Else
                                '-- UPDATE: actualizar el NODO bajo análisis --

                                ' recupero el "nro_par_nodo"
                                query = "SELECT nro_par_nodo FROM Parametros_Nodos WHERE " & String.Join(" AND ", strWhere)
                                rs = conn.Execute(query)

                                If Not rs.EOF Then
                                    nro_par_nodo = rs.Fields("nro_par_nodo").Value
                                    dependencias_nodos_old_new.Add(nro_par_nodo_DEF, nro_par_nodo)
                                End If

                                nvDBUtiles.DBCloseRecordset(rs, False)

                                ' Actualizar dependiendo del tipo de nodo (R: raiz, M: modulo, P: parametro)
                                Select Case par_nodo_tipo.ToUpper
                                    Case "R"
                                        query = "UPDATE Parametros_Nodos "
                                        query &= String.Format("SET par_nodo='{0}', nro_par_nodo_dep=null, par_nodo_tipo='R', id_param='', hardcode={1}, orden={2}, informacion={3} ", par_nodo, hardcode, orden, If(informacion = "", "null", "'" & informacion & "'"))
                                        query &= String.Format("WHERE {0}", String.Join(" AND ", strWhere))
                                        conn.Execute(query)


                                    Case "M"
                                        query = "UPDATE Parametros_Nodos "
                                        query &= String.Format("SET par_nodo='{0}', nro_par_nodo_dep={1}, par_nodo_tipo='M', id_param='', hardcode={2}, orden={3}, informacion={4} ", par_nodo, dependencias_nodos_old_new(nro_par_nodo_dep), hardcode, orden, If(informacion = "", "null", "'" & informacion & "'"))
                                        query &= String.Format("WHERE {0}", String.Join(" AND ", strWhere))
                                        conn.Execute(query)


                                    Case "P"
                                        query = "UPDATE Parametros_Nodos "
                                        query &= String.Format("SET par_nodo='{0}', nro_par_nodo_dep={1}, par_nodo_tipo='P', id_param='{2}', hardcode={3}, orden={4}, informacion={5} ", par_nodo, dependencias_nodos_old_new(nro_par_nodo_dep), id_param, hardcode, orden, If(informacion = "", "null", "'" & informacion & "'"))
                                        query &= String.Format("WHERE {0}", String.Join(" AND ", strWhere))
                                        conn.Execute(query)

                                End Select
                            End If
                        End If

                        '   nvDBUtiles.DBCloseRecordset(rs, False)
                    Next

                    conn.CommitTrans()
                Catch ex As Exception
                    conn.RollbackTrans()
                    Throw ex
                Finally
                    Try
                        conn.Close()
                    Catch ex As Exception
                    End Try
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
                        childRes = checkIntegrity_parametros(child, resChilds, nvApp)

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



            Private Function checkIntegrity_parametros(objMe As tSicaObjeto, resCabChilds As tResCab, nvApp As tnvApp) As nvenumResStatus
                '**************************************************************************************
                ' Comparar ambos binarios y devolver el resultado
                '
                '   Si ningun dato existe:                        nvenumResStatus.objeto_no_econtrado
                '   Si existen algunos de las PK y son distintas: nvenumResStatus.objeto_modificado
                '   Si existen todos y son iguales:               nvenumResStatus.OK
                '**************************************************************************************
                Dim tabla As String = If(objMe.modulo_version_path.Split("\").Length = 2, objMe.modulo_version_path.Split("\")(1), "")

                Dim strXML As String = nvConvertUtiles.BytesToString(objMe.bytes)
                Dim oXmlDefinicion As New System.Xml.XmlDocument
                oXmlDefinicion.LoadXml(strXML)

                Dim nodesDefinicion As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlDefinicion, "xml/rs:data/z:row")
                If nodesDefinicion.Count = 0 Then nodesDefinicion = nvXMLUtiles.selectNodes(oXmlDefinicion, "xml/rs:data/rs:insert/z:row")

                ' Controlar que el objMe tenga asociada la app
                If objMe.implemantation_nvApp Is Nothing Then objMe.implemantation_nvApp = nvApp

                ' Obtener el objeto sica de la Implementacion
                Dim oSicaImplementacion As New tSicaObjeto
                oSicaImplementacion.loadFromImplementation(objMe.implemantation_nvApp, objMe.cod_obj_tipo, objMe.modulo_version_path, objMe.objeto, objMe.modulo_version_cod_sub_tipo, True, objMe.bytes)

                Dim resElement As New tResElement
                resElement.cod_objeto = objMe.cod_objeto
                resElement.cod_obj_tipo = objMe.cod_obj_tipo
                resElement.path = objMe.modulo_version_path
                resElement.cod_sub_tipo = objMe.modulo_version_cod_sub_tipo
                resElement.objeto = objMe.objeto
                resElement.cod_modulo_version = objMe.cod_modulo_version
                resElement.cod_pasaje = objMe.modulo_version_cod_pasaje
                resElement.comentario = ""

                If oSicaImplementacion.bytes Is Nothing OrElse oSicaImplementacion.bytes.Count = 0 Then
                    resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                    resElement.comentario = String.Format("No existe el objeto ({0}) en la implementación", objMe.objeto)
                    resCabChilds.elements.Add(resElement)
                    Return nvenumResStatus.objeto_no_econtrado
                End If

                strXML = nvConvertUtiles.BytesToString(oSicaImplementacion.bytes)
                Dim oXmlImplementacion As New System.Xml.XmlDocument
                oXmlImplementacion.LoadXml(strXML)

                Dim columnsToAvoid As New List(Of String)
                Dim xPathAvoid As String = ""

                ' Setear las columnas a ignorar al momento de buscar en el XML
                If tabla.ToLower <> "parametros_def" Then
                    columnsToAvoid.Add("@name != 'nro_par_nodo'")
                    columnsToAvoid.Add("@name != 'nro_par_nodo_dep'")
                    xPathAvoid = String.Join(" and ", columnsToAvoid)
                End If

                ' PK y columnas --> obtener desde DEFINICION
                ' Ésto es así porque podríamos haber definido otra/s PKs diferente a la que está por defecto o no tener una y definirla nosotros;
                ' además podríamos haber definido el dato habiendo seleccionado solo algunas columnas en lugar de la totalidad
                Dim nodesPK As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlDefinicion, "xml/s:Schema/s:ElementType/s:AttributeType[@pk='true']")
                Dim nodesFields As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXmlDefinicion, "xml/s:Schema/s:ElementType/s:AttributeType" & If(xPathAvoid <> "", "[" & xPathAvoid & "]", ""))

                ' Buscar el "nro_permiso_grupo" que le corresponde en la Implementación
                Dim permiso_grupo As String = ""
                Dim nro_permiso_grupo_Implementacion As Integer = 0

                If tabla.ToLower = "parametros_def" Then
                    permiso_grupo = nvXMLUtiles.getAttribute_path(oXmlDefinicion, "xml/params/@permiso_grupo")
                    nro_permiso_grupo_Implementacion = 0
                End If

                If permiso_grupo <> "" Then
                    Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(emunDBType.db_other, nvApp.app_cns("default"))
                    Dim strSQL As String = String.Format("SELECT nro_permiso_grupo FROM operador_permiso_grupo WHERE permiso_grupo='{0}'", permiso_grupo)
                    Dim rs As ADODB.Recordset = conn.Execute(strSQL)

                    If Not rs.EOF Then nro_permiso_grupo_Implementacion = rs.Fields("nro_permiso_grupo").Value

                    nvDBUtiles.DBCloseRecordset(rs)
                End If

                Dim nodePK As System.Xml.XmlNode
                Dim iguales As Boolean
                Dim xPath As String
                Dim encontrados As Integer = 0
                Dim count_distintos As Integer = 0
                Dim table As String = resElement.path.Split("\")(1)
                Dim nodesImplementacion As System.Xml.XmlNodeList


                Dim attributeNamePK As String
                Dim attributeName As String

                For i = 0 To nodesDefinicion.Count - 1
                    xPath = ""
                    attributeNamePK = ""

                    Try
                        If nodesPK.Count = 0 Then Throw New Exception("La tabla " & table & " no tiene definida ninguan PK.")

                        For Each nodePK In nodesPK
                            attributeNamePK = nodePK.Attributes("name").Value

                            If xPath = "" Then
                                xPath &= String.Format("@{0}='{1}'", attributeNamePK, nodesDefinicion(i).Attributes(attributeNamePK).Value)
                            Else
                                xPath &= String.Format(" and @{0}='{1}'", attributeNamePK, nodesDefinicion(i).Attributes(attributeNamePK).Value)
                            End If
                        Next
                    Catch ex As Exception
                        Throw New Exception("No se encontró el atributo de clave primaria (PK: " & attributeNamePK & ") en los nodos de Definición (tabla: " & table & ").", ex)
                    End Try

                    ' Anexamos al xPath el valor de "nro_permiso_grupo" de la implementacion
                    If tabla.ToLower = "parametros_def" Then xPath &= String.Format(" and @nro_permiso_grupo='{0}'", nro_permiso_grupo_Implementacion)

                    nodesImplementacion = nvXMLUtiles.selectNodes(oXmlImplementacion, "xml/rs:data/z:row[" & xPath & "]")
                    If nodesImplementacion.Count = 0 Then nodesImplementacion = nvXMLUtiles.selectNodes(oXmlImplementacion, "xml/rs:data/rs:insert/z:row[" & xPath & "]")

                    If nodesImplementacion.Count = 1 Then
                        encontrados += 1
                        iguales = True

                        For Each field In nodesFields
                            attributeName = field.Attributes("name").Value

                            If nodesDefinicion(i).Attributes(attributeName) Is Nothing OrElse nodesImplementacion(0).Attributes(attributeName) Is Nothing Then
                                If nodesDefinicion(i).Attributes(attributeName) IsNot Nothing OrElse nodesImplementacion(0).Attributes(attributeName) IsNot Nothing Then
                                    Dim definicionIsNull As Boolean = IsDBNull(nodesDefinicion(i).Attributes(attributeName)) OrElse nodesDefinicion(i).Attributes(attributeName) Is Nothing
                                    resElement.comentario &= table & "@" & attributeName & ": valor nulo en " & If(definicionIsNull, "definición", "implementación") & "</br>"
                                    iguales = False
                                    Exit For
                                End If
                            Else
                                If nodesDefinicion(i).Attributes(attributeName).Value <> nodesImplementacion(0).Attributes(attributeName).Value Then
                                    resElement.comentario &= table & "@" & attributeName & ": difiere entre definición (" & nodesDefinicion(i).Attributes(attributeName).Value & ") e implementación (" & nodesImplementacion(0).Attributes(attributeName).Value & ")</br>"
                                    iguales = False
                                    Exit For
                                End If
                            End If
                        Next

                        If Not iguales Then count_distintos += 1
                    Else
                        If nodesImplementacion.Count = 0 Then
                            resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                        ElseIf nodesImplementacion.Count > 1 Then
                            resElement.resStatus = nvenumResStatus.archivo_sobrante
                            resElement.comentario = "Hay más de una coincidencia al comparar contra la implementación. Revisar que las PKs utilizadas obtengan resultados únicos"
                        End If
                    End If
                Next

                If encontrados = 0 Then
                    resElement.resStatus = nvenumResStatus.objeto_no_econtrado
                    resCabChilds.elements.Add(resElement)
                    Return nvenumResStatus.objeto_no_econtrado
                ElseIf count_distintos > 0 OrElse (encontrados <> nodesDefinicion.Count) Then
                    resElement.resStatus = nvenumResStatus.objeto_modificado
                    resCabChilds.elements.Add(resElement)
                    Return nvenumResStatus.objeto_modificado
                End If

                Return nvenumResStatus.OK
            End Function


        End Class
    End Namespace
End Namespace
