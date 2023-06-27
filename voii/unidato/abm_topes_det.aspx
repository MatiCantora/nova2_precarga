<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    Me.contents("login") = nvApp.operador.login

    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

    If strXML <> "" Then
        Dim err As New tError()

        If (Not op.tienePermiso("permisos_alarmas_pld", 7)) Then
            err.numError = 0
            err.titulo = "Edición de detalle no permitida"
            err.mensaje = "No tiene permiso para realizar esta acción."
            err.response()
            Return
        End If

        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("abm_topes_det", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app, cod_cn:="UNIDATO")
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            If Not rs.EOF Then
                err.numError = rs.Fields("numError").Value
                err.mensaje = rs.Fields("mensaje").Value
                err.debug_desc = rs.Fields("debug_desc").Value
                err.debug_src = rs.Fields("debug_src").Value
                err.params("nro_topes_det") = rs.Fields("nro_topes_det").Value
            End If

        Catch ex As Exception
            err.numError = 1000
            err.mensaje = "Error al intentar realizar la operación."
            err.debug_desc = ex.Message
        End Try

        err.response()
    End If

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Topes Detalle</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();
        var nv_login = nvFW.pageContents.login;
        var modo;

        function window_onload() {
            cargar_datos_ventana();
            cargar_menu();
            campos_defs.set_value('id_periodicidad', 4);
        }

        function cargar_datos_ventana() {
            try {
                modo = win.options.userData.modo;

                if (modo == 'M')
                    modo_modificacion(true);
                else if (modo == 'A')
                    modo_nuevo();
            }

            catch (e) {
                console.log(e);
            }
        }

        function cargar_menu() {
            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_como</icono><Desc>Guardar cómo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_como()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Dar de Baja</Desc><Acciones><Ejecutar Tipo='script'><Codigo>dar_baja()</Codigo></Ejecutar></Acciones></MenuItem>")
            pMenu.loadImage("guardar_como", "../image/icons/guardar_como.png");
            pMenu.loadImage("guardar", "../image/icons/guardar.png");
            pMenu.loadImage("eliminar", "../image/icons/eliminar.png");

            pMenu.MostrarMenu();
        }

        function guardar() {
            if (validar_datos() != 0)
                return;
            let strXML = '<?xml version="1.0" encoding="ISO-8859-1"?><transaccion modo="' + modo + '" nro_tope_def="' + campos_defs.get_value('nro_tope_def') + '" id_cliente="' + campos_defs.get_value('id_cliente') + '" nro_topes_det="' + win.options.userData.nro_topes_det + '" cuitcuil="' + campos_defs.get_value('cuitcuil') + '" tipo_persona="' + document.getElementById("tipo_persona").value + '" gran_cliente="' + document.getElementById("gran_cliente").value + '" proporcion_tope="' + $('proporcion_tope').value + '" fecha_alta="' + campos_defs.get_value('fecha_alta') + '" fecha_baja="' + campos_defs.get_value('fecha_baja') + '" nv_login="' + nv_login + '"></transaccion>'

            nvFW.error_ajax_request('abm_topes_det.aspx', {
                parameters: {
                    strXML: strXML
                },
                onSuccess: function (err, transport) {
                    if (modo == 'A') {
                        modo = 'M';
                        modo_modificacion();
                    }
                    nvFW.alert("Guardado correctamente.")
                    win.options.userData.nro_topes_det = err.params['nro_topes_det'];
                    win.options.userData.hay_modificacion = true;
                    win.options.userData.nro_tope_def = campos_defs.get_value('nro_tope_def');
                    win.options.userData.id_cliente = campos_defs.get_value('id_cliente');
                    win.options.userData.cuitcuil = campos_defs.get_value('cuitcuil');
                    win.options.userData.tipo_persona = $(tipo_persona).value;
                    win.options.userData.gran_cliente = $(gran_cliente).value;
                    win.options.userData.proporcion_tope = $(proporcion_tope).value;
                    win.options.userData.fecha_alta = campos_defs.get_value('fecha_alta');
                    win.options.userData.fecha_baja = campos_defs.get_value('fecha_baja');
                    win.options.userData.nv_login = campos_defs.get_value('nv_login');

                },
                onFailure: function (err, transport) {

                }
            });
        }

        function guardar_como() {
            let win_gc = top.nvFW.createWindow({
                className: 'alphacube',
                url: '/voii/unidato/abm_topes_det.aspx',
                title: '<b>Editar Tope Det</b>',
                minimizable: false,
                maximizable: false,
                resizable: true,
                draggable: true,
                width: 700,
                height: 400,
                destroyOnClose: true,
                onClose: function () {
                    win.options.userData.hay_modificacion = true;
                }
            });

            win_gc.options.userData = { modo: 'A', hay_modificacion: false, nro_tope_def: campos_defs.get_value('nro_tope_def'), id_cliente: campos_defs.get_value('id_cliente'), cuitcuil: campos_defs.get_value('cuitcuil'), tipo_persona: document.getElementById('tipo_persona').value, gran_cliente: document.getElementById('gran_cliente').value, proporcion_tope: document.getElementById('proporcion_tope').value, fecha_alta: campos_defs.get_value('fecha_alta'), fecha_baja: campos_defs.get_value('fecha_baja'), nv_login: nv_login }
            win_gc.showCenter(false);
        }

        function dar_baja() {
            let strXML = '<?xml version="1.0" encoding="ISO-8859-1"?><transaccion modo="B" nro_tope_def="' + campos_defs.get_value('nro_tope_def') + '" id_cliente="' + campos_defs.get_value('id_cliente') + '" nro_topes_det="' + win.options.userData.nro_topes_det + '" cuitcuil="' + campos_defs.get_value('cuitcuil') + '" tipo_persona="' + document.getElementById("tipo_persona").value + '" gran_cliente="' + document.getElementById("gran_cliente").value + '" proporcion_tope="' + $('proporcion_tope').value + '" fecha_alta="' + campos_defs.get_value('fecha_alta') + '" fecha_baja="' + campos_defs.get_value('fecha_baja') + '" nv_login="' + nv_login + '"></transaccion>'

            confirm('¿Quiere dar de baja realmente?', {
                width: 300, className: "alphacube",
                onOk: function (win2) {
                    nvFW.error_ajax_request('abm_topes_det.aspx', {
                        parameters:
                        {
                            strXML: strXML
                        },
                        onSuccess: function (err) {
                            win2.close();
                            win.options.userData.hay_modificacion = true;
                            win.close();
                        }
                    });
                },
                onCancel: function (win2) { win2.close() },
                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar'
            });

        }

        function aux_StrToDate(dateStr) {
            let parts = dateStr.split("/");
            return new Date(parts[2], parts[1] - 1, parts[0]);
        }

        function modo_modificacion(onload = false) {
            if (onload) {
                campos_defs.set_value('nro_tope_def', win.options.userData.nro_tope_def);
                campos_defs.set_value('id_cliente', win.options.userData.id_cliente);
                campos_defs.set_value('cuitcuil', win.options.userData.cuitcuil);
                campos_defs.set_value('nv_login', win.options.userData.nv_login);
                campos_defs.habilitar('nv_login', false);
                $(proporcion_tope).value = win.options.userData.proporcion_tope;
                document.getElementById('tipo_persona').value = win.options.userData.tipo_persona;
                document.getElementById('gran_cliente').value = win.options.userData.gran_cliente;

                campos_defs.set_value('fecha_alta', win.options.userData.fecha_alta);
                if (win.options.userData.fecha_baja != undefined)
                    campos_defs.set_value('fecha_baja', win.options.userData.fecha_baja);
            }
            else {
                win.options.userData.nro_tope_def = campos_defs.get_value('nro_tope_def');
                win.options.userData.id_cliente = campos_defs.get_value('id_cliente');
                win.options.userData.cuitcuil = campos_defs.get_value('cuitcuil');
                win.options.userData.nv_login = campos_defs.get_value('nv_login');
                win.options.userData.fecha_alta = campos_defs.get_value('fecha_alta');
                win.options.userData.fecha_baja = campos_defs.get_value('fecha_baja');
                win.options.userData.proporcion_tope = $('proporcion_tope').value;
                win.options.userData.gran_cliente = $('gran_cliente').value;
                win.options.userData.tipo_persona = $('tipo_persona').value;
            }


            if (parseFecha(campos_defs.get_value('fecha_alta'), 'dd/mm/yyyy') < new Date())
                campos_defs.habilitar('fecha_alta', false)

            if (win.options.userData.fecha_baja != undefined && aux_StrToDate(campos_defs.get_value('fecha_baja')) < new Date) {
                campos_defs.habilitar('fecha_baja', false);
                $('proporcion_tope').disabled = true;
                document.getElementById('porcentaje').disabled = true;
                document.getElementById('mensaje_det_terminado').hidden = false;
                document.getElementById('divMenuPrincipal').hidden = true;
            }
        }

        function modo_nuevo() {
            let f1 = new Date;
            campos_defs.set_value('fecha_alta', f1.getDate() + "/" + (f1.getMonth() + 1) + "/" + f1.getFullYear());
            win.options.userData.nro_topes_det = 0;
            campos_defs.habilitar('nv_login', false);

            //viene del guardar como
            if (win.options.userData.nro_tope_def != undefined) {
                campos_defs.set_value('nro_tope_def', win.options.userData.nro_tope_def);
                campos_defs.set_value('id_cliente', win.options.userData.id_cliente);
                campos_defs.set_value('cuitcuil', win.options.userData.cuitcuil);
                $(proporcion_tope).value = win.options.userData.proporcion_tope;
                document.getElementById('tipo_persona').value = win.options.userData.tipo_persona;
                document.getElementById('gran_cliente').value = win.options.userData.gran_cliente;

                if (win.options.userData.fecha_baja != undefined)
                    campos_defs.set_value('fecha_baja', win.options.userData.fecha_baja);
            }
        }

        function validar_datos() {
            //Controles básicos de que no falten completar datos necesarios.
            if (campos_defs.get_value('nro_tope_def') == "") {
                nvFW.alert("Debe elegir una definición de tope para proceder.");
                return;
            }
            else if (campos_defs.get_value('id_cliente') == "") {
                nvFW.alert("Debe elegir un PSP para proceder.");
                return;
            }
            else if (campos_defs.get_value('fecha_baja') != '' &&
                aux_StrToDate(campos_defs.get_value('fecha_alta')) > aux_StrToDate(campos_defs.get_value('fecha_baja'))) {
                nvFW.alert("La fecha de baja no puede ser anterior a la fecha de alta.");
                return;
            }
            else if (campos_defs.get_value('fecha_alta') == campos_defs.get_value('fecha_baja')) {
                nvFW.alert("La fecha de baja no puede ser igual a la fecha de alta.");
                return;
            }
            else if (campos_defs.get_value('fecha_alta').substring(0, 2) != '01') {
                nvFW.alert("La fecha de alta debe ser el primer día de un mes.");
                return;
            }
            else if (campos_defs.get_value('cuitcuil') != '' && campos_defs.get_value('cuitcuil').length != 11) {
                nvFW.alert("El CUIT/CUIL es inválido, no contiene 11 dígitos.");
                return;
            }
            else if ($('proporcion_tope').value == '' || $('proporcion_tope').value == 0) {
                nvFW.alert("Es necesario establecer una proporción tope y no puede ser 0.");
                return;
            }

            if (modo == 'M') {
                if (win.options.userData.id_cliente != campos_defs.get_value('id_cliente') ||
                    win.options.userData.nro_tope_def != campos_defs.get_value('nro_tope_def') ||
                    win.options.userData.cuitcuil != campos_defs.get_value('cuitcuil') ||
                    win.options.userData.tipo_persona != $("tipo_persona").value ||
                    win.options.userData.gran_cliente != $("gran_cliente").value) {

                    nvFW.alert("Está modificando las claves del registro, no puede utilizar la opción Guardar. Utilice Guardar cómo ");
                    return -1;
                }

                if (win.options.userData.proporcion_tope == $('proporcion_tope').value &&
                    win.options.userData.fecha_alta == campos_defs.get_value('fecha_alta') &&
                    win.options.userData.fecha_baja == campos_defs.get_value('fecha_baja')) {

                    nvFW.alert("No hay modificaciones, no se guardará nada. ");
                    return -1;
                }
            }

            return 0;
        }

        function change_tope() {
            let tope = $('proporcion_tope').value;
            $('proporcion_tope').value = Number.parseFloat(tope).toFixed(4);
        }

    </script>

