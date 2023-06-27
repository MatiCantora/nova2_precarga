<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Dim nro_entidad_get As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad_get", "0")
    Dim nro_rol = nvUtiles.obtenerValor("nro_rol", "0")
    Dim modoSeleccionarEntidadFirmante As String = nvUtiles.obtenerValor("modoSeleccionarEntidadFirmante", "0")

    Me.contents("filtroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>nro_entidad, apellido, nombres, 'DNI' as documento, nro_docu, sexo, tipo_docu, cuitcuil, cuit, persona_fisica, Razon_social</campos><orden>nro_entidad</orden><filtro></filtro><grupo></grupo></select></criterio>")
    Me.contents("nro_entidad_get") = nro_entidad_get
    Me.contents("modoSeleccionarEntidadFirmante") = modoSeleccionarEntidadFirmante
    
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
        var Parametros              = []
        var win                     = nvFW.getMyWindow()
        var vButtonItems            = {};
        vButtonItems[0]             = []
        vButtonItems[0]["nombre"]   = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"]   = "buscar";
        vButtonItems[0]["onclick"]  = "return Aceptar()";

        var vListButtons            = new tListButton(vButtonItems,'vListButtons')
        vListButtons.loadImage("buscar",'/fw/image/icons/buscar.png') 


        function window_onload()
        {
            // mostramos los botones creados
            vListButtons.MostrarListButton()
            
            var Parametros = window.dialogArguments

            // si se paso un nro_entidad por GET, cargar solo esa entidad
            if (nvFW.pageContents.nro_entidad_get != 0) {
                Aceptar(nvFW.pageContents.nro_entidad_get)
            }

            set_campos_defs_onchange()

            window_onresize()
        }


        function set_campos_defs_onchange()
        {
            ['nro_docu', 'apellido', 'nombres'].each(function (input_name) {
                campos_defs.items[input_name]['input_hidden'].onkeypress = is_enter
            })
        }


        function is_enter(event)
        {
            if ((event.which || event.keyCode) == 13)
                Aceptar()
        }


        function AgregarEntidad(nro_entidad, apellido, nombres, documento, nro_docu, sexo, tipo_docu)
        {
            var Entidad            = []
            Entidad["nro_entidad"] = nro_entidad
            Entidad["apellido"]    = apellido
            Entidad["nombres"]     = nombres
            Entidad["documento"]   = documento
            Entidad["nro_docu"]    = nro_docu
            Entidad["sexo"]        = sexo
            Entidad["tipo_docu"]   = tipo_docu

            window.parent.win.returnValue = Entidad
            window.parent.win.close();
        }


        // Realiza la busqueda de Entidades
        function Aceptar(nro_entidad_get)
        {
            var filtro = ""

            if (nro_entidad_get != undefined) {
                filtro = "<nro_entidad type='igual'>" + nro_entidad_get + "</nro_entidad>"
            }
            else {
                if (campos_defs.get_value('nro_docu') != '') {
                    filtro += "<nro_docu type='igual'>'" + campos_defs.get_value('nro_docu') + "'</nro_docu>"
                }

                if (campos_defs.get_value('apellido') != '') {
                    filtro += "<apellido type='like'>%" + campos_defs.get_value('apellido') + "%</apellido>"
                }
                
                if (campos_defs.get_value('nombres') != '') {
                    filtro += "<nombres type='like'>%" + campos_defs.get_value('nombres') + "%</nombres>"
                }
            }

            nvFW.exportarReporte({ 
                filtroXML:          nvFW.pageContents.filtroBuscar,
                filtroWhere:        filtro,
                path_xsl:           'report\\funciones\\entidades\\HTML_entidades.xsl',
                formTarget:         'iframeRes',
                bloq_contenedor:    $('iframeRes'),
                cls_contenedor:     'iframeRes',
                cls_contenedor_msg: " ",
                bloq_msg:           "Cargando..."
            })
        }


        var esIE = Prototype.Browser.IE

        //function strNombreCompleto_onkeypress(e)
        //{
        //    if ((esIE ? e.keyCode : e.which) == 13)
        //        Aceptar()
        //    //var key=Prototype.Browser.IE?e.keyCode:e.which;
        //    //if(key==13)
        //    //    Aceptar()
        //}


        //function dni_onkeypress(e)
        //{
        //    ((esIE ? e.keyCode : e.which) == 13) ? Aceptar() : valDigito(e)
        //    //var key=Prototype.Browser.IE?e.keyCode:e.which;
        //    //if(key==13)
        //    //    Aceptar()
        //    //else
        //    //    valDigito(e)
        //}

        var dif = esIE ? 5 : 0


        function window_onresize()
        {
            var body_h           = $$('body')[0].getHeight()
            var divMenuEntidad_h = $('divMenuEntidad').getHeight()
            var tbFiltro_h       = $('tbFiltro').getHeight()

            try {
                $('iframeRes').style.height = body_h - divMenuEntidad_h - tbFiltro_h - dif + 'px'
            }
            catch(e) {}
        }


        function entidad_seleccionar(nro_entidad, apellido, nombres, documento, nro_docu, sexo, tipo_docu, tipo_cuitcuil, cuit, persona_fisica, razon_social)
        {
            win.options.userData.entidad = {
                nro_entidad:    nro_entidad,
                apellido:       apellido,
                nombres:        nombres,
                documento:      documento,
                nro_docu:       nro_docu,
                sexo:           sexo,
                tipo_docu:      tipo_docu,
                tipo_cuitcuil:  tipo_cuitcuil,
                cuit:           cuit,
                persona_fisica: persona_fisica.toLowerCase() === 'true',
                razon_social:   razon_social
            }
            
            if (nvFW.pageContents.modoSeleccionarEntidadFirmante=="0") {
                win.close()
                return
            }
            
            if (persona_fisica.toLowerCase() === 'true') {
                aceptar_individual(nro_entidad, razon_social)
            } else {
                if (nro_entidad) {
                    abrir_asistente(nro_entidad, razon_social)
                }
            }
        }


        var win_abm_entidad

        // Llama la modal para editar las Entidades
        function nueva_entidad()
        {
            win_abm_entidad = window.top.nvFW.createWindow({
                url:         '/FW/entidades/entidad_abm.aspx?nro_rol=<% = nro_rol %>&nro_entidad=',
                title:       '<b>ABM Entidad</b>',
                minimizable: true,
                maximizable: true,
                draggable:   true,
                width:       900,
                height:      420,
                resizable:   true
            })

            win_abm_entidad.showCenter(true)
        }

        function entidad_abm(nro_entidad)
        {
            if (nro_entidad != '') {
                var win_entidad_abm = window.top.nvFW.createWindow({
                    url:            '/FW/entidades/entidad_abm.aspx?nro_entidad=' + nro_entidad,
                    //url: '/FW/entidades/zzrol_abm.aspx?nro_entidad=' + nro_entidad,
                    title:          '<b>Entidad ABM</b>',
                    minimizable:    true,
                    maximizable:    true,
                    draggable:      true,
                    width:          1130,
                    height:         620,
                    resizable:      true,
                    destroyOnClose: true,
                    onClose:        entidad_abm_onclose
                })

                win_entidad_abm.options.userData = { recargar: false }
                win_entidad_abm.showCenter(true)
            }
        }

        function entidad_abm_onclose(win)
        {
            if (win.options.userData.recargar) {
                return Aceptar((nvFW.pageContents.nro_entidad_get != 0 ? nvFW.pageContents.nro_entidad_get : undefined))
            }
        }

        function abrir_asistente(nro_entidad, razon_social) {
            var win2 = nvFW.createWindow({
                url: '/fw/esquema_firma/firmas_ABM_asistente.aspx?entidad=' + nro_entidad + "&razon_social=" + razon_social,
                title: '<b>Asistente de Esquemas</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 600,
                height: 400,
                onClose: function () {
                    if (!win2.options.userData)
                        return
                    var xmlData = win2.options.userData.retorno["xmlData"]
                    win.options.userData.retorno["entidad_juridica"] = { xmlData: xmlData }
                    win.close()
                }
            });
            win2.showCenter(true)
            win2.options.userData = { retorno: {} }
        }

        function aceptar_individual(nroEntidad, razonSocial) {
            win.options.userData.retorno["entidad_fisica"] = {}
            win.options.userData.retorno["entidad_fisica"]["nro_entidad"] = nroEntidad
            win.options.userData.retorno["entidad_fisica"]["razon_social"] = razonSocial
            win.close()
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <form name="frmFiltro_entidad" id="frmFiltro_entidad" style="width: 100%; height: 100% ; overflow: hidden; margin: 0;">
        <div id="divMenuEntidad"></div>
        <script type="text/javascript">
            var vMenuEntidad = new tMenu('divMenuEntidad', 'vMenuEntidad');
            Menus["vMenuEntidad"] = vMenuEntidad
            Menus["vMenuEntidad"].loadImage("nueva", '/fw/image/icons/nueva.png')
            Menus["vMenuEntidad"].alineacion = 'centro';
            Menus["vMenuEntidad"].estilo = 'A';
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuEntidad"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_entidad()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuEntidad.MostrarMenu()
        </script>

        <table id="tbFiltro" class="tb1" style='width:100%'>
            <tr class="tblabel">
                <td style="width: 25%">Documento</td>
                <td style="width: 25%">Apellido</td>
                <td style="width: 25%">Nombre</td>
                <td></td>
            </tr>
            <tr>
                <td>
                    <% = nvCampo_def.get_html_input("nro_docu", enDB:=False, nro_campo_tipo:=100) %>
                </td>
                <td>
                    <% = nvCampo_def.get_html_input("apellido", enDB:=False, nro_campo_tipo:=104) %>
                </td>
                <td>
                    <% = nvCampo_def.get_html_input("nombres", enDB:=False, nro_campo_tipo:=104) %>
                </td>
                <td><div id="divBuscar" style="width:100%"></div></td>
            </tr>
        </table>

        <iframe name="iframeRes" id="iframeRes" style="width: 100%; height: 100%; overflow: hidden; border: none;" src="/fw/enBlanco.htm"></iframe>
    </form>
</body>
</html>
