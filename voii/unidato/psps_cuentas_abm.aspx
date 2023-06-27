<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%  
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_pld", 4)) Then
        Response.Redirect("/FW/error/httpError_403.aspx")
    End If

    Me.addPermisoGrupo("permisos_pld")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim id_cliente As String = nvFW.nvUtiles.obtenerValor("id_cliente", "")

    If modo.ToUpper() <> "" Then
        Dim err As New tError()
        Dim strSQL = ""

        Try
            Dim id_tipo_cuenta As String = nvFW.nvUtiles.obtenerValor("tipo_cuenta", "")
            Dim numero_cuenta As String = nvFW.nvUtiles.obtenerValor("numero_cuenta", "")
            Dim cbu As String = nvFW.nvUtiles.obtenerValor("cbu", "")
            Dim id_sucursal As String = nvFW.nvUtiles.obtenerValor("id_sucursal", "")

            Select Case modo
                Case "A"
                    Dim rs = nvDBUtiles.DBExecute(strSQL:="SELECT cbu FROM nv_psps_cuentas WHERE cbu= '" & cbu & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If Not rs.EOF Then
                        err.mensaje = "El CBU ya se encuentra designado a un PSP."
                        err.numError = -5
                        err.response()
                        Return
                    End If
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)

                    strSQL = "INSERT INTO nv_psps_cuentas (id_cliente, cbu, id_sucursal, id_tipo_cuenta, numero_cuenta) VALUES ('" & id_cliente & "', '" & cbu & "', " & id_sucursal & ", " & id_tipo_cuenta & ", " & numero_cuenta & ")"
                    nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")

                Case "M"
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="select top 1 1 from verNv_psp_movimientos m inner join dbo.nv_psp_rel_mov_calc_tope rel on m.id_nv_psp_mov = rel.id_nv_psp_mov and m.id_nv_psp_mov = rel.id_nv_psp_mov where m.id_cliente = '" & id_cliente & "' and m.cbu_psp = '" & cbu & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If rs.EOF Then
                        strSQL = "UPDATE nv_psps_cuentas SET cbu =  " & cbu & "  WHERE id_cliente = '" & id_cliente & "'"
                        nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")
                    Else
                        err.mensaje = "No se puede modificar la cuenta porque tiene movimientos asociados."
                        err.numError = -6
                        err.response()
                        Return
                    End If
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)

                Case "B"
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="select top 1 1 from verNv_psp_movimientos m inner join dbo.nv_psp_rel_mov_calc_tope rel on m.id_nv_psp_mov = rel.id_nv_psp_mov and m.id_nv_psp_mov = rel.id_nv_psp_mov where m.id_cliente = '" & id_cliente & "' and m.cbu_psp = '" & cbu & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If rs.EOF Then
                        strSQL = "DELETE FROM nv_psps_cuentas WHERE id_cliente = '" & id_cliente & "' AND cbu = '" & cbu & "'"
                        nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")
                    Else
                        err.mensaje = "No se puede dar de baja la cuenta porque tiene movimientos asociados."
                        err.numError = -7
                        err.response()
                        Return
                    End If
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)
            End Select

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -2
            err.mensaje = "Ocurrió un error inesperado."
            err.debug_desc &= strSQL
        End Try

        err.response()

    End If

    Me.contents("filtroCuenta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTRLAV_CUENTA_CLIENTE' cn='UNIDATO'><campos>NUMERO_CUENTA as id, TIPO_CUENTA as [campo]</campos><orden></orden><filtro><id_cliente type='igual'>'" & id_cliente & "'</id_cliente></filtro></select></criterio>")
    Me.contents("filtroCuentas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTRLAV_CUENTA_CLIENTE' cn='UNIDATO'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroSucursal") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPAFIP_SUCURSAL' cn='UNIDATO'><campos>ID_SUCURSAL as id, SUCURSAL as [campo] </campos><orden></orden><filtro></filtro></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Tipo Procesos ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var winCuentas = nvFW.getMyWindow();
        var modo = winCuentas.options.user_data.modo;
        var id_cliente = winCuentas.options.user_data.id_cliente;
        var tipo_cuenta = '';
        var cbu_val = false;

        function window_onload() {
            if (modo == 'M') {
                campos_defs.set_value('unidato_id_cuenta', winCuentas.options.user_data.numero_cuenta);
                campos_defs.set_value('numero_cuenta', winCuentas.options.user_data.numero_cuenta);
                campos_defs.set_value('cbu', winCuentas.options.user_data.cbu);
                campos_defs.set_value('id_sucursal', winCuentas.options.user_data.id_sucursal);
            }

            campos_defs.habilitar('numero_cuenta', false);
            campos_defs.habilitar('id_sucursal', false);
        }

        function guardar() {
            if (id_cliente == "") {
                nvFW.alert('No hay un cliente asociado.');
                return;
            }

            else if (tipo_cuenta == "") {
                nvFW.alert('No se seleccionó una cuenta');
                return;
            }

            else if (campos_defs.get_value('numero_cuenta') == "") {
                nvFW.alert('No hay un número de cuenta asociado.');
                return;
            }

            else if (campos_defs.get_value('cbu') == "") {
                nvFW.alert('No se ingresó el CBU.');
                return;
            }

            else if (campos_defs.get_value('id_sucursal') == "") {
                nvFW.alert('No hay una sucursal asociada.');
                return;
            }

            else if (cbu_val == false) {
                nvFW.alert('No se ingreso un CBU correcto');
                return;
            }

            else {
                nvFW.error_ajax_request('psps_cuentas_abm.aspx', {
                    parameters: {
                        modo: modo,
                        id_cliente: id_cliente,
                        tipo_cuenta: tipo_cuenta,
                        numero_cuenta: campos_defs.get_value('numero_cuenta'),
                        cbu: campos_defs.get_value('cbu'),
                        id_sucursal: campos_defs.get_value('id_sucursal')
                    },
                    onSuccess: function () {
						winCuentas.close();
						parent.listarCuentas();
                    },
                    onFailure: function (err) {
                        console.log(err.debug_desc);
                    }
                });
            }
        }

        function validarCBU(cbu) {
            let ponderador = '97139713971397139713971397139713';
            let i;
            let nDigito;
            let nPond;
            let bloque1 = '0' + cbu.substring(0, 7);
            let bloque2;
            let nTotal = 0;

            for (i = 0; i <= 7; i++) {
                nDigito = bloque1.charAt(i);
                nPond = ponderador.charAt(i);
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10);
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i))
                i += 1;

            // i = digito verificador
            //es CVU
            if (cbu.substring(0, 3) == '000')
                return false

            if (cbu.substring(7, 8) != i)
                return false;

            nTotal = 0;
            bloque2 = '000' + cbu.substring(8, 21)

            for (i = 0; i <= 15; i++) {
                nDigito = bloque2.charAt(i)
                nPond = ponderador.charAt(i)
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10)
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i))
                i += 1;

            // i = digito verificador

            if (cbu.substring(21, 22) != i)
                return false;

            return true;
        }

        function recupCuenta() {
            let numero_cuenta = campos_defs.get_value('unidato_id_cuenta');
            let filtroWhere = "<NUMERO_CUENTA type='igual'>'" + numero_cuenta + "'</NUMERO_CUENTA>";
            let rs = new tRS();

            rs.open({ filtroXML: nvFW.pageContents.filtroCuentas, filtroWhere: filtroWhere });
            if (!rs.eof()) {
                tipo_cuenta = rs.getdata("ID_TIPO_CUENTA");
                campos_defs.habilitar('numero_cuenta', true);
                campos_defs.habilitar('id_sucursal', true);
                campos_defs.set_value('numero_cuenta', rs.getdata("NUMERO_CUENTA"));
                campos_defs.set_value('id_sucursal', rs.getdata("ID_SUCURSAL"));
                campos_defs.habilitar('numero_cuenta', false);
                campos_defs.habilitar('id_sucursal', false);
            }
        }

    </script>

