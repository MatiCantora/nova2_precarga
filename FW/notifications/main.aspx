<%@ Page Language="VB" AutoEventWireup="false"  %>

<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Runtime.Serialization.Json" %>

<%@ Import Namespace="System.Net" %>



<%@ Import Namespace="nvFW" %>


<script language="VB" runat="server">
        
    Private Sub GetPOSTResponse(uri As Uri, data As String, apiKey As String, callback As Action(Of WebResponse))
        Dim request As HttpWebRequest = DirectCast(HttpWebRequest.Create(uri), HttpWebRequest)
        
        request.Method = "POST"
        'request.ContentType = "text/plain;charset=utf-8"
        request.ContentType = "application/json;charset=utf-8"
        request.Headers.Add("Authorization", "key=" & apiKey)
        
        Dim encoding As New System.Text.UTF8Encoding()
        Dim bytes As Byte() = encoding.GetBytes(data)

        request.ContentLength = bytes.Length

        Using requestStream As Stream = request.GetRequestStream()
            ' Send the data.
            requestStream.Write(bytes, 0, bytes.Length)
        End Using

        request.BeginGetResponse(
            Function(x)
                Using response As HttpWebResponse = DirectCast(request.EndGetResponse(x), HttpWebResponse)
                    If callback IsNot Nothing Then
                        Dim ser As New DataContractJsonSerializer(GetType(WebResponse))
                        callback(TryCast(ser.ReadObject(response.GetResponseStream()), WebResponse))
                    End If
                End Using
                Return 0
            End Function, Nothing)
    End Sub
    
</script>




<%
    
    
    ' Notification payload
    'Dim title = nvUtiles.obtenerValor("title", "")
    'Dim body = nvUtiles.obtenerValor("body", "")
    'Dim tag = nvUtiles.obtenerValor("tag", "")
    
    ' Destinatario
    '0: segmento/aplicacion; 1: tema; 2: dispositivo
    'Dim destType = nvUtiles.obtenerValor("destType", "") 
    'Dim dest = nvUtiles.obtenerValor("dest", "")
    
    Dim modo As String = nvUtiles.obtenerValor("modo", "")

    Dim apiKey As String = nvUtiles.obtenerValor("apiKey", "")

    ' apikey de firma
    'Dim apiKey = "AAAALGx7L78:APA91bECTNhCHOJyV7jgssqSwIB6onfAcbBst5aBErYv6dz9qbAjWpT2eFCZgMOIN0NVXV55yq883JBoMGgoGAS4Pv1hVolcTpmqksR5t16rtnqb5VA5qxXAG9-kwA1Do5kVYpe3N7aq"
    
    ' apikey de webapp nova dev
    'Dim apiKey = "AAAA1idlOj8:APA91bHuvgx5FSAg6JMS_a0iixQxukwdHwQU7iYBhOaKioGvznW1OjX44aAhXGzLtRMJcwySWnqixYLrGUiZfD61QZQ6QFkqGAKsXhKwd5U2rsoyBaNBiF6TR4zPSG1iaOSQBKPrlv3C"
    
	' apikey de app de firma xamarin.android
    'Dim apiKey = "AAAATg9vAK0:APA91bE9JNt8zll41KxAndWYD63D_1jM_M-e8Gbln6bx5cdvVJbjkGwShs95k4lkFAXAyCiLUkVWtBKVqLP16eq-QFD6Rv4_I2zBs9b8jF3ccUMVpUE4ua38zsyKK5l5slVRD9gSWPsQ"
	
    Dim err As New tError()
   
    If (modo = "SEND_NOTI") Then
        Try
            Dim strJSON = nvUtiles.obtenerValor("strJSON", "")
            GetPOSTResponse(New Uri("https://fcm.googleapis.com/fcm/send"), strJSON, apiKey, Nothing)
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If
        
    
    
    




    


