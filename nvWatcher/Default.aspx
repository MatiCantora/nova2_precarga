<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%
    Dim operador As nvFW.nvPages.tnvOperadorAdmin
    Dim sucursal As String = ""
    Dim er As New tError
    Try
        operador = nvFW.nvApp.getInstance().operador

        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("SELECT sucursal FROM sucursal WHERE nro_sucursal=" & operador.datos("nro_sucursal").value)

        If Not rs.EOF Then
            sucursal = rs.Fields("sucursal").Value
        Else
            sucursal = "Sin Sucursal"
        End If

        nvFW.nvDBUtiles.DBCloseRecordset(rs)

        'debe tener el permiso para ingresar al modulo
        If Not operador.tienePermiso("permisos_web", 2) Or Not operador.tienePermiso("permisos_web", 4) Then
            'er = New nvFW.tError()
            'er.numError = -1
            'er.titulo = "No se pudo completar la operación."
            'er.mensaje = "No tiene permisos para ver la página."
            'er.response()
            Response.Redirect("/fw/error/httpError_401.aspx?No tiene permisos para ver la página.")
        End If
    Catch ex As Exception
    End Try


    Me.addPermisoGrupo("permisos_web")
    Me.addPermisoGrupo("permisos_seguridad")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>NOVA nvWatcher Home</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        function Busqueda() {
            //ObtenerVentana('frame_ref').document.location.href = "/admin/nv_buscar.aspx"
            canal = nvFW.createWindow({
                url: "/admin/nv_buscar.aspx",
                title: 'Eventos ABM',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 1000,
                height: 450
            });

            canal.showCenter(true)
        }

        var win
        //path, descripcion, permiso, nro_permiso, height, width, modulo, maximizable, draggable, resizable, modal)
        function abrir_ventana_emergente(path, descripcion, permiso_grupo, nro_permiso, height, width, minimizable, maximizable, resizable, draggable, modal) {

            if (permiso_grupo && nro_permiso && !nvFW.tienePermiso(permiso_grupo, nro_permiso)) {
                alert("No tiene permisos para acceder a esta opción", {
                    title: "<b>Permisos insuficientes</b>",
                    height: 70,
                    width: 400
                })

                return
            }

            // Obtener el modificador
            var tecla_modificador = 'default'

            if (window.event.ctrlKey)
                tecla_modificador = 'control'
            else if (window.event.shiftKey)
                tecla_modificador = 'shift'

            if (tecla_modificador == 'default') {
                // Medidas por defecto en caso que no esten definidas
                height = height || 512
                width = width || 1024
                minimizable = minimizable !== undefined ? minimizable : false
                maximizable = maximizable !== undefined ? maximizable : false
                resizable = resizable !== undefined ? resizable : false
                draggable = draggable !== undefined ? draggable : true
                modal = modal !== undefined ? modal : false

                var win = nvFW.createWindow({
                    title: '<b>' + descripcion + '</b>',
                    url: path,
                    minimizable: minimizable,
                    maximizable: maximizable,
                    resizable: resizable,
                    draggable: draggable,
                    width: width,
                    height: height,
                    destroyOnClose: true
                });

                win.showCenter(modal);
            }
            else {
                // Nueva pestaña
                if (tecla_modificador == 'control') {
                    window.open(path)
                }
                else {
                    // Nueva ventana
                    var xMax = window.screen.width - 15
                    var yMax = window.screen.availHeight - 55
                    window.open(path, '_blank', 'top=0,left=0,width=' + xMax + ',height=' + yMax)
                }
            }
        }


        function window_onresize() {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_heigth = $$('body')[0].getHeight()
            cab_heigth = $('tb_cab').getHeight()
            $('tb_body').setStyle({ 'height': body_heigth - cab_heigth - dif + 'px' })
        }

        function window_onload() {
            window_onresize()
        }

        /** 
        * td para hacer movil el panel del arbol de Servidores/Sistemas/Modulos
        */
        function tb_body_resize_inicio() {
            if ($('tb_body_div_hide') == null) {
                var strHTML = '<div id="tb_body_div_hide" style="width: 100%; height: 100%; position: absolute; z-index: 1000; float: left; background-color: gray; opacity: 0.1;"></div>'
                $$('BODY')[0].insert({ top: strHTML })

                strHTML = '<div id="tb_body_div_rec" style="position: absolute; z-index: 1000; float: left; background-color: #539bf1; opacity: 0.5;"></div>'
                $$('BODY')[0].insert({ top: strHTML })

                var oDIV_rec = $("tb_body_div_rec")
                td_move = $('tb_body_td_move')
                oDIV_rec.setStyle({ width: td_move.getWidth(), height: td_move.getHeight() })
            }
            else {
                $('tb_body_div_hide').show()
                var oDIV_rec = $('tb_body_div_rec')
                oDIV_rec.show()
            }

            Element.clonePosition(oDIV_rec, td_move)
            $$('BODY')[0].setStyle({ cursor: 'w-resize' })

            Event.observe($$('BODY')[0], 'mousemove', tb_body_resize_mousemove);
            Event.observe($$('BODY')[0], 'mouseup', tb_body_resize_fin);
        }

        function tb_body_resize_fin() {
            var body = $$('BODY')[0]
            var oDIV_rec = $('tb_body_div_rec')
            $('tb_body_td').setStyle({ width: oDIV_rec.getStyle('left') })
            Event.stopObserving($$('BODY')[0], 'mousemove', tb_body_resize_mousemove);

            var oDIV = $("tb_body_div_hide")
            $$('BODY')[0].setStyle({ cursor: 'default' })
            oDIV.hide()
            oDIV_rec.hide()
        }

        function tb_body_resize_mousemove(e) {
            try {
                var nuevoX = Event.pointerX(e) - 4
                $('tb_body_div_rec').setStyle({ left: nuevoX + 'px' })
                document.selection.clear()
            }
            catch (e) { }
        }


    </script>
    <script type="text/javascript">
        function updateModDef(cod_modulo_version, cod_objeto, objeto, path0, cod_obj_tipo, resStatus) 
        {
            nvFW.error_ajax_request('ejecutar_acciones_integridad.aspx', {
                parameters: {
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


        function updateImplementacion(cod_modulo_version, cod_objeto, objeto, path0, cod_obj_tipo, resStatus) 
        {
            nvFW.error_ajax_request('ejecutar_acciones_integridad.aspx', {
                parameters: {
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
    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="overflow: hidden">
    <form action='' id="ventana_nueva" target="_blank" method="get" style="display: none">
    </form>
    <table id="tb_cab" cellspacing="0" border="0" cellpadding="0" style="width: 100%;
        height: 64">
        <tr>
            <td rowspan="2" id="logo_rm" style="width: 424px; height: 64px">
                <object style="width: 140px; height: 64px" data="/admin/image/cabecera/Logo_Nova_Inicio_admin.svg"
                    type="image/svg+xml">
                </object>
            </td>
            <td>
                <table cellpadding="0" cellspacing="0" border="0" style="width: 100%">
                    <tr>
                        <td id="user_name" style="text-align: right" nowrap>
                            <% = operador.login.ToUpper%>
                        </td>
                    </tr>
                    <tr>
                        <td id="data_user" style="text-align: right; vertical-align: middle" nowrap>
                            <% = sucursal%>
                            <img border="0" class="img_button" align="absmiddle" hspace="2" alt="Bloquear sesión"
                                title="Bloquear sesión" src="../../FW/image/tSession/sesion_bloquear.png" onclick="nvSesion.bloquear()" />
                            <img border="0" class="img_button" align="absmiddle" hspace="2" alt="Cerrar sesión"
                                title="Cerrar sesión" src="../../FW/image/tSession/sesion_cerrar.png" onclick="nvSesion.cerrar()" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <div id="DIV_Menu" style="width: 100%">
                </div>
            </td>
        </tr>
    </table>
    <table id="tb_body" cellpadding="0" cellspacing="0" border="0" style="width: 100%; height: 100%;">
        <tr>
            <td id="tb_body_td" style="width: 40%">
                <iframe src="../FW/watcher/nWatcher_listar.aspx" name="frame_abm" id="frame_abm" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            </td>
            <td id="tb_body_td_move" style="width: 2px; cursor: w-resize;" onmousedown="javascript:tb_body_resize_inicio()">
                &nbsp;
            </td>
            <td>
                <iframe src="../FW/watcher/nWatcher_eventos.aspx" name="frame_eventos" id="frame_eventos" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            </td>
        </tr>
    </table>
    <script type="text/javascript" language="javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenu = new tMenu('DIV_Menu', 'vMenu');
        vMenu.alineacion = 'izquierda';
        vMenu.estilo = 'O'

        vMenu.loadImage("inicio", '/admin/image/icons/home.png')
        vMenu.loadImage('login', '/admin/image/icons/login.png')
        vMenu.loadImage('permiso', '/admin/image/icons/sesion_cerrar.png')
        vMenu.loadImage("servidor", '/admin/image/icons/servidor.png')
        vMenu.loadImage('log', '/admin/image/icons/log.png')
        vMenu.loadImage('seguridad', '/admin/image/icons/seguridad.png')

        var TargetDocumentos = 'lado';
        var e;
        DocumentMNG.APP_PATH = window.location.href;
        var strXML = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', '/nvWatcher/DocMNG/data/nvWatcher_mnu_cabecera.xml')
        vMenu.CargarXML(strXML);

        vMenu.MostrarMenu();
    </script>
</body>
</html>
