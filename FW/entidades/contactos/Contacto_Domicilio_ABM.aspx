<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%


    Me.contents("login") = nvApp.operador.login
    Me.contents("nro_operador") = nvApp.operador.operador
    Me.addPermisoGrupo("permisos_contactos")
    'Maps
    Dim GOOGLE_MAPS_API_KEY_BROWSER As String = nvUtiles.getParametroValor("GOOGLE_MAPS_API_KEY_BROWSER", "")
    'Maps

    Dim indice = nvUtiles.obtenerValor("indice", "")
    Dim id_domicilio As String = nvUtiles.obtenerValor("id_contact", "")
    Dim id_tipo As String = nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_id_tipo As Integer = nvUtiles.obtenerValor("nro_id_tipo", 1)

    If id_domicilio <> "" Then
        Me.contents("filtroContactoDomicilio") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verContacto_Domicilio'><campos>*</campos><filtro><id_domicilio type='igual'>" + id_domicilio + "</id_domicilio></filtro><orden>predeterminado desc</orden></select></criterio>")
    End If

    Me.contents("filtroContactoTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_tipo'><campos>distinct nro_contacto_tipo as id, desc_contacto_tipo as [campo]</campos><orden>[id]</orden><filtro><nro_contacto_tipo type='in'>1,2,3,13,14</nro_contacto_tipo></filtro></select></criterio>")
    Me.contents("filtroLocalidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLocalidad'><campos>cod_veraz_prov,postal,postal_real,localidad,cod_prov</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("indice") = indice
    Me.contents("id_domicilio") = id_domicilio
    Me.contents("id_tipo") = id_tipo
    Me.contents("nro_id_tipo") = nro_id_tipo

%>
<html>
<head>
    <title>ABM Contactos - Domicilio</title>
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
    <%-- Google Maps API --%>
    <% 
        If GOOGLE_MAPS_API_KEY_BROWSER <> "" Then Response.Write("<script type=""text/javascript"" src=""https://maps.googleapis.com/maps/api/js?key=" & GOOGLE_MAPS_API_KEY_BROWSER & "&libraries=places&region=AR""></script>")
    %>

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
        var id_domicilio = nvFW.pageContents.id_domicilio;
        var fecha = new Date();
        var win = nvFW.getMyWindow()
        var permisos_contactos = nvFW.permiso_grupos.permisos_contactos
        var id_tipo = nvFW.pageContents.id_tipo
        var nro_id_tipo = nvFW.pageContents.nro_id_tipo

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

            //Maps
            if (window.google) {
                inicializarMaps();
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

                rs.open(nvFW.pageContents.filtroContactoDomicilio)

                if (rs.recordcount >= 1) {

                    piso = (rs.getdata('piso') == null) ? '' : rs.getdata('piso')
                    depto = (rs.getdata('depto') == null) ? '' : rs.getdata('depto')
                    resto = (rs.getdata('resto') == null) ? '' : rs.getdata('resto')

                    $('calle').value = rs.getdata('calle')
                    $('numero').value = rs.getdata('numero')
                    $('piso').value = piso
                    $('depto').value = depto
                    $('resto').value = resto
                    $('postal').value = rs.getdata('postal')
                    $('desc_localidad').value = "CP:" + rs.getdata('postal_real') + " - " + rs.getdata('localidad') + " - " + rs.getdata('provincia')
                    $('observacion').value = rs.getdata('observacion')
                    $('fecha_estado').value = FechaToSTR(parseFecha(rs.getdata('fecha_estado')))
                    //$('operador').value = rs.getdata('nro_operador')
                    $('operador').value = rs.getdata('nombre_operador')
                    campos_defs.set_value("nro_contacto_tipo", rs.getdata('nro_contacto_tipo'))
                    $('cpa').value = rs.getdata('cpa') != null ? rs.getdata('cpa') : ''
                    $('localidad_CPA').value = rs.getdata('localidad')
                    $('cod_veraz_prov').value = rs.getdata('cod_veraz_prov')
                    $('cod_prov').value = rs.getdata('cod_prov')
                    $('checkPredeterminado').checked = rs.getdata('predeterminado') == 'True'

                    if (rs.getdata('vigente') == "True") {
                        $('vigente').checked = true
                    }
                    //if ($('checkPredeterminado').checked) {
                    //    $('vigente').disabled = true
                    //}
                    //else {
                    //    $('vigente').disabled = false
                    //}

                }
            }
            //Cuando se da de alta un nuevo contacto de telefono   
            if (indice < 0)
                $('vigente').checked = true

            //Permiso para Editar Vigente
            if (!nvFW.tienePermiso('permisos_contactos', 8))
                $('vigente').disabled = true
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
                alto = (parent.win.element.offsetTop + parentTop + parent.$$('body')[0].getHeight() / 2) - 100;
                left = (parent.win.element.offsetLeft + parentLeft + parent.$$('body')[0].getWidth() / 2) - 200;
            }
            win_localidad = top.nvFW.createWindow({
                url: '/fw/funciones/localidad_consultar.aspx',
                title: '<b>Seleccionar Localidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: false,
                width: 400,
                height: 200,
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

                $('localidad_CPA').value = objRetorno['localidad']
                $('cod_prov').value = objRetorno['cod_prov']
                $('cod_veraz_prov').value = objRetorno['cod_veraz_prov']
            }
        }

        function trim(cadena) {
            cadena = cadena.replace(/^\s+/, '').replace(/\s+$/, '');
            return (cadena);
        }

        /***    Valida domicilio repetido     ***/
        function valDomicilioRepetido(calle, numero, postal) {
            var repetido = false
            var calle_c

            if (Contactos["domicilio"] != undefined) {
                Contactos["domicilio"].each(function (arreglo, i) {

                    calle_c = trim(Contactos["domicilio"][i]["calle"]).toLowerCase();

                    //Para ver si hay repetidos, comparo: calle, numero
                    //si el contacto de domicilio esta vigente
                    //si el contacto de domicilio no esta borrado
                    if (calle_c == calle.toLowerCase() && trim(Contactos["domicilio"][i]["numero"]) == numero && Contactos["domicilio"][i]["postal"] == postal && Contactos["domicilio"][i]["vigente"] == "True" && Contactos["domicilio"][i]["estado"] != 'BORRADO')
                        repetido = true
                });
            }
            return repetido
        }

        function btnActualizar_onclick() {
            var validacion = ''
            validacion = Validar_domicilio()
            if (validacion != '') {
                alert(validacion)
                return
            }

            var calle = trim($('calle').value)
            var numero = $('numero').value
            var postal = $('postal').value

            //    if (valDomicilioRepetido(calle, numero, postal)) {
            //        alert('La calle, el número y la localidad que intenta ingresar ya existen como Contacto de Domicilio.')
            //        return false
            //    } 

            var predeterminado = $('checkPredeterminado').checked ? "True" : "False"

            if ($('checkPredeterminado').checked && !$('vigente').checked) {
                alert('Un domicilio "no vigente" no puede ser predeterminado.')
                return
            }

            var ins = indice
            if (indice < 0) {

                var inicio = '<![CDATA['
                var fin = ']]>'

                var xmldato = ""
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<contactos>"
                xmldato += "<domicilios>"

                var vigente;
                if ($('vigente').checked == true)
                    vigente = 'True'
                else
                    vigente = 'False'

                xmldato += "\n<domicilio id_domicilio='0' numero ='" + numero + "' piso ='" + $('piso').value + "' depto ='" + $('depto').value + "' resto ='" + $('resto').value + "' postal ='" + postal + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' observacion ='" + $('observacion').value + "' nro_contacto_tipo ='" + $('nro_contacto_tipo').value + "' predeterminado ='" + predeterminado + "' orden='1' vigente='" + vigente + "' estado='Nuevo' cpa='" + $('cpa').value + "' id_ro_domicilio = '0'>"
                xmldato += "<calle>" + inicio + calle + fin + "</calle>"
                xmldato += "</domicilio>"

                xmldato += "</domicilios>"

                xmldato += "<telefonos>"
                xmldato += "</telefonos>"

                xmldato += "<horarios>"
                xmldato += "</horarios>"

                xmldato += "<emails>"
                xmldato += "</emails>"

                xmldato += "</contactos>"
                //return xmldato
                if ($('checkPredeterminado').checked)
                    Dialog.confirm('A partir de ahora este sera su domicilio predeterminado.', {
                        className: "alphacube",
                        width: 280,
                        onOk: function (win) {
                            ajax_contacto('A', xmldato, id_tipo, nro_id_tipo);
                            win.close();
                        },
                        onCancel: function (win) { win.close(); },
                        okLabel: 'Confirmar',
                        cancelLabel: 'Cancelar'
                    });
                else
                    ajax_contacto('A', xmldato, id_tipo, nro_id_tipo);

            }
            else {

                if (predeterminado == "True") {
                    //Si el contacto de domicilio es predeterminado, el tipo de contacto debe ser: "Personal(1)"
                    if ($('nro_contacto_tipo').value != 1) {
                        alert('Un contacto de domicilio Predeterminado debe ser de tipo "Personal"')
                        return false
                    }
                }


                var inicio = '<![CDATA['
                var fin = ']]>'

                var xmldato = ""
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<contactos>"
                xmldato += "<domicilios>"

                var vigente;
                if ($('vigente').checked == true)
                    vigente = 'True'
                else
                    vigente = 'False'

                xmldato += "\n<domicilio id_domicilio='" + id_domicilio + "' numero ='" + numero + "' piso ='" + $('piso').value + "' depto ='" + $('depto').value + "' resto ='" + $('resto').value + "' postal ='" + postal + "' nro_operador ='" + nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' observacion ='" + $('observacion').value + "' nro_contacto_tipo ='" + $('nro_contacto_tipo').value + "' predeterminado ='" + predeterminado + "' orden='1' vigente='" + vigente + "' estado='EDITADO' cpa='" + $('cpa').value + "' id_ro_domicilio = '0'>"
                xmldato += "<calle>" + inicio + calle + fin + "</calle>"
                xmldato += "</domicilio>"

                xmldato += "</domicilios>"

                xmldato += "<telefonos>"
                xmldato += "</telefonos>"

                xmldato += "<horarios>"
                xmldato += "</horarios>"

                xmldato += "<emails>"
                xmldato += "</emails>"

                xmldato += "</contactos>"
                //return xmldato

                if ($('checkPredeterminado').checked)
                    Dialog.confirm('A partir de ahora este sera su domicilio predeterminado.', {
                        className: "alphacube",
                        width: 280,
                        onOk: function (win) {
                            ajax_contacto('M', xmldato, id_tipo, nro_id_tipo);
                            win.close();
                        },
                        onCancel: function (win) { win.close(); },
                        okLabel: 'Confirmar',
                        cancelLabel: 'Cancelar'
                    });
                else
                    ajax_contacto('M', xmldato, id_tipo, nro_id_tipo);

            }


        }


        function ajax_contacto(modo, xmldato, id_tipo, nro_id_tipo) {
            nvFW.error_ajax_request('contacto_ABM.aspx', {
                parameters: {
                    modo: modo,
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


        function Validar_domicilio() {
            var mensaje = ''
            if ($('calle').value == '')
                mensaje = mensaje + 'El campo "Calle" no puede ser vacio.\n'
            if ($('numero').value == '')
                mensaje = mensaje + 'El campo "Número" no puede ser vacio.\n'
            if ($('postal').value == '')
                mensaje = mensaje + 'El campo "Localidad" no puede ser vacio.\n'
            if ($('nro_contacto_tipo').value == '')
                mensaje = mensaje + 'El campo "Tipo Contacto" no puede ser vacio.\n'

            return mensaje
        }

        function enter_onkeypress(e) {
            key = Prototype.Browser.IE ? e.keyCode : e.which
            if (key == 13)
                Aceptar()
        }

        /***    Valida formato de CPA    ***/
        function valFormatoCPA(cpa) {
            var RegExPattern = /^[a-zA-Z]{1}[0-9]{4}[a-zA-Z]{3}$/;
            if ((cpa.match(RegExPattern)) && (cpa != ''))
                return true
            else {
                return false
            }
        }

        function valCPA() {
            var cpa = $('cpa').value
            if (cpa != '') {
                if (!valFormatoCPA(cpa)) {
                    alert('El CPA debe tener 8 caracteres con el siguiente formato obligatorio: 1 letra + 4 dígitos + 3 letras.')
                    $('cpa').focus()
                    return false
                } else {
                    var postal = $('postal').value
                    var primer_letra = cpa.charAt(0)
                    var cod_veraz_prov = ''
                    var filtro = "<postal type='igual'>" + postal + "</postal>"
                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtroLocalidad, "", filtro)
                    if (!rs.eof())
                        cod_veraz_prov = rs.getdata('cod_veraz_prov') != null ? rs.getdata('cod_veraz_prov') : ''

                    if (cod_veraz_prov != '') {
                        if (primer_letra != cod_veraz_prov) {
                            alert('La primer letra del CPA ("' + primer_letra + '"), no corresponde a la Provincia seleccionada.')
                            $('cpa').focus()
                            return false
                        }
                    } else {
                        alert('Antes de completar el CPA, debe seleccionar la Localidad del socio.')
                        $('cpa').value = ''
                        return false
                    }
                }
            }
        }

        function selCPA() {
            var parametros_CPA = new Array()
            parametros_CPA['calle'] = $('calle').value
            parametros_CPA['numero'] = $('numero').value == 'undefined' ? '' : $('numero').value
            parametros_CPA['localidad'] = $('localidad_CPA').value
            parametros_CPA['cod_prov'] = $('cod_prov').value
            parametros_CPA['cod_veraz_prov'] = $('cod_veraz_prov').value

            win_CPA = parent.nvFW.createWindow({ //new Window({
                className: 'alphacube',
                url: '/FW/funciones/selCPA.aspx',
                title: '<b>Seleccionar CPA</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: false,
                width: 840,
                height: 240,
                onClose: selCPA_return
            });

            win_CPA.options.userData = { parametros_CPA: parametros_CPA }
            win_CPA.showCenter(true)
        }

        function selCPA_return() {

            if (win_CPA.options.userData.res) {

                var objRetorno = win_CPA.options.userData.res

                $('cpa').value = objRetorno['CPA']
                if ($('calle').value == '')
                    $('calle').value = objRetorno['calle']
                if ($('numero').value == '')
                    $('numero').value = objRetorno['numero']
                if ($('desc_localidad').value == '') {
                    $('desc_localidad').value = localidad_desc(objRetorno['localidad'])
                    $('localidad_CPA').value = objRetorno['localidad']
                    $('cod_prov').value = objRetorno['cod_prov']
                    $('cod_veraz_prov').value = objRetorno['cod_veraz_prov']
                }

            }

        }


        function localidad_desc(localidad) {
            var filtro = "<localidad type='like'>" + localidad + "</localidad></filtro>"
            var rs = new tRS();
            rs.open(nvFW.pageContents.filtroLocalidad, "", filtro)
            if (!rs.eof()) {
                $('postal').value = rs.getdata('postal')
                return 'CP: ' + rs.getdata('postal_real') + ' - ' + rs.getdata('localidad')
            }
            else {
                return ''
            }
        }


        //Maps autocompletar calle
        var autocomplete;
        function inicializarMaps() {
            // Box general
            var configs = {
                types: ['address'],
                //types: ['(cities)'],
                //types: ['geocode'],
                componentRestrictions: { country: 'ar' }
            };

            //Box calle
            var input = $('calle');
            var calleInputHtml = input.outerHTML;
            input.placeholder = ''; //'Ingrese una dirección. Ej: Bv. Oroño 126, Rosario, Santa Fe';
            input.autocomplete = 'on';

            autocomplete = new google.maps.places.Autocomplete(input, configs);
            autocomplete.setFields(['address_components']);
            var autocompleteLsr = autocomplete.addListener('place_changed', setDataMapCallback); // Evento seleccionar

            //Captura el error de autenticación de Google Maps API
            gm_authFailure = function () {
                //Destruimos el autocomplete y liberamos el campo
                var valor = $('calle').value;
                google.maps.event.removeListener(autocompleteLsr);
                google.maps.event.clearInstanceListeners(autocomplete);
                $('calle').outerHTML = calleInputHtml;
                $('calle').value = valor;
                $('calle').focus();
                console.log("Google Maps JavaScript API no pudo autenticar. El autocompletado del domicilio no estará disponible.")
            };
        }

        function setDataMapCallback() {

            var filtro = '';
            var place = autocomplete.getPlace();

            if (place.address_components) {
                var item;
                $('desc_localidad').value = '';

                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];

                    //if (item.types[0] == 'route')
                    //    if (item.long_name) $('calle').value = item.long_name;

                    switch (item.types[0]) {
                        case 'route':
                            if (item.long_name) $('calle').value = item.long_name;
                            //if (item.long_name) campos_defs.set_value('calle', item.long_name);
                            break;

                        case 'street_number':
                            if (item.long_name) $('numero').value = item.long_name;
                            break;

                        case 'locality':
                            if (item.long_name) /*campos_defs.set_value('ciudad', item.long_name);*/
                                if (item.long_name) {
                                    $('desc_localidad').value += item.long_name.toUpperCase();
                                    filtro += "<localidad type='sql'> '" + reemplazarAcentos(item.long_name) + "' = localidad collate Latin1_General_CI_AI</localidad >";

                                }
                            break;

                        //case 'postal_code':
                        //    console.log('entro')
                        //    if (item.long_name) $localidad.value = "CP: " + item.long_name + ' - ' + $localidad.value;
                        //    break;

                        case 'administrative_area_level_1':
                            if (item.long_name) {
                                $('desc_localidad').value += ' - ' + item.long_name.toUpperCase();
                                filtro += "<provincia type='sql'>'" + reemplazarAcentos(item.long_name) + "' = provincia collate Latin1_General_CI_AI</provincia>";
                            }
                            break;
                    }
                }

                var rsLocalidad = new tRS();

                rsLocalidad.open(nvFW.pageContents.filtroLocalidad, "", filtro)

                if (!rsLocalidad.eof()) {
                    $('postal').value = rsLocalidad.getdata('postal');
                    $('desc_localidad').value = 'CP: ' + rsLocalidad.getdata('postal_real') + ' - ' + $('desc_localidad').value;

                    $('localidad_CPA').value = rsLocalidad.getdata('localidad');
                    $('cod_prov').value = rsLocalidad.getdata('cod_prov');
                    $('cod_veraz_prov').value = rsLocalidad.getdata('cod_veraz_prov');
                    //postal_telefono = $postal.value;
                    //$car_tel.value = rsLocalidad.getdata('car_tel');
                }

            }
        }

        function reemplazarAcentos(cadena) {
            var chars = {
                "á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
                "à": "a", "è": "e", "ì": "i", "ò": "o", "ù": "u", "ñ": "n",
                "Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U",
                "À": "A", "È": "E", "Ì": "I", "Ò": "O", "Ù": "U", "Ñ": "N"
            }
            var expr = /[áàéèíìóòúùñ]/ig;
            var res = cadena.replace(expr, function (e) { return chars[e] });
            return res;
        }


        function vigenteOnchange() {
            if (!$('vigente').checked) {
                $('checkPredeterminado').checked = false
                $('checkPredeterminado').disabled = true
            } else { $('checkPredeterminado').disabled = false }
        }

    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="Contacto_Domicilio_ABM.aspx" method="post" name="form1" target="frmEnviar">
        <input type="hidden" name="indice" id="indice" value="<%=indice %>" />
        <input type="hidden" name="postal" id="postal" value="" />
        <input type="hidden" name="predeterminado" id="predeterminado" value="" />
        <input type="hidden" name="localidad_CPA" id="localidad_CPA" value="" />
        <input type="hidden" name="cod_prov" id="cod_prov" value="" />
        <input type="hidden" name="cod_veraz_prov" id="cod_veraz_prov" value="" />
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width: 100%">
                    <div id="divMenuDomicilioABM"></div>
                    <script type="text/javascript">
                        var vMenuDomicilioABM = new tMenu('divMenuDomicilioABM', 'vMenuDomicilioABM');
                        //vMenuDomicilioABM.loadImage("punto", "/FW/image/icons/punto.gif")
                        Menus["vMenuDomicilioABM"] = vMenuDomicilioABM
                        Menus["vMenuDomicilioABM"].alineacion = 'centro';
                        Menus["vMenuDomicilioABM"].estilo = 'A';
                        //Menus["vMenuDomicilioABM"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 14px'><Lib TipoLib='offLine'>DocMNG</Lib><icono>punto</icono><Desc></Desc></MenuItem>")
                        Menus["vMenuDomicilioABM"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Domicilio</Desc></MenuItem>")
                        vMenuDomicilioABM.MostrarMenu()
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 55%; text-align: center">Calle*</td>
                <td style="width: 10%; text-align: center">Nro*</td>
                <td style="width: 10%; text-align: center">Piso</td>
                <td style="width: 10%; text-align: center">Dpto</td>
                <td style="width: 15%; text-align: center">Resto</td>
            </tr>
            <tr>
                <td style="width: 55%">
                    <input style="width: 100%" type="text" name="calle" id="calle" value="" maxlength="50" /></td>
                <!--<td id="td_numero" style="width:15%" ></td>-->
                <td style="width: 10%">
                    <input type="text" name="numero" id="numero" style="width: 100%" value="" onkeypress="return enter_onkeypress(event) || valDigito(event)" maxlength="5" /></td>
                <td style="width: 10%">
                    <input type="text" name="piso" id="piso" style="width: 100%" value="" maxlength="2" /></td>
                <td style="width: 10%">
                    <input type="text" name="depto" id="depto" style="width: 100%" value="" maxlength="4" /></td>
                <td style="width: 15%">
                    <input type="text" name="resto" id="resto" style="width: 100%" value="" /></td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 50%; text-align: center">Localidad*</td>
                <td style="width: 23%; text-align: center" colspan="2">CPA</td>
                <td style="width: 27%; text-align: center">Tipo Contacto*</td>
            </tr>
            <tr>
                <td style="width: 50%" nowrap>
                    <input style="width: 93%" name="desc_localidad" id="desc_localidad" ondblclick="selLocalidad()" readonly /><input type="button" name="btnSelLocalidad" id="btnSelLocalidad" value="." size="1" onclick="selLocalidad()" /></td>
                <td style="width: 23%">
                    <input style="width: 100%" type="text" name="cpa" id="cpa" value="" maxlength="8" onchange="return valCPA()" /></td>
                <td>
                    <input type="button" name="btnSelCPA" id="btnSelCPA" value="." size="1" onclick="selCPA()" /></td>
                <td style="width: 27%" id="td_nro_contacto_tipo"></td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 100%; text-align: center">Observación</td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <input name="observacion" id="observacion" style="width: 100%" /></td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 50%; text-align: center">Fecha Estado</td>
                <td style="width: 25%; text-align: center">Operador</td>
                <td style="width: 12.5%; text-align: center">Vigente</td>
                <td style="width: 12.5%; text-align: center">Predeterminado</td>
            </tr>
            <tr>
                <td style="width: 50%">
                    <input name="fecha_estado" id="fecha_estado" style="width: 100%; text-align: right" disabled="disabled" /></td>
                <td style="width: 25%">
                    <input name="operador" id="operador" style="width: 100%" disabled="disabled" /></td>
                <td style="width: 12.5%">
                    <div id="div_vigente">
                        <input type="checkbox" name="vigente" id="vigente" onchange="vigenteOnchange()" style="width: 100%" />
                    </div>
                </td>
                <td style="width: 12.5%">
                    <div id="div_predeterminado">
                        <input type="checkbox" name="checkPredeterminado" id="checkPredeterminado" style="width: 100%" />
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
