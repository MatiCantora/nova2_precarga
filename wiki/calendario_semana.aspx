<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim fecha_get = nvFW.nvUtiles.obtenerValor("fecha_get", "10/26/2010")
    Dim privacidad = nvFW.nvUtiles.obtenerValor("privacidad", "")
    Dim nro_period = nvFW.nvUtiles.obtenerValor("nro_period", "")
    Dim tiene_autorun = nvFW.nvUtiles.obtenerValor("tiene_autorun", "")
    
    Me.contents("filtroSemanaDibujar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.operador_get_tareas' CommantTimeOut='1500'><parametros><fe_desde DataType='datetime'>%fe_desde%</fe_desde><fe_hasta DataType='datetime'>%fe_hasta%</fe_hasta><strWhere>%strWhere%</strWhere><strOrder>%strOrder%</strOrder></parametros></procedure></criterio>")
%>
<html>
<head>
    <title>Calendario Semana</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <style type="text/css">
        .tr_cel TD { 
            border: solid 1px #749BC4 !Important; 
            background-color: #F0FFFF !Important; 
        }
        .tdTitulo, .tdTituloHoy, .tdDia, .tdTarea, .tbTarea {
            font: 12px Arial, Helvetica, sans-serif;
        }
        .tdTitulo {
            vertical-align: middle;
            background-color: #D4D0C8 !Important;
            font-weight:bolder;
            border: #808080 1px solid !Important;
            text-align: center;
        }
        .tdTituloHoy {
            color:red !Important; 
            font-weight:bold; 
            background-color:white !Important; 
            border:red 1px solid !Important;
            text-align: center;
        }
        .tdDia, .tdTarea, .tbTarea {
            width:100%;
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

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        var dayArray = [
            'Domingo', 
            'Lunes', 
            'Martes', 
            'Miércoles', 
            'Jueves', 
            'Viernes', 
            'Sábado'
        ];

        function obtener_dia_string(fecha) {            
            for (var i = 0, max = dayArray.length; i < max; i++) {
                if (i == fecha.getDay())
                    return dayArray[i]
            }

            return ''
        }

        function obtener_primer_dia_semana(fecha) {
            var dia_semana = fecha.getDay()
            dia_semana = dia_semana == 0 ? 7 : dia_semana   // si es domingo toma el lunes anterior

            var valor = fecha.getDate() - dia_semana 
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000) ) // 1 dia en milisegundos = 86400000
            
            return FechaToSTR(fecha, 2)
        }

        function obtener_ultimo_dia_semana(fecha)
        {
            var valor = fecha.getDate() + 7 
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000) ) // 1 dia en milisegundos = 86400000
            return FechaToSTR(fecha, 2) 
        }

        function ing_fecha(fecha, ing)
        {
            var valor = fecha.getDate() + ing
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000) ) // 1 dia en milisegundos = 86400000
            return FechaToSTR(fecha, 2)
        } 
   
        function TiempoToSTR(objFecha) {
            var horas = parseInt(objFecha.getHours(), 10),
                minutos = parseInt(objFecha.getMinutes(), 10) 
      
            horas = horas < 10 ? '0' + horas : horas
            minutos = minutos < 10 ? '0' + minutos : minutos

            return horas + ':' + minutos
        }

        var param_privacidad = '<% = privacidad  %>',
            param_nro_period = '<% = nro_period  %>',
            param_tiene_autorun = '<% = tiene_autorun %>'   
 
        function semana_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    body_h = $$('body')[0].getHeight(),
                    tb_titulo_h = $('tb_titulo').getHeight()
                
                $('tb_semana').setStyle({ height: body_h - tb_titulo_h - dif })
            }
            catch(e) {}
        }

        function dia_onresize(day) {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    td_h = $(tb_semana).getHeight() / 3,
                    tit_h = $('tit_dia_' + day).getHeight()
    
                if (day > 5)
                    td_h /= 2
       
                $('nro_dia_'+ day).setStyle({ height: td_h - tit_h - dif })
            }
            catch(e) {} 
        }

        function semana_dibujar()
        {
            var fecha_desde = FechaToSTR(parseFecha(primer_dia_sem),2),
                fecha_hasta = FechaToSTR(parseFecha(ing_fecha(parseFecha(ultimo_dia_sem),1)),2),
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
 
            limpiar_div_nro_dia()

            var num_dia_sem = '',
                num_dia_sem_ant = '',
                strHTML = ''
    
            var rs = new tRS(),
                params = "<criterio><params fe_desde='" + fecha_desde + "' fe_hasta='" + fecha_hasta + "' strWhere='" + strWhere + "' strOrder='" + strOrder + "'/></criterio>"

            rs.open({
                filtroXML: nvFW.pageContents.filtroSemanaDibujar,
                params: params
            })

            while (!rs.eof()) {
                num_dia_sem = parseFecha(rs.getdata('fe_inicio')).getDay() 
                num_dia_sem = num_dia_sem == 0 ? num_dia_sem + 7 : num_dia_sem 
    
                if (num_dia_sem_ant == '') {
                    strHTML = "<table class='tbTarea' border='0' cellpadding='0' cellspacing='0'>"
                    strHTML += tarea_dibujar(rs)
                }
   
                if (num_dia_sem_ant != num_dia_sem && num_dia_sem_ant != '')
                {
                    strHTML += "</table>" 
                    $('nro_dia_'+ num_dia_sem_ant).insert({top: strHTML})
        
                    strHTML = "<table class='tbTarea' border='0' cellpadding='0' cellspacing='0'>"
                    strHTML += tarea_dibujar(rs)
                    tabla_abierto = true
                } 
      
                if (num_dia_sem_ant == num_dia_sem)
                    strHTML += tarea_dibujar(rs)
     
                num_dia_sem_ant = num_dia_sem 
                rs.movenext()
            }
   
            if (num_dia_sem != '') 
            {
                strHTML += "</table>" 
     
                //style_tb = ''

                $('nro_dia_' + num_dia_sem).insert({top: strHTML})

                dia_onresize(num_dia_sem) 
            }  
        }

        function limpiar_div_nro_dia() {
            var i = 1

            while (i < 8) {
                $('nro_dia_'+ i).innerHTML = ''
                dia_onresize(i)
   
                i++
            }
        }

        function seleccionar(indice) {
            $('tr_ver'+indice).addClassName('tr_cel')
        }
 
        function no_seleccionar(indice) {
            $('tr_ver'+indice).removeClassName('tr_cel')
        }

        function tarea_dibujar(rs) {
            var strHTML = ""
            strHTML += "<tr id='tr_ver" + rs.position + "' onmousemove='seleccionar(" + rs.position + ")' onmouseout='no_seleccionar(" + rs.position + ")'>"
        
            var font = '',
                titleHTML =  "+ Tarea: " +  rs.getdata('nro_tarea') + " - " + rs.getdata('asunto').substring(0,15)  + " \n" 
        
            if (rs.getdata('nro_tarea_estado') == 1 || rs.getdata('nro_tarea_estado') == 2)  // pendiente
                font = "color:blue !Important"
        
            var eti_img_est = ""
            
            if (rs.getdata('nro_tarea_estado') == 3)  // completa
            {
                font = "text-decoration:line-through !Important;font-weight:bold !Important;color:black !Important"
                titleHTML += "+ Estado: Completa \n"
                eti_img_est = "<img src='/wiki/image/icons/completado.png' style='vertical-align:middle !Important'/>"
            }          
        
            if (rs.getdata('tarea_vencida') == 1) // esta vencida
            {
                font = "color:red !Important" 
                titleHTML += "+ Vencida: Si \n"  
            } 
        
            titleHTML += "+ Prioridad:"  // prioridad
        
            var eti_img_pri = ""
            
            switch (parseInt(rs.getdata('nro_tarea_pri'))) {
                case 1:
                    titleHTML += " Alta \n"
                    eti_img_pri = "<img src='/wiki/image/icons/pri_alta.png' style='vertical-align:middle !Important'/>"
                    break        
                case 2:
                    titleHTML += " Normal \n"
                    eti_img_pri = "<img src='/wiki/image/icons/pri_normal.png' style='vertical-align:middle !Important' />"
                    break        
                case 3:
                    titleHTML += " Baja \n"
                    eti_img_pri = "<img src='/wiki/image/icons/pri_baja.png' style='vertical-align:middle !Important'/>"
                    break        
            }
        
            var eti_img_perio = ''
            
            if (rs.getdata('nro_rep') > 1) {
                titleHTML += "+ Periodica: Si \n" 
                eti_img_perio = "<img src='/wiki/image/icons/periodicidad.png' style='vertical-align:middle !Important' />"
            } 
         
            if (rs.getdata('nro_rep') == 1 && rs.getdata('nro_tipo_period') != null) {
                titleHTML += "+ Periodicidad: Origen \n" 
                eti_img_perio = "<img src='/wiki/image/icons/periodicidad_origen.png' style='vertical-align:middle !Important' />"
            }

            var eti_img_autorun = ''
            
            if (rs.getdata('tiene_autorun') == 'True') {
                titleHTML += "+ Ejecución Automática: Si \n"
                eti_img_autorun = "<img src='/wiki/image/icons/auto_run.png' style='vertical-align:middle !Important' />"
            }
          
            var eti_img_noti = ''
            
            if (rs.getdata('id_noti') > 0) {
                titleHTML += "+ Noti: " + FechaToSTR(parseFecha(rs.getdata('fe_dif_tarea_noti'))) + " " + TiempoToSTR(parseFecha(rs.getdata('fe_dif_tarea_noti'))) + " \n" 
                eti_img_noti += "&nbsp;<img src='/wiki/image/icons/aviso.png' style='vertical-align:middle !Important'/>"
            }
        
            var num_dia_sem = parseFecha(rs.getdata('fe_inicio')).getDay()   
            num_dia_sem = num_dia_sem == 0 ? num_dia_sem  + 7 : num_dia_sem 
        
            var nro_rep = (rs.getdata('nro_rep') == 1 && rs.getdata('nro_tipo_period') == null) ?  0 : rs.getdata('nro_rep')  // en el caso que no tenga periodicidad

            strHTML += "<td title='" + titleHTML + "' class='tdTarea' style='cursor: default;width:100%;" + font + "' ondblclick='return tarea_ondblclick(" + rs.getdata('nro_tarea') + ", \"" + rs.getdata('fe_inicio') + "\", " + nro_rep + "," + rs.position + ")'>" 
            strHTML += "&nbsp;" + TiempoToSTR(parseFecha(rs.getdata('fe_inicio'))) + "&nbsp;"
            strHTML += eti_img_pri
            strHTML += eti_img_perio
            strHTML += eti_img_autorun
            strHTML += " " + rs.getdata('asunto').substring(0,75) 
            strHTML += eti_img_est
            strHTML += eti_img_noti
            strHTML += "</td>"
            strHTML += "</tr>"
  
            return strHTML
        }

        function encabezado_dia_dibujar(fecha) {
            var i = 1
            
            while (i < 8) {
                var style = ''//,
                    //style_tb = ''
  
                $('tit_dia_'+ i).innerHTML = '' 

                var dia = ing_fecha(parseFecha(fecha), i),
                    titulo_dia = obtener_dia_string(parseFecha(dia)) + ", " + FechaToSTR(parseFecha(dia), 1),
                    hoy = FechaToSTR(new Date(), 2),
                    Td_class = '',
                    background = ''
  
                if ((parseFecha(hoy) - parseFecha(dia)) == 0) // si es hoy
                    Td_class = 'tdTituloHoy'
                else
                    Td_class ='tdTitulo'
     
                if (i > 5) // sabado - domingo
                    background = ";background-color:#F7F5F4 !Important"

                $('tit_dia_'+ i).insert({top: "<table style='width:100%'><tr><td class='" + Td_class + "' style='width:100%" + background + "'>" + titulo_dia + "</td></tr></table>"})
                fecha = obtener_primer_dia_semana(parseFecha(dia))
                
                i++
            }
        }

        var id

        function tarea_ondblclick(nro_tarea, fe_inicio, nro_rep, id_click) {
            id = id_click
            tarea_abm(nro_tarea, fe_inicio, nro_rep)
        }
  
        function tarea_abm(nro_tarea, fe_inicio, nro_rep, num_dia) {
            fe_inicio = num_dia != undefined && nro_tarea == 0 ? FechaToSTR(parseFecha(ing_fecha(parseFecha(primer_dia_sem), num_dia)), 2) + ' 00:00' : fe_inicio
    
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
            semana_dibujar()
        }  

        function semana_anterior() {
            fecha_get = FechaToSTR(parseFecha(ing_fecha(parseFecha(fecha_get),-7)),2) 
            window_onload()
        }

        function semana_siguiente() {
            fecha_get = FechaToSTR(parseFecha(ing_fecha(parseFecha(fecha_get),7)),2) 
            window_onload()
        }

        var fecha_get = '<%= fecha_get %>',
            primer_dia_sem,
            ultimo_dia_sem

        function window_onload() {
            semana_onresize()

            var fecha_origen = parseFecha(fecha_get)
 
            primer_dia_sem = obtener_primer_dia_semana(parseFecha(fecha_get)) 
            ultimo_dia_sem = obtener_ultimo_dia_semana(parseFecha(primer_dia_sem))
 
            //titulo
            $('td_titulo').innerHTML = ''
            titulo = "<table style='width:100%'><tr><td style='width: 25%'>&nbsp;</td><td onclick='return semana_anterior()' style='text-align:right;cursor:hand;cursor:pointer'><img title='Anterior' src='/wiki/image/icons/anterior.png' style='vertical-align:middle !Important'/></td><td style='text-align:center;font: 13px Arial, Helvetica, sans-serif' nowrap='nowrap'><b>" + obtener_dia_string(parseFecha(ing_fecha(parseFecha(primer_dia_sem),1))) + ", " + FechaToSTR(parseFecha(ing_fecha(parseFecha(primer_dia_sem),1))) + " - " + obtener_dia_string(parseFecha(ultimo_dia_sem)) + ", " + FechaToSTR(parseFecha(ultimo_dia_sem),1) + "</b></td><td onclick='return semana_siguiente()' style='text-align:left;cursor:hand;cursor:pointer'><img title='Siguiente' src='/wiki/image/icons/siguiente.png' style='vertical-align:middle !Important'/></td><td style='width: 25%'>&nbsp;</td></tr></table>"
            $('td_titulo').insert({top: titulo})
 
            encabezado_dia_dibujar(primer_dia_sem)
            semana_dibujar()
        }
    </script>
