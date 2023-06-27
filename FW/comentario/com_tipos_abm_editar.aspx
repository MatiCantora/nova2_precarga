<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Me.contents("vistaTipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_tipos'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("comTiposEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_tipos_com_estados'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("comTiposParametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_parametros_tipo'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("comEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_estados'><campos>*</campos><filtro></filtro></select></criterio>")
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
        var win = nvFW.getMyWindow();
        var modo = '';

        function window_onresize() {
            let alto_body = $$('BODY')[0].getHeight();
            let alto_menu = $('divMenuAgregar').getHeight() * 3;
            let alto_tabla = $('tbDatos').getHeight();
            let alto_iframe = (alto_body - alto_menu - alto_tabla) / 2;
            $("iframe_estilos_estados").setStyle({ height: (alto_iframe + "px") });
            $("iframe_parametros").setStyle({ height: (alto_iframe + "px") });
        }

        function window_onload() {
            let nro_com_tipo = parseInt(win.options.userData.nro_com_tipo);
            let modo_edicion = win.options.userData.modo_edicion;
            let com_tipo = win.options.userData.com_tipo;
            let nro_permiso = parseInt(win.options.userData.nro_permiso);
            let nro_permiso_grupo = parseInt(win.options.userData.nro_permiso_grupo);
            let nombre_asp = win.options.userData.nombre_asp;
            let style = win.options.userData.style;
            campos_defs.habilitar('nro_com_tipo', false);

            if (modo_edicion == "nuevo")
                return;
            if ((modo_edicion == "modificar") && (nro_com_tipo != undefined)) { //si existe
                campos_defs.set_value('nro_com_tipo', parseInt(nro_com_tipo));              
                campos_defs.set_value('com_tipo', com_tipo);
                campos_defs.set_value('nombre_asp', nombre_asp);
                campos_defs.set_value('style', style);
                if (!isNaN(nro_permiso_grupo))
                    campos_defs.set_value("nro_permiso_grupo", nro_permiso_grupo);
                if (!isNaN(nro_permiso))
                    campos_defs.set_value("nro_permiso_dep", nro_permiso);
            }

            cargar_plantilla_estilos();
            cargar_plantilla_parametros();
            window_onresize();
        }

        function guardar() {
            let com_tipo = campos_defs.get_value('com_tipo');
            let nro_com_tipo = campos_defs.get_value('nro_com_tipo');
            let style = campos_defs.get_value('style');
            let nro_permiso = campos_defs.get_value('nro_permiso_dep');
            let nombre_asp = campos_defs.get_value('nombre_asp');
            let nro_permiso_grupo = campos_defs.get_value('nro_permiso_grupo');

            if (nro_com_tipo == "")
                modo = "agregar";
            else
                modo = "modificar";
            
            if (com_tipo == "") {
                nvFW.alert('Error. Debe completar obligatoriamente el campo tipo para guardar');
                return;
            }

            let xml = '<?xml version="1.0" encoding="ISO-8859-1"?><tipos><tipo accion="' + modo + '" nro_com_tipo="' + nro_com_tipo + '" com_tipo="' + com_tipo + '" style="' + style + '" nro_permiso="' + nro_permiso + '" nombre_asp="' + nombre_asp + '" nro_permiso_grupo="' + nro_permiso_grupo + '" ></tipo></tipos>'
            if (modo == 'agregar') {
                nvFW.error_ajax_request("/FW/comentario/com_tipos_abm.aspx", {
                    parameters: {
                        xml: xml,
                        modo: "ajax_call",
                        accionBack: "guardar"
                    },

                    onSuccess: function (err) {
                        campos_defs.set_value('nro_com_tipo', err.params['nro_com_tipo']);
                        modo = "modificar";
                    },

                    onFailure: function () {
                        nvFW.alert("Ocurrió un error. Contacte al administrador.");
                    },
                    error_alert: false
                })
                
            }

            else if (modo == 'modificar') {
                nvFW.error_ajax_request("/FW/comentario/com_tipos_abm.aspx", {
                    parameters: {
                        xml: xml,
                        modo: "ajax_call",
                        accionBack: "guardar"
                    },
                    
                    onFailure: function () {
                        top.nvFW.alert("Ocurrió un error. Contacte al administrador.")
                    },
                    error_alert: false
                })
            }
        }

        function nuevo() {
            win2 = top.nvFW.createWindow({
                title: '<b>Editar Tipo</b>',
                url: '/FW/comentario/com_tipos_abm_editar.aspx',
                modal: true,
                maximizable: true,
                minimizable: true,
                resizable: false,
                draggable: true,
                height: 500,
                width: 1200,
                destroyOnClose: true
            });
            win2.options.userData = {
                modo_edicion: 'nuevo'
            }
            win2.name = "ventanaEditarTipo";
            win2.showCenter();
        }

        function estilo_estado_ABM(nro_com_tipo = '', nro_com_estado = '') {
            if (nro_com_tipo == '') {
                nro_com_tipo = campos_defs.get_value('nro_com_tipo');
                if (nro_com_tipo == '') {
                    nvFW.alert("Debe guardar el comentario antes de proceder con esta acción.");
                    return;
                }    
            }

            win3 = top.nvFW.createWindow({
                title: '<b>Editar Estilo</b>',
                url: '/FW/comentario/com_estilos_estado_abm.aspx',
                modal: true,
                maximizable: false,
                minimizable: false,
                resizable: false,
                draggable: true,
                height: 200,
                width: 500,
                destroyOnClose: true,
                onClose: function (win) {
                    cargar_plantilla_estilos();
                }
            });
            win3.options.userData = {
                nro_com_tipo: nro_com_tipo,
                nro_com_estado: nro_com_estado
            }
            win3.name = "ventanaEditarEstiloEstado";
            win3.showCenter();
            
        }

        function cargar_plantilla_estilos() {
            let nro_com_tipo = campos_defs.get_value('nro_com_tipo');
            let filtro = "<criterio><select><filtro><nro_com_tipo type='igual'>'" + nro_com_tipo + "'</nro_com_tipo></filtro></select></criterio>";
           
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.comTiposEstados,
                filtroWhere: filtro,
                path_xsl: "report/comentario/com_estilos_estado.xsl",
                formTarget: "iframe_estilos_estados",
                ContentType: "text/html",
                nvFW_mantener_origen: true
            });

        }

        function eliminar_estilo(nro_com_tipo, nro_com_estado) {
            Dialog.confirm("¿Confirma que desea eliminar el estilo?", {
                width: 350,
                className: "alphacube",
                onOk: function (winDialog) {
                    nvFW.error_ajax_request("com_estilos_estado_abm.aspx", {
                        parameters: {
                            modo: 'B',
                            nro_com_tipo: nro_com_tipo,
                            nro_com_estado: nro_com_estado
                        },

                        onFailure: function () {
                            nvFW.alert("Ocurrió un error. Contacte al administrador.");
                        },
                        error_alert: false
                    })

                    winDialog.close();
                    cargar_plantilla_estilos();
                },
                onCancel: function (winDialog) {
                    winDialog.close()
                },
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar'
            });

        }

        function cargar_plantilla_parametros() {
            let nro_com_tipo = campos_defs.get_value('nro_com_tipo');
            let filtro = "<criterio><select><filtro><nro_com_tipo type='igual'>'" + nro_com_tipo + "'</nro_com_tipo></filtro></select></criterio>";

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.comTiposParametros,
                filtroWhere: filtro,
                path_xsl: "report/comentario/com_parametros_tipo.xsl",
                formTarget: "iframe_parametros",
                ContentType: "text/html",
                nvFW_mantener_origen: true
            });

        }

        function parametros_ABM(nro_com_parametro = '') {
            let nro_com_tipo = campos_defs.get_value('nro_com_tipo');
            if (nro_com_tipo == '') {
                nvFW.alert("Debe guardar el comentario antes de proceder con esta acción.");
                return;
            }

            win4 = top.nvFW.createWindow({
                title: '<b>Editar Parámetro</b>',
                url: '/FW/comentario/com_parametros_abm.aspx',
                modal: true,
                maximizable: false,
                minimizable: false,
                resizable: false,
                draggable: true,
                height: 200,
                width: 500,
                destroyOnClose: true,
                onClose: function (win) {
                    cargar_plantilla_parametros();
                }
            });
            win4.options.userData = {
                nro_com_parametro: nro_com_parametro,
                nro_com_tipo: nro_com_tipo
            }

            win4.name = "ventanaEditarParametro";
            win4.showCenter();
        }

        function eliminarComParametro(nro_com_parametro) {
            if (nro_com_parametro == '') {
                top.nvFW.alert("No hay un parámetro seleccionado para eliminar.");
                return;
            }

            let modo = 'B';
            let strXML = '<?xml version="1.0" encoding="ISO-8859-1"?><com_parametros modo="' + modo + '" nro_com_parametro="' + nro_com_parametro + '" nro_com_tipo="' + "" + '" com_parametro="' + "" + '" tipo_dato="' + "" + '" requerido="' + "" + '" com_etiqueta="' + "" + '" por_rango="' + "" + '" esfiltro="' + "" + '" visible="' + "" + '" ></com_parametros>'
            
            Dialog.confirm("¿Confirma que desea eliminar el parámetro?", {
                width: 450,
                className: "alphacube",

                onOk: function (winDialog) {
                    nvFW.error_ajax_request("com_parametros_abm.aspx", {
                        parameters: {
                            strXML: strXML
                        },

                        onSuccess: function (err) {
                            if (err.numError == 0) {
                                winDialog.close();
                                cargar_plantilla_parametros();
                            }
                            else
                                top.nvFW.alert(err.message)
                        },

                        onFailure: function () {
                            winDialog.close();
                        },
                        error_alert: true

                    })

                },
                onCancel: function (winDialog) {
                    winDialog.close()

                },
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar'
            });

        }

        function verComEstado(nro_com_estado) {
            let rs = new tRS();
            let filtroWhere = "<criterio><select><filtro><nro_com_estado type='igual'>'" + nro_com_estado + "'</nro_com_estado></filtro></select></criterio>";
            rs.open({ filtroXML: nvFW.pageContents.comEstados, filtroWhere: filtroWhere });
            if (!rs.eof())
                return rs.getdata('com_estado');

        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%; overflow:hidden">
    <div id="divMenuAgregar">
            <script type="text/javascript">
                let vMenuAgregar = new tMenu('divMenuAgregar', 'vMenuAgregar');
                Menus["vMenuAgregar"] = vMenuAgregar;
                Menus["vMenuAgregar"].loadImage("guardar", '/fw/image/icons/guardar.png');
                Menus["vMenuAgregar"].loadImage("nueva", '/FW/image/icons/nueva.png');
                Menus["vMenuAgregar"].loadImage("estilo", '/FW/image/icons/bgcolor.gif');
                Menus["vMenuAgregar"].alineacion = 'centro';
                Menus["vMenuAgregar"].estilo = 'A';
                Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='0' style='text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 95%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='2' style='text-align:right'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo tipo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>");

                vMenuAgregar.MostrarMenu()
            </script>
    </div>

    <table class="tb1" id="tbDatos">
         <tr hidden> 
            <td class="Tit1"> Nro Tipo </td>
            <td> 
                <script type="text/javascript">
                    campos_defs.add('nro_com_tipo', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        placeholder: "se define automáticamente"
                    })
                </script>
            <td>
        </tr>

        <tr> 
            <td class="Tit1"> Tipo </td>
            <td> 
                <script type="text/javascript">
                    campos_defs.add('com_tipo', {
                        nro_campo_tipo: 104,
                        enDB: false
                    })
                </script>
            <td>
        </tr>

         <tr>
            <td class="Tit1"> Permiso grupo </td>
            <td>
                 <script type="text/javascript">
                     campos_defs.add('nro_permiso_grupo')
                 </script>
            </td>
        </tr>

        <tr>
            <td class="Tit1"> Permiso </td>
            <td> 
                <script type="text/javascript">
                    campos_defs.add('nro_permiso_dep')
                </script>
            </td>
        </tr>

        <tr>
            <td class="Tit1"> Nombre ASP </td>
            <td> 
                <script type="text/javascript">
                    campos_defs.add('nombre_asp', {
                        nro_campo_tipo: 104,
                        enDB: false
                    })
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1"> Definir estilo </td>
            <td colspan="2" >  
                <script type="text/javascript">
                    campos_defs.add('style', {
                        nro_campo_tipo: 104,
                        enDB: false
                    })
                </script>
            </td>
        </tr>
    </table>
    <div id="divMenuEstilo">
            <script type="text/javascript">
                let vMenuEstilo = new tMenu('divMenuEstilo', 'vMenuEstilo');
                Menus["vMenuEstilo"] = vMenuEstilo;
                Menus["vMenuEstilo"].loadImage("estilo", '/FW/image/icons/bgcolor.gif');
                Menus["vMenuEstilo"].alineacion = 'centro';
                Menus["vMenuEstilo"].estilo = 'A';
                Menus["vMenuEstilo"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Estilos de Estado</Desc></MenuItem>");
                Menus["vMenuEstilo"].CargarMenuItemXML("<MenuItem id='1' style='text-align:right'><Lib TipoLib='offLine'>DocMNG</Lib><icono>estilo</icono><Desc>Nuevo estilo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>estilo_estado_ABM(campos_defs.get_value('nro_com_tipo'))</Codigo></Ejecutar></Acciones></MenuItem>");

                vMenuEstilo.MostrarMenu();
            </script>
    </div>
    <iframe id="iframe_estilos_estados" name="iframe_estilos_estados" style="width:100%; height:auto; overflow:hidden;" frameborder="0"> </iframe>
    <div id="divMenuParametros">
            <script type="text/javascript">
                let vMenuParametros = new tMenu('divMenuParametros', 'vMenuParametros');
                Menus["vMenuParametros"] = vMenuParametros;
                Menus["vMenuParametros"].loadImage("parametro", '/FW/image/icons/parametros.png');
                Menus["vMenuParametros"].alineacion = 'centro';
                Menus["vMenuParametros"].estilo = 'A';
                Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Parámetros</Desc></MenuItem>");
                Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1' style='text-align:right'><Lib TipoLib='offLine'>DocMNG</Lib><icono>parametro</icono><Desc>Nuevo parámetro</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parametros_ABM()</Codigo></Ejecutar></Acciones></MenuItem>");

                vMenuParametros.MostrarMenu();
            </script>
    </div>
    <iframe id="iframe_parametros" name="iframe_parametros" style="width:100%; height:auto; overflow:hidden;" frameborder="0"> </iframe>

</body>
</html>
