

//mover a la salida del motor y no llamar a planes
function Validar_datos() {

    if (consulta.cliente.fe_naci == '') {
        //gjmo -> de donde sale fe_naci_socio
        consulta.cliente.fe_naci = fe_naci_socio
        edad = edad_socio
    }

    if (consulta.cliente.fe_naci == '') {
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        win_edad = createWindow2({
            title: '<b>No se pudo obtener la edad de la persona</b>',
            parentWidthPercent: 0.8,
            //parentWidthElement: $("contenedor"),
            maxWidth: 450,
            //centerHFromElement: $("contenedor"),
            minimizable: false,
            maximizable: false,
            draggable: false,
            resizable: true,
            closable: false,
            recenterAuto: true,
            setHeightToContent: true,
            onClose: function () {
                consulta.cliente.fe_naci = $('fe_naci').value
                consulta.cliente.edad = getEdad(consulta.cliente.fe_naci)
                $('strFNac').innerHTML = ''
                $('strFNac').insert({ bottom: consulta.cliente.fe_naci + ' (' + edad + ')' })
                if (btn_aceptar) {
                    if ((nro_mutual == '') || (nro_banco == '')) btnBuscarPLanes_onclick()
                }

            }
        });
        var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
        html += '<table class="tb1">'
        html += '<tbody><tr><td class="Tit1"><b>Ingrese la fecha de nacimiento</b></td><td><input type="text" value="" id="fe_naci" style="width:100%" onkeypress="return valDigito(event, \'/\')" onchange="valFecha(event)" /></td></tr>'
        html += '<tr><td style="text-align:center;width:50%"><br><input type="button" style="width:80%" value="Cancelar" onclick="win_edad_cerrar(false)" style="cursor:pointer" /></td><td style="text-align:center;width:50%"><br><input type="button" style="width:80%" value="Aceptar" onclick="win_edad_cerrar(true)" style="cursor:pointer"/></td></tr>'
        html += '</tbody></table></body></html>'

        win_edad.setHTMLContent(html)
        win_edad.showCenter(true)
    }
    //quitar else
    else
        btnBuscarPLanes_onclick()
}


function btnBuscarPLanes_onclick() {

    consulta.plan = {};

    let nro_grupo = consulta.cliente.trabajo.nro_grupo

    if ((!$('chkmax_disp').checked) && (($('retirado_desde').value == '') && ($('retirado_hasta').value == '') && ($('importe_cuota_desde').value == '') && ($('importe_cuota_hasta').value == '') && ($('cuota_desde').value == '') && ($('cuota_hasta').value == ''))) {
        nvFW.alert('Ingrese algún filtro para realizar la búsqueda.')
        return
    }

    //Filtros opcionales
    let strWhere_planes = '';
    if (campos_defs.get_value('cuota_desde') != '')
        strWhere_planes += "<cuotas type='mas'>" + campos_defs.get_value('cuota_desde') + "</cuotas>"
    if (campos_defs.get_value('cuota_hasta') != '')
        strWhere_planes += "<cuotas type='menos'>" + campos_defs.get_value('cuota_hasta') + "</cuotas>"

    let params = get_criterio_params(nro_grupo);

    nvFW.bloqueo_activar($('divFiltros'), 'blq_precarga_planes', 'buscando planes...')

    var fxOnComplete = function () {
        nvFW.bloqueo_desactivar($('divFiltros'), 'blq_precarga_planes')
        //var tbCabe_h = $('ifrplanes').contentWindow.document.getElementById('tbCabe').getHeight()
        //var div_lst_creditos_h = $('ifrplanes').contentWindow.document.getElementById('div_lst_creditos').getHeight()
        //var div_pag_h = $('ifrplanes').contentWindow.document.getElementById('div_pag').getHeight()
        $('ifrplanes').setStyle({ height: /*tbCabe_h + div_lst_creditos_h + div_pag_h + 25*/ 300 + 'px' })
        console.log("fin carga de planes")
        if (!!$('ifrplanes').contentWindow.document.getElementById('tdrdplan1'))
            $('ifrplanes').contentWindow.document.getElementById('tdrdplan1').parentNode.onclick();
        else dibujar_propuesta();

        return true;
    }

    drawplanes(strWhere_planes, params, fxOnComplete)

    //nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')

    //let nro_mutual = campos_defs.get_value('mutual') //$('mutual').value
    //if ($('chkmax_disp').checked) {

    //    if (nro_mutual == 168) {

    //        var rs = new tRS();
    //        rs.async = true
    //        rs.open(nvFW.pageContents.max_cuota_plan, "", strWhere_planes)
    //        rs.onComplete = function (rs) {
    //            var importe_cuota_maxplan = "0";
    //            while (!rs.eof()) {
    //                importe_cuota_maxplan += (importe_cuota_maxplan != "") ? "," + rs.getdata("importe_cuota") : rs.getdata("importe_cuota")
    //                rs.movenext()
    //            }

    //            strWhere_planes += "<importe_cuota type='in'>" + importe_cuota_maxplan + "</importe_cuota>"
    //            strWhere_planes += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
    //            if ($('cuota_hasta').value != '') {
    //                strWhere_planes += "<cuotas type='menos'>" + $('cuota_hasta').value + "</cuotas>"
    //            }
    //        }
    //    }

    //}


}


