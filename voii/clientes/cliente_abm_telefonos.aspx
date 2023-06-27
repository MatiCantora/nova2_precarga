<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim tipdoc As Integer = nvFW.nvUtiles.obtenerValor("tipdoc", 0)
    Dim nrodoc As Long = nvFW.nvUtiles.obtenerValor("nrodoc", 0)


    If tipdoc > 0 And nrodoc > 0 Then
        'Dim op = nvFW.nvApp.getInstance.operador
        'If (Not op.tienePermiso("permisos_entidades", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx?No posee permisos para ver las entidades.")

        Dim campos_tcl As String = "paiscod, bcocod, succod, tipdoc, nrodoc, domcod, " +
            "cartel, numtel, particular, descripcion"
        Me.contents("telXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tcl_telefonos' cn='BD_IBS_ANEXA'><campos>" + campos_tcl + "</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden>cartel ASC</orden></select></criterio>")

        Me.contents("domXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tcl_Domicilio' cn='BD_IBS_ANEXA'><campos>domcod as id, tipdomcod, domnom as [campo], domnro, paiscod, bcocod, succod, tipdoc, nrodoc</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden>[campo]</orden></select></criterio>")

        Me.contents("tipotelXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..trgl_tipotelefono' cn='BD_IBS_ANEXA'><campos>tipotelcod as id, teldesc as [campo], (CASE WHEN estado = 0 THEN 1 ELSE 0 END) as allowSelection</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

        Me.contents("tipdoc") = tipdoc
        Me.contents("nrodoc") = nrodoc

    End If
    'Me.addPermisoGrupo("permisos_vinculos")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Cliente Domicilios</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        .pac-container.pac-logo::after {
            content: none;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        

        var winEntidad = nvFW.getMyWindow()

        var _actionTel = "A"

        function loadButtons() {
            var vButtonItems = {};
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Mostrar";
            vButtonItems[0]["etiqueta"] = "Mostrar";
            vButtonItems[0]["imagen"] = "mostrar";
            vButtonItems[0]["onclick"] = "return mostrarTel()";

            vButtonItems[1] = {};
            vButtonItems[1]["nombre"] = "Nuevo";
            vButtonItems[1]["etiqueta"] = "Nuevo";
            vButtonItems[1]["imagen"] = "nuevo";
            vButtonItems[1]["onclick"] = "return nuevoTel()";

            vButtonItems[2] = {};
            vButtonItems[2]["nombre"] = "Borrar";
            vButtonItems[2]["etiqueta"] = "Borrar";
            vButtonItems[2]["imagen"] = "eliminar";
            vButtonItems[2]["onclick"] = "return eliminarTel()";

            vButtonItems[3] = {};
            vButtonItems[3]["nombre"] = "Guardar";
            vButtonItems[3]["etiqueta"] = "Guardar";
            vButtonItems[3]["imagen"] = "guardar";
            vButtonItems[3]["onclick"] = "return guardarTel()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("mostrar", '/FW/image/icons/ver.png')
            vListButton.loadImage("nuevo", '/FW/image/icons/agregar.png')
            vListButton.loadImage("eliminar", '/FW/image/icons/eliminar.png');
            vListButton.loadImage("guardar", '/FW/image/icons/guardar.png')
            vListButton.MostrarListButton()

        }

        function window_onload() {

            CargarDatos()

            loadButtons();
            window_onresize();
        }


        function window_onresize() {
            try {
                

            }
            catch (e) { }
        }



        var telList
        function CargarDatos(domcod) {

            telList = []
            $('telListBody').innerHTML = "";

            if (nvFW.pageContents == undefined || nvFW.pageContents.tipdoc == undefined || nvFW.pageContents.nrodoc == undefined) return;

            var rs = new tRS();
            rs.async = true;

            rs.onComplete = function (res) {

                while (!res.eof()) {
                    var tel = {
                        paiscod: res.getdata("paiscod"),
                        bcocod: res.getdata("bcocod"),
                        succod: res.getdata("succod"),
                        tipdoc: res.getdata("tipdoc"),
                        nrodoc: res.getdata("nrodoc"),
                        domcod: res.getdata("domcod"),
                        cartel: res.getdata("cartel"),
                        numtel: res.getdata("numtel"),
                        particular: res.getdata("particular"),
                        descripcion: res.getdata("descripcion")
                    }


                    var fila = '<tr onclick="seleccionarTel(' + telList.length + ')" style="cursor: pointer;">' +
                        '<td width="5px"><input type="radio" name="telRadio" id="radio' + telList.length + '" data-index="' + telList.length + '" style="cursor: pointer;" title="Seleccionar"></td>' +
                        '<td nowrap>' + tel.cartel + '</td>' +
                        '<td nowrap>' + tel.numtel + '</td>' +
                        '<td nowrap>' + tel.particular + '</td>' +
                        '<td nowrap>' + tel.descripcion + '</td>' +
                        '</tr >';
                    $$('#telListBody')[0].insert(fila);

                    telList.push(tel);

                    res.movenext()
                }
                nvFW.bloqueo_desactivar($$('body')[0], 'bloq_domicilios')
            }

            rs.onError = function (res) {
                nvFW.bloqueo_desactivar($$('body')[0], 'bloq_domicilios')
                alert(res.lastError.numError + ' - ' + res.lastError.mensaje);
            }

            nvFW.bloqueo_activar($$('body')[0], 'bloq_domicilios', 'Cargando domicilios de cliente...')

            //rs.open(nvFW.pageContents.telXML);
            if (domcod != undefined)
                rs.open(nvFW.pageContents.telXML, "", "<domcod type='igual'>" + domcod + "</domcod>");
            else
                rs.open(nvFW.pageContents.telXML);
        }

        function domicilioChange() {
            var domCodSelected = campos_defs.get_value("domicilio")
            if (domCodSelected == "")
                domCodSelected = undefined;

            CargarDatos(domCodSelected)
        }


        function seleccionarTel(fila) {
            //limpiarCampos()
            $$("#radio" + fila)[0].checked = true;
        }

        function getTelefonoSeleccionado() {
            var rSelected = $$("#telListBody input[type=radio]:checked")[0]
            if (rSelected == undefined) {
                return undefined;
            }

            var telSelected = telList[rSelected.dataset.index]

            return telSelected;
        }

        function limpiarCampos() {
            _actionTel = "A"

            campos_defs.set_value("cartel", "")
            campos_defs.set_value("particular", "")
            campos_defs.set_value("numtel", "")
            campos_defs.set_value("descripcion", "")
        }


        function mostrarTel() {
            limpiarCampos()
            _actionTel = "M"

            var telSelected = getTelefonoSeleccionado()
            if (telSelected == undefined) {
                alert("Seleccione un teléfono")
                return;
            }

            campos_defs.set_value("cartel", telSelected.cartel)
            campos_defs.set_value("numtel", telSelected.numtel)
            campos_defs.set_value("particular", telSelected.particular)
            campos_defs.set_value("descripcion", telSelected.descripcion)
            
        }

        function nuevoTel() {
            limpiarCampos()
            _actionTel = "A"

            var rSelected = $$("#telListBody input[type=radio]:checked")[0]
            if (rSelected != undefined)
                rSelected.checked = false

        }

        function eliminarTel() {

            var telSelected = getTelefonoSeleccionado()
            if (telSelected == undefined) {
                alert("Seleccione un teléfono")
                return;
            }

            var datos = {};

            datos["domcod"] = parseInt(telSelected.domcod, 10)

            datos["action"] = "B";
            datos["paiscod"] = 54;
            datos["bcocod"] = 312;
            datos["succod"] = parseInt(telSelected.succod, 10);//1;
            datos["tipdoc"] = parseInt(telSelected.tipdoc, 10);// parent.campos_defs.get_value("tipdoc");//8;
            datos["nrodoc"] = parseInt(telSelected.nrodoc, 10);//20259040329;
            datos["confirmar_cambios"] = true
            datos["ef"] = ""

            nvFW.error_ajax_request('/voii/ibs/cliente/telefono/scl_dtcl_telefono.aspx', {
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


        function guardarTel() {

            var datos = {};

            var urlAction

            if (_actionTel == "A") {
                urlAction = '/voii/ibs/cliente/telefono/scl_itcl_telefono.aspx'

                if (campos_defs.value("domicilio") == "") {
                    alert("No seleccionó un domicilio.")
                    return
                }
                datos["domcod"] = parseInt(campos_defs.value("domicilio"), 10)
                datos["succod"] = parent._succod //TODO obtenerlo del domicilio?
            }
            if (_actionTel == "M") {
                urlAction = '/voii/ibs/cliente/telefono/scl_utcl_telefono.aspx'

                var telSelected = getTelefonoSeleccionado()
                datos["domcod"] = parseInt(telSelected.domcod, 10)
                datos["succod"] = parseInt(telSelected.succod, 10)
            }

            if (urlAction == undefined)
                return;

            if (campos_defs.get_value("cartel") == "") {
                alert("Ingrese la caracteristica.")
                return
            }
            if (campos_defs.get_value("numtel") == "") {
                alert("Ingrese el número.")
                return
            }
            if (campos_defs.get_value("particular") == "") {
                alert("Seleccione el tipo de teléfono.")
                return
            }


            datos["paiscod"] = parent._paiscod;// 54;
            datos["bcocod"] = parent._bcocod;//312;
            
            datos["cartel"] = campos_defs.get_value("cartel")
            datos["numtel"] = campos_defs.get_value("numtel")
            datos["particular"] = parseInt(campos_defs.get_value("particular"), 10)
            datos["descripcion"] = campos_defs.get_value("descripcion")
                        // //

            datos["action"] = _actionTel;
            
            //datos["succod"] = parent._succod;//TODO: tomarlo del domicilio seleccionado $$("#esglobal")[0].checked ? 0 : 1;//1;
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

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
    <table class="tb1">
        <tr>
            <td class="Tit1">Domicilio</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('domicilio', {
                        enDB: false,
                        nro_campo_tipo: 1,
                        filtroXML: nvFW.pageContents.domXML,
                        onchange: domicilioChange
                    });
                </script>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr class="tbLabel">
            <td>Teléfonos</td>
        </tr>
    </table>
    <div style="width: 80%; float:left;">
        <table class="tb1 highlightOdd highlightTROver">
            <thead>
                <tr class="tbLabel">
                    <td style="width: 5px; text-align: center;"></td>
                    <td style="text-align: center;">Caract</td>
                    <td style="text-align: center;">Número</td>
                    <td style="text-align: center;">Tipo</td>
                    <td style="text-align: center;">Descripción</td>
                </tr>
            </thead>
            <tbody id="telListBody">
                
            </tbody>
        
        </table>
    </div>
    <div style="width: 20%; float:left;">
        <div id="divDomicilioAcciones"></div>
        <div id="divMostrar">
        </div>
        <div id="divNuevo">
        </div>
        <div id="divBorrar">
        </div>
        <div id="divGuardar">
        </div>
    </div>
    
             
    <table class="tb1">
        <tr class="tbLabel">
            <td>Datos del teléfono</td>
        </tr>
    </table>

    <div style="width: 100%; float:left;">
        <table class="tb1">
            <tr>
                <td class="Tit1">Característica</td>
                <td>
                    <script>
                        campos_defs.add('cartel', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
                <td class="Tit1">Número</td>
                <td>
                    <script>
                        campos_defs.add('numtel', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td class="Tit1">Tipo</td>
           
                <td>
                    <script type="text/javascript">
                        campos_defs.add('particular', {
                            enDB: false,
                            nro_campo_tipo: 1,
                            filtroXML: nvFW.pageContents.tipotelXML
                        });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Descripción</td>
                <td>
                    <script>
                        campos_defs.add('descripcion', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
            
        </table>
    </div>
                            
                            
</body>
</html>
