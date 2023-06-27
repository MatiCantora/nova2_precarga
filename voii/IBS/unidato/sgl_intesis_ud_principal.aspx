<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim debug As Boolean = obtenerValor("debug", False)
    definirValor("ef", "JSON")

    Dim tsParamsRequest As trsParam = nvUtiles.RequestTotrsParam()
    Dim resError As tError = IBS.Unidato.sgl_intesis_ud_principal(tsParamsRequest, debug)

    resError.response()


%>