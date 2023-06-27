<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim nro_pago_registro As Integer = 0
    Dim num_error As String = "999999"

    If modo = "" Then
        modo = "VA"
    End If

    If modo = "A" Then
        If strXML <> "" Then
            num_error = "0"
            nro_pago_registro = nvFW.nvUtiles.obtenerValor("nro_pago_registro")
            Dim err As New tError()

            Try

                Dim oXML As New System.Xml.XmlDocument
                oXML.LoadXml(strXML)
                Dim importes As System.Xml.XmlNodeList = oXML.SelectNodes("pagos/registro/detalles/detalle/@importe_pago")
                Dim importe_control As System.Xml.XmlNode = oXML.SelectSingleNode("pagos/registro/@importe_control")

                For Each importe In importes
                    If importe.value = 0 Then
                        err.numError = 101
                        err.mensaje = "Existen importes en cero."
                        err.titulo = "Error"
                    End If
                Next

                If err.numError = 0 AndAlso importe_control.Value <> 0 Then
                    err.numError = 102
                    err.mensaje = "Hay diferencia con el importe Total - Controle..."
                    err.titulo = "Error"
                End If

                If err.numError = 0 Then
                    If nro_pago_registro <> 0 Then
                        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_pg_cargar_pago_registro", ADODB.CommandTypeEnum.adCmdStoredProc)
                        cmd.addParameter("@xmlRegistro", ADODB.DataTypeEnum.adLongVarChar, , , strXML)
                        Dim rs As ADODB.Recordset = cmd.Execute()
                        'nvFW.nvDBUtiles.DBCloseRecordset(rs)

                        If Not rs.EOF Then
                            err.numError = rs.Fields("numError").Value
                            err.mensaje = "Error al intentar guardar el pago."
                            err.titulo = "Error"
                            err.debug_desc = rs.Fields("mensaje").Value
                        End If
                    End If
                End If




            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = -100
                err.mensaje = "Error al intentar guardar pago."
                err.titulo = "Error"
            End Try
            err.response()
        End If
    End If

    Dim operador As Object = nvFW.nvApp.getInstance().operador

    '|--------------------------------------------------------------
    '| Filtros Encriptados
    '|--------------------------------------------------------------
    Me.contents("filtro_inicio") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_pg_registro_xml_2'><campos>nro_pago_registro, CAST(PG_XML1 AS VARCHAR(8000)) AS PG_XML1, CAST(PG_XML2 AS VARCHAR(8000)) AS PG_XML2</campos></select></criterio>")
    Me.contents("filtro_detalle_dibujar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>descripcion_cta, id_cuenta, descripcion, moneda</campos></select></criterio>")
    Me.contents("filtro_detalle_dibujar2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_estados'><campos>*</campos><orden>nro_pago_estado ASC</orden></select></criterio>")
    Me.contents("filtro_actualizar_deposito") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>id_cuenta, descripcion_cta, nro_banco, id_banco_sucursal, nro_cuenta, tipo_cuenta</campos><filtro><habilitada type='igual'>1</habilitada></filtro></select></criterio>")

    Me.addPermisoGrupo("permisos_pagos")
