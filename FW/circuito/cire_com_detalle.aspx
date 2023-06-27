<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%   
    Dim nro_circuito = nvFW.nvUtiles.obtenerValor("nro_circuito", "")

    Me.contents("filtroCircuitoRegistros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCire_com_detalle'><campos>*</campos><filtro><nro_circuito type='igual'>" + nro_circuito + "</nro_circuito></filtro><orden>com_tipo, com_estado</orden></select></criterio>")

    Me.contents("filtroCircuito") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cire_circuito'><campos>circuito</campos><filtro><nro_circuito type='igual'>" + nro_circuito + "</nro_circuito></filtro><orden></orden></select></criterio>")

    Me.contents("filtroTipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'><campos>nro_com_tipo as id, com_tipo as  [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

    Me.contents("nro_circuito") = nvFW.nvUtiles.obtenerValor("nro_circuito", "")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Modulo Comentarios</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var filtroCircuitoRegistros = nvFW.pageContents.filtroCircuitoRegistros
        var circuito = ""
        var frame_circuito

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return cargarCircuito()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png') 

        window.alert = function (msg) {
            window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }
        function window_onresize() {
            try {
                body_h = $$('BODY')[0].clientHeight;
                var divCircuito_h = $('divCircuito').getHeight();
                var divFiltro_h = $('divFiltro').getHeight();

                $('frame_circuito').style.height = (body_h - divCircuito_h - divFiltro_h ) + 'px';
            } catch (err) {

            }
        }

        function window_onload() {

            var rs = new tRS();
            rs.open({
                filtroXML: nvFW.pageContents.filtroCircuito,
            });
            circuito = rs.getdata("circuito")

            frame_circuito = $("frame_circuito")

            vListButtons.MostrarListButton()

            cargarCircuito();

            window_onresize();
        }

        function cargarCircuito(expandir) {
            var tipo = campos_defs.get_value("tipo")
            var filtro = ""
            if (tipo)
                filtro = '<criterio><select><filtro><nro_com_tipo_origen type="isnull"></nro_com_tipo_origen><nro_com_tipo type="igual">' + tipo + '</nro_com_tipo></filtro></select></criterio>'
            else
                filtro = '<criterio><select><filtro><nro_com_tipo_origen type="isnull"></nro_com_tipo_origen></filtro></select></criterio>'

            nvFW.bloqueo_activar($$("BODY")[0], "rsOnload");
            
            nvFW.exportarReporte({
                async: false,
                filtroXML: nvFW.pageContents.filtroCircuitoRegistros,
                filtroWhere: filtro,
                bloq_contenedor: $('frame_circuito'),
                path_xsl: 'report/circuito/cire_com_detalle_tree.xsl',
                bloq_msg: 'Cargando...',
                formTarget: 'frame_circuito',
                nvFW_mantener_origen: true,
                parametros: '<parametros><circuito>' + circuito + '</circuito><expandir>' + (expandir || 0) + '</expandir></parametros>',//'<parametros><nro_com_tipo_origen>0</nro_com_tipo_origen><nro_com_estado_origen>0</nro_com_estado_origen><tab>0</tab></parametros>',
                funComplete: function (w) {
                    reporteRaizContent = w.target.contentWindow
                    nvFW.bloqueo_desactivar($$("BODY")[0], "rsOnload");
                }
            })

            
        }

        function expandirContraerArbol(){
            if (reporteRaizContent) {
                nvFW.bloqueo_activar($$("BODY")[0], "rsOnload");
                reporteRaizContent.expandirContraer();
                nvFW.bloqueo_desactivar($$("BODY")[0], "rsOnload");
            }
                
        }

        function editCire_com_detalle(id_cire_com_detalle, nro_com_tipo_origen, nro_com_estado_origen, fn_callback) {

            var win = nvFW.createWindow({
                url: "/FW/circuito/cire_com_detalle_abm.aspx?id_cire_com_detalle=" + id_cire_com_detalle +
                    "&nro_circuito=" + nvFW.pageContents.nro_circuito +
                    "&nro_com_tipo_origen=" + nro_com_tipo_origen +
                    "&nro_com_estado_origen=" + nro_com_estado_origen,
                title: id_cire_com_detalle > 0 ? "<b>Editar</b>" : "<b>Nuevo</b>",
                width: 750,
                height: 250,
                resizable: true,
                maximizable: false,
                minimizable: false,
                //height: height,
                //width: width,
                onShow: function (win) {

                },
                onClose: function (win) {

                    if (win.options.userData.hay_modificacion) {
                        if (fn_callback)
                            fn_callback();

                        //cargarCircuito();
                    }
                }

            });

            win.showCenter(true)
        }

    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="overflow: hidden;">
    <div id="divCircuito"></div>
    <%--<script type="text/javascript">
        //var DocumentMNG = new tDMOffLine;
        var vCircuitos = new tMenu('divCircuito', 'vCircuitos');
        vCircuitos.loadImage("abm", '/FW/image/icons/abm.png')
        Menus["vCircuitos"] = vCircuitos
        Menus["vCircuitos"].alineacion = 'centro';
        Menus["vCircuitos"].estilo = 'A';


        vCircuitos.loadImage("guardar", '/FW/image/icons/guardar.png')
        vCircuitos.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%;text-align:center; vertical-align:middle'>" +
            "<Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Estructura</Desc></MenuItem>")
        vCircuitos.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Expandir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>expandirArbol()</Codigo></Ejecutar></Acciones></MenuItem>")


        vCircuitos.MostrarMenu()
    </script>--%>
    <div id="divFiltro">
        <table class="tb1" style="width:90%; float:left;">
            <tr>
                <td class="Tit2" width="100px" >Tipo:</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add("tipo",
                            {
                                enDB: false,
                                nro_campo_tipo: 1,
                                filtroXML: nvFW.pageContents.filtroTipos
                            })
                    </script>
                </td>
            </tr>
        </table>
        <div id="divBuscar" style="width:10%; float:left;"></div>
        <div style="clear:both;"></div>
    </div>
    <iframe id="frame_circuito" name="frame_circuito" style="width: 100%; height: 100%; border: none; overflow: hidden;" src="/fw/enBlanco.htm"></iframe>


</body>
</html>