</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>

    <table id="tb_contenido" class="tb1 layout_fixed">
        <tr>
            <td style="width: 25%">Definición de Tope</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_tope_def', { enDB: true });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 25%">PSP</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_cliente', { enDB: true, mostrar_codigo: false });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 25%">CUIT/CUIL</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cuitcuil', { nro_campo_tipo: 100, enDB: false });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 25%">Tipo de Persona</td>
            <td>
                <select name="tipo_persona" id="tipo_persona" style="width: 100%">
                    <option value="PH">Persona Humana </option>
                    <option value="PJ">Persona Jurídica </option>
                </select>
            </td>
        </tr>
        <tr>
            <td style="width: 25%">Gran Cliente</td>
            <td style="text-align: center; width: 5%;">
                <select name="gran_cliente" id="gran_cliente" style="width: 100%">
                    <option value="False">No </option>
                    <option value="True">Si </option>
                </select>
            </td>
        </tr>
        <tr>
            <td style="width: 25%">Proporción Tope</td>
            <td>
                <input type="number" id="proporcion_tope" value="0.0000" step="0.250" onchange="change_tope()" style="width: 100%" />
            </td>
        </tr>
        <tr>
            <td style="width: 25%">Fecha Alta</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_alta', { nro_campo_tipo: 103, enDB: false });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 25%">Fecha Baja</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_baja', { nro_campo_tipo: 103, enDB: false });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 25%">Última modificación</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nv_login', { nro_campo_tipo: 104, enDB: false });
                </script>
            </td>
        </tr>
    </table>
    <div id="mensaje_det_terminado" hidden style="padding: 5px; margin: 5px; text-align: center; background-color: tomato"><b>No se pueden hacer modificaciones porque es un registro cuya fecha de baja ya aconteció.</b></div>
</body>
</html>
