<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Response.Expires = 0

    Dim fecha_server As String = DateTime.Now.ToString("o")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim pagos_detalles As String = nvFW.nvUtiles.obtenerValor("pagos_detalles", "")
    Dim nro_pago_estado As String = nvFW.nvUtiles.obtenerValor("nro_pago_estado", "")
    Dim fe_estado As String = nvFW.nvUtiles.obtenerValor("fe_estado", "")
    Dim chk_fe_estado As Boolean = nvFW.nvUtiles.obtenerValor("chk_fe_estado", "False")

    If modo = "" Then
        modo = "VA"
    End If

    If modo.ToUpper() = "A" Then

        Dim err As New tError
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_pg_cambiar_estado", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@nro_pago_detalles", ADODB.DataTypeEnum.adLongVarChar, , , pagos_detalles)
            cmd.addParameter("@nro_pago_estado", ADODB.DataTypeEnum.adInteger, , , nro_pago_estado)

            If chk_fe_estado = True AndAlso nvFW.nvApp.getInstance().operador.tienePermiso("permisos_pagos", 5) Then
                cmd.addParameter("@fe_estado", ADODB.DataTypeEnum.adDate, , , fe_estado)
            Else
                cmd.addParameter("@fe_estado", ADODB.DataTypeEnum.adDate, , , DBNull.Value)
            End If

            cmd.addParameter("@modo", ADODB.DataTypeEnum.adVarChar, , , modo)
            cmd.Execute()
        Catch ex As Exception
            'err.parse_error_script(ex)
            err.numError = -100
            err.mensaje = "Error al cambiar de estado."
            err.debug_desc = ex.Message
            err.debug_src = "Pagos_distribucion_deposito.aspx"
        End Try

        err.response()
    End If

    If modo.ToUpper() = "TRANSF" Then
        Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
        Dim id_transf As String = nvUtiles.obtenerValor("id_transf", "")

        Dim err As New tError
        Dim tTransferencia As New nvTransferencia.tTransfererncia

        Try
            'Dim id_transferencia As Integer = CType(nvUtiles.getParametroValor("get_id_transf_productos_yacare"), Integer)

            tTransferencia.cargar(id_transf)

            tTransferencia.param("strXML")("valor") = strXML

            tTransferencia.ejecutar()

            Dim error_count As Integer = 0

            For Each cola_det In tTransferencia.dets_run
                If cola_det.det.det_error.numError <> 0 Then error_count += 1
            Next

            '*************************************************************
            ' Si hay ERRORES => salir con excepción
            '*************************************************************
            If error_count > 0 Then
                Throw New Exception("Error en transferencia (" & error_count & ")")
            End If

            '*************************************************************
            ' Si hay mensaje de error => salir con excepción
            '*************************************************************
            Dim msg_error As String = tTransferencia.param("msg_error")("valor")
            If msg_error.ToUpper() <> "" Then
                err.numError = -1
                Throw New Exception("<b>Error al ejecutar forma de pago.</b>")
            End If

        Catch ex As Exception
            If err.numError <> -1 Then
                err.parse_error_script(ex)
                err.mensaje = "Error al ejecutar forma de pago."
            Else
                err.mensaje = ex.Message
            End If
        End Try
        err.response()
    End If

    Me.addPermisoGrupo("permisos_pagos")

    Me.contents("filtro_verPago_registro_detalle_parametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_registro_detalle_parametros'><campos>nro_pago_detalle, ISNULL(nro_credito, '') AS nro_credito, razon_social, nro_pago_concepto, pago_concepto, nro_pago_tipo, pago_tipo, importe_pago, importe_pago_detalle AS importe_param, pago_estados, fe_estado</campos><orden>nro_credito</orden><filtro><nro_pago_tipo type='in'>1</nro_pago_tipo><nro_pago_estado type='distinto'>3</nro_pago_estado></filtro></select></criterio>")
    Me.contents("filtro_pago_estados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_estados'><campos>*</campos></select></criterio>")
    Me.contents("filtro_generarArchivo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_PG_Registro'><campos>nro_pago_detalle, razon_social, cuit, dbo.rm_getParametroPago(nro_pago_detalle, 'nro_cuenta') AS cbu, 1 AS nro_liquidacion, GETDATE() AS fe_pago, importe_pago, 0 AS sucursal_rio, 0 AS tipo_cuenta_rio, 0 AS numero_cuenta_rio</campos><orden>nro_credito</orden><filtro><nro_pago_tipo type='igual'>1</nro_pago_tipo><tipo_cuenta type='igual'>2</tipo_cuenta><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    Me.contents("filtro_formaPagoDNBSF") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_verpg_registro'><campos>*</campos><filtro><nro_pago_estado type='igual'>1</nro_pago_estado><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio><NOT><nro_envio_ref type='in'>646</nro_envio_ref></NOT><estado_envio type='igual'>'F'</estado_envio></filtro></select></criterio>")
    Me.contents("filtro_formaPagoTR") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_PG_Registro'><campos>nro_pago_detalle, razon_social, cuit, dbo.rm_getParametroPago(nro_pago_detalle, 'nro_cuenta') AS cbu, 1 AS nro_liquidacion, GETDATE() AS fe_pago, importe_pago, 0 AS sucursal_rio, 0 AS tipo_cuenta_rio, 0 AS numero_cuenta_rio</campos><orden>nro_credito</orden><filtro><nro_pago_tipo type='igual'>1</nro_pago_tipo><tipo_cuenta type='igual'>2</tipo_cuenta><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>")
    Me.contents("filtro_formaPagoInterbanking") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_registro_detalle'><campos>nro_pago_detalle</campos></select></criterio>")
    Me.contents("filtro_formaPagoInterbanking2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista=''><campos>dbo.interb_ultima_actualizacion_str('%param1%') as ultima_actualizacion</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_pg_formas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPiz_pago_forma'><campos>pago_forma as id, pago_forma_desc as campo, nro_interbanking, id_transf</campos><filtro><vigente type='igual'>1</vigente></filtro><orden>campo</orden></select></criterio>")
