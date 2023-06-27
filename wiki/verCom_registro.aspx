<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim nro_entidad = nvFW.nvUtiles.obtenerValor("nro_entidad", "")
    Dim nro_com_id_tipo = nvFW.nvUtiles.obtenerValor("nro_com_id_tipo", "")
    Dim id_tipo = nvFW.nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_com_grupo = nvFW.nvUtiles.obtenerValor("nro_com_grupo", "")
    Dim collapsed_fck = nvFW.nvUtiles.obtenerValor("collapsed_fck", "")
    Dim do_zoom = nvFW.nvUtiles.obtenerValor("do_zoom", "")

    Me.contents("filtroMostrarRegistroGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro'><campos>*</campos><orden>com_prioridad desc, fecha</orden></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Consultar Registro</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

        <% = Me.getHeadInit() %>

        <script type="text/javascript">
            var Imagenes = []
            Imagenes["buscar1"] = new Image();
            Imagenes["buscar1"].src = '/FW/image/icons/buscar.png';
            Imagenes["nueva"] = new Image();
            Imagenes["nueva"].src = '/FW/image/icons/nueva.png';

            var nro_entidad = '<%= nro_entidad %>',
                nro_com_id_tipo = '<%= nro_com_id_tipo %>',
                id_tipo = '<%= id_tipo %>',
                nro_com_grupo = '<%= nro_com_grupo %>',
                collapsed_fck = parseInt('<%= collapsed_fck  %>');
            collapsed_fck = (collapsed_fck != '0') ? 1 : 0;
            
            var do_zoom = parseInt('<%= do_zoom %>');
            do_zoom = (do_zoom != '0') ? 1 : 0;

            //Botones
            var vButtonItems = {};
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Nuevo";
            vButtonItems[0]["etiqueta"] = "Nuevo";
            vButtonItems[0]["imagen"] = "nueva";
            vButtonItems[0]["onclick"] = "return ABMRegistro(nro_entidad, id_tipo,nro_com_id_tipo, 0, 0)";

            var vListButtons = new tListButton(vButtonItems, 'vListButtons')
            vListButtons.imagenes = Imagenes // "Imagenes" está definida en "pvUtiles.asp"

            function window_onload()
            {
                // mostramos los botones creados
                vListButtons.MostrarListButton()
                window_onresize()
            }

            function Mostrar_Registro_grupo(nro_com_grupo_nuevo)
            {/*
                $('link_' + nro_com_grupo).style.fontStyle = ''
                $('link_' + nro_com_grupo).style.fontWeight = ''
                */
                nro_com_grupo = nro_com_grupo_nuevo
                /*
                $('link_' + nro_com_grupo).style.fontStyle = 'italic'
                $('link_' + nro_com_grupo).style.fontWeight = 'bold'
                */
                var e
                try {
                    var strFiltro = ''

                    if (nro_entidad > 0)
                        strFiltro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"

                    if (id_tipo > 0)
                        strFiltro += "<id_tipo type='igual'>" + id_tipo + "</id_tipo>"

                    //strFiltro += "<nro_com_id_tipo type='igual'>" + nro_com_id_tipo + "</nro_com_id_tipo>"
                    strFiltro += "<nro_com_grupo type='igual'>" + nro_com_grupo + "</nro_com_grupo>"

                    nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.filtroMostrarRegistroGrupo,
                        filtroWhere: strFiltro,
                        path_xsl: "report/verCom_registro/verRegistro_base_detalle.xsl",
                        formTarget: 'iframe_detalle',
                        bloq_contenedor: $('iframe_detalle'),
                        cls_contenedor: 'iframe_detalle',
                        cls_contenedor_msg: '&nbsp;'
                    })
                }
                catch(e) {}
            }

            function ABMRegistro(nro_entidad, id_tipo, nro_com_id_tipo, nro_registro, nro_com_tipo)
            {
                //var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                window.top.win = nvFW.createWindow({
                    url: '/FW/comentario/ABMRegistro.aspx?nro_entidad=' + nro_entidad + '&id_tipo=' + id_tipo + '&nro_com_id_tipo=' + nro_com_id_tipo + '&nro_registro=' + nro_registro + '&nro_com_tipo=' + nro_com_tipo + '&collapsed_fck=' + collapsed_fck,
                    title: '<b>Alta de Comentario</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    width: 800,
                    height: 550,
                    resizable: true,
                    onClose: Mostrarcomentarios_return
                });
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

                if (parent.$('nro_ref_get') != null)
                    if (id_tipo == '' && parent.$('nro_ref_get').value > 0)
                        id_tipo = parent.$('nro_ref_get').value


                window_onresize()
            }

            function window_onresize() {
                try {
                    var dif = Prototype.Browser.IE ? 5 : 2
                    body_height = $$('body')[0].getHeight()
                    trTitulo_height = $('tbTitulo').getHeight()
                    alto = body_height - trTitulo_height - dif - 5
                    $('tbResto').setStyle({height: alto})
                }
                catch (e) {
                }
            }


            function get_com_grupo()
            {
                var URL = "/FW/reportViewer/exportarReporte.aspx"
                filtroXML = "<criterio><select vista='verCom_id_tipo_grupos'><campos>nro_com_grupo, com_grupo</campos><orden>com_grupo desc</orden><filtro><nro_com_id_tipo type='igual'>" + nro_com_id_tipo + "</nro_com_id_tipo></filtro><grupo></grupo></select></criterio>"
                path_xsl = "report/verCom_registro/verRegistro_base_grupo.xsl"
                new Ajax.Updater($('divGrupo'), URL, {method: 'get',
                    parameters: {filtroXML: filtroXML, path_xsl: path_xsl},
                    onComplete: function(win) {
                        Mostrar_Registro_grupo(nro_com_grupo)
                        $('link_' + nro_com_grupo).style.fontStyle = 'italic'
                        $('link_' + nro_com_grupo).style.fontWeight = 'bold' // le da formato al grupo seleccionado
                    }
                });
            }

            function zoom_comentarios() {
                //var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                window.top.win = nvFW.createWindow({
                    url: '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=' + nro_com_id_tipo + '&nro_com_grupo=' + nro_com_grupo + '&collapsed_fck=' + collapsed_fck + '&id_tipo=' + id_tipo,
                    title: '<b>Comentarios</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    resizable: true,
                    onClose: get_com_grupo
                });
                window.top.win.showCenter(true);
                window.top.win.maximize();
            }
        </script>
    </head>
    <body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%; overflow:hidden">
        <form action='' name="frmCom" style='width:100%;height:100%;overflow:hidden'>
            <table id="tbTitulo" style="width:100%;font-weight:bold">
                <tr class="tbLabel" >
                    <td colspan="2">
                        <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
                        <script type="text/javascript">
                            var DocumentMNG = new tDMOffLine;
                            var vMenu = new tMenu('divMenu', 'vMenu');
                            Menus["vMenu"] = vMenu
                            Menus["vMenu"].alineacion = 'centro';
                            Menus["vMenu"].estilo = 'A';
                            Menus["vMenu"].imagenes = Imagenes //Imagenes se declara en pvUtiles  


                            if(do_zoom){
                                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar1</icono><Desc>Zoom</Desc><Acciones><Ejecutar Tipo='script'><Codigo>zoom_comentarios()</Codigo></Ejecutar></Acciones></MenuItem>")
                            }
                            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Registro de comentarios</Desc></MenuItem>")
                            vMenu.MostrarMenu()
                        </script>
                    </td>
                </tr>
            </table>
            <table id="tbResto" class="tb1" style="height:100% !Important">
                <tr>
                    <td style="width:85%">
                        <iframe name="iframe_detalle" id="iframe_detalle" style="width:100%;height:100%;overflow:hidden" frameborder="0"></iframe>
                    </td>
                    <td id="menu_right" style="vertical-align:top">
                        <table class="tb2">
                            <tr class="tbLabel0">
                                <td>Grupos</td>
                            </tr>
                            <tr>
                                <td style="width:100% !Important">
                                    <div id="divGrupo" style="width:100% !Important"></div>
                                    <script type="text/javascript">
                                        get_com_grupo()
                                    </script>
                                </td>
                            </tr>
                            <tr class="tbLabel0">
                                <td>Comentario</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td style="width:100% !Important">
                                    <div id="divNuevo" style="width:100% !Important"></div>
                                </td>
                            </tr>
                        </table>								
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