%>
<html>
<head>
    <title>ABM Pagos</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var nro_operador = '<% = operador.operador %>';
        var login = '<% = operador.nombre_operador %>';

        //Botones
        var vButtonItems = {}

        //vButtonItems[0] = {}
        //vButtonItems[0]["nombre"]   = "Aceptar";
        //vButtonItems[0]["etiqueta"] = "Aceptar";
        //vButtonItems[0]["imagen"]   = "guardar";
        //vButtonItems[0]["onclick"]  = "return Aceptar()";

        //vButtonItems[1] = {}
        //vButtonItems[1]["nombre"]   = "Cancelar";
        //vButtonItems[1]["etiqueta"] = "Cancelar";
        //vButtonItems[1]["imagen"]   = "cerrar";
        //vButtonItems[1]["onclick"]  = "return Cancelar()";

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Agregar";
        vButtonItems[0]["etiqueta"] = "Agregar Pago";
        vButtonItems[0]["imagen"] = "agregar";
        vButtonItems[0]["onclick"] = "return pg_detalle_agregar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')

        vListButtons.loadImage("guardar", "/FW/image/icons/guardar.png")
        vListButtons.loadImage("cerrar", "/FW/image/icons/cancelar.png")
        vListButtons.loadImage("agregar", "/FW/image/icons/agregar.png")

        var isModal
        var vPago_registro = {}
        var nro_pago_registro
        var importe_pago
        var nro_pago_tipo
        var diferencia
        var pago_estados
        var nro_pago_estado
        var total
        
        function pg_cargar(PG_XML) {
            var NOD
            var NOD_detalle
            var NOD_parametro
            var objXML = new tXML();
            var strcancela_vence
            vPago_registro = {}

            if (PG_XML != null) {
                if (objXML.loadXML(PG_XML)) {
                    NOD = objXML.getElementsByTagName('registro')[0]
                    vPago_registro = {}
                    vPago_registro["nro_pago_registro"] = NOD.getAttribute('nro_pago_registro') ? NOD.getAttribute('nro_pago_registro') : ''
                    vPago_registro["nro_credito"] = NOD.getAttribute('nro_credito') ? NOD.getAttribute('nro_credito') : ''
                    vPago_registro["nro_entidad_destino"] = NOD.getAttribute('nro_entidad_destino') ? NOD.getAttribute('nro_entidad_destino') : ''
                    vPago_registro["razon_social"] = NOD.getAttribute('Razon_social') ? NOD.getAttribute('Razon_social') : ''
                    vPago_registro["nro_pago_concepto"] = NOD.getAttribute('nro_pago_concepto') ? NOD.getAttribute('nro_pago_concepto') : ''
                    vPago_registro["pago_concepto"] = NOD.getAttribute('pago_concepto') ? NOD.getAttribute('pago_concepto') : ''
                    vPago_registro["cancela_cuota"] = NOD.getAttribute('cancela_cuota') ? NOD.getAttribute('cancela_cuota') : ''
                    vPago_registro["ISO_cod"] = NOD.getAttribute('ISO_cod') ?  NOD.getAttribute('ISO_cod') : 'ARS'
                    vPago_registro["nro_moneda"] = NOD.getAttribute('nro_moneda') ?  NOD.getAttribute('nro_moneda') : 1
                    vPago_registro["importe_pago"] = NOD.getAttribute('importe_pago') ? NOD.getAttribute('importe_pago') : 'null'
                    vPago_registro["cancela_nro_cuota"] = NOD.getAttribute('cancela_cuota_paga') ? NOD.getAttribute('cancela_cuota_paga') : ''
                    strcancela_vence = NOD.getAttribute('cancela_vence') ? NOD.getAttribute('cancela_vence') : ''

                    if (strcancela_vence == '') {
                        vPago_registro["cancela_vence"] = ''
                        vPago_registro["strcancela_vence"] = ''
                    }
                    else {
                        vPago_registro["cancela_vence"] = new Date(parseFecha(strcancela_vence));
                        vPago_registro["strcancela_vence"] = FechaToSTR(vPago_registro["cancela_vence"])
                    }

                    vPago_registro["cancela_cupo"] = NOD.getAttribute('cancela_cupo') ? NOD.getAttribute('cancela_cupo') : ''
                    vPago_registro["cancela_nro_credito"] = NOD.getAttribute('cancela_nro_credito') ? NOD.getAttribute('cancela_nro_credito') : ''
                    vPago_registro['parametros_registro'] = {}

                    for (var i = 0; i < NOD.getElementsByTagName('parametro').length; i++) {
                        NOD_parametro_registro = NOD.getElementsByTagName('parametro')[i]

                        if (NOD_parametro_registro.getAttribute('pago_parametro') && NOD_parametro_registro.getAttribute('pertenece_registro') == '1') {
                            vPago_registro['parametros_registro'][NOD_parametro_registro.getAttribute('pago_parametro')] = []
                            vPago_registro['parametros_registro'][NOD_parametro_registro.getAttribute('pago_parametro')]['valor'] = NOD_parametro_registro.getAttribute('pago_parametro_valor') ? NOD_parametro_registro.getAttribute('pago_parametro_valor') : 'null'
                            vPago_registro['parametros_registro'][NOD_parametro_registro.getAttribute('pago_parametro')]['nro_pago_tipo'] = NOD_parametro_registro.getAttribute('nro_pago_tipo')
                        }
                    }

                    vPago_registro["detalle"] = {}

                    for (var j = 0; j < NOD.getElementsByTagName('detalle').length; j++) {
                        NOD_detalle = NOD.getElementsByTagName('detalle')[j]
                        vPago_registro["detalle"][j] = {}
                        vPago_registro["detalle"][j]['nro_pago_detalle'] = NOD_detalle.getAttribute('nro_pago_detalle') ? NOD_detalle.getAttribute('nro_pago_detalle') : ''
                        vPago_registro["detalle"][j]['nro_pago_estado'] = NOD_detalle.getAttribute('nro_pago_estado') ? NOD_detalle.getAttribute('nro_pago_estado') : 'null'
                        vPago_registro["detalle"][j]['nro_pago_tipo'] = NOD_detalle.getAttribute('nro_pago_tipo') ? NOD_detalle.getAttribute('nro_pago_tipo') : 'null'
                        vPago_registro["detalle"][j]['pago_estados'] = NOD_detalle.getAttribute('pago_estados') ? NOD_detalle.getAttribute('pago_estados') : ''
                        vPago_registro["detalle"][j]['pago_tipo'] = NOD_detalle.getAttribute('pago_tipo') ? NOD_detalle.getAttribute('pago_tipo') : 'null'
                        vPago_registro["detalle"][j]['importe_pago'] = NOD_detalle.getAttribute('importe_pago') ? NOD_detalle.getAttribute('importe_pago') : 'null'
                        vPago_registro["detalle"][j]['fe_estado'] = NOD_detalle.getAttribute('fe_estado') ? FechaToSTR(parseFecha(NOD_detalle.getAttribute('fe_estado'))) : ''
                        vPago_registro["detalle"][j]['nombre_operador'] = NOD_detalle.getAttribute('nombre_operador') ? NOD_detalle.getAttribute('nombre_operador') : ''
                        vPago_registro["detalle"][j]['pg_desc'] = NOD_detalle.getAttribute('pg_desc') ? NOD_detalle.getAttribute('pg_desc') : ''
                        vPago_registro["detalle"][j]['parametros'] = {}

                        for (var h = 0; h < NOD_detalle.getElementsByTagName('parametro').length; h++) {
                            NOD_parametro = NOD_detalle.getElementsByTagName('parametro')[h]

                            if (NOD_parametro.getAttribute('pago_parametro') && NOD_parametro.getAttribute('pertenece_registro') == '0')
                                vPago_registro["detalle"][j]['parametros'][NOD_parametro.getAttribute('pago_parametro')] = NOD_parametro.getAttribute('pago_parametro_valor') ? NOD_parametro.getAttribute('pago_parametro_valor') : 'null'
                        }
                    }
                }
            }

            return vPago_registro
        }



        function pg_mostrar() { // Arma la Cabecera y el array
            $('divcabecera_pagos').innerHTML = ""
            strHTML = "<table class='tb1'><tr class='tbLabel0'><td>Razón Social</td><td>Concepto</td><td>Importe</td></tr>"
            strHTML += "<tr><td>" + vPago_registro["razon_social"] + "</td><td>" + vPago_registro["pago_concepto"] + "</td><td align='right'>" + vPago_registro["ISO_cod"] + ' ' + parseFloat(vPago_registro["importe_pago"]).toFixed(2) + "</td></tr></table>"
            $('divcabecera_pagos').insert({ top: strHTML })
            pg_detalle_dibujar()
            pg_actualizar_valores()
        }

        var nro_moneda_cta = {}
        function pg_detalle_dibujar() { // Redibuja el detalle
            var fe_estado
            var nombre_operador
            var nro_pago_detalle = 0
            var style = ''

            $('divdatos_pagos').innerHTML = ''

            var strHTML = "<table class='tb1 layout_fixed'><tr class='tbLabel'><td style='width: 32%; text-align: center'>Tipo de Pago</td><td style='width: 12%; text-align: center'>Estado</td><td style='width: 13%; text-align: center'>Fecha - Operador</td><td style='width: 10%; text-align: center'>Moneda</td><td style='width: 15%; text-align: center'>Importe</td><td style='width: 18%' align='center'>&nbsp;</td></tr>"

            for (var x in vPago_registro["detalle"]) {
                if (!isNaN(x)) {
                    style = ''
                    nro_pago_detalle = vPago_registro["detalle"][x]["nro_pago_detalle"]

                    if (!nro_pago_detalle)
                        nro_pago_detalle = ''

                    if (nro_pago_detalle != '' && nro_pago_detalle < 0)
                        style = 'display: none'

                    strHTML += "<tr style='" + style + "'><td>"

                    if (vPago_registro["detalle"][x]["nro_pago_tipo"] == 1) {
                        strHTML += "<select id='cb_deposito_" + x + "' name='cb_deposito_" + x + "' style='width: 100%;' onchange='pg_actualizar_deposito(" + x + ")'>"

                        var rs = new tRS();
                        //rs.open('<criterio><select vista="verEntidad_bco_ctas"><campos>descripcion_cta, id_cuenta, descripcion</campos><orden></orden><filtro><nro_entidad type="igual">' + vPago_registro["nro_entidad_destino"] + '</nro_entidad><habilitada type="igual">1</habilitada></filtro></select></criterio>')
                        rs.open({
                            filtroXML: nvFW.pageContents.filtro_detalle_dibujar,
                            filtroWhere: "<criterio><select><filtro><nro_entidad type='igual'>" + vPago_registro["nro_entidad_destino"] + "</nro_entidad><habilitada type='igual'>1</habilitada></filtro></select></criterio>"
                        })

                        nro_moneda_cta[x] = {}

                        while (!rs.eof()) {
                            var seleccionado = ''

                            if (rs.getdata('id_cuenta') == vPago_registro["detalle"][x]["parametros"]["id_cuenta"]) {
                                seleccionado = "selected"
                                nro_moneda_cta[x]['selected'] = rs.getdata('id_cuenta')
                            }

                            nro_moneda_cta[x][rs.getdata('id_cuenta')] = rs.getdata('moneda') ? rs.getdata('moneda') : 1

                            strHTML += "<option value='" + rs.getdata('id_cuenta') + "' " + seleccionado + ">" + rs.getdata('descripcion_cta') + "  " + rs.getdata('descripcion') + "</option>"
                            rs.movenext()
                        }
                        strHTML += "</select>"
                    }
                    else
                        strHTML += vPago_registro["detalle"][x]["pago_tipo"] + "<br>" + vPago_registro["detalle"][x]["pg_desc"]

                    if (vPago_registro["detalle"][x]["pago_estados"] == "Pagado") {
                        estado_tipo = ""
                        estado_buton = ""
                    }
                    else {
                        estado_tipo = ""
                        estado_buton = ""
                    }

                    var desabilitar = ''

                    //if (vPago_registro["nro_pago_concepto"] == 5 && vPago_registro["detalle"][x]["nro_pago_tipo"] == 1 && (permisos_pagos & 8) <= 0)
                    if (vPago_registro["nro_pago_concepto"] == 5 && vPago_registro["detalle"][x]["nro_pago_tipo"] == 1 && !nvFW.tienePermiso("permisos_pagos", 4)) // Permiso = 4 -> "Editar Estado importe en mano con deposito"
                        desabilitar = 'disabled'

                    strHTML += "</td><td><select id='nro_pago_estado" + x + "' name='nro_pago_estado" + x + "' " + desabilitar + " style='width: 100%' onchange='pg_actualizar_valores()'>"

                    var rs = new tRS();
                    //rs.open("<criterio><select vista='pago_estados'><campos>*</campos><orden>nro_pago_estado asc</orden><filtro></filtro></select></criterio>")
                    rs.open({ filtroXML: nvFW.pageContents.filtro_detalle_dibujar2 })

                    while (!rs.eof()) {
                        var seleccionado = ''

                        if (rs.getdata('nro_pago_estado') == vPago_registro["detalle"][x]["nro_pago_estado"])
                            seleccionado = "selected"

                        strHTML += "<option value='" + rs.getdata('nro_pago_estado') + "' " + seleccionado + ">" + rs.getdata('pago_estados') + "</option>"
                        rs.movenext()
                    }

                    fe_estado = vPago_registro["detalle"][x]["fe_estado"] != undefined ? vPago_registro["detalle"][x]["fe_estado"] : ''
                    nombre_operador = vPago_registro["detalle"][x]["nombre_operador"] != undefined ? vPago_registro["detalle"][x]["nombre_operador"] : ''

                    strHTML += "</select></td>"
                    strHTML += "<td align='center' title='" + fe_estado + ' - ' + nombre_operador + "'>" + fe_estado + ' - ' + nombre_operador + "</td>"
                    strHTML += "<td>" + vPago_registro["ISO_cod"] + "</td>"
                    strHTML += "<td><input " + estado_tipo + " style='width: 100%; TEXT-ALIGN: right' onchange='validarNumero(event,\"0.00\"); pg_actualizar_valores()' onkeypress='return valDigito(event,\".+-*/\")' type='text' id='importe_pago" + x + "' name='importe_pago" + x + "'  value='" + parseFloat(vPago_registro["detalle"][x]["importe_pago"]).toFixed(2) + "'>"
                    strHTML += "<input type='hidden' id='nro_pago_tipo" + x + "' name='nro_pago_tipo" + x + "' value='" + vPago_registro["detalle"][x]["nro_pago_tipo"] + "'></td>"
                    strHTML += "<td align='center'>"
                    strHTML += "<img title='Eliminar pago' style='cursor: pointer;' src='/FW/image/icons/eliminar.png' onclick='pg_detalle_eliminar(" + x + ")'/>"

                    for (var r in vPago_registro["detalle"][x]["parametros"]) {
                        strHTML += "<input type='hidden' id='" + r + x + "' name='" + r + x + "' value='" + vPago_registro["detalle"][x]["parametros"][r] + "'>"
                    }

                    strHTML += "</td></tr>"
                }
            }

            $('nro_pago_registro').value = vPago_registro["nro_pago_registro"]
            strHTML += "<tr><td align='right' colspan='3'><b>Total:</b></td>"
            strHTML += "<td>" + vPago_registro["ISO_cod"] + "</td>"
            strHTML += "<td><input style='width:100%; text-align: right' id='input_totales' name='input_totales' type='text' readonly='true' value='0.00'></td>"
            strHTML += "<td><input style='width: 100%; text-align: right; color:Black' id='input_diferencia' name='input_diferencia' type='text' readonly='true' value='0.00'></tr>"
            strHTML += "</table>"

            $('divdatos_pagos').insert({ top: strHTML })
        }


        function pg_actualizar_deposito(i) {
            var id_cuenta = $('cb_deposito_' + i).value
            var rs = new tRS()
            
            if (nro_moneda_cta[i][id_cuenta] != vPago_registro["nro_moneda"]) {
                alert('El tipo de moneda de la cuenta no coincide con la del pago.')
                $('cb_deposito_' + i).value = nro_moneda_cta[i]['selected']
                return
            }
            
            nro_moneda_cta[i]['selected'] = id_cuenta
            //rs.open('<criterio><select vista="verEntidad_bco_ctas"><campos>id_cuenta, descripcion_cta, nro_banco, id_banco_sucursal, nro_cuenta, tipo_cuenta</campos><orden></orden><filtro><nro_entidad type="igual">' + vPago_registro["nro_entidad_destino"] + '</nro_entidad><id_cuenta type="igual">' + id_cuenta + '</id_cuenta><habilitada type="igual">1</habilitada></filtro></select></criterio>')
            rs.open({
                filtroXML: nvFW.pageContents.filtro_actualizar_deposito,
                filtroWhere: "<criterio><select><filtro><nro_entidad type='igual'>" + vPago_registro["nro_entidad_destino"] + "</nro_entidad><id_cuenta type='igual'>" + id_cuenta + "</id_cuenta></filtro></select></criterio>"
            })

            if (!rs.eof()) {
                vPago_registro["detalle"][i]["pg_desc"] = rs.getdata('descripcion_cta')
                vPago_registro["detalle"][i]["parametros"]["nro_banco"] = rs.getdata('nro_banco')
                vPago_registro["detalle"][i]["parametros"]["nro_banco_sucursal"] = rs.getdata('id_banco_sucursal')
                vPago_registro["detalle"][i]["parametros"]["nro_cuenta"] = rs.getdata('nro_cuenta')
                vPago_registro["detalle"][i]["parametros"]["tipo_cuenta"] = rs.getdata('tipo_cuenta')
                vPago_registro["detalle"][i]["parametros"]["id_cuenta"] = rs.getdata('id_cuenta')
            }
        }


        function pg_actualizar_valores() {  // Actualiza los totales
            var i
            var valor
            var nuevo_valor
            var total = 0
            var diferencia = 0
            var option
            var cant = 0

            for (var i in vPago_registro["detalle"]) {
                if (!isNaN(i)) {
                    if (!(parseInt(vPago_registro["detalle"][i]["nro_pago_detalle"]) < 0)) {
                        valor = $('importe_pago' + i).value
                        vPago_registro["detalle"][i]["importe_pago"] = valor
                        vPago_registro["detalle"][i]["nro_pago_estado"] = $('nro_pago_estado' + i).value
                        vPago_registro["detalle"][i]["pago_estados"] = $('nro_pago_estado' + i).options[$('nro_pago_estado' + i).selectedIndex].innerHTML

                        total += parseFloat(valor);
                    }
                }
            }

            $('input_totales').value = total.toFixed(2)
            diferencia = parseFloat(vPago_registro["importe_pago"]) - total
            $('input_diferencia').value = diferencia.toFixed(2)

            if ($('input_diferencia').value != 0 || $('input_diferencia').value != 0.00)
                $('input_diferencia').style.cssText = "width: 100%; color: red; fontWeight: bolder; text-align: right;"
            else
                $('input_diferencia').style.cssText = "width: 100%; color: black; fontWeight: normal; text-align: right;"
        }


        function pg_detalle_eliminar(indice) {  // Elimina un tipo de Pago
            if (vPago_registro["detalle"][indice]['nro_pago_detalle'] != '')
                vPago_registro["detalle"][indice]['nro_pago_detalle'] = -1 * vPago_registro["detalle"][indice]['nro_pago_detalle']
            else
                delete vPago_registro["detalle"][indice]

            $('divdatos_pagos').innerHTML = ""
            pg_detalle_dibujar();

            if (indice = 1 || importe_pago != 0) {
                $('input_diferencia').value = parseFloat(importe_pago)
                $('input_diferencia').style.cssText = "width: 100%; color: red; fontWeight: bolder;"
            }

            pg_actualizar_valores();
        }


        var Param_Tipo = {}
        var win_pago_tipo


        function pg_detalle_agregar() { // Agrega un tipo de Pago
            Param_Tipo["nro_pago_registro"] = nro_pago_registro
            Param_Tipo["nro_pago_detalle"] = ''
            Param_Tipo["nro_entidad"] = vPago_registro["nro_entidad_destino"]

            win_pago_tipo = window.top.nvFW.createWindow({
                title: '<b>Seleccionar Pagos Tipos</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 280,
                resizable: false,
                destroyOnClose: true,
                onClose: pg_detalle_agregar_return
            });

            win_pago_tipo.options.userData = { Param_Tipo: Param_Tipo }
            win_pago_tipo.setURL('/FW/pagos/Pagos_tipo_seleccionar.aspx')
            win_pago_tipo.showCenter(true)
        }


        function pg_detalle_agregar_return() {
            if (win_pago_tipo.options.userData.res) {
                var retorno = win_pago_tipo.options.userData.res
                var a = retorno["nro_pago_estado"]
                var indice = 0

                for (var h in vPago_registro["detalle"]) {
                    if (!isNaN(h))
                        indice = parseInt(h) + 1
                }

                vPago_registro["detalle"][indice] = retorno

                pg_detalle_dibujar()
                pg_actualizar_valores()
            }
        }


        function Inicio() {
            vListButtons.MostrarListButton()
            var e

            try {
                var win = nvFW.getMyWindow()
                vPago_registro = win.options.userData.parametros

                if (!vPago_registro["nro_pago_registro"])
                    vPago_registro["nro_pago_registro"] = 0

                nro_pago_registro = vPago_registro["nro_pago_registro"]
            }
            catch (e) {
                nro_pago_registro = 0 // vnro_pago_registro
            }

            $('nro_pago_registro').value = nro_pago_registro

            if (nro_pago_registro != 0) {
                var rs = new tRS();
                //rs.open("<criterio><select vista='wrp_pg_registro_xml_2'><campos>nro_pago_registro,cast(PG_XML1 as varchar(8000)) as PG_XML1, cast(PG_XML2 as varchar(8000)) as PG_XML2</campos><orden></orden><filtro><nro_pago_registro type='in'>" + nro_pago_registro + "</nro_pago_registro></filtro></select></criterio>")
                rs.open({
                    filtroXML: nvFW.pageContents.filtro_inicio,
                    filtroWhere: "<criterio><select><filtro><nro_pago_registro type='in'>" + nro_pago_registro + "</nro_pago_registro></filtro></select></criterio>"
                })

                if (!rs.eof()) {
                    //var PG_XML1 = rs.getdata('PG_XML1')
                    //var PG_XML2 = rs.getdata('PG_XML2')
                    //var PG_XML = PG_XML1 + PG_XML2

                    //vPago_registro = pg_cargar(PG_XML)

                    vPago_registro = pg_cargar(rs.getdata('PG_XML1') + rs.getdata('PG_XML2'))
                }
            }

            if (vPago_registro["cancela_vence"] != '')
                vPago_registro["cancela_vence"] = parseFecha(FechaToSTR(parseFecha(vPago_registro["strcancela_vence"], 'dd/mm/yyyy'), 2))

            try {
                if (vPago_registro["cancela_vence_orig"] != '')
                    vPago_registro["cancela_vence_orig"] = parseFecha(FechaToSTR(parseFecha(vPago_registro["strcancela_vence"], 'dd/mm/yyyy'), 2))
            }
            catch (e) { }

            //vPago_registro["cancela_vence"] = new Date(Date.parse(strFecha(vPago_registro["strcancela_vence"])))    

            pg_mostrar()

            if ($('modo').value == 'VA')
                $('modo').value = 'A'

            window_onresize()
            $("frame_comentarios").onload = checkFrame()
            verComentarios()
        }


        var obj = {} // objeto con parametros para el filtro de comentarios


        function verComentarios() {
            var operador = '<%= operador.operador %>'
            obj.strFiltro = "<id_tipo type='igual'>" + nro_pago_registro + "</id_tipo>";

            //$('frame_comentarios').src = '/FW/verCom_registro.asp?nro_com_id_tipo=6&collapsed_fck=1&id_tipo=' + nro_pago_registro + '&do_zoom=0&obj=obj&nro_com_grupo=24'; //@@@@ analizar este modulo
            $('frame_comentarios').src = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=6&collapsed_fck=1&id_tipo=' + nro_pago_registro + '&do_zoom=0&obj=obj&nro_com_grupo=7';
            //$('frame_comentarios').src = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=6&collapsed_fck=1&id_tipo=' + nro_pago_registro + '&do_zoom=0&obj=obj&nro_com_grupo=24';
        }


        function Mostrar(valor, nro_mutual_cred) {
            switch (valor) {
                case '10':  // Deposito Bejerman
                    parent.document.all.ifrmMostrar_Tipo.src = "dpo_bjm_editar_pago.asp?nro_mutual=" + nro_mutual_cred
                    break

                case '6':   // Cheque Bejerman
                    parent.document.all.ifrmMostrar_Tipo.src = "cheque_bjm_editar_pago.asp?nro_mutual=" + nro_mutual_cred
                    break

                case '1':   // Depósito CA
                case '2':   // Depósito CC
                case '3':   // Depósito CBU
                case '11':  // Depósito 3eros 
                    parent.document.all.ifrmMostrar_Tipo.src = 'dpo_terc_editar_pago.aspx'
                    break

                case '5':   // Cheque 3eros
                    parent.document.all.ifrmMostrar_Tipo.src = 'cheque_terc_editar_pago.aspx'
                    break

                case '4':   // Efectivo
                    parent.document.all.ifrmMostrar_Tipo.src = 'efectivo_editar_pago.aspx'
                    break

                default:    // Otros
                    alert('Otros');
                    break
            }
        }


        function pg_to_xml() {
            var pago_parametro_valor
            var xmlDatos = "<pagos>"

            if (vPago_registro["cancela_vence"] != '')
                cancela_vence = FechaToSTR(vPago_registro["cancela_vence"], 2)
            else
                cancela_vence = ''

            xmlDatos += "<registro "

            if (vPago_registro["nro_pago_registro"] != '')
                xmlDatos += " nro_pago_registro='" + vPago_registro["nro_pago_registro"] + "' "

            if (vPago_registro["nro_credito"] != '')
                xmlDatos += " nro_credito='" + vPago_registro["nro_credito"] + "' "

            var strRazonSocial = vPago_registro["razon_social"].replace('&', '&amp;')
            xmlDatos += "nro_pago_concepto='" + vPago_registro["nro_pago_concepto"] + "' importe_pago='" + vPago_registro["importe_pago"] + "' nro_entidad_destino='" + vPago_registro["nro_entidad_destino"] + "' pago_concepto='" + vPago_registro["pago_concepto"] + "'"

            if (vPago_registro["cancela_vence"] != '')
                xmlDatos += " cancela_cuota='" + vPago_registro["cancela_cuota"] + "' cancela_vence='" + FechaToSTR(vPago_registro["cancela_vence"], 2) + "' cancela_nro_cuota='" + vPago_registro["cancela_nro_cuota"] + "'"

            if (vPago_registro["cancela_cupo"] != '')
                xmlDatos += " cancela_cupo='" + vPago_registro["cancela_cupo"] + "'"

            if (vPago_registro["cancela_nro_credito"] != '')
                xmlDatos += " cancela_nro_credito='" + vPago_registro["cancela_nro_credito"] + "'"

            xmlDatos += " importe_control='" + parseFloat($('input_diferencia').value) + "'"
            xmlDatos += ">"
            xmlDatos += "<parametros_reg>"

            for (var r in vPago_registro['parametros_registro']) {
                xmlDatos += "<parametro_reg pago_parametro_reg='" + r + "' "

                if (vPago_registro['parametros_registro'][r]['valor'] != '')
                    xmlDatos += " nro_pago_tipo_reg='" + vPago_registro['parametros_registro'][r]['nro_pago_tipo'] + "' pago_parametro_valor_reg='" + vPago_registro['parametros_registro'][r]['valor'] + "' "

                xmlDatos += "/>"
            }

            xmlDatos += "</parametros_reg>"
            xmlDatos += "<detalles>"

            for (var j in vPago_registro['detalle']) {
                if (!isNaN(j)) {
                    xmlDatos += "<detalle id='" + j + "' "

                    if (vPago_registro['detalle'][j]['nro_pago_detalle'] != '')
                        xmlDatos += " nro_pago_detalle='" + vPago_registro['detalle'][j]['nro_pago_detalle'] + "' "

                    xmlDatos += " nro_pago_estado='" + vPago_registro['detalle'][j]['nro_pago_estado'] + "' nro_pago_tipo='" + vPago_registro['detalle'][j]['nro_pago_tipo'] + "' importe_pago='" + vPago_registro['detalle'][j]['importe_pago'] + "' pago_tipo='" + vPago_registro['detalle'][j]['pago_tipo'] + "' pago_estados='" + vPago_registro['detalle'][j]['pago_estados'] + "' pg_desc='" + vPago_registro['detalle'][j]['pg_desc'] + "'>"

                    if (vPago_registro['detalle'][j]['nro_pago_tipo'] == 6 && vPago_registro['detalle'][j]['nro_pago_estado'] == 1)
                        xmlDatos += "<parametros></parametros>"
                    else {
                        xmlDatos += "<parametros>"

                        for (var m in vPago_registro['detalle'][j]['parametros']) {
                            //pago_parametro_valor = vPago_registro['detalle'][j]['parametros'][m]
                            //pago_parametro_valor = '<![CDATA[' + pago_parametro_valor + ']]>'
                            pago_parametro_valor = '<![CDATA[' + vPago_registro['detalle'][j]['parametros'][m] + ']]>'

                            xmlDatos += "<parametro pago_parametro='" + m + "'>"
                            xmlDatos += "<pago_parametro_valor>" + pago_parametro_valor + "</pago_parametro_valor>"
                            xmlDatos += "</parametro>"
                        }

                        xmlDatos += "</parametros>"
                    }

                    xmlDatos += "</detalle>"
                }
            }

            xmlDatos += "</detalles>"
            xmlDatos += "</registro>"
            xmlDatos += "</pagos>"

            xmlDatos = xmlDatos.replace(/ & /g, ' &amp; ')

            return xmlDatos
        }


        function Aceptar() {
            var diferencia = parseFloat($('input_diferencia').value)

            for (var i in vPago_registro['detalle']) {
                if (!isNaN(i)) {
                    if (parseFloat(vPago_registro['detalle'][i]["importe_pago"]) == 0) {
                        alert('Existen importes en cero.')
                        return
                    }
                }
            }

            if (diferencia != 0)
                alert('Hay diferencia con el importe Total - Controle...')
            else {
                $('strXML').value = pg_to_xml()

                nvFW.error_ajax_request('Pagos_ABM.aspx', {
                    bloq_contenedor: $$("body")[0],
                    bloq_msg: "Guardando pago...",
                    parameters: {
                        modo: $('modo').value,
                        strXML: $('strXML').value,
                        nro_pago_registro: $('nro_pago_registro').value
                    },
                    onSuccess: function (err, transport) {
                        var win = nvFW.getMyWindow()
                        win.options.userData = { parametros: vPago_registro }
                        win.close()
                    },
                    onFailure: function (err, transport) {
                        console.log('Error');
                    }
                });
            }
        }


        function Cancelar() {
            var win = nvFW.getMyWindow()
            win.close()
        }


        function window_onresize() {
            try {
                var body_h = $$("body")[0].getHeight()
                var frmTipoPago_h = $("frmTipoPago").getHeight()

                $("frame_comentarios").setStyle({ height: body_h - frmTipoPago_h + "px" })
            }
            catch (e) { }
        }


        function checkFrame() {
            var checkFrameLoaded = setInterval(function () {
                if ($("frame_comentarios").contentDocument.iframe_detalle !== undefined) {
                    if ($("frame_comentarios").contentDocument.iframe_detalle.document.getElementById("div_registro") !== null) {
                        clearInterval(checkFrameLoaded)

                        // Corregir altura de contenedores
                        var componentes = $("frame_comentarios").contentDocument.querySelectorAll("#menu_right td")
                        var contenedor_h = $("frame_comentarios").getHeight()
                        var tbTitulo_h = $("frame_comentarios").contentDocument.querySelector("#tbTitulo").getHeight()
                        var componentes_h = 0

                        for (var i = 0; i < 4; i++)
                            if (i != 1)     // 1 es el componente a modificar su altura
                                componentes_h += componentes[i].getHeight()

                        componentes[1].querySelector("#divGrupo").setStyle({ height: contenedor_h - tbTitulo_h - componentes_h - 12 + "px" })
                    }
                }
            }, 100)
        }
    </script>
