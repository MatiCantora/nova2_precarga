<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>


<%
    Me.contents("filtroAPINodes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='API_nodes'><campos> proxy_url as [id], node_name + '::' as campo</campos><filtro><proxy_url type='distinto'>''</proxy_url></filtro></select></criterio>")
 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
        

    <% = Me.getHeadInit()%>

    <style type="text/css">
        input
        {
            width: 100px;
        }
    </style>

    <script type="text/javascript" language="javascript">
         
        function window_onload()
          {
         
           
            
//          var el = $("input_txt")
//          el.addEventListener('change', handler, false)
//          //el.addEventListener('domattrmodified', handler, false)
//          //el.onchange = handler

//          el = $("input_hidden")
//          el.addEventListener('change', handler, false)
//          //el.addEventListener('domattrmodified', handler, false)
//          //el.onchange = handler

          }

        function APINode_ejecutar()
          {
          var url = window.location.origin + "/" + campos_defs.get_desc("APINode").split("::")[0]
          $("txtURL").value = url 
          $("iframe1").src = url
          }

        function APINode_ejecutar2()
          {
          var url = window.location.origin + "/" + campos_defs.get_desc("APINode").split("::")[0] + "/?algo=12&algo2=34" 
          $("txtURL").value = url 
          $("iframe1").src = url
          }

         function APINode_ejecutar_path()
          {
          var url = window.location.origin + "/API/COELSA/Servicio123.aspx" 
          $("txtURL").value = url 
          $("iframe1").src = url
          }

         function APINode_ejecutar_https()
          {
          var url = window.location.origin + "/API/NOVATEST/nvLogin.aspx" 
          $("txtURL").value = url 
          $("iframe1").src = url
          }
        
 
    </script>

</head>
<body onload="window_onload()"  style="width: 100%; height: 100%; overflow: auto" >
    <table class="tb1 ">
        
        <tr class="tbLabel0">
            <td>
                Ejemplos de Nova Proxy
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td>API Node</td>
            <td>
                 <script type="text/javascript">
                    campos_defs.add('APINode',{ nro_campo_tipo: 1,enDB: false,filtroXML: nvFW.pageContents.filtroAPINodes})
                    campos_defs.set_first('APINode')
                </script>
            </td>
        </tr>
    </table>
   

    <input type="button"  onclick="APINode_ejecutar()" value="Ejecutar"/>
    <input type="button"  style="width:200px" onclick="APINode_ejecutar2()" value="Ejecutar params"/>
    <input type="button"  style="width:250px" onclick="APINode_ejecutar_path()" value="Ejecutar otro path"/>
    <input type="button"  style="width:300px" onclick="APINode_ejecutar_https()" value="Ejecutar HTTPS"/>

    <br />
    <input type="text" readonly="readonly" id="txtURL" style="width:100%" />
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="/admin/enBlanco.htm"></iframe>
</body>
</html>
