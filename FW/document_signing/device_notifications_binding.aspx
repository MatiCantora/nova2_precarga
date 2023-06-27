<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageProxyIpCtrl" %>


<%@ Import Namespace="System.IO" %>

<script language="VB" runat="server">
</script>

<%
    Dim accion As String = obtenerValor("accion", "")
    
    ' Registrar dispositivo para firma
    If (accion.ToLower = "register_device") Then
        
        Dim err As New tError
        
        ' Buscar el response pending que genero la solicitud de registro de dispositivo
        Dim tran_id As String = nvUtiles.obtenerValor("tran_id", "")
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
        
        
        ' Obtener los parametros para el registro a partir del response pending
        ' y de las datos enviados desde la app movil
        Dim operador As String = responsePendingElem.operador
        Dim nro_entidad As String = responsePendingElem.element("nro_entidad")
        Dim secret_key As String = responsePendingElem.element("secret_key")
        Dim cod_hmac_algorithm As String = responsePendingElem.element("cod_hmac_algorithm")
        
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
        
        
        'TODO: Cuando se registra un celular con modelo y marca que ya existe, deberia preguntar por un uniqueid para verificar 
        ' si se trata del mismo dispositivo del user o si tiene dos celulares de la misma marca/modelo.
        ' Ahora admite registrar UN SOLO dispositivo de la misma marca/modelo
        Dim proc As String =
            "SET XACT_ABORT ON;" &
            "BEGIN TRAN;" &
            "DECLARE @cod_device INT = 1;" &
            "DECLARE @cod_device_operador INT=NULL;" &
            "DECLARE @cod_binding INT=NULL;" &
            "SELECT @cod_device=cod_device FROM mobile_devices WHERE device_manufacturer='" & device_manufacturer & "' AND device_model='" & device_model & "';" &
            "SELECT @cod_device_operador=cod_device_operador FROM device_operador WHERE cod_device=@cod_device AND operador=" & operador & "" & vbLf &
            "IF @cod_device_operador is null " & vbLf &
            "BEGIN" & vbLf &
            "INSERT INTO device_operador(cod_device, operador, device_operador_desc) VALUES(@cod_device," & operador & ",'')" & vbLf &
            "SELECT @cod_device_operador=@@identity" & vbLf &
            "END;" &
            "SELECT @cod_binding=cod_binding FROM notification_binding WHERE cod_device_operador=@cod_device_operador and cod_mobile_app='" & cod_mobile_app & "'" & vbLf &
            "IF @cod_binding is not null " & vbLf &
            "BEGIN" & vbLf &
            "DELETE FROM notification_bindings_signing_certificates WHERE cod_binding=@cod_binding" & vbLf &
            "DELETE FROM notification_binding WHERE cod_binding=@cod_binding" & vbLf &
            "END;" &
            "INSERT INTO notification_binding(cod_mobile_app, cod_device_operador, notification_token, secret_key, cod_hmac_algorithm) VALUES('" & cod_mobile_app & "', @cod_device_operador, '" & notification_token & "', '" & secret_key & "', '" & cod_hmac_algorithm & "');" &
            "SELECT  @cod_binding= @@identity;"
            
        For Each idcert In idCerts
            proc &= "IF NOT EXISTS(SELECT * FROM entidad_certificados WHERE idcert=" & idcert & " AND nro_entidad=" & nro_entidad & ")" & vbLf
            proc &= "INSERT into entidad_certificados(nro_entidad,idcert) VALUES(" & nro_entidad & ", " & idcert & ");" & vbLf
            'proc &= "ELSE " & vbLf & "UPDATE entidad_certificados set added_by_device=1 WHERE nro_entidad=" & nro_entidad & " AND idcert=" & idcert & ";"
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
    
    
    
    
    ' Servicio para actualizar token de notificacion
    ' Utiliza HMAC para verificar autenticacion e integridad
    If accion.ToLower = "update_notification_token" Then
        
        Dim err As New tError
        Dim cod_binding As String = nvUtiles.obtenerValor("cod_binding", "")
        Dim notification_token As String = nvUtiles.obtenerValor("notification_token", "")
        Dim notification_token_hmac As String = nvUtiles.obtenerValor("notification_token_hmac", "")
        
        If cod_binding <> "" And notification_token <> "" And notification_token_hmac <> "" Then
            
            Dim cod_hmac_algorithm As String = ""
            Dim secretKey As String = ""
            Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute("SELECT cod_hmac_algorithm, secret_key FROM notification_binding  WHERE cod_binding='" & cod_binding & "'")
            If Not rs.EOF Then
                cod_hmac_algorithm = rs.Fields("cod_hmac_algorithm").Value
                secretKey = rs.Fields("secret_Key").Value
            End If
            nvDBUtiles.DBCloseRecordset(rs)

            Dim hmac As System.Security.Cryptography.HMAC = Nothing
            If cod_hmac_algorithm = "1" Then
                hmac = New System.Security.Cryptography.HMACSHA1(Convert.FromBase64String(secretKey))
            ElseIf cod_hmac_algorithm = "2" Then
                hmac = New System.Security.Cryptography.HMACSHA256(Convert.FromBase64String(secretKey))
            Else
                err.numError = -1
                err.mensaje = "Algoritmo de HMAC no soportado"
                err.response()
            End If
            
            Dim validToken As Boolean = True
            Dim hmacData As Byte() = Convert.FromBase64String(notification_token_hmac)
            Using hmac
                Dim computedHmacValue As Byte() = hmac.ComputeHash(Encoding.UTF8.GetBytes(notification_token))
                For i As Integer = 0 To hmacData.Length - 1
                    If hmacData(i) <> computedHmacValue(i) Then
                        validToken = False
                        Exit For
                    End If
                Next
            End Using
        
            If Not validToken Then
                err.numError = -1
                err.mensaje = "El token de notificacion ha sido alterado o enviado de un origen desconocido"
                err.response()
            End If
        
            DBExecute("UPDATE notification_binding SET notification_token='" & notification_token & "' WHERE cod_binding='" & cod_binding & "'")
        End If
        Err.response()
    End If
    
    
    
    
    

%>