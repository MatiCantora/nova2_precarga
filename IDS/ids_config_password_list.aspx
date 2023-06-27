<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim filtro_pwdcfgs As String = nvXMLSQL.encXMLSQL("<criterio><select vista='ids_pwdcfgs'><campos>*</campos><filtro><ids_cli_id>" & Me.operador.ids_cli_id & "</ids_cli_id></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_pwdcfgs") = filtro_pwdcfgs
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es-ar">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <title>Listado configuraciones de Contrase�as</title>
    <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />

    <style>
        body {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        tr.tbLabel td {
            text-align: center;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        
        var win = nvFW.getMyWindow();



        function buscarConfigs()
        {
            var options = {
                filtroXML:            nvFW.pageContents.filtro_pwdcfgs,
                path_xsl:             'report/consultas/password_config_list.xsl',
                formTarget:           'frameListado',
                bloq_contenedor:      $('frameListado'),
                bloq_msg:             'Cargando...',
                nvFW_mantener_origen: true
            };
            
            nvFW.exportarReporte(options);
        }


        function editPwdConfig(ids_pwdcfg_id)
        {
            var win_edicion = nvFW.createWindow({
                url:            'ids_config_password.aspx' + (ids_pwdcfg_id ? '?ids_pwdcfg_id=' + ids_pwdcfg_id : ''),
                title:          '<b>Config Password</b>',
                width:          700,
                height:         500,
                destroyOnClose: true,
                onClose: function (w)
                {
                    if (w.options.userData.reload)
                    {
                        buscarConfigs();
                    }
                }
            });

            win_edicion.options.userData = { reload: false };
            win_edicion.showCenter(true);
        }


        function windowOnload()
        {
            loadMenu();
            windowOnresize();   // Corregir todos los tama�os
            buscarConfigs();
        }

        
        function windowOnresize()
        {
            try
            {
                var body_h = $$('body')[0].getHeight();
                var menu_h = 24;

                $('frameListado').style.height = body_h - menu_h + 'px';
            }
            catch (e)
            {
                console.error(e);
            }
        }
        
        
        function loadMenu()
        {
            $('divMenu').innerHTML = '';    // Limpiar el contenedor antes de cargar
            vMenu = new tMenu('divMenu', 'vMenu');

            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva()</Codigo></Ejecutar></Acciones></MenuItem>");

            vMenu.loadImage('nuevo', '/IDS/image/icons/nueva.png');

            vMenu.MostrarMenu();
        }


        /*---------------------------------------------------------------------
        | 
        |                                 ABM
        | 
        |--------------------------------------------------------------------*/
        function nueva()
        {
            editServerConfig(null);
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <div id="divMenu"></div>
    <iframe name="frameListado" id="frameListado" src="enBlanco.htm" style="width: 100%; height: 75%; border: none;"></iframe>

</body>
</html>
