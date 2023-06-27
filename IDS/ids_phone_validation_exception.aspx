<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<script runat="server" language="VB">

    ''' <summary>
    ''' Salva los valores de Operador, Dispositivo y valores extra del tError hacia la tabla <c>ids_action_events</c>
    ''' </summary>
    ''' <param name="operador"></param>
    ''' <param name="ids_deviceID"></param>
    ''' <param name="id_origen"></param>
    ''' <param name="tError_validation"></param>
    Public Sub SaveEventIdentity(operador As Integer, ids_deviceID As String, id_origen As String, tError_validation As tError)
        Dim strFormat As String = "INSERT INTO ids_action_events (ids_actionID, fe_event, operador, ids_deviceid, uid, numError, titulo, mensaje, id_origen) " &
                                  "VALUES ('val_phone_exception', GETDATE(), {0}, '{1}', NULL, {2}, '{3}', '{4}', '{5}')"
        Dim strInsert As String = String.Format(strFormat, operador, ids_deviceID, tError_validation.numError, tError_validation.titulo, tError_validation.mensaje, id_origen)

        Try
            nvDBUtiles.DBExecute(strInsert)
        Catch ex As Exception
        End Try
    End Sub


    Public Sub InsertValidation(ByVal tel_valcode As String, ByVal nro_tel As String)
        Dim db_table_name As String = "ids_phone_validations"
        Dim strSQL As String = "INSERT INTO " & db_table_name & " (tel_valcode, moment, phone, tError_response, tError_validation, numError, titulo, mensaje) "
        strSQL &= String.Format("VALUES ('{0}', GETDATE(), '{1}', '', '', 0, '', '')", tel_valcode, nro_tel)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
        End Try
    End Sub


    Public Sub UpdateValidation(ByVal tError_response As tError, ByVal tel_valcode As String)
        Dim db_table_name As String = "ids_phone_validations"
        Dim str_tError_response = nvConvertUtiles.objectToSQLScript(tError_response.get_error_xml())
        Dim strSQL As String = String.Format("UPDATE {0} SET numError={1}, titulo='{2}', mensaje='{3}', tError_response={4} WHERE tel_valcode='{5}'", db_table_name, tError_response.numError, tError_response.titulo, tError_response.mensaje, str_tError_response, tel_valcode)

        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
        End Try
    End Sub

</script>
<%
    Dim validation As New tError
    Dim operador As Integer = Me.operador.operador
    Dim ids_device_id As String = Me.nvDevice.ids_deviceid
    Dim nro_tel As String = nvUtiles.obtenerValor("nro_tel", "")
    Dim tel_valcode As String = nvConvertUtiles.RamdomInteger(6)
    Dim strSQL As String = ""

    '--------------------------------------------------------------------------
    ' REGISTRAR LA REQUEST en "ids_action_requests"
    '--------------------------------------------------------------------------
    Dim trsRequest As trsParam = nvUtiles.RequestTotrsParam()
    Dim strRequest As String = nvConvertUtiles.objectToSQLScript(trsRequest.toXML(True, "request"))   ' Éste string ya queda escapado con comillas simples (') para SQL
    strSQL = String.Format("INSERT INTO ids_action_requests (ids_actionID, request, id_origen) VALUES ('val_phone_exception', {0}, '{1}')", strRequest, tel_valcode)

    Try
        nvDBUtiles.DBExecute(strSQL)
    Catch ex As Exception
    End Try


    '--------------------------------------------------------------------------
    ' Primer INSERT hacia la tabla "ids_phone_validations"
    '--------------------------------------------------------------------------
    InsertValidation(tel_valcode, nro_tel)


    '--------------------------------------------------------------------------
    ' Validar integridad del numero de telefono
    '
    '   1) Longitud: debe contener 10 dígitos
    '   2) Integridad: los caracteres deben ser todos números
    '--------------------------------------------------------------------------
    If nro_tel = "" OrElse nro_tel.Length <> 10 Then
        validation.numError = 100
        validation.titulo = "Error longitud de teléfono"
        validation.mensaje = "La longitud del teléfono proporcionado (" & nro_tel & ") debe ser de 10 dígitos sin 0 en código de área y sin 15 en el número."

        ' Actualizar la validacion
        UpdateValidation(validation, tel_valcode)
        ' Salvar el Evento
        SaveEventIdentity(operador, ids_device_id, tel_valcode, validation)

        validation.response()
    End If

    Dim regEx As New System.Text.RegularExpressions.Regex("^\d+$")
    If Not regEx.Match(nro_tel).Success Then
        validation.numError = 101
        validation.titulo = "Error en integridad de teléfono"
        validation.mensaje = "El teléfono proporcionado (" & nro_tel & ") contiene dígitos no válidos."

        ' Actualizar la validacion
        UpdateValidation(validation, tel_valcode)
        ' Salvar el Evento
        SaveEventIdentity(operador, ids_device_id, tel_valcode, validation)

        validation.response()
    End If


    ' Comprobar si existe en la BASE (todavia no estan las tablas)
    Dim existe As Boolean = False

    ' Armado de los params de Salida
    validation.params("tel_valcode") = tel_valcode
    validation.params("exists") = existe

    ' INSERTS de "ids_action_events" y "ids_phone_validations"
    SaveEventIdentity(operador, ids_device_id, tel_valcode, validation)
    UpdateValidation(validation, tel_valcode)

    '--------------------------------------------------------------------------
    ' ENCRIPTAR => sólo si viene desde DEVICE
    '--------------------------------------------------------------------------
    If validation.numError <> 0 Then
        ' Borrar todos los datos de parametros
        validation.params.Clear()
    Else

        If Not Me.nvDevice Is Nothing Then
            ' Pasar el params del resultado
            Dim jsonRes_enc As nvFW.nvIDS.tnvDeviceEncData = Me.nvDevice.EncRsaAes256(validation.params)

            ' Limpio los params originales
            validation.params.Clear()

            ' Asigno la clave simetrica y los datos encriptados
            validation.params("simKey") = jsonRes_enc.simKeyB64
            validation.params("DeviceDataResEnc") = jsonRes_enc.encDataB64
        End If
    End If

    validation.response()
%>