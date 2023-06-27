<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim nro_tarea = nvFW.nvUtiles.obtenerValor("nro_tarea", "")
    Dim fe_desde = nvFW.nvUtiles.obtenerValor("fe_desde", "")
    Dim fe_hasta = nvFW.nvUtiles.obtenerValor("fe_hasta", "")

    Me.contents("filtroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.operador_get_tareas' CommantTimeOut='1500'><parametros><fe_desde DataType='datetime'>%fe_desde%</fe_desde><fe_hasta DataType='datetime'>%fe_hasta%</fe_hasta><strWhere>%strWhere%</strWhere><strOrder>%strOrder%</strOrder></parametros></procedure></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar Tarea</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Aceptar";
        vButtonItems[0]["etiqueta"] = "Aceptar";
        vButtonItems[0]["imagen"] = "";
        vButtonItems[0]["onclick"] = "return Aceptar()";
  
        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "Primer";
        vButtonItems[1]["etiqueta"] = "Ir a Tarea Origen";
        vButtonItems[1]["imagen"] = "";
        vButtonItems[1]["onclick"] = "return Primer()";
  
        vButtonItems[2] = {};
        vButtonItems[2]["nombre"] = "Cancelar";
        vButtonItems[2]["etiqueta"] = "Cancelar";
        vButtonItems[2]["imagen"] = "";
        vButtonItems[2]["onclick"] = "return Cancelar()";
  
        var vListButton = new tListButton(vButtonItems,'vListButton');

        function window_onload() {
            vListButton.MostrarListButton()
            window_onresize()
            Buscar()
        }
        
        var fe_desde = '<%= fe_desde%>',
            fe_hasta = '<%= fe_hasta%>',
            nro_tarea = '<%= nro_tarea%>',
            strWhere,
            strOrder

        function Buscar() { // Realiza la busqueda
            if (fe_desde != '' && fe_hasta != '' && nro_tarea != '') { 
                strOrder = 'fe_inicio,nro_tarea'
                strWhere = 'nro_tarea='+ nro_tarea
                fe_desde = FechaToSTR(parseFecha(fe_desde), 2)
                fe_hasta = FechaToSTR(parseFecha(fe_hasta), 2)

                var parametros = "<criterio><params fe_desde='" + fe_desde + "' fe_hasta='" + fe_hasta + "' strWhere='" + strWhere + "' strOrder='" + strOrder + "'/></criterio>"

                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroBuscar,
                    params: parametros,
                    path_xsl: 'report/verTarea/HTML_tareas_verificar.xsl',
                    formTarget: 'FrameResultado',
                    bloq_contenedor: $('FrameResultado'),
                    cls_contenedor: 'FrameResultado'
                })
            }                    
        }
           
        function window_onresize() {
            var dif = Prototype.Browser.IE ? 5 : 2,
                body_height = $$('body')[0].getHeight(),
                button_height = $('trButton').getHeight(),
                sep_height = $('trSeparador').getHeight()

            try {
                $('FrameResultado').setStyle({ 'height': body_height - button_height - sep_height - dif + 'px' })
            }
            catch(e) {}
        }
     
        function Aceptar() {
            parent.win.returnValue = 'ACEPTAR'
            parent.win.close()
        }

        function Cancelar() {
            parent.win.returnValue = 'CANCELAR'
            parent.win.close()
        }
        
        function Primer() {
            parent.win.returnValue = 'IR_A_TAREA_ORIGEN'
            parent.win.close()
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden" >
    <table class="tb1" cellpadding="0" cellspacing="0" width="100%" border="0">
        <tr>
            <td colspan="3">
                <iframe name="FrameResultado" id="FrameResultado" style="width: 100%; height: 100%;overflow: auto" frameborder="0" src="enBlanco.htm"></iframe>
            </td>
        </tr>
        <tr id="trSeparador"><td>&nbsp;</td></tr>
        <tr id="trButton">
            <td style="text-align:center;width:33%">
                <div id="divAceptar" style="width:100%"/>
            </td> 
            <td style="text-align:center;width:33%">
                <div id="divPrimer" style="width:100%"/>
            </td> 
            <td style="text-align:center">
                <div id="divCancelar" style="width:100%"/>
            </td> 
        </tr>
  </table>
</body>
</html>
