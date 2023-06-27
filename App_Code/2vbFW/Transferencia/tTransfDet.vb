Imports Microsoft.VisualBasic
Imports nvFW
Imports System.Web.Script.Serialization
Imports System.Runtime.Serialization
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW.nvTransferencia
    Public Class tTransfDet
        Inherits System.MarshalByRefObject
        <ScriptIgnore()>
        <IgnoreDataMember()> Public Transf As tTransfererncia
        Public id_transf_det As Integer
        Public id_transf_log_det As Integer
        Public transf_tipo As String
        Public transf_det As String
        'Public transferencia As String
        Public fe_ini As DateTime
        Public fe_fin As DateTime
        Public opcional As Boolean
        Public opcional_value As Boolean = False
        Public orden As Integer
        Public habilitado As Boolean
        <ScriptIgnore()>
        Public param As New Dictionary(Of String, trsParam)
        Public det_error As New tError
        Public salida_tipo As nvenumSalidaTipo
        Public target As String
        'Public tranf_estado As String

        Public TSQL As String
        Public dtsx_path As String
        Public dtsx_parametros As String
        Public dtsx_exec As String
        Public filtroXML As String
        Public filtroWhere As String
        Public report_name As String
        Public path_reporte As String
        Public contentType As String
        Public xsl_name As String
        Public path_xsl As String
        Public xml_xsl As String
        Public xml_data As String
        Public vistaguardada As String
        Public metodo As String
        Public mantener_origen As Boolean
        Public id_exp_origen As String
        Public parametros As String
        Public parametros_extra_xml As System.Xml.XmlDocument
        Public xls_path As String
        Public lenguaje As String
        Public cod_cn As String
        Public estado As tTransfererncia.nvenumTransfEstado
        Public transf_estado As String
        Public id_transf_log_subproc As Integer = 0

        <ScriptIgnore()>
        <IgnoreDataMember()>
        Public sigs As New Dictionary(Of String, trsParam)
        <ScriptIgnore()>
        <IgnoreDataMember()>
        Public ants As New Dictionary(Of String, trsParam)

        Public script_browser As String
        Public link_browser As String
        'Public resumen As String

        Public Function ejecutar(cola_det As tCola_det) As tError

            'Dim res As tError = New tError
            Dim sw As New System.Diagnostics.Stopwatch
            sw.Start()
            ' //Si la ejecución es opcional y no está tildada seguir con la siguiente
            If Not (Me.opcional And Not Me.opcional_value) And Me.habilitado Then
                Dim strSQLDet As String = vbCrLf & "EXECUTE transf_log_det_add " & Me.Transf.id_transf_log & ", " & Me.id_transf_det & ",'', '', '', '', '', '', ''"

                Dim rsLogDet As ADODB.Recordset
                Dim c1 As Integer = 0
                Do
                    c1 += 1
                    rsLogDet = nvDBUtiles.DBExecute(strSQLDet)
                    Me.id_transf_log_det = rsLogDet.Fields("id_transf_log_det").Value
                Loop Until Me.id_transf_log_det > 0 Or c1 >= 5
                nvDBUtiles.DBCloseRecordset(rsLogDet)

                '/***************************************
                '  Ejeutar la tarea
                '/***************************************
                Dim res As New tError
                Dim stw_det As New System.Diagnostics.Stopwatch
                stw_det.Start()
                Select Case Trim(Me.transf_tipo).ToUpper()
                    Case "INI", "IUS"
                        res = _detVoid_ejecutar(cola_det)
                    Case "ENE" 'Terminado con error
                        res = _detENE_ejecutar(cola_det)
                    Case "END" 'Terminado sin error
                        res = _detEND_ejecutar(cola_det)
                    Case "USR" ' accion de usuario - Pendiente
                        res = _detUSR_ejecutar(cola_det)
                    Case "SP"
                        res = _detSP_ejecutar(cola_det)
                    Case "SCR"
                        res = _detSCR_ejecutar(cola_det)
                    Case "SSR"
                        res = _detSSR_ejecutar(cola_det)
                    Case "SSC"
                        res = _detSSC_ejecutar(cola_det)
                    Case "SEG"
                        res = _detSEG_ejecutar(cola_det)
                    Case "AND", "XOR", "OR"
                        res = _detAND_OR_XOR_ejecutar(cola_det)
                    Case "IF"
                        res = _detIF_ejecutar(cola_det)
                    Case "EXP", "INF"
                        res = _detEXP_ejecutar(cola_det)
                    Case "DTS"
                        res = _detDTS_ejecutar(cola_det)
                    Case "TRA" 'Transferencias - Subprocesos
                        res = _detTRA_ejecutar(cola_det)
                    Case "NOS" 'NOSIS
                        res = _detNOS_ejecutar(cola_det)
                    Case "MSG" 'NOTIF
                        res = _detMSG_ejecutar(cola_det)

                    Case Else

                End Select
                stw_det.Stop()
                Dim ms As Long = stw_det.ElapsedMilliseconds
                res.params("time_ms_b") = ms
                Me.det_error = res



                Try
                    'Dim sw3 As New System.Diagnostics.Stopwatch
                    'sw3.Start()
                    'strSQLDet = "declare @tmp as table (id_transf_log_det int) " & vbCrLf
                    strSQLDet = "EXECUTE transf_log_det_update " & Me.id_transf_log_det & ", " & Me.det_error.numError & ", " & nvConvertUtiles.objectToSQLScript(Me.det_error.mensaje) & ", " & nvConvertUtiles.objectToSQLScript(Me.det_error.comentario) & ", " & nvConvertUtiles.objectToSQLScript(Me.det_error.titulo) & ", " & nvConvertUtiles.objectToSQLScript(Me.det_error.debug_src) & ", " & nvConvertUtiles.objectToSQLScript(Me.det_error.debug_desc) & ", " & nvConvertUtiles.objectToSQLScript(Me.script_browser) & ", " & nvConvertUtiles.objectToSQLScript(Me.link_browser) & ", '" & Me.estado.ToString() & "'," & Me.id_transf_log_subproc & vbCrLf
                    'rsLogDet = nvDBUtiles.DBExecute(strSQLDet)
                    'Me.id_transf_log_det = rsLogDet.Fields("id_transf_log_det").Value
                    'nvDBUtiles.DBCloseRecordset(rsLogDet)

                    If Me.Transf.log_param_save = enum_log_param_save.todo Then strSQLDet += nvTransfUtiles.GetStrSQLLogInsertParams(Me)

                    'Dim param As String
                    'For Each param In Me.Transf.param.Keys
                    '    'If Me.Transf.param(param)("valor") Is Nothing Then Continue For
                    '    'strSQLDet += "INSERT INTO transf_log_param(id_transf_log_det, id_transferencia, parametro, valor)"
                    '    'strSQLDet += "VALUES(" & Me.id_transf_log_det & ", " & Me.Transf.id_transferencia & ", '" & param & "', " & nvConvertUtiles.objectToSQLScript(Me.Transf.param(param)("valor")) & ")" & vbCrLf

                    '    strSQLDet += "INSERT INTO transf_log_param(id_transf_log_det, id_transferencia, parametro, valor)"
                    '    strSQLDet += "VALUES(" & Me.id_transf_log_det & ", " & Me.Transf.id_transferencia & ", '" & param & "', " & IIf(Me.Transf.param(param)("valor") Is Nothing, "NULL", nvConvertUtiles.objectToSQLScript(Me.Transf.param(param)("valor"))) & ")" & vbCrLf
                    'Next
                    nvDBUtiles.DBExecute(strSQLDet)
                    'sw3.Stop()
                    'Me.det_error.params("ms3") = sw3.ElapsedMilliseconds
                Catch ex As Exception

                End Try
                Me.det_error.params("transf_tipo") = Me.transf_tipo
                Me.det_error.params("id_transf_log_det") = Me.id_transf_log_det
                Me.det_error.params("id_transf_det") = Me.id_transf_det
                Me.det_error.params("transf_det") = Me.transf_det
                sw.Stop()
                Me.det_error.params("time_all_ms") = sw.ElapsedMilliseconds

                'errorGlobal.params("tarea_log_" & det.id_transf_log_det) = "<tarea id_transf_det ='" & det.id_transf_det & "' transferencia='" & det.transf_det & "' numError='" & det.transf_error.numError & "'><titulo>" & det.transf_error.titulo & "</titulo><mensaje>" & det.transf_error.mensaje & "</mensaje><comentario>" & det.transf_error.comentario & "</comentario><debug_src>" & det.transf_error.debug_src & "</debug_src><debug_desc>" & det.transf_error.debug_desc & "</debug_desc></tarea>"
                'errorGlobal.params['tarea_log_'+ det.id_transf_log_det] =  "<tarea id_transf_det ='" + det.id_transf_det  + "' transferencia='" + det.transferencia + "' numError='" + det['transf_error'].numError + "'><titulo>" + det['transf_error'].titulo + "</titulo><mensaje>" + det['transf_error'].mensaje + "</mensaje><comentario>" + det['transf_error'].comentario + "</comentario><debug_src>" + det['transf_error'].debug_src + "</debug_src><debug_desc>" + det['transf_error'].debug_desc + "</debug_desc></tarea>"
            End If
            Return Me.det_error
        End Function


        Public Function clone() As tTransfDet
            Dim res As New tTransfDet
            With res
                .ants = Me.ants
                .sigs = Me.sigs
                .cod_cn = Me.cod_cn
                .contentType = Me.contentType
                .det_error = New tError
                .dtsx_exec = Me.dtsx_exec
                .dtsx_parametros = Me.dtsx_parametros
                .dtsx_path = Me.dtsx_path
                .estado = Me.estado 'tTransfererncia.nvenumTransfEstado.no_iniciada
                .filtroWhere = Me.filtroWhere
                .filtroXML = filtroXML
                .habilitado = Me.habilitado
                .id_exp_origen = id_exp_origen
                .id_transf_det = Me.id_transf_det
                .id_transf_log_det = Me.id_transf_log_det
                .lenguaje = Me.lenguaje
                .link_browser = Me.link_browser
                .mantener_origen = Me.mantener_origen
                .metodo = Me.metodo
                .opcional = Me.opcional
                .opcional_value = Me.opcional_value
                .orden = Me.orden
                .param = Me.param
                .parametros = Me.parametros
                .parametros_extra_xml = Me.parametros_extra_xml
                .path_reporte = Me.path_reporte
                .path_xsl = Me.path_xsl
                .report_name = Me.report_name
                .salida_tipo = Me.salida_tipo
                .script_browser = Me.script_browser
                .target = Me.target
                .Transf = Me.Transf
                .transf_det = Me.transf_det
                .transf_tipo = Me.transf_tipo
                .TSQL = Me.TSQL
                .vistaguardada = Me.vistaguardada
                .xls_path = Me.xls_path
                .xml_xsl = Me.xml_xsl
                .xml_data = Me.xml_data
                .xsl_name = Me.xsl_name
                .transf_estado = Me.transf_estado
                .id_transf_log_subproc = Me.id_transf_log_subproc
            End With
            Return res
        End Function

        Private Function _detVoid_ejecutar(cola_det As tCola_det) As tError
            Me.estado = tTransfererncia.nvenumTransfEstado.terminado
            Return New tError
        End Function

        Private Function _detUSR_ejecutar(cola_det As tCola_det) As tError
            If Me.estado <> tTransfererncia.nvenumTransfEstado.Pendiente Then
                For Each s In Me.sigs.Keys
                    Me.sigs(s)("disabled") = True
                Next
                Me.estado = tTransfererncia.nvenumTransfEstado.Pendiente
                Me.Transf.estado = tTransfererncia.nvenumTransfEstado.Pendiente
            Else
                Me.estado = tTransfererncia.nvenumTransfEstado.terminado
            End If

            Return New tError
        End Function

        'Terminado con error
        Private Function _detENE_ejecutar(cola_det As tCola_det) As tError
            Me.estado = tTransfererncia.nvenumTransfEstado.terminado
            Me.Transf.estado = tTransfererncia.nvenumTransfEstado.error
            Return New tError
        End Function
        'Terminado sin error
        Private Function _detEND_ejecutar(cola_det As tCola_det) As tError
            Me.estado = tTransfererncia.nvenumTransfEstado.terminado
            Me.Transf.estado = tTransfererncia.nvenumTransfEstado.finalizado
            Return New tError
        End Function

        Private Function _detSCR_ejecutar(cola_det As tCola_det) As tError
            Me.script_browser = Me.Transf.paramSCRIPT() & vbCrLf & Me.TSQL
            Me.estado = tTransfererncia.nvenumTransfEstado.terminado
            Return New tError
        End Function

        Private Function _detNOS_ejecutar(cola_det As tCola_det) As tError

            Dim err As New tError()
            Dim oXML As New System.Xml.XmlDataDocument
            Dim cuit As String
            Dim cda As Integer
            Dim nro_vendedor As Integer
            Dim razonsocial As String = ""
            Dim sexo As String = ""
            Dim actualizar_fuentes As Boolean
            Dim tipo_informe As String
            Dim forzar_consulta As Boolean

            Try
                Dim pname_cuit As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'cuil']", "")
                Dim pname_cda As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'cda']", "")
                Dim pname_nro_vendedor As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'vendedor']", "")
                Dim pname_razonsocial As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'razonsocial']", "")
                Dim pname_sexo As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'sexo']", "")

                actualizar_fuentes = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'actualizar_fuentes']", "false").ToLower = "true"
                tipo_informe = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'tipo_informe']", "sac_informe")
                forzar_consulta = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = 'forzar_consulta']", "false").ToLower = "true"

                cuit = Me.Transf.param(pname_cuit)("valor")
                cda = Me.Transf.param(pname_cda)("valor")
                nro_vendedor = Me.Transf.param(pname_nro_vendedor)("valor")
                If pname_razonsocial <> "" Then razonsocial = Me.Transf.param(pname_razonsocial)("valor")
                If pname_sexo <> "" Then sexo = Me.Transf.param(pname_sexo)("valor")

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar el componente NOSIS"
                err.mensaje = "Error en la carla de los parámetros de entrada"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try
            Try

                Dim strXML As String
                'Dim objNosis As Object = CreateObject("nvFW.servicios.tnvNOSIS")
                Dim tipo As Object = System.Type.GetType("nvFW.servicios.tnvNosis")
                If tipo Is Nothing Then
                    err.numError = 1045
                    err.titulo = "Error al ejecutar el componente NOSIS"
                    err.mensaje = "No se pudo cargar la clase nvFW.Servicios.nvNosis"
                    Me.estado = tTransfererncia.nvenumTransfEstado.error
                    Return err
                End If
                Dim SAC_informe_variable = tipo.GetMethod("SAC_informe_variable")
                Dim SAC_informeBase = tipo.GetMethod("SAC_informeBase")
                Dim SAC_informe = tipo.GetMethod("SAC_informe")

                If tipo_informe = "sac_informe_variable" Then
                    strXML = nvFW.servicios.nvNOSIS.SAC_informe_variable(cuit, nro_vendedor, 0, CDA:=cda, actualizarFuentes:=actualizar_fuentes, forzar_consulta:=forzar_consulta)
                    'strXML = SAC_informe_variable.Invoke(New Object() {cuit, nro_vendedor, 0, cda, actualizar_fuentes, forzar_consulta})
                Else
                    If razonsocial <> "" AndAlso sexo <> "" Then
                        strXML = nvFW.servicios.nvNOSIS.SAC_informeBase(cuit, razonsocial:=razonsocial, sexo:=sexo, nro_entidad:=nro_vendedor, CDA:=cda, actualizarFuentes:=actualizar_fuentes, forzar_consulta:=forzar_consulta)
                        'strXML = SAC_informeBase.Invoke(New Object() {cuit, razonsocial, sexo, nro_vendedor, cda, "", actualizar_fuentes, forzar_consulta})
                    Else
                        strXML = nvFW.servicios.nvNOSIS.SAC_informe(cuit, nro_vendedor, 0, CDA:=cda, actualizarFuentes:=actualizar_fuentes, forzar_consulta:=forzar_consulta)
                        'strXML = SAC_informe.Invoke(New Object() {cuit, nro_vendedor, "", CInt(0), cda, "", actualizar_fuentes, forzar_consulta})
                    End If
                End If
                oXML.LoadXml(strXML)

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar el componente NOSIS"
                err.mensaje = "No se pudo ejecutar la tarea o error en el resultado revuelto"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try


            Try

                Dim nodes As System.Xml.XmlNodeList = Me.parametros_extra_xml.SelectNodes("parametros_extra/parametro[@nombre=""asignacion""]/parametro")
                For Each n As System.Xml.XmlElement In nodes
                    Dim parametro As String = nvUtiles.isNUll(n.GetAttribute("param"), "")
                    Dim nosis_xpath As String = nvUtiles.isNUll(n.GetAttribute("nosis_xpath"), "")
                    If parametro <> "" And nosis_xpath <> "" Then
                        If Me.Transf.param.ContainsKey(parametro) = True Then
                            If nosis_xpath = "." Then
                                Me.Transf.param(parametro)("valor") = oXML.OuterXml
                            Else
                                Me.Transf.param(parametro)("valor") = nvXMLUtiles.getNodeText(oXML, nosis_xpath, "") 'oXML.SelectSingleNode(nosis_xpath).InnerText
                            End If
                        End If
                    End If
                Next

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar el componente NOSIS"
                err.mensaje = "Error al procesar los parámetros de salida"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try

            Dim rsPOutput As ADODB.Recordset
            Try
                rsPOutput = DBOpenRecordset("Select parametro,nosis_xpath from Transferencia_parametros_NOS where parametro <> '' and id_transf_det = " & Me.id_transf_det)
                While Not rsPOutput.EOF
                    Dim parametro As String = nvUtiles.isNUll(rsPOutput.Fields("parametro").Value, "")
                    Dim nosis_xpath As String = nvUtiles.isNUll(rsPOutput.Fields("nosis_xpath").Value, "")
                    If parametro <> "" And nosis_xpath <> "" And Me.Transf.param(parametro)("valor") Is Nothing Then
                        If Me.Transf.param.ContainsKey(parametro) = True Then
                            If nosis_xpath = "." Then
                                Me.Transf.param(parametro)("valor") = oXML.OuterXml
                            Else
                                Me.Transf.param(parametro)("valor") = nvXMLUtiles.getNodeText(oXML, nosis_xpath, "") 'oXML.SelectSingleNode(nosis_xpath).InnerText
                            End If
                        End If
                    End If
                    rsPOutput.MoveNext()
                End While
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar el componente NOSIS"
                err.mensaje = "Error al procesar los parámetros de salida"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try


            DBCloseRecordset(rsPOutput)
            Me.estado = tTransfererncia.nvenumTransfEstado.terminado
            Return err
        End Function

        Private Function _detMSG_ejecutar(cola_det As tCola_det) As tError

            Dim det As tTransfDet = Me

            Dim err As New tError()
            Dim oXML As New System.Xml.XmlDataDocument
            Dim oXMLUsu As New System.Xml.XmlDataDocument

            Dim nombre As String = ""
            Dim _to As String = ""
            Dim _cc As String = ""
            Dim _cco As String = ""
            Dim asunto As String = ""
            Dim cuerpo As String = ""
            Dim pool As String = ""
            Dim lane As String = ""
            Dim attch As String = ""
            Dim _from As String = ""

            Try
                Dim nodes As System.Xml.XmlNodeList = Me.parametros_extra_xml.SelectNodes("parametros_extra/parametro")
                For Each n In nodes

                    nombre = nvUtiles.isNUll(n.GetAttribute("nombre")).ToUpper

                    If nombre = "PARA" Or nombre = "CC" Or nombre = "CCO" Then

                        pool = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = '" & nombre.ToLower & "']/parametro[@nombre = 'pool']", "0")
                        lane = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = '" & nombre.ToLower & "']/parametro[@nombre = 'lane']", "0") 'nvUtiles.isNUll(n.GetAttribute("lane")) 'n.SelectSingleNode("[@nombre = 'lane']").InnerText
                        Dim mail As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = '" & nombre.ToLower & "']/parametro[@nombre = 'mail']", "0") 'nvUtiles.isNUll(n.GetAttribute("mail")) 'n.SelectSingleNode("[@nombre = 'mail']").InnerText
                        Dim xmpp As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre = '" & nombre.ToLower & "']/parametro[@nombre = 'xmpp']", "0") 'nvUtiles.isNUll(n.GetAttribute("xmpp")) 'n.SelectSingleNode("[@nombre = 'xmpp']").InnerText
                        Dim eProtocolo As System.Xml.XmlNodeList = Me.parametros_extra_xml.SelectNodes("parametros_extra/parametro[@nombre = '" & nombre.ToLower & "']/parametro[@nombre = 'userText' or @nombre = 'mailText' or @nombre = 'xmppText']/parametro")

                        For Each nod_e As System.Xml.XmlElement In eProtocolo

                            Dim protocolo = nod_e.ParentNode.SelectSingleNode("@nombre").Value
                            Dim name = nod_e.SelectSingleNode("parametro [@nombre= 'name']").InnerText
                            Dim eExtras = nod_e.SelectNodes("parametro [@nombre= 'extras']")

                            For Each nod_ex As System.Xml.XmlElement In eExtras

                                If nod_ex.SelectSingleNode("parametro") Is Nothing Then
                                    Exit For
                                End If

                                Dim operador = nod_ex.SelectSingleNode("parametro [@nombre = 'operador']").InnerText
                                Dim login = nod_ex.SelectSingleNode("parametro [@nombre = 'login']").InnerText
                                Dim strNombreCompleto = nod_ex.SelectSingleNode("parametro [@nombre = 'strNombreCompleto']").InnerText

                            Next

                            If protocolo = "userText" Or protocolo = "mailText" Then

                                name = name.Replace("{{", "")
                                name = name.Replace("}}", "")

                                'Try
                                '    Dim resEval = nvEvaluator.Code.ejecutar("vb", name, cola_det.det, "Det_MSG_class_" & cola_det.det.id_transf_det, "Det_MSG_class_" & cola_det.det.id_transf_det)
                                'Catch ex As Exception
                                '    name = ""
                                'End Try

                                'Dim strEval As String = "function return_valor(){" & det.Transf.paramSCRIPT() & "; return " & name & " } " & vbCrLf & " return_valor()"
                                'Dim eval_res As String
                                'Try
                                '    eval_res = nvConvertUtiles.JSScriptToObject(strEval)
                                'Catch ex As Exception
                                'End Try

                                Dim res As String = nvTransfUtiles.evalString(det, name)
                                If Not res Is Nothing Then
                                    name = res
                                End If

                                If name <> "" Then

                                    If protocolo = "userText" Then
                                        Dim getUsuarioHabMSG As Boolean = False
                                        err = nvLogin.execute(nvApp.getInstance(), "getLogin", "", "", "", "", "", "<criterio><login>" & name & "</login></criterio>")
                                        If err.numError = 0 Then
                                            oXMLUsu = New System.Xml.XmlDataDocument
                                            oXMLUsu.LoadXml(err.params("loginXML"))
                                            getUsuarioHabMSG = IIf(oXMLUsu.SelectSingleNode("criterio/cuenta_habilitada").InnerText.ToLower = "true", True, False)
                                        End If

                                        name = IIf(getUsuarioHabMSG, name & "@" & nvApp.getInstance().ads_dominio, name)
                                    End If

                                    If nombre = "PARA" And _to.IndexOf(name) = -1 Then
                                        If _to = "" Then
                                            _to = name
                                        Else
                                            _to = name & ";" & _to
                                        End If
                                    End If

                                    If nombre = "CC" And _cc.IndexOf(name) = -1 Then
                                        If _cc = "" Then
                                            _cc = name
                                        Else
                                            _cc = name & ";" & _cc
                                        End If
                                    End If

                                    If nombre = "CCO" And _cco.IndexOf(name) = -1 Then
                                        If _cco = "" Then
                                            _cco = name
                                        Else
                                            _cco = name & ";" & _cco
                                        End If
                                    End If

                                End If
                            End If
                        Next

                        If pool = "1" Or lane = "1" Then

                            Dim login_msg As String = ""
                            Dim login_msg_hab As Boolean = False
                            Dim rsPOutput As ADODB.Recordset = nvDBUtiles.DBExecute("exec dbo.transf_send_msg_operadores_hab " + Me.id_transf_det.ToString + ", " & pool & "," & lane)
                            While Not rsPOutput.EOF

                                login_msg = nvUtiles.isNUll(rsPOutput.Fields("login").Value, "")

                                If _to.IndexOf(login_msg) = -1 And _cc.IndexOf(login_msg) = -1 And _cco.IndexOf(login_msg) = -1 Then

                                    login_msg_hab = False
                                    err = nvLogin.execute(nvApp.getInstance(), "getLogin", "", "", "", "", "", "<criterio><login>" & login_msg & "</login></criterio>")

                                    If err.numError = 0 Then
                                        oXMLUsu = New System.Xml.XmlDataDocument
                                        oXMLUsu.LoadXml(err.params("loginXML"))
                                        login_msg_hab = IIf(oXMLUsu.SelectSingleNode("criterio/cuenta_habilitada").InnerText.ToLower = "true", True, False)
                                    End If

                                    If login_msg <> "" Then
                                        login_msg = IIf(login_msg_hab, login_msg & "@" & nvApp.getInstance().ads_dominio, login_msg)
                                    End If

                                    If nombre = "PARA" Then
                                        If _to = "" Then
                                            _to = login_msg
                                        Else
                                            _to = login_msg & ";" & _to
                                        End If
                                    End If

                                    If nombre = "CC" Then
                                        If _cc = "" Then
                                            _cc = login_msg
                                        Else
                                            _cc = login_msg & ";" & _cc
                                        End If
                                    End If

                                    If nombre = "CCO" Then
                                        If _cco = "" Then
                                            _cco = login_msg
                                        Else
                                            _cco = login_msg & ";" & _cco
                                        End If
                                    End If
                                End If

                                rsPOutput.MoveNext()
                            End While
                            nvDBUtiles.DBCloseRecordset(rsPOutput)
                        End If

                    End If

                    If nombre = "ASUNTO" Then

                        asunto = n.SelectSingleNode(".").InnerText
                        'asunto = asunto.Replace("\""", "\\""")
                        'asunto = asunto.Replace("'", "\\'")
                        'asunto = asunto.Replace("\n", "\\n")
                        asunto = asunto.Replace("{{", "{")
                        asunto = asunto.Replace("}}", "}")

                        'Dim res As String = nvTransfUtiles.evalString(det, asunto)

                        Dim strReg As String = "{([A-Z||a-z||1-9||_]*)}"
                        Dim reg As New System.Text.RegularExpressions.Regex(strReg)

                        Dim proc As New List(Of String)
                        Dim ms As System.Text.RegularExpressions.MatchCollection = reg.Matches(asunto)
                        For Each m As System.Text.RegularExpressions.Match In ms
                            Dim param As String = m.Groups(1).Value
                            If Not proc.Contains(param) Then
                                asunto = asunto.Replace(m.Value, String.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"), "{0}", det.Transf.param(param)("valor")))
                                proc.Add(param)
                            End If
                        Next

                    End If

                    If nombre = "CUERPO" Then

                        cuerpo = n.SelectSingleNode(".").InnerXml
                        cuerpo = Replace(Replace(cuerpo, "&lt;", "<"), "&gt;", ">")
                        cuerpo = Replace(cuerpo, "&quot;", """")
                        cuerpo = Replace(cuerpo, "&apos;", "'")
                        cuerpo = Replace(cuerpo, "&amp;", "&")
                        '  cuerpo = Replace(cuerpo, "&nbsp;", "&")

                        Dim strReg As String = "(<transfvariable(.*?)>(.*?)</transfvariable>)"
                        Dim reg As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.Compiled Or RegexOptions.IgnoreCase)

                        Dim proc As New List(Of String)
                        Dim ms As System.Text.RegularExpressions.MatchCollection = reg.Matches(cuerpo)
                        For Each m As System.Text.RegularExpressions.Match In ms
                            Dim param As String = m.Groups(1).Value
                            If Not proc.Contains(param) Then
                                proc.Add(param)

                                Dim procParam As New List(Of String)
                                Dim regParam As New System.Text.RegularExpressions.Regex("varname=""(.*?)""", RegexOptions.Compiled Or RegexOptions.IgnoreCase)
                                Dim msParam As System.Text.RegularExpressions.MatchCollection = regParam.Matches(m.Value)
                                For Each mp As System.Text.RegularExpressions.Match In msParam
                                    Dim param_transf As String = mp.Groups(1).Value
                                    If Not procParam.Contains(param_transf) Then
                                        procParam.Add(param)
                                        If Not det.Transf.param(param_transf) Is Nothing Then
                                            cuerpo = cuerpo.Replace(m.Value, String.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"), "{0}", det.Transf.param(param_transf)("valor")))
                                        End If

                                    End If
                                Next

                            End If
                        Next
                    End If

                    If nombre = "ARCHIVOSADJUNTOS" Then


                        Dim eFiles = n.selectNodes("parametro")
                        For Each file As System.Xml.XmlElement In eFiles

                            ' Dim name = nvTransfUtiles.evalString(det, file.SelectSingleNode("parametro").InnerText)
                            Dim name = file.SelectSingleNode("parametro").InnerText

                            Dim strReg As String = "{([A-Z||a-z||1-9||_]*)}"
                            Dim reg As New System.Text.RegularExpressions.Regex(strReg)

                            Dim proc As New List(Of String)
                            Dim ms As System.Text.RegularExpressions.MatchCollection = reg.Matches(name)
                            For Each m As System.Text.RegularExpressions.Match In ms
                                Dim param As String = m.Groups(1).Value
                                If Not proc.Contains(param) Then
                                    name = name.Replace(m.Value, String.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"), "{0}", det.Transf.param(param)("valor")))
                                    proc.Add(param)
                                End If
                            Next

                            Dim path As String = ""
                            If name.Substring(0, name.IndexOf("://")).ToUpper = "FILE" Then
                                path = nvReportUtiles.get_file_path(name)
                            End If

                            If System.IO.File.Exists(path) Then
                                If path = "" Then
                                    attch = path
                                Else
                                    attch = path & ";" & attch
                                End If

                            End If

                        Next
                    End If

                    If nombre = "DESDE" Then

                        _from = n.SelectSingleNode(".").InnerText
                        Dim strSQLConf As String = "Select [from] as _from from transf_conf where id_transf_conf = " & _from & " "
                        Dim rsConf As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQLConf)
                        If (rsConf.EOF = False) Then
                            _from = rsConf.Fields("_from").Value
                        End If
                        nvDBUtiles.DBCloseRecordset(rsConf)

                    End If

                Next

                err = nvFW.nvNotify.sendMail(_from:=_from _
                                            , _to:=_to, _cc:=_cc, _bcc:=_cco _
                                            , _subject:=asunto _
                                            , _body:=cuerpo _
                                            , _attachByPath:=attch)

                If (err.numError <> 0) Then
                    err.titulo = "Error al ejecutar el componente notificación"
                    ' err.mensaje = "Error al procesar los parámetros de salida"
                    Me.estado = tTransfererncia.nvenumTransfEstado.error
                    Return err
                End If

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar el componente notificación"
                err.mensaje = "Error al procesar los parámetros de salida"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try

            Me.estado = tTransfererncia.nvenumTransfEstado.terminado
            Return err

        End Function

        Private Function _detSSR_ejecutar(cola_det As tCola_det) As tError

            Dim res As New tError
            Try

                res = nvEvaluator.Code.ejecutar(cola_det.det.lenguaje, cola_det.det.TSQL, cola_det.det, "Det_SSR_" & cola_det.det.id_transf_det, "Det_SSR_class_" & cola_det.det.id_transf_det)
                'nvSSRCodeEjecutar.ejecutar(Me)
                Me.estado = IIf(res.numError = 0, tTransfererncia.nvenumTransfEstado.terminado, tTransfererncia.nvenumTransfEstado.error)
            Catch ex As Exception
                res = New tError
                res.parse_error_script(ex)
                res.titulo = "Error de ejecución SSR"
                res.mensaje = "Error al ejecutar la tarea"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
            End Try
            Return res
        End Function

        Private Function _detSSC_ejecutar(cola_det As tCola_det) As tError

            Dim res As New tError
            Try
                Dim lenguaje As String = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "/parametros_extra/parametro [@nombre='lenguaje']", "")

                res = nvEvaluator.Code.ejecutar(lenguaje, cola_det.det.TSQL, cola_det.det, "Det_SSC_" & cola_det.det.id_transf_det, "Det_SSC_class_" & cola_det.det.id_transf_det)
                'nvSSRCodeEjecutar.ejecutar(Me)
                Me.estado = IIf(res.numError = 0, tTransfererncia.nvenumTransfEstado.terminado, tTransfererncia.nvenumTransfEstado.error)
            Catch ex As Exception
                res = New tError
                res.parse_error_script(ex)
                res.titulo = "Error de ejecución SSC"
                res.mensaje = "Error al ejecutar la tarea"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
            End Try
            Return res
        End Function

        Private Function _detSEG_ejecutar(cola_det As tCola_det) As tError
            Dim res = New tError

            Dim code As String = ""
            If nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "/parametros_extra/parametro [@nombre='xml']", "") <> "" Then
                For Each p In cola_det.det.Transf.param
                    code = nvTransfUtiles.getCodeSEG(Me.parametros_extra_xml.SelectSingleNode("/segmentos/nodo [@nodo_id='raiz']/nodos"), p.Value("parametro"), p.Value("valor"), cola_det.det.Transf.param)
                    If code <> "" Then
                        Exit For
                    End If
                Next
            Else
                res.numError = -99
                res.titulo = "Error de ejecución SEG"
                res.mensaje = "Error al intentar cargar la segmentación"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return res
            End If

            Try
                res = nvEvaluator.Code.ejecutar(cola_det.det.lenguaje, code, cola_det.det, "Det_SEG_" & cola_det.det.id_transf_det, "Det_SEG_class_" & cola_det.det.id_transf_det)
                Me.estado = IIf(res.numError = 0, tTransfererncia.nvenumTransfEstado.terminado, tTransfererncia.nvenumTransfEstado.error)
            Catch ex As Exception
                res.parse_error_script(ex)
                res.titulo = "Error de ejecución SEG"
                res.mensaje = "Error al ejecutar la tarea"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
            End Try

            Return res
        End Function

        Private Function _detSP_ejecutar(cola_det As tCola_det) As tError

            Dim Stopwatch1 As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
            Dim scriptSQL As String = ""

            Dim det As tTransfDet = Me

            '/***********************************************
            'EJECUTAR CODIGO SQL
            '************************************************/
            Dim err As New tError
            'Abrir y definir la conexión

            'Definir conexión a utilizar
            Dim cn As ADODB.Connection
            Try
                Dim cn_nombre As String = det.cod_cn
                If det.Transf.ActiveConnections.ContainsKey(cn_nombre.ToLower) Then
                    cn = det.Transf.ActiveConnections(cn_nombre.ToLower)
                Else
                    'cn_nombre
                    If Not nvDBUtiles.getDBConection(cn_nombre) Is Nothing Then
                        cn = nvDBUtiles.DBConectar(cn_nombre)
                        det.Transf.ActiveConnections.Add(cn_nombre.ToLower, cn)
                    Else
                        Throw New Exception("La conexión '" & cn_nombre & "' no existe")
                    End If
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar la tarea"
                err.mensaje = "Se produjo un error al conectar la DB"
                err.debug_src = "nvTranfDetEjecutar::detSP_ejecutar"
                det.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try

            'obtener tipo de conexion
            Dim cn_tipo As String = ""
            Try
                cn_tipo = nvFW.nvApp.getInstance().app_cns(det.cod_cn).cn_tipo
            Catch ex As Exception

            End Try

            'Definir el select de salida
            Dim paramTSQL_ret As String = IIf(det.Transf.paramTSQL_ret(cn_tipo) <> "", "Select " & det.Transf.paramTSQL_ret(cn_tipo), "")

            Dim rsResScript As ADODB.Recordset = Nothing

            Try
                'Separar en bloques "GO"
                Dim strReg As String = "\sGO\s"
                Dim reg As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.IgnoreCase)
                Dim scriptBase As String = det.TSQL
                Dim scriptBlocks As New List(Of String)
                While reg.IsMatch(scriptBase)
                    Dim m As Match = reg.Match(scriptBase)
                    Dim bloque As String = scriptBase.Substring(0, m.Index)
                    scriptBase = scriptBase.Substring(m.Index + m.Length)
                    scriptBlocks.Add(bloque)
                End While
                If scriptBase.Length > 0 Then
                    scriptBlocks.Add(Trim(scriptBase))
                End If

                'Dim rsReturns As New List(Of ADODB.Recordset)

                Dim st As New System.Diagnostics.Stopwatch
                st.Start()

                For Each scriptBlock In scriptBlocks
                    rsResScript = New ADODB.Recordset
                    Try

                        'Cargar parámetros y asignarles el valor
                        Dim paramTSQL As String = ""

                        Select Case cn_tipo.ToLower()
                            Case "oracle"
                                err = _plsql_sp_ejecutar(scriptSQL, paramTSQL, paramTSQL_ret, scriptBlock, cn_tipo, cn)
                                If err.numError <> 0 Then Return err
                            Case Else
                                det.Transf.getScript_SP_ejecutar(scriptSQL, paramTSQL, paramTSQL_ret, scriptBlock, cn_tipo, det.id_transf_log_det)

                                err = _sql_sp_ejecutar(rsResScript, scriptSQL, paramTSQL_ret, cn)
                                If err.numError <> 0 Then Return err
                        End Select

                        Try
                            st.Stop()
                            Dim ts1 As TimeSpan = st.Elapsed
                            nvLog.addEvent("transf_det_spejecutar", ";;" & ts1.TotalMilliseconds & ";" & det.id_transf_log_det.ToString & ";" & scriptSQL & "")
                        Catch ex1 As Exception
                        End Try

                    Catch ex1 As Oracle.ManagedDataAccess.Client.OracleException
                        Throw ex1
                    Catch ex1 As Exception
                        Throw ex1
                    End Try

                    While Not rsResScript Is Nothing
                        '  If rsResScript.State = ADODB.ObjectStateEnum.adStateOpen Then
                        '  rsReturns.Add(rsResScript)
                        '   End If
                        Try
                            rsResScript = rsResScript.NextRecordset
                        Catch ex As Exception
                            rsResScript = Nothing
                        End Try

                    End While

                Next

                If Not (rsResScript Is Nothing) Then nvDBUtiles.DBCloseRecordset(rsResScript, False)

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar la tarea"
                err.mensaje = "Se produjo un error al ejecutar las sentencias"
                err.debug_src = "nvTranfDetEjecutar::detSP_ejecutar"
                det.estado = tTransfererncia.nvenumTransfEstado.error
                nvLog.addEvent("transf_det_spejecutar_error", ";;" & ex.Message & ";" & det.id_transf_log_det.ToString & ";" & scriptSQL & "")
                Return err
            End Try

            det.estado = tTransfererncia.nvenumTransfEstado.terminado
            Return err

        End Function

        Private Function _plsql_sp_ejecutar(scriptSQL As String, paramTSQL As String, paramTSQL_ret As String, scriptBlock As String, cn_tipo As String, cn As ADODB.Connection) As tError

            Dim err As New tError()
            Dim det As tTransfDet = Me

            ' Buscar variables y reemplazar por valor?
            ' SEPARAR CON PALABRA CLAVE EJECUCION DIRECTA
            Dim strReg As String = "\sIMMEDIATE"
            Dim reg As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.IgnoreCase)
            While reg.IsMatch(scriptBlock)
                Dim m As Match = reg.Match(scriptBlock)
                Dim index As Integer = 0
                If scriptBlock.Substring(m.Index - 1, 1) = ";" Then index = m.Index - 1
                Dim bloque As String = scriptBlock.Substring(0, index)
                nvDBUtiles.DBExecute(bloque, Transf.timeout,,,, cn, False)
                scriptBlock = scriptBlock.Substring(m.Index + m.Length)
            End While

            If scriptBlock <> "" Then
                'Crear SP
                det.Transf.getScript_SP_ejecutar(scriptSQL, paramTSQL, paramTSQL_ret, scriptBlock, cn_tipo, det.id_transf_log_det)
                nvDBUtiles.DBExecute(scriptSQL, Transf.timeout,,,, cn, False)

                Dim connection_string As String = getDBConection(cod_cn).cn_string
                Dim array_conn_string = connection_string.Split(";")
                Dim key_words = "\b(user id=|password=|data source=)\b"
                connection_string = ""

                For Each connection_param As String In array_conn_string

                    If Regex.IsMatch(connection_param.ToLower(), key_words) Then
                        connection_string &= connection_param & ";"
                    End If
                Next

                Using oracnn As Oracle.ManagedDataAccess.Client.OracleConnection = New Oracle.ManagedDataAccess.Client.OracleConnection(connection_string)
                    oracnn.Open()
                    Try
                        'System.Data.DbType.Object
                        Using cmd_oracle As Oracle.ManagedDataAccess.Client.OracleCommand = New Oracle.ManagedDataAccess.Client.OracleCommand("tmp_transf_sp_" & det.Transf.id_transf_log, oracnn)
                            cmd_oracle.CommandType = System.Data.CommandType.StoredProcedure
                            Dim outRefPrm As Oracle.ManagedDataAccess.Client.OracleParameter = cmd_oracle.Parameters.Add("c1", Oracle.ManagedDataAccess.Client.OracleDbType.RefCursor, DBNull.Value, System.Data.ParameterDirection.Output)
                            cmd_oracle.ExecuteNonQuery()
                            If paramTSQL_ret <> "" Then 'Solo si tiene variables
                                If Not outRefPrm.Value.isNull Then

                                    Dim reader As Oracle.ManagedDataAccess.Client.OracleDataReader = outRefPrm.Value.getdatareader()

                                    If Not reader Is Nothing Then
                                        While reader.Read()
                                            Dim parametro As trsParam
                                            'Dim valor As Object
                                            Dim param As String
                                            For Each param In det.Transf.param.Keys
                                                parametro = det.Transf.param(param)
                                                parametro("valor") = nvUtiles.isNUll(reader(param), Nothing)
                                            Next
                                        End While
                                    End If
                                Else
                                    err.numError = 54
                                    err.titulo = "Error al ejecutar la tarea"
                                    err.mensaje = "Error al procesar los parametos devueltos"
                                    err.debug_src = "nvTranfDetEjecutar::detSP_ejecutar::oracle"
                                    err.debug_desc = "Error al recuperar los parametros del SP. El SP no devuleve resultado. posible PRINT (Oracle)"

                                    Try
                                        nvLog.addEvent("transf_det_spejecutar_error", ";;;" & det.id_transf_log_det.ToString & ";" & err.debug_desc)
                                    Catch ex2 As Exception
                                    End Try

                                    det.estado = tTransfererncia.nvenumTransfEstado.error
                                End If
                            End If

                        End Using
                    Catch ex1 As Oracle.ManagedDataAccess.Client.OracleException
                        Throw ex1
                    Catch ex As Exception
                        Throw ex
                    Finally
                        Try
                            If oracnn.State = 1 Then
                                oracnn.Close()
                                nvDBUtiles.DBExecute("DROP PROCEDURE tmp_transf_sp_" & det.Transf.id_transf_log, Transf.timeout,,,, cn, False)
                            End If
                        Catch ex4 As Exception

                        End Try
                    End Try
                End Using
            End If

            Return err
        End Function

        Private Function _sql_sp_ejecutar(ByRef rsResScript As ADODB.Recordset, scriptSQL As String, paramTSQL_ret As String, cn As ADODB.Connection) As tError
            Dim err As New tError()
            Dim det As tTransfDet = Me
            rsResScript = nvDBUtiles.DBExecute(scriptSQL, Transf.timeout,,,, cn, False)

            If paramTSQL_ret <> "" Then 'Solo si tiene variables
                Try

                    If Not rsResScript.EOF Then
                        Dim parametro As trsParam
                        'Dim valor As Object
                        Dim param As String
                        For Each param In det.Transf.param.Keys
                            parametro = det.Transf.param(param)
                            parametro("valor") = nvUtiles.isNUll(rsResScript.Fields(param).Value, Nothing)
                        Next
                    Else
                        err.numError = 54
                        err.titulo = "Error al ejecutar la tarea"
                        err.mensaje = "Error al procesar los parametos devueltos"
                        err.debug_src = "nvTranfDetEjecutar::detSP_ejecutar"
                        err.debug_desc = "Error al recuperar los parametros del SP. El SP no devuleve resultado. posible PRINT"

                        Try
                            nvLog.addEvent("transf_det_spejecutar_error", ";;;" & det.id_transf_log_det.ToString & ";" & err.debug_desc)
                        Catch ex2 As Exception
                        End Try

                        det.estado = tTransfererncia.nvenumTransfEstado.error
                        Return err
                    End If
                Catch ex As Exception

                    nvDBUtiles.DBCloseRecordset(rsResScript, False)
                    err.numError = 55
                    err.titulo = "Error al ejecutar la tarea"
                    err.mensaje = "Error al procesar los parametos devueltos"
                    err.debug_src = "nvTranfDetEjecutar::detSP_ejecutar"
                    err.debug_desc = "Error al recuperar los parametros del SP. El SP no debe devolver datos"
                    det.estado = tTransfererncia.nvenumTransfEstado.error

                    Try
                        nvLog.addEvent("transf_det_spejecutar_error", ";;;" & det.id_transf_log_det.ToString & ";" & ex.Message.ToString)
                    Catch ex2 As Exception
                    End Try
                End Try
            End If

            Return err

        End Function

        Private Function _detTRA_ejecutar(cola_det As tCola_det) As tError
            Dim err As New tError
            Dim tr As New tTransfererncia

            Dim id_trans_sub As Integer
            Dim transf_sub_async As Boolean = False
            Dim param_set As New Dictionary(Of String, String)

            Try
                id_trans_sub = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre=""id_transferencia""]", "0")
                'id_trans_sub = Me.parametros_extra_xml.SelectSingleNode("parametros_extra/parametro[@nombre=""id_transferencia""]").Value()
                transf_sub_async = nvXMLUtiles.getNodeText(Me.parametros_extra_xml, "parametros_extra/parametro[@nombre=""async""]", "0") = "1"
                Dim nodes As System.Xml.XmlNodeList = Me.parametros_extra_xml.SelectNodes("parametros_extra/parametro[@nombre=""asignacion""]/parametro")
                For Each n As System.Xml.XmlElement In nodes
                    param_set.Add(n.GetAttribute("param"), n.GetAttribute("param_sub"))
                Next

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar el subproceso"
                err.mensaje = "No se pudo cargar la definición del mismo"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try

            err = tr.cargar(id_trans_sub)
            If err.numError <> 0 Then
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End If

            '**************************
            ' Asignar parámetros
            '**************************
            Try
                For Each p In param_set
                    ' tr.param(p.Key)("valor") = Me.Transf.param(p.Value)("valor")
                    tr.param(p.Value)("valor") = Me.Transf.param(p.Key)("valor")
                Next
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar el subproceso"
                err.mensaje = "Error en la asignacion de parámetros"
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try



            If transf_sub_async = False Then

                tr.id_transf_log = Me.Transf.id_transf_log

                err = tr.ejecutar()

                Dim strSQL As String = "Update transf_log_cab set fe_fin = null, estado = 'ejecutando', resumen = '', obs='', obsbin = null  where id_transf_log = " & Me.Transf.id_transf_log
                nvDBUtiles.DBExecute(strSQL)

                For Each d In tr.dets_run
                    Me.Transf.dets_run.Add(d)
                Next

                '**************************
                ' Reasignar parámetros
                '**************************
                Try
                    For Each p In param_set
                        'tr.param(p.Key)("valor") = Me.Transf.param(p.Value)("valor")
                        Me.Transf.param(p.Key)("valor") = tr.param(p.Value)("valor")
                    Next
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error al ejecutar el subproceso"
                    err.mensaje = "Error en la asignacion de parámetros"
                    Me.estado = tTransfererncia.nvenumTransfEstado.error
                    Return err
                End Try

                'err.params("transf_xml") = tr.getError_xml()
                Me.estado = IIf(err.numError = 0, tTransfererncia.nvenumTransfEstado.terminado, tTransfererncia.nvenumTransfEstado.error)
            Else

                Dim rsTransf_log As ADODB.Recordset = nvDBUtiles.DBExecute("exec transf_log_add " & id_trans_sub)
                tr.id_transf_log = rsTransf_log.Fields("id_transf_log").Value
                nvDBUtiles.DBCloseRecordset(rsTransf_log)

                Dim obj As New Dictionary(Of String, Object)
                obj.Add("Transf", tr)
                obj.Add("nvApp", nvFW.nvApp.getInstance())

                Dim async_thread As System.Threading.Thread = New System.Threading.Thread(Sub(psp)

                                                                                              nvFW.nvApp._nvApp_ThreadStatic = psp("nvApp")
                                                                                              psp("Transf").ejecutar()

                                                                                              Try
                                                                                                  nvTransfUtiles.transfRunThread.Remove(psp("Transf").id_transf_log)
                                                                                              Catch ex As Exception
                                                                                              End Try
                                                                                          End Sub)

                nvFW.nvTransferencia.nvTransfUtiles.transfRunThread.Add(tr.id_transf_log, async_thread) 'carga la referecnia del hilo en una lista para seguilo
                async_thread.SetApartmentState(System.Threading.ApartmentState.MTA) ' habilitar el hilo con parametros
                async_thread.Start(obj)

                Me.id_transf_log_subproc = tr.id_transf_log
                Me.estado = IIf(err.numError = 0, tTransfererncia.nvenumTransfEstado.ejecucion_async, tTransfererncia.nvenumTransfEstado.error)

            End If


            Return err

        End Function


        'Private Function _detXOR_ejecutar(cola_det As tCola_det) As tError
        '    Dim det As tTransfDet = Me
        '    '/*****************************************/
        '    '//  Compuerta XOR
        '    '//  Solo avanza si la primera vez que pasa por el elemento, el resto de las veces lo ignora
        '    '/*****************************************/
        '    Dim xorSQL As String = "Select count(*) As contEjecutado from transf_log_det where id_transf_det = " & det.id_transf_det & " And id_transf_log = " & det.Transf.id_transf_log & " And estado_det = 'Terminado'"
        '    Dim xorRS As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(xorSQL)
        '    Dim contEjecutado As Integer = xorRS.Fields("contEjecutado").Value
        '    nvDBUtiles.DBCloseRecordset(xorRS)

        '    Dim id_transf_rels As String = ""
        '    For Each id_transf_rel In det.ants.Keys
        '        id_transf_rels += "," & id_transf_rel
        '    Next


        '    id_transf_rels = id_transf_rels.Substring(1)

        '    '//Buscar el token más alto de las relaciones entrantes 
        '    xorSQL = "Select id_transf_rel, sum(token) as sumToken from transf_log_rel_token where id_transf_rel in (" & id_transf_rels & ") and id_transf_log = " & det.Transf.id_transf_log & " group by id_transf_rel order by sumToken desc"
        '    xorRS = nvDBUtiles.DBOpenRecordset(xorSQL)
        '    Dim maxToken As Integer = xorRS.Fields("sumToken").Value
        '    nvDBUtiles.DBCloseRecordset(xorRS)
        '    '//Buscar la cantidad de ejecuciones que tiene el control
        '    '//Si la cantidad de ejecuciones es menor que la cantidad de entradas en en camino entonces debe ejecutarce
        '    Dim bandera As Boolean = maxToken > contEjecutado

        '    For Each id_transf_rel In det.sigs.Keys
        '        det.sigs(id_transf_rel)("disabled") = True
        '    Next


        '    If Not bandera Then det.estado = "Ignorado"
        '    Dim eval_res As Boolean
        '    Dim strEval As String
        '    If bandera Then
        '        '//Aca se deben recorrer los caminos por orden.
        '        '//El primer camino que da verdareo es el único que queda activo
        '        '//Si ninguno da verdadero sale por el camino por defecto.
        '        For Each s In det.sigs.Keys
        '            eval_res = False
        '            strEval = "function res(){" & det.Transf.paramSCRIPT() & "; return " & det.sigs(s)("evaluacion") & " } res()"
        '            Try
        '                eval_res = nvConvertUtiles.JSScriptToObject(strEval) 'eval(strEval) ? 1 : 0
        '            Catch ex As Exception

        '            End Try
        '            '//Si verdadero encolarla y agregarl el token
        '            If eval_res Or det.sigs(s)("default") Then
        '                det.sigs(s)("disabled") = False
        '            End If

        '        Next
        '    End If
        '    Return New tError

        'End Function

        Private Function _detAND_OR_XOR_ejecutar(cola_det As tCola_det) As tError
            Dim det As tTransfDet = Me
            '/*********************************************************/
            '//  Compuerta AND
            '//  Solo avanza si todas las entradas son verdaderas.
            'EN LA MISMA CANTIDAD DE ITERACIONES. PUEDE PASAR VARIAS VECES
            'POR EL MISMO LUGAR
            '/********************************************************/
            Try


                Dim det_rel_false As Integer = nvXMLUtiles.getNodeText(cola_det.det.parametros_extra_xml, "parametros_extra/parametro[@nombre=""op_false_id_transf_det""]", 0)
                Dim count_instancia As Integer = 1
                Dim list_count_ant(cola_det.det.ants.Count - 1) As Integer
                Dim count_true_instancias(0) As Integer
                Dim index_list As Integer = -1
                'Identificar el indice de la ejecución actual.
                For i = 0 To cola_det.det.ants.Count - 1
                    Dim id_tranf_rel As Integer = cola_det.det.ants.Keys(i)
                    If cola_det.det.ants(id_tranf_rel)("det").id_transf_det = cola_det.ant.id_transf_det Then index_list = i
                Next

                For Each cola_det_run In Me.Transf.dets_run
                    If Not cola_det_run.ant Is Nothing And cola_det_run.det.id_transf_det = cola_det.det.id_transf_det Then
                        'Contar las instancias de esta ocurrencia.
                        If cola_det_run.ant.id_transf_det = cola_det.ant.id_transf_det Then
                            count_instancia += 1
                        End If

                        'Contar las instancias de todas las ocurrencias
                        For i = 0 To cola_det.det.ants.Count - 1
                            Dim id_tranf_rel As Integer = cola_det.det.ants.Keys(i)
                            If cola_det_run.ant.id_transf_det = cola_det.det.ants(id_tranf_rel)("det").id_transf_det Then
                                list_count_ant(i) += 1
                                If cola_det_run.eval_res Then
                                    If list_count_ant(i) < (count_true_instancias.Count + 1) Then ReDim Preserve count_true_instancias(list_count_ant(i))
                                    count_true_instancias(list_count_ant(i)) += 1
                                End If
                            End If
                        Next
                    End If
                Next

                'Si todas las interaciones son iguales o mayores que la actual entonces la instancia está cumplida
                Dim Instancia_cumplida As Boolean = True
                For i = 0 To list_count_ant.Count - 1
                    If list_count_ant(i) < count_instancia And i <> index_list Then
                        Instancia_cumplida = False
                        Exit For
                    End If
                Next


                'Si la instancia está cumplida, se debe avanzar con la ejecución 
                If Instancia_cumplida Then
                    'Sumar al contador de true en funcion de lo que dió la evaluación que se está procesando
                    Dim count_true As Integer
                    If count_true_instancias.Length <= count_instancia Then
                        count_true = 0
                    Else
                        count_true = count_true_instancias(count_instancia)
                    End If
                    count_true += IIf(cola_det.eval_res, 1, 0)
                    Dim count_ants As Integer = cola_det.det.ants.Count

                    If (cola_det.det.transf_tipo.ToUpper() = "AND" And count_true = count_ants) Or (cola_det.det.transf_tipo.ToUpper() = "OR" And count_true >= 1) Or (cola_det.det.transf_tipo.ToUpper() = "XOR" And count_true = 1) Then
                        'Continuar por verdadero
                        cola_det.continuar = True
                        'Poner a falso el camino por falso
                        For Each sig In cola_det.det.sigs
                            If sig.Value("det").id_transf_det = det_rel_false Then
                                sig.Value("evaluacion") = "false"
                                'cola_det.sigs.Add(New tCola_det With {.det = sig.Value("det").clone(), .ant = det, .eval_res = "true"})
                            End If
                        Next
                    Else
                        'Continuar por falso
                        cola_det.continuar = False
                        'Agregar el camino por falso
                        For Each sig In cola_det.det.sigs
                            If sig.Value("det").id_transf_det = det_rel_false Then
                                cola_det.sigs.Add(New tCola_det With {.det = sig.Value("det").clone(), .ant = det, .eval_res = "true"})
                            End If
                        Next
                    End If
                Else
                    'No se ha cumplido la instancia. Cancelar el continuar
                    cola_det.continuar = False
                End If
                Me.estado = tTransfererncia.nvenumTransfEstado.terminado
                Return New tError
            Catch ex As Exception
                Dim er As New tError
                er.parse_error_script(ex)
                er.titulo = "Error al ejecutar la tarea '" & det.transf_tipo & "'"
                er.mensaje = ""
                Me.estado = tTransfererncia.nvenumTransfEstado.error
                Return New tError
            End Try
        End Function

        Private Function _detIF_ejecutar(cola_det As tCola_det) As tError
            Try

                Dim eval_res As Boolean = True
                Dim resl As New List(Of trsParam)
                Dim eval As String = nvXMLUtiles.getNodeText(cola_det.det.parametros_extra_xml, "parametros_extra/parametro[@nombre=""op_evaluacion""]", "true")
                Dim eval_lenguaje As String = cola_det.det.lenguaje
                Dim id_transf_det_true As Integer = nvXMLUtiles.getNodeText(cola_det.det.parametros_extra_xml, "parametros_extra/parametro[@nombre=""op_true_id_transf_det""]", "0")
                Dim id_transf_det_false As Integer = nvXMLUtiles.getNodeText(cola_det.det.parametros_extra_xml, "parametros_extra/parametro[@nombre=""op_false_id_transf_det""]", "0")

                'Elimina la continuación por defecto
                cola_det.continuar = False
                Dim err2 As tError = nvEvaluator.Code.ejecutar(eval_lenguaje, "", cola_det.det, "Det_SSR_" & cola_det.det.id_transf_det, "Det_SSR_class_" & cola_det.det.id_transf_det, eval)
                If err2.numError <> 0 Then
                    err2.titulo = "Error al ejecutar la tarea IF"
                    err2.mensaje = "Error al procesar la condición"
                    Return err2
                End If
                eval_res = err2.params("return_value")

                Dim tarea_siguiente As Integer
                tarea_siguiente = IIf(eval_res, id_transf_det_true, id_transf_det_false)

                If tarea_siguiente > 0 Then cola_det.sigs.Add(New tCola_det With {.det = Me.Transf.dets(tarea_siguiente).clone, .ant = Me, .eval_res = eval_res})

                Me.estado = tTransfererncia.nvenumTransfEstado.terminado
                Return New tError
            Catch ex As Exception
                Dim err As New tError
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar la tarea"
                err.mensaje = ""
                err.debug_src = "nvTranfDetEjecutar::detIF_ejecutar"
                cola_det.det.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try
        End Function

        Private Function _detEXP_ejecutar(cola_det As tCola_det) As tError

            Dim det As tTransfDet = Me
            Dim paramExport As New tnvExportarParam
            Dim path_temp As String

            Try

                paramExport.VistaGuardada = det.vistaguardada
                paramExport.filtroXML = IIf(det.filtroXML.Trim <> "", nvXMLSQL.encXMLSQL(nvTransfUtiles.evalString(det, det.filtroXML)), "")
                paramExport.filtroWhere = nvTransfUtiles.evalString(det, det.filtroWhere)
                paramExport.filtroParams = nvTransfUtiles.evalString(det, nvConvertUtiles.objectToScriptString(det.parametros))
                paramExport.xml_data = nvTransfUtiles.evalString(det, det.xml_data)

                Dim a As String = nvTransfUtiles.evalString(det, det.parametros)
                'Dim xml_xsl As String = det.xml_xsl

                '//Parametros de transformación 
                '//Si xsl_name tiene valor se busca el archivo dentro de la carpeta de la vista.
                '//Si no se busca la el archivo en la dirección indicada en path_xsl anexandole la carpeta de servidor

                paramExport.xsl_name = det.xsl_name
                paramExport.path_xsl = det.path_xsl
                paramExport.xml_xsl = det.xml_xsl

                paramExport.report_name = det.report_name
                paramExport.path_reporte = det.path_reporte

                '//Parametros de destino
                paramExport.ContentType = det.contentType
                paramExport.target = nvTransfUtiles.evalString(det, det.target)

                paramExport.filename = nvXMLUtiles.getNodeText(det.parametros_extra_xml, "parametros_extra/parametro[@nombre='filename']", "")
                paramExport.page_name = nvXMLUtiles.getNodeText(det.parametros_extra_xml, "parametros_extra/parametro[@nombre='page_name']", "")


                If det.transf_tipo = "EXP" AndAlso paramExport.path_xsl <> "" Then
                    path_temp = paramExport.path_xsl
                End If

                If det.transf_tipo = "INF" AndAlso paramExport.path_reporte <> "" Then
                    path_temp = paramExport.path_reporte
                End If

                Dim file As nvFW.nvFile.tnvFile = nvFW.nvFile.getFile(ref_files_path:=path_temp)
                If Not file Is Nothing Then

                    path_temp = nvServer.appl_physical_path & "App_Data\" & nvApp.getInstance().path_rel & "\report\temp\" & file.f_nombre & "." & file.f_ext
                    nvReportUtiles.create_folder(path_temp)

                    Dim fs = New System.IO.FileStream(path_temp, System.IO.FileMode.Create)
                    fs.Write(file.BinaryData, 0, file.BinaryData.Length)
                    fs.Close()

                    If det.transf_tipo = "EXP" Then
                        paramExport.path_xsl = "/report/temp/" & file.f_nombre & "." & file.f_ext
                    End If

                    If det.transf_tipo = "INF" Then
                        paramExport.path_reporte = "/report/temp/" & file.f_nombre & "." & file.f_ext
                    End If
                End If


                '//Si det.salida_tipo == adjunto entonces hay que fijarse si genera archivo, si es asi en el link hay que agregarlo para que se abra automáticamente
                '//sino hay que crear un archivo temporal
                Dim file_agregado As String = ""
                Dim arDestinos As List(Of Dictionary(Of String, String)) = nvReportUtiles.target_parse(paramExport.target)
                Dim generaFile As Boolean = False
                Dim target_path As String
                Dim target_basic As String = ""
                Dim script_browser As String
                Dim target_compression As String = ""

                For Each T In arDestinos
                    If T("protocolo").ToUpper() = "FILE" Then
                        target_path = T("path")

                        If target_basic = "" Then
                            target_basic = T("target_basic")
                        Else
                            target_basic += ";" & T("target_basic")
                        End If


                        If T("comp_filename") <> "" Then
                            target_basic = target_basic.Replace(T("filename"), T("comp_filename"))
                        End If

                        generaFile = True
                        'Exit For
                    End If
                Next

                If det.salida_tipo = nvenumSalidaTipo.adjunto Then
                    If Not generaFile Then
                        Dim path_tmp_i As Integer = 0
                        Do

                            target_path = "FILE:///tmp_" & det.Transf.id_transf_log & "_" & det.id_transf_log_det & "_" & path_tmp_i & ".tmp"
                            Dim arDestinosTMP As List(Of Dictionary(Of String, String)) = nvReportUtiles.target_parse(target_path)
                            target_path = arDestinosTMP(0)("path")
                            target_basic = arDestinosTMP(0)("target_basic")

                            paramExport.target = target_path & ";" & det.target

                        Loop While System.IO.File.Exists(target_path)
                    End If

                    script_browser = "var index = transf_log_dets['window'].length;" & vbCrLf
                    script_browser += "transf_log_dets['window'][index] = new Array();" & vbCrLf
                    script_browser += "transf_log_dets['window'][index].id = 'win_" & det.id_transf_log_det & "';" & vbCrLf
                    script_browser += "transf_log_dets['window'][index].win = window.open('/fw/files/file_get.aspx?content_disposition=attachment&path=FILE://'" & target_basic & "&contenttype=" & paramExport.ContentType.ToLower() & "&tmp_borrar=true&filename=" & paramExport.filename & "','win_" & det.id_transf_log_det & "','')"
                    det.script_browser = script_browser
                End If

                paramExport.salida_tipo = nvenumSalidaTipo.return '//Identifica si en la llamada será devuelto el resultado o un informe de resultado
                paramExport.mantener_origen = det.mantener_origen
                paramExport.id_exp_origen = det.id_exp_origen
                paramExport.export_exeption = det.metodo
                paramExport.parametros = det.parametros
                det.link_browser = target_basic

            Catch ex As Exception
                Dim err As New tError
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar la tarea"
                err.mensaje = "Error al procesar los parámetros de exportación"
                err.debug_src = "nvTranfDetEjecutar::detEXP_ejecutar"
                det.estado = tTransfererncia.nvenumTransfEstado.error
                Return err
            End Try

            If det.transf_tipo = "EXP" Then
                det.det_error = nvFW.reportViewer.exportarReporte(paramExport, det.Transf.ActiveConnections)
            End If

            If det.transf_tipo = "INF" Then
                det.det_error = nvFW.reportViewer.mostrarReporte(paramExport, det.Transf.ActiveConnections)
            End If

            If path_temp <> "" AndAlso System.IO.File.Exists(path_temp) Then
                System.IO.File.Delete(path_temp)
            End If

            If det.det_error.numError = 0 Then
                det.estado = tTransfererncia.nvenumTransfEstado.terminado
            Else
                det.estado = tTransfererncia.nvenumTransfEstado.error
            End If

            Return det.det_error
        End Function

        Private Shared Sub _DTS_Ejecutar_quitar_archivos(files As List(Of String))
            For Each path In files
                Try
                    System.IO.File.Delete(path)
                Catch ex As Exception

                End Try
            Next
        End Sub
        Private Function _detDTS_ejecutar(cola_det As tCola_det) As tError
            Dim det As tTransfDet = Me
            'Copia los archivos a la carpeta temporal del los DTS
            Dim path_destino As String = ""
            Dim path_destino_localfile As String = ""

            Dim files As New List(Of String)
            Dim xml_param_dtsx As String = ""
            Try
                For Each archivo In det.Transf.Archivos
                    'nvReportUtiles.get_file_path(target_path)

                    ' para los dts que utilizan la definicion de directorio de la implementacion "directorio_archivos"
                    path_destino = nvReportUtiles.get_file_path("directorio_archivos\tranf_tmp\" + archivo.Value("filename"))

                    'crear el path si no existiese
                    nvReportUtiles.create_folder(path_destino)

                    If System.IO.File.Exists(path_destino) Then System.IO.File.Delete(path_destino)
                    If System.IO.File.Exists(archivo.Value("path")) Then
                        System.IO.File.Copy(archivo.Value("path"), path_destino)
                        files.Add(path_destino)
                    End If

                    ' para los dts que utilizan el app_data como origen
                    path_destino_localfile = nvServer.appl_physical_path & "App_Data\localfile\" & archivo.Value("filename")
                    nvReportUtiles.create_folder(path_destino_localfile)

                    If System.IO.File.Exists(path_destino_localfile) Then System.IO.File.Delete(path_destino_localfile)
                    If System.IO.File.Exists(archivo.Value("path")) Then
                        System.IO.File.Copy(archivo.Value("path"), path_destino_localfile)
                        files.Add(path_destino_localfile)
                    End If

                Next

                det.link_browser = det.target

                Dim parametro As String
                Dim valor As String
                '//GENERAR EL XML DE PARAMETROS


                For Each p1 In det.Transf.param
                    'parametro = param.Value
                    '//Solamente los parametros indicados en el campo dtsx_parametros
                    Dim strreg = "(^|;|\\s)(" & p1.Value("parametro") & ")(\\s|;|$)"
                    Dim reg = New System.Text.RegularExpressions.Regex(strreg, RegexOptions.IgnoreCase)
                    If reg.IsMatch(det.dtsx_parametros) Then
                        valor = p1.Value("valor") 'nvConvertUtiles.objectToDTSparam(p1.Value("valor"))
                        xml_param_dtsx += "<" & p1.Value("parametro") & " variable='" & p1.Value("parametro") & "' tipo_dato='" & p1.Value("tipo_dato") & "'><![CDATA[" & valor & "]]></" & p1.Value("parametro") & ">"
                    End If

                Next
                If xml_param_dtsx <> "" Then
                    xml_param_dtsx = "<parametros>" & xml_param_dtsx & "</parametros>"
                End If
            Catch ex As Exception
                Dim err As New tError
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar la tarea"
                err.mensaje = "Error en el armado de los parametros"
                'err.debug_src = "nvTranfDetEjecutar::detDTS_ejecutar"
                det.estado = tTransfererncia.nvenumTransfEstado.error
                _DTS_Ejecutar_quitar_archivos(files)
                Return err
            End Try

            Dim dtsx_filename As String
            Dim dtsx_file_temp As String
            Try

                Dim file As nvFW.nvFile.tnvFile = nvFW.nvFile.getFile(ref_files_path:=det.dtsx_path)
                If Not file Is Nothing Then

                    dtsx_file_temp = System.IO.Path.GetTempFileName.Replace(".tmp", "." & file.f_ext)
                    Dim fs = New System.IO.FileStream(dtsx_file_temp, System.IO.FileMode.Create)
                    fs.Write(file.BinaryData, 0, file.BinaryData.Length)
                    fs.Close()

                    det.dtsx_path = dtsx_file_temp

                End If

                'Ejecutar
                Dim rsExec As ADODB.Recordset = nvDTSEjecutarUtiles.DTSRun(det.dtsx_path, xml_param_dtsx, det.dtsx_exec)
                'ANALIZAR EL RESULTADO
                Dim msgError As String = ""
                Dim id_run As Integer = 0
                While Not rsExec.EOF
                    msgError = IIf(IsDBNull(rsExec.Fields("output").Value), "", rsExec.Fields("output").Value)
                    id_run = rsExec.Fields("id_run").Value
                    det.det_error.debug_src = id_run ' .det_error.debug_src ['transf_error'].debug_src
                    If msgError.IndexOf("Error") = 0 Then
                        det.det_error = New tError()
                        det.det_error.numError = -1
                        det.det_error.debug_src = id_run.ToString()
                        det.det_error.titulo = "Error de ejecución DTSX"
                        det.det_error.mensaje = "El DTSX devolvió un error"
                        ''det.det_error.debug_desc = det.dtsx_path & " - " & xml_param_dtsx
                        Exit While
                    End If

                    rsExec.MoveNext()
                End While
                nvFW.nvDBUtiles.DBCloseRecordset(rsExec)

                If dtsx_file_temp <> "" AndAlso System.IO.File.Exists(dtsx_file_temp) Then
                    System.IO.File.Delete(dtsx_file_temp)
                End If

            Catch ex As Exception
                Dim err As New tError
                err.parse_error_script(ex)
                err.titulo = "Error al ejecutar la tarea"
                err.mensaje = "Error de ejecución DTSX"
                'err.debug_src = "nvTranfDetEjecutar::detDTS_ejecutar"
                'err.debug_desc = det.dtsx_path & " - " & xml_param_dtsx
                det.estado = tTransfererncia.nvenumTransfEstado.error
                _DTS_Ejecutar_quitar_archivos(files)

                Return err
            End Try

            Dim paramExport As New tnvExportarParam
            paramExport.target = nvTransfUtiles.evalString(det, det.target)
            Dim arDestinos As List(Of Dictionary(Of String, String)) = nvReportUtiles.target_parse(paramExport.target)
            Dim target_path As String = ""
            Dim target_basic As String = ""

            For Each T In arDestinos

                If T("protocolo").ToUpper() = "FILE" Then
                    target_path = T("path")

                    If target_basic = "" Then
                        target_basic = T("target_basic")
                    Else
                        target_basic += ";" & T("target_basic")
                    End If


                    If T("comp_filename") <> "" Then
                        target_basic = target_basic.Replace(T("filename"), T("comp_filename"))
                    End If

                End If
            Next
            det.link_browser = target_basic

            _DTS_Ejecutar_quitar_archivos(files)
            If det.det_error.numError = 0 Then
                det.estado = tTransfererncia.nvenumTransfEstado.terminado
            Else
                det.estado = tTransfererncia.nvenumTransfEstado.error
            End If

            Return det.det_error
        End Function

    End Class

End Namespace