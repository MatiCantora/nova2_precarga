<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim cod_image As String = nvUtiles.obtenerValor("id_origen", "")

    If cod_image = "" Then
        Response.Clear()
        Response.ContentType = "text/html"
        Response.Write("<div style='width: 500px; margin: 0 auto; padding: 25px 0; text-align: center; font-family: Tahoma, sans-serif;'><h2>Error</h2><p style='margin: 0;'>El código de imagen es inválido</p></div>")
        Response.End()
    End If

    Me.contents("cod_image") = cod_image
%>
<!DOCTYPE html>
<html>
<head>
    <title>Detalles de Validación de Imagen</title>
    <link href="/FW/css/base.css" rel="stylesheet" type="text/css" />
    <style>
        body {
            width: 100%;
            overflow: hidden;
        }
        
        div {
            display: inline-block;
            float: left;
            width: 50%;
            height: 100%;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        function setTitle()
        {
            nvFW.getMyWindow().setTitle('<b>Detalles validación de imagen (' + nvFW.pageContents.cod_image + ')</b>');
        }


        function setFrames()
        {
            window.setTimeout(() => { $('frameImage').src = 'get_image.aspx?cod_image=' + nvFW.pageContents.cod_image; }, 0);
            window.setTimeout(() => { $('frameData').src  = 'get_info.aspx?cod_image=' + nvFW.pageContents.cod_image; }, 0);
        }


        function windowOnload()
        {
            setTitle();
            setFrames();
            //windowOnresize();
        }


        //function windowOnresize()
        //{
        //    try
        //    {
        //    }
        //    catch (e) {}
        //}
    </script>
</head>
<body onload="windowOnload()">

    <div>
        <iframe name="frameImage" id="frameImage" src="../enBlanco.htm" style="width: 100%; height: 100%; border: none;"></iframe>
    </div>
    <div>
        <iframe name="frameData" id="frameData" src="../enBlanco.htm" style="width: 100%; height: 100%; border: none;"></iframe>
    </div>

</body>
</html>
