<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Me.contents("inNewWindow") = nvFW.nvUtiles.obtenerValor("inNewWindow", "0")
    Me.contents("criterio") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.operador_get_tareas' CommantTimeOut='1500'><parametros><fe_desde DataType='datetime'>%fe_desde%</fe_desde><fe_hasta DataType='datetime'>%fe_hasta%</fe_hasta><strWhere>%strWhere%</strWhere><strOrder>%strOrder%</strOrder></parametros></procedure></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Mis tareas</title>
    <link rel="shortcut icon" href="image/icons/nv_wiki.ico" />

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
	<script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/wiki/script/tareas.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        var inNewWindow = nvFW.pageContents.inNewWindow != "0",
            Imagenes    = [];

        Imagenes["nueva"] = new Image();
        Imagenes["nueva"].src = '/FW/image/icons/nueva.png';
        Imagenes["vincular"] = new Image();
        Imagenes["vincular"].src = '/wiki/image/icons/vincular.png';
        Imagenes["hoy"] = new Image();
        Imagenes["hoy"].src = '/wiki/image/icons/hoy.png';
        Imagenes["dia"] = new Image();
        Imagenes["dia"].src = '/wiki/image/icons/dia.png';
        Imagenes["semana"] = new Image();
        Imagenes["semana"].src = '/wiki/image/icons/semana.png';
        Imagenes["mes"] = new Image();
        Imagenes["mes"].src = '/wiki/image/icons/mes.png';
        Imagenes["buscar"] = new Image();
        Imagenes["buscar"].src = '/FW/image/icons/buscar.png';
        Imagenes["up"] = new Image();
        Imagenes["up"].src = '/wiki/image/icons/up.gif';

        function cFecha(strFecha)
        {
            var aFecha = strFecha.split('/')
            strFecha = ''

            if (aFecha.length == 3)
            {
                dia = aFecha[0]
                mes = parseInt(aFecha[1]) - 1
                anio = parseInt(aFecha[2]) < 100 ? 2000 + parseInt(aFecha[2], 10) : parseInt(aFecha[2])
            }
            
            var fecha = {}
            
            try
            {
                fecha = new Date(anio, mes, dia, 0, 0, 0)
            }
            catch (e)
            {
                fecha = null
            }

            return fecha
        }

        function obtener_ultimo_dia_del_mes(fecha)
        {
            fecha.setTime(fecha.getTime() + ((32 - fecha.getDate()) * 86400000))
            fecha.setTime(fecha.getTime() - (fecha.getDate() * 86400000))
            return fecha
        }

        function obtener_primer_dia_mes_siguiente(fecha)
        {
            valor = obtener_ultimo_dia_del_mes(fecha).getDate() + 1
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000))
            return fecha
        }

        function obtener_dia_siguiente(fecha)
        {
            valor = fecha.getDate() + 1
            fecha.setTime(fecha.getTime() + ((valor - fecha.getDate()) * 86400000)) // 1 dia en milisegundos = 86400000
            return fecha
        }

        function comparar_fechas(fecha1, fecha2) {
            fecha1 = fecha1.split('/')
            fecha2 = fecha2.split('/')

            var ano1 = parseInt(fecha1[2])
            var ano2 = parseInt(fecha2[2])

            var mes1 = parseInt(fecha1[1])
            var mes2 = parseInt(fecha2[1])

            var dia1 = parseInt(fecha1[0])
            var dia2 = parseInt(fecha2[0])

            if (ano1 > ano2)
                return 1
            else
                if (ano1 < ano2)
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

        function MMDDYYYY(strFecha) {
            return strFecha.split('/')[1] + '/' + strFecha.split('/')[0] + '/' + strFecha.split('/')[2]
        }
    </script>
    <script type="text/javascript">

        var vButtonItems = {};
        vButtonItems[0]  = {};
        vButtonItems[0]["nombre"]   = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"]   = "buscar";
        vButtonItems[0]["onclick"]  = "return Buscar(true)";

        var vListButton = new tListButton(vButtonItems, 'vListButton');

        vListButton.imagenes = Imagenes //Imagenes se declara en pvUtiles 

        var oCalendar,
            // referencias a ventanas utilizadas frecuentemente
            win_menuLeft,
            win_divMenuContent
        
        function window_onload() {
            if (!inNewWindow) {
                // cargar las referencias de ventanas
                win_menuLeft = ObtenerVentana('menu_left'),
                win_divMenuContent = ObtenerVentana('divMenu_content')

                //ObtenerVentana('menu_left').$('titulo_menu_left').innerHTML = ''
                //ObtenerVentana('menu_left').$('titulo_menu_left').insert({ top: 'Mis Tareas' })
                win_menuLeft.$('titulo_menu_left').innerHTML = ''
                win_menuLeft.$('titulo_menu_left').insert({ top: 'Mis Tareas' })
            }

            vListButton.MostrarListButton()
            vMenu.MostrarMenu()
            window_onresize()

            cargar_fe_calendario('desde')
            cargar_fe_calendario('hasta')

            btnListarTarea()
        }

        var calendar_fe_desde
        var calendar_fe_hasta
        
        function cargar_fe_calendario(obj) {
            min = 'fe_' + obj == 'fe_desde' ? null : cFecha($('fe_' + obj).value)

            calendar = new Calendar({
                inputField: "fe_" + obj,
                dateFormat: "%d/%m/%Y",
                //trigger: 'img_fe_' + obj,
                showTime: false,
                animation: false,
                min: min,
                onSelect: function () {
                    $('fe_' + obj).value = FechaToSTR(Calendar.intToDate(this.selection.get()))

                    if (obj == 'desde') {
                        calendar_fe_hasta.args.min = cFecha($('fe_desde').value)
                        calendar_fe_hasta.redraw()
                    }

                    this.hide()
                }
            });

            obj == 'desde' ? calendar_fe_desde = calendar : calendar_fe_hasta = calendar
        }

        function ejecutar_calendar(calendar, obj) {
            var calendar = eval(calendar)
            calendar.popup($(obj))
        }

        function tarea_eliminar(nro_tarea, nro_rep) {
            if (nro_rep > 1) {
                pregunta = "Esta es una tarea periódica, que pertenese a la tarea Nº: " + nro_tarea
                pregunta += "<br/>Recuerde: Si acepta se eliminarán todas sus repeticiones"
                pregunta += "<br/>¿Desea eliminarla?"
            }
            else
                pregunta = "¿Desea eliminar la tarea seleccionada?"
            
            window.top.nvFW.confirm(pregunta, {
                width: 350,
                height: 90,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function(win) {
                    win.close();
                    return 
                },
                ok: function (win) {
                    eliminar(nro_tarea)
                    win.close()
                }
            });
        }

        function eliminar(nro_tarea) {
            if (nro_tarea == undefined)
                return

            nvFW.error_ajax_request('tarea_abm.aspx', {
                parameters: { modo: 'E', nro_tarea: nro_tarea },
                onSuccess: function () { Buscar() }
            })
        }

        function window_onresize() {
            var dif = Prototype.Browser.IE ? 5 : 2,
                body_height = $$('body')[0].getHeight(),
                cab_height = $('tbFiltro').getHeight(),
                divFiltro_height = $('divFiltro').getStyle('display') == 'block' ? $('divFiltro').getHeight() : 0
            
            try {
                $('FrameResultado').setStyle({ 'height': body_height - cab_height - divFiltro_height - dif + 'px' })
            }
            catch(e) {}
        }

        function window_onmouseup() {
        }

        function btnListarTarea() {
            mostrar_buscar(false)
            
            if (!inNewWindow) {
                //if (ObtenerVentana('divMenu_content').document.location.pathname != "/wiki/mis_tareas_vistas.aspx")
                //    ObtenerVentana('divMenu_content').location.href = 'mis_tareas_vistas.aspx'
                if (win_divMenuContent.document.location.pathname != "/wiki/mis_tareas_vistas.aspx")
                    win_divMenuContent.location.href = 'mis_tareas_vistas.aspx'
            }
            else
                Buscar()
        }


        function btnBuscar() {
            if ($('divFiltro').getStyle('display') == 'block') {
                $('divFiltro').hide()
                window_onresize()
                return
            }

            if (!inNewWindow)
                //if (ObtenerVentana('divMenu_content').document.location.pathname != "/wiki/mis_tareas_vistas.aspx")
                //    ObtenerVentana('divMenu_content').location.href = 'mis_tareas_vistas.aspx'
                if (win_divMenuContent.document.location.pathname != "/wiki/mis_tareas_vistas.aspx")
                    win_divMenuContent.location.href = 'mis_tareas_vistas.aspx'

            mostrar_buscar(true)
            window_onresize()
        }

        function mostrar_buscar(mostrar) {
            if (mostrar) {
                $('divFiltro').show()
            }
            else
                $('divFiltro').hide()

            window_onresize()
        }

        function tarea_referencias() {
            window.top.win = window.top.nvFW.createWindow({
                url: '/wiki/tarea_referencias.aspx',
                title: '<b>Observaciones</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 350,
                height: 125,
                resizable: false,
                destroyOnClose: true
            });
            
            window.top.win.showCenter(true)
        }
        
        var vista = '',
            fecha = ''

        function onkeypress_buscar(e) {
            var key = Prototype.Browser.IE ? e.keyCode : e.which;
            if (key == 13)
                Buscar()
        }
    </script>
    
    <script type="text/javascript">
        function btnHoy() {
            // en el caso que este visible los filtros el div contenedor lo pone en none
            vista = 'HOY'
            mostrar_buscar(false)
            
            if (!inNewWindow)
                //ObtenerVentana('divMenu_content').location.href = 'menu_calendario.aspx'
                win_divMenuContent.location.href = 'menu_calendario.aspx'
            else
                $("FrameResultado").src = "calendario_dia.aspx?fecha=" + FechaToSTR(new Date(), 2) + "&hora_fraccion=2&esquema_h=1&privacidad=&nro_period=&tiene_autorun="
        }
    </script>
    <script type="text/javascript">
        function btnDia()
        {
            vista = 'DIA'
            // en el caso que este visible los filtros el div contenedor lo pone en none
            mostrar_buscar(false)

            if (!inNewWindow)
                //ObtenerVentana('divMenu_content').location.href = 'menu_calendario.aspx'
                win_divMenuContent.location.href = 'menu_calendario.aspx'
            else
                $("FrameResultado").src = "calendario_dia.aspx?fecha=" + FechaToSTR(new Date(), 2) + "&hora_fraccion=2&esquema_h=1&privacidad=&nro_period=&tiene_autorun="
        }
    </script>
    <script type="text/javascript">
        function btnSemana()
        {
            vista = 'SEMANA'
            // en el caso que este visible los filtros el div contenedor lo pone en none
            mostrar_buscar(false)

            if (!inNewWindow)
                //ObtenerVentana('divMenu_content').location.href = 'menu_calendario.aspx'
                win_divMenuContent.location.href = 'menu_calendario.aspx'
            else
                $("FrameResultado").src = "calendario_semana.aspx?fecha_get=" + FechaToSTR(new Date(), 2) + "&privacidad=&nro_period=&tiene_autorun="
        }
    </script>
    <script type="text/javascript">
        function btnMes()
        {
            vista = 'MES'
            mostrar_buscar(false)

            if (!inNewWindow)
                //ObtenerVentana('divMenu_content').location.href = 'menu_calendario.aspx'
                win_divMenuContent.location.href = 'menu_calendario.aspx'
            else
                $("FrameResultado").src = "calendario_mes.aspx?fecha_get=" + FechaToSTR(new Date(), 2) + "&privacidad=&nro_period=&tiene_autorun="
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden" onmouseup="return window_onmouseup()">
    <div id="tbFiltro" style="width: 100%">
        <div id="divMenu" style="margin: 0px; padding: 0px;"></div>

        <script type="text/javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenu = new tMenu('divMenu', 'vMenu');
            
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].imagenes = Imagenes //Imagenes se declara en pvUtiles

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>tarea_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vincular</icono><Desc>Mis Tareas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnListarTarea()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoy</icono><Desc>Hoy</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnHoy()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>dia</icono><Desc>Día</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnDia()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>semana</icono><Desc>Semana</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnSemana()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='6'><Lib TipoLib='offLine'>DocMNG</Lib><icono>mes</icono><Desc>Mes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnMes()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='7'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Buscar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnBuscar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='8' style='width: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='9'><Lib TipoLib='offLine'>DocMNG</Lib><icono>up</icono><Desc>Referencias Iconos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>tarea_referencias()</Codigo></Ejecutar></Acciones></MenuItem>")
        </script>
    </div>
    <table class="tb1" cellpadding="0" cellspacing="0" width="100%" border="0">
        <tr>
            <td>
                <div id="divFiltro" style="width:100%;display:none">
                    <table class="tb1">
                        <tr>
                            <td style="width:15%;vertical-align:top">
                                <table class="tb1">
                                    <tr>
                                        <td class='Tit1' style="width:25%;text-align:center">Asunto</td>
                                        <td class='Tit1' style="width:10%;text-align:center" nowrap="nowrap">Fecha Desde</td>
                                        <td class='Tit1' style="width:10%;text-align:center" nowrap="nowrap">Fecha hasta</td>
                                        <td class='Tit1' style="width:10%;text-align:center">Estado</td>
                                        <td class='Tit1' style="width:10%;text-align:center">Prioridad</td>
                                        <td class='Tit1' style="width:8%;text-align:center">Privacidad</td>
                                        <td class='Tit1' style="width:8%;text-align:center">Periódica</td>
                                        <td class='Tit1' style="width:8%;text-align:center">Automática</td>
                              
                                        <td style="text-align:center" rowspan="2"><div id="divBuscar" style="width:100%"/></td>
                                    </tr>
                                    <tr>
                                        <td style="width:25%">
                                            <input type="text" id="asunto" style="width:100%" onkeypress="return onkeypress_buscar(event)"  />
                                        </td>
                                        <td style="width:10%">
                                            <% = nvCampo_def.get_html_input("fe_desde", nro_campo_tipo:=103, enDB:=False)%>
                                        </td>
                                        <td style="width:10%">
                                            <% = nvCampo_def.get_html_input("fe_hasta", nro_campo_tipo:=103, enDB:=False)%>
                                        </td>
                                        <td style="width:10%">
                                            <%= nvFW.nvCampo_def.get_html_input("nro_tarea_estado") %>
                                        </td>
                                        <td style="width:10%">
                                            <%= nvFW.nvCampo_def.get_html_input("nro_tarea_pri") %>
                                        </td>
                                        <td style="width:8%">
                                            <select id="cmb_privacidad" style="width:100%">
                                                <option value="0">Vinculada</option>
                                                <option value="1">Privada</option>
                                                <option value="2">Publica</option>
                                                <option value="3" selected="selected">Todas</option>
                                            </select>
                                        </td>            
                                        <td style="width:8%">
                                            <select id="cmb_esperiodica" style="width:100%">
                                                <option value="0" selected="selected">Todas</option>
                                                <option value="1">Si</option>
                                                <option value="2">No</option>
                                            </select>
                                        </td>            
                                        <td style="width:8%">
                                            <select id="cmb_tiene_autorun" style="width:100%">
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
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <iframe name="FrameResultado" id="FrameResultado" style="width: 100%; height: 100%;overflow: auto" frameborder="0" src="enBlanco.htm"></iframe>
            </td>
        </tr>
    </table>
</body>
</html>