%>
<html>
<head>
    <title>Pagos - Depósitos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win
        var inCredito
        var strError = ""
        var filtro_envio
        var filtro_credito
        var nro_banco
        var fecha_hoy


        function window_onload() {
            //Cargar_Estados()
            win = nvFW.getMyWindow()
            fecha_hoy = FechaToSTR(new Date($('fecha_server').value))
            $('fe_estado').value = fecha_hoy

            campos_defs.habilitar('fe_estado', false)

            //if ((permisos_pagos & 16) == 0)
            if (nvFW.tienePermiso("permisos_pagos", 5))    // 5: Editar fecha estado en depositos
                $('chk_fe_estado').disabled = true

            var Parametros = win.options.userData.Parametros
            var nro_pagos_registros = Parametros["nro_pagos_registros"]
            filtro_envio = Parametros["filtro_envios"]

            if (nro_pagos_registros != '')
                var filtro = "<nro_pago_registro type='in'>" + nro_pagos_registros + "</nro_pago_registro>"
            else
                return

            nro_banco = Parametros["nro_banco"]
            var banco = Parametros["banco"]
            var cuenta = Parametros["cuenta"]
            var chequera = Parametros["chequera"]
            var cheque_desde = Parametros["cheque_desde"]
            var cheque_desde_01 = cheque_desde - 1

            //if ((permisos_pagos & 8) > 0)
            if (nvFW.tienePermiso("permisos_pagos", 4))     // 4: Editar Estado importe en mano con deposito
                permiso_pago = 1
            else
                permiso_pago = 0

            window_onresize()

            //var filtroXML = "<criterio><select vista='verPago_registro_detalle_parametros'><campos>nro_pago_detalle, isnull(nro_credito,'') as nro_credito, razon_social, nro_pago_concepto, pago_concepto, nro_pago_tipo, pago_tipo, importe_pago, importe_pago_detalle as importe_param, pago_estados,fe_estado, " + permiso_pago + " as permiso_pago</campos><orden>nro_credito</orden><filtro>" + filtro + "<nro_pago_tipo type='in'>1</nro_pago_tipo><nro_pago_estado type='distinto'>3</nro_pago_estado></filtro></select></criterio>"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_verPago_registro_detalle_parametros,
                filtroWhere: "<criterio><select><campos>*, " + permiso_pago + " AS permiso_pago</campos><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: "report/wrp_pg_registro/HTML_pagos.xsl",
                formTarget: 'ifrdepositos',
                nvFW_mantener_origen: true,
                bloq_contenedor: 'ifrdepositos',
                cls_contenedor: 'ifrdepositos',
                cls_contenedor_msg: " ",
                funComplete: function () { forma_pago_onchange(); },
                bloq_msg: "Cargando..."
            })

            if ($('modo').value == 'VA')
                $('modo').value = 'A';

            $('cb_seleccionar')[0].selected = true
            $('cb_seleccionar').disabled = true

        }


        function Confirmar() {
            debugger
            if (campos_defs.get_value('nro_pago_estado') == '') {
                alert('Debe seleccionar un estado.')
                $('nro_pago_estado').focus()
                return
            }

            if ($('chk_fe_estado').checked == true)
                if ($('fe_estado').value == '') {
                    alert('La fecha de estado no puede ser vacia.')
                    return
                }

            if ($('pagos_detalles').value == '') {
                alert("No ha seleccionado ningun Pago")
                return
            }

            $('modo').value = 'A'

            nvFW.error_ajax_request('Pagos_distribucion_deposito.aspx', {
                parameters: {
                    modo: $('modo').value,
                    nro_pago_estado: $('nro_pago_estado').value,
                    chk_fe_estado: $('chk_fe_estado').checked,
                    fe_estado: $('fe_estado').value,
                    pagos_detalles: $('pagos_detalles').value
                },
                onSuccess: function (err) {
                    $('numError').value = err.numError

                    if ($('numError').value == 0) {
                        var win = nvFW.getMyWindow()
                        win.close()
                    }
                }
            })
        }


        function Invertir() {
            for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++) {
                if (ele.type == 'checkbox')
                    if (ele.name != 'all') {
                        if (ele.checked)
                            ele.checked = false;
                        else
                            ele.checked = true;
                    }
            }
        }


        function Imprimir() {
            var filtro_cheque = ''
            var Parametros = []
            var i

            for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++) {
                if (ele.type == 'checkbox')
                    if (ele.name != 'all') {
                        if (ele.checked) {
                            if (filtro_cheque == "")
                                filtro_cheque = ele.value
                            else
                                filtro_cheque = filtro_cheque + ", " + ele.value
                        }
                    }
            }

            if (filtro_cheque == '') {
                alert('No ha seleccionado ningún Pago para imprimir')
                return
            }
            else {
                Parametros["filtro_envio"] = filtro_cheque;
                Parametros["filtro_credito"] = "deposito";
                //@@@@ pasar funcion a nvFW.createWindow()

                var win = nvFW.createWindow({
                    url: "Pagos_distribucion_chequera.aspx",
                    title: "Pagos distribución - Chequera",
                    width: 800,
                    height: 170,
                    resizable: false,
                    destroyOnClose: true
                })

                win.options.userData = { Parametros: Parametros }
                win.showCenter()

                window.close()
            }
        }


        //function Cargar_Estados()
        //{
        //    $('nro_pago_estado').options.length = 0
        //    $('nro_pago_estado').insert(new Element('option', { value: '-1' }).update('Seleccione un Estado...'))

        //    var rs = new tRS()
        //    //rs.open("<criterio><select vista='pago_estados'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
        //    rs.open({ filtroXML: nvFW.pageContents.filtro_pago_estados })

        //    while (!rs.eof())
        //    {
        //        $('nro_pago_estado').insert(new Element('option', { value: rs.getdata('nro_pago_estado') }).update(rs.getdata('pago_estados')))
        //        rs.movenext()
        //    }

        //    $('nro_pago_estado').setStyle({ width: '100%' })
        //}


        function Generar_Nombre_Archivo() {
            var nombre_archivo
            var nombre_carpeta
            var camino
            var mydate = new Date()

            var year = mydate.getFullYear();

            var month = mydate.getMonth() + 1;
            if (month < 10)
                month = "0" + month;

            var daym = mydate.getDate();
            if (daym < 10)
                daym = "0" + daym;

            var hour = mydate.getHours();
            if (hour < 10)
                hour = "0" + hour

            var min = mydate.getMinutes();
            if (min < 10)
                min = "0" + min

            var sec = mydate.getSeconds();
            if (sec < 10)
                sec = "0" + sec

            nombre_carpeta = year + month
            nombre_archivo = "DEP-" + year + month + daym + "-" + hour + min + sec + ".txt"
            camino = nombre_carpeta + "/" + nombre_archivo

            return camino
        }


        function Generar_Archivo() {
            // PAG-aaaammdd-hhmiss.txt
            var camino
            var filtro_archivo = ''
            var Parametros = []

            for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++) {
                if (ele.type == 'checkbox')
                    if (ele.name != 'all') {
                        if (ele.checked) {
                            if (filtro_archivo == "")
                                filtro_archivo = ele.value
                            else
                                filtro_archivo += ", " + ele.value
                        }
                    }
            }

            if (filtro_archivo == '') {
                alert('No ha seleccionado ningún Pago')
                return
            }
            else {
                camino = Generar_Nombre_Archivo()
                //frmExportar.xsl_name.value = "XSL_pagos_Banco_RIO.xsl"
                //frmExportar.filtroXML.value = "<criterio><select vista='WRP_PG_Registro'><campos>nro_pago_detalle, razon_social, cuit, dbo.rm_getParametroPago(nro_pago_detalle, 'nro_cuenta') as cbu, 1 as nro_liquidacion, getDate() as fe_pago, importe_pago, 0 as sucursal_rio, 0 as tipo_cuenta_rio, 0 as numero_cuenta_rio</campos><orden>nro_credito</orden><filtro><nro_pago_detalle type='in'>" + filtro_archivo + "</nro_pago_detalle><nro_pago_tipo type='igual'>1</nro_pago_tipo><tipo_cuenta type='igual'>2</tipo_cuenta><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio></filtro></select></criterio>"
                //frmExportar.filtroWhere.value = ""
                //frmExportar.target.value = "FILE://directorio_archivos/Santander_Rio/" + camino

                //// enviamos el 'form' para generar el archivo

                //frmExportar.submit()

                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_generarArchivo,
                    filtroWhere: "<criterio><select><filtro><nro_pago_detalle type='in'>" + filtro_archivo + "</nro_pago_detalle></filtro></select></criterio>",
                    xsl_name: "XSL_pagos_Banco_RIO.xsl",
                    salida_tipo: "estado",
                    destinos: "FILE://directorio_archivos/Santander_Rio/" + camino,
                    metodo: "HTTPRequest",
                    funComplete: function (response, parseError) {
                        var oXML = new tXML()
                        var numError

                        if (oXML.loadXML(response.responseText))
                            numError = oXML.selectSingleNode("//@numError").nodeValue
                        else
                            numError = -1

                        window.open("directorio_archivos/Santander_Rio/" + camino)
                    }
                })
            }
        }


        function Ejecutar_Forma_Pago() {
            var filtro_deposito = $('pagos_detalles').value

            if (filtro_deposito == '') {
                alert('No ha seleccionado ningún pago. verifique...')
                return
            }

            var fecha = new Date()

            var year = fecha.getUTCFullYear().toString()
            var imonth = fecha.getUTCMonth() + 1; // Meses desde 1 a 12
            var month = imonth < 10 ? "0" + imonth : imonth
            var idia = fecha.getUTCDate()
            var day = idia < 10 ? "0" + idia : idia
            var ihoras = fecha.getHours()
            var horas = ihoras < 10 ? "0" + ihoras : ihoras
            var iminutos = fecha.getMinutes()
            var minutos = iminutos < 10 ? "0" + iminutos : iminutos
            var isegundos = fecha.getSeconds()
            var segundos = isegundos < 10 ? "0" + isegundos : isegundos
            var milesimas = fecha.getMilliseconds()

            var strtime = year + month + day + horas + minutos + segundos + milesimas

            var strXML = '';
            strXML = '<parametros><nro_interb_empresa>' + nro_interb_empresa + '</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>';

            //ejecutar transferencia
            nvFW.error_ajax_request('pagos_distribucion_deposito.aspx', {
                parameters: {
                    strXML: strXML,
                    id_transf: id_transf,
                    accion: 'TRANSF'
                },
                onComplete: function () {

                },
                onFailure: function () {

                }
            });

            //switch ($('cb_forma_pago').value)
            //{ //transferencia
            //    // Cheque
            //    case 'CH':
            //    // Depósito Chaco
            //    case 'DCH':
            //        alert('Módulo no Habilitado')
            //        break

            //    // Depósito NBSF
            //    case 'DNBSF':
            //        nvFW.mostrarReporte({
            //            //filtroXML: "<criterio><select vista='WRP_verpg_registro'><campos>*</campos><orden></orden><filtro><nro_pago_detalle type='in'>" + filtro_deposito + "</nro_pago_detalle><nro_pago_estado type='igual'>1</nro_pago_estado><esenvio type='SQL'>dbo.rm_esEnvio(nro_envio_gral) = 1</esenvio><NOT><nro_envio_ref type='in'>646</nro_envio_ref></NOT><estado_envio type='igual'>'F'</estado_envio></filtro></select></criterio>",
            //            filtroXML: nvFW.pageContents.filtro_formaPagoDNBSF,
            //            filtroWhere: "<criterio><select><filtro><nro_pago_detalle type='in'>" + filtro_deposito + "</nro_pago_detalle></filtro></select></criterio>",
            //            report_name: "Pago_Listado_Deposito_NBSF.rpt",
            //            salida_tipo: "adjunto",
            //            formTarget: "_blank",
            //            filename: "Listado_pagos_deposito_NBSF_" + strtime + ".pdf"
            //        })
            //        break

            //    case 'TIAMUS':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>X22856A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TIAMSDA':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B16386A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TICHACO':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B10886A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TICHACRA':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B51640A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TICHACO':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B10886A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TIMUPER':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>X62016A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TINEXFIN':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B47268A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TIITALA':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B50235A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TIAMPIV':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B14192A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TIURQUIZA':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>B14188A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TIAMEP':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>X38296A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TIACCCOM':
            //        var strXML = ''

            //        if (filtro_envio != '')
            //            filtro_envio = filtro_envio.replace(" type='in'", "")

            //        strXML = '<parametros><nro_interb_empresa>D27590A</nro_interb_empresa><nro_pagos_detalle>' + filtro_deposito + '</nro_pagos_detalle><nro_envio_gral>' + filtro_envio + '</nro_envio_gral></parametros>'
            //        ejecutar_transferencia_interbanking(strXML)
            //        break

            //    case 'TR':
            //        camino = Generar_Nombre_Archivo()

            //        nvFW.exportarReporte({
            //            filtroXML: nvFW.pageContents.filtro_formaPagoTR,
            //            filtroWhere: "<criterio><select><filtro><nro_pago_detalle type='in'>" + filtro_deposito + "</nro_pago_detalle></filtro></select></criterio>",
            //            xsl_name: "XSL_pagos_Banco_RIO.xsl",
            //            salida_tipo: "estado",
            //            destinos: "FILE://directorio_archivos/Santander_Rio/" + camino,
            //            metodo: "HTTPRequest",
            //            funComplete: function (response, parseError) {
            //                var oXML = new tXML()
            //                var numError

            //                if (oXML.loadXML(response.responseText))
            //                    numError = oXML.selectSingleNode("//@numError").nodeValue
            //                else
            //                    numError = -1

            //                window.open("directorio_archivos/Santander_Rio/" + camino)
            //            }
            //        })
            //        break
            //}
        }


        function ejecutar_transferencia_interbanking(strXML) {
            window.top.nvFW.transferenciaEjecutar({
                id_transferencia: 367,
                xml_param: strXML,
                pasada: 0,
                formTarget: 'winPrototype',
                async: false,
                winPrototype: {
                    modal: true,
                    center: true,
                    bloquear: false,
                    url: '/FW/enBlanco.htm',
                    title: '<b>Transferencia</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 800,
                    height: 400,
                    resizable: true,
                    destroyOnClose: true
                }
            })
        }

        var nro_interb_empresa = ''
        var id_transf = ''

        function forma_pago_onchange() {
            if ($('pagos_detalles_todos').value == '')
                return

            nro_interb_empresa = campos_defs.getRS("cb_forma_pago").getdata('nro_interbanking');
            id_transf = campos_defs.getRS("cb_forma_pago").getdata('id_transf');

            //recuperar nro_interbanking y datos de la pizarra

            if (nro_interb_empresa != '') {
                var contar_habilitado = 0
                var contar_nohabilitado = 0
                var rs = new tRS()

                //rs.open("<criterio><select vista='pago_registro_detalle'><campos>nro_pago_detalle, dbo.interb_get_estado_desc(nro_pago_detalle,'" + nro_interb_empresa + "') as interb_estado</campos><filtro><nro_pago_detalle type='in'>" + $('pagos_detalles_todos').value + "</nro_pago_detalle></filtro><orden></orden></select></criterio>")
                rs.open({
                    filtroXML: nvFW.pageContents.filtro_formaPagoInterbanking,
                    filtroWhere: "<criterio><select><campos>nro_pago_detalle, dbo.interb_get_estado_desc(nro_pago_detalle,'" + nro_interb_empresa + "') AS interb_estado</campos><filtro><nro_pago_detalle type='in'>" + $('pagos_detalles_todos').value + "</nro_pago_detalle></filtro></select></criterio>"
                })

                while (!rs.eof()) {
                    ifrdepositos.$('interb_estado_' + rs.getdata("nro_pago_detalle")).innerHTML = ''
                    ifrdepositos.$('interb_estado_' + rs.getdata("nro_pago_detalle")).insert({ top: rs.getdata("interb_estado") })

                    if (rs.getdata("interb_estado").toUpperCase() == 'HABILITADO') {
                        contar_habilitado++
                        ifrdepositos.$('interb_estado_' + rs.getdata("nro_pago_detalle")).setStyle({ color: 'green' })
                    }
                    else {
                        contar_nohabilitado++
                        ifrdepositos.$('interb_estado_' + rs.getdata("nro_pago_detalle")).setStyle({ color: 'red' })
                    }

                    rs.movenext()
                }

                var ultima_actualizacion = ''
                rs = new tRS()

                //rs.open("<criterio><select vista=''><campos>dbo.interb_ultima_actualizacion_str('" + nro_interb_empresa + "') as ultima_actualizacion</campos><filtro></filtro><orden></orden></select></criterio>")
                rs.open({
                    filtroXML: nvFW.pageContents.filtro_formaPagoInterbanking2,
                    params: "<criterio><params param1='" + nro_interb_empresa + "'/></criterio>"
                })

                if (!rs.eof())
                    ultima_actualizacion = rs.getdata("ultima_actualizacion")

                nombre_forma_pago = campos_defs.get_desc('cb_forma_pago');
                nombre_forma_pago = nombre_forma_pago.slice(nombre_forma_pago.indexOf('(') + 1, nombre_forma_pago.indexOf(')'));

                var strHTML = "<table class='tb1'>"
                strHTML += "<tr><td style='width: 20%; text-align: right; font-weight: bold; cursor: pointer; text-decoration: underline;' nowrap='nowrap' title='" + ultima_actualizacion + "'>" + nombre_forma_pago + ":</td>"
                strHTML += "<td style='width: 20%; color: #30E73E;'>Habilitadas: " + contar_habilitado + "<td>"
                strHTML += "<td style='width: 20%; color: #AE0000;'>No Habilitadas: " + contar_nohabilitado + "<td>"
                strHTML += "<td style='width: 30%; text-align: right; font-weight: bold;'>Total Seleccionado:<td>"
                strHTML += "</tr></table>"

                ifrdepositos.$('tdResumen').innerHTML = ''
                ifrdepositos.$('tdResumen').insert({ top: strHTML })
                $('cb_seleccionar').disabled = false
            }
            else {
                var arr_nro_pd = $('pagos_detalles_todos').value.split(',')
                var cant = arr_nro_pd.length

                for (var i = 0; i < cant; i++)
                    ifrdepositos.$('interb_estado_' + arr_nro_pd[i]).innerHTML = ''

                //var strHTML = "<table class='tb1'><tr>"
                //strHTML += "<td style='text-align: right; font-weight: bold;'>Total Seleccionado:<td>"
                //strHTML += "</tr></table>"

                ifrdepositos.$('tdResumen').innerHTML = ''
                ifrdepositos.$('tdResumen').insert({ top: "Total Seleccionado:" })

                $('cb_seleccionar')[0].selected = true
                $('cb_seleccionar').disabled = true
            }
        }


        function seleccionar_onchange() {
            ifrdepositos.seleccionar_estado($('cb_seleccionar').value)
        }


        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var hbody = $$('BODY')[0].getHeight()
                var tbAccionH = $('tbAccion').getHeight()

                $('ifrdepositos').setStyle({ 'height': (hbody - tbAccionH - dif) + 'px' })
            }
            catch (e) { }
        }


        function chk_fe_estado_onclick() {
            if ($('chk_fe_estado').checked == true)
                campos_defs.habilitar('fe_estado', true)
            else {
                if ($('fe_estado').value == '')
                    $('fe_estado').value = fecha_hoy

                campos_defs.habilitar('fe_estado', false)
            }
        }
    </script>
