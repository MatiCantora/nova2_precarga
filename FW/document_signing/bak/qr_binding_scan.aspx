<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<script language="VB" runat="server">
    
    Function EscapeXML(str As String) As String
        
        If str <> "" Then
            str = str.Replace("&", "&amp;")
            str = str.Replace("""", "&quot;")
            str = str.Replace("'", "&apos;")
            str = str.Replace("<", "&lt;")
            str = str.Replace(">", "&gt;")
        End If
        Return str
    End Function
    
</script>

<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="Gma.QrCodeNet.Encoding.Windows.Render" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Gma.QrCodeNet.Encoding" %>
<%
    
    Dim accion As String = obtenerValor("accion", "")
    Dim f_id As String = obtenerValor("f_id", "")
    Me.contents("f_id") = f_id
    
    If (accion = "LOAD_QR") Then
        
        Dim operador As String = nvApp.operador.operador
        Dim cod_sistema As String = nvApp.cod_sistema
        Dim cod_servidor As String = nvApp.cod_servidor
        
        
        Dim serverUri As Uri = New Uri(nvApp.server_host_https)
        Dim registerUrl = New Uri(serverUri, "/fw/document_signing/device_notifications_binding.aspx")
        Dim url As String = registerUrl.ToString & "?app_cod_sistema=" & cod_sistema & "&accion=register_device"
        
        Dim rpending As nvFW.nvResponsePending.nvResponsePendingElement = nvFW.nvResponsePending.add("", True, 60)
        rpending.cod_sistema = cod_sistema
        rpending.operador = operador
       
        
        Dim notification_token_update_url As Uri = New Uri(serverUri, "/fw/document_signing/device_notifications_binding.aspx?accion=update_notification_token&app_cod_sistema=" + cod_sistema)

        ' cuando se registre le devuelve cod_vinculacion
        Dim textToEncode As String = "<QR><register url='" & EscapeXML(url) & "' tran_id='" & rpending.id & "' notification_token_update_url='" & EscapeXML(notification_token_update_url.ToString) & "'/></QR>"


        Dim qrEncoder As New QrEncoder(ErrorCorrectionLevel.H)
        Dim qrCode = qrEncoder.Encode(textToEncode)
        Dim renderer = New GraphicsRenderer(New FixedModuleSize(5, QuietZoneModules.Two), Brushes.Black, Brushes.White)
        Dim bytes As Byte()
        Using stream As New IO.MemoryStream()
            renderer.WriteToStream(qrCode.Matrix, ImageFormat.Png, stream)
            bytes = stream.ToArray
        End Using
        
        
        'Response.BinaryWrite(bytes)
        'Response.ContentType = "image/png"
        'Response.End()
        'Me.contents("imgQR") = bytes
        Dim imgQR As String = Convert.ToBase64String(bytes)
        
        Dim err As New tError
        err.params("imgQR") = imgQR
        err.params("xmlDataBase64String") = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(textToEncode))
        err.params("secondsToExpire") = rpending.secondsToExpire
        err.params("tranId") = rpending.id
        err.response()
    End If
    
    
    If accion = "check_device_registered" Then
        
        Dim tran_id As String = nvUtiles.obtenerValor("tran_id", "")
        Dim err as new tError
        err.params("registerSuccessful") = "false"
        If Not nvFW.nvResponsePending.get(tran_id) Is Nothing Then
            If nvFW.nvResponsePending.get(tran_id).state = nvResponsePending.enumPendingSatate.terminado Then
                err.params("registerSuccessful") = "true"
            End If
        End If
        err.response()
    End If
    
    

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Scan QR</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="initial-scale=1"/>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/clipboard/clipboard.js"></script>
    <% = Me.getHeadInit()%>
    <script type='text/javascript'>

        var clipboard
        var handlerSocketConnected
        var handlerLoadQR
        function window_onload() {

            testExp = new RegExp('Android|webOS|iPhone|iPad|' +
    		       'BlackBerry|Windows Phone|' +
    		       'Opera Mini|IEMobile|Mobile',
    		      'i');

            if (testExp.test(navigator.userAgent)) {
                $('divCopyToCB').style.display = 'inline-block'
                clipboard = new Clipboard('.btn');

                /*clipboard.on('success', function (e) {
                    console.info('Action:', e.action);
                    console.info('Text:', e.text);
                    console.info('Trigger:', e.trigger);

                    e.clearSelection();
                });

                clipboard.on('error', function (e) {
                    console.error('Action:', e.action);
                    console.error('Trigger:', e.trigger);
                });*/

            }

            // cargar el qr
            loadQR()

            // cerrar la ventana si pasa mucho tiempo y no se pudo establecer vinculo
            setTimeout(destroyWindow, 180000)
        }

        function destroyWindow() {
            clearInterval(handlerDeviceRegistered)
            clearInterval(handlerLoadQR)
            nvFW.getMyWindow().setDestroyOnClose()
            nvFW.getMyWindow().close()
        }
       
        function window_onresize() {

        }

        var tranId
        var secondsToExpire
        var handlerLoadQR
        var handlerDeviceRegistered

        function loadQR() {

            nvFW.error_ajax_request('qr_vinculo_scan.aspx?accion=LOAD_QR', {
                bloq_contenedor_on: true,
                parameters: {},
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        var imgQR = err.params["imgQR"]
                        var xmlDataBase64String = err.params["xmlDataBase64String"]
                        $('imgQR').src = "data:image/jpg;base64," + imgQR
                        $('xmlDataBase64StringInput').value = xmlDataBase64String;

                        if (handlerLoadQR == null) {
                            secondsToExpire = err.params["secondsToExpire"]
                            tranId = err.params["tranId"]
                            handlerLoadQR = setInterval(loadQR, secondsToExpire * 1000);
                            handlerDeviceRegistered = setInterval(checkDeviceRegistered, 3000);
                        }
                    }
                },
                onFailure: function (err) {
                }
            })
        }

        function checkDeviceRegistered() {
            nvFW.error_ajax_request('qr_vinculo_scan.aspx', {
                bloq_contenedor_on: false,
                parameters: { accion: "check_device_registered", tran_id: tranId },
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        var registerSuccessful = err.params["registerSuccessful"]
                        if (registerSuccessful == "true") {
                            if (nvFW.pageContents.f_id != null) {
                                window.location.replace("notification_select_registered_device.aspx?f_id=" + nvFW.pageContents.f_id)
                            }
                        }
                    }
                },
                onFailure: function (err) {
                }
            })
        }



    </script>
</head>
<body style="width: 100%; height: 100%;" onload="window_onload()" onresize="window_onresize()">

   
    
    <div style="width: 100%; text-align: center; margin-left: auto; margin-right: auto;
        margin-top: 5%">
         <div style="text-align:center;width:100%;"><h2>Utiliza la aplicación de firma para escanear el código QR y vincular tu teléfono celular a este sistema</h2></div>
         <br />
        <img id='imgQR' />
    </div>

    <div id='divCopyToCB' style="text-align: center; width: 100%; margin: auto; display: none">

        <!-- Target -->
        <!-- si el input no es visible, no funciona en algunos browsers -->

        <br />
        <br />
        <br />

        
        <div style="display:inline-block">Si has abierto el sitio desde tu teléfono, puedes copiar el código siguiente y utilizarlo en la aplicación de firma para 
        vincularte</div> 
      
        <input id="xmlDataBase64StringInput" type="text" readonly="readonly" value="" />

        <!-- Trigger -->
      
        <button class="btn" data-clipboard-target="#foo" style="vertical-align: bottom">
            <img src="copy_to_cb.png" alt="Copiar a Portapapeles">
        </button>

    </div>

</body>
</html>
