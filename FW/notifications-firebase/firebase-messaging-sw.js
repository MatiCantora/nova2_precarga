// Import and configure the Firebase SDK
// These scripts are made available when the app is served or deployed on Firebase Hosting
// If you do not serve/host your project using Firebase Hosting see https://firebase.google.com/docs/web/setup

//importScripts('/__/firebase/3.9.0/firebase-app.js');
//importScripts('/__/firebase/3.9.0/firebase-messaging.js');
//importScripts('/__/firebase/init.js');
//const messaging = firebase.messaging();


	
 //* Here is is the code snippet to initialize Firebase Messaging in the Service
 //* Worker when your app is not hosted on Firebase Hosting.

 // [START initialize_firebase_in_sw]
 // Give the service worker access to Firebase Messaging.
 // Note that you can only use Firebase Messaging here, other Firebase libraries
 // are not available in the service worker.
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









