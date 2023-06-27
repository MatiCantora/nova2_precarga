Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Namespace nvFW


    Public Class nvPKIDBUtil


        ' ABM De PKI's
        Public Shared Function dbAddPKI(idpki As String, pki As String, pki_comentario As String, esconfiable As Boolean, urlTsa As String, cer As System.Security.Cryptography.X509Certificates.X509Certificate2, Optional cod_cn As String = "default") As nvFW.tError
            Return spPKI_ABM("A", idpki, pki, pki_comentario, 0, esconfiable, urlTsa, cer, cod_cn)
        End Function

        Public Shared Function dbDeletePKI(idpki As String, Optional cod_cn As String = "default") As nvFW.tError
            Return spPKI_ABM("B", idpki, "", "", 0, False, "", Nothing, cod_cn)
        End Function

        Public Shared Function dbUpdatePKI(idpki As String, pki As String, pki_comentario As String, acraiz As Integer, esconfiable As Boolean, urlTsa As String, Optional cer As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing, Optional cod_cn As String = "default") As nvFW.tError
            Return spPKI_ABM("M", idpki, pki, pki_comentario, acraiz, esconfiable, urlTsa, cer, cod_cn)
        End Function

        Private Shared Function spPKI_ABM(modo As String, idpki As String, pki As String,
                                          pki_comentario As String, acraiz As Integer, esconfiable As Boolean,
                                          urlTsa As String,
                                          Optional cer As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing,
                                          Optional cod_cn As String = "default") As nvFW.tError

            ' Certificado de la CA, agregar o actualizar
            If modo = "A" Or (modo = "M" And Not cer Is Nothing) Then
                Dim err_res As nvFW.tError = spCert_ABM(acraiz, Nothing, cer, cod_cn)
                acraiz = err_res.params("idcert")
            End If

            Dim cmdPKI As New nvFW.nvDBUtiles.tnvDBCommand(commandText:="pki_abm", commandType:=ADODB.CommandTypeEnum.adCmdStoredProc, cod_cn:=cod_cn)
            Dim param1PKI = cmdPKI.CreateParameter("@modo", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, modo)
            cmdPKI.Parameters.Append(param1PKI)
            Dim param2PKI = cmdPKI.CreateParameter("@idpki", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, idpki)
            cmdPKI.Parameters.Append(param2PKI)
            Dim param3PKI = cmdPKI.CreateParameter("@pki", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, pki)
            cmdPKI.Parameters.Append(param3PKI)
            Dim param4PKI = cmdPKI.CreateParameter("@pki_comentario", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, pki_comentario)
            cmdPKI.Parameters.Append(param4PKI)
            Dim param5PKI = cmdPKI.CreateParameter("@acraiz", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, acraiz)
            cmdPKI.Parameters.Append(param5PKI)
            Dim param6PKI As ADODB.Parameter = cmdPKI.CreateParameter("@esConfiable", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, -1, esconfiable)
            cmdPKI.Parameters.Append(param6PKI)
            Dim param7PKI As ADODB.Parameter = cmdPKI.CreateParameter("@urlTSA", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, urlTsa)
            cmdPKI.Parameters.Append(param7PKI)

            Dim res As ADODB.Recordset = cmdPKI.Execute()

            Dim err As nvFW.tError = New nvFW.tError
            If res.Fields.Item("numError").Value <> 0 Then
                err.numError = res.Fields("numError").Value
                err.mensaje = res.Fields("mensaje").Value
                err.titulo = res.Fields("titulo").Value
                err.debug_desc = res.Fields("debug_desc").Value
                err.debug_src = res.Fields("debug_src").Value
            Else
                err.mensaje = ""
                err.params("idpki") = idpki
                err.numError = 0
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(res)

            Return err
        End Function

        'ABM De Certificados en PKI
        Public Shared Function dbAddCert(idPKI As String, carpeta_path As String, cer As System.Security.Cryptography.X509Certificates.X509Certificate2, Optional cod_cn As String = "default") As nvFW.tError

            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT id_carpeta FROM pki_carpetas WHERE carpeta_path='" & carpeta_path & "'" & "AND IDPKI='" & idPKI & "'")
            Dim id_carpeta As Integer = rs.Fields("id_carpeta").Value
            Return spCert_ABM(0, id_carpeta, cer, cod_cn)
        End Function

        'ABM De Certificados en PKI
        Public Shared Function dbAddCert(id_carpeta As Integer, cer As System.Security.Cryptography.X509Certificates.X509Certificate2, Optional cod_cn As String = "default") As nvFW.tError
            Return spCert_ABM(0, id_carpeta, cer, cod_cn)
        End Function


        Public Shared Function dbDeleteCert(idCert As Integer, idcarpeta As String, Optional cod_cn As String = "default") As nvFW.tError

            ' Esto debido a que el storedproc pide el id del certificado a eliminar en negativo
            If idCert > 0 Then
                idCert = idCert * -1
            End If
            Return spCert_ABM(idCert, idcarpeta, Nothing, cod_cn)
        End Function

        Public Shared Function dbUpdateCert(idCert As Integer, id_carpeta As String, Optional cer As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing, Optional cod_cn As String = "default") As nvFW.tError
            Return spCert_ABM(idCert, id_carpeta, cer)
        End Function


        Private Shared Function spCert_ABM(idCert As Integer, idcarpeta As Integer, Optional cer As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing, Optional cod_cn As String = "default") As nvFW.tError

            Dim binary_serialnumber As Byte() = Nothing
            Dim binary_huella As Byte() = Nothing
            Dim binary_cert As Byte() = Nothing
            Dim binary_pkcs12 As Byte() = Nothing
            Dim cert_notafter As Date = Nothing
            Dim cert_notbefore As Date = Nothing
            Dim cert_version As String = ""
            Dim cert_issuer As String = ""
            Dim cert_subject As String = ""
            Dim cert_extensions As String = ""
            Dim cert_hasPrivateKey As Boolean = False
            Dim cert_exportable As Boolean = False
            Dim cert_secure As Boolean = False
            Dim pwd = ""
            Dim cert_name As String = ""

            If Not cer Is Nothing Then
                cert_name = cer.SubjectName.Name.ToString
                binary_serialnumber = cer.GetSerialNumber() 'oUtils.GetSerialNumber(cer)
                binary_huella = System.Text.Encoding.UTF8.GetBytes(cer.Thumbprint)
                binary_cert = cer.Export(System.Security.Cryptography.X509Certificates.X509ContentType.Cert)
                binary_pkcs12 = cer.Export(System.Security.Cryptography.X509Certificates.X509ContentType.Pkcs12, pwd)
                cert_notbefore = cer.NotBefore
                cert_notafter = cer.NotAfter
                cert_version = cer.Version
                cert_issuer = cer.Issuer
                cert_subject = cer.Subject
                cert_hasPrivateKey = cer.HasPrivateKey
                cert_extensions = "<extensions>"
                For Each ext In cer.Extensions
                    Dim asndata As New System.Security.Cryptography.AsnEncodedData(ext.Oid, ext.RawData)
                    cert_extensions += "<extension descripcion='" + ext.Oid.FriendlyName + "' valor='" + asndata.Format(True) + "'/>"
                Next
                cert_extensions += "</extensions>"
            End If

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(commandText:="pki_cert_abm", commandType:=ADODB.CommandTypeEnum.adCmdStoredProc, cod_cn:=cod_cn)
            Dim param1 As ADODB.Parameter = cmd.CreateParameter("@idcert", 3, 1, -1, idCert)
            cmd.Parameters.Append(param1)
            Dim param2 As ADODB.Parameter = cmd.CreateParameter("@cert_name", 201, 1, -1, cert_name)
            cmd.Parameters.Append(param2)
            Dim param3 As ADODB.Parameter = cmd.CreateParameter("@cert_hasPrivateKey", 11, 1, -1, cert_hasPrivateKey)
            cmd.Parameters.Append(param3)
            Dim param4 As ADODB.Parameter = cmd.CreateParameter("@cert_exportable", 11, 1, -1, cert_exportable)
            cmd.Parameters.Append(param4)
            Dim param5 As ADODB.Parameter = cmd.CreateParameter("@cert_secure", 11, 1, -1, cert_secure)
            cmd.Parameters.Append(param5)
            Dim param6 As ADODB.Parameter = cmd.CreateParameter("@cert_serial", 205, 1, -1, binary_serialnumber)
            cmd.Parameters.Append(param6)
            Dim param7 As ADODB.Parameter = cmd.CreateParameter("@cert_huella", 205, 1, -1, binary_huella)
            cmd.Parameters.Append(param7)
            Dim param8 = cmd.CreateParameter("@cert_bin", 205, 1, -1, binary_cert)
            cmd.Parameters.Append(param8)
            Dim param10 As ADODB.Parameter = cmd.CreateParameter("@cert_notbefore", ADODB.DataTypeEnum.adDate, 1, -1, cert_notbefore)
            cmd.Parameters.Append(param10)
            Dim param11 As ADODB.Parameter = cmd.CreateParameter("@cert_notafter", ADODB.DataTypeEnum.adDate, 1, -1, cert_notafter)
            cmd.Parameters.Append(param11)
            Dim param12 As ADODB.Parameter = cmd.CreateParameter("@cert_version", 201, 1, -1, cert_version)
            cmd.Parameters.Append(param12)
            Dim param13 As ADODB.Parameter = cmd.CreateParameter("@cert_issuer", 201, 1, -1, cert_issuer)
            cmd.Parameters.Append(param13)
            Dim param14 As ADODB.Parameter = cmd.CreateParameter("@cert_subject", 201, 1, -1, cert_subject)
            cmd.Parameters.Append(param14)
            Dim param15 As ADODB.Parameter = cmd.CreateParameter("@cert_extensions", 201, 1, -1, cert_extensions)
            cmd.Parameters.Append(param15)
            Dim param16 = cmd.CreateParameter("@cert_bin_pkcs12", 205, 1, -1, binary_pkcs12)
            cmd.Parameters.Append(param16)

            If idcarpeta <> Nothing Then
                Dim param17 As ADODB.Parameter = cmd.CreateParameter("@id_carpeta", 3, 1, -1, idcarpeta)
                cmd.Parameters.Append(param17)
            End If

            Dim res As ADODB.Recordset = cmd.Execute()
            Dim err As nvFW.tError = New nvFW.tError
            If res.Fields.Item("numError").Value <> 0 Then
                err.numError = res.Fields("numError").Value
                err.mensaje = res.Fields("mensaje").Value
                err.titulo = res.Fields("titulo").Value
                err.debug_desc = res.Fields("debug_desc").Value
                err.debug_src = res.Fields("debug_src").Value
                err.response()
            End If
            err.params.Add("idcert", res.Fields("idcert").Value)
            nvDBUtiles.DBCloseRecordset(res)

            Return err
        End Function


        ' ABM De Carpetas de PKI
        Public Shared Function pkiFolderABM(idpki As String, id_carpeta As Integer, carpeta_path As String, carpeta_nombre As String, esconfiable As Boolean, esmy As Boolean) As nvFW.tError

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("pki_carpeta_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
            Dim param1 As ADODB.Parameter = cmd.CreateParameter("@id_carpeta", 3, 1, 0, id_carpeta)
            cmd.Parameters.Append(param1)
            Dim param2 As ADODB.Parameter = cmd.CreateParameter("@IDPKI", 201, 1, idpki.Length, idpki)
            cmd.Parameters.Append(param2)
            Dim param3 As ADODB.Parameter = cmd.CreateParameter("@carpeta_path", 201, 1, carpeta_path.Length, carpeta_path)
            cmd.Parameters.Append(param3)
            Dim param4 As ADODB.Parameter = cmd.CreateParameter("@carpeta_nombre", 201, 1, carpeta_nombre.Length, carpeta_nombre)
            cmd.Parameters.Append(param4)
            Dim param5 As ADODB.Parameter = cmd.CreateParameter("@esConfiable", 11, 1, 0, esconfiable)
            cmd.Parameters.Append(param5)
            Dim param6 As ADODB.Parameter = cmd.CreateParameter("@esMy", 11, 1, 0, esmy)
            cmd.Parameters.Append(param6)
            Dim res As ADODB.Recordset = cmd.Execute()

            Dim err As nvFW.tError = New tError
            Dim numError As Integer = res.Fields.Item("numError").Value
            id_carpeta = res.Fields.Item("id_carpeta").Value

            If numError <> 0 Then
                err.numError = res.Fields("numError").Value
                err.mensaje = res.Fields("mensaje").Value
                err.titulo = res.Fields("titulo").Value
                err.debug_desc = res.Fields("debug_desc").Value
                err.debug_src = res.Fields("debug_src").Value
            Else
                err.mensaje = ""
                err.params("id_carpeta") = id_carpeta
                err.numError = 0
            End If
            Return err
        End Function




        Public Shared Function LoadPKIFromDB(idpki As String, nvcn As tDBConection, Optional loadDBOptions As nveunmloadDBOptions = nveunmloadDBOptions.loadAll) As nvFW.tnvPKI

            Dim oPki As nvFW.tnvPKI = New nvFW.tnvPKI
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL:="SELECT * FROM verPKI WHERE idpki='" & idpki & "'", _nvcn:=nvcn)
            If Not rs.EOF Then

                Dim certBytes() As Byte = rs.Fields("cert_bin").Value

                Dim rootCert As New System.Security.Cryptography.X509Certificates.X509Certificate2(certBytes, "", System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.Exportable)

                ' Este método falló para leer certificados de la BD
                'Dim parser As New Org.BouncyCastle.X509.X509CertificateParser()
                'Dim cert As Org.BouncyCastle.X509.X509Certificate = parser.ReadCertificate(certBytes)

                'Dim cert As Org.BouncyCastle.X509.X509Certificate =                    Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(New System.Security.Cryptography.X509Certificates.X509Certificate(certBytes))


                oPki.setPKI(rs.Fields("idpki").Value, rs.Fields("esConfiable").Value, rootCert)
                oPki.description = rs.Fields("pki").Value
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            If Not oPki.rootCert Is Nothing Then


                Dim cond As String = ""

                'loadNone = 0
                'loadTrusted = 1
                'loadMy = 2
                'LoadOther = 4
                'loadAll = 7

                If loadDBOptions = nveunmloadDBOptions.loadAll Then
                    cond = ""
                Else
                    Dim loadTrusted As Boolean = loadDBOptions And nveunmloadDBOptions.loadTrusted
                    Dim loadMy As Boolean = loadDBOptions And nveunmloadDBOptions.loadMy

                    cond = " AND (esconfiable='" & loadTrusted.ToString & "' AND esMy='" & loadMy.ToString & "' )"
                End If


                rs = nvDBUtiles.DBOpenRecordset(strSQL:="SELECT IDCert, cert_bin, carpeta_path, esMy, esConfiable, cert_hasPrivateKey FROM [verpki_certificados_carpetas] WHERE idpki='" & idpki & "' " & cond, _nvcn:=nvcn)
                While Not rs.EOF


                    Dim bytes As Byte() = rs.Fields("cert_bin").Value
                    If (rs.Fields("cert_hasPrivateKey").Value) Then
                        Dim strPK As String = "select cert_bin_pkcs12 from PKI_cert_binary where IDCert = " & rs.Fields("IDCert").Value
                        Dim rsPKS12 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strPK, _nvcn:=nvcn)
                        bytes = nvUtiles.isNUll(rsPKS12.Fields("cert_bin_pkcs12").Value, rs.Fields("cert_bin").Value)
                        nvDBUtiles.DBCloseRecordset(rsPKS12)
                    Else
                        bytes = rs.Fields("cert_bin").Value
                    End If
                    'Dim cert As Org.BouncyCastle.X509.X509Certificate = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(New System.Security.Cryptography.X509Certificates.X509Certificate(bytes))
                    Dim cert As New System.Security.Cryptography.X509Certificates.X509Certificate2(bytes, "", System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.Exportable)

                    Try
                        oPki.createFolder(rs.Fields("carpeta_path").Value, rs.Fields("esConfiable").Value, rs.Fields("esMy").Value)
                    Catch
                        'Exception si la carpeta ya existe
                    End Try

                    oPki.addCert(rs.Fields("carpeta_path").Value, cert)
                    rs.MoveNext()
                End While
                nvFW.nvDBUtiles.DBCloseRecordset(rs)


            End If
            Return oPki
        End Function



        Public Shared Function LoadPKIFromDB(idpki As String, nvApp As tnvApp, Optional cod_cn As String = "default", Optional loadDBOptions As nveunmloadDBOptions = nveunmloadDBOptions.loadAll) As nvFW.tnvPKI
            If cod_cn = Nothing Then
                cod_cn = "default"
            End If

            Dim app_cn_strings As Dictionary(Of String, tDBConection) = nvApp.app_cns
            Dim nvcn As tDBConection = app_cn_strings(cod_cn)
            Return LoadPKIFromDB(idpki, nvcn, loadDBOptions)
        End Function
        Public Shared Function LoadPKIFromDB(idpki As String, Optional cod_cn As String = "default", Optional loadDBOptions As nveunmloadDBOptions = nveunmloadDBOptions.loadAll) As nvFW.tnvPKI

            Dim nvApp As tnvApp = nvFW.nvApp.getInstance()

            Return LoadPKIFromDB(idpki, nvApp, cod_cn, loadDBOptions)
        End Function


        Public Class SharedGlobals
            'Public Shared fileSignaturesValidation As Dictionary(Of String, Dictionary(Of String, tnvFileSignatureValidation))
            Public Shared PKIBasics As New Dictionary(Of String, Dictionary(Of String, nvFW.tnvPKI))
        End Class



        Public Class tnvFileSignatureValidation
            'Public Property pki As String
            'Public Property pkiName As String
            'Public Property pkiRootSubjectDN As String

            Public Property file_id As String
            Public Property signaturesStatus As New Dictionary(Of String, Dictionary(Of String, nvFW.tnvSignVerifyStatus))
            Public Property validationTime As DateTime
        End Class


        Public Enum nveunmloadDBOptions
            loadNone = 0
            loadTrusted = 1
            loadMy = 2
            LoadOther = 4
            loadAll = 7
        End Enum

    End Class

End Namespace
