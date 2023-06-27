<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>

<%


%>
<html>
<head>
    <title>Presentacion</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% =Me.getHeadInit()%>
    <script type="text/javascript">
        var filas = 0
        function brLog_show(el) {
            
            if ($("chkPausa").checked)
                return

            if (nvFW.brLog.eventos[el.id_nv_log_evento].brMostrar || $("chkMostrarTodos").checked) {
                filas++
                var enviado = el.enviado == true ? 1 : 0
                var strCampos = ''
                var strTR = '<tr><td>' + filas + '</td><td nowrap>' + HoraToSTR(el.fe_evento) + '.' + el.fe_evento.getMilliseconds() + '</td><td nowrap>' + el.id_nv_log_evento + "</td>"
                var e = "<"
                var reg = new RegExp(e, 'ig')
                for (var i in el)
                    if (i != 'fe_evento' && i != 'id_nv_log_evento')
                        strCampos += el[i].toString() + ';'
                strTR += '<td nowrap>' + strCampos.replace(reg, "&lt;") + '</td><td>' + enviado + '</td></tr>'
                $("tbBrLog").insert({ bottom: strTR })
                //document.body.innerHTML = strCampos.replace(reg, "&lt;") + "</br>" + document.body.innerHTML
            }

        }

        function window_resize() {
            try {

                var body = $$("BODY")[0]
                var tb = $("contenedor")
                var dif = body.getHeight() - tb.cumulativeOffset().top
                tb.setStyle({ height: dif + 'px' })
            } catch (e) {

            }
        }
        function window_onload() {
            
            // inicializar objeto de log
            if (window.top.nvFW.brLog == undefined) {
                window.top.nvFW.brLog = new tnvBrowserLog()
            }
            // usar el objeto log del top
            nvFW.brLog = window.top.nvFW.brLog

            for (var i = 0; i < nvFW.brLog.logs.length; i++) {
                if (typeof (nvFW.brLog.logs[i]) != "function")
                    nvFW.brLog.logWindow.content.contentWindow.brLog_show(nvFW.brLog.logs[i])
            }

            window_resize()
        }

        function btnActualizar_onclick() {
            filas = 0
            var tb = $("tbBrLog")
            while (tb.rows[1] != null)
                tb.deleteRow(1)
            for (var i = 0; i < nvFW.brLog.logs.length; i++) {
                if (typeof (nvFW.brLog.logs[i]) != "function")
                    nvFW.brLog.logWindow.content.contentWindow.brLog_show(nvFW.brLog.logs[i])
            }
        }

        function chkEnviar_onclick() {
            
            nvFW.brLog.agente_intervalo = $("txtIntervalo").value
            if ($("chkEnviar").checked)
                nvFW.brLog.agente_iniciar()
            else
                nvFW.brLog.agente_terminar()
        }
        function btnLimpiar_onclick() {
            filas = 0
            var tb = $("tbBrLog")
            while (tb.rows[1] != null)
                tb.deleteRow(1)
        }

        function btnLimpiarLog_onclick() {
            nvFW.brLog.clear()
            btnLimpiar_onclick()
        }

        function btnCFG_onclick() {
            nvFW.brLog.cfg_actualizar()
        }

        function btnVerCFG_onclick() {
            var strHTML = "<table class='tb1'><tr class='tbLabel'><td>Evento</td><td>Mostrar</td><td>Enviar</td><td>cuenta</td></tr>"
            var evento
            for (var i in nvFW.brLog.eventos) {
                evento = nvFW.brLog.eventos[i]
                strHTML += "<tr><td>" + evento.id_nv_log_evento + "</td><td style='text-align: center'>" + evento.brMostrar + "</td><td style='text-align: center'>" + evento.brEnviar + "</td><td style='text-align: right'>" + evento.cuenta + "</td></tr>"
            }
            strHTML += "</table>"
            var win = window.top.nvFW.createWindow({
                className: 'alphacube',
                title: '<b>Browser Log CFG</b>',
                //url: '/.asp',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 400,
                height: 150,
                resizable: true
            })

            win.getContent().innerHTML = strHTML
            win.showCenter()
        }
    </script>
</head>
<body style="width: 100%; height: 100%; overflow: hidden; background-color: White; width: 100%" onload="window_onload()" onresize="window_resize()">
    <input type="button" id="btnActualizar" value="Actualizar" onclick="btnActualizar_onclick()" />
    &nbsp;&nbsp;&nbsp;Enviar al servidor
    <input type="checkbox" id="chkEnviar" onclick="chkEnviar_onclick()" />
    &nbsp;&nbsp;&nbsp;Intervalo de envio
    <input type="text" value="10000" id="txtIntervalo" style="text-align: right; width: 50px" />
    &nbsp;&nbsp;&nbsp;Pausa
    <input type="checkbox" id="chkPausa" />
    &nbsp;&nbsp;&nbsp;
    <input type="button" id="btnLimpiar" value="Limpiar ventana" onclick="btnLimpiar_onclick()" />
    &nbsp;&nbsp;&nbsp;
    <input type="button" id="btnLimpiarLog" value="Limpiar Log" onclick="btnLimpiarLog_onclick()" />
    &nbsp;&nbsp;&nbsp;Mostrar todos
    <input type="checkbox" id="chkMostrarTodos" />
    &nbsp;&nbsp;&nbsp;
    <input type="button" id="btnCFG" value="CFG" onclick="btnCFG_onclick()" />
    &nbsp;&nbsp;&nbsp;
    <input type="button" id="btnVerCFG" value="Ver CFG" onclick="btnVerCFG_onclick()" />
    <div style="overflow: auto; width: 100%; height: 300px" id="contenedor">
        <table id="tbBrLog" class="tb1">
            <tr class="tbLabel">
                <td>#</td>
                <td>fecha</td>
                <td>evento</td>
                <td>datos</td>
                <td></td>
            </tr>
        </table>
    </div>
</body>
</html>
