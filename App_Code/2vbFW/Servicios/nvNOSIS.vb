Imports System.Windows.Forms
Imports Microsoft.VisualBasic
Imports System.Diagnostics
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW.servicios

    Public Class tnvNosis
        Public Sub New()

        End Sub
        Public Function SAC_identidad(ByVal nro_docu As Integer, ByVal nro_vendedor As Integer, ByVal nro_banco As Integer, Optional ByVal nro_entidad As Integer = 0, Optional ByVal CDA As Integer = 0) As String
            Return nvNOSIS.SAC_identidad(nro_docu, nro_vendedor, nro_banco, nro_entidad, CDA)
        End Function

        Public Function SAC_informe_variable(ByVal cuit As String, ByVal nro_vendedor As Integer, ByVal nro_banco As String, Optional ByVal CDA As Integer = 0, Optional ByVal logTrack As String = "", Optional ByVal actualizarFuentes As Boolean = True, Optional ByVal forzar_consulta As Boolean = False) As String
            Return nvNOSIS.SAC_informe_variable(cuit, nro_vendedor, nro_banco, CDA, logTrack, actualizarFuentes, forzar_consulta)
        End Function
        Public Function SAC_informeBase(ByVal cuit As String, ByVal razonsocial As String, ByVal sexo As String, ByVal CDA As Integer, Optional ByVal nro_entidad As Integer = 0, Optional ByVal logTrack As String = "", Optional ByVal actualizarFuentes As Boolean = True, Optional ByVal forzar_consulta As Boolean = False) As String
            Return nvNOSIS.SAC_informeBase(cuit, razonsocial, sexo, CDA, nro_entidad, logTrack, actualizarFuentes, forzar_consulta)
        End Function

        Public Function SAC_informe(ByVal cuit As String, ByVal nro_vendedor As Integer, ByVal nro_banco As String, Optional ByVal nro_entidad As Integer = 0, Optional ByVal CDA As Integer = 0, Optional ByVal logTrack As String = "", Optional ByVal actualizarFuentes As Boolean = True, Optional ByVal forzar_consulta As Boolean = False) As String
            Return nvNOSIS.SAC_informe(cuit, nro_vendedor, nro_banco, nro_entidad, CDA, logTrack, actualizarFuentes, forzar_consulta)
        End Function

    End Class

    Public Class nvNOSIS
        Public Shared Function SAC_identidad(ByVal nro_docu As Integer, ByVal nro_vendedor As Integer, ByVal nro_banco As Integer, Optional ByVal nro_entidad As Integer = 0, Optional ByVal CDA As Integer = 0) As String

            Dim XML As New System.Xml.XmlDocument
            Dim strXML As String = ""

            Try

                Dim NOSIS_UID As String = "0"
                Dim NOSIS_PWD As String = ""
                Dim NroConsulta As String = 0

                Dim Stopwatch As System.Diagnostics.Stopwatch

                ' Recupero valores a partir de una consulta
                Dim strSQL As String = "Select top 1 nro_entidad,nosis_cda,param_uid,param_pwd from [verNOSISCdasBancos] where "
                If CDA > 0 Then
                    strSQL &= " nosis_cda ='" & CDA.ToString & "'"
                End If
                If nro_banco > 0 Then
                    strSQL &= IIf(strSQL.Substring(strSQL.Length - 6, 5) = "where", " ", " and ") & " nro_banco = " & nro_banco.ToString
                End If
                If nro_entidad > 0 Then
                    strSQL &= IIf(strSQL.Substring(strSQL.Length - 6, 5) = "where", " ", " and ") & " nro_entidad = " & nro_entidad.ToString
                End If
                strSQL &= " order by orden asc"

                'Dim strSQL As String = "SELECT TOP 1 nosis_cda, nro_entidad, param_uid, param_pwd FROM [verNOSISCdas] WHERE nosis_cda='" & CDA & "'"
                Dim rsRes As ADODB.Recordset = DBOpenRecordset(strSQL)
                If Not rsRes.EOF Then
                    NOSIS_UID = getParametroValor(rsRes.Fields("param_uid").Value)
                    NOSIS_PWD = getParametroValor(rsRes.Fields("param_pwd").Value)
                    nro_entidad = rsRes.Fields("nro_entidad").Value
                    CDA = rsRes.Fields("nosis_cda").Value
                End If
                DBCloseRecordset(rsRes)

                Dim NOSIS_url_identidad = nvFW.nvUtiles.getParametroValor("NOSIS_URL_IDENTIDAD") '//'http://sac.nosis.com.ar/Sac_ServicioVI/Consulta.asp'

                Dim Resp_EsReducida = nvFW.nvUtiles.getParametroValor("Resp_EsReducida") '//'no'
                Dim Resp_DomTipoInfo = nvFW.nvUtiles.getParametroValor("Resp_DomTipoInfo") '// '2'
                Dim MaxRows = nvFW.nvUtiles.getParametroValor("MaxRows") '// '200'
                Dim TipoConsult = nvFW.nvUtiles.getParametroValor("TipoConsult") '// '1'
                Dim IdConsulta = nvFW.nvUtiles.getParametroValor("IdConsulta") '// 10
                Dim URL = ""
                Dim strHTML = ""
                '/*********************************************/
                '// Revisar si la consulta ya existe
                '/*********************************************/
                Dim filtroCDA As String = ""
                Dim filtroBanco As String = ""
                If CDA <> 0 Then filtroCDA = " AND CDA = " & CDA.ToString
                If nro_banco <> 0 Then filtroBanco = " AND nro_banco = " & nro_banco.ToString

                strSQL = "Select * from verNosis_consulta where accion = 'sac_identidad' and criterio = '" & nro_docu & "' and terminado = 1 and activo = 1 " & filtroBanco & " " & filtroCDA
                rsRes = nvDBUtiles.DBOpenRecordset(strSQL)

                Dim existe As Boolean = False

                If Not rsRes.EOF Then

                    strXML = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    XML.LoadXml(strXML)
                    existe = True

                    If XML.SelectSingleNode("/Resultado/@TodoOk").Value.ToString.ToUpper = "NO" Then
                        If rsRes.Fields("id_consulta").Value > 0 Then
                            DBExecute("UPDATE lausana_anexa..nosis_consulta SET nosis_activo = 0 WHERE id_consulta = " & rsRes.Fields("id_consulta").Value)
                            existe = False
                        End If
                    End If

                End If

                If existe = False Then

                    Dim RazonSocial As String = ""
                    Dim Sexo As String = ""
                    strSQL = "Select top 1 apellido,nombres,sexo, strNombreCompleto from verPersonas where nro_docu = '" & nro_docu & "'"
                    Dim rsRes2 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                    If Not rsRes2.EOF Then
                        RazonSocial = rsRes2.Fields("strNombreCompleto").Value
                        Sexo = IIf(rsRes2.Fields("sexo").Value = "F", "Femenino", "Masculino")
                    End If
                    nvDBUtiles.DBCloseRecordset(rsRes2)
                    Dim strURL As String = NOSIS_url_identidad & "?TipoConsult=" & TipoConsult & "&RazonSocial=" & RazonSocial & "&Doc=" & nro_docu & "&MaxRows=" & MaxRows & "&User=" & NOSIS_UID & "&Resp_EsReducida=" & Resp_EsReducida & "&Resp_DomTipoInfo=" & Resp_DomTipoInfo
                    IdConsulta = SAC_get_id_consulta("sac_identidad", nro_docu, strURL, nro_vendedor, nro_banco, CDA, NOSIS_UID)
                    strURL += "&IdConsulta=" & IdConsulta & "&Password=" & NOSIS_PWD

                    'XML.async = False
                    Dim resultado As Boolean = False

                    '//var XMLaux = new ActiveXObject("Microsoft.XMLDOM"); 
                    Dim nvHttPReq As New nvHTTPRequest
                    nvHttPReq.Method = "GET"
                    nvHttPReq.url = strURL

                    Dim XMLaux As System.Xml.XmlDocument = nvHttPReq.getResponseXML

                    URL = nvFW.nvXMLUtiles.getNodeText(XMLaux, "Pedido/URL", "")
                    Dim cont As Integer = 0
                    If URL <> "" Then
                        Do
                            cont += 1
                            'System.Threading.Thread.CurrentThread.Sleep(500)
                            nvDBUtiles.DBExecute("WAITFOR DELAY '00:00:00.5'")
                            Dim nvHTTPReq2 As New nvHTTPRequest
                            nvHTTPReq2.Method = "GET"
                            nvHTTPReq2.url = URL
                            'Dim XML2 As System.Xml.XmlDocument = nvHTTPReq2.getResponseXML
                            XML = nvHTTPReq2.getResponseXML
                            If Not XML Is Nothing Then
                                resultado = True
                                SAC_get_act_consulta(IdConsulta, XML.OuterXml)

                                If XML.SelectSingleNode("/Resultado/@TodoOk").Value.ToString.ToUpper = "NO" Then
                                    SAC_deshabilitar(IdConsulta)
                                End If

                                Exit Do
                            End If
                        Loop While cont < 4
                    End If

                    If Not resultado Then
                        strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                        XML.LoadXml(strXML)
                        SAC_deshabilitar(IdConsulta)
                    End If

                End If

                Dim NODs As System.Xml.XmlNodeList = XML.SelectNodes("Resultado/Personas/Persona")
                For Each nod As System.Xml.XmlNode In NODs
                    Dim attr As System.Xml.XmlAttribute = XML.CreateAttribute("existe")
                    attr.Value = existe.ToString.ToLower
                    nod.Attributes.Append(attr)
                Next

                nvDBUtiles.DBCloseRecordset(rsRes)

            Catch ex As Exception
                strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                XML = New System.Xml.XmlDocument
                XML.LoadXml(strXML)
            End Try

            Return XML.OuterXml

        End Function

        Public Shared Function SAC_get_id_consulta(ByVal accion As String, ByVal criterio As String, ByVal pvURL As String, ByVal nro_vendedor As Integer, ByVal nro_banco As Integer, ByVal Cons_CDA As Integer, ByVal NOSIS_UID As String) As String

            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("exec rm_nosis_consulta '" & accion & "', '" & criterio & "', '" & pvURL.Replace("'", "''") & "'," & nro_vendedor & "," & nro_banco & "," & Cons_CDA & "," & NOSIS_UID)
            Dim res As String = rs.Fields("id_consulta").Value
            nvDBUtiles.DBCloseRecordset(rs)
            Return res

        End Function

        Public Shared Sub SAC_get_act_consulta(ByVal id_consulta As String, ByVal xml_resultado As String)
            Dim strSQL As String = "declare @xml_resultado varbinary(max) "
            strSQL += "set @xml_resultado = cast('" + xml_resultado.Replace("'", "''") + "' as varbinary(max)) "
            strSQL += "exec rm_nosis_consulta_res " + id_consulta + ", @xml_resultado"
            nvDBUtiles.DBExecute(strSQL)
        End Sub

        '{
        '  "Stk": "RWH42Y0F244P025922I242I2I2642I023522I23042I59522I33122I42242I59522I242I2I23042I23522I25922I2162I023042I27362I2162I023522I25922I40322I23522I24962I2N42I25442I25442I2N42I244P0242I0",
        '  "Ok": true,
        '  "Novedad": null
        '}
        Public Shared Function SAC_get_token(ByVal cda As String) As String
            'Stop
            Dim url As String = ""
            Dim token As String = ""
            Dim NOSIS_UID As String = ""
            Dim NOSIS_PWD As String = ""

            ' Recupero valores a partir de una consulta
            Dim strSQL As String = "SELECT TOP 1 nosis_cda, nro_entidad, param_uid, param_pwd FROM [verNOSISCdas] WHERE "
            If cda > 0 Then
                strSQL &= "nosis_cda='" & cda & "'"
            End If
            strSQL &= " ORDER BY ORDEN ASC"

            Dim rsRes As ADODB.Recordset = DBOpenRecordset(strSQL)

            If Not rsRes.EOF() Then
                NOSIS_UID = getParametroValor(rsRes.Fields("param_uid").Value)
                NOSIS_PWD = getParametroValor(rsRes.Fields("param_pwd").Value)
            End If

            DBCloseRecordset(rsRes)

            rsRes = nvDBUtiles.DBOpenRecordset("select top 1 rtrim(ltrim(token)) as token from lausana_anexa..nosis_token where usuario = " & NOSIS_UID & " and dbo.[conv_fecha_to_str](momento,'yyyymmdd') >= dbo.[conv_fecha_to_str](getdate(),'yyyymmdd') order by id_token")
            If Not rsRes.EOF Then
                token = LTrim(rsRes.Fields("token").Value)
                nvDBUtiles.DBCloseRecordset(rsRes)
            Else
                Dim nvHTTPReg As New nvHTTPRequest
                nvHTTPReg.url = "http://sacrelay.nosis.com/fuentesexternas/acceso?usuario=" & NOSIS_UID & "&password=" & NOSIS_PWD & ""
                nvHTTPReg.Method = "GET"
                Dim strRes As String = nvHTTPReg.getResponseText
                If Not strRes Is Nothing Then
                    token = strRes.Split(":")(1).Split(",")(0).Replace("""", "")
                    nvDBUtiles.DBExecute("INSERT INTO lausana_anexa..nosis_token (token,usuario,momento) values ('" & LTrim(token) & "'," & NOSIS_UID & ",getdate())")
                End If
            End If

            Return "<resultado><url><![CDATA[http://sacrelay.nosis.com/fuentesexternas?usuario=" & NOSIS_UID & "&stk=" & token & "&fuentes=1&forzar=true]]></url></resultado>"

        End Function

        'Listado de Fuentes Externas (NOSIS_FEX) parametro para informe variable
        'BCRA - Banco Central de la República Argentina
        'RD - Anses
        'SRT SRT – Superintendencia de Riesgos de Trabajo.
        'AF AFIP – Inscripciones
        'SSS SSS – Superintendencia de Servicios de Salud
        'AF.AP AFIP – Mis Aportes
        'SIPA Anses - Situación Previsional
        'AF.OC AFIP - Consulta Padrón - Operaciones de Cambio
        'MNP SSS - Pagos de Monotributo
        'MN SSS - Padrón de Monotributo
        'CN Anses - Certificación Negativa 

        ' Tabla Fuentes Externas (NOSIS_FUENTES_EXTERNAS_OK)
        '1 BCRA
        '2 ANSES
        '3 SRT - Superintendencia de Riesgos de Trabajo
        '4 AFIP - Inscripciones
        '5 SSS - Superintendencia de Servicios de Salud
        '6 AFIP - Mis aportes
        '7 ANSES - Situación Previsional
        '8 AFIP - Consulta Padrón - Operaciones de Cambio
        '9 MNP – Pagos de Monotributo
        '10 MN – Padrón de Monotributo
        Public Shared Function SAC_informe(ByVal cuit As String, ByVal nro_vendedor As Integer, ByVal nro_banco As String, Optional ByVal nro_entidad As Integer = 0, Optional ByVal CDA As Integer = 0, Optional ByVal logTrack As String = "", Optional ByVal actualizarFuentes As Boolean = True, Optional ByVal forzar_consulta As Boolean = False) As String

            Dim XML As New System.Xml.XmlDocument
            Dim strXML As String = ""

            Try
                Dim cdaSinInformeBCRA As Boolean = False
                Dim cdaDictamen As String = ""
                Dim NroConsultaFuentes As String = ""
                Dim NOSIS_UID As String = "0"
                Dim NOSIS_PWD As String = ""
                Dim isFueExt_vigente As Boolean = False
                Dim Stopwatch As System.Diagnostics.Stopwatch
                Dim EstadoOk As String = "SI"

                Dim NOSIS_url_informe As String = nvFW.nvUtiles.getParametroValor("NOSIS_URL_INFORME") '//'http://sac.nosis.com.ar/SAC_ServicioSF/Consulta.asp'
                Dim NroConsulta As String = 0

                ' Recupero valores a partir de una consulta
                Dim strSQL As String = "Select top 1 nro_entidad,nosis_cda,param_uid,param_pwd,isFueExt_vigente from [verNOSISCdasBancos] where "
                If CDA > 0 Then
                    strSQL &= " nosis_cda ='" & CDA.ToString & "'"
                End If
                If nro_banco > 0 Then
                    strSQL &= IIf(strSQL.Substring(strSQL.Length - 6, 5) = "where", " ", " and ") & " nro_banco = " & nro_banco.ToString
                End If
                If nro_entidad > 0 Then
                    strSQL &= IIf(strSQL.Substring(strSQL.Length - 6, 5) = "where", " ", " and ") & " nro_entidad = " & nro_entidad.ToString
                End If
                strSQL &= " order by orden asc"

                'Dim strSQL As String = "Select TOP 1 nosis_cda, nro_entidad, param_uid, param_pwd FROM [verNOSISCdas] WHERE nosis_cda='" & CDA & "'"
                Dim rsRes As ADODB.Recordset = DBOpenRecordset(strSQL)
                If Not rsRes.EOF Then
                    NOSIS_UID = getParametroValor(rsRes.Fields("param_uid").Value)
                    NOSIS_PWD = getParametroValor(rsRes.Fields("param_pwd").Value)
                    nro_entidad = rsRes.Fields("nro_entidad").Value
                    CDA = rsRes.Fields("nosis_cda").Value
                    isFueExt_vigente = rsRes.Fields("isFueExt_vigente").Value
                End If
                DBCloseRecordset(rsRes)

                Dim filtroCDA As String = ""
                Dim filtroBanco As String = ""

                If CDA <> 0 Then filtroCDA = " AND CDA = " & CDA.ToString
                If nro_banco <> 0 Then filtroBanco = " AND nro_banco = " & nro_banco.ToString

                '***
                Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                '***
                strSQL = "Select * from verNosis_consulta where accion = 'sac_informe' and criterio = '" & cuit & "' and terminado = 1 and activo = 1 " & filtroBanco & " " & filtroCDA
                rsRes = nvDBUtiles.DBOpenRecordset(strSQL)
                '***
                Stopwatch.Stop()
                Dim ts As TimeSpan = Stopwatch.Elapsed
                nvLog.addEvent("nosis_consultaDB", logTrack & ";;" & ts.TotalMilliseconds)
                '***
                If Not rsRes.EOF Then
                    NroConsulta = rsRes.Fields("id_consulta").Value
                    strXML = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    XML = New System.Xml.XmlDocument
                    XML.LoadXml(strXML)
                    strXML = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    XML.LoadXml(strXML)
                    If NroConsulta > 0 Then
                        nvDBUtiles.DBExecute("exec dbo.rm_nosis_consulta_registrar_vendedor " & NroConsulta & "," & nro_vendedor)
                    End If
                Else

                    If (actualizarFuentes = True) Then
                        Try

                            NroConsultaFuentes = "-99"
                            strXML = nvFW.servicios.nvNOSIS.SAC_Actualizar_fuentes_externas(cuit, nro_banco, nro_entidad:=nro_entidad, CDA:=CDA, logTrack:=logTrack, actualizarFuentes:=actualizarFuentes)
                            XML = New System.Xml.XmlDocument
                            XML.LoadXml(strXML)
                            If XML.SelectSingleNode("/Respuesta/@TodoOk").Value.ToString.ToUpper = "SI" Then

                                If XML.SelectSingleNode("/Respuesta/@IdConsulta").Value <> "" Then
                                    NroConsultaFuentes = XML.SelectSingleNode("/Respuesta/@IdConsulta").Value
                                End If

                            End If

                        Catch ex As Exception

                        End Try
                    End If

                    Dim RazonSocial As String = ""
                    Dim Sexo As String = ""
                    strSQL = "Select top 1 sexo,replace(rtrim(ltrim(nombre)),'#','Ñ') as nombre,nro_docu from verDBCuit where cuit = '" & cuit & "'"
                    Dim rsRes2 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                    If Not rsRes2.EOF Then
                        RazonSocial = rsRes2.Fields("nombre").Value
                        Sexo = IIf(rsRes2.Fields("sexo").Value.ToString.ToUpper = "F", "Femenino", "Masculino")
                    End If
                    nvDBUtiles.DBCloseRecordset(rsRes2)

                    '***
                    Dim Stopwatch3 As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                    '***
                    Dim ConsXML_Filtro As String = ""
                    Dim URL As String = ""
                    Dim strHTML As String = ""

                    Dim strURL As String = NOSIS_url_informe _
                                        & "?Usuario=" & NOSIS_UID _
                                        & "&Cons_CDA=" & CDA _
                                        & "&ConsXML_Doc=" & cuit _
                                        & "&ConsXML_RZ=" & RazonSocial _
                                        & "&ConsXML_Filtro=" _
                                        & "&ConsHTML_Doc=" & cuit _
                                        & "&ConsHTML_RZ=" & RazonSocial _
                                        & "&ConsHTML_Filtro=" _
                                        & "&ConsHTML_MaxResp=200" _
                                        & "&ConsXML_MaxResp=200" _
                                        & "&ConsXML_Setup=" _
                                        & "&Cons_SoloPorDoc=No"

                    NroConsulta = SAC_get_id_consulta("sac_informe", cuit, strURL, nro_vendedor, nro_banco, CDA, NOSIS_UID)
                    strURL += "&Password=" & NOSIS_PWD _
                           & " &NroConsulta=" & NroConsulta

                    '        XML.async = false
                    Dim resultado As Boolean = False
                    Dim nvHttpReg As New nvHTTPRequest
                    nvHttpReg.Method = "GET"
                    nvHttpReg.url = strURL
                    Dim XMLaux As System.Xml.XmlDocument = nvHttpReg.getResponseXML
                    If Not XMLaux Is Nothing Then URL = nvXMLUtiles.getNodeText(XMLaux, "Pedido/URL", "")
                    Dim cont As Integer = 0
                    If URL <> "" Then
                        Do
                            cont += 1
                            System.Threading.Thread.Sleep(500)
                            Dim nvHTTPReq2 As New nvHTTPRequest
                            nvHTTPReq2.Method = "GET"
                            nvHTTPReq2.url = URL
                            XML = nvHTTPReq2.getResponseXML
                            If Not XML Is Nothing Then
                                resultado = True
                                SAC_get_act_consulta(NroConsulta, XML.OuterXml)
                                Exit Do
                            End If
                        Loop While (cont < 4)

                    End If

                    If Not resultado Then
                        'strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades cdaSinInformeBCRA='false' cdaDictamen=''><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                        strXML = "<Respuesta TodoOk='No' IdConsulta='-99' cdaSinInformeBCRA='false' cdaDictamen=''><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la consulta]]></Novedad></Resultado></Consulta></Respuesta>"
                        XML = New System.Xml.XmlDocument
                        XML.LoadXml(strXML)
                    End If
                    '***
                    Stopwatch3.Stop()
                    Dim ts3 As TimeSpan = Stopwatch3.Elapsed
                    nvLog.addEvent("nosis_obtener_informe", logTrack & ";;" & ts3.TotalMilliseconds)
                    '***
                End If

                If NroConsulta > 0 Then

                    strSQL = "insert into lausana_anexa..NOSIS_consulta_log(id_consulta) values(" & NroConsulta & ")"
                    nvDBUtiles.DBExecute(strSQL)
                End If
                nvDBUtiles.DBCloseRecordset(rsRes)

                cdaSinInformeBCRA = nvXMLUtiles.getNodeText(XML, "/Respuesta/ParteXML/Dato/CalculoCDA/Item[@Clave = ""CI"" and contains(Detalle,""Sin Info BCRA"")]", "") <> ""
                cdaDictamen = nvXMLUtiles.getNodeText(XML, "/Respuesta/ParteXML/Dato/CalculoCDA/Item[@Clave = ""DICT"" and Descrip = ""Dictamen""]/Valor", "")
                EstadoOk = nvXMLUtiles.getNodeText(XML, "/Respuesta/Consulta/Resultado/EstadoOk", "SI").ToUpper

                'Agregar a Resultado
                If Not (IsNothing(XML.SelectSingleNode("/Respuesta"))) Then

                    Dim oAtt As System.Xml.XmlAttribute
                    oAtt = XML.CreateAttribute("cdaSinInformeBCRA")
                    oAtt.Value = cdaSinInformeBCRA
                    XML.SelectSingleNode("Respuesta").Attributes.Append(oAtt)

                    oAtt = XML.CreateAttribute("cdaDictamen")
                    oAtt.Value = cdaDictamen
                    XML.SelectSingleNode("Respuesta").Attributes.Append(oAtt)

                    oAtt = XML.CreateAttribute("NroConsultaFuentes")
                    oAtt.Value = NroConsultaFuentes
                    XML.SelectSingleNode("Respuesta").Attributes.Append(oAtt)

                End If

                If cdaSinInformeBCRA = True And isFueExt_vigente = True Then
                    SAC_deshabilitar(NroConsulta)
                End If

                'En el caso que fallaré no guardar
                If EstadoOk = "NO" Then
                    SAC_deshabilitar(NroConsulta)
                End If


            Catch ex As Exception

                'strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                strXML = "<Respuesta TodoOk='No' IdConsulta='-99' cdaSinInformeBCRA='false' cdaDictamen=''><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la consulta]]></Novedad></Resultado></Consulta></Respuesta>"
                XML = New System.Xml.XmlDocument
                XML.LoadXml(strXML)
            End Try

            Return XML.OuterXml

        End Function

        Public Shared Function SAC_identidadBase(ByVal nro_docu As Integer, ByVal razonsocial As String, ByVal sexo As String, ByVal CDA As Integer, Optional ByVal nro_entidad As Integer = 0) As String

            Dim XML As New System.Xml.XmlDocument
            Dim strXML As String = ""

            Try

                Dim NOSIS_UID As String = "0"
                Dim NOSIS_PWD As String = ""
                Dim NroConsulta As String = 0

                'Dim Stopwatch As System.Diagnostics.Stopwatch

                '/*********************************************/
                '// Revisar si la consulta ya existe
                '/*********************************************/
                Dim filtroCDA As String = ""
                If CDA <> 0 Then filtroCDA = " AND CDA = " & CDA.ToString
                Dim strSQL As String = "Select * from verNosis_consulta where accion = 'sac_identidad' and criterio = '" & nro_docu & "' and terminado = 1 and activo = 1 " & filtroCDA
                Dim rsRes As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)

                Dim existe As Boolean = False
                If Not rsRes.EOF Then

                    strXML = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    XML.LoadXml(strXML)
                    existe = True

                    If XML.SelectSingleNode("/Resultado/@TodoOk").Value.ToString.ToUpper = "NO" Then
                        If rsRes.Fields("id_consulta").Value > 0 Then
                            DBExecute("UPDATE nosis_consulta SET nosis_activo = 0 WHERE id_consulta = " & rsRes.Fields("id_consulta").Value)
                            existe = False
                        End If
                    End If

                End If

                If existe = False Then

                    strSQL = "Select top 1 nro_entidad,nosis_cda,param_uid,param_pwd,isFueExt_vigente from [verNOSISCdas] where nosis_cda ='" & CDA.ToString & "'"
                    rsRes = DBOpenRecordset(strSQL)
                    If Not rsRes.EOF Then
                        NOSIS_UID = getParametroValor(rsRes.Fields("param_uid").Value)
                        NOSIS_PWD = getParametroValor(rsRes.Fields("param_pwd").Value)
                    End If
                    DBCloseRecordset(rsRes)

                    Dim NOSIS_url_identidad = nvFW.nvUtiles.getParametroValor("NOSIS_URL_IDENTIDAD") '//'http://sac.nosis.com.ar/Sac_ServicioVI/Consulta.asp'

                    Dim Resp_EsReducida = nvFW.nvUtiles.getParametroValor("Resp_EsReducida") '//'no'
                    Dim Resp_DomTipoInfo = nvFW.nvUtiles.getParametroValor("Resp_DomTipoInfo") '// '2'
                    Dim MaxRows = nvFW.nvUtiles.getParametroValor("MaxRows") '// '200'
                    Dim TipoConsult = nvFW.nvUtiles.getParametroValor("TipoConsult") '// '1'
                    Dim IdConsulta = nvFW.nvUtiles.getParametroValor("IdConsulta") '// 10
                    Dim URL = ""
                    Dim strHTML = ""

                    Dim strURL As String = NOSIS_url_identidad & "?TipoConsult=" & TipoConsult & "&RazonSocial=" & razonsocial & "&Doc=" & nro_docu & "&MaxRows=" & MaxRows & "&User=" & NOSIS_UID & "&Resp_EsReducida=" & Resp_EsReducida & "&Resp_DomTipoInfo=" & Resp_DomTipoInfo
                    IdConsulta = SAC_get_id_consulta("sac_identidad", nro_docu, strURL, nro_entidad, 0, CDA, NOSIS_UID)
                    strURL += "&IdConsulta=" & IdConsulta & "&Password=" & NOSIS_PWD

                    'XML.async = False
                    Dim resultado As Boolean = False

                    '//var XMLaux = new ActiveXObject("Microsoft.XMLDOM"); 
                    Dim nvHttPReq As New nvHTTPRequest
                    nvHttPReq.Method = "GET"
                    nvHttPReq.url = strURL

                    Dim XMLaux As System.Xml.XmlDocument = nvHttPReq.getResponseXML

                    URL = nvFW.nvXMLUtiles.getNodeText(XMLaux, "Pedido/URL", "")
                    Dim cont As Integer = 0
                    If URL <> "" Then
                        Do
                            cont += 1
                            'System.Threading.Thread.CurrentThread.Sleep(500)
                            nvDBUtiles.DBExecute("WAITFOR DELAY '00:00:00.5'")
                            Dim nvHTTPReq2 As New nvHTTPRequest
                            nvHTTPReq2.Method = "GET"
                            nvHTTPReq2.url = URL
                            'Dim XML2 As System.Xml.XmlDocument = nvHTTPReq2.getResponseXML
                            XML = nvHTTPReq2.getResponseXML
                            If Not XML Is Nothing Then
                                resultado = True
                                SAC_get_act_consulta(IdConsulta, XML.OuterXml)

                                If XML.SelectSingleNode("/Resultado/@TodoOk").Value.ToString.ToUpper = "NO" Then
                                    SAC_deshabilitar(IdConsulta)
                                End If

                                Exit Do
                            End If
                        Loop While cont < 4
                    End If

                    If Not resultado Then
                        strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                        XML.LoadXml(strXML)
                        SAC_deshabilitar(IdConsulta)
                    End If

                End If

                Dim NODs As System.Xml.XmlNodeList = XML.SelectNodes("Resultado/Personas/Persona")
                For Each nod As System.Xml.XmlNode In NODs
                    Dim attr As System.Xml.XmlAttribute = XML.CreateAttribute("existe")
                    attr.Value = existe.ToString.ToLower
                    nod.Attributes.Append(attr)
                Next

                nvDBUtiles.DBCloseRecordset(rsRes)

            Catch ex As Exception
                strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                XML = New System.Xml.XmlDocument
                XML.LoadXml(strXML)
            End Try

            Return XML.OuterXml

        End Function

        Public Shared Function SAC_informeBase(ByVal cuit As String, ByVal razonsocial As String, ByVal sexo As String, ByVal CDA As Integer, Optional ByVal nro_entidad As Integer = 0, Optional ByVal logTrack As String = "", Optional ByVal actualizarFuentes As Boolean = True, Optional ByVal forzar_consulta As Boolean = False) As String

            Dim XML As New System.Xml.XmlDocument
            Dim strXML As String = ""
            Dim cdaSinInformeBCRA As Boolean = False
            Dim cdaDictamen As String = ""
            Dim NroConsultaFuentes As String = ""
            Dim NOSIS_UID As String = "0"
            Dim NOSIS_PWD As String = ""
            Dim isFueExt_vigente As Boolean = False
            Dim EstadoOk As String = "SI"
            Dim NroConsulta As String = 0

            Try
                Dim Stopwatch As System.Diagnostics.Stopwatch

                Dim filtroCDA As String = ""
                If CDA <> 0 Then filtroCDA = " AND CDA = " & CDA.ToString
                '***
                Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                '***
                Dim strSQL As String = "Select * from verNosis_consulta where accion = 'sac_informe' and criterio = '" & cuit & "' and terminado = 1 and activo = 1 " & filtroCDA & " order by id_consulta desc"
                Dim rsRes As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                '***
                Stopwatch.Stop()
                Dim ts As TimeSpan = Stopwatch.Elapsed
                nvLog.addEvent("nosis_consultaDB", logTrack & ";;" & ts.TotalMilliseconds)
                '***
                If Not rsRes.EOF And forzar_consulta = False Then
                    NroConsulta = rsRes.Fields("id_consulta").Value
                    strXML = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    XML = New System.Xml.XmlDocument
                    XML.LoadXml(strXML)
                    strXML = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    XML.LoadXml(strXML)
                    If NroConsulta > 0 Then
                        nvDBUtiles.DBExecute("exec dbo.rm_nosis_consulta_registrar_entidad " & NroConsulta & "," & nro_entidad)
                    End If
                Else

                    ' Recupero valores a partir de una consulta
                    strSQL = "Select top 1 nro_entidad,nosis_cda,param_uid,param_pwd,isFueExt_vigente from [verNOSISCdas] where nosis_cda ='" & CDA.ToString & "'"
                    rsRes = DBOpenRecordset(strSQL)
                    If Not rsRes.EOF Then
                        NOSIS_UID = getParametroValor(rsRes.Fields("param_uid").Value)
                        NOSIS_PWD = getParametroValor(rsRes.Fields("param_pwd").Value)
                        isFueExt_vigente = rsRes.Fields("isFueExt_vigente").Value
                    End If
                    DBCloseRecordset(rsRes)

                    If (actualizarFuentes = True) Then
                        Try

                            NroConsultaFuentes = "-99"
                            strXML = nvFW.servicios.nvNOSIS.SAC_Actualizar_fuentes_externasBase(cuit, NOSIS_UID, NOSIS_PWD, CDA:=CDA)
                            XML = New System.Xml.XmlDocument
                            XML.LoadXml(strXML)
                            If XML.SelectSingleNode("/Respuesta/@TodoOk").Value.ToString.ToUpper = "SI" Then

                                If XML.SelectSingleNode("/Respuesta/@IdConsulta").Value <> "" Then
                                    NroConsultaFuentes = XML.SelectSingleNode("/Respuesta/@IdConsulta").Value
                                End If

                            End If

                        Catch ex As Exception

                        End Try
                    End If

                    '***
                    Dim Stopwatch3 As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                    '***

                    Dim NOSIS_url_informe As String = nvFW.nvUtiles.getParametroValor("NOSIS_URL_INFORME") '//'http://sac.nosis.com.ar/SAC_ServicioSF/Consulta.asp'
                    Dim ConsXML_Filtro As String = ""
                    Dim URL As String = ""
                    Dim strHTML As String = ""

                    Dim strURL As String = NOSIS_url_informe _
                                        & "?Usuario=" & NOSIS_UID _
                                        & "&Cons_CDA=" & CDA _
                                        & "&ConsXML_Doc=" & cuit _
                                        & "&ConsXML_RZ=" & razonsocial _
                                        & "&ConsXML_Filtro=" _
                                        & "&ConsHTML_Doc=" & cuit _
                                        & "&ConsHTML_RZ=" & razonsocial _
                                        & "&ConsHTML_Filtro=" _
                                        & "&ConsHTML_MaxResp=200" _
                                        & "&ConsXML_MaxResp=200" _
                                        & "&ConsXML_Setup=" _
                                        & "&Cons_SoloPorDoc=No"

                    NroConsulta = SAC_get_id_consulta("sac_informe", cuit, strURL, nro_entidad, 0, CDA, NOSIS_UID)
                    strURL += "&Password=" & NOSIS_PWD
                    strURL += "&NroConsulta=" & NroConsulta

                    '        XML.async = false
                    Dim resultado As Boolean = False
                    Dim nvHttpReg As New nvHTTPRequest
                    nvHttpReg.url = strURL
                    nvHttpReg.Method = "GET"
                    Dim XMLaux As System.Xml.XmlDocument = nvHttpReg.getResponseXML
                    If Not XMLaux Is Nothing Then URL = nvXMLUtiles.getNodeText(XMLaux, "Pedido/URL", "")
                    Dim cont As Integer = 0
                    If URL <> "" Then
                        Do
                            cont += 1
                            System.Threading.Thread.Sleep(500)
                            Dim nvHTTPReq2 As New nvHTTPRequest
                            nvHTTPReq2.Method = "GET"
                            nvHTTPReq2.url = URL
                            XML = nvHTTPReq2.getResponseXML
                            If Not XML Is Nothing Then

                                resultado = True

                                'Agregar NroConsulta
                                Dim oNode As System.Xml.XmlNode = XML.CreateNode(System.Xml.XmlNodeType.Element, "NroConsulta", "")
                                oNode.InnerText = NroConsulta
                                XML.SelectSingleNode("/Respuesta/Consulta/Resultado").AppendChild(oNode)

                                'Agregar NroConsulta Fuente
                                oNode = XML.CreateNode(System.Xml.XmlNodeType.Element, "NroConsultaFuentes", "")
                                oNode.InnerText = NroConsultaFuentes
                                XML.SelectSingleNode("/Respuesta/Consulta/Resultado").AppendChild(oNode)

                                SAC_get_act_consulta(NroConsulta, XML.OuterXml)

                                Exit Do
                            End If
                        Loop While (cont < 4)

                    End If

                    If Not resultado Then
                        strXML = "<Respuesta TodoOk='No' IdConsulta='-99' cdaSinInformeBCRA='false' cdaDictamen=''><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la consulta]]></Novedad></Resultado></Consulta></Respuesta>"
                        XML = New System.Xml.XmlDocument
                        XML.LoadXml(strXML)
                    End If
                    '***
                    Stopwatch3.Stop()
                    Dim ts3 As TimeSpan = Stopwatch3.Elapsed
                    nvLog.addEvent("nosis_obtener_informe", logTrack & ";;" & ts3.TotalMilliseconds)
                    '***
                End If

                If NroConsulta > 0 Then
                    strSQL = "insert into NOSIS_consulta_log(id_consulta) values(" & NroConsulta & ")"
                    nvDBUtiles.DBExecute(strSQL)
                End If
                ' nvDBUtiles.DBCloseRecordset(rsRes)

                cdaSinInformeBCRA = nvXMLUtiles.getNodeText(XML, "/Respuesta/ParteXML/Dato/CalculoCDA/Item[@Clave = ""CI"" and contains(Detalle,""Sin Info BCRA"")]", "") <> ""
                cdaDictamen = nvXMLUtiles.getNodeText(XML, "/Respuesta/ParteXML/Dato/CalculoCDA/Item[@Clave = ""DICT"" and Descrip = ""Dictamen""]/Valor", "")
                EstadoOk = nvXMLUtiles.getNodeText(XML, "/Respuesta/Consulta/Resultado/EstadoOk", "SI").ToUpper

                'Agregar a Resultado
                If Not (IsNothing(XML.SelectSingleNode("/Respuesta"))) Then

                    Dim oAtt As System.Xml.XmlAttribute
                    oAtt = XML.CreateAttribute("cdaSinInformeBCRA")
                    oAtt.Value = cdaSinInformeBCRA
                    XML.SelectSingleNode("Respuesta").Attributes.Append(oAtt)

                    oAtt = XML.CreateAttribute("cdaDictamen")
                    oAtt.Value = cdaDictamen
                    XML.SelectSingleNode("Respuesta").Attributes.Append(oAtt)

                    ' oAtt = XML.CreateAttribute("NroConsultaFuentes")
                    ' oAtt.Value = NroConsultaFuentes
                    ' XML.SelectSingleNode("Respuesta").Attributes.Append(oAtt)

                End If

                If cdaSinInformeBCRA = True And isFueExt_vigente = True Then
                    SAC_deshabilitar(NroConsulta)
                End If

                'En el caso que fallaré no guardar
                If EstadoOk = "NO" Then
                    SAC_deshabilitar(NroConsulta)
                End If


            Catch ex As Exception

                'strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                strXML = "<Respuesta TodoOk='No' IdConsulta='-99' cdaSinInformeBCRA='false' cdaDictamen=''><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la consulta]]></Novedad></Resultado></Consulta></Respuesta>"
                XML = New System.Xml.XmlDocument
                XML.LoadXml(strXML)
            End Try

            Return XML.OuterXml

        End Function

        Public Shared Function SAC_Actualizar_fuentes_externasBase(ByVal cuit As String, ByVal NOSIS_UID As String, ByVal NOSIS_PWD As String, ByVal CDA As String, Optional ByVal logTrack As String = "") As String

            Dim strXML As String = "<Respuesta TodoOk='No' IdConsulta='-99'><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la actualización de fuentes.<br>Si desea puede <b>reintentar</b> o generarlo de todas formas.]]></Novedad></Resultado></Consulta></Respuesta>"

            Try

                Dim NroConsultaFuentes As String = ""
                Dim respuesta As String = "0"

                Try
                    '***
                    Dim Stopwatch2 As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                    '***
                    Dim nvNosisFuentes As New nvFW.servicios.tnvNosisFuentes

                    If nvFW.nvUtiles.getParametroValor("nosis_actual_fuentes_version") = "2" Then
                        Dim NOSIS_FUENTES_EXTERNAS_OK As String = nvFW.nvUtiles.getParametroValor("FUENTES_EXTERNAS")
                        nvNosisFuentes.timeOut = nvFW.nvUtiles.getParametroValor("nosis_actual_fuentes_timeout")
                        nvNosisFuentes.URL = nvFW.nvUtiles.getParametroValor("nosis_actual_fuentes_url_ws") '"http://sacrelay.nosis.com/api/consultar" 
                        Dim res As String = nvNosisFuentes.ActualizarFuentesNosis_version2(NOSIS_UID, NOSIS_PWD, cuit, fuentes:=NOSIS_FUENTES_EXTERNAS_OK, CDA:=CDA)
                        Dim arrRes As String() = res.Split(",")
                        respuesta = arrRes(0)
                        NroConsultaFuentes = arrRes(1)
                    Else
                        nvNosisFuentes.URL = ""
                        nvNosisFuentes.timeOut = 10
                        respuesta = nvNosisFuentes.ActualizarFuentesNosis(cuit, "1")
                        NroConsultaFuentes = "-99"
                    End If

                    '***
                    Stopwatch2.Stop()
                    Dim ts2 As TimeSpan = Stopwatch2.Elapsed
                    nvLog.addEvent("nosis_actualizarFuentes", logTrack & ";;" & ts2.TotalMilliseconds & ";resultado=" & respuesta)

                Catch ex As Exception
                    strXML = "<Respuesta TodoOk='No' IdConsulta='-99'><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la actualización de fuentes.<br>Si desea puede <b>reintentar</b> o generarlo de todas formas.]]></Novedad></Resultado></Consulta></Respuesta>"
                    respuesta = "-1"
                End Try
                '***
                If respuesta = "1" Then
                    strXML = "<Respuesta TodoOk='Si' IdConsulta='" & NroConsultaFuentes & "'><Consulta><Resultado><EstadoOk>SI</EstadoOk><Novedad><![CDATA[]]></Novedad></Resultado></Consulta></Respuesta>"
                End If

            Catch ex As Exception

            End Try

            Dim XML = New System.Xml.XmlDocument
            XML.LoadXml(strXML)
            Return XML.OuterXml

        End Function

        Public Shared Function SAC_Actualizar_fuentes_externas(ByVal cuit As String, Optional ByVal nro_banco As String = "", Optional ByVal nro_entidad As Integer = 0, Optional ByVal CDA As Integer = 0, Optional ByVal logTrack As String = "", Optional ByVal actualizarFuentes As Boolean = True) As String

            Dim strXML As String = "<Respuesta TodoOk='No' IdConsulta='-99'><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la actualización de fuentes.<br>Si desea puede <b>reintentar</b> o generarlo de todas formas.]]></Novedad></Resultado></Consulta></Respuesta>"

            Try

                Dim NroConsultaFuentes As String = ""
                Dim NOSIS_UID As String = "0"
                Dim NOSIS_PWD As String = ""
                Dim Stopwatch As System.Diagnostics.Stopwatch
                Dim respuesta As String = "0"

                If (actualizarFuentes = True) Then

                    ' Recupero valores a partir de una consulta
                    Dim strSQL As String = "Select top 1 nro_entidad,nosis_cda,param_uid,param_pwd,isFueExt_vigente from [verNOSISCdasBancos] where "
                    If CDA > 0 Then
                        strSQL &= " nosis_cda ='" & CDA.ToString & "'"
                    End If
                    If nro_banco > 0 Then
                        strSQL &= IIf(strSQL.Substring(strSQL.Length - 6, 5) = "where", " ", " and ") & " nro_banco = " & nro_banco.ToString
                    End If
                    If nro_entidad > 0 Then
                        strSQL &= IIf(strSQL.Substring(strSQL.Length - 6, 5) = "where", " ", " and ") & " nro_entidad = " & nro_entidad.ToString
                    End If
                    strSQL &= " order by orden asc"

                    Dim rsRes As ADODB.Recordset = DBOpenRecordset(strSQL)
                    If Not rsRes.EOF Then

                        NOSIS_UID = getParametroValor(rsRes.Fields("param_uid").Value)
                        NOSIS_PWD = getParametroValor(rsRes.Fields("param_pwd").Value)
                        nro_entidad = rsRes.Fields("nro_entidad").Value
                        CDA = rsRes.Fields("nosis_cda").Value

                        DBCloseRecordset(rsRes)

                        Try
                            '***
                            Dim Stopwatch2 As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                            '***
                            Dim nvNosisFuentes As New nvFW.servicios.tnvNosisFuentes

                            If nvFW.nvUtiles.getParametroValor("nosis_actual_fuentes_version") = "2" Then
                                Dim NOSIS_FUENTES_EXTERNAS_OK As String = "1" 'nvFW.nvUtiles.getParametroValor("FUENTES_EXTERNAS_OK")
                                nvNosisFuentes.timeOut = nvFW.nvUtiles.getParametroValor("nosis_actual_fuentes_timeout")
                                nvNosisFuentes.URL = nvFW.nvUtiles.getParametroValor("nosis_actual_fuentes_url_ws") '"http://sacrelay.nosis.com/api/consultar" 
                                Dim res As String = nvNosisFuentes.ActualizarFuentesNosis_version2(NOSIS_UID, NOSIS_PWD, cuit, fuentes:=NOSIS_FUENTES_EXTERNAS_OK, CDA:=CDA)
                                Dim arrRes As String() = res.Split(",")
                                respuesta = arrRes(0)
                                NroConsultaFuentes = arrRes(1)
                            Else
                                nvNosisFuentes.URL = ""
                                nvNosisFuentes.timeOut = 10
                                respuesta = nvNosisFuentes.ActualizarFuentesNosis(cuit, "1")
                                NroConsultaFuentes = "-99"
                            End If

                            '***
                            Stopwatch2.Stop()
                            Dim ts2 As TimeSpan = Stopwatch2.Elapsed
                            nvLog.addEvent("nosis_actualizarFuentes", logTrack & ";;" & ts2.TotalMilliseconds & ";resultado=" & respuesta)

                        Catch ex As Exception
                            strXML = "<Respuesta TodoOk='No' IdConsulta='-99'><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la actualización de fuentes.<br>Si desea puede <b>reintentar</b> o generarlo de todas formas.]]></Novedad></Resultado></Consulta></Respuesta>"
                            respuesta = "-1"
                        End Try

                    Else
                        Stop
                        strXML = "<Respuesta TodoOk='No' IdConsulta='-99'><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[No se pudo realizar la actualización de fuentes.<br>Credenciales invalidas.<br>Si desea puede <b>reintentar</b> o generarlo de todas formas.]]></Novedad></Resultado></Consulta></Respuesta>"
                        respuesta = "-1"
                    End If

                End If

                '***
                If respuesta = "1" Then
                    strXML = "<Respuesta TodoOk='Si' IdConsulta='" & NroConsultaFuentes & "'><Consulta><Resultado><EstadoOk>SI</EstadoOk><Novedad><![CDATA[]]></Novedad></Resultado></Consulta></Respuesta>"
                End If

            Catch ex As Exception

            End Try

            Dim XML = New System.Xml.XmlDocument
            XML.LoadXml(strXML)
            Return XML.OuterXml

        End Function

        Public Shared Function SAC_informe_variable(ByVal cuit As String, ByVal nro_vendedor As Integer, ByVal nro_banco As String, Optional ByVal CDA As Integer = 0, Optional ByVal logTrack As String = "", Optional ByVal actualizarFuentes As Boolean = True, Optional ByVal forzar_consulta As Boolean = False) As String

            Dim strXML As String = ""

            Dim NOSIS_UID As String = ""
            Dim NOSIS_PWD As String = ""
            Dim NOSIS_VR As String = ""
            Dim NOSIS_FEX As String = ""
            Dim NOSIS_TIMEOUT As String = ""
            Dim NOSIS_FUENTES_EXTERNAS_OK As String = ""
            Dim Stopwatch As System.Diagnostics.Stopwatch
            Dim strSQL As String = ""
            Dim NroConsulta As String = 0
            Dim NroConsultaFuentes As String = 0
            Dim rsRes As ADODB.Recordset
            Dim NOSIS_url_informe As String = ""
            Dim resStrXML As String = ""

            ' Recupero valores a partir de una consulta
            ' Dim strSQL As String = "SELECT TOP 1 nosis_cda, nro_entidad, param_uid, param_pwd FROM [verNOSISCdas] WHERE nosis_cda='" & CDA & "'"
            ' Dim rsRes As ADODB.Recordset = DBOpenRecordset(strSQL)
            ' If Not rsRes.EOF Then
            ' NOSIS_UID = getParametroValor(rsRes.Fields("param_uid").Value)
            ' NOSIS_PWD = getParametroValor(rsRes.Fields("param_pwd").Value)
            ' End If
            ' DBCloseRecordset(rsRes)

            NOSIS_url_informe = nvFW.nvUtiles.getParametroValor("NOSIS_URL_INFORME_VAR") '"https://ws01.nosis.com/api/variables"
            NOSIS_VR = nvFW.nvUtiles.getParametroValor("VR_CONF_OK")
            NOSIS_FEX = "BCRA:0,AF.AP:0" '"AF.AP:30,BCRA:30" ' nvFW.nvUtiles.getParametroValor("FEX_CONF_OK")
            NOSIS_FUENTES_EXTERNAS_OK = nvFW.nvUtiles.getParametroValor("FUENTES_EXTERNAS_OK")
            NOSIS_TIMEOUT = nvFW.nvUtiles.getParametroValor("NOSIS_TIMEOUT_VAR")

            Dim login_prod As String() = nvFW.nvUtiles.getParametroValor("NOSIS_LOGIN_PROD").ToUpper.Split(",")
            If login_prod.Contains(nvFW.nvApp.getInstance().operador.login.ToUpper) Then
                NOSIS_UID = nvFW.nvUtiles.getParametroValor("NOSIS_UID_OK_VAR_PROD")
                NOSIS_PWD = nvFW.nvUtiles.getParametroValor("NOSIS_PWD_OK_VAR_PROD")
            Else
                NOSIS_UID = nvFW.nvUtiles.getParametroValor("NOSIS_UID_OK_VAR_CONT") '"62231"
                NOSIS_PWD = nvFW.nvUtiles.getParametroValor("NOSIS_PWD_OK_VAR_CONT") '"117898"
            End If


            Dim filtroCDA As String = ""
            Dim filtroBanco As String = ""

            If CDA <> 0 Then filtroCDA = " AND CDA = " & CDA
            If nro_banco <> 0 Then filtroBanco = " AND nro_banco = " & nro_banco

            Dim XML As New System.Xml.XmlDocument
            '***
            Stopwatch = System.Diagnostics.Stopwatch.StartNew()

            '***
            strSQL = "Select * from verNosis_consulta where accion = 'sac_informe_variable' and criterio = '" & cuit & "' and terminado = 1 and activo = 1 " & filtroBanco & " " & filtroCDA
            rsRes = nvDBUtiles.DBOpenRecordset(strSQL)
            '***
            Stopwatch.Stop()
            Dim ts As TimeSpan = Stopwatch.Elapsed
            nvLog.addEvent("nosis_consultaDB_variable", logTrack & ";;" & ts.TotalMilliseconds & ";" & cuit)
            '***
            If Not rsRes.EOF Then

                NroConsulta = rsRes.Fields("id_consulta").Value

                If forzar_consulta = True Then

                    strXML = SAC_deshabilitar(NroConsulta)
                    XML = New System.Xml.XmlDocument
                    XML.LoadXml(strXML)
                    If XML.SelectSingleNode("/Resultado/@TodoOk").Value.ToString.ToUpper = "SI" Then
                        NroConsulta = 0
                    End If

                Else

                    strXML = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    XML = New System.Xml.XmlDocument
                    XML.LoadXml(strXML)

                    resStrXML = XML.OuterXml

                    If NroConsulta > 0 Then
                        nvDBUtiles.DBExecute("exec dbo.rm_nosis_consulta_registrar_vendedor " & NroConsulta & "," & nro_vendedor)
                    End If

                End If

            End If
            nvDBUtiles.DBCloseRecordset(rsRes)


            If NroConsulta = 0 Or forzar_consulta = True Then

                '***
                Dim Stopwatch2 As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
                '***

                Dim RazonSocial As String = ""
                Dim Sexo As String = ""
                Dim nro_docu As Integer = 0
                strSQL = "Select top 1 sexo,ltrim(rtrim(nombre)) as nombre,nro_docu from verDBCuit where cuit = '" & cuit & "'"
                Dim rsRes2 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                If Not rsRes2.EOF Then
                    '//RazonSocial = rsRes.Fields("apellido").Value + " " + rsRes.Fields("nombres").Value
                    RazonSocial = rsRes2.Fields("nombre").Value
                    Sexo = rsRes2.Fields("sexo").Value.ToString.ToUpper
                    nro_docu = rsRes2.Fields("nro_docu").Value
                End If
                nvDBUtiles.DBCloseRecordset(rsRes2)


                Dim ConsXML_Filtro As String = ""
                Dim URL As String = ""
                Dim strHTML As String = ""

                Dim strURL As String = ""
                strURL = NOSIS_url_informe _
                                        & "?Usuario=" & NOSIS_UID _
                                        & "&documento=" & nro_docu _
                                        & "&razonsocial=" & RazonSocial _
                                        & "&sexo=" & Sexo _
                                        & "&VR=" & NOSIS_VR & "&FEX=" & NOSIS_FEX & "&timeout=" & NOSIS_TIMEOUT

                NroConsulta = SAC_get_id_consulta("sac_informe_variable", cuit, strURL, nro_vendedor, nro_banco, CDA, NOSIS_UID)
                strURL += "&token=" & NOSIS_PWD

                Dim resultado As Boolean = False
                Dim cont As Integer = 0

                Dim nvHttpReg As New nvHTTPRequest
                nvHttpReg.Method = "GET"
                nvHttpReg.url = strURL

                If strURL <> "" Then

                    Dim response As System.Net.HttpWebResponse = nvHttpReg.getResponse()
                    Dim reader As System.IO.StreamReader = New System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding("utf-8"))
                    XML.LoadXml(reader.ReadToEnd())

                    If Not XML Is Nothing Then

                        resultado = True

                        resStrXML = Replace(XML.OuterXml, "encoding=""utf-8""?", "encoding=""iso-8859-1""?")
                        resStrXML = Replace(resStrXML, "xmlns=""http://schemas.nosis.com/sac/ws01/types""", "")
                        resStrXML = Replace(resStrXML, "xmlns:i=""http://www.w3.org/2001/XMLSchema-instance""", "")
                        resStrXML = Replace(resStrXML, "i:nil=""true""", "")

                        'Agregamos el numerod de consulta
                        resStrXML = Replace(resStrXML, "</Contenido></VariablesResponse>", "<NroConsulta>" & NroConsulta & "</NroConsulta><NroConsultaFuentes>" & NroConsultaFuentes & "</NroConsultaFuentes></Contenido></VariablesResponse>")
                        SAC_get_act_consulta(NroConsulta, resStrXML)
                    End If
                End If

                '***
                Stopwatch2.Stop()
                Dim ts2 As TimeSpan = Stopwatch2.Elapsed
                nvLog.addEvent("nosis_obtener_informe_variable", logTrack & ";;" & ts2.TotalMilliseconds & ";" & cuit & ";" & nro_docu & ";" & Sexo & ";" & RazonSocial & ";" & NOSIS_UID)
                '***

                If Not resultado Then
                    'strXML = "<Resultado TodoOk='No' IdConsulta='1'><Novedades><Novedad>No se pudo realizar la consulta</Novedad></Novedades></Resultado>"
                    strXML = "<VariablesResponse TodoOk='No' IdConsulta='1'><Contenido><NroConsulta>-1</NroConsulta><NroConsultaFuentes>-1</NroConsultaFuentes><Resultado><Estado>-1</Estado><Novedad>No se pudo realizar la consulta</Novedad></Resultado></Contenido></VariablesResponse>"
                    XML = New System.Xml.XmlDocument
                    XML.LoadXml(strXML)
                End If
            End If




            If NroConsulta > 0 Then
                strSQL = "insert into NOSIS_consulta_log(id_consulta) values(" & NroConsulta & ")"
                nvDBUtiles.DBExecute(strSQL)
            End If

            Return resStrXML

        End Function

        Public Shared Function SAC_deshabilitar(ByVal id_consulta As Integer) As String
            Try
                Dim SQL As String = "UPDATE ide SET nosis_activo = 0 " &
                " FROM NOSIS_consulta ide " &
                " INNER JOIN NOSIS_consulta inf ON inf.CDA = ide.CDA " &
                "   AND inf.nro_entidad = ide.nro_entidad " &
                "   AND inf.nosis_activo = ide.nosis_activo " &
                "   AND inf.terminado = ide.terminado " &
                "   AND inf.id_consulta = " & id_consulta & " " &
                " WHERE ide.accion = 'sac_identidad' " &
                "   AND ide.nosis_activo = 1 " &
                "   AND ide.terminado = 1 " &
                "   AND ide.criterio = CAST(CAST(SUBSTRING(SUBSTRING(inf.criterio, 3, LEN(inf.criterio)), 1, LEN(SUBSTRING(inf.criterio, 3, LEN(inf.criterio))) - 1) AS int) AS varchar(11))"
                DBExecute(SQL)

                SQL = "UPDATE nosis_consulta SET nosis_activo = 0 WHERE id_consulta = " & id_consulta
                DBExecute(SQL)

                Return "<Resultado TodoOk='Si' IdConsulta='" & id_consulta & "'><Novedades><Novedad>La consulta con ID: " & id_consulta & " fue deshabilitada con éxito</Novedad></Novedades></Resultado>"
            Catch ex As Exception
                Return "<Resultado TodoOk='No' IdConsulta='" & id_consulta & "'><Novedades><Novedad>No se pudo deshabilitar la consulta con ID: " & id_consulta & "</Novedad></Novedades></Resultado>"
            End Try
        End Function

    End Class

    Public Class nvNosisUtiles
        Public Shared Function SAC_informe_guardar_html(id_tipo As Integer, nro_archivo_id_tipo As Integer, archivo_descripcion As String, nro_consulta As Integer) As tError

            Dim err As New tError

            Try
                Dim nro_def_archivo As Integer = 0
                Dim nro_def_detalle As Integer = 0
                Dim strSQL As String = " select lc.nro_def_archivo,dd.nro_def_detalle from archivo_leg_cab lc " &
                                        "join archivos_def_detalle dd on lc.nro_def_archivo = dd.nro_def_archivo " &
                                        "where nro_archivo_id_tipo = " & nro_archivo_id_tipo & " and id_tipo = " & id_tipo & " and dd.archivo_descripcion like '" & archivo_descripcion & "' "

                Dim rsRes As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                If Not rsRes.EOF Then
                    nro_def_archivo = rsRes.Fields("nro_def_archivo").Value
                    nro_def_detalle = rsRes.Fields("nro_def_detalle").Value
                Else
                    err.numError = 99
                    err.titulo = "Guardar informe NOSIS"
                    err.mensaje = "<Respuesta TodoOk='No' IdConsulta='-99'><Consulta><Resultado><EstadoOk>NO</EstadoOk><Novedad><![CDATA[Imposible realizar la acción. No existe definicion para insertar informe Nosis]]></Novedad></Resultado></Consulta></Respuesta>"
                    Return err
                End If
                nvDBUtiles.DBCloseRecordset(rsRes)

                strSQL = "Select * from verNosis_consulta where id_consulta = " & nro_consulta.ToString
                rsRes = nvDBUtiles.DBOpenRecordset(strSQL)
                If Not rsRes.EOF Then

                    Dim strXML As String = nvFW.nvConvertUtiles.BytesToString(rsRes.Fields("xml_resultado").Value)
                    Dim XML As New System.Xml.XmlDocument
                    XML.LoadXml(strXML)
                    Dim strHTML As String = XML.SelectSingleNode("Respuesta/ParteHTML").OuterXml
                    Dim BinaryData As Byte() = System.Text.Encoding.GetEncoding("iso-8859-1").GetBytes(strHTML)

                    Dim archivo As New tnvArchivo(BinaryData:=BinaryData, id_tipo:=id_tipo, nro_archivo_id_tipo:=nro_archivo_id_tipo, nro_def_archivo:=nro_def_archivo, nro_def_detalle:=nro_def_detalle, file_ext:=".html")
                    err = archivo.save()
                    If err.numError = 0 Then

                        Dim nro_archivo As String = err.params("nro_archivo")
                        'strSQL = "INSERT INTO archivos_parametros (nro_archivo,parametro,parametro_valor,fe_actualizacion,nro_operador) " & vbCrLf
                        'strSQL += "SELECT " & nro_archivo & " as nro_archivo,parametro,'' as parametro_valor,getdate() as fe_actualizacion,dbo.rm_nro_operador() as nro_operador " & vbCrLf
                        'strSQL += "FROM archivos_parametro_def where archivo_descripcion = 'NOSIS'" & vbCrLf
                        ' nvDBUtiles.DBExecute(strSQL)
                        strSQL = ""
                        Dim nodes As System.Xml.XmlNodeList = XML.SelectNodes("Respuesta/ParteXML/Dato/CalculoCDA/Item")
                        For Each n As System.Xml.XmlElement In nodes
                            Dim Clave As String = nvUtiles.isNUll(n.GetAttribute("Clave"), "")
                            If Clave = "COMPMENSUALES" Or Clave = "Valor.SCO" Or Clave = "Valor.NSE" Or Clave = "DICT" Then
                                Dim Valor As String = nvXMLUtiles.getNodeText(n, "Valor", "")
                                strSQL += "UPDATE archivos_parametros SET fe_actualizacion = getdate(), parametro_valor = '" & Valor & "' WHERE nro_archivo = '" & nro_archivo & "' and parametro = '" & Clave & "'" & vbCrLf
                            End If
                        Next
                        strSQL += "UPDATE archivos_parametros SET fe_actualizacion = getdate(), parametro_valor = '" & nro_consulta & "' WHERE nro_archivo = '" & nro_archivo & "' and parametro = 'NroConsulta'" & vbCrLf

                        nvFW.nvDBUtiles.DBExecute(strSQL)

                    End If
                Else
                    err.numError = 99
                    err.titulo = "Guardar informe NOSIS"
                    err.mensaje = "Imposible realizar la acción. El número de consulta ingresado no existe"
                End If
                nvDBUtiles.DBCloseRecordset(rsRes)

            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Guardar informe NOSIS"
                err.mensaje = "Salida por excepcion"
            End Try

            Return err

        End Function

    End Class

    Public Class tnvNosisFuentes

        Public _URL As String = "http://sacrelay.nosis.com/api/consultar"
        Public _timeOut As Integer = 20
        Public salida As Boolean
        Public resultado As Integer
        Public Function ActualizarFuentesNosis(ByVal documento As String, Optional fuentes As String = "") As Integer
            Dim url As String = _URL + "&documento=" + documento
            resultado = 0
            Dim thread As New System.Threading.Thread(Sub()
                                                          Using browser As New System.Windows.Forms.WebBrowser()

                                                              browser.ScriptErrorsSuppressed = True
                                                              browser.AllowNavigation = True
                                                              browser.Navigate(url)
                                                              If fuentes = "" Then fuentes = "1,2,3,4,5,6,7,8,9,10"
                                                              Dim arfuentes As String() = fuentes.Split(",")

                                                              AddHandler browser.DocumentCompleted, New WebBrowserDocumentCompletedEventHandler(AddressOf browser_DocumentCompleted)

                                                              While browser.ReadyState <> WebBrowserReadyState.Complete
                                                                  System.Windows.Forms.Application.DoEvents()
                                                              End While

                                                              System.Windows.Forms.Application.DoEvents()

                                                              Dim ini As Date = Now
                                                              Dim timeout As Boolean = True
                                                              Dim finalizado_count As Integer = 0
                                                              Dim error_count As Integer = 0
                                                              While Now < DateAdd(DateInterval.Second, _timeOut, ini)
                                                                  Try

                                                                      Dim pos As Integer = browser.Document.Body.OuterHtml.IndexOf("Finalizado</")
                                                                      Do While pos <> -1
                                                                          finalizado_count += 1
                                                                          pos = browser.Document.Body.OuterHtml.IndexOf("Finalizado</", pos + 1)
                                                                      Loop
                                                                      pos = browser.Document.Body.OuterHtml.IndexOf("Actualizado</")
                                                                      Do While pos <> -1
                                                                          finalizado_count += 1
                                                                          pos = browser.Document.Body.OuterHtml.IndexOf("Actualizado</", pos + 1)
                                                                      Loop

                                                                      pos = browser.Document.Body.OuterHtml.IndexOf("Error</")
                                                                      Do While pos <> -1
                                                                          error_count += 1
                                                                          pos = browser.Document.Body.OuterHtml.IndexOf("Error</", pos + 1)
                                                                      Loop

                                                                      If (finalizado_count + error_count) = arfuentes.Count Or browser.Document.Body.OuterHtml.IndexOf("no se encuentran disponibles") > -1 Or browser.Document.Body.OuterHtml.IndexOf("Ocurrió un error. Por favor intente nuevamente") > -1 Then
                                                                          timeout = False
                                                                          Exit While
                                                                      End If

                                                                      'If Not (browser.Document.Body.OuterHtml.IndexOf("Finalizado") = -1 And browser.Document.Body.OuterHtml.IndexOf("no se encuentran disponibles") = -1 And browser.Document.Body.OuterHtml.IndexOf("Error") = -1 And browser.Document.Body.OuterHtml.IndexOf("Ocurrió un error. Por favor intente nuevamente") = -1) Then
                                                                      '    timeout = False
                                                                      '    Exit While
                                                                      'End If
                                                                  Catch ex As Exception
                                                                      resultado = 0
                                                                  End Try
                                                                  System.Windows.Forms.Application.DoEvents()
                                                                  System.Threading.Thread.Sleep(100)
                                                              End While
                                                              If finalizado_count = arfuentes.Count Then
                                                                  resultado = 1
                                                              Else
                                                                  If (timeout) Then
                                                                      resultado = -1
                                                                  Else
                                                                      resultado = 0
                                                                  End If
                                                              End If
                                                              'If browser.Document.Body.OuterHtml.IndexOf("Finalizado") <> -1 Then
                                                              '    resultado = 1
                                                              'Else
                                                              '    If (timeout) Then
                                                              '        resultado = -1
                                                              '    Else
                                                              '        resultado = 0
                                                              '    End If
                                                              'End If
                                                          End Using
                                                      End Sub)
            thread.SetApartmentState(Threading.ApartmentState.STA)
            thread.Start()
            thread.Join()
            'System.Threading.Thread.Sleep(200)
            Return resultado & ",0"
        End Function

        Public Shared Function SAC_get_fuentes_id_consulta(ByVal criterio As String, ByVal pvURL As String, ByVal fuentes As String, ByVal NOSIS_UID As String, ByVal Cons_CDA As Integer, ByVal pedido As String, ByVal resultado As String, ByVal resJson As String) As String

            resJson = resJson.Replace(vbCrLf, "")
            resJson = resJson.Replace(vbCr, "")
            resJson = resJson.Replace(vbLf, "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_NOSIS_consulta_fuentes", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@cuit", ADODB.DataTypeEnum.adVarChar, 1, 255, criterio)
            cmd.addParameter("@url_consulta", ADODB.DataTypeEnum.adVarChar, 1, 0, pvURL)
            cmd.addParameter("@fuentes", ADODB.DataTypeEnum.adVarChar, 1, 0, fuentes)
            cmd.addParameter("@NOSIS_UID", ADODB.DataTypeEnum.adInteger, 1, 0, NOSIS_UID)
            cmd.addParameter("@cda", ADODB.DataTypeEnum.adInteger, 1, 0, Cons_CDA)
            cmd.addParameter("@pedido", ADODB.DataTypeEnum.adInteger, 1, 0, pedido)
            cmd.addParameter("@resultado", ADODB.DataTypeEnum.adInteger, 1, 0, resultado)
            cmd.addParameter("@res_json", ADODB.DataTypeEnum.adVarChar, 1, 8000, resJson.ToString)

            Dim res As ADODB.Recordset = cmd.Execute()
            Dim id_consulta As String = "0"
            If Not res.EOF Then
                id_consulta = res.Fields("id_consulta").Value
            End If

            Return id_consulta

        End Function

        Public Shared seguimientoActualizarFuentesNosis As New Dictionary(Of String, String)
        Public Function ActualizarFuentesNosis_version2(NOSIS_UID As String, NOSIS_PWD As String, cuit As String, Optional fuentes As String = "", Optional CDA As String = "", Optional isAsync As Boolean = False) As String

            Dim URL As String = _URL
            Dim strHTML As String = ""
            Dim resultado As String = -1
            Dim Identificador As String = ""
            Dim ProximoPedido As Integer = 0
            Dim cont As Integer = 0
            Dim fuente As String = ""
            Dim fuente_valor As String = ""
            Dim response As Net.HttpWebResponse = Nothing
            Dim responseJson As String = ""
            Dim oXML As New System.Xml.XmlDocument
            Dim rXML As System.Xml.XmlReader
            Dim fuente_ok As Boolean = False
            Dim strURL As String = ""

            If fuentes = "" Then fuentes = "1,2,3,4,5,6,7,8,9,10"
            Dim arfuentes As String() = fuentes.Split(",")

            Dim thread As New System.Threading.Thread(Sub()

                                                          Dim nvHttpReg As New nvHTTPRequest
                                                          nvHttpReg.Method = "GET"
                                                          Dim inicio As Date = Now

                                                          Do
                                                              cont += 1

                                                              If ProximoPedido > 0 Then
                                                                  System.Threading.Thread.Sleep(ProximoPedido)
                                                              End If

                                                              If Identificador <> "" Then
                                                                  strURL = URL & "?Identificador=" & Identificador
                                                              Else
                                                                  strURL = URL _
                                                                              & "?Usuario=" & NOSIS_UID _
                                                                              & "&password=" & NOSIS_PWD _
                                                                              & "&documento=" & cuit _
                                                                              & "&fuentes=" & fuentes
                                                              End If

                                                              If strURL <> "" Then

                                                                  nvHttpReg.url = strURL
                                                                  response = nvHttpReg.getResponse()
                                                                  responseJson = ""

                                                                  If Not response Is Nothing Then
                                                                      If response.StatusCode = 200 Then
                                                                          Try
                                                                              Dim reader As System.IO.StreamReader = New System.IO.StreamReader(response.GetResponseStream())
                                                                              responseJson = reader.ReadToEnd()
                                                                          Catch ex As Exception
                                                                              oXML.LoadXml("<Respuesta><![CDATA[" & ex.Message.ToString & "]]></Respuesta>")
                                                                              resultado = -1
                                                                              Exit Do
                                                                          End Try
                                                                      Else
                                                                          oXML.LoadXml("<Respuesta><![CDATA[El WS respondio: " & response.StatusCode.ToString & "]]></Respuesta>")
                                                                          resultado = -1
                                                                          Exit Do
                                                                      End If
                                                                  Else
                                                                      oXML.LoadXml("<Respuesta><![CDATA[El WS no contestó]]></Respuesta>")
                                                                      resultado = -1
                                                                      Exit Do
                                                                  End If

                                                                  rXML = System.Runtime.Serialization.Json.JsonReaderWriterFactory.CreateJsonReader(System.Text.Encoding.GetEncoding("iso-8859-1").GetBytes(responseJson), New System.Xml.XmlDictionaryReaderQuotas())
                                                                  Try
                                                                      oXML.Load(rXML)
                                                                      Identificador = nvXMLUtiles.getNodeText(oXML, "/root/Identificador", "")
                                                                      resultado = IIf(nvXMLUtiles.getNodeText(oXML, "/root/Resultado", "false") = "false", -1, 0)
                                                                      ProximoPedido = Convert.ToInt32(nvXMLUtiles.getNodeText(oXML, "/root/ProximoPedido", "5")) * 1000

                                                                      fuente_ok = True
                                                                      Dim fuentes_servicio As String = ""

                                                                      Dim objFuentes = oXML.SelectNodes("/root/Fuentes")(0)
                                                                      If Not objFuentes Is Nothing Then
                                                                          For Each n As System.Xml.XmlElement In objFuentes
                                                                              fuente = nvUtiles.isNUll(n.GetAttribute("item"), "")
                                                                              fuente_valor = nvUtiles.isNUll(n.InnerText, "")
                                                                              If arfuentes.Contains(fuente) Then
                                                                                  If fuente_valor <> "10" Then
                                                                                      fuente_ok = False
                                                                                  End If
                                                                              End If

                                                                              ' en el caso que el servicio no exponfa las fuentes solicitadas: acumulamos
                                                                              If fuentes_servicio = "" Then
                                                                                  fuentes_servicio = fuente
                                                                              Else
                                                                                  fuentes_servicio = "," & fuente
                                                                              End If

                                                                          Next
                                                                      End If

                                                                      ' en el caso que el servicio no exponda las fuentes solicitadas: comparamos
                                                                      For Each f As String In arfuentes
                                                                          If fuentes_servicio.IndexOf(f) = -1 Then
                                                                              fuente_ok = False
                                                                          End If
                                                                      Next

                                                                      If resultado = -1 Then
                                                                          Exit Do
                                                                      End If

                                                                      If fuente_ok = True Then
                                                                          resultado = 1
                                                                          Exit Do
                                                                      End If

                                                                  Catch ex As Exception
                                                                      oXML.LoadXml("<Respuesta><Res_XML><![CDATA[" & rXML.ToString & "]]></Res_XML><Mensaje><![CDATA[" & ex.Message.ToString & "]]></Mensaje></Respuesta>")
                                                                      resultado = -1
                                                                      Exit Do
                                                                  End Try

                                                              End If

                                                              If Now > DateAdd(DateInterval.Second, _timeOut, inicio) Then
                                                                  resultado = -1
                                                                  Exit Do
                                                              End If

                                                          Loop While (cont < 5)

                                                          If resultado <> 1 Then
                                                              resultado = -1
                                                          End If

                                                      End Sub)

            thread.SetApartmentState(Threading.ApartmentState.STA)
            thread.Start()

            Dim NroConsulta As String = "-99"
            If isAsync = False Then
                thread.Join()
                NroConsulta = SAC_get_fuentes_id_consulta(cuit, URL, fuentes, NOSIS_UID, CDA, cont.ToString, resultado, oXML.OuterXml)
            End If

            Return resultado.ToString & "," & NroConsulta.ToString

        End Function


        Private Sub browser_DocumentCompleted(ByVal sender As Object, ByVal e As WebBrowserDocumentCompletedEventArgs)
            Dim browser As WebBrowser = TryCast(sender, WebBrowser)
            browser.Refresh(WebBrowserRefreshOption.Completely)
        End Sub

        Public Property URL()
            Get
                Return Me._URL
            End Get
            Set(ByVal value)
                Me._URL = value
            End Set
        End Property
        Public Property timeOut()
            Get
                Return Me._timeOut
            End Get
            Set(ByVal value)
                Me._timeOut = value
            End Set
        End Property
    End Class
End Namespace
