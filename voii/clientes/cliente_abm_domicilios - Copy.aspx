<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
'Me.addPermisoGrupo("permisos_vinculos")
%>
<!DOCTYPE html>
<html lang="es-ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title>Cliente Teléfonos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        body {
            width: 100%;
            height: 100%;
            overflow: auto;
        }
        .pac-container.pac-logo::after {
            content: none;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/IMask/imask.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var winEntidad   = nvFW.getMyWindow();
        var vListButton  = null;
        var vButtonItems = {};



        function loadListButton()
        {
            vButtonItems[0] = {
                "nombre":   "Mostrar",
                "etiqueta": "Mostrar",
                "imagen":   "mostrar",
                "onclick":  "return Mostrar()"
            };
            //vButtonItems[0] = {};
            //vButtonItems[0]["nombre"] = "Mostrar";
            //vButtonItems[0]["etiqueta"] = "Mostrar";
            //vButtonItems[0]["imagen"] = "mostrar";
            //vButtonItems[0]["onclick"] = "return Mostrar()";

            vButtonItems[1] = {
                "nombre":   "Nuevo",
                "etiqueta": "Nuevo",
                "imagen":   "nuevo",
                "onclick":  "return Nuevo()"
            };
            //vButtonItems[1] = {};
            //vButtonItems[1]["nombre"] = "Nuevo";
            //vButtonItems[1]["etiqueta"] = "Nuevo";
            //vButtonItems[1]["imagen"] = "nuevo";
            //vButtonItems[1]["onclick"] = "return Nuevo()";

            vButtonItems[2] = {
                "nombre":   "Guardar",
                "etiqueta": "Guardar",
                "imagen":   "guardar",
                "onclick":  "return Guardar()"
            };
            //vButtonItems[2] = {};
            //vButtonItems[2]["nombre"] = "Guardar";
            //vButtonItems[2]["etiqueta"] = "Guardar";
            //vButtonItems[2]["imagen"] = "guardar";
            //vButtonItems[2]["onclick"] = "return Guardar()";

            vListButton = new tListButton(vButtonItems, 'vListButton');

            vListButton.loadImage("mostrar", '/FW/image/icons/ver.png');
            vListButton.loadImage("nuevo",   '/FW/image/icons/agregar.png');
            vListButton.loadImage("guardar", '/FW/image/icons/guardar.png');
            
            vListButton.MostrarListButton();
        }


        function window_onload()
        {
            loadListButton();
            window_onresize();
        }


        function window_onresize()
        {
            try
            {
            }
            catch (e) {}
        }

        
        function CargarDatos(nro_entidad)
        {
            if (!nro_entidad) return;

            var rs   = new tRS();
            rs.async = true;

            rs.onComplete = function (res)
            {
                if (!res.eof())
                {
                }
            }

            rs.onError = function (res) {
                alert(res.lastError.numError + ' - ' + res.lastError.mensaje);
            }

            rs.open({
                filtroXML:   nvFW.pageContents.filtroXMLEntidad,
                filtroWhere: "<criterio><select><filtro><nro_entidad type='igual'>" + nro_entidad + "</nro_entidad></filtro></select></criterio>"
            });
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()">
    <table class="tb1" cellpadding="0" cellspacing="0">
        <tr class="tbLabel">
            <td style="border-radius: 0;">Domicilio</td>
            <td style="border-radius: 0;">
                <input type="text" style="width: 100%" name="domicilio" id="domicilio"/>
            </td>
        </tr>
    </table>

    <table class="tb1">
        <tr class="tbLabel">
            <td>Teléfonos</td>
        </tr>
    </table>
    
    <div style="width: 80%; float:left;">
        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 25px; text-align: center;">Caract</td>
                <td style="text-align: center;">Número</td>
                <td style="text-align: center;">Tipo</td>
                <td style="text-align: center;">Descripción</td>
            </tr>
        
        </table>
    </div>
    
    <div style="width: 20%; float: left;">
        <div id="divDomicilioAcciones"></div>
        <div id="divMostrar"></div>
        <div id="divNuevo"></div>
        <div id="divGuardar"></div>
    </div>

</body>
</html>