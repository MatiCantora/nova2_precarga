<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Me.contents("filtroAsig") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_asignacion' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    'Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute("select * from VOII_asignacion where codafinidad=2", cod_cn:="BD_IBS_ANEXA")
    'Stop
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administrador de Movimientos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit() %>


    <script type="text/javascript">

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "buscar_asignacion()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("buscar", "/fw/image/icons/buscar.png")

        var filtro

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var FiltroDatos_h = $('tablaCont').getHeight() + $('divMenuDig').getHeight()
                $('listaAsignaciones').setStyle({ 'height': body_h - FiltroDatos_h - dif + 2 + 'px' });
            }
            catch (e) { }
        }

        function window_onload() {
            vListButton.MostrarListButton()
            window_onresize()
        }

        function buscar_asignacion() {
            filtros()

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroAsig,
                filtroWhere: "<criterio><select PageSize='22' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: 'report\\asignacion\\asignacion.xsl',
                formTarget: 'listaAsignaciones',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Buscando...',
                cls_contenedor: 'listaAsignaciones'
            })
        }

        function filtros() {
            filtro = ""

            if ($('razonsocial').value != '')
                filtro += "<razon_social type='like'>%" + $('razonsocial').value + "%</razon_social>"

            if ($('tipdoc').value != '')
                filtro += "<tipdoc type='in'>" + $('tipdoc').value + "</tipdoc>"

            if ($('nrodoc').value != '')
                filtro += "<nrodoc type='igual'>" + $('nrodoc').value + "</nrodoc>"

            if ($('codafinidad').value != '')
                filtro += "<codafinidad type='in'>" + $('codafinidad').value + "</codafinidad>"

            if ($('nrocuil').value != '')
                filtro += "<cuit_cuil type='igual'>'" + $('nrocuil').value + "'</cuit_cuil>"
        }

        function eliminar_asignacion(razon_social, tipdoc, nrodoc, cuit_cuil, codafinidad) {
            Dialog.confirm('<b>¿Esta seguro de que desea eliminar esta asignación?</b>', {
                width: 425,
                className: "alphacube",
                okLabel: "Si",
                cancelLabel: "No",
                onOk: function (win) {
                    nvFW.error_ajax_request('asignacion_ABM.aspx', {
                        parameters: { accion: 1, codafinidad: codafinidad, tipdoc: tipdoc, razon_social: razon_social, nrodoc: nrodoc, cuit_cuil: cuit_cuil },
                        onSuccess: function (err, transport) {
                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                            buscar_asignacion()

                        },
                    })
                    win.close()
                }
            })
        }


        var win_asignacion_abm
        function abrirAbm() {
            //var w 
            win_asignacion_abm = nvFW.createWindow({
                url: '/voii/asignacion/asignacion_ABM.aspx?path=' + path,
                title: '<b>Asignación ABM</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: false,
                modal: true,
                width: 800,
                height: 250
            });

            win_asignacion_abm.showCenter()
        }

        function editar_asignacion(razon_social, tipdoc, nrodoc, cuit_cuil, codafinidad) {
            var win_asignacion_abm
                win_asignacion_abm = nvFW.createWindow({
                    url: "/voii/asignacion/asignacion_ABM.aspx",
                    title: '<b>Asignación ABM</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    resizable: false,
                    width: 800,
                    height: 250
                });
            win_asignacion_abm.options.userData = {
                'accion': 2,
                'razon_social': razon_social,
                'tipdoc': tipdoc,
                'nrodoc': nrodoc,
                'cuit_cuil': cuit_cuil,
                'codafinidad': codafinidad
            }
                win_asignacion_abm.showCenter()
        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
    <div id="divMenuDig"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuDig = new tMenu('divMenuDig', 'vMenuDig');
        Menus["vMenuDig"] = vMenuDig
        Menus["vMenuDig"].alineacion = 'centro';
        Menus["vMenuDig"].estilo = 'A';

        vMenuDig.loadImage("nuevo", "/FW/image/icons/file.png");

        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Asignaciones</Desc></MenuItem>")
        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abrirAbm()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuDig.MostrarMenu()
    </script>
<table id="tablaCont" style="width:100%" class="tb1">   
    <tr>
        <td style="width:80%">
            <table id="ori_des"  style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:center">Tipo Documento</td>
                    <td style="text-align:center">Nro Documento</td>
                    <td style="text-align:center">CUIT-CUIL</td>
                    <td style="text-align:center">Razón Social</td>
                    <td style="text-align:center">Cod Afinidad</td>
                </tr>
                <tr>
                    <td>
                        <script>
                            campos_defs.add('tipdoc', {
                                enDB: true,
                                nro_campo_tipo: 2,
                            })              
                        </script>
                    </td>
                    <td>
                        <input id="nrodoc" style="width:100%" type="text" maxlength="9"/>
                        <script>
                            $("nrodoc").addEventListener("keypress", function (evt) {
                                if (evt.which != 8 && evt.which != 0 && evt.which < 48 || evt.which > 57)
                                {
                                    evt.preventDefault();
                                }
                            });
                        </script>                    </td>
                    <td>
                        <input id="nrocuil" style="width:100%" type="text" maxlength="11"/>
                    </td>
                    <td>
                        <input id="razonsocial" style="width:100%" type="text" />
                    </td>
                    <td>
                        <script>
                            campos_defs.add('codafinidad', {
                                enDB: true,
                                nro_campo_tipo: 2,
                            })
                        </script>
                    </td>
                </tr>
            </table>
        </td>
        <td>
            <table id=""  style="width:100%" class="tb1">
                <tr>
                    <td>
                        <div id="divBuscar"></div>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
    <iframe id="listaAsignaciones" name="listaAsignaciones" style="width: 100%; height: 500px; overflow:auto; border:none; background-color:white"></iframe>
</body>
</html>
