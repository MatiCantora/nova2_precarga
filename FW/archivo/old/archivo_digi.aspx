<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Me.contents("filtro_tipo_archivo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_id_tipo'><campos>nro_archivo_id_tipo as id,archivo_id_tipo as campo</campos></select></criterio>")
    Me.contents("filtro_archivo_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_cab'><campos>nro_def_archivo as id,archivo_def as campo</campos></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Digitalización</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>

    <% = Me.getHeadInit() %>

<script>


</script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto">
    <div id="divMenuDig">
    </div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuDig = new tMenu('divMenuDig', 'vMenuDig');
        Menus["vMenuDig"] = vMenuDig
        Menus["vMenuDig"].alineacion = 'centro';
        Menus["vMenuDig"].estilo = 'A';

       // vMenuDig.loadImage("procesar", "/fw/image/icons/procesar.png");
       // vMenuDig.loadImage("excel", "/FW/image/icons/trabajo.png");

        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Archivos</Desc></MenuItem>")
       // Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>procesar</icono><Desc>Reportes de control</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnEjecutar_transferencia(617)</Codigo></Ejecutar></Acciones></MenuItem>")
       // Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnBuscar_onclick('EXL')</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuDig.MostrarMenu()
    </script>


    <div id="divCabe" style="width: 100%; overflow: auto;">

        <table style="width: 100%" class="tb1">
            <tr class="tbLabel">
                <td style="width: 10%"><b>Fecha del archivo</b></td>
                <td style="width: 10%"><b>Fecha de vencimineto</b></td>
                <td style="width: 15%"><b>Descripción</b></td>
                <td style="width: 20%"><b>Definición</b></td>
                <td style="width: 20%"><b>Tipo</b></td>
                <td style="width: 5%"><b>Nro Tipo</b></td>
                <td style="width: 20%"><b>Operador</b></td>
            </tr>
            <tr>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('momento', { enDB: false, nro_campo_tipo: 103 })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('vencimiento', { enDB: false, nro_campo_tipo: 103 })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('descripcion', {
                            filtroXML: nvFW.pageContents.filtro_tipo_archivo,
                            enDB: false,
                            nro_campo_tipo: 1
                        })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('definicion', {
                            enDB: false,
                            nro_campo_tipo: 1,
                            depende_de: 'descripcion',
                            depende_de_campo: 'nro_archivo_id_tipo',
                            filtroXML: nvFW.pageContents.filtro_archivo_def,
                        })
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add('tipo_archivo', { enDB: false, nro_campo_tipo: 104 })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('nro_tipo', { enDB: false, nro_campo_tipo: 100 })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('operador', { enDB: false, nro_campo_tipo: 104 })
                    </script>
                </td>
            </tr>
        </table>
    
</body>
</html>




