<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageBase" %>
<%@ Import Namespace="nvFW" %>
<%
    Response.Expires = 0

    dim operador_get as string = nvUtiles.obtenerValor("operador_get", "")
    Dim titulo As String = ""
    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from verOperadores where operador = " + operador_get)
    If (rs.EOF)Then
        titulo = "Operador: "  + rs.Fields("strNombreCompleto").value
    end if
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Operador Hisotrial</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

   window.alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); }

   var version_todas = new Array();

   function window_onload() 
   {
       historial_mostrar()
       window_onresize()
   }

   function historial_mostrar() {

       if ($('operador_get').value != "") 
       {
           nvFW.exportarReporte({
               filtroXML: "<criterio><select vista='verOperadores_operador_tipo_log'><campos>*</campos><filtro><operador type='igual'>" + $('operador_get').value + "</operador></filtro><orden>oot_momento_log desc</orden></select></criterio>",
               path_xsl: 'report\\security\\verOperadores_operador_tipo_log\\HTML_oot_log.xsl',
               formTarget: 'iframe_historial',
               bloq_contenedor: $('iframe_historial'),
               cls_contenedor: 'iframe_historial',
               nvFW_mantener_origen: true,
               id_exp_origen: 0
           })
       }
   }

   function window_onresize()
     {
       try 
          {
           var dif = Prototype.Browser.IE ? 5 : 2
           var body_h = $$('body')[0].getHeight()
           var tb_datos_h = $('tb_datos').getHeight()

           $('iframe_historial').setStyle({ 'height': body_h - tb_datos_h - dif })
          }
       catch(e){}    
     }
</script>

</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; width:100%; overflow: hidden" >
    <input type="hidden" name="operador_get" id="operador_get" value="<%= operador_get %>"/>
    <table class="tb2" id="tb_datos">
       <tr class="tbLabel0" >
          <td style='text-align: left; width: 70%' id='td_titular'><%= titulo %></td>
       </tr>
    </table>
    <iframe name="iframe_historial" id="iframe_historial" style="width:100%; height:100%; overflow:auto" frameborder="0" src="enBlanco.htm"></iframe>
</body>
</html>
