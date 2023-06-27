<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    'Dim err As New tError
    'Dim id = nvUtiles.obtenerValor("id", "")

    'If (id <> "") Then
    '    Try
    '        DBExecute("delete from ent_vinc_tipo_rel where nro_vinc_tipo_rel=" + id)
    '        DBExecute("delete from ent_vinc_tipo_rel where nro_vinc_tipo=" + id)
    '        DBExecute("delete from ent_vinc_tipos where nro_vinc_tipo=" + id)
    '    Catch ex As Exception
    '        err.parse_error_script(ex)
    '        err.numError = 101
    '        err.titulo = "Error en DB"
    '        err.mensaje = "Mensaje: " & ex.Message
    '    End Try
    '    err.response()
    'End If

    Me.contents("filtro_ent_vinc_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_tipos'><campos>nro_vinc_tipo as id, vinc_tipo as campo, nro_vinc_grupo</campos><filtro></filtro><orden>vinc_tipo</orden></select></criterio>")
    Me.contents("filtro_vinc_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEnt_vinc_tipos_grupos'><campos>*</campos><filtro></filtro><orden>nro_vinc_tipo</orden></select></criterio>")
    Me.contents("filtro_ent_vinc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinculos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_ent_vinc_rel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_tipo_rel'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_ent_vinc_grupos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_grupos'><campos>nro_vinc_grupo as id, vinc_grupo as campo</campos><filtro></filtro><orden></orden></select></criterio>")
