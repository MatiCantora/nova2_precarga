<%@Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Stop
    Dim err As New tError

    
    
    
    ''** Guardar Terminos y Condiciones de Yacare en "ids_res_config"
    'Dim path_file As String = Server.MapPath(".") & "/consultas/tyc_yacare.html"    ' Server.MapPath(".") devuelve el directorio fisico actual
    'Dim full_path As String = IO.Path.GetFullPath(path_file)
    'Dim file As Byte() = IO.File.ReadAllBytes(full_path)

    'Dim ids_cli_id As Integer = Me.operador.ids_cli_id
    'Dim ids_res_id As String = "YacareApp"
    'Dim ids_event_id As String = "uid_create"

    ''err.params("file") = file
    ''err.params("ids_cli_id") = ids_cli_id
    ''err.params("ids_res_id") = ids_res_id
    ''err.params("ids_event_id") = ids_event_id
    ''err.response()

    'Dim strSQL As String = String.Format("UPDATE ids_res_config SET ids_legal_binary=?, ids_legal_content_type='text/html' WHERE ids_cli_id={0} AND ids_res_id='{1}' AND ids_event_id='{2}'", ids_cli_id, ids_res_id, ids_event_id)
    'Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText, emunDBType.db_app)

    'Try
    '    cmd.Parameters(0).Type = ADODB.DataTypeEnum.adLongVarBinary
    '    cmd.Parameters(0).Size = file.Count
    '    cmd.Parameters(0).AppendChunk(file)

    '    cmd.Execute()
    'Catch ex As Exception
    '    err.parse_error_script(ex)
    '    err.titulo = "Error en TyC"
    '    err.mensaje = "No se guardaron los TyC de Yacaré"
    'End Try

    

    
    'Dim count As Integer = 50

    'For i As Integer = 0 To count
    '    err.params("param_" & i) = nvConvertUtiles.getUniqueId()
    'Next

    'Dim trsRequest As trsParam = nvUtiles.RequestTotrsParam()
    'err.params = trsRequest
    'err.params("trsRequest_xml") = trsRequest.toXML(False)

    'Dim selfie_gestures_xml As String = nvUtiles.getParametroValor("IDS_SELFIE_GESTURES_LIMITS", "")

    'If selfie_gestures_xml = "" Then
    '    err.numError = -99
    '    err.titulo = "Error de Parámetro"
    '    err.mensaje = "No se pudo obtener el valor del parametro solicitado"
    '    err.response()
    'End If

    'Dim xml As New System.Xml.XmlDocument
    'xml.LoadXml(selfie_gestures_xml)

    'Dim param_node As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(xml, "/parametros/parametro")
    'Dim parametro As trsParam
    'Dim gesture_type As String

    'For Each node As System.Xml.XmlNode In param_node
    '    parametro = New trsParam
    '    gesture_type = nvXMLUtiles.getNodeText(node, "gesture_type", "")

    '    If gesture_type = "" Then Continue For

    '    parametro("gesture_type") = gesture_type
    '    parametro("pitch_min") = CSng(nvXMLUtiles.getNodeText(node, "pitch_min", "-99"))
    '    parametro("pitch_max") = CSng(nvXMLUtiles.getNodeText(node, "pitch_max", "-99"))
    '    parametro("roll_min") = CSng(nvXMLUtiles.getNodeText(node, "roll_min", "-99"))
    '    parametro("roll_max") = CSng(nvXMLUtiles.getNodeText(node, "roll_max", "-99"))
    '    parametro("yaw_min") = CSng(nvXMLUtiles.getNodeText(node, "yaw_min", "-99"))
    '    parametro("yaw_max") = CSng(nvXMLUtiles.getNodeText(node, "yaw_max", "-99"))

    '    err.params(gesture_type) = parametro
    'Next

    

    err.response()
%>