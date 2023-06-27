<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    '--------------------------------------------------------------------------
    ' 
    '--------------------------------------------------------------------------
    Dim e As New terror()
    Try
        Dim idUsuario As integer = nvApp.operador.operador
        Dim accion As String = nvUtiles.obtenerValor("accion", "")
        Dim nro_dc_mov_def As String = nvUtiles.obtenerValor("nro_dc_mov_def", "")

        Dim internalcode As String = nvUtiles.obtenerValor("internalcode", "")

        Dim concepto As String = nvUtiles.obtenerValor("concepto", "")
        Dim moneda As String = nvUtiles.obtenerValor("moneda", "")
        Dim importe As String = nvUtiles.obtenerValor("importe", "")
        Dim mismoTitular As String = nvUtiles.obtenerValor("mismoTitular", "")
        Dim ipCliente As String = nvUtiles.obtenerValor("ipCliente", "")
        Dim tipoDispositivo As String = nvUtiles.obtenerValor("tipoDispositivo", "")
        Dim plataforma As String = nvUtiles.obtenerValor("plataforma", "")
        Dim imsi As String = nvUtiles.obtenerValor("imsi", "")
        Dim imei As String = nvUtiles.obtenerValor("imei", "")
        Dim precision As String = nvUtiles.obtenerValor("precision", "")

        Dim forzar As Boolean = If(nvUtiles.obtenerValor("forzar", "false") = "true", True, False)


        Dim lat As String = nvUtiles.obtenerValor("lat", "0")
        If lat = "" Then lat = "0"

        Dim lng As String = nvUtiles.obtenerValor("lng", "0")
        If lng = "" Then lng = "0"


        Select Case (accion)
            Case "D"

                If Not nvApp.operador.tienePermiso("permisos_debincredin", 2) Then
                    e.numError = 401
                    e.titulo = "Error de acceso"
                    e.mensaje = "El usuario no tiene permisos necesarios para realizar esta acción"
                    e.response()
                End If

                'Dim credito_cuit As String = nvUtiles.obtenerValor("credito_cuit", "")
                'Dim credito_cbu As String = nvUtiles.obtenerValor("credito_cbu", "")
                'Dim credito_nro_bcra As String = nvUtiles.obtenerValor("credito_nro_bcra", "")
                'Dim credito_nro_sucursal As String = nvUtiles.obtenerValor("credito_nro_sucursal", "")
                Dim tiempoExpiracion As String = nvUtiles.obtenerValor("tiempoExpiracion", "")

                Dim debito_cuit As String = nvUtiles.obtenerValor("debito_cuit", "")
                Dim debito_cbu As String = nvUtiles.obtenerValor("debito_cbu", "")
                Dim debito_alias As String = nvUtiles.obtenerValor("debito_alias", "")

                Dim idComprobante As String = nvUtiles.obtenerValor("idComprobante", "0")
                Dim descripcion As String = nvUtiles.obtenerValor("descripcion", "")


                e = servicios.nvQNET.debin(nro_dc_mov_def:=nro_dc_mov_def, debito_cuit:=debito_cuit, concepto:=concepto, moneda:=moneda, importe:=importe _
, debito_cbu:=debito_cbu, debito_alias:=debito_alias, descripcion:=descripcion, idUsuario:=idUsuario.ToString, idComprobante:=idComprobante _
, ipCliente:=ipCliente, tipoDispositivo:=tipoDispositivo, plataforma:=plataforma, imsi:=imsi _
, imei:=imei, lat:=lat, lng:=lng, precision:=precision, internalcode:=internalcode)

            Case "C"

                If Not nvApp.operador.tienePermiso("permisos_debincredin", 3) Then
                    e.numError = 401
                    e.titulo = "Error de acceso"
                    e.mensaje = "El usuario no tiene permisos necesarios para realizar esta acción"
                    e.response()
                End If


                Dim credito_cuit As String = nvUtiles.obtenerValor("credito_cuit", "")
                Dim credito_cbu As String = nvUtiles.obtenerValor("credito_cbu", "")
                Dim credito_nro_bcra As String = nvUtiles.obtenerValor("credito_nro_bcra", "")
                Dim credito_nro_sucursal As String = nvUtiles.obtenerValor("credito_nro_sucursal", "")
                Dim credito_titular As String = nvUtiles.obtenerValor("credito_titular", "")

                'Dim debito_cuit As String = nvUtiles.obtenerValor("debito_cuit", "")
                'Dim debito_cbu As String = nvUtiles.obtenerValor("debito_cbu", "")
                'Dim debito_nro_bcra As String = nvUtiles.obtenerValor("debito_nro_bcra", "")
                'Dim debito_nro_sucursal As String = nvUtiles.obtenerValor("debito_nro_sucursal", "")

                Dim idComprobante As String = nvUtiles.obtenerValor("idComprobante", "0")
                Dim ClienteId As String = nvUtiles.obtenerValor("ClienteId", "")

                e = servicios.nvQNET.credin(nro_dc_mov_def:=nro_dc_mov_def, credito_cuit:=credito_cuit, credito_cbu:=credito_cbu _
   , credito_nro_bcra:=credito_nro_bcra, credito_nro_sucursal:=credito_nro_sucursal, credito_titular:=credito_titular _
   , concepto:=concepto, moneda:=moneda, importe:=importe _
   , idUsuario:=idUsuario.ToString, idComprobante:=idComprobante _
   , ipCliente:=ipCliente, tipoDispositivo:=tipoDispositivo, plataforma:=plataforma, imsi:=imsi _
   , imei:=imei, lat:=lat, lng:=lng, precision:=precision, internalcode:=internalcode)


            Case "CD"

                If Not nvApp.operador.tienePermiso("permisos_debincredin", 1) Then
                    e.numError = 401
                    e.titulo = "Error de acceso"
                    e.mensaje = "El usuario no tiene permisos necesarios para realizar esta acción"
                    e.response()
                End If

                Dim id As String = nvUtiles.obtenerValor("id", "")
                Dim dc_id_estado As String = nvUtiles.obtenerValor("dc_id_estado", "")
                e = servicios.nvQNET.consultarDebin(id, dc_id_estado, internalcode:=internalcode, dc_mov_tipo:="D")

            Case "CC"

                If Not nvApp.operador.tienePermiso("permisos_debincredin", 1) Then
                    e.numError = 401
                    e.titulo = "Error de acceso"
                    e.mensaje = "El usuario no tiene permisos necesarios para realizar esta acción"
                    e.response()
                End If

                Dim id As String = nvUtiles.obtenerValor("id", "")
                Dim dc_id_estado As String = nvUtiles.obtenerValor("dc_id_estado", "")
                e = servicios.nvQNET.consultarDebin(id, dc_id_estado, internalcode:=internalcode, dc_mov_tipo:="C", forzar:=forzar)

            Case "CCBUALIAS"

                If Not nvApp.operador.tienePermiso("permisos_herramientas", 8) Then
                    e.numError = 401
                    e.titulo = "Error de acceso"
                    e.mensaje = "El usuario no tiene permisos necesarios para realizar esta acción"
                    e.response()
                End If

                Dim id As String = nvUtiles.obtenerValor("id", "")
                e = servicios.nvQNET.consultarCBUALIAS(id)

            Case Else
                e.numError = 1
                e.titulo = "Error de accion QNET"
                e.mensaje = "La acción es desconocido"

        End Select


    Catch ex As Exception
        e.numError = -99
        e.titulo = "Error de QNET"
        e.mensaje = "La acción es desconocido"
    End Try

    e.response()

%>