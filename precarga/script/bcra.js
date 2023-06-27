
const bcra_canvas = 'strSitBCRA'


function bcra_limpiar_html() {
    $(bcra_canvas).innerHTML = ''
    $(bcra_canvas).removeClassName($(bcra_canvas).className)
}


function bcra_get_sit_html() {

    bcra_limpiar_html();

    $(bcra_canvas).insert({ bottom: consulta.oferta.bcra_sit })
    switch (consulta.oferta.bcra_sit) {
        case '1':
            $(bcra_canvas).addClassName('sit1')
            break;
        case '2':
            $(bcra_canvas).addClassName('sit2')
            break;
        case '3':
            $(bcra_canvas).addClassName('sit3')
            break;
        case '4':
            $(bcra_canvas).addClassName('sit4')
            break;
        case '5':
            $(bcra_canvas).addClassName('sit5')
            break;
        case '6':
            $(bcra_canvas).addClassName('sit6')
            break;
    }
}


//dado los parametros, consulta el central de deudores y lo devuelve en tr para su asignacion en los tags html
//en el array, pueden venir varias cadenas html a reemplazar
var BCRABodyHTML = function (cuit, nro_grupo, nro_tipo_cobro, nro_banco_cobro, arrHtml) {

    var rsBCRA = new tRS()
    var color = 'green'
    var marca_exc = ''
    var style_exc = ''
    var obs = ''
    var fecha_info = ''
    rsBCRA.open({
        filtroXML: nvFW.pageContents["BCRA_deudores"],
        params: "<criterio><params cuil='" + cuit + "' nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco='" + nro_banco_cobro + "' /></criterio>"
    })
    var strTR = ""
    while (!rsBCRA.eof()) {
        fecha_info = rsBCRA.getdata('fecha_info')
        var situacion = rsBCRA.getdata('situacion').trim()
        switch (situacion) {
            case '1':
                color = 'green'
                break;
            case '2':
                color = '#FFD700'
                break;
            case '3':
                color = '#f0f'
                break;
            case '4':
                color = '#c33'
                break;
            case '5':
                color = 'maroon'
                break;
            case '6':
                color = '#000'
                break;
        }
        hpx = hpx + 20
        marca_exc = ''
        obs = ''
        style_exc = 'text-align:left'
        if (rsBCRA.getdata('excluyente') != undefined) {
            marca_exc = '<b>*</b>'
            style_exc = 'text-align:left;font-weight: bold;color:#800000'
        }
        if (rsBCRA.getdata('recat_obligatoria') == 1)
            obs += '(B)'
        if (rsBCRA.getdata('sit_juridica') == 1)
            obs += '(C)'
        strTR += '<tr><td style="' + style_exc + '">' + rsBCRA.getdata('noment') + ' ' + marca_exc + '</td><td>' + rsBCRA.getdata('fecha_info') + '</td><td style="background-color: ' + color + ';color: #fff;text-align:right" title="' + rsBCRA.getdata('fecha_info') + '" ><b>' + rsBCRA.getdata('prestamos') + '</b></td><td style="background-color: ' + color + ';color: #fff;" title="' + rsBCRA.getdata('fecha_info') + '"><b>' + rsBCRA.getdata('situacion') + '</b></td><td>' + obs + '</td></tr>'
        rsBCRA.movenext()
    }//while

    for (r in arrHtml) {
        arrHtml[r]['html'] = arrHtml[r]['html'].replace('{tr_body_bcra}', strTR)
        arrHtml[r]['html'] = arrHtml[r]['html'].replace('{fecha_info}', fecha_info)
    }
    return arrHtml;
}


