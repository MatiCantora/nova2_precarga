<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    'Me.addPermisoGrupo("permisos_abm_cuentas")

    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

    If strXML <> "" Then
        Dim err As New tError()

        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("modificar_proporciones_tope_det", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app, cod_cn:="UNIDATO")
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            If Not rs.EOF Then
                err.numError = rs.Fields("numError").Value
                err.mensaje = rs.Fields("mensaje").Value
                err.debug_desc = rs.Fields("debug_desc").Value
                err.debug_src = rs.Fields("debug_src").Value
            End If

        Catch ex As Exception
            err.numError = 1000
            err.mensaje = "No se pudieron modificar las proporciones de tope."
            err.debug_desc = ex.Message
        End Try

        err.response()
    End If
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Topes Detalle</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <% = Me.getHeadInit()%>

    <script type='text/javascript'>
        var win = nvFW.getMyWindow();

        function cambio() {
            $('btnGuardar').disabled = false;
            $('btnGuardar').title = "Aceptar y guardar";
            parent.topes_modificados($('signo_modificacion').value, $('porcentaje').value);
            $('alerta').hidden = true;
            $('exito').hidden = true;
        }

        function cancelar() {
            win.close();
        }

        function guardar() {
            if ($('porcentaje').value == '') {
                $('alerta').hidden = false;
                return;
            }
                
            let strXML = parent.topes_modificados($('signo_modificacion').value, $('porcentaje').value)


            confirm('¿Confirma que quiere cambiar los topes?', {
                width: 300, className: "alphacube",
                onOk: function (win) {
                    nvFW.error_ajax_request('cambio_topes_lote.aspx', {
                        parameters: {
                            strXML: strXML
                        },
                        onSuccess: function (err, transport) {
                            $('alerta').hidden = true;
                            $('exito').hidden = false;
                        },
                        onFailure: function (err, transport) {

                        }
                    });
                    win.close();
                },
                onCancel: function (win) { win.close() },
                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar'
            });
            
        }

    </script>
</head>

<body style='width: 100%; height: 100%; overflow: hidden'>
    <table class='tb1'>
        <tbody>
            <tr>
                <td>
                    <select id='signo_modificacion' onchange='cambio()'>
                        <option value='+'>+</option>
                        <option value='-'>-</option>
                    </select>
                    <input id='porcentaje' type='number' style='width: 85%' onchange='cambio()' />%
                </td>
            </tr>

            <tr>
                <td style='text-align: center'>
                    <br />
                    <input type='button' value='Previsualizar' onclick="cambio()" />&nbsp;&nbsp;
                    <input id='btnGuardar' type='button' value='Aceptar y Guardar' onclick="guardar()" disabled title="Para poder guardar, primero previsualice los cambios para evitar errores."/>&nbsp;&nbsp;
                    <input type='button' value='Cancelar' onclick="cancelar()"/>
                </td>
            </tr>
        </tbody>
    </table>
    <div id="alerta" hidden="true" style="padding: 5px; margin: 5px; text-align:center; background-color:tomato"><b>No ingreso ningún valor porcentual para modificar los topes.</b></div>
    <div id="exito" hidden="true" style="padding: 5px; margin: 5px; text-align:center; background-color:greenyellow"><b>Modificación hecha correctamente.</b></div>

</body>
</html>
