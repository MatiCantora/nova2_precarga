<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim mail_cfgs_id As String = nvUtiles.obtenerValor("mail_cfgs_id", "")

    If modo <> "" AndAlso ({"A", "M"}.Contains(modo.ToUpper())) Then
        Dim err As New tError

        Dim mail_cfgs As String = nvUtiles.obtenerValor("mail_cfgs", "")
        Dim Body As String = nvUtiles.obtenerValor("Body", "")
        Dim Subject As String = nvUtiles.obtenerValor("Subject", "")
        Dim FromTitle As String = nvUtiles.obtenerValor("FromTitle", "")
        Dim cco As String = nvUtiles.obtenerValor("cco", "")
        Dim mail_server_id As String = nvUtiles.obtenerValor("mail_server_id", "")

        If mail_cfgs_id = "" OrElse mail_cfgs = "" Then
            err.numError = 10
            err.titulo = "Error en Parámetros"
            err.mensaje = "Uno o mas parámetros suministrados son nulos o inválidos. El ID y su descripción deben contener un valor."
            err.debug_src = "ids_config_email"
            err.response()
        End If

        Dim sb As New StringBuilder()
        err.params("modo") = modo.ToUpper()

        Select Case modo.ToUpper()

            ' Alta
            Case "A"
                sb.Clear()
                sb.Append("INSERT INTO mail_cfgs (id_tipo, nro_com_id_tipo, mail_cfgs_id, mail_cfgs, [Body], [Subject], [FromTitle], [cco], mail_server_id) ")
                sb.Append("VALUES (")
                sb.AppendFormat("{0}, {1}, '{2}', '{3}', '{4}', '{5}', '{6}', '{7}', '{8}'", 1, 0, mail_cfgs_id, mail_cfgs, Body, Subject, FromTitle, cco, mail_server_id)
                sb.Append(")")

                Try
                    nvDBUtiles.DBExecute(sb.ToString())
                    err.params("mail_cfgs_id") = mail_cfgs_id
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Alta"
                    err.mensaje = "No fué posible realizar el alta de configuración."
                    err.debug_src = "ids_config_email::alta"
                    err.debug_desc = sb.ToString()
                End Try


            ' Modifcacion
            Case "M"
                sb.Clear()
                sb.Append("UPDATE mail_cfgs SET ")
                sb.AppendFormat("mail_cfgs='{0}', ", mail_cfgs)
                sb.AppendFormat("[Body]='{0}', ", Body)
                sb.AppendFormat("[Subject]='{0}', ", Subject)
                sb.AppendFormat("[FromTitle]='{0}', ", FromTitle)
                sb.AppendFormat("[cco]='{0}', ", cco)
                sb.AppendFormat("mail_server_id='{0}' ", mail_server_id)
                sb.AppendFormat("WHERE mail_cfgs_id='{0}'", mail_cfgs_id)

                Try
                    nvDBUtiles.DBExecute(sb.ToString())
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Modificación"
                    err.mensaje = "No fué posible realizar la modificación de configuración."
                    err.debug_src = "ids_config_email::modificacion"
                    err.debug_desc = sb.ToString()
                End Try

        End Select

        err.response()
    End If


    ' Obtener los datos
    Dim data As New trsParam

    If mail_cfgs_id <> "" Then
        Dim strSQL As String = String.Format("SELECT * FROM mail_cfgs WHERE mail_cfgs_id='{0}'", mail_cfgs_id)
        Dim rs As ADODB.Recordset

        Try
            rs = nvDBUtiles.DBExecute(strSQL)

            If Not rs.EOF Then
                data("mail_cfgs_id") = rs.Fields("mail_cfgs_id").Value
                data("mail_cfgs") = rs.Fields("mail_cfgs").Value
                data("Body") = rs.Fields("Body").Value
                data("Subject") = rs.Fields("Subject").Value
                data("FromTitle") = rs.Fields("FromTitle").Value
                data("cco") = rs.Fields("cco").Value
                data("mail_server_id") = rs.Fields("mail_server_id").Value
            End If

            nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
        End Try
    End If


    Me.contents("data") = data
    Me.contents("filtro_mail_servers") = nvXMLSQL.encXMLSQL("<criterio><select vista='mail_servers'><campos>mail_server_id as [id], mail_server as [campo]</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("solo_consulta") = nvUtiles.obtenerValor("solo_consulta", "0")
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es-ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <title>Configuración Email</title>
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
        textarea {
            width: 100%;
            margin: 0;
            resize: vertical;
        }
        input:disabled,
        select:disabled,
        textarea:disabled {
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
        var solo_consulta = parseInt(nvFW.pageContents.solo_consulta) === 1;
        var nueva_cfg    = !data ? true : false;
        var vMenu;



        function windowOnload()
        {
            nvFW.enterToTab = false;

            if (!solo_consulta) {
                loadMenu();
                setMenu();
            }

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
            campos_defs.add('mail_cfgs_id', { enDB: false, nro_campo_tipo: 104, target: 'tdMailCfgsId', placeholder: 'id_config_email' });
            campos_defs.habilitar('mail_cfgs_id', false);
            campos_defs.add('mail_cfgs', { enDB: false, nro_campo_tipo: 104, target: 'tdMailCfgs', placeholder: 'Mail para Empresa X ...' });
            campos_defs.add('FromTitle', { enDB: false, nro_campo_tipo: 104, target: 'tdFromTitle', placeholder: 'Informes Empresa X' });
            campos_defs.add('cco', { enDB: false, nro_campo_tipo: 104, target: 'tdCCO', placeholder: 'Emails con copia oculta: fake@info.com' });
            campos_defs.add('Subject', { enDB: false, nro_campo_tipo: 104, target: 'tdSubject', placeholder: 'Asunto del mensaje' });
            campos_defs.add('mail_server_id', {
                enDB:           false, 
                nro_campo_tipo: 1, 
                filtroXML:      nvFW.pageContents.filtro_mail_servers,
                filtroWhere:    '',
                target:         'tdMailServerId', 
                placeholder:    'Seleccionar', 
                mostrar_codigo: false, 
                despliega:      'arriba'
            });
        }


        function setValues()
        {
            if (data)
            {
                campos_defs.set_value('mail_cfgs_id',   data.mail_cfgs_id ? data.mail_cfgs_id : '');
                campos_defs.set_value('mail_cfgs',      data.mail_cfgs ? data.mail_cfgs : '');
                campos_defs.set_value('FromTitle',      data.FromTitle ? data.FromTitle : '');
                campos_defs.set_value('cco',            data.cco ? data.cco : '');
                campos_defs.set_value('Subject',        data.Subject ? data.Subject : '');
                campos_defs.set_value('mail_server_id', data.mail_server_id ? data.mail_server_id : '');
                $('Body').value = data.Body ? data.Body : '';
            }
        }


        function setEdition()
        {
            campos_defs.habilitar('mail_cfgs', modo_edicion);
            campos_defs.habilitar('FromTitle', modo_edicion);
            campos_defs.habilitar('cco', modo_edicion);
            campos_defs.habilitar('Subject', modo_edicion);
            campos_defs.habilitar('mail_server_id', modo_edicion);
            $('Body').disabled = !modo_edicion;
        }


        /*---------------------------------------------------------------------
        | 
        |                                 ABM
        | 
        |--------------------------------------------------------------------*/
        function nueva()
        {
            nueva_cfg = true;
            campos_defs.habilitar('mail_cfgs_id', true);
            campos_defs.set_value('mail_cfgs_id', '');
            campos_defs.set_value('mail_cfgs', '');
            campos_defs.set_value('FromTitle', '');
            campos_defs.set_value('cco', '');
            campos_defs.set_value('Subject', '');
            campos_defs.set_value('mail_server_id', '');
            $('Body').value = '';
            
            modo_edicion = true;
            setMenu();
            setEdition();

            campos_defs.focus('mail_cfgs_id');
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
                    mail_cfgs_id:   normalizarID(campos_defs.get_value('mail_cfgs_id').trim()).replace(/\s+/g, '_'),   // sacamos espacios al inicio y final; reemplazamos los espacios intermedios con '_'
                    mail_cfgs:      campos_defs.get_value('mail_cfgs'),
                    FromTitle:      campos_defs.get_value('FromTitle'),
                    cco:            campos_defs.get_value('cco'),
                    Subject:        campos_defs.get_value('Subject'),
                    mail_server_id: campos_defs.get_value('mail_server_id'),
                    Body:           $('Body').value
                },
                onSuccess: function (res)
                {
                    campos_defs.habilitar('mail_cfgs_id', false); // Deshabilitar el campo ID
                    nueva_cfg                    = false;  // Ya se guardó, no es mas nueva config.
                    win.options.userData.reload  = true;

                    if (res.params.modo === 'A') campos_defs.set_value('mail_cfgs_id', res.params.mail_cfgs_id); // Actualizar el ID, ya que se pudo cambiar algun espacio por '_'.
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

            nvFW.error_ajax_request('ids_config_email.aspx', options);
        }


        function validateFields()
        {
            var error_msg = '';

            if (nueva_cfg && !campos_defs.get_value('mail_cfgs_id')) error_msg += '* ID Email Config<br>';
            if (!campos_defs.get_value('mail_cfgs')) error_msg += '* Descripción<br>'
            if (!campos_defs.get_value('mail_server_id')) error_msg += '* Servidor MAIL<br>'

            return error_msg;
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <div id="divMenu"></div>

    <table class="tb1 highlightTROver highlightOdd">
        <tr class="tbLabel">
            <td style="max-width: 200px;">Opción</td><td>Valor</td>
        </tr>
        <tr>
            <td class="Tit1">ID Email Config</td>
            <td id="tdMailCfgsId"></td>
        </tr>
        <tr>
            <td class="Tit1">Descripción</td>
            <td id="tdMailCfgs"></td>
        </tr>
        <tr>
            <td class="Tit1">Título 'DE'</td>
            <td id="tdFromTitle"></td>
        </tr>
        <tr>
            <td class="Tit1">CCO</td>
            <td id="tdCCO"></td>
        </tr>
        <tr>
            <td class="Tit1">Asunto</td>
            <td id="tdSubject"></td>
        </tr>
        <tr>
            <td class="Tit1">Cuerpo del Mensaje</td>
            <td id="tdBody">
                <textarea id="Body" name="Body" rows="5"></textarea>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Servidor MAIL</td>
            <td id="tdMailServerId"></td>
        </tr>
    </table>
</body>
</html>
