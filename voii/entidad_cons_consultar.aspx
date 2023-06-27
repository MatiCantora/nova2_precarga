<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    'Dim nro_entidad_get As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad_get", "0")
    'Dim nro_rol = nvUtiles.obtenerValor("nro_rol", "0")
    'Dim alta_operador As Integer = nvFW.nvUtiles.obtenerValor("alta_operador", 1)

    'Me.contents("filtroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos> " + alta_operador.ToString() + "as alta_operador, nro_entidad, apellido, nombres, 'DNI' as documento, nro_docu, sexo, tipo_docu, cuitcuil, cuit, persona_fisica, Razon_social</campos><orden>nro_entidad</orden><filtro></filtro><grupo></grupo></select></criterio>")
    Me.contents("filtroEntidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'>" +
                                                          "<campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, " +
                                                          "cliape, clinom, clisexo, clifecalt, tipocli, codprov, codprovdesc, codpos, loccoddesc, policaexpuesto, tipoempcod, tipoempdesc, tipempsoc, " +
                                                          "tipsocdesc, clicondgi, clconddgi, tiporel, tipreldesc, impgancod, impgandesc </campos>" +
                                                          "<filtro></filtro><orden>razon_social</orden></select></criterio>")

    Dim camposNV As String = "nro_entidad, tipocli, tiporel, tipdoc, tipdoc_desc, nrodoc, CUIT_CUIL, DNI, cliape, clinom, clideno, " +
"fecnac_insc, clisexo, cartel, numtel, razon_social, tipreldesc, domnom, domnro, dompiso, domdepto, codpos, loccoddesc, codprovdesc, " +
"email, clconddgi, descestciv, tipsocdesc, tipoempdesc, policaexpuesto, apenomConyuge, nacionalidad, '' AS sectorfindesc, '' AS profdesc, impgandesc, '' AS perconnom, '' AS clasidesc, '' AS desctipcar "
    Me.contents("verEntidades_compatibilidadXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades_compatibilidad_ibs'><campos>" + camposNV + "</campos><filtro></filtro></select></criterio>")

    Dim camposIBS As String = "tipocli, tiporel, tipdoc, tipdoc_desc, nrodoc, CUIT_CUIL, DNI, cliape, clinom, clideno, " +
