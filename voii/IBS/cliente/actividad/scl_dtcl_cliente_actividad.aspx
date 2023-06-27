<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim debug As Boolean = obtenerValor("debug", False)
    'definirValor("ef", "JSON")
    Dim ef As String = obtenerValor("ef", "JSON")

    Dim tsParamsRequest As trsParam = nvUtiles.RequestTotrsParam()
    Stop
    Dim resError As tError = IBS.cliente.actividad.scl_dtcl_cliente_actividad(tsParamsRequest, debug)

    resError.response()


%>