<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Response.Expires = 0

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim observacion As String = nvFW.nvUtiles.obtenerValor("observacion", "")

    If modo = "" Then
        modo = "VA"
    End If

    If modo = "A" Then
        If strXML <> "" Then
            Dim err As New tError

            Try
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_pago_parametros_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app, , , , , , , )
                'cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML)
                cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

                Dim rs As ADODB.Recordset = cmd.Execute()

                'If Not rs.EOF Then
                err.numError = 0
                err.titulo = ""
                err.mensaje = ""
                'End If
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try

            err.response()
        End If
    End If

    '-----------------------------------------------------------------------------------
    ' Filtros encriptados
    '-----------------------------------------------------------------------------------
    Me.contents("filtro_onLoad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_registro_detalle_parametros'><campos>nro_credito, nro_pago_detalle, razon_social, nro_pago_concepto, pago_concepto, pago_tipo, importe_pago, importe_pago_detalle as importe_param, nro_pago_estado, pago_estados, observacion, nro_cheque</campos><orden>nro_credito, nro_pago_concepto, nro_pago_detalle</orden><filtro><nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='distinto'>3</nro_pago_estado></filtro></select></criterio>")
    Me.contents("filtro_imprimir") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden>nro_credito, nro_pago_concepto, nro_pago_detalle</orden><filtro><estado_envio type='igual'>'F'</estado_envio><nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='in'>1</nro_pago_estado><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    Me.contents("filtro_confirmarOk") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_registro_detalle_parametros'><campos>razon_social, importe_pago_detalle, nro_pago_estado</campos></select></criterio>")
    Me.contents("filtro_cargarEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_bj_cuentas_permisos'><campos>nro_bancoBCRA, cuenta, permiso_pagos_ejecutar, permiso_pagos_anular, permiso_pagos_seguimiento</campos><orden>cuenta</orden></select></criterio>")
