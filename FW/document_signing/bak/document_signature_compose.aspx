<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageProxyIpCtrl" %>


<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="System.IO" %>


<%
 
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    
    If accion = "compose_signature" Then
        
        Dim proc_id As String = nvUtiles.obtenerValor("proc_id", "")
        Dim err As New tError
        
        
        If nvFW.nvResponsePending.get(proc_id) Is Nothing Then
            err.numError = -1
            err.mensaje = "No existe el proceso pendiente asociado a la firma"
            err.response()
        End If
        
        If nvFW.nvResponsePending.get(proc_id).state = nvResponsePending.enumPendingSatate.terminado Or nvFW.nvResponsePending.get(proc_id).state = nvResponsePending.enumPendingSatate.timeout Then
            err.numError = -1
            err.mensaje = "El proceso pendiente de firma a expirado"
        End If
        
        If nvFW.nvResponsePending.get(proc_id).element.ContainsKey("sign_pending") Then
            
            Dim defSign As nvPDFDeferredSign = nvFW.nvResponsePending.get(proc_id).element("sign_pending")
            Dim f_id As String = nvFW.nvResponsePending.get(proc_id).element("f_id")
            Dim signedDigest As String = nvUtiles.obtenerValor("signed_digest", "")
            
            ' ensamblar pdf con firma
            Dim signedPDF As Byte() = defSign.composeSignedPDF(signedDigest)
            If Not signedPDF Is Nothing Then
                
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM ref_files WHERE f_id=" + f_id)
                Dim f_path As String
                Dim f_nro_ubi As String = "1"
                If Not rs.EOF Then
                    f_path = rs.Fields("f_path").Value
                    f_nro_ubi = rs.Fields("f_nro_ubi").Value
                End If
                If f_nro_ubi = "1" Then
                    Try
                        DBExecute("UPDATE ref_files SET f_falta=GETDATE() WHERE f_id=" + f_id + ";")
                        Using fs As New FileStream(f_path, System.IO.FileMode.Create)
                            fs.Write(signedPDF, 0, signedPDF.Length)
                        End Using
                    Catch e As Exception
                        err.parse_error_script(e)
                    End Try
                Else
                    ' updatear binario del file en la wiki
                    Dim sqltran As String = ""
                    sqltran &=
                        "BEGIN TRAN;" &
                        "UPDATE ref_files SET f_falta=GETDATE() WHERE f_id=" + f_id + ";" &
                        "UPDATE ref_file_bin SET binaryData=?  WHERE f_id=" + f_id + ";" &
                        "COMMIT TRAN;"
                    
                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(sqltran, ADODB.CommandTypeEnum.adCmdText)
                    Dim objParm1 = cmd.CreateParameter("@binaryData", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, signedPDF.Length, signedPDF)
                    cmd.Parameters.Append(objParm1)
                    Try
                        cmd.Execute()
                    Catch e As Exception
                        err.parse_error_script(e)
                    End Try
                End If
            Else
                err.numError = "-1"
                err.mensaje = "No se pudo generar el archivo firmado. Compruebe que el espacio reservado para la firme sea el suficiente"
            End If
        End If
        
        ' marcar proceso pendiente como terminado
        nvFW.nvResponsePending.get(proc_id).state = nvResponsePending.enumPendingSatate.terminado

        err.response()
    End If
    

%>