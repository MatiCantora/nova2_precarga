<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Response.Expires = 0

    Dim objOperador As Object = nvFW.nvApp.getInstance().operador
    Dim operador As String = objOperador.nombre_operador
    Dim nro_operador As Integer = objOperador.operador

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_pago_estado As Integer = nvFW.nvUtiles.obtenerValor("nro_pago_estado", "0")
    Dim nro_banco As Integer = nvFW.nvUtiles.obtenerValor("nro_banco", "0")
    Dim nro_banco_sucursal As Integer = nvFW.nvUtiles.obtenerValor("nro_banco_sucursal", "0")
    Dim nro_comprobante As Integer = nvFW.nvUtiles.obtenerValor("nro_comprobante", "0")
    Dim nro_cuenta As Integer = nvFW.nvUtiles.obtenerValor("nro_cuenta", "0")
    Dim nro_pago_detalle As String = ""
    Dim indice As Integer = 0
    Dim nro_pago_tipo As Integer = 0

    If modo = "" Then
        modo = "VA"
    End If

    '|-----------------------------------------------------
    '| Cambio de estado de pagos seleccionados
    '|-----------------------------------------------------
    If modo = "A" Then
        indice = nvFW.nvUtiles.obtenerValor("indice")

        For i As Integer = 1 To indice
            nro_pago_detalle = nvFW.nvUtiles.obtenerValor("nro_pago_detalle" & i.ToString())

            If nro_pago_detalle <> "" Then
                Dim strSQL As String = "SELECT mutual, nro_pago_tipo, importe_param, razon_social, nro_pago_estado FROM wrp_verpg_registro WHERE nro_pago_detalle = " & nro_pago_detalle
                Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)

                If Not rs.EOF Then
                    nro_pago_tipo = rs.Fields("nro_pago_tipo").Value
                    '***********************************************************************
                    ' Los valores a continuacion no se traducen porque no tienen ningun uso
                    '***********************************************************************
                    ' nro_pago_tipo = Rs.Fields("nro_pago_tipo").Value
                    ' empresa = Rs.Fields("mutual").Value
                    ' importe = Rs.Fields("importe_param").Value
                    ' razon_social = Rs.Fields("razon_social").Value
                    ' estado = Rs.Fields("nro_pago_estado").Value
                End If

                nvFW.nvDBUtiles.DBCloseRecordset(rs)

                If nro_pago_tipo = 6 AndAlso nro_pago_estado = 2 Then
                    strSQL = "UPDATE pago_registro_detalle SET nro_pago_estado = " & nro_pago_estado & ", fe_estado = GETDATE(), nro_operador_estado = " & nro_operador & ", usuario_estado = '" & operador & "' WHERE nro_pago_detalle = " & nro_pago_detalle
                    nvFW.nvDBUtiles.DBExecute(strSQL)
                End If
            End If
        Next
    End If

    '|-----------------------------------------------------
    '| Pasar pagos seleccionados a Efectivo
    '|-----------------------------------------------------
    If modo = "E" Then
        indice = nvFW.nvUtiles.obtenerValor("indice")

        For i As Integer = 1 To indice
            nro_pago_detalle = nvFW.nvUtiles.obtenerValor("nro_pago_detalle" & i.ToString())

            If nro_pago_detalle <> "" Then
                Dim strSQL As String = "SELECT * FROM pago_registro_detalle WHERE nro_pago_detalle = " & nro_pago_detalle & " AND nro_pago_estado = 1"
                Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)

                If Not rs.EOF Then
                    strSQL = "DELETE FROM pago_parametros WHERE nro_pago_detalle = " & nro_pago_detalle & vbCrLf
                    strSQL &= "UPDATE pago_registro_detalle SET nro_pago_tipo = 4 WHERE nro_pago_detalle = " & nro_pago_detalle
                    nvFW.nvDBUtiles.DBExecute(strSQL)
                End If

                nvFW.nvDBUtiles.DBCloseRecordset(rs)
            End If
        Next
    End If

    '|-----------------------------------------------------
    '| Filtros encriptados
    '|-----------------------------------------------------
    Me.contents("filtro_pgRegistroDetEnvio") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_pg_registro_det_envio'><campos>nro_pago_detalle, nro_credito, razon_social, pago_concepto, pago_tipo, importe_pago, importe_param, nro_pago_estado, pago_estados</campos><orden>nro_credito</orden></select></criterio>")
    Me.contents("filtro_pgRegistroDet") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_pg_registro_det'><campos>nro_pago_detalle, nro_credito, razon_social, pago_concepto, pago_tipo, importe_pago, importe_param, nro_pago_estado, pago_estados</campos><orden>nro_credito</orden></select></criterio>")
    Me.contents("filtro_pagoEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_estados'><campos>*</campos></select></criterio>")
    Me.contents("filtro_ejecutarFormaPago") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_pg_registro'><campos>*</campos><filtro><estado_envio type='sql'>estado_envio = 'F' OR estado_envio IS NULL</estado_envio></filtro></select></criterio>")
    Me.contents("filtro_ejecutarFormaPagoTI") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_pg_registro'><campos>*</campos><filtro><nro_pago_tipo type='igual'>1</nro_pago_tipo><nro_pago_estado type='igual'>1</nro_pago_estado></filtro></select></criterio>")
    Me.contents("filtro_ejecutarFormaPagoTR") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_PG_Registro'><campos>nro_pago_detalle, razon_social, cuit, dbo.rm_getParametroPago(nro_pago_detalle, 'nro_cuenta') AS cbu, 1 AS nro_liquidacion, getDate() AS fe_pago, importe_pago, 0 AS sucursal_rio, 0 AS tipo_cuenta_rio, 0 AS numero_cuenta_rio</campos><orden>nro_credito</orden><filtro><nro_pago_tipo type='igual'>1</nro_pago_tipo><tipo_cuenta type='igual'>2</tipo_cuenta><estado_envio type='sql'>estado_envio = 'F' OR estado_envio IS NULL</estado_envio></filtro></select></criterio>")
    Me.contents("filtro_generarArchivo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_PG_Registro'><campos>nro_pago_detalle, razon_social, cuit, dbo.rm_getParametroPago(nro_pago_detalle, 'nro_cuenta') AS cbu, 1 AS nro_liquidacion, getDate() AS fe_pago, importe_pago, 0 AS sucursal_rio, 0 AS tipo_cuenta_rio, 0 AS numero_cuenta_rio</campos><orden>nro_credito</orden><filtro><nro_pago_tipo type='igual'>1</nro_pago_tipo><tipo_cuenta type='igual'>2</tipo_cuenta></filtro></select></criterio>")
    Me.contents("filtro_") = nvFW.nvXMLSQL.encXMLSQL("")
    Me.contents("filtro_") = nvFW.nvXMLSQL.encXMLSQL("")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Pagos edición</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var inCredito
        var strError = ""
        var filtro_envio
        var filtro_credito
        var nro_pago_tipo
        var nro_banco
        var razon_social
        var nro_pago_concepto
        var filtro_rs
        var filtro_pago_concepto
        var vista

        // Botones
        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"]   = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"]   = "buscar";
        vButtonItems[0]["onclick"]  = "return Aceptar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", "/FW/image/icons/buscar.png")


        function window_onload()
        {
            // Mostrar botones creados
            vListButtons.MostrarListButton()
            Cargar_Estados()
            
            try
            {
                var Parametros          = window.dialogArguments
                filtro_envio            = Parametros["filtro_envio"]
                filtro_credito          = Parametros["filtro_credito"]
                nro_pago_tipo           = Parametros["nro_pago_tipo"]
                razon_social            = Parametros["razon_social"]
                nro_pago_concepto       = Parametros["nro_pago_concepto"]
                form1.nro_credito.value = Parametros["nro_credito"]
                filtro_rs               = ''

                if (razon_social != '')
                {
                    filtro_rs = "<razon_social type='like'>%" + razon_social + "%</razon_social>"
                    form1.razon_social.value = razon_social
                }

                filtro_pago_concepto = ''

                if (nro_pago_concepto != 0)
                {
                    filtro_pago_concepto = "<nro_pago_concepto type='in'>" + nro_pago_concepto + "</nro_pago_concepto>"
                    campos_defs.set_value("nro_pago_concepto", nro_pago_concepto.toString())
                }
                
                nro_banco        = Parametros["nro_banco"]
                var banco        = Parametros["banco"]
                var cuenta       = Parametros["cuenta"]
                var chequera     = Parametros["chequera"]
                var cheque_desde = Parametros["cheque_desde"]
                cheque_desde_01  = cheque_desde - 1

                if (filtro_envio != '')
                {
                    vista = 'wrp_pg_registro_det_envio'
                    formImp.filtroXML.value = nvFW.pageContents.filtro_pgRegistroDetEnvio
                }
                else
                {
                    vista = 'wrp_pg_registro_det'
                    formImp.filtroXML.value = nvFW.pageContents.filtro_pgRegistroDet
                }

                //formImp.filtroXML.value = "<criterio><select vista='" + vista + "'><campos>nro_pago_detalle, nro_credito, razon_social, pago_concepto, pago_tipo, importe_pago, importe_param, nro_pago_estado, pago_estados</campos><orden>nro_credito</orden><filtro>" + filtro_envio + filtro_credito + filtro_rs + filtro_pago_concepto + "<nro_pago_tipo type='igual'>" + nro_pago_tipo + "</nro_pago_tipo></filtro></select></criterio>"
                formImp.filtroWhere.value = "<criterio><select><filtro>" + filtro_envio + filtro_credito + filtro_rs + filtro_pago_concepto + "<nro_pago_tipo type='igual'>" + nro_pago_tipo + "</nro_pago_tipo></filtro></select></criterio>"
                formImp.path_xsl.value = "report/wrp_pg_registro/HTML_pagos.xsl"
                formImp.submit()
                isModal = true
                campos_defs.set_value("nro_pago_tipo", nro_pago_tipo.toString())
            }
            catch(e)
            {
                isModal = false
            }

            if (form1.indice.value > 0)
                window.close();
            
            if (form1.modo.value == 'VA')
                form1.modo.value = 'A'
        }


        function Aceptar() {
            var filtro_defs = campos_defs.filtroWhere()
            var filtro_rs   = ""

            if (form1.razon_social.value != '')
                filtro_rs = "<razon_social type='like'>%" + form1.razon_social.value + "%</razon_social>"

            if (filtro_credito == '')
            {
                if (form1.nro_credito.value != '')
                    filtro_credito = "<nro_credito type='igual'>" + form1.nro_credito.value + "</nro_credito>"
            }

            //formImp.filtroXML.value = "<criterio><select vista='" + vista + "'><campos>nro_pago_detalle, nro_credito, razon_social, pago_concepto, pago_tipo, importe_pago, importe_param, pago_estados, nro_pago_estado</campos><orden>nro_credito</orden><filtro>" + filtro_envio + filtro_credito + filtro_defs + filtro_rs + "</filtro></select></criterio>"
            formImp.filtroXML.value   = vista == "wrp_pg_registro_det_envio" ? nvFW.pageContents.filtro_pgRegistroDetEnvio : nvFW.pageContents.filtro_pgRegistroDet
            formImp.filtroWhere.value = "<criterio><select><filtro>" + filtro_envio + filtro_credito + filtro_defs + filtro_rs + "</filtro></select></criterio>"
            formImp.path_xsl.value    = "report/wrp_pg_registro/HTML_pagos.xsl"
            formImp.submit()
        }


        function Confirmar()
        {
            if (form1.nro_pago_estado.value == 0)
            {
                alert('Debe seleccionar un estado.');
                form1.nro_pago_estado.focus()
                return
            }
            else
            {
                document.all.divdatos.innerHTML = ""
                var strHTML = ""

                for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++)
                {
                    if (ele.type == 'checkbox')
                        if (ele.name != 'all')
                        {
                            if (ele.checked)
                            {
                                ele_cheque = iframe1.document.all.frm1.elements[i + 1]
                                strHTML += "<input type='hidden' name='nro_pago_detalle" + i.toString() + "' value='" + ele.value + "' />"
                            }
                        }
                }

                if (strHTML == "")
                    alert("No ha seleccionado ningun Pago")
                else
                {
                    document.all.divdatos.insertAdjacentHTML("beforeEnd", strHTML)
                    form1.indice.value = i - 1
                    form1.submit()
                }
            }
        }


        function Seleccion_chequera()
        {
            var filtro_cheque = ''
            var Parametros    = []
            
            for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++)
            {
                if (ele.type == 'checkbox')
                    if (ele.name != 'all')
                    {
                        if (ele.checked)
                        {
                            filtro_cheque = filtro_cheque == "" ? ele.value : filtro_cheque + ", " + ele.value
                            //if (filtro_cheque == "")
                            //    filtro_cheque = ele.value
                            //else
                            //    filtro_cheque = filtro_cheque + ", " + ele.value
                        }
                    }
            }

            if (filtro_cheque == '')
            {
                alert('No ha seleccionado ningún Pago para imprimir')
                return
            }
            else
            {
                Parametros["filtro_seleccion"] = filtro_cheque
                Parametros["descripcion"]      = "grupo"

                var winSeleccionChequera = nvFW.createWindow({
                    title: "<b>Selección de chequera</b>",
                    url: "/meridiano/Pagos_distribucion_chequera.aspx",
                    width: 800,
                    height: 170,
                    destroyOnClose: true
                })

                winSeleccionChequera.options.userData = { Parametros: Parametros }
                winSeleccionChequera.showCenter(true)
            }
        }


        function Cargar_Estados()
        {
            var rs = new tRS()
            var cb = document.all.nro_pago_estado
            cb.options.length = 0
            cb.options.length++
            cb.options[cb.options.length - 1].value = 0
            cb.options[cb.options.length - 1].text  = "Seleccione un Estado..."

            //rs.open("<criterio><select vista='pago_estados'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
            rs.open({ filtroXML: nvFW.pageContents.filtro_pagoEstados })

            while (!rs.eof())
            {
                cb.options.length++
                cb.options[cb.options.length - 1].value = rs.getdata('nro_pago_estado')
                cb.options[cb.options.length - 1].text  = rs.getdata('pago_estados')

                rs.movenext()
            }
        }


        function Ejecutar_Forma_Pago() {
            var filtro_seleccion = Registros_Seleccionados()

            if (filtro_seleccion == '')
            {
                alert('No ha seleccionado ningún pago. Verifique...')
                return
            }
            else
            {
                switch (form1.cb_forma_pago.value)
                {
                    // Cheque
                    case 'CHG':
                        alert('Página en Construcción');
                        break

                    // Impresion Cheque Detalle
                    case 'CHD':
                        Imprimir_Cheque_Detalle();
                        break

                    // Depósito Chaco
                    case 'DCH':
                        //formImpXML.filtroXML.value = "<criterio><select vista='WRP_pg_registro'><campos>*</campos><orden></orden><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle><estado_envio type='sql'>estado_envio = 'F' or estado_envio is null</estado_envio></filtro></select></criterio>"
                        formImpXML.filtroXML.value   = nvFW.pageContents.filtro_ejecutarFormaPago
                        formImpXML.filtroWhere.value = "<criterio><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle></filtro></criterio>"
                        formImpXML.report_name.value = "Pagos_Detalle_Chaco.rpt"
                        formImpXML.submit();
                        break

                    // Depósito NBSF
                    case 'DNBSF':
                        //formImpXML.filtroXML.value = "<criterio><select vista='WRP_pg_registro'><campos>*</campos><orden></orden><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle><estado_envio type='sql'>estado_envio = 'F' or estado_envio is null</estado_envio></filtro></select></criterio>"
                        formImpXML.filtroXML.value   = nvFW.pageContents.filtro_ejecutarFormaPago
                        formImpXML.filtroWhere.value = "<criterio><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle></filtro></criterio>"
                        formImpXML.report_name.value = "Pago_Listado_Deposito_NBSF.rpt"
                        formImpXML.submit();
                        break

                    // Generar Archivo Interbanking
                    case 'TI':
                        var filtro_pago_detalle = ''
                        var rs = new tRS()

                        //rs.open("<criterio><select vista='wrp_pg_registro'><campos>*</campos><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle><nro_pago_tipo type='igual'>1</nro_pago_tipo><nro_pago_estado type='igual'>1</nro_pago_estado></filtro><orden></orden></select></criterio>")
                        rs.open({
                            filtroXML: nvFW.pageContents.filtro_ejecutarFormaPagoTI,
                            filtroWhere: "<criterio><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle></filtro></criterio>"
                        })

                        while (!rs.eof())
                        {
                            filtro_pago_detalle = filtro_pago_detalle == '' 
                                ? rs.getdata('nro_pago_detalle') 
                                : filtro_pago_detalle + ", " + rs.getdata('nro_pago_detalle')
                            //if (filtro_pago_detalle == '')
                            //    filtro_pago_detalle = rs.getdata('nro_pago_detalle')
                            //else
                            //    filtro_pago_detalle = filtro_pago_detalle + ", " + rs.getdata('nro_pago_detalle')

                            rs.movenext()
                        }

                        if (filtro_pago_detalle == '')
                            alert('No existen pagos para generar el archivo')
                        else
                        {
                            // Ejecutar Transferencia Interbanking
                            var Parametros = []
                            Parametros["filtro_pago_detalle"] = filtro_pago_detalle;
                                

                            var winInterbanking = nvFW.createWindow({
                                title: "<b>Pagos distribución InterBanking</b>",
                                url: "/meridiano/Pagos_distribucion_interbanking.aspx",
                                width: 900,
                                height: 550,
                                destroyOnClose: true
                            })

                            winInterbanking.options.userData = { Parametros: Parametros }
                            winInterbanking.showCenter(true)
                        }
                        break

                    case 'TR':
                        var camino = Generar_Nombre_Archivo()

                        //frmExportar.filtroXML.value = "<criterio><select vista='WRP_PG_Registro'><campos>nro_pago_detalle, razon_social, cuit, dbo.rm_getParametroPago(nro_pago_detalle, 'nro_cuenta') as cbu, 1 as nro_liquidacion, getDate() as fe_pago, importe_pago, 0 as sucursal_rio, 0 as tipo_cuenta_rio, 0 as numero_cuenta_rio</campos><orden>nro_credito</orden><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle><nro_pago_tipo type='igual'>1</nro_pago_tipo><tipo_cuenta type='igual'>2</tipo_cuenta><estado_envio type='sql'>estado_envio = 'F' or estado_envio is null</estado_envio></filtro></select></criterio>"
                        frmExportar.filtroXML.value   = nvFW.pageContents.filtro_ejecutarFormaPagoTR
                        frmExportar.filtroWhere.value = "<criterio><filtro><nro_pago_detalle type='in'>" + filtro_seleccion + "</nro_pago_detalle></filtro></criterio>"
                        frmExportar.xsl_name.value    = "XSL_pagos_Banco_RIO.xsl"
                        frmExportar.target.value      = "FILE://directorio_archivos/Santander_Rio/" + camino
                        frmExportar.submit()
                        window.open("directorio_archivos/Santander_Rio/" + camino, null, "width=680")
                        break

                    case 'E':
                        document.all.divdatos.innerHTML = ""
                        var strHTML = ""

                        for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++)
                        {
                            if (ele.type == 'checkbox')
                                if (ele.name != 'all')
                                {
                                    if (ele.checked)
                                    {
                                        ele_cheque = iframe1.document.all.frm1.elements[i + 1]
                                        strHTML += "<input type='hidden' name='nro_pago_detalle" + i.toString() + "' value='" + ele.value + "' />"
                                    }
                                }
                        }

                        if (strHTML == "")
                            alert("No ha seleccionado ningun Pago")
                        else
                        {
                            var mensaje = nvFW.confirm('¿Desea cambiar los pagos seleccionados a tipo "Efectivo"?')

                            if (mensaje)
                            {
                                document.all.divdatos.insertAdjacentHTML("beforeEnd", strHTML)
                                form1.modo.value   = "E"
                                form1.indice.value = i - 1
                                form1.submit();
                            }
                            else
                                return
                        }
                        break

                    case 'D':
                        alert('Página en construcción.')
                        break
                }
            }
        }


        function Imprimir_Cheque_Detalle()
        {
            var Parametros = []
            Parametros["filtro_seleccion"] = Registros_Seleccionados()
            Parametros["descripcion"]      = "detalle"


            var winImprimirChequeDetalle = nvFW.createWindow({
                title: "<b>Imprimir cheque detalle</b>",
                url: "/meridiano/Pagos_distribucion_chequera.aspx",
                width: 800,
                height: 170,
                destroyOnClose: true
            })

            winImprimirChequeDetalle.options.userData = { Parametros: Parametros }
            winImprimirChequeDetalle.showCenter(true)

            Aceptar()
        }


        function Generar_Nombre_Archivo()
        {
            var nombre_archivo
            var nombre_carpeta
            var mydate = new Date()
            var year = mydate.getFullYear()
            
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

            return nombre_carpeta + "/" + nombre_archivo
        }


        function Generar_Archivo()
        {
            // PAG-aaaammdd-hhmiss.txt
            var camino
            var filtro_archivo = ''
            var Parametros = []
            
            for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++)
            {
                if (ele.type == 'checkbox')
                    if (ele.name != 'all')
                    {
                        if (ele.checked)
                        {
                            filtro_archivo = filtro_archivo == "" ? ele.value : filtro_archivo + ", " + ele.value
                            //if (filtro_archivo == "")
                            //    filtro_archivo = ele.value
                            //else
                            //    filtro_archivo = filtro_archivo + ", " + ele.value
                        }
                    }
            }

            if (filtro_archivo == '')
            {
                alert('No ha seleccionado ningún Pago')
                return
            }
            else
            {
                var camino = Generar_Nombre_Archivo()
                //frmExportar.filtroXML.value = "<criterio><select vista='WRP_PG_Registro'><campos>nro_pago_detalle, razon_social, cuit, dbo.rm_getParametroPago(nro_pago_detalle, 'nro_cuenta') as cbu, 1 as nro_liquidacion, getDate() as fe_pago, importe_pago, 0 as sucursal_rio, 0 as tipo_cuenta_rio, 0 as numero_cuenta_rio</campos><orden>nro_credito</orden><filtro><nro_pago_detalle type='in'>" + filtro_archivo + "</nro_pago_detalle><nro_pago_tipo type='igual'>1</nro_pago_tipo><tipo_cuenta type='igual'>2</tipo_cuenta></filtro></select></criterio>"
                frmExportar.filtroXML.value   = nvFW.pageContents.filtro_generarArchivo
                frmExportar.filtroWhere.value = "<criterio><filtro><nro_pago_detalle type='in'>" + filtro_archivo + "</nro_pago_detalle></filtro></criterio>"
                frmExportar.xsl_name.value    = "XSL_pagos_Banco_RIO.xsl"
                frmExportar.target.value      = "FILE://directorio_archivos/Santander_Rio/" + camino

                // Enviamos el 'form' para generar el archivo
                frmExportar.submit()
                window.open("directorio_archivos/Santander_Rio/" + camino, null, "width=680")
            }
        }


        function Registros_Seleccionados()
        {
            var filtro_seleccion = ''

            for (var i = 0, ele; ele = iframe1.document.all.frm1.elements[i]; i++) {
                if (ele.type == 'checkbox')
                    if (ele.name != 'all')
                    {
                        if (ele.checked)
                        {
                            filtro_seleccion = filtro_seleccion == "" ? ele.value : filtro_seleccion + ", " + ele.value
                            //if (filtro_seleccion == "") {
                            //    filtro_seleccion = ele.value
                            //}
                            //else
                            //    filtro_seleccion = filtro_seleccion + ", " + ele.value
                        }
                    }
            }

            return filtro_seleccion
        }
    </script>
