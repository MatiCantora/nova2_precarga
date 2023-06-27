<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Dim nro_entidad_get As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad_get", "0")
    Dim nro_rol = nvUtiles.obtenerValor("nro_rol", "0")

    Me.contents("filtroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>nro_entidad, apellido, nombres, 'DNI' as documento, nro_docu, sexo, tipo_docu, cuitcuil, cuit, persona_fisica, Razon_social</campos><orden>nro_entidad</orden><filtro></filtro><grupo></grupo></select></criterio>")
    Me.contents("nro_entidad_get") = nro_entidad_get
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
            window_onresize()

            // mostramos los botones creados
            vListButtons.MostrarListButton()
            
            var Parametros = window.dialogArguments

            // si se paso un nro_entidad por GET, cargar solo esa entidad
            if (nvFW.pageContents.nro_entidad_get != 0) {
                Aceptar(nvFW.pageContents.nro_entidad_get)
            }
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
                if ($('nro_docu').value != '') { filtro += "<nro_docu type='igual'>'" + $('nro_docu').value + "'</nro_docu>" }
                if (apellido = $('apellido').value != '') { filtro += "<apellido type='like'>%" + $('apellido').value + "%</apellido>" }
                if ($('nombres').value != '') { filtro += "<nombres type='like'>%" + $('nombres').value + "%</nombres>" }
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


        let esIE = Prototype.Browser.IE

        function strNombreCompleto_onkeypress(e)
        {
            if ((esIE ? e.keyCode : e.which) == 13)
                Aceptar()
            //var key=Prototype.Browser.IE?e.keyCode:e.which;
            //if(key==13)
            //    Aceptar()
        }


        function dni_onkeypress(e)
        {
            ((esIE ? e.keyCode : e.which) == 13) ? Aceptar() : valDigito(e)
            //var key=Prototype.Browser.IE?e.keyCode:e.which;
            //if(key==13)
            //    Aceptar()
            //else
            //    valDigito(e)
        }


        function window_onresize()
        {
            let dif    = esIE ? 5 : 0
            let body_h = $$('body')[0].getHeight()
            let cab_h  = $('tbFiltro').getHeight()

            try {
                $('iframeRes').style.height = body_h - cab_h - dif + 'px'
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

            win.close()
        }


        var win_abm_entidad

        // Llama la modal para editar las Entidades
        function nueva_entidad()
        {
            win_abm_entidad = window.top.nvFW.createWindow({
                url:         '/FW/entidades/entidad_abm.aspx?nro_rol=<% = nro_rol %>&nro_entidad=',
                title:       '<b>ABM Entidad</b>',
                minimizable: false,
                maximizable: false,
                draggable:   false,
                width:       900,
                height:      420,
                resizable:   false
            })

            win_abm_entidad.showCenter(true)
        }


        function entidad_abm(nro_entidad)
        {
            if (nro_entidad != '') {
                var win_entidad_abm = window.top.nvFW.createWindow({
                    url:            '/FW/entidades/entidad_abm.aspx?nro_entidad=' + nro_entidad,
                    title:          '<b>Entidad ABM</b>',
                    minimizable:    false,
                    maximizable:    false,
                    draggable:      false,
                    width:          1024,
                    height:         480,
                    resizable:      false,
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
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <form name="frmFiltro_entidad" id="frmFiltro_entidad" style="width: 100%; height: 100% ; overflow: hidden; margin: 0;">
        <div id="divMenuEntidad"></div>
        <script type="text/javascript">
            //var DocumentMNG = new tDMOffLine;
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
                <td><input name="nro_docu" id="nro_docu" style="width: 100%" onkeypress="return dni_onkeypress(event)" /></td>
                <td><input name="apellido" id="apellido" style="width: 100%" onkeypress="return strNombreCompleto_onkeypress(event)" /></td>
                <td><input name="nombres" id="nombres" style="width: 100%" onkeypress="return strNombreCompleto_onkeypress(event)" /></td>
                <td><div id="divBuscar" style="width:100%"></div></td>
            </tr>
        </table>
    <iframe name="iframeRes" id="iframeRes" style="width: 100%; height: 100%; overflow: hidden; border: none;" src="/fw/enBlanco.htm"></iframe>
  </form>

</body>
</html>
