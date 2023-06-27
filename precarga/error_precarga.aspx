<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%
Dim desc_error As String = nvFW.nvUtiles.obtenerValor("desc_error", "")
%>
<html>
<head>
 <title>Error Precarga</title>
 <meta http-equiv="X-UA-Compatible" content="IE=edge" />
 <link href="../errores_personalizados/css/base.css" type="text/css" rel="stylesheet">
 
<script language="javascript" type="text/javascript">
// <!CDATA[

function window_onload() 
{ 
if (window.parent != window)
  redir.submit()
}

// ]]>
</script>
</head>
<body onload="return window_onload()">
<form name="redir" action="../../errores_personalizados/precarga.html" target="_top" style="display: none" method="get"></form>
<br/> <br/>
    <table height="140px" width="100%">
       <tr>
           <td nowrap='nowrap' style="text-align:center; COLOR:#000000; FONT: 18pt/18pt verdana">
               <%=desc_error %>
           </td>
       </tr>
    </table>
    <br/>
    <table width="100%" height="150px">
      <tr>
       <td style="text-align:center">
          <a>
              <img src='../../errores_personalizados/image/rm_logo_280.jpg'  alt =""/>
          </a>
       </td>
      </tr>
    </table>
    <br/> <br/>
    <table width="100%" style="text-align:center; color:black; font:12pt/12pt tahoma">
         <tr>
              <td style="text-align:center; color:black; font:12pt/12pt tahoma">&nbsp;P&oacute;ngase en contacto con el administrador del sistema.</td>
         </tr>
         <tr >
              <td>&nbsp;Email:
                   <a href="http://webmail.redmutual.com.ar/" style="color:blue; font:12pt/12pt tahoma" title="Email: Departamento de Sistemas">sistemas@redmutual.com.ar</a>
              </td>
         </tr>
    </table>
</body>
</html>
