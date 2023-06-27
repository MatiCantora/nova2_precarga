<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim operador As nvFW.nvPages.tnvOperadorAdmin
    Dim er As New tError

    operador = nvFW.nvApp.getInstance().operador
    'debe tener el permiso para ingresar
    If Not operador.tienePermiso("permisos_web", 4) Then
        er = New nvFW.tError()
        er.numError = -1
        er.titulo = "No se pudo completar la operación."
        er.mensaje = "No tiene permisos para ver la página."
        er.response()
    End If

    Me.contents("filtroLogType") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nvWatcher_logType'><campos>distinct nro_logType as id, logType as  [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

    Me.contents("filtroWatcherEventos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select PageSize='32' AbsolutePage='1' vista='verNv_Watcher_Eventos'><campos>* </campos><orden>fe_log desc</orden></select></criterio>")
    Me.contents("filtroWatcherEventosExportar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_Watcher_Eventos'><campos>idlog as [Nro], fe_log as [Fecha], instancia as [Instancia], name as [Watcher], msg as [Descripcion], isnull(logType,'') + ' (' + CAST(nro_logType as varchar(50)) + ')' as [Tipo Evento], log as [Log], machine as [Maquina], source as [Source]</campos><orden>fe_log desc</orden></select></criterio>")

    Me.contents("fromDate") = DateTime.Now.AddMonths(-1).ToString("dd/MM/yyyy")
    Me.contents("toDate") = DateTime.Now.ToString("dd/MM/yyyy")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Watcher Eventos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% =Me.getHeadInit()%>
    <style type="text/css">
        
    </style>
    <script type="text/javascript">

        var win = nvFW.getMyWindow();
        var indexActual = 0;
        var descripciones = {}

        function window_onload() {
            var vButtonItems = {};
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Buscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            var vListButtons = new tListButton(vButtonItems, 'vListButtons')
            vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png')
            vListButtons.MostrarListButton()
            window_onresize();

            //Búsqueda por defecto
            campos_defs.set_value('fecha_log_desde', nvFW.pageContents.fromDate)
            campos_defs.set_value('fecha_log_hasta', nvFW.pageContents.toDate)
            campos_defs.set_value('registrosTop', 500)

            //buscar()

        }

        function key_Buscar() {
            if (window.event.keyCode == 13)
                buscar();
        }

        function getFiltroInstancia() {
            var output = "";
            //Quitamos el Id de la descripción
            var instanciasFilter = campos_defs.get_desc('nro_instancias_watcher').replace(new RegExp(/ \([\s\d\/]+\)/, 'g'), "");
            if (instanciasFilter.length) {
                instanciasFilter.split('; ').forEach(function (valor, i, array) {
                    output += (i > 0 ? ",'" : "'") + valor + "'";
                });
            }
            
            return output;
        }

        function getFiltroWhere() {
            
            var filtro = ""

            if ($('fecha_log_desde').value != "")
                filtro = filtro + " <fe_log type='mas'>convert(datetime,'" + campos_defs.get_value('fecha_log_desde') + "',103)</fe_log>"
            if ($('fecha_log_hasta').value != "")
                filtro = filtro + " <fe_log type='menor'>dateadd(dd,1,convert(datetime,'" + campos_defs.get_value('fecha_log_hasta') + "',103))</fe_log>"

            if ($('nro_instancias_watcher').value != "")
                filtro = filtro + "<instancia type='in'>" + getFiltroInstancia() + "</instancia>"
            if ($('watcherLabel').value != "")
                filtro = filtro + "<name type='like'>%" + campos_defs.get_value('watcherLabel') + "%</name>"

            if ($('descripcion').value != "")
                filtro = filtro + "<msg type='like'>%" + campos_defs.get_value('descripcion') + "%</msg>"
            if ($('logType').value != "")
                filtro = filtro + "<nro_logType type='in'>" + campos_defs.get_value('logType') + "</nro_logType>"

            return filtro;
        }

        function buscar() {
            var strFiltros = getFiltroWhere()

            //nvFW.bloqueo_activar($(document.body), 'cargando_logs')
            var alto = $("iframe_logs").clientHeight
            var filas = alto / 22.6 // 22.6px es la altura aproximada de cada fila
            var filtroWhere = "<criterio><select PageSize='" + Math.floor(filas) + "' AbsolutePage='1' top='" + campos_defs.get_value('registrosTop') + "' cacheControl='session' expire_minutes='2'><filtro>" + strFiltros + "</filtro></select></criterio>"


            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroWatcherEventos,
                filtroWhere: filtroWhere,
                path_xsl: 'report/watcher/nvLog_watcher.xsl',
                salida_tipo: "adjunto",
                formTarget: 'iframe_logs',
                nvFW_mantener_origen: true,
                bloq_contenedor: 'iframe_logs',
                cls_contenedor: 'iframe_logs',
                cls_contenedor_msg: " ",
                bloq_msg: "Cargando lista..."
            });
        }

        function exportar(){
            var strFiltros = getFiltroWhere()

            var filtroWhere = "<criterio><select top='" + campos_defs.get_value('registrosTop') + "' cacheControl='session' expire_minutes='2'><filtro>" + strFiltros + "</filtro></select></criterio>"

            nvFW.exportarReporte({

                //Parémetros de consulta
                filtroXML: nvFW.pageContents.filtroWatcherEventosExportar,
                filtroWhere: filtroWhere,
                //path_xsl: 'report/EXCEL_base.xsl',
                export_exeption: "RSXMLtoExcel",
                filename: "nvWatcherEventos.xlsx",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel"
            })
        }


        function verDescripcion(idlog) {

            var win_desc = nvFW.createWindow({
                className: 'alphacube',
                url: '/FW/watcher/nWatcher_eventos_desc.aspx',
                title: 'Evento',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 210
            });
            win_desc.options.userData = {idlog: idlog};
            win_desc.showCenter(false)
        }

        function window_onresize() {

            var body_h = $$('body')[0].getHeight()
            var divHead_h = $('divHead').getHeight()
            var h = body_h - divHead_h
            if (h > 0) {
                $('iframe_logs').setStyle({ height: h, overflow: "hidden" });
            }

        }

    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" onkeypress="return key_Buscar()"
    style="width: 100%; height: 100%;overflow:hidden">
    <div id='divHead' style="width:100%">
        <table class="tb1">
            <tr>
                <td colspan="2">
                    <div id="menuLista" style="width: 100%"></div>
                </td>
                <script type="text/javascript">
                    var vMenu = new tMenu('menuLista', 'vMenu');
                    vMenu.alineacion = 'centro'
                    vMenu.estilo = 'A'
                    //vMenu.loadImage('nuevo', '/FW/image/icons/nueva.png')
                    vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Eventos</Desc></MenuItem>")
                    vMenu.MostrarMenu();
                </script>
            </tr>
            <tr style="white-space:nowrap" id="trfiltros">
                <td style="width: 100%">
                    <table class="tb1">
                        <tr>
                            <td width="10%" class="Tit1">
                                Desde:
                            </td>
                            <td width="10%">
                                <script type="text/javascript">
                                    campos_defs.add('fecha_log_desde', {
                                        enDB: false,
                                        nro_campo_tipo: 103,
                                    });
                                </script>
                            </td>
                            <td width="10%" class="Tit1">
                                Hasta:
                            </td>
                            <td width="10%">
                                <script type="text/javascript">
                                    campos_defs.add('fecha_log_hasta', {
                                        enDB: false,
                                        nro_campo_tipo: 103,
                                    });
                                </script>
                            </td>
                            <td class="Tit1">
                                Instancia:
                            </td>
                            <td>
                                <% = nvFW.nvCampo_def.get_html_input("nro_instancias_watcher") %>
                            </td>
                            <td class="Tit1">
                                Watcher:
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('watcherLabel', {
                                        enDB: false,
                                        nro_campo_tipo: 104,
                                    });
                                </script>
                            </td>
                            <td rowspan="2" style="width: 90px">
                                <div id="divBuscar" style="width: 100%" />
                            </td>
                        </tr>
                        <tr>
                            <td class="Tit1">
                                Descripción:
                            </td>
                            <td colspan="3">
                                <script type="text/javascript">
                                    campos_defs.add('descripcion', {
                                        enDB: false,
                                        nro_campo_tipo: 104,
                                    });
                                </script>
                            </td>
                            <td class="Tit1" nowrap>
                                Tipo de Evento:
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('logType', {
                                        enDB: false,
                                        nro_campo_tipo: 2,
                                        filtroXML: nvFW.pageContents.filtroLogType
                                    });
                                </script>
                            </td>
                            <td class="Tit1" nowrap>
                                Nro. de registros:
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('registrosTop', {
                                        enDB: false,
                                        nro_campo_tipo: 100
                                    });
                                </script>
                            </td>
                        </tr>
                    </table>
                </td>
                
            </tr>
        </table>

    </div>

      <iframe id="iframe_logs" name="iframe_logs" style="width: 100%; height: 100%;border: none; overflow: hidden" src="/FW/enBlanco.htm"></iframe>

</body>
</html>