</head>
<body onload="window_onload()" onresize="semana_onresize()" style="width:100%;height:100%;overflow:hidden">
    <table id='tb_titulo' class="tb1" style="width:100%;height:20px !Important" border='0' cellpadding='0' cellspacing='0'>
        <tr> 
            <td style="width:100%;text-align:center" colspan="2" id="td_titulo">&nbsp;</td>
        </tr>
    </table>
    <table id="tb_semana" class="tbTarea" style="width:100%;height:100%" border='0' cellpadding='0' cellspacing='0'>
        <tr> 
            <td class="tdDia" style="width:50%;height:25%;vertical-align:top" id="td_1">
                <div id="tit_dia_1" style="width:100%;overflow:hidden" ondblclick="return tarea_abm(0,'','',1)"></div>
                <div id="nro_dia_1" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="vertical-align:top" id="td_4">
                <div id="tit_dia_4" title="Nueva tarea" style="width:100%;overflow:hidden" ondblclick="return tarea_abm(0,'','',4)"></div>
                <div id="nro_dia_4" style="width:100%;overflow:auto"></div>
            </td>
        </tr>
        <tr> 
            <td class="tdDia" style="width:50%;height:25%;vertical-align:top" id="td_2">
                <div id="tit_dia_2" style="width:100%;overflow:hidden" ondblclick="return tarea_abm(0,'','',2)"></div>
                <div id="nro_dia_2" style="width:100%;overflow:auto"></div>
            </td>
            <td class="tdDia" style="vertical-align:top" id="td_5">
                <div id="tit_dia_5" title="Nueva tarea" style="width:100%;overflow:hidden" ondblclick="return tarea_abm(0,'','',5)"></div>
                <div id="nro_dia_5" style="width:100%;overflow:auto"></div>
            </td>
        </tr>
        <tr> 
            <td class="tdDia" style="width:50%;height:25%;vertical-align:top" id="td_3">
                <div id="tit_dia_3" style="width:100%;overflow:hidden" ondblclick="return tarea_abm(0,'','',3)"></div>
                <div id="nro_dia_3" style="width:100%;overflow:auto"></div>
            </td>
            <td>
                <table style="width:100%;height:100%" border='0' cellpadding='0' cellspacing='0'>
                    <tr>
                        <td class="tdDia" style="height:50%;vertical-align:top" id="td_6">
                            <div id="tit_dia_6" style="width:100%;overflow:hidden" ondblclick="return tarea_abm(0,'','',6)"></div>
                            <div id="nro_dia_6" style="width:100%;overflow:auto"></div>
                        </td>
                    </tr>
                    <tr>
                        <td class="tdDia" style="height:50%;vertical-align:top" id="td_7">
                            <div id="tit_dia_7" style="width:100%;overflow:hidden" ondblclick="return tarea_abm(0,'','',7)"></div>
                            <div id="nro_dia_7" style="width:100%;overflow:auto"></div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
