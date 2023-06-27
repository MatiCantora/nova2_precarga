<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim modificar As Boolean = nvFW.nvUtiles.obtenerValor("modificar", False)
    Me.contents("modificar") = modificar
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Nosis CDAs ABM</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript" language="javascript">
        var vMenu,
            modificar = nvFW.pageContents.modificar

        function window_onload() {
            cargar_menu()

            if (modificar)
                setear_valores_campos_defs()
        }

        function cargar_menu() {
            vMenu = new tMenu("divMenu", "vMenu")
            vMenu.loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro'
            Menus["vMenu"].estilo = 'A'

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar(" + modificar + ")</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 80%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenu.MostrarMenu()
        }

        function guardar(modificar) {
            if (!comprobar_campos())
                return

            modificar = modificar || false

            var xml = "<nosis nro_entidad='" + window.parent.nro_entidad + "'>"
                    + "<cda "
                    + "accion='" + (modificar ? "modificar" : "agregar") + "' "
                    + "nosis_cda='" + (modificar ? $("nosis_cda").value : campos_defs.get_value("nosis_cda")) + "' "
                    + "nosis_cda_desc='" + campos_defs.get_value("nosis_cda_descripcion") + "' "
                    + "nro_permiso_grupo='" + campos_defs.get_value("nro_permiso_grupo") + "' "
                    + "nro_permiso='" + campos_defs.get_value("nro_permiso_dep") + "' "
                    + "orden='" + (modificar ? window.parent.fila_edicion.orden : (window.parent.orden_maximo > 0 ? window.parent.orden_maximo + 1 : 1)) + "' "
                    + "vigente='" + ($("vigente").checked ? "true" : "false") + "' "
                    + "/></nosis>"

            // llamamos a la funcion guardar del parent y le pedimos que recargue la lista
            window.parent.guardar(xml, true)

            // cerramos la ventana actual
            window.parent.winAgregarEditar.close()
        }

        function comprobar_campos() {
            // Nro CDA
            if (!modificar && campos_defs.get_value("nosis_cda") == "") {
                alert("El campo <b>Nro CDA</b> debe estar completo")
                return false
            }
            else if (!modificar && window.parent.listaCdas.indexOf(+campos_defs.get_value("nosis_cda")) > -1) {
                alert("El campo <b>Nro CDA</b> se encuentra en uso")
                return false
            }

            // Descripcion
            if (campos_defs.get_value("nosis_cda_descripcion") == "") {
                alert("El campo <b>Descripción</b> debe estar completo")
                return false
            }

            // Nro permiso grupo
            if (campos_defs.get_value("nro_permiso_grupo") == "") {
                alert("El campo <b>Nro Permiso Grupo</b> no puede estar vacío")
                return false
            }

            // Nro permiso
            if (campos_defs.get_value("nro_permiso_dep") == "") {
                alert("El campo <b>Nro Permiso</b> no puede estar vacío")
                return false
            }

            return true // si llego acá, todo OK
        }

        // Solo se ejecuta esta funcion al editar
        function setear_valores_campos_defs() {
            if (window.parent.fila_edicion.nosis_cda == undefined) 
                return

            modificar ? $("nosis_cda").value = window.parent.fila_edicion.nosis_cda : campos_defs.set_value("nosis_cda", window.parent.fila_edicion.nosis_cda)
            campos_defs.set_value("nosis_cda_descripcion", window.parent.fila_edicion.nosis_cda_desc)
            campos_defs.set_value("nro_permiso_grupo", window.parent.fila_edicion.nro_permiso_grupo)
            campos_defs.set_value("nro_permiso_dep", window.parent.fila_edicion.nro_permiso)

            if (window.parent.fila_edicion.vigente.toLowerCase() == "true")
                $("vigente").setAttribute("checked", "true")
        }
    </script>
</head>
<body onload="window_onload()" style="background-color: white;">
    <div id="divMenu"></div>
    <table class="tb1">
        <tr>
            <td class="Tit2" style="width: 30%">Nro CDA:</td>
            <td><% 
                    If modificar = True Then
                        Response.Write("<input disabled='true' id='nosis_cda' style='width: 100%; text-align: right;' type='text' value=''/>")
                    Else
                        Response.Write(nvFW.nvCampo_def.get_html_input("nosis_cda", nro_campo_tipo:=100, enDB:=False))
                    End If
                    
                %></td>
        </tr>
        <tr>
            <td class="Tit2" style="width: 30%">Descripción:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("nosis_cda_descripcion", nro_campo_tipo:=104, enDB:=False) %></td>
        </tr>
        <tr>
            <td class="Tit2" style="width: 30%">Nro Permiso Grupo:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_permiso_grupo", nro_campo_tipo:=1, enDB:=True) %></td>
        </tr>
        <tr>
            <td class="Tit2" style="width: 30%">Nro Permiso:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_permiso_dep", nro_campo_tipo:=1, enDB:=True) %></td>
        </tr>
        <tr>
            <td class="Tit2" style="width: 30%">Vigente:</td>
            <td><input id="vigente" name="vigente" type="checkbox" value="False"/></td>
        </tr>
    </table>
</body>
</html>