function BCRA_obtener(strXML) {
    try {
        var SitBCRA = {}
        objXML = new tXML();
        objXML.async = false
        if (objXML.loadXML(strXML)) {
            Deuda = objXML.getElementsByTagName('Deuda')
            NroConsulta = XMLText(objXML.selectSingleNode('Respuesta/Consulta/NroConsulta'))
            consulta.cliente.cuit = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Doc'))
            consulta.cliente.razon_social = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/RZ'))
            consulta.cliente.edad = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/Edad')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Edad')) : '99'
            consulta.cliente.documento = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Tipo'))
            consulta.cliente.domicilio = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Dom')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Dom')) : ''
            consulta.cliente.localidad = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Loc')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Loc')) : ''
            consulta.cliente.CP = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/CP')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/CP')) : sucursal_postal_real
            consulta.cliente.provincia = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Prov')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Prov')) : ''
            switch (documento) {
                case 'DNI':
                    consulta.cliente.tipo_docu = 3
                    break;
                case 'LE':
                    consulta.cliente.tipo_docu = 1
                    break;
                case 'LC':
                    consulta.cliente.tipo_docu = 2
                    break;
                default:
                    consulta.cliente.tipo_docu = 3
            }
            consulta.cliente.nro_docu = consulta.cliente.cuit.substring(2, 10)
            consulta.cliente.sexo = 'M'
            consulta.cliente.sexo_desc = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Sexo'))
            if (sexo_desc == 'Femenino')
                consulta.cliente.sexo = 'F'
            fe_naci_str = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/FecNac')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/FecNac')) : ''
            consulta.cliente.fe_naci = (fe_naci_str != '') ? fe_naci_str.substring(6, 8) + '/' + fe_naci_str.substring(4, 6) + '/' + fe_naci_str.substring(0, 4) : ''
            $('strApeyNomb').innerHTML = ''
            $('strApeyNomb').insert({ bottom: razon_social })
            //$('strCUIT').innerHTML = ''
            //$('strCUIT').insert({ bottom: consulta.cliente.cuit })
            //$('strFNac').innerHTML = ''
            //if (consulta.cliente.fe_naci != '')
            //    $('strFNac').insert({ bottom: consulta.cliente.fe_naci + ' (' + edad + ')' })
            var rs = new tRS();


            rs.open({ filtroXML: nvFW.pageContents["sit_bcra"], params: "<criterio><params id_consulta='" + NroConsulta + "' /></criterio>" })
            if (!rs.eof())
                sit_bcra = rs.getdata('situacion')

            $('strSitBCRA').innerHTML = ''
            $('strSitBCRA').insert({ bottom: sit_bcra })
            $('strSitBCRA').removeClassName($('strSitBCRA').className)
            switch (sit_bcra) {
                case '1':
                    $('strSitBCRA').addClassName('sit1')
                    break;
                case '2':
                    $('strSitBCRA').addClassName('sit2')
                    break;
                case '3':
                    $('strSitBCRA').addClassName('sit3')
                    break;
                case '4':
                    $('strSitBCRA').addClassName('sit4')
                    break;
                case '5':
                    $('strSitBCRA').addClassName('sit5')
                    break;
                case '6':
                    $('strSitBCRA').addClassName('sit6')
                    break;
            }
            empresa = objXML.getElementsByTagName('CalculoCDA')[0].getAttribute('Titulo')
            HTMLCDA += "<html><head></head><body style='width:100%;height:100%;overflow:hidden'><table class='tb1 highlightEven'><tr><td style='width:30%'><b>CDA</b></td><td style='width:80%' class='Tit1'>" + empresa + "</td></tr>"

            itemsCDA = objXML.getElementsByTagName('Item')
            for (var i = 0; i < itemsCDA.length; i++) {
                descripcion = XMLText(itemsCDA[i].childNodes[0])
                if (descripcion == 'Dictamen') {
                    valor = "<b>" + XMLText(itemsCDA[i].childNodes[1]) + "</b>"
                    dictamen = XMLText(itemsCDA[i].childNodes[1])
                    $('strDictamen').innerHTML = ''
                    $('strDictamen').insert({ bottom: dictamen })
                    $('strDictamen').removeClassName($('strDictamen').className)
                    switch (dictamen) {
                        case 'APROBADO':
                            $('strDictamen').addClassName('cdaAC')
                            break;
                        case 'OBSERVADO':
                            $('strDictamen').addClassName('cdaOB')
                            break;
                        case 'RECHAZADO':
                            $('strDictamen').addClassName('cdaRC')
                            break;
                    }
                }
                else
                    valor = XMLText(itemsCDA[i].childNodes[1])
                HTMLCDA += "<tr><td style='width:30%'>" + descripcion + "</td><td style='text-align:center'>" + valor + "</td></tr>"
            }
            HTMLCDA += "</table></body></html>"
            $('strFuentes').innerHTML = ''
            var parteHTML = XMLText(objXML.selectSingleNode('Respuesta/ParteHTML'))
            var res = parteHTML.search(/Falta último Informe BCRA/)
            if (res != -1)
                $('strFuentes').insert({ bottom: ' - Falta último Informe BCRA' })

            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            Control_socio()
        }
    }
    catch (err) {
        rserror_handler('No se puede generar la consulta de NOSIS. Intente nuevamente.')
    }
}