<%@  language="JScript" %>
<!--#include virtual="scripts/pvAccesoPaginaGlobal.asp"-->
<%
    Response.Expires = 0
    var numError = obtenerValor("numError", '')
    var mensaje = obtenerValor("mensaje", '')
 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Mostrar Error</title>
<!--#include virtual="meridiano/scripts/pvUtiles.asp"-->
<!--#include virtual="meridiano/scripts/pvCampo_def.asp"-->
<meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="../../meridiano/css/base.css" type="text/css" rel="stylesheet" />
    <link href="../../meridiano/css/btnSvr.css" type="text/css" rel="stylesheet" />
    <link href="../../meridiano/css/mnuSvr.css" type="text/css" rel="stylesheet" />
    <link href="../../meridiano/css/window_themes/default.css" rel="stylesheet" type="text/css" />
    <link href="../../meridiano/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../meridiano/script/mnuSvr.js" language="JavaScript"></script>
    <script type="text/javascript" src="../../meridiano/script/acciones.js"></script>
    <script type="text/javascript" src="../../meridiano/script/DMOffLine.js"></script>
    <script type="text/javascript" src="../../meridiano/script/btnSvr.js"></script>
    <script type="text/javascript" src="../../meridiano/script/rsXML.js"></script>
    <script type="text/javascript" src="../../meridiano/script/tXML.js"></script>
    <script type="text/javascript" src="../../meridiano/script/prototype.js"></script>
    <script type="text/javascript" src="../../meridiano/script/window.js"></script>
    <script type="text/javascript" src="../../meridiano/script/effects.js"></script>
    <script type="text/javascript" src="../../meridiano/script/window_effects.js"></script>
    <script type="text/javascript" src="../../meridiano/script/utiles.js"></script>
    <script type="text/javascript" src="../../meridiano/script/nvFW.js" ></script>
    <script type="text/javascript" src="../../meridiano/script/tCampo_def.js" ></script>
    <script type="text/javascript" src="../../meridiano/script/tSesion.js" ></script>
    <script type="text/javascript" src="../../meridiano/script/tError.js" ></script>
<script type="text/javascript" language="javascript">
 
</script>
</head>
<body>
<input type="hidden" name="numError" id="numError" value="<%=numError %>" />
<input type="hidden" name="mensaje" id="mensaje" value="<%=mensaje %>" />

<% if (numError == 10000) { %>
<table width="410" cellpadding="3" cellspacing="5">  <tr>       <td align="left" valign="middle" width="600" nowrap='nowrap' style="COLOR:00000; FONT: 15pt/18pt tahoma">No tiene autorizaci&oacute;n para ver esta p&aacute;gina</td>       </tr>       <tr>          <td width="700" colspan="2" style="COLOR:000000; FONT: 12pt/15pt tahoma" nowrap='nowrap'>No tiene permiso para ver este directorio o esta p&aacute;gina con las credenciales suministradas.</td>       </tr>    </table> <%}%> <%if (numError == 20000) { %><table width="410" cellpadding="3" cellspacing="5">  <tr>       <td align="left" valign="middle" width="600" nowrap='nowrap' style="COLOR:00000; FONT: 15pt/18pt tahoma">Entidad Bloqueada</td>       </tr>       <tr>          <td width="700" colspan="2" style="COLOR:000000; FONT: 12pt/15pt tahoma" nowrap='nowrap'><b><%= mensaje %></b></td>       </tr>    </table> <%}%>    </body>
</html>
