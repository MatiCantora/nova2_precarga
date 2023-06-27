<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<% 
    Me.contents("estadosDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_estados'><campos>id_dc_estado as id, dc_estado as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("tipoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov_tipos'><campos>dc_mov_tipo as id, dc_mov_tipo_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("dc_mov") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov'><campos>*</campos><filtro></filtro></select></criterio>")
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar CREDIN y DEBIN</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <style type="text/css">
        select:disabled { background-color: #EBEBE4; }
    </style>

    <script type="application/javascript">
        var filtroWhere

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return serchDeb()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("buscar", "/fw/image/icons/buscar.png")
        
        function nuevoCredinDebin(tipo) {
            var title = 'CREDIN'
            if (tipo == 'D') {
                title = 'DEBIN'
            }
            var win_nuevo= top.nvFW.createWindow({
                url: '/voii/debincredin/dc_mov.aspx',
                title: '<b>Nuevo '+ title +'</b>',
                width: 1080,
                height: 600,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })
            win_nuevo.options.userData = { tipo: tipo }

            win_nuevo.showCenter(true)
        }
        
        function editar_mov(credito_cuit, credito_cbu, debito_cuit, debito_cbu, fecha_alta, fecha_estado, estado, tipo, nro_mov, concepto, observacion, moneda, idUsuario, idComprobante, importe, lat, lng, precision, ipCli, tipoDisp, plataforma, sucursal, cuenta_cred, cuenta_deb, dc_id, dc_id_estado, dc_estado, db_addDt, db_fecha_expiracion, puntaje) {
            var title = 'CREDIN'
            if (tipo == 'D') {
                title = 'DEBIN'
            }
            var win_nuevo= top.nvFW.createWindow({
                url: '/voii/debincredin/dc_mov.aspx',
                title: '<b>'+ title +'</b>',
                width: 1080,
                height: 600,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })
            win_nuevo.options.userData = {
                modo: 1,
                tipo: tipo,
                credito_cuit: credito_cuit,
                credito_cbu: credito_cbu,
                debito_cuit: debito_cuit,
                debito_cbu: debito_cbu,
                fecha_alta: fecha_alta,
                fecha_estado: fecha_estado,
                estado: estado,
                observacion: observacion,
                moneda: moneda,
                concepto: concepto,
                idUsuario: idUsuario,
                idComprobante: idComprobante,
                importe: importe,
                lat: lat,
                lng: lng,
                precision: precision,
                ipCli: ipCli,
                tipoDisp: tipoDisp,
                plataforma: plataforma,
                sucursal: sucursal,
                cuenta_cred: cuenta_cred,
                cuenta_deb: cuenta_deb,
                nro_mov: nro_mov,
                dc_id: dc_id,
                dc_id_estado: dc_id_estado,
                dc_estado: dc_estado,
                db_addDt: db_addDt,
                db_fecha_expiracion: db_fecha_expiracion,
                puntaje: puntaje
            }

            win_nuevo.showCenter(true)
        }

        function window_onresize()
        {

        }

        function window_onload()
        {
            vListButton.MostrarListButton()
        }

        function serchDeb() {
            setFiltroWhere()
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.dc_mov,
                filtroWhere: "<criterio><select PageSize='20' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtroWhere + "</filtro></select></criterio>",
                path_xsl: "..\\voii\\report\\credindebin\\credin_debin.xsl",
                formTarget: 'frmResultados',
                nvFW_mantener_origen: true,
                cls_contenedor: 'frmResultados'
            })
        }

        function setFiltroWhere()
        {
            filtroWhere = ''

            if ($('fecha_desde_alta').value != "")
                filtroWhere += "<dc_addDt type='mas'>convert(datetime,'" + $('fecha_desde_alta').value + "',103)</dc_addDt>"

            if ($('fecha_hasta_alta').value != "")
                filtroWhere += "<dc_addDt type='menor'>convert(datetime,'" + $('fecha_hasta_alta').value + "',103)+1</dc_addDt>"

            if ($('fecha_desde_estado').value != "")
                filtroWhere += "<dc_fecha_expiracion type='mas'>convert(datetime,'" + $('fecha_desde_estado').value + "',103)</dc_fecha_expiracion>"

            if ($('fecha_hasta_estado').value != "")
                filtroWhere += "<dc_fecha_expiracion type='menor'>convert(datetime,'" + $('fecha_hasta_estado').value + "',103)+1</dc_fecha_expiracion>"

            if ($('tipo_mov').value != "")
                filtroWhere += "<dc_mov_tipo type='igual'>'" + $('tipo_mov').value + "'</dc_mov_tipo>"

            //if ($('estado').value != "")
            //    filtroWhere += "<id_dc_estado type='igual'>'" + $('estado').value + "'</id_dc_estado>"

            if ($('cbu_credito').value != "")
                filtroWhere += "<credito_cbu type='igual'>'" + $('cbu_credito').value + "'</credito_cbu>"

            if ($('cbu_debito').value != "")
                filtroWhere += "<debito_cbu type='igual'>'" + $('cbu_debito').value + "'</debito_cbu>"

            if ($('cuit_credito').value != "")
                filtroWhere += "<credito_cuit type='igual'>" + $('cuit_credito').value + "</credito_cuit>"

            if ($('cuit_debito').value != "")
                filtroWhere += "<debito_cuit type='igual'>" + $('cuit_debito').value + "</debito_cuit>"

        }
       
        function exportarPDF(objData)
        {
            var _filtroWhere = ""

            if (objData != undefined && typeof objData == "object") {
                _filtroWhere = "<criterio><select><filtro>" + objData.filtroWhere + "</filtro></select></criterio>"
                nro_proceso  = objData.nro_proceso
            }
            else {
                _filtroWhere = "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>"
            }

            nvFW.mostrarReporte({
                filtroXML:           nvFW.pageContents.filtro_exportacion_pdf,
                filtroWhere:         _filtroWhere,
                path_reporte:        "report\\verInstruccionPago\\PDF_instrucciones_pago.rpt",
                salida_tipo:         "adjunto",
                formTarget:          "_blank",
                filename:            "instruccion_pago_" + (nro_proceso != 0 ? nro_proceso : "listado") + ".pdf",
                ContentType:         "application/pdf",
                content_disposition: "inline"
            })

            objData = undefined
            nro_proceso = 0
        }

        function exportarEXCEL()
        {

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.dc_mov,
                filtroWhere: '<criterio><select><filtro>' + filtroWhere + '</filtro></select></criterio>',
                path_xsl: "report\\EXCEL_base.xsl",
                salida_tipo: "adjunto",
                formTarget: "_blank",
                ContentType: "application/vnd.ms-excel",
                filename: "debins_credins.xls"

            })
        }

        function verReferencias()
        {
            var html = $('tbReferencias').innerHTML
            
            var winReferencias = nvFW.createWindow({
                title:          '<b>Referencias</b>',
                width:          200,
                height:         200,
                resizable:      false,
                draggable:      true,
                minimizable:    false,
                maximizable:    false,
                closable:       true,
                destroyOnClose: true
            })

            winReferencias.setHTMLContent(html)
            winReferencias.showCenter()
        }

        function exportarPDFProceso(nro_proceso)
        {
            var objData = {
                "nro_proceso": nro_proceso,
                "filtroWhere": "<nro_proceso type='igual'>" + nro_proceso + "</nro_proceso>"
            }

            return exportarPDF(objData)
        }

    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <div id="divMenu" style="width: 100%; margin: 0; padding: 0;"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu')

        vMenu.loadImage('pdf',   '/FW/image/filetype/pdf.png')
        vMenu.loadImage('excel', '/FW/image/filetype/excel.png')
        vMenu.loadImage('nuevo', '/FW/image/icons/file.png')
        vMenu.loadImage('abm',   '/FW/image/icons/login.png')
        vMenu.loadImage('info',  '/FW/image/icons/info.png')

        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo     = 'A';

        //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>info</icono><Desc>Referencias</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verReferencias()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>pdf</icono><Desc>Exportar PDF</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarPDF()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar Excel</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarEXCEL()</Codigo></Ejecutar></Acciones></MenuItem>")
        //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Entidad ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abrirEntidadABM()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo DEBIN</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevoCredinDebin('D')</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo CREDIN</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevoCredinDebin('C')</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu.MostrarMenu()
    </script>
    