%>
<html>
<head>
    <title>Nuevo mensaje</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    
    <script type="text/javascript">
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }



        function window_onload() {
            $('btnAgregarData').onclick = function () {
                var row = $('tbDataPayload').insertRow();
                var cell1 = row.insertCell(0);
                var cell2 = row.insertCell(1);
                cell1.innerHTML = "<input type='text' style='width:100%' name='dataInputKey'/>";
                cell2.innerHTML = "<input type='text' style='width:100%' name='dataInputValue'/>";
            }

            $('sendNoti').onclick = sendNotification;


            //
            $('btnAgregarData').click();
            $('btnAgregarData').click();
            document.getElementsByName("dataInputKey")[0].value = "accion"
            document.getElementsByName("dataInputKey")[1].value = "rm0_remote_url"
            document.getElementsByName("dataInputValue")[0].value = "abrir_legajo"
            document.getElementsByName("dataInputValue")[1].value = "https://172.16.5.90/services/nvcertiservicedownload.aspx?filename=prueba_CUIT_20297225244.rm0" //"https://novatest.improntasolutions.com/services/nvCertiServiceConsulta.aspx?accion=getrm0&filename=prueba1.rm0"

        }


        function sendNotification() {

            var apiKey = $('selectApiKey').options[$('selectApiKey').selectedIndex].value;

            var to = $('to').value;
            
            var registration_ids = $('registration_ids').value.split(",");


            var condition = $('condition').value;

            var collapse_key = $('collapse_key').value;

            //var priority = $('priority').value;
            var priority = $('priority').options[$('priority').selectedIndex].value;

			// si lo pasaba como "string" me daba error en el servidor
            var content_available = ($('content_available').value==""?false:true);
            var delay_while_idle = $('delay_while_idle').value;
            var time_to_live = $('time_to_live').value;
            var restricted_package_name = $('restricted_package_name').value;
            var dry_run = $('dry_run').value;


            var title = $('title').value;
            var body = $('body').value;
            var icon = $('icon').value;
            var sound = $('sound').value;
            var badge = $('badge').value;
            var tag = $('tag').value;
            var color = $('color').value;
            var click_action = $('click_action').value;
            var body_loc_key = $('body_loc_key').value;
            var body_loc_args = $('body_loc_args').value;
            var title_loc_key = $('title_loc_key').value;
            var title_loc_args = $('title_loc_args').value;




            var object = {}

            if (to != "") {
                object.to = to;
            }
            if (registration_ids.length > 0) {
                if(registration_ids[0]!="")
                    object.registration_ids =  registration_ids ;
            }
            if (condition != "") {
                object.condition = condition;
            }
            if (collapse_key != "") {
                object.collapse_key = collapse_key;
            }

            if (priority != "") {
                object.priority = priority;
            }
            if (content_available != "") {
                object.content_available = content_available;
            }
            if (delay_while_idle != "") {
                object.delay_while_idle = delay_while_idle;
            }
            if (time_to_live != "") {
                object.time_to_live = time_to_live;
            }
            if (restricted_package_name != "") {
                object.restricted_package_name = restricted_package_name;
            }
            if (dry_run != "") {
                object.dry_run = dry_run;
            }



            var notification = {};
            if (title != "") {
                notification.title = title;
            }
            if (body != "") {
                notification.body = body;
            }
            if (icon != "") {
                notification.icon = icon;
            }
            if (sound != "") {
                notification.sound = sound;
            }
            if (badge != "") {
                notification.badge = badge;
            }
            if (tag != "") {
                notification.tag = tag;
            }
            if (click_action != "") {
                notification.click_action = click_action;
            }
            if (body_loc_key != "") {
                notification.body_loc_key = body_loc_key;
            }
            if (body_loc_args != "") {
                notification.body_loc_args = body_loc_args;
            }
            if (title_loc_key != "") {
                notification.title_loc_key = title_loc_key;
            }
            if (title_loc_args != "") {
                notification.title_loc_args = title_loc_args;
            }


            if (!isEmpty(notification)) {
                object.notification = notification;
            }
           

            var inputKeys = document.getElementsByName('dataInputKey');
            var inputValues = document.getElementsByName('dataInputValue');


            for (var i = 0; i < inputKeys.length; i++) {
                if (inputKeys[i].value != "") {
                    object.data = {};
                    break;
                }
            }


            for (var i = 0; i < inputKeys.length; i++) {
                if (inputKeys[i].value != "") {
                    object.data[inputKeys[i].value] = inputValues[i].value;
                }
            }
            
            nvFW.error_ajax_request('main.aspx', {
                parameters: {
                    apiKey: apiKey,
                    strJSON : JSON.stringify(object),
                    modo: "SEND_NOTI"
                },
                onSuccess: function (err, transport) {
                    if (err.params["actualizarObjetos"] == "true") { 
                        
                    }
                }
            });

        }

        function isEmpty(obj) {
            for (var prop in obj) {
                if (obj.hasOwnProperty(prop))
                    return false;
            }

            return JSON.stringify(obj) === JSON.stringify({});
        }

        function window_onresize() {

        }

    </script>

