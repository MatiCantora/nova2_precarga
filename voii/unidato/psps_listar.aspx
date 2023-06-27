<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_pld", 4)) Then
        Response.Redirect("/FW/error/httpError_403.aspx")
    End If

    Me.addPermisoGrupo("permisos_pld")

    Me.contents("filtroPsps") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psps' cn='UNIDATO'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroTipoCuenta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPLAV_TIPO_CUENTA' cn='UNIDATO'><campos> distinct ID_TIPO_CUENTA as id, TIPO_CUENTA as [campo] </campos><orden></orden><filtro></filtro></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Listado de Clientes PSP</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        function window_onload() {
            window_onresize();
            buscar_onclick();

            let vButtonItems = [];
            vButtonItems[0] = [];
            vButtonItems[0]["nombre"] = "Buscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar_onclick()";

            let vListButtons = new tListButton(vButtonItems, 'vListButtons');
            vListButtons.loadImage("buscar", '../image/icons/buscar.png');
            vListButtons.MostrarListButton();
        }

        function buscar_onclick() {
            let cantFilas = Math.floor(($("listaPsps").getHeight() - 18 * 2) / 22);
            let filtroWhere = "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' cacheControl='session' expire_minutes='2'><filtro>" + campos_defs.filtroWhere() + "</filtro></select></criterio>";

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroPsps
                , filtroWhere: filtroWhere
                , path_xsl: "report/unidato/psps_listar.xsl"
                , salida_tipo: "adjunto"
                , ContentType: "text/html"
                , formTarget: "listaPsps"
                , nvFW_mantener_origen: true
            })
        }

        function psps_editar(id_cliente, tipo_cuenta, tipo_doc, cuitcuil, razon_social="", cbu, cod_bcra) {
            if (!nvFW.tienePermiso("permisos_pld", 4)) {
                nvFW.alert("No tiene permisos para realizar esta acción. Contacte al administrador del sistema.");
                return;
            }

            winAgregar = nvFW.createWindow(
                {
                    className: 'alphacube',
                    url: "psps_abm.aspx",
                    title: 'ABM PSP  ' + razon_social,
                    width: 700,
                    height: 300,
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    resizable: true,
                    destroyOnClose: true,
                    onClose: function (win) {
                        buscar_onclick();
                    }
                }
            )

            // Viene en modo editar con parámetros, no en modo Nuevo
            if (typeof tipo_cuenta != 'undefined') {
                winAgregar.options.user_data = {
                    id_cliente: id_cliente,
                    tipo_cuenta: tipo_cuenta,
                    tipo_doc: tipo_doc,
                    cuitcuil: cuitcuil,
                    razon_social: razon_social,
                    cbu: cbu,
                    cod_bcra: cod_bcra
                }
            }

            winAgregar.showCenter(true);
        }

        function window_onresize() {
            let alto_body = $$('BODY')[0].getHeight();
            let alta_main = $('cabecera').getHeight();
            let alto_div = alto_body - alta_main;
            $('listaPsps').style.height = alto_div + 'px';
        }

        function onEnter(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which;
            if (key == 13)
                buscar_onclick();
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" onkeypress="onEnter(event)" style="overflow: hidden; background-color: white;">
    <div id="cabecera">
        <div class="tb1" id="tbBuscar">
            <div id="menuLista" style="width: 100%"></div>
            <script type="text/javascript">
                var vMenu = new tMenu('menuLista', 'vMenu');
                vMenu.alineacion = 'centro'
                vMenu.estilo = 'A'

                vMenu.loadImage('nuevo', '../image/icons/nueva.png')

                vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>psps_editar()</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenu.MostrarMenu();
            </script>
        </div>

        <table class="tb1">
            <tr>
                <td class="Tit1" style="width: 25%; text-align: center;">Razón Social</td>
                <td class="Tit1" style="width: 15%; text-align: center;">Tipo Cuenta</td>
                <td class="Tit1" style="width: 15%; text-align: center;">CBU</td>
                <td class="Tit1" style="width: 15%; text-align: center;">Cuit/Cuil</td>
                <td rowspan="2" style="width: 15%;" white-space="nowrap">
                    <div id="divBuscar" style="margin: 0px; padding: 0px;"></div>
                </td>
            </tr>

            <tr>
                <td style="width: 25%">
                    <script type="text/javascript">
                        campos_defs.add('razon_social', {
                            enDB: false,
                            nro_campo_tipo: 104,
                            filtroWhere: "<razon_social type='like'>%%campo_value%%</razon_social>"
                        });
                    </script>
                </td>
                <td style="width: 15%">
                    <script type="text/javascript">
                        campos_defs.add('tipo_cuenta', {
                            nro_campo_tipo: 2,
                            enDB: false,
                            filtroXML: nvFW.pageContents.filtroTipoCuenta,
                            filtroWhere: "<id_tipo_cuenta type='in'>%campo_value%</id_tipo_cuenta>",
                            mostrar_codigo: false
                        });
                    </script>
                </td>
                <td style="width: 15%">
                    <script type="text/javascript">
                        campos_defs.add('cbu', {
                            enDB: false,
                            nro_campo_tipo: 104,
                            filtroWhere: "<cbu type='igual'>%campo_value%</cbu>"
                        });
                    </script>
                </td>
                <td style="width: 15%">
                    <script type="text/javascript">
                        campos_defs.add('cuitcuil', {
                            enDB: false,
                            nro_campo_tipo: 104,
                            filtroWhere: "<cuitcuil type='igual'>'%campo_value%'</cuitcuil>"
                        })

                    </script>
                </td>
            </tr>
        </table>
    </div>

    <iframe name="listaPsps" id="listaPsps" style="width: 100%; height: 100%; border: none;" src="/fw/enBlanco.htm" frameborder="0"></iframe>

</body>
</html>
