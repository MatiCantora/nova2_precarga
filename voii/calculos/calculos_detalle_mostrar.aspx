<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    'Stop
    Dim id_calc_det = obtenerValor("id_calc_det")
    Dim strXML = obtenerValor("strXML", "")
    Dim modo = obtenerValor("modo", "")
    Dim Err

    Me.contents("filtro_tipo_persona") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='tipo_persona'><campos>nro_tipo_persona as id, tipo_persona as [campo] </campos><orden>[campo]</orden></select></criterio>")

    Me.contents("filtro_calculo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calculos'><campos>id_calculo as id, calculo as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>")
    '<fe_hasta type='isnull'></fe_hasta>

    Me.contents("filtro_ver_calc_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_cal_cab_pers_calc'><campos> id_calc_cab, calc_cab, nro_tipo_persona, tipo_persona, convert(varchar, fe_desde, 103), convert(varchar, fe_hasta, 103), id_calculo, calculo </campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_ver_calc_det") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_calc_cab'><campos>id_calc_det, calc_det, convert(varchar, fe_desde_det, 103) as fe_desde_det, convert(varchar, fe_hasta_det, 103) fe_hasta_det, calc_id_tipo, parametro, id_tipo </campos><orden></orden><filtro></filtro></select></criterio>")



    Me.contents("filtro_calc_var_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_var_tipos'><campos>distinct id_calc_var_tipo as id, calc_var_tipo as [campo] </campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_calc_acumuladores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_acumuladores'><campos>distinct nro_calc_acum as id, calc_acum as [campo] </campos><orden>[campo]</orden></select></criterio>")


    Me.contents("filtro_calc_det") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_det'><campos>id_calc_det as id, calc_det as [campo] </campos><orden>id_calc_det</orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_calc_cab2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_cab'><campos>nro_perfil,nro_empresa</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_ver_calc_valores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_calc_valores'><campos>top 1 id_liquidacion</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_ver_calc_det_variables") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_calc_det_variables'><campos>id_calc_var,calc_variable,calculo,tipo_variable,id_calc_var_tipo,calc_var_tipo,nro_calc_acum,calc_acum,case when calc_variable = 'monto_comision' then SUBSTRING (prioridad ,2 , LEN(prioridad)) else prioridad end as prioridad</campos><orden>prioridad</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_calc_cab3") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_cab'><campos>id_calc_cab</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("perfiles") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='perfiles'><campos> distinct nro_perfil as id, perfil as [campo] </campos><filtro><NOT><nro_perfil type='in'>7</nro_perfil></NOT><nro_permiso type='sql'>dbo.rm_tiene_permiso('permisos_perfiles',nro_permiso) = 1</nro_permiso></filtro><orden>[campo]</orden></select></criterio>")

    Me.addPermisoGrupo("permisos_calculos")


    If (modo.ToUpper() = "M") Then
        Err = New tError()

        'Obtener Datos
        Try

            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "rm_calculo_detalle_abm"

            Dim Charset = "ISO-8859-1"
            Dim objStream = New ADODB.Stream
            objStream.Charset = Charset
            objStream.Mode = 3
            objStream.Type = 2
            objStream.Open()

            'escribir bytes en el  stream
            objStream.WriteText(strXML)
            objStream.Flush()

            'recuperar string desde el stream
            objStream.Position = 0
            objStream.Type = 1
            Dim BinaryData = objStream.Read()

            Dim param = Cmd.CreateParameter("strXML0", 205, 1, objStream.Size, BinaryData)
            Cmd.Parameters.Append(param)

            Dim rs = Cmd.Execute()
            If (Not rs.EOF) Then

                id_calc_det = rs.fields("id_calc_det").value
                Err.params("id_calc_det") = id_calc_det
                Err.numError = 0
                Err.mensaje = id_calc_det

            End If

        Catch e As Exception
            Err.parse_error_script(e)
        End Try
        Err.response()

    End If


%>

