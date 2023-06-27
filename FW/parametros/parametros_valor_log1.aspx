<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Editar</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
     

    <%= Me.getHeadInit() %>

    <script type="text/javascript">

        var win = nvFW.getMyWindow()
        var filtro_historico
        var parametros

        function window_onload()
        {
            filtro_historico = win.options.userData.filtro_historico
            parametro = win.options.userData.param
            listar_logs()

            window_onresize()
        }

        function window_onresize() {
            $('frameDatos').setStyle({ height: $$('body')[0].getHeight() })
        }

        function listar_logs() {
            nvFW.exportarReporte({
                filtroXML: filtro_historico,
                filtroWhere: "<criterio><select><filtro><id_param type='igual'>'" + parametro + "'</id_param></filtro></select></criterio>",
                path_xsl: 'report\\parametros\\html_listar_parametros_valor_logs.xsl',
                salida_tipo: 'adjunto',
                ContentType: 'text/html',
                formTarget: 'frameDatos',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Cargando...',
                cls_contenedor: 'frameDatos'

            });
        }



    </script>
</head>
<body style="overflow: auto;" onload="window_onload()" onresize="window_onresize()">
    <form onsubmit="return false;" autocomplete="off">

        <script type="text/javascript">
        </script>
        
        <iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>
    </form>
</body>
</html>