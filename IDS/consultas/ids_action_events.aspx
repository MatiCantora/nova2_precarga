<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    ' Valores pasados por URL (opcional) desde el buscador de Eventos
    Me.contents("ids_actionID") = nvUtiles.obtenerValor("ids_actionID", "")
    Me.contents("operador") = nvUtiles.obtenerValor("operador", "")
    Me.contents("ids_deviceid") = nvUtiles.obtenerValor("ids_deviceid", "")
    Me.contents("uid") = nvUtiles.obtenerValor("uid", "")
    Me.contents("dni_cuit") = nvUtiles.obtenerValor("dni_cuit", "")

    Me.contents("filtro_acciones") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_actions'><campos>ids_actionID AS [id], ids_action AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_operadores") = nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos>operador AS [id], nombre_operador AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_eventos_accion") = nvXMLSQL.encXMLSQL("<criterio><select vista='verIDSAction_events'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_error_action_events") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_action_events'><campos>numError, titulo, mensaje</campos><filtro></filtro><orden></orden></select></criterio>")
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es-ar">
<head>
    <title>IDS Eventos de Acción</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        body {
            width: 100%;
            overflow: hidden;
        }
        tr.tbLabel td {
            text-align: center;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var vButtonItems = {}
        vButtonItems[0]  = {};
        vButtonItems[0].nombre   = 'Filtrar';
        vButtonItems[0].etiqueta = 'Filtrar';
        vButtonItems[0].imagen   = 'filtrar';
        vButtonItems[0].onclick  = 'return filtrarEventos();';

        var vListButton;
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">
    <div id="divFiltros" style="display: none;">
        <table class="tb1">
            <tr class="tbLabel">
                <td>Acción</td>
                <td>Fecha</td>
                <td>Operador</td>
                <td>Dispositivo</td>
                <td>Usuario</td>
                <td>DNI - CUIT</td>
                <td>Num. Error</td>
                <td>ID Origen</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td id="tdids_actionID"></td>
                <td id="tdfe_event"></td>
                <td id="tdoperador"></td>
                <td id="tdids_deviceid"></td>
                <td id="tduid"></td>
                <td id="tddni_cuit"></td>
                <td id="tdnumError"></td>
                <td id="tdid_origen"></td>
                <td>
                    <div id="divFiltrar"></div>
                </td>
            </tr>
        </table>
    </div>

    <iframe src="../enBlanco.htm" name="frameActionEvents" id="frameActionEvents" style="width: 100%; height: 75%; border: none;"></iframe>

    <script type="text/javascript">
        function isEmpty(obj)
        {
            if (!obj) return true;

            if (window.Object.entries)
                return Object.entries(obj).length === 0;
            else {
                for (var o in obj)
                    if (obj.hasOwnProperty(o))
                        return false

                return true
            }
        }
    </script>

    <script type="text/javascript">
        function setCamposDefs()
        {
            try
            {
                campos_defs.add('ids_actionID', {
                    enDB:           false,
                    nro_campo_tipo: 2,
                    filtroXML:      nvFW.pageContents.filtro_acciones,
                    filtroWhere:    '',
                    mostrar_codigo: false,
                    placeholder:    'Acción',
                    target:         'tdids_actionID'
                });

                campos_defs.add('fe_event', {
                    enDB:           false,
                    nro_campo_tipo: 103,
                    filtroWhere:    "<fe_event type='mas'>CONVERT(datetime, '%campo_value%', 103)</fe_event><fe_event type='menor'>DATEADD(dd, 1, CONVERT(datetime, '%campo_value%', 103))</fe_event>",
                    placeholder:    'dd/mm/aaaa',
                    target:         'tdfe_event'
                });

                campos_defs.add('operador', {
                    enDB:           false,
                    nro_campo_tipo: 3,
                    placeholder:    'Seleccionar Operador',
                    filtroXML:      nvFW.pageContents.filtro_operadores,
                    filtroWhere:    "<operador>%campo_value%</operador>",
                    campo_codigo:   'operador',
                    campo_desc:     'nombre_operador',
                    mostrar_codigo: false,
                    target:         'tdoperador'
                });

                campos_defs.add('ids_deviceid', { enDB: false, nro_campo_tipo: 104, placeholder: 'ID del Dispositivo', target: 'tdids_deviceid' });

                campos_defs.add('uid', {
                    enDB:           false,
                    nro_campo_tipo: 104,
                    placeholder:    'Usuario del Dispositivo',
                    filtroWhere:    "<uid type='like'>%%campo_value%%</uid>",
                    target:         'tduid'
                });

                campos_defs.add('dni_cuit', { 
                    enDB:           false,
                    nro_campo_tipo: 100,
                    placeholder:    'DNI o CUIT',
                    filtroWhere:    "<or><nro_docu>%campo_value%</nro_docu><cuit>'%campo_value%'</cuit></or>",
                    target:         'tddni_cuit'
                });

                campos_defs.add('numError', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, placeholder: 'Sel. Error', target: 'tdnumError' });
                
                var _rs = new tRS();
                _rs.addField('id', 'string');
                _rs.addField('campo', 'string');
                _rs.addRecord({ 'id': '0', 'campo': 'No' });
                _rs.addRecord({ 'id': '1', 'campo': 'Si' });

                campos_defs.items['numError'].rs = _rs;

                campos_defs.add('id_origen', {
                    enDB:           false,
                    nro_campo_tipo: 104,
                    placeholder:    'ID de Origen',
                    filtroWhere:    "<id_origen type='igual'>'%campo_value%'</id_origen>",
                    target:         'tdid_origen'
                });
            }
            catch (e)
            {
                console.error(e);
            }
        }


        function mostrarBotones()
        {
            vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage('filtrar', '/FW/image/icons/filtrar.png');
            vListButton.MostrarListButton();
        }


        function filtrarEventos()
        {
            const frameActionEvents = $('frameActionEvents');
            const filtros_height    = $('divFiltros').visible() ? $('divFiltros').getHeight() : 0;
            const pageSize          = Math.floor((frameActionEvents.getHeight() - filtros_height - 45) / 19.023);   // 45 es la altura de la cabecera de tabla más el paginador
            let orden               = 'fe_event DESC'
            let filtroWhere         = '';

            // Accion/Evento
            if (campos_defs.get_value('ids_actionID'))
                filtroWhere += "<ids_actionID type='in'>'" + campos_defs.get_value('ids_actionID').split(/,\s*/).join("','") + "'</ids_actionID>";

            // Operador
            if (campos_defs.get_value('operador'))
                filtroWhere += campos_defs.filtroWhere('operador');

            // DNI o CUIT
            if (campos_defs.get_value('dni_cuit'))
                filtroWhere += campos_defs.filtroWhere('dni_cuit');
            
            // ID Dispositivo
            if (campos_defs.get_value('ids_deviceid'))
                filtroWhere += "<ids_deviceid type='like'>" + campos_defs.get_value('ids_deviceid').replace(/\*+/g, '%') + "</ids_deviceid>"

            // Usuario
            if (campos_defs.get_value('uid'))
                filtroWhere += campos_defs.filtroWhere('uid');

            // numError
            if (campos_defs.get_value('numError'))
            {
                if (campos_defs.get_value('numError') === '0')
                    filtroWhere += "<numError>0</numError>";
                else
                    filtroWhere += "<numError type='distinto'>0</numError>";
            }

            // ID Origen
            if (campos_defs.get_value('id_origen'))
                filtroWhere += campos_defs.filtroWhere('id_origen');

            // Fecha del evento
            if (campos_defs.get_value('fe_event'))
                filtroWhere += campos_defs.filtroWhere('fe_event');

            // Wrapper del filtro where con Criterio y demás etiquetas
            filtroWhere = "<criterio><select PageSize='" + pageSize + "' AbsolutePage='1'><filtro>" + filtroWhere + "</filtro><orden>" + orden + "</orden></select></criterio>";
            
            let options = {
                filtroXML:            nvFW.pageContents.filtro_eventos_accion,
                filtroWhere:          filtroWhere,
                formTarget:           'frameActionEvents',
                path_xsl:             'report/log/action_events_list.xsl',
                bloq_contenedor:      frameActionEvents,
                bloq_msg:             'Buscando...',
                nvFW_mantener_origen: true
            };

            // Llamamos la función de Exportar Reporte mediante el Parent de la window actual, ya estamos trabajando entre 2 iframes dentro de éste Parent
            nvFW.exportarReporte(options);
            
            // Eliminar los FORM creados al exportar
            $$('form[id^=frmExportar]').each(function (frm) {
                frm.remove();
            });
        }


        function setearValoresCamposDef()
        {
            campos_defs.set_value('ids_actionID', nvFW.pageContents.ids_actionID);
            campos_defs.set_value('operador',     nvFW.pageContents.operador);
            campos_defs.set_value('ids_deviceid', nvFW.pageContents.ids_deviceid);
            campos_defs.set_value('uid',          nvFW.pageContents.uid);
            campos_defs.set_value('dni_cuit',     nvFW.pageContents.dni_cuit);
        }


        function verFiltros()
        {
            $('divFiltros').visible() ? $('divFiltros').hide() : $('divFiltros').show();
            windowOnresize();
        }


        function showDetails(ids_actionID, id_origen)
        {
            let options = {};

            switch (ids_actionID)
            {
                case 'val_img':
                    options.url   = '/IDS/consultas/image_details.aspx?id_origen=' + id_origen;
                    options.title = '<b>Detalles validación de imagen</b>';
                    break;

                case 'val_identity':
                    options.url   = '/IDS/consultas/identity_details.aspx?id_origen=' + id_origen;
                    options.title = '<b>Detalles validación de Identidad</b>';
                    break;
            }

            // No hay opciones a mostrar para la acción solicitada
            if (isEmpty(options))
            {
                var rs   = new tRS();
                rs.async = false;

                // Aquí tenemos 2 opciones:
                //  1) verificar si tenemos un Error para mostrar
                //  2) informar que no hay detalles
                rs.open({
                    filtroXML:   nvFW.pageContents.filtro_error_action_events,
                    filtroWhere: "<criterio><select><filtro><ids_actionID>'" + ids_actionID + "'</ids_actionID><id_origen>'" + id_origen + "'</id_origen><numError type='distinto'>0</numError></filtro></select></criterio>"
                });
                
                if (!rs.eof())
                {
                    var numError = rs.getdata('numError', '100');
                    var titulo   = rs.getdata('titulo', 'Error');
                    var mensaje  = rs.getdata('mensaje', 'Ocurrió un error en la acción solicitada');

                    alert('(' + numError + ') ' + mensaje, { title: '<b>' + titulo + '</b>' });
                    rs = null;
                    return;
                }

                // No hay detalles
                var ids_action = '';
                rs             = new tRS();
                rs.async       = false;

                rs.open({
                    filtroXML:   nvFW.pageContents.filtro_acciones,
                    filtroWhere: "<criterio><select><filtro><ids_actionID>'" + ids_actionID + "'</ids_actionID></filtro></select></criterio>"
                });

                if (!rs.eof())
                    ids_action = rs.getdata('campo');

                rs = null;

                window.parent.alert('No hay detalles para la acción solicitada (<b>' + ids_action + '</b>), correspondiente al ID de origen <b>' + id_origen + '</b>', {
                    title: '<b>Información</b>',
                    width: 400
                });

                return;
            }

            // Obtener el iframe Parent para usar sus proporciones de ancho y alto
            const frame_ref = top.$('frame_ref');

            // Completar las demás optiones
            options.width          = frame_ref.getWidth() * 0.8;
            options.height         = frame_ref.getHeight() * 0.8;
            options.minWidth       = 750;
            options.minHeight      = 550;
            options.destroyOnClose = true;
            options.minimizable    = true;
            options.maximizable    = true;
            options.resizable      = true;
            options.draggable      = true;

            let win = parent.nvFW.createWindow(options);
            win.showCenter(true);
        }


        function windowOnload()
        {
            windowOnresize();
            mostrarBotones();
            setCamposDefs()
            setearValoresCamposDef();
            filtrarEventos();
        }


        function windowOnresize()
        {
            try
            {
                let body_h       = $$('body')[0].getHeight();
                let divFiltros_h = $('divFiltros').visible() ? $('divFiltros').getHeight() : 0;
                let new_h        = body_h - divFiltros_h;

                $('frameActionEvents').setStyle({ height: new_h + 'px' });
            }
            catch (e) {}
        }
    </script>
</body>
</html>
