<%@ Page Language="VB" AutoEventWireup="false" %>

<%@ Import Namespace="nvFW" %>
<%

Response.ContentType = "text/javascript"
%>


self.addEventListener('install', function(event) {
    event.waitUntil(self.skipWaiting()); // Activate worker immediately
});

self.addEventListener('activate', function(event) {
    event.waitUntil(self.clients.claim()); // Become available to all pages
});


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