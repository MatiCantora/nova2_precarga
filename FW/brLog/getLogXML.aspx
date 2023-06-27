<%@ Page Language="vb" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    Response.Expires = 0
    Dim accion As String = nvUtiles.obtenerValor("accion")
    Dim criterio As String = nvUtiles.obtenerValor("criterio")

    Dim strXML As String = ""
    Dim st As New ADODB.Stream
    
    Select Case accion.ToLower()

        Case "brlog"
            Dim oXML As New System.Xml.XmlDocument
            oXML.LoadXml(criterio)
            Dim NODs As System.Xml.XmlNodeList = oXML.SelectNodes("brLogs/brLog")
            Dim NodFilter As System.Xml.XmlNode
            Dim id_nv_log_evento As String
            Dim contenido As String

            For Each NodFilter In NODs
                id_nv_log_evento = NodFilter.Attributes("id_nv_log_evento").Value
                contenido = NodFilter.Attributes("fe_evento").Value + ";"
                contenido += NodFilter.InnerText
                nvLog.addEvent(id_nv_log_evento, contenido)
            Next
        Case "brlogcfg"

            Dim strSQL = "select le.id_nv_log_evento, case when sum(case when brEnviar = 0 then 0 else 1 end) > 0 then 1 else 0 end as brEnviar from  nv_log_sistema ls "
            strSQL += "left outer join verServidor_alias sp on ls.cod_servidor = sp.cod_servidor "
            strSQL += "join nv_log_sistema_evento se on ls.id_nv_log_sistema = se.id_nv_log_sistema "
            strSQL += "join nv_log_evento le on se.id_nv_log_evento = le.id_nv_log_evento "
            strSQL += "left outer join nv_log_login l on ls.id_nv_log_sistema = l.id_nv_log_sistema "
            strSQL += "where ((servidor_alias = '" + nvApp.server_name + "') or (global = 1)) and activo = 1 and aBrowser = 1 and ((allUsers = 0 and [login] = '" + nvApp.operador.login + "') or (allUsers = 1)) "
            strSQL += "group by le.id_nv_log_evento"

            Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
            strXML = "<brlogcfg><eventos>"
            While (Not (rs.EOF))
                strXML += "<evento id_nv_log_evento='" + rs.Fields("id_nv_log_evento").Value.ToString + "' brEnviar='" + rs.Fields("brEnviar").Value.ToString + "' />"
                rs.MoveNext()
            End While
            strXML += "</eventos></brlogcfg>"

            nvDBUtiles.DBCloseRecordset(rs)

        Case "brlogvalidar"
            
            Dim tAcceso As Integer = 0
            Dim Err As New nvFW.tError
            Err.numError = 0
            Err.mensaje = ""
            Dim objXML = Server.CreateObject("Microsoft.XMLDOM")
            objXML.loadXML(criterio)

            Try
                'objXML.selectNodes("/criterio/UID")
                Dim UID As String = objXML.selectNodes("/criterio/UID")(0).text
                Dim PWD As String = objXML.selectNodes("/criterio/PWD")(0).text
                Dim permiso_grupo = objXML.selectNodes("/criterio/permiso_grupo")(0).text
                Dim nro_permiso = objXML.selectNodes("/criterio/nro_permiso")(0).text

                'Err = nv_login(nvSession.getContents("app_cod_sistema"), 'login', UID, PWD, '', 0, '')

                Err = nvLogin.execute(nvApp, "login", UID, PWD, "", 0, "", "")

                If (Err.numError = 0) Then
                    If (permiso_grupo <> "" And nro_permiso > 0) Then
                        Dim strSQL As String = "select tiene_permiso from FW_Permisos_verOperadores_accesos where login = '" + UID + "' and permiso_grupo = '" + permiso_grupo + "' and nro_permiso = " + nro_permiso
                        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                        If (rs.EOF = False) Then
                            tAcceso = IIf(rs.Fields("tiene_permiso").Value > 0, 1, 0)

                            If (tAcceso = 0) Then
                                Err.numError = 999
                                Err.mensaje = "No posee los permisos necesarios para realizar esta acción.</br>Póngase en contacto con el administrador del sistema"
                            End If

                        Else
                            Err.numError = 998
                            Err.mensaje = "No se definieron los permisos para la verificación"
                        End If

                    Else
                        Err.numError = 996
                        Err.mensaje = "El usuario no tiene permisos"
                    End If

                End If

            Catch ex As Exception
                Err.numError = 997
                Err.mensaje = "Error"
                Err.parse_error_script(ex)
                Err.response()

            End Try

            strXML = "<xml xmlns:s='uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882' " &
                            "xmlns:dt='uuid:C2F41010-65B3-11d1-A29F-00AA00C14882' " &
                            " xmlns:rs='urn:schemas-microsoft-com:rowset' " &
                            "xmlns:z='#RowsetSchema'><rs:data>" &
                            "<z:row numError='" & Err.numError.ToString() & "' tAcceso ='" & tAcceso.ToString() & "' >" &
                            "<mensaje><![CDATA[" & Err.mensaje & "]]></mensaje>" &
                            "</z:row></rs:data></xml>"


            'Dim strSQL = "select le.id_nv_log_evento, case when sum(case when brEnviar = 0 then 0 else 1 end) > 0 then 1 else 0 end as brEnviar from  nv_log_sistema ls "
            'strSQL += "left outer join verServidor_alias sp on ls.cod_servidor = sp.cod_servidor "
            'strSQL += "join nv_log_sistema_evento se on ls.id_nv_log_sistema = se.id_nv_log_sistema "
            'strSQL += "join nv_log_evento le on se.id_nv_log_evento = le.id_nv_log_evento "
            'strSQL += "left outer join nv_log_login l on ls.id_nv_log_sistema = l.id_nv_log_sistema "
            'strSQL += "where ((servidor_alias = '" + nvApp.server_name + "') or (global = 1)) and activo = 1 and aBrowser = 1 and ((allUsers = 0 and [login] = '" + nvApp.operador.login + "') or (allUsers = 1)) "
            'strSQL += "group by le.id_nv_log_evento"

            'Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
            'strXML = "<brlogcfg><eventos>"
            'While (Not (rs.EOF))
            '    strXML += "<evento id_nv_log_evento='" + rs.Fields("id_nv_log_evento").Value.ToString + "' brEnviar='" + rs.Fields("brEnviar").Value.ToString + "' />"
            '    rs.MoveNext()
            'End While
            'strXML += "</eventos></brlogcfg>"

            'nvDBUtiles.DBCloseRecordset(rs)

        Case Else
            
            Dim e As New nvFW.tError
            e.numError = 1001
            e.titulo = "Error en la consulta"
            e.comentario = "La acción es deconocida"
            e.debug_src = "getLogXML"
            e.debug_desc = "accion='" & accion & "'; criterio='" & criterio & "'"
            e.response()
    End Select
    nvFW.nvXMLUtiles.responseXML(Response, strXML)
    'nvXMLUtiles.responseXML()
    Response.End()

%>