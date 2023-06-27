<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Response.Expires = 0

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim pagos_detalles As String = nvFW.nvUtiles.obtenerValor("pagos_detalles", "")
    Dim nro_pago_estado As String = nvFW.nvUtiles.obtenerValor("nro_pago_estado", "")

    If modo = "" Then
        modo = "VA"
    End If

    If modo <> "VA" Then
        Dim err As New tError
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_pg_cambiar_estado", ADODB.CommandTypeEnum.adCmdStoredProc)
            ' Parametros del Procedimiento Almacenado
            cmd.addParameter("@nro_pago_detalles", ADODB.DataTypeEnum.adInteger, , , pagos_detalles)
            cmd.addParameter("@nro_pago_estado", ADODB.DataTypeEnum.adInteger, , , nro_pago_estado)
            cmd.addParameter("@fe_estado", ADODB.DataTypeEnum.adVarChar, , , DBNull.Value)
            cmd.addParameter("@modo", ADODB.DataTypeEnum.adVarChar, , , modo)

            cmd.Execute()
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try

        err.response()
    End If

    ' Filtros encriptados
    Me.contents("filtro_pagosEfectivo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_registro_detalle_parametros'><campos>nro_pago_detalle, ISNULL(nro_credito, '') AS nro_credito, razon_social, pago_concepto, pago_tipo, importe_pago, importe_pago_detalle AS importe_param, pago_estados</campos><orden>nro_credito</orden><filtro><nro_pago_registro type='in'>%param1%</nro_pago_registro><nro_pago_tipo type='in'>4</nro_pago_tipo><nro_pago_estado type='distinto'>3</nro_pago_estado></filtro></select></criterio>")
    Me.contents("filtro_cargarEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_estados'><campos>*</campos></select></criterio>")
%>
<html>
<head>
    <title>Pagos - Efectivo</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win


        function window_onload()
        {
            win = nvFW.getMyWindow()
            var Parametros = win.options.userData.Parametros
            //var filtro = "<nro_pago_registro type='in'>" + Parametros["nro_pagos_registros"] + "</nro_pago_registro>"

            window_onresize()

            nvFW.exportarReporte({
                //filtroXML: "<criterio><select vista='verPago_registro_detalle_parametros'><campos>nro_pago_detalle, isnull(nro_credito,'') as nro_credito, razon_social, pago_concepto, pago_tipo, importe_pago, importe_pago_detalle as importe_param, pago_estados</campos><orden>nro_credito</orden><filtro>" + filtro + "<nro_pago_tipo type='in'>4</nro_pago_tipo><nro_pago_estado type='distinto'>3</nro_pago_estado></filtro></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_pagosEfectivo,
                params: "<criterio><params param1='" + Parametros["nro_pagos_registros"] + "' /></criterio>",
                path_xsl: "report/wrp_pg_registro/HTML_pagos.xsl",
                formTarget: 'ifrefectivo',
                nvFW_mantener_origen: true,
                cls_contenedor: 'ifrefectivo',
                cls_contenedor_msg: " ",
                bloq_contenedor: 'ifrefectivo',
                bloq_msg: "Cargando..."
            })

            if ($('modo').value == 'VA')
                $('modo').value = 'A'
        }


        function Confirmar()
        {
            if ($('nro_pago_estado').value == -1)
            {
                alert('Debe seleccionar un estado.')
                $('nro_pago_estado').focus()
                return
            }

            if ($('pagos_detalles').value == '')
            {
                alert("No ha seleccionado ningun Pago")
                return
            }

            $('modo').value = 'A'
            
            nvFW.error_ajax_request('Pagos_distribucion_efectivo.aspx', {
                parameters: {
                    modo: $('modo').value,
                    nro_pago_estado: $('nro_pago_estado').value,
                    pagos_detalles: $('pagos_detalles').value
                },
                onSuccess: function (err) {
                    $('numError').value = err.numError

                    if ($('numError').value == 0)
                    {
                        var win = nvFW.getMyWindow()
                        win.close()
                    }
                }
            })
        }


        function Ejecutar_Forma_Pago()
        {
            if ($('pagos_detalles').value == '')
            {
                alert("No ha seleccionado ningun Pago")
                return
            }

            switch ($('cb_forma_pago').value)
            {
                // Cheque
                case 'CH':
                    $('modo').value = 'CH'

                    nvFW.error_ajax_request('Pagos_distribucion_efectivo.aspx', {
                        parameters: {
                            modo: $('modo').value,
                            nro_pago_estado: $('nro_pago_estado').value,
                            pagos_detalles: $('pagos_detalles').value
                        },
                        onSuccess: function (err) {
                            $('numError').value = err.numError

                            if ($('numError').value == 0)
                            {
                                var win = nvFW.getMyWindow()
                                win.close()
                            }
                        }
                    })
                    break
            }
        }


        function forma_pago_onchange() {}


        function window_onresize()
        {
            try
            {
                var hBody = $$("BODY")[0].getHeight()
                var hTbEfectivo = $("tbEfectivo").getHeight()

                $("ifrefectivo").setStyle({ height: hBody - hTbEfectivo + "px" })
            }
            catch(e) {}
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <input type="hidden" name="modo" id="modo" value="<% = modo %>" />
    <input type="hidden" name="pagos_detalles" id="pagos_detalles" />
    <input type="hidden" name="pagos_detalles_todos" id="pagos_detalles_todos" />
    <input type="hidden" name="numError" id="numError" />

    <iframe name="ifrefectivo" id="ifrefectivo" style="height: 400px; width: 100%; border: none;" src="/FW/enBlanco.htm"></iframe>

    <table class="tb1" id="tbEfectivo">
        <tr class="tbLabel">
            <td style="width:50%" colspan="2">Cambio de Estado</td>
            <td style="width:50%" colspan="2">Forma de Pago</td>
        </tr>
        <tr>
            <td style="width:25%">
                <script>campos_defs.add("nro_pago_estado", { despliega: "arriba" })</script>
            </td>
            <td style="width:25%">
                <input type="button" style="width: 100%;" value="Cambiar Estado" onclick="Confirmar()" />
            </td>
            <td style="width:25%">
                <select name="cb_forma_pago" id="cb_forma_pago" style="width: 100%;">
                    <option value="CH">Cheque Bejerman</option>
                </select>
            </td>
            <td style="width:25%">
                <input type="button" name="btn_Ejecutar_Forma_Pago" id="btn_Ejecutar_Forma_Pago" value="Ejecutar" style="width: 100%;" onclick="Ejecutar_Forma_Pago()" />
            </td>
        </tr>
    </table>
</body>
</html>