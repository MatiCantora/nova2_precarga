<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim numero_alarma As String = nvFW.nvUtiles.obtenerValor("numero_alarma", "")
    Dim nro_registro As String = nvFW.nvUtiles.obtenerValor("nro_registro", "")

    Me.contents("filtro_sub_detalle_operaciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_alarmas_movimientos' cn='UNIDATO'><campos>unidato_numero_alarma, tope_tipo,id_tope,tope_def,origen,tipo_periodo,mov_tipo_desc,mov_fecha,anio,cantidad_obtenida,importe_obtenido,tp,cuitcuil,razon_social,calc_tope,tit_razon_social,tit_cuitcuil,tit_cbu,tit_cvu,cont_razon_social,cont_cuitcuil,cont_tp,cont_gran_cliente,cont_tipo_cuenta,cont_cbu,cont_cvu,importe,mes_desc,nro_tope_tipo,ESTADO_SECUENCIA,OBSERVACIONES,SUM(importe) over (PARTITION by unidato_numero_alarma) as total, ID_TIPO_ALARMA, FECHA_ALTA_ALARMA,DIAS_TRANSCURRIDOS</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("numero_alarma") = numero_alarma
    Me.contents("nro_registro") = nro_registro
    Me.contents("filtro_sub_comentario") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro_UnidatoPSP'><campos>nro_entidad,id_tipo,nro_com_id_tipo,nro_com_estado,nro_registro,nro_com_tipo,numero_alarma</campos><filtro></filtro><orden>nro_registro desc</orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Detalle de Alarma</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();

        function window_onload() {
            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu
            Menus["pMenu"].alineacion = 'izquierda';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0' style='width:8%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportar()</Codigo></Ejecutar></Acciones></MenuItem>")
            pMenu.loadImage("excel", "/voii/image/icons/excel.png");
            pMenu.MostrarMenu();

            cargar_detalle();
            window_onresize();
        }

        function window_onresize() {
                let dif = Prototype.Browser.IE ? 10 : 0;
                let body_heigth = $$('body')[0].getHeight();
                let divMenuPrincipal_heigth = $('divMenuPrincipal').getHeight();

                $('ver_detalle').setStyle({ 'height': body_heigth  - divMenuPrincipal_heigth - 8 - dif + 'px' });
        }

        function cargar_detalle() {
            let cantFilas = $('ver_detalle').clientHeight / 2;
            nvFW.bloqueo_activar($('ver_detalle'), 'bloq_carga_detalle', 'Cargando detalle de movimientos...')
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_sub_detalle_operaciones,
                filtroWhere: "<criterio><select PageSize='" + cantFilas.toFixed(0) + "' AbsolutePage='1'><filtro><unidato_numero_alarma type='igual'>" + nvFW.pageContents.numero_alarma + "</unidato_numero_alarma></filtro></select></criterio>",
                path_xsl: "report/unidato/verNv_psp_alarmas_det.xsl",
                formTarget: 'ver_detalle',
                nvFW_mantener_origen: true,
                async: true,
                bloq_contenedor: 'ver_detalle',
                funComplete: function (response, parseError) {
                    nvFW.bloqueo_desactivar($('ver_detalle'), 'bloq_carga_detalle');
                }
            })
        }

        function exportar() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_sub_detalle_operaciones,
                filtroWhere: "<criterio><select><filtro><unidato_numero_alarma type='igual'>" + nvFW.pageContents.numero_alarma + "</unidato_numero_alarma></filtro></select></criterio>",
                path_xsl: "report/EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "detalle_operaciones_alarma" + nvFW.pageContents.numero_alarma + ".xls"
            });
        }

        var winComentario
        function abrirComentario() {
            let nro_registro = nvFW.pageContents.nro_registro;
            let rs = new tRS();
            let filtroWhere = "<numero_alarma type='igual'>'" + nvFW.pageContents.numero_alarma + "'</numero_alarma>";
            if (nro_registro != '')
                filtroWhere += "<nro_registro type='igual'>'" + nro_registro + "'</nro_registro>"
            rs.open(nvFW.pageContents.filtro_sub_comentario, "", filtroWhere)
            if (!rs.eof()) {

                let nro_entidad = rs.getdata("nro_entidad")
                let id_tipo = rs.getdata("id_tipo")
                let nro_com_id_tipo = rs.getdata("nro_com_id_tipo")
                if (nro_registro == '')
                    nro_registro = rs.getdata("nro_registro")
                let nro_com_tipo = rs.getdata("nro_com_tipo")
                let nro_com_estado = rs.getdata("nro_com_estado")
                let w = parent.nvFW != undefined ? parent.nvFW : nvFW

                winCom = nvFW.createWindow({
                    className: 'alphacube',
                    url: '/FW/comentario/ABMRegistro.aspx?nro_entidad=' + nro_entidad + '&id_tipo=' + id_tipo + '&nro_registro_origen=' + nro_registro + '&nro_com_estado_origen=' + nro_com_estado + '&nro_com_id_tipo=' + nro_com_id_tipo + '&nro_com_tipo_origen=' + nro_com_tipo,
                    title: '<b>Alta de Comentario</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    width: 670,
                    height: 450,
                    resizable: true,
                    onClose: Mostrarcomentarios_return
                });
                winCom.showCenter(true);
            }
        }

        function Mostrarcomentarios_return() {
            if (window.top.Windows.getFocusedWindow().returnValue != undefined)
             document.location.reload()
        }
    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>

    <iframe name="ver_detalle" id="ver_detalle" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>

</body>
</html>
