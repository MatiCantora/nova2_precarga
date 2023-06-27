<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    Dim nro_entidad_get As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad_get", "0")
    Dim nro_rol = nvUtiles.obtenerValor("nro_rol", "0")
    Dim alta_operador As Integer = nvFW.nvUtiles.obtenerValor("alta_operador", 1)

    Me.contents("filtroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos> " + alta_operador.ToString() + "as alta_operador, nro_entidad, apellido, nombres, 'DNI' as documento, nro_docu, sexo, tipo_docu, cuitcuil, cuit, persona_fisica, Razon_social</campos><orden>nro_entidad</orden><filtro></filtro><grupo></grupo></select></criterio>")
    Me.contents("nro_entidad_get") = nro_entidad_get

    'Consulta de entidades para vínculos
    Me.contents("entidad_consultar") = nvFW.nvUtiles.obtenerValor("entidad_consultar", "")
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

        var alta_operador = nvFW.pageContents.alta_operador;

        function window_onload() {
            // mostramos los botones creados
            vListButtons.MostrarListButton()

            nvFW.enterToTab = false;

            var Parametros = window.dialogArguments

            if (win.options.userData == null)
                win.options.userData = {};

            // si se paso un nro_entidad por GET, cargar solo esa entidad
            if (nvFW.pageContents.nro_entidad_get != 0) {
                Aceptar(nvFW.pageContents.nro_entidad_get)
            }

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
        function Aceptar(nro_entidad_get) {
            var filtro = ''
            var tipo_persona = ''

            if (nro_entidad_get != undefined) {
                filtro = "<nro_entidad type='igual'>" + nro_entidad_get + "</nro_entidad>"
            }
            else {

                if (campos_defs.get_value('nro_docu') != '') {
                    filtro += "<nro_docu type='igual'>'" + campos_defs.get_value('nro_docu') + "'</nro_docu>"
                }

                if (campos_defs.get_value('tipo_docu') != '') {
                    filtro += "<tipo_docu type='igual'>'" + campos_defs.get_value('tipo_docu') + "'</tipo_docu>"
                }

                if (campos_defs.get_value('razon_social') != '') {
                    filtro += "<Razon_social type='like'>%" + campos_defs.get_value('razon_social') + "%</Razon_social>"
                }


                if ($('select_tipo_persona').value != '')
                    filtro += '<persona_fisica type="igual">' + $('select_tipo_persona').value + '</persona_fisica>'

            }


            cantFilas = Math.floor(($("iframeRes").getHeight() - 18 * 2) / 22);

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroBuscar,
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: 'report\\funciones\\entidades\\HTML_entidades.xsl',                
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


        function entidad_seleccionar(nro_entidad, apellido, nombres, documento, nro_docu, sexo, tipo_docu, tipo_cuitcuil, cuit, persona_fisica, razon_social) {
            
            win.options.userData.entidad = {
                nro_entidad: nro_entidad,
                apellido: apellido,
                nombres: nombres,
                documento: documento,
                nro_docu: nro_docu,
                sexo: sexo,
                tipo_docu: tipo_docu,
                tipo_cuitcuil: tipo_cuitcuil,
                cuit: cuit,
                persona_fisica: persona_fisica.toLowerCase() === 'true',
                razon_social: razon_social
            }

            win.close()
        }


        var win_abm_entidad

        // Llama la modal para editar las Entidades
        function nueva_entidad() {
            var url = '/FW/entidades/entidad_abm.aspx?nro_rol=<% = nro_rol %>'
            if (nvFW.pageContents.entidad_consultar != '')
                url += '&entidad_consultar=' + nvFW.pageContents.entidad_consultar

            win_abm_entidad = window.top.nvFW.createWindow({
                url: url,
                title: '<b>ABM Entidad</b>',
                minimizable: false,
                maximizable: true,
                draggable: true,
                width: 900,
                height: 420,
                resizable: true,
                onClose: entidad_abm_onclose
            })

            win_abm_entidad.showCenter(true)
        }


        function entidad_abm(nro_entidad) {
            if (nro_entidad != '') {
                var url = '/FW/entidades/entidad_abm.aspx?nro_entidad=' + nro_entidad
                if (nvFW.pageContents.entidad_consultar != '')
                    url += '&entidad_consultar=' + nvFW.pageContents.entidad_consultar

                var win_entidad_abm = window.top.nvFW.createWindow({
                    url: url,
                    title: '<b>Entidad ABM</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
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
                return Aceptar((nvFW.pageContents.nro_entidad_get != 0 ? nvFW.pageContents.nro_entidad_get : undefined))
            }
        }


    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <form name="frmFiltro_entidad" id="frmFiltro_entidad" style="width: 100%; height: 100%; overflow: hidden; margin: 0;">
        <div id="divMenuEntidad"></div>
        <script type="text/javascript">
            var vMenuEntidad = new tMenu('divMenuEntidad', 'vMenuEntidad');
            Menus["vMenuEntidad"] = vMenuEntidad
            Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/icons/persona_alta.png')
            Menus["vMenuEntidad"].alineacion = 'centro';
            Menus["vMenuEntidad"].estilo = 'A';
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_entidad()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuEntidad.MostrarMenu()
        </script>

        <table class="tb1" id="tbFiltro" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width: 90%;">
                    <table id="tbFisica" class="tb1">
                        <tr class="tblabel">
                            <td style="width: 20%; text-align: center;">Tipo Entidad</td>
                            <td style="width: 15%; text-align: center;">Tipo Doc.</td>
                            <td style="width: 25%; text-align: center;">Documento</td>
                            <td style="width: 40%; text-align: center;">Apellido y Nombres/Razón Social</td>
                            <%--<td style="width: 35%; text-align: center;">Nombre</td>--%>
                        </tr>
                        <tr>
                            <td>
                                <select name="select_tipo_persona" id="select_tipo_persona" style="width: 100%;" <%--onchange="return tipo_persona_onchange(this)"--%>>
                                    <option value="" selected="selected"></option>
                                    <option value="0">Persona Jurídica</option>
                                    <option value="1">Persona Física</option>
                                </select>
                            </td>
                            <td>
                                <%--<% = nvCampo_def.get_html_input("tipo_docu") %>--%>
                               <script>
                                   campos_defs.add("tipo_docu")
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
