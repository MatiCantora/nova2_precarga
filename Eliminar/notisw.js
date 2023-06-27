self.addEventListener('message', function (evt) 
  {
  debugger
  console.log('postMessage received', evt.data);
  var options = evt.data;
  var notificationTitle
  if (options["title"] != undefined)
    notificationTitle = options["title"]
  
  //var options2 = {}
  
  //var notificationOptions = {
  //  body: payload["body"],
  //  icon: payload["icon"]
  //};
  //evt.waitUntil(self.registration.showNotification(notificationTitle,options).then(notificationEvent => {
  //     let notification = notificationEvent.notification;
  //     setTimeout(() => notification.close(), options.timeout);
  //  }));

  event.waitUntil(
    self.registration.showNotification(notificationTitle, options)
    .then(notificationEvent => {
       debugger
       let notification = notificationEvent.notification;
       setTimeout(() => notification.close(), options.timeout);
    })
  );

});