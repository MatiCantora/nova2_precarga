<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 2)) Then
        Response.Redirect("/FW/error/httpError_403.aspx")
    End If

    Dim e As New tError()
    Dim modo As String = nvUtiles.obtenerValor("modo")

    If modo = 1 Then
        '1 -> Viene para poner en lista de aceptación a un cliente
        Try
            Dim psp_from As String = nvUtiles.obtenerValor("psp_from")
            Dim cuitcuil As String = nvUtiles.obtenerValor("cuitcuil")
            Dim monto_tope As Integer = nvUtiles.obtenerValor("monto_tope")

            If monto_tope = 0 Then
                e.numError = -1
                e.mensaje = "El monto tope no puede ser 0."
                e.debug_src = "/unidato/topes_det_lote.aspx"
                e.response()
                Return
            End If

            Dim proporcion_tope_smvm As Double = 0
            'Tope SMVM = 1
            Dim rsTmp As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select tope from nv_psp_topes_tipos where nro_tope_tipo=1", cod_cn:="UNIDATO")
            If Not rsTmp.EOF Then
                proporcion_tope_smvm = monto_tope / rsTmp.Fields("tope").Value
            Else
                e.numError = -2
                e.mensaje = "Ocurrió un error de configuración, no se encontró el tope de tipo SMVM."
                e.debug_desc = "La consulta devolvió nulo. No debería suceder. select tope from nv_psp_topes_tipos where nro_tope_tipo=1, cod_cn:='UNIDATO'"
                e.debug_src = "/unidato/topes_det_lote.aspx"
                e.response()
                Return
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rsTmp)

            Dim proporcion_tope_monto As Double = 0
            'Tope Monto = 2
            rsTmp = nvFW.nvDBUtiles.DBOpenRecordset("select tope from nv_psp_topes_tipos where nro_tope_tipo=2", cod_cn:="UNIDATO")
            If Not rsTmp.EOF Then
                proporcion_tope_monto = monto_tope / rsTmp.Fields("tope").Value
            Else
                e.numError = -3
                e.mensaje = "Ocurrió un error de configuración, no se encontró el tope de tipo Tope."
                e.debug_desc = "La consulta devolvió nulo. No debería suceder. select tope from nv_psp_topes_tipos where nro_tope_tipo=2, cod_cn:='UNIDATO'"
                e.debug_src = "/unidato/topes_det_lote.aspx"
                e.response()
                Return
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rsTmp)

            rsTmp = nvFW.nvDBUtiles.DBOpenRecordset("select tipo_persona, gran_cliente from nv_psp_clientes where cuitcuil='" & cuitcuil & "' and id_cliente='" & psp_from & "'", cod_cn:="UNIDATO")
            Dim tipo_persona As String
            Dim gran_cliente As Integer
            If Not rsTmp.EOF Then
                tipo_persona = rsTmp.Fields("tipo_persona").Value
                If (rsTmp.Fields("gran_cliente").Value.ToString() = "") Then
                    gran_cliente = 0
                Else
                    gran_cliente = Convert.ToInt32(rsTmp.Fields("gran_cliente").Value)
                End If
            Else
                e.numError = -4
                e.mensaje = "El CUIT/CUIL ingresado no pertenece a una persona que sea cliente de dicho PSP."
                e.debug_src = "/unidato/topes_det_lote.aspx"
                e.response()
                Return
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rsTmp)

            'La fecha de alta en lista de aceptación tiene que ser el primer día del mes siguiente al último procesado (es decir, el mes siguiente al último mes del cual se generaron alarmas)
            rsTmp = nvFW.nvDBUtiles.DBOpenRecordset("select max(fe_hasta)+1 as fecha from nv_psp_clientes_calc_tope_cab where fe_hasta > GETDATE() and id_cliente='" & psp_from & "'", cod_cn:="UNIDATO")
            Dim fecha_alta As Date = System.DateTime.Today
            If (Not rsTmp.EOF) And (Not rsTmp.Fields("fecha").Value Is DBNull.Value) Then
                fecha_alta = rsTmp.Fields("fecha").Value
            Else
                If fecha_alta.ToString("dd") <> "01" Then
                    fecha_alta = New DateTime(System.DateTime.Today.Year, System.DateTime.Today.Month, 1).AddMonths(1)
                End If
            End If

            Dim strSQL As String = "INSERT INTO nv_psp_topes_det SELECT '" & psp_from & "', nro_tope_def, " & proporcion_tope_smvm.ToString.Replace(",", ".") & ", '" & tipo_persona & "', " & gran_cliente & ", '" & cuitcuil & "', '" & fecha_alta & "', dateadd(yy,1,'" & fecha_alta & "'), '" & nvApp.operador.login & "' FROM verNv_listar_psp_topes_det WHERE id_cliente =  '" & psp_from & "' and no_vigente = 0 and nro_tope_tipo = 1 and tipo_persona = '" & tipo_persona & "' and gran_cliente=" & gran_cliente & " and cuitcuil is null and proporcion_tope < '" & proporcion_tope_smvm.ToString.Replace(",", ".") & "'"
            nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")

            strSQL = "INSERT INTO nv_psp_topes_det SELECT '" & psp_from & "', nro_tope_def, " & proporcion_tope_monto.ToString.Replace(",", ".") & ", '" & tipo_persona & "', " & gran_cliente & ", '" & cuitcuil & "', '" & fecha_alta & "', dateadd(yy,1,'" & fecha_alta & "'), '" & nvApp.operador.login & "' FROM verNv_listar_psp_topes_det WHERE id_cliente =  '" & psp_from & "' and no_vigente = 0 and nro_tope_tipo = 2 and tipo_persona = '" & tipo_persona & "' and gran_cliente=" & gran_cliente & " and cuitcuil is null and proporcion_tope < '" & proporcion_tope_smvm.ToString.Replace(",", ".") & "'"
            nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")

            nvFW.nvDBUtiles.DBCloseRecordset(rsTmp)

            e.numError = 0
            e.response()

        Catch ex As Exception
            e.numError = 1000
            e.mensaje = "Ocurrió un error no controlado. Contacte con el administrador."
            e.debug_desc = ex.Message
            e.debug_src = "/unidato/topes_det_lote.aspx modo=" & modo
        End Try

    ElseIf modo = 2 Or modo = 3 Then
        '2 -> Viene para copiar topes_det de un psp determinado, a otro psp a seleccionar
        '3 -> Viene para copiar topes_det a un psp, desde otro psp a seleccionar
        Try
            Dim psp_from As String = nvUtiles.obtenerValor("psp_from")
            Dim psp_to As String = nvUtiles.obtenerValor("psp_to")
            Dim proporcion_tope As String = nvUtiles.obtenerValor("proporcion_tope")

            If psp_from = psp_to Then
                e.numError = -1
                e.mensaje = "El PSP de origen y de destino no deben ser iguales."
                e.debug_src = "/unidato/topes_det_lote.aspx"
                e.response()
                Return
            End If

            Dim rsTest As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select nro_topes_det from nv_psp_topes_det where id_cliente='" & psp_to & "'", cod_cn:="UNIDATO")
            If Not rsTest.EOF Then
                e.numError = -2
                e.mensaje = "El PSP de destino ya tiene detalles de tope asociados, no puede procederse."
                e.debug_src = "/unidato/topes_det_lote.aspx"
                e.response()
                Return
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rsTest)

            Dim strSQL As String = "INSERT INTO nv_psp_topes_det (id_cliente, nro_tope_def, proporcion_tope, tipo_persona, gran_cliente, cuitcuil, fecha_alta, fecha_baja, nv_login) SELECT '" & psp_to & "', nro_tope_def, proporcion_tope, tipo_persona, gran_cliente, cuitcuil, GETDATE(), fecha_baja, '" & nvApp.operador.login & "' FROM nv_psp_topes_det WHERE id_cliente =  '" & psp_from & "' and (fecha_baja is null or fecha_baja > GETDATE())"
            nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")

            e.numError = 0
            e.response()

        Catch ex As Exception
            e.numError = 1000
            e.mensaje = "Ocurrió un error no controlado. Contacte con el administrador."
            e.debug_desc = ex.Message
            e.debug_src = "/unidato/topes_det_lote.aspx modo=" & modo
        End Try

    End If

    Me.contents("filtro_topes_det") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_det' cn='UNIDATO'><campos>id_cliente,cuitcuil</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_nv_cliente") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_clientes' cn='UNIDATO'><campos>cuitcuil as [id],razon_social as [campo]</campos><filtro></filtro></select></criterio>")
    Me.contents("filtro_clientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_clientes' cn='UNIDATO'><campos>*</campos><filtro></filtro></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Copiar Topes Detalle</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        let win = nvFW.getMyWindow();
        let psp_to = "";
        let psp_from = "";
        let cliente_cuitcuil = "";

        function window_onload() {
            // MODOS
            // 1 -> Viene para poner en lista de aceptación a un cliente
            // 2 -> Viene para copiar topes_det de un psp determinado, a otro psp a seleccionar
            // 3 -> Viene para copiar topes_det a un psp, desde otro psp a seleccionar

            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")

            pMenu.loadImage("guardar", "/voii/image/icons/guardar.png");
            pMenu.MostrarMenu();

            if (win.options.userData.modo == 1) {
                //Viene para poner en lista de aceptación a un cliente
                cliente_cuitcuil = win.options.userData.cuitcuil;

                campos_defs.add('id_cliente', {
                    enDB: true,
                    mostrar_codigo: false,
                    target: 'td_psp_from'
                });
                campos_defs.set_value('id_cliente', win.options.userData.id_psp_from)

                campos_defs.add('cliente', {
                    nro_campo_tipo: 3,
                    enDB: false,
                    filtroXML: nvFW.pageContents.filtro_nv_cliente,
                    filtroWhere: "<cuitcuil type='igual'>%campo_value%</cuitcuil>",
                    campo_codigo: 'cuitcuil',
                    campo_desc: 'razon_social',
                    target: 'td_cuitcuil_to',
                    onchange: function () { cliente_cuitcuil = campos_defs.get_value('cliente') }

                });
                campos_defs.set_value('cliente', cliente_cuitcuil);

                campos_defs.add('monto_tope', {
                    nro_campo_tipo: 100,
                    enDB: false,
                    target: 'td_monto_tope'
                });

                document.getElementById('tr_psp_destino').hidden = true;
                //document.getElementById('tr_destino').hidden = true;
            }

            else if (win.options.userData.modo == 2) {
                //Viene para copiar topes_det de un psp determinado, a otro psp a seleccionar
                psp_from = win.options.userData.id_psp_from;

                campos_defs.add('id_cliente', { enDB: true, mostrar_codigo: false, target: 'td_psp_to' });
                document.getElementById('td_psp_from').innerHTML = '<input type="text" id="psp_from" style="width: 100%" />';

                $("psp_from").value = win.options.userData.desc_psp_from;
                $("psp_from").disabled = true;

                document.getElementById('tr_cliente_destino').hidden = true;
                document.getElementById('tr_cliente_monto').hidden = true;
            }

            else if (win.options.userData.modo == 3) {
                psp_to = win.options.userData.id_psp_to;

                campos_defs.add('id_cliente', { enDB: true, mostrar_codigo: false, target: 'td_psp_from' });
                document.getElementById('td_psp_to').innerHTML = '<input type="text" id="psp_to" style="width: 100%" />';

                $("psp_to").value = win.options.userData.desc_psp_to;
                $("psp_to").disabled = true;

                //document.getElementById("tr_destino").hidden = true;
                document.getElementById('tr_cliente_destino').hidden = true;
                document.getElementById('tr_cliente_monto').hidden = true;
            }

            else {
                //No debería llegar nunca a esta opción
                win.close();
            }
        }

        function guardar() {
            actualizar_variables();

            if (validar()) {
                if (win.options.userData.modo == 1) {
                    nvFW.error_ajax_request('topes_det_lote.aspx', {
                        parameters: {
                            psp_from: psp_from,
                            cuitcuil: cliente_cuitcuil,
                            monto_tope: campos_defs.get_value('monto_tope'),
                            modo: win.options.userData.modo
                        },
                        onSuccess: function (err, transport) {
                            if (err.numError == 0)
                                nvFW.alert("Operación realizada exitosamente.");
                            else
                                nvFW.alert("Ha sucedido un error, no pudo completarse la operación.");

                        }
                    });
                }
                else if ((win.options.userData.modo == 2) || (win.options.userData.modo == 3)) {
                    nvFW.error_ajax_request('topes_det_lote.aspx', {
                        parameters: {
                            psp_from: psp_from,
                            psp_to: psp_to,
                            modo: win.options.userData.modo
                        },
                        onSuccess: function (err, transport) {
                            if (err.numError == 0)
                                nvFW.alert("Operación realizada exitosamente.");
                            else
                                nvFW.alert("Ha sucedido un error, no pudo completarse la operación.");
                        }
                    });
                }
            }

        }

        function validar() {
            if (campos_defs.get_value('id_cliente') == "") {
                nvFW.alert("Complete todos los datos requeridos.");
                return false;
            }

            if (win.options.userData.modo == 1) {
                if ((campos_defs.get_value('monto_tope') == '') || campos_defs.get_value('cliente') == '') {
                    nvFW.alert("Complete todos los datos.");
                    return false;
                }

                let rs = new tRS();
                let filtroXML = nvFW.pageContents.filtro_clientes;
                let filtroWhere = "<criterio><select><filtro><id_cliente type='igual'>'" + campos_defs.get_value('id_cliente') + "'</id_cliente><cuitcuil type='igual'>'" + campos_defs.get_value('cliente') + "'</cuitcuil></filtro></select></criterio>";
                rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere });

                if (rs.eof()) {
                    nvFW.alert("La persona elegida no figura como cliente del PSP.");
                    return false;
                }

                let rs2 = new tRS();
                filtroXML = nvFW.pageContents.filtro_topes_det;
                filtroWhere = "<criterio><select><filtro><id_cliente type='igual'>'" + campos_defs.get_value('id_cliente') + "'</id_cliente><cuitcuil type='igual'>'" + campos_defs.get_value('cliente') + "'</cuitcuil></filtro></select></criterio>";
                rs2.open({ filtroXML: filtroXML, filtroWhere: filtroWhere });

                if (!rs2.eof()) {
                    nvFW.alert("La persona ya tiene detalles de tope asignados. Pueden modificarse desde la pantalla de Configuración.");
                    return false;
                }
            }
            else if ((win.options.userData.modo == 2) || (win.options.userData.modo == 3)) {
                if (psp_to == "" || psp_from == "") {
                    nvFW.alert("Ha ocurrido un error con alguno de los PSP. Contacte al administrador.");
                    return false;
                }

                let rs = new tRS();
                let filtroXML = nvFW.pageContents.filtro_topes_det;
                let filtroWhere = "<criterio><select><filtro><id_cliente type='igual'>'" + psp_to + "'</id_cliente></filtro></select></criterio>";
                rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere });

                if (!rs.eof()) {
                    nvFW.alert("El PSP de destino ya tiene detalles de tope asociados.");
                    return false;
                }
            }

            return true;
        }

        function actualizar_variables() {
            if (psp_from == "")
                psp_from = campos_defs.get_value('id_cliente');
            else if (psp_to == "")
                psp_to = campos_defs.get_value('id_cliente');
        }

        //function cambio_destino() {
        //    if (document.getElementById("psp").checked) {
        //        document.getElementById("td_cuitcuil_to").hidden = true;
        //        document.getElementById("td_psp_to").hidden = false;
        //    }
        //    else if (document.getElementById("cuitcuil").checked) {
        //        document.getElementById("td_cuitcuil_to").hidden = false;
        //        document.getElementById("td_psp_to").hidden = true;
        //    }
        //}

    </script>

