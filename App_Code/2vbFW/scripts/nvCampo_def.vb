Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    Public Class nvCampo_def
        Public Shared Function get_html_input(ByVal campo_def As String, Optional ByVal filtroXML As String = "" _
                                                                       , Optional ByVal filtroWhere As String = "" _
                                                                       , Optional ByVal vistaGuardada As String = "" _
                                                                       , Optional ByVal depende_de As String = "" _
                                                                       , Optional ByVal depende_de_campo As String = "" _
                                                                       , Optional ByVal nro_campo_tipo As enumnvCampo_def_tipos = -1 _
                                                                       , Optional ByVal permite_codigo As Boolean = Nothing _
                                                                       , Optional ByVal json As Boolean = Nothing _
                                                                       , Optional ByVal cacheControl As String = "" _
                                                                       , Optional ByVal enDB As Boolean = True _
                                                                       , Optional parametros As Dictionary(Of String, Object) = Nothing _
                                                                       , Optional StringValueIncludeQuote As Boolean = Nothing) As String
            'Public Shared Function get_html_input(ByVal campo_def As String, Optional ByRef parametros As Dictionary(Of String, Object) = Nothing) As String
            Dim oCampo_def As New tnvCampo_def
            oCampo_def.campo_def = campo_def
            If oCampo_def.parametros Is Nothing Then
                oCampo_def.parametros = New Dictionary(Of String, Object)
            End If
            If parametros Is Nothing Then
                parametros = New Dictionary(Of String, Object)
            End If
            If enDB Then
                Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute("select * from campos_def where campo_def = '" & campo_def & "'")
                If rs.EOF Then
                    Throw New Exception("No existe el campo_def " & campo_def)
                    nvDBUtiles.DBCloseRecordset(rs)
                End If
                oCampo_def.filtroWhere = IIf(IsDBNull(rs.Fields("filtroWhere").Value), "", rs.Fields("filtroWhere").Value)
                oCampo_def.filtroXML = IIf(IsDBNull(rs.Fields("filtroXML").Value), "", rs.Fields("filtroXML").Value)

                'Si viene como script JS hay que pasarlo a string. Esto está discontinuado, se mantine por compatibilidad.
                'Debe venir como simple string
                Try
                    oCampo_def.filtroXML = nvConvertUtiles.JSScriptToObject(oCampo_def.filtroXML)
                Catch ex As Exception
                End Try
                oCampo_def.depende_de = IIf(IsDBNull(rs.Fields("depende_de").Value), "", rs.Fields("depende_de").Value)
                oCampo_def.depende_de_campo = IIf(IsDBNull(rs.Fields("depende_de_campo").Value), "", rs.Fields("depende_de_campo").Value)
                '//campo_filtro = rs.fields('campo_filtro').value == null ? '' : rs.fields('campo_filtro').value
                oCampo_def.nro_campo_tipo = IIf(IsDBNull(rs.Fields("nro_campo_tipo").Value), "", rs.Fields("nro_campo_tipo").Value)
                oCampo_def.permite_codigo = IIf(IsDBNull(rs.Fields("permite_codigo").Value), "false", rs.Fields("permite_codigo").Value).ToString.ToLower() = "true"
                oCampo_def.json = IIf(IsDBNull(rs.Fields("json").Value), "true", rs.Fields("json").Value).ToString.ToLower() = "true"
                oCampo_def.cacheControl = IIf(IsDBNull(rs.Fields("cacheControl").Value), "", rs.Fields("cacheControl").Value)
                Try
                    If Not IsDBNull(rs.Fields("options").Value) Then
                        Dim options As String = rs.Fields("options").Value.replace("'", """")
                        Dim regAutocomplete As New System.Text.RegularExpressions.Regex("""autocomplete"":\s*?true", RegexOptions.IgnoreCase)
                        Dim regNativeAutocomplete As New System.Text.RegularExpressions.Regex("""native_autocomplete"":\s*?true", RegexOptions.IgnoreCase)
                        'Dim regPlaceholder As New System.Text.RegularExpressions.Regex("""placeholder"":\s?""(?<word>\w+)""", RegexOptions.IgnoreCase)
                        Dim regPlaceholder As New System.Text.RegularExpressions.Regex("""placeholder"":\s?""(?<word>\w+( +\w+)*)""", RegexOptions.IgnoreCase)

                        oCampo_def.parametros.Add("options", rs.Fields("options").Value)

                        oCampo_def.parametros.Add("autocomplete", regAutocomplete.IsMatch(options))
                        oCampo_def.parametros.Add("native_autocomplete", regNativeAutocomplete.IsMatch(options))
                        If regPlaceholder.IsMatch(options) Then
                            oCampo_def.parametros.Add("placeholder", regPlaceholder.Match(options).Groups("word").Value)
                        End If
                    End If
                Catch ex As Exception

                End Try
                nvDBUtiles.DBCloseRecordset(rs)
            End If
            oCampo_def.filtroWhere = nvUtiles.isNUllorEmpty(filtroWhere, oCampo_def.filtroWhere)
            oCampo_def.filtroXML = nvUtiles.isNUllorEmpty(filtroXML, oCampo_def.filtroXML)
            oCampo_def.vistaGuardada = nvUtiles.isNUllorEmpty(vistaGuardada, oCampo_def.vistaGuardada)
            oCampo_def.depende_de = nvUtiles.isNUllorEmpty(depende_de, oCampo_def.depende_de)
            oCampo_def.depende_de_campo = nvUtiles.isNUllorEmpty(depende_de_campo, oCampo_def.depende_de_campo)
            oCampo_def.nro_campo_tipo = IIf(nro_campo_tipo = -1, oCampo_def.nro_campo_tipo, nro_campo_tipo)
            oCampo_def.permite_codigo = nvUtiles.isNUllorEmpty(permite_codigo, oCampo_def.permite_codigo)
            oCampo_def.json = nvUtiles.isNUllorEmpty(json, oCampo_def.json)
            oCampo_def.cacheControl = nvUtiles.isNUllorEmpty(cacheControl, oCampo_def.cacheControl)
            oCampo_def.StringValueIncludeQuote = nvUtiles.isNUllorEmpty(StringValueIncludeQuote, oCampo_def.StringValueIncludeQuote)

            oCampo_def.nro_campo_tipo = IIf(oCampo_def.nro_campo_tipo = -1 Or oCampo_def.nro_campo_tipo = 0, 1, oCampo_def.nro_campo_tipo)
            oCampo_def.permite_codigo = nvUtiles.isNUllorEmpty(oCampo_def.permite_codigo, False)
            oCampo_def.json = nvUtiles.isNUllorEmpty(oCampo_def.json, True)
            oCampo_def.StringValueIncludeQuote = nvUtiles.isNUllorEmpty(oCampo_def.StringValueIncludeQuote, False)

            oCampo_def.filtroWhere = nvUtiles.isNUllorEmpty(oCampo_def.filtroWhere, "")
            oCampo_def.filtroXML = nvUtiles.isNUllorEmpty(oCampo_def.filtroXML, "")
            oCampo_def.vistaGuardada = nvUtiles.isNUllorEmpty(oCampo_def.vistaGuardada, "")
            oCampo_def.depende_de = nvUtiles.isNUllorEmpty(oCampo_def.depende_de, "")
            oCampo_def.depende_de_campo = nvUtiles.isNUllorEmpty(oCampo_def.depende_de_campo, "")
            oCampo_def.cacheControl = nvUtiles.isNUllorEmpty(oCampo_def.cacheControl, "")

            If oCampo_def.nro_campo_tipo = 4 Then
                If oCampo_def.parametros.ContainsKey("autocomplete") Then
                    oCampo_def.parametros.Remove("autocomplete")
                End If
                oCampo_def.parametros.Add("autocomplete", True)
            End If

            For Each element In parametros.Keys
                If oCampo_def.parametros.ContainsKey(element) Then
                    oCampo_def.parametros.Remove(element)
                End If
                oCampo_def.parametros.Add(element, parametros(element))
            Next

            If Not oCampo_def.parametros.ContainsKey("autocomplete") Then
                oCampo_def.parametros.Add("autocomplete", False)
            End If
            If Not oCampo_def.parametros.ContainsKey("native_autocomplete") Then
                oCampo_def.parametros.Add("native_autocomplete", False)
            End If
            If Not oCampo_def.parametros.ContainsKey("placeholder") Then
                oCampo_def.parametros.Add("placeholder", "")
            End If

            Return oCampo_def.get_html_input()
        End Function

    End Class

    Public Class tnvCampo_def
        Public campo_def As String
        Public vistaGuardada As String
        Public filtroXML As String
        Public filtroWhere As String
        Public depende_de As String
        Public depende_de_campo As String
        Public nro_campo_tipo As enumnvCampo_def_tipos
        Public permite_codigo As Boolean
        Public json As Boolean
        Public cacheControl As String
        Public StringValueIncludeQuote As Boolean

        Public descripcion As String

        Public parametros As Dictionary(Of String, Object)

        Public Sub New()
            parametros = New Dictionary(Of String, Object)
        End Sub
        Public Function get_html_input() As String
            Try
                'setea el autocomplete del navegador en off
                Dim str_native_autocomplete As String = ""
                If Not Me.parametros("native_autocomplete") Then
                    str_native_autocomplete = "autocomplete='off'"
                End If

                Dim strHTML As String = "<table id='campo_def_tb" & campo_def & "' class='tb1' cellspacing='0' cellpadding='0' style='width: 100%' border='0'><tr>"

                '//Los campos de tipo < que 100 tienen el valor en el hidden y el desc es solo descriptivo
                '//Los >= a 100 son campos transparentes, es decir el valor y la desc son iguales
                If nro_campo_tipo < 100 Then
                    strHTML += "<td style='width: 100%;white-space:nowrap;'><input type='hidden' id='" & campo_def & "'/><input class='' type='text' id='" & campo_def & "_desc' style='width: 100%;padding-right: 17px;' "
                    strHTML += "placeholder='" & Me.parametros("placeholder") & "'"

                    If Not permite_codigo And Not Me.parametros("autocomplete") Then
                        strHTML += " readonly='true' ontouchstart='return campos_defs.onclick(event, """ & campo_def & """)' "
                    ElseIf Me.parametros("autocomplete") Then
                        strHTML += " " & str_native_autocomplete & " onkeypress='campos_defs.onkeypress_autocomplete(event, """ & campo_def & """, true)' onkeyup='campos_defs.onkeypress_autocomplete(event, """ & campo_def & """, true)' onkeydown='return campo_def_tabkey(event, """ & campo_def & """ )'"
                    Else
                        strHTML += " " & str_native_autocomplete & " onchange='campos_defs.codigo_onchange(event, """ & campo_def & """)'"
                    End If
                    strHTML += " onblur='campos_defs.onblur(""" & campo_def & """)' "
                    'si es tipo 4 quitamos la flecha de seleccion
                    If nro_campo_tipo <> 4 Then
                        strHTML += " ondblclick='return campos_defs.onclick(event, """ + campo_def + """)'/>"
                        strHTML += "<img src='/FW/image/campo_def/down.png' class='img_down' border='0' align='absmiddle' hspace='1' id='img_down' ontouchstart='return campos_defs.onclick(event, """ + campo_def + """)' onclick='return campos_defs.onclick(event, """ + campo_def + """)'></td>"
                    Else strHTML += ">"
                    End If

                    'strHTML += "<img src='/FW/image/campo_def/cancelar.png' class='img_clear' border='0' align='absmiddle' hspace='1' id='img_clear' ontouchstart='return campos_defs.clear(""" + campo_def + """)' onclick='return campos_defs.clear(""" + campo_def + """)'>"
                    'strHTML += "<td><input class='img_find' readonly='true' onclick='return campos_defs.onclick(event, """ + campo_def + """)'></td>"
                    'strHTML += "<td><input class='img_clear' title='Limpiar' readonly='true' onclick='return campos_defs.clear(""" + campo_def + """)'></td>"
                    'strHTML += "<td><img src='/FW/image/campo_def/buscar.png' style='cursor: hand; cursor: pointer' id='btnSel_" & campo_def & "' onclick='return campos_defs.onclick(event,""" + campo_def + """)'></td>"
                    strHTML += "</td><td><img src='/FW/image/campo_def/cancelar.png' title='Limpiar' class='img_clear' readonly='true' onclick='return campos_defs.clear(""" + campo_def + """)'></td>"
                    'strHTML += "<td><img src='/FW/image/campo_def/file.png' alt='Limpiar' style='cursor: hand; cursor: pointer' id='btnLim_" & campo_def & "' onclick='return campos_defs.clear(""" + campo_def + """)'></td>"
                Else
                    strHTML += "<td style='width: 100%'><input type='hidden' id='" & campo_def & "_desc'/>"
                    strHTML += "<input id='" & campo_def & "'  " & str_native_autocomplete + " "
                    strHTML += "placeholder='" & Me.parametros("placeholder") & "' "
                    If nro_campo_tipo = 100 Then '//Valores enteros
                        strHTML += " type='number' onkeypress='return valDigito(event)'  onchange='campos_defs.onchange(event, """ & campo_def & """)' style='width: 100%; text-align: right'/>"
                    End If

                    If nro_campo_tipo = 101 Then '//Valores enteros separados por comas o guiones
                        strHTML += " type='number' onkeypress='return valDigito(event, ""-,"")' onchange='campos_defs.onchange(event, """ & campo_def & """)' style='width: 100%; text-align: right'/>"
                    End If

                    If nro_campo_tipo = 102 Then '//Valores decimales
                        strHTML += " type='number' onkeypress='return valDigito(event, ""."")' onchange='campos_defs.onchange(event, """ & campo_def & """)' style='width: 100%; text-align: right'/>"
                    End If

                    If nro_campo_tipo = 103 Then  '//Valores de tipo fecha
                        strHTML += " type='text' onkeypress='return valDigito(event, ""/"")' onchange='campos_defs.onchange_calendar(event,""" & campo_def & """); ' ondblclick='campos_defs.show_calendar(""" & campo_def & """)' style='width: 100%; text-align: right'/><td><input class='img_calendar' readonly='true' style='cursor: hand; cursor: pointer' id='btnCal_" & campo_def & "' onclick='campo_def_show_calendar(""" + campo_def + """)'/>"
                        strHTML += "<td><img src='/FW/image/campo_def/cancelar.png' title='Limpiar' class='img_clear' readonly='true' onclick='return campos_defs.clear(""" & campo_def & """)'></td>"
                    End If

                    If nro_campo_tipo = 104 Then '//Texto libre
                        strHTML += " type='text' onchange='campos_defs.onchange(event, """ & campo_def & """)' style='width: 100%; text-align: left' />"
                    End If
                    strHTML += "</td>"
                End If

                Dim campo_codigo As String = ""
                Dim campo_desc As String = ""
                Dim xmlSQL As String = filtroXML
                Try
                    If vistaGuardada <> "" Then
                        xmlSQL = nvXMLSQL.nvVistaGuardada.get(vistaGuardada).filtroXML
                    End If
                    Dim strReg As String = "([^>\s,]*)\s+as\s+\[?id]?" '// busca ????? as id  O ????? as [id] "(\w*)\s+as\s+\[?id]?"
                    Dim reg As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.IgnoreCase)
                    If reg.IsMatch(filtroXML) Then
                        campo_codigo = reg.Match(filtroXML).Groups(1).Value
                    End If
                    'Dim res As System.Text.RegularExpressions.MatchCollection = filtroXML. .toLowerCase().match(reg)

                    strReg = "([^>\s,]*)\s+as\s+\[?campo]?" '// busca ????? as campo  O ????? as [campo]
                    Dim reg2 As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.IgnoreCase)
                    If reg2.IsMatch(filtroXML) Then
                        campo_desc = reg2.Match(filtroXML).Groups(1).Value
                    End If

                Catch ex As Exception

                End Try

                'If vistaGuardada = "" And filtroXML <> "" Then
                '    Dim pageID As String = DirectCast(HttpContext.Current.Handler, nvPages.nvPageBase).pageID
                '    nvXMLSQL.nvVistaGuardada.add("cd_" & campo_def, filtroXML, "", nvXMLSQL.nvVistaGuardada.enumnvVG_Location.enPage, pageID)
                '    vistaGuardada = "(" & pageID & ")cd_" & campo_def
                'End If

                Dim DBParametros As Dictionary(Of String, Object) = New Dictionary(Of String, Object)
                DBParametros.Add("target", "")
                DBParametros.Add("nro_campo_tipo", nro_campo_tipo)
                DBParametros.Add("depende_de", depende_de)
                DBParametros.Add("vistaGuardada", vistaGuardada)
                DBParametros.Add("filtroWhere", filtroWhere)
                DBParametros.Add("filtroXML", nvXMLSQL.encXMLSQL(filtroXML)) 'filtroXML


                'Dim cad As String
                'Dim oFiltroXML As New System.Xml.XmlDocument
                'Try
                '    'Si viene encriptado desencriptarlo.
                '    oFiltroXML.LoadXml(DBParametros("filtroXML"))
                '    If Not oFiltroXML.SelectSingleNode("/enc") Is Nothing Then
                '        cad = nvXMLSQL._EncBase64ToStr(oFiltroXML.SelectSingleNode("/enc").InnerText)
                '    End If
                'Catch ex As Exception
                'End Try

                DBParametros.Add("depende_de_campo", depende_de_campo)
                DBParametros.Add("permite_codigo", permite_codigo)
                DBParametros.Add("json", json)
                DBParametros.Add("cacheControl", cacheControl)
                DBParametros.Add("StringValueIncludeQuote", StringValueIncludeQuote)
                DBParametros.Add("enDB", False)
                If nro_campo_tipo = enumnvCampo_def_tipos.combo_buscador Then 'tipo 3 
                    DBParametros.Add("campo_codigo", campo_codigo)
                    DBParametros.Add("campo_desc", campo_desc)
                End If
                For Each param In parametros.Keys
                    DBParametros.Remove([param])
                    DBParametros.Add(param, parametros(param))
                Next

                Dim scrParametros As String = ""

                Dim oRS As trsParam = New trsParam(DBParametros)
                scrParametros = oRS.toJSON()

                strHTML += "</tr></table>"
                strHTML += vbCrLf & "<script>" & vbCrLf
                strHTML += "campos_defs.add('" + campo_def + "', " + scrParametros + ")"
                strHTML += vbCrLf & "</script>" & vbCrLf
                Return strHTML
            Catch ex As Exception
                Return "Error al cargar el campo_def: '" & campo_def & "'"
            End Try

        End Function
    End Class

    Public Enum enumnvCampo_def_tipos
        combo_simple = 1
        combo_multiple = 2
        combo_buscador = 3
        input_texto_autocomplete = 4
        input_entero = 100
        input_entero_rangos = 101
        input_decimales = 102
        input_fecha = 103
        input_texto = 104
    End Enum

End Namespace
