<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageWiki" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Vistas Mis Tareas</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <script type="text/javascript">
        var winMenuLeft = {},   // declaracion de objetos vacíos donde se carpturarán diferentes ventanas
            winFrameRef = {}

        function obtener_ultimo_dia_del_mes(fecha) {
            fecha.setTime(fecha.getTime() + ((32 - fecha.getDate()) * 86400000))
            fecha.setTime(fecha.getTime() - (fecha.getDate() * 86400000))
            return fecha
        }

        function obtener_primer_dia_mes_siguiente(fecha) {
            var valor = obtener_ultimo_dia_del_mes(fecha).getDate() + 1
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000))
            return fecha
        }

        function obtener_proximos_siete_dias(fecha) {
            var valor = fecha.getDate() + 6
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000)) // 1 dia en milisegundos = 86400000
            return fecha
        }

        function aumentar_disminuir_fecha(fecha, ad) {
            var valor = fecha.getDate() + ad
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000)) // 1 dia en milisegundos = 86400000
            return fecha
        }

        function obtener_dia_siguiente(fecha) {
            var valor = fecha.getDate() + 1
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000)) // 1 dia en milisegundos = 86400000
            return fecha
        }

        function window_onload() {
            winMenuLeft = ObtenerVentana('menu_left')

            //ObtenerVentana('menu_left').$('titulo_menu_left').innerHTML = ''
            //ObtenerVentana('menu_left').$('titulo_menu_left').insert({ top: 'Mis Tareas' })
            winMenuLeft.$('titulo_menu_left').innerHTML = ''
            winMenuLeft.$('titulo_menu_left').insert({ top: 'Mis Tareas' })

            winFrameRef = ObtenerVentana('frame_ref')

            generar_filtro('tareas_pendientes');
            FormVistas.Radio[1].checked = true
        }

        function generar_filtro(vista) {
            //ObtenerVentana('frame_ref').$('cmb_privacidad').options[3].selected = true
            //ObtenerVentana('frame_ref').$('asunto').value = ''
            //ObtenerVentana('frame_ref').campos_defs.clear()
            //ObtenerVentana('frame_ref').campos_defs.set_value('fe_desde', '')
            //ObtenerVentana('frame_ref').campos_defs.set_value('fe_hasta', FechaToSTR(new Date(new Date().getFullYear(), 11, 31, 23, 59, 59)))
            //ObtenerVentana('frame_ref').strOrder = 'fe_inicio,nro_tarea'

            winFrameRef.$('cmb_privacidad').options[3].selected = true
            winFrameRef.$('asunto').value = ''
            winFrameRef.campos_defs.clear()
            winFrameRef.campos_defs.set_value('fe_desde', '')
            winFrameRef.campos_defs.set_value('fe_hasta', FechaToSTR(new Date(new Date().getFullYear(), 11, 31, 23, 59, 59)))
            winFrameRef.strOrder = 'fe_inicio,nro_tarea'

            $('tdOtros').hide();
            check_radio = ''

            switch (vista) {
                case 'tareas_pendientes':
                    //ObtenerVentana('frame_ref').campos_defs.set_value('nro_tarea_estado', 1)
                    winFrameRef.campos_defs.set_value('nro_tarea_estado', 1)
                    break
                case 'tareas_en_ejecucion':
                    //ObtenerVentana('frame_ref').campos_defs.set_value('nro_tarea_estado', 2)
                    winFrameRef.campos_defs.set_value('nro_tarea_estado', 2)
                    break
                case 'tareas_aplazadas':
                    //ObtenerVentana('frame_ref').campos_defs.set_value('nro_tarea_estado', 4)
                    winFrameRef.campos_defs.set_value('nro_tarea_estado', 4)
                    break
                case 'tareas_pendientes_pri_alta':
                    //ObtenerVentana('frame_ref').campos_defs.set_value('nro_tarea_pri', 1)
                    //ObtenerVentana('frame_ref').campos_defs.set_value('nro_tarea_estado', 1)
                    winFrameRef.campos_defs.set_value('nro_tarea_pri', 1)
                    winFrameRef.campos_defs.set_value('nro_tarea_estado', 1)
                    break
                case 'comienzan_hoy':
                    var date = new Date();
                    date.setHours(0);
                    date.setMinutes(0);
                    date.setSeconds(0);
                    
                    var fecha_desde = FechaToSTR(date)
                    date.setDate(date.getDate() + 1)
                    var fecha_hasta = FechaToSTR(date)
                    
                    //ObtenerVentana('frame_ref').$('fe_desde').value = fecha_desde
                    //ObtenerVentana('frame_ref').$('fe_hasta').value = fecha_hasta
                    winFrameRef.$('fe_desde').value = fecha_desde
                    winFrameRef.$('fe_hasta').value = fecha_hasta
                    break
            }
            //ObtenerVentana('frame_ref').Buscar()
            winFrameRef.Buscar()
        }
    </script>

    <style type="text/css">
        input {
            border-width: 0px;
            border-left: 0px;
            border-right: 0px;
            border-top: 0px;
        }
        td label {
            cursor: hand;
            cursor: pointer;
        }
	
    </style>

</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="" id="FormVistas" style="width: 100%; height: 100%; overflow: hidden">
        <table class="tb1" cellpadding="0" cellspacing="0" style="height: 100% !Important">
            <tr>
                <td style="vertical-align: top !Important">
                    <table class="tb1">
                        <tr>
                            <td style="width: 100%; height: 100% !Important">
                                <table class="tb1" style="height: 100% !Important">
                                    <tr>
                                        <td class="td_aumentado">&nbsp;<b>Filtros predefinidos:</b></td>
                                    </tr>
                                    <tr>
                                        <td class="td_aumentado">
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="radio" name="Radio" id="hoy" value="1" onclick="return generar_filtro('comienzan_hoy')" />
                                            &nbsp;
                                            <label for="hoy">Comienzan Hoy</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="td_aumentado">
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="radio" name="Radio" id="pendientes" value="2" checked="checked" onclick="return generar_filtro('tareas_pendientes')" />
                                            &nbsp;
                                            <label for="pendientes">Tareas Pendientes</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="td_aumentado">
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="radio" name="Radio" id="enEjecucion" value="3" onclick="return generar_filtro('tareas_en_ejecucion')" />
                                            &nbsp;
                                            <label for="enEjecucion">Tareas en Ejecución</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="td_aumentado">
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="radio" name="Radio" id="aplazadas" value="4" onclick="return generar_filtro('tareas_aplazadas')" />
                                            &nbsp;
                                            <label for="aplazadas">Tareas Aplazadas</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="td_aumentado">
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="radio" name="Radio" id="altaPrioridad" value="8" onclick="return generar_filtro('tareas_pendientes_pri_alta')" />
                                            &nbsp;
                                            <label for="altaPrioridad">Alta Prioridad</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="td_aumentado" id="tdOtros">
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="radio" name="Radio" id="otros" value="5" onclick="return generar_filtro('default')" />
                                            &nbsp;
                                            <label for="otros">Otros</label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
