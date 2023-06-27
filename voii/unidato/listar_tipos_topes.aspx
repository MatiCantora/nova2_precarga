<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 4)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Me.contents("vista_tipos_tope") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psps_topes_tipos' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden>fe_hasta</orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Tipos de Topes</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();

        function window_onload() {
            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu;
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_tipo_tope()</Codigo></Ejecutar></Acciones></MenuItem>")
            pMenu.loadImage("nuevo", "../image/icons/nueva.png");

            pMenu.MostrarMenu();

            mostrar_listado();
        }

        function mostrar_listado() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.vista_tipos_tope,
                path_xsl: 'report/unidato/verNv_psp_tipos_tope.xsl',
                formTarget: 'ver_tipos_tope',
                nvFW_mantener_origen: true,
                cls_contenedor: 'ver_tipos_tope'
            });
        }

        function nuevo_tipo_tope() {
            let win = nvFW.createWindow({
                className: 'alphacube',
                url: 'abm_tipos_topes.aspx',
                title: 'Nuevo Tipo Tope',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: false,
                width: 400,
                height: 150,
                destroyOnClose: true
            });

            win.showCenter(true);
        }

    </script>

</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>
    <iframe name="ver_tipos_tope" id="ver_tipos_tope" style="width: 100%; height: 70%; overflow: hidden" frameborder="0"></iframe>

</body>
</html>
