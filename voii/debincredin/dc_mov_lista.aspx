<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim nro_proceso As Integer = nvFW.nvUtiles.obtenerValor("nro_proceso", "-1")
    Me.contents("filtro_consultarArchivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccionPago_archivos'><campos>*</campos><filtro></filtro></select></criterio>")
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Archivos asociados a Instrucción de Pago - Proceso Nº <% = nro_proceso %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <% = Me.getHeadInit() %>

    <script type="application/javascript">
        var dif         = Prototype.Browser.isIE ? 5 : 0
        var nro_proceso = parseInt(<% = nro_proceso %>)
        var $body
        var $divMenu
        var $iframe_archivos

        
        function window_onresize()
        {
            try {
                $iframe_archivos.style.height = $body.getHeight() - $divMenu.getHeight() + 'px'
            }
            catch(e) {}
        }


        function window_onload()
        {
            // cache
            $body            = $$('body')[0]
            $divMenu         = $('divMenu')
            $iframe_archivos = $('iframe_archivos')

            window_onresize()
            cargarArchivos()
        }


        function cargarArchivos()
        {
            nvFW.exportarReporte({
                filtroXML:            nvFW.pageContents.filtro_consultarArchivos,
                filtroWhere:          '<criterio><select><filtro><nro_proceso type="igual">' + nro_proceso + '</nro_proceso></filtro></select></criterio>',
                path_xsl:             'report/verInstruccionPago/HTML_instrucciones_pago_listado_archivos.xsl',
                formTarget:           'iframe_archivos',
                cls_contenedor:       'iframe_archivos',
                cls_contenedor_msg:   ' ',
                bloq_contenedor:      $iframe_archivos,
                bloq_msg:             'Cargando listado de archivos...',
                nvFW_mantener_origen: true
            })
        }


        function adjuntarArchivos()
        {
            var win_alta_archivos = parent.nvFW.createWindow({
                url:            'instruccion_pago_archivos_alta.aspx?nro_proceso=' + nro_proceso,
                title:          '<b>Adjuntar Archivos</b>',
                width:          800,
                height:         350,
                maximizable:    false,
                minimizable:    false,
                resizable:      false,
                destroyOnClose: true,
                onClose:        adjuntarArchivos_onClose
            })

            win_alta_archivos.options.userData = { recargar_lista: false }
            win_alta_archivos.showCenter(true)
        }


        function adjuntarArchivos_onClose(win) {
            if (win.options.userData.recargar_lista)
                cargarArchivos()
        }
    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <div id="divMenu" style="width: 100%; margin: 0; padding: 0;"></div>
    <script>
        var vMenu = new tMenu('divMenu', 'vMenu')

        vMenu.loadImage('archivo', '/FW/image/icons/nueva.png')

        Menus["vMenu"]            = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo     = 'A';

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Adjuntar Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>adjuntarArchivos()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu.MostrarMenu()
    </script>

    <iframe name="iframe_archivos" id="iframe_archivos" style="width: 100%; border: none;"></iframe>
   
</body>
</html>
