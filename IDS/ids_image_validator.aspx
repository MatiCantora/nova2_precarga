<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    Dim imgValidator_res As New tError
    Dim strSQL As String

    Dim image_type As String = nvUtiles.obtenerValor("image_type", "").ToString().ToLower()
    Dim dni_frente_code As String = nvUtiles.obtenerValor("dni_frente_code", "")

    Dim trs_additional As New trsParam  ' Usado para pasar todo tipo de valores y estructuras adicionales necesarias para el proceso
    trs_additional("ids_deviceid") = Me.nvDevice.ids_deviceid

    If dni_frente_code <> "" Then trs_additional("dni_frente_code") = dni_frente_code

    ' Para procesar el DNI DORSO, necesitamos el "image_code" del DNI FRENTE, pasado como "dni_frente_code"
    If image_type = "dni_dorso" AndAlso dni_frente_code = "" Then
        imgValidator_res.numError = 10
        imgValidator_res.debug_desc = "No se puede procesar el dorso del DNI sin antes haber procesaso el frente del mismo."
        imgValidator_res.params.Clear()
        imgValidator_res.params("user_msg") = "Debe procesar el frente del DNI antes."
        imgValidator_res.response()
    End If

    Dim image_typeID As Integer = [Enum].Parse(GetType(nvFW.nvIDS.nvEnumImageType), image_type) ' Obtener ENUM de clase nvFW.nvIDS.nvImage
    Dim img As String = nvUtiles.obtenerValor("img", "")    ' Siempre como String BASE 64

    trs_additional("contentType") = nvUtiles.obtenerValor("contentType", "")
    trs_additional("dni_or_cuitcuil") = nvUtiles.obtenerValor("dni_or_cuitcuil", "")
    trs_additional("min_face_width") = nvUtiles.obtenerValor("min_face_width", "0.3", nvConvertUtiles.DataTypes.decimal)    ' Sólo válida para SELFIE; por defecto 0.3
    trs_additional("gesture_type") = nvUtiles.obtenerValor("gesture_type", "selfie")   ' Sólo válida para SELFIE; por defecto "selfie"

    '--------------------------------------------------------------------------
    ' VALIDACION
    '--------------------------------------------------------------------------
    imgValidator_res = nvFW.nvIDS.nvImage.Validation(image_typeID, img, trs_additional)


    '--------------------------------------------------------------------------
    ' REGISTRAR LA REQUEST Y EL EVENTO PARA ACCION "val_img"
    '--------------------------------------------------------------------------
    'Dim trsRequest As trsParam = nvUtiles.RequestTotrsParam()
    'Dim strRequest As String = nvConvertUtiles.objectToSQLScript(trsRequest.toXML(True, "request"))

    'strSQL = String.Format("INSERT INTO ids_action_requests (ids_actionID, request, id_origen) VALUES ('val_img', {0}, '{1}');", strRequest, imgValidator_res.params("image_code"))
    'strSQL &= vbCrLf
    strSQL = "INSERT INTO ids_action_events (ids_actionID, fe_event, operador, ids_deviceid, uid, numError, titulo, mensaje, id_origen) "
    strSQL &= String.Format("VALUES ('val_img', GETDATE(), {0}, '{1}', NULL, {2}, '{3}', '{4}', '{5}');", Me.operador.operador, Me.nvDevice.ids_deviceid, imgValidator_res.numError, imgValidator_res.titulo, imgValidator_res.mensaje, imgValidator_res.params("image_code"))

    Try
        nvDBUtiles.DBExecute(strSQL)
    Catch ex As Exception
    End Try


    If imgValidator_res.numError <> 0 Then
        ' Borrar todos los datos de parametros
        imgValidator_res.params.Clear()
    Else
        ' Si viene desde DEVICE => encriptar
        If Not Me.nvDevice Is Nothing Then
            ' Pasar el params del resultado
            Dim jsonRes_enc As nvFW.nvIDS.tnvDeviceEncData = Me.nvDevice.EncRsaAes256(imgValidator_res.params)

            ' Limpio los params originales
            imgValidator_res.params.Clear()

            ' Asigno la clave simetrica y los datos encriptados
            imgValidator_res.params("simKey") = jsonRes_enc.simKeyB64
            imgValidator_res.params("DeviceDataResEnc") = jsonRes_enc.encDataB64
        End If
    End If


    imgValidator_res.response()
%>