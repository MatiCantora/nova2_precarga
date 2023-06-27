<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<% 
    Dim modo = nvUtiles.obtenerValor("modo", 0)
    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim err = New nvFW.tError()
    Me.contents("date") = DateTime.Now.ToShortDateString()


    'Dim nro_dc_mov = nvUtiles.obtenerValor("nro_dc_mov", "")
    'Dim cuit_destino = nvUtiles.obtenerValor("cuit_destino", "")
    'Dim cuit_origen = nvUtiles.obtenerValor("cuit_origen", "")
    'Dim cbu_destino = nvUtiles.obtenerValor("cbu_destino", "")
    'Dim cbu_origen = nvUtiles.obtenerValor("cbu_origen", "")
    'Dim estado = nvUtiles.obtenerValor("estado", "")
    'Dim importe = nvUtiles.obtenerValor("importe", "")
    'Dim nro_pago_conceptos = nvUtiles.obtenerValor("nro_pago_conceptos", "")
    'Dim tipo = nvUtiles.obtenerValor("tipo", "")
    'Dim id_usuario = nvUtiles.obtenerValor("id_usuario", "")
    'Dim id_comprobante = nvUtiles.obtenerValor("id_comprobante", "")
    'Dim nro_moneda = nvUtiles.obtenerValor("nro_moneda", "")
    'Dim dato_generado = nvUtiles.obtenerValor("dato_generado", "")
    'Dim ip_cliente = nvUtiles.obtenerValor("ip_cliente", "")
    'Dim plataforma = nvUtiles.obtenerValor("plataforma", "")
    'Dim sim = nvUtiles.obtenerValor("sim", "")
    'Dim email = nvUtiles.obtenerValor("email", "")
    'Dim latitud = nvUtiles.obtenerValor("latitud", "")
    'Dim longitud = nvUtiles.obtenerValor("longitud", "")
    'Dim observacion = nvUtiles.obtenerValor("observacion", "")

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

            err.params.Add("nro_archivo_def_grupo", rs.Fields("nro_archivo_def_grupo").Value)
            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value

            'If modo = 1 Then
            '    DBExecute("UPDATE dc_mov SET credito_cuit = cuit_origen, debito_cuit = " & cuit_destino & ", credito_cbu = " & cbu_origen & ", debito_cbu = " & cbu_destino & ", dc_mov_tipo = " & tipo & ", id_dc_estado = " & estado & ", importe = " & importe)
            '    'DBExecute("UPDATE dc_mov SET credito_cuit = cuit_origen, debito_cuit = " & cuit_destino & ", credito_cbu = " & cbu_origen & ", debito_cbu = " & cbu_destino & ", dc_mov_tipo = " & tipo & ", id_dc_estado = " & estado & ", importe = " & importe & ", idUsuario = " & id_usuario & ", idComprobante = " & id_comprobante & ", moneda = " & nro_moneda & ", dg_ipCliente = " & ip_cliente & ",dg_plataforma = " & plataforma & ",dg_imsi = " & sim & ",dg_lat = " & latitud & ",dg_lng = " & longitud & ",descripcion = " & observacion & " WHERE nro_dc_mov = " & nro_dc_mov)
            'ElseIf modo = 0 Then
            '    Dim teest = "INSERT INTO dc_mov (credito_cuit,debito_cuit,credito_cbu,debito_cbu,dc_mov_tipo,id_dc_estado,descripcion,importe) VALUES ('" & cbu_destino & "','" & cbu_origen & "','" & cuit_destino & "','" & cuit_origen & "','" & tipo & "','" & estado & "','" & observacion & "'," & importe & ")"
            '    DBExecute("INSERT INTO dc_mov (credito_cuit,debito_cuit,credito_cbu,debito_cbu,dc_mov_tipo,id_dc_estado,descripcion,importe) VALUES ('" & cbu_destino & "','" & cbu_origen & "','" & cuit_destino & "','" & cuit_origen & "','" & tipo & "','" & estado & "','" & observacion & "'," & importe & ")")
            '    'DBExecute("INSERT INTO dc_mov (credito_cuit,debito_cuit,credito_cbu,debito_cbu,dc_mov_tipo,id_dc_estado,importe,idUsuario,idComprobante,moneda,dg_ipCliente,dg_plataforma,dg_imsi,dg_lat,dg_lng,descripcion) VALUES ('" & cbu_destino & "','" & cbu_origen & "','" & cuit_destino & "','" & cuit_origen & "','" & tipo & "','" & estado & "'," & importe & ",'" & id_usuario & "','" & id_comprobante & "'," & nro_moneda & ",'" & ip_cliente & "','" & plataforma & "','" & sim & "'," & latitud & "," & longitud & ",'" & observacion & "')")
            'End If
        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del parametro"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Dim operador As Object
    Try
        operador = nvFW.nvApp.getInstance().operador

        ' Pasar las variables al browser (cliente)
        Me.contents("operador_login") = operador.login
        Me.contents("operador_nombre") = operador.nombre_operador
        Me.contents("operador_nro") = operador.operador
        Me.contents("operador_nro_sucursal") = operador.nro_sucursal
        Me.contents("operador_sucursal") = operador.sucursal
    Catch ex As Exception
    End Try

    Me.contents("entidadDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Entidades'><campos>cuit as id, Razon_social as campo, nro_entidad</campos><filtro></filtro></select></criterio>")
    Me.contents("cuentaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_cuentas'><campos>id_tipo as id, CBU as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("bancoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Entidades'><campos>cuit as id, Razon_social as campo, nro_entidad</campos><filtro><Razon_social type='like'>%BANCO%</Razon_social></filtro></select></criterio>")
    Me.contents("tipoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov_tipos'><campos>dc_mov_tipo as id, dc_mov_tipo_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("estadosDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_estados'><campos>id_dc_estado as id, dc_estado as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("conceptoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_conceptos'><campos>id_dc_concepto as id, dc_concepto as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("monedaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='moneda'><campos>ISO_num as id, ISO_cod as campo</campos><filtro><activo type='igual'>1</activo></filtro><orden>campo</orden></select></criterio>")

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Nuevo CREDIN / DEBIN</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/tListButton.css" type="text/css" rel="stylesheet" />
    <%-- Se agrega a "pata" porque se usa una clase para botones --%>
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

        function cargar_mov(param) {

            if (!param) {
                param = {}
            }

            $('expTit').innerHTML = 'Fecha de Expiración: '

            nro_dc_mov = win.options.userData.nro_dc_mov

            param.fecha_ip = !param.fecha_ip ? '' : param.fecha_ip
            param.concepto = !param.concepto ? '' : param.concepto
            param.moneda = !param.moneda ? '' : param.moneda
            param.credito_cuit = !param.credito_cuit ? '' : param.credito_cuit
            param.tipoDispositivo = !param.tipoDispositivo ? '' : param.tipoDispositivo
            param.plataforma = !param.plataforma ? '' : param.plataforma
            param.dc_id_estado = !param.dc_id_estado ? '' : param.dc_id_estado
            param.importe = !param.importe ? '' : param.importe
            param.debito_cbu = !param.debito_cbu ? '' : param.debito_cbu
            param.credito_cbu = !param.credito_cbu ? '' : param.credito_cbu
            param.sucursal = !param.sucursal ? '' : param.sucursal
            param.lat = !param.lat ? '' : param.lat
            param.lng = !param.lng ? '' : param.lng
            param.precision = !param.precision ? '' : param.precision
            param.ipCli = !param.ipCli ? '' : param.ipCli
            param.puntaje = !param.puntaje ? '' : param.puntaje

            campos_defs.set_value('fecha_ip', param.fecha_ip)
            campos_defs.set_value('concepto', param.concepto)
            campos_defs.set_value('nro_moneda', param.moneda)
            campos_defs.set_value('nrodoc_bco', param.credito_cuit)
            campos_defs.set_value('dc_dg_dispositivos', param.tipoDispositivo)
            campos_defs.set_value('dc_dg_plataforma', param.plataforma)
            //campos_defs.set_value('cuit_entidades', param.debito_cuit)

            campos_defs.habilitar('nrodoc_bco', false)
            campos_defs.habilitar('concepto', false)
            campos_defs.habilitar('nro_moneda', false)
            campos_defs.habilitar('fecha_ip', false)
            campos_defs.habilitar('cuit_entidades', false)

            $('estado').value = param.dc_id_estado
            $('importe').value = param.importe
            $("cuentaDeb").value = param.debito_cbu
            $("cuitDestino").value = param.debito_cuit
            $("cbuDestino").value = param.debito_cbu
            $("cuentaCred").value = param.credito_cbu
            $('sucursal').value = param.sucursal
            $('latitud').value = param.lat
            $('longitud').value = param.lng
            $('precision').value = param.precision
            $('ip_cliente').value = param.ipCli
            $('puntaje').value = param.puntaje

            $('cuitDestino').disabled = true
            $('cbuDestino').disabled = true
            $('importe').disabled = true
            $('observacion').disabled = true
            $('sucursal').disabled = true
            $('id_user').disabled = true
            $('id_comprobante').disabled = true

            $("detCbuDeb").style.display = "table-cell"
            $("defCbuDeb").style.display = "none"
            $("tabPuntaje").style.display = "block"
            $("detCbuCred").style.display = "table-cell"
            $("defCbuCred").style.display = "none"
            $('tiempoExp').style.display = 'none'
            $('fechaExp').style.display = 'table-cell'

            avanzado()

            //campos_defs.set_value('', winParam.options.userData.fecha_estado) 
            //campos_defs.set_value('estado', win.options.userData.estado) 
            //campos_defs.habilitar('estado', false)    
            //$('dc_id').value = win.options.userData.dc_id 
            //$('dc_id_estado').value = win.options.userData.dc_id_estado 
            //$('dc_estado').value = win.options.userData.dc_estado 
            //$('db_addDt').value = win.options.userData.db_addDt 
            //$('db_fecha_expiracion').value = win.options.userData.db_fecha_expiracion 
        }

        function window_onload() {
            campos_defs.items['cuit_entidades']["nvFW"] = nvFW

            campos_defs.set_value('fecha_ip', nvFW.pageContents.date)
            campos_defs.habilitar('fecha_ip', false)

            window_onresize()
            tipo_mov = win.options.userData.tipo

            modo = !win.options.userData.modo ? 0 : win.options.userData.modo
            if (modo == 1) {
                cargar_mov({
                    fecha_ip: win.options.userData.db_addDt,
                    concepto: win.options.userData.concepto,
                    moneda: win.options.userData.moneda,
                    credito_cuit: win.options.userData.credito_cuit,
                    credito_cbu: win.options.userData.credito_cbu,
                    dc_id_estado: win.options.userData.dc_id_estado,
                    importe: win.options.userData.importe,
                    debito_cbu: win.options.userData.debito_cbu,
                    debito_cuit: win.options.userData.debito_cuit,
                    credito_nro_sucursal: win.options.userData.credito_nro_sucursal,
                    tipoDispositivo: win.options.userData.tipoDispositivo,
                    plataforma: win.options.userData.plataforma,
                    lat: win.options.userData.lat,
                    lng: win.options.userData.lng,
                    precision: win.options.userData.precision,
                    ipCliente: win.options.userData.ipCliente,
                })

            } else {
                campos_defs.set_value('nrodoc_bco', 30546741636)
                campos_defs.habilitar('nrodoc_bco', false)   
            }

            //campos_defs.set_value("fecha_ip", nvFW.FechaToSTR(new Date()))

            //ar_resumen["operador"] = []
            //ar_resumen["operador"]["login"] = nvFW.pageContents.operador_login
            //ar_resumen["operador"]["nombre"] = nvFW.pageContents.operador_nombre
            //ar_resumen["operador"]["nro"] = nvFW.pageContents.operador_nro
            //ar_resumen["operador"]["nro_sucursal"] = nvFW.pageContents.operador_nro_sucursal
            //ar_resumen["operador"]["sucursal"] = nvFW.pageContents.operador_sucursal

        }

        function window_onresize() {

        }

        function guardar() {
            var flag = 1

            //if ($('concepto').value == '') {
            //    alert('Especifique el concepto.')
            //}

            //if ($('importe').value == '') {
            //    alert('Especifique el importe.')
            //}

            //if ($('cuitOrigen').value == '' && $('nrodoc_bco').value == '') {
            //    flag = 0
            //    if ($("manualTabCred").style.display == "none") {
            //        alert('Seleccione la entidad que emite el credito.')
            //    } else {
            //        alert('Ingrese el cuit de la entidad que emite el credito.')
            //    }
            //}

            //if ($('cuitOrigen').value == '' && $('ibs_cuecod_bco').value == '') {
            //    flag = 0
            //    if ($("manualTabCred").style.display == "none") {
            //        alert('Seleccione la cuenta de la entidad que emite el credito.')
            //    } else {
            //        alert('Ingrese el cbu de la entidad que emite el credito.')

            //    }
            //}

            //if ($('cbuDestino').value == '' && $('cuit_entidades').value == '') {
            //    flag = 0
            //    if ($("manualTabCred").style.display == "none") {
            //        alert('Seleccione la entidad que recibe el credito.')
            //    } else {
            //        alert('Ingrese el cuit de la entidad que recibe el credito.')
            //    }
            //}

            //if ($('cuitDestino').value == '' && $('ibs_cuecod').value == '') {
            //    flag = 0
            //    if ($("manualTabCred").style.display == "none") {
            //        alert('Seleccione la cuenta de la entidad que recibe el credito.')
            //    } else {
            //        alert('Ingrese el cbu de la entidad que recibe el credito.')
            //    }
            //}


            if (flag == 1) {

                if ($("manualTabCred").style.display == "none") {
                    var credito_cbu = campos_defs.get_desc('ibs_cuecod_bco').substr(0, 22)
                    var credito_cuit = $('nrodoc_bco').value
                } else {
                    var credito_cbu = $('cbuOrigen').value
                    var credito_cuit = $('cuitOrigen').value
                }

                if ($("manualTabDeb").style.display == "none") {
                    var debito_cuit = $('cuit_entidades').value
                    var debito_cbu = campos_defs.get_desc('ibs_cuecod').substr(0, 22)
                } else {
                    var debito_cuit = $('cbuDestino').value
                    var debito_cbu = $('cbuDestino').value
                }

                /*var tipo = tipo_mov
                var estado = $('estado').value
                var nro_pago_conceptos = $('concepto').value
                var importe = $('importe').value
                var id_user = $('id_user').value
                var id_comprobante = $('id_comprobante').value
                var nro_moneda = $('nro_moneda').value
                var ip_cliente = $('ip_cliente').value
                //var plataforma = $('plataforma').value
                var observacion = $('observacion').value
                var email = $('email').value
                var latitud = $('latitud').value
                var longitud = $('longitud').value

                credito_cuit = '<![CDATA[' + credito_cuit + ']]>'
                credito_cbu = '<![CDATA[' + credito_cbu + ']]>'
                debito_cuit = '<![CDATA[' + debito_cuit + ']]>'
                debito_cbu = '<![CDATA[' + debito_cbu + ']]>'
                tipo = '<![CDATA[' + tipo + ']]>'
                nro_pago_conceptos = '<![CDATA[' + nro_pago_conceptos + ']]>'
                //importe = '<![CDATA[' + importe + ']]>'
                id_user = '<![CDATA[' + id_user + ']]>'
                id_comprobante = '<![CDATA[' + id_comprobante + ']]>'
                //nro_moneda = '<![CDATA[' + nro_moneda + ']]>'
                observacion = '<![CDATA[' + observacion + ']]>'
                estado = '<![CDATA[' + estado + ']]>'

                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<dc_mov modo='" + modo + "' nro_dc_mov='" + nro_dc_mov + "'>"
                xmldato += "<credito_cuit>" + credito_cuit + "</credito_cuit>"
                xmldato += "<credito_cbu>" + credito_cbu + "</credito_cbu>"
                xmldato += "<debito_cuit>" + debito_cuit + "</debito_cuit>"
                xmldato += "<debito_cbu>" + debito_cbu + "</debito_cbu>"
                xmldato += "<dc_mov_tipo>" + tipo + "</dc_mov_tipo>"
                xmldato += "<id_dc_concepto>" + nro_pago_conceptos + "</id_dc_concepto>"
                xmldato += "<moneda>" + nro_moneda + "</moneda>"
                xmldato += "<importe>" + importe + "</importe>"
                xmldato += "<descripcion>" + observacion + "</descripcion>"
                xmldato += "</dc_mov>"*/

                error_ajax_request("dc_acciones.aspx",
                    {
                        parameters: {
                            //strXML: xmldato
                            //accion: 'D',
                            //credito_cuit: credito_cuit,
                            //credito_cbu: credito_cbu,
                            //credito_nro_bcra: '312',// $('').value,
                            //credito_nro_sucursal: $('sucursal').value,
                            //debito_cuit: debito_cuit,
                            //debito_cbu: debito_cbu,
                            //concepto: $('concepto').value,
                            //idUsuario: $('id_user').value,
                            //idComprobante: $('id_comprobante').value,
                            //moneda: $('nro_moneda').value,
                            //importe: $('importe').value,
                            //tiempoExpiracion: $('tiempoExpiracion').value,
                            //descripcion: $('observacion').value,
                            //mismoTitular:  0,// $('').value,
                            //ipCliente: $('ip_cliente').value,
                            //tipoDispositivo: $('dc_dg_dispositivos').value,
                            //plataforma: $('dc_dg_plataforma').value,
                            //imsi: $('imsi').value,
                            //imei: $('imei').value,
                            //lat: $('latitud').value,
                            //lng: $('longitud').value,
                            //precision: $('precision').value
                            accion: "D",
                            credito_cuit: "30546741636",
                            credito_cbu: "3120001901000110001992",
                            credito_nro_bcra: "312",
                            credito_nro_sucursal: "0001",
                            debito_cuit: "23237103769",
                            debito_cbu: "3120001902000000000668",
                            concepto: "PLF",
                            moneda: "032",
                            importe: 9.99,
                            tiempoExpiracion: 48,
                            descripcion: "prueba001",
                            mismoTitular: 0,
                            idUsuario: 99,
                            idComprobante: 99,
                            ipCliente: "127.0.0.1",
                            tipoDispositivo: "04",
                            plataforma: "01",
                            imsi: "",
                            imei: "",
                            lat: 0,
                            lng: 0,
                            precision: ""
                        },
                        onSuccess: function (err, parametros) {

                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                            
                            var xmlString = err.params.respuesta
                            console.log(xml)
                            var xml = new DOMParser().parseFromString(xmlString, 'text/xml');
                            var params = xml.children

                            cargar_mov({
                                fecha_ip: params[0].childNodes[38].innerHTML,
                                concepto: params[0].childNodes[7].innerHTML,
                                moneda: params[0].childNodes[8].innerHTML,
                                credito_cuit: params[0].childNodes[1].innerHTML,
                                credito_cbu: params[0].childNodes[2].innerHTML,
                                dc_id_estado: params[0].childNodes[37].innerHTML,
                                importe: params[0].childNodes[9].innerHTML,
                                debito_cbu: params[0].childNodes[6].innerHTML,
                                debito_cuit: params[0].childNodes[5].innerHTML,
                                credito_nro_sucursal: win.options.userData.credito_nro_sucursal,
                                tipoDispositivo: params[0].childNodes[16].innerHTML,
                                plataforma: params[0].childNodes[17].innerHTML,
                                lat: params[0].childNodes[20].innerHTML,
                                lng: params[0].childNodes[21].innerHTML,
                                precision: params[0].childNodes[22].innerHTML,
                                ipCliente: params[0].childNodes[15].innerHTML,
                            })


                            //win.close()
                        },
                        onFailure: function (err, parametros) {

                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                        },
                        bloq_msg: 'GUARDANDO...',
                        error_alert: false
                    })
            }
            
        }

        function habilitarCuit() {
            if ($('cbuOrigenCheck').checked == true) {
                $('cbuOrigen').disabled = false
                $('cbuOrigen').value = ''
                campos_defs.habilitar('nrodoc_bco', false)
                campos_defs.clear('nrodoc_bco')
            } else {
                $('cbuOrigen').disabled = true
                $('cbuOrigen').value = ''
                campos_defs.habilitar('nrodoc_bco', true)
                campos_defs.clear('nrodoc_bco')
            }

            if ($('cbuDestinoCheck').checked == true) {
                $('cbuDestino').disabled = false
                $('cbuDestino').value = ''
                campos_defs.habilitar('cuit_entidades', false)
                campos_defs.clear('cuit_entidades')
            } else {
                $('cbuDestino').disabled = true
                $('cbuDestino').value = ''
                campos_defs.habilitar('cuit_entidades', true)
                campos_defs.clear('cuit_entidades')
            }
        }

        function changeTit() {
            if ($('tipo_mov').value == 'D') {
                $('td_origen').innerHTML = 'Entidad Vendedora'
                $('td_destino').innerHTML = 'Entidad Compradora'
            }

            if ($('tipo_mov').value == 'C')    {
                $('td_origen').innerHTML = 'Entidad Debito'
                $('td_destino').innerHTML = 'Entidad Credito'
            }

        }

        function enviarMail() {
            var subject = 'Notificación - Instrucción de Pago - ' + ar_resumen.cabecera.concepto.split("(")[0]
            var body = "<span><style type='text/css'>*{font-family:Tahoma,Arial,sans-serif;font-size:13px;}.tb{width:100%;border-collapse:collapse;}.tb th,.tb td{border:1px solid grey;text-align:center;}</style></span>"
            body += "<table class='tb'>"
            body += '<tr><th>Nro. Proceso</th><th>Concepto</th><th>Estado</th><th>Operador</th></tr>'
            body += '<tr>'

            try {
                body += '<td>' + nro_proceso + '</td>'
                body += '<td>' + ar_resumen.cabecera.concepto + '</td>'
                body += '<td>' + ar_resumen.cabecera.estado + '</td>'
                body += '<td>' + ar_resumen.operador.login.toUpperCase() + '</td>'
            }
            catch (e) {
                body += '<td colspan="4">Error al obtener datos para el email. Mensaje: ' + e.message + '</td>'
            }

            body += '</tr>'
            body += '</table>'
            body += '<p><b>Para más detalles, visite el siguiente enlace:</b>&nbsp;'

            var url_href = nvFW.location.origin + "/FW/instruccion_pago/instruccion_pago_consultar.aspx?nro_proceso=" + nro_proceso
            body += "<a href='" + url_href + "' target='_blank' style='text-decoration: none;'>Ver instrucción de pago en NOVA</a></p>"
            body += "<div contenteditable='true' class='observacion' id='observacion'>Ingrese las observaciones que crea necesarias...</div>"

            var win_sendMail = nvFW.createWindow({
                title: "<b>Notificar por mail</b>",
                url: '/FW/sendMail.aspx?modo=IP&nro_pago_concepto=' + ar_resumen['cabecera']['nro_pago_concepto'] + '&nro_pago_estado=' + ar_resumen['cabecera']['nro_pago_estado'] + '&subject=' + subject + '&body=' + body,
                width: 750,
                height: 400,
                destroyOnClose: true,
                onClose: function () {
                    window.location.reload()
                    w_resumen.close()
                }
            })

            win_sendMail.options.userData = {
                adjuntar_pdf: 0,
                filtroXML: '',
                filtroWhere: '',
                path_reporte: '',
                filename: '',
                observaciones: campos_defs.get_value('observacion_ip')
            }

            win_sendMail.showCenter()
        }

        function cambiarTd(flag) {

            if (flag == 0) {
                if ($("manualTabCred").style.display == "none" && tipo_mov == 'D') {
                    $("defTabCred").style.display = "none"
                    $("manualTabCred").style.display = "table"

                    campos_defs.clear('nrodoc_bco')
                    campos_defs.clear('ibs_cuecod_bco')

                } else {
                    $("defTabCred").style.display = "table"
                    $("manualTabCred").style.display = "none"

                    $('cbuOrigen').value = ''
                    $('cuitOrigen').value = ''
                }

            } else {
                if ($("manualTabDeb").style.display == "none") {
                    $("defTabDeb").style.display = "none"
                    $("manualTabDeb").style.display = "table"

                    campos_defs.clear('cuit_entidades')
                    campos_defs.clear('ibs_cuecod')

                } else {
                    $("defTabDeb").style.display = "table"
                    $("manualTabDeb").style.display = "none"

                    $('cbuDestino').value = ''
                    $('cuitDestino').value = ''
                }
            }

        }

        function avanzado() {
            
            if ($("datosGen").style.display == "none") {
                $("datosGen").style.display = "table"
            } else {
                $("datosGen").style.display = "none"
            }

        }

        function nuevaCuenta(tipo) {
            var flag = 0
            var nro_entidad

            if (tipo == 'B') {
                nro_entidad = $('nro_entidad').value

                if (!$('nrodoc_bco').value) {
                    flag = 1
                }
            } else if (tipo == 'E') {
                nro_entidad = $('nro_entidad_d').value

                if (!$('cuit_entidades').value) {
                    flag = 1
                }
            }

            if (flag == 1) {
                alert('Especifique la entidad para poder abrir el ABM')
                return
            }

            var win_entABM = top.nvFW.createWindow({
                url: '/FW/entidades/entidad_abm.aspx?nro_entidad=' + nro_entidad,
                title: '<b>ABM entidades</b>',
                width: 1080,
                height: 600,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })

            win_entABM.showCenter(true)

        }

        function validarCbu() {
            if ($('img').title == 'Validar CBU') {
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
                            console.log(err.params.tit_razon_social)

                            $("cuitDestino").value = err.params.tit_cuit
                            $("razonSocial").value = err.params.tit_razon_social

                            $('img').src = '../../FW/image/icons/editar.png'
                            $('img').title = 'Editar CBU'
                            $('cbuDestino').disabled = true
                        },
                        onFailure: function (err, transport) {
                            console.log(err)
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
                $('img').title = 'Validar CBU'
                $('cbuDestino').disabled = false
            }

        }

        function consultarEstado() {
            error_ajax_request("dc_acciones.aspx", {
                parameters: {
                    accion: 'CD',
                    id: win.options.userData.dc_id 
                },
                onSuccess: function (err, transport) {
                    var xmlString = err.params.respuesta
                    console.log(xml)
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
                    console.log(err)
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

        function seleccionEntidad() {

            var win = top.nvFW.createWindow({
                url: '/voii/debincredin/dc_mov_seleccionar.aspx',
                title: '<b>Selección Entidad y Cuenta</b>',
                width: 1080,
                height: 600,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })

            win.options.userData = {
                cuitInput: $("cuitDestino"),
                cbuInput: $("cbuDestino"),
                razonSocialInput: $("razonSocial"),
            }

            win.showCenter(true)
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

            if (win.options.userData.modo != 1) {
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%; height:24px'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            } else {
                //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Consultar Estado</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style=''><Lib TipoLib='offLine'>DocMNG</Lib><icono>historico</icono><Desc>Actualizar Estado</Desc><Acciones><Ejecutar Tipo='script'><Codigo>consultarEstado()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%; height:24px'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ID: " + win.options.userData.dc_id  + "</Desc></MenuItem>")                
            }

            vMenu.loadImage("guardar", "/FW/image/icons/guardar.png");
            vMenu.loadImage("historico", "/FW/image/icons/historico.png");

            vMenu.MostrarMenu()
        </script>
    </div>
    <input id="nro_entidad" style="display: none" type="text" />
    <input id="nro_entidad_d" style="display: none" type="text" />
    <table class="tb1" id="cabecera">
        <tr>
            <td id="feTit" class="Tit1">Fecha:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fecha_ip', { enDB: false, nro_campo_tipo: 103 })
                </script>
            </td>
            <td class="Tit1">Concepto:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('concepto', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.conceptoDef,
                        nro_campo_tipo: 1
                    })
                </script>
            </td>
            <td class="Tit1">Estado:</td>
            <td>
                <input id="estado" style="width: 100%" type="text" disabled />
<%--                <script type="text/javascript">
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
        <tr>
            <td id="expTit" class="Tit1">Tiempo Expiración:</td>
            <td id="tiempoExp" style="width: 150px">
                <select id="tiempoExpiracion" style="width: 100%">
                    <option value="24">24 horas</option>
                    <option value="48">48 horas</option>
                    <option value="72">72 horas</option>
                </select>
            </td>
            <td id="fechaExp" style="display: none">
                <input type="text" id="expTime" style="width: 100%" disabled />
            </td>
            <td class="Tit1">User ID:</td>
            <td>
                <input id="id_user" type="text" style="width: 100%" />
            </td>
            <td class="Tit1">Comprobante ID:</td>
            <td>
                <input id="id_comprobante" type="text" style="width: 100%" />
            </td>
        </tr>
    </table>
    <div id="instruccionesPago">
        <%-- Cabecera de la tabla Instruccion de Pago --%>
        <table style="width: 100%">
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
                                    if (win.options.userData.modo != 1) {
                                        Menus["vMenuVen"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Entidad ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevaCuenta('B')</Codigo></Ejecutar></Acciones></MenuItem>")

                                        //if (win.options.userData.tipo == 'D') {
                                        //    Menus["vMenuVen"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>user</icono><Desc>Manual</Desc><Acciones><Ejecutar Tipo='script'><Codigo>cambiarTd(0)</Codigo></Ejecutar></Acciones></MenuItem>")
                                        //}
                                    }
                                    Menus["vMenuVen"].CargarMenuItemXML("<MenuItem id='0' style='width: 95%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>CREDITO</Desc></MenuItem>")

                                    vMenuVen.loadImage("user", "/FW/image/icons/user2.png");
                                    vMenuVen.loadImage("nuevo", "/FW/image/icons/file.png");

                                    vMenuVen.MostrarMenu()
                                </script>
                            </td>
                        </tr>
                    </table>
                    <table class="tb1" id="defTabCred" >
                        <tr class="">
                            <td style="width: 140px" id="td_entidad_origen">
                                <script type="text/javascript">
                                campos_defs.add('nrodoc_bco', {
                                    enDB: false,
                                    filtroXML: nvFW.pageContents.bancoDef,
                                    json: true,
                                    onchange: function (event, campo_def) {
                                        var rs_cdef = campos_defs.getRS(campo_def)
                                        var valor = rs_cdef.getdata('nro_entidad')
                                        $('nro_entidad').value = valor
                                    },
                                    nro_campo_tipo: 1
                                })
                                </script>
                            </td>
                            <td style="width: 50px">
                                <input id="sucursal" type="text" placeholder="Codigo Sucursal" style="width: 100%" disabled/>
                            </td>
                            <td id="detCbuCred" style="width: 140px; display: none">
                                <input style="width: 100%" type="text" id="cuentaCred" disabled /></td>
                            <td id="defCbuCred" style="width: 140px">
                                <script type="text/javascript">
                                campos_defs.add('ibs_cuecod_bco', {
                                    enDB: false,
                                    filtroXML: nvFW.pageContents.cuentaDef,
                                    //filtroWhere: "<criterios><select><razon_social type='like'>'%BANCO%'</razon_social></criterios></select>",
                                    depende_de: 'nro_entidad',
                                    depende_de_campo: 'id_tipo',
                                    nro_campo_tipo: 1
                                })
                                </script>
                            </td>
                        </tr>
                    </table>
                    <table class="tb1" id="manualTabCred" style="display: none">
                        <tr>
                            <td style="width: 22px" colspan="3">
                                <input type="text" maxlength="11" id="cuitOrigen" style="width: 47%" placeholder="CUIT Origen" />
                                <input type="text" maxlength="22" id="cbuOrigen" style="width: 47%" placeholder="CBU Origen" />
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

                                    if (win.options.userData.modo != 1) {
                                        Menus["vMenuCom"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Entidad ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevaCuenta('E')</Codigo></Ejecutar></Acciones></MenuItem>")
                                        Menus["vMenuCom"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>user</icono><Desc>Seleccionar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>seleccionEntidad()</Codigo></Ejecutar></Acciones></MenuItem>")
                                    }
                                    Menus["vMenuCom"].CargarMenuItemXML("<MenuItem id='0' style='width: 95%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>DEBITO</Desc></MenuItem>")

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
                            <td style="width: 22px" colspan="2">
                                <input type="text" id="razonSocial" style="width: 32%" placeholder="Razon Social" disabled />
                                <input type="text" maxlength="11" id="cuitDestino" style="width: 32%" placeholder="CUIT Destino" disabled />
                                <input type="text" maxlength="22" id="cbuDestino" style="width: 32%" placeholder="CBU Destino" />
                                <img src="../../FW/image/icons/confirmar.png" style="width:16px; cursor: pointer" onclick="validarCbu()" title="Validar CBU" id="img" />
                            </td>
                            <td style="width: 14px; display: none;" class="tdScroll">&nbsp;&nbsp;</td>
                        </tr>
                    </table>
                </td>
                <td>
                    <table>
                        <tr class="tbLabel">
                            <td colspan="2">Importe </td>
                        </tr>
                        <tr>
                            <td id="prefijo" class="Tit1" style="width: 25%; text-align: center">$ </td>
                            <td style="text-align: right; width: 80%">
                                <div style="width: 100%; display: inline-block;" id="div_importe">
                                    <script type="text/javascript">
                                    campos_defs.add('importe', {
                                        enDB: false,
                                        nro_campo_tipo: 102
                                    })
                                    </script>
                                </div>
                            </td>
                        </tr>
                        <tr class="tbLabel">
                            <td colspan="2" style="text-align: center">Codigo Moneda</td>
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
                                </script>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <table>
            <tr class="tbLabel">
                <td style="text-align: center" id="obsercvacion">Observación</td>
            </tr>
            <tr>
                <td style="text-align: center; align-items: center; margin: auto">
                    <textarea style="margin: auto; resize: none; width: 100%" id="observacion" onkeypress="return ( this.value.length < 160 )" cols="160" rows="5" placeholder="Observación..."></textarea>
                </td>
            </tr>
        </table>
        <table style="width: 100%; display:none" id="tabPuntaje">
            <tr>
                <td class="Tit1" style="width: 30%">Evaluación de actividad sospechosa:
                </td>
                <td style="width: 70%">
                    <input id="puntaje" type="text" style="width: 100%" disabled />
                </td>
        </table>
        <%--        <table class="tb1" id="datos_usuario">
            <tr class="tbLabel">
                <td style="text-align:center">
                   Usuario ID
                </td>
                <td style="text-align:center">
                    Comprobante ID
                </td>
                <td style="text-align:center">
                    Tiempo de Expiración
                </td>
            </tr>
            <tr>
                <td>
                    <input id="id_user" type="text" style="width:100%"/>
                </td>
                <td>
                    <input id="id_comprobante" type="text" style="width:100%"/>
                </td>
                <td style="width:150px">
                    <select id="tiempoExpiracion" style="width:100%">
                        <option value="1">24 horas</option>
                        <option value="2">48 horas</option>
                        <option value="3">72 horas</option>
                    </select>
                </td>
            </tr>
        </table>--%>
        <div id="divMenuTit" style="width: 100%; margin: 0; padding: 0;"></div>
        <script type="text/javascript">
            var vMenuTit = new tMenu('divMenuTit', 'vMenuTit');

            Menus["vMenuTit"] = vMenuTit
            Menus["vMenuTit"].alineacion = 'centro';
            Menus["vMenuTit"].estilo = 'A';

            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='1' style='width: 98%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos Generador</Desc></MenuItem>")
            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='0' style='width: 2%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>mas</icono><Desc></Desc><Acciones><Ejecutar Tipo='script'><Codigo>avanzado()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuTit.loadImage("mas", "/FW/image/icons/mas.jpg");

            vMenuTit.MostrarMenu()
        </script>
        <table id="datosGen" style="display: none">
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
                            <td colspan="3" style="text-align: center">UBICACION</td>
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

        <%-- Datos de la tabla Instruccion de Pago --%>
        <div id="divDatosIP" style="overflow: auto;">
            <table class="tb1" id="datosIP">
                <tr id="tr_dato">
                </tr>
            </table>
        </div>
</body>
</html>
