<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW.nvDBUtiles" %>
<%@ Import Namespace="nvFW.nvUtiles" %>

<%

    Dim campo_def As String = nvFW.nvUtiles.obtenerValor("campo_def", "")
    Dim er As New tError()
    Try
        Dim strSQL As String = "Select * from campos_def where campo_def = '" & campo_def & "'"
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
        If rs.EOF Then
            er = New tError()
            er.titulo = "Error al recuperar el campo_def"
            er.mensaje = "El campo_def '" & campo_def & "' no existe"
            er.response()
        End If

        Dim filtroXML As String = isNUll(rs.Fields("filtroXML").Value, "")
        If filtroXML <> "" Then
            er.params("filtroXML") = nvFW.nvXMLSQL.encXMLSQL(nvFW.nvConvertUtiles.JSScriptToObject(filtroXML))
        Else
            er.params("filtroXML") = filtroXML
        End If
        er.params("filtroWhere") = isNUll(rs.Fields("filtroWhere").Value, "")
        er.params("depende_de") = isNUll(rs.Fields("depende_de").Value, "")
        er.params("depende_de_campo") = isNUll(rs.Fields("depende_de_campo").Value, "")
        er.params("nro_campo_tipo") = rs.Fields("nro_campo_tipo").Value
        er.params("permite_codigo") = rs.Fields("permite_codigo").Value = True
        er.params("json") = rs.Fields("json").Value = True
        er.params("cacheControl") = isNUll(rs.Fields("cacheControl").Value, "")
        er.params("options") = isNUll(rs.Fields("options").Value, "")


        '**************************************************************
        'Extraer los valores de ID de DESC para pasarlos como resultado
        '**************************************************************
        Dim campo_codigo As String = ""
        Dim campo_desc As String = ""
        Dim strReg As String = "([^>\s,]*)\s+as\s+\[?id]?" '// busca ????? as id  O ????? as [id] "(\w*)\s+as\s+\[?id]?"
        Dim reg As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.IgnoreCase)
        If reg.IsMatch(filtroXML) Then
            campo_codigo = reg.Match(filtroXML).Groups(1).Value
        End If
        'Dim res As System.Text.RegularExpressions.MatchCollection = filtroXML. .toLowerCase().match(reg)

        strReg = "([^>\s,]*)\s+as\s+\[?campo]?" '// busca ????? as campo  O ????? as [campo]
        Dim reg2 As New System.Text.RegularExpressions.Regex(strReg, RegexOptions.IgnoreCase)
        If reg2.IsMatch(filtroXML) Then
            campo_desc = reg2.Match(filtroXML).Groups(1).Value
        End If
        er.params("campo_codigo") = campo_codigo
        er.params("campo_desc") = campo_desc
    Catch ex As Exception
        er.parse_error_script(ex)
        er.titulo = "Error al recuperar el campo_def"
    End Try

    er.response()

%>
