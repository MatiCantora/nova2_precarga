<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Me.contents("login") = nvApp.operador.login
    Me.contents("nro_operador") = nvApp.operador.operador
    Me.addPermisoGrupo("permisos_contactos")

    Dim indice = nvUtiles.obtenerValor("indice", "")
    Dim id_horario = nvUtiles.obtenerValor("id_horario", "")
    Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")

    Me.contents("filtroContactoHorario") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verContacto_Horario'><campos>id_horario,nro_entidad,hora_desde,hora_hasta,nro_operador,nombre_operador,fecha_estado,vigente,predeterminado,nro_docu,Razon_social,tipo_operador,observacion</campos><filtro></filtro><orden>predeterminado desc</orden></select></criterio>")

    Me.contents("indice") = indice
    Me.contents("id_horario") = id_horario
    Me.contents("nro_entidad") = nro_entidad

%>
<html>
<head>
    <title>ABM Contactos - Horario</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />

    <style>
        .footer-pie {
            position: fixed;
            left: 0;
            bottom: 0;
            width: 100%;
        }
    </style>

    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Actualizar";
        vButtonItems[0]["etiqueta"] = "Guardar Cambios";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return btnActualizar_onclick()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("guardar", '/FW/image/icons/guardar.png')

        var login = nvFW.pageContents.login;
        var nro_operador = nvFW.pageContents.nro_operador;
        var Contactos
        var indice = nvFW.pageContents.indice;
        var id_horario = nvFW.pageContents.id_horario;
        var fecha = new Date();
        var nro_entidad = nvFW.pageContents.nro_entidad;
        var win = nvFW.getMyWindow();

        function window_onload() {
            vListButton.MostrarListButton()

            //Contactos = win.options.userData.Contactos
            win.options.userData = {
                modificacion: false,
                recargar: false
            }

            if (indice < 0) {
                $('fecha_estado').value = FechaToSTR(fecha, 1)
                $('operador').value = login
            }
            else {

                var rs = new tRS();

                rs.open(nvFW.pageContents.filtroContactoHorario, "", "<id_horario type='igual'>" + id_horario + "</id_horario>")

                if (!rs.eof()) {

                    var ar_hora_desde = rs.getdata("hora_desde").split(":");
                    $('hora_desde').value = ar_hora_desde[0] + ':' + ar_hora_desde[1]

                    var ar_hora_hasta = rs.getdata("hora_hasta").split(":");
                    $('hora_hasta').value = ar_hora_hasta[0] + ':' + ar_hora_hasta[1]

                    $('fecha_estado').value = FechaToSTR(new Date(rs.getdata("fecha_estado")), 1);
                    $('operador').value = rs.getdata("nombre_operador");

                    $('predeterminado').value = rs.getdata("predeterminado");

                    if (rs.getdata("predeterminado") == "True") {
                        $('vigente').checked = true
                    } else {
                        $('vigente').checked = false
                    }

                    if (rs.getdata("vigente") == "True")
                        $('vigente').checked = true

                    $('observacion').value = rs.getdata("observacion");

                }

            }
            //Cuando se da de alta un nuevo contacto de horario   
            if (indice < 0)
                $('vigente').checked = true

            //Permiso para Editar Vigente
            //if ((permisos_contactos & 8) == 0)
            if (!nvFW.tienePermiso("permisos_contactos", 4))
                $('vigente').disabled = true
        }

        function btnActualizar_onclick() {
            var validacion = ''
            validacion = valHorario()
            if (validacion != '') {
                alert(validacion)
                return
            }

            /***    Controlo que no se carguen horarios repetidos   ***/
            var hora_desde = $('hora_desde').value
            var hora_hasta = $('hora_hasta').value
            var filtro = "";
            var horario_repetido = 0
            var predeterminado_horario = 0

            if (indice < 0) {
                filtro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>";
            }
            else {
                filtro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad><id_horario type='distinto'>" + id_horario + "</id_horario>";
            }

            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroContactoHorario, "", filtro)

            while (!rs.eof()) {

                if (rs.getdata("hora_desde") == hora_desde && rs.getdata("hora_hasta") == hora_hasta)
                    horario_repetido = 1

                //controlo que siempre haya un horario predeterminado
                if (rs.getdata("predeterminado") == "True")
                    predeterminado_horario = 1

                rs.movenext();
            }

            if (horario_repetido == 1) {
                alert('El horario que intenta guardar ya se encuentra cargado.')
                return
            }
            /**********************************************************/

            if (indice < 0) {

                var inicio = '<![CDATA['
                var fin = ']]>'

                var xmldato = ""
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<contactos>"

                xmldato += "<domicilios>"
                xmldato += "</domicilios>"

                xmldato += "<telefonos>"
                xmldato += "</telefonos>"

                xmldato += "<horarios>"

                var vigente;
                if ($('vigente').checked == true)
                    vigente = 'True'
                else
                    vigente = 'False'

                var predeterminado;
                if ((predeterminado_horario == 0) && $('vigente').checked)
                    predeterminado = "True";
                else
                    predeterminado = "False";

                xmldato += "\n<horario id_horario ='0' hora_desde ='" + $('hora_desde').value + "' hora_hasta ='" + $('hora_hasta').value + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' vigente='" + vigente + "' predeterminado='" + predeterminado + "' estado='NUEVO'>"
                xmldato += "<observacion>" + inicio + $('observacion').value + fin + "</observacion>"
                xmldato += "</horario>"

                xmldato += "</horarios>"

                xmldato += "<emails>"
                xmldato += "</emails>"

                xmldato += "</contactos>"
                //return xmldato



                nvFW.error_ajax_request('contacto_ABM.aspx', {
                    parameters: {
                        modo: 'A',
                        contactos_xml: xmldato,
                        nro_entidad: nro_entidad
                    },
                    onSuccess: function (err, transport) {

                        //var ventana_actual = window.top.Windows.getFocusedWindow()

                        win.options.userData = {
                            modificacion: true,
                            recargar: true
                        }

                        win.close()
                    },
                    onFailure: function (err) {

                        if (typeof err == 'object') {
                            alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                        }
                    },
                    error_alert: false,
                    bloq_msg: "Guardando..."
                });


            }
            else {

                var inicio = '<![CDATA['
                var fin = ']]>'

                var xmldato = ""
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<contactos>"

                xmldato += "<domicilios>"
                xmldato += "</domicilios>"

                xmldato += "<telefonos>"
                xmldato += "</telefonos>"

                xmldato += "<horarios>"

                var vigente;
                if ($('vigente').checked == true)
                    vigente = 'True'
                else
                    vigente = 'False'

                var predeterminado = "True";
                if (predeterminado_horario)
                    predeterminado = "False";

                xmldato += "\n<horario id_horario ='" + id_horario + "' hora_desde ='" + $('hora_desde').value + "' hora_hasta ='" + $('hora_hasta').value + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' vigente='" + vigente + "' predeterminado='" + $('predeterminado').value + "' estado='EDITADO'>"
                xmldato += "<observacion>" + inicio + $('observacion').value + fin + "</observacion>"
                xmldato += "</horario>"

                xmldato += "</horarios>"

                xmldato += "<emails>"
                xmldato += "</emails>"

                xmldato += "</contactos>"
                //return xmldato



                nvFW.error_ajax_request('contacto_ABM.aspx', {
                    parameters: {
                        modo: 'A',
                        contactos_xml: xmldato,
                        nro_entidad: nro_entidad
                    },
                    onSuccess: function (err, transport) {

                        win.options.userData = {
                            modificacion: true,
                            recargar: true
                        }

                        win.close()
                    },
                    onFailure: function (err) {

                        if (typeof err == 'object') {
                            alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                        }
                    },
                    error_alert: false,
                    bloq_msg: "Guardando..."
                });


            }

        }

        function valHorario() {
            var mensaje = ''
            if ($('hora_desde').value == '')
                mensaje += 'El campo "Hora Desde" no puede ser vacio.</br>';
            if ($('hora_hasta').value == '')
                mensaje += 'El campo "Hora Hasta" no puede ser vacio.</br>';
            return mensaje
        }

        function valFormatoHora(elem) {
            var valor = elem.value
            var longitud = elem.value.length

            switch (longitud) {
                case 1:
                    if (valor >= 3)
                        elem.value = '0'
                    break
                case 2:
                    if (parseInt(valor, 10) < 24)
                        elem.value = elem.value + ':'
                    else
                        elem.value = '23:'
                    break
                case 4:
                    var hora = valor.split(':')[0]
                    var minutos = valor.split(':')[1]
                    if (minutos >= 6)
                        elem.value = hora + ':0'
                    break
                case 5:
                    var hora = valor.split(':')[0]
                    var minutos = valor.split(':')[1]
                    if (minutos >= 60)
                        elem.value = hora + ':59'
                    break
            }
        }

        function valTiempo(e) {
            val = Event.element(e).value
            var res = '99:99'
            if (val.split(':').length == 2) {
                hora = parseInt(val.split(':')[0], 10) < 24 && parseInt(val.split(':')[0], 10) >= 0 ? parseInt(val.split(':')[0], 10) : 99
                minutos = parseInt(val.split(':')[0], 10) < 99 && parseInt(val.split(':')[1], 10) < 60 && parseInt(val.split(':')[1], 10) >= 0 ? parseInt(val.split(':')[1], 10) : 99

                hora = hora < 10 ? '0' + hora : hora
                minutos = minutos < 10 ? minutos + '0' : minutos
                minutos = minutos == 99 ? '00' : minutos
                res = hora == 99 || minutos == 99 ? '99:99' : hora + ':' + minutos
            }

            if (res == '99:99') {
                alert('El formato de hora no es válido.')
                Event.element(e).value = '00:00'
                Event.element(e).focus()
            }
            else
                Event.element(e).value = res
        }

    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="Contacto_Horario_ABM.asp" method="post" name="form1" target="frmEnviar">
        <input type="hidden" name="indice" id="indice" value="<%=indice %>" />
        <input type="hidden" name="predeterminado" id="predeterminado" value="" />
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width: 100%">
                    <div id="divMenuHorarioABM"></div>
                    <script type="text/javascript">
                        var vMenuHorarioABM = new tMenu('divMenuHorarioABM', 'vMenuHorarioABM');
                        //vMenuHorarioABM.loadImage("punto", "/FW/image/icons/punto.gif")
                        Menus["vMenuHorarioABM"] = vMenuHorarioABM
                        Menus["vMenuHorarioABM"].alineacion = 'centro';
                        Menus["vMenuHorarioABM"].estilo = 'A';
                        //Menus["vMenuHorarioABM"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 14px'><Lib TipoLib='offLine'>DocMNG</Lib><icono>punto</icono><Desc></Desc></MenuItem>")
                        Menus["vMenuHorarioABM"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Horario</Desc></MenuItem>")
                        vMenuHorarioABM.MostrarMenu()
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 50%; text-align: center">Hora Desde*</td>
                <td style="width: 50%; text-align: center">Hora Hasta*</td>
            </tr>
            <tr>
                <td style="width: 50%; text-align: center;">
                    <input style="width: 65%; text-align: right" type="text" id="hora_desde" name="hora_desde" onkeypress="return valDigito(event, ':')" onkeyup="valFormatoHora(this)" onblur="return valTiempo(event)" value="" maxlength="5" /><span style="width: 35%; text-align: center; color: #C0C0C0; font-size: 10px">[00:00-23:59]</span></td>
                <td style="width: 50%; text-align: center;">
                    <input style="width: 65%; text-align: right" type="text" id="hora_hasta" name="hora_hasta" onkeypress="return valDigito(event, ':')" onkeyup="valFormatoHora(this)" onblur="return valTiempo(event)" value="" maxlength="5" /><span style="width: 35%; text-align: center; color: #C0C0C0; font-size: 10px">[00:00-23:59]</span></td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td>Observación</td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <input name="observacion" id="observacion" style="width: 100%" /></td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 60%; text-align: center">Fecha Estado</td>
                <td style="width: 20%; text-align: center">Operador</td>
                <td style="width: 20%; text-align: center">Vigente</td>
            </tr>
            <tr>
                <td style="width: 60%">
                    <input name="fecha_estado" id="fecha_estado" style="width: 100%" disabled="disabled" /></td>
                <td style="width: 20%">
                    <input name="operador" id="operador" style="width: 100%" disabled="disabled" /></td>
                <td style="width: 20%">
                    <div id="div_vigente">
                        <input type="checkbox" name="vigente" id="vigente" style="width: 100%" />
                    </div>
                </td>
            </tr>
        </table>
        <br />
        <table style="width: 100%;">
            <tr>
                <td style="width: 30%;"></td>
                <td style="width: 40%;">
                    <div id="divActualizar"></div>
                </td>
                <td style="width: 30%;"></td>
            </tr>
        </table>
        <div class="footer-pie">
            <table class="tb1" id="pie" cellspacing="0" cellpadding="0">
                <tr>
                    <td style="text-align: left !Important">(*) Campos obligatorios</td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