</head>
<body onload="return window_onload()">

    <form name="formImpXML" target="_blank" action="/FW/reportViewer/mostrarReporte.aspx" method="POST">
        <input type="hidden" name="filtroXML" value="" />
        <input type="hidden" name="filtroWhere" value="" />
        <input type="hidden" name="report_name" value="" />
    </form>

    <form name="formImp" target="iframe1" action="/FW/reportViewer/exportarReporte.aspx" method="POST">
        <input type="hidden" name="filtroXML" value="" />
        <input type="hidden" name="filtroWhere" value="" />
        <input type="hidden" name="xsl_name" value="" />
        <input type="hidden" name="path_xsl" value="" />
        <input type="hidden" name="mantener_origen" value="true" />
        <input type="hidden" name="parametros" value="" />
    </form>

    <form name="frmExportar" target="frmEnviar" action="/FW/reportViewer/exportarReporte.aspx" method="POST">
        <input type="hidden" name="filtroXML" value="" />
        <input type="hidden" name="filtroWhere" value="" />
        <input type="hidden" name="xsl_name" value="" />    
        <input type="hidden" name="target" value=""  />
    </form>

    <form style="display:none" name="formTransfe" enctype="multipart/form-data" target="_blank" action="transferencia_ejecutar.aspx" method="POST">
        <input type="hidden" name="id_transferencia" value="" />
        <input type="hidden" name="xml_param" value="" />
        <input type="hidden" name="pasada" value="" />
    </form>

    <form name="form1" id="form1" action="Pagos_distribucion.aspx" method="post" target="frmEnviar">
        <input type="hidden" name="indice" value="<% = indice %>">
        <input type="hidden" name="modo" value="<% = modo %>">
        
        <table class="tb1">
            <tr class="tbLabel_O">
                <td nowrap>Edición Pagos</td>
            </tr>
            <tr>
                <td>      
                    <div id="divMostrar"></div>
                </td>
                <td>
                    <div id="divdatos" visible="false"></div>
                </td>
            </tr>
        </table>

        <table class="tb1">
            <tr>
                <td style="width:85%">       
                    <table class="tb1">    
                        <tr class="tbLabel">    
                            <td style="width:15%">Nro. Crédito</td>
                            <td style="width:30%">Razón Social</td>
                            <td style="width:25%">Concepto</td>
                            <td style="width:25%">Tipo Pago</td>
                        </tr>
                        <tr>   
                            <td><input name="nro_credito" style="width: 100%" onkeypress='return valDigito()' /></td>
                            <td><input name="razon_social" style="width: 100%" /></td>
                            <td><% = nvFW.nvCampo_def.get_html_input("nro_pago_concepto", enDB:=False, nro_campo_tipo:=104) %></td>
                            <td><% = nvFW.nvCampo_def.get_html_input("nro_pago_tipo", enDB:=False, nro_campo_tipo:=104) %></td>
                        </tr>
                    </table>
                </td>
                <td align="left" style="vertical-align: bottom">    
                    <table class="tb1">
                        <tr>
                            <td align="left" style="vertical-align:bottom"><div id="divBuscar"></div></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>    
        
        <iframe name="iframe1" height="430" width="100%" frameborder="1" src="enBlanco.htm"></iframe>

        <br />

        <table class="tb1">
            <tr class="tbLabel">
                <td style="width:40%" colspan="2">Cambio de Estado</td>
                <td style="width:30%" colspan="2">Tarea</td>              
            </tr>
            <tr>
                <td style="width: 25%"><select name="nro_pago_estado" style="width: 100%"></select></td>
                <td style="width: 25%"><input type="button" style="width: 100%" value="Cambiar Estado" onclick="Confirmar()" /></td>
                <td style="width: 30%">
                    <select name="cb_forma_pago" style="width: 100%">
                        <option value="CHD" selected>Imprimir Cheque Detalle</option>
                        <option value="CHG">Imprimir Cheque General</option>                                        
                        <option value="DCH">Imprimir depósito formato Bco. Chaco</option>
                        <option value="DNBSF">Imprimir depósito formato NBSF</option>
                        <option value="TI">Generar archivo depósito Interbanking</option>                    
                        <option value="TR">Generar archivo depósito Banco Rio</option>
                        <option value="E">Pasar Pagos a Efectivo</option>
                        <option value="D">Pasar Pagos a Depósitos</option>                                                            
                    </select>
                </td>
                <td style="width:20%">
                    <input type="button" name="btn_Ejecutar_Forma_Pago" value="Ejecutar" style="width:100%" onclick="Ejecutar_Forma_Pago()" />
                </td>
            </tr>
        </table>

        <iframe name="frmEnviar" src="enBlanco.htm" frameborder="0" style="displayº: none"></iframe>

    </form>    
</body>
</html>
