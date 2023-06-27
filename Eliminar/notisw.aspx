<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%

	Response.ContentType = "text/javascript"
%>

self.addEventListener('message', function (evt) {
  console.log('postMessage received', evt.data);
  var payload = evt.data;
  var notificationTitle = payload["title"];
  var notificationOptions = {
    body: payload["body"],
    icon: payload["icon"]
  };
  evt.waitUntil(
    self.registration.showNotification(notificationTitle,
      notificationOptions)
  );
});