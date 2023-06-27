<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
  
    Me.contents("filtroSicaEntidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_tipo_sica_entidad'><campos>distinct id_tipo_sica_entidad as id, sica_entidad as  [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroSicaTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_tipo_sica_evento'><campos>distinct id_tipo_sica_evento as id, sica_evento as  [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Sistemas ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% =Me.getHeadInit()%>
    <style type="text/css">
        input.Error{
          color: #D8000C;
          background-color: #FFBABA;
        }
        input.FailureAudit{
            color: #D8000C;
            background-color: #FFBABA;
        }
        input.Information{
            color: #059;
            background-color: #BEF;
        }
        input.SuccessAudit{
            color: #270;
            background-color: #DFF2BF;
        }
        input.Warning{
            color: #9F6000;
            background-color: #FEEFB3;
        }
    </style>
    <script type="text/javascript">

        var win = nvFW.getMyWindow();
        var padre = win.parent;
        var idlog
        
        function window_onload() {
            divDescripcion = new tMenu('divDescripcion', 'divDescripcion');
            divDescripcion.loadImage("ver", "/FW/image/icons/ver.png");

            Menus["divDescripcion"] = divDescripcion;
            Menus["divDescripcion"].alineacion = 'centro';
            Menus["divDescripcion"].estilo = 'A';
            Menus["divDescripcion"].CargarMenuItemXML("<MenuItem id='0' style='width: 80%;  vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>ver</icono><Desc>Detalle</Desc></MenuItem>");
            Menus["divDescripcion"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Anterior</Desc><Acciones><Ejecutar Tipo='script'><Codigo>anterior()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["divDescripcion"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Siguiente</Desc><Acciones><Ejecutar Tipo='script'><Codigo>siguiente()</Codigo></Ejecutar></Acciones></MenuItem>")
            divDescripcion.MostrarMenu();
            //alert(win.options.userData.descripcion);


            idlog = win.options.userData.idlog;
            cargarDescripcion();
            window_onresize();

        }

        function cargarDescripcion() {
            var descripcion = parent.descripciones[idlog]
            if (descripcion){
                $('descripcionText').value = 'Fecha Log: ' + descripcion.fe_log + '\n' + descripcion.msg.split(". ").join(".\n");;
                $('idlog').value = descripcion.idlog;
                $('instancia').value = descripcion.instancia;
                $('name').value = descripcion.name;
                $('machine').value = descripcion.machine;
                $('log').value = descripcion.log;

                $('logType').removeAttribute("class");
                $('logType').addClassName(descripcion.logType);
                $('logType').value = $('logType').class = descripcion.logType;
            }
        }

        function siguiente() {

            if (parent.descripciones[idlog - 1]) {
                idlog = idlog - 1
                cargarDescripcion()
            }
            
        }

        function anterior() {
            if (parent.descripciones[idlog + 1]) {
                idlog = idlog + 1
                cargarDescripcion()
            }
        }

        function window_onresize() {
            divDescripcion_h = $('divDescripcion').getHeight();
            tbCampos_h = $('tbCampos').getHeight();
            body_h = $$('BODY')[0].clientHeight;
            
            $('descripcionText').style.height = (body_h - tbCampos_h - divDescripcion_h - 7) + 'px';
        }
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="background-color:white">
    <div id="divDescripcion">
    </div>
    <table class="tb1 scroll" id="tbCampos">
        <tr class="tbLabel">
            <td style="width: 10%">
                Evento
            </td>
            <td style="width: 21%">
                Instancia
            </td>
            <td style="width: 21%">
                Watcher
            </td>
            <td style="width: 16%">
                Máquina
            </td>
            <td style="width: 16%">
                Log
            </td>
            <td style="width: 16%">
                Tipo
            </td>
        </tr>
        <tr>
            <td>
                <input style="width: 100%" readonly id="idlog" />
            </td>
            <td>
                <input style="width: 100%" readonly id="instancia" />
            </td>
            <td>
                <input style="width: 100%" readonly id="name" />
            </td>
            <td>
                <input style="width: 100%" readonly id="machine" />
            </td>
            <td>
                <input style="width: 100%" readonly id="log" />
            </td>
            <td>
                <input style="width: 100%" readonly id="logType" />
            </td>
        </tr>
    </table>
    <textarea id="descripcionText" rows="8" style="width:100%; resize:none" readonly></textarea>
</body>
</html>