"fecnac_insc, clisexo, cartel, numtel, razon_social, tipreldesc, domnom, domnro, dompiso, domdepto, codpos, loccoddesc, codprovdesc, " +
"email, clconddgi, descestciv, tipsocdesc, tipoempdesc, policaexpuesto, sectorfindesc, profdesc, impgandesc, perconnom, clasidesc, desctipcar "
    Me.contents("VOII_entidadesXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>" + camposIBS + "</campos><filtro></filtro></select></criterio>")

    Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo], cod_interno, cod_externo, desc_externo</campos><filtro><elemento type='igual'>'documento'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden>[campo]</orden></select></criterio>")

    'Me.contents("nro_entidad_get") = nro_entidad_get
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consulta Entidades</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var razon_social
        var Parametros = []
        var win = nvFW.getMyWindow()
        var vButtonItems = {};
        vButtonItems[0] = []
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return Aceptar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/fw/image/icons/buscar.png')

        //var alta_operador = nvFW.pageContents.alta_operador;

        function window_onload() {
            // mostramos los botones creados
            vListButtons.MostrarListButton()

            nvFW.enterToTab = false;

            var Parametros = window.dialogArguments

            set_campos_defs_onchange()

            window_onresize()
        }


        function set_campos_defs_onchange() {
            ['nro_docu', 'razon_social'].each(function (input_name) {
                campos_defs.items[input_name]['input_hidden'].onkeypress = is_enter
            })
        }


        function is_enter(event) {
            if ((event.which || event.keyCode) == 13)
                Aceptar()
        }


        function AgregarEntidad(nro_entidad, apellido, nombres, documento, nro_docu, sexo, tipo_docu) {
            var Entidad = []
            Entidad["nro_entidad"] = nro_entidad
            Entidad["apellido"] = apellido
            Entidad["nombres"] = nombres
            Entidad["documento"] = documento
            Entidad["nro_docu"] = nro_docu
            Entidad["sexo"] = sexo
            Entidad["tipo_docu"] = tipo_docu

            window.parent.win.returnValue = Entidad
            window.parent.win.close();
        }


        // Realiza la busqueda de Entidades
        function Aceptar(nro_entidad) {
            var filtro = ''

            if (nro_entidad) {
                filtro += "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"
            }
            else {
                var nro_docu = campos_defs.get_value('nro_docu')
                if (nro_docu != '') {
                    filtro += "<nrodoc type='igual'>" + nro_docu + "</nrodoc>";

                    var tipo_docu = campos_defs.get_value('tipodoc')
                    if (tipo_docu != '') {
                        //filtro += "<tipdoc type='igual'>" + tipo_docu + "</tipdoc>";
                        switch (tipo_docu) {
                            case "8":
                                if (nro_docu.toString().length == 11) {
                                    filtro = "<or><and><tipdoc type='igual'>" + tipo_docu + "</tipdoc><nrodoc type='igual'>" + nro_docu + "</nrodoc></and><CUIT_CUIL type='igual'>'" + nro_docu + "'</CUIT_CUIL></or>";
                                } else { window.top.alert('El CUIT ingresado debe tener 11 dígitos.'); return }
                                break;
                            case "5":
                                if (nro_docu.toString().length == 11) {
                                    filtro = "<or><and><tipdoc type='igual'>" + tipo_docu + "</tipdoc><nrodoc type='igual'>" + nro_docu + "</nrodoc></and><CUIT_CUIL type='igual'>'" + nro_docu + "'</CUIT_CUIL></or>";
                                } else { window.top.alert('El CUIT ingresado debe tener 11 dígitos.'); return }
                                break;
                            case "70":
                                filtro = "<tipdoc type='igual'>" + tipo_docu + "</tipdoc><nrodoc type='igual'>" + nro_docu + "</nrodoc>";
                                break;
                            case "1":
                                filtro = "<or><and><tipdoc type='igual'>" + tipo_docu + "</tipdoc><nrodoc type='igual'>" + nro_docu + "</nrodoc></and><DNI type='igual'>'" + nro_docu + "'</DNI></or>";
                                break;
                        }
                    }

                }

                if (campos_defs.get_value('razon_social') != '') {
                    filtro += "<sql type='sql'>upper(razon_social) like upper('%" + campos_defs.get_value('razon_social') + "%')</sql>";
                }
            }
                

            if (filtro == '') {
                window.top.alert('Ingrese un criterio de búsqueda')
                return;
            }

            cantFilas = Math.floor(($("iframeRes").getHeight() - 18 * 2) / 22);

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroBuscar,
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: 'report/Plantillas/HTML_buscar_entidad.xsl',
                //path_xsl: 'report\\funciones\\entidades\\HTML_entidades.xsl',
                formTarget: 'iframeRes',
                bloq_contenedor: $('iframeRes'),
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframeRes',
                cls_contenedor_msg: " ",
                bloq_msg: "Cargando..."
            })
        }


        var esIE = Prototype.Browser.IE

        var dif = esIE ? 5 : 0


        function window_onresize() {
            var body_h = $$('body')[0].getHeight()
            var divMenuEntidad_h = $('divMenuEntidad').getHeight()
            var tbFiltro_h = $('tbFiltro').getHeight()

            try {
                $('iframeRes').style.height = body_h - divMenuEntidad_h - tbFiltro_h - dif + 'px'
            }
            catch (e) { }
        }


        //function entidad_seleccionar(nro_entidad, apellido, nombres, documento, nro_docu, sexo, tipo_docu, tipo_cuitcuil, cuit, persona_fisica, razon_social) {
        //    win.options.userData.entidad = {
        //        nro_entidad: nro_entidad,
        //        apellido: apellido,
        //        nombres: nombres,
        //        documento: documento,
        //        nro_docu: nro_docu,
        //        sexo: sexo,
        //        tipo_docu: tipo_docu,
        //        tipo_cuitcuil: tipo_cuitcuil,
        //        cuit: cuit,
        //        persona_fisica: persona_fisica.toLowerCase() === 'true',
        //        razon_social: razon_social
        //    }

        //    win.close()
        //}

        function cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc) {
            var entidad;

            var rs = new tRS()
            rs.asyc = false
            rs.onComplete = function (rs) {
                if (!rs.eof()) {
                    var tipo_docu_nv
                    var tipo_docu_desc_nv
                    var rsTDoc = new tRS();
                    rsTDoc.open(nvFW.pageContents.filtro_nomenclador_documento, "", "<criterio><select><filtro><cod_externo type='igual'>" + rs.getdata("tipdoc") + "</cod_externo></filtro></select></criterio>", "", "")
                    if (rsTDoc.recordcount >= 1) {
                        tipo_docu_nv = rsTDoc.getdata('cod_interno')
                        tipo_docu_desc_nv = rsTDoc.getdata('desc_externo')

                        if (!nro_entidad) {
                            //Viene de IBS
                            //Si no está en Nova, lo creamos
                            //Si ya está en Nova obtenemos el nro de entidad
                            //En ambos casos seteo el nro_entidad

                            var rsEnv = new tRS();
                            rsEnv.open(nvFW.pageContents.filtroEntidades, "", "<criterio><select><filtro><tipo_docu type='igual'>" + tipo_docu_nv + "</tipo_docu><nro_docu type='igual'>" + rs.getdata("nrodoc") + "</nro_docu></filtro></select></criterio>", "", "")
                            if (rsEnv.recordcount == 0) {
                                nro_entidad = guardarEntidad(rs, tipo_docu_nv);
                            }
                            else {
                                nro_entidad = rsEnv.getdata("nro_entidad")
                            }
                        }

                        entidad = {
                            nro_entidad: nro_entidad,
                            apellido: rs.getdata("cliape"),
                            nombres: rs.getdata("clinom"),
                            documento: tipo_docu_desc_nv,
                            nro_docu: rs.getdata("nrodoc"),
                            sexo: rs.getdata("clisexo"),
                            tipo_docu: tipo_docu_nv,
                            tipo_cuitcuil: rs.getdata("tipocli") == "1" ? 'CUIL' : 'CUIT',
                            cuit: rs.getdata("CUIT_CUIL"),
                            persona_fisica: rs.getdata("tipocli") == "1",
                            razon_social: rs.getdata("razon_social")
                        };
                    }
                }
            }

            if (nro_entidad) 
                rs.open(nvFW.pageContents.verEntidades_compatibilidadXML, "", "<criterio><select><filtro><nro_entidad type='igual'>'" + nro_entidad + "'</nro_entidad></filtro></select></criterio>", "", "")
            else
                rs.open(nvFW.pageContents.VOII_entidadesXML, "", "<criterio><select><filtro><tipdoc type='igual'>" + tipdoc + "</tipdoc><nrodoc type='igual'>" + nrodoc + "</nrodoc></filtro></select></criterio>", "", "")

            if (!entidad) {
                alert("No se pudo cargar la entidad.");
                return;
            }

            win.options.userData.entidad = entidad

            win.close()
        }

        function guardarEntidad(rs, tipo_docu_nv) {
            var nro_entidad_nueva

            var razon_social = '<![CDATA[' + rs.getdata("razon_social") + ']]>'
            var abreviacion = '<![CDATA[' + rs.getdata("razon_social") + ']]>'
            var apellido = '<![CDATA[' + rs.getdata("cliape") + ']]>'
            var nombres = '<![CDATA[' + rs.getdata("clinom") + ']]>'
            var alias = rs.getdata("clideno") ? '<![CDATA[' + rs.getdata("clideno") + ']]>' : ''
            var calle = '<![CDATA[' + rs.getdata("domnom") + ']]>'
            var email = email ? '<![CDATA[' + rs.getdata("email") + ']]>' : ''
            var esPersona_fisica = rs.getdata("tipocli") == "1"


            var xmldato = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            xmldato += "<pago_entidad modo='AC' nro_entidad='' "
            //            xmldato += "postal='" + rs.getdata("codpos") + "' "
            if (rs.getdata("cartel"))
                xmldato += "postal_telefono='" + rs.getdata("cartel") + "' "
            if (rs.getdata("numtel"))
                xmldato += "telefono='" + rs.getdata("numtel") + "' "
            xmldato += "cuit='" + rs.getdata("CUIT_CUIL") + "' "
            //if (rs.getdata("CUIT_CUIL") != '')
            //    xmldato += "cuitcuil='" + rs.getdata("CUIT_CUIL") + "' ";
            xmldato += "cuitcuil='" + (esPersona_fisica ? 'CUIL' : 'CUIT') + "' "
            //                        else xmldato += "cuitcuil='' "

            xmldato += "numero='" + rs.getdata("domnro") + "' nro_contacto_tipo='1' resto='' "
            if (rs.getdata("dompiso"))
                xmldato += "piso='" + rs.getdata("dompiso") + "' "
            if (rs.getdata("domdepto"))
                xmldato += "depto='" + rs.getdata("domdepto") + "' "
            //xmldato += "cod_sit_iva='" + clconddgi + "' cod_ing_brutos='" + $cod_ing_brutos.value + "' "

            if (rs.getdata("policaexpuesto") == 1)
                xmldato += "pep='1' "
            else
                xmldato += "pep='0' "

            var fecnac_insc = rs.getdata("fecnac_insc") == undefined ? '' : FechaToSTR(parseFecha(rs.getdata("fecnac_insc")));

            if (esPersona_fisica) {

                xmldato += "nro_docu='" + rs.getdata("nrodoc") + "' tipo_docu='" + tipo_docu_nv + "' sexo='" + rs.getdata("clisexo") + "' persona_fisica='1' "
                xmldato += "dni='" + rs.getdata("DNI") + "' nro_emp_tipo='' nro_soc_tipo='' "
                xmldato += "fecha_nacimiento='" + fecnac_insc + "' fecha_inscripcion='' " //estado_civil='" + rs.getdata("descestciv") + "' nro_nacion='" + $nro_nacion.value + "' "
                //xmldato += "nro_docu_c='" + $('nro_docu_c').value + "' tipo_docu_c='" + $('tipo_docu_c').value + "' "
            }
            else {

                xmldato += "nro_docu='" + rs.getdata("nrodoc") + "' tipo_docu='" + tipo_docu_nv + "' sexo='' persona_fisica='0' "
                xmldato += "dni='' nro_emp_tipo='' nro_soc_tipo='' "
                xmldato += "fecha_nacimiento='' fecha_inscripcion='" + fecnac_insc + "' estado_civil='' nro_nacion='' "
                //xmldato += "nro_docu_c='' tipo_docu_c='' "

            }

            xmldato += ">"

            if (esPersona_fisica) {
                xmldato += "<apellido>" + apellido + "</apellido>"
                xmldato += "<nombres>" + nombres + "</nombres>"
            }
            else {
                xmldato += "<apellido></apellido>"
                xmldato += "<nombres></nombres>"
            }

            xmldato += "<razon_social>" + razon_social + "</razon_social>"
            xmldato += "<abreviacion>" + abreviacion + "</abreviacion>"
            xmldato += "<alias>" + alias + "</alias>"
            xmldato += "<calle>" + calle + "</calle>"
            xmldato += "<email>" + email + "</email>"
            xmldato += "</pago_entidad>"

            nvFW.error_ajax_request('cargar_cliente.aspx', {
                asynchronous: false, //Necesitamos el mro_entidad para poder corgar la página
                parameters: {
                    strXML: xmldato
                },
                onSuccess: function (err, transport) {
                    nro_entidad_nueva = err.params['nro_entidad']

                },
                onFailure: function (err) {
                    if (typeof err == 'object') {
                        alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                    }
                },
                error_alert: false,
                bloq_msg: "Cargando..."
            });

            return nro_entidad_nueva;
        }


        var win_abm_entidad

        // Llama la modal para editar las Entidades
        function nueva_entidad() {
            win_abm_entidad = window.top.nvFW.createWindow({
                url:         '/FW/entidades/entidad_abm.aspx?nro_rol=0&nro_entidad=',
                title: '<b>ABM Entidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                width: 900,
                height: 420,
                resizable: true,
                onClose: entidad_abm_onclose
            })

            win_abm_entidad.showCenter(true)
        }


        function entidad_abm(nro_entidad) {
            if (nro_entidad != '') {
                var win_entidad_abm = window.top.nvFW.createWindow({
                    url: '/FW/entidades/entidad_abm.aspx?nro_entidad=' + nro_entidad,
                    title: '<b>Entidad ABM</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    width: 1024,
                    height: 480,
                    resizable: true,
                    destroyOnClose: true,
                    onClose: entidad_abm_onclose
                })

                win_entidad_abm.options.userData = { recargar: false }
                win_entidad_abm.showCenter(true)
            }
        }


        function entidad_abm_onclose(win) {
            if (win.options.userData.recargar) {
                //return Aceptar((nvFW.pageContents.nro_entidad_get != 0 ? nvFW.pageContents.nro_entidad_get : undefined))
                return Aceptar(win.returnValue['nro_entidad']);
            }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <form name="frmFiltro_entidad" id="frmFiltro_entidad" style="width: 100%; height: 100%; overflow: hidden; margin: 0;" autocomplete="off">
        <div id="divMenuEntidad"></div>
        <%--<script type="text/javascript">
            var vMenuEntidad = new tMenu('divMenuEntidad', 'vMenuEntidad');
            Menus["vMenuEntidad"] = vMenuEntidad
            Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/icons/persona_alta.png')
            //Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/icons/entidad.png')
            //Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/icons/user.png')
            //Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/icons/socio.png')
            //Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/icons/nueva.png')
            Menus["vMenuEntidad"].alineacion = 'centro';
            Menus["vMenuEntidad"].estilo = 'A';
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_entidad()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuEntidad.MostrarMenu()
        </script>--%>

        <table class="tb1" id="tbFiltro" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width: 90%;">
                    <table id="tbFisica" class="tb1">
                        <tr class="tblabel">
                            <td style="width: 15%; text-align: center;">Tipo Doc.</td>
                            <td style="width: 25%; text-align: center;">Documento</td>
                            <td style="width: 40%; text-align: center;">Apellido y Nombres/Razón Social</td>
                        </tr>
                        <tr>
                            <td>
                                <script>
                                    campos_defs.add('tipodoc', {
                                        enDB: false,
                                        filtroXML: nvFW.pageContents.filtro_nomenclador_documento,
                                        nro_campo_tipo: 1
                                    });
                            </script>
                            </td>
                            <td>
                                <% = nvCampo_def.get_html_input("nro_docu", enDB:=False, nro_campo_tipo:=100) %>
                            </td>
                            <td>
                                <% = nvCampo_def.get_html_input("razon_social", enDB:=False, nro_campo_tipo:=104) %>
                            </td>
                        </tr>
                    </table>
                </td>
                <td>
                    <div id="divBuscar" style="width: 100%;"></div>
                </td>
            </tr>
        </table>

        <iframe name="iframeRes" id="iframeRes" style="width: 100%; height: 100%; overflow: hidden; border: none;" src="/fw/enBlanco.htm"></iframe>
    </form>
</body>
</html>