%>
<%--<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">--%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title>Vinculos ABM</title>
    <link href="/fw/image/icons/nv_voii.ico" type="text/css" rel="shortcut icon" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win = nvFW.getMyWindow()
        var win_grupos_vinculos_abm

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar_vinculo()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", "/FW/image/icons/buscar.png")

        function abm_vinculos_tipos() {

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_grupos_vinculos_abm = w.createWindow({
                className: 'alphacube',
                url: '/FW/entidades/vinculos/ent_vinculos_tipos_ABM.aspx',
                title: '<b>ABM Tipos Vínculos</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                resizable: false,
                modal: true,
                width: 800,
                height: 400,
                //onClose: window_onload
                onClose: function (win_grupos_vinculos_abm) {
                    if (win_grupos_vinculos_abm.options.userData.recargar)
                        buscar_vinculo();
                }
            });
            win_grupos_vinculos_abm.showCenter()
        }

        function buscar_vinculo() {
            var filtroWhere = ''

            var id = $('id').value
            var descripcion = $('descripcion').value

            var cantFilas = Math.floor(($("iframe_vinculos_tipos").getHeight() - 18 * 2) / 22);

            if (id != '') {
                filtroWhere += "<nro_vinc_tipo type='igual'>" + id + "</nro_vinc_tipo>"
            }
            if (descripcion != '') {
                filtroWhere += "<vinc_tipo type='like'>%" + descripcion + "%</vinc_tipo>"
            }

            if (campos_defs.get_value('nro_vinc_grupo') != '') {
                filtroWhere += "<nro_vinc_grupo type='igual'>" + campos_defs.get_value('nro_vinc_grupo') + "</nro_vinc_grupo>"
            }

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_vinc_tipos,
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtroWhere + "</filtro></select></criterio>",
                path_xsl: "report\\verVinculos\\HTML_vinculos_ABM.xsl",
                formTarget: 'iframe_vinculos_tipos',
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                bloq_contenedor: $('iframe_vinculos_tipos'),
                cls_contenedor: 'iframe_vinculos_tipos'
            })
        }

        function window_onload() {

            nvFW.enterToTab = false;

            //nvFW.exportarReporte({
            //    filtroXML: nvFW.pageContents.filtro_vinc_tipos,
            //    path_xsl: "report\\verVinculos\\HTML_vinculos_ABM.xsl",
            //    formTarget: 'iframe_vinculos_tipos',
            //    nvFW_mantener_origen: true,
            //    id_exp_origen: 0,
            //    bloq_contenedor: $('iframe_vinculos_tipos'),
            //    cls_contenedor: 'iframe_vinculos_tipos'
            //})

            vListButtons.MostrarListButton()

            window_onresize();

            buscar_vinculo();

        }

        function editar_tipo_vinculo(id, tipo, grupo, modo) {

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_grupos_vinculos_abm = w.createWindow({
                className: 'alphacube',
                url: '/FW/entidades/vinculos/ent_vinculos_tipos_ABM.aspx?codigoID=' + id + '&descTipo=' + tipo + '&nroGrupo=' + grupo + '&modo=' + modo,
                title: '<b>ABM Grupos Vinculos</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                resizable: false,
                modal: true,
                width: 800,
                height: 400,
                onClose: function (win_grupos_vinculos_abm) {
                    if (win_grupos_vinculos_abm.options.userData.recargar)
                        buscar_vinculo();
                }
            });
            win_grupos_vinculos_abm.showCenter()
        }

        function eliminar_tipo_vinculo(id) {

            Dialog.confirm('¿Desea eliminar el tipo de vínculo?', {
                width: 350,
                className: "alphacube",
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                onOk: function (win) {
                    win.close();
                    var strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>";
                    strXML += "<ent_vinc_tipo modo='B' nro_vinc_grupo='0' vinc_tipo='' nro_vinc_tipo='" + id + "'>";
                    strXML += "<vinc_relaciones>";
                    strXML += "</vinc_relaciones>";
                    strXML += "</ent_vinc_tipo>";

                    nvFW.error_ajax_request('ent_vinculos_tipos_ABM.aspx', {
                        parameters: { modo: 'B', strXML: strXML },
                        onSuccess: function (err, transport) {

                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }

                            buscar_vinculo();

                        },
                        error_alert: true
                    });
                },
                onCancel: function (win) {
                    //window_onload()
                    win.close()
                }
            });



            //var flag = 0

            //var rs = new tRS()
            //rs.open({ filtroXML: nvFW.pageContents.filtro_ent_vinc })
            //while (!rs.eof()) {
            //    if (id == rs.getdata('nro_vinc_tipo')) {
            //        flag = 1
            //        alert('No puede eliminar este registro ya que existe una relacion con la tabla vinculos.')
            //        return
            //    }
            //    rs.movenext()
            //}

            //var rs1 = new tRS()
            //rs1.open({ filtroXML: nvFW.pageContents.filtro_ent_vinc_rel })
            //while (!rs1.eof()) {
            //    if (id == rs1.getdata('nro_vinc_tipo') || id == rs1.getdata('nro_vinc_tipo_rel')) {
            //        flag = 1
            //        alert('No puede eliminar este registro ya que esta vinculado.')
            //        return
            //    }
            //    rs1.movenext()
            //}

            //if (flag == 0) {
            //    nvFW.error_ajax_request('ent_vinculos_tipos_listar.aspx', {
            //        parameters: { id: id },
            //        onSuccess: function (err, transport) {
            //            if (err.numError != 0) {
            //                alert(err.mensaje)
            //                return
            //            }
            //            window_onload()
            //            win.refresh()
            //        },
            //        error_alert: true
            //    })
            //}
        }

        function window_onresize() {

            $('iframe_vinculos_tipos').setStyle({ height: $$('body')[0].getHeight() - $('divMenuVinculo').getHeight() - $('tb_definicion_archivos').getHeight() + 'px' })

        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="overflow: hidden;">
    <div id="divMenuVinculo" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenuVinculo = new tMenu('divMenuVinculo', 'vMenuVinculo');
        vMenuVinculo.loadImage("nuevo", "/fw/image/icons/nueva.png")
        //vMenuVinculo.loadImage("guardar", "/fw/image/icons/guardar.png")
        Menus["vMenuVinculo"] = vMenuVinculo
        Menus["vMenuVinculo"].alineacion = 'centro';
        Menus["vMenuVinculo"].estilo = 'A';
        Menus["vMenuVinculo"].CargarMenuItemXML("<MenuItem id='0' style='width: 86%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Vínculos</Desc></MenuItem>")
        Menus["vMenuVinculo"].CargarMenuItemXML("<MenuItem id='1' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo Tipo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_vinculos_tipos()</Codigo></Ejecutar></Acciones></MenuItem>")
        //Menus["vMenuVinculo"].CargarMenuItemXML("<MenuItem id='2' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>validar_vinc_tipo()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuVinculo.MostrarMenu()
    </script>
    <table class="tb1" id="tb_definicion_archivos">
        <tr>
            <td style="width: 80%">
                <table class="tb1" id="tb_cab" style="width: 100%;">
                    <tr class="tbLabel">
                        <td style='width: 20%; text-align: center;'>ID</td>
                        <td style='width: 50%; text-align: center;'>Descripción</td>
                        <td style='width: 30%; text-align: center;'>Grupo</td>
                    </tr>
                    <tr>
                        <td style='width: 20%; padding: 0;'>
                            <script type="text/javascript">
                                campos_defs.add("id", { enDB: false, nro_campo_tipo: 100 })
                                $('id').addEventListener('keydown', function (e) {
                                    if (e.key === 'Enter') {
                                        buscar_vinculo()
                                    }
                                })
                            </script>
                        </td>
                        <td style='width: 50%; padding: 0;'>
                            <script type="text/javascript">
                                campos_defs.add("descripcion", { enDB: false, nro_campo_tipo: 104 })
                                $('descripcion').addEventListener('keydown', function (e) {
                                    if (e.key === 'Enter') {
                                        buscar_vinculo()
                                    }
                                })
                            </script>
                        </td>
                        <td style='width: 30%; padding: 0;'>
                            <script type="text/javascript">
                                campos_defs.add("nro_vinc_grupo")
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
            <td style="width: 20%">
                <div id="divBuscar"></div>
            </td>
        </tr>
    </table>
    <iframe name="iframe_vinculos_tipos" id="iframe_vinculos_tipos" style='width: 100%; height: 100%; overflow: auto; border: none;' src="/FW/enBlanco.htm"></iframe>
</body>
</html>
