<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Me.contents("filtro_image_validations") = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_image_validations'><campos>cod_image, image_type, datalength(image_binary) as image_size, convert(varchar, moment, 103) as fecha, convert(varchar, moment, 108) as hora, image_content_type, ids_deviceid, is_valid</campos><orden>moment desc</orden></select></criterio>")
%>
<!DOCTYPE html>
<html>
<head>
    <title>Request API Image Validator</title>
    <link href="/FW/css/base.css" rel="stylesheet" type="text/css" />
    <style>
        h1 {
            margin: 0;
            padding: 0.5em 0;
            font-family: serif;
            text-align: center;
            color: #333;
            font-size: 3em;
            background: #1ac31f59;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        function loadCamposDefs()
        {
            // Fecha desde
            var options = {
                nro_campo_tipo: 103,
                enDB: false,
                target: 'tdFeDesde',
                filtroWhere: "<moment type='mas'>convert(datetime, '%campo_value%', 103)</moment>"
            };
            campos_defs.add("fe_desde", options);
            
            // Fecha hasta
            options.target = 'tdFeHasta';
            options.filtroWhere = "<moment type='menor'>dateadd(d, 1, convert(datetime, '%campo_value%', 103))</moment>";
            campos_defs.add("fe_hasta", options);
            
            // ID Dispositivo
            options.target = 'tdIDS_deviceid';
            options.nro_campo_tipo = 104;
            options.filtroWhere = "<ids_deviceid type='like'>%campo_value%</ids_deviceid>";
            campos_defs.add("ids_deviceid", options);
            
            // Cantidad de registros
            options.target = 'tdPageSize';
            options.nro_campo_tipo = 1;
            options.filtroWhere = "";   // No necesitamos el filtroWhere para éste campo
            campos_defs.add("PageSize", options);

            var rs = new tRS();
            rs.addField("id", "string")
            rs.addField("campo", "string")
            rs.addRecord({ "id": "10", "campo": "10" })
            rs.addRecord({ "id": "50", "campo": "50" })
            rs.addRecord({ "id": "100", "campo": "100" })
            rs.addRecord({ "id": "150", "campo": "150" })

            campos_defs.items["PageSize"].rs = rs;
        }



        function windowOnload()
        {
            loadCamposDefs();
            setearFechaDesdeHoy();
            windowOnresize();
            loadRequests();
        }


        function windowOnresize()
        {
            try
            {
                var body_h     = $$('body')[0].getHeight();
                var filtros_h  = $('divFiltros').getHeight();
                var height     = body_h - filtros_h;

                $('frameResult').setStyle({ 'height': height + 'px' });
            }
            catch (e) {}
        }


        function setearFechaDesdeHoy()
        {
            var date = new Date();
            var dia = nvFW.rellenar_izq(date.getDate(), 2, '0');
            var mes = nvFW.rellenar_izq(date.getMonth() + 1, 2, '0');
            var anio = date.getFullYear();
            var fecha_hoy = dia.toString() + '/' + mes + '/' + anio;

            campos_defs.set_value("fe_desde", fecha_hoy);
        }


        function getPageSize()
        {
            var page_size = campos_defs.get_value('PageSize');

            // Si no se seleccionó el tamaño de pagina, determinarlo con el espacio disponible
            if (!page_size)
            {
                var alto_fila      = 23.1;
                var alto_cabecera  = 24;
                var alto_paginador = 21;
                var alto_frame     = $('frameResult').getHeight();

                var cantidad_filas = Math.floor((alto_frame - alto_cabecera - alto_paginador) / alto_fila);
                page_size          = cantidad_filas;
            }

            return page_size;
        }


        function loadRequests()
        {
            var filtroWhere = "<criterio><select PageSize='" + getPageSize() + "' AbsolutePage='1'><filtro>";
            filtroWhere += campos_defs.filtroWhere();
            filtroWhere += "</filtro></select></criterio>";

            var options = {
                filtroXML:            nvFW.pageContents.filtro_image_validations,
                filtroWhere:          filtroWhere,
                path_xsl:             "report/consultas/request_list.xsl",
                formTarget:           "frameResult",
                nvFW_mantener_origen: true,
                bloq_contenedor:      $("frameResult"),
                bloq_msg:             "Cargando solicitudes..."
            };

            nvFW.exportarReporte(options);
        }


        function showImage(cod_image)
        {
            var win = nvFW.createWindow(
            {
                url: "get_image.aspx?cod_image=" + cod_image,
                title: "<b>Imagen enviada</b>",
                minimizable: true,
                maximizable: true,
                resizable: true,
                draggable: true,
                width: 1000,
                height: 750,
                destroyOnClose: true,
                parentHeightPercent: 0.9
            });

            win.options.data = {};
            win.showCenter(true);
        }


        function showInfo(cod_image)
        {
            var win = nvFW.createWindow(
            {
                url: "get_info.aspx?cod_image=" + cod_image,
                title: "<b>Información de la Request</b>",
                minimizable: true,
                maximizable: true,
                resizable: true,
                draggable: true,
                width: 1000,
                height: 750,
                destroyOnClose: true,
                parentHeightPercent: 0.9
            });

            win.options.data = {};
            win.showCenter(true);
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()" style="width: 100%; height: 100%; margin: 0; padding: 0; overflow: hidden;">

    <div id="divFiltros">
        <h1>Listado de solicitudes de pre-validación</h1>

        <table class="tb1">
            <tr class="tbLabel">
                <td>Fecha desde</td>
                <td>Fecha hasta</td>
                <td>ID Dispositivo</td>
                <td>Cantidad de Registros</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td id="tdFeDesde"></td>
                <td id="tdFeHasta"></td>
                <td id="tdIDS_deviceid"></td>
                <td id="tdPageSize"></td>
                <td>
                    <input type="button" name="reload" onclick="loadRequests()" value="Buscar" style="width: 100%; cursor: pointer;" />
                </td>
            </tr>
        </table>
    </div>

    <iframe name="frameResult" id="frameResult" src="../enBlanco.htm" style="width: 100%; height: 75%; border: none;"></iframe>

</body>
</html>
