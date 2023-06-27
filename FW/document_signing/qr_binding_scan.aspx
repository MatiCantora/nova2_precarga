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
        
        Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
        rpending.element("nro_entidad") = op.nro_entidad
        
        Dim notification_token_update_url As Uri = New Uri(serverUri, "/fw/document_signing/device_notifications_binding.aspx?accion=update_notification_token&app_cod_sistema=" + cod_sistema)

        
        ' key para asegurar autenticacion+integridad en el update de token de notificacion
        Dim hmacAlgorithm As String = "HMACSHA256"
        rpending.element("cod_hmac_algorithm") = "2"
        Dim secret_key As String = Convert.ToBase64String(Encoding.ASCII.GetBytes(Guid.NewGuid().ToString))
        rpending.element("secret_key") = secret_key
        
        ' cuando se registre le devuelve cod_vinculacion
        Dim textToEncode As String = "<QR><register url='" & EscapeXML(url) & "' tran_id='" & rpending.id & "' notification_token_update_url='" & EscapeXML(notification_token_update_url.ToString) & "' hmac_algorithm='" & hmacAlgorithm & "' secret_key='" & secret_key & "'/></QR>"


        Dim qrEncoder As New QrEncoder(ErrorCorrectionLevel.H)
        Dim qrCode = qrEncoder.Encode(textToEncode)
        
        'Dim renderer = New GraphicsRenderer(New FixedModuleSize(5, QuietZoneModules.Two), Brushes.Black, Brushes.White)
        Dim renderer = New GraphicsRenderer(New FixedCodeSize(400, QuietZoneModules.Zero), Brushes.Black, Brushes.White)
        
        Dim bytes As Byte()
        Using stream As New IO.MemoryStream()
            renderer.WriteToStream(qrCode.Matrix, ImageFormat.Png, stream)
            bytes = stream.ToArray
        End Using
        
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
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT count(*) FROM verOperadores_mobile_devices WHERE operador=" & nvApp.operador.operador)
                Dim numConfigurations As Integer = 0
                If Not rs.EOF Then
                    numConfigurations = rs.Fields(0).Value
                End If
                nvDBUtiles.DBCloseRecordset(rs)
                err.params("numConfigurations") = numConfigurations
            End If
        End If
        err.response()
    End If
    
    
    If accion = "update_default_config" Then
        
        Dim cod_binding As String = nvUtiles.obtenerValor("cod_binding", "")
        If cod_binding = "" Then
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT cod_binding FROM verOperadores_mobile_devices WHERE operador=" & nvApp.operador.operador & " order by cod_binding desc")
            cod_binding = rs.Fields(0).Value
            nvDBUtiles.DBCloseRecordset(rs)
        End If
        nvDBUtiles.DBExecute("UPDATE A SET default_config = 0  FROM notification_binding A " &
                             " INNER JOIN device_operador B on B.cod_device_operador=A.cod_device_operador  AND B.operador=" & nvApp.operador.operador & "")
                             
        nvDBUtiles.DBExecute("UPDATE notification_binding SET default_config = 1 WHERE cod_binding=" & cod_binding & "")
                             
        Dim err As New tError
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

            nvFW.error_ajax_request('qr_binding_scan.aspx?accion=LOAD_QR', {
                bloq_contenedor_on: true,
                parameters: {},
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        var imgQR = err.params["imgQR"]
                        var xmlDataBase64String = err.params["xmlDataBase64String"]
                        $('imgQR').src = "data:image/jpg;base64," + imgQR
                        $('xmlDataBase64StringInput').value = xmlDataBase64String;
                        tranId = err.params["tranId"]
                        if (handlerLoadQR == null) {
                            secondsToExpire = err.params["secondsToExpire"]
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
            nvFW.error_ajax_request('qr_binding_scan.aspx', {
                bloq_contenedor_on: false,
                parameters: { accion: "check_device_registered", tran_id: tranId },
                onSuccess: function (err) {
                    debugger
                    if (err.numError == 0) {

                        var registerSuccessful = err.params["registerSuccessful"]
                        if (registerSuccessful == "true") {

                            if (nvFW.getMyWindow().options.userData) {
                                nvFW.getMyWindow().options.userData.retorno["success"] = true
                            }

                            var numConfigurations = err.params["numConfigurations"]
                            if (parseInt(numConfigurations) > 1) {
                                nvFW.confirm('<b>Desea establecer esta vinculación como opción por defecto?</br>'
                                    , { onShow: function () {
                                    },
                                        onOk: function (win) {
                                            updateDefaultConfig()
                                            redirectToExit()
                                            win.close();
                                        },
                                        onCancel: function (win) { redirectToExit(); win.close() },
                                        okLabel: 'Confirmar',
                                        cancelLabel: 'Cancelar'
                                    });
                            } else {
                                updateDefaultConfig()
                                redirectToExit()
                            }
                            //                            if (nvFW.pageContents.f_id) {
                            //                                window.location.replace("/fw/document_signing/pdf_signature_editor.aspx?modo=sign_file&f_id=" + nvFW.pageContents.f_id)
                            //                            } else {
                            //                                if (getMyWindow() != null) {
                            //                                    getMyWindow().options.userData.retorno["success"] = true;
                            //                                    destroyWindow()
                            //                                }
                            //                            }
                        }
                    }
                },
                onFailure: function (err) {
                }
            })
        }



        function updateDefaultConfig() {
            nvFW.error_ajax_request('qr_binding_scan.aspx', {
                asynchronous: false,
                bloq_contenedor_on: false,
                parameters: { accion: "update_default_config" },
                onSuccess: function (err) {
                },
                onFailure: function (err) {
                }
            })
        }


        function redirectToExit() {
            if (nvFW.pageContents.f_id) {
                window.location.replace("/fw/document_signing/pdf_signature_editor.aspx?modo=sign_file&f_id=" + nvFW.pageContents.f_id)
            } else {
                if (getMyWindow() != null) {
                    getMyWindow().options.userData.retorno["success"] = true;
                    destroyWindow()
                }
            }
        }



    </script>
</head>
<body style="width: 100%; height: 100%;overflow:hidden" onload="window_onload()" onresize="window_onresize()">

   
    
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
