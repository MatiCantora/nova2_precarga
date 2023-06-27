<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>

<% 

    Me.contents("consulta01") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select cacheControl='session' expire_minutes='2' vista='verCampos_def'><campos>*</campos><orden>campo_def</orden><filtro></filtro></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Campos def</title>
    <link href="../FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript" >

        function listaCampoDefs_resize()
          {
          var body = $$("BODY")[0]
          var tbBuscar = $("tbBuscar")
          var alto = body.clientHeight -  tbBuscar.clientHeight
          $("listaCampoDefs").setStyle({height: alto + "px"}) 
          }
         
        function window_onload()
          {
          listaCampoDefs_resize()
          }

        function window_onresize()
          {
          listaCampoDefs_resize()
          }

        function buscar_onlick()
         {
         var strWhere = ""
         if (campos_defs.value("campo_def") != '')
             {
             strWhere = "<campo_def type='like'>%" + campos_defs.value("campo_def")  + "%</campo_def>" 
             } 
         if (campos_defs.value("descripcion") != '')
             {
             strWhere += "<descripcion type='like'>%" + campos_defs.value("descripcion")  + "%</descripcion>" 
             }              
         if (campos_defs.value("nro_campo_tipo") != '')
             {
             strWhere += "<nro_campo_tipo type='igual'>" + campos_defs.value("nro_campo_tipo")  + "</nro_campo_tipo>" 
             }              
         
         if ($("depende_de").checked)
            strWhere += "<NOT><depende_de type='isnull'/></NOT>" 
         else
           strWhere += "<depende_de type='isnull'/>" 
         
         var alto = $("listaCampoDefs").clientHeight
         var filas = alto / 25

         var filtroXML = nvFW.pageContents.consulta01
         var filtroWhere = "<criterio><select PageSize='" + filas.toFixed(0) + "' AbsolutePage='1'><filtro>" + strWhere + "</filtro></select></criterio>"  
         nvFW.exportarReporte({
                           filtroXML: filtroXML
                         ,filtroWhere: filtroWhere
                         , path_xsl: "report\\campo_def_abm\\campo_def_listar.xsl"
                         //, xsl_name: "algo.xsl"
                         , salida_tipo: "adjunto"
                         , ContentType: "text/html" //default opcional
                         , formTarget: "listaCampoDefs"
                         , bloq_contenedor: $$("BODY")[0]
                         , cls_contenedor: "listaCampoDefs"
                         , nvFW_mantener_origen: true
            })
         
            
         }
    </script>


</head>
<body onload="window_onload()" onresize="window_onresize()" style="overflow:hidden">
    <table class="tb1" id="tbBuscar">
        <tr class="tbLabel">
            <td colspan="9">ABM Campos defs</td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 40px" >id:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("campo_def", enDB:=False, nro_campo_tipo:=104)  %></td>
            <td  class="Tit1">Descripción:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("descripcion", enDB:=False, nro_campo_tipo:=104)  %></td>
            <td  class="Tit1">Tipo:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_campo_tipo", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='campos_def_tipo'><campos> distinct nro_campo_tipo as id, campo_tipo as [campo] </campos><orden>[id]</orden><filtro></filtro></select></criterio>")  %></td>
            <td  class="Tit1">Dependiente:</td>
            <td><input name="depende_de" id="depende_de" type="checkbox" /></td>
            <td style="width: 100px"><input type="button" value="Buscar" onclick="buscar_onlick()" style="width:100%" /></td>
        </tr>
    </table>
    <iframe name="listaCampoDefs" id="listaCampoDefs" style="width: 100%" src="/admin/enBlanco.htm" frameborder="0"></iframe>


</body>
</html>        