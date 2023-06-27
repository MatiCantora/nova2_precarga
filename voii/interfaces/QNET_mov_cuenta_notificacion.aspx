<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIICallback" %>

<%
    Dim e As New tError()
    Dim strJSON As String = nvUtiles.obtenerValor("strJSON")
    Dim strSQL As String = ""
    Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer

    'Antes de enviar el strJSON, dejo que corran nuevamente los envíos con error
    Try
        Dim rsPendientes As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute("select id, intentos, valor from dc_mov_cuenta_noti where estado='Error' and intentos < 4")
        Dim strJSONmov As String
        Dim objResp_mov As Dictionary(Of String, Object)
        Dim cbu_mov As String
        Dim nro_docu_mov As String
        Dim rsCliente_mov As ADODB.Recordset
        Dim req_mov As New nvHTTPRequest

        While (Not rsPendientes.EOF)
            strJSONmov = rsPendientes.Fields("valor").Value

            objResp_mov = serializer.Deserialize(Of Dictionary(Of String, Object))(strJSONmov)
            cbu_mov = objResp_mov("Movimiento")("cbuCredito")
            nro_docu_mov = objResp_mov("Movimiento")("destinatario")("cuit")
            'Obtener dirección de endpoint del cliente identificado
            rsCliente_mov = nvFW.nvDBUtiles.DBOpenRecordset("SELECT callback FROM API_clientes_cuentas_cfg WHERE nrodoc='" & nro_docu_mov & "' and cbu='" & cbu_mov & "'")

            If Not rsCliente_mov.EOF Then
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

                strSQL = "update dc_mov_cuenta_noti set estado='" & estado & "', intentos=" & rsPendientes.Fields("intentos").Value + 1 & ", fecha_ultimo_envio=GETDATE(), last_response='" & res & "' where id =" & rsPendientes.Fields("id").Value
                nvFW.nvDBUtiles.DBExecute(strSQL)
            End If

            rsPendientes.MoveNext()
        End While

        rsPendientes.Close()
    Catch ex As Exception
        e.debug_desc = ex.Message
    End Try

    'Identificar el cliente a quien pertenece el movimiento
    Dim objResp As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(strJSON)
    Dim cbu As String = objResp("Movimiento")("cbuCredito")
    Dim nro_docu As String = objResp("Movimiento")("destinatario")("cuit")
    'Obtener dirección de endpoint del cliente identificado
    Dim rsCliente As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("Select callback FROM API_clientes_cuentas_cfg WHERE nrodoc='" & nro_docu & "' and cbu='" & cbu & "'")

    If Not rsCliente.EOF Then
        Try
            Dim req As New nvHTTPRequest
            req.url = rsCliente.Fields("callback").Value
            req.time_out = 3000
            req.Method = "POST"
            req.ContentType = "application/json"
            req.Body = strJSON

            Dim response As System.Net.HttpWebResponse = req.getResponse()
            Dim estado As String = ""
            Dim status_code As Integer
            Dim res As String = ""
            Dim reader As System.IO.StreamReader

            If response Is Nothing Then
                e.params("response_error") = True
                res = "Servidor no responde"
                status_code = -1
                estado = "Error"
            Else
                status_code = response.StatusCode
                If response.StatusCode = 200 Then
                    estado = "Enviado"
                    reader = New System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding("UTF-8"))
                    res = reader.ReadToEnd()
                Else
                    e.params("response_error") = True
                    reader = New System.IO.StreamReader(req.response_error.GetResponseStream(), System.Text.Encoding.GetEncoding("UTF-8"))
                    res = reader.ReadToEnd()
                    estado = "Error"
                End If
            End If

            strSQL = "insert into dc_mov_cuenta_noti (valor, nro_docu, cbu, estado, intentos, fecha_ultimo_envio, last_response, status_code) values ('" & strJSON & "','" & nro_docu & "','" & cbu & "','" & estado & "', 1, GETDATE(), '" & res.Replace("'", "") & "', " & status_code & ")"
            nvFW.nvDBUtiles.DBExecute(strSQL)

        Catch ex As Exception
            e.numError = -90
            e.titulo = "Error"
            e.mensaje = "Ocurrió una excepción no controlada."
            e.debug_desc = ex.Message
            e.debug_src = "QNet Movimientos de Cuenta."
        End Try

    Else
        strSQL = "insert into dc_mov_cuenta_noti (valor, nro_docu, cbu, estado, intentos, fecha_ultimo_envio, last_response) values ('" & strJSON & "','" & nro_docu & "','" & cbu & "','Error', 0, GETDATE(), 'No se encontró el cliente para hacer el callback.')"
        nvFW.nvDBUtiles.DBExecute(strSQL)

        e.numError = -1
        e.titulo = "Operación incompleta."
        e.mensaje = "No se encontró el cliente para hacer el callback."
        e.debug_src = "QNet Movimientos de Cuenta."
    End If
    rsCliente.Close()


    If (e.numError = 0) Then
        e.mensaje = "Operación realizada exitosamente."
        e.debug_src = "QNet Movimientos de Cuenta."
        e.debug_desc = ""
    End If

    nvSession.Abandon()
    e.response()
%>