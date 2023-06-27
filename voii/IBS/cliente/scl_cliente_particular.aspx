<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    
	Dim debug As Boolean = obtenerValor("debug", true)
    Dim ef As String = obtenerValor("ef", "JSON")

    Dim tsParamsRequest As trsParam = nvUtiles.RequestTotrsParam()
    Dim resError As tError = IBS.Cliente.scl_cliente_particular(tsParamsRequest, debug)

    resError.response()

%>