<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Menu Calendario</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/calendar/jscal2.js"></script>
    <script type="text/javascript" src="/FW/script/calendar/lang/es.js"></script>
    <link type="text/css" rel="stylesheet" href="/FW/css/calendar/css/jscal2.css" />

    <style type="text/css">
        .DynarchCalendar-titleCont tr,
        .DynarchCalendar-dayNames tr {
            background: transparent !important;
        }
        .DynarchCalendar-titleCont td,
        .DynarchCalendar-dayNames td {
            -webkit-box-shadow: none !important;
            -moz-box-shadow: none !important;
            -ms-box-shadow: none !important;
            box-shadow: none !important;
        }
    </style>

    <script type="text/javascript">
        var oCalendar,
            // referencia a ventana "frame_ref" utilizada - aqui objeto vacio
            win_frameRef = {}
        
        function window_onload() {
            var FechaSelection
            win_frameRef =  ObtenerVentana('frame_ref')

            if (win_frameRef.fecha == '' || win_frameRef.vista == 'HOY') {
                FechaSelection     = Calendar.dateToInt(new Date())
                win_frameRef.fecha =  FechaToSTR(new Date(), 2)
            } 
            else  
                FechaSelection = Calendar.dateToInt(parseFecha(win_frameRef.fecha))
            
            oCalendar = Calendar.setup({
                cont: "calendar-container",
                weekNumbers: false,
                bottomBar: false,
                animation: false,
                selection: FechaSelection,
                showTime: false,
                onSelect: hoy_actualizar,
                onTimeChange: function(cal) { }
            });
            
            window_onresize()
            hoy_actualizar()
        }
        
        function hoy_actualizar() {
            var cb = $("hora_fraccion"),
                hora_fraccion = cb.options[cb.options.selectedIndex].value,
                cb = $("esquema_h"),
                esquema_h = cb.options[cb.options.selectedIndex].value,
                privacidad = '',
                cb = $('cmb_privacidad')
            
            if (cb.options[cb.options.selectedIndex].value == 3)
                privacidad = ""
            
            if (cb.options[cb.options.selectedIndex].value == 2)
                privacidad = "2"

            if (cb.options[cb.options.selectedIndex].value == 1)
                privacidad = "1"
            
            if (cb.options[cb.options.selectedIndex].value == 0)
                privacidad = "0,1"

            var tiene_autorun = '',
                cb = $('cmb_tiene_autorun')
            
            if (cb.options[cb.options.selectedIndex].value == 1)
                tiene_autorun = "1"
            
            if (cb.options[cb.options.selectedIndex].value == 2)
                tiene_autorun = "0"

            var nro_period = '',
                cb = $('cmb_esperiodica')
            
            if (cb.options[cb.options.selectedIndex].value == 1)
                nro_period = "1"
            
            if (cb.options[cb.options.selectedIndex].value == 2)
                nro_period = "0" 
            
            win_frameRef.fecha = FechaToSTR(Calendar.intToDate(oCalendar.selection.get()), 2) 
            
            win = ObtenerVentana("FrameResultado")

            if (win_frameRef.vista == 'HOY') {
                win.location.href = "calendario_dia.aspx?fecha=" + FechaToSTR(new Date(), 2) + '&hora_fraccion=' + hora_fraccion + "&esquema_h=" + esquema_h + "&privacidad=" + privacidad + '&nro_period=' + nro_period + '&tiene_autorun=' + tiene_autorun
                $('hora_fraccion').disabled = false
                $('esquema_h').disabled = false
            } 
            
            if (win_frameRef.vista == 'DIA') {
                win.location.href = "calendario_dia.aspx?fecha=" + win_frameRef.fecha + '&hora_fraccion=' + hora_fraccion + "&esquema_h=" + esquema_h + "&privacidad=" + privacidad + '&nro_period=' + nro_period + '&tiene_autorun=' + tiene_autorun
                $('hora_fraccion').disabled = false
                $('esquema_h').disabled = false
            } 
            
            if (win_frameRef.vista == 'SEMANA' ) {
                win.location.href = "calendario_semana.aspx?fecha_get=" + win_frameRef.fecha + "&privacidad=" + privacidad + '&nro_period=' + nro_period + '&tiene_autorun=' + tiene_autorun
                $('hora_fraccion').disabled = true
                $('esquema_h').disabled = true
            } 
             
            if (win_frameRef.vista == 'MES' ) {
                win.location.href = "calendario_mes.aspx?fecha_get=" + win_frameRef.fecha + "&privacidad=" + privacidad + '&nro_period=' + nro_period + '&tiene_autorun=' + tiene_autorun
                $('hora_fraccion').disabled = true
                $('esquema_h').disabled = true
            }  
            
            if (win_frameRef.vista == 'HOY')
                win_frameRef.vista = 'DIA'
        }
        
        function window_onresize(){
        }

        function tarea_rep(nro_tarea, nro_rep) {
            if (nro_rep > 1) {
                pregunta = "Esta es una tarea periódica, que pertenese a la tarea Nº: " + nro_tarea 
                pregunta += "<br/> si acepta accedera a la tarea origen"
                nvFW.confirm(pregunta, {
                    width: 350,
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    cancel: function(win) {
                        win.close(); 
                        return
                    },
                    ok: function(win) {
                        tarea_abm(nro_tarea)
                        win.close()
                    }
                });
            }
            else
                tarea_abm(nro_tarea)
        }

        function tarea_abm(nro_tarea) {
            window.top.win = nvFW.createWindow({
                url: '/wiki/tarea_abm.aspx?nro_tarea_get=' + nro_tarea,
                title: '<b>Tarea</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 950,
                height: 450,
                resizable: true,
                onClose: tarea_abm_return,
                destroyOnClose: true
                });

            window.top.win.showCenter(true)
        }

        function tarea_abm_return()
        {
            if (window.top.win.returnValue != undefined)
                Buscar()
        }

        function window_onmouseup() {
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden" onmouseup="return window_onmouseup()">
    <table class="tb1" cellpadding="0" cellspacing="0" style="width:100%;height:100%" border="0">
        <tr>
            <td style="vertical-align: top; font-size: 12px !Important">
                <table class="tb1" cellpadding="0" cellspacing="0" id="tb_calendar">
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div style="width: 100%; vertical-align: top" id="calendar-container"></div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="Tit1" style="width:47%">&nbsp;Intervalo horario:</td>
                        <td>
                            <select id="hora_fraccion" onchange="return hoy_actualizar()" style="width: 95%">
                                <option value="1">1 hora</option>
                                <option value="2" selected>30 minutos</option>
                                <option value="4">15 minutos</option>
                                <option value="6">10 minutos</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="Tit1">&nbsp;Esquema horario:</td>
                        <td>
                            <select id="esquema_h" onchange="return hoy_actualizar()" style="width: 95%">
                                <option value="1">Horario completo</option>
                                <option value="2" selected="selected">Horario corrido 8-19</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>    
                        <td class="Tit1">&nbsp;Privacidad:</td>
                        <td>
                            <select id="cmb_privacidad" onchange="return hoy_actualizar()" style="width: 95%">
                                <option value="0">Vinculada</option>
                                <option value="1">Privada</option>
                                <option value="2">Publica</option>
                                <option value="3" selected="selected">Todas</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>    
                        <td class="Tit1">&nbsp;Periodicidad:</td>
                        <td>
                            <select id="cmb_esperiodica" onchange="return hoy_actualizar()" style="width: 95%">
                                <option value="0" selected="selected">Todas</option>
                                <option value="1">Si</option>
                                <option value="2">No</option>
                            </select>                        
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>    
                        <td class="Tit1">&nbsp;Ejecución Automática:</td>
                        <td>
                            <select id="cmb_tiene_autorun" onchange="return hoy_actualizar()" style="width: 95%">
                                <option value="0" selected="selected">Todas</option>
                                <option value="1">Si</option>
                                <option value="2">No</option>
                            </select>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
