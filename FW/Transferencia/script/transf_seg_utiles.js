function backgroundColorEstados(estado) {
    var fondo = ""

    switch (estado.toLowerCase()) {
        case "iniciar":
            fondo = "#1BA261 !Important"
            break
        case "terminado":
            fondo = "#1BA261 !Important"
            break
        case "finalizado":
            fondo = "#1BA261 !Important"
            break
        case "pendiente":
            fondo = "#185683 !Important"
            break
        case "error":
            fondo = "#800000 !Important"
            break
        case "iniciando":
            fondo = "url('/FW/image/transferencia/spinner24x24_azul.gif')"
            break
        case "ejecutando":
            fondo = "#739AC6 !Important"
            break
        default:

    }

    return fondo
}

function getHTMLResultado(arrPropiedades) {
    var obs = arrPropiedades.obs
    var estado = arrPropiedades.estado.toLowerCase()
    var permiso_pendiente = arrPropiedades.permiso_pendiente
    var id_transf_log = arrPropiedades.id_transf_log
    var existe_error = arrPropiedades.existe_error.toLowerCase()
    var estadoCSS = arrPropiedades.existe_error.toLowerCase() == 'error' ? 'error' : estado
    var duracion = arrPropiedades.duracion == '00:00:00' || arrPropiedades.duracion == '' ? '' : '-&nbsp;Duración:&nbsp;<b>' + arrPropiedades.duracion + '</b>&nbsp;'

    var strHTMLBotones = ""
    var strHTMLRes = "<table class='tb1 contenedor' style='width:100%'>"

    strHTMLRes += "<tr>"
    strHTMLRes += "<td colspan='3'>&nbsp;</td>"
    strHTMLRes += "</tr>"

    strHTMLRes += "<tr>"
    strHTMLRes += "<td style='width:35%'>&nbsp;</td>"
    strHTMLRes += "<td style='width:35%'>"
    strHTMLRes += "<table class='tb1' style='width:100%'>"
    strHTMLRes += "<tr>"
    strHTMLRes += "<td class='mnuCELL_Normal_" + estadoCSS + "' onclick='return fn_mostrar_seguimiento(" + id_transf_log + ")' style='color:white;background-color:" + backgroundColorEstados(estadoCSS) + ";text-align:center;cursor:hand' nowrap='nowrap'>&nbsp;Estado:&nbsp;<b>" + estado.toUpperCase() + '</b>&nbsp;' + duracion + " (Código: <u><b>" + id_transf_log +"</b></u>)</td>"

    if (obs != '')
        strHTMLRes += "<tr><td>" + replace(replace(replace(obs, "\n", "</br>"), "\'", "\\'"), "\"", "\\'") + "</td></tr>"

    strHTMLRes += "</tr>"

    if (estado == 'pendiente') {
        if (permiso_pendiente == 1) {
            strHTMLRes += "<tr>"
            strHTMLRes += "<td class='tdSubTitulo'>"
            if (existe_error == 'error') {
                strHTMLRes += "&nbsp;La ejecución finalizó con <span style='color:red'><b>Error</b></span>.</br>"
            }
            strHTMLRes += "¿Desea proseguir con la ejecución?</td>"
            strHTMLRes += "</tr>"

            strHTMLBotones = "<table style='width:100%'><tr>"
            strHTMLBotones += "<td style='width:20%'>&nbsp;</td>"
            strHTMLBotones += "<td style='width:20%'><div style='width: 110px; margin:5px' id='divbtnSiguiente'></div></td>"
            strHTMLBotones += "<td style='width:20%'>&nbsp;</td>"
            strHTMLBotones += "<td style='width:20%'><div style='width: 110px; margin:5px' id='divbtnSalir'></div></td>"
            strHTMLBotones += "<td style='width:20%'>&nbsp;</td>"
            strHTMLBotones += "</tr></table>"

        }
        else {
            strHTMLRes += "<tr>"
            strHTMLRes += "<td class='tdSubTitulo'>Queda a la espera de ser restablecida por otra acción usuario.</td>"
            strHTMLRes += "</tr>"
        }
    }

    if (estado == 'finalizado') {
        strHTMLRes += "<tr>"
        if (existe_error == 'error')
            strHTMLRes += "<td class='tdSubTitulo'>&nbsp;La ejecución finalizó con <span style='color:red;cursor:hand;text-decoration:underline'  onclick='alert(\"" + replace(replace(replace(obs, "\n", "</br>"), "\'", "\\'"), "\"", "\\'") + "\")'><b>Error</b></a></span>.</td>"
        else
            strHTMLRes += "<td class='tdSubTitulo'>&nbsp;La ejecución finalizó correctamente.</td>"
        strHTMLRes += "</tr>"
    }

    strHTMLRes += "<tr><td style='text-align:center'>"
    if (strHTMLBotones == '') {
        strHTMLBotones = "<table style='width:100%'><tr>"
        strHTMLBotones += "<td style='width:40%'>&nbsp;</td>"
        strHTMLBotones += "<td style='width:20%'><div style='width: 110px; margin:5px' id='divbtnSalir'></div></td>"
        strHTMLBotones += "<td style='width:40%'>&nbsp;</td>"
        strHTMLBotones += "</tr></table>"
    }

    strHTMLRes += strHTMLBotones + "</td></tr>"
    strHTMLRes += "</table>"
    strHTMLRes += "</td>"
    strHTMLRes += "<td style='width:35%'>&nbsp;</td>"
    strHTMLRes += "</tr>"

    return strHTMLRes += "</table>"

}

