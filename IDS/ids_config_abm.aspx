<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim ids_cli_id As Integer = Me.operador.ids_cli_id                      ' Cliente
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")      ' Recurso
    Dim ids_event_id As String = nvUtiles.obtenerValor("ids_event_id", "")  ' Evento

    If ids_res_id = "" Then
        Response.Clear()
        Response.ContentType = "text/html"
        Response.Write("<div style='width: 450px; margin: 0 auto; padding: 25px 0; font-family: sans-serif; text-align: center;'>El <b>Recurso</b> no ha sido asociado al cliente o bien no ha sido configurado.</div>")
        Response.End()
    End If

    Dim modo As String = nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then
        Dim err As New tError
        err.debug_src = "ids_config_abm"
        Dim sb As New StringBuilder

        ' Captura de valores
        Dim ids_pwdcfg_id As String = nvUtiles.obtenerValor("ids_pwdcfg_id", "0", nvConvertUtiles.DataTypes.int)

        Dim ids_valcfg_id As String = nvUtiles.obtenerValor("ids_valcfg_id", "")
        Dim ids_valcfg As String = nvUtiles.obtenerValor("ids_valcfg", "")

        Dim req_email As Integer = If(nvUtiles.obtenerValor("req_email", "False").ToLower = "true", 1, 0)
        Dim req_email_cfg_id As String = nvUtiles.obtenerValor("req_email_cfg_id", "")
        Dim req_email_codeLength As Integer = nvUtiles.obtenerValor("req_email_codeLength", "0", nvConvertUtiles.DataTypes.int)
        Dim req_email_codeTimeout As Integer = nvUtiles.obtenerValor("req_email_codeTimeout", "0", nvConvertUtiles.DataTypes.int)
        Dim req_email_codeMaxFails As Integer = nvUtiles.obtenerValor("req_email_codeMaxFails", "0", nvConvertUtiles.DataTypes.int)

        Dim req_phone As Integer = If(nvUtiles.obtenerValor("req_phone", "False").ToLower = "true", 1, 0)
        Dim req_phone_text As String = nvUtiles.obtenerValor("req_phone_text", "")
        Dim req_phone_codeLength As Integer = nvUtiles.obtenerValor("req_phone_codeLength", "0", nvConvertUtiles.DataTypes.int)
        Dim req_phone_codeTimeout As Integer = nvUtiles.obtenerValor("req_phone_codeTimeout", "0", nvConvertUtiles.DataTypes.int)

        Dim req_verazID As Integer = If(nvUtiles.obtenerValor("req_verazID", "False").ToLower = "true", 1, 0)
        Dim req_nosisID As Integer = If(nvUtiles.obtenerValor("req_nosisID", "False").ToLower = "true", 1, 0)

        Dim req_dni_frente As Integer = If(nvUtiles.obtenerValor("req_dni_frente", "False").ToLower = "true", 1, 0)
        Dim req_dni_dorso As Integer = If(nvUtiles.obtenerValor("req_dni_dorso", "False").ToLower = "true", 1, 0)
        Dim req_selfie As Integer = If(nvUtiles.obtenerValor("req_selfie", "False").ToLower = "true", 1, 0)
        Dim val_dni_selfie As Integer = If(nvUtiles.obtenerValor("val_dni_selfie", "False").ToLower = "true", 1, 0)
        Dim val_pre_selfie As Integer = If(nvUtiles.obtenerValor("val_pre_selfie", "False").ToLower = "true", 1, 0)
        Dim val_bio_vida As Integer = If(nvUtiles.obtenerValor("val_bio_vida", "False").ToLower = "true", 1, 0)
        Dim val_renaper_basico As Integer = If(nvUtiles.obtenerValor("val_renaper_basico", "False").ToLower = "true", 1, 0)
        Dim val_renaper_multifactor As Integer = If(nvUtiles.obtenerValor("val_renaper_multifactor", "False").ToLower = "true", 1, 0)

        Dim req_facebook As Integer = If(nvUtiles.obtenerValor("req_facebook", "False").ToLower = "true", 1, 0)
        Dim req_google As Integer = If(nvUtiles.obtenerValor("req_google", "False").ToLower = "true", 1, 0)
        Dim req_instagram As Integer = If(nvUtiles.obtenerValor("req_instagram", "False").ToLower = "true", 1, 0)
        Dim req_twitter As Integer = If(nvUtiles.obtenerValor("req_twitter", "False").ToLower = "true", 1, 0)

        Dim req_cbu_mov As Integer = If(nvUtiles.obtenerValor("req_cbu_mov", "False").ToLower = "true", 1, 0)
        Dim bpm_process As Integer = nvUtiles.obtenerValor("bpm_process", "-1", nvConvertUtiles.DataTypes.int)

        Dim ids_status_id As String = nvUtiles.obtenerValor("ids_status_id", "")
        Dim ids_valtype_version As String = nvUtiles.obtenerValor("ids_valtype_version", "")

        If ids_cli_id = 0 OrElse ids_valcfg_id = "" OrElse ids_valcfg = "" OrElse ids_pwdcfg_id = 0 Then
            err.numError = 10
            err.titulo = "Error"
            err.mensaje = "El ID cliente, ID de Contraseña, ID Validacion o su descripción son inválidos."
            err.response()
        End If

        Select Case modo.ToUpper()
            Case "A"
                sb.Clear()
                ' Controlar que no exista una configuración igual en "Config de Recursos" y "Config de Validaciones"
                sb.Append("SELECT 1 FROM ids_res_config WHERE ")
                sb.AppendFormat("ids_cli_id={0} AND ids_res_id='{1}' AND ids_event_id='{2}'", ids_cli_id, ids_res_id, ids_event_id)
                Dim exists As Boolean = False

                Try
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(sb.ToString())
                    exists = Not rs.EOF
                Catch ex As Exception
                End Try

                If exists Then
                    err.numError = 11
                    err.titulo = "Error"
                    err.mensaje = "Ya existe una configuración de validación en la base con el Recurso y Evento seleccionados."
                    err.debug_src &= "::Alta"
                    err.response()
                End If

                sb.Clear()
                sb.AppendFormat("SELECT 1 FROM ids_valcfgs WHERE ids_cli_id={0} AND ids_valcfg_id='{1}'", ids_cli_id, ids_valcfg_id)

                Try
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(sb.ToString())
                    exists = Not rs.EOF
                Catch ex As Exception
                End Try

                If exists Then
                    err.numError = 11
                    err.titulo = "Error"
                    err.mensaje = "Ya existe una configuración de validación en la base con el ID proporcionado."
                    err.debug_src &= "::Alta"
                    err.response()
                End If

                ' Agregar la configuración de validaciones y actualizar en recursos
                sb.Clear()
                sb.Append("INSERT INTO ids_valcfgs (")
                sb.Append("ids_cli_id, ids_valcfg_id, ids_valcfg, req_email, req_email_cfg_id, req_email_codeLength, req_email_codeTimeout, req_email_codeMaxFails, ")
                sb.Append("req_phone, req_phone_text, req_phone_codeLength, req_phone_codeTimeout, req_verazID, req_nosisID, req_dni_frente, req_dni_dorso, req_selfie, ")
                sb.Append("val_dni_selfie, val_pre_selfie, val_bio_vida, val_renaper_basico, val_renaper_multifactor, req_facebook, req_google, req_instagram, req_twitter, ")
                sb.Append("req_cbu_mov, bpm_process, ids_status_id, ids_valtype_version) VALUES (")
                sb.AppendFormat("{0}, '{1}', '{2}', ", ids_cli_id, ids_valcfg_id, ids_valcfg)
                sb.AppendFormat("{0}, '{1}', {2}, {3}, {4}, ", req_email, req_email_cfg_id, req_email_codeLength, req_email_codeTimeout, req_email_codeMaxFails)
                sb.AppendFormat("{0}, '{1}', {2}, {3}, ", req_phone, req_phone_text, req_phone_codeLength, req_phone_codeTimeout)
                sb.AppendFormat("{0}, {1}, {2}, {3}, {4}, ", req_verazID, req_nosisID, req_dni_frente, req_dni_dorso, req_selfie)
                sb.AppendFormat("{0}, {1}, {2}, {3}, {4}, ", val_dni_selfie, val_pre_selfie, val_bio_vida, val_renaper_basico, val_renaper_multifactor)
                sb.AppendFormat("{0}, {1}, {2}, {3}, ", req_facebook, req_google, req_instagram, req_twitter)
                sb.AppendFormat("{0}, {1}, '{2}', '{3}')", req_cbu_mov, bpm_process, ids_status_id, ids_valtype_version)
                sb.Append(vbCrLf)
                sb.Append(vbCrLf)

                ' Agregar el recurso y  el evento en "ids_res_config" para la config de validación nueva
                sb.Append("INSERT INTO ids_res_config (ids_cli_id, ids_res_id, ids_event_id, ids_valcfg_id, ids_pwdcfg_id) ")
                sb.AppendFormat("VALUES ({0}, '{1}', '{2}', '{3}', {4})", ids_cli_id, ids_res_id, ids_event_id, ids_valcfg_id, ids_pwdcfg_id)

                Try
                    nvDBUtiles.DBExecute(sb.ToString())
                    err.params("ids_valcfg_id") = ids_valcfg_id
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Alta"
                    err.mensaje = "No fué posible realizar el alta en la base."
                    err.debug_src &= "::Alta"
                End Try


            Case "M"
                sb.Clear()
                sb.Append("UPDATE ids_valcfgs SET ")
                sb.AppendFormat("ids_valcfg='{0}', ", ids_valcfg)
                sb.AppendFormat("req_email={0}, req_email_cfg_id='{1}', req_email_codeLength={2}, req_email_codeTimeout={3}, req_email_codeMaxFails={4}, ", req_email, req_email_cfg_id, req_email_codeLength, req_email_codeTimeout, req_email_codeMaxFails)
                sb.AppendFormat("req_phone={0}, req_phone_text='{1}', req_phone_codeLength={2}, req_phone_codeTimeout={3}, ", req_phone, req_phone_text, req_phone_codeLength, req_phone_codeTimeout)
                sb.AppendFormat("req_verazID={0}, req_nosisID={1}, ", req_verazID, req_nosisID)
                sb.AppendFormat("req_dni_frente={0}, req_dni_dorso={1}, req_selfie={2}, ", req_dni_frente, req_dni_dorso, req_selfie)
                sb.AppendFormat("val_dni_selfie={0}, val_pre_selfie={1}, val_bio_vida={2}, ", val_dni_selfie, val_pre_selfie, val_bio_vida)
                sb.AppendFormat("val_renaper_basico={0}, val_renaper_multifactor={1}, ", val_renaper_basico, val_renaper_multifactor)
                sb.AppendFormat("req_facebook={0}, req_google={1}, req_instagram={2}, req_twitter={3}, ", req_facebook, req_google, req_instagram, req_twitter)
                sb.AppendFormat("req_cbu_mov={0}, bpm_process={1}, ", req_cbu_mov, bpm_process)
                sb.AppendFormat("ids_status_id='{0}', ids_valtype_version='{1}' ", ids_status_id, ids_valtype_version)
                sb.AppendFormat("WHERE ids_cli_id={0} AND ids_valcfg_id='{1}'", ids_cli_id, ids_valcfg_id)
                sb.Append(vbCrLf)

                ' Actualizar el ID de password porque puede haber cambiado
                sb.Append("UPDATE ids_res_config SET ")
                sb.AppendFormat("ids_pwdcfg_id='{0}' ", ids_pwdcfg_id)
                sb.AppendFormat("WHERE ids_cli_id={0} AND ids_res_id='{1}' AND ids_event_id='{2}' AND ids_valcfg_id='{3}'", ids_cli_id, ids_res_id, ids_event_id, ids_valcfg_id)
                sb.Append(vbCrLf)

                Try
                    nvDBUtiles.DBExecute(sb.ToString())
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Modificación"
                    err.mensaje = "No fué posible realizar la actualización en la base."
                    err.debug_src &= "::Modificacion"
                End Try

        End Select

        err.response()
    End If


    Me.contents("filtro_eventos") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_events' cacheControl='session'><campos>ids_event_id AS [id], ids_event AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_email_configs") = nvXMLSQL.encXMLSQL("<criterio><select vista='mail_cfgs' cacheControl='session'><campos>mail_cfgs_id AS [id], mail_cfgs AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_passwords") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_pwdcfgs'><campos>ids_pwdcfg_id AS [id], ids_pwdcfg AS [campo]</campos><filtro><ids_cli_id>" & ids_cli_id & "</ids_cli_id></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_ids_estados") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_status'><campos>ids_status_id AS [id], ids_status AS [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")

    Me.contents("ids_res_id") = ids_res_id
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Agregar configuración al recurso</title>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <style>
        tr.tbLabel > td {
            text-align: center;
        }
        tr.selected > td:first-child {
            font-weight: bold;
            color: #0074ff;
        }
        tr.selected > td:not(:first-child) {
            background-color: #b0d7ffb0;
            color: #333;
        }
        div.inline {
            display: inline-block;
            float: left;
            text-align: center;
        }
        div.inline:first-child {
            width: 30px;
        }
        div.inline:last-child {
            width: calc(100% - 30px);
            max-width: 900px;
            text-align: left;
            background-color: #FFFFFF;
        }
        div.inline table.tb1 {
            font-size: 0.9em;
        }
        textarea {
            width: 100%;
            resize: vertical;
            max-height: 120px;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

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


        /**
         * Funcion para sanitizar los IDs y hacerlos válidos
         * 
         * Toma como argumento una cadena y la convierte en un identificador válido, quitando
         * todos los caracteres acentuados y otros como la letra "ñ".
         *
         * Ejemplo:
         *  Input:  "un identificador válido para mañana"
         *  Output: "UnIdentificadorValidoParaManana"
         *
         * @param str_id Cadena a sanitizar para convertirla en ID válido
         */
        function sanitize(str_id)
        {
            if (!str_id) return '';

            // Quitar acentos y caracteres especiales (acentos y ñ)
            str_id = str_id.normalize('NFD').replace(/[\u0300-\u036f]/g, '');

            var splitted = str_id.split(/\s+/);
            if (splitted.length <= 1) return str_id;

            splitted.each(function(str, index) {
                splitted[index] = str.capitalize();
            });

            return splitted.join('');
        }
    </script>

    <script type="text/javascript">
        var win        = nvFW.getMyWindow();
        var data       = null;
        var nueva_cfg  = false;
        var vMenu;
        var ids_res_id = nvFW.pageContents.ids_res_id;
        


        function loadMenu()
        {
            vMenu = new tMenu('divMenu', 'vMenu');
            
            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>save()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_cerrar</icono><Desc>Guardar y Salir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>save(true)</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva()</Codigo></Ejecutar></Acciones></MenuItem>");
            
            vMenu.loadImage('guardar', '/IDS/image/icons/guardar.png');
            vMenu.loadImage('guardar_cerrar', '/IDS/image/icons/guardar_cerrar.png');
            vMenu.loadImage('nuevo', '/IDS/image/icons/nueva.png');
            
            vMenu.MostrarMenu();
        }


        function loadData()
        {
            if (!isEmpty(data))
            {
                var settings = data.settings;

                // Configuración
                campos_defs.set_value("ids_valcfg_id", data.ids_valcfg_id);
                campos_defs.set_value("ids_valcfg", settings.ids_valcfg);
                // Evento
                campos_defs.set_value("ids_event_id", settings.config_event.ids_event_id);
                // Password
                campos_defs.set_value("ids_pwdcfg_id", settings.config_pass.ids_pwdcfg_id);
                // Email
                if (settings.req_email)
                {
                    $("req_email").click();
                    campos_defs.set_value('req_email_codeLength', settings.config_email.req_email_codeLength ? settings.config_email.req_email_codeLength : '');
                    campos_defs.set_value('req_email_codeTimeout', settings.config_email.req_email_codeTimeout ? settings.config_email.req_email_codeTimeout : '');
                    campos_defs.set_value('req_email_codeMaxFails', settings.config_email.req_email_codeMaxFails ? settings.config_email.req_email_codeMaxFails : '');
                    campos_defs.set_value('req_email_cfg_id', settings.config_email.req_email_cfg_id ? settings.config_email.req_email_cfg_id : '');
                }
                // Telefono
                if (settings.req_phone)
                {
                    $("req_phone").click();
                    $('req_phone_text').value = settings.config_phone.req_phone_text ? settings.config_phone.req_phone_text : '';
                    campos_defs.set_value('req_phone_codeLength', settings.config_phone.req_phone_codeLength ? settings.config_phone.req_phone_codeLength : '');
                    campos_defs.set_value('req_phone_codeTimeout', settings.config_phone.req_phone_codeTimeout ? settings.config_phone.req_phone_codeTimeout : '');
                }
                // Veraz
                if (settings.req_verazID) $("req_verazID").click();
                // NOSIS
                if (settings.req_nosisID) $("req_nosisID").click();
                // DNI frente
                if (settings.req_dni_frente) $("req_dni_frente").click();
                // DNI dorso
                if (settings.req_dni_dorso) $("req_dni_dorso").click();
                // Selfie
                if (settings.req_selfie) $("req_selfie").click();
                // Validar DNI +  selfie
                if (settings.val_dni_selfie) $("val_dni_selfie").click();
                // Validar con selfie anterior
                if (settings.val_pre_selfie) $("val_pre_selfie").click();
                // Validacion biometrica prueba de vida
                if (settings.val_bio_vida) $("val_bio_vida").click();
                // Validar ReNaPer basico
                if (settings.val_renaper_basico) $("val_renaper_basico").click();
                // Valida ReNaPer multifactor
                if (settings.val_renaper_multifactor) $("val_renaper_multifactor").click();
                // Movimiento CBU
                if (settings.req_cbu_mov) $("req_cbu_mov").click();
                // Proceso BPM
                if (settings.bpm_process !== -1)
                {
                    $('chk_bpm_process').click();
                    campos_defs.set_value("bpm_process", settings.bpm_process);
                }
                // Facebook
                if (settings.req_facebook) $("req_facebook").click();
                // Google
                if (settings.req_google) $("req_google").click();
                // Twitter
                if (settings.req_twitter) $("req_twitter").click();
                // Instagram
                if (settings.req_instagram) $("req_instagram").click();
                // Estado
                campos_defs.set_value('ids_status_id', settings.ids_status_id ? settings.ids_status_id : '');
                // Version
                campos_defs.set_value('ids_valtype_version', settings.ids_valtype_version ? settings.ids_valtype_version : '');
            }
        }


        function setCheckboxes_onclick()
        {
            var checkboxes = $$('input[type="checkbox"]');
            
            checkboxes.each(function(checkbox) {
                checkbox.onclick = function (event) {
                    var element = $(event.target);

                    if (element.checked)
                    {
                        element.up("tr").addClassName("selected");

                        switch (element.id)
                        {
                            case 'req_email': $('verEmailConfigs').show(); break;
                            case 'req_phone': $('verPhoneConfigs').show(); break;
                            case 'chk_bpm_process': $('verBPM').show(); break;
                        }
                    }
                    else
                    {
                        element.up("tr").removeClassName("selected");
                        
                        switch (element.id)
                        {
                            case 'req_email': $('verEmailConfigs').hide(); break;
                            case 'req_phone': $('verPhoneConfigs').hide(); break;
                            case 'chk_bpm_process': $('verBPM').hide(); break;
                        }
                    }
                }
            });
        }


        function setCamposDefs_onchange()
        {
            // Contraseña
            campos_defs.items['ids_pwdcfg_id'].onchange = function()
            {
                var tds = $$('#trPwd > td');  // TD's de la contraseña

                if (campos_defs.get_value('ids_pwdcfg_id'))
                {
                    tds[1].colSpan       = 1;
                    tds[2].style.display = '';
                }
                else
                {
                    tds[1].colSpan       = 2;
                    tds[2].style.display = 'none';
                }
            }


            // Configuración de Email
            campos_defs.items['req_email_cfg_id'].onchange = function()
            {
                if ($('verEmailConfigs').visible())
                {
                    var tds = $$('#trEmailCfg > td');

                    if (campos_defs.get_value('req_email_cfg_id'))
                    {
                        tds[1].colSpan       = 1;
                        tds[2].style.display = '';
                    }
                    else
                    {
                        tds[1].colSpan       = 2;
                        tds[2].style.display = 'none';
                    }
                }
            }
        }


        function windowOnload()
        {
            nvFW.enterToTab = false;
            data = win.options.userData;

            loadMenu();
            setCheckboxes_onclick();
            setCamposDefs_onchange();

            if (data && data.modo && data.modo.toLowerCase() === "edit")
            {
                loadData();
                // No dejar editar los siguientes campos defs (a menos que sea una configuración nueva)
                campos_defs.habilitar("ids_valcfg_id", false);
                campos_defs.habilitar("ids_valcfg", false);
                campos_defs.habilitar("ids_event_id", false);
            }
            else
            {
                nueva_cfg = true;
                campos_defs.focus('ids_valcfg_id');
            }

            windowOnresize();
        }


        function windowOnresize()
        {
        }


        function validateFields()
        {
            var errors = '';

            if (nueva_cfg)
            {
                if (!campos_defs.get_value("ids_valcfg_id")) errors += "* ID Configuración<br>";
                if (!campos_defs.get_value("ids_valcfg")) errors += "* Descripción Configuración<br>";
            }

            if (!campos_defs.get_value("ids_event_id")) errors += "* Evento<br>";
            if (!campos_defs.get_value("ids_pwdcfg_id")) errors += "* Contraseña<br>";
            if (!campos_defs.get_value("ids_status_id")) errors += "* Estado<br>";
            if (!campos_defs.get_value("ids_valtype_version")) errors += "* Versión<br>";

            return errors;
        }


        function save(exit_after_save)
        {
            // Chequear que los campos principales esten seteados
            var error_msg = validateFields();
            
            if (error_msg)
            {
                alert(error_msg, {
                    title:  '<b>Error: valores sin completar</b>',
                    width:  500,
                    height: 150
                });

                return false;
            }
            
            exit_after_save = exit_after_save === true;

            var options = {
                parameters: {
                    modo:                    nueva_cfg ? 'A' : 'M',
                    ids_res_id:              ids_res_id,
                    ids_valcfg_id:           nueva_cfg ? sanitize(campos_defs.get_value('ids_valcfg_id')) : campos_defs.get_value('ids_valcfg_id'),  // Si es ALTA => sanitizar el ID
                    ids_valcfg:              campos_defs.get_value('ids_valcfg'),
                    ids_event_id:            campos_defs.get_value('ids_event_id'),
                    ids_pwdcfg_id:           campos_defs.get_value('ids_pwdcfg_id'),
                    req_email:               $('req_email').checked,
                    req_email_codeLength:    $('req_email').checked ? campos_defs.get_value('req_email_codeLength') : '',
                    req_email_codeTimeout:   $('req_email').checked ?  campos_defs.get_value('req_email_codeTimeout') : '',
                    req_email_codeMaxFails:  $('req_email').checked ? campos_defs.get_value('req_email_codeMaxFails') : '',
                    req_email_cfg_id:        $('req_email').checked ? campos_defs.get_value('req_email_cfg_id') : '',
                    req_phone:               $('req_phone').checked,
                    req_phone_text:          $('req_phone').checked ? $('req_phone_text').value : '',
                    req_phone_codeLength:    $('req_phone').checked ? campos_defs.get_value('req_phone_codeLength') : '',
                    req_phone_codeTimeout:   $('req_phone').checked ? campos_defs.get_value('req_phone_codeTimeout') : '',
                    req_verazID:             $('req_verazID').checked,
                    req_nosisID:             $('req_nosisID').checked,
                    req_dni_frente:          $('req_dni_frente').checked,
                    req_dni_dorso:           $('req_dni_dorso').checked,
                    req_selfie:              $('req_selfie').checked,
                    val_dni_selfie:          $('val_dni_selfie').checked,
                    val_pre_selfie:          $('val_pre_selfie').checked,
                    val_bio_vida:            $('val_bio_vida').checked,
                    val_renaper_basico:      $('val_renaper_basico').checked,
                    val_renaper_multifactor: $('val_renaper_multifactor').checked,
                    req_facebook:            $('req_facebook').checked,
                    req_google:              $('req_google').checked,
                    req_instagram:           $('req_instagram').checked,
                    req_twitter:             $('req_twitter').checked,
                    req_cbu_mov:             $('req_cbu_mov').checked,
                    bpm_process:             $('chk_bpm_process').checked ? campos_defs.get_value('bpm_process') : -1,
                    ids_status_id:           campos_defs.get_value('ids_status_id'),
                    ids_valtype_version:     campos_defs.get_value('ids_valtype_version')
                },
                error_alert: false,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Guardando...',
                onSuccess: function (res)
                {
                    if (nueva_cfg)
                    {
                        nueva_cfg = false;
                        campos_defs.set_value('ids_valcfg_id', res.params.ids_valcfg_id);
                        campos_defs.habilitar('ids_valcfg_id', false);
                    }

                    data.reload = true;
                    data.reload_ids_valcfg_id = campos_defs.get_value('ids_valcfg_id');

                    campos_defs.habilitar('ids_valcfg', false);
                    campos_defs.habilitar('ids_event_id', false);

                    if (exit_after_save) win.close();
                },
                onFailure: function (res)
                {
                    alert(res.mensaje, { title: '<b>' + res.titulo + '</b>', width: 500 });
                }
            };

            nvFW.error_ajax_request('ids_config_abm.aspx', options);
        }


        function nueva()
        {
            nueva_cfg = true;

            // Cambiar titulo de la ventana
            win.setTitle('Agregar config para recurso <b>' + win.options.userData.ids_resource + '</b>');

            // Habilitar los campos bloqueados
            campos_defs.habilitar('ids_valcfg_id', true);
            campos_defs.habilitar('ids_valcfg', true);
            campos_defs.habilitar('ids_event_id', true);

            // Limpiar los campos_defs principales
            campos_defs.clear('ids_valcfg_id');
            campos_defs.clear('ids_valcfg');
            campos_defs.clear('ids_event_id');
            campos_defs.clear('ids_pwdcfg_id');

            // Limpiar los campos_defs de Email, Phone y BPM
            campos_defs.clear('req_email_codeLength');
            campos_defs.clear('req_email_codeTimeout');
            campos_defs.clear('req_email_codeMaxFails');
            campos_defs.clear('req_email_cfg_id');
            $('req_phone_text').value = '';
            campos_defs.clear('req_phone_codeLength');
            campos_defs.clear('req_phone_codeTimeout');
            campos_defs.clear('bpm_process');
            campos_defs.clear('ids_status_id');
            campos_defs.clear('ids_valtype_version');

            // Limpiar todos los checkboxes (quitar los marcados)
            $$('input[type="checkbox"]').each(function (checkbox)
            {
                if (checkbox.checked) {
                    checkbox.click();
                }
            });

            campos_defs.focus('ids_valcfg_id');
        }


        /*---------------------------------------------------------------------
        |
        |   Visualización de sub-configuraciones
        |
        |--------------------------------------------------------------------*/
        function verConfigPassword()
        {
            var ids_pwdcfg_id = campos_defs.get_value('ids_pwdcfg_id');

            if (ids_pwdcfg_id)
            {
                var options = {
                    url:            'ids_config_password.aspx?ids_pwdcfg_id=' + ids_pwdcfg_id + '&solo_consulta=1',
                    title:          '<b>Config Password</b>',
                    width:          700,
                    height:         400,
                    destroyOnClose: true
                };
                var win_pwdcfg = nvFW.createWindow(options);
                win_pwdcfg.showCenter(true);
            }
        }


        function verConfigEmail()
        {
            var mail_cfg_id = campos_defs.get_value('req_email_cfg_id');

            if (mail_cfg_id)
            {
                var options = {
                    url:            'ids_config_email.aspx?mail_cfgs_id=' + mail_cfg_id + '&solo_consulta=1',
                    title:          '<b>Config de mail</b>',
                    width:          700,
                    height:         270,
                    destroyOnClose: true
                };
                var win_emailcfg = nvFW.createWindow(options);
                win_emailcfg.showCenter(true);
            }
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">
    <div id="divMenu"></div>

    <table class="tb1 highlightOdd highlightTROver">
        <tr>
            <td class="Tit1" style="width: 250px;">ID Configuración</td>
            <td colspan="2">
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 104,
                        placeholder:    "MiConfiguracion"
                    };

                    campos_defs.add("ids_valcfg_id", options);
                    //campos_defs.habilitar("ids_valcfg_id", false);
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 250px;">Descripción Configuración</td>
            <td colspan="2">
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 104,
                        placeholder:    "Descripción de la configuración actual..."
                    };

                    campos_defs.add("ids_valcfg", options);
                    //campos_defs.habilitar("ids_valcfg", false);
                </script>
            </td>
        </tr>

        <tr>
            <td class="Tit1">Evento</td>
            <td colspan="2">
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 1,
                        placeholder:    'Seleccionar Evento',
                        mostrar_codigo: false,
                        filtroXML:      nvFW.pageContents.filtro_eventos
                    };

                    campos_defs.add('ids_event_id', options);
                    //campos_defs.habilitar('ids_event_id', false);
                </script>
            </td>
        </tr>

        <tr id="trPwd">
            <td class="Tit1">Contraseña</td>
            <td colspan="2">
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 1,
                        placeholder:    'Seleccionar config. de Contraseña',
                        mostrar_codigo: false,
                        filtroXML:      nvFW.pageContents.filtro_passwords
                    };

                    campos_defs.add('ids_pwdcfg_id', options);
                </script>
            </td>
            <td style="display: none; width: 20px; text-align: center;">
                <img alt="pwd" src="/IDS/image/icons/ojo.png" style="cursor: pointer;" id="icoVerPwd" title="Ver configuración contraseña" onclick="verConfigPassword();" />
            </td>
        </tr>

        <tr>
            <td class="Tit1">Email</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_email" id="req_email" />
                </div>
                <div class="inline">
                    
                    <!-- Configuraciones de Email -->
                    <table class="tb1" id="verEmailConfigs" style="display: none;">
                        <%--<tr class="tbLabel">
                            <td style="width: 175px;">Opción</td>
                            <td colspan="2">Valor</td>
                        </tr>--%>
                        <tr>
                            <td class="Tit4" style="width: 175px;">Largo de código</td>
                            <td colspan="2">
                                <script type="text/javascript">
                                    campos_defs.add('req_email_codeLength', { enDB: false, nro_campo_tipo: 100, placeholder: '0' });
                                </script>
                            </td>
                        </tr>
                        <tr>
                            <td class="Tit4">Timeout (minutos)</td>
                            <td colspan="2">
                                <script type="text/javascript">
                                    campos_defs.add('req_email_codeTimeout', { enDB: false, nro_campo_tipo: 100, placeholder: '0' });
                                </script>
                            </td>
                        </tr>
                        <tr>
                            <td class="Tit4">Fallos máximos de código</td>
                            <td colspan="2">
                                <script type="text/javascript">
                                    campos_defs.add('req_email_codeMaxFails', { enDB: false, nro_campo_tipo: 100, placeholder: '0' });
                                </script>
                            </td>
                        </tr>
                        <tr id="trEmailCfg">
                            <td class="Tit4">Configuración de Email</td>
                            <td colspan="2">
                                <script type="text/javascript">
                                    campos_defs.add('req_email_cfg_id', { 
                                        enDB:           false, 
                                        nro_campo_tipo: 1, 
                                        placeholder:    'Seleccionar config de Email', 
                                        filtroXML:      nvFW.pageContents.filtro_email_configs, 
                                        mostrar_codigo: false
                                    });
                                </script>
                            </td>
                            <td style="display: none; width: 20px; text-align: center;">
                                <img alt="emailcfg" src="/IDS/image/icons/ojo.png" style="cursor: pointer;" id="icoVerEmailCfg" title="Ver configuración de email" onclick="verConfigEmail();" />
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Teléfono</td>
            <td style="text-align: right;"colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_phone" id="req_phone" />
                </div>
                <div class="inline">
                    
                    <!-- Configuraciones de Teléfono -->
                    <table class="tb1" id="verPhoneConfigs" style="display: none;">
                        <%--<tr class="tbLabel">
                            <td style="width: 175px;">Opción</td>
                            <td>Valor</td>
                        </tr>--%>
                        <tr>
                            <td class="Tit4" style="width: 175px;">Cuerpo del Mensaje</td>
                            <td>
                                <textarea name="req_phone_text" id="req_phone_text" rows="3" placeholder="Texto del mensaje telefónico..."></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="Tit4">Largo del código</td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('req_phone_codeLength', { enDB: false, nro_campo_tipo: 100, placeholder: '0' });
                                </script>
                            </td>
                        </tr>
                        <tr>
                            <td class="Tit4">Timeout (minutos)</td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('req_phone_codeTimeout', { enDB: false, nro_campo_tipo: 100, placeholder: '0' });
                                </script>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Veraz ID</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_verazID" id="req_verazID" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">NOSIS</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_nosisID" id="req_nosisID" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">DNI Frente</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_dni_frente" id="req_dni_frente" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">DNI Dorso</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_dni_dorso" id="req_dni_dorso" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Selfie</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_selfie" id="req_selfie" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">DNI + Selfie</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="val_dni_selfie" id="val_dni_selfie" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Prevalidación con selfie</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="val_pre_selfie" id="val_pre_selfie" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Biométrica con prueba de vida</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="val_bio_vida" id="val_bio_vida" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">ReNaPer básico</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="val_renaper_basico" id="val_renaper_basico" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">ReNaPer multifactor</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="val_renaper_multifactor" id="val_renaper_multifactor" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Movimiento de CBU</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_cbu_mov" id="req_cbu_mov" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr id="trBPM">
            <td class="Tit1">BPM</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="chk_bpm_process" id="chk_bpm_process" />
                </div>
                <div class="inline">

                    <!-- Búsqueda del BPM -->
                    <table class="tb1" id="verBPM" style="display: none;">
                        <%--<tr class="tbLabel">
                            <td style="width: 175px;">Opción</td>
                            <td>Valor</td>
                        </tr>--%>
                        <tr>
                            <td class="Tit4" style="width: 175px;">BPM</td>
                            <td>
                                <script type="text/javascript">
                                    // Completar
                                    campos_defs.add('bpm_process', { enDB: false, nro_campo_tipo: 3, placeholder: 'Seleccione el BPM' });
                                </script>
                            </td>
                        </tr>
                    </table>

                </div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Facebook</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_facebook" id="req_facebook" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Google</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_google" id="req_google" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Twitter</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_twitter" id="req_twitter" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Instagram</td>
            <td style="text-align: right;" colspan="2">
                <div class="inline">
                    <input type="checkbox" name="req_instagram" id="req_instagram" />
                </div>
                <div class="inline"></div>
            </td>
        </tr>

        <tr>
            <td class="Tit1">Estado de Configuración</td>
            <td colspan="2">
                <script>
                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 1,
                        placeholder:    'Seleccionar Estado',
                        mostrar_codigo: false,
                        filtroXML:      nvFW.pageContents.filtro_ids_estados
                    };

                    campos_defs.add('ids_status_id', options);
                </script>
            </td>
        </tr>

        <tr>
            <td class="Tit1">Versión de Configuración</td>
            <td colspan="2">
                <script>
                    // Internar cargar la librería IMask, ya que necesitamos opciones de ella (IMask.MaskedRange)
                    nvFW.chargeJSifNotExist('', '/FW/script/IMask/imask.js');

                    var options = {
                        enDB:           false,
                        nro_campo_tipo: 104,
                        placeholder:    '1.0.0',
                        mask: {
                            mask: 'mayor{.}`0{.}`0[0]',
                            blocks: {
                                mayor: {
                                    mask:      IMask.MaskedRange,
                                    from:      1,
                                    to:        9,
                                    maxLength: 1
                                }
                            },
                            placeholderChar: 'x',
                            lazy: false
                        }
                    };

                    campos_defs.add('ids_valtype_version', options);
                </script>
            </td>
        </tr>
    </table>
</body>
</html>
