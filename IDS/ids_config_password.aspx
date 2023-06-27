<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim ids_pwdcfg_id As Integer = nvUtiles.obtenerValor("ids_pwdcfg_id", "0", nvConvertUtiles.DataTypes.int)
    Dim ids_cli_id As Integer = Me.operador.ids_cli_id
    Dim modo As String = nvUtiles.obtenerValor("modo", "")

    If modo <> "" AndAlso {"A", "M"}.Contains(modo.ToUpper()) Then
        Dim err As New tError
        err.debug_src = "ids_config_password"
        err.params("modo") = modo.ToUpper()

        If ids_cli_id = 0 OrElse (ids_pwdcfg_id = 0 And modo.ToUpper() = "M") Then
            err.numError = 15
            err.titulo = "Error"
            err.mensaje = "El ID de cliente o de Config de Password es inválido"
            err.response()
        End If

        ' Recuperar todos los valores
        Dim ids_pwdcfg As String = nvUtiles.obtenerValor("ids_pwdcfg", "")

        If ids_pwdcfg = "" Then
            err.numError = 16
            err.titulo = "Error"
            err.mensaje = "La descripción de Config de Password no puede estar vacía."
            err.response()
        End If

        Dim pwd_minlength As Integer = nvUtiles.obtenerValor("pwd_minlength", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_maxlength As Integer = nvUtiles.obtenerValor("pwd_maxlength", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_includeUpperCase As Integer = nvUtiles.obtenerValor("pwd_includeUpperCase", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_includeLowerCase As Integer = nvUtiles.obtenerValor("pwd_includeLowerCase", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_includeSpecialChars As Integer = nvUtiles.obtenerValor("pwd_includeSpecialChars", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_maxPasswordAge As Integer = nvUtiles.obtenerValor("pwd_maxPasswordAge", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_minPasswordAge As Integer = nvUtiles.obtenerValor("pwd_minPasswordAge", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_LockoutThreshold As Integer = nvUtiles.obtenerValor("pwd_LockoutThreshold", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_LockoutObsWin As Integer = nvUtiles.obtenerValor("pwd_LockoutObsWin", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_LockoutDuration As Integer = nvUtiles.obtenerValor("pwd_LockoutDuration", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_historyDays As Integer = nvUtiles.obtenerValor("pwd_historyDays", "0", nvConvertUtiles.DataTypes.int)
        Dim pwd_version As String = nvUtiles.obtenerValor("pwd_version", "1.0.0")

        Dim sb As New StringBuilder()

        Select Case modo.ToUpper()
            ' Alta
            Case "A"
                ' 1) Buscar el ID más alto dentro de las configuraciones de PWD del cliente actual
                sb.Clear()
                sb.Append("DECLARE @new_ids_pwdcfg_id AS INT" & vbCrLf)
                sb.AppendFormat("SELECT @new_ids_pwdcfg_id = MAX(ids_pwdcfg_id) + 1 FROM ids_pwdcfgs WHERE ids_cli_id={0}" & vbCrLf, ids_cli_id)
                ' 2) Incrementar ese ID y usarlo como nuevo "ids_pwdcfg_id"
                sb.Append("INSERT INTO ids_pwdcfgs (")
                sb.Append("ids_cli_id, ids_pwdcfg_id, ids_pwdcfg, pwd_minlength, pwd_maxlength, ")
                sb.Append("pwd_includeUpperCase, pwd_includeLowerCase, pwd_includeSpecialChars, ")
                sb.Append("pwd_maxPasswordAge, pwd_minPasswordAge, pwd_LockoutThreshold, pwd_LockoutObsWin, pwd_LockoutDuration, ")
                sb.Append("pwd_historyDays, pwd_version) ")
                sb.Append("VALUES (")
                sb.AppendFormat("{0}, @new_ids_pwdcfg_id, '{1}', ", ids_cli_id, ids_pwdcfg)
                sb.AppendFormat("{0}, {1}, ", pwd_minlength, pwd_maxlength)
                sb.AppendFormat("{0}, {1}, {2}, ", pwd_includeUpperCase, pwd_includeLowerCase, pwd_includeSpecialChars)
                sb.AppendFormat("{0}, {1}, ", pwd_maxPasswordAge, pwd_minPasswordAge)
                sb.AppendFormat("{0}, {1}, {2}, ", pwd_LockoutThreshold, pwd_LockoutObsWin, pwd_LockoutDuration)
                sb.AppendFormat("{0}, '{1}'", pwd_historyDays, pwd_version)
                sb.Append(")" & vbCrLf)
                ' 3) Selecciono el nuevo ID para pasarlo al front
                sb.Append("SELECT @new_ids_pwdcfg_id AS ids_pwdcfg_id")

                Try
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(sb.ToString())

                    If Not rs.EOF Then
                        ids_pwdcfg_id = rs.Fields("ids_pwdcfg_id").Value
                        err.params("ids_pwdcfg_id") = ids_pwdcfg_id
                    Else
                        err.params("ids_pwdcfg_id") = 0
                    End If

                    nvDBUtiles.DBCloseRecordset(rs)
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Alta"
                    err.mensaje = "No fué posible realizar el alta debido a un error."
                    err.debug_src &= "::alta"
                End Try


                ' Modificación
            Case "M"
                sb.Clear()
                sb.Append("UPDATE ids_pwdcfgs SET ")
                sb.AppendFormat("ids_pwdcfg='{0}', pwd_minlength={1}, pwd_maxlength={2}, ", ids_pwdcfg, pwd_minlength, pwd_maxlength)
                sb.AppendFormat("pwd_includeUpperCase={0}, pwd_includeLowerCase={1}, pwd_includeSpecialChars={2}, ", pwd_includeUpperCase, pwd_includeLowerCase, pwd_includeSpecialChars)
                sb.AppendFormat("pwd_maxPasswordAge={0}, pwd_minPasswordAge={1}, ", pwd_maxPasswordAge, pwd_minPasswordAge)
                sb.AppendFormat("pwd_LockoutThreshold={0}, pwd_LockoutObsWin={1}, pwd_LockoutDuration={2}, ", pwd_LockoutThreshold, pwd_LockoutObsWin, pwd_LockoutDuration)
                sb.AppendFormat("pwd_historyDays={0}, pwd_version='{1}' ", pwd_historyDays, pwd_version)
                sb.AppendFormat("WHERE ids_cli_id={0} AND ids_pwdcfg_id={1}", ids_cli_id, ids_pwdcfg_id)

                Try
                    nvDBUtiles.DBExecute(sb.ToString())
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error en Modificación"
                    err.mensaje = "No fué posible realizar la modificación debido a un error."
                    err.debug_src &= "::modificacion"
                End Try

        End Select

        err.response()
    End If


    ' Recuperar los valores de configuración a partir del ID de Password
    Dim data As New trsParam

    If ids_pwdcfg_id <> 0 Then
        Dim strSQL As String = String.Format("SELECT * FROM ids_pwdcfgs WHERE ids_cli_id={0} AND ids_pwdcfg_id={1}", ids_cli_id, ids_pwdcfg_id)
        Dim rs As ADODB.Recordset

        Try
            rs = nvDBUtiles.DBExecute(strSQL)

            If Not rs.EOF Then
                data("ids_pwdcfg_id") = rs.Fields("ids_pwdcfg_id").Value
                data("ids_pwdcfg") = rs.Fields("ids_pwdcfg").Value
                data("pwd_minlength") = rs.Fields("pwd_minlength").Value
                data("pwd_maxlength") = rs.Fields("pwd_maxlength").Value
                data("pwd_includeUpperCase") = rs.Fields("pwd_includeUpperCase").Value
                data("pwd_includeLowerCase") = rs.Fields("pwd_includeLowerCase").Value
                data("pwd_includeSpecialChars") = rs.Fields("pwd_includeSpecialChars").Value
                data("pwd_maxPasswordAge") = rs.Fields("pwd_maxPasswordAge").Value
                data("pwd_minPasswordAge") = rs.Fields("pwd_minPasswordAge").Value
                data("pwd_LockoutThreshold") = rs.Fields("pwd_LockoutThreshold").Value
                data("pwd_LockoutObsWin") = rs.Fields("pwd_LockoutObsWin").Value
                data("pwd_LockoutDuration") = rs.Fields("pwd_LockoutDuration").Value
                data("pwd_historyDays") = rs.Fields("pwd_historyDays").Value
                data("pwd_version") = rs.Fields("pwd_version").Value
            End If

            nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
        End Try
    End If


    Me.contents("data") = data
    Me.contents("solo_consulta") = nvUtiles.obtenerValor("solo_consulta", "0")
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <title>Configuración de Contaseñas</title>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <style>
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
    </script>

    <script type="text/javascript">
        var data          = !isEmpty(nvFW.pageContents.data) ? nvFW.pageContents.data : null;
        var solo_consulta = parseInt(nvFW.pageContents.solo_consulta) === 1;
        var modo_edicion  = false;
        var nueva_cfg     = false;
        var win;
        var vMenu;


                
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


        /**
         * Función para setear los botones del menu según se esté en modo de edición o no
         * 
         * El orden del menu es:
         *      0 - Guardar
         *      1 - Guardar y Salir
         *      2 - Editar
         *      3 - <<Espacio vacio disponible>>
         *      4 - Nuevo
         */
        function setMenu()
        {
            var tds = $$('#vMenu td');

            if (modo_edicion)
            {
                tds[2].hide();
                tds[0].show();
                tds[1].show();
            }
            else
            {
                tds[0].hide();
                tds[1].hide();
                tds[2].show();
            }
        }


        function windowOnload()
        {
            win          = nvFW.getMyWindow();

            if (!solo_consulta)
            {
                loadMenu();   // carga el menu
                setMenu();    // setea los botones que corresponden al modo (edicion o visualizacion)
            }

            makeFields(); // arma los campos de valores (campos_defs y selectores)
            setValues();  // setea los valores de los campos
            setEdition(); // habilita los campos si esta en modo edicion, caso contrario se bloquean los mismos

            windowOnresize();
        }


        function windowOnresize()
        {

        }


        function makeFields()
        {
            campos_defs.add('ids_pwdcfg_id', { enDB: false, nro_campo_tipo: 100, target: 'tdIdsPwdcfgId', placeholder: '0' });
            campos_defs.habilitar('ids_pwdcfg_id', false);  // Siempre deshabilitado

            campos_defs.add('ids_pwdcfg', { enDB: false, nro_campo_tipo: 104, target: 'tdIdsPwdcfg', placeholder: 'Nombre de config' });
            campos_defs.add('pwd_minlength', { enDB: false, nro_campo_tipo: 100, target: 'tdMinLength', placeholder: '0' });
            campos_defs.add('pwd_maxlength', { enDB: false, nro_campo_tipo: 100, target: 'tdMaxLength', placeholder: '0' });
            campos_defs.add('pwd_includeUpperCase', { enDB: false, nro_campo_tipo: 100, target: 'tdUpperCase', placeholder: '0' });
            campos_defs.add('pwd_includeLowerCase', { enDB: false, nro_campo_tipo: 100, target: 'tdLowerCase', placeholder: '0' });
            campos_defs.add('pwd_includeSpecialChars', { enDB: false, nro_campo_tipo: 100, target: 'tdSpecialChars', placeholder: '0' });
            campos_defs.add('pwd_maxPasswordAge', { enDB: false, nro_campo_tipo: 100, target: 'tdMaxPassAge', placeholder: '0' });
            campos_defs.add('pwd_minPasswordAge', { enDB: false, nro_campo_tipo: 100, target: 'tdMinPassAge', placeholder: '0' });
            campos_defs.add('pwd_LockoutThreshold', { enDB: false, nro_campo_tipo: 100, target: 'tdLockoutThreshold', placeholder: '0' });
            campos_defs.add('pwd_LockoutDuration', { enDB: false, nro_campo_tipo: 100, target: 'tdLockoutDuration', placeholder: '0' });
            campos_defs.add('pwd_LockoutObsWin', { enDB: false, nro_campo_tipo: 100, target: 'tdLockoutObswin', placeholder: '0' });
            campos_defs.add('pwd_historyDays', { enDB: false, nro_campo_tipo: 100, target: 'tdHistoryDays', placeholder: '0' });
            
            // Intentar cargar la librería "IMask", ya que necesitamos opciones de ella (IMask.MaskedRange)
            nvFW.chargeJSifNotExist('', '/FW/script/IMask/imask.js');

            var options = {
                enDB:           false,
                nro_campo_tipo: 104,
                placeholder:    '1.0.0',
                target:         'tdVersion',
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
            campos_defs.add('pwd_version', options);
        }


        function setValues()
        {
            if (data)
            {
                campos_defs.set_value('ids_pwdcfg_id', data.ids_pwdcfg_id);
                campos_defs.set_value('ids_pwdcfg', data.ids_pwdcfg);
                campos_defs.set_value('pwd_minlength', data.pwd_minlength);
                campos_defs.set_value('pwd_maxlength', data.pwd_maxlength);
                campos_defs.set_value('pwd_includeUpperCase', data.pwd_includeUpperCase);
                campos_defs.set_value('pwd_includeLowerCase', data.pwd_includeLowerCase);
                campos_defs.set_value('pwd_includeSpecialChars', data.pwd_includeSpecialChars);
                campos_defs.set_value('pwd_maxPasswordAge', data.pwd_maxPasswordAge);
                campos_defs.set_value('pwd_minPasswordAge', data.pwd_minPasswordAge);
                campos_defs.set_value('pwd_LockoutThreshold', data.pwd_LockoutThreshold);
                campos_defs.set_value('pwd_LockoutDuration', data.pwd_LockoutDuration);
                campos_defs.set_value('pwd_LockoutObsWin', data.pwd_LockoutObsWin);
                campos_defs.set_value('pwd_historyDays', data.pwd_historyDays);
                campos_defs.set_value('pwd_version', data.pwd_version);
            }
        }


        function setEdition()
        {
            campos_defs.habilitar('ids_pwdcfg', modo_edicion);
            campos_defs.habilitar('pwd_minlength', modo_edicion);
            campos_defs.habilitar('pwd_maxlength', modo_edicion);
            campos_defs.habilitar('pwd_includeUpperCase', modo_edicion);
            campos_defs.habilitar('pwd_includeLowerCase', modo_edicion);
            campos_defs.habilitar('pwd_includeSpecialChars', modo_edicion);
            campos_defs.habilitar('pwd_maxPasswordAge', modo_edicion);
            campos_defs.habilitar('pwd_minPasswordAge', modo_edicion);
            campos_defs.habilitar('pwd_LockoutThreshold', modo_edicion);
            campos_defs.habilitar('pwd_LockoutDuration', modo_edicion);
            campos_defs.habilitar('pwd_LockoutObsWin', modo_edicion);
            campos_defs.habilitar('pwd_historyDays', modo_edicion);
            campos_defs.habilitar('pwd_version', modo_edicion);
        }


        function editar()
        {
            modo_edicion = true;
            
            setMenu();
            setEdition();

            campos_defs.focus('ids_pwdcfg');
        }


        function clearFields()
        {
            campos_defs.clear('ids_pwdcfg_id');
            campos_defs.clear('ids_pwdcfg');
            campos_defs.clear('pwd_minlength');
            campos_defs.clear('pwd_maxlength');
            campos_defs.clear('pwd_includeUpperCase');
            campos_defs.clear('pwd_includeLowerCase');
            campos_defs.clear('pwd_includeSpecialChars');
            campos_defs.clear('pwd_maxPasswordAge');
            campos_defs.clear('pwd_minPasswordAge');
            campos_defs.clear('pwd_LockoutThreshold');
            campos_defs.clear('pwd_LockoutDuration');
            campos_defs.clear('pwd_LockoutObsWin');
            campos_defs.clear('pwd_historyDays');
            campos_defs.clear('pwd_version');
        }

        function nueva()
        {
            nueva_cfg    = true;
            modo_edicion = true;

            setMenu();
            setEdition();
            clearFields();
            
            campos_defs.set_value('ids_pwdcfg_id', '');
            campos_defs.focus('ids_pwdcfg');
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
                    modo:                    nueva_cfg ? 'A' : 'M',
                    ids_pwdcfg_id:           nueva_cfg ? 0 : parseInt(campos_defs.get_value('ids_pwdcfg_id')),
                    ids_pwdcfg:              campos_defs.get_value('ids_pwdcfg'),
                    pwd_minlength:           campos_defs.get_value('pwd_minlength'),
                    pwd_maxlength:           campos_defs.get_value('pwd_maxlength'),
                    pwd_includeUpperCase:    campos_defs.get_value('pwd_includeUpperCase'),
                    pwd_includeLowerCase:    campos_defs.get_value('pwd_includeLowerCase'),
                    pwd_includeSpecialChars: campos_defs.get_value('pwd_includeSpecialChars'),
                    pwd_maxPasswordAge:      campos_defs.get_value('pwd_maxPasswordAge'),
                    pwd_minPasswordAge:      campos_defs.get_value('pwd_minPasswordAge'),
                    pwd_LockoutThreshold:    campos_defs.get_value('pwd_LockoutThreshold'),
                    pwd_LockoutDuration:     campos_defs.get_value('pwd_LockoutDuration'),
                    pwd_LockoutObsWin:       campos_defs.get_value('pwd_LockoutObsWin'),
                    pwd_historyDays:         campos_defs.get_value('pwd_historyDays'),
                    pwd_version:             campos_defs.get_value('pwd_version')
                },
                onSuccess: function (res)
                {
                    win.options.userData.reload = true;
                    nueva_cfg                   = false;  // Ya se guardó, no es mas nueva config.

                    if (res.params.modo === 'A') campos_defs.set_value('ids_pwdcfg_id', res.params.ids_pwdcfg_id); // Actualizar el ID con el nuevo valor del Insertado
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

            nvFW.error_ajax_request('ids_config_password.aspx', options);
        }


        function validateFields()
        {
            var error_msg = '';
            if (!campos_defs.get_value('ids_pwdcfg')) error_msg += '* Descripción PWD<br>'

            return error_msg;
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <div id="divMenu"></div>

    <table class="tb1 highlightTROver highlightOdd">
        <tr class="tbLabel">
            <td style="width: 320px;">Opción</td>
            <td>Valor</td>
        </tr>
        <tr>
            <td class="Tit1">ID Config PWD</td>
            <td id="tdIdsPwdcfgId"></td>
        </tr>
        <tr>
            <td class="Tit1">Descripción PWD</td>
            <td id="tdIdsPwdcfg"></td>
        </tr>
        <tr>
            <td class="Tit1">Largo mínimo</td>
            <td id="tdMinLength"></td>
        </tr>
        <tr>
            <td class="Tit1">Largo Máximo</td>
            <td id="tdMaxLength"></td>
        </tr>
        <tr>
            <td class="Tit1">Cantidad Mayúsculas</td>
            <td id="tdUpperCase"></td>
        </tr>
        <tr>
            <td class="Tit1">Cantidad Minúsculas</td>
            <td id="tdLowerCase"></td>
        </tr>
        <tr>
            <td class="Tit1">Cantidad Caracteres Especiales</td>
            <td id="tdSpecialChars"></td>
        </tr>
        <tr>
            <td class="Tit1">Tiempo máximo (minutos)</td>
            <td id="tdMaxPassAge"></td>
        </tr>
        <tr>
            <td class="Tit1">Tiempo mínimo (minutos)</td>
            <td id="tdMinPassAge"></td>
        </tr>
        <tr>
            <td class="Tit1">Bloqueo entre intentos fallidos</td>
            <td id="tdLockoutThreshold"></td>
        </tr>
        <tr>
            <td class="Tit1">Duración del bloqueo (minutos)</td>
            <td id="tdLockoutDuration"></td>
        </tr>
        <tr>
            <td class="Tit1">Obs Win de bloqueo (minutos)</td>
            <td id="tdLockoutObswin"></td>
        </tr>
        <tr>
            <td class="Tit1">Histórico de almacenamiento (dias)</td>
            <td id="tdHistoryDays"></td>
        </tr>
        <tr>
            <td class="Tit1">Versión</td>
            <td id="tdVersion"></td>
        </tr>
    </table>
</body>
</html>
