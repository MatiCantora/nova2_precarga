<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim operador As nvPages.tnvOperadorIDS = nvFW.nvApp.getInstance().operador
    Dim login As String = operador.login.ToUpper()

    '***********************************************
    ' IDS
    Dim action As String = nvUtiles.obtenerValor("action", "")

    If action = "" Then
        ' Debe retornar un string con todos los IDs separados por coma si hay mas de uno; ejempo: 1,2,5,9
        Dim all_ids_cli_id As String = String.Join(",", operador.ids_clients.Keys)
        Dim filtro_clientId As String = "<criterio><select vista='ids_clientes'><campos>ids_cli_id as [id], ids_cliente as [campo]</campos><orden>[campo]</orden><filtro><ids_cli_id type='in'>" & all_ids_cli_id & "</ids_cli_id></filtro></select></criterio>"
        Dim filtro_clientResource As String = "<criterio><select vista='ids_resources'><campos>ids_res_id as [id], ids_resource as [campo]</campos><orden>[campo]</orden></select></criterio>"

        ' Pasar los clientes del operador
        Dim ids_cli_rel As New trsParam

        For Each ids_cli_id_key In operador.ids_clients.Keys
            ids_cli_rel(ids_cli_id_key) = New trsParam({"ids_cli_id", "ids_cliente", "def"}, {operador.ids_clients(ids_cli_id_key).ids_cli_id, operador.ids_clients(ids_cli_id_key).ids_cliente, operador.ids_clients(ids_cli_id_key).default})
        Next

        Me.contents("filtro_clientId") = nvXMLSQL.encXMLSQL(filtro_clientId)
        Me.contents("filtro_clientResource") = nvXMLSQL.encXMLSQL(filtro_clientResource)
        Me.contents("ids_cli_rel") = ids_cli_rel
    Else
        Dim err As New tError

        Try
            Select Case action.ToLower()
                Case "sel_ids_cli"
                    Dim ids_cli_id As Integer = nvUtiles.obtenerValor("ids_cli_id_sel", "")
                    operador.ids_cli_id = ids_cli_id
                    operador.ids_cliente = operador.ids_clients(ids_cli_id).ids_cliente
                    err.params("ids_cli_id") = operador.ids_cli_id
                    err.params("ids_cliente") = operador.ids_cliente
            End Select
        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = 1
            err.titulo = "Error"
            err.mensaje = "Error en actualizacion de operador"
        End Try

        err.response()
    End If

    ' Grupos de permisos a solicitar
    '    Me.addPermisoGrupo("permisos_parametros")
    '    Me.addPermisoGrupo("permisos_seguridad")
    '    Me.addPermisoGrupo("permisos_abm")

    Dim dic_includes As New Dictionary(Of String, Boolean)
    dic_includes.Add("permisos", True)
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>NOVA IDS</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    
    <link rel="shortcut icon" href="image/icons/nv_ids.ico" />
    
    <style type="text/css">
        .client_resource {
            width: 50%;
            vertical-align: bottom;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 0.8em;
            font-weight: bold;
            color: #183884;
        }
        .title {
            padding-right: 10px;
            text-align: right;
            text-transform: uppercase;
            font-size: 0.85em;
            color: #5f5f5f;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>
    
    <% = Me.getHeadInit(dic_includes) %>
    
    <script type="text/javascript">
        var ids_cli_id  = '<% = operador.ids_cli_id %>';
        var ids_cliente = '<% = operador.ids_cliente %>';

        var nvTargetWin = tnvTargetWin()

        if (!window.top.nvTargetWin)
            window.top.nvTargetWin = nvTargetWin
        else
            nvTargetWin = window.top.nvTargetWin



        function window_onresize()
        {
            var dif     = Prototype.Browser.IE ? 5 : 0;
            body_heigth = $$('body')[0].getHeight();
            cab_heigth  = $('tb_cab').getHeight();

            $('tb_body').setStyle({ 'height': body_heigth - cab_heigth - dif + 'px' });

            setTimeout('nvTargetWin.winMinOrder()', 100);
        }


        function loadClients()
        {
            var clientes     = nvFW.pageContents.ids_cli_rel;
            var cliente_def  = null;
            var rs           = new tRS();
            rs.format        = 'getterror';
            rs.format_tError = 'json';
            rs.addField('id', 'string');
            rs.addField('campo', 'string');

            for (id in clientes)
            {
                rs.addRecord({ id: id.toString(), campo: clientes[id].ids_cliente });

                //if (clientes[id].def.toLowerCase() === 'true') cliente_def = id;
                if (clientes[id].def) cliente_def = id;
            }

            // Agregar el RS al campo_def
            campos_defs.items['ids_clientes'].rs = rs;

            // Setear el valor por defecto
            if (cliente_def) campos_defs.set_value('ids_clientes', cliente_def);
        }


        function window_onload()
        {
            $('frame_ref').src                = '/FW/panel.aspx';
            nvTargetWin.base                  = ObtenerVentana('frame_ref');
            nvTargetWin.base_iframe_src       = {};
            nvTargetWin.base_iframe_src.left  = '/IDS/buscar.aspx';
            nvTargetWin.base_iframe_src.right = '';

            loadClients();
            window_onresize();
        }


        function ids_clientes_onchange()
        {
            var ids_cli_id_selected = campos_defs.get_value('ids_clientes');

            nvFW.error_ajax_request("default.aspx",
            {
                parameters: {
                    action:         'sel_ids_cli',
                    ids_cli_id_sel: ids_cli_id_selected
                },
                onSuccess: function (resp)
                {
                    ids_cli_id  = resp.params.ids_cli_id;
                    ids_cliente = resp.params.ids_cliente;
                },
                onFailure: function (resp)
                {
                    console.error(resp.mensaje);
                },
                error_alert: false,
                bloq_contenedor_on: false
            });
        }   
    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="overflow: hidden">
    <form action='' id="ventana_nueva" target="_blank" method="get" style="display: none; margin: 0;"></form>

    <table id="tb_cab" style="width: 100%; height: 64px; padding: 0; border-spacing: 0; border: none;">
        <tr>
            <td rowspan="2" id="logo_rm" style="width: 300px; height: 64px;">
                <object data="/IDS/image/cabecera/Logo_Nova_Inicio_IDS.svg" type="image/svg+xml" style="width: 140px;"></object>
            </td>

            <td>
                <table style="width: 100%; padding: 0; border-spacing: 0; border: none;">
                    <tbody>
                        <tr style="height: 26px; text-align: right;">
                            
                            <td style="width: 100%; vertical-align: middle; font-size: 0.8em;" nowrap>
                                <div style="display: inline-block; width: 200px; margin-right: 1em;">
                                    <script type="text/javascript">
                                        var options = {
                                            enDB:           false,
                                            nro_campo_tipo: 1,
                                            mostrar_codigo: false
                                        };

                                        campos_defs.add('ids_clientes', options);
                                        campos_defs.items['ids_clientes'].onchange = ids_clientes_onchange;
                                    </script>
                                </div>
                            </td>

                            <td id="user_name" style="vertical-align: middle;">&nbsp;<% = login %></td>

                        </tr>
                    </tbody>
                </table>
            </td>
            
            <td style="width: 110px; padding: 0px 10px;">
                <table style="width: 100%; padding: 0; border-spacing: 0; border: none;">
                    <tr>
                        <td id="data_user" style="text-align: right; vertical-align: middle" nowrap>
                            <img class="img_button" alt="bloq_session" title="Bloquear sesión" src="/FW/image/tSession/sesion_bloquear.png" onclick="nvSesion.bloquear()" />
                            <img class="img_button" alt="close_session" title="Cerrar sesión" src="/FW/image/tSession/sesion_cerrar.png" onclick="nvSesion.cerrar()" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="vertical-align: bottom;">
                <div id="DIV_Menu" style="width: 100%"></div>
            </td>
        </tr>
    </table>

    <table id="tb_body" cellpadding="0" cellspacing="0" border="0" style="width: 100%;height: 100%">
        <tr>
            <td>
                <iframe src="/fw/enBlanco.htm" name="frame_ref" id="frame_ref" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            </td>
        </tr>
    </table>
    
    <script type="text/javascript">
        var vMenu = new tMenu('DIV_Menu', 'vMenu');
        vMenu.alineacion = 'izquierda';
        vMenu.estilo = 'O'

        vMenu.loadImage('inicio', '/IDS/image/icons/home.png')
        vMenu.loadImage('tabla', '/IDS/image/icons/tabla.png')
        vMenu.loadImage('estructura', '/IDS/image/icons/estructura.png')
        vMenu.loadImage('buscar', '/IDS/image/icons/buscar.png');
        vMenu.loadImage('password', '/IDS/image/icons/password.png');
        vMenu.loadImage('operador', '/IDS/image/icons/operador.png');
        vMenu.loadImage('permiso', '/IDS/image/icons/llave.png');
        vMenu.loadImage('parametros', '/IDS/image/icons/parametros.png');
        vMenu.loadImage('herramientas', '/IDS/image/icons/herramientas.png');
        vMenu.loadImage('modulo', '/IDS/image/icons/modulo.png');
        vMenu.loadImage('nueva', '/IDS/image/icons/editar.png');
        vMenu.loadImage('analisis', '/IDS/image/icons/analisis.png');
        vMenu.loadImage('play', '/IDS/image/icons/play.png');
        vMenu.loadImage('log', '/IDS/image/icons/ver.png');
        vMenu.loadImage('evento', '/IDS/image/icons/periodo.png');
        vMenu.loadImage('seguridad', '/IDS/image/icons/seguridad.png');
        vMenu.loadImage('bpm', '/IDS/image/icons/BPM.png');
        vMenu.loadImage('sistema', '/IDS/image/sistemas/sistema.png');
        vMenu.loadImage('circuito', '/IDS/image/icons/circuito.png');
        vMenu.loadImage('procesos', '/IDS/image/icons/procesos.png');
        vMenu.loadImage('reporte', '/IDS/image/icons/reporte.png');
        vMenu.loadImage('abm', '/IDS/image/icons/abm.png');
        vMenu.loadImage('entidad', '/IDS/image/icons/entidad.png');
        vMenu.loadImage('vinculo', '/IDS/image/icons/socios.png');
        vMenu.loadImage('mail_server', '/IDS/image/icons/servidor_mail.png');
        vMenu.loadImage('mail_cfg', '/IDS/image/icons/email_config.png');

        var DocumentMNG = new tDMOffLine;
        DocumentMNG.APP_PATH = window.location.href;
        var strXML = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', '/IDS/DocMNG/data/ids_menu.xml');
        vMenu.CargarXML(strXML);

        vMenu.MostrarMenu();
    </script>

</body>
</html>
