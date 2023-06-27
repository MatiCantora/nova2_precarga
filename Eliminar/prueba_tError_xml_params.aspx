<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%
    'Stop
    'Try
    '    Response.End()
    'Catch ex As Exception
    '    Dim x As String = ex.ToString
    'End Try



    Dim err = New tError
    Dim bytes() As Byte = System.Text.Encoding.GetEncoding("iso-8859-1").GetBytes("Hola mundo")
    Dim oXML As New System.Xml.XmlDocument
    oXML.LoadXml("<criterio><elementA>algo</elementA></criterio>")
    Dim p As New trsParam()
    p("string") = "Esto es un string"
    p("datetime") = Now()
    Dim strJson As New nvFW.nvJSON_String("{""campo"":  ""valor""}")

    err.params("int") = 124
    err.params("decimal") = 124.45
    err.params("string") = """'<>/\"
    err.params("bytes") = bytes
    err.params("oXML") = oXML
    err.params("boolean") = True
    err.params("datetime") = Now()
    err.params("trsParam") = p
    err.params("nvJSON_String") = strJson
    err.params("int") = 124
    err.params("int") = 124
    Stop
    Try
        err.response()
    Catch ex As Exception
        Dim err2 As New tError()
        err2.parse_error_script(ex)
    End Try

    Dim a As Object = Nothing
    Dim e As String = a.ToString()



%>