<html>
<head>
    <title>Cálculos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" language='javascript' src="/fw/script/utiles.js"></script>

    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var nvTargetWin = tnvTargetWin()
        if (!window.top.nvTargetWin)
            window.top.nvTargetWin = nvTargetWin
        else
            nvTargetWin = window.top.nvTargetWin

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return consultar_calculos_detalle()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", "/fw/image/icons/buscar.png")


        var win = nvFW.getMyWindow()
        var id_calc_det = '<%=id_calc_det %>'
        var Calculo = new Array()
        var Variables = new Array()
        var fecha = new Date()

        var id_calc_cab
        var cambio_acumulador = false

        function window_onload() {
            vListButton.MostrarListButton()

            //campos_defs.add('id_calculo', {
            //    despliega: 'abajo',
            //    enDB: false,
            //    target: 'td_id_calc_cab',
            //    nro_campo_tipo: 1,
            //    filtroXML: nvFW.pageContents.filtro_calculo,
            //    filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>"
            //})

            campos_defs.add("nro_tipo_persona", {
                target: 'td_nro_tipo_persona',
                enDB: false,
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_tipo_persona,
                filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>",
                onchange: function () {
                    //if (campos_defs.get_value("id_calculo") != '') {
                    //    campos_defs.set_value("id_calculo", "") }
                }
            })

            campos_defs.add('fe_desde', { enDB: false, nro_campo_tipo: 103, target: "td_fe_desde" })

            campos_defs.add('fe_hasta', { enDB: false, nro_campo_tipo: 103, target: "td_fe_hasta" })

            consultar_calculos_detalle()
            window_onresize()
        }

        function consultar_calculos_detalle() {
            var filtro = ""
            var nro_tipo_persona = campos_defs.get_value('nro_tipo_persona')
            //var id_calculo = campos_defs.get_value('id_calculo')

            if (nro_tipo_persona != "") filtro += "<nro_tipo_persona type='igual'>" + nro_tipo_persona + "</nro_tipo_persona>"

            //if (id_calculo != "") filtro += "<id_calculo type='igual'>" + id_calculo + "</id_calculo>"

            if ($('fe_desde').value != "")
                filtro += "<fe_desde type='mas'>convert(datetime,'" + $('fe_desde').value + "',103)</fe_desde>"

            if ($('fe_hasta').value != "")
                filtro += "<fe_hasta type='menor'>convert(datetime,'" + $('fe_hasta').value + "',103)+1</fe_hasta>"

            var filtroXML = nvFW.pageContents.filtro_ver_calc_cab

            var filtroWhere = "<criterio><select><campos>*</campos><filtro>" + filtro + "</filtro></select></criterio>"

            nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere: filtroWhere,
                path_xsl: 'report\\calculos\\HTML_calculos_mostrar.xsl',
                formTarget: 'frame_listado',
                nvFW_mantener_origen: true,
                bloq_contenedor: 'frame_listado',
                cls_contenedor: 'frame_listado'
            })
        }

        function calculo_detalle_nuevo(id_calc_cab) {
            var win = nvFW.createWindow({
                className: 'alphacube',
                url: '/voii/calculos/calculos_detalle_ABM.aspx?id_calc_det=' + 0 + '&id_calc_cab=' + id_calc_cab,
                title: '<b>Editar Detalle Cálculo</b>',
                resizable: true,
                height: 500,
                width: 1100,
                minimizable: true,
                maximizable: false,
                draggable: false,
                resizable: false,
                //onClose: function (win) {
                //    if (win.options.userData.hayModificacion)
                //        verDetalleCalculo(win.options.userData.id_calc_cab)
                //}
            })
            win.options.userData = { hayModificacion: false }
            win.showCenter(true)
        }

        function calculo_abm(id_calc_cab, calc_cab, fe_desde, fe_hasta, nro_tipo_persona, id_calculo) {
            win = nvFW.createWindow({
                className: 'alphacube',
                url: 'calculos_ABM.aspx',
                title: '<b>Calculo Definición ABM</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 350,
                onClose: function (win) {
                    if (win.options.userData.hayModificacion)
                        consultar_calculos_detalle()
                }
            });

            win.options.userData = { hayModificacion: false }
            win.options.userData.id_calc_cab = id_calc_cab
            win.options.userData.calc_cab = calc_cab
            win.options.userData.fe_desde = fe_desde
            win.options.userData.fe_hasta = fe_hasta
            win.options.userData.nro_tipo_persona = nro_tipo_persona
            win.options.userData.id_calculo = id_calculo

            win.showCenter(true)
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divCalculoDatos_h = $('divCalculoDatos').getHeight()
                var divMenuCalculos_h = $('divMenuCalculos').getHeight()
               
                $('frame_listado').setStyle({ 'height': body_h - divCalculoDatos_h - divMenuCalculos_h - dif })
            }
            catch (e) { }
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="calculos_comisiones_editar.aspx" method="post" name="form1" target="frmEnviar">
        <input type="hidden" id="nro_calc_pizarra" value='' />
        <div id="divMenuCalculos" style="width: 100%"></div>
            <script type="text/javascript" language="javascript">
                var DocumentMNG = new tDMOffLine;
                var vMenuCalculos = new tMenu('divMenuCalculos', 'vMenuCalculos');
                Menus["vMenuCalculos"] = vMenuCalculos
                Menus["vMenuCalculos"].alineacion = 'izquierda';
                Menus["vMenuCalculos"].estilo = 'A';

                vMenuCalculos.loadImage("nuevo", "/FW/image/icons/nueva.png");
                Menus["vMenuCalculos"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo Calculo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>calculo_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenuCalculos.MostrarMenu()
            </script>
        </div>
        <div id="divCalculoDatos">
            <table class="tb1" style="width:100%">
                <tr>
                    <td style="width:85%">
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td style="width: 35%; text-align: center"><b>Tipo Persona</b></td>
                                <%--<td style="width: 35%; text-align: center"><b>Cálculo</b></td>--%>
                                <td style="width: 15%; text-align: center"><b>Fe. Desde</b></td>
                                <td style="width: 15%; text-align: center"><b>Fe. Hasta</b></td>
                            </tr>
                            <tr>
                                <td style="width: 35%" id="td_nro_tipo_persona"></td>
                                <%--<td style="width: 35%" id="td_id_calc_cab"></td>--%>
                                <td style="width: 15%" id="td_fe_desde"></td>
                                <td style="width: 15%" id="td_fe_hasta"></td>
                            </tr>
                        </table>
                    </td>
                    <td style="width:15%">
                        <table class="tb1" style="width:100%">
                            <tr>
                                <td rowspan="2">
                                    <table style="width:100%">
                                        <tr>
                                            <td style="width:100%">
                                                <div id="divBuscar" ></div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <iframe style='width: 100%; height:100%; border-style:none' name='frame_listado' id='frame_listado' src='/fw/enBlanco.htm'></iframe>
    </form>
</body>
</html>
