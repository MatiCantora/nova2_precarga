<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim cod_image As String = nvUtiles.obtenerValor("cod_image", "")

    If cod_image = "" Then
        Dim err As New tError
        err.titulo = "Error"
        err.mensaje = "Codigo de imagen inválido"
        err.response()
    End If

    Dim query As String = String.Format("select image_type, image_binary from ids_image_validations where cod_image='{0}'", cod_image)
    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(query)

    Dim img_type As String = ""
    Dim img_base64 As String = ""
    Dim img_size As Integer = 0
    Dim img_unit As String = "bytes"

    If Not rs.EOF Then
        img_type = rs.Fields("image_type").Value
        Dim image As Byte() = rs.Fields("image_binary").Value
        img_size = image.Length

        nvDBUtiles.DBCloseRecordset(rs)

        Select Case img_type
            Case "dni_frente"
                img_type = "DNI Frente"

            Case "dni_dorso"
                img_type = "DNI Dorso"

            Case "selfie"
                img_type = "Selfie"

        End Select


        ' Convertir el tamaño de imagen a una unidad ás cómoda si corresponde
        Dim unit_pos As Integer = 0
        Dim units As String() = {"bytes", "Kb", "Mb", "Gb"}

        While img_size > 1024
            img_size = img_size / 1024
            unit_pos += 1
        End While

        img_unit = units(unit_pos)
        img_base64 = Convert.ToBase64String(image)
    End If
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Imagen enviada API</title>
    <link href="/FW/css/base.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>

    <style type="text/css">
        body {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        #datos {
            position: fixed;
            left: 0;
            bottom: 0;
            width: 100%;
            padding: 6px;
            background-color: #333333;
            color: #ffffff;
            font-size: 0.9em;
        }
        h3 {
            margin: 0;
            padding: 10px;
            font-weight: bold;
            text-align: center;
            background-color: #333333;
            color: #ffffff;
        }
    </style>


    <script type="text/javascript">
        var img;
        var interval_img = null;



        function setImageOnComplete(img)
        {
            // Setear la CSS para la imagen
            if (img.naturalWidth > img.naturalHeight)
                img.setStyle({ width: '100%' });
            else
                img.setStyle({ height: '100%' });

            $('dimensiones').innerText = img.naturalWidth + 'x' + img.naturalHeight;
            nvFW.bloqueo_desactivar(null, 'bloq_inicial');
        }


        function windowOnresize()
        {
            try
            {
                let body_h    = $$('body')[0].getHeight();
                let imgType_h = $('imgType').getHeight();
                let datos_h   = $('datos').getHeight();
                let _height   = body_h - imgType_h - datos_h;
                
                $('divImg').setStyle({ height: _height + 'px' });
            }
            catch (e) {}
        }


        function windowOnload()
        {
            windowOnresize();

            img = $('imgEnvida');

            if (img.complete) {
                setImageOnComplete(img);
            }
            else {
                interval_img = window.setInterval(() => {
                    if (img.complete) {
                        setImageOnComplete(img);
                        window.clearInterval(interval_img);
                    }
                }, 15);
            }
        }
    </script>
</head>
<body onload="windowOnload()" onresize="windowOnresize()">

    <script type="text/javascript">
        nvFW.bloqueo_activar($$('body')[0], 'bloq_inicial', 'Cargando...');
    </script>

    <div id="imgType" style="text-align: center;">
        <h3>Tipo: <b><% = img_type %></b></h3>
    </div>

    <div id="divImg" style="text-align: center;">
        <img id="imgEnvida" src="data:image/jpeg;base64,<% = img_base64 %>" alt="img_sent" />
    </div>

    <div id="datos" style="height: 25px; text-align: center;">
        <b>Dimensiones: </b><span id="dimensiones">1024x768</span>

        <span style="font-weight: bold; padding: 0 10px;">|</span>
        
        <b>Tamaño: </b><span><% = img_size & " " & img_unit %></span>
    </div>
</body>
</html>
