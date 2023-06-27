<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim tipdoc As Integer = nvFW.nvUtiles.obtenerValor("tipdoc", 0)
    Dim nrodoc As Long = nvFW.nvUtiles.obtenerValor("nrodoc", 0)


    If tipdoc > 0 And nrodoc > 0 Then
        'Dim op = nvFW.nvApp.getInstance.operador
        'If (Not op.tienePermiso("permisos_entidades", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx?No posee permisos para ver las entidades.")

        Dim campos_tcl As String = "tipdoc, nrodoc, paiscod, succod, domcod, tipdomcod, domnom, domnro, dompiso, domdepto, codpos, " +
            "domhsdesde, domhrshasta, compper, dommai, loccod, codprov, dptocod, domdiahabdes, domdiahabhas, resipaiscod, " +
            "domtoddiades, domtoddiahas, domdiaferdes, domdiaferhas, barrio, manz, block, lote, " +
            "dominio_mail, usuario_mail, cpa"
        Me.contents("domXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tcl_Domicilio' cn='BD_IBS_ANEXA'><campos>" + campos_tcl + "</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden>domcod ASC</orden></select></criterio>")

        Me.contents("tipdoc") = tipdoc
        Me.contents("nrodoc") = nrodoc

    End If

    'Me.addPermisoGrupo("permisos_vinculos")
