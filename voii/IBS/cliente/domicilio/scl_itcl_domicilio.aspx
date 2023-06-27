<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim debug As Boolean = obtenerValor("debug", False)
    Dim ef As String = obtenerValor("ef", "JSON")

    Dim tsParamsRequest As trsParam = nvUtiles.RequestTotrsParam()

    Stop
    Dim resError As tError = IBS.cliente.domicilio.scl_itcl_Domicilio(tsParamsRequest, debug)

    resError.response()


%>