</head>
<body onload="return window_onload()" onresize="retunr window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <input type="hidden" name="pagos_detalles" id="pagos_detalles" />
    <input type="hidden" name="pagos_detalles_todos" id="pagos_detalles_todos" />
    <input type="hidden" name="modo" id="modo" value="<% = modo %>" />
    <input type="hidden" name="fecha_server" id="fecha_server" value="<% = fecha_server %>" />
    <input type="hidden" name="numError" id="numError" />

    <iframe name="ifrdepositos" id="ifrdepositos" style="height: 400px; width: 100%; border: none;" src="/FW/enBlanco.htm"></iframe>

    <table class="tb1" id="tbAccion">
        <tr class="tbLabel">
            <td style="width: 15%">Cambio de Estado</td>
            <td style="width: 10%" colspan='2'>Fecha Estado</td>
            <td style="width: 15%">-</td>
            <td style="width: 60%" colspan="3">Forma de Pago</td>
        </tr>
        <tr>
            <td>
                <script>campos_defs.add("nro_pago_estado", { despliega: "arriba" })</script>
                <%--<select name="nro_pago_estado" id="nro_pago_estado" style="width: 100%"></select>--%>
            </td>
            <td style="text-align: center; width: 2%;">
                <input type="checkbox" id="chk_fe_estado" name="chk_fe_estado" style="border: none; cursor: pointer;" onclick="return chk_fe_estado_onclick()" />
            </td>
            <td style="width: 8%;">
                <script type="text/javascript">campos_defs.add('fe_estado', { enDB: false, nro_campo_tipo: 103 })</script>
            </td>
            <td>
                <input type="button" style="width: 100%" value="Cambiar Estado" onclick="Confirmar()" />
            </td>
            <td style="width: 20%">
                <script>
                    campos_defs.add('cb_forma_pago', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_pg_formas,
                        nro_campo_tipo: 1,
                        stringValueIncludeQuotes: true,
                        despliega: 'arriba',
                        sin_seleccion: false,
                        onchange: function () {
                            forma_pago_onchange();
                        }
                    });

                    campos_defs.set_first('cb_forma_pago');

                </script>
                <%--<select name="cb_forma_pago" id="cb_forma_pago" onchange="return forma_pago_onchange()" style="width: 100%;">
                    <option value="CH">Cheque</option>
                    <option value="DCH">Depósito Chaco</option>
                    <option value="DNBSF">Depósito NBSF</option>
                    <option value="TIAMSDA">TEF Interbanking Amsda</option>
                    <option value="TIAMUS">TEF Interbanking Amus</option>
                    <option value="TICHACO">TEF Interbanking Coop. Chaco</option>
                    <option value="TICHACRA">TEF Interbanking Chacra</option>
                    <option value="TIMUPER">TEF Interbanking MUPER</option>
                    <option value="TINEXFIN">TEF Interbanking Nexfin</option>
                    <option value="TIITALA">TEF Interbanking Itala</option>
                    <option value="TIAMPIV">TEF Interbanking Ampiv</option>
                    <option value="TIURQUIZA">TEF Interbanking Urquiza</option>
                    <option value="TIAMEP">TEF Interbanking Amep</option>
                    <option value="TIACCCOM">TEF Interbanking ACC COM</option>
                    <option value="TR">TEF Banco Rio</option>
                </select>--%>
            </td>
            <td style="width: 15%;">
                <select name="cb_seleccionar" id="cb_seleccionar" onchange="return seleccionar_onchange()" style="width: 100%;">
                    <option value="V">Selección por Estado Cta.</option>
                    <option value="T">Todos</option>
                    <option value="I">Ninguno</option>
                    <option value="H">Habilitadas</option>
                    <option value="N">No Habilitadas</option>
                    <option value="P">Pendiente Habilitación</option>
                </select>
            </td>
            <td style="width: 10%;">
                <input type="button" name="btn_Ejecutar_Forma_Pago" id="btn_Ejecutar_Forma_Pago" value="Ejecutar" style="width: 100%;" onclick="Ejecutar_Forma_Pago()" />
            </td>
        </tr>
    </table>
</body>
</html>
