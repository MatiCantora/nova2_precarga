<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar moviminetos psp
    '--------------------------------------------------------------------------

    'Dim io As System.IO.Stream = HttpContext.Current.Request.InputStream
    'io.Position = 0
    'Dim buffer(io.Length - 1) As Byte
    'io.Read(buffer, 0, buffer.Length)
    'io.Position = 0

    'Dim strJSON As String = nvFW.nvConvertUtiles.currentEncoding.GetString(buffer)
    'Dim logTrack As String = nvLog.getNewLogTrack()
    'nvLog.addEvent("lg_interface_request", logTrack & ";" & Request.Url.ToString & ";" & Request.QueryString.ToString & ";" & strJSON)

    Dim e As New tError()
    e.titulo = "Consultar Debin"

    Try

        ' reverso el string de atras para adelante para extraer el path sin los parametros incrustados
        Dim strSQL As String = "select * from verOperador_permisos where permiso_grupo = 'permisos_api_clientes' and "
        strSQL += " Permitir like reverse(substring(reverse('" & HttpContext.Current.Request.RawUrl & "'),charindex('/',reverse('" & HttpContext.Current.Request.RawUrl & "'))+1,len('" & HttpContext.Current.Request.RawUrl & "')))"

        Dim tienePermiso As Boolean = False

        Dim rsP As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
        If rsP.EOF = False Then
            tienePermiso = True
        End If
        nvDBUtiles.DBCloseRecordset(rsP)

        If tienePermiso = False Then
            e.numError = 403
            e.mensaje = "El usuario no tiene permisos necesarios para realizar esta acción"
            GoTo salir
        End If

        Dim id As String = nvUtiles.obtenerValor("id", "")
        e = servicios.nvQNET.consultarDebin(id.ToUpper)

        If e.numError > 0 Then
            e.numError = 400
            e.params = New trsParam()
            e.response()
            GoTo salir
        End If

        Dim json_response As New trsParam
        json_response("json") = e.params("json_response")


        e.params = New trsParam()
        e.params("response") = json_response("json")

    Catch ex As Exception
        e.numError = -99
        e.mensaje = "Ocurrio una excepción no controlada"
        e.debug_desc = ex.Message
        e.debug_src = "Consulta Debin::consultar"
    End Try



    'cerrar la sesion
salir:
    ' nvLog.addEvent("lg_interface_response", logTrack & ";" & Request.Url.ToString & ";" & Request.QueryString.ToString & ";" & strJSON)

    nvSession.Abandon()

    e.response()


%>