<%@ Page Language="vb" AutoEventWireup="false"  %>
<%@ Import namespace="nvFW" %>
<%

    Dim err As tError = New tError()
    err.salida_tipo = "estado"
    err.numError = 0
    err.titulo = ""
    err.mensaje = ""

    err.response()

%>

