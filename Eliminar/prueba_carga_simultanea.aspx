<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
     <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit()%>
    <script type="text/javascript">

            var filtroXML =  "<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>" //"<criterio><select vista='estado'><campos>*</campos><filtro><estado>%pestado%</estado></filtro></select></criterio>"
            var filtroWhere = "<criterio><select><filtro><estado>'T'</estado></filtro></select></criterio>"
            filtroWhere = "<criterio><select><orden>nro_permiso</orden></select></criterio>"
            //VistaGuardada = "vg1"
            var params = "<criterio><params pestado=\"'A'\" /></criterio>"

        function window_onload()
          {
          for (var i=0; i<=10; i++)
              { 
              nvFW.exportarReporte({
                         filtroXML: filtroXML
                         , filtroWhere: filtroWhere
                         //,params: params
                         , path_xsl: "report\\HTML_base_fixedHead.xsl"
                         //, xsl_name: "algo.xsl"
                         , salida_tipo: "adjunto" // "estado"
                         , ContentType: "text/html" //default opcional
                         , cls_contenedor: "iframeB" + i
                         , cls_contenedor_msg : "Otra cosa"
                         ,formTarget: "iframeB" + i
                         //,bloq_contenedor: '$$("BODY")[0]'
                         //,bloq_msg: "Hola"
                         //,bloq_id: "sasasa1"
                         //,parametros:"<parametros><columnHeaders><![CDATA[dasdsdsadasdsa]]></columnHeaders></parametros>"
                         , parametros: "<parametros><columnHeaders><table><tr><td></td><td></td></tr></table></columnHeaders></parametros>"
                         })
              }
          }
    </script>
</head>
<body onload="window_onload()">
<%
    For i = 0 To 10
        Response.Write("<iframe id='iframeB" & i & "' name='iframeB" & i & "' style='width: 300px; height: 200px; border: solid red 1px' ></iframe>")
    Next

    %>
</body>
</html>
