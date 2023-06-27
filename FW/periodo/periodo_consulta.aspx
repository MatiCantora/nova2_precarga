<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 

    If Not nvFW.nvApp.getInstance().operador.tienePermiso("permisos_abm", 1) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.mostrar_error()
    End If


    Me.contents("periodo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='periodos'><campos>*</campos><filtro></filtro></select></criterio>")

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar Periodo</title>
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
        
        function editar_def(nro, desc, mes, anio) {

            var win_nuevo= nvFW.createWindow({
                url: '/fw/periodo/periodo_ABM.aspx',
                title: '<b>Editar periodo:'+ nro +'</b>',
                width: 350,
                height: 250,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                draggable: false,
                onClose: function () {
                }
            })
            win_nuevo.options.userData = {
                nro: nro,
                desc: desc,
                mes: mes,
                anio: anio
            }

            win_nuevo.showCenter(true)
        }

        function nuevo() {
            var win_nuevo = nvFW.createWindow({
                url: '/fw/periodo/periodo_ABM.aspx',
                title: '<b>Nuevo Periodo</b>',
                width: 350,
                height: 250,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                draggable: false,
                onClose: function () {
                }
            })
            win_nuevo.options.userData = {
                nro: 0
            }
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
                filtroXML: nvFW.pageContents.periodo,
                filtroWhere: "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>",
                path_xsl: "..\\fw\\report\\periodo\\periodo.xsl",
                formTarget: 'frmResultados',
                nvFW_mantener_origen: true,
                cls_contenedor: 'frmResultados'
            })
        }

        function deletePeriod(nro) {

            var xml = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xml += "<periodo>"
            xml += "<nro_periodo>" + nro + "</nro_periodo>"
            xml += "<desc_periodo></desc_periodo>"
            xml += "<mes></mes>"
            xml += "<anio>0</anio>"
            xml += "</periodo>"

            Dialog.confirm('<b>¿Desea eliminar este periodo?.</b>', {
                width: 425,
                className: "alphacube",
                okLabel: "Si",
                cancelLabel: "No",
                onOk: function (window) {
                    error_ajax_request("periodo_ABM.aspx", {
                        parameters: {
                            xml: xml,
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

            if ($('nro_period').value != "")
                filtroWhere += "<nro_periodo type='in'>" + $('nro_period').value + "</nro_periodo>"

            if ($('descripcion').value != "")
                filtroWhere += "<desc_periodo type='like'>%" + $('descripcion').value + "%</desc_periodo>"

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
                        <td style="text-align: center;">Nro</td>
                        <td style="text-align: center;">Descripción</td>
                    </tr>
                    <tr>
                        <td style="width:20%">
                            <script type="text/javascript">
                              campos_defs.add("nro_period",{enDB: false,nro_campo_tipo: 101})
                            </script>
                        </td>
                        <td  style="width: 80%">
                            <input type="text" id="descripcion" style="width:100%"/>
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
