<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim abrir_como_abm As Integer = nvFW.nvUtiles.obtenerValor("open_abm", 0)

    ' Valores para setear la lista de tipos
    Dim item_padre As Integer = nvFW.nvUtiles.obtenerValor("id_padre", -1) ' id para seleccionar el radio
    Dim item_hijo As Integer = nvFW.nvUtiles.obtenerValor("id_hijo", -1) ' id para deshabilitar el radio (evitar recursividad sobre si mismo)

    Dim abrir_abm As Boolean = IIf(abrir_como_abm = 1, True, False)

    Me.contents("abrir_abm") = abrir_abm
    Me.contents("filtro_tipos_ordenados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCf_tipos'><campos>*</campos><orden>level_orden</orden></select></criterio>")
 %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Lista tipos de conceptos financieros</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <style type="text/css">
        p { margin: 0 0 2px; padding: 4px 0 4px 4px; }
        p:hover { background-color: #DFD6E0; }
        input[type=radio]:hover, label:hover, .nuevo_dependiente:hover { cursor:pointer; }
        .raiz { background: #EAEAEA; }
        #acciones { position:absolute; bottom: 0; width: 100%; text-align:center; }
        #btnSeleccionar, #btnAgregarTipo {
            background-repeat: no-repeat;
            background-position: 2px;
            width: 105px;
            height: 22px;
            text-align: right;
            margin-top: 2px;
        }
        #btnSeleccionar { background-image: url(/fw/image/icons/seleccionar.png); }
        #btnAgregarTipo, .nuevo_dependiente { background-image: url(/fw/image/icons/agregar.png); vertical-align:bottom; }
        #btnSeleccionar:hover, #btnAgregarTipo:hover { border-color: #b0b0b0; cursor: pointer; }
        .eliminar, .editar, .level-up, .level-down {
            background-image: url(/fw/image/icons/eliminar.png);
            background-repeat: no-repeat;
            width: 15px;
            height: 16px;
            float: right;
            margin-right: 0.5em;
        }
        .level-up, .level-down {
            float: left;
        }
        .editar { background-image: url(/fw/image/icons/editar.png); }
        .eliminar { background-image: url(/fw/image/icons/eliminar.png); }
        .level-up { background-image: url(/fw/image/icons/up_a.png); width: 10px; vertical-align:bottom; }
        .level-down { background-image: url(/fw/image/icons/down_a.png); width: 10px; vertical-align:bottom; }
        .eliminar:hover, .editar:hover, .level-up:hover, .level-down:hover { cursor: pointer; }
        .nuevo_dependiente {
            display: inline-block;
            width: 16px;
            height: 16px;
            margin-left: 10px;
            vertical-align:bottom;
        }
    </style>

    <%= Me.getHeadInit() %>
    
    <script type="text/javascript">
        var tipo_id = null,
            tipo_desc = null,
            abm = nvFW.pageContents.abrir_abm,
            id_padre = <%= item_padre %>,
            id_hijo = <%= item_hijo %>

        function window_onload() {
            // borrar valores de variables de ventana parent
            parent.tipo_id = null
            parent.tipo_desc = null

            cargar_arbol()

            window_onresize()
        }

        function window_onresize() {
            var h_body = $$("BODY")[0].getHeight(),
                h_menu = $("divMenu").getHeight(),
                arbol = $("arbol")
                
            arbol.setStyle({ height: h_body - h_menu })
        }

        function cargar_arbol() {
            var rs = new tRS()

            rs.onComplete = function (result) {
                if (result.lastError.numError == 0) {
                    var datos = ""

                    // Armar el ABM
                    if (abm) {
                        while (!result.eof()) {
                            var id = result.getdata("cf_tipo_id"),
                                valor = result.getdata("cf_tipo"),
                                nivel = result.getdata("level"),
                                es_raiz = nivel == 0 ? true : false,
                                padding_left = 10 + nivel * 20,
                                depende_de_orden = result.getdata("sub_orden") != null ? result.getdata("sub_orden") : ''

                            if (es_raiz)
                                datos += "<p id='" + id + "' class='raiz' data-nivel='" + nivel + "' data-orden='" + result.getdata("sub_orden") + "' style='padding-left: 10px;'>" +
                                            "<span style='display:inline-block;width:35px;'>" +
                                                "<span title='Bajar nivel raiz' onclick='bajar_nivel(" + id + ", " + depende_de_orden + ", true)' class='level-down'></span>" +
                                                " <span title='Subir nivel raiz' onclick='subir_nivel(" + id + ", " + depende_de_orden + ", true)' class='level-up'></span>" +
                                            "</span>"
                            else {
                                datos += "<p id='" + id + "' class='hijo' data-nivel='" + nivel + "' style='padding-left: " + padding_left + "px;'>" +
                                            "<span style='display:inline-block;width:35px;'>" +
                                                "<span title='Bajar nivel' onclick='bajar_nivel(" + id + ", " + depende_de_orden + ")' class='level-down'></span>" +
                                                " <span title='Subir nivel' onclick='subir_nivel(" + id + ", " + depende_de_orden + ")' class='level-up'></span>" +
                                            "</span>"
                            }

                            datos += valor +
                                     "<span class='nuevo_dependiente' title='Agregar dependiente de " + valor + "' onclick='agregar_tipo(" + id + ")'></span>" +
                                     "<span title='Eliminar " + valor + "' onclick='eliminar_tipo(" + id + ", \"" + valor + "\")' class='eliminar'></span>" +
                                     "<span title='Editar " + valor + "' onclick='editar_tipo(" + id + (!es_raiz ? ", " + depende_de_orden : "") + ")' class='editar'></span>"

                            datos += "</p>"

                            result.movenext()
                        }
                    }
                    // Selector de radios simple
                    else {
                        while (!result.eof()) {
                            var padding_left = 10,
                                id = result.getdata("cf_tipo_id"),
                                valor = result.getdata("cf_tipo"),
                                es_raiz = result.getdata("level") == 0 ? true : false

                            for (var i = 0, cant = result.getdata("level_orden").length; i < cant; i++)
                                padding_left += i * 10

                            datos += "<p class='" + (es_raiz ? 'raiz' : '') + "' style='padding-left: " + padding_left + "px'>"

                            if (id != id_padre && id != id_hijo)
                                datos += "<input type='radio' name='cf_tipo' value='" + id + "' id='" + id + "' onchange='obtener_valores_radio(this)' data-valor='" + valor + "' />"
                            else if (id == id_padre)
                                datos += "<input type='radio' name='cf_tipo' value='" + id + "' id='" + id + "' onchange='obtener_valores_radio(this)' data-valor='" + valor + "' checked='checked' />"
                            else if (id == id_hijo)
                                datos += "<input type='radio' name='cf_tipo' value='" + id + "' id='" + id + "' onchange='obtener_valores_radio(this)' data-valor='" + valor + "' disabled='true' />"

                            datos += "<label for='" + id + "'>" + valor + " (" + id + ")</label>" +
                                     "</p>"

                            result.movenext()
                        }
                    }

                    $("arbol").innerHTML = datos

                    // Revisar todos los radiobuttons y setear correctamente las flechas de subir/bajar, solo en ABM
                    if (abm)
                        checkear_subir_bajar()
                }
            }

            rs.onError = function (result) {
                alert(result.lastError.numError + ": " + result.lastError.mensaje)
            }

            rs.open({ filtroXML: nvFW.pageContents.filtro_tipos_ordenados })
        }


        function obtener_valores_radio(ele) {
            tipo_id = ele.id,
            tipo_desc = ele.dataset.valor
        }

        // Esta funcion toma el ID y Value que tenga el elemento y lo almacena en el window parent para su uso
        function seleccionar() {
            if (tipo_id == null || tipo_desc == null)
                return

            parent.tipo_id = tipo_id
            parent.tipo_desc = tipo_desc

            parent.winTipo.close()
        }

        // ALTA
        function agregar_tipo(id) {
            parent.winNuevo = parent.nvFW.createWindow({
                url: "/wiki/cf_tipos_agregar.aspx" + (id != null ? "?parent_id=" + id : ""),
                title: "<b>Nuevo Tipo CF</b>",
                width: 400,
                height: 80,
                destroyOnClose: true,
                minimizable: true,
                maximizable: true,
                onClose: function () {
                    cargar_arbol()
                }
            })

            parent.winNuevo.showCenter(true)
        }

        // BAJA
        function eliminar_tipo(id, valor) {
            var dialog = parent.nvFW.confirm("¿Está seguro que desea eliminar el tipo \"<b>" + valor + "</b>\"?", {
                title: "Eliminar",
                height: 80,
                onOk: function () {
                    // Busco el parent para asignar la dependencia
                    var depende_de = -1,
                        p = $(id + ""),
                        continuar = true,
                        xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"

                    while (continuar) {
                        if (p.previous() == null) {
                            continuar = false
                        }
                        else {
                            if (p.previous().readAttribute("data-nivel") == p.readAttribute("data-nivel")) {
                                p = p.previous()
                            }
                            else {
                                continuar = false
                                depende_de = p.previous().id
                            }
                        }
                    }

                    xmldato += "<tipo cf_tipo_id='" + (id * -1) + "' cf_tipo='' depende_de='" + depende_de + "'></tipo>"

                    nvFW.error_ajax_request("cf_tipos_agregar.aspx", {
                        parameters: { strXML: xmldato },
                        onSuccess: function (er) {
                            cargar_arbol()
                            dialog.close() // cerrar la ventana de dialogo
                        },
                        error_alert: true,
                        bloq_contenedor_on: true
                    })
                    return
                },
                onCancel: function () {
                    return
                }
            })
        }

        // MODIFICACION
        function editar_tipo(id, depende_de_orden) {
            depende_de_orden = depende_de_orden || -1

            parent.winEditar = parent.nvFW.createWindow({
                url: "/wiki/cf_tipos_agregar.aspx?cf_tipo_id=" + id + "&depende_de_orden=" + depende_de_orden,
                title: "<b>Editar Tipo CF</b>",
                width: 400,
                height: 80,
                destroyOnClose: true,
                minimizable: true,
                maximizable: true,
                onClose: function() {
                    cargar_arbol()
                }
            })

            parent.winEditar.showCenter(true)
        }

        // Modificar orden en niveles
        function subir_nivel(id, depende_de_orden, raiz) {
            var depende_de = -1,
                elemento = $(id + ""),
                anterior = (raiz ? elemento.previous("p.raiz") : elemento.previous()),
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"

            if (elemento.hasClassName("hijo"))
                depende_de = elemento.previous(".raiz").id

            xmldato += "<tipo cf_tipo_id='" + id + "' cf_tipo='" + elemento.innerText + "' depende_de='" + depende_de + "' depende_de_orden='" + (depende_de_orden - 1) + "'></tipo>"

            nvFW.error_ajax_request("cf_tipos_agregar.aspx", {
                parameters: { strXML: xmldato },
                onSuccess: function (er) {
                    // actualizar dependencia de orden del item anterior
                    xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>" +
                                "<tipo cf_tipo_id='" + $(anterior).id + "' cf_tipo='" + $(anterior).innerText + "' depende_de='" + depende_de + "' depende_de_orden='" + depende_de_orden + "'></tipo>"

                    nvFW.error_ajax_request("cf_tipos_agregar.aspx", {
                        parameters: { strXML: xmldato },
                        onSuccess: function (er) {
                            cargar_arbol()
                        },
                        error_alert: true,
                        bloq_contenedor_on: true
                    })

                },
                error_alert: true,
                bloq_contenedor_on: true
            })
        }

        function bajar_nivel(id, depende_de_orden, raiz) {
            var depende_de = -1,
                elemento = $(id + ""),
                siguiente = (raiz ? elemento.next("p.raiz") : elemento.next()),
                xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"

            if (elemento.hasClassName("hijo"))
                depende_de = elemento.previous(".raiz").id

            xmldato += "<tipo cf_tipo_id='" + id + "' cf_tipo='" + elemento.innerText + "' depende_de='" + depende_de + "' depende_de_orden='" + (depende_de_orden + 1) + "'></tipo>"

            nvFW.error_ajax_request("cf_tipos_agregar.aspx", {
                parameters: { strXML: xmldato },
                onSuccess: function (er) {
                    // actualizar dependencia de orden del item anterior
                    xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>" +
                                "<tipo cf_tipo_id='" + $(siguiente).id + "' cf_tipo='" + $(siguiente).innerText + "' depende_de='" + depende_de + "' depende_de_orden='" + depende_de_orden + "'></tipo>"

                    nvFW.error_ajax_request("cf_tipos_agregar.aspx", {
                        parameters: { strXML: xmldato },
                        onSuccess: function (er) {
                            cargar_arbol()
                        },
                        error_alert: true,
                        bloq_contenedor_on: true
                    })

                },
                error_alert: true,
                bloq_contenedor_on: true
            })
        }

        // Mostrar / ocultar flechas de Subir - Bajar nivel
        function checkear_subir_bajar() {
            // chequear flechas en raices
            checkear_subir_bajar_raices()

            var p = $$("p"),
                nivel = -1

            for (var i = 0, n = p.length; i < n; i++) {
                nivel = p[i].readAttribute("data-nivel")

                if (nivel != "0") {
                    if (p[i].previous().readAttribute("data-nivel") != nivel) {
                        $(p[i]).select("span.level-up")[0].setStyle({ "display": "none" })
                    }

                    if (p[i].next() != null) {
                        if (p[i].next().readAttribute("data-nivel") != nivel) {
                            $(p[i]).select("span.level-down")[0].setStyle({ "display": "none" })
                        }
                    }
                    else {
                        $(p[i]).select("span.level-down")[0].setStyle({ "display": "none" })
                    }
                }
            }
        }

        function checkear_subir_bajar_raices() {
            var p = $$("p.raiz"),
                n = p.length

            p[0].select("span.level-up")[0].setStyle({ "display": "none" })
            p[n - 1].select("span.level-down")[0].setStyle({ "display": "none" })
        }
    </script>
</head>

<body onload="window_onload()" onresize="window_onresize()" style="background: white; width:100%; height:100%; overflow:hidden">
    <div id="divMenu" style="width:100%;"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');
        
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        if (abm) {
            vMenu.loadImage("nuevo", "/FW/image/icons/agregar.png");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo Tipo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_tipo()</Codigo></Ejecutar></Acciones></MenuItem>")
        }
        else {
            vMenu.loadImage("seleccionar", "/FW/image/icons/tilde.png");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>seleccionar</icono><Desc>Seleccionar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>seleccionar()</Codigo></Ejecutar></Acciones></MenuItem>")
        }

        vMenu.MostrarMenu();
    </script>
    <div id="arbol" style="overflow-y: auto;"></div>
</body>
</html>
