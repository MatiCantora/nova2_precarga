<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    '----------------------------------------------------------------
    ' Filtros Encriptados
    '----------------------------------------------------------------
    Me.contents("filtro_nro_tipo_comision") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verVend_comision_liquidacion'><campos>distinct id_liquidacion AS id, abreviacion AS [campo]</campos><orden>id desc</orden></select></criterio>")
    Me.contents("filtro_tipo_pago") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_tipos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_ctrl_fondos_cheques") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden></orden><filtro><nro_pago_tipo type='igual'>6</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    'Me.contents("filtro_aceptar_10") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_pg_registro_agrupados_reintegros' vista='wrp_pg_registro_agrupados'><parametros><nro_envios DataType='varchar'>%nro_envios%</nro_envios><nro_creditos DataType='varchar'>%nro_creditos%</nro_creditos><nro_entidad DataType='int'>%nro_entidad%</nro_entidad><nro_pago_conceptos DataType='varchar'>%nro_pago_conceptos%</nro_pago_conceptos><pendientes DataType='varchar'>%pendientes%</pendientes><suspendidos>%suspendidos%</suspendidos><nro_mutual DataType='int'>%nro_mutual%</nro_mutual><fe_descuento DataType='datetime'>%fe_descuento%</fe_descuento><numeros>%numeros%</numeros><fecha_presentacion DataType='datetime'>%fecha_presentacion%</fecha_presentacion><id_liquidacion DataType='int'>%id_liquidacion%</id_liquidacion><nro_entidad_pago DataType='int'>%nro_entidad_pago%</nro_entidad_pago><nro_proceso DataType='int'>%nro_proceso%</nro_proceso><orden>%orden%</orden></parametros></procedure></criterio>")
    Me.contents("filtro_aceptar_10") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_pg_registro_agrupados_reintegros' vista='wrp_pg_registro_agrupados'><parametros><nro_envios DataType='varchar'>%nro_envios%</nro_envios><nro_creditos DataType='varchar'>%nro_creditos%</nro_creditos><nro_entidad DataType='int'>%nro_entidad%</nro_entidad><nro_pago_conceptos DataType='varchar'>%nro_pago_conceptos%</nro_pago_conceptos><pendientes DataType='varchar'>%pendientes%</pendientes><suspendidos>%suspendidos%</suspendidos><nro_mutual DataType='int'>%nro_mutual%</nro_mutual><fe_descuento DataType='datetime'>%fe_descuento%</fe_descuento><numeros>%numeros%</numeros><fecha_presentacion DataType='datetime'>%fecha_presentacion%</fecha_presentacion><id_liquidacion DataType='int'>%id_liquidacion%</id_liquidacion><nro_entidad_pago DataType='int'>%nro_entidad_pago%</nro_entidad_pago><nro_proceso DataType='int'>%nro_proceso%</nro_proceso></parametros></procedure></criterio>")
    Me.contents("filtro_aceptar_17") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_pg_registro_agrupados_2'><parametros><nro_envios DataType='varchar'>%nro_envios%</nro_envios><nro_creditos DataType='varchar'>%nro_creditos%</nro_creditos><nro_entidad DataType='int'>%nro_entidad%</nro_entidad><nro_pago_conceptos DataType='varchar'>%nro_pago_conceptos%</nro_pago_conceptos><pendientes DataType='varchar'>%pendientes%</pendientes><suspendidos>%suspendidos%</suspendidos><nro_mutual DataType='int'>%nro_mutual%</nro_mutual><fe_descuento DataType='datetime'>%fe_descuento%</fe_descuento><numeros>%numeros%</numeros><fecha_presentacion DataType='datetime'>%fecha_presentacion%</fecha_presentacion><id_liquidacion DataType='int'>%id_liquidacion%</id_liquidacion><nro_entidad_pago DataType='int'>%nro_entidad_pago%</nro_entidad_pago><orden>%orden%</orden></parametros></procedure></criterio>")

    Me.contents("filtro_pago_registro_agrupados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_registro_agrupados'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_pago_registro_lineal") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPG_Registro_lineal'><campos>origen, destino, fe_estado, pago_tipo_orig, pago_tipo, pago_estados, login, nombre_operador, pago_concepto, ISO_cod, importe_pago, nro_pago_registro</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_pagos_envios") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>convert(float, nro_cheque) AS nro_cheque01, *</campos><orden>nro_cheque01 ASC</orden><filtro><nro_pago_estado type='in'>2, 4, 5</nro_pago_estado><nro_pago_tipo type='in'>1, 6, 8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    Me.contents("filtro_pago_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>distinct convert(float,nro_cheque) as nro_cheque01, *</campos><orden>nro_cheque01 asc</orden><filtro><nro_pago_estado type='in'>2,4,5</nro_pago_estado><nro_pago_tipo type='in'>1,4,6,8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    Me.contents("filtro_recibo_fondos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden>nro_pago_registro</orden><filtro><nro_pago_estado type='in'>2, 4, 5</nro_pago_estado><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    Me.contents("filtro_nro_pago_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_detalle</campos><filtro><nro_pago_estado type='in'>2, 4, 5</nro_pago_estado><nro_pago_concepto type='igual'>10</nro_pago_concepto></filtro></select></criterio>")
    Me.contents("filtro_recibos_reintegros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verReintegros'><campos>*</campos></select></criterio>")
    Me.contents("filtro_control_envios") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_PG_CREDITO_ENVIOS'><campos>*</campos><orden>nro_credito</orden></select></criterio>")
    Me.contents("filtro_cargar_concepto") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_conceptos'><campos>*</campos></select></criterio>")
    Me.contents("filtro_control_pagos_excel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>DISTINCT pago_concepto, pago_tipo, pago_estados, CASE WHEN NOT dep_cuenta_desc IS NULL THEN ISNULL(dep_cuenta_desc, '') ELSE '' END AS cuenta, CASE WHEN NOT nro_cheque IS NULL THEN nro_cheque ELSE '' END AS cheque, razon_social AS destinatario, documento, nro_docu, strnombrecompleto, nro_envio, nro_envio_gral, nro_credito, mutual, banco, importe_bruto, importe_neto, importe_pago, ISNULL(fe_estado, '') AS fecha_estado</campos><filtro><nro_pago_estado type='in'>1, 2, 4, 5</nro_pago_estado><nro_pago_tipo type='in'>1, 4, 6, 8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    Me.contents("filtro_pagos_generico") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_registro, nro_credito, nro_envio, nro_envio_gral, importe_pago, nro_entidad, razon_social, CASE WHEN MUTUAL = 'ASOCIACION MUTUAL UNION SOLIDARIA' THEN 'AMUS' ELSE MUTUAL END AS mutual, COUNT(*) AS detalle, CONTAR AS contar, pago_concepto, fecha</campos><filtro><estado_envio type='igual'>'F'</estado_envio></filtro><grupo>nro_pago_registro, nro_credito, nro_envio, nro_envio_gral, importe_pago, nro_entidad, razon_social, MUTUAL, CONTAR, pago_concepto, fecha</grupo><orden>fecha, nro_pago_registro</orden></select></criterio>")

    Me.contents("filtro_pago_estados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_estados'><campos>nro_pago_estado as id, pago_estados as campo</campos><orden>campo</orden><filtro><nro_pago_estado type='in'>1,7</nro_pago_estado></filtro></select></criterio>")
    '----------------------------------------------------------------
    ' Permisos
    '----------------------------------------------------------------
    Me.addPermisoGrupo("procesos_ref_grupos")
    Me.contents("today") = DateTime.Today.ToString("dd/MM/yyyy")


    Dim path_filtros As String = "/" + nvFW.nvApp.getInstance.path_rel + "/Pagos/pg_filtros.aspx"

    If Not System.IO.File.Exists(HttpContext.Current.Server.MapPath(path_filtros)) Then
        path_filtros = "/FW/enBlanco.htm"
    End If
    Me.contents("path_filtros") = path_filtros

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Pagos Selección</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win
        var inCredito
        var Parametros = {}
        var frmFiltros

        // Botones
        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return Aceptar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", "/FW/image/icons/buscar.png")

        // variable para determinar si necesitamos aplicar filtros extras (credito, muper, comercio, reintegro)
        var aplicar_filtros_extras = false
        var filtro = null
        var str_filtro_where = ''
        var flagOnload = false
        var iframeExportar = 'ifrRegistros'

        function getStrTime() {
            var fecha = new Date()

            var year = fecha.getUTCFullYear().toString()
            var imonth = fecha.getUTCMonth() + 1     // Meses desde 1 a 12
            var month = imonth < 10 ? "0" + imonth : imonth
            var idia = fecha.getUTCDate()
            var day = idia < 10 ? "0" + idia : idia
            var ihoras = fecha.getHours()
            var horas = ihoras < 10 ? "0" + ihoras : ihoras
            var iminutos = fecha.getMinutes()
            var minutos = iminutos < 10 ? "0" + iminutos : iminutos
            var isegundos = fecha.getSeconds()
            var segundos = isegundos < 10 ? "0" + isegundos : isegundos
            var milesimas = fecha.getMilliseconds()

            return year + month + day + horas + minutos + segundos + milesimas
        }


        function window_onload() {

            //iframe con filtros dinamicos
            frmFiltros = ObtenerVentana('frameFiltros')
            frmFiltros.location.href = nvFW.pageContents.path_filtros
            flagOnload = true

        }


        function frmOnload() {

            if (flagOnload) {

                if (typeof frmFiltros.getIframe == 'function') {
                    iframeExportar = frmFiltros.getIframe()
                    $('frameFiltros').show()
                    $('ifrRegistros').hide()
                    //$('divBuscar').hide()
                    $('btnBuscar').hide()
                }

                // Mostrar botones creados
                vListButtons.MostrarListButton()
                if (typeof frmFiltros.CargarTipo_Pago == 'function')
                    frmFiltros.CargarTipo_Pago()
                //campos_defs.habilitar('nro_mutual', false)
                campos_defs.items['nro_pago_conceptos']['onchange'] = nro_pago_concepto_onchange
                //campos_defs.habilitar('nro_proceso', true)


                //$('filtroConcepto').value = '0'
                //$('filtroConcepto').onchange()
                campos_defs.set_value('nro_pg_filtro', 0)

                campos_defs.set_value('fecha_desde', nvFW.pageContents.today)
                campos_defs.set_value('nro_pago_estado', 1)

                window_onresize()
            }
        }


        function nro_pago_concepto_onchange() {

            var nro_pago_conceptos = $('nro_pago_conceptos').value
            //var $filtroConcepto = $('nro_pg_filtro')
            var nro_pg_filtro = campos_defs.get_value('nro_pg_filtro')

            switch (nro_pago_conceptos) {
                // Comercio MUPER
                case '16':
                    // setear el filtro en 'Comercio Muper'
                    if (nro_pg_filtro != 1) {
                        campos_defs.set_value('nro_pg_filtro', 1)
                    }

                    break

                // Comisión
                case '17':
                    // setear el filtro en 'Comision'
                    if (nro_pg_filtro != 2) {
                        campos_defs.set_value('nro_pg_filtro', 2)
                    }

                    break

                // Reintegro
                case '10':
                    // setear el filtro en 'Reintegro'
                    if (nro_pg_filtro != 3) {
                        campos_defs.set_value('nro_pg_filtro', 3)
                    }

                    break

                default:
                    if (nro_pg_filtro != '' && nro_pg_filtro != 0) {
                        campos_defs.set_value('nro_pg_filtro', '')
                    }

                    break
            }

            window_onresize()
        }


        var parametros = {}
        var win_pagos


        function editarPago(nro_tipo_pago) { // Llama la modal para editar los pagos
            parametros["nro_pago_registro"] = nro_tipo_pago
            win_pagos = window.top.nvFW.createWindow({
                title: '<b>ABM Pagos</b>',
                url: '/FW/pagos/Pagos_ABM.aspx',
                minimizable: false,
                maximizable: false,
                draggable: true,
                closable: true,
                width: 950,
                height: 500,
                resizable: true,
                onClose: editarPago_return,
                destroyOnClose: true
            });

            win_pagos.options.userData = { parametros: parametros }
            win_pagos.showCenter(true)
        }


        function editarPago_return() {
            var retorno = win_pagos.options.userData.parametros

            if (retorno['importe_pago'] != undefined)
                setTimeout('Aceptar()', 200)
        }


        function DetalleEnvios() {
            var filtro_envio = ""
            var ele

            for (var i = 0; ele = iframe1.document.all.frmEnvios.elements[i]; i++) {
                if (ele.type == 'checkbox')
                    if (ele.name != 'all') {
                        if (ele.checked) {
                            if (filtro_envio == "")
                                filtro_envio = ele.value;
                            else
                                filtro_envio = filtro_envio + "," + ele.value;
                        }
                    }
            }

            if (filtro_envio == "")
                alert("No ha seleccionado ningun Envio")
            else {
                Parametros["filtro_envio"] = filtro_envio

                var winDetalleEnvios = nvFW.createWindow({
                    title: "<b>Detalles de Envíos</b>",
                    url: "/meridiano/Pagos_distribucion.aspx",
                    width: 840,
                    height: 560,
                    destroyOnClose: true
                })

                winDetalleEnvios.options.userData = { Parametros: Parametros }
                winDetalleEnvios.showCenter(true)
            }
        }


        var strparametros = ''


        function Aceptar(orden) {
            var mensaje = Validar_Filtro()
            var path_xsl

            if (mensaje) {
                alert('Debe seleccionar alguno de los siguientes filtros:<br/><br/>' + mensaje, { title: '<b>Selección de filtros</b>', width: 450, height: 150 })
                return
            }

            if (typeof orden != "string" || orden == "")
                orden = "nro_credito"
            if (campos_defs.get_value('tipo_vista') == 1) {
                if ($('nro_pago_conceptos').value == 10) {
                    nvFW.exportarReporte({
                        //filtroXML: "<criterio><procedure CommandText='dbo.rm_pg_registro_agrupados_reintegros' vista='wrp_pg_registro_agrupados'><parametros>" + strparametros + "<orden>nro_credito</orden></parametros></procedure></criterio>",
                        //filtroXML:            nvFW.pageContents.filtro_aceptar_10,
                        filtroXML: nvFW.pageContents.filtro_pago_registro_agrupados,
                        //filtroWhere:          '<criterio><procedure><parametros><select><orden>nro_credito</orden></select></parametros></procedure></criterio>',
                        filtroWhere: '<criterio><select><orden>nro_credito</orden><filtro>' + str_filtro_where + '</filtro></select></criterio>',
                        //params:               '<criterio>' + strparametros + '/></criterio>',
                        path_xsl: 'report/wrp_pg_registro_agrupados/HTML_registros_pagos_reintegros.xsl',
                        formTarget: iframeExportar,
                        nvFW_mantener_origen: true,
                        id_exp_origen: 0,
                        cls_contenedor: iframeExportar,
                        cls_contenedor_msg: ' ',
                        bloq_contenedor: $$('body')[0],
                        bloq_msg: 'Cargando...'
                    })
                }
                else {
                    if ($('nro_pago_conceptos').value == 17)
                        path_xsl = "report/wrp_pg_registro_agrupados/HTML_registros_pagos_comisiones.xsl"
                    else
                        path_xsl = "report/wrp_pg_registro_agrupados/HTML_registros_pagos.xsl"

                    nvFW.exportarReporte({
                        //filtroXML: "<criterio><procedure CommandText='dbo.rm_pg_registro_agrupados_2'><parametros>" + strparametros + "<orden>nro_credito</orden></parametros></procedure></criterio>",
                        //filtroXML:            nvFW.pageContents.filtro_aceptark_17,
                        filtroXML: nvFW.pageContents.filtro_pago_registro_agrupados,
                        filtroWhere: '<criterio><select><orden>' + orden + '</orden><filtro>' + str_filtro_where + '</filtro></select></criterio>',
                        //params:               '<criterio>' + strparametros + ' orden="' + orden + '" /></criterio>',
                        path_xsl: path_xsl,
                        //formTarget: 'ifrRegistros',
                        formTarget: iframeExportar,
                        nvFW_mantener_origen: true,
                        id_exp_origen: 0,
                        //cls_contenedor: 'ifrRegistros',
                        cls_contenedor: iframeExportar,
                        cls_contenedor_msg: ' ',
                        bloq_contenedor: $$('body')[0],
                        bloq_msg: 'Cargando...'
                    })
                }
            } else {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_pago_registro_lineal,
                    filtroWhere: '<criterio><select><orden>' + orden + '</orden><filtro>' + str_filtro_where + '</filtro></select></criterio>',
                    path_xsl: "report/wrp_pg_registro_agrupados/HTML_registros_pagos_lineal.xsl",
                    formTarget: iframeExportar,
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0,
                    cls_contenedor: iframeExportar,
                    cls_contenedor_msg: ' ',
                    bloq_contenedor: $$('body')[0],
                    bloq_msg: 'Cargando...'
                })
            }
        }


        function Validar_Filtro() {
            var mensaje = ''
            var mensaje_genericos = ''
            var str_filtro_entidad_fecha = ''
            str_filtro_where = ''

            /*----------------------------------------------------------------- 
            | Filtros genéricos
            |------------------------------------------------------------------
            |   Nombre campo                    |   Tipo
            |------------------------------------------------------------------
            |   * nro_entidad                   |   campo_def 3
            |   * nro_pago_conceptos            |   campo_def 2
            |   * chk_pendientes                |   input checkbox
            |   * chk_suspendidos               |   input checkbox
            |   * fecha_desde                   |   campo_def 103
            |   * fecha_hasta                   |   campo_def 103
            |------------------------------------------------------------------
            | NOTA:
            |       el filtro de entidad y fecha_desde puede ir combinado con
            |       alguno de los filtros extra; por lo tanto se los lleva por
            |       separado hasta juntar todos los filtros al final.
            |----------------------------------------------------------------*/
            var nro_entidad = campos_defs.get_value('nro_entidad')

            if (nro_entidad) {
                str_filtro_entidad_fecha += '<nro_entidad type="igual">' + nro_entidad + '</nro_entidad>'
            }

            if (campos_defs.get_value('nro_pago_conceptos')) {
                str_filtro_where += '<nro_pago_concepto type="in">' + campos_defs.get_value('nro_pago_conceptos') + '</nro_pago_concepto>'
            }

            if (campos_defs.get_value('tipo_vista') == 1) {
                var estados = campos_defs.get_value('nro_pago_estado').replace(/ /g, '').split(",")
                //if ($('chk_pendientes').checked) {
                if (estados.indexOf("1") > -1) {
                    str_filtro_where += '<pagos_pendientes type="mayor">0</pagos_pendientes>'
                }

                //if ($('chk_suspendidos').checked) {
                if (estados.indexOf("7") > -1) {
                    str_filtro_where += '<pagos_suspendidos type="mayor">0</pagos_suspendidos>'
                }
            } else {
                if (campos_defs.get_value('nro_pago_estado') != '')
                    str_filtro_where += '<nro_pago_estado type="in">' + campos_defs.get_value('nro_pago_estado') + '</nro_pago_estado>'
            }

            var fecha_desde = campos_defs.get_value('fecha_desde')

            if (fecha_desde) {
                str_filtro_entidad_fecha += '<fecha type="mas">convert(datetime, \'' + fecha_desde + '\', 103)</fecha>'
            }

            if (campos_defs.get_value('fecha_hasta')) {
                str_filtro_where += '<fecha type="menor">dateadd(dd, 1, convert(datetime, \'' + campos_defs.get_value('fecha_hasta') + '\', 103))</fecha>'
            }

            // Comprobar si Razon Social o Fecha desde están presentes
            if (!str_filtro_entidad_fecha) {
                mensaje_genericos += '<b>Genéricos: </b>Razón Social, Fecha desde<br/>'
                mensaje = mensaje_genericos
            }

            if (!aplicar_filtros_extras) {
                str_filtro_where = str_filtro_entidad_fecha + str_filtro_where
                return mensaje
            }
            else {
                if (typeof frmFiltros.getFiltros == 'function') {
                    var rtrnFiltro = frmFiltros.getFiltros(filtro, mensaje_genericos, str_filtro_entidad_fecha, fecha_desde)
                    str_filtro_where += rtrnFiltro.filtroWhere
                    mensaje = rtrnFiltro.mensaje
                    return mensaje
                }
            }
        }


        function valDigito_fecha(strCaracteres) {
            if (event.keyCode == 13) {
                event.keyCode = 0
                Aceptar()
            }
        }


        var win_chequera
        var win_depositos
        var win_efectivo
        var win_giro


        function CargarConcepto() {
            var rs = new tRS();
            var cb = document.all.cbConcepto

            cb.options.length = 0
            cb.options.length++
            cb.options[cb.options.length - 1].value = 0
            cb.options[cb.options.length - 1].text = "-- TODOS --"

            //rs.open("<criterio><select vista='pago_conceptos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
            rs.open({ filtroXML: nvFW.pageContents.filtro_cargar_concepto })

            while (!rs.eof()) {
                cb.options.length++
                cb.options[cb.options.length - 1].value = rs.getdata('nro_pago_concepto')
                cb.options[cb.options.length - 1].text = rs.getdata('pago_concepto')
                rs.movenext()
            }
        }



        function transferencia_ejecutar(id_transferencia, xml_param) {
            debugger
            if (nvFW.tienePermiso("procesos_ref_grupos", 12)) {     // 12: Interbanking
                window.top.nvFW.transferenciaEjecutar({
                    id_transferencia: id_transferencia,
                    xml_param: xml_param,
                    pasada: 0,
                    formTarget: 'winPrototype',
                    async: false,
                    ej_mostrar: true,
                    winPrototype: {
                        modal: true,
                        center: true,
                        bloquear: false,
                        url: '/FW/enBlanco.htm',
                        title: '<b>Transferencia Interbanking</b>',
                        minimizable: false,
                        maximizable: true,
                        draggable: true,
                        width: 800,
                        height: 400,
                        resizable: true,
                        destroyOnClose: true
                    }
                })
            }
            else {
                alert('No posee los permisos necesarios para realizar esta acción')
                return
            }
        }


        function alta_cuenta_interbanking_por_lote() {
            nvFW.confirm('¿Desea generar los archivos de alta para Interbanking por lote?',
                {
                    width: 350,
                    okLabel: "Si",
                    cancelLabel: "No",
                    onOk: function (win) {
                        transferencia_ejecutar(909, '')
                        win.close()
                    },
                    onCancel: function (win) {
                        win.close()
                        return
                    }
                });
        }


        function window_onresize() {
            try {
                var body_h = $$("body")[0].getHeight()
                var divMenuPagos_h = $('divMenuPagos').getHeight()
                var filtro1_h = $("filtro1").getHeight()
                //var filtro2_h        = $("filtro2").getHeight()
                var filtro2_h = 0
                var btnBuscar_h = $("btnBuscar").getHeight()
                if (typeof frmFiltros.getTamanio == 'function') {
                    filtro2_h = frmFiltros.getTamanio()
                    btnBuscar_h = 0
                }
                //var pagosImpresion_h = $("pagosImpresion").getHeight()

                if (iframeExportar != 'ifrRegistros') {
                    var bodyIframe = body_h - divMenuPagos_h - filtro1_h - btnBuscar_h //- pagosImpresion_h
                    $('frameFiltros').setStyle({ height: bodyIframe + 'px' })
                    filtro2_h = filtro2_h - frmFiltros.document.getElementById(iframeExportar).getHeight()
                    frmFiltros.document.getElementById(iframeExportar).setStyle({ height: bodyIframe - filtro2_h + 'px' })
                } else {
                    $('frameFiltros').setStyle({ height: filtro2_h + 'px' })
                    $("ifrRegistros").setStyle({ height: body_h - divMenuPagos_h - filtro1_h - filtro2_h - btnBuscar_h + 'px' })
                    //$("ifrRegistros").setStyle({ height: body_h - divMenuPagos_h - filtro1_h - filtro2_h - btnBuscar_h - pagosImpresion_h + 'px' })
                }
            }
            catch (e) { }
        }


        function filtroConceptoOnChange(id) {
            if (typeof frmFiltros.setFiltros == 'function')
                frmFiltros.setFiltros(id) //setear filtro

            window_onresize()
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <div id="divMenuPagos" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenuPagos = new tMenu('divMenuPagos', 'vMenuPagos');

        vMenuPagos.loadImage("procesar", "/FW/image/icons/procesar.png")
        vMenuPagos.loadImage("upload", "/FW/image/icons/subir.png")

        Menus["vMenuPagos"] = vMenuPagos
        Menus["vMenuPagos"].alineacion = 'centro';
        Menus["vMenuPagos"].estilo = 'A';

        Menus["vMenuPagos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Administración de Pagos - Selección</Desc></MenuItem>")
        Menus["vMenuPagos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>procesar</icono><Desc>Paso 1: Generar archivo para interbanking por lote</Desc><Acciones><Ejecutar Tipo='script'><Codigo>alta_cuenta_interbanking_por_lote()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuPagos"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>upload</icono><Desc>Paso 2: Subir archivo de interbanking al sistema</Desc><Acciones><Ejecutar Tipo='script'><Codigo>transferencia_ejecutar(100,'')</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuPagos.MostrarMenu()
    </script>

    <table class="tb1" id="filtro1">
        <tr class="tbLabel">
            <td style="width: 32%; text-align: center">Razón Social</td>
            <td style="width: 10%; text-align: center">Fecha desde</td>
            <td style="width: 10%; text-align: center">Fecha hasta</td>
            <td style="width: 12.5%; text-align: center">Concepto</td>
            <td style="width: 12.5%; text-align: center">Estado</td>
            <td style="width: 14.5%; text-align: center">Filtro</td>
            <td style="width: 11%; text-align: center">vista</td>
        </tr>
        <tr>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_entidad") %></td>
            <td><% = nvFW.nvCampo_def.get_html_input("fecha_desde", enDB:=False, nro_campo_tipo:=103) %></td>
            <td><% = nvFW.nvCampo_def.get_html_input("fecha_hasta", enDB:=False, nro_campo_tipo:=103) %></td>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_pago_conceptos") %></td>
            <td style="text-align: center">
                <script>
                    campos_defs.add("nro_pago_estado", {
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_pago_estados,
                        nro_campo_tipo: 2
                    })
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('nro_pg_filtro', {
                        mostrar_codigo: false,
                        onchange: function () { filtroConceptoOnChange(campos_defs.get_value('nro_pg_filtro')); }
                    })
                </script>
            </td>
            <td>
                <script>
                    var rs = new tRS();

                    campos_defs.add("tipo_vista", {
                        enDB: false,
                        json: true,
                        nro_campo_tipo: 1,
                        mostrar_codigo: false,
                        sin_seleccion: false
                    })

                    rs.format = "getterror";
                    rs.format_tError = "json";
                    rs.addField("id", "int")
                    rs.addField("campo", "string")
                    rs.addRecord({ id: "1", campo: "Agrupada" });
                    rs.addRecord({ id: "2", campo: "Lineal" });

                    campos_defs.items["tipo_vista"].rs = rs;
                    campos_defs.set_value("tipo_vista", 2)
                </script>
            </td>
        </tr>
    </table>

    <iframe onload="frmOnload()" style="width: 100%; border: none; display: none" name="frameFiltros" id="frameFiltros" src="/FW/enBlanco.htm"></iframe>

    <table class="tb1" id="btnBuscar">
        <tr>
            <td align="left" style="vertical-align: bottom;">
                <div id="divBuscar"></div>
            </td>
        </tr>
    </table>

    <iframe style="width: 100%; height: 100%; border-style: none;" name="ifrRegistros" id="ifrRegistros" src="/FW/enBlanco.htm"></iframe>

    <iframe style="display: none;" name="frameExcel" id="frameExcel"></iframe>
</body>
</html>
