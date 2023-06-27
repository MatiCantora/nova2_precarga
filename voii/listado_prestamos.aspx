<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")
    Dim strTabla As String = ""
    Dim err As New tError

    If cuit <> "" Then
        Me.contents("filtro_prestamos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_prestamos' cn='BD_IBS_ANEXA'><campos>paiscod, bcocod, succod, sistcod, codsubsist, moncod, monsimbolo, cuecod, openro, nroreferencia, fecori, importpact, cancuocap, estoperdesc, prodnom, periodo, plansint</campos><filtro><nrodoc type='igual'>" & cuit & "</nrodoc></filtro><orden>fecori ASC</orden></select></criterio>")
        Me.contents("filtro_prestamosExcel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_prestamos' cn='BD_IBS_ANEXA'><campos>(CONVERT(VARCHAR(5), paiscod) + '-' + CONVERT(VARCHAR(5), bcocod) + '-' + CONVERT(VARCHAR(5), succod) + '-' + CONVERT(VARCHAR(5), sistcod) + '-' + CONVERT(VARCHAR(5), codsubsist) + '-' + CONVERT(VARCHAR(5), moncod) + '-' + CONVERT(VARCHAR(10), cuecod) + '-' + CONVERT(VARCHAR(10), openro)) AS nro_prestamo, nroreferencia, CONVERT(DATETIME, fecori, 103) AS fecori, importpact, cancuocap, estoperdesc, prodnom, periodo, plansint</campos><filtro><nrodoc type='igual'>" & cuit & "</nrodoc></filtro><orden>fecori ASC</orden></select></criterio>")
    Else
        Me.contents("filtro_prestamos") = ""
        err.numError = 100
        err.titulo = "No hay CUIT"
        err.mensaje = "No se encontro un CUIT en los valores requeridos para realizar la operación."
        err.response()
    End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Listado de Prestamos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var $body
        var $tbFiltro
        var $framePrestamos

        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"]   = "Filtrar";
        vButtonItems[0]["etiqueta"] = "Filtrar";
        vButtonItems[0]["imagen"]   = "filtro";
        vButtonItems[0]["onclick"]  = "return cargarPrestamos()";

        vButtonItems[1] = []
        vButtonItems[1]["nombre"]   = "Limpiar";
        vButtonItems[1]["etiqueta"] = "Limpiar";
        vButtonItems[1]["imagen"]   = "limpiar";
        vButtonItems[1]["onclick"]  = "return limpiarFiltros()";
  
        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("filtro", "/voii/image/icons/filtro.png")
        vListButton.loadImage("limpiar", "/FW/image/icons/eliminar.png")


        function window_onload()
        {
            vListButton.MostrarListButton()

            $body           = $$('body')[0]
            $tbFiltro       = $('tbFiltro')
            $framePrestamos = $('framePrestamos')

            window_onresize()
            nvFW.bloqueo_desactivar(null, 'bloq_prestamos')
            cargarPrestamos()
        }


        function window_onresize()
        {
            try {
                var body_h     = $body.getHeight()
                var tbFiltro_h = $tbFiltro.getHeight()
                
                $framePrestamos.style.height = body_h - tbFiltro_h + 'px'
            }
            catch(e) {}
        }


        function cargarPrestamos()
        {
            if (nvFW.pageContents.filtro_prestamos == '') {
                alert('Ocurrio un error al intentar cargar los prestamos debido a que no hay un CUIT presente.')
                return
            }
            else {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_prestamos,
                    filtroWhere: getFiltros(),
                    formTarget: 'framePrestamos',
                    path_xsl: 'report/verPrestamos/HTML_listado_prestamos.xsl',
                    cls_contenedor: 'framePrestamos',
                    cls_contenedor_msg: ' ',
                    bloq_contenedor: $('framePrestamos'),
                    bloq_msg: 'Cargando prestamos...',
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0
                })
            }
        }


        function limpiarFiltros()
        {
            campos_defs.clear('openro')
            campos_defs.clear('nroreferencia')
            campos_defs.clear('fecori_desde')
            campos_defs.clear('fecori_hasta')
            campos_defs.clear('importpact_min')
            campos_defs.clear('importpact_max')
            campos_defs.clear('estoperdesc')

            cargarPrestamos()
        }


        function getFiltros()
        {
            // Armar el filtro Where
            var filtro = ''

            // Número de operación
            if (campos_defs.get_value('openro') != '')
                filtro += '<openro type="igual">' + campos_defs.get_value('openro') + '</openro>'

            // Número de referencia
            if (campos_defs.get_value('nroreferencia') != '')
                filtro += '<nroreferencia type="igual">"' + campos_defs.get_value('nroreferencia') + '"</nroreferencia>'

            // Fecha originación desde
            if (campos_defs.get_value('fecori_desde') != '')
                filtro += '<fecori type="mas">CONVERT(DATETIME, "' + campos_defs.get_value('fecori_desde') + '", 103)</fecori>'

            // Fecha originación hasta
            if (campos_defs.get_value('fecori_hasta') != '')
                filtro += '<fecori type="menor">DATEADD(dd, 1, CONVERT(DATETIME, "' + campos_defs.get_value('fecori_hasta') + '", 103))</fecori>'

            // Importe mínimo
            if (campos_defs.get_value('importpact_min') != '')
                filtro += '<importepact type="mas">' + campos_defs.get_value('importpact_min') + '</importepact>'

            // Importe máximo
            if (campos_defs.get_value('importpact_max') != '')
                filtro += '<importepact type="menor">' + campos_defs.get_value('importpact_max') + '</importepact>'

            // Estado de Operación
            if (campos_defs.get_value('estoperdesc') != '')
                filtro += '<estoperdesc type="like">%' + campos_defs.get_value('estoperdesc') + '%</estoperdesc>'

            return filtro
        }


        function verPrestamo(evento, nro_operacion)
        {
            var url_destino = '/voii/cargar_prestamo.aspx?cuit=<% = cuit %>&id_prestamo=' + nro_operacion

            // Abrir datos según modificadores (Ctrl | Shift)
            if (evento.ctrlKey) {
                // Nueva pestaña
                window.open(url_destino)
            }
            else if (evento.shiftKey) {
                // Nueva ventana de browser
                var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                newWin.moveTo(0, 0)
                newWin.resizeTo(screen.availWidth, screen.availHeight)
            }
            else {
                // Ventana flotante NO-modal. Comportamiento por defecto
                var win_prestamo = top.nvFW.createWindow({
                    url: url_destino,
                    title: '<b>Préstamo Nº ' + nvFW.replace(nro_operacion, '-', '') + '</b>',
                    width: 1024,
                    height: 500,
                    destroyOnClose: true
                })

                win_prestamo.show()
            }
        }


        function fechaTimestamp() {
            var f = new Date()
            var anio
            var mes
            var dia
            var hora
            var minuto
            var segundo

            // Año
            anio = f.getFullYear().toString()

            // Mes
            mes = f.getMonth() + 1
            if (mes < 10)
                mes = '0' + mes

            // Dia
            dia = f.getDate()
            if (dia < 10)
                dia = '0' + dia

            // Horas
            hora = f.getHours()
            if (hora < 10)
                hora = '0' + hora

            // Minutos
            minuto = f.getMinutes()
            if (minuto < 10)
                minuto = '0' + minuto

            // Segundos
            segundo = f.getSeconds()
            if (segundo < 10)
                segundo = '0' + segundo

            return anio + mes + dia + hora + minuto + segundo
        }


        function exportListado()
        {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_prestamosExcel,
                filtroWhere: getFiltros(),
                path_xsl: 'report/EXCEL_base.xsl',
                salida_tipo: 'adjunto',
                formTarget: 'frameExcel',
                ContentType: 'application/vnd.ms-excel',
                export_exception: 'RSXMLtoExcel',
                filename: 'listado_prestamos_<% = cuit %>_' + fechaTimestamp() + '.xls',
                parametros: '<parametros><columnHeaders><table><tr><td>Nro. Préstamo</td><td>Nro. Referencia</td><td>Fe. Originación</td><td>Importe</td><td>Cuotas</td><td>Estado</td><td>Producto</td><td>Período</td><td>Plan</td></tr></table></columnHeaders></parametros>'
            })
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <script>nvFW.bloqueo_activar($$('body')[0], 'bloq_prestamos', 'Cargando prestamos...')</script>
    
    <table class="tb1" cellspacing="0" cellpadding="0" id="tbFiltro">
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 170px; text-align: center;">Nro Operación</td>
                        <td style="width: 170px; text-align: center;">Nro Referencia</td>
                        <td style="text-align: center;" colspan="2">Fecha Originación</td>
                        <td style="text-align: center;" colspan="2">Importe</td>
                        <td style="text-align: center;">Estado Operación</td>
                    </tr>
                    <tr>
                        <td style="width: 170px;"><% = nvFW.nvCampo_def.get_html_input("openro", enDB:=False, nro_campo_tipo:=100) %></td>
                        <td style="width: 170px;"><% = nvFW.nvCampo_def.get_html_input("nroreferencia", enDB:=False, nro_campo_tipo:=100) %></td>
                        <td style="width: 170px;"><% = nvFW.nvCampo_def.get_html_input("fecori_desde", enDB:=False, nro_campo_tipo:=103) %></td>
                        <td style="width: 170px;"><% = nvFW.nvCampo_def.get_html_input("fecori_hasta", enDB:=False, nro_campo_tipo:=103) %></td>
                        <td style="width: 170px;"><% = nvFW.nvCampo_def.get_html_input("importpact_min", enDB:=False, nro_campo_tipo:=102) %></td>
                        <td style="width: 170px;"><% = nvFW.nvCampo_def.get_html_input("importpact_max", enDB:=False, nro_campo_tipo:=102) %></td>
                        <td><% = nvFW.nvCampo_def.get_html_input("estoperdesc", enDB:=False, nro_campo_tipo:=104) %></td>
                    </tr>
                </table>
            </td>
            <td style="width: 300px;">
                <table class="tb1">
                    <tr>
                        <td style="width: 50%;">
                            <div id="divFiltrar">Filtrar</div>
                        </td>
                        <td style="width: 50%;">
                            <div id="divLimpiar">Limpiar</div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <iframe id="framePrestamos" name="framePrestamos" style="width: 100%; height: 150px; border: none; overflow: hidden;" src="enBlanco.htm"></iframe>
    <iframe id="frameExcel" name="frameExcel" style="display: none"></iframe>

</body>
</html>
