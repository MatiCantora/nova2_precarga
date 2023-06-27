<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim nro_entidad As String = nvFW.nvUtiles.obtenerValor("nro_entidad", "")
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim id_entidad_pago_def As String = ""

    Me.contents("filtro_entidad_pago_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_pago_def'><campos>id_entidad_pago_def, nro_tipo_pago, id_cuenta, pago_tipo, descripcion, asumir, nro_pago_estado, pago_estados</campos><orden></orden><filtro><nro_entidad type='igual'>%nro_entidad%</nro_entidad><tipo_movimiento type='igual'>'P'</tipo_movimiento></filtro></select></criterio>")
    Me.contents("nro_entidad") = nro_entidad

    If strXML <> "" Then

        Dim Err As New nvFW.tError()

        Try
            Dim cmd As New nvDBUtiles.tnvDBCommand("rm_ent_pago_tipo_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            Dim rs As ADODB.Recordset = cmd.Execute()

            If rs.Fields("numError").Value = 0 Then
                id_entidad_pago_def = rs.Fields("id_entidad_pago_def").Value
                Err.numError = rs.Fields("numError").Value
                Err.mensaje = rs.Fields("mensaje").Value
                Err.params.Add("id_entidad_pago_def", id_entidad_pago_def)
            Else
                Err.titulo = "Error"
                Err.numError = rs.Fields("numError").Value
                Err.mensaje = rs.Fields("mensaje").Value
            End If
        Catch ex As Exception
            Err.titulo = "Error"
            Err.numError = 1
            Err.mensaje = "Error al ejecutar el procedimiento almacenado."
        End Try
        Err.response()
    End If

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Formas de Pago y Cobro</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />


    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var win
        var vButtonItems = {}
        var indice = -1
        var vPago_registro = {}

        var nro_entidad = nvFW.pageContents.nro_entidad

        function window_onload() {
            win = nvFW.getMyWindow()

            Recupera_Pagos_Def(nro_entidad);

            window_onresize();
        }


        function window_onresize() {

        }


        function tbDetalle_pago_redibujar() // redibuja el detalle
        {
            var i
            var j
            var strHTML = "<table class='tb1'><tr class='tbLabel'><td colspan='5'>Tipos de Pago</td></tr></table><table class='tb1 highlightOdd highlightTROver'>"
            var checkeador = ''

            $('divTipoPago').innerHTML = ""

            for (i in vPago_registro) {     // en ABM personas
                checkeador = ''

                if (vPago_registro[i]["asumir"] == 'True')
                    checkeador = "checked"

                strHTML += "<tr>"
                strHTML += "<td style='width: 3%; text-align: center;'><input type='radio' " + checkeador + " name='RCuenta' id='RCuenta' value='" + i + "' onclick='return RCuenta_onclick(" + i + ")' style='border: none; cursor: pointer;'></td>"
                strHTML += "<td style='width: 20%;'>" + vPago_registro[i]["pago_tipo"] + "</td>"
                strHTML += "<td>" + (vPago_registro[i]["descripcion"] != "" ? vPago_registro[i]["descripcion"] : "&nbsp;") + "</td>"
                strHTML += "<td style='width: 15%;'>" + vPago_registro[i]["pago_estados"] + " (" + vPago_registro[i]["nro_pago_estado"] + ")</td>"
                strHTML += "<td style='width: 5%; text-align: center;'><img title='Eliminar Pago' style='cursor:pointer' src='/FW/image/icons/eliminar.png' onclick='Eliminar_Pago_def(" + i + ")'/></td>"
                strHTML += "</tr>"
            }

            strHTML += "</table>"
            $('divTipoPago').insert({ top: strHTML })
        }


        function Recupera_Pagos_Def(nro_entidad) {   // Arma la Cabecera y el array

            var x = 0
            var rs = new tRS();

            var params = '<criterio><params nro_entidad="' + nro_entidad + '" /></criterio>'
            rs.open(nvFW.pageContents.filtro_entidad_pago_def, "", "", "", params)

            while (!rs.eof()) {
                vPago_registro[x] = {}
                vPago_registro[x]["nro_pago_tipo"] = rs.getdata('nro_tipo_pago')
                vPago_registro[x]["id_cuenta"] = rs.getdata('id_cuenta')
                vPago_registro[x]["pago_tipo"] = rs.getdata('pago_tipo')
                vPago_registro[x]["descripcion"] = rs.getdata('descripcion')
                vPago_registro[x]["asumir"] = rs.getdata('asumir')
                vPago_registro[x]["nro_pago_estado"] = rs.getdata('nro_pago_estado')
                vPago_registro[x]["pago_estados"] = rs.getdata('pago_estados')
                vPago_registro[x]["id_entidad_pago_def"] = rs.getdata('id_entidad_pago_def')

                x += 1
                rs.movenext()
            }

            tbDetalle_pago_redibujar();
        }


        var Param_Tipo = {}
        var win_pago_tipo
        function Agregar_Pago_def() {
            Param_Tipo['nro_entidad'] = nro_entidad
            Param_Tipo['tipo'] = 'P'
            Param_Tipo['parametros'] = false

            win_pago_tipo = top.nvFW.createWindow({
                title: '<b>Seleccionar Pago</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 280,
                resizable: false,
                destroyOnClose: true,
                onClose: Pago_tipo_return
            });

            win_pago_tipo.options.userData = { Param_Tipo: Param_Tipo }
            win_pago_tipo.setURL('/FW/pagos/Pagos_tipo_seleccionar.aspx')
            win_pago_tipo.showCenter()
        }


        function Pago_tipo_return() {

            var Datos = win_pago_tipo.options.userData.res
            var indice = 0

            for (var i in vPago_registro) {
                indice = parseInt(i) + 1
            }

            if (Datos) {
                vPago_registro[indice] = {}
                vPago_registro[indice]["nro_pago_tipo"] = Datos["nro_pago_tipo"]
                vPago_registro[indice]["id_cuenta"] = Datos['parametros']['id_cuenta']
                vPago_registro[indice]["pago_tipo"] = Datos["pago_tipo"]

                if (Datos["pg_desc"]) {
                    vPago_registro[indice]["descripcion"] = Datos["pg_desc"]
                }
                else {
                    vPago_registro[indice]["descripcion"] = ""
                }

                if (indice == 0) {
                    vPago_registro[indice]["asumir"] = 'True'
                }
                else {
                    vPago_registro[indice]["asumir"] = 'False'
                }

                vPago_registro[indice]["nro_pago_estado"] = Datos["nro_pago_estado"]
                vPago_registro[indice]["pago_estados"] = Datos["pago_estados"]

                var strXML = ""
                var id_cuenta = 0

                if (vPago_registro[indice]["id_cuenta"] != undefined)
                    id_cuenta = vPago_registro[indice]["id_cuenta"]

                strXML = "<pago_def nro_entidad='" + nro_entidad + "' nro_tipo_pago='" + vPago_registro[indice]["nro_pago_tipo"] + "' id_cuenta='" + id_cuenta + "' asumir='" + vPago_registro[indice]["asumir"] + "' id_entidad_pago_def='' accion='A' />"

                guardar(strXML, indice)

            }
        }


        function guardar(strXML, indice) {

            //permisos ?

            var id_entidad_pago_def

            nvFW.error_ajax_request('ent_pagos_tipo.aspx', {
                parameters: {
                    strXML: strXML
                },
                onSuccess: function (err, transport) {
                    id_entidad_pago_def = err.params['id_entidad_pago_def']
                    if (err.numError == 0) {
                        if (typeof vPago_registro[indice] != "undefined")
                            vPago_registro[indice]['id_entidad_pago_def'] = id_entidad_pago_def
                        tbDetalle_pago_redibujar();
                    }
                },
                onFailure: function (err) {
                    //if (typeof err == 'object') {
                    //    alert(err.mensaje != '' ? err.mensaje : 'Error al intentar guardar.')//, { title: '<b>' + Error + '</b>' })
                    //}
                },
                bloq_msg: "Guardando..."
            })
        }


        function RCuenta_onclick(indice)
        {
            for (i in vPago_registro) {
                vPago_registro[i]["asumir"] = (i == indice) ? 'True' : 'False'
            }

            var strXML = ""
            strXML = "<pago_def nro_entidad='" + nro_entidad + "' nro_tipo_pago='" + vPago_registro[indice]["nro_pago_tipo"] + "' id_cuenta='0' asumir='" + vPago_registro[indice]["asumir"] + "' id_entidad_pago_def='" + vPago_registro[indice]["id_entidad_pago_def"] + "' accion='M' />"
            guardar(strXML, indice)
        }


        function Eliminar_Pago_def(indice)  // Elimina un tipo de Pago
        {

            nvFW.confirm('¿Desea eliminar la forma de pago <b>' + vPago_registro[indice]['pago_tipo'] + '</b>?', {
                width: 300,
                onOk: function (win) {
                    
                    if (Object.keys(vPago_registro).length > 1 && vPago_registro[indice]['asumir'] == 'True') {
                        alert('No puede eliminar la forma de pago por defecto.')
                        win.close()
                        return
                    }
                    var strXML
                    strXML = "<pago_def nro_entidad='" + nro_entidad + "' nro_tipo_pago='' id_cuenta='' asumir='' id_entidad_pago_def='" + vPago_registro[indice]['id_entidad_pago_def'] + "' accion='E' />"
                    delete vPago_registro[indice]
                    guardar(strXML, indice)
                    win.close()
                },
                onCancel: function (win) { win.close() },
                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar'
            });

        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divTipoPago" style="width: 100%;"></div>
    <table id="tb_button" style="width: 100%">
        <tr>
            <td style="text-align: center; width: 100%">
                <img onclick="return Agregar_Pago_def()" src="/FW/image/icons/agregar.png" style="cursor: pointer" title="Agregar">
            </td>
        </tr>
    </table>
</body>
</html>