function drawplanes(strWhere_planes, params, fxOnComplete = () => { }) {

    var filtroXML = $('chkmax_disp').checked ? nvFW.pageContents.planes_lotes_agrupado : nvFW.pageContents.planes_lotes

    nvFW.exportarReporte({
        filtroXML: filtroXML,
        filtroWhere: "<criterio><select><filtro>" + strWhere_planes + "</filtro></select></criterio>",
        params: params,
        path_xsl: 'report/verPlanes_lotes/lst_planes_precarga_HTML.xsl',
        formTarget: 'ifrplanes',
        //bloq_msg: 'Buscando planes...',
        //bloq_contenedor: $('ifrplanes'),
        async: true,
        nvFW_mantener_origen: true,
        funComplete: function (e) {
            fxOnComplete();
        }
    })
}


function btnSelPlan_onclick(nro_plan, importe_neto1, importe_bruto, cuotas, importe_cuota, plan_banco, nro_tipo_cobro, gastoscomerc) {

    consulta.plan = {};
    consulta.plan.nro_plan = nro_plan
    consulta.plan.importe_neto = importe_neto1
    consulta.plan.importe_bruto = importe_bruto
    consulta.plan.cuotas = cuotas
    consulta.plan.importe_cuota = importe_cuota
    consulta.plan.plan_banco = plan_banco
    consulta.plan.gastoscomerc = gastoscomerc

    analisis.set_etiqueta('importe_cuota', consulta.plan.importe_cuota)
    analisis.set_etiqueta('importe_neto', consulta.plan.importe_neto)
    analisis.set_etiqueta('importe_bruto', consulta.plan.importe_bruto)
    analisis.set_etiqueta('gastoscomerc', consulta.plan.gastoscomerc)

    //gjmo -> ver
    form1.importe_cuota.value = importe_cuota;
    analisis.actualizar();

    dibujar_propuesta(importe_neto1, cuotas, importe_cuota);

    //$("importe_prevision_coseguro").value = 0
    //if (campos_defs.get_value('mutual') == 168) {
    //    var rs = new tRS();
    //    rs.async = false;
    //    rs.open({ filtroXML: nvFW.pageContents["planes2"], params: "<criterio><params nro_plan='" + nro_plan + "' /></criterio>" })
    //    //rs.open("<criterio><select vista='planes'><campos>dbo.piz5D_money('cuota_credito2',importe_bruto,cuotas,nro_banco,nro_mutual,nro_grupo) as prevision_coseguro</campos><filtro><nro_plan type='igual'>" + nro_plan + "</nro_plan></filtro><orden></orden></select></criterio>")
    //    if (!rs.eof()) {
    //        $("importe_prevision_coseguro").value = rs.getdata('prevision_coseguro')
    //    }
    //}

}


//gjmo -> ver
function chkmax_disp_on_click() {
    if ($('chkmax_disp').checked) {
        $('divFiltrosLeft').hide()
        $('divFiltrosRight').hide()
        $('divFiltros2Left').hide()
        $('divFiltros2Right').hide()
        $('divFiltros3Left').hide()
        $('divFiltros3Right').hide()
    }
    else {
        $('divFiltrosLeft').show()
        $('divFiltrosRight').show()
        $('divFiltros2Left').show()
        $('divFiltros2Right').show()
        $('divFiltros3Left').show()
        $('divFiltros3Right').show()
    }
}


function selplan_on_click() {
    if ($('selplan').checked) {
        $('ifrplanes').show()
        $('tbfiltros').show()
        $('chkmax_disp').checked = true
        $('divFiltrosLeft').show()
        $('divFiltrosRight').show()
        $('divFiltros2Left').show()
        $('divFiltros2Right').show()
        $('divFiltros3Left').show()
        $('divFiltros3Right').show()
    }
    else {
        $('ifrplanes').hide()
        $('tbfiltros').hide()
    }
}


