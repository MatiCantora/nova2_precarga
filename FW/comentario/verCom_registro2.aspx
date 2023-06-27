<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")
    Dim nro_com_id_tipo = nvUtiles.obtenerValor("nro_com_id_tipo", "")
    Dim id_tipo = nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_com_grupo = nvUtiles.obtenerValor("nro_com_grupo", "")
    Dim collapsed_fck = nvUtiles.obtenerValor("collapsed_fck", "")
    Dim nro_circuito = nvUtiles.obtenerValor("nro_circuito", "")
    Dim do_zoom = nvUtiles.obtenerValor("do_zoom", "")

    If (collapsed_fck <> "") Then
        collapsed_fck = 1
    Else
        collapsed_fck = 0
    End If

    If (do_zoom <> "") Then
        do_zoom = 1
    Else
        do_zoom = 0
    End If


    Me.contents("filtroverComRegistro") = nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro'><campos>*</campos><orden>com_prioridad desc, fecha</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroverCom_id_tipo_grupos") = nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_id_tipo_grupos'><campos>nro_com_grupo, com_grupo</campos><orden></orden><filtro></filtro><grupo></grupo></select></criterio>")
    Me.contents("filtroComRegistro") = nvXMLSQL.encXMLSQL("<criterio><select vista='com_registro'><campos>dbo.rm_com_html_parametro(nro_registro,'%visible%',1) as html_parametros</campos><orden></orden><filtro><nro_registro type='igual'>%nro_registro%</nro_registro></filtro></select></criterio>")


