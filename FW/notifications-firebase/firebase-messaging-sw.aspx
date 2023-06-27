<%@ Page Language="VB" AutoEventWireup="false" %>

<%@ Import Namespace="nvFW" %>
<%

Response.ContentType = "text/javascript"
%>


importScripts("https://www.gstatic.com/firebasejs/4.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/4.10.1/firebase-messaging.js");

 // Initialize the Firebase app in the service worker by passing in the
 // messagingSenderId.
 firebase.initializeApp({
   'messagingSenderId': "596695740437"
 });

 // Retrieve an instance of Firebase Messaging so that it can handle background
 // messages.
 const messaging = firebase.messaging();
 // [END initialize_firebase_in_sw]



// If you would like to customize notifications that are received in the
// background (Web app is closed or not in browser focus) then you should
// implement this optional method.
// [START background_handler]

messaging.setBackgroundMessageHandler(function(payload) {
	
	// Solo será llamado si la notificacion, no tiene el campo "notification" y ademas la app debe estar en segundo plano
	// sino que trae toda la info en el campo "data":
	//{	
    //"data": {
    //    "key": "value"
    //}
	//}
	
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  var notificacion = JSON.parse(payload.data.notificacion)
  
  // Customize notification here
  const notificationTitle = notificacion.titulo;
  const notificationOptions = {
    body: notificacion.cuerpo,
    icon: notificacion.icono
  };

  return self.registration.showNotification(notificationTitle,
      notificationOptions);
});
// [END background_handler]



/*
// aca entra cuando la app tiene foco, pero solo
// es valida en la pagina web no en el service worker
messaging.onMessage(function(payload) {
	

  //console.log("onMessage SWorker Message received. ", payload);
  // ...
  
	const notificationTitle = 'App on FOCUS Message Title';
  const notificationOptions = {
    body: 'FOCUS Message body.',
    icon: '/firebase-logo.png'
  };

  return self.registration.showNotification(notificationTitle,
      notificationOptions);
  
});*/







/*
// por mas que trate de reclamar el cliente serviceworker es nulo a menos que refresque la pagina
self.addEventListener('install', function(event) {
    event.waitUntil(self.skipWaiting()); // Activate worker immediately
});

self.addEventListener('activate', function(event) {
    event.waitUntil(self.clients.claim()); // Become available to all pages
});*/


self.addEventListener('message', function (evt) {
	
  console.log('postMessage received', evt.data);
  
  var notificacion = JSON.parse(evt.data);
 
  const notificationOptions = {
    body: notificacion["cuerpo"],
    icon: notificacion["icono"]
  };
  evt.waitUntil(
    self.registration.showNotification(notificacion["titulo"],
      notificationOptions)
  );
});




