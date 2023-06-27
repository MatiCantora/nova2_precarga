<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%

    Dim nro_registro As Integer = nvFW.nvUtiles.obtenerValor("nro_registro", 0)
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then

        Dim err As New nvFW.tError
        Try
            Dim fecha_hoy As Date = Now()
            Dim dias As Integer = nvFW.nvUtiles.obtenerValor("dias", 0)
            Dim horas As Integer = nvFW.nvUtiles.obtenerValor("horas", 0)
            Dim minutos As Integer = nvFW.nvUtiles.obtenerValor("minutos", 0)
            Dim indefinido As Boolean = nvFW.nvUtiles.obtenerValor("indefinido", False)

            If indefinido Then
                fecha_hoy = DateAndTime.DateAdd(DateInterval.Year, 99, fecha_hoy)
            Else
                fecha_hoy = DateAndTime.DateAdd(DateInterval.Day, dias, fecha_hoy)
                fecha_hoy = DateAndTime.DateAdd(DateInterval.Hour, horas, fecha_hoy)
                fecha_hoy = DateAndTime.DateAdd(DateInterval.Minute, minutos, fecha_hoy)
            End If

            Dim fecha_str As String = fecha_hoy.ToString("dd/MM/yyyy hh:mm:ss")

            Dim strSQL As String = "UPDATE bloqueo_operador SET bloq_mantener = 1, fe_hasta = CONVERT(DATETIME, '" & fecha_str & "', 103) WHERE nro_registro = " & nro_registro & " AND operador = dbo.rm_nro_operador()"

            nvFW.nvDBUtiles.DBExecute(strSQL)

            err.params.Add("fecha_bloqueo", fecha_str)

            err.numError = 0
            err.mensaje = ""
            err.titulo = ""
            err.debug_src = ""
        Catch ex As Exception
            err.numError = -1
            err.mensaje = "Error al intentar guardar cambios."
            err.titulo = "Error"
            err.debug_src = "bloqueo_registro.aspx"
        End Try
        err.response()
    End If

    Me.contents("nro_registro") = nro_registro

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Alta Comentarios</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tCampo_def.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var nro_registro = nvFW.pageContents.nro_registro;
        var win = nvFW.getMyWindow();

        function window_onload() {
            win.options.userData.hay_modificacion = false;
            campos_defs.set_value('unidad','1');
        }


        function wondow_onresize() {
            
        }


        function setearCampos() {
        }


        function validar_campos() {
            var valido = campos_defs.get_value('unidad') == 4;

            if (!valido) {
                valido = campos_defs.get_value('tiempo') != '';
            }

            return valido;
        }

        function btnGuardar() {

            if (!validar_campos()) {
                alert('Debe ingresar al menos un campo.');
                return;
            }

            var minutos = 0;
            var horas = 0;
            var dias = 0;
            var indefinido = false;
            
            switch (campos_defs.get_value('unidad')) {
                case "1":
                    minutos = campos_defs.get_value('tiempo');
                    break;
                case "2":
                    horas = campos_defs.get_value('tiempo');
                    break;
                case "3":
                    dias = campos_defs.get_value('tiempo');
                    break;
                case "4":
                    indefinido = true;
                    break;
            }

            nvFW.error_ajax_request('bloqueo_registro.aspx', {
                parameters: {
                    nro_registro: nro_registro,
                    modo: 'A',
                    indefinido: indefinido,
                    dias: dias,
                    horas: horas,
                    minutos: minutos
                },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {

                        win.options.userData.fecha_bloqueo = !indefinido ? err.params["fecha_bloqueo"] : "Indefinido";
                        win.options.userData.hay_modificacion = true;

                        win.close();
                    }
                },
                bloq_msg: 'Guardando..'
            });
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>
    <script>
        vMenuPrincipal = new tMenu('divMenuPrincipal', 'vMenuPrincipal');
        Menus["vMenuPrincipal"] = vMenuPrincipal;
        Menus["vMenuPrincipal"].alineacion = 'centro';
        Menus["vMenuPrincipal"].estilo = 'A';

        Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnGuardar()</Codigo></Ejecutar></Acciones></MenuItem>");
        Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");

        Menus["vMenuPrincipal"].loadImage('guardar', '/FW/image/icons/guardar.png');
        vMenuPrincipal.MostrarMenu();
    </script>
    <table class="tb1">
        <tr class="tbLabel">
            <td style="text-align:center; width:50%">Unidad</td>
            <td style="text-align:center; width:50%">Tiempo</td>
        </tr>
        <tr>
            <td>
                <script>
                    campos_defs.add('unidad', {
                        enDB: false,
                        nro_campo_tipo: 1,
                        mostrar_codigo: false,
                        onchange: function (e, campo_def) {
                            campos_defs.habilitar('tiempo', campos_defs.get_value(campo_def) != 4)
                        }
                    })
                    var rs = new tRS();
                    rs.xml_format = "rsxml_json";
                    rs.addField("id", "string")
                    rs.addField("campo", "string")
                    rs.addRecord({ id: "1", campo: "Minutos" });
                    rs.addRecord({ id: "2", campo: "Horas" });
                    rs.addRecord({ id: "3", campo: "Dias" });
                    rs.addRecord({ id: "4", campo: "Indefinido" });
                    campos_defs.items['unidad'].rs = rs;
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('tiempo', {
                        enDB: false,
                        nro_campo_tipo: 100
                    })
                </script>
            </td>
        </tr>
        <%--<tr class="tbLabel">
            <td style="text-align: center">Días</td>
            <td style="text-align: center">Horas</td>
            <td style="text-align: center">Minutos</td>
            <td style="text-align: center">Segundos</td>
        </tr>
        <tr>
            <td>
                <script>
                    campos_defs.add('dias', {
                        enDB: false,
                        nro_campo_tipo: 100
                    })
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('horas', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        onchange(e, campo_def) {
                            var valor = campos_defs.get_value(campo_def)
                            if (valor >= 24) {
                                var horas = valor % 24
                                var dias = campos_defs.get_value('dias') != '' ?parseInt(campos_defs.get_value('dias')) : 0
                                dias = Math.floor(valor / 24) + dias
                                campos_defs.set_value('dias', dias)
                                campos_defs.set_value(campo_def, horas)
                            }
                        }
                    })
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('minutos', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        onchange(e, campo_def) {
                            var valor = campos_defs.get_value(campo_def)
                            if (valor >= 60) {
                                var minutos = valor % 60
                                var horas = campos_defs.get_value('horas') != '' ? parseInt(campos_defs.get_value('horas')) : 0
                                horas = Math.floor(valor / 60) + horas
                                campos_defs.set_value('horas', horas)
                                campos_defs.set_value(campo_def, minutos)
                            }
                        }
                    })
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('segundos', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        onchange(e, campo_def) {
                            var valor = campos_defs.get_value(campo_def)
                            if (valor >= 60) {
                                var segundos = valor % 60
                                var minutos = campos_defs.get_value('minutos') != '' ? parseInt(campos_defs.get_value('minutos')) : 0;
                                minutos = Math.floor(valor / 60) + minutos
                                campos_defs.set_value('minutos', minutos)
                                campos_defs.set_value(campo_def, segundos)
                            }
                        }
                    });
                </script>
            </td>
        </tr>
        <tr class="tbLabel">
            <td style="text-align: center">Indefinido</td>
        </tr>
        <tr>
            <td style="text-align: center">
                <input id="checkIndefinido" type="checkbox" onchange="desabilitar_campos()" /></td>
        </tr>--%>
    </table>
</body>
</html>