<table class="tb1" >
  <tr>
   <td style="width: 93%">
        
    <table class="tb1" id="tblFiltros">
        <tr class="tbLabel">
            <td style="text-align: center;">Tipo Movimiento</td>
            <td style="text-align: center;" colspan="2">Fecha Alta</td>
            <td style="text-align: center;" colspan="2">Fecha Expiración</td>
            <td style="text-align: center;">Estado</td>
        </tr>
        <tr>
            <td style="width: 120px;">
                <script type="text/javascript">
                    campos_defs.add('tipo_mov', {
                        enDB: false,
                        nro_campo_tipo: 1,
                        filtroXML: nvFW.pageContents.tipoDef
                    })
                </script>
            </td>
            <td style="width: 120px">
                <script type="text/javascript">
                    campos_defs.add('fecha_desde_alta', { enDB: false, nro_campo_tipo: 103, placeholder: 'desde' })
                </script>
            </td>
            <td style="width: 120px">
                <script type="text/javascript">
                    campos_defs.add('fecha_hasta_alta', { enDB: false, nro_campo_tipo: 103, placeholder: 'hasta' })
                </script>
            </td>
            <td style="width: 120px">
                <script type="text/javascript">
                    campos_defs.add('fecha_desde_estado', { enDB: false, nro_campo_tipo: 103, placeholder: 'desde' })
                </script>
            </td>
            <td style="width: 120px">
                <script type="text/javascript">
                    campos_defs.add('fecha_hasta_estado', { enDB: false, nro_campo_tipo: 103, placeholder: 'hasta' })
                </script>
            </td>
            <td style="width: 120px;">
                <script type="text/javascript">
                    campos_defs.add('estado', {
                        enDB: false,
                        nro_campo_tipo: 2,
                        filtroXML: nvFW.pageContents.estadosDef
                    })
                </script>
            </td>
        </tr>
     </table>
     <table class="tb1">
        <tr  class="tbLabel">
            <td style="text-align: center;">Entidad Debito</td>
            <td style="text-align: center;">CBU Debito</td>
            <td style="text-align: center;">Entidad Credito</td>
            <td style="text-align: center;">CBU Credito</td>
        </tr>
        <tr>
            <td style="width: 25%;">
                <input style="width: 100%" type="text" id="cuit_debito" />
            </td>
            <td style="width: 25%;">
                <input style="width: 100%" type="text" id="cbu_debito" />
            </td>
            <td style="width: 25%;">
                <input style="width: 100%" type="text" id="cuit_credito" />
            </td>
            <td style="width: 25%;">
                <input style="width: 100%" type="text" id="cbu_credito" />
            </td>
        </tr>
    </table>
   </td>
   <td style="width: 7%">
    <div id="divBuscar"></div>
   </td>
 </tr>
</table>
<br />  
    <iframe name="frmResultados" id="frmResultados" style="width: 100%; height:100%; max-height:448px" frameborder='0'></iframe>
</body>
</html>
