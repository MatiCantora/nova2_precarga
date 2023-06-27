<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_api_clientes_cfg", 1)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    Me.addPermisoGrupo("permisos_api_clientes_cfg")

    Me.contents("filtro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verApi_clientes_cfg'><campos>[id_api_cc_cfg],[tipdoc],[nrodoc],[sistcod],[siscod_desc],[cuecod],[cbu],[es_psp],[vigente],[moneda],[moneda_desc],[fe_vigencia],[operador],[callback],[Razon_social], tipdoc_desc,Login, desc_externo</campos><filtro></filtro><orden></orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Transferencias conf</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">  

        function window_onload() {
            var vButtonItems = {}

            vButtonItems[0] = {}
            vButtonItems[0]["nombre"] = "BtnBuscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

            vListButton.MostrarListButton();
        }

        function buscar() {
            if (!nvFW.tienePermiso('permisos_api_clientes_cfg', 1)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema');
                return;
            }

            let filtroWhere = "";

            if (campos_defs.get_value('tipdoc_codext') != "")
                filtroWhere += "<tipdoc type='in'>" + campos_defs.get_value('tipdoc_codext') + "</tipdoc>";

            if (campos_defs.get_value('nro_docu') != "")
                filtroWhere += "<nrodoc type=\"like\">%" + campos_defs.get_value('nro_docu') + "%</nrodoc>";

            if (campos_defs.get_value('cbu') != "")
                filtroWhere += "<cbu type=\"like\">%" + campos_defs.get_value('cbu') + "%</cbu>";

            if ($('es_psp').value != "") {
                if ($('es_psp').value == "No") 
                    filtroWhere += `<or><es_psp type='igual'>0</es_psp><es_psp type='isnull'/></or>`;
                else 
                    filtroWhere += `<es_psp type='igual'>1</es_psp>`;
            }

            switch ($('estado').value) {
                case "vigente":
                    filtroWhere += "<vigente type=\"like\">1</vigente>"
                    break
                case "novigente":
                    filtroWhere += "<vigente type=\"like\">0</vigente>"
                    break
                case "ambos":
                    break
            }

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro,
                filtroWhere: filtroWhere,
                path_xsl: "report/clientes_cuentas/HTML_clientes_cuentas.xsl",
                formTarget: "iframe1",
                ContentType: "text/html",
                bloq_contenedor: $('iframe1'),
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframe1',
                bloq_msg: "cargando"
            });
        }

        function editar(modo, id) {
            if (!nvFW.tienePermiso('permisos_api_clientes_cfg', 2)) {
                nvFW.alert('No posee permisos para hacer esta operación, consulte al administrador del sistema.');
                return;
            }

            let winAgregar;
            winAgregar = nvFW.createWindow({
                className: 'alphacube',
                url: 'clientes_cuentas_ABM.aspx',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 255,
                resizable: true,
                onClose: function () {
                    buscar();
                }
            });

            winAgregar.options.userData = {
                modo: modo,
                id: id
            }

            winAgregar.showCenter(true);
        }

        function pressEnter() {
            if (window.event.keyCode == 13) {
                buscar()
            }
        }
    </script>
</head>

<body id="cuerpo" onload="return window_onload()" style="width: 100%;"  onkeypress="pressEnter()">
    <div id="divCabe" style="width: 100%; overflow: auto;">
        <div id="divMenuDig"></div>
        <script type="text/javascript">
            var vMenuDig = new tMenu('divMenuDig', 'vMenuDig');
            Menus["vMenuDig"] = vMenuDig
            Menus["vMenuDig"].alineacion = 'centro';
            Menus["vMenuDig"].estilo = 'A';

            vMenuDig.loadImage("nueva", "/fw/image/icons/nueva.png");

            Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editar(\"new\")</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuDig.MostrarMenu()
        </script>

        <table id='contenedor' class="tb1">
            <tr class="tbLabel">
                <td style="text-align: center; font-weight: bolder!important">
                    Tipo de documento
                </td>
                <td style="text-align: center; font-weight: bolder!important">
                    Nro. documento
                </td>
                <%--<td>Codigo de cuenta
                </td>--%>
                <td style="text-align: center; font-weight: bolder!important">
                    CBU
                </td>
                <td style="text-align: center; font-weight: bolder!important">
                    Vigencia
                </td>
                <td style="text-align: center; font-weight: bolder!important">
                    Es PSP?
                </td>
            </tr>
            <tr>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('tipdoc_codext', { nro_campo_tipo: 2 })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('nro_docu', { nro_campo_tipo: 100, enDB: false })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('cbu', { nro_campo_tipo: 100, enDB: false })
                    </script>
                </td>
                <td>
                    <select name="select" id="estado" style="width: 100%">
                        <option value="ambos" selected>Ambos</option>
                        <option value="vigente">Vigente</option>
                        <option value="novigente">No vigente</option>
                    </select>
                </td>
                <td>
                    <select name="select" id="es_psp" style="width: 100%">
                        <option value="" selected></option>
                        <option value="Si">SI</option>
                        <option value="No">No</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td colspan="5">
                    <div id="divBtnBuscar"></div>
                </td>
            </tr>
        </table>
    </div>

    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; max-height: 817px; overflow: auto" frameborder='0'></iframe>
</body>
</html>

