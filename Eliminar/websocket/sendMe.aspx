<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW"  enableSessionState="ReadOnly"%>
<%
    Dim msg As String = obtenerValor("msg", "", nvConvertUtiles.DataTypes.varchar)
    Dim er As New tError()
    nvWebSocket.send(Session.SessionID, msg)
    er.response()
%>