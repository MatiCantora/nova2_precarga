<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIIClienteInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar moviminetos por cuenta psp
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
    e.titulo = "Consulta por Cuenta"

    Dim filtroWhere As String = ""
    Dim filtroXML As String = ""

    Try

        ' reverso el string de atras para adelante para extraer el path sin los parametros incrustados
        Dim strSQL As String = "select * from verOperador_permisos where permiso_grupo = 'permisos_api_clientes' and Permitir like '" & HttpContext.Current.Request.RawUrl & "' "        
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


        Dim cbu As String = nvUtiles.obtenerValor("cbu", "")
        Dim fe_desde As String = nvUtiles.obtenerValor("fe_desde", "")
        Dim fe_hasta As String = nvUtiles.obtenerValor("fe_hasta", "")
        Dim fe_hasta_tiene_time As Boolean = False

        Try

            If cbu = "" Then
                e.numError = 403
                e.mensaje = "El CBU cliente no tiene defindo un valor"
                GoTo salir
            End If

            If fe_desde = "" Or fe_hasta = "" Then
                e.numError = 403
                e.mensaje = "La fecha de inicio o la fecha de fin no se encuentran definidas"
                GoTo salir
            End If

            If fe_desde.Length <= 10 Then
                fe_desde = fe_desde & " " & "00:00:00"
            End If

            If fe_hasta.Length <= 10 Then
                fe_hasta = fe_hasta & " " & "00:00:00"
            End If

            Dim fe_desde_date As DateTime = DateTime.ParseExact(fe_desde, "MM/dd/yyyy HH:mm:ss", System.Globalization.CultureInfo.InvariantCulture)
            Dim fe_hasta_date As DateTime = DateTime.ParseExact(fe_hasta, "MM/dd/yyyy HH:mm:ss", System.Globalization.CultureInfo.InvariantCulture)

            ' validar rango de fecha
            If fe_desde_date > fe_hasta_date Then
                e.numError = 403
                e.mensaje = "La fecha de inicio es mayo a la fecha final"
                GoTo salir
            End If

            If fe_desde_date.Hour > 0 Or fe_desde_date.Minute > 0 Or fe_desde_date.Second > 0 Then
                fe_hasta_tiene_time = True
            End If

        Catch ex As Exception
            e.numError = 403
            e.mensaje = "La fecha de inicio o final están mal formateada"
            GoTo salir
        End Try

        Dim cuecod As Integer = 0
        Dim sistcod As Integer = 0

        Dim clitipdoc As String = nvApp.operador.datos("cli_tipdoc").value
        Dim clinrodoc As String = nvApp.operador.datos("cli_nrodoc").value
        strSQL = "select cuecod,sistcod from API_clientes_cuentas_cfg where nrodoc = " & clinrodoc & "  and tipdoc = " & clitipdoc & " and cbu = '" & cbu & "' and vigente = 1 "

        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
        If rs.EOF = False Then
            sistcod = rs.Fields("sistcod").Value
            cuecod = rs.Fields("cuecod").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)

        If cuecod = 0 And sistcod = 0 Then
            e.numError = 400
            e.mensaje = "El cliente no tiene asociada el CBU " & cbu & ", para realizar esta acción."
            e.response()
            GoTo salir
        End If


        Dim strFiltro As String = "<criterio><select vista='VOII_movimientos' cn='BD_IBS_ANEXA'><campos>fecreal as fecha, cuecod as [nro_cuenta], accdesc as [desc],descbreve as [cod_trn],descdet as [trn], dbo.fn_eliminar_ASCIICONTROL(info_adic) as [informacion_adicional], mondesc as [moneda], accimp as importe</campos>"
        strFiltro += "<filtro><clitipdoc type='igual'>" & clitipdoc & "</clitipdoc><clinrodoc type='igual'>" & clinrodoc & "</clinrodoc>"

        If cuecod > 0 And sistcod > 0 Then
            strFiltro += "<cuecod type='igual'>" & cuecod & "</cuecod>"
            strFiltro += "<sistcod type='igual'>" & sistcod & "</sistcod>"
        End If

        If fe_desde <> "" And fe_hasta <> "" Then
            strFiltro += "<fecreal type='mas'>'" & fe_desde & "'</fecreal>"
            If fe_hasta_tiene_time = True Then
                strFiltro += "<fecreal type='menor'>dateadd(ss,1,convert(datetime,'" & fe_hasta & "',101))</fecreal>"
            Else
                strFiltro += "<fecreal type='menor'>dateadd(dd,1,convert(datetime,'" & fe_hasta & "',101))</fecreal>"
            End If
        End If
        strFiltro += "</filtro></select></criterio>"

        filtroXML = nvXMLSQL.encXMLSQL(strFiltro)

    Catch ex As Exception
        e.numError = -99
        e.mensaje = "Ocurrió una excepción no controlada"
        e.debug_desc = ex.Message
        e.debug_src = "Consultar Movs::consultar"
    End Try

    ' Cargar datos adicionales al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroWhere", nvUtiles.obtenerValor("filtroWhere", ""))
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")

salir:
    nvSession.Abandon()
    e.response()



%>