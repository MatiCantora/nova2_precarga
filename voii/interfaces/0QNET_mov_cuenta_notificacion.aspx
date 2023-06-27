<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIICallback" %>

<%
    Dim e As New tError()
    Dim strJSON As String = nvUtiles.obtenerValor("strJSON")


    Dim strSQL As String = "insert into dc_mov_cuenta_noti (valor) values ('" & strJSON & "')"
    nvFW.nvDBUtiles.DBExecute(strSQL)
    Dim id_inserted As Integer = nvFW.nvDBUtiles.DBExecute("select IDENT_CURRENT('dc_mov_cuenta_noti') as id").Fields("id").Value
    Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer


    'Antes de enviar el strJSON, dejo que corran nuevamente los envíos con error
    Try
        Dim rsPendientes As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute("select id_mov_cuenta_noti, intentos from API_clientes_cuentas_noti where estado='Error' and intentos < 4")
        Dim rsMovPendiente As ADODB.Recordset
        Dim strJSONmov As String
        Dim objResp_mov As Dictionary(Of String, Object)
        Dim cbu_mov As String
        Dim nro_docu_mov As String
        Dim rsCliente_mov As ADODB.Recordset
        Dim req_mov As New nvHTTPRequest

        While (Not rsPendientes.EOF)
            rsMovPendiente = nvFW.nvDBUtiles.DBExecute("select valor from dc_mov_cuenta_noti where id=" & rsPendientes.Fields("id_mov_cuenta_noti").Value)
            strJSONmov = rsMovPendiente.Fields("valor").Value

            objResp_mov = serializer.Deserialize(Of Dictionary(Of String, Object))(strJSONmov)
            cbu_mov = objResp_mov("Movimiento")("cbuDebito")
            nro_docu_mov = objResp_mov("Movimiento")("originante")("cuit")
            'Obtener dirección de endpoint del cliente identificado
            rsCliente_mov = nvFW.nvDBUtiles.DBOpenRecordset("SELECT callback FROM API_clientes_cuentas_cfg WHERE nrodoc='" & nro_docu_mov & "' and cbu='" & cbu_mov & "'")

            req_mov.url = rsCliente_mov.Fields("callback").Value
            req_mov.Method = "POST"
            req_mov.ContentType = "application/json"
            req_mov.Body = strJSONmov

            Dim res As String = req_mov.getResponseText()
            Dim estado As String = ""

            If (res Is Nothing OrElse res = String.Empty) AndAlso Not req_mov.response_error Is Nothing Then
                e.params("response_error") = True
                res = New IO.StreamReader(req_mov.response_error.GetResponseStream()).ReadToEnd()
                estado = "Error"
            Else
                estado = "Enviado"
            End If

            strSQL = "update API_clientes_cuentas_noti set estado='" & estado & "', intentos=" & rsPendientes.Fields("intentos").Value + 1 & ", fecha_ultimo_envio=GETDATE(), last_response='" & res & "' where id_mov_cuenta_noti =" & rsPendientes.Fields("id_mov_cuenta_noti").Value
            nvFW.nvDBUtiles.DBExecute(strSQL)

            rsMovPendiente.Close()
            rsPendientes.MoveNext()
        End While

        rsPendientes.Close()
    Catch ex As Exception

    End Try


    'Identificar el cliente a quien pertenece el movimiento
    Dim objResp As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(strJSON)
    Dim cbu As String = objResp("Movimiento")("cbuDebito")
    Dim nro_docu As String = objResp("Movimiento")("originante")("cuit")
    'Obtener dirección de endpoint del cliente identificado
    Dim rsCliente As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("Select callback FROM API_clientes_cuentas_cfg WHERE nrodoc='" & nro_docu & "' and cbu='" & cbu & "'")

    If Not rsCliente.EOF Then
        Try
            Dim req As New nvHTTPRequest
            req.url = rsCliente.Fields("callback").Value
            req.Method = "POST"
            req.ContentType = "application/json"
            req.Body = strJSON

            Dim res As String = req.getResponseText()
            Dim estado As String = ""

            If (res Is Nothing OrElse res = String.Empty) AndAlso Not req.response_error Is Nothing Then
                e.params("response_error") = True
                res = New IO.StreamReader(req.response_error.GetResponseStream()).ReadToEnd()
                estado = "Error"
            Else
                estado = "Enviado"
            End If

            strSQL = "insert into API_clientes_cuentas_noti (id_mov_cuenta_noti, estado, intentos, fecha_ultimo_envio, last_response) values (" & id_inserted & ",'" & estado & "', 1, GETDATE(), '" & res.Replace("'", "") & "')"
            nvFW.nvDBUtiles.DBExecute(strSQL)

        Catch ex As Exception
            e.numError = -90
            e.titulo = "Error"
            e.mensaje = "Ocurrió una excepción no controlada."
            e.debug_desc = ex.Message
            e.debug_src = "QNet Movimientos de Cuenta."
        End Try

    Else
        e.numError = -1
        e.titulo = "Operación incompleta."
        e.mensaje = "No se encontró el cliente."
        e.debug_src = "QNet Movimientos de Cuenta."
    End If
    rsCliente.Close()


    If (e.numError = 0) Then
        e.mensaje = "Operación realizada exitosamente."
    End If

    nvSession.Abandon()
    e.response()
%>