<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim mail_server_id As String = nvUtiles.obtenerValor("mail_server_id", "")

    If modo <> "" AndAlso ({"A", "M"}.Contains(modo.ToUpper())) Then
        Dim err As New tError
        Dim mail_server As String = nvUtiles.obtenerValor("mail_server", "")
        Dim smtp_server As String = nvUtiles.obtenerValor("smtp_server", "")
        Dim smtp_port As Integer = nvUtiles.obtenerValor("smtp_port", "0", nvConvertUtiles.DataTypes.int)
        Dim smtp_user As String = nvUtiles.obtenerValor("smtp_user", "")
        Dim smtp_pwd As String = nvUtiles.obtenerValor("smtp_pwd", "")
        Dim smtp_secure As Integer = nvUtiles.obtenerValor("smtp_secure", "0", nvConvertUtiles.DataTypes.int)

        If mail_server_id = "" OrElse mail_server = "" OrElse smtp_server = "" OrElse smtp_port = 0 OrElse smtp_user = "" OrElse smtp_pwd = "" Then
            err.numError = 10
            err.titulo = "Error en Parámetros"
            err.mensaje = "Uno o mas parámetros suministrados son nulos o inválidos"
            err.debug_src = "ids_config_email_server"
            err.response()
        End If

        Dim sb As New StringBuilder()
        err.params("modo") = modo.ToUpper()

        Select Case modo.ToUpper()

            ' Alta
            Case "A"
                sb.Clear()
                sb.Append("INSERT INTO mail_servers (id_tipo, nro_com_id_tipo, mail_server_id, mail_server, smtp_server, smtp_port, smtp_user, smtp_pwd, smtp_secure) ")
                sb.Append("VALUES (")
                sb.AppendFormat("{0}, {1}, '{2}', '{3}', '{4}', {5}, '{6}', '{7}', {8}", 1, 0, mail_server_id, mail_server, smtp_server, smtp_port, smtp_user, smtp_pwd, smtp_secure)
                sb.Append(")")

                Try
                    nvDBUtiles.DBExecute(sb.ToString())
                    err.params("mail_server_id") = mail_server_id
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Alta"
                    err.mensaje = "No fué posible realizar el alta de configuración."
                    err.debug_src = "ids_config_email_server.aspx::alta"
                    err.debug_desc = sb.ToString()
                End Try


            ' Modifcacion
            Case "M"
                sb.Clear()
                sb.Append("UPDATE mail_servers SET ")
                sb.AppendFormat("mail_server='{0}', ", mail_server)
                sb.AppendFormat("smtp_server='{0}', ", smtp_server)
                sb.AppendFormat("smtp_port={0}, ", smtp_port)
                sb.AppendFormat("smtp_user='{0}', ", smtp_user)
                sb.AppendFormat("smtp_pwd='{0}', ", smtp_pwd)
                sb.AppendFormat("smtp_secure={0} ", smtp_secure)
                sb.AppendFormat("WHERE mail_server_id='{0}'", mail_server_id)

                Try
                    nvDBUtiles.DBExecute(sb.ToString())
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Modificación"
                    err.mensaje = "No fué posible realizar la modificación de configuración."
                    err.debug_src = "ids_config_email_server.aspx::modificacion"
                    err.debug_desc = sb.ToString()
                End Try

        End Select

        err.response()
    End If


    ' Obtener los datos
    Dim data As New trsParam

    If mail_server_id <> "" Then
        Dim strSQL As String = String.Format("SELECT * FROM mail_servers WHERE mail_server_id='{0}'", mail_server_id)
        Dim rs As ADODB.Recordset


        Try
            rs = nvDBUtiles.DBExecute(strSQL)

            If Not rs.EOF Then
                data("mail_server_id") = rs.Fields("mail_server_id").Value
                data("mail_server") = rs.Fields("mail_server").Value
                data("smtp_server") = rs.Fields("smtp_server").Value
                data("smtp_port") = rs.Fields("smtp_port").Value
                data("smtp_user") = rs.Fields("smtp_user").Value
                data("smtp_pwd") = rs.Fields("smtp_pwd").Value
                data("smtp_secure") = rs.Fields("smtp_secure").Value
            End If

            nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
        End Try
    End If


    Me.contents("data") = data
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es-ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <title>Configuración Server de Email</title>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <style>
        body {
            width: 100%;
            height: 100%;
            overflow: hidden;
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


        function normalizarID(strID)
        {
            return strID.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
        }
    </script>

    <script type="text/javascript">
        var win          = nvFW.getMyWindow();;
        var data         = !isEmpty(nvFW.pageContents.data) ? nvFW.pageContents.data : null;
        var modo_edicion = false;
        var nueva_cfg    = !data ? true : false;



        function windowOnload()
        {
            loadMenu();
            setMenu();
            makeFields();   // armar los campos
            
            if (data) {
                setValues();    // setear sus valores
                setEdition();   // bloquear o habilitar los campos segun este activo o no el modo de edicion
            }
            else {
                // Si no hya datos, asumimos que queremos una nueva config
                nueva();
            }

            windowOnresize();
        }

        
        function windowOnresize()
        {
        }
        
        
        function loadMenu()
        {
            $('divMenu').innerHTML = '';    // Limpiar el contenedor antes de cargar
            vMenu = new tMenu('divMenu', 'vMenu');

            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>save()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_cerrar</icono><Desc>Guardar y Salir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>save(true)</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editar()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva()</Codigo></Ejecutar></Acciones></MenuItem>");

            vMenu.loadImage('guardar', '/IDS/image/icons/guardar.png');
            vMenu.loadImage('guardar_cerrar', '/IDS/image/icons/guardar_cerrar.png');
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
            |       1 - Guardar y Salir
            |       2 - Editar
            |       3 - Espacio disponible
            |       4 - Nuevo
            |----------------------------------------------------------------*/
            $tds = $$('#vMenu td');

            if (modo_edicion)
            {
                $tds[0].show();
                $tds[1].show();
                $tds[2].hide();
            }
            else {
                $tds[0].hide();
                $tds[1].hide();
                $tds[2].show();
            }
        }


        function makeFields()
        {
            campos_defs.add('mail_server_id', { enDB: false, nro_campo_tipo: 104, target: 'tdMailServerId', placeholder: 'id_config_email' });
            campos_defs.habilitar('mail_server_id', false);
            campos_defs.add('mail_server', { enDB: false, nro_campo_tipo: 104, target: 'tdServerName', placeholder: 'Servicio de mail para XYZ' });
            campos_defs.add('smtp_server', { enDB: false, nro_campo_tipo: 104, target: 'tdServer', placeholder: 'mail.xyz.com.ar' });
            campos_defs.add('smtp_port', { enDB: false, nro_campo_tipo: 100, target: 'tdPort', placeholder: '587' });
            campos_defs.add('smtp_user', { enDB: false, nro_campo_tipo: 104, target: 'tdUser', placeholder: 'john@xyz.com.ar' });
            campos_defs.add('smtp_pwd', { enDB: false, nro_campo_tipo: 104, target: 'tdPwd', placeholder: 'm1pas$w0rd9.' });
            campos_defs.add('smtp_secure', { enDB: false, nro_campo_tipo: 1, target: 'tdSecure', placeholder: 'Seleccionar', mostrar_codigo: false, despliega: 'arriba' });
            
            var rs = new tRS();
            rs.addField('id', 'string');
            rs.addField('campo', 'string');
            rs.addRecord({ 'id': '0', 'campo': 'Si' });
            rs.addRecord({ 'id': '1', 'campo': 'No' });

            campos_defs.items['smtp_secure'].rs = rs;
        }


        function setValues()
        {
            if (data)
            {
                campos_defs.set_value('mail_server_id', data.mail_server_id ? data.mail_server_id : '');
                campos_defs.set_value('mail_server',    data.mail_server ? data.mail_server : '');
                campos_defs.set_value('smtp_server',    data.smtp_server ? data.smtp_server : '');
                campos_defs.set_value('smtp_port',      data.smtp_port ? data.smtp_port : '');
                campos_defs.set_value('smtp_user',      data.smtp_user ? data.smtp_user : '');
                campos_defs.set_value('smtp_pwd',       data.smtp_pwd ? data.smtp_pwd : '');
                campos_defs.set_value('smtp_secure',    data.smtp_secure.toString().toLowerCase() === 'true' ? '1' : '0');
            }
        }


        function setEdition()
        {
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
        function nueva()
        {
            nueva_cfg = true;
            campos_defs.habilitar('mail_server_id', true);
            campos_defs.clear('mail_server_id');
            campos_defs.clear('mail_server');
            campos_defs.clear('smtp_server');
            campos_defs.clear('smtp_port');
            campos_defs.clear('smtp_user');
            campos_defs.clear('smtp_pwd');
            campos_defs.clear('smtp_secure');
            
            modo_edicion = true;
            setMenu();
            setEdition();

            campos_defs.focus('mail_server_id');
        }


        function editar()
        {
            modo_edicion = true;
            setMenu();
            setEdition();
        }


        function save(close_after_save)
        {
            var error_msg = validateFields();

            if (error_msg)
            {
                alert(error_msg, { title: '<b>Error: campos sin completar</b>', width: 450, heihgt: 110 });
                return false;
            }

            close_after_save = close_after_save ? close_after_save : false;

            var options = {
                parameters:
                {
                    modo:           nueva_cfg ? 'A' : 'M',
                    mail_server_id: normalizarID(campos_defs.get_value('mail_server_id').trim()).replace(/\s+/g, '_'),   // sacamos espacios al inicio y final; reemplazamos los espacios intermedios con '_'
                    mail_server:    campos_defs.get_value('mail_server'),
                    smtp_server:    campos_defs.get_value('smtp_server'),
                    smtp_port:      campos_defs.get_value('smtp_port'),
                    smtp_user:      campos_defs.get_value('smtp_user'),
                    smtp_pwd:       campos_defs.get_value('smtp_pwd'),
                    smtp_secure:    campos_defs.get_value('smtp_secure')
                },
                onSuccess: function (res)
                {
                    campos_defs.habilitar('mail_server_id', false); // Deshabilitar el campo ID
                    win.options.userData.reload  = true;
                    nueva_cfg                    = false;  // Ya se guardó, no es mas nueva config.

                    if (res.params.modo === 'A') campos_defs.set_value('mail_server_id', res.params.mail_server_id); // Actualizar el ID, ya que se pudo cambiar algun espacio por '_'.
                    if (close_after_save) win.close();
                },
                onFailure: function (res)
                {
                    alert(res.mensaje, { title: '<b>' + res.titulo + '</b>' });
                },
                error_alert:     false,
                bloq_contenedor: $$('body')[0],
                bloq_msg:        'Guardando...'
            };

            nvFW.error_ajax_request('ids_config_email_server.aspx', options);
        }


        function validateFields()
        {
            var error_msg = '';

            if (nueva_cfg && !campos_defs.get_value('mail_server_id')) error_msg += '* ID Server<br>';
            if (!campos_defs.get_value('mail_server')) error_msg += '* Descripción Server<br>'
            if (!campos_defs.get_value('smtp_server')) error_msg += '* SMTP Server<br>'
            if (!campos_defs.get_value('smtp_port')) error_msg += '* SMTP Port<br>'
            if (!campos_defs.get_value('smtp_user')) error_msg += '* SMTP Usuario<br>'
            if (!campos_defs.get_value('smtp_pwd')) error_msg += '* SMTP Password<br>'
            if (!campos_defs.get_value('smtp_secure')) error_msg += '* SMTP Seguridad<br>'

            return error_msg;
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <div id="divMenu"></div>

    <table class="tb1 highlightTROver highlightOdd">
        <tr class="tbLabel">
            <td style="width: 45%;">Opción</td><td>Valor</td>
        </tr>
        <tr>
            <td class="Tit1">ID Server</td>
            <td id="tdMailServerId"></td>
        </tr>
        <tr>
            <td class="Tit1">Descripción Server</td>
            <td id="tdServerName"></td>
        </tr>
        <tr>
            <td class="Tit1">SMTP Server</td>
            <td id="tdServer"></td>
        </tr>
        <tr>
            <td class="Tit1">SMTP Puerto</td>
            <td id="tdPort"></td>
        </tr>
        <tr>
            <td class="Tit1">SMTP Usuario</td>
            <td id="tdUser"></td>
        </tr>
        <tr>
            <td class="Tit1">SMTP Password</td>
            <td id="tdPwd"></td>
        </tr>
        <tr>
            <td class="Tit1">SMTP Seguridad</td>
            <td id="tdSecure"></td>
        </tr>
    </table>
</body>
</html>
