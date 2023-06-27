<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%


'Dim parametro As String = nvFW.nvUtiles.obtenerValor("parametro", "")
'Dim filtro_historico As String = nvFW.nvUtiles.obtenerValor("filtro_historico", "")

'Me.contents("filtro_ent_param_valor_log") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ent_param_valor_log'><campos>*</campos><filtro><param type='igual'>'" & parametro & "'</param><nro_entidad type='igual'>" & nro_entidad & "</nro_entidad></filtro><orden>momento</orden></select></criterio>")

'Me.contents("filtro_ent_pld_param_valor_log") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ent_pld_param_valor_log'><campos>*</campos><filtro><param type='igual'>'" & parametro & "'</param><nro_entidad type='igual'>" & nro_entidad & "</nro_entidad></filtro><orden>momento</orden></select></criterio>")

'Me.contents("filtro_historico") = filtro_historico
'Me.contents("parametro") = parametro

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
        //var _parametro = nvFW.pageContents.parametro

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
                filtroWhere: "<criterio><select><filtro><param type='igual'>'" + parametro + "'</param></filtro></select></criterio>",
                path_xsl: 'report\\param_valor_log\\html_listar_param_valor_logs.xsl',
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