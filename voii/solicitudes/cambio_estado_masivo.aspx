<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim nro_sol_array As String = nvFW.nvUtiles.obtenerValor("nro_sol_array", "")
    Dim sol_estado As String = nvFW.nvUtiles.obtenerValor("sol_estado", "")
    Dim nro_circuito As String = nvFW.nvUtiles.obtenerValor("nro_circuito", "")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Me.contents("sol_estado") = sol_estado
    Me.contents("nro_sol_array") = nro_sol_array

    If (modo = "E") Then 'Cambiar estado

        Dim estado As String = nvFW.nvUtiles.obtenerValor("estado", "")
        Dim estadoPrev As String = nvFW.nvUtiles.obtenerValor("estadoPrev", "")
        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
        'CARGA PARA TRANSFERENCIA
        nro_sol_array = nvFW.nvUtiles.obtenerValor("solicitudes", "")
        Dim array() As String = Split(nro_sol_array, ",")

        Dim err As New tError()

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sol_cambio_estado_masivo", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
        cmd.addParameter("@estado", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, , estado)
        cmd.addParameter("@estadoPrev", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, , estadoPrev)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()
            err = New nvFW.tError(rs)

            err.numError = rs.Fields("numError").Value
            err.mensaje = rs.Fields("mensaje").Value

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            If err.numError = 0 Then

                Dim strSQL As String = "select nro_sol_tipo from sol_tipos where nro_circuito = " & nro_circuito
                rs = nvDBUtiles.DBOpenRecordset(strSQL)

                Dim nro_sol_tipo As String = ""
                If Not rs.EOF Then
                    nro_sol_tipo = rs.Fields("nro_sol_tipo").Value
                Else
                    err.numError = "400"
                    err.titulo = "Error en la acción"
                    err.mensaje = "El circuito seleccionado no está asociado a un tipo de solicitud"
                End If
                nvFW.nvDBUtiles.DBCloseRecordset(rs)


                If nro_sol_tipo <> "" Then


                    'Identificar en la pizarra si hay transferencia
                    Dim strArray() As String = {nro_sol_tipo, estado}
                    Dim nro_transferencia As String = nvFW.Pizarra.value("proc_solicitud_estado_change", strArray) 'Agregar el tipo de solicitud
                    'Dim id_transferencia = nro_transferencia

                    If nro_transferencia <> "" Then

                        'For Each element In array



                        'Ejecutar la transferencia en segundo plano

                        Dim nT As New System.Threading.Thread(Sub(objeto As Object())

                                                                  nvFW.nvApp._nvApp_ThreadStatic = objeto.GetValue(4)
                                                                  Dim tx As New nvFW.nvTransferencia.tTransfererncia
                                                                  tx.cargar(objeto.GetValue(1))
                                                                  Dim estadoPrevINT As String = objeto.GetValue(2)
                                                                  Dim estadoINT As String = objeto.GetValue(3)
                                                                  Dim nro_sol_arrayINT() As String = objeto.GetValue(0)
                                                                  For Each element In nro_sol_arrayINT

                                                                      'Cargas la transferencia


                                                                      tx.limpiar()
                                                                      tx.param("sol_estado_previo")("valor") = estadoPrevINT
                                                                      tx.param("sol_estado_nuevo")("valor") = estadoINT
                                                                      tx.param("nro_sol")("valor") = element



                                                                      err = tx.ejecutar()
                                                                  Next

                                                              End Sub)
                        nT.Start(New Object() {array, nro_transferencia, estadoPrev, estado, nvApp})

                        'Next
                    End If
                End If
            End If

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = 105
            err.titulo = "Error"
            err.mensaje = "No se pudo completar el proceso"
        End Try
        err.response()
    End If

    Me.contents("filtroSolicitud") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud'><campos>*</campos><orden></orden><filtro><nro_sol type='in'>" + nro_sol_array + "</nro_sol></filtro></select></criterio>")

    Me.contents("solEstadosTransicionXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='ver_cire_estado_detalle'><campos>estado_origen, estado, sol_estado_desc</campos><orden>sol_estado_desc</orden><filtro><nro_circuito type='igual'>" & nro_circuito & "</nro_circuito><vigente type='igual'>1</vigente></filtro></select></criterio>")

    Me.contents("solEstadosXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='sol_estados'><campos>sol_estado, sol_estado_desc, estilo as sol_estado_estilo</campos></select></criterio>")

    Me.contents("nro_circuito") = nro_circuito


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Cambio estado masivo</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        /*.divBoton {
            margin: auto;
            max-width: 200px;
            align-content: center;
        }*/
        .divBotonItem {
            margin: auto;
            margin-top: 1px;
            max-width: 200px;
            align-content: center;
        }

        .divBotonRow {
            /*margin: auto;*/
            /*max-width: 200px;*/
            align-content: center;
            display: -webkit-flex;
            display: -moz-flex;
            display: flex;
            -webkit-flex-direction: row;
            -moz-flex-direction: row;
            flex-direction: row;
            align-items: center;
            background-color: white;
            /*align-items: flex-start;*/
        }

        .divBotonColumn {
            /*margin: auto;*/
            /*max-width: 200px;*/
            align-content: center;
            display: -webkit-flex;
            display: -moz-flex;
            display: flex;
            -webkit-flex-direction: column-reverse;
            -moz-flex-direction: row;
            flex-direction: column-reverse;
            align-items: center;
            background-color: white;
            /*align-items: flex-start;*/
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var mediaAdaptive = window.matchMedia("(max-width: 400px)")
        //var botones = [];
        //var claseBtn = '';

        var ventana = nvFW.getMyWindow()
        //if (ventana) {
        if (ventana.options.userData == undefined)
            ventana.options.userData = {}

        ventana.options.userData.hay_modificacion = false
        //}
        var sol_estado;
        var solicitudes;
        var cant_sol;

        function window_onload() {

            sol_estado = nvFW.pageContents.sol_estado;
            solicitudes = nvFW.pageContents.nro_sol_array.split(",");
            mostrarListButtonEstados();
            buscar_solicitud();
            window_onresize();

        }

        function window_onresize() {

            var dif = Prototype.Browser.IE ? 5 : 2;
            if (mediaAdaptive.matches) {
                $('cambioEstados').className = 'divBotonColumn';

                $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('tbCambioEstados').getHeight() - $('tbCabecera').getHeight() - $('cantFilas').getHeight() + 'px' });

            }
            else {
                $('cambioEstados').className = 'divBotonRow';

                $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('tbCambioEstados').getHeight() - $('tbCabecera').getHeight() - $('cantFilas').getHeight() + 'px' });

            }


        }

        function buscar_solicitud() {

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroSolicitud,
                filtroWhere: "<criterio><select expire_minutes='1' cacheControl='Session'><filtro></filtro></select></criterio>",
                path_xsl: 'report\\Plantillas\\ModSolicitud\\html_solicitudes_cambioEstado.xsl',
                salida_tipo: 'adjunto',
                ContentType: 'text/html',
                formTarget: 'frameDatos',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Buscando solicitudes...',
                cls_contenedor: 'frameDatos',
                funComplete: function (response, parseError) {
                    document.getElementById('tdCant').innerHTML = 'Solicitudes: <b>' + cant_sol + '</b>';
                }

            });

        }

        function exportar_solicitud() {


            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroSolicitud
                , filtroWhere: "<criterio><select><filtro></filtro></select></criterio>"
                , path_xsl: "report\\EXCEL_base.xsl"
                , salida_tipo: "adjunto"
                , ContentType: "application/vnd.ms-excel"
                , filename: "Solicitudes.xls"
            });

        }

        function mostrarListButtonEstados() {
            var estadosRs = new tRS();
            estadosRs.open(nvFW.pageContents.solEstadosTransicionXML, "", "<estado_origen type='igual'>'" + sol_estado + "'</estado_origen><vigente type='igual'>1</vigente>");
            $('cambioEstados').innerHTML = "";
            if (estadosRs.recordcount > 0) {
                var vButtonEstados = {};
                while (!estadosRs.eof()) {

                    $('cambioEstados').insert('<div id="divEstado' + estadosRs.getdata(" estado") + '" style = "width: 100%" class="divBotonItem" ></div >')


                    vButtonEstados[estadosRs.position] = {};
                    vButtonEstados[estadosRs.position]["nombre"] = "Estado" + estadosRs.getdata("estado");
                    vButtonEstados[estadosRs.position]["etiqueta"] = estadosRs.getdata("sol_estado_desc");
                    vButtonEstados[estadosRs.position]["imagen"] = "play";
                    vButtonEstados[estadosRs.position]["onclick"] = "return CambiarEstado('" + estadosRs.getdata("estado") + "')";
                    estadosRs.movenext()
                }
                var vListButtonEstados = new tListButton(vButtonEstados, 'vListButtonEstados');
                vListButtonEstados.loadImage("play", '/FW/image/icons/play.png');
                vListButtonEstados.MostrarListButton()
            }
            else {
                $('cambioEstados').insert('<tr><td>&nbsp;No posee estados de transición disponibles.</td></tr>');
            }

        }

        function CambiarEstado(abreviacion) {

            var nuevoEstadoRs = new tRS();
            nuevoEstadoRs.open(nvFW.pageContents.solEstadosXML, "", "<sol_estado type='igual'>'" + abreviacion + "'</sol_estado>");
            if (!nuevoEstadoRs.eof()) {

                var strXML = "<?xml version='1.0' encoding='ISO-8859-1'?><solicitudes>";
                for (var i = 0; i < solicitudes.length; i++) {
                    strXML += "<solicitud nro_sol='" + solicitudes[i] + "'></solicitud>"

                }
                strXML += "</solicitudes>";

                var ventana = nvFW.getMyWindow()
                var strCant = 'solicitudes';
                if (cant_sol == 1)
                    strCant = 'solicitud';
                nvFW.confirm("¿Confirma cambiar " + cant_sol + " " + strCant + " a estado <b>" + nuevoEstadoRs.getdata("sol_estado_desc") + "</b>?",
                    {
                        okLabel: 'Si',
                        cancelLabel: 'No',
                        onOk: function (win) {

                            nvFW.error_ajax_request('cambio_estado_masivo.aspx', {
                                parameters: { modo: 'E', strXML: strXML, estado: abreviacion, estadoPrev: sol_estado, solicitudes, nro_circuito: nvFW.pageContents.nro_circuito },
                                onSuccess: function (err, transport) {

                                    if (err.numError == 0) {

                                        win.options.userData = { res: 'ok' }

                                        if (ventana) {
                                            ventana.options.userData.hay_modificacion = true
                                            ventana.close()
                                        }
                                    }

                                },
                                error_alert: true
                            });

                            win.close();

                        },
                        onCancel: function (win) {
                            win.close();
                        }
                    })
            }

        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style='width: 100%; height: 100%; overflow: hidden;' onkeypress="return key_Buscar()">

    <table class="tb1" id="tbCabecera">
        <tr>
            <td colspan="2">
                <div id="divMenu"></div>
            </td>
            <script type="text/javascript">


                var vMenuModulos = new tMenu('divMenu', 'vMenuModulos');

                Menus["vMenuModulos"] = vMenuModulos
                Menus["vMenuModulos"].alineacion = 'centro';
                Menus["vMenuModulos"].estilo = 'A';

                vMenuModulos.loadImage("excel", '/FW/image/icons/excel.png');

                Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Cambio de Estado</Desc></MenuItem>")
                Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportar_solicitud()</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenuModulos.MostrarMenu()


            </script>
        </tr>
    </table>

    <iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>

    <table class="tb1" id="cantFilas">
        <tr class="tbLabel0" align="right">
            <td id="tdCant" style="text-align: right; padding-right: 2%"></td>
        </tr>
    </table>

    <table class="tb1" id="tbCambioEstados">
        <tr style="height: 26px">
            <td>
                <div id="cambioEstados">
                </div>
            </td>
        </tr>
    </table>
    <%--<table id="cambioEstados" class="tb1">
        </table>--%>
</body>
</html>
