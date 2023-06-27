<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim operador As nvFW.nvPages.tnvOperadorVOII
    Dim sucursal As String = ""

    Try
        operador = nvFW.nvApp.getInstance().operador

        'Me.addPermisoGrupo("permisos_herramientas")
        'Me.addPermisoGrupo("permisos_seguridad")
        'Me.addPermisoGrupo("permisos_transferencia")
        'Me.addPermisoGrupo("permisos_parametros")
        'Me.addPermisoGrupo("permisos_procesos_tareas")
        'Me.addPermisoGrupo("permisos_transferencia_seguimiento")
        'Me.addPermisoGrupo("permisos_solicitudes")
        'Me.addPermisoGrupo("permisos_pizarra_gral")


        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("SELECT sucursal FROM sucursal WHERE nro_sucursal=" & operador.datos("nro_sucursal").value)
        sucursal = IIf(Not rs.EOF, rs.Fields("sucursal").Value, "Sin sucursal")
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
    Catch ex As Exception
    End Try

    ' Diccionario para pedirle a la Page del VOII que cargue los permisos; SOLO CARGAR EN DEFAULT.ASPX
    Dim dicInit As New Dictionary(Of String, Boolean)
    dicInit.Add("permisos", True)
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title>NOVA VOII</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <link rel="icon" type="image/png" href="/fw/image/icons/nv_voii.png"/>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>

    <% = Me.getHeadInit(dicInit) %>

    <script type="text/javascript">
        var sistema
        var canal
        var win
        var winActualizar


        function operador_permiso_ABM() {
            ObtenerVentana('frame_ref').document.location.href = "/admin/operador_permiso_abm.aspx";
        }


        function Log() {
            canal = nvFW.createWindow(
                {
                    url: "/admin/ABMNvLog/nvLog_lista.aspx",
                    title: '<b>Log ABM</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 850,
                    height: 450,
                    destroyOnClose: true
                });

            canal.showCenter(true);
        }


        function ADreportes() {
            ObtenerVentana('frame_ref').document.location.href = "../admin/ad_reportes.asp";
        }


        function Eventos() {
            canal = nvFW.createWindow(
                {
                    url: "/admin/ABMNvLog/nvLog_evento_lista.aspx",
                    title: '<b>Eventos ABM</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 850,
                    height: 450,
                    destroyOnClose: true
                });

            canal.showCenter(true);
        }


        function EventosTipo() {
            ObtenerVentana('frame_ref').document.location.href = "../admin/eventos_tipos_abm.asp";
        }


        var nvTargetWin = tnvTargetWin()
        if (!window.top.nvTargetWin)
            window.top.nvTargetWin = nvTargetWin
        else
            nvTargetWin = window.top.nvTargetWin

        function abrir_ventana_emergente_solicitud(path, descripcion, permiso, nro_permiso, height, width)
        {
            // Chequear si esta cargado el permiso_grupo
           /* if (!nvFW.permiso_grupos[permiso]) {
                nvFW.permiso_grupos[permiso] = this[permiso] ? this[permiso] : 0;
            }

            if (!nvFW.tienePermiso(permiso, nro_permiso)) {
                alert('No posee los permisos necesarios para realizar esta acción.');
                return;
            }

            height = height == undefined ? 480 : height;
            width = width == undefined ? 1024 : width;

            var porcentajeHeight;
            if (screen.height < 800)
                porcentajeHeight = 0.947;
            else porcentajeHeight = 0.963;

            var win = nvFW.createWindow({
                url: path,
                title: '<b>' + descripcion + '</b>',
                minimizable: true,
                maximizable: false,
                resizable: false,
                draggable: true,
                parentWidthElement: $("frame_ref"),
                parentWidthPercent: 0.988,
                parentHeightElement: $("frame_ref"),
                parentHeightPercent: porcentajeHeight,
                centerHFromElement: $("tb_body"),
                centerVFromElement: $("tb_body"),
                destroyOnClose: true
                
            });


            win.options.userData = { retorno: {} };
            win.options.data = {};
            win.showCenter();*/

            var porcentajeHeight;
            if (screen.height < 800)
                porcentajeHeight = 0.947;
            else porcentajeHeight = 0.963;

            var parametros = {}
            parametros.path = path
            parametros.descripcion = descripcion
            parametros.permiso = permiso
            parametros.nro_permiso = nro_permiso
            parametros.height = height
            parametros.width = width
            parametros.minimizable = true
            parametros.maximizable = false
            parametros.draggable = true
            parametros.resizable = true
            //parametros.eventKey = eventKey
            parametros.parentWidthPercent =  0.988
            parametros.parentHeightPercent = porcentajeHeight
            parametros.destroyOnClose = true 
            parametros.modal = false

            nvTargetWin.owopen(parametros)
        }

        function abrir_ventana_emergente_seguimiento_archivo(path, descripcion, permiso, nro_permiso, height, width)
        {
            // Chequear si esta cargado el permiso_grupo
           /* if (!nvFW.permiso_grupos[permiso]) {
                nvFW.permiso_grupos[permiso] = this[permiso] ? this[permiso] : 0;
            }

            if (!nvFW.tienePermiso(permiso, nro_permiso)) {
                alert('No posee los permisos necesarios para realizar esta acción.');
                return;
            }

            height = height == undefined ? 480 : height;
            width = width == undefined ? 1024 : width;

            var porcentajeHeight;
            if (screen.height < 800)
                porcentajeHeight = 0.947;
            else porcentajeHeight = 0.963;

            var win = nvFW.createWindow({
                url: path,
                title: '<b>' + descripcion + '</b>',
                minimizable: true,
                maximizable: true,
                resizable: false,
                draggable: true,
                parentWidthElement: $("frame_ref"),
                parentWidthPercent: 0.988,
                parentHeightElement: $("frame_ref"),
                parentHeightPercent: porcentajeHeight,
                centerHFromElement: $("tb_body"),
                centerVFromElement: $("tb_body"),
                destroyOnClose: true
                
            });


            win.options.userData = { retorno: {} };
            win.options.data = {};
            win.showCenter();*/

            var porcentajeHeight;
            if (screen.height < 800)
                porcentajeHeight = 0.947;
            else porcentajeHeight = 0.963;

            var parametros = {}
            parametros.path = path
            parametros.descripcion = descripcion
            parametros.permiso = permiso
            parametros.nro_permiso = nro_permiso
            parametros.height = height
            parametros.width = width
            parametros.minimizable = true
            parametros.maximizable = false
            parametros.draggable = true
            parametros.resizable = true
            parametros.parentWidthPercent =  0.988
            parametros.parentHeightPercent = porcentajeHeight
            parametros.destroyOnClose = true 
            parametros.modal = false
            parametros.options = { retorno: {} };

            nvTargetWin.owopen(parametros)
        }

        function abrir_ventana_emergente_asignacion(path, descripcion, permiso, nro_permiso, height, width) {
            //if (!nvFW.permiso_grupos[permiso]) {
            //    nvFW.permiso_grupos[permiso] = this[permiso] ? this[permiso] : 0;
            //}

            //if (!nvFW.tienePermiso(permiso, nro_permiso)) {
            //    alert('No posee los permisos necesarios para realizar esta acción.');
            //    return;
            //}

            height = height == undefined ? 480 : height;
            width = width == undefined ? 1024 : width;

            var porcentajeHeight;
            if (screen.height < 800)
                porcentajeHeight = 0.947;
            else porcentajeHeight = 0.963;

            var win = nvFW.createWindow({
                url: path,
                title: '<b>' + descripcion + '</b>',
                minimizable: true,
                maximizable: true,
                resizable: false,
                draggable: true,
                parentWidthElement: $("frame_ref"),
                parentWidthPercent: 0.988,
                parentHeightElement: $("frame_ref"),
                parentHeightPercent: porcentajeHeight,
                centerHFromElement: $("tb_body"),
                centerVFromElement: $("tb_body"),
                destroyOnClose: true

            });


            win.options.userData = { retorno: {} };
            win.options.data = {};
            win.showCenter();
        }

        function abrir_ventana_emergente_resizable(path, descripcion, permiso, nro_permiso, height, width)
        {
            // Chequear si esta cargado el permiso_grupo
            if (!nvFW.permiso_grupos[permiso]) {
                nvFW.permiso_grupos[permiso] = this[permiso] ? this[permiso] : 0;
            }

            if (!nvFW.tienePermiso(permiso, nro_permiso)) {
                alert('No posee los permisos necesarios para realizar esta acción.');
                return;
            }

            height = height == undefined ? 400 : height;
            width = width == undefined ? 800 : width;


            var win = nvFW.createWindow({
                url: path,
                title: '<b>' + descripcion + '</b>',
                minimizable: true,
                maximizable: false,
                resizable: false,
                draggable: true,
                destroyOnClose: true,
                width: width,
                height: height
            });


            win.options.userData = { retorno: {} };
            win.options.data = {};
            win.showCenter();
        }


        function brLog_showWindow() {
            nvFW.brLog.showWindow();
        }


        function window_onresize() {
            var dif = Prototype.Browser.IE ? 5 : 0;
            var body_heigth = $$('body')[0].getHeight();
            var cab_heigth = $('tb_cab').getHeight();

            $('tb_body').setStyle({ 'height': body_heigth - cab_heigth - dif + 'px' });

            setTimeout('nvTargetWin.winMinOrder()', 100)

        }


        function window_onload() {
		   document.domain = "redmutual.com.ar"
            nvTargetWin.base = ObtenerVentana('frame_ref')
            window_onresize();
        }


        function prototype_window(obj) {
            var win = new Window(obj);
            return win;
        }


        function nv_sistemas_cambiar(sistema, ventana) {
            nvFW.abrir_sistema(sistema, ventana);
        }
    </script>
    <script type="text/javascript">
        function tb_body_resize_inicio() {
            if ($('tb_body_div_hide') == null) {
                var strHTML = '<div id="tb_body_div_hide" style="width: 100%; height: 100%; position: absolute; z-index: 1000; float: left; background-color: gray; opacity: 0.1;"></div>';
                $$('BODY')[0].insert({ top: strHTML });
                strHTML = '<div id="tb_body_div_rec" style="position: absolute; z-index: 1000; float: left; background-color: gray; opacity: 0.5;"></div>';
                $$('BODY')[0].insert({ top: strHTML });
                var oDIV_rec = $("tb_body_div_rec");
                td_move = $('tb_body_td_move');
                oDIV_rec.setStyle({ width: td_move.getWidth(), height: td_move.getHeight() });
            }
            else {
                $('tb_body_div_hide').show();
                var oDIV_rec = $('tb_body_div_rec');
                oDIV_rec.show();
            }

            Element.clonePosition(oDIV_rec, td_move);
            body.setStyle({ cursor: 'w-resize' });
            Event.observe($$('BODY')[0], 'mousemove', tb_body_resize_mousemove);
            Event.observe($$('BODY')[0], 'mouseup', tb_body_resize_fin);
        }


        function tb_body_resize_fin() {
            var oDIV_rec = $('tb_body_div_rec');
            $('tb_body_td').setStyle({ width: oDIV_rec.getStyle('left') });
            Event.stopObserving($$('BODY')[0], 'mousemove', tb_body_resize_mousemove);
            var oDIV = $("tb_body_div_hide");
            $$('BODY')[0].setStyle({ cursor: '' });
            oDIV.hide();
            oDIV_rec.hide();
        }


        function tb_body_resize_mousemove(e) {
            try {
                var nuevoX = Event.pointerX(e) - 4;
                $('tb_body_div_rec').setStyle({ left: nuevoX + 'px' });
                document.selection.clear();
            }
            catch (e) { }
        }
    </script>
    <script type="text/javascript">
        function sica_controlar_integridad() {
            var err = new tError();
            err.request("/FW/sica/sica_control_integridad.aspx?accion=currentApp", { asynchronous: false });
            alert(err.numError + ":" + err.mensaje);
        }


        function sica_comparar_modulos() {
            var win = nvFW.createWindow(
                {
                    url: '/admin/sica/modulos_versiones_comparar.aspx',
                    title: '<b>Comparar Módulos</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 650,
                    height: 350,
                    destroyOnClose: true,
                    onClose: function () {
                        var success = win.options.userData.retorno["success"];
                        if (success) { }
                    }
                });

            win.options.userData = { retorno: {} };
            win.options.data = {};
            win.showCenter(true);
            win.maximize();
        }


        function sica_comparar_implementaciones() {
            var win = nvFW.createWindow(
                {
                    url: '/admin/sica/sistemas_implementaciones_comparar.aspx',
                    title: '<b>Comparar Implementaciones</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 650,
                    height: 350,
                    destroyOnClose: true,
                    onClose: function () {
                        var success = win.options.userData.retorno["success"];
                        if (success) { }
                    }
                });

            win.options.userData = { retorno: {} };
            win.options.data = {};
            win.showCenter(true);
            win.maximize();
        }


        function sica_control_res() {
            var Parametros = [];
            var win = nvFW.createWindow(
                {
                    url: '/FW/sica/sica_control_integridad.aspx?modo=currentApp',
                    title: '<b>Control de Integridad</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 650,
                    height: 350,
                    destroyOnClose: true,
                    onClose: function () {
                        var success = win.options.userData.retorno["success"];
                        if (success) { }
                    }
                });

            win.options.userData = { retorno: Parametros };
            win.options.data = {};
            win.showCenter(true);
            win.maximize();
        }


        function updateModDef(cod_modulo_version, cod_objeto, objeto, path0, cod_obj_tipo, resStatus) {
            nvFW.error_ajax_request('ejecutar_acciones_integridad.aspx',
                {
                    parameters:
                    {
                        modo: 1,
                        cod_modulo_version: cod_modulo_version,
                        path0: path0,
                        cod_objeto: cod_objeto,
                        objeto: objeto,
                        cod_obj_tipo: cod_obj_tipo,
                        resStatus: resStatus
                    },
                    onSuccess: function (err, transport) {
                        winmod.close();
                    }
                });
        }


        function updateImplementacion(cod_modulo_version, cod_objeto, objeto, path0, cod_obj_tipo, resStatus) {
            nvFW.error_ajax_request('ejecutar_acciones_integridad.aspx',
                {
                    parameters:
                    {
                        modo: 2,
                        cod_modulo_version: cod_modulo_version,
                        path0: path0,
                        cod_objeto: cod_objeto,
                        objeto: objeto,
                        cod_obj_tipo: cod_obj_tipo,
                        resStatus: resStatus
                    },
                    onSuccess: function (err, transport) {
                        winmod.close();
                    }
                });
        }


        function sica_control_res() {
            var Parametros = [];
            var win = nvFW.createWindow(
                {
                    url: '/FW/sica/sica_control_integridad.aspx?modo=currentApp',
                    title: '<b>Control de Integridad</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 650,
                    height: 350,
                    destroyOnClose: true,
                    onClose: function () {
                        var success = win.options.userData.retorno["success"];
                        if (success) { }
                    }
                });

            win.options.userData = { retorno: Parametros };
            win.options.data = {};
            win.showCenter(true);
            win.maximize();
        }
    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="overflow: hidden;">
    <table id="tb_cab" cellspacing="0" border="0" cellpadding="0" style="width: 100%; height: 64px;">
        <tr>
            <td rowspan="2" id="logo_rm" style="width: 424px; height: 64px;">
                <object style="width: 140px; height: 64px;" data="/voii/image/cabecera/Logo_Nova_Inicio_voii.svg" type="image/svg+xml"></object>
            </td>
            <td>
                <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;">
                    <tr>
                        <td style="padding: 0px 10px;">
                            <table style="width: 100%;">
                                <tr>
                                    <td id="user_name" style="text-align: right;"><% = IIf(operador.nombre_operador <> "", operador.nombre_operador.ToUpper, operador.login.ToUpper) %></td>
                                </tr>
                                <tr>
                                    <td id="data_user" style="text-align: right; font-style: italic;"><% = sucursal %></td>
                                </tr>
                            </table>
                        </td>
                        <td style="text-align: right; vertical-align: middle; width: 80px; padding-left: 10px; padding-right: 5px; border-left: 1px solid #CCC;">
                            <img border="0" class="img_button" align="absmiddle" hspace="2" alt="Bloquear sesión" title="Bloquear sesión" src="/voii/image/icons/sesion_bloquear.png" onclick="nvSesion.bloquear()" />
                            <img border="0" class="img_button" align="absmiddle" hspace="2" alt="Cerrar sesión" title="Cerrar sesión" src="/voii/image/icons/sesion_cerrar.png" onclick="nvSesion.cerrar()" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <div id="DIV_Menu" style="width: 100%"></div>
            </td>
        </tr>
    </table>

    <table id="tb_body" cellpadding="0" cellspacing="0" border="0" style="width: 100%; height: 100%;">
        <tr>
            <td>
                <%--<iframe src="enBlanco.htm" name="frame_ref" id="frame_ref" style="width: 100%; height: 100%; margin: 0; border: none;"></iframe>--%>
                <iframe src="/voii/front_consulta.aspx" name="frame_ref" id="frame_ref" style="width: 100%; height: 100%; margin: 0; border: none;"></iframe>
            </td>
        </tr>
    </table>

    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenu = new tMenu('DIV_Menu', 'vMenu');

        vMenu.alineacion = 'izquierda';
        vMenu.estilo = 'O';

        vMenu.loadImage('inicio', '/voii/image/icons/home.png');
        vMenu.loadImage('buscar', '/voii/image/icons/buscar.png');
        vMenu.loadImage('password', '/voii/image/icons/password.png');
        vMenu.loadImage('operador', '/voii/image/icons/operador.png');
        vMenu.loadImage('permiso', '/voii/image/icons/llave.png');
        vMenu.loadImage('parametros', '/voii/image/icons/parametros.png');
        vMenu.loadImage('herramientas', '/voii/image/icons/herramientas.png');
        vMenu.loadImage('modulo', '/voii/image/icons/modulo.png');
        vMenu.loadImage('nueva', '/voii/image/icons/editar.png');
        vMenu.loadImage('analisis', '/voii/image/icons/analisis.png');
        vMenu.loadImage('play', '/voii/image/icons/play.png');
        vMenu.loadImage('log', '/voii/image/icons/ver.png');
        vMenu.loadImage('evento', '/voii/image/icons/periodo.png');
        vMenu.loadImage('seguridad', '/voii/image/icons/seguridad.png');
        vMenu.loadImage('bpm', '/voii/image/icons/BPM.png');
        vMenu.loadImage('sistema', '/voii/image/sistemas/sistema.png');
        vMenu.loadImage('circuito', '/voii/image/icons/circuito.png');
        vMenu.loadImage('procesos', '/voii/image/icons/procesos.png');
        vMenu.loadImage('reporte', '/voii/image/icons/reporte.png');
        vMenu.loadImage('abm', '/voii/image/icons/abm.png');
        vMenu.loadImage('entidad', '/voii/image/icons/entidad.png');
        vMenu.loadImage('vinculo', '/voii/image/icons/socios.png');
        vMenu.loadImage('tabla', '/voii/image/icons/tabla.png');
        vMenu.loadImage('pago', '/voii/image/icons/pago.png');
        vMenu.loadImage('debincredin', '/voii/image/icons/debincredin.png');

        DocumentMNG.APP_PATH = window.location.href;
        var strXML = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', '/voii/DocMNG/Data/voii_mnu_cabecera.xml');
        vMenu.CargarXML(strXML);

        vMenu.MostrarMenu();
    </script>
</body>
</html>
