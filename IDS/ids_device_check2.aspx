<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim err As New tError

    Dim image_type As String = obtenerValor("image_type")
    Dim imgB64 As String = obtenerValor("img")
    Dim img_bytes As Byte() = Convert.FromBase64String(imgB64)

    Dim image_code As String = "23qwe32"

    If Me.nvDevice Is Nothing Then
        err.params("image_code") = image_code
    Else
        Dim rs As New trsParam()
        rs("image_code") = image_code
        Dim jsonRes_enc As nvFW.nvIDS.tnvDeviceEncData = Me.nvDevice.EncRsaAes256(rs)

        err.params("simKey") = jsonRes_enc.simKeyB64
        err.params("DeviceDataResEnc") = jsonRes_enc.encDataB64
    End If

    err.response()
%>