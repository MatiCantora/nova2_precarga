<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Me.contents("login") = nvApp.operador.login
    Me.contents("nro_operador") = nvApp.operador.operador
    Me.addPermisoGrupo("permisos_contactos")

    Dim indice = nvUtiles.obtenerValor("indice", "")
    Dim id_email = nvUtiles.obtenerValor("id_contact", "")
    Dim id_tipo = nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_id_tipo = nvUtiles.obtenerValor("nro_id_tipo", 1)

    Me.contents("filtroContactoTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_tipo'><campos>distinct nro_contacto_tipo as id, desc_contacto_tipo as [campo]</campos><orden>[id]</orden><filtro><nro_contacto_tipo type='in'>1,2,12</nro_contacto_tipo></filtro></select></criterio>")

    Me.contents("filtroContactoEmail") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verContacto_Email'><campos>*</campos><filtro></filtro><orden>predeterminado desc</orden></select></criterio>")

    Me.contents("indice") = indice
    Me.contents("id_email") = id_email
    Me.contents("id_tipo") = id_tipo
    Me.contents("nro_id_tipo") = nro_id_tipo

%>

<html>
<head>
    <title>ABM Contactos - Email</title>
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

        var Contactos
        var login = nvFW.pageContents.login;
        var nro_operador = nvFW.pageContents.nro_operador;
        var fecha = new Date();
        var indice = nvFW.pageContents.indice;
        var id_email = nvFW.pageContents.id_email;
        var win = nvFW.getMyWindow()

        var id_tipo = nvFW.pageContents.id_tipo;
        var nro_id_tipo = nvFW.pageContents.nro_id_tipo;

        function window_onload() {
            vListButton.MostrarListButton()

            //Contactos = win.options.userData.Contactos
            if (typeof win == 'undefined') {
                win = parent.win
            }

            win.options.userData = {
                modificacion: false,
                recargar: false
            }

            campos_defs.add('nro_contacto_tipo', {
                despliega: 'abajo',
                enDB: false,
                target: 'td_nro_contacto_tipo',
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtroContactoTipo,
                filtroWhere: "<nro_contacto_tipo type='igual'>%campo_value%</nro_contacto_tipo>",
                depende_de: null,
                depende_de_campo: null
            })

            if (indice < 0) {
                campos_defs.set_value("nro_contacto_tipo", "1")
                $('fecha_estado').value = FechaToSTR(fecha, 1)
                $('operador').value = login
            }
            else {

                var rs = new tRS();

                rs.open(nvFW.pageContents.filtroContactoEmail, "", "<id_email type='igual'>" + id_email + "</id_email>");

                if (!rs.eof()) {
                    $('email').value = rs.getdata("email");
                    $('observacion').value = rs.getdata("observacion");
                    $('fecha_estado').value = FechaToSTR(new Date(rs.getdata("fecha_estado")), 1);
                    $('operador').value = rs.getdata("nombre_operador");
                    campos_defs.set_value("nro_contacto_tipo", rs.getdata("nro_contacto_tipo"));
                    $('checkPredeterminado').checked = rs.getdata("predeterminado") == 'True';

                    //if (Contactos["email"][indice]["vigente"] == "True" || Contactos["email"][indice]["predeterminado"] == "True") {
                    if (rs.getdata("vigente") == "True") {
                        $('vigente').checked = true
                    } else {
                        $('vigente').checked = false
                    }

                    //if (Contactos["email"][indice]["predeterminado"] == "True")
                    //    $('vigente').disabled = true

                    if (rs.getdata("incorrecto") == "True") {
                        $('incorrecto').checked = true
                    } else {
                        $('incorrecto').checked = false
                    }

                    //if ((permisos_contactos & 16) != 0)
                    if (nvFW.tienePermiso("permisos_contactos", 5))
                        $('incorrecto').disabled = false
                    else
                        $('incorrecto').disabled = true

                }
            }


            //Cuando se da de alta un nuevo contacto de email   
            if (indice < 0)
                $('vigente').checked = true

            //Permiso para Editar Vigente
            //if ((permisos_contactos & 8) == 0)
            if (!nvFW.tienePermiso("permisos_contactos", 4))
                $('vigente').disabled = true

            // Permiso para Editar Incorrecto
            //if ((permisos_contactos & 16) == 0)
            if (!nvFW.tienePermiso("permisos_contactos", 5))
                $('incorrecto').disabled = true

        }

        /***   Valida el formato de Email  ***/
        function valFormatoEmail(email) {
            if (email != '') {
                var okemail = /^\w+([\.-]?\w+)*(\-)*@\w+([\.-]?\w+)*(\.\w{2,4})+$/.test(email);
                if (!okemail)
                    return false
                else
                    return true
            }
        }

        /***    Valida Email repetidos     ***/
        function valEmailRepetido(email) {
            var repetido = false

            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroContactoEmail, "", "<id_tipo type='igual'>" + id_tipo + "</id_tipo><id_email type='distinto'>" + id_email + "</id_email><nro_id_tipo type='igual'>" + nro_id_tipo + "</nro_id_tipo>");

            while (!rs.eof()) {

                //Para ver si hay repetidos, comparo: email
                //si el contacto de email esta vigente
                //si el contacto de email no esta borrado
                if (rs.getdata("email") == email && rs.getdata("vigente") == "True") //&& Contactos["email"][i]["estado"] != "BORRADO")
                    repetido = true

                rs.movenext();
            }
            return repetido
        }

        function valEmail() {
            var email = $('email').value
            var nro_contacto_tipo = campos_defs.get_value('nro_contacto_tipo')
            var contacto_tipo_desc = campos_defs.get_desc('nro_contacto_tipo')

            if (valEmailRepetido(email)) {
                alert('El email que intenta ingresar ya existe como Contacto de Email.')
                $('email').focus()
                return false
            } else {

                if (nro_contacto_tipo == '') {
                    $('email').value = ''
                    $('email').focus()
                    alert('Debe seleccionar un Tipo de Contacto')
                    return false
                }
                else {
                    if (!valFormatoEmail(email)) {
                        alert('La dirección de email posee un formato inválido.<br>')
                        $('email').focus()
                        return false
                    }
                    return true
                }
            }
        }

        function btnActualizar_onclick() {
            var validacion = ''
            var referencias_repetidas = 0
            //Cuando se guarda como NO VIGENTE, no se validan los datos
            if ($('vigente').checked == true) {
                validacion = Validar_campos_obligatorios()
                if ((validacion != '') && (validacion != undefined)) {
                    alert(validacion)
                    return
                }

                if (valEmail()) {
                    if ($('checkPredeterminado').checked)
                        Dialog.confirm('A partir de ahora este sera su email predeterminado.', {
                            className: "alphacube",
                            width: 280,
                            onOk: function (win) {
                                actualizar_email();
                                win.close();
                            },
                            onCancel: function (win) { win.close(); },
                            okLabel: 'Confirmar',
                            cancelLabel: 'Cancelar'
                        });
                    else
                        actualizar_email();
                }
            } else {
                actualizar_email();
            }
        }

        function actualizar_email() {

            var indice = $('indice').value

            var predeterminado = $('checkPredeterminado').checked ? 'True' : 'False'

            if ($('checkPredeterminado').checked && !$('vigente').checked) {
                alert('Un email "no vigente" no puede ser predeterminado.')
                return
            }

            var email_repetido = 0
            var predeterminado_email = 0

            if (indice < 0) {
                filtro = "<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_id_tipo type='igual'>" + nro_id_tipo + "</nro_id_tipo>";
            }
            else {
                filtro = "<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_id_tipo type='igual'>" + nro_id_tipo + "</nro_id_tipo><id_email type='distinto'>" + id_email + "</id_email>";
            }

            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroContactoEmail, "", filtro)

            while (!rs.eof()) {

                if (rs.getdata("email") == $('email').value)
                    email_repetido = 1

                //controlo que siempre haya un email predeterminado
                if (rs.getdata("predeterminado") == "True")
                    predeterminado_email = 1

                rs.movenext();
            }

            if (email_repetido == 1) {
                alert('El email que intenta guardar ya se encuentra cargado.')
                return
            }

            //var predeterminado;
            if ((predeterminado_email == 0) && $('vigente').checked && !$('checkPredeterminado').checked) {
                alert('Debe haber un email predeterminado.')
                return
            }

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
                xmldato += "</horarios>"

                xmldato += "<emails>"

                var vigente;
                if ($('vigente').checked == true)
                    vigente = 'True'
                else
                    vigente = 'False'

                var incorrecto;
                if ($("incorrecto").value == true)
                    incorrecto = 'True'
                else
                    incorrecto = 'False'

                xmldato += "\n<email id_email ='0' email ='" + $('email').value + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' observacion ='" + $("observacion").value + "' nro_contacto_tipo ='" + campos_defs.get_value("nro_contacto_tipo") + "' orden='1' predeterminado='" + predeterminado + "' vigente='" + vigente + "' incorrecto ='" + incorrecto + "'/>"

                xmldato += "</emails>"

                xmldato += "</contactos>"
                //return xmldato

                nvFW.error_ajax_request('contacto_ABM.aspx', {
                    parameters: {
                        modo: 'A',
                        contactos_xml: xmldato,
                        id_tipo: id_tipo,
                        nro_id_tipo: nro_id_tipo
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
                xmldato += "</horarios>"

                xmldato += "<emails>"

                var vigente;
                if ($('vigente').checked == true)
                    vigente = 'True'
                else
                    vigente = 'False'

                var incorrecto;
                if ($("incorrecto").value == true)
                    incorrecto = 'True'
                else
                    incorrecto = 'False'

                xmldato += "\n<email id_email ='" + id_email + "' email ='" + $('email').value + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' observacion ='" + $("observacion").value + "' nro_contacto_tipo ='" + campos_defs.get_value("nro_contacto_tipo") + "' orden='1' predeterminado='" + predeterminado + "' vigente='" + vigente + "' incorrecto ='" + incorrecto + "' estado='EDITADO' />"

                xmldato += "</emails>"

                xmldato += "</contactos>"
                //return xmldato



                nvFW.error_ajax_request('contacto_ABM.aspx', {
                    parameters: {
                        modo: 'A',
                        contactos_xml: xmldato,
                        id_tipo: id_tipo,
                        nro_id_tipo: nro_id_tipo
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


        }

        function Validar_campos_obligatorios() {
            var mensaje = ''
            if ($('email').value == '')
                mensaje = mensaje + 'El campo "Email" no puede ser vacio.</br>'
            if ($('nro_contacto_tipo').value == '')
                mensaje = mensaje + 'El campo "Tipo Contacto" no puede ser vacio.</br>'

            if (mensaje != '')
                return mensaje

        }


        function vigenteOnchange() {
            if (!$('vigente').checked) {
                $('checkPredeterminado').checked = false
                $('checkPredeterminado').disabled = true
            } else { $('checkPredeterminado').disabled = false }
        }

    </script>
</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="Contacto_Email_ABM.asp" method="post" name="form1" id="form1" target="frmEnviar">
        <input type="hidden" name="indice" id="indice" value="<%=indice %>" />
        <input type="hidden" name="predeterminado" id="predeterminado" value="" />
        <table id="tbMenuEmailABM" style="width: 100%;" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width: 100%">
                    <div id="divMenuEmailABM" style="margin: 0px; padding: 0px;"></div>
                    <script type="text/javascript">
                        var vMenuEmailABM = new tMenu('divMenuEmailABM', 'vMenuEmailABM');
                        Menus["vMenuEmailABM"] = vMenuEmailABM
                        Menus["vMenuEmailABM"].alineacion = 'centro';
                        Menus["vMenuEmailABM"].estilo = 'A';
                        //Menus["vMenuEmailABM"].imagenes = Imagenes //Imagenes se declara en pvUtiles
                        //Menus["vMenuEmailABM"].CargarMenuItemXML("<MenuItem id='0' style='width: 2%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>punto</icono><Desc></Desc></MenuItem>")
                        Menus["vMenuEmailABM"].CargarMenuItemXML("<MenuItem id='0' style='width: 98%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Email</Desc></MenuItem>")
                        vMenuEmailABM.MostrarMenu()
                    </script>
                </td>
            </tr>
        </table>

        <table style="width: 100%" class="tb1">
            <tr class="tbLabel">
                <td style="width: 40%; text-align: center">Tipo Contacto*</td>
                <td style="width: 60%; text-align: center">Email*</td>
            </tr>
            <tr>
                <td style="width: 40%" id="td_nro_contacto_tipo"></td>
                <td style="width: 60%">
                    <input size="15" type="text" name="email" id="email" style="width: 100%" value="" onchange="return valEmail()" /></td>
            </tr>
        </table>


        <table style="width: 100%;" class="tb1">
            <tr class="tbLabel">
                <td>Observación</td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <input name="observacion" id="observacion" style="width: 100%" /></td>
            </tr>
        </table>

        <table style="width: 100%" class="tb1">
            <tr class="tbLabel">
                <td style="width: 30%; text-align: center">Fecha Estado</td>
                <td style="width: 25%; text-align: center">Operador</td>
                <td style="text-align: center">Vigente</td>
                <td style="text-align: center">Incorrecto</td>
                <td style="text-align: center">Predeterminado</td>
            </tr>
            <tr>
                <td>
                    <input name="fecha_estado" id="fecha_estado" style="width: 100%; text-align: right" disabled="disabled" /></td>
                <td>
                    <input name="operador" id="operador" style="width: 100%" disabled="disabled" /></td>
                <td style="text-align: center">
                    <div id='div_vigente'>
                        <input style="border: 0;" type="checkbox" name="vigente" id="vigente" onchange="vigenteOnchange()" style="width: 100%" />
                    </div>
                </td>
                <td style="text-align: center">
                    <div id='div_incorrecto'>
                        <input style="border: 0;" type="checkbox" name="incorrecto" id="incorrecto" style="width: 100%" />
                    </div>
                </td>
                <td style="text-align: center">
                    <div id='div_predeterminado'>
                        <input style="border: 0;" type="checkbox" name="checkPredeterminado" id="checkPredeterminado" style="width: 100%" />
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
