<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<% 
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_api_clientes_cfg", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    Me.addPermisoGrupo("permisos_api_clientes_cfg")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then
        Dim err = New tError()
        Dim tipdoc As String = nvFW.nvUtiles.obtenerValor("tipdoc", 0)
        Dim nro_docu As Int64 = nvFW.nvUtiles.obtenerValor("nro_docu", 0)
        Dim ibs_sistcod As Integer = nvFW.nvUtiles.obtenerValor("ibs_sistcod", 0)
        Dim cuecod As Integer = nvFW.nvUtiles.obtenerValor("cuecod", 0)
        Dim cbu As String = nvFW.nvUtiles.obtenerValor("cbu", 0)
        Dim operador As String = nvFW.nvUtiles.obtenerValor("operador", False)
        Dim fe_vigencia As String = nvFW.nvUtiles.obtenerValor("fe_vigencia", "")
        Dim id As Integer = nvFW.nvUtiles.obtenerValor("id", 0)
        Dim estado As Integer = nvFW.nvUtiles.obtenerValor("estado", 0)
        Dim cambio_vig As String = nvFW.nvUtiles.obtenerValor("cambio_vig", "")
        Dim cambio_vigSQL As String
        Dim moneda As String = nvFW.nvUtiles.obtenerValor("moneda", "")
        Dim moncod As Integer = nvFW.nvUtiles.obtenerValor("moncod", 0)
        Dim callback As String = nvFW.nvUtiles.obtenerValor("callback", "")
        Dim razon_social As String = nvFW.nvUtiles.obtenerValor("razon_social", "")
        Dim es_psp As Integer = nvFW.nvUtiles.obtenerValor("es_psp", 0)

        If cambio_vig = "null_vig" Then
            cambio_vigSQL = ",fe_vigencia = null"
        ElseIf cambio_vig = "nueva_vig" Then
            cambio_vigSQL = ",fe_vigencia =CONVERT(DATETIME,GETDATE())"
        Else
            cambio_vigSQL = ""
        End If

        If (modo = "new") Then
            Try
                Dim sql As String = "Insert into API_clientes_cuentas_cfg(tipdoc,nrodoc,sistcod,cuecod,cbu,vigente,moneda,callback,moneda_desc,operador,fe_vigencia,Razon_social,es_psp) values (" & tipdoc & "," & nro_docu & "," & ibs_sistcod & "," & cuecod & ",'" & cbu & "'," & estado & "," & moncod & ",'" & callback & "','" & moneda & "',dbo.rm_nro_operador(),getdate(),'" & razon_social & "'," & es_psp & ")"
                nvFW.nvDBUtiles.DBExecute(sql)

                err.numError = 0
                err.mensaje = "Se guardó con éxito."

            Catch ex As Exception
                err.numError = 1000
                err.mensaje = "No se pudo guardar el registro."
                err.debug_desc = ex.Message
            End Try
        End If

        If (modo = "edit") Then
            Try
                Dim sql As String = "UPDATE API_clientes_cuentas_cfg Set tipdoc=" & tipdoc & ", es_psp = " & es_psp & " , razon_social='" & razon_social & "' ,nrodoc=" & nro_docu & ",sistcod=" & ibs_sistcod & ",cuecod=" & cuecod & ",moneda=" & moncod & ",vigente=" & estado & ",callback='" & callback & "',moneda_desc='" & moneda & "',cbu=" & cbu & ",operador= dbo.rm_nro_operador() " & cambio_vigSQL & " WHERE id_api_cc_cfg=" & id
                nvFW.nvDBUtiles.DBExecute(sql)

                err.numError = 0
                err.mensaje = "Se guardó con éxito."

            Catch ex As Exception
                err.numError = 1001
                err.mensaje = "No se pudo modificar el registro."
                err.debug_desc = ex.Message
            End Try
        End If

        If (modo = "delete") Then
            Try
                Dim sql As String = "delete from API_clientes_cuentas_cfg where id_api_cc_cfg=" & id
                nvFW.nvDBUtiles.DBExecute(sql)

                err.numError = 0
                err.mensaje = "Se eliminó el registro con éxito."

            Catch ex As Exception
                err.numError = 1002
                err.mensaje = "No se pudo eliminar el registro."
                err.debug_desc = ex.Message
            End Try
        End If

        err.response()

    End If

    Me.contents("filtro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verApi_clientes_cfg'><campos>[id_api_cc_cfg],[tipdoc],[tipdoc_desc],[nrodoc],[Razon_social],[sistcod],[siscod_desc],[cuecod],[cbu],[moneda_desc],[nro_moneda],[moneda],[ISO_cod],[vigente],[fe_vigencia],[operador],[Login],[desc_externo],[callback],[es_psp]</campos><filtro></filtro><orden></orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Transferencias conf ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow()
        var modo = win.options.userData.modo
        var cambio_vig = ''

        function window_onload() {
            if (!nvFW.tienePermiso('permisos_api_clientes_cfg', 2)) {
                nvFW.alert('No posee permisos para hacer esta operación, consulte al administrador del sistema.');
                return;
            }

            if (modo == "edit") {
                let id_cfg = win.options.userData.id;
                let filtroCfg = `<id_api_cc_cfg type='igual'>${id_cfg}</id_api_cc_cfg>`;
                nvFW.bloqueo_activar($(document.body), 'cuerpo', 'Cargando...');
                let rs = new tRS();
                rs.async = true

                rs.onComplete = function () {
                    campos_defs.set_value('tipdoc_codext', rs.getdata('tipdoc'));
                    campos_defs.set_value('nrodoc', rs.getdata('nrodoc'));
                    campos_defs.set_value('ibs_cuecod_ca_cc', rs.getdata('cuecod'));
                    campos_defs.set_value('cbu', rs.getdata('cbu'));
                    campos_defs.set_value('fe_desde', rs.getdata('fe_vigencia'));
                    campos_defs.set_value('nro_operador', rs.getdata('operador'));
                    if (rs.getdata('callback') != undefined)
                        campos_defs.set_value('callback', rs.getdata('callback'));
                    $('es_psp').value = rs.getdata('es_psp') == "True" ? 'si' : 'no';

                    switch (rs.getdata('vigente')) {
                        case "True":
                            $('estado').value = "vigente";
                            break;
                        case "False":
                            $('estado').value = "novigente";
                            break;
                    }

                    nvFW.bloqueo_desactivar($(document.body), 'cuerpo');
                }
                rs.open(nvFW.pageContents.filtro, null, filtroCfg)
            }
            else
                document.getElementById('menuItem_divMenuDig_3').hidden = true;

            campos_defs.habilitar('fe_desde', false);
            campos_defs.habilitar('nro_operador', false);
        }

        function guardar() {
            if (!nvFW.tienePermiso('permisos_api_clientes_cfg', 2)) {
                alert('No posee permisos para hacer esta operación, consulte al administrador del sistema.');
                return;
            }

            let id = (modo == 'new' ? 0 : win.options.userData.id)

            if (modo != 'delete') {
                if ($('estado').value == 'novigente') {
                    campos_defs.set_value('fe_desde', "");
                    cambio_vig = 'null_vig';
                }

                if (campos_defs.get_value('nrodoc') == '') {
                    nvFW.alert('Ingresar número de documento.');
                    return;
                }
                if (campos_defs.get_value('ibs_cuecod_ca_cc') == '') {
                    nvFW.alert('Ingresar tipo de cuenta.');
                    return;
                }
                if ($('es_psp').value == '') {
                    nvFW.alert('Especificar si es PSP.');
                    return;
                }

                if (campos_defs.get_value('tipdoc_codext') == '') {
                    nvFW.alert('Ingresar tipo de documento.');
                    return;
                }

                if (campos_defs.get_value('ibs_cuecod_ca_cc') == "" ? 0 : campos_defs.get_value('ibs_cuecod_ca_cc') == '') {
                    nvFW.alert('Ingresar tipo de cuenta.');
                    return;
                }

                if (campos_defs.get_value('cbu') == '') {
                    nvFW.alert('Ingresar CBU.');
                    return;
                }

                if (campos_defs.get_value('cbu').length < 22) {
                    nvFW.alert('El CBU debe tener 22 dígitos.');
                    return;
                }

                if ($('estado').value == '') {
                    nvFW.alert('Seleccionar un estado.');
                    return;
                }

                if (verificarExistenciaCBU(campos_defs.get_value('cbu').toString(), campos_defs.getRS('ibs_cuecod_ca_cc').getdata('moneda')) != 0) {
                    nvFW.alert('Ya existe ese CBU.');
                    return;
                }

                //let tipdoc = campos_defs.get_value('tipdoc_codext');
                //let nro_docu = campos_defs.get_value('nrodoc');
                //let ibs_sistcod = campos_defs.getRS('ibs_cuecod_ca_cc').getdata('sistcod');
                //let cuecod = campos_defs.get_value('ibs_cuecod_ca_cc') == "" ? 0 : campos_defs.get_value('ibs_cuecod_ca_cc');
                //let cbu = campos_defs.get_value('cbu').toString();
                //let fe_vigencia = campos_defs.get_value('fe_desde');
                //let operador = campos_defs.get_value('nro_operador');
                //let callback = campos_defs.get_value('callback');
                //let razon_social = campos_defs.get_desc('nrodoc');
                //let es_psp = $('es_psp').value == 'si' ? 1 : 0;
                //let moneda = campos_defs.getRS('ibs_cuecod_ca_cc').getdata('moneda');
                //let moncod = campos_defs.getRS('ibs_cuecod_ca_cc').getdata('moncod');
                //let estado = $('estado').value;
            }

            let estado = $('estado').value == 'vigente' ? 1 : 0;
            nvFW.error_ajax_request("clientes_cuentas_ABM.aspx", {

                parameters: {
                    modo: modo,
                    id: id,
                    tipdoc: campos_defs.get_value('tipdoc_codext'),
                    nro_docu: campos_defs.get_value('nrodoc'),
                    ibs_sistcod: campos_defs.getRS('ibs_cuecod_ca_cc').getdata('sistcod'),
                    cuecod: campos_defs.get_value('ibs_cuecod_ca_cc') == "" ? 0 : campos_defs.get_value('ibs_cuecod_ca_cc'),
                    cbu: campos_defs.get_value('cbu').toString(),
                    fe_vigencia: campos_defs.get_value('fe_desde'),
                    operador: campos_defs.get_value('nro_operador'),
                    estado: estado,
                    cambio_vig: cambio_vig,
                    moneda: campos_defs.getRS('ibs_cuecod_ca_cc').getdata('moneda'),
                    moncod: campos_defs.getRS('ibs_cuecod_ca_cc').getdata('moncod'),
                    callback: campos_defs.get_value('callback'),
                    razon_social: campos_defs.get_desc('nrodoc'),
                    es_psp: $('es_psp').value == 'si' ? 1 : 0
                },
                onSuccess: function (err, transport) {
                    if (modo != 'edit')
                        win.close();
                    else {
                        nvFW.alert('Guardado.');
                    }
                },
                onFailure: function (err) {
                    nvFW.alert("Ocurrió un error. Contacte al administrador.");
                },
                error_alert: false
            })
        }

        function verificarExistenciaCBU(cbu, moneda) {
            let filtroWhereRs = "<cbu type='igual'>'" + cbu + "'</cbu><moneda type='igual'>'" + moneda + "'</moneda>";
            let rs = new tRS();
            rs.open(nvFW.pageContents.filtro, '', filtroWhereRs);
            if (!rs.eof())
                return 1;

            return 0;
        }

        function nuevo() {
            modo = "new";
            campos_defs.clear();
            campos_defs.habilitar('nro_operador', false);
        }

        function eliminar() {
            Dialog.confirm(`¿Desea eliminar el elemento?`, {
                width: 300, className: "alphacube",
                onOk: function (win) {
                    modo = "delete";
                    guardar();
                },
                onCancel: function (win) { },
                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar'
            });

        }

        function fe_vig() {
            if ($('estado').value == 'novigente') {
                campos_defs.set_value('fe_desde', "");
                cambio_vig = 'null_vig';
            } else if ($('estado').value == 'vigente') {
                cambio_vig = 'nueva_vig';
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

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            // i = digito verificador
            //es CVU
            if (cbu.substring(0, 3) == '000')
                return false;

            if (cbu.substring(7, 8) != i)
                return false;

            nTotal = 0;
            bloque2 = '000' + cbu.substring(8, 21);

            for (i = 0; i <= 15; i++) {
                nDigito = bloque2.charAt(i);
                nPond = ponderador.charAt(i);
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10);
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            if (cbu.substring(21, 22) != i)
                return false;

            return true;
        }

        function onchange_ibs() {
            campos_defs.set_value('cbu', campos_defs.getRS('ibs_cuecod_ca_cc').getdata('cbubloque1').toString() + '0' + campos_defs.getRS('ibs_cuecod_ca_cc').getdata('cbubloque2').toString());
        }

    </script>
</head>

<body id="cuerpo" onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuDig"></div>
    <script type="text/javascript">
        var vMenuAgregar = new tMenu('divMenuDig', 'vMenuAgregar');
        Menus["vMenuAgregar"] = vMenuAgregar
        Menus["vMenuAgregar"].loadImage("guardar", '/fw/image/icons/guardar.png')
        Menus["vMenuAgregar"].loadImage("nuevo", '/fw/image/icons/nueva.png')
        Menus["vMenuAgregar"].loadImage("eliminar", '/fw/image/icons/eliminar.png')
        Menus["vMenuAgregar"].loadImage("parametros", '/fw/image/icons/parametros.png')
        Menus["vMenuAgregar"].alineacion = 'centro';
        Menus["vMenuAgregar"].estilo = 'A';
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
        //Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuAgregar.MostrarMenu()
    </script>

    <table class="tb1 " style="width: 100%">
        <tr>
            <td class="Tit2" style="width: 20%; text-align: center">Tipo de documento:
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tipdoc_codext')
                </script>
            </td>
            <td style="text-align: center" class="Tit2">Cliente:
            </td>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('nrodoc'/*, { nro_campo_tipo: 100, enDB: false }*/)
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="text-align: center">Número de cuenta:
            </td>
            <td colspan="3">
                <script type="text/javascript">
                    campos_defs.add('ibs_cuecod_ca_cc', { onchange: onchange_ibs });
                </script>
            </td>

        </tr>
        <tr>

            <td class="Tit2" style="text-align: center">CBU:
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cbu', {
                        enDB: false,
                        nro_campo_tipo: 104,
                        mask: {
                            mask: '0000000000000000000000',
                            lazy: false,
                            placeholderChar: '#'
                        },
                        onmask_complete: function (campo_def, objcampo_def) { if (validarCBU(campos_defs.get_value(campo_def))) { } else { } }
                    });
                    campos_defs.habilitar('cbu', false)

                </script>
            </td>
            <td colspan="2">
                <table class="tb1 " style="width: 100%">
                    <tr>
                        <td class="Tit2" style="text-align: center">Estado:
                        </td>
                        <td>
                            <select name="select" id="estado" onchange="fe_vig()" style="width: 100%">
                                <option value="vigente" selected>Vigente</option>
                                <option value="novigente">No vigente</option>
                            </select>
                        </td>
                        <td class="Tit2" style="text-align: center">Es PSP:
                        </td>
                        <td>
                            <select name="select" id="es_psp" style="width: 100%">
                                <option value="si">Si</option>
                                <option value="no" selected>No</option>
                            </select>
                        </td>
                    </tr>
                </table>
            </td>

        </tr>

        <tr>
            <td class="Tit2" style="text-align: center">Operador
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_operador')
                </script>
            </td>

            <td class="Tit2" style="text-align: center">Vigencia:
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fe_desde', {
                        nro_campo_tipo: 103, enDB: false
                    })
                </script>
            </td>

        </tr>
        <tr>
            <td class="Tit2" style="text-align: center">Callback
            </td>
            <td colspan="3">
                <script type="text/javascript">
                    campos_defs.add('callback', { nro_campo_tipo: 104, enDB: false })
                </script>
            </td>
        </tr>

    </table>
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 100%; max-height: 817px; overflow: auto" frameborder='0'></iframe>
</body>
</html>
