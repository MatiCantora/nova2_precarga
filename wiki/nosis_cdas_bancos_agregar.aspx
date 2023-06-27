<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Nosis CDAS Bancos Agregar</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

        <script type="text/javascript" language="javascript">
            var menu

            function window_onload() {
                cargar_menu()
                // dejamos la variable en -1 para que una segunda apertura no venga con valor cargado
                parent.valorBancoNuevo = -1
            }

            function cargar_menu() {
                menu = new tMenu("divMenu", "menu")
                menu.loadImage("guardar", "/FW/image/icons/guardar.png")

                Menus["menu"] = menu
                Menus["menu"].alineacion = 'centro'
                Menus["menu"].estilo = 'A'

                Menus["menu"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["menu"].CargarMenuItemXML("<MenuItem id='1' style='width: 60%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                menu.MostrarMenu()
            }

            // Guardar
            function guardar() {
                var banco = campos_defs.get_value("nro_banco") != "" ? +campos_defs.get_value("nro_banco") : -1
                if (parent.listaBancos.indexOf(banco) > -1) {
                    // avisar al cliente que el banco ya esta en la lista de relaciones
                    alert("<b>" + campos_defs.get_desc("nro_banco") + "</b> ya está vinculado al CDA actual.<br>Por favor, seleccione uno diferente.", {
                        title: "<b>Error: Banco ya vinculado</b>",
                        width: 400,
                        height: 90
                    })
                    
                    parent.valorBancoNuevo = -1
                }
                else {
                    // marcar la variable de la ventana parent con el nuevo valor de banco, para proceder con el guardado del lado del parent
                    parent.valorBancoNuevo = banco
                    // cerrar la ventana
                    parent.winNuevaRel.close()
                }
            }
        </script>
    </head>
    <body onload="window_onload()" style="background-color: white">
        <div id="divMenu"></div>
        <table class="tb1">
            <tr>
                <td class="Tit2" style="height: 1.5em;">Seleccione un banco para la vinculación:</td>
            </tr>
            <tr>
                <td>
                    <%= nvFW.nvCampo_def.get_html_input("nro_banco", enDB:=False, nro_campo_tipo:=3, filtroXML:="<criterio><select vista='banco'><campos>distinct nro_banco as id, banco as  [campo] </campos><filtro><opera_lausana type='igual'>'S'</opera_lausana></filtro><orden>[campo]</orden></select></criterio>") %>
                </td>
            </tr>
        </table>
    </body>
</html>