%>
<!DOCTYPE html>
<html lang="es-ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title>Cliente Domicilios</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/switch.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        body {
            width: 100%;
            height: 100%;
            overflow: auto;
        }
        .pac-container.pac-logo::after {
            content: none;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/IMask/imask.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        
        var vButtonItems = {};
        var vListButton  = null;

        var _actionDom = "A"

        function loadButtons()
        {
            vButtonItems[0] = {
                "nombre":   "Mostrar",
                "etiqueta": "Mostrar",
                "imagen":   "mostrar",
                "onclick":  "return mostrarDom()"
            };

            vButtonItems[1] = {
                "nombre":   "Nuevo",
                "etiqueta": "Nuevo",
                "imagen":   "nuevo",
                "onclick":  "return nuevoDom()"
            };

            vButtonItems[2] = {
                "nombre":   "Borrar",
                "etiqueta": "Borrar",
                "imagen":   "eliminar",
                "onclick":  "return eliminarDom()"
            };

            vButtonItems[3] = {
                "nombre": "Guardar",
                "etiqueta": "Guardar",
                "imagen": "guardar",
                "onclick": "return guardarDom()"
            };

            vListButton = new tListButton(vButtonItems, 'vListButton');

            vListButton.loadImage("mostrar", '/FW/image/icons/ver.png');
            vListButton.loadImage("nuevo", '/FW/image/icons/agregar.png');
            vListButton.loadImage("eliminar", '/FW/image/icons/eliminar.png');
            vListButton.loadImage("guardar", '/FW/image/icons/guardar.png');

            vListButton.MostrarListButton();
        }


        function window_onload()
        {
            CargarDatos()

            loadButtons();
            window_onresize();
        }


        function window_onresize()
        {
            try
            {
            }
            catch (e) {}
        }

        var domList
        function CargarDatos() {

            domList = []
            $('domListBody').innerHTML = "";

            if (nvFW.pageContents == undefined || nvFW.pageContents.tipdoc == undefined || nvFW.pageContents.nrodoc == undefined) return;

            var rs = new tRS();
            rs.async = true;

            rs.onComplete = function (res) {

                while (!res.eof()) {
                    var dom = {
                        tipdoc: res.getdata("tipdoc"),
                        nrodoc: res.getdata("nrodoc"),
                        paiscod: res.getdata("paiscod"),
                        domcod: res.getdata("domcod"),
                        domnom: res.getdata("domnom"),
                        succod: res.getdata("succod"),
                        tipdomcod: res.getdata("tipdomcod"),
                        domnro: res.getdata("domnro"),
                        dompiso: res.getdata("dompiso"),
                        domdepto: res.getdata("domdepto"),
                        codpos: res.getdata("codpos"),
                        domhsdesde: res.getdata("domhsdesde"),
                        domhrshasta: res.getdata("domhrshasta"),
                        compper: res.getdata("compper"),
                        dommai: res.getdata("dommai"),
                        loccod: res.getdata("loccod"),
                        codprov: res.getdata("codprov"),
                        dptocod: res.getdata("dptocod"),
                        domdiahabdes: res.getdata("domdiahabdes"),
                        domdiahabhas: res.getdata("domdiahabhas"),
                        resipaiscod: res.getdata("resipaiscod"),
                        domtoddiades: res.getdata("domtoddiades"),
                        domtoddiahas: res.getdata("domtoddiahas"),
                        domdiaferdes: res.getdata("domdiaferdes"),
                        domdiaferhas: res.getdata("domdiaferhas"),
                        barrio: res.getdata("barrio"),
                        manz: res.getdata("manz"),
                        block: res.getdata("block"),
                        lote: res.getdata("lote"),
                        dominio_mail: res.getdata("dominio_mail"),
                        usuario_mail: res.getdata("usuario_mail"),
                        cpa: res.getdata("cpa")
                    }

                    
                    var fila = '<tr onclick="seleccionarDom(' + domList.length + ')" style="cursor: pointer;"><td width="5px"><input type="radio" name="domRadio" id="radio' + domList.length + '" data-index="' + domList.length + '" style="cursor: pointer;" title="Seleccionar"></td>' +
                        '<td class="Tit2" width="15%" nowrap>' + dom.domcod + '</td>' +
                        '<td>' + dom.domnom + ' ' + (dom.domnro ? dom.domnro : '') + '</td></tr >';
                    $$('#domListBody')[0].insert(fila);

                    domList.push(dom);

                    res.movenext()
                }
                nvFW.bloqueo_desactivar($$('body')[0], 'bloq_domicilios')
            }

            rs.onError = function (res) {
                nvFW.bloqueo_desactivar($$('body')[0], 'bloq_domicilios')
                alert(res.lastError.numError + ' - ' + res.lastError.mensaje);
            }

            nvFW.bloqueo_activar($$('body')[0], 'bloq_domicilios', 'Cargando domicilios de cliente...')
            rs.open(nvFW.pageContents.domXML);
        }

        function seleccionarDom(fila) {
            limpiarCampos()
            $$("#radio" + fila)[0].checked = true;
        }

        function getDomicilioSeleccionado() {
            var rSelected = $$("#domListBody input[type=radio]:checked")[0]
            if (rSelected == undefined) {
                return undefined;
            }

            var domSelected = domList[rSelected.dataset.index]

            return domSelected;
        }

        function limpiarCampos() {
            _actionDom = "A"

            $$("#esglobal")[0].checked = false
            campos_defs.set_value("codpos", "")
            campos_defs.set_value("cpa", "")

            campos_defs.set_value("paiscod", "")
            campos_defs.set_value("codprovs", "")
            campos_defs.set_value("dptocod", "")
            campos_defs.set_value("loccod", "")

            campos_defs.set_value("tipdomcod", "")

            campos_defs.set_value("domdiahabdes", "")
            campos_defs.set_value("domdiahabhas", "")
            campos_defs.set_value("domdiaferdes", "")
            campos_defs.set_value("domdiaferhas", "")
            campos_defs.set_value("domtoddiades", "")
            campos_defs.set_value("domtoddiahas", "")

            if ($("compper").value == "1")
                $("compper").parentElement.click()
            if ($("dommai").value == "1")
                $("dommai").parentElement.click()

            campos_defs.set_value("domnom", "")
            campos_defs.set_value("domnro", "")
            campos_defs.set_value("block", "")
            campos_defs.set_value("dompiso", "")
            campos_defs.set_value("domdepto", "")
            campos_defs.set_value("barrio", "")
            campos_defs.set_value("manz", "")
            campos_defs.set_value("lote", "")

            campos_defs.set_value("usuario_mail", "")
            campos_defs.set_value("dominio_mail", "")

        }

        function mostrarDom() {
            limpiarCampos()
            _actionDom = "M"

            var domSelected = getDomicilioSeleccionado()
            if (domSelected == undefined) {
                alert("Seleccione un domicilio")
                return;
            }


            $$("#esglobal")[0].checked = domSelected.succod == 0

            campos_defs.set_value("codpos", domSelected.codpos)
            if (domSelected.cpa != undefined)
                campos_defs.set_value("cpa", domSelected.cpa)

            campos_defs.set_value("paiscod", domSelected.resipaiscod)
            campos_defs.set_value("codprovs", domSelected.codprov)
            campos_defs.set_value("dptocod", domSelected.dptocod)
            campos_defs.set_value("loccod", domSelected.loccod)

            campos_defs.set_value("tipdomcod", domSelected.tipdomcod)

            if (domSelected.domdiahabdes) {
                var fec = parseFecha(domSelected.domdiahabdes)
                campos_defs.set_value("domdiahabdes", ("0" + fec.getHours()).slice(-2) + ("0" + fec.getMinutes()).slice(-2))
            }
            if (domSelected.domdiahabhas) {
                var fec = parseFecha(domSelected.domdiahabhas)
                campos_defs.set_value("domdiahabhas", ("0" + fec.getHours()).slice(-2) + ("0" + fec.getMinutes()).slice(-2))
            }
            if (domSelected.domdiaferdes) {
                var fec = parseFecha(domSelected.domdiaferdes)
                campos_defs.set_value("domdiaferdes", ("0" + fec.getHours()).slice(-2) + ("0" + fec.getMinutes()).slice(-2))
            }
            if (domSelected.domdiaferhas) {
                var fec = parseFecha(domSelected.domdiaferhas)
                campos_defs.set_value("domdiaferhas", ("0" + fec.getHours()).slice(-2) + ("0" + fec.getMinutes()).slice(-2))
            }
            if (domSelected.domtoddiades) {
                var fec = parseFecha(domSelected.domtoddiades)
                campos_defs.set_value("domtoddiades", ("0" + fec.getHours()).slice(-2) + ("0" + fec.getMinutes()).slice(-2))
            }
            if (domSelected.domtoddiahas) {
                var fec = parseFecha(domSelected.domtoddiahas)
                campos_defs.set_value("domtoddiahas", ("0" + fec.getHours()).slice(-2) + ("0" + fec.getMinutes()).slice(-2))
            }

            if (domSelected.compper == "S")
                $("compper").parentElement.click()
            if (domSelected.dommai == "S")
                $("dommai").parentElement.click()

            campos_defs.set_value("domnom", domSelected.domnom)
            if (domSelected.domnro != undefined)
                campos_defs.set_value("domnro", domSelected.domnro)

            if (domSelected.block != undefined)
                campos_defs.set_value("block", domSelected.block)
            if (domSelected.dompiso != undefined)
                campos_defs.set_value("dompiso", domSelected.dompiso)
            if (domSelected.domdepto != undefined)
                campos_defs.set_value("domdepto", domSelected.domdepto)
            if (domSelected.barrio != undefined)
                campos_defs.set_value("barrio", domSelected.barrio)
            if (domSelected.manz != undefined)
                campos_defs.set_value("manz", domSelected.manz)
            if (domSelected.lote != undefined)
            campos_defs.set_value("lote", domSelected.lote)

            if (domSelected.usuario_mail != undefined)
                campos_defs.set_value("usuario_mail", domSelected.usuario_mail)
            if (domSelected.dominio_mail != undefined)
                campos_defs.set_value("dominio_mail", domSelected.dominio_mail)
            
        }

        function nuevoDom() {
            limpiarCampos()
            _actionDom = "A"

            var rSelected = $$("#domListBody input[type=radio]:checked")[0]
            if (rSelected != undefined)
                rSelected.checked = false

        }

        function eliminarDom() {

            var domSelected = getDomicilioSeleccionado()
            if (domSelected == undefined) {
                alert("Seleccione un domicilio")
                return;
            }

            var datos = {};

            datos["domcod"] = parseInt(domSelected.domcod, 10)

            datos["action"] = "B";
            datos["paiscod"] = 54;
            datos["bcocod"] = 312;
            datos["succod"] = parseInt(domSelected.succod, 10);//1;
            datos["tipdoc"] = parseInt(domSelected.tipdoc, 10);// parent.campos_defs.get_value("tipdoc");//8;
            datos["nrodoc"] = parseInt(domSelected.nrodoc, 10);//20259040329;
            datos["confirmar_cambios"] = true
            datos["ef"] = ""

            nvFW.error_ajax_request('/voii/ibs/cliente/domicilio/scl_dtcl_domicilio.aspx', {
                postBody: JSON.stringify(datos),
                contentType: "application/json",
                method: 'post',
                bloq_msg: "Eliminando",
                onFailure: function (err, transport) { console.log(transport.responseText) },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        limpiarCampos();
                        CargarDatos();
                    }

                },
                error_alert: true
            });
        }

        function guardarDom() {

            var datos = {};

            var urlAction

            if (_actionDom == "A")
                urlAction = '/voii/ibs/cliente/domicilio/scl_itcl_domicilio.aspx'
            if (_actionDom == "M") {
                urlAction = '/voii/ibs/cliente/domicilio/scl_utcl_domicilio.aspx'

                var domSelected = getDomicilioSeleccionado()
                datos["domcod"] = parseInt(domSelected.domcod, 10)
            }
                

            if (urlAction == undefined)
                return;

            datos["codpos"] = campos_defs.get_value("codpos")
            datos["cpa"] = campos_defs.get_value("cpa")

            datos["resipaiscod"] = campos_defs.get_value("paiscod") ? parseInt(campos_defs.get_value("paiscod"), 10) : null;//54;
            datos["codprov"] = campos_defs.get_value("codprovs") ? parseInt(campos_defs.get_value("codprovs"), 10) : null;//1;
            datos["dptocod"] = campos_defs.get_value("dptocod") ? parseInt(campos_defs.get_value("dptocod"), 10) : null;//1;
            datos["loccod"] = campos_defs.get_value("loccod") ? parseInt(campos_defs.get_value("loccod"), 10) : null;

            datos["tipdomcod"] = campos_defs.get_value("tipdomcod") ? parseInt(campos_defs.get_value("tipdomcod"), 10) : null;

            var domdiahabdes = campos_defs.get_value("domdiahabdes")
            if (domdiahabdes != "") {
                if (domdiahabdes.length != 4) {
                    alert("Revise el horario para días habiles.")
                    return
                }

                var fec = new Date();
                fec.setHours(domdiahabdes.substring(0, 2))
                fec.setMinutes(domdiahabdes.substring(2, 4))
                fec.setSeconds(0)
                datos["domdiahabdes"] = new Date(fec.getTime() - fec.getTimezoneOffset() * 60000).toISOString()
            }

            var domdiahabhas = campos_defs.get_value("domdiahabhas")
            if (domdiahabhas != "") {
                if (domdiahabhas.length != 4) {
                    alert("Revise el horario para días habiles.")
                    return
                }

                var fec = new Date()
                fec.setHours(domdiahabhas.substring(0, 2))
                fec.setMinutes(domdiahabhas.substring(2, 4))
                fec.setSeconds(0)
                datos["domdiahabhas"] = new Date(fec.getTime() - fec.getTimezoneOffset() * 60000).toISOString()
            }

            var domdiaferdes = campos_defs.get_value("domdiaferdes")
            if (domdiaferdes != "") {
                if (domdiaferdes.length != 4) {
                    alert("Revise el horario para días feriados.")
                    return
                }

                var fec = new Date()
                fec.setHours(domdiaferdes.substring(0, 2))
                fec.setMinutes(domdiaferdes.substring(2, 4))
                fec.setSeconds(0)
                datos["domdiaferdes"] = new Date(fec.getTime() - fec.getTimezoneOffset() * 60000).toISOString()
            }

            var domdiaferhas = campos_defs.get_value("domdiaferhas")
            if (domdiaferhas != "") {
                if (domdiaferhas.length != 4) {
                    alert("Revise el horario para días feriados.")
                    return
                }

                var fec = new Date()
                fec.setHours(domdiaferhas.substring(0, 2))
                fec.setMinutes(domdiaferhas.substring(2, 4))
                fec.setSeconds(0)
                datos["domdiaferhas"] = new Date(fec.getTime() - fec.getTimezoneOffset() * 60000).toISOString()
            }

            var domtoddiades = campos_defs.get_value("domtoddiades")
            if (domtoddiades != "") {
                if (domtoddiades.length != 4) {
                    alert("Revise el horario para todos los días.")
                    return
                }

                var fec = new Date()
                fec.setHours(domtoddiades.substring(0, 2))
                fec.setMinutes(domtoddiades.substring(2, 4))
                fec.setSeconds(0)
                datos["domtoddiades"] = new Date(fec.getTime() - fec.getTimezoneOffset() * 60000).toISOString()
            }

            var domtoddiahas = campos_defs.get_value("domtoddiahas")
            if (domtoddiahas != "") {
                if (domtoddiahas.length != 4) {
                    alert("Revise el horario para todos los días.")
                    return
                }

                var fec = new Date()
                fec.setHours(domtoddiahas.substring(0, 2))
                fec.setMinutes(domtoddiahas.substring(2, 4))
                fec.setSeconds(0)
                datos["domtoddiahas"] = new Date(fec.getTime() - fec.getTimezoneOffset() * 60000).toISOString()
            }

            datos["compper"] = $("compper").value == "1" ? "S" : "N"
            datos["dommai"] = $("dommai").value == "1" ? "S" : "N"

            datos["domnom"] = campos_defs.get_value("domnom")
            datos["domnro"] = campos_defs.get_value("domnro")
            datos["block"] = campos_defs.get_value("block")
            datos["dompiso"] = campos_defs.get_value("dompiso")
            datos["domdepto"] = campos_defs.get_value("domdepto")
            datos["barrio"] = campos_defs.get_value("barrio")
            datos["manz"] = campos_defs.get_value("manz")
            datos["lote"] = campos_defs.get_value("lote")
            
            datos["usuario_mail"] = campos_defs.get_value("usuario_mail")
            datos["dominio_mail"] = campos_defs.get_value("dominio_mail")
            
            // //

            datos["action"] = _actionDom;
            datos["paiscod"] = 54;//datos.paiscod;
            datos["bcocod"] = 312;
            datos["succod"] = $$("#esglobal")[0].checked ? 0 : 1;//1;
            datos["tipdoc"] = parseInt(parent.campos_defs.get_value("tipdoc"), 10);//8;
            datos["nrodoc"] = parseInt(parent.campos_defs.get_value("nrodoc"), 10);//20259040329;
            datos["confirmar_cambios"] = true
            datos["ef"] = ""

            nvFW.error_ajax_request(urlAction, {
                postBody: JSON.stringify(datos),//{ clientData: JSON.stringify(datos) },
                contentType: "application/json",
                method: 'post',
                bloq_msg: "Guardando",
                onFailure: function (err, transport) { console.log(transport.responseText) },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        limpiarCampos();
                        CargarDatos();
                    }

                },
                error_alert: true
            });
        }

        function cambiar_valor(obj)
        {
            var inputObj = obj.getElementsByTagName("input")[0];
            
            if (!inputObj) return;

            if (inputObj.value === "1")
            {
                inputObj.className = "slider4";
                inputObj.value     = "0";
            }
            else
            {
                inputObj.className = "slider3";
                inputObj.value     = "1";
            }
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()">
    
    <table class="tb1" cellpadding="0" cellspacing="0">
        <tr class="tbLabel">
            <td>Domicilios</td>
        </tr>
    </table>
    
    <div style="width: 80%; float: left;">
        <table class="tb1 highlightOdd highlightTROver">
            <tbody id="domListBody">
                <tr class="tbLabel">
                    <td></td>
                    <td style="width: 25px; text-align: center;">DomCo</td>
                    <td style="text-align: center;"></td>
                </tr>
            </tbody>
        </table>
    </div>

    <div style="width: 20%; float:left;">
        <div id="divDomicilioAcciones"></div>
        <div id="divMostrar"></div>
        <div id="divNuevo"></div>
        <div id="divBorrar"></div>
        <div id="divGuardar"></div>
    </div>

    <table class="tb1">
        <tr class="tbLabel">
            <td>Datos del domicilio</td>
        </tr>
    </table>

    <div style="width: 70%; float:left;">
        <input type="checkbox" name="esglobal" id="esglobal" />Domicilio global
        <table class="tb1">
            <tr>
                <td class="Tit1">Código Postal</td>
                <td>
                    <script>
                        campos_defs.add('codpos', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
                <td class="Tit1">CPA</td>
                <td>
                    <script>
                        campos_defs.add('cpa', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td class="Tit1">País</td>
           
                <td>
                    <script type="text/javascript">
                        campos_defs.add('paiscod', {
                            nro_campo_tipo: 1
                        });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Provincia</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('codprovs', {
                            nro_campo_tipo:   1,
                            depende_de:       'paiscod',
                            depende_de_campo: 'paiscod'
                        });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Part. Dpto.</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('dptocod', {
                            depende_de: 'codprovs',
                            depende_de_campo: 'codprov'
                        });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Localidad</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add("loccod", {
                            nro_campo_tipo:   1,
                            depende_de:       'codprovs',
                            depende_de_campo: 'codprov'
                        });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Tipo</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add("tipdomcod");
                    </script>
                </td>
            </tr>
        </table>
    </div>

    <div style="width:30%; float:left">
        <table class="tb1">
            <tr class="tbLabel">
                <td colspan="3">Horarios para encontrarlo</td>
            </tr>
            <tr>
                <td width="50%"></td>
                <td class="Tit1">Desde</td>
                <td class="Tit1">Hasta</td>
            </tr>
            <tr>
                <td class="Tit1" nowrap>Días habiles</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('domdiahabdes', { enDB: false, nro_campo_tipo: 104,
                            mask: {
                                mask: 'h:m',
                                blocks: {
                                    h: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 23,
                                        maxLength: 2
                                    },
                                    m: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 59,
                                        maxLength: 2
                                    }
                                },
                                overwrite: true,
                                lazy: false
                            } });
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('domdiahabhas', {
                            enDB: false, nro_campo_tipo: 104,
                            mask: {
                                mask: 'h:m',
                                blocks: {
                                    h: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 23,
                                        maxLength: 2
                                    },
                                    m: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 59,
                                        maxLength: 2
                                    }
                                },
                                overwrite: true,
                                lazy: false
                            } });
                    </script>
                </td >
            </tr>
            <tr>
                <td class="Tit1" nowrap>Días feriados</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('domdiaferdes', {
                            enDB: false, nro_campo_tipo: 104,
                            mask: {
                                mask: 'h:m',
                                blocks: {
                                    h: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 23,
                                        maxLength: 2
                                    },
                                    m: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 59,
                                        maxLength: 2
                                    }
                                },
                                overwrite: true,
                                lazy: false
                            } });
                    </script>
                </td >
                <td>
                    <script type="text/javascript">
                        campos_defs.add('domdiaferhas', {
                            enDB: false, nro_campo_tipo: 104,
                            mask: {
                                mask: 'h:m',
                                blocks: {
                                    h: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 23,
                                        maxLength: 2
                                    },
                                    m: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 59,
                                        maxLength: 2
                                    }
                                },
                                overwrite: true,
                                lazy: false
                            } });
                    </script>
                </td >
            </tr>
            <tr>
                <td class="Tit1">Todos</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('domtoddiades', {
                            enDB: false, nro_campo_tipo: 104,
                            mask: {
                                mask: 'h:m',
                                blocks: {
                                    h: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 23,
                                        maxLength: 2
                                    },
                                    m: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 59,
                                        maxLength: 2
                                    }
                                },
                                overwrite: true,
                                lazy: false
                            } });
                    </script>
                </td >
                <td>
                    <script type="text/javascript">
                        campos_defs.add('domtoddiahas', {
                            enDB: false, nro_campo_tipo: 104,
                            mask: {
                                mask: 'h:m',
                                blocks: {
                                    h: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 23,
                                        maxLength: 2
                                    },
                                    m: {
                                        mask: IMask.MaskedRange,
                                        from: 0,
                                        to: 59,
                                        maxLength: 2
                                    }
                                },
                                overwrite: true,
                                lazy: false
                            } });
                    </script>
                </td >
            </tr>
        </table>

        <table class="tb1">
            <tr>
                <td class="Tit1">Recibe Mailing</td>
                <td nowrap>
                    <span onclick="cambiar_valor(this)" style="vertical-align: middle"><b>No</b><input id="dommai" value="0" class="slider4" style="width: 35px" type="range" min="0" max="1" disabled=""><b>Si</b></span>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Posee PC</td>
                <td nowrap>
                    <span onclick="cambiar_valor(this)" style="vertical-align: middle"><b>No</b><input id="compper" value="0" class="slider4" style="width: 35px" type="range" min="0" max="1" disabled=""><b>Si</b></span>
                </td>
            </tr>
        </table>
    </div>

    <div>
        <table class="tb1">
            <tr>
                <td></td><td></td><td class="Tit1">Número</td><td class="Tit1">Block</td><td class="Tit1">Piso</td><td class="Tit1">Depto.</td>
            </tr>
            <tr>
                <td class="Tit1">Calle</td>
                <td width="25%">
                    <script>
                        campos_defs.add('domnom', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add('domnro', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add('block', { enDB: false, nro_campo_tipo: 104, maxLength: 3 });
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add('dompiso', { enDB: false, nro_campo_tipo: 104, maxLength: 3 });
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add('domdepto', { enDB: false, nro_campo_tipo: 104, maxLength: 5 });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Barrio</td>
                <td>
                    <script>
                        campos_defs.add('barrio', { enDB: false, nro_campo_tipo: 104, maxLength: 30 });
                    </script>
                </td>
                <td class="Tit1">Manz.</td>
                <td>
                    <script>
                        campos_defs.add('manz', { enDB: false, nro_campo_tipo: 104, maxLength: 3 });
                    </script>
                </td>
                <td class="Tit1">Lote/Casa</td>
                <td>
                    <script>
                        campos_defs.add('lote', { enDB: false, nro_campo_tipo: 104, maxLength: 3 });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1" nowrap>E-Mail</td>
                <td colspan="5">
                    <span style="width:50%; float:left;">
                        <script>
                            campos_defs.add('usuario_mail', { enDB: false, nro_campo_tipo: 104, maxLength: 127 });
                        </script>
                    </span>
                    <span style="width:5%; float:left; text-align:center;">@</span>
                    <span style="width:45%; float:left;">
                        <script>
                            campos_defs.add('dominio_mail', { enDB: false, nro_campo_tipo: 104, maxLength: 127 });
                        </script>
                    </span>
                    
                </td>
            </tr>
        </table>
    </div>
                            
</body>
</html>