</head>

<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id='divContent'>

    <form name="formDocs" method="post" action="main.aspx" enctype="multipart/form-data"
    target="" style="width: 100%; height: 100%; overflow: hidden">
    <iframe name="iframeCargar" id="iframeCargar" style="display: none"></iframe>
    <input type="hidden" id='modo' name='modo' />
    <input type="hidden" id='idcert' name='idcert' />
    <div style="width: 100%; height: 100%;">

        <div>
        <table class='tb1'>
        <tr class='tbLabel'>
        <td>API KEY</td>
        <td><select id='selectApiKey'>
        <option value='AAAA1idlOj8:APA91bHuvgx5FSAg6JMS_a0iixQxukwdHwQU7iYBhOaKioGvznW1OjX44aAhXGzLtRMJcwySWnqixYLrGUiZfD61QZQ6QFkqGAKsXhKwd5U2rsoyBaNBiF6TR4zPSG1iaOSQBKPrlv3C'>WebApp Nova (improntatest@gmail.com)</option>
        <option value='AAAALGx7L78:APA91bECTNhCHOJyV7jgssqSwIB6onfAcbBst5aBErYv6dz9qbAjWpT2eFCZgMOIN0NVXV55yq883JBoMGgoGAS4Pv1hVolcTpmqksR5t16rtnqb5VA5qxXAG9-kwA1Do5kVYpe3N7aq'>Firma Android Nativo (desarrollo.impronta@gmail.com)</option>
        <option value='AAAATg9vAK0:APA91bE9JNt8zll41KxAndWYD63D_1jM_M-e8Gbln6bx5cdvVJbjkGwShs95k4lkFAXAyCiLUkVWtBKVqLP16eq-QFD6Rv4_I2zBs9b8jF3ccUMVpUE4ua38zsyKK5l5slVRD9gSWPsQ'>Firma Xamarin Android (desarrollo.impronta@gmail.com)</option>
        <option value='AAAA2eVrxCA:APA91bHw6A_eH3jm9tNofnkVT8YHzcsAacUNfLDgkeWSoJ7tSb2bsXKdDfmg3-UPF5eqD6z83ActKWuRg8yiQF1F8GuQYAJG_uJLsiD3uEWKNPo7XoOM3Lp0zDlYtWK68818wcHRG0CLiwbpjCAWeokg7bT5iVGtBQ'>Firma Xamarin iOS (desarrollo.impronta@gmail.com)</option>
        </select></td>
        </tr>
        </table>
        </div>

        <div style="float: left">
            <table class="tb1" style="width: 50%">
                <tr class="tbLabel">
                    <td colspan="2">
                        Params
                    </td>
                </tr>
                <tr class='tbLabel'>
                    <td colspan="2">
                        Objetivos
                    </td>
                </tr>
                <tr>
                    <td>
                        to
                    </td>
                    <td>
                        <input type="text" id="to" />
                    </td>
                </tr>
                <tr>
                    <td>
                        registration_ids
                    </td>
                    <td>
                        <input type="text" id="registration_ids" />
                    </td>
                </tr>
                <tr>
                    <td>
                        condition
                    </td>
                    <td>
                        <input type="text" id="condition" />
                    </td>
                </tr>
                <tr class='tbLabel'>
                    <td colspan="2">
                        Carga
                    </td>
                </tr>
                <tr>
                    <td>
                        collapse_key
                    </td>
                    <td>
                        <input type="text" id="collapse_key" />
                    </td>
                </tr>
                <tr>
                    <td>
                        priority
                    </td>
                    <td>
                        <select id="priority">
                            <option selected="selected" value="">normal</option>
                            <option value="high">high</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>
                        content_available
                    </td>
                    <td>
                        <input type="text" id="content_available" />
                    </td>
                </tr>
                <tr>
                    <td>
                        delay_while_idle
                    </td>
                    <td>
                        <input type="text" id="delay_while_idle" />
                    </td>
                </tr>
                <tr>
                    <td>
                        time_to_live (0 - 2419200 sec)
                    </td>
                    <td>
                        <input type="text" id="time_to_live" />
                    </td>
                </tr>
                <tr>
                    <td>
                        restricted_package_name
                    </td>
                    <td>
                        <input type="text" id="restricted_package_name" />
                    </td>
                </tr>
                <tr>
                    <td>
                        dry_run
                    </td>
                    <td>
                        <input type="text" id="dry_run" />
                    </td>
                </tr>
            </table>
        </div>
        <div style="float: left">
            <table class="tb1" style="width: 50%">
                <tr class="tbLabel">
                    <td colspan="2">
                        Notificacion Params
                    </td>
                </tr>
                <tr>
                    <td>
                        title
                    </td>
                    <td>
                        <input type="text" id="title" value="title"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        body
                    </td>
                    <td>
                        <input type="text" id="body" value="body" />
                    </td>
                </tr>
                <tr>
                    <td>
                        icon
                    </td>
                    <td>
                        <input type="text" id="icon" />
                    </td>
                </tr>
                <tr>
                    <td>
                        sound
                    </td>
                    <td>
                        <input type="text" id="sound" />
                    </td>
                </tr>
                <tr>
                    <td>
                        badge
                    </td>
                    <td>
                        <input type="text" id="badge" />
                    </td>
                </tr>
                <tr>
                    <td>
                        tag
                    </td>
                    <td>
                        <input type="text" id="tag" />
                    </td>
                </tr>
                <tr>
                    <td>
                        color
                    </td>
                    <td>
                        <input type="text" id="color" />
                    </td>
                </tr>
                <tr>
                    <td>
                        click_action
                    </td>
                    <td>
                        <input type="text" id="click_action" value="OPEN_HOME_ACTIVITY"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        body_loc_key
                    </td>
                    <td>
                        <input type="text" id="body_loc_key" />
                    </td>
                </tr>
                <tr>
                    <td>
                        body_loc_args
                    </td>
                    <td>
                        <input type="text" id="body_loc_args" />
                    </td>
                </tr>
                <tr>
                    <td>
                        title_loc_key
                    </td>
                    <td>
                        <input type="text" id="title_loc_key" />
                    </td>
                </tr>
                <tr>
                    <td>
                        title_loc_args
                    </td>
                    <td>
                        <input type="text" id="title_loc_args" />
                    </td>
                </tr>
            </table>
        </div>



        <div>
            <table class="tb1" style="width: 50%">
                <tr class="tbLabel">
                    <td colspan="2">
                        Datos personalizados
                    </td>
                </tr>
                <tr>
                    <td>
                        Clave
                    </td>
                    <td>
                        Valor
                    </td>
                </tr>
            </table>

            <table id='tbDataPayload' class="tb1" style="width: 50%">
            </table>

            <input type="button" value="agregar" id="btnAgregarData" />

        </div>
        <div>
            <input type="button" value="Enviar Notificación" id="sendNoti" />
        </div>
    </div>
     </form>
	</div>
	
    <!--
    <div id='divDocu'>
	<iframe src="https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages" name="iframeinfo" id="iframeinfo"></iframe>
    </div>-->
   
</body>
</html>
