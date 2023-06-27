<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>


<%
    Me.contents("filtroXMLmiCampo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>estado as [id], descripcion as campo</campos><filtro></filtro></select></criterio>")

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
  function alert_getFiltroWhere()
     {
     debugger
     var strF = campos_defs.filtroWhere()
     alert(strF)
     }

    </script>

</head>
<body onload="window_onload()"  style="width: 100%; height: 100%; overflow: auto" >
    <table class="tb1 ">
        
        <tr class="tbLabel0">
            <td>
                Ejemplos de campo_def
            </td>
        </tr>
    </table>
    <table class="tb1 highlightTROver">
        <tr>
            <td>
                cod_servidor1
            </td>
            <td> <script type="text/javascript">
                     campos_defs.add('cod_servidor1', {filtroXML:"<criterio><select vista='nv_servidores'><campos>distinct cod_servidor as id, cod_servidor as [campo], cod_servidor </campos><orden>[campo]</orden></select></criterio>", 
                                                       filtroWhere: "<" + "%campo_def%>%campo_value%</%campo_def%><cod_servidor>%rs!cod_servidor%</cod_servidor><cod_servidor>%rs!id%</cod_servidor>",
                                                       nro_campo_tipo : 1, enDB: false, json: true});
                </script>
                </td>
        </tr>
        <tr>
            <td>
                id_param
            </td>
            <td style="width: 50%">
                <script type="text/javascript">
                    campos_defs.add('id_param') //,{permite_codigo:true, onchargefinish:function(campo_def){}}
                </script>

            </td>
        </tr>
        
        
        <tr>
            <td>
                nro_login2
            </td>
            <td style="">
                <%= nvFW.nvCampo_def.get_html_input("nro_login2")%>
            </td>
        </tr>
        <tr>
            <td>
                campos_def
            </td>
            <td style="">
                <%
                    Dim miCampo_def As New nvFW.tnvCampo_def
                    miCampo_def.campo_def = "miCampo_def"
                    miCampo_def.nro_campo_tipo = 3
                    miCampo_def.filtroXML = "<criterio><select vista='campos_def'><campos> distinct campo_def as id, descripcion as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>"
                    Response.Write(miCampo_def.get_html_input())
                %>
            </td>
        </tr>
        
      
    </table>

    <input type="button"  onclick="alert_getFiltroWhere()" value="getFiltroWhere"/>

    <br />
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="/admin/enBlanco.htm"></iframe>
</body>
</html>
