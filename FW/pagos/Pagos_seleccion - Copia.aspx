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
        var filtro_credito       = ''
        var filtro_credito_envio = ''
        var filtro_envio         = ''
        var filtro_conceptos     = ''  
        var filtro_pendientes    = ''
        var filtro_suspendidos   = ''
        var filtro_entidad       = ''
        var filtro_mutual        = ''
        var filtro_fe_descuento  = ''
        var filtro_numero        = ''
        var filtro_fe_liq        = ''
        var filtro_nro_liq_cab   = ''
        var filtro_fe_pago_desde = ''
        var filtro_fe_pago_hasta = ''
        var filtro_pagos_muper   = ''
        var Parametros           = {}

        // Botones
        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"]   = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"]   = "buscar";
        vButtonItems[0]["onclick"]  = "return Aceptar()";

        vButtonItems[1] = []
        vButtonItems[1]["nombre"]   = "Editar";
        vButtonItems[1]["etiqueta"] = "Editar";
        vButtonItems[1]["imagen"]   = "editar";
        vButtonItems[1]["onclick"]  = "return Seleccionar()";

        vButtonItems[2] = []
        vButtonItems[2]["nombre"]   = "Imprimir";
        vButtonItems[2]["etiqueta"] = "Imprimir";
        vButtonItems[2]["imagen"]   = "imprimir";
        vButtonItems[2]["onclick"]  = "return Imprimir()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", "/FW/image/icons/buscar.png")
        vListButtons.loadImage("editar", "/FW/image/icons/editar.png")
        vListButtons.loadImage("imprimir", "/FW/image/icons/imprimir.png")

        // variable para determinar si necesitamos aplicar filtros extras (credito, muper, comercio, reintegro)
        var aplicar_filtros_extras = false
        var filtro                 = null
        var str_filtro_where       = ''


        function getStrTime()
        {
            var fecha = new Date()

            var year      = fecha.getUTCFullYear().toString()
            var imonth    = fecha.getUTCMonth() + 1     // Meses desde 1 a 12
            var month     = imonth < 10 ? "0" + imonth : imonth
            var idia      = fecha.getUTCDate()
            var day       = idia < 10 ? "0" + idia : idia
            var ihoras    = fecha.getHours()
            var horas     = ihoras < 10 ? "0" + ihoras : ihoras
            var iminutos  = fecha.getMinutes()
            var minutos   = iminutos < 10 ? "0" + iminutos : iminutos
            var isegundos = fecha.getSeconds()
            var segundos  = isegundos < 10 ? "0" + isegundos : isegundos
            var milesimas = fecha.getMilliseconds()

            return year + month + day + horas + minutos + segundos + milesimas
        }


        function window_onload() {
            // Mostrar botones creados
            vListButtons.MostrarListButton()
            CargarTipo_Pago()
            //campos_defs.habilitar('nro_mutual', false)
            campos_defs.items['nro_pago_conceptos']['onchange'] = nro_pago_concepto_onchange
            //campos_defs.habilitar('nro_proceso', true)
            campos_defs.items['nro_tipo_comision_est']['onchange'] = nro_tipo_comision_onchange

            $('filtroConcepto').value = '0'
            $('filtroConcepto').onchange()

            campos_defs.set_value('fecha_desde', nvFW.pageContents.today)
            campos_defs.set_value('nro_pago_estado', 1)

            window_onresize()
        }


        function nro_tipo_comision_onchange() {
            $('td_id_liquidacion_est').innerHTML = ''
            var nro_estructura = campos_defs.get_value('nro_estructura')
            var nro_tipo_comision_est = campos_defs.get_value('nro_tipo_comision_est')

            if (nro_estructura != '') {
                campos_defs.add('id_liquidacion_est', {
                    despliega: 'abajo',
                    enDB: false,
                    target: 'td_id_liquidacion_est',
                    nro_campo_tipo: 1,
                    //filtroXML: "<criterio><select vista='verVend_comision_liquidacion'><campos>distinct id_liquidacion as id, abreviacion as [campo] </campos><orden>id_liquidacion desc</orden><filtro></filtro></select></criterio>",
                    filtroXML: nvFW.pageContents.filtro_nro_tipo_comision,
                    filtroWhere: "<criterio><select><filtro><nro_estructura type='igual'>" + nro_estructura + "</nro_estructura><estado type='distinto'>'Z'</estado><id_liquidacion type='in'>%campo_value%</id_liquidacion></filtro></select></criterio>",
                    depende_de: 'nro_tipo_comision_est',
                    depende_de_campo: 'nro_tipo_comision'
                })
            }
        }


        function nro_pago_concepto_onchange()
        {
            var nro_pago_conceptos = $('nro_pago_conceptos').value
            var $filtroConcepto    = $('filtroConcepto')

            switch (nro_pago_conceptos) {
                // Comercio MUPER
                case '16':
                    // setear el filtro en 'Comercio Muper'
                    if ($filtroConcepto.value != '1') {
                        $filtroConcepto.value = '1'
                        $filtroConcepto.onchange()
                    }

                    break

                // Comisión
                case '17':
                    // setear el filtro en 'Comision'
                    if ($filtroConcepto.value != '2') {
                        $filtroConcepto.value = '2'
                        $filtroConcepto.onchange()
                    }

                    break

                // Reintegro
                case '10':
                    // setear el filtro en 'Reintegro'
                    if ($filtroConcepto.value != '3') {
                        $filtroConcepto.value = '3'
                        $filtroConcepto.onchange()
                    }

                    break

                default:
                    if ($filtroConcepto.value != '' && $filtroConcepto.value != '0') {
                        $filtroConcepto.value = ''
                        $filtroConcepto.onchange()
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
                width: 900,
                height: 400,
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
                Aceptar()
        }

    
        function DetalleEnvios() {        
            var filtro_envio = ""
            var ele

            for(var i = 0; ele = iframe1.document.all.frmEnvios.elements[i]; i++) {
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


        function Aceptar(orden)
        {
            var mensaje = Validar_Filtro()
            var path_xsl

            if (mensaje) {
                alert('Debe seleccionar alguno de los siguientes filtros:<br/><br/>' + mensaje, { title: '<b>Selección de filtros</b>', width: 450, height: 150 })
                return
            }


            // Antes de validar, revisar si el concepto y el filtro por conceptos está vacío
            // e intentar realizar una búsqueda por fecha desde y hasta
            //if ($F('nro_pago_conceptos') == '' && $F('nro_pago_conceptos') == '') {
            //    var fecha_desde = $F('fecha_desde')
            //    var fecha_hasta = $F('fecha_hasta')

            //    // Verificar que al menos la fecha_desde no esté vacía
            //    if (fecha_desde == '') {
            //        alert('Para realizar una búsqueda genérica de pagos, debe ingresar al menos la <b>Fecha desde</b>', {
            //            onOk: function(win) {
            //                $('fecha_desde').focus()
            //                win.close()
            //            }
            //        })
            //        return
            //    }
            //    else {
            //        var filtroWhere = '<criterio><select><filtro>'

            //        // Preguntar si esta activado el filtro de Pendientes
            //        if ($('chk_pendientes').checked) {
            //            filtroWhere += "<nro_pago_estado type='igual'>1</nro_pago_estado>"
            //        }

            //        // Si fecha_hasta esta presente, incrementar en un dia su valor, sino usar fecha_desde
            //        var objFecha_fin = parseFecha((fecha_hasta != '' ? fecha_hasta : fecha_desde), 'dd/mm/yyyy')
            //        fecha_hasta = FechaToSTR(new Date(objFecha_fin.getFullYear(), objFecha_fin.getMonth(), objFecha_fin.getDate() + 1), 1)
            //        filtroWhere += "<sql type='sql'><![CDATA[fecha >= CONVERT(DATETIME, '" + fecha_desde + "', 103) AND fecha < CONVERT(DATETIME, '" + fecha_hasta + "', 103)]]></sql>"

            //        filtroWhere += '</filtro></select></criterio>'

            //        nvFW.exportarReporte({
            //            filtroXML:            nvFW.pageContents.filtro_pagos_generico,
            //            filtroWhere:          filtroWhere,
            //            path_xsl:             'report/wrp_pg_registro_agrupados/HTML_pagos_generico.xsl',
            //            formTarget:           'ifrRegistros',
            //            nvFW_mantener_origen: true,
            //            id_exp_origen:        0,
            //            cls_contenedor:       'ifrRegistros',
            //            cls_contenedor_msg:   ' ',
            //            bloq_contenedor:      $('ifrRegistros'),
            //            bloq_msg:             'Cargando...'
            //        })
            //    }
            //    return
            //}

            if (typeof orden != "string" || orden == "" )
                orden = "nro_credito"
            
            if ($('nro_pago_conceptos').value == 10) {
                nvFW.exportarReporte({
                    //filtroXML: "<criterio><procedure CommandText='dbo.rm_pg_registro_agrupados_reintegros' vista='wrp_pg_registro_agrupados'><parametros>" + strparametros + "<orden>nro_credito</orden></parametros></procedure></criterio>",
                    //filtroXML:            nvFW.pageContents.filtro_aceptar_10,
                    filtroXML:            nvFW.pageContents.filtro_pago_registro_agrupados,
                    //filtroWhere:          '<criterio><procedure><parametros><select><orden>nro_credito</orden></select></parametros></procedure></criterio>',
                    filtroWhere:          '<criterio><select><orden>nro_credito</orden><filtro>' + str_filtro_where + '</filtro></select></criterio>',
                    //params:               '<criterio>' + strparametros + '/></criterio>',
                    path_xsl:             'report/wrp_pg_registro_agrupados/HTML_registros_pagos_reintegros.xsl',
                    formTarget:           'ifrRegistros',
                    nvFW_mantener_origen: true,
                    id_exp_origen:        0,
                    cls_contenedor:       'ifrRegistros',
                    cls_contenedor_msg:   ' ',
                    bloq_contenedor:      $('ifrRegistros'),
                    bloq_msg:             'Cargando...'
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
                    filtroXML:            nvFW.pageContents.filtro_pago_registro_agrupados,
                    filtroWhere:          '<criterio><select><orden>' + orden + '</orden><filtro>' + str_filtro_where + '</filtro></select></criterio>',
                    //params:               '<criterio>' + strparametros + ' orden="' + orden + '" /></criterio>',
                    path_xsl:             path_xsl,
                    formTarget:           'ifrRegistros',
                    nvFW_mantener_origen: true,
                    id_exp_origen:        0,
                    cls_contenedor:       'ifrRegistros',
                    cls_contenedor_msg:   ' ',
                    bloq_contenedor:      $('ifrRegistros'),
                    bloq_msg:             'Cargando...'
                })
            }
        }


        function Validar_Filtro()
        {
            var mensaje                  = ''
            var mensaje_genericos        = ''
            var str_filtro_entidad_fecha = ''
            str_filtro_where             = ''

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

            var estados = campos_defs.get_value('nro_pago_estado').replace(/ /g, '').split(",")
            
            //if ($('chk_pendientes').checked) {
            if (estados.indexOf("1") > -1) {
                str_filtro_where += '<pagos_pendientes type="mayor">0</pagos_pendientes>'
            }
            
            //if ($('chk_suspendidos').checked) {
            if (estados.indexOf("7") > -1) {
                str_filtro_where += '<pagos_suspendidos type="mayor">0</pagos_suspendidos>'
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
            }

            if (!aplicar_filtros_extras) {
                str_filtro_where = str_filtro_entidad_fecha + str_filtro_where
                return mensaje
            }
            else {
                /*----------------------------------------------------------------- 
                | Filtros específicos extra
                |------------------------------------------------------------------
                |   * Crédito
                |   * Comercio MUPER
                |   * Comisión
                |   * Reintegro
                |----------------------------------------------------------------*/

                /*----------------------------------------------------------------- 
                | CREDITO
                |------------------------------------------------------------------
                |   Nombre campo                    |   Tipo
                |------------------------------------------------------------------
                |   * nro_envio                     |   input text
                |   * nro_credito                   |   input text
                |----------------------------------------------------------------*/
                if (filtro == 'credito') {
                    var str_filtro_credito = ''

                    if ($('nro_envio').value.trim()) {
                        str_filtro_credito += '<nro_envio_gral type="in">' + $('nro_envio').value.trim() + '</nro_envio_gral>'
                    }

                    if ($('nro_credito').value.trim()) {
                        str_filtro_credito += '<nro_credito type="in">' + $('nro_credito').value.trim() + '</nro_credito>'
                    }

                    if (!str_filtro_credito) {
                        if (!str_filtro_entidad_fecha) {
                            mensaje += mensaje_genericos + '<b>Crédito: </b>Nro. envío, Nro. crédito<br/>'
                        }
                        else {
                            str_filtro_where = str_filtro_entidad_fecha + str_filtro_where
                        }
                    }
                    else {
                        if (str_filtro_entidad_fecha)
                            str_filtro_where += str_filtro_credito + str_filtro_entidad_fecha
                        else
                            str_filtro_where += str_filtro_credito
                    }

                    return mensaje
                }

                /*----------------------------------------------------------------- 
                | Comercio MUPER
                |------------------------------------------------------------------
                |   Nombre campo                    |   Tipo
                |------------------------------------------------------------------
                |   * fecha_presentacion            |   campo_def 103
                |----------------------------------------------------------------*/
                if (filtro == 'muper') {
                    var str_filtro_muper = ''

                    if (campos_defs.get_value('fecha_presentacion')) {
                        str_filtro_muper += '<fecha_presentacion type="igual">\'' + nvFW.MMDDYYYY(campos_defs.get_value('fecha_presentacion')) + '\'</fecha_presentacion>'
                    }

                    if (str_filtro_muper) {
                        if (str_filtro_entidad_fecha) {
                            str_filtro_where += '<or><or>' + str_filtro_entidad_fecha + '</or><or>' + str_filtro_muper + '</or></or>'
                        }
                        else {
                            str_filtro_where += str_filtro_muper
                        }
                    }
                    else {
                        if (str_filtro_entidad_fecha)
                            str_filtro_where += str_filtro_entidad_fecha
                        else
                            // En este caso no hay ningun filtro seteado
                            mensaje += mensaje_genericos + '<b>MUPER: </b>Fecha presentación<br/>'
                    }

                    return mensaje
                }

                /*----------------------------------------------------------------- 
                | Comisión
                |------------------------------------------------------------------
                |   Nombre campo                    |   Tipo
                |------------------------------------------------------------------
                |   * nro_estructura                |   campo_def 1
                |   * nro_tipo_comision_est         |   campo_def 1
                |   * id_liquidacion_est            |   campo_def 1
                |   * nro_entidad_facturacion       |   campo_def 1
                |----------------------------------------------------------------*/
                if (filtro == 'comision') {
                    var str_filtro_comision = ''

                    if (campos_defs.get_value('nro_estructura') && campos_defs.get_value('nro_tipo_comision_est')) {
                        if (campos_defs.get_value('id_liquidacion_est')) {
                            str_filtro_comision += '<id_liquidacion type="igual">' + campos_defs.get_value('id_liquidacion_est') + '</id_liquidacion>'
                        }

                        if (campos_defs.get_value('nro_entidad_facturacion')) {
                            str_filtro_comision += '<nro_entidad_pago type="igual">' + campos_defs.get_value('nro_entidad_facturacion') + '</nro_entidad_pago>'
                        }

                        // Si ambos filtros están vacíos, informar que debe seleccionar al menos uno de ellos
                        if (!str_filtro_comision) {
                            if (!str_filtro_entidad_fecha)
                                mensaje += mensaje_genericos + '<b>Comisión: </b>Liquidación, Entidad de pago<br/>'
                            else
                                str_filtro_where += str_filtro_entidad_fecha
                        }
                        else {
                            if (!str_filtro_entidad_fecha)
                                str_filtro_where += str_filtro_comision
                            else
                                str_filtro_where += str_filtro_entidad_fecha + str_filtro_comision
                        }
                    }
                    else {
                        if (!str_filtro_entidad_fecha)
                            mensaje += mensaje_genericos + '<b>Comisión: </b>Liquidación, Entidad de pago<br/>'
                        else
                            str_filtro_where += str_filtro_entidad_fecha
                    }

                    return mensaje
                }

                /*----------------------------------------------------------------- 
                | Reintegro
                |------------------------------------------------------------------
                |   Nombre campo                    |   Tipo
                |------------------------------------------------------------------
                |   * nro_mutual                    |   campo_def 1
                |   * fe_descuento                  |   campo_def 103
                |   * numero                        |   input text
                |   * nro_proceso                   |   campo_def 101
                |----------------------------------------------------------------*/
                if (filtro == 'reintegro') {
                    var str_filtro_reintegro = ''

                    if (campos_defs.get_value('nro_mutual')) {
                        str_filtro_reintegro += '<nro_mutual type="igual">' + campos_defs.get_value('nro_mutual') + '</nro_mutual>'
                    }

                    var fe_descuento = campos_defs.get_value('fe_descuento')

                    if (fe_descuento) {
                        str_filtro_reintegro += '<fe_descuento type="igual">convert(datetime, \'' + fe_descuento + '\', 103)</fe_descuento>'
                    }

                    if ($('numero').value.trim()) {
                        str_filtro_reintegro += '<numero type="in">' + $('numero').value + '</numero>'
                    }

                    if (campos_defs.get_value('nro_proceso')) {
                        str_filtro_reintegro += '<nro_proceso type="in">' + campos_defs.get_value('nro_proceso') + '</nro_proceso>'
                    }

                    if (!fecha_desde && !fe_descuento) {
                        mensaje += 'Para <b>reintegros</b> es necesario setear al menos uno de éstos filtros:<br/><b>Genéricos: </b>Fecha desde<br/><b>Reintegro: </b>Fecha descuento<br/>'
                        return mensaje
                    }

                    if (!str_filtro_reintegro) {
                        if (!str_filtro_entidad_fecha)
                            mensaje += mensaje_genericos + '<b>Reintegro: </b>Fecha descuento<br/>'
                        else
                            str_filtro_where = str_filtro_entidad_fecha + str_filtro_where
                    }
                    else {
                        if (!str_filtro_entidad_fecha)
                            str_filtro_where += str_filtro_reintegro
                        else
                            str_filtro_where += str_filtro_reintegro + str_filtro_entidad_fecha
                    }

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


        function valDigito_nro_envio(strCaracteres) {
            if (event.keyCode == 13) {
                event.keyCode = 0
                Aceptar()
            }

            if (!strCaracteres)
                strCaracteres = ''

            var key        = window.event.keyCode
            var strkey     = String.fromCharCode(key)
            var encontrado = strCaracteres.indexOf(strkey) != -1
  
            if ((strkey < "0" || strkey > "9") && !encontrado)
                window.event.keyCode = 0
        }


        var win_envios


        function Ver_FiltroEnvios() {
            win_envios = parent.nvFW.createWindow({
                title:               '<b>Seleccionar Envios</b>',
                url:                 'Envios_Finalizados.aspx?seleccion=1',
                minimizable:         true,
                maximizable:         true,
                draggable:           true,
                closable:            true,
                resizable:           true,
                width:               950,
                height:              450,
                parentWidthElement:  $$("body")[0],
                parentWidthPercent:  1.0,
                parentHeightElement: $$("body")[0],
                parentHeightPercent: 1.0,
                onClose:             Ver_FiltroEnvios_return,
                destroyOnClose:      true
            });
            
            //win_envios.setURL('Envios_Finalizados.aspx?seleccion=1')
            win_envios.options.userData = { filtro_envio: '' }
            win_envios.showCenter(true)
        }


        function Ver_FiltroEnvios_return() {
            var retorno = win_envios.options.userData.parametros

            if (retorno) {
                filtro_envio = retorno
                $('nro_envio').value = filtro_envio
                Aceptar()
            }
        }


        var win_chequera
        var win_depositos
        var win_efectivo
        var win_giro


        function Seleccionar() {
            debugger
            var mensaje = Validar_Filtro()
            
            if (mensaje != '') {
                alert(mensaje)
                return
            }

            var i
            var ele
            var nro_pagos_registros = ''
            var nombre = ''
            
            for (i = 0; ele = ifrRegistros.document.all.frmPagos.elements[i]; i++) {
                nombre = ele.id.substring(0, 17)
                
                if (ele.type == 'hidden' && nombre == 'nro_pago_registro') {
	 	             if (nro_pagos_registros == '')
                        nro_pagos_registros = ele.value
                     else
                        nro_pagos_registros += ", " + ele.value  
                } 
            }

            Parametros["nro_pagos_registros"] = nro_pagos_registros    
            Parametros["filtro_envios"]       = $('nro_envio').value

            switch ($('tipo_pago').value)
            {
                // Cheque Bejerman
                case '6': {                         
                    win_chequera = nvFW.createWindow({
                        title:          '<b>Seleccionar Chequera</b>',
                        url:            'Pagos_distribucion_chequera.aspx',
                        minimizable:    true,
                        maximizable:    true,
                        draggable:      false,
                        closable:       true,
                        width:          800,
                        height:         170,
                        resizable:      false,
                        onClose:        Aceptar,
                        destroyOnClose: true
                    });
                    
                    win_chequera.options.userData = { Parametros: Parametros }
                    //win_chequera.setURL('Pagos_distribucion_chequera.aspx')
                    win_chequera.showCenter(true)
                    }
                    break

                // Depósito 3eros
                case '1': {
                    win_depositos = window.top.nvFW.createWindow({
                        title:          '<b>Editar Pagos - Depósitos</b>',
                        url:            'Pagos_distribucion_deposito.aspx',
                        minimizable:    true,
                        maximizable:    true,
                        draggable:      false,
                        closable:       true,
                        width:          1024,
                        height:         520,
                        resizable:      false,
                        onClose:        Aceptar,
                        destroyOnClose: true
                    });

                    win_depositos.options.userData = { Parametros: Parametros }
                    //win_depositos.setURL('Pagos_distribucion_deposito.aspx')
                    win_depositos.showCenter(true)
                    }
                    break  

                // Efectivo
                case '4': {                        
                    win_efectivo = window.top.nvFW.createWindow({
                        title:          '<b>Editar Pagos - Efectivo</b>',
                        url:            'Pagos_distribucion_efectivo.aspx',
                        minimizable:    true,
                        maximizable:    true,
                        draggable:      false,
                        closable:       true,
                        width:          850,
                        height:         500,
                        resizable:      false,
                        onClose:        Aceptar,
                        destroyOnClose: true
                    });

                    win_efectivo.options.userData = { Parametros: Parametros }
                    //win_efectivo.setURL('Pagos_distribucion_efectivo.aspx')
                    win_efectivo.showCenter(true)
                    }
                    break

                // Giro
                case '8': {       
                    win_giro = window.top.nvFW.createWindow({
                        title:          '<b>Editar Pagos - Giro</b>',
                        url:            'Pagos_distribucion_giro.aspx',
                        minimizable:    true,
                        maximizable:    true,
                        draggable:      false,
                        closable:       true,
                        width:          850,
                        height:         500,
                        resizable:      false,
                        onClose:        Aceptar,
                        destroyOnClose: true
                    });

                    win_giro.options.userData = { Parametros: Parametros }
                    //win_giro.setURL('Pagos_distribucion_giro.aspx')
                    win_giro.showCenter(true)
                    }
                    break

                // Deposito Bejerman
                case '10':
                // Tarjeta Sidecreer
                case '7':
                // Descuento Sueldo
                case '9':
                // Cheque 3eros
                case '5':
                default:
                    alert('Modulo no Habilitado', { width: 250, height: 70 });
                    break
            }
        }


        function Pagos_Envios()
        {
            if (filtro_credito == '' && filtro_envio == '') {
                alert('Debe seleccionar un crédito o un envio para generar el reporte.')
                return
            }

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>convert(float,nro_cheque) as nro_cheque01, *</campos><orden>nro_cheque01 asc</orden><filtro>" + filtro_credito + filtro_envio + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><nro_pago_tipo type='in'>1,6,8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML:   nvFW.pageContents.filtro_pagos_envios,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + "</filtro></select></criterio>",
                report_name: "pagos_envios.rpt",
                formTarget:  "_blank",
                name:        "pagos_envios",
                filename:    "pagos_envios_" + getStrTime() + ".pdf"
            })
        }


        function Pagos_Tipos()
        {
            var mensaje = Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>distinct convert(float,nro_cheque) as nro_cheque01, *</campos><orden>nro_cheque01 asc</orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><nro_pago_tipo type='in'>1,4,6,8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML:   nvFW.pageContents.filtro_pago_tipos,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "</filtro></select></criterio>",
                report_name: "pagos_tipos.rpt",
                formTarget:  "_blank",
                name:        "pagos_tipos",
                filename:    "pagos_tipos_" + getStrTime() + ".pdf"
            })
        }


        function RecFondos(nro_pago_tipo)
        {
            var strfiltro_pago = ''
            
            if (nro_pago_tipo)
                strfiltro_pago = "<SQL type='sql'>dbo.rm_credito_tiene_pago_tipo(nro_credito, " + nro_pago_tipo + ") > 0</SQL>"        
            
            var mensaje = Validar_Filtro()
            
            if (mensaje != '') {
                alert(mensaje)
                return
            } 

            var filtro_envio_tipo = "<nro_envio_tipo type='SQL'>dbo.rm_esEnvio_tipo_impresion(nro_banco, nro_envio_tipo) = 1</nro_envio_tipo>"

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden>nro_pago_registro</orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + strfiltro_pago + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio>" + filtro_envio_tipo + "</filtro></select></criterio>",
                filtroXML:   nvFW.pageContents.filtro_recibo_fondos,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + strfiltro_pago + filtro_envio_tipo + "</filtro></select></criterio>",
	            report_name: "recibo_pagos.rpt",
	            formTarget:  "_blank",
                name:        "recibo_pagos",
                filename:    "recibo_pagos_" + getStrTime() + ".pdf"
	        })
        }


        function Recibos_Reintegros() {
            if ($('nro_pago_conceptos').value != '10') {
                alert('Debe seleccionar Reintegros para imprimir el Recibo.')
                return
            }

            var mensaje = Validar_Filtro()
            
            if (mensaje != '') {
                alert(mensaje)
                return
            }
            
            var nro_pago_detalles = ''
            var rs                = new tRS()

            //rs.open("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_detalle</campos><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><nro_pago_concepto type='igual'>10</nro_pago_concepto></filtro></select></criterio>")                      
            rs.open({
                filtroXML:   nvFW.pageContents.filtro_nro_pago_detalle,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + "</filtro></select></criterio>"
            })

            while (!rs.eof()) {
                if (nro_pago_detalles == '')
                    nro_pago_detalles = rs.getdata('nro_pago_detalle')
                else
                    nro_pago_detalles += "," + rs.getdata('nro_pago_detalle')

                rs.movenext()       
            }

            if (nro_pago_detalles != '') {
                nvFW.mostrarReporte({
                    //filtroXML: "<criterio><select vista='verReintegros'><campos>*</campos><orden></orden><filtro><nro_pago_detalle type='in'>" + nro_pago_detalles + "</nro_pago_detalle></filtro></select></criterio>",
                    filtroXML:   nvFW.pageContents.filtro_recibos_reintegros,
                    filtroWhere: "<criterio><select><filtro><nro_pago_detalle type='in'>" + nro_pago_detalles + "</nro_pago_detalle></filtro></select></criterio>",
                    report_name: "recibo_pago_reintegros.rpt",
                    formTarget:  "_blank",
                    name:        "recibo_pago_reintegros",
                    filename:    "recibo_pago_reintegros_" + getStrTime() + ".pdf"
                })
            }
        }


        function CtrolEnvios() {
            var filtro = ''
            var nro_envio_value   = $('nro_envio').value
            var nro_credito_value = $('nro_credito').value

            if (nro_envio_value == '' && nro_credito_value == '') {
                alert('Debe seleccionar un crédito o un envio para generar el reporte.')
                return
            }

            if (nro_envio_value != '')
                filtro += "<nro_envio_gral type='in'>" + nro_envio_value + "</nro_envio_gral>"

            if (nro_credito_value != '')
                filtro += "<nro_credito type='in'>" + nro_credito_value + "</nro_credito>"    

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='WRP_PG_CREDITO_ENVIOS'><campos>*</campos><orden>nro_credito</orden><filtro>" + filtro + "</filtro></select></criterio>",
                filtroXML:   nvFW.pageContents.filtro_control_envios,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                report_name: "control_envios.rpt",
                formTarget:  "_blank",
                name:        "control_envios",
                filename:    "control_envios_" + getStrTime() + ".pdf"
            })
        }


        function CargarConcepto()
        {
            var rs = new tRS();
            var cb = document.all.cbConcepto

            cb.options.length = 0
            cb.options.length++
            cb.options[cb.options.length - 1].value = 0
            cb.options[cb.options.length - 1].text  = "-- TODOS --"

            //rs.open("<criterio><select vista='pago_conceptos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
            rs.open({ filtroXML: nvFW.pageContents.filtro_cargar_concepto })

            while (!rs.eof()) {
                cb.options.length++
                cb.options[cb.options.length - 1].value = rs.getdata('nro_pago_concepto') 
                cb.options[cb.options.length - 1].text  = rs.getdata('pago_concepto')
                rs.movenext()
            }
        }


        function CargarTipo_Pago()
        {
            var rs         = new tRS();
            var $tipo_pago = $('tipo_pago')
            //$('tipo_pago').options.length = 0
            $tipo_pago.options.length = 0

            //rs.open("<criterio><select vista='pago_tipos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
            rs.open({ filtroXML: nvFW.pageContents.filtro_tipo_pago })
            
            while (!rs.eof()) {
                $tipo_pago.insert(new Element('option', { value: rs.getdata('nro_pago_tipo') }).update(rs.getdata('pago_tipo')))

                if (rs.getdata('nro_pago_tipo') == 6)
                    $tipo_pago.selectedIndex = $tipo_pago.options.length - 1

                i++
                rs.movenext()
            }

            $tipo_pago.setStyle({ width: '100%' })
        }


        function Imprimir() {
            switch ($('cbTipo_Reporte').value) {
                case 'CE':  
                    CtrolEnvios()
                    break
                case 'PE': 
                    Pagos_Envios()
                    break
                case 'PT':
                    Pagos_Tipos()
                    break
                case 'RF':
                    RecFondos()
                    break
                case 'RFC':
                    RecFondos(6)
                    break  
                case 'RR':
                    Recibos_Reintegros()
                    break        
                case 'SP':
                    SeguimientoPagos();
                    break 
                case 'CFC':
                    CtrolFondosCheques();
                    break
                case 'CPE':
                    CtrolPagosExcel();
                    break  
            }
        }


        function CtrolFondosCheques()
        {
            var mensaje = Validar_Filtro()
            
            if (mensaje != '') {
                alert(mensaje)
                return
            }
    
            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden></orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "<nro_pago_tipo type='igual'>6</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML:   nvFW.pageContents.filtro_ctrl_fondos_cheques,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "</filtro></select></criterio>",
                report_name: "control_fondos_cheques.rpt",
                formTarget:  "_blank",
                name:        "control_fondos_cheques",
                filename:    "control_fondos_cheques_" + getStrTime() + ".pdf"
            })
        }


        function CtrolPagosExcel()
        {
            var mensaje = Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }
            
            nvFW.exportarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>distinct pago_concepto,pago_tipo,pago_estados,CASE WHEN not dep_cuenta_desc IS NULL THEN ISNULL(dep_cuenta_desc,'') ELSE '' END as cuenta,CASE WHEN not nro_cheque IS NULL THEN nro_cheque ELSE '' END as cheque,razon_social as destinatario,documento,nro_docu,strnombrecompleto,nro_envio,nro_envio_gral,nro_credito,mutual,banco,importe_bruto,importe_neto,importe_pago,ISNULL(fe_estado,'') AS fecha_estado</campos><orden></orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "<nro_pago_estado type='in'>1,2,4,5</nro_pago_estado><nro_pago_tipo type='in'>1,4,6,8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML:           nvFW.pageContents.filtro_control_pagos_excel,
                filtroWhere:         "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "</filtro></select></criterio>",
                path_xsl:            "report\\wrp_verpg_registro\\EXCEL_control_pagos.xsl",
                salida_tipo:         "adjunto",
                ContentType:         "application/vnd.ms-excel",
                content_disposition: "attachment",
                formTarget:          "frameExcel",
                filename:            "control_pagos.xls"
            })
        }


        function SeguimientoPagos() {
            nvFW.transferenciaEjecutar({
                id_transferencia: 191,
                xml_param:        '',
                pasada:           0,
                formTarget:       'winPrototype',
                async:            false,
                ej_mostrar:       true,
                winPrototype: {
                    modal:          true,
                    center:         true,
                    bloquear:       false,
                    url:            '/FW/enBlanco.htm',
                    title:          '<b>Seguimiento de Pagos</b>',
                    minimizable:    false,
                    maximizable:    true,
                    draggable:      true,
                    width:          800,
                    height:         400,
                    resizable:      true,
                    destroyOnClose: true
                }
            })    
        }


        function transferencia_ejecutar(id_transferencia, xml_param) {
            //if ((procesos_ref_grupos & 2048) > 0) {
            if (nvFW.tienePermiso("procesos_ref_grupos", 12)) {     // 12: Interbanking
                window.top.nvFW.transferenciaEjecutar({
                    id_transferencia: id_transferencia,
                    xml_param:        xml_param,
                    pasada:           0,
                    formTarget:       'winPrototype',
                    async:            false,
                    ej_mostrar:       true,
                    winPrototype: {
                        modal:          true,
                        center:         true,
                        bloquear:       false,
                        url:            '/FW/enBlanco.htm',
                        title:          '<b>Transferencia Interbanking</b>',
                        minimizable:    false,
                        maximizable:    true,
                        draggable:      true,
                        width:          800,
                        height:         400,
                        resizable:      true,
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
                    onOk: function(win) {
                        transferencia_ejecutar(909, '')  
                        win.close()
                    },
                    onCancel: function(win) {
                        win.close()
                        return
                    }
                });
        }


        function window_onresize()
        {
            try {
                var body_h           = $$("body")[0].getHeight()
                var divMenuPagos_h   = $('divMenuPagos').getHeight()
                var filtro1_h        = $("filtro1").getHeight()
                var filtro2_h        = $("filtro2").getHeight()
                var btnBuscar_h      = $("btnBuscar").getHeight()
                var pagosImpresion_h = $("pagosImpresion").getHeight()

                $("ifrRegistros").setStyle({ height: body_h - divMenuPagos_h - filtro1_h - filtro2_h - btnBuscar_h - pagosImpresion_h + 'px' })
            }
            catch(e) {}
        }


        function filtroConceptoOnChange(id)
        {
            switch(id) {
                // Crédito
                case '0':
                    var conceptos = campos_defs.get_value('nro_pago_conceptos').split(', ')

                    // Si alguno de los conceptos elegidos es Muper, Comisión o Reintegro, limpiamos el concepto
                    if (conceptos.indexOf('10') != -1 || conceptos.indexOf('16') != -1 || conceptos.indexOf('17') != -1)
                        campos_defs.set_value('nro_pago_conceptos', '')

                    // Mostrar el filtro seleccionado
                    $('filtroMuper').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').hide()
                    $('filtroCredito').show()

                    aplicar_filtros_extras = true
                    filtro = 'credito'
                    break

                // Comercio MUPER
                case '1':
                    if (campos_defs.get_value('nro_pago_conceptos') != '16')
                        campos_defs.set_value('nro_pago_conceptos', '16')

                    //$('nro_envio').value   = ''
                    //$('nro_credito').value = ''

                    // Mostrar el filtro seleccionado
                    $('filtroCredito').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').hide()
                    $('filtroMuper').show()

                    aplicar_filtros_extras = true
                    filtro = 'muper'
                    break

                // Comisión
                case '2':
                    if (campos_defs.get_value('nro_pago_conceptos') != '17')
                        campos_defs.set_value('nro_pago_conceptos', '17')

                    //campos_defs.clear('fecha_presentacion')
                    //$('nro_envio').value   = ''
                    //$('nro_credito').value = ''

                    // Mostrar el filtro seleccionado
                    $('filtroCredito').hide()
                    $('filtroMuper').hide()
                    $('filtroReintegro').hide()
                    $('filtroComision').show()

                    aplicar_filtros_extras = true
                    filtro = 'comision'
                    break

                // Reintegro
                case '3':
                    if (campos_defs.get_value('nro_pago_conceptos') != '10')
                        campos_defs.set_value('nro_pago_conceptos', '10')

                    //campos_defs.clear('fecha_presentacion')
                    //$('nro_envio').value   = ''
                    //$('nro_credito').value = ''

                    // Mostrar el filtro seleccionado
                    $('filtroCredito').hide()
                    $('filtroMuper').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').show()

                    aplicar_filtros_extras = true
                    filtro = 'reintegro'
                    break
                
                // Vacio
                case '':
                default:
                    $('filtroCredito').hide()
                    $('filtroMuper').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').hide()

                    aplicar_filtros_extras = false
                    filtro = null
                    break
            }

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
            <td style="width: 35%;">Razón Social</td>
            <td style="width: 10%;">Fecha desde</td>
            <td style="width: 10%;">Fecha hasta</td>
            <td style="width: 17.5%;">Concepto</td>
            <td style="width: 17.5%;">Estado</td>
            <%--<td style="width: 5%; text-align: center;" title="Pagos Pendientes">P</td>
            <td style="width: 5%; text-align: center;" title="Pagos Suspendidos">S</td>--%>
            <td style="width: 17.5%;">Filtro</td>
        </tr>
        <tr>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_entidad") %></td>
            <td><% = nvFW.nvCampo_def.get_html_input("fecha_desde", enDB:=False, nro_campo_tipo:=103) %></td>
            <td><% = nvFW.nvCampo_def.get_html_input("fecha_hasta", enDB:=False, nro_campo_tipo:=103) %></td>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_pago_conceptos") %></td>
            <td style="text-align:center">
                <%--<input type="checkbox" style="border: none; cursor: pointer;" id="chk_pendientes" name="chk_pendientes" title='Pagos Pendientes' checked />
            </td>
            <td style="text-align:center">
                <input type="checkbox" style="border: none; cursor: pointer;" id="chk_suspendidos" name="chk_suspendidos" title='Pagos Suspendidos' />--%>
                <script>
                    campos_defs.add("nro_pago_estado",{
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_pago_estados,
                        nro_campo_tipo: 2
                    })
                </script>
            </td>
            <td>
                <select id="filtroConcepto" style="width: 100%;" onchange="return filtroConceptoOnChange(this.value)">
                    <option value="" selected></option>
                    <option value="0">Crédito</option>
                    <option value="1">Comercio Muper</option>
                    <option value="2">Comisión</option>
                    <option value="3">Reintegro</option>
                </select>
            </td>
        </tr>
    </table>

    <table class="tb1" id="filtro2" cellspacing="0" cellpadding="0">
        <tr id="filtroCredito" style="display: none;">
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td colspan="2">Nro. Envío</td>
                        <td>Nro. Crédito</td>
                    </tr>
                    <tr>
                        <td style="width: 80%;">
                            <input type="text" name="nro_envio" id="nro_envio" style="width: 100%;" onkeypress='return valDigito_nro_envio(",-")' ondblclick="return Ver_FiltroEnvios()" />
                        </td>
                        <td>
                            <img alt="Seleccionar envíos" src="/FW/image/campo_def/buscar.png" style="cursor: pointer;" onclick="return Ver_FiltroEnvios()" title="Seleccionar envíos" />
                        </td>
                        <td style="width: 20%;">
                            <input type="text" name="nro_credito" id="nro_credito" style="width: 100%" onkeypress='return valDigito_nro_envio(",-")' />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="filtroMuper" style="display: none;">
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 100%;">Fecha Presentación</td>
                    </tr>
                    <tr>
                        <td id='tdfecha_presentacion'>
                            <% = nvFW.nvCampo_def.get_html_input("fecha_presentacion", enDB:=False, nro_campo_tipo:=103) %>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="filtroComision" style="display: none;">
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 50%">Estructura</td>
                        <td style="width: 50%">Tipo Comisión</td>
                    </tr>
                    <tr>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("nro_estructura") %>
                        </td> 
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("nro_tipo_comision_est") %>
                        </td>  
                    </tr>
                    <tr class="tbLabel">
                        <td style="width: 50%">Liquidación</td>
                        <td style="width: 50%">Entidad Pago</td>
                    </tr>
                    <tr>
                        <td style="width: 50%; text-align: left;" id="td_id_liquidacion_est">
                            <input type="text" name="id_liquidacion_est_hidden" id="id_liquidacion_est_hidden" style="width: 100%;" disabled />
                        </td>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("nro_entidad_facturacion") %>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="filtroReintegro" style="display: none;">
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 50%">Mutual</td>
                        <td style="width: 50%">Fecha Descuento</td>            
                    </tr>
                    <tr>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("nro_mutual") %>
                        </td>
                        <td id='tdfe_descuento'>
                            <% = nvFW.nvCampo_def.get_html_input("fe_descuento", enDB:=False, nro_campo_tipo:=103) %>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td>Nro. Descuento</td>
                        <td>Nro. Proceso</td>
                    </tr>
                    <tr>
                        <td>
                            <input name="numero" id="numero" onkeypress='return valDigito_nro_envio(",")' style="width: 100%;" />
                        </td>
                        <td id="tdnro_proceso">
                            <% = nvFW.nvCampo_def.get_html_input("nro_proceso", enDB:=False, nro_campo_tipo:=101) %>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>


    <table class="tb1" id="btnBuscar">
        <tr>
            <td align="left" style="vertical-align: bottom;">
                <div id="divBuscar"></div>
            </td>
        </tr>
    </table>                   

    <iframe style="width: 100%; height: 100%; border-style: none" name="ifrRegistros" id="ifrRegistros" src="/FW/enBlanco.htm"></iframe>

    <table class="tb1" id="pagosImpresion">
        <tr class="tbLabel">
            <td colspan="2" style="width: 50%">Editar Pagos</td>
            <td colspan="2" style="width: 50%">Impresión de Reportes</td>
        </tr>
        <tr>
            <td style="width: 30%">
                <select name="tipo_pago" id="tipo_pago"></select>
            </td>
            <td style="width: 20%">
                <div id='divEditar' style='width: 100%'></div>
            </td>
            <td style="width: 30%">
                <select style="width: 100%" id="cbTipo_Reporte" name="cbTipo_Reporte">
                    <option value="CE">Control de Envios</option>
                    <option value="PE">Pagos por Envios</option>
                    <option value="PT">Pagos por Tipo</option>
                    <option value="RF">Recepción Fondos</option>
                    <option value="RFC">Recepción Fondos - Cheques</option>
                    <option value="RR">Recibo Reintegros</option>
                    <option value="SP">Seguimiento Pagos</option>                                        
                    <option value="CFC">Control Fondos - Cheques</option>       
                    <option value="CPE">Control de Pagos - Excel</option>       
                </select>
            </td>
            <td style="width: 20%">
                <div id='divImprimir' style='width:100%'></div>
            </td>
        </tr>
    </table>

    <iframe style="display: none;" name="frameExcel" id="frameExcel"></iframe>
</body>
</html>