//function getDuracion(fe_inicio, fe_fin) {
//    try {
//        if (fe_inicio == null || fe_fin == null)
//            return ''

//       fe_inicio = parseFecha(fe_inicio)
//       fe_fin    = parseFecha(fe_fin)

//        var diferencia = (fe_fin.getTime() - fe_inicio.getTime()) / 1000

//        dias       = Math.floor(diferencia / 86400)
//        diferencia = diferencia - (86400 * dias)

//        horas      = Math.floor(diferencia / 3600)
//        diferencia = diferencia - (3600 * horas)

//        minutos    = Math.floor(diferencia / 60)
//        diferencia = diferencia - (60 * minutos)

//        segundos = Math.floor(diferencia)

//        str_durac  = ''
//        str_durac += dias > 0 ? dias + ' días -' : ''
//        str_durac += horas >= 0 ? ' ' + (horas < 10 ? ('0' + horas.toString()) : horas) + ':' : ''
//        str_durac += minutos >= 0 ? '' + (minutos < 10 ? ('0' + minutos.toString()) : minutos) + ':' : ''
//        str_durac += segundos >= 0 ? '' + (segundos < 10 ? ('0' + segundos.toString()) : segundos) : ''
//        str_durac += ''
//    }
//    catch (e) { str_durac = '' }

//    return str_durac
//}

function getDuracion(str_fe_inicio, str_fe_fin) {
    try {

        if (str_fe_fin == null && str_fe_inicio == null)
            return ''

        var fe_fin
        var fe_inicio
        if (str_fe_fin == 'hoy')
            fe_fin = new Date((new Date().getTime()))
        else
            fe_fin = new Date(MMDDYYYY(str_fe_fin).split(' ')[0] + " " + str_fe_fin.split(' ')[1])

        fe_inicio = new Date(MMDDYYYY(str_fe_inicio).split(' ')[0] + " " + str_fe_inicio.split(' ')[1])

        var diferencia = (fe_fin.getTime() - fe_inicio.getTime()) / 1000

        var dias = Math.floor(diferencia / 86400)
        diferencia = diferencia - (86400 * dias)

        var horas = Math.floor(diferencia / 3600)
        diferencia = diferencia - (3600 * horas)

        var minutos = Math.floor(diferencia / 60)
        diferencia = diferencia - (60 * minutos)

        var segundos = Math.floor(diferencia)

        var str_durac = ''
        str_durac = dias > 0 ? dias.toString() + ' días -' : ''
        str_durac = str_durac + '' + (horas >= 0 ? ' ' + (horas < 10 ? ('0' + horas.toString()) : horas.toString()) + ':' : '').toString()
        str_durac = str_durac + '' + (minutos >= 0 ? '' + (minutos < 10 ? ('0' + minutos.toString()) : minutos.toString()) + ':' : '').toString()
        str_durac = str_durac + '' + (segundos >= 0 ? '' + (segundos < 10 ? ('0' + segundos.toString()) : segundos.toString()) : '').toString()
    }
    catch (e) { str_durac = '' }

    return str_durac
}

function window_transferencia_abm(id_transferencia)
{
   
    if (nvFW.tienePermiso("permisos_transferencia", 1)) {
        win = window.top.nvFW.createWindow({
            url: '/fw/transferencia/transferencia_abm.aspx?id_transferencia=' + id_transferencia,
            title: '<b>Transferencia - ABM</b>',
            minimizable: true,
            maximizable: true,
            draggable: true,
            width: 1000,
            height: 500
            //destroyOnClose: true,
        });

        win.showCenter()

    }
    else {
        alert('No posee los permisos necesarios para realizar esta acción')
        return
    }
}


