<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    ' Obtener valores de cliente seleccionado desde el operador
    Dim operador As nvPages.tnvOperadorIDS = nvFW.nvApp.getInstance().operador
    Dim ids_cli_id As Integer = operador.ids_cli_id

    ' Búsqueda de RECURSOS del Cliente actual
    Dim resources As New trsParam
    Dim query As String = String.Format("SELECT ids_res_id, ids_resource FROM ids_resources WHERE ids_cli_id={0}", ids_cli_id)
    Dim rs As ADODB.Recordset = Nothing

    Try
        rs = nvDBUtiles.DBExecute(query)

        While Not rs.EOF
            resources(rs.Fields("ids_res_id").Value) = rs.Fields("ids_resource").Value
            rs.MoveNext()
        End While

        nvDBUtiles.DBCloseRecordset(rs)
    Catch ex As Exception
    End Try

    Me.contents("filtro_configurations") = nvXMLSQL.encXMLSQL("<criterio><select vista='verIDS_res_config' cacheControl='session'><campos>*</campos><filtro><ids_cli_id>" & ids_cli_id & "</ids_cli_id></filtro></select></criterio>")
    Me.contents("filtro_email_configs") = nvXMLSQL.encXMLSQL("<criterio><select vista='mail_cfgs'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_events") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_events'><campos>ids_event_id AS [id], ids_event AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_passwords") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_pwdcfgs'><campos>ids_pwdcfg_id AS [id], ids_pwdcfg AS [campo]</campos><filtro><ids_cli_id>" & ids_cli_id & "</ids_cli_id></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_estados") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_status'><campos>ids_status_id AS [id], ids_status AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")

    Me.contents("resources") = resources
    Me.contents("ids_cliente") = operador.ids_cliente
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <title>ABM Validaciones</title>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <style type="text/css">
        body {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        #tbMain {
            padding: 0;
            margin: 0;
            border-collapse: collapse;
        }
        #tbMain > tbody > tr > td {
            vertical-align: top;
            box-shadow: none;
        }
        #tbMain td#td_move {
            width: 3px;
            background-color: #6f6f71;
            border-radius: 0;
            cursor: w-resize;
            user-select: none;
        }
        .tb1 tr.tbLabel td {
            text-align: center;
        }
        #tbFiltros {
            border-bottom: 3px solid #6f6f71;
            border-bottom-right-radius: 0;
            border-bottom-left-radius: 0;
        }
        #tbConfigs tr:not(:first-child) td {
            color: #333333;
        }
        span.ver {
            cursor: pointer;
            font-weight: bold;
            text-overflow: ellipsis;
            overflow: hidden;
            white-space: nowrap;
            color: #000000;
        }
        tr.status_pendiente > td {
            background-color: #ffd80055;
        }
        tr.status_suspendido > td {
            background-color: #ff6a0055;
        }
        tr.status_baja > td {
            background-color: #ff000055;
        }
        span.icon {
            display: inline-block;
            width: 16px; 
            height: 16px;
            vertical-align: middle;
        }
        span.icon.activo {
            background: url('/IDS/image/icons/activo.png');
        }
        span.icon.baja {
            background: url('/IDS/image/icons/baja.png');
        }
        span.icon.pendiente {
            background: url('/IDS/image/icons/pendiente.png');
        }
        span.icon.suspendido {
            background: url('/IDS/image/icons/suspendido.png');
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        function isEmpty(obj)
        {
            if (!obj) return true;

            if (window.Object.entries)
                return Object.entries(obj).length === 0;
            else
            {
                for (var o in obj)
                    if (obj.hasOwnProperty(o))
                        return false

                return true
            }
        }
    </script>

    <script type="text/javascript">
        var win               = nvFW.getMyWindow();
        var settings          = [];
        var ids_cliente       = nvFW.pageContents.ids_cliente;
        var ids_res_id        = null;
        var last_res_selected = null;
        var vMenu;
        var body;
        var vButtonItems      = {};


        function windowOnresize()
        {
            try
            {
                var body_h = $$('body')[0].getHeight();
                var menu_h = 24;

                $('tbMain').style.height = body_h - menu_h + 'px';
            }
            catch (e) 
            {
                console.error(e);
            }
        }


        function loadMenu()
        {
            vMenu = new tMenu('divMenu', 'vMenu');

            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Menu Validaciones</Desc></MenuItem>");
            //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva()</Codigo></Ejecutar></Acciones></MenuItem>");

            //vMenu.loadImage('nuevo', '/IDS/image/icons/nueva.png');
            vMenu.MostrarMenu();
        }


        function loadButtons()
        {
            vButtonItems[0] = {};
            vButtonItems[0]['nombre']   = 'Filtrar';
            vButtonItems[0]['etiqueta'] = 'Filtrar';
            vButtonItems[0]['imagen']   = 'filtro';
            vButtonItems[0]['onclick']  = 'return loadClientResources();';

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage('filtro', '/FW/image/icons/filtrar.png');
            vListButton.MostrarListButton();
        }


        function loadResources()
        {
            var resources = nvFW.pageContents.resources;
            var html = '<table class="tb1 highlightEven highlightTROver layout_fixed">' +
                         '<tbody>' +
                           '<tr class="tbLabel">' +
                             '<td style="width: 20px;">&nbsp;</td>' +
                             '<td>Recurso</td>' +
                           '</tr>';

            if (resources)
            {
                for (res in resources)
                {
                    if (resources.hasOwnProperty(res))
                    {
                        html += '<tr>\
                                    <td style="text-align: center;">\
                                        <input type="radio" name="ids_res_id" id="' + res + '" value="' + res + '" \
                                           style="margin: 0; vertical-align: middle; margin-bottom: 1px; cursor: pointer;" \
                                           onclick="setResourceId(event, this)" \
                                           title="' + resources[res] + '" \
                                           data-ids-resource="' + resources[res] + '" />\
                                    </td>\
                                    <td title="' + resources[res] + '">&nbsp;' + resources[res] + '</td>\
                                </tr>';
                    }
                }
            }

            html += '</tbody></table>';
            $('tdLeft').innerHTML = html;
        }


        function setResourceId(event, element)
        {
            if (element.value)
            {
                if (element.id !== last_res_selected)
                {
                    last_res_selected = element.id;
                    ids_res_id        = element.value;
                    //settings          = [];
                    loadClientResources();
                }
            }
        }


        function selectResource(id_radio)
        {
            if (id_radio)
                $$('input[type=radio]#' + id_radio).click();
            else
                $$('input[type=radio]')[0].click();
        }


        function getResourceSelected()
        {
            var radio = $$('input[name=ids_res_id]:checked');

            if (radio.length === 0 || radio.length > 1)
                return null;

            return radio[0];
        }


        function windowOnload()
        {
            body = $$('body')[0];
            win.setTitle('<b>ABM Validaciones ' + ids_cliente + '</b>');
            loadMenu();
            loadButtons();
            windowOnresize();
            //setearSelector();
            loadResources();
            selectResource();
        }



        /**
         * Carga todas las configuraciones de seguridad a partir del Cliente y Recurso seleccionados
         */
        function loadClientResources()
        {
            nvFW.bloqueo_activar($('tdData'), 'bloq_recurso', 'Cargando...');
            settings = [];

            var rs = new tRS();
            rs.async = true;


            rs.onComplete = function (resp)
            {
                if (resp.recordcount)
                {
                    var ids_valcfg_id = null;

                    for (var i = 0; i < resp.recordcount; i++)
                    {
                        ids_valcfg_id = resp.getdata('ids_valcfg_id');

                        //-----------------------------------------------------
                        // Cargar todos los valores de configuración
                        //-----------------------------------------------------
                        if (!settings[ids_valcfg_id])
                        {
                            settings[ids_valcfg_id] = {
                                ids_valcfg_id:           ids_valcfg_id,
                                ids_valcfg:              resp.getdata('ids_valcfg'),
                                req_email:               resp.getdata('req_email').toString().toLowerCase() === "true",
                                req_phone:               resp.getdata('req_phone').toString().toLowerCase() === "true",
                                req_verazID:             resp.getdata('req_verazID').toString().toLowerCase() === 'true',
                                req_nosisID:             resp.getdata('req_nosisID').toString().toLowerCase() === 'true',
                                req_dni_frente:          resp.getdata('req_dni_frente').toString().toLowerCase() === 'true',
                                req_dni_dorso:           resp.getdata('req_dni_dorso').toString().toLowerCase() === 'true',
                                req_selfie:              resp.getdata('req_selfie').toString().toLowerCase() === 'true',
                                val_dni_selfie:          resp.getdata('val_dni_selfie').toString().toLowerCase() === 'true',
                                val_pre_selfie:          resp.getdata('val_pre_selfie').toString().toLowerCase() === 'true',
                                val_bio_vida:            resp.getdata('val_bio_vida').toString().toLowerCase() === 'true',
                                val_renaper_basico:      resp.getdata('val_renaper_basico').toString().toLowerCase() === 'true',
                                val_renaper_multifactor: resp.getdata('val_renaper_multifactor').toString().toLowerCase() === 'true',
                                req_cbu_mov:             resp.getdata('req_cbu_mov').toString().toLowerCase() === 'true',
                                req_facebook:            resp.getdata('req_facebook').toString().toLowerCase() === 'true',
                                req_google:              resp.getdata('req_google').toString().toLowerCase() === 'true',
                                req_twitter:             resp.getdata('req_twitter').toString().toLowerCase() === 'true',
                                req_instagram:           resp.getdata('req_instagram').toString().toLowerCase() === 'true',
                                bpm_process:             resp.getdata('bpm_process') ? parseInt(resp.getdata('bpm_process')) : -1,
                                ids_status_id:           resp.getdata('ids_status_id'),
                                ids_status:              resp.getdata('ids_status'),
                                ids_valtype_version:     resp.getdata('ids_valtype_version')
                            };
                        }

                        //-----------------------------------------------------
                        // Configuración de CONTRASEÑA (obligatorio)
                        //-----------------------------------------------------
                        if (!settings[ids_valcfg_id].config_pass)
                        {
                            settings[ids_valcfg_id].config_pass = {
                                ids_pwdcfg_id:            resp.getdata('ids_pwdcfg_id'),
                                ids_pwdcfg:               resp.getdata('ids_pwdcfg'),
                                pwd_minlength:            resp.getdata('pwd_minlength'),
                                pwd_maxlength:            resp.getdata('pwd_maxlength'),
                                pwd_includeUpperCase:     resp.getdata('pwd_includeUpperCase'),
                                pwd_includeLowerCase:     resp.getdata('pwd_includeLowerCase'),
                                pwd_includeSpecialChars:  resp.getdata('pwd_includeSpecialChars'),
                                pwd_maxPasswordAge:       resp.getdata('pwd_maxPasswordAge'),
                                pwd_minPasswordAge:       resp.getdata('pwd_minPasswordAge'),
                                pwd_LockoutThreshold:     resp.getdata('pwd_LockoutThreshold'),
                                pwd_LockoutDuration:      resp.getdata('pwd_LockoutDuration'),
                                pwd_LockoutObsWin:        resp.getdata('pwd_LockoutObsWin'),
                                pwd_historyDays:          resp.getdata('pwd_historyDays'),
                                pwd_version:              resp.getdata('pwd_version')
                            };
                        }
                        
                        //-----------------------------------------------------
                        // Configuración de EVENTO (obligatorio)
                        //-----------------------------------------------------
                        if (!settings[ids_valcfg_id].config_event)
                        {
                            settings[ids_valcfg_id].config_event = {
                                ids_event_id: resp.getdata('ids_event_id'),
                                ids_event:    resp.getdata('ids_event')
                            };
                        }

                        //-------------------------------------------------
                        // Configuración de EMAIL (opcional)
                        //-------------------------------------------------
                        if (!settings[ids_valcfg_id].config_email) 
                        {
                            settings[ids_valcfg_id].config_email = {
                                req_email_cfg_id:       resp.getdata('req_email_cfg_id') ? resp.getdata('req_email_cfg_id') : null,
                                mail_cfgs:              resp.getdata('mail_cfgs') ? resp.getdata('mail_cfgs') : null,
                                req_email_codeLength:   resp.getdata('req_email_codeLength') ? resp.getdata('req_email_codeLength') : null,
                                req_email_codeTimeout:  resp.getdata('req_email_codeTimeout') ? resp.getdata('req_email_codeTimeout') : null,
                                req_email_codeMaxFails: resp.getdata('req_email_codeMaxFails') ? resp.getdata('req_email_codeMaxFails'): null,
                                Body:                   resp.getdata('Body') ? resp.getdata('Body') : null,
                                Subject:                resp.getdata('Subject') ? resp.getdata('Subject') : null,
                                FromTitle:              resp.getdata('FromTitle') ? resp.getdata('FromTitle') : null,
                                cco:                    resp.getdata('cco') ? resp.getdata('cco') : null,
                                mail_server_id:         resp.getdata('mail_server_id') ? resp.getdata('mail_server_id') : null,
                                mail_server:            resp.getdata('mail_server') ? resp.getdata('mail_server') : null,
                                smtp_server:            resp.getdata('smtp_server') ? resp.getdata('smtp_server') : null,
                                smtp_port:              resp.getdata('smtp_port') ? resp.getdata('smtp_port') : null,
                                smtp_user:              resp.getdata('smtp_user') ? resp.getdata('smtp_user') : null,
                                smtp_pwd:               resp.getdata('smtp_pwd') ? resp.getdata('smtp_pwd') : null,
                                smtp_secure:            resp.getdata('smtp_secure') ? resp.getdata('smtp_secure') : null
                            };
                        }

                        //-------------------------------------------------
                        // Configuración de TELEFONO (opcional)
                        //-------------------------------------------------
                        if (!settings[ids_valcfg_id].config_phone)
                        {
                            settings[ids_valcfg_id].config_phone = {
                                req_phone_text:        resp.getdata('req_phone_text') ? resp.getdata('req_phone_text') : null,
                                req_phone_codeLength:  resp.getdata('req_phone_codeLength') ? resp.getdata('req_phone_codeLength') : null,
                                req_phone_codeTimeout: resp.getdata('req_phone_codeTimeout') ? resp.getdata('req_phone_codeTimeout') : null
                            };
                        }

                        resp.movenext();
                    }
                }

                drawClientResources();
                nvFW.bloqueo_desactivar(null, 'bloq_recurso');
            }

            rs.onError = function (resp)
            {
                nvFW.bloqueo_desactivar(null, 'bloq_recurso');
            }

            var filtros = "<ids_res_id>'" + ids_res_id + "'</ids_res_id>";
            
            // Eventos
            if (campos_defs.get_value('ids_event_id'))
                filtros += "<ids_event_id type='in'>'" + campos_defs.get_value('ids_event_id').split(', ').join("','") + "'</ids_event_id>";

            // Estados
            if (campos_defs.get_value('ids_status_id'))
                filtros += "<ids_status_id type='in'>'" + campos_defs.get_value('ids_status_id').split(', ').join("','") + "'</ids_status_id>";

            // Todos los demas filtros desde campos_defs
            filtros += campos_defs.filtroWhere();
            
            var filtroWhere = "<criterio><select><filtro>" + filtros + "</filtro></select></criterio>";

            rs.open({
                filtroXML: nvFW.pageContents.filtro_configurations,
                filtroWhere: filtroWhere
            });
        }


        function drawClientResources()
        {
            var table_html = '';
            
            if (isEmpty(settings))
            {
                // No hay configuracion para el recurso seleccionado
                var ids_resource = getResourceSelected().getAttribute("data-ids-resource");
                table_html += '<div style="max-width: 500px; margin: 0 auto; padding: 10px 0; text-align: center;">' +
                                '<p style="margin: 0 auto; padding: 10px 0; font-size: 1.5em;">El recurso <b>' + ids_resource + '</b> no contiene una configuración asociada.</p>' +
                                '<p style="margin: 0 auto; padding: 10px 0; font-size: 1.5em;">Si aplicó algún filtro, intente con otro valor o quitándolo.</p>' +
                                '<img alt="agregar" src="/FW/image/icons/agregar.ico" style="width: 16px; cursor: pointer;" title="Agregar configuración" onclick="agregarConfiguracion()">' +
                              '</div>';

                $('divData').innerHTML = table_html;
                return;
            }
            
            table_html += '<table class="tb1 highlightTROver highlightOdd layout_fixed" id="tbConfigs">'
            table_html += '<tr class="tbLabel center">'
            table_html +=   '<td style="width: 20px;" title="Estado">&nbsp;</td>' +
                            '<td style="min-width: 100px;" title="Configuración">Configuración</td>' +
                            '<td style="min-width: 100px;">Evento</td>' +
                            '<td style="min-width: 120px;" title="Configuración de Contraseñas">Password</td>' +
                            '<td title="Configuración de Email">Email</td>' +
                            '<td title="Configuración de Teléfono">Phone</td>' +
                            '<td title="Configuración de Veraz">Veraz</td>' +
                            '<td>NOSIS</td>' +
                            '<td>DNI Frente</td>' +
                            '<td>DNI Dorso</td>' +
                            '<td>Selfie</td>' +
                            '<td>DNI+Selfie</td>' +
                            '<td>Pre-Selfie</td>' +
                            '<td>Bio-vida</td>' +
                            '<td title="ReNaPer básico">ReNaPer</td>' +
                            '<td title="ReNaPer Multifactor">ReNaPer M</td>' +
                            '<td title="Movimiento de CBU">CBU Mov</td>' +
                            '<td style="width: 45px;">BPM</td>' +
                            '<td style="width: 45px;" title="Facebook">FB</td>' +
                            '<td style="width: 45px;" title="Google">GL</td>' +
                            '<td style="width: 45px;" title="Twitter">TW</td>' +
                            '<td style="width: 45px;" title="Instagram">IG</td>' +
                            '<td style="width: 20px;">&nbsp;</td>' +
                            '</tr>';

            var _data = null;

            for (var ids_valcfg_id in settings)
            {
                if (settings.hasOwnProperty(ids_valcfg_id))
                {
                    _data = settings[ids_valcfg_id];

                    table_html += '<tr>';
                    table_html += '<td title="Estado ' + _data.ids_status.toString().toUpperCase() + '" style="text-align: center;"><span class="icon ' + _data.ids_status + '"></span></td>';
                    table_html += '<td title="' + ids_valcfg_id + '">' + ids_valcfg_id + '</td>';
                    table_html += '<td title="' + _data.config_event.ids_event + '">' + _data.config_event.ids_event + '</td>';
                    table_html += '<td title="Ver config ' + _data.config_pass.ids_pwdcfg + '"><span class="ver" onclick="verConfigPassword(\'' + ids_valcfg_id + '\')">' + _data.config_pass.ids_pwdcfg + '</span></td>';

                    // REQUIERE EMAIL
                    if (_data.req_email)
                        table_html += '<td class="center" title="Ver config Email"><span class="ver" onclick="verConfigEmail(\'' + ids_valcfg_id + '\')">SI</span></td>';
                    else
                        table_html += '<td class="center">NO</td>';

                    // REQUIERE TELEFONO
                    if (_data.req_phone)
                        table_html += '<td class="center" title="Ver config Teléfono"><span class="ver" onclick="verConfigPhone(\'' + ids_valcfg_id + '\')">SI</span></td>';
                    else
                        table_html += '<td class="center">NO</td>';

                    // REQUIERE VERAZ ID
                    if (_data.req_verazID)
                        table_html += '<td class="center" title="Ver configuración VerazID"><span class="ver" onclick="alert(\'Config verazId\')">SI</span></td>';
                    else
                        table_html += '<td class="center">NO</td>';

                    table_html += '<td class="center">' + (_data.req_nosisID ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_dni_frente ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_dni_dorso ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_selfie ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.val_dni_selfie ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.val_pre_selfie ? 'SI': 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.val_bio_vida ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.val_renaper_basico ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.val_renaper_multifactor ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_cbu_mov ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.bpm_process !== -1 ? _data.bpm_process : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_facebook ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_google ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_twitter ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' + (_data.req_instagram ? 'SI' : 'NO') + '</td>';
                    table_html += '<td class="center">' +
                                    '<img alt="editar" src="/FW/image/icons/editar.png" title="Editar ' + ids_valcfg_id + '" style="cursor: pointer;" ' +
                                        'onclick="editarConfiguración(\'' + ids_valcfg_id + '\')">' +
                                  '</td>';

                    table_html += '</tr>';
                }
            }

            table_html += '</table>';
            table_html += '<div style="padding: 10px 0; text-align: center;">' +
                            '<img alt="agregar" src="/FW/image/icons/agregar.ico" style="width: 16px; cursor: pointer;" title="Agregar configuración" onclick="agregarConfiguracion()">' +
                          '</div>';

            $('divData').innerHTML = table_html;
        }


        function agregarConfiguracion()
        {
            if (ids_res_id)
            {
                var radio_selected = getResourceSelected();
                var ids_resource   = radio_selected.getAttribute('data-ids-resource');

                var win_add = nvFW.createWindow({
                    url:            'ids_config_abm.aspx?ids_res_id=' + ids_res_id, // + '&ids_event_id=' + ids_event_id,
                    title:          'Agregar config para recurso <b>' + ids_resource + '</b>',
                    width:          win.width * 0.8,    // Asignar el 80% del ancho la ventana actual
                    height:         win.height * 0.9,   // Asignar el 90% del alto la ventana actual
                    destroyOnClose: true,
                    onClose:        agregarConfiguracion_onclose
                });

                win_add.options.userData = {
                    reload:       false,
                    ids_resource: ids_resource
                };
                win_add.showCenter(true);
            }
        }



        function agregarConfiguracion_onclose(win)
        {
            var data = win.options.userData;

            if (data && data.reload)
            {
                // En este caso el valor del RELOAD es el ID de la config agregada
                //var reload_ids_valcfg_id = data.reload_ids_valcfg_id ? data.reload_ids_valcfg_id : null;
                //loadClientResources(reload_ids_valcfg_id);
                loadClientResources();
            }
        }



        function editarConfiguración(ids_valcfg_id)
        {
            if (ids_res_id)
            {
                var radio_selected = getResourceSelected();
                var ids_resource   = radio_selected.getAttribute('data-ids-resource');
                var ids_event_id   = settings[ids_valcfg_id].config_event.ids_event_id;

                var win_add = nvFW.createWindow({
                    url:            'ids_config_abm.aspx?ids_res_id=' + ids_res_id + '&ids_event_id=' + ids_event_id,
                    title:          'Editando config <b>' + ids_valcfg_id + '</b> del recurso <b>' + ids_resource + '</b>',
                    width:          win.width * 0.8,    // Asignar el 80% del ancho la ventana actual
                    height:         win.height * 0.9,   // Asignar el 90% del alto la ventana actual
                    destroyOnClose: true,
                    onClose:        editarConfiguracion_onclose
                });

                win_add.options.userData = {
                    modo:          'edit',
                    ids_resource:  ids_resource,
                    reload:        false,
                    ids_valcfg_id: ids_valcfg_id,
                    settings:      settings[ids_valcfg_id]
                };
                win_add.showCenter(true);
            }
        }



        function editarConfiguracion_onclose(win)
        {
            var data = win.options.userData;
            
            if (data && data.reload)
            {
                //var reload_ids_valcfg_id = data.reload_ids_valcfg_id ? data.reload_ids_valcfg_id : null;
                //loadClientResources(reload_ids_valcfg_id);
                loadClientResources();
            }
        }



        function verConfigPassword(ids_valcfg_id)
        {
            var valores = settings[ids_valcfg_id].config_pass;

            if (valores)
            {
                var win_pass = nvFW.createWindow({
                    url:            'ids_config_password.aspx?ids_pwdcfg_id=' + valores.ids_pwdcfg_id + '&solo_consulta=1',
                    title:          '<b>Config Password</b>',
                    width:          700,
                    height:         500,
                    minWidth:       400,
                    minHeight:      300,
                    destroyOnClose: true
                });

                win_pass.options.userData = valores;
                win_pass.showCenter(true);
            }
        }


        // Ésta visualización es de sólo lectura
        function verConfigEmail(ids_valcfg_id)
        {
            var config_email = settings[ids_valcfg_id].config_email;

            if (config_email)
            {
                var win_mail = nvFW.createWindow({
                    title:          "<b>Config validación email</b>",
                    width:          550,
                    height:         120,
                    destroyOnClose: true,
                    resizable:      false,
                    onShow: function (w)
                    {
                        // Asignar los Valores
                        $('req_email_codeLength').value   = config_email.req_email_codeLength ? config_email.req_email_codeLength : '';
                        $('req_email_codeTimeout').value  = config_email.req_email_codeTimeout ? config_email.req_email_codeTimeout : '';
                        $('req_email_codeMaxFails').value = config_email.req_email_codeMaxFails ? config_email.req_email_codeMaxFails : '';

                        if (!config_email.req_email_cfg_id)
                            $('req_email_cfg_id').value = '';
                        else
                        {
                            var rs = new tRS();
                            rs.async = false;
                            rs.open({
                                filtroXML: nvFW.pageContents.filtro_email_configs,
                                filtroWhere: "<criterio><select><filtro><mail_cfgs_id>'" + config_email.req_email_cfg_id + "'</mail_cfgs_id></filtro></select></criterio>"
                            });

                            if (!rs.eof()) $('req_email_cfg_id').value = rs.getdata('mail_cfgs');
                            rs = null;
                        }
                    }
                });

                win_mail.setHTMLContent($('divEmailConfig').innerHTML);
                win_mail.options.userData = config_email;
                win_mail.showCenter(true);
            }
        }


        function verConfigPhone(ids_valcfg_id)
        {
            var config_phone = settings[ids_valcfg_id].config_phone;

            if (config_phone)
            {
                var win_phone = nvFW.createWindow({
                    title:          "<b>Config validación de teléfono</b>",
                    width:          550,
                    height:         220,
                    destroyOnClose: true,
                    onShow: function (w)
                    {
                        // Asignar los valores
                        $('req_phone_text').value        = config_phone.req_phone_text ? config_phone.req_phone_text : '';
                        $('req_phone_codeLength').value  = config_phone.req_phone_codeLength ? config_phone.req_phone_codeLength : '';
                        $('req_phone_codeTimeout').value = config_phone.req_phone_codeTimeout ? config_phone.req_phone_codeTimeout : '';
                    }
                });

                win_phone.setHTMLContent($('divPhoneConfig').innerHTML);
                win_phone.options.userData = config_phone;
                win_phone.showCenter(true);
            }
        }


        // Funciones para los eventos de Resize
        function resizeInicio()
        {
            var td_move  = $('td_move');
            var oDIV_rec = null;

            if ($('div_hide') === null)
            {
                var strHTML = '<div id="div_hide" style="width: 100%; height: 100%; position: absolute; z-index: 1000; float: left; background-color: gray;"></div>';
                body.insert({ top: strHTML });
                var oDIV = $("div_hide");
                oDIV.style.opacity = 0.1;
                
                strHTML = '<div id="div_rec" style="position: absolute; z-index: 1000; float: left; background-color: #539bf1;"></div>';
                body.insert({ top: strHTML })
                oDIV_rec = $("div_rec");
                oDIV_rec.style.opacity = 0.5;
                oDIV_rec.setStyle({ width: td_move.getWidth() + 'px', height: td_move.getHeight() + 'px' });
            }
            else
            {
                $('div_hide').show();
                oDIV_rec = $('div_rec');
                oDIV_rec.show();
            }

            // Clonar la posicion de "td_move"
            var bounding = td_move.getBoundingClientRect();
            oDIV_rec.setStyle({
                top:    bounding.top + 'px',
                left:   bounding.left + 'px',
                width:  bounding.width + 'px',
                height: bounding.height + 'px'
            });
            //Element.clonePosition(oDIV_rec, td_move);

            body.setStyle({ cursor: 'w-resize' });

            // Agregar los eventos de mouse al Body
            body.addEventListener('mousemove', resizeMousemove, false);
            body.addEventListener('mouseup', resizeFin, false);
        }


        function resizeFin()
        {
            var oDIV_rec = $('div_rec');
            $('tdLeft').setStyle({ width: oDIV_rec.getStyle('left') }); // getStyle('left') devuelve el valor con 'px' al final. Ejemplo: '385px'

            var oDIV = $("div_hide");
            oDIV.hide();
            oDIV_rec.hide();
            
            body.setStyle({ cursor: 'default' });

            // Quitar la escucha de eventos del Body
            body.removeEventListener('mousemove', resizeMousemove, false);
            body.removeEventListener('mouseup', resizeFin, false);
        }


        function resizeMousemove(e)
        {
            try
            {
                var nuevoX = Event.pointerX(e); // - 4;
                var minX   = 160;
                var maxX   = 450;
                
                if (nuevoX >= minX && nuevoX <= maxX)
                {
                    $('div_rec').setStyle({ left: nuevoX + 'px' });
                    document.selection.clear();
                }
            }
            catch (e) { }
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <div id="divMenu"></div>

    <!-- FILTROS -->
    <table class="tb1" id="tbFiltros">
        <tr class="tbLabel">
            <td>Configuración</td>
            <td>Evento</td>
            <td>Password</td>
            <td style="width: 60px;">Email</td>
            <td style="width: 60px;">Phone</td>
            <td style="width: 60px;">Veraz</td>
            <td style="width: 60px;">NOSIS</td>
            <td style="width: 60px;">DNI Frente</td>
            <td style="width: 60px;">DNI Dorso</td>
            <td style="width: 60px;">Selfie</td>
            <td style="width: 60px;">DNI+Selfie</td>
            <td style="width: 60px;">Pre-Selfie</td>
            <td style="width: 60px;">Bio-Vida</td>
            <td style="width: 60px;">Renaper</td>
            <td style="width: 60px;">Renaper M</td>
            <td style="width: 60px;">Mov CBU</td>
            <td style="width: 60px;">BPM</td>
            <td style="width: 60px;">FB</td>
            <td style="width: 60px;">GL</td>
            <td style="width: 60px;">TW</td>
            <td style="width: 60px;">IG</td>
            <td style="width: 100px;">Estado</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <script>
                    campos_defs.add('ids_valcfg_id', { enDB: false, nro_campo_tipo: 104, placeholder: 'ID de config', filtroWhere: "<ids_valcfg_id type='like'>'%%campo_value%%'</ids_valcfg_id>" });
                </script>
            </td>
            <td>
                <script>
                    // Armar el filtroWhere a partir de sus valores, que los IDs de éste campo son strings
                    campos_defs.add('ids_event_id', { enDB: false, nro_campo_tipo: 2, placeholder: 'Seleccionar eventos', filtroXML: nvFW.pageContents.filtro_events, mostrar_codigo: false });
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('ids_pwdcfg_id', { enDB: false, nro_campo_tipo: 1, placeholder: 'Seleccionar password', filtroXML: nvFW.pageContents.filtro_passwords, mostrar_codigo: false, filtroWhere: "<ids_pwdcfg_id type='in'>%campo_value%</ids_pwdcfg_id>" });
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_email', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_email>%campo_value%</req_email>" });
                    var rs = new tRS();
                    rs.addField('id', 'string');
                    rs.addField('campo', 'string');
                    rs.addRecord({ id: '1', campo: 'Si' });
                    rs.addRecord({ id: '0', campo: 'No' });
                    campos_defs.items['req_email'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_phone', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_phone>%campo_value%</req_phone>" });
                    campos_defs.items['req_phone'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_verazID', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_verazID>%campo_value%</req_verazID>" });
                    campos_defs.items['req_verazID'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_nosisID', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_nosisID>%campo_value%</req_nosisID>" });
                    campos_defs.items['req_nosisID'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_dni_frente', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_dni_frente>%campo_value%</req_dni_frente>" });
                    campos_defs.items['req_dni_frente'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_dni_dorso', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_dni_dorso>%campo_value%</req_dni_dorso>" });
                    campos_defs.items['req_dni_dorso'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_selfie', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_selfie>%campo_value%</req_selfie>" });
                    campos_defs.items['req_selfie'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('val_dni_selfie', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<val_dni_selfie>%campo_value%</val_dni_selfie>" });
                    campos_defs.items['val_dni_selfie'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('val_pre_selfie', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<val_pre_selfie>%campo_value%</val_pre_selfie>" });
                    campos_defs.items['val_pre_selfie'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('val_bio_vida', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<val_bio_vida>%campo_value%</val_bio_vida>" });
                    campos_defs.items['val_bio_vida'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('val_renaper_basico', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<val_renaper_basico>%campo_value%</val_renaper_basico>" });
                    campos_defs.items['val_renaper_basico'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('val_renaper_multifactor', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<val_renaper_multifactor>%campo_value%</val_renaper_multifactor>" });
                    campos_defs.items['val_renaper_multifactor'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_cbu_mov', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_cbu_mov>%campo_value%</req_cbu_mov>" });
                    campos_defs.items['req_cbu_mov'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('bpm_process', { enDB: false, nro_campo_tipo: 3, mostrar_codigo: false, filtroWhere: "<bpm_process>%campo_value%</bpm_process>" });
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_facebook', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_facebook>%campo_value%</req_facebook>" });
                    campos_defs.items['req_facebook'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_google', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_google>%campo_value%</req_google>" });
                    campos_defs.items['req_google'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_twitter', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_twitter>%campo_value%</req_twitter>" });
                    campos_defs.items['req_twitter'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('req_instagram', { enDB: false, nro_campo_tipo: 1, mostrar_codigo: false, filtroWhere: "<req_instagram>%campo_value%</req_instagram>" });
                    campos_defs.items['req_instagram'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('ids_status_id', { enDB: false, nro_campo_tipo: 2, mostrar_codigo: false, filtroXML: nvFW.pageContents.filtro_estados });
                </script>
            </td>
            <td>
                <div id="divFiltrar"></div>
            </td>
        </tr>
    </table>

    <table class="tb1" id="tbMain">
        <tbody>
            <tr>
                <!-- LISTADO DE RECURSOS -->
                <td id="tdLeft" style="width: 230px;">
                    <table class="tb1 highlightTROver">
                        <tbody>
                            <tr class="tbLabel">
                                <td style="width: 20px;">&nbsp;</td>
                                <td>Recurso</td>
                            </tr>
                        </tbody>
                    </table>
                </td>

                <!-- TD PARA RESIZE -->
                <td id="td_move" onmousedown="resizeInicio()"></td>

                <!-- CONFIGURACIONES DEL RECURSO SELECCIONADO -->
                <td id="tdData">
                    <div id="divData"></div>
                </td>
            </tr>
        </tbody>
    </table>


    <%-- CONFIG DE EMAIL (básica de la tabla de ids_valcfgs) --%>
    <div id="divEmailConfig" style="display: none;">
        <table class="tb1" style="font-size: 13px;">
            <tr class="tbLabel">
                <td style="max-width: 200px;">Opción</td>
                <td>Valor</td>
            </tr>
            <tr>
                <td class="Tit1">Largo del código</td>
                <td>
                    <input type="number" name="req_email_codeLength" id="req_email_codeLength" style="width: 100%;" disabled="disabled" placeholder="0" />
                </td>
            </tr>
            <tr>
                <td class="Tit1">Timeout (minutos)</td>
                <td>
                    <input type="number" name="req_email_codeTimeout" id="req_email_codeTimeout" style="width: 100%;" disabled="disabled" placeholder="0" />
                </td>
            </tr>
            <tr>
                <td class="Tit1">Fallos máximos de código</td>
                <td>
                    <input type="number" name="req_email_codeMaxFails" id="req_email_codeMaxFails" style="width: 100%;" disabled="disabled" placeholder="0" />
                </td>
            </tr>
            <tr>
                <td class="Tit1">Configuración de Email</td>
                <td>
                    <input type="text" name="req_email_cfg_id" id="req_email_cfg_id" style="width: 100%;" disabled="disabled" placeholder="Config Mail de Validación" />
                </td>
            </tr>
        </table>
    </div>

    
    <%-- CONFIG DE TELEFONO (básica de la tabla de ids_valcfgs) --%>
    <div id="divPhoneConfig" style="display: none;">
        <table class="tb1" style="font-size: 13px;">
            <tr class="tbLabel">
                <td style="max-width: 200px;">Opción</td>
                <td>Valor</td>
            </tr>
            <tr>
                <td class="Tit1">Cuerpo del Mensaje</td>
                <td>
                    <textarea name="req_phone_text" id="req_phone_text" style="width: 100%; max-height: 110px; resize: vertical;" rows="5" disabled="disabled" placeholder="Texto del mensaje..."></textarea>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Largo del código</td>
                <td>
                    <input type="number" name="req_phone_codeLength" id="req_phone_codeLength" style="width: 100%;" disabled="disabled" placeholder="0" />
                </td>
            </tr>
            <tr>
                <td class="Tit1">Timeout del código</td>
                <td>
                    <input type="number" name="req_phone_codeTimeout" id="req_phone_codeTimeout" style="width: 100%;" disabled="disabled" placeholder="0" />
                </td>
            </tr>
        </table>
    </div>
    
</body>
</html>
