<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    
    
      
    
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Documento adjuntable</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <script type="text/javascript">

        var vMenu
        var win
        var firmante
        var docu
       
        function window_onload() {
            win = nvFW.getMyWindow()
            loadMenu()
            debugger

            firmante = win.options.userData.input["firmante"]
            docu = win.options.userData.input["docu"]


            if (firmante["id_esquema"]) {
                var select_adjuntantes = $("select_adjuntantes")
                select_adjuntantes.style.display = ""
                var entidades = firmante["firmantes"]
                for (key in entidades) {
                    var entidad = entidades[key]
                    var opt = document.createElement('option')
                    opt.value = entidad["nro_entidad"]
                    opt.innerHTML = entidad["razon_social"]
                    select_adjuntantes.appendChild(opt)
                }
            }


            if (docu) {
                
                $('nombre_doc').value = docu.nombre_doc
                $('nombre_doc').disabled = "disabled"

                $('descripcion').value = docu.descripcion
                $('cbDocObligatorio').checked = docu.adjuntable_obligatorio

                $('extension').value = docu.extension
                $('extension').disabled = "disabled"

                $('ppi').value = docu.ppi
                $('depthcolor').value = docu.depthcolor

                if (docu["nro_entidad_adjuntante_delegado"]) {
                    $("select_adjuntantes").value = docu["nro_entidad_adjuntante_delegado"]
                }
            }

        }

        function window_onresize() {

        }


        function guardar() {
            
            var nombre_doc = $('nombre_doc').value
            var descripcion = $('descripcion').value
            var obligatorio =  $('cbDocObligatorio').checked
            var extension = $('extension').value
            var ppi = $('ppi').value
            var depthcolor = 0

            if ( $('depthcolor').value=='truecolor'){
                depthcolor = 0
            }
           
            if (!nombre_doc){
                alert("Debe especificar el nombre del archivo adjuntable")
                return
            }

            
            var nro_entidad_adjuntante = firmante["nro_entidad"]
            var nro_entidad_adjuntante_delegado = null

            if (firmante["id_esquema"]) {
                nro_entidad_adjuntante_delegado = $("select_adjuntantes").value

                if (nro_entidad_adjuntante_delegado == "-1") {
                    alert("Debe especificar la persona encargada de adjuntar el documento")
                    return
                }
            }


            var docu_adjuntable = { nombre_doc: nombre_doc,
                descripcion: descripcion,
                adjuntable: true,
                adjuntable_obligatorio: obligatorio,
                nro_entidad_adjuntante: nro_entidad_adjuntante,
                nro_entidad_adjuntante_delegado: nro_entidad_adjuntante_delegado,
                extension: extension,
                ppi: ppi,
                depthcolor: depthcolor
            }

            if (docu) {
                if (docu.id_documento_firma != null) {
                    docu_adjuntable["id_documento_firma"] = docu.id_documento_firma
                }
            }




            // adjuntable
            // nro_entidad_adjuntante
            // adjuntable_obligatorio

            win.options.userData.retorno["success"] = true
            win.options.userData.retorno["docu_adjuntable"] = docu_adjuntable
            win.close()
        }


        function loadMenu() {

            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
            vMenu.MostrarMenu()


        }


    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id="divMenu">
    </div>
    <table class="tb1">
        <tr>
            <td>
                Nombre
            </td>
            <td>
                <input type="text" id='nombre_doc'/>
            </td>
        </tr>
        <tr>
            <td>
                Descripcion
            </td>
            <td>
                <input type="text" id='descripcion' />
            </td>
        </tr>
                <tr>
            <td>
                Extensión
            </td>
            <td>
                <input type="text" id='extension' value='pdf' />
            </td>
        </tr>
        <tr>
            <td>
                Obligatorio
            </td>
            <td>
                <input type="checkbox" checked="checked" id='cbDocObligatorio'/>
            </td>
        </tr>
        <tr>
        <td>
            Adjuntante
        </td>
        <td>
        <select id='select_adjuntantes' style='display:none'><option value='-1'></option></select>
        </td>
        </tr>

        <tr>
        <td>ppi</td>
        <td><input type="text" id='ppi' value="120"/></td>
        </tr>
        <tr>
        <td>depthcolor</td>
        <td><input type="text" id="depthcolor" value="truecolor"/></td>
        </tr>
    </table>
</body>
</html>
