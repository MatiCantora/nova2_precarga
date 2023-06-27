<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%
    Dim accion As String = nvUtiles.obtenerValor({"accion","a"}, "")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")
    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim Err As New tError
    Dim nro_mutual As Integer
    Dim nro_vendedor As Integer = 0


    Select Case accion.ToLower
        Case "evaluar"

            Dim id_transferencia As Integer = 1537
            Dim usa_cuad_robot As String = "0"
            XML = New System.Xml.XmlDocument
            XML.LoadXml(criterio)
            Dim cupo_premotor As String =  nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor","")
            Dim cuit As String =  nvXMLUtiles.getNodeText(XML, "criterio/cuit", 0)
            Dim nro_grupo As String =  nvXMLUtiles.getNodeText(XML, "criterio/nro_grupo", 0)
            Dim clave_sueldo As String =  nvXMLUtiles.getNodeText(XML, "criterio/clave_sueldo", "")
            Dim nro_tipo_cobro As Integer = nvXMLUtiles.getNodeText(XML, "criterio/nro_tipo_cobro", 0)
            nro_vendedor = nvXMLUtiles.getNodeText(XML, "criterio/nro_vendedor", 0)
            Dim nro_banco_debito As Integer = nvXMLUtiles.getNodeText(XML, "criterio/nro_banco", 0)
            Dim sce_id as Integer= nvXMLUtiles.getNodeText(XML, "criterio/sce_id", 0)
            Dim tTransferencia As New nvTransferencia.tTransfererncia
            Try
                tTransferencia.cargar(id_transferencia)
                tTransferencia.param("cuil")("valor") = cuit
                tTransferencia.param("nro_grupo")("valor") = nro_grupo
                tTransferencia.param("clave_sueldo")("valor") = clave_sueldo
                tTransferencia.param("nro_tipo_cobro")("valor") = nro_tipo_cobro
                tTransferencia.param("nro_vendedor")("valor") = nro_vendedor
                tTransferencia.param("nro_banco_debito")("valor") = nro_banco_debito
                tTransferencia.param("cod_servidor")("valor") = nvApp.cod_servidor


                If (cupo_premotor <> "") Then
                    tTransferencia.param("cupo_disponible")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_disponible", "")
                    tTransferencia.param("cupo_iplyc")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_iplyc", "")
                    tTransferencia.param("cupo_chacra")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_chacra", "")
                    tTransferencia.param("Scu_Id")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/scu_id", "")
                    tTransferencia.param("Scm_Id")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/scm_id", "")
                End If
                tTransferencia.param("Sce_Id")("valor") = sce_id

                tTransferencia.ejecutar()

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.mensaje = "No se pudo calcular la oferta. Intente nuevamente."
            End Try

            Dim errResume As tError = tTransferencia.getErrorResumen_xml()

            errResume.response()

            'Dim getErrorResumen_xml As String = tTransferencia.getErrorResumen_xml()

        'Case "disponible_ba_educacion"
        '    Dim req As New nvFW.servicios.Robots.RobotEducacion
        '    Dim EDUCACION_BA_UID as String=""
        '    Dim EDUCACION_BA_PWD as String=""
        '    EDUCACION_BA_UID = nvFW.nvUtiles.getParametroValor("EDUCACION_BA_UID")
        '    EDUCACION_BA_PWD = nvFW.nvUtiles.getParametroValor("EDUCACION_BA_PWD")

        '    Dim nro_docu As Integer
        '    Dim disponible As String = "0"
        '    Try
        '        XML = New System.Xml.XmlDocument
        '        XML.LoadXml(criterio)
        '        nro_docu = nvXMLUtiles.getNodeText(XML, "criterio/nro_docu", 0)
        '        nro_mutual = nvXMLUtiles.getNodeText(XML, "criterio/nro_mutual", 0)
        '        nro_vendedor = nvXMLUtiles.getNodeText(XML, "criterio/nro_vendedor", 0)
        '        req.nro_vendedor = nro_vendedor
        '        Dim nro_entidad As Integer = 0
        '        Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("select * from educacion_ba_entidades where nro_mutual=" & CStr(nro_mutual))
        '        If Not (rs.EOF) Then
        '            Err = req.login(uuid:=EDUCACION_BA_UID, pwd:=EDUCACION_BA_PWD)
        '            If (Err.numError = 0) Then
        '                nro_entidad = rs.Fields("nro_entidad").Value
        '                Err = req.obtener_monto_disponible(nro_docu:=nro_docu, nro_entidad:=nro_entidad)
        '            End If
        '        Else
        '            Err.numError = 1
        '            Err.mensaje = "la mutual de consulta no se puede encontrar en las entidades de educación. Consulte con el administrador"
        '        End If



        '    Catch ex As Exception
        '        Err.parse_error_script(ex)
        '    End Try
        '    ''si no contiene el parametro disponible, lo agrego
        '    If (Not Err.params.ContainsKey("disponible")) Then
        '        Err.params.Add("disponible", 0)
        '    End If

        '    strXML = Err.get_error_xml()

        'Case "certificado_ba_educacion"
        '    ''Stop
        '    Dim req As New nvFW.servicios.Robots.RobotEducacion
        '    Dim EDUCACION_BA_UID as String=""
        '    Dim EDUCACION_BA_PWD as String=""
        '    EDUCACION_BA_UID = nvFW.nvUtiles.getParametroValor("EDUCACION_BA_UID")
        '    EDUCACION_BA_PWD = nvFW.nvUtiles.getParametroValor("EDUCACION_BA_PWD")
        '    Dim nro_credito As Integer
        '    Try
        '        XML = New System.Xml.XmlDocument
        '        XML.LoadXml(criterio)
        '        nro_credito = nvXMLUtiles.getNodeText(XML, "criterio/nro_credito", 0)
        '        Dim nro_entidad As Integer = 0
        '        req.nro_vendedor = nvXMLUtiles.getNodeText(XML, "criterio/nro_vendedor", 0)
        '        Dim nro_def_detalle As Integer = 0
        '        Dim repetido As Boolean = False
        '        ''por ahora se toma la definicion del credito donde tenga cargado el item excepcion (si no lo tienen, el sistema no va a cargar nada) 
        '        Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("select cr.nro_credito,cr.nro_docu,e.nro_mutual,e.nro_entidad,e.entidad,month(getdate()) as mes,year(getdate()) as anio,cr.nro_def_archivo,def.* from vercreditos cr join educacion_ba_entidades e on e.nro_mutual=cr.nro_mutual join verArchivos_def_det def on cr.nro_def_archivo=def.nro_def_archivo and def.nro_archivo_def_tipo=0 where cr.nro_credito=" & CStr(nro_credito))
        '        If Not (rs.EOF) Then
        '            Dim entidad_nombre As String = rs.Fields("entidad").Value
        '            nro_entidad = rs.Fields("nro_entidad").Value
        '            nro_def_detalle = rs.Fields("nro_def_detalle").Value
        '            repetido = (rs.Fields("repetido").Value = 1)
        '            Dim nro_docu As String = rs.Fields("nro_docu").Value
        '            Dim mes As String = rs.Fields("mes").Value
        '            Dim anio As String = rs.Fields("anio").Value
        '            Err = req.login(uuid:=EDUCACION_BA_UID, pwd:=EDUCACION_BA_PWD)
        '            If (Err.numError = 0) Then
        '                Err = req.obtener_info_certificado_periodo(nro_docu:=nro_docu, entidad:=entidad_nombre, mes:=mes, anio:=anio)
        '                ''si no se encuentra certificado en el periodo, que lo dé de alta
        '                If (Err.numError = 100) Then
        '                    Err = req.presentar_certificado(nro_docu:=nro_docu, nro_entidad:=nro_entidad)
        '                End If
        '                ''si obtubo certificado por alguno de los dos metodos, lo agrego al legajo
        '                If (Err.numError = 0) Then
        '                    Dim path_rova As String = ""
        '                    Dim filename As String = ""
        '                    path_rova = nvFW.nvReportUtiles.get_file_path("(nvarchivos)/")
        '                    Dim filepath As String = Err.params("tmpfile")
        '                    Dim strSQL As String = "SET NOCOUNT ON" & vbCrLf
        '                    strSQL &= "declare @nro_archivo int " & vbCrLf
        '                    strSQL &= "select @nro_archivo=isnull(max(nro_archivo), 0) + 1  from archivos WITH (NOLOCK) " & vbCrLf
        '                    strSQL &= "Insert Into archivos (nro_archivo,Descripcion,nro_credito,momento,nro_def_detalle,operador,nro_archivo_estado,nro_img_origen) values(@nro_archivo,'Certificado educación','" & nro_credito & "',getdate(),'" & nro_def_detalle & "','" & nvApp.operador.operador & "',1,1)" & vbCrLf
        '                    If Not (repetido) Then
        '                        strSQL &= "update archivos set nro_archivo_estado = 2 where nro_def_detalle = " & nro_def_detalle & " and nro_credito = " & CStr(nro_credito) & " and nro_archivo<> @nro_archivo" & vbCrLf
        '                    End If
        '                    strSQL &= "SET NOCOUNT OFF" & vbCrLf
        '                    strSQL &= "select @nro_archivo as maxArchivo"
        '                    Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
        '                    Dim nro_archivo As Integer = rsA.Fields("maxArchivo").Value
        '                    nvFW.nvDBUtiles.DBCloseRecordset(rsA)
        '                    Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
        '                    Dim archivo As String = carpeta & "\" & nro_archivo & ".pdf"
        '                    Dim path_rova_absoluto As String = path_rova & carpeta & "\\" & nro_archivo & ".pdf"
        '                    Try
        '                        nvFW.nvReportUtiles.create_folder(path_rova & carpeta & "\\")
        '                        System.IO.File.Copy(Err.params("tmpfile"), path_rova_absoluto)
        '                        filename = System.IO.Path.GetFileName(path_rova_absoluto)
        '                        Err.params.Item("tmpfile") = ""
        '                        Err.params.Add("nova_filename", filename)
        '                        strSQL = "update archivos set path = '" & archivo & "' where nro_archivo = " & nro_archivo
        '                    Catch ex As Exception
        '                        Err.parse_error_script(ex)
        '                    End Try

        '                    nvFW.nvDBUtiles.DBExecute(strSQL)
        '                End If
        '            End If
        '            nvDBUtiles.DBCloseRecordset(rs)
        '        Else
        '            Err.numError = 1
        '            Err.mensaje = "No podemos procesar el certificado para este tipo de credito. Consulte con el administrador"
        '        End If
        '        XML = Nothing
        '    Catch ex As Exception
        '        Err.parse_error_script(ex)
        '    End Try
        '    strXML = Err.get_error_xml()

        Case "precarga_motor"
            Try
                Dim hash As String = ""
                Err = nvLogin.execute(nvApp, "get_hash", nvApp.operador.login, "", "", "", "", "")
                hash = Err.params("hash")
                Dim aspx_callback As String = "FW/servicios/ROBOTS/GetXML.aspx?accion=consultar_motor"
                Dim URLREQUEST As String = "https://" & nvApp.server_name & "/" & aspx_callback
                Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("Select  isnull(dbo.piz1D('CUAD callback robot','" & nvApp.cod_servidor & "'),'') as host_callback")
                If Not (rs.EOF) Then
                    If (rs.Fields("host_callback").Value <> "") Then
                        URLREQUEST = "https://" & rs.Fields("host_callback").Value & "/" & aspx_callback
                    End If
                End If
                nvDBUtiles.DBCloseRecordset(rs)
                'Dim URLREQUEST As String = "https://" & nvApp.server_name
                ''Dim URLREQUEST As String = "https://" & nvApp.server_name & ":10449/fw/servicios/uif/consultar.aspx"
                ' Dim URLREQUEST As String = "https://novatest.redmutual.com.ar:10449/FW/servicios/ROBOTS/GetXML.aspx?accion=consultar_motor"
                ' Dim URLREQUEST As String = "https://jozan.redmutual.com.ar:10443/FW/servicios/ROBOTS/GetXML.aspx?accion=consultar_motor"
                ''nvApp.cod_servidor -> contiene el nombre simple del servidor (jozan,novii1,novation1 etc)
                ''nvApp.server_path -> contiene el nombre del host sin puerto ("https://jozan.redmutual.com.ar")
                ''nvApp.server_port -> contiene el nombre del puerto (10443)
                Dim oHTTP As New nvHTTPRequest
                oHTTP.multi_part = True
                oHTTP.url = URLREQUEST
                'JMO: Porque entra a mutuales?? Si es precarga
                'oHTTP.param_add("app_cod_sistema", "nv_mutuales")
                'oHTTP.param_add("app_path_rel", "meridiano")
                oHTTP.param_add("app_cod_sistema", nvApp.cod_sistema)
                oHTTP.param_add("app_path_rel", nvApp.path_rel)

                oHTTP.param_add("criterio", criterio)
                oHTTP.param_add("hash", hash)
                oHTTP.param_add("nv_hash", hash)
                oHTTP.param_add("end", "")
                oHTTP.time_out = 800000
                Dim response As Net.HttpWebResponse = oHTTP.getResponse()

                If (response Is Nothing) Then
                    Err.numError = -1
                    Err.mensaje = "Servicio apagado. URL: " & URLREQUEST
                    strXML = Err.get_error_xml()
                Else
                    Dim reader As System.IO.StreamReader = New System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding("iso-8859-1"))
                    Dim oXML As New System.Xml.XmlDocument
                    strXML = reader.ReadToEnd()
                    reader.Close()
                    reader = Nothing
                End If
                ''Stop
                ''cargo el terror tmp por si viene cualquier cosa
                Dim ErrTmp As New tError
                ErrTmp.loadXML(strXML)
                If (ErrTmp.numError <> 0) Then
                    Err.numError = -5
                    Err.mensaje = "No se pudo procesar la informacion. Intente luego"
                    Err.params("strXML") = strXML
                    strXML = Err.get_error_xml()
                End If
                ErrTmp = Nothing
                oHTTP = Nothing
                response = Nothing
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.numError = -1
                Err.mensaje = ex.Message.ToString
                strXML = Err.get_error_xml()
            End Try
            Err.clear()
        Case "consultar_motor"

            Dim id_transferencia As Integer = 1537
            Dim usa_cuad_robot As String = "0"
            XML = New System.Xml.XmlDocument
            XML.LoadXml(criterio)
            Dim cupo_premotor As String = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor", "")
            Dim cuit As String = nvXMLUtiles.getNodeText(XML, "criterio/cuit", 0)
            Dim nro_grupo As String = nvXMLUtiles.getNodeText(XML, "criterio/nro_grupo", 0)
            Dim clave_sueldo As String = nvXMLUtiles.getNodeText(XML, "criterio/clave_sueldo", "")
            Dim nro_tipo_cobro As Integer = nvXMLUtiles.getNodeText(XML, "criterio/nro_tipo_cobro", 0)
            nro_vendedor = nvXMLUtiles.getNodeText(XML, "criterio/nro_vendedor", 0)
            Dim nro_banco_debito As Integer = nvXMLUtiles.getNodeText(XML, "criterio/nro_banco", 0)
            Dim sce_id As Integer = nvXMLUtiles.getNodeText(XML, "criterio/sce_id", 0)
            Dim tTransferencia As New nvTransferencia.tTransfererncia
            Try
                tTransferencia.cargar(id_transferencia)
                tTransferencia.param("cuil")("valor") = cuit
                tTransferencia.param("nro_grupo")("valor") = nro_grupo
                tTransferencia.param("clave_sueldo")("valor") = clave_sueldo
                tTransferencia.param("nro_tipo_cobro")("valor") = nro_tipo_cobro
                tTransferencia.param("nro_vendedor")("valor") = nro_vendedor
                tTransferencia.param("nro_banco_debito")("valor") = nro_banco_debito
                tTransferencia.param("cod_servidor")("valor") = nvApp.cod_servidor


                If (cupo_premotor <> "") Then
                    tTransferencia.param("cupo_disponible")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_disponible", "")
                    tTransferencia.param("cupo_iplyc")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_iplyc", "")
                    tTransferencia.param("cupo_chacra")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_chacra", "")
                    tTransferencia.param("Scu_Id")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/scu_id", "")
                    tTransferencia.param("Scm_Id")("valor") = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/scm_id", "")
                End If
                tTransferencia.param("Sce_Id")("valor") = sce_id
                tTransferencia.ejecutar()
                Dim error_count As Integer = 0
                For Each cola_det In tTransferencia.dets_run
                    If cola_det.det.det_error.numError <> 0 Then error_count += 1
                Next
                '*************************************************************
                ' Si hay ERRORES => salir con excepción
                '*************************************************************
                If error_count > 0 Then
                    Throw New Exception("Error en transferencia (" & error_count & ")")
                End If
                '*************************************************************
                ' Si hay mensaje de error => salir con excepción
                '*************************************************************
                For Each kvp As KeyValuePair(Of String, trsParam) In tTransferencia.param
                    Dim clave As String = kvp.Key
                    Dim parametro As trsParam = kvp.Value
                    If (Not Err.params.ContainsKey(clave)) Then
                        Err.params.Add(clave, CStr(parametro.Item("valor")))
                    End If
                Next


                ' Err.params.Add("dictamen", tTransferencia.param("dictamen").Item("valor"))
                Dim mensaje_usuario As String = IIf(tTransferencia.param("mensaje_usuario").Item("valor") Is Nothing, "", tTransferencia.param("mensaje_usuario").Item("valor"))
                Dim partes = mensaje_usuario.Split("|")
                mensaje_usuario = ""
                For Each p In partes
                    If (p <> "") Then
                        If (mensaje_usuario <> "") Then
                            mensaje_usuario &= "<br/>" & p
                        Else
                            mensaje_usuario &= p
                        End If
                    End If
                Next

                mensaje_usuario = mensaje_usuario.Replace("&lt;", "<").Replace("&gt;", ">")
                Err.params("mensaje_usuario") = mensaje_usuario
                Err.params("nro_grupo") = nro_grupo
                Err.params("socio_nuevo") = IIf(tTransferencia.param("socio_nuevo").Item("valor") = "true", 1, 0)
                Err.params.Add("importe_cs", 0)
                'Err.params.Add("bcra_sit_financiera", tTransferencia.param("bcra_sit_financiera").Item("valor"))
                'Err.params.Add("bcra_sit", tTransferencia.param("bcra_sit").Item("valor"))
                'Err.params.Add("cant_sit_juridica", tTransferencia.param("cant_sit_juridica").Item("valor"))
                'Err.params.Add("ch_rechazados", tTransferencia.param("ch_rechazados").Item("valor"))
                'Err.params.Add("control_edad", tTransferencia.param("control_edad").Item("valor"))
                'Err.params.Add("grupo", tTransferencia.param("grupo").Item("valor"))
                'Err.params.Add("nro_tipo_cobro", tTransferencia.param("nro_tipo_cobro").Item("valor"))
                'Err.params.Add("tipo_cobro", tTransferencia.param("tipo_cobro").Item("valor"))
                'Err.params.Add("ent_excluidas", tTransferencia.param("ent_excluidas").Item("valor"))
                'Err.params.Add("nosis_cda", tTransferencia.param("nosis_cda").Item("valor"))
                'Err.params.Add("nosis_cda_desc", tTransferencia.param("nosis_cda_desc").Item("valor"))
                'Err.params.Add("motivo", tTransferencia.param("motivo").Item("valor"))
                'Err.params.Add("nro_entidad_cda", tTransferencia.param("nro_entidad_cda").Item("valor"))
                'Err.params.Add("clave_sueldo", tTransferencia.param("clave_sueldo").Item("valor"))
                'Err.params.Add("sueldo_bruto", tTransferencia.param("sueldo_bruto").Item("valor"))
                'Err.params.Add("desc_ley", tTransferencia.param("desc_ley").Item("valor"))
                'Err.params.Add("sueldo_neto", tTransferencia.param("sueldo_neto").Item("valor"))
                'Err.params.Add("es_poder_judicial", tTransferencia.param("es_poder_judicial").Item("valor"))
                'Err.params.Add("cupo_disponible", tTransferencia.param("cupo_disponible").Item("valor"))
                'Err.params.Add("id_transf_log", tTransferencia.param("id_transf_log").Item("valor"))
                'Err.params.Add("nro_motor_decision", tTransferencia.param("nro_motor_decision").Item("valor"))
                'Err.params.Add("Scu_Id", tTransferencia.param("Scu_Id").Item("valor"))
                'Err.params.Add("Sce_Id", tTransferencia.param("Sce_Id").Item("valor"))
                'Err.params.Add("Scm_Id", tTransferencia.param("Scm_Id").Item("valor"))
                'Err.params.Add("socio_nuevo", IIf(tTransferencia.param("socio_nuevo").Item("valor") = "true", 1, 0))
                'Err.params.Add("bcra_calificacion_cendeu", tTransferencia.param("bcra_calificacion_cendeu").Item("valor"))
                'Err.params.Add("nosis_id_consulta", tTransferencia.param("nosis_id_consulta").Item("valor"))

                ''indica si el rechazo proviene del/los motor/es de decision configurados en la transferencia
                Dim rechaza_motor As Integer = 0
                If ((tTransferencia.param("nro_motor_decision").Item("valor") = 1538 Or tTransferencia.param("nro_motor_decision").Item("valor") = 1631) And (tTransferencia.param("dictamen").Item("valor").ToUpper = "RECHAZADO") Or (tTransferencia.param("dictamen").Item("valor").ToUpper = "RECHAZAR")) Then
                    rechaza_motor = 1
                End If
                Err.params.Add("rechaza_motor", rechaza_motor)

                Dim evalua_motor As Integer = 0
                ''indica si el motor, se encarga de evaluar, sino el producto es evaluado por el camino tradicional
                If (tTransferencia.param("nro_motor_decision").Item("valor") = 1538 Or tTransferencia.param("nro_motor_decision").Item("valor") = 1631 Or tTransferencia.param("nro_motor_decision").Item("valor") = 1613) Then
                    evalua_motor = 1
                End If

                ''indica si la consulta cupo y el consumo, se encarga el robot de CUAD
                If (tTransferencia.param("nro_motor_decision").Item("valor") = 1538 Or tTransferencia.param("nro_motor_decision").Item("valor") = 1631) Then
                    usa_cuad_robot = "1"
                End If
                Err.params.Add("usa_cuad_robot", usa_cuad_robot)
                Err.params.Add("evalua_motor", evalua_motor)
                ''ojo que los archivos xml se toman desde C:\Windows\SysWOW64\inetsrv\directorio_archivos\MotorDSStaFe\2078754_respuesta.xml    
                Dim errXML As tError = tTransferencia.getErrorResumen_xml(include_file:=True)
                Dim NOD As System.Xml.XmlNode = CType(errXML.params.Values(3), System.Xml.XmlNode)
                If (nvXMLUtiles.selectSingleNode(NOD, "/targets/target") IsNot Nothing) Then
                    strXML = nvXMLUtiles.selectSingleNode(NOD, "/targets/target").InnerXml
                End If

                Err.params.Add("strXML", strXML)
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.mensaje = "No se pudo calcular la oferta. Intente nuevamente."
            End Try
            strXML = Err.get_error_xml()
            Err.clear()
            tTransferencia = Nothing
            XML = Nothing
            'Err.response()
        Case "consultar_premotor"

            Dim id_transferencia As Integer = 1623
            XML = New System.Xml.XmlDocument
            XML.LoadXml(criterio)
            Dim nro_docu As String = nvXMLUtiles.getNodeText(XML, "criterio/nro_docu", 0)
            Dim sce_id As String = nvXMLUtiles.getNodeText(XML, "criterio/sce_id", 0)
            Dim clave_sueldo As String = nvXMLUtiles.getNodeText(XML, "criterio/clave_sueldo", 0)
            Dim tTransferencia As New nvTransferencia.tTransfererncia
            Try
                tTransferencia.cargar(id_transferencia)
                tTransferencia.param("nro_docu")("valor") = nro_docu
                tTransferencia.param("Sce_Id")("valor") = sce_id
                tTransferencia.param("clave_sueldo")("valor") = clave_sueldo
                tTransferencia.ejecutar()
                Dim error_count As Integer = 0
                For Each cola_det In tTransferencia.dets_run
                    If cola_det.det.det_error.numError <> 0 Then error_count += 1
                Next
                '*************************************************************
                ' Si hay ERRORES => salir con excepción
                '*************************************************************
                If error_count > 0 Then
                    Throw New Exception("Error en transferencia (" & error_count & ")")
                End If
                '*************************************************************
                ' Si hay mensaje de error => salir con excepción
                '*************************************************************
                For Each kvp As KeyValuePair(Of String, trsParam) In tTransferencia.param
                    Dim clave As String = kvp.Key
                    Dim parametro As trsParam = kvp.Value
                    If (Not Err.params.ContainsKey(clave)) Then
                        Err.params.Add(clave, CStr(parametro.Item("valor")))
                    End If
                Next
                ''ojo que los archivos xml se toman desde C:\Windows\SysWOW64\inetsrv\directorio_archivos\MotorDSStaFe\2078754_respuesta.xml    
                Dim errXML As tError = tTransferencia.getErrorResumen_xml(include_file:=True)
                Dim NOD As System.Xml.XmlNode = CType(errXML.params.Values(3), System.Xml.XmlNode)
                If (nvXMLUtiles.selectSingleNode(NOD, "/targets/target") IsNot Nothing) Then
                    strXML = nvXMLUtiles.selectSingleNode(NOD, "/targets/target").InnerXml
                End If
                errXML.clear()
                Err.params.Add("strXML", strXML)
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.mensaje = "No se pudo consultar. Intente nuevamente."
            End Try
            tTransferencia = Nothing
            strXML = Err.get_error_xml()
            XML = Nothing
        Case "consultar_cbu"
            XML = New System.Xml.XmlDocument
            XML.LoadXml(criterio)
            Dim cuenta As String = nvXMLUtiles.getNodeText(XML, "criterio/cuenta", 0)
            Dim host As String = nvUtiles.getParametroValor("url_srv_test", "")
            Dim urlpdfx As String = nvUtiles.getParametroValor("pfx_ok_test", "")
            Dim pwdpdfx As String = nvUtiles.getParametroValor("pwd_pfx_ok_test", "")
            Dim apivoii As New nvFW.servicios.voii.ApiBanking(urlpdfx:=urlpdfx, pwdpdfx:=pwdpdfx, host:=host)
            apivoii.inicializar()
            Err = apivoii.consultarCBU(cuenta)
            strXML = Err.get_error_xml()
            apivoii = Nothing
            Err.clear()
        Case "files_cuad_add"
            criterio = HttpUtility.UrlDecode(criterio)
            Dim nro_credito As Integer = 0
            Dim rsP As ADODB.Recordset = Nothing '' record set para parametros de respuesta
            Dim rsC As ADODB.Recordset = Nothing
            Dim robot As New nvFW.servicios.Robots.wsCuad
            Dim nvFile As New nvFW.servicios.nvProcesamiento
            Dim numError As Integer = 0
            Dim xmlresponse As String = ""
            Dim log_id As Integer = 0
            Dim cadprestacion As Integer = 0
            Dim cadcuota As Integer = 0
            Dim captura As Integer = 0
            Err.clear()

            Try
                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                nro_credito = CInt(XML.SelectSingleNode("criterio/nro_credito").InnerText)
                rsC = nvFW.nvDBUtiles.DBOpenRecordset("select consumo_log_id  from CUAD_motor_calificacion where consumo_log_id is not null and nro_credito=" & CStr(nro_credito))
                If Not (rsC.EOF) Then
                    ''recorro por creditos en esperando respuesta y cuyo respuesta (bien o mal) haya devuelto, parametro X:dias pendientes
                    rsC = nvFW.nvDBUtiles.DBOpenRecordset("select cr.nro_credito, case when cadprestacion.nro_archivo is not null then 1 else 0 end cadprestacion,case when cadcuota.nro_archivo is not null then 1 else 0 end cadcuota ,case when captura.nro_archivo is not null then 1 else 0 end captura,m.xmlresponse,m.id as log_id from vercreditos cr left outer join verArchivos cadprestacion on cr.nro_credito=cadprestacion.nro_credito and cadprestacion.nro_archivo_estado=1 and cadprestacion.nro_archivo_def_tipo=2 left outer join verArchivos cadcuota on cr.nro_credito=cadcuota.nro_credito and cadcuota.nro_archivo_estado=1 and cadcuota.nro_archivo_def_tipo=46 left outer join verArchivos captura on cr.nro_credito=captura.nro_credito and captura.nro_archivo_estado=1 and captura.nro_archivo_def_tipo=118 join CUAD_motor_calificacion cl on cr.nro_credito=cl.nro_credito join lausana_anexa..cuad_robot m on cl.consumo_log_id=m.id  where cr.nro_credito=" & CStr(nro_credito))
                    Dim parametros As New System.Collections.Generic.Dictionary(Of String, String)
                    xmlresponse = rsC.Fields("xmlresponse").Value
                    log_id = rsC.Fields("log_id").Value
                    cadprestacion = rsC.Fields("cadprestacion").Value
                    cadcuota = rsC.Fields("cadcuota").Value
                    captura = rsC.Fields("captura").Value
                    ''tomo los parametros distinto de vacio y hayan sido respondidos, si numError<>0 algo paso y debe pasarse a observado, sino paso al estado que propuso el motor mediante la tabla CUAD_motor_calificacion
                    rsP = nvFW.nvDBUtiles.DBOpenRecordset("select p.parametro,p.valor  from lausana_anexa..cuad_robot_parametros p join lausana_anexa..cuad_robot r on p.id=r.id where p.tipo='response' and p.id=" & log_id & " and r.servicio='WsAltaConsumoDirecto' and r.vigente=0  and p.valor<>''")
                    While Not (rsP.EOF)
                        parametros.Add(rsP.Fields("parametro").Value, rsP.Fields("valor").Value)
                        rsP.MoveNext()
                    End While
                    nvDBUtiles.DBCloseRecordset(rsP)
                    Dim bytes As Byte() = Nothing
                    If (parametros.ContainsKey("comprobante_consumo_64")) Then
                        Try
                            If (cadprestacion = 0) Then
                                bytes = robot.getPdf(parametros("comprobante_consumo_64"))
                                Err = nvFile.addfilelegajo(binary:=bytes, nro_credito:=nro_credito, nro_archivo_def_tipo:=2, cod_sistema:="nv_mutual") '' adjunto cad de prestacion al legajo
                            End If
                        Catch ex As Exception
                            Err.parse_error_script(ex)
                        End Try
                    End If
                    bytes = Nothing
                    If (parametros.ContainsKey("comprobante_screen")) Then
                        Try
                            Dim _pdf As New nvFW.nvPDF
                            Try

                                If (captura = 0) Then
                                    bytes = robot.parseBytes(parametros("comprobante_screen"))
                                    bytes = _pdf.ImageToPDF(bytes) '' convierto a pdf
                                    Err = nvFile.addfilelegajo(binary:=bytes, nro_credito:=nro_credito, nro_archivo_def_tipo:=118, cod_sistema:="nv_mutual") '' adjunto captura del cuad
                                End If
                            Catch ex As Exception
                                Err.parse_error_script(ex)
                            End Try

                        Catch ex As Exception
                            Err.parse_error_script(ex)
                        End Try
                    End If
                    bytes = Nothing
                    If (parametros.ContainsKey("comprobante_filiacion_64")) Then
                        Try
                            If (cadcuota = 0) Then
                                bytes = robot.getPdf(parametros("comprobante_filiacion_64"))
                                Err = nvFile.addfilelegajo(binary:=bytes, nro_credito:=nro_credito, nro_archivo_def_tipo:=46, cod_sistema:="nv_mutual") '' adjunto cad de cuota social (alta como socio)
                            End If

                        Catch ex As Exception
                            Err.parse_error_script(ex)
                        End Try
                    End If
                    bytes = Nothing
                Else
                    Err.numError = -1
                    Err.mensaje = "el credito no pertenece al proceso de calificacion de cuad"
                End If
                nvDBUtiles.DBCloseRecordset(rsC)
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error en la generacion de archivos"
                Err.mensaje = "Salida por exception :" & ex.Message & " - " & ex.StackTrace
                Err.debug_src = "getxml::files_cuad_add"
            End Try
            strXML = Err.get_error_xml()
            Err.clear()
    End Select
    nvXMLUtiles.responseXML(Response, strXML)
    Response.End()


%>