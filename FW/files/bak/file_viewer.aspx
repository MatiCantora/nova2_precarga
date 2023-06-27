<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim f_id = nvFW.nvUtiles.obtenerValor("f_id", "")
    Me.contents("f_id") = f_id
    
    
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Visor de Archivos</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% =Me.getHeadInit()%>
    <script type="text/javascript">

        var f_id = nvFW.pageContents.f_id
        function window_onload() {
            $('iframeFileView').src = "file_content_response.aspx?f_id=" + f_id
            $('iframeFirmas').src = "file_signatures.aspx?f_id=" + f_id
            $('iframePropiedades').src = "ref_file_pvalues_abm.aspx?f_id=" + f_id
        }

//        //Resize para la pantalla con las propiedades en la barra izquierda, y el content y firmas a la derecha
//        function window_onresize() {
//            try {
//                var dif = Prototype.Browser.IE ? 5 : 2
//                var body_height = $$('body')[0].getHeight()

//                $('divPropiedades').setStyle({ height: body_height - dif + 'px' })

//                var divContent_h = $('divContent').getHeight()
//                $('divFirmas').setStyle({ height: body_height - divContent_h - dif + 'px' })
//            }
//            catch (e) { }
//        }



    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%;
    overflow: hidden">


    <div style="float: left; width: 30%; height: 100%">
    <div id="divPropiedades" style="width: 100%;height:40%;float: left;">
        <iframe style="width: 100%; height: 100%" id='iframePropiedades' name='iframePropiedades'
            src="/fw/enBlanco.htm" frameborder="0" marginheight="0" marginwidth="0"></iframe>
    </div>


    <div id="divFirmas" style="float: left; height:60%;width: 100%;">
            <iframe style="width: 100%; height: 100%" id='iframeFirmas' name='iframeFirmas' src="/fw/enBlanco.htm"
                frameborder="0" marginheight="0" marginwidth="0"></iframe>
    </div>

     </div>


    
        <div id="divContent" style="float: left; width: 70%; height: 100%">
            <iframe style="width: 100%; height: 100%" id='iframeFileView' name='iframeFileView'
                src="/fw/enBlanco.htm" frameborder="0" marginheight="0" marginwidth="0"></iframe>
        </div>

   
</body>
</html>
