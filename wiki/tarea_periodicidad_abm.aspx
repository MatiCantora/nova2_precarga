<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    ' Obtenemos el valor de numero de periodo desde el submit()
    Dim nro_period_get = nvFW.nvUtiles.obtenerValor("nro_period_get", "")
%>
<html>
<head>
    <title>Tarea Periodicidad ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/wiki/script/cboOtro.js"></script>

    <style type="text/css">
        td > label:hover { cursor: hand; cursor: pointer; }
    </style>

    <script type="text/javascript">

        var Imagenes  = [];

        Imagenes["eliminar"] = new Image();
        Imagenes["eliminar"].src = '/wiki/image/icons/eliminar.png';
        Imagenes["guardar"] = new Image();
        Imagenes["guardar"].src = '/FW/image/icons/guardar.png';
        Imagenes["info"] = new Image();
        Imagenes["info"].src = '/FW/image/icons/info.png';
        Imagenes["dep_padre"] = new Image();
        Imagenes["dep_padre"].src = '/wiki/image/icons/dep_padre.png';
        Imagenes["dep_hijo"] = new Image();
        Imagenes["dep_hijo"].src = '/wiki/image/icons/dep_hijo.png';
        Imagenes["favorito_si"] = new Image();
        Imagenes["favorito_si"].src = '/wiki/image/icons/favorito_si.png';
        Imagenes["nueva"] = new Image();
        Imagenes["nueva"].src = '/FW/image/icons/nueva.png';
        Imagenes["upload"] = new Image();
        Imagenes["upload"].src = '/wiki/image/icons/upload.png';
        Imagenes["cerrar"] = new Image();
        Imagenes["cerrar"].src = '/FW/image/icons/guardar_cerrar.png';
        Imagenes["guardar_como"] = new Image();
        Imagenes["guardar_como"].src = '/wiki/image/icons/guardar_como.png';
        Imagenes["guardar_cerrar"] = new Image();
        Imagenes["guardar_cerrar"].src = '/wiki/image/icons/guardar_cerrar.png';

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Aceptar";
        vButtonItems[0]["etiqueta"] = "Aceptar";
        vButtonItems[0]["imagen"] = "";
        vButtonItems[0]["onclick"] = "return Aceptar()";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "";
        vButtonItems[1]["onclick"] = "return Cancelar()";

        vButtonItems[2] = {};
        vButtonItems[2]["nombre"] = "QuitarRepeticion";
        vButtonItems[2]["etiqueta"] = "Quitar Repeticion";
        vButtonItems[2]["imagen"] = "";
        vButtonItems[2]["onclick"] = "return QuitarRepeticion()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.imagenes = Imagenes //Imagenes se declara en pvUtiles  

        var ho_inicio = parent.$('ho_inicio').value,
            ho_fin = parent.$('ho_fin').value

        function window_onload() {
            vListButton.MostrarListButton()
            
            new HrvToolkit.Utilidades.ComboEditable('cmb_fe_inicio')
            HrvToolkit.Utilidades.ComboEditable.prototype.initialize('cmb_fe_inicio')
            HrvToolkit.Utilidades.ComboEditable.prototype.AddItem($('cmb_fe_inicio'), ho_inicio)

            new HrvToolkit.Utilidades.ComboEditable('cmb_fe_fin')
            HrvToolkit.Utilidades.ComboEditable.prototype.initialize('cmb_fe_fin')
            HrvToolkit.Utilidades.ComboEditable.prototype.AddItem($('cmb_fe_fin'), ho_fin)
            
            $('fe_inicio').value = "Inicio: " + parent.$('fe_inicio').value
            $('fe_fin').value = "Fin: " + parent.$('fe_fin').value

            fecha_inicio = parent.unir_fecha_hora(parent.cFecha(parent.$('fe_inicio').value), parent.cHora(parent.$('ho_inicio').value))
            fecha_fin = parent.unir_fecha_hora(parent.cFecha(parent.$('fe_fin').value), parent.cHora(parent.$('ho_fin').value))

            $('duracion').value = diferencia_fechas(fecha_inicio, fecha_fin)

            cargar_calendar_intervalo()
            cargar_periodicidad()

            final_fecha_calendar.args.min = fecha_inicio
            final_fecha_calendar.redraw()
        }

        function diferencia_fechas(fecha_inicio, fecha_fin) {
            var diferencia = fecha_fin.getTime() - fecha_inicio.getTime()

            var dias = Math.floor(diferencia / (1000 * 60 * 60 * 24))

            direfencia = dias * (1000 * 60 * 60 * 24)
            var total_horas = Math.floor(diferencia / (1000 * 60 * 60))
            var horas = total_horas - (dias * 24)

            direfencia = total_horas * (1000 * 60 * 60)
            var total_minutos = Math.floor(diferencia / (1000 * 60))
            var minutos = total_minutos - (total_horas * 60)

            horas = horas == 0 ? "00" : horas
            horas = horas > 0 && horas < 10 ? "0" + horas : horas

            minutos = minutos > 0 && minutos < 10 ? "0" + minutos : minutos
            minutos = minutos == 0 ? "00" : minutos

            minutos = minutos + " horas"
            dias = dias == 0 ? '' : dias + " dias "

            return dias + horas + ":" + minutos
        }

        function onchange_cmb(obj) {
            var fecha_inicio = parent.$('fe_inicio').value + " " + $('cmb_fe_inicio').options[$('cmb_fe_inicio').selectedIndex].text
            var fecha_fin = parent.$('fe_fin').value + " " + $('cmb_fe_fin').options[$('cmb_fe_fin').selectedIndex].text

            if (parent.comparar_fechasyhora(fecha_inicio, fecha_fin) == 1)
                HrvToolkit.Utilidades.ComboEditable.prototype.AddItem($('cmb_fe_fin'), $('cmb_fe_inicio').options[$('cmb_fe_inicio').selectedIndex].text)

            fecha_inicio = parent.unir_fecha_hora(parent.cFecha(parent.$('fe_inicio').value), parent.cHora($('cmb_fe_inicio').options[$('cmb_fe_inicio').selectedIndex].text))
            fecha_fin = parent.unir_fecha_hora(parent.cFecha(parent.$('fe_fin').value), parent.cHora($('cmb_fe_fin').options[$('cmb_fe_fin').selectedIndex].text))

            $('duracion').value = diferencia_fechas(fecha_inicio, fecha_fin)
        }

        function nuevo() {
            visualizar_div('divRepetirDiario')
            $('FrmPer').RadioR[0].checked = true
            $('nro_period').value = 0
        }

        function Cancelar() {
            parent.win.close()
        }

        function QuitarRepeticion() {
            nvFW.confirm("¿Desea eliminar la periodicidad?", {
                width: 300,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    parent.win.returnValue = 'BORRADO'
                    win.close()
                    parent.win.close()
                }
            });

        }

        var final_fecha_calendar
        function cargar_calendar_intervalo() {
            final_fecha_calendar = new Calendar({
                inputField: "final_fecha",
                dateFormat: "%d/%m/%Y %H:%M",
                trigger: "img_final_fecha",
                showTime: false,
                animation: false,
                min: null,
                onSelect: function () {
                    $('final_fecha').value = FechaToSTR(Calendar.intToDate(this.selection.get()));
                    this.hide();
                }
            });
        }

        function visualizar_div(div_id) {
            var div = new Array();
            div[0] = new Array();
            div[0]['id'] = 'divRepetirDiario'
            div[1] = new Array();
            div[1]['id'] = 'divRepetirSemanal'
            div[2] = new Array();
            div[2]['id'] = 'divRepetirMensual'
            div[3] = new Array();
            div[3]['id'] = 'divRepetirAnual'

            div.each(function (arreglo, i) {
                if (div_id == arreglo['id'])
                    $(arreglo['id']).show()
                else
                    $(arreglo['id']).hide()
            });

            if (div_id == 'divRepetirDiario') {
                $('FrmPer').RadioF[0].checked = true
                $('dia_intervalo').focus()
            }

            if (div_id == 'divRepetirSemanal') {
                $('FrmPer').RadioF[1].checked = true
                $('sem_intervalo').focus()
            }

            if (div_id == 'divRepetirMensual') {
                $('FrmPer').RadioF[2].checked = true
                $('FrmPer').RadioMensual[0].checked = true
                $('men_dia').focus()
            }

            if (div_id == 'divRepetirAnual') {
                $('FrmPer').RadioF[3].checked = true
                $('FrmPer').RadioAnual[0].checked = true
                $('anio_dia').focus()
            }
        }

        function obtener_dias_laborales() {
            var i = 1
            var sem_dia = 0
            while (i <= 7) {
                if ($('ck_' + i).checked == true)
                    sem_dia = sem_dia + Math.pow(2, i - 1)
                i++
            }
            return sem_dia
        }

        function cargar_dias_laborales(sem_dia) {
            var i = 1
            while (i <= 7) {
                if ((Math.pow(2, i - 1) & sem_dia) > 0)
                    $('ck_' + i).checked = true
                i++
            }
        }

        var TareaPeriodicidad = parent.TareaPeriodicidad
        function cargar_periodicidad() {
            $('nro_period').value = TareaPeriodicidad['nro_period']

            //diario
            $('dia_intervalo').value = TareaPeriodicidad['dia_intervalo']
            if ($('dia_intervalo').value != '')
                visualizar_div('divRepetirDiario')

            //semanal        
            $('sem_intervalo').value = TareaPeriodicidad['sem_intervalo']
            if (TareaPeriodicidad['sem_dia'] != '')
                cargar_dias_laborales(parseInt(TareaPeriodicidad['sem_dia'], 10))

            if (TareaPeriodicidad['sem_intervalo'] != '')
                visualizar_div('divRepetirSemanal')

            //mensual
            var men_intervalo = TareaPeriodicidad['men_intervalo']
            var men_dia = TareaPeriodicidad['men_dia']
            var men_ultimo_dia = TareaPeriodicidad['men_ultimo_dia']
            var men_dia_pos = TareaPeriodicidad['men_dia_pos']
            var men_dia_sem = TareaPeriodicidad['men_dia_sem']

            if (men_intervalo != '' && men_dia != '') {
                $('men_intervalo_1').value = men_intervalo
                $('men_dia').value = men_dia
                visualizar_div('divRepetirMensual')
                $('FrmPer').RadioMensual[0].checked = true
                $('men_dia').focus()
            }

            if (men_ultimo_dia != '') {
                $('men_intervalo_2').value = men_intervalo
                visualizar_div('divRepetirMensual')
                $('FrmPer').RadioMensual[1].checked = true
                $('men_intervalo_2').focus()
            }

            if (men_dia_pos != '' && men_dia_sem != '' && men_intervalo != '') {
                cargar_cmb('men_dia_pos', men_dia_pos)
                cargar_cmb('men_dia_sem', men_dia_sem)
                $('men_intervalo_3').value = men_intervalo
                visualizar_div('divRepetirMensual')
                $('FrmPer').RadioMensual[2].checked = true
                $('men_intervalo_3').focus()
            }

            //anual 
            var anio_dia = TareaPeriodicidad['anio_dia']
            var anio_mes = TareaPeriodicidad['anio_mes']
            var anio_dia_pos = TareaPeriodicidad['anio_dia_pos']
            var anio_dia_sem = TareaPeriodicidad['anio_dia_sem']

            if (anio_dia != '' && anio_mes != '') {
                $('anio_dia').value = anio_dia
                cargar_cmb('anio_mes_1', anio_mes)
                visualizar_div('divRepetirAnual')
                $('FrmPer').RadioAnual[0].checked = true
            }

            if (anio_dia_pos != '' && anio_dia_sem != '' && anio_mes != '') {
                cargar_cmb('anio_dia_pos', anio_dia_pos)
                cargar_cmb('anio_dia_sem', anio_dia_sem)
                cargar_cmb('anio_mes_2', anio_mes)
                visualizar_div('divRepetirAnual')
                $('FrmPer').RadioAnual[1].checked = true
            }

            //finalizacion

            var final_repet = TareaPeriodicidad['final_repet']
            var final_fecha = TareaPeriodicidad['final_fecha']

            if (final_repet >= 0)
                if (final_repet == 0)
                    $('FrmPer').RadioR[0].checked = true
                else {
                    $('final_repet').value = final_repet
                    $('FrmPer').RadioR[1].checked = true
                }

            if (final_fecha != '') {
                $('final_fecha').value = final_fecha
                $('FrmPer').RadioR[2].checked = true
            }

            if (TareaPeriodicidad['nro_period'] == '')
                nuevo()
        }

        function cargar_cmb(cmb, valor) {
            for (i = 0; i < $(cmb).options.length; i++) {
                if (valor == $(cmb).options[i].value)
                    $(cmb).options[i].selected = true
            }
        }

        function limpiar_arreglo() {
            TareaPeriodicidad['nro_period'] = ''
            TareaPeriodicidad['nro_tipo_period'] = ''
            TareaPeriodicidad['nro_tipo_repet'] = ''
            TareaPeriodicidad['dia_intervalo'] = ''
            TareaPeriodicidad['sem_intervalo'] = ''
            TareaPeriodicidad['sem_dia'] = ''
            TareaPeriodicidad['men_intervalo'] = ''
            TareaPeriodicidad['men_dia'] = ''
            TareaPeriodicidad['men_ultimo_dia'] = ''
            TareaPeriodicidad['men_dia_pos'] = ''
            TareaPeriodicidad['men_dia_sem'] = ''
            TareaPeriodicidad['anio_dia'] = ''
            TareaPeriodicidad['anio_mes'] = ''
            TareaPeriodicidad['anio_dia_pos'] = ''
            TareaPeriodicidad['anio_dia_sem'] = ''
            TareaPeriodicidad['final_repet'] = ''
            TareaPeriodicidad['final_fecha'] = ''
        }

        function validar() {

            var strError = ''
            switch (frecuencia) {
                case 1:
                    if ($('dia_intervalo').value == '')
                        strError = 'Ingrese el número del intervalo <br/>'
                    break
                case 2:
                    if ($('sem_intervalo').value == '')
                        strError += 'Ingrese el número del intervalo <br/>'
                    existen_checkeados = false
                    var i = 1
                    while (i <= 7) {
                        if ($('ck_' + i).checked == true)
                            existen_checkeados = true
                        i++
                    }
                    if (existen_checkeados == false)
                        strError += 'Seleccione los dias de la semana <br/>'
                    break
                case 3:
                    if ($('FrmPer').RadioMensual[0].checked == true)
                        if ($('men_dia').value == '' || $('men_intervalo_1').value == '')
                            strError += 'Unos de los campos esta incompleto <br/>'
                    if ($('FrmPer').RadioMensual[1].checked == true)
                        if ($('men_intervalo_2').value == '')
                            strError += 'El intervalo esta incompleto <br/>'
                    if ($('FrmPer').RadioMensual[2].checked == true)
                        if ($('men_intervalo_3').value == '')
                            strError += 'Ingrese el número del intervalo <br/>'
                    break
                case 4:
                    if ($('FrmPer').RadioAnual[0].checked == true)
                        if ($('anio_dia').value == '')
                            strError += 'Ingrese el dia <br/>'
                    break
            }

            switch (radio_repet_sel) {
                case 2:
                    if ($('final_repet').value == '')
                        strError += 'Ingrese la cantidad de repeticiones <br/>'
                    break
                case 3:
                    if ($('final_fecha').value == '')
                        strError += 'Ingrese la fecha de finalización <br/>'
                    break
            }

            if (strError != '')
                return strError
            else
                return ''
        }

        var frecuencia
        var radio_repet_sel
        function Aceptar() {
            frecuencia = 0
            for (var i = 0 ; i < $('FrmPer').RadioF.length ; i++) {
                if ($('FrmPer').RadioF[i].checked == true)
                    frecuencia = parseInt($('FrmPer').RadioF[i].value, 10)
            }

            radio_repet_sel = 0
            for (var i = 0 ; i < $('FrmPer').RadioR.length ; i++) {
                if ($('FrmPer').RadioR[i].checked == true)
                    radio_repet_sel = parseInt($('FrmPer').RadioR[i].value, 10)
            }

            var strError = validar()
            if (strError != '') {
                alert(strError)
                return
            }

            limpiar_arreglo()

            TareaPeriodicidad['nro_period'] = $('nro_period').value
            TareaPeriodicidad['nro_tipo_period'] = frecuencia
            TareaPeriodicidad['nro_tipo_repet'] = radio_repet_sel

            switch (frecuencia) {
                case 1:
                    TareaPeriodicidad['dia_intervalo'] = $('dia_intervalo').value
                    break

                case 2:
                    TareaPeriodicidad['sem_intervalo'] = $('sem_intervalo').value
                    TareaPeriodicidad['sem_dia'] = obtener_dias_laborales()
                    break

                case 3:

                    var radio_mensual_sel
                    for (var i = 0 ; i < $('FrmPer').RadioMensual.length ; i++) {
                        if ($('FrmPer').RadioMensual[i].checked == true)
                            radio_mensual_sel = parseInt($('FrmPer').RadioMensual[i].value, 10)
                    }

                    TareaPeriodicidad['men_intervalo'] = (radio_mensual_sel == 1 ? $('men_intervalo_1').value : radio_mensual_sel == 2 ? $('men_intervalo_2').value : radio_mensual_sel == 3 ? $('men_intervalo_3').value : '')
                    TareaPeriodicidad['men_dia'] = (radio_mensual_sel == 1 ? $('men_dia').value : '')
                    TareaPeriodicidad['men_ultimo_dia'] = (radio_mensual_sel == 2 ? 1 : '')
                    TareaPeriodicidad['men_dia_pos'] = (radio_mensual_sel == 3 ? $('men_dia_pos').options[$('men_dia_pos').selectedIndex].value : '')
                    TareaPeriodicidad['men_dia_sem'] = (radio_mensual_sel == 3 ? $('men_dia_sem').options[$('men_dia_sem').selectedIndex].value : '')
                    break

                case 4:
                    var radio_anual_sel
                    for (var i = 0 ; i < $('FrmPer').RadioAnual.length ; i++) {
                        if ($('FrmPer').RadioAnual[i].checked == true)
                            radio_anual_sel = parseInt($('FrmPer').RadioAnual[i].value, 10)
                    }

                    TareaPeriodicidad['anio_dia'] = (radio_anual_sel == 1 ? $('anio_dia').value : '')
                    TareaPeriodicidad['anio_mes'] = ((radio_anual_sel == 1) ? $('anio_mes_1').options[$('anio_mes_1').selectedIndex].value : (radio_anual_sel == 2) ? $('anio_mes_2').options[$('anio_mes_2').selectedIndex].value : '')
                    TareaPeriodicidad['anio_dia_pos'] = (radio_anual_sel == 2 ? $('anio_dia_pos').options[$('anio_dia_pos').selectedIndex].value : '')
                    TareaPeriodicidad['anio_dia_sem'] = (radio_anual_sel == 2 ? $('anio_dia_sem').options[$('anio_dia_sem').selectedIndex].value : '')
                    break

            }

            var final_repet = ''
            var final_fecha = ''

            if (radio_repet_sel == 1)
                final_repet = 0

            if (radio_repet_sel == 2)
                final_repet = $('final_repet').value

            if (radio_repet_sel == 3)
                final_fecha = $('final_fecha').value

            TareaPeriodicidad['final_repet'] = final_repet
            TareaPeriodicidad['final_fecha'] = final_fecha

            parent.TareaPeriodicidad = TareaPeriodicidad

            if (!parent.$('ch_aviso').checked) {
                parent.$('ho_inicio').value = $('cmb_fe_inicio').options[$('cmb_fe_inicio').selectedIndex].text
                parent.$('ho_fin').value = $('cmb_fe_fin').options[$('cmb_fe_fin').selectedIndex].text

                parent.$('fe_inicio_hidden').value = parent.$('fe_inicio').value + " " + $('cmb_fe_inicio').options[$('cmb_fe_inicio').selectedIndex].text
                parent.$('fe_fin_hidden').value = parent.$('fe_fin').value + " " + $('cmb_fe_fin').options[$('cmb_fe_fin').selectedIndex].text

                parent.comparar_fincio_fseleccion('_vencimiento')
                parent.comparar_fincio_fseleccion('_fin')

                var encontro = false
                if (parent.$('fe_fin_hidden').value != null)
                    encontro = parent.cargar_cmb_relativo('_fin', parent.$('fe_inicio_hidden').value, parent.$('fe_fin_hidden').value)

                if (!encontro)
                    parent.$('ch_relativo_fin').checked = false
                else
                    parent.$('ch_relativo_fin').checked = true

                parent.check_relativo_fin('_fin')

            }

            parent.win.close()

        }

        function onchange_intervalo(e) {
            if (Event.element(e).value == '')
                Event.element(e).value = 1

            valor = parseInt(Event.element(e).value, 10)

            if (valor == 0)
                Event.element(e).value = 1
            else
                Event.element(e).value = valor

        }

        function onchange_de0_a31(e) {
            valor = Event.element(e).value

            if (valor == '')
                return

            if (parseInt(valor, 10) < 1 || parseInt(valor, 10) > 31) {
                Event.element(e).value = ''
                Event.element(e).focus()
            }
        }

        function onchange_verificar_si_es_dia(obj) {
            var fecha = null
            dia = $('anio_dia').value
            mes = parseInt($('anio_mes_1').options[$('anio_mes_1').selectedIndex].value, 10) - 1
            anio = new Date().getFullYear()

            try {
                fecha = new Date(anio, mes, dia)

                if (fecha.getMonth() != parseInt(mes) || fecha.getDate() != parseInt(dia))
                    fecha = null
            }
            catch (a) {
                fecha = null
            }

            if (fecha == null) {
                $('anio_dia').value = ''
                $('anio_dia').focus()
                alert('El día correspondiende al mes seleccionado')
            }
        }

        /********************  herramientas ***********************/
        function obtener_posicion_dia(fecha) {
            ult_dia = obtener_ultimo_dia_del_mes(fecha)
            num_ult_dia = obtener_numero_dia_semanal(ult_dia)
            num_dia = obtener_numero_dia_semanal(fecha)

        }

        function obtener_ultimo_dia_del_mes(fecha) {
            fecha.setTime(fecha.getTime() + ((32 - fecha.getDate()) * 86400000))
            fecha.setTime(fecha.getTime() - (fecha.getDate() * 86400000))
            return fecha
        }

        function obtener_numero_dia_semanal(fecha) {
            return fecha.getDay()
        }

        function obtener_numero_semana(fecha) {
            month = fecha.getMonth()
            date = fecha.getDate()

            f1 = new Date(fecha.getFullYear(), 0, 1, 0, 0)
            dayf1 = f1.getDay()
            if (dayf1 == 0)
                dayf1 = 7

            f2 = new Date(fecha.getFullYear(), month, date, 0, 0)
            dayf2 = f2.getDay()
            if (dayf2 == 0)
                dayf2 = 7

            if (month == 0 && date == 1 && dayf2 > 4 || month == 0 && date == 2 && dayf2 > 5 || month == 0 && date == 3 && dayf2 == 7) {
                f1 = new Date(fecha.getFullYear() - 1, 0, 1, 0, 0);
                f2 = new Date(fecha.getFullYear() - 1, 11, 31, 0, 0);
                dayf1 = f1.getDay();
                if (dayf1 == 0)
                    day = 7
            }
            if (month == 11 && date == 31 && dayf2 < 4 || month == 11 && date == 30 && dayf2 < 3 || month == 11 && date == 29 && dayf2 == 1)
                return 1

            if (dayf1 < 5)
                FW = parseInt(((Math.round(((f2 - f1) / 1000 / 60 / 60 / 24)) + (dayf1 - 1)) / 7) + 1);
            else
                FW = parseInt(((Math.round(((f2 - f1) / 1000 / 60 / 60 / 24)) + (dayf1 - 1)) / 7));
            return FW
        }


    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <input type="hidden" id="nro_period" value="" />

    <form action="" id="FrmPer" style="width: 100%; height: 100%; overflow: hidden">
        <table class="tb1" style="width: 100%; height: 100%;">
            <tr>
                <td>
                    <table class="tb1">
                        <tr class = "tbLabel">
                            <td class="Tit1" colspan="10">Hora de la tarea</td>
                        </tr>
                        <tr>
                            <td style="width: 5px">&nbsp;</td>
                            <td style="width: 34%">
                                <input type="text" id="fe_inicio" readonly="readonly" style="text-align: left; vertical-align: top; width: 58%; background-color: #E9F0F4; border-width: 0px" />
                                &nbsp;
                                <select id="cmb_fe_inicio" style="width: 35%">
                                    <option value="1">08:00</option>
                                    <option value="2">08:30</option>
                                    <option value="3">09:00</option>
                                    <option value="4">09:30</option>
                                    <option value="5">10:00</option>
                                    <option value="6">10:30</option>
                                    <option value="7">11:00</option>
                                    <option value="8">11:30</option>
                                    <option value="9">12:00</option>
                                    <option value="10">12:30</option>
                                    <option value="11">13:00</option>
                                    <option value="12">13:30</option>
                                    <option value="13">14:00</option>
                                    <option value="14">14:30</option>
                                    <option value="15">15:00</option>
                                    <option value="16">15:30</option>
                                    <option value="17">16:00</option>
                                    <option value="18">16:30</option>
                                    <option value="19">17:00</option>
                                    <option value="20">17:30</option>
                                    <option value="21">18:00</option>
                                    <option value="22">18:30</option>
                                    <option value="23">19:00</option>
                                    <option value="24">19:30</option>
                                    <option value="25">20:00</option>
                                    <option value="26">20:30</option>
                                </select>
                            </td>
                            <td style="width: 5px">&nbsp;</td>
                            <td style="width: 34%">
                                <input type="text" id="fe_fin" readonly="readonly" style="text-align: left; vertical-align: top; width: 58%; background-color: #E9F0F4; border-width: 0px" />
                                &nbsp;
                                <select id="cmb_fe_fin" style="width: 35%">
                                    <option value="1">08:00</option>
                                    <option value="2">08:30</option>
                                    <option value="3">09:00</option>
                                    <option value="4">09:30</option>
                                    <option value="5">10:00</option>
                                    <option value="6">10:30</option>
                                    <option value="7">11:00</option>
                                    <option value="8">11:30</option>
                                    <option value="9">12:00</option>
                                    <option value="10">12:30</option>
                                    <option value="11">13:00</option>
                                    <option value="12">13:30</option>
                                    <option value="13">14:00</option>
                                    <option value="14">14:30</option>
                                    <option value="15">15:00</option>
                                    <option value="16">15:30</option>
                                    <option value="17">16:00</option>
                                    <option value="18">16:30</option>
                                    <option value="19">17:00</option>
                                    <option value="20">17:30</option>
                                    <option value="21">18:00</option>
                                    <option value="22">18:30</option>
                                    <option value="23">19:00</option>
                                    <option value="24">19:30</option>
                                    <option value="25">20:00</option>
                                    <option value="26">20:30</option>
                                </select>
                            </td>
                            <td style="width: 5px">&nbsp;</td>
                            <td style="width: 3%">Duración:</td>
                            <td>
                                <input type="text" id="duracion" readonly="readonly" style="width: 100%; background-color: #E9F0F4; border-width: 0px; text-align: left; font-weight: bold" />
                                <!--<select id="cmb_duracion" style="width:100%"><option value="M~5">5 minutos</option><option value="M~10">10 minutos</option><option value="M~15">15 minutos</option><option value="M~20">20 minutos</option><option value="M~30">30 minutos</option><option value="M~45">45 minutos</option><option value="M~50">50 minutos</option><option value="M~60">1 horas</option><option value="M~120">2 horas</option><option value="D~1">1 día</option><option value="D~2">2 días</option><option value="MES~1">1 mes</option></select>-->
                            </td>
                            <td style="width: 5px">&nbsp;</td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td style="width: 100%; vertical-align: middle">
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td class="Tit1" colspan="2">Frecuencia</td>
                        </tr>
                        <tr>
                            <td style="width: 20%">
                                <table class="tb1" style="border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: 2px solid #BDD2EC !Important">
                                    <tr>
                                        <td>
                                            <input type="radio" name="RadioF" id="diaria" value="1" onclick="return visualizar_div('divRepetirDiario')" />
                                            <label for="diaria">Diaria</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input type="radio" name="RadioF" id="semanal" value="2" onclick="return visualizar_div('divRepetirSemanal')" />
                                            <label for="semanal">Semanal</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input type="radio" name="RadioF" id="mensual" value="3" onclick="return visualizar_div('divRepetirMensual')" />
                                            <label for="mensual">Mensual</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <input type="radio" name="RadioF" id="anual" value="4" onclick="return visualizar_div('divRepetirAnual')" />
                                            <label for="anual">Anual</label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="vertical-align: middle">
                                <div id="divRepetirDiario" style="width: 100%; display: none">
                                    <table class="tb1">
                                        <tr>
                                            <td style="width: 100%">Cada&nbsp;<input type="text" id="dia_intervalo" value="1" style="width: 9%; text-align: center;" onkeypress="return valDigito(event)" onchange="return onchange_intervalo(event)" maxlength="3" />&nbsp;días</td>
                                        </tr>
                                    </table>
                                </div>
                                <div id="divRepetirSemanal" style="width: 100%; display: none">
                                    <table class="tb1">
                                        <tr>
                                            <td colspan="4">Repetir cada <input type="text" id="sem_intervalo" style="width: 7%;text-align: center;" value="1" onkeypress="return valDigito(event)" onchange="return onchange_intervalo(event)" maxlength="2" /> semanas el:</td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td style="width: 20%; text-align: left">
                                                <input type="checkbox" name="ck_2" id="ck_2" />Lunes</td>
                                            <td style="width: 20%; text-align: left">
                                                <input type="checkbox" name="ck_3" id="ck_3" />Martes</td>
                                            <td style="width: 20%; text-align: left">
                                                <input type="checkbox" name="ck_4" id="ck_4" />Miércoles</td>
                                            <td style="width: 20%; text-align: left">
                                                <input type="checkbox" name="ck_5" id="ck_5" />Jueves</td>
                                        </tr>
                                        <tr>
                                            <td style="width: 20%; text-align: left">
                                                <input type="checkbox" name="ck_6" id="ck_6" />Viernes</td>
                                            <td style="width: 20%; text-align: left">
                                                <input type="checkbox" name="ck_7" id="ck_7" />Sabado</td>
                                            <td style="width: 20%; text-align: left" colspan="2">
                                                <input type="checkbox" name="ck_1" id="ck_1" />Domingo</td>
                                        </tr>
                                    </table>
                                </div>
                                <div id="divRepetirMensual" style="width: 100%; display: none">
                                    <table class="tb1">
                                        <tr>
                                            <td style="width: 100%">
                                                <input type="radio" name="RadioMensual" value="1" />&nbsp;El día&nbsp;<input type="text" id="men_dia" style="width: 10%;text-align: center;" onkeypress="return valDigito(event)" onchange="return onchange_de0_a31(event)" maxlength="2" />&nbsp;de cada&nbsp;<input type="text" id="men_intervalo_1" style="width: 10%;text-align: center;" value="1" maxlength="2" onkeypress="return valDigito(event)" onchange="return onchange_intervalo(event)" />&nbsp;meses
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="width: 100%">
                                                <input type="radio" name="RadioMensual" value="2" />&nbsp;El último día del mes&nbsp;de cada&nbsp;<input type="text" id="men_intervalo_2" style="width: 10%;text-align: center;" value="1" maxlength="2" onkeypress="return valDigito(event)" onchange="return onchange_intervalo(event)" />&nbsp;meses
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="width: 100%">
                                                <input type="radio" name="RadioMensual" value="3" />&nbsp;El&nbsp;
                                                <select id="men_dia_pos" style="width: 20%">
                                                    <option value="1">Primer</option>
                                                    <option value="2">Segundo</option>
                                                    <option value="3">Tercer</option>
                                                    <option value="4">Cuarto</option>
                                                    <option value="99">Ultimo</option>
                                                </select>
                                                <select id="men_dia_sem" style="width: 40%">
                                                    <option value="1">Lunes</option>
                                                    <option value="2">Martes</option>
                                                    <option value="3">Miércoles</option>
                                                    <option value="4">Jueves</option>
                                                    <option value="5">Viernes</option>
                                                    <option value="6">Sabado</option>
                                                    <option value="0">Domingo</option>
                                                </select>
                                                &nbsp;de cada&nbsp;<input type="text" id="men_intervalo_3" style="width: 10%;text-align: center;" onkeypress="return valDigito(event)" onchange="return onchange_intervalo(event)" maxlength="2" value="1" />&nbsp;meses
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div id="divRepetirAnual" style="width: 100%; display: none">
                                    <table class="tb1">
                                        <tr>
                                            <td style="width: 100%">
                                                <input type="radio" name="RadioAnual" value="1" />&nbsp;Cada&nbsp;<input type="text" id="anio_dia" style="width: 10%;text-align:center" onkeypress="return valDigito(event)" onchange="return onchange_verificar_si_es_dia(event) || onchange_de0_a31(event)" maxlength="2" />&nbsp;de&nbsp; 
                                                <select id="anio_mes_1" style="width: 20%" onchange="return onchange_verificar_si_es_dia(event) || onchange_de0_a31(event)">
                                                    <option value="1">Enero</option>
                                                    <option value="2">Febrero</option>
                                                    <option value="3">Marzo</option>
                                                    <option value="4">Abril</option>
                                                    <option value="5">Mayo</option>
                                                    <option value="6">Junio</option>
                                                    <option value="7">Julio</option>
                                                    <option value="8">Agosto</option>
                                                    <option value="9">Septiembre</option>
                                                    <option value="10">Octubre</option>
                                                    <option value="11">Noviembre</option>
                                                    <option value="12">Diciembre</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="width: 100%">
                                                <input type="radio" name="RadioAnual" value="2" />
                                                &nbsp;El&nbsp;
                                                <select id="anio_dia_pos" style="width: 20%">
                                                    <option value="1">Primer</option>
                                                    <option value="2">Segundo</option>
                                                    <option value="3">Tercer</option>
                                                    <option value="4">Cuarto</option>
                                                    <option value="99">Ultimo</option>
                                                </select>
                                                <select id="anio_dia_sem" style="width: 40%">
                                                    <option value="1">Lunes</option>
                                                    <option value="2">Martes</option>
                                                    <option value="3">Miércoles</option>
                                                    <option value="4">Jueves</option>
                                                    <option value="5">Viernes</option>
                                                    <option value="6">Sabado</option>
                                                    <option value="0">Domingo</option>
                                                </select>
                                                &nbsp;de&nbsp;
                                                <select id="anio_mes_2" style="width: 20%">
                                                    <option value="1">Enero</option>
                                                    <option value="2">Febrero</option>
                                                    <option value="3">Marzo</option>
                                                    <option value="4">Abril</option>
                                                    <option value="5">Mayo</option>
                                                    <option value="6">Junio</option>
                                                    <option value="7">Julio</option>
                                                    <option value="8">Agosto</option>
                                                    <option value="9">Septiembre</option>
                                                    <option value="10">Octubre</option>
                                                    <option value="11">Noviembre</option>
                                                    <option value="12">Diciembre</option>
                                                </select>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td class="Tit1" colspan="2">Intervalo de repetición</td>
                        </tr>
                        <tr>
                            <td style="width: 8%; vertical-align: middle">&nbsp;
                            </td>
                            <td style="vertical-align: middle">
                                <table class="tb1" style="vertical-align: middle">
                                    <tr>
                                        <td rowspan="4" style="width: 5%">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="width: 30%">
                                            <input type="radio" name="RadioR" value="1" />Sin fecha de finalización</td>
                                    </tr>
                                    <tr>
                                        <td style="width: 30%">
                                            <input type="radio" name="RadioR" value="2" />Finalizar después de:&nbsp;<input type="text" id="final_repet" style="width: 10%;text-align: center;" value="1" onkeypress="return valDigito(event)" onchange="return onchange_intervalo(event)" maxlength="3" />&nbsp;repeticiones</td>
                                    </tr>
                                    <tr>
                                        <td style="width: 30%">
                                            <input type="radio" name="RadioR" value="3" />Finalizar el:&nbsp; 
                          <input type="text" name="final_fecha" id="final_fecha" style="width: 20%; text-align: right" onchange="return valFecha(event)" onkeypress="return valDigito(event,'/')" />
                                            <img alt="" title="Seleccionar fecha finalización" id="img_final_fecha" src="/FW/image/icons/periodo.png" style="vertical-align: middle; cursor: hand; cursor: pointer" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <table class="tb1">
                        <tr>
                            <td style="width: 6.25%">&nbsp;</td>
                            <td style="width: 25%">
                                <div id="divAceptar" style="width: 100%"></div>
                            </td>
                            <td style="width: 6.25%">&nbsp;</td>
                            <td style="width: 25%">
                                <div id="divCancelar" style="width: 100%"></div>
                            </td>
                            <td style="width: 6.25%">&nbsp;</td>
                            <td style="width: 25%">
                                <div id="divQuitarRepeticion" style="width: 100%"></div>
                            </td>
                            <td style="width: 6.25%">&nbsp;</td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