</head>
<body onload="return Inicio()" onresize="window_onresize()" onunload="return Cancelar()" style="width: 100%; height: 100%; background-color: white; overflow: hidden;">
    <form action="Pagos_ABM.aspx" method="post" name="frmTipoPago" id="frmTipoPago" target="frmEnviar" style="margin: 0;">
        <div id="divMenuPagos" style="margin: 0px; padding: 0px;"></div>
        <script type="text/javascript">
            var vMenuPagos = new tMenu('divMenuPagos', 'vMenuPagos');

            vMenuPagos.loadImage("guardar", "/FW/image/icons/guardar.png")

            Menus["vMenuPagos"] = vMenuPagos
            Menus["vMenuPagos"].alineacion = 'centro';
            Menus["vMenuPagos"].estilo = 'A';

            Menus["vMenuPagos"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Aceptar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuPagos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

            vMenuPagos.MostrarMenu()
        </script>
        <input type="hidden" id="num_error" name="num_error" value="<%= num_error %>" />
        <input type="hidden" name="strXML" id="strXML" />
        <input type="hidden" id="nro_pago_registro" name="nro_pago_registro" value="<%= nro_pago_registro %>" />
        <input type="hidden" id="modo" name="modo" value="<%= modo %>" />

        <textarea rows="4" cols="10" style="display: none;" name="txt_xml" id="txt_xml"><%= strXML %></textarea>

        <div id="divcabecera_pagos" style='width: 100%'></div>
        <div id="divdatos_pagos" style='width: 100%'></div>

        <table class="tb1">
            <tr>
                <td style="width:33%"></td>
                <td>
                    <div id="divAgregar"></div>
                </td>
                <td style="width:33%"></td>
            </tr>
        </table>
        <%-- <table class="tb1">
            <tr>
                <td>&nbsp</td>
                <td style="width: 30%">
                    <div id="divAceptar"></div>
                </td>
                <td>&nbsp</td>
                <td style="width: 30%">
                    <div id="divCancelar"></div>
                </td>
                <td>&nbsp</td>
            </tr>
        </table>--%>

        <iframe name="frmEnviar" id="frmEnviar" src="/FW/enBlanco.htm" style="display: none; border: none;"></iframe>
    </form>

    <iframe name='frame_comentarios' id='frame_comentarios' src='/FW/enBlanco.htm' style='width: 100%; height: 200px; border-style: none;'></iframe>
</body>
</html>
