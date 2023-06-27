<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecargaCallback" %>
<%@ Import namespace="nvFW"  %>
<%@ Import namespace="nvFW.nvUtiles"  %>
<%@ Import namespace="nvFW.nvDBUtiles"  %>

<%

    Dim Err As New tError
    Dim cod_acceso As String = nvUtiles.obtenerValor("cod_acceso")
    Dim criterio As String = nvUtiles.obtenerValor({"resultado", "Resultado"}, "")

    Try

        Dim strSQL As String = "SELECT id FROM lausana_anexa..cuad_robot where cod_acceso = '" & cod_acceso & "' AND vigente = 1 AND (fe_venc > GETDATE() or fe_venc is null)"
        Dim rs As ADODB.Recordset = DBExecute(strSQL)
        If Not rs.EOF Then
            Dim id As Integer = CInt(rs.Fields("id").Value)
            'Quitar vigencia
            DBExecute("UPDATE lausana_anexa..cuad_robot SET vigente=0 WHERE cod_acceso='" & cod_acceso & "'")
            If (criterio <> "" And id <> 0) Then
                Dim req As New nvFW.servicios.Robots.wsCuad
                req.ProcessResponse(id, criterio)
            End If
        Else
            Err.numError = 99
            Err.mensaje = "El código de acceso es invalido"
        End If
        nvDBUtiles.DBCloseRecordset(rs)

    Catch ex As Exception

        Err.numError = -99
        Err.mensaje = "Error del callback. mensaje: " & ex.Message.ToString

    End Try

    If Err.numError <> 0 Then

        Err.titulo = "Error de callback CUAD"
        Err.debug_src = "nvPageMutualPrecargaCallback::cuad_callback"

        Dim logTrack As String = nvLog.getNewLogTrack()
        nvLog.addEvent("lg_interface_request", logTrack & ";" & Request.Url.ToString & ";" & Err.get_error_xml())

    End If

    nvSession.Abandon()

    Err.response()

%>