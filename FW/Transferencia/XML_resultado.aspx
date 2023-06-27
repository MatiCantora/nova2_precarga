<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Response.Expires = 0
    Response.ContentType = "text/xml"
    Response.Charset = "ISO-8859-1"

    Dim id_transf_log = nvUtiles.obtenerValor("XML_id_transf_log", "")
    Dim xmlres As String = ""

    If id_transf_log > 0 Then

        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select isNULL(obsbin,0) as obsbin from transf_log_cab where id_transf_log =" & id_transf_log)
        xmlres += nvFW.nvConvertUtiles.BytesToString(rs.Fields("obsbin").Value)

    End If

    Response.Write(xmlres)

%>