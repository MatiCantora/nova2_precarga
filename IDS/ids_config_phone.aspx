<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    ' Parametros necesarios para guardar
    Dim ids_cli_id As Integer = nvUtiles.obtenerValor("ids_cli_id", "-1", nvConvertUtiles.DataTypes.int)
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")
    Dim ids_event_id As String = nvUtiles.obtenerValor("ids_event_id", "")

    If modo <> "" Then
        Dim err As New tError
        err.debug_src = "ids_config_phone::save"

        If ids_cli_id = -1 OrElse ids_res_id = "" OrElse ids_event_id = "" Then
            err.numError = 151
            err.titulo = "Error"
            err.mensaje = "No se obtuvieron los datos del cliente, recurso o evento."
            err.response()
        End If

        Select Case modo.ToUpper
            Case "SAVE"
                Dim req_phone_text As String = nvUtiles.obtenerValor("req_phone_text", "")
                Dim req_phone_codeLength As Integer = nvUtiles.obtenerValor("req_phone_codeLength", "0", nvConvertUtiles.DataTypes.int)
                Dim req_phone_codeTimeout As Integer = nvUtiles.obtenerValor("req_phone_codeTimeout", "-99", nvConvertUtiles.DataTypes.int)

                If req_phone_text = "" OrElse req_phone_codeLength = 0 OrElse req_phone_codeTimeout = -99 Then
                    err.numError = 150
                    err.titulo = "Error en parámetros"
                    err.mensaje = "Uno o más parámetros son nulos o inválidos."
                    err.response()
                End If

                err.mensaje = "Salvado OK!"
                err.params("req_phone_text") = req_phone_text
                err.params("req_phone_codeLength") = req_phone_codeLength
                err.params("req_phone_codeTimeout") = req_phone_codeTimeout
        End Select

        err.response()
    End If

    Me.contents("ids_cli_id") = ids_cli_id
    Me.contents("ids_res_id") = ids_res_id
    Me.contents("ids_event_id") = ids_event_id
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <title>Configuración de Teléfono</title>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win;
        var data;
        var vMenu;
        var modo_edicion = false;
        var ids_cli_id   = nvFW.pageContents.ids_cli_id;
        var ids_res_id   = nvFW.pageContents.ids_res_id;
        var ids_event_id = nvFW.pageContents.ids_event_id;



        function loadMenu()
        {
            $('divMenu').innerHTML = '';    // Limpiar el contenedor antes de cargar
            vMenu = new tMenu('divMenu', 'vMenu');

            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>saveConfig()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editConfig()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>newConfig()</Codigo></Ejecutar></Acciones></MenuItem>");

            vMenu.loadImage('guardar', '/IDS/image/icons/guardar.png');
            vMenu.loadImage('editar', '/IDS/image/icons/editar.png');
            vMenu.loadImage('nuevo', '/IDS/image/icons/nueva.png');

            vMenu.MostrarMenu();
        }


        function setMenu()
        {
            /*-----------------------------------------------------------------
            |   Orden del menu
            |------------------------------------------------------------------
            |       0 - Guardar
            |       1 - Editar
            |       2 - Espacio vacío disponible
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


        function makeFields()
        {
            campos_defs.add('req_phone_text', { enDB: false, nro_campo_tipo: 104, target: 'tdTexto', placeholder: 'Texto de muestra en el mensaje.' });
            campos_defs.add('req_phone_codeLength', { enDB: false, nro_campo_tipo: 100, target: 'tdCodeLength', placeholder: '0' });
            campos_defs.add('req_phone_codeTimeout', { enDB: false, nro_campo_tipo: 100, target: 'tdTimeout', placeholder: '0' });
        }


        function setValues()
        {
            if (data)
            {
                campos_defs.set_value('req_phone_text', data.text ? data.text : '');
                campos_defs.set_value('req_phone_codeLength', data.codeLength ? data.codeLength : '');
                campos_defs.set_value('req_phone_codeTimeout', data.codeTimeout ? data.codeTimeout : '');
            }
        }


        function setEdition()
        {
            campos_defs.habilitar('req_phone_text', modo_edicion);
            campos_defs.habilitar('req_phone_codeLength', modo_edicion);
            campos_defs.habilitar('req_phone_codeTimeout', modo_edicion);
        }


        function windowOnresize()
        {
        }


        function windowOnload()
        {
            nvFW.enterToTab = false;
            loadMenu();
            setMenu();

            win  = nvFW.getMyWindow();
            data = win.options.userData;
            
            makeFields();
            setValues();
            setEdition();

            windowOnresize();
        }


        /*---------------------------------------------------------------------
        |
        |                                 ABM
        |
        |--------------------------------------------------------------------*/
        function saveConfig()
        {
            var msg = [];
            
            if (!campos_defs.get_value('req_phone_text')) msg.push('<b>Cuerpo de mensaje</b>');
            if (!campos_defs.get_value('req_phone_codeLength')) msg.push('<b>Longitud de código</b>');
            if (!campos_defs.get_value('req_phone_codeTimeout')) msg.push('<b>TimeOut</b>');

            if (msg.length)
            {
                var msg_salida = msg.length === 1 ? 'El campo ' + msg[0] + ' es obligatorio y no puede estar vacío para guardar.' : 'Los campos ' + msg.join(', ') + ' son obligatorios y no pueden estar vacíos para guardar.';

                alert(msg_salida, { title: '<b>Error al Guardar</b>', width: 400 });
                return false;
            }

            // Opciones para el error_ajax_request
            var options = {
                parameters:
                {
                    modo:                  'SAVE',
                    ids_cli_id:            ids_cli_id,
                    ids_res_id:            ids_res_id,
                    ids_event_id:          ids_event_id,
                    req_phone_text:        campos_defs.get_value('req_phone_text'),
                    req_phone_codeLength:  campos_defs.get_value('req_phone_codeLength'),
                    req_phone_codeTimeout: campos_defs.get_value('req_phone_codeTimeout')
                },
                onSuccess: function (err)
                {
                    //// @@@@ completar con los resultados
                    console.table(err.params);
                },
                onFailure: function (err)
                {
                    alert(err.mensaje, { title: '<b>' + err.titulo + '</b>' });
                },
                error_alert:     true,
                bloq_contenedor: $$('body')[0],
                bloq_msg:        'Guardando...'
            };

            nvFW.error_ajax_request('ids_config_phone.aspx', options);
        }


        function editConfig()
        {
            modo_edicion = true;
            setMenu();
            setEdition();

            // Hacer foco en el primer campo
            campos_defs.focus('req_phone_text');
        }


        function newConfig()
        {
            // Limpiar los campos_defs
            campos_defs.clear('req_phone_text');
            campos_defs.clear('req_phone_codeLength');
            campos_defs.clear('req_phone_codeTimeout');

            // Llamar al modo de edición
            editConfig();
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <div id="divMenu"></div>

    <table class="tb1 highlightTROver highlightOdd">
        <tr class="tbLabel">
            <td style="min-width: 150px; width: 30%; text-align: center;">Opción</td>
            <td style="text-align: center;">Valor</td>
        </tr>
        <tr>
            <td class="Tit1">Cuerpo del mensaje</td>
            <td id="tdTexto"></td>
        </tr>
        <tr>
            <td class="Tit1">Logitud de código</td>
            <td id="tdCodeLength"></td>
        </tr>
        <tr>
            <td class="Tit1">Timeout</td>
            <td id="tdTimeout"></td>
        </tr>
    </table>

</body>
</html>
