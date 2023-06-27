<%@ Page Language="VB" AutoEventWireup="false"  Inherits="System.Web.UI.Page" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>

   <script type="text/javascript">

   var _notify_isInit = false
   var _notify_registration
   function notify_init()
        {
        if (notify_supported() && !_notify_isInit)
          {
          _notify_isInit = true;
          navigator.serviceWorker.register('notisw.js')
			.then(reg => {debugger; _notify_registration = reg; return console.log('SW registered!', reg)}
			).catch(err => console.log('Boo!', err));
          }
		}
   
   function notify_supported() 
        {
        return ("Notification" in window) && ('serviceWorker' in navigator);
        }

    function notify_requestPermission()
       {
       if (notify_supported() ) 
         Notification.requestPermission();
       }
  
   function notify_send(titulo, options, timeOut)
     {
     debugger
     notify_requestPermission()
     notify_init()
     if (Notification.permission === "granted")
       {
       //var notif = new Notification("Ejemplo de notificación", options);
       //setTimeout(function() {notif.close()}, timeOut);
       if (!options) options = {}
       if (!timeOut) timeOut = 3000
       
       options.title = titulo
       options.timeout = timeOut
       var notification = options;
       try
         {
         navigator.serviceWorker.controller.postMessage(notification)
         }
       catch(e){}
       }
     
     //var options = {
     //     body: "Este es le cuerpo de la notificación"
     //     //,icon: "imgs/logoNotifs.png"
     //     };
 
     //var notif = new Notification("Ejemplo de notificación", options);
     //setTimeout(function() {notif.close()}, 3000);
     }
   
   // function GetWebNotificationsSupported() 
   //     {
   //     return (!!window.Notification);
   //     }
   
   
   // function AskForWebNotificationPermissions()
   //    {
   //    //if (!handler) handler = null
   //    if (Notification) 
   //      {
   //      Notification.requestPermission();
   //      }
   //    }
   
   //function notify_asksupport()
   //  {
   //  nvFW.alert(GetWebNotificationsSupported().toString())
   //  }
   
   //function notify_send()
   //  {
   //  var options = {
   //       body: "Este es le cuerpo de la notificación"
   //       //,icon: "imgs/logoNotifs.png"
   //       };
 
   //  var notif = new Notification("Ejemplo de notificación", options);
   //  setTimeout(function() {notif.close()}, 3000);
   //  }
   </script>
        
</head>
<body  style="width: 100%; height: 100%; overflow: auto" >
    <input type="button" style="width:250px; height:100px" value="¿Soporta notificacines?" onclick="notify_asksupport()" />
    <input type="button" style="width:250px; height:100px" value="Solicitar permisos" onclick="AskForWebNotificationPermissions()" />
    <input type="button" style="width:250px; height:100px" value="Notificar" onclick="notify_send('Hola mundo', {body:'Este es el cuerpo'}, 3000)" />

</body>
</html>