function get_criterio_params(nro_grupo, nro_plan) {
    let params = "<criterio><params tiene_seguro='" + tiene_seguro + "' nro_tipo_cobro='" + consulta.nro_tipo_cobro + "' nro_grupo='" + nro_grupo + "' "
    params += "nro_tablas='" + consulta.oferta.nro_tablas + "' marca='S' "

    params += !!nro_plan ? "nro_plan='" + nro_plan + "' " : '';

    let campo_max = ''
    let campo_min = ''
    if (consulta.cliente.sexo == 'M') {
        campo_max = 'edad_max_masc'
        campo_min = 'edad_min_masc'
    }
    else {
        campo_max = 'edad_max_fem'
        campo_min = 'edad_min_fem'
    }

    params += "campo_min='" + campo_min + "' campo_max='" + campo_max + "' fe_naci='" + ajustarFecha(consulta.cliente.fe_naci).replace(/'/g, "&apos;") + "' "

    var maxImporte = objCancelaciones.totalCancelaciones;

    if (campos_defs.get_value('retirado_desde') != "")
        if (parseFloat(campos_defs.get_value('retirado_desde')) > parseFloat(objCancelaciones.totalCancelaciones))
            maxImporte = campos_defs.get_value('retirado_desde')

    params += "neto_minimo='" + maxImporte + "' "

    let importe_cuota_desde = campos_defs.get_value('importe_cuota_desde') == '' ? 0 : campos_defs.get_value('importe_cuota_desde');
    params += "importe_cuota_desde='" + importe_cuota_desde + "' "

    let importe_cuota_hasta = campos_defs.get_value('importe_cuota_hasta')
    importe_cuota_hasta = importe_cuota_hasta != '' && importe_cuota_hasta < analisis.cuota_maxima ? importe_cuota_hasta : analisis.cuota_maxima;
    params += "importe_cuota_hasta='" + importe_cuota_hasta + "' "

    if (campos_defs.get_value('retirado_hasta') != '')
        params += "neto_maximo='" + campos_defs.get_value('retirado_hasta') + "' "

    params += "sexo='" + consulta.cliente.sexo + "' "

    params += "/></criterio>"

    return params
}


function planes_limpiar() {

    let nro_plan_sel = !!consulta.plan.nro_plan ? consulta.plan.nro_plan : 0;

    $('ifrplanes').src = 'enBlanco.htm';
    consulta.plan = {};
    if (!!form1.importe_cuota)
        form1.importe_cuota.value = 0;

    //Actualizar analisis si habia un plan seleccionado
    if (analisis.nro_analisis != 0 && nro_plan_sel != 0) {
        analisis.set_etiqueta('importe_cuota', consulta.plan.importe_cuota);
        analisis.set_etiqueta('importe_neto', consulta.plan.importe_neto);
        analisis.set_etiqueta('importe_bruto', consulta.plan.importe_bruto);
        analisis.set_etiqueta('gastoscomerc', consulta.plan.gastoscomerc);
        analisis.actualizar();
    }

    const tablePlanes = $('tbfiltros');
    Array.from(tablePlanes.getElementsByTagName('input')).forEach((inputPlanes) => {
        if (!!campos_defs.items[inputPlanes.id])
            campos_defs.clear(inputPlanes.id);
    })
}


//consulta.planes.validar()
function validarPlan(nro_grupo, nro_plan) {
    let params = get_criterio_params(nro_grupo, nro_plan);
    let mensaje = '';
    let valido = true;

    let rs = new tRS();

    rs.open(nvFW.pageContents.planes_lotes, '', '', '', params);

    if (rs.lastError.numError != 0) {
        mensaje = 'Error al validar plan';
        valido = false;
    }

    if (valido && rs.eof()) {
        mensaje = '<b>El plan seleccionado no es valido para la configuración actual.</b><br>Vuelva a realizar la búsqueda de planes y seleccione nuevamente.';
        valido = false;
    }

    return { valido: valido, mensaje: mensaje }

}


function dibujar_propuesta(importe_neto, cuotas, importe_cuota) {

    //let strHTML = '<div>PROPUESTA MÁXIMA</div>';
    let strHTML = '<div>PROPUESTA</div>';
    strHTML += '<div id="divMaxPlan">$' + (!!importe_neto ? importe_neto : '0') + '</div>';
    strHTML += '<div id="divMaxCuotas">' + (!!cuotas ? cuotas + ' cuotas de <b>$' + importe_cuota + '</b>' : '0 cuotas de <b>$0</b>') + '</div>';
    strHTML += '<div id="divPersonalizarPlanes" onclick="mostrarDivPlanes(true)"><a href="javascript:;">Personalizar</a></div>';

    $('divPropuestaMaxima').innerHTML = strHTML;

}

//function SeleccionarPlanesMostrar() {
//    win_sel_cp = new Window({
//        className: 'alphacube',
//        title: '<b>Seleccionar Provincia</b>',
//        parentWidthPercent: 0.8,
//        //parentWidthElement: $("contenedor"),
//        maxWidth: 430,
//        width: 250,
//        maxHeight: 220,
//        //centerHFromElement: $("contenedor"),
//        minimizable: false,
//        maximizable: false,
//        draggable: false,
//        resizable: true,
//        closable: false,
//        recenterAuto: true,
//        setHeightToContent: true,
//        //destroyOnClose: true,
//        onShow: function () {
//            campos_defs.add('cod_provincia', { target: 'tbProv', enDB: false, nro_campo_tipo: 1, filtroXML: nvFW.pageContents["provincia"] })
//            var rsG = new tRS()
//            rsG.open({ filtroXML: nvFW.pageContents["grupo_provincia"], params: "<criterio><params nro_grupo='" + nro_grupo + "' cod_prov='" + cod_prov_op + "' /></criterio>" })
//            if (!rsG.eof()) {
//                campos_defs.set_value('cod_provincia', rsG.getdata('cod_prov'))
//            }
//        },
//        onClose: function () {
//            if (btn_sel_cp_aceptar) {
//                if (noti_prov == true) {
//                    var param = {}
//                    param['nro_credito'] = 0
//                    win_files = window.top.nvFW.createWindow({
//                        url: 'ABMDocumentos_prov.aspx',
//                        title: '<b>Adjuntar Servicio</b>',
//                        maxHeight: 150,
//                        minimizable: false,
//                        maximizable: false,
//                        draggable: true,
//                        resizable: true,
//                        onClose: ABMArchivos_return
//                    });
//                    win_files.options.userData = { param: param }
//                    win_files.showCenter(true)
//                }
//                else {
//                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Buscando información del producto...(02)')
//                    $('divProducto').show()
//                    $('divFiltros').show()
//                    if (nro_grupo != 0) {
//                        $('ifrplanes').hide()
//                        $('tbfiltros').hide()
//                        $('selplan').hide()
//                        $('selplan').setStyle({ display: 'inline' })
//                    }
//                    else {
//                        $('ifrplanes').show()
//                        $('tbfiltros').show()
//                        $('selplan').setStyle({ display: 'none' })
//                    }
//                    $('tbButtons').show()

//                    $('strEnMano').innerHTML = ''
//                    $('chkmax_disp').checked = true

//                    $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
//                    importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
//                    var socio = false
//                    for (var j in Creditos) {
//                        if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
//                            socio = true
//                            break
//                        }
//                    }
//                    if (!socio)
//                        importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)

//                    //     $('banco').options.length = 0
//                    //    $('mutual').options.length = 0
//                    campos_defs.clear('banco')
//                    campos_defs.clear('mutual')
//                    if (dictamen == 'RECHAZADO' || motor.tiene_mensaje())
//                        VerCDA()

//                    CargarBancos(banco_onchange)
//                }

//            }
//            else
//                consulta.limpiar()
//        }
//    });
//    var html = ""
//    if (persona_existe == false) {
//        html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
//        html += "<table class='tb1' style='width:100%'>"
//        html += "<tbody><tr><td colspan=2 class='Tit1'><br><b>Seleccione la provincia de residencia de la persona. (Debe coincidir con la del servicio a presentar).</b><br><br></td></tr>"
//        html += "<tr><td style='width:30%'>Provincia:</td><td id='tbProv' style='width:70%'>" //<select id='cbprov' style='width:100%'>"
//        html += "</td></tr>"

//        html += "<tr><td style='text-align:center;width:50%' colspan='2'><br><input type='button' value='Aceptar' style='width:50%' onclick='win_sel_cp_onclick(true)'/><br></td></tr>"
//        html += "</tbody></table></body></html>"
//        //
//        win_sel_cp.setHTMLContent(html)
//        win_sel_cp.showCenter(true)


//    }
//    else {
//        nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Buscando información del producto...(03)')
//        $('divProducto').show()
//        $('divFiltros').show()
//        if (nro_grupo != 0) {
//            $('ifrplanes').hide()
//            $('tbfiltros').hide()
//            $('selplan').hide()
//            $('selplan').setStyle({ display: 'inline' })
//        }
//        else {
//            $('ifrplanes').show()
//            $('tbfiltros').show()
//            $('selplan').setStyle({ display: 'none' })
//        }
//        $('tbButtons').show()
//        $('strEnMano').innerHTML = ''
//        $('chkmax_disp').checked = true
//        $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
//        importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
//        var socio = false
//        for (var j in Creditos) {
//            if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
//                socio = true
//                break
//            }
//        }
//        if (!socio)
//            importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)

//        campos_defs.clear('banco')
//        campos_defs.clear('mutual')
//        if (dictamen == 'RECHAZADO' || motor.tiene_mensaje())
//            VerCDA()

//        CargarBancos(banco_onchange)
//    }
//}//SeleccionarPlanesMostrar