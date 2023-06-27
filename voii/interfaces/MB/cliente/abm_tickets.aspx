﻿<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    Dim e As New tError()

    Try
        Dim tipo_docu As Integer = nvUtiles.obtenerValor("tipo_docu")
        Dim nro_docu As Double = nvUtiles.obtenerValor("nro_docu")
        Dim modo As String = nvUtiles.obtenerValor("modo")
        Dim datosTicket As Dictionary(Of String, Object) = Nothing
        Dim strComentario As String = nvUtiles.obtenerValor("datosTicket", "")

        Select Case modo
            Case = "A"
                Dim nro_ticket_trx As String = nvUtiles.obtenerValor("tipo_trx")

                If nro_ticket_trx Is Nothing Then
                    e.numError = -1
                    e.titulo = "ERROR"
                    e.mensaje = "Faltó especificar el nro_ticket_trx."
                    e.debug_src = "Guardado Ticket Link"
                    nvSession.Abandon()
                    e.response()

                ElseIf strComentario = "" Then
                    e.numError = -2
                    e.titulo = "ERROR"
                    e.mensaje = "Faltaron datos necesarios."
                    e.debug_src = "Guardado Ticket Link"
                    nvSession.Abandon()
                    e.response()

                End If

                Dim strSQL As String = "insert into cliente_mb_tickets (tipo_docu, nro_docu, nro_ticket_trx, comentario, fecha_alta) values (" & tipo_docu & "," & nro_docu & ", '" & nro_ticket_trx & "', '" & strComentario & "', GETDATE() )"
                nvFW.nvDBUtiles.DBExecute(strSQL)
                e.mensaje = "Ticket guardado con éxito."
                e.numError = 0

            Case = "Q"
                Dim fecha_desde As String = nvUtiles.obtenerValor("fecha_desde", "")
                Dim fecha_hasta As String = nvUtiles.obtenerValor("fecha_hasta", "")
                Dim filtroWhere As String = nvUtiles.obtenerValor("filtroWhere", "")
                Dim filtroWhereTmp As String = ""

                If fecha_desde <> "" Then
                    filtroWhereTmp &= "<fecha_alta type='mas'> convert(datetime, '" & fecha_desde & "', 103)</fecha_alta>"
                End If

                If fecha_hasta <> "" Then
                    filtroWhereTmp &= "<fecha_alta type='menor'> convert(datetime, '" & fecha_hasta & "', 103)+1</fecha_alta>"
                End If

                If filtroWhere <> "" Then
                    filtroWhereTmp &= filtroWhere
                End If

                Dim strSQL As String = "<criterio><select vista='cliente_mb_tickets'><campos>nro_cliente_ticket, nro_ticket_trx, fecha_alta, comentario</campos><filtro><and><tipo_docu type='igual'>" & tipo_docu & "</tipo_docu><nro_docu type='igual'>" & nro_docu & "</nro_docu>" & filtroWhereTmp & "</and></filtro></select></criterio>"
                Dim rs As ADODB.Recordset = nvFW.nvXMLSQL.XMLtoRecordset(strSQL)

                Dim params_json As String = "{"

                While rs.EOF = False
                    params_json &= "'ticket" & rs.Fields("nro_cliente_ticket").Value & "': {"
                    params_json &= "'nro_ticket_trx': '"
                    params_json &= rs.Fields("nro_ticket_trx").Value & "',"
                    params_json &= "'fecha_alta': '"
                    params_json &= rs.Fields("fecha_alta").Value & "',"
                    params_json &= "'datosTicket': '"
                    params_json &= rs.Fields("comentario").Value & "'},"

                    rs.MoveNext()
                End While

                If params_json <> "{" Then
                    params_json = params_json.Remove(params_json.Length - 1)
                End If
                params_json &= "}"

                If params_json <> "{}" Then
                    'Deserializar el JSON a un object
                    Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
                    Dim objResp As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(params_json)
                    Dim trsResp As New trsParam(objResp)
                    e.params("movimientos") = trsResp
                    e.mensaje = "Se encontraron los siguientes registros asociados."
                Else
                    e.mensaje = "No se encontraron registros asociados."
                End If

                nvDBUtiles.DBCloseRecordset(rs)
                e.titulo = "Consulta hecha con éxito."
                e.numError = 0

        End Select

    Catch ex As Exception
        e.numError = -99
        e.titulo = "ERROR"
        e.mensaje = "Ocurrió una excepción no controlada."
        e.debug_desc = ex.Message
        e.debug_src = "Guardado y Consulta Ticket Link"
    End Try

    nvSession.Abandon()
    e.response()

%>