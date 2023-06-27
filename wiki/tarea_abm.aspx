<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    ' Obtenemos valores del submit()
    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_tarea_get = nvFW.nvUtiles.obtenerValor("nro_tarea_get", "")
    Dim nro_rep_get = nvFW.nvUtiles.obtenerValor("nro_rep_get", "")
    Dim fe_inicio_get = nvFW.nvUtiles.obtenerValor("fe_inicio_get", (New Date()).ToString("MM/dd/yyyy"))
    Dim nro_tarea = nvFW.nvUtiles.obtenerValor("nro_tarea", "")

    ' Alta/Modificacion - Eliminacion
    Dim err As New tError
    Try
        Select Case modo.ToLower
            Case "m"
                Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
                Dim Cmd As New nvFW.nvDBUtiles.tnvDBCommand("tarea_add", ADODB.CommandTypeEnum.adCmdStoredProc, nvFW.nvDBUtiles.emunDBType.db_app, , , , , )
                Cmd.addParameter("@strXML", 201, 1, , strXML)
                Dim rs = Cmd.Execute()

                err.parse_rs(rs)
                err.params("nro_tarea") = rs.Fields("nro_tarea").Value
                err.response()
            Case "e"
                ' Procedimiento almacenado
                Dim Cmd As New nvFW.nvDBUtiles.tnvDBCommand("tarea_delete", ADODB.CommandTypeEnum.adCmdStoredProc, nvFW.nvDBUtiles.emunDBType.db_app, , , , , )
                Cmd.addParameter("@nro_tarea", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, nro_tarea.Length, nro_tarea)

                Cmd.Execute()
                err.response()
        End Select

    Catch ex As Exception
        err.parse_error_script(ex)
        err.titulo = "Error en tareas ABM"
        err.mensaje = "No se puedo realizar ejecutar la acción solicitada"
    End Try

    ' Consultas XML encriptadas
    Me.contents("filtroBuscarTarea") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTarea'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroCategorias") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='tarea_cat'><campos>*</campos><filtro></filtro><orden>tarea_cat</orden></select></criterio>")
    Me.contents("filtroCategoriaAsignar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='tarea_asignar_cat'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroOperadorCargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerTarea_Operador'><campos>*</campos><filtro></filtro><orden>nro_tarea_tipo_rel,strNombreCompleto</orden></select></criterio>")
    Me.contents("filtroarmarRelacion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Tarea_tipo_rel'><campos>distinct *</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroParametrosAutorun") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Tarea_autorun_parametros'><campos>distinct *</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroautoruncargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Tarea_autorun'><campos>distinct *</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroautorumABM") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPeriodicidad'><campos>distinct *</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroValidadOperador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTarea_Operador'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroNotificarOperador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='tarea_cat_operador'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroOperadorNuevo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>distinct *</campos><filtro><SQL type='sql'>operador = dbo.rm_nro_operador()</SQL></filtro></select></criterio>")
