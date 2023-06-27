var fe_desde,
    fe_hasta,
    strWhere,
    strOrder,
    winDivMenuContent = ObtenerVentana('divMenu_content'),
    winFrameRef = ObtenerVentana('frame_ref')

function tarea_rep(nro_tarea, fe_inicio, nro_rep) {
    tarea_abm(nro_tarea, fe_inicio, nro_rep)
}

function tarea_abm(nro_tarea, fe_inicio, nro_rep) {
    window.top.win = window.top.nvFW.createWindow({
        url: '/wiki/tarea_abm.aspx?nro_tarea_get=' + nro_tarea + '&fe_inicio_get=' + fe_inicio + '&nro_rep_get=' + nro_rep,
        title: '<b>Tarea</b>',
        minimizable: true,
        maximizable: true,
        draggable: true,
        width: 1024,
        height: 600,
        resizable: true,
        destroyOnClose: true,
        onClose: tarea_abm_return
    });

    window.top.win.showCenter(true)
}

function tarea_abm_return() {
    if (window.top.win.returnValue != undefined) {
        //if (winDivMenuContent.document.location.pathname == "/wiki/menu_calendario.aspx")
        //    winDivMenuContent.hoy_actualizar()
        //else if (winDivMenuContent.document.location.pathname == "/wiki/ref_tree.aspx")
        //    winFrameRef.location.href = '/wiki/inicio.aspx'
        //    else
        //        Buscar()
        if (!inNewWindow)
            switch (winDivMenuContent.document.location.pathname) {
                case "/wiki/menu_calendario.aspx": 
                    winDivMenuContent.hoy_actualizar()
                    break
                case "/wiki/ref_tree.aspx":
                    window.top.recargarTareasInicio()
                    break
                default:
                    Buscar()
                    break
            }
        else
            Buscar()
    }
}

function Buscar(por_evento) {   // Realiza la busqueda
    if (!inNewWindow && por_evento) {
        winDivMenuContent.$('tdOtros').show()
        winDivMenuContent.FormVistas.Radio[winDivMenuContent.FormVistas.Radio.length - 1].checked = true
    }

    var strFe_hasta = campos_defs.get_value('fe_hasta'),
        strFe_desde = campos_defs.get_value('fe_desde'),
        validar = comparar_fechas(strFe_desde, strFe_hasta),
        strerror = ''

    if (validar == 1) {
        alert('La <b>fecha desde</b> es mayor a la <b>fecha hasta</b><br><br>fecha desde > fecha hasta')
        return
    }

    if (strFe_hasta == '')
        if (inNewWindow) {
            // Setear la fecha al 31 de Diciembre del año actual
            campos_defs.set_value("fe_hasta", "31/12/" + (new Date()).getFullYear().toString())
            strFe_hasta = campos_defs.get_value("fe_hasta")
        }
        else
            strerror += 'La <b>fecha hasta</b> no esta definida<br />'

    if (strerror != '') {
        alert(strerror)
        return
    }

    fe_desde = ""
    fe_hasta = ""
    strWhere = ""
    strOrder = ""

    if (strFe_desde != '')
        fe_desde = MMDDYYYY(strFe_desde)
    else
        fe_desde = '1/1/1900'

    if (strFe_hasta != '')
        fe_hasta = MMDDYYYY(strFe_hasta)

    var cb = $('cmb_privacidad')

    if (cb.options[cb.options.selectedIndex].value == 3)
        strWhere += " "

    if (cb.options[cb.options.selectedIndex].value == 2)
        strWhere += " privacidad in (2) and "

    if (cb.options[cb.options.selectedIndex].value == 1)
        strWhere += " privacidad in (1) and "

    if (cb.options[cb.options.selectedIndex].value == 0)
        strWhere += " privacidad in (0,1) and "

    var cb = $('cmb_tiene_autorun')

    if (cb.options[cb.options.selectedIndex].value == 1)
        strWhere += " tiene_autorun in (1) and "

    if (cb.options[cb.options.selectedIndex].value == 2)
        strWhere += " tiene_autorun in (0) and "

    var cb = $('cmb_esperiodica')

    if (cb.options[cb.options.selectedIndex].value == 1)
        strWhere += " nro_period > 1 and "

    if (cb.options[cb.options.selectedIndex].value == 2)
        strWhere += " (nro_period = 1 or nro_period is null) and "

    if (campos_defs.value("nro_tarea_estado") != '')
        strWhere += " nro_tarea_estado = " + campos_defs.value("nro_tarea_estado") + " and "

    if (campos_defs.value("nro_tarea_pri") != '')
        strWhere += " nro_tarea_pri = " + campos_defs.value("nro_tarea_pri") + " and "

    if ($('asunto').value != '')
        strWhere += " asunto like '%" + $('asunto').value + "%' and "

    strWhere = strWhere.substring(0, strWhere.length - 4)

    strOrder = 'fe_inicio,nro_tarea'

    var params = "<criterio><params fe_desde='" + fe_desde + "' fe_hasta='" + fe_hasta + "' strWhere='" + stringToXMLAttributeString(strWhere) + "' strOrder='" + strOrder + "'></params></criterio>"

    nvFW.exportarReporte({
        filtroXML: nvFW.pageContents.criterio,
        params: params,
        path_xsl: 'report/verTarea/HTML_tareas_consultar.xsl',
        formTarget: 'FrameResultado',
        bloq_contenedor: $('FrameResultado'),
        cls_contenedor: 'FrameResultado'
    })
}