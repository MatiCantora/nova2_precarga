<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<% 
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim accion = nvUtiles.obtenerValor("accion", "")
    Dim nro = nvUtiles.obtenerValor("nro", "")
    Dim bl = nvUtiles.obtenerValor("bl", "")
    Me.contents("date") = DateTime.Now.ToShortDateString()
    Dim err = New nvFW.tError()

    If Not op.tienePermiso("permisos_debincredin", 1) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.mostrar_error()
    End If

    If (accion = "bl") Then
        Try
            DBExecute("UPDATE dc_mov_def SET activo = " & bl & " WHERE nro_dc_mov_def =" & nro)
        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del parametro"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Me.contents("estadosDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_estados'><campos>id_dc_estado as id, dc_estado as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("tipoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov_tipos'><campos>dc_mov_tipo as id, dc_mov_tipo_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("monedaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='moneda'><campos>ISO_num as id, ISO_cod as campo</campos><filtro><activo type='igual'>1</activo></filtro><orden>campo</orden></select></criterio>")
    Me.contents("bancos_bcra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='bancos_bcra'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("dcDefinicion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov_def'><campos>*</campos><filtro></filtro></select></criterio>")

    Me.addPermisoGrupo("permisos_debincredin")

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar CREDIN y DEBIN</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="application/javascript">
        var filtroWhere

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("buscar", "/fw/image/icons/buscar.png")
        
        function editar_def(id_def, desc, tipo, nro_bnco, sucursal, cuit, cbu, moneda, exp, razonsocial, concepto, tip_cta, activo) {

            var win_nuevo= nvFW.createWindow({
                url: '/voii/debincredin/dc_definicion_ABM.aspx',
                title: '<b>Consulta Definición</b>',
                width: 620,
                height: 420,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })
            win_nuevo.options.userData = {
                id: id_def,
                desc: desc,
                tipo: tipo,
                nro_bnco: nro_bnco,
                sucursal: sucursal,
                cuit: cuit,
                cbu: cbu,
                moneda: moneda,
                exp: exp,
                razonsocial: razonsocial,
                concepto: concepto,
                tip_cta: tip_cta,
                activo: activo
            }

            win_nuevo.showCenter(true)
        }

        function window_onresize()
        {
            var frameHeight = $$('body')[0].clientHeight - $('divMenu').offsetHeight - $('cabecera').offsetHeight  

            $('frmResultados').style.height = frameHeight + 'px';
            $('frmResultados').style.maxHeight = frameHeight + 'px'
        }

        function window_onload()
        {
            vListButton.MostrarListButton()
            window_onresize()
        }

        function buscar() {
            setFiltroWhere()
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.dcDefinicion,
                filtroWhere: "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>",
                path_xsl: "..\\voii\\report\\credindebin\\dc_definicion.xsl",
                formTarget: 'frmResultados',
                nvFW_mantener_origen: true,
                cls_contenedor: 'frmResultados'
            })
        }

        function bajaLogica(nro, td, bl) {
            Dialog.confirm('<b>¿Desea desactivar esta definición?.</b>', {
                width: 425,
                className: "alphacube",
                okLabel: "Si",
                cancelLabel: "No",
                onOk: function (window) {
                    error_ajax_request("dc_definicion_consulta.aspx", {
                        parameters: {
                            accion: 'bl',
                            nro: nro,
                            bl: bl
                        },
                        onSuccess: function (err, transport) {
                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                            buscar()
                        },
                        onFailure: function (err, transport) {
                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                        },
                        bloq_msg: 'DESACTIVANDO...',
                        error_alert: false
                    })
                    window.close()
                }
            })

        }

        function setFiltroWhere()
        {
            filtroWhere = ''

            if ($('activo').value != "")
                filtroWhere += "<activo type='igual'>" + $('activo').value + "</activo>"

            if ($('descripcion').value != "")
                filtroWhere += "<mov_dc_def_desc type='like'>%" + $('descripcion').value + "%</mov_dc_def_desc>"

            if ($('nro_moneda').value != "")
                filtroWhere += "<moneda type='igual'>" + $('nro_moneda').value + "</moneda>"

            if ($('tipo').value != "")
                filtroWhere += "<dc_mov_tipo type='igual'>'" + $('tipo').value + "'</dc_mov_tipo>"

            if (campos_defs.get_value('cbu') != "")
                filtroWhere += "<cbu type='like'>%" + campos_defs.get_value('cbu') + "%</cbu>"
        }

        function validarCBU(cbu) {

            var ponderador = '97139713971397139713971397139713'
            var i
            var nDigito
            var nPond
            var bloque1 = '0' + cbu.substring(0, 7)
            var bloque2
            var nTotal = 0

            for (i = 0; i <= 7; i++) {
                nDigito = bloque1.charAt(i)
                nPond = ponderador.charAt(i)
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10)
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            // i = digito verificador
            //es CVU
            if (cbu.substring(0, 3) == '000') {
                return false;
            }

            if (cbu.substring(7, 8) != i) {
                return false;
            }

            nTotal = 0;

            bloque2 = '000' + cbu.substring(8, 21)

            for (i = 0; i <= 15; i++) {
                nDigito = bloque2.charAt(i)
                nPond = ponderador.charAt(i)
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10)
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            // i = digito verificador

            if (cbu.substring(21, 22) != i) {
                return false;
            }

            return true;
        }

    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <div id="divMenu" style="width: 100%; margin: 0; padding: 0;"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu')

        vMenu.loadImage('nuevo', '/FW/image/icons/nueva.png')
        
		Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>info</icono><Desc>Referencias</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verReferencias()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editar_def(0)</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu.MostrarMenu()
    </script>
    <table class="tb1" id="cabecera">
        <tr>
            <td style='width: 90%;'>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="text-align: center;">Tipo Movimiento</td>
                        <td style="text-align: center;">Activo</td>
                        <td style="text-align: center;">Descripción</td>
                        <td style="text-align: center;">CBU</td>
                        <td style="text-align: center;">Moneda</td>
                    </tr>
                    <tr>
                        <td style="width:10%">
                            <script type="text/javascript">
                                campos_defs.add('tipo', {
                                    enDB: false,
                                    filtroXML: nvFW.pageContents.tipoDef,
                                    nro_campo_tipo: 1
                                })
                            </script>
                        </td>
                        <td  style="width: 10%">
                            <select id="activo" style="width: 100%">
                                <option value=''></option>
                                <option value='1'>Si</option>
                                <option value='0'>No</option>
                            </select>
                        </td>
                        <td  style="width: 25%">
                            <input type="text" id="descripcion" style="width:100%"/>
                        </td>
                        <td  style="width: 15%">
                            <script>
                                campos_defs.add('cbu', {
                                    enDB: false,
                                    nro_campo_tipo: 100,
                                    mask: {
                                        mask: '0000000000000000000000',
                                        lazy: false,
                                        placeholderChar: '#'
                                    },
                                    onmask_complete: function (campo_def, objcampo_def) { if (validarCBU(campos_defs.get_value(campo_def))) { } else { } }
                                });
                            </script>
                        </td>
                        <td style="width: 10%">
                            <script type="text/javascript">
                                campos_defs.add('nro_moneda', {
                                    enDB: false,
                                    filtroXML: nvFW.pageContents.monedaDef,
                                    nro_campo_tipo: 1
                                })
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
            <td style='width: 10%;'>
                <div id="divBuscar"></div>
            </td>
        </tr>
    </table>
    <iframe name="frmResultados" id="frmResultados" style="width: 100%;" frameborder='0'></iframe>
</body>
</html>
