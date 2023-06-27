<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    ' Parametros necesarios para guardar ...
    Dim ids_cli_id As Integer = nvUtiles.obtenerValor("ids_cli_id", "0", nvConvertUtiles.DataTypes.int)
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")
    Dim ids_event_id As String = nvUtiles.obtenerValor("ids_event_id", "")
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es-ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <title>Configuración de Email</title>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <style>
        .tr_seccion td {
            height: 21px;
            text-transform: uppercase;
            text-align: center !important;
            font-weight: bold !important;
            background-color: #333 !important;
            color: #fff !important;
        }
        tr.tbLabel td {
            text-align: center;
        }
        input:disabled,
        select:disabled {
            background-color: #EEE;
            border: 1px solid #DDD;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <script type="text/javascript">
        var win;
        var data;
        var modo_edicion = false;



        function windowOnload()
        {
            configEmail_loadMenu();
            configEmail_setMenu();

            win          = nvFW.getMyWindow();
            data         = win.options.userData;
            modo_edicion = !data.modo ? false :  data.modo === true;

            configEmail_makeFields();   // armar los campos
            configEmail_setValues();    // setear sus valores
            configEmail_setEdition();   // bloquear o habilitar los campos segun este activo o no el modo de edicion

            windowOnresize();
        }

        
        function windowOnresize()
        {
        }
        
        
        function configEmail_loadMenu()
        {
            $('divMenu').innerHTML = '';    // Limpiar el contenedor antes de cargar
            vMenu = new tMenu('divMenu', 'vMenu');

            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>configEmail_save()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>configEmail_editar()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>configEmail_nueva()</Codigo></Ejecutar></Acciones></MenuItem>");

            vMenu.loadImage('guardar', '/IDS/image/icons/guardar.png');
            vMenu.loadImage('editar', '/IDS/image/icons/editar.png');
            vMenu.loadImage('nuevo', '/IDS/image/icons/nueva.png');

            vMenu.MostrarMenu();
        }
        

        function configEmail_setMenu()
        {
            /*-----------------------------------------------------------------
            |   Orden del menu
            |------------------------------------------------------------------
            |       0 - Guardar
            |       1 - Editar
            |       2 - Vacio
            |       3 - Nuevo
            |----------------------------------------------------------------*/
            $tds = $$('#vMenu td');

            if (modo_edicion)
            {
                $tds[0].show();
                $tds[1].hide();
            }
            else {
                $tds[0].hide();
                $tds[1].show();
            }
        }


        function configEmail_makeFields()
        {
            // Configs código
            campos_defs.add('mail_cfgs', { enDB: false, nro_campo_tipo: 104, target: 'tdCfgName', placeholder: 'Validación de email para XYZ.' });
            campos_defs.add('req_email_codeLength', { enDB: false, nro_campo_tipo: 100, target: 'tdCodeLength', placeholder: '0' });
            campos_defs.add('req_email_codeTimeout', { enDB: false, nro_campo_tipo: 100, target: 'tdTimeout', placeholder: '0' });
            campos_defs.add('req_email_codeMaxFails', { enDB: false, nro_campo_tipo: 100, target: 'tdMaxFails', placeholder: '0' });

            // Configs mensajes
            campos_defs.add('Body', { enDB: false, nro_campo_tipo: 104, target: 'tdBody', placeholder: 'Cuerpo del mensaje, admite %parametros%' });
            campos_defs.add('Subject', { enDB: false, nro_campo_tipo: 104, target: 'tdSubject', placeholder: 'Asunto del mensaje' });
            campos_defs.add('FromTitle', { enDB: false, nro_campo_tipo: 104, target: 'tdFromTitle', placeholder: 'John Doe' });
            campos_defs.add('cco', { enDB: false, nro_campo_tipo: 104, target: 'tdCCO', placeholder: 'john@doe.com' });

            // Config SMTP
            campos_defs.add('mail_server', { enDB: false, nro_campo_tipo: 104, target: 'tdServerName', placeholder: 'Servicio de mail para XYZ' });
            campos_defs.add('smtp_server', { enDB: false, nro_campo_tipo: 104, target: 'tdServer', placeholder: 'mail.xyz.com.ar' });
            campos_defs.add('smtp_port', { enDB: false, nro_campo_tipo: 100, target: 'tdPort', placeholder: '587' });
            campos_defs.add('smtp_user', { enDB: false, nro_campo_tipo: 104, target: 'tdUser', placeholder: 'john@xyz.com.ar' });
            campos_defs.add('smtp_pwd', { enDB: false, nro_campo_tipo: 104, target: 'tdPwd', placeholder: 'm1pas$w0rd9.' });
            
            // SMTP seguro
            campos_defs.add('smtp_secure', { enDB: false, nro_campo_tipo: 1, target: 'tdSecure', placeholder: 'Seleccionar', mostrar_codigo: false, despliega: 'arriba' });
            var rs = new tRS();
            rs.addField('id', 'string');
            rs.addField('campo', 'string');
            rs.addRecord({ 'id': '0', 'campo': 'Si' });
            rs.addRecord({ 'id': '1', 'campo': 'No' });

            campos_defs.items['smtp_secure'].rs = rs;
        }


        function configEmail_setValues()
        {
            if (data)
            {
                // Configs generales de código
                campos_defs.set_value('mail_cfgs', data.mail_cfgs ? data.mail_cfgs : 'N/D');
                campos_defs.set_value('req_email_codeLength', data.req_email_codeLength ? data.req_email_codeLength : '0');
                campos_defs.set_value('req_email_codeTimeout', data.req_email_codeTimeout ? data.req_email_codeTimeout : '0');
                campos_defs.set_value('req_email_codeMaxFails', data.req_email_codeMaxFails ? data.req_email_codeMaxFails : '0');

                // Configs mensajes
                campos_defs.set_value('Body', data.Body ? data.Body : 'N/D');
                campos_defs.set_value('Subject', data.Subject ? data.Subject : 'N/D');
                campos_defs.set_value('FromTitle', data.FromTitle ? data.FromTitle : 'N/D');
                campos_defs.set_value('cco', data.cco ? data.cco : 'N/D');

                // Config SMTP
                campos_defs.set_value('mail_server', data.mail_server ? data.mail_server : 'N/D');
                campos_defs.set_value('smtp_server', data.smtp_server ? data.smtp_server : 'N/D');
                campos_defs.set_value('smtp_port', data.smtp_port ? data.smtp_port : 'N/D');
                campos_defs.set_value('smtp_user', data.smtp_user ? data.smtp_user : 'N/D');
                campos_defs.set_value('smtp_pwd', data.smtp_pwd ? data.smtp_pwd : 'N/D');
                campos_defs.set_value('smtp_secure', data.smtp_secure.toString().toLowerCase() === 'true' ? '1' : '0');
            }
        }


        function configEmail_setEdition()
        {
            campos_defs.habilitar('mail_cfgs', modo_edicion);
            campos_defs.habilitar('req_email_codeLength', modo_edicion);
            campos_defs.habilitar('req_email_codeTimeout', modo_edicion);
            campos_defs.habilitar('req_email_codeMaxFails', modo_edicion);
            campos_defs.habilitar('Body', modo_edicion);
            campos_defs.habilitar('Subject', modo_edicion);
            campos_defs.habilitar('FromTitle', modo_edicion);
            campos_defs.habilitar('cco', modo_edicion);
            campos_defs.habilitar('mail_server', modo_edicion);
            campos_defs.habilitar('smtp_server', modo_edicion);
            campos_defs.habilitar('smtp_port', modo_edicion);
            campos_defs.habilitar('smtp_user', modo_edicion);
            campos_defs.habilitar('smtp_pwd', modo_edicion);
            campos_defs.habilitar('smtp_secure', modo_edicion);
        }


        /*---------------------------------------------------------------------
        | 
        |                                 ABM
        | 
        |--------------------------------------------------------------------*/
        function configEmail_nueva()
        {
            // Configs generales de código
            campos_defs.set_value('mail_cfgs', '');
            campos_defs.set_value('req_email_codeLength', '');
            campos_defs.set_value('req_email_codeTimeout', '');
            campos_defs.set_value('req_email_codeMaxFails', '');

            // Configs mensajes
            campos_defs.set_value('Body', '');
            campos_defs.set_value('Subject', '');
            campos_defs.set_value('FromTitle', '');
            campos_defs.set_value('cco', '');

            // Config SMTP
            campos_defs.set_value('mail_server', '');
            campos_defs.set_value('smtp_server', '');
            campos_defs.set_value('smtp_port', '');
            campos_defs.set_value('smtp_user', '');
            campos_defs.set_value('smtp_pwd', '');
            campos_defs.set_value('smtp_secure', '');
            
            modo_edicion = true;
            configEmail_setMenu();
            configEmail_setEdition();
        }


        function configEmail_editar()
        {
            modo_edicion = true;
            configEmail_setMenu();
            configEmail_setEdition();
        }


        function configEmail_save()
        {
            alert("no implementado!");
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <div id="divMenu"></div>

    <table class="tb1 highlightTROver highlightOdd">
        <tr class="tr_seccion">
            <td colspan="2">Codigo</td>
        </tr>
        <tr class="tbLabel">
            <td style="width: 40%; min-width: 180px; max-width: 200px;">Opción</td>
            <td>Valor</td>
        </tr>
        <tr>
            <td class="Tit1">Configuración</td>
            <td id="tdCfgName"></td>
        </tr>
        <tr>
            <td class="Tit1">Largo de código</td>
            <td id="tdCodeLength"></td>
        </tr>
        <tr>
            <td class="Tit1">Timeout</td>
            <td id="tdTimeout"></td>
        </tr>
        <tr>
            <td class="Tit1">Máximo códigos fallidos</td>
            <td id="tdMaxFails"></td>
        </tr>


        <tr class="tr_seccion">
            <td colspan="2">Mensaje</td>
        </tr>
        <tr class="tbLabel">
            <td style="width: 45%;">Opción</td>
            <td>Valor</td>
        </tr>
        <tr>
            <td class="Tit1">Body</td>
            <td id="tdBody"></td>
        </tr>
        <tr>
            <td class="Tit1">Asunto</td>
            <td id="tdSubject"></td>
        </tr>
        <tr>
            <td class="Tit1">Título Desde</td>
            <td id="tdFromTitle"></td>
        </tr>
        <tr>
            <td class="Tit1">CCO</td>
            <td id="tdCCO"></td>
        </tr>


        <tr class="tr_seccion">
            <td colspan="2">SMTP</td>
        </tr>
        <tr class="tbLabel">
            <td style="width: 45%;">Opción</td>
            <td>Valor</td>
        </tr>
        <tr>
            <td class="Tit1">Nombre Server</td>
            <td id="tdServerName"></td>
        </tr>
        <tr>
            <td class="Tit1">Server</td>
            <td id="tdServer"></td>
        </tr>
        <tr>
            <td class="Tit1">Puerto</td>
            <td id="tdPort"></td>
        </tr>
        <tr>
            <td class="Tit1">Usuario</td>
            <td id="tdUser"></td>
        </tr>
        <tr>
            <td class="Tit1">Password</td>
            <td id="tdPwd"></td>
        </tr>
        <tr>
            <td class="Tit1">Seguridad</td>
            <td id="tdSecure"></td>
        </tr>
    </table>
</body>
</html>
