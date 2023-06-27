<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim operador As nvFW.nvPages.tnvOperadorAdmin
    Dim er As New tError

    operador = nvFW.nvApp.getInstance().operador
    'debe tener el permiso para ingresar
    If Not operador.tienePermiso("permisos_web", 2) Then
        er = New nvFW.tError()
        er.numError = -1
        er.titulo = "No se pudo completar la operación."
        er.mensaje = "No tiene permisos para ver la página."
        er.response()
    End If

    Me.contents("instancias_Watchers") = nvXMLSQL.encXMLSQL("<criterio><select vista='verNvw_Instancias_Watchers'><campos>*</campos><orden>nvwInstancia</orden><filtro></filtro></select></criterio>")
    Me.contents("instancias_Watchers_Report") = nvXMLSQL.encXMLSQL("<criterio><select vista='verNvw_Instancias_Watchers'><campos>nvwInstancia, nvwLabel, dirOrigen, dirDestino, dirBackup, dirFiltro, iif(addPrefijo = 1, 'Si', iif(addPrefijo is NULL,'', 'No')), iif(addPosFijo = 1, 'Si', iif(addPosFijo is NULL,'', 'No')), iif(includeDir = 1, 'Si', iif(includeDir is NULL,'', 'No')), seg_timeout, el_machine, el_log, el_source, el_cn</campos><orden>nvwInstancia</orden><filtro></filtro></select></criterio>")
    'Dim tienePermiso As Boolean = nvFW.nvApp.getInstance().operador.tienePermiso("permisos_web", Math.Pow(2, 3 - 1))

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Watcher</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript" >
        var isIE            = Prototype.Browser.IE ? true : false
        var tbBuscar_height = 0
        var $body


        function listaInstanciasWatchers_resize()
        {
            $("listaInstanciasWatchers").setStyle({ height: ($body.getHeight() - tbBuscar_height) + "px" })
        }


        function window_onload()
        {
            nvFW.enterToTab = false
            $body = $$("BODY")[0]
            tbBuscar_height = $("tbBuscar").getHeight() // La altura de los campos de búsqueda no cambian
            listaInstanciasWatchers_resize()
            setearListenerInputs()
            buscar_onclick();
        }


        function window_onresize()
        {
            listaInstanciasWatchers_resize()
        }


        function setearListenerInputs()
        {
            // Iterar sobre los IDs de campos de busqueda
            ["label", "origen", "destino"].each(function (idElement) {
                $(idElement).addEventListener("keyup", function(e) { checkKey(e, this) }, false)
            })
        }


        var ENTER_KEY  = 13
        var ESCAPE_KEY = 27


        function checkKey(event, element)
        {
            return (isIE ? event.keyCode : event.which) == ENTER_KEY
                    ? buscar_onclick() 
                    : (isIE ? event.keyCode : event.which) == ESCAPE_KEY
                        ? element.value = "" 
                        : true
        }

        function getStrWhere() {
            var strWhere = ""


            if (campos_defs.value("nro_instancias_watcher") != '')
                strWhere += "<id_nvwinstancia type='in'>" + campos_defs.value("nro_instancias_watcher") + "</id_nvwinstancia>"

            if (campos_defs.value("label") != '')
                strWhere += "<nvwLabel type='like'>%" + campos_defs.value("label") + "%</nvwLabel>"

            if (campos_defs.value("origen") != '')
                strWhere += "<dirOrigen type='like'>%" + campos_defs.value("origen") + "%</dirOrigen>"

            if (campos_defs.value("destino") != '')
                strWhere += "<dirDestino type='like'>%" + campos_defs.value("destino") + "%</dirDestino>"

            return strWhere;
        }

        function buscar_onclick()
        {
            var strWhere = getStrWhere()

            var alto = $("listaInstanciasWatchers").clientHeight
            var filas       = alto / 22.6 // 22.6px es la altura aproximada de cada fila
            var filtroWhere = "<criterio><select PageSize='" + filas.toFixed(0) + "' AbsolutePage='1' cacheControl='session' expire_minutes='2'><filtro>" + strWhere + "</filtro></select></criterio>"
           
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.instancias_Watchers
                , filtroWhere: filtroWhere
                , path_xsl: "report\\watcher\\instancias_watchers_listar.xsl"
                , salida_tipo: "adjunto"
                , ContentType: "text/html" //default opcional
                , formTarget: "listaInstanciasWatchers"
                , bloq_contenedor: $$("BODY")[0]
                , cls_contenedor: "listaInstanciasWatchers"
                , nvFW_mantener_origen: true
                , cls_contenedor_msg: " "
                /*, bloq_msg: "Cargando lista..."*/
            })
        }


        function nueva_instancia_onclick()
        {
            var win = nvFW.createWindow({
                url: "/FW/watcher/nWatcher_instancia_am.aspx?id_nvwinstancia=",
                width: "400",
                height: "150",
                top: "50",
                maximizable: false,
                minimizable: false,
                resizable: false,
                onClose: function (win) {
                    //Forzamos la carga del combo
                    //if (campos_defs.items["nro_instancias_watcher"].input_select)
                    //    campos_defs.items["nro_instancias_watcher"].input_select.length = 0                    
                    if (win.options.userData.hay_modificacion) {
                        campos_defs.clear_list('nro_instancias_watcher');
                        buscar_onclick()
                    }
                }
            });

            win.showCenter(true)
        }

        function instancia_editar(id_nvwinstancia) {
            var win = top.nvFW.createWindow({
                url: "/FW/watcher/nWatcher_abm.aspx?id_nvwinstancia=" + id_nvwinstancia,
                width: "1100",
                height: "400",
                top: "50",
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion) {
                        campos_defs.clear_list('nro_instancias_watcher');
                        buscar_onclick();
                                               
                    }
                    
                }
            })

            win.showCenter(false)
        }

        function exportar() {
            var strWhere = getStrWhere()

            var filtroWhere = "<criterio><select cacheControl='session' expire_minutes='2'><filtro>" + strWhere + "</filtro></select></criterio>"

            var string_Parametros = 
                "<parametros><columnHeaders>\
                    <table class='tb1' style='table-layout: fixed;' id='tbDetalles'>\
                        <tr class='tbLabel'>\
                            <td style='text-align: center;' colspan='10'></td>\
                            <td style='text-align: center;' colspan='4'>Log</td>\
                        </tr>\
                        <tr class='tbLabel'>\
                            <td style='text-align: center; width: 10px;'>Instancia</td>\
                            <td style='text-align: center; width: 10px;'>Watcher</td>\
                            <td style='text-align: center; width: 15px;'>Origen</td>\
                            <td style='text-align: center; width: 15px;'>Destino</td>\
                            <td style='text-align: center; width: 10px;'>Backup</td>\
                            <td style='text-align: center; width: 10px;'>Filtro</td>\
                            <td style='text-align: center; width: 10px;'>Agregar Prefijo</td>\
                            <td style='text-align: center; width: 10px;'>Agregar Posfijo</td>\
                            <td style='text-align: center; width: 10px;'>Incluir Directorios</td>\
                            <td style='text-align: center; width: 10px;'>Timeout (segundos)</td>\
                            <td style='text-align: center;'>Máquina<br /></td>\
                            <td style='text-align: center;'>Log<br /></td>\
                            <td style='text-align: center;'>Source<br /></td>\
                            <td style='text-align: center;'>Cadena de Conexión<br /></td>\
                        </tr>\
                    </table>\
                </columnHeaders></parametros>";

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.instancias_Watchers_Report
                , filtroWhere: filtroWhere
                , salida_tipo: "adjunto"
                , ContentType: "application/vnd.ms-excel"
                , filename: "nvWatcher.xls"
                , path_xsl: 'report/EXCEL_base.xsl'
                , parametros: string_Parametros
            })
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="overflow: hidden; background-color: white;">
    <table class="tb1" id="tbBuscar">
        <tr>
            <td colspan="9">
                <div id="menuLista" style="width: 100%"></div>
            </td>
            <script type="text/javascript">
                var vMenu = new tMenu('menuLista','vMenu');
                vMenu.alineacion = 'centro'
                vMenu.estilo     = 'A'
                vMenu.loadImage('nuevo','/FW/image/icons/nueva.png')
                vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Watchers</Desc></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_instancia_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenu.MostrarMenu();
            </script>
        </tr>
        <tr style="white-space:nowrap" id="trfiltros">
            <td style="width: 100%">
                <table class="tb1">
                    <tr>
                        <td class="Tit1">Instancia:</td>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("nro_instancias_watcher") %>
                        </td>
                        <td class="Tit1">Label:</td>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("label", enDB:=False, nro_campo_tipo:=104) %>
                        </td>
                        <td rowspan="2" style="width: 90px">
                            <div id="divBuscar"></div>
                            <%--<input type="button" value="Buscar" onclick="buscar_onclick()" style="width: 100%; background-image: url('/FW/image/icons/buscar.png'); background-repeat: no-repeat; background-position: 2px 3px; background-size: 12px; cursor: pointer;" title="Buscar campos defs" />--%>
                            <script type="text/javascript">
                                var vButtonItems = {};
                                vButtonItems[0] = {};
                                vButtonItems[0]["nombre"]   = "Buscar";
                                vButtonItems[0]["etiqueta"] = "Buscar";
                                vButtonItems[0]["imagen"]   = "buscar";
                                vButtonItems[0]["onclick"]  = "return buscar_onclick()";

                                var vListButton = new tListButton(vButtonItems, 'vListButton');
                                vListButton.loadImage('buscar', '/FW/image/icons/buscar.png')

                                vListButton.MostrarListButton();
                            </script>
                        </td>            
                    </tr>
                    <tr>
                        <td class="Tit1">Origen:</td>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("origen", enDB:=False, nro_campo_tipo:=104) %>
                        </td>
                        <td class="Tit1">Destino:</td>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("destino", enDB:=False, nro_campo_tipo:=104) %>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <iframe name="listaInstanciasWatchers" id="listaInstanciasWatchers" style="width: 100%; height: 100%;border: none; overflow: hidden" src="/FW/enBlanco.htm"></iframe>
</body>
</html>