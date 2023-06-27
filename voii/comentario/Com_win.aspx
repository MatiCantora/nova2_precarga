<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim nro_reg = nvFW.nvUtiles.obtenerValor("nro_reg", "")
    Me.contents("verRegistro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro' PageSize='29' AbsolutePage='1' cacheControl='Session'><campos>*</campos><filtro><nro_registro>" & nro_reg & "</nro_registro></filtro><orden></orden></select></criterio>")


    Response.Expires = 0
%>
<html>
<head>
<title>Búsqueda de Comentarios</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">
        var coment = nvFW.pageContents.nro_reg
        function window_onload() {
            var win = nvFW.getMyWindow();
            //console.log(win.options.userData)
            //console.log(coment)
            //console.log(nvFW.pageContents.coment)

            var rs = new tRS();
            rs.open({
                filtroXML: nvFW.pageContents.verRegistro,
            })


            $('divCom').innerHTML = '<p>' + rs.getdata('comentario') + '</p>'
        }
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
<div name="divCom" id="divCom" style="width: 100%; height:auto; max-height:325px; overflow:auto"></div>
</body>
</html>