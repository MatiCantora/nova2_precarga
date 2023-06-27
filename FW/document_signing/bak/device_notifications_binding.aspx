<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageProxyIpCtrl" %>


<%@ Import Namespace="System.IO" %>

<%
    
    Dim accion As String = obtenerValor("accion", "")

    ' va a url con query string=
    'app_cod_sistema
    'nv_hash
   
    If (accion.ToLower = "register_device") Then
        Dim err As New tError
        

        Dim tran_id As String = nvUtiles.obtenerValor("tran_id", "")
        
        
        ' buscar el response pending
        Dim responsePendingElem As nvFW.nvResponsePending.nvResponsePendingElement = Nothing
        Try
            responsePendingElem = nvFW.nvResponsePending.get(tran_id)
        Catch ex As Exception
            err.numError = -1
            err.mensaje = "No se pudo encontrar el proceso pendiente asociado."
            err.response()
        End Try
        
        If responsePendingElem.state = nvResponsePending.enumPendingSatate.timeout Then
            err.numError = -1
            err.mensaje = "El proceso de vinculación expiró. Intente vincularse nuevamente."
            err.response()
        End If
        
        
        ' con el tran_id obtengo el operador 
        Dim operador As String = responsePendingElem.operador
        Dim cod_mobile_app As String = nvUtiles.obtenerValor("cod_mobile_app", "")
        Dim notification_token As String = nvUtiles.obtenerValor("notification_token", "")
        Dim signature_certs As String = nvUtiles.obtenerValor("signature_certs", "")
        Dim device_manufacturer As String = nvUtiles.obtenerValor("device_manufacturer", "")
        Dim device_model As String = nvUtiles.obtenerValor("device_model", "")
        
        
        ' instalar el certificado de firma
        ' en carpeta entidadesde de la pki del certificado
        Dim pemList As String() = signature_certs.Split(",")
        Dim idCerts As New List(Of String)
        For Each pem As String In pemList
            
            If pem = "" Then Continue For
            
            Dim cer As New System.Security.Cryptography.X509Certificates.X509Certificate2
            cer.Import(System.Text.Encoding.UTF8.GetBytes(pem), "", System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.UserKeySet)
            
            ' corroborar que certificado pertenece a algunas de las pkis
            Dim idpki As String = ""
            For Each pkiId In nvApp.PKIs.Keys
                Dim pki As tnvPKI = nvApp.PKIs(pkiId)
                Dim includeRoot As Boolean = False
                pki.getChainElement(Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cer), includeRoot)
                If includeRoot Then
                    idpki = pkiId
                    Exit For
                End If
            Next
   
            If idpki = "" Then
                err.numError = -1
                err.titulo = "Error"
                err.mensaje = "La PKI del certificado es desconocida"
                err.debug_desc = "La PKI del certificado es desconocida"
                err.debug_src = "device_notifications_binding.aspx"
                err.response()
            End If
            
            ' Agregar carpeta entidades en caso de que no exista
            nvFW.nvPKIDBUtil.pkiFolderABM(idpki, 0, "entidades", "entidades", False, False)
            
            Dim errCer As tError = nvFW.nvPKIDBUtil.dbAddCert(idpki, "entidades", cer)
            Dim idcert As String = errCer.params("idcert")
            
            If idcert > 0 Then
                idCerts.Add(idcert)
            Else
                err.numError = -1
                err.titulo = "Error"
                err.mensaje = "No se pudo vincular el certificado de firma"
                err.debug_desc = errCer.debug_desc
                err.debug_src = "device_notifications_binding.aspx"
                err.response()
            End If
            
        Next
        
        

        Dim proc As String =
            "BEGIN TRAN;" &
            "DECLARE @cod_device INT = 1;" &
            "DECLARE @cod_device_operador INT;" &
            "DECLARE @cod_binding INT;" &
            "SELECT @cod_device=cod_device FROM mobile_devices WHERE device_manufacturer='" & device_manufacturer & "' AND device_model='" & device_model & "';" &
            "INSERT INTO device_operador(cod_device, operador) VALUES(@cod_device,'" & operador & "');" &
            "SELECT @cod_device_operador=@@identity;" &
            "INSERT INTO notification_binding(cod_mobile_app, cod_device_operador, notification_token) VALUES('" & cod_mobile_app & "', @cod_device_operador, '" & notification_token & "' );" &
            "SELECT  @cod_binding= @@identity;"
            
        For Each idcert In idCerts
            proc &= "INSERT INTO notification_bindings_signing_certificates(cod_binding, idcert) values(@cod_binding, " & idcert & ");"
        Next
        
        proc &= "COMMIT TRAN;" &
                "SELECT @cod_binding"
        
        Dim cod_binding As String = ""
        Dim rs As ADODB.Recordset = DBExecute(proc)
        If Not rs.EOF Then
            cod_binding = rs.Fields(0).Value
        End If
        DBCloseRecordset(rs)
        
        
        If cod_binding <> "" Then
            err.params("cod_binding") = cod_binding
            Try
                nvFW.nvResponsePending.get(tran_id).state = nvResponsePending.enumPendingSatate.terminado
            Catch ex As Exception
            End Try
          
        Else
            err.numError = "-1"
            err.mensaje = "No se pudo registrar dispositivo"
            err.debug_desc = ""
            err.debug_src = ""
        End If
        err.response()
    End If
    
    
    If accion.ToLower = "update_notification_token" Then
        
        
        Dim err As New tError
        Dim cod_binding As String = nvUtiles.obtenerValor("cod_binding", "")
        Dim notification_token As String = nvUtiles.obtenerValor("notification_token", "")
        
        'Dim notification_token_signature As String = nvUtiles.obtenerValor("notification_token_signature", "")
        'Dim data() As Byte = System.Text.Encoding.UTF8.GetBytes(notification_token)
        'Dim dataHash() As Byte
        
        '' Firma es valida para alguno de los certificados
        'Dim certificates As New List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)
        'Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT cert_binary FROM [vernotification_bindings_signing_certificates] WHERE cod_binding=" & cod_binding)
        'While Not rs.EOF
        '    Dim certBytes As Byte() = rs.Fields("cert_binary").Value
        '    Dim cer As New System.Security.Cryptography.X509Certificates.X509Certificate2(certBytes)
        '    certificates.Add(cer)
        '    rs.MoveNext()
        'End While
        'nvDBUtiles.DBCloseRecordset(rs)
        
        
        'Dim validSignature As Boolean = False
        'For Each cert As System.Security.Cryptography.X509Certificates.X509Certificate2 In certificates
      
        '    Dim mapField = GetType(Org.BouncyCastle.Cms.CmsSignedData).Assembly.GetType("Org.BouncyCastle.Cms.CmsSignedHelper").GetField("digestAlgs", Reflection.BindingFlags.Static Or Reflection.BindingFlags.NonPublic)
        '    Dim map = mapField.GetValue(Nothing)
        '    Dim strAlgoritmoHash As String = DirectCast(map(cert.SignatureAlgorithm.Value), String) ' returns "SHA256" for OID of sha256 with RSA.
        
            
        '    Dim csp As System.Security.Cryptography.RSACryptoServiceProvider = DirectCast(cert.PublicKey.Key, System.Security.Cryptography.RSACryptoServiceProvider)
        '    validSignature = csp.VerifyData(data, System.Security.Cryptography.CryptoConfig.MapNameToOID(strAlgoritmoHash), Convert.FromBase64String(notification_token_signature))
        '    If validSignature Then
        '        Exit For
        '    End If
            
            
        '    'Select Case strAlgoritmoHash
        '    '    Case "SHA1"
        '    '        Dim sha1 As New System.Security.Cryptography.SHA1Managed()
        '    '        dataHash = sha1.ComputeHash(data)
        '    '    Case Else
        '    '        Dim sha256 As New System.Security.Cryptography.SHA256Managed()
        '    '        dataHash = sha256.ComputeHash(data)
        '    '        'Case "SHA384"

        '    '        'Case "SHA512"

        '    '        'Case "RIPEMD160"
        '    'End Select
        
        '    'Dim csp As System.Security.Cryptography.RSACryptoServiceProvider = DirectCast(cert.PublicKey.Key, System.Security.Cryptography.RSACryptoServiceProvider)
        '    'validSignature = csp.VerifyHash(dataHash, System.Security.Cryptography.CryptoConfig.MapNameToOID(strAlgoritmoHash), Convert.FromBase64String(notification_token_signed_hash))
        '    'If validSignature Then
        '    '    Exit For
        '    'End If
            
        'Next
        
        
        'If Not validSignature Then
        '    err.numError = 10
        '    err.titulo = "Error"
        '    err.mensaje = "El hash firmado no se corresponde con el token de notificación"
        '    err.debug_desc = ""
        '    err.response()
        'End If
        
        
        If cod_binding <> "" And notification_token <> "" Then
            DBExecute("UPDATE notification_binding SET notification_token='" & notification_token & "' WHERE cod_binding='" & cod_binding & "'")
        End If
        
        err.response()
    End If
    

%>