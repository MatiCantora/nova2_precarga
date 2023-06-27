<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageVOII" %>
<%

    Dim err As New tError()

    Dim sol_estado As String = nvFW.nvUtiles.obtenerValor("sol_estado", "")
    Dim nro_sol_tipo As String = nvFW.nvUtiles.obtenerValor("nro_sol_tipo", "")

    Me.contents("solEstadosXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='(sol_tipos t inner join cire_estado_detalle c on t.nro_circuito = c.nro_circuito full join  dbo.sol_estados e on e.sol_estado = c.estado or e.sol_estado = c.estado_origen)'><campos>distinct sol_estado as id, sol_estado_desc as campo</campos><filtro><sol_estado type='distinto'>'" + sol_estado + "'</sol_estado><nro_sol_tipo type='igual'>'" + nro_sol_tipo + "'</nro_sol_tipo></filtro></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Solicitud Estados</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

        <%= Me.getHeadInit() %>

        <script type="text/javascript">
            var ventanaEstados
            function window_onload() {
                ventanaEstados = nvFW.getMyWindow()
                if (ventanaEstados.options.userData == undefined)
                    ventanaEstados.options.userData = {}
                ventanaEstados.options.userData.hay_modificacion = false

                var contentHeight = $$("#estadosTbl")[0].getHeight();
                if (contentHeight < 140)
                    contentHeight += 100

                ventanaEstados.setSize(ventanaEstados.getSize().width, contentHeight);
            }


            function cambiarEstado() {
                var estadoSeleccionado = campos_defs.get_value('sol_estado')
                if (estadoSeleccionado == "") {
                    alert("Seleccione un estado.")
                    return;
                }
                var fechaEstado = campos_defs.get_value('fecha_estado')

                ventanaEstados.options.userData.hay_modificacion = true
                ventanaEstados.options.userData.nuevo_estado = estadoSeleccionado
                ventanaEstados.options.userData.fecha_estado = fechaEstado
                ventanaEstados.close()
            }
        
        </script>

    </head >

    <body  onload="window_onload()">
        <div id="DIV_MenuEstado" style="WIDTH: 100%"></div>
        <script type="text/javascript">
            var vMenuEstado = new tMenu('DIV_MenuEstado', 'vMenuEstado');
            Menus["vMenuEstado"] = vMenuEstado
            Menus["vMenuEstado"].alineacion = 'centro'
            Menus["vMenuEstado"].estilo = 'A'
            vMenuEstado.loadImage("play", "/FW/image/icons/play.png");
            Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Nuevo estado</Desc></MenuItem>")
            Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>play</icono><Desc>Cambiar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>cambiarEstado()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuEstado"].MostrarMenu();
        </script>
        <table class="tb1">
            <tr>
                <td>
                    <script>
                        campos_defs.add('sol_estado', {
                            enDB: false,
                            nro_campo_tipo: 2,
                            filtroXML: nvFW.pageContents.solEstadosXML
                        });
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add("fecha_estado", { enDB: false, nro_campo_tipo: 103 });
                    </script>
                </td>
            </tr>
            
        </table>
    </body>
</html>