</head>
<body style="overflow: hidden;" onload="window_onload()">
    <div id="tGuardar">
        <div id="menuLista" style="width: 100%"></div>
        <script type="text/javascript">
            var vMenu = new tMenu('menuLista', 'vMenu');
            vMenu.alineacion = 'centro'
            vMenu.estilo = 'A'

            vMenu.loadImage('guardar', '/FW/image/icons/guardar.png')

            vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenu.MostrarMenu();
        </script>
    </div>

    <table class="tb1">
        <tr>
            <td class="Tit1" style="width: 100px">Tipo Cuenta:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('unidato_id_cuenta', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtroCuenta,
                        filtroWhere: "<NUMERO_CUENTA type='igual'>campo_value</NUMERO_CUENTA>",
                        onchange: recupCuenta
                    });
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 100px">Nro Cuenta:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('numero_cuenta', {
                        enDB: false,
                        nro_campo_tipo: 100
                    })
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 100px">CBU:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cbu', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        mask: {
                            mask: '0000000000000000000000',
                            placeholderChar: '#',
                            lazy: false
                        },
                        onmask_change: function (campo_def, objcampo_def) {
                            if (objcampo_def['objMask'].masked.isComplete) {
                                cbu_val = validarCBU(campos_defs.get_value(campo_def));
                                if (!cbu_val)
                                    alert('CBU invalida.');
                            } else {
                                cbu_val = false;
                            }
                        }
                    })</script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 100px">Sucursal:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add("id_sucursal", {
                        enDB: false,
                        nro_campo_tipo: 1,
                        filtroXML: nvFW.pageContents.filtroSucursal,
                        mostrar_codigo: false
                    })
                </script>
            </td>
        </tr>
    </table>
</body>
</html>
