<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' insertar log
    '--------------------------------------------------------------------------
    Dim e As New terror()
    Try

        Dim nro_dc_mov As String = nvUtiles.obtenerValor("nro_dc_mov", "")
        Dim credito_cuit As String = nvUtiles.obtenerValor("credito_cuit", "")
        Dim credito_cbu As String = nvUtiles.obtenerValor("credito_cbu", "")
        Dim credito_nro_bcra As String = nvUtiles.obtenerValor("credito_nro_bcra", "")
        Dim credito_nro_sucursal As String = nvUtiles.obtenerValor("credito_nro_sucursal", "")
        Dim debito_cuit As String = nvUtiles.obtenerValor("debito_cuit", "")
        Dim debito_cbu As String = nvUtiles.obtenerValor("debito_cbu", "")
        Dim concepto As String = nvUtiles.obtenerValor("concepto", "")
        Dim idUsuario As String = nvUtiles.obtenerValor("idUsuario", "")
        Dim idComprobante As String = nvUtiles.obtenerValor("idComprobante", "")
        Dim moneda As String = nvUtiles.obtenerValor("moneda", "")
        Dim importe As String = nvUtiles.obtenerValor("importe", "")
        Dim tiempoExpiracion As String = nvUtiles.obtenerValor("tiempoExpiracion", "")
        Dim descripcion As String = nvUtiles.obtenerValor("descripcion", "")
        Dim mismoTitular As String = nvUtiles.obtenerValor("mismoTitular", "")
        Dim ipCliente As String = nvUtiles.obtenerValor("ipCliente", "")
        Dim tipoDispositivo As String = nvUtiles.obtenerValor("tipoDispositivo", "")
        Dim plataforma As String = nvUtiles.obtenerValor("plataforma", "")
        Dim imsi As String = nvUtiles.obtenerValor("imsi", "")
        Dim imei As String = nvUtiles.obtenerValor("imei", "")
        Dim lat As String = nvUtiles.obtenerValor("lat", "")
        Dim lng As String = nvUtiles.obtenerValor("lng", "")
        Dim precision As String = nvUtiles.obtenerValor("precision", "")

        e = servicios.nvQNET.debin(credito_cuit, credito_cbu, credito_nro_bcra, credito_nro_sucursal, debito_cuit, debito_cbu, concepto, idUsuario, idComprobante _
                                 , moneda, importe, tiempoExpiracion, descripcion, mismoTitular, ipCliente, tipoDispositivo, plataforma, imsi, imei, lat, lng, precision)

    Catch ex As Exception
        e.numError = 1001
        e.titulo = "Error de log"
        e.mensaje = "La acción es desconocido"
        e.debug_src = "log"
    End Try

    e.response()

%>