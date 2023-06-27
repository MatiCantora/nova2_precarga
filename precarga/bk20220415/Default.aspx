<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", "0")
    Dim login As String = nvApp.operador.login
    Dim ip_usr As String = Request.ServerVariables("REMOTE_ADDR")
    Dim ip_srv As String = Request.ServerVariables("LOCAL_ADDR")
    Dim server_name As String = nvApp.cod_servidor
    Select Case modo.ToUpper
        Case "L"
            Dim err As New nvFW.tError
            Try
                Dim xmlLog As String = nvFW.nvUtiles.obtenerValor("xmlLog", "")
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_precarga_log", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@xmlLog", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlLog.Length, xmlLog)
                Dim rs As ADODB.Recordset = cmd.Execute()
                Dim numError As Integer = rs.Fields("numError").Value
                Dim mensaje As String = rs.Fields("mensaje").Value
                err.mensaje = mensaje
                err.numError = numError
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al registrar la consulta."
                err.comentario = ""
            End Try
            err.response()

        Case "F"    'Actualizar Fuentes de Nosis

            Dim err As New nvFW.tError
            Try

                Dim documento As String = nvFW.nvUtiles.obtenerValor("cuit", "")
                Dim url As String = nvFW.nvUtiles.obtenerValor("url", "")

                Dim nvNosisFuentes As New nvFW.servicios.tnvNosisFuentes
                nvNosisFuentes.URL = url
                nvNosisFuentes.timeOut = 20
                Dim respuesta = nvNosisFuentes.ActualizarFuentesNosis(documento)
                err.numError = 0
                err.titulo = ""
                err.mensaje = ""
                If (respuesta <> 1) Then
                    err.numError = 99
                    err.titulo = "Generar informe comercial."
                    err.mensaje = "Error al actualizar las fuentes externas. Intente Nuevamente."
                End If
                err.params("respuesta") = respuesta
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al actualizar las fuentes externas"
                err.comentario = ""
            End Try
            err.response()

        Case "E"
            Dim err As New nvFW.tError
            Try
                Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")
                Dim nro_vendedor As Integer = nvFW.nvUtiles.obtenerValor("nro_vendedor", "")

                err.params("cr_mes") = 0
                err.params("tiene_cs") = 0
                err.params("tiene_cr") = 0
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select nro_credito from vercreditos where cuit = '" & cuit & "' and nro_vendedor = " & nro_vendedor & " and estado in ('H','M','P') and fe_estado >= dbo.finac_inicio_mes(getdate())")
                If (rs.EOF = False) Then
                    err.params("cr_mes") = 1
                End If
                nvDBUtiles.DBCloseRecordset(rs)
                rs = nvDBUtiles.DBOpenRecordset("select nro_credito from vercreditos where cuit = '" & cuit & "' and nro_banco = 200 and estado = 'T'")
                If (rs.EOF = False) Then
                    err.params("tiene_cs") = 1
                End If
                nvDBUtiles.DBCloseRecordset(rs)
                rs = nvDBUtiles.DBOpenRecordset("select nro_credito from vercreditos where cuit = '" & cuit & "' and nro_banco <> 200 and estado = 'T'")
                If (rs.EOF = False) Then
                    err.params("tiene_cr") = 1
                End If
                nvDBUtiles.DBCloseRecordset(rs)
                err.numError = 0

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al evaluar socio"
                err.comentario = ""
            End Try
            err.response()

        Case "S"    'Generar Solicitud
            Dim err As New nvFW.tError
            Try
                Dim persona_existe As Boolean
                If nvFW.nvUtiles.obtenerValor("persona_existe", "") = "true" Then
                    persona_existe = True
                End If
                Dim noti_prov As Boolean
                If nvFW.nvUtiles.obtenerValor("noti_prov", "") = "true" Then
                    noti_prov = True
                End If
                Dim nro_archivo_noti_prov As Integer = nvFW.nvUtiles.obtenerValor("nro_archivo_noti_prov", "0")
                Dim xmlpersona As String = nvFW.nvUtiles.obtenerValor("xmlpersona", "")
                Dim xmltrabajo As String = nvFW.nvUtiles.obtenerValor("xmltrabajo", "")
                Dim xmlcredito As String = nvFW.nvUtiles.obtenerValor("xmlcredito", "")
                Dim xmlanalisis As String = nvFW.nvUtiles.obtenerValor("xmlanalisis", "")
                Dim xmlcancelaciones As String = nvFW.nvUtiles.obtenerValor("xmlcancelaciones", "")
                Dim xmlparametros As String = nvFW.nvUtiles.obtenerValor("xmlparametros")
                Dim estado As String = nvFW.nvUtiles.obtenerValor("estado")
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_cr_solicitud_v10", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                cmd.addParameter("@persona_existe", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, persona_existe)
                cmd.addParameter("@noti_prov", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, noti_prov)
                cmd.addParameter("@nro_archivo_noti_prov", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_archivo_noti_prov)
                cmd.addParameter("@XMLpersona", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlpersona.Length, xmlpersona)
                cmd.addParameter("@XMLtrabajo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmltrabajo.Length, xmltrabajo)
                cmd.addParameter("@XMLcredito", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcredito.Length, xmlcredito)
                cmd.addParameter("@XMLanalisis", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlanalisis.Length, xmlanalisis)
                cmd.addParameter("@XMLcancelaciones", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcancelaciones.Length, xmlcancelaciones)
                cmd.addParameter("@XMLparametros", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlparametros.Length, xmlparametros)

                Dim rs As ADODB.Recordset = cmd.Execute()
                nro_credito = rs.Fields("nro_credito").Value
                Dim modo1 As String = rs.Fields("modo").Value
                Dim numError As Integer = rs.Fields("numError").Value
                Dim mensaje As String = rs.Fields("mensaje").Value
                err.params("nro_credito") = nro_credito
                err.params("estado") = estado
                err.mensaje = mensaje
                err.numError = numError

                If numError = 0 And modo1 = "A" Then
                    Try
                        'Incorporar archivo Nosis al credito
                        Dim NosisXML As String = nvFW.nvUtiles.obtenerValor("NosisXML")

                        If NosisXML <> "" Then
                            Dim objXML As System.Xml.XmlDocument

                            objXML = New System.Xml.XmlDocument
                            objXML.LoadXml(NosisXML)
                            Dim strHTML As String = objXML.SelectSingleNode("Respuesta/ParteHTML").InnerText

                            Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset("Select isnull(max(nro_archivo), 0) + 1 As maxArchivo from archivos")
                            Dim nro_archivo As Integer = rsA.Fields("maxArchivo").Value
                            nvFW.nvDBUtiles.DBCloseRecordset(rsA)

                            nvFW.nvDBUtiles.DBExecute("Insert Into archivos (nro_archivo, path, operador,nro_img_origen,nro_archivo_estado) values(" & nro_archivo & ", '" & nro_archivo & "','" & nvApp.operador.operador & "',1,1)")
                            Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
                            Dim filename As String = nro_archivo & ".html"

                            'Guardado en Nova
                            'Dim path_carpeta As String
                            'path_carpeta = "\\\\" & server_name & "\\d$\\MeridianoWeb\\Meridiano\\archivos\\" & carpeta
                            'If System.IO.Directory.Exists(path_carpeta) = False Then
                            '    System.IO.Directory.CreateDirectory(path_carpeta)
                            'End If
                            'Dim path As String = path_carpeta & "\\" & filename
                            'Dim fs2 As New System.IO.FileStream(path, IO.FileMode.Create)
                            'Dim buffer() As Byte = nvFW.nvConvertUtiles.StringToBytes(strHTML)
                            'fs2.Write(buffer, 0, buffer.Length)
                            'fs2.Close()

                            'Guardado en Rova
                            Dim path_rova As String
                            Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = 'nv_mutual' and cod_servidor = '" & server_name & "' and cod_ss_dir = 'nvArchivosDefault'")
                            path_rova = rsRova.Fields("path").Value.Replace("\", "\\") & carpeta
                            If System.IO.Directory.Exists(path_rova) = False Then
                                System.IO.Directory.CreateDirectory(path_rova)
                            End If
                            Dim pathR As String = path_rova & "\\" & filename
                            'System.IO.File.Copy(path, pathR, True)

                            Dim fs3 As New System.IO.FileStream(pathR, IO.FileMode.Create)
                            Dim buffer1() As Byte = nvFW.nvConvertUtiles.StringToBytes(strHTML)
                            fs3.Write(buffer1, 0, buffer1.Length)
                            fs3.Close()

                            Dim rsDef = nvFW.nvDBUtiles.DBOpenRecordset("select nro_def_detalle,archivo_descripcion from verArchivos_def where nro_credito = " & nro_credito & " and  archivo_descripcion like 'NOSIS%'")
                            Dim nro_def_detalle As Integer = rsDef.Fields("nro_def_detalle").Value
                            Dim archivo_descripcion As String = rsDef.Fields("archivo_descripcion").Value

                            nvFW.nvDBUtiles.DBExecute("update archivos set nro_archivo_estado = 2 where nro_def_detalle = " & nro_def_detalle & " and nro_credito = " & nro_credito & " and nro_archivo <> " & nro_archivo)
                            nvFW.nvDBUtiles.DBExecute("update archivos set path = '" & carpeta & "\" & filename & "', nro_credito = " & nro_credito & ", descripcion = '" & archivo_descripcion & "',nro_def_detalle=" & nro_def_detalle & " where nro_archivo = " & nro_archivo)

                            'Incorporar parametros del CDA al archivo de Nosis
                            Dim strParteXML As String = "<?xml version=""1.0"" encoding=""ISO-8859-1""?>" & objXML.SelectSingleNode("Respuesta/ParteXML").OuterXml
                            Dim ParteXML As System.Xml.XmlDocument
                            ParteXML = New System.Xml.XmlDocument
                            ParteXML.LoadXml(strParteXML)

                            Dim XmlNodeList As System.Xml.XmlNodeList
                            Dim node As System.Xml.XmlNode

                            XmlNodeList = ParteXML.SelectNodes("/ParteXML/Dato/CalculoCDA")

                            Dim strSQL As String = ""

                            For Each node In XmlNodeList
                                Dim Titulo = node.Attributes.GetNamedItem("Titulo").Value
                                strSQL = "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'EMPRESA' , '" & Titulo & "', getdate(),dbo.rm_nro_operador()) "
                                Dim NroCDA = node.Attributes.GetNamedItem("NroCDA").Value
                                strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CDA' , '" & NroCDA & "', getdate(),dbo.rm_nro_operador()) "
                                Dim Version = node.Attributes.GetNamedItem("Version").Value
                                strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CDA_VERSION' , '" & Version & "', getdate(),dbo.rm_nro_operador()) "
                                Dim Fecha = node.Attributes.GetNamedItem("Fecha").Value
                                strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'FECHA' , '" & Fecha & "', getdate(),dbo.rm_nro_operador()) "
                                Dim Documento = node.SelectSingleNode("Documento").InnerText
                                strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CUIL' , '" & Documento & "', getdate(),dbo.rm_nro_operador()) "
                                Dim RazonSocial = node.SelectSingleNode("RazonSocial").InnerText
                                strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'RAZON_SOCIAL' , '" & RazonSocial & "', getdate(),dbo.rm_nro_operador()) "
                                Dim ItemList As System.Xml.XmlNodeList
                                Dim ItemNode As System.Xml.XmlNode
                                ItemList = node.SelectNodes("Item")
                                For Each ItemNode In ItemList
                                    Dim parametro = ItemNode.Attributes.GetNamedItem("Clave").Value
                                    Dim valor = ItemNode.SelectSingleNode("Valor").InnerText
                                    strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'" & parametro & "' , '" & valor & "', getdate(),dbo.rm_nro_operador()) "
                                Next
                                nvFW.nvDBUtiles.DBExecute(strSQL)
                            Next
                        End If

                    Catch ex As Exception

                    End Try

                End If

            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            err.response()

    End Select

    Me.contents.Add("operador", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='veroperadores'><campos>sucursal_cod_prov, nro_docu, sucursal_provincia, sucursal_postal_real</campos><orden></orden><filtro><operador type='igual'>" & nvApp.operador.operador & "</operador></filtro></select></criterio>"))
    Me.contents.Add("vendedor", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vervendedores'><campos>nro_vendedor, strNombreCompleto</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
    Me.contents.Add("trabajo", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBTrabajo_cuad_anexa_v3'><campos>dbo.rm_lote_first_grupo(nro_sistema,nro_lote) as nro_grupo,dbo.rm_lote_first_nombre_grupo(nro_sistema,nro_lote) as grupo, tipo,nro_sistema,sistema,nro_lote,lote,clave_sueldo,nro_docu,nombre,disponible,dbo.conv_fecha_to_str(fecha_actualizacion,'dd/mm') as fecha_actualizacion,id_origen</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
    Me.contents.Add("persona", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPersonas'><campos>Documento,sexo,nro_docu,tipo_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad,cod_prov</campos><orden></orden><filtro><cuit type='like'>%cuit%</cuit></filtro></select></criterio>"))
    Me.contents.Add("saldos", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_calc_credito_precarga' CommantTimeOut='1500' vista='verCreditos'><parametros><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><sexo>%sexo%</sexo></parametros></procedure></criterio>"))
    Me.contents.Add("creditos_cs", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_socio'  CommantTimeOut='1500' vista='verCreditos'><parametros><cuit>%cuit%</cuit></parametros></procedure></criterio>"))
    Me.contents.Add("creditos_cs_docu", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_socio'  CommantTimeOut='1500' vista='verCreditos'><parametros><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><sexo>%sexo%</sexo></parametros></procedure></criterio>"))
    'Me.contents.Add("operatorias", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_auxbanco_mutual_linea_grupo_analisis_v2'  CommantTimeOut='1500' vista='verCreditos'><parametros><cuit>%cuit%</cuit><nro_sistema DataType='int'>%nro_sistema%</nro_sistema><nro_lote DataType='int'>%nro_lote%</nro_lote><nro_grupo DataType='int'>%nro_grupo%</nro_grupo><sitbcra DataType='int'>%sit_bcra%</sitbcra><nro_banco DataType='int'>%nro_banco%</nro_banco><nro_mutual DataType='int'>%nro_mutual%</nro_mutual><salida>%salida%</salida></parametros></procedure></criterio>"))
    Me.contents.Add("operatoria_bancos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verAuxBanco_grupo_mutual_cobro_debito'><campos>nro_banco as id, banco as campo,  dbo.rm_banco_sitBCRA_orden(nro_banco, %sit_bcra%) as orden</campos><orden>orden</orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_tipo_cobro type='igual'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco_debito type='igual'>%nro_banco_cobro%</nro_banco_debito><aplica_precarga type='igual'>1</aplica_precarga></filtro><grupo>nro_banco, banco, dbo.rm_banco_sitBCRA_orden(nro_banco, %sit_bcra%)</grupo></select></criterio>"))
    Me.contents.Add("operatoria_mutuales", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verAuxBanco_grupo_mutual_cobro_debito'><campos>nro_mutual as id, mutual as campo</campos><orden></orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_tipo_cobro type='igual'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco_debito type='igual'>%nro_banco_cobro%</nro_banco_debito><nro_banco type='igual'>%nro_banco%</nro_banco><aplica_precarga type='igual'>1</aplica_precarga></filtro><grupo>nro_mutual,mutual</grupo></select></criterio>"))
    Me.contents.Add("sit_bcra", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='lausana_anexa..nosis_consulta'><campos>dbo.rm_sit_bcra_nosis_v2(id_consulta,0) as situacion</campos><orden></orden><filtro><id_consulta type='igual'>%id_consulta%</id_consulta></filtro></select></criterio>"))
    Me.contents.Add("persona_docu", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPersonas'><campos>Documento,sexo,nro_docu,tipo_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
    Me.contents.Add("grupos_lotes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verGrupos_lotes'><campos>top 1 nro_grupo</campos><orden></orden><filtro><nro_sistema type='igual'>%nro_sistema%</nro_sistema><nro_lote type='igual'>%nro_lote%</nro_lote><nro_grupo type='in'>401,501,127,1,402,502,125,2000,116,53,2,117,8,51,10,18</nro_grupo></filtro></select></criterio>"))
    Me.contents.Add("nosis_cda_def", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNosis_cda_def_v5'><campos>distinct nro_tipo_cobro, tipo_cobro, nro_banco, banco, abreviacion</campos><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("precarga_cda", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_cda_v12'  CommantTimeOut='1500'><parametros><nro_vendedor DataType='int'>%nro_vendedor%</nro_vendedor><nro_grupo DataType='int'>%nro_grupo%</nro_grupo><nro_tipo_cobro DataType='int'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco DataType='int'>%nro_banco%</nro_banco><cuil>%cuit%</cuil></parametros></procedure></criterio>"))
    Me.contents.Add("mutual_cuota", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='auxMutual_cuota'><campos>top 1 importe_cuota as importe_cuota_social</campos><filtro><nro_mutual type='igual'>%nro_mutual%</nro_mutual><aplica type='igual'>1</aplica><nro_grupo type='sql'>nro_grupo = case when nro_grupo = 0 then 0 else %nro_grupo% end</nro_grupo></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("planes_lotes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_lotes_v4' PageSize='5' AbsolutePage='1' cacheControl='Session'><campos>datediff(year, convert(datetime,'%fe_naci%',103), dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) as edad_fin, nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,nro_tipo_cobro,gastoscomerc,mes_vencimiento,case when %tiene_seguro%=1 then dbo.piz4D_money('monto_seguro',nro_banco,nro_mutual,nro_grupo,importe_bruto) else 0 end as monto_seguro</campos><orden>nro_plan desc</orden><filtro></filtro><grupo>nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,nro_tipo_cobro,gastoscomerc,mes_vencimiento,nro_banco,nro_mutual,nro_grupo</grupo></select></criterio>"))
    Me.contents.Add("planes_lotes2", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_lotes'><campos>top 1 nro_plan</campos><orden></orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_mutual type='igual'>%nro_mutual%</nro_mutual><nro_banco type='igual'>%nro_banco%</nro_banco><marca type='igual'>'S'</marca><falta type='menos'>getdate()</falta><fbaja type='sql'>(fbaja > getdate() or fbaja is null)</fbaja><vigente type='igual'>1</vigente><nro_tabla_tipo type='igual'>1</nro_tabla_tipo><importe_neto type='igual'>0</importe_neto><importe_cuota type='igual'>0</importe_cuota><cuotas type='igual'>0</cuotas></filtro></select></criterio>"))
    Me.contents.Add("planes_parametros", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_Parametros'><campos>*</campos><orden></orden><filtro><nro_plan type='igual'>%nro_plan%</nro_plan></filtro></select></criterio>"))
    Me.contents.Add("DBCuit", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBCuit_precarga'><campos>cuit,nombre,fe_naci_str,edad,sexo,nro_docu</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
    Me.contents.Add("DBCuit2", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBCuit_precarga'><campos>cuit,nombre,fe_naci_str,edad,sexo,nro_docu</campos><orden></orden><filtro><cuit type='igual'>'%cuit%'</cuit></filtro></select></criterio>"))
    Me.contents.Add("evaluar_persona", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Personas'><campos>dbo.rm_cr_mes(cuit,%nro_vendedor%) as cr_mes,dbo.rm_tiene_cs(cuit) as tiene_cs,dbo.rm_tiene_cr(cuit) as tiene_cr,nro_docu</campos><orden></orden><filtro><cuit type='igual'>'%cuit%'</cuit></filtro></select></criterio>"))
    'Me.contents.Add("BCRA_deudores", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verBCRA_deudores1'><campos>*,convert(varchar,fe_periodo,103) as fecha_periodo</campos><orden></orden><filtro><fe_periodo type='igual'>convert(datetime,'%fecha_periodo%',103)</fe_periodo><nro_identificacion type='igual'>'%nro_identificacion%'</nro_identificacion></filtro></select></criterio>"))
    Me.contents.Add("BCRA_deudores", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_BCRA_deudores'  CommantTimeOut='1500'><parametros><cuil>%cuil%</cuil><nro_grupo DataType='int'>%nro_grupo%</nro_grupo><nro_tipo_cobro DataType='int'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco DataType='int'>%nro_banco%</nro_banco></parametros></procedure></criterio>"))
    Me.contents.Add("tipos_rechazos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_grupo_tipos'><campos>nro_com_tipo, com_tipo</campos><orden></orden><filtro><nro_com_grupo type='igual'>17</nro_com_grupo><nro_permiso type='sql'>dbo.rm_tiene_permiso('permisos_com_tipo',nro_permiso) = 1</nro_permiso></filtro></select></criterio>"))
    Me.contents.Add("nosis_cp", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='provincia'><campos>top 1 dbo.rm_nosis_obtener_cp('%cuit%') as cp</campos><orden></orden><filtro></filtro></select></criterio>"))
    Me.contents.Add("provincia", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='provincia'><campos>cod_prov as id , provincia as campo</campos><orden></orden><filtro><nro_nacion type='igual'>1</nro_nacion><estaborrado type='igual'>0</estaborrado></filtro></select></criterio>"))
    Me.contents.Add("grupo_provincia", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='grupo_provincia'><campos>nro_grupo, cod_prov</campos><orden></orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><cod_prov type='igual'>%cod_prov%</cod_prov></filtro></select></criterio>"))
    Me.contents.Add("analisis_cargar", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verAux_Banco_Mutual_Grupo_Analisis_tabla_v1'><campos>distinct nro_analisis as id, analisis as campo, orden</campos><orden>orden</orden><filtro></filtro></select></criterio>"))
    Me.contents.Add("etiqueta_analisis", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEtiqueta_analisis'><campos>Orden,Nro_Etiqueta,etiqueta,Visible,Calculado,Color,Nro_Analisis,analisis,ultimo,HD,Comentario,css_style,tipo_dato,css_style_input,Calculo,editable,dbo.rm_an_calculobanco(nro_analisis, nro_etiqueta, orden, %nro_banco%) as CalculoBanco</campos><filtro><nro_analisis type='igual'>%nro_analisis%</nro_analisis></filtro><orden>orden</orden></select></criterio>"))
    Me.contents.Add("analisis_valor", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='analisis'><campos>%fun% as value</campos><filtro><nro_analisis type='igual'>%nro_analisis%</nro_analisis></filtro></select></criterio>"))
    Me.contents.Add("cuad_consumos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCUAD_consumos_terceros'><campos>clave,clave_sueldo,documento,cuotas,importe_cuota,saldo_consumo,nro_entidad,Razon_social</campos><orden></orden><filtro><documento type='igual'>%nro_docu%</documento><clave_sueldo type='like'>%clave_sueldo%</clave_sueldo></filtro></select></criterio>"))
    Me.contents.Add("planes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='planes'><campos>*</campos><filtro></filtro></select></criterio>"))
    Me.contents.Add("inaes_black_list", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='lausana_anexa..inaes_black_list'><campos>*</campos><filtro><CUIT type='igual'>%CUIT%</CUIT></filtro></select></criterio>"))

    Me.contents.Add("postergaciones_originante", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos_postergaciones'><campos>distinct nro_credito,estado,importe_cuota,credito_origen</campos><filtro><credito_origen type='igual'>%credito_origen%</credito_origen></filtro></select></criterio>"))
    Me.contents.Add("postergaciones", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos_postergaciones'><campos>distinct nro_credito,estado,importe_cuota,credito_origen</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))
    Me.contents.Add("credito_originante", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>distinct  nro_credito,estado,importe_cuota</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))

    'Campos defs
    'Me.contents.Add("grupos_cda", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verGrupos_cda'><campos>nro_grupo as id,grupo as campo</campos><orden></orden><filtro></filtro></select></criterio>"))
    Me.contents.Add("grupos_cda", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNosis_cda_def_v5'><campos>distinct nro_grupo as id, grupo as campo</campos><orden></orden><filtro></filtro></select></criterio>"))

    '"<criterio><select vista='verGrupos_cda'><campos>nro_grupo as id,grupo as campo</campos><orden></orden><filtro></filtro></select></criterio>"

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim opParams As New trsParam
    opParams("vendedor_provincia") = ""
    opParams("cod_prov_op") = ""
    opParams("sucursal_postal_real") = ""
    opParams("nro_docu") = 0
    opParams("strVendedor") = ""
    opParams("nro_estructura") = ""
    opParams("nro_vendedor") = ""

    Try
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from veroperadores where operador = " & nvApp.operador.operador)
        opParams("vendedor_provincia") = rs.Fields("sucursal_provincia").Value
        opParams("cod_prov_op") = rs.Fields("sucursal_cod_prov").Value
        opParams("sucursal_postal_real") = rs.Fields("sucursal_postal_real").Value
        opParams("nro_docu") = rs.Fields("nro_docu").Value '4292472
        nvDBUtiles.DBCloseRecordset(rs)
    Catch ex As Exception

    End Try
    If opParams("nro_docu") <> 0 Then
        Try
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from vervendedores where nro_docu = " & opParams("nro_docu"))
            opParams("strVendedor") = rs.Fields("strNombreCompleto").Value
            opParams("nro_vendedor") = rs.Fields("nro_vendedor").Value
            opParams("nro_estructura") = rs.Fields("nro_estructura").Value
            nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception

        End Try
    End If

    Me.contents("operador") = nvApp.operador.operador
    Me.contents("permisos_precarga") = op.permisos("permisos_precarga")
    Me.contents("permisos_web2") = op.permisos("permisos_web2")
    Me.contents("operador_vendedor") = opParams
    Me.addPermisoGrupo("permisos_precarga")

    Dim filtro_cuenta As Boolean
    Dim filtro_bcra As Boolean
    filtro_cuenta = op.tienePermiso("permisos_precarga", 64)
    filtro_bcra = op.tienePermiso("permisos_precarga", 128)

    Me.contents.Add("codigoyacare", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_generar_codigo_yacare' CommantTimeOut='1500' vista='verCreditos'><parametros><nro_vendedor DataType='int'>%nro_vendedor%</nro_vendedor></parametros></procedure></criterio>"))
    Dim estructura_genera_codigo As String = "11,12"
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1 " lang="es" >
    <meta name="viewport" content="width=device-width, user-scalable=no" lang="es" >
    <meta name="mobile-web-app-capable" content="yes"lang="es"  >
    <meta http-equiv="Content-Language" content="es"/>
    <link href="/precarga/image/icons/nv_mutual.png"  sizes="193x193" rel="shortcut icon" />
    <title>NOVA Precarga</title>
    <meta name="google" content="notranslate" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
<%--    <link rel="shortcut icon" sizes="196x196" href="FW/image/icons/nv_login.ico" />--%>
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="script/precarga.js"></script>
    <script type="text/javascript" src="script/analisis.js?v=100"></script>
    <script type="text/javascript" src="/fw/script/utiles.js"></script>
      <link rel="manifest" href="/precarga/manifest.json">
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var estructura_genera_codigo=Array(<%=estructura_genera_codigo%>)
        var win

        var CUIT_source = 'DB'
        var crPostergaciones=Array() //guarda los creditos que se relacionan entre si por postergaciones 
        var menuRight = false;

        var vButtonItems = {}
        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "PBuscar";
        vButtonItems[0]["etiqueta"] = " Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return Persona_Trabajos_cargar()";
        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "PlanBuscar";
        vButtonItems[1]["etiqueta"] = "";
        vButtonItems[1]["imagen"] = "buscar";
        vButtonItems[1]["onclick"] = "return Validar_datos()";
        /*vButtonItems[2] = {}
        vButtonItems[2]["nombre"] = "VerCreditos";
        vButtonItems[2]["etiqueta"] = "Ver Creditos";
        vButtonItems[2]["imagen"] = "credito";
        vButtonItems[2]["onclick"] = "return VerCreditos('V')";*/
        vButtonItems[2] = {}
        vButtonItems[2]["nombre"] = "PLimpiar";
        vButtonItems[2]["etiqueta"] = "Limpiar";
        vButtonItems[2]["imagen"] = "limpiar";
        vButtonItems[2]["onclick"] = "return Precarga_Limpiar()";
      /*  vButtonItems[3] = {}
        vButtonItems[3]["nombre"] = "BuscarVendedor";
        vButtonItems[3]["etiqueta"] = "Vendedor";
        vButtonItems[3]["imagen"] = "buscar";
        vButtonItems[3]["onclick"] = "return selVendedor_onclick()";*/
        vButtonItems[4] = {}
        vButtonItems[4]["nombre"] = "Nosis";
        vButtonItems[4]["etiqueta"] = "";
        vButtonItems[4]["imagen"] = "ver";
        vButtonItems[4]["onclick"] = "return VerInformeNosis()";
        vButtonItems[5] = {}
        vButtonItems[5]["nombre"] = "Noti";
        vButtonItems[5]["etiqueta"] = "Notificar";
        vButtonItems[5]["imagen"] = "noti";
        vButtonItems[5]["onclick"] = "return NotiEnviar()";
        vButtonItems[6] = {}
        vButtonItems[6]["nombre"] = "NotiR";
        vButtonItems[6]["etiqueta"] = "Notificar";
        vButtonItems[6]["imagen"] = "noti";
        vButtonItems[6]["onclick"] = "return tipo_rechazo()";
       
        
        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
        vListButtons.loadImage("buscar", "image/search_16.png");
        vListButtons.loadImage("volver", "image/a_left_2.png");
        vListButtons.loadImage("credito", "image/us_dollar_16.png");
        vListButtons.loadImage("nuevo", "image/text_document_24.png");
        vListButtons.loadImage("guardar", "image/guardar.png");
        vListButtons.loadImage("ver", "image/preview_16.png");
        vListButtons.loadImage("noti", "image/send-16.png");
        vListButtons.loadImage("pdf", "../FW/image/filetype/pdf.png");
        vListButtons.loadImage("abrir_chat", "../FW/image/icons/comentario3.png");
        vListButtons.loadImage("limpiar", "../FW/image/icons/eliminar.png");
        vListButtons.loadImage("cuenta", "../FW/image/icons/cuenta.png");

        var vendedor = ''
        var WinTipo = ''
        var origen = 'precarga'
        var tiene_seguro = 0

        var win_descargas
        function Descargar_formularios() {
            win_descargas = createWindow2({
                url: 'formulario_descarga.aspx?codesrvsw=true',
                title: '<b>Descargar Solicitudes</b>',
                maxHeight: 350,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true
            });
            win_descargas.options.userData = { res: '' }
            win_descargas.showCenter(true)
            
            if (isMobile())
            mostrarMenuIzquierdo()
        }

        var bloquearSlideVertical = 0;

        function blockVerticalSlide(sum) {

            bloquearSlideVertical = bloquearSlideVertical + sum

            if (bloquearSlideVertical < 1) {
                $$("body")[0].style.position = "absolute"
                $$("body")[0].style.overflowY = "auto"
            }
            else {
                $$("body")[0].style.position = "fixed"
                $$("body")[0].style.overflowY = "hidden"
            }
        }

        function window_onload() {


            //No guarda el scrolling en el historial
            history.scrollRestoration = 'manual'
            ismobile = (isMobile()) ? true : false

            //Anulo el cartel default de nova cuando abandono la aplicacion
            nvFW.alertUnload = false
            vListButtons.MostrarListButton()
            ObtenerSucursalOperador()
            document.getElementById('nro_docu1').focus()

            if ((permisos_precarga & 4) <= 0) {
                $('divNoti').hide()
                $('divNotiR').hide()
                $('tbResultado').hide()
            }
            if ((permisos_precarga & 64) == 0)
                $('chkFiltroCuenta').style.visibility = 'hidden';

            if ((permisos_precarga & 128) == 0)
                $('chkFiltroBCRA').style.visibility = 'hidden';

            Precarga_Limpiar()

            //Esta funcion determina los tamaños de los componentes, menu sup, inf, body, etc
            tamanio = nvtWinDefault()

            //muestra menu dependiendo si debe ser menu movil o no
            vMenuLeft.MostrarMenu(tamanio.ocultarMenu)
            
             //para operadores de mendoza o que no tengan estructura            
             mostrar_boton_generarcodigo(nro_estructura==11)


            //funciones de scrolling para mostrar o ocultar el menu.
            detectSwipe($$("BODY")[0], "mostrar", 50);
            //detectSwipe($("divComponentes"), mostrarMenuIzquierdoSwipe, 50, "izq");
            detectSwipe($("menu_left_vidrio"), "colapsar");
            detectSwipe($("menu_left_mobile"), "colapsar");
            detectSwipe($("menu_right_vidrio"), "colapsar");
            //detectSwipe($(vMenuRight.canvasMobile), "colapsar");

            window_onresize()
            //ocultar el vidrio porque el menu no se muestra desde el inicio
            $("menu_left_vidrio").style.right = "-540px";
            //Para mostrar el body cuando termine el onload
            $$("body")[0].style.visibility = "visible"

            campos_defs.items['banco']['onchange'] = banco_onchange
            campos_defs.items['mutual']['onchange'] = mutual_onchange
        }



        var vMenuRight = new tMenu('menu_right', 'vMenuRight');
        var DocumentMNG = new tDMOffLine;
        function cargarMenuRight() {
            // cargar menu
            vMenuRight.alineacion = 'izquierda';
            vMenuRight.estilo = 'O'
            vMenuRight.loadImage("inicio", "/fw/image/icons/home.png")
            vMenuRight.loadImage("upload", "/fw/image/icons/play.png")
            vMenuRight.loadImage("ref", "/fw/image/icons/info.png")
            vMenuRight.loadImage("nueva", "/fw/image/icons/nueva.png")
            vMenuRight.loadImage("servicio_asignar", "/fw/image/icons/play.png")
            vMenuRight.loadImage("buscar", "/fw/image/icons/buscar.png")
            vMenuRight.loadImage("vincular", "/fw/image/security/vincular.png")
            vMenuRight.loadImage("herramientas", "/fw/image/icons/herramientas.png")
            vMenuRight.loadImage("operador", "/fw/image/icons/operador.png")
            vMenuRight.loadImage("permiso", "/fw/image/icons/permiso.png")
            vMenuRight.loadImage("imprimir", "/fw/image/icons/imprimir.png")

            vMenuRight.loadImage("parametros", "/fw/image/icons/imprimir.png")
            vMenuRight.loadImage("play", "/fw/image/icons/imprimir.png")

            //Importante: Nombre de la ventana que contendrá los documentos 

            DocumentMNG.APP_PATH = window.location.href;
            var strXML = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', 'ref_mnu_cabecera')
            vMenuRight.CargarXML(strXML);

            // vMenuRight.MostrarMenu(tamanio.ocultarMenu);//DESATIVADO POR AHORA TODO , PARA VERSION PROD
        }

        function UbicacionObtener() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(Ubicacion, UbicacionErrores);
            } else {
                nvFW.alert('No disponible')
            }
        }

        var geoloc_lat = 0
        var geoloc_long = 0
        var geoloc_domicilio = ''
        var geoloc_localidad = ''
        var geoloc_provincia = ''
        var geoloc_pais = ''
        var ismobile = false

        function Ubicacion(position) {
            geoloc_lat = position.coords.latitude
            geoloc_long = position.coords.longitude
            UbicacionDescripcion()
        }

        var win_ubicacion
        var btn_aceptar_u = false

        function UbicacionErrores(error) {
            var desc_error = ""
            switch (error.code) {
                case error.PERMISSION_DENIED:
                    desc_error = "Permiso denegado para acceder a la ubicación."
                    break;
                case error.POSITION_UNAVAILABLE:
                    desc_error = "La información de la ubicación no se encuentra disponible."
                    break;
                case error.TIMEOUT:
                    desc_error = "Tiempo de respuesta agotado para obtener la ubicación."
                    break;
                case error.UNKNOWN_ERROR:
                    desc_error = "Error Desconocido."
                    break;
            }
            if (desc_error != "") {
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                win_ubicacion = createWindow2({
                    title: '<b>Ubicación Geográfica</b>',
                    parentWidthPercent: 0.8,
                    //parentWidthElement: $("contenedor"),
                    maxWidth: 450,
                    //centerHFromElement: $("contenedor"),
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: true,
                    closable: false,
                    recenterAuto: true,
                    setHeightToContent: true,
                    onClose: function () {
                        if (btn_aceptar_u) {
                            ObtenerSucursalOperador()
                            document.getElementById('nro_docu1').focus()
                        }
                        else
                            UbicacionObtener()
                    }
                });
                var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
                html += '<table class="tb1">'
                html += '<tbody><tr><td colspan="2"><b>La aplicación no pudo obtener la ubicación geográfica.</b><br><br>Acepte el mensaje de seguridad del browser o configure manualmente el acceso a la ubicación.</td></tr>'
                html += '<tr><td style="text-align:center;width:40%"><br><input type="button" style="width:99%" value="Reintentar" onclick="win_ubicacion_cerrar(false)" style="cursor: pointer !important" /></td><td style="text-align:center;width:60%"><br><input type="button" style="width:99%" value="Continuar sin ubicación" onclick="win_ubicacion_cerrar(true)" style="cursor: pointer !important" /></td></tr>'
                html += '</tbody></table></body></html>'

                win_ubicacion.setHTMLContent(html)
                win_ubicacion.showCenter(true)
            }
        }

        function win_ubicacion_cerrar(aceptar) {
            btn_aceptar_u = aceptar
            win_ubicacion.close()
        }

        function UbicacionDescripcion() {
            var request = new XMLHttpRequest();

            var method = 'GET';
            var url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + geoloc_lat + ',' + geoloc_long + '&sensor=true';
            var async = true;

            request.open(method, url, async);
            request.onreadystatechange = function () {
                if (request.readyState == 4 && request.status == 200) {
                    var data = JSON.parse(request.responseText);
                    try {
                        geoloc_domicilio = data.results[0].formatted_address
                        geoloc_localidad = data.results[0].address_components[2]['long_name']
                        geoloc_provincia = data.results[0].address_components[4]['long_name']
                        geoloc_pais = data.results[0].address_components[5]['long_name']
                    }
                    catch (e) {
                    }
                    ObtenerSucursalOperador()
                    document.getElementById('nro_docu1').focus()
                }
            };
            request.send();
        };

        var cupo_disponible = 0
        var nro_sistema = 0
        var sistema = ''
        var nro_lote = 0
        var lote = ''
        var clave_sueldo = ''
        var nro_grupo = 0

        /* Variables persona */
        var fe_naci = ''
        var sexo = ''
        var tipo_docu = 0
        var nro_docu = 0
        var cuit = ''
        var razon_social = ''
        var domicilio = ''
        var localidad = ''
        var CP = 0
        var provincia = ''
        var cod_prov_persona = 0
        var nro_archivo_nosis = 0
        var nro_docu_db = 0

        var TotalCancelaciones1 = 0
        var LiberaCuota = 0
        var cancelaciones = 0
        var importe_max_cuota = 0

        var nro_analisis = undefined
        var nro_analisis_actual = -1
        

        function Precarga_Limpiar(nro_credito) {
            $("consultarRobot").value="0"
            Trabajos = {}
            Creditos = {}
            Etiquetas = {}
            Cancelaciones = {}
            $('strApeyNomb').innerHTML = ''
            $('strCUIT').innerHTML = ''
            $('strFNac').innerHTML = ''
            $('divMostrarTrabajos').innerHTML = ''
            $('strSitBCRA').innerHTML = ''
            $('strDictamen').innerHTML = ''
            $('strFuentes').innerHTML = ''
            $('strInfoCuit').innerHTML = ''
            $('divNotiR').hide()
             $('tbResultado').hide()
            $('nro_docu1').value = ''
            $('nro_docu').value = ''

            $('strEnMano').innerHTML = ''

            $('tbButtons').hide()

            $('retirado_desde').value = ''
            $('retirado_hasta').value = ''
            $('importe_cuota_desde').value = ''
            $('importe_cuota_hasta').value = ''
            $('cuota_desde').value = ''
            $('cuota_hasta').value = ''

            $('divHaberes').innerHTML = ''
            $('divHaberesNoVisibles').innerHTML = ''
            $('saldo_a_cancelar').innerHTML = ''
            $('haber_neto').innerHTML = ''
            $('importe_max_cuota').innerHTML = ''
            $('divHaberes').innerHTML = ""
            $('divHaberesNoVisibles').innerHTML = ""

            $('divVendedor').show()
            $('divDatosPersonales').hide()
            $('divSelTrabajo').show()
            $('divGrupo').hide()
            $('divSocio').hide()
            $('divFiltros').hide()
            $('divFiltrosLeft').hide()
            $('divFiltrosRight').hide()
            $('divFiltros2Left').hide()
            $('divFiltros2Right').hide()
            $('divFiltros3Left').hide()
            $('divFiltros3Right').hide()
            $('divProducto').hide()
            $('divMostrarTrabajos').hide()
            $('divAnalisis').hide()
            campos_defs.clear("cbAnalisis") //$('cbAnalisis').options.length = 0
            $('td_canc_int').hide()
            $('td_canc_3').hide()

            cupo_disponible = 0
            nro_sistema = 0
            sistema = ''
            nro_lote = 0
            lote = ''
            clave_sueldo = ''
            nro_grupo = 0
            prueba = ''
            NroConsulta = 0
            razon_social = ''
            nombre = ''
            domicilio = ''
            localidad = ''
            CP = ''
            provincia = ''
            cod_prov_persona = 0
            edad = ''
            sexo = ''
            fe_naci = ''
            fe_naci_str = ''
            tipo_docu = 0
            nro_docu = 0
            nro_docu_db = 0
            cuit = ''
            NosisXML = ''
            nro_archivo_nosis = 0
            sit_bcra = 99
            HTMLCDA = ''
            TotalCancelaciones1 = 0
            LiberaCuota = 0
            cancelaciones = 0
            importe_max_cuota = 0
            importe_neto = 0
            gastoscomerc = 0
            strHTMLNosis = ''
            persona_existe = true
            fe_naci_socio = ''
            nro_plan_sel = 0
            plan_lineas = ''
            nro_tipo_cobro = 0
            nro_banco_cobro = 0
            nro_analisis = 0
            btn_cobro_aceptar = false
            $('selplan').checked = false
            $('chkmax_disp').checked = false
            $('ifrplanes').src = 'enBlanco.htm'
            document.getElementById('nro_docu1').focus()
            strHTML_CDA = ''
            hpx = 0
            tipo_rechazo_call = ''
            nro_credito_random = 0
            nro_archivo_noti_prov = 0
            noti_prov = false
            tiene_cupo = false
            importe_cs_analisis = 0
            Btn_cancelaciones_onclick()
            btnStatus(false)
            if (nro_credito) {
                var filtros = {}
                filtros['nro_credito'] = nro_credito
                win_estado = createWindow2({
                    url: 'Credito_cambiar_estado.aspx?codesrvsw=true',
                    title: '<b>Crédito: ' + nro_credito + ' </b>',
                    //centerHFromElement: $("contenedor"),
                    //parentWidthElement: $("contenedor"),
                    //parentWidthPercent: 0.9,
                    //parentHeightElement: $("contenedor"),
                    //parentHeightPercent: 0.9,
                    maxHeight: 500,
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    resizable: true
                });
                win_estado.options.userData = { filtros: filtros }
                win_estado.showCenter(true)

            }
        }

        var BodyWidth = 0
        var widthWin = 0
        var heightWin = 0
        var leftWin = 0
        var topWin = 0

        var win_vendedor
        var permisos_precarga = nvFW.pageContents["permisos_precarga"]
        var permisos_web2 = nvFW.pageContents["permisos_web2"]
        function selVendedor_onclick() {
            if ((permisos_precarga & 1) <= 0) {
                nvFW.alert('No posee permisos para seleccionar el vendedor')
                return
            }
            win_vendedor = createWindow2({
                url: 'selVendedor.aspx',
                title: '<b>Seleccionar Vendedor</b>',
                //centerHFromElement: $("contenedor"),
                //parentWidthElement: $("contenedor"),
                //parentWidthPercent: 0.9,
                //parentHeightElement: $("contenedor"),
                //parentHeightPercent: 0.9,
                maxHeight: 500,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                onClose: selVendedor_return
            });
            win_vendedor.options.userData = { res: '' }
            win_vendedor.showCenter(true)
           // mostrarMenuIzquierdoSwipe()
        
         if (isMobile())
            mostrarMenuIzquierdo()

        }

        var nro_vendedor = 0
        var strVendedor = ''
        var nro_estructura=0
        function selVendedor_return() {
            var retorno = win_vendedor.options.userData.res
            if (retorno) {            
                $('strVendedor').innerText = retorno["vendedor"]
                strVendedor = retorno["vendedor"]
                nro_vendedor = retorno['nro_vendedor']
                $("nro_vendedor").value=nro_vendedor
                nro_estructura = (retorno['nro_estructura']==null)?0:retorno['nro_estructura']                
                mostrar_boton_generarcodigo(estructura_genera_codigo.indexOf(+nro_estructura)>=0)
                cod_prov_op = retorno['cod_prov']
                sucursal_postal_real = retorno['postal_real']
                //mostrar_boton_generarcodigo(nro_estructura==11 || nro_estructura==0)
                //mostrar_boton_generarcodigo(nro_estructura==11)
                Precarga_Limpiar()

            
            }
        }

        var win_estado

        function MostrarCredito(nro_credito) {
            var filtros = {}
            filtros['nro_credito'] = nro_credito
            win_estado = createWindow2({
                url: 'Credito_cambiar_estado.aspx?codesrvsw=true',
                title: '<b>Crédito: ' + nro_credito + ' </b>',
                //centerHFromElement: $("contenedor"),
                //parentWidthElement: $("contenedor"),
                //parentWidthPercent: 0.9,
                //parentHeightElement: $("contenedor"),
                //parentHeightPercent: 0.9,
                maxHeight: 500,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true
            });
            win_estado.options.userData = { filtros: filtros }
            win_estado.showCenter(true)
        }

        var cod_prov_op
        var sucursal_postal_real

        function ObtenerSucursalOperador() {

            cod_prov_op = nvFW.pageContents["operador_vendedor"].cod_prov_op
            sucursal_postal_real = nvFW.pageContents["operador_vendedor"].sucursal_postal_real
            nro_docu = nvFW.pageContents["operador_vendedor"].nro_docu
            $('strVendedor').innerText = nvFW.pageContents["operador_vendedor"].strVendedor
            strVendedor = nvFW.pageContents["operador_vendedor"].strVendedor
            nro_vendedor = nvFW.pageContents["operador_vendedor"].nro_vendedor
            nro_estructura   = nvFW.pageContents["operador_vendedor"].nro_estructura

            $("nro_vendedor").value=nro_vendedor
            if ($('nro_credito').value != 0)
                MostrarCredito($('nro_credito').value)
            else if (nro_vendedor == '')
                selVendedor_onclick()


           

        }

        function mostrar_boton_generarcodigo(bandera){
            
            //oculto para cuando la estructura no es de mendoza
            if(bandera){
                    if($("menuItem_menu_left_mobile_6")!=null){
                       $("menuItem_menu_left_mobile_6").show() 
                   }
            }else{
                if($("menuItem_menu_left_mobile_6")!=null){
                       $("menuItem_menu_left_mobile_6").hide() 
                }
            }
        }


        function btnBuscar_trabajo_onclick(e) {
            var key = Prototype.Browser.IE ? e.keyCode : e.which
            if ((key == 13) || (key == 9)) {
                Persona_Trabajos_cargar()
                return false
            }
        }

        function rserror_handler(msg) {
            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            nvFW.alert(msg, { onClose: function () { Precarga_Limpiar() } })
        }

      
        function rddoc_onclick() {
            document.getElementById('nro_docu1').focus()
        }

        function Persona_Trabajos_cargar() {
            var tipo = $$('input:checked[type="radio"][name="rddoc"]').pluck('value')[0]
            var control = (tipo == 'dni') ? 8 : 11
            var strAlert = ''
            if ($('nro_docu1').value == '')
                strAlert = 'Ingrese un número de documento para realizar la busqueda.<br>'
            if ($('nro_docu1').value.length > control)
                strAlert = 'La cantidad de digitos ingresados es incorrecta.<br>'
            if ((tipo == 'cuit') && ($('nro_docu1').value.length != 11))
                strAlert += 'El CUIT/CUIL debe tener 11 dígitos.<br>'
            if (nro_vendedor == 0)
                strAlert += 'Seleccione un vendedor para realizar la búsqueda.<br>'

            if (strAlert != '') {
                nvFW.alert(strAlert, {width:"300"})
                document.getElementById('nro_docu1').focus()
                return
            }


            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Evaluando identidad...')
            var onSusses = function (cuit, nro_docu) {

                var rs = new tRS();
                Trabajos = {}
                var i = 0
                var cod_prov = cod_prov_op
                rs.async = true
                rs.onError = function (rs) {
                    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                }
                rs.onComplete = function (rs) {
                    var i = 0
                    while (!rs.eof()) {
                        if (rs.getdata('nro_grupo') != 0) {
                            i++
                            Trabajos[i] = {}
                            Trabajos[i]['tipo'] = rs.getdata('tipo')
                            Trabajos[i]['sistema'] = rs.getdata('sistema')
                            Trabajos[i]['nro_sistema'] = rs.getdata('nro_sistema')
                            Trabajos[i]['lote'] = rs.getdata('lote')
                            Trabajos[i]['nro_lote'] = rs.getdata('nro_lote')
                            Trabajos[i]['clave_sueldo'] = rs.getdata('clave_sueldo')
                            Trabajos[i]['nro_docu'] = rs.getdata('nro_docu')
                            Trabajos[i]['nombre'] = rs.getdata('nombre')
                            Trabajos[i]['disponible'] = ((rs.getdata('id_origen') == 11210) || (rs.getdata('id_origen') == 651) || (rs.getdata('id_origen') == 11100)) ? -1 : rs.getdata('disponible')
                            Trabajos[i]['fecha_actualizacion'] = rs.getdata('fecha_actualizacion')
                            Trabajos[i]['nro_grupo'] = rs.getdata('nro_grupo')
                            Trabajos[i]['grupo'] = rs.getdata('grupo')
                        }
                        rs.movenext()
                    }
                    if (i > 0) {
                        i++
                        Trabajos[i] = {}
                        Trabajos[i]['tipo'] = ''
                        Trabajos[i]['sistema'] = ''
                        Trabajos[i]['nro_sistema'] = 99999
                        Trabajos[i]['lote'] = ''
                        Trabajos[i]['nro_lote'] = 0
                        Trabajos[i]['clave_sueldo'] = ''
                        Trabajos[i]['nro_docu'] = nro_docu
                        Trabajos[i]['nombre'] = 'Seleccionar otro mercado...'
                        Trabajos[i]['disponible'] = -1
                        Trabajos[i]['fecha_actualizacion'] = ''
                        Trabajos[i]['nro_grupo'] = 0
                        Trabajos[i]['grupo'] = ''
                    }
                    $('strInfoCuit').innerHTML = ''
                    $('strInfoCuit').insert({ bottom: " " + nombre.trim() })
                    $('tdResultado').innerHTML = "Resultado: " + cuit//({ bottom: ": " + cuit })
                    if ((permisos_precarga & 4) > 0)
                        $('divNotiR').show()
                        $('tbResultado').show()
                    if (i == 0) {
                        $('divMostrarTrabajos').innerHTML = ''
                        var strHTML = ""
                        strHTML += "<table class='tb1' cellspacing='5' cellpadding='1'>"
                        strHTML += "<tr><td class='Tit1' colspan='2' style='text-align:center'><b>Seleccione el mercado para continuar.<b></td></tr>"
                        strHTML += "<tr><td style='width:100%'>"
                        strHTML += "<table class='tb1' style='max-width:450px; margin:auto'><tr><td id='tdgrupos'></td><td id='divGAceptar'></td></tr></table>"
                        strHTML += "</td>"
                        strHTML += "</tr></table>"
                        $('divMostrarTrabajos').insert({ bottom: strHTML })
                        $('divMostrarTrabajos').show()
                        var vButtonItems = {}
                        vButtonItems[0] = {}
                        vButtonItems[0]["nombre"] = "GAceptar";
                        vButtonItems[0]["etiqueta"] = "Aceptar";
                        vButtonItems[0]["imagen"] = "aceptar";
                        vButtonItems[0]["onclick"] = "Ingresa_grupo()";
                        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
                        vListButtons.loadImage("aceptar", "image/search_16.png");

                        vListButtons.MostrarListButton()
                        campos_defs.add("grupos", { nro_campo_tipo: 1, target: "tdgrupos", enDB: false, cacheControl: 'Session', filtroXML: nvFW.pageContents["grupos_cda"] })
                        //JMO
                        campos_defs.items["grupos"].onchange = function () { campos_defs.items["grupos"].input_text.focus() }
                        $(campos_defs.items["grupos"].input_text).observe('keypress', function (e) {
                            var tecla = !e.keyCode ? e.which : e.keyCode
                            if (tecla = 13)
                                Ingresa_grupo()
                        })

                        campos_defs.items["grupos"].input_text.ondblclick()
                        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                        return
                    }
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    Persona_Trabajos_dibujar()

                }
                rs.open({ filtroXML: nvFW.pageContents["trabajo"], params: "<criterio><params nro_docu='" + nro_docu + "' /></criterio>" })
            }

            var onError = function () { nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga') }

            CUIT_obtener($('nro_docu1').value, tipo, onSusses, onError)
        }



        function Persona_Trabajos_dibujar() {
            $('divMostrarTrabajos').innerHTML = ''
            $('divMostrarTrabajos').show()
            var strHTML = ""
            strHTML += "<table class='tb1 highlightEven highlightTROver' cellspacing='1' cellpadding='1'>"
            strHTML += "<tr><td class='Tit1' style='width:5px'></td><td class='Tit1' style='width:40%'>Nombre</td><td class='Tit1' style='width:30%'>Trabajo</td><td class='Tit1' style='width:30%'>Clave</td></tr>"
            for (var x in Trabajos) {
                if (Trabajos[x]['nro_sistema'] == 99999)
                    strHTML += "<tr style='text-align:center' onclick='return Mostrar_grupos()'><td style='text-align:center' title='Seleccionar trabajo'><img class='img_button_sel' src='image/seleccionar_32.png'/></td><td>" + Trabajos[x]['nombre'] + "</td><td>" + Trabajos[x]['sistema'] + "</td><td>" + Trabajos[x]['clave_sueldo'] + "</td></tr>"
                else
                    strHTML += "<tr style='text-align:center' onclick='return Log_registro(" + x + ")'><td style='text-align:center' title='Seleccionar trabajo'><img class='img_button_sel' src='image/seleccionar_32.png'/></td><td>" + Trabajos[x]['nombre'] + "</td><td>" + Trabajos[x]['sistema'] + " - " + Trabajos[x]['lote'] + "</td><td>" + Trabajos[x]['clave_sueldo'] + "</td></tr>"

            }
            strHTML += "</table>"
            $('divMostrarTrabajos').insert({ bottom: strHTML })
        }

        function Mostrar_grupos() {
            $('divMostrarTrabajos').innerHTML = ''
            var strHTML = ""
            strHTML += "<table class='tb1' cellspacing='1' cellpadding='1'>"
            strHTML += "<tr><td class='Tit1' colspan='2' style='text-align:center'><b>Seleccione el mercado para continuar.<b></td></tr>"
            strHTML += "<tr><td style='width:100%'>"
            strHTML += "<table class='tb1' style='max-width:450px; margin:auto'><tr><td id='tdgrupos'></td><td id='divGAceptar'></td></tr></table>"
            strHTML += "</td>"
            strHTML += "</tr></table>"
            $('divMostrarTrabajos').insert({ bottom: strHTML })
            $('divMostrarTrabajos').show()
            var vButtonItems = {}
            vButtonItems[0] = {}
            vButtonItems[0]["nombre"] = "GAceptar";
            vButtonItems[0]["etiqueta"] = "Aceptar";
            vButtonItems[0]["imagen"] = "aceptar";
            vButtonItems[0]["onclick"] = "Ingresa_grupo()";
            var vListButtons = new tListButton(vButtonItems, 'vListButtons');
            vListButtons.loadImage("aceptar", "image/search_16.png");
            vListButtons.MostrarListButton()
            campos_defs.add("grupos", { nro_campo_tipo: 1, target: "tdgrupos", enDB: false, cacheControl: 'Session', filtroXML: nvFW.pageContents["grupos_cda"] })

            //JMO
            campos_defs.items["grupos"].onchange = function () { campos_defs.items["grupos"].input_text.focus() }
            $(campos_defs.items["grupos"].input_text).observe('keypress', function (e) {
                var tecla = !e.keyCode ? e.which : e.keyCode
                if (tecla = 13)
                    Ingresa_grupo()
            })

            campos_defs.items["grupos"].input_text.ondblclick()
        }

        var CDA = 0
        var nro_banco = 31

        var win_sel_cuit
        var win_sel_dbcuit
        var login = '<%= login %>'
        var ip_usr = '<%= ip_usr %>'
        var ip_srv = '<%= ip_srv %>'

        function Ingresa_grupo() {
            if ($('grupos').value == '')
                nvFW.alert('Debe seleccionar un grupo para continuar')
            else {
                nro_grupo = $('grupos').value
                Trabajos[1] = {}
                Trabajos[1]['tipo'] = ''
                Trabajos[1]['sistema'] = ''
                Trabajos[1]['nro_sistema'] = 0
                Trabajos[1]['lote'] = ''
                Trabajos[1]['nro_lote'] = 0
                Trabajos[1]['clave_sueldo'] = ''
                Trabajos[1]['nro_docu'] = $('nro_docu1').value
                Trabajos[1]['nombre'] = ''
                Trabajos[1]['disponible'] = -1
                Trabajos[1]['fecha_actualizacion'] = ''
                Trabajos[1]['nro_grupo'] = $('grupos').value
                Trabajos[1]['grupo'] = campos_defs.get_desc("grupos").substring(0, campos_defs.get_desc("grupos").indexOf('('))

                Log_registro(1, true)

            }
        }

        var nro_tipo_cobro = 0
        var win_cobro
        var btn_cobro_aceptar = false
        var tiene_cupo = false
        var grupo = ''
        var tipo_cobro = ''
        var tipo_rechazo_call = ''
        var observaciones_call = ''


        function win_tipo_rechazo(aceptar) {
            dictamen = 'RECHAZADO'
            tipo_rechazo_call = $('cbtr').value
            observaciones_call = $('txt_observaciones').value
            btn_tr_aceptar = aceptar
            win_tr.close()
        }

        function Generar_codigo(){
            if(nro_vendedor==0 || nro_vendedor==''){
                alert("debe seleccionar vendedor")
                return
            }
         var rstr = new tRS()
            rstr.open({ filtroXML: nvFW.pageContents["codigoyacare"], params: "<criterio><params nro_docu='" +  $('nro_docu').value  + "' sexo='" + sexo + "' tipo_docu='" + tipo_docu + "' cuit='" + cuit + "' nro_vendedor='" + nro_vendedor + "'  /></criterio>" })
            
            if(!rstr.eof()) {
                var codigo=rstr.getdata('codigo')
                var param = {}
            param['codigo'] = codigo
            param['strNombreCompleto'] = nombre.trim()
            var win_enviotyc = window.top.createWindow2({
                url: 'precarga_envio_codigo.aspx',
                title: '<b>Enviar codigo yacaré</b>',
                centerHFromElement: window.top.$("contenedor"),
                parentWidthElement: window.top.$("contenedor"),
                parentWidthPercent: 0.9,
                parentHeightElement: window.top.$("contenedor"),
                parentHeightPercent: 0.9,
                maxHeight: 180,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,                
                onClose: function(){}
            });
            win_enviotyc.options.userData = { param: param }
            win_enviotyc.showCenter(true)
            }

        }

        var win_tr
        var btn_tr_aceptar = false

        function tipo_rechazo() {
            win_tr = createWindow2({
                className: 'alphacube',
                title: '<b>Tipo de rechazo</b>',
                parentWidthPercent: 0.8,
                //parentWidthElement: $("contenedor"),
                maxWidth: 450,
                maxHeight: 200,
                //centerHFromElement: $("contenedor"),
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: true,
                closable: false,
                recenterAuto: true,
                setHeightToContent: true,
                //destroyOnClose: true,
                onClose: function () {
                    if (btn_tr_aceptar) {
                        strHTML_CDA_noti = ''
                        strHTML_CDA_noti += '<table>'
                        strHTML_CDA_noti += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#800000 !important"><b>' + tipo_rechazo_call + '</b></td></tr>'
                        strHTML_CDA_noti += '<table style="font-family: Verdana,Arial,Sans-serif;font-size: 12px"><tr><td><b>CUIT/CUIL:</b></td><td style="text-align:left">' + cuit + '</td></tr>'
                        strHTML_CDA_noti += '<tr><td><b>Nombre:</b></td><td>' + nombre + '</td></tr><tr><td><b>Observaciones:</b></td><td>' + observaciones_call + '</td></tr></table>'
                        NotiEnviar()
                    }
                }
            });
            var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
            html += "<table class='tb1' style='width:100%'>"
            html += "<tbody><tr><td colspan=2 class='Tit1'><br><b>Seleccione el tipo de rechazo.</b><br><br></td></tr>"
            html += "<tr><td style='width:30%'>Tipo:</td><td style='width:70%'><select id='cbtr' style='width:100%'>"
            var str_sel = ""
            var rstr = new tRS()
            rstr.open({ filtroXML: nvFW.pageContents["tipos_rechazos"] })
            while (!rstr.eof()) {
                html += "<option id='" + rstr.getdata('nro_com_tipo') + "' value='" + rstr.getdata('com_tipo') + "' " + str_sel + ">" + rstr.getdata('com_tipo') + "</option>"
                rstr.movenext()
            }
            html += "</select></td></tr>"
            html += "<tr><td>Observaciones:</td><td><textarea id='txt_observaciones' style='width:100%' rows='3'></textarea></td></tr>"
            html += "<tr><td style='text-align:center' colspan='2'><br><input type='button' value='Notificar' onclick='win_tipo_rechazo(true)'/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Cancelar' onclick='win_tipo_rechazo(false)'/><br><br></td></tr>"
            html += "</tbody></table></body></html>"
            win_tr.setHTMLContent(html)
            win_tr.showCenter(true)
        }


        var strHTML_CDA = ''
        var strHTML_CDA_noti = ''
        var hpx = 0

        var win_noti

        function NotiEnviar() {
            var subject = 'Notificación Precarga ' + dictamen + ' - ' + cuit + ':' + nombre.trim()
            var body = '<b>Razón Social:</b> ' + nombre + '<br>'
            body += '<b>CUIT/CUIL:</b> ' + cuit + '<br><br>'
            body += 'Informe Comercial:<br>'
            body += '<b>Situación:</b> ' + sit_bcra + ' - <b>CDA:</b> ' + dictamen
            var parametros = {}
            parametros['subject'] = subject
            parametros['body'] = strHTML_CDA_noti
            parametros['tipo_rechazo_call'] = tipo_rechazo_call
            parametros['cuit'] = cuit
            win_noti = createWindow2({
                url: 'sendMail.aspx?nro_vendedor=' + nro_vendedor,
                title: '<b>Notificación</b>',
                //centerHFromElement: $("contenedor"),
                //parentWidthElement: $("contenedor"),
                //parentWidthPercent: 0.9,
                //parentHeightElement: $("contenedor"),
                //parentHeightPercent: 0.9,
                maxHeight: 500,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true
            });
            win_noti.options.userData = { parametros: parametros }
            win_noti.showCenter(true)
        }

        var dictamen = ''
        var sit_bcra = 99
        var nro_banco_cobro = 0
        var banco_cobro = ''
        var cobro_array = {}

        function Log_registro(x) {
            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información comercial...')
            nro_sistema = Trabajos[x]['nro_sistema']
            sistema = Trabajos[x]['sistema']
            nro_lote = Trabajos[x]['nro_lote']
            lote = Trabajos[x]['lote']
            clave_sueldo = Trabajos[x]['clave_sueldo']
            nro_grupo = Trabajos[x]['nro_grupo']
            grupo = Trabajos[x]['grupo']
            nro_docu = Trabajos[x]['nro_docu']
            $('nro_docu').value = nro_docu_db
            $('clave_sueldo').value = clave_sueldo
			$('cuit').value = cuit
            razon_social = nombre
            $('divSelTrabajo').hide()
            $('divDatosPersonales').show()
            var rs = new tRS();
            rs.async = true
            var handler = function () {
                var rsN = new tRS()
                rsN.async = true
                rsN.onError = function (rsN) {
                    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                }
                rsN.onComplete = function (rsN) {
                    cupo_disponible = (Trabajos[x]['disponible'] == -1) ? 0 : parseFloat(Trabajos[x]['disponible']).toFixed(2)
                    tiene_cupo = (Trabajos[x]['disponible'] == -1) ? false : true
                    var nosis_cda = (rsN.getdata('nosis_cda') == undefined) ? 'No existen productos para la combinación seleccionada.' : rsN.getdata('nosis_cda') + ' - ' + rsN.getdata('nosis_cda_desc')
                    var nosis_cda_log = (rsN.getdata('nosis_cda') == undefined) ? '' : rsN.getdata('nosis_cda')
                    var str_edad = (rsN.getdata('control_edad') == 1) ? '<td style="color:#008000"><b>Cumple</b></td>' : '<td style="color:#800000"><b>No Cumple</b></td>'
                    var str_ent_exc = (rsN.getdata('ent_excluidas') == 0) ? '<td style="color:#008000;text-align:right"><b>' + rsN.getdata('ent_excluidas') + '</b></td>' : '<td style="color:#800000;text-align:right"><b>' + rsN.getdata('ent_excluidas') + ' *</b></td>'
                    var str_ch_rech = (rsN.getdata('ch_rechazados') == 0) ? '<td style="color:#008000;text-align:right"><b>' + rsN.getdata('ch_rechazados') + '</b></td>' : '<td style="color:#800000;text-align:right"><b>' + rsN.getdata('ch_rechazados') + '</b></td>'
                    dictamen = (rsN.getdata("nosis_cda") != null) ? 'APROBADO' : 'RECHAZADO'
                    strHTML_CDA = ''
                    strHTML_CDA_noti = ''
                    strHTML_CDA += '<table class="tb1">'
                    strHTML_CDA_noti += '<table>'

                    var dct_style = ''
                    switch (dictamen) {
                        case 'APROBADO':
                            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#008000 !important'
                            break;
                        case 'OBSERVADO':
                            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#ffd800 !important'
                            break;
                        case 'RECHAZADO':
                            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#800000 !important'
                            break;
                    }
                    strHTML_CDA += '<tr><td style="' + dct_style + '"><b>' + dictamen + '</b></td></tr>'
                    strHTML_CDA += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px"><b>' + nosis_cda + '</b></td></tr></table>'

                    strHTML_CDA_noti += '<tr><td style="' + dct_style + '"><b>' + dictamen + '</b></td></tr>'
                    strHTML_CDA_noti += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px"><b>' + nosis_cda + '</b></td></tr></table>'
                    strHTML_CDA_noti += '<table style="font-family: Verdana,Arial,Sans-serif;font-size: 12px"><tr><td><b>CUIT/CUIL:</b></td><td style="text-align:left">' + cuit + '</td></tr>'
                    strHTML_CDA_noti += '<tr><td><b>Nombre:</b></td><td>' + nombre + '</td></tr>'
                    strHTML_CDA_noti += '<tr><td><b>Cobro:</b></td><td>' + rsN.getdata('tipo_cobro') + '</td></tr>'
                    strHTML_CDA_noti += '<tr><td><b>Grupo:</b></td><td>' + rsN.getdata('Grupo') + '</td></tr>'
                    strHTML_CDA_noti += '<tr><td><b>Edad:</b></td>' + str_edad + '</tr>'
                    strHTML_CDA_noti += '<tr><td><b>Ent. Excluyentes:</b></td>' + str_ent_exc + '</tr>'
                    strHTML_CDA_noti += '<tr><td><b>Cheques Rech.:</b></td>' + str_ch_rech + '</tr></table>'

                    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1">CUIT/CUIL</td><td class="Tit1">Nombre</td></tr>'
                    strHTML_CDA += '<tr><td style="text-align:left">' + cuit + '</td><td>' + nombre + '</td></tr></table>'
                    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1">Cobro</td><td class="Tit1">Grupo</td></tr>'
                    strHTML_CDA += '<td>' + rsN.getdata('tipo_cobro') + '</td><td>' + rsN.getdata('Grupo') + '</td></tr></table>'
                    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1" style="width:30%">Edad</td><td class="Tit1" style="width:30%">Ent. Excluyentes</td><td class="Tit1">Cheques Rech.</td></tr>'
                    strHTML_CDA += str_edad + str_ent_exc + str_ch_rech + '</tr></table>'

                    $('strSitBCRA').innerHTML = ''
                    sit_bcra = rsN.getdata('situacion')
                    $('strSitBCRA').insert({ bottom: sit_bcra })
                    $('strSitBCRA').removeClassName($('strSitBCRA').className)
                    switch (sit_bcra) {
                        case '1':
                            $('strSitBCRA').addClassName('sit1')
                            break;
                        case '2':
                            $('strSitBCRA').addClassName('sit2')
                            break;
                        case '3':
                            $('strSitBCRA').addClassName('sit3')
                            break;
                        case '4':
                            $('strSitBCRA').addClassName('sit4')
                            break;
                        case '5':
                            $('strSitBCRA').addClassName('sit5')
                            break;
                        case '6':
                            $('strSitBCRA').addClassName('sit6')
                            break;
                    }

                    $('strDictamen').innerHTML = ''
                    $('strDictamen').insert({ bottom: dictamen })
                    $('strDictamen').removeClassName($('strDictamen').className)
                    switch (dictamen) {
                        case 'APROBADO':
                            $('strDictamen').addClassName('cdaAC')
                            break;
                        case 'OBSERVADO':
                            $('strDictamen').addClassName('cdaOB')
                            break;
                        case 'RECHAZADO':
                            $('strDictamen').addClassName('cdaRC')
                            break;
                    }

                    var rsBCRA = new tRS()
                    var color = 'green'
                    var marca_exc = ''
                    var style_exc = ''
                    var obs = ''
                    rsBCRA.open({
                        filtroXML: nvFW.pageContents["BCRA_deudores"],
                        params: "<criterio><params cuil='" + cuit + "' nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco='" + nro_banco_cobro + "' /></criterio>",
                        nvLog: "<nvLog><event id_log_evento='nosis_bcra' params='" + nro_vendedor + ";" + nro_grupo + ";" + nro_tipo_cobro + ";" + cuit + ";" + sit_bcra + ";" + dictamen + ";" + nosis_cda_log + "' moment='end' /></nvLog>"
                    })
                    strHTML_CDA += '<br><table style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 11px"><tr style="background-color: #f7f7f7;font-weight: normal;border-bottom: 1px solid #dbdbdb"><td>Entidad</td><td>Periodo</td><td>Base ' + rsN.getdata('fecha_info') + '</td><td>Sit.</td><td></td></tr>'
                    strHTML_CDA_noti += '<br><table style="width:60%;font-family: Verdana,Arial,Sans-serif;font-size: 11px"><tr style="background-color: #f7f7f7;font-weight: normal;border-bottom: 1px solid #dbdbdb"><td>Entidad</td><td>Periodo</td><td>Base ' + rsN.getdata('fecha_info') + '</td><td>Sit.</td><td></td></tr>'
                    while (!rsBCRA.eof()) {
                        var situacion = rsBCRA.getdata('situacion').trim()
                        switch (situacion) {
                            case '1':
                                color = 'green'
                                break;
                            case '2':
                                color = '#FFD700'
                                break;
                            case '3':
                                color = '#f0f'
                                break;
                            case '4':
                                color = '#c33'
                                break;
                            case '5':
                                color = 'maroon'
                                break;
                            case '6':
                                color = '#000'
                                break;
                        }
                        hpx = hpx + 20
                        marca_exc = ''
                        obs = ''
                        style_exc = 'text-align:left'
                        if (rsBCRA.getdata('excluyente') != undefined) {
                            marca_exc = '<b>*</b>'
                            style_exc = 'text-align:left;font-weight: bold;color:#800000'
                        }
                        if (rsBCRA.getdata('recat_obligatoria') == 1)
                            obs += '(B)'
                        if (rsBCRA.getdata('sit_juridica') == 1)
                            obs += '(C)'
                        strHTML_CDA += '<tr><td style="' + style_exc + '">' + rsBCRA.getdata('noment') + ' ' + marca_exc + '</td><td>' + rsBCRA.getdata('fecha_info') + '</td><td style="background-color: ' + color + ';color: #fff;text-align:right" title="' + rsBCRA.getdata('fecha_info') + '" ><b>' + rsBCRA.getdata('prestamos') + '</b></td><td style="background-color: ' + color + ';color: #fff;" title="' + rsBCRA.getdata('fecha_info') + '"><b>' + rsBCRA.getdata('situacion') + '</b></td><td>' + obs + '</td></tr>'
                        strHTML_CDA_noti += '<tr><td style="' + style_exc + '">' + rsBCRA.getdata('noment') + ' ' + marca_exc + '</td><td>' + rsBCRA.getdata('fecha_info') + '</td><td style="background-color: ' + color + ';color: #fff;text-align:right" title="' + rsBCRA.getdata('fecha_info') + '"><b>' + rsBCRA.getdata('prestamos') + '</b></td><td style="background-color: ' + color + ';color: #fff;" title="' + rsBCRA.getdata('fecha_info') + '"><b>' + rsBCRA.getdata('situacion') + '</b></td><td>' + obs + '</td></tr>'
                        rsBCRA.movenext()
                    }
                    strHTML_CDA += '<tr><td colspan="5"><br>B) Recategorización obligatoria. C) Situación jurídica.</td></tr>'
                    strHTML_CDA_noti += '<tr><td colspan="5"><br>B) Recategorización obligatoria. C) Situación jurídica.</td></tr>'
                    strHTML_CDA += '</table>'
                    strHTML_CDA_noti += '</table>'
                    nro_banco = rsN.getdata('nro_entidad')
                    CDA = rsN.getdata('nosis_cda')
                    campos_defs.habilitar('nro_tipo_cobro_precarga', true)
                    campos_defs.set_value('nro_tipo_cobro_precarga', nro_tipo_cobro)
                    campos_defs.habilitar('nro_tipo_cobro_precarga', false)
                    $('divGrupo').show()
                    $('strGrupo').innerHTML = ''
                    if (clave_sueldo != '')
                        $('strGrupo').insert({ bottom: grupo + ' (' + clave_sueldo + ')' })
                    else
                        $('strGrupo').insert({ bottom: grupo })
                    $('strCobro').innerHTML = ''
                    var strCobroDesc = (nro_tipo_cobro == 4) ? tipo_cobro + ' - ' + banco_cobro : tipo_cobro
                    $('strCobro').insert({ bottom: strCobroDesc })
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    Control_socio()

                }
                rsN.open({
                    filtroXML: nvFW.pageContents["precarga_cda"],
                    params: "<criterio><params nro_vendedor='" + nro_vendedor + "' nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco='" + nro_banco_cobro + "' cuit='" + cuit + "' /></criterio>",
                    nvLog: "<nvLog><event id_log_evento='nosis_cda_def' params='" + nro_vendedor + ";" + strVendedor + ";" + nro_grupo + ";" + grupo + ";" + nro_tipo_cobro + ";" + tipo_cobro + ";" + cuit + "' moment='end' /></nvLog>"
                })
            }
            rs.onComplete = function (rs) {
                if (rs.recordcount == 0) {
                    rserror_handler("No existen productos para el trabajo/grupo.")
                }
                if (rs.recordcount > 1) {
                    win_cobro = createWindow2({
                        title: '<b>Seleccionar Cobro</b>',
                        parentWidthPercent: 0.8,
                        //parentWidthElement: $("contenedor"),
                        maxWidth: 450,
                        maxHeight: 150,
                        //centerHFromElement: $("contenedor"),
                        minimizable: false,
                        maximizable: false,
                        draggable: false,
                        resizable: true,
                        closable: false,
                        recenterAuto: true,
                        setHeightToContent: true,
                        //destroyOnClose: true,
                        onClose: function () {
                            var dialogedubsas=false;
                                if($('grupos')!=null){
                                    if(btn_cobro_aceptar && nro_tipo_cobro=="1" && $('grupos').value=="10"){
                                        dialogedubsas=true
                                        Dialog.confirm("Desea consultar datos para Activos Provinciales - Buenos Aires - EDUCACION?",
                                                            {
                                                                width: 400,
                                                                className: "alphacube",
                                                                okLabel: "Si",
                                                                cancelLabel: "No",
                                                                onShow: function () {  },
                                                                onOk: function (w) {
                                                                    w.close();                                                                    
                                                                    $("consultarRobot").value="1"
                                                                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga');
                                                                    handler() 
                                                                    return                                                                   
                                                                },
                                                                onCancel:function(w){
                                                                    w.close();                                                                    
                                                                    $("consultarRobot").value="0"
                                                                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga');
                                                                    handler() 
                                                                    return
                                                                }
                                                            })
                                    }
                                }
                                if(!dialogedubsas){
                                    if (btn_cobro_aceptar) {
                                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga');
                                    handler()
                                    }
                                    else
                                        Precarga_Limpiar()
                                 }
                            
                        }
                    });
                    var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
                    html += "<table class='tb1'>"
                    html += "<tr><td colspan=2 class='Tit1'><br><b>Seleccione un tipo de cobro para continuar:</b><br><br></td></tr><table>"
                    html += "<table class='tb1 highlightEven highlightTROver'>"
                    var strchecked = ''
                    var i = 0
                    while (!rs.eof()) {
                        strchecked = (i == 0) ? 'checked' : ''
                        i++
                        cobro_array[i] = {}
                        cobro_array[i]['nro_tipo_cobro'] = rs.getdata('nro_tipo_cobro')
                        cobro_array[i]['tipo_cobro'] = rs.getdata('tipo_cobro')
                        cobro_array[i]['nro_banco'] = rs.getdata('nro_banco')
                        cobro_array[i]['abreviacion'] = rs.getdata('abreviacion')
                        html += "<tr onclick='selcobro(" + i + ")' style='cursor:pointer' ><td><input type='radio' name='rdcobro' id='rdcobro' value='" + i + "' " + strchecked + "/>" + ((rs.getdata('nro_banco') == undefined) ? rs.getdata('tipo_cobro') : rs.getdata('tipo_cobro') + " - " + rs.getdata('abreviacion')) + "</td></tr>"
                        rs.movenext()
                    }
                    html += "</table>"
                    html += "<table class='tb1'><tr><td style='text-align:center;width:50%'><br><input type='button' style='width:100%' value='Cancelar' onclick='win_cobro_cerrar(false)'/></td><td><br><input type='button' style='width:100%' value='Aceptar' onclick='win_cobro_cerrar(true)'/></td></tr>"
                    html += "</table></body></html>"
                    win_cobro.setHTMLContent(html)
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    win_cobro.showCenter(true)
                }
                else {
                    nro_tipo_cobro = rs.getdata("nro_tipo_cobro")
                    tipo_cobro = rs.getdata("tipo_cobro")
                    nro_banco_cobro = rs.getdata("nro_banco")
                    banco_cobro = rs.getdata("abreviacion")
                    handler()
                }
            }
            rs.open({ filtroXML: nvFW.pageContents["nosis_cda_def"], params: "<criterio><params nro_grupo='" + nro_grupo + "'/></criterio>" })

        }

        function win_cobro_cerrar(aceptar) {

            if (aceptar) {                
                var i = $$('input:checked[type="radio"][name="rdcobro"]').pluck('value')[0]
                nro_tipo_cobro = cobro_array[i]['nro_tipo_cobro']
                tipo_cobro = cobro_array[i]['tipo_cobro']
                nro_banco_cobro = ((cobro_array[i]['nro_banco'] == undefined) ? 0 : cobro_array[i]['nro_banco'])
                banco_cobro = ((cobro_array[i]['abreviacion'] == undefined) ? 0 : cobro_array[i]['abreviacion'])
            }
            btn_cobro_aceptar = aceptar
            win_cobro.close()
            
        }

        function selcobro(nro_tipo_cobro_sel) {
            var radioGrp = document['all']['rdcobro']
            if (radioGrp.length == undefined)
                $('rdcobro').checked = true
            else {
                for (i = 0; i < radioGrp.length; i++) {
                    if (radioGrp[i].value == nro_tipo_cobro_sel)
                        radioGrp[i].checked = true
                    else
                        radioGrp[i].checked = false
                }
            }
        }
        var existe
        var fecha_actualizacion = ''
        var disponible = 0

        function NOSIS_evaluar_identidad(nro_docu, onSusses, onError) {
            var strXML = ""
            var strHTML = ""
            var oXML = new tXML();
            oXML.async = true
            oXML.load('/FW/servicios/NOSIS/GetXML.aspx', 'accion=SAC_identidad&criterio=<criterio><nro_docu>' + nro_docu + '</nro_docu><CDA>' + CDA + '</CDA><nro_vendedor>' + nro_vendedor + '</nro_vendedor><nro_banco>' + nro_banco + '</nro_banco></criterio>',
                            function () {
                                var NODs = oXML.selectNodes('Resultado/Personas/Persona')
                                if (NODs.length == 0) {
                                    nvFW.alert('No se encontro información con el documento ingresado.')
                                    onError()
                                }
                                if (NODs.length == 1) {
                                    cuit = XMLText(selectSingleNode('Doc', NODs[0]))
                                    existe = selectSingleNode('@existe', NODs[0]).nodeValue
                                    onSusses(cuit)
                                }
                                if (NODs.length > 1) {
                                    win_sel_cuit = createWindow2({
                                        title: '<b>Seleccionar Persona</b>',
                                        //centerHFromElement: $("contenedor"),
                                        //parentWidthElement: $("contenedor"),
                                        //parentWidthPercent: 0.9,
                                        //parentHeightElement: $("contenedor"),
                                        //parentHeightPercent: 0.9,
                                        maxHeight: 500,
                                        minimizable: false,
                                        maximizable: false,
                                        draggable: true,
                                        resizable: true,
                                        onClose: function (win) {
                                            var e
                                            try {
                                                cuit = win.options.userData.res['cuit']
                                                existe = win.options.userData.res['existe']
                                                onSusses(cuit)
                                            }
                                            catch (e) {
                                                Precarga_Limpiar()
                                                return
                                            }
                                        }
                                    });
                                    win_sel_cuit.options.userData = { NODs: oXML }
                                    win_sel_cuit.setURL('NOSIS_sel_cuit.aspx')
                                    win_sel_cuit.showCenter(true)
                                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                                }
                            }
                            );
        }

        var nombre = ''
        var edad = 0

        function CUIT_obtener(nro_docu, tipo, onSusses, onError) {
            if (CUIT_source == 'DB') {
                var rs = new tRS();
                rs.async = true
                rs.onError = function (rs) {
                    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                }
                rs.onComplete = function (rs) {
                    if (rs.recordcount == 1) {
                        cuit = rs.getdata('cuit')
                        nombre = rs.getdata('nombre')
                        razon_social = rs.getdata('razon_social')
                        fe_naci = rs.getdata('fe_naci_str')
                        edad = rs.getdata('edad')
                        sexo = rs.getdata('sexo')
                        nro_docu = rs.getdata('nro_docu')
                        nro_docu_db = rs.getdata('nro_docu')
                        $('nro_docu').value = rs.getdata('nro_docu')
                        tipo_docu = 3
                        $('strApeyNomb').innerHTML = ''
                        $('strApeyNomb').insert({ bottom: nombre })
                        $('strCUIT').innerHTML = ''
                        $('strCUIT').insert({ bottom: cuit })
                        $('strFNac').innerHTML = ''
                        $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
                        onSusses(cuit, nro_docu)
                    }
                    if (rs.recordcount == 0) {
                        nvFW.alert('No se encontro información con el documento ingresado.')
                        onError()
                    }
                    if (rs.recordcount > 1) {
                        win_sel_dbcuit = createWindow2({
                            title: '<b>Seleccionar Persona</b>',
                            //centerHFromElement: $("contenedor"),
                            //parentWidthElement: $("contenedor"),
                            //parentWidthPercent: 0.9,
                            //parentHeightElement: $("contenedor"),
                            //parentHeightPercent: 0.9,
                            maxHeight: 500,
                            minimizable: false,
                            maximizable: false,
                            draggable: true,
                            resizable: true,
                            onClose: function (win) {
                                var e
                                try {

                                    res = win_sel_dbcuit.options.userData.res

                                    nro_docu_db = res['nro_docu']
                                    $('nro_docu').value = res['nro_docu']
                                    cuit = res['cuit']
                                    nombre = res['nombre']
                                    fe_naci = res['fe_naci_str']
                                    edad = res['edad']
                                    sexo = res['sexo']
                                    tipo_docu = 3
                                    $('strApeyNomb').innerHTML = ''
                                    $('strApeyNomb').insert({ bottom: nombre })
                                    $('strCUIT').innerHTML = ''
                                    $('strCUIT').insert({ bottom: cuit })
                                    $('strFNac').innerHTML = ''
                                    $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
                                    onSusses(cuit, nro_docu)
                                }
                                catch (e) {
                                    Precarga_Limpiar()
                                    return
                                }
                            }
                        });
                        win_sel_dbcuit.options.userData = { nro_docu: nro_docu }
                        win_sel_dbcuit.setURL('NOSIS_sel_DBCuit.aspx')
                        win_sel_dbcuit.showCenter(true)
                        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    }
                }
                if (tipo == 'dni')
                    rs.open({ filtroXML: nvFW.pageContents["DBCuit"], params: "<criterio><params nro_docu='" + nro_docu + "' /></criterio>" })
                else
                    rs.open({ filtroXML: nvFW.pageContents["DBCuit2"], params: "<criterio><params cuit='" + nro_docu + "' /></criterio>" })
            }
            else
                NOSIS_evaluar_identidad(nro_docu, onSusses, onError)
        }

        function NOSIS_actualizar_fuentes(cuit) {
            NOSIS_generar_informe(cuit)
        }

        var NosisXML = ''
        var strHTMLNosis = ''


        function NOSIS_generar_informe(cuit) {
            nvFW.bloqueo_msg('blq_precarga', "Obteniendo información de NOSIS...")
            var oXML = new tXML();
            oXML.async = true
            oXML.method = 'POST'
            oXML.onComplete = function () {
                strXML = XMLtoString(oXML.xml)
                NosisXML = strXML
                objXML = new tXML();
                objXML.async = false
                if (objXML.loadXML(strXML))
                    var NODs = objXML.selectNodes('Respuesta/ParteHTML')
                if (NODs.length == 1)
                    strHTMLNosis = XMLText(NODs[0])
                strHTMLNosis = replace(strHTMLNosis, "undefined", "'")
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            }
            oXML.onFailure = function () { nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga') }
            oXML.load('/FW/servicios/NOSIS/GetXML.aspx', 'accion=SAC_informe&criterio=<criterio><cuit>' + cuit + '</cuit><CDA>' + CDA + '</CDA><nro_vendedor>' + nro_vendedor + '</nro_vendedor><nro_banco>' + nro_banco + '</nro_banco></criterio>')

        }



        var prueba = ''
        var NroConsulta = 0
        var edad = ''
        var fe_naci_str = ''
        var sit_bcra = 99
        var HTMLCDA = ''

        function BCRA_obtener(strXML) {
            try {
                var SitBCRA = {}
                objXML = new tXML();
                objXML.async = false
                if (objXML.loadXML(strXML)) {
                    Deuda = objXML.getElementsByTagName('Deuda')
                    NroConsulta = XMLText(objXML.selectSingleNode('Respuesta/Consulta/NroConsulta'))
                    cuit = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Doc'))
                    razon_social = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/RZ'))
                    edad = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/Edad')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Edad')) : '99'
                    documento = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Tipo'))
                    domicilio = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Dom')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Dom')) : ''
                    localidad = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Loc')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Loc')) : ''
                    CP = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/CP')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/CP')) : sucursal_postal_real
                    provincia = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Prov')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Prov')) : ''
                    switch (documento) {
                        case 'DNI':
                            tipo_docu = 3
                            break;
                        case 'LE':
                            tipo_docu = 1
                            break;
                        case 'LC':
                            tipo_docu = 2
                            break;
                        default:
                            tipo_docu = 3
                    }
                    nro_docu = cuit.substring(2, 10)
                    sexo = 'M'
                    sexo_desc = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Sexo'))
                    if (sexo_desc == 'Femenino')
                        sexo = 'F'
                    fe_naci_str = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/FecNac')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/FecNac')) : ''
                    fe_naci = (fe_naci_str != '') ? fe_naci_str.substring(6, 8) + '/' + fe_naci_str.substring(4, 6) + '/' + fe_naci_str.substring(0, 4) : ''
                    $('strApeyNomb').innerHTML = ''
                    $('strApeyNomb').insert({ bottom: razon_social })
                    $('strCUIT').innerHTML = ''
                    $('strCUIT').insert({ bottom: cuit })
                    $('strFNac').innerHTML = ''
                    if (fe_naci != '')
                        $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
                    var rs = new tRS();
                    rs.open({ filtroXML: nvFW.pageContents["sit_bcra"], params: "<criterio><params id_consulta='" + NroConsulta + "' /></criterio>" })
                    if (!rs.eof())
                        sit_bcra = rs.getdata('situacion')

                    $('strSitBCRA').innerHTML = ''
                    $('strSitBCRA').insert({ bottom: sit_bcra })
                    $('strSitBCRA').removeClassName($('strSitBCRA').className)
                    switch (sit_bcra) {
                        case '1':
                            $('strSitBCRA').addClassName('sit1')
                            break;
                        case '2':
                            $('strSitBCRA').addClassName('sit2')
                            break;
                        case '3':
                            $('strSitBCRA').addClassName('sit3')
                            break;
                        case '4':
                            $('strSitBCRA').addClassName('sit4')
                            break;
                        case '5':
                            $('strSitBCRA').addClassName('sit5')
                            break;
                        case '6':
                            $('strSitBCRA').addClassName('sit6')
                            break;
                    }
                    empresa = objXML.getElementsByTagName('CalculoCDA')[0].getAttribute('Titulo')
                    HTMLCDA += "<html><head></head><body style='width:100%;height:100%;overflow:hidden'><table class='tb1 highlightEven'><tr><td style='width:30%'><b>CDA</b></td><td style='width:80%' class='Tit1'>" + empresa + "</td></tr>"

                    itemsCDA = objXML.getElementsByTagName('Item')
                    for (var i = 0; i < itemsCDA.length; i++) {
                        descripcion = XMLText(itemsCDA[i].childNodes[0])
                        if (descripcion == 'Dictamen') {
                            valor = "<b>" + XMLText(itemsCDA[i].childNodes[1]) + "</b>"
                            dictamen = XMLText(itemsCDA[i].childNodes[1])
                            $('strDictamen').innerHTML = ''
                            $('strDictamen').insert({ bottom: dictamen })
                            $('strDictamen').removeClassName($('strDictamen').className)
                            switch (dictamen) {
                                case 'APROBADO':
                                    $('strDictamen').addClassName('cdaAC')
                                    break;
                                case 'OBSERVADO':
                                    $('strDictamen').addClassName('cdaOB')
                                    break;
                                case 'RECHAZADO':
                                    $('strDictamen').addClassName('cdaRC')
                                    break;
                            }
                        }
                        else
                            valor = XMLText(itemsCDA[i].childNodes[1])
                        HTMLCDA += "<tr><td style='width:30%'>" + descripcion + "</td><td style='text-align:center'>" + valor + "</td></tr>"
                    }
                    HTMLCDA += "</table></body></html>"
                    $('strFuentes').innerHTML = ''
                    var parteHTML = XMLText(objXML.selectSingleNode('Respuesta/ParteHTML'))
                    var res = parteHTML.search(/Falta último Informe BCRA/)
                    if (res != -1)
                        $('strFuentes').insert({ bottom: ' - Falta último Informe BCRA' })

                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    Control_socio()
                }
            }
            catch (err) {
                nvFW.alert('No se puede generar la consulta de NOSIS. Intente nuevamente.')
                Precarga_Limpiar()
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            }
        }

        var Creditos = {}
        //var Consumos = {}
        var win_persona

        var persona_existe = true
        var fe_naci_socio = ''
        var edad_socio = 0
        var win_sel_persona

        var datos_persona = {}

        function Control_socio() {
            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información del socio...')
            var cr_mes = 0
            var tiene_cs = 0
            var tiene_cr = 0
            var rs = new tRS();
            rs.async = true
            rs.onError = function (rs) {
                rserror_handler("Error al consultar los datos. Intente nuevamente.")
            }
            rs.onComplete = function (rs) {
                if (rs.recordcount > 0) {
                    cr_mes = rs.getdata('cr_mes')
                    tiene_cs = rs.getdata('tiene_cs')
                    tiene_cr = rs.getdata('tiene_cr')
                    nro_docu = rs.getdata('nro_docu')
                }
                Evaluar_socio(cr_mes, tiene_cs, tiene_cr)
            }
            rs.open({ filtroXML: nvFW.pageContents["evaluar_persona"], params: "<criterio><params nro_vendedor='" + nro_vendedor + "' cuit='" + cuit + "' /></criterio>" })

        }

        var win_control_cred
        var opcion_ctrl = 0

        function win_control_cred_cerrar(opcion) {
            if (opcion == 1)
                VerCreditos('S')
            else {
                opcion_ctrl = opcion
                win_control_cred.close()
            }

        }

        function Evaluar_socio(cr_mes, tiene_cs, tiene_cr) {
            if ((tiene_cs > 0) || (tiene_cr > 0))
                $('divSocio').show()
            var Evaluar_persona = function () {
                var rs = new tRS();
                rs.async = true
                rs.onError = function (rs) {
                    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                }
                rs.onComplete = function (rs) {
                    if (rs.recordcount == 0) {
                        $('divSocio').hide()
                        persona_existe = false
                        SeleccionarPlanesMostrar()
                    }
                    if (rs.recordcount == 1) {  // Si la búsqueda de la persona por cuit da un resultado -> Carga creditos y CS
                        nro_docu = rs.getdata('nro_docu')
                        tipo_docu = rs.getdata('tipo_docu')
                        sexo = rs.getdata('sexo')
                        cod_prov_persona = rs.getdata('cod_prov')
                        fe_naci_socio = rs.getdata('fe_naci')
                        edad_socio = rs.getdata('edad')
                        Evaluar_cs()
                    }
                    if (rs.recordcount > 1) {   // Si la búsqueda da más de un resultado
                        datos_persona['nro_docu'] = ''
                        datos_persona['cuit'] = cuit
                        win_sel_persona = createWindow2({
                            title: '<b>Seleccionar Persona</b>',
                            //centerHFromElement: $("contenedor"),
                            //parentWidthElement: $("contenedor"),
                            //parentWidthPercent: 0.9,
                            //parentHeightElement: $("contenedor"),
                            //parentHeightPercent: 0.9,
                            maxHeight: 500,
                            minimizable: false,
                            maximizable: false,
                            draggable: true,
                            resizable: true,
                            onClose: function (win) {
                                if (win.options.userData.res != undefined) {
                                    var filtros = {}
                                    nro_docu = win.options.userData.res['nro_docu']
                                    tipo_docu = win.options.userData.res['tipo_docu']
                                    sexo = win.options.userData.res['sexo']
                                    cod_prov_persona = win.options.userData.res['cod_prov']
                                    var nombre = win.options.userData.res['nombre']
                                    fe_naci_socio = win.options.userData.res['fe_naci']
                                    rs = null
                                    Evaluar_cs()
                                }
                                else {
                                    $('divSocio').hide()
                                    persona_existe = false
                                    SeleccionarPlanesMostrar()
                                }
                            }
                        });
                        win_sel_persona.options.userData = { datos_persona: datos_persona }
                        win_sel_persona.setURL('precarga_sel_persona.aspx?codesrvsw=true')
                        win_sel_persona.showCenter(true)

                    }
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                }
                rs.open({ filtroXML: nvFW.pageContents["persona"], params: "<criterio><params cuit='" + cuit + "' /></criterio>" })
            }

            var Evaluar_cs = function () {
                nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información de cuota social...')
                if (tiene_cs > 0) {
                    var strHTMLS = "<table class='tb1' cellspacing='1' cellpadding='1' style='vertical-align:top'>"
                    var rsCS = new tRS();
                    rsCS.async = true
                    rsCS.onError = function (rsCS) {
                        rserror_handler("Error al consultar los datos. Intente nuevamente.")
                    }
                    rsCS.onComplete = function (rsCS) {
                        if (rsCS.recordcount > 0)
                            strHTMLS += "<tr><td class='Tit1' style='width:70%'>Mutual</td><td class='Tit1' style='width:30%;text-align:right'>Cuota</td></tr>"
                        else
                            strHTMLS += "<tr><td class='Tit1' style='width:100%' colspan=2>Sin información</td></tr>"
                        while (!rsCS.eof()) {
                            i++
                            Creditos[i] = {}
                            Creditos[i]['nro_credito'] = 0
                            Creditos[i]['nro_banco'] = 200
                            Creditos[i]['nro_mutual'] = rsCS.getdata('nro_mutual')
                            Creditos[i]['mutual'] = rsCS.getdata('mutual')
                            Creditos[i]['importe_cuota'] = parseFloat(rsCS.getdata('importe_cuota')).toFixed(2)
                            Creditos[i]['saldo'] = 0
                            Creditos[i]['saldo_nro_entidad'] = 0
                            Creditos[i]['cancela_vence'] = ''
                            Creditos[i]['cancela_cuota_paga'] = 0
                            Creditos[i]['nro_credito_seguro'] = 0
                            Creditos[i]['nro_calc_tipo'] = 0
                            Creditos[i]['cancela'] = false
                            rsCS.movenext()
                        }
                        for (var j in Creditos) {
                            strHTMLS += "<tr><td>" + Creditos[j]['mutual'] + "</td><td style='text-align:right'>$ " + parseFloat(Creditos[j]['importe_cuota']).toFixed(2) + "</td></tr>"
                        }
                        strHTMLS += "</table>"
                        $('tbCuotaSocial').insert({ bottom: strHTMLS })
                        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                        Evaluar_cr()
                    }
                    rsCS.open({ filtroXML: nvFW.pageContents["creditos_cs"], params: "<criterio><params cuit='" + cuit + "' /></criterio>" })
                }
                else {
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    Evaluar_cr()
                }

            }

            var Evaluar_cr = function () {
                nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información de saldos...')
                if (tiene_cr > 0) {
                    var strHTMLC = "<table id='tbCred' class='tb1 highlightEven highlightTROver' cellspacing='1' cellpadding='1' style='vertical-align:top;'><tr><td class='Tit1' style='width:10%'>Credito</td><td class='Tit1' width:30%>Banco</td><td class='Tit1' width:30%>Mutual</td><td class='Tit1' style='width:12%;text-align:right'>Cuota</td><td class='Tit1' style='width:13%;text-align:right'>Saldo</td><td class='Tit1' style='width:5%;text-align:center'>C</td></tr>"
                    var rsC = new tRS();
                    rsC.async = true                    
                    rsC.onError = function (rsCS) {
                        rserror_handler("Error al consultar los datos. Intente nuevamente.")
                    }
                    rsC.onComplete = function (rsC) {

                        while (!rsC.eof()) {
                            i++
                            
                            getCrRelacionados(rsC.getdata('nro_credito'))
                            var ret=getVectorrel(rsC.getdata('nro_credito'))
                            var credrel=null;
                                for(r=0;r< ret.length;r++){
                                    
                                    var ob=ret[r]
                                    if(ob.get("nro_credito")==rsC.getdata("nro_credito") && ob.get("estado")=="T"){
                                        credrel=ob;
                                        break;
                                    }
                                }
                            Creditos[i] = {}
                            Creditos[i]['nro_credito'] = rsC.getdata('nro_credito')
                            Creditos[i]['nro_banco'] = rsC.getdata('nro_banco')
                            Creditos[i]['nro_mutual'] = rsC.getdata('nro_mutual')
                            Creditos[i]['importe_cuota'] = (rsC.getdata('nro_calc_tipo') == 4) ? parseFloat(rsC.getdata('importe_cuota_seg')).toFixed(2) : parseFloat(rsC.getdata('importe_cuota')).toFixed(2)
                            if(credrel){
                                if(credrel.get("mostrarcuota")){
                                    Creditos[i]["importe_cuota"]=credrel.get("importe_cuota")
                                }else{
                                    Creditos[i]["importe_cuota"]=0
                                }

                            }
                            
                            Creditos[i]['saldo'] = parseFloat(rsC.getdata('saldo_importe')).toFixed(2)
                            Creditos[i]['saldo_nro_entidad'] = rsC.getdata('saldo_entidad')
                            Creditos[i]['cancela_vence'] = FechaToSTR(new Date(parseFecha(rsC.getdata('saldo_vencimiento'))))
                            Creditos[i]['cancela_cuota_paga'] = rsC.getdata('cuotas_pagadas')
                            Creditos[i]['nro_credito_seguro'] = rsC.getdata('nro_credito_seguro')
                            Creditos[i]['nro_calc_tipo'] = rsC.getdata('nro_calc_tipo')
                            //Creditos[i]['nro_pago_concepto'] = 2
                            Creditos[i]['cancela'] = false
                            var strChek = ''
                            var strClass = ''
                            strHTMLC += "<tr id='trCr_" + i + "' style='cursor:pointer;' " + strClass + " onclick='btnCancela_onClick(" + i + ")'><td nowrap='true'>" + rsC.getdata('nro_credito') + "</td><td>" + rsC.getdata('banco') + "</td><td nowrap='true'>" + rsC.getdata('mutual') + "</td><td style='text-align:right' nowrap='true'>$ " + Creditos[i]['importe_cuota'] + "</td><td style='text-align:right' nowrap='true'>$ " + parseFloat(rsC.getdata('saldo_importe')).toFixed(2) + "</td><td nowrap='true' style='text-align:center'><input type='checkbox' id='chkCred_" + i + "' style='border:0' " + strChek + " /></td></tr>"
                            rsC.movenext()
                        }
                        strHTMLC += "</table>"
                        if (rsC.recordcount > 0) {
                            $('td_canc_int').show()
                            $('tbCredVigente').insert({ bottom: strHTMLC })
                        }

                        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                        SeleccionarPlanesMostrar()
                        //CargarBancos()
                        //banco_onchange()
                        //nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    }
                    rsC.open({ filtroXML: nvFW.pageContents["saldos"], params: "<criterio><params nro_docu='" + nro_docu + "' tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' /></criterio>" })
                }
                else {
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    SeleccionarPlanesMostrar()
                    //CargarBancos()
                    //banco_onchange()
                    //nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                }
            }



            $('tbCredVigente').innerHTML = ''
            $('tbCredVigente3').innerHTML = ''
            $('tbCuotaSocial').innerHTML = ''
            var i = 0
            Creditos = {}
            if (cr_mes > 0) {
                win_control_cred = createWindow2({
                    title: '<b>Control de créditos</b>',
                    parentWidthPercent: 0.8,
                    //parentWidthElement: $("contenedor"),
                    maxWidth: 450,
                    maxHeight: 120,
                    //centerHFromElement: $("contenedor"),
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: true,
                    closable: false,
                    recenterAuto: true,
                    setHeightToContent: true,
                    onClose: function () {
                        if (opcion_ctrl == 2) {
                            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información del socio...')
                            Evaluar_persona()
                        }
                        else
                            Precarga_Limpiar()
                    }
                });
                var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
                html += "<table class='tb1'>"
                html += "<tr><td colspan=3 class='Tit1'><br>Ya existen créditos ingresados en el mes para el número de documento: <b>" + $('nro_docu1').value + "</b>. Desea ver los créditos o continuar con la carga?</b><br><br></td></tr><table>"
                html += "<table class='tb1'><tr><td style='text-align:center;width:33%'><br><input type='button' style='width:100%; cursor:pointer' value='Ver Créditos' onclick='win_control_cred_cerrar(1)'/></td><td style='text-align:center;width:33%'><br><input type='button' style='width:100%; cursor:pointer' value='Continuar' onclick='win_control_cred_cerrar(2)'/></td><td style='text-align:center;width:33%'><br><input type='button' style='width:100%; cursor:pointer' value='Limpiar' onclick='win_control_cred_cerrar(3)'/></td></tr>"
                html += "</table></body></html>"
                win_control_cred.setHTMLContent(html)
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                win_control_cred.showCenter(true)
            }
            else
                Evaluar_persona()
        }

        var win_nosis_generar
        var btn_aceptar_nosis = false

        function win_nosis_generar_cerrar(aceptar) {
            btn_aceptar_nosis = aceptar
            win_nosis_generar.close()
        }

        function VerInformeNosis() {
            if ((permisos_precarga & 2) <= 0) {
                nvFW.alert('No posee permisos para generar el informe')
                return
            }
            if (strHTMLNosis == '') {
                if (dictamen == 'RECHAZADO') {
                    nvFW.alert('No se puede generar el informe para una solicitud Rechazada.')
                    return
                }
                win_nosis_generar = createWindow2({
                    title: '<b>Generar Informe Nosis</b>',
                    parentWidthPercent: 0.8,
                    //parentWidthElement: $("contenedor"),
                    maxWidth: 450,
                    maxHeight: 150,
                    //centerHFromElement: $("contenedor"),
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: true,
                    closable: false,
                    recenterAuto: true,
                    setHeightToContent: true,
                    //destroyOnClose: true,
                    onClose: function () {
                        if (btn_aceptar_nosis)
                            NOSIS_generar_informe2(cuit)
                    }
                });
                var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
                html += "<table class='tb1'><tr><td class='Tit1' style='text.align:center'><br>Desea generar el informe Nosis?<br></td></tr></table></br>"
                html += "<div style='text-align:center;width:49%;float:left'><input type='button' style='width:90%' value='Generar Informe' onclick='win_nosis_generar_cerrar(true)'/></div>"
                html += "<div style='text-align:center;width:49%;float:left'><input type='button' style='width:90%' value='Cancelar' onclick='win_nosis_generar_cerrar(false)'/></div>"
                html += "</body></html>"
                win_nosis_generar.setHTMLContent(html)
                win_nosis_generar.showCenter(true)
            }

            else {
                strHTMLNosis = replace(strHTMLNosis, "undefined", "'")
                mostrarHTMLNosis(strHTMLNosis)
            }
        }

        var win_error_nosis
        function NOSIS_generar_informe2(cuit, reintento) {
            var HTML_bloqueo = "<input type='button' id='btn_cancelar' style='width:20px' value='Detener' style='cursor: pointer !important' />"

            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Generando informe de Nosis&nbsp;&nbsp;&nbsp;<img border="0" id="img_cancelar" src="image/cancel.png" align="absmiddle" title="Cancelar" style="vertical-align:middle; cursor: pointer" />')

            var oXML = new tXML();
            try {
               // mixpanel.track("consultar_nosis"); //registrar el evento consultar_nosis
                var reintentos = "<reintentos>1</reintentos>"
                if (reintento == 0) reintentos = ""

            oXML.async = true
            oXML.method = 'POST'
            oXML.onFailure = function () { nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga') }
                oXML.load('/FW/servicios/NOSIS/GetXML.aspx', 'accion=SAC_informe&criterio=<criterio><cuit>' + cuit + '</cuit><CDA>' + CDA + '</CDA><nro_vendedor>' + nro_vendedor + '</nro_vendedor><nro_banco>' + campos_defs.get_value("banco") + '</nro_banco>' + reintentos + '</criterio>',
                function () {
                    strXML = XMLtoString(oXML.xml)
                    NosisXML = strXML
                    objXML = new tXML();
                    objXML.async = false
                    var novedad = ""

                    if (objXML.loadXML(strXML))
                       var NODs = objXML.selectNodes('Respuesta/ParteHTML')

                        var NOD_novedad = oXML.selectNodes('Respuesta/Consulta/Resultado')
                        if (NOD_novedad.length > 0)
                            novedad = XMLText(selectSingleNode('Novedad', NOD_novedad[0]))

                        if(NODs[0])
                        strHTMLNosis = XMLText(NODs[0])

                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')

                    if (novedad != "") {
                          //  alert("NOSIS: " + novedad)
                            win_error_nosis = createWindow2({
                            title: '<b>Notificacion nosis</b>',
                             maxWidth: 450,
                             maxHeight: 100,
                               // recenterAuto: true,
                              //  setHeightToContent: true,
                            minimizable: false,
                            maximizable: false,
                            draggable: true,
                            resizable: true
                        });
                            
                           var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
                            html += '<table class="tb1">'
                            html += '<tbody><tr><td colspan="3">'+novedad+'</td></tr><tr><td colspan="3"></td></tr>'
                            html += '<tr><td style="text-align:center;width:25%"><input type="button" style="width:80%" value="Reintentar" onclick="reintentar('+cuit+', 1)" style="cursor:pointer" /></td>'
                            html += '<td style = "text-align:center;width:25%" ><input type="button" style="width:80%" value="Generarlo igual" onclick="reintentar('+cuit+', 0)" style="cursor:pointer" /></td>'
                            html += '<td style = "text-align:center;width:25%" ><input type="button" style="width:80%" value="Cerrar" onclick="win_error_nosis.close()" style="cursor:pointer" /></td></tr > '
                            html += '</tbody></table></body></html>'

                            win_error_nosis.setHTMLContent(html)
                            win_error_nosis.showCenter(true)
                            
                            return
                        }

                        if (strHTMLNosis == '') {
                            alert("Error al consultar los datos.")
                        return
                    }

                    strHTMLNosis = replace(strHTMLNosis, "undefined", "'")
                    mostrarHTMLNosis(strHTMLNosis)
                }
                )
            } catch (e) {
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                alert("Error al generar nosis.")
            }
            $('img_cancelar').observe("click", function () { NOSIS_generar_informe2_cancel(oXML) })
        }


        function reintentar(cuit, intento) { 
            NOSIS_generar_informe2(cuit, intento)
            win_error_nosis.close()
        }

        function mostrarHTMLNosis(strHTML) {
            if (nvFW.nvInterOP) {
                //window.open("data:text/html;charset=utf-8," + strHTMLNosis, "", "https://nullurl.redmutual.com.ar")
                window.open("_null?content=" + encodeURIComponent(strHTMLNosis))
            } else {
                var win = window.open()
                win.document.write(strHTMLNosis)
            }
        }

        function NOSIS_generar_informe2_cancel(oXML) {
            try {
                oXML.abort()
            }
            catch (e) { }//divBloq_msg_blq_precarga
            //$("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "" })
            //$("divBloq_" + 'msg_blq_precarga')._DivMsg.setStyle({ background: "" })
           // nvFW.bloqueo_desactivar(null, 'msg_blq_precarga')
          nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
           // Precarga_Limpiar()
        }

        var win_cda
        function VerCDA() {

            var winVerCda = createWindow2({
                width: 280,
                height: 160,
                title: '',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true
            })

            winVerCda.setHTMLContent(strHTML_CDA)
            winVerCda.showCenter(true)
            /*
            nvFW.alert(strHTML_CDA, {
            sizable: true,
            //parentWidthElement: $("contenedor"),
            //parentWidthPercent: 0.9,
            maxWidth: 480,
            height: 300
            //parentHeightElement: $("contenedor"),
            //parentHeightPercent: 0.8,
            //maxHeight: 280// + hpx

            })*/

        }



        //devuelvo el arreglo de creditos con el que se relaciona, sino devuelvo array vacio
            function getVectorrel(nro_credito){
                var ret=Array()
                var idx= -1
                //si ya existe el credito en alguna relacion de postergaciones, no busco nada
                for(i=0;i<crPostergaciones.length;i++){
                    var cr=crPostergaciones[i]
                    for(var j=0;j<cr.length;j++){
                        if(cr[j].get("nro_credito")==nro_credito){
                            ret=cr
                        break;
                        }    
                    }
                    //si ya lo encontro, que salga
                    if(ret.length>0){
                        break;
                    }
                }
                return ret;
            }

            //dado un credito, devuelvo el indice del arreglo donde esta relacionado con otros, sino cargo su relacionados
            function getCrRelacionados(nro_credito){    
            
                var cr=Array()
                var nro_credito_origen=null;
                //si el credito ya esta relacionado con algun vector, no cargo nada
                var ret=getVectorrel(nro_credito)
                if(ret.length>0){
                    return
                }                
                var mostrarcuota=false;
                var rsC0 = new tRS();
                 rsC0.async = false;                  
                 rsC0.open({filtroXML: nvFW.pageContents["postergaciones"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })                 
                 if(!rsC0.eof()){
                    nro_credito_origen= rsC0.getdata("credito_origen")
                 }else{
                    nro_credito_origen=nro_credito
                }
                //agrego el credito originante al vector
                if(nro_credito_origen){
                 var rsC1 = new tRS();
                 rsC1.async = false; 
                 rsC1.open({filtroXML: nvFW.pageContents["credito_originante"], params: "<criterio><params nro_credito='" + nro_credito_origen + "' /></criterio>" })
                  if(!rsC1.eof()){ 
                        var ocred={}                 
                        ocred['nro_credito']=rsC1.getdata("nro_credito")                        
                        ocred['agregado']=false;
                        ocred['estado']=rsC1.getdata("estado")
                        ocred['importe_cuota']=rsC1.getdata("importe_cuota")                        
                         if(!mostrarcuota && (rsC1.getdata("estado")=="T")){
                          ocred['mostrarcuota']=true;
                          mostrarcuota=true;  
                          }else{
                           ocred['mostrarcuota']=false;
                        }
                        cr.push($H(ocred));
                  }
                }
                  
                 var rsC2 = new tRS();
                 rsC2.async = false; 
                 rsC2.open({filtroXML: nvFW.pageContents["postergaciones_originante"], params: "<criterio><params credito_origen='" + nro_credito_origen + "' /></criterio>" })
                  while (!rsC2.eof()){ 
                        var ocred={}                 
                        ocred['nro_credito']=rsC2.getdata("nro_credito")                        
                        ocred['agregado']=false;
                        ocred['estado']=rsC2.getdata("estado")
                        ocred['importe_cuota']=rsC2.getdata("importe_cuota")                        
                         if(!mostrarcuota && (rsC2.getdata("estado")=="T")){
                          ocred['mostrarcuota']=true;
                          mostrarcuota=true;  
                          }else{
                           ocred['mostrarcuota']=false;
                        }
                        cr.push($H(ocred));                    
                    rsC2.movenext()
                  }
                  if(cr.length>1){
                    //agreggo el credito parametro si es que se relaciona con algunos                    
                   crPostergaciones.push(cr)  
                  }
                             
            }//getCrRealcionados


        

        function PostergacionAdd(nro_credito) {            
            var rel=getVectorrel(nro_credito)
            if(rel.length==0) return //si el credito no se realciona con nadie, retorna            
            for (var j=0;j<rel.length;j++){
                        if(rel[j].get("nro_credito")==nro_credito && rel[j].get("agregado")){
                            return; //si ya se agrego, no lo vuelvo a agregar
                        }
            }
            for(var r=0;r<rel.length;r++){
                if(!rel[r].get('agregado')){
                    var nro_cred=rel[r].get('nro_credito')
                    rel[r].set('agregado',true)
                    for (var k in Creditos){
                        if(Creditos[k]['nro_credito']==nro_cred && nro_credito!=nro_cred){                           
                        btnCancela_onClick(k)    
                        break    
                        }
                     }
                }
            }
            
        }


        function PostergacionRemove(nro_credito) {  
        var rel=getVectorrel(nro_credito)
            if(rel.length==0) return //si el credito no se realciona con nadie, retorna            
            for (var j=0;j<rel.length;j++){
                        if(rel[j].get("nro_credito")==nro_credito && !rel[j].get("agregado")){
                            return; //si ya se elimino, no lo vuelvo a eliminar
                        }
            }
            for(var r=0;r<rel.length;r++){
                if(rel[r].get('agregado')){
                    var nro_cred=rel[r].get('nro_credito')
                    rel[r].set('agregado',false)
                    for (var k in Creditos){
                        if(Creditos[k]['nro_credito']==nro_cred && nro_credito!=nro_cred){                           
                        btnCancela_onClick(k)    
                        break    
                        }
                     }
                }
            }  
        }//PostergacionRemove

        var Cancelaciones = {}
        function btnCancela_onClick(i) {               
            var tr = $('trCr_' + i)
            if (tr.className == 'Tit3') {
                tr.removeClassName('Tit3')
                $('chkCred_' + i).checked = false
                PostergacionRemove(Creditos[i]['nro_credito'])
            }
            else {                
                tr.addClassName('Tit3')
                $('chkCred_' + i).checked = true
                PostergacionAdd(Creditos[i]['nro_credito'])
            }
            TotalCancelaciones1 = 0
            LiberaCuota = 0

            //Si tiene seguro forzar la selección
            for (var j in Creditos) {
                if (j != i) {
                    if ((Creditos[j]['nro_credito_seguro'] != 0) && (Creditos[i]['nro_credito_seguro'] == Creditos[j]['nro_credito_seguro'])) {
                        var trS = $('trCr_' + j)
                        if ($('chkCred_' + i).checked == true) {
                            trS.addClassName('Tit3')
                            $('chkCred_' + j).checked = true
                            Creditos[j]['cancela'] = true
                        }
                        else {
                            trS.removeClassName('Tit3')
                            $('chkCred_' + j).checked = false
                            Creditos[j]['cancela'] = false
                        }
                    }
                }
            }

            for (var x in Creditos) {
                if (x == i)
                    if ($('chkCred_' + i).checked == true)
                        Creditos[x]['cancela'] = true
                    else
                        Creditos[x]['cancela'] = false
                    if (Creditos[x]['cancela'] == true) {
                        TotalCancelaciones1 = parseFloat(parseFloat(TotalCancelaciones1) + parseFloat(Creditos[x]['saldo'])).toFixed(2)
                        LiberaCuota = parseFloat(parseFloat(LiberaCuota) + parseFloat(Creditos[x]['importe_cuota'])).toFixed(2)
                    }
                }
                importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
                importe_mano = 0
                importe_mano = importe_neto - gastoscomerc - TotalCancelaciones1
                $('strEnMano').innerHTML = ''
                $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })


                Cancelaciones = {}
                var j = 0
                for (var x in Creditos) {
                    if (Creditos[x]['cancela'] == true) {
                        j++
                        Cancelaciones[j] = {}
                        Cancelaciones[j]['cancela_cuota'] = Creditos[x]['importe_cuota']
                        Cancelaciones[j]['cancela_cupo'] = 0
                        Cancelaciones[j]['importe_pago'] = Creditos[x]['saldo']
                    }
                }
                saldo_a_cancelar = parseFloat(TotalCancelaciones1)
                $('saldo_a_cancelar').innerHTML = ''
                $('saldo_a_cancelar').insert({ bottom: parseFloat(TotalCancelaciones1).toFixed(2) })
                analisis_actualizar(false)
                if (nro_grupo == 0)
                    Validar_datos()
            }

            var plan_lineas = ''
            var noti_prov = false
            var nro_credito_random = 0

            function win_sel_cp_onclick(aceptar) {
                if (persona_existe == true) {
                    if ($('chk_noti_prov').checked)
                    if (cod_prov_persona == campos_defs.get_value('cod_provincia') ){//$('cbprov').value) {
                            nvFW.alert('La provincia seleccionada es la misma que la propuesta.<br>Para notificar el cambio debe seleccionar otra. Verifique.')
                            return
                        }
                    noti_prov = $('chk_noti_prov').checked
                }
            if (campos_defs.get_value('cod_provincia') == '') {
                alert("Debe seleccionar la provincia de residencia")
                return
            }
            cod_prov_persona = campos_defs.get_value('cod_provincia') // $('cbprov').value
                btn_sel_cp_aceptar = aceptar
                win_sel_cp.close()
            }

            function chk_noti_prov_on_click() {
                if ($('chk_noti_prov').checked)
                campos_defs.habilitar('cod_provincia', true)   //$('cbprov').enable()
                else {
                campos_defs.set_value('cod_provincia', cod_prov_persona)  //$('cbprov').value = cod_prov_persona
                campos_defs.habilitar('cod_provincia', false) //$('cbprov').disable()
                }
            }

            var win_sel_cp
            var btn_sel_cp_aceptar = false

            var win_files
            var nro_archivo_noti_prov = 0

            function ABMArchivos_return() {
                var retorno = win_files.options.userData.res
                if (retorno == undefined) {
                    nvFW.alert('Debe adjuntar un servicio para notificar el cambio de provincia.')
                    Precarga_Limpiar()
                }
                var sucess = retorno['sucess']
                nro_archivo_noti_prov = retorno['nro_archivo']
                if (sucess == true) {
                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Buscando información del producto...')
                    $('divProducto').show()
                    $('divFiltros').show()
                    if (nro_grupo != 0) {
                        $('ifrplanes').hide()
                        $('tbfiltros').hide()
                        $('selplan').hide()
                        $('selplan').setStyle({ display: 'inline' })
                    }
                    else {
                        $('ifrplanes').show()
                        $('tbfiltros').show()
                        $('selplan').setStyle({ display: 'none' })
                    }
                    $('tbButtons').show()
                    $('strEnMano').innerHTML = ''
                    $('chkmax_disp').checked = true
                    $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
                    importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
                    var socio = false
                    for (var j in Creditos) {
                    if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
                            socio = true
                            break
                        }
                    }
                    if (!socio)
                        importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)
              //  $('banco').options.length = 0
              //  $('mutual').options.length = 0
                campos_defs.clear('banco')
                campos_defs.clear('mutual')
                    CargarBancos(banco_onchange)
                }
                else {
                    nvFW.alert('Debe adjuntar un servicio para notificar el cambio de provincia.')
                    Precarga_Limpiar()
                }
            }

            function SeleccionarPlanesMostrar() {
                win_sel_cp = new Window({
                    className: 'alphacube',
                    title: '<b>Seleccionar Provincia</b>',
                    parentWidthPercent: 0.8,
                    //parentWidthElement: $("contenedor"),
                maxWidth: 430,
                width: 250,
                maxHeight: 220,
                    //centerHFromElement: $("contenedor"),
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: true,
                    closable: false,
                    recenterAuto: true,
                    setHeightToContent: true,
                    //destroyOnClose: true,
                onShow: function (){
                       campos_defs.add('cod_provincia', {target: 'tbProv' , enDB: false, nro_campo_tipo: 1, filtroXML: nvFW.pageContents["provincia"] })
                       var rsG = new tRS()
                       rsG.open({ filtroXML: nvFW.pageContents["grupo_provincia"], params: "<criterio><params nro_grupo='" + nro_grupo + "' cod_prov='" + cod_prov_op + "' /></criterio>" })
                       if (!rsG.eof()) {
                            campos_defs.set_value('cod_provincia', rsG.getdata('cod_prov'))
                        }
                },
                    onClose: function () {
                        if (btn_sel_cp_aceptar) {
                            if (noti_prov == true) {
                                var param = {}
                                param['nro_credito'] = 0
                                win_files = window.top.nvFW.createWindow({
                                    url: 'ABMDocumentos_prov.aspx',
                                    title: '<b>Adjuntar Servicio</b>',
                                    //centerHFromElement: window.top.$("contenedor"),
                                    //parentWidthElement: window.top.$("contenedor"),
                                    //parentWidthPercent: 0.9,
                                    //parentHeightElement: window.top.$("contenedor"),
                                    //parentHeightPercent: 0.9,
                                    maxHeight: 150,
                                    minimizable: false,
                                    maximizable: false,
                                    draggable: true,
                                    resizable: true,
                                    onClose: ABMArchivos_return
                                });
                                win_files.options.userData = { param: param }
                                win_files.showCenter(true)
                            }
                            else {
                                nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Buscando información del producto...')
                                $('divProducto').show()
                                $('divFiltros').show()
                                if (nro_grupo != 0) {
                                    $('ifrplanes').hide()
                                    $('tbfiltros').hide()
                                    $('selplan').hide()
                                    $('selplan').setStyle({ display: 'inline' })
                                }
                                else {
                                    $('ifrplanes').show()
                                    $('tbfiltros').show()
                                    $('selplan').setStyle({ display: 'none' })
                                }
                                $('tbButtons').show()

                                $('strEnMano').innerHTML = ''
                                $('chkmax_disp').checked = true

                                $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
                                importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
                                var socio = false
                                for (var j in Creditos) {
                                if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
                                        socio = true
                                        break
                                    }
                                }
                                if (!socio)
                                    importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)

                       //     $('banco').options.length = 0
                            //    $('mutual').options.length = 0
                            campos_defs.clear('banco')
                            campos_defs.clear('mutual')
                                if (dictamen == 'RECHAZADO')
                                    VerCDA()
                                CargarBancos(banco_onchange)
                            }

                        }
                        else
                            Precarga_Limpiar()
                    }
                });
                var html = ""
                if (persona_existe == false) {
                    html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
                    html += "<table class='tb1' style='width:100%'>"
                    html += "<tbody><tr><td colspan=2 class='Tit1'><br><b>Seleccione la provincia de residencia de la persona. (Debe coincidir con la del servicio a presentar).</b><br><br></td></tr>"
                html += "<tr><td style='width:30%'>Provincia:</td><td id='tbProv' style='width:70%'>" //<select id='cbprov' style='width:100%'>"
                html += "</td></tr>"


     /*           var rs = new tRS()
                    var prov_sel = ""
                    var encontro = false
                    rs.open({ filtroXML: nvFW.pageContents["provincia"] })
                    while (!rs.eof()) {
                        prov_sel = ""
                        if (!encontro) {
                            var rsG = new tRS()
                            rsG.open({ filtroXML: nvFW.pageContents["grupo_provincia"], params: "<criterio><params nro_grupo='" + nro_grupo + "' cod_prov='" + rs.getdata('cod_prov') + "' /></criterio>" })
                            if (!rsG.eof()) {
                                prov_sel = "selected"
                                encontro = true
                            }
                        }
                        if (!encontro)
                            prov_sel = (rs.getdata('cod_prov') == cod_prov_op) ? "selected" : ""
                        html += "<option id='" + rs.getdata('cod_prov') + "' value='" + rs.getdata('cod_prov') + "' " + prov_sel + ">" + rs.getdata('provincia') + "</option>"
                        rs.movenext()
                    }
                html += "</select></td></tr>"   */
                    html += "<tr><td style='text-align:center;width:50%' colspan='2'><br><input type='button' value='Aceptar' style='width:50%' onclick='win_sel_cp_onclick(true)'/><br></td></tr>"
                    html += "</tbody></table></body></html>"
               // 
                    win_sel_cp.setHTMLContent(html)
                    win_sel_cp.showCenter(true)
                
                
                }
                else {
                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Buscando información del producto...')
                    $('divProducto').show()
                    $('divFiltros').show()
                    if (nro_grupo != 0) {
                        $('ifrplanes').hide()
                        $('tbfiltros').hide()
                        $('selplan').hide()
                        $('selplan').setStyle({ display: 'inline' })
                    }
                    else {
                        $('ifrplanes').show()
                        $('tbfiltros').show()
                        $('selplan').setStyle({ display: 'none' })
                    }
                    $('tbButtons').show()
                    $('strEnMano').innerHTML = ''
                    $('chkmax_disp').checked = true
                    $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
                    importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
                    var socio = false
                    for (var j in Creditos) {
                    if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
                            socio = true
                            break
                        }
                    }
                    if (!socio)
                        importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)
          //      $('banco').options.length = 0
             //   $('mutual').options.length = 0
                campos_defs.clear('banco')
                campos_defs.clear('mutual')
                    if (dictamen == 'RECHAZADO')
                        VerCDA()
                    CargarBancos(banco_onchange)
                }
            }

        var aux_valor_banco_old = ''
            function CargarBancos(banco_onchange) {
            campos_defs.habilitar("banco", true)
            campos_defs.clear_list("banco")
             var rs = new tRS()
             //rs.addField("id", "int")
             //rs.addField("campo", "string")
             //rs.addRecord({id:"1", campo:'Algo de 1'})
             //rs.addRecord({id:"2", campo:'Algo de 2'})
            
            //var id = rs.getdata("id") 
            //var campo = rs.getdata("campo")
            //campos_defs.add('cod_servidor1', {nro_campo_tipo : 1, enDB: false, json: true});
           //   campos_defs.items['banco'].rs = rs

                var i = 0
                rs.async = true
                rs.onError = function (rs) {
                    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                }
                rs.onComplete = function (rs) {
            //    if (rs.recordcount == 0)
            //        rserror_handler("Error al consultar los datos. Intente nuevamente.")
            //    while (!rs.eof()) {
            //        //$('banco').insert(new Element('option', { value: rs.getdata('nro_banco') }).update(rs.getdata('banco')))

            //        campos_defs.items['banco'].

            //        rs.movenext()
            //    }
            //    $('banco').setStyle({ width: '100%' })
            //    banco_onchange()

                campos_defs.items['banco'].rs = rs
                campos_defs.set_first('banco')
               
               if (rs.recordcount == 1) campos_defs.habilitar("banco", false)
               else campos_defs.habilitar("banco", true)
                }
                rs.open({ filtroXML: nvFW.pageContents["operatoria_bancos"], params: "<criterio><params sit_bcra='" + sit_bcra + "' nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco_cobro='" + nro_banco_cobro + "' /></criterio>" })

            }

          function inaes_black_list(nro_banco){
                if(nro_banco!=800) return false;
                var rs = new tRS()
                rs.async=false
                var cuit=$("cuit").value
                rs.open({ filtroXML: nvFW.pageContents["inaes_black_list"], params: "<criterio><params CUIT='" + cuit + "' /></criterio>" })
                return (!rs.eof())

            }

            function banco_onchange() {
            
            var nro_banco_filtro = campos_defs.get_value('banco')//$('banco').value

            if (nro_banco_filtro == aux_valor_banco_old ) {
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga');
                return
            }
            /*if(inaes_black_list(nro_banco_filtro)){
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga');
                alert("Persona bloqueada para alta en voii. Seleccione otro Banco")
                if(aux_valor_banco_old!=800 && aux_valor_banco_old!=""){
                campos_defs.set_value('banco',aux_valor_banco_old)       
                }
                return
            }*/

            campos_defs.habilitar("mutual", true)
            campos_defs.clear_list("mutual")
            campos_defs.habilitar("cbAnalisis", true)
            campos_defs.clear_list("cbAnalisis")

            if (nro_banco_filtro != '') {
                    CargarMutuales(nro_banco_filtro, mutual_onchange)
            }
            else {
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            }
            aux_valor_banco_old = nro_banco_filtro
           
        }
        var aux_valor_mutual_old = ''
            function CargarMutuales(nro_banco_filtro, mutual_onchange) {
            //$('mutual').options.length = 0
            campos_defs.clear("mutual")
                var i = 0
                var sel = false
                var rs = new tRS();
                rs.async = true
                rs.onError = function (rs) {
                    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                }
                rs.onComplete = function (rs) {
                //if (rs.recordcount == 0)
                //    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                //while (!rs.eof()) {
                //    var descripcion = ''
                //    for (var j in Creditos) {
                //        if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == rs.getdata('nro_mutual')) {
                //            descripcion = ' (Socio)'
                //            break
                //        }
                //    }
                //    $('mutual').insert(new Element('option', { value: rs.getdata('nro_mutual') }).update(rs.getdata('mutual') + descripcion))
                //    if ((descripcion != '') && (sel == false))
                //        $('mutual').selectedIndex = $('mutual').options.length - 1
                //    i++
                //    rs.movenext()
                //}
                //$('mutual').setStyle({ width: '100%' })

                campos_defs.items['mutual'].rs = rs
                campos_defs.set_first('mutual')

                if (rs.recordcount == 1) campos_defs.habilitar("mutual", false)
                else campos_defs.habilitar("mutual", true)
                }
                rs.open({ filtroXML: nvFW.pageContents["operatoria_mutuales"], params: "<criterio><params nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco_cobro='" + nro_banco_cobro + "' nro_banco='" + nro_banco_filtro + "' /></criterio>" })
            }

            var importe_cuota_social = 0
            var importe_cs_analisis = 0

            function mutual_onchange() {
                var rs_cs = new tRS();
                importe_cuota_social = 0
                importe_cs_analisis = 0

            if (campos_defs.get_value('mutual') == aux_valor_mutual_old) {
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga');
                return
            }

            campos_defs.habilitar("cbAnalisis", true)
            campos_defs.clear_list("cbAnalisis")

            rs_cs.open({ filtroXML: nvFW.pageContents["mutual_cuota"], params: "<criterio><params nro_mutual='" + campos_defs.get_value('mutual') + "' nro_grupo='" + nro_grupo + "' /></criterio>" })
                if (!rs_cs.eof())
                    importe_cuota_social = parseFloat(rs_cs.getdata('importe_cuota_social')).toFixed(2)
                $('strEnMano').innerHTML = ''
                importe_mano = 0
                $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
                importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
                var socio = false
                for (var j in Creditos) {
                if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
                        socio = true
                        break
                    }
                }
                if (!socio) {
                    importe_cs_analisis = parseFloat(importe_cuota_social).toFixed(2)
                    importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)
                }
                var j = 0
                for (var x in Creditos) {
                    if (Creditos[x]['cancela'] == true) {
                        j++
                        Cancelaciones[j]['cancela_cuota'] = Creditos[x]['importe_cuota']
                        Cancelaciones[j]['cancela_cupo'] = 0
                        Cancelaciones[j]['importe_pago'] = Creditos[x]['saldo']
                    }
                }
                $('divHaberes').innerHTML = ""
                $('divHaberesNoVisibles').innerHTML = ""
                $('ifrplanes').src = 'enBlanco.htm'

                $('divAnalisis').show()
                CargarAnalisis(nro_analisis)
            //if ((nro_tipo_cobro == 1) && (tiene_cupo) &&  campos_defs.get_value("mutual") != '') {
            //        $('selplan').checked = true
            //        selplan_on_click()
            //        $('chkmax_disp').checked = true
            //        btnBuscarPLanes_onclick()
            //    }
            aux_valor_mutual_old = campos_defs.get_value("mutual")
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')

            }

            function win_edad_cerrar(aceptar) {
                if (aceptar) {
                    if ($('fe_naci').value == '') {
                        nvFW.alert('Ingrese la fecha de nacimiento.')
                        return
                    }
                }
                btn_aceptar = aceptar
                win_edad.close()
            }

            var win_edad
            var btn_aceptar = false

            function getEdad(dateString) {
                var dia = dateString.substring(0, dateString.indexOf("/"))
                var mes = dateString.substring(dateString.indexOf("/") + 1, dateString.indexOf("/", dateString.indexOf("/") + 1))
                var anio = dateString.substring(dateString.indexOf("/", dateString.indexOf("/") + 1) + 1, dateString.length)
                dateString = mes + "/" + dia + "/" + anio
                var today = new Date();
                var birthDate = new Date(dateString);
                var age = today.getFullYear() - birthDate.getFullYear();
                var m = today.getMonth() - birthDate.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                    age--;
                }
                return age;
            }

            function Validar_datos() {
                if (fe_naci == '') {
                    fe_naci = fe_naci_socio
                    edad = edad_socio
                    $('strFNac').innerHTML = ''
                    $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
                }

                if (fe_naci == '') {
                    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                    win_edad = createWindow2({
                        title: '<b>No se pudo obtener la edad de la persona</b>',
                        parentWidthPercent: 0.8,
                        //parentWidthElement: $("contenedor"),
                        maxWidth: 450,
                        //centerHFromElement: $("contenedor"),
                        minimizable: false,
                        maximizable: false,
                        draggable: false,
                        resizable: true,
                        closable: false,
                        recenterAuto: true,
                        setHeightToContent: true,
                        onClose: function () {
                            fe_naci = $('fe_naci').value
                            edad = getEdad(fe_naci)
                            $('strFNac').innerHTML = ''
                            $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
                        if (btn_aceptar) {
                            if((nro_mutual == '') || (nro_banco == '')) btnBuscarPLanes_onclick()
                        }
                           
                        }
                    });
                    var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
                    html += '<table class="tb1">'
                    html += '<tbody><tr><td class="Tit1"><b>Ingrese la fecha de nacimiento</b></td><td><input type="text" value="" id="fe_naci" style="width:100%" onkeypress="return valDigito(event, \'/\')" onchange="valFecha(event)" /></td></tr>'
                    html += '<tr><td style="text-align:center;width:50%"><br><input type="button" style="width:80%" value="Cancelar" onclick="win_edad_cerrar(false)" style="cursor:pointer" /></td><td style="text-align:center;width:50%"><br><input type="button" style="width:80%" value="Aceptar" onclick="win_edad_cerrar(true)" style="cursor:pointer"/></td></tr>'
                    html += '</tbody></table></body></html>'

                    win_edad.setHTMLContent(html)
                    win_edad.showCenter(true)
                }
                else
                    btnBuscarPLanes_onclick()
            }

            var nro_banco_debito
            var strWhere_planes = ''

            function btnBuscarPLanes_onclick() { 
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                strWhere_planes = ''
            var nro_mutual = campos_defs.get_value('mutual') //$('mutual').value
            var nro_banco =campos_defs.get_value('banco') // $('banco').value
                if ($('selplan').checked) {
                    if ((nro_mutual == '') || (nro_banco == '')) {
                        nvFW.alert('Debe seleccionar un banco/mutual para realizar la búsqueda')
                        return
                    }
                    else {
                        if ((!$('chkmax_disp').checked) && (($('retirado_desde').value == '') && ($('retirado_hasta').value == '') && ($('importe_cuota_desde').value == '') && ($('importe_cuota_hasta').value == '') && ($('cuota_desde').value == '') && ($('cuota_hasta').value == ''))) {
                            nvFW.alert('Ingrese algún filtro para realizar la búsqueda.')
                            return
                        }
                        else {
                            var strTop = ''
                            if ((nro_grupo == 0) || (nro_grupo == 90)) {
                                strWhere_planes += "<nro_sistema type='igual'>" + nro_sistema + "</nro_sistema>"
                                strWhere_planes += "<nro_lote type='igual'>" + nro_lote + "</nro_lote>"
                            }
                            else
                                strWhere_planes += "<nro_grupo type='igual'>" + nro_grupo + "</nro_grupo>"
                            strWhere_planes += "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
                            strWhere_planes += "<nro_banco type='igual'>" + nro_banco + "</nro_banco>"
                            strWhere_planes += "<marca type='igual'>'S'</marca>"
                            strWhere_planes += "<falta type='menos'>getdate()</falta>"
                            strWhere_planes += "<fbaja type='sql'>(fbaja > getdate() or fbaja is null)</fbaja>"
                            strWhere_planes += "<vigente type='igual'>1</vigente>"
                            strWhere_planes += "<nro_tabla_tipo type='igual'>1</nro_tabla_tipo>"

                            var campo_max
                            var campo_min
                            if (sexo == 'M') {
                                campo_max = 'edad_max_masc'
                                campo_min = 'edad_min_masc'
                            }
                            else {
                                campo_max = 'edad_max_fem'
                                campo_min = 'edad_min_fem'
                            }

                            strWhere_planes += "<sql type='sql'><![CDATA[datediff(year," + ajustarFecha(fe_naci) + ", getdate()) >= " + campo_min + "]]></sql>"

                            strWhere_planes += "<sql type='sql'><![CDATA[datediff(year, " + ajustarFecha(fe_naci) + ", dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) <= " + campo_max + "]]></sql>"

                            var maxImporte = TotalCancelaciones1

                            if (!$('chkFiltroCuenta').checked) {
                                if (nro_banco_debito != undefined)
                                    strWhere_planes += "<sql type='sql'><![CDATA[((nro_tipo_cobro = 4 and nro_banco_debito = " + nro_banco_debito + ") or (nro_tipo_cobro <> 4))]]></sql>"
                            }

                            if (!$('chkFiltroBCRA').checked) {
                                if (sit_bcra != undefined)
                                    strWhere_planes += "<sql type='sql'><![CDATA[((sitbcra_max is null) or (" + sit_bcra + " between sitbcra_min and sitbcra_max))]]></sql>"
                            }

                            strWhere_planes += "<sql type='sql'><![CDATA[((nro_tipo_cobro in (1,4) and (cod_prov = " + cod_prov_persona + " or cod_prov is null)) or (nro_tipo_cobro not in (1,4)) )]]></sql>"

                            strWhere_planes += "<sql type='sql'>nro_comercio is null</sql>"

                            if ($('chkmax_disp').checked) {
                                var strIn = '(Select max(importe_cuota) from planes where planes.nroTabla = verPlanes_lotes_v4.nroTabla and planes.importe_cuota <= ' + importe_max_cuota + ')'
                                strWhere_planes += "<importe_cuota type='igual'><![CDATA[" + strIn + "]]></importe_cuota>"
                                strWhere_planes += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
                            }
                            else {
                                strWhere_planes += "<importe_cuota type='menos'>" + importe_max_cuota + "</importe_cuota>"
                                if ($('retirado_desde').value != "")
                                    if (parseFloat($('retirado_desde').value) > parseFloat(TotalCancelaciones1))
                                        maxImporte = $('retirado_desde').value
                                    
                                    strWhere_planes += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
                                
                                    if (tiene_seguro == 1)
                                        strWhere_planes += "<sql type='sql'>importe_neto >= dbo.piz4D_money ('monto_seguro',nro_banco,nro_mutual,nro_grupo,importe_bruto)</sql>"
                                    
                                        
                                    if ($('retirado_hasta').value != '')
                                        strWhere_planes += "<importe_neto type='menos'>" + $('retirado_hasta').value + "</importe_neto>"
                                    if ($('importe_cuota_desde').value != '')
                                        strWhere_planes += "<importe_cuota type='mas'>" + $('importe_cuota_desde').value + "</importe_cuota>"
                                    if ($('importe_cuota_hasta').value != '')
                                        strWhere_planes += "<importe_cuota type='menos'>" + $('importe_cuota_hasta').value + "</importe_cuota>"
                                    if ($('cuota_desde').value != '')
                                        strWhere_planes += "<cuotas type='mas'>" + $('cuota_desde').value + "</cuotas>"
                                    if ($('cuota_hasta').value != '')
                                        strWhere_planes += "<cuotas type='menos'>" + $('cuota_hasta').value + "</cuotas>"
                                }

                                var nro_tipo_cobro = campos_defs.get_value('nro_tipo_cobro_precarga')
                                if (nro_tipo_cobro != "")
                                    strWhere_planes += "<nro_tipo_cobro type='in'>" + nro_tipo_cobro + "</nro_tipo_cobro>"

                                var operador = nvFW.pageContents["operador"]

                                //strWhere_planes += "<nroTabla type='sql'>dbo.rm_tabla_permiso_estructura (" + nro_operador + ",nroTabla) = 1</nroTabla>"
                                //strWhere_planes += "<socio type='sql'>dbo.rm_tabla_socio_nuevo (nroTabla," + nro_docu + "," + tipo_docu + ",'" + sexo + "') = 1</socio>"

//                                if ((nro_tipo_cobro != "") && (nro_tipo_cobro == 1))
//                                    strWhere_planes += "<nro_tipo_cobro type='in'>1,5</nro_tipo_cobro>"
//                                else
//                                    strWhere_planes += "<nro_tipo_cobro type='in'>" + nro_tipo_cobro + "</nro_tipo_cobro>"
                            
                                var filtroXML = nvFW.pageContents.planes_lotes
                                var params = "<criterio><params fe_naci='" + fe_naci + "' tiene_seguro='" + tiene_seguro + "' /></criterio>"
                                nvFW.exportarReporte({
                                    filtroXML: filtroXML,
                                    filtroWhere: "<criterio><select><filtro>" + strWhere_planes + "</filtro></select></criterio>",
                                    params: params,
                                    path_xsl: 'report/verPlanes_lotes/lst_planes_precarga_HTML.xsl',
                                    formTarget: 'ifrplanes',
                                    async: true,
                                    bloq_contenedor: $(document.documentElement),
                                    bloq_msg: 'Buscando planes...',
                                    funComplete: function (e) {
                                try {
                                        var tbCabe_h = $('ifrplanes').contentWindow.document.getElementById('tbCabe').getHeight()
                                        var div_lst_creditos_h = $('ifrplanes').contentWindow.document.getElementById('div_lst_creditos').getHeight()
                                        var div_pag_h = $('ifrplanes').contentWindow.document.getElementById('div_pag').getHeight()
                                        $('ifrplanes').setStyle({ height: tbCabe_h + div_lst_creditos_h + div_pag_h + 25 + 'px' })
                                } catch (e){ }
                                    },
                                    nvFW_mantener_origen: true
                                })
                            }

                        }
                    }
                }

                var importe_neto = 0
                var gastoscomerc = 0
                var importe_mano = 0

                function btnSelPlan_onclick(nro_plan, importe_neto1, importe_bruto, cuotas, importe_cuota, plan_banco, nro_tipo_cobro, gastoscomerc) {
                    importe_neto = importe_neto1
                    gastoscomerc = gastoscomerc
                    importe_mano = importe_neto1 - gastoscomerc - TotalCancelaciones1
                    $('strEnMano').innerHTML = ''
                    $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
                }

                function chkmax_disp_on_click() {
                    if ($('chkmax_disp').checked) {
                        $('divFiltrosLeft').hide()
                        $('divFiltrosRight').hide()
                        $('divFiltros2Left').hide()
                        $('divFiltros2Right').hide()
                        $('divFiltros3Left').hide()
                        $('divFiltros3Right').hide()
                    }
                    else {
                        $('divFiltrosLeft').show()
                        $('divFiltrosRight').show()
                        $('divFiltros2Left').show()
                        $('divFiltros2Right').show()
                        $('divFiltros3Left').show()
                        $('divFiltros3Right').show()
                    }
                }

                function selplan_on_click() {
                    if ($('selplan').checked) {
                        $('ifrplanes').show()
                        $('tbfiltros').show()
                $('chkmax_disp').checked = true
                        $('divFiltrosLeft').show()
                        $('divFiltrosRight').show()
                        $('divFiltros2Left').show()
                        $('divFiltros2Right').show()
                        $('divFiltros3Left').show()
                        $('divFiltros3Right').show()
                    }
                    else {
                        $('ifrplanes').hide()
                        $('tbfiltros').hide()
                    }
                }

                var win_creditos

                function VerCreditos(modo) {
                    var filtros = {}
                    filtros['modo'] = modo
                    filtros['nro_vendedor'] = nro_vendedor
                    filtros['nro_docu'] = nro_docu
                    filtros['BodyWidth'] = BodyWidth
                    if (modo == 'V')
                        if (nro_vendedor == 0) {
                            nvFW.alert('Debe seleccionar un vendedor para realizar la consulta.')
                            return
                        }
                    win_creditos = createWindow2({
                        url: 'Precarga_solicitud_creditos.aspx?nro_vendedor=' + nro_vendedor,  
                        title: '<b>Créditos</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        resizable: true
                    });
                    win_creditos.options.userData = { filtros: filtros }
                    win_creditos.showCenter(true)

            if (isMobile())
            mostrarMenuIzquierdo()
                }

                var nro_plan_sel = 0

                function btnStatus(progress) {
                    if (progress) {
                        document.getElementById('btn1').onclick = null
                        document.getElementById('btn1').style.cursor = 'progress'
                        document.getElementById('img1').style.cursor = 'progress'
                        document.getElementById('btn2').onclick = null
                        document.getElementById('btn2').style.cursor = 'progress'
                        document.getElementById('img2').style.cursor = 'progress'
                        document.getElementById('btn3').onclick = null
                        document.getElementById('btn3').style.cursor = 'progress'
                        document.getElementById('img3').style.cursor = 'progress'
                    }
                    else {
                        document.getElementById('btn1').onclick = function () { GuardarSolicitud('P') }
                        document.getElementById('btn1').style.cursor = 'pointer'
                        document.getElementById('img1').style.cursor = 'pointer'
                        document.getElementById('btn2').onclick = function () { GuardarSolicitud('H') }
                        document.getElementById('btn2').style.cursor = 'pointer'
                        document.getElementById('img2').style.cursor = 'pointer'
                        document.getElementById('btn3').onclick = function () { Precarga_Limpiar() }
                        document.getElementById('btn3').style.cursor = 'pointer'
                        document.getElementById('img3').style.cursor = 'pointer'
                    }
                }



                function GuardarSolicitud(estado) {
                    
            var nro_mutual = campos_defs.get_value('mutual')// $('mutual').value
            var nro_banco = campos_defs.get_value('banco') //$('banco').value
            
            if(inaes_black_list(nro_banco)){
                alert("Persona bloqueada para alta en voii. Seleccione otro Banco")
                return
            }
            var nro_analisis = campos_defs.get_value("cbAnalisis") // $('cbAnalisis').value
                    if ((nro_mutual == '') || (nro_banco == '') || (nro_analisis == '')) {
                        nvFW.alert('Debe seleccionar un banco/mutual/análisis para guardar el crédito')
                        return
                    }
                    btnStatus(true)
                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Guardando crédito...')
                    var modo = 'S'
                    nro_plan_sel = 0
                    if ($('selplan').checked) {
                        try {
                            var iframe = $('ifrplanes');
                            var radioGrp = iframe.contentDocument.forms.frmplanes.rdplan
                            if (radioGrp.length == undefined)
                                if (iframe.contentDocument.forms.frmplanes.rdplan.checked)
                                    nro_plan_sel = iframe.contentDocument.forms.frmplanes.rdplan.value
                                for (i = 0; i < radioGrp.length; i++) {
                                    if (radioGrp[i].checked == true)
                                        nro_plan_sel = radioGrp[i].value
                                }
                            }
                            catch (e) { nro_plan_sel = 0 }

                            strWhere_planes = ''
                var nro_mutual = campos_defs.get_value('mutual') //$('mutual').value
                var nro_banco = campos_defs.get_value('banco') //$('banco').value
                            if ((nro_grupo == 0) || (nro_grupo == 90)) {
                                strWhere_planes += "<nro_sistema type='igual'>" + nro_sistema + "</nro_sistema>"
                                strWhere_planes += "<nro_lote type='igual'>" + nro_lote + "</nro_lote>"
                                }
                            else
                                strWhere_planes += "<nro_grupo type='igual'>" + nro_grupo + "</nro_grupo>"
                            strWhere_planes += "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
                            strWhere_planes += "<nro_banco type='igual'>" + nro_banco + "</nro_banco>"
                            strWhere_planes += "<marca type='igual'>'S'</marca>"
                            strWhere_planes += "<falta type='menos'>getdate()</falta>"
                            strWhere_planes += "<fbaja type='sql'>(fbaja > getdate() or fbaja is null)</fbaja>"
                            strWhere_planes += "<vigente type='igual'>1</vigente>"
                            strWhere_planes += "<nro_tabla_tipo type='igual'>1</nro_tabla_tipo>"
                            var campo_max
                            var campo_min
                            if (sexo == 'M') {
                                campo_max = 'edad_max_masc'
                                campo_min = 'edad_min_masc'
                            }
                            else {
                                campo_max = 'edad_max_fem'
                                campo_min = 'edad_min_fem'
                            }

                            strWhere_planes += "<sql type='sql'><![CDATA[datediff(year," + ajustarFecha(fe_naci) + ", getdate()) >= " + campo_min + "]]></sql>"
                            strWhere_planes += "<sql type='sql'><![CDATA[datediff(year, " + ajustarFecha(fe_naci) + ", dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) <= " + campo_max + "]]></sql>"
                            var maxImporte = TotalCancelaciones1

                            if (!$('chkFiltroCuenta').checked) {
                                if (nro_banco_debito != undefined)
                                    strWhere_planes += "<sql type='sql'><![CDATA[((nro_tipo_cobro = 4 and nro_banco_debito = " + nro_banco_debito + ") or (nro_tipo_cobro <> 4))]]></sql>"
                            }

                            if (!$('chkFiltroBCRA').checked) {
                                if (sit_bcra != undefined)
                                    strWhere_planes += "<sql type='sql'><![CDATA[((sitbcra_max is null) or (" + sit_bcra + " between sitbcra_min and sitbcra_max))]]></sql>"
                            }

                            strWhere_planes += "<sql type='sql'><![CDATA[((nro_tipo_cobro in (1,4) and (cod_prov = " + cod_prov_persona + " or cod_prov is null)) or (nro_tipo_cobro not in (1,4)) )]]></sql>"
                            strWhere_planes += "<nro_plan type='igual'>" + nro_plan_sel + "</nro_plan>"
                            strWhere_planes += "<importe_cuota type='menos'>" + importe_max_cuota + "</importe_cuota>"
                            strWhere_planes += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
//                            if (nro_tipo_cobro == 1)
//                                strWhere_planes += "<nro_tipo_cobro type='in'>1,5</nro_tipo_cobro>"
//                            else
                            strWhere_planes += "<nro_tipo_cobro type='in'>" + nro_tipo_cobro + "</nro_tipo_cobro>"
                            var rs = new tRS();
                            rs.open({ filtroXML: nvFW.pageContents.planes_lotes, filtroWhere: "<criterio><select><filtro>" + strWhere_planes + "</filtro></select></criterio>", params: "<criterio><params fe_naci='" + fe_naci + "' tiene_seguro='" + tiene_seguro + "' /></criterio>" })
                            if (rs.eof()) {
                                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                                nvFW.alert('<b>El plan seleccionado es incorrecto.</b><br>Vuelva a realizar la búsqueda de planes y seleccione nuevamente.')
                                btnStatus(false)
                                return
                            }
                        }
                        else
                            nro_plan_sel = -1

                        if (nro_plan_sel != 0) {
                            /* XML Persona  */
                            var xmlpersona = ""
                            xmlpersona = "<?xml version='1.0' encoding='iso-8859-1'?>"
                            xmlpersona += "<persona nro_docu='" + nro_docu_db + "' tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' cuit='" + cuit + "' fe_naci='" + fe_naci + "' razon_social='" + razon_social.trim() + "' "
                            xmlpersona += "domicilio='" + domicilio + "' CP='" + CP + "' localidad='" + localidad + "' provincia='" + provincia + "' cod_prov='" + cod_prov_persona + "'></persona>"
                            /* XML Trabajo */
                            var xmltrabajo = ""
                            xmltrabajo = "<?xml version='1.0' encoding='iso-8859-1'?><trabajo nro_sistema='" + nro_sistema + "' nro_lote='" + nro_lote + "' clave_sueldo='" + clave_sueldo + "' nro_grupo='" + nro_grupo + "'></trabajo>"
                            /* XML Credito */
                            var xmlcredito = ""
                            xmlcredito = "<?xml version='1.0' encoding='iso-8859-1'?><credito estado='" + estado + "' nro_vendedor='" + nro_vendedor + "' nro_plan='" + nro_plan_sel + "' nro_banco='" + nro_banco + "' nro_mutual='" + nro_mutual + "' nro_analisis='" + nro_analisis + "' nro_tipo_cobro='" + nro_tipo_cobro + "' ></credito>"
                            /* XML Analisis */
                            var xmlanalisis = ""
                            var Etiqueta
                            xmlanalisis = "<Analisis nro_analisis='" + nro_analisis + "'>"
                            for (var i in Etiquetas) {
                                Etiqueta = Etiquetas[i]
                                xmlanalisis += "<Etiqueta nro_etiqueta='" + Etiqueta["nro_etiqueta"] + "' orden='" + Etiqueta['orden'] + "' tipo_dato='" + Etiqueta['tipo_dato'] + "'>"
                                xmlanalisis += "<valor>"
                                switch (Etiqueta['tipo_dato']) {
                                    case 'B':
                                        xmlanalisis += $('nuevo_monto' + i).checked == true ? '1' : '0'
                                        break
                                    default:
                                        xmlanalisis += $('nuevo_monto' + i).value
                                }
                                xmlanalisis += "</valor>"
                                xmlanalisis += "</Etiqueta>"
                            }
                            xmlanalisis += "</Analisis>"

                            /* XML Cancelaciones */
                            var xmlcancelaciones = ""
                            xmlcancelaciones = "<?xml version='1.0' encoding='iso-8859-1'?><cancelaciones>"
                            for (var x in Creditos) {
                                if (Creditos[x]['cancela'] == true) {
                                    var nro_credito_calc = (Creditos[x]['nro_calc_tipo'] == 4) ? Creditos[x]['nro_credito_seguro'] : Creditos[x]['nro_credito']
                                    xmlcancelaciones += "<cancelacion importe_pago='" + Creditos[x]['saldo'] + "' nro_entidad_destino='" + Creditos[x]['saldo_nro_entidad'] + "' cancela_cuota='" + Creditos[x]['importe_cuota'] + "' cancela_vence='" + Creditos[x]['cancela_vence'] + "' cancela_nro_credito='" + nro_credito_calc + "' cancela_cuota_paga='" + Creditos[x]['cancela_cuota_paga'] + "' nro_pago_concepto='" + Creditos[x]['nro_pago_concepto'] + "' />"
                                }
                            }
                            xmlcancelaciones += "</cancelaciones>"
                            /* XML Parametros */
                            var xmlparametros = ""
                            xmlparametros = "<?xml version='1.0' encoding='iso-8859-1'?><parametros>"
                            var rs = new tRS();
                            rs.open({ filtroXML: nvFW.pageContents["planes_parametros"], params: "<criterio><params nro_plan='" + nro_plan_sel + "' /></criterio>" })
                            while (!rs.eof()) {
                                xmlparametros += "<parametro nombre='" + rs.getdata('parametro') + "' valor='" + rs.getdata('valor_defecto') + "' />"
                                rs.movenext()
                            }
                            xmlparametros += "</parametros>"
                            var nro_credito = 0
                            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                            nvFW.error_ajax_request('Default.aspx', {
                                parameters: { modo: modo, estado: estado, nro_credito: nro_credito, persona_existe: persona_existe, noti_prov: noti_prov, nro_archivo_noti_prov: nro_archivo_noti_prov, xmlpersona: xmlpersona, xmltrabajo: xmltrabajo, xmlcredito: xmlcredito, xmlanalisis: xmlanalisis, xmlcancelaciones: xmlcancelaciones, xmlparametros: xmlparametros, NosisXML: NosisXML },
                                bloq_msg: 'Guardando crédito...',
                                onSuccess: function (err, transport) {
                                    if (err.numError == 0)
                                        Precarga_Limpiar(err.params.nro_credito)
                                    else
                                        nvFW.alert('Error al guardar el crédito.<br>' + err.numError + ' : ' + err.mensaje)
                                }
                            });
                        }
                        else {
                            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                            btnStatus(false)
                            nvFW.alert('Seleccione un plan')
                        }

                    }

                    var cambioDeWidth = 1;
                    function window_onresize_movil() {

                        $("divEspacioBotonera").show();
                        $("imgMenu").show();
                        $("imgMenuDerecho").hide(); //va show 

                        menuIzquierdoVisible = false;

                        /* if (!vMenuRight.functionMobile) {
                        $("imgMenuDerecho").hide();
                        }*/

                        $("menu_left_vidrio").show();
                        $("menu_right_vidrio").show();

                        $("user_sucursal").hide();
                        $("br1").hide();
                        $("br2").hide();

                        if ($("logo").data != 'image/nova-aux.svg') {
                            $("logo").data = 'image/nova-aux.svg'
                            if (calcularScrollEvent == "top") {
                                $("logo").setStyle({ height: "50px", width: "150px" })
                            }
                            else {
                                $("logo").setStyle({ height: "40px", width: "125px" })
                            }
                        }

                        $(vMenuLeft.canvasMobile).style.position = "fixed";
                        $(vMenuLeft.canvasMobile).style.width = tamanio.div_left.width + "%"
                        $(vMenuLeft.canvasMobile).style.height = tamanio.div_left.height + "px"

                        $(vMenuLeft.canvasMobile).style.marginTop = "0px";

                        $("menu_left_vidrio").style.width = tamanio.div_left_vidrio.width + "%"
                        $("menu_left_vidrio").style.height = tamanio.div_left_vidrio.height + "px"

                        $("menu_right_vidrio").style.width = tamanio.div_left_vidrio.width + "%"
                        $("menu_right_vidrio").style.height = tamanio.div_left_vidrio.height + "px"

                        $$("BODY")[0].setStyle({ overflowy: "auto", width: "99.9%", float: "none" })

                        $("top_menu").style.position = "fixed"

                        vMenuLeft.resize(true)

                        if (!vMenuLeft.clasicMenu) {
                            $(vMenuLeft.canvasMobile).children[0].rows[0].show()
                        }

                        $$("BODY")[0].style.marginTop = "0px"

                        $(vMenuLeft.canvasMobile).style.left = "-540px"
                        $(vMenuLeft.canvasMobile).style.top = $("top_menu").getHeight() + "px"
                        $(vMenuLeft.canvasMobile).style.transition = "all 0.3s";

           // $("tbButtons").style.width = $$("BODY")[0].getWidth()  + "px"
                        $("tbButtons").style.position = "fixed"

                        $("divVendedor").style.width = "100%"
                        $("divVendedor").style.marginTop = "50px"
                        $("divSelTrabajo").style.width = "100%"
                        $("divDatosPersonales").style.width = "100%"
                        $("divGrupo").style.width = "100%"
                        $("divSocio").style.width = "100%"
                        $("divProducto").style.width = "100%"
                        $("divAnalisis").style.width = "100%"
                        $("divFiltros").style.width = "100%"
            $("tbButtons").style.width = "98%"

                        $("div_padding_left").style.width = "0px"
                        //$$("body")[0].style.paddingLeft = "0px"

                        $("divVendedor").style.marginLeft = "0px"
                        $("divSelTrabajo").style.marginLeft = "0px"
                        $("divDatosPersonales").style.marginLeft = "0px"
                        $("divGrupo").style.marginLeft = "0px"
                        $("divSocio").style.marginLeft = "0px"
                        $("divProducto").style.marginLeft = "0px"
                        $("divAnalisis").style.marginLeft = "0px"
                        $("divFiltros").style.marginLeft = "0px"
                        $("tbButtons").style.marginLeft = "0px"

                        $("top_menu").style.left = "0px"
                    }

                    function window_onresize_desktop() {



                        $("divEspacioBotonera").hide();

                        $("div_padding_left").style.width = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"
                        //$$("body")[0].style.paddingLeft = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"


                        $("top_menu").setStyle({ opacity: 1 })

                        $(vMenuLeft.canvasMobile).style.transition = "";

                        $("imgMenu").hide();
            //$("imgMenuDerecho").hide();

                        $("menu_left_vidrio").hide();

                        $("br1").show();
                        $("br2").show();
                        $("user_sucursal").show();

                        if ($("logo").data != 'image/nova.svg') {
                            $("logo").data = 'image/nova.svg'
                            $("logo").setStyle({ height: "90px", width: "215px" })
                        }

                        $(vMenuLeft.canvasMobile).style.position = "fixed";
                        $(vMenuLeft.canvasMobile).style.width = "200px"
                        $(vMenuLeft.canvasMobile).style.height = "100%"
                        $(vMenuLeft.canvasMobile).style.marginTop = "102px"
                        $(vMenuLeft.canvasMobile).style.top = "0px"
                        //$(vMenuLeft.canvasMobile).style.left = "initial"

                        //vMenuRight.resize(false)
                        vMenuLeft.resize(false)
                        /*
                        if (vMenuRight.clasicMenu) {
                        $(vMenuRight.canvas).style.width = "100%"
                        $(vMenuRight.canvas).style.float = "none"
                        $(vMenuRight.canvas).style.marginTop = "0px"
                        $(vMenuRight.canvas).style.top = "0px"
                        $(vMenuRight.canvas).style.position = "initial"
                        }*/

            //if (!vMenuLeft.clasicMenu) {
            //    $(vMenuLeft.canvasMobile).children[0].rows[0].hide()
            //}

                        $("menu_right_vidrio").hide();

           // $$("BODY")[0].setStyle({ overflowy: "auto", width: tamanio.div_top_body.width /* + (window.innerWidth - tamanio.div_top_body.width) / 2*/ + "px" })

                        $$("BODY")[0].style.marginTop = "0px";
                        $("top_menu").style.position = "fixed"
                        $("top_menu").style.left = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"
                        $(vMenuLeft.canvasMobile).style.left = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"

                        $(vMenuLeft.canvasMobile).style.float = "left"

                        $$("BODY")[0].style.float = "left"

                        $("top_menu").setStyle({ width: tamanio.div_top_menu.width + "px", height: tamanio.div_top_menu.height + "px" })

                        $("tbButtons").style.width = ($$("BODY")[0].getWidth() - 16) + "px"
            //$("tbButtons").style.position = "relative"

                        $("divVendedor").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("divVendedor").style.marginTop = "102px"
                        $("divSelTrabajo").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("divDatosPersonales").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("divGrupo").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("divSocio").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("divProducto").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("divAnalisis").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("divFiltros").style.width = ($("top_menu").getWidth() - 200) + "px"
                        $("tbButtons").style.width = ($("top_menu").getWidth() - 200) + "px"

                        $("divVendedor").style.marginLeft = "200px"
                        $("divSelTrabajo").style.marginLeft = "200px"
                        $("divDatosPersonales").style.marginLeft = "200px"
                        $("divGrupo").style.marginLeft = "200px"
                        $("divSocio").style.marginLeft = "200px"
                        $("divProducto").style.marginLeft = "200px"
                        $("divAnalisis").style.marginLeft = "200px"
                        $("divFiltros").style.marginLeft = "200px"
                        $("tbButtons").style.marginLeft = 200 + (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"
                    }

                    var tamanio

                    function window_onresize() {
                        try {

                            //ejecutar onresize solo si hubo un cambio de width
                            if (document.documentElement.clientWidth == cambioDeWidth) return
                            cambioDeWidth = document.documentElement.clientWidth

                            //setear tamaño de componentes
                            tamanio = nvtWinDefault()

                            //evitar mostrar mnostrar el vidrio simulando una accion
                            window.top.nvSesion.usuario_accion()

                            //$("contenedor").setStyle({ overflowy: "auto", height: tamanio.div_top_body.height + "px", width: tamanio.div_top_body.width + "px" })

                            $("top_menu").style.width = tamanio.div_top_menu.width + "px"
                            $("top_menu").style.height = tamanio.div_top_menu.height + "px"

                            if (!tamanio.ocultarMenu) {
                                window_onresize_desktop()
                            }
                            else {
                                window_onresize_movil()
                            }

                            $(vMenuLeft.canvasMobile).style.borderRight = "3px solid #E3E0E3"
                            // $(vMenuRight.canvasMobile).style.borderLeft = "3px solid #E3E0E3"
                        }
                        catch (e) { }
                    }

                    /*En otro caso la funcion nombre_del_menu.scroll_event(this) debe ser invocada como un evento oncroll desde el elemento que se scrollea*/
                    var calcularScrollEvent = "top";
                    function scroll_event(e) {

                        if (bloquearSlideVertical < 1) {
                        }
                        else {
                            window.scrollTo(0, 0);
                            return
                        }


                        if (tamanio.ocultarMenu) {
                            if ($$("BODY")[0].parentElement.scrollTop > 1) {
                                if (calcularScrollEvent == "top") {
                                    calcularScrollEvent = "not_top"

                                    /*  if (!vMenuRight.functionMobile) {
                                    $(vMenuRight.canvas).style.top = "44px"
                                    $(vMenuRight.canvas).style.transition = "all 0.3s";
                                    $(vMenuRight.canvas).style.borderBottom = "3px solid #E3E0E3;"
                                    }*/
                                    $(vMenuLeft.canvasMobile).style.top = "44px"
                                    $("top_menu").setStyle({ height: "40px", opacity: 0.9 })

                                    $("logo").setStyle({ width: "125px", height: "40px", top: "0px" })
                                    $("imgbloqueo_sesion").setStyle({ height: "24px", width: "24px" })
                                    $("imgbutton_sesion").setStyle({ height: "24px", width: "24px" })
                        $("img_Menu").setStyle({ height: "24px", width: "24px" })
                                }
                            } else {
                                if (calcularScrollEvent == "not_top") {
                                    calcularScrollEvent = "top"

                                    $(vMenuLeft.canvasMobile).style.top = "50px"
                                    /*
                                    if (!vMenuRight.functionMobile) {
                                    $(vMenuRight.canvas).style.top = "50px"
                                    $(vMenuRight.canvas).style.transition = "all 0.3s";
                                    $(vMenuRight.canvas).style.borderBottom = "3px solid #E3E0E3;"
                                    }
                                    */
                                    $("top_menu").setStyle({ height: "50px", opacity: 1 })

                                    $("logo").setStyle({ width: "150px", height: "50px", top: "0px" })
                                    $("imgbloqueo_sesion").setStyle({ height: "32px", width: "32px" })
                                    $("imgbutton_sesion").setStyle({ height: "32px", width: "32px" })
                         $("img_Menu").setStyle({ height: "32px", width: "32px" })
                                }
                            }
                        }

                    }


                    function mostrarMenuIzquierdoSwipe(elemento, direccion) {
                        if (elemento === "body" && !menuIzquierdoVisible && direccion === "derecha")
                            mostrarMenuIzquierdo()
                        if ((elemento === (vMenuLeft.canvasMobile) || elemento === ("menu_left_vidrio")) && direccion === "izquierda")
                            mostrarMenuIzquierdo()
                    }

                    function mostrarMenuDerechoSwipe(elemento, direccion) {
                        if (elemento === "body" && !menuDerechoVisible && direccion === "izquierda")
                            mostrarMenuDerecho()
                        if ((elemento === (vMenuRight.canvasMobile) || elemento === ("menu_right_vidrio")) && direccion === "derecha")
                            mostrarMenuDerecho()
                    }

                    function detectSwipe(elemento, funcion, inicial) {

                        deteccion_swipe = {};
                        deteccion_swipe.sX = 0; deteccion_swipe.sY = 0; deteccion_swipe.eX = 0; deteccion_swipe.eY = 0; deteccion_swipe.cX = 0

                        var min_x = 50;  //min x swipe para swipe horizontal 
                        var max_y = 60;  //max y para swipe horizontal 

                        var direccion = "";
                        ele = elemento;

                        ele.addEventListener('touchstart', function (e) {
                            var t = e.touches[0];
                            deteccion_swipe.sX = t.screenX;
                            deteccion_swipe.sY = t.screenY;
                            deteccion_swipe.cX = t.clientX;

                        }, false);

                        ele.addEventListener('touchmove', function (e) {

                            //e.preventDefault()

                //window.scrollTo(window.scrollX, window.scrollY);
                            var t = e.touches[0];
                            deteccion_swipe.eX = t.screenX;
                            deteccion_swipe.eY = t.screenY;

                            //e.cancelBubble = true
                        }, { passive: false });

                        ele.addEventListener('touchend', function (e) {
                //e.preventDefault()
                            if ((((deteccion_swipe.eX - min_x > deteccion_swipe.sX) || (deteccion_swipe.eX + min_x < deteccion_swipe.sX)) && ((deteccion_swipe.eY < deteccion_swipe.sY + max_y) && (deteccion_swipe.sY > deteccion_swipe.eY - max_y) && (deteccion_swipe.eX > 0)))) {
                                if (deteccion_swipe.eX > deteccion_swipe.sX) direccion = "derecha";
                                else direccion = "izquierda";
                            }

                            if (funcion === "colapsar") {

                                if (menuDerechoVisible && direccion === "derecha") {
                                    //mostrarMenuDerecho()
                                }
                                else if (menuIzquierdoVisible && direccion === "izquierda") {
                                    mostrarMenuIzquierdo()
                                }
                            }
                            else if (direccion == "izquierda" && funcion === "mostrar") {
                                if (inicial && (($$("body")[0].getWidth() - inicial) < deteccion_swipe.cX)) {
                                    //mostrarMenuDerechoSwipe(elemento.id, direccion);
                                }
                            }
                            else if (direccion == "derecha" && funcion === "mostrar") {
                                if (inicial && (deteccion_swipe.cX < inicial))
                                    mostrarMenuIzquierdoSwipe(elemento.id, direccion);
                            }
                            direccion = "";
                            deteccion_swipe.sX = 0; deteccion_swipe.sY = 0; deteccion_swipe.eX = 0; deteccion_swipe.eY = 0;
                        }, false);
                    }

                    var menuIzquierdoVisible = false;
                    function mostrarMenuIzquierdo() {
            //if (document.activeElement.name != undefined) {
            //    ; $(document.activeElement.name).blur()
            //} //quitar el focus para ocultar el teclado mobile y el menu se muestre completo

          //  $('nro_docu').focus()
            
                        menuIzquierdoVisible = !menuIzquierdoVisible
           // $(vMenuLeft.canvasMobile).style.height = ($$("body")[0].getHeight() + 60 - $("top_menu").getHeight()) + "px";
                        $(vMenuLeft.canvasMobile).style.zIndex = "1"

                        $("menu_left_vidrio").style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";

                        if (!menuIzquierdoVisible) {
                            $(vMenuLeft.canvasMobile).style.left = "-540px";
                            $("menu_left_vidrio").style.right = "-540px";
                        }
                        else {
                            /*if (menuDerechoVisible) {
                            mostrarMenuDerecho();
                            }*/
                            $(vMenuLeft.canvasMobile).style.left = "0px";

                            $("menu_left_vidrio").style.right = "0px";
                        }
            $(vMenuLeft.canvasMobile).style.height = '100%';
                    }

                    var menuDerechoVisible = false;
                    function mostrarMenuDerecho() {
                        menuDerechoVisible = !menuDerechoVisible
                        $(vMenuRight.canvasMobile).style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";
                        $("menu_right_vidrio").style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";

                        if (!menuDerechoVisible) {
                            $(vMenuRight.canvasMobile).style.right = "-540px";
                            $("menu_right_vidrio").style.left = "-540px";
                        }
                        else {
                            if (menuIzquierdoVisible) {
                                mostrarMenuIzquierdo();
                            }

                            $(vMenuRight.canvasMobile).style.right = "0px";
                            $("menu_right_vidrio").style.left = "0px";
                        }
                    }

        function establecerFuncionBack(event) {

            /* var isSafari = /constructor/i.test(window.HTMLElement) || (function (p) { return p.toString() === "[object SafariRemoteNotification]"; })(!window['safari'] || (typeof safari !== 'undefined' && safari.pushNotification));
             if (isSafari) {
                 history.pushState({}, '', '');
                 return;
             }*/

                        if (window.top.Windows.modalWindows.length > 0) {
                            window.top.Windows.focusedWindow.close()
                            history.pushState(null, document.title, location.href);

                if (window.top.Windows.focusedWindow && window.top.Windows.focusedWindow.callback_onresize)
                                window.top.Windows.focusedWindow.callback_onresize()
                            }
                        else {
                            if (menuIzquierdoVisible) {
                                mostrarMenuIzquierdo()
                                history.pushState(null, document.title, location.href);
                            }
                            else if (menuDerechoVisible) {
                                mostrarMenuDerecho()
                                history.pushState(null, document.title, location.href);
                            }
                            else {
                                var vent = confirm("¿Desea salir?, Verifique haber guardado los cambios.")
                                vent.okCallback = function () {
                                    if (nvFW.nvInterOP) {
                                        nvFW.nvInterOP.sendMessage('close_app', '')
                        }
                        else {
                                        window.removeEventListener('popstate', establecerFuncionBack);
                                        history.back();
                                    }

                                vent.cancelCallback = function () {
                                    history.pushState(null, document.title, location.href);
                                }
                            }
                        }
                    }


                    history.pushState(null, document.title, location.href);
                    window.addEventListener('popstate', establecerFuncionBack);
 }
                    /*
                    if (nvFW.nvInterOP) {
                    function abrirChat() {
                    nvFW.nvInterOP.openChatRoom();
                    }
        
                    nvFW.nvInterOP.sendMessage("login", "<action><params user='prueba_xmpp' password='1234562' token='' cod_app='cod_app' cod_implement='AABC10F' /></action>")
                    nvFW.nvInterOP.receiveMessageHandler = function (action, params) {
                    if (action == 'is_alive') {
                    nvFW.nvInterOP.sendMessage('is_alive', 'true')
                    return;
                    }
        
        
                    if (action == 'BackPressed') {
        
                    establecerFuncionBack()
        
                    nvFW.nvInterOP.sendMessage('BackPressed', 'true') // le respondo al esqueleto que ya me hice cargo del back
                    //nvFW.nvInterOP.sendMessage('BackPressed','false') //le respondo al esqueleto que manda la app al backgroun
                    return;
                    }
        
                    if (action == 'MessageReceived') {
                    alert('Notificacion Recibida')
                    console.log('Notificaci—n recibida.')
                    }
                    }
                    }
                    */
        
                    function Btn_cancelaciones_onclick(objeto) {
                        var nombre1 = (objeto) ? objeto.id : 'td_canc_int'
            $(nombre1).setStyle({ width: "30%", color: "#404040", cursor: "auto", textDecoration: "none" })
                        var nombre = (nombre1 == 'td_canc_3') ? 'td_canc_int' : 'td_canc_3'
            $(nombre).setStyle({ width: "30%", color: "#FFFFFF", cursor: "pointer", textDecoration: "underline" })
                        if (nombre1 == 'td_canc_3') {
                            $('tbCredVigente').hide()
                            $('tbCredVigente3').show()
                        }
                        else {
                            $('tbCredVigente').show()
                            $('tbCredVigente3').hide()
                        }
                    }

                    /*--------------------------------------------------------------------
                    |   nvFW.nvInterOP
                    |---------------------------------------------------------------------
                    |
                    |   Interfaz entre WebApp de Android y JavaScript, con la cual podemos
                    |   ejecutar métodos en la aplicación nativa Android.
                    |
                    |-------------------------------------------------------------------*/
                    if (nvFW.nvInterOP) {
            nvFW.nvInterOP.checkIfHandlerExists('true')
                        function abrirChat() {
                            nvFW.nvInterOP.openChatRoom()
                if (isMobile())
                mostrarMenuIzquierdo()
                        }

                        //nvSession.UID

                        // esto va en nvLogin.js: linea 278
                        //try {
                        //	 debugger
                        //	 if (nvFW.nvInterOP) {
                        //		 nvFW.nvInterOP.sendMessage("login", "<action><params user='" +  $('UID').value + "' password='" + $('PWD').value + "' token='' cod_app='" + app_cod_sistema + "' cod_implement='AABC10F' /></action>")
                        //	 }
                        //} catch (e) {
                        //}

                        nvFW.nvInterOP.receiveMessageHandler = function (action, params) {
                            if (action == 'is_alive') {
                                nvFW.nvInterOP.sendMessage('is_alive', 'true')
                       //         nvFW.nvInterOP.checkIfHandlerExists('true')
                                return;
                            }

                            if (action == 'BackPressed') {
                                establecerFuncionBack()
                                nvFW.nvInterOP.sendMessage('BackPressed', 'true') // le respondo al esqueleto que ya me hice cargo del Back
                                //nvFW.nvInterOP.sendMessage('BackPressed','false') //le respondo al esqueleto que manda la app al background
                                return;
                            }

                            if (action == 'MessageReceived') {
                                alert('Notificacion Recibida')
                    // console.log('Notificaci—n recibida.')
                            }

                            if (action == 'get_hash') {
                                nvFW.nvInterOP.sendMessage('get_hash', nvFW.get_hash())
                            }

                            if (action == 'xmppMessageReceived') {
                                var xmlObj = new tXML()
                                xmlObj.loadXML(params)
                                var nod = xmlObj.selectNodes("action/params")[0]
                                var messagesPreview = nod.getAttribute("messagesPreview")
                                var newMessagesCount = nod.getAttribute("newMessagesCount")

                    //alert("Operador de chat dice: <br><b>" + messagesPreview + "...</b>")
                                // Mostrar mensajería en un dialog de Android
                    nvFW.interOP.printDialogMessage('Operador de chat dice:', messagesPreview);
                            }
                        }
                    }

        try {
            if (window.webkit.messageHandlers) {
            //debugger
                window.webkit.messageHandlers.nvInterOp.receiveMessageHandler = function (action, params) {
               // debugger
                    if (action == 'BackPressed') {
                  //  debugger
                    establecerFuncionBack()     
                        window.webkit.messageHandlers.nvInterOp.postMessage('BackPressed') // le respondo al esqueleto que ya me hice cargo del Back
                        return;
                    }


                }

               // window.webkit.messageHandlers.nvInterOp.postMessage('close_app')
            }
        }
        catch (e) {}



        function verTutoriales() {
        // window.open('https://youtu.be/k7QU1fab5Mo','_blank')
           var win_tutorial = createWindow2({
                url: 'tutoriales_precarga.aspx?codesrvsw=true',
                title: '<b>Tutoriales</b>',
                maxHeight: 500,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true
            });
            win_tutorial.showCenter(true)

            if (isMobile())
                mostrarMenuIzquierdo()

        }


        function descargar_app() {
            if (isMobile())
                mostrarMenuIzquierdo()

            window.open('https://play.google.com/store/apps/details?id=com.improntasolutions.precarga&hl=es')
        }

    </script>
</head>
<body id="body" onload="return window_onload()" onresize="return window_onresize()"
    style="overscroll-behavior: none; visibility: hidden; overflow-y: auto; overflow-x: hidden;"
    onscroll="scroll_event(this)">
    <form id="form1" action="">
    <input type="hidden" name="nro_docu" id="nro_docu" />
    <input type="hidden" name="clave_sueldo" id="clave_sueldo" />
	<input type="hidden" name="cuit" id="cuit" />
    <input type="hidden" name="nro_vendedor" id="nro_vendedor" value="0" />
    <input type="hidden" name="consultarRobot" id="consultarRobot" value="0" />
    <input type="hidden" id="importe_cuota" name="importe_cuota" value="0.00"/>
    </form>
    <input type="hidden" name="nro_credito" id="nro_credito" value="<%=nro_credito%>" />

    <div style="height: 100%; float: left" id="div_padding_left"></div>

    <table id='top_menu' border='0' style='background-color: white; border-bottom: 3px solid #E3E0E3;z-index:1'>
        <tr>
            <td style='width: 42px;' id='imgMenu'>
                <img id='img_Menu' style='height: 32px; width: 32px;' border='0' class='img_button_sesion' alt='Menu' title='Menú' src='image/menu.svg' onclick='mostrarMenuIzquierdo()' />
            </td>
            <td style=' text-align: left; width: 60%'>
                <object data='image/nova.svg' class='logo' id="logo" type='image/svg+xml'>
                    <img src='/fw/image/nvLogin/nvLogin_logo.png' alt='PNG image of standAlone.svg' />
                </object>
            </td>
            <td id='data_user' style='text-align: right; vertical-align: middle' nowrap>

                <div id="user_name" nowrap><% = nvApp.operador.login.ToUpper%></div>
                <br id="br1" />
                <span id="user_sucursal" nowrap><% = nvApp.operador.sucursal%></span>
                <br id="br2" />

                <img border='0' style='height: 32px; width: 32px' id='imgbloqueo_sesion' class='img_button_sesion' alt='Bloquear sesión' title='Bloquear sesión' src='image/bloquear_sesion.png' onclick='nvSesion.bloquear()' />
                <img border='0' style='height: 32px; width: 32px' id='imgbutton_sesion' class='img_button_sesion' alt='Cerrar sesión' title='Cerrar sesión' src='image/sesion_cerrar.gif' onclick='nvSesion.cerrar()' />
                <div id="menu_right" style="background-color: white; display: inline"></div>
            </td>
            <td style="width: 32px;" id="imgMenuDerecho">
               <%-- <img style='height: 32px; width: 32px;' border='0' class='img_button_sesion' alt='Menu' title='Menú' src='image/menu.ico' onclick='mostrarMenuDerecho()' />--%>
            </td>
        </tr>
    </table>
    <style>
        #vMenuRight td
        {
            background-color: white;
        }
    </style>
    <div id="menu_right_vidrio" onclick="mostrarMenuDerecho()" style="background-color: white;
        position: fixed; left: -540px; bottom: 0px; filter: alpha(opacity=0); opacity: 0.0;
        width: 50px;">
    </div>
    <div id="menu_left" style="">
        <script type="text/javascript">
            //aca va el tMenu_mobile
            var vMenuLeft = new tMenu('menu_left', 'vMenuLeft', { clasicMenu: false });
            Menus["vMenuLeft"] = vMenuLeft
            Menus["vMenuLeft"].alineacion = 'izquierda';
            Menus["vMenuLeft"].estilo = 'A';

            vMenuLeft.canvasMobile = "menu_left_mobile"

            vMenuLeft.loadImage("volver", "../FW/image/icons/izquierda.png")
            vMenuLeft.loadImage("vercreditos", "image/us_dollar_16.png")
            vMenuLeft.loadImage("vendedor", "image/search_16.png")
            vMenuLeft.loadImage("formularios", "../FW/image/filetype/pdf.png")
            vMenuLeft.loadImage("tutorial", "image/tutorial.png")
            vMenuLeft.loadImage("app", "../FW/image/icons/app.png")
            vMenuLeft.loadImage("cuenta", "../FW/image/icons/cuenta.png");

            //Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='1' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>volver</icono><Desc>Volver</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarMenuIzquierdo()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='1' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vercreditos</icono><Desc>Ver Creditos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>VerCreditos('V')</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='2' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vendedor</icono><Desc>Vendedor</Desc><Acciones><Ejecutar Tipo='script'><Codigo>selVendedor_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='3' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>formularios</icono><Desc>Formularios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Descargar_formularios()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='4' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>tutorial</icono><Desc>Tutoriales</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verTutoriales()</Codigo></Ejecutar></Acciones></MenuItem>")


            if (isMobile()) {
                Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>app</icono><Desc>Aplicación</Desc><Acciones><Ejecutar Tipo='script'><Codigo>descargar_app()</Codigo></Ejecutar></Acciones></MenuItem>")
            }
            
            if(estructura_genera_codigo.indexOf(+nvFW.pageContents["operador_vendedor"].nro_estructura)>=0 || nvFW.pageContents["operador_vendedor"].nro_estructura==""){
            Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='6' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>cuenta</icono><Desc>Generar codigo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Generar_codigo()</Codigo></Ejecutar></Acciones></MenuItem>")         
            }
            
             

            //Se genera el html en onload
        </script>
    </div>
    <div id="menu_left_mobile" style="background-color: white; left: -537px; bottom: 0px; transition: .3s all; border-right: 3px solid #E3E0E3; cursor: pointer">
        
    </div>

    <div id="menu_left_vidrio" onclick="mostrarMenuIzquierdo()" style="background-color: white; position: fixed; right: -540px; bottom: 0px; filter: alpha(opacity=0); opacity: 0.0; width: 50px;"></div>

    <div id="divVendedor" style="float: left">
        <div id="divVendedorLeft">
            <table class="tb1" style="border: none;">
                <tr class="tbLabel" style="padding-left: 3px">
                    <td >Vendedor</td>
                </tr>
                <tr>
                    <td><span id="strVendedor"></span></td>
                </tr>
            </table>
        </div>
    </div>
    <!-- Buscar Persona -->
    <div id="divSelTrabajo" style="float: left">
        <table class="tb1" >
            <tr class="tbLabel">
                <td style="text-align: left !important">Buscar Persona</td>
            </tr>
        </table>
        <table class="tb1">
            <tr style="text-align:center">
                <td style="text-align: center; margin-left: auto; margin-right: auto; align: center; padding: 0.6em;"  onclick="return rddoc_onclick()">
                    <input style="vertical-align: bottom;" type='radio' name='rddoc' id='rddoc' value='cuit' onclick="return rddoc_onclick()" />&nbsp;CUIT/CUIL&nbsp;
                    <input style="vertical-align: bottom;" type='radio' name='rddoc' id='rddoc' value='dni' onclick="return rddoc_onclick()" checked />&nbsp;DNI &nbsp;&nbsp;
                    <input style="vertical-align: bottom; text-align: right;width: 9em;" type="number" name="nro_docu1" id="nro_docu1" onclick="return detectSwipe($('menu_left_mobile'), 'colapsar')" onkeydown="return btnBuscar_trabajo_onclick(event)" />
                </td>
            </tr>
            <tr>
                <td style="text-align:center">
                    <div id="divPLimpiar" style="width:25%; margin-left:24%; float:left"></div>
                    <div id="divPBuscar" style="width:25%; margin-left:3%; float:left"></div>
                </td>
            </tr>
        </table>
        <table class="tb1" id="tbResultado">
            <tr class="tbLabel">
                <td colspan="2" id="tdResultado">Resultado</td>
            </tr>
            <tr>
                <td class="Tit4" style="width: 75%; text-align: center"><span style="text-align: left" id="strInfoCuit"></span></div></td>                
                <td style="width: 25%">
                    <div id="divNotiR" style="margin:1px"></div>
                </td>
            </tr>
        </table>
        
        <div id="divMostrarTrabajos" style="display: none"></div>
    </div>
    <!-- Datos Personales -->
    <div id="divDatosPersonales" style="display: none; float: left">
        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align: left !important">Datos Personales</td>
            </tr>
        </table>
        <div id="divDatosPersonalesLeft">
            <table class="tb1">
                <tr>
                    <td class='Tit1' style="width: 60%">CUIT</td>
                    <td class="Tit1" style="width: 40%">F.Nac.</td>
                </tr>
                <tr>
                    <td><span id="strCUIT"></span></td>
                    <td><span id="strFNac"></span></td>
                </tr>
            </table>
        </div>
        <div id="divDatosPersonalesRight">
            <table class="tb1">
                <tr>
                    <td class='Tit1' style="width: 100%">Apellido y Nombres</td>
                </tr>
                <tr>
                    <td><span id="strApeyNomb"></span></td>
                </tr>
            </table>
        </div>
        <div id="divInformeComercial">
            <table class="tb1">
                <tr>
                    <td class='Tit1'>Informe Comercial</td>
                    <td style="width: 60px" title="Ver informe comercial">
                        <div id="divNosis" />
                    </td>
                </tr>
            </table>
            <table class="tb1">
                <tr>
                    <td style="width: 50%">Situación: &nbsp;&nbsp;<b><span style="display: inline-block; width: 50px !important; border-radius: 4px" class="sit1" id="strSitBCRA"></span></b></td>
                    <td style="width: 30%">CDA:&nbsp;&nbsp;<a href="#" style='cursor: pointer' onclick="VerCDA()"><span style="display: inline-block; width: 100px; border-radius: 4px !important" class="cdaAC" id="strDictamen"></span></a>
                        <span id="strFuentes"></span>
                    </td>
                    <td style="width: 20%">
                        <div id="divNoti"></div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <!--Datos del Trabajo -->
    <!-- Datos del Grupo y cobro -->
    <div id="divGrupo" style="display: none; float: left">
        <div id="divGrupoLeft">
            <table class='tb1'>
                <tr>
                    <td class='Tit1'>Trabajo</td>
                </tr>
                <tr>
                    <td><span id="strGrupo"></span></td>
                </tr>
            </table>
        </div>
        <div id="divGrupoRight">
            <table class='tb1'>
                <tr>
                    <td class='Tit1' style="width: 100%">Cobro</td>
                </tr>
                <tr>
                    <td><span id="strCobro"></span></td>
                </tr>
            </table>
        </div>
    </div>
    <!-- Datos del Socio -->
    <div id="divSocio" style="display: none; float: left">
        <div id="divSocioLeft">
            <table class="tb1">
                <tr class="tbLabel">
                    <td style="text-align: left !important">Socio</td>
                </tr>
            </table>
            <table class='tb1'>
                <tr>
                    <td style="width: 100%; vertical-align: top" colspan="2">
                        <div id="tbCuotaSocial" style="vertical-align: top; width: 100%"></div>
                    </td>
                </tr>
            </table>
        </div>
        <div id="divSocioRight">
            <table class="tb1" id="tbCreditos">
                <tr class="tbLabel">
                    <td style="text-align: left !important">Cancelaciones</td>
                    <td id="td_canc_int" style="display: none" onclick="Btn_cancelaciones_onclick(this)">Internas</td>
                    <td id="td_canc_3" style="display: none" onclick="Btn_cancelaciones_onclick(this)">Terceros</td>
                </tr>
            </table>
            <div id="tbCredVigente" style="vertical-align: top; width: 100%; height:148px; overflow:auto"></div>
            <div id="tbCredVigente3" style="vertical-align: top; width: 100%; display: none"></div>
        </div>
    </div>
    <!-- Seleccionar Producto -->
    <div id="divProducto" style="display: none; float: left">
        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align: left !important">Producto</td>
            </tr>
        </table>
        <div id="divProductoLeft">
            <table class='tb1'>
                <tr>
                    <td class='Tit1' style="width: 10%">Banco:</td>
                    <td style="width: 36%">
                        <%--<select id="banco" name="banco" style="width: 100%" onchange="return banco_onchange()"></select>--%>
                        <script type="text/javascript">campos_defs.add('banco', { enDB: false, nro_campo_tipo: 1})</script>
                    </td>
                </tr>
            </table>
        </div>
        <div id="divProductoRight">
            <table class='tb1'>
                <tr>
                    <td class='Tit1' style="width: 10%">Mutual:</td>
                    <td style="width: 36%">
                        <%--<select id="mutual" name="mutual" style="width: 100%" onchange="return mutual_onchange()"></select>--%>
                        <script type="text/javascript">campos_defs.add('mutual', { enDB: false, nro_campo_tipo: 1})</script>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div id="divAnalisis" style="display: none; float: left">
        <table class='tb1'>
            <tr>
                <td class='Tit1' style="width: 10%">Analisis:</td>
                <td style="width: 36%">
                    <%--<select name="cbAnalisis" id="cbAnalisis" onchange="return cbAnalisis_onchange()"></select></td>--%>
                    <script type="text/javascript">campos_defs.add('cbAnalisis', { enDB: false, nro_campo_tipo: 1})</script>
            </tr>
        </table>
        <div id="divHaberesNoVisibles" style='display: none'></div>
        <table style="width: 100%" id="haberes" cellspacing="0" cellpadding="0">
            <tr style="text-align: center; font-size: 12px; font-weight: bolder; color: white; background-color: dimgray;"></tr>
        </table>
        <div id="divHaberes"></div>
        <div id="divTotalesLeft">
            <table class="tb1" style="width: 100%">
                <tr>
                    <td style='width: 27%; text-align: right;' class="Tit1"><b>&nbsp;Saldo a cancelar:&nbsp;</b></td>
                    <td style='width: 25%; text-align: right'><b><span id="saldo_a_cancelar">$ 0.00</span></b></td>
                    <td style='width: 25%; text-align: right' class="Tit1"><b>&nbsp;Haber neto:&nbsp;</b></td>
                    <td style='text-align: right'><b><span id="haber_neto">$ 0.00</span></b></td>
                </tr>
            </table>
        </div>
        <div id="divTotalesRight">
            <table class="tb1" style="width: 100%">
                <tr>
                    <td style='width: 25%; text-align: right' class="Tit1"><b>&nbsp;Cuota máxima:&nbsp;</b></td>
                    <td style='width: 25%; text-align: right'><b><span id="importe_max_cuota">$ 0.00</span></b></td>
                    <td style='width: 25%; text-align: right' class="Tit1"><b>&nbsp;En mano:&nbsp;</b></td>
                    <td style='width: 25%; text-align: right'><b><span id="strEnMano">$ 0.00</span></b></td>
                </tr>
            </table>
        </div>
    </div>
    <div id="divFiltros" style="display: none; float: left">
        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align: left !important" onclick='selplan_on_click()'>
                    <input type="checkbox" style="border: none; display: none; vertical-align: middle;" id="selplan" onclick='selplan_on_click()' />&nbsp;Seleccionar Plan</td>
            </tr>
        </table>
        <table class='tb1' id="tbfiltros" style="border-collapse: collapse; border: none; display: none">
            <tr>
                <td>
                    <div id="divFiltrosLeft">
                        <table class='tb1'>
                            <tr>
                                <td class='Tit1' style="width: 50%"></td>
                                <td class='Tit1' style="width: 25%">Desde</td>
                                <td class='Tit1' style="width: 25%">Hasta</td>
                            </tr>
                            <tr>
                                <td>Importe Retirado</td>
                                <td>
                                    <script type="text/javascript">campos_defs.add('retirado_desde', { enDB: false, nro_campo_tipo: 102 })</script>
                                </td>
                                <td>
                                    <script type="text/javascript">campos_defs.add('retirado_hasta', { enDB: false, nro_campo_tipo: 102 })</script>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="divFiltrosRight">
                        <table class='tb1'>
                            <tr>
                                <td class='Tit1' style="width: 50%"></td>
                                <td class='Tit1' style="width: 25%">Desde</td>
                                <td class='Tit1' style="width: 25%">Hasta</td>
                            </tr>
                            <tr>
                                <td>Importe Cuota</td>
                                <td>
                                    <script type="text/javascript">campos_defs.add('importe_cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script>
                                </td>
                                <td>
                                    <script type="text/javascript">campos_defs.add('importe_cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="divFiltros2Left">
                        <table class='tb1'>
                            <tr>
                                <td class='Tit1' style="width: 50%"></td>
                                <td class='Tit1' style="width: 25%">Desde</td>
                                <td class='Tit1' style="width: 25%">Hasta</td>
                            </tr>
                            <tr>
                                <td>Cuotas</td>
                                <td>
                                    <script type="text/javascript">campos_defs.add('cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script>
                                </td>
                                <td>
                                    <script type="text/javascript">campos_defs.add('cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="divFiltros2Right">
                        <table class='tb1' style='vertical-align: middle'>
                            <tr>
                                <td class="Tit1" style="width: 100%" colspan="2">Ignorar</td>
                            </tr>
                            <tr>
                                <td style="width: 50%">
                                    <input type="checkbox" style="border: none" id="chkFiltroCuenta" />
                                    <% If filtro_cuenta = "True" Then
                                            Response.Write("Banco Cobro")
                                        Else
                                            Response.Write("&nbsp;")
                                        End If
                                    %>
                                </td>
                                <td style="width: 50%">
                                    <input type="checkbox" style="border: none" id="chkFiltroBCRA" />
                                    <% If filtro_bcra = "True" Then
                                            Response.Write("Sit.BCRA")
                                        Else
                                            Response.Write("&nbsp;")
                                        End If
                                    %>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="divFiltros3Left">
                        <table class='tb1'>
                            <tr>
                                <td class="Tit1" style="width: 50%"></td>
                                <td class="Tit1" style="width: 50%">Cobro</td>
                            </tr>
                            <tr>
                                <td style="width: 50%">
                                    <input type="checkbox" style="border: none" id="chkmax_disp" />
                                    Importe máx. disp.</td>
                                <td style="width: 50%">
                                    <script type="text/javascript">campos_defs.add('nro_tipo_cobro_precarga', { enDB: true })</script>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="divFiltros3Right">
                        <table class='tb1'>
                            <tr>
                                <td></td>
                            </tr>
                            <tr>
                                <td style="width: 100%">
                                    <div id="divPlanBuscar"></div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <iframe style="width: 100%; height: 200px; border: none; display: none;" name="ifrplanes" id="ifrplanes" src="enBlanco.htm"></iframe>
    </div>
    <table style="width: 98%; display: none; position: fixed; bottom: 0px; float: left; background-color: grey; border-radius:140px;" id="tbButtons">
        <tr>
            <td style="width: 33%">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0" style="border-radius: 55px !important ;">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('P')" id="btn1" style="border-radius: 70px">
                            <img src="image/save.ico" class="img_button" border="0" align="absmiddle" hspace="1" id="img1">&nbsp;Pendiente
                        </td>
                        <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
            <td style="width: 33%">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0" style="border-radius: 55px !important ;">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('H')" id="btn2" style="border-radius: 70px">
                            <img src="image/ok.ico" class="img_button" border="0" alt="" align="absmiddle" hspace="1" id="img2">&nbsp;Precarga
                        </td>
                        <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
            <td style="text-align: center">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0" style="border-radius: 55px !important ;">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="this.disabled=true; Precarga_Limpiar()" id="btn3" style="border-radius: 70px">
                            <img src="image/blank.ico" class="img_button" border="0" align="absmiddle" hspace="1" id="img3">&nbsp;Limpiar
                        </td>
                        <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <div id="divEspacioBotonera" style="height: 50px; float: left; width: 100%;"></div>
    
    <%--<table style="width: 100%; display: none; position: fixed; bottom: 0px; float: left; background-color: #ded2d2;" id="tbButtons">
        <tr>
            <td style="width: 33%">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('P')" id="btn1" >
                            <img src="/precarga_test/image/tarea.png" class="img_button" border="0" align="absmiddle" hspace="1" id="img1">&nbsp;Pendiente
                        </td>
                        <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
            <td style="width: 33%">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('H')" id="btn2">
                            <img src="/precarga_test/image/guardar (2).png" class="img_button" border="0" alt="" align="middle" hspace="1" id="img2">&nbsp;Precarga
                        </td>
                        <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
            <td style="text-align: center">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="this.disabled=true; Precarga_Limpiar()" id="btn3">
                            <img src="/precarga_test/image/limpiar (2).png" class="img_button" border="0" align="absmiddle" hspace="1" id="img3">&nbsp;Limpiar
                        </td>
                        <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>--%>
</body>
</html>
