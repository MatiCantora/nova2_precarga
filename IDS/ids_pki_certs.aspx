<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%

    Dim certType As String = obtenerValor("certType", "", nvConvertUtiles.DataTypes.varchar) 'ACRoot | ACIntermediate | Server

    Dim strSQL As String = ""

    Select Case certType.tolower()
        Case "acroot"
            strSQL = "select cert_name, cert_notbefore, cert_notafter, cert_issuer, cert_subject, cert_bin from PKI_Certificados  join PKI on pki.ACRaiz = PKI_Certificados.IDCert " &
                     "join PKI_cert_binary on PKI_Certificados.IDCert = PKI_cert_binary.IDCert where IDPKI = '" & nvFW.nvSecurity.nvJWTConfig.PKI_name & "'"

        Case "acintermediate"
            strSQL = "select cert_name, cert_notbefore, cert_notafter, cert_issuer, cert_subject, cert_bin from PKI_carpetas " &
                     "Join PKI_carpeta_certificados on PKI_carpetas.IDPKI = PKI_carpeta_certificados.IDPKI and PKI_carpetas.carpeta_path = PKI_carpeta_certificados.carpeta_path " &
                     "join  PKI_Certificados on PKI_carpeta_certificados.IDCert = PKI_Certificados.IDCert " &
                     "Join PKI_cert_binary On PKI_Certificados.IDCert = PKI_cert_binary.IDCert " &
                     "where esConfiable = 1 and PKI_carpetas.IDPKI = '" & nvFW.nvSecurity.nvJWTConfig.PKI_name & "'"

        Case "server"
            strSQL = "select cert_name, cert_notbefore, cert_notafter, cert_issuer, cert_subject, cert_bin from PKI_carpetas " &
                 "Join PKI_carpeta_certificados on PKI_carpetas.IDPKI = PKI_carpeta_certificados.IDPKI and PKI_carpetas.carpeta_path = PKI_carpeta_certificados.carpeta_path " &
                 "join  PKI_Certificados on PKI_carpeta_certificados.IDCert = PKI_Certificados.IDCert " &
                 "Join PKI_cert_binary On PKI_Certificados.IDCert = PKI_cert_binary.IDCert " &
                 "where esMy = 1 and PKI_carpetas.IDPKI = '" & nvFW.nvSecurity.nvJWTConfig.PKI_name & "'"
        Case Else
            Dim err2 As New tError
            err2.numError = 154
            err2.titulo = "Error al recuperar los certificados"
            err2.mensaje = "El certType es incorrecto"
            err2.response()
    End Select

    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)

    Dim rsError As tError = nvXMLSQL.RecordsetTotError(rs, New trsParam)

    rsError.response()

%>