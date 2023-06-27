<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Me.contents("filtroGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_grupos'><campos>nro_com_grupo as id, com_grupo as [campo] </campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'><campos>nro_com_tipo as id, com_tipo as [campo] </campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroGrupoTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_tipos_grupos_rel'><campos>*</campos><orden>com_prioridad DESC</orden><filtro></filtro></select></criterio>")

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
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var tabla_grupos;
        var tabla_tipos;
        var grupoSeleccionado = {};
        var tipoSeleccionado = {};
        var radio_seleccionado;
        var navegador = navigator.appName;
        var win;


        function window_onload() {
            buscar_onclick()
            window_onresize()
        }

        function window_onresize() {

            var alto_body = $$('BODY')[0].getHeight()
            var alta_main = $('cabecera').getHeight()
            var alto_div = alto_body - alta_main
            $('iframeTipoGrupo').style.height = alto_div + 'px'

        }

        function buscar_onclick() {

            var strWhere = ""

            if ($('cdef_grupo').value) {
                strWhere = "<nro_com_grupo type='igual'>" + $('cdef_grupo').value + "</nro_com_grupo>";
            }

            if ($('cdef_tipo').value) {
                strWhere += "<nro_com_tipo type='igual'>'" + $('cdef_tipo').value + "'</nro_com_tipo>";
            }

            cantFilas = Math.floor(($("iframeTipoGrupo").getHeight() - 18 * 2) / 22) - 2;
            var filtroWhere = "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' cacheControl='session' expire_minutes='2'><filtro>" + strWhere + "</filtro></select></criterio>"

            var filtroXML = nvFW.pageContents.filtroGrupoTipo
            nvFW.exportarReporte({
                filtroXML: filtroXML
                , filtroWhere: filtroWhere
                , path_xsl: '../FW/report/comentario/relaciones_listar.xsl'
                , salida_tipo: "adjunto"
                , ContentType: "text/html"
                , formTarget: "iframeTipoGrupo"
                , bloq_contenedor: $$("BODY")[0]
                , cls_contenedor: "iframeTipoGrupo"
                , nvFW_mantener_origen: true
                , cls_contenedor_msg: " "
                , bloq_msg: "Cargando lista..."
            })

        }


        function eliminarTipoGrupo(nro_com_grupo, nro_com_tipo, nro_prioridad, com_grupo, com_tipo) {

            Dialog.confirm("¿Esta seguro que desea eliminar la relacion " + com_grupo + '/' + com_tipo + "?", {

                width: 450,
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar',
                className: "alphacube",
                onOk: function (win) {

                    nvFW.error_ajax_request("com_tipo_grupo_abm.aspx", {
                        parameters: {
                            modo: "ajax_call",
                            accion: "eliminar",
                            nro_com_grupo: nro_com_grupo,
                            nro_com_tipo: nro_com_tipo,
                            nro_prioridad: nro_prioridad
                        },

                        onSuccess: function (err) {
                            win.close()
                            buscar_onclick()
                        },

                        onFailure: function (err) {
                            console.log(err.debug_desc)
                            win.close()
                        }
                    });
                }
            });
        }

        function editarTipoGrupo(nro_com_grupo, nro_com_tipo, com_prioridad) {


            var winAgregar = top.nvFW.createWindow(
                {
                    url: '../FW/comentario/com_tipo_grupo_abm.aspx',
                    title: ('ABM Grupo/Tipo'),
                    width: "500",
                    height: "210",
                    top: "50",
                    minimizable: false,
                    maximizable: false,
                    onClose: function (win) {
                        buscar_onclick()

                    }
                }
            )

            if (typeof nro_com_grupo != 'undefined') {
                winAgregar.options.user_data = {
                    nro_com_grupo: nro_com_grupo,
                    nro_com_tipo: nro_com_tipo,
                    com_prioridad: com_prioridad
                }
            }

            winAgregar.showCenter(true)
        }

        function abmGrupos() {
            win_abmGrupoTipo = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/com_grupos_abm.aspx',
                title: ('ABM de Grupos'),
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 400,
                height: 300,
                onClose: function () {
                    tabla_grupos.refresh();
                }
            });
            win_abmGrupoTipo.options.userData = {};

            win_abmGrupoTipo.showCenter(true)
        }

        function abmTipos() {
            win_abmGrupoTipo = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/com_tipos_abm.aspx',
                title: ('ABM de Tipos'),
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 1300,
                height: 350,
                onClose: function () {
                    tabla_tipos.refresh();

                }
            });
            win_abmGrupoTipo.options.userData = {};

            win_abmGrupoTipo.showCenter(true)
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" onkeypress="return key_Buscar()" style="overflow: hidden">
    <div id="cabecera">
        <div id="tbBuscar">
            <div id="menuLista" style="width: 100%"></div>
            <script type="text/javascript">
                var vMenu = new tMenu('menuLista', 'vMenu');
                vMenu.alineacion = 'centro'
                vMenu.estilo = 'A'

                vMenu.loadImage('relacion', '/FW/image/icons/agregar.png')
                vMenu.loadImage('grupo', '/FW/image/icons/grupo.png')
                vMenu.loadImage('tipo', '/FW/image/icons/agregar_novedad.png')


                vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>relacion</icono><Desc>Nueva Relación</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editarTipoGrupo()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>grupo</icono><Desc>Nuevo Grupo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abmGrupos()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>tipo</icono><Desc>Nuevo Tipo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abmTipos()</Codigo></Ejecutar></Acciones></MenuItem>")


                vMenu.MostrarMenu();
            </script>
        </div>

        <table class="tb1" id="tablaMenu">
            <tr>
                <td class="Tit1" style="width: 10%; text-align: center;">Grupo</td>
                <td style="width: 30%">
                    <script type="text/javascript">
                        campos_defs.add('cdef_grupo', {
                            nro_campo_tipo: 2,
                            enDB: false,
                            filtroXML: nvFW.pageContents.filtroGrupo,
                            filtroWhere: "<nro_com_grupo type='igual'>%campo_value%</nro_com_grupo>"
                        });
                    </script>
                </td>
                <td class="Tit1" style="width: 10%; text-align: center;">Tipo</td>
                <td style="width: 30%">
                    <script type="text/javascript">
                        campos_defs.add('cdef_tipo', {
                            nro_campo_tipo: 2,
                            enDB: false,
                            filtroXML: nvFW.pageContents.filtroTipo,
                            filtroWhere: "<nro_com_tipo type='igual'>%campo_value%</nro_com_tipo>"
                        });
                    </script>
                </td>
                <td style="width: 20%">
                    <div id="divBuscar"></div>
                    <script type="text/javascript">
                        var vButtonItems = {};
                        vButtonItems[0] = {};
                        vButtonItems[0]["nombre"] = "Buscar";
                        vButtonItems[0]["etiqueta"] = "Buscar";
                        vButtonItems[0]["imagen"] = "buscar";
                        vButtonItems[0]["onclick"] = "return buscar_onclick()";

                        var vListButton = new tListButton(vButtonItems, 'vListButton');
                        vListButton.loadImage('buscar', '/FW/image/icons/buscar.png')

                        vListButton.MostrarListButton();
                    </script>
                </td>
            </tr>
        </table>
    </div>
    <iframe id="iframeTipoGrupo" name="iframeTipoGrupo" style="width: 100%; height: 100%; border: 0px"></iframe>
</body>
</html>
