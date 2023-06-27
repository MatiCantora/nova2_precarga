<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<% 
    Dim flag_ic = nvUtiles.obtenerValor("flag_ic", 0)
    Dim dc_id_mov = nvUtiles.obtenerValor("dc_id_mov", "")
    Dim internalcode = nvUtiles.obtenerValor("internalcode", "")
    Dim modo = nvUtiles.obtenerValor("modo", 0)
    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim err = New nvFW.tError()
    Me.contents("date") = DateTime.Now.ToShortDateString()

    ''ESTE UPDATE ES PARA EL EDITABLE DEL INTERNAL CODE QUE HOY NO SE USA.
    If flag_ic = 1 Then
        Try
            DBExecute("UPDATE dc_mov SET internalcode ='" & internalcode & "' WHERE nro_dc_mov =" & dc_id_mov)
        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del parametro"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    ''ESTE CODIGO TAMPOCO SE USA, YA QUE NO LE PEGAMOS DE FORMA DIRECTA A LA TABLA SI NO QUE VAMOS A LA API PRIMERO
    If strXML <> "" Then
        'Stop
        Try
            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "dc_mov_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = strXML.Length
            Cmd.Parameters("@strXML").value = strXML

            Dim rs = Cmd.Execute()

            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del parametro"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Me.contents("bancoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='bancos_bcra'><campos>nro_bcra as id, bcra_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("bancoRs") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='bancos_bcra'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("bancos_bcra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_estados'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("entidadDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Entidades'><campos>cuit as id, Razon_social as campo, nro_entidad</campos><filtro></filtro></select></criterio>")
    Me.contents("cuentaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_cuentas'><campos>id_tipo as id, CBU as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("bancoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Entidades'><campos>cuit as id, Razon_social as campo, nro_entidad</campos><filtro><Razon_social type='like'>%BANCO%</Razon_social></filtro></select></criterio>")
    Me.contents("tipoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov_tipos'><campos>dc_mov_tipo as id, dc_mov_tipo_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("estadosDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_estados'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("conceptoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_conceptos'><campos>id_dc_concepto as id, dc_concepto as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("monedaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='moneda'><campos>ISO_num as id, ISO_cod as campo</campos><filtro><activo type='igual'>1</activo></filtro><orden>campo</orden></select></criterio>")
    Me.contents("dc_mov") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDC_movimientos'><campos>*</campos><filtro></filtro></select></criterio>")


%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Nuevo CREDIN / DEBIN</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/tListButton.css" type="text/css" rel="stylesheet" />
    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="application/javascript">
        var win = nvFW.getMyWindow()
        var tipo_mov
        var modo = 0
        var ar_resumen
        var nro_dc_mov = -1

        //ESTA FUNCION CARGA LOS DATOS YA SEA DE LA VUELTA DEL AJAX O DEL MOVIMIENTO SELECCIONADO EN LA PLANTILLA.
        function cargar_mov(param) {

            if (!param) {
                param = {}
            }

            $('cabecera').style.display = 'none'

            $('expTit').innerHTML = 'Fecha de Expiración: '

            nro_dc_mov = win.options.userData.nro_dc_mov

            //$('estado').value = param.dc_id_estado + ' ' + param.res_descripcion

            var rs = new tRS()

            rs.open({
                filtroXML: nvFW.pageContents.estadosDef,
                filtroWhere: "<criterio><select><filtro><id_dc_estado type='igual'>'" + param.dc_id_estado + "'</id_dc_estado></filtro></select></criterio>"
            })


            param.flag = !param.flag ? '' : param.flag
            param.fecha_ip = !param.fecha_ip ? '' : param.fecha_ip
            param.imsi = !param.imsi ? '' : param.imsi
            param.imei = !param.imei ? '' : param.imei
            param.concepto = !param.concepto ? '' : param.concepto
            param.moneda = !param.moneda ? '' : param.moneda
            param.credito_cuit = !param.credito_cuit ? '' : param.credito_cuit
            param.tipoDispositivo = !param.tipoDispositivo ? '' : param.tipoDispositivo
            param.plataforma = !param.plataforma ? '' : param.plataforma
            param.dc_id_estado = !param.dc_id_estado ? '' : param.dc_id_estado
            param.res_descripcion = !param.res_descripcion ? '' : param.res_descripcion
            param.res_codigo = !param.res_codigo ? '' : param.res_codigo
            param.dc_estado = !param.dc_estado ? '' : param.dc_estado
            param.importe = !param.importe ? '' : param.importe
            param.debito_cbu = !param.debito_cbu ? '' : param.debito_cbu
            param.credito_cbu = !param.credito_cbu ? '' : param.credito_cbu
            param.sucursal = !param.sucursal ? '' : param.sucursal
            param.lat = !param.lat ? '' : param.lat
            param.lng = !param.lng ? '' : param.lng
            param.precision = !param.precision ? '' : param.precision
            param.ipCli = !param.ipCli ? '' : param.ipCli
            param.puntaje = !param.puntaje ? '-' : param.puntaje
            param.debitoRazonSocial = !param.debitoRazonSocial ? '' : param.debitoRazonSocial
            param.creditoTipoCta = !param.creditoTipoCta ? '' : param.creditoTipoCta
            param.debitoTipoCta = !param.debitoTipoCta ? '' : param.debitoTipoCta
            param.credito_bcra_desc = !param.credito_bcra_desc ? '' : param.credito_bcra_desc
            param.debito_bcra_desc = !param.debito_bcra_desc ? '' : param.debito_bcra_desc
            param.db_fecha_expiracion = !param.db_fecha_expiracion ? '' : param.db_fecha_expiracion
            param.internalcode = !param.internalcode ? '' : param.internalcode
            param.reglas = !param.reglas ? '-' : param.reglas
            param.login = !param.login ? '-' : param.login



            var fecha = param.fecha_ip
            var fechaExp = param.db_fecha_expiracion

            if (param.bool == 1) {
                $('undef').style.display = 'table-cell'
                $('def').style.display = 'none'
            }

            $('sucursal').value = param.credito_cbu.substring(3, 7)
            $('detCuitCred').value = param.credito_cuit
            $('detCbuCred').value = param.credito_cbu
            $('tiempoExpiracion').value = param.db_fecha_expiracion
            campos_defs.habilitar("nro_moneda", true)
            campos_defs.habilitar("concepto", true)
            campos_defs.habilitar("dc_cuentas_tipo", true)
            campos_defs.habilitar('dc_definicion', false)
            if (param.flag == 1) {
                campos_defs.set_value('fecha_ip', fecha)
            } else {
                campos_defs.set_value("nro_moneda", param.moneda)
                campos_defs.set_value("concepto", param.concepto)
                $('credDestino').value = param.credito_bcra_desc
                campos_defs.set_value('fecha_ip', fecha.substr(8, 2) + "/" + fecha.substr(5, 2) + "/" + fecha.substr(0, 4))
                $('razonSocialCred').value = param.creditoRazonSocial
                campos_defs.set_value("dc_cuentas_tipo", param.creditoTipoCta)
            }
            campos_defs.habilitar("nro_moneda", false)
            campos_defs.habilitar("concepto", false)
            campos_defs.habilitar("dc_cuentas_tipo", false)
            campos_defs.set_value('nro_moneda', param.moneda)
            campos_defs.habilitar('dc_dg_dispositivos', true)
            campos_defs.set_value('dc_dg_dispositivos', param.tipoDispositivo)
            campos_defs.habilitar('dc_dg_dispositivos', false)
            campos_defs.habilitar('dc_dg_plataforma', true)
            campos_defs.set_value('dc_dg_plataforma', param.plataforma)
            campos_defs.habilitar('dc_dg_plataforma', false)
            campos_defs.habilitar('importe', true)
            campos_defs.set_value('importe', param.importe)
            campos_defs.habilitar('importe', false)

            campos_defs.habilitar('nro_moneda', false)
            campos_defs.habilitar('fecha_ip', false)

            $('tipoCtaDeb').value = param.creditoTipoCta
            $('internal_code').value = param.internalcode
            $('expTime').value = !fechaExp ? '' : fechaExp.substr(8, 2) + "/" + fechaExp.substr(5, 2) + "/" + fechaExp.substr(0, 4)
            $("cuentaDeb").value = param.debito_cbu
            $("cuitDestino").value = param.debito_cuit
            $("cbuDestino").value = param.debito_cbu
            //$("bncoDestino").value = param.debito_bco
            $('latitud').value = param.lat
            $('longitud').value = param.lng
            $('imsi').value = param.imsi
            $('imei').value = param.imei
            $('precision').value = param.precision
            $('ip_cliente').value = param.ipCli
            //$('puntaje').value = param.puntaje
            $('puntaje').innerHTML = 'Puntaje: ' + param.puntaje + ' |  Reglas: ' + param.reglas
            $('id_comprobante').value = param.idComprobante
            $('operador').value = param.login
            $('observacion').value = param.observacion
            $('id_user').value = param.idUsuario
            if (param.flag != 1) {
                $('razonSocial').value = param.debitoRazonSocial
                //$('tipo_cta_c').value = param.creditoTipoCta
                $('tipo_cta_d').value = param.debitoTipoCta
                $('credDestino').value = param.debito_bcra_desc
            }

            $('cuitDestino').disabled = true
            $('cbuDestino').disabled = true
            $('observacion').disabled = true
            $('sucursal').disabled = true
            $('id_user').disabled = true
            $('id_comprobante').disabled = true
            $('operador').disabled = true

            $("detCbuDeb").style.display = "table-cell"
            $("defCbuDeb").style.display = "none"
            $("tabPuntaje").style.display = "block"
            $("detCbuCred").style.display = "table-cell"
            $('tiempoExp').style.display = 'none'
            if (tipo_mov == 'D') {
                $('fechaExp').style.display = 'table-cell'
            }

            $('credDestino').value = param.debito_bcra_desc
            $('debBanco').value = param.credito_bcra_desc

            
            if (param.dc_estado != "") {
                $('estado').value = param.dc_id_estado + ' - ' + param.dc_estado
            } else {
                $('estado').value = param.dc_id_estado
            }

            //$('estado').value = param.dc_id_estado + (param.dc_estado != '' ? ' - ' + param.dc_estado : '')
            //$('estado').value = param.dc_id_estado + ' - ' + param.dc_estado //+ (param.res_codigo != '' ? ' - ' + param.res_codigo : '') + ' ' + (param.res_descripcion != '' ? ' - ' + param.res_descripcion : '')

            var rs = new tRS()
            rs.open({
                filtroXML: nvFW.pageContents.estadosDef,
                filtroWhere: "<criterio><select><filtro><id_dc_estado type='igual'>'" + param.dc_id_estado + "'</id_dc_estado></filtro></select></criterio>"
            })

            $('estado').style = 'width: 100%; text-align:center; ' + rs.getdata('css_style')

            avanzado()
        }

        function window_onload() {
            //campos_defs.items['cuit_entidades']["nvFW"] = nvFW

            if (win.options.userData.tipo == 'C') {
                $('refTab').style.display = 'none'
            }

            if (win.options.userData.tipo != '')
                campos_defs.set_value('mov_tipo', "\'" + win.options.userData.tipo + "\'")


            campos_defs.set_value('fecha_ip', nvFW.pageContents.date)
            campos_defs.habilitar('fecha_ip', false)


            window_onresize()
            tipo_mov = win.options.userData.tipo

            //$('imgIc').style.display = 'none'

            if (tipo_mov == 'C') {
                $('tiempoExp').style.display = 'none'
                $('fechaExp').style.display = 'none'
                $('expTit').style.display = 'none'
            }

            modo = !win.options.userData.modo ? 0 : win.options.userData.modo
            $('estado').style = 'width: 100%; text-align:center; '
            //PREGUNTA SI ESTAS LEVANTANDO UN MOVIMIENTO EXISTENTE PARA CARGAR LOS DETALLES.
            if (modo == 1) {
                if (tipo_mov == 'D') {
                    cargar_mov({
                        fecha_ip: win.options.userData.db_addDt,
                        db_fecha_expiracion: win.options.userData.db_fecha_expiracion,
                        concepto: win.options.userData.concepto,
                        moneda: win.options.userData.moneda,
                        credito_cuit: win.options.userData.credito_cuit,
                        credito_cbu: win.options.userData.credito_cbu,
                        credito_nro_sucursal: win.options.userData.credito_nro_sucursal,
                        creditoTipoCta: win.options.userData.creditoTipoCta,
                        creditoRazonSocial: win.options.userData.creditoRazonSocial,
                        credito_bcra_desc: win.options.userData.credito_bcra_desc,
                        debito_bcra_desc: win.options.userData.debito_bcra_desc,
                        debito_cbu: win.options.userData.debito_cbu,
                        debito_cuit: win.options.userData.debito_cuit,
                        debitoRazonSocial: win.options.userData.debitoRazonSocial,
                        debitoTipoCta: win.options.userData.debitoTipoCta,
                        dc_id_estado: win.options.userData.dc_id_estado,
                        res_descripcion: win.options.userData.res_descripcion,
                        res_codigo: win.options.userData.res_codigo,
                        dc_estado: win.options.userData.dc_estado,
                        importe: win.options.userData.importe,
                        tipoDispositivo: win.options.userData.tipoDisp,
                        plataforma: win.options.userData.plataforma,
                        lat: win.options.userData.lat,
                        lng: win.options.userData.lng,
                        precision: win.options.userData.precision,
                        ipCli: win.options.userData.ipCli,
                        idComprobante: win.options.userData.idComprobante,
                        login: win.options.userData.login,
                        idUsuario: win.options.userData.idUsuario,
                        debito_bco: win.options.userData.debito_bco,
                        observacion: win.options.userData.observacion,
                        internalcode: win.options.userData.internalcode,
                        reglas: win.options.userData.reglas,
                        puntaje: win.options.userData.puntaje,
                        bool: 1,
                    })

                    //$('imgIc').style.display = 'inline-block'
                    $('cabecera').style.display = 'none'
                } else {
                    cargar_mov({
                        fecha_ip: win.options.userData.db_addDt,
                        db_fecha_expiracion: win.options.userData.db_fecha_expiracion,
                        concepto: win.options.userData.concepto,
                        moneda: win.options.userData.moneda,
                        credito_cbu: win.options.userData.debito_cbu,
                        credito_cuit: win.options.userData.debito_cuit,
                        credito_nro_sucursal: win.options.userData.credito_nro_sucursal,
                        creditoTipoCta: win.options.userData.debitoTipoCta,
                        creditoRazonSocial: win.options.userData.debitoRazonSocial,
                        credito_bcra_desc: win.options.userData.debito_bcra_desc,
                        debito_bcra_desc: win.options.userData.credito_bcra_desc,
                        debito_cbu: win.options.userData.credito_cbu,
                        debito_cuit: win.options.userData.credito_cuit,
                        debitoRazonSocial: win.options.userData.creditoRazonSocial,
                        debitoTipoCta: win.options.userData.debitoTipoCta,
                        dc_id_estado: win.options.userData.dc_id_estado,
                        res_descripcion: win.options.userData.res_descripcion,
                        res_codigo: win.options.userData.res_codigo,
                        dc_estado: win.options.userData.dc_estado,
                        importe: win.options.userData.importe,
                        tipoDispositivo: win.options.userData.tipoDisp,
                        plataforma: win.options.userData.plataforma,
                        lat: win.options.userData.lat,
                        lng: win.options.userData.lng,
                        precision: win.options.userData.precision,
                        ipCli: win.options.userData.ipCli,
                        idComprobante: win.options.userData.idComprobante,
                        login: win.options.userData.login,
                        idUsuario: win.options.userData.idUsuario,
                        debito_bco: win.options.userData.debito_bco,
                        observacion: win.options.userData.observacion,
                        internalcode: win.options.userData.internalcode,
                        reglas: win.options.userData.reglas,
                        puntaje: win.options.userData.puntaje,
                        bool: 1,
                    })

                    //$('imgIc').style.display = 'inline-block'
                    $('cabecera').style.display = 'none'
                }
            }

            //Si es vacio el campo operador no lo muestra
            if ($('operador').value == '') {
                $('ope').style.display = 'none'
            }

        }

        function window_onresize() {
        }


        var nro_dc_mov
        var dc_id_estado

        //DISPARA EL AJAX QUE INICIA EL DEBIN O CREDIN
        function guardar() {
            var flag = 1
            //VALIDACIONES
            if ($('id_comprobante').value == '' || $('id_comprobante').value == 0) {
                alert('Ingrese el comprobante.')
                return
            }

            if ($('dc_definicion').value == '') {
                alert('Especifique la definición.')
                return
            }

            if ($('importe').value == '') {
                alert('Especifique el importe.')
                return
            }

            if ($('importe').value < 0) {
                alert('El importe debe ser un valor positivo.')
                return
            }

            if ($('cbuDestino').value == '') {
                alert('Seleccione el destino.')
                return
            }

            if ($('observacion').value == '' && tipo_mov == 'D') {
                alert('Ingrese una referencia.')
                return
            }


            if (flag == 1) {

                var credito_cbu = $('detCbuCred').value
                var credito_cuit = $('detCuitCred').value

                var debito_cuit = $('cuitDestino').value
                var debito_cbu = $('cbuDestino').value

                //PREGUNTA SI ES DEBIN O CREDIN
                if (tipo_mov == 'D') {
                    error_ajax_request("dc_acciones.aspx",
                        {
                            parameters: {
                                accion: tipo_mov,
                                nro_dc_mov_def: campos_defs.get_value('dc_definicion'),
                                credito_cuit: credito_cuit,
                                credito_cbu: credito_cbu,
                                credito_nro_bcra: '312',
                                credito_nro_sucursal: $('sucursal').value,
                                internalcode: $('internal_code').value,
                                debito_cuit: debito_cuit,
                                debito_cbu: debito_cbu,
                                concepto: $('concepto').value,
                                idUsuario: !$('id_user').value ? 0 : $('id_user').value,
                                idComprobante: !$('id_comprobante').value ? 0 : $('id_comprobante').value,
                                login: $('operador').value,
                                moneda: $('nro_moneda').value,
                                importe: $('importe').value,
                                tiempoExpiracion: $('tiempoExpiracion').value,
                                descripcion: $('observacion').value.replace(/(?:\r\n|\r|\n)/g, ''),
                                mismoTitular: 0,
                                ipCliente: $('ip_cliente').value,
                                tipoDispositivo: $('dc_dg_dispositivos').value,
                                plataforma: $('dc_dg_plataforma').value,
                                imsi: $('imsi').value,
                                imei: $('imei').value,
                                lat: $('latitud').value,
                                lng: $('longitud').value,
                                precision: $('precision').value
                            },
                            onSuccess: function (err, parametros) {
                                if (err.numError != 0) {
                                    alert(err.mensaje)
                                    return
                                }

                                nro_dc_mov = err.params.nro_dc_mov
                                dc_id_estado = err.params.dc_id_estado

                                //PROCESA EL XML Y LO TRANSFORMA EN JSON
                                var xmlString = err.params.respuesta
                                var xml = new DOMParser().parseFromString(xmlString, 'text/xml');
                                var params = xml.children

                                //INCERTA EL ID EN EL TITULO
                                $('menuItem_divMenu_0').style.display = 'none'
                                $('menuItem_divMenu_1').innerHTML = 'ID:' + params[0].childNodes[39].innerHTML

                                //ESTE RS BUSCA LOS ESTILOS PARA EL ESTADO QUE DEVUELVE EL AJAX
                                var rs = new tRS()

                                rs.open({
                                    filtroXML: nvFW.pageContents.estadosDef,
                                    filtroWhere: "<criterio><select><filtro><id_dc_estado type='igual'>'" + params[0].childNodes[40].innerHTML + "'</id_dc_estado></filtro></select></criterio>"
                                })

                                var rs_bco_deb = new tRS()

                                rs_bco_deb.open({
                                    filtroXML: nvFW.pageContents.bancoRs,
                                    filtroWhere: "<criterio><select><filtro><nro_bcra type='igual'>'" + params[0].childNodes[3].innerHTML.substring(0, 3) + "'</nro_bcra></filtro></select></criterio>"
                                })

                                var credito_bco = rs_bco_deb.getdata('bcra_desc')

                                var rs_bco_cred = new tRS()

                                rs_bco_cred.open({
                                    filtroXML: nvFW.pageContents.bancoRs,
                                    filtroWhere: "<criterio><select><filtro><nro_bcra type='igual'>'" + params[0].childNodes[7].innerHTML.substring(0, 3) + "'</nro_bcra></filtro></select></criterio>"
                                })

                                console.log(rs_bco_cred.getdata('bcra_desc'))


                                var debito_bco = rs_bco_cred.getdata('bcra_desc')

                                $('estado').style = rs.getdata('css_style')

                                //CARGA LOS VALORES QUE DEVUELVE EL AJAX EN LA MODAL QUE ESTA ABIERTA
                                cargar_mov({
                                    flag: 1,
                                    fecha_ip: params[0].childNodes[42].innerHTML,
                                    concepto: params[0].childNodes[9].innerHTML,
                                    moneda: params[0].childNodes[10].innerHTML,
                                    credito_cuit: params[0].childNodes[2].innerHTML,
                                    credito_cbu: params[0].childNodes[3].innerHTML,
                                    dc_id_estado: params[0].childNodes[40].innerHTML,
                                    importe: params[0].childNodes[11].innerHTML,
                                    debito_cbu: params[0].childNodes[7].innerHTML,
                                    credito_bcra_desc: credito_bco,
                                    debito_bcra_desc: debito_bco,
                                    debito_cuit: params[0].childNodes[6].innerHTML,
                                    credito_nro_sucursal: params[0].childNodes[5].innerHTML,
                                    tipoDispositivo: params[0].childNodes[18].innerHTML,
                                    plataforma: params[0].childNodes[19].innerHTML,
                                    lat: params[0].childNodes[22].innerHTML,
                                    lng: params[0].childNodes[23].innerHTML,
                                    imsi: params[0].childNodes[20].innerHTML,
                                    imei: params[0].childNodes[21].innerHTML,
                                    precision: params[0].childNodes[24].innerHTML,
                                    ipCliente: params[0].childNodes[17].innerHTML,
                                    idComprobante: params[0].childNodes[15].innerHTML,
                                    idUsuario: params[0].childNodes[14].innerHTML,
                                    db_fecha_expiracion: params[0].childNodes[43].innerHTML,
                                    internalcode: params[0].childNodes[25].innerHTML,
                                    observacion: params[0].childNodes[13].innerHTML,
                                    reglas: params[0].childNodes[38].innerHTML,
                                    puntaje: params[0].childNodes[37].innerHTML,
                                })
                                //win.close()
                            },
                            onFailure: function (err, parametros) {
                                //VALIDA SI SE GENERO UN ID, EN DADO CASO SE OCULTA EL BOTON DE "GENERAR DEBIN/CREDIN"
                                if (!err.params.dc_id) {
                                } else {
                                    $('menuItem_divMenu_0').style.display = 'none'
                                    $('menuItem_divMenu_1').innerHTML = 'ID:' + err.params.dc_id
                                }

                                if (err.numError != 0) {
                                    alert(err.mensaje)
                                    return
                                }

                                //ESTE CODIGO COMENTADO ES EN CASO DE RETOMAR EL APARTADO DE BORRADORES
                                //error_ajax_request("dc_acciones.aspx",iuj
                                //    {
                                //        parameters: {
                                //            accion: tipo_mov,
                                //            credito_cuit: credito_cuit,
                                //            credito_cbu: credito_cbu,
                                //            credito_nro_bcra: '312',
                                //            credito_nro_sucursal: $('sucursal').value,
                                //            debito_cuit: debito_cuit,
                                //            debito_cbu: debito_cbu,
                                //            concepto: $('concepto').value,
                                //            idUsuario: $('id_user').value,
                                //            idComprobante: $('id_comprobante').value,
                                //            moneda: $('nro_moneda').value,
                                //            importe: $('importe').value,
                                //            tiempoExpiracion: $('tiempoExpiracion').value,
                                //            descripcion: $('observacion').value,
                                //            mismoTitular: 0,
                                //            ipCliente: $('ip_cliente').value,
                                //            tipoDispositivo: $('dc_dg_dispositivos').value,
                                //            plataforma: $('dc_dg_plataforma').value,
                                //            imsi: $('imsi').value,
                                //            imei: $('imei').value,
                                //            lat: $('latitud').value,
                                //            lng: $('longitud').value,
                                //            precision: $('precision').value
                                //        },
                                //        bloq_msg: 'GUARDANDO BORRADOR...',
                                //        error_alert: false
                                //    })
                            },
                            bloq_msg: 'INICIANDO...',
                            error_alert: false
                        })
                } else {
                    error_ajax_request("dc_acciones.aspx",
                        {
                            parameters: {
                                accion: tipo_mov,
                                nro_dc_mov_def: campos_defs.get_value('dc_definicion'),
                                debito_cuit: credito_cuit,
                                debito_cbu: credito_cbu,
                                //debito_nro_bcra: '312',
                                //debito_nro_sucursal: $('sucursal').value,
                                credito_cuit: debito_cuit,
                                credito_cbu: debito_cbu,
                                credito_titular: $('razonSocial').value,
                                internalcode: $('internal_code').value,
                                concepto: $('concepto').value,
                                idUsuario: !$('id_user').value ? 0 : $('id_user').value,
                                idComprobante: !$('id_comprobante').value ? 0 : $('id_comprobante').value,
                                login: $('operador').value,
                                moneda: $('nro_moneda').value,
                                importe: $('importe').value,
                                tiempoExpiracion: $('tiempoExpiracion').value,
                                descripcion: $('observacion').value.replace(/(?:\r\n|\r|\n)/g, ''),
                                mismoTitular: 0,
                                ipCliente: $('ip_cliente').value,
                                tipoDispositivo: $('dc_dg_dispositivos').value,
                                plataforma: $('dc_dg_plataforma').value,
                                imsi: $('imsi').value,
                                imei: $('imei').value,
                                lat: $('latitud').value,
                                lng: $('longitud').value,
                                precision: $('precision').value
                            },
                            onSuccess: function (err, parametros) {

                                if (err.numError != 0) {
                                    alert(err.mensaje)
                                    return
                                }

                                //PROCESA EL XML Y LO TRANSFORMA EN JSON
                                var xmlString = err.params.respuesta
                                var xml = new DOMParser().parseFromString(xmlString, 'text/xml');
                                var params = xml.children

                                //INCERTA EL ID EN EL TITULO
                                $('menuItem_divMenu_0').style.display = 'none'
                                $('menuItem_divMenu_1').innerHTML = 'ID:' + params[0].childNodes[38].innerHTML

                                //ESTE RS BUSCA LOS ESTILOS PARA EL ESTADO QUE DEVUELVE EL AJAX
                                var rs = new tRS()

                                rs.open({
                                    filtroXML: nvFW.pageContents.estadosDef,
                                    filtroWhere: "<criterio><select><filtro><id_dc_estado type='igual'>" + params[0].childNodes[39].innerHTML + "</id_dc_estado></filtro></select></criterio>"
                                })

                                var rs_bco_deb = new tRS()

                                rs_bco_deb.open({
                                    filtroXML: nvFW.pageContents.bancoRs,
                                    filtroWhere: "<criterio><select><filtro><nro_bcra type='igual'>'" + params[0].childNodes[3].innerHTML.substring(0, 3) + "'</nro_bcra></filtro></select></criterio>"
                                })

                                var credito_bco = rs_bco_deb.getdata('bcra_desc')

                                var rs_bco_cred = new tRS()

                                rs_bco_cred.open({
                                    filtroXML: nvFW.pageContents.bancoRs,
                                    filtroWhere: "<criterio><select><filtro><nro_bcra type='igual'>'" + params[0].childNodes[8].innerHTML.substring(0, 3) + "'</nro_bcra></filtro></select></criterio>"
                                })

                                var debito_bco = rs_bco_cred.getdata('bcra_desc')

                                $('estado').style = rs.getdata('css_style')

                                //CARGA LOS VALORES QUE DEVUELVE EL AJAX EN LA MODAL QUE ESTA ABIERTA
                                cargar_mov({
                                    flag: 1,
                                    fecha_ip: params[0].childNodes[39].innerHTML,
                                    concepto: params[0].childNodes[12].innerHTML,
                                    moneda: params[0].childNodes[13].innerHTML,
                                    credito_cuit: params[0].childNodes[2].innerHTML,
                                    credito_cbu: params[0].childNodes[3].innerHTML,
                                    dc_id_estado: params[0].childNodes[41].innerHTML,
                                    importe: params[0].childNodes[14].innerHTML,
                                    debito_cbu: params[0].childNodes[8].innerHTML,
                                    credito_bcra_desc: credito_bco,
                                    debito_bcra_desc: debito_bco,
                                    debito_cuit: params[0].childNodes[7].innerHTML,
                                    credito_nro_sucursal: params[0].childNodes[5].innerHTML,
                                    tipoDispositivo: params[0].childNodes[19].innerHTML,
                                    plataforma: params[0].childNodes[20].innerHTML,
                                    lat: params[0].childNodes[23].innerHTML,
                                    lng: params[0].childNodes[24].innerHTML,
                                    imsi: params[0].childNodes[21].innerHTML,
                                    imei: params[0].childNodes[22].innerHTML,
                                    precision: params[0].childNodes[25].innerHTML,
                                    ipCliente: params[0].childNodes[27].innerHTML,
                                    idComprobante: params[0].childNodes[16].innerHTML,
                                    idUsuario: params[0].childNodes[15].innerHTML,
                                    //db_fecha_expiracion: params[0].childNodes[43].innerHTML,
                                    internalcode: params[0].childNodes[26].innerHTML,
                                    //observacion: params[0].childNodes[13].innerHTML,
                                    reglas: params[0].childNodes[38].innerHTML,
                                    puntaje: params[0].childNodes[37].innerHTML,
                                })

                            },
                            onFailure: function (err, parametros) {

                                //VALIDA SI SE GENERO UN ID, EN DADO CASO SE OCULTA EL BOTON DE "GENERAR DEBIN/CREDIN"
                                if (!err.params.dc_id) {
                                } else {
                                    $('menuItem_divMenu_0').style.display = 'none'
                                    $('menuItem_divMenu_1').innerHTML = 'ID:' + err.params.dc_id
                                }

                                if (err.numError != 0) {
                                    alert(err.mensaje)
                                    return
                                }

                                //ESTE CODIGO COMENTADO ES EN CASO DE RETOMAR EL APARTADO DE BORRADORES
                                //error_ajax_request("dc_acciones.aspx",
                                //    {
                                //        parameters: {
                                //            accion: tipo_mov,
                                //            credito_cuit: credito_cuit,
                                //            credito_cbu: credito_cbu,
                                //            credito_nro_bcra: '312',
                                //            credito_nro_sucursal: $('sucursal').value,
                                //            debito_cuit: debito_cuit,
                                //            debito_cbu: debito_cbu,
                                //            concepto: $('concepto').value,
                                //            idUsuario: $('id_user').value,
                                //            idComprobante: $('id_comprobante').value,
                                //            moneda: $('nro_moneda').value,
                                //            importe: $('importe').value,
                                //            tiempoExpiracion: $('tiempoExpiracion').value,
                                //            descripcion: $('observacion').value,
                                //            mismoTitular: 0,
                                //            ipCliente: $('ip_cliente').value,
                                //            tipoDispositivo: $('dc_dg_dispositivos').value,
                                //            plataforma: $('dc_dg_plataforma').value,
                                //            imsi: $('imsi').value,
                                //            imei: $('imei').value,
                                //            lat: $('latitud').value,
                                //            lng: $('longitud').value,
                                //            precision: $('precision').value
                                //        },
                                //        bloq_msg: 'GUARDANDO BORRADOR...',
                                //        error_alert: false
                                //    })
                            },
                            bloq_msg: 'INICIANDO...',
                            error_alert: false
                        })
                }
            }

        }

        function changeTit() {
            if ($('tipo_mov').value == 'D') {
                $('td_origen').innerHTML = 'Entidad Vendedora'
                $('td_destino').innerHTML = 'Entidad Compradora'
            }

            if ($('tipo_mov').value == 'C') {
                $('td_origen').innerHTML = 'Entidad Debito'
                $('td_destino').innerHTML = 'Entidad Credito'
            }

        }

        //MUESTRA O ESCONDE LA INFORMACION DE DE LA TERMINAL
        function avanzado() {

            if ($("datosGen").style.display == "none") {
                $("datosGen").style.display = "table"
                $("vMenuTit_img0").src = "/FW/image/icons/menos.jpg"
            } else {
                $("datosGen").style.display = "none"
                $("vMenuTit_img0").src = "/FW/image/icons/mas.jpg"
            }

        }


        function validarCbu() {
            if ($('img').src == 'https://lborda1921.redmutual.com.ar/FW/image/icons/confirmar.png') {
                if ($('cbuDestino').value != '') {

                    error_ajax_request("dc_acciones.aspx", {
                        parameters: {
                            accion: 'CCBU',
                            cbu: $('cbuDestino').value
                        },
                        onSuccess: function (err, transport) {
                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                            $('img').src = '../../FW/image/icons/editar.png'
                            $('cbuDestino').disabled = 'true'
                        },
                        onFailure: function (err, transport) {
                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                            win.close()
                        },
                        bloq_msg: 'VALIDANDO...',
                        error_alert: false
                    })

                } else {

                    alert("Debe ingresar un CBU")

                }
            } else {
                $('img').src = '../../FW/image/icons/confirmar.png'
                $('cbuDestino').disabled = 'false'
            }

        }

        //DISPARA UN AJAX QUE TRAE EL ESTADO ACTUAL
        function consultarEstado() {
            error_ajax_request("dc_acciones.aspx", {
                parameters: {
                    accion: 'CD',
                    id: win.options.userData.dc_id
                },
                onSuccess: function (err, transport) {
                    var xmlString = err.params.respuesta
                    var xml = new DOMParser().parseFromString(xmlString, 'text/xml');
                    var params = xml.children
                    $('estado').value = params[0].childNodes[37].innerHTML

                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    win.close()
                },
                onFailure: function (err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    win.close()
                },
                bloq_msg: 'VALIDANDO...',
                error_alert: false
            })
        }

        //LEVANTA LA MODAL QUE VALIDA EL CBU Y PRECARGA LOS DATOS RELACIONADOS A ESTE
        function seleccionEntidad() {

            var win_select = nvFW.createWindow({
                url: '/voii/debincredin/dc_mov_seleccionar.aspx',
                title: '<b>Seleccionar Cuenta Valida</b>',
                width: 500,
                height: 200,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })

            win_select.options.userData = {
                cuitInput: $("cuitDestino"),
                cbuInput: $("cbuDestino"),
                razonSocialInput: $("razonSocial"),
                banco: $("credDestino"),
                tipo_cta: $("tipo_cta_d"),
                eti_d: $("etiCBU_d"),
                eti_c: $("etiCBU_c"),
                importe: $("importe"),
                flag: 1
            }

            win_select.showCenter(true)
        }

        function abmDef() {

            var win_select = nvFW.createWindow({
                url: '/voii/debincredin/dc_definicion_ABM.aspx',
                title: '<b>ABM Definición</b>',
                width: 500,
                height: 400,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })

            win_select.showCenter(true)
        }

        //EN CASO DE QUE SE QUIERA HACER EDITABLE EL CODIGO INTERNO ESTA FUNCION ES FUNCIONAL, SOLO HAY QUE CAMBIAR EL DISPLAY A LA IMAGEN DE ID: 'ImgIc' QUE DISPARA ESTA FUNCION.
        function saveCod() {

            if ($('internal_code').value == '') {
                alert('Inserte el nuevo codigo interno')
                return
            }

            error_ajax_request("dc_mov.aspx", {
                parameters: {
                    internalcode: $('internal_code').value,
                    dc_id_mov: win.options.userData.nro_mov,
                    flag_ic: 1,
                },
                onSuccess: function (err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    parent.serchDeb()
                },
                onFailure: function (err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    win.close()
                },
                bloq_msg: 'GUARDANDO...',
                error_alert: false
            })
        }

        //MOSTRAR REPORTE DE UN USUARIO ESPECÍFICO SI EXISTE.
        function mostrarReporteDebinCredin(nro_mov) {
            if (typeof win.options.userData.nro_mov == 'undefined') {
                alert("No hay información para mostrar.")
            }
            else {
                nvFW.mostrarReporte({
                    filtroXML: nvFW.pageContents.dc_mov,
                    filtroWhere: "<criterio><select><filtro><nro_dc_mov type='igual'> " + nro_mov + " </nro_dc_mov></filtro></select></criterio>",
                    path_reporte: "report/credindebin/dc_comprobante.rpt",
                    salida_tipo: "adjunto",
                    content_disposition: "attachment",
                    filename: "Comprobante Nro " + (nro_mov.toString()).padStart(10, "0") + ".pdf",
                    bloq_contenedor: 'frame',
                    bloq_msg: "Cargando Información...",
                    bloq_id: "frame_detalle"
                })
            }
        }

    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <div id="divMenu" style="width: 100%; margin: 0; padding: 0;">
        <script type="text/javascript">
            var vMenu = new tMenu('divMenu', 'vMenu');

            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            var boton_imprimir_xsl = "<MenuItem id='2' style=''><Lib TipoLib='offLine'>DocMNG</Lib><icono>imprimir</icono><Desc>Descargar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarReporteDebinCredin(" + win.options.userData.nro_mov + ")</Codigo></Ejecutar></Acciones></MenuItem>"

            var boton_imprimir_dc = "<MenuItem id='2' style=''><Lib TipoLib='offLine'>DocMNG</Lib><icono>imprimir</icono><Desc>Descargar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarReporteDebinCredin(" + nro_dc_mov + ")</Codigo></Ejecutar></Acciones></MenuItem>"

            if (win.options.userData.modo != 1) {
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>confirmar</icono><Desc>Generar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%; height:24px'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            } else {
                if (win.options.userData.dc_id_estado == 'INICIADO' || win.options.userData.dc_id_estado == 'EN CURSO') {
                    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style=''><Lib TipoLib='offLine'>DocMNG</Lib><icono>historico</icono><Desc>Actualizar Estado</Desc><Acciones><Ejecutar Tipo='script'><Codigo>consultarEstado()</Codigo></Ejecutar></Acciones></MenuItem>")
                }
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%; height:24px'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ID: " + win.options.userData.dc_id + "</Desc></MenuItem>")
            }

            if (win.options.userData.dc_id_estado == 'ACREDITADO') {
                Menus["vMenu"].CargarMenuItemXML(boton_imprimir_xsl)
            } else if (dc_id_estado == 'ACREDITADO') {
                Menus["vMenu"].CargarMenuItemXML(boton_imprimir_dc)
            }

            vMenu.loadImage("nuevo", "/FW/image/icons/nueva.png");
            vMenu.loadImage("confirmar", "/FW/image/icons/confirmar.png");
            vMenu.loadImage("historico", "/FW/image/icons/historico.png");
            vMenu.loadImage("imprimir", "/FW/image/icons/file_pdf.png");

            vMenu.MostrarMenu()
        </script>
    </div>
    <div style="display: none">
        <script type="text/javascript">
            campos_defs.add('mov_tipo', {
                enDB: false,
                nro_campo_tipo: 104
            })
        </script>
    </div>
    <input id="nro_entidad_d" style="display: none" type="text" />
    <table class="tb1" id="cabecera">
        <tr>
            <td style="width: 5%" class="Tit1"><b>Definición:</b></td>
            <td style="width:95%">
                    <script type="text/javascript">
                        campos_defs.add('dc_definicion', {
                            enDB: true,
                            json: true,
                            onchange: function (event, campo_def) {
                                var rs_cdef = campos_defs.getRS(campo_def)

                                if ($('dc_definicion').value != '') {
                                    $('razonSocialCred').value = rs_cdef.getdata('razon_social')
                                    $('debBanco').value = rs_cdef.getdata('razon_social')
                                    $('sucursal').value = rs_cdef.getdata('nro_sucursal')
                                    $('detCuitCred').value = rs_cdef.getdata('cuitcuil')
                                    $('detCbuCred').value = rs_cdef.getdata('cbu')
                                    $('tiempoExpiracion').value = rs_cdef.getdata('tiempoExpiracion')
                                    campos_defs.habilitar("nro_moneda", true)
                                    campos_defs.habilitar("concepto", true)
                                    campos_defs.habilitar("dc_cuentas_tipo", true)
                                    campos_defs.set_value("nro_moneda", rs_cdef.getdata('moneda'))
                                    campos_defs.set_value("concepto", rs_cdef.getdata('id_dc_concepto'))
                                    campos_defs.set_value("dc_cuentas_tipo", rs_cdef.getdata('nro_dc_tipo_cta'))
                                    campos_defs.habilitar("nro_moneda", false)
                                    campos_defs.habilitar("concepto", false)
                                    campos_defs.habilitar("dc_cuentas_tipo", false)
                                } else {
                                    $('razonSocialCred').value = ''
                                    $('sucursal').value = ''
                                    $('detCuitCred').value = ''
                                    $('detCbuCred').value = ''
                                    $('tiempoExpiracion').value = ''
                                    campos_defs.clear("nro_moneda")
                                    campos_defs.clear("concepto")
                                    campos_defs.clear("dc_cuentas_tipo")
                                }

                            },
                            depende_de: 'mov_tipo',
                            depende_de_campo: 'dc_mov_tipo',
                            nro_campo_tipo: 1
                        })
                    </script>
            </td>            
        </tr>
    </table>
    
    <table class="tb1">
        <tr>
            <td style="width: 17%; text-align:center;" class="Tit1">Concepto</td>
            
            <td style="width: 13%; text-align:center;" id="expTit" class="Tit1">Tiempo Expiración</td>
            
            
            <td style="width: 13%; text-align:center;" id="feTit" class="Tit1">Fecha</td>
           
            <td style="width: 57%; text-align:center;" class="Tit1">Estado</td>
            
        </tr>
        <tr>
            <td style="width: 17%; text-align:center;">
                <script type="text/javascript">
                    campos_defs.add('concepto', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.conceptoDef,
                        nro_campo_tipo: 1
                    })
                    campos_defs.habilitar("concepto", false)
                </script>
            </td>
            <td id="tiempoExp" style="width: 13%">
                <select id="tiempoExpiracion" style="width: 100%" >
                    <option value="24">24 horas</option>
                    <option value="48">48 horas</option>
                    <option value="72">72 horas</option>
                </select>
            </td>
            <td id="fechaExp" style="display: none">
                <input type="text" id="expTime" style="width: 100%; text-align: right;" disabled />
            </td>
             <td style="width: 13%">
                <script type="text/javascript">
                    campos_defs.add('fecha_ip', { enDB: false, nro_campo_tipo: 103 })
                </script>
            </td>
            <td style="width: 57%;">
                <input id="estado" type="text" disabled />
                 <%--<script type="text/javascript">
                    campos_defs.add('estado', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.estadosDef,
                        nro_campo_tipo: 1
                    })
                    campos_defs.set_value('estado', 'P ')
                    campos_defs.habilitar('estado', false)
                </script>--%>
            </td>
        </tr>
    </table>
    <div id="instruccionesPago">
        <%-- Cabecera de la tabla Instruccion de Pago --%>
        <table class="tb1" style="width: 100%">
            <tr>
                <td style="width: 80%">
                    <table class="tb1" id="tbCabeceraIP">
                        <tr class="">
                            <td id='divMenuVen' colspan="4">
                                <%--<div id="divMenuVen" style="width: 100%; margin: 0; padding: 0;"></div>--%>
                                <script type="text/javascript">
                                    var vMenuVen = new tMenu('divMenuVen', 'vMenuVen');

                                    Menus["vMenuVen"] = vMenuVen;
                                    Menus["vMenuVen"].alineacion = 'centro';
                                    Menus["vMenuVen"].estilo = 'A';
                                    if (win.options.userData.tipo != 'D') {
                                        Menus["vMenuVen"].CargarMenuItemXML("<MenuItem id='0' style='width: 95%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>credin</icono><Desc>DEBITO</Desc></MenuItem>")

                                    } else {
                                        Menus["vMenuVen"].CargarMenuItemXML("<MenuItem id='0' style='width: 95%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>debin</icono><Desc>CREDITO</Desc></MenuItem>")
                                    }

                                    vMenuVen.loadImage("credin", "/voii/image/icons/credin.png");
                                    vMenuVen.loadImage("debin", "/voii/image/icons/debin.png");
                                    vMenuVen.loadImage("user", "/FW/image/icons/user2.png");
                                    vMenuVen.loadImage("nuevo", "/FW/image/icons/file.png");

                                    vMenuVen.MostrarMenu()
                                </script>
                            </td>
                        </tr>
                    </table>
                    <table class="tb1" id="defTabCred" >
                        <tr class="">
                            <td style="width: 100px" class="Tit1">Razón Social</td>
                            <td style="" id="td_entidad_origen">
                                <input id="razonSocialCred" type="text" placeholder="" style="width: 100%" disabled/>
                            </td>
                            <td style="width: 45px" class="Tit1">CUIT</td>
                            <td style="">
                                <input id="detCuitCred" type="text" placeholder="" style="width: 100%" disabled/>
                            </td>
                        </tr>
                    </table>
                    <table class="tb1" id="" >
                        <tr>
                            <td style="width: 7%" class="Tit1">Banco</td>
                            <td style="width: 15%">
                                <input id="debBanco" type="text" placeholder="" style="width: 100%" disabled/>
                            </td>
                            <td style="width: 7%" class="Tit1">Sucursal</td>
                            <td style="width: 5%">
                                <input id="sucursal" type="text" placeholder="" style="width: 100%" disabled/>
                            </td>
                            <td style="width: 10.5%" class="Tit1">Tipo Cuenta</td>
                            <td id="undef" style="width: 15%; display: none">
                                <input type="text" style="width: 100%" id="tipoCtaDeb" disabled/>
                            </td>
                            <td id="def" style="width: 20%">
                                <script type="text/javascript">
                                    campos_defs.add('dc_cuentas_tipo', {
                                        enDB: true
                                    })
                                    campos_defs.habilitar("dc_cuentas_tipo", false)
                                </script>
                            </td>
                            <td style="width: 5%" id="etiCBU_c" class="Tit1">CBU</td>
                            <td style="width: 30%">
                                <input style="width: 100%" type="text" id="detCbuCred" disabled />
                            </td>
                        </tr>
                    </table>
                    <table class="tb1" style="width: 100%">
                        <tr class="">
                            <td id='divMenuCom' colspan="4">
                                <script type="text/javascript">
                                    var vMenuCom = new tMenu('divMenuCom', 'vMenuCom');

                                    Menus["vMenuCom"] = vMenuCom;
                                    Menus["vMenuCom"].alineacion = 'centro';
                                    Menus["vMenuCom"].estilo = 'A';

                                    if (win.options.userData.tipo != 'D') {
                                        Menus["vMenuCom"].CargarMenuItemXML("<MenuItem id='0' style='width: 95%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>debin</icono><Desc>CREDITO</Desc></MenuItem>")

                                    } else {
                                        Menus["vMenuCom"].CargarMenuItemXML("<MenuItem id='0' style='width: 95%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>credin</icono><Desc>DEBITO</Desc></MenuItem>")
                                    }

                                    if (win.options.userData.modo != 1) {
                                        //Menus["vMenuCom"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Entidad ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevaCuenta('E')</Codigo></Ejecutar></Acciones></MenuItem>")
                                        Menus["vMenuCom"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>user</icono><Desc>Seleccionar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>seleccionEntidad()</Codigo></Ejecutar></Acciones></MenuItem>")
                                    }

                                    vMenuCom.loadImage("credin", "/voii/image/icons/credin.png");
                                    vMenuCom.loadImage("debin", "/voii/image/icons/debin.png");
                                    vMenuCom.loadImage("nuevo", "/FW/image/icons/file.png");
                                    vMenuCom.loadImage("user", "/FW/image/icons/user2.png");

                                    vMenuCom.MostrarMenu()
                                </script>
                            </td>
                        </tr>
                    </table>
                    <table id="defTabDeb" class="tb1"  style="display: none">
                        <tr>
                            <td style="width: 140px" id="td_entidad_destino">
                                <script type="text/javascript">
                                    var rs_cdef
                                    campos_defs.add('cuit_entidades', {
                                        json: true,
                                        StringValueIncludeQuote: true,
                                        onchange: function (event, campo_def) {
                                            rs_cdef = campos_defs.getRS(campo_def)
                                            var cont = 0
                                            var valor = ''
                                            while (valor == '') {
                                                if (rs_cdef.data[cont].id == $('cuit_entidades').value) {
                                                    valor = rs_cdef.data[cont].nro_entidad
                                                    $('nro_entidad_d').value = valor
                                                    return
                                                }
                                                cont = cont + 1
                                            }
                                        }
                                    })
                                </script>
                            </td>
                            <td style="width: 140px; display: none">
                                <input style="width: 100%" type="text" id="cuitDeb" disabled /></td>
                            <td id="detCbuDeb" style="width: 140px; display: none">
                                <input style="width: 100%" type="text" id="cuentaDeb" disabled /></td>
                            <td id="defCbuDeb" style="width: 140px">
                                <script type="text/javascript">
                                    campos_defs.add('ibs_cuecod', {
                                        enDB: false,
                                        filtroXML: nvFW.pageContents.cuentaDef,
                                        nro_campo_tipo: 1,
                                        depende_de: 'nro_entidad_d',
                                        depende_de_campo: 'id_tipo'
                                    })
                                </script>
                            </td>
                        </tr>
                    </table>
                    <table id="manualTabDeb" class="tb1" style="display: table">
                        <tr>
                            <td style="width: 100px" class="Tit1">Razón Social</td>
                            <td>
                                <input type="text" id="razonSocial" style="width: 100%" placeholder="" disabled />
                            </td>
                            <td style="width: 45px" class="Tit1">CUIT</td>
                            <td>
                                <input type="text" maxlength="11" id="cuitDestino" style="width: 100%" placeholder="" disabled />
                            </td>
                        </tr>
                    </table>
                    <table class="tb1">
                        <tr>
                            <td style="width: 20px" class="Tit1">BANCO</td>
                            <td>
                                <input type="text"id="credDestino" style="width: 100%" placeholder="" disabled />
                            </td>
                            <td style="width: 11%" class="Tit1">Tipo Cuenta</td>
                            <td>
                                <input id="tipo_cta_d" type="text" placeholder="" style="width: 100%" disabled/>
                            </td>
                            <td style="width: 20px" id="etiCBU_d" class="Tit1">CBU</td>
                            <td>
                                <input type="text" maxlength="22" id="cbuDestino" style="width: 100%" placeholder="" disabled />
                            </td>
                        </tr>
                    </table>
                </td>
                <td>
                    <table  class="tb1">
                        <tr class="tbLabel">
                            <td colspan="2" style="text-align: center">Código Moneda</td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <script type="text/javascript">
                                    campos_defs.add('nro_moneda', {
                                        enDB: false,
                                        filtroXML: nvFW.pageContents.monedaDef,
                                        nro_campo_tipo: 1
                                    })
                                    campos_defs.set_value('nro_moneda', 32)
                                    campos_defs.items['nro_moneda'].onchange = function (campo_def) {
                                        if ($('nro_moneda').value == 32) {
                                            $('prefijo').innerHTML = '$'
                                        } else if ($('nro_moneda').value == 978) {
                                            $('prefijo').innerHTML = 'EURO'
                                        } else {
                                            $('prefijo').innerHTML = 'U$D'
                                        }
                                    }
                                    campos_defs.habilitar("nro_moneda", false)

                                </script>
                            </td>
                        </tr>
                        <tr class="tbLabel">
                            <td colspan="2" style="text-align: center">Importe </td>
                        </tr>
                        <tr>
                            <td id="prefijo" class="Tit1" style="width: 25%; text-align: center">$ </td>
                            <td style="text-align: right; width: 80%">
                                <div style="width: 100%; display: inline-block;" id="div_importe">
                                    <script type="text/javascript">
                                        campos_defs.add('importe', {
                                            enDB: false,
                                            nro_campo_tipo: 102,
                                            mask: {
                                                mask: Number,
                                                scale: 2, //dígitos después del punto
                                                radix: ',', //separador de decimales
                                                mapToRadix: ['.'],  //separador de decimales sin mascara
                                                padFractionalZeros: true,  //si es verdadero, coloca ceros al final de la escala
                                                thousandsSeparator: '.' //separador de miles
                                            }
                                        })
                                    </script>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
      
        <table id="refTab" class="tb1">
            <tr class="tbLabel">
                <td style="text-align: center" id="obsercvacion">Referencia</td>
            </tr>
            <tr>
                <td style="text-align: center; align-items: center; margin: auto">
                    <textarea style="margin: auto; resize: none; width: 100%" id="observacion" onkeypress="return ( this.value.length < 100 )" cols="160" rows="5" placeholder="Ingrese referencia..."></textarea>
                </td>
            </tr>
        </table>
          <div id="divMenuComp" style="width: 100%; margin: 0; padding: 0;"></div>
        <script type="text/javascript">
            var vMenuComp = new tMenu('divMenuComp', 'vMenuComp');

            Menus["vMenuComp"] = vMenuComp
            Menus["vMenuComp"].alineacion = 'centro';
            Menus["vMenuComp"].estilo = 'A';

            Menus["vMenuComp"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos Complementarios</Desc></MenuItem>")

            vMenuComp.MostrarMenu()
        </script>
        <table class="tb1" style="width: 100%">
            <tr>
                <td style="width: 10%" class="Tit1">Código Interno</td>
                <td style="width: 86%">
                    <script type="text/javascript">
                        campos_defs.add('internal_code', {
                            enDB: false,
                            nro_campo_tipo: 104
                        });
                    </script>
                    <%--<input id="internal_code" type="text" style="width: 98%" />--%>
                    <img id="imgIc" style="width: 16px; cursor:pointer; margin-left:2px; display:none" onclick="saveCod()" title="Guardar Codigo Interno" src="/FW/image/icons/guardar.png"/>
                </td>
            </tr>
        </table>
        <table  class="tb1" style="width: 100%;">
            <tr>
                <td style="width: 5%" class="Tit1">User</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('id_user', {
                            enDB: false,
                            nro_campo_tipo: 104
                        });
                    </script>
                    <%--<input id="id_user" type="text" style="width: 100%" disabled />--%>

                </td>
                <td style="width: 10%" class="Tit1">Comprobante</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('id_comprobante', {
                            enDB: false,
                            nro_campo_tipo: 101
                        });
                    </script>
                    <%--<input id="id_comprobante" type="number" style="width: 100%" />--%>

                </td>
            </tr>
            <tr id='ope'>
                <td style="width: 7%" class="Tit1">Operador</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('operador', {
                            enDB: false,
                            nro_campo_tipo: 104
                        });
                    </script>
                   
                </td>
            </tr>
        </table>
        <table  class="tb1" style="width: 100%; display:none" id="tabPuntaje">
            <tr>
                <td class="Tit1" style="width: 80px">Evaluación</td><td id="puntaje" >Puntaje: -  |  Reglas: -</td>
            </tr>
        </table>
        <div id="divMenuTit" style="width: 100%; margin: 0; padding: 0;"></div>
        <script type="text/javascript">
            var vMenuTit = new tMenu('divMenuTit', 'vMenuTit');

            Menus["vMenuTit"] = vMenuTit
            Menus["vMenuTit"].alineacion = 'centro';
            Menus["vMenuTit"].estilo = 'A';

            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='1' style='width: 98%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Información de la terminal</Desc></MenuItem>")
            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='0' style='width: 2%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>mas</icono><Desc></Desc><Acciones><Ejecutar Tipo='script'><Codigo>avanzado()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuTit.loadImage("mas", "/FW/image/icons/mas.jpg");

            vMenuTit.MostrarMenu()
        </script>
    <div id="datosGen" style="display: none">
        <table  class="tb1">
            <tr>
                <td>
                    <table class="tb1" id="datos_otros">
                        <tr class="tbLabel">
                            <td colspan="5" style="text-align: center">DISPOSITIVO</td>
                        </tr>
                        <tr class="tbLabel">
                            <td style="text-align: center">Ip Cliente</td>
                            <td style="text-align: center">Plataforma</td>
                            <td style="text-align: center">Tipo Dispositivo</td>
                            <td style="text-align: center">MSI</td>
                            <td style="text-align: center">IMEI</td>
                        </tr>
                        <tr>
                            <td>
                                <input id="ip_cliente" type="text" style="width: 100%" disabled />
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('dc_dg_plataforma')
                                    campos_defs.habilitar('dc_dg_plataforma', false)
                                </script>
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('dc_dg_dispositivos')
                                    campos_defs.habilitar('dc_dg_dispositivos', false)
                                </script>
                            </td>
                            <td>
                                <input id="imsi" type="text" style="width: 100%" disabled />
                            </td>
                            <td>
                                <input id="imei" type="text" style="width: 100%" disabled />
                            </td>
                        </tr>
                    </table>
                </td>
                <td>
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td colspan="3" style="text-align: center">UBICACIÓN</td>
                        </tr>
                        <tr class="tbLabel">
                            <td style="text-align: center">Latitud
                            </td>
                            <td style="text-align: center">Longitud
                            </td>
                            <td style="text-align: center">Precisión
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input id="latitud" type="text" style="width: 100%" disabled />
                            </td>
                            <td>
                                <input id="longitud" type="text" style="width: 100%" disabled />
                            </td>
                            <td>
                                <input id="precision" type="text" style="width: 100%" disabled />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
        <%-- Datos de la tabla Instruccion de Pago --%>
        <div id="divDatosIP" style="overflow: auto;">
            <table class="tb1" id="datosIP">
                <tr id="tr_dato">
                </tr>
            </table>
        </div>
</body>
</html>
