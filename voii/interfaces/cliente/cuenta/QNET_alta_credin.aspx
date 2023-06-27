<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIIClienteInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar moviminetos psp
    '--------------------------------------------------------------------------


    Dim io As System.IO.Stream = HttpContext.Current.Request.InputStream
    io.Position = 0
    Dim buffer(io.Length - 1) As Byte
    io.Read(buffer, 0, buffer.Length)
    io.Position = 0


    Dim strJSON As String = nvFW.nvConvertUtiles.currentEncoding.GetString(buffer)

    'Dim logTrack As String = nvLog.getNewLogTrack()
    'nvLog.addEvent("lg_interface_request", logTrack & ";" & Request.Url.ToString & ";" & Request.QueryString.ToString & ";" & strJSON)

    Dim e As New tError()
    e.titulo = "Alta de Credin"

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


    Try


        Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
        Dim obj As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(strJSON)
        Dim trsRequest As New trsParam(obj)

        Dim ClienteId As String = ""
        Dim internalcode As String = ""

        Dim concepto As String = ""
        Dim idUsuario As String = ""
        Dim idComprobante As String = ""
        Dim moneda As String = ""
        Dim importe As String = ""
        Dim mismo_titular As String = ""

        Dim ipCliente As String = ""
        Dim tipoDispositivo As String = ""
        Dim plataforma As String = ""
        Dim imsi As String = ""
        Dim imei As String = ""
        Dim precision As String = ""
        Dim lat As String = ""
        Dim lng As String = ""

        Dim credito_cuit As String = ""
        Dim credito_cbu As String = ""
        Dim credito_nro_bcra As String = ""
        Dim credito_nro_sucursal As String = ""
        Dim credito_titular As String = ""

        Dim debito_cuit As String = ""
        Dim debito_cbu As String = ""
        Dim debito_nro_bcra As String = ""
        Dim debito_nro_sucursal As String = ""
        Dim debito_titular As String = ""

        Try

            ClienteId = trsRequest("ClienteId")
            internalcode = trsRequest("internalcode")

            concepto = trsRequest("concepto")
            idUsuario = trsRequest("idUsuario")
            idComprobante = trsRequest("idComprobante")
            moneda = trsRequest("moneda")
            importe = trsRequest("importe")
            mismo_titular = trsRequest("mismo_titular")

            ipCliente = trsRequest("datosGenerador")("ipCliente")
            tipoDispositivo = trsRequest("datosGenerador")("tipoDispositivo")
            plataforma = trsRequest("datosGenerador")("plataforma")
            imsi = trsRequest("datosGenerador")("imsi")
            imei = trsRequest("datosGenerador")("imei")
            precision = trsRequest("datosGenerador")("precision")
            lat = trsRequest("datosGenerador")("lat")
            lng = trsRequest("datosGenerador")("lng")

            credito_cuit = trsRequest("credito")("cuit")
            credito_cbu = trsRequest("credito")("cbu")
            credito_nro_bcra = trsRequest("credito")("banco")
            credito_nro_sucursal = trsRequest("credito")("sucursal")
            credito_titular = trsRequest("credito")("titular")

            debito_cuit = trsRequest("debito")("cuit")
            debito_cbu = trsRequest("debito")("cbu")
            debito_nro_bcra = trsRequest("debito")("banco")
            debito_nro_sucursal = trsRequest("debito")("sucursal")
            debito_titular = trsRequest("debito")("titular")

        Catch ex As Exception
            e.numError = -98
            e.mensaje = "Entrada de datos mal formada."
            e.parse_error_script(ex)
            GoTo salir
        End Try


        ' checkear si tiene permiso de acceso a el API
        Dim clitipdoc As String = nvApp.operador.datos("cli_tipdoc").value
        Dim clinrodoc As String = nvApp.operador.datos("cli_nrodoc").value
        Dim clinCBU As String = ""
        strSQL = "select cbu from API_clientes_cuentas_cfg where nrodoc = " & clinrodoc & " and tipdoc = " & clitipdoc & " and cbu = '" & debito_cbu & "' and vigente = 1 "

        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
        If rs.EOF = False Then
            clinCBU = rs.Fields("cbu").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)

        If clinCBU = "" Then
            e.numError = 500
            e.mensaje = "El usuario no tiene asociada la CBU (" & debito_cbu & ") para realizar credines."
            GoTo salir
        End If


        e = servicios.nvQNET.credin(_credito_cuit:=credito_cuit, _credito_cbu:=credito_cbu _
                    , _credito_nro_bcra:=credito_nro_bcra, _credito_nro_sucursal:=credito_nro_sucursal, _credito_titular:=credito_titular _
                    , _debito_cuit:=debito_cuit, _debito_cbu:=debito_cbu, _debito_nro_bcra:=debito_nro_bcra _
                    , _debito_nro_sucursal:=debito_nro_sucursal, _debito_titular:=debito_titular _
                    , _concepto:=concepto, _moneda:=moneda, _importe:=importe _
                    , _idUsuario:=idUsuario, _idComprobante:=idComprobante _
                    , _ipCliente:=ipCliente, _tipoDispositivo:=tipoDispositivo, _plataforma:=plataforma, _imsi:=imsi _
                    , _imei:=imei, _lat:=lat, _lng:=lng, _precision:=precision, _internalcode:=internalcode)


        Dim json_response As New trsParam
        json_response("json") = e.params("json_response")

        ' limpio y retorno solo lo necesarios
        e.params = New trsParam()
        e.params("response") = json_response("json")

    Catch ex As Exception
        e.numError = -99
        e.mensaje = "Ocurrió una excepción no controlada"
        e.debug_desc = ex.Message
        e.debug_src = "Alta de Credin::alta"
    End Try



    'cerrar la sesion
salir:

    'nvLog.addEvent("lg_interface_response", logTrack & ";" & Request.Url.ToString & ";" & Request.QueryString.ToString & ";" & strJSON)

    nvSession.Abandon()
    e.response()


%>