%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar Registro</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tScript.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">
        var alert = function (msg) {
            Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }

        var nro_entidad = '<%= nro_entidad %>'
        var nro_com_id_tipo = '<%= nro_com_id_tipo %>'
        var id_tipo = '<%= id_tipo %>'
        var nro_com_grupo = '<%= nro_com_grupo %>'
        var collapsed_fck = parseInt('<%= collapsed_fck  %>');
        var do_zoom = parseInt('<%= do_zoom %>');
        var nro_circuito = '<%= nro_circuito %>';

        //Botones
        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Nuevo";
        vButtonItems[0]["etiqueta"] = "Nuevo";
        vButtonItems[0]["imagen"] = "nueva";
        vButtonItems[0]["onclick"] = "return ABMRegistro('" + nro_entidad + "'," + id_tipo + "," + nro_com_id_tipo + ", 0, 0, 0)";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("nueva", '/fw/image/comentario/nueva.png')


        function Mostrar_Registro_grupo(nro_com_grupo_nuevo) {

            var objlink = eval("ObtenerVentana('iframe_grupo').document.all.link_" + nro_com_grupo)

            objlink.style.fontStyle = ''
            objlink.style.fontWeight = ''

            nro_com_grupo = nro_com_grupo_nuevo

            objlink.style.fontStyle = 'italic'
            objlink.style.fontWeight = 'bold'

            var e
            try {
                var strFiltro = ''

                if (nro_entidad > 0)
                    strFiltro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"

                if (id_tipo > 0)
                    strFiltro += "<id_tipo type='igual'>" + id_tipo + "</id_tipo>"

                strFiltro += "<nro_com_id_tipo type='igual'>" + nro_com_id_tipo + "</nro_com_id_tipo>"
                strFiltro += "<nro_com_grupo type='igual'>" + nro_com_grupo + "</nro_com_grupo>"

                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroverComRegistro,
                    filtroWhere: "<criterio><select><campos></campos><orden>com_prioridad desc, fecha</orden><filtro>" + strFiltro + "</filtro></select></criterio>",
                    path_xsl: "report/comentario/verCom_registro/verRegistro_base_detalle.xsl",
                    formTarget: 'iframe_detalle',
                    bloq_contenedor: $('iframe_detalle'),
                    cls_contenedor: 'iframe_detalle',
                    cls_contenedor_msg: '&nbsp;'
                })
            }
            catch (e) {
            }
        }

        function ABMRegistro(nro_entidad, id_tipo, nro_com_id_tipo, nro_registro_origen, nro_com_tipo_origen, nro_com_estado_origen) {

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW

            var Parametros = []
            Parametros["nro_entidad"] = nro_entidad
            Parametros["id_tipo"] = id_tipo
            Parametros["nro_com_id_tipo"] = nro_com_id_tipo
            Parametros["nro_registro_origen"] = nro_registro_origen
            Parametros["nro_com_tipo_origen"] = nro_com_tipo_origen
            Parametros["nro_com_estado_origen"] = nro_com_estado_origen
            Parametros["collapsed_fck"] = collapsed_fck
            Parametros["nro_circuito"] = nro_circuito
            Parametros["nro_com_grupo"] = nro_com_grupo


            window.top.win = w.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/ABMRegistro.aspx' +
                    '?nro_entidad=' + nro_entidad +
                    '&id_tipo=' + id_tipo +
                    '&nro_com_id_tipo=' + nro_com_id_tipo +
                    '&nro_registro_origen=' + nro_registro_origen +
                    '&nro_com_tipo_origen=' + nro_com_tipo_origen +
                    '&nro_com_estado_origen=' + nro_com_estado_origen +
                    '&nro_circuito=' + nro_circuito +
                    '&nro_com_grupo=' + nro_com_grupo +
                    '&collapsed_fck=' + collapsed_fck,
                title: '<b>Alta de Comentario</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 600,
                resizable: true,
                onClose: Mostrarcomentarios_return
            });

            window.top.win.options.userData = Parametros
            window.top.win.showCenter(true)
        }

        function Mostrarcomentarios_return() {
            if (window.top.win.returnValue != undefined)
                Mostrar_Registro_grupo(nro_com_grupo)
        }

        function window_onload() {
            // mostramos los botones creados
            vListButtons.MostrarListButton()
            // window_onresize();

            if (nro_entidad == '' && parent.entidad != undefined)
                nro_entidad = parent.nro_entidad

            if (parent.$('nro_ref_get') != null && id_tipo == '' && parent.$('nro_ref_get').value > 0)
                id_tipo = parent.$('nro_ref_get').value

            window_onresize()

            get_com_grupo()
        }

        function window_onresize() {
            try {

                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                trTitulo_height = $('tbTitulo').getHeight()
                alto = body_height - trTitulo_height - dif - 5
                $('iframe_detalle').setStyle({ height: alto })

                $('tbResto').setStyle({ height: alto })

                var alto_grupo = (alto * 0.65) + 'px'
                $('divGrupo').setStyle({ height: alto_grupo })
            }
            catch (e) {
            }
        }

        function get_com_grupo() {
            // return
            //                var URL = "/fw/reportViewer/exportarReporte.asp"
            //                path_xsl = "report/comentario/verCom_registro/verRegistro_base_grupo.xsl"
            //                new Ajax.Updater($('divGrupo'), URL, {method: 'get',
            //                    parameters: {filtroXML: filtroXML, path_xsl: path_xsl},
            //                    onComplete: function(win) 
            //                     {     
            //                        Mostrar_Registro_grupo(nro_com_grupo)
            //                        $('link_' + nro_com_grupo).style.fontStyle = 'italic'
            //                        $('link_' + nro_com_grupo).style.fontWeight = 'bold' // le da formato al grupo seleccionado
            //                     }
            //                });

            path_xsl = "//report//comentario//verCom_registro//verRegistro_base_grupo.xsl"
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroverCom_id_tipo_grupos
                , filtroWhere: "<criterio><select><campos></campos><orden>com_grupo desc</orden><filtro><nro_com_id_tipo type='igual'>" + nro_com_id_tipo + "</nro_com_id_tipo></filtro><grupo></grupo></select></criterio>"
                , path_xsl: path_xsl
                , salida_tipo: "adjunto"
                , formTarget: "iframe_grupo"
                , async: false
                , bloq_contenedor: $("iframe_grupo")
                , funComplete: function (response, parseError) {
                    Mostrar_Registro_grupo(nro_com_grupo)
                }
                //                 , bloq_contenedor: "iframe_grupo"
                //                   , cls_contenedor: "iframe_grupo"
            })
        }

        function zoom_comentarios() {
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;

            var Parametros = []
            Parametros["nro_registro_origen"] = 0//nro_registro_origen 
            Parametros["nro_com_id_tipo"] = nro_com_id_tipo
            Parametros["id_tipo"] = id_tipo
            Parametros["nro_com_tipo_origen"] = 0//nro_com_tipo_origen
            Parametros["nro_entidad"] = nro_entidad

            window.top.win = w.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/verCom_registro.aspx?nro_com_id_tipo=' + nro_com_id_tipo + '&nro_com_grupo=' + nro_com_grupo + '&collapsed_fck=' + collapsed_fck + '&id_tipo=' + id_tipo,
                title: '<b>Comentarios</b>',
                minimizable: false,
                maximizable: true,
                draggable: true,
                resizable: true,
                onClose: get_com_grupo
            });

            window.top.win.options.userData = Parametros
            window.top.win.showCenter(true);
            window.top.win.maximize();
        }

        function Ver_com_parametros(nro_registro, visible) {
            var rs = new tRS();

            var parametros = "<criterio><params visible='" + visible + "' nro_registro='" + nro_registro + "' /></criterio>"

            rs.open(nvFW.pageContents.filtroComRegistro, "", "", "", parametros)

            if (!rs.eof()) {
                return rs.getdata('html_parametros')
            }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <table id="tbTitulo" style="width: 100%; font-weight: bold">
        <tr class="tbLabel">
            <td colspan="2">
                <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
                <script type="text/javascript">
                    var DocumentMNG = new tDMOffLine;
                    var vMenu = new tMenu('divMenu', 'vMenu');
                    Menus["vMenu"] = vMenu
                    Menus["vMenu"].alineacion = 'centro';
                    Menus["vMenu"].estilo = 'A';
                    //Menus["vMenu"].imagenes = Imagenes //Imagenes se declara en pvUtiles  
                    if (do_zoom) {
                        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Zoom</Desc><Acciones><Ejecutar Tipo='script'><Codigo>zoom_comentarios()</Codigo></Ejecutar></Acciones></MenuItem>")
                    }
                    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Registro de comentarios</Desc></MenuItem>")

                    vMenu.loadImage("buscar", '/fw/image/comentario/buscar.png')
                    vMenu.MostrarMenu()
                </script>
            </td>
        </tr>
    </table>
    <table id="tbResto" class="tb1" style="height: 100% !Important">
        <tr>
            <td style="width: 85%; vertical-align: top">
                <iframe name="iframe_detalle" id="iframe_detalle" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>
            </td>
            <td id="menu_right" style="vertical-align: top">
                <table class="tb1">
                    <tr class="tbLabel0">
                        <td>Grupos</td>
                    </tr>
                    <tr>
                        <td style="width: 100% !Important; vertical-align: top">
                            <div id="divGrupo" style="width: 100% !Important; overflow: auto">
                                <iframe name="iframe_grupo" id="iframe_grupo" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>
                            </div>
                        </td>
                    </tr>
                    <tr class="tbLabel0">
                        <td>Comentario</td>
                    </tr>
                    <tr>
                        <td style="width: 100% !Important; vertical-align: top">
                            <div id="divNuevo" style="width: 100% !Important"></div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
