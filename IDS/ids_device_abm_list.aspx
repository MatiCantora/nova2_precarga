<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    ' Permisos y Filtros encriptados si hacen falta aqui
    Me.contents("filtro_devices") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_devices' cacheControl='Session'><campos>ids_deviceid, ids_device, ids_device_desc, creationdate, lastaccess, [enable], [uid]</campos><filtro></filtro><orden></orden></select></criterio>")
%>
<!DOCTYPE html>
<html lang="es-ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Listado de Dispositivos</title>

    <%-- ESTILOS CSS --%>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <style type="text/css">
        .tb1 .tbLabel td {
            text-align: center;
        }
    </style>

    <%-- SCRIPTS --%>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var vMenu;
        var vButtonItems = {};


        function loadMenu()
        {
            vMenu = new tMenu('divMenu', 'vMenu');
            
            // Configuraciones de estilos al objeto "Menus" global de tMenu
            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            
            // Armado de los items del menu
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar Excel</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarExcel()</Codigo></Ejecutar></Acciones></MenuItem>");

            // Cargar imagenes necesarias
            vMenu.loadImage('excel', '/FW/image/filetype/xlsx.png');
            // Mostrar el menú
            vMenu.MostrarMenu();
        }


        function loadButtons()
        {
            vButtonItems[0] = {};
            vButtonItems[0]['nombre']   = 'BuscarDispositivos';
            vButtonItems[0]['etiqueta'] = 'Buscar';
            vButtonItems[0]['imagen']   = 'buscar';
            vButtonItems[0]['onclick']  = 'return buscarDevices();';

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage('buscar', '/FW/image/icons/buscar.png');
            vListButton.MostrarListButton();
        }


        function getPageSize()
        {
            var page_size = campos_defs.get_value('PageSize');

            // Si no se seleccionó el tamaño de pagina, determinarlo con el espacio disponible
            if (!page_size)
            {
                var alto_fila      = 20.2;
                var alto_cabecera  = 24;
                var alto_paginador = 21;
                var alto_frame     = $('frameResultados').getHeight();

                var cantidad_filas = Math.floor((alto_frame - alto_cabecera - alto_paginador) / alto_fila);
                page_size          = cantidad_filas;
            }

            return page_size;
        }


        function setKeyPress()
        {
            // Setear el keyPress event para 4 campos_defs particulares:
            //  * ids_deviceid
            //  * ids_device
            //  * ids_device_descripcion  -> cambiamos este nombre porque hay conflicto con los campos_defs ocultos que llevan el prefijo "_desc"
            //                               En éste caso, "ids_device_desc" coincidia con el campo oculto de "ids_device", que lleva como ID el valor "ids_device_desc"
            //  * uid

            campos_defs.items['ids_deviceid'].input_hidden.onkeypress           = keyPressEvent;
            campos_defs.items['ids_device'].input_hidden.onkeypress             = keyPressEvent;
            campos_defs.items['ids_device_descripcion'].input_hidden.onkeypress = keyPressEvent;
            campos_defs.items['uid'].input_hidden.onkeypress                    = keyPressEvent;
        }


        function keyPressEvent(event)
        {
            if (event && event.keyCode === 13)
                buscarDevices();
        }


        function getFiltroWhere()
        {
            let filtroWhere = '';

            // Seteo del filtro para Device ID
            let ids_deviceid = campos_defs.get_value('ids_deviceid');

            if (ids_deviceid)
                filtroWhere += "<ids_deviceid type='like'>" + ids_deviceid.replace(/\*+/g, '%') + "</ids_deviceid>";

            // Fitros generales
            filtroWhere += campos_defs.filtroWhere();

            // Seteo del filtro para usuario, según el valor de "Usuario Asignado"
            var uid = campos_defs.get_value('uid');

            switch (campos_defs.get_value('uid_assigned'))
            {
                case '0': // NO
                    filtroWhere += "<uid type='isnull'></uid>";
                    break;


                case '1': // SI
                    if (!uid) {
                        alert('Debe ingresar un Usuario si sólo desea filtrar por Usuarios Asignados.');
                        return false;
                    }
                    filtroWhere += "<uid type='like'>%" + uid + "%</uid>";
                    break;


                default: // Libre
                    if (uid)
                        filtroWhere += "<uid type='like'>%" + uid + "%</uid>";
                    break;
            }

            return filtroWhere;
        }


        function buscarDevices()
        {
            // Tamaño de paginación
            var page_size = getPageSize();

            // Top de registros
            var top = campos_defs.get_value('top') !== '' ? campos_defs.get_value('top') : 300;
            
            // Armado de filtroWhere
            var filtroWhere = "<criterio><select top='" + top + "' PageSize='" + page_size + "' AbsolutePage='1'><filtro>";
            filtroWhere += getFiltroWhere();
            filtroWhere += '</filtro></select></criterio>';

            // Exportar el resultado al frame con paginación
            var opciones = {
                filtroXML:            nvFW.pageContents.filtro_devices,
                filtroWhere:          filtroWhere,
                path_xsl:             'report/device/device_list.xsl',
                contentType:          'text/html',
                formTarget:           'frameResultados',
                bloq_contenedor:      $$('body')[0],
                bloq_msg:             'Cargando dispositivos...',
                nvFW_mantener_origen: true  // Necesario para paginar con campos_head en plantilla
            };

            nvFW.exportarReporte(opciones);
        }


        function exportarExcel()
        {
            //let msg = '¿Desea exportar el resultado a Excel?';
            let msg = $('divExportarExcel').innerHTML;
            let options = {
                title:       '<b>Exportar Excel</b>',
                width:       550,
                height:      130,
                okLabel:     'Si',
                cancelLabel: 'Cancelar',
                onShow: function (w)
                {
                    $('file_name').focus();
                },
                onOk: function (w)
                {
                    let file_name = $('file_name').value;

                    if (!file_name)
                    {
                        let fecha = new Date();
                        file_name = 'devices_list__';
                        file_name += fecha.getFullYear();                               // Año
                        file_name += nvFW.rellenar_izq(fecha.getMonth() + 1, 2, '0');   // Mes
                        file_name += nvFW.rellenar_izq(fecha.getDate(), 2, '0');        // Día
                        file_name += nvFW.rellenar_izq(fecha.getHours(), 2, '0');       // Hora
                        file_name += nvFW.rellenar_izq(fecha.getMinutes(), 2, '0');     // Minutos
                        file_name += nvFW.rellenar_izq(fecha.getSeconds(), 2, '0');     // Segundos
                    }

                    // Cabecera para el Excel de exportación
                    const headers = '<parametros>\
                                        <columnHeaders>\
                                            <table>\
                                                <tr>\
                                                    <td>ID Dispositivo</td>\
                                                    <td>Nombre</td>\
                                                    <td>Descripción</td>\
                                                    <td>Fecha Alta</td>\
                                                    <td>Último Acceso</td>\
                                                    <td>Habilitado</td>\
                                                    <td>Usuario</td>\
                                                </tr>\
                                            </table>\
                                        </columnHeaders>\
                                    </parametros>';

                    // EXPORTACION
                    nvFW.exportarReporte({
                        filtroXML:   nvFW.pageContents.filtro_devices,
                        filtroWhere: "<criterio><select><filtro>" + getFiltroWhere() + "</filtro></select></criterio>",
                        path_xsl:    'report/EXCEL_base.xsl',
                        salida_tipo: 'adjunto',
                        filename:    file_name + '.xls',
                        formTarget:  'frameExcel',
                        ContentType: 'application/vnd.ms-excel',
                        parametros:  headers
                    });

                    w.close();
                }
            };

            nvFW.confirm(msg, options);
        }


        /**
         * Funcion para manejar el comportamiento del campode usuarios
         */
        function uid_assigned_onchange()
        {
            let valor = campos_defs.get_value('uid_assigned');

            if (!valor) {
                campos_defs.habilitar('uid', true);
            }
            else
            {
                switch (valor)
                {
                    case '0':
                        campos_defs.set_value('uid', '');
                        campos_defs.habilitar('uid', false);
                        break;

                    case '1':
                        campos_defs.habilitar('uid', true);
                        break;
                }
            }
        }


        function windowOnload()
        {
            nvFW.enterToTab = false;
            loadMenu();
            loadButtons()
            setKeyPress();
            windowOnresize();
            buscarDevices();
        }


        function windowOnresize()
        {
            try
            {
                var body_h      = $$('body')[0].getHeight();
                var divMenu_h   = 24;                           // Siempre tienen 24px de alto los menues.
                var tbFiltros_h = $('tbFiltros').getHeight();

                var frame_h     = body_h - divMenu_h - tbFiltros_h;
                $('frameResultados').setStyle({ 'height': frame_h + 'px' });
            }
            catch (e) {}
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()" style="width: 100%; height: 100%; overflow: hidden;">
    
    <!-- Menu principal -->
    <div id="divMenu"></div>

    <!-- Filtros de busqueda -->
    <table class="tb1" id="tbFiltros">
        <tr class="tbLabel">
            <td style="width: 250px;">ID Dispositivo</td>
            <td style="width: 230px;">Nombre</td>
            <td>Descripción</td>
            <td style="width: 140px;">Fecha Alta</td>
            <td style="width: 140px;">Fecha Último Acceso</td>
            <td style="width: 90px;">Habilitado</td>
            <td style="width: 90px;" title="Usuario Asignado">Usr Asig.</td>
            <td>Usuario</td>
            <td style="width: 100px;" title="Cantidad de Registros por Página">Cant. RPP</td>
            <td style="width: 100px;" title="Top de Registros">Top Reg.</td>
            <td style="width: 100px;">&nbsp;</td>
        </tr>
        <tr>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 104//,
                        //filtroWhere:    "<ids_deviceid type='igual'>'%campo_value%'</ids_deviceid>"
                    };

                    campos_defs.add('ids_deviceid', options);
                </script>
            </td>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 104,
                        filtroWhere:    "<ids_device type='like'>%%campo_value%%</ids_device>"
                    };

                    campos_defs.add('ids_device', options);
                </script>
            </td>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 104,
                        filtroWhere:    "<ids_device_desc type='like'>%%campo_value%%</ids_device_desc>"
                    };

                    // IMPORTANTE
                    // El nombre del campo_def lo cambiamos levemente ya que colisiona con el oculto de "ids_device", que es "ids_device_desc"
                    campos_defs.add('ids_device_descripcion', options);
                </script>
            </td>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 103,
                        filtroWhere:    "<creationdate type='mayor'>CONVERT(DATETIME, '%campo_value%', 103)</creationdate>"
                    };

                    campos_defs.add('creationdate', options);
                </script>
            </td>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 103,
                        filtroWhere:    "<lastaccess type='mayor'>CONVERT(DATETIME, '%campo_value%', 103)</lastaccess>"
                    };

                    campos_defs.add('lastaccess', options);
                </script>
            </td>
            <td style="text-align: center;">
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 1,
                        filtroWhere:    "<enable type='in'>%campo_value%</enable>",
                        mostrar_codigo: false
                    };

                    campos_defs.add('enable', options);

                    // Armar un RS para un combo sin DB
                    var rs           = new tRS();
                    rs.addField("id", "string");
                    rs.addField("campo", "string");
                    rs.addRecord({ id: "1", campo: "SI" });
                    rs.addRecord({ id: "0", campo: "NO" });

                    // Agregar el RS al campo_def
                    campos_defs.items['enable'].rs = rs;
                </script>
            </td>
            <td style="text-align: center;">
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 1,
                        filtroWhere:    '',
                        mostrar_codigo: false
                    };

                    campos_defs.add('uid_assigned', options);

                    // Armar un RS para un combo sin DB
                    var rs = new tRS();
                    rs.addField("id", "string");
                    rs.addField("campo", "string");
                    rs.addRecord({ id: "1", campo: "SI" });
                    rs.addRecord({ id: "0", campo: "NO" });

                    // Agregar el RS al campo_def
                    campos_defs.items['uid_assigned'].rs = rs;
                    campos_defs.items['uid_assigned'].onchange = uid_assigned_onchange;
                </script>
            </td>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 104
                    };

                    campos_defs.add('uid', options);
                </script>
            </td>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 1,
                        filtroWhere:    "",
                        mostrar_codigo: false
                    };

                    campos_defs.add('PageSize', options);

                    // Armar un RS para un combo sin DB
                    var rs           = new tRS();
                    rs.format        = "getterror";
                    rs.format_tError = "json";
                    rs.addField("id", "string");
                    rs.addField("campo", "string");
                    rs.addRecord({ id: "10", campo: "10" });
                    rs.addRecord({ id: "25", campo: "25" });
                    rs.addRecord({ id: "50", campo: "50" });
                    rs.addRecord({ id: "75", campo: "75" });
                    rs.addRecord({ id: "100", campo: "100" });

                    // Agregar el RS al campo_def
                    campos_defs.items['PageSize'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 1,
                        filtroWhere:    "",
                        mostrar_codigo: false
                    };

                    campos_defs.add('top', options);

                    // Armar un RS para un combo sin DB
                    var rs           = new tRS();
                    rs.addField("id", "string");
                    rs.addField("campo", "string");
                    rs.addRecord({ id: "100", campo: "100" });
                    rs.addRecord({ id: "300", campo: "300" });
                    rs.addRecord({ id: "500", campo: "500" });
                    rs.addRecord({ id: "1000", campo: "1000" });

                    // Agregar el RS al campo_def
                    campos_defs.items['top'].rs = rs;
                    campos_defs.set_value('top', '300');
                </script>
            </td>
            <td>
                <div id="divBuscarDispositivos"></div>
            </td>
        </tr>
    </table>

    <!-- Frame de resultados -->
    <iframe src="enBlanco.htm" name="frameResultados" id="frameResultados" style="width: 100%; height: 80%; border: none;"></iframe>

    <!-- Frame para exportar el Excel (NO VISIBLE) -->
    <iframe src="enBlanco.htm" name="frameExcel" id="frameExcel" style="display: none;"></iframe>

    <!-- Estructura para Nombre del archivo Excel a Exportar -->
    <div id="divExportarExcel" style="display: none;">
        <div style="text-align: center;">
            <p style="margin: 0; padding: 10px;">Ingrese el nombre para el archivo Excel a exportar. De otro modo se asignará por defecto un timestamp.</p>
            <input type="text" name="file_name" id="file_name" value="" style="width: 100%;" placeholder="devices_list__20200807143527" />
        </div>
    </div>
</body>
</html>
