<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim debug As Boolean = obtenerValor("debug", False)
    Dim ef As String = obtenerValor("ef", "JSON")

    Dim tsParamsRequest As trsParam = nvUtiles.RequestTotrsParam()


    Dim resError As tError = IBS.cliente.telefono.scl_utcl_telefono(tsParamsRequest, debug)

    resError.response()


%>