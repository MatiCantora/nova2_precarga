<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim tmp_response As tError  ' Lo tenemos por si es necesario salir anticipadamente

    ' 1) Obtener ID del parámetro con valor complejo
    Dim id_param As String = nvUtiles.obtenerValor("id_param", "")

    ' 2) Obtner el valor, aquí siempre como una estructura XML del tipo "<parametros><parametro> <...> </parametro></parametros>"
    Dim xml_parametros = nvUtiles.getParametroValor(id_param, "")

    If xml_parametros = String.Empty Then
        tmp_response = New tError
        tmp_response.numError = -99
        tmp_response.titulo = "Error en Parametros"
        tmp_response.mensaje = "El valor del parámetro no esta seteado o está vacío."
        tmp_response.debug_src = "getXML_parametros.aspx"
        tmp_response.response()
    End If

    ' 3) Levanatar los datos string a un XML
    Dim oXML As New System.Xml.XmlDocument
    oXML.LoadXml(xml_parametros)

    ' 4) Leemos todos los nodos
    Dim nodos As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXML, "parametros/parametro")

    If nodos.Count = 0 Then
        tmp_response = New tError
        tmp_response.numError = -98
        tmp_response.titulo = "Error en Parametros"
        tmp_response.mensaje = "No se encontraron nodos para el parámetro suministrado."
        tmp_response.debug_src = "getXML_parametros.aspx"
        tmp_response.response()
    End If

    ' 5) Verificar si la tabla temporal existe => eliminarla | La tabla temporal es global "##"
    Dim tmp_table_name As String = "##" & nvConvertUtiles.RamdomString(5)
    Dim strSQL As String = String.Format("IF OBJECT_ID('tempdb..{0}') IS NOT NULL DROP TABLE {0};", tmp_table_name)

    nvDBUtiles.DBExecute(strSQL)

    ' 6) Armar dinamicamente los campos para la inserción de datos
    Dim nodo As System.Xml.XmlNode = nodos(0)   ' Tomamos el primero, ya que aqui al menos 1 nodos tenemos
    Dim campos As New List(Of String)   ' Me guardo los campos para las demas inserciones
    Dim tag_name As String = ""
    Dim tag_value As String = ""

    ' 7) Armamos el Select de Inserción (SELECT INTO ...)
    strSQL = "SELECT "

    For Each parametro As System.Xml.XmlNode In nodo.ChildNodes
        tag_name = parametro.Name
        tag_value = parametro.InnerText

        campos.Add("[" & tag_name & "]")
        strSQL &= String.Format("CAST('{0}' AS VARCHAR(50)) AS [{1}], ", tag_value, tag_name)
    Next

    ' 7.1) Eliminar la ultima coma y espacio
    strSQL = strSQL.TrimEnd(",", " ")
    strSQL &= String.Format(" INTO {0};", tmp_table_name)

    ' 7.2) Armar los INSERTs para los parametros extras, si existen
    If nodos.Count > 1 Then
        strSQL &= String.Format("INSERT INTO {0} ({1}) VALUES ", tmp_table_name, String.Join(",", campos))

        For i = 1 To nodos.Count - 1
            strSQL &= "("

            ' Recorrer todos los parametros del nodo actual
            For Each parametro As System.Xml.XmlNode In nodos(i)
                strSQL &= String.Format("'{0}', ", parametro.InnerText)
            Next

            strSQL = strSQL.TrimEnd(",", " ")   ' Eliminar última coma y espacio
            strSQL &= "), "                     ' Cerrar el strSQL del INSERT actual
        Next

        strSQL = strSQL.TrimEnd(",", " ")   ' Eliminar última coma y espacio
        strSQL &= ";"
    End If

    nvDBUtiles.DBExecute(strSQL)

    ' 8) Armamos un FiltroXML; siempre encriptado
    Dim filtroXML As String = nvXMLSQL.encXMLSQL("<criterio><select vista='" & tmp_table_name & "'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

    ' 9) Pasar al body stream el nuevo valor de filtroXML
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' 10) Mandamos el flujo de la Request al getXML.aspx del FW
    Server.Execute("~/FW/getXML.aspx")
%>