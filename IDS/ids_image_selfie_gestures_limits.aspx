<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    '   Aqu� s�lo se "wrappea" la llamada hacia getXML_parametros
    '   Se hace para que pase las validaciones de la Page instanciada
    '--------------------------------------------------------------------------
    nvUtiles.definirValor("id_param", "IDS_SELFIE_GESTURES_LIMITS") ' Parametro objetivo, que como valor (contenido) es un string XML completo con valores particulares
    Server.Execute("~/FW/parametros/getXML_parametros.aspx")        ' getXML para par�metros; ah� se "parcean" los datos del XML de parametro
%>