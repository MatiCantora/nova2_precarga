<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Me.contents("login") = nvApp.operador.login
    Me.contents("nro_operador") = nvApp.operador.operador
    Me.addPermisoGrupo("permisos_contactos")

    Dim indice = nvUtiles.obtenerValor("indice", "")
    Dim id_telefono As String = nvUtiles.obtenerValor("id_contact", "")
    Dim id_tipo As String = nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_id_tipo As Integer = nvUtiles.obtenerValor("nro_id_tipo", 1)

    Me.contents("filtroContactoTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_tipo'><campos>distinct nro_contacto_tipo as id, desc_contacto_tipo as [campo]</campos><orden>[id]</orden><filtro><nro_contacto_tipo type='in'>1,2,3,8,9,10,11</nro_contacto_tipo></filtro></select></criterio>")

    If id_telefono <> "" Then
        Me.contents("filtroContactoTelefono") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verContacto_Telefono'><campos>*</campos><filtro></filtro><orden>predeterminado desc</orden></select></criterio>")
    End If

    Me.contents("indice") = indice
    Me.contents("id_telefono") = id_telefono
    Me.contents("id_tipo") = id_tipo
    Me.contents("nro_id_tipo") = nro_id_tipo

%>
<html>
<head>
    <title>ABM Contactos - Teléfono</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
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
        var Contactos = new Array();
        var fecha = new Date();
        var indice = nvFW.pageContents.indice
        var id_telefono = nvFW.pageContents.id_telefono
        var win = nvFW.getMyWindow()

        var id_tipo = nvFW.pageContents.id_tipo;
        var nro_id_tipo = nvFW.pageContents.nro_id_tipo;

        function window_onload() {

            vListButton.MostrarListButton()

            if (typeof win == 'undefined') {
                win = parent.win
            }

            win.options.userData = {
                modificacion: false,
                recargar: false
            }

            //Contactos = win.options.userData.Contactos
            //Contactos = window.top.telefono.returnValue

            //Contactos = window.dialogArguments
            //indice = form1.indice.value

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

                rs.open(nvFW.pageContents.filtroContactoTelefono, "", "<id_telefono type='igual'>" + id_telefono + "</id_telefono>")

                if (rs.recordcount >= 1) {

                    $('telefono').value = rs.getdata("telefono")
                    $('car_tel').value = rs.getdata("car_tel")
                    $('postal').value = rs.getdata("postal")
                    $('desc_localidad').value = rs.getdata("localidad")
                    $('observacion').value = rs.getdata("observacion")
                    $('observacion_referencia').value = rs.getdata("observacion_referencia")
                    $('fecha_estado').value = FechaToSTR(new Date(rs.getdata("fecha_estado")), 1)
                    $('operador').value = rs.getdata("nombre_operador")
                    campos_defs.set_value("nro_contacto_tipo", rs.getdata("nro_contacto_tipo"))
                    $('checkPredeterminado').checked = rs.getdata("predeterminado") == 'True'

                    if (rs.getdata("vigente") == "True") {
                        $('vigente').checked = true
                    } else {
                        $('vigente').checked = false
                    }

                    if (rs.getdata("predeterminado") == "True" || rs.getdata("nro_contacto_tipo") == 9 || rs.getdata("nro_contacto_tipo") == 10)
                        $('vigente').disabled = true

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

            campos_defs.items['nro_contacto_tipo']['onchange'] = actualizar_observacion
            actualizar_observacion()

            //Cuando se da de alta un nuevo contacto de telefono   
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


        function valTelefonoFijo(telefono) {
            var RegExPattern = /^[2-7]{1}[0-9]{5,7}$/;
            if ((telefono.match(RegExPattern)) && (telefono != ''))
                return true
            else
                return false
        }

        function valTelefonoCelular(telefono) {
            //var RegExPattern = /^15{1}[0-9]{6,8}$/;
            var RegExPattern = /^1{1}[5-6]{1}[0-9]{6,8}$/;
            if ((telefono.match(RegExPattern)) && (telefono != ''))
                return true
            else
                return false
        }

        /***    Valida teléfonos repetidos     ***/
        function valTelefonoRepetido(car_tel, telefono) {
            var repetido = false
            var car_tel_contactos


            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroContactoTelefono, "", "<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_id_tipo type='igual'>" + nro_id_tipo + "</nro_id_tipo>")

            while (!rs.eof()) {

                //Sacamos el 0 al inicio de las caracteristicas del arreglo "Contactos['telefono']"
                car_tel_contactos = rs.getdata("car_tel")
                if (car_tel_contactos.charAt(0) == '0')
                    car_tel_contactos = car_tel_contactos.substring(1, car_tel_contactos.length);

                //Sacamos el 0 al inicio de la característica que queremos comparar (car_tel)
                if (car_tel.charAt(0) == '0')
                    car_tel = car_tel.substring(1, car_tel.length);

                //Para ver si hay repetidos, comparo: car_tel, telefono
                //si el contacto de teléfono esta vigente
                //si el contacto de teléfono no esta borrado
                if (car_tel_contactos == car_tel && rs.getdata("telefono") == telefono && rs.getdata("vigente") == "True" && id_telefono != rs.getdata("id_telefono"))
                    repetido = true

                rs.movenext()

            }


            return repetido
        }

        function valTelefono() {
            var telefono = $('telefono').value
            var nro_contacto_tipo = campos_defs.get_value('nro_contacto_tipo')
            var contacto_tipo_desc = campos_defs.get_desc('nro_contacto_tipo')
            var car_tel = $('car_tel').value

            if (valTelefonoRepetido(car_tel, telefono)) {
                alert('El número de teléfono que intenta ingresar ya existe como Contacto Telefónico.')
                $('telefono').focus()
                return false
            } else {

                if (nro_contacto_tipo == '') {
                    $('telefono').value = ''
                    $('telefono').focus()
                    alert('Debe seleccionar un Tipo de Contacto')
                    return false
                }
                else {
                    if (nro_contacto_tipo == 1) { //Personal (fijo)
                        if (!valTelefonoFijo(telefono)) {
                            alert('El Tipo de Contacto "<u>' + contacto_tipo_desc + '</u>" debe comenzar con uno de los siguientes dígitos: "2,3,4,5,6 ó 7" y puede tener 8 dígitos como máximo.')
                            $('telefono').focus()
                            return false
                        }
                    }

                    if (nro_contacto_tipo == 8) { //Celular
                        if (!valTelefonoCelular(telefono)) {
                            alert('El Tipo de Contacto "<u>' + contacto_tipo_desc + '</u>" debe comenzar con 15 ó 16 y puede tener 10 dígitos como máximo.')
                            $('telefono').focus()
                            return false
                        }
                    }

                    if ((nro_contacto_tipo == 2) || (nro_contacto_tipo == 3) || (nro_contacto_tipo == 9) || (nro_contacto_tipo == 10) || (nro_contacto_tipo == 11)) { //Laboral ó Otro ó Referencia 1 ó Referencia 2 ó Referencia Anterior
                        if (!valTelefonoFijo(telefono) && !valTelefonoCelular(telefono)) {
                            alert('El Tipo de Contacto "<u>' + contacto_tipo_desc + '</u>" debe cumplir con el formato de "Teléfono Fijo" ó "Teléfono Celular": </br>- <u>Teléfono Fijo</u>: debe comenzar con uno de los siguientes dígitos: "2,3,4,5,6 ó 7" y puede tener 8 dígitos como máximo. </br>- <u>Teléfono Celular</u>: debe comenzar con 15 ó 16 y puede tener 10 dígitos como máximo.')
                            $('telefono').focus()
                            return false
                        }
                    }
                    return true
                }
            }
        }

        function actualizar_observacion() {
            var nro_contacto_tipo = campos_defs.get_value('nro_contacto_tipo')
            $('tb_observacion').innerHTML = ""
            if (nro_contacto_tipo == 9 || nro_contacto_tipo == 10) {
                $('vigente').checked = true
                $('vigente').disabled = true
            }
            else {
                $('vigente').disabled = false
                if (indice >= 0) {
                    if ($("vigente").checked == true)//ver
                        //if ($("vigente").checked == 'True')//ver
                        $('vigente').checked = true
                    else
                        $('vigente').checked = false
                }
            }
            if (nro_contacto_tipo == 9 || nro_contacto_tipo == 10 || nro_contacto_tipo == 11) {
                $('tb_observacion_referencia').show()
                $('tb_observacion').insert('Apellido y Nombres')
            } else {
                $('tb_observacion_referencia').hide()
                $('tb_observacion').insert('Observación')
            }
            if ((indice >= 0) && ($("predeterminado") == "True"))
                $('vigente').disabled = true

            var telefono = $('telefono').value
            if (telefono != '')
                valTelefono()

        }

        var win_localidad
        function selLocalidad() {

            var parentTop = 0;
            var parentLeft = 0;
            //Corregir
            if (typeof parent.parent.nvFW.getMyWindow() != 'undefined') {
                //var win_parent = parent.parent.nvFW.getMyWindow();
                ////while (typeof win_parent != 'undefined') {
                //win_parent = parent.parent.nvFW.getMyWindow().element
                parentTop = undefined;
                parentLeft = undefined;
                //win_parent = win_parent.parent.nvFW.getMyWindow();
                //}
            } else {
                if (typeof parent.parent.frameElement != 'undefined') {
                    var win_parent = parent.parent.frameElement;
                    parentTop = win_parent.offsetTop + 64;
                    parentLeft = win_parent.positionedOffset().left;
                }
            }

            var alto
            var left

            if (typeof parentTop != 'undefined') {
                alto = (parent.win.element.offsetTop + parentTop + parent.$$('body')[0].getHeight() / 2) - 125;
                left = (parent.win.element.offsetLeft + parentLeft + parent.$$('body')[0].getWidth() / 2) - 225;
            }

            win_localidad = top.nvFW.createWindow({
                className: 'alphacube',
                url: '/FW/funciones/localidad_consultar.aspx',
                title: '<b>Seleccionar Localidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: false,
                width: 450,
                height: 250,
                onClose: selLocalidad_return
            });

            win_localidad.options.userData = { res: '' }
            win_localidad.showCenter(false, alto, left)
        }

        function selLocalidad_return() {
            if (win_localidad.options.userData.res) {
                var objRetorno = win_localidad.options.userData.res

                $('postal').value = objRetorno['postal']
                $('desc_localidad').value = objRetorno['desc'].substr(0, 28)
                $('car_tel').value = objRetorno['car_tel']
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

                if (valTelefono()) {
                    var indice = $('indice').value
                    var nro_contacto_tipo = $('nro_contacto_tipo').value
                    var contacto_tipo_desc = $('nro_contacto_tipo_desc').value
                    var predeterminado = $('checkPredeterminado').checked ? 'True' : 'False'

                    if (predeterminado == "True") {
                        //Si el contacto de teléfono es predeterminado, el tipo de contacto puede ser: "Personal(1)", "Laboral(2)", "Otro(3)" ó "Celular(8)"
                        if (nro_contacto_tipo != 1 && nro_contacto_tipo != 2 && nro_contacto_tipo != 3 && nro_contacto_tipo != 8) {
                            alert('Un contacto telefónico Predeterminado debe ser de tipo "Personal", "Celular", "Laboral" u "Otros"')
                            return false
                        }
                    }

                    //Sólo puede existir un teléfono con el tipo "Referencia 1" y un teléfono con el tipo "Referencia 2"
                    if ((nro_contacto_tipo == 9) || (nro_contacto_tipo == 10)) {
                        var rs = new tRS();

                        rs.open(nvFW.pageContents.filtroContactoTelefono, "", "<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_id_tipo type='igual'>" + nro_id_tipo + "</nro_id_tipo>")

                        while (!rs.eof()) {
                            //for (var j = 0; j < Contactos["telefono"].length; j++) {
                            if ((rs.getdata("nro_contacto_tipo") == nro_contacto_tipo) && (id_telefono != rs.getdata("id_telefono")))
                                referencias_repetidas++

                            rs.movenext();
                        }

                        if (referencias_repetidas > 0) {
                            Dialog.confirm("Se dará de alta un tipo de contacto '" + contacto_tipo_desc + "'.\n Se pasarán a 'Referencia Anterior', los tipos de contacto '" + contacto_tipo_desc + "' antes cargados.\n Confirma los cambios?", {
                                width: 400,
                                className: "alphacube",
                                okLabel: "Aceptar",
                                cancelLabel: "Cancelar",
                                cancel: function (win_ref) {
                                    alert('Sólo puede existir un teléfono de contacto de tipo ' + contacto_tipo_desc)
                                    win_ref.close();
                                    return
                                },
                                ok: function (win_ref) {
                                    //for (var j = 0; j < Contactos["telefono"].length; j++) {
                                    //    if ((Contactos["telefono"][j]["nro_contacto_tipo"] == nro_contacto_tipo) && (indice != j)) {
                                    //        Contactos["telefono"][j]["nro_contacto_tipo"] = 11
                                    //        Contactos["telefono"][j]["desc_contacto_tipo"] = 'Referencia Anterior'
                                    //    }
                                    //}
                                    win_ref.close()
                                    actualizar_telefono()
                                }
                            });
                        }
                        else {
                            actualizar_telefono()
                        }
                    }
                    else {
                        actualizar_telefono()
                    }
                }
            } else {
                actualizar_telefono()
            }
        }

        function actualizar_telefono() {
            var indice = $('indice').value

            if (!$('vigente').checked && $('checkPredeterminado').checked) {
                alert('Un teléfono "no vigente" no puede ser predeterminado.')
                return
            }

            if (indice < 0) {

                var id_ro_telefono = 0

                var inicio = '<![CDATA['
                var fin = ']]>'
                var postal = ''
                var xmldato = ""
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<contactos>"

                xmldato += "<domicilios>"
                xmldato += "</domicilios>"

                xmldato += "<telefonos>"

                var vigente
                var incorrecto

                if ($('vigente').checked == true || $('nro_contacto_tipo').value == 9 || $('nro_contacto_tipo').value == 10)
                    vigente = 'True';
                else
                    vigente = 'False';

                if ($('incorrecto').checked == true)
                    incorrecto = 'True';
                else
                    incorrecto = 'False';

                postal = $('postal').value;
                var predeterminado = $('checkPredeterminado').checked ? 'True' : 'False';
                xmldato += "\n<telefono id_telefono='0' car_tel='" + $('car_tel').value + "' telefono ='" + $("telefono").value + "' postal ='" + postal + "' observacion ='" + $("observacion").value + "' observacion_referencia ='" + $("observacion_referencia").value + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' nro_contacto_tipo ='" + campos_defs.get_value("nro_contacto_tipo") + "' predeterminado='" + predeterminado + "' orden='1' vigente='" + vigente + "' incorrecto ='" + incorrecto + "' estado='NUEVO' id_ro_telefono = '" + id_ro_telefono + "'/>"
                //});

                xmldato += "</telefonos>"

                xmldato += "<horarios>"
                xmldato += "</horarios>"

                xmldato += "<emails>"
                xmldato += "</emails>"

                xmldato += "</contactos>"

                if ($('checkPredeterminado').checked)
                    Dialog.confirm('A partir de ahora este sera su telefono predeterminado.', {
                        width: 280,
                        onOk: function (win) {
                            ajax_telefono('A', xmldato, id_tipo, nro_id_tipo);
                            win.close();
                        },
                        onCancel: function (win) { win.close(); },
                        okLabel: 'Confirmar',
                        cancelLabel: 'Cancelar'
                    });
                else
                    ajax_telefono('A', xmldato, id_tipo, nro_id_tipo)

            }
            else {

                var id_ro_telefono = 0

                var inicio = '<![CDATA['
                var fin = ']]>'
                var postal = ''
                var xmldato = ""
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<contactos>"

                xmldato += "<domicilios>"
                xmldato += "</domicilios>"

                xmldato += "<telefonos>"

                var vigente
                var incorrecto

                if ($('vigente').checked == true || $('nro_contacto_tipo').value == 9 || $('nro_contacto_tipo').value == 10)
                    vigente = 'True';
                else
                    vigente = 'False';

                if ($('incorrecto').checked == true)
                    incorrecto = 'True';
                else
                    incorrecto = 'False';

                postal = $('postal').value;
                //acaes

                var predeterminado = $('checkPredeterminado').checked ? 'True' : 'False';
                xmldato += "\n<telefono id_telefono ='" + id_telefono + "' car_tel='" + $('car_tel').value + "' telefono ='" + $("telefono").value + "' postal ='" + postal + "' observacion ='" + $("observacion").value + "' observacion_referencia ='" + $("observacion_referencia").value + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' nro_contacto_tipo ='" + campos_defs.get_value("nro_contacto_tipo") + "' predeterminado='" + predeterminado + "' orden='1' vigente='" + vigente + "' incorrecto ='" + incorrecto + "' estado='EDITADO' id_ro_telefono = '" + id_ro_telefono + "'/>"
                //});
                xmldato += "</telefonos>"

                xmldato += "<horarios>"
                xmldato += "</horarios>"

                xmldato += "<emails>"
                xmldato += "</emails>"

                xmldato += "</contactos>"

                if ($('checkPredeterminado').checked)
                    Dialog.confirm('A partir de ahora este sera su telefono predeterminado.', {
                        className: "alphacube",
                        width: 280,
                        onOk: function (win) {
                            ajax_telefono('M', xmldato, id_tipo, nro_id_tipo);
                            win.close();
                        },
                        onCancel: function (win) { win.close(); },
                        okLabel: 'Confirmar',
                        cancelLabel: 'Cancelar'
                    });
                else
                    ajax_telefono('M', xmldato, id_tipo, nro_id_tipo);
                

            }

            //var win = nvFW.getMyWindow()
            //win.options.userData = { Contactos: Contactos }
            //win.close();
        }

        function ajax_telefono(modo, xmldato, id_tipo, nro_id_tipo) {
            nvFW.error_ajax_request('contacto_ABM.aspx', {
                parameters: {
                    modo: modo,
                    contactos_xml: xmldato,
                    id_tipo: id_tipo,
                    nro_id_tipo: nro_id_tipo
                },
                onSuccess: function (err, transport) {

                    win.options.userData = {
                        modificacion: true,
                        recargar: true
                    }

                    win.close();
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

        function Validar_campos_obligatorios() {
            var mensaje = ''
            if ($('telefono').value == '')
                mensaje = mensaje + 'El campo "Teléfono" no puede ser vacio.\n'
            if ($('car_tel').value == '')
                mensaje = mensaje + 'El campo "Car. Tel." no puede ser vacio.\n'
            if ($('nro_contacto_tipo').value == '')
                mensaje = mensaje + 'El campo "Tipo Contacto" no puede ser vacio.\n'

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
    <form action="Contacto_Telefono_ABM.asp" method="post" name="form1" id="form1" target="frmEnviar">
        <input type="hidden" name="indice" id="indice" value="<%=indice %>" />
        <input type="hidden" name="postal" id="postal" value="" />
        <input type="hidden" name="predeterminado" id="predeterminado" value="" />
        <table id="tbMenuTelefonoABM" style="width: 100%;" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width: 100%">
                    <div id="divMenuTelefonoABM" style="margin: 0px; padding: 0px;"></div>
                    <script type="text/javascript">
                        var vMenuTelefonoABM = new tMenu('divMenuTelefonoABM', 'vMenuTelefonoABM');
                        Menus["vMenuTelefonoABM"] = vMenuTelefonoABM
                        Menus["vMenuTelefonoABM"].alineacion = 'centro';
                        Menus["vMenuTelefonoABM"].estilo = 'A';
                        //Menus["vMenuTelefonoABM"].imagenes = Imagenes //Imagenes se declara en pvUtiles
                        //Menus["vMenuTelefonoABM"].CargarMenuItemXML("<MenuItem id='0' style='width: 2%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>punto</icono><Desc></Desc></MenuItem>")
                        Menus["vMenuTelefonoABM"].CargarMenuItemXML("<MenuItem id='0' style='width: 98%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Teléfono</Desc></MenuItem>")
                        vMenuTelefonoABM.MostrarMenu()
                    </script>
                </td>
            </tr>
        </table>

        <table style="width: 100%" class="tb1">
            <tr class="tbLabel">
                <td style="width: 30%; text-align: center">Tipo Contacto*</td>
                <td style="width: 20%; text-align: center">Car. Tel.*</td>
                <td style="width: 50%; text-align: center">Teléfono*</td>
            </tr>
            <tr>
                <td style="width: 30%" id="td_nro_contacto_tipo"></td>
                <td style="width: 20%;">
                    <input type="text" name="car_tel" id="car_tel" value="" size="4" style="width: 100%; text-align: right" ondblclick="selLocalidad()" /></td>
                <td style="width: 50%">
                    <input size="15" type="text" name="telefono" id="telefono" style="width: 100%; text-align: right" value="" onkeypress="return valDigito(event)" onchange="return valTelefono()" /></td>
            </tr>
        </table>

        <table style="width: 100%" class="tb1">
            <tr class="tbLabel">
                <td style="width: 100%; text-align: center">Localidad</td>
            </tr>
            <tr>
                <td style="width: 100%" nowrap>
                    <input name="desc_localidad" id="desc_localidad" style="width: 93%" ondblclick="selLocalidad()" readonly /><input type="button" name="btnSelLocalidad" id="btnSelLocalidad" value="." size="1" onclick="selLocalidad()" /></td>
            </tr>
        </table>

        <table style="width: 100%" class="tb1">
            <tr class="tbLabel">
                <td id="tb_observacion"></td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <input name="observacion" id="observacion" style="width: 100%" /></td>
            </tr>
        </table>

        <table style="width: 100%; display: none" class="tb1" id="tb_observacion_referencia">
            <tr class="tbLabel">
                <td>Observación</td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <input name="observacion_referencia" id="observacion_referencia" style="width: 100%" /></td>
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
