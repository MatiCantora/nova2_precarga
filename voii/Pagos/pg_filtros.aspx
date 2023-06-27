<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    '----------------------------------------------------------------
    ' Filtros Encriptados
    '----------------------------------------------------------------
    Me.contents("filtro_nro_tipo_comision") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verVend_comision_liquidacion'><campos>distinct id_liquidacion AS id, abreviacion AS [campo]</campos><orden>id desc</orden></select></criterio>")
    Me.contents("filtro_tipo_pago") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_tipos'><campos>nro_pago_tipo as id, pago_tipo as campo</campos><filtro><pago_habilitado type='igual'>1</pago_habilitado></filtro><orden>campo</orden></select></criterio>")
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

        var filtro_credito = ''
        var filtro_envio = ''
        var filtro_conceptos = ''
        var filtro_pendientes = ''
        var filtro_suspendidos = ''
        var filtro_entidad = ''
        var filtro_mutual = ''
        var filtro_fe_descuento = ''
        var filtro_numero = ''
        var filtro_fe_liq = ''
        var filtro_nro_liq_cab = ''
        var filtro_fe_pago_desde = ''
        var filtro_fe_pago_hasta = ''
        var filtro_credito_envio = ''
        var filtro_pagos_muper = ''
        var filtro_pagos_comision = ''

        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return parent.Aceptar()";

        vButtonItems[1] = []
        vButtonItems[1]["nombre"] = "Editar";
        vButtonItems[1]["etiqueta"] = "Editar";
        vButtonItems[1]["imagen"] = "editar";
        vButtonItems[1]["onclick"] = "return Seleccionar()";

        vButtonItems[2] = []
        vButtonItems[2]["nombre"] = "Imprimir";
        vButtonItems[2]["etiqueta"] = "Imprimir";
        vButtonItems[2]["imagen"] = "imprimir";
        vButtonItems[2]["onclick"] = "return Imprimir()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", "/FW/image/icons/buscar.png")
        vListButtons.loadImage("editar", "/FW/image/icons/editar.png")
        vListButtons.loadImage("imprimir", "/FW/image/icons/imprimir.png")

        function window_onload() {
            vListButtons.MostrarListButton()
            campos_defs.items['nro_tipo_comision_est']['onchange'] = nro_tipo_comision_onchange
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


        function window_onresize() {

        }


        function getFiltros(filtro, mensaje_genericos, str_filtro_entidad_fecha, fecha_desde) {

            var mensaje = ''
            var str_filtro_where = ''

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

                var objReturn = {}
                objReturn.mensaje = mensaje
                objReturn.filtroWhere = str_filtro_where

                return objReturn
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

                var objReturn = {}
                objReturn.mensaje = mensaje
                objReturn.filtroWhere = str_filtro_where

                return objReturn
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

                var objReturn = {}
                objReturn.mensaje = mensaje
                objReturn.filtroWhere = str_filtro_where

                return objReturn
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

                var objReturn = {}
                objReturn.mensaje = mensaje
                objReturn.filtroWhere = str_filtro_where

                return objReturn
            }
        }


        function setFiltros(nro_pg_filtro) {

            switch (nro_pg_filtro) {
                // Crédito
                case '0':
                    var conceptos = parent.campos_defs.get_value('nro_pago_conceptos').split(', ')

                    // Si alguno de los conceptos elegidos es Muper, Comisión o Reintegro, limpiamos el concepto
                    if (conceptos.indexOf('10') != -1 || conceptos.indexOf('16') != -1 || conceptos.indexOf('17') != -1)
                        parent.campos_defs.set_value('nro_pago_conceptos', '')

                    // Mostrar el filtro seleccionado
                    $('filtroMuper').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').hide()
                    $('filtroCredito').show()

                    parent.aplicar_filtros_extras = true
                    parent.filtro = 'credito'
                    break

                // Comercio MUPER
                case '1':
                    if (parent.campos_defs.get_value('nro_pago_conceptos') != '16')
                        parent.campos_defs.set_value('nro_pago_conceptos', '16')

                    //$('nro_envio').value   = ''
                    //$('nro_credito').value = ''

                    // Mostrar el filtro seleccionado
                    $('filtroCredito').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').hide()
                    $('filtroMuper').show()

                    parent.aplicar_filtros_extras = true
                    parent.filtro = 'muper'
                    break

                // Comisión
                case '2':
                    if (parent.campos_defs.get_value('nro_pago_conceptos') != '17')
                        parent.campos_defs.set_value('nro_pago_conceptos', '17')

                    //campos_defs.clear('fecha_presentacion')
                    //$('nro_envio').value   = ''
                    //$('nro_credito').value = ''

                    // Mostrar el filtro seleccionado
                    $('filtroCredito').hide()
                    $('filtroMuper').hide()
                    $('filtroReintegro').hide()
                    $('filtroComision').show()

                    parent.aplicar_filtros_extras = true
                    parent.filtro = 'comision'
                    break

                // Reintegro
                case '3':
                    if (parent.campos_defs.get_value('nro_pago_conceptos') != '10')
                        parent.campos_defs.set_value('nro_pago_conceptos', '10')

                    //campos_defs.clear('fecha_presentacion')
                    //$('nro_envio').value   = ''
                    //$('nro_credito').value = ''

                    // Mostrar el filtro seleccionado
                    $('filtroCredito').hide()
                    $('filtroMuper').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').show()

                    parent.aplicar_filtros_extras = true
                    parent.filtro = 'reintegro'
                    break

                // Vacio
                case '':
                default:
                    $('filtroCredito').hide()
                    $('filtroMuper').hide()
                    $('filtroComision').hide()
                    $('filtroReintegro').hide()

                    parent.aplicar_filtros_extras = false
                    parent.filtro = null
                    break
            }

        }


        function valDigito_nro_envio(strCaracteres) {
            if (event.keyCode == 13) {
                event.keyCode = 0
                parent.Aceptar()
            }

            if (!strCaracteres)
                strCaracteres = ''

            var key = window.event.keyCode
            var strkey = String.fromCharCode(key)
            var encontrado = strCaracteres.indexOf(strkey) != -1

            if ((strkey < "0" || strkey > "9") && !encontrado)
                window.event.keyCode = 0
        }


        var win_envios


        function Ver_FiltroEnvios() {
            win_envios = parent.nvFW.createWindow({
                title: '<b>Seleccionar Envios</b>',
                url: '/meridiano/Envios_Finalizados.aspx?seleccion=1',
                minimizable: true,
                maximizable: true,
                draggable: true,
                closable: true,
                resizable: true,
                width: 950,
                height: 450,
                parentWidthElement: $$("body")[0],
                parentWidthPercent: 1.0,
                parentHeightElement: $$("body")[0],
                parentHeightPercent: 1.0,
                onClose: Ver_FiltroEnvios_return,
                destroyOnClose: true
            });

            //win_envios.setURL('Envios_Finalizados.aspx?seleccion=1')
            win_envios.options.userData = { filtro_envio: '' }
            win_envios.showCenter(true)
        }


        function editarPago(nro_pago) {
            parent.editarPago(nro_pago)
        }


        function Ver_FiltroEnvios_return() {
            var retorno = win_envios.options.userData.parametros

            if (retorno) {
                filtro_envio = retorno
                $('nro_envio').value = filtro_envio
                parent.Aceptar()
            }
        }


        function getTamanio() {
            var tamanio = $('filtro2').getHeight() + $('btnBuscar').getHeight() + $('ifrpg_filtros').getHeight() + $('pagosImpresion').getHeight()
            return tamanio
        }


        function getIframe() {
            return 'ifrpg_filtros'
        }


        function CargarTipo_Pago() {
            //var rs = new tRS();
            //var $tipo_pago = $('tipo_pago')
            ////$('tipo_pago').options.length = 0
            //$tipo_pago.options.length = 0

            ////rs.open("<criterio><select vista='pago_tipos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
            //rs.open({ filtroXML: nvFW.pageContents.filtro_tipo_pago })

            //while (!rs.eof()) {
            //    $tipo_pago.insert(new Element('option', { value: rs.getdata('nro_pago_tipo') }).update(rs.getdata('pago_tipo')))

            //    if (rs.getdata('nro_pago_tipo') == 1)
            //        $tipo_pago.selectedIndex = $tipo_pago.options.length - 1

            //    //i++
            //    rs.movenext()
            //}

            //$tipo_pago.setStyle({ width: '100%' })

            campos_defs.add('tipo_pago', {
                enDB: false,
                json: true,
                sin_seleccion: false,
                nro_campo_tipo: 1,
                target: 'tdTipo_pago',
                despliega: 'arriba',
                filtroXML: nvFW.pageContents.filtro_tipo_pago
            });

            campos_defs.set_value('tipo_pago', 1);
        }


        function Seleccionar() {

            var mensaje = parent.Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }

            var i
            var ele
            var nro_pagos_registros = ''
            var nombre = ''

            if (typeof ifrpg_filtros.document.all.frmPagos == 'undefined') {
                alert('Debe realizar una busqueda antes de editar.')
                return
            }

            //for (i = 0; ele = ifrRegistros.document.all.frmPagos.elements[i]; i++) {
            //for (i = 0; ele = ObtenerVentana(iframeExportar).document.all.frmPagos.elements[i]; i++) {
            for (i = 0; ele = ifrpg_filtros.document.all.frmPagos.elements[i]; i++) {
                nombre = ele.id.substring(0, 17)

                if (ele.type == 'hidden' && nombre == 'nro_pago_registro') {
                    if (nro_pagos_registros == '')
                        nro_pagos_registros = ele.value
                    else
                        nro_pagos_registros += ", " + ele.value
                }
            }

            parent.Parametros["nro_pagos_registros"] = nro_pagos_registros
            parent.Parametros["filtro_envios"] = $('nro_envio').value

            //switch ($('tipo_pago').value) {
            switch (campos_defs.get_value('tipo_pago')) {
                // Cheque Bejerman
                case '6': {
                    win_chequera = nvFW.createWindow({
                        title: '<b>Seleccionar Chequera</b>',
                        url: 'Pagos_distribucion_chequera.aspx',
                        minimizable: true,
                        maximizable: true,
                        draggable: false,
                        closable: true,
                        width: 800,
                        height: 170,
                        resizable: false,
                        onClose: function () { setTimeout('parent.Aceptar()', 100) },
                        destroyOnClose: true
                    });

                    win_chequera.options.userData = { Parametros: parent.Parametros }
                    //win_chequera.setURL('Pagos_distribucion_chequera.aspx')
                    win_chequera.showCenter(true)
                }
                    break

                // Depósito 3eros
                case '1': {
                    win_depositos = window.top.nvFW.createWindow({
                        title: '<b>Editar Pagos - Depósitos</b>',
                        url: 'pagos/Pagos_distribucion_deposito.aspx',
                        minimizable: true,
                        maximizable: true,
                        draggable: false,
                        closable: true,
                        width: 1024,
                        height: 520,
                        resizable: false,
                        onClose: function () { setTimeout('parent.Aceptar()', 100) },
                        destroyOnClose: true
                    });

                    win_depositos.options.userData = { Parametros: parent.Parametros }
                    //win_depositos.setURL('Pagos_distribucion_deposito.aspx')
                    win_depositos.showCenter(true)
                }
                    break

                // Efectivo
                case '4': {
                    win_efectivo = window.top.nvFW.createWindow({
                        title: '<b>Editar Pagos - Efectivo</b>',
                        url: 'pagos/Pagos_distribucion_efectivo.aspx',
                        minimizable: true,
                        maximizable: true,
                        draggable: false,
                        closable: true,
                        width: 850,
                        height: 500,
                        resizable: false,
                        onClose: function () { setTimeout('parent.Aceptar()', 100) },
                        destroyOnClose: true
                    });

                    win_efectivo.options.userData = { Parametros: parent.Parametros }
                    //win_efectivo.setURL('Pagos_distribucion_efectivo.aspx')
                    win_efectivo.showCenter(true)
                }
                    break

                // Giro
                case '8': {
                    win_giro = window.top.nvFW.createWindow({
                        title: '<b>Editar Pagos - Giro</b>',
                        url: 'Pagos_distribucion_giro.aspx',
                        minimizable: true,
                        maximizable: true,
                        draggable: false,
                        closable: true,
                        width: 850,
                        height: 500,
                        resizable: false,
                        onClose: function () { setTimeout('parent.Aceptar()', 100) },
                        destroyOnClose: true
                    });

                    win_giro.options.userData = { Parametros: parent.Parametros }
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


        function RecFondos(nro_pago_tipo) {
            var strfiltro_pago = ''

            if (nro_pago_tipo)
                strfiltro_pago = "<SQL type='sql'>dbo.rm_credito_tiene_pago_tipo(nro_credito, " + nro_pago_tipo + ") > 0</SQL>"

            var mensaje = parent.Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }

            var filtro_envio_tipo = "<nro_envio_tipo type='SQL'>dbo.rm_esEnvio_tipo_impresion(nro_banco, nro_envio_tipo) = 1</nro_envio_tipo>"

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden>nro_pago_registro</orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + strfiltro_pago + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio>" + filtro_envio_tipo + "</filtro></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_recibo_fondos,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + strfiltro_pago + filtro_envio_tipo + "</filtro></select></criterio>",
                report_name: "recibo_pagos.rpt",
                formTarget: "_blank",
                name: "recibo_pagos",
                filename: "recibo_pagos_" + parent.getStrTime() + ".pdf"
            })
        }


        function Recibos_Reintegros() {
            debugger
            if (parent.$('nro_pago_conceptos').value != '10') {
                alert('Debe seleccionar Reintegros para imprimir el Recibo.')
                return
            }

            var mensaje = parent.Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }

            var nro_pago_detalles = ''
            var rs = new tRS()

            //rs.open("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_detalle</campos><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><nro_pago_concepto type='igual'>10</nro_pago_concepto></filtro></select></criterio>")                      
            rs.open({
                filtroXML: nvFW.pageContents.filtro_nro_pago_detalle,
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
                    filtroXML: nvFW.pageContents.filtro_recibos_reintegros,
                    filtroWhere: "<criterio><select><filtro><nro_pago_detalle type='in'>" + nro_pago_detalles + "</nro_pago_detalle></filtro></select></criterio>",
                    report_name: "recibo_pago_reintegros.rpt",
                    formTarget: "_blank",
                    name: "recibo_pago_reintegros",
                    filename: "recibo_pago_reintegros_" + parent.getStrTime() + ".pdf"
                })
            }
        }


        function CtrolEnvios() {
            var filtro = ''
            var nro_envio_value = $('nro_envio').value
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
                filtroXML: nvFW.pageContents.filtro_control_envios,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                report_name: "control_envios.rpt",
                formTarget: "_blank",
                name: "control_envios",
                filename: "control_envios_" + parent.getStrTime() + ".pdf"
            })
        }


        function Pagos_Envios() {

            var nro_envio_value = $('nro_envio').value
            var nro_credito_value = $('nro_credito').value
            var filtro_credito = ""
            var filtro_envio = ""

            if (nro_credito_value != '')
                filtro_credito = "<nro_credito type='in'>" + nro_credito_value + "</nro_credito>"

            if (nro_envio_value != '')
                filtro_envio = "<nro_envio_gral type='in'>" + nro_envio_value + "</nro_envio_gral>"

            if (filtro_credito == '' && filtro_envio == '') {
                alert('Debe seleccionar un crédito o un envio para generar el reporte.')
                return
            }

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>convert(float,nro_cheque) as nro_cheque01, *</campos><orden>nro_cheque01 asc</orden><filtro>" + filtro_credito + filtro_envio + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><nro_pago_tipo type='in'>1,6,8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_pagos_envios,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + "</filtro></select></criterio>",
                report_name: "pagos_envios.rpt",
                formTarget: "_blank",
                name: "pagos_envios",
                filename: "pagos_envios_" + parent.getStrTime() + ".pdf"
            })
        }


        function Pagos_Tipos() {
            var mensaje = parent.Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>distinct convert(float,nro_cheque) as nro_cheque01, *</campos><orden>nro_cheque01 asc</orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "<nro_pago_estado type='in'>2,4,5</nro_pago_estado><nro_pago_tipo type='in'>1,4,6,8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_pago_tipos,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "</filtro></select></criterio>",
                report_name: "pagos_tipos.rpt",
                formTarget: "_blank",
                name: "pagos_tipos",
                filename: "pagos_tipos_" + parent.getStrTime() + ".pdf"
            })
        }


        function SeguimientoPagos() {
            nvFW.transferenciaEjecutar({
                id_transferencia: 191,
                xml_param: '',
                pasada: 0,
                formTarget: 'winPrototype',
                async: false,
                ej_mostrar: true,
                winPrototype: {
                    modal: true,
                    center: true,
                    bloquear: false,
                    url: '/FW/enBlanco.htm',
                    title: '<b>Seguimiento de Pagos</b>',
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


        function CtrolFondosCheques() {
            var mensaje = parent.Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }

            nvFW.mostrarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden></orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "<nro_pago_tipo type='igual'>6</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_ctrl_fondos_cheques,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_pendientes + filtro_suspendidos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "</filtro></select></criterio>",
                report_name: "control_fondos_cheques.rpt",
                formTarget: "_blank",
                name: "control_fondos_cheques",
                filename: "control_fondos_cheques_" + parent.getStrTime() + ".pdf"
            })
        }


        function CtrolPagosExcel() {
            var mensaje = parent.Validar_Filtro()

            if (mensaje != '') {
                alert(mensaje)
                return
            }

            nvFW.exportarReporte({
                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>distinct pago_concepto,pago_tipo,pago_estados,CASE WHEN not dep_cuenta_desc IS NULL THEN ISNULL(dep_cuenta_desc,'') ELSE '' END as cuenta,CASE WHEN not nro_cheque IS NULL THEN nro_cheque ELSE '' END as cheque,razon_social as destinatario,documento,nro_docu,strnombrecompleto,nro_envio,nro_envio_gral,nro_credito,mutual,banco,importe_bruto,importe_neto,importe_pago,ISNULL(fe_estado,'') AS fecha_estado</campos><orden></orden><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "<nro_pago_estado type='in'>1,2,4,5</nro_pago_estado><nro_pago_tipo type='in'>1,4,6,8</nro_pago_tipo><estado_envio type='igual'>'F'</estado_envio><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_control_pagos_excel,
                filtroWhere: "<criterio><select><filtro>" + filtro_credito + filtro_envio + filtro_conceptos + filtro_entidad + filtro_mutual + filtro_fe_descuento + filtro_numero + filtro_fe_liq + filtro_nro_liq_cab + filtro_fe_pago_desde + filtro_fe_pago_hasta + filtro_pagos_muper + filtro_pagos_comision + "</filtro></select></criterio>",
                path_xsl: "report\\wrp_verpg_registro\\EXCEL_control_pagos.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                content_disposition: "attachment",
                formTarget: "frameExcel",
                filename: "control_pagos.xls"
            })
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <div id="divMenuPagos" style="margin: 0px; padding: 0px;"></div>

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

    <iframe style="width: 100%; height: 100%; border-style: none" name="ifrpg_filtros" id="ifrpg_filtros" src="/FW/enBlanco.htm"></iframe>

    <table class="tb1" id="pagosImpresion">
        <tr class="tbLabel">
            <td colspan="2" style="width: 50%">Editar Pagos</td>
            <td colspan="2" style="width: 50%">Impresión de Reportes</td>
        </tr>
        <tr>
            <td id="tdTipo_pago" style="width: 30%">
                <%--<select name="tipo_pago" id="tipo_pago"></select>--%>
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
                <div id='divImprimir' style='width: 100%'></div>
            </td>
        </tr>
    </table>

</body>
</html>
