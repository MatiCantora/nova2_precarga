<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" enableSessionState="ReadOnly"  %>
<%@ Import namespace="nvFW" %>
<%
    Dim cacheID As String = nvUtiles.obtenerValor("cacheID", "")
    Dim cacheParams As String = nvUtiles.obtenerValor("params", "")

    Dim XML As System.Xml.XmlDocument = Nothing
    Dim Err As New tError

    Dim params1 As Dictionary(Of String, Object) = New Dictionary(Of String, Object)
    'Leer los parámetros
    Try
        XML = New System.Xml.XmlDocument
        XML.LoadXml(cacheParams)

        Dim oCacheParams As System.Xml.XmlNode = XML.SelectSingleNode("params")
        For Each node As System.Xml.XmlNode In oCacheParams.ChildNodes
            params1.Add(node.Name, node.InnerText)
        Next
    Catch ex As Exception
        Err.parse_error_script(ex)
        Err.titulo = "Error en la actualización de la cache"
        Err.comentario = "Error al procesar los parámetros."
        Err.debug_src = "reset_cache_expite::"
        Err.response()
    End Try

    Dim cache = nvCache.getCache(cacheID, params1)

    If cache Is Nothing Then
        Err.numError = 1500
        Err.titulo = "Error en la actualización de la cache"
        Err.comentario = "No se encuentra el valor solicitado"
        Err.debug_src = "reset_cache_expite::"
        Err.response()
    End If

    cache.actualiceExpire()
    Err.response()
%>