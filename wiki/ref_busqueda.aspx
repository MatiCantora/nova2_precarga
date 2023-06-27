<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim valor As String = nvFW.nvUtiles.obtenerValor("valor", "")
    Dim tipo_consulta As String = nvFW.nvUtiles.obtenerValor("tipo_consulta", "")
    Dim rNombre As String = nvFW.nvUtiles.obtenerValor("rNombre","")
    Dim rTitulo As String = nvFW.nvUtiles.obtenerValor("rTitulo","")
    Dim rCuerpo As String = nvFW.nvUtiles.obtenerValor("rCuerpo","")
    Dim aContenido As String = nvFW.nvUtiles.obtenerValor("aContenido","")
    Dim aPropiedades As String = nvFW.nvUtiles.obtenerValor("aPropiedades", "")
     
    Me.contents("filtroBusqueda") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText = 'dbo.rm_busqueda'><parametros></parametros></procedure></criterio>")
 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Búsqueda de Referencias</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>

    <%= Me.getHeadInit()%>

    <script type="text/javascript">
        function window_onresize() {
            try {
                var dif        = Prototype.Browser.IE ? 5 : 2,
                    body_h     = $$('body')[0].getHeight(),
                    cab_heigth = $('tbFiltro').getHeight()

                $('iframe_ref').setStyle({ 'height': body_heigth - cab_heigth - dif })
            }
            catch(e) {}
        }

        function window_onload() {
            var valor         = '<% = valor %>',
                // Búsqueda por texto libre
                tipo_consulta = '<% = tipo_consulta %>',
                // Búsqueda por referencia
                rNombre       = '<% = rNombre %>',
                rTitulo       = '<% = rTitulo %>',
                rCuerpo       = '<% = rCuerpo %>',
                // Búsqueda por Archivos
                aContenido    = '<% = aContenido %>',
                aPropiedades  = '<% = aPropiedades %>',
                // filtros
                filtroXML     = nvFW.pageContents.filtroBusqueda,
                //filtroWhere   = "<criterio><procedure><parametros><valor>'" + valor + "'</valor><rNombre>" + rNombre + "</rNombre><rTitulo>" + rTitulo + "</rTitulo><rCuerpo>" + rCuerpo + "</rCuerpo><aContenido>" + aContenido + "</aContenido><aPropiedades>" + aPropiedades + "</aPropiedades><tipo_consulta>" + tipo_consulta + "</tipo_consulta></parametros></procedure></criterio>"
                filtroWhere = "<criterio><procedure><parametros><valor>'" + valor + "'</valor><rNombre DataType='int'>" + rNombre + "</rNombre><rTitulo DataType='int'>" + rTitulo + "</rTitulo><rCuerpo DataType='int'>" + rCuerpo + "</rCuerpo><aContenido DataType='int'>" + aContenido + "</aContenido><aPropiedades DataType='int'>" + aPropiedades + "</aPropiedades><tipo_consulta DataType='int'>" + tipo_consulta + "</tipo_consulta></parametros></procedure></criterio>"

            nvFW.exportarReporte({
                filtroXML: filtroXML
                ,filtroWhere : filtroWhere
                ,path_xsl: "report\\verBusqueda\\HTML_busqueda.xsl"
                ,formTarget: 'iframe_res_busqueda'
                ,nvFW_mantener_origen: true
                ,id_exp_origen: 0
                ,bloq_contenedor: $('iframe_res_busqueda')
                ,cls_contenedor: 'iframe_res_busqueda'
                ,cls_contenedor_msg: ' '
                ,bloq_msg: 'Buscando resultados...'
            })

            window_onresize()
        }

        /***   Ejecuta una function del default para cargar el contenido de la referencia seleccionada   ***/
        function ref_seleccionar(nro_ref) {
            window.top.frame_ref_recargar(nro_ref)
        }

        function btnPreview_onclick(f_id) {
            var win = window.top.nvFW.createWindow({
                title: "",
                width: 320,
                height: 320,
                minimizable: true,
                maximizable: true,
                maxWidth: 900,
                maxHeight: 600,
                resizable: true,
                draggable: true
            })
            var url = '/FW/files/file_preview.aspx?f_id=' + f_id + '&height=500&width=500&id_ventana=' + win.getId()
            
            win.setURL(url)
            win.showCenter(true);
        }

        function btnPropiedades_onclick(f_id_sel) {
            if (f_id_sel == undefined) {
                var frm      = $('frmPreview')
                var f_id_sel = frm.contentWindow.f_id_sel
                
                if (f_id_sel == null) {
                    alert("Seleccione el archivo")
                    return
                }
            }

            var win = window.top.nvFW.createWindow({
                title: 'Propiedades',
                url: '/FW/files/file_properties.aspx?f_id=' + f_id_sel,
                width: 600,
                height: 400
            })

            win.showCenter(true)
        }  
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height: 100%; overflow: hidden; background: #FFFFFF;">
    <div id="tbFiltro" style="width:100%">
        <form action="" name="frmFiltro_version">
            <input type='hidden' id='nro_ref' name='nro_ref'/>
	    </form>
    </div>
    <iframe name="iframe_res_busqueda" id="iframe_res_busqueda" style="width:100%; height:100%; overflow:auto; border:none;" src="enBlanco.htm"></iframe>      
</body>
</html>