</head>
<body onload="window_onload()" style="overflow: hidden; background-color: white;">
    <div id="divMenuPrincipal"></div>
    <table id="tb_contenido" class="tb1 layout_fixed">
        <tr>
            <td style="width: 25%">PSP Origen</td>
            <td id="td_psp_from"></td>
        </tr>
<%--        <tr id="tr_destino">
            <td style="width: 25%">
                Destino
            </td>
            <td>
                <input type="radio" id="psp" name="destino" value="psp" onchange="cambio_destino()" checked>
                <label for="psp">PSP</label>
                <input type="radio" id="cuitcuil" name="destino" value="cuitcuil" onchange="cambio_destino()">
                <label for="cuitcuil">Cliente (Lista Aceptación)</label>
            </td>
        </tr>--%>
        <tr id="tr_psp_destino">
            <td style="width: 25%"> 
                PSP Destino
            </td>
            <td id="td_psp_to"></td>
        </tr>
        <tr id="tr_cliente_destino">
            <td style="width: 25%"> 
                Cliente Destino
            </td>
            <td id="td_cuitcuil_to"></td>
        </tr>
        <tr id="tr_cliente_monto">
            <td style="width: 25%">
                Monto tope
            </td>
            <td id="td_monto_tope"></td>
        </tr>
    </table>

</body>
</html>
