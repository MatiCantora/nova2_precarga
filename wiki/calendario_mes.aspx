<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim fecha_get = nvFW.nvUtiles.obtenerValor("fecha_get", "10/26/2010")
    Dim privacidad = nvFW.nvUtiles.obtenerValor("privacidad", "")
    Dim nro_period = nvFW.nvUtiles.obtenerValor("nro_period", "")
    Dim tiene_autorun = nvFW.nvUtiles.obtenerValor("tiene_autorun", "")
    
    Me.contents("filtroMesDibujar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.operador_get_tareas' CommantTimeOut='1500'><parametros><fe_desde DataType='datetime'>%fecha_desde%</fe_desde><fe_hasta DataType='datetime'>%fecha_hasta%</fe_hasta><strWhere>%strWhere%</strWhere><strOrder>%strOrder%</strOrder></parametros></procedure></criterio>")
%>
<html>
<head>
    <title>Calendario Mes</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    
    <%= Me.getHeadInit() %>

    <style type="text/css">
        .tdTitulo, .tdTituloHoy, .tdDia, .tdTarea, .tbTarea {
	        font: 12px Arial, Helvetica, sans-serif;
        }
        .tr_cel TD { 
	        border: solid 1px #749BC4 !Important; 
	        background-color: #F0FFFF !Important; 
        }
        .tdTitulo {
	        vertical-align: middle;
	        background-color: #D4D0C8 !Important;
	        font-weight: bolder;
	        text-align: center;
	        border: #808080 1px solid !Important;
        }
        .tdTituloHoy {
	        color: red !Important; 
	        background-color: white !Important; 
	        font-weight: bold; 
	        text-align: center;
	        border: red 1px solid !Important;
        }
        .tdDia, .tdTarea, .tbTarea {
	        width: 100%; 
	        height: 20px;
	        vertical-align: middle;
        }
        .tdDia {
	        border: solid 1px #FFEFC7;
        }
        .tdTarea {
	        border: solid 1px #FFEFC7;
	        background-color: #FFFFFF !Important;
        }
        .tbTarea {
	        background-color: #FFFFD5 !Important;
        }
    </style>

    <script type="text/javascript">
        var param_privacidad = '<% = privacidad  %>',
            param_nro_period = '<% = nro_period  %>',
            param_tiene_autorun = '<% = tiene_autorun %>',
            dayArray = [
                'Domingo',  // 0
                'Lunes', 
                'Martes', 
                'Miércoles', 
                'Jueves', 
                'Viernes', 
                'Sábado'    // 6
            ],
            meses = [
                "Enero",    // 0
                "Febrero",
                "Marzo",
                "Abril",
                "Mayo",
                "Junio",
                "Julio",
                "Agosto",
                "Septiembre",
                "Octubre",
                "Noviembre",
                "Diciembre" // 11
            ]

        function obtener_dia_string(fecha) {
            for (var i = 0, max = dayArray.length; i < max; i++) {
                if (i == fecha.getDay())
                    return dayArray[i]
            }

            return ''
        }

        function obtener_primer_del_mes(fecha)
        {
            fecha.setTime(fecha.getTime() - ((fecha.getDate() - 1 ) * 86400000) )
            return FechaToSTR(fecha, 2)
        }
   
        function obtener_primer_dia_mes_siguiente(fecha)
        {
            fecha.setTime(fecha.getTime() + ((32 - fecha.getDate()) * 86400000) )
            fecha.setTime(fecha.getTime() - (fecha.getDate() * 86400000) ) 
            
            var ultimo_dia_mes = FechaToSTR(fecha, 2),
                valor = parseFecha(ultimo_dia_mes).getDate() + 1
            
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000) )
            
            return FechaToSTR(fecha, 2)
        }

        function aumentar_disminuir_fecha(fecha, ad)
        {
            var valor = fecha.getDate() + ad
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000) ) // 1 dia en milisegundos = 86400000
            
            return  FechaToSTR(fecha, 2)
        }
   
        function TiempoToSTR(objFecha) // hh:mm
        {
            var horas = parseInt(objFecha.getHours(), 10),
                minutos = parseInt(objFecha.getMinutes(), 10) 
      
            horas = horas < 10 ? '0' + horas : horas
            minutos = minutos < 10 ? '0' + minutos : minutos

            return horas + ':' + minutos
        }
    
        function comparar_fechas(fecha1, fecha2)
        {
            fecha1 = fecha1.split('/')
            fecha2 = fecha2.split('/')
     
            var anio1 = parseInt(fecha1[2]),
                anio2 = parseInt(fecha2[2]),
     
                mes1 = parseInt(fecha1[1]),
                mes2 = parseInt(fecha2[1]),
     
                dia1 = parseInt(fecha1[0]),
                dia2 = parseInt(fecha2[0])
     
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
    
        function dia_onresize(day) {
            try {
                var td_h = $('tb_mes').getHeight() / 7,
                    tit_h = $('tit_dia_' + day).getHeight()
                
                $('nro_dia_' + day).setStyle({ height: td_h - tit_h })
            }
            catch(e) {} 
        }

        function mes_dibujar() {
            var fecha_desde = FechaToSTR(parseFecha(primer_dia_mes), 2),
                fecha_hasta = FechaToSTR((parseFecha(primer_dia_mes_sig)), 2),
                strWhere = ''

            if (param_privacidad != '')
                strWhere += 'privacidad in (' + param_privacidad + ')'

            if (param_nro_period == '0')
                strWhere += strWhere == '' ? ' (nro_period = 1 or nro_period is null) ' : ' and (nro_period = 1 or nro_period is null) '

            if (param_nro_period == '1')
                strWhere += strWhere == '' ? ' nro_period > 1 ' : ' and nro_period > 1 '

            if (param_tiene_autorun == '0')
                strWhere += strWhere == '' ? ' tiene_autorun = 0 ' : ' and tiene_autorun = 0 '

            if (param_tiene_autorun == '1')
                strWhere += strWhere == '' ? ' tiene_autorun = 1 ' : ' and tiene_autorun = 1 '  
 
            var strOrder = 'fe_inicio'
 
            inicializar_div_nro_dia()

            var num_dia_mes = '',
                num_dia_mes_ant = '',
                strHTML = ''//,
                //style_tb = ''
 
            var rs = new tRS(),
                criterio = nvFW.pageContents.filtroMesDibujar,
                parametros = "<criterio><params fecha_desde='" + fecha_desde + "' fecha_hasta='" + fecha_hasta + "' strWhere='" + strWhere + "' strOrder='" + strOrder + "'/></criterio>"
            
            rs.open({
                filtroXML: criterio,
                params: parametros
            })

            while (!rs.eof()) {
                num_dia_mes = obtener_posicion_fecha(FechaToSTR(parseFecha(rs.getdata('fe_inicio'))))
    
                if (num_dia_mes_ant == '') {
                    strHTML = "<table class='tbTarea' style='width:100%' border='0' cellpadding='0' cellspacing='0'>"
                    strHTML += tarea_dibujar(rs)
                }
   
                if (num_dia_mes_ant != num_dia_mes && num_dia_mes_ant != '') {
                    strHTML += "</table>" 
                    $('nro_dia_'+ num_dia_mes_ant).insert({ top: strHTML })
          
                    strHTML = "<table class='tbTarea' style='width:100%' border='0' cellpadding='0' cellspacing='0'>"
                    strHTML += tarea_dibujar(rs)
                }
      
                if (num_dia_mes_ant == num_dia_mes)
                    strHTML += tarea_dibujar(rs)
     
                num_dia_mes_ant = num_dia_mes 
    
                rs.movenext()
            }
 
            if (num_dia_mes != '')  {
                strHTML += "</table>" 
                dia_onresize(num_dia_mes) 
                $('nro_dia_' + num_dia_mes).insert({ top: strHTML })
            }
        }

        function obtener_posicion_fecha(fecha) {
            var i = 1,
                res = 0

            while (i < 43) {
                if ($('td_tit_dia_' + i) != null) { 
                    res = comparar_fechas($('td_tit_dia_' + i).value, fecha)
                    if (res == 0)
                        return i
                }
                i++
            }
  
            return 0
        }

        function inicializar_div_nro_dia() {
            var i = 1

            while (i < 43) {
                $('nro_dia_' + i).innerHTML = ''
                dia_onresize(i)
                i++
            }
        }

        function seleccionar(indice) {
            $('tr_ver' + indice).addClassName('tr_cel')
        }
 
        function no_seleccionar(indice) {
            $('tr_ver' + indice).removeClassName('tr_cel')
        }

        function tarea_dibujar(rs) {
            var strHTML = ""
            strHTML += "<tr id='tr_ver" + rs.position + "' onmousemove='seleccionar(" + rs.position + ")' onmouseout='no_seleccionar(" + rs.position + ")'>"
        
            var font = ''
        
            if (rs.getdata('nro_tarea_estado') == 1 || rs.getdata('nro_tarea_estado') == 2)
                font= "color:blue !Important"
        
            var titleHTML =  "+ Tarea: " +  rs.getdata('nro_tarea') + " - " + rs.getdata('asunto').substring(0,15)  + " \n" 
        
            if (rs.getdata('nro_tarea_estado') == 3)
            {
                font = "text-decoration:line-through !Important;font-weight:bold !Important;color:black !Important"
                titleHTML += "+ Estado: Completa \n"
            }         

            if (rs.getdata('tarea_vencida') == 1)
            {
                font = "color:red !Important" 
                titleHTML += "+ Vencida: Si \n"
            }
     
            titleHTML += "+ Prioridad:"  // prioridad
            
            switch (parseInt(rs.getdata('nro_tarea_pri')))
            {
                case 1:
                    titleHTML += " Alta \n"
                    break        
                case 2:
                    titleHTML += " Normal \n"
                    break        
                case 3:
                    titleHTML += " Baja \n"
                    break        
            }

            var eti_img_perio = ''
            
            if (rs.getdata('nro_rep') > 1)
            {
                titleHTML += "+ Periodica: Si \n" 
                eti_img_perio = "<img src='/wiki/image/icons/periodicidad.png' style='vertical-align:middle !Important' />"
            }   
        
            if ((rs.getdata('nro_rep') == 1) && rs.getdata('nro_tipo_period') != null) 
            {
                titleHTML += "+ Periodicidad: Origen \n" 
                eti_img_perio = "<img src='/wiki/image/icons/periodicidad_origen.png' style='vertical-align:middle !Important' />"
            }

            var eti_img_autorun = ''
            
            if (rs.getdata('tiene_autorun') == 'True') 
            {
                titleHTML += "+ Ejecución Automática: Si \n"
                eti_img_autorun = "<img src='/wiki/image/icons/auto_run.png' style='vertical-align:middle !Important' />"
            } 
        
            var eti_img_noti = ''
            
            if (rs.getdata('id_noti') > 0)
            {
                titleHTML += "+ Noti: " + FechaToSTR(parseFecha(rs.getdata('fe_dif_tarea_noti'))) + " " + TiempoToSTR(parseFecha(rs.getdata('fe_dif_tarea_noti'))) + " \n" 
                eti_img_noti = "&nbsp;<img src='/wiki/image/icons/aviso.png' style='vertical-align:middle !Important'/>"
            }
         
            var nro_rep = (rs.getdata('nro_rep') == 1 && rs.getdata('nro_tipo_period') == null) ?  0 : rs.getdata('nro_rep')  // en el caso que no tenga periodicidad
        
            strHTML += "<td class='tdTarea' title='" + titleHTML + "' style='cursor: default;" + font + "' ondblclick='return tarea_ondblclick(" + rs.getdata('nro_tarea') + ", \"" + rs.getdata('fe_inicio') + "\"," + nro_rep + "," + rs.position + ")'>"

            strHTML += eti_img_perio
            strHTML += eti_img_autorun
            strHTML += "&nbsp;" + TiempoToSTR(parseFecha(rs.getdata('fe_inicio')))
            strHTML +=  ' ' + rs.getdata('asunto').substring(0,11) 
            strHTML += eti_img_noti
            strHTML += "</td>"
            strHTML += "</tr>"

            return strHTML
        }

        function encabezado_dia_dibujar(primer_dia) {
            var fecha = primer_dia,
                i = 1,
                titulo_dia = ''
 
            while (i < 43) {
                $('tit_dia_' + i).innerHTML = '' 
  
                titulo_dia = parseFecha(fecha).getDate()
                hoy = FechaToSTR(new Date(), 2)
  
                if ((parseFecha(hoy) - parseFecha(fecha)) == 0) // si es hoy
                    Td_class ='tdTituloHoy'
                else
                    Td_class ='tdTitulo'

                if (parseFecha(fecha).getMonth() == parseFecha(primer_dia_mes).getMonth()) // se se encuentra dentro del mes
                    $('tit_dia_' + i).insert({top: "<table style='width:100%'><tr><td class='" + Td_class + "' style='width:100%' ondblclick='return tarea_abm(0,\"" + FechaToSTR(parseFecha(fecha), 2) + " 00:00\")'>" + titulo_dia + "<input type='hidden' id='td_tit_dia_" + i + "' value='" + titulo_dia + "'/></td></tr></table>"})
  
                fecha = aumentar_disminuir_fecha(parseFecha(primer_dia), i)
                i++
            }
        }

        var id

        function tarea_ondblclick(nro_tarea, fe_inicio, nro_rep, id_click) {
            id = id_click
            tarea_abm(nro_tarea, fe_inicio, nro_rep)
        }
  
        function tarea_abm(nro_tarea, fe_inicio, nro_rep) {
            fe_inicio = fe_inicio == undefined && nro_tarea != 0 ? '' : fe_inicio
  
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
            mes_dibujar()
        }  

        var fecha_pos_primer_dia//,
            //fecha_pos_ultimo_dia
        
        function obtener_fecha_pos_primer_dia(fecha) {
            var primer_dia = fecha,
                num_dia_sem = parseFecha(fecha).getDay()
            
            num_dia_sem = num_dia_sem == 0 ? 7 : num_dia_sem 
            
            if (num_dia_sem > 1) // si no es lunes
                primer_dia = aumentar_disminuir_fecha(parseFecha(fecha), ((num_dia_sem - 1) * -1))
 
            return primer_dia 
        }

        var fecha_get = '<%= fecha_get %>',
            primer_dia_mes,
            primer_dia_mes_sig

        function mes_anterior()
        {
            if (parseFecha(fecha_get).getMonth() == 0) 
                fecha_get = FechaToSTR(new Date(parseFecha(fecha_get).getFullYear() - 1, 11, 1), 2) 
            else
                fecha_get = FechaToSTR(new Date(parseFecha(fecha_get).getFullYear(), parseFecha(fecha_get).getMonth() - 1 , 1), 2) 

            window_onload()
        }

        function mes_siguiente()
        {
            if (parseFecha(fecha_get).getMonth() == 11) 
                fecha_get = FechaToSTR(new Date(parseFecha(fecha_get).getFullYear() + 1, 0, 1), 2)
            else
                fecha_get = FechaToSTR(new Date(parseFecha(fecha_get).getFullYear(), parseFecha(fecha_get).getMonth()+ 1 , 1), 2)

            window_onload()
        }
        
        function window_onload() {
            mes_onresize()
 
            var fecha_origen = parseFecha(fecha_get)
 
            primer_dia_mes = obtener_primer_del_mes(parseFecha(fecha_get))
            primer_dia_mes_sig = obtener_primer_dia_mes_siguiente(parseFecha(primer_dia_mes))

            fecha_pos_primer_dia = obtener_fecha_pos_primer_dia(primer_dia_mes) // obtiene la fecha del primer = nro_dia_1

            // titulo
            $('td_titulo').innerHTML = ''
            var titulo = "<table style='width:100%'><tr><td style='width: 25%'>&nbsp;</td><td onclick='return mes_anterior()' style='text-align:right;cursor:hand;cursor:pointer'><img title='Anterior' src='/wiki/image/icons/anterior.png' style='vertical-align:middle !Important'/></td><td style='text-align:center;font: 13px Arial, Helvetica, sans-serif' nowrap='nowrap'><b>" + meses[fecha_origen.getMonth()] + " de " + fecha_origen.getFullYear() + "</b></td><td onclick='return mes_siguiente()' style='text-align:left;cursor:hand;cursor:pointer'><img title='Siguiente' src='/wiki/image/icons/siguiente.png' style='vertical-align:middle !Important'/></td><td style='width: 25%'>&nbsp;</td></tr></table>"
            $('td_titulo').insert({ top: titulo })

            encabezado_dia_dibujar(fecha_pos_primer_dia)

            mes_dibujar()
        }

        function mes_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    body_h = $$('body')[0].getHeight(),
                    tb_titulo_h = $('tb_titulo').getHeight()

                $('tb_mes').setStyle({ height: body_h - tb_titulo_h - dif })
            }
            catch(e) {} 
        }
    </script>
