var win_error_nosis
var win_nosis_generar
var btn_aceptar_nosis = false
var NosisXML = ''
var strHTMLNosis = ''

function VerInformeNosis() {
    //" (permisos_precarga & 2) <= 0)
    if (!nvFW.tienePermiso("permisos_precarga", 2)) {
        nvFW.alert('No posee permisos para generar el informe')
        return
    }
    if (strHTMLNosis == '') {
        if (consulta.resultado.dictamen == 'RECHAZADO') {
            nvFW.alert('No se puede generar el informe para una solicitud Rechazada.')
            return
        }
        win_nosis_generar = createWindow2({
            title: '<b>Generar Informe Nosis</b>',
            parentWidthPercent: 0.8,
            //parentWidthElement: $("contenedor"),
            maxWidth: 450,
            maxHeight: 150,
            //centerHFromElement: $("contenedor"),
            minimizable: false,
            maximizable: false,
            draggable: false,
            resizable: true,
            closable: false,
            recenterAuto: true,
            setHeightToContent: true,
            //destroyOnClose: true,
            onClose: function () {
                if (btn_aceptar_nosis)
                    NOSIS_generar_informe2(consulta.cliente.cuit)
            }
        });
        var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
        html += "<table class='tb1'><tr><td class='Tit1' style='text.align:center'><br>Desea generar el informe Nosis?<br></td></tr></table></br>"
        html += "<div style='text-align:center;width:49%;float:left'><input type='button' style='width:90%' value='Generar Informe' onclick='win_nosis_generar_cerrar(true)'/></div>"
        html += "<div style='text-align:center;width:49%;float:left'><input type='button' style='width:90%' value='Cancelar' onclick='win_nosis_generar_cerrar(false)'/></div>"
        html += "</body></html>"
        win_nosis_generar.setHTMLContent(html)
        win_nosis_generar.showCenter(true)
    }

    else {
        strHTMLNosis = replace(strHTMLNosis, "undefined", "'")
        mostrarHTMLNosis(strHTMLNosis)
    }
}


function NOSIS_generar_informe2(cuit, reintento) {
    var HTML_bloqueo = "<input type='button' id='btn_cancelar' style='width:20px' value='Detener' style='cursor: pointer !important' />"

    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Generando informe de Nosis&nbsp;&nbsp;&nbsp;<img border="0" id="img_cancelar" src="image/cancel.png" align="absmiddle" title="Cancelar" style="vertical-align:middle; cursor: pointer" />')

    var oXML = new tXML();
    try {
        // mixpanel.track("consultar_nosis"); //registrar el evento consultar_nosis
        var reintentos = "<reintentos>1</reintentos>"
        if (reintento == 0) reintentos = ""

        //let criterio = '<criterio><cuit>' + cuit + '</cuit><CDA>' + CDA + '</CDA><nro_vendedor>' + consulta.nro_vendedor + '</nro_vendedor><nro_banco>' + campos_defs.get_value("banco") + '</nro_banco>' + reintentos + '</criterio>';

        //nvFW.error_ajax_request('/FW/servicios/NOSIS/GetXML.aspx', {
        //    parameters: {
        //        accion: 'SAC_informe',
        //        criterio: criterio
        //    },
        //    onSuccess: function (err) {
        //        debugger;
        //    },
        //    onFailure: function (err) {
        //        debugger;
        //    }
        //});

        oXML.async = true
        oXML.method = 'POST'
        oXML.onFailure = function () { nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga') }
        oXML.load('/FW/servicios/NOSIS/GetXML.aspx', 'accion=SAC_informe&criterio=<criterio><cuit>' + cuit + '</cuit><CDA>' + CDA + '</CDA><nro_vendedor>' + consulta.nro_vendedor + '</nro_vendedor><nro_banco>' + campos_defs.get_value("banco") + '</nro_banco>' + reintentos + '</criterio>',
            function () {
                debugger;
                strXML = XMLtoString(oXML.xml)
                NosisXML = strXML
                objXML = new tXML();
                objXML.async = false
                var novedad = ""

                if (objXML.loadXML(strXML))
                    var NODs = objXML.selectNodes('Respuesta/ParteHTML')

                var NOD_novedad = oXML.selectNodes('Respuesta/Consulta/Resultado')
                if (NOD_novedad.length > 0)
                    novedad = XMLText(selectSingleNode('Novedad', NOD_novedad[0]))

                if (NODs[0])
                    strHTMLNosis = XMLText(NODs[0])

                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')

                if (novedad != "") {
                    //  alert("NOSIS: " + novedad)
                    win_error_nosis = createWindow2({
                        title: '<b>Notificacion nosis</b>',
                        maxWidth: 450,
                        maxHeight: 100,
                        // recenterAuto: true,
                        //  setHeightToContent: true,
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        resizable: true
                    });

                    var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
                    html += '<table class="tb1">'
                    html += '<tbody><tr><td colspan="3">' + novedad + '</td></tr><tr><td colspan="3"></td></tr>'
                    html += '<tr><td style="text-align:center;width:25%"><input type="button" style="width:80%" value="Reintentar" onclick="reintentar(' + consulta.cliente.cuit + ', 1)" style="cursor:pointer" /></td>'
                    html += '<td style = "text-align:center;width:25%" ><input type="button" style="width:80%" value="Generarlo igual" onclick="reintentar(' + consulta.cliente.cuit + ', 0)" style="cursor:pointer" /></td>'
                    html += '<td style = "text-align:center;width:25%" ><input type="button" style="width:80%" value="Cerrar" onclick="win_error_nosis.close()" style="cursor:pointer" /></td></tr > '
                    html += '</tbody></table></body></html>'

                    win_error_nosis.setHTMLContent(html)
                    win_error_nosis.showCenter(true)

                    return
                }

                if (strHTMLNosis == '') {
                    alert("Error al consultar los datos.")
                    return
                }

                strHTMLNosis = replace(strHTMLNosis, "undefined", "'")
                mostrarHTMLNosis(strHTMLNosis)
            }
        )
    } catch (e) {
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        alert("Error al generar nosis.")
    }
    $('img_cancelar').observe("click", function () { NOSIS_generar_informe2_cancel(oXML) })
}


function mostrarHTMLNosis(strHTML) {
    if (nvFW.nvInterOP) {
        //window.open("data:text/html;charset=utf-8," + strHTMLNosis, "", "https://nullurl.redmutual.com.ar")
        window.open("_null?content=" + encodeURIComponent(strHTMLNosis))
    } else {
        var win = window.open()
        win.document.write(strHTMLNosis)
    }
}


function NOSIS_generar_informe2_cancel(oXML) {
    try {
        oXML.abort()
    }
    catch (e) { }//divBloq_msg_blq_precarga
    //$("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "" })
    //$("divBloq_" + 'msg_blq_precarga')._DivMsg.setStyle({ background: "" })
    // nvFW.bloqueo_desactivar(null, 'msg_blq_precarga')
    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
    // Precarga_Limpiar()
}


function reintentar(cuit, intento) {
    NOSIS_generar_informe2(cuit, intento)
    win_error_nosis.close()
}


function win_nosis_generar_cerrar(aceptar) {
    btn_aceptar_nosis = aceptar
    win_nosis_generar.close()
}