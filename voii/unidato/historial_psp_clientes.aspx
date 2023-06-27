<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 5)) Then
        Response.Redirect("/FW/error/httpError_403.aspx")
    End If

    Me.contents("filtro_cliente_hist") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_clientes_log' cn='UNIDATO'><campos>id_cliente, razon_social, cuitcuil, tipo_persona, gran_cliente, login, momento</campos><filtro></filtro><orden></orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>PSP Clientes Log</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();

        function window_onload() {
            cargar_datos(win.options.userData.id_cliente, win.options.userData.cuitcuil);
        }

        function cargar_datos(id_cliente, cuitcuil) {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_cliente_hist,
                filtroWhere: "<criterio><select><filtro><id_cliente type='igual'>'" + id_cliente + "'</id_cliente><cuitcuil type='igual'>'" + cuitcuil + "'</cuitcuil></filtro></select></criterio>",
                path_xsl: 'report/unidato/nv_psp_clientes_log.xsl',
                formTarget: 'ver_historial_cliente_psp',
                nvFW_mantener_origen: true,
                cls_contenedor: 'ver_historial_cliente_psp'
            });
        }


    </script>

</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
  
    <iframe name="ver_historial_cliente_psp" id="ver_historial_cliente_psp" style="width: 100%; height: 100%; overflow: hidden;" frameborder="0"></iframe>

</body>
</html>
