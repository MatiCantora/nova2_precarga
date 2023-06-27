<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>

<script runat="server" language="VB">
    Function GetImageStream(ByVal image_source As String) As IO.MemoryStream
        Dim image_bytes As Byte() = IO.File.ReadAllBytes(image_source)
        Return New IO.MemoryStream(image_bytes)
    End Function
</script>

<%
    Stop

    Dim url_base As String = "C:\Users\mmeurzet\Pictures\test\aws\"
    Dim imagenes As New trsParam

    '' Imagenes de FRENTE con variaciones leves en pitch, roll y yaw
    'imagenes("frente") = "frente.jpg"
    'imagenes("frente_pitch_up") = "frente_pitch_up.jpg"
    'imagenes("frente_pitch_down") = "frente_pitch_down.jpg"
    'imagenes("frente_roll_right") = "frente_roll_right.jpg"
    'imagenes("frente_roll_left") = "frente_roll_left.jpg"
    'imagenes("frente_yaw_right") = "frente_yaw_right.jpg"
    'imagenes("frente_yaw_left") = "frente_yaw_left.jpg"

    '' Imagenes con cambios grandes en pitch, roll y yaw
    'imagenes("pitch_up") = "pitch_up.jpg"
    'imagenes("pitch_down") = "pitch_down.jpg"
    'imagenes("roll_right") = "roll_right.jpg"
    'imagenes("roll_left") = "roll_left.jpg"
    'imagenes("yaw_right") = "yaw_right.jpg"
    'imagenes("yaw_left") = "yaw_left.jpg"


    ' Imagenes para analizar ojos
    url_base &= "eyes\compressed\"
    imagenes("eyes_closed") = "eyes_closed.jpg"
    imagenes("eye_right_open") = "eye_right_open.jpg"
    imagenes("eye_left_open") = "eye_left_open.jpg"


    Dim general_response As New tError
    Dim img_response As tError
    Dim image_path As String
    Dim image_stream As IO.MemoryStream
    Dim detect_attribute As nvFW.servicios.AWS.Rekognition.awsEnumDetectFacesAttribute = nvFW.servicios.AWS.Rekognition.awsEnumDetectFacesAttribute.ALL

    ' Recorrer el diccionario y llamar al servicio de AWS Rekognition
    For Each imagen In imagenes
        ' Cargar Imagen
        image_path = url_base & imagen.Value
        image_stream = GetImageStream(image_path)

        ' Llamar servicio AWS
        img_response = nvFW.servicios.AWS.Rekognition.DetectarSelfie(image_stream, detect_attribute:=detect_attribute)

        ' Salvar el resultado dentro de a respuesta general
        general_response.params(imagen.Key) = img_response.params
    Next


    general_response.response(tError.nvenum_error_format.json)



    '***********************************************************************


    'Dim image_stream As IO.MemoryStream = GetImageStream(url_base & "")
    'Dim detect_attribute As nvFW.servicios.AWS.Rekognition.awsEnumDetectFacesAttribute = nvFW.servicios.AWS.Rekognition.awsEnumDetectFacesAttribute.ALL

    'Dim aws_response As tError = nvFW.servicios.AWS.Rekognition.DetectarSelfie(image_stream, detect_attribute:=detect_attribute)
    'aws_response.response(tError.nvenum_error_format.json)
%>
