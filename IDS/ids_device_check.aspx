<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    Dim msg As String = obtenerValor("msg", "", nvConvertUtiles.DataTypes.varchar)

    Dim err As New tError
    err.params("msg") = msg

    err.response()
%>