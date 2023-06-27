<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' insertar log
    '--------------------------------------------------------------------------
    Dim e As New terror()
    Try
        Dim id_evento As String = nvUtiles.obtenerValor("id_evento", "")
        Dim accion As String = nvUtiles.obtenerValor("accion", "") ' ejemplo paso1,paso2,paso3, etc
        Dim params As Object = nvUtiles.obtenerValor("params", "") ' todos los parametros que quieras separados por ;

        Dim logTrack As String = nvLog.getNewLogTrack()
        'Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
        'Dim ts As TimeSpan = Stopwatch.Elapsed

        Dim params_json As String = ""
        Try
            params_json = "{"
            For Each item In params
                params_json += """" & item.key & """:""" & item.value & ""","
            Next
            params_json = params_json.Substring(0, params_json.Length - 1)
            params_json += "}"
            params = params_json
        Catch ex As Exception

        End Try


        nvLog.addEvent(id_evento, logTrack & ";" & accion & ";" & params)


    Catch ex As Exception
        e.numError = 1001
        e.titulo = "Error de log"
        e.mensaje = "La acción es desconocido"
        e.debug_src = "log"
    End Try

    e.response()

%>