function fn_mostrar_seguimiento(id_transf_log) {

    if (nvFW.tienePermiso("permisos_transferencia_seguimiento", 1)) {
        win = window.top.nvFW.createWindow({
            url: '/fw/transferencia/transf_seguimiento.aspx?id_transf_log_get=' + id_transf_log,
            title: '<b>Seguimiento procesos y tareas</b>',
            minimizable: true,
            maximizable: true,
            draggable: true,
            width: 900,
            height: 80,
            destroyOnClose: true
        });
        win.showCenter()

    }
    else {
        alert('No posee los permisos necesarios para realizar esta acción')
        return
    }

}


function fn_verlog(param) {
    
    if (typeof (param) != "object")
    {
        alert("faltan definir paramentros::fn_verlog()")
        return
    }
    
    var id_transf_log = !param.id_transf_log ? "" : param.id_transf_log
    var tiene_permiso = param.tiene_permiso.toLowerCase() == 'true'

    if (tiene_permiso) {
        win = window.top.nvFW.createWindow({
            url: '/fw/transferencia/transf_seguimiento_pool_control_exec.aspx?id_transf_log=' + id_transf_log,
            title: '<b>Seguimiento procesos y tareas</b>',
            minimizable: true,
            maximizable: true,
            draggable: true,
            width: 900,
            height: 450,
            destroyOnClose: true
        });
        win.options.userData = param.id_transf_log
        win.showCenter()

    }
    else {
        alert('No posee los permisos necesarios para realizar esta acción')
        return
    }

}

function fn_DTS_log(id_run,filtroXML) 
{
    if (id_run > 0)
     {
       var filtroWhere = "<criterio><procedure><parametros><id_run DataType='int'>" + id_run + "</id_run></parametros></procedure></criterio>"

       nvFW.exportarReporte({
        filtroXML: filtroXML,
        filtroWhere: filtroWhere,
        path_xsl: '\\report\\transferencia\\verDTSRun_res\\HTML_base.xsl',
        formTarget: '_blank'
        })
     }
    else
     alert(id_run)
}

function fn_mostrar_error(id_transf_log_det,filtroXML) 
  {
    var rs = new tRS()
    
    rs.open(filtroXML,"","<criterio><select><campos></campos><filtro><id_transf_log_det type='igual'>" + id_transf_log_det + "</id_transf_log_det></filtro><orden></orden></select></criterio>","","")
    if (!rs.eof()) 
      {
         debug_src = rs.getdata('debug_src')
         debug_desc = rs.getdata('debug_desc')
         titulo = rs.getdata('mensaje')
         comentario = rs.getdata('comentario')
         mensaje = rs.getdata('mensaje')

         var r = new RegExp("\\\\", "ig")
         debug_src = debug_src.replace(r, "\\\\")
         debug_desc = debug_desc.replace(r, "\\\\")
         titulo = titulo.replace(r, "\\\\")
         comentario = comentario.replace(r, "\\\\")
         mensaje = mensaje.replace(r, "\\\\")

         var r = new RegExp("'", "ig")
         debug_src = debug_src.replace(r, "\\'")
         debug_desc = debug_desc.replace(r, "\\'")
         titulo = titulo.replace(r, "\\'")
         comentario = comentario.replace(r, "\\'")
         mensaje = mensaje.replace(r, "\\'")

         var r = new RegExp("\"", "ig")
         debug_src = debug_src.replace(r, "\\'")
         debug_desc = debug_desc.replace(r, "\\'")
         titulo = titulo.replace(r, "\\'")
         comentario = comentario.replace(r, "\\'")
         mensaje = mensaje.replace(r, "\\'")

         var r = new RegExp("\n", "ig")
         debug_src = debug_src.replace(r, "</br>")
         debug_desc = debug_desc.replace(r, "</br>")
         titulo = titulo.replace(r, "</br>")
         comentario = comentario.replace(r, "</br>")
         mensaje = mensaje.replace(r, "</br>")

         var errorHTML = "<table class='tb1'><tr class='tblabel'><td colspan='2'>Error - Detalle Nro. " + id_transf_log_det + "</td></tr>"
         errorHTML += "<tr><td class='Tit1'>numError:</td><td>" + id_transf_log_det + "</td></tr>"
         errorHTML += "<tr><td class='Tit1'>titulo:</td><td>" + titulo + "</td></tr>"
         errorHTML += "<tr><td class='Tit1'>mensaje:</td><td>" + mensaje + "</td></tr>"
         errorHTML += "<tr><td class='Tit1'>comentario:</td><td><span id='spError_desc" + id_transf_log_det + "'></span>" + comentario + "</td></tr>"
         errorHTML += "<tr><td class='Tit1'>debug_src:</td><td>" + debug_src + "</td></tr>"
         errorHTML += "<tr><td class='Tit1'>debug_desc:</td><td><div style='width:620px !Important;overflow:auto'>" + debug_desc + "</div></td></tr></table>"

         Dialog.alert(errorHTML, { className: "alphacube", width: 700, height: 250, okLabel: "cerrar" })
      }
   }


