<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>

<script runat="server" language="VB">
    Function GetExtension(ByVal content_type As String) As String
        Select Case content_type.ToLower()
            Case "image/jpeg", "image/jpg"
                Return "jpg"

            Case "image/png"
                Return "png"

            Case "image/tif", "image/tiff"
                Return "tif"

            Case "image/gif"
                Return "gif"

            Case Else
                Return ""
        End Select
    End Function
</script>

<%
    '------------------------------------------------------------------------------
    '   BIOMETRIC-VALIDATOR
    '
    '   Recurso utilizador como validador biométrico de las imágenes enviadas 
    '   desde la aplicación "APPLICA" para firmar documentos PDF.
    '   Las imágenes que se validarán son la del frente del DNI detectada contra
    '   la selfie enviada.
    '
    '------------------------------------------------------------------------------
    '   INPUT:
    '       "code_img_dni_frente": código de imagen del DNI (proporcionado por el
    '                             servicio de preValidator).
    '       "code_img_dni_dorso":  código de imagen del DNI (proporcionado por el
    '                             servicio de preValidator).
    '       "code_img_selfie":   idem anterior pero en éste caso con la selfie.
    '------------------------------------------------------------------------------
    '   OUTPUT:
    '       tError:
    '           [OK]    numError = 0;
    '                   params("accuracy") = porcentaje de precisión entre imágenes
    '           [Error] numError = numero_error_diferente_de_cero;
    '                   mensaje = mensaje_error_producido

    '------------------------------------------------------------------------------
    Dim biometric_response As New tError
    biometric_response.debug_src = "ids_biometric_validator"
    Dim message_debug_desc As String = ""   ' La usamos para cargar descripciones de excepciones provocadas y luego se asigna al final en un catch que corresponda


    Dim query As String = ""
    Dim rs As ADODB.Recordset = Nothing


    ''------------------------------------------------------------------------------
    '' ACCESS_KEY: Chequear que exista y no esté vencida
    ''------------------------------------------------------------------------------
    Dim dni_or_cuitcuil As String = nvUtiles.obtenerValor("dni_or_cuitcuil", "")
    'Dim dni_or_cuitcuil As String = Nothing  ' Utilizado para verificar con el numero de DNI leído desde la imagen proporcionada (frente)
    Dim access_key As String = nvUtiles.obtenerValor("ak", "")

    'If access_key = String.Empty Then
    '    biometric_response.numError = 100
    '    biometric_response.titulo = "Error de autenticación"
    '    biometric_response.mensaje = "No fue posible realizar la autenticación con los datos proporcionados."
    '    biometric_response.debug_desc = "El valor de 'ak' es nulo o inválido."
    '    biometric_response.response()
    'Else
    '    ' Validar con la db existencia del ak y que no este vencido [dbo].[nv_public_access_key]
    '    query = String.Format("SELECT expiration_date, tipo_doc, nro_doc FROM nv_public_access_key WHERE access_key='{0}'", access_key)

    '    Try
    '        rs = nvDBUtiles.DBExecute(query)

    '        If rs.EOF Then
    '            biometric_response.numError = 100
    '            biometric_response.titulo = "Error de autenticación"
    '            biometric_response.mensaje = "No fue posible realizar la autenticación con los datos proporcionados."
    '            biometric_response.debug_desc = "El valor de 'ak' es inválido. No existe en la DB."
    '            biometric_response.response()
    '        Else
    '            '*** Verificar que no este vencido
    '            Dim expiration_date As DateTime = rs.Fields("expiration_date").Value
    '            Dim date_diff = (expiration_date - DateTime.Now).TotalSeconds

    '            If date_diff < 0 Then
    '                biometric_response.numError = 101
    '                biometric_response.titulo = "Error de autenticación"
    '                biometric_response.mensaje = "No fue posible realizar la autenticación con los datos proporcionados."
    '                biometric_response.debug_desc = "El valor de 'ak' ha expirado."
    '                biometric_response.response()
    '            Else
    '                ' Capturar el "nro_doc"
    '                Dim tipo_doc As Integer = rs.Fields("tipo_doc").Value

    '                Select Case tipo_doc
    '                    Case 3 ' DNI
    '                        dni_or_cuitcuil = rs.Fields("nro_doc").Value

    '                    Case 5 ' CUIT/CUIL
    '                        dni_or_cuitcuil = rs.Fields("nro_doc").Value.ToString().Substring(2, 8)

    '                End Select
    '            End If
    '        End If
    '    Catch ex As Exception
    '        biometric_response.parse_error_script(ex)
    '        biometric_response.numError = 101
    '        biometric_response.titulo = "Error de autenticación"
    '        biometric_response.mensaje = "No fue posible realizar la autenticación con los datos proporcionados."
    '        biometric_response.debug_desc = message_debug_desc
    '        biometric_response.response()
    '    End Try

    '    rs.Close()
    'End If


    '------------------------------------------------------------------------------
    ' Codigos de imagen
    Dim code_img_dni_frente As String = nvUtiles.obtenerValor("code_img_dni_frente", "")
    Dim code_img_dni_dorso As String = nvUtiles.obtenerValor("code_img_dni_dorso", "")
    Dim code_img_selfie As String = nvUtiles.obtenerValor("code_img_selfie", "")

    ' Verificar que ambos códigos no estén vacíos
    If code_img_dni_frente = String.Empty OrElse code_img_dni_dorso = String.Empty OrElse code_img_selfie = String.Empty Then
        biometric_response.numError = 101
        biometric_response.titulo = "Error llamada API"
        biometric_response.mensaje = "Ocurrió un error con los parámetros suministrados."
        biometric_response.debug_desc = "Uno o más códigos de imagen suminstrados están vacíos."
        biometric_response.response()
    End If


    '------------------------------------------------------------------------------
    ' Obtener los binarios de cada imagen desde el XML "tError_validation"
    ' *** hay que ir a la DB y retornarlos; si no están => ERROR
    Dim xml_dni_frente As System.Xml.XmlDocument = Nothing
    Dim xml_dni_dorso As System.Xml.XmlDocument = Nothing
    Dim xml_selfie As System.Xml.XmlDocument = Nothing
    Dim ms_dni_front As IO.MemoryStream
    Dim ms_dni_dorso As IO.MemoryStream
    Dim ms_selfie As IO.MemoryStream

    ' Diccionarios de parámetros que luego vamos a utilizar para el tError.params
    Dim param_aws As New trsParam
    Dim param_renaper As New trsParam


    '------------------------------------------------------------------------------
    ' PASO 1: comparar rostros con AWS.Rekognition
    '------------------------------------------------------------------------------
    Dim err_aws As New tError

    Try
        query = String.Format("SELECT tError_validation FROM ids_image_validations WHERE cod_image in ('{0}', '{1}', '{2}') ORDER BY CASE image_type WHEN 'dni_frente' THEN 0 WHEN 'dni_dorso' THEN 1 WHEN 'selfie' THEN 2 END", code_img_dni_frente, code_img_dni_dorso, code_img_selfie)
        rs = nvDBUtiles.DBExecute(query)

        ' Tienen que venir si o si 3 registros
        If rs.EOF Then
            message_debug_desc = "No se encontraron los registros de imagenes solicitados en la DB."
            Throw New Exception()
        End If

        ' Cargar los XML desde "tError_validation"
        xml_dni_frente = New System.Xml.XmlDocument
        xml_dni_frente.LoadXml(rs.Fields("tError_validation").Value)
        rs.MoveNext()

        xml_dni_dorso = New System.Xml.XmlDocument
        xml_dni_dorso.LoadXml(rs.Fields("tError_validation").Value)
        rs.MoveNext()

        xml_selfie = New System.Xml.XmlDocument
        xml_selfie.LoadXml(rs.Fields("tError_validation").Value)
        rs.Close()

        ' Cargar las imagenes
        Dim tmp_img As Byte() = Nothing

        tmp_img = Convert.FromBase64String(nvXMLUtiles.getNodeText(xml_dni_frente, "/error_mensajes/error_mensaje/params/image_base64", ""))
        ms_dni_front = New IO.MemoryStream(tmp_img)

        tmp_img = Convert.FromBase64String(nvXMLUtiles.getNodeText(xml_selfie, "/error_mensajes/error_mensaje/params/image_base64", ""))
        ms_selfie = New IO.MemoryStream(tmp_img)

        ' Comparar los rostros desde las imagenes
        Dim similarity_threshold As Single = Single.Parse(nvUtiles.obtenerValor("similarity_threshold", "75.0"), System.Globalization.NumberFormatInfo.InvariantInfo)

        '----------------------------------------------------------------------
        ' AWS: COMPARAR ROSTROS
        err_aws = nvFW.servicios.AWS.Rekognition.CompareFaces(ms_selfie, ms_dni_front, similarity_threshold)

        If err_aws.numError <> 0 Then
            message_debug_desc = err_aws.debug_desc
            Throw New Exception()
        End If

        If err_aws.params("hasCoincidence") = "0" Then
            message_debug_desc = "No hay coincidencia entre las imágenes con el umbral proporcionado (" & similarity_threshold & ") mediante el servicio de AWS. Tasa de coincidencia (" & biometric_response.params("similarity") & ")."
            Throw New Exception()
        End If

        ' Carga de valores en parámetros de AWS
        param_aws("hasCoincidence") = err_aws.params("hasCoincidence")
        param_aws("similarity") = err_aws.params("similarity")

    Catch ex As Exception
        biometric_response.numError = 102
        biometric_response.titulo = "Error llamada API"
        biometric_response.mensaje = "Ocurrió un error al validar la identidad."
        biometric_response.debug_desc = message_debug_desc
        biometric_response.params.Clear()   ' No mandar nada a la salida
        biometric_response.response()
    End Try

    err_aws = Nothing


    '------------------------------------------------------------------------------
    ' PASO 2: Comparar datos de la persona contra ReNaPer
    '------------------------------------------------------------------------------
    Dim err_renaper As New tError

    Try
        Dim renaper_package As Integer = CInt(nvUtiles.obtenerValor("renaper_package", "3"))

        Select Case renaper_package
            Case 1
                '********************************************************
                ' Paquete 1:
                '   Imagen DNI frente
                '   Imagen DNI dorso
                '   Imagen selfie
                '********************************************************

                ' Levantar los binarios completos de cada imagen
                query = String.Format("SELECT image_binary, image_content_type FROM ids_image_validations WHERE cod_image in ('{0}', '{1}', '{2}') ORDER BY CASE image_type WHEN 'dni_frente' THEN 0 WHEN 'dni_dorso' THEN 1 WHEN 'selfie' THEN 2 END", code_img_dni_frente, code_img_dni_dorso, code_img_selfie)
                rs = nvDBUtiles.DBExecute(query)

                If rs.EOF Then
                    message_debug_desc = "No se obtuvieron los binarios desde la DB a partir de los códigos suministrados."
                    Throw New Exception()
                End If


                ms_dni_front = rs.Fields("image_binary").Value
                Dim front_img_extension As String = GetExtension(rs.Fields("image_content_type").Value.ToString())
                rs.MoveNext()

                ms_dni_dorso = rs.Fields("image_binary").Value
                Dim back_img_extension As String = GetExtension(rs.Fields("image_content_type").Value.ToString())
                rs.MoveNext()

                ms_selfie = rs.Fields("image_binary").Value
                Dim selfie_img_extension As String = "selfie." & GetExtension(rs.Fields("image_content_type").Value.ToString())
                rs.Close()

                err_renaper = nvFW.servicios.Renaper.ValidarIdentidad(ms_dni_front, ms_dni_dorso, ms_selfie)

                If err_renaper.numError <> 0 Then
                    message_debug_desc = err_renaper.debug_desc
                    Throw New Exception()
                End If


            Case 2
                ' No implemenetado
                message_debug_desc = "Paquete 2 ReNaPer no implementado."
                Throw New NotImplementedException()


            Case 3
                '********************************************************
                ' Paquete 3:
                '   Número DNI
                '   Género
                '   Número de trámite
                '********************************************************

                If xml_dni_frente Is Nothing Then
                    message_debug_desc = "No fué posible obtenerlos datos desde la DB."
                    Throw New Exception()
                End If

                Dim number As String = nvXMLUtiles.getNodeText(xml_dni_frente, "/error_mensajes/error_mensaje/params/number", "")
                Dim gender As String = nvXMLUtiles.getNodeText(xml_dni_frente, "/error_mensajes/error_mensaje/params/gender", "")
                Dim order As String = nvXMLUtiles.getNodeText(xml_dni_frente, "/error_mensajes/error_mensaje/params/order", "")

                If number = String.Empty OrElse gender = String.Empty OrElse order = String.Empty Then
                    message_debug_desc = "Número, género o número de trámite no determinado."
                    Throw New Exception()
                End If

                err_renaper = nvFW.servicios.Renaper.ValidarIdentidad(number, gender, order)

                If err_renaper.numError <> 0 Then
                    message_debug_desc = err_renaper.debug_desc
                    Throw New Exception()
                End If

                ' Verificar validez de RENAPER
                If err_renaper.params("valid").ToLower() <> "vigente" Then
                    message_debug_desc = "Identidad no válida según ReNaPer."
                    Throw New Exception()
                End If

                ' Verificar si no es fallecido
                If err_renaper.params("messageOfDeath").ToLower() <> "sin aviso de fallecimiento" Then
                    message_debug_desc = "ReNaPer informó que el individuo está fallecido."
                    Throw New Exception()
                End If

                If err_renaper.params("number") <> dni_or_cuitcuil Then
                    message_debug_desc = "No coincide el Número de DNI con el informado por ReNaPer."
                    Throw New Exception()
                End If
        End Select

        ' Guardar los datos si no hay error
        If err_renaper.numError = 0 Then
            For Each parametro In err_renaper.params
                If parametro.Key = "code" Then Continue For
                ' Cargamos los parametros de salida para RENAPER
                param_renaper(parametro.Key) = parametro.Value
            Next
        End If

    Catch ex As Exception
        biometric_response.parse_error_script(ex)
        biometric_response.titulo = "Error llamada API"
        biometric_response.mensaje = "Ocurrió un error al validar la identidad."
        biometric_response.debug_desc = message_debug_desc
        biometric_response.params.Clear()   ' No enviar nada a la salida
        biometric_response.response()
    End Try

    err_renaper = Nothing

    '------------------------------------------------------------------------------
    ' Asignar los parámetros de AWS y RENAPER al tError
    biometric_response.params("aws") = param_aws
    biometric_response.params("renaper") = param_renaper
    biometric_response.params("identity_key") = nvConvertUtiles.RamdomString(16)

    ' Actualizar el acceso con la nueva KEY de validacion
    Dim as_datos As String = String.Format("<as_data><identity_key>{0}</identity_key></as_data>", biometric_response.params("identity_key"))
    Dim sql_update As String = String.Format("UPDATE nv_public_access_key SET as_datos='{0}' WHERE access_key='{1}'", as_datos, access_key)

    Try
        nvDBUtiles.DBExecute(sql_update)
    Catch ex As Exception
        biometric_response.parse_error_script(ex)
        biometric_response.titulo = "Error llamada API"
        biometric_response.mensaje = "Ocurrió un error generando clave de identidad."
        biometric_response.debug_desc = "No se guardó la clave de identidad generada para la solicitud actual."
        biometric_response.params.Clear()
    End Try


    biometric_response.response()
%>