%>
<html>
<head>
    <title>Tarea ABM</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>

    <style type="text/css">
        #div_cat td label:hover { cursor: hand; cursor: pointer; }
    </style>
    
    <% = Me.getHeadInit()%>
    
    <script type="text/javascript">
        var Imagenes = [];
        Imagenes["eliminar"]           = new Image();
        Imagenes["eliminar"].src       = '/wiki/image/icons/eliminar.png';
        Imagenes["guardar"]            = new Image();
        Imagenes["guardar"].src        = '/FW/image/icons/guardar.png';
        Imagenes["info"]               = new Image();
        Imagenes["info"].src           = '/FW/image/icons/info.png';
        Imagenes["period_origen"]      = new Image();
        Imagenes["period_origen"].src  = '/FW/image/icons/info.png';
        Imagenes["dep_padre"]          = new Image();
        Imagenes["dep_padre"].src      = '/wiki/image/icons/dep_padre.png';
        Imagenes["vincular"]           = new Image();
        Imagenes["vincular"].src       = '/wiki/image/icons/dep_padre.png';
        Imagenes["dep_hijo"]           = new Image();
        Imagenes["dep_hijo"].src       = '/wiki/image/icons/dep_hijo.png';
        Imagenes["favorito_si"]        = new Image();
        Imagenes["favorito_si"].src    = '/wiki/image/icons/favorito_si.png';
        Imagenes["nueva"]              = new Image();
        Imagenes["nueva"].src          = '/FW/image/icons/nueva.png';
        Imagenes["upload"]             = new Image();
        Imagenes["upload"].src         = '/wiki/image/icons/upload.png';
        Imagenes["periodicidad"]       = new Image();
        Imagenes["periodicidad"].src   = '/wiki/image/icons/periodicidad.png';
        Imagenes["cerrar"]             = new Image();
        Imagenes["cerrar"].src         = '/FW/image/icons/guardar_cerrar.png';
        Imagenes["guardar_como"]       = new Image();
        Imagenes["guardar_como"].src   = '/wiki/image/icons/guardar_como.png';
        Imagenes["guardar_cerrar"]     = new Image();
        Imagenes["guardar_cerrar"].src = '/wiki/image/icons/guardar_cerrar.png';

        function valTiempo(e) {
            var val      = Event.element(e).value,
                res      = "99:99",
                hora     = "",
                minutos  = "",
                splitted = val.split(":")

            if (splitted.length == 2) {
                hora    = parseInt(splitted[0], 10) < 24 && parseInt(splitted[0], 10) >= 0 ? parseInt(splitted[0], 10) : 99
                minutos = parseInt(splitted[0], 10) < 99 && parseInt(splitted[1], 10) < 60 && parseInt(splitted[1], 10) >= 0 ? parseInt(splitted[1], 10) : 99

                hora    = hora < 10 ? '0' + hora : hora
                minutos = minutos < 10 ? '0' + minutos : minutos
                res     = hora == 99 || minutos == 99 ? '99:99' : hora + ':' + minutos
            }
            //if (val.split(':').length == 2) {
            //    hora    = parseInt(val.split(':')[0], 10) < 24 && parseInt(val.split(':')[0], 10) >= 0 ? parseInt(val.split(':')[0], 10) : 99
            //    minutos = parseInt(val.split(':')[0], 10) < 99 && parseInt(val.split(':')[1], 10) < 60 && parseInt(val.split(':')[1], 10) >= 0 ? parseInt(val.split(':')[1], 10) : 99

            //    hora    = hora < 10 ? '0' + hora : hora
            //    minutos = minutos < 10 ? '0' + minutos : minutos
            //    res     = hora == 99 || minutos == 99 ? '99:99' : hora + ':' + minutos
            //}

            if (res == '99:99') {
                alert('El formato de hora no es valido')
                Event.element(e).value = ''
                Event.element(e).focus()
            }
            else
                Event.element(e).value = res
        }

        function hoy() {
            return FechaToSTR(new Date()) + " " + TiempoToSTR(new Date())
        }

        function TiempoToSTR(objFecha) {
            horas   = parseInt(objFecha.getHours(), 10)
            minutos = parseInt(objFecha.getMinutes(), 10)

            horas   = horas < 10 ? '0' + horas : horas
            minutos = minutos < 10 ? '0' + minutos : minutos

            return horas + ':' + minutos
        }

        function comparar_fechas(fecha1, fecha2) {
            fecha1 = fecha1.split("/")
            fecha2 = fecha2.split("/")

            var anio1 = parseInt(fecha1[2]),
                anio2 = parseInt(fecha2[2]),

                mes1  = parseInt(fecha1[1]),
                mes2  = parseInt(fecha2[1]),

                dia1  = parseInt(fecha1[0]),
                dia2  = parseInt(fecha2[0])

            if (anio1 > anio2)
                return 1
            else
                if (anio1 < anio2)
                    return -1
                else
                    if (mes1 > mes2)
                        return 1
                    else
                        if (mes1 < mes2)
                            return -1
                        else
                            if (dia1 > dia2)
                                return 1
                            else
                                if (dia1 < dia2)
                                    return -1
                                else
                                    return 0
        }

        function comparar_horas(hora1, hora2) {
            var arHora1 = hora1.split(":"),
                arHora2 = hora2.split(":"),
                // Obtener horas y minutos (hora 1)
                hh1     = isNaN(parseInt(arHora1[0], 10)) ? 0 : parseInt(arHora1[0], 10),
                mm1     = isNaN(parseInt(arHora1[1], 10)) ? 0 : parseInt(arHora1[1], 10),
                // Obtener horas y minutos (hora 2)
                hh2     = isNaN(parseInt(arHora2[0], 10)) ? 0 : parseInt(arHora2[0], 10),
                mm2     = isNaN(parseInt(arHora2[1], 10)) ? 0 : parseInt(arHora2[1], 10)

            // Comparar 
            if (hh1 < hh2 || (hh1 == hh2 && mm1 < mm2))
                return -1
            else if (hh1 > hh2 || (hh1 == hh2 && mm1 > mm2))
                return 1
            else
                return 0
        }

        function comparar_fechasyhora(Inicio, Vencimiento) {
            var Ainicio      = Inicio.split(' '),
                Avencimiento = Vencimiento.split(' '),
                resF         = comparar_fechas(Ainicio[0], Avencimiento[0]),
                resH         = comparar_horas(Ainicio[1], Avencimiento[1])

            if (resF == 1)
                return 1
            else
                if (resF == -1)
                    return -1
                else
                    if (resF == 0 && resH == 1)
                        return 1
                    else
                        if (resF == 0 && resH == -1)
                            return -1
                        else
                            return 0
        }

        function cFecha(strFecha) {
            var aFecha = strFecha.split("/"),
                dia    = "",
                mes    = "",
                anio   = "",
                fecha  = {}

            strFecha = ""

            if (aFecha.length == 3) {
                dia  = aFecha[0]
                mes  = parseInt(aFecha[1]) - 1
                anio = parseInt(aFecha[2]) < 100 ? 2000 + parseInt(aFecha[2], 10) : parseInt(aFecha[2])
            }
            //var fecha = null
            try {
                fecha = new Date(anio, mes, dia, 0, 0, 0)
            }
            catch(e) {
                fecha = null
            }

            return fecha
        }

        function cHora(strHora) {
            var aHora  = strHora.split(":"),
                hora   = "",
                minuto = "",
                tiempo = {}

            strHora = ""

            if (aHora.length >= 2) {
                hora   = aHora[0]
                minuto = aHora[1]
            }

            //var tiempo = null
            try {
                tiempo = new Date(0, 0, 0, hora, minuto, 0)
            }
            catch(e) {
                tiempo = null
            }

            return tiempo
        }

        function unir_fecha_hora(fecha, tiempo) {
            if (fecha == null || tiempo == null)
                return null

            var mes     = fecha.getMonth(),
                dia     = fecha.getDate(),
                ano     = fecha.getFullYear(),
                hora    = tiempo.getHours(),
                minutos = tiempo.getMinutes()

            return new Date(ano, mes, dia, hora, minutos, 0)
        }
    </script>
    <script type="text/javascript">
        var modo          = "",
            fe_inicio_get = "<%= fe_inicio_get %>",
            nro_rep_get   = "<%= nro_rep_get %>",
            fe_ini_noti   = "",
            fe_ven_noti   = "",
            Tarea         = [],
            primera_vez   = false,
            nominal,
            valor,
            fecha,
            disabled

        function window_onload()
        {
            try {
                campos_defs.items['nro_tarea_estado']['onchange'] = onchange_estado
                campos_defs.items['nro_operador']['onchange']     = onchange_operadores

                if ($('nro_tarea').value == 0)
                    nueva()
                else
                    tarea_cargar()

                cargar_periodicidad()
                tarea_autorun_cargar()
                cargar_calendar_inicio()
                cargar_calendar_fin()
                cargar_calendar_ven()
                cargar_calendar('_ini')
                cargar_calendar('_ven')
                onchange_privacidad()
                redibujar_calendar()
                redibujar_aviso_calendar()

                if ($('ch_aviso').checked)
                    check_aviso_todo_el_dia()

                if ($('ch_relativo_ini').checked)
                    check_aviso_relativo('_ini')

                if ($('ch_relativo_fin').checked)
                    check_relativo_fin('_fin')

                if ($('ch_relativo_ven').checked)
                    check_aviso_relativo('_ven')
            }
            catch(e) {}

            window_onresize()
        }

        function VerComentarios() {
            ObtenerVentana('frame_comentario').location.href = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=1&nro_com_grupo=1&collapsed_fck=1&id_tipo=' + $('nro_tarea').value + '&do_zoom=1'
        }

        function redibujar_aviso_calendar() {
            var fecha_inicio = unir_fecha_hora(cFecha($('fe_inicio').value), cHora($('ho_inicio').value)),
                fecha_vencimiento = unir_fecha_hora(cFecha($('fe_vencimiento').value), cHora($('ho_vencimiento').value))

            if (aviso_calendar_ini != undefined) {
                aviso_calendar_ini.args.min = null
                aviso_calendar_ini.args.max = fecha_inicio
                aviso_calendar_ini.redraw()
            }

            if (aviso_calendar_ven != undefined) {
                aviso_calendar_ven.args.min = fecha_inicio
                aviso_calendar_ven.args.max = null
                aviso_calendar_ven.redraw()
            }
        }

        function redibujar_calendar() {
            // valida que el rango de fe_vencimiento no sea menor que la fecha de inicio
            if (fe_fin_calendar == undefined && fe_vencimiento_calendar == undefined)
                return

            var fecha_inicio = unir_fecha_hora(cFecha($('fe_inicio').value), cHora($('ho_inicio').value))

            fe_vencimiento_calendar.args.min = fecha_inicio
            fe_vencimiento_calendar.redraw()

            fe_fin_calendar.args.min = fecha_inicio
            fe_fin_calendar.redraw()
        }
        
        function validar() {
            var strError = ""

            strError = validar_tarea_tipo_operador()

            if (strError != "")
                return strError

            strError = onchange_aviso("_inicio")
            strError += onchange_aviso("_vencimiento")

            if (strError != "")
                return strError

            if ($F('asunto').trim() == "")
                strError = "Ingrese el asunto de la tarea</br>"
            
            if (campos_defs.value('nro_tarea_pri') == "")
                strError += "Ingrese la priodidad</br>"
            
            if (campos_defs.value('nro_tarea_estado') == "")
                strError += "Ingrese el estado</br>"
            
            if ($F('fe_inicio') == "")
                strError += "Ingrese la fecha inicio</br>"
            
            if ($F('ho_inicio') == "")
                strError += "Ingrese la hora inicio</br>"
            
            if ($F('ho_fin') == "" && $F('fe_fin') != "")
                strError += 'Ingrese la hora de finalización <br/>'
            
            if ($F('ho_vencimiento') == "" && $F('fe_vencimiento') != "")
                strError += 'Ingrese la hora del vencimiento <br/>'
            
            if ($F('sel_ho_aviso_ini') == "" && $F('sel_fe_aviso_ini') != "")
                strError += 'Ingrese la hora del aviso del inicio <br/>'
            
            if ($F('sel_ho_aviso_ven') == "" && $F('sel_fe_aviso_ven') != "")
                strError += 'Ingrese la hora del aviso del vencimiento <br/>'

            if (strError == "") {
                nominal = 'D'
                valor   = 1
                fecha   = unir_fecha_hora(cFecha($F('fe_inicio')), cHora($F('ho_inicio')))

                if ($F('ho_fin') != "" && $F('fe_fin') == "") {
                    res               = aumentar_disminutir_fecha(nominal, valor, fecha).split(" ")
                    $('fe_fin').value = res[0]
                }

                if ($F('ho_vencimiento') != "" && $F('fe_vencimiento') == "") {
                    if ($('ch_aviso').checked)
                        $('fe_vencimiento').value = $F('fe_incio')
                    else {
                        res                       = aumentar_disminutir_fecha(nominal, valor, fecha).split(" ")
                        $('fe_vencimiento').value = res[0]
                    }
                }

                // fecha de notificacion (valida cuando la fecha de notificacion esta vacia) 
                if ($F('sel_ho_aviso_ini') != "" && $F('sel_fe_aviso_ini') == "") {
                    nominal                     = "M"
                    valor                       = -10
                    res                         = aumentar_disminutir_fecha(nominal, valor, fecha).split(" ")
                    $('sel_fe_aviso_ini').value = res[0]
                    $('sel_ho_aviso_ini').value = res[1]
                }

                if ($F('sel_ho_aviso_ven') != "" && $F('sel_fe_aviso_ven') == "") {
                    nominal                     = "M"
                    valor                       = -10
                    fecha                       = unir_fecha_hora(cFecha($F('fe_vencimiento')), cHora($F('ho_vencimiento')))
                    res                         = aumentar_disminutir_fecha(nominal, valor, fecha).split(" ")
                    $('sel_fe_aviso_ven').value = res[0]
                    $('sel_ho_aviso_ven').value = res[1]
                }
            }

            return strError
        }

        function obtener_valor_input_check(obj) {
            return $(obj).checked == true ? 1 : 0
        }

        function ir_tarea_origen() {
            actualizar_start()

            fe_inicio_get = Tarea['fe_inicio_origen']
            nro_rep_get   = 1
            fe_ini_noti   = ""
            fe_ven_noti   = ""
            
            tarea_aviso_ocultar('_ini')
            tarea_aviso_ocultar('_ven')
            
            primera_vez = false
            
            window_onload()

            setTimeout('winActualizar.close()', 500)
        }

        function tarea_verificar_return() {
            switch (win.returnValue) {
                case 'ACEPTAR':
                    guardar()
                    break;

                case 'IR_A_TAREA_ORIGEN':
                    ir_tarea_origen()
                    break;
            }
        }

        function MMDDYYYY(strFecha) {
            var splitted = strFecha.split("/")
            return splitted[1] + "/" + splitted[0] + "/" + splitted[2]
        }

        var dialog_confirmar,
            guardar_cerrar = false

        function btn_guardar_click(gc) {
            strError = validar()
            
            if (strError != '') {
                alert(strError)
                return
            }

            guardar_cerrar = gc ? true : false

            if ($('nro_tarea').value > 0) {
                var fe_inicio = $('fe_inicio').value
                fe_inicio = MMDDYYYY(fe_inicio) + ' ' + $('ho_inicio').value
                var diferencia_fecha = (parseFecha(fe_inicio) - parseFecha(Tarea['fe_inicio_origen']))

                //Si existe diferencia es mayor a la fecha de inicio guardada BD y se cambio el estado de pendiente a cualquiera que sea distinto del estado en ejecucion
                var cumple_condicion_ant = false

                if (!cumple_condicion_ant && diferencia_fecha > 0 && Tarea['nro_tarea_estado'] == 1 && campos_defs.value('nro_tarea_estado') == 1 && nro_rep_get > 1)
                {
                    cumple_condicion_ant = true
                    win = nvFW.createWindow({
                        url: '/wiki/tarea_verificar.aspx?nro_tarea=' + $('nro_tarea').value + '&fe_desde=' + Tarea['fe_inicio_origen'] + '&fe_hasta=' + fe_inicio,
                        title: '<b>Alerta</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        width: 600,
                        height: 350,
                        onClose: tarea_verificar_return
                    });
                    win.showCenter(true)
                }

                if (!cumple_condicion_ant && Tarea['nro_tarea_estado'] == 1 && campos_defs.value('nro_tarea_estado') != 1 && TareaPeriodicidad['nro_period'] > 0)
                {
                    cumple_condicion_ant = true
                    dialog_confirmar = nvFW.confirm("<b>Se realizo un cambio de estado,<br/> indique de que forma desea guardar la tarea periodica de actual:</b><br/><table style='font-size:12px !Important;width:100%'><tr><td><input type='radio' name='Radio' value='1' style='width:10%;border: 0px !Important' checked='checked'/>&nbsp;Continuar con la inmediata posterior.</td></tr><tr><td><input type='radio' name='Radio' value='2' style='width:10%;border: 0px !Important'/>&nbsp;No realizarle cambios (crear una copia).</td></tr><tr><td><input type='radio' name='Radio' value='3' style='width:10%;border: 0px !Important'/>&nbsp;Iniciar la tarea origen.</td></tr></table>",
                            {
                                width: 350,
                                okLabel: "Aceptar",
                                cancelLabel: "Cancelar",
                                onShow: function (win) {
                                },
                                cancel: function (win) {
                                    win.close();
                                    return
                                },
                                ok: function (win) {
                                    var res = 0
                                    var i
                                    
                                    for (i = 0, n = document.all.Radio.length; i < n; i++)
                                    {
                                        if (document.all.Radio[i].checked == true)
                                            res = parseInt(document.all.Radio[i].value, 10)
                                    }
                                    
                                    switch (res) {
                                        case 1:
                                            if (TareaPeriodicidad['nro_period'] > 0)
                                                Tarea['nro_tarea_ant'] = $('nro_tarea').value

                                            $('nro_tarea').value = 0
                                            TareaPeriodicidad['nro_period'] = 0
                                            nro_rep_get = 0
                                            guardar()
                                            break;
                                        case 2:
                                            $('nro_tarea').value = 0
                                            nro_rep_get = 0
                                            limpiar_arreglo()
                                            guardar()
                                            break;
                                        case 3:
                                            ir_tarea_origen()
                                            break;
                                    }
                                    win.close()
                                }
                            });
                }

                if (!cumple_condicion_ant)
                    guardar()
            }
            else
                guardar()
        }

        var xmlperiodicidad = ''
        
        function guardar()
        {
            tarea_cat_actualizar()
            notificaciones_actualizar()
            tarea_operador_actualizar()
            
            check_aviso_relativo('_ini')
            check_aviso_relativo('_ven')

            validar_notificador_operador()

            Tarea['nro_tarea_ant'] = Tarea['nro_tarea_ant'] != undefined && Tarea['nro_tarea_ant'] != '' ? Tarea['nro_tarea_ant'] : '' // si la tarea cambio de estado a ejecución

            if ($('nro_tarea').value == 0) {
                var comentario = CKEDITOR.instances['descripcion'].getData()
            }

            var xmldato = ""
            xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xmldato += "<tarea nro_tarea='" + $('nro_tarea').value + "' asunto='" + $('asunto').value + "' fe_vencimiento='" + $('fe_vencimiento').value + " " + $('ho_vencimiento').value + "' fe_inicio='" + $('fe_inicio').value + " " + $('ho_inicio').value + "' fe_fin='" + $('fe_fin').value + " " + $('ho_fin').value + "' fe_estado='" + $('fe_estado').value + "' completado='" + $('completado').options[$('completado').options.selectedIndex].text + "' nro_tarea_pri='" + campos_defs.value('nro_tarea_pri') + "' nro_tarea_estado='" + campos_defs.value('nro_tarea_estado') + "' fe_inicio_noti='" + $('sel_fe_aviso_ini').value + " " + $('sel_ho_aviso_ini').value + "' fe_vencimiento_noti='" + $('sel_fe_aviso_ven').value + " " + $('sel_ho_aviso_ven').value + "' privacidad='" + $('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value + "' noti_inactividad='" + $('cmb_noti_inactividad').options[$('cmb_noti_inactividad').options.selectedIndex].value + "' fin_rel_ini='" + obtener_valor_input_check('ch_relativo_fin') + "' noti_ini_rel_ini='" + obtener_valor_input_check('ch_relativo_ini') + "' noti_ven_rel_ini='" + obtener_valor_input_check('ch_relativo_ven') + "' todo_dia='" + obtener_valor_input_check('ch_aviso') + "' nro_tarea_ant='" + Tarea['nro_tarea_ant'] + "'>"
            xmldato += "<descripcion><![CDATA[" + comentario + " ]]></descripcion>"
            xmldato += "<categorias>"
            
            Categorias.each(function (arreglo, i)
            {
                if (arreglo['estado'] == 'S')
                    xmldato += "<categoria  nro_tarea_cat='" + arreglo['nro_tarea_cat'] + "'/>"
            });

            xmldato += "</categorias>"
            xmldato += "<operadores>"
            
            TareaOperador.each(function (arreglo, i)
            {
                if (arreglo['estado'] != 'BORRADO' && arreglo['estado'] != 'VACIO')
                    xmldato += "<operador operador='" + arreglo['operador'] + "' tipo_rel='" + arreglo['nro_tarea_tipo_rel'] + "' notificador='" + arreglo['notificador'] + "'/>"
            });
            
            xmldato += "</operadores>"
            xmldato += "<tarea_autorun>"
            
            TareaAutorun.each(function (arreglo, i)
            {
                xmldato += "<autorun "
                xmldato += "nro_tarea_autorun='" + arreglo.nro_tarea_autorun + "' "
                xmldato += "servidor='" + arreglo.servidor + "' "
                xmldato += "puerto='" + arreglo.puerto + "' "
                xmldato += "cod_sistema='" + arreglo.cod_sistema + "' "
                xmldato += "url='" + arreglo.url + "' "
                xmldato += "metodo='" + arreglo.metodo + "' "
                xmldato += "id_transferencia='" + arreglo.id_transferencia + "' "
                xmldato += "transferencia='" + arreglo.transferencia + "' >"
                xmldato += "<parametros>"
                
                arreglo.Parametros.each(function (arreglo_p, p)
                {
                    xmldato += "<param parametro='" + arreglo_p.parametro + "' valor='" + arreglo_p.valor + "' />"
                });
                
                xmldato += "</parametros>"
                xmldato += "</autorun>"
            });
            
            xmldato += "</tarea_autorun>"
            xmldato += "<periodicidades>"
            xmldato += "<periodicidad nro_period='" + TareaPeriodicidad['nro_period'] + "' nro_tipo_period='" + TareaPeriodicidad['nro_tipo_period'] + "' nro_tipo_repet='" + TareaPeriodicidad['nro_tipo_repet'] + "'"

            switch (parseInt(TareaPeriodicidad['nro_tipo_period'], 10))
            {
                case 1:
                    xmldato += " dia_intervalo='" + TareaPeriodicidad['dia_intervalo'] + "'"
                    xmldato += " sem_intervalo='' sem_dia='' men_dia='' men_ultimo_dia='' men_intervalo='' men_dia_pos='' men_dia_sem='' anio_dia='' anio_dia_pos='' ano_dia_sem='' anio_mes=''"
                    break

                case 2:
                    xmldato += " dia_intervalo='' "
                    xmldato += " sem_intervalo='" + TareaPeriodicidad['sem_intervalo'] + "' sem_dia='" + TareaPeriodicidad['sem_dia'] + "'"
                    xmldato += " men_dia='' men_ultimo_dia='' men_intervalo='' men_dia_pos='' men_dia_sem='' anio_dia='' anio_dia_pos='' anio_dia_sem='' anio_mes=''"
                    break

                case 3:
                    xmldato += " dia_intervalo='' sem_intervalo='' sem_dia='' "
                    xmldato += " men_dia='" + TareaPeriodicidad['men_dia'] + "'"
                    xmldato += " men_intervalo='" + TareaPeriodicidad['men_intervalo'] + "'"
                    xmldato += " men_ultimo_dia='" + TareaPeriodicidad['men_ultimo_dia'] + "'"
                    xmldato += " men_dia_pos='" + TareaPeriodicidad['men_dia_pos'] + "'"
                    xmldato += " men_dia_sem='" + TareaPeriodicidad['men_dia_sem'] + "'"
                    xmldato += " anio_dia='' anio_dia_pos='' anio_dia_sem='' anio_mes=''"
                    break

                case 4:
                    xmldato += " dia_intervalo='' sem_intervalo='' sem_dia='' men_dia='' men_ultimo_dia='' men_intervalo='' men_dia_pos='' men_dia_sem='' "
                    xmldato += " anio_dia='" + TareaPeriodicidad['anio_dia'] + "'"
                    xmldato += " anio_dia_pos='" + TareaPeriodicidad['anio_dia_pos'] + "'"
                    xmldato += " anio_dia_sem='" + TareaPeriodicidad['anio_dia_sem'] + "'"
                    xmldato += " anio_mes='" + TareaPeriodicidad['anio_mes'] + "'"
                    break
                default:
                    xmldato += " dia_intervalo='' sem_intervalo='' sem_dia='' men_dia='' men_ultimo_dia='' men_intervalo='' men_dia_pos='' men_dia_sem='' anio_dia='' anio_dia_pos='' anio_dia_sem='' anio_mes=''"
                    break
            }

            xmldato += " final_repet='" + TareaPeriodicidad['final_repet'] + "' final_fecha='" + TareaPeriodicidad['final_fecha'] + "'/>"
            xmldato += "</periodicidades>"

            xmldato += "</tarea>"

            nvFW.error_ajax_request('tarea_abm.aspx', { 
                parameters: { modo: 'M', strXML: xmldato },
                onSuccess: function (er) { window_reload(er.params["nro_tarea"]) }
            })
        }

        function window_reload(nro_tarea)
        {
            parent.win.returnValue = nro_tarea

            if (nro_tarea > 0 && !guardar_cerrar)
            {
                $('nro_tarea').value = nro_tarea
                tarea_actualizar()
                parent.win.setTitle("<b>Tarea: " + $('nro_tarea').value + " - " + $('asunto').value.substring(0, 20) + tipo_tarea() + "</b>")
            }
            else
                if (guardar_cerrar)
                    parent.win.close()
        }

        function tarea_cat_actualizar() {
            Categorias.each(function (arreglo, i) {
                if ($('check_' + i).checked == true)
                    arreglo['estado'] = 'S'
            });
        }

        function tipo_tarea()
        {
            var tipo_tarea = '... ('
            tipo_tarea += nro_rep_get > 1 ? 'Periodica - ' : nro_rep_get == 1 && campos_defs.value('nro_tarea_estado') != 2 ? 'Origen - ' : ''
            tipo_tarea += campos_defs.desc('nro_tarea_estado').split('  (')[0]
            tipo_tarea += ')'
            return tipo_tarea
        }

        var Categorias

        function tarea_cat_cargar() {
            $('div_cat').innerHTML = ''

            var filtroXML = nvFW.pageContents.filtroCategorias,
                rs = new tRS(),
                i = 0
           
            rs.open(filtroXML)       
            
            Categorias = []
            
            while (!rs.eof()) {
                Categorias[i] = []
                Categorias[i]['nro_tarea_cat'] = rs.getdata('nro_tarea_cat')
                Categorias[i]['tarea_cat'] = rs.getdata('tarea_cat')
                Categorias[i]['estado'] = ''
                rs.movenext()
                i++
            }

            tarea_cat_dibujar()
        }

        function tarea_cat_dibujar()
        {
            $('div_cat').innerHTML = ''
            var strHTML = "<table class='tb1'>"
            
            Categorias.each(function (arreglo, i) {
                strHTML += "<tr><td style='text-align: center;width:2%'><input type='checkbox' name='check_" + i + "' id='check_" + i + "'/></td>"
                strHTML += "<td style='text-align:left;width:80%'><label for='check_" + i + "'>" + arreglo['tarea_cat'] + "</label></td>"
                strHTML += "</tr>"
            });

            strHTML += "</table>"
            $('div_cat').insert({ top: strHTML })
        }

        function obtener_fe_periodo(fecha, dif) {
            fecha.setTime(fecha.getTime() + dif)
            return fecha
        }

        function tarea_actualizar() {
            tarea_aviso_ocultar('_ini')
            tarea_aviso_ocultar('_ven')
            tarea_aviso_cargar()
            cargar_periodicidad()
            tarea_autorun_cargar()
            nro_rep_get = TareaPeriodicidad['nro_period'] != '' ? 1 : 0

            Tarea['nro_tarea']           = $('nro_tarea').value
            Tarea['fe_inicio_origen']    = fecha_union_hora(MMDDYYYY($('fe_inicio').value), $('ho_inicio').value)
            Tarea['asunto']              = $('asunto').value
            Tarea['descripcion']         = $('descripcion').value
            Tarea['nro_tarea_estado']    = parseInt(campos_defs.value('nro_tarea_estado'))
            Tarea['fe_estado']           = $('fe_estado').value
            Tarea['nro_tarea_pri']       = parseInt(campos_defs.value('nro_tarea_pri'))
            Tarea['completado']          = $('completado').options[$('completado').options.selectedIndex].value
            Tarea['privacidad']          = $('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value
            Tarea['fin_rel_ini']         = obtener_valor_input_check('ch_relativo_fin')
            Tarea['noti_ini_rel_ini']    = obtener_valor_input_check('ch_relativo_ini')
            Tarea['noti_ven_rel_ini']    = obtener_valor_input_check('ch_relativo_ven')
            Tarea['todo_dia']            = obtener_valor_input_check('ch_aviso')
            Tarea['nro_period']          = TareaPeriodicidad['nro_period']
            Tarea['noti_inactividad']    = $('cmb_noti_inactividad').options[$('cmb_noti_inactividad').options.selectedIndex].value
            Tarea['fe_inicio']           = fecha_union_hora($('fe_inicio').value, $('ho_inicio').value)
            Tarea['fe_fin']              = fecha_union_hora($('fe_fin').value, $('ho_fin').value)
            Tarea['fe_vencimiento']      = fecha_union_hora($('fe_vencimiento').value, $('fe_vencimiento').value)
            Tarea['fe_inicio_noti']      = fe_ini_noti
            Tarea['fe_vencimiento_noti'] = fe_ven_noti
            Tarea['nro_tarea_ant']       = ""
        }

        function tarea_cargar() {
            if ($('nro_tarea').value == '')
                return
            
            var filtroXML   = nvFW.pageContents.filtroBuscarTarea,
                filtroWhere = "<nro_tarea type='igual'>" + $('nro_tarea').value + "</nro_tarea>",
                rs          = new tRS();

            rs.open(filtroXML, '', filtroWhere)
   
            if (!rs.eof()) {
                if (nro_rep_get > 1 && fe_inicio_get != '') {
                    var dif = parseFecha(fe_inicio_get) - parseFecha(rs.getdata('fe_inicio'))

                    $('fe_inicio').value      = rs.getdata('fe_inicio') == null ? '' : FechaToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_inicio')), dif))
                    $('ho_inicio').value      = rs.getdata('fe_inicio') == null ? '' : TiempoToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_inicio')), dif))
                    $('fe_fin').value         = rs.getdata('fe_fin') == null ? '' : FechaToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_fin')), dif))
                    $('ho_fin').value         = rs.getdata('fe_fin') == null ? '' : TiempoToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_fin')), dif))
                    $('fe_vencimiento').value = rs.getdata('fe_vencimiento') == null ? '' : FechaToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_vencimiento')), dif))
                    $('ho_vencimiento').value = rs.getdata('fe_vencimiento') == null ? '' : TiempoToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_vencimiento')), dif))
                    fe_ini_noti               = rs.getdata('fe_inicio_noti') == null ? '' : FechaToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_inicio_noti')), dif)) + " " + TiempoToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_inicio_noti')), dif))
                    fe_ven_noti               = rs.getdata('fe_vencimiento_noti') == null ? '' : FechaToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_vencimiento_noti')), dif)) + " " + TiempoToSTR(obtener_fe_periodo(parseFecha(rs.getdata('fe_vencimiento_noti')), dif))
                }
                else {
                    $('fe_inicio').value      = rs.getdata('fe_inicio') == null ? '' : FechaToSTR(parseFecha(rs.getdata('fe_inicio')))
                    $('ho_inicio').value      = rs.getdata('fe_inicio') == null ? '' : TiempoToSTR(parseFecha(rs.getdata('fe_inicio')))
                    $('fe_fin').value         = rs.getdata('fe_fin') == null ? '' : FechaToSTR(parseFecha(rs.getdata('fe_fin')))
                    $('ho_fin').value         = rs.getdata('fe_fin') == null ? '' : TiempoToSTR(parseFecha(rs.getdata('fe_fin')))
                    $('fe_vencimiento').value = rs.getdata('fe_vencimiento') == null ? '' : FechaToSTR(parseFecha(rs.getdata('fe_vencimiento')))
                    $('ho_vencimiento').value = rs.getdata('fe_vencimiento') == null ? '' : TiempoToSTR(parseFecha(rs.getdata('fe_vencimiento')))
                    fe_ini_noti               = rs.getdata('fe_inicio_noti') == null ? '' : FechaToSTR(parseFecha(rs.getdata('fe_inicio_noti'))) + " " + TiempoToSTR(parseFecha(rs.getdata('fe_inicio_noti')))
                    fe_ven_noti               = rs.getdata('fe_vencimiento_noti') == null ? '' : FechaToSTR(parseFecha(rs.getdata('fe_vencimiento_noti'))) + " " + TiempoToSTR(parseFecha(rs.getdata('fe_vencimiento_noti')))
                }

                Tarea['nro_tarea']           = $('nro_tarea').value
                Tarea['fe_inicio_origen']    = rs.getdata('fe_inicio')
                Tarea['asunto']              = rs.getdata('asunto')
                Tarea['descripcion']         = rs.getdata('descripcion')
                Tarea['nro_tarea_estado']    = parseInt(rs.getdata('nro_tarea_estado'))
                Tarea['fe_estado']           = rs.getdata('fe_estado')
                Tarea['nro_tarea_pri']       = parseInt(rs.getdata('nro_tarea_pri'))
                Tarea['completado']          = rs.getdata('completado')
                Tarea['privacidad']          = rs.getdata('privacidad')
                Tarea['fin_rel_ini']         = rs.getdata('fin_rel_ini')
                Tarea['noti_ini_rel_ini']    = rs.getdata('noti_ini_rel_ini')
                Tarea['noti_ven_rel_ini']    = rs.getdata('noti_ven_rel_ini')
                Tarea['todo_dia']            = rs.getdata('todo_dia')
                Tarea['nro_period']          = rs.getdata('nro_period')
                Tarea['noti_inactividad']    = rs.getdata('noti_inactividad')
                Tarea['fe_inicio']           = fecha_union_hora($('fe_inicio').value, $('ho_inicio').value)
                Tarea['fe_fin']              = fecha_union_hora($('fe_fin').value, $('ho_fin').value)
                Tarea['fe_vencimiento']      = fecha_union_hora($('fe_vencimiento').value, $('fe_vencimiento').value)
                Tarea['fe_inicio_noti']      = fe_ini_noti
                Tarea['fe_vencimiento_noti'] = fe_ven_noti
                Tarea['nro_tarea_ant']       = ""

                $('asunto').value                = Tarea['asunto']
                //$('descripcion').value = Tarea['descripcion']
                $('fe_inicio_hidden').value      = Tarea['fe_inicio']
                $('fe_fin_hidden').value         = Tarea['fe_fin']
                $('fe_vencimiento_hidden').value = Tarea['fe_vencimiento']


                $('fe_estado').value = rs.getdata('fe_estado') == null ? FechaToSTR(new Date()) + " " + TiempoToSTR(new Date()) : FechaToSTR(parseFecha(Tarea['fe_estado'])) + " " + TiempoToSTR(parseFecha(Tarea['fe_estado']))

                campos_defs.set_value('nro_tarea_estado', Tarea['nro_tarea_estado'])
                campos_defs.set_value('nro_tarea_pri', Tarea['nro_tarea_pri'])

                cmb_seleccionar_valor($('completado'), Tarea['completado'], 'text')
                cmb_seleccionar_valor($('cmb_noti_inactividad'), Tarea['noti_inactividad'], 'value')

                cmb_seleccionar_valor($('cmb_privacidad'), Tarea['privacidad'] == null ? 0 : Tarea['privacidad'], 'value')

                $('ch_relativo_fin').checked = Tarea['fin_rel_ini'] == 1 ? true : false
                $('ch_relativo_ini').checked = Tarea['noti_ini_rel_ini'] == 1 ? true : false
                $('ch_relativo_ven').checked = Tarea['noti_ven_rel_ini'] == 1 ? true : false
                $('ch_aviso').checked        = Tarea['todo_dia'] == 1 ? true : false

                if ($('fe_fin_hidden').value != '' && $('ch_relativo_fin').checked)
                    cargar_cmb_relativo('_fin', $('fe_inicio_hidden').value, $('fe_fin_hidden').value)

                $('nro_period').value = Tarea['nro_period'] == null ? '' : rs.getdata('nro_period')

                parent.win.setTitle("<b>Tarea: " + Tarea['nro_tarea'] + " - " + Tarea['asunto'].substring(0, 20) + tipo_tarea() + "</b>")

                tarea_aviso_cargar()
                tarea_cat_cargar()
                tarea_cat_asignar()
                tarea_operador_cargar()

                $('frame_comentario').show()
                VerComentarios();
            }
        }

        function cargar_cmb_relativo(obj, fe_inicio, fecha) {
            var fecha_ms     = unir_fecha_hora(cFecha(fecha.split(' ')[0]), cHora(fecha.split(' ')[1])).valueOf(),
                fe_inicio_ms = unir_fecha_hora(cFecha(fe_inicio.split(' ')[0]), cHora(fe_inicio.split(' ')[1])).valueOf(),
                valor        = '',
                dif          = (fe_inicio_ms - fecha_ms) / 1000

            dif = dif < 0 ? (dif * -1) : dif

            if (Math.floor(dif / 86400) > 0 && (dif / 86400).toString().split('.')[1] == undefined) {
                valor = 'D~' + Math.floor(dif / 86400)

                if (parseInt(valor.split('~')[1]) >= 30 && parseInt(valor.split('~')[1]) < 32 && (dif / 86400).toString().split('.')[1] == undefined)  // un mes
                    valor = 'MES~' + 1
            }

            if (Math.floor(dif / 3600) > 0 && valor == '' && (dif / 3600).toString().split('.')[1] == undefined)
                valor = 'H~' + Math.floor(dif / 3600)

            if (Math.floor(dif / 60) > 0 && valor == '' && (dif / 60).toString().split('.')[1] == undefined)
                valor = 'M~' + Math.floor(dif / 60)

            return cmb_seleccionar_valor('cmb_aviso' + obj, valor, 'value')
        }

        function tarea_aviso_cargar() {
            if (campos_defs.value('nro_tarea_estado') == 1 || campos_defs.value('nro_tarea_estado') == 2) {
                if (fe_ini_noti != '') {
                    if ($('ch_relativo_ini').checked)
                        cargar_cmb_relativo('_ini', $('fe_inicio_hidden').value, fe_ini_noti)

                    var fe_ini_noti_splitted    = fe_ini_noti.split(" ")
                    $('sel_fe_aviso_ini').value = fe_ini_noti_splitted[0]
                    $('sel_ho_aviso_ini').value = fe_ini_noti_splitted[1]
                    aviso_abm('_ini')
                }

                if (fe_ven_noti != '') {
                    if ($('ch_relativo_ven').checked)
                        cargar_cmb_relativo('_ven', $('fe_vencimiento_hidden').value, fe_ven_noti)

                    var fe_ven_noti_splitted    = fe_ven_noti.split(" ")
                    $('sel_fe_aviso_ven').value = fe_ven_noti_splitted[0]
                    $('sel_ho_aviso_ven').value = fe_ven_noti_splitted[1]
                    aviso_abm('_ven')
                }
            }
        }

        function cmb_seleccionar_valor(obj, valor, tipo) {
            for (var i = 0, n  = $(obj).options.length; i < n; i++) {
                switch (tipo) {
                    case 'text':
                        if (valor == $(obj).options[i].text) {
                            $(obj).options[i].selected = true
                            return true
                        }
                        break
                    case 'value':
                        if (valor == $(obj).options[i].value) {
                            $(obj).options[i].selected = true
                            return true
                        }
                        break
                }
            }
            return false
        }

        function tarea_cat_asignar() {
            var rs = new tRS(),
                filtroXML= nvFW.pageContents.filtroCategoriaAsignar,
                filtrowhere = "<nro_tarea type='igual'>" + $('nro_tarea').value + "</nro_tarea>"

            rs.open(filtroXML, '' , filtrowhere)

            while (!rs.eof()) {
                Categorias.each(function (arreglo, i) {
                    if (rs.getdata('nro_tarea_cat') == arreglo['nro_tarea_cat'])
                        $('check_' + i).checked = true
                });
                rs.movenext()
            }
        }

        //compara fe_seleccion con inicio
        function comparar_fincio_fseleccion(obj) {
            if ($('fe' + obj).value == '' || $('ho' + obj).value == '') {
                if ($('ho_vencimiento').value == '')
                    onchange_input('_vencimiento')
                if ($('ho_inicio').value == '')
                    onchange_input('_inicio')
                return
            }

            $('fe_inicio_hidden').value = $('fe_inicio').value + " " + $('ho_inicio').value
            $('fe' + obj + '_hidden').value = $('fe' + obj).value + " " + $('ho' + obj).value

            if ($('fe_inicio_hidden').value != '') {
                res = comparar_fechasyhora($('fe_inicio_hidden').value, $('fe' + obj + '_hidden').value) // res = 1 f1 > f2; res = -1 f1 < f2; res = 0 iguales
                if (res == 1) {
                    $('fe' + obj + '_hidden').value = ''
                    $('fe' + obj).value = ''
                    $('ho' + obj).value = ''

                    if (obj == '_vencimiento')
                        onchange_input('_vencimiento')
                }
            }
        }

        // compara la fecha de inicio o la fecha de vencimiento contra la fecha de la notificación -- la notificación no tiene que superar a la fecha de inicio
        function onchange_aviso(fecha_origen) {
            var obj = '_vencimiento' == fecha_origen ? '_ven' : '_ini'

            if ($('sel_fe_aviso' + obj).value == '' || $('sel_ho_aviso' + obj).value == '')
                return ''

            fecha_origen = $('fe_inicio').value + " " + $('ho_inicio').value
            fecha_aviso = $('sel_fe_aviso' + obj).value + " " + $('sel_ho_aviso' + obj).value

            if (fecha_origen != '') {
                res = comparar_fechasyhora(fecha_origen, fecha_aviso) // res = 1 f1 > f2; res = -1 f1 < f2; res = 0 iguales
                if ((res == -1 && obj == '_ini')) {
                    //$('sel_fe_aviso_hidden' + obj).value = ''
                    //$('sel_fe_aviso' + obj).value = ''
                    //$('sel_ho_aviso' + obj).value = ''
                    return 'La fecha notificación de inicio<br/>es mayor a la fecha de inicio.<br/>'
                }
                if ((res == 1 && obj == '_ven')) {
                    return 'La fecha notificación de vencimiento<br/>es menor a la fecha de inicio.'
                }
            }

            return ''
        }

        function onchange_estado() {
            if (campos_defs.value('nro_tarea_estado') == 3)
                cmb_seleccionar_valor($('completado'), '100', 'text')

            if (campos_defs.value('nro_tarea_estado') == 2)
                $('completado').disabled = false
            else {
                $('completado').disabled = true
                cmb_seleccionar_valor($('completado'), '0', 'text')
            }
        }

        function nueva() {
            campos_defs.clear()

            $('nro_tarea').value = 0
            $('asunto').value = ''
            $('fe_inicio').value = fe_inicio_get != 'undefined' && fe_inicio_get.split('T')[0] != '' ? FechaToSTR(parseFecha(fe_inicio_get.split('T')[0])) : FechaToSTR(new Date())
            $('ho_inicio').value = fe_inicio_get.split('T')[1]  != null ? fe_inicio_get.split('T')[1] : '00:00'
            $('fe_inicio_hidden').value = $('fe_inicio').value + " " + $('ho_inicio').value
            $('fe_fin').value = ''
            $('ho_fin').value = ''
            $('fe_vencimiento').value = ''
            $('ho_vencimiento').value = ''
            $('ch_aviso').checked = false

            redibujar_calendar()

            $('img_aviso_ini').src = "/wiki/image/icons/aviso_sin.png"
            $('img_aviso_ven').src = "/wiki/image/icons/aviso_sin.png"
            $('div_aviso_ini').hide()
            $('div_aviso_ven').hide()
            $('sel_fe_aviso_ini').value = ''
            $('sel_fe_aviso_ven').value = ''
            $('ch_relativo_ini').checked = false
            $('ch_relativo_ven').checked = false
            
            check_aviso_relativo('_ini')
            check_aviso_relativo('_ven')

            $('fe_estado').value = FechaToSTR(new Date()) + " " + TiempoToSTR(new Date())
            $('completado')[0].value = ''

            // Fecha de finalización
            $('ch_relativo_fin').checked = true
            check_relativo_fin()
            $('cmb_aviso_fin').options[4].selected = true // 30 minutos por defecto

            campos_defs.set_value('nro_tarea_estado', 1)
            campos_defs.set_value('nro_tarea_pri', 2)

            tarea_cat_cargar()
            
            $('divTareaOperador').innerHTML = ''
            TareaOperador = new Array()

            operador_nuevo()

            // Privacidad
            $('cmb_privacidad').options[0].selected = true // solo vinculado por defecto
            $('observacion').innerHTML = ''
            $('observacion').insert({ top: 'La tarea puede ser vista y editada solo por los operadores vinculados a la misma.' })

            aviso_abm('_ini')

            parent.win.setTitle("<b> Nueva Tarea </b>")

            setTimeout("$('asunto').focus()", 10)

            // Nueva instancia de CKEditor
            CKEDITOR.config.toolbar = 'Comentarios'
            CKEDITOR.replace('descripcion')

            $('frame_comentario').hide()
        }

        function eliminar() {
            if ($('nro_tarea').value == 0)
                return

            strError = validar_tarea_tipo_operador()

            if (strError != '') {
                alert(strError)
                return
            }

            nvFW.confirm("¿Desea eliminar esta tarea?", {
                width: 300,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win) {
                    win.close();
                    return
                },
                ok: function (win) {
                    $('nro_tarea').value = -$('nro_tarea').value //parseInt($('nro_tarea').value) * -1
                    guardar_cerrar = true // con ésta variable se cierra el ABM de tareas y refresca la informacion
                    guardar()
                    win.close()
                }
            });
        }

        var TareaOperador = []

        function tarea_operador_cargar() {
            TareaOperador.length = 0
            var i = 0,
                rs = new tRS(),
                filtroXML= nvFW.pageContents.filtroOperadorCargar,
                filtrowhere = "<nro_tarea type='igual'>" + $('nro_tarea').value + "</nro_tarea>"

            rs.open(filtroXML, '', filtrowhere)
  
            while (!rs.eof()) {
                TareaOperador[i] = []
                TareaOperador[i]['operador'] = rs.getdata('operador')
                TareaOperador[i]['strNombreCompleto'] = rs.getdata('strNombreCompleto')
                TareaOperador[i]['nro_tarea_tipo_rel'] = rs.getdata('nro_tarea_tipo_rel')
                TareaOperador[i]['tarea_tipo_rel'] = rs.getdata('tarea_tipo_rel')
                TareaOperador[i]['notificador'] = rs.getdata('notificador') == '' ? 0 : rs.getdata('notificador')
                TareaOperador[i]['estado'] = 'GUARDADO'
                i++
                rs.movenext()
            }

            agregar_nuevo_vinculacion(TareaOperador.length)
            tarea_operador_dibujar()
        }

        function agregar_nuevo_vinculacion(indice) {
            TareaOperador[indice] = []
            TareaOperador[indice]['operador'] = ''
            TareaOperador[indice]['strNombreCompleto'] = ''
            TareaOperador[indice]['nro_tarea_tipo_rel'] = ''
            TareaOperador[indice]['tarea_tipo_rel'] = ''
            TareaOperador[indice]['notificador'] = 1
            TareaOperador[indice]['estado'] = 'VACIO'
        }

        function tarea_operador_dibujar() {
            var checkear = '',
                nro_tipo,
                disabled,
                strHTML = "<table id='tbCuerpo' class='tb1'>",
                value_button = '',
                title = '',
                cursor = ''

            $('divTareaOperador').innerHTML = ''

            TareaOperador.each(function (arreglo, i) {
                if (arreglo['estado'] != 'BORRADO') {
                    nro_tipo = arreglo["nro_tarea_tipo_rel"]
                    disabled = (nro_tipo == 1 && !primera_vez) || (nro_tipo == '' && !primera_vez) ? 'disabled="disabled"' : ''

                    //'PRIVADO'
                    if ($('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value != 1 || disabled != '') {
                        etiqueta_img = disabled == '' ? '<img alt="" title="Desvincular Operador" src="/FW/image/icons/eliminar.png" style="cursor:pointer;cursor:hand" onclick="operador_eliminar(' + i + ')" />' : ''
                
                        //value_button = arreglo["estado"] == 'VACIO' ? 'value = "+"' : 'value = "..."'
                        if (arreglo["estado"] == 'VACIO') {
                            value_button = 'value="+"'
                            title = 'Agregar Operador'
                            cursor = 'pointer'
                        }
                        else {
                            value_button = 'value="..."'
                            title = ''
                            cursor = 'default'
                        }

                        var notificador = arreglo['notificador']

                        if (notificador >= 0) {
                            checkear_ce = (Math.pow(2, 1 - 1) & notificador) == 0 ? '' : 'checked="checked"'
                            checkear_p = (Math.pow(2, 2 - 1) & notificador) == 0 ? '' : 'checked="checked"'
                            checkear_c = (Math.pow(2, 3 - 1) & notificador) == 0 ? '' : 'checked="checked"'
                        }

                        strHTML += "<tr>"
                        strHTML += "<td style='width:4%;text-align:center'>" + etiqueta_img + "</td>"
                        strHTML += "<td style='width:50%' id='td_ope" + i + "'><b>" + arreglo['operador'] + "</b> " + arreglo['strNombreCompleto'] + "</td>"
                        strHTML += "<td style='width:8%; text-align:right'><input type='button' onclick='return operador_asignar(\"EDITAR_OPERADOR~" + i + "\")' " + value_button + " " + disabled + " style='width:30px; cursor:" + cursor + "' title='" + title + "'></td>"
                        strHTML += arreglo["estado"] != 'VACIO' ? "<td style='width:4%; text-align:center'><input type='checkbox' id='check_ce~" + i + "~" + Math.pow(2, 1 - 1) + "'name='check_ce~" + i + "~" + Math.pow(2, 1 - 1) + "' value='' " + checkear_ce + "/></td>" : "<td style='width:4%; text-align:center'></td>"
                        strHTML += arreglo["estado"] != 'VACIO' ? "<td style='width:4%; text-align:center'><input type='checkbox' id='check_p~" + i + "~" + Math.pow(2, 2 - 1) + "' name='check_p~" + i + "~" + Math.pow(2, 2 - 1) + "' value='' " + checkear_p + "/></td>" : "<td style='width:4%; text-align:center'></td>"
                        strHTML += arreglo["estado"] != 'VACIO' ? "<td style='width:4%; text-align:center'><input type='checkbox' id='check_c~" + i + "~" + Math.pow(2, 3 - 1) + "' name='check_c~" + i + "~" + Math.pow(2, 3 - 1) + "' value='' " + checkear_c + "/></td>" : "<td style='width:4%; text-align:center'></td>"
                        strHTML += arreglo["estado"] != 'VACIO' ? "<td style='width:20%'>" + armar_tipo_rel(i, arreglo["nro_tarea_tipo_rel"]) + "</td>" : "<td style='width:20%'></td>"
                        strHTML += "<td id='tdScroll" + i + "' style='width:2%'>&nbsp;&nbsp;</td>"
                        strHTML += "</tr>"
                    }
                }
            });

            strHTML += "</table>"
            $('divTareaOperador').insert({ top: strHTML })

            $('tbCuerpo').getHeight() - $('divTareaOperador').getHeight() > 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
        }

        function tdScroll_hide_show(show) {
            var i = 0

            while (i < TareaOperador.length) {
                if (show && $('tdScroll' + i) != undefined)
                    $('tdScroll' + i).show()

                if (!show && $('tdScroll' + i) != undefined)
                    $('tdScroll' + i).hide()

                i++
            }
        }

        function notificaciones_inicializar() {
            TareaOperador.each(function (arreglo, i) {
                arreglo['notificador'] = 0
            });
        }

        function notificaciones_actualizar() {
            notificaciones_inicializar()

            var res = 0,
                i = 0

            for (; ele = $('FrmTarea').elements[i]; i++) {
                res = 0
                if (ele.type == 'checkbox' && ele.disabled != true)
                    if (ele.name.split('~').length > 1) {
                        if (ele.checked) {
                            var indice = parseInt(ele.name.split('~')[1])
                            var numero = parseInt(ele.name.split('~')[2])

                            res = TareaOperador[indice]['notificador']
                            res = numero + res
                            TareaOperador[indice]['notificador'] = res
                        }
                    }
            }
        }

        function armar_tipo_rel(id, nro_tipo) {
            if ((nro_tipo == 1 && !primera_vez) || (nro_tipo == '' && !primera_vez)) {
                disabled = "disabled='disabled'"
                criterio = "<nro_tarea_tipo_rel type='igual'>1</nro_tarea_tipo_rel>"
            }
            else {
                disabled = ''
                criterio = "<nro_tarea_tipo_rel type='distinto'>1</nro_tarea_tipo_rel>"
            }

            var strTipo = "<select style='width:100%' name='cmb_tarea_tipo_rel" + id + "' " + disabled + " id='cmb_tarea_tipo_rel" + id + "'>",
                filtroXML = nvFW.pageContents.filtroarmarRelacion,
                rs = new tRS(),
                seleccionado = ''

            rs.open(filtroXML, '', criterio)

            while (!rs.eof()) {
                seleccionado = ''
                
                if (nro_tipo == rs.getdata("nro_tarea_tipo_rel"))
                    seleccionado = 'selected'

                if (!primera_vez && parseInt(rs.getdata("nro_tarea_tipo_rel")) == 1)
                    primera_vez = true

                strTipo += "<option value='" + rs.getdata("nro_tarea_tipo_rel") + "' " + seleccionado + ">" + rs.getdata("tarea_tipo_rel") + "</option>"
                rs.movenext()
            }

            strTipo += "</select>"

            return strTipo
        }

        var asignar

        function operador_asignar(modo) {
            asignar = modo
            
            // si el objeto ya esta construido
            if (campos_defs.items['nro_operador']["window"] != undefined && campos_defs.items['nro_operador']["window"].campo_def_value != '') {
                campos_defs.items['nro_operador']["window"] = undefined
                campos_defs.clear('nro_operador')
            }

            campos_defs.clear('nro_operador')
            campos_defs.onclick('', 'nro_operador', true)
        }

        function onchange_operadores() {
            var res = []
            res = asignar != undefined ? asignar.split('~') : res
            if (res[0] == 'EDITAR_OPERADOR')
                operador_editar(res[1])
        }

        function operador_editar(indice) {
            primera_vez = false
            
            if (!operador_existe()) {
                TareaOperador[indice]['operador'] = campos_defs.value('nro_operador')
                TareaOperador[indice]['strNombreCompleto'] = campos_defs.desc('nro_operador').split(' (')[0]

                if (TareaOperador[indice]['estado'] == 'VACIO') // si la fila es la ultima y estaba vacia 
                {
                    notificaciones_actualizar()
                    TareaOperador[indice]['estado'] = 'NUEVO'
                    TareaOperador[indice]['notificador'] = 7
                    agregar_nuevo_vinculacion(TareaOperador.length)
                    tarea_operador_dibujar()
                }
                else {
                    $('td_ope' + indice).innerHTML = ''
                    $('td_ope' + indice).insert({ top: TareaOperador[indice]['operador'] + ' ' + TareaOperador[indice]['strNombreCompleto'] })
                }
            }
            else {
                notificaciones_actualizar()
                tarea_operador_dibujar()
            }
        }

        function operador_existe() {
            var existe = false
            TareaOperador.each(function (arreglo, i) {
                if (arreglo['operador'] == campos_defs.value('nro_operador')) {
                    existe = true
                    if (arreglo['estado'] == 'BORRADO')
                        arreglo['estado'] = 'GUARDADO'
                }
            });
            return existe
        }

        function window_onresize() {
            try {
                var correccion = 12,
                    h_body = $$('body')[0].getHeight(),
                    h_menuBody = $('divMenu').getHeight(),
                    h_contenedores = 0,
                    contenedores = $('TblTareaABM').querySelectorAll("tr.contenedor"),
                    h_final = 0,
                    i = 0,
                    n = contenedores.length - 1

                // calcular la altura de todos los contenedores menos el ultimo (que queremos modificar - editor/comentarios)
                for (; i < n; i++) {
                    h_contenedores += contenedores[i].getHeight()
                }

                // setear la altura final
                h_final = h_body - h_menuBody - h_contenedores - correccion

                $('contenedor_frame_comentario').setStyle({ 'height': h_final + 'px' })

                // ejecutar el ajuste de CKeditor solo si esta cargado
                var editor = CKEDITOR.instances['descripcion'];

                if (editor !== undefined) {
                    // CKeditor
                    if (editor.status != "unloaded") {
                        editor.resize('auto', h_final);
                    }
                    else {
                        // si NO esta cargado aún, verificar cada 100ms su carga
                        var editorResize = setInterval(function() {
                            if (editor.status != "unloaded") {
                                clearInterval(editorResize)
                                editor.resize('auto', h_final);
                            }
                        }, 100)
                    }
                }
                else {
                    // Modulo de COMENTARIOS
                    ajustar_size_ModComentarios()
                }
            }
            catch(e) {}
        }

        function operador_eliminar(indice) {
            if (TareaOperador[indice]['estado'] == 'VACIO')
                return

            notificaciones_actualizar()
            primera_vez = false

            if (TareaOperador[indice]['estado'] == 'GUARDADO')
                TareaOperador[indice]['estado'] = 'BORRADO'

            if (TareaOperador[indice]['estado'] == 'NUEVO')
                TareaOperador.splice(indice, 1)

            tarea_operador_dibujar()

        }

        function operador_nuevo() {
            var indice = TareaOperador.length > 0 ? TareaOperador.length : 0

            if (indice == 0)
            {
                var rs = new tRS()
                rs.open(nvFW.pageContents.filtroOperadorNuevo)
                
                if (!rs.eof())
                {
                    operador = rs.getdata('operador')
                    strNombreCompleto = rs.getdata('strNombreCompleto')
                }

                TareaOperador[indice] = new Array();
                TareaOperador[indice]['operador'] = operador
                TareaOperador[indice]['strNombreCompleto'] = strNombreCompleto
                TareaOperador[indice]['nro_tarea_tipo_rel'] = ''
                TareaOperador[indice]['tarea_tipo_rel'] = ''
                TareaOperador[indice]['notificador'] = 1
                TareaOperador[indice]['estado'] = 'NUEVO'

                //}
                //notificaciones_actualizar()  
                primera_vez = false
                agregar_nuevo_vinculacion(TareaOperador.length)
                tarea_operador_dibujar()
            }
        }

        function tarea_operador_actualizar() {
            TareaOperador.each(function (arreglo, i) {
                if ($('cmb_tarea_tipo_rel' + i) != null) {
                    cmb = $('cmb_tarea_tipo_rel' + i)
                    if (cmb.options[cmb.options.selectedIndex].value != '') {
                        arreglo['nro_tarea_tipo_rel'] = cmb.options[cmb.selectedIndex].value
                        arreglo['tarea_tipo_rel']     = cmb.options[cmb.selectedIndex].text
                    }
                }

                // colocar todos los opereradores que no son titulares en "borrado" cuando selecciona modo privado
                if ($('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value == 1 && arreglo['nro_tarea_tipo_rel'] != 1) {
                    if (arreglo['estado'] == 'GUARDADO' || arreglo['estado'] == 'NUEVO')
                        arreglo['estado'] = 'BORRADO'
                }
            });
        }

        var TareaAutorun = []
        
        function tarea_autorun_cargar() {
            var filtroXML   = nvFW.pageContents.filtroautoruncargar,
                filtrowhere = "<nro_tarea type='igual'>" + $('nro_tarea').value + "</nro_tarea>",
                rs          = new tRS(),
                i           = 0

            rs.open(filtroXML, '', filtrowhere)

            while (!rs.eof()) {
                i = TareaAutorun.length

                TareaAutorun[i] = []
                TareaAutorun[i].nro_tarea_autorun = rs.getdata("nro_tarea_autorun")
                TareaAutorun[i].cod_sistema       = rs.getdata("cod_sistema")
                TareaAutorun[i].servidor          = isNULL(rs.getdata("servidor"), '')
                TareaAutorun[i].puerto            = isNULL(rs.getdata("puerto"), '')
                TareaAutorun[i].url               = isNULL(rs.getdata("url"), '')
                TareaAutorun[i].metodo            = isNULL(rs.getdata("metodo"), '')
                TareaAutorun[i].id_transferencia  = isNULL(rs.getdata("id_transferencia"), '')
                TareaAutorun[i].transferencia     = isNULL(rs.getdata("transferencia"), '')
                TareaAutorun[i].estado            = ""
                TareaAutorun[i].Parametros        = []

                tarea_autorun_parametros_cargar(i)

                rs.movenext()
            }
        }

        function isNULL(valor, retorno) {
            return valor == null ? retorno : valor
        }

        function tarea_autorun_parametros_cargar(i) {
            var Parametros  = TareaAutorun[i].Parametros,
                rs          = new tRS(),
                filtroXML   = nvFW.pageContents.filtroParametrosAutorun,
                filtrowhere = "<nro_tarea_autorun type='igual'>" + TareaAutorun[i].nro_tarea_autorun + "</nro_tarea_autorun>",
                i           = 0
            
            rs.open(filtroXML, '', filtrowhere)
            
            while (!rs.eof()) {
                i                          = Parametros.length
                Parametros[i]              = []
                Parametros[i]["parametro"] = rs.getdata("parametro")
                Parametros[i]["valor"]     = rs.getdata("valor")
                rs.movenext()
            }
        }

        var win_auto

        function tarea_autorun_abm() {
            if (campos_defs.value('nro_tarea_estado') != 2) {
                // var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_auto = nvFW.createWindow({
                    url: 'tarea_autorun_abm.aspx',
                    title: '<b>Asociar AutoRun</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    width: 750,
                    height: 400,
                    onClose: tarea_autorun_abm_return
                });

                win_auto.showCenter(true)
            }
            else
                alert('La tarea está en ejecución, imposible acceder')
        }

        function tarea_autorun_abm_return() {}

        var TareaPeriodicidad = []

        function cargar_periodicidad() {
            var rs          = new tRS(),
                filtroXML   = nvFW.pageContents.filtroautorunABM,
                filtrowhere = "<nro_tarea type='igual'>" + $('nro_tarea').value + "</nro_tarea>"

            rs.open(filtroXML, '', filtrowhere)

            if (!rs.eof()) {
                $('nro_period').value                = rs.getdata('nro_period')
                TareaPeriodicidad['nro_period']      = rs.getdata('nro_period')
                TareaPeriodicidad['nro_tipo_period'] = rs.getdata('nro_tipo_period')
                TareaPeriodicidad['nro_tipo_repet']  = rs.getdata('nro_tipo_repet')
                TareaPeriodicidad['dia_intervalo']   = rs.getdata('dia_intervalo') != null ? rs.getdata('dia_intervalo') : ""
                TareaPeriodicidad['sem_intervalo']   = rs.getdata('sem_intervalo') != null ? rs.getdata('sem_intervalo') : ""
                TareaPeriodicidad['sem_dia']         = rs.getdata('sem_dia') != null ? rs.getdata('sem_dia') : ""
                TareaPeriodicidad['men_intervalo']   = rs.getdata('men_intervalo') != null ? rs.getdata('men_intervalo') : ""
                TareaPeriodicidad['men_dia']         = rs.getdata('men_dia') != null ? rs.getdata('men_dia') : ""
                TareaPeriodicidad['men_ultimo_dia']  = rs.getdata('men_ultimo_dia') != null ? rs.getdata('men_ultimo_dia') : ""
                TareaPeriodicidad['men_dia_pos']     = rs.getdata('men_dia_pos') != null ? rs.getdata('men_dia_pos') : ""
                TareaPeriodicidad['men_dia_sem']     = rs.getdata('men_dia_sem') != null ? rs.getdata('men_dia_sem') : ""
                TareaPeriodicidad['anio_dia']        = rs.getdata('anio_dia') != null ? rs.getdata('anio_dia') : ""
                TareaPeriodicidad['anio_mes']        = rs.getdata('anio_mes') != null ? rs.getdata('anio_mes') : ""
                TareaPeriodicidad['anio_dia_pos']    = rs.getdata('anio_dia_pos') != null ? rs.getdata('anio_dia_pos') : ""
                TareaPeriodicidad['anio_dia_sem']    = rs.getdata('anio_dia_sem') != null ? rs.getdata('anio_dia_sem') : ""
                TareaPeriodicidad['final_repet']     = rs.getdata('final_repet') != null ? rs.getdata('final_repet') : ""
                TareaPeriodicidad['final_fecha']     = rs.getdata('final_fecha') == null ? "" : FechaToSTR(parseFecha(rs.getdata('final_fecha')))
            }
            else
                limpiar_arreglo()
        }

        function limpiar_arreglo() {
            TareaPeriodicidad['nro_period']      = ""
            TareaPeriodicidad['nro_tipo_period'] = ""
            TareaPeriodicidad['nro_tipo_repet']  = ""
            TareaPeriodicidad['dia_intervalo']   = ""
            TareaPeriodicidad['sem_intervalo']   = ""
            TareaPeriodicidad['sem_dia']         = ""
            TareaPeriodicidad['men_intervalo']   = ""
            TareaPeriodicidad['men_dia']         = ""
            TareaPeriodicidad['men_ultimo_dia']  = ""
            TareaPeriodicidad['men_dia_pos']     = ""
            TareaPeriodicidad['men_dia_sem']     = ""
            TareaPeriodicidad['anio_dia']        = ""
            TareaPeriodicidad['anio_mes']        = ""
            TareaPeriodicidad['anio_dia_pos']    = ""
            TareaPeriodicidad['anio_dia_sem']    = ""
            TareaPeriodicidad['final_repet']     = ""
            TareaPeriodicidad['final_fecha']     = ""
        }

        var win

        function tarea_periodicidad_abm() {

            if (campos_defs.value('nro_tarea_estado') != 2) {

                if (TareaPeriodicidad['nro_period'] < 0)
                    limpiar_arreglo()

                win = nvFW.createWindow({
                    url: '/wiki/tarea_periodicidad_abm.aspx',
                    title: '<b>Periodicidad</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    minWidth: 695,
                    minHeight: 400,
                    maxHeight: 400,
                    width: 695,
                    height: 400,
                    onClose: tarea_periodicidad_abm_return
                });

                win.showCenter(true)
            }
            else
                alert('La tarea está en ejecución, imposible acceder')
        }

        function tarea_periodicidad_abm_return() {
            if (win.returnValue == 'BORRADO') {

                if (TareaPeriodicidad['nro_period'] > 0) {
                    TareaPeriodicidad['nro_period'] = -TareaPeriodicidad['nro_period'] //parseInt(TareaPeriodicidad['nro_period'], 10) * -1
                    $('nro_period').value = -$('nro_period').value //$('nro_period').value * -1
                }

                if (TareaPeriodicidad['nro_period'] == 0)
                    if ($('nro_period').value < 0)
                        TareaPeriodicidad['nro_period'] = $('nro_period').value
            }
        }

        var win

        function tarea_cat_abm() {
            win = nvFW.createWindow({
                url: '/wiki/tarea_categoria_abm.aspx',
                title: '<b>Tarea Categoría ABM</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                minWidth: 400,
                minHeight: 350,
                maxHeight: 600,
                width: 800,
                height: 500,
                destroyOnClose: true,
                onClose: tarea_cat_abm_return
            });

            win.showCenter(true)
        }

        function tarea_cat_abm_return() {
            if (win.returnValue != undefined) {
                tarea_cat_cargar()
                tarea_cat_asignar()
            }
        }

        function check_aviso_todo_el_dia() {
            if ($('ch_aviso').checked) {
                if ($('fe_fin').value == '') {
                    fecha = unir_fecha_hora(cFecha($('fe_inicio').value), cHora($('ho_inicio').value))
                    Date(fecha.setDate(fecha.getDate() + 1))
                    $('fe_fin').value = FechaToSTR(fecha)
                }

                $('ho_inicio').value = '00:00'
                $('ho_fin').value = '23:59'
                $('fe_inicio_hidden').value = $('fe_inicio').value + " " + $('ho_inicio').value
                $('fe_fin_hidden').value = $('fe_fin').value + " " + $('ho_fin').value

                $('ho_inicio').disabled = true
                $('ho_fin').disabled = true
                $('ho_fin').hide()
                $('ho_inicio').hide()

                $('div_norelativo_fin').show()
                $('div_relativo_fin').hide()
                $('ch_relativo_fin').checked = false
                $('ch_relativo_fin').disabled = true

                fe_inicio_calendar.args.showTime = false
                fe_fin_calendar.args.showTime = false
                fe_inicio_calendar.redraw()
                fe_fin_calendar.redraw()
                onchange_input('_inicio')
            }
            else {
                $('ho_inicio').disabled = false
                $('ho_fin').disabled = false
                $('ho_fin').show()
                $('ho_inicio').show()

                $('ch_relativo_fin').disabled = false

                fe_inicio_calendar.args.showTime = true
                fe_fin_calendar.args.showTime = true
                fe_inicio_calendar.redraw()
                fe_fin_calendar.redraw()
            }
        }

        var aviso_calendar_ini,
            aviso_calendar_ven

        function cargar_calendar(obj) {
            var fecha_min = obj == '_ini' ? null : unir_fecha_hora(cFecha($('fe_vencimiento').value), cHora($('ho_vencimiento').value)),
                fecha_max = obj == '_ini' ? unir_fecha_hora(cFecha($('fe_inicio').value), cHora($('ho_inicio').value)) : null,
                aviso_calendar = {}

            aviso_calendar = new Calendar({
                inputField: "sel_fe_aviso_hidden" + obj,
                dateFormat: "%d/%m/%Y %H:%M",
                trigger: "img_fecha_aviso" + obj,
                bottomBar: false,
                animation: false,
                showTime: true,
                min: fecha_min,
                max: fecha_max,
                onSelect: function () {
                    $('sel_fe_aviso' + obj).value = $('div_aviso' + obj).style.diplay != 'none' ? FechaToSTR(Calendar.intToDate(this.selection.get())) : ''
                    $('sel_ho_aviso' + obj).value = $('div_aviso' + obj).style.diplay != 'none' ? this.selection.print("%H:%M") : ''
                    $('sel_fe_aviso_hidden' + obj).value = $('sel_fe_aviso' + obj).value + " " + $('sel_ho_aviso' + obj).value

                    //controla el rango de fecha
                    fecha_origen = '_ven' == obj ? '_vencimiento' : '_inicio'
                    onchange_aviso(fecha_origen)

                    this.hide();
                }
            });

            obj == '_ini' ? aviso_calendar_ini = aviso_calendar : aviso_calendar_ven = aviso_calendar
        }

        function aviso_abm(obj) {
            if ($('div_aviso' + obj).style.display == 'none') {
                var strError = ''

                if (($('fe_inicio').value == '' || $('ho_inicio').value == '') && obj == '_ini')
                    strError += 'Ingrese la fecha/hora de inicio <br/>'

                if (($('fe_vencimiento').value == '' || $('ho_vencimiento').value == '') && obj == '_ven')
                    strError += 'Ingrese la fecha/hora de vencimiento <br/>'

                if (strError != '') {
                    alert(strError)
                    return
                }

                $('img_aviso' + obj).src = "/wiki/image/icons/aviso.png"
                $('div_aviso' + obj).show()

                redibujar_aviso_calendar()

                if (($('sel_fe_aviso' + obj).value == '') || ($('sel_ho_aviso' + obj).value == '')) {
                    $('ch_relativo' + obj).checked = true
                    check_aviso_relativo(obj)
                }
            }
            else {
                tarea_aviso_ocultar(obj)
                //eval('fe' + obj + '_noti = ""')
                obj == "_ini" ? fe_ini_noti = "" : fe_ven_noti = ""
            }

        }

        function tarea_aviso_ocultar(obj) {
            $('img_aviso' + obj).src = "/wiki/image/icons/aviso_sin.png"
            $('div_aviso' + obj).hide()
            $('sel_fe_aviso' + obj).value = ''
            $('sel_ho_aviso' + obj).value = ''
        }

        var fe_inicio_calendar = {},
            fe_ini_min = null

        function cargar_calendar_inicio() {
            fe_hoy = FechaToSTR(new Date()) + " " + "00:00"
            // si es nuevo
            if ($('nro_tarea').value == 0 || $('fe_inicio').value == '')
                $('fe_inicio_hidden').value = fe_hoy
            else
                fe_ini_min = null

            showTime = $('ch_aviso').checked ? false : true

            fe_inicio_calendar = new Calendar({
                inputField: "fe_inicio_hidden",
                dateFormat: "%d/%m/%Y %H:%M",
                trigger: "sel_fecha_ini",
                showTime: showTime,
                animation: false,
                min: fe_ini_min,
                onSelect: function () {
                    $('fe_inicio').value = FechaToSTR(Calendar.intToDate(this.selection.get()))
                    $('ho_inicio').value = $('ch_aviso').checked ? '00:00' : this.selection.print("%H:%M")
                    $('fe_inicio_hidden').value = $('fe_inicio').value + " " + $('ho_inicio').value

                    comparar_fincio_fseleccion('_fin')
                    comparar_fincio_fseleccion('_vencimiento')

                    redibujar_calendar()
                    redibujar_aviso_calendar()
                    onchange_input('_inicio')

                    this.hide();
                }
            });
        }

        var fe_fin_calendar

        function cargar_calendar_fin(e) {
            var trigger = e != undefined ? Event.element(e).id : 'sel_fecha_fin',
                showTime = $('ch_aviso').checked ? false : true

            fe_fin_calendar = new Calendar({
                inputField: "fe_fin_hidden",
                dateFormat: "%d/%m/%Y %H:%M",
                trigger: trigger,
                showTime: showTime,
                animation: false,
                min: unir_fecha_hora(cFecha($('fe_inicio').value), cHora($('ho_inicio').value)),
                onSelect: function () {
                    $('fe_fin').value = FechaToSTR(Calendar.intToDate(this.selection.get()))
                    $('ho_fin').value = $('ch_aviso').checked ? '00:00' : this.selection.print("%H:%M")
                    $('fe_fin_hidden').value = $('fe_fin').value + " " + $('ho_fin').value
                    comparar_fincio_fseleccion('_fin')
                    this.hide();
                }
            });
        }

        var fe_vencimiento_calendar

        function cargar_calendar_ven(e) {
            var trigger = e != undefined ? Event.element(e).id : 'sel_fecha_ven'

            fe_vencimiento_calendar = new Calendar({
                inputField: "fe_vencimiento_hidden",
                dateFormat: "%d/%m/%Y %H:%M",
                trigger: trigger,
                showTime: true,
                animation: false,
                min: unir_fecha_hora(cFecha($('fe_inicio').value), cHora($('ho_inicio').value)),
                onSelect: function () {
                    $('fe_vencimiento').value = FechaToSTR(Calendar.intToDate(this.selection.get()));
                    $('ho_vencimiento').value = this.selection.print("%H:%M");
                    $('fe_vencimiento_hidden').value = $('fe_vencimiento').value + " " + $('ho_vencimiento').value
                    comparar_fincio_fseleccion('_vencimiento');
                    redibujar_aviso_calendar()
                    onchange_input('_vencimiento')
                    this.hide();
                }
            });
        }

        function fecha_union_hora(campo_fecha, campo_hora) {
            if (campo_fecha == '' || campo_hora == '')
                return ''
            else
                return campo_fecha + ' ' + campo_hora
        }

        function check_aviso_relativo(obj) {
            if ($('ch_relativo' + obj).checked) {
                $('div_aviso_norelativo' + obj).hide()
                $('div_aviso_relativo' + obj).show()
                onchange_cmb_relativo(obj)
            }
            else {
                //eval('fe' + obj + '_noti = "' + fecha_union_hora($('sel_fe_aviso' + obj).value, $('sel_ho_aviso' + obj).value) + '"')
                var fechaUnionHora = fecha_union_hora($('sel_fe_aviso' + obj).value, $('sel_ho_aviso' + obj).value)
                obj == "_ini" ? fe_ini_noti = fechaUnionHora : fe_ven_noti = fechaUnionHora;
                
                $('div_aviso_relativo' + obj).hide()
                $('div_aviso_norelativo' + obj).show()
            }
        }

        function check_relativo_fin() {
            if ($('ch_relativo_fin').checked) {
                $('div_norelativo_fin').hide()
                $('div_relativo_fin').show()
                onchange_cmb_relativo('_fin')
            }
            else {
                $('div_relativo_fin').hide()
                $('div_norelativo_fin').show()
            }
        }

        function onchange_cmb_relativo(obj) {

            if ($('div_aviso' + obj) != null)
                if ($('div_aviso' + obj).style.display == 'none')
                    return

            var cmb = $('cmb_aviso' + obj)
            if ((cmb.options[cmb.selectedIndex].value != '')) {
                if (obj == '_ini') {
                    fecha_origen = 'fe_inicio'
                    tiempo_origen = 'ho_inicio'
                    operador = -1
                }

                if (obj == '_ven') {
                    fecha_origen = 'fe_vencimiento'
                    tiempo_origen = 'ho_vencimiento'
                    operador = -1
                }

                if (obj == '_fin') {
                    fecha_origen = 'fe_inicio'
                    tiempo_origen = 'ho_inicio'
                    operador = 1
                }

                nominal = cmb.options[cmb.selectedIndex].value.split('~')[0]
                valor = parseInt(cmb.options[cmb.selectedIndex].value.split('~')[1], 10)
                fecha = unir_fecha_hora(cFecha($(fecha_origen).value), cHora($(tiempo_origen).value))

                res = aumentar_disminutir_fecha(nominal, (operador * valor), fecha)

                if (obj != '_fin') {
                    //eval('fe' + obj + '_noti = "' + res + '"')
                    obj == '_ini' ? fe_ini_noti = res : fe_ven_noti = res
                    $('sel_fe_aviso_hidden' + obj).value = res
                    $('sel_fe_aviso' + obj).value = res.split(' ')[0]
                    $('sel_ho_aviso' + obj).value = res.split(' ')[1]
                }
                else {
                    $('fe' + obj + '_hidden').value = res
                    $('fe' + obj).value = res.split(' ')[0]
                    $('ho' + obj).value = $('ch_aviso').checked != true ? res.split(' ')[1] : '00:00'
                }
            }
        }

        function aumentar_disminutir_fecha(nominal, valor, fecha) {
            valor = +valor //parseInt(valor, 10)
            
            if (nominal == 'H')
                Date(fecha.setMinutes(fecha.getMinutes() + (valor * 60)))
            
            if (nominal == 'M')
                Date(fecha.setMinutes(fecha.getMinutes() + valor))
            
            if (nominal == 'D')
                Date(fecha.setDate(fecha.getDate() + valor))
            
            if (nominal == 'MES')
                Date(fecha.setMonth(fecha.getMonth() + valor))

            return FechaToSTR(fecha) + " " + TiempoToSTR(fecha)
        }

        function ejecutar_calendar(calendar, obj) {
            var calendar = eval(calendar)
            calendar.popup($(obj))
        }

        var TareaOperador_ANT = [],
            ant_privado

        function onchange_privacidad(e) {
            $('observacion').innerHTML = ''

            notificaciones_actualizar()

            //privada
            if ($('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value == 1) {
                $('observacion').insert({ top: 'Solo puede verla y editarla el propietario de la misma.' })

                TareaOperador_ANT = []
                TareaOperador.each(function (arreglo, index) {
                    TareaOperador_ANT[index] = []
                    TareaOperador_ANT[index]['notificador'] = arreglo['notificador']
                });

                ant_privado = true
            }

            //solo vinculados  
            if ($('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value == 0)
                $('observacion').insert({ top: 'La tarea puede ser vista y editada solo por los operadores vinculados a la misma.' })

            //publica
            if ($('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value == 2)
                $('observacion').insert({ top: 'Puede ser vista por todos, y editada solo por los operadores vinculados.' })

            if ($('cmb_privacidad').options[$('cmb_privacidad').options.selectedIndex].value != 1 && ant_privado) {
                TareaOperador_ANT.each(function (arreglo, index) {
                    if (index > 0)  // que no sea el propietario
                        TareaOperador[index]['notificador'] = arreglo['notificador']
                });
                ant_privado = false
            }

            if (e != undefined) {
                primera_vez = false
                tarea_operador_dibujar()
            }
        }

        function onchange_input(input) {
            var obj = input == '_vencimiento' ? '_ven' : '_ini'

            if ($('fe' + input).value == '' || $('ho' + input).value == '') {
                $('img_aviso' + obj).src = "/wiki/image/icons/aviso_sin.png"
                $('div_aviso' + obj).hide()
                $('sel_fe_aviso' + obj).value = ''
                $('sel_ho_aviso' + obj).value = ''
            }
            else {
                if ($('div_aviso' + obj).style.display != 'none') {
                    //$('ch_relativo' + obj).checked = true
                    redibujar_aviso_calendar()
                    check_aviso_relativo(obj)
                    check_relativo_fin()
                }
            }
        }

        function validar_tarea_tipo_operador() {
            if ($('nro_tarea').value > 0) {
                var rs = new tRS(),
                    filtroXML = nvFW.pageContents.filtroValidadOperador,
                    filtrowhere = "<nro_tarea type='igual'>" + $('nro_tarea').value + "</nro_tarea><SQL type='sql'>operador = dbo.rm_nro_operador()</SQL>"

                rs.open(filtroXML, '', filtrowhere)

                if (!rs.eof()) {
                    if (rs.getdata('nro_tarea_tipo_rel') == 4)
                        return 'El operador es <b>invitado</b>.<br/>No puede realizar cambios.'  //invitado
                    else
                        return ''   // propietario,asistente,participante
                }
                else
                    return 'El operador no está vinculado a la tarea.<br/>No se pueden realizar cambios.'   //publico
            }
            return '' // borradas, nuevas
        }

        function validar_notificador_operador() {

            if (($('sel_fe_aviso_ini').value != '' && $('sel_ho_aviso_ini').value != '') || ($('sel_fe_aviso_ven').value != '' && $('sel_ho_aviso_ven').value != '')) {
                var str_nro_tarea_cat = '',
                    accion_notificar = false

                Categorias.each(function (arreglo, i) {
                    if ($('check_' + i).checked == true)
                        str_nro_tarea_cat += arreglo['nro_tarea_cat'] + ','
                });

                if (str_nro_tarea_cat != '') {
                    str_nro_tarea_cat = str_nro_tarea_cat.substring(0, str_nro_tarea_cat.length - 1)
                    var rs = new tRS(),
                        filtroXML = nvFW.pageContents.filtroNotificarOperador,
                        filtrowhere = "<nro_tarea_cat type='in'>" + str_nro_tarea_cat + "</nro_tarea_cat>"

                    rs.open(filtroXML, '', filtrowhere)

                    while (!rs.eof()) {
                        if (rs.getdata('notificador') > 0 && rs.getdata('notificador') != 4)
                            accion_notificar = true
                        rs.movenext()
                    }
                }

                TareaOperador.each(function (arreglo, i) {
                    if (arreglo['notificador'] > 0 && arreglo['notificador'] != 4)
                        accion_notificar = true
                });

                if (accion_notificar == false)
                    alert('Existen notificaciones y los operadores <br/>vinculados no tiene asignados estados para <br/>que se realize esta acción')
            }
        }

        var frame_cargado = false

        function ajustar_size_ModComentarios() {
            if (!frame_cargado) {
                // no ejecutar ninguna accion hasta que el IFRAME principal este disponible
                var intervaloFrameComentarios = setInterval(function() {
                    if ($('frame_comentario').contentWindow.document != null) {
                        var frame_detalle = $('frame_comentario').contentWindow.document.getElementById('iframe_detalle')
                        if (frame_detalle != null) {
                            var frame_detalle_body = frame_detalle.contentWindow.document.body
                            if (frame_detalle_body != null) {
                                // verificar si el body tiene hijos (contenido cargado)
                                if ($(frame_detalle_body).childElementCount > 0) {
                                    clearInterval(intervaloFrameComentarios)
                                    frame_cargado = true
                                    ajustarAlturaComentarios()
                                }
                            }
                        }
                    }
                }, 100) // fin intervalo "frame_comentarios"
            }
            else {
                ajustarAlturaComentarios()
            }
        }

        // funcion que se ejecuta cuando el Frame COMENTARIOS esta cargado
        function ajustarAlturaComentarios() {
            // calculos para setear las alturas
            var h_parentBody      = $$('body')[0].getHeight(), // BODY del ABM tareas
                h_menuItems       = $('divMenu').getHeight(), // MENU items del ABM tareas
                contenedores      = $$('.contenedor'), // todos los contenedores (filas => TR) del ABM tareas
                h_contenedores    = 0,
                frame_comentario  = $('frame_comentario').contentWindow.document, // Contenedor donde se carga el CKEditor o Comentarios
                h_frame_menuItems = frame_comentario.getElementById('tbTitulo').getHeight(),
                i = 0,
                max = contenedores.length - 1

            // calcular alturas de todos los contenedores menos el ultimo (comentarios)
            for (; i < max; i++) {
                h_contenedores += contenedores[i].getHeight()
            }

            // setear todas las alturas
            var ajuste = 15, // por espacios que quedan entre celdas (no capturados. Faltaría la propiedad cell-spacing en 0)
                h_body_comentarios = h_parentBody - (h_menuItems + h_contenedores + ajuste), // altura disponible para insertar el modulo de Comentarios
                h_final = h_body_comentarios - h_frame_menuItems // altura calculada para el BODY de COMENTARIOS

            // body de comentarios
            //frame_comentario.body.setStyle({ 'height': h_body_comentarios })
            setTimeout(function() {frame_comentario.body.setStyle({ 'height': h_body_comentarios })}, 5)
            
            // tabla contenedora y grupo de comentarios
            frame_comentario.getElementById('tbResto').setStyle({ 'height': h_final })
            
            // frame GRUPOS
            var td_divRight = frame_comentario.getElementById('menu_right').select('td'),
                h_td = 0

            for (i = 0; i <= 3; i++) {
                if (i != 1) // el item 1 es el que se setea, entonces hay que saltearlo
                    h_td += td_divRight[i].getHeight()
            }

            h_td += Prototype.Browser.IE ? 10 : 11 // ajuste segun browser
            // setear altura final de GRUPOS
            //frame_comentario.getElementById('divGrupo').setStyle({ height : (h_final - h_td)})
            var altura_grupo = h_final - h_td
            setTimeout(function() {frame_comentario.getElementById('divGrupo').style.height = altura_grupo + "px"}, 5)

            // setear el "iframe_detalle"
            //frame_comentario.getElementById('iframe_detalle').setStyle({ 'height': '100%' })
            setTimeout(function() {frame_comentario.getElementById('iframe_detalle').setStyle({ 'height': '100%' })}, 5)
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFFFFF;">
    <form action="" id="FrmTarea" name="FrmTarea" style="width: 100%; height: 100%; overflow: hidden">
        <input type="hidden" name="nro_tarea" id="nro_tarea" style="width: 100%; text-align: right" value="<%= nro_tarea_get %>" />
        <input type="hidden" name="nro_period" id="nro_period" value="" />
        <input type="hidden" name="fe_inicio_hidden" id="fe_inicio_hidden" />
        <input type="hidden" name="fe_fin_hidden" id="fe_fin_hidden" />
        <input type="hidden" name="fe_vencimiento_hidden" id="fe_vencimiento_hidden" />
        <div id="divCabe" style="width: 100%">
            <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
            <script type="text/javascript">
                var DocumentMNG = new tDMOffLine;
                var vMenu = new tMenu('divMenu', 'vMenu');
                
                Menus["vMenu"] = vMenu
                Menus["vMenu"].alineacion = 'centro';
                Menus["vMenu"].estilo = 'A';
                Menus["vMenu"].imagenes = Imagenes //Imagenes se declara en pvUtiles                  
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_cerrar</icono><Desc>Guardar y Cerrar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btn_guardar_click(true)</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btn_guardar_click()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")

                if (nro_rep_get > 1)
                    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>period_origen</icono><Desc>Ir al origen</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ir_tarea_origen()</Codigo></Ejecutar></Acciones></MenuItem>")

                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>AutoRun</Desc><Acciones><Ejecutar Tipo='script'><Codigo>tarea_autorun_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='6'><Lib TipoLib='offLine'>DocMNG</Lib><icono>periodicidad</icono><Desc>Periodicidad</Desc><Acciones><Ejecutar Tipo='script'><Codigo>tarea_periodicidad_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='7'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva()</Codigo></Ejecutar></Acciones></MenuItem>")
                
                vMenu.MostrarMenu()
            </script>
            <table class="tb1" id="TblTareaABM">
                <tr class="contenedor">
                    <td colspan="6">
                        <table class="tb1">
                            <tr>
                                <td rowspan="2" class="Tit1" style="width: 5%">
                                    Asunto:
                                </td>
                                <td rowspan="2">
                                    <textarea name="asunto" id="asunto" style="width: 100%; border-width: 1px; resize: none" cols="12" rows="3"></textarea>
                                </td>
                                <td class="Tit1" style="width: 5%" nowrap="nowrap">
                                    Fecha Estado:
                                </td>
                                <td style="width: 15%">
                                    <input type="text" name="fe_estado" id="fe_estado" style="width: 100%; text-align: right; background-color: #E9F0F4; border-width: 0px; text-align: center" readonly="readonly" />
                                </td>
                                <td class="Tit1" style="width: 5%">
                                    Prioridad:
                                </td>
                                <td style="width: 15%">
                                    <%= nvFW.nvCampo_def.get_html_input("nro_tarea_pri") %>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1" style="width: 5%">
                                    Estado:
                                </td>
                                <td style="width: 15%">
                                    <%= nvFW.nvCampo_def.get_html_input("nro_tarea_estado") %>
                                </td>
                                <td class="Tit1" style="width: 5%" nowrap="nowrap">
                                    % Completado:
                                </td>
                                <td style="width: 15%">
                                    <select id="completado">
                                        <option value="0">0</option>
                                        <option value="25">25</option>
                                        <option value="50">50</option>
                                        <option value="75">75</option>
                                        <option value="100">100</option>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="contenedor">
                    <td colspan="6">
                        <table class="tb1">
                            <tr>
                                <td class="Tit1" style="width: 5%">
                                    Inicio:
                                </td>
                                <td style="width: 17%; vertical-align: middle; text-align: left">
                                    <input type="text" name="fe_inicio" id="fe_inicio" ondblclick="return ejecutar_calendar('fe_inicio_calendar', 'fe_inicio')"
                                        style="width: 44%; text-align: right" onchange="return valFecha(event) || onchange_input('_inicio') || redibujar_calendar() || comparar_fincio_fseleccion('_fin') || comparar_fincio_fseleccion('_vencimiento')"
                                        onkeypress="return valDigito(event, '/')" />
                                    <input type="text" name="ho_inicio" id="ho_inicio" ondblclick="return ejecutar_calendar('fe_inicio_calendar', 'ho_inicio')"
                                        style="width: 28%; text-align: right" onchange="return valTiempo(event) || onchange_input('_inicio') || redibujar_calendar() || comparar_fincio_fseleccion('_fin') || comparar_fincio_fseleccion('_vencimiento')"
                                        onkeypress="return valDigito(event, ':')" />
                                    <img alt="" title="Seleccionar Fecha" id="sel_fecha_ini" src="/FW/image/icons/periodo.png" style="vertical-align: middle; cursor: hand; cursor: pointer" />
                                </td>
                                <td style="width: 3%; padding-right: 5px" rowspan="2" nowrap="nowrap">
                                    <input type='checkbox' id='ch_aviso' style="border-width: 0px !Important; vertical-align: middle" onclick='check_aviso_todo_el_dia()' />Todo el día&nbsp;&nbsp;
                                </td>
                                <td rowspan="3" style="width: 20px">
                                    <img alt="Aviso" title="Aviso Inicio" id="img_aviso_ini" src="/wiki/image/icons/aviso_sin.png" style="vertical-align: middle; cursor: hand; cursor: pointer" onclick="return aviso_abm('_ini')" />
                                </td>
                                <td rowspan="3" style="text-align: center; width: 17%; height: 70px; padding-left: 10px">
                                    <div id="div_aviso_ini" style="width: 100%; display: none">
                                        <table class="tb1">
                                            <tr>
                                                <td class="Tit1" style="text-align: center">
                                                    Aviso
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="font-size: 12px !important" nowrap="nowrap">
                                                    <input type="checkbox" id="ch_relativo_ini" value="" style="width: 20px; border-width: 0px !Important" 
                                                    onclick="check_aviso_relativo('_ini')" />Relativo al inicio
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="div_aviso_norelativo_ini" style="width: 100%">
                                                        <input type="hidden" name="sel_fe_aviso_hidden_ini" id="sel_fe_aviso_hidden_ini" value="" />
                                                        <input type='text' name='sel_fe_aviso_ini' id='sel_fe_aviso_ini' ondblclick="return ejecutar_calendar('aviso_calendar_ini', 'sel_fe_aviso_ini')"
                                                            style='width: 51%; text-align: right; vertical-align: middle' onchange='return valFecha(event)'
                                                            onkeypress='return valDigito(event, "/")' />
                                                        <input type='text' name='sel_ho_aviso_ini' id='sel_ho_aviso_ini' ondblclick="return ejecutar_calendar('aviso_calendar_ini', 'sel_ho_aviso_ini')"
                                                            style='width: 31%; text-align: right; vertical-align: middle' onchange='return valTiempo(event)'
                                                            onkeypress='return valDigito(event, ":")' />
                                                        <img alt='' title='Seleccione Fecha' id='img_fecha_aviso_ini' src='/FW/image/icons/periodo.png' style='vertical-align: middle; cursor: hand; cursor: pointer' />
                                                    </div>
                                                    <div id="div_aviso_relativo_ini" style="width: 100%; display: none">
                                                        <select id="cmb_aviso_ini" style="width: 68%" onchange="onchange_cmb_relativo('_ini')">
                                                            <option value="M~5">5 minutos</option>
                                                            <option value="M~10">10 minutos</option>
                                                            <option value="M~15">15 minutos</option>
                                                            <option value="M~20">20 minutos</option>
                                                            <option value="M~30">30 minutos</option>
                                                            <option value="M~45">45 minutos</option>
                                                            <option value="M~50">50 minutos</option>
                                                            <option value="H~1">1 horas</option>
                                                            <option value="H~2">2 horas</option>
                                                            <option value="D~1">1 día</option>
                                                            <option value="D~2">2 días</option>
                                                            <option value="MES~1">1 mes</option>
                                                        </select>
                                                        antes
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                                <td style="width: 20px" rowspan="3">
                                    &nbsp;
                                </td>
                                <td class="Tit1" rowspan="2" style="width: 5%">
                                    Vencimiento:
                                </td>
                                <td rowspan="3" style="width: 17%; vertical-align: middle; text-align: left">
                                    <input type="text" name="fe_vencimiento" id="fe_vencimiento" ondblclick="return ejecutar_calendar('fe_vencimiento_calendar', 'fe_vencimiento')"
                                        style="width: 50%; text-align: right" onchange="return valFecha(event) || onchange_input('_vencimiento') || redibujar_calendar() || comparar_fincio_fseleccion('_vencimiento')"
                                        onkeypress="return valDigito(event, '/')" />
                                    <input type="text" name="ho_inicio" id="ho_vencimiento" ondblclick="return ejecutar_calendar('fe_vencimiento_calendar', 'ho_vencimiento')"
                                        style="width: 30%; text-align: right" onchange="return valTiempo(event) || onchange_input('_vencimiento') || redibujar_calendar() || comparar_fincio_fseleccion('_vencimiento')"
                                        onkeypress="return valDigito(event, ':')" />
                                    <img alt="" title="Seleccionar Fecha" id="sel_fecha_ven" src="/FW/image/icons/periodo.png" style="vertical-align: middle; cursor: hand; cursor: pointer" />
                                </td>
                                <td rowspan="3" style="width: 20px">
                                    <img alt="Aviso" title="Aviso" id="img_aviso_ven" src="/wiki/image/icons/aviso_sin.png" style="vertical-align: middle; cursor: hand; cursor: pointer" onclick="return aviso_abm('_ven')" />
                                </td>
                                <td style='width: 18%; height: 70px' rowspan="2">
                                    <div id="div_aviso_ven" style="width: 100%; display: none">
                                        <table class="tb1">
                                            <tr>
                                                <td class="Tit1" style="text-align: center">
                                                    Aviso
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style='font-size: 12px !important' nowrap="nowrap">
                                                    <input type="checkbox" id="ch_relativo_ven" value="" style="width: 20px; border-width: 0px !Important"
                                                        onclick="check_aviso_relativo('_ven')" />Relativo al vencimiento
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="div_aviso_norelativo_ven" style="width: 100%">
                                                        <input type="hidden" name="sel_fe_aviso_hidden_ven" id="sel_fe_aviso_hidden_ven"
                                                            value="" />
                                                        <input type='text' name='sel_fe_aviso_ven' id='sel_fe_aviso_ven' ondblclick="return ejecutar_calendar('aviso_calendar_ven', 'sel_fe_aviso_ven')"
                                                            style='width: 46%; text-align: right; vertical-align: middle' onchange='return valFecha(event)'
                                                            onkeypress='return valDigito(event, "/")' />
                                                        <input type='text' name='sel_ho_aviso_ven' id='sel_ho_aviso_ven' ondblclick="return ejecutar_calendar('aviso_calendar_ven', 'sel_ho_aviso_ven')"
                                                            style='width: 28%; text-align: right; vertical-align: middle' onchange='return valTiempo(event)'
                                                            onkeypress='return valDigito(event, ":")' />
                                                        <img alt='' title='Seleccione Fecha' id='img_fecha_aviso_ven' src='/FW/image/icons/periodo.png'
                                                            style='vertical-align: middle; cursor: hand; cursor: pointer' />
                                                    </div>
                                                    <div id="div_aviso_relativo_ven" style="width: 100%; display: none;">
                                                        <select id="cmb_aviso_ven" style="width: 60%" onchange="onchange_cmb_relativo('_ven')">
                                                            <option value="M~5">5 minutos</option>
                                                            <option value="M~10">10 minutos</option>
                                                            <option value="M~15">15 minutos</option>
                                                            <option value="M~20">20 minutos</option>
                                                            <option value="M~30">30 minutos</option>
                                                            <option value="M~45">45 minutos</option>
                                                            <option value="M~50">50 minutos</option>
                                                            <option value="H~1">1 horas</option>
                                                            <option value="H~2">2 horas</option>
                                                            <option value="D~1">1 día</option>
                                                            <option value="D~2">2 días</option>
                                                            <option value="MES~1">1 mes</option>
                                                        </select>
                                                        antes
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1" style="width: 5%">
                                    Finalización:
                                </td>
                                <td rowspan="3" style="vertical-align: middle; width: 20%; height: 55px">
                                    <div id="div_fin" style="width: 100%">
                                        <table class="tb1">
                                            <tr>
                                                <td style="font-size: 12px !important" nowrap="nowrap">
                                                    <input type="checkbox" id="ch_relativo_fin" value="" style="width: 20px; border-width: 0px !Important" 
                                                    onclick="check_relativo_fin()" />Relativo al inicio
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="div_norelativo_fin" style="width: 100%">
                                                        <input type='text' name='fe_fin' id='fe_fin' ondblclick="return ejecutar_calendar('fe_fin_calendar', 'fe_fin')"
                                                            style='width: 44%; text-align: right; vertical-align: middle' onchange="return valFecha(event) || comparar_fincio_fseleccion('_fin')"
                                                            onkeypress="return valDigito(event, '/')" />
                                                        <input type='text' name='ho_fin' id='ho_fin' ondblclick="return ejecutar_calendar('fe_fin_calendar', 'ho_fin')"
                                                            style='width: 28%; text-align: right; vertical-align: middle' onchange="return valTiempo(event) || comparar_fincio_fseleccion('_fin')"
                                                            onkeypress="return valDigito(event, ':')" />
                                                        <img alt='' title='Seleccione Fecha' id='sel_fecha_fin' src='/FW/image/icons/periodo.png' style='vertical-align: middle; cursor: hand; cursor: pointer' />
                                                    </div>
                                                    <div id="div_relativo_fin" style="width: 100%; display: none">
                                                        <select id="cmb_aviso_fin" style="width: 63%" onchange="onchange_cmb_relativo('_fin')">
                                                            <option value="M~5">5 minutos</option>
                                                            <option value="M~10">10 minutos</option>
                                                            <option value="M~15">15 minutos</option>
                                                            <option value="M~20">20 minutos</option>
                                                            <option value="M~30" selected="selected">30 minutos</option>
                                                            <option value="M~45">45 minutos</option>
                                                            <option value="M~50">50 minutos</option>
                                                            <option value="H~1">1 horas</option>
                                                            <option value="H~2">2 horas</option>
                                                            <option value="D~1">1 día</option>
                                                            <option value="D~2">2 días</option>
                                                            <option value="MES~1">1 mes</option>
                                                        </select>
                                                        despues
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="contenedor">
                    <td style="width: 100%" colspan="6">
                        <table class="tb1">
                            <tr>
                                <td style="width: 75%; vertical-align: top;" id="td_frame_comentarios">
                                    <table style="display: none">
                                        <tr>
                                            <td><%= nvFW.nvCampo_def.get_html_input("nro_operador") %></td>
                                        </tr>
                                    </table>
                                    <div id="divMenuO" style="margin: 0px; padding: 0px;"></div>
                                    <script type="text/javascript">
                                        var DocumentMNG = new tDMOffLine;
                                        var vMenuO      = new tMenu('divMenuO', 'vMenuO');

                                        Menus["vMenuO"] = vMenuO
                                        Menus["vMenuO"].alineacion = "centro"
                                        Menus["vMenuO"].estilo     = "A"
                                        Menus["vMenuO"].imagenes   = Imagenes
                                        Menus["vMenuO"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vincular</icono><Desc>Seleccionar Operadores</Desc></MenuItem>")
                                        
                                        vMenuO.MostrarMenu()
                                    </script>
                                    <table class='tb1'>
                                        <tr class='tbLabel'>
                                            <td style='width: 4%'></td>
                                            <td colspan="2" style='width: 58%'>
                                                Operador
                                            </td>
                                            <td style='width: 4%; text-align:center;' title='Cambiar Estado'>
                                                CE
                                            </td>
                                            <td style='width: 4%; text-align:center;' title='Progreso'>
                                                P
                                            </td>
                                            <td style='width: 4%; text-align:center;' title='Conclusión'>
                                                C
                                            </td>
                                            <td style='width: 20%'>
                                                Tipo
                                            </td>
                                            <td style='width: 2%'>
                                                <div style="overflow: scroll; height: 1px; width: 1px">&nbsp;</div>
                                            </td>
                                        </tr>
                                    </table>
                                    <div id="divTareaOperador" style="width: 100%; overflow: auto"></div>
                                </td>
                                <td style="vertical-align: top">
                                    <table class="tb1">
                                        <tr class="tbLabel">
                                            <td style="background: #FFFFFF !important">
                                                <div id="divMenuCat" style="margin: 0px; padding: 0px;"></div>
                                                <script type="text/javascript">
                                                    var DocumentMNG = new tDMOffLine;
                                                    var vMenuCat = new tMenu('divMenuCat','vMenuCat');

                                                    Menus["vMenuCat"] = vMenuCat
                                                    Menus["vMenuCat"].alineacion = 'centro';
                                                    Menus["vMenuCat"].estilo = 'A';
                                                    Menus["vMenuCat"].imagenes = Imagenes
                                                    Menus["vMenuCat"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 15%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>-</Desc><Acciones><Ejecutar Tipo='script'><Codigo></Codigo></Ejecutar></Acciones></MenuItem>")
                                                    Menus["vMenuCat"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Categoría</Desc></MenuItem>")
                                                    Menus["vMenuCat"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>tarea_cat_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
                                                
                                                    vMenuCat.MostrarMenu()
                                                </script>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div id="div_cat" style='width: 100%; height: 120px; overflow: auto'></div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="contenedor">
                    <td colspan="6">
                        <table class="tb1">
                            <tr>
                                <td class="Tit1" style="width: 5%; text-align: center">
                                    Privacidad:
                                </td>
                                <td style="width: 14%">
                                    <select id="cmb_privacidad" style="width: 100%" onchange="onchange_privacidad(event)">
                                        <option value="0">Solo Vinculados</option>
                                        <option value="1">Privada</option>
                                        <option value="2">Publica</option>
                                    </select>
                                </td>
                                <td id="observacion">
                                    &nbsp;
                                </td>
                                <td class="Tit1" style="width: 11%; text-align: center" nowrap="nowrap">
                                    Notificar inactividad:
                                </td>
                                <td style="width: 14%">
                                    <select id="cmb_noti_inactividad" style="width: 100%">
                                        <option value="0" selected="selected"></option>
                                        <option value="1">1 día</option>
                                        <option value="2">2 días</option>
                                        <option value="3">3 días</option>
                                        <option value="7">1 Semana</option>
                                        <option value="14">2 Semanas</option>
                                        <option value="30">1 Mes</option>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="contenedor">
                    <td id="contenedor_frame_comentario" style="height: 150px; vertical-align: top;">
                        <textarea id="descripcion" name="descripcion" style="width: 100%; border-width: 1px; resize: none; display: none;" cols="8" rows="8"></textarea>
                        <iframe name="frame_comentario" id="frame_comentario" style="width: 100%; height: 100%; overflow: auto; display: none;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
