<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim debug As Boolean = obtenerValor("debug", False)
    definirValor("ef", "JSON")

    Dim tsParamsRequest As trsParam = nvUtiles.RequestTotrsParam()


    Dim resError As tError = IBS.cliente.domicilio.scl_itcl_domicilio(tsParamsRequest, debug, True)

    resError.response()


%>