function mostrar_transf_parametros(id_transf_log_det, title, avanzado, filtroXML)
 {
    var width = 700
    var height = 180
    var filtroWhere = "<criterio><select><campos></campos><filtro><editable type='igual'>1</editable><id_transf_log_det type='igual'>" + id_transf_log_det + "</id_transf_log_det></filtro><orden></orden></select></criterio>"
    var path_xsl = "\\report\\transferencia\\verTransf_log\\HTML_verTransf_log_param.xsl"
                                        
    if (avanzado) 
     {
       width = 800
       filtroWhere = "<criterio><select><campos></campos><filtro><id_transf_log_det type='igual'>" + id_transf_log_det + "</id_transf_log_det></filtro><orden></orden></select></criterio>"
       path_xsl = "\\report\\transferencia\\verTransf_log\\HTML_verTransf_log_param_avanzado.xsl"
     }
    
    var w = parent.nvFW ? parent.nvFW : window.top.nvFW
    w.exportarReporte({
                        filtroXML: filtroXML
                        , filtroWhere: filtroWhere
                        , path_xsl: path_xsl
                        , formTarget: 'winPrototype'
                        , nvFW_mantener_origen: true
                        , id_exp_origen: 0
                        , winPrototype: { modal: true,
                          center: true,
                          bloquear: false,
                          url: 'enBlanco.htm',
                          title: '<b>' + title + '</b>',
                          minimizable: false,
                          maximizable: false,
                          draggable: true,
                          width: width,
                          height: height,
                          resizable: true,
                          destroyOnClose: true
                        }
    })

}

function mostrar_transf(id_transf_log, id_transferencia, nombre, fe_inicio, fe_fin, nombre_operador, estado) {
    fe_inicio = fe_inicio == '' ? '' : FechaToSTR(parseFecha(fe_inicio)) + " " + HoraToSTR(parseFecha(fe_inicio))
    fe_fin = fe_fin == '' ? '' : FechaToSTR(parseFecha(fe_fin)) + " " + HoraToSTR(parseFecha(fe_fin))

    window.top.win = window.top.nvFW.createWindow({ className: 'alphacube',
    title: '<b>Transferencia en ' + estado + '</b>',
        url: '/fw/transferencia/transf_pool_control_ejecucion.aspx',
        minimizable: false,
        maximizable: false,
        draggable: true,
        width: 800,
        height: 280,
        resizable: false,
        destroyOnClose: true
    })

    window.top.win.options.userData = { interval: null, id_transf_log: id_transf_log, estado: estado, id_transferencia: id_transferencia, nombre: nombre, fe_inicio: fe_inicio, fe_fin: fe_fin, nombre_operador: nombre_operador }
    window.top.win.showCenter(true)
} 


function finalizar_transf(id_transf_log, ReturnEval) {

    if (nvFW.tienePermiso("permisos_transferencia_ejecutar", 2)) {

        if (id_transf_log == '') { alert('Faltan definir el seguimiento'); return }

        Dialog.confirm("¿Desea <b>finalizar</b> el proceso seleccionado Nº " + id_transf_log + "?",
            {
                width: 300,
                className: "alphacube",
                okLabel: "Si",
                cancelLabel: "No",
                onOk: function (w) {
                    nvFW.error_ajax_request('transf_seguimiento.aspx',
                        {
                            parameters: { modo: 'GUARDAR', id_transf_log: id_transf_log },
                            onSuccess: function (err, transport) {

                                if (err.numError != 0) {
                                    alert(err.mensaje)
                                    return
                                }
                                else
                                    eval(ReturnEval);
                            }
                        });

                    w.close();
                    return
                },

                onCancel: function (w) {
                    w.close();
                }
            });
    }
    else
    {
        alert('No posee los permisos necesarios para realizar esta acción')
        return
    }
}
