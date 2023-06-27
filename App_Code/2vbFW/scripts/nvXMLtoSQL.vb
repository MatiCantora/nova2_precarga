Imports System.Xml
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports System
Imports System.Text.RegularExpressions

Namespace nvFW

    Public Class nvXMLSQL

        ''' <summary>
        ''' Encripta un fitlroXML para poder utilizarlo fuera del middleware
        ''' </summary>
        ''' <param name="strXML">La consulta XML sin encriptar</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function encXMLSQL(ByVal strXML As String) As String
            Dim res As String = "<enc><![CDATA[" & nvSecurity.nvCrypto.StrToEncBase64(strXML) & "]]></enc>"
            Return res
        End Function

        '***********************************************************************************
        ' Devuelve un recordset con los datos y objError con el resultado de la operación
        ' xmlCriterio = FiltroXML
        ' xmlCriterio_add = FiltroWhere
        ' arParam = parametros adicionales de ejecución
        ' arParam['timeout'] = tiempo máximo de ejecución 
        ' arParam['SQL'] = devuelve el TSQL correspondiente
        ' arParam['objError'] = devuelve el codigo de error, 0 = OK
        '***********************************************************************************

        ''' <summary>
        ''' Devuelve un recordset con los datos y objError con el resultado de la operación
        ''' </summary>
        ''' <param name="xmlCriterio">La consulta XML sin encriptar</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function XMLtoRecordset(ByVal xmlCriterio As String) As ADODB.Recordset
            Dim arParam As trsParam = New trsParam
            arParam("SQL") = ""
            arParam("timeout") = 0
            arParam("objError") = Nothing
            Return XMLtoRecordset(xmlCriterio, "", arParam)
        End Function

        ''' <summary>
        ''' Devuelve un recordset con los datos y objError con el resultado de la operación
        ''' </summary>
        ''' <param name="xmlCriterio">La consulta XML sin encriptar</param>
        ''' <param name="xmlCriterio_add">FiltroWhere</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function XMLtoRecordset(ByVal xmlCriterio As String, ByVal xmlCriterio_add As String) As ADODB.Recordset
            Dim arParam As trsParam = New trsParam
            arParam("SQL") = ""
            arParam("timeout") = 0
            arParam("objError") = Nothing
            Return XMLtoRecordset(xmlCriterio, xmlCriterio_add, arParam)
        End Function

        ''' <summary>
        ''' Devuelve el recorset resultado de la consulta XML.
        ''' </summary>
        ''' <param name="xmlCriterio">Consulta XML</param>
        ''' <param name="xmlCriterio_add">filtroWhere</param>
        ''' <param name="arParam">Parametros adicionales de la llamada</param>
        ''' <param name="ActiveConnections">Colección de conexiones activas</param>
        ''' <returns></returns>
        ''' <remarks>arParam['timeout'] = tiempo máximo de ejecución 
        ''' arParam['SQL'] = devuelve el TSQL correspondiente
        ''' arParam['objError'] = devuelve el codigo de error, 0 = OK
        ''' </remarks>
        Public Shared Function XMLtoRecordset(ByVal xmlCriterio As String, ByVal xmlCriterio_add As String, ByVal arParam As trsParam, Optional ByRef ActiveConnections As Dictionary(Of String, ADODB.Connection) = Nothing) As ADODB.Recordset
            Dim objXML As New System.Xml.XmlDocument
            Dim objXMLAdd As New System.Xml.XmlDocument
            Dim rs As ADODB.Recordset = Nothing
            Dim cacheID As String = ""
            Dim objError As New nvFW.tError()
            objError.debug_src = "nvXMLtoSQL.vb::XMLtoRecordset"

            Try
                objXML.LoadXml(xmlCriterio)
            Catch ex As Exception
                ' Error en el filtro XML
                objError.parse_error_xml(ex)
                objError.titulo = "Error en la consulta"
                objError.mensaje = "Error XML en el criterio"
                objError.debug_desc = objError.debug_desc & ";" & xmlCriterio
                arParam("objError") = objError
                Return Nothing
            End Try

            If objXML.SelectSingleNode("criterio/select") Is Nothing AndAlso objXML.SelectSingleNode("criterio/procedure") Is Nothing Then
                objError.numError = 106
                objError.titulo = "Error en la consulta"
                objError.mensaje = "Error XML en el criterio"
                objError.debug_desc = "No existe ni Select ni Procedure"
                arParam("objError") = objError
                Return Nothing
            End If

            If xmlCriterio_add <> "" Then
                Try
                    objXMLAdd.LoadXml(xmlCriterio_add)
                Catch ex As Exception
                    ' Error en el filtro XML
                    objError.parse_error_xml(ex)
                    objError.titulo = "Error en la consulta"
                    objError.mensaje = "Error XML en el criterio_add"
                    objError.debug_desc = objError.debug_desc & ";" & xmlCriterio_add
                    arParam("objError") = objError
                    Return Nothing
                End Try
            End If

            arParam("tipo") = IIf(objXML.SelectSingleNode("criterio/select") Is Nothing, "procedure", "select")
            If arParam("timeout").ToString = "" Then arParam("timeout") = 0

            ' Valores de paginación
            Dim PageSize As Integer = nvXMLUtiles.getAttribute_path(objXML, "criterio/" + arParam("tipo") + "/@PageSize", 0)
            Dim AbsolutePage = nvXMLUtiles.getAttribute_path(objXML, "criterio/" + arParam("tipo") + "/@AbsolutePage", 0)

            ' Valor de orden
            Dim strOrden As String = ""

            If arParam("tipo") = "select" Then
                strOrden = nvXMLUtiles.getNodeText(objXML, "criterio/select/orden", "")
            Else
                strOrden = nvXMLUtiles.getNodeText(objXML, "select/orden", "")
            End If

            '******************************************************
            ' Cargar el recordset y los parametros desde la cache
            '******************************************************
            Dim cacheControl As String = nvXMLUtiles.getAttribute_path(objXML, "criterio/" & arParam("tipo") & "/@cacheControl", "none")
            Dim expire_minutes As Integer = nvXMLUtiles.getAttribute_path(objXML, "criterio/" & arParam("tipo") & "/@expire_minutes", 1)

            If cacheControl.ToLower() = "session" Then
                cacheID = nvXMLUtiles.getAttribute_path(objXML, "criterio/" & arParam("tipo") & "/@cacheID", "")

                If cacheID <> "" Then
                    Dim params1 As Dictionary(Of String, Object) = New Dictionary(Of String, Object)
                    params1.Add("cacheID", cacheID)
                    Dim cache = nvCache.getCache("rs", params1)

                    If Not cache Is Nothing Then
                        Dim arParam2 As trsParam = cache.Valores("arParam")

                        For Each p In arParam2.Keys
                            arParam(p) = arParam2(p)
                        Next

                        arParam("PageSize") = PageSize
                        arParam("AbsolutePage") = AbsolutePage
                        arParam("orden") = strOrden
                        arParam("cache") = True
                        arParam("cache_absolute_expire") = cache.expireAbsolute.ToString("yyyy/mm/dd hh:mm:ss")

                        ' Solo si se mantiene el mismo orden
                        If arParam("orden") = arParam("orden_original") Then
                            Return DBRecordsetCopiar(cache.Valores("rs"), arParam)
                        Else
                            AbsolutePage = 1
                        End If
                    End If
                End If
            End If

            arParam("PageSize") = PageSize
            arParam("AbsolutePage") = AbsolutePage

            ' Determinar la conexion a utilizar
            Dim cod_cn As String

            If arParam("tipo") = "select" Then
                cod_cn = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@cn", "default")
            Else
                cod_cn = nvXMLUtiles.getAttribute_path(objXML, "criterio/procedure/@cn", "default")
            End If

            If cod_cn.ToLower = "default" Then
                cod_cn = nvFW.nvApp.getInstance().app_cns("default").cod_ss_cn
            End If

            Dim top = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@top", "")
            arParam("top") = top

            Dim cn As ADODB.Connection
            If Not ActiveConnections Is Nothing Then
                If ActiveConnections.ContainsKey(cod_cn.ToLower) Then
                    cn = ActiveConnections(cod_cn.ToLower)
                Else
                    If Not nvDBUtiles.getDBConection(cod_cn) Is Nothing Then
                        cn = nvDBUtiles.DBConectar(cod_cn)
                        ActiveConnections.Add(cod_cn.ToLower, cn)
                    Else
                        objError.numError = 100
                        objError.titulo = "Error en la consulta"
                        objError.mensaje = "La conexión  '" & cod_cn & "' no existe"
                        arParam("objError") = objError
                        Return Nothing
                        'Throw New Exception("La conexión '" & cod_cn & "' no existe")
                    End If


                End If
            Else
                cn = nvDBUtiles.DBConectar(cod_cn)
            End If

            '******************************************************************
            ' Hay dos tipos de criterio uno es el select y otro el command
            '******************************************************************
            If Not objXML.SelectSingleNode("criterio/select") Is Nothing Then
                '*******************************************************************
                '                     Consulta select
                '*******************************************************************
                ' Generar sentencia SQL
                Dim strSQL As String = ""

                Try
                    strSQL = XMLtoSQL(xmlCriterio, xmlCriterio_add)
                Catch ex As Exception
                    objError.parse_error_script(ex)
                    objError.titulo = "Error en la consulta"
                    objError.mensaje = "La consulta XML no es consistente. " & objError.mensaje
                    objError.debug_src = "pvXMLtoSQL.asp:XMLtoSQL"
                    arParam("objError") = objError
                    Return Nothing
                End Try

                arParam("SQL") = strSQL

                ' Validar que exista la consulta
                If strSQL = "" Then
                    objError.titulo = "Error en la consulta"
                    objError.mensaje = "La consulta XML no es consistente. Conculta vacía"
                    arParam("objError") = objError
                    Return Nothing
                End If

                Dim forxml As String = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@forxml", "")
                Dim root As String = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@root", "")
                ' strSQL = "select cast((select verTablas_xml.* from verTablas_xml where [tabla!1!nro_tabla] in (42088, 42089, 42090, 42080) order by [tabla!1!nro_tabla] for xml explicit, root('tablas')) as text) as forxml_data"

                ' Si tiene clausula @forxml devuelve el resultado dentro del campo forxml_data
                If forxml <> "" Then
                    strSQL &= " for xml " & forxml

                    If root <> "" Then
                        strSQL &= " ,  root('" & root & "')"
                    End If

                    strSQL = "select cast((" & strSQL & ") as text) as forxml_data"
                End If

                Try
                    ' CursorType = 3 //statis
                    ' CursorLocation = 3 //Client
                    'Dim time_start As DateTime = Now()
                    arParam("orden_original") = strOrden
                    nvLog.parentLogTrack = arParam("logTrack")
                    Dim commandTimeout As Integer = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@CommandTimeout", arParam("timeout"))

                    rs = nvFW.nvDBUtiles.DBOpenRecordset(strSQL, 3, 1, commandTimeout, 3, , , , cn)

                    nvLog.parentLogTrack = ""
                    'Dim time_end As DateTime = Now()
                    'try{nvLog_addEvent("rd_XMLToRS", nvLog_getTrack() + ";" + strDate(time_start) + ";" + strDate(time_end) + ";" + strSQL)} catch(e){}
                Catch ex As Exception
                    objError.parse_error_script(ex)
                    objError.titulo = "Error en la consulta"
                    objError.mensaje = "Error en la ejecución de la consulta"
                    objError.debug_desc &= ";strSQL = '" & strSQL & "'"
                    arParam("objError") = objError
                    Return Nothing
                End Try
            End If

            '*******************************************************************
            '                     Procedimiento almacenado
            '*******************************************************************
            If Not objXML.SelectSingleNode("criterio/procedure") Is Nothing Then
                '*****************************************************************
                '                     Consulta procedure
                '***************************************************************** 
                ' Crea el objeto command, asigna la conexión y setea el tipo
                Dim commandText As String = nvXMLUtiles.getAttribute_path(objXML, "criterio/procedure/@CommandText", "")
                Dim commandTimeout As Integer = nvXMLUtiles.getAttribute_path(objXML, "criterio/procedure/@CommandTimeout", arParam("timeout"))
                Dim Cmd As New nvDBUtiles.tnvDBCommand(commandText,
                                                       ADODB.CommandTypeEnum.adCmdStoredProc,
                                                       nvDBUtiles.emunDBType.db_app, ,
                                                       ADODB.CursorTypeEnum.adOpenStatic, ,
                                                       commandTimeout,
                                                       ADODB.CursorLocationEnum.adUseClient, ,
                                                       cn)
                'Try
                '    Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar(cod_cn)
                'Catch ex As Exception
                '    objError.parse_error_script(ex)
                '    objError.titulo = "Error en la consulta"
                '    objError.mensaje = "No se puede abrir la conexiona la DB"
                '    arParam("objError") = objError
                '    Return Nothing
                'End Try
                'Cmd.CommandType = 4
                '//Si la cadena trae timeout lo respeta, si no, utiliza el de la llamada
                'Cmd.CommandTimeout = nvXMLUtiles.getAttribute_path(objXML, "criterio/procedure/@CommandTimeout", arParam("timeout"))
                'Cmd.CommandText = nvXMLUtiles.getAttribute_path(objXML, "criterio/procedure/@CommandText", "")
                'Dim param_strXML As New List(Of ADODB.Parameter)
                'Dim CommandText As String = ""
                Dim valor As Object = ""
                Dim DataType As String
                Dim NOD As System.Xml.XmlNode
                Dim strFiltro As String
                Dim strCampos As String
                Dim strGrupo As String
                Dim strHaving As String
                Dim nombre As String
                'Dim NOD1 As System.Xml.XmlNode
                'Dim p As ADODB.Parameter
                Dim param_date As DateTime
                'Dim cmd_parameters As New Dictionary(Of String, ADODB.Parameter)

                If Not objXML.SelectSingleNode("criterio/procedure/parametros") Is Nothing Then
                    Try
                        For i = 0 To objXML.SelectSingleNode("criterio/procedure/parametros").ChildNodes.Count - 1
                            NOD = objXML.SelectSingleNode("criterio/procedure/parametros").ChildNodes(i)
                            nombre = NOD.Name
                            valor = NOD.InnerText

                            DataType = nvXMLUtiles.getAttribute_path(NOD, "@DataType", "")
                            If valor.toupper() = "NULL" Then
                                'valor = DBNull.Value
                                Continue For
                            End If
                            '****************************************************************************
                            ' Si dentro de los parametros hay una clausula select, los valores de esta
                            ' se pasan como parametros automaticamente
                            ' campos, orden, grupo
                            '****************************************************************************
                            If nombre.ToLower = "select" Then
                                Dim objSelect As System.Xml.XmlNode = NOD
                                strFiltro = ""
                                strCampos = ""
                                strGrupo = ""
                                strHaving = ""

                                If Not objSelect.SelectSingleNode("filtro") Is Nothing Then
                                    valor = procesarFiltro(objSelect.SelectSingleNode("filtro"))
                                    Cmd.addParameter("@filtro", 201, 1, 8000, valor)
                                    'If Cmd.Parameters("@filtro") Is Nothing Then
                                    '    p = Cmd.CreateParameter("@filtro", 201, 1, 8000, valor)
                                    '    Cmd.Parameters.Append(p)
                                    'Else
                                    '    Cmd.Parameters.Item("@filtro").Value = valor
                                    'End If
                                End If

                                If Not objSelect.SelectSingleNode("campos") Is Nothing Then
                                    valor = objSelect.SelectSingleNode("campos").InnerText
                                    Cmd.addParameter("@campos", 201, 1, 8000, valor)
                                    'If Cmd.Parameters("@campos") Is Nothing Then
                                    '    p = Cmd.CreateParameter("@campos", 201, 1, 8000, valor)
                                    '    Cmd.Parameters.Append(p)
                                    'Else
                                    '    Cmd.Parameters.Item("@campos").Value = valor
                                    'End If
                                End If

                                If Not objSelect.SelectSingleNode("orden") Is Nothing Then
                                    valor = objSelect.SelectSingleNode("orden").InnerText
                                    Cmd.addParameter("@orden", 201, 1, 8000, valor)
                                    'If Cmd.Parameters("@orden") Is Nothing Then
                                    '    p = Cmd.CreateParameter("@orden", 201, 1, 8000, valor)
                                    '    Cmd.Parameters.Append(p)
                                    'Else
                                    '    Cmd.Parameters.Item("@orden").Value = valor
                                    'End If
                                End If

                                If Not objSelect.SelectSingleNode("grupo") Is Nothing Then
                                    valor = objSelect.SelectSingleNode("grupo").InnerText
                                    Cmd.addParameter("@grupo", 201, 1, 8000, valor)
                                    'If Cmd.Parameters("@grupo") Is Nothing Then
                                    '    p = Cmd.CreateParameter("@grupo", 201, 1, 8000, valor)
                                    '    Cmd.Parameters.Append(p)
                                    'Else
                                    '    Cmd.Parameters.Item("@grupo").Value = valor
                                    'End If
                                End If
                                'p = Cmd.CreateParameter("filtro", 201, 1, 8000, valor)
                                ''param_strXML.Add(p)
                                'Cmd.Parameters.Append(p)

                                'strCampos = nvXMLUtiles.getNodeText(objSelect, "select/campos", "")
                                'p = Cmd.CreateParameter("campos", 201, 1, 8000, strCampos)
                                ''param_strXML.Add(p)
                                'Cmd.Parameters.Append(p)

                                'strOrden = nvXMLUtiles.getNodeText(objSelect, "select/orden", "")
                                'p = Cmd.CreateParameter("orden", 201, 1, 8000, strOrden)
                                ''param_strXML.Add(p)
                                'Cmd.Parameters.Append(p)

                                'strGrupo = nvXMLUtiles.getNodeText(objSelect, "select/grupo", "")
                                'p = Cmd.CreateParameter("grupo", 201, 1, 8000, strGrupo)
                                ''param_strXML.Add(p)
                                'Cmd.Parameters.Append(p)
                                '//break ????
                                Continue For
                            End If

                            '*********************************************************
                            ' Carga los parametros con su tipo correspondiente.
                            ' Si no se informa el tipo lo pasa como varchar
                            '*********************************************************

                            Select Case DataType.ToLower
                                Case "int"
                                    ' adBigInt 
                                    ' param_strXML[param_strXML.length] = Cmd.CreateParameter(nombre, 20, 1, 8, parseInt(valor))
                                    If Cmd.Parameters("@" & nombre) Is Nothing Then Cmd.CreateParameter("@" & nombre, ADODB.DataTypeEnum.adBigInt, 1)
                                    Cmd.Parameters.Item("@" & nombre).Value = CInt(valor)

                                Case "money"
                                    ' adCurrency 
                                    ' param_strXML[param_strXML.length] = Cmd.CreateParameter(nombre, 6, 1, 8, parseFloat(valor))
                                    If Cmd.Parameters("@" & nombre) Is Nothing Then Cmd.CreateParameter("@" & nombre, ADODB.DataTypeEnum.adDouble, 1)
                                    Cmd.Parameters.Item("@" & nombre).Value = Val(valor)

                                Case "datetime"
                                    ' adDate 
                                    If Cmd.Parameters("@" & nombre) Is Nothing Then Cmd.CreateParameter("@" & nombre, ADODB.DataTypeEnum.adDBDate, 1)
                                    param_date = nvConvertUtiles.parseFecha(valor, "SCRIPT")
                                    Cmd.Parameters.Item("@" & nombre).Value = param_date

                                Case "binary"
                                    If Cmd.Parameters("@" & nombre) Is Nothing Then Cmd.CreateParameter("@" & nombre, ADODB.DataTypeEnum.adLongVarBinary, 1)
                                    Dim arBytes() = Convert.FromBase64String(valor)
                                    Cmd.Parameters.Item("@" & nombre).Type = ADODB.DataTypeEnum.adLongVarBinary
                                    Cmd.Parameters.Item("@" & nombre).Size = arBytes.Length
                                    Cmd.Parameters.Item("@" & nombre).AppendChunk(arBytes)

                                Case Else
                                    If Cmd.Parameters("@" & nombre) Is Nothing Then Cmd.CreateParameter("@" & nombre, ADODB.DataTypeEnum.adLongVarChar, 1)
                                    ' string
                                    ' param_strXML[param_strXML.length] = Cmd.CreateParameter(nombre, 201, 1, 8000, valor)
                                    If valor.ToString.Length > 0 Then
                                        Cmd.Parameters.Item("@" & nombre).Type = ADODB.DataTypeEnum.adLongVarChar
                                        Cmd.Parameters.Item("@" & nombre).Size = valor.ToString.Length
                                    End If
                                    Cmd.Parameters.Item("@" & nombre).Value = valor
                            End Select
                        Next
                    Catch ex As Exception
                        objError.parse_error_script(ex)
                        objError.titulo = "Error en la consulta"
                        objError.mensaje = "Error el procesar los parametros"
                        objError.debug_desc &= "; strSQL='" & commandText & "'. Mensaje de excepción: " & ex.Message
                        arParam("objError") = objError
                        Return Nothing
                    End Try
                End If

                Try
                    'Dim time_start As DateTime = Now()
                    arParam("orden_original") = strOrden
                    nvLog.parentLogTrack = arParam("logTrack")
                    rs = Cmd.Execute()
                    nvLog.parentLogTrack = ""
                    'rs = New ADODB.Recordset
                    'rs.CursorLocation = 3 '//adUseClient 
                    'rs.CursorType = 3 '//statis  
                    'rs.Source = Cmd
                    'rs.Open()
                    'Dim time_end As DateTime = Now()
                    'try{nvLog_addEvent("rd_XMLToRS", nvLog_getTrack() + ";" + strDate(time_start) + ";" + strDate(time_end) + ";" + Cmd.CommandText)} catch(e){}
                Catch ex As Exception
                    objError.parse_error_script(ex)
                    objError.debug_src = "pvXMLtoSQL.asp::XMLtoRecordset::select::command"
                    objError.debug_desc &= "; Cmd = " '" & Cmd & "'"
                    arParam("objError") = objError
                    Return Nothing
                End Try
            End If

            If rs Is Nothing Then
                objError.debug_desc = "rs = null: Puede que el criterio no contenga la etiqueta select o command" '
                arParam("objError") = objError
                Return Nothing
            End If

            '*******************************************************************
            ' Procesar los filtros de salida
            '*******************************************************************
            Try
                Dim campo_id As String
                Dim campo_desc As String
                Dim NODs As XmlNodeList = objXML.SelectNodes("criterio/result/filter")
                Dim NodFilter As XmlNode
                Dim camposList As New trsParam
                Dim campo As trsParam

                For Each NodFilter In NODs
                    campo_id = NodFilter.Attributes("campo_id").Value
                    campo_desc = NodFilter.Attributes("campo_desc").Value
                    campo = New trsParam
                    campo("campo_desc") = campo_desc
                    campo("values") = New Dictionary(Of String, String)
                    camposList(campo_id) = campo
                Next

                If camposList.Keys.Count > 0 Then
                    rs.AbsolutePosition = 1
                    Dim valCampo As String

                    While Not rs.EOF
                        For Each campo_id In camposList.Keys
                            valCampo = nvFW.nvConvertUtiles.objectToScript(rs.Fields(campo_id).Value)
                            If Not camposList(campo_id)("values").ContainsKey(valCampo) Then
                                camposList(campo_id)("values").add(valCampo, rs.Fields(camposList(campo_id)("campo_desc")).Value)
                            End If
                        Next
                        rs.MoveNext()
                    End While

                    rs.AbsolutePosition = 1
                    arParam("filters") = camposList
                End If
            Catch ex As Exception
            End Try

            '****************************************************
            ' "rs" contiene los registros resultantes
            ' Cargar los parametros asociados a la paginación
            '****************************************************

            arParam("recordcount") = rs.RecordCount
            arParam("PageCount") = 1

            If arParam("AbsolutePage") > 0 AndAlso arParam("PageSize") > 0 Then
                arParam("PageCount") = Math.Ceiling(rs.RecordCount / arParam("PageSize"))
            End If

            '*******************************************************
            ' Cargar el recorset y los parametros a la cache
            '*******************************************************
            arParam("cacheControl") = cacheControl
            arParam("orden") = strOrden
            arParam("cache") = False

            If Not rs.EOF Then 'Si el RS tiene datos entonces procesar la salida
                'Si se ha definido que debe guardarese en la cache de session
                If cacheControl.ToLower = "session" Then
                    If cacheID = "" Then
                        Dim tempCacheID As String
                        Dim p1 As Dictionary(Of String, Object)

                        Do
                            tempCacheID = nvCache.IDGen()
                            p1 = New Dictionary(Of String, Object)
                            p1.Add("cacheID", tempCacheID)
                        Loop Until nvFW.nvCache.getCache("rs", p1) Is Nothing

                        cacheID = tempCacheID
                    End If

                    'cacheID = IIf(cacheID = "", nvCache.IDGen(), cacheID)
                    arParam("cacheID") = cacheID
                    Dim valores = New Dictionary(Of String, Object)
                    Dim rs_clon As ADODB.Recordset = DBRecordsetCopiar(rs)
                    valores.Add("rs", rs_clon)
                    valores.Add("arParam", arParam)
                    Dim p As New Dictionary(Of String, Object)
                    p.Add("cacheID", cacheID)
                    Dim cache As nvCacheElement = nvCache.add("rs", p, valores, expire_minutes)
                    arParam("cache_absolute_expire") = cache.expireAbsolute.ToString("yyyy/mm/dd hh:mm:ss")
                    ''   nvCache_add('rs', {cacheID: cacheID}, valores, expire_minutes, null)
                    'rs = DBRecordsetCloneFilter(rs)
                End If

                'Si se debe paginar el recorset realizar una copia, sino devolver el original
                If arParam("PageSize") > 0 AndAlso arParam("PageSize") < rs.RecordCount AndAlso Not rs.EOF Then
                    Return DBRecordsetCopiar(rs, arParam)
                Else
                    Return rs
                End If
            Else
                Return rs
            End If

            ' Si el recorset no fué cacheado se puede destruir, sino, solo de cierra la conexión
            'If Not nvDBUtiles.getDBConection(cn_nombre) Is Nothing Then
            If cacheControl.ToLower <> "session" Then
                nvDBUtiles.DBCloseRecordset(rs, Not ActiveConnections Is Nothing)
            Else
                If ActiveConnections Is Nothing Then nvDBUtiles.DBDesconectar(rs.ActiveConnection)
            End If
        End Function


        ''' <summary>
        ''' Devuelve una sentencia select SQL desde un XML
        ''' </summary>
        ''' <param name="xmlCriterio"></param>
        ''' <param name="xmlCriterio_add"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function XMLtoSQL(ByVal xmlCriterio As String, Optional ByVal xmlCriterio_add As String = "") As String
            Dim objXML As New XmlDocument
            Dim objXMLWhere As New XmlDocument
            Dim strSQL As String = ""
            Dim strWhere As String = ""
            Dim i As Integer
            'Dim j As Integer
            Dim campo As String = ""
            Dim top As String = ""
            Dim vista As String = ""
            Dim grupo As String = ""
            Dim orden As String = ""
            Dim distinct As String = ""
            Dim tipo_sql As String = ""
            Dim having As String = ""
            Dim con As String = ""
            Dim fetch As String = ""
            Dim limit As String = ""

            '*****************************************************
            ' Control de error
            '*****************************************************
            'objError.numError = 0
            'objError.debug_src = 'pvXMLtoSQL.asp::XMLtoSQL'
            Dim objError As New nvFW.tError

            Try
                objXML.LoadXml(xmlCriterio)
            Catch ex As Exception
                ' Error en el filtro XML
                Throw New Exception("Error XML en el xmlCriterio", ex)
                Return ""
            End Try

            If Not objXML.SelectSingleNode("criterio/select") Is Nothing Then
                ' Recuperar campos de la consulta
                'vista = objXML.SelectSingleNode("criterio/select/@vista").Value
                'campo = objXML.SelectSingleNode("criterio/select/campos").InnerText
                vista = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@vista", "")
                campo = nvXMLUtiles.getNodeText(objXML, "criterio/select/campos", "")
                top = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@top", "")
                con = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@cn", "default")

                If vista = "" OrElse campo = "" Then
                    Dim ex As New Exception("Error XML en el criterio. El elemento vista o el campo están vacíos.")
                    ex.Data.Add("numError", 101)
                    ex.Data.Add("mensaje", "Error XML en el criterio. El elemento vista o el campo están vacíos.")

                    Throw ex
                End If

                If top <> "" Then
                    Select Case nvApp.getInstance().app_cns(con).cn_tipo.ToLower()
                        Case "oracle"
                            fetch = " FETCH NEXT " & top & " ROWS ONLY "
                            top = ""
                        Case "mysql"
                            limit = " LIMIT " & top
                            top = ""
                        Case Else
                            top = " TOP " & top
                    End Select
                End If

                If Not objXML.SelectSingleNode("criterio/select[@distinct = 'true']") Is Nothing Then distinct = " DISTINCT "

                Dim strOrden = nvXMLUtiles.getNodeText(objXML, "criterio/select/orden", "")

                If strOrden <> "" Then
                    orden = " ORDER BY " & strOrden
                End If

                Dim strGrupo = nvXMLUtiles.getNodeText(objXML, "criterio/select/grupo", "")

                If strGrupo <> "" Then
                    grupo = " GROUP BY " & strGrupo
                End If

                Dim strHaving = nvXMLUtiles.getNodeText(objXML, "criterio/select/having", "")

                If strHaving <> "" Then
                    having = " HAVING " & strHaving
                End If

                ' Anexar filtros extras
                If xmlCriterio_add <> "" Then
                    Try
                        objXMLWhere.LoadXml(xmlCriterio_add)
                    Catch ex As Exception
                        Throw New Exception("Error XML en el xmlCriterio_add", ex)
                        Return ""
                    End Try

                    Try
                        If objXMLWhere.GetElementsByTagName("filtro").Count > 0 Then
                            Dim NODs As XmlNodeList = objXMLWhere.GetElementsByTagName("filtro")(0).ChildNodes
                            Dim NOD As XmlNode
                            Dim nodeFiltro As XmlNode

                            If NODs.Count > 0 Then
                                nodeFiltro = objXML.SelectSingleNode("criterio/select/filtro")

                                If nodeFiltro Is Nothing Then
                                    nodeFiltro = objXML.CreateElement("filtro")
                                    objXML.SelectSingleNode("criterio/select").AppendChild(nodeFiltro)
                                End If

                                For i = 0 To NODs.Count - 1
                                    Dim textReader As XmlTextReader = New XmlTextReader(New System.IO.StringReader(NODs(i).OuterXml))
                                    NOD = objXML.ReadNode(textReader)
                                    nodeFiltro.AppendChild(NOD)
                                Next
                            End If
                        End If
                    Catch ex As Exception
                        Throw New Exception("Error XML en el xmlCriterio_add", ex)
                        Return ""
                    End Try
                End If

                ' Genarar filtro
                If Not objXML.SelectSingleNode("criterio/select/filtro") Is Nothing Then
                    strWhere = procesarFiltro(objXML.SelectSingleNode("criterio/select/filtro"))
                End If

                If strWhere.Length > 0 Then strWhere = " WHERE " & strWhere

                strSQL = "SELECT " & distinct & " " & top & " " & campo & " " & " FROM " & vista & " " & strWhere & " " & grupo & " " & having & " " & orden & " " & fetch & " " & limit
            End If

            Return strSQL
        End Function


        ''' <summary>
        ''' Genera la parte Where de la consulta SQL en base a los nodos de "filtro" de la conslta XML
        ''' </summary>
        ''' <param name="NODFiltro"></param>
        ''' <param name="clogico"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Shared Function procesarFiltro(ByVal NODFiltro As XmlNode, Optional ByVal clogico As String = "AND") As String
            Dim strWhere As String = ""
            Dim filtro = New List(Of String)
            Dim campo As String = ""
            Dim type As String = ""
            Dim nodeName As String = ""
            Dim NOD As XmlNode

            Try
                For i = 0 To NODFiltro.ChildNodes.Count - 1
                    NOD = NODFiltro.ChildNodes(i)
                    nodeName = NOD.Name

                    If nodeName.ToUpper() = "NOT" Then
                        filtro.Add("NOT(" & procesarFiltro(NOD) & ")")
                        Continue For
                    End If

                    If nodeName.ToUpper() = "FILTRO" Or nodeName.ToUpper() = "AND" Then
                        filtro.Add("(" & procesarFiltro(NOD, "AND") & ")")
                        Continue For
                    End If

                    If nodeName.ToUpper() = "OR" Then
                        filtro.Add("(" & procesarFiltro(NOD, "OR") & ")")
                        Continue For
                    End If

                    campo = nodeName

                    If campo = "xmlpath" Then campo = NOD.SelectSingleNode("@path").Value

                    type = nvXMLUtiles.getAttribute_path(NOD, "@type", "")
                    Dim res As String = ""

                    Select Case type.ToLower
                        Case "in"
                            res = crearIn(campo, NOD.InnerText)

                        Case "insql"
                            res = campo & " in (" & NOD.InnerText & ")"

                        Case "charindex"
                            res = " charindex(" & campo & ", '" & NOD.InnerText + "') <> 0"

                        Case "igual"
                            res = campo & " = " & NOD.InnerText

                        Case "mas"
                            res = campo & " >= " & NOD.InnerText

                        Case "menos"
                            res = campo & " <= " & NOD.InnerText

                        Case "mayor"
                            res = campo & " > " & NOD.InnerText

                        Case "menor"
                            res = campo & " < " & NOD.InnerText

                        Case "like"
                            res = campo & " like '" & NOD.InnerText & "'"

                        Case "isnull"
                            res = campo & " is null"

                        Case "distinto"
                            res = campo & " <> " & NOD.InnerText

                        Case "sql"
                            res = "(" & NOD.InnerText & ")"

                        Case "contains"
                            res = "CONTAINS(" & campo & ",'" & Replace(NOD.InnerText, "'", "''") & "')"

                        Case "feetext"
                            res = "FREETEXT(" & campo & ",'" + Replace(NOD.InnerText, "'", "''") & "')"
                        Case Else
                            res = crearIn(campo, NOD.InnerText)

                    End Select

                    ' Agregar el filtro si es <> de ''
                    If res <> "" Then filtro.Add(res)
                Next

                If filtro.Count > 0 Then
                    strWhere = filtro(0)

                    For i = 1 To filtro.Count - 1
                        strWhere &= " " & clogico & " " & filtro(i)
                    Next
                End If

                Return strWhere
            Catch ex As Exception
                Throw New Exception("Error al procesar el filtro", ex)
                Return ""
            End Try
        End Function


        Private Shared Function crearIn(ByVal etiqueta As String, ByVal criterio As String) As String
            Dim strRes As String = ""
            Dim porcion As String = ""
            Dim strIn As String = ""
            Dim filtroA = New List(Of String)
            Dim strWhere As String = ""
            Dim i As Integer
            Dim partsGuion() As String
            Dim partsComas() As String = criterio.Split(",")

            For i = 0 To partsComas.Length - 1
                porcion = partsComas(i)
                partsGuion = porcion.Split("-")

                If partsGuion.Length > 1 AndAlso String.IsNullOrEmpty(partsGuion(0).ToString) = False Then
                    filtroA.Add(etiqueta & " between " & partsGuion(0) & " and " & partsGuion(1))
                Else
                    strIn &= "," & porcion
                End If
            Next

            If strIn <> "" Then
                strIn = strIn.Substring(1)
                filtroA.Add(etiqueta & " in (" & strIn & ")")
            End If

            If filtroA.Count > 0 Then
                strWhere = filtroA(0)

                For i = 1 To filtroA.Count - 1
                    strWhere &= " or " & filtroA(i)
                Next
            End If

            If strWhere <> "" Then
                Return "(" & strWhere & ")"
            Else
                Return ""
            End If
        End Function


        ''' <summary>
        ''' Devuelve una copia del recorset que se pasa como parámetro teniendo en cuenta los parametros de AbsolutePage y PageSize
        ''' </summary>
        ''' <param name="rs"></param>
        ''' <param name="arParam"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function DBRecordsetCopiar(ByRef rs As ADODB.Recordset, Optional ByRef arParam As trsParam = Nothing, Optional exclude_types As List(Of ADODB.DataTypeEnum) = Nothing) As ADODB.Recordset
            If arParam Is Nothing Then arParam = New trsParam
            If exclude_types Is Nothing Then exclude_types = New List(Of ADODB.DataTypeEnum)

            Dim AbsolutePage = arParam("AbsolutePage", 0)
            Dim PageSize = arParam("PageSize", 0)
            'Dim orden = arParam("orden", "")
            'Dim filtros = arParam("filtros", Nothing)
            'Dim orden_actual = IIf(rs.Sort = "", arParam("orden_original"), rs.Sort)

            ' Controlar orden del recordset
            ' if (orden_actual != orden)
            '   rs.sort = orden

            ' if (AbsolutePage > 0 && rs.recordcount != 0)
            ' {
            If AbsolutePage <= 0 Or PageSize = 0 Then
                'Return rs
                PageSize = rs.RecordCount
                AbsolutePage = 1
            End If
            ' rs.AbsolutePage = -1

            If rs.RecordCount <> 0 Then
                rs.PageSize = PageSize
                rs.AbsolutePage = AbsolutePage
            End If

            Dim rs_clon As New ADODB.Recordset

            If (PageSize = 0 OrElse PageSize = rs.RecordCount) AndAlso exclude_types.Count = 0 Then
                rs_clon = rs.Clone
                rs_clon.MarshalOptions = ADODB.MarshalOptionsEnum.adMarshalAll
                rs_clon.ActiveConnection = Nothing
                Return rs_clon
            End If

            Dim i As Integer

            ' Copiar campos
            Dim primero As Boolean = False
            Dim name As String = ""

            For i = 0 To rs.Fields.Count - 1
                Try
                    If Not exclude_types.Contains(rs.Fields(i).Type) Then
                        rs_clon.Fields.Append(rs.Fields(i).Name, rs.Fields(i).Type, rs.Fields(i).DefinedSize, rs.Fields(i).Attributes)

                        Try
                            rs_clon.Fields(rs.Fields(i).Name).Precision = rs.Fields(i).Precision
                            rs_clon.Fields(rs.Fields(i).Name).NumericScale = rs.Fields(i).NumericScale
                        Catch ex1 As Exception
                        End Try

                    End If
                Catch ex As Exception
                End Try
            Next

            rs_clon.Open()

            Dim cont As Integer = 1

            ' Copiar datos solo las filas solicitadas
            While cont <= PageSize AndAlso Not rs.EOF AndAlso Not rs.BOF
                cont += 1

                If rs.EOF AndAlso rs.BOF Then Exit While

                rs_clon.AddNew()

                For i = 0 To rs.Fields.Count - 1
                    Try
                        If Not exclude_types.Contains(rs.Fields(i).Type) Then
                            Dim n As String = rs.Fields(i).Name
                            rs_clon.Fields(n).Value = rs.Fields(n).Value
                        End If
                    Catch ex As Exception
                    End Try
                Next

                rs.MoveNext()
            End While

            rs_clon.UpdateBatch()

            If rs_clon.RecordCount > 0 Then
                rs_clon.PageSize = PageSize
                rs_clon.AbsolutePage = 1
                rs_clon.AbsolutePosition = 1
            End If

            Return rs_clon
        End Function


        '''' <summary>
        '''' Devuelve una copia del recorset que se pasa como parámetro aplicando los filters con AbsolutePage y PageSize
        '''' El parametro cerrar_origen define si se debe cerrar el recorset de origen
        '''' </summary>
        '''' <param name="rs"></param>
        '''' <param name="arParam"></param>
        '''' <returns></returns>
        '''' <remarks></remarks>
        'Public Shared Function DBRecordsetCloneFilter(ByRef rs As ADODB.Recordset, Optional ByRef arParam As trsParam = Nothing, Optional cerrar_origen As Boolean = False) As ADODB.Recordset

        '    Dim rs_clon As ADODB.Recordset = rs.Clone()
        '    'Desaaociar el Recordset de la conexion
        '    rs_clon.MarshalOptions = ADODB.MarshalOptionsEnum.adMarshalModifiedOnly
        '    rs_clon.ActiveConnection = Nothing
        '    'Aplicar los filtros
        '    rs_clon = DBRecordsetApplyFilter(rs_clon, arParam)

        '    If cerrar_origen Then
        '        rs.Close()
        '    End If

        '    Return rs_clon
        'End Function

        '''' <summary>
        '''' Devuelve el mismo recorset que se pasa como parámetro aplicando los filters con AbsolutePage y PageSize
        '''' </summary>
        '''' <param name="rs"></param>
        '''' <param name="arParam"></param>
        '''' <returns></returns>
        '''' <remarks></remarks>
        'Public Shared Function DBRecordsetApplyFilter(ByRef rs As ADODB.Recordset, Optional ByRef arParam As trsParam = Nothing) As ADODB.Recordset

        '    If arParam Is Nothing Then arParam = New trsParam

        '    Dim AbsolutePage = arParam("AbsolutePage", 1)
        '    Dim PageSize = arParam("PageSize", 0)



        '    Dim rs_clon As ADODB.Recordset = rs

        '    If PageSize <> 0 Then
        '        'Generar las lista de Bookmark con los registros de la pagina seleccionada
        '        Dim desde As Long = (PageSize * (AbsolutePage - 1)) + 1
        '        Dim hasta As Long = desde + (PageSize - 1)
        '        If hasta > rs.RecordCount Then hasta = rs.RecordCount
        '        Dim bookmark(PageSize - 1) As Object
        '        If Not rs Is Nothing AndAlso (desde <= rs.RecordCount And hasta <= rs.RecordCount) Then
        '            rs.AbsolutePosition = desde
        '            For index = desde To hasta
        '                bookmark(index - desde) = rs.Bookmark
        '                rs.MoveNext()
        '            Next
        '            rs_clon.Filter = bookmark
        '        End If
        '    End If

        '    Return rs_clon
        'End Function


        ''' <summary>
        ''' Devuelve un ADO XML con los datos del recorset y sus parámetros
        ''' </summary>
        ''' <param name="rs"></param>
        ''' <param name="arParam"></param>
        ''' <param name="objParametros"></param>
        ''' <param name="primary_keys"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function RecordsetToXML(ByRef rs As ADODB.Recordset, ByVal arParam As trsParam, Optional ByRef objParametros As System.Xml.XmlDocument = Nothing, Optional primary_keys As List(Of String) = Nothing) As System.Xml.XmlDocument
            Dim st As New ADODB.Stream
            Dim strXML As String
            Dim stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

            ' Si es un recordset comun o un campo con el XML
            If (rs.Fields(0).Name <> "forxml_data") Then
                Try
                    'El metodo save puede recibir como destino del XML un objeto ADODB.Stream o un MSXML.document (versiones no .Net)
                    Dim index As Integer
                    Dim tiene_tipos_excluyentes As Boolean = False

                    For index = 0 To rs.Fields.Count - 1
                        If rs.Fields(index).Type = 141 Then
                            tiene_tipos_excluyentes = True
                            Exit For
                        End If
                    Next

                    If tiene_tipos_excluyentes Then
                        Dim exclude_types As New List(Of ADODB.DataTypeEnum)
                        exclude_types.Add(141)
                        rs = nvXMLSQL.DBRecordsetCopiar(rs, , exclude_types)
                    End If

                    rs.Save(st, ADODB.PersistFormatEnum.adPersistXML)
                    strXML = st.ReadText()

                    'Dim oXML As New MSXML2.DOMDocument60
                    'rs.Save(oXML, ADODB.PersistFormatEnum.adPersistXML)
                    'strXML = oXML.xml


                    'rs.Save(st, ADODB.PersistFormatEnum.adPersistXML)
                    'strXML = st.ReadText()


                    ' El metodo de mierda este, cuando hay datos binarios los corta y les agrega salto de linea y especios, con el replace de abajo se los saco
                    strXML = strXML.Replace(vbCrLf & "		", "")
                Catch ex As Exception
                    Dim er As New tError
                    er.parse_error_script(ex)
                    er.titulo = "Error en la transformación XML"
                    er.debug_src = "nvXMLSQL::RecordsetToXML"
                    arParam("objError") = er
                    Return Nothing
                End Try
            Else
                strXML = rs.Fields("forxml_data").Value
            End If

            Dim Xml As New System.Xml.XmlDocument
            Xml.LoadXml(strXML)

            Dim nodParams As System.Xml.XmlNode = Xml.CreateElement("params")

            ' Define si se retorna la sentencia SQL al resultado XML
            Dim attr As System.Xml.XmlAttribute
            Dim NOD As System.Xml.XmlNode

            ' Si tiene los permisos necesarios puede acceder a la consulta SQL
            Dim returnSQLStatement As Boolean = nvServer.getConfigValue("/config/global/XMLtoSQL/@returnSQLStatement", "False").ToLower = "true"

            For Each p In arParam.Keys
                If (p.ToLower = "sql" AndAlso returnSQLStatement = False) OrElse p.ToLower = "tipo" OrElse p.ToLower = "objerror" OrElse p.ToLower = "logtrack" OrElse p.ToLower = "stopwatch" Then ' Se tiene que habilitar con un permiso
                    Continue For
                End If

                If p.ToLower = "filters" Then
                    Continue For
                End If

                ' Solo pasar elementos con valor
                If arParam(p).ToString <> "" Then
                    attr = Xml.CreateAttribute(p)
                    attr.Value = arParam(p)
                    nodParams.Attributes.Append(attr)
                End If

                If p.ToLower = "id_exp_origen" OrElse p.ToLower = "mantener_origen" Then
                    NOD = Xml.CreateElement(p.ToLower)
                    NOD.InnerText = arParam(p)
                    Xml.ChildNodes(0).AppendChild(NOD)
                End If
            Next

            Xml.ChildNodes(0).AppendChild(nodParams)

            If Not objParametros Is Nothing Then
                Try
                    Dim nodP = objParametros.SelectSingleNode("/parametros")
                    If Not nodP Is Nothing Then
                        Dim nod_parametros As System.Xml.XmlDocumentFragment = Xml.CreateDocumentFragment()
                        nod_parametros.InnerXml = nodP.OuterXml
                        Xml.ChildNodes(0).AppendChild(nod_parametros)
                    End If

                Catch ex As Exception
                End Try
            End If

            If Not primary_keys Is Nothing Then
                For Each campo In primary_keys
                    attr = Xml.CreateAttribute("pk")
                    attr.Value = "true"
                    nvXMLUtiles.selectSingleNode(Xml, "xml/s:Schema/s:ElementType/s:AttributeType[@name='" & campo & "']").Attributes.Append(attr)
                Next
            End If

            stopwatch.Stop()

            Dim ts As TimeSpan = stopwatch.Elapsed
            nvLog.addEvent("rd_RStoXML", ";" & arParam("logTrack") & ";" & ts.TotalMilliseconds & ";getxml;" & Xml.OuterXml.Length)
            Return Xml
        End Function


        ''' <summary>
        ''' Devuelve un XML JSON con los datos del recorset y sus parámetros
        ''' </summary>
        ''' <param name="rs"></param>
        ''' <param name="arParam"></param>
        ''' <param name="objParametros"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function RecordsetToXMLJson(ByRef rs As ADODB.Recordset, ByVal arParam As trsParam, Optional ByRef objParametros As System.Xml.XmlDocument = Nothing, Optional js_format As nvConvertUtiles.nvJS_format = nvConvertUtiles.nvJS_format.js_classic) As System.Xml.XmlDocument
            Dim xml_field As String = "<fields><![CDATA[{}]]></fields>"
            Dim xml_data As String = ""
            Dim position As Integer = 0
            Dim f As Integer
            Dim stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
            xml_field = ""

            For f = 0 To rs.Fields.Count - 1
                xml_field &= ",""" & f & """: {""name"":" & nvConvertUtiles.objectToScript(rs.Fields(f).Name, js_format) & ", ""datatype"" : " & nvConvertUtiles.objectToScript(nvConvertUtiles.ADOTypeToXMLType(rs.Fields(f).Type), js_format) & "}"
            Next

            xml_field &= ", ""length"" : " & rs.Fields.Count

            If f > 0 Then
                xml_field = xml_field.Substring(1)
            End If
            If js_format = nvConvertUtiles.nvJS_format.js_classic Then
                xml_field = "<fields><![CDATA[({" & xml_field & "})]]></fields>"
            Else
                xml_field = "<fields><![CDATA[{" & xml_field & "}]]></fields>"
            End If

            While Not rs.EOF
                ' varchar   = 200
                ' varbinary = 204
                xml_data &= vbCrLf & """" & position & """:{"

                For f = 0 To rs.Fields.Count - 1
                    Try
                        If f > 0 Then xml_data &= ","
                        If Not IsDBNull(rs.Fields(f).Value) Then
                            xml_data &= """" & rs.Fields(f).Name & """: " & nvConvertUtiles.objectToScript(rs.Fields(f).Value, js_format)
                        Else
                            xml_data &= """" & rs.Fields(f).Name & """: null"
                        End If
                    Catch ex As Exception
                        xml_data &= """" & rs.Fields(f).Name & """" & ": ""**Tipo de dato desconocido**"""
                    End Try
                Next

                xml_data = xml_data.Replace(":{" & vbCrLf & ",", ":{" & vbCrLf)
                xml_data &= "},"
                position += 1

                rs.MoveNext()
            End While

            If position > 0 Then xml_data = xml_data.Substring(0, xml_data.Length - 1)
            If js_format = nvConvertUtiles.nvJS_format.js_classic Then
                xml_data = "<data recordcount=""" & position & """><![CDATA[({" & xml_data & "})]]></data>"
            Else
                xml_data = "<data recordcount=""" & position & """><![CDATA[{" & xml_data & "}]]></data>"
            End If

            Dim xml_params As String = "<params><![CDATA[{}]]></params>"
            Dim returnSQLStatement As Boolean = nvServer.getConfigValue("/config/global/XMLtoSQL/@returnSQLStatement", "False").ToLower = "true"
            xml_params = "<params><![CDATA[{"

            For Each p In arParam.Keys
                If (p.ToLower = "sql" AndAlso returnSQLStatement = False) OrElse p.ToLower = "tipo" OrElse p.ToLower = "objerror" OrElse p.ToLower = "logtrack" OrElse p.ToLower = "stopwatch" Then ' Se tiene que habilitar con un permiso
                    Continue For
                End If

                If xml_params <> "<params><![CDATA[{" Then xml_params &= " , "
                If js_format = nvConvertUtiles.nvJS_format.js_classic Then
                    xml_params &= p & ":" & nvConvertUtiles.objectToScript(arParam(p))
                Else
                    xml_params &= """" & p & """:" & nvConvertUtiles.objectToScript(arParam(p), nvConvertUtiles.nvJS_format.js_json)
                End If
            Next

            xml_params &= "}]]></params>"

            Dim oXML As New XmlDocument
            oXML.LoadXml("<rs_xml_json>" & xml_field & xml_data & xml_params & "</rs_xml_json>")

            stopwatch.Stop()

            Dim ts As TimeSpan = stopwatch.Elapsed
            nvLog.addEvent("rd_RStoXML", ";" & arParam("logTrack") & ";" & ts.TotalMilliseconds & ";getxml_json;" & oXML.OuterXml.Length)

            Return oXML
        End Function

        ''' <summary>
        ''' Devuelve un tError con los datos del recorset y sus parámetros
        ''' </summary>
        ''' <param name="rs"></param>
        ''' <param name="arParam"></param>
        ''' <param name="objParametros"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function RecordsetTotError(ByRef rs As ADODB.Recordset, ByVal arParam As trsParam, Optional ByRef objParametros As System.Xml.XmlDocument = Nothing) As tError
            Dim err As New tError

            Dim xml_json = RecordsetToXMLJson(rs, arParam, objParametros, nvConvertUtiles.nvJS_format.js_json)
            err.params("recordcount") = CInt(xml_json.SelectSingleNode("rs_xml_json/data/@recordcount").Value)
            err.params("fields") = New nvJSON_String(xml_json.SelectSingleNode("rs_xml_json/fields").InnerText)
            err.params("rows") = New nvJSON_String(xml_json.SelectSingleNode("rs_xml_json/data").InnerText)
            err.params("params") = New nvJSON_String(xml_json.SelectSingleNode("rs_xml_json/params").InnerText) ' arParam
            If objParametros Is Nothing Then
                err.params("parametros") = ""
            Else
                err.params("parametros") = objParametros.OuterXml
            End If



            Return err
        End Function

        ''' <summary>
        ''' Reemplaza los parametros de la cadena por los valores que vienen en el XML
        ''' </summary>
        ''' <param name="str"></param>
        ''' <param name="paramsXML"></param>
        ''' <returns></returns>
        ''' <remarks>
        ''' %param_name[?][datatype][:default]% 
        '''[* %param_name[?][(datatype)][:default]% *]
        ''' ejemplos: %fe_naci?(date):9/2/1977%
        ''' %edad?:null%
        ''' ejemplos: %nvSession['fecha']?(date):9/2/1977%
        ''' ejemplos: %Application['fecha']?(date):9/2/1977%
        ''' 
        ''' </remarks>
        Public Shared Function StrReplaceParam(ByVal str As String, ByVal paramsXML As String) As String
            ' Si no vienen los parámetros
            'If Trim(paramsXML) = "" Then
            '    Return str
            'End If

            str = str.Replace("<![CDATA[", "aperturacdata")
            str = str.Replace("]]>", "cierrecdata")

            Dim res As String = str
            Dim strReg As String = "%([A-Z||a-z||1-9||_||\'||\[\]]*)(\?)?(\(?([A-Z||a-z]*)\)?)?(:[A-Z||a-z||\s]*)?%" '"%([A-Z||a-z||1-9||_]*)(\?)?(\([A-Z||a-z]*\))?%"
            Dim reg As New Regex(strReg)

            'Dim strReg2 As String = "%([A-Z||a-z||1-9||_]*)(\?)?(\([A-Z||a-z]*\))?(@)?(\([A-Z||a-z]*\))?%" '"%([A-Z||a-z||1-9||_]*)(\?)?(\([A-Z||a-z]*\))?%"
            'Dim reg2 As New Regex(strReg2)
            'Dim str2 As String = str.Replace(":", "@")

            'Dim m2 = reg2.Matches(str2)

            Dim mc As System.Text.RegularExpressions.MatchCollection = reg.Matches(str)
            Dim m As System.Text.RegularExpressions.Match
            'Si hay parametros recorrerlos
            If mc.Count > 0 Then
                'Generar lista de parámetros
                Dim lstParam As New trsParam
                Dim param As tnvRegParam

                'Cargar los parámetros
                For i = 0 To mc.Count - 1
                    m = mc(i)
                    param = New tnvRegParam
                    param.value = m.Value
                    param.name = m.Groups(1).Value
                    param.opcional = m.Groups(2).Value = "?"
                    param.hasDataType = m.Groups(4).Value <> ""
                    param.dataType = IIf(m.Groups(4).Value <> "", m.Groups(4).Value, "varchar")
                    param.hasDefault = m.Groups(5).Value <> ""
                    If param.hasDefault Then param.default = m.Groups(5).Value.Substring(1)
                    lstParam(param.name.ToLower) = param
                Next

                Dim oXML As New System.Xml.XmlDocument
                If Trim(paramsXML) <> "" Then
                    Try
                        oXML.LoadXml(paramsXML)
                    Catch ex As Exception
                    End Try
                End If

                Dim pname As String
                Dim valor As String
                Dim strRegParam As String = "nvSession\[\'([[A-Z||a-z||1-9||_]*)\'\]"
                Dim regParam As New Regex(strRegParam)

                For Each pname In lstParam.Keys
                    param = lstParam(pname)
                    valor = nvXMLUtiles.getAttribute_path(oXML, "/criterio/params/@" & param.name, IIf(param.hasDefault, param.default, "_Error"))

                    If param.opcional Then

                        Dim strRegOp As String = "\[([^\[]*" & param.value.Replace("(", "\(").Replace(")", "\)").Replace("?", "\?") & "[^\[]*)\]"
                        Dim regOp As New System.Text.RegularExpressions.Regex(strRegOp)
                        If regOp.IsMatch(res) Then

                            If valor = "_Error" Then
                                ' Si el parámetro es opcional hay que sacar o todo lo que esté entre [] porque así está definido o sacar el nodo contenedor del parametro
                                res = regOp.Replace(res, "")
                            Else
                                ' Si el parametro es opcional y tiene valor, se quitan corchetes
                                res = regOp.Replace(res, "$1") 'regOp.Match(res).Groups(1).Value
                            End If
                        Else
                            ' Si es opcional y no tiene los corchetes simplemente reemplazar por null.
                            res = res.Replace(param.value, "null")
                        End If

                    End If
                    ' Si NO TIENE definido tipo, reemplaza por la cadena igual que como viene en el parámetro.
                    ' Si TIENE definido tipo ajusta el parámetro al tipo especificado.
                    If valor <> "_Error" Then res = res.Replace(param.value, IIf(param.hasDataType, nvConvertUtiles.objectToSQLScript(valor, param.dataType, "Error_"), valor))
                Next
            End If

            res = res.Replace("aperturacdata", "<![CDATA[")
            res = res.Replace("cierrecdata", "]]>")

            Return res
        End Function


        Private Class tnvRegParam
            Public value As String
            Public name As String
            Public opcional As Boolean
            Public hasDataType As Boolean
            Public dataType As String
            Public replace As String
            Public hasDefault As Boolean
            Public [default] As String
        End Class


        ''' <summary>
        ''' Devuelve los valores de filtroXML desencriptados y con las signación de parámetros aplicada.
        ''' </summary>
        ''' <param name="filtroXML"></param>
        ''' <param name="filtroWhere"></param>
        ''' <param name="VistaGuardada"></param>
        ''' <param name="xmlParams"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function setFiltroXML(ByRef filtroXML As String, ByRef filtroWhere As String, ByVal VistaGuardada As String, Optional ByVal xmlParams As String = "") As tError
            Dim Err As tError
            Dim NoEncExecute As Boolean = False
            Dim DBvista As String = ""
            'allowFiltroXMLNotEncrypted: Determina si se pueden ejecutar filtroXML que no estén encriptados
            Dim allowFiltroXMLNotEncrypted As Boolean = nvServer.getConfigValue("/config/global/XMLtoSQL/@allowFiltroXMLNotEncrypted", "False").ToLower = "true"

            'If filtroXML <> "" And Not allowFiltroXML Then
            '    Err = New tError
            '    Err.numError = "1002"
            '    Err.titulo = "Error en la consulta"
            '    Err.mensaje = "No se pueden utilizar filtroXML en esta implementación"
            '    Err.debug_src = "nvXMLtoSQL::genFiltroXML"
            '    Err.debug_desc = "filtroXML: '" & filtroXML & "'"
            '    Return Err
            'End If

            Dim oFiltroXML As New System.Xml.XmlDocument

            ' Controlar que sea encriptado
            If filtroXML <> "" Then
                Try
                    ' Si viene encriptado desencriptarlo.
                    oFiltroXML.LoadXml(filtroXML)

                    If Not oFiltroXML.SelectSingleNode("/enc") Is Nothing Then
                        filtroXML = nvSecurity.nvCrypto.EncBase64ToStr(oFiltroXML.SelectSingleNode("/enc").InnerText)
                    Else
                        ' Controlar que se permita filtroXML no encriptado
                        If Not allowFiltroXMLNotEncrypted Then
                            Dim permiteEjecucion As Boolean = False
                            Dim filtroXML2 As String = oFiltroXML.OuterXml.ToString()
                            Dim oXML2 As New System.Xml.XmlDocument
                            Try
                                oXML2.LoadXml(filtroXML2)
                                Dim vista As String = oXML2.SelectSingleNode("criterio/select/@vista").Value
                                Dim con As String = oXML2.SelectSingleNode("criterio/select/@cn").Value
                                Dim strSQLVista As String = "select * from verRptadmin_vistas where nombre_vista = '" & vista & "'"
                                Dim rs2 As ADODB.Recordset = DBOpenRecordset(strSQLVista)
                                If nvApp.getInstance().operador.tienePermiso("permisos_Administrador_reportes", 1) And rs2.RecordCount > 0 Then
                                    permiteEjecucion = True
                                    filtroXML = filtroXML2
                                    NoEncExecute = True
                                    DBvista = vista
                                End If
                                DBCloseRecordset(rs2)
                            Catch ex As Exception

                            End Try

                            If Not permiteEjecucion Then
                                Err = New tError
                                Err.numError = "1002"
                                Err.titulo = "Error en la consulta"
                                Err.mensaje = "No se pueden utilizar filtroXML que no estén encriptado en esta implementación"
                                Err.debug_src = "nvXMLtoSQL::genFiltroXML"
                                Err.debug_desc = "filtroXML: '" & filtroXML & "'"
                                Return Err
                            End If
                        End If
                    End If
                Catch ex As Exception
                    'Err = New tError()
                    'Err.parse_error_xml(ex)
                    'Err.titulo = "Error en la conasulta XML"
                    'Err.mensaje = "Error XML en el parametro filtroXML"
                    'Err.debug_desc += vbCrLf & filtroXML
                    'Return Err
                End Try
            End If

            'If xmlParams <> "" Then
            filtroXML = nvXMLSQL.StrReplaceParam(filtroXML, xmlParams)
            filtroWhere = nvXMLSQL.StrReplaceParam(filtroWhere, xmlParams)
            'End If

            ' Recuperar vista guardada
            If VistaGuardada <> "" Then
                Dim vg As tnvVistaGuardada = nvVistaGuardada.get(VistaGuardada)
                Dim DBFiltroXML As String
                Dim DBFiltroWhere As String

                If vg Is Nothing Then
                    Err = New tError
                    Err.numError = 1003
                    Err.titulo = "Error en la consulta"
                    Err.mensaje = "La vista guardada no existe"
                    Err.debug_src = "nvXMLtoSQL::genFiltroXML"
                    Err.debug_desc = "Vista Guardada: '" & VistaGuardada & "'"
                    Return Err
                End If

                DBFiltroXML = nvUtiles.isNUllorEmpty(vg.filtroXML, "")
                DBFiltroWhere = nvUtiles.isNUllorEmpty(vg.filtroWhere, "")

                ' Reemplazar los parametros por los valores
                If xmlParams <> "" Then
                    DBFiltroXML = nvXMLSQL.StrReplaceParam(DBFiltroXML, xmlParams)
                    DBFiltroWhere = nvXMLSQL.StrReplaceParam(DBFiltroWhere, xmlParams)
                End If

                filtroXML = nvXMLUtiles.MergeXML(DBFiltroXML, filtroXML)
                filtroWhere = nvXMLUtiles.MergeXML(DBFiltroWhere, filtroWhere)
            End If

            oFiltroXML = New System.Xml.XmlDocument

            Try
                oFiltroXML.LoadXml(filtroXML)
            Catch ex As Exception
                Err = New tError()
                Err.parse_error_xml(ex)
                Err.titulo = "Error en la conasulta XML"
                Err.mensaje = "Error XML en el parametro filtroXML"
                Err.debug_desc += vbCrLf & filtroXML
                Return Err
            End Try

            Dim oFiltroWhere As New System.Xml.XmlDocument

            If Trim(filtroWhere) <> "" Then
                If filtroWhere.IndexOf("<filtro>") = -1 AndAlso filtroWhere.IndexOf("<criterio>") = -1 Then filtroWhere = "<criterio><select><filtro>" & filtroWhere & "</filtro></select></criterio>"

                Try
                    oFiltroWhere.LoadXml(filtroWhere)
                Catch ex As Exception
                    Err = New tError()
                    Err.parse_error_xml(ex)
                    Err.titulo = "Error en la conasulta XML"
                    Err.mensaje = "Error XML en el parametro filtroWhere"
                    Err.debug_desc &= vbCrLf & filtroWhere
                    Return Err
                End Try
            End If

            Dim exclusion As New List(Of String)
            exclusion.Add("/criterio/select/@vista")
            'exclusion.Add("/criterio/select/filtro")
            exclusion.Add("/criterio/procedure/@cmd")

            Try
                filtroXML = nvXMLUtiles.MergeXML(filtroXML, filtroWhere, exclusion)
            Catch ex As Exception
                Err = New tError()
                Err.parse_error_script(ex)
                Err.titulo = "Error en la conasulta XML"
                Err.mensaje = "Error XML en el parametro filtroWhere"
                Err.debug_desc += vbCrLf & filtroWhere
                Return Err
            End Try

            filtroWhere = ""
            Dim errOK As New tError()
            errOK.params("NoEncExecute") = NoEncExecute
            errOK.params("vista") = DBvista
            Return errOK
        End Function



        Public Class nvVistaGuardada
            Private Shared _vg_global As Dictionary(Of String, tnvVistaGuardada)


            Private Shared Function pvGetEnGlobal() As Dictionary(Of String, tnvVistaGuardada)
                Dim res As Dictionary(Of String, tnvVistaGuardada) = _vg_global

                If res Is Nothing Then
                    res = New Dictionary(Of String, tnvVistaGuardada)
                    _vg_global = res
                End If

                Return res
            End Function


            Private Shared Function pvGetEnSession() As Dictionary(Of String, tnvVistaGuardada)
                Dim res As Dictionary(Of String, tnvVistaGuardada) = nvSession.Contents("nvVistaGuardada")

                If res Is Nothing Then
                    res = New Dictionary(Of String, tnvVistaGuardada)
                    nvSession.Contents("nvVistaGuardada") = res
                End If

                Return res
            End Function

            'Private Shared Function pvGetEnPage(ByVal pageID As String) As Dictionary(Of String, tnvVistaGuardada)

            '    Dim res As Dictionary(Of String, tnvVistaGuardada) = nvPage.Contents("nvVistaGuardadaPage", pageID)
            '    If res Is Nothing Then
            '        res = New Dictionary(Of String, tnvVistaGuardada)
            '        nvPage.Contents("nvVistaGuardadaPage", pageID) = res
            '    End If

            '    'res = nvPage.Contents("nvVistaGuardadaPage", pageID)

            '    'Dim resPage As Dictionary(Of String, Dictionary(Of String, tnvVistaGuardada)) = nvSession.Contents("nvVistaGuardadaPage")
            '    'If resPage Is Nothing Then
            '    '    resPage = New Dictionary(Of String, Dictionary(Of String, tnvVistaGuardada))
            '    '    nvSession.Contents("nvVistaGuardadaPage") = resPage
            '    'End If

            '    'Dim res As Dictionary(Of String, tnvVistaGuardada)
            '    'If resPage.Keys.Contains(pageID) Then
            '    '    res = resPage(pageID)
            '    'Else
            '    '    res = New Dictionary(Of String, tnvVistaGuardada)
            '    '    resPage.Add(pageID, res)
            '    'End If

            '    Return res
            'End Function

            'Public Shared Sub addPage(ByVal name As String, ByVal filtroXML As String, ByVal filtroWhere As String, ByVal pageID As String)
            '    Dim vg As New tnvVistaGuardada
            '    vg.name = name
            '    vg.filtroXML = filtroXML
            '    vg.filtroWhere = filtroWhere
            '    add(vg, enumnvVG_Location.enPage, pageID)
            'End Sub
            'Public Shared Sub removePage(ByVal name As String, ByVal pageID As String)
            '    remove(name, enumnvVG_Location.enPage, pageID)
            'End Sub

            Public Shared Sub addSession(ByVal name As String, ByVal filtroXML As String, ByVal filtroWhere As String)
                Dim vg As New tnvVistaGuardada
                vg.name = name
                vg.filtroXML = filtroXML
                vg.filtroWhere = filtroWhere
                add(vg, enumnvVG_Location.enSession)
            End Sub


            Public Shared Sub removeSession(ByVal name As String)
                remove(name, enumnvVG_Location.enSession)
            End Sub


            Public Shared Sub add(ByVal name As String, ByVal filtroXML As String, ByVal filtroWhere As String, ByVal location As enumnvVG_Location, Optional ByVal pageID As String = "")
                Dim vg As New tnvVistaGuardada
                vg.name = name
                vg.filtroXML = filtroXML
                vg.filtroWhere = filtroWhere
                add(vg, location, pageID)
            End Sub


            Public Shared Sub add(ByVal vg As tnvVistaGuardada, ByVal location As enumnvVG_Location, Optional ByVal pageID As String = "")
                Select Case location
                    Case enumnvVG_Location.enDB
                        Dim strSQL As String = "Delete from WRP_Config where vista = '" & vg.name & "'" & vbCrLf
                        strSQL &= "Insert into WRP_Config(vista, strXML, filtroWhere) values('" & vg.name & "', '" & vg.filtroXML.Replace("'", "'''") & "', '" & vg.filtroWhere.Replace("'", "''") & "')"
                        nvDBUtiles.DBExecute(strSQL)
                        'Case enumnvVG_Location.enPage
                        '    Dim EnPage As Dictionary(Of String, tnvVistaGuardada) = pvGetEnPage(pageID)
                        '    EnPage.Remove(vg.name)
                        '    EnPage.Add(vg.name, vg)

                    Case enumnvVG_Location.enSession
                        Dim EnSession As Dictionary(Of String, tnvVistaGuardada) = pvGetEnSession()
                        EnSession.Remove(vg.name)
                        EnSession.Add(vg.name, vg)

                    Case enumnvVG_Location.enApplication
                        Dim EnGlobal As Dictionary(Of String, tnvVistaGuardada) = pvGetEnGlobal()
                        EnGlobal.Remove(vg.name)
                        EnGlobal.Add(vg.name, vg)
                End Select
            End Sub


            Public Shared Sub remove(ByVal name As String, ByVal location As enumnvVG_Location, Optional ByVal pageID As String = "")
                Select Case location
                    Case enumnvVG_Location.enDB
                        Dim strSQL As String = "Delete from WRP_Config where vista = '" & name & "'"
                        'strSQL += "Insert into WRP_Config(vista, strXML, filtroWhere) values('" & vg.name & "', '" & vg.filtroXML.Replace("'", "'''") & "', '" & vg.filtroWhere.Replace("'", "''") & "')"
                        nvDBUtiles.DBExecute(strSQL)
                        'Case enumnvVG_Location.enPage
                        '    Dim EnPage As Dictionary(Of String, tnvVistaGuardada) = pvGetEnPage(pageID)
                        '    EnPage.Remove(name)
                        '    'EnPage.Add(vg.name, vg)

                    Case enumnvVG_Location.enSession
                        Dim EnSession As Dictionary(Of String, tnvVistaGuardada) = pvGetEnSession()
                        EnSession.Remove(name)
                        'EnSession.Add(vg.name, vg)

                    Case enumnvVG_Location.enApplication
                        Dim EnGlobal As Dictionary(Of String, tnvVistaGuardada) = pvGetEnGlobal()
                        EnGlobal.Remove(name)
                        '_vg_global.Add(vg.name, vg)

                End Select
            End Sub


            Public Shared Sub remove(ByVal vg As tnvVistaGuardada, ByVal location As enumnvVG_Location, Optional ByVal pageID As String = "")
                remove(vg.name, location, pageID)
            End Sub


            Public Shared Function [get](ByVal name As String, ByVal location As enumnvVG_Location, Optional ByVal pageID As String = "") As tnvVistaGuardada
                Dim res As tnvVistaGuardada = Nothing

                Select Case location
                    Case enumnvVG_Location.enDB
                        Dim strSQL As String = "select * from WRP_Config where vista = '" & name & "'"
                        Dim rs As ADODB.Recordset

                        Try
                            rs = nvDBUtiles.DBOpenRecordset(strSQL)

                            If Not rs.EOF Then
                                res = New tnvVistaGuardada
                                res.filtroXML = rs.Fields("strXML").Value
                                'res.filtroWhere = rs.Fields("filtroWhere").Value
                                res.name = rs.Fields("vista").Value
                            End If

                            nvDBUtiles.DBExecute(strSQL)
                        Catch ex As Exception
                        End Try
                        'Case enumnvVG_Location.enPage
                        '    Dim EnPage As Dictionary(Of String, tnvVistaGuardada) = pvGetEnPage(pageID)
                        '    Try
                        '        res = EnPage(name)
                        '    Catch ex As Exception
                        '    End Try

                        'EnPage.Add(vg.name, vg)

                    Case enumnvVG_Location.enSession
                        Dim EnSession As Dictionary(Of String, tnvVistaGuardada) = pvGetEnSession()

                        Try
                            If Not EnSession Is Nothing AndAlso EnSession.ContainsKey(name) Then res = EnSession(name)
                        Catch ex As Exception
                        End Try

                        'EnSession.Add(vg.name, vg)

                    Case enumnvVG_Location.enApplication
                        Dim EnGlobal As Dictionary(Of String, tnvVistaGuardada) = pvGetEnGlobal()

                        Try
                            If Not EnGlobal Is Nothing AndAlso EnGlobal.ContainsKey(name) Then res = EnGlobal(name)
                        Catch ex As Exception
                        End Try
                        '_vg_global.Add(vg.name, vg)

                End Select

                Return res
            End Function


            Public Shared Function [get](ByVal name As String) As tnvVistaGuardada
                Dim res As tnvVistaGuardada = Nothing
                'Dim strReg As String = "\(.*\)"
                'Dim reg As New System.Text.RegularExpressions.Regex(strReg)
                'If reg.IsMatch(name) Then
                '    Dim pageID As String = reg.Match(name).Value
                '    pageID = pageID.Substring(1, pageID.Length - 2)
                '    name = reg.Replace(name, "")
                '    res = [get](name, enumnvVG_Location.enPage, pageID)
                'End If

                If res Is Nothing Then
                    res = [get](name, enumnvVG_Location.enSession)
                End If

                If res Is Nothing Then
                    res = [get](name, enumnvVG_Location.enApplication)
                End If

                If res Is Nothing Then
                    res = [get](name, enumnvVG_Location.enDB)
                End If

                Return res
            End Function

            'Public Shared Function [get](ByVal name As String, ByVal location As enumnvVG_Location, Optional ByVal pageID As String = "") As tnvVistaGuardada
            '    Dim res As tnvVistaGuardada = Nothing
            '    Select Case location
            '        Case enumnvVG_Location.enDB
            '            Dim strSQL As String = "select * from WRP_Config where vista = '" & name & "'"
            '            Dim rs As ADODB.Recordset
            '            Try
            '                rs = nvDBUtiles.DBOpenRecordset(strSQL)
            '                res = New tnvVistaGuardada
            '                res.filtroXML = rs.Fields("strXML").Value
            '                res.filtroWhere = rs.Fields("filtroWhere").Value
            '                res.name = rs.Fields("vista").Value
            '                nvDBUtiles.DBExecute(strSQL)
            '            Catch ex As Exception
            '            End Try
            '        Case enumnvVG_Location.enPage
            '            Dim EnPage As Dictionary(Of String, tnvVistaGuardada) = pvGetEnPage(pageID)
            '            res = EnPage(name)
            '            'EnPage.Add(vg.name, vg)
            '        Case enumnvVG_Location.enSession
            '            Dim EnSession As Dictionary(Of String, tnvVistaGuardada) = pvGetEnSession()
            '            res = EnSession(name)
            '            'EnSession.Add(vg.name, vg)
            '        Case enumnvVG_Location.enApplication
            '            Dim EnGlobal As Dictionary(Of String, tnvVistaGuardada) = pvGetEnGlobal()
            '            res = EnGlobal(name)
            '            '_vg_global.Add(vg.name, vg)
            '    End Select
            '    Return res
            'End Function

            'Public Shared Function [get](ByVal name As String, ByVal location As enumnvVG_Location, Optional ByVal pageID As String = "") As tnvVistaGuardada

            'End Function


            Public Enum enumnvVG_Location
                enDB = 0
                'enPage = 1
                enSession = 2
                enApplication = 3
            End Enum
        End Class


        Public Class tnvVistaGuardada
            Public name As String
            Public filtroXML As String
            Public filtroWhere As String
        End Class
    End Class


    ''' <summary>
    ''' Esta clase define una cadena de caracteres que se identifica como un JSON
    ''' </summary>
    ''' <remarks>
    ''' Se utiliza para que el toJSON no convierta el resultado a string y lo pase como un JSON
    ''' </remarks>
    Public Class nvJSON_String
        Private _value As String
        Public Sub New(strJSON As String)
            _value = strJSON
        End Sub
        Public Property value As String
            Get
                Return _value
            End Get
            Set(value As String)
                _value = value
            End Set
        End Property
    End Class


End Namespace
