<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>

<script runat="server" language="VB">

    Dim strFormat As String = "INSERT INTO ids_action_events (ids_actionID, fe_event, operador, ids_deviceid, uid, numError, titulo, mensaje, id_origen) VALUES ('val_identity', GETDATE(), {0}, '{1}', NULL, {2}, '{3}', '{4}', '{5}')"

    Public Sub SaveEventIdentity(operador As Integer, ids_deviceID As String, numError As Integer, titulo As String, mensaje As String, id_origen As String)
        Dim strInsert As String = String.Format(strFormat, operador, ids_deviceID, numError, titulo, mensaje, id_origen)

        Try
            nvDBUtiles.DBExecute(strInsert)
        Catch ex As Exception
        End Try
    End Sub

</script>

<%
    Dim _response As New tError
    Dim strSQL As String
    Dim operador As Integer = Me.operador.operador
    Dim ids_deviceID As String = Me.nvDevice.ids_deviceid


    '--------------------------------------------------------------------------
    ' IDENTIFICADOR DEL USUARIO
    '--------------------------------------------------------------------------
    Dim uid_valcode As String = nvConvertUtiles.getUniqueId()
    Dim str_tError_response As String = ""


    '--------------------------------------------------------------------------
    ' REGISTRAR LA REQUEST
    '--------------------------------------------------------------------------
    Dim trsRequest As trsParam = nvUtiles.RequestTotrsParam()
    Dim strRequest As String = nvConvertUtiles.objectToSQLScript(trsRequest.toXML(True, "request"))   ' Éste string ya queda escapado con comillas simples (') para SQL

    strSQL = String.Format("INSERT INTO ids_action_requests (ids_actionID, request, id_origen) VALUES ('val_identity', {0}, '{1}')", strRequest, uid_valcode)

    Try
        nvDBUtiles.DBExecute(strSQL)
    Catch ex As Exception
    End Try


    '--------------------------------------------------------------------------
    ' Primer INSERT hacia la tabla "ids_identity_validations"
    '--------------------------------------------------------------------------
    strSQL = "INSERT INTO ids_identity_validations (uid_valcode, moment, tError_response, tError_validation, numError, titulo, mensaje) "
    strSQL &= String.Format("VALUES ('{0}', GETDATE(), '', '', 0, '', '')", uid_valcode)

    Try
        nvDBUtiles.DBExecute(strSQL)
    Catch ex As Exception
    End Try


    '--------------------------------------------------------------------------
    ' Obtener el ID de la configuración de Validaciones (ids_valcfg_id)
    '--------------------------------------------------------------------------
    Dim ids_cli_id As Integer = Me.operador.ids_cli_id
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")
    Dim ids_event_id As String = nvUtiles.obtenerValor("ids_event_id", "")

    If ids_res_id = "" OrElse ids_event_id = "" Then
        _response.numError = -98
        _response.titulo = "Error"
        _response.mensaje = "El Recurso o Evento proporcionados son nulos o inválidos."

        ' Salvar Response
        str_tError_response = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())

        strSQL = String.Format("UPDATE ids_identity_validations SET numError={0}, titulo='{1}', mensaje='{2}', tError_response={3} WHERE uid_valcode='{4}'", _response.numError, _response.titulo, _response.mensaje, str_tError_response, uid_valcode)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
        End Try

        ' Salvar el Evento
        SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)
        _response.response()
    End If

    strSQL = String.Format("SELECT ids_valcfg_id FROM ids_res_config WHERE ids_cli_id={0} AND ids_res_id='{1}' AND ids_event_id='{2}'", ids_cli_id, ids_res_id, ids_event_id)
    Dim rs As ADODB.Recordset = Nothing
    Dim ids_valcfg_id As String = ""

    Try
        rs = nvDBUtiles.DBExecute(strSQL)

        If rs.EOF Then
            _response.numError = -99
            _response.titulo = "Error"
            _response.mensaje = "No existe una configuración de validaciones para la combinación de cliente, recurso y evento suministrados."

            ' Salvar Response
            str_tError_response = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())

            strSQL = String.Format("UPDATE ids_identity_validations SET numError={0}, titulo='{1}', mensaje='{2}', tError_response={3} WHERE uid_valcode='{4}'", _response.numError, _response.titulo, _response.mensaje, str_tError_response, uid_valcode)

            Try
                nvDBUtiles.DBExecute(strSQL)
            Catch ex As Exception
            End Try

            ' Salvar el Evento
            SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)
            _response.response()
        End If

        ids_valcfg_id = rs.Fields("ids_valcfg_id").Value
        nvDBUtiles.DBCloseRecordset(rs)
    Catch ex As Exception
        _response.numError = -100
        _response.titulo = "Error SQL"
        _response.mensaje = "No fué posible realizar la consulta con la base."

        ' Salvar Response
        str_tError_response = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())

        strSQL = String.Format("UPDATE ids_identity_validations SET numError={0}, titulo='{1}', mensaje='{2}', tError_response={3} WHERE uid_valcode='{4}'", _response.numError, _response.titulo, _response.mensaje, str_tError_response, uid_valcode)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex1 As Exception
        End Try

        ' Salvar el Evento
        SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)
        _response.response()
    End Try

    '--------------------------------------------------------------------------
    ' Obtener todas las validaciones correspondientes al Cliente y al 
    ' ID de config de Validaciones
    '--------------------------------------------------------------------------
    strSQL = String.Format("SELECT * FROM ids_valcfgs WHERE ids_cli_id={0} AND ids_valcfg_id='{1}'", ids_cli_id, ids_valcfg_id)
    Dim validaciones As trsParam = Nothing

    Try
        rs = nvDBUtiles.DBExecute(strSQL)

        If rs.EOF Then
            _response.numError = -101
            _response.titulo = "Error"
            _response.mensaje = "No existe una configuración de validaciones o bien no se ha cargado aún."

            ' Salvar Response
            str_tError_response = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())

            strSQL = String.Format("UPDATE ids_identity_validations SET numError={0}, titulo='{1}', mensaje='{2}', tError_response={3} WHERE uid_valcode='{4}'", _response.numError, _response.titulo, _response.mensaje, str_tError_response, uid_valcode)

            Try
                nvDBUtiles.DBExecute(strSQL)
            Catch ex As Exception
            End Try

            nvDBUtiles.DBCloseRecordset(rs)

            ' Salvar el Evento
            SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)
            _response.response()
        End If

        validaciones = New trsParam
        validaciones("ids_valcfg") = rs.Fields("ids_valcfg").Value
        validaciones("req_email") = nvUtiles.isNUllorEmpty(rs.Fields("req_email").Value, False)
        validaciones("req_email_cfg_id") = nvUtiles.isNUllorEmpty(rs.Fields("req_email_cfg_id").Value, Nothing)
        validaciones("req_email_codeLength") = nvUtiles.isNUllorEmpty(rs.Fields("req_email_codeLength").Value, -99)
        validaciones("req_email_codeTimeout") = nvUtiles.isNUllorEmpty(rs.Fields("req_email_codeTimeout").Value, -99)
        validaciones("req_email_codeMaxFails") = nvUtiles.isNUllorEmpty(rs.Fields("req_email_codeMaxFails").Value, -99)
        validaciones("req_phone") = nvUtiles.isNUllorEmpty(rs.Fields("req_phone").Value, False)
        validaciones("req_phone_text") = nvUtiles.isNUllorEmpty(rs.Fields("req_phone_text").Value, Nothing)
        validaciones("req_phone_codeLength") = nvUtiles.isNUllorEmpty(rs.Fields("req_phone_codeLength").Value, -99)
        validaciones("req_phone_codeTimeout") = nvUtiles.isNUllorEmpty(rs.Fields("req_phone_codeTimeout").Value, -99)
        validaciones("req_verazID") = nvUtiles.isNUllorEmpty(rs.Fields("req_verazID").Value, False)
        validaciones("req_nosisID") = nvUtiles.isNUllorEmpty(rs.Fields("req_nosisID").Value, False)
        validaciones("req_dni_frente") = nvUtiles.isNUllorEmpty(rs.Fields("req_dni_frente").Value, False)
        validaciones("req_dni_dorso") = nvUtiles.isNUllorEmpty(rs.Fields("req_dni_dorso").Value, False)
        validaciones("req_selfie") = nvUtiles.isNUllorEmpty(rs.Fields("req_selfie").Value, False)
        validaciones("val_dni_selfie") = nvUtiles.isNUllorEmpty(rs.Fields("val_dni_selfie").Value, False)
        validaciones("val_pre_selfie") = nvUtiles.isNUllorEmpty(rs.Fields("val_pre_selfie").Value, False)
        validaciones("val_bio_vida") = nvUtiles.isNUllorEmpty(rs.Fields("val_bio_vida").Value, False)
        validaciones("val_renaper_basico") = nvUtiles.isNUllorEmpty(rs.Fields("val_renaper_basico").Value, False)
        validaciones("val_renaper_multifactor") = nvUtiles.isNUllorEmpty(rs.Fields("val_renaper_multifactor").Value, False)
        validaciones("req_cbu_mov") = nvUtiles.isNUllorEmpty(rs.Fields("req_cbu_mov").Value, False)
        validaciones("bpm_process") = nvUtiles.isNUllorEmpty(rs.Fields("bpm_process").Value, -99)
        validaciones("req_facebook") = nvUtiles.isNUllorEmpty(rs.Fields("req_facebook").Value, False)
        validaciones("req_google") = nvUtiles.isNUllorEmpty(rs.Fields("req_google").Value, False)
        validaciones("req_twitter") = nvUtiles.isNUllorEmpty(rs.Fields("req_twitter").Value, False)
        validaciones("req_instagram") = nvUtiles.isNUllorEmpty(rs.Fields("req_instagram").Value, False)

        nvDBUtiles.DBCloseRecordset(rs)
    Catch ex As Exception
        _response.parse_error_script(ex)
        _response.numError = -102
        _response.titulo = "Error configuracion"
        _response.mensaje = "Ocurrió un error al intentar obtener la configuración"
        _response.params("user_msg") = "Error al obtener la configuración de validación."

        ' Salvar Response
        str_tError_response = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())

        strSQL = String.Format("UPDATE ids_identity_validations SET numError={0}, titulo='{1}', mensaje='{2}', tError_response={3} WHERE uid_valcode='{4}'", _response.numError, _response.titulo, _response.mensaje, str_tError_response, uid_valcode)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex1 As Exception
        End Try

        ' Salvar el Evento
        SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)
        _response.response()
    End Try


    '--------------------------------------------------------------------------
    ' Verificar que se cargaron las validaciones
    '--------------------------------------------------------------------------
    If validaciones Is Nothing OrElse validaciones.Count = 0 Then
        _response.numError = -103
        _response.titulo = "Error configuracion"
        _response.mensaje = "Ocurrió un error al intentar obtener la configuración de validación"
        _response.params("user_msg") = "Error al obtener la configuración de validación."

        ' Salvar Response
        str_tError_response = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())

        strSQL = String.Format("UPDATE ids_identity_validations SET numError={0}, titulo='{1}', mensaje='{2}', tError_response={3} WHERE uid_valcode='{4}'", _response.numError, _response.titulo, _response.mensaje, str_tError_response, uid_valcode)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
        End Try

        ' Salvar el Evento
        SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)
        _response.response()
    End If


    '--------------------------------------------------------------------------
    ' Quitar todas las validaciones que no están requeridas en la config.
    '--------------------------------------------------------------------------
    For index As Integer = validaciones.Count - 1 To 0 Step -1
        If validaciones.Values(index) Is Nothing Then
            validaciones.Remove(validaciones.Keys(index))
        Else
            Select Case validaciones.Values(index).GetType().Name.ToLower()
                Case "boolean"
                    If validaciones.Values(index) = False Then validaciones.Remove(validaciones.Keys(index))

                Case "string"
                    If validaciones.Values(index) = "" Then validaciones.Remove(validaciones.Keys(index))

                Case "int32"
                    If validaciones.Values(index) = -99 Then validaciones.Remove(validaciones.Keys(index))

            End Select
        End If
    Next


    '--------------------------------------------------------------------------
    ' Recorrer todas las validaciones y marcar el resultado en vector de control
    '--------------------------------------------------------------------------
    Dim validation_control As New trsParam  ' Para control de validaciones ejecutadas
    Dim details_control As trsParam         ' Para detalles del control

    ' Variables globales necesarias
    Dim dni_frente_code As String = Nothing
    Dim dni_frente_data As String = Nothing
    Dim dni_dorso_code As String = Nothing
    Dim selfie_code As String = Nothing
    Dim selfie_data As String = Nothing
    Dim timer As New Diagnostics.Stopwatch

    For Each validacion In validaciones
        ' Iniciar un nuevo trsParam en cada iteracion
        details_control = New trsParam
        details_control("is_valid") = True
        details_control("message") = ""
        details_control("time") = 0.0
        timer.Start()

        Select Case validacion.Key.ToUpper
            Case "IDS_VALCFG", "REQ_EMAIL_CFG_ID", "REQ_EMAIL_CODELENGTH", "REQ_EMAIL_CODETIMEOUT", "REQ_EMAIL_CODEMAXFAILS", "REQ_PHONE_TEXT", "REQ_PHONE_CODELENGTH", "REQ_PHONE_CODETIMEOUT"
                Continue For



            Case "REQ_EMAIL"
                Dim email As String = nvUtiles.obtenerValor("email", "")
                Dim email_valcode As String = nvUtiles.obtenerValor("email_valcode", "")

                ' Checkear que el email y el val_code pasados hayan validado OK
                Dim email_validation As Boolean = True
                details_control("is_valid") = email_validation
                If Not email_validation Then details_control("message") = "Email inválido"



            Case "REQ_PHONE"
                Dim tel_nro As String = nvUtiles.obtenerValor("tel_nro", "")
                Dim tel_valcode As String = nvUtiles.obtenerValor("tel_valcode", "")

                ' Checkear que el numero de telefono y el valcode esten correctamente validados
                Dim tel_validation As Boolean = True
                details_control("is_valid") = tel_validation
                If Not tel_validation Then details_control("message") = "Teléfono inválido"



            Case "REQ_VERAZID"
                Dim verazid_valcode As String = nvUtiles.obtenerValor("verazid_valcode", "")

                ' Checkear que el VERAZ ID valcode sea válido
                Dim verazid_validation As Boolean = True
                details_control("is_valid") = verazid_validation
                If Not verazid_validation Then details_control("message") = "VERAZ inválido"



            Case "REQ_NOSISID"
                Dim nosisid_valcode As String = nvUtiles.obtenerValor("nosisid_valcode", "")

                ' Checkear que el VERAZ ID valcode sea válido
                Dim nosisid_validation As Boolean = True
                details_control("is_valid") = nosisid_validation
                If Not nosisid_validation Then details_control("message") = "NOSIS inválido"



            Case "REQ_DNI_FRENTE"
                dni_frente_code = nvUtiles.obtenerValor("dni_frente_code", "")
                dni_frente_data = Nothing

                If dni_frente_code = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "Código DNI Frente nulo"
                    Exit Select
                End If

                ' Checkear que el DNI Frente sea válido
                Dim sql As String = "SELECT tError_validation FROM ids_image_validations WHERE cod_image='" & dni_frente_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                ' @@@@@ Faltaria una validacion de TIMEOUT
                Dim rsDNIFrente As ADODB.Recordset = nvDBUtiles.DBExecute(sql)

                If Not rsDNIFrente.EOF Then
                    dni_frente_data = rsDNIFrente.Fields("tError_validation").Value
                Else
                    details_control("is_valid") = False
                    details_control("message") = "DNI Frente inválido"
                End If

                nvDBUtiles.DBCloseRecordset(rsDNIFrente)



            Case "REQ_DNI_DORSO"
                dni_dorso_code = nvUtiles.obtenerValor("dni_dorso_code", "")

                If dni_dorso_code = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "Código DNI Dorso nulo"
                    Exit Select
                End If

                ' Checkear que el DNI Dorso sea válido
                Dim sql As String = "SELECT 1 FROM ids_image_validations WHERE cod_image='" & dni_dorso_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                Dim rsDorso As ADODB.Recordset = nvDBUtiles.DBExecute(sql)

                If rsDorso.EOF Then
                    details_control("is_valid") = False
                    details_control("message") = "Código DNI Dorso inválido o nulo"
                End If

                nvDBUtiles.DBCloseRecordset(rsDorso)



            Case "REQ_SELFIE"
                selfie_code = nvUtiles.obtenerValor("selfie_code", "")

                If selfie_code = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "Código Selfie nulo"
                    Exit Select
                End If

                ' Checkear que la Selfie sea válida
                Dim sql As String = "SELECT tError_validation FROM ids_image_validations WHERE cod_image='" & selfie_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                Dim rsSelfie As ADODB.Recordset = nvDBUtiles.DBExecute(sql)

                If Not rsSelfie.EOF Then
                    selfie_data = rsSelfie.Fields("tError_validation").Value
                Else
                    details_control("is_valid") = False
                    details_control("message") = "Código Selfie inválido o nulo"
                End If

                nvDBUtiles.DBCloseRecordset(rsSelfie)



            Case "VAL_DNI_SELFIE"
                If dni_frente_code Is Nothing OrElse dni_frente_code = "" Then dni_frente_code = nvUtiles.obtenerValor("dni_frente_code", "")
                If selfie_code Is Nothing OrElse selfie_code = "" Then selfie_code = nvUtiles.obtenerValor("selfie_code", "")

                If dni_frente_code = "" OrElse selfie_code = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "Código de DNI Frente y/o Selfie inválidos o nulos"
                    Exit Select
                End If

                '--------------------------------------------------------------
                ' Obtener las imagenes de DNI Frente (sólo la foto de la 
                ' persona) y la Selfie, si es que no estan cargadas en DATA
                '--------------------------------------------------------------
                Dim img_dni As IO.MemoryStream = Nothing
                Dim img_selfie As IO.MemoryStream = Nothing
                Dim sql As String = ""
                Dim _rs As ADODB.Recordset = Nothing
                Dim oXml As System.Xml.XmlDocument = Nothing
                Dim img_b64 As String = Nothing

                ' 1) Imagen Foto DNI
                If dni_frente_data Is Nothing OrElse dni_frente_data = "" Then
                    sql = "SELECT tError_validation FROM ids_image_validations WHERE cod_image='" & dni_frente_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                    _rs = nvDBUtiles.DBExecute(sql)

                    If _rs.EOF Then
                        details_control("is_valid") = False
                        details_control("message") = "No se pudieron obtener las imágenes de DNI o Selfie"
                        Exit Select
                    End If

                    dni_frente_data = _rs.Fields("tError_validation").Value
                    nvDBUtiles.DBCloseRecordset(_rs)
                End If

                ' 1.1) Parsear el XML y cargar desde ahi el Stream
                oXml = New System.Xml.XmlDocument
                oXml.LoadXml(dni_frente_data)
                img_b64 = nvXMLUtiles.getNodeText(oXml, "error_mensajes/error_mensaje/params/image_base64", "")

                If img_b64 = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "No se pudieron obtener las imágenes de DNI o Selfie"
                    Exit Select
                End If

                img_dni = New IO.MemoryStream(Convert.FromBase64String(img_b64))

                ' 2) Imagen Selfie
                If selfie_data Is Nothing OrElse selfie_data = "" Then
                    sql = "SELECT tError_validation FROM ids_image_validations WHERE cod_image='" & selfie_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                    _rs = nvDBUtiles.DBExecute(sql)

                    If _rs.EOF Then
                        details_control("is_valid") = False
                        details_control("message") = "No se pudieron obtener las imágenes de DNI o Selfie"
                        Exit Select
                    End If

                    selfie_data = _rs.Fields("tError_validation").Value
                    nvDBUtiles.DBCloseRecordset(_rs)
                End If

                ' 2.1) Parsear el XML y cargar desde ahi el Stream
                oXml = New System.Xml.XmlDocument
                oXml.LoadXml(selfie_data)
                img_b64 = nvXMLUtiles.getNodeText(oXml, "error_mensajes/error_mensaje/params/image_base64", "")

                If img_b64 = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "No se pudieron obtener las imagnes de DNI o Selfie"
                    Exit Select
                End If

                img_selfie = New IO.MemoryStream(Convert.FromBase64String(img_b64))

                ' Comprobar que los datos de DNI y de Selfie estén presentes
                If img_dni Is Nothing OrElse img_dni.Length = 0 OrElse img_selfie Is Nothing OrElse img_selfie.Length = 0 Then
                    details_control("is_valid") = False
                    details_control("message") = "No se pudieron obtener las imagnes de DNI o Selfie"
                    Exit Select
                End If


                '--------------------------------------------------------------
                ' Llamada a Servicio AWS Rekognition
                '--------------------------------------------------------------
                Dim umbral_similitud As Single = nvUtiles.obtenerValor("umbral_similitud", "72", nvConvertUtiles.DataTypes.decimal) ' ** OPCIONAL
                Dim aws_validation As tError = servicios.AWS.Rekognition.CompareFaces(img_selfie, img_dni, umbral_similitud)

                If aws_validation.numError <> 0 OrElse aws_validation.params("hasCoincidence") = 0 Then
                    details_control("is_valid") = False
                    details_control("message") = "No hay coincidencia entre el DNI Frente y la Selfie"
                    Exit Select
                End If



            Case "VAL_PRE_SELFIE"
                If selfie_code Is Nothing OrElse selfie_code = "" Then selfie_code = nvUtiles.obtenerValor("selfie_code", "")
                Dim selfie_preexistente_code As String = "VER DE DONDE SACAR LA PREEXISTENTE"

                ' Usar servicios de Amazon para éste caso
                Dim pre_selfie_validation As Boolean = True
                details_control("is_valid") = pre_selfie_validation
                If Not pre_selfie_validation Then details_control("message") = "La Selfie suministrada no coincide con una previa"



            Case "VAL_BIO_VIDA"
                If selfie_code Is Nothing OrElse selfie_code = "" Then selfie_code = nvUtiles.obtenerValor("selfie_code", "")

                Dim gesture1_code As String = nvUtiles.obtenerValor("gesture1_code", "")
                Dim gesture2_code As String = nvUtiles.obtenerValor("gesture2_code", "")

                If selfie_code = "" OrElse gesture1_code = "" OrElse gesture2_code = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "La Selfie o alguno de los gestos son inválidos o no han sido proporcionados."
                    Exit Select
                End If

                '--------------------------------------------------------------
                ' Controlar que todas las imagenes sean válidas y luego que
                ' los gestos estén dentro de los límites establecidos
                '--------------------------------------------------------------
                Dim query As String = ""
                Dim _rs As ADODB.Recordset = Nothing
                Dim xml_doc As New System.Xml.XmlDocument

                '--- SELFIE ---
                Try
                    query = String.Format("SELECT tError_validation FROM ids_image_validations WHERE cod_image='{0}' AND ids_deviceid='{1}' AND is_valid=1", selfie_code, Me.nvDevice.ids_deviceid)
                    _rs = nvDBUtiles.DBExecute(query)

                    If _rs.EOF Then
                        details_control("is_valid") = False
                        details_control("message") = "La Selfie es inválida."
                        Exit Select
                    End If

                    xml_doc.LoadXml(_rs.Fields("tError_validation").Value)

                    Dim numError As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/@numError", "10")
                    Dim status As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/params/status", "0")
                    Dim count As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/params/count", "0")

                    If numError <> 0 OrElse status = 0 OrElse count <> 1 Then
                        details_control("is_valid") = False
                        details_control("message") = "La Selfie es inválida."
                        Exit Select
                    End If

                    nvDBUtiles.DBCloseRecordset(_rs)
                Catch ex As Exception
                    details_control("is_valid") = False
                    details_control("message") = "No fué posible validar la Selfie debido a un error interno."
                    Exit Select
                End Try

                '--- GESTO 1 ---
                Try
                    query = String.Format("SELECT tError_validation FROM ids_image_validations WHERE cod_image='{0}' AND ids_deviceid='{1}' AND is_valid=1", gesture1_code, Me.nvDevice.ids_deviceid)
                    _rs = nvDBUtiles.DBExecute(query)

                    If _rs.EOF Then
                        details_control("is_valid") = False
                        details_control("message") = "Gesto inválido."
                        Exit Select
                    End If

                    xml_doc.LoadXml(_rs.Fields("tError_validation").Value)

                    Dim numError As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/@numError", "10")
                    Dim status As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/params/status", "0")
                    Dim count As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/params/count", "0")

                    If numError <> 0 OrElse status = 0 OrElse count <> 1 Then
                        details_control("is_valid") = False
                        details_control("message") = "Gesto inválido."
                        Exit Select
                    End If

                    nvDBUtiles.DBCloseRecordset(_rs)
                Catch ex As Exception
                    details_control("is_valid") = False
                    details_control("message") = "No fué posible validar el gesto debido a un error interno."
                    Exit Select
                End Try

                '--- GESTO 2 ---
                Try
                    query = String.Format("SELECT tError_validation FROM ids_image_validations WHERE cod_image='{0}' AND ids_deviceid='{1}' AND is_valid=1", gesture2_code, Me.nvDevice.ids_deviceid)
                    _rs = nvDBUtiles.DBExecute(query)

                    If _rs.EOF Then
                        details_control("is_valid") = False
                        details_control("message") = "Gesto inválido."
                        Exit Select
                    End If

                    xml_doc.LoadXml(_rs.Fields("tError_validation").Value)

                    Dim numError As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/@numError", "10")
                    Dim status As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/params/status", "0")
                    Dim count As Integer = nvXMLUtiles.getNodeText(xml_doc, "/error_mensajes/error_mensaje/params/count", "0")

                    If numError <> 0 OrElse status = 0 OrElse count <> 1 Then
                        details_control("is_valid") = False
                        details_control("message") = "Gesto inválido."
                        Exit Select
                    End If

                    nvDBUtiles.DBCloseRecordset(_rs)
                Catch ex As Exception
                    details_control("is_valid") = False
                    details_control("message") = "No fué posible validar el gesto debido a un error interno."
                    Exit Select
                End Try



            Case "VAL_RENAPER_BASICO"
                ' Datos obligatorios; Se obtienen por parametria o por DB si ya
                ' se proceso una imagen y se tiene el codigo de la misma
                Dim number As String
                Dim gender As String
                Dim order As String

                If dni_frente_code Is Nothing OrElse dni_frente_code = "" Then dni_frente_code = nvUtiles.obtenerValor("dni_frente_code", "")

                If dni_frente_code <> "" AndAlso (dni_frente_data Is Nothing OrElse dni_frente_data = "") Then
                    ' Cargar desde la DB con el codifo de imagen del DNI Frente
                    Dim sql As String = "SELECT tError_validation FROM ids_image_validations WHERE cod_image='" & dni_frente_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                    Dim rsDNIFrente As ADODB.Recordset = nvDBUtiles.DBExecute(sql)

                    If Not rsDNIFrente.EOF Then dni_frente_data = rsDNIFrente.Fields("tError_validation").Value

                    nvDBUtiles.DBCloseRecordset(rsDNIFrente)
                End If

                ' Si se cargaron los datos del DNI Frente, sacamos la info de ahi.
                ' "dni_frente_data" viene como un string XML con formato tError
                If Not dni_frente_data Is Nothing AndAlso dni_frente_data <> "" Then
                    Dim oXml As New System.Xml.XmlDocument
                    oXml.LoadXml(dni_frente_data)
                    number = nvXMLUtiles.getNodeText(oXml, "error_mensajes/error_mensaje/params/number", "")
                    gender = nvXMLUtiles.getNodeText(oXml, "error_mensajes/error_mensaje/params/gender", "")
                    order = nvXMLUtiles.getNodeText(oXml, "error_mensajes/error_mensaje/params/order", "")
                Else
                    number = nvUtiles.obtenerValor("number", "")
                    gender = nvUtiles.obtenerValor("gender", "")
                    order = nvUtiles.obtenerValor("order", "")
                End If


                '--------------------------------------------------------------
                ' Llamada a Renaper paquete III
                '--------------------------------------------------------------
                Dim err As tError = servicios.Renaper.ValidarIdentidad(number, gender, order)

                If err.numError <> 0 Then
                    details_control("is_valid") = False
                    details_control("message") = "Error en ReNaPer (básico) al validar la identidad."
                    Exit Select
                End If

                If Not String.Equals("vigente", err.params("valid"), StringComparison.InvariantCultureIgnoreCase) Then
                    details_control("is_valid") = False
                    details_control("message") = "ReNaPer informó que el DNI no se encuenta vigente."
                    Exit Select
                End If

                If Not String.Equals("sin aviso de fallecimiento", err.params("messageOfDeath"), StringComparison.InvariantCultureIgnoreCase) Then
                    details_control("is_valid") = False
                    details_control("message") = "ReNaPer informó que la persona está fallecida."
                    Exit Select
                End If



            Case "VAL_RENAPER_MULTIFACTOR"
                ' Códigos de imagen
                If dni_frente_code Is Nothing OrElse dni_frente_code = "" Then dni_frente_code = nvUtiles.obtenerValor("dni_frente_code", "")
                If dni_dorso_code Is Nothing OrElse dni_dorso_code = "" Then dni_dorso_code = nvUtiles.obtenerValor("dni_dorso_code", "")
                If selfie_code Is Nothing OrElse selfie_code = "" Then selfie_code = nvUtiles.obtenerValor("selfie_code", "")

                If dni_frente_code = "" OrElse dni_dorso_code = "" OrElse selfie_code = "" Then
                    details_control("is_valid") = False
                    details_control("message") = "Uno o más códigos de imagen son nulos o inválidos en ReNaPer (multifactor)."
                    Exit Select
                End If

                ' Cargar los streams de imagen desde cada código
                Dim sql As String = ""
                Dim _rs As ADODB.Recordset = Nothing
                Dim byte_tmp As Byte() = Nothing

                Dim streams As New trsParam
                streams("dni_frente") = Nothing
                streams("dni_dorso") = Nothing
                streams("selfie") = Nothing

                ' Obtener todos los binarios de las 3 imágenes (muy importante establecer el orden, para capturar cada binario correctamente)
                sql = "SELECT image_binary FROM ids_image_validations " &
                        "WHERE cod_image IN ('" & dni_frente_code & "', '" & dni_dorso_code & "', '" & selfie_code & "') " &
                        "AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1 " &
                        "ORDER BY CASE WHEN image_type='dni_frente' THEN 0 WHEN image_type='dni_dorso' THEN 1 ELSE 2 END"

                Try
                    _rs = nvDBUtiles.DBExecute(sql)
                Catch ex As Exception
                    details_control("is_valid") = False
                    details_control("message") = "Error al consultar la base de datos en validación ReNaPer (multifactor)."
                    Exit Select
                End Try

                If _rs.EOF Then
                    details_control("is_valid") = False
                    details_control("message") = "No se pudo obtener una o más imágenes desde la base para ReNaPer (multifactor)."
                    Exit Select
                End If

                For i = 0 To 2
                    byte_tmp = _rs.Fields("image_binary").Value

                    Select Case i
                        Case 0
                            streams("dni_frente") = New IO.MemoryStream(byte_tmp)

                        Case 1
                            streams("dni_dorso") = New IO.MemoryStream(byte_tmp)

                        Case 2
                            streams("selfie") = New IO.MemoryStream(byte_tmp)

                    End Select

                    byte_tmp = Nothing
                    _rs.MoveNext()
                Next

                nvDBUtiles.DBCloseRecordset(_rs)


                '' Frente DNI
                'sql = "SELECT image_binary FROM ids_image_validations WHERE cod_image='" & dni_frente_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                '_rs = nvDBUtiles.DBExecute(sql)

                'If _rs.EOF Then
                '    details_control("is_valid") = False
                '    details_control("message") = "No se pudo obtener la imagen del DNI frente en ReNaPer (multifactor)."
                '    Exit Select
                'End If

                'byte_tmp = _rs.Fields("image_binary").Value
                'streams("dni_frente") = New IO.MemoryStream(byte_tmp)
                'nvDBUtiles.DBCloseRecordset(_rs)

                '' Dorso DNI
                'sql = "SELECT image_binary FROM ids_image_validations WHERE cod_image='" & dni_dorso_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                '_rs = nvDBUtiles.DBExecute(sql)

                'If _rs.EOF Then
                '    details_control("is_valid") = False
                '    details_control("message") = "No se pudo obtener la imagen del DNI dorso en ReNaPer (multifactor)."
                '    Exit Select
                'End If

                'byte_tmp = _rs.Fields("image_binary").Value
                'streams("dni_dorso") = New IO.MemoryStream(byte_tmp)
                'nvDBUtiles.DBCloseRecordset(_rs)

                '' Selfie
                'sql = "SELECT image_binary FROM ids_image_validations WHERE cod_image='" & selfie_code & "' AND ids_deviceid='" & Me.nvDevice.ids_deviceid & "' AND is_valid=1"
                '_rs = nvDBUtiles.DBExecute(sql)

                'If _rs.EOF Then
                '    details_control("is_valid") = False
                '    details_control("message") = "No se pudo obtener la imagen selfie en ReNaPer (multifactor)."
                '    Exit Select
                'End If

                'byte_tmp = _rs.Fields("image_binary").Value
                'streams("selfie") = New IO.MemoryStream(byte_tmp)
                'nvDBUtiles.DBCloseRecordset(_rs)

                '' Control de los streams
                'If streams("dni_frente") Is Nothing OrElse streams("dni_dorso") Is Nothing OrElse streams("selfie") Is Nothing Then
                '    details_control("is_valid") = False
                '    details_control("message") = "No se pudieron cargar una o más imágenes en ReNaPer (multifactor)."
                '    Exit Select
                'End If


                '--------------------------------------------------------------
                ' Llamada a ReNaPer Paquete I
                '--------------------------------------------------------------
                Dim err As tError = servicios.Renaper.ValidarIdentidad(streams("dni_frente"), streams("dni_dorso"), streams("selfie"))

                If err.numError <> 0 Then
                    details_control("is_valid") = False
                    details_control("message") = "Error al validar la identidad con ReNaPer (multifactor). Detalles: " & err.mensaje
                    Exit Select
                End If

                If err.params("personData_valid").ToLower <> "vigente" Then
                    details_control("is_valid") = False
                    details_control("message") = "ReNaPer informa que el DNI está fuera de vigencia."
                    Exit Select
                End If

                If err.params("personData_messageOfDeath").ToLower <> "sin aviso de fallecimiento" Then
                    details_control("is_valid") = False
                    details_control("message") = "ReNaPer informa que la persona está fallecida."
                    Exit Select
                End If



            Case "REQ_CBU_MOV"
                Dim cbu As String = nvUtiles.obtenerValor("cbu", "")
                Dim cbu_valcode As String = nvUtiles.obtenerValor("cbu_valcode", "")

                ' Comprobar que esté su validación OK
                Dim cbu_validation As Boolean = True
                details_control("is_valid") = cbu_validation
                If Not cbu_validation Then details_control("message") = "Movimiento de CBU inválido."



            Case "BPM_PROCESS"
                ' No implementado por el momento
                Dim bpm_validation As Boolean = True
                details_control("is_valid") = bpm_validation
                If Not bpm_validation Then details_control("message") = "BPM inválido."



            Case "REQ_FACEBOOK"
                Dim facebook_id As String = nvUtiles.obtenerValor("facebook_id", "")
                Dim facebook_tk As String = nvUtiles.obtenerValor("facebook_tk", "")

                ' Validar éstos datos...
                Dim facebook_validation As Boolean = True
                details_control("is_valid") = facebook_validation
                If Not facebook_validation Then details_control("message") = "Login de Facebook inválido."



            Case "REQ_GOOGLE"
                Dim google_id As String = nvUtiles.obtenerValor("google_id", "")
                Dim google_tk As String = nvUtiles.obtenerValor("google_tk", "")

                ' Validar éstos datos...
                Dim google_validation As Boolean = True
                details_control("is_valid") = google_validation
                If Not google_validation Then details_control("message") = "Login de Google inválido."



            Case "REQ_TWITTER"
                Dim twitter_id As String = nvUtiles.obtenerValor("twitter_id", "")
                Dim twitter_tk As String = nvUtiles.obtenerValor("twitter_tk", "")

                ' Validar éstos datos...
                Dim twitter_validation As Boolean = True
                details_control("is_valid") = twitter_validation
                If Not twitter_validation Then details_control("message") = "Login de Twitter inválido."



            Case "REQ_INSTAGRAM"
                Dim instagram_id As String = nvUtiles.obtenerValor("instagram_id", "")
                Dim instagram_tk As String = nvUtiles.obtenerValor("instagram_tk", "")

                ' Validar éstos datos...
                Dim instagram_validation As Boolean = True
                details_control("is_valid") = instagram_validation
                If Not instagram_validation Then details_control("message") = "Login de Instagram inválido."

        End Select

        details_control("time") = timer.ElapsedMilliseconds
        timer.Restart()

        ' Guardar los detalles en la coleccion
        validation_control(validacion.Key) = details_control
    Next


    '--------------------------------------------------------------------------
    ' Recorrer el vector de control y generar código de persona si esta todo OK
    '--------------------------------------------------------------------------
    Dim at_least_one_failed As Boolean = False
    Dim all_error_messages As String = ""

    For Each control In validation_control
        If Not control.Value("is_valid") Then
            at_least_one_failed = True
            all_error_messages &= control.Value("message") & vbCrLf
        End If
    Next


    '--------------------------------------------------------------------------
    ' Salvar un tError con la Validación en la tabla "ids_identity_validations"
    '--------------------------------------------------------------------------
    Dim tError_validation As New tError
    tError_validation.params = validation_control
    Dim str_tError_validation As String = ""

    If at_least_one_failed Then
        _response.numError = 100
        _response.titulo = "Error en Validación de Identidad"
        _response.mensaje = "No fué posible validar la identidad de la persona por uno o más errores. " & all_error_messages

        ' Copiar los valores del tError general al de Validación para que contenga los valores correctos
        tError_validation.numError = _response.numError
        tError_validation.titulo = _response.titulo
        tError_validation.mensaje = _response.mensaje
        str_tError_validation = nvConvertUtiles.objectToSQLScript(tError_validation.get_error_xml())  ' Escapa todo para SQL y viene wrappeado para string (')

        ' Salvar Response
        str_tError_response = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())

        strSQL = String.Format("UPDATE ids_identity_validations SET tError_validation={0}, numError={1}, titulo='{2}', mensaje='{3}', tError_response={4} WHERE uid_valcode='{5}'", str_tError_validation, _response.numError, _response.titulo, _response.mensaje, str_tError_response, uid_valcode)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
        End Try

        ' Salvar el Evento
        SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)
        _response.response()
    Else
        ' No hubo error => guardar resultados de la validación
        str_tError_validation = nvConvertUtiles.objectToSQLScript(tError_validation.get_error_xml())  ' Escapa todo para SQL y viene wrappeado para string (')
        strSQL = String.Format("UPDATE ids_identity_validations SET tError_validation={0} WHERE uid_valcode='{1}'", str_tError_validation, uid_valcode)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
        End Try
    End If


    '--------------------------------------------------------------------------
    ' Si llegó acá está todo OK
    '--------------------------------------------------------------------------
    _response.params("uid_valcode") = uid_valcode

    Dim str_response As String = nvConvertUtiles.objectToSQLScript(_response.get_error_xml())  ' Escapa todo para SQL y viene wrappeado para string (')
    strSQL = String.Format("UPDATE ids_identity_validations SET tError_response={0} WHERE uid_valcode='{1}'", str_response, uid_valcode)

    Try
        nvDBUtiles.DBExecute(strSQL)
    Catch ex As Exception
    End Try


    '--------------------------------------------------------------------------
    ' REGISTRO DE EVENTO
    '
    ' Registrar el Evento para la Acción "val_identity"
    '--------------------------------------------------------------------------
    SaveEventIdentity(operador, ids_deviceID, _response.numError, _response.titulo, _response.mensaje, uid_valcode)

    If _response.numError <> 0 Then
        ' Borrar todos los datos de parametros
        _response.params.Clear()
    Else
        ' Si viene desde DEVICE => encriptar
        If Not Me.nvDevice Is Nothing Then
            ' Pasar el params del resultado
            Dim jsonRes_enc As nvFW.nvIDS.tnvDeviceEncData = Me.nvDevice.EncRsaAes256(_response.params)

            ' Limpio los params originales
            _response.params.Clear()

            ' Asigno la clave simetrica y los datos encriptados
            _response.params("simKey") = jsonRes_enc.simKeyB64
            _response.params("DeviceDataResEnc") = jsonRes_enc.encDataB64
        End If
    End If

    _response.response()
%>