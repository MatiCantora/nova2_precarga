<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    '   Sólo funciones que "wrappean" a la llamada final
    '   Se hace para que pase las validaciones de la Page instanciada
    '--------------------------------------------------------------------------
    nvUtiles.definirValor("id_param", "IDS_IMAGE_SIZES")        ' Parametro objetivo, que como valor contiene un XML completo con valores particulares
    Server.Execute("~/FW/parametros/getXML_parametros.aspx")    ' getXML para parámetros; ahí se "parcean" los datos del XML de parametro
%>