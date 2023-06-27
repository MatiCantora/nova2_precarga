<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%
    Dim errr As New nvFW.tError
    Dim nro_docu As Integer = "28240681"
    Dim sexo As String = "M"
    Dim robot As New nvFW.servicios.Robots.PredictorPeype
    Dim credenciales As New nvFW.servicios.Robots.PredictorCredenciales
    credenciales.user = "wokcred"
    credenciales.pwd = "jfnc93b2"
    Stop
    ''errr = robot.consultar("27331227450", credenciales)
    Dim ret As Dictionary(Of String, String) = robot.consultar(nro_docu, "M", credenciales, errr)
    If (errr.numError = 0) Then
        Dim actividad = ret.Item("actividad_empleador")
    End If

    'xmlresponse = errr.params("response")
    'Dim ParteXML As System.Xml.XmlDocument
    'ParteXML = New System.Xml.XmlDocument
    'ParteXML.LoadXml(xmlresponse)
    'Dim XmlNodeList As System.Xml.XmlNodeList
    'Dim node As System.Xml.XmlNode
    'XmlNodeList = ParteXML.DocumentElement.SelectNodes("/RESULTADO/row")
    'For Each node In XmlNodeList
    '    pyp_actividad_empleador = node.SelectSingleNode("actividad_empleador").InnerText
    '    pyp_posee_automotor = node.SelectSingleNode("posee_automotor").InnerText
    '    pyp_cuil = node.SelectSingleNode("cuil").InnerText
    '    pyp_documento = node.SelectSingleNode("documento").InnerText
    '    pyp_sexo = node.SelectSingleNode("sexo").InnerText
    '    pyp_apenom = node.SelectSingleNode("apenom").InnerText
    '    pyp_apellido = node.SelectSingleNode("apellido").InnerText
    '    pyp_nombre = node.SelectSingleNode("nombre").InnerText
    '    pyp_nacionalidad = node.SelectSingleNode("nacionalidad").InnerText
    '    pyp_fecha_nac = node.SelectSingleNode("fecha_nac").InnerText
    '    pyp_fecha_fallecido = node.SelectSingleNode("fecha_fallecido").InnerText
    '    pyp_calle = node.SelectSingleNode("calle").InnerText
    '    pyp_altura = node.SelectSingleNode("altura").InnerText
    '    pyp_piso = node.SelectSingleNode("piso").InnerText
    '    pyp_dpto = node.SelectSingleNode("dpto").InnerText
    '    pyp_cp = node.SelectSingleNode("cp").InnerText
    '    pyp_localidad = node.SelectSingleNode("localidad").InnerText
    '    pyp_provincia = node.SelectSingleNode("provincia").InnerText
    '    pyp_score = node.SelectSingleNode("score").InnerText
    '    pyp_cant_empleadores = node.SelectSingleNode("cant_empleadores").InnerText
    '    pyp_ocupacion = node.SelectSingleNode("ocupacion").InnerText
    '    pyp_ocupacion_au = node.SelectSingleNode("ocupacion_au").InnerText
    '    pyp_ocupacion_mn = node.SelectSingleNode("ocupacion_mn").InnerText
    '    pyp_ocupacion_jb = node.SelectSingleNode("ocupacion_jb").InnerText
    '    pyp_ocupacion_rd = node.SelectSingleNode("ocupacion_rd").InnerText
    '    pyp_ocupacion_ed = node.SelectSingleNode("ocupacion_ed").InnerText
    '    pyp_pi21 = node.SelectSingleNode("pi21").InnerText
    '    pyp_pi47 = node.SelectSingleNode("pi47").InnerText
    '    pyp_imp_ganancias = node.SelectSingleNode("imp_ganancias").InnerText
    '    pyp_imp_iva = node.SelectSingleNode("imp_iva").InnerText
    '    pyp_monotributo = node.SelectSingleNode("monotributo").InnerText
    '    pyp_integrante_soc = node.SelectSingleNode("integrante_soc").InnerText
    '    pyp_empleador = node.SelectSingleNode("empleador").InnerText
    '    pyp_cuit_empleador = node.SelectSingleNode("cuit_empleador").InnerText
    '    pyp_periodo = node.SelectSingleNode("periodo").InnerText
    '    pyp_razon_social_empleador = node.SelectSingleNode("razon_social_empleador").InnerText
    '    pyp_tipo_empleador = node.SelectSingleNode("tipo_empleador").InnerText
    '    pyp_mora_fecha_morosidad = node.SelectSingleNode("mora_fecha_morosidad").InnerText
    '    pyp_mora_fecha_pago = node.SelectSingleNode("mora_fecha_pago").InnerText
    '    pyp_mora_entidad = node.SelectSingleNode("mora_entidad").InnerText
    '    pyp_entidad_bcra_vig = node.SelectSingleNode("entidad_bcra_vig").InnerText
    '    pyp_sit_bcra_max_vig = node.SelectSingleNode("situacion_max_vig").InnerText
    '    pyp_deuda_bcra_max_vig = node.SelectSingleNode("deuda_max_vig").InnerText
    '    pyp_cant_ban_oper = node.SelectSingleNode("cant_ban_oper").InnerText
    '    pyp_st_ult_6m_bcra = node.SelectSingleNode("st_ult_6m_bcra").InnerText
    '    pyp_mo_st_ult_6m_bcra = node.SelectSingleNode("mo_st_ult_6m_bcra").InnerText
    '    pyp_st_ult_7_12_bcra = node.SelectSingleNode("st_ult_7_12_bcra").InnerText
    '    pyp_mo_st_ult_7_12_bcra = node.SelectSingleNode("mo_st_ult_7_12_bcra").InnerText
    '    pyp_st_12_24m_bcra = node.SelectSingleNode("st_12_24m_bcra").InnerText
    '    pyp_mo_st_12_24m_bcra = node.SelectSingleNode("mo_st_12_24m_bcra").InnerText
    '    pyp_cheques_rechazados = node.SelectSingleNode("cheques_rechazados").InnerText
    '    pyp_cantidad_cheques_rechazados = node.SelectSingleNode("cantidad_cheques_rechazados").InnerText
    '    pyp_monto_cheques_rechazados = node.SelectSingleNode("monto_cheques_rechazados").InnerText
    '    pyp_auh = node.SelectSingleNode("auh").InnerText
    '    pyp_cod_provincia = node.SelectSingleNode("cod_provincia").InnerText
    '    pyp_periodo_alta_ult_trabajo = node.SelectSingleNode("periodo_alta_ult_trabajo").InnerText
    'Next



%>
<%="<br/>terror:" & errr.get_error_xml() %>
