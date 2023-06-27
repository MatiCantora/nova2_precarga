<%@ Page Language="C#" AutoEventWireup="false"   EnableSessionState="True" %>
<%
    string res = "Error No se pudo cargar la conexion.";
    ADODB.Connection cn = new ADODB.Connection();
    try
    {
        cn.Open("Provider=SQLNCLI11;Data Source=madrid1.redmutual.com.ar2;Initial Catalog=nvadmin;Integrated Security=SSPI;");
        res = "Conexión OK";
    }
    catch (Exception e)
    {

    }


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>

    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>

    <style type="text/css">
        input
        {
            width: 100px;
        }
    </style>

   
  
   
</head>
<body  style="width: 100%; height: 100%; overflow: auto" onload="return window_onload()"    onresize="return window_onresize()">
    <form name="pruebas" action="" method="GET" style="width: 100%">
    <table class="tb1">
         <tr class="tbLabel0">
            <td>
               <span id="spnTitulo" style="font-weight:bold;"><%= res%></span>
            </td>
        </tr>
        <tr class="tbLabel0">
            <td>
                Ejemplos de Exportar Reporte
            </td>
        </tr>
</table>
</body>
7</html>
