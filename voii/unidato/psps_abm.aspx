<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%  
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_pld", 4)) Then
        Response.Redirect("/FW/error/httpError_403.aspx")
    End If

    Me.addPermisoGrupo("permisos_pld")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo.ToUpper() <> "" Then
        Dim id_cliente As String = nvFW.nvUtiles.obtenerValor("id_cliente", "")
        Dim err As New tError()
        Dim strSQL = ""

        Try
            Select Case modo
                Case "A"
                    Dim psp_tipo_docu As String = nvFW.nvUtiles.obtenerValor("psp_tipo_docu", "")
                    Dim cuitcuil As String = nvFW.nvUtiles.obtenerValor("cuitcuil", "")
                    Dim psp_nro_docu = nvFW.nvUtiles.obtenerValor("psp_nro_docu", "")
                    Dim razon_social = nvFW.nvUtiles.obtenerValor("razon_social", "")
                    Dim cod_bcra = nvFW.nvUtiles.obtenerValor("cod_bcra", "")

                    If id_cliente = "" Or psp_tipo_docu = "" Or psp_nro_docu = "" Then
                        err.mensaje = "Ocurríó un error. No se encuentran los datos necesarios del cliente."
                        err.numError = -4
                        err.response()
                        Return
                    End If

                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT id_cliente FROM nv_psps WHERE id_cliente= '" & id_cliente & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If Not rs.EOF Then
                        err.mensaje = "El cliente ya se encuentra desginado como PSP."
                        err.numError = -3
                        err.response()
                        Return
                    End If
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)

                    strSQL = "INSERT INTO nv_psps (id_cliente, psp_tipo_docu, psp_nro_docu, cuitcuil, razon_social, cod_bcra) VALUES ('" & id_cliente & "', " & psp_tipo_docu & ", " & psp_nro_docu & ", '" & cuitcuil & "', '" & razon_social & "', '" & cod_bcra & "')"
                    nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")

                Case "M"
                    Dim cod_bcra = nvFW.nvUtiles.obtenerValor("cod_bcra", "")

                    If id_cliente = "" Then
                        err.mensaje = "Ocurríó un error. No se seleccionó un cliente."
                        err.numError = -100
                        err.response()
                        Return
                    End If

                    strSQL = "update nv_psps set cod_bcra='" & cod_bcra & "' where id_cliente=" & id_cliente
                    nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")

                Case "B"
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT count(*) as cantidad FROM verNv_psp_movimientos WHERE id_cliente= '" & id_cliente & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If Not rs.EOF AndAlso rs.Fields("cantidad").Value > 0 Then
                        err.mensaje = "Este cliente no puede ser eliminado porque ya tiene movimientos asignados."
                        err.numError = -5
                        err.response()
                        Return
                    End If
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)

                    rs = nvDBUtiles.DBExecute(strSQL:="SELECT count(*) as cantidad FROM nv_psp_topes_det WHERE id_cliente= '" & id_cliente & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If Not rs.EOF AndAlso rs.Fields("cantidad").Value > 0 Then
                        err.mensaje = "Este cliente no puede ser eliminado porque tiene detalles de tope asignados."
                        err.numError = -6
                        err.response()
                        Return
                    End If
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)

                    strSQL = "DELETE FROM nv_psps_cuentas WHERE id_cliente = '" & id_cliente & "'"
                    nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")

                    strSQL = "DELETE FROM nv_psps WHERE id_cliente = '" & id_cliente & "'"
                    nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="UNIDATO")
            End Select

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -2
            err.mensaje = "Ocurrió un error inesperado."
            err.debug_desc &= strSQL
        End Try

        err.response()

    End If

    Me.contents("filtroCliente") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPLAV_CLIENTE' cn='UNIDATO'><campos>cast(ID_CLIENTE as varchar(36)) as id, CLIENTE as [campo] </campos><filtro></filtro></select></criterio>")
    Me.contents("filtroClientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPLAV_CLIENTE' cn='UNIDATO'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroCuenta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psps' cn='UNIDATO'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroTipoDoc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPLAV_TIPO_DOC' cn='UNIDATO'><campos> ID_TIPO_DOC as id, TIPO_DOC as [campo]</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroCuentas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psps_cuentas' cn='UNIDATO'><campos>*</campos><filtro></filtro></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM PSP</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow()
        var modo = 'A';
        var id_cliente = '';

        function window_onload() {
            if (typeof win.options.user_data != 'undefined') {
                modo = 'M';
                //document.getElementById('menuItem_menuLista_0').hidden = true;
                document.getElementById('vMenu1').hidden = false;

                id_cliente = win.options.user_data.id_cliente;
                campos_defs.set_value('unidato_id_cliente', "'" + id_cliente + "'");
                campos_defs.set_value('tipo_doc', win.options.user_data.tipo_doc);
                campos_defs.set_value('cuitcuil', win.options.user_data.cuitcuil);
                campos_defs.set_value('cod_bcra', win.options.user_data.cod_bcra);

                listarCuentas();
            }
            else {
                document.getElementById('vMenu1').hidden = true;
                document.getElementById('menuItem_menuLista_2').hidden = true;
                document.getElementById('menuItem_menuLista_3').hidden = true;
            }

            campos_defs.habilitar('tipo_doc', false);
            campos_defs.habilitar('cuitcuil', false);
            campos_defs.habilitar('unidato_id_cliente', false);
        }

        function guardar() {
            id_cliente = campos_defs.get_value('unidato_id_cliente');
            let psp_tipo_docu = campos_defs.get_value('tipo_doc');
            let cuitcuil = campos_defs.get_value('cuitcuil');
            let cod_bcra = campos_defs.get_value('cod_bcra');
            let razon_social = ""

            if (campos_defs.get_desc('unidato_id_cliente').indexOf('(') == -1) //en modo edición el campo def no incluye en get_desc el id_cliente, pero si muchos espacios en blanco al final
                razon_social = campos_defs.get_desc('unidato_id_cliente').trim();
            else
                razon_social = campos_defs.get_desc('unidato_id_cliente').split('(')[0].trim(); //en modo nuevo el campo def incluye en get_desc el id_cliente, así que lo ignoramos para guardar el nombre

            if (id_cliente == "" || psp_tipo_docu == "" || cuitcuil == "") {
                nvFW.alert('No se seleccionó un cliente. Faltan datos necesarios para proceder.');
                return;
            }
            else {
                nvFW.error_ajax_request('psps_abm.aspx', {
                    parameters: {
                        modo: modo,
                        id_cliente: id_cliente,
                        psp_tipo_docu: psp_tipo_docu,
                        psp_nro_docu: cuitcuil,
                        cuitcuil: cuitcuil,
                        razon_social: razon_social, 
                        cod_bcra: cod_bcra
                    },

                    onSuccess: function (winDialog) {
                        document.getElementById('menuItem_menuLista_0').hidden = true;
                        document.getElementById('menuItem_menuLista_2').hidden = false;
                        document.getElementById('menuItem_menuLista_3').hidden = false;
                        document.getElementById('vMenu1').hidden = false;
                        listarCuentas();
                    },

                    onFailure: function (err) {
                        nvFW.alert('Ocurrió un error.');
                        console.log(err.debug_desc);
                    }
                });
            }
        }

        function eliminar(id_cliente) {
            if (!nvFW.tienePermiso("permisos_pld", 4)) {
                nvFW.alert("No tiene permisos para realizar esta acción. Contacte al administrador del sistema.");
                return;
            }

            Dialog.confirm("¿Desea eliminar el PSP?", {
                width: 450,
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar',
                className: "alphacube",
                onOk: function (winDialog) {
                    nvFW.error_ajax_request("psps_abm.aspx", {
                        parameters: {
                            modo: 'B',
                            id_cliente: id_cliente,
                        },

                        onSuccess: function () {
                            win.close();
                            parent.buscar_onclick();
                        },

                        onFailure: function (err) {
                            winDialog.close();
                        }
                    });
                }
            });
        }

        function recupCliente() {
            let filtroWhere = "<id_cliente type='igual'>'" + campos_defs.get_value('unidato_id_cliente') + "'</id_cliente>";
            let rs = new tRS();

            rs.open({ filtroXML: nvFW.pageContents.filtroClientes, filtroWhere: filtroWhere })
            if (!rs.eof()) {
                campos_defs.habilitar('tipo_doc', true);
                campos_defs.habilitar('cuitcuil', true);
                campos_defs.set_value('tipo_doc', rs.getdata("ID_TIPO_DOC"));
                campos_defs.set_value('cuitcuil', rs.getdata("NUMERO_DOC"));
                campos_defs.habilitar('tipo_doc', false);
                campos_defs.habilitar('cuitcuil', false);
            }
        }

        function listarCuentas() {
            let filtroWhere = "";
            if (modo == 'A')
                filtroWhere = "<id_cliente type='igual'>'" + campos_defs.get_value('unidato_id_cliente') + "'</id_cliente>";
            else
                filtroWhere = "<id_cliente type='igual'>" + campos_defs.get_value('unidato_id_cliente') + "</id_cliente>";

            let rs = new tRS();
            rs.open({ filtroXML: nvFW.pageContents.filtroCuentas, filtroWhere: filtroWhere })
            if (!rs.eof()) {
                document.getElementById('listaCuentas').hidden = false;
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroCuenta
                    , filtroWhere: filtroWhere
                    , path_xsl: "report/unidato/cuentas_listar.xsl"
                    , salida_tipo: "adjunto"
                    , ContentType: "text/html"
                    , formTarget: "listaCuentas"
                    , nvFW_mantener_origen: true
                })
            }
            else
                document.getElementById('listaCuentas').hidden = true;
        }

        function btn_asignar_cuenta(id_cliente) {
            if (!nvFW.tienePermiso("permisos_pld", 4)) {
                nvFW.alert("No tiene permisos para realizar esta acción. Contacte al administrador del sistema.");
                return;
            }

            if (id_cliente == '') {
                nvFW.alert('Error. No hay cliente seleccionado.');
                return;
            }
            else {
                id_cliente = id_cliente.replace(/'/g, '')
                var winAgregar = nvFW.createWindow(
                    {
                        url: "psps_cuentas_abm.aspx?id_cliente=" + id_cliente,
                        width: "500",
                        height: "150",
                        top: "50",
                        onClose: function (win) {
                            listarCuentas();
                        }
                    }
                )

                winAgregar.options.user_data = {
                    id_cliente: id_cliente,
                    modo: 'A'
                }

                winAgregar.showCenter(true)
            }
        }

        function editar_cuenta(id_cliente, id_tipo_cuenta, numero_cuenta, cbu, id_sucursal) {
            if (!nvFW.tienePermiso("permisos_pld", 4)) {
                nvFW.alert("No tiene permisos para realizar esta acción. Contacte al administrador del sistema.");
                return;
            }

            if (id_cliente == "" || id_cliente == 'undefined') {
                nvFW.alert('Error. No hay cliente seleccionado.');
                return;
            }

            let winAgregar = nvFW.createWindow(
                {
                    url: "psps_cuentas_abm.aspx?id_cliente=" + id_cliente,
                    width: "500",
                    height: "150",
                    top: "50",
                    onClose: function (win) {
                        listarCuentas();
                    }
                }
            )

            winAgregar.options.user_data = {
                id_cliente: id_cliente,
                cbu: cbu,
                modo: 'M',
                id_tipo_cuenta: id_tipo_cuenta,
                numero_cuenta: numero_cuenta,
                id_sucursal: id_sucursal
            }

            winAgregar.showCenter(true);
        }

        function eliminar_cuenta(id_cliente, cbu) {
            if (!nvFW.tienePermiso("permisos_pld", 4)) {
                nvFW.alert("No tiene permisos para realizar esta acción. Contacto al administrador del sistema.");
                return;
            }

            Dialog.confirm("¿Desea realmente eliminar la cuenta del PSP?", {
                width: 450,
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar',
                className: "alphacube",
                onOk: function (win_dialog) {
                    nvFW.error_ajax_request("psps_cuentas_abm.aspx", {
                        parameters: {
                            modo: 'B',
                            id_cliente: id_cliente,
                            cbu: cbu
                        },

                        onSuccess: function (err) {
                            listarCuentas();
                            win_dialog.close();
                        },

                        onFailure: function (err) {
                            nvFW.alert("No se puede eliminar.")
                        }
                    });
                }
            });
        }

        function importar_topes_det() {
            let win_gc = nvFW.createWindow({
                className: 'alphacube',
                url: 'topes_det_lote.aspx',
                title: '<b>Copiar Topes Detalle para nuevo PSP</b>',
                minimizable: false,
                maximizable: false,
                resizable: true,
                draggable: true,
                width: 400,
                height: 200,
                destroyOnClose: true
            });

            win_gc.options.userData = { id_psp_to: campos_defs.get_value('unidato_id_cliente'), desc_psp_to: campos_defs.get_desc('unidato_id_cliente'), modo: 3 };
            win_gc.showCenter(true);
        }

    </script>

</head>

<body style="overflow: hidden;" onload="window_onload()">
    <div id="menuLista" style="width: 100%"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('menuLista', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>copiar</icono><Desc>Importar Topes Det</Desc><Acciones><Ejecutar Tipo='script'><Codigo>importar_topes_det()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar PSP</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar(id_cliente)</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.loadImage("guardar", "/voii/image/icons/guardar.png");
        vMenu.loadImage("eliminar", "/voii/image/icons/eliminar.png");
        vMenu.loadImage("copiar", "/voii/image/icons/copiar.png");

        vMenu.MostrarMenu();
    </script>

    <table class="tb1">
        <tr>
            <td class="Tit1" style="width: 100px">Cliente:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('unidato_id_cliente', {
                        nro_campo_tipo: 3,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtroCliente,
                        filtroWhere: "<id_cliente type='igual'>'%campo_value%'</id_cliente>",
                        campo_codigo: "id_cliente",
                        campo_desc: "cliente",
                        //StringValueIncludeQuote: true,
                        mostrar_codigo: false,
                        onchange: recupCliente
                    });
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 100px">Tipo Doc:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tipo_doc', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtroTipoDoc,
                        filtroWhere: "<ID_TIPO_DOC type='igual'>%campo_value%</ID_TIPO_DOC>",
                        mostrar_codigo: false
                    })
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 100px">Cuit/Cuil:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cuitcuil', {
                        enDB: false,
                        nro_campo_tipo: 104
                    })
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 100px">Código BCRA:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cod_bcra', {
                        enDB: false,
                        nro_campo_tipo: 104
                    })
                </script>
            </td>
        </tr>
    </table>

    <div id="menuLista1" style="width: 100%"></div>
    <script type="text/javascript">
        var vMenu1 = new tMenu('menuLista1', 'vMenu1');
        vMenu1.alineacion = 'centro'
        vMenu1.estilo = 'A'

        vMenu1.loadImage('asignar', '/voii/image/icons/agregar.png')

        vMenu1.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu1.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>asignar</icono><Desc>Asignar Cuenta</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btn_asignar_cuenta(campos_defs.get_value('unidato_id_cliente'))</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu1.MostrarMenu();
    </script>

    <iframe name="listaCuentas" id="listaCuentas" style="width: 100%; height: 100%; border: none;" src="/fw/enBlanco.htm" frameborder="0"></iframe>

</body>
</html>
