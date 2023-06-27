<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%   
    Dim nro_circuito = nvFW.nvUtiles.obtenerValor("nro_circuito", "")

    Me.contents("filtroCircuitoRegistros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCire_estado_detalle'><campos>*</campos><filtro><nro_circuito type='igual'>" + nro_circuito + "</nro_circuito></filtro><orden>estado</orden></select></criterio>")

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
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var filtroCircuitoRegistros = nvFW.pageContents.filtroCircuitoRegistros
        window.alert = function (msg) {
            window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }
        function window_onresize() {
            try {
                body_h = $$('BODY')[0].clientHeight;
                var divCircuito_h = $('divCircuito').getHeight();

                $('frame_circuito').style.height = (body_h - divCircuito_h - 5) + 'px';
            } catch (err) {

            }
        }

        function window_onload() {

            cargarCircuito();

            window_onresize();
        }

        function cargarCircuito() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroCircuitoRegistros,
                filtroWhere: '<criterio><select><filtro><estado_origen type="isnull"></estado_origen></filtro></select></criterio>',
                bloq_contenedor: $('frame_circuito'),
                path_xsl: 'report/circuito/cire_estado_detalle_tree.xsl',
                bloq_msg: 'Cargando...',
                formTarget: 'frame_circuito',
                nvFW_mantener_origen: true
                //parametros: '<parametros><estado_origen>0</estado_origen><tab>0</tab></parametros>',
            })
        }

        function editCire_estado_detalle(id_cire_estado, estado_origen, fn_callback) {
            var urlABM = "/FW/circuito/cire_estado_detalle_abm.aspx?id_cire_estado=" + id_cire_estado + "&nro_circuito=" + nvFW.pageContents.nro_circuito
            if (estado_origen)
                urlABM += "&estado_origen='" + estado_origen + "'"
            var win = nvFW.createWindow({
                url: urlABM,
                title: id_cire_estado > 0 ? "<b>Editar</b>" : "<b>Nuevo</b>",
                width: 700,
                height: 210,
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



        Menus["vCircuitos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%;text-align:center; vertical-align:middle'>" +
                                        "<Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Circuitos ABM</Desc></MenuItem>")


        vCircuitos.MostrarMenu()
    </script>--%>
    
    <iframe id="frame_circuito" name="frame_circuito" style="width: 100%; height: 100%; border: none; overflow: hidden;" src="/fw/enBlanco.htm"></iframe>


</body>
</html>