</head>
<body onload="window_onload()" onresize="mes_onresize()" style="width:100%;height:100%;overflow:hidden">
    <table id="tb_titulo"  class="tb1" style="height:20px !Important" border='0' cellpadding='0' cellspacing='0'>
        <tr> 
            <td style="width:100%;text-align:center" colspan="7" id="td_titulo">&nbsp;</td>
        </tr>
        <tr> 
            <td class="Tit1" style="width:14%;vertical-align:top;text-align:center">Lun</td>
            <td class="Tit1" style="width:14%;vertical-align:top;text-align:center">Mar</td>
            <td class="Tit1" style="width:14%;vertical-align:top;text-align:center">Mie</td>
            <td class="Tit1" style="width:14%;vertical-align:top;text-align:center">Jue</td>
            <td class="Tit1" style="width:14%;vertical-align:top;text-align:center">Vie</td>
            <td class="Tit1" style="width:14%;vertical-align:top;text-align:center">Sab</td>
            <td class="Tit1" style="width:14%;vertical-align:top;text-align:center">Dom</td>
        </tr>
    </table>
    <table id="tb_mes" class="tbTarea" style="width:100%;height:100%">
        <tr> 
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_1">
                <div id="tit_dia_1" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_1" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_2">
                <div id="tit_dia_2" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_2" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_3">
                <div id="tit_dia_3" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_3" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_4">
                <div id="tit_dia_4" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_4" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_5">
                <div id="tit_dia_5" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_5" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_6">
                <div id="tit_dia_6" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_6" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_7">
                <div id="tit_dia_7" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_7" style="width:100%;overflow:auto"></div>
            </td>
        </tr>
        <tr> 
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_8">
                <div id="tit_dia_8" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_8" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_9">
                <div id="tit_dia_9" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_9" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_10">
                <div id="tit_dia_10" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_10" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_11">
                <div id="tit_dia_11" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_11" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_12">
                <div id="tit_dia_12" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_12" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_13">
                <div id="tit_dia_13" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_13" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_14">
                <div id="tit_dia_14" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_14" style="width:100%;overflow:auto"></div>
            </td>
        </tr>
        <tr> 
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_15">
                <div id="tit_dia_15" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_15" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_16">
                <div id="tit_dia_16" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_16" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_17">
                <div id="tit_dia_17" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_17" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_18">
                <div id="tit_dia_18" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_18" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_19">
                <div id="tit_dia_19" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_19" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width:14%;height:16%;vertical-align:top" id="td_20">
                <div id="tit_dia_20" style="width:100%;overflow:hidden"></div>
                <div id="nro_dia_20" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_21">
                <div id="tit_dia_21" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_21" style="width: 100%; overflow: auto"></div>
            </td>
        </tr>
        <tr> 
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_22">
                <div id="tit_dia_22" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_22" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_23">
                <div id="tit_dia_23" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_23" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_24">
                <div id="tit_dia_24" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_24" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_25">
                <div id="tit_dia_25" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_25" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_26">
                <div id="tit_dia_26" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_26" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_27">
                <div id="tit_dia_27" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_27" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_28">
                <div id="tit_dia_28" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_28" style="width: 100%; overflow: auto"></div>
            </td>
        </tr>
        <tr> 
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_29">
                <div id="tit_dia_29" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_29" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_30">
                <div id="tit_dia_30" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_30" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_31">
                <div id="tit_dia_31" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_31" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_32">
                <div id="tit_dia_32" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_32" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_33">
                <div id="tit_dia_33" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_33" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_34">
                <div id="tit_dia_34" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_34" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_35">
                <div id="tit_dia_35" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_35" style="width: 100%; overflow: auto"></div>
            </td>
        </tr>
        <tr> 
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_36">
                <div id="tit_dia_36" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_36" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_37">
                <div id="tit_dia_37" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_37" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_38">
                <div id="tit_dia_38" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_38" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_39">
                <div id="tit_dia_39" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_39" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_40">
                <div id="tit_dia_40" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_40" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_41">
                <div id="tit_dia_41" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_41" style="width: 100%; overflow: auto"></div>
            </td>
            <td class="tdDia" style="width: 14%; height: 16%; vertical-align: top" id="td_42">
                <div id="tit_dia_42" style="width: 100%; overflow: hidden"></div>
                <div id="nro_dia_42" style="width: 100%; overflow: auto"></div>
            </td>
        </tr>
        <tr>
        </tr>
    </table>
</body>
</html>