%>
<html>
<head>
    <title>Pagos - Cheques</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win
        var inCredito
        var strError = ""
        var filtro_envio
        var nro_banco
        var chequera
        var filtro = ""
        var banco
        var cuenta
        var Parametros
        var fecha


        function window_onload() {
            win                = nvFW.getMyWindow()
            Parametros         = win.options.userData.Parametros
            filtro             = "<nro_pago_registro type='in'>" + Parametros["nro_pagos_registros"] + "</nro_pago_registro>"
            nro_banco          = Parametros["nro_banco"]
            banco              = Parametros["banco"]
            cuenta             = Parametros["cuenta"]
            chequera           = Parametros["chequera"]
            var cheque_desde   = Parametros["cheque_desde"]
            $('empresa').value = Parametros["empresa"]
            cheque_desde_01    = parseFloat(cheque_desde)

            var strHTML = ""
            strHTML += "<table class='tb1'><tr class='tbLabel'>"
            strHTML += "<tr class='tbLabel'>"
            strHTML += "<td style='width: 25%'><b>Banco</b></td><td style='width:25%'><b>Cuenta</b></td><td style='width:25%'><b>Chequera</b></td><td style='width:25%'><b>Nro. Cheque Desde:</b></td>"
            strHTML += "</tr>"
            strHTML += "<tr>"
            strHTML += "<td align='center'><b>" + banco + "</b></td><td align='center'><b>" + cuenta + "</b></td><td align='right'><b>" + chequera + "</b></td><td align='right'><b>" + cheque_desde + "</b><input type='hidden' id='cheque_desde' name='cheque_desde' value='" + cheque_desde + "'></td>"
            strHTML += "</tr></table>"
            strHTML += "<input type='hidden' name='nro_banco_bcra' id='nro_banco_bcra' value=" + nro_banco + "/>"
            strHTML += "<input type='hidden' name='chequera' id='chequera' value='" + chequera + "'/>"
            strHTML += "<input type='hidden' name='cuenta' id='cuenta' value='" + cuenta + "'/>"

            $('divMostrar').insert({ top: strHTML })
            Cargar_Estados()

            if ($('modo').value == 'VA')
                $('modo').value = 'A'

            // Setear altura iFrame
            var body_h              = $$("body")[0].getHeight()
            var divMostrar_h        = $("divMostrar").getHeight()
            var tb_imprimirEstado_h = $("imprimirEstado").getHeight()

            $("ifrcheques").setStyle({ height: body_h - divMostrar_h - tb_imprimirEstado_h + "px" })

            nvFW.exportarReporte({
                //filtroXML: "<criterio><select vista='verPago_registro_detalle_parametros'><campos>nro_credito, nro_pago_detalle, razon_social, nro_pago_concepto, pago_concepto, pago_tipo, importe_pago, importe_pago_detalle as importe_param, " + cheque_desde_01 + " as cheque_desde, nro_pago_estado, pago_estados, observacion, nro_cheque</campos><orden>nro_credito, nro_pago_concepto, nro_pago_detalle</orden><filtro>" + filtro + "<nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='distinto'>3</nro_pago_estado></filtro></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_onLoad,
                filtroWhere: "<criterio><select><campos>*, " + cheque_desde_01 + " AS cheque_desde</campos><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: "report/wrp_pg_registro/HTML_pagos_impresion.xsl",
                formTarget: 'ifrcheques',
                nvFW_mantener_origen: true,
                cls_contenedor: 'ifrcheques',
                cls_contenedor_msg: ' ',
                bloq_contenedor: 'ifrcheques',
                bloq_msg: "Cargando..."
            })
        }


        function getStrTime() {
            var fecha = new Date()

            var year      = fecha.getUTCFullYear().toString()
            var imonth    = fecha.getUTCMonth() + 1; // Meses del 1 al 12
            var month     = imonth < 10 ? "0" + imonth : imonth
            var idia      = fecha.getUTCDate()
            var day       = idia < 10 ? "0" + idia : idia
            var ihoras    = fecha.getHours()
            var horas     = ihoras < 10 ? "0" + ihoras : ihoras
            var iminutos  = fecha.getMinutes()
            var minutos   = iminutos < 10 ? "0" + iminutos : iminutos
            var isegundos = fecha.getSeconds()
            var segundos  = isegundos < 10 ? "0" + isegundos : isegundos
            var milesimas = fecha.getMilliseconds()

            return year + month + day + horas + minutos + segundos + milesimas
        }


        function Imprimir() {
            if (permiso_pagos_ejecutar == 'True') {
                switch (nro_banco) {
                    // Banco: Santa Fe
                    case '330':
                        // Chequera de Rosario
                        if (chequera == '67366/08') {
                            nvFW.mostrarReporte({
                                //filtroXML: "<criterio><select vista='wrp_verpg_registro'><campos>*</campos><orden>nro_credito, nro_pago_concepto, nro_pago_detalle</orden><filtro>" + filtro + "<estado_envio type='igual'>'F'</estado_envio><nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='in'>1</nro_pago_estado><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>",
                                filtroXML: nvFW.pageContents.filtro_imprimir,
                                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                                report_name: "report\\wrp_verpg_registro\\CHEQUE_STAFE_ROSARIO.rpt",
                                salida_tipo: "adjunto",
                                formTarget: "_blank",
                                name: "cheque.pdf",
                                filename: "cheque_" + getStrTime() + ".pdf"
                            })
                        }
                        else {
                            nvFW.mostrarReporte({
                                filtroXML: nvFW.pageContents.filtro_imprimir,
                                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                                report_name: "report\\wrp_verpg_registro\\CHEQUE_STAFE.rpt",
                                salida_tipo: "adjunto",
                                formTarget: "_blank",
                                name: "cheque.pdf",
                                filename: "cheque_" + getStrTime() + ".pdf"
                            })
                        }
                        break

                    // Banco: Berza
                    case '59':
                        nvFW.mostrarReporte({
                            filtroXML: nvFW.pageContents.filtro_imprimir,
                            filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                            report_name: "report/wrp_verpg_registro/CHEQUE_BERZA.rpt",
                            salida_tipo: "adjunto",
                            formTarget: "_blank",
                            name: "cheque.pdf",
                            filename: "cheque_" + getStrTime() + ".pdf"
                        })
                        break

                    // Banco: Suquia
                    case '255':
                        nvFW.mostrarReporte({
                            filtroXML: nvFW.pageContents.filtro_imprimir,
                            filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                            report_name: "report/wrp_verpg_registro/CHEQUE_SUQUIA.rpt",
                            salida_tipo: "crystal",
                            formTarget: "_blank",
                            name: "cheque.pdf",
                            filename: "cheque_" + getStrTime() + ".pdf"
                        })
                        break

                    // Banco: Rio
                    case '25':
                        nvFW.mostrarReporte({
                            filtroXML: nvFW.pageContents.filtro_imprimir,
                            filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                            report_name: "report/wrp_verpg_registro/CHEQUE_RIO.rpt",
                            salida_tipo: "adjunto",
                            formTarget: "_blank",
                            name: "cheque.pdf",
                            filename: "cheque_" + getStrTime() + ".pdf"
                        })
                        break

                    // Banco: NACION
                    case '11':
                        nvFW.mostrarReporte({
                            filtroXML: nvFW.pageContents.filtro_imprimir,
                            filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                            report_name: "report/wrp_verpg_registro/CHEQUE_NACION.rpt",
                            salida_tipo: "adjunto",
                            formTarget: "_blank",
                            name: "cheque.pdf",
                            filename: "cheque_" + getStrTime() + ".pdf"
                        })
                        break

                    // Banco: BMR
                    case '65':
                        nvFW.mostrarReporte({
                            filtroXML: nvFW.pageContents.filtro_imprimir,
                            filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                            report_name: "report/wrp_verpg_registro/CHEQUE_BMR.rpt",
                            salida_tipo: "adjunto",
                            formTarget: "_blank",
                            name: "cheque.pdf",
                            filename: "cheque._" + getStrTime() + "pdf"
                        })
                        break

                    // Banco: Prueba
                    case '999':
                        nvFW.mostrarReporte({
                            filtroXML: nvFW.pageContents.filtro_imprimir,
                            filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                            report_name: "report/wrp_verpg_registro/CHEQUE_RIO.rpt",
                            salida_tipo: "adjunto",
                            formTarget: "_blank",
                            name: "cheque.pdf",
                            filename: "cheque_" + getStrTime() + ".pdf"
                        })
                        break
                }
            }
            else {
                alert('No posee permisos para la impresión. Consulte al Administrador')
                return
            }
        }


        var obs = ''


        function Confirmar() {
            
            var xmldato = ''
            // Armar fecha
            var mydate = new Date();
            var year   = mydate.getFullYear();
            var month  = mydate.getMonth() + 1;
            if (month < 10)
                month  = "0" + month;
            var daym   = mydate.getDate();
            if (daym < 10)
                daym   = "0" + daym;

            fecha = month + "/" + daym + "/" + year

            if ($('nro_pago_estado').value == '0') {
                alert('Debe seleccionar un estado.')
                $('nro_pago_estado').focus()
                return
            }
            else {
                if ($('nro_pago_estado').value == '3') {
                    var strHTML = ''
                    strHTML += "<table class='tb1' cellpadding='0' cellspacing='0'><tr>"
                    strHTML += "<td class='Tit1' style='width: 30%'><b>Observacion:</b></td>"
                    strHTML += "<td style='width: 70%'><input type='text' id='observacion' name='observacion' style='width: 100%; text-align: right;'/></td>"
                    strHTML += "</tr></table>"

                    nvFW.confirm(strHTML, {
                        title: '<b>Anular Pago - Observación</b>',
                        width: 500,
                        height: 100,
                        okLabel: "Aceptar",
                        cancelLabel: "Cancelar",
                        cancel: function (win) {
                            win.close()
                            return
                        },
                        ok: function (win) {
                            if ($('observacion').value = '') {
                                alert('Debe ingresar una observacion para anular un pago.')
                                win.close()
                            }
                            else {
                                obs = $('observacion').value
                                Confirmar_OK()
                                win.close()
                            }
                        }
                    });
                }
                else
                    Confirmar_OK()
            }
        }


        var Parametros_pagos = []


        function Confirmar_OK() {
            var xmldato = ""

            for (j in Parametros_pagos) {
                if (typeof (Parametros_pagos[j]) != 'function') {
                    if (xmldato == '')
                        xmldato = "<?xml version='1.0' encoding='ISO-8859-1'?><pago_registro>"
                    
                    var nro_pago_detalle = Parametros_pagos[j]['nro_pago_detalle']
                    var nro_pago_estado  = $('nro_pago_estado').value
                    var rs = new tRS();

                    //rs.open("<criterio><select vista='verPago_registro_detalle_parametros'><campos>razon_social, importe_pago_detalle, nro_pago_estado</campos><orden></orden><grupo></grupo><filtro><nro_pago_detalle type='igual'>" + nro_pago_detalle + "</nro_pago_detalle><nro_pago_estado type='distinto'>" + nro_pago_estado + "</nro_pago_estado></filtro></select></criterio>")
                    rs.open({
                        filtroXML: nvFW.pageContents.filtro_confirmarOk,
                        filtroWhere: "<criterio><select><filtro><nro_pago_detalle type='igual'>" + nro_pago_detalle + "</nro_pago_detalle><nro_pago_estado type='distinto'>" + nro_pago_estado + "</nro_pago_estado></filtro></select></criterio>"
                    })
                    
                    if (!rs.eof()) {
                        var razon_social           = rs.getdata('razon_social').replace("&", "&#38;").replace("'", "&#39;")
                        var importe                = rs.getdata('importe_pago_detalle')
                        var chequera               = $('chequera').value
                        var cuenta                 = $('cuenta').value
                        var empresa                = $('empresa').value
                        var nro_banco_bcra         = $('nro_banco_bcra').value
                        var nro_cheque             = Parametros_pagos[j]['nro_cheque']
                        var nro_pago_estado_actual = rs.getdata('nro_pago_estado')

                        xmldato += "<pago_registro_detalle nro_pago_detalle='" + nro_pago_detalle + "' nro_pago_estado='" + nro_pago_estado + "' nro_pago_tipo='6' observacion='" + (obs != undefined? obs : "") + "'>"
                        
                        if ($('nro_pago_estado').value == '4' && nro_pago_estado_actual == 1) {
                            xmldato += "<pago_parametro parametro='chequera' valor='" + chequera + "'/>"
                            xmldato += "<pago_parametro parametro='cuenta' valor='" + cuenta + "'/>"
                            xmldato += "<pago_parametro parametro='empresa' valor='" + empresa + "'/>"
                            xmldato += "<pago_parametro parametro='fe_impresion' valor='" + fecha + "'/>"
                            xmldato += "<pago_parametro parametro='importe' valor='" + importe + "'/>"
                            xmldato += "<pago_parametro parametro='nro_banco_bcra' valor='" + nro_banco_bcra + "'/>"
                            xmldato += "<pago_parametro parametro='nro_cheque' valor='" + nro_cheque + "'/>"
                            xmldato += "<pago_parametro parametro='razon_social' valor='" + razon_social + "'/>"
                        }

                        xmldato += "</pago_registro_detalle>"
                    }
                    //rs.close()
                }
            }

            if (xmldato == '')
                alert("No ha seleccionado ningun Pago")
            else {
                xmldato += "</pago_registro>"
                $('modo').value = 'A'

                nvFW.error_ajax_request('Pagos_distribucion_imprimir.aspx', {
                    parameters: { 
                        modo: $('modo').value,
                        strXML: xmldato
                    },
                    onSuccess: function (err, transport) {
                        $('numError').value = err.numError
                        
                        if ($('numError').value == 0) {
                            var win = nvFW.getMyWindow()
                            win.close()
                        }
                    }
                })
            }
        }


        var permiso_pagos_ejecutar
        var permiso_pagos_consulta
        var permiso_pagos_anular
        var permiso_pagos_seguimiento


        function Cargar_Estados() {
            var rs = new tRS();
            $('nro_pago_estado').options.length = 0
            $('nro_pago_estado').insert(new Element('option', { value: '0' }).update('Seleccione un Estado...'))
            
            //rs.open("<criterio><select vista='ver_bj_cuentas_permisos'><campos>nro_bancoBCRA, cuenta, permiso_pagos_ejecutar, permiso_pagos_anular, permiso_pagos_seguimiento</campos><orden>cuenta</orden><grupo></grupo><filtro><nro_bancoBCRA type='igual'>" + nro_banco + "</nro_bancoBCRA><cuenta type='like'>" + cuenta + "</cuenta></filtro></select></criterio>")
            rs.open({
                filtroXML: nvFW.pageContents.filtro_cargarEstados,
                filtroWhere: "<criterio><select><filtro><nro_bancoBCRA type='igual'>" + nro_banco + "</nro_bancoBCRA><cuenta type='like'>" + cuenta + "</cuenta></filtro></select></criterio>"
            })
            
            if (!rs.eof()) {
                permiso_pagos_ejecutar = rs.getdata('permiso_pagos_ejecutar')
                if (permiso_pagos_ejecutar == 'True') {
                    $('nro_pago_estado').insert(new Element('option', { value: '1' }).update('Pendiente'))
                    $('nro_pago_estado').insert(new Element('option', { value: '4' }).update('Emitido'))
                }

                permiso_pagos_anular = rs.getdata('permiso_pagos_anular')
                if (permiso_pagos_anular == 'True')
                    $('nro_pago_estado').insert(new Element('option', { value: '3' }).update('Anulado'))

                permiso_pagos_seguimiento = rs.getdata('permiso_pagos_seguimiento')
                if (permiso_pagos_seguimiento == 'True') {
                    $('nro_pago_estado').insert(new Element('option', { value: '2' }).update('Pagado'))
                    $('nro_pago_estado').insert(new Element('option', { value: '5' }).update('Enviado'))
                    $('nro_pago_estado').insert(new Element('option', { value: '6' }).update('Controlado'))
                }
            }

            $('nro_pago_estado').setStyle({ width: '100%' })
        }
    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <input type="hidden" name="empresa" id="empresa" value="" />
    <input type="hidden" name="modo" id="modo" value="<%= modo %>"/>
    <input type="hidden" name="strXML" id="strXML" value="" />
    <input type="hidden" name="observacion" id="observacion" value="" />
    <input type="hidden" name="numError" id="numError" />
    <input type="hidden" name="pagos_detalles" id="pagos_detalles" />

    <div id="divMostrar"></div>

    <div id="divdatos" visible="false"></div>
    
    <iframe name="ifrcheques" id="ifrcheques" style="height: 400px; width: 100%; border: none;" src="/FW/enBlanco.htm"></iframe>

    <table class="tb1" id="imprimirEstado">
        <tr class="tbLabel">
            <td style="width: 33.3333%">Impresión de Cheques</td>
            <td style="width: 33.3333%">Cambiar Estado</td>
            <td style="width: 33.3333%">-</td>
        </tr>
        <tr>
            <td><input type="button" value="Imprimir" style="width:100%" id="btn_Imprimir" name="btn_Imprimir" onclick="Imprimir()"/></td>
            <td><select id="nro_pago_estado" name="nro_pago_estado"></select></td>
            <td><input type="button" value="Cambiar Estado" style="width:100%" id="btn_Estado" name="btn_Estado" onclick="Confirmar()" /></td>
        </tr>
    </table>     
</body>
</html>
