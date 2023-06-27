<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    'Stop
    Dim err As New tError
    Dim filtroXML As String = nvXMLSQL.encXMLSQL("<criterio><select vista='verReferencia'><campos>distinct nro_ref as id, referencia as [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
    err.params("filtroXML") = filtroXML
    err.response()
%>