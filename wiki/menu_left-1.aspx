<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    'Stop
    'Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    'Dim permisos_referencias As Boolean = op.tienePermiso("permisos_referencias", 1)
    'Dim permisos_tareas As Boolean = op.tienePermiso("permisos_tareas", 1)

    Me.addPermisoGrupo("permisos_referencias")
    Me.addPermisoGrupo("permisos_tareas")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Wiki Menu</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <style type="text/css">
        #titulo_menu_left { font-size: 1.1em !important; text-align:center; }
    </style>

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        <%--var permisos_referencias = '<%= permisos_referencias %>',
            permisos_tareas = '<%= permisos_tareas %>',--%>
        var vButtonItems = {}
    
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"]   = "Referencias";
        vButtonItems[0]["etiqueta"] = "Referencias";
        vButtonItems[0]["imagen"]   = "ref";
        vButtonItems[0]["onclick"]  = "return referencia()";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"]   = "Tareas";
        vButtonItems[1]["etiqueta"] = "Mis Tareas";
        vButtonItems[1]["imagen"]   = "vincular";
        vButtonItems[1]["onclick"]  = "return tarea()";
  
        vButtonItems[2] = {};
        vButtonItems[2]["nombre"]   = "Contactos";
        vButtonItems[2]["etiqueta"] = "Contactos";
        vButtonItems[2]["imagen"]   = "operador";
        vButtonItems[2]["onclick"]  = "return contacto()";  
 
        var Imagenes = []
        Imagenes["operador"]     = new Image();
        Imagenes["operador"].src = '/FW/image/icons/editar.png';
        Imagenes["vincular"]     = new Image();
        Imagenes["vincular"].src = '/wiki/image/icons/vincular.png';
        Imagenes["ref"]          = new Image();
        Imagenes["ref"].src      = '/FW/image/icons/info.png';

        var vListButton = new tListButton(vButtonItems,'vListButton');
        vListButton.imagenes = Imagenes

        // Referencias a ventanas utilizadas - Se cargan en onLoad
        var winDivMenuContent = {},
            winFrameRef       = {},
			winMenuLeft       = {}

        function window_resize() {
            var body          = $$('BODY')[0],
                tbMenu_items  = $("tbMenu_items"),
                tbMenu_titulo = $('tbMenu_titulo')

            $('divMenu_content').setStyle({
                height: (body.getHeight() - tbMenu_items.getHeight() - tbMenu_titulo.getHeight()) + 'px',
                width: body.getWidth() + 'px'
            })
        }

        function window_onload() {
            vListButton.MostrarListButton()

            // cargar las referencias de ventanas
            winDivMenuContent = ObtenerVentana('divMenu_content'),
            winFrameRef       = ObtenerVentana('frame_ref')
			winMenuLeft       = ObtenerVentana('menu_left')

            if (nvFW.tienePermiso("permisos_referencias", 1)) 
                referencia()
            else
                if (nvFW.tienePermiso("permisos_tareas", 1))
                    tarea()
                else
                    winDivMenuContent.location.href = 'enBlanco.htm'

            window_resize()
        }

        function referencia() {
            if (nvFW.tienePermiso("permisos_referencias", 1)) {
                winDivMenuContent.location.href             = '/wiki/ref_tree.aspx'
                winFrameRef.location.href                   = '/wiki/inicio.aspx'
                winMenuLeft.$('titulo_menu_left').innerHTML = 'Referencias'
            }
            else
                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
        }

        function tarea() {
            if (nvFW.tienePermiso("permisos_tareas", 1)) {
                winDivMenuContent.location.href = '/wiki/enBlanco.htm'
                winFrameRef.location.href       = '/wiki/mis_tareas.aspx'
            }
            else
                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
        }

        function contacto() {}
</script>
</head>
<body onload="window_onload()" onresize="window_resize()" style="overflow:hidden; height:100%">
    <table class="tb1" id="tbMenu_titulo">
        <tr class="Tit2">
            <td id="titulo_menu_left">Referencias</td>
        </tr>
    </table>

    <iframe  name="divMenu_content" id="divMenu_content" style="height: 212px; overflow: auto; margin: 0px; padding: 0px; border: none; width: 300px;" src="enBlanco.htm"></iframe>
    
    <table class="tb1" id="tbMenu_items">
        <tr>
            <td style="width:100%"><div id="divReferencias" style="width:100%"/></td>
        </tr>
        <tr>
            <td style="width:100%"><div id="divTareas" style="width:100%"/></td>
        </tr>
        <tr>
            <td style="width:100%"><div id="divContactos" style="width:100%"/></td>
        </tr>
    </table>
